# Superpowers 技能族盘点（只读调研）

> 范围：`/home/terry/.zcode/skills/` 与 `/home/terry/.agents/skills/`；同名两处均存在时下表列双路径，优先级未在本次调研文件中明示（UNKNOWN）。来源均为文件路径:行号。

## 1. 家族完整清单

| 技能名 | SKILL.md 绝对路径 | 一句话职责（frontmatter description/首段） | 调用名 |
|---|---|---|---|
| using-superpowers | `/home/terry/.zcode/skills/using-superpowers/SKILL.md`; `/home/terry/.agents/skills/using-superpowers/SKILL.md` | "Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions" | `using-superpowers` / `superpowers:using-superpowers`（文本引用） |
| brainstorming | `/home/terry/.zcode/skills/brainstorming/SKILL.md`; `/home/terry/.agents/skills/brainstorming/SKILL.md` | "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation." | `brainstorming` / `superpowers:brainstorming` |
| writing-plans | `/home/terry/.zcode/skills/writing-plans/SKILL.md`; `/home/terry/.agents/skills/writing-plans/SKILL.md` | "Use when you have a spec or requirements for a multi-step task, before touching code" | `writing-plans` / `superpowers:writing-plans` |
| executing-plans | `/home/terry/.agents/skills/executing-plans/SKILL.md`（.zcode 无） | "Use when you have a written implementation plan to execute in a separate session with review checkpoints" | `executing-plans` / `superpowers:executing-plans` |
| subagent-driven-development | `/home/terry/.agents/skills/subagent-driven-development/SKILL.md`（.zcode 无） | "Use when executing implementation plans with independent tasks in the current session" | `subagent-driven-development` / `superpowers:subagent-driven-development` |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md`（.zcode 无） | "Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes" | `systematic-debugging` / `superpowers:systematic-debugging` |
| test-driven-development | `/home/terry/.agents/skills/test-driven-development/SKILL.md`（.zcode 无） | "Use when implementing any feature or bugfix, before writing implementation code" | `test-driven-development` / `superpowers:test-driven-development` |
| requesting-code-review | `/home/terry/.agents/skills/requesting-code-review/SKILL.md`（.zcode 无） | "Use when completing tasks, implementing major features, or before merging to verify work meets requirements" | `requesting-code-review` / `superpowers:requesting-code-review` |
| receiving-code-review | `/home/terry/.agents/skills/receiving-code-review/SKILL.md`（.zcode 无） | "Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification..." | `receiving-code-review` |
| finishing-a-development-branch | `/home/terry/.agents/skills/finishing-a-development-branch/SKILL.md`（.zcode 无） | "Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup" | `finishing-a-development-branch` / `superpowers:finishing-a-development-branch` |
| using-git-worktrees | `/home/terry/.zcode/skills/using-git-worktrees/SKILL.md`; `/home/terry/.agents/skills/using-git-worktrees/SKILL.md` | "Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback" | `using-git-worktrees` / `superpowers:using-git-worktrees` |
| dispatching-parallel-agents | `/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md`（.zcode 无） | "Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies" | `dispatching-parallel-agents` |
| writing-skills | `/home/terry/.agents/skills/writing-skills/SKILL.md`（.zcode 无） | "Use when creating new skills, editing existing skills, or verifying skills work before deployment" | `writing-skills` |
| verification-before-completion | `/home/terry/.zcode/skills/verification-before-completion/SKILL.md`; `/home/terry/.agents/skills/verification-before-completion/SKILL.md` | "Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output..." | `verification-before-completion` / `superpowers:verification-before-completion` |

- 来源：目录/存在性 `ls` 结果（本次 Bash 输出）；frontmatter 描述与调用名示例：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:2-3,30-31`；`/home/terry/.zcode/skills/brainstorming/SKILL.md:2-3`；`/home/terry/.zcode/skills/writing-plans/SKILL.md:2-3,17,62,170,174`；`/home/terry/.agents/skills/executing-plans/SKILL.md:2-4,15`；`/home/terry/.agents/skills/subagent-driven-development/SKILL.md:2-3,409-418`；`/home/terry/.agents/skills/systematic-debugging/SKILL.md:2-3,179,287-288`；`/home/terry/.agents/skills/test-driven-development/SKILL.md:2-3`；`/home/terry/.agents/skills/requesting-code-review/SKILL.md:2-3`；`/home/terry/.agents/skills/receiving-code-review/SKILL.md:2-3`；`/home/terry/.agents/skills/finishing-a-development-branch/SKILL.md:2-4`；`/home/terry/.zcode/skills/using-git-worktrees/SKILL.md:2-3`；`/home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md:2-3`；`/home/terry/.agents/skills/writing-skills/SKILL.md:2-4,284-285`；`/home/terry/.zcode/skills/verification-before-completion/SKILL.md:2-3`。

## 2. using-superpowers 入口语义

- 路由/索引方式：要求“若技能可能适用（哪怕 1%）必须先调用技能”，在任何响应/行动前（含澄清、读文件、探索代码库）检查并调用；流程技能优先于实现技能，并给出示例映射（build→brainstorming，bug→systematic-debugging），还要求计划模式前若未 brainstorm 先调用 brainstorming。来源：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:10-31`；`/home/terry/.agents/skills/using-superpowers/SKILL.md:10-31`。
- 用户触发：description 标明 “Use when starting any conversation ... requiring skill invocation before ANY response...”，即会话开始/任何任务即触发检查与调用；并要求 “announce \\"Using [skill] to [purpose]\\" and follow the skill exactly”。来源：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:3,20,24`；`/home/terry/.agents/skills/using-superpowers/SKILL.md:3,20,24`。

## 3. brainstorming 深读

- 触发条件：`description` “You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.”；且 HARD-GATE 禁止在设计呈现并获用户批准前实施。来源：`/home/terry/.zcode/skills/brainstorming/SKILL.md:3,13-15`；`/home/terry/.agents/skills/brainstorming/SKILL.md:3,13-15`。
- 流程步骤（Checklist/Flow）：1) 探索项目上下文 2) 需要时适时提供 visual companion 3) 逐个澄清问题 4) 提 2-3 方案与取舍/推荐 5) 分段呈现设计并逐段获批 6) 写设计文档并提交 7) 规格自检 8) 用户审阅 spec 9) 转入 writing-plans。来源：`/home/terry/.zcode/skills/brainstorming/SKILL.md:23-33,37-60,64-133`。
- 输入：当前项目上下文（files/docs/recent commits）、用户想法与澄清回答。来源：`/home/terry/.zcode/skills/brainstorming/SKILL.md:11,25,68-74`。
- 输出/产物：经批准的设计展示；spec 文档 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` 并 commit；用户审阅通过后调用 `writing-plans` 进入实现计划（终态仅 writing-plans）。来源：`/home/terry/.zcode/skills/brainstorming/SKILL.md:30,62,106-111,122-133`。

## 4. 安装与初始化方式

- **UNKNOWN（未在盘点到的 superpowers 相关 SKILL.md 内文找到安装命令 / plugin marketplace 名 / 初始化步骤，亦未找到“未安装时如何安装”的逐字说明）。**
- 最有线索文件与段落：
  - `/home/terry/.zcode/skills/using-superpowers/references/codex-tools.md:1-10`（Codex 配置片段，非 superpowers 安装）：含 `Add to your Codex config (~/.codex/config.toml):` 与 `[features]` / `multi_agent = true`，用于启用子代理能力。
  - `/home/terry/.zcode/skills/using-superpowers/references/pi-tools.md:12`：`"Pi core does not ship a standard subagent tool. The \`pi-subagents\` package is a strong optional companion..."`（可选依赖提示，非 superpowers 本体安装/marketplace）。
  - `/home/terry/.agents/skills/writing-skills/SKILL.md:19` 提及 `superpowers:test-driven-development` 为 REQUIRED BACKGROUND（技能依赖关系，非安装命令）。

## 5. ZCode/Claude Code 调用形态

- 依据文件文本：技能间以 `superpowers:<skill-name>` 形式引用/要求子技能（如 `superpowers:brainstorming`、`superpowers:writing-plans`、`superpowers:executing-plans` 等）。来源：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:30-31`；`/home/terry/.zcode/skills/writing-plans/SKILL.md:17,62,170,174`；`/home/terry/.agents/skills/executing-plans/SKILL.md:15,37,69-71`；`/home/terry/.agents/skills/subagent-driven-development/SKILL.md:409-418`；`/home/terry/.agents/skills/systematic-debugging/SKILL.md:179,287-288`。
- 平台适配提及：`executing-plans` 注记 “Superpowers works much better... on a platform with subagent support (Claude Code, Codex CLI, Codex App, and Copilot CLI all qualify...)”。来源：`/home/terry/.agents/skills/executing-plans/SKILL.md:15`。
- `using-superpowers` 指出按 harness 读取 `references/codex-tools.md|pi-tools.md|antigravity-tools.md` 做平台适配；未在这些 SKILL.md/references 中找到 ZCode 专属 `Skill(skill="...")` 或斜杠命令的逐字说明（UNKNOWN）。来源：`/home/terry/.zcode/skills/using-superpowers/SKILL.md:52-58`；`/home/terry/.zcode/skills/using-superpowers/references/codex-tools.md:1-10`。

## 6. NET 补采：安装权威命令（主进程 2026-11-15 真实抓取，75.7 来源留痕）
- 来源：https://github.com/obra/superpowers README（web_reader 抓取，2026-11-15）
- Claude Code 安装（逐字，二选一）：`/plugin install superpowers@claude-plugins-official`（官方 marketplace）；或 `/plugin marketplace add obra/superpowers-marketplace` + `/plugin install superpowers@superpowers-marketplace`
- 基本工作流（逐字摘要）：brainstorming（动笔前激活，产出可供建造的设计文档）→ using-git-worktrees → writing-plans → subagent-driven-development / executing-plans → test-driven-development → requesting-code-review → finishing-a-development-branch
- brainstorming 定位（逐字）："Drawing out intent before building... projects get a written design document a builder could plan from"
- 哲学条目（逐字）："Evidence over claims - Verify before declaring success"（与本仓 §三 反造谣同源）
- 第 4 节 UNKNOWN 项部分关闭：安装命令已获权威来源；ZCode 专属调用语法仍 UNKNOWN（本机技能以 Skill 工具按名调用为事实形态）
