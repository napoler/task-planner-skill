# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1-R6 见 task_plan.md「🎯 用户需求原文」区块(逐字抄录,禁转译);本文件只记根因与证据,不重复需求正文
- 子代理任务:Rule 43/51 缺陷根因分析 + 修改方案设计(43.5/43.6、Rule 26 触发面、SKILL.md 门控、selftest 断言),产出 findings.md + modification-plan.md

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 43/51/26/53 条款正文 | `skills/task-planner/references/critical-rules.md` L224-252 / L449-456 / L556-567 / L581-587 | ☑ 已消费 | §根因分析 G1-G4 |
| SKILL.md 门控面(C 清单/摘要 bullet) | `skills/task-planner/SKILL.md` L199 / L204 / L299 / L304 / L330 | ☑ 已消费 | §级联影响面 |
| selftest-reliability-institution.sh 断言 R-01..R-12 | `skills/task-planner/scripts/selftest-reliability-institution.sh` L35-93 | ☑ 已消费 | §根因 G4 + §可检测性 |
| selftest-requirement-coverage.sh 断言 RC-01..RC-22 | `skills/task-planner/scripts/selftest-requirement-coverage.sh` L26-487 | ☑ 已消费 | §根因 G4 + §可检测性 |
| 级联守护 | `scripts/selftest-skill-split.sh` L41(SKILL ≤477 行阈值) / `scripts/selftest-registry.tsv` L41/L50 | ☑ 已消费 | §级联影响面 |

## Research Findings

### 前置处置:worktree 基线陈旧(阻塞级,已修复)
- **现象**:派发 prompt 指定的 worktree `/home/terry/task-planner-skill-worktrees/task-v133` 停在 `15a3ecf`(旧 sync 提交),其中 `skills/task-planner/references/critical-rules.md` 仅 44 行(Rules 1-11),**不含 Rule 43/51 正文、无 selftest 脚本、SKILL.md 仅 113 行**——按任务书路径直接分析将全部落空。
- **处置**:worktree `git status` 干净后执行 `git reset --hard 54f6fe2`(master tip,含 task-v131/v132 全部落地内容);复位后 4 个目标文件与主仓 `/mnt/data/dev/task-planner-skill` 逐字节一致(diff -q ALL_IN_SYNC),分支 `wt/task-v133` 现在 54f6fe2,工作树干净。主仓未受任何影响(主仓 plans/ 下的未提交文件状态前后一致)。
- **证据**:`git log --oneline -1` → `54f6fe2 Merge branch 'wt/task-v132'`;`diff -q` 四文件 → `ALL_IN_SYNC`;`wc -l critical-rules.md` → 587 行。
- **置信度**:HIGH。

### 根因分析:Rule 43/51 为何未拦住「未测试就声称完成 + 零消耗宣传」

**G1 — Rule 43 缺「提示词/参数优化类修改」的修改后实测义务(覆盖 VC-2/VC-5)**
- 43.1(L453)只约束「已完成/正确/通过」类声称须附证据,43.3(L455)只约束**呈报前**候选预验证——两者都是「声称侧/决策侧」纪律,**没有一条规定「生成参数(提示词/参数/seed/模型)被修改之后,必须实际跑一次生成并做质检才算完成」**。事故行为=修改后不跑生成就把「额度消耗 0」当优点呈报:该行为不落在 43.1 的「已完成」声称模式里,也不落在 43.3 的「候选呈报」里,是**修改后验证(verification-after-modification)空档**。
- 文本证据:`grep '提示词' critical-rules.md` 在 Rule 43 段零命中;Rule 43 四子条(43.1-43.4)无任何「实际生成/实测」锚。Rule 47.3(批量生成试点先行)管的是**批量生成前**首单元试点,不是**提示词修改后**的单点实测;Rule 35.6(最小探针)管的是验证动作最小化,不是参数修改必须验证。
- 相关但不对口:Rule 50(程度/权重评级)+47(媒体工序)对 image 族任务有质检链,但它们是**任务类型画像层**(template_type 命中才激活),提示词优化型修改即使不在媒体族任务内(如技能自身的 agnes 图像生成参数)也无任何条款兜住——事故正是发生在技能维护语境。

**G2 — Rule 51 缺「未测试就声称完成」的显式禁止与降级语义(覆盖 VC-1)**
- 51.3(L563)完成声称对照门有「uncovered/partial → 禁 COMPLETE」语义,51.2 覆盖判据定义了证据形态——但 51.x 七子条**没有一条写明:覆盖判据属「实际生成/实际测试」形态的需求条目,在无实测证据时不得声称 covered,且成本/数量类统计(如「零消耗」)不构成验证证据**。事故中「额度 0」是一个**真实但无验证力**的数字被当作优点宣传——51.5(L565)前置盘点管的是「生成前查库存」,管不住「修改后拿统计数自我表扬」。
- 文本证据:`grep -c '未测试' critical-rules.md` = 0;`grep '零消耗'` 全文仅 1 命中(L165 22.3.1 provider 失败改派语境,与本缺陷无关)。

**G3 — Rule 26 惩罚映射缺「未验证优点宣传/未测试声称完成」触发面(覆盖 VC-3/VC-4)**
- 26.1(L229-234)Q1-Q6:Q2 管 Test Results 缺失、Q3 管**证据伪造/篡改**(Read 失败/输出矛盾)——「零消耗宣传」中统计数字本身为真,不属于 Q3 伪造,属于**未验证结果的正向化呈现**,Q1-Q6 全部不命中 → 26.3 惩罚表(L240-246)无行可挂 → 违规无确定性处置。
- **编号冲突裁决(重要)**:任务书建议「Rule 26 增加 Q7」,但现仓库中 **Q7(惰性推诿)/Q8(无根治判据)已被 Rule 53(53.2/53.3/53.5)占用**,且 53.5(L587)明文登记「触发面=Q7 惰性推诿/Q8 无根治判据(均挂 26.3 惩罚映射语义消费,不扩 26.1 既有 Q1-Q6 枚举)」——这是既有先例:触发面在属主规则登记、挂 26.3 语义消费、不扩 26.1 枚举。故本方案采用 **Q9**(顺延 Q6+1,沿 Q7/Q8 先例),不改 26.1 枚举,仅:①26.3 表新增 Q9 处置行 ②53.5 触发面登记追加 Q9。
- 文本证据:`grep -n 'Q7\|Q8' critical-rules.md` → L584/585/587 三处(全在 Rule 53);`grep -c 'Q9' critical-rules.md` = 0(可用)。

**G4 — 两个 selftest 脚本的断言缺口(覆盖 VC-6)**
- `selftest-reliability-institution.sh`:R-02(L38-40)硬断言 `grep -c '^43\.' = 4`——**新增 43.5/43.6 必须同步把 R-02 演进为 =6**(先例:R-01 5→10 task-v102、RC-01 6→7 task-v132 阈值演进注记范式);R-05..R-07 是「行内语义锚」范式(grep '^43.N' | grep -q 词),新断言照此范式补 43.5/43.6/Q9 行/C37 四锚;**全文无任何提示词优化/实测/未验证宣传锚**。
- `selftest-requirement-coverage.sh`:RC-01(L33)`grep -cE '^[[:space:]]*51\.'` ≥7(现行实测=8,加 51.8 后=9,≥7 不受影响,零改动);RC-15(L166)负断言 `'^54\.' = 0`(51.8 不产生 54 号,不受影响);需新增 51.8 行锚 + SKILL「51.8」联动锚;SKILL.md bullet(L304)与 C35 行(L203)未含新语义。
- 级联面(超出任务书文件清单,需登记):①`selftest-skill-split.sh` L41 硬阈值「SKILL.md ≤477 行」——新增 C37 行后 SKILL.md=478 行,该断言必 FAIL,须演进 477→478(先例:同断言演进链 440→…→475→477);②`selftest-registry.tsv` L41/L50 两行的 trigger_scenarios/dep_anchors 列须追加(36.6a 双向一致性;行内编辑必须保持 tabs=3,先例 task-v131 Phase 9 registry 行 tabs 事故)。

### 现有 selftest 断言可扩展点清单(方案依据)
| 扩展点 | 现行为 | 扩展方式 |
|--------|--------|---------|
| R-02 `^43.` =4 | 硬等值 | 演进为 =6(注释加 task-v133 演进注记) |
| R-05..R-07 范式 | 行内语义锚 | 新增 R-13(`^43\.5`∧「实际生成测试」)/R-14(`^43\.6`∧「未验证优点」)/R-15(`^\| Q9 ` 26.3 行)/R-16(SKILL `\| C37 \|`=1∧「未测试」) |
| RC-01 ≥7 | 阈值下界 | 零改动(9 仍 ≥7),注释可加实测说明 |
| RC-22 之后 | 脚本尾部 Total 前 | 新增 RC-23(51.8 行锚=1 + SKILL「51.8」联动 ≥1) |

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新增 43.5(提示词/参数优化必须实际生成测试)+43.6(未验证结果禁优点宣传) | 挂 Rule 43 执行可靠性制度化,与 43.1 证据先行同层;纯追加子条不动 43.1-43.4 原文(Rule 36.5) |
| 新增 51.8(未测试就声称完成禁令) | 挂 Rule 51 完成声称门控,补 G2 缺口;沿用 51.7 的子条编号位(51.8 空闲,RC-15 负断言 '^54.' 不受扰) |
| Rule 26 用 Q9 而非任务书建议的 Q7 | Q7/Q8 已被 Rule 53 占用且 53.5 明文「不扩 26.1 枚举」先例;Q9 沿同先例=26.3 加处置行 + 53.5 登记追加,零 26.1 枚举改动 |
| SKILL.md 新增 C37 合规行 + C31 行内追加 + Rule 43/51 bullet 行内追加 | 消费侧三件套范式(RC-10/C35、RR-08/C36 先例),C37 为唯一新增行(+1 行,级联 skill-split 阈值) |
| 修改方案文档落在 plans/task-v133/modification-plan.md,实施交 Phase 2 | Phase 1=分析+方案(本产出);方案逐字逐句落定,Phase 2 按行号实施 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| worktree 基线停在 15a3ecf(缺 Rule 43/51 正文与 selftest 脚本),按任务书路径无法分析 | 干净复位 `git reset --hard 54f6fe2`(仅移动 wt/task-v133 分支指针,主仓零触碰);复位后四文件与主仓逐字节一致再开工 |
| 任务书建议的「Rule 26 Q7」编号与现状冲突(Q7/Q8 已被 Rule 53 占用) | 改取 Q9 并沿 53.5 既有先例(触发面登记挂 53.5、不扩 26.1 枚举);差异在 modification-plan.md 显式登记 |
| C37 新增行使 SKILL.md 477→478,触发 selftest-skill-split 阈值断言 FAIL | 登记为级联演进项(skill-split 477→478 + registry 两行),属 task_plan「执行范围限制」表外文件 → 列入 modification-plan 需用户确认段(VC-6 前置决策项) |

## 实施回填（Phase 2/3 — 2026-10-05 M1-M8 逐条执行）
- **M1/M2 落地**: critical-rules.md L457/L458 新增 43.5（提示词/参数优化必须实际生成测试，取证三件套=生成回执+产物 Read/image-understand+Rule 50 评级）/43.6（未验证结果禁止作为优点宣传，「0 消耗」≠验证证据，Q9 触发面挂 26.3 语义+53.5 登记，Q3 伪造档同档）；判例锚=task-v133 用户 R2/R3/R5 原话。
- **M3 落地**: L570 新增 51.8（未测试就声称完成禁令三子款：①无实测证据禁 covered ②未测试结果禁优点宣传 ③成本/额度统计禁充当覆盖证据——51.5「零生成」盘点平面与 51.8「参数修改必附实测」平面由产物性质区分；违规=uncovered+Q9 语义，终态禁 COMPLETE 只可 PARTIAL）。
- **M4 落地**: 53.5 行内替换「触发面登记=Q7/Q8…」→「Q7/Q9 登记（Q9 属主条款=43.5/43.6/51.8，task-v133 登记）」，旧串全文唯一命中=1，53.2/53.3 零误触。
- **M6.4 落地**: 43.4 机制行「43.1/43.2/43.3/43.4 四子条锚」→「43.1-43.6 六子条锚（task-v133 增 43.5/43.6 级联）」（RC-01 口径演进先例）。
- **M5 落地**: SKILL.md +C37 合规行（L205）；C31 行内追加 43.5/43.6 消费语义（L199，'| C31 |' 计数仍=1 零回归）；Rule 43 摘要 bullet 行末追加（L299）；Rule 51 bullet 枚举七→八子条（L304，task-v132 P2 先例）。SKILL.md 477→478 行。
- **M6 落地**: selftest-reliability-institution.sh R-02 演进 `^43.` 4→6（头注释+断言体）+R-13（43.5 行内锚「实际生成测试」）/R-14（43.6 行内锚「优点」）/R-15（53.5 行 Q9 登记锚）/R-16（SKILL `| C37 |`=1）全 PASS（16/16）。
- **M7 落地**: selftest-requirement-coverage.sh 头注释 L4 追加 task-v133 注记 + RC-23（`^51.8 ` 行锚=1 ∧ 语义锚「未测试就声称完成」∧ SKILL「51.8」联动 ≥1）PASS（23/23；RC-01 计数 9≥7、RC-15 '^54.'=0 均不破）。
- **M8 落地**: selftest-skill-split.sh L41 阈值 477→478（注释追加「task-v133 C37 合规行 +1」演进注记）；selftest-registry.tsv L41（domain 追加 43.5/43.6 语义 + dep_anchors 追加 C37/Q9）/L50（trigger 追加 51.8 + dep 追加 51.8/Q9）两行内编辑，tab 结构 3 tab=4 fields 保持（先例 task-v131 tabs 事故零复发）。
- **全量回归**: 51 个 selftest-*.sh 全 PASS 0 FAIL（含 selftest-skill-modify SM 计数、selftest-root-resolution RR 负断言、selftest-registry registry rows=51 双向一致）。
- **负结果自查**: 「Q9」全文命中=3（43.6/51.8/53.5 三处受控出现，非误插；R-15 锚限 `^53\.5` 行=1）；既有「零消耗」L165 provider 语境未被新条款误触；properties=40 零新键维持（R-12/RC-13 PASS）。

## Resources
- `plans/task-v133/modification-plan.md` — 完整修改方案(逐字逐句 + 文件:行号 + 理由 + VC 映射 + 级联清单)
- `skills/task-planner/references/critical-rules.md` L224-252(Rule 26)/ L449-456(Rule 43)/ L556-567(Rule 51)/ L581-587(Rule 53)
- `plans/incident-reports/2026-10-05-72h-instruction-mutation.md` — 同类事故判例(51.1 判例锚先例,本任务 43.5/51.8 判例锚写法参照)

## Visual/Browser Findings
- 无(本 Phase 纯静态分析,无多模态内容)

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
