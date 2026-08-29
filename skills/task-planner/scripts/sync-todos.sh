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
PLANS_DIR="${PLANS_DIR:-$(pwd)/plans}"

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

        # Skip pending (no Todo needed for phases not started)
        if (status == "pending") {
            phase_num = 0
            next
        }

        # Build subject (max 60 chars for Claude Code limit)
        subject = tid "/Phase " phase_num
        if (length(subject) > 60) {
            subject = substr(subject, 1, 57) "..."
        }

        # Output: TASK_ID|PHASE_NUM|STATUS|SUBJECT
        printf "%s|%s|%s|%s\n", tid, phase_num, status, subject
        phase_num = 0
    }
    ' "$task_plan"
}

# ─── Forward sync report ───────────────────────────────────────────────────
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

# ─── Task index rollup (for --index mode) ───────────────────────────────────
# Per-task status rollup from a single task_plan.md.
# Output pipe-delimited: TASK_ID|GOAL|TOTAL|COMPLETE|INPROG|PENDING|MTIME
rollup_task() {
    local task_plan="$1"
    local task_id
    task_id="$(dirname "$task_plan" | xargs basename)"
    local mtime
    mtime="$(stat -c %y "$task_plan" 2>/dev/null | cut -d' ' -f1)"
    mtime="${mtime:-?}"

    awk -v tid="$task_id" -v mt="$mtime" '
        /^## Goal[[:space:]]*$/ { ingoal=1; next }
        ingoal && /^#/ { ingoal=0 }
        ingoal {
            line=$0
            sub(/<!--.*-->/,"",line)
            sub(/^[[:space:]]*/,"",line)
            if (line != "" && goal == "") goal=line
        }
        /^### Phase [0-9]+:/ { total++ }
        /[Ss]tatus:\*\*/ {
            s=$0; sub(/.*[Ss]tatus:\*\*[[:space:]]*/,"",s); gsub(/\*\*/,"",s); gsub(/[[:space:]]/,"",s)
            if (s ~ /complete/) complete++
            else if (s ~ /in_progress/) inprog++
            else if (s ~ /pending/) pending++
        }
        END {
            if (goal=="") goal="(no goal)"
            printf "%s|%s|%d|%d|%d|%d|%s\n", tid, substr(goal,1,50), total+0, complete+0, inprog+0, pending+0, mt
        }
    ' "$task_plan"
}

# ─── Write plans/INDEX.md (persistent cross-task registry) ──────────────────
# Answers "which tasks need processing after interruption?" by rolling up every
# task-{id}/ state into ONE file at the plans/ parent level. Read INDEX.md first on resume.
write_index() {
    local plans_dir="$1"
    if [[ ! -d "$plans_dir" ]]; then
        echo "[index] No plans directory: $plans_dir" >&2
        return 1
    fi

    local -a rows_arr=() todo_arr=() done_arr=()
    local task_id goal total comp inp pend mtime status icon row
    local ttodo=0 tdone=0 tinprog=0

    while IFS= read -r task_plan; do
        [[ -z "$task_plan" ]] && continue
        row="$(rollup_task "$task_plan")"
        [[ -z "$row" ]] && continue
        IFS='|' read -r task_id goal total comp inp pend mtime <<< "$row"

        if [[ "${total:-0}" -gt 0 && "${comp:-0}" -eq "${total:-0}" ]]; then
            status="complete"; icon="✓"; tdone=$((tdone+1))
            done_arr+=("- ${task_id} ✓ (${comp}/${total}) — ${mtime}")
        elif [[ "${inp:-0}" -gt 0 || "${comp:-0}" -gt 0 ]]; then
            status="in_progress"; icon="⚠ 续"; tinprog=$((tinprog+1))
            todo_arr+=("- **${task_id}** — in_progress, Phase ${comp}/${total}（中断恢复首选）")
        else
            status="pending"; icon="⚠ 未开始"; ttodo=$((ttodo+1))
            todo_arr+=("- **${task_id}** — pending, 未开始 (0/${total})")
        fi
        rows_arr+=("| ${task_id} | ${status} | ${comp}/${total} | ${goal} | ${mtime} | ${icon} |")
    done < <(find "$plans_dir" -maxdepth 2 -name "task_plan.md" -type f 2>/dev/null | sort)

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
            echo "| Task ID | Status | Phase 进度 | Goal | 最后更新 | 待办 |"
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