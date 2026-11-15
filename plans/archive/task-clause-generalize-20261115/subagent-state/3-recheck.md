# 3-recheck — 独立第三方复检（双轮质检第二轮，Rule 103.3）

- 角色：critic（只读；禁改被检文件；无 git 写操作）
- 受检 commit：`2042fdc`（基点 `0ceda55`）
- worktree：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115`
- 时间：2026-11-15
- 判定：**8/8 PASS → APPROVED**（残留内容缺陷 R-1/R-2/R-3 另列，均需新授权方可修订）

---

## 0. 全局事实（先取）

```
$ git show --stat 2042fdc
 skills/task-discipline/references/critical-rules-discipline.md | 4 ++--
 skills/task-discipline/references/execution-recall-card.md     | 6 +++---
 skills/task-drift-guard/references/critical-rules-drift.md     | 4 ++--
 skills/task-planner/SKILL.md                                   | 2 +-
 skills/task-planner/references/critical-rules.md               | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

$ git status --short
（空输出）

$ git rev-parse --abbrev-ref HEAD
wt/task-clause-generalize-20261115
```

`git diff -U0 0ceda55..2042fdc -- skills/` 的变更行清单（严格 9 行，无附带行）：

```
critical-rules-discipline.md @@ -616 +616 @@   （94.5）
critical-rules-discipline.md @@ -618 +618 @@   （94.7）
execution-recall-card.md     @@ -7   +7   @@   （card A）
execution-recall-card.md     @@ -14  +14  @@   （card B）
execution-recall-card.md     @@ -41  +41  @@   （card E）
critical-rules-drift.md      @@ -63  +63  @@   （64.4）
critical-rules-drift.md      @@ -68  +68  @@   （64.7）
SKILL.md                     @@ -229 +229 @@   （Rule 51 bullet）
critical-rules.md            @@ -107 +107 @@   （51.14）
```

---

## 1. 15 授权项逐项落位（对照 clause-drafts-v2.md §0）

| # | 编号 | 落位 | 证据（grep -cF，`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115/` 下） | 结论 |
|---|---|---|---|---|
| 1 | G-1 | discipline:618 | `**豁免**：用户原话已显式覆盖该对象范围`=1；`禁自行推定 N`=1；`（95.4④ 同向）`=1 | PASS |
| 2 | G-6 | discipline:618 | `**判据单位**：②③ 的规模以用户指令给出的单位计`=1；`禁跨单位折算规避 ②`=1 | PASS |
| 3 | G-2 | discipline:618 | `跨对象生命周期/库存状态分区互跨`=1；`内容域 published/draft/trash/archive；代码域 merged/tag/branch/stash；文件域 active/backup/回收站；媒体域 已用/未用/废弃`=1；`判据=状态分区不同且用户指令未指明该分区`=1 | PASS |
| 4 | G-3 | discipline:618 | `全集级批量动作（审计/扫描/取证/重构/重制/重跑/批量替换）`=1 | PASS |
| 5 | G-4 | discipline:618 | `任何阶段性或成果性命名（战役/阶段/批次/Wave/Batch 等）`=1 | PASS |
| 6 | G-5 | discipline:618 | `94.6 判定面经本条扩展至 94.7`=1 | PASS |
| 7 | C-1 | core:107 | `L1 机械/统计级 ＜ L2 抽样级 ＜ L3 逐件语义处理级 ＜ L4 创作/改写级`=1；`内容 L1 正则/机械扫描/L2 抽样审读/L3 逐篇语义审读/L4 文字改写/优化`=1；`代码 L1 lint·grep/L2 抽样 review/L3 逐行审读/L4 重构修复`=1；`媒体 L1 参数校验/L2 抽帧目检/L3 逐帧审看/L4 剪辑重制`=1 | PASS |
| 8 | C-2 | core:107 | `单件成本下限÷K 时禁以该操作类型「完成」声称`=1；`K=并发执行体数，缺省 3`=1；`须在声称中写明 K 的依据`=1；旧 `下限÷3 时`=0 | PASS |
| 9 | C-5 | core:107 | `**适用面**：对外交付/终态完成/阶段成果上报；单文件 ≤3 行 trivial 修改的自述可一行式（操作类型+覆盖 1/1），免耗时项`=1 | PASS |
| 10 | D-1 | drift:68 | `最近含目标/指令类内容的条目号+一句话摘要（跳过寒暄/确认类条目；同号条目优先——与 51.3 双锚口径一致`=1 | PASS |
| 11 | D-2 | drift:68 | `**与 64.2.1 分工**：64.2.1 管零交集的判定与不可豁免（门控面），本条管检查点留痕字段与专档缺失处置（证据面）；同一事实由 64.2.1 定级、本条留痕，惩罚不双计`=1 | PASS |
| 12 | D-4 | drift:68 | `专档缺失且 plan 属 trivial 代码修复档（init-session.sh user-session-log 按需创建档）→ 检查点记`=1；`专档=未建档(tier)`=2；`按 64.1 未执行处置（64.2 门控拦截）并叠加 🔴BLOCKED 升级用户`=1 | PASS |
| 13 | C-7 | SKILL:229 + card:7/14/41 | SKILL：`完成声称须按 51.14 操作类型档位 L1-L4 + 覆盖实数 + 实测耗时（并发度 K 写明依据）自证，措辞不得高于实际档位（task-drift-fakeqc-20261115 判例锚）`=1；card A：`对外交付/阶段成果须补 51.14 操作类型档位 L1-L4、覆盖实数 N/总数与实测耗时（并发度 K 及依据）`=1；card B：`对象状态分区跨越/规模跳变 ≥10×/子集→全集级批量动作触发 94.7 停等复述与确认门`=1；card E：`检查点须记 64.7 用户原话对照面`=1 | PASS |
| 14 | D-3 | drift:63 两片段 | 片段1 `上述三锚外新增第四锚 ④ 用户原话对照锚`=1；片段2 `扩展为四锚后（含 ④ 用户原话对照锚）判定基线与 64.2.1/64.7 同步`=1 | PASS |
| 15 | G-7 | discipline:616 | `94.7 管范围静默扩张（对象状态分区跨越、规模跳变 ≥10×、子集→全集级批量动作三触发器）的判据与停等确认门`=1 | PASS |

合计 15/15 落位。

---

## 2. 既有锚零改动（94.6 / 51.13 / 64.6）

证据：`-U0` 最小 diff 中三行零出现（U0 无上下文行，出现=被改）。

```
$ git diff -U0 0ceda55..2042fdc -- skills/ | grep -cE '^-?\s*(\- \*\*)?(94\.6 |51\.13 |64\.6 )'
0
$ 逐串：git diff -U0 ... | grep -cF "94.6 机制"        → 0
$ 逐串：git diff -U0 ... | grep -cF "51.13 **机制"     → 0
$ 逐串：git diff -U0 ... | grep -cF "64.6 **零新 config" → 0
（完整 diff 中 "94.6 机制" 仅 1 次，为上下文行 `^ `，非增删）
```

当前行号：94.6=discipline:617（hunk 表现为 616、618 两行独立改动，617 未触）；51.13=core:106；64.6=drift:67。
五文件行数与基点完全一致（1:1 整行替换，无换行拆合）：754/53/69/282/206 均 base=head。

结论：**PASS**（锚行字面零改动）。

---

## 3. 三条款单行格式

```
$ grep -nE '^- \*\*(94\.7|51\.14|64\.7) ' <三文件>
critical-rules-discipline.md:618:- **94.7 对象状态分区与规模跳变确认门（范围静默扩张封堵 — task-drift-fakeqc-20261115 判例，L0-T 文本锚）**：
critical-rules.md:107:- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：
critical-rules-drift.md:68:- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：
```

三文件行数与基点相同（754/206/69），且每条款 `grep -c '^- \*\*<编号> '`=1 → 各为单物理行、行首结构 `- **<编号> <标题>**：` 保持。
结论：**PASS**。

---

## 4. 判例锚保留

```
$ grep -nF "task-drift-fakeqc-20261115 判例" <三文件>
critical-rules-discipline.md:616 618    （616=G-7 衔接句新句、618=94.7 本体）
critical-rules.md:107                   （51.14）
critical-rules-drift.md:68              （64.7）
```
三条款各含该字样（94.7 含标题+句尾两处；51.14/64.7 各标题+句尾）。结论：**PASS**。

---

## 5. 禁做项未引入

| 禁做项 | 证据 | 结论 |
|---|---|---|
| C-6 新增 selftest 断言/脚本 | `git show --stat` 仅 5 个 .md，无 `scripts/`；94.7 行 `selftest`=0、51.14 行 `selftest`=0（机制句保持 `机制=L0-T 文本锚。`=1，`94.6 同范式零脚本零新键`=1、`64.6 同范式零脚本零新键`=1） | PASS（未引入） |
| G-8 改指 8.1.1 | 94.7 行 `8.1.1`=0；`B 类扩范围（Rule 74）`=1（直挂保留） | PASS（未改） |
| D-5 措辞 | 64.7 行 `64.1 未执行同口径`=0；现存 `按 64.1 未执行处置（64.2 门控拦截）并叠加 🔴BLOCKED 升级用户`=1；🔴 计数=1（无新增前缀） | PASS（未改） |
| P3 格式前缀批量改动 | `-U0` 变更行清单恰为预期的 9 行；无其他 hunk；三条款行首结构不变；加号行中 `config.json|TASK_PLANNER_[A-Z_]+=` 命中=0 | PASS |

---

## 6. new ⊃ old 子串纪律（逐行 `case "$new" in *"$old"*)` 实测）

取 `git show 0ceda55:<file> | sed -n '<ln>p'` 为 old、工作树同行为 new：

```
critical-rules-discipline.md :616 oldlen=219  newlen=337  oldSubNew=YES   ← G-7（item 6 范围内）
critical-rules-discipline.md :618 oldlen=626  newlen=1008 oldSubNew=NO    ← 94.7 整行重写（item 6 不含）
execution-recall-card.md     :7   oldlen=81   newlen=182  oldSubNew=YES   ← card A
execution-recall-card.md     :14  oldlen=44   newlen=146  oldSubNew=YES   ← card B
execution-recall-card.md     :41  oldlen=58   newlen=222  oldSubNew=YES   ← card E
critical-rules-drift.md      :63  oldlen=415  newlen=669  整行=NO         ← 片段级见下
critical-rules-drift.md      :68  oldlen=440  newlen=730  oldSubNew=NO    ← 64.7 整行重写（item 6 不含）
SKILL.md                     :229 oldlen=115  newlen=213  oldSubNew=YES   ← C-7 bullet
critical-rules.md            :107 oldlen=584  newlen=904  oldSubNew=NO    ← 51.14 整行重写（item 6 不含）
```

64.4 按草案两片段做片段级验证（片段的 old 同时存在于基点行与新版行）：

```
64.4 frag1 oldSubNew=YES     frag1="drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：…③ scope 文件集锚（执行范围表路径）；"
64.4 frag2 oldSubNew=YES     frag2="无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。"
base frag1=YES  base frag2=YES（证明草案 old 抄录准确，替换非改写）
```

item 6 范围内的 6 处（card A/B/E + SKILL bullet + 94.5 整行 + 64.4 两片段）全部 YES。结论：**PASS**。

---

## 7. 越界检查

- `git show --stat 2042fdc` = 5 文件 9+/9-，与授权范围（三条款行 + 级联四点）一一对应，无第 6 文件。
- `git status --short` = 空（worktree 干净）。
- 分支 = `wt/task-clause-generalize-20261115`（非 main）。
- 无其他 hunk，即无「顺手改」其他规则/格式。
结论：**PASS**。

---

## 8. 语义一致性抽查（对 critic §三/§四 意图）

- 94.7 v2（discipline:618）
  - G-1 豁免线落在 ③ 之后、包装禁令之前（草案要求位）✓；保留「范围上限不可判定仍须停」兜底 ✓；指向 95.4④ ✓。
  - G-2 ①「对象生命周期/库存状态分区」+ 四域例举 + `列举可扩展` + `判据=状态分区不同且用户指令未指明该分区` ✓；`同站点/同产品不豁免——94.1 同域口径不适用本门` 保留（判例 coffeesploration）✓。
  - G-3 ③「子集→全集级批量动作（审计/扫描/取证/重构/重制/重跑/批量替换）」✓（并发型全集化已覆盖，对应 critic「③ 动词集特化」缺口）。
  - G-4 去战役：改为「任何阶段性或成果性命名（战役/阶段/批次/Wave/Batch 等）包装」，战役降为枚举示例 ✓。
  - G-6 判据单位（篇/条/文件/目录/资产/条记录）+ 未给单位须复述声明固定 + 禁跨单位折算 ✓。
  - G-5 机制句「94.6 同范式零脚本零新键；94.6 判定面经本条扩展至 94.7」✓（形态即 critic G-5 要求）；复述模板去单位特化 `现在把对象扩展为 Y（N）` ✓。
- 51.14 v2（core:107）：L1<L2<L3<L4 抽象档位 + 内容/代码/媒体三域映射（照表即可判定，code/media 从类比变明确）✓；「措辞档位不得高于实际档位」✓；`÷K`（K 依据必须写明：单执行体/派发 N 子代理/批量接口）✓（并行场景误报消除）；适用面 + ≤3 行 trivial 一行式豁免 ✓；51.3/51.8 分工句保留 ✓。
- 64.7 v2（drift:68）：取样口径「最近含目标/指令类内容的条目号（跳过寒暄/确认；同号优先，与 51.3 双锚口径一致）」✓；分工句（64.2.1 门控面 vs 本条证据面，惩罚不双计）✓；trivial 豁免 `专档=未建档(tier)` 不判 BLOCKED、在位但空/零条目→BLOCKED ✓。
- 64.4（drift:63）：四锚输入 + 专档未建档时显式记 tier + 与 64.2.1 分工（证据面）✓；片段2 四锚使基线同步说明 ✓。

结论：**PASS**（与 §三 G-1..G-6 / C-1/C-2/C-5 / D-1/D-2/D-4 意图一致；与 §四 G-7/D-3/C-7 落点一致）。

---

## 9. 发现的缺陷（不属 8 项清单判定面；均需新授权方可修订）

### R-1 🟡IMPORTANT `critical-rules-drift.md:68` — 非 trivial 档「专档缺失」从处置枚举中消失
- 原文：「专档缺失且 plan 属 trivial 代码修复档（…）→ 检查点记 `专档=未建档(tier)` 并按 64.1 留痕即可，不判 BLOCKED；专档在位但空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效」
- 推理：基点文本为「专档缺失/空/零条目…均 BLOCKED」；新版把「专档缺失」并入 trivial 分支，BLOCKED 分支只列「在位但空/零条目」「零交集」——**专档缺失且 plan 非 trivial 时无显式处置**，而同句判例叙事恰是「被投诉判例计划目录缺专档…trash 扩批被计划内任务项背书」（该判例 plan 非 trivial），self-consistency 断裂；判例原本要堵的入口被弱化，且与 D-2 分工句「本条管…专档缺失处置」的承诺不一致。
- 建议（后续授权）：BLOCKED 分支补「专档缺失且非 trivial 档」一类。
- 置信度：HIGH（纯文本可复现）

### R-2 🟡WARNING `critical-rules-drift.md:63` — 同句并存「必须内嵌三锚输入」与「四锚合计…缺任一即不完整」
- 原文：「必须内嵌三锚输入：① …③ …；上述三锚外新增第四锚 ④ …——四锚合计为「四锚输入」，缺任一即不完整」
- 推理：new⊃old 纪律使开头强制语保留在「三锚」，强制力句与后置结论互斥；派发侧若只读首句仍可合法只带三锚（D-3 想堵的通道仍在字面层留口）。
- 建议（后续授权）：开头改「必须内嵌四锚输入」或在「必须内嵌三锚输入」后即插「（本条扩展为四锚，见下）」。
- 置信度：MEDIUM

### R-3 💬NIT 三处小瑕
- `critical-rules-discipline.md:618`：94.7 标题与句尾各含一次 task-drift-fakeqc 判例锚（重复）；「条」与「条记录」在单位枚举中重复。
- `critical-rules.md:107`：域映射用 `/` 兼作层级分隔与档内并列（如 `L1 正则/机械扫描/L2 抽样审读`），靠 `L2` 标记才能唯一解析，存在误读面。
- `execution-recall-card.md:7`：card A 适用面写「对外交付/阶段成果」，漏 51.14 原文的「终态完成」，载体与本体枚举不完全同步。
- 置信度：HIGH（字面）/ 影响 LOW

---

## 10. 负结果报告（检查了但未发现问题）

- 检查 `scripts/` 全域：本 commit 零变更（无 C-6 越界）。
- 检查新增 config/env 键：加号行 `config.json|TASK_PLANNER_*=` 命中 0。
- 检查 emoji/严重度前缀：64.7 行 🔴 计数=1（仅原有 BLOCKED），无 P3 风格前缀改动。
- 检查行数与段落结构：五文件行数 base=head，无段落拆合/尾随空行变化。
- 检查 8.1.1 指针注入：94.7 行 `8.1.1`=0（G-8 未越界）。
- 检查「战役」残留面：仅出现在 94.7 禁令枚举与判例原话引用内（符合 G-4 意图），无包装用途残留。
- 检查 recall card 行数上限（≤120 行）：53 行，未破限。

## 11. 验证摘要

- 8 项清单：8/8 PASS
- 15 授权项：15/15 落位且有 grep 证据
- 缺陷：3 条（1 IMPORTANT / 1 WARNING / 1 NIT 合并条目），均为「草案带入 / 纪律权衡」残留，不属于落位偏差
- 总发现（含缺陷）12 项 / 已用 grep·diff·substr 复现 12 项 / 通过率 100%
- 总判定：**APPROVED（落位与授权边界合格；R-1 建议在下一轮修订中补 BLOCKED 分支）**
