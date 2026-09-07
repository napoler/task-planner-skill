#!/usr/bin/env bash
# lib/verify.sh — Verify multi-tool task-planner installation
#
# Usage:
#   TASK_PLANNER_ROOT=<canonical skill dir> bash verify.sh [(--help|-h)]
#
# Or source + call explicitly (smoke.sh path):
#   source verify.sh
#   verify_installation
#
# 三态部署模型(2026-09-06 task-v053):
#   - 软链(symlink):stub 指向 canonical → 软链目标 + canonical 全量版校验
#   - 薄壳(thin shell):stub 是独立小体积副本(<15KB) → 硬编码路径 / 体积校验
#   - 全量实体副本(full copy):stub 是 canonical 全量副本(>=15KB)→
#     SKILL.md 一致性(cmp) + deploy drift 检测;check 3/4/8 走 N/A 分支
#
# Checks:
#   1. Canonical source exists (SKILL.md 必存;若 .git 同存则附 git root 说明)
#   2. Each detected tool has stub (软链/薄壳/全量实体副本 三态判定)
#   3. Stub scripts have no hardcoded zcode/claude paths (软链/全量副本跳过)
#   4. Stub SKILL.md 体积或一致性(软链=全量;薄壳=<15KB;全量副本=cmp 一致)
#   5. check-complete.sh runs OK (no plan = exit 0/2 acceptable)
#   6. check-doc-sync.sh runs OK
#   7. External references use ${TASK_PLANNER_ROOT} form
#   8. Hooks registered per platform (claude=settings.local.json, zcode=cli/config.json,
#      opencode/cursor=SKILL.md frontmatter;全量副本模式下 frontmatter hooks: 块 N/A)
#   9. task-v055 委派门控三件套可执行(check-delegation.sh + allow-direct.sh +
#      selftest-delegation.sh;2026-09-07)
#   10. task-v055-fallback provider 探测脚本可执行 + config.provider_fallback 键
#      (subagent-fallback.sh;2026-09-08)
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

  # 第三态:全量实体副本(2026-09-06 task-v053):stub 是独立但体积等同 canonical 的实体副本
  stub_is_full_copy() {
    local stub="$1"
    [ -d "$stub" ] && [ -f "$stub/SKILL.md" ] || return 1
    [ "$(wc -c < "$stub/SKILL.md")" -ge 15360 ]
  }

  # 1. Canonical source — SKILL.md 必存;若 .git 同存则附 git root 说明
  if [ -f "$TASK_PLANNER_ROOT/SKILL.md" ]; then
    if [ -d "$TASK_PLANNER_ROOT/.git" ]; then
      pass "canonical source exists at $TASK_PLANNER_ROOT (git repo)"
    else
      pass "canonical source exists at $TASK_PLANNER_ROOT (no .git, e.g. exported snapshot — OK)"
    fi
  else
    fail "canonical source missing SKILL.md: $TASK_PLANNER_ROOT"
  fi

  # 2. Each detected tool has stub (三态判定)
  if [ ${#TOOLS_DETECTED[@]} -eq 0 ]; then
    fail "no agent tools detected (checked: claude-code, zcode, opencode, cursor, continue)"
  else
    for tool in "${TOOLS_DETECTED[@]}"; do
      local stub="${TOOL_STUB_ROOT[$tool]}"
      if stub_is_symlink_mode "$stub"; then
        pass "$tool deploy = symlink → canonical (软链模型)"
      elif stub_is_full_copy "$stub"; then
        if cmp -s "$stub/SKILL.md" "$TASK_PLANNER_ROOT/SKILL.md"; then
          pass "$tool deploy = physical full copy, deploy matches canonical (全量副本模型)"
        else
          fail "$tool deploy drift: full-copy SKILL.md differs from canonical ($stub)"
        fi
      elif [ -d "$stub" ] && [ -f "$stub/SKILL.md" ]; then
        pass "$tool stub exists at $stub"
      else
        fail "$tool stub missing or incomplete: $stub"
      fi
    done
  fi

  # 3. Stub scripts: no hardcoded zcode/claude paths (仅薄壳实体模型;软链/全量副本跳过)
  # Note: check-doc-sync.sh intentionally keeps zcode/claude fallback chain
  # in its `for _c in` block (line 30-36) for standalone-script use. Whitelist it.
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]}"
    if stub_is_symlink_mode "$stub"; then
      continue  # 软链模型的脚本即 canonical 脚本,回退默认值合法,见文件头注释
    fi
    if stub_is_full_copy "$stub"; then
      pass "$tool scripts: canonical scripts/full copy — hardcoded-path scan N/A"
      continue  # 全量副本 = canonical 实体副本,无独立硬编码检查必要
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

  # 4. Stub SKILL.md size / consistency — 三态:软链(>=15KB 经软链可读);薄壳(<15KB);全量副本(>=15KB,与 canonical 一致)
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
    if stub_is_full_copy "$stub"; then
      # check 2 已报 cmp 一致;此处复述 size 以便一眼看出三态
      local fsize
      fsize=$(wc -c < "$stub/SKILL.md")
      pass "$tool SKILL.md = canonical full copy ($fsize bytes, full-copy deploy)"
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
  # 全量实体副本:canonical frontmatter 无 hooks: 块(hooks 按平台配置注册,SKILL.md 内是注释说明)
  for tool in opencode cursor continue; do
    local stub="${TOOL_STUB_ROOT[$tool]:-}"
    [ -n "$stub" ] && [ -d "$stub" ] && [ -f "$stub/SKILL.md" ] || continue
    if stub_is_full_copy "$stub"; then
      pass "$tool: hooks registered at platform level (frontmatter block N/A for full copy)"
      continue
    fi
    if grep -q '^hooks:' "$stub/SKILL.md" 2>/dev/null; then
      pass "$tool: hooks declared in SKILL.md frontmatter"
    else
      fail "$tool: SKILL.md missing hooks: block (run install.sh to regenerate)"
    fi
  done

  # 9. task-v055 委派门控脚本存在性(2026-09-07):PreToolUse hook 拦截 + 用户 bypass
  # + 自测 是执行期机制化三件套,任一缺失 = 白名单/拦截/自测三能力之一失效
  for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh; do
    if [ -x "$TASK_PLANNER_ROOT/scripts/$_script" ]; then
      pass "$_script exists and is executable"
    else
      fail "$_script missing or not executable at $TASK_PLANNER_ROOT/scripts/"
    fi
  done

  # 10. task-v055-fallback provider 探测脚本(2026-09-08):网络/400 类失败后主动 Scaling 改派
  if [ -x "$TASK_PLANNER_ROOT/scripts/subagent-fallback.sh" ]; then
    pass "subagent-fallback.sh exists and is executable"
  else
    fail "subagent-fallback.sh missing or not executable at $TASK_PLANNER_ROOT/scripts/"
  fi
  if jq -e '.properties.provider_fallback // empty' "$TASK_PLANNER_ROOT/config.json" >/dev/null 2>&1; then
    pass "config.json provider_fallback key present"
  else
    fail "config.json missing .properties.provider_fallback (Rule 22.3.1)"
  fi

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

# 2026-09-06 task-v053: main 入口 — 原脚本只定义函数从未调用,直接运行静默 exit 0,所有检查形同虚设
verify_usage() {
  echo "Usage: TASK_PLANNER_ROOT=<canonical skill dir> bash verify.sh"
  echo "  校验 canonical 存在性与各平台部署位健康度(三态:软链/薄壳/全量实体副本)"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    verify_usage; exit 0
  fi
  verify_installation
  exit $?
fi
