#!/usr/bin/env bash
set -euo pipefail

# scan-template-spec.sh
# Scan plan templates for spec_version lineage compliance against kit authority.
# Outputs: CURRENT-SPEC, per-template status lines, OUTDATED summary.
# Exit: 0 if OUTDATED=0, 1 if any OUTDATED/MISSING-counted-as-outdated.
#
# Usage:
#   scan-template-spec.sh [--target-spec <N>]
#   --target-spec <N> : compare against N; if N > current spec, simulate upgrade
#                       (all scanned templates reported OUTDATED). Default: current.

TARGET_SPEC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-spec)
      [[ $# -ge 2 ]] || { echo "error: --target-spec requires a value" >&2; exit 2; }
      TARGET_SPEC="$2"; shift 2 ;;
    -h|--help)
      sed -n '1,22p' "$0"; exit 0 ;;
    *)
      echo "error: unknown arg: $1" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
KIT_SKILL="$ROOT/skills/plan-template-kit/SKILL.md"
TPL_DIR="$ROOT/skills/task-planner/templates"

[[ -f "$KIT_SKILL" ]] || { echo "error: kit SKILL.md not found: $KIT_SKILL" >&2; exit 2; }

CURRENT_SPEC="$(grep -Eo 'spec_version=[0-9]+' "$KIT_SKILL" | head -n1 | cut -d= -f2 || true)"
[[ -n "$CURRENT_SPEC" ]] || { echo "error: cannot parse spec_version from $KIT_SKILL" >&2; exit 2; }

if [[ -n "$TARGET_SPEC" ]]; then
  [[ "$TARGET_SPEC" =~ ^[0-9]+$ ]] || { echo "error: --target-spec must be integer" >&2; exit 2; }
  TARGET="$TARGET_SPEC"
else
  TARGET="$CURRENT_SPEC"
fi

SIMULATE=0
if [[ "$TARGET" -gt "$CURRENT_SPEC" ]]; then
  SIMULATE=1
fi

is_variant_exempt() {
  local base="$1"
  [[ "$base" == "mini-lite-type.md" || "$base" == "l0-lite-type.md" ]]
}

is_root_aux_exempt() {
  # Root auxiliary templates (non-base, non-variant) are outside lineage governance.
  local base="$1"
  [[ "$base" != "task_plan.md" ]]
}

extract_spec_version() {
  local file="$1"
  # Parse spec_version from template-lineage header (scan header region).
  local line
  line="$(grep -m1 'template-lineage:' "$file" || true)"
  if [[ -z "$line" ]]; then
    echo ""
    return 0
  fi
  echo "$line" | grep -Eo 'spec_version=[0-9]+' | head -n1 | cut -d= -f2 || true
}

echo "CURRENT-SPEC: $CURRENT_SPEC"

OUTDATED_COUNT=0
# Collect scan files in stable order: root templates/*.md, then variant/*.md
mapfile -t ROOT_FILES < <(find "$TPL_DIR" -maxdepth 1 -type f -name '*.md' | sort)
mapfile -t VAR_FILES < <(find "$TPL_DIR/variant" -maxdepth 1 -type f -name '*.md' | sort)
FILES=("${ROOT_FILES[@]}" "${VAR_FILES[@]}")

for f in "${FILES[@]}"; do
  rel="${f#"$ROOT"/}"
  base="$(basename "$f")"
  in_variant=0
  [[ "$f" == "$TPL_DIR/variant/"* ]] && in_variant=1

  exempt=0
  if [[ $in_variant -eq 1 ]]; then
    if is_variant_exempt "$base"; then exempt=1; fi
  else
    if is_root_aux_exempt "$base"; then exempt=1; fi
  fi

  sv="$(extract_spec_version "$f")"

  if [[ $SIMULATE -eq 1 ]]; then
    # Upgrade simulation: all scanned templates listed as OUTDATED.
    vdisp="${sv:-missing}"
    echo "$rel spec_version=$vdisp OUTDATED"
    OUTDATED_COUNT=$((OUTDATED_COUNT + 1))
    continue
  fi

  if [[ $exempt -eq 1 ]]; then
    vdisp="${sv:-exempt}"
    echo "$rel spec_version=$vdisp SKIPPED-EXEMPT"
    continue
  fi

  if [[ -z "$sv" ]]; then
    echo "$rel spec_version=missing MISSING"
    OUTDATED_COUNT=$((OUTDATED_COUNT + 1))
    continue
  fi

  if [[ "$sv" -lt "$TARGET" ]]; then
    echo "$rel spec_version=$sv OUTDATED"
    OUTDATED_COUNT=$((OUTDATED_COUNT + 1))
  else
    echo "$rel spec_version=$sv OK"
  fi
done

echo "OUTDATED: $OUTDATED_COUNT"
if [[ "$OUTDATED_COUNT" -eq 0 ]]; then
  exit 0
else
  exit 1
fi
