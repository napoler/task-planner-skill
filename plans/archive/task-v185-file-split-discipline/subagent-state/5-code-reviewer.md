# Code Review 报告 — task-v185 Rule 92 交付 diff（CR Gate 单轮）

## 元信息

- 审查对象：`/mnt/data/dev/task-planner-skill`（master），diff 范围 `16951ff..73ce9ec`（merge 73ce9ec，含 feat 282fd42）
- 规模：5 文件 +24/-11
- 计划：`plans/task-v185-file-split-discipline/task_plan.md`；用户原话：`plans/task-v185-file-split-discipline/user-session-log.md #1`
- 审查方式：只读（未修改任何文件）；回归面以实跑取证

## VERDICT: APPROVED

无 Blocker；六项 VC 全部满足（语义在位/级联 1-92/回归实跑绿）；2 项 🟡 建议属「计划已授权的只登记范畴」或「未断裂的范式滞后」，不阻断终验，建议用户/Verifier 裁决是否补强。

---

## 逐维度结论

### 1. 正确性 — 无发现

Rule 92 完整承载用户七点诉求（R1-R7）：
- R1/R2（尽量避免过大+优先拆分）→ 92.1「尽量避免单个文件过大…优先拆分为多个文件…『尽量避免』= 默认拆分+例外显式登记（92.6），不是禁止大文件」
- R3（代码按引用拆）→ 92.3「按模块/职责/引用关系切分」
- R4（其他文件同理）→ 92.4 非代码文件垂直拆分
- R5（垂直化拆分）→ 92.5「沿内聚边界垂直切」
- R6（减少负担）→ 建制段「大单文件的负担=读写定位慢、上下文注入与读取成本高、多会话编辑冲突面大、diff 审查困难、工具行数/字符上限易触顶」
- R7（产出/写入时）→ 92.1「任何任务的产出/写入动作…前」

与既有规则衔接正确、无冲突：
- 92.2 明确划清与 Rule 19.6 的管辖（「19.6 只管 task_plan.md 本身，本条管全部任务产出物」），口径同源不重叠。
- 92.5③ 引用 Rule 45（注释随逻辑迁移）；92.6 引用 Rule 88（射程）/87.4③（禁顺手拆），同面语义无矛盾。
- 92.1 与 92.6 自洽（总则「尽量避免」↔ 例外显式登记通道）。
- 92.5 禁止「≤10 行孤儿文件=过度拆分」与「优先拆分」不矛盾（拆分质量 vs 过度拆分，边界清晰）。

### 2. 级联完备性 — 1 项 🟡（计数行滞后，属只登记范畴）

5 文件编辑点一致、无错位：
- CA-1 `critical-rules-discipline.md`：Rule 92 全文追加于末尾（:577-588），未触碰既有 88-90 正文。
- CA-2 `task-discipline/SKILL.md`：清单+92（:24）、调用条件+「产出文件尺寸与拆分」（:26）、索引表+行 92（:68）。
- CA-3 `task-planner/SKILL.md`：1-91→1-92 共 3 处（:9/:179/:221）；两处 discipline 清单+92（:17/:166）。
- CA-4 `critical-rules.md`：task-discipline 路由行清单+92（:182）。
- CA-5 `README.md`：1-91→1-92 共 3 处（:36/:81/:123）。

旧字面零残留（`grep "1-91" SKILL.md README.md` = 0）；「其余 73 条」既有漂移合规保留未改（Decisions：只登记不修）。

### 3. 风格一致性 — 1 项 💬（机制条日期省略）

标题格式（`### NN 标题（P1 — task-vXXX，目标：…；判定面=…；衔接…，既有规则条目原文零改动）`）、建制段、子条结构、L0-T 机制条范式均与 Rule 88/89/90 对齐；编号 92 与 Rule 91（plan-collab-router `### 91 workflow 脚本内 per-subagent 模型分档纪律`，见 `critical-rules-collab.md:37`）无冲突，全局编号唯一。

### 4. 范围纪律 — 无发现

diff 严格限于 5 文件（+24/-11）；既有规则正文（88/89/90 及全部）零改动；仅索引/清单/编号字面与规则追加。

### 5. 回归面 — 1 项 🟡（selftest 锚未同步，未断裂）

实跑 `selftest-workflow-orchestration.sh`：22/22 PASS=0 FAIL，WF-10 PASS（cnt=4 ≥3），**回归无破坏**。但 diff 构成「潜在影响 selftest 断言」的形态，详见 🟡-1。

---

## 发现清单（按严重度）

### 🟡-1 [回归面/范式] `skills/task-planner/scripts/selftest-workflow-orchestration.sh:79` — WF-10 grep 锚未纳入 92，本 diff 使 cnt 余量 10→4

- 原文（:79）：`c="$(grep -cE 'Critical Rules 1-(68|69|71|75|91)' "$f" || true)"; c2="$(grep -cE '1-(68|69|71|75|91)' "$f" || true)"`
- 原因：本 diff 将 SKILL.md/README.md 的 `1-91` 全部改为 `1-92`，而 WF-10 锚 `1-(68|69|71|75|91)` 不匹配 `1-92`。实测技能文件对 WF-10 的贡献从 7（改动前 SKILLMD 3 + README 4）降到 1（改动后 SKILLMD 0 + README 1），cnt 从 10 降到 4；余量全靠仓根 `CLAUDE.md`（c2=1）/`README_zh.md`（c2=2）旧变体字面兜底（这俩文件不在本 diff 范围、未被触碰）。该脚本自身 8 次级联演进（v144→v183）注释均申明「锚同步扩族」，本次未同步，范式滞后；且兜底依赖仓根历史文档的旧纪元字面，若未来清理这些字面，WF-10 将断裂。
- 影响：断言未断裂（实跑绿，cnt=4≥3），VC-4 满足；但该断言已失去对 `1-92` 在位的验证能力，余量脆弱。
- 建议修法（非阻断，符合 CA-6「最小口径扩展」精神）：将 :79 两处 grep 模式 `1-(68|69|71|75|91)` 扩为 `1-(68|69|71|75|91|92)`（c 与 c2 两行），并在 :76 注释补一行 task-v185 演进注记。按计划纪律（CA-6 仅限「断裂锚」+ 只登记不修），本任务未改合规；此建议供用户/Verifier 裁决是否在终验前补强。
- 置信度：HIGH（实跑取证：改动前 cnt=10，改动后 cnt=4；SKILLMD 改动后 c2=0）

### 🟡-2 [级联完备性] `skills/task-discipline/SKILL.md:70,:81` — 加 92 后计数行滞后（属既有只登记漂移）

- 原文（:70）：`…已后补落盘——本索引现共 41 条全文可消费。`；原文（:81）：`` `references/critical-rules-discipline.md` — 42 条规则全文（含后补落盘的 Rule 85/86/87/88/89/90） ``
- 原因：新增 Rule 92 后，实际可消费规则数为 42（:70 口径应 41→42）/ 43（:81 口径应 42→43），但这两处计数行未随级联更新。属计划 Decisions 明确的「既有漂移只登记不修」范畴，CA 表未列这两行的修改，故 diff 未改**合规**；但计数行现已实际滞后。
- 建议修法：在既有漂移登记项（findings.md）中明确标注「加 92 后 :70 应 42 条、:81 应 43 条」，供后续任务统一处置；本 diff 无需改。
- 置信度：MEDIUM（滞后事实明确；是否属「必须修」取决于用户对只登记范畴的裁决）

### 💬-1 [风格] `skills/task-discipline/references/critical-rules-discipline.md:588` — 92.7 机制条省略裁决日期

- 原文（:588）：`**92.7 机制（文本优先 L0-T——对齐 86.7/89.6/90.6 范式）**`
- 原因：88.6/89.6 机制条含「2026-10-16 用户裁决」日期，90.6 与 92.7 均省略日期只写「对齐」。92.7 与 90.6 一致故可接受，但与 88.6/89.6 不完全统一。
- 建议修法：若要严格统一，可在 92.7 括号内补「2026-10-17 用户裁决」；属可选 Nit，不影响语义。
- 置信度：LOW

---

## 负结果声明

- 已检查：5 文件全量 diff、`critical-rules-discipline.md` Rule 92 全文及周边 88-90、`task-planner` 两文件索引面、`selftest-workflow-orchestration.sh` 全文（22 断言逐条实跑）、`selftest-registry.tsv` 登记、Rule 91 占用核查。
- 未发现安全/正确性 Blocker。
- 已排除：① `1-91` 旧字面残留（grep=0）；② 92 编号冲突（91=plan-collab-router workflow 分档，唯一）；③ 既有规则正文改动（diff 零改动 88-90）；④ 范围越界（严格 5 文件）；⑤ selftest 断裂（实跑 22/22 绿）。

## 验证协议

- 🟡-1：`bash skills/task-planner/scripts/selftest-workflow-orchestration.sh` → `Total: 22 PASS=22 FAIL=0`，WF-10 PASS cnt=4；改动前（`git show 16951ff:`）SKILLMD c2=3/README c2=4 → cnt=10；改动后 SKILLMD c2=0/README c2=1 → cnt=4。
- 🟡-2：`grep -n "41 条\|42 条" skills/task-discipline/SKILL.md` → :70「41 条」、:81「42 条」在位未改。
- 💬-1：`grep -n "92.7 机制" skills/task-discipline/references/critical-rules-discipline.md` → :588 无日期；对比 :551（88.6）/:563（89.6）含日期。
