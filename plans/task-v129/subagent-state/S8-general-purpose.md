# S8 alignment-review checkpoint

status: complete
started_at: 2026-10-04
finished_at: 2026-10-04
scope: read-only alignment review of worktree task-v129 (git diff master...HEAD, 2 commits, 6 files)
task: 四面同步对齐审查 (Rule 42.6.2)

## 结论：CHANGES_REQUESTED（2 项，均轻量；Rule 51 本体四面基本对齐）

### 已核对通过项（证据）
- 条款面 critical-rules.md:522-530：Rule 51 六子条 51.1-51.6 全在位（^51.=6, ### 51 @522, 全文 530 行）；51.1=需求原文锚定/51.2=覆盖判据/51.3=需求覆盖核对表/51.4=自缩水禁令+silent 注记/51.5=前置盘点+Rule26/51.6=零新键+守护。^50.=0（编号无冲突）。
- SKILL 面：C35@201（行首 | C35 |）、bullet@286、References@310、括注@249；SKILL=451 行；'Rules 1-39'=2、'1-40'=0。
- 模板面 delivery-summary.md:35-41：区块「需求覆盖核对（Rule 51.3）」+ 列 = 需求#/用户原话（摘）/判定(covered/partial/uncovered)/证据路径 + 51.1 豁免行注记，与 51.3 一致；5 个编号区块保持（TL-19=5）。
- 守护面：selftest-requirement-coverage.sh 15 断言 15/15 PASS（RC-01..RC-15）；selftest-skill-split.sh:41 ≤449→≤451 且实测 451，41/41 PASS；registry.tsv 47 行 / 46 数据行（+1）/ 新行 NF=4；script 数=46；新脚本 chmod +x；registry.sh 5/5 PASS。
- 引用完整性：Rule 41 G4@41.2:418 ✓、Rule 26@214 ✓、SKILL C35@201 ✓、templates/delivery-summary.md 区块@35 ✓、19.5@113 与 check-3file-gate.sh ✓（51.6 承诺真实锚）。
- 邻锚无回归：template-lifecycle 24/24、lane-advancement 14/14、reliability-institution 12/12 全 PASS；config properties=40（零新键）。

### CHANGES_REQUESTED 明细
1. [不一致] skills/task-planner/SKILL.md:249 —— 括注枚举 `（Rules 1-39（含 Rule 40/41/42/43/44/45/46/47/48/51））` 跳号漏列 Rule 49（49 块真实存在于 critical-rules.md:506-520，且同文件 :310 References 行已列 49）。
   建议修法：`.../47/48/49/51`（仅补 "49/"，保留 '含 Rule 40/41/42/43' 子串 + 'Rules 1-39'=2 不变，无 selftest 破坏）。注：49 的遗漏系 v126 遗留，本次 task-v129 触碰该行未一并修正。
2. [术语不一致] skills/task-planner/SKILL.md:286 —— bullet 首词 "目标原文锚定" 与条款 51.1 子条名 "需求原文锚定" 不一致（task_plan.md Goal 正文亦用 "需求原文锚定"，仅标题行/5Whys 用 "目标原文锚定"）。
   建议修法：bullet 改为 "需求原文锚定+验证机制先行+…"（与条款子条名逐字对齐）。
   （注：RC-03 只断言 CRIT 侧 "需求原文锚定"，SKILL 侧无断言，故未暴露。）

### 已登记但判定为"可接受"的观察项（不要求修改）
- SKILL.md:310 References 行 51 排在 49 之前（…48/51/49）——受 v126 LA-11 右括号锚 `'Rule 49 单元线多路并行推进）'` 约束（51 必须前插），属计划明示取舍（F-6.1 #10 / F-7 S2 裁决③），接受。
- 模板 heading 用「需求覆盖核对」（区块名）而条款工件名用「需求覆盖核对表」——51.3 自身即区分（区块 vs 表），四面语义一致，接受。
- SKILL C35 未逐字出现术语「覆盖判据」/「需求覆盖核对表」中箱——C35 以条文号（51.1/51.2/51.3）引用，语义等价，接受。

### 变更记录三要素草稿（42.6.3，供交付总结消费）
- 变更对象：critical-rules.md:522-530（Rule 51 六子条）；SKILL.md:201/249/286/310（C35+括注+bullet+References）；templates/delivery-summary.md:35-41（需求覆盖核对区块）；scripts/selftest-requirement-coverage.sh（新）+ selftest-registry.tsv（+1）+ selftest-skill-split.sh:41（断言值级联）。
- 变更类型：纯增量（Rule 36.5）——新条款/新消费点/新模板区块/新守护脚本 + 1 处行数断言级联值（449→451）；零功能性删除/零语义改写。
- 影响面：运行行为=新增静态守护纳入全量回归（46 脚本）；SKILL 行数 449→451；零新 config 键（properties=40 不变）；消费面=SKILL 合规 C35 + delivery-summary 交付必载区块；不涉 check-complete.sh（deferred）、videop1（只读）、agents/commands/config。

files_touched: none（本审查只读；仅写本 checkpoint）
