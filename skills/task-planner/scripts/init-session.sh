#!/bin/bash
# Initialize planning files for a new session
# Usage: ./init-session.sh [project-name]
#
# Template priority (per-file):
#   1. {project}/.claude/plan-templates/{filename}   (project-level, optional)
#   2. ~/.claude/skills/task-planner/templates/{filename}    (built-in fallback)
#
# Path resolution: look for .claude/plan-templates/ by traversing upward from CWD

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILTIN_TEMPLATES="${SCRIPT_DIR}/../templates"  # ~/.claude/skills/task-planner/templates/

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
DATE=$(date +%Y-%m-%d)

echo "Initializing planning files for: $PROJECT_NAME"

# Check for project-level templates
if project_templates=$(find_project_templates); then
    echo "Using project templates: $project_templates"
else
    echo "No project-level templates found, using built-in defaults"
    echo "  (Add .claude/plan-templates/ to your project for custom templates)"
fi
echo ""

# Initialize each template file (only if it doesn't exist)
for file in task_plan.md verification.md findings.md progress.md notepad-learnings.md; do
    if [ -f "$file" ]; then
        echo "$file already exists, skipping"
    else
        if copy_template "$file"; then
            echo "    Created $file"
        fi
    fi
done

echo ""
echo "Planning files initialized!"
