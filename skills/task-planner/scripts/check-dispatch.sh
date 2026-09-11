#!/usr/bin/env bash
# check-dispatch.sh — Agent() 派发契约守卫 (Rule 22.4c / 22.8.1, task-v057 Phase 4)
# 校验派发 prompt 是否含: 计划三文件绝对路径(task_plan.md/findings.md/progress.md)
# + 8 字段返回 key 必检标记(status: / acceptance: / checkpoint:) + subagent-state/ 检查点路径。
# 缺项按档位处置: enforce=exit 2 阻断 / warn=exit 0 + 落盘告警 / off=跳过。
#
# Usage:
#   check-dispatch.sh pretool <prompt-file> [sid]     # hook 入口: exit 0 放行 / exit 2 enforce 阻断([dispatch-block]→stderr)
#   check-dispatch.sh check <prompt-file> <plan-dir>  # 纯检查: stdout 每行一个缺项名; exit 0 无缺项 / 1 有缺项(与档位无关)
#
# 环境覆盖: TASK_PLANNER_DISPATCH_ENFORCE=enforce|warn|off (档位;未设则 jq 读 config.json)
#           TASK_PLANNER_PLAN_DIR=<dir> (计划目录;未设则 resolve-plan-dir.sh "$PWD" 输出取 dirname)
#
# fail-open (exit 0 + stderr 记录): 无活跃计划 / 计划目录不存在 / prompt 文件不可读 / jq 缺失
# 退出码: 0=放行|无缺项|fail-open; 1=check 有缺项; 2=enforce 阻断
#
# [2026-09-10 task-planrequired-race] 修改说明(仅 cmd_pretool 的计划目录解析与违规处置语义;
# 其余函数/subcommand 字节不变):
#   原行为 = pd 仅按「env TASK_PLANNER_PLAN_DIR → resolve-plan-dir.sh 链」解析,缺项一律 exit 2;
#   全局指针 .active_plan 被并发会话/cron 频繁翻转指向他会话计划目录时,任何合规 prompt
#   (含本会话计划路径) 都被误判"缺项"而 exit 2 阻断派发(当日实锤 4 次,见 findings.md B5/B5a)。
#   现改三级解析: ① TASK_PLANNER_PLAN_DIR env 显式 → enforce(显式指定维持强校验);
#   ② prompt 自声明(三文件路径同目录三件齐 且 task_plan.md 真实存在,兼容 /home 与 /mnt/data
#   双视图拼写) → enforce; ③ resolve 链(sid 指针/global/mtime)兜底未命中 → 降级 warn:
#   打印一行 [dispatch-guard] ⚠ 到 stderr 后 exit 0(fail-open,根治 B5 跨会话误拦)。
#   TASK_PLANNER_DISPATCH_ENFORCE=off 全程放行 与 =warn 既有分支语义保持不变;成功路径(无缺项)保持静默 exit 0。
#
# [2026-09-10 task-path-identity] 身份判定改造记录(仅 scan_missing 三文件分支;档位分档不变):
#   现象 = 混拼写 prompt(task_plan 行 /home、findings 行 /mnt/data、progress 行 /home)在 enforce 档
#   被 grep -qF 字面匹配误判缺项 exit 2(bind mount 双视图: 同仓同文件两种拼写);
#   根因 = 旧 alt 拼写 $pd_real 依赖 pwd -P/realpath,而 realpath 不折叠 bind mount,alt 形同虚设;
#   修法 = 双轨文件身份判定: 两侧文件都存在 → stat -c %d:%i(device:inode)比对,拼写免疫;
#   任一不存在(拟创建计划)→ realpath -m 两侧规范串相等即命中;alt 拼写与 pd_real 变量一并废除。
set -u

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v057] BASH_SOURCE 推导出的 SKILL_ROOT 是 scripts/ 目录;config.json 在 skill 根(上一级)
CONFIG_JSON="$SKILL_ROOT/../config.json"

# 缺项扫描: $1=prompt 文件 $2=计划目录 → stdout 每行一个缺项名(固定顺序 P1..P3,R1..R3,C1)
# [2026-09-10 task-path-identity] 原行为=grep -qF 字面匹配+无效 alt 拼写（realpath 不折叠 bind mount），混拼写 prompt 被误判缺项；改为文件身份判定：存在文件→stat -c %d:%i inode 比对（bind mount 免疫），不存在→realpath -m 规范串比对；废除 alt 拼写
scan_missing() {
    local f="$1" pd="$2" item c hit id_cand id_ref dc dr
    pd="${pd%/}"
    # [2026-09-10 task-path-identity] 文件身份判定: 预抽取 prompt 中所有以三文件名结尾的候选路径
    local cands
    cands="$(grep -oE '[^[:space:][:cntrl:]]*/(task_plan|findings|progress)\.md' "$f" 2>/dev/null | sort -u || true)"
    for item in "$pd/task_plan.md" "$pd/findings.md" "$pd/progress.md" "status:" "acceptance:" "checkpoint:" "subagent-state/"; do
        case "$item" in
        */task_plan.md|*/findings.md|*/progress.md)
            hit=0
            for c in $cands; do
                case "$c" in
                *"/${item##*/}") ;;      # 文件名须与 item 一致(task_plan.md 等), 避免跨名误判
                *) continue ;;
                esac
                if [ -e "$c" ] && [ -e "$item" ]; then
                    # a. 两侧都存在 → device:inode 相同即同一文件(bind mount 双拼写免疫)
                    id_cand="$(stat -c %d:%i -- "$c" 2>/dev/null)" || continue
                    id_ref="$(stat -c %d:%i -- "$item" 2>/dev/null)" || continue
                else
                    # b. 任一不存在(拟创建计划) → 目录身份优先: 两侧目录都在则 dirname 的
                    #    device:inode 比对(拼写免疫——全路径 realpath -m 不折叠 bind mount,
                    #    Phase 5 VC-3 实测跨视图拟创建仍误拦); 目录也不在才退 realpath -m 全路径
                    dc="$(dirname -- "$c" 2>/dev/null)" || continue
                    dr="$(dirname -- "$item" 2>/dev/null)" || continue
                    if [ -d "$dc" ] && [ -d "$dr" ]; then
                        id_cand="$(stat -c %d:%i -- "$dc" 2>/dev/null)" || continue
                        id_ref="$(stat -c %d:%i -- "$dr" 2>/dev/null)" || continue
                    else
                        id_cand="$(realpath -m -- "$c" 2>/dev/null)" || continue
                        id_ref="$(realpath -m -- "$item" 2>/dev/null)" || continue
                    fi
                fi
                [ -n "$id_cand" ] && [ "$id_cand" = "$id_ref" ] && { hit=1; break; }
            done
            if [ "$hit" -ne 1 ]; then
                case "${item##*/}" in
                task_plan.md) printf 'task_plan.md\n' ;;
                findings.md) printf 'findings.md\n' ;;
                progress.md) printf 'progress.md\n' ;;
                esac
            fi
            ;;
        *)
            grep -qF -- "$item" "$f" 2>/dev/null || printf '%s\n' "$item" ;;
        esac
    done
}

# 档位解析: 环境变量优先;未设 → jq 读 .properties.dispatch_contract_enforce.default // "enforce"
# (config 缺失/jq 解析失败 → enforce;jq 二进制缺失 → "nojq" sentinel,调用方 fail-open)
get_mode() {
    local m="${TASK_PLANNER_DISPATCH_ENFORCE:-}"
    if [ -n "$m" ]; then
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
        return 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf 'nojq'; return 0
    fi
    if [ ! -f "$CONFIG_JSON" ]; then
        printf 'enforce'; return 0
    fi
    m="$(jq -r '.properties.dispatch_contract_enforce.default // "enforce"' "$CONFIG_JSON" 2>/dev/null)" || m="enforce"
    case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
}

# 计划目录解析: 环境变量 TASK_PLANNER_PLAN_DIR 优先,否则 resolve-plan-dir.sh 输出(= task_plan.md 路径)取 dirname
# [2026-09-10 active-plan-race] resolver 二参带会话 sid(zcode-pretooluse.sh Agent 分支 export TASK_PLANNER_SID
# 传入;未设则回 env CLAUDE_CODE_SESSION_ID/resolver 内置 default) → .active_plan_side/<sid>.active_plan
# 会话私有指针优先,并行会话的派发守卫各查各的计划,不再被互顶的全局 legacy 指针误拦
resolve_plan_dir() {
    local pd="${TASK_PLANNER_PLAN_DIR:-}" pfile
    if [ -n "$pd" ]; then
        printf '%s' "$pd"; return 0
    fi
    pfile="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$PWD" "${TASK_PLANNER_SID:-}" 2>/dev/null || true)"
    if [ -n "$pfile" ] && [ -f "$pfile" ]; then
        printf '%s' "$(dirname "$pfile")"
    fi
}

join_missing() { printf '%s\n' "$1" | tr '\n' ',' | sed 's/,$//'; }

cmd_pretool() {
    local pf="${1:-}" sid="${2:-unknown}"
    if [ -z "$pf" ]; then
        echo "[dispatch-guard] pretool: 缺 <prompt-file> 参数, fail-open" >&2; exit 0
    fi
    if [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] prompt 文件不可读($pf), fail-open" >&2; exit 0
    fi
    local mode pd missing names
    mode="$(get_mode)"
    if [ "$mode" = "nojq" ]; then
        echo "[dispatch-guard] jq 缺失, 派发契约守卫 fail-open" >&2; exit 0
    fi
    [ "$mode" = "off" ] && exit 0
    # [2026-09-10 task-planrequired-race] 三级计划目录解析,决定 pd 与处置档位(见头部修改说明):
    # ① TASK_PLANNER_PLAN_DIR env 显式 → enforce; ② prompt 自声明(声明含 task_plan.md 路径的目录
    # 且该目录 task_plan.md 真实存在,取首个命中拼写,兼容 /home 与 /mnt/data 双视图) → enforce;
    # ③ 均未锚定 → resolve 链(带 sid)兜底,一律降级 warn 放行(根治 B5 跨会话误拦)
    local pd_mode decl_taskdirs d
    # 自声明目录组 = prompt 中所有 task_plan.md 声明路径的 dirname(去重)
    decl_taskdirs="$(grep -oE '[^ [:cntrl:]]*/task_plan\.md' "$pf" 2>/dev/null | xargs -n1 dirname 2>/dev/null | sort -u || true)"
    if [ -n "${TASK_PLANNER_PLAN_DIR:-}" ]; then
        pd="${TASK_PLANNER_PLAN_DIR}"; pd_mode="enforce"
    else
        pd=""
        # 自声明锚定: 取 prompt 中 task_plan.md 声明路径的目录组(去重); 该目录下
        # task_plan.md 真实存在([ -f ])即锚定——双视图拼写下取首个可命中者;
        # 三件齐(组内同时含三文件名)是本条件最强形态, 缺 findings/progress 声明
        # 仍按缺项在 enforce 档被 scan 捕获(不得因此逃逸到 warn 档)
        for d in $decl_taskdirs; do
            if [ -f "$d/task_plan.md" ]; then
                pd="$d"; break
            fi
        done
        if [ -n "$pd" ]; then
            pd_mode="enforce"
        else
            pd="$(resolve_plan_dir)"
            pd_mode="warn"
        fi
    fi
    if [ "$pd_mode" = "warn" ]; then
        # [task-planrequired-race] B5 根治: env 显式与 prompt 自声明均未锚定本会话计划目录,
        # side/resolve 只是兜底(全局指针可能被并发会话翻转指向他会话) → 降级 warn 放行,不再 exit 2 误拦
        if [ -n "$pd" ] && [ -d "$pd" ]; then
            missing="$(scan_missing "$pf" "$pd")"
            # [task-v061-serial-dispatch] 契约校验通过(兜底命中且无缺项), 即将放行前执行串行槽检查
            [ -n "$missing" ] || { serial_slot_check "$pd" "$mode" "$sid"; exit 0; }
            names="$(join_missing "$missing")"
        else
            names="unknown"
        fi
        echo "[dispatch-guard] ⚠ 计划目录解析未命中本会话(side/自声明)，降级 warn 放行(pd=${pd:-空}) 缺项=${names}" >&2
        exit 0
    fi
    # enforce 档(env 显式 / prompt 自声明锚定成功): 沿用原有缺项扫描与分档处置
    [ -n "$pd" ] && [ -d "$pd" ] || exit 0   # 目录不存在 → fail-open(原语义)
    missing="$(scan_missing "$pf" "$pd")"
    # [task-v061-serial-dispatch] 契约校验通过(无缺项), 即将放行前执行串行槽检查; 缺项 exit 2 路径不写锁不检查
    [ -n "$missing" ] || { serial_slot_check "$pd" "$mode" "$sid"; exit 0; }
    names="$(join_missing "$missing")"
    if [ "$mode" = "warn" ]; then
        echo "[dispatch-warn] ⚠ 派发契约缺项: $names"
        wf="${TMPDIR:-/tmp}/task-planner-dispatch-warn-${sid}"
        [ -f "$wf" ] && [ -n "$(find "$wf" -mmin +1440 2>/dev/null)" ] && rm -f "$wf"   # [p7fix] 24h TTL: 过期计数先清
        printf '%s [dispatch-warn] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$names" \
            >> "$wf" 2>/dev/null || true
        exit 0
    fi
    echo "[dispatch-block] 🚫 派发契约缺项(Rule 22.4a/b/22.8.1): $names — prompt 须含计划三文件绝对路径 + 8 字段返回模板 + subagent-state 检查点路径(templates/subagent_dispatch.md §2/§7/§8)" >&2
    exit 2
}

cmd_check() {
    local pf="${1:-}" pd="${2:-}"
    if [ -z "$pf" ] || [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] check: prompt 文件不可读, fail-open" >&2; exit 0
    fi
    if [ -z "$pd" ] || [ ! -d "$pd" ]; then
        echo "[dispatch-guard] check: plan-dir 为空/不存在, fail-open" >&2; exit 0
    fi
    local missing
    missing="$(scan_missing "$pf" "$pd")"
    if [ -n "$missing" ]; then
        printf '%s\n' "$missing"
        exit 1
    fi
    exit 0
}

# [task-v061-serial-dispatch] 串行槽守卫(Rule 21.4): inflight 锁 <plan-dir>/subagent-state/.dispatch-inflight
# (unix 时间戳)。age<120s → 判并行派发尝试, 按 get_mode 分档处置; 无锁/陈旧(≥120s,崩溃残留) → 写新锁放行;
# 锁不可写/plan-dir 解析失败 → fail-open 静默放行(与既有 fail-open 原则一致)。
# 边界(如实): run_in_background 的 Agent 调用 PostToolUse 立即返回即清锁, 后台并发不由本守卫捕获,
# 由 Rule 21.4 文本条款(后台派发视为持续占用串行槽)覆盖。
# 边界(多会话): 全局指针被翻转向他任务且他会话 Agent 返回时,可能误删本任务锁(120s TTL 自愈,仅短暂旁路串行约束)
serial_slot_check() {
    local pd="${1:-}" mode="${2:-}" sid="${3:-unknown}" lf now ts age
    case "$mode" in enforce|warn) ;; *) return 0 ;; esac        # off/nojq → 跳过
    [ -n "$pd" ] && [ -d "$pd" ] || return 0                     # plan-dir 未解析 → fail-open
    lf="$pd/subagent-state/.dispatch-inflight"
    mkdir -p -- "${lf%/*}" 2>/dev/null || return 0               # mkdir 失败 → fail-open
    now="$(date +%s)" || return 0
    if [ -f "$lf" ]; then
        ts="$(head -n1 -- "$lf" 2>/dev/null)"
        case "$ts" in ''|*[!0-9]*) ts="" ;; esac
        if [ -n "$ts" ]; then
            age=$(( now - ts ))
            [ "$age" -lt 0 ] && age=0
            if [ "$age" -lt 120 ]; then                           # 槽占用
                if [ "$mode" = "warn" ]; then
                    echo "[dispatch-warn] ⚠ Rule 21.4 串行派发铁律: 串行槽被占用(锁 age=${age}s<120s), 本派发按 warn 档放行 — 应等上一个子代理验收通过" >&2
                    return 0
                fi
                echo "[dispatch-block] 🚫 Rule 21.4 串行派发铁律: 串行槽被占用(锁 age=${age}s<120s), 禁止并行派发 — 须等上一子代理三证据验收通过(清锁)后再派下一个" >&2
                exit 2
            fi
        fi
    fi
    { printf '%s' "$now" > "$lf"; } 2>/dev/null || return 0     # [2026-09-12 task-v061 p2fix] 槽空闲 → 写新锁放行; 重定向包进父级 { } 2>/dev/null: 重定向建立失败(如 Permission denied)由父 shell 报出, 原写法仅吞 printf 自身 stderr 而泄漏重定向错误, 破坏 fail-open 静默
    return 0
}

case "${1:-}" in
    pretool) cmd_pretool "${2:-}" "${3:-}" ;;
    check)   cmd_check "${2:-}" "${3:-}" ;;
    *) echo "[dispatch-guard] usage: pretool <prompt-file> [sid] | check <prompt-file> <plan-dir>" >&2; exit 0 ;;
esac
