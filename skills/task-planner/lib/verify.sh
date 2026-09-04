#!/usr/bin/env bash
# lib/verify.sh — Verify multi-tool task-planner installation
#
# Usage:
#   verify_installation
#
# Checks:
#   1. Canonical source exists and has git history
#   2. Each detected tool has a stub (软链模型:校验软链指向 canonical)
#   3. Stub scripts have no hardcoded zcode/claude paths (软链模型跳过)
#   4. Stub SKILL.md is thin shell (软链模型改为校验经软链可读 canonical 全量版)
#   5. check-complete.sh runs OK (no plan = exit 0/2 acceptable)
#   6. check-doc-sync.sh runs OK
#   7. External references use ${TASK_PLANNER_ROOT} form
#   8. Hooks registered per platform (claude=settings.local.json, zcode=cli/config.json,
#      opencode/cursor=SKILL.md frontmatter)
#
# Returns exit 0 if all pass; non-zero with summary if any fail.

set -u

: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

PASS=0
FAIL=0
FAILURES=()

pass() { PASS=$((PASS + 1)); echo "[verify] ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); FAILURES+=("$1"); echo "[verify] ✗ $1"; }

verify_installation() {
  # shellcheck disable=SC1091
  source "${TASK_PLANNER_ROOT}/lib/detect-tools.sh"

  # 软链模型判定(2026-09-04):部署位若为指向 canonical 的软链,则"薄壳体积/硬编码路径"
  # 检查不适用(全量内容与合法回退默认值都是预期状态),改为校验软链目标正确。
  local canonical_real
  canonical_real="$(readlink -f "$TASK_PLANNER_ROOT")"
  stub_is_symlink_mode() {
    local stub="$1"
    [ -L "$stub" ] || return 1
    [ "$(readlink -f "$stub")" = "$canonical_real" ]
  }

  # 1. Canonical source
  if [ -d "$TASK_PLANNER_ROOT/.git" ] && [ -f "$TASK_PLANNER_ROOT/SKILL.md" ]; then
    pass "canonical source exists at $TASK_PLANNER_ROOT"
  else
    fail "canonical source missing or not a git repo: $TASK_PLANNER_ROOT"
  fi

  # 2. Each detected tool has stub
  if [ ${#TOOLS_DETECTED[@]} -eq 0 ]; then
    fail "no agent tools detected (checked: claude-code, zcode, opencode, cursor, continue)"
  else
    for tool in "${TOOLS_DETECTED[@]}"; do
      local stub="${TOOL_STUB_ROOT[$tool]}"
      if stub_is_symlink_mode "$stub"; then
        pass "$tool deploy = symlink → canonical (软链模型)"
      elif [ -d "$stub" ] && [ -f "$stub/SKILL.md" ]; then
        pass "$tool stub exists at $stub"
      else
        fail "$tool stub missing or incomplete: $stub"
      fi
    done
  fi

  # 3. Stub scripts: no hardcoded zcode/claude paths (仅薄壳实体模型;软链模型跳过)
  # Note: check-doc-sync.sh intentionally keeps zcode/claude fallback chain
  # in its `for _c in` block (line 30-36) for standalone-script use. Whitelist it.
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]}"
    if stub_is_symlink_mode "$stub"; then
      continue  # 软链模型的脚本即 canonical 脚本,回退默认值合法,见文件头注释
    fi
    if [ -d "$stub/scripts" ]; then
      # Find files with hardcoded paths, excluding the whitelisted fallback chain in check-doc-sync.sh
      local hardcoded
      hardcoded=$(grep -rlnE '\$HOME/\.zcode/skills/task-planner|\$HOME/\.claude/skills/task-planner' "$stub/scripts/" 2>/dev/null \
        | grep -v 'check-doc-sync\.sh$' || true)
      if [ -z "$hardcoded" ]; then
        pass "$tool scripts: no hardcoded paths (check-doc-sync.sh fallback chain whitelisted)"
      else
        fail "$tool scripts: hardcoded paths in $(echo "$hardcoded" | wc -l) files"
      fi
    fi
  done

  # 4. Stub SKILL.md is thin (should be < 15KB) — 仅薄壳实体模型;软链模型应为大体积全量版
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]}"
    if stub_is_symlink_mode "$stub"; then
      local fsize
      fsize=$(wc -c < "$stub/SKILL.md" 2>/dev/null || echo 0)
      if [ "$fsize" -gt 0 ]; then
        pass "$tool SKILL.md = canonical full via symlink ($fsize bytes)"
      else
        fail "$tool SKILL.md unreadable through symlink: $stub"
      fi
      continue
    fi
    if [ -f "$stub/SKILL.md" ]; then
      local size
      size=$(wc -c < "$stub/SKILL.md")
      if [ "$size" -lt 15360 ]; then
        pass "$tool SKILL.md is thin shell ($size bytes)"
      else
        fail "$tool SKILL.md too large ($size bytes) — should be < 15KB"
      fi
    fi
  done

  # 5. check-complete.sh runs OK
  if [ -x "$TASK_PLANNER_ROOT/scripts/check-complete.sh" ]; then
    if bash "$TASK_PLANNER_ROOT/scripts/check-complete.sh" >/dev/null 2>&1; then
      pass "check-complete.sh runs OK"
    else
      fail "check-complete.sh returned non-zero"
    fi
  else
    fail "check-complete.sh not executable"
  fi

  # 6. check-doc-sync.sh runs OK (no plan = exit 2 acceptable)
  if [ -x "$TASK_PLANNER_ROOT/scripts/check-doc-sync.sh" ]; then
    local rc=0
    bash "$TASK_PLANNER_ROOT/scripts/check-doc-sync.sh" >/dev/null 2>&1 || rc=$?
    if [ "$rc" -eq 0 ] || [ "$rc" -eq 2 ]; then
      pass "check-doc-sync.sh runs OK (exit=$rc)"
    else
      fail "check-doc-sync.sh returned unexpected exit=$rc"
    fi
  else
    fail "check-doc-sync.sh not executable"
  fi

  # 7. External references migrated
  local unmigrated
  unmigrated=$(grep -rln 'bash ~/\.claude/skills/task-planner\|bash ~/\.zcode/skills/task-planner' \
    "$HOME/.claude/CLAUDE.md" "$HOME/.claude/commands/" 2>/dev/null | head -3)
  if [ -z "$unmigrated" ]; then
    pass "external references migrated to env-var form"
  else
    fail "external references still hardcoded: $unmigrated"
  fi

  # 8. Hooks actually registered per platform
  # Claude Code: must have hooks block in settings.local.json
  local claude_settings="$HOME/.claude/settings.local.json"
  if [ -d "${TOOL_STUB_ROOT[claude-code]:-}" ] && [ -f "$claude_settings" ]; then
    if grep -q 'task-plan-init\.cjs' "$claude_settings" 2>/dev/null; then
      pass "Claude Code: hooks registered in $claude_settings"
    else
      fail "Claude Code: settings.local.json missing task-planner hooks (run register-hooks-cj.ts)"
    fi
  fi
  # ZCode: hooks 注册机制 = ~/.zcode/cli/config.json 的 hooks.events(2026-09-04 实证,
  # SKILL.md frontmatter 从未承载 zcode hooks——canonical frontmatter 亦无 hooks: 块)
  local zcode_cfg="$HOME/.zcode/cli/config.json"
  if [ -n "${TOOL_STUB_ROOT[zcode]:-}" ] && [ -f "$zcode_cfg" ]; then
    if grep -q 'task-planner' "$zcode_cfg" 2>/dev/null; then
      pass "ZCode: hooks registered in $zcode_cfg"
    else
      fail "ZCode: $zcode_cfg missing task-planner hooks"
    fi
  fi
  # OpenCode/Cursor/Continue(薄壳实体模型): SKILL.md frontmatter must contain hooks: block
  for tool in opencode cursor continue; do
    local stub="${TOOL_STUB_ROOT[$tool]:-}"
    [ -n "$stub" ] && [ -d "$stub" ] && [ -f "$stub/SKILL.md" ] || continue
    if grep -q '^hooks:' "$stub/SKILL.md" 2>/dev/null; then
      pass "$tool: hooks declared in SKILL.md frontmatter"
    else
      fail "$tool: SKILL.md missing hooks: block (run install.sh to regenerate)"
    fi
  done

  # Summary
  echo ""
  echo "[verify] summary: $PASS pass / $FAIL fail"
  if [ "$FAIL" -gt 0 ]; then
    echo "[verify] FAILED checks:"
    for f in "${FAILURES[@]}"; do
      echo "  - $f"
    done
    return 1
  fi
  return 0
}
