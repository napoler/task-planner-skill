# 01 Explore: Rule 94 级联面侦察 — 检查点

## [1/7 完成] Rule 93 落地判例（task-v195-spec-recall）

**合并提交**: `2f1b88f` Merge branch 'wt/task-v195-spec-recall'（parents: 45eda8c ← master, 19e66fe ← 分支头）
**分支内提交序列**（45eda8c..19e66fe）:
- `a182b71` feat(s195-p1): execution-recall-card 召回卡新增 + Rule 93 落地 + discipline 规则索引计数级联
- `419dfb3` feat(s195-p2): SKILL.md 3g 规范召回接线 + 全仓纪元计数级联(1-93) + task_plan 模板召回行
- `65ceed7` fix(s195-p2): S7 CR 修复 — 4 处计数声明行级联补齐（discipline 43→44 条 + README/ARCHITECTURE 73→74 条）
- `b5dd8e5` merge(s195): 并入 master(s77-exec) 冲突并集解
- `19e66fe` fix(s195-p4): 补回 master 侧执行循环 4 行（selftest DCS/IP 断言守护抓获）

**净改动文件清单（`git diff 45eda8c..19e66fe`，与 `git show --stat 2f1b88f` 一致）**：
```
CLAUDE.md                                          |  2 +-
README_zh.md                                       |  4 +-
skills/task-discipline/SKILL.md                    |  8 ++--
skills/task-discipline/references/critical-rules-discipline.md | 14 ++++++
skills/task-discipline/references/execution-recall-card.md    | 51 +++++（新增文件）
skills/task-planner/README.md                      | 10 ++---
skills/task-planner/SKILL.md                       | 13 +++---
skills/task-planner/docs/ARCHITECTURE.md           | 15 ++++---
skills/task-planner/references/critical-rules.md   |  2 +-
skills/task-planner/templates/task_plan.md         |  1 +
```
**判例要点**：
- Rule 93 落在 **task-discipline** 卫星（非 drift-guard）——纪律域
- 改动面 = 规则正文(卫星 references) + 卫星 SKILL 计数 + 核心 critical-rules.md 索引(1 行改动=1-93 范围) + 主 SKILL.md + 根 CLAUDE.md/README_zh.md 计数 + planner README/ARCHITECTURE 计数(73→74 条口径) + task_plan 模板
- 判例未触碰 selftest 脚本（但 fix s195-p4 说明 selftest DCS/IP 断言守护会抓获 SKILL.md 行删除）
- 判例未新增独立 selftest（Rule 93 是 L0-T 纯文本档先例之一；规则计数口径 74→76 由后续 commit `3544076` 处理——「实测 dedup」说明 README/ARCHITECTURE 的"条数"口径是去重后实测数，非规则编号最大值）

## 账本确认
- `plans/.rule-reservations.jsonl` 末 4 行: 92 reserved/landed (task-v185-file-split-discipline), 93 reserved/landed (task-v195-spec-recall, 2026-10-21)
- 94 未被预留 ✓

## [2/7] task-drift-guard 卫星结构
- 目录: `skills/task-drift-guard/` = EXAMPLES.md, README.md, references/, SKILL.md
- references/ 仅 `critical-rules-drift.md`
- （待补: 编号格式/总行数/SKILL 索引清单）

## [2/7 完成] 卫星归属判定

**2a. task-drift-guard**
- `skills/task-drift-guard/`: EXAMPLES.md, README.md, SKILL.md(91行), references/critical-rules-drift.md(68行)
- 编号格式 = `### N 标题`（### 11 @L9, ### 15 @L17 附近, Rule 61/64 段 @L42/L51；文件头 L5: 「本批次（task-v171 S30）落盘 4 条：Rule 11,15,61,64」）
- 该卫星 SKILL.md:13 = `域=漂移检测与偏移留痕。规则全文见 references/critical-rules-drift.md（Rule 11,15,61,64）。` —— 有规则编号清单（L13 一处，SKILL.md 89-91 行区间内的 L13）
- `^### ` 计数 = 4（grep -rc 实测）

**2b. task-discipline**
- `skills/task-discipline/`: SKILL.md(89行), references/{critical-rules-discipline.md(603行), batch-quality-gate.md, capability-registry.md, execution-recall-card.md}
- `^### ` 计数 = 56（含 70.x 子条 ### 70.1-70.6 等，非全为独立规则编号；SKILL.md 口径=44 条）
- Rule 8（新请求强制重新规划三分类）= `### 8` @ critical-rules-discipline.md:18；**8.1 新任务边界判定（D 类）** @L21；**8.1.1 目标切换可判定触发（E 类前身）** @L23
- Rule 88（任务射程契约）= `### 88` @L542，正文 88.1-88.6 至 L554 前

**2c. 归属结论：放 task-discipline（纪律域）更贴合**
理由：
1. Rule 8/8.1/8.1.1（新任务边界 D 类 + 目标切换三判）全文就在 task-discipline——「检测到重大偏差→建议拆分新计划」是 8.1/8.1.1 处置链（D 类开新计划）的正向补强，语义同源同域；
2. Rule 93 判例（task-v195）刚把「规范再召回」落在 discipline 并把 92 落 discipline（v185）——9x 纪元新增规则全部归纪律域，drift 卫星冻结在 4 条（11,15,61,64，v171 后未新增过）；
3. 放 drift 需扩其 4 条编号清单（SKILL.md:13 + 核心 L202 + SKILL.md:204 路由行 3 处「Rule 11,15,61,64」硬字面，恰是 selftest DCS-09 守护行），破裂面大于 discipline（discipline 编号清单是展开枚举 4,6,7,…,93，追加 94 是尾部单点插入）；
4. drift-guard 域=「检测/留痕/节奏」（机制侧），本条是「决策侧处置纪律」（重大偏差时主动询问拆分），按 Rule 82 归属判定「主题⟷执行纪律→discipline」。
注：若实施选 discipline，SKILL.md 两处路由行 + 核心 L194 行的 discipline 枚举尾部加 94；若选 drift，则 3 处「11,15,61,64」字面要改。

## [3/7 完成] 核心索引面 critical-rules.md（203 行）
- L5: `## 分层架构说明（task-v171 技能专业化拆分）`
- L177: 边界段「核心只保留 14 条…新规则先过 Rule 20.6 rule-reserve.sh 查重，再入其归属域文件，禁直接写入核心」——新规则不入核心文件正文
- L191: `## 卫星路由索引（11 卫星 — 非核心域规则全文按需 Read；路径相对仓根）`
- L194: task-discipline 行（规则枚举 …,90,92,93）
- L202: task-drift-guard 行（Rule 11,15,61,64）
- **本文件无「Rules 1-93 全集索引」字面行**——1-93 字面在 CLAUDE.md/README_zh.md/planner README/SKILL.md/docs/ARCHITECTURE.md（见 4/5 项）；核心文件里 1-93 演进史唯一位置=L177 附近注释无 1-93（grep "93" 仅命中 L194 行尾枚举 93）
- L175: 「7 条…77 条既有规则（1-76+80）」历史建制描述，非现役锚（不动）

## [4/7 完成] 主 SKILL.md（skills/task-planner/SKILL.md，267 行）
- L9: frontmatter `- references/critical-rules.md: Critical Rules 核心域——Rules 1-93 全集索引（…；其余 74 条按域归 11 卫星…）`
- L17: `- 卫星技能 task-discipline: …（Rule 4,6,7,…,90,92,93）`
- L95: `3g 规范召回（Rule 93）` 执行循环行（不动，判例参照物）
- L99: 执行循环 6.[A] DRIFT CHECK 行（含 task-drift-guard 指针；若 Rule 94 挂 SKILL「用户新指令处理」段则此处可不改）
- L140/147: 上下文读序/验收清单 G1b（G1b 提及「目标切换三判（E 类）」——与 Rule 94 语义最近的 SKILL 锚）
- L154: G8 行「用户新指令已过 D/A/B/C 判定（如有）」——Rule 94 可能在此 G8 句加指针
- L163: `### 🆕 用户新指令处理（计划影响判定 — 强制）`（段 163-175）
- L172: 判定顺序行（「B/C 变更前过 Rule 73.2 对齐三问…」——Rule 94 指针可挂此句）
- L174: `**目标切换判定（E 类，P0 铁律）**：…`（Rule 94 最贴插入点=E 类段之后/D 类行处置列）
- L196: 路由表 task-discipline 行（规则枚举 …,90,92,93）
- L204: 路由表 task-drift-guard 行 `| task-drift-guard | … | 漂移检测/偏移检查子代理化/周期回顾节奏（Rule 11,15,61,64） |`（selftest DCS-09 守护此行含路径）
- L209: `Rules 1-93 全集索引：**核心在位 14 条**…其余 74 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93 纪律域）`
- L251: References 表行 `| references/critical-rules.md | Critical Rules 核心域 1-93 全集索引（14 条核心全文+分层架构说明+卫星路由索引） |`
- 若归属 discipline：改 L9(1-93→1-94, 74→75或随 dedup 口径)、L17 枚举+94、L196 枚举+94、L209(1-93→1-94, 枚举+94)、L251(1-93→1-94)、L172/174 区段加指针句（净增 ≤2 行，BP-08 上限 275，现 267，余 8 行边距——注意）
- 若归属 drift：另需改 L204 行（Rule 11,15,61,64→+94）+ 核心 L202 行

## [5/7 完成] selftest 机器锚（scripts/ 与仓根 scripts/）
仓根 scripts/ 仅 3 个 kb-*.sh（知识库），无规则锚——无命中。
**SKILL.md 内 1-93/9x 字面与纪元断言（改 1-94 时逐一判定）**：
1. `selftest-conclusion-discipline.sh:84` n35 = `grep -cE '1-(3[5-9]|9[0-9])'` + `:91` n45=`grep -cE '1-[4-7][0-9]'`，`:92` 断言 n35+n45 ≥3。SKILL 现值 1-93 命中 n35（L9/L209/L251 3 处 '1-93'⊂1-9[0-9]）→ 改 1-94 后 n35 仍 ≥3 **不破裂**（9x 纪元通配）；`'1-34'` 反回退锚（:93-95 n34=0）不受影响。
2. `selftest-root-resolution.sh:126` n=`grep -cE 'Rules 1-[89][0-9] 全集索引：'` =1 断言 → 1-94 ⊂ 1-[89][0-9] **不破裂**；负断言 m=`'(全集|Rules) 1-(51|53|55)'`=0 不受影响。
3. `selftest-error-loop.sh:75`（EL-11）`grep -qE 'Rules 1-(3[1-9]|[4-7][0-9]|8[0-9]|9[0-9])'` → 1-94 **不破裂**（9[0-9] 通配）。
4. `selftest-session-log.sh:67-71`（SL-05）`grep -cE '1-[89][0-9]([^0-9]|$)'` ≥3 + 负样本 '1-90' 对 `1-8[0134]` =0 → 1-94 **不破裂**。
5. `selftest-workflow-orchestration.sh:79-82`（WF-10）变体族 `Critical Rules 1-(68|69|71|75|91)`+裸 `1-(68|69|71|75|91)` 4 文档合计 ≥3：**实测当前=4**（CLAUDE.md:33 历史注释 1、README_zh.md:136 历史注释 1、planner README 历史注释 1、… 均在 `<!-- -->` 注释/历史行内）→ 改 1-94 后族成员不增，**恒 4 不破裂**（历史纪元注释行保留即维持 ≥3）；WF-11「Rules 1-38 残留=0」不受影响。
6. **计数口径断言（新规则新增规则条数时可能触及，非 1-N 纪元面）**：无 selftest 断言「44 条/74 条/76 条」字面（grep 无命中）——计数口径是 README/ARCHITECTURE/卫星 SKILL 散文声明（判例 65ceed7 补 43→44 系 CR 人工级联，非机器锚）。
7. **行数钉**：`selftest-batch-pilot.sh:63`（BP-08）SKILL.md ≤275（现 267，+8 行内安全）；`selftest-skill-collab.sh:93`（T10）SKILL.md ≤584（历史钉恒真，不受影响）；核心 critical-rules.md 无 selftest 行数断言（grep 无命中）。
8. **规则计数 ^### 断言**：无 selftest 对 discipline/drift 文件 grep -c '^### ' 做总数断言（dispatch-grain 只断 46.x=6 条，ask-default-timeout 断 44.x=1 条，均为既有规则子条锚，与新增 94 无关）。
9. **run-selftests.sh 注册机制**：L5 `枚举 scripts/selftest-*.sh 逐个执行`（glob 自动发现，无 manifest）；但 `selftest-registry.tsv`（93 行=表头+92 脚本行）+ `selftest-registry.sh` T02/T03/T04/T05 双向核对——**新增任何 selftest-*.sh 必须同步 TSV 登记行**（4 列：script/domain/trigger_scenarios/dep_anchors），否则 T02 FAIL。判例 Rule 93 未新增 selftest（L0-T 档），故本任务若 L0-T 纯文本档：0 新增 selftest、0 TSV 变更。
10. **check-complete/attest/check-plan-dispatch 锚面**：仅引用既有规则号（Rule 27.3/18.6/19.5/22.6/59.1/38.x 等），**无 critical-rules.md 行数或 1-93 纪元断言，无漂移卫星文件锚**——不破裂。check-complete.sh:530-552 DRIFT-GATE 只查 drift-checker 检查点存在性（`ls | grep -q 'drift'`），与规则编号无关。
11. **rule-reserve 台账守护** `selftest-rule-reserve-pairing.sh:38/41` EXEMPT_LANDED=(46 47 48 49 50 75)/EXEMPT_DANGLING=(57 60 80 82)：Rule 94 走正常 `rule-reserve.sh reserve 94` + land 配对即 PASS，无需扩豁免表。实测 `rule-reserve.sh next`=94（94 可预留，与台账末行 93 landed 一致）。

## [6/7 完成] 模板面
- `skills/task-planner/templates/`：13 基础模板 + variant/。task_plan.md:312 仅 Rule 93 召回行（本任务不改，除非 Rule 94 也要挂模板 checklist——判例 Rule 93 是当时才加此行，Rule 88/89 未加）；**无 1-93 字面、无规则编号清单需同步**（grep "1-93" 无命中）。
- `templates/variant/rule-enhancement-type.md:24/39`：VC-5 模板行「SKILL 联动（索引行 Rules 1-N/合规清单 C 行/特判段/摘要行）」+ 「⚠️ 锚定级联：改 SKILL.md "Rules 1-N" 前先 grep -rn "Rules 1-" scripts/ 扫全部锚断言一次修齐（宽容正则 Rules 1-3[x-y] 优先）」——这是**指引模板**（1-N 占位），无需改；它明确指向本次 5/7 的宽泛 grep 扫描 SOP。
- `.zcode/plan-templates/knowledge-brief.md`：12 处 Rule 引用（Rule 45.2/22.4/21.2.1/53/59.3 等），**无 1-93 纪元/规则总数/卫星编号清单**——不破裂。
- `.zcode/plan-templates/` 目录仅 knowledge-brief.md 一个文件。

## [7/7 完成] 其他消费面（check-*.sh / attest / 部署位）
- `check-complete.sh`：门控引用既有规则号（L276 Batch Report Rule 18.6、L545 DRIFT-GATE Rule 61/64.1 文案、L1379-1418 session-log Rule 80.2 等），**无 1-93 纪元断言、无卫星文件行数锚**——0 破裂。
- `attest-plan.sh`：头注引用 Rule 20.1/34.1/84.1/51.1/22.9/66.5/22.6——**无新增规则敏感面**——0 破裂。
- `check-plan-dispatch.sh`：Rule 22.6/25.1/21.1b/38.4/59.1 门控——0 破裂；L504 "drift" 变量是 TSV 列数漂移检查（hdr_nf），与漂移域无关（同名异义，勿误改）。
- **部署位**（判例 419dfb3 含 CLAUDE.md/README_zh.md——即仓根双索引文档）：`CLAUDE.md:33` 与 `README_zh.md:136,229` 各 1 处 `Rules 1-93` 字面（+历史注释链）。Rule 94 实施需 1-93→1-94 各 1 行改动（3 处），判例同款级联。
- `skills/task-planner/README.md:4,81,123,127,288`：L81「Rules 1-93 全集索引…其余 76 条」、L4 家族分层段（76 条 dedup 口径）、L288 历史段（76 条 v171 快照，不动）——1-94 时 L4/L81 改纪元+条数口径。
- `skills/task-planner/docs/ARCHITECTURE.md:4,13,42,113,122,134,136`：L113「Rules 1-93 全集索引（2026-10-21 task-v195 更新）」、L122 演进史行（追加一行）、L4/L13/L42/L134/L136 1-93 字面与条数。
- 卫星 SKILL.md（归属=discipline 时）：`skills/task-discipline/SKILL.md:15`（「共 44 条」→45）、`:24`（规则枚举尾 +94）、`:76`（「本索引现共 44 条全文可消费」→45+ 后补行）、`:87`（「44 条规则全文（含…93）」→45 条+94）。归属=drift 时改 `skills/task-drift-guard/SKILL.md:13`（「Rule 11,15,61,64」→+94）+ 核心 L202/SKILL L204 同款 3 处字面。
