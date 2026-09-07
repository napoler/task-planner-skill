#!/usr/bin/env bash
# install.sh — Multi-tool task-planner auto-installer
#
# Usage:
#   bash install.sh [--canonical <path>] [--tools claude,zcode,opencode,...] [--no-verify] [--no-backup] [--dry-run]
#
# What it does:
#   1. Pre-flight: checks git/bun/jq availability
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

set -uo pipefail

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
    git clone "$SCRIPT_DIR" "$TASK_PLANNER_ROOT" 2>&1 | head -3
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

# ─── Phase 5: Migrate external references ───────────────────────────────
log "Phase 5: migrate external references"
dry "source lib/migrate-refs.sh; migrate_external_references"
if [ "$DRY_RUN" -eq 0 ]; then
  export HOME
  export TASK_PLANNER_ROOT
  # shellcheck disable=SC1091
  source "$TASK_PLANNER_ROOT/lib/migrate-refs.sh"
  migrate_external_references
fi

# ─── Phase 5.5: Register hooks per tool ──────────────────────────────────
# Claude Code requires explicit settings.json patch; other platforms read
# hooks from SKILL.md frontmatter (auto-registered). This phase ensures
# Claude Code is always re-registered after stub install/update.
log "Phase 5.5: register hooks for tools that need explicit config"
for tool in "${TOOLS_DETECTED[@]}"; do
  case "$tool" in
    claude-code)
      log "  Claude Code: patching ~/.claude/settings.local.json via register-hooks-cj.ts"
      dry "bun run $HOME/.claude/skills/task-planner/scripts/register-hooks-cj.ts"
      if [ "$DRY_RUN" -eq 0 ]; then
        if command -v bun >/dev/null 2>&1; then
          (cd "$HOME/.claude/skills/task-planner/scripts" && bun run register-hooks-cj.ts) 2>&1 | head -10
        else
          log "  WARNING: bun not found, skipping Claude Code hook registration"
          log "           install bun: curl -fsSL https://bun.sh/install | bash"
          log "           then: bun run ~/.claude/skills/task-planner/scripts/register-hooks-cj.ts"
        fi
      fi
      ;;
    zcode|opencode|cursor|continue)
      # Hooks are declared in SKILL.md frontmatter (installed in Phase 4)
      # and registered automatically by the platform runtime. No further action.
      log "  $tool: hooks registered via SKILL.md frontmatter (auto by platform)"
      ;;
  esac
done

# ─── Phase 5.6: Install companion files (agents + top-level peripheral skills) ──────
# companion/agents/ 存放随行 agents(plan-writer/article-batch-publisher/article-field-fixer);
# 外围 skill(task-drift-guard/plan-resume/todo-skill)位于仓库顶层 skills/,由
# install-companion.sh 统一分发。一键安装保证新机器装完 task-planner 即拥有全部依赖;
# 日常修改用 scripts/sync-companion.sh 拉回仓。
log "Phase 5.6: install companion files"
if [ -d "$TASK_PLANNER_ROOT/companion" ]; then
  DRY_RUN_ARG=""; [ "$DRY_RUN" -eq 1 ] && DRY_RUN_ARG="--dry-run"
  bash "$TASK_PLANNER_ROOT/lib/install-companion.sh" $DRY_RUN_ARG 2>&1 | sed 's/^/  /'
else
  log "  no companion/ dir — skipping"
fi

# ─── Phase 5.7: provider fallback bind (best-effort, task-v055-fallback) ──
# 预探测本机可用 fallback 通道(agnes 等)并生成 <type>-fb 变体 agent;
# 任何失败只告警不阻塞安装(变体 agent 仅在新会话对 Agent 工具可见)
log "Phase 5.7: provider fallback bind (best-effort)"
if [ -f "$TASK_PLANNER_ROOT/scripts/subagent-fallback.sh" ]; then
  _FB_HOME="${ZCODE_HOME:-$HOME/.zcode}"
  if [ -d "$_FB_HOME/agents" ] && [ -f "$_FB_HOME/v2/config.json" ]; then
    bash "$TASK_PLANNER_ROOT/scripts/subagent-fallback.sh" probe --out "$_FB_HOME/agents/.last-probe.json" || true
    bash "$TASK_PLANNER_ROOT/scripts/subagent-fallback.sh" bind --zcode-home "$_FB_HOME" || log "  [warn] fallback bind 失败(非阻塞,不影响安装)"
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
log "  2. For Claude Code: hooks are auto-registered; restart Claude Code to apply"
