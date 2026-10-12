#!/usr/bin/env bash
# check-rescue-chain.sh — task-v065 S-1 F-1: 子代理失败挽救链路机械门控
#
# 背景：用户核心诉求「子代理失败之后应该采取挽救方案而不是摆烂」。审计发现失败挽救
#   链路（检查点续跑 → 五机械档+22.3.3 评估档兜底串行穷尽 → 才可 STOP）100% 存在于文本、0% 存在于机械
#   机制。本脚本把 Rule 22.8.4（failed/timeout 行必须回填 checkpoint 路径）与「挽救档位
#   留痕」变成终验可机械校验的闸门（对应 Rule 22.7 连续失败语义：≥2 次失败强制换档挽救）。
#
# 用途：校验 <plan-dir>/task_plan.md 的「Subagent Handoff 登记表」区块中，
#   状态含 `failed` 或 `timeout` 的行是否具备完整挽救证据（三查）：
#     ① checkpoint 路径列非空（非 `-` / 非空白）
#     ② rescue 列存在且非空（挽救档位留痕，如 `①改派:done→②拆细:done`；不校验格式，非空即可）
#     ③ <plan-dir>/subagent-state/ 下对应检查点文件真实存在
#          （列内路径命中 → 或 `{seq}-{agent_type}.md` 模式命中）
#
# Usage: bash check-rescue-chain.sh <plan-dir> [--json]
#
# 档位（优先级从高到低，与 check-dispatch.sh/resolve-interaction-mode.sh 同口径）：
#   ① env TASK_PLANNER_RESCUE_CHAIN_ENFORCE=enforce|warn|off（非法值忽略，降级下一级）
#   ② config.json .properties.rescue_chain_enforce.default
#   ③ 键缺失 / config 缺失 / 解析失败 / jq 缺失 → warn（fail-open，stderr 说明）
#   enforce=存在违规 → exit 1；warn=打印违规但 exit 0；off=不做校验 exit 0
#
# 退出码：0=通过 或 warn/off 档；1=enforce 档存在违规；2=参数错误
# fail-open：plan-dir 存在但 task_plan.md 不可读 → 视为无计划 exit 0；无 Handoff 区块 /
#   区块无 failed|timeout 行 → total_failed=0 且 exit 0（与 check-plan-dispatch.sh 同口径）
#
# [2026-09-13 task-v065 S-1] 新建（F-1 规格）。设计说明：
#   - 「rescue 列缺失」计为违规：登记表没有该列时，failed 行不可能留下挽救档位证据，
#     等同留痕为空（规格「rescue 列存在且非空」的严格读法）。
#   - 「Handoff 行 N」的 N = task_plan.md 内物理行号（便于定位）。
#   - JSON 手写转义，不依赖 jq（jq 缺失也要能出合法 JSON）。
#   - 纯 bash while-read 状态机（与 check-plan-dispatch.sh 一致，规避 gawk 区间模式 bug）。

set -u

usage() {
    printf 'usage: bash check-rescue-chain.sh <plan-dir> [--json]\n' >&2
}
die2() {
    printf '[rescue] 参数错误: %s\n' "$1" >&2
    usage
    exit 2
}
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}
emit_pass_json() {
    printf '{"total_failed":0,"violations":[],"verdict":"pass"}\n'
}

# ── 参数解析 ────────────────────────────────────────────────────────────────
PLAN_DIR=""
JSON_OUT=0
for arg in "$@"; do
    case "$arg" in
        --json) JSON_OUT=1 ;;
        -h|--help) usage; exit 0 ;;
        -*) die2 "未知选项 $arg" ;;
        *)
            if [ -z "$PLAN_DIR" ]; then PLAN_DIR="$arg"; else die2 "多余参数 $arg"; fi
            ;;
    esac
done
[ -n "$PLAN_DIR" ] || die2 "缺少 <plan-dir>"
[ -d "$PLAN_DIR" ] || die2 "plan-dir 不存在或非目录: $PLAN_DIR"
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
PLAN_FILE="$PLAN_DIR/task_plan.md"

# ── fail-open：无计划文件 ────────────────────────────────────────────────────
if [ ! -f "$PLAN_FILE" ] || [ ! -r "$PLAN_FILE" ]; then
    if [ "$JSON_OUT" -eq 1 ]; then emit_pass_json
    else printf '[rescue] fail-open: no readable task_plan.md (%s)\n' "$PLAN_FILE"; fi
    exit 0
fi

# ── 档位解析 ────────────────────────────────────────────────────────────────
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_JSON="$SKILL_ROOT/config.json"

resolve_tier() {
    local m="${TASK_PLANNER_RESCUE_CHAIN_ENFORCE:-}"
    case "$m" in
        enforce|warn|off) printf '%s' "$m"; return 0 ;;
    esac
    if ! command -v jq >/dev/null 2>&1; then
        printf '[rescue] jq 不可用 — fail-open 降级 warn 档（不阻断终验）\n' >&2
        printf 'warn'; return 0
    fi
    if [ ! -f "$CONFIG_JSON" ]; then
        printf '[rescue] config.json 缺失 — fail-open 降级 warn 档\n' >&2
        printf 'warn'; return 0
    fi
    m="$(jq -r '.properties.rescue_chain_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || {
        printf '[rescue] config.json rescue_chain_enforce 解析失败 — fail-open 降级 warn 档\n' >&2
        printf 'warn'; return 0
    }
    case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
}

TIER="$(resolve_tier)"

if [ "$TIER" = "off" ]; then
    if [ "$JSON_OUT" -eq 1 ]; then emit_pass_json
    else printf '[rescue] off 档: 跳过挽救链路门控\n'; fi
    exit 0
fi

# ── 单元格清洗（去 markdown 修饰 + 首尾空白）─────────────────────────────────
clean_cell() {
    local s="$1"
    s="${s//\`/}"
    s="${s//\*\*/}"
    s="${s//$'\r'/}"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# ── 扫描 Handoff 区块 ───────────────────────────────────────────────────────
in_section=0
header_found=0
col_status=0; col_cp=0; col_rescue=0; col_type=0; col_seq=0
line_no=0
total_failed=0
violation_rows=0
v_json=""
human_lines=""

while IFS= read -r line; do
    line_no=$((line_no + 1))

    if [ "$in_section" -eq 0 ]; then
        if [[ "$line" =~ ^##[[:space:]].*Subagent.*Handoff ]]; then
            in_section=1
        fi
        continue
    fi
    # 区块结束：下一个二级标题（`### ` 第三字符是 #，不匹配 `^## `）
    if [[ "$line" =~ ^##[[:space:]] ]]; then
        break
    fi

    # 表头行：区块内首个 `|` 开头且含「状态」或 subagent_type 的行
    if [ "$header_found" -eq 0 ]; then
        case "$line" in
            '|'*)
                if [[ "$line" == *状态* || "$line" == *subagent_type* ]]; then
                    IFS='|' read -ra H <<< "$line"
                    hidx=0
                    for hc in "${H[@]}"; do
                        hclean="$(clean_cell "$hc")"
                        if [ "$col_seq" -eq 0 ] && [ "$hidx" -gt 0 ] && [ "$hclean" = "#" ]; then col_seq=$hidx; fi
                        if [ "$col_status" -eq 0 ] && [[ "$hclean" == *状态* || "$hclean" == *status* ]]; then col_status=$hidx; fi
                        if [ "$col_cp" -eq 0 ] && [[ "$hclean" == *checkpoint* || "$hclean" == *检查点* ]]; then col_cp=$hidx; fi
                        if [ "$col_rescue" -eq 0 ] && [[ "$hclean" == *rescue* || "$hclean" == *挽救* ]]; then col_rescue=$hidx; fi
                        if [ "$col_type" -eq 0 ] && [[ "$hclean" == *subagent_type* ]]; then col_type=$hidx; fi
                        hidx=$((hidx + 1))
                    done
                    header_found=1
                fi
                ;;
        esac
        continue
    fi

    # 数据行：仅 `|` 开头；跳过分隔行
    case "$line" in
        '|'*) ;;
        *) continue ;;
    esac
    if [[ "$line" =~ ^\|[[:space:]]*-+ ]]; then continue; fi

    IFS='|' read -ra C <<< "$line"
    status="$(clean_cell "${C[$col_status]:-}")"
    status_lc="$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
    case "$status_lc" in
        *failed*|*timeout*) ;;
        *) continue ;;
    esac

    total_failed=$((total_failed + 1))
    reasons=""

    # ① checkpoint 路径列非空
    cp_val=""
    if [ "$col_cp" -gt 0 ]; then cp_val="$(clean_cell "${C[$col_cp]:-}")"; fi
    if [ -z "$cp_val" ] || [ "$cp_val" = "-" ]; then
        reasons="${reasons}checkpoint列空|"
    fi

    # ② rescue 列存在且非空
    rescue_val=""
    if [ "$col_rescue" -eq 0 ]; then
        reasons="${reasons}rescue列缺失(登记表需加 rescue 列)|"
    else
        rescue_val="$(clean_cell "${C[$col_rescue]:-}")"
        if [ -z "$rescue_val" ] || [ "$rescue_val" = "-" ]; then
            reasons="${reasons}rescue列空|"
        fi
    fi

    # ③ 检查点文件存在（列内路径 或 {seq}-{agent_type}.md 模式）
    cp_found=0
    if [ -n "$cp_val" ] && [ "$cp_val" != "-" ]; then
        case "$cp_val" in
            /*) [ -f "$cp_val" ] && cp_found=1 ;;
            *)
                [ -f "$PLAN_DIR/$cp_val" ] && cp_found=1
                if [ "$cp_found" -eq 0 ]; then
                    [ -f "$PLAN_DIR/subagent-state/$cp_val" ] && cp_found=1
                fi
                ;;
        esac
    fi
    if [ "$cp_found" -eq 0 ]; then
        seq_val="$(clean_cell "${C[$col_seq]:-}")"
        type_val="$(clean_cell "${C[$col_type]:-}")"
        if [ -n "$type_val" ] && [ -n "$seq_val" ]; then
            seq_stripped="$(printf '%s' "$seq_val" | sed 's/^0*//')"
            [ -z "$seq_stripped" ] && seq_stripped="0"
            seq_pad="$(printf '%02d' "$seq_stripped" 2>/dev/null || true)"
            for sv in "$seq_val" "$seq_stripped" "$seq_pad"; do
                [ -z "$sv" ] && continue
                if [ -f "$PLAN_DIR/subagent-state/${sv}-${type_val}.md" ]; then cp_found=1; break; fi
            done
        fi
    fi
    if [ "$cp_found" -eq 0 ]; then
        reasons="${reasons}checkpoint文件缺失|"
    fi

    if [ -n "$reasons" ]; then
        violation_rows=$((violation_rows + 1))
        reasons_h="${reasons//|/, }"
        reasons_h="${reasons_h%, }"
        human_lines="${human_lines}[rescue] Handoff 行 ${line_no}: 状态=${status} ${reasons_h}"$'\n'
        rjson=""
        while IFS= read -r rr; do
            [ -z "$rr" ] && continue
            [ -n "$rjson" ] && rjson="${rjson},"
            rjson="${rjson}\"$(json_escape "$rr")\""
        done <<< "$(printf '%s' "$reasons" | tr '|' '\n')"
        [ -n "$v_json" ] && v_json="${v_json},"
        v_json="${v_json}{\"line\":${line_no},\"row\":\"$(json_escape "$(clean_cell "${C[$col_seq]:-}")")\",\"status\":\"$(json_escape "$status")\",\"checkpoint\":\"$(json_escape "$cp_val")\",\"rescue\":\"$(json_escape "$rescue_val")\",\"reasons\":[${rjson}]}"
    fi
done < "$PLAN_FILE"

# ── 输出 ─────────────────────────────────────────────────────────────────────
verdict="pass"
[ "$violation_rows" -gt 0 ] && verdict="violation"

if [ "$JSON_OUT" -eq 1 ]; then
    printf '{"total_failed":%s,"violations":[%s],"verdict":"%s"}\n' "$total_failed" "$v_json" "$verdict"
else
    printf '%s' "$human_lines"
    if [ "$violation_rows" -eq 0 ]; then
        printf '[rescue] ✓ 挽救链路完好 (failed/timeout 行=%s, 违规=0, 档位=%s)\n' "$total_failed" "$TIER"
    else
        printf '[rescue] 违规 %s 行 (failed/timeout 行=%s, 档位=%s)\n' "$violation_rows" "$total_failed" "$TIER"
    fi
fi

if [ "$violation_rows" -eq 0 ]; then
    exit 0
fi
case "$TIER" in
    enforce)
        [ "$JSON_OUT" -eq 1 ] && printf '[rescue] enforce 档: 违规阻断终验 (task-v065 F-1)\n' >&2
        exit 1
        ;;
    *)
        if [ "$JSON_OUT" -eq 1 ]; then
            printf '[rescue] warn 档: 仅警告不阻断终验（config.json rescue_chain_enforce=enforce 可升级为阻断）\n' >&2
        else
            printf '[rescue] warn 档: 仅警告不阻断终验（config.json rescue_chain_enforce=enforce 可升级为阻断）\n'
        fi
        exit 0
        ;;
esac
