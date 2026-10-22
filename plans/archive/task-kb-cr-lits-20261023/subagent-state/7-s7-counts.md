# S7 检查点：L-5 文档计数修正（task-kb-cr-lits-20261023 Phase 1 S-unit S7）

状态：DONE（2 文件已改，未 commit；CR 裁决项已登记，见「遗留/风险」）

## 一、实测命令与输出原文

抽查标题形态（决定口径）：各卫星/核心规则实体段落标题 = `### N 标题`（顶层），子条 = `### N.M 子条`（如 `### 70.1`，discipline 内 70/72 各带 6 个子条标题共 12 行 `### N.M`）。故「唯一规则编号」统计必须排除子条标题（`### 70.1` 不是一条新规则，是 Rule 70 的子条）。

实测命令 1 —— 卫星侧顶层规则标题计数（每文件）：
```bash
cd <worktree>/skills
for f in task-dispatch/references/critical-rules-dispatch.md \
         task-discipline/references/critical-rules-discipline.md \
         media-planner/references/critical-rules-media.md \
         plan-research-router/references/critical-rules-research.md \
         plan-template-kit/references/critical-rules-template.md \
         plan-collab-router/references/critical-rules-collab.md \
         plan-cost-guard/references/critical-rules-cost.md \
         plan-resume/references/critical-rules-resume.md \
         progress-tracker/references/critical-rules-progress.md \
         task-drift-guard/references/critical-rules-drift.md \
         verification-gate/references/critical-rules-verification.md; do
  n=$(grep -cE '^### [0-9]+([^0-9.])' "$f"); echo -n "$n "; done
# 输出：11 44 3 3 4 3 1 1 1 4 1  → 卫星侧合计 76
```

实测命令 2 —— 卫星侧唯一编号并集：
```bash
grep -hoE '^### [0-9]+([^0-9.])' <上述 11 卫星文件> | grep -oE '[0-9]+' | sort -n | uniq
# 输出（76 个，跨文件无重复编号）：
# 4 6 7 8 9 10 11 12 13 14 15 16 17 18 21 22 23 24 25 27 28 29 30 31 32 33 34 35 36 37 38 39 40
# 41 42 43 44 45 46 47 48 49 50 52 53 54 55 56 57 58 59 60 61 63 64 65 67 68 69 70 71 72 73 74 75 76
# 84 85 86 87 88 89 90 91 92 93
# 唯一总数（含核心）= 90；77/78/79 全仓（12 个 critical-rules*.md）无标题实体（账本确认 77/78/79 = abandoned）
```

实测命令 3 —— 核心侧（task-planner 本仓 critical-rules.md）：
```bash
grep -hoE '^### [0-9]+|^## Rule [0-9]+' task-planner/references/critical-rules.md | grep -oE '[0-9]+' | sort -n | uniq
# 输出（14 个）：1 2 3 5 19 20 26 51 62 66 80 81 82 83
# 其中 80 标题形态不同 = `## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）`（:139），其余 13 个为 `### N`
# 核心 14 条 = 任务括注口径（1,2,3,5,19,20,26,51,62,66,80,81,82,83）✓ 一致
```

交叉验证（README:69 卫星路由表 调用条件里的编号面）：
- task-dispatch 11 ✓ / task-discipline 36（表列 4,6,7,8,9,10,18,27,28,29,31-36,41-45,48,53-57,60,65,67,69-76）但 discipline 文件实测顶层 44 条 = 36 + 85,86,87,88,89,90,92,93（v183~v195 后续追加，路由表未同步列）
- 11+44+3+3+4+3+1+1+1+4+1 = 76 ✓ 与唯一并集 76 一致（无跨文件重号）

## 二、口径说明（为何 76 而非文档原 74，也非 CR 所记 76 的来源混淆）

- 文档原值 74：源自 2026-10-21 task-v195 注释「非核心 73→74 条」——该注释只把 Rule 93 一条 +1 进 73，漏记了此间实际在纪律域追加的 85/86/87/88/89/90/92 等已 land 规则（这些在 v183~v190 各自落地，ARCHITECTURE:121 注释写「卫星 73 条」为 10-19 快照口径，之后 10-21 只 bump 了 93，未做全量重测 → 累积漂移 74 与实测 76 差 2）。
- 实测口径 =「文档实际表述的指代面」：README「其余 N 条已按域迁至上表 11 卫星」指**卫星文件内实体段落（标题在位）的规则数**，非「全集 1-93 减核心 14」（后者 = 79 中 77/78/79 已废弃，得 76——两个口径恰好殊途同归 = 76，无歧义需双值登记）。
- 结论：卫星侧实体 = 76；核心 = 14；全集实体 = 90（Rules 标称 1-93，77/78/79 废弃缺号）。**改值 = 76**（实测），与 CR 遗留登记值 76 巧合一致，但依据是独立重测而非抄录。

## 三、改前/改后值

| 位置 | 改前 | 改后 |
|------|------|------|
| `skills/task-planner/README.md:81` | 「其余 74 条已按域迁至上表 11 卫星…」（其余文字逐字保留） | 「其余 76 条已按域迁至上表 11 卫星…<!-- [2026-10-23 task-kb-cr-lits-20261023 L-5 实测：卫星侧实体规则编号 dedup=76] -->」 |
| `skills/task-planner/docs/ARCHITECTURE.md:4` | 「…74 条非核心规则按域分层至 11 卫星技能…其余 74 条中纪律域含 85/…/93…」 | 「…76 条非核心规则…其余 76 条中纪律域含…」+ 实测注 `<!-- [2026-10-23 task-kb-cr-lits-20261023 L-5 实测：卫星侧实体规则编号 dedup=76，全集 14+76=90（77/78/79 已废弃不计）] -->` |

修改后自验（2026-10-23 S7 执行）：
- `git diff --stat -- skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md` → `2 files changed, 2 insertions(+), 2 deletions(-)`，diff 仅上述 2 行计数词变更，无其他行。
- 同 worktree 内另有 6 个文件 diff（check-delegation/check-scope/check-tier-consistency/selftest-requirement-coverage/task-plan-init.cjs/templates/task_plan.md）= 兄弟 S-unit（L-2/L-6/L-7/L-8）未 commit 的在途变更，非 S7 改动，S7 未触碰。

## 四、遗留/风险（需 CR/主控裁决，S7 不越权改动）

1. **同两文件内残留 74 口径（非 L-5 点名位置，S7 按范围约束未改）**：
   - `README.md:4`「74 条非核心规则按域分层至 11 卫星技能」（家族分层 v2.1 引言行）+ 其尾注释「非核心 73→74 条」（历史注释，属纪元记录，一般不动）
   - `README.md:127` 目录树「[critical-rules-discipline 等 74 条非核心规则 → 各卫星…]」
   - `ARCHITECTURE.md:115`「**其余 74 条**按域迁至上表 11 卫星（3 新域 50 条 + 7 收编 16 条 + 验证域 1 条 Rule 84；纪律域含 85-90/92/93，协同域含 91）」——其中括注拆分「3 新域 50 + 7 收编 16 + 验证域 1 = 67」也与其外层 74 自相矛盾（应为纪律域后续追加口径），建议 CR 一并裁决是否改 76 且重测拆分
   - `ARCHITECTURE.md:122`「卫星 73→74 条」（纪元演进史注释，历史记录性质，倾向保留原值 + 不溯改）
   - `ARCHITECTURE.md:136` 目录树「[74 条非核心规则 → …]」
   风险：只改 :81/:4 两处会造成同文件内 74 与 76 并存（新值旧值混排）。S7 任务书限定「约 :81 / 约 :4」两处，故越界处未动，上报 CR 裁决是否扩面。
2. **README:69 卫星路由表（task-discipline 行）调用条件编号列** 仍为 v195 前快照（36 条列），未含 85-90/92/93；同理 ARCHITECTURE.md:101 路由表行。非计数词，不属 L-5，未动，上报。
3. **核心文件行数注** README:81/ARCHITECTURE:114 写「references/critical-rules.md（193 行）」，实测 wc -l = 203 行（S7 期间在途 L-3 RC-28 自测等兄弟改动或含核心文件新增 51.13 所致）。非 L-5 范围，未动，上报。
4. 兄弟 S-unit 的 6 文件在途 diff 未 commit，合并合约（worktree 内 git status 干净）需主控在全部 S-unit 收口后统一处理。

## 五、执行证据

- 实测输出见 §一（命令 + 原文输出）
- 修改文件（S7 仅 2 个）：
  - `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023/skills/task-planner/README.md`（:81）
  - `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023/skills/task-planner/docs/ARCHITECTURE.md`（:4）
- 验证：`git diff --stat`（2 文件 +2/-2 行，仅计数词行）；grep 复核残留 74 见 §四

---

# S7 扩面轮（主进程裁决授权，L-5 口径同步射程）

## 扩面改值（6 处，仍限 2 文件，未 commit）

| 位置 | 改前 | 改后 | 依据 |
|------|------|------|------|
| README:4 引言行 | 「74 条非核心规则按域分层至 11 卫星技能」 | 「76 条非核心规则…」+ 扩面注 `<!-- [2026-10-23 … L-5 扩面：卫星侧实体规则 dedup=76（全集 14+76=90，77/78/79 废弃不计），引言行同步实测值] -->` | 实测 dedup=76 |
| README:81 行数注 | 「critical-rules.md（193 行，2026-10-19 task-v191 实测；…）」 | 「（203 行，2026-10-23 task-kb-cr-lits L-5 实测；task-v191 快照 193 行；…）」 | `wc -l` = 203（worktree 与 `git show 923aa54` 均 = 203，193 为 v191 历史快照值非 master 现值） |
| README:127 目录树 | 「[critical-rules-discipline 等 74 条非核心规则 → …]」 | 76 | 同上 |
| ARCHITECTURE:115 | 「**其余 74 条**按域迁至上表 11 卫星（3 新域 50 条 + 7 收编 16 条 + 验证域 1 条 Rule 84；纪律域含 85-90/92/93，协同域含 91）」 | 「**其余 76 条**…（3 新域 58 条 + 7 收编 17 条 + 验证域 1 条 Rule 84，合计 76；纪律域含 85/86/87/88/89/90/92/93 为 v171 后追加 8 条、协同域含 91 为追加 1 条）」+ 扩面注说明改法 | 括注拆分重核：50/16 为 v171 时点快照（50=dispatch 11+discipline 36+media 3；16=research 3+template 4+collab 2+cost 1+resume 1+progress 1+drift 4），后续追加 discipline 8 条（85-90/92/93，v183~v195）+ collab 1 条（91）→ 现值 58+17+1=76，50+16+1=67 与外层 74/76 均不自洽，按「改成与 76 自洽的表述」改法落地（未删括注，改写+注释注明） |
| ARCHITECTURE:114 行数注 | 「（193 行，含分层架构说明 + 卫星路由索引）」 | 「（203 行，2026-10-23 task-kb-cr-lits L-5 实测；task-v191 快照 193 行；…）」 | 同 README:81 |
| ARCHITECTURE:136 目录树 | 「[74 条非核心规则 → …]」 | 76 | 同上 |

## 扩面验证

- `git diff --stat -- skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md` → `README.md | 6 +++--- ；ARCHITECTURE.md | 8 ++++----`（累计两轮 = S7 全量：README 3 行变更、ARCHITECTURE 4 行变更，全部为计数词/括注/行数词面，无其他行）
- 残留扫描：两文件内正文「74 条」已全部清零；仅剩 :122 纪元注释「卫星 73→74 条」（按裁决 R3 保留历史演进记录）与 :4/README:4 尾部历史注释「非核心 73→74 条」（v195 纪元注，同属历史记录面，保留）；「193 行」仅剩两处新注内「task-v191 快照 193 行」的快照标注（有意保留，非残留）
- 兄弟 S-unit 6 文件 diff 未触碰（pathspec 限定复核）

## 不扩面（登记遗留，留 CR 裁决）

- README:69 与 ARCHITECTURE:101 卫星路由表 task-discipline 行调用条件编号列 = v195 前快照（36 条列 4,6,…,69-76），缺 85/86/87/88/89/90/92/93；同为 task-collab 行缺 91。独立缺陷族（路由表编号面同步），非 L-5 计数口径射程，未动
- （承首轮遗留 ①③④：纪元注释不改、兄弟未 commit diff 主控统一收口）
