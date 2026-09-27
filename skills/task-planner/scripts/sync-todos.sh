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
# Output (one line per non-pending Phase):
#   TASK_ID|PHASE_NUM|STATUS|PHASE_TITLE|SUBJECT
parse_task_plan() {
    local task_plan="$1"

    # Extract task_id from path: plans/task-YYYYMMDD-HHMMSS/task_plan.md
    local task_id
    task_id=$(dirname "$task_plan" | xargs basename)

    # Find all Phase blocks and their Status
    # State machine: capture phase info on header, capture status on **Status:**
    awk -v tid="$task_id" '
    /^### Phase [0-9]+:/ {
        # Extract phase number
        if (match($0, /^### Phase ([0-9]+):/, arr)) {
            phase_num = arr[1]
        }
        # Extract phase title (everything after "Phase N: ")
        phase_title = $0
        sub(/^### Phase [0-9]+: */, "", phase_title)
    }
    /^- \*\*Status:\*\*/ && phase_num {
        # Extract status: "- **Status:** value" → "value"
        status = $0
        sub(/^- \*\*Status:\*\* */, "", status)
        gsub(/^\*\*|\*\*$/, "", status)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)

        # task-v065/V-4 [2026-09-13] 归一化: 去括号注释(如 in_progress(2026-09-13, ...)),
        # 前缀匹配 pending|in_progress|complete, 均不命中 → pending
        sub(/[（(].*$/, "", status)
        gsub(/[[:space:]]+$/, "", status)
        if (status ~ /^in_progress/) status = "in_progress"
        else if (status ~ /^complete/) status = "complete"
        else if (status !~ /^pending/) status = "pending"

        # Skip pending (no Todo needed for phases not started)
        if (status == "pending") {
            phase_num = 0
            next
        }

        # Build subject (max 60 chars for Claude Code limit)
        # task-v065/V-4 [2026-09-13] subject 补 phase title(原为死变量): 截断 40 字符加 …
        # (与 todo-sync.md 契约 subject 格式 "{task-id}/Phase N: title" 一致)
        t = phase_title
        if (length(t) > 40) t = substr(t, 1, 39) "…"
        subject = tid "/Phase " phase_num ": " t
        if (length(subject) > 60) {
            subject = substr(subject, 1, 57) "..."
        }

        # Output: TASK_ID|PHASE_NUM|STATUS|SUBJECT
        printf "%s|%s|%s|%s\n", tid, phase_num, status, subject
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
    while IFS= read -r task_plan; do
        [[ -z "$task_plan" ]] && continue

        while IFS='|' read -r tid pnum status subject; do
            [[ -z "$tid" ]] && continue

            if $JSON_OUTPUT; then
                [[ -n "$json_entries" ]] && json_entries="${json_entries},"
                json_entries="${json_entries}{\"task_id\":\"$tid\",\"phase\":$pnum,\"status\":\"$status\",\"subject\":\"$subject\"}"
            else
                echo "[sync-todos] $tid | Phase $pnum | $status | $subject"
            fi
            ((count++)) || true
        done < <(parse_task_plan "$task_plan")

    done < <(find "$plans_dir" -name "task_plan.md" -type f 2>/dev/null | sort)

    if $JSON_OUTPUT; then
        echo "[$json_entries]"
    else
        echo "[sync-todos] Total: $count phases to sync"
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
                    # —— Phase/状态计数: 任一 Status:** 行均计(含括号注记, 整词归一) ——
                    if (line ~ /^### Phase [0-9]+:/) total++
                    if (line ~ /[Ss]tatus:\*\*/) {
                        s = line
                        sub(/.*[Ss]tatus:\*\*[[:space:]]*/, "", s)
                        gsub(/\*\*/, "", s)
                        gsub(/[[:space:]]/, "", s)
                        if (s ~ /complete/) comp++
                        else if (s ~ /in_progress/) inp++
                        else if (s ~ /pending/) pend++
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