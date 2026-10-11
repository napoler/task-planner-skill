# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-10-03）：「创建一个Agent 使用GLM5.3模型或者其他Opus级别模型进行任务解决规划 当然要求只有任务复杂度过高才会使用 就是作为解决复杂问题的备用方案」
- 拆解：① 新建 agent ② 模型=GLM5.3（或其他 Opus 级）③ 职能=任务解决规划 ④ 触发门控=仅高复杂度 ⑤ 定位=复杂问题备用方案（非日常主力）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| ListModels 宿主模型清单 | 本会话工具输出（32 模型） | ☑ | §Research Findings R0 |
| complex-problem-solver 结构先例 | ~/.zcode/agents/complex-problem-solver.md（60 行全文） | ☑ | §Research Findings R2 |
| 裸 providerId/modelId model 行先例 | ~/.zcode/agents/executor.md:5 | ☑（Explore 引用） | §Research Findings R1 |
| install-companion claude 位适配 | skills/task-planner/lib/install-companion.sh:70-86 | ☑（Explore 引用） | §Research Findings R3 |
| skill-agent-router 路由表 | ~/.zcode/skills/skill-agent-router/SKILL.md:97 | ☑（Explore 引用） | §Research Findings R5 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

- **R0（主进程第一手，ListModels 2026-10-03）**：宿主在位模型中 `account:zai-individual-coding-plan/GLM-5.3`（完整版，levels low/high/max，默认 max）即用户所指 GLM5.3；Opus 级等价档 `9e221f47-3040-4ea7-b742-20b813fb79aa/opus-1`（ccr provider）。当前会话模型为 GLM-5.3-**Flash**（非完整版）。
- **R1（Explore Q1）**：agent canonical 位 = 仓内 `skills/task-planner/companion/agents/`，仅 3 文件（article-batch-publisher / article-field-fixer / plan-writer）；`complex-problem-solver.md` **不在仓内**（仅两个部署位实体，2026-09-18 安装）。plan-writer 三方 md5 互异（companion 与 zcode 位各自演进线漂移——存量问题，不在本任务范围）。部署先例（memory task-planner-repo-deploy-flow v057 段）：`~/.zcode/agents/plan-writer.md` 须与 companion 逐字节一致，`~/.claude/agents/plan-writer.md` 仅 model 行适配。
- **R2（Explore Q2 + 主进程 Read）**：`~/.zcode/agents/*.md` model 行 9 种格式，主流 `model: "custom:9e221f47-…:<slug>"`（72 文件）；裸 `providerId/modelId` 式 5 文件在用（executor.md 等）；**无任何 GLM/zai/account: 前缀先例**（新范式）。complex-problem-solver.md 结构 = frontmatter(name/description/tools/model/thoughtLevel) + 证据要求 + 验证协议 + 负结果报告 + 技能清单 + 禁止行为 + 输出模板，model=sonnet-1 档，定位=失败升级+问题分解。
- **R3（Explore Q3）**：claude 位适配 = `lib/install-companion.sh:70-86` `adapt_model_line`（仅 `custom:<uuid>:` 式被降级映射 sonnet-1→sonnet/opus-1→opus/mini→mini，其余格式原样通过）；反向收编 = `scripts/sync-companion.sh:68-79`（**禁在部署后误跑**，sync-companion 反向覆盖陷阱见 memory）。`~/.claude/agents/` 共 73 文件，含 complex-problem-solver.md。
- **R4（Explore Q4）**：全部 selftest/check 脚本对 agent 的断言仅锚定 `companion/agents/plan-writer.md` 单文件内容（selftest-reliability-institution.sh:28、selftest-conclusion-discipline.sh:39、selftest-tool-selection.sh:32、selftest-knowledge-brief.sh:18、selftest-methodology.sh:54-55），**无任何目录结构/文件数量断言** → 新增 companion agent 文件零 selftest 破坏（前提不动 plan-writer.md）。install-companion.sh:154 通配分发，新文件自动进入安装面。
- **R5（Explore Q5）**：路由联动面 = `~/.zcode/skills/skill-agent-router/SKILL.md:97` 硬编码枚举 complex-problem-solver 行（需为新 agent 加行）；`sub-agents/SKILL.md` 只列内置三类无需同步；task-planner 仓内「升级 ComplexProblemSolver」叙事 3 处（SKILL.md:339/349 + critical-rules.md:149）——本任务不联动（D4 deferred，Rule 36 保守化 + v117 守卫教训）。
- **R6（主进程，check-conflicts 2026-10-03）**：信号①②③ 全部来自并行 task-v118（自有 worktree `/home/terry/task-planner-skill-worktrees/task-v118`，scope=critical-rules/templates）+ task-v116 残留信号文件；与本任务 scope（companion/agents/ 新增文件）**零重叠**，worktree 隔离 + 互不触碰即可。
- **R7（主进程，agent 可见性限制）**：Agent 工具类型列表会话启动固化（task-v055-fallback 先例：变体 agent 新会话才可见）→ 新 agent 本会话**不可行为级派发验证**，只能结构验证（D6）。
- **R8（Phase 1 S1 产出复核，主进程 Read 第一手 2026-10-03 04:20）**：`<worktree>/skills/task-planner/companion/agents/complex-planner.md` 已产出，48 行，与 knowledge-brief §6.1 规格逐字一致；主进程 Read 复核确认：frontmatter 4 要素在位（:2 name/:4 tools/:5 model 双引号 GLM 裸式/:6 thoughtLevel）、description 含「仅当任务复杂度过高」门控+5 触发词+禁用边界句（:3）、正文五段锚齐全（:13/:18/:23/:30/:37）。executor 三组 grep 自验证据存 subagent-state/1-executor.md。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| model 行用裸 providerId/modelId 引号式而非 custom: 式 | GLM-5.3 挂在 `account:zai-individual-coding-plan` provider 下，不在 ccr UUID（9e221f47）下，custom:<ccr-uuid>:GLM-5.3 会解析失败；裸式有 executor.md 在用先例（R1/R2）；引号防 YAML 冒号歧义 |
| claude 位 model=opus 而非照抄 GLM 行 | claude 平台无 GLM 提供方；adapt_model_line 对非 custom: 格式原样通过会留下 claude 无法解析的行；用户原话授权"或者其他 Opus 级别模型"等价替换（D3） |
| 触发门控三层设计（description+router 行+正文禁用清单） | 用户要求"只有复杂度过高才用"：description=Agent 工具匹配层、router 表=路由建议层、正文禁用清单=agent 自拒单层；三层冗余防滥用 |
| 与 complex-problem-solver 互补定位不改动 CPS | CPS=失败后升级+问题分解（sonnet 档）；新 agent=高复杂度**规划**（GLM5.3/Opus 级，产出计划不产码）；改 CPS 属语义改写需单独授权（Rule 36），无必要 |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| plan-writer.md companion 版与 zcode 部署位已漂移（各自演进线，R1） | 不在本任务 scope，不动 plan-writer.md；登记为存量观察项（如用户裁决再立项） |
| GLM model 行无行为级先例（R2/R7） | FMEA 已登记 RPN56 兜底：结构同构断言 + 交付显式登记未验证 + 新会话冒烟建议 + 一行 sed 可切 opus-1 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 部署拓扑权威记忆：`~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-repo-deploy-flow.md`（v057 段 agent 2 位部署先例 + sync-companion 反向陷阱段）
- 守卫锚：selftest 仅锚 plan-writer 单文件（R4 五个脚本行号）
- 路由表锚：`~/.zcode/skills/skill-agent-router/SKILL.md:97`

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- （本任务无多模态输入）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
