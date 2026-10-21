# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:S1-executor]
- 结论：执行规范召回卡已落 worktree，内容=派发 brief「文件内容」逐字，未改一字（含 A-F 六节）。
- 证据：wc -l=51（≤120 ✓）；grep -c '^- '=35（≥20 ✓）；test -f EXISTS ✓；34 个规则编号全部在位。
- 安全网：brief 指定命令（精确 "Rule $n" 匹配）报 MISSING-71/84/31/64/86 五项；经复核均为检查器误报——该 5 项在卡内以复合锚出现（Rule 54.5/71、Rule 19.2/84.3、Rule 57/19.4/31.2、Rule 61/64.2、Rule 72/86），卡内无规则真缺失，未自行编造。
- 证据路径：file=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/skills/task-discipline/references/execution-recall-card.md；checkpoint=plans/task-v195-spec-recall/subagent-state/S1-executor.md

#### [sub:S2-executor]
- 状态：done。Rule 93 全文（93.0-93.5，6 锚）纯追加至 `critical-rules-discipline.md` 末尾（588→602 行，+3319B，恰好 1 空行分隔，既有 92 原文零改动）；`SKILL.md` :24 清单加 `,93`、:76 `43→44 条`、:87 `43→44 条`+`92/93` 三处计数同步。
- 证据：AC1 `grep -c "^93\."`=6；AC2 diff 删除行=0（14 insertions only）；AC3 `grep -c ",93"`=1、`grep -c "44 条"`=2；AC4 `git diff --name-only`=2 文件（SKILL.md + critical-rules-discipline.md）。
- 偏差：`git status --short` 第 3 条 `?? execution-recall-card.md`（4458B/09:48）为并行 S1 产物，非本 S-unit 触碰，故不删不改；`:15`「等共 43 条」不在 brief 三处范围内，未改（报告不修）。
- 产出：/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/skills/task-discipline/references/critical-rules-discipline.md；/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/skills/task-discipline/SKILL.md。checkpoint：/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S2-executor.md。

#### [sub:S4-executor]
- 状态：done。根文档纪元计数 1-92→1-93 级联：README_zh.md :136 与 :229 两处、CLAUDE.md :33 一处，均将字面 `Rules 1-92` 改为 `Rules 1-93`，并在该行既有最后一个演进注释后追加 `<!-- 2026-10-21 task-v195 演进 1-92→1-93（Rule 93 规范再召回落地，核心 14 条不变） -->`。:229 为表格行，注释置于既有注释后、行尾 ` |` 前，表格未破。
- 证据：S4A `grep -rn "Rules 1-92"`=0 → S4A-OK；S4B README=2/CLAUDE=1 → S4B-OK；S4C README=2/CLAUDE=1 → S4C-OK；本 S-unit numstat CLAUDE.md 1+/1-、README_zh.md 2+/2-。
- 偏差：S4D `git diff --name-only` 实测 4 文件（另含 skills/task-planner/SKILL.md、skills/task-planner/references/critical-rules.md），经核为同 worktree 其他 S-unit 产出，非本 S-unit 触碰；本 S-unit 严格只改 2 目标文件。历史注释 `1-91→1-92`（README=2/CLAUDE=1）等逐字保留。
- 产出：/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/README_zh.md；/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/CLAUDE.md。checkpoint：/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S4-executor.md。

#### [sub:S3-executor]
- 状态：done。task-planner SKILL.md 接线「3g 规范召回」步骤 + 恢复矩阵短语 + 纪元计数级联（7 处）+ 核心 critical-rules.md 路由行加 93（1 处）。
- 变更：SKILL.md 行 86 后插入 `3g 规范召回（Rule 93）` 条目（5 空格缩进逐字）；:141 决策矩阵 `中断/压缩恢复→读全部三文件（Rule 19.3）` 追加 `＋执行规范召回卡（Rule 93.3）`；:9/:17/:196/:209/:251 五处纪元计数与纪律域清单 `1-92→1-93`、`73→74 条`、`...90,92→...90,92,93`、`Rule 85/86/87/88/89/90/92→.../93`；critical-rules.md :184 task-discipline 路由行尾只加 `,93`。
- 证据：S3A `grep -c "3g 规范召回"`=1→OK；S3B `grep -c "execution-recall-card"`≥1→OK；S3C `grep -rn "Rules 1-92"`=0→OK；S3D `grep -c ",93"`≥1→OK；numstat 本 2 文件=SKILL 7+/6-、critical-rules 1+/1-。
- 偏差：`git diff --name-only` 实测 4 文件（另含 CLAUDE.md/README_zh.md），经核为并行 S4-executor 同 task-v195 产出（findings 已记），非本 S-unit 触碰；本 S-unit 严格只改 2 目标文件。历史演进注释 `1-91→1-92` 等逐字保留。
- 产出：/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/skills/task-planner/SKILL.md；/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall/skills/task-planner/references/critical-rules.md。checkpoint：/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S3-executor.md。

#### [sub:S6-verifier]
- 状态：done（独立上下文验收，Rule 33.3）。worktree 内全量回归 + VC-1..5 逐条复验。
- 回归（VC-6 证据）：改后 `Total: 92 PASS=92 FAIL=0`（run=92 reused=0），与基线 `Total: 92 PASS=92 FAIL=0` 逐项一致 → **FAIL 增量=0**（无真回归，无计数断言级联）。
- VC-1 PASS：卡 51 行（≤120）、`^- ` 条目 35（≥20）、A-F 六节齐（grep -c '^## [A-F]'=6）。
- VC-2 PASS：`^93.` 计数=6（≥6，93.0-93.5）；`git diff master -- critical-rules-discipline.md` 删除行=0、新增 7 行（纯追加）。注：master 已前进（见 blockers），但经 `git diff 42d72b4..master` 证实 master 未触碰该文件，故 master 基线等价于任务真基线，结论成立。
- VC-3 PASS：`grep -c "3g 规范召回"`=1、`grep -c "execution-recall-card"`=1（SKILL.md:87 同一行）。
- VC-4 PASS：权威面 `Rules 1-92` 残留=0（SKILL.md+references/+README_zh.md+CLAUDE.md）；critical-rules.md:184 路由行含 `,93`=1；README.md+ARCHITECTURE.md 历史叙述字面=2（ARCHITECTURE.md:4 的 task-v191 时点注释、:121 演进史条目，与口径注一致）。
- VC-5 PASS：templates/task_plan.md:312 含「规范召回」=1。
- blockers（重要，供 Phase 4 处置）：worktree 建于 master=42d72b4，其后 master 前进至 45eda8c（并入 s77-exec：0c9a408 改 skills/task-planner/SKILL.md 16+/18-，与任务 SKILL.md 改动同文件同区域）。`git merge-tree --write-tree HEAD master` 预览 = **CONFLICT (content) in skills/task-planner/SKILL.md**。→ Phase 4 合并回（VC-8）将遇内容冲突，须按 FMEA 兜底「冲突即 STOP 报告/并集解」，非本 S6 射程（只读验证，未做任何 git 写操作）。
- 证据路径：worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall；checkpoint=/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S6-verifier.md。
- verdict：PASS（VC-1..5 全 PASS + FAIL 增量=0），附 Phase 4 合并冲突风险预警。

#### [sub:S7-critic]
- 状态：done（只读审查，未修改任何仓内文件）。`git diff master`（419dfb3+a182b71）+ `git diff 42d72b4..HEAD`（本任务自身改动，排除 master 前进干扰）双基准；新文件 execution-recall-card.md 全文。
- verdict：**CHANGES_REQUESTED** — 计数级联不完整，4 处当前声明行漏改造成同文件自相矛盾。
- 逐项（7 清单）：① 既有条款零改动 **PASS**（discipline 14+/0-，hunk `@@ -586,3 +586,17 @@` 无删除行；README_zh/CLAUDE 四代历史注释 `1-69→1-71`…`1-91→1-92` 逐字保留）② 范围越界 **PASS**（`--name-only`=10 文件与 scope 表 CA-1..CA-9 完全一致，零多出）③ 召回卡 **PASS**（51 行≤120、`^- `35≥20、A-F 六节、抽验 20 条规则锚全对、无镜像）④ Rule 93 **PASS**（93.0-93.5 六锚、65 边界显式「互补不重复」、[recall] 可执行）⑤ SKILL 接线 **PASS**（3g 落 :87 紧邻 3f:86 同层、8 处计数级联全齐）⑥ 计数级联 **FAIL**（见 C-1/C-2）⑦ 模板召回行 **PASS**（:312 插点结构未破）。
- C-1 [IMPORTANT] `skills/task-discipline/SKILL.md:15`「…等共 **43 条**（全文见规则索引）」与同文件 :76/:87 的「**44 条**」自相矛盾；S2-executor 已报告「不在 brief 三处范围内，未改（报告不修）」=明知不一致留置；plan CA-3 枚举 `:24/:76/:87` 漏扫 :15。建议 :15→44 并补 CA 登记+重 attest。置信度 HIGH。
- C-2 [IMPORTANT] `skills/task-planner/README.md:127`「[critical-rules-discipline 等 **73 条**非核心规则 → …]」+ `docs/ARCHITECTURE.md:136`「[**73 条**非核心规则 → …]」与同文件 :81/:115 的「**74 条**」矛盾；CA-9 自述动作含「73→74」但枚举（README :36/:81/:123、ARCH :4/:13/:42/:113/:121）漏扫此两行；改前全 73 自洽，**本次改动引入不自洽**。建议两处→74 并补 CA 登记。置信度 HIGH。
- C-3 [NIT] `skills/task-planner/README.md:4`「家族分层 v2.1（2026-10-12 task-v171）…**73 条**非核心规则」与平行声明 ARCHITECTURE.md:4（已改 74）跨文件不一致；该行带版本号，是否属历史字面需裁决。置信度 MEDIUM。
- C-4 [QUESTION] `critical-rules-discipline.md:75`（93 头部）对 Rule 64 只写「衔接」未给互补结论（65 已显式给）；清单要求「65/64 边界是否说清」→ 64 属未说清。建议补一句对象差异结论。置信度 MEDIUM。
- 方法学纠正（防误判）：`git diff master` 呈现的「Phase 循环机械/智能双勾选重构」**非本任务改动**——基线 42d72b4 本就是双勾选，master 45eda8c（s77-exec 0c9a408「内联 [M]/[A] 小数点方案」）才是单勾选内联形态；`git diff 42d72b4..HEAD -- SKILL.md` 仅 5 hunk（:9/:17/:87-3g/:139/:194/:207/:249）无勾选结构改动。故清单第 1/2 项不据此判违规。
- 负结果：既有条款无删除行/无注释截断/召回卡无镜像/20 条规则锚无张冠李戴/selftest 宽松锚未被顶破（S6 回归 PASS=92 FAIL=0 独立印证）/模板字段区未破/无越界文件。
- 验证：总发现 4，Grep/Read 复现 4/4，通过率 100%。checkpoint=/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S7-critic.md。

#### [sub:S7b-critic-recheck]
- 状态：done（只读复核，未修改仓内任何文件）。worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall；复核对象=修复 commit 65ceed7。
- verdict：**APPROVED** — 4 处计数声明行级联补齐完成，全库计数自洽，修复未越界。
- 逐项复核：
  - C-1 **PASS**：`skills/task-discipline/SKILL.md:15`「…规范再召回等共 **44 条**（全文见规则索引）」；`grep -c "共 44 条"`=2（:15/:76），`grep -c "共 43 条"`=0（exit=1）。:76「本索引现共 44 条全文可消费」、:87「44 条规则全文」保持，全文件 44 自洽。
  - C-2 **PASS**：`skills/task-planner/README.md:127`「[critical-rules-discipline 等 **74 条**非核心规则 → …]」+ `docs/ARCHITECTURE.md:136`「[**74 条**非核心规则 → …]」；`grep -rn "73 条非核心\|等共 43 条" skills/` 零命中（exit=1）。
  - C-3 **PASS**：`README.md:4` 与 `ARCHITECTURE.md:4` 均「**74 条**非核心规则」；`grep -c "74 条非核心规则"` README=2 / ARCH=2。
- 修复 commit 核验：`git show --stat HEAD` = 3 files changed, 4 insertions(+), 4 deletions(-)（discipline/SKILL.md 1+/1-、README.md 2+/2-、ARCHITECTURE.md 1+/1-）；`git diff HEAD~1 HEAD --name-only` = 3 文件（与预期一致，零越界、零夹带）。
- 全局自洽抽验：`grep -rn "共 4[34] 条\|[73][4] 条非核心" skills/ | grep -v "共 19 条"` = 5 命中，逐行判读全为现行声明（README:4/:127、ARCH:4/:136、SKILL:15）且值均为 74/44；`grep -rn "73 条" skills/` 余命中仅两类——(a) README:4 与 ARCH:4 的 v191 历史演进注释「非核心 76→73 条」（dated 2026-10-19，其后 v195 注释已补正 73→74，属历史记录非现行声明）；(b) `selftest-registry.tsv:73`/`selftest-decision-drift.sh` 的「Rule 73」= 规则编号非计数；(c) `ARCHITECTURE.md:121` 位于「纪元演进史」changelog 内的 v191 历史条目（「核心 14 条 + 卫星 73 条，2026-10-19 task-v191 对齐」），紧随 :122 v195 条目（73→74），历史/现行分层清晰，不构成矛盾。→ 无新旧矛盾残留。
- 负结果：未发现修复引入新矛盾；未发现范围越界（--name-only=3 与 scope 一致）；未发现旧计数残留（「共 43 条」「73 条非核心」现行命中=0）；未发现注释截断或删除行（4+/4- 均为声明行替换）。
- 验证：复核项 3/3 PASS，新发现 0，Grep 复现 0/0（无新问题即无需复现）。checkpoint=/mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall/subagent-state/S7b-critic-recheck.md。
