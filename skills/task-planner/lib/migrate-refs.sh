#!/usr/bin/env bash
# lib/migrate-refs.sh — Migrate external references to use $TASK_PLANNER_ROOT
#
# Usage:
#   migrate_external_references [--dry-run|--apply]
#
# [2026-11-25 task-skill-deploy-fix] B3: 默认 dry-run（只打印将改动清单），仅 --apply 或
#   TASK_PLANNER_MIGRATE_REFS=1 时执行 sed -i；改写前备份到 ~/.task-planner-backups/migrate-refs/<ts>/；
#   单一 PATTERNS 数组同时驱动 grep 判据与 sed 规则，消除不同构。
#
# Migrates hardcoded paths in:
#   - ~/.claude/CLAUDE.md
#   - ~/.claude/commands/*.md
#   - ~/.claude/prompts/*.md (if exists)
#   - ~/.zcode/CLAUDE.md or AGENTS.md (if exists)
#
# Idempotent: skips files that no longer contain hardcoded patterns.

set -u

: "${HOME:?HOME must be set}"
: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

# Files to migrate: <glob> <sed-pattern>
MIGRATION_TARGETS=(
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.claude/commands/*.md"
  "$HOME/.claude/prompts/*.md"
  "$HOME/.zcode/CLAUDE.md"
  "$HOME/.zcode/AGENTS.md"
  "$HOME/.config/ZCode/AGENTS.md"
  "$HOME/AGENTS.md"
)

# [2026-11-25 task-skill-deploy-fix] B3: 单一 PATTERNS 数组同时驱动 grep 判据与 sed 规则，消除不同构。
# 格式: "<grep-regex>|<sed-rule>"；sed-rule 为空则仅参与检测（无对应改写）。
# grep-regex 用于检测文件是否仍含硬编码；sed-rule 用于实际替换。
PATTERNS=(
  'bash ~/\.claude/skills/task-planner/scripts/|s|bash ~/.claude/skills/task-planner/scripts/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  'node ~/\.claude/skills/task-planner/scripts/|s|node ~/.claude/skills/task-planner/scripts/|node ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  'bash ~/\.zcode/skills/task-planner/scripts/|s|bash ~/.zcode/skills/task-planner/scripts/|bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  'node ~/\.zcode/skills/task-planner/scripts/|s|node ~/.zcode/skills/task-planner/scripts/|node ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g'
  # detect-only：覆盖原 grep 判据中更宽的 $HOME/~/ 形态，保证检测与历史口径同构
  '\$HOME/\.claude/skills/task-planner|'
  '\$HOME/\.zcode/skills/task-planner|'
  'bash ~/.*\.claude/skills/task-planner|'
  'bash ~/.*\.zcode/skills/task-planner|'
)

_migrate_grep_re() {
  # 从 PATTERNS 构造统一 grep -E 正则（只取检测部分）
  local re="" p detect
  for p in "${PATTERNS[@]}"; do
    detect="${p%%|*}"
    if [ -z "$re" ]; then re="$detect"; else re="$re|$detect"; fi
  done
  printf '%s' "$re"
}

_migrate_sed_rules() {
  # 输出 PATTERNS 中包含 sed 规则的条目（有 '|' 分隔且右侧以 s| 开头）
  local p rule
  for p in "${PATTERNS[@]}"; do
    rule="${p#*|}"
    case "$rule" in
      s\|*) printf '%s\n' "$rule" ;;
    esac
  done
}

migrate_external_references() {
  # [2026-11-25 task-skill-deploy-fix] B3: 默认 dry-run，仅 --apply 或 TASK_PLANNER_MIGRATE_REFS=1 执行写入。
  local mode="dry-run"
  while [ $# -gt 0 ]; do
    case "$1" in
      --apply) mode="apply"; shift ;;
      --dry-run) mode="dry-run"; shift ;;
      *) shift ;;
    esac
  done
  if [ "$mode" = "dry-run" ] && [ "${TASK_PLANNER_MIGRATE_REFS:-0}" = "1" ]; then
    mode="apply"
  fi

  local changed=0
  local total=0
  local grep_re
  grep_re="$(_migrate_grep_re)"
  local backup_dir="$HOME/.task-planner-backups/migrate-refs/$(date +%Y%m%d-%H%M%S)"
  local backup_done=0

  for target in "${MIGRATION_TARGETS[@]}"; do
    # Expand glob (or use literal if no glob)
    for file in $target; do
      [ -f "$file" ] || continue
      total=$((total + 1))

      # Skip if already migrated (heuristic: no hardcoded path remaining)
      if ! grep -qE "$grep_re" "$file" 2>/dev/null; then
        continue
      fi

      if [ "$mode" = "dry-run" ]; then
        echo "[migrate] WOULD_CHANGE: $file"
        changed=$((changed + 1))
        continue
      fi

      # [2026-11-25 task-skill-deploy-fix] B3: 改写前备份到 ~/.task-planner-backups/migrate-refs/<ts>/
      if [ "$backup_done" -eq 0 ]; then
        mkdir -p "$backup_dir"
        backup_done=1
      fi
      local rel="${file#$HOME/}"
      mkdir -p "$backup_dir/$(dirname "$rel")"
      cp "$file" "$backup_dir/$rel"

      # Apply all sed rules (single source PATTERNS)
      while IFS= read -r rule; do
        [ -n "$rule" ] || continue
        sed -i "$rule" "$file"
      done < <(_migrate_sed_rules)

      echo "[migrate] CHANGED: $file (backup: $backup_dir/$rel)"
      changed=$((changed + 1))
    done
  done

  if [ "$mode" = "dry-run" ]; then
    echo "[migrate] summary: $changed / $total files would change (dry-run; use --apply or TASK_PLANNER_MIGRATE_REFS=1 to write)"
  else
    echo "[migrate] summary: $changed / $total files changed (backup_dir=$backup_dir)"
  fi
}
