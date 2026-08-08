# task-planner

> **面向 AI 代理的文件系统驱动任务规划工具。** 让计划跨上下文重置持久化，支持多子代理并行执行，并通过显式验证契约（VC）严格判定完成状态。

这是一个 Claude Code / OpenCode Skill，将易失的上下文窗口规划替换为磁盘上的 Markdown 文件。受 [Manus](https://manus.im) 的 Context Engineering 原则启发，并扩展了多任务并行、范围守护 Hook 和验证契约门控等能力，让"完成"变得可证伪。

---

## 为什么需要它？

LLM 会遗忘。经过约 50 次工具调用后，原始目标会漂移，指令互相竞争，代理开始"解决"已经不存在的问题。本 Skill 让计划成为磁盘上的第一类实体——因此：

- **计划可跨 `/clear` 保存** —— 每个阶段、决策、错误和验证步骤都保存在 `plans/task-XXX/` 中
- **阶段有门控，非叙述** —— 每个阶段仅在验证契约（VC）通过时才会从 `pending` → `in_progress` → `complete`
- **范围由 Hook 强制** —— PreToolUse Hook 阻止写入计划目录外的文件；非交互 Shell 无法逃逸
- **子代理是真执行，非叙述** —— 子代理报告"完成"后，Skill 通过 Read 验证文件确实变更后才接受
- **多任务并行** —— 启动 N 个子代理，每个拥有自己的计划子目录，通过共享 `plans/INDEX.md` 协调

这是对原有"文件驱动计划"模式的升级，带来三个核心改进：多任务并行支持、范围守护强制、以及硬验证门控。

---

## 功能特性

| 特性 | 说明 |
|------|------|
| **分阶段规划** | `task_plan.md` 追踪各阶段状态（pending/in_progress/complete） |
| **验证契约（VC）** | 客观、可证伪的成功标准；所有 VC 通过才算"完成" |
| **范围守护 Hook** | PreToolUse 阻止计划外写入；非交互 Shell 无法绕过 |
| **持久化工作记忆** | `findings.md`、`progress.md`、`notepad-learnings.md` 可跨上下文重置恢复 |
| **多任务并行** | 启动 N 个子代理，各拥有 `plans/task-XXX-*`；协调者通过 `plans/INDEX.md` 跟踪 |
| **子代理验证** | 子代理返回"完成"后，必须 Read 验证文件实际变更（completion-gate 规则） |
| **配置驱动阈值** | `config.json` 集中管理 `max_vc`、`retry_count`、`escalation_threshold` 等参数 |
| **中断恢复** | `session-catchup.py` 检测上一轮中断点，避免重复劳动 |
| **项目模板覆盖** | 在项目中放置 `.claude/plan-templates/` 可覆盖内置模板 |
| **跨平台** | 脚本支持 Linux/macOS/WSL；PowerShell 镜像用于原生 Windows |

---

## 快速开始

### 1. 安装（一条命令）

```bash
git clone https://github.com/napoler/task-planner-skill.git
cd task-planner-skill
bash scripts/install.sh
```

默认安装位置：`~/.claude/skills/task-planner/`。可通过 `--target DIR` 自定义。

### 2. 验证安装

```bash
bash scripts/validate.sh
# 预期输出：VALIDATION PASSED
```

### 3. 重启 Claude Code 并调用

让 Claude 规划一个多步骤任务，或直接使用 Skill 工具：

```
/skill task-planner
```

Claude 将：
1. 运行 `session-catchup.py`（检测残留计划）
2. 创建 `plans/task-001/` 并运行 `init-session.sh`
3. 展示计划并等待你确认"yes"
4. 逐阶段执行，在计划文件中标记进度
5. 最后逐条复验 VC，输出 COMPLETE / PARTIAL / BLOCKED

### 4. 让 AI 自动安装

让 LLM 阅读 `INSTALL.md`，其中包含一段可直接执行的安装代码块——详见 **LLM 自动安装**章节。

---

## 项目结构

```
task-planner-skill/
├── README.md                      ← 你在这里
├── README_zh.md                   ← 中文版本
├── INSTALL.md                     ← 安装说明（LLM 自动安装 + 手动安装）
├── INSTALL_zh.md                  ← 中文安装说明
├── CHANGELOG.md                   ← 版本历史
├── CONTRIBUTING.md                ← 开发流程与 PR 规范
├── LICENSE                        ← MIT
├── CLAUDE.md                      ← Claude Code 仓库指南
│
├── scripts/                       ← 安装/验证工具
│   ├── install.sh                 ← 一键安装
│   ├── uninstall.sh               ← 安全卸载
│   └── validate.sh                ← 安装后完整性检查
│
├── examples/
│   └── full-workflow.md           ← 端到端演示
│
└── skills/task-planner/           ← Skill 包本体（镜像到 ~/.claude/skills/）
    ├── SKILL.md                   ← 入口：frontmatter + 工作流
    ├── config.json                ← 所有阈值配置
    ├── reference.md               ← Manus 原则 + 决策矩阵
    ├── examples.md                ← 实战示例
    ├── scripts/
    │   ├── init-session.sh        ← 初始化计划文件
    │   ├── check-scope.sh         ← PreToolUse Hook：范围守护
    │   ├── sync-todos.sh          ← 阶段状态 ↔ TodoWrite 同步
    │   ├── check-complete.sh      ← Stop Hook：汇总阶段完成情况
    │   ├── check-complete.ps1     ← Windows 镜像
    │   ├── init-session.ps1       ← Windows 镜像
    │   ├── session-catchup.py     ← 跨会话恢复
    │   └── sync-ide-folders.ts    ← IDE 工作区同步
    ├── templates/
    │   ├── task_plan.md           ← 阶段 + VC 模板
    │   ├── verification.md        ← VC + 阶段门控模板
    │   ├── findings.md            ← 发现与决策记录
    │   ├── progress.md            ← 会话进度日志
    │   └── notepad-learnings.md
    └── references/
        ├── critical-rules.md      ← Rules 1-10 核心执行约束
        ├── completion-gate.md     ← 子代理验证协议
        ├── goal-gate.md           ← COMPLETE / PARTIAL / BLOCKED 判定标准
        └── billing.md             ← 计费模式说明
```

---

## 规划循环（快速心智模型）

```
用户任务
   │
   ▼
session-catchup.py     ← 如有残留计划则恢复
   │
   ▼
init-session.sh        ← 创建 plans/task-XXX/ 及 5 个模板文件
   │
   ▼
填写 task_plan.md      ← 写入目标 + 阶段 + VC + 范围
   │
   ▼
展示计划，等待"yes"    ← 用户确认
   │
   ▼
逐阶段执行：
   ├─ 状态：pending → in_progress
   ├─ 执行
   ├─ 状态：in_progress → complete
   └─ sync-todos.sh --index（多任务时）
   │
   ▼
全部阶段完成后：
   ├─ 逐条复验 VC
   └─ 输出：COMPLETE / PARTIAL / BLOCKED
```

---

## 验证契约（VC）—— 为什么重要？

任务不是代理说"完成"就完成了。只有**客观检查**通过才算完成。VC 强制每个计划提前声明完成标准：

```markdown
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|----------|
| VC-1 | README ≥3000 字符 | wc -c README.md | README.md |
| VC-2 | install.sh 退出码 0 | bash install.sh --dry-run | stdout |
| VC-3 | validate.sh 退出码 0 | bash validate.sh | 退出码 |
| ... | | | |
```

`max_vc`（默认 5，在 `config.json` 中）是最小 VC 数量。`min_verification_per_phase`（默认 2）确保每个阶段至少有 2 项子检查。

---

## 多任务并行

适用于包含多个独立子功能的项目（如"REST API 含鉴权 + CRUD + 测试"）：

```
plans/
├── INDEX.md                    ← 协调者跟踪所有任务
├── task-001-auth/
│   ├── task_plan.md           ← auth 子代理负责
│   ├── findings.md
│   └── ...
├── task-002-crud/
│   ├── task_plan.md           ← CRUD 子代理负责
│   └── ...
└── task-003-tests/
    └── ...
```

通过 Skill 工具为每个目录启动一个子代理；各子代理独立执行阶段；协调者读取 `INDEX.md` 跟踪整体进度。详见 `examples/full-workflow.md` 中的编排模式。

---

## 英文文档

[English README](README.md) · [English Install Guide](INSTALL.md) · [English Contributing Guide](CONTRIBUTING.md)

---

## 文档索引

| 文档 | 阅读时机 |
|------|----------|
| `INSTALL.md` / `INSTALL_zh.md` | 安装 Skill —— LLM 自动安装块 + 手动安装（Linux/macOS/WSL/Windows） |
| `examples/full-workflow.md` | 端到端演示：从用户请求到 COMPLETE |
| `skills/task-planner/examples.md` | Skill 包内实战示例 |
| `skills/task-planner/reference.md` | Manus Context Engineering 原则 + 决策矩阵 |
| `skills/task-planner/references/critical-rules.md` | Rules 1-10 —— 自定义前必读 |
| `skills/task-planner/references/goal-gate.md` | VC 门控工作原理、COMPLETE/PARTIAL/BLOCKED 规则 |
| `skills/task-planner/references/completion-gate.md` | 子代理验证协议 |
| `CONTRIBUTING.md` / `CONTRIBUTING_zh.md` | 开发流程、脚本规范、PR 检查清单 |

---

## 配置

所有运行时阈值集中在 `skills/task-planner/config.json` 中。修改后重新安装：

```json
{
  "max_vc": 5,                          // 每个计划最少 VC 数量
  "min_verification_per_phase": 2,      // 每个阶段最少子检查数
  "retry_count": 3,                     // 最大重试次数后升级给用户
  "max_tool_calls_before_refresh": 5,   // 每 N 次工具调用后重读 task_plan.md
  "max_view_browser_before_save": 2,    // 每 2 次浏览操作后写 findings.md
  "escalation_threshold": 3,            // 连续失败次数 → AskUserQuestion
  "plan_dir_pattern": "plans/{task-id}/",
  "template_priority": ["project-level", "built-in"]
}
```

`$schema` 强制 `additionalProperties: false` —— 拼写错误会立刻报错。

---

## 许可

MIT —— 见 [`LICENSE`](LICENSE)。

---

## 贡献

欢迎 PR。详见 [`CONTRIBUTING_zh.md`](CONTRIBUTING_zh.md)（中文版）或 [`CONTRIBUTING.md`](CONTRIBUTING.md)（英文版）。Skill 逻辑位于 `skills/task-planner/`；安装/验证/卸载脚本位于仓库根目录 `scripts/`。修改前请先阅读相关参考文档。
