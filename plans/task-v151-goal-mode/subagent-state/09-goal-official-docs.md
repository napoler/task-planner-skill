# /goal Goal Mode 官方文档提炼（检查点 09）

检索日期：2026-10-09。任务：为 task-planner Rule 66「goal 单元固化 + /goal 驱动推进」提供官方 /goal 语义对照基准。

官方文档确实存在，且是 ZCode 内置命令。主来源：
- 中文目标模式页：https://zcode.z.ai/cn/docs/goal
- 英文目标模式页：https://zcode.z.ai/en/docs/goal
- 命令页：https://zcode.z.ai/cn/docs/commands
- Agent 页：https://zcode.z.ai/en/docs/agents

---

## 1. 官方语义

### 1.1 /goal 设定方式（来源：https://zcode.z.ai/cn/docs/goal）
引句：「在输入框输入 `/goal` 后接目标描述，或通过 `/` 建议面板选择。」
常用子命令（官方原文）：
- `/goal 查看当前目标`
- `/goal <目标描述>` 设定（替换已有目标）
- `/goal replace <目标>` 明确替换
- `/goal pause` 暂停
- `/goal resume` 恢复
- `/goal clear` 清除

约束：**一个会话同一时间仅一个目标**（官方原句：「一个会话同一时间仅一个目标。」）
英文页同义：`/goal` 显示当前目标；`/goal <objective>` 设定或替换；`/goal replace/resume/clear`。

### 1.2 目标表述要求（来源：https://zcode.z.ai/cn/docs/goal）
引句：「目标描述越具体、越可校验，每轮的判断就越准。」
官方正反例：比起「优化一下性能」，**「把 pnpm test 跑通，并且首屏加载控制在 2 秒内」**效果更好（英文页原文：`"Make pnpm test pass and keep first-paint under two seconds" works much better than "make it faster"`）。
官方列举适合的任务：「重构整个模块并保持测试通过」「修复所有 TypeScript 编译错误」「把这个页面的 Lighthouse 性能分提到 90 以上」；英文页补充定性为「easy to state in one sentence but takes many rounds to finish」。

### 1.3 迭代机制（来源：https://zcode.z.ai/cn/docs/goal）
引句：「每一轮结束都会自动校验目标是否达成，没达成就自己接着下一轮，确认完成才收尾。」
摘要面板按迭代分组展示每轮产出，**每轮标题来自上一步校验给出的下一步动作**（英文页：`Each round's title derives from "the next action the previous round's verification produced."`）。面板展示目标、已用时长、按迭代分组的已完成清单项与当前进度。

### 1.4 完成校验（来源：https://zcode.z.ai/cn/docs/goal）
引句：「校验看的是实据。」——仅写计划、列清单、跑很久或给出结论性回复都**不算数**；必须有「改出来的文件、命令输出、测试结果这类能核对的东西」（英文页：`changed files, command output, and test results` count，`a plan, a checklist, a lot of elapsed effort, or a reply that merely sounds conclusive does not count`）。
补充硬条件：**「只要还有待办未完成，校验就不会判定完成。」**（英文页：`as long as any to-do is still unfinished, the check will not call the goal complete.`）——即 goal 与 todo 清单直接联动。

### 1.5 停止条件（来源：https://zcode.z.ai/cn/docs/goal）
目标在三种情况下停止自动推进：
1. 校验判定完成；
2. 用户主动暂停或清除；
3. 达到为该目标配置的**用量上限**（英文页：`hits the configured usage budget`）。
补充：**停止正在运行的任务会自动暂停 goal**；**goal 状态在会话关闭/重开后保留**（英文页：`Goal state persists across session close/reopen.`）。

### 1.6 与计划（Plan）模式 / 待办（Todo）的关系
- **与 Plan 模式冲突**：官方原句「计划模式与目标模式冲突，因为计划模式"专注于先把方案讨论清楚，不会自动往下执行"」（英文页：`plan mode is for working out an approach before anything runs, so it conflicts with a goal's automatic continuation`）。**必须先切换执行模式，才能设定目标**；任务运行中也无法设定目标。
- **与 Todo**：见 1.4，只要有待办未完成，校验不判完成（goal 校验以 todo 清单为完成度依据）。
- **与执行模式搭配**：引句「目标决定「做到什么程度才算完」，执行模式决定「过程中多少操作需要你确认」。」长任务建议搭配**完全访问 / 自动编辑**以减少中断；涉及重要文件变更时可用「变更前确认」模式。
- Agent 页（https://zcode.z.ai/en/docs/agents）补充：Goal Mode「adds objective management, completion verification, and state recovery for long tasks」；长多轮任务建议「set a verifiable session goal with Goal Mode」；fork 会话时新会话**继承 goal-mode 进度**（`any goal-mode progress`）。

### 1.7 命令页对 /goal 的定位（来源：https://zcode.z.ai/cn/docs/commands）
官方称 ZCode Agent 目前**只有两个内置命令：`/goal` 与 `/compact`**。对 `/goal` 的描述：「查看、设置、替换、暂停、恢复或清除当前会话目标」，定位「适合持续执行的长任务」；用法引句：「需要让 Agent 围绕一个长期目标持续推进时，可以用 `/goal` 设置目标」。

---

## 2. 官方推荐的 goal 写法要点（可执行 goal 长什么样）
综合 1.2 / 1.4，官方口径下可执行的 goal 目标应满足：
1. **一句话可陈述**，但需要多轮才能完成（`easy to state in one sentence but takes many rounds to finish`）。
2. **具体 + 可校验**：包含可运行的命令与可量化的阈值，例：`把 pnpm test 跑通，并且首屏加载控制在 2 秒内`；`把 Lighthouse 性能分提到 90 以上`。
3. **完成判定基于实据**：能对应到「改出来的文件 / 命令输出 / 测试结果」这类可核对物，而非「看起来 OK」。
4. **可被每轮校验反复判定**：表述稳定，不随轮次漂移，便于「每轮结束自动校验」。
5. **有明确终止**：达成实据、或触发用量上限、或用户暂停/清除。
6. 反例（官方明确说效果差）：`优化一下性能` / `make it faster` 这类模糊、不可校验的表述。

---

## 3. 本地安装面补充证据（本地实证，非官方）
说明：以下为本次 grep/ls 结果，仅作补充，不代表官方机制面。

- `grep -rl 'goal' /opt/ZCode/resources/glm/ --include='*.json' --include='*.md' --include='*.js' | head -30` 命中 7 个文件，均为无关命中（ios-simulator、android-emulator、docx copywriting、pptx SKILL、node-repl-host server.js、zcode-guide README）——**未见内置 /goal 命令的模块/定义文件**。
- `ls /opt/ZCode/resources/glm/packages/bundled-skills/skills/` → 仅 `dynamic-workflows`，**无 goal 相关捆绑技能**。
- `find /opt/ZCode/resources/glm -iname '*goal*'` 与 `find ~/.zcode/cli -maxdepth 2 -iname '*goal*'` → **均无结果**。
- `grep -rli 'goal' ~/.zcode/cli/agents/`（排除 sess_* 会话目录）→ **无结果**。
- 发现一个**用户自建命令** `~/.zcode/commands/goal.md`：标题「Goal 模式 — 目标驱动的自动规划 + 自动验证」，是 6 步流程（目标解析→拆 phase→每 phase 验收→执行→phase 间验证→终验），引用 `~/.claude/skills/task-planner/scripts/init-session.sh`（注意是 `.claude` 旧路径）。
  - **重要区分**：这是**用户自定义 slash 命令**（文件型），与官方**内置** `/goal` 会话目标特性同名但**语义不同**——本地 goal.md 是「任务级 6 步验证工作流」，官方 /goal 是「会话级目标 + 每轮自动校验 + 用量上限」的运行时特性。Rule 66 review 时须区分二者，避免把自建命令的语义当成官方内置语义。
- `~/.zcode/commands/` 下另有多个文件提及 goal（sop-dev.md、commands/*.md 等），属用户自定义命令群，非官方定义。

结论：官方 /goal 的机制面**未在本地安装面暴露**（与既有本地实证一致），本地仅存在一个同名的用户自建命令，语义与官方内置特性不同。

---

## 4. 检索记录
已试引擎/站点/关键词（Rule 63.3 合法形态）：
- WebSearch（web_search_prime 后端）：
  - 中文：「ZCode /goal 命令 goal mode 智谱」→ 命中官方 https://zcode.z.ai/cn/docs/goal 及知乎/凤凰网/腾讯云/东方财富等报道。
  - 英文：「ZCode goal mode slash command z.ai coding agent」→ 命中 https://zcode.z.ai/en/docs/goal、/en/docs/commands、/en/docs/agents 及第三方评测（glm5.app、bitdoze、verdent.ai）。
- WebFetch 官方页（成功）：
  - https://zcode.z.ai/cn/docs/goal（中文目标模式）
  - https://zcode.z.ai/en/docs/goal（英文 Goal Mode）
  - https://zcode.z.ai/cn/docs/commands（命令页，确认 /goal 为内置命令）
  - https://zcode.z.ai/en/docs/agents（Agent 页，确认 Goal Mode 定位与 fork 继承）
- 本地安装面：grep /opt/ZCode/resources/glm、ls bundled-skills、grep ~/.zcode/cli/agents、find *goal*（结果见 §3）。
- 社区线索（未深挖，仅记录）：GitHub kingsword09/zcode-cli（Unofficial terminal client），官方源 zai-org/ZCode。

检索结论：**官方 /goal 文档已找到**（zcode.z.ai/cn/docs/goal 与 /en/docs/goal），§1、§2 均据官方页面原文提炼，未编造引句。第三方媒体（知乎/凤凰网/腾讯云）报道口径与官方一致（Goal 模式 = 设定可验收目标、自动拆解/改代码/跑测试/持续迭代直至达成），可作旁证。
