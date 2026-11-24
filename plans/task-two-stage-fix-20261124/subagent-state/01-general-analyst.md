# 01-general-analyst.md — 只读定位分析检查点

- start: 2026-11-24 05:22:03 CST
- end: 2026-11-24 05:27:20 CST
- status: DONE（只读定位；grep/Read 取证，未改任何被分析文件）
- scope: skills/ 源码 + 4 个指定计划视图；已先读 RETRIEVAL_EXCLUDE.md（唯一排除项 trash/），未查 ~/.zcode、部署位、plans/ 其他文件、tmp/、forensics/、日志。

## Q1 根因/防复发/修规则本身条款与触发流程步骤
1. skills/task-discipline/references/critical-rules-discipline.md:79 标题「### 31 错误学习闭环（P0 — task-v072，目标：用户指出错误 → 根因分析 → 计划/规则优化 → 防复现，禁盲目修改）」。
2. :83 31.1「触发条件（用户指令判为"错误指出"，任一命中即 STOP 当前写入，先走 31.2 再动手）」；五类触发：已产出有误/同问题≥2次/推翻结论/ERROR-LOOP/预期成功动作实际失败。
3. :84 31.2「动手前完成 4 维归因表…现象/直接原因/根因（5 Whys ≤5 层）/类别…分析未完成（4 维缺项）禁止执行 31.3 修复动作」。
4. :85 31.3「技能规则本体缺口 → 登记 Decisions Made + 提案写 notepad…本体修改走后续任务」。
5. :86 31.4「沉淀（强制，与 31.3 同一动作内完成）：notepad…What Didn't Work / Notes for Next Time…Prevention 列由 <待沉淀> 翻成实际措施」。
6. :88 31.5「下一 Phase 开工前 Read notepad…新任务 init-session 后 Read 上一 completed 任务 notepad…终验 Learning Gate…Root Cause 列非空」。
7. :87 31.7「普及化抽象（强制，与 31.4 同一动作内完成）…通用规则=规则名称|适用条件|具体措施」。
8. :91 31.8「制度层诉求（…确保不再出现/防复发/根治…）：交付物=规则文本变更…禁止偏差为修复引发问题的具体实例；实例层诉求…禁止擅自升级为改规则/技能本体；双层同时要求…先落制度层条款，再按用户显式范围处理实例」。
9. :107-112 Rule 33「任一问题解决动作完成后…反思四问…独立验证…沉淀联动…REFLECT-GATE」。
10. :129 36.2「归因前置门（防盲目修改）：『修改技能』禁止作为第一补救动作；必须先按 31.2 完成四维归因」。
11. :712 102.0「每次用户指令…先走反思门五问…B/C/D/E 类：先同步文档并落盘，再按文档执行」；:715 102.2「同步范围按实际判定类最小化…不过度扩张（Rule 88 射程限定）」。
12. :668 98.5「Rule 31=归因主链（本条触发面=31.3『数据源过时→记录面整理』路由的专职落点）」。
13. 触发流程步骤（消费侧锚）：skills/task-planner/SKILL.md:182 3c「错误立即写 Error Log（19.4）并同轮完成四步：记错误原文→Rule 31.2 四问根因→纠正→复验回填，未完禁下一动作」；:284「用户指出错误（Rule 31）→先 STOP 走 31.2 四维归因再修」；:146 T4「Rule 31.2 根因→推导链显式化落 findings」；check-complete.sh:1486/1489 LEARNING-GATE（L0 skip）；:1605/1608 REFLECT-GATE（L0 skip）；progress 模板 Error Log Root Cause/Prevention 列见本任务 progress.md:52-58（计划视图锚，仅佐证）。

## Q2 轻量档精确条件与"改回被改错的值"
- skills/task-planner/scripts/lane-detect.sh:7-9 L0=文件数≤3 ∧ 增删行≤20 ∧ 全 .md 无代码；L2=>8 文件 ∨ register-hooks-cj.ts ∨ 顶层 agents 定义 ∨ 跨≥2 顶层 skill 目录；禁滥用=①新增文件②critical-rules.md 新 Rule 段③代码文件改动。
- lane-detect.sh:78-85 L2 字面条件：`[ "$NFILES" -gt 8 ]`、hooks 注册、agents 定义、`[ "$NSKILLS" -ge 2 ]`。
- lane-detect.sh:99-102 `--trivial` L0：`[ -z "$l2_hits" ] && [ -z "$abuse" ] && [ "$NFILES" -le 1 ] && [ "$LINES_TOTAL" -le 3 ]`，CODE_HIT 豁免（:92）。
- lane-detect.sh:112-115 普通 L0：`[ -z "$l2_hits" ] && [ -z "$abuse" ] && [ "$NFILES" -le 3 ] && [ "$LINES_TOTAL" -le 20 ] && ! printf … | grep -qvE '\.md$'`。
- skills/task-planner/scripts/init-session.sh:610-619 trivial 前提：`TASK_SCOPE_FILES=1 ∧ TASK_SCOPE_MODULES=1 ∧ TASK_EST_MINUTES≤15 ∧ TASK_EST_LINES≤3 ∧ TASK_SCOPE_FILE_LIST` 唯一文件 ∧ 扩展名 sh/ts/cjs/js/py/json；:625-638 保护区路径（含 `skills/*|*/skills/*`）强制 `_trivial_code=0`。
- init-session.sh:663-684 auto-tier：未显式 tier ∧ `TASK_AUTO_TIER:-1=1`；①`TASK_TIER_EXCLUDE=1` 不降档；②`_trivial_code=1` → mini+L0（:671-674）；③`EST_MINUTES≤15 ∧ 1≤SCOPE_FILES≤2 ∧ SCOPE_MODULES=1` → mini（:675-680）；④输入缺失/非法保缺省档（fail-safe）。:646-659 env 全缺时读 .plan_scope。
- skills/plan-template-kit/references/critical-rules-template.md:51 L0-T 触发=变更面全部 .md ∧ 零新增脚本/零 config 键/零 hook（cap≤12）。
- :52 L0-E 三条件全满足=零仓库受管文件变更 ∧ 仅调用既有工具 ∧ 产物全落 gitignore 区；:53 L0-T 记 L0 括注、L0-E 记 L0-E；lane-detect 对 L0-T 自动判定仍 opt-in。
- 结论（条件分支，非单点臆断）："把某个被改错的值改回来"属实例层小改——① 非保护区单文件代码 ≤3 行且 env 齐备 → mini+L0（trivial）；② 纯 .md 文本值 → L0-T（或普通 L0）；③ 本仓 skills/ 源码为保护区：init-session.sh:631 命中 `skills/*` 使 trivial 失效，auto-tier 被 ④ 排除，回落 L1（显式 mini/L0-T 例外）；本任务计划头显式 execution_lane: L2 / plan_tier: standard（task_plan.md:2,15），显式优先（38.6 :46）不走 auto-tier。
- 跳过的分析环节：38.2(critical-rules-template.md:42) mini 跳 FMEA/知识储备表/委派统计/Batch；38.3(:43) 白名单仅 Goal/VC/2(→1)Phase/范围/Handoff；38.4(:44) FMEA gate 跳、VC 5→2、委派 floor 0.7→0.0、S-unit 表豁免、knowledge-brief 降为可选；init-session.sh:332-335,489-491 跳「用户需求原文/根源覆盖表/证据面清单/核心目标达成裁决」注入；SKILL.md:107 L0-T/mini 跳 plan-history-recall；SKILL.md:186-187 mini/L0 豁免 3f' 周期记忆回顾与 3g 规范召回；check-complete.sh L0 跳 STATE-CONSISTENCY(:127)/DELEGATION(:450)/DRIFT(:537)/FMEA(:622)/R-COVERAGE(:1070)/SESSION-LOG(:1367)/CR(:1449)/LEARNING(:1489)/REFLECT(:1608)/COMPLIANCE(:1764)，保留 LANE-L0 三段(:1949)、SKILL-MODIFY(:1637)、porcelain/report-lint。

## Q3 每次必发生驱动点
- skills/task-planner/scripts/sync-todos.sh:207-214 基线组 B1-B8（--json 自动带出，:201-204 注释）：B1 修改后验证 / B2 Phase翻转校验 / B3 终验VC复验 / B4 收尾回读 / B5 Todo终态 / B6 引擎检测 / B7 对齐核查 / B8 worktree核验。
- 单条完整结构（:207）：`{"task_id":"B1","phase":0,"status":"baseline","subject":"修改后验证"}`，字段四元组 task_id/phase/status/subject。
- 契约锚 skills/task-planner/references/todo-sync.md:35-40：S1 建两组、基线组生命周期、门禁挂钩、S3 丢失当次重建、mini 仅 B1 不豁免、本文件为唯一事实源。
- 判定：B1-B8 中无根因分析/防复发/后续任务登记项；根因闭环只在 LEARNING-GATE/REFLECT-GATE 与 Rule 31/33 侧，非 Todo 基线组。
- check-complete.sh 门清单（名称:锚）：porcelain :23/:101；3-File Gate :351；STATE-CONSISTENCY GATE :127；DELEGATION GATE :450；DRIFT GATE :537；SKIP-BY-HASH :558；PLAN-DISPATCH GATE :603；FMEA GATE :622；RESCUE-CHAIN GATE :707；VC-GATE :712（薄化 :892）；EVIDENCE-ANCHOR/R-COVERAGE GATE :735/:1059；report-lint :1252；SESSION-LOG GATE :1358；CR-GATE :1443；LEARNING-GATE :1486/1489；REFLECT-GATE :1605；SKILL-MODIFY GATE :1637；ALIGN-ANCHOR GATE :1673；COMPLIANCE-CHECK :1750；goal-gate :1825/1837；LANE-L0 GATE :1949；judge-gate :1997；ARCHIVE-GATE :2054；pointer-lifecycle 提醒 :2036（非门）。

## Q4 追加根因修复=范围扩张的条款
- critical-rules-discipline.md:558 88.1「射程=指令字面点名的内容域（对象+动作+范围三要素）…禁按『相关性』自行扩展——『顺手看到』…不构成射程扩展依据」。
- :559 88.2「本任务只对射程内对象产生写入…③把『发现的问题』直接修复（改为登记+报告，对齐 Rule 87.4④ 与 36.4）」；:560 88.3 呈报域收敛；:562 88.5「88 管『管得窄』」。
- :491 74.2 三判门「增量（默认且优先）…只追加、既有条目逐字保留不动，禁以『整合/去重/顺手重构/格式化』名义回写既有条目；(b) 替代（禁默认，四条件全满足才可）」；:492 74.3「无变更标注表的修订方案=无效方案，禁入执行」；:497 74.7「任何已确立规范/规则/验收约束/阈值/区间的修改或放宽…必须先在变更标注表逐条登记合规四元组」。
- 51.9：NONE FOUND（作为范围扩张条款）。grep 关键词：`51.9`、`Rule 51.9`、`51\.9`。命中唯一原文在 skills/task-planner/references/critical-rules.md:98「51.9 可计数交付物全 R 化（countable-deliverable R-row completeness…）：产出动词…可枚举件数 N≥1 必须各落为数字编号 R 行」——主题为计数交付物，不管辖范围扩张。相近替代：:87 51.1「逐条编号抄录用户原话（R1..Rn；禁转译/缩写/合并）」、:95 51.7「纠正=回锚重译，非设计增量…用户纠正/补充指令…追加为新 R 行」。
- 修A不修B：NONE FOUND（skills/ 源码内）。grep 关键词：`修 A 不修 B`、`修A不修B`、`用 X 不换 Y`、`范围扩张`、`射程外`、`不属本次`、`不在射程`。最近替代=critical-rules-discipline.md:546 87.4①「只改必须改的地方，不顺手『改进』相邻代码/注释/格式（36.5/74.2a 同向）」；:91 31.8②「实例层诉求…禁止擅自升级为改规则/技能本体」；SKILL.md:284/102.2 最小化同步。
- 结论：把阶段二根因排雷塞进阶段一"修同一个问题"的动作域，命中 88.2③（发现的问题改为登记+报告）、74.2/74.3（须标注表且默认只增量）、87.4①（只改必须改处）；须由用户原话新 R 行/显式授权（51.7/102.2）才能合法并入，或按用户裁决建新计划（Rule 8.1/102.1 D 类）。

## 未决/建议
- 未决：① trivial 是否触发取决于主进程提交 env（TASK_SCOPE_FILES/LIST/EST_LINES/MINUTES/TIER_EXCLUDE），静态源码无法判定具体一次调用；② 51.9/修A不修B 在用户全局宪法 §四/§十三有语义，但本任务限定 skills/ 源码，故未取为仓内条款。
- 建议：① 阶段一VC显式写"根因线索包=登记产物，不改源文件"；② 阶段二独立计划目录 + worktree，引用 Rule 31.2 四维表与 notepad 消费链；③ 若要机器化"后续根因任务登记"，现成落点是 notepad「Notes for Next Time」+ Todo 基线组外新增任务组项，而非改 B1-B8 固定清单。
