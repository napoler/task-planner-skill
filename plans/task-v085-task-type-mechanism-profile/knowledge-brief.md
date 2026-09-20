# Knowledge Brief — task-v085-task-type-mechanism-profile（任务知识简略要点）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 20（template-guide.md:65 验收）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出（2026-09-20），执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner 建「机制画像」映射层——按 template_type 判定 Code Review Gate/code-assistant 路由等代码组机制适用性，非代码任务不再误入代码机制，通用守卫全类型不变；达成标准=Rule 37+§九矩阵+config 键+抽查段+selftest 全部落盘且全量 selftest 0 FAIL。
- 背景/动机：用户指出文章撰写任务完全不需要 Code Reviewer 类 skill 使用（误路由+审查浪费），机制适用性与任务类型间缺映射层。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 机制画像（mechanism profile） | 按 template_type 查表得到「适用/不适用机制+执行体路由组」的映射，权威源=template-mapping.md §九 |
| 三类机制组 | 代码组（Code Review Gate+code-assistant 路由+修改后验证）/ 内容组（content_quality 门控+article-writer 路由）/ 通用组（全部守卫不变，全类型适用） |
| template_type | 计划 frontmatter 的模板类型字段，13 variant+general 共 14 值，check-template-type.sh 动态白名单校验 |
| 档位键（*_enforce） | config.json 三档开关范式：enforce=阻断 exit 1/2、warn=告警放行、off=关闭；新键默认 warn 观察期 |
| TL 断言 | selftest-template-lifecycle.sh 的 17 条存量断言（TL-01..17），守护 template-mapping/guide 结构 |

## §2 已验证关键事实
<!-- 只录已验证事实；1-4 条经 plan-writer 计划期二次实测复核（标注✅） -->

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| ✅ SKILL.md §子代理路由表 L354 起无类型适配注记，L355 强制「先按本表选择 subagent」；全文 545 行 | skills/task-planner/SKILL.md:354-357（实测） | S2 三处增量的落点之一；纯追加不改既有锚 |
| ✅ 通用 templates/task_plan.md 416 行，L16-24 Code Review 节 n/a/required 二态无判定逻辑（L24 值行），L180 Executor 示例 code-assistant | skills/task-planner/templates/task_plan.md:16-24（实测） | S4 两处微调的精确锚；非代码任务被引向代码机制的缺口现场 |
| ✅ config.json JSON Schema 形态、additionalProperties:false、38 顶级键；content_quality_enforce（L71-80）已按 writing/research/publish 分档=default warn；template_gate_enforce 在 L305 | skills/task-planner/config.json:71-80, :305（实测） | S6 新键仿写范式与插入位置；先例证明「机制按类型分档」可行 |
| ✅ check-template-type.sh 白名单=variant/ 动态派生+general（L15-17 ls 构造），新增章节不破坏 gate；selftest-template-lifecycle.sh TL-17 断言「13 个」计数在 L80-82（grep '13 个' template-guide.md） | skills/task-planner/scripts/check-template-type.sh:15-17; selftest-template-lifecycle.sh:80-82（实测）；template-guide.md:32, :60（计数锚，实测） | §九 新增章节安全；S5 联动核对与 FMEA R2 的兜底对象 |
| 通用模板 Executor 示例 code-assistant 为代码向；check-complete.sh 868 行，warn 档恒 exit 0、enforce 档违规 exit 1（L509 语义注释）；critical-rules.md 315 行末条=Rule 36.7 | plans/task-v085-task-type-mechanism-profile/subagent-state/1-plan-writer-brief.md §已验证事实 1/5 + check-complete.sh:509 + critical-rules.md:315（均实测） | Rule 37 编号取 37；S7 抽查段须兼容既有 exit 语义（FMEA R3） |

## §3 关键文件锚点表
<!-- 执行期照此表定位文件，禁止凭记忆改文件 -->

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | :354-357 | §子代理路由表头部：L350 目的段、L353 强制约束标题、L354 目的句+P0 约束、L355「先按本表选择 subagent」、L356「### 路由表」、L357 表头行；S2 注记插入 L354 附近 |
| skills/task-planner/templates/task_plan.md | :16-24 | Code Review 配置节：L18-21 二态注释（设计代码类改 required/调研文档留 n/a）、L22-24 表头与值行；S4 加自动判定句 |
| skills/task-planner/templates/task_plan.md | :180 | Executor 示例行（code-assistant 代码向）；S4 加机制画像注记 |
| skills/task-planner/references/template-mapping.md | :145-154 | §六 模板互斥关系表（易混对边界 6 行）；§九 矩阵表格样式仿此 |
| skills/task-planner/references/template-mapping.md | :178 | §八 验证命令=现末章；§九 顺延追加于其后 |
| skills/task-planner/config.json | :71-80 | content_quality_enforce 键块：enum[enforce,warn,off]+default warn+description 注明档位语义；S6 新键仿写 |
| skills/task-planner/config.json | :305 | template_gate_enforce 键块（Rule 34 三档+description 注明 Rule 编号）；新键插入其相邻 |
| skills/task-planner/scripts/check-template-type.sh | :15-17 | 白名单动态派生：`ls templates/variant/*-type.md` 去后缀+general；新增 §九 不触碰此逻辑 |
| skills/task-planner/scripts/selftest-template-lifecycle.sh | :80-82 | TL-17 断言：grep 'rule-enhancement' 且 grep '13 个' template-guide.md → ok/bad；TL-18 按此范式追加 |
| skills/task-planner/scripts/check-complete.sh | :509 | enforce/warn 档语义注释行：enforce 违规 exit 1 阻断、warn/off 恒 exit 0；S7 抽查段须守此语义 |
| skills/task-planner/references/critical-rules.md | :315 | 文件末行=Rule 36.7（skill_modify_enforce 消费侧三件套）；Rule 37 纯追加于其后 |
| skills/task-planner/references/template-guide.md | :32, :60 | L32「Variant 模板（13 个）」、L60 模板总数锚「5+3+13=21」；S5 联动核对对象（TL-17 依赖） |

## §4 易错点与禁止假设清单
1. TL-17 计数断言（「13 个」）：template-guide.md L32 锚被联动改坏 → selftest FAIL；兜底=只同步计数不改结构（→ task_plan.md FMEA R2 行）。
2. check-complete.sh exit 语义：新增抽查段禁止在 warn 档改变 exit（恒 exit 0），仅 enforce 档 exit 1（→ FMEA R3 行；S7/S8 双档行为断言必做）。
3. config.json additionalProperties:false：新键必须进 properties 块且 enum/default/description 齐全，其余 38 键零改动。
4. S-unit ID 纯数字：attest 拒锁字母后缀命名（如 S1a 非法）；本计划 S-unit 编号 1-11。
5. Phase 状态行只许在 Phase 块内：`- **Status:**` 不得作为正文散行出现（假 Status 行=check-complete 拒收）。
6. 禁止虚构行号：一切 file:line 以 §2/§3 实测锚点为准；执行期发现行号漂移（前置 Phase 改动所致）先更新本表再派发。
7. 禁改区：template-mapping.md §七定制红线（L158 起）、SKILL.md TL-14/15 grep 锚（C22 行、「模板选取门控与沉淀」段）、通用模板既有锚区结构。
- FMEA RPN>100 兜底指针：R1（160，注记措辞误读）与 R3（144，exit 语义）→ task_plan.md FMEA 表对应行；R4（105，模板锚破坏）同表。

## §5 S-unit 材料包索引
<!-- 与 task_plan.md S-unit 表「输入」列互链 -->

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| 1（Rule 37 追加） | §1 + §2（事实5）+ §3（critical-rules.md:315 行） | plans/task-v085-task-type-mechanism-profile/subagent-state/1-plan-writer-brief.md（「方案设计 A」段） |
| 2（SKILL 三处增量） | §2（事实1）+ §3（SKILL.md:354-357 行）+ §4 第 1/7 条 | 同上 brief（「方案设计 C」段） |
| 3（§九 矩阵） | §1（三类机制组行）+ §3（template-mapping.md:145/:178 行） | 同上 brief（「方案设计 B」段） |
| 4（通用模板微调） | §2（事实2）+ §3（templates/task_plan.md:16-24/:180 行） | 同上 brief（「方案设计 D」段） |
| 5（guide 计数联动） | §2（事实4）+ §3（template-guide.md:32/:60 行）+ §4 第 1 条 | 同上 brief（FMEA R2） |
| 6（config 新键） | §2（事实3）+ §3（config.json:71-80/:305 行）+ §4 第 3 条 | 同上 brief（「方案设计 G」段） |
| 7（画像抽查段） | §2（事实5）+ §3（check-complete.sh:509 行）+ §4 第 2 条 | 同上 brief（「方案设计 E」段） |
| 8（新 selftest+TL-18） | §2（事实4）+ §3（selftest-template-lifecycle.sh:80-82 行）+ §4 第 2/4 条 | 同上 brief（「方案设计 F」段） |
| 9（复验+自查） | §2 全部 + §4 全部 | task_plan.md VC 表（VC-1/2/3） |
| 10（全量 selftest 求和） | §3（scripts 目录锚）+ §4 第 2 条 | task_plan.md VC-4/VC-5 判定标准 |
| 11（Gate+合并回+簿记） | §4 第 6 条 + task_plan.md 隔离决策区块 | skills/task-planner/references/worktree-isolation.md §3 |
