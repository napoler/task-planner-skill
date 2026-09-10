#!/bin/bash
# [2026-09-04] 新增 5 文件存在性复核（Rule 19.5 配套），缺失/空文件 exit 1
# Initialize planning files for a new session
# Usage: ./init-session.sh [project-name]
#
# Template priority (per-file):
#   1. {project}/.claude/plan-templates/{filename}   (project-level, optional)
#   2. ~/.zcode/skills/task-planner/templates/{filename}    (built-in fallback)
#
# Path resolution: look for .claude/plan-templates/ by traversing upward from CWD

set -e

# 2026-09-06 task-v053: CWD 守卫 — 原 PLAN_ROOT="$(cd .. && pwd)" 无校验,在非 plans/<task-id>/ 目录运行会把模板写进任意目录并向 ${PLAN_ROOT}/.active_plan(可能为根目录)写指针(实测 /tmp 运行 PLAN_ROOT 解析为 /)
if [ "$(basename "$(dirname "$(pwd)")")" != "plans" ]; then
    echo "[init] ERROR: 必须在 plans/<task-id>/ 目录下运行(当前目录: $(pwd),父目录: $(dirname "$(pwd)"))" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILTIN_TEMPLATES="${SCRIPT_DIR}/../templates"  # ~/.zcode/skills/task-planner/templates/

# Find project-level templates: traverse upward from CWD to find .claude/plan-templates/
find_project_templates() {
    local dir="$(pwd)"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude/plan-templates" ]; then
            echo "$dir/.claude/plan-templates"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Copy a template file: project-level if exists, else built-in
# Usage: copy_template <filename>
copy_template() {
    local filename="$1"
    local project_templates

    if project_templates=$(find_project_templates) && [ -f "$project_templates/$filename" ]; then
        cp "$project_templates/$filename" "$filename"
        echo "  └─ $filename (project-level)"
    elif [ -f "$BUILTIN_TEMPLATES/$filename" ]; then
        cp "$BUILTIN_TEMPLATES/$filename" "$filename"
        echo "  └─ $filename (built-in)"
    else
        echo "  └─ $filename: no template found, skipping"
        return 1
    fi
}

PROJECT_NAME="${1:-project}"
TEMPLATE_TYPE="${2:-}"   # optional: research/diagnostic/writing/publish/code-edit/refactor/bugfix/migration/test-writing/deployment/performance-tuning/schema-migration
DATE=$(date +%Y-%m-%d)

echo "Initializing planning files for: $PROJECT_NAME"

# Template type routing (Rule 16, v2.2.1): variant task_plan selected by template_type
# Usage: ./init-session.sh [project-name] [template-type]
VALID_TYPES="research diagnostic writing publish code-edit refactor bugfix migration test-writing deployment performance-tuning schema-migration"
TASK_PLAN_SRC="task_plan.md"
if [ -n "$TEMPLATE_TYPE" ]; then
    if echo " $VALID_TYPES " | grep -q " $TEMPLATE_TYPE "; then
        VARIANT_REL="variant/${TEMPLATE_TYPE}-type.md"
        VARIANT_ABS_BUILTIN="${BUILTIN_TEMPLATES}/${VARIANT_REL}"
        if [ -f "$VARIANT_ABS_BUILTIN" ]; then
            TASK_PLAN_SRC="$VARIANT_REL"
            echo "Template routing: task_plan.md <- $VARIANT_REL (template_type: $TEMPLATE_TYPE)"
        else
            echo "WARNING: variant template not found: $VARIANT_REL — falling back to generic task_plan.md"
        fi
    else
        echo "WARNING: unknown template_type '$TEMPLATE_TYPE' — valid: $VALID_TYPES"
        echo "Falling back to generic task_plan.md"
    fi
fi

# Check for project-level templates
if project_templates=$(find_project_templates); then
    echo "Using project templates: $project_templates"
else
    echo "No project-level templates found, using built-in defaults"
    echo "  (Add .claude/plan-templates/ to your project for custom templates)"
fi
echo ""

# Initialize each template file (only if it doesn't exist)
for file in findings.md progress.md notepad-learnings.md verification.md; do
    if [ -f "$file" ]; then
        echo "$file already exists, skipping"
    else
        if copy_template "$file"; then
            echo "    Created $file"
        fi
    fi
done

# task_plan.md handled separately (may come from variant/)
if [ -f "task_plan.md" ]; then
    echo "task_plan.md already exists, skipping"
else
    if [ "$TASK_PLAN_SRC" != "task_plan.md" ]; then
        # variant source: copy directly to task_plan.md (project-level override first)
        if project_templates=$(find_project_templates) && [ -f "$project_templates/$TASK_PLAN_SRC" ]; then
            cp "$project_templates/$TASK_PLAN_SRC" "task_plan.md"
        else
            cp "${BUILTIN_TEMPLATES}/${TASK_PLAN_SRC}" "task_plan.md"
        fi
        echo "    Created task_plan.md (variant: $TEMPLATE_TYPE)"
    elif copy_template "task_plan.md"; then
        echo "    Created task_plan.md"
    fi
fi

echo ""
# [2026-09-04 Rule 19.5 配套] 5 文件存在性复核：缺失或空 → exit 1
missing_files=()
for f in task_plan.md findings.md progress.md notepad-learnings.md verification.md; do
    if [ ! -s "$f" ]; then
        missing_files+=("$f")
    fi
done
if [ ${#missing_files[@]} -gt 0 ]; then
    for f in "${missing_files[@]}"; do
        echo "[init] ERROR: $f missing or empty — planning files incomplete"
    done
    exit 1
fi
echo "[init] 5/5 planning files verified"
# [2026-09-05 task-active-plan] 自动写活跃计划指针(最新创建的计划=默认活跃);
# 失败仅警告不阻断(指针缺失时 resolve-plan-dir.sh 回退 mtime 最新)
# 2026-09-10 active-plan-race: 原行为=无条件覆写全局 plans/.active_plan(后写者赢,多并行会话互顶,
#   09-09 实锤 7 次 check-dispatch 误拦)。改为:env CLAUDE_CODE_SESSION_ID 有值(ZCode 会话)→
#   原子写会话私有 side 指针 .active_plan_side/<sidkey>.active_plan,不碰全局 legacy;
#   无值(cron/纯脚本单会话场景)→保持原行为写全局 legacy(7am cron 兼容)。
PLAN_ROOT="$(cd .. && pwd)"
SIDSRC="${CLAUDE_CODE_SESSION_ID:-}"
if [ -n "$SIDSRC" ]; then
    SIDKEY="$(printf '%s' "$SIDSRC" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
    if [ -n "$SIDKEY" ] && mkdir -p "$SIDE_DIR" 2>/dev/null; then
        side_tmp="$(mktemp "${SIDE_DIR}/.tmp.XXXXXX" 2>/dev/null)" || side_tmp=""
        if [ -n "$side_tmp" ]; then
            printf '%s\n' "$(basename "$PWD")" > "$side_tmp" 2>/dev/null \
                && mv -f "$side_tmp" "${SIDE_DIR}/${SIDKEY}.active_plan" 2>/dev/null \
                && echo "[init] active_plan side 指针已指向: $(basename "$PWD")(sid=${SIDKEY})"
        fi
    fi
else
    if printf '%s\n' "$(basename "$PWD")" > "${PLAN_ROOT}/.active_plan" 2>/dev/null; then
        echo "[init] active_plan 指针已指向: $(basename "$PWD")"
    else
        echo "[init] WARN: 指针写入失败(hook 将回退 mtime 最新解析)"
    fi
fi
echo "Planning files initialized!"
