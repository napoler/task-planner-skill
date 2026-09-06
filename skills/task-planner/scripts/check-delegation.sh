#!/usr/bin/env bash
# check-delegation.sh — task-v055 执行期委派门控核心
# [2026-09-07 task-v055] 实施 task-v055 Phase 3「执行期委派门控」(session-owner 对比 + 白名单 + exit2 阻断 + warn 计数)
#
# 双模式:
#   pretool (默认,供 zcode-pretooluse.sh 调用):
#     check-delegation.sh pretool <file_path> [session_id] [new_string_lines]
#       exit 0  = 放行(白名单命中 / 子代理 sid / .allow-direct 有效 / trivial / 无活跃计划)
#       exit 2  = enforce 模式阻断(主进程白名单外 Write/Edit)
#       exit 0 + stdout {"additionalContext":...} = warn 模式注入警告(主进程被通知但不被阻断)
#
#   stats (供终验调用,去口供化委派率统计):
#     check-delegation.sh stats <plan-dir>
#       stdout: 单行 JSON {"phases_total":N,"phases_delegated":N,"delegation_rate":x.x,
#                         "main_direct":[{phase,executor,reason}],
#                         "violations":[...],"verdict":"ok"|"violation"}
#       exit 0/1 视 violations 是否非空
#
# 设计原则(P0 / 用户指令锁定):
#   - fail-open: jq/JSON 解析失败 → exit 0 + stderr 记录(禁止静默,m-4)
#   - B-1: 文案禁止引导模型自助绕过;放行只能来自显式 allow-direct.sh on
#   - B-2 去口供化:stats 不只信 Executor 字段文本,做占位检测 + Handoff 交叉校验
#   - 30 分钟 allow-direct 过期;同一会话二次 bypass 拒绝
#   - bash 纯实现,禁止 python

set -u

# ── 常量 ─────────────────────────────────────────────────────────────────────
ALLOW_TTL_SECONDS=1800          # 30 分钟 allow-direct 有效期
LEDGER_FILE="ledger-delegation.jsonl"

# ── 工具函数 ─────────────────────────────────────────────────────────────────
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [2026-09-07 task-v055] BASH_SOURCE 推导出的 SKILL_ROOT 是 scripts/ 目录,
# config.json 在 skill 根(上一级);写错层级会让 get_enforce_mode 恒走 failopen
CONFIG_JSON="$SKILL_ROOT/../config.json"

# 解析活跃 plan 目录(复用 resolve-plan-dir.sh)
resolve_plan_dir() {
    local cwd="${1:-$PWD}"
    local plan_file=""
    if [ -f "$SKILL_ROOT/resolve-plan-dir.sh" ]; then
        plan_file="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$cwd" 2>/dev/null || true)"
    fi
    if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
        dirname "$plan_file"
    fi
}

# 解析活跃计划存在性(任意 cwd);解析失败空字符串
resolve_plan_dir_any() {
    local cwd="${1:-$PWD}"
    # 尝试输入 cwd
    local d
    d="$(resolve_plan_dir "$cwd")"
    [ -n "$d" ] && { printf '%s' "$d"; return 0; }
    # 兜底:从 CWD 向上找 plans/<slug>/task_plan.md
    local p="$cwd"
    while [ "$p" != "/" ] && [ -n "$p" ]; do
        if [ -d "$p/plans" ]; then
            d="$(resolve_plan_dir "$p")"
            [ -n "$d" ] && { printf '%s' "$d"; return 0; }
        fi
        p="$(dirname "$p")"
    done
    # 最后兜底:home/.zcode/plans
    if [ -d "$HOME/.zcode/plans" ]; then
        d="$(resolve_plan_dir "$HOME/.zcode/plans")"
        [ -n "$d" ] && { printf '%s' "$d"; return 0; }
    fi
    return 1
}

# 读 delegation_enforce 配置(enforce|warn)。
# [2026-09-07 task-v055 m-4] jq 缺失或解析失败 → 输出 "failopen" sentinel;
#   caller 收到后 → exit 0 + stderr 记录(避免 hook 链整体崩坏时把用户锁死)
get_enforce_mode() {
    if ! command -v jq >/dev/null 2>&1; then
        printf 'failopen\n' >&2
        printf 'failopen'
        return 0
    fi
    if [ ! -f "$CONFIG_JSON" ]; then
        printf 'failopen\n' >&2
        printf 'failopen'
        return 0
    fi
    local mode
    mode="$(jq -r '.properties.delegation_enforce.default // "enforce"' "$CONFIG_JSON" 2>/dev/null)" || {
        printf 'failopen\n' >&2
        printf 'failopen'
        return 0
    }
    case "$mode" in enforce|warn) printf '%s' "$mode" ;; *) printf '%s' "enforce" ;; esac
}

# 白名单路径判定:file_path 是否在白名单路径下
# 白名单:*/plans/* (任意祖先含 plans/), .claude/plan-templates/, .zcode/plans/, $SKILL_ROOT
is_whitelisted_path() {
    local fp="$1"
    case "$fp" in
        "") return 1 ;;
    esac
    # 绝对路径化(脚本可能任意 CWD 调用)
    case "$fp" in
        /*) ;;
        *)  fp="$(cd "$(dirname "$fp")" 2>/dev/null && pwd)/$(basename "$fp")" || fp="$PWD/$fp" ;;
    esac
    # 1. 祖先含 plans/(覆盖三件套 basename 收紧问题 m-2)
    local d="$(dirname "$fp")"
    while [ "$d" != "/" ] && [ -n "$d" ]; do
        if [ "$(basename "$d")" = "plans" ]; then
            return 0
        fi
        d="$(dirname "$d")"
    done
    # 2. .claude/plan-templates/ 与 .zcode/plans/ 与 SKILL_ROOT 自身
    case "$fp" in
        */.claude/plan-templates/*) return 0 ;;
        */.zcode/plans/*) return 0 ;;
        "$SKILL_ROOT"/*|"$SKILL_ROOT") return 0 ;;
    esac
    return 1
}

# allow-direct 标记有效性检查 + ledger 记录
# [2026-09-07 task-v055] 文件内容=过期时刻(epoch,写入时 now+1800),
# 有效性 = remain = stamp - now ∈ [0, TTL];原 age=now-stamp 方向反了(恒不放行),已修
check_allow_direct() {
    local plan_dir="$1"
    local sid="$2"
    local allow_file="$plan_dir/.allow-direct"
    [ -f "$allow_file" ] || return 1
    local stamp
    stamp="$(cat "$allow_file" 2>/dev/null | tr -cd '0-9')"
    case "$stamp" in ''|*[!0-9]*) return 1 ;; esac
    local now; now="$(date +%s)"
    local remain=$(( stamp - now ))
    if [ "$remain" -ge 0 ] && [ "$remain" -le "$ALLOW_TTL_SECONDS" ]; then
        # ledger 记录
        local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo 1970-01-01T00:00:00Z)"
        local sid_esc; sid_esc="$(printf '%s' "$sid" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\001-\037' ' ')"
        local file_esc; file_esc="$(printf '%s' "${3:-pretool}" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\001-\037' ' ')"
        printf '{"ts":"%s","event":"bypass","sid":"%s","trigger":"%s","remain_sec":%d}\n' \
            "$ts" "$sid_esc" "$file_esc" "$remain" >> "$plan_dir/$LEDGER_FILE"
        return 0
    fi
    return 1
}

# warn 模式注入 + 计数
emit_warn() {
    local sid="$1"
    local file="$2"
    local count_file="/tmp/task-planner-warn-${sid}.count"
    local n; n="$(cat "$count_file" 2>/dev/null || echo 0)"
    case "$n" in ''|*[!0-9]*) n=0 ;; esac
    n=$(( n + 1 ))
    echo "$n" > "$count_file"
    local msg
    msg="[delegation-warn] ⚠️ 主进程直做尝试拦截($(date +%H:%M:%S),本次会话第 ${n} 次): file=${file}
按 SKILL.md 路由表派子代理执行;若属误拦,确认文件路径是否在 plans/ 白名单;若用户明文请求主进程亲为,执行:
  bash ${SKILL_ROOT}/scripts/allow-direct.sh on --confirm-user-requested
(30 分钟窗口;会被 ledger 记录并在终验展示;同会话仅一次)"
    printf '{"additionalContext": %s}\n' "$(printf '%s' "$msg" | jq -Rs . 2>/dev/null || printf '"warn"')"
}

# ── pretool 模式 ──────────────────────────────────────────────────────────────
mode_pretool() {
    local file_path="${1:-}"
    local sid="${2:-default}"
    local lines_arg="${3:--}"

    # ① 无活跃计划 → 放行(拦截只在计划执行期生效)
    local cwd="${PWD}"
    local plan_dir
    plan_dir="$(resolve_plan_dir_any "$cwd" 2>/dev/null || true)"
    if [ -z "$plan_dir" ]; then
        exit 0
    fi

    # ② session_id 非空且 ≠ .session-owner → 判定为子代理 → 放行
    if [ -n "$sid" ] && [ "$sid" != "default" ]; then
        local owner=""
        owner="$(cat "$plan_dir/.session-owner" 2>/dev/null || true)"
        if [ -n "$owner" ] && [ "$owner" != "$sid" ]; then
            exit 0
        fi
        # owner 为空 = 该 plan 尚未被 UserPromptSubmit 写入(可能子代理单独启动),放行
        if [ -z "$owner" ]; then
            exit 0
        fi
    fi

    # ③ 白名单 → 放行
    if is_whitelisted_path "$file_path"; then
        exit 0
    fi

    # ④ trivial: new_string 行数 ≤3 且 >0 → 放行(仅 Edit 场景;Write 不适用)
    if [ "$lines_arg" != "-" ]; then
        case "$lines_arg" in
            ''|*[!0-9]*) ;;
            *) [ "$lines_arg" -ge 1 ] && [ "$lines_arg" -le 3 ] && exit 0 ;;
        esac
    fi

    # ⑤ .allow-direct 有效 → 放行 + ledger 记录
    if check_allow_direct "$plan_dir" "$sid" "pretool"; then
        exit 0
    fi

    # ⑥ 到此 = 违规
    local mode; mode="$(get_enforce_mode 2>/dev/null)"
    case "$mode" in
        failopen)
            # m-4: jq 不可用 / config 解析失败 → fail-open 放行 + stderr 记录
            printf '[check-delegation] jq 或 config 异常,fail-open 放行 mode=%s file=%s\n' "$mode" "$file_path" >&2
            exit 0
            ;;
        warn)
            emit_warn "$sid" "$file_path"
            exit 0
            ;;
    esac
    # enforce → exit 2
    exit 2
}

# ── stats 模式(去口供化委派率统计)────────────────────────────────────────
mode_stats() {
    local plan_dir="${1:-}"
    if [ -z "$plan_dir" ] || [ ! -d "$plan_dir" ]; then
        printf '{"error":"plan_dir_not_found","path":"%s"}\n' "$plan_dir"
        exit 1
    fi
    local plan_file="$plan_dir/task_plan.md"
    if [ ! -f "$plan_file" ]; then
        printf '{"error":"task_plan_missing","plan_dir":"%s"}\n' "$plan_dir"
        exit 1
    fi

    # 解析 Phases 段:状态机扫描 ### Phase N: ... **Status:** ... **Executor:** ...
    # 不用 gawk /start/,/end/(已知 gawk 5.2 bug)
    local total=0
    local delegated=0
    local main_direct_count=0
    local violations_json="[]"
    local main_direct_json="[]"

    # 读取整个文件(中小文件,直接载入;B-2 容忍 O(n))
    # 用 mktemp + 命名 pipe 方式避免 here-string while 死循环
    local tmp_plan
    tmp_plan="$(mktemp)"
    trap 'rm -f "$tmp_plan" 2>/dev/null' RETURN
    cat "$plan_file" 2>/dev/null > "$tmp_plan"

    # 状态机扫描 Phase 块
    local in_phase=0
    local current_executor=""
    local current_reason=""
    local current_phase_name=""
    local phase_buf=""
    local line
    while IFS= read -r line; do
        # Phase 头
        if [[ "$line" =~ ^###[[:space:]]*Phase[[:space:]]+([^:]+):[[:space:]]*(.*) ]]; then
            # [2026-09-07 task-v055] BASH_REMATCH 必须在 flush 之前立即捕获:
            # flush 块内含 [[ =~ ]] 匹配会重置 BASH_REMATCH,顺序反了会导致 phase_name 为空
            local _r1="${BASH_REMATCH[1]:-}"
            local _r2="${BASH_REMATCH[2]:-}"
            # flush 上一 Phase
            if [ "$in_phase" -eq 1 ]; then
                # 处理
                total=$(( total + 1 ))
                local exec_norm="$current_executor"
                if [[ "$exec_norm" =~ 主进程 ]]; then
                    main_direct_count=$(( main_direct_count + 1 ))
                    # 占位检测
                    local suspicious=0
                    case "$exec_norm" in
                        *"（"*"|*（)"*|*"("*) suspicious=0 ;; # 标准格式
                    esac
                    # 白名单正则——禁止自我声明字样
                    local reason="$current_reason"
                    local needs_git=0
                    if [[ "$reason" =~ (3行|trivial|≤3行|≤ 3行) ]]; then
                        needs_git=1
                    fi
                    local self_declared=0
                    if [[ "$reason" =~ (用户显式|规划|验收|编排|簿记) ]]; then
                        self_declared=1
                    fi
                    # 写 main_direct 项
                    local obj
                    obj="$(printf '{"phase":"%s","executor":"%s","reason":"%s","needs_git_evidence":%s,"self_declared":%s}' \
                        "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                        "$(printf '%s' "$exec_norm" | sed 's/"/\\"/g')" \
                        "$(printf '%s' "$reason" | sed 's/"/\\"/g')" \
                        "$needs_git" \
                        "$self_declared")"
                    if [ "$main_direct_json" = "[]" ]; then
                        main_direct_json="$obj"
                    else
                        main_direct_json="${main_direct_json},${obj}"
                    fi
                    if [ "$self_declared" -eq 1 ]; then
                        local vo
                        vo="$(printf '{"type":"self_declared_reason","phase":"%s","reason":"%s"}' \
                            "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                            "$(printf '%s' "$reason" | sed 's/"/\\"/g')")"
                        if [ "$violations_json" = "[]" ]; then
                            violations_json="$vo"
                        else
                            violations_json="${violations_json},${vo}"
                        fi
                    fi
                else
                    delegated=$(( delegated + 1 ))
                    # Handoff 交叉校验(若 Executor 包含子代理类型,该类型应出现在 Handoff 表)
                    local type_hint="$exec_norm"
                    type_hint="${type_hint#*:}"     # 去 "code-assistant: ..." 的冒号前缀(若有)
                    type_hint="${type_hint%%（*}"
                    type_hint="${type_hint%%(*}"
                    type_hint="$(printf '%s' "$type_hint" | tr -d ' \t')"
                    if [ -n "$type_hint" ] && [ "$type_hint" != "主进程" ]; then
                        # [2026-09-07 task-v055-fix] 复合Executor按+拆分逐个校验
                        # 例:"architect + critic（方案挑刺）" → 按 + 拆成 [architect, critic（方案挑刺）]
                        # 每个 token trim 空白后再去括号/空白,然后逐个 grep Handoff 表;任一缺失才计 unverified
                        # 用 NUL 分隔 + read -d '' 处理 "a+b" 这种无空白的复合 Executor
                        # (tr '+' '\n' 末尾无换行时 read 会把整段当一行,故改 NUL)
                        local handoff_found=0
                        local missing_tokens=""
                        local _tok
                        local _tok_norm
                        local _first=1
                        while IFS= read -r -d '' _tok; do
                            # trim 空白 + 去括号/空白(沿用上面同套清理)
                            _tok_norm="$(printf '%s' "$_tok" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                            _tok_norm="${_tok_norm%%（*}"
                            _tok_norm="${_tok_norm%%(*}"
                            _tok_norm="$(printf '%s' "$_tok_norm" | tr -d ' \t')"
                            if [ -z "$_tok_norm" ]; then
                                continue
                            fi
                            if grep -qE "\|[[:space:]]*${_tok_norm}[[:space:]]*\|" "$plan_file" 2>/dev/null; then
                                # 该 token 在 Handoff 表
                                :
                            else
                                if [ "$_first" -eq 1 ]; then
                                    missing_tokens="$_tok_norm"
                                    _first=0
                                else
                                    missing_tokens="${missing_tokens},${_tok_norm}"
                                fi
                            fi
                        done < <(printf '%s\0' "$type_hint" | tr '+' '\0')
                        if [ -z "$missing_tokens" ]; then
                            handoff_found=1
                        fi
                        if [ "$handoff_found" -eq 0 ]; then
                            delegated=$(( delegated - 1 ))
                            local vo
                            vo="$(printf '{"type":"unverified_delegation","phase":"%s","executor":"%s","reason":"Executor 含未登记子代理类型:%s"}' \
                                "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                                "$(printf '%s' "$exec_norm" | sed 's/"/\\"/g')" \
                                "$missing_tokens")"
                            if [ "$violations_json" = "[]" ]; then
                                violations_json="$vo"
                            else
                                violations_json="${violations_json},${vo}"
                            fi
                        fi
                    fi
                fi
            fi
            # 开始新 Phase
            in_phase=1
            current_executor=""
            current_reason=""
            current_phase_name="${_r1} ${_r2}"
            current_phase_name="${current_phase_name%% }"
            phase_buf=""
            continue
        fi
        if [ "$in_phase" -eq 1 ]; then
            # Phase 块结束:遇到 ## 顶层章节或 ### 非 Phase 开头(防 Plan 末尾丢 Phase)
            if [[ "$line" =~ ^##[[:space:]] ]]; then
                # flush 当前 Phase(### Phase 段已由 Phase 头分支处理;此处处理 ## 顶层章节截断)
                # flush 当前 Phase(Phase 3 后立即 ## 段时,末尾不 flush 会丢 Phase)
                total=$(( total + 1 ))
                if [[ "$current_executor" =~ 主进程 ]]; then
                    main_direct_count=$(( main_direct_count + 1 ))
                    local reason="$current_reason"
                    local needs_git=0
                    [[ "$reason" =~ (3行|trivial|≤3行|≤ 3行) ]] && needs_git=1
                    local self_declared=0
                    [[ "$reason" =~ (用户显式|规划|验收|编排|簿记) ]] && self_declared=1
                    local obj
                    obj="$(printf '{"phase":"%s","executor":"%s","reason":"%s","needs_git_evidence":%s,"self_declared":%s}' \
                        "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                        "$(printf '%s' "$current_executor" | sed 's/"/\\"/g')" \
                        "$(printf '%s' "$reason" | sed 's/"/\\"/g')" \
                        "$needs_git" "$self_declared")"
                    if [ "$main_direct_json" = "[]" ]; then
                        main_direct_json="$obj"
                    else
                        main_direct_json="${main_direct_json},${obj}"
                    fi
                    if [ "$self_declared" -eq 1 ]; then
                        local vo
                        vo="$(printf '{"type":"self_declared_reason","phase":"%s","reason":"%s"}' \
                            "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                            "$(printf '%s' "$reason" | sed 's/"/\\"/g')")"
                        if [ "$violations_json" = "[]" ]; then
                            violations_json="$vo"
                        else
                            violations_json="${violations_json},${vo}"
                        fi
                    fi
                else
                    delegated=$(( delegated + 1 ))
                    local type_hint="$current_executor"
                    type_hint="${type_hint%%（*}"
                    type_hint="${type_hint%%(*}"
                    type_hint="$(printf '%s' "$type_hint" | tr -d ' \t')"
                    if [ -n "$type_hint" ] && [ "$type_hint" != "主进程" ]; then
                        # [2026-09-07 task-v055-fix] 复合Executor按+拆分逐个校验
                        # 用 NUL 分隔 + read -d '' 处理 "a+b" 这种无空白的复合 Executor
                        local handoff_found=0
                        local missing_tokens=""
                        local _tok
                        local _tok_norm
                        local _first=1
                        while IFS= read -r -d '' _tok; do
                            _tok_norm="$(printf '%s' "$_tok" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                            _tok_norm="${_tok_norm%%（*}"
                            _tok_norm="${_tok_norm%%(*}"
                            _tok_norm="$(printf '%s' "$_tok_norm" | tr -d ' \t')"
                            if [ -z "$_tok_norm" ]; then
                                continue
                            fi
                            if grep -qE "\|[[:space:]]*${_tok_norm}[[:space:]]*\|" "$plan_file" 2>/dev/null; then
                                :
                            else
                                if [ "$_first" -eq 1 ]; then
                                    missing_tokens="$_tok_norm"
                                    _first=0
                                else
                                    missing_tokens="${missing_tokens},${_tok_norm}"
                                fi
                            fi
                        done < <(printf '%s\0' "$type_hint" | tr '+' '\0')
                        if [ -z "$missing_tokens" ]; then
                            handoff_found=1
                        fi
                        if [ "$handoff_found" -eq 0 ]; then
                            delegated=$(( delegated - 1 ))
                            local vo
                            vo="$(printf '{"type":"unverified_delegation","phase":"%s","executor":"%s","reason":"Executor 含未登记子代理类型:%s"}' \
                                "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                                "$(printf '%s' "$current_executor" | sed 's/"/\\"/g')" \
                                "$missing_tokens")"
                            if [ "$violations_json" = "[]" ]; then
                                violations_json="$vo"
                            else
                                violations_json="${violations_json},${vo}"
                            fi
                        fi
                    fi
                fi
                in_phase=0
                continue
            fi
            if [[ "$line" =~ \*\*Status:\*\*[[:space:]]*(.+)$ ]]; then
                continue
            fi
            if [[ "$line" =~ \*\*Executor:\*\*[[:space:]]*(.+)$ ]]; then
                current_executor="${BASH_REMATCH[1]:-}"
                # 提取括号内例外理由
                if [[ "$current_executor" =~ （(.+)） ]]; then
                    current_reason="${BASH_REMATCH[1]:-}"
                elif [[ "$current_executor" =~ \((.+)\) ]]; then
                    current_reason="${BASH_REMATCH[1]:-}"
                fi
                continue
            fi
        fi
    done < "$tmp_plan"
    rm -f "$tmp_plan" 2>/dev/null
    trap - RETURN
    # flush 最后一个 Phase
    if [ "$in_phase" -eq 1 ]; then
        total=$(( total + 1 ))
        if [[ "$current_executor" =~ 主进程 ]]; then
            main_direct_count=$(( main_direct_count + 1 ))
            local reason="$current_reason"
            local needs_git=0
            [[ "$reason" =~ (3行|trivial|≤3行|≤ 3行) ]] && needs_git=1
            local self_declared=0
            [[ "$reason" =~ (用户显式|规划|验收|编排|簿记) ]] && self_declared=1
            local obj
            obj="$(printf '{"phase":"%s","executor":"%s","reason":"%s","needs_git_evidence":%s,"self_declared":%s}' \
                "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                "$(printf '%s' "$current_executor" | sed 's/"/\\"/g')" \
                "$(printf '%s' "$reason" | sed 's/"/\\"/g')" \
                "$needs_git" "$self_declared")"
            if [ "$main_direct_json" = "[]" ]; then
                main_direct_json="$obj"
            else
                main_direct_json="${main_direct_json},${obj}"
            fi
            if [ "$self_declared" -eq 1 ]; then
                local vo
                vo="$(printf '{"type":"self_declared_reason","phase":"%s","reason":"%s"}' \
                    "$(printf '%s' "$current_phase_name" | sed 's/"/\\"/g')" \
                    "$(printf '%s' "$reason" | sed 's/"/\\"/g')")"
                if [ "$violations_json" = "[]" ]; then
                    violations_json="$vo"
                else
                    violations_json="${violations_json},${vo}"
                fi
            fi
        else
            delegated=$(( delegated + 1 ))
        fi
    fi

    # 委派率 = delegated / (delegated + 全部 main_direct_count)
    # 全部主进程直做均算入分母(含白名单内例外),与 Rule 25.4 一致
    local denom=$(( delegated + main_direct_count ))
    [ "$denom" -lt 1 ] && denom=1
    local rate
    rate="$(awk -v d="$delegated" -v de="$denom" 'BEGIN{printf "%.3f", d/de}')"

    # verdict
    local verdict="ok"
    [ "$violations_json" != "[]" ] && verdict="violation"

    # violations_json / main_direct_json 包裹成数组
    [ -z "$main_direct_json" ] && main_direct_json="[]"
    [ "$main_direct_json" != "[]" ] && main_direct_json="[$main_direct_json]"
    [ -z "$violations_json" ] && violations_json="[]"
    [ "$violations_json" != "[]" ] && violations_json="[$violations_json]"

    printf '{"phases_total":%d,"phases_delegated":%d,"main_direct_count":%d,"delegation_rate":%s,"main_direct":%s,"violations":%s,"verdict":"%s"}\n' \
        "$total" "$delegated" "$main_direct_count" "$rate" "$main_direct_json" "$violations_json" "$verdict"

    if [ "$verdict" = "violation" ]; then
        exit 1
    fi
    exit 0
}

# ── 入口 ─────────────────────────────────────────────────────────────────────
main() {
    local mode="${1:-}"
    case "$mode" in
        pretool)
            shift
            mode_pretool "$@"
            ;;
        stats)
            shift
            mode_stats "$@"
            ;;
        -h|--help|"")
            cat <<EOF
Usage: $0 <mode> [args]
  pretool <file_path> [session_id] [new_string_lines]
  stats <plan-dir>
EOF
            exit 0
            ;;
        *)
            printf '{"error":"unknown_mode","mode":"%s"}\n' "$mode" >&2
            exit 2
            ;;
    esac
}

main "$@"