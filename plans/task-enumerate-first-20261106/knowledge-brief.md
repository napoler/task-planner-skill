# Knowledge Brief — task-enumerate-first-20261106（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-enumerate-first-20261106/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-enumerate-first-20261106/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：新增 Rule 105「可枚举集合全量枚举优先纪律（ls-first）」条款+selftest 守护+级联部署，制度化纠正「小集合关键词盲搜」检索缺陷（用户判例：素材几十个却关键词盲搜漏检致错误 asset-first 决定）
- 背景/动机：检索方式选择（ls 全量枚举 vs 关键词检索）原为模型临场自判，判例实证会因关键词族选错漏检并推出错误决定，用户裁决「必须进行纠正」

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| ls-first | 可枚举小集合（≤200 项默认经验值）先 ls 全量列出再在完整清单上选择匹配的检索纪律 |
| 零命中回退 | 关键词检索没搜到 ≠ 不存在，下否定结论前必须回退全量枚举复核（105.2） |
| 纪元锚级联 | SKILL.md 计数行/路由行/selftest 宽窗在 Rule 编号演进时须同址改写的联动面 |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Rule 105 条款落位 discipline 文件尾 | skills/task-discipline/references/critical-rules-discipline.md:707-721（主仓，五子条 :711-719） | 后续规则引用/部署对账以此为锚 |
| selftest 守护 EN-01..07 段内锚定 | skills/task-planner/scripts/selftest-enumerate-first.sh:44（SEC105 awk 提取） | EN-01..05 锚定 105 段局部文本防空壳，改条款文字须保 EN-03 词频 |
| registry 登记 4 列 tab | skills/task-planner/scripts/selftest-registry.tsv:98 | 后续 selftest 登记照此格式 |
| rule 105 已 land | plans/.rule-reservations.jsonl（e8ab2e8） | 编号占用闭环，后续任务查重可见 |
| 基线 flaky 双脚本 | selftest-active-plan T11/selftest-execution-stability T11b（run-selftests 沙箱态 FAIL，单跑可过） | 全量回归 FAIL≠0 先做主仓单跑对照分类，勿即判本任务引入 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | :9/:222/:265 | 全集索引计数行（1-105；「其余 88 条」）——Rule 编号演进时三处同址改写 |
| skills/task-planner/SKILL.md | :209/:255 | 卫星路由表 discipline 行（枚举含 ,105）/派发指针段（Rule 105 表述） |
| skills/task-discipline/SKILL.md | :15/:86/:97/:84 | 域边界 53 条计数×3+Rule 105 索引行——规则数演进时四处联动 |
| skills/task-planner/scripts/selftest-batch-pilot.sh | :66 | BP-08 行数钉（SKILL.md ≤285）——SKILL 净增行 >4 须升钉 |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止对 SKILL.md 计数行做净增行改动（BP-08 钉 ≤285，margin 4）——Rule 编号演进全部走同址改写
2. 禁止弱化 selftest 断言迁就现状（EN-06/07 依赖级联完成是时序设计，先跑后改≠改断言）
3. run-selftests 全量 FAIL 先主仓单跑对照分类（flaky：active-plan/execution-stability 实证），再判归因
4. Verify command 字段必须纯命令（中文说明混入=runner 127），判据阈值放 test 表达式内
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 级联锚面扫描漏项」「Phase 3 级联锚漏改」「Phase 5 部署位漂移方向误判」行（本次均未触发，清单驱动+逐位 diff 判向生效）

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| Phase3 S1（条款写入） | §1 + §2 | findings.md §Rule 105 设计定稿（条款蓝本） |
| Phase3 S3（级联修正） | §2 + §3 | checkpoint 01-explore-enumerate-first.md（级联清单） |
| Phase5（部署） | §3 | 部署位四路径（zcode/claude/opencode/cursor skills/） |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| {示例：brainstorming} | ~/.agents/skills/brainstorming/SKILL.md | {本任务画像中哪一点命中该技能} | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| {示例：comet} | ~/.zcode/skills/comet/SKILL.md | {匹配点} | 用户手动触发（仅提示） |
| {技能名} | {SKILL.md 绝对路径} | {匹配点} | {激活方式} |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-enumerate-first-20261106>` → 生成 knowledge/entries/_draft-task-enumerate-first-20261106.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

