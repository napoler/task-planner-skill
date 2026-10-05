#!/usr/bin/env bash
# lib/detect-tools.sh — Detect installed agent tools and their skill locations
#
# Source this file; it populates:
#   TOOLS_DETECTED       — array of detected tool names
#   TOOL_STUB_ROOT_<X>   — stub directory for tool X
#   TOOL_HOOK_STYLE_<X>  — hook config style (claude-zhjson / zcode-yaml / ...)
#
# Returns exit 0 always (silent tools → silent skip).

set -u

# Canonical location assumption
: "${HOME:?HOME must be set}"

# Tool detection matrix: name | stub dir | hook style | probe path
TOOL_PROBES=(
  "claude-code|$HOME/.claude/skills/task-planner|claude-settings|$HOME/.claude"
  "zcode|$HOME/.zcode/skills/task-planner|zcode-frontmatter|$HOME/.zcode"
  # opencode 物理路径=~/.config/opencode；~/.opencode 为其 symlink 兼容入口
  # （2026-10-05 task-v131 审计 L-5 修正：原行为=探测/记录均用 ~/.opencode symlink 路径，
  #   symlink 缺失时探测误判工具未部署；改为物理路径后探测更稳健）
  "opencode|$HOME/.config/opencode/skills/task-planner|opencode-frontmatter|$HOME/.config/opencode"
  "cursor|$HOME/.cursor/skills/task-planner|cursor-frontmatter|$HOME/.cursor"
  "continue|$HOME/.continue/skills/task-planner|continue-frontmatter|$HOME/.continue"
)

TOOLS_DETECTED=()
declare -gA TOOL_STUB_ROOT
declare -gA TOOL_HOOK_STYLE

detect_tools() {
  for probe in "${TOOL_PROBES[@]}"; do
    IFS='|' read -r name stub_dir hook_style probe_path <<< "$probe"
    if [ -d "$probe_path" ]; then
      TOOLS_DETECTED+=("$name")
      TOOL_STUB_ROOT[$name]="$stub_dir"
      TOOL_HOOK_STYLE[$name]="$hook_style"
    fi
  done
}

# Run detection on source
detect_tools
