# design — plan-history-recall 技能（跨任务历史经验挖掘）

> 状态：设计已获用户批准（2026-11-16，五节逐条批准 + 三裁决 Q&A）。
> 方法论：using-superpowers → brainstorming →（本文件）→ writing-plans。
> 调研依据：同目录 findings.md（Explore 子代理一手事实+主进程抽查复核）。

## 1. 背景与目标

用户诉求（转译）：基于 task-planner 现有文档体系（plans/ 计划档案，185 归档+12 活跃任务×约 7 份标准文档）结合 git 提交历史，调研梳理「之前做了什么、什么成功、什么犯错」，作为后期任务规划的经验/参考来源。

调研确认的真实缺口：现有能力全部是 per-task 执行期/恢复期（plan-resume/progress-tracker/Rule 93 召回/Rule 84.14 收口回读），**跨任务经验挖掘层为空白**；`kb-search.sh`（扫 `knowledge/*.md`）为可复用检索基座但仅覆盖 knowledge/ 不覆盖 plans/。

技能定位：**按需调研型**——新任务规划期或独立咨询时调用，从 plans/ 文档体系 + git 历史挖掘相关过往任务，产出证据锚齐全的「历史经验简报」并落盘。

## 2. 用户裁决记录（brainstorming Q&A，2026-11-16）

| # | 问题 | 裁决 |
|---|------|------|
| Q1 | 核心工作模式 | **按需调研型**（规划期按需挖掘，产出随任务落盘；非全量沉淀库） |
| Q2 | 触发方式 | **显式调用+轻接线**（独立可调用 + task-planner L1+ 规划期 1 行建议指针，不强制） |
| Q3 | 实施形态 | **SOP+专职子代理全家桶**（SKILL.md+专职 agent+经验卡 schema+简报模板+selftest） |
| 自裁 | 适用范围 | 按 `$PWD/plans/` 相对路径通用设计（部署全局后他项目仓同用），以本仓实测验证 |
| 自裁 | 命名 | 技能 `plan-history-recall`（对齐 plan-* 家族）；子代理 `history-miner` |

## 3. 交付物清单（6 项）

| # | 文件 | 职责 |
|---|------|------|
| 1 | `skills/plan-history-recall/SKILL.md` | SOP 载体：触发→路由→派发→综合→落盘全流程+成本护栏 |
| 2 | `skills/plan-history-recall/references/experience-card-schema.md` | 经验卡 schema（单任务提炼契约，history-miner 产出物规范） |
| 3 | `skills/plan-history-recall/references/brief-template.md` | 简报模板（跨任务综合产出契约，含占位符） |
| 4 | `agents/history-miner.md` | 专职只读挖掘子代理（对齐 drift-checker 伴飞先例：轻档模型+只读纪律+结构化产出） |
| 5 | `skills/task-planner/SKILL.md` 轻接线 | 规划期指针 1 行（见 §7 措辞） |
| 6 | selftest 断言脚本 + registry 登记 | frontmatter 合规/SOP 段完整性/schema 占位符/接线行存在性 |

部署：按仓库惯例四部署位（源仓→zcode/claude/cursor/agents），writing-plans 阶段细化部署矩阵。

## 4. 架构与数据流

```
Stage 0 触发与输入
  显式调用（用户："梳理一下之前做过的 X 相关任务"）或 task-planner 规划期指针建议
  输入 = 主题/问题 + 可选范围（默认当前仓 plans/ 含 archive/）

Stage 1 路由（主进程，§一 轻档）
  INDEX.md 主表（Task ID|Status|Goal…）grep 主题关键词 + 任务目录名匹配
  + git log --oneline --grep "<关键词>" 反查关联 task-id
  → 候选任务清单（≤8 个，按相关性排序；排除理由留痕）

Stage 2 并行挖掘派发（history-miner ×≤3，每代理 ≤3 任务）
  子代理只读提取每任务：
    task_plan.md（Goal 原文/Decisions Made/VC）· progress.md（Error Log 的 Root Cause/Prevention 列+[goal:Gn] 证据行）
    user-session-log.md（用户逐字裁决）· findings.md/knowledge-brief.md（要点）
    git log --grep "<task-id>"（提交面证据：feat/fix/archive 轨迹）
  → 产出：schema 化经验卡落盘（见 §5）+ 返回 8 字段指针

Stage 3 综合（主进程或 general-summarizer）
  跨任务提炼：成功模式 / 失败教训（频次+根因聚类）/ 用户偏好演变 / 可复用判据与资产
  按 brief-template.md 填充

Stage 4 落盘
  任务上下文内（规划期）：<当前任务 plans/<id>/history-recall/cards/*.md> + <plans/<id>/history-brief.md>
  独立咨询：plans/history-recall/<topic>-<date>/（cards/ + brief.md）
```

## 5. 经验卡 schema（experience-card-schema.md 核心契约）

每任务一卡，九字段，**每字段必须带文件级证据锚（相对路径+行号或 commit），无锚字段留空并标「未查到」——禁脑补**：

| 字段 | 来源 | 说明 |
|------|------|------|
| task_id | 目录名 | 全局连接键 |
| outcome | task_plan.md frontmatter/progress | complete/pending/in_progress/cancelled |
| goal_摘要 | task_plan.md Goal 段 | ≤3 句 |
| 关键决策 | Decisions Made 表 | 决策+理由，保留用户裁决原话要点 |
| 成功要素 | progress [goal:Gn] 证据行+VC 通过记录 | 什么做对了 |
| 失败教训 | progress Error Log（Root Cause/Prevention 列） | 犯错+根因+防复发 |
| 可复用资产 | progress/交付记录 | 脚本/模板/规则条款/技能产出 |
| 用户偏好信号 | user-session-log.md | 逐字裁决摘录 |
| 证据锚 | 全部来源 | 文件路径+行号/commit 列表 |

## 6. 成本与错误护栏

- 单次调研：候选任务 ≤8；history-miner ≤3 并行 ×每代理 ≤3 任务；简报 ≤150 行；经验卡 ≤60 行/卡。
- 全程只读 plans/ 与 git，**禁写任何历史任务文件**（唯一写入=§4 Stage 4 消费方目录产物）。
- 零命中 → 如实产出「无相关历史」简报+已查维度清单（禁编造相关性）。
- INDEX.md 缺失/新项目空仓 → 降级纯 `git log --grep` 扫描+说明降级原因。
- history-miner 失败 → 重派一次 → 仍败降级主进程直读（≤2 任务）并留痕。
- 超大主题 → 分批多轮（每轮 ≤8 任务），简报按轮合并。

## 7. task-planner 轻接线条款（措辞草案）

插入 `skills/task-planner/SKILL.md` 规划/初始化段 1 行：

> 规划期可选前置：L1+ 新任务若主题可能涉及历史经验（同类改造/既有机制扩展/曾犯错领域），建议先 `Skill(plan-history-recall)` 产出 history-brief 再定方案；不强制，L0-T/mini 跳过。

## 8. 测试与验收标准（VC 预览，writing-plans 细化为可执行 Verify command）

- VC-1：6 交付物存在且 frontmatter 合规（name/description/tools 一致性）。
- VC-2：**本仓真实主题全链实测**——选 1 个真实主题跑 Stage 0→4，简报中每条结论可追溯：引用的任务目录存在、证据锚路径+行号盘上可查（反造谣门）。
- VC-3：成本护栏数字（≤8/≤3×3/≤150 行）在 SKILL.md 与模板占位中落字可 grep。
- VC-4：selftest 注册 registry 并通过；不破坏既有基线。
- VC-5：四部署位同步 diff=0。
- VC-6：task-planner 接线行存在，selftest 全量零新增 FAIL。

## 9. 范围外（YAGNI，记录为未来可选演进）

- 不做全量沉淀经验库/增量索引脚本/经验卡回流 knowledge/（Q1 已裁按需型）。
- 不改 kb-search.sh 及现有召回条款（Rule 93/84.14 保持单任务语义）。
- 不做跨仓聚合（单仓内 plans/ + git；跨项目由调用方逐仓执行）。

## 10. 实施边界提醒（writing-plans 输入）

- skills/agents 属 §六 保护区+§十一 worktree 强制：实现阶段必须 worktree 隔离（wt/task-history-recall-20261116，基点 master）。
- selftest 基线对照、四部署位部署矩阵、registry 登记按仓库既有 SOP（task-planner 收口链）执行。
