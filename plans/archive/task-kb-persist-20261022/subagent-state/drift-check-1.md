# Drift Check 1 — task-kb-persist-20261022 Phase 1（偏移检查，只读+唯一检查点写入）

<!-- WHAT: 按指定读序（task_plan.md → progress.md → findings.md → user-session-log.md #1）对 Phase 1 做四检查项偏移核查
     WHY: 宪法 §四 防漂移 + 计划 Rule（Phase 状态/证据真实性与三方一致性）
     WHEN: 2026-10-22，Phase 1 commit 037c683 落地后
     范围: 只读检查 + 本检查点写入；未修改任何仓库文件
-->

## 判定结论

**⚠️ DRIFT**（4 项检查中 2 项实质通过、2 项存在偏离点；无阻塞项，非 🔴BLOCKED）

| 检查项 | 结论 | 摘要 |
|--------|------|------|
| 1 目标对齐 | ✅ 通过 | Phase 1 产出与用户原话 #1 的「持久化载体 + 快速查询入口」面一致；「不断累计沉淀」全量面属 Phase 2/3（按计划分解，尚未到期，非漂移） |
| 2 范围对齐 | ✅ 通过 | `git show --stat HEAD` 仅 7 个新增文件，全部落在 `knowledge/**` 与 `scripts/kb-*.sh`，零既有文件修改、零越界 |
| 3 进度真实性 | ⚠️ 部分偏离 | exit 0 与载体在位属实；但 V-1.2「无命中」证据当前不可原样复现（draft 条目已入库使 `test` 命中）；行数登记 84 与实际 90 不符 |
| 4 状态一致性 | ⚠️ 偏离 | task_plan.md=complete / verification.md=complete，但 progress.md=in_progress；S-unit 行仍 pending；Current Phase 与 Next Step 陈旧 |

---

## 检查项 1：目标对齐 ✅

- **Goal（task_plan.md:51）**：「为当前项目建成『知识沉淀→累计存留→快速查询』全链闭环」
- **用户原话（user-session-log.md #1）**：「我希望可以将当前项目的每次积累的知识库文件 不断累计沉淀 确保后期查询数据可以复用 核心思路就是将当前项目的知识体系的积累可以持久化……解决类似问题可以快速查询」
- **理解镜像（#1 理解镜像）**：三能力=①持续沉淀 ②累计持久 ③快速查询
- **Phase 1 实际产出（worktree commit 037c683，7 文件 391 行）**：
  - `scripts/kb-search.sh`(86l) 检索入口 → 用户原话「快速查询」
  - `scripts/kb-sync-from-plan.sh`(90l) 增量入库 → 用户原话「沉淀 / 每次积累的数据可以沉淀」
  - `scripts/kb-rebuild-index.sh`(60l) 索引派生 → 用户原话「累计存留 / 查询数据可复用」
  - `knowledge/{README.md,entry-template.md,INDEX.md,entries/}` → 用户原话「每次积累的知识库文件」的固定去处
- **判定**：Phase 1 = Goal 单元表 G1「载体与工具」的完整交付，与 R1/R2 的「持久化载体 + 查询入口」面直接对应，无目标切换、无范围曲解。
- **保留面（不判为漂移）**：Goal 全链闭环的「152 归档任务存量回填」与「后续任务入库闭环」分别属 Phase 2 / Phase 3（task_plan.md:185-214），当前 pending 属计划既定顺序，非越界或偷工。
- **Goal 单元表状态滞后**：G1 状态仍为 `pending`（task_plan.md:99），而 Phase 1 已 complete —— 属检查项 4 的簿记偏离，一并登记。

---

## 检查项 2：范围对齐 ✅

`git -C /home/terry/task-planner-skill-worktrees/kb-persist-20261022 show --stat HEAD`（commit 037c683）：

```
 knowledge/INDEX.md                    |  5 ++
 knowledge/README.md                   | 63 +++++
 knowledge/entries/_draft-task-v122.md | 47 ++++
 knowledge/entry-template.md           | 40 ++
 scripts/kb-rebuild-index.sh           | 60 +++
 scripts/kb-search.sh                  | 86 +++
 scripts/kb-sync-from-plan.sh          | 90 +++
 7 files changed, 391 insertions(+)
```

对照 task_plan.md「⚠️ 执行范围限制」表（task_plan.md:105-113）：

| 允许项 | 实际命中 | 判定 |
|--------|---------|------|
| 新增 `knowledge/`（README/entry-template/INDEX/entries/*.md） | 全部 4 类命中 | ✅ |
| 新增 `scripts/kb-{search,rebuild-index,sync-from-plan}.sh` | 3 个全部新增 | ✅ |
| 「修改 scripts/ 下任何既有文件」= 禁止 | 零既有 scripts 文件出现在 diff | ✅ |
| 禁区 `skills/**` 零触碰 / 既有文件零修改 | diff 内无 skills/、无任何 M/D 行（全为新增） | ✅ |

- 越界文件：**无**。
- `knowledge/entries/_draft-task-v122.md` 属 `knowledge/entries/*.md` 允许面（VC-3 的样例 draft 产物），非越界。
- worktree `git status --short` = 空（工作区干净、无游离改动）。
- 主仓 `knowledge/`、`scripts/kb-*` 尚不存在 → Phase 4 合并回前主仓无残留副本，符合分阶段预期。

---

## 检查项 3：进度真实性 ⚠️

### 3.1 可复现且属实

| 断言（progress.md Phase 1 Test Results） | 实测 | 判定 |
|-------------------------------------------|------|------|
| 载体在位：3 脚本 + README + template + INDEX + entries/ | `ls knowledge/ scripts/kb-*.sh` 全部在位 | ✅ PASS |
| 索引重建 exit 0 | `bash scripts/kb-rebuild-index.sh --dry-run` → 表头 + 计数 0，EXIT=0 | ✅ PASS |
| 无命中分支 exit 0 | `kb-search.sh zzz_no_such_keyword_xyz` → 「无命中: zzz_no_such_keyword_xyz」EXIT=0 | ✅ PASS |

### 3.2 偏离点 D-1：V-1.2「无命中: test」证据当前不可原样复现

- progress.md:31 记录 V-1.2 实际值「「无命中: test」exit 0」PASS。
- 实测 worktree 内 `bash scripts/kb-search.sh test` → **EXIT=0，但输出的是命中内容**（`knowledge/entries/_draft-task-v122.md` 内 5 处 `test` 字样 + selftest 相关条目共 5 行命中），并非「无命中」。
- **根因（非造假）**：kb-search.sh 检索范围为 `knowledge/` 下全部 .md（脚本第 30-33 行），而 Phase 1 冒烟过程中 `kb-sync-from-plan.sh` 对 `plans/archive/task-v122` 实弹生成了 `knowledge/entries/_draft-task-v122.md` 并已入库（progress.md Test Results 第 4 行、commit 037c683 均在案）。该 draft 正文含 selftest 文本 → 关键词 `test` 命中。V-1.2 跑「空库冒烟」时库内为空，故当时输出确为「无命中」；属**证据时效性问题**（检查口径写死在已变更的库状态上），非断言造假。
- **影响**：exit 0 的核心判定仍成立；仅 verification.md:53 的 V-1.2 复查命令（`bash scripts/kb-search.sh test`）在当前库状态下会输出命中而非「无命中」，终验复跑时若机械比对字符串会误判 FAIL。
- **建议修法（交主进程裁决，本次未执行）**：V-1.2 复查关键词改用不可能命中的串（如 `__v12_no_match__`），或把断言改写为「exit 0 且输出非错误」。

### 3.3 偏离点 D-2：脚本行数登记与实际不符

- progress.md:25 与 findings.md:29 登记 `kb-sync-from-plan.sh` = 84l（79l + 5l 修复）。
- 实测 `wc -l` = **90l**（git show --stat 亦为 90）。
- 其余五个产物行数登记准确（kb-search 86 / rebuild-index 60 / README 63 / entry-template 40 / draft 47）。
- 影响：低（仅簿记偏差），但属「进度真实性」项下的登记不准。

### 3.4 附带核对（均通过）

- `grep -L "^sources:" knowledge/entries/*.md` → 输出为空（唯一条目 draft frontmatter 含非空 sources）。
- `bash scripts/kb-rebuild-index.sh` 真实落盘 exit 0，INDEX.md 生成物与脚本注释一致（生成时间戳为 UTC）。
- `knowledge/entries/_draft-task-v122.md` 的 frontmatter `sources` 为仓相对路径（plans/archive/task-v122/...），符合 findings.md:30 记录的「主进程 5 行级修复」结论；正文标题行仍含 worktree 绝对路径（`/home/terry/task-planner-skill-worktrees/...`），合并回主仓后该行路径会失效但不影响 frontmatter 来源锚解析 —— 登记为遗留观察项，Phase 4 合并回时值得复核。

---

## 检查项 4：状态一致性 ⚠️

| 文件 | 位置 | 声明值 | 判定 |
|------|------|--------|------|
| task_plan.md | :175 Phase 1 | `complete` | 基准 |
| verification.md | :55 Phase 1 | `complete`（Last verified: 2026-10-22） | ✅ 一致 |
| progress.md | :14 Phase 1 | **`in_progress`** | ❌ 与上二者冲突 |

### 偏离点 D-3：progress.md Phase 1 状态未同步（Rule 19.2 相邻簿记冲突）

- progress.md 注释自称「Status 与 task_plan.md 同步(pending/in_progress/complete)」，实为 in_progress。
- 判定：以 task_plan.md + verification.md 双票 complete 为准，progress.md 为滞后项；**不是** Phase 1 未完成的证据（产物、测试、commit 三重证据齐备）。

### 偏离点 D-4：task_plan.md Phase 1 内部状态自相矛盾

- Phase 汇总行 `- **Status:** complete`（:175）与 S1/S2/S3/S4 四行状态列 `pending`（:180-183）并存。
- Goal 单元表 G1 仍 `pending`（:99），而 G1 明确映射 Phase 1。
- `## Current Phase` = `Phase 1`（:150-151）、`## Next Step` = 「创建 worktree → 并行派发 Phase 1 四个 S-unit → 主进程实弹冒烟」（:153-154）—— 三项均已被 commit 037c683 超越，属陈旧指针。

### 偏离点 D-5：verification.md 勾选框与 Status 不匹配

- Phase 1 的「Done when」三条与「Verification」V-1.1/V-1.2 两条复选框均为未勾选 `[ ]`（verification.md:47-53），而同节 Status 行写 `complete`。
- 全量 VC-1..VC-7 复选框亦全未勾（属正常：终验在 Phase 4）。

### 偏离点 D-6：Phase 2 预分组产物已落盘但 progress.md 无记录

- `plans/task-kb-persist-20261022/batch-{A..F}-sources.md`（6 份）+ `manifest.tsv` 已生成（mtime 05:01，晚于 Phase 1 commit 04:55），对应 task_plan.md:186「主进程机械预分组」。
- progress.md Phase 2 段仍是模板占位（`### Phase 2: [Title]` / Status: pending / Started 空 / 各字段 `-`，:37-46），未记录该预分组动作与 6 份清单产出。
- 影响：低（产物与计划一致，属下一 Phase 的正常起手），但触犯 progress.md「随做随记」纪律，且使 Phase 1→2 的交接点缺失可追溯记录。

### 偏离点 D-7：漂移登记表为空

- task_plan.md:285-288「🚨 Drift Log」表格为空行，未记录本次检查结论。
- findings.md:45-49「Issues Encountered」表亦为空行，而 Phase 1 实际发生过 gawk ERE 陷阱与 sources 绝对路径缺陷（两者仅记于 findings.md 子代理段与 progress.md Actions，未进 Issues 表）。

---

## 汇总：偏离点清单（均为簿记/口径级，无范围越界、无功能阻塞）

| # | 类型 | 描述 | 严重度 | 建议动作（本次未执行） |
|---|------|------|--------|-------------------|
| D-1 | 验证口径 | V-1.2 断言「无命中: test」在库非空后不可复现（exit 0 仍成立） | 中（终验误判风险） | 终验复查关键词改用不可能命中串，或改写断言口径 |
| D-2 | 登记不准 | kb-sync-from-plan.sh 行数登记 84l，实际 90l | 低 | 进度/发现文档更正行数 |
| D-3 | 状态冲突 | progress.md Phase 1 = in_progress，与 task_plan/verification 的 complete 冲突 | 中 | progress.md Phase 1 Status 改 complete |
| D-4 | 状态自矛盾 | task_plan.md S1-S4 行 pending、G1 pending、Current Phase/Next Step 陈旧 | 中 | 同步 S-unit 行状态、G1=complete、更新 Current Phase=Phase 2 与 Next Step |
| D-5 | 勾选不一致 | verification.md Phase 1 Done-when/V-1.1/V-1.2 复选框未勾但 Status=complete | 低 | 勾选已 PASS 项 |
| D-6 | 记录缺失 | Phase 2 预分组（6 份 batch 清单 + manifest.tsv）已落盘但 progress.md Phase 2 段未记录 | 低 | 回填 Phase 2 段 Actions/Files |
| D-7 | 登记表空 | task_plan.md Drift Log 与 findings.md Issues Encountered 均空行 | 低 | 登记本次检查结论 |

**遗留观察项（非偏离）**：`knowledge/entries/_draft-task-v122.md` 正文标题行含 worktree 绝对路径，Phase 4 合并回主仓后该行路径失效（frontmatter sources 为仓相对路径不受影响）。

**潜在风险预警（Phase 2 口径冲突，非本 Phase 偏离）**：VC-5 在 task_plan.md:77 的判据为 `grep -c '^| ' == entries 文件数 + 1`（含表头），而 verification.md:27 的判据为 `diff <(ls entries/*.md \| wc -l) <(grep -c '^| ' INDEX.md)`（不含表头）。两式不等价：当前 entries=1（含 1 个 _draft-，rebuild 脚本按 :22 跳过 draft 不计行）→ task_plan 式判据 = 1 vs 2 FAIL，verification 式判据 = 1 vs 1 PASS。Phase 2 回填后若 draft 未清理，两判据将给出相反结论。建议 Phase 2 前统一 VC-5 口径并明确 draft 是否计入 entries 基数。

---

## 证据锚

- 计划文档：`/mnt/data/dev/task-planner-skill/plans/task-kb-persist-20261022/{task_plan.md,progress.md,findings.md,verification.md,user-session-log.md,.plan-attestation,ledger-main.jsonl}`
- worktree：`/home/terry/task-planner-skill-worktrees/kb-persist-20261022`（分支 `wt/task-kb-persist-20261022`，HEAD `037c683`，status 干净）
- 计划哈希自校验：`sha256sum task_plan.md` = `50d5622982d82a9f7126fecd9ea6bfcedf9d220d7704d4f0beac88354a600a2e` = `.plan-attestation` 内 `plan_sha256` → 计划文件未被篡改
- 实测命令：`git show --stat HEAD` / `ls knowledge/ scripts/kb-*.sh` / `bash scripts/kb-search.sh test` / `bash scripts/kb-search.sh zzz_no_such_keyword_xyz` / `bash scripts/kb-rebuild-index.sh --dry-run` / `wc -l` / `grep -L "^sources:"`
