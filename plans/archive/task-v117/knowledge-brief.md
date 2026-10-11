# Knowledge Brief — {task-id}（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/<task-id>/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：一句话说明本任务做什么 + 为什么做（≤2 行）；下方术语表每条 ≤1 行，只收录「不解释会读不懂后续 S-unit 材料包」的术语 -->
## §1 任务速览与核心概念
- 任务一句话：{做什么 + 达成标准，一行}
- 背景/动机：{为什么做，一行}

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| {示例：worktree} | git 隔离开发区，实现类任务必须在其中开发（Rule §十一） |
| {术语} | {≤1 行解释} |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| {示例：init-session.sh 建 5 文件} | scripts/init-session.sh:120 | 新增第 6 文件须同步 :120 复核列表与 :131 文案 |
| {事实} | {file:line} | {影响} |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| {示例：scripts/init-session.sh} | :90-98 | 4 文件循环建立（findings/progress/notepad-learnings/verification） |
| {路径} | :{行号} | {摘要} |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. {示例：禁止改 22.4a 三文件契约原文（KQ2 轻量方案裁定，KQ2 波及面=check-dispatch 7 处+selftest 5 组）}
2. {易错点/禁止假设}
3. {易错点/禁止假设}
- FMEA RPN>100 兜底指针：{→ task_plan.md FMEA 表「{Phase} {失败模式}」行}

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| {示例：S1} | §1 + §2 + §3 | /abs/path/to/material.md |
| {S-unit ID} | {§x} | {路径} |


# task-v117 实例回填（主进程 2026-10-02）

## §1 任务速览
- 任务一句话：v107 遗留 8 处文档面残留 + 三裁决口径（P-5/T-2/C-P6）落地 + 部署位同步，全部完成后 v107 遗留真实清零
- 背景：v116 终验声称「R 系列全部清零」，2026-10-02 系统性复核查（sub:60）实测出 8 处漏网

## §2 已验证事实（sub:60 检查点 + 主进程抽查）
| 事实 | 证据 |
|------|------|
| 8 处残留锚点行号 | plans/task-v116/subagent-state/60-explore-v107-legacy.md §A/§B |
| 部署分叉唯一文件=三宿主 selftest-workflow-orchestration.sh（v116 前旧版，单向 cp 即可） | sub:60 附节（md5 三宿主一致） |
| 主模板三区块：Drift Log :336 / 委派统计 :363 / Handoff 登记表 :375 | 主仓 skills/task-planner/templates/task_plan.md 实测 |
| T-2 缺项面：委派统计 28/29 缺（mini-lite 设计豁免）、Handoff 12 家缺（v115 回流 video/image 族） | sub:60 §B3 |
| P-1 完成后 WF-10 命中 2+1+0+1=4 <6 下限 → Phase 3 自检时同步扩守卫口径（与 v116 同款处置） | 主进程 Phase 1 后实测 |
| P-1 已 commit worktree 321ae79（12 文件） | git log wt/task-v117 |

## §3 定位文件
- 计划: plans/task-v117/task_plan.md（Phase 2 S-unit 表）
- 区块源文本: skills/task-planner/templates/task_plan.md（worktree 内，逐字复制）
- 批次目标: skills/task-planner/templates/variant/*.md（27 家委派统计 + 12 家 Handoff，名单以 sub:60 §B3 实测为准）

## §4 易错点
- 18.9 试点先行：试点 1 家主进程 Read 验收前禁止批量
- 区块文本逐字复制主模板，禁自造内容；插入顺序照主模板（Drift Log → 委派统计 → Handoff）
- mini-lite-type.md 两区块均设计豁免（Rule 38.3 白名单），勿补
- Batch Report 八字段必填（Rule 18.6，批量 ≥5 单元）

## §5 S-unit → brief 节互链
- P2-S1 试点：§3 区块源文本 + §4 试点硬门
- P2-S2/S3 批量：§4 豁免名单 + §2 T-2 缺项面
- P3 回归：§2 WF-10 守卫口径 + VC 表
