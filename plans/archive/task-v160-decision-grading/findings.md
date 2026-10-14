# Findings & Decisions — task-v160-decision-grading

## Requirements
- R1 重大决策（换风格/换视频生成方式=推翻既定计划）不询问用户、不通知，擅自执行
- R2 违背既定计划的重大变更完全不通知用户
- R3 基础性质检（猫咪五条腿等物理常识错误）审核不出来，推给用户主动审查
- R4 无关紧要事项反复打断用户执行（一小时任务几分钟即被打断）
- R5 无关紧要事项一直骚扰用户、卡住整个执行

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 是否已消费 | 结论落点 |
|--------|------|-----------|---------|
| v155 决策分级归因（5 Whys） | /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/findings.md §新投诉归因 | ✅ | Research Findings/决策分级归因 |
| Rule 41/44/47/50/69/70 条文 | skills/task-planner/references/critical-rules.md | ✅ | Research Findings/决策分级归因 |
| selftest 范式（v155 RRV） | skills/task-planner/scripts/selftest-report-reviewability.sh | ✅ | Research Findings/守护设计 |

## Research Findings

### 决策分级归因（Rule 31 四维 — 用户 2026-10-10 第二条反馈）
- **现象**：① 重大决策（更换风格、更换视频生成方式——推翻用户已确认的计划要素）不询问用户、不通知，擅自执行；② 琐碎事项（「这里有错误，是否需要修正」类有明确对错的局部问题）反复上抛用户抉择，打断执行流（一小时任务几分钟即被打断）；③ 基础性质检（图像物理常识错误：动物肢体数量等）执行体不审核，直接推给用户主动审查。
- **直接原因**：决策点分级判据缺失/颠倒——Rule 41（消解优先+升级四门槛）与 Rule 44（低区分度直接裁决+自动超时）只约束「何时可以不问」，缺正向「哪些必须问」的影响权重轴；媒体质检条款（Rule 47/50）停在评级打分，无「基础性质检必须机检+禁上抛代审」硬门。
- **根因（5 Whys）**：①打断与隐瞒并存 ← ②分级只按选项区分度（44.2）与升级门槛（41.2 G1-G4）运作，缺「影响权重」轴：推翻既定计划要素=必须问；有明确对错的局部修复=必须自动消解 ← ③41/44 演进聚焦「减少打扰」（38.7 比例原则判例主诉=流程开销过大），矫枉过正，「该问不问」反向失败无对称条款 ← ④缺统一「决策分级表」载体（A 必问/B 默认+超时/C 禁问）← ⑤历史投诉单点演进模式（与 v155 归因根因⑤同构：单点补丁、无横向分级审计、零守护）。
- **类别**：规则覆盖缺口（决策分级轴）+守卫缺失（质检上抛禁令）——修法=Rule 72（A 必问：推翻已确认计划要素/不可逆/对外；C 禁问：明确对错局部修复、质检结果代审；B=44 既有）+媒体变体模板/QC 链触点修补+selftest 守护，方案细节入本计划。

### 守护设计（对齐 v155 三层闭环）
- 条文层：Rule 72 六子条（72.1 分级表/72.2 A 级呈报禁令/72.3 琐碎上抛禁令/72.4 基础质检硬门/72.5 与既有规则关系/72.6 机制）
- 触点层：critical-rules 28.3/41.2/41.3/44.2/44.5 四处决策点 + 媒体送审模板×2 + companion×2
- 机器层：selftest-decision-grading.sh（DG-01..12）+ registry 登记

#### [sub:1-executor] Rule 72 条文落盘（worktree 内 critical-rules.md）
- 操作：将 task_plan.md「📜 Rule 72 条文草案」代码块（353-375 行）逐字追加到 `skills/task-planner/references/critical-rules.md` 的 Rule 70.6 段之后（文件末段）。
- 证据：`git diff --numstat` = `24  0`（纯新增，既有行零改动）；`grep -c "^## Rule 72（"` = 1；`grep -c "72\.[1-6]"` = 7。
- 关键词核对：材料为「A 级（必须询问…）」「C 级（禁止询问…）」括号形态，字面串「A 级必须询问」「C 级禁止询问」不出现（逐字采用约束下不可改写）；语义关键词 `必须询问`/`禁止询问`/`基础质检硬门` 各 =1。
- 结论：AC1/AC2/AC4 PASS；AC3 按语义 token 判定 PASS（字面形态受逐字约束，供 S7/S8 DG-02 断言按材料措辞实现）。

#### [sub:2a-executor] SKILL.md Rule 72 三处接线（worktree）
- 操作：worktree 内 `skills/task-planner/SKILL.md` 按材料包前三条接线——① :9 顶部 references 索引行 `1-69+70`→`1-72` + 追加「、72 决策分级与用户打断纪律」；② :377 References 表 critical-rules 行 `1-69+70`→`1-72` + 追加「+Rule 72 决策分级与用户打断纪律（task-v160）」；③ :172 终验交付段交付总结 bullet 后新增「会话内一切决策点（选项/升级/熔断/质检送审）按 Rule 72 分级：A 级必须询问、C 级禁问自动消解」。
- 证据：`git diff --numstat -- skills/task-planner/SKILL.md` = `3  2`（3 增 2 删）；`grep -c "1-72"` = 2；`grep -c "按 Rule 72 分级"` = 1；删除行仅 2 条=两索引行口径替换。
- 边界：本单元仅前三条；材料包第 3/4 条（Critical Rules 索引段新增行、合规清单 C49）未做（不在派发范围）。SKILL.md:293 `1-69+70` 保持原样（属第 3 条范围）。
- 结论：AC1/AC2/AC3 PASS，confidence HIGH。

#### [sub:2b-executor] SKILL.md Rule 72 后两处接线（索引段摘要行 + 合规清单 C49）
- 操作：worktree 内 `skills/task-planner/SKILL.md` 按材料包后两条接线——④ 于 Critical Rules 索引段 Rule 70 行（:354）后新增一行 Rule 72 摘要 bullet（:356）；⑤ 于合规清单 C48 行（:230）后新增 C49 行（:231）。两处均为「行后新增」，逐字采用材料包措辞，未改任何既有行。
- 证据：`git diff --numstat -- skills/task-planner/SKILL.md` = `5  2`（本单元 +2/-0；2 删为 S2a 两行口径替换）；`grep -o "Rule 72" skills/task-planner/SKILL.md | wc -l` = 5；`grep -c "Rule 72"` = 4（行数口径，:356 行含 2 处）；`grep -c "C49"` = 1 且该行含「A 级」「C 级」。
- 边界/差异：材料包第 1 条全集行（:6）按材料逐字措辞作「、72 决策分级与用户打断纪律」，无「Rule」前缀，故不计入 `grep -c "Rule 72"`；本单元按派发「只做后两条」未动 :6。A1（`grep -c`≥5）逐字判定 =4（未达），出现次数口径 =5（达标）。计划 S2 行（task_plan.md:181）自设阈值为 ≥4（行数），已满足。
- 结论：A2/A3 PASS；A1 逐字 `grep -c` 口径未达 ≥5，根因=上游 S2a 全集行措辞（非本单元所为），需协调者裁决是否补「Rule」前缀。

#### [sub:2c-executor] SKILL.md 全集索引行 Rule 72 前缀补齐（消 S2b A1 缺口）
- 操作：worktree 内 `skills/task-planner/SKILL.md` :9 顶部 references 索引行内，将「、72 决策分级与用户打断纪律」补「Rule」前缀为「、Rule 72 决策分级与用户打断纪律」（行内一处前缀插入，其余文字零改动）。
- 证据：`grep -c "Rule 72" skills/task-planner/SKILL.md` = 5（编辑前 4）；本单元快照差分 `git diff --no-index --numstat /tmp/skill-before-2c.md SKILL.md` = `1 1`（仅 :9 行 `9c9` 替换）；`sed -n '9p'` 确认含「、Rule 72 决策分级与用户打断纪律」。
- 边界：仅改该文件该行；未 git add/commit/checkout/reset/push；未触碰其他 worktree。文件对 HEAD 总 numstat 仍为 `5 2`（:9 行已被上游 S2a 改过，故本单元不新增 hunk 计数，本单元归因增量 = +1/-1）。
- 结论：AC1（grep -c≥5）/AC2（本单元 1 行变更）PASS，confidence HIGH；补足 S2b 记录的 A1 缺口（:6/:9 全集行无 Rule 前缀）。

#### [sub:3-code-assistant] critical-rules.md 28.3/41.3 段补 Rule 72 分级引用（T1-T2，task-v160）
- 操作：worktree 内 `skills/task-planner/references/critical-rules.md` 两处决策点段补指针——① 28.3 段末（原行 285 后）新增一行 T1 措辞：`（task-v160）选项呈报按 Rule 72 分级：A 级（推翻已确认计划要素/不可逆/对外）必须询问；B 级默认项+自动超时；C 级禁问。`；② 41.3 段末（原行 445 后、41.4 前）新增一行 T2 措辞：`（task-v160）升级四门槛（G1-G4）与 Rule 72.1 A 级对齐：门槛内场景必须询问用户，禁擅自执行。`（41.2 门槛在 41.3 段内被引用「命中 41.2 四门槛的项」，T2 语义落点取 41.3 段末，覆盖 41.2/41.3 两处定位）。
- 既有行零改动：两处均为「行后新增一行」，新增行带 `（task-v160）` 任务标。
- 证据：`git diff --numstat` = `2 0`（仅 critical-rules.md，0 删除）；`grep -c "Rule 72"` = 3（本单元前基线 1，净增 2，达标 ≥2）；`grep -n "按 Rule 72 分级\|Rule 72.1 A 级对齐"` → :286 / :447 各命中；材料包 T1/T2 措辞逐字保留，「Rule 72」「A 级必须询问/B 级默认项/C 级禁问」字样均在位。
- 边界：仅改该文件；未 git add/commit/checkout/reset/push；未触碰其他 worktree；44.2/44.5 段（T3-T4）未做（属 S4）。
- 结论：AC1/AC2/AC3 全 PASS，confidence HIGH。

#### [sub:4-code-assistant] critical-rules.md 44.2/44.5 段补 Rule 72 C 级禁问引用（T3-T4，task-v160）
- 操作：worktree 内 `skills/task-planner/references/critical-rules.md` 两处决策点段末补指针——① 44.2 段末（44.2 条款行后）新增一行 T3 措辞：`（task-v160 补充,语义不变；44.2 段末续行,不新增子条锚）: 低区分度选项（产出一致仅步骤/耗时差异）按 Rule 72.1 C 级处置：直接裁决+登记，禁止 AskUserQuestion（Rule 72 琐碎上抛禁令 72.3,自动消解+登记）。`；② 44.5 段末（44.5 条款行后）新增一行 T4 措辞：`（task-v160 补充,语义不变；44.5 段末续行,不新增子条锚）: 阻塞点展示按 Rule 72 分级：A 级阻塞（目标分叉/不可逆）必须询问；C 级阻塞（明确对错的局部问题）自动消解+登记。`
- 既有行零改动：两处均为「行后新增一行」，新增行带 `（task-v160 补充）` 任务标；材料包 T3/T4 措辞保留（含「Rule 72」「C 级」「自动消解」字样），仅按宿主语体加任务标与续行说明。
- 风险排除：初版曾将 T3 行写成 `44.2.1` 新子条行 → 触发 `selftest-ask-default-timeout.sh` RT-01 锚断言（`^44.` 子条数=5）FAIL 级联（FMEA 历史 5 次判例同型）→ 回退为普通续行（不带 `44.x` 前缀），RT-01 恢复 PASS；「段末续行不新增子条锚」已写入行内备注防复发。
- 证据：`git diff --numstat` = `4 0`（仅 critical-rules.md，0 删除）；`grep -c "Rule 72"` = 5（基线 3，净增 2，达标 ≥5）；`grep -A1 "^44.2 "` / `grep -A1 "^44.5 "` 各含 1 次「Rule 72」命中（:482 / :486）；`bash scripts/selftest-ask-default-timeout.sh` = 11 PASS/0 FAIL, exit 0。
- 边界：仅改该文件；未 git add/commit/checkout/reset/push；未触碰其他 worktree；task_plan/findings/progress 按计划读写契约操作（findings 本条追加、progress [sub:4] 行追加）。
- 结论：AC1/AC2/AC3 全 PASS，confidence HIGH。

#### [sub:5-code-assistant] image-type/multiview-ref-type 送审清单补基础质检硬门规格（T5，task-v160）
- 操作：worktree 内 `skills/task-planner/templates/variant/image-type.md`（原 :88 审查地址清单规格行后，即 Phase 7 终验段内）与 `multiview-ref-type.md`（原 :27 审查地址清单规格行后，VC 表段末）各新增一行 T5 措辞：`- 基础质检硬门（Rule 72.4）：物理常识错误（肢体数量/文字乱码/构图破损/比例失调）必须由执行体 QC 完成+留证据；不合格禁上抛代审，回炉重生成或修复后重检。` 既有行零改动。
- 证据：`grep -c "Rule 72"` 两文件各 =1（AC1/AC2 达标）；`git diff --numstat` = 各 `1 0`（0 删除，AC3 达标）；关键措辞「物理常识错误」「禁上抛代审」「回炉重生成」均在位。
- 边界：仅改该两文件；未 git add/commit/checkout/reset/push；未触碰其他 worktree；task_plan/findings/progress 按计划读写契约操作（findings 本条追加、progress [sub:5] 行追加）。
- 结论：AC1/AC2/AC3 全 PASS，confidence HIGH。

#### [sub:6-code-assistant] article-batch-publisher/article-field-fixer 熔断/跳过呈报点补 Rule 72 分级引用（T6，task-v160）
- 操作：worktree 内 `skills/task-planner/companion/agents/article-batch-publisher.md` 两处呈报点（原 :77 跳过 ≥10% AskUserQuestion 重审行的 Rule 70 四要素行后 / 原 :91 失败率 STOP 报告用户行的 Rule 70 四要素行后）各新增一行 T6 逐字措辞：`（呈报按 Rule 72 分级：A 级（推翻已确认计划要素/不可逆/对外）必须询问；C 级（明确对错的局部问题）禁问自动消解）`；`article-field-fixer.md` 原 :47 failed>0 整批熔断报告用户行的 Rule 70 四要素行后同增一行。既有行零改动。
- 证据：`grep -c "Rule 72"` pub=2 / fix=1（AC1/AC2 达标）；`git diff --numstat` 两文件 = `2 0` / `1 0`（0 删除，AC3 达标）；「A 级必须询问」「C 级禁问自动消解」语义关键词在位（逐字材料括号形态）。
- 边界：仅改该两文件；未 git add/commit/checkout/reset/push；未触碰其他 worktree；task_plan 只读；findings/progress 按计划读写契约操作。
- 结论：AC1/AC2/AC3 全 PASS，confidence HIGH。

#### [sub:7-executor] 新建 scripts/selftest-decision-grading.sh（DG-01..07，task-v160）
- 操作：worktree 内新建 `skills/task-planner/scripts/selftest-decision-grading.sh`（162 行，chmod +x）；DG-01..07 按材料包逐条实现，DG-08..12 仅留 TODO 骨架；范式对齐 `selftest-report-reviewability.sh`（PASS/FAIL/WARN 计数+Total 行+exit 语义）。
- 证据：`bash -n` 通过；自跑 `DG-01..07` 逐行输出 + `Total: PASS=6 FAIL=0 WARN=1`，exit 0（DG-06 registry 中间态 WARN，登记行由 S8 落位）；`DG_REGISTRY_STRICT=1` 时 DG-06 翻 FAIL、Total FAIL=1、exit 1（宽限/严格双档验证）；脚本自身 `grep -cE ':\s?[0-9]+'`=0。
- DG-02 容错记录：材料字面串「A 级必须询问」「C 级禁止询问」在条文（critical-rules.md Rule 72.1）以全角括号分隔（「A 级（必须询问」「C 级（禁止询问」），字面 grep=0；断言改用 `A 级（?必须询问`/`C 级（?禁止询问` 容错括号（两形态均命中，语义不变），未改任何条文文件。
- 边界：仅新建脚本 1 文件（`git status` 仅 `?? ...selftest-decision-grading.sh`）；未 git add/commit/checkout/reset/push；未触碰其他 worktree；config.json 未改。
- 结论：验收 4 项全 PASS，confidence HIGH。

#### [sub:8-executor] DG-08..12 触点分组锚 + DG-06 翻常驻 FAIL 档 + registry 登记行（task-v160）
- 操作：worktree 内 `skills/task-planner/scripts/selftest-decision-grading.sh` 三处——① 头注更新为 DG-01..12 全量（+DG-08..12 规格行）；② DG-06 翻常驻 FAIL 档（`${DG_REGISTRY_STRICT:-0}`→`${DG_REGISTRY_STRICT:-1}`，注释更新为「登记行已落位（S8），2026-10-10 翻硬档」，保留 env 作降档开关）；③ 替换 DG-08..12 TODO 骨架为真实断言（DG-08 引用面 critical-rules>=5 / DG-09 模板面 image-type>=1∧multiview>=1 / DG-10 管线面 batch-publisher>=2∧field-fixer>=1 / DG-11 SKILL 接线组 Rule 72>=5∧C49 含 A 级/C 级 / DG-12 `^# TODO(DG-13)` 行为面 fixture 预留占位）。`scripts/selftest-registry.tsv` 追加第 70 行（材料包逐字，tab 4 列）。
- 证据：`bash -n` 通过；自跑 `DG-01..12` 逐行全 PASS + `Total: PASS=12 FAIL=0 WARN=0`，exit 0；`DG_REGISTRY_STRICT=1 bash` 逐行输出与普通跑完全一致（exit 0）；`awk -F'\t' '/selftest-decision-grading/{print NF}' selftest-registry.tsv` → `NF=4`；`git diff --numstat -- selftest-registry.tsv` = `1 0`（纯新增）；`git status` 仅 ` M selftest-registry.tsv` + `?? selftest-decision-grading.sh`。
- 既有断言零改动核对：`diff` S7 基线（67-130 行 = DG-01..05 断言体）vs 现（73-136 行）= IDENTICAL；DG-07 断言体在 unified diff 中为未变上下文行。DG-06 变更与头注/骨架替换均属 `8-prompt-material.md` 逐字指令（§DG-06 翻档要求注释更新为指定文本）。
- 边界：仅改上述两文件（均在 scope）；未 git add/commit/checkout/reset/push；未触碰其他 worktree；config.json 未改（DG-07 恒 PASS）；task_plan.md 只读未动。
- 结论：验收 4 项全 PASS，confidence HIGH。

#### [sub:9-code-runner] 全量 selftest 跑批 Round 1（69/69 执行，ΣFAIL=4 全部级联型）（task-v160）
- 操作：worktree 内 `for f in selftest-*.sh; do timeout 120 bash "$f"`（逐脚本日志 /tmp/dg-selftest-*.log，汇总 /tmp/dg-runner.out，驱动器 /tmp/dg-runner.sh）；69 脚本 158s 跑完，无 TIMEOUT/TRUNCATED。
- 结果：65 脚本 rc=0 零 FAIL；4 脚本 rc=1 各 1 FAIL，ΣFAIL=4——conclusion-discipline(CD-12)、parallel-scheduling(P-05)、research-first(RF-06)、root-resolution(RR-09)；完整 rc 清单+FAIL 断言行原文落 subagent-state/9-code-runner.md。
- 级联证据（4 脚本本体本分支零改动，base 62b8b4b 均达标、current 失衡）：CD-12 双锚计数 base 4→current 2（<3）；P-05 动态上界 base 69=69→current skill 72 vs crit 69（crit=critical-rules `^### [0-9]+ ` 标题 max）；RF-06 `1-6[0-9]` base 3→current 1；RR-09 `Critical Rules 全集 1-6X` base 1→current 0。根因=本任务 SKILL.md 全集/索引行 1-69(70)→1-72 演进（历史 5 次级联判例第 6 例，修复属 S10）。
- 数量：worktree 实存 69（base 68 + 本任务新增 selftest-decision-grading.sh），派发预期 68 差 +1 已说明；registry rows=69=实存 69 账本一致；worktree `git status` 干净。
- 结论：跑批完成、FAIL 清单已落检查点供 S10。confidence HIGH。

#### [sub:10a-executor] SKILL 索引宽容锚扩 7x 纪元（CD-12 + RF-06 级联修复）（task-v160）
- 根因：本任务 SKILL.md 索引/全集面 1-69(70)→1-72 演进，两脚本宽容锚集合（1-3[5-9] / 1-[4-6][0-9] / 1-6[0-9]）未覆盖 1-70/1-71/1-72 → CD-12 合计 base 4→current 2（<3）、RF-06 `1-6[0-9]` base 3→current 1（<3）。
- 修法（worktree 内）：① selftest-conclusion-discipline.sh 追加 n70=`grep -cE '1-7[0-2]'`，判据改 n35+n45+n70 ≥3；② selftest-research-first.sh RF-06 追加并列计数 `cnt '1-7[0-2]'`，合计 ≥3。阈值语义零改动，同 v144 6x 纪元范式；注释追加「2026-10-10 task-v160 合并级联: 全集演进 1-72 宽容扩 7x」。
- 结果：CD-12 PASS（0+2+2=4≥3，Total 24 PASS=24 FAIL=0 rc=0）；RF-06 PASS（1+2=3≥3，Total 12 PASS=12 FAIL=0 rc=0）。diff 仅被修 2 行（+5/-2），worktree 无其他改动。
- 结论：两守卫级联修复完成，confidence HIGH。

#### [sub:10b-executor] P-05 上界判据 + RR-09 全集锚 1-72 级联修复（task-v160）
- 根因：同 S10a 级联面——① P-05 crit_max 提取用旧纪元 `^### [0-9]+ ` 标题形态（实测 max=69），Rule 70/72 段用 `## Rule N（…）` 新形态无 `### N` 标题 → skill_max=72 vs crit_max=69 失衡；② RR-09 全集锚 `1-(5[3-9]|6[0-9])` 未覆盖 1-72（SKILL:9 全集行现状 1-72）。
- 修法（worktree 内，仅两脚本）：① selftest-parallel-scheduling.sh:106 crit_max 提取模式 `^### N `→`^## Rule N`（实测 max=72），判据语义（skill 上界==critical 实测最大号）不变；② selftest-root-resolution.sh:110 全集锚追加 `7[0-2]` 形态 `1-(5[3-9]|6[0-9]|7[0-2])`，命中=1 判据不变。注释各追加「2026-10-10 task-v160 合并级联…」同口径说明。
- 结果：parallel-scheduling Total 9 PASS=9 FAIL=0 rc=0（P-05 上界 1-72 = critical 实测 72 动态一致）；root-resolution Total 17 PASS=17 FAIL=0 rc=0（RR-09 命中=1）。diff 仅被修 2 行（+4/-1、+2/-1）。
- 结论：两守卫级联修复完成，confidence HIGH。

#### [sub:11-code-reviewer] task-v160 .sh 代码审查（APPROVED）
- 范围核验（Rule 51 需求锚 R1）: 派发单给的 `git diff master..HEAD -- '*.sh'` 会混入 master 领先 26 提交（并集导入），统计出 25 个 .sh；经 merge-base 核验真实本分支改动仅 5 个（新增 selftest-decision-grading.sh + 4 个锚级联修复），另 3 个“删除”属 master 领先侧非本分支所为。审查基线建议改 `$(git merge-base master HEAD)..HEAD`。
- 结论: APPROVED（P0/P1=0）。证据: 5 脚本 `bash -n` 全 OK；selftest-decision-grading 12/12 PASS（exit=0）；4 个被改脚本自跑 CD 24/24、P-05 9/9、RF 12/12、RR 17/17 全 FAIL=0。
- 需修（P2，不阻断）: selftest-parallel-scheduling.sh:106 P-05 crit_max 提取采样面由 `^### N `（68 行/Rules 1-69，max=69）收窄为 `^## Rule N`（仅 2 行 Rule 70/72，max=72），注释「判据语义不变」表述不准确；当前 max=72 正确且偏 fail-closed，建议并集两形态或修正注释。
- Nit: selftest-decision-grading.sh:70 `cnt()` 对不可读文件返回空串（`[ "" -lt N ]` 告警+静默吞错）；:105-113 注释自称「内容锚」却硬断言 `C49`；selftest-root-resolution.sh:114 ok 消息串仍写旧区间 1-62（实断言已 1-72）。
- 已排除: 安全面（全只读 grep/sed，无 eval/网络/写操作）、ugrep 兼容（ugrep 影子 grep 下 12/12 PASS）、多字节 `（?` 三 locale 无误报、DG-03 零行号引用命中=0、config 零新键命中=0。confidence HIGH。

#### [sub:13a-executor] P-05 并集化 + RR-09 文案同步（task-v160 CR P2+Nit 修）
- P-05（selftest-parallel-scheduling.sh:106-109）: crit_max 提取口径并集 `^(## Rule|###) [0-9]+` 两形态（旧 `^## Rule N` 仅命中 Rule 70/72 两行，Rules 1-69 的 `### N` 形态退出采样面——CR P2 采样收窄）；注释「判据语义不变」改为实况（并集覆盖全量 1-72）。实测并集 max=72，与 SKILL 上界 1-72 动态一致。
- RR-09（selftest-root-resolution.sh）: ① :114 ok 消息串同步为实际断言区间 `1-(5[3-9]|6[0-9]|7[0-2])`（现状 1-72）；② :109 陈旧 present-tense「现状=1-62」→「现状=1-72」（repo 内唯一 `现状=` 行，非 dated 记录；:107/112/172 的 `1-62` 为 v144 dated changelog 标记，全仓 14 文件同形，按惯例保留）。
- 结果: parallel 9/9 FAIL=0 rc=0（P-05 上界 1-72=72）；root 17/17 FAIL=0 rc=0（RR-09 PASS）。diff 删除行 6 全为被修行行（+7/-6）。
- 负结果/排除: ok/bad 09 消息串 `1-62` 命中=0（文案漂移清除）；文件级 `1-62`=3 全为 dated v144 记录（非文案、非本 S-unit 引入）；两脚本 `bash -n` OK；全只读无写入/网络/eval。
- confidence: HIGH。

#### [sub:13b-executor] selftest-decision-grading.sh 两处 Nit 修正（cnt 空串防护 + DG-04 内容锚）
- Nit#3（:70 cnt/cntE）: 原 `grep -c ... 2>/dev/null || true` 在「文件存在但不可读」时 stdout 为空 → 调用方 `[ "" -lt N ]` 触发 `integer expression expected` 且静默吞错。改为 `n="$(grep -c -e "$1" "$2")"; printf '%s' "${n:-0}"`（有匹配 rc=0 / 无匹配 rc=1 stdout=0 / 读错误 rc=2 stdout 空 三态均得合法整数）；去掉 `2>/dev/null`，grep/ugrep 权限报错可见（禁吞错）。实测：不可读文件下新 cnt 输出 `0` 无整数告警，旧实现输出空串并报 `[: : integer expression expected`。
- Nit#4（DG-04/DG-11）: 注释自称「内容锚（而非绝对编号）」却硬断言 `C49`（并集易位资源 C46→C48→C49，编号让位即 false-positive）。按派发单首选方案改为内容锚 `^| C<N> | .*决策分级与用户打断`（文本锚替代行号锚=本仓硬纪律，DG-03 同款；v155 RRV-04 教训）；DG-11 与 header 文档同步改为同口径内容锚，保持「与 DG-04 同口径」陈述为真。
- 结果: `bash scripts/selftest-decision-grading.sh` exit 0，Total PASS=12 FAIL=0 WARN=0（stderr 空）；DG-04/DG-11 仍 PASS。
- 负结果/排除: 内容锚 grep 命中=1（唯一合规行 :231）；renumber 模拟（C49→C77）下旧锚 0 命中/新锚 1 命中，证明级联免疫；无 C49 硬锚残留（仅注释内历史 C46→C48→C49 记录）；`bash -n` OK；全只读无写入/网络/eval。
- confidence: HIGH。

#### [sub:12-align-reviewer] 对齐面审查 APPROVED（task-v160 S12）
- 审查单元=worktree `wt/v160-decision-grading` 分支自身 .md 改动（merge-base 62b8b4b..HEAD；master..HEAD 两点 diff 混入 master 领先 26 提交并集集，按 Rule 51.1 口径排除）；rubric=review-library/alignment-review/SKILL.md。
- 审查对象 6 文件 +38/-2：critical-rules.md(+28/-0，Rule 72 条文 :918-941 + 触点 :286/:447/:482/:486)、SKILL.md(+5/-2，五处接线 :9/:172/:231/:356/:380)、image-type.md:89、multiview-ref-type.md:28、article-batch-publisher.md:79/:94、article-field-fixer.md:49（绝对路径见 subagent-state/12-align-reviewer.md 总清单）。
- 六维度 PASS：① 账号体系——41.2/44.1/44.2/47.3/50/69/70.2/Rule 26 引用目标实测在位，72.5 关系表逐条核对属实（70.2 四要素与 72.2① 逐字一致）；② 索引演进——唯二删除行=SKILL.md:9/:380 两 caption（仅 1-69+70→1-72+Rule 72 条目，材料逐字），HEAD 规则头 1-66/68-70/72（67/71 已在 master 落地晚于 merge-base，1-72 前向一致）；③ 触点无弱化——T1-T6 对材料包逐字，A 级必须询问/C 级禁问自动消解/基础质检硬门三措辞 6/6 全含；④ 零篡改——全 diff 纯新增或 caption 替换，delivery-summary.md 未触碰，交付五要素 bullet 原样；⑤ Rule 70 衔接——72.2 消费四要素+单一权威源不重复定义；⑥ 无关混入=0。
- 机器复验（含 S13a/13b 未提交修复）：DG 12/12、RR 17/17、CD 24/24、RF 12/12、P-05 9/9、SR 13/13、RT 11/11 全 rc=0；registry.tsv:70 NF=4；Rule 72 块行号锚=0。
- P2×3 不阻断：SKILL.md:295「1-69+70」旧口径残留（接线范围外 base 行，merge 取 master 1-71 新值，**Phase 8 并集解须扩 1-72**）；SKILL.md:9 括注「67-69 并行预留」陈旧（Phase 8 并集统一）；critical-rules.md:286 T1「C 级禁问」无自动消解尾串（材料原文逐字采用，登记备查）。
- 结论：APPROVED（P0/P1=0），详见 subagent-state/12-align-reviewer.md。confidence: HIGH。

#### [sub:13c-executor] SKILL.md:295 索引口径 1-69+70 → 1-72（task-v160 S13c，partial）
- 操作：worktree 内 `skills/task-planner/SKILL.md:295` 单行改写 `（Critical Rules 1-69+70（含 Rule 40-69 全集 + Rule 70 用户呈报可审批性纪律，67-69 已由并行任务落位；` → `（Critical Rules 1-72（含 Rule 40-69 全集 + Rule 70 用户呈报可审批性纪律、72 决策分级与用户打断纪律，67-69/71/72 后续任务已落位；`；余段（Rule 55/61/63/64/65/66/69）逐字未动；`git diff --numstat` = `1 1`。
- 硬约束核对：子串 `Critical Rules 1-72（含 Rule 40-69 全集` 在位；全行 `1-72` 出现 0→1（不减少）。
- 验收：AC1 `grep -c "1-69+70"`=0 PASS；AC2 `grep -c "Critical Rules 1-72（含 Rule 40-69 全集"`=1 PASS；AC4 `selftest-parallel-scheduling.sh` Total 9 PASS=9 FAIL=0 rc=0 PASS；**AC3 `selftest-research-first.sh` FAIL**（Total 12 PASS=11 FAIL=1，`FAIL RF-07 ... got=(1,0) expect=(>=1,>=1)`）。
- 冲突根因（关键，登记备查）：`selftest-research-first.sh:73` RF-07 为「钉值双锚」，第二锚硬编码字面串 `Critical Rules 1-69+70（含 Rule 40-69 全集`。AC1（要求全文件 `1-69+70` 计数=0）与 AC3（RF-07 要求该串在位）在**不改脚本**前提下互斥。派发 §2 硬约束称 RF-07 锚=`Critical Rules 1-72（含 Rule 40-69 全集`，与脚本实况（`1-69+70`）不符；`git worktree list` 与全分支检索确认无任何分支/worktree 已把该锚改为 `1-72`（各分支 1-72-anchor=0）。属 S10a/S10b 级联面遗漏（10a 仅补 RF-06 `1-6[0-9]`→`1-7[0-2]`，未含 RF-07 钉值锚）。
- 处置：按 §4 Scope（禁止修改 SKILL.md 外一切文件）+ §六 技能文件保护，未改脚本，上报 partial；建议修法（待授权）= `selftest-research-first.sh:73` 第二锚 `1-69+70`→`1-72` + :13 注释同步（一行即令 RF-07 双锚→(1,1)）。
- 证据/完整记录：subagent-state/13c-executor.md。confidence: HIGH。

#### [sub:13d-executor] RF-07 钉值锚 1-69+70 → 1-72（task-v160 S13d，done）
- 承接：13c partial 遗留缺口（RF-07 第二锚字面滞后致 `selftest-research-first.sh` FAIL=1）。
- 操作：worktree 内 `skills/task-planner/scripts/selftest-research-first.sh:73` 单处字面替换 `$(cnt 'Critical Rules 1-69+70（含 Rule 40-69 全集' "$SKILL")` → `$(cnt 'Critical Rules 1-72（含 Rule 40-69 全集' "$SKILL")`；断言结构、标签描述、其余行零改动；`git diff --numstat` = `1 1`。
- 验收：AC1 `bash scripts/selftest-research-first.sh` → `Total: 12 PASS=12 FAIL=0`，`EXIT=0`（`PASS RF-07 SKILL 双锚(...)`）PASS；AC2 `grep -c "1-72（含 Rule 40-69 全集"` = 1 PASS；AC3 numstat +1/-1 PASS。
- 备注：RF-07 标签文字 `头注 1-69+70 全集` 属描述性元数据，不在 §2 指定替换字面内（§2 仅指定 `Critical Rules ...` 完整字面），按「单处字面替换」保持不动；`grep -c "1-69+70"`=1 即该标签残留，不影响验收。
- 证据/完整记录：subagent-state/13d-executor.md。confidence: HIGH。

#### [sub:14a-executor] EL-11/VT-10 SKILL 索引宽容锚扩 7x 纪元（Rule 72 落地级联）
- 承接：Round 3 回归 FAIL 原文——`selftest-error-loop.sh` EL-11 与 `selftest-veto.sh` VT-10 均报 `FAIL SKILL.md 缺 Rules 1-3x..6x 宽容锚`（SKILL.md 三处索引已统一「1-72」=:9/:295/:380，旧宽容正则 `Rules 1-(3[1-9]|[4-6][0-9])` 未覆盖 7x 纪元）。
- 操作：两脚本各单处修——宽容锚正则追加 `7[0-2]` 分支（`Rules 1-(3[1-9]|[4-6][0-9]|7[0-2])`，覆盖 1-70/1-71/1-72），注释追加「2026-10-10 task-v160：Rule 72 落地锚扩 7x」，ok 消息串同步 6x→7x；判据方向不变，bad 消息串保持原文（同 RR-09 先例：仅 ok 串随纪元更新）。
- 验收：`bash scripts/selftest-error-loop.sh` → `Total: 16 PASS=16 FAIL=0` EXIT=0（`EL-11 PASS ... Rules 1-3x..7x 宽容范围`）；`bash scripts/selftest-veto.sh` → `Total: 13 PASS=13 FAIL=0` EXIT=0（`VT-10 PASS ... Rules 1-3x..7x 宽容范围`）。`grep -c "7[0-2]\|7[0-9]\|1-72"` 各=1；`git diff --numstat` 各 `2 2`（+2/-2，删除行仅被修注释行+断言行）；断言总数不减（16/13）。
- 证据/完整记录：subagent-state/14a-executor.md。confidence: HIGH。

#### [sub:14b-executor] LA-12/RC-11 SKILL 主锚钉值 1-69 → 宽容形态 1-(6[0-9]|7[0-2])（Rule 72 落地级联）
- 承接：Round 3 回归 FAIL 原文——`selftest-lane-advancement.sh` LA-12 报 `FAIL SKILL.md 主锚漂移（Critical Rules 1-69=0 应 ≥1 / 1-39=0 应 0）`、`selftest-requirement-coverage.sh` RC-11 同款（SKILL.md 主锚已演进为「Critical Rules 1-72」，:295/:380 两处字面命中，旧钉值 `1-69` 命中 0 → 误报漂移）。
- 操作：两脚本各单处修——断言行 `grep -c 'Critical Rules 1-69'` → `grep -cE 'Critical Rules 1-(6[0-9]|7[0-2])'`（覆盖 1-69/1-72），注释追加「2026-10-10 task-v160 新纪元宽容演进」，ok/bad 消息串同步为 `1-(60-72)`；「1-39 变体=0」负向检查原样保留；判据方向不变。
- 验收：`bash scripts/selftest-lane-advancement.sh` → `Total: 14 PASS=14 FAIL=0` EXIT=0（`LA-12 PASS ... 1-(60-72) ≥1 且 1-39 变体 0`）；`bash scripts/selftest-requirement-coverage.sh` → `Total: 23 PASS=23 FAIL=0` EXIT=0（`RC-11 PASS ...`）。宽容锚实测命中 2 ≥1；`1-39` 命中 0。`git diff --numstat` 各 +5/-2、+6/-3，删除行全为被修行（grep 断言行 + ok/bad 消息行）；断言总数不减（14/23）。改动仅限两目标脚本（其余 diff 文件为并行单元既有变更，未触碰）。
- 证据/完整记录：subagent-state/14b-executor.md。confidence: HIGH。

#### [sub:14c-executor] T-锚/TS-05 SKILL 索引锚扩 7x 纪元（Rule 72 落地级联，S14c）
- 承接：Round 3 回归 FAIL 原文——`selftest-skill-split.sh` T-锚报 `FAIL Rules 1-3..6 宽容计数锚 ≥1`（旧宽容正则 `Rules 1-(3[0-9]|[4-6][0-9])` 覆盖 1-30..1-69，未含 7x 纪元，SKILL.md 现状三处「1-72」=:9/:295/:380 → 0 命中）；`selftest-tool-selection.sh` TS-05 报 `FAIL SKILL.md 字面锚漂移（Critical Rules 1-69=0 应 ≥1 / 1-39=0 应 0）`（主锚钉值 `1-69` 命中 0 → 误报漂移）。
- 操作：① skill-split.sh:79 宽容计数锚正则追加 `7[0-2]` 分支（`Rules 1-(3[0-9]|[4-6][0-9]|7[0-2])`，覆盖 1-30..1-72），注释追加 v160 锚扩说明；② tool-selection.sh:63 主锚 `grep -c 'Critical Rules 1-69'` → `grep -cE 'Critical Rules 1-(6[0-9]|7[0-2])'`（覆盖 60-72 纪元），:65 ok/bad 消息串同步 `1-(60-72)`，负向检查 `1-39=0` 原样保留；判据方向不变、断言行数不减。
- 验收：`bash skills/task-planner/scripts/selftest-skill-split.sh` → `Total: 41 PASS=41 FAIL=0` EXIT=0（`T-锚 Rules 1-3..6 宽容计数锚 ≥1` PASS）；`bash skills/task-planner/scripts/selftest-tool-selection.sh` → `Total: 12 PASS=12 FAIL=0` EXIT=0（`TS-05 PASS ... Critical Rules 1-(60-72)≥1 且 1-39=0`）。宽容锚实测命中 2≥1；`1-39` 命中 0。`git diff --numstat` skill-split +3/-1、tool-selection +3/-2，删除行全为被修行（grep 断言行 + ok/bad 消息行）；断言总数不减（41/12）。
- 证据/完整记录：subagent-state/14c-executor.md。confidence: HIGH。

#### [sub:14d-executor] SR-07/RV-10 SKILL 索引锚漂移修复（Rule 72 落地级联，S14d）
- 承接：Round 3 回归 FAIL 原文——`selftest-self-resolution.sh` SR-07 报 `FAIL SKILL.md 字面锚漂移（Critical Rules 1-69=0 应 ≥1 / 1-39=0 应 0）`（主锚钉值 `1-69` 命中 0，SKILL.md 现状三处「1-72」=:9/:295/:380 → 误报漂移）；`selftest-reflect-verify.sh` RV-10 报 `FAIL SKILL.md 缺 'Rules 1-(3[5-9]|[4-6][0-9])' 宽容锚`（旧宽容正则覆盖 1-35..1-69，未含 7x 纪元 → 0 命中）。
- 操作：① selftest-self-resolution.sh:80 主锚 `grep -c 'Critical Rules 1-69'` → `grep -cE 'Critical Rules 1-(6[0-9]|7[0-2])'`（覆盖 60-72 纪元），:82 ok/bad 消息串同步 `1-(6[0-9]|7[0-2])`，负向检查 `1-39=0` 原样保留；② selftest-reflect-verify.sh:60 宽容正则追加 `|7[0-2]` 分支（`Rules 1-(3[5-9]|[4-6][0-9]|7[0-2])`，覆盖 1-35..1-72），ok/bad 消息串同步。两处均追加 v160 锚扩注释；判据方向不变、断言行数不减。
- 验收：`bash skills/task-planner/scripts/selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0` EXIT=0（SR-07 PASS）；`bash skills/task-planner/scripts/selftest-reflect-verify.sh` → `Total: 12 PASS=12 FAIL=0` EXIT=0（RV-10 PASS）。宽容锚实测命中 2≥1；`1-39` 命中 0。`git diff --numstat` self-resolution +3/-2、reflect-verify +2/-1，删除行全为被修行（grep 断言行 + ok/bad 消息行）；断言总数不减（13/12）。
- 证据/完整记录：subagent-state/14d-executor.md。confidence: HIGH。

#### [sub:ua-executor] 合并冲突并集解（SKILL.md + references/critical-rules.md，task-v160 Phase 8）
- 范围：worktree `wt/v160-decision-grading` merge master 冲突态，只解两文件（其余 11 个 UU 冲突文件、所有 scripts 未碰）；禁 git add/commit（遵守，仍处 UU 态）。
- SKILL.md 4 块并集：①:9 索引首句→`Critical Rules 全集 1-69+72（67-71 均经并行任务合流落地，72=决策分级与用户打断纪律）`，规则名列表取并集（master 66-70 + HEAD `、Rule 72…`）；②合规清单 master C49(Rule 67)/C50(Rule 71) 在前、HEAD C49 改号 C51 在后（三行列数一致）；③Critical Rules 首行→`（Critical Rules 1-72（含 Rule 40-71 全集 + Rule 72 决策分级与用户打断纪律））`；④References 行取 HEAD（=master 枚举+Rule 70(task-v155)+Rule 72(task-v160)，行首 1-72）。
- critical-rules.md 尾段 1 块并集：master 侧 Rule 71 块在前、HEAD 侧 Rule 72 块在后（70→71→72 升序）；`diff` 验证两节正文与各自源逐字节一致（Rule71 vs master=0、Rule72 vs HEAD=0，零丢失），仅移除冲突标记+节间补空行。
- 验收：`^<<<<<<<` SKILL=0/RULES=0 PASS；SKILL `1-69+72`=1、`Critical Rules 1-72（含 Rule 40-71 全集`=1、C49/C50/C51=1/1/1、Rule 72 bullet 在位 PASS；RULES `^## Rule 70`=1、`^## Rule 72`=1、`^### 72.[1-6]`=6 PASS；前缀宽容锚 `1-(69|71|72)（含 Rule 40-`=1 PASS。SA-01 PASS、DG-01 PASS。
- 偏差①（acceptance 第3项 FAIL）：`^## Rule 71`=0——master 原生形态为 `### 71 无源不写…`（v158），仓内硬锚强制：selftest-source-anchor-discipline.sh:27 SA-01 `grep -qF '### 71 无源不写'` + selftest-report-reviewability.sh:96 sed 分隔符 `/^### 71 无源不写/p`；归一为 `## Rule 71` 会同时打破两守卫，故按「正文一字不改」保持 `### 71`。
- 偏差②（范围外，需主进程级联）：SA-07（selftest-source-anchor-discipline.sh:39）断言 SKILL `grep -cF '1-71' ≥2`；并集按规格把 SKILL 索引三处（:9/:298/:385）迁至 1-72 → `1-71`=0 → SA-07 FAIL。非并集失误（HEAD 本身即 1-72 无 1-71；SA-07 由合并自 v158 引入），属 v160 1-72 迁移级联面遗漏（S10-S14 未含 SA-07）。建议修法=SA-07 `1-71`→`1-7[0-2]`（同 14a-d 范式）。
- 证据/完整记录：subagent-state/ua-executor.md。confidence: HIGH。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 72 而非扩写 Rule 41/44 | 41/44 是「消解/默认项」机制，72 是「分级」元规则；独立编号便于触点统一引用（72.5） |
| 编号顺延 v160（非 v156） | v156-drift-shield 已被并行会话占用（范围=漂移愤怒案例，不同族）；v157/158/159 同被占用 |
| 机器守护只增静态断言+warn | 对齐 v155 判例：exit 语义是交付门控承重墙 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| （暂无） | |

## Resources
- v155 归因材料：/mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/findings.md
- 规则预留账本：/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl（70 landed、71=v158 预留、**72 已 reserve 本任务**）
- 并行在途 worktree：v152/153/154/156/157/158/159（合并期预期 critical-rules.md/SKILL.md 尾段冲突，按 v149/v155 并集解判例）

## Visual/Browser Findings
- 无

## 第三条反馈立案材料（2026-10-10 用户反馈 — task-v161 立项依据，Rule 31 四维）
- **现象**：① 总结阶段让用户审查内容时，不把需要审查的内容列出来（连很多文件列表都不列）；② 列表/候选列表用「圈1、圈2、圈3」（①②③）混用数字列表，格式混乱令人头疼；③ 审查用的图片/文件没有专门列表（文件名/路径/描述表格）；④ 缺少运作详情+下一步指引。
- **实锤（用户提供）**：派发给子代理的提示词模板本身就含污染格式——`templates/subagent_dispatch.md` 的返回格式段示例为「① v3.1 23 段新配置摘要表…② style_exempt 统一口径…⑥ 待裁项。」（用户原话：「这就是问题的关键」）。
- **直接原因**：总结/派发模板无「格式可读性标准」（数字列表优先、禁圆圈枚举混用）+「审查清单实体化规格」（表格：文件名/路径/描述）+「派发模板格式源」未治理。
- **根因（5 Whys）**：①总结不可读 ← ②模板输出契约用① ② ③ 圆圈枚举承载结构化字段（返回格式段/输出合约/材料包清单）← ③模板设计时无格式规范条款（Rule 45 只管注释完整性不管展示格式）← ④Rule 70 只规定内容四要素未规定格式与清单实体化（v155 第二轮同类反馈）← ⑤格式规范从未作为独立规则域被审计。
- **类别**：规则覆盖缺口（展示格式规范）+载体污染（派发模板=格式源头）。修法=Rule 73（总结格式可读性纪律：数字列表优先/审查清单表格实体化/派发模板格式源修正）+templates 面修补+selftest 守护。

#### [sub:ub-executor] UB 单元：三脚本 merge 冲突并集解 + SA-07 级联修（2026-10-10）
- 经验判据（两侧正则对已并集 SKILL.md 实测 grep）：SKILL 实态 :9/:111=`1-69`、:298/:385=`Critical Rules 1-72（含 Rule 40-71 全集…`
- `selftest-research-first.sh` RF-06：两侧均命中（HEAD `1-6[0-9]`+`1-7[0-2]`=4；master `1-[67][0-9]`=4，均 ≥3）→ 取 master 侧 `cnt '1-[67][0-9]'` + 追加历史注释「[2026-10-10 task-v160 合并并集…]」。
- 同文件 RF-07：两侧字面均 0 命中（HEAD `Critical Rules 1-72（含 Rule 40-69 全集`=0；master `Critical Rules 1-71（含 Rule 40-(65|69|71) 全集`=0）→ 按规格扩 `cntE 'Critical Rules 1-(69|71|72)（含 Rule 40-'`，实测=1（SKILL.md:298 实态 `Critical Rules 1-72（含 Rule 40-71 全集`）→ PASS。
- `selftest-conclusion-discipline.sh` CD-11/12 块：两侧均命中（HEAD n35+n45+n70=0+3+2=5；master n35+n45=0+5=5，均 ≥3）→ 取 master 侧单锚 `1-[4-7][0-9]`，v160 n70 注释链保留为历史。
- SA-07 级联修（`selftest-source-anchor-discipline.sh:39`）：并集 SKILL 迁 1-72 后硬锚 `grep -cF '1-71'`=0 → 扩 `grep -cE '1-7[12]'`（实测=2），负向检查不动；SA-07 由 FAIL 转 PASS。
- 复跑：RF `Total: 12 PASS=12 FAIL=0` rc=0；CD `Total: 24 PASS=24 FAIL=0` rc=0；SA `Total: 12 pass, 0 fail` rc=0。三脚本 `^<<<<<<<`=0；diff 删除行全为被修行行；断言总数不减（RF 12/CD 24/SA 12）。未 git add/commit，未触碰其他 worktree/文件。证据：subagent-state/ub-executor.md。

#### [sub:uc-executor] UC 单元：EL-11/RV-10 两脚本 merge 冲突并集解（2026-10-10）
- 经验判据（两侧正则对已并集 SKILL.md 实测 grep）：SKILL.md:298=`Critical Rules 1-72（含 Rule 40-71 全集 + Rule 72 决策分级与用户打断纪律）`，含 `Rules 1-72`。
- `selftest-error-loop.sh` EL-11：两侧均命中（HEAD `Rules 1-(3[1-9]|[4-6][0-9]|7[0-2])`=HIT；master `Rules 1-(3[1-9]|[4-7][0-9])`=HIT，均命中 :298 `Rules 1-72`）→ 取 master 侧 + 追加 `# [2026-10-10 task-v160 合并并集: 保留演进记录，Rule 72 落地 1-72 纪元]`。
- `selftest-reflect-verify.sh` RV-10：两侧均命中（HEAD `Rules 1-(3[5-9]|[4-6][0-9]|7[0-2])`=HIT；master `Rules 1-(3[5-9]|[4-7][0-9])`=HIT）→ 取 master 侧 + 追加同 v160 历史注释行。
- 复跑：EL `Total: 16 PASS=16 FAIL=0` rc=0；RV `Total: 12 PASS=12 FAIL=0` rc=0。两脚本 `^<<<<<<<`=0；diff 删除行全为被修行行（HEAD 侧断言+冲突标记）；断言总数不减（EL 16/RV 12）。未 git add/commit，未触碰其他 worktree/文件。证据：subagent-state/uc-executor.md。

#### [sub:ud-executor] UD 单元：VT-10/skill-split T-锚 两脚本 merge 冲突并集解（2026-10-10）
- 经验判据（两侧正则对已并集 SKILL.md 实测 grep）：SKILL.md:298=`Critical Rules 1-72（含 Rule 40-71 全集 + Rule 72 决策分级与用户打断纪律）`，含 `Rules 1-72`。
- `selftest-veto.sh` VT-10：两侧均命中（HEAD `Rules 1-(3[1-9]|[4-6][0-9]|7[0-2])`=HIT；master `Rules 1-(3[1-9]|[4-7][0-9])`=HIT，均命中 `Rules 1-72`）→ 取 master 侧 + 追加 `# [2026-10-10 task-v160 合并并集: 保留演进记录，Rule 72 落地 1-72 纪元]`。
- `selftest-skill-split.sh` T-锚：两侧均命中（HEAD `Rules 1-(3[0-9]|[4-6][0-9]|7[0-2])`=HIT；master `Rules 1-(3[0-9]|[4-7][0-9])`=HIT）→ 取 master 侧 + 追加同 v160 历史注释行；T-主 行数钉 ≤555 未触碰。
- 复跑：VT `Total: 13 PASS=13 FAIL=0` rc=0；T `Total: 41 PASS=41 FAIL=0` rc=0。两脚本 `^<<<<<<<`=0；diff 删除行全为被修行行（HEAD 侧断言+冲突标记）；断言总数不减（VT 13/T 41）。未 git add/commit，未触碰其他 worktree/文件。证据：subagent-state/ud-executor.md。

#### [sub:ue-executor] UE 单元：RC-11/SR-07 两脚本 merge 冲突并集解（2026-10-10）
- 经验判据（两侧锚对已并集 SKILL.md 实测 grep）：并集 `Critical Rules 1-(6[0-9]|7[0-2])`=2（命中 `Critical Rules 1-72` :9/:295/:380）；master 字面 `1-71`=0、`1-69`=0（不命中）；负向 `1-39`=0。RC-11/SR-07 均「HEAD 宽容 HIT / master 字面 MISS」→ 取 HEAD 侧 + 追加 `# [2026-10-10 task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]`。
- 复跑：RC `Total: 23 PASS=23 FAIL=0` rc=0；SR `Total: 13 PASS=12 FAIL=1` rc=1。两脚本 `^<<<<<<<`=0；diff 删除行仅限冲突块（3 标记+master 侧内容），断言总数 RC=23/SR=13 不减。未 git add/commit，未触碰其他 worktree/文件。
- 遗留（范围外）：SR-12 FAIL 因 `scripts/selftest-registry.tsv` 仍冲突态（`^<<<<<<<`=1，76 行应 73），需 uf 单元并集解后 SR 方达 13/13。证据：subagent-state/ue-executor.md。

#### [sub:uf-executor] UF 单元：TS-05/LA-12 两脚本 merge 冲突并集解（2026-10-10）
- 经验判据（两侧锚对已并集 SKILL.md 实测 grep）：`grep -cE 'Critical Rules 1-(6[0-9]|7[0-2])'`=2（命中 :298/:385 的 `Critical Rules 1-72`）→ HEAD 宽容侧 HIT；master 字面 `grep -c 'Critical Rules 1-71'`=0（MISS，并集已迁 1-72）；负向 `grep -c '1-39'`=0。两侧非均命中 → 取 HEAD 侧 + 各追加 `# [2026-10-10 task-v160 合并并集: 取 v160 宽容锚，Rule 72 落地 1-72 纪元]`。
- 复跑：TS `Total: 12 PASS=12 FAIL=0` rc=0；LA `Total: 14 PASS=14 FAIL=0` rc=0。两脚本 `^<<<<<<<`=0；断言总数不减（TS 12/12、LA 14/14，stage2/stage3 亦各 12/14）；diff 删除仅 1 行（master 自动并集 doc-header `1-65`→`1-67`，非冲突块内断言行）。未 git add/commit，未触碰其他 worktree/文件。
- 遗留（范围外）：`skills/task-planner/scripts/selftest-registry.tsv` 仍 1 冲突标记（影响 SR-12，非本单元范围），待专责单元并集解。证据：subagent-state/uf-executor.md。

#### [sub:ug-executor] UG 单元：selftest-registry.tsv 合并冲突并集解（2026-10-10）
- 真实路径 = `skills/task-planner/scripts/selftest-registry.tsv`（相对 skill 根，非仓根 `scripts/`）。冲突态 76 行，标记在 71/73/76：HEAD 侧 = 本任务行 `selftest-decision-grading.sh`；master 侧 = `selftest-source-anchor-discipline.sh` + `selftest-pointer-lifecycle.sh`。
- 三数据行 tab 列数核验 `awk -F'\t' NF`=4（各 3 tab/4 列，符合契约）。解法=仅删三处冲突标记，三行全保留（stable 序：本任务行在前、master 两行在后；指令允许任意稳定序）。未 git add/commit，未触碰其他文件/worktree。
- 复跑：`^<<<<<<<|=|>>>` 类标记 grep=0；三脚本名各 grep=1；`selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=72, actual selftest=72)` rc=0；`selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0` rc=0，**SR-12 由 FAIL 转 PASS**（registry 总行数 73=脚本数+表头）。文件 76→73 行。证据：subagent-state/ug-executor.md。

#### [sub:uz-executor] UZ 单元：合并态两交叉 FAIL 机械修复（SKILL 清单恢复 + CP-07 锚扩 1-72）（2026-10-10）
- 真实路径 = worktree `/mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading`（非主仓）。
- 修复① `skills/task-planner/SKILL.md:298`「## Critical Rules」段首行恢复 UA 并集遗漏的规则名清单（回填 Rule 55/61/63/64/65 名目），锚仍为 `Critical Rules 1-72（含 Rule 40-`（RF-07 前缀宽容锚不断，grep=1）。
- 修复② `skills/task-planner/scripts/selftest-context-pressure.sh:99-101` CP-07 c2 正则 `Critical Rules 1-(69|71)` → `1-(69|71|72)`（v160 Rule 72 落地后索引 1-72），并补 v160 合并级联注释行。
- 基线→复跑：capability-persistence 20:19P/1F（CP-04 'Rule 55'=2<3）→ 20:20P/0F rc=0；context-pressure 9:8P/1F（CP-07 CR=0）→ 9:9P/0F rc=0。`bash -n` OK。
- 未 git add/commit；`git status --short` 仅两文件 M（+3/-2）。证据 subagent-state/uz-executor.md。
