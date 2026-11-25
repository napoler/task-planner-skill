#!/usr/bin/env bash
# install.sh — Multi-tool task-planner auto-installer
#
# Usage:
#   bash install.sh [--canonical <path>] [--tools claude,zcode,opencode,...] [--no-verify] [--no-backup] [--dry-run]
#
# What it does:
#   1. Pre-flight: checks git/bash availability
#   2. Clones canonical source (if not exists) or uses existing
#   3. Detects installed agent tools
#   4. Backs up existing per-tool stubs (if any)
#   5. Installs thin stub for each detected tool
#   6. Migrates external references (CLAUDE.md, commands/*.md, prompts/*.md)
#   7. Verifies installation
#
# Environment:
#   TASK_PLANNER_ROOT   override canonical location (default: $SCRIPT_DIR (dir containing install.sh))
#   INSTALL_LOG         log file path (default: $TASK_PLANNER_ROOT/install.log)

# [2026-11-25 task-skill-deploy-fix] What: 启用 set -e（fail-fast）。Why: 原缺 -e 导致中间命令失败静默继续；
#   配合 pipefail 需对管道显式捕获 PIPESTATUS，避免 head/sed 提前退出触发 SIGPIPE 误杀（见 :79/:189/:213）。
set -euo pipefail

# ─── Defaults ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_PLANNER_ROOT="${TASK_PLANNER_ROOT:-$SCRIPT_DIR}"
TOOLS_FILTER=""
SKIP_BACKUP=0
SKIP_VERIFY=0
DRY_RUN=0
INSTALL_LOG=""

# ─── Args ───────────────────────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    --canonical) TASK_PLANNER_ROOT="$2"; shift 2 ;;
    --tools) TOOLS_FILTER="$2"; shift 2 ;;
    --no-verify) SKIP_VERIFY=1; shift ;;
    --no-backup) SKIP_BACKUP=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,21p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

INSTALL_LOG="${INSTALL_LOG:-$TASK_PLANNER_ROOT/install.log}"
mkdir -p "$(dirname "$INSTALL_LOG")"
exec > >(tee -a "$INSTALL_LOG") 2>&1

log() { echo "[install $(date +%H:%M:%S)] $*"; }
dry() { if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; fi; }

# ─── Pre-flight ─────────────────────────────────────────────────────────
log "pre-flight checks"
for cmd in git bash; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "ERROR: $cmd not found"; exit 1
  fi
done
log "git + bash OK"

# ─── Phase 1: Clone or use existing canonical ───────────────────────────
log "Phase 1: canonical source"
if [ -d "$TASK_PLANNER_ROOT/.git" ]; then
  log "  existing canonical at $TASK_PLANNER_ROOT"
  cd "$TASK_PLANNER_ROOT"
  if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
    log "  git pull (clean working tree)"
    dry "git pull"
    [ "$DRY_RUN" -eq 0 ] && git pull --quiet 2>&1 || true
  else
    log "  WARNING: working tree dirty, skipping git pull"
  fi
elif [ -d "$SCRIPT_DIR/.git" ] && [ "$SCRIPT_DIR" != "$TASK_PLANNER_ROOT" ]; then
  log "  cloning $SCRIPT_DIR → $TASK_PLANNER_ROOT"
  dry "git clone $SCRIPT_DIR $TASK_PLANNER_ROOT"
  if [ "$DRY_RUN" -eq 0 ]; then
    # [2026-11-25 task-skill-deploy-fix] What: 去掉 `| head -3`。Why: set -euo pipefail 下 head 提前退出会
    #   通过 pipefail+SIGPIPE 误杀 clone 成功路径；install.log 已 tee 捕获输出，无需截断。
    git clone "$SCRIPT_DIR" "$TASK_PLANNER_ROOT" 2>&1
  fi
else
  log "  initializing new git repo at $TASK_PLANNER_ROOT"
  dry "git init $TASK_PLANNER_ROOT"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$TASK_PLANNER_ROOT"
    cd "$TASK_PLANNER_ROOT"
    git init --quiet
  fi
fi

# ─── Phase 2: Detect tools ──────────────────────────────────────────────
log "Phase 2: detect installed agent tools"
# shellcheck disable=SC1091
source "$TASK_PLANNER_ROOT/lib/detect-tools.sh"
log "  detected: ${TOOLS_DETECTED[*]:-(none)}"

# Filter if --tools given
if [ -n "$TOOLS_FILTER" ]; then
  IFS=',' read -ra WANTED <<< "$TOOLS_FILTER"
  FILTERED=()
  for t in "${TOOLS_DETECTED[@]}"; do
    for w in "${WANTED[@]}"; do
      if [ "$t" = "$w" ]; then FILTERED+=("$t"); fi
    done
  done
  TOOLS_DETECTED=("${FILTERED[@]}")
  log "  filtered: ${TOOLS_DETECTED[*]}"
fi

if [ ${#TOOLS_DETECTED[@]} -eq 0 ]; then
  log "  no tools detected — install will only set up canonical source"
fi

# ─── Phase 3: Backup existing stubs ─────────────────────────────────────
if [ "$SKIP_BACKUP" -eq 0 ] && [ ${#TOOLS_DETECTED[@]} -gt 0 ]; then
  log "Phase 3: backup existing stubs"
  dry "source lib/backup.sh; backup_existing_install"
  if [ "$DRY_RUN" -eq 0 ]; then
    export TASK_PLANNER_ROOT
    # shellcheck disable=SC1091
    source "$TASK_PLANNER_ROOT/lib/backup.sh"
    backup_existing_install
  fi
fi

# ─── Phase 4: Install stubs ──────────────────────────────────────────────
if [ ${#TOOLS_DETECTED[@]} -gt 0 ]; then
  log "Phase 4: install per-tool stubs"
  dry "source lib/install-stub.sh; for each tool: install_stub_for_tool"
  if [ "$DRY_RUN" -eq 0 ]; then
    # shellcheck disable=SC1091
    source "$TASK_PLANNER_ROOT/lib/install-stub.sh"
    for tool in "${TOOLS_DETECTED[@]}"; do
      install_stub_for_tool "$tool" "${TOOL_STUB_ROOT[$tool]}" "${TOOL_HOOK_STYLE[$tool]}"
    done
  fi
fi

# ─── Phase 4.5: Ensure SP injection hook script in each deploy stub ──────
# [2026-11-24 task-sp-driven-invocation H1] What: 显式保障 zcode-sp-inject.sh 落到各工具位
#   scripts/（Phase 4 的全量 rsync 已覆盖 scripts/，本步为幂等兜底 + 可 grep 的部署登记）。
# Why: config.json 的 SessionStart 命令指向部署位绝对路径，仅落 canonical 源则首次触发即
#   ENOENT（improvement-proposal.md H1 W-3 修正）；显式登记使部署清单可验证。
# [2026-11-25 task-skill-deploy-fix] A2: 未设 TASK_PLANNER_ROOT 时 fallback 到部署位绝对路径，不回落 canonical 源码。
# 边界: 尊重 DRY_RUN / TOOLS_FILTER；目标已存在且与 canonical 内容一致时 cmp 短路零写入。
log "Phase 4.5: ensure zcode-sp-inject.sh in each deploy stub (targets: ${TOOLS_DETECTED[*]:-(none)})"
SP_INJECT_SRC="$TASK_PLANNER_ROOT/scripts/zcode-sp-inject.sh"
if [ -f "$SP_INJECT_SRC" ]; then
  for tool in "${TOOLS_DETECTED[@]}"; do
    _sp_dst="${TOOL_STUB_ROOT[$tool]}/scripts/zcode-sp-inject.sh"
    if [ -f "$_sp_dst" ] && cmp -s "$SP_INJECT_SRC" "$_sp_dst"; then
      log "  $tool: zcode-sp-inject.sh already in sync — skip"
      continue
    fi
    dry "cp $SP_INJECT_SRC $_sp_dst"
    if [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$(dirname "$_sp_dst")"
      cp "$SP_INJECT_SRC" "$_sp_dst"
      chmod +x "$_sp_dst"
      log "  $tool: zcode-sp-inject.sh deployed to $_sp_dst"
    fi
  done
else
  log "  WARNING: zcode-sp-inject.sh missing at $SP_INJECT_SRC — SP injection hook will be unavailable"
fi

# ─── Phase 5: Migrate external references ───────────────────────────────
# [2026-11-25 task-skill-deploy-fix] B3: 默认不再自动改写用户全局文件。Why: 外部引用迁移会 sed -i 改写
#   ~/.claude/CLAUDE.md 等用户文件，默认应 opt-in；提示用户显式 --apply 或 TASK_PLANNER_MIGRATE_REFS=1。
log "Phase 5: migrate external references (opt-in)"
dry "source lib/migrate-refs.sh; migrate_external_references --dry-run"
if [ "$DRY_RUN" -eq 0 ]; then
  export HOME
  export TASK_PLANNER_ROOT
  # shellcheck disable=SC1091
  source "$TASK_PLANNER_ROOT/lib/migrate-refs.sh"
  if [ "${TASK_PLANNER_MIGRATE_REFS:-0}" = "1" ]; then
    migrate_external_references --apply
  else
    migrate_external_references --dry-run
    log "  提示: 默认仅预览不改写。显式 opt-in: TASK_PLANNER_MIGRATE_REFS=1 bash install.sh 或直接调用 migrate_external_references --apply"
  fi
fi

# ─── Phase 5.5: Register hooks per tool ──────────────────────────────────
# [2026-11-25 task-skill-deploy-fix] A3: 职责澄清。Claude 用 settings.local.json 显式注册（install.sh patch）；
# ZCode 由 ~/.zcode/cli/config.json hooks.events 维护（用户/环境维护，install.sh 不自动改写全局 config）；
# opencode/cursor/continue 走 SKILL.md frontmatter 声明，由平台运行时自动注册。
log "Phase 5.5: register hooks for tools that need explicit config"
for tool in "${TOOLS_DETECTED[@]}"; do
  case "$tool" in
    claude-code)
      log "  Claude Code: patching ~/.claude/settings.local.json via register-hooks-cj.ts"
      dry "node --experimental-strip-types $HOME/.claude/skills/task-planner/scripts/register-hooks-cj.ts"
      if [ "$DRY_RUN" -eq 0 ]; then
        if command -v node >/dev/null 2>&1; then
          # [2026-11-25 task-skill-deploy-fix] What: 捕获 PIPESTATUS[0]，去掉 `| head -10`。Why: set -euo pipefail 下
          #   head 提前退出会误杀注册成功路径；注册语义非阻断，真实失败仅 WARNING，不 `|| true` 吞掉。
          _rc=0
          (cd "$HOME/.claude/skills/task-planner/scripts" && node --experimental-strip-types register-hooks-cj.ts) 2>&1 || _rc=$?
          if [ "$_rc" -ne 0 ]; then
            log "  WARNING: register-hooks-cj.ts exited $_rc (non-blocking)"
          fi
        else
          log "  WARNING: node not found, skipping Claude Code hook registration"
          log "           install node: https://nodejs.org (v22.6+ for --experimental-strip-types)"
          log "           then: node --experimental-strip-types ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts"
        fi
      fi
      ;;
    zcode)
      # [2026-11-25 task-skill-deploy-fix] A3: ZCode hooks 由 ~/.zcode/cli/config.json hooks.events 维护，
      # install.sh 不自动改写用户全局 config；提示用户确认/注册。
      log "  zcode: hooks 由 ~/.zcode/cli/config.json hooks.events 维护（用户/环境维护）"
      log "         install.sh 不自动改写全局 config；请确认 config.json 已注册 task-planner hooks"
      ;;
    opencode|cursor|continue)
      # Hooks are declared in SKILL.md frontmatter (installed in Phase 4)
      # and registered automatically by the platform runtime. No further action.
      log "  $tool: hooks registered via SKILL.md frontmatter (auto by platform)"
      ;;
  esac
done

# ─── Phase 5.6: Install companion files (agents + top-level peripheral skills) ──────
# companion/agents/ 存放随行 agents(plan-writer/article-batch-publisher/article-field-fixer/complex-planner/image-generation-executor/video-generation-executor);
# 外围 skill(task-drift-guard/plan-resume/todo-skill)位于仓库顶层 skills/,由
# install-companion.sh 统一分发。一键安装保证新机器装完 task-planner 即拥有全部依赖;
# 日常修改用 scripts/sync-companion.sh 拉回仓。
log "Phase 5.6: install companion files"
if [ -d "$TASK_PLANNER_ROOT/companion" ]; then
  DRY_RUN_ARG=""; [ "$DRY_RUN" -eq 1 ] && DRY_RUN_ARG="--dry-run"
  # [2026-11-25 task-skill-deploy-fix] What: 捕获 PIPESTATUS[0]，避免 sed 吞掉上游真实 rc。Why: set -euo pipefail
  #   下 sed 早退/SIGPIPE 会误杀；companion 安装语义非阻断，真实失败仅 WARNING。用 `|| _rc=${PIPESTATUS[0]}` 保持 PIPESTATUS 可见。
  _rc=0
  bash "$TASK_PLANNER_ROOT/lib/install-companion.sh" $DRY_RUN_ARG 2>&1 | sed 's/^/  /' || _rc=${PIPESTATUS[0]:-0}
  if [ "$_rc" -ne 0 ]; then
    log "  WARNING: install-companion.sh exited $_rc (non-blocking)"
  fi
else
  log "  no companion/ dir — skipping"
fi

# ─── Phase 5.7: provider fallback bind (best-effort, task-v055-fallback) ──
# 预探测本机可用 fallback 通道(agnes 等)并生成 <type>-fb 变体 agent;
# 任何失败只告警不阻塞安装(变体 agent 仅在新会话对 Agent 工具可见)
log "Phase 5.7: provider fallback bind (best-effort)"
if [ -f "$TASK_PLANNER_ROOT/../task-dispatch/scripts/subagent-fallback.sh" ]; then
  _FB_HOME="${ZCODE_HOME:-$HOME/.zcode}"
  if [ -d "$_FB_HOME/agents" ] && [ -f "$_FB_HOME/v2/config.json" ]; then
    bash "$TASK_PLANNER_ROOT/../task-dispatch/scripts/subagent-fallback.sh" probe --out "$_FB_HOME/agents/.last-probe.json" || true
    bash "$TASK_PLANNER_ROOT/../task-dispatch/scripts/subagent-fallback.sh" bind --zcode-home "$_FB_HOME" || log "  [warn] fallback bind 失败(非阻塞,不影响安装)"
  else
    log "  no $_FB_HOME/agents 或 v2/config.json — 跳过 fallback bind"
  fi
else
  log "  no subagent-fallback.sh — 跳过 Phase 5.7"
fi

# ─── Phase 6: Verify ────────────────────────────────────────────────────
if [ "$SKIP_VERIFY" -eq 0 ]; then
  log "Phase 6: verify installation"
  dry "source lib/verify.sh; verify_installation"
  if [ "$DRY_RUN" -eq 0 ]; then
    export TASK_PLANNER_ROOT
    # shellcheck disable=SC1091
    source "$TASK_PLANNER_ROOT/lib/verify.sh"
    if verify_installation; then
      log "✓ installation verified"
    else
      log "✗ verification failed (see above)"
      exit 1
    fi
  fi
fi

log "install complete. canonical: $TASK_PLANNER_ROOT"
log "next steps:"
log "  1. Restart your agent tool(s) to load hooks"
# [2026-11-25 task-skill-deploy-fix] A3: 修正矛盾措辞。Why: install.sh 已 patch settings.local.json（Phase 5.5），
#   "auto-registered" 易误解为无需 install.sh；实际是 install.sh 注册、重启生效。
log "  2. For Claude Code: hooks 已由 install.sh 写入 settings.local.json; restart Claude Code to apply"
