#!/usr/bin/env bash
# lib/install-stub.sh — Install per-tool thin stub that delegates to canonical
#
# Usage:
#   install_stub_for_tool <tool_name> <stub_dir>
#
# Effect:
#   - mkdir -p stub_dir
#   - rsync scripts/ → stub_dir/scripts/ (with sed-rewritten hardcoded paths)
#   - rsync references/ + templates/ + config.json → stub_dir/
#   - Write stub SKILL.md (template) with tool-specific frontmatter
#   - chmod +x scripts
#
# Idempotent: overwrites existing stub files. Caller is responsible for backup.

set -u

: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

# Per-tool SKILL.md frontmatter template generator
generate_stub_skill_md() {
  local tool_name="$1"
  local hook_style="$2"
  local out_path="$3"

  case "$hook_style" in
    claude-settings)
      # Claude Code uses settings.json hooks
      cat > "$out_path" <<'STUB_SKILL_EOF'
---
name: task-planner
description: 任务规划与进度追踪 | 计划文档 ↔ 原生 Todo 双向同步 | 漂移检测 | 冲突分析
model: opus
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
---

# task-planner — Claude Code 适配薄壳

> Canonical source: `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}`.
> 本薄壳只声明 Claude Code 平台特定的 hook 配置 + 路径解析契约。

## Hooks（Claude Code settings.json 风格）

复制到 `~/.claude/settings.local.json` 的 `hooks` 字段，或运行：
```bash
bun run $HOME/.claude/skills/task-planner/scripts/register-hooks-cj.ts
```

```json
{
  "hooks": {
    "SessionStart":     [{ "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/task-plan-init.cjs" }],
    "PreToolUse":       [{ "matcher": "Write|Edit", "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-scope.sh \"${CLAUDE_TOOL_NAME:-Write}\" \"${FILE_PATH:-}\"" }],
    "PostToolUse":      [{ "matcher": "Write|Edit", "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-doc-sync.sh" }],
    "UserPromptSubmit": [{ "command": "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/zcode-userpromptsubmit.sh" }],
    "Stop":             [{ "command": "SD=\"${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"$SD/check-complete.ps1\" 2>/dev/null || sh \"$SD/check-complete.sh\"" }]
  }
}
```

## 内容引用

| 资源 | 路径 |
|------|------|
| 核心规则 | `${TASK_PLANNER_ROOT}/references/critical-rules.md` |
| Todo 同步 | `${TASK_PLANNER_ROOT}/references/todo-sync.md` |
| 工作树隔离 | `${TASK_PLANNER_ROOT}/references/worktree-isolation.md` |
| 模板 | `${TASK_PLANNER_ROOT}/templates/` |

完整流程见 canonical 的 `README.md` + `WORKFLOW.md` + `examples.md`。
STUB_SKILL_EOF
      ;;

    zcode-frontmatter)
      cat > "$out_path" <<'STUB_SKILL_EOF'
---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
hooks:
- type: command
  name: SessionStart
  command: "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/task-plan-init.cjs"
  statusMessage: "Checking task plan status..."
- type: command
  name: PreToolUse
  matcher: "Write|Edit"
  command: "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-scope.sh"
  block_on_nonzero: true
- type: command
  name: PostToolUse
  command: "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/check-doc-sync.sh"
  statusMessage: "[task-planner] 计划/Todo 同步检查..."
- type: command
  name: UserPromptSubmit
  command: "bash ${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/zcode-userpromptsubmit.sh"
  statusMessage: "[task-planner] 新指令计划影响提示..."
- type: command
  name: Stop
  command: "SD=\"${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"$SD/check-complete.ps1\" 2>/dev/null || sh \"$SD/check-complete.sh\""
model: opus
---

# task-planner — ZCode 适配薄壳

> Canonical source: `${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}`.
> 本薄壳只声明 ZCode 平台特定的 hook 配置（通过 SKILL.md frontmatter）。

## 内容引用

| 资源 | 路径 |
|------|------|
| 核心规则 | `${TASK_PLANNER_ROOT}/references/critical-rules.md` |
| Todo 同步 | `${TASK_PLANNER_ROOT}/references/todo-sync.md` |
| 工作树隔离 | `${TASK_PLANNER_ROOT}/references/worktree-isolation.md` |
| 模板 | `${TASK_PLANNER_ROOT}/templates/` |
STUB_SKILL_EOF
      ;;

    opencode-frontmatter|cursor-frontmatter|continue-frontmatter)
      # Generic frontmatter-stub for platforms with similar hook-via-SKILL mechanism
      cat > "$out_path" <<STUB_SKILL_EOF
---
name: task-planner
description: 任务规划与进度追踪（${tool_name} 适配薄壳）
model: opus
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
---

# task-planner — ${tool_name} 适配薄壳

> Canonical source: \`\${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}\`。
> 本薄壳只持有 hook 入口（按 ${hook_style} 规范）。

## 平台说明

${tool_name} 的 hook 配置请参考平台官方文档，将以下命令注册到对应 hook 点：
- SessionStart:    bash \${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}/scripts/task-plan-init.cjs
- PreToolUse:      bash \${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}/scripts/check-scope.sh
- PostToolUse:     bash \${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}/scripts/check-doc-sync.sh
- UserPromptSubmit: bash \${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}/scripts/zcode-userpromptsubmit.sh
- Stop:            bash \${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}/scripts/check-complete.sh
STUB_SKILL_EOF
      ;;

    *)
      echo "[install-stub] unknown hook style '$hook_style' for $tool_name" >&2
      return 1
      ;;
  esac
}

# sed-rewrite hardcoded paths in scripts (idempotent: only acts on unrewritten files)
rewrite_paths_in_scripts() {
  local stub_dir="$1"

  # Order matters: replace .zcode first (more specific), then .claude
  find "$stub_dir/scripts" -type f \( -name "*.sh" -o -name "*.cjs" -o -name "*.ps1" -o -name "*.ts" \) -print0 2>/dev/null | \
    while IFS= read -r -d '' file; do
      # Only rewrite if the file still has hardcoded zcode path (idempotency)
      if grep -q '\$HOME/\.zcode/skills/task-planner\|/home/.*/\.zcode/skills/task-planner' "$file" 2>/dev/null; then
        sed -i \
          -e 's|"\${OPENCODE_SKILL_ROOT:-\$HOME/\.zcode/skills/task-planner}"|"\${TASK_PLANNER_ROOT:-\$HOME/dev/task-planner}"|g' \
          -e 's|node /home/.*/\.zcode/skills/task-planner/scripts/|node "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g' \
          -e 's|bash "/home/.*/\.zcode/skills/task-planner/scripts/|bash "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g' \
          -e 's|bash ~/\.zcode/skills/task-planner/scripts/|bash "${TASK_PLANNER_ROOT:-$HOME/dev/task-planner}/scripts/|g' \
          "$file"
      fi
    done
}

install_stub_for_tool() {
  local tool_name="$1"
  local stub_dir="$2"
  local hook_style="$3"

  echo "[install-stub] $tool_name → $stub_dir"

  mkdir -p "$stub_dir/scripts"

  # Rsync content dirs (exclude SKILL.md, we'll generate it)
  rsync -a --exclude='SKILL.md' --exclude='lib/' --exclude='tests/' --exclude='docs/' --exclude='install.sh' --exclude='uninstall.sh' \
    "${TASK_PLANNER_ROOT}/" "${stub_dir}/" 2>/dev/null

  # Generate tool-specific SKILL.md (overwrites canonical's stripped version)
  generate_stub_skill_md "$tool_name" "$hook_style" "${stub_dir}/SKILL.md"

  # Rewrite hardcoded paths in scripts
  rewrite_paths_in_scripts "$stub_dir"

  # chmod +x scripts
  chmod +x "${stub_dir}/scripts/"*.sh "${stub_dir}/scripts/"*.cjs "${stub_dir}/scripts/"*.ts 2>/dev/null

  echo "[install-stub] $tool_name stub installed"
}
