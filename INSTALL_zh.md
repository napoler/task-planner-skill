# 安装 task-planner

两种安装路径：**LLM 自动安装**（将代码块粘贴到 AI 提示词中）或**手动安装**（手动执行命令）。安装脚本按 `lib/detect-tools.sh` 自动检测本机已装工具（claude-code / zcode / opencode / cursor / continue 五工具），为每个检测到的工具安装对应位置的软壳（多工具软壳模型，非单一目标目录）。

> **安装后效果：** `task-planner` Skill 会被 Claude Code / ZCode / OpenCode 等已装工具自动发现。安装完成后，重启工具，然后让它规划一个多步骤任务即可。

---

## LLM 自动安装

**适用于 AI 代理（或请 AI 帮你安装的真人）：** 将下方代码块复制粘贴到你的 LLM 中，它会在一次 Shell 调用中完成安装、验证并报告结果。

```bash
# 一键安装 task-planner Skill
# 在任何 Shell 中运行；安装脚本自动检测已装工具（claude-code / zcode / opencode 等）并为各工具安装对应软壳
set -e
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/napoler/task-planner-skill.git "$TMP/repo"
cd "$TMP/repo"
bash skills/task-planner/install.sh
cd ~
rm -rf "$TMP"
echo "安装完成。重启 Claude Code，然后让它规划一个多步骤任务。"
```

> 如果已有本地 clone，可直接使用本地路径：
>
> ```bash
> bash /path/to/task-planner-skill/skills/task-planner/install.sh
> ```

**LLM 还应了解的变体命令：**

```bash
# 干运行（预览将要执行的操作，不实际写入）
bash skills/task-planner/install.sh --dry-run

# 指定目标工具（默认自动检测五工具：claude-code/zcode/opencode/cursor/continue）
bash skills/task-planner/install.sh --tools claude-code,zcode,opencode

# 卸载
bash skills/task-planner/uninstall.sh
# 或干运行预览：
bash skills/task-planner/uninstall.sh --dry-run

# 重新验证已有安装
bash skills/task-planner/lib/verify.sh
```

如果 LLM 遇到 `Permission denied` 无法写入工具目录（如 `~/.claude/skills/` 或 `~/.zcode/skills/`），可先 `chmod` 修复父目录权限，或用 `TASK_PLANNER_ROOT` 环境变量/`--canonical <路径>` 将规范源指向用户可写位置再安装。

---

## 手动安装

### 前置依赖

| 工具 | 用途 | 检查命令 |
|------|------|----------|
| `bash` ≥ 4 | 所有安装脚本均为 bash 编写 | `bash --version` |
| `bun` 或 `node` ≥ 18 | `session-catchup.ts` 等 .ts/.cjs 脚本运行 | `bun --version` 或 `node --version` |
| `jq` | 校验脚本（verify.sh 部分检查） | `jq --version` |
| `git` | 克隆仓库 | `git --version` |
| 对 `~/.claude/skills/` 的写权限 | 安装目标 | `mkdir -p ~/.claude/skills && test -w ~/.claude/skills` |

可选依赖：
- `node` + `npx` + `@types/node` —— 仅当你需要对 `sync-ide-folders.ts` 做完整 TypeScript 类型检查时才需要
- `jsonschema` Python 模块 —— 仅当你需要对 config.json 做严格 Schema 验证时才需要（`pip install jsonschema`）

### Linux / macOS / WSL

```bash
# 1. 克隆仓库
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill

# 2. （可选）预览 install.sh 将要做什么
bash skills/task-planner/install.sh --dry-run

# 3. 安装（自动检测已装工具并安装对应软壳）
bash skills/task-planner/install.sh

# 4. 验证安装
bash skills/task-planner/lib/verify.sh

# 5. 重启 Claude Code，然后：
#    让 Claude 规划一个多步骤任务，或使用 Skill 工具。
```

#### 多工具软壳模型

安装脚本不是单一目标目录安装，而是按 `lib/detect-tools.sh` 检测本机已装工具（claude-code / zcode / opencode / cursor / continue 五工具探测），为每个检测到的工具安装对应位置的软壳（如 `~/.claude/skills/task-planner/`、`~/.zcode/skills/task-planner/`）。可用参数：

```bash
# 仅安装到指定工具子集
bash skills/task-planner/install.sh --tools claude-code,zcode

# 跳过备份已有软壳 / 跳过安装后验证
bash skills/task-planner/install.sh --no-backup --no-verify

# 指定规范源位置（默认=install.sh 所在目录）
bash skills/task-planner/install.sh --canonical /path/to/task-planner-skill/skills/task-planner
```

#### 验证安装

```bash
# 确认 Skill 文件存在且可执行
ls -la ~/.claude/skills/task-planner/SKILL.md
ls -la ~/.claude/skills/task-planner/scripts/*.sh

# 显式运行验证器
bash skills/task-planner/lib/verify.sh
# 预期输出：[verify] summary: N pass / 0 fail
```

### Windows（原生 PowerShell）

> Skill 内已包含 PowerShell 镜像（`init-session.ps1`、`check-complete.ps1`）。仓库级安装器以 bash 为主。在原生 Windows 上，推荐使用 **WSL** 或 **Git Bash**。如果必须在 PowerShell 中操作：

```powershell
# 从 PowerShell 克隆仓库后：
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill

# 使用 Git Bash 运行安装器（Git for Windows 自带 Git Bash）
& "C:\Program Files\Git\bin\bash.exe" skills/task-planner/install.sh

# 用同样方式验证
& "C:\Program Files\Git\bin\bash.exe" skills/task-planner/lib/verify.sh
```

#### WSL（Windows 用户推荐方案）

WSL 是 Windows 下最顺畅的安装路径——bash 脚本无需任何修改即可运行。

```powershell
# 在 PowerShell 中安装 WSL（如未安装）：
wsl --install -d Ubuntu
```

```bash
# 在 WSL 中：
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill
bash skills/task-planner/install.sh
```

WSL 中的 Claude Code 会自动通过 `$HOME/.claude/skills/task-planner/SKILL.md` 发现 Skill。

---

## 升级

将已有安装升级到新版本：

```bash
# 在本地 clone 中执行
git pull
bash skills/task-planner/install.sh   # 重新安装（自动覆盖已有软壳）
bash skills/task-planner/lib/verify.sh          # 确认安装正常
```

Skill 目录本身是无状态的，升级不会保留任何自定义内容。你的**计划文件**（位于 `plans/` 目录）不受影响——它们在项目目录中，不在 Skill 安装路径。

---

## 卸载

```bash
# 默认：卸载所有已检测工具的软壳
bash skills/task-planner/uninstall.sh

# 先干运行预览
bash skills/task-planner/uninstall.sh --dry-run

# 保留规范源 / 保留备份目录
bash skills/task-planner/uninstall.sh --keep-canonical --keep-backups
```

卸载器按 `lib/detect-tools.sh` 检测已装工具，逐个移除各工具软壳目录，再移除规范源与备份（可用 `--keep-canonical` / `--keep-backups` 保留），不影响其他 Skill。外部引用迁移（CLAUDE.md / commands/*.md）不会被自动回退，如需恢复旧路径须手动处理。

---

## 项目模板覆盖

如需在**本项目的**项目中覆盖内置模板，只需将替换文件放入：

```
<你的项目>/.claude/plan-templates/
    task_plan.md
    verification.md
    findings.md
    progress.md
    notepad-learnings.md
```

`init-session.sh` 优先查找项目级模板文件夹；缺失的模板自动回退到内置版本。

---

## 故障排查

### 写入工具目录（如 `~/.claude/skills/`）时权限被拒绝

```bash
# 方案一：修复父目录权限后重装
mkdir -p ~/.claude/skills
chmod u+rwX ~/.claude/skills
bash skills/task-planner/install.sh

# 方案二：跳过该工具，只装可写路径对应的工具
bash skills/task-planner/install.sh --tools zcode,opencode

# 方案三：规范源指向用户可写位置
TASK_PLANNER_ROOT=/path/to/task-planner-skill/skills/task-planner bash skills/task-planner/install.sh
```

### 对 .ts 脚本做 TypeScript 检查时报警告

如果你未安装 `@types/node`，这是预期行为。TS 类型错误不会阻断安装/校验。要消除警告：

```bash
npm install --save-dev @types/node
```

### `bash: skills/task-planner/install.sh: No such file or directory`

你可能没有 `cd` 到仓库目录。先 `cd task-planner-skill`，或传入绝对路径：

```bash
bash /absolute/path/to/task-planner-skill/skills/task-planner/install.sh
```

### 安装后 Skill 未被发现

1. 确认软壳存在：`ls ~/.claude/skills/task-planner/SKILL.md`（或对应工具目录，如 `~/.zcode/skills/task-planner/`）
2. 重启工具（或运行 `/clear`）—— Skill 目录在启动时扫描
3. 确认 SKILL.md 的 frontmatter 中包含 `name: task-planner`（区分大小写）

### `config.json` Schema 验证失败

如果你自定义了 `config.json` 且校验（`lib/verify.sh` 或独立 schema 检查）报告 Schema 错误：

```bash
# 可选：用 Python 严格校验（需 jsonschema 模块）
python3 -c "
import json, jsonschema
schema = json.load(open('skills/task-planner/config.json'))
schema.pop('\$schema', None)
jsonschema.validate({}, schema)   # 测试必填项和默认值
"
```

Schema 强制 `additionalProperties: false` —— 多余键会直接报错。删除未知键或谨慎更新 Schema。

---

## 安装后冒烟测试

```bash
# 1. Skill 文件存在
test -f ~/.claude/skills/task-planner/SKILL.md && echo OK || echo MISSING

# 2. 脚本可执行
for f in init-session.sh check-scope.sh sync-todos.sh check-complete.sh; do
  test -x ~/.claude/skills/task-planner/scripts/$f && echo "  $f: OK"
done

# 3. 验证器通过
bash skills/task-planner/lib/verify.sh

# 4. 端到端：启动一个测试计划
mkdir -p /tmp/planner-smoke && cd /tmp/planner-smoke
bash ~/.claude/skills/task-planner/scripts/init-session.sh smoke-test
# 或用环境变量指定模板类型（task-v074 起）:
TASK_TEMPLATE_TYPE=bugfix bash ~/.claude/skills/task-planner/scripts/init-session.sh smoke-test
ls task_plan.md   # 应存在
```

如有任何步骤失败，请参见上方故障排查。

---

## 安装内容清单

```
~/.claude/skills/task-planner/   （软壳指向规范源 skills/task-planner/；下列以规范源为准）
├── SKILL.md                       (入口文件)
├── config.json                    (JSON-Schema 阈值配置, 40 键)
├── reference.md                   (Manus 原则 + Chain Handoff Contract)
├── examples.md                    (实战示例)
├── scripts/                       (81 项: .sh 72 个（含 42 selftest）;
│   │                               另有 .ps1/.ts/.cjs 镜像与 lib/ 辅助)
├── templates/                     (39 个模板: 顶层 10 个 md
│   │                               （task_plan / verification / findings / progress /
│   │                                notepad-learnings / knowledge-brief /
│   │                                subagent_dispatch / shared-tracker / batch_report /
│   │                                delivery-summary）
│   │                               + variant/ 29 类 template_type 变体
│   │                                （*-*-type.md，含 video/image 家族 12 类）)
├── references/                    (8 个: critical-rules / completion-gate / goal-gate /
│   │                               dispatch-examples / methodology / todo-sync /
│   │                               worktree-isolation / batch-quality-gate)
└── companion/agents/              (3 个配套 agent: plan-writer /
                                     article-batch-publisher / article-field-fixer,
                                     部署到 ~/.zcode/agents/ 等)
```

> 实际清单以 `ls -R skills/task-planner/` 为准（2026-10-02 实测：39 个模板、29 类 variant、81 项 scripts、8 个 references）；companion agent 变更后需重跑 `lib/install-companion.sh` 或定向 cp 到各平台 agents/ 目录。

总大小约 2.0 MB（2026-10-02 `du -sh` 实测），安装过程不会在 Skill 目录外写入任何内容。

---

## English Version

[English Install Guide](skills/task-planner/INSTALL.md) · [English README](skills/task-planner/README.md)

---

## 激活方式

重启 Claude Code 后，Skill 会自动发现。可以通过三种方式激活：

### 斜杠命令（推荐）

```
/task-planner         # 创建或恢复任务计划
/task-drift-guard     # 对当前计划运行漂移检测
/todo                 # 通过 todo-skill 创建持久化待办
```

### 自然语言触发

| 触发词 | 效果 |
|--------|------|
| `"帮我规划一个多步骤任务"` / `"plan a multi-step task"` | 加载 task-planner skill |
| `"检查漂移"` / `"check drift"` | 运行 task-drift-guard |
| `"拆解这个任务"` / `"break this down"` | 创建待办列表并执行 |

### 通过 Skill 工具调用

```python
Skill(skill="task-planner")
```

### 快速冒烟测试

```bash
# 重启后，在 Claude Code 聊天框中粘贴：
"帮我规划一个任务：创建一个带添加、列表、删除功能的 TODO 应用。"
```

你应该看到 Claude 自动在 `plans/task-XXX/task_plan.md` 中创建包含 Phases 和 VC 表的计划。

## 下一步

- 详见 [`README_zh.md`](README_zh.md) 功能概览和快速心智模型
- 详见 [`examples/full-workflow.md`](examples/full-workflow.md) 端到端演示
- 详见 [`skills/task-planner/reference.md`](skills/task-planner/reference.md) 设计原理
