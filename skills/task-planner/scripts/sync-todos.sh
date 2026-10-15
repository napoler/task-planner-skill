#!/usr/bin/env bash
# sync-todos.sh — Phase-to-ClaudeCodeTodo sync report generator
#
# Usage:
#   sync-todos.sh                        # human-readable report
#   sync-todos.sh --json                 # machine-parseable JSON report
#   sync-todos.sh /path/to/plans/dir      # sync specific plans dir
#
# NOTE: Claude Code Todo API (TaskWrite/TaskUpdate) is only callable
#       by the agent via tool calls, NOT from bash scripts.
#       This script PARSES task_plan.md and EMITS what to sync.
#       The agent reads output and calls TaskWrite/TaskUpdate.

set -euo pipefail

# [2026-09-27 task-v091 S17 C-1c] scope 提取统一库(语义权威源+调用方清单见 lib/plan-parse.sh);
# 以脚本自身绝对路径 source(范式同 check-conflicts.sh S16 接入)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/plan-parse.sh
. "$SCRIPT_DIR/lib/plan-parse.sh"

PLANS_DIR=""
JSON_OUTPUT=false
INDEX_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_OUTPUT=true ;;
        --index) INDEX_MODE=true ;;
        -h|--help)
            echo "Usage: sync-todos.sh [--json|--index] [/path/to/plans/dir]"
            echo "  (default)  emit Phase→Todo sync report (human, or machine via --json)"
            echo "  --index    write plans/INDEX.md cross-task registry + print summary"
            echo "             (the resume entry point: read INDEX.md to see what needs processing)"
            exit 0
            ;;
        *)
            PLANS_DIR="$1"
            ;;
    esac
    shift
done
# task-v065/V-5 [2026-09-13] 未显式指定时, 从 CWD 向上逐级查找名为 plans 的祖先目录
# (最多 6 级); 找不到回落 $(pwd)/plans 并 stderr 提示(口径参考 resolve-plan-dir.sh / plan-created.cjs)
resolve_plans_dir() {
    local d="$(pwd)"
    local i
    for i in 0 1 2 3 4 5; do
        if [[ -d "$d/plans" ]]; then
            printf '%s' "$d/plans"
            return 0
        fi
        [[ "$i" -eq 5 ]] && break
        [[ -L "$d" ]] && break
        d="$(dirname "$d")"
    done
    echo "[sync-todos] WARN: 未找到 plans 祖先目录,请显式传 PLANS_DIR 或在项目根执行" >&2
    printf '%s' "$(pwd)/plans"
}
PLANS_DIR="${PLANS_DIR:-$(resolve_plans_dir)}"

# ─── Phase parser ───────────────────────────────────────────────────────────
# Parses task_plan.md for Phase blocks.
# Output records (pipe-delimited, one line per emitted record):
#   TASK|TASK_ID|PHASE_NUM|STATUS|SUBJECT  非 pending 的 phase(STATUS 已归一)
#   S|RAW_STATUS                            锚定 Status 行的剥前缀原始值(与 TASK 记录
#                                           同序, 供调用方经共享 parse_status 二次校验)
# 2026-10-15 task-v176/D1 锚定口径: 只认行首列表锚 '- **Status:**'/'* **Status:**'
# (关键词大小写不限, 游离 Status 行=正文引用/表格单元格, 不参与捕获)——与 write_index
# 的计数锚完全一致; 归一口径也同一套(剥 ** 与括号注记→全词判定, 注记含 complete 不翻
# complete, 全词未中回落前缀, 仍不中→pending; 双入口不口径分裂, 见 parse_status 注释)。
parse_task_plan() {
    local task_plan="$1"

    # Extract task_id from path: plans/task-YYYYMMDD-HHMMSS/task_plan.md
    local task_id
    task_id=$(dirname "$task_plan" | xargs basename)

    # State machine: capture phase info on header, capture status on line-anchored
    # list Status line ('- ' / '* ' 列表符, 原仅 '- ' 形态——2026-10-15 task-v176/D1
    # 扩为 '- /* 双形态, 与 write_index 同一锚)。
    awk -v tid="$task_id" '
    /^### Phase [0-9]+:/ {
        if (match($0, /^### Phase ([0-9]+):/, arr)) {
            phase_num = arr[1]
        }
        # Extract phase title (everything after "Phase N: ")
        phase_title = $0
        sub(/^### Phase [0-9]+: */, "", phase_title)
    }
    /^[-*] +\*\*[Ss]tatus:\*\*/ && phase_num {
        st = $0
        sub(/^[-*] +\*\*[Ss]tatus:\*\*/, "", st)
        # 2026-10-15 task-v176/D1: 行首列表锚(只认 "- " / "* " 列表符形态, 与
        # write_index 计数块同一锚; 游离 Status 行不捕获)。判定梯与 bash 共享
        # parse_status() 及 write_index 逐字同步(三处一改全改):
        # ① 剥 ** 与 (）/() 括号注记 → ② 全词判定(注记含 complete 字样不得翻
        # complete, D1 fixture 实证) → ③ 全词未中回落前缀匹配(task-v065/V-4 旧
        # 口径, 未知词不静默归 pending) → 仍不中 → pending。
        v = st
        gsub(/\*\*/, "", v)
        sub(/^[[:space:]]+/, "", v)
        # ② 剥括号注记: 首个(全角（/半角(至行尾整段剥除
        #    (与 parse_status 的 v%%（* / v%%(* 同语义;
        #     awk 单遍正则: 首个任意括号命中即截断)
        p = match(v, /（|\(/)
        if (p > 0) v = substr(v, 1, p - 1)
        sub(/[[:space:]]+$/, "", v)
        # ③ 全词判定 + ④ 前缀回落(与 write_index 计数块/parse_status 逐字同梯,
        # 三处一改全改; 注记含 complete 字样不得翻 complete——D1 失真根因)
        if (v == "complete") st = "complete"
        else if (v == "in_progress") st = "in_progress"
        else if (v == "pending") st = "pending"
        else if (v ~ /^in_progress/) st = "in_progress"
        else if (v ~ /^complete/) st = "complete"
        else st = "pending"

        # Skip pending (no Todo needed for phases not started)
        if (st == "pending") {
            phase_num = 0
            next
        }

        # S 标记行: 携带本 Status 锚定行判定后的归一值, 由调用方 forward_sync 送共享
        # parse_status() 二次归一(幂等校验通道——两入口收敛同一语义函数, task-v176/D1)
        print "S|" st

        # Build subject (max 60 chars for Claude Code limit)
        # task-v065/V-4 [2026-09-13] subject 补 phase title(原为死变量): 截断 40 字符加 …
        # (与 todo-sync.md 契约 subject 格式 "{task-id}/Phase N: title" 一致)
        t = phase_title
        if (length(t) > 40) t = substr(t, 1, 39) "…"
        subject = tid "/Phase " phase_num ": " t
        if (length(subject) > 60) {
            subject = substr(subject, 1, 57) "..."
        }

        # Output: TASK|TASK_ID|PHASE_NUM|STATUS|SUBJECT
        printf "TASK|%s|%s|%s|%s\n", tid, phase_num, st, subject
        phase_num = 0
    }
    ' "$task_plan"
}

# task-v065/V-6 [2026-09-13] 删除此处与下方 extract_plan_meta 的字节级重复定义(diff 逐字相同), 仅保留下方一份
forward_sync() {
    local plans_dir="$1"

    if [[ ! -d "$plans_dir" ]]; then
        $JSON_OUTPUT && echo '{"error":"no_plans_dir","path":"'"$plans_dir"'"}' || echo "[sync-todos] No plans directory: $plans_dir"
        return 1
    fi

    local count=0
    local json_entries=""

    # Find all task_plan.md files under plans/
    # task-v170/S5 [2026-10-11] 排除 archive/ 子树: 归档后 plans/archive/<id>/task_plan.md 深度≥3,
    # 原递归 find 无深度限制会把已归档任务扫入 sync 报告(findings §6 记录 L152 形态)。
    # Why=归档目录仅为历史记录, 不得再进入活跃同步面; 与 write_index(maxdepth 2, 天然不命中
    # archive 下 task_plan.md)的口径对齐——INDEX 只列根目录在途任务(见 findings Technical Decisions)。
    # -not -path 对 find 起始路径本身也做匹配, "*/archive/*" 不含起始路径(其自身非 archive 子项),
    # 根目录在途任务不受影响; 不破坏 L201 write_index 的 maxdepth 2 行为(此处仅动 forward_sync)。
    while IFS= read -r task_plan; do
        [[ -z "$task_plan" ]] && continue

        # 2026-10-15 task-v176/D1: 记录现为带行首标签的 pipe 输出——
        #   TASK|<tid>|<pnum>|<STATUS>|<subject>  非 pending 的 phase(主记录)
        #   S|<raw>                               STATUS 原始值标记(与所属 TASK 记录同序,
        #                                           经共享 parse_status 二次归一校验)
        # 主记录 STATUS 由 awk 按与 write_index 同一套判定梯产出, 再经 bash 共享
        # parse_status 归一兜底——两入口同一解析语义, 消除口径分裂(findings D1)。
        while IFS='|' read -r kind f2 f3 status subject; do
            [[ -z "$kind" ]] && continue
            case "$kind" in
                TASK)
                    tid="$f2"; pnum="$f3"
                    status="$(parse_status "$status")"   # 共享归一锚点(与 --index 同一判定梯)
                    if $JSON_OUTPUT; then
                        [[ -n "$json_entries" ]] && json_entries="${json_entries},"
                        json_entries="${json_entries}{\"task_id\":\"$tid\",\"phase\":$pnum,\"status\":\"$status\",\"subject\":\"$subject\"}"
                    else
                        echo "[sync-todos] $tid | Phase $pnum | $status | $subject"
                    fi
                    ((count++)) || true
                    ;;
                S)
                    # S|<normalized>: parse_status 归一(统一语义锚; 与所属 TASK 记录
                    # STATUS 同一梯判定 → 幂等, 结果不改变输出形态, 纯校验通道,
                    # 消费方契约不变——task-v176/D1 两入口收敛同一判定函数)。
                    parse_status "$f2" >/dev/null
                    ;;
            esac
        done < <(parse_task_plan "$task_plan")

    done < <(find "$plans_dir" -name "task_plan.md" -type f -not -path "*/archive/*" 2>/dev/null | sort)

    if $JSON_OUTPUT; then
        echo "[$json_entries]"
    else
        echo "[sync-todos] Total: $count phases to sync"
    fi
}

# task-v176/D1 [2026-10-15] 共享状态解析(唯一判定实现): forward_sync 的 TASK 记录 STATUS
# 经本函数归一; write_index 内联 awk 按本函数判定梯逐字镜像(三处一改全改, 语义以本注释为准)。
# ① 锚定: 只认行首列表锚 '- **Status:**' / '* **Status:**'(关键词大小写不限),
#    游离 Status 行(正文引用/表格单元格)不参与 Phase 计数
# ② 剥除: 去 ** 加粗残留 + 行尾 (）/() 括号注记
# ③ 全词判定: 剥除后剩余值须 == complete|in_progress|pending(注记含 complete 字样
#    不得翻 complete——D1 fixture 实证: 'in_progress（前一轮 complete 判定已撤回）'
#    原 contains 匹配被 write_index 误计 complete, 进行中→已完成失真)
# ④ 前缀回落: 全词未中才按 ^in_progress/^complete 前缀归一(保留 task-v065/V-4 旧
#    口径, 未知词如 'done' 不静默归 pending); 仍不中 → pending。
# 输入=剥列表符与关键词前缀后的原始值; 输出=complete|in_progress|pending
parse_status() {
    local v="${1-}"
    # ② 剥 Markdown 加粗残留(全部 ** 出现, 与 awk 侧 gsub(/\*\*/) 同语义)
    v="${v//\*\*/}"
    # ② 剥括号注记: 全角（与半角(各自"首个出现至行尾"整段剥除, 顺序执行
    #    (v 中无对应括号时 %% 模式不命中→原样保留, 天然幂等)
    v="${v%%（*}"
    v="${v%%(*}"
    # ② 剥首尾空白
    v="${v#"${v%%[![:space:]]*}"}"
    # 行尾: 先取"首个非空白到行尾"再剥(若行尾无空白, ## 取回原值, % 剥自身→原样, 幂等)
    v="${v%"${v##*[![:space:]]}"}"
    # ③ 全词判定(注记含 complete 字样不得翻 complete——D1 失真根因)
    if [[ "$v" == complete || "$v" == in_progress || "$v" == pending ]]; then
        printf '%s' "$v"
    elif [[ "$v" == in_progress* ]]; then
        # ④ 前缀回落(保留 task-v065/V-4 旧口径, 未知词不静默归 pending)
        printf 'in_progress'
    elif [[ "$v" == complete* ]]; then
        printf 'complete'
    else
        printf 'pending'
    fi
}

# ─── Write plans/INDEX.md (persistent cross-task registry) ──────────────────
# Answers "which tasks need processing after interruption?" by rolling up every
# task-{id}/ state into ONE file at the plans/ parent level. Read INDEX.md first on resume.
#
# [2026-09-27 task-v091 C-3] 重构为单 awk 全量重算: 原实现(rollup_task+extract_plan_meta)
# 每计划 fork stat/cut/dirname/xargs basename/awk×3/head/tr/sed ≈11 进程 ×37 计划;
# 现合并为 find -printf 携 mtime 出一次清单 → sort -k1,1(与旧 find|sort 字典序逐字一致,
# 37 计划对拍) → 单 awk getline 流式解析全部计划, 直接产出 R/T/D/S 四类成品行, bash 仅
# 回写 INDEX.md 骨架。输出与重构前逐字节一致(37 计划对拍, 见 selftest-sync-index.sh)。
# v3 口径: 「按 mtime 仅重写变化行」增量选项已在提案终审 #4 删除——恒全量重算, mv 归档
# 后目录从 find 清单消失即行同步消失(critical-rules 29.6 防 INDEX 统计回归依赖此特性;
# 现行实现本无 mtime 比较分支, 此处无删除物, 行为=保持全量重算)。
# 语义锚义务(任一处语义变更必须同步另一处, 改本块前先跑 selftest-sync-index.sh):
#   - scope 提取块 = lib/plan-parse.sh plan_parse_scope 的内联语义副本(范式同
#     zcode-pretooluse.sh Rule23 内联锚); head -10 上限+逗号 join 保留原调用侧口径
#   - goal/Phase/状态计数块 = 原 rollup_task awk 规则逐字迁移(含括号注记整词归一
#     与 goal 50 字符截断)
#   - session_id 缺省补 none / worktree_path 无缺省 = 原 extract_plan_meta 口径
write_index() {
    local plans_dir="$1"
    if [[ ! -d "$plans_dir" ]]; then
        echo "[index] No plans directory: $plans_dir" >&2
        return 1
    fi

    local -a rows_arr=() todo_arr=() done_arr=()
    local ttodo=0 tdone=0 tinprog=0
    local tag rest

    # 行标签: R=汇总表行 T=待处理行(in_progress+pending) D=已完成行 S=三类计数
    # (tab 分隔, 防与行内容中的表格 | 冲突)
    while IFS=$'\t' read -r tag rest; do
        [[ -z "$tag" ]] && continue
        case "$tag" in
            R) rows_arr+=("$rest") ;;
            T) todo_arr+=("$rest") ;;
            D) done_arr+=("$rest") ;;
            S) IFS=$'\t' read -r tinprog ttodo tdone <<< "$rest" ;;
        esac
    done < <(
        find "$plans_dir" -maxdepth 2 -name "task_plan.md" -type f \
             -printf '%p\t%TY-%Tm-%Td\n' 2>/dev/null \
        | sort -t$'\t' -k1,1 \
        | awk '
            # 每条 stdin 记录 = <task_plan.md 路径>\t<mtime YYYY-MM-DD>;
            # FS 显式 tab: 路径含空格时 $1 仍为完整路径(对齐旧实现 while read 整行语义)
            BEGIN { FS = "\t" }
            {
                path = $1; mt = $2
                # —— 每文件状态复位(= 原两函数每计划独立进程的复位语义) ——
                goal = ""; ingoal = 0
                total = comp = inp = pend = 0
                sid = ""; sid_seen = 0; wt = ""; wt_seen = 0
                scopes = ""; nscope = 0; inscope = 0
                nseg = split(path, seg, "/")            # task_id = basename(dirname(path))
                tid = seg[nseg - 1]

                r = (getline line < path)
                if (r < 0) next          # 读失败: 原实现 rollup 输出空被 [[ -z row ]] 跳过
                while (r > 0) {
                    # —— goal: 「## Goal」起, 下一标题止, 首个剥注释/前导空白后非空行 ——
                    if (line ~ /^## Goal[[:space:]]*$/) { ingoal = 1 }
                    else if (ingoal && line ~ /^#/) { ingoal = 0 }
                    else if (ingoal) {
                        t = line
                        sub(/<!--.*-->/, "", t)
                        sub(/^[[:space:]]*/, "", t)
                        if (t != "" && goal == "") goal = t
                    }
                    if (line ~ /^### Phase [0-9]+:/) total++
                    # 2026-10-15 task-v176/D1: 锚定+全词判定, 判定梯与 bash 共享
                    # parse_status()(上方, 唯一判定实现)逐字镜像——三处一改全改:
                    # ① 行首列表锚 "- **Status:**"/"* **Status:**"(游离 Status 行不计),
                    # ② 剥 ** 加粗残留 + 行首/行尾 (）/() 注记 → ③ 全词判定(注记含
                    # complete 字样不得翻 complete, D1 fixture 实证) → ④ 前缀回落
                    # (保留 task-v065/V-4 旧口径, 未知词→pending)。
                    # 原 "s ~ /complete/" 含注记 contains 匹配+无行首锚, 是失真根因。
                    if (line ~ /^[-*] +\*\*[Ss]tatus:\*\*/) {
                        s = line
                        sub(/^[-*] +\*\*[Ss]tatus:\*\*/, "", s)   # 剥列表符与关键词前缀
                        gsub(/\*\*/, "", s)                          # ② 剥加粗残留
                        sub(/^[[:space:]]+/, "", s)                 # ② 剥行首空白
                        # ② 剥括号注记: 首个(全角（/半角(至行尾整段剥除
                        #    (与 parse_status 的 v%%（* / v%%(* 同语义;
                        #     awk 单遍正则: 首个任意括号命中即截断)
                        p = match(s, /（|\(/)
                        if (p > 0) s = substr(s, 1, p - 1)
                        sub(/[[:space:]]+$/, "", s)                # ② 剥行尾空白
                        # ③ 全词判定(与 parse_status 逐字同梯; 注记含 complete 字样
                        # 被误计 complete) → ④ 前缀回落 → pending
                        if (s == "complete") comp++
                        else if (s == "in_progress") inp++
                        else if (s == "pending") pend++
                        else if (s ~ /^in_progress/) inp++
                        else if (s ~ /^complete/) comp++
                        else pend++
                    }
                    # —— frontmatter 首个命中(原独立 awk …exit 的首行语义) ——
                    if (!sid_seen && line ~ /^session_id:/) { split(line, f, " "); sid = f[2]; sid_seen = 1 }
                    if (!wt_seen && line ~ /^worktree_path:/) { split(line, f, " "); wt = f[2]; wt_seen = 1 }
                    # —— scope(语义锚=lib/plan-parse.sh plan_parse_scope): 「## …执行
                    #    范围限制」到下一「## 」标题, 表格行第 3+ 字段含点分路径的整格,
                    #    头 10 条逗号 join(原 head -10|tr|sed 口径) ——
                    if (line ~ /^## .*执行范围限制/) { inscope = 1 }
                    else if (line ~ /^## /) { inscope = 0 }
                    if (inscope && line ~ /^\|/ && line !~ /^\|---/) {
                        n = split(line, c, "|")
                        for (i = 3; i <= n; i++) {
                            s = c[i]
                            gsub(/^[[:space:]]+/, "", s)
                            gsub(/[[:space:]]+$/, "", s)
                            if (s ~ /\.[a-zA-Z]/ && nscope < 10) {
                                scopes = (nscope ? scopes "," : "") s
                                nscope++
                            }
                        }
                    }
                    r = (getline line < path)
                }
                close(path)

                if (goal == "") goal = "(no goal)"
                if (sid == "") sid = "none"
                g = substr(goal, 1, 50)

                # —— 状态归并(原 write_index bash 判定逐字迁移)与三类行产出 ——
                if (total+0 > 0 && comp+0 == total+0) {
                    st = "complete"; icon = "✓"; tdone++
                    printf "D\t- %s ✓ (%d/%d) — %s\n", tid, comp, total, mt
                } else if (inp+0 > 0 || comp+0 > 0) {
                    st = "in_progress"; icon = "⚠ 续"; tinprog++
                    printf "T\t- **%s** — in_progress, Phase %d/%d（中断恢复首选）\n", tid, comp, total
                } else {
                    st = "pending"; icon = "⚠ 未开始"; ttodo++
                    printf "T\t- **%s** — pending, 未开始 (0/%d)\n", tid, total
                }
                printf "R\t| %s | %s | %d/%d | %s | %s | %s | %s | %s | %s |\n", \
                       tid, st, comp, total, g, sid, wt, scopes, mt, icon
            }
            END { printf "S\t%d\t%d\t%d\n", tinprog, ttodo, tdone }
        '
    )

    local now
    now="$(date +%Y-%m-%d_%H:%M)"

    {
        echo "# Task Index"
        echo "<!-- Auto-generated by sync-todos.sh --index. 勿手改，重跑脚本刷新。 -->"
        echo "<!-- Last refreshed: ${now} -->"
        echo ""
        echo "> 恢复时先读本文件：in_progress=中断待续 / pending=未开始 / complete=已完成。"
        echo "> 单任务详情 → 对应 task-{id}/task_plan.md。刷新：\`sync-todos.sh --index\`"
        echo ""
        if [[ ${#rows_arr[@]} -eq 0 ]]; then
            echo "_No tasks found under ${plans_dir}_"
        else
            echo "| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |"
            echo "|---------|--------|-----------|------|---------|------|"
            printf '%s\n' "${rows_arr[@]}"
            echo ""
            echo "## 待处理（需关注）"
            if [[ ${#todo_arr[@]} -eq 0 ]]; then
                echo "_无待处理任务_"
            else
                printf '%s\n' "${todo_arr[@]}"
            fi
            echo ""
            echo "## 已完成"
            if [[ ${#done_arr[@]} -eq 0 ]]; then
                echo "_无_"
            else
                printf '%s\n' "${done_arr[@]}"
            fi
            echo ""
            echo "## 汇总"
            echo "- in_progress: ${tinprog} | pending: ${ttodo} | complete: ${tdone}"
        fi
    } > "$plans_dir/INDEX.md"

    echo "[index] Wrote $plans_dir/INDEX.md (in_progress=${tinprog} pending=${ttodo} complete=${tdone})"
    echo "[index] Resume: read $plans_dir/INDEX.md → 待处理区"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    if $INDEX_MODE; then
        write_index "$PLANS_DIR"
    else
        forward_sync "$PLANS_DIR"
    fi
}

main