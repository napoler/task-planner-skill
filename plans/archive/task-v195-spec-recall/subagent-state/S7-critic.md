# S7-critic — task-v195-spec-recall 全量 diff 挑刺审查（只读）

- 派发：Phase 3 / S7（critic 独立审查视角，Rule 33.3）
- 审查对象：worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall
- 审查基准：`git diff master`（419dfb3 + a182b71）+ 新文件 execution-recall-card.md 全文
- 辅助基准：`git diff 42d72b4 HEAD`（= 本任务自身改动，排除 master 前进带来的继承分歧）
- 判据来源：plans/task-v195-spec-recall/task_plan.md（CA-1..CA-9 + scope 表 + 审查清单 7 项）
- 结论：**CHANGES_REQUESTED** — 计数级联不完整，4 处当前声明行漏改造成同文件自相矛盾

---

## 关键方法学发现（影响归因，务必读）

`git diff master` 里呈现的「Phase 执行循环被重构为机械/智能双勾选」**不是本任务改的**：

| 形态 | 载体 |
|------|------|
| 双勾选（机械/智能分离） | 基线 42d72b4 **本来就是**这个形态；worktree 继承未动 |
| 单勾选+内联 [M]/[A] 小数点方案 | **master 45eda8c（s77-exec 0c9a408）**改成的——commit 标题即「Phase 执行循环顺序修复（内联 [M]/[A] 小数点方案）」 |

证据：`git diff 42d72b4 HEAD -- skills/task-planner/SKILL.md` 只含 5 个 hunk——:9 计数、:17 计数、:87 插入 3g、:139 矩阵短语、:194/:207/:249 计数——**无任何勾选结构/[M][A] 标签改动**。
=> 该重构出现于 `git diff master` 是因 master 前进，非本任务越界。审查清单第 1/2 项据此不判违规。

---

## 7 项审查清单逐条结论

| # | 清单项 | 结论 | 证据 |
|---|--------|------|------|
| 1 | 既有条款零改动 | **PASS** | discipline `git diff 42d72b4..HEAD --stat` = 14+/0-；hunk `@@ -586,3 +586,17 @@` 纯追加无删除行，92.5/92.6/92.7 上下文完整。README_zh/CLAUDE 历史注释 `1-91→1-92` 逐字保留，新注释追加于行尾 |
| 2 | 范围越界 | **PASS** | `git diff master --name-only` = 10 文件，与 scope 表 CA-1..CA-9 完全一致，零多出（untracked 均为 plans/ 他任务运行时文件，不在本 diff） |
| 3 | 召回卡质量 | **PASS** | 51 行 ≤120；`^- ` 35 条 ≥20；`grep -c '^## [A-F]'`=6；抽验 74.2/88/87/62.2/93 + 51.1/51.4/51.7/51.8/26.3/54/54.5/71/36/45/92/20.6/69.1/70.2/83 全部语义一致；无规则正文镜像 |
| 4 | Rule 93 条款质量 | **PASS（1 NIT）** | 93.0-93.5 六锚 `grep -c "^93\."`=6；93 头部明写 65 边界「其回顾对象为三文件状态，本条召回对象为技能规范文本，互补不重复」；[recall] 格式可执行 |
| 5 | SKILL.md 接线 | **PASS** | 3g 落 SKILL.md:87，紧邻 3f:86 且同为 5 空格缩进；措辞与 3a-3f 同构；8 处计数级联全齐（:9/:17/:141/:196/:210/+critical-rules.md:184/+3g） |
| 6 | 计数级联一致性 | **FAIL** | `Rules 1-92` 残留符合预期（ARCHITECTURE 2=:4/:121 历史字面、README 0）；但「当前声明行全部更新」未达成 → C-1/C-2 |
| 7 | 模板召回行 | **PASS** | templates/task_plan.md:312 插于 309-311 checklist 与 `**V-N:**` 之间，`- [ ]` 同构，模板结构未破 |

---

## 问题清单

### C-1 [IMPORTANT] 计数级联漏改 — discipline SKILL 同文件 43 vs 44 自相矛盾
- 位置：`skills/task-discipline/SKILL.md:15`
- 原文：「任务射程契约、前后逻辑一致性禁反言等**共 43 条**（全文见规则索引）」
- 同文件对照：`:76`「本索引现共 **44 条**全文可消费」、`:87`「**44 条**规则全文（…90/92/93）」
- 推理：Rule 93 落地后索引 43→44，:76/:87 已级联而 :15 漏改；同一 SKILL 内三个计数互相打架。**S2-executor 已显式报告此行**（findings「`:15`『等共 43 条』不在 brief 三处范围内，未改（报告不修）」）——属明知不一致仍留置。plan CA-3 枚举 `:24/:76/:87` 漏扫 :15。
- 建议：:15 「共 43 条」→「共 44 条」；按 Rule 74.3 在 CA 表补登记该行（scope 追加 + 重 attest）。
- 置信度：HIGH

### C-2 [IMPORTANT] 计数级联漏改 — README/ARCHITECTURE 目录树 73 vs 74 自相矛盾
- 位置：`skills/task-planner/README.md:127`、`skills/task-planner/docs/ARCHITECTURE.md:136`
- 原文 README:127：「│   └── [critical-rules-discipline 等 **73 条**非核心规则 → 各卫星 references/critical-rules-*.md]」
- 原文 ARCHITECTURE:136：「│   └── [**73 条**非核心规则 → 各卫星 references/critical-rules-*.md（见 §3 路由表）]」
- 同文件对照：README:81 已改「其余 **74 条**已按域迁至上表 11 卫星（2026-10-21 task-v195…）」；ARCHITECTURE:4「**74 条**非核心规则」、:115「**其余 74 条**按域迁至上表 11 卫星」
- 推理：本任务把同族声明行改成 74，却漏掉这两行目录树注，形成同文件 73/74 打架；且 CA-9 自述执行动作为「当前声明行 1-92→1-93+**73→74**+清单加 93」——即 plan 自身意图含 73→74，枚举（README 仅 :36/:81/:123、ARCHITECTURE 仅 :4/:13/:42/:113/:121）漏扫。改前全部是 73（自洽），**是本次改动引入了不自洽**。
- 建议：两处 `73 条` → `74 条`；补 CA-9 枚举行并重 attest。
- 置信度：HIGH

### C-3 [NIT] README:4 家族分层主声明 73 条 vs 平行声明 ARCHITECTURE:4 74 条
- 位置：`skills/task-planner/README.md:4`
- 原文：「**家族分层 v2.1（2026-10-12 task-v171）**：…**73 条**非核心规则按域分层至 11 卫星技能…」
- 推理：与 ARCHITECTURE.md:4（同一「家族分层」声明，已改 74）跨文件处理不一致；README 侧 :81 已 74 而 :4 仍 73。该行带版本号 `v2.1（2026-10-12）`，是否视作历史字面需主进程裁决。
- 建议：裁决为当前声明则改 74（与 ARCHITECTURE:4 对齐）；裁决为版本快照则保持不动并在 CA 表登记理由。
- 置信度：MEDIUM（语义归类需裁决）

### C-4 [QUESTION] Rule 93 对 Rule 64 的边界只写「衔接」、未给互补结论
- 位置：`skills/task-discipline/references/critical-rules-discipline.md:75`（93 头部）
- 原文：「衔接 Rule 19.3（恢复读序）/29（上下文卫生）/61/64（偏移节奏）/65（周期回顾——**其回顾对象为三文件状态，本条召回对象为技能规范文本，互补不重复**）/67…」
- 推理：审查清单要求「与 Rule 65/64 的边界是否说清（互补不重复）」；65 已显式给「互补不重复」结论，64 只被列为「衔接」+一个短标签，未像 65 那样点明对象差异（64.3=工具调用次数驱动的漂移节奏、93.2=S-unit 计数驱动的规范文本召回）。语义上确不冲突，但按本清单字面属「64 边界未说清」。
- 建议：93 头部给 64 补一句对象差异结论（如「64 管漂移检查节奏，本条管规范文本召回节奏，对象正交」）。
- 置信度：MEDIUM

---

## Blocker / Phase 4 交接（非本任务改动，但会挡合并）

`git merge-tree --write-tree HEAD master` = **CONFLICT (content) in skills/task-planner/SKILL.md**（S6-verifier 已预警）。根因：
- worktree 基线 42d72b4 的 Phase 循环 = **双勾选（机械/智能分离）**
- master 45eda8c（s77-exec 0c9a408「Phase 执行循环顺序修复（内联 [M]/[A] 小数点方案）」）= **单勾选 + 内联 [M]/[A] + 交错顺序**

=> 合并解冲突时**必须保留 master 的顺序修复**（2.5x 委派步骤须回到 step 3 执行之前），只把 3g 一行插到 3f 之后；若直接取 worktree 侧会**回退 s77-exec 刚做的顺序修复**。3g 插入点在两种形态下都位于 step 3 子条 3f 之后，兼容可插。

---

## 负结果报告（检查了但未发现问题的面）

- critical-rules-discipline.md 既有条款：hunk 上下文与 numstat 双向核验，**无任何删除/改写行**，92.x 全部逐字保留
- README_zh/CLAUDE 历史演进注释：`1-69→1-71`、`1-72→1-75`、`1-75→1-83`、`1-91→1-92` 四代注释逐字保留，仅尾部追加新注释——未发现注释被截断/重写
- 召回卡引用的 34 个规则编号：抽验 20 个（含清单要求的 74.2/88/87/62.2/93）语义全部对得上，未发现张冠李戴
- 召回卡正文镜像：逐行读完，最长行=一行蒸馏，**无规则段落级复制**
- 自包含兜底：抽查 selftest 对 Phase 循环/计数的锚（selftest-drift-check-subagent DCS-03、selftest-periodic-review PR-10、selftest-workflow-orchestration L78），均为宽松锚或注释承载，未发现本次改动会顶破的自包含断言；S6 回归 PASS=92 FAIL=0 亦独立印证
- 模板结构：召回行插点上下（309-311 与 `**V-N:**`/`**Status:**`/`**Executor:**`）核验，未破坏字段区
- 越界可能性：`git diff --name-only` 与 scope 表逐行比对，无一处多余文件；无未跟踪新文件混入

---

## 验证协议自检

- 总发现 4（C-1/C-2/C-3/C-4）
- 已用 Grep/Read 复现原文 4/4
- 通过率 100%
