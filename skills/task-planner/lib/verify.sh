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
#      opencode/cursor=SKILL.md frontmatter;全量副本模式下同样检查 hooks: 块存在性)
#   9. task-v055 委派门控三件套可执行(check-delegation.sh + allow-direct.sh +
#      selftest-delegation.sh;2026-09-07)
#      + task-v075 P5 (v063 遗留①): selftest-methodology.sh(v063 引入,methodology
#      门控面守护脚本)并入同一存在性检查循环
#   10. task-v055-fallback provider 探测脚本可执行 + config.provider_fallback 键
#      (subagent-fallback.sh;2026-09-08)
#   11. H1 SP 注入脚本 canonical 可执行 + 各部署位 scripts/ 内容一致(2026-11-24,
#      zcode-sp-inject.sh;SessionStart 指向部署位,缺失即 ENOENT)
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
        # [2026-11-25 task-skill-deploy-fix] B4: 薄壳静态分发面对账。What: 对 thin shell（<15KB SKILL.md）不再只
        #   pass "stub exists"，而是对 install-stub.sh:329 rsync 分发面的静态文件做 diff -rq 对账。
        # Why: 薄壳模式此前无内容漂移检测，部署位静态资源与 canonical 漏检。
        # 范围: references/ templates/ config.json schemas/ 等静态文件；排除 SKILL.md（工具适配薄壳）、
        #   scripts（rewrite 本地化）、lib（install-stub.sh --exclude='/lib/' 非分发面）、
        #   __pycache__/.git/.backup/install.log/tests/docs。
        local _thin_drift=""
        for _item in references templates config.json schemas; do
          [ -e "$TASK_PLANNER_ROOT/$_item" ] || continue
          if [ ! -e "$stub/$_item" ]; then
            _thin_drift="${_thin_drift} missing:${_item}"
            continue
          fi
          if [ -d "$TASK_PLANNER_ROOT/$_item" ]; then
            local _d
            _d="$(diff -rq "$TASK_PLANNER_ROOT/$_item" "$stub/$_item" 2>/dev/null | grep -v '__pycache__' | head -5 || true)"
            [ -n "$_d" ] && _thin_drift="${_thin_drift} drift:${_item}"
          else
            cmp -s "$TASK_PLANNER_ROOT/$_item" "$stub/$_item" || _thin_drift="${_thin_drift} drift:${_item}"
          fi
        done
        if [ -z "$_thin_drift" ]; then
          pass "$tool stub thin-shell static content matches canonical ($stub)"
        else
          fail "$tool stub thin-shell drift:${_thin_drift} ($stub)"
        fi
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
      # Find files with hardcoded paths, excluding whitelisted env-fallback chains.
      # [2026-11-25 task-skill-deploy-fix] What: 白名单新增 zcode-posttooluse.sh。
      # Why: 该文件 :251 的 SKILL_ROOT="${OPENCODE_SKILL_ROOT:-$HOME/.zcode/skills/task-planner}"
      #   与 check-doc-sync.sh 同为合法 env-fallback 形态（环境变量优先、未设才用默认），
      #   非裸硬编码；原检查只豁免 check-doc-sync.sh，部署位同步后本文件字面量显现致假 FAIL。
      #   判据不变：仍抓无 env 逃生的裸硬编码，只扩大同类合法形态的白名单。
      local hardcoded
      hardcoded=$(grep -rlnE '\$HOME/\.zcode/skills/task-planner|\$HOME/\.claude/skills/task-planner' "$stub/scripts/" 2>/dev/null \
        | grep -vE 'check-doc-sync\.sh$|zcode-posttooluse\.sh$' || true)
      if [ -z "$hardcoded" ]; then
        pass "$tool scripts: no hardcoded paths (env-fallback chains whitelisted)"
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
  # [2026-11-25 task-skill-deploy-fix] A3: 增强校验。What: 不只 grep task-planner，还用 jq/python 提取
  #   hooks.events 里含 task-planner 的 command，逐个验证 command 中脚本路径真实存在([ -f ])。
  # Why: 原检查只看关键字，路径失效/漂移无法发现；沿用 pass()/fail() 结构，不改函数签名。
  #   Stop 事件缺失仅提示不 fail（平台差异）。
  local zcode_cfg="$HOME/.zcode/cli/config.json"
  if [ -n "${TOOL_STUB_ROOT[zcode]:-}" ] && [ -f "$zcode_cfg" ]; then
    if grep -q 'task-planner' "$zcode_cfg" 2>/dev/null; then
      local _zp_ok=1 _zp_missing=""
      local _zp_cmds=""
      if command -v jq >/dev/null 2>&1; then
        _zp_cmds="$(jq -r '.. | objects | select(has("command")) | .command | select(type=="string") | select(test("task-planner"))' "$zcode_cfg" 2>/dev/null || true)"
      elif command -v python3 >/dev/null 2>&1; then
        _zp_cmds="$(python3 - "$zcode_cfg" <<'PY'
import json, sys
p = sys.argv[1]
try:
    data = json.load(open(p))
except Exception:
    sys.exit(0)
cmds = []
def walk(x):
    if isinstance(x, dict):
        c = x.get("command")
        if isinstance(c, str) and "task-planner" in c:
            cmds.append(c)
        for v in x.values():
            walk(v)
    elif isinstance(x, list):
        for v in x:
            walk(v)
walk(data)
for c in cmds:
    print(c)
PY
        )"
      fi
      if [ -n "$_zp_cmds" ]; then
        while IFS= read -r _cmd; do
          [ -n "$_cmd" ] || continue
          # 提取 command 中看起来像绝对路径的 task-planner 脚本片段
          local _paths
          _paths="$(printf '%s\n' "$_cmd" | grep -oE '/[^"'"'"' ]*task-planner[^"'"'"' ]*\.(sh|cjs|ps1|ts|py)' || true)"
          while IFS= read -r _p; do
            [ -n "$_p" ] || continue
            if [ ! -f "$_p" ]; then
              _zp_ok=0
              _zp_missing="${_zp_missing} $_p"
            fi
          done <<< "$_paths"
        done <<< "$_zp_cmds"
      fi
      if [ "$_zp_ok" -eq 1 ]; then
        pass "ZCode: hooks registered in $zcode_cfg (command paths exist)"
      else
        fail "ZCode: hook command paths missing:${_zp_missing}"
      fi
      # Stop 事件缺失仅提示不 fail（平台差异）
      if ! grep -q '"Stop"' "$zcode_cfg" 2>/dev/null && ! grep -q "'Stop'" "$zcode_cfg" 2>/dev/null; then
        echo "[verify] · ZCode: $zcode_cfg missing Stop event (hint only, platform-dependent)"
      fi
    else
      fail "ZCode: $zcode_cfg missing task-planner hooks"
    fi
  fi
  # OpenCode/Cursor/Continue(薄壳实体模型+全量实体副本): SKILL.md frontmatter must contain hooks: block
  # [2026-11-28 task-skill-fix-defs-20261128 DEF-05] What: 全量实体副本位也检查 SKILL.md frontmatter hooks: 块存在性。
  # Why: 根因=审计 DEF-05 盲区（verify.sh:26 hooks N/A=对账盲区）；原行为=N/A 跳过；现=hooks 存在性检查进对账，缺失计 fail。
  #      全量副本是 canonical 实体副本，正常应含 hooks: 块；缺失说明部署漂移，不应静默 N/A。
  for tool in opencode cursor continue; do
    local stub="${TOOL_STUB_ROOT[$tool]:-}"
    [ -n "$stub" ] && [ -d "$stub" ] && [ -f "$stub/SKILL.md" ] || continue
    if grep -q '^hooks:' "$stub/SKILL.md" 2>/dev/null; then
      if stub_is_full_copy "$stub"; then
        pass "$tool: hooks declared in SKILL.md frontmatter (full-copy deploy)"
      else
        pass "$tool: hooks declared in SKILL.md frontmatter"
      fi
    else
      if stub_is_full_copy "$stub"; then
        fail "$tool: SKILL.md missing hooks: block in full-copy deploy ($stub)"
      else
        fail "$tool: SKILL.md missing hooks: block (run install.sh to regenerate)"
      fi
    fi
  done

  # 9. task-v055 委派门控脚本存在性(2026-09-07):PreToolUse hook 拦截 + 用户 bypass
  # + 自测 是执行期机制化三件套,任一缺失 = 白名单/拦截/自测三能力之一失效
  # task-v075 P5 (v063 遗留①): 追加 selftest-methodology.sh(v063 引入的 methodology
  # 门控面守护脚本)——同目录存在性+可执行性检查,语义不变
  for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh selftest-methodology.sh; do
    if [ -x "$TASK_PLANNER_ROOT/scripts/$_script" ]; then
      pass "$_script exists and is executable"
    else
      fail "$_script missing or not executable at $TASK_PLANNER_ROOT/scripts/"
    fi
  done

  # 10. task-v055-fallback provider 探测脚本(2026-09-08):网络/400 类失败后主动 Scaling 改派
  if [ -x "$TASK_PLANNER_ROOT/../task-dispatch/scripts/subagent-fallback.sh" ]; then
    pass "subagent-fallback.sh exists and is executable"
  else
    fail "subagent-fallback.sh missing or not executable at $TASK_PLANNER_ROOT/../task-dispatch/scripts/"
  fi
  if jq -e '.properties.provider_fallback // empty' "$TASK_PLANNER_ROOT/config.json" >/dev/null 2>&1; then
    pass "config.json provider_fallback key present"
  else
    fail "config.json missing .properties.provider_fallback (Rule 22.3.1)"
  fi

  # 11. [2026-11-24 task-sp-driven-invocation H1] SP 注入脚本 canonical + 部署位对账
  # What: 校验 zcode-sp-inject.sh 在 canonical 存在且可执行，且每个已检出工具 stub 的
  #       scripts/ 下同名文件与 canonical 内容一致（cmp）。
  # Why: SessionStart hook 命令指向部署位绝对路径；仅 canonical 有而部署位缺失 = 首次触发
  #       ENOENT（improvement-proposal.md H1 W-3）。纳入 summary 计数使部署漂移即 FAIL。
  # 边界: 软链模式下 stub/scripts 即 canonical，cmp 自然成立；无该工具 stub 则跳过该工具。
  local sp_src="$TASK_PLANNER_ROOT/scripts/zcode-sp-inject.sh"
  if [ -x "$sp_src" ]; then
    pass "zcode-sp-inject.sh exists and is executable at canonical scripts/"
  else
    fail "zcode-sp-inject.sh missing or not executable at $sp_src"
  fi
  for tool in "${TOOLS_DETECTED[@]}"; do
    local stub="${TOOL_STUB_ROOT[$tool]:-}"
    [ -n "$stub" ] && [ -d "$stub" ] || continue
    local sp_deployed="$stub/scripts/zcode-sp-inject.sh"
    if [ ! -f "$sp_deployed" ]; then
      fail "$tool deploy missing zcode-sp-inject.sh at $sp_deployed (SessionStart hook ENOENT)"
    elif [ -f "$sp_src" ] && ! cmp -s "$sp_src" "$sp_deployed"; then
      fail "$tool deploy drift: zcode-sp-inject.sh differs from canonical ($sp_deployed)"
    else
      pass "$tool deploy: zcode-sp-inject.sh in sync with canonical"
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
