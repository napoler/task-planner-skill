# Spec 模式路由 — Superpowers × OpenSpec 专业执行体集成

> **定位（2026-11-15 用户 /goal 锚定）**：任务整理阶段（需求分析/目标澄清/规格产出）是用户目标偏移高发区 → 显性路由给专业 Spec 技能执行；task-planner 收敛为**忠实记录者 + 调度者**，不妄图所有任务都由本技能执行。
> **集成形态铁律（R6）**：**调用，不是复制** —— 禁止把 Superpowers/OpenSpec 的技能内容复制或内联进本仓；本文件只承载「何时调用、怎么调用、产物记录到哪」。

## 1. 触发判定与路由表
**触发**：L1+ 任务（mini / L0-T / L0-E 豁免）且命中任一——需求模糊/多方向/「优化改进」类未定边界/需要规格或变更提案。mini/L0-T 小任务不触发（免仪式）。
**原则**：路由=默认建议路径（L1+ 命中即走）；整理阶段的专业内容归专业执行体，planner 不越俎代庖。

| 整理场景 | 路由执行体 | 调用形态 | 产物（外部技能自管） | task-planner 记录动作（记录者职责） |
|----------|-----------|---------|---------------------|-----------------------------------|
| 目标模糊→发散澄清/头脑风暴 | Superpowers `brainstorming` | `Skill("brainstorming")` | 设计文档 `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`（9 步 HARD-GATE，终态移交 writing-plans） | 产物路径+结论收据 → findings.md / task_plan 需求原文区锚定 |
| 需求收敛→规格化/变更提案 | OpenSpec `openspec-propose` | `Skill("openspec-propose")` 或 `/opsx:propose <name>` | 变更产物 proposal.md / specs/ / design.md / tasks.md（路径由 CLI planningHome/changeRoot/artifactPaths 动态解析，典型为 `openspec/changes/<name>/`，禁硬编码） | 同上；tasks.md 可作 S-unit 拆分输入 |
| 「不知道要什么」→方案探索 | OpenSpec `openspec-explore` | `Skill("openspec-explore")` 或 `/opsx:explore` | 探索结论 | 结论收据落 findings |
| 规格获批→实施与验证 | OpenSpec `openspec-apply-change` / `openspec-verify-change` | `Skill("openspec-apply-change")` / `Skill("openspec-verify-change")` | 实施勾选 / 三维验证报告 | 调度 + 验收记录落 progress |
| 规格获批→实施计划 | Superpowers `writing-plans`（brainstorming 硬门规定其后唯一技能）或 OpenSpec `tasks.md`（apply 任务清单） | `Skill("writing-plans")` / openspec-apply-change | 计划/任务清单产物 | planner 记录产物路径收据并与 task_plan 对接，不重写计划内容（R4：任务计划交给专业执行体） |

### 1b. 复杂度分档→族选择决策表（2026-11-16 用户 /goal 增补：按复杂度在 Superpowers/OpenSpec 间择一）
> 判据裁决（用户 2026-11-16 双选）：载体=既有条款扩展（零新文件零脚本）；判据=复杂度主轴（沿用体量分级）+信号修正。本表与 plan-collab-router 权威源 `skill-collaboration.md` §二触发矩阵同构互引，冲突以权威源为准。

| 复杂度档 | 择一路由 | 执行形态 | 备注 |
|---------|---------|---------|------|
| L0/mini（小任务） | 不路由，直执行 | 现行豁免不变 | 免仪式（§1 触发判定同口径） |
| L1（中等）且无规格留存需求 | Superpowers（嵌入） | 主进程保持统筹，按需载入过程纪律成员（brainstorming→writing-plans→executing-plans/TDD/systematic-debugging/审查） | 单会话轻量；task-planner 保留计划循环与验证门 |
| L2+ 或规格留存需求（proposal/design/tasks 有归档价值） | OpenSpec（移交） | `openspec-propose`→apply→verify→archive 生命周期 handoff | planner=忠实记录者+调度者（本文件既有语义） |
| 信号修正（覆盖复杂度初判） | 触及已有 spec→OpenSpec；bug 排查→systematic-debugging（superpowers 单技能嵌入）；跨会话托管→comet | 按修正信号路由 | 多族命中=叠加协同；判定顺序 comet→OpenSpec→superpowers（权威源 §二） |

**择一语义**：同任务同阶段在 Superpowers 与 OpenSpec 之间**择一主导**（防双真源双计划）；跨阶段可切换（brainstorming 收敛后转 `openspec-propose`，即 §1 既有路由）。技能/CLI 探针缺失 → 按 §2 安装引导；安装失败才回落本仓执行并登记（禁静默降级，Rule 97 证据门）。

## 2. 安装引导（检测缺失 → 直接安装，免用户门 —— 用户 R5 原话「遇到没有的话直接安装补充即可」）
| 检测项 | 判定方式 | 缺失时动作（先留痕后执行） |
|--------|---------|---------------------------|
| Superpowers 技能不在位 | 会话技能清单无 `using-superpowers` / `brainstorming` | Claude 生态：`/plugin marketplace add obra/superpowers-marketplace` → `/plugin install superpowers@superpowers-marketplace`；或官方源 `/plugin install superpowers@claude-plugins-official`〔来源：github.com/obra/superpowers README，2026-11-15 抓取〕；ZCode 生态官方无专属安装命令（UNKNOWN，75.7 禁脑补）——fallback=参照 OpenCode 流程（raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md）或向技能目录安装副本，并如实登记 UNKNOWN |
| OpenSpec CLI 不在位 | `command -v openspec` 失败 | `npm install -g @fission-ai/openspec@latest`（Node ≥ 22.12.0）或 `curl -fsSL https://openspec.dev/cli/install.sh | sh`〔来源：github.com/Fission-AI/OpenSpec README，2026-11-15 抓取〕 |
| 项目未初始化 OpenSpec | 项目根无 `openspec/` 目录 | `cd <project> && openspec init`（CLI 打印所选工具的正确调用形态） |

**纪律**：① 安装/初始化命令与输出摘要落 progress.md（记录者留痕）；② 安装失败→报错留痕走 Rule 22.3 兜底链，禁静默跳过、禁脑补其他安装命令（来源逐字）；③ 免用户门=用户 R5 显式授权仅及安装/初始化动作，其他不可逆动作仍走既有门。

## 3. 反模式（禁止）
- ❌ 把 Superpowers/OpenSpec 技能内容复制/内联进本仓（R6 原话：「这样是不对的」）
- ❌ planner 在整理阶段自拟规格/头脑风暴替代专业执行体（R4：专业内容交给他们）
- ❌ 未安装时静默判「不可用」而不引导安装（违反 R5 + Rule 97 不可用判词证据门）
- ✅ 正确形态：调度调用 + 忠实记录（原话锚、产物路径、收据进 plans/ 文件体系）

## 4. 与既有条款关系（纯增量，不改既有链路）
- Rule 39/40/91（协同路由/工具选择）：spec 模式是路由面新增的专业执行体条目，非新 Rule
- Rule 52（执行体专业化优先）：同源原则——专业的事给专业执行体
- Rule 51.1（需求锚定）：spec 产物路径必须回链 task_plan 需求原文区 / findings（记录者义务）
- Markdown 批量/结构化编辑执行面：优先 `skills/md-edit-ops/` 指令单（task-discipline Rule 106.6 指针），与规格路由无冲突、纯增量协同
- 产物路径由外部技能/CLI 自管（OpenSpec 用 planningHome/changeRoot/artifactPaths 动态解析，禁硬编码猜测）

## 5. 验证前置定位（2026-11-16 用户 /goal 锚定：目标驱动/测试驱动）
> **定位**：本项目所有任务按「目标驱动/测试驱动」运行——任务初期先定目标+边界+验证方案（验证脚本/验证规则规范前置），再持续实现；**禁止「先执行、任务偏移后再补验证」**（用户原话锚：后期补验证=「可能会存在严重的隐患」，plans/task-superpowers-openspec-routing-20261116/user-session-log.md#2）。

**验证三载体映射（调用不复制，R6 铁律同源）**：

| 阶段 | 验证载体 | 调用形态 |
|------|---------|---------|
| 计划面（目标+评审机制前置） | task-planner 自有：R 锚定（Rule 51.1）+VC/V-N 契约（51.2/84.1 可执行验证命令）+attest 锁定 | 本技能既有链路，无外部调用 |
| 执行面（先测后写） | Superpowers `test-driven-development` / `verification-before-completion` | `Skill("test-driven-development")`（实现/修 bug 前）；`Skill("verification-before-completion")`（完成声称前，证据先于断言） |
| 收口面（变更收口验证） | OpenSpec `openspec-verify-change` | `Skill("openspec-verify-change")`（变更归档前三维验证报告） |

**与 §1b 路由的关系**：验证依赖强度=§1b 决策表的信号修正项——强验证依赖（可执行验收/规格留存）→ 优先 OpenSpec（verify 阶段前置收口）或 L1 嵌入 TDD；弱验证单点任务 → 本技能 VC 契约直执行，不外部路由。

**反模式**：❌ 任务偏移后才补写验证脚本/验收标准（后期补验证）；❌ 以「先跑起来再说」跳过初期目标+评审评判机制设定；❌ 把验证载体内容复制/内联进本仓（R6 同源禁令）。
**反作弊（判据编写期）**：验证判据编写的严禁清单/负控制/盲探针规约，权威源=卫星 `verification-gate`「验证反作弊规约」段（2026-11-16 /goal 增补）。