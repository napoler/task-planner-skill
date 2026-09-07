#!/usr/bin/env bash
# [2026-09-08 task-v055-fallback] subagent-fallback.sh — provider 类失败后主动 Scaling 改派（用户裁决 09-08）
#
# 背景: 路由 provider（ccr 192.168.123.36:3456）间歇宕时,子代理 haiku-1/sonnet-1/mini 全部
#       400/断连 → Agent 工具同步阻塞挂 ~5 分钟才失败（09-08 实测 37 次派发 27 失败=73%,
#       findings R10）。本脚本提供「失败后主动指定模型改派」机制:
#       探测 fallback 通道 → 生成变体 agent（指定可用模型）→ 决策改派目标。
#
# 模式:
#   probe [--plan-dir <dir>] [--out <path>] [--max <n>] [--timeout-ms <ms>] [--no-network]
#     读 $ZCODE_HOME/v2/config.json provider 表,对 config#provider_fallback.fallback_slugs
#     在各 provider 中的 (provider_key, model) 组合做 1-token 探测,写 health JSON:
#     默认 <plan-dir>/.provider-health.json;无 plan-dir 时 /tmp/task-planner-provider-health.json
#     stdout: 单行 JSON {health_file, ok, failed}
#   bind [--zcode-home <dir>] [--plan-dir <dir>] [--out <path>]
#     按 health + config 生成变体 agent 文件 $ZCODE_HOME/agents/<type>-fb.md
#     (frontmatter 继承源 agent,仅 model 行换成 custom:<fallback-uuid>:<slug> + 登记标记),
#     幂等（内容 md5）,清理本轮 variant_types 之外的陈旧 -fb 登记;stdout: 报告 JSON
#   next <type> [err_kind] [--plan-dir <dir>] [--out <path>]
#     err_kind ∈ provider|network|timeout|400|unknown → 有健康通道:
#       {"dispatch_as":"<type>-fb","model":"custom:<uuid>:<slug>","zero_cost":true}
#       （零消耗改派,不计 subagent.retry_limit;无健康通道/无 health →
#       {"dispatch_as":null,"escalation":"main_takeover_or_askuser"}）
#     其他 err_kind（逻辑错/工具错）→ 提示按 Rule 22.3 原顺序处理
#
# 约束: bash+jq+curl（探测）;--no-network 时 probe 只解析不请求
# 边界（如实登记）: 变体 agent 定义对 Agent 工具的识别随会话启动固化——
#   bind 生成后当前会话不可见,新会话才可用;next 的改派目标须由主进程按 Handoff 表
#   登记并以新会话/或主进程接管方式兑现（Rule 22.3 升级条款）
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_JSON="$SKILL_ROOT/config.json"
ZCODE_HOME="${ZCODE_HOME:-$HOME/.zcode}"

CFG_ENABLED=true
CFG_VARIANT_TYPES="executor,explore,code-assistant,general-purpose"
CFG_FALLBACK_SLUGS="agnes-2.5-flash"
CFG_PROBE_TIMEOUT_MS=10000

load_config() {
    # config.json#properties.provider_fallback.* 缺失 → 保持内置默认
    command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ] || return 0
    local v
    v="$(jq -r '.properties.provider_fallback.enabled.default // empty' "$CONFIG_JSON" 2>/dev/null)"
    [ -n "$v" ] && CFG_ENABLED="$v"
    v="$(jq -r '.properties.provider_fallback.variant_types.default // empty' "$CONFIG_JSON" 2>/dev/null)"
    [ -n "$v" ] && CFG_VARIANT_TYPES="$v"
    v="$(jq -r '.properties.provider_fallback.fallback_slugs.default // empty' "$CONFIG_JSON" 2>/dev/null)"
    [ -n "$v" ] && CFG_FALLBACK_SLUGS="$v"
    v="$(jq -r '.properties.provider_fallback.probe_timeout_ms.default // empty' "$CONFIG_JSON" 2>/dev/null)"
    [ -n "$v" ] && CFG_PROBE_TIMEOUT_MS="$v"
}

resolve_candidates() {
    # 输出 NUL 分隔三元组: provider_key\0provider_name\0model\0
    # 候选 = fallback_slugs 与任一 provider.models 的交集;顺序 = config provider 表顺序
    local v2="$ZCODE_HOME/v2/config.json"
    [ -f "$v2" ] || return 1
    command -v jq >/dev/null 2>&1 || return 1
    jq -r --arg sl "$CFG_FALLBACK_SLUGS" '
        (.provider // {}) | to_entries[]
        | .key as $k | .value as $vv
        | ($vv.models // {} | keys) as $ms
        | $ms[] as $m
        | select( ($sl | split(",") | map(gsub("^\\s+|\\s+$";"")) | map(select(length>0))) as $allowed
                  | any($allowed[]; $m == .) )
        | [ $k, ($vv.name // $k), $m ] | @tsv
    ' "$v2" 2>/dev/null | while IFS=$'\t' read -r pk pn pm; do
        printf '%s\0%s\0%s\0' "$pk" "$pn" "$pm"
    done
}

probe_one() {
    # probe_one <provider_key> <model> → rc 0=ok / 1=err（stderr 输出原因）
    local pk="$1" model="$2"
    local v2="$ZCODE_HOME/v2/config.json"
    local base apikey
    base="$(jq -r ".provider[\"$pk\"].options.baseURL // .provider[\"$pk\"].baseUrl // empty" "$v2" 2>/dev/null)"
    apikey="$(jq -r ".provider[\"$pk\"].options.apiKey // .provider[\"$pk\"].apiKey // empty" "$v2" 2>/dev/null)"
    [ -n "$base" ] || { printf 'no_baseURL' >&2; return 1; }
    [ -n "$apikey" ] || { printf 'no_apiKey' >&2; return 1; }
    local base_trim="${base%/}" url
    case "$base_trim" in
        *"/v1") url="${base_trim}/messages" ;;
        *)      url="${base_trim}/v1/messages" ;;
    esac
    local deadline_s=$(( (CFG_PROBE_TIMEOUT_MS + 999) / 1000 ))
    [ "$deadline_s" -lt 2 ] && deadline_s=2
    local out
    out="$(curl -sS -m "$deadline_s" -X POST "$url" \
        -H "x-api-key: $apikey" -H "authorization: Bearer $apikey" \
        -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
        -d "$(jq -n --arg m "$model" '{model:$m, max_tokens:1, messages:[{role:"user",content:"ping"}]}')" 2>&1)"
    local rc=$?
    if [ $rc -ne 0 ]; then printf 'curl_rc=%s' "$rc" >&2; return 1; fi
    if ! grep -q '"type":"message"' <<<"$out"; then
        printf 'reject: %s' "$(head -c 120 <<<"$out" | tr -d '\n')" >&2
        return 1
    fi
    # 外层 500 包 404/限流形态（如 {"code":500,"msg":"404 NOT_FOUND"} / rate_limit_error）
    if grep -qE '"(code|error)":([0-9]+|\{)|AuthError|Unauthorized|Forbidden|rate_limit' <<<"$out"; then
        printf 'reject: %s' "$(head -c 120 <<<"$out" | tr -d '\n')" >&2
        return 1
    fi
    return 0
}

cmd_probe() {
    local network=1 max=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --plan-dir)    PLAN_DIR="$2"; shift 2 ;;
            --out)        HEALTH_OUT="$2"; shift 2 ;;
            --max)        max="$2"; shift 2 ;;
            --timeout-ms) CFG_PROBE_TIMEOUT_MS="$2"; shift 2 ;;
            --no-network) network=0; shift ;;
            *) shift ;;
        esac
    done
    load_config
    local hp="${HEALTH_OUT:-${PLAN_DIR:+$PLAN_DIR/.provider-health.json}}"
    [ -n "$hp" ] || hp="/tmp/task-planner-provider-health.json"
    local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    local entries=() n=0
    local pk pn pm status err
    while IFS= read -r -d '' pk && IFS= read -r -d '' pn && IFS= read -r -d '' pm; do
        [ $max -gt 0 ] && [ $n -ge $max ] && break
        n=$((n + 1))
        status="ok"; err=""
        if [ "$network" -eq 1 ]; then
            if err="$(probe_one "$pk" "$pm" 2>&1)"; then status=ok
            else status=err; fi
        else
            status=skipped; err=no_network
        fi
        entries+=("$pk"$'\t'"$pn"$'\t'"$pm"$'\t'"$status"$'\t'"$err")
    done < <(resolve_candidates)
    # 逐条 JSON 行 → 合成 entries 数组(单次 jq 生成,避免拼接不完整 JSON)
    local entries_json
    if [ ${#entries[@]} -gt 0 ]; then
        entries_json="$(for e in "${entries[@]}"; do
            IFS=$'\t' read -r pk pn pm status err <<<"$e"
            jq -cn --arg p "$pk" --arg pn "$pn" --arg m "$pm" --arg s "$status" --arg e "$err" \
                '{provider:$p, provider_name:$pn, model:$m, status:$s, error:$e}'
        done | jq -cs '.')"
    else
        entries_json="[]"
    fi
    mkdir -p "$(dirname "$hp")" 2>/dev/null || true
    if ! jq -cn --arg ts "$ts" --argjson e "$entries_json" '{ts:$ts, entries:$e}' > "$hp"; then
        printf '{"error":"health_write_failed","path":"%s"}\n' "$hp" >&2; exit 1
    fi
    local okc errc
    okc="$(jq -r '[.entries[] | select(.status=="ok")] | length' "$hp" 2>/dev/null || echo 0)"
    errc="$(jq -r '[.entries[] | select(.status=="err")] | length' "$hp" 2>/dev/null || echo 0)"
    jq -cn --arg hp "$hp" --argjson ok "$okc" --argjson err "$errc" \
        '{health_file:$hp, ok:$ok, failed:$err}'
}

cmd_bind() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --zcode-home) ZCODE_HOME="$2"; shift 2 ;;
            --plan-dir)   PLAN_DIR="$2"; shift 2 ;;
            --out)        HEALTH_OUT="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    load_config
    local agents_dir="$ZCODE_HOME/agents"
    [ -d "$agents_dir" ] || { printf '{"error":"agents_dir_missing","path":"%s"}\n' "$agents_dir" >&2; exit 2; }
    local meta_file="$agents_dir/.task-planner-fallback-meta.json"
    [ -f "$meta_file" ] || printf '{"files":{}}\n' > "$meta_file"
    local hp="${HEALTH_OUT:-${PLAN_DIR:+$PLAN_DIR/.provider-health.json}}"
    [ -n "$hp" ] || hp="$agents_dir/.last-probe.json"
    [ -f "$hp" ] || { printf '{"error":"no_health","hint":"先跑 probe(可 --plan-dir 指定)或 --out 指定既有 health"}\n' >&2; exit 2; }
    local best
    best="$(jq -c '[.entries[] | select(.status=="ok")] | .[0] // empty' "$hp" 2>/dev/null)"

    local created=() skipped=() cleaned=() failures=()
    local t
    for t in $(printf '%s' "$CFG_VARIANT_TYPES" | tr ',' ' '); do
        t="$(printf '%s' "$t" | tr -d ' \t')"
        [ -n "$t" ] || continue
        local src="$agents_dir/$t.md" tgt="$agents_dir/${t}-fb.md"
        if [ ! -f "$src" ]; then failures+=("$t: source missing"); continue; fi
        if [ -z "$best" ]; then skipped+=("$t: no healthy channel"); continue; fi
        local bp bm model_line
        bp="$(jq -r .provider <<<"$best")"; bm="$(jq -r .model <<<"$best")"
        model_line="custom:${bp}:${bm}"
        # 源 agent frontmatter: 保留全部键;model 行原地替换为 fallback 通道;name 行后插 name_suffix 登记键
        local fm_new
        fm_new="$(awk -v ml="$model_line" 'NR==1{if($0=="---"){f=1;next}} f&&/^---$/{exit} f{
                if($0 ~ /^model:/) {print "model: \"" ml "\""; next}
                if($0 ~ /^name:/) {print $0; print "name_suffix: task-planner-fallback-variant"}
                else print
            }' "$src")"
        # 源无 model 键 → 追加(不覆盖已有键语义)
        grep -q '^model:' <<<"$fm_new" || fm_new="$(printf '%s\nmodel: "%s"' "$fm_new" "$model_line")"
        # 源无 name 键 → 补 name（type 名兜底）
        grep -q '^name:' <<<"$fm_new" || fm_new="name: ${t}-fb
$(printf '%s' "$fm_new")"
        local body
        body="$(awk 'f>=2{print} /^---$/{f++; next}' "$src")"
        local content
        content="$(printf -- '---\n%s\n---\n\n%s\n' "$fm_new" "$body")"
        local new_hash; new_hash="$(printf '%s' "$content" | md5sum | cut -d' ' -f1)"
        local old_hash
        old_hash="$(jq -r --arg f "$(basename "$tgt")" '.files[$f].hash // empty' "$meta_file" 2>/dev/null)"
        if [ -f "$tgt" ] && [ "$old_hash" = "$new_hash" ]; then
            skipped+=("$t")
            continue
        fi
        if ! printf '%s\n' "$content" > "$tgt"; then failures+=("$t: write failed"); continue; fi
        jq --arg f "$(basename "$tgt")" --arg h "$new_hash" --arg s "$t.md" --arg m "$model_line" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '.files[$f] = {hash:$h, source:$s, model:$m, created_ts:$ts}' "$meta_file" > "$meta_file.tmp" \
            && mv "$meta_file.tmp" "$meta_file"
        created+=("$t")
    done
    # 清理陈旧登记（本轮 variant_types 集合之外的 -fb 文件）
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        local owner="${f%-fb.md}" in_list=0 t2
        for t2 in $(printf '%s' "$CFG_VARIANT_TYPES" | tr ',' ' '); do
            [ "$(printf '%s' "$t2" | tr -d ' \t')" = "$owner" ] && in_list=1
        done
        if [ "$in_list" -eq 0 ]; then
            rm -f "$agents_dir/$f" 2>/dev/null && cleaned+=("$f")
            jq --arg f "$f" 'del(.files[$f])' "$meta_file" > "$meta_file.tmp" 2>/dev/null && mv "$meta_file.tmp" "$meta_file" || true
        fi
    done < <(jq -r '.files // {} | keys[]' "$meta_file" 2>/dev/null)
    jq -n \
        --argjson c "$(printf '%s\n' "${created[@]:-}"   | jq -R 'select(length>0)' | jq -sc '.')" \
        --argjson s "$(printf '%s\n' "${skipped[@]:-}"   | jq -R 'select(length>0)' | jq -sc '.')" \
        --argjson x "$(printf '%s\n' "${cleaned[@]:-}"   | jq -R 'select(length>0)' | jq -sc '.')" \
        --argjson f "$(printf '%s\n' "${failures[@]:-}"  | jq -R 'select(length>0)' | jq -sc '.')" \
        --arg m "${best:-none}" \
        '{created:$c, skipped:$s, cleaned:$x, failures:$f, bound_model:$m,
          note:"变体 agent 新会话才对 Agent 工具可见(类型列表会话启动固化);Handoff 表状态列记 scaling-redispatch"}'
}

cmd_next() {
    local type="${1:-}" err_kind="${2:-}"
    [ -n "$type" ] || { printf '{"error":"usage: next <type> [err_kind]"}\n' >&2; exit 2; }
    while [ $# -gt 0 ]; do
        case "$1" in
            --plan-dir) PLAN_DIR="$2"; shift 2 ;;
            --out)      HEALTH_OUT="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    load_config
    if [ "$CFG_ENABLED" != "true" ]; then
        printf '{"dispatch_as":null,"reason":"provider_fallback_disabled","escalation":"main_takeover_or_askuser"}\n'
        return 0
    fi
    case "$err_kind" in
        provider|network|timeout|400|unknown|"")
            local hp="${HEALTH_OUT:-${PLAN_DIR:+$PLAN_DIR/.provider-health.json}}"
            [ -n "$hp" ] || hp="$ZCODE_HOME/agents/.last-probe.json"
            if [ ! -f "$hp" ]; then
                printf '{"dispatch_as":null,"reason":"no_health_file","hint":"先运行: bash <skill>/scripts/subagent-fallback.sh probe --plan-dir <plan-dir> 再 bind","escalation":"main_takeover_or_askuser"}\n'
                return 0
            fi
            local best
            best="$(jq -c '[.entries[] | select(.status=="ok")] | .[0] // empty' "$hp" 2>/dev/null)"
            if [ -z "$best" ]; then
                printf '{"dispatch_as":null,"reason":"no_healthy_channel","escalation":"main_takeover_or_askuser","hint":"主通道与 fallback 通道均不可用 → Rule 22.3 ③ 主进程接管 / ④ AskUser"}\n'
                return 0
            fi
            jq -n \
                --arg t "${type}-fb" \
                --arg m "custom:$(jq -r .provider <<<"$best"):$(jq -r .model <<<"$best")" \
                '{dispatch_as:$t, model:$m, reason:"provider_failure_scaling", zero_cost:true,
                  note:"零消耗改派,不计 subagent.retry_limit;变体新会话可见;Handoff 状态列记 failed→scaling-redispatch"}'
            ;;
        *)
            printf '{"dispatch_as":null,"reason":"non_provider_error","hint":"非 provider 类失败按 Rule 22.3 原顺序: ①换类型 → ②降档 → ③主进程接管 → ④AskUser（消耗 retry_limit）"}\n'
            return 0
            ;;
    esac
}

usage() {
    cat <<'EOF'
Usage: subagent-fallback.sh <mode> [args]
  probe  [--plan-dir <dir>] [--out <path>] [--max <n>] [--timeout-ms <ms>] [--no-network]
  bind   [--zcode-home <dir>] [--plan-dir <dir>] [--out <path>]
  next   <type> [err_kind] [--plan-dir <dir>] [--out <path>]
err_kind: provider|network|timeout|400|unknown(零消耗改派) | 其他(走 22.3 原顺序)
EOF
}

main() {
    local mode="${1:-}"
    [ -n "$mode" ] && shift || true
    case "$mode" in
        probe) cmd_probe "$@" ;;
        bind)  cmd_bind "$@" ;;
        next)  cmd_next "$@" ;;
        -h|--help|"") usage ;;
        *) printf '{"error":"unknown_mode","mode":"%s"}\n' "$mode" >&2; exit 2 ;;
    esac
}

main "$@"
