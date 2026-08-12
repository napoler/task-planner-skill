# 安装 task-planner

两种安装路径：**LLM 自动安装**（将代码块粘贴到 AI 提示词中）或**手动安装**（手动执行命令）。两种方式最终都安装到 `~/.claude/skills/task-planner/SKILL.md`（或自定义目标路径）。

> **安装后效果：** `task-planner` Skill 会被 Claude Code / OpenCode 自动发现。安装完成后，重启 Claude Code，然后让它规划一个多步骤任务即可。

---

## LLM 自动安装

**适用于 AI 代理（或请 AI 帮你安装的真人）：** 将下方代码块复制粘贴到你的 LLM 中，它会在一次 Shell 调用中完成安装、验证并报告结果。

```bash
# 一键安装 task-planner Skill
# 在任何 Shell 中运行；默认安装到 ~/.claude/skills/task-planner/
set -e
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/napoler/task-planner-skill.git "$TMP/repo"
cd "$TMP/repo"
bash scripts/install.sh
cd ~
rm -rf "$TMP"
echo "安装完成。重启 Claude Code，然后让它规划一个多步骤任务。"
```

> 如果已有本地 clone，可直接使用本地路径：
>
> ```bash
> bash /path/to/task-planner-skill/scripts/install.sh
> ```

**LLM 还应了解的变体命令：**

```bash
# 安装到自定义目标路径（适合测试）
bash scripts/install.sh --target /tmp/test-skill

# 干运行（预览将要执行的操作，不实际写入）
bash scripts/install.sh --dry-run

# 卸载
bash scripts/install.sh --uninstall
# 或直接：
bash scripts/uninstall.sh

# 重新验证已有安装
bash scripts/validate.sh ~/.claude/skills/task-planner
```

如果 LLM 遇到 `Permission denied` 无法写入 `~/.claude/skills/`，应改用 `--target "$HOME/.local/share/claude/skills/task-planner"` 或 `$HOME` 下任意用户可写目录，再通过软链接移到 `~/.claude/skills/task-planner/`。

---

## 手动安装

### 前置依赖

| 工具 | 用途 | 检查命令 |
|------|------|----------|
| `bash` ≥ 4 | 所有安装脚本均为 bash 编写 | `bash --version` |
| `python3` ≥ 3.8 | session-catchup.py + JSON 验证 | `python3 --version` |
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
bash scripts/install.sh --dry-run

# 3. 安装到默认位置
bash scripts/install.sh

# 4. 验证安装
bash scripts/validate.sh

# 5. 重启 Claude Code，然后：
#    让 Claude 规划一个多步骤任务，或使用 Skill 工具。
```

#### 自定义目标路径

```bash
# 安装到其他路径（适合沙箱测试 / 多版本并存）
bash scripts/install.sh --target "$HOME/.local/share/claude/skills/task-planner"

# 跳过确认，强制覆盖已有安装
bash scripts/install.sh --force --target ~/.claude/skills/task-planner
```

#### 验证安装

```bash
# 确认 Skill 文件存在且可执行
ls -la ~/.claude/skills/task-planner/SKILL.md
ls -la ~/.claude/skills/task-planner/scripts/*.sh

# 显式运行验证器
bash scripts/validate.sh ~/.claude/skills/task-planner
# 预期输出：VALIDATION PASSED
```

### Windows（原生 PowerShell）

> Skill 内已包含 PowerShell 镜像（`init-session.ps1`、`check-complete.ps1`）。仓库级安装器以 bash 为主。在原生 Windows 上，推荐使用 **WSL** 或 **Git Bash**。如果必须在 PowerShell 中操作：

```powershell
# 从 PowerShell 克隆仓库后：
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill

# 使用 Git Bash 运行安装器（Git for Windows 自带 Git Bash）
& "C:\Program Files\Git\bin\bash.exe" scripts/install.sh --target $HOME\.claude\skills\task-planner

# 用同样方式验证
& "C:\Program Files\Git\bin\bash.exe" scripts\validate.sh "$HOME\.claude\skills\task-planner"
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
bash scripts/install.sh
```

WSL 中的 Claude Code 会自动通过 `$HOME/.claude/skills/task-planner/SKILL.md` 发现 Skill。

---

## 升级

将已有安装升级到新版本：

```bash
# 在本地 clone 中执行
git pull
bash scripts/install.sh --force   # 覆盖已有安装
bash scripts/validate.sh          # 确认安装正常
```

Skill 目录本身是无状态的，升级不会保留任何自定义内容。你的**计划文件**（位于 `plans/` 目录）不受影响——它们在项目目录中，不在 Skill 安装路径。

---

## 卸载

```bash
# 默认目标
bash scripts/uninstall.sh

# 自定义目标
bash scripts/uninstall.sh --target /path/to/skill

# 先干运行预览
bash scripts/uninstall.sh --dry-run

# 跳过确认提示
bash scripts/uninstall.sh --force
```

卸载器只操作你指定的路径，不影响其他 Skill。如果父目录变为空，会询问是否一并删除。

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

### 写入 `~/.claude/skills/` 时权限被拒绝

```bash
# 方案一：改用用户可写路径
bash scripts/install.sh --target "$HOME/.local/share/claude/skills/task-planner"

# 方案二：修复父目录权限
mkdir -p ~/.claude/skills
chmod u+rwX ~/.claude/skills
```

### `validate.sh` 报告 TypeScript 警告

如果你未安装 `@types/node`，这是预期行为。验证器将 TS 类型错误降级为警告，不会阻止安装。要消除警告：

```bash
npm install --save-dev @types/node
```

### `bash: scripts/install.sh: No such file or directory`

你可能没有 `cd` 到仓库目录。先 `cd task-planner-skill`，或传入绝对路径：

```bash
bash /absolute/path/to/task-planner-skill/scripts/install.sh
```

### 安装后 Skill 未被发现

1. 确认文件存在：`ls ~/.claude/skills/task-planner/SKILL.md`
2. 重启 Claude Code（或运行 `/clear`）—— Skill 目录在启动时扫描
3. 确认 SKILL.md 的 frontmatter 中包含 `name: task-planner`（区分大小写）

### `config.json` Schema 验证失败

如果你自定义了 `config.json` 且 `validate.sh` 报告 Schema 错误：

```bash
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
bash scripts/validate.sh ~/.claude/skills/task-planner

# 4. 端到端：启动一个测试计划
mkdir -p /tmp/planner-smoke && cd /tmp/planner-smoke
bash ~/.claude/skills/task-planner/scripts/init-session.sh smoke-test
ls task_plan.md   # 应存在
```

如有任何步骤失败，请参见上方故障排查。

---

## 安装内容清单

```
~/.claude/skills/task-planner/
├── SKILL.md                       (入口文件)
├── config.json                    (阈值配置)
├── reference.md                   (Manus 原则)
├── examples.md                    (实战示例)
├── scripts/
│   ├── init-session.sh            (bash + .ps1 镜像)
│   ├── init-session.ps1
│   ├── check-scope.sh
│   ├── sync-todos.sh
│   ├── check-complete.sh
│   ├── check-complete.ps1
│   ├── session-catchup.py
│   └── sync-ide-folders.ts
├── templates/
│   ├── task_plan.md
│   ├── verification.md
│   ├── findings.md
│   ├── progress.md
│   └── notepad-learnings.md
└── references/
    ├── critical-rules.md
    ├── completion-gate.md
    ├── goal-gate.md
    └── billing.md
```

总大小约 50 KB，安装过程不会在 Skill 目录外写入任何内容。

---

## English Version

[English Install Guide](INSTALL.md) · [English README](README.md)

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
