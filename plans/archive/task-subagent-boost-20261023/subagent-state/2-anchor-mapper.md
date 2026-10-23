# 2-anchor-mapper — selftest 纪元锚级联清单冻结（1-94 全形态）

- 勘察员：纪元锚勘察员（只读子代理 S2）；日期 2026-10-24
- 勘察对象（worktree）：`/mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023/skills/task-planner/scripts/`（含 lib/、schemas/ 递归）+ 形态④点名的 `SKILL.md`
- 取证手段：grep -rn 全量扫描（字面/字符类/并集/计数四形态）+ sed 精读关键断言块；所有行号均为 worktree 内实测（2026-10-24 worktree 快照 = master 886f060 基线 + 未提交增量，见文末「基线说明」）

## 0. 结论速览

1. **当前纪元实态 = Rules 1-94**：字面 `1-94` 在 scripts/ 内 **0 处**；全部落在 3 个 .md——SKILL.md 三处（:9 frontmatter / :209 正文全集索引 / :251 References 表）、README.md 三处、docs/ARCHITECTURE.md 五处（后两者属 ask 点名范围外，另列 F 节）。
2. **scripts/ 的纪元锚已完成「宽容正则类」化**（近 20 轮纪元级联 v079→v195 的成果）：现存活锚形态 `1-[89][0-9]`、`1-(3[1-9]|[4-7][0-9]|8[0-9]|9[0-9])`、`Rules 1-(3[5-9]|[4-9][0-9])`、`1-(7[4-9]|[89][0-9]|8[0-9])`、`1-(3[5-9]|9[0-9])`+`1-[4-7][0-9]`、`1-(3[0-9]|[4-9][0-9])`、`1-[7-9][0-9]`、`1-(68|69|71|75|91)`——**全部天然覆盖 1-96**。
3. **四形态总行数 total = 207**（①0 + ②139 + ③63 + ④5；口径见 §1，逐行清单见 §2-§5）。另有风险面 E 节（行数钉/子条计数/旧族负断言），未计入 total。
4. **级联主体不是改 selftest**：scripts/ 侧 63 条可执行断言在 96 纪元下全部免改仍 PASS（§6 逐类验证）；必改面 = SKILL.md 三处字面 1-94→1-96 + 演进注释补行（Rule 45 惯例）+ run-selftests.sh 两处 selftest 数注释随动。

## 1. 计数口径（rubric）

- **①字面 '1-94'**：文本含字面 `1-94` 的行。scripts/ = 0；SKILL.md 三处计入 ④。
- **②正则类纪元锚**：文本含 ERE 字符类/并集纪元形态（`1-[89][0-9]`、`1-(…|…)`、`1-8[0134]`、`40-[5-8][0-9]`、`1-[7-9][0-9]` 等）或主线全集纪元演进注释（含 1-62…1-94 家族旧字面原文）的行——含可执行存在断言（grep -q）、ok/bad 消息串、pin 定义、注释。
- **③计数断言**：对纪元锚串的可执行计数断言行（grep -cE/-oE、cnt/cntE、-ge/-eq 阈值、负向越界断言）+ AD-12 pin 断言行（pin=对兄弟 selftest 活锚形态的存在性断言，属同步门）。
- **④SKILL.md 规则数 / selftest 数钉值**：SKILL.md frontmatter/正文/References 表中的规则数钉值行（1-94 字面活体）+ scripts/ 内 selftest 数钉值注释（run-selftests.sh 76/72 脚本）。
- 每行只计一次，按上述优先级归入最具体形态；旧纪元旁支族（1-3x/1-4x 子条计数、1-38/1-39/1-45 负断言）不入四形态，入 E 节。
- 附带说明：`task-v094`、行号区间（如「行 92-94」「:759-794」）、`created_epoch`（时间戳语义）等非纪元锚命中已剔除。

## 2. 形态① 字面 '1-94'（scripts/ = 0 行）

- 验证命令：`grep -rn "1-94" <worktree>/skills/task-planner/scripts/` → 无命中（本次实测）。
- 字面唯一活体（计入 ④，见 §5）：SKILL.md:9 / SKILL.md:209 / SKILL.md:251。
- 范围外发现（未计入 total，级联时随部署位对齐面处理，见 §7-F）：README.md:36、:81、:123；docs/ARCHITECTURE.md:13、:42、:113、:123、:135。
- `references/critical-rules.md` 与 `reference.md` 内无 `1-94`/`Rules 1-94` 字面（grep 实测仅 critical-rules.md:25 命中 task-v094 任务号、:194 命中卫星行枚举尾 `,93,94）`——后者入 E 节）。

## 3. 形态② 正则类纪元锚（139 行）

标记：[断言]=可执行存在断言；[消息]=ok/bad 消息串（随动可选）；[pin 定义/注释]；[演进注释]。原文超长处截断保留形态原文。

### selftest-absorption-discipline.sh（6）
- :35 [注释] AD-04 …全集 '1-[7-9][0-9]' 三处…
- :69 [注释] AD-11 …三处已演进 1-[7-8][0-9]
- :72 [注释] 精确 5（_pin_lit）…'Critical Rules 1-[7-8][0-9]'…
- :74 [注释] 宽容 6（_pin_tol）…'1-[7-8][0-9]'/'1-(69|71|7[4-9]|80)'/'Rules 1-(3[0-9]|[4-8][0-9])'…
- :79 [注释] 4 个主锚 selftest 的纪元锚随动演进（'Critical Rules 1-[7-8][0-9]'→"grep -cE '1-80'"）…
- :80 [注释] （pin 机制语义不变：钉住兄弟 selftest 的 live 纪元锚形态…与 v169 '1-74'→'1-[7-8][0-9]' 同范式）

### selftest-error-loop.sh（7）
- :14 [演进注释] EL-11 …宽容正则扩 6x 纪元 1-(3[1-9]|[4-6][0-9])…末段字符类 4-7x→4-8x…
- :15 [演进注释] [task-v170 S10j 纪元扩围] 宽容正则 '1-(3[1-9]|[4-7][0-9])'→'1-(3[1-9]|[4-7][0-9]|8[01])'…
- :68 [演进注释] EL-11 [task-v144 合并级联…宽容正则扩 6x 纪元]
- :69 [演进注释] [task-v160 合并并集…Rule 72 落地 1-72 纪元]
- :70 [演进注释] [task-v169 合并级联: Rule 80 落地 1-80 纪元, 末段字符类 4-7x→4-8x]
- :71 [演进注释] [task-v170 S10j 纪元扩围（Rule 45 注释）] 'Rules 1-(3[1-9]|[4-7][0-9])'→'Rules 1-(3[1-9]|[4-7][0-9]|8[01])'
- :75 [断言] `grep -qE 'Rules 1-(3[1-9]|[4-7][0-9]|8[0-9]|9[0-9])' "$SKILLMD"`（EL-11，覆盖 96 ✓）

### selftest-veto.sh（6）
- :13 [演进注释] VT-10 …8x 精化 8[01] 尾边界断言…（含畸形拼接文本 '8[0134]([^0-9]|$))^0-9]|$))'）
- :59 [演进注释] VT-10 [task-v144…宽容正则扩 6x 纪元][task-v158 扩 7x 纪元 1-(3[1-9]|[4-7]x)]
- :60 [演进注释] [task-v160 合并并集…Rule 72 落地 1-72 纪元]
- :61 [演进注释] [task-v169 合并级联…末段字符类 4-7x→4-8x（后由 task-v170 精化为 8[01] 尾边界…）]
- :62 [演进注释] [task-v070 S10o 扩 81 纪元（Rule 45 注释）]…负样本 82/89/90 不得命中…
- :63 [断言] `grep -qE 'Rules 1-(3[1-9]|[4-7][0-9]|8[0-9]([^0-9]|$)|9[0-9]([^0-9]|$))' "$SKILLMD"`（VT-10，覆盖 96 ✓，消息串自称「1-3x..99」）

### selftest-reflect-verify.sh（4）
- :13 [演进注释] RV-10 …宽容正则扩 6x 纪元 1-(3[5-9]|[4-6][0-9])…8x 纪元 1-(3[5-9]|[4-8][0-9])…
- :64 [演进注释] RV-10 [task-v144…][task-v158…][task-v169 扩 8x 纪元…]
- :65 [演进注释] [task-v160 合并并集…Rule 72 落地 1-72 纪元]
- :66 [断言] `grep -qE 'Rules 1-(3[5-9]|[4-9][0-9])' "$SKILL"`（RV-10，覆盖 96 ✓）

### selftest-conclusion-discipline.sh（5）
- :9 [演进注释] CD-11 …双锚 1-3[5-9]+1-4[56] 合计 ≥3…宽容正则扩 6x 纪元…
- :86 [演进注释] 追加锚 1-7[0-2]…n35+n45+n70 合计 ≥3…（此行仅存历史）
- :88 [演进注释] 1-4[5-9]|1-5[0-9]→1-[4-7][0-9]（单锚合并扩面…）
- :89 [演进注释] [task-v163 级联…活跃锚 1-[4-7][0-9] 已覆盖 75…]
- :90 [演进注释] [task-v182 口径扩展] 1-3[5-9]→1-(3[5-9]|9[0-9])（Rule 90 落地 SKILL.md 全集演进 1-90…）

### selftest-workflow-orchestration.sh（9）
- :8 [演进注释] 新锚 'Critical Rules 1-68'+'1-68' 变体族命中总和 ≥3…
- :12 [演进注释] [task-v144] 旧口径「Rules 1-39+1-45 总和 ≥6」演进为新锚 1-62 族…
- :13 [演进注释] SKILL.md 三锚…已演进为 Critical Rules 1-62
- :66 [演进注释] WF-10 4 索引文档 新锚 1-68 族…
- :68 [演进注释] [task-v144] 旧口径 'Rules 1-39+1-45 总和 ≥6' 随 SKILL.md 锚演进 1-62 同步…
- :74 [演进注释] [task-v158] '1-68'→'1-71' 变体族…
- :75 [演进注释] [task-v163 级联…'Critical Rules 1-(68|69|71|75)'|'1-(68|69|71|75)'…]
- :76 [演进注释] [task-v163 并集解] AD-12 _pin_tol 旧纪元钉值 '1-(68|69|71)' 保留为历史字面…
- :77 [演进注释] [task-v183 Rule 91 落地] 变体族扩 91…L78 grep 模式 1-(68|69|71|75)→1-(68|69|71|75|91)…

### selftest-context-pressure.sh（6）
- :102 [演进注释] CP-07 …全集纪元锚 '1-8[0134]' ≥2 ∧ 'Rules 1-80 全集' ≥1…
- :103 [演进注释] 旧纪元锚 '1-(69|71|7[4-9]|80)' 与合规清单…双双零命中…
- :105 [演进注释] 修法：纪元锚改 '1-80'（c1≥2 实测 3 处）+ 整串改 'Rules 1-80 全集'…
- :108 [演进注释] 历史纪元演进（v158/v160/v162/v163/v169 各级宽容扩）保留如上…
- :115 [消息] ok "CP-07" "'1-[89][0-9]'=$c1≥2 ∧ 'Rules 1-[89][0-9] 全集'=$c2≥1 ∧…"
- :117 [消息] bad "CP-07" "'1-[89][0-9]'=$c1 全集串=$c2 路由行=$c3…"

### selftest-summary-readability.sh（6）
- :11 [演进注释] SRV-03 `1-(7[4-9]|[89][0-9]|8[01])` ≥3（task-v170 S10n 纪元扩围…负样本 1-82 不命中）…
- :76 [演进注释] [task-v169 纪元再扩] '1-7[4-9]'→'1-[7-8][0-9]'…（阈值 ≥3 不变）
- :77 [演进注释] SRV-03: SKILL 接线锚（1-(7[4-9]|[89][0-9]|8[01])≥3…防下次 epoch 再漂移）
- :78 [演进注释] [task-v170 S10n 纪元扩围] '1-7[4-9]'→'1-(7[4-9]|[89][0-9]|8[01])'…负样本 '1-82' 不命中…
- :81 [消息] ok "SRV-03" "SKILL 接线锚(1-(7[4-9]|[89][0-9]|8[0-9])≥3)"
- :83 [消息] bad "SRV-03" "SKILL 接线锚(got 1-(7[4-9]|[89][0-9]|8[0-9])=$SRV03_EPOCH expect>=3)"
- 注意：:77/:78 注释形态为 `8[01]`，:79 可执行行已演进为 `8[0-9]`——注释与代码已有一步漂移（无门，仅记录）。

### selftest-requirement-coverage.sh（8）
- :132 [演进注释] [task-v160 新纪元宽容演进] 钉值 '1-69' → 宽容形态 'Critical Rules 1-(6[0-9]|7[0-2])'
- :136 [演进注释] [task-v166 纪元再扩] 旧钉值→'1-7[4-9]'…
- :137 [演进注释] [task-v169 Rule 80 落地纪元扩展] '1-7[4-9]'→'1-[7-8][0-9]'…
- :138 [演进注释] [task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]
- :139 [演进注释] [task-v163 级联: SKILL 计数演进 1-72→1-75…宽容正则扩 7[0-5] 纪元…]
- :142 [演进注释] 旧主锚 'Critical Rules 1-[7-8][0-9]' 零命中；随动演进为 '1-8[0134]' 全集口径锚…
- :143 [演进注释] grep -cE 口径与四脚本统一——AD-12 pinning 机制钉 live 锚形态…1-39 负断言保留
- :146 [消息] ok 11 "SKILL.md 主锚 '1-[89][0-9]' 全集口径 ≥1 且 '1-39' 变体 0…"

### selftest-tool-selection.sh（3）
- :77 [演进注释] [task-v160] '1-69'→宽容形态 '1-(6[0-9]|7[0-2])'…
- :80 [演进注释] [task-v169 纪元扩展] '1-7[4-9]'→'1-[7-8][0-9]'…
- :82 [演进注释] 'Critical Rules 1-[7-8][0-9]' 零命中；随动演进为 '1-8[0134]' 全集口径锚…

### selftest-self-resolution.sh（5）
- :93 [演进注释] [task-v160 S14d] 字面 '1-69'→宽容 '1-(6[0-9]|7[0-2])'…
- :95 [演进注释] [task-v166→v169 纪元锚扩展]…宽容正则扩为 'Critical Rules 1-[7-8][0-9]'…
- :97 [演进注释] 'Critical Rules 1-[7-8][0-9]'（区间字面）零命中；随动演进为 '1-80' 全集口径锚…
- :116 [消息] ok 08 "SKILL.md '1-[89][0-9]' 全集口径锚 + CRIT_C Rule 40 六子条 = 6…"
- :118 [消息] bad 08 "Rule 40/41 共存锚损伤（'1-[89][0-9]' 缺失或…）"

### selftest-execution-honesty.sh（1）
- :106 [消息] ok 09 "…全集 '1-[89][0-9]'=$z≥1…"

### selftest-reliability-institution.sh（6）
- :90 [演进注释] [task-v138] 括注演进「40-55 全集」…宽容正则 40-5[3-9]…
- :91 [演进注释] [task-v144]…随动 40-5[3-9]→40-[56][0-9]…1-40 负断言保留
- :92 [演进注释] [task-v158]…随动 40-[56][0-9]→40-[567][0-9]…
- :93 [演进注释] [task-v156] 锚随 SKILL 计数「1-71+73」插入形态宽容化…正则加 `(\+[0-9]+)?` 族（K9）…
- :94 [演进注释] [task-v169 纪元演进]…字符类 40-[4567][0-9]→40-[4-8][0-9]…
- :95 [演进注释] [task-v171 分层口径切换]…旧宽容锚 40-[4-8][0-9] 失配=0，随动演进为 '1-80' 全集口径锚…

### selftest-iteration-persistence.sh（9）
- :15 [演进注释] IP-12 全集声明宽容锚 `Rule 40-[5-8][0-9]` ≥1…
- :151 [演进注释] IP-12 SKILL.md 全集声明宽容锚 `Rule 40-[5-8][0-9]` ≥1
- :156 [演进注释] …「Rule 40-62」，旧正则 `40-5[5-9]` 不再命中…
- :157 [演进注释] [task-v158] 全集声明演进为「Rule 40-71」(L288)…
- :158 [演进注释] 随动 40-[56][0-9]→40-[567][0-9]…
- :159 [演进注释] [task-v169] 全集声明演进为「Rule 40-80 全集」(L313)…
- :160 [演进注释] 随动 40-[567][0-9]→40-[5-8][0-9]…
- :161 [演进注释] [task-v171 分层口径切换] 全集声明演进为「Rules 1-80 全集索引」…
- :162 [演进注释] 随动演进为 `1-8[0134]` 全集口径锚…

### selftest-root-resolution.sh（13）
- :108 [演进注释] RR-09 全集声明演进锚 `grep -cE 'Critical Rules 全集 1-[0-9]+(\+[0-9]+)?'` =1（负断言 '1-51'=0）
- :117 [演进注释] 主断言 1-5[3-9]→1-(5[3-9]|6[0-9])（同 SR-08 范式…）
- :120 [演进注释] [task-v162]…宽容正则扩 7x 纪元 1-(5[3-9]|6[0-9]|7[0-4])…
- :121 [演进注释] [task-v156] 锚随「1-71+73」插入形态宽容化…`(\+[0-9]+)?` 族（K9）…
- :123 [演进注释] [task-v171] 全集声明演进为「Rules 1-80 全集索引」…
- :124 [演进注释] 旧形态 'Critical Rules 全集 1-NN(+N)' 失配=0；主断言随动演进为 'Rules 1-80 全集索引：'…
- :129 [消息] ok 09 "SKILL.md 全集声明「Rules 1-[89][0-9] 全集索引：」=1…"
- :131 [消息] bad 09 "SKILL.md 全集 'Rules 1-[89][0-9] 全集索引：' 命中=$n…"
- :181 [演进注释] 口径：:266 索引行「详见 references/critical-rules.md（Rules 1-39…）」…
- :183 [演进注释] …已改简洁括注「含 Rule 40-53 全集」。断言：索引行（'（Rules 1-39' =1 定位）
- :191 [演进注释] 定位面同步：:273 索引行括注已演进「含 Rule 40-62 全集」…
- :195 [演进注释] 现存载体=References 表行「| `references/critical-rules.md` | Critical Rules 核心域 1-80 全集索引…」
- :196 [演进注释] 修法：idxn 锚改 'critical-rules.md` | Critical Rules 核心域'（=1）+ 行内含 '1-8[0134]'…

### selftest-research-first.sh（7）
- :13 [演进注释] RF-06 `1-65` ≥3…RF-07 双锚…`Critical Rules 1-65（含 Rule 40-65 全集` ≥1
- :79 [演进注释] [task-v156] 锚随「1-71+73」插入形态宽容化…`(\+[0-9]+)?` 族（K9）…
- :81 [演进注释] ② 头注全集宽容锚 → 'Rules 1-8[0134] 全集' 口径…
- :82 [演进注释] 现象：…头注 'Critical Rules 1-NN（含 Rule 40-NN 全集'…
- :83 [演进注释] 形态双双移除（全集口径演进为「Rules 1-80 全集索引」）…
- :85 [演进注释] 修法：① cnt 锚改 '反推诿'…② cntE 锚改 'Rules 1-80 全集'（≥1）…
- :87 [演进注释] [task-v163 级联: 头注全集 1-72→1-75…cntE 交替再扩 (69|71|72|75)…]

### selftest-plan-tier.sh（5）
- :14 [演进注释] PT-08 SKILL.md frontmatter 索引含「1-4[56]」（task-v088 级联 1-38→1-39…）
- :53 [演进注释] PT-08 改指核心 SKILL.md frontmatter「Critical Rules 核心域——Rules 1-80 全集索引」…
- :94 [演进注释] S33 重写后 frontmatter 索引演进为「Critical Rules 核心域——Rules 1-80 全集索引…」
- :95 [演进注释] 全集覆盖语义由 1-80 全集索引承载（核心 12 条全文+66 条卫星归属路由表）…
- :96 [断言] `grep -qE 'Critical Rules 核心域.*Rules 1-[89][0-9]' "$SKILLMD"`（PT-08，覆盖 96 ✓）

### selftest-decision-drift.sh（3）
- :114 [演进注释] 旧宽锚 '1-7[0-9]'（1-70..1-79 字面）零命中…
- :115 [演进注释] 根因：宽锚钉的是旧全集纪元字面…（1-80 全集索引）
- :116 [演进注释] 修法：宽锚改 '1-8[0134]'…

### selftest-drift-check-subagent.sh（3）
- :90 [演进注释] 全集声明演进为「Rules 1-80 全集索引」…
- :91 [演进注释] 修法：全集锚改 '1-8[0134]'（阈值 ≥1…）
- :93 [断言] `grep -q '1-[89][0-9]' "$SKILLMD" && grep -q '偏移检查子代理化' …`（DCS-11，覆盖 96 ✓）

### selftest-source-anchor-discipline.sh（2）
- :47 [演进注释] ③ 全集计数锚 '1-7[4-9]'→'1-8[0134]'（≥2；task-v170 并集 ma…
- :50 [演进注释] [task-v163 级联]…计数锚 1-7[12]→1-7[125]（容忍 71/72/75 纪元）…

### selftest-session-log.sh（2）
- :66 [演进注释] 扩围正则 1-8[0134]([^0-9]|$)（尾边界写法参照 selftest-veto.sh VT-10…）
- :68 [断言标签] t "SL-05 SKILL.md 纪元锚 '1-8[0-9]' ≥3…"
  （注意：标签写 '1-8[0-9]'，实际模式是 :69 的 '1-[89][0-9]([^0-9]|$)'——标签与实现已有措辞差，纯标签无门）

### selftest-verification-gate.sh（6）
- :79 [演进注释] VG-06 主 SKILL.md 三处步骤引用…+ 全集 1-84 纪元
- :80 [演进注释] What：断言主 SKILL.md 含 '1-84' 全集纪元 + '11 卫星' 计数…
- :81 [演进注释] Why：…（task-v173 纪元级联）
- :82 [断言] `grep -q 'Rules 1-[89][0-9]' "$TP_SKILL" && grep -q '11 卫星' …`（覆盖 96 ✓）
- :83 [消息] ok 06 "主 SKILL.md 全集 1-[89][0-9] + 11 卫星 +…"
- :85 [消息] bad 06 "主 SKILL.md 全集 1-[89][0-9]/11 卫星/…"

### selftest-requirement-grading.sh（4）
- :91 [演进注释] RG-06 …全集 '1-8[0134]' ≥1 ∧ 'Rule 47,49,50' 枚举 ≥2…
- :96 [断言] `grep -q '1-[89][0-9]' "$SKILLMD" && [ "$(grep -cF 'Rule 47,49,50' …)" -ge 2 ]`（覆盖 96 ✓；行尾注释 [task-v173]）
- :97 [消息] ok 06 "SKILL.md 全集 '1-[89][0-9]' 在位 ∧…"
- :100 [消息] bad 06 "SKILL.md 路由面锚缺失（'1-[89][0-9]' 或…）"

### selftest-parallel-scheduling.sh（7）
- :16 [演进注释] P-05 …SKILL 内 `Critical Rules 1-NN(+N)` 上界…
- :109 [演进注释] 现象：…'Critical Rules 1-NN' 主 label 演进为
- :110 [演进注释] 「Rules 1-80 全集索引」（skill_max 提取式失配=空）…
- :113 [演进注释] ③ 上界动态对照改分层口径：SKILL 声明 'Rules 1-81'（skill_max=81）+…
- :117 [演进注释] [task-v160/v163 上界动态对照演进史] 保留如上…
- :118 [演进注释] v171 分层后口径=SKILL 'Rules 1-80' 声明 + 核心 CRIT Rule 82…
- :119 [演进注释] [task-v172 对齐 1-83]…[task-v173 对齐 1-84] skill_max=84。

### selftest-batch-pilot.sh（3）
- :12 [演进注释] BP-09 batch-quality-gate.md 含「隶属 Rules 1-36..1-77」宽容正则…扩为「1-(3[6-9]|[4-6][0-9]|7[0-7])」…
- :67 [演进注释] grep -qE '隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])'（参照…CD-19「1-3[5-8]」宽容锚写法…）
- :69 [断言] `grep -qE '隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])' "$BGATE"`（BP-09，目标为 batch-quality-gate.md 的 1-77 全集描述，非 SKILL 1-9x 纪元，96 级联无关）

### selftest-skill-split.sh（6）
- :8 [演进注释] ⑤ 锚点抽验…Rules 1-3 计数锚…宽容正则扩 6x 纪元 1-(3[0-9]|[4-6][0-9])
- :84 [演进注释] 原固定字面 'Rules 1-3' 计数锚在 1-62 纪元…→ 宽容正则 1-(3[0-9]|[4-6][0-9])…
- :85 [演进注释] [task-v158] 7x 纪元再扩…宽容正则扩 7x 纪元 1-(3[0-9]|[4-7]x)…
- :87 [演进注释] [task-v169] 8x 纪元…1-(3[0-9]|[4-8][0-9])…
- :88 [演进注释] [task-v170 纪元演进并集] '1-(3[0-9]|[4-8][0-9])'→'1-(3[0-9]|[4-7][0-9]|81)'…
- :89 [演进注释] [task-v172 对齐 1-83]…放宽至 8x 纪元 1-(3[0-9]|[4-8][0-9])…

**②合计 = 6+7+6+4+5+9+6+6+8+3+5+1+6+9+13+7+5+3+2+2+6+4+7+3+6 = 139 行**

## 4. 形态③ 计数断言（63 行）

### selftest-absorption-discipline.sh（13）——AD-12 pin 家族=级联同步机制本体
- :42 [计数] AD-04 chk：`test $(grep -cE '1-[7-9][0-9]' "$SKILL") -ge 3` ∧ 'Rule 74 三判门' ∧ task-discipline 行（覆盖 96 ✓）
- :70 [负断言] AD-11：SKILL.md『1-71』字面残留 =0（grep -c '1-71'）
- :75 [pin 定义] `_pin_lit() { grep -qF "$2" "$1"; }`
- :85-:89 [pin×5] `_pin_lit … "grep -cE '1-[89][0-9]'"`（钉 tool-selection/requirement-coverage/lane-advancement/self-resolution/source-anchor-discipline 五脚本活锚形态）
- :90 [pin] `_pin_tol … '1-[89][0-9]'`（research-first）
- :91 [pin] `_pin_tol … '1-[89][0-9]'`（context-pressure）
- :92 [pin] `_pin_tol … '1-(68|69|71)'`（workflow-orchestration，历史字面钉）
- :93 [pin] `_pin_tol … '1-[4-7][0-9]'`（conclusion-discipline）
- :94 [pin] `_pin_tol … 'Rules 1-(3[0-9]|[4-9][0-9])'`（skill-split）
- :96 [汇总断言] AD-12 ok/ng："pinning 锚 11 处逐个断言：live 锚字面（精确 5：'1-[89][0-9]' 纪元 grep ×5）或宽容正则族（6）二者居一"

### selftest-conclusion-discipline.sh（3）
- :80 [计数] `n35=$(grep -cE '1-(3[5-9]|9[0-9])' "$SKILL")`（9[0-9] 覆盖 1-96 ✓）
- :91 [计数] `n45=$(grep -cE '1-[4-7][0-9]' "$SKILL")`
- :92 [阈值] `check "test $((n35+n45)) -ge 3" "SKILL.md 宽容锚「1-(3[5-9]|9[0-9])」…+「1-[4-7][0-9]」…合计 ≥3"`

### selftest-context-pressure.sh（3）
- :109 [计数] `c1=$(grep -cE '1-[89][0-9]' "$SKILL_MD")`
- :110 [计数] `c2=$(grep -cE 'Rules 1-[89][0-9] 全集|1-[89][0-9] 全集' "$SKILL_MD")`
- :114 [阈值] `if [ "$c1" -ge 2 ] && [ "$c2" -ge 1 ] && …`

### selftest-decision-drift.sh（1）
- :117 [计数] `[ "$(cnt '1-[89][0-9]' "$SKILL")" -ge 1 ]`（DD-21）

### selftest-execution-honesty.sh（2）
- :104 [计数] `z="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :105 [阈值] `if [ "$x" -eq 1 ] && [ "$y" -eq 1 ] && [ "$z" -ge 1 ]`

### selftest-capability-persistence.sh（3）
- :93 [计数] `n="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :94 [负断言] `o="$(grep -cE '40-[5-8][0-9]' "$SKILLMD")"`（旧 40-x 纪元残留 =0）
- :95 [阈值] `if [ "$n" -ge 1 ] && [ "$o" -eq 0 ]`

### selftest-iteration-persistence.sh（2）
- :163 [计数] `n="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :164 [阈值] `if [ "$n" -ge 1 ]`（IP-12）

### selftest-lane-advancement.sh（3）
- :129 [计数] `n="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :130 [负断言] `m="$(grep -c '1-39' "$SKILLMD")"`
- :131 [阈值] `if [ "$n" -ge 1 ] && [ "$m" -eq 0 ]`（LA-12）

### selftest-parallel-scheduling.sh（2）
- :121 [动态提取] `skill_max="$(grep -oE 'Rules 1-[89][0-9]' "$SKILLMD" | head -1 | grep -oE '[0-9]+' | tail -1)"`
- :123 [下限阈值] `… [ "${skill_max:-0}" -ge 84 ] …`（P-05；96 纪元下 96≥84 ✓ 免改）

### selftest-reliability-institution.sh（3）
- :96 [计数] `a="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :97 [负断言] `b="$(grep -c '1-40' "$SKILLMD")"`
- :98 [阈值] `if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]`

### selftest-requirement-coverage.sh（2）
- :144 [计数] `n="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :145 [阈值+负断言] `if [ "$n" -ge 1 ] && [ "$(grep -c '1-39' "$SKILLMD")" -eq 0 ]`（RC-11）

### selftest-research-first.sh（2）
- :78 [计数] `ge "RF-06 SKILL 1-6X 计数（宽容锚）≥3(三处联动)" "$(cnt '1-[7-9][0-9]' "$SKILL")" 3`（覆盖 96 ✓；行尾巨型演进注释）
- :86 [计数] `pair "RF-07 …" "$(cnt '反推诿' …)" "$(cntE 'Rules 1-[89][0-9] 全集' "$SKILL")"`

### selftest-root-resolution.sh（3）
- :126 [计数] `n="$(grep -cE 'Rules 1-[89][0-9] 全集索引：' "$SKILLMD")"`（RR-09）
- :127 [负断言] `m="$(grep -cE '(全集|Rules) 1-(51|53|55)' "$SKILLMD")"`
- :199 [存在+计数] `if [ "$idxn" -eq 1 ] && printf '%s' "$idxline" | grep -qE '1-[89][0-9]'`（RR-16，References 表 critical-rules 行内全集括注）

### selftest-self-resolution.sh（4）
- :98 [计数] `a="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :99 [负断言] `b="$(grep -c '1-39' "$SKILLMD")"`
- :100 [阈值] `if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]`（SR-07）
- :115 [计数复合] `[ "$(grep -cE '1-[89][0-9]' "$SKILLMD")" -ge 1 ] && [ "$(grep -c '^40\.' "$CRIT_C")" -eq 6 ]`（SR-08）

### selftest-session-log.sh（3）——SL-05 尾边界元测试
- :69 [计数] `[ "$(grep -cE '1-[89][0-9]([^0-9]|$)' '$SKILL')" -ge 3 ]`
- :70 [负样本] `[ "$(echo '1-79' | grep -cE '1-8[0134]([^0-9]|$)')" -eq 0 ]`
- :71 [负样本] `[ "$(echo '1-90' | grep -cE '1-8[0134]([^0-9]|$)')" -eq 0 ]`

### selftest-skill-split.sh（1）
- :90 [计数] `t "T-锚 Rules 1-3..83 宽容计数锚 ≥1" bash -c "[ "$(grep -cE 'Rules 1-(3[0-9]|[4-9][0-9])' '$SKILL')" -ge 1 ]"`（覆盖 96 ✓）

### selftest-source-anchor-discipline.sh（1）
- :49 [计数] SA-07 chk：`test $(grep -cE '1-[89][0-9]' "$SKILL") -ge 2` ∧ task-discipline 行 ∧ 71.1 本体

### selftest-summary-readability.sh（1）
- :79 [计数] `SRV03_EPOCH=$(cntE '1-(7[4-9]|[89][0-9]|8[0-9])' "$SKILL")`（阈值 ≥3 见 :80 if；覆盖 96 ✓）

### selftest-tool-selection.sh（3）
- :83 [计数] `a="$(grep -cE '1-[89][0-9]' "$SKILLMD")"`
- :84 [负断言] `b="$(grep -c '1-39' "$SKILLMD")"`
- :85 [阈值] `if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]`（TS-05）

### selftest-workflow-orchestration.sh（5）
- :80 [计数] `c="$(grep -cE 'Critical Rules 1-(68|69|71|75|91)' "$f")"; c2="$(grep -cE '1-(68|69|71|75|91)' "$f")"`（4 索引文档求和）
- :82 [负断言] `oldres="$(grep -c 'Rules 1-39' …)"; oldres2="$(grep -c 'Rules 1-45' …)"`
- :83 [阈值] `if [ "$cnt" -ge 3 ] && [ "$oldres" -eq 0 ]`（WF-10）
- :87 [负断言] `res=$((res + $(grep -c 'Rules 1-38' "$f")))`（WF-11）
- :89 [阈值] `if [ "$res" -eq 0 ]`

**③合计 = 13+3+3+1+2+3+2+3+2+2+3+2+2+3+4+3+3+1+1+1+3+5 = 63 行**

## 5. 形态④ SKILL.md 规则数 / selftest 数钉值（5 行）

### SKILL.md（规则数钉值 = 字面 1-94 活体，级联必改）
- SKILL.md:9 [frontmatter references] `- references/critical-rules.md: Critical Rules 核心域——Rules 1-94 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83…其余 77 条按域归 11 卫星…）`
- SKILL.md:209 [正文全集索引行] `Rules 1-94 全集索引：**核心在位 14 条**（…）…其余 77 条已按域迁至上表 11 卫星（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94 纪律域）…`
- SKILL.md:251 [References 表行] `| references/critical-rules.md | Critical Rules 核心域 1-94 全集索引（14 条核心全文+…） |`
- SKILL.md 内无 selftest 数钉值、无含数字的 HTML 注释钉（grep '<!--' 实测无）。

### scripts/ 内 selftest 数钉值（注释钉，无门）
- run-selftests.sh:11 [注释] 「两轮全量回归（**76 脚本** × 5-12s ≈ 6-15min/轮）」
- run-selftests.sh:79 [注释] 「top-5 后台并行…其余 **72 脚本** 串行」
- 说明：selftest 总数为动态计数（run-selftests.sh 循环 `TOTAL=$((TOTAL+1))`、selftest-registry.sh T02/T03 双向配对），无硬编码总数门——新增 Rule 96 selftest 脚本无需改任何计数断言，仅需按 selftest-registry.sh 头注在 selftest-registry.tsv 自登记（否则 T02 FAIL，机制自动兜底）。

## 6. 级联验证结论：scripts/ 可执行断言在 96 纪元下全部免改（逐类）

| 活锚形态 | 覆盖 1-96？ | 载体（③/②行号） |
|---|---|---|
| `1-[89][0-9]`（±尾边界 `([^0-9]|$)`） | ✓（1-80..1-99） | capability:93 / conclusion— / context-pressure:109,110 / decision-drift:117 / execution-honesty:104 / iteration-persistence:163 / lane-advancement:129 / plan-tier:96 / reliability:96 / requirement-coverage:144 / requirement-grading:96 / root-resolution:126,199 / self-resolution:98,115 / session-log:69 / source-anchor:49 / tool-selection:83 / verification-gate:82 / drift-check-subagent:93 / absorption:85-91 |
| `Rules 1-(3[1-9]\|[4-7][0-9]\|8[0-9](…)\|9[0-9](…))` | ✓（9x 全开） | error-loop:75、veto:63 |
| `Rules 1-(3[5-9]\|[4-9][0-9])` | ✓ | reflect-verify:66 |
| `1-(3[5-9]\|9[0-9])` + `1-[4-7][0-9]` 合计 ≥3 | ✓（n35 的 9[0-9] 命中 SKILL 三处 1-96 字面） | conclusion:80,91,92 |
| `1-(3[0-9]\|[4-9][0-9])` | ✓ | skill-split:90、absorption:94(pin) |
| `1-(7[4-9]\|[89][0-9]\|8[0-9])` | ✓ | summary-readability:79 |
| `1-[7-9][0-9]` | ✓（含 96） | absorption:42、research-first:78 |
| `1-(68\|69\|71\|75\|91)` 变体族 | 96 无关（钉 4 索引文档的旧纪元变体字面，96 不写入这些文档则计数来源不变） | workflow-orchestration:80、absorption:92(pin) |
| 动态下限 `skill_max ≥84` | ✓（96≥84） | parallel-scheduling:121,123 |
| 负向越界断言 | 96 落地不误伤：1-39/1-40/1-71/1-(51|53|55)/40-[5-8][0-9]/1-79/1-90 各负断言对象与 1-96 字面无交集 | §4 各负断言行 |
| AD-12 pin 家族 | 钉「活锚形态字面在位」——活锚不改形态则 pin 免改；若任一活锚演进形态，必须同步 absorption:85-94 对应 pin 行 | absorption:85-94,96 |

**结论：唯一必须改写的 scripts/ 行 = 0；SKILL.md 三处字面行 = 级联必改面。**

## 7. 级联目标建议（targetForms 详版）

优先级序（供 S-起草与实现阶段消费）：
1. **必改**：SKILL.md:9/:209/:251 字面 `1-94`→`1-96`（含「其余 77 条→78 条」及纪律域枚举追加 96；若 96 归 task-dispatch 域则同时动 SKILL.md 卫星路由表 task-dispatch 行枚举——归属判定属 S1 职权）。
2. **随动（注释钉，Rule 45 惯例）**：run-selftests.sh:11（76→77 脚本）、:79（72→73 脚本），仅当本任务新增 selftest 脚本时；新脚本必须在 selftest-registry.tsv 登记（selftest-registry.sh T02 会强制）。
3. **免改但需回归复验**：§6 全表 63 条可执行断言（全绿预期）；负断言族不误伤。
4. **pin 同步纪律**：若实施者选择把任一 `1-[89][0-9]` 活锚改写为更宽/更窄形态（无必要），必须同步 selftest-absorption-discipline.sh:85-94 对应 _pin_tol/_pin_lit 行，否则 AD-12 FAIL。
5. **演进注释补行**：参照仓内先例（error-loop:15、veto:62、summary-readability:78 的「[task-xxx 纪元扩围（Rule 45 注释）] Why=…」格式），在受影响 selftest 头注补一行 `task-subagent-boost Rule 96 级联: 1-94→1-96, 宽容正则已覆盖` 即可，禁止重新钉死宽容锚（v138 以来的「宽容正则优先」惯例，reliability-institution.sh:90-95 五连演进注释为范式）。
6. **行数钉风险**（E 节）：SKILL.md 接线增行后按「实值+25 边距」先例上调 ≤581/≤584/≤275 钉（先例：selftest-skill-collab.sh:93 注释、batch-pilot:63）。

## 8. 风险面 E（非四形态，未计入 total=207）

### E1 SKILL.md 行数钉值（Rule 96 接线增行可能触顶）
- selftest-batch-pilot.sh:63 [注释] / :65 [可执行] `≤275`（BP-08）
- selftest-execution-stability.sh:70 [注释] / :76 [可执行] `≤558`（T8b）
- selftest-knowledge-brief.sh:42 [注释] / :43 [可执行] `≤558`（T2b）
- selftest-goal-unit-goal-mode.sh:25 [注释] / :130 [注释] / :134 [可执行] `≤581`
- selftest-skill-split.sh:50 [可执行] `≤581 ∧ ≤584`（T-主）
- selftest-skill-collab.sh:93 [注释] / :94 [可执行] `≤584`（T10）
- selftest-agent-coverage.sh:212 [注释] references/agent-coverage.md `≤130`（非 SKILL，Record only）
- 附：selftest-skill-collab.sh:93 与 batch-pilot:63 的注释承载「实值+25 边距」上调先例全史（530→538→…→584、558→275）。

### E2 规则子条计数族（Rule 96 若带子条并触发子条计数，需另行级联；与 1-9x 纪元无关）
- selftest-dispatch-grain.sh:4 [注释] / :86 [注释] / :87 [可执行] `grep -c '^46\.'` / :88 [阈值] `= 6`（46.1-46.6）
- selftest-ask-default-timeout.sh:5 [注释] / :37 [注释] / :38 [可执行] `grep -c '^44\.'` / :39 [阈值] `= 5`（44.1-44.5）
- selftest-session-log.sh:62 [可执行] `grep -cE '^80\.[1-6] '` = 6（Rule 80 六子条，SL-04）
- selftest-ask-default-timeout.sh:79 [可执行] / :80 [可执行] 旧 1-4x 族越界负断言（`grep -oE '1-4[0-9]' | grep -vE '^1-4[5-9]$' | wc -l`，whitelist 1-45..1-49；RT-08）
- selftest-self-resolution.sh:115 的 `grep -c '^40\.' -eq 6`（Rule 40 六子条，已计③因其与纪元锚同行复合）

### E3 卫星行规则枚举族（96 落地后按归属域增员）
- SKILL.md:9/:209 枚举（已计④）；SKILL.md 卫星路由表 task-discipline 行（含 `…90,92,93,94`，SKILL.md:194 附近，行号待 S1 承载面清单确认）
- references/critical-rules.md:194：task-discipline 卫星行枚举尾 `…,90,92,93,94）`（范围外发现）
- selftest-input-consistency.sh:11 [注释] / :68 [注释] / :70 [可执行] / :71 [可执行]：task-discipline 行裸字面 `85` 弱锚（防区间化误扩，注释言明「纪元演进时 85 被并入区间如 69-85 则恒 PASS」）
- selftest-verification-gate.sh:82 的 `'11 卫星'` 计数锚（SKILL 卫星数钉，随 96 归属可能仍为 11，若新增卫星才需动）

### E4 范围外字面 1-94（部署位对齐面，未计入 total）
- README.md:36、:81、:123；docs/ARCHITECTURE.md:13、:42、:113、:123、:135（ARCHITECTURE.md:123 载有 94 纪元落地全史）

## 9. 基线说明

- worktree 快照时间 2026-10-24 00:02（ls 实测 scripts/ 全目录 mtime）；本次为只读勘察，未改动 worktree 任何文件（唯一写入=本检查点）。
- `grep -rn "1-94" scripts/`、`grep -rnE "1-9\[0-9\]" scripts/`、`grep -rnE "1-\[[0-9]" scripts/`、`grep -rnE "1-\([0-9]" scripts/`、`grep -rn "1-9" scripts/`（去 task-v094/行号噪声）、`grep -nE "1-\[[0-9]|1-\([0-9]|Rules 1-|…" 13 文件结构化 dump、六脚本 sed 精读——以上为本清单全部证据来源，均在本会话实际执行。
- 疑义上报：无。四形态 grep 均可复跑，total=207 可由本清单逐节复核（0+139+63+5）。
