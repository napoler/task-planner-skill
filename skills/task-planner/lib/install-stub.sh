#!/usr/bin/env bash
# lib/install-stub.sh — Install a full copy of task-planner (scripts/references/templates/config)
# into each host stub dir.
#
# [task-v131 M-1, 2026-10-05] 口径修正 (Rule 45): 原头注释「Install per-tool thin stub that
# delegates to canonical」与实盘不符——对齐审计 (memory/align-audit-2026-10-05.md M-1) 核实
# 实盘=全量副本同步: 安装源=本仓 skills/task-planner/, 四位宿主位
# (~/.zcode / ~/.claude / ~/.config/opencode / ~/.cursor 下 skills/task-planner/) 均为全量副本,
# 无指针引用薄壳形态。本次改描述文字; 「stub」保留为脚本/函数命名历史术语, 不改文件名与函数名。
#
# Usage:
#   install_stub_for_tool <tool_name> <stub_dir>
#
# Effect:
#   - mkdir -p stub_dir
#   - rsync scripts/ → stub_dir/scripts/ (with sed-rewritten hardcoded paths)
#   - rsync references/ + templates/ + config.json → stub_dir/
#   [task-v131 M-1, 2026-10-05] 口径注: 上述 rsync 即全量副本同步 (安装源=本仓
#   skills/task-planner/, 四位宿主位均为完整副本, 非指针引用薄壳);
#   「stub_dir」为脚本命名历史术语, 保留。
#   - rsync 4 satellite skills (plan-research-router/plan-template-kit/
#     plan-cost-guard/plan-collab-router) whole-dir → stub 位同级 skills/<sat>/
#     [task-v095 P7 扩展; 卫星无 scripts/config 无需 sed 重写; 源缺失则跳过]
#   - Write stub SKILL.md (template) with tool-specific frontmatter
#   - chmod +x scripts
#
# Idempotent: overwrites existing stub files. Caller is responsible for backup.

set -u

: "${TASK_PLANNER_ROOT:?TASK_PLANNER_ROOT must be set}"

# [task-v095 P7] 卫星技能: 仓库顶层 skills/ 下 4 个卫星目录(零 config 零 hook 零硬编码路径),
# 随 task-planner 安装到各工具位同级位置(<tool_root>/skills/<sat>/); 卫星无 scripts/config,
# sed 重写不适用, 整目录 rsync 全量复制即最小 diff 方案(找不到目录则跳过, 向后兼容不阻塞)
SATELLITE_SKILLS=(plan-research-router plan-template-kit plan-cost-guard plan-collab-router)

# Per-tool SKILL.md frontmatter template generator
generate_stub_skill_md() {
  local tool_name="$1"
  local hook_style="$2"
  local out_path="$3"

  case "$hook_style" in
    claude-settings)
      # Claude Code uses settings.json hooks
      # Use install-stub.sh's own TASK_PLANNER_ROOT as the env-var default
      local FALLBACK="${TASK_PLANNER_ROOT}"
      cat > "$out_path" <<STUB_SKILL_EOF
---
name: task-planner
description: 任务规划与进度追踪 | 计划文档 ↔ 原生 Todo 双向同步 | 漂移检测 | 冲突分析
model: opus
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
---

# task-planner — Claude Code 适配薄壳

> Canonical source: \`\${TASK_PLANNER_ROOT:-${FALLBACK}}\`。
> 本薄壳只声明 Claude Code 平台特定的 hook 配置 + 路径解析契约。

## Hooks（Claude Code settings.json 风格）

复制到 \`~/.claude/settings.local.json\` 的 \`hooks\` 字段，或运行：
\`\`\`bash
bun run \$TASK_PLANNER_ROOT/scripts/register-hooks-cj.ts
\`\`\`

\`\`\`json
{
  "hooks": {
    "SessionStart":     [{ "command": "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/task-plan-init.cjs" }],
    "PreToolUse":       [{ "matcher": "Write|Edit", "command": "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-scope.sh \"\${CLAUDE_TOOL_NAME:-Write}\" \"\${FILE_PATH:-}\"" }],
    "PostToolUse":      [{ "matcher": "Write|Edit", "command": "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-doc-sync.sh" }],
    "UserPromptSubmit": [{ "command": "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/zcode-userpromptsubmit.sh" }],
    "Stop":             [{ "command": "SD=\"\${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"\$SD/check-complete.ps1\" 2>/dev/null || sh \"\$SD/check-complete.sh\"" }]
  }
}
\`\`\`

## 内容引用

| 资源 | 路径 |
|------|------|
| 核心规则 | `${TASK_PLANNER_ROOT}/references/critical-rules.md` |
| Todo 同步 | `${TASK_PLANNER_ROOT}/references/todo-sync.md` |
| 工作树隔离 | `${TASK_PLANNER_ROOT}/references/worktree-isolation.md` |
| 模板 | `${TASK_PLANNER_ROOT}/templates/` |

完整流程见 canonical 的 `README.md` + `examples.md`。
STUB_SKILL_EOF
      ;;

    zcode-frontmatter)
      local FALLBACK="${TASK_PLANNER_ROOT}"
      cat > "$out_path" <<STUB_SKILL_EOF
---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
hooks:
- type: command
  name: SessionStart
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/task-plan-init.cjs"
  statusMessage: "Checking task plan status..."
- type: command
  name: PreToolUse
  matcher: "Write|Edit"
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-scope.sh"
  block_on_nonzero: true
- type: command
  name: PostToolUse
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-doc-sync.sh"
  statusMessage: "[task-planner] 计划/Todo 同步检查..."
- type: command
  name: UserPromptSubmit
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/zcode-userpromptsubmit.sh"
  statusMessage: "[task-planner] 新指令计划影响提示..."
- type: command
  name: Stop
  command: "SD=\"\${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"\$SD/check-complete.ps1\" 2>/dev/null || sh \"\$SD/check-complete.sh\""
model: opus
---

# task-planner — ZCode 适配薄壳

> Canonical source: \`\${TASK_PLANNER_ROOT:-${FALLBACK}}\`。
> 本薄壳只声明 ZCode 平台特定的 hook 配置（通过 SKILL.md frontmatter）。

## 内容引用

| 资源 | 路径 |
|------|------|
| 核心规则 | \`\${TASK_PLANNER_ROOT}/references/critical-rules.md\` |
| Todo 同步 | \`\${TASK_PLANNER_ROOT}/references/todo-sync.md\` |
| 工作树隔离 | \`\${TASK_PLANNER_ROOT}/references/worktree-isolation.md\` |
| 模板 | \`\${TASK_PLANNER_ROOT}/templates/\` |
STUB_SKILL_EOF
      ;;

    opencode-frontmatter|cursor-frontmatter|continue-frontmatter)
      # Generic frontmatter-stub for platforms with similar hook-via-SKILL mechanism
      local FALLBACK="${TASK_PLANNER_ROOT}"
      cat > "$out_path" <<STUB_SKILL_EOF
---
name: task-planner
agent: executor
description: Use when planning, decomposing, or organizing multi-step projects or research tasks expected to require more than 5 tool calls. Also use when resuming work after /clear.
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"
user-invocable: true
hooks:
- type: command
  name: SessionStart
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/task-plan-init.cjs"
  statusMessage: "Checking task plan status..."
- type: command
  name: PreToolUse
  matcher: "Write|Edit"
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-scope.sh"
  block_on_nonzero: true
- type: command
  name: PostToolUse
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-doc-sync.sh"
  statusMessage: "[task-planner] 计划/Todo 同步检查..."
- type: command
  name: UserPromptSubmit
  command: "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/zcode-userpromptsubmit.sh"
  statusMessage: "[task-planner] 新指令计划影响提示..."
- type: command
  name: Stop
  command: "SD=\\"\${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts\\"; powershell.exe -NoProfile -ExecutionPolicy Bypass -File \\"\$SD\\"/check-complete.ps1 2>/dev/null || sh \\"\$SD\\"/check-complete.sh"
model: opus
---

# task-planner — ${tool_name} 适配薄壳

> Canonical source: \`\${TASK_PLANNER_ROOT:-${FALLBACK}}\`。
> 本薄壳通过 SKILL.md frontmatter hooks 块声明 ${tool_name} 平台特定的 hook 配置。

## 内容引用

| 资源 | 路径 |
|------|------|
| 核心规则 | \`\${TASK_PLANNER_ROOT}/references/critical-rules.md\` |
| Todo 同步 | \`\${TASK_PLANNER_ROOT}/references/todo-sync.md\` |
| 工作树隔离 | \`\${TASK_PLANNER_ROOT}/references/worktree-isolation.md\` |
| 模板 | \`\${TASK_PLANNER_ROOT}/templates/\` |

> 完整流程见 canonical 的 \`README.md\` + \`examples.md\`。

## 平台兼容性

若 ${tool_name} 不识别 SKILL.md frontmatter 的 \`hooks:\` 字段（与 zcode/opencode 不同的 hook 注册机制），需手动配置：

\`\`\`json
// ${tool_name} 配置示例（路径因平台而异）
{
  "hooks": {
    "SessionStart":    "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/task-plan-init.cjs",
    "PreToolUse":      "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-scope.sh",
    "PostToolUse":     "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-doc-sync.sh",
    "UserPromptSubmit": "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/zcode-userpromptsubmit.sh",
    "Stop":            "bash \${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/check-complete.sh"
  }
}
\`\`\`

> 请参考 ${tool_name} 官方文档适配实际配置语法。
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
          -e 's|"\${OPENCODE_SKILL_ROOT:-\$HOME/\.zcode/skills/task-planner}"|"\${TASK_PLANNER_ROOT:-${FALLBACK}}"|g' \
          -e 's|node /home/.*/\.zcode/skills/task-planner/scripts/|node "${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/|g' \
          -e 's|bash "/home/.*/\.zcode/skills/task-planner/scripts/|bash "${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/|g' \
          -e 's|bash ~/\.zcode/skills/task-planner/scripts/|bash "${TASK_PLANNER_ROOT:-${FALLBACK}}/scripts/|g' \
          "$file"
      fi
    done
}

# [task-v095 P7] 卫星技能整目录安装: 仓库顶层 skills/ 下 4 个卫星(零 scripts/config/hook,
# 无硬编码路径)随 task-planner 同步到各工具位同级 skills/<sat>/; 全量 rsync 即最小 diff 方案
# (无需 sed 重写); 源目录缺失(如非 canonical 运行)则跳过, 不阻塞主安装
install_satellite_skills() {
  local stub_dir="$1"
  local repo_skills target_skills_dir
  repo_skills="$(cd "$(dirname "$(dirname "$TASK_PLANNER_ROOT")")" 2>/dev/null && pwd)/skills"
  target_skills_dir="$(dirname "$stub_dir")"
  [ -d "$repo_skills" ] || return 0
  for sat in "${SATELLITE_SKILLS[@]}"; do
    local src="$repo_skills/$sat" dst="$target_skills_dir/$sat"
    if [ ! -d "$src" ]; then
      echo "[install-stub] satellite $sat not found under $repo_skills — skip"
      continue
    fi
    [ "$src" -ef "$dst" ] && continue   # 源与目标同目录(部署副本重跑)幂等跳过
    rsync -a "$src/" "$dst/" 2>/dev/null
    echo "[install-stub] satellite $sat → $dst"
  done
}

install_stub_for_tool() {
  local tool_name="$1"
  local stub_dir="$2"
  local hook_style="$3"

  echo "[install-stub] $tool_name → $stub_dir"

  mkdir -p "$stub_dir/scripts"

  # Rsync content dirs (exclude SKILL.md, we'll generate it)
  # [task-v131 M-1, 2026-10-05] 口径修正 (Rule 45): 原口径把宿主位描述为「thin stub」,
  # 实盘=全量副本同步: 安装源=${TASK_PLANNER_ROOT}(本仓 skills/task-planner/) 全量 rsync 到
  # 四位宿主位 (~/.zcode / ~/.claude / ~/.config/opencode / ~/.cursor 的 skills/task-planner/),
  # 宿主位是完整副本而非指向 canonical 的指针薄壳; 下方 sed 重写只是副本内的路径本地化。
  rsync -a --exclude='SKILL.md' --exclude='lib/' --exclude='tests/' --exclude='docs/' --exclude='install.sh' --exclude='uninstall.sh' \
    "${TASK_PLANNER_ROOT}/" "${stub_dir}/" 2>/dev/null

  # [task-v095 P7] 4 卫星技能整目录安装到工具位同级 skills/ 目录
  install_satellite_skills "$stub_dir"

  # Generate tool-specific SKILL.md (overwrites canonical's stripped version)
  generate_stub_skill_md "$tool_name" "$hook_style" "${stub_dir}/SKILL.md"

  # Rewrite hardcoded paths in scripts
  rewrite_paths_in_scripts "$stub_dir"

  # chmod +x scripts
  chmod +x "${stub_dir}/scripts/"*.sh "${stub_dir}/scripts/"*.cjs "${stub_dir}/scripts/"*.ts 2>/dev/null

  echo "[install-stub] $tool_name stub installed"
}
