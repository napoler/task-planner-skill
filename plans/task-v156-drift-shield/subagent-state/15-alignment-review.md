# 15-alignment-review — task-v156 收尾对齐审查（Rule 42.6.2）

- **审查体**：alignment-review 技能标准流程（先读 SKILL.md 方法论：全文扫描→对照→证据→二值结论）
- **审查对象**：worktree `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment`，HEAD=`a2bd2ba`，基线 `git diff a538a3a..HEAD`（12 文件，+206/-6）
- **需求锚（51.1a）**：R2=四文件三态强化（不变/可变/学得显式化）；R5=歧义词带解释层、为犯错堵漏洞
- **审查模式**：纯只读（Read + 只读 grep/diff + 只读执行 selftest）；零修改、零 git 写操作

## 审查对象总清单（Rule 70①）

| # | 文件（worktree 内绝对路径前缀 `/mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/`） | 一句话 |
|---|------|--------|
| 1 | `skills/task-planner/references/critical-rules.md` | Rule 73 段（:944-958，七子条纯 EOF 追加） |
| 2 | `skills/task-planner/SKILL.md` | K1-K6 六处接线（:9/:90/:234/:251/:300/:361/:387） |
| 3 | `skills/task-planner/templates/deprecated.md` | 新建五段废弃隔离模板（32 行） |
| 4 | `skills/task-planner/templates/task_plan.md` | 「🔒 不变量声明区」区块（:31-38） |
| 5 | `skills/task-planner/scripts/check-complete.sh` | [judge-gate] 强制评判段（:1325-1351） |
| 6 | `skills/task-planner/scripts/zcode-posttooluse.sh` | [judge] 节奏注入（:355-359） |
| 7 | `skills/task-planner/scripts/selftest-decision-drift.sh` | 新守护脚本（DD-01~22+DD-14b，23 断言） |
| 8 | `skills/task-planner/scripts/selftest-drift-check-subagent.sh` | 存量锚宽容化（DCS-11，:61 1 行） |
| 9 | `skills/task-planner/scripts/selftest-reliability-institution.sh` | 存量锚宽容化（R-09，:85 1 行） |
| 10 | `skills/task-planner/scripts/selftest-root-resolution.sh` | 存量锚宽容化（RR-09，:110 1 行） |
| 11 | `skills/task-planner/scripts/selftest-parallel-scheduling.sh` | 存量上界解析宽容化（P-05，:107 1 行） |
| 12 | `skills/task-planner/scripts/selftest-research-first.sh` | 存量锚宽容化（RF-07，:76 1 行） |
| 13 | `skills/task-planner/scripts/selftest-registry.tsv` | 自登记行（:73，NF=4） |
| 参照（只读未改） | 仓根 `CLAUDE.md:33`、`README_zh.md:136,229`；主仓 `plans/.rule-reservations.jsonl`；master 现状 CR Rule 72/74 | 计数标签/账本/并行任务合并态对照 |

## 逐文件对齐结论表

| 文件 | 对齐维度 | 结论 | 证据（file:line / 命令输出） |
|------|---------|------|---------------------------|
| critical-rules.md Rule 73 | 格式范式（参照系一） | PASS | 块头 `### 73` 于 :944，子条 `73.1`-`73.7` 内联加粗编号于 :946/:948/:950/:952/:954/:956/:958——与 Rule 67(:861)/68(:877)/69(:892)/71(:928) 的 `### NN`+`NN.x **粗体**` 范式逐字同构；Rule 70/72 的 `### NN.x` 标题式为文件内并存另一既有范式（70.1-70.6、master 72.1-72.6），非本分支引入 |
| critical-rules.md Rule 73 | 纯增量/零删除 | PASS | `git diff a538a3a..HEAD --numstat -- critical-rules.md`=16/0；`git diff \| grep -c '^-[^-]'`=0（Rule 1-71 既有行零改动，Rule 36.3 基线守住） |
| critical-rules.md Rule 73 | 计数口径 | PASS | 独立 `grep -cE '^73\.[1-7] '`=7（VC-1 声称复现）；`grep -c '对齐'`=43（复现） |
| critical-rules.md Rule 73 | 交叉引用有效性 | PASS | 73.2/73.5/73.6 引用的锚全部在文内有定义：29.2a=2、32.2=5、32.4=3、51.8=10、65.4=3、69.1=2、8.1=21、66.1=3、Rule 28=11（grep -cE 全 ≥1，无失效引用） |
| critical-rules.md Rule 73 | 术语消歧义（R5） | PASS | :956 73.6 含示范「不变量（invariant，指 Goal/VC/用户原话类…；反例=可变量）」；deprecated.md §5 三废弃类型词条各带判据解释；SKILL:361 摘要与 73.x 语义一致（五类决策点=73.1 五项） |
| critical-rules.md Rule 73 | 与 Rule 72 关系表述 | PASS（附已知项 K2） | :948 措辞「Rule 72 由 task-v160 在途落地，未落地前一律按 Rule 28 呈报」——基线 a538a3a 态 72 未入 CR（实测 `git show a538a3a:…critical-rules.md` 无 72 锚）=措辞当时准确；master 现已落地 72=合并期更新项 |
| SKILL.md K1-K6 | bullet/C 清单格式（参照系二） | PASS | :361 Rule 73 bullet 与相邻 Rule 67/68/69/70/71 bullet 同构（粗头+分号子条+机制尾注）；:234 C51 行与 C48-C50 同构（机器面+mini 豁免括注）；插入位在 Rule 71 bullet 后=续既有「新条追加于最新条之后」惯例（列表既有非升序 67,68,71,69,70） |
| SKILL.md K1-K6 | 计数口径 | PASS | :9「1-69+70」→「1-71+73」（修复 v158 漏改存量缺陷+计入本分支 73，基线态 CR 实有 1-71）；:300/:387 同步；独立复测 `grep -c 'Rule 73'`=5、`grep -c 'C51'`=2、`grep -c '1-71+73'`=3（VC-5 声称全复现）；旧「1-69」残留仅在 :112 v159 历史 dated 注释（非活动计数） |
| SKILL.md K1-K6 | 决策点对齐接线 | PASS | :90 委派检查点段「变更型决策点…按 Rule 73.1 判定、73.2 对齐三问后再派发」；:251「B/C 类变更执行前按 Rule 73.2 对齐三问…」——两处均为纯插入 bullet，未改写既有语义 |
| deprecated.md | 结构/五要素 | PASS | 五段标题 :10/:16/:21/:26/:29；登记表六列含五要素（原内容指针/废弃类型/废弃原因/日期/替代锚）:11-14；`grep -c '废弃'`=14（≥5）；WHAT/WHY/WHEN 头部注释齐备；与 Rule 73.5 逐项对应 |
| deprecated.md | 逐字采用源 | PASS | `diff <(sed -n '62,93p' design-draft.md) deprecated.md` → VERBATIM_IDENTICAL（复跑确认零差异） |
| templates/task_plan.md | 模板区块顺序（参照系三） | PASS（附 MINOR M2） | 🔒 区块 :31-38 位于 根源覆盖表(:20)+plan_tier 注释(:29) 之后、Goal(:40) 之前；三态词独立复测 不变量=4/可变量=2/学得量=2（VC-3 复现）；模板内部顺序自洽 |
| check-complete.sh | 门控范式/档位契约 | PASS | [judge-gate] :1325-1351：plan_tier 前置门 :1334（同 goal-gate :1288 范式）+ 三 env 档（off/enforce/warn）+ 06b 计数鲁棒化（`\|\| true`+case 归零）；SKIPPED 文案引 Rule 73.4/C51 与 C51「mini 档豁免」契约一致；`bash -n` rc=0 |
| zcode-posttooluse.sh | 注入范式/env 降档 | PASS | :355-359 `_jr` 段随 drift-rhythm due 同发、emit 行尾 `${_cp}${_jr}`（原 `${_cp}` 全保留，唯一 `-` 行为指定行替换）；hook 侧默认 on/`off` 抑制=Rule 73.4「=off 跳过」语义（enforce 档在 check-complete 侧消费，两处无矛盾）；`bash -n` rc=0 |
| selftest-decision-drift.sh | 断言面/自洽性 | PASS | 独立复跑（cwd=worktree）23/23 PASS EXIT=0；头部自述「DD-01~22 + DD-14b」与 Total:23(:111) 自洽；DD-14b 档位门控断言 :66-71；DD-19 解析链实走绝对路径回退分支 PASS；DD-20 config=42 复现；`bash -n` rc=0 |
| 5 存量 selftest | 锚宽容化/负断言保留 | PASS | DCS-11 :61 / R-09 :85 / RR-09 :110 / P-05 :107 / RF-07 :76 各 1 行纯 pattern 替换；独立复跑 rc 全 0（20/20、16/16、17/17、9/9、12/12）；负断言行原位保留（RR-09 m 断言 :111、R-09 b 断言 :86，语义未放宽）；diff 各 1/1（参照系含 S9 例外登记=范围内） |
| selftest-registry.tsv | 登记联动 | PASS（附 MINOR M1） | :73 新行 NF=4 与表头（script/domain/trigger_scenarios/dep_anchors）一致；DD-18 自登记=1 复跑通过；行内 dep_anchors 八路径全部实存（critical-rules/deprecated/task_plan/check-complete/posttooluse/SKILL/registry/config） |
| 仓根计数标签（参照系四） | 未触碰确认 | 已知项 K1（非缺陷） | `git diff a538a3a..HEAD --name-only`=12 文件全在 `skills/task-planner/**`，CLAUDE.md/README_zh.md 零触碰；现状 CLAUDE.md:33、README_zh.md:136/229=「Rules 1-71」——master 已至 1-74，合并期统一更新 |
| master 并集（参照系五） | 撞号排查 | 已知项 K2/K3（非缺陷） | master(b6d1594) CR 实态：Rule 71(:933)、**Rule 74=task-v162(:949)**、Rule 72=v160(:958)，**Rule 73 空缺**（v162/v163 占 74/75 跳过 73=无撞号）；v156 分支计数「1-71+73」相对其基线 a538a3a 正确 |

## 全量回归（本审查独立复跑，机器证据）

```
命令（cwd=worktree 根）：for f in skills/task-planner/scripts/selftest-*.sh; do out=$(timeout 120 bash "$f" 2>&1); rc=$?; … done
结果：72/72 rc=0；ΣFAIL=0；ΣPASS=1062（=基线 1039 + 新脚本 23，DD-14b 于 S10 落地后口径）
日志：/tmp/v156-align-review-regression.log（72 行+DONE 行，grep -vc 'rc=0'=1 仅 DONE 行）
```

## 问题清单

**BLOCKER（P0）= 0**——无失效引用（Rule 73 引用的 9 类锚全验存）；无机器计数矛盾（全部声称值独立复现）；无术语与条款定义漂移（73.6 消歧义示范+deprecated §5 词条+R5 需求锚落地）。

**MINOR（不阻断，建议合并期或后续顺手处理）**：

- `[MINOR] skills/task-planner/scripts/selftest-registry.tsv:73` — 描述「静态 DD-01~22」滞后于实际 23 断言（DD-14b 于 S10 新增；selftest :2 头部与 :111 Total 均已自洽为 23）。非机器断言面（DD-18 只判行存在），且已在 findings `[sub:13-executor]` 末行登记为待协调者裁决项。建议修法：描述改「静态 DD-01~22+DD-14b（23 断言）」。
- `[MINOR] templates/task_plan.md:31 vs 主仓 plans/task-v156-drift-shield/task_plan.md:52` — 模板 🔒 区块在 Goal 之前，计划实例 dogfood 区块在 Goal(:48) 之后——存量计划补建插入位与模板顺序不一致；DD-19 只判存在不判位，无功能影响。建议修法：下次编辑该计划时（或合并期簿记）将区块移至 Goal 前，或接受为存量补建形态并登记。
- `[MINOR] 5 个存量 selftest（selftest-drift-check-subagent.sh:61 / reliability-institution.sh:85 / root-resolution.sh:110 / research-first.sh:76）` — ok/bad 消息文案仍写旧锚字面（如「40-69/40-71」「现状 1-62」「头注 1-71 全集」）与随动后 pattern 滞后；且 4 个带历史注释块的文件未追加 2026-10-10 task-v156 演进注释行（DCS-11/R-09/RF-07/RR-09 注释块均逐纪元登记，本纪元漏登）。沿该族文件既有惯例（历史演进同样只改 pattern 未回改消息），无机器影响；Rule 45 注释完整性轻微缺口。
- `[MINOR] plans/task-v156-drift-shield/verification.md:20` — VC-5 证据称「ΣPASS=1061=基线 1039+新 22」为 S10 前 R2 值；S10 加 DD-14b 后机器实态=1062/23（本审查独立复跑证实，72/72 rc=0 ΣFAIL=0 结论不变）。簿记数字陈旧 1，不影响任何判定。建议修法：更新为 1062/23 或标注该值为 pre-S10。

**已知并集项（合并期处理，非本分支缺陷）**：

- `[KNOWN-K1] CLAUDE.md:33 / README_zh.md:136,229` — 「Rules 1-71」标签未随本分支更新（本分支 scope 不含仓根文件）；master 已 1-74 → 合并期统一改。
- `[KNOWN-K2] critical-rules.md:948 + SKILL.md:9/:300/:387` — master 已落地 Rule 72(:958)/74(:949)，Rule 73 空缺无撞号；分支计数「1-71+73」基于 a538a3a 正确。合并期并集解：SKILL 计数行取「1-74」或插入形态「1-71+73+74」；Rule 73.2「在途 Rule 72」措辞在 72 已落地后需更新（语义无损：72 落地即走分级）。
- `[KNOWN-K3] 合并期 selftest 级联预警（本审查新增发现）` — 若合并后 SKILL 计数行取 master 现值「1-74 / 40-74 全集」（master:301/:389 实测），则 DCS-11（pattern 需 `40-(69|71,73)` 前缀）与 RF-07（需字面 `1-71`）两锚将失配（同 v156 S7→S9 级联类）；P-05/RR-09/R-09 两种写法均 PASS。建议：合并写法保留插入形态「1-71+73+74 / 40-71+73+74 全集」，或合并后随动更新两锚并重跑回归。
- `[PENDING-K4] plans/.rule-reservations.jsonl` — Rule 73 无账本登记（grep `rule":73`/`task-v156` 均 0；67/72/74/75 均有记录）；task_plan Phase 6「land 73」为计划内待办——合并前须补登记，使 73 号有账本归属（v162 占 74 的既成事实已反证 73 被并行任务避让）。

## 需求锚覆盖确认（R2/R5）

- **R2（三态强化）**：73.3 三态定义（:950）+ 模板 🔒 区块（templates/task_plan.md:31-38）+ 计划实例 dogfood（task_plan.md:52-59）三位落地；deprecated.md 把「学得量/废弃内容」与正确内容隔离——「哪些不变/可变/学得」在条款、模板、实例三层可 grep。
- **R5（消歧义）**：73.6（:956）歧义词解释层纪律+两处示范（CR 条文括注、deprecated.md §5 三类型判据）；C51(:234)/SKILL:361 摘要口径一致，无术语漂移。

## 变更记录（三要素）

| 字段 | 值 |
|------|-----|
| 变更范围 | **零修改，仅审查**——本检查点为本次审查唯一写入产物；审查对象 13 文件+参照系全部只读（Read/grep/diff/只读执行 selftest），未触碰任何 skill 文件、未执行任何 git 写操作（worktree `git status` 保持干净，HEAD 仍=a2bd2ba） |
| 冲突处理结果 | 发现 4 项 MINOR（M1 registry 描述滞后 / M2 模板-实例区块顺序 / M3 存量 selftest 消息文案+注释欠账 / M4 verification.md 簿记 1061→1062 陈旧）——均已回答「建议修法」待协调者裁决，本审查不代改；4 项已知并集/待办（K1-K4）登记移交合并期；无未决残留冲突 |
| 文档当前状态 | 审查对象自身一致性：BLOCKER=0、MINOR=4（均不阻断、无机器断言面/引用面影响）；全量回归 72/72 rc=0 ΣFAIL=0 ΣPASS=1062；静态对齐结论=**PASS** |

## 最终结论

```
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: none（纯审查）
evidence: critical-rules.md:944-958（Rule 73 段,73.1-73.7 内联编号与 Rule 67-71 范式同构）;SKILL.md:9/:300/:387（1-71+73 三处,复测 Rule73=5/C51=2/1-71+73=3）;deprecated.md:10/:16/:21/:26/:29（五段）+ diff design-draft §2=VERBATIM_IDENTICAL;check-complete.sh:1325-1351（plan_tier 门+三 env 档）;zcode-posttooluse.sh:355-359;selftest-decision-drift.sh 独立复跑 23/23 EXIT=0;5 存量 selftest rc=0（20/16/17/9/12 全 PASS）;selftest-registry.tsv:73 NF=4;Rule 73 引用锚 29.2a/32.2/32.4/51.8/65.4/69.1/8.1 全验存;全量回归 72/72 rc=0 ΣPASS=1062 ΣFAIL=0（/tmp/v156-align-review-regression.log）;master=Rule72(v160:958)/74(v162:949)/73 空缺
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/15-alignment-review.md (status: done)
findings_written: none
blockers: none（0 BLOCKER；MINOR×4=M1 registry「DD-01~22」描述滞后/M2 模板-实例 🔒 区块顺序差/M3 存量 selftest 消息文案+注释欠账/M4 verification.md ΣPASS 1061→1062 簿记陈旧；已知并集 K1-K4 移交合并期）
confidence: HIGH
```

**verdict: PASS（= APPROVED，0 BLOCKER / 4 MINOR）**——task-v156 产出与五个对齐参照系逐项对照全部通过；4 项 MINOR 均无机器断言面/引用面影响且 2 项已在任务内登记待裁；K1-K4 为合并期并集与账本待办，按预案移交 Phase 6 合并步。
