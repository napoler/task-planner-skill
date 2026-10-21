# S5-explore — task-planner-skill「部署与簿记面」健康度审计（只读）

- 审计对象：`/mnt/data/dev/task-planner-skill`（canonical 主仓）
- 审计范围：plans/ 簿记面 · Rule 编号账本 · 4 个部署位同步面 · 形态健康（Rule 81 / 20.6 / 18）
- 审计时点：主仓 HEAD = `2448e01`（2026-10-21 21:27:54 +0800）
- 执行纪律：全程只读（唯一写入 = 本检查点文件）；无任何 git 写操作（未 checkout/stash/clean/commit）；未触碰 `/home/terry/videop1` 等他仓；grep/find 均排除 `.backup`
- 滞后度量方法（部署位专用）：把部署位文件内容做 blob 哈希，与主仓 `git log -- skills/task-planner` 的历史提交逐一比对 → 取**最新命中**的主仓提交 → 落后数 = `git rev-list --count <commit>..HEAD`

---

## 0. 对既有线索的复核结果（含修正）

| 线索 | 复核结论 | 证据 |
|------|---------|------|
| plans/ 根 23 个在途目录 | ✅ 成立 | `ls -1d plans/*/` = 24（含 `archive/` 本身）→ 在途 23 |
| 7 个无 task_plan.md | ✅ 成立 | 见 B-05；含 `plans/task-v183/`（**完全空目录**） |
| 3 个有计划但无 Status 行 | ✅ 成立 | 见 B-06 |
| plans/archive/ 下 151 个归档目录 | ✅ 成立 | `ls -1d plans/archive/*/` = 151；其中 150 个有 task_plan.md |
| INDEX.md 仅 46 行 / **14** 条数据行 | ⚠️ **修正为 15 条** | `plans/INDEX.md` 共 46 行 ✅；数据行 = :10–:24 共 **15** 行（`grep -c '^|'` = 17 = 1 表头 + 1 分隔 + 15 数据行） |
| 4 个部署位全部落后 19~59 提交 | ⚠️ **实测为 19~74**（按文件），按部署位取最小值 19 / 47 / 47 / 47 | 见 B-13（度量方法已声明） |
| 现行加载位 /home/terry/.zcode 落后 19 提交 | ✅ 成立 | SKILL.md 命中主仓 `0c9a408`（2026-10-21 10:04）→ `rev-list --count` = **19** |
| .zcode 缺 Rule 93 规范召回 | ✅ 成立且**范围更大** | `grep -rl 'Rule 93' /home/terry/.zcode/skills/task-planner` = **0 命中**；且**整个 task-discipline 卫星**也 0 命中；召回卡文件 `execution-recall-card.md` 缺失 |
| 在途未部署：SKILL.md、critical-rules.md 新增 51.9–51.13、selftest-requirement-coverage.sh 新增断言 | ✅ 成立，且**系未提交工作区改动**（非已提交未部署） | `git status --short` → 4 个 `M` 文件；`git diff --stat` = 4 files, 69 insertions(+), 5 deletions(-) |

---

## 1. plans/ 簿记面

### 1.1 在途目录全量清单（23 个）

判定口径：`TP`=有 task_plan.md；`Status 行`=形如 `- **Status:** xxx` 的列表锚行数（archive-plan.sh:128 同口径）；`complete`=剥括号注记后以整词 complete 开头。

| # | 目录 | task_plan.md | Status 行 / complete | 状态机 | 最后修改 | 判定 |
|---|------|--------------|----------------------|--------|-----------|------|
| 1 | `cost-analysis-2026-10-05` | ✗ | — | — | 2026-10-05 15:47 | 无计划（4 份 md 报告） |
| 2 | `incident-reports` | ✗ | — | — | 2026-10-05 07:58 | 无计划（2 份 md） |
| 3 | `perf-diagnosis-2026-10-12` | ✗ | — | — | 2026-10-13 03:04 | 无计划（report.md） |
| 4 | `s77-p2-fix` | ✓ | 4 / 4 | 全 complete | 2026-10-21 10:13 | **应归档未归档** |
| 5 | `skill-audit-20261019` | ✗ | — | — | 2026-10-19 01:07 | 无计划（diagnostic-report + subagent-state） |
| 6 | `skill-audit-s77-20261019` | ✓ | 4 / 4 | 全 complete | 2026-10-20 02:45 | **应归档未归档** |
| 7 | `skill-audit-s77-fix-20261019` | ✓ | 5 / 5 | 全 complete | 2026-10-20 04:26 | **应归档未归档** |
| 8 | `task-defect-rrv13-dg12-false-pass` | ✓ | **0 / 0** | **无 Status 行** | 2026-10-21 11:28 | 状态机缺失（40 行 plan） |
| 9 | `task-P01-evidence-anchor` | ✓ | 3 行（in_progress + 2×pending） | 在途 | 2026-10-21 10:36 | 正常在途 |
| 10 | `task-skill-audit-20261021` | ✓ | 3 行（全 pending） | 在途·**当前 active** | 2026-10-22 01:17 | 在途，但 **INDEX 缺行** |
| 11 | `task-v180-scope-contract` | ✓ | 1 / 1 | 全 complete | 2026-10-21 10:36 | **应归档未归档** |
| 12 | `task-v181` | ✓ | 1 / 1 | 全 complete | 2026-10-21 10:36 | **应归档未归档** |
| 13 | `task-v183` | ✗ | — | — | 2026-10-21 10:36 | **空目录** |
| 14 | `task-v183-verif-closeout` | ✓ | 5 / 5 | 全 complete | 2026-10-21 10:36 | **应归档未归档** |
| 15 | `task-v184-proactive-error-review` | ✓ | 5 / 5 | 全 complete | 2026-10-21 10:36 | **应归档未归档** |
| 16 | `task-v187-workflow-activation-parallel` | ✓ | 4 / 4 | 全 complete | 2026-10-21 10:36 | **应归档未归档** |
| 17 | `task-v188-skill-audit-fix` | ✓ | 3 行（in_progress + 2×pending） | 在途 | 2026-10-21 10:36 | 正常在途 |
| 18 | `task-v189-skill-audit-deferred-fix` | ✓ | 3 行（in_progress + 2×pending） | 在途 | 2026-10-21 10:36 | 正常在途 |
| 19 | `task-v190-skill-audit-legacy-fix` | ✓ | 3 行（in_progress + 2×pending） | 在途 | 2026-10-21 10:36 | 正常在途 |
| 20 | `task-v191-project-audit-sync` | ✗ | — | — | 2026-10-21 10:36 | 无计划（delivery-summary + subagent-state） |
| 21 | `task-v192-deploy-zcode` | ✓ | **0 / 0** | **无 Status 行** | 2026-10-21 10:36 | 状态机缺失（37 行 plan） |
| 22 | `task-v193-skill-goal-drift-fix` | ✓ | **0 / 0** | **无 Status 行** | 2026-10-21 11:26 | 状态机缺失（55 行 plan） |
| 23 | `verification-upgrade-2026-10-16` | ✗ | — | — | 2026-10-16 13:26 | 无计划（report.md） |

**汇总**：有 task_plan.md = 16；无 task_plan.md = 7；Status 全 complete = 8；Status 缺失 = 3；在途正常 = 5。

### 1.2 plans/INDEX.md 结构盘点

- 总行数 46（`wc -l plans/INDEX.md` = 46）
- 结构：`:1` 标题 / `:2-3` 自动生成声明 + `Last refreshed: 2026-10-21_14:11` / `:5-6` 恢复指引 / `:8` 表头 / `:9` 分隔行 / `:10-24` **数据行 15 条** / `:26-33` 「待处理」7 条 / `:35-43` 「已完成」8 条 / `:45-46` 汇总
- 覆盖目录：15 个 id = s77-p2-fix、skill-audit-s77-20261019、skill-audit-s77-fix-20261019、task-defect-rrv13-dg12-false-pass、task-P01-evidence-anchor、task-v180-scope-contract、task-v181、task-v183-verif-closeout、task-v184-proactive-error-review、task-v187-workflow-activation-parallel、task-v188-skill-audit-fix、task-v189-skill-audit-deferred-fix、task-v190-skill-audit-legacy-fix、task-v192-deploy-zcode、task-v193-skill-goal-drift-fix

### 1.3 双向差集

| 方向 | 集合差 | 说明 |
|------|--------|------|
| INDEX 有 / 磁盘无 | **∅（空）** | 15 个 id 全部在磁盘存在 |
| 磁盘有 / INDEX 无 | **{task-skill-audit-20261021}** | 磁盘 16 个有 task_plan.md 的在途目录，INDEX 只列 15 |
| 磁盘有（无 task_plan.md，不进 INDEX 属设计内） | cost-analysis-2026-10-05、incident-reports、perf-diagnosis-2026-10-12、skill-audit-20261019、task-v183、task-v191-project-audit-sync、verification-upgrade-2026-10-16 | 7 个 |

### 1.4 archive/ 计数与形态

- 151 个归档目录；150 个有 task_plan.md，1 个（`task-planner-skill-review`）无 task_plan.md
- 1 个归档计划 Status 非全 complete：`plans/archive/task-v069-context-hygiene/task_plan.md` — Status 行 8 条（5 complete + **3 pending**：`:180`、`:218`、`:238`）
- 「Status 全 complete 但仍留 plans/ 根」的应归档未归档清单 = **8 个**（见 1.1 表「应归档未归档」行）：s77-p2-fix、skill-audit-s77-20261019、skill-audit-s77-fix-20261019、task-v180-scope-contract、task-v181、task-v183-verif-closeout、task-v184-proactive-error-review、task-v187-workflow-activation-parallel
  - 守卫放行测算（archive-plan.sh:94-147 三类拒绝 + Phase 覆盖校验）：这 8 个全部满足 `Phase 数 == Status 行数 == complete 数`（逐个实测：4/4、4/4、5/5、1/1、1/1、5/5、5/5、4/4）→ **7 个当前即可归档**（.session-owner mtime 均 >24h 或不存在）；**s77-p2-fix 被拦**，其 `.session-owner` mtime = 2026-10-21 06:07:51（审计时点 2026-10-22 ≈02:00，仍在 24h TTL 内）

---

## 2. Rule 编号账本

### 2.1 账本结构

`plans/.rule-reservations.jsonl` = **81 行**，全部为合法 JSON（0 解析错误）。状态词分布：`reserved` 40 / `landed` 36 / `abandoned` 4 / `contested` 1。编号覆盖 46–93 区间中 **45 个编号**；**缺 56、76、83 三号**（76 已被 `reserved`+`landed` 覆盖；**56 与 83 完全无任何行**）。

### 2.2 正文交叉核对结果

正文命中面 = `skills/task-planner/references/critical-rules.md` + `skills/*/references/critical-rules-*.md` 的规则标题行（102 个标题，顶级编号 76 个：1–76 + 80–93）。

| 类别 | 编号 | 正文位置（file:line） | 账本行（.rule-reservations.jsonl:line） | 结论 |
|------|------|----------------------|-------------------------------------|------|
| **账本 reserved 无 landed，但正文已落地** | 57 | `skills/task-discipline/references/critical-rules-discipline.md:278`「### 57 迭代测试轮次落盘纪律（P0 — task-v141…）」 | `:17` reserved task-v142，**无 landed** | 账本漏记 landed；且 task_id 与正文（v141）不一致 |
| 同上 | 60 | 同文件 `:295`「### 60 主动解决问题（… P0 — task-v142…）」 | `:20` reserved task-v145 + `:23` abandoned task-v145，**无 landed** | 账本漏记 landed；task_id 不一致（正文 v142） |
| 同上 | 80 | `skills/task-planner/references/critical-rules.md:139`「## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）」 | `:58` reserved task-v169，**无 landed** | 正文在位（且 SKILL.md:217、:155 G9 消费面在位），账本仍判「未落地」 |
| 同上 | 82 | `skills/task-planner/references/critical-rules.md:173`「### 82 技能专业化分层纪律（… task-v171…）」 | `:60` reserved task-v171，**无 landed** | 正文在位（SKILL.md:219 消费面在位），账本仍判「未落地」 |
| **正文已落地，账本 0 记录** | 56 | `skills/task-discipline/references/critical-rules-discipline.md:260`「### 56 用户指令优先与自动执行（P0 — task-v140…）」 | **无** | 编号所有权凭证缺失 |
| 同上 | 83 | `skills/task-planner/references/critical-rules.md:181`「### 83 通道不可用快速失败（P0 — task-v172 CA-6…）」 | **无** | 编号所有权凭证缺失 |
| **账本有记录，正文 0 命中** | 77 / 78 / 79 | — | `:55` / `:56` / `:57`，均 `abandoned` task-v168-session-anchor-skill-activation | 一致（作废号，正文确无）——**唯一三类账本-正文一致的无误项** |
| **landed 无 reserved（历史旁路）** | 46 47 48 49 50 75 | 各自正文在位 | 1–5、8、47 行 | 一致（EXEMPT_LANDED 覆盖，v128 建账本前历史 land） |
| **配对完整** | 51–55、58–59、61–79(除77/78/79)、81、84–93 | 各自正文在位 | reserved+landed 成对 | 一致 |

### 2.3 守门脚本硬编码豁免 vs 正文实况

`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:41`（EXEMPT_DANGLING）与 `:38`（EXEMPT_LANDED）：

- `:38` `EXEMPT_LANDED=(46 47 48 49 50 75)` —— 6 号正文全部在位，**豁免与实况一致**（历史旁路冻结，合理）
- `:41` `EXEMPT_DANGLING=(57 60 80 82)` —— **4 号正文全部在位**（见 2.2 表），**豁免与实况矛盾**：脚本把它们冻结为「历史悬空预留（未落地）」，而实测四条均已落地
- 实跑结果（只读）：`bash skills/task-planner/scripts/selftest-rule-reserve-pairing.sh`
  ```
  PR-01 PASS landed 无 reserved 的缺失项=46 47 48 49 50 75 全在豁免表 46 47 48 49 50 75 内（历史旁路冻结）
  PR-02 PASS reserved 悬空项=57 60 80 82 全在豁免表 57 60 80 82 内（历史悬空冻结）
  PR-03 PASS 豁免表自检通过（去重 + 无空格污染 + 元素全为纯数字）
  Total: 3 PASS=3 FAIL=0        exit 0
  ```
  → **机器门全绿，但绿灯掩盖了 4 条「已落地未登记」+ 2 条「已落地零登记」**。PR-02 的不变量对「真悬空」与「已落地漏登记」不可区分。
- 脚本自身的注册信息（`skills/task-planner/scripts/selftest-registry.tsv:82`）也把该豁免表登记为「历史悬空」语义，进一步固化错误认知。

---

## 3. 部署位同步面

### 3.1 版本标识与滞后

| 部署位 | SKILL.md 行数 | references/critical-rules.md 行数 | SKILL.md 匹配主仓提交 | 落后提交数 | critical-rules.md 匹配提交 | 落后提交数 | Rule 93 命中 |
|--------|---------------|----------------------------------|----------------------|-----------|---------------------------|-----------|-------------|
| **/home/terry/.zcode**（现行实际加载位） | 265（主仓 266） | 193 | `0c9a408` 2026-10-21 10:04 | **19** | `14be073` 2026-10-21 11:22 | **19** | **0**（整个 task-planner 树 0 命中；task-discipline 卫星亦 0 命中） |
| /home/terry/.claude | 237 | 193 | `4941250` 2026-10-18 02:17 | **47** | `4941250` | **47** | 0 |
| /home/terry/.cursor | 237 | 191 | `4941250` | **47** | `602af6b` 2026-10-17 12:58 | **74** | 0 |
| /home/terry/.opencode | 237 | 193 | `34fa8b9` 2026-10-17 16:59 | **56** | `4941250` | **47** | 0 |

主仓 HEAD = `2448e01` 2026-10-21 21:27:54。→ 滞后区间 **19 ~ 74 提交**（按部署位取最轻文件：19 / 47 / 47 / 47）。

### 3.2 相对主仓缺失的关键文件（文件级）

| 部署位 | 缺失文件/目录（Only in main） |
|--------|---------------------------|
| **/home/terry/.zcode** | `skills/task-discipline/references/execution-recall-card.md`（Rule 93 召回卡，唯一缺失项） |
| /home/terry/.claude | `skills/task-discipline/references/execution-recall-card.md`；`skills/task-planner/scripts/schemas/`；`skills/task-planner/scripts/selftest-verify-io.sh`；`skills/task-planner/scripts/verify_io.sh`；`skills/progress-tracker/references/critical-rules-progress.md`；`skills/plan-resume/references/` |
| /home/terry/.cursor | `skills/task-discipline/references/execution-recall-card.md`；`skills/task-planner/scripts/schemas/`；`skills/task-planner/scripts/selftest-gate-injection.sh`；`skills/task-planner/scripts/selftest-verify-io.sh`；`skills/task-planner/scripts/verify_io.sh`；`skills/task-drift-guard/references/` |
| /home/terry/.opencode | 同 .claude 清单 + `skills/error-fix-prompt-forge/`（整技能缺失） |

### 3.3 .zcode 相对主仓 HEAD 的具体内容差（关键规则/门）

`diff <(git show HEAD:skills/task-planner/SKILL.md) /home/terry/.zcode/skills/task-planner/SKILL.md`：

- `:9` 索引口径 `Rules 1-93 全集索引 … 其余 74 条按域归 11 卫星` → 部署位为 `1-92 … 73 条`
- `:17` 卫星 task-discipline 规则集尾部缺 `93`
- `:95` **`3g 规范召回（Rule 93）` 整行缺失**（主仓执行循环第 3g 步，指向 `../task-discipline/references/execution-recall-card.md`）
- `:140` Read-vs-Write 决策矩阵缺 `＋执行规范召回卡（Rule 93.3）`
- `:195` 卫星路由表 task-discipline 行缺 `93`
- `:208` `Rules 1-93 全集索引 … 其余 74 条` → 部署位 `1-92 … 73 条`
- `:250` 文件说明行 `1-93 全集索引` → 部署位 `1-92 全集索引`
- `references/critical-rules.md:184` 卫星路由行缺 `93`
- `skills/task-discipline/references/critical-rules-discipline.md` 在部署位 **Rule 93 正文 0 命中**（主仓 `:590`「### 93 规范再召回纪律（P0 — task-v195…）」）
- `skills/task-planner/scripts/selftest-requirement-coverage.sh` 部署位缺主仓工作区新增的 60 行断言（51.9–51.13）

→ **现行加载位缺失整条 Rule 93 规范召回机制（SKILL.md 3g 行 + 召回卡文件 + discipline 正文 + 索引计数）**。

### 3.4 唯一部署感知门的实测行为

`bash skills/task-planner/scripts/selftest-doc-script-paths.sh --deploy`（只读）：
```
T01 PASS / T01 面：docs=46 tokens=162 / T02 PASS / T03 PASS
[deploy-path] ✗ 悬空引用 2 处（去重后 1 个部署位路径；仓库有 / 部署无）
  [deploy-path] ✗ /home/terry/.zcode/skills/task-discipline/references/execution-recall-card.md ← skills/task-discipline/references/critical-rules-discipline.md:594 ../task-discipline/references/execution-recall-card.md
[deploy-path] 注：report-only 不计入 FAIL——部署位同步属运维动作（待授权，与 registry RRV-13 部署位对账同批）
Total: 3 PASS=3 FAIL=0        exit 0
```
→ 门**能看见** .zcode 的 Rule 93 悬空引用，但自述 report-only，**不计入 FAIL、exit 0**。仓内无任何「部署位内容 parity 门」（全仓 selftest 检索无第二处比对部署位文件内容的脚本）。

---

## 4. 发现清单

### B-01 ｜P0｜当前 active 计划未进 INDEX.md

- **现象**：`plans/.active_plan` 指向 `task-skill-audit-20261021`，该目录存在于磁盘且有 task_plan.md，但 INDEX.md 15 条数据行中无此 id。
- **证据**：`plans/.active_plan` 内容 = `task-skill-audit-20261021`；`plans/INDEX.md:10-24` 15 条数据行（`grep -c '^|'` = 17 = 表头+分隔+15）；`plans/task-skill-audit-20261021/task_plan.md` 存在。双向差集：INDEX→磁盘 = ∅，磁盘→INDEX = {task-skill-audit-20261021}。
- **影响**：INDEX.md:5-6 自述「恢复时先读本文件：in_progress=中断待续 / pending=未开始 / complete=已完成」——权威恢复入口漏掉当前活跃任务 → 跨会话恢复/INDEX 重建会丢任务指针；「待处理（需关注）」清单（:26-33）同样漏列。
- **违反**：Rule 81.4（`skills/task-planner/references/critical-rules.md:165`）index/pointer coherence。

### B-02 ｜P1｜INDEX.md 表格列数错配（8 列表头 vs 6 列分隔行）

- **现象**：表头 8 列，分隔行只声明 6 列。
- **证据**：`plans/INDEX.md:8` = `| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |`（8 列）；`plans/INDEX.md:9` = `|---------|--------|-----------|------|---------|------|`（6 列）。数据行（如 `:10`）为 8 段。
- **影响**：Markdown 渲染按分隔行列数截断 → `scope_files` / `最后更新` / `待办` 三列不可见或错位；审计者从 INDEX 读不到 Phase 进度与待办状态，索引的「可核验性」在最表层即失效。

### B-03 ｜P1｜INDEX 汇总行与实际在途目录数不一致

- **现象**：汇总宣称 15 项（in_progress 4 / pending 3 / complete 8），磁盘实际有 task_plan.md 的在途目录 16 个。
- **证据**：`plans/INDEX.md:46` `- in_progress: 4 | pending: 3 | complete: 8`；磁盘 16 个有 plan 的在途目录；差 1 = B-01 的 `task-skill-audit-20261021`。
- **影响**：汇总行使读者误判「plans/ 已被完整盘点」，掩盖 B-01。

### B-04 ｜P0｜8 个 Status 全 complete 的计划仍留在 plans/ 根（违反 Rule 81「完成即归档」）

- **现象**：8 个已完成计划在根目录滞留 1–6 天，其中 task-v180~task-v187 完成于 2026-10-16~18，至今未归档。
- **证据**（Phase 数 / Status 行数 / complete 数三者相等，均满足 archive-plan.sh:138-147 覆盖校验）：
  - `plans/s77-p2-fix/task_plan.md` 4/4/4
  - `plans/skill-audit-s77-20261019/task_plan.md` 4/4/4
  - `plans/skill-audit-s77-fix-20261019/task_plan.md` 5/5/5
  - `plans/task-v180-scope-contract/task_plan.md` 1/1/1
  - `plans/task-v181/task_plan.md` 1/1/1
  - `plans/task-v183-verif-closeout/task_plan.md` 5/5/5
  - `plans/task-v184-proactive-error-review/task_plan.md` 5/5/5
  - `plans/task-v187-workflow-activation-parallel/task_plan.md` 4/4/4
  - 守卫可放行测算：`.session-owner` mtime 分别为 —(无)、—(无)、—(无)、2026-10-16 02:50、2026-10-16 03:16、2026-10-17 01:46、2026-10-17 14:02、2026-10-18 05:01 → **7 个当前守卫即可放行**（>24h 或无 owner）；`s77-p2-fix` owner mtime = 2026-10-21 06:07:51（审计时点距今 <24h）被 TTL 拦
- **影响**：Rule 81.1（`critical-rules.md:161`「任务终验 check-complete.sh exit 0 后…必须对当前任务目录执行归档…跳过=违规」）被违反；Rule 81.3 守卫的设计目的是防误归档在途，而此处是反向——已完成项永久滞留 → plans/ 根堆积、INDEX 失真（B-01/B-03）、归档语义被稀释。

### B-05 ｜P1｜7 个 plans/ 根目录无 task_plan.md（含 1 个完全空目录），永远无法归档

- **现象**：`task-v183/` 是空目录；其余 6 个是「有产出文档但无计划」的报告/审计目录。
- **证据**：
  - `plans/task-v183/` → 内容为空（`ls -A` 空）
  - `plans/cost-analysis-2026-10-05/` → 4 份 md（无 plan）
  - `plans/incident-reports/` → 2 份 md
  - `plans/perf-diagnosis-2026-10-12/` → report.md
  - `plans/skill-audit-20261019/` → diagnostic-report.md + subagent-state/
  - `plans/task-v191-project-audit-sync/` → delivery-summary.md + subagent-state/（**有交付总结但无计划、无 Status 状态机**）
  - `plans/verification-upgrade-2026-10-16/` → report.md
- **影响**：`archive-plan.sh:128` 守卫 total=0 → `status-none` fail-closed 拒绝 → 这 7 类目录**结构上永远无法归档**，只能人工搬运；`task-v191-project-audit-sync` 这类「有 delivery-summary 交付物但无 task_plan 状态锚」的目录，正是「执行产出不可追溯」的典型形态（无 Goal / 无 Status / 无 VC 记录）。
- **违反**：Rule 81 形态铁律「在途在根、历史在 archive/」（`SKILL.md:112`）。

### B-06 ｜P1｜3 个计划有 task_plan.md 但无任何 Status 行（状态机缺失）

- **现象**：task_plan.md 存在但零个 `- **Status:**` 列表锚行。
- **证据**：
  - `plans/task-defect-rrv13-dg12-false-pass/task_plan.md`（40 行，0 处 Status 行；`grep -i status` 唯一命中为 `:30` 的 `git status --short` 文字）
  - `plans/task-v192-deploy-zcode/task_plan.md`（37 行；`:15 ## Phases`、`:16` 表头含「状态」列、`:28` VC 表，但无一行 `- **Status:**`）
  - `plans/task-v193-skill-goal-drift-fix/task_plan.md`（55 行；`:27 ## 步骤 / Phase`，无 Status 行）
- **影响**：
  1. archive-plan.sh status-none 拒绝 → 同样永远无法归档；
  2. `sync-todos.sh` 解析不到状态 → INDEX 把它们写成 `pending | 0/0 | (no goal)`（`INDEX.md:13`、`:23`、`:24`）——**这是解析兜底值而非真实状态**，掩盖了「状态从未被写入」这一事实；
  3. 违反 Rule 5（Phase 完成后更新）+ Rule 81.3 的 fail-closed 前提（`critical-rules.md:163`「含 0 行=异常」）。

### B-07 ｜P2｜archive/ 内存在非全 complete 的归档计划

- **现象**：已归档目录里仍有 pending 态 Phase。
- **证据**：`plans/archive/task-v069-context-hygiene/task_plan.md` — Status 行 8 条，其中 `:180`、`:218`、`:238` 为 `- **Status:** pending`，5 条 complete。
- **影响**：「archive/ = 历史 = 已完成」语义被破；任何按 archive 溯源「这批工作还差什么」的下游读取会读到 3 个 pending Phase，产生与现实不符的结论。

### B-08 ｜P2｜plans/ 根堆积失效 side 指针与 71 个漂移节奏状态文件

- **现象**：`.active_plan_side/` 残留 3 个正式指针 + 4 个 `.tmp.*` 临时指针，其中 2 个指向**不存在的计划**；`.drift-rhythm/` 积累 71 个 session 状态文件。
- **证据**：
  - `plans/.active_plan_side/dwfdwfrun3053e3ffb3234b85a3e81fb6189.active_plan` → `task-v193-skill-goal-drift-fix`
  - `plans/.active_plan_side/ionc6d79d2cb258c907a8a71232dc962182.active_plan` → `task-v193-skill-goal-drift-fix`
  - `plans/.active_plan_side/ion8252bb380b6c1e030a706eba5e62b055.active_plan` → `task-skill-audit-20261021`
  - `plans/.active_plan_side/.tmp.cH2stf` 与 `.tmp.xfv7Mz` → `task-batch-report-tmpl-fix`（**`plans/task-batch-report-tmpl-fix` 不存在** → 幽灵指针）
  - `ls plans/.drift-rhythm/ | wc -l` = **71**
- **影响**：悬空指针指向已不存在的计划 = 计划被删/已归档但指针未清；恢复面会指向幽灵任务，直接破坏「恢复时先读 active 指针」的可追溯性。71 个漂移状态文件在 plans/ 根，与 151 个归档目录共同构成 plans/ 的堆积面。

### B-09 ｜P0｜编号账本机器门结构性假 PASS：4 条已落地规则被 EXEMPT_DANGLING 永久豁免

- **现象**：EXEMPT_DANGLING 冻结的 4 个编号（57/60/80/82）正文**全部已在仓内落地**，账本却无 landed 行；配对门因豁免全部 PASS。
- **证据**：
  - 豁免表：`skills/task-planner/scripts/selftest-rule-reserve-pairing.sh:41` `EXEMPT_DANGLING=(57 60 80 82)`；`:38` `EXEMPT_LANDED=(46 47 48 49 50 75)`
  - 正文（实测在位）：
    - Rule 57 → `skills/task-discipline/references/critical-rules-discipline.md:278`「### 57 迭代测试轮次落盘纪律（P0 — task-v141…）」
    - Rule 60 → 同文件 `:295`「### 60 主动解决问题（泛化行为原则，P0 — task-v142…）」
    - Rule 80 → `skills/task-planner/references/critical-rules.md:139`「## Rule 80（用户会话逐字记录与只写不改纪律 — task-v169）」（消费面 `SKILL.md:155` G9、`:217` 亦在位）
    - Rule 82 → 同文件 `:173`「### 82 技能专业化分层纪律（… task-v171…）」（消费面 `SKILL.md:219` 在位）
  - 账本：`plans/.rule-reservations.jsonl:17`（57 reserved task-v142，无 landed）、`:20`/`:23`（60 reserved+abandoned task-v145，无 landed）、`:58`（80 reserved task-v169，无 landed）、`:60`（82 reserved task-v171，无 landed）
  - 门实跑：`Total: 3 PASS=3 FAIL=0`，exit 0
  - 附注：账本 task_id 与正文署名不一致（账本 57→v142 / 正文 57→v141；账本 60→v145 / 正文 60→v142）→ 不可据账本回溯正文来源
- **影响**：账本低报已落地规则数 4 条；PR-02 不变量对「真悬空」与「已落地漏登记」本质不可区分 → **Rule 20.6 配对门对真实缺陷永久豁免，且绿灯**。任何「某编号是否已占用」的裁决都会基于错误事实源，做出撞号决策。
- **违反**：Rule 20.6（`critical-rules.md:50`「合并后 land、废弃 release」）；且与 Rule 82 自身「空壳与预留号纪律」（`critical-rules.md:179`「预留号落地/废弃按 Rule 20.6 台账 land/release，删除任何规则前必须实测当前正文而非凭历史登记」）直接冲突——账本里 80/82 恰是「正文已实测在位、land 未登记」的反例。

### B-10 ｜P1｜2 条已落地规则在账本 0 记录（Rule 56 / Rule 83）

- **现象**：正文在位，编号所有权凭证完全缺失。
- **证据**：
  - Rule 56 → `skills/task-discipline/references/critical-rules-discipline.md:260`「### 56 用户指令优先与自动执行（P0 — task-v140…）」
  - Rule 83 → `skills/task-planner/references/critical-rules.md:181`「### 83 通道不可用快速失败（P0 — task-v172 CA-6…）」（消费面 `SKILL.md:185` 在位）
  - 账本 81 行中 `rule` 字段无 56、无 83；46–93 区间仅缺 56 / 76 / 83 三号，其中 76 已有 reserved+landed
- **影响**：Rule 20.6（`critical-rules.md:50`）要求新编号经 `rule-reserve.sh` 登记；56/83 无凭证 → 他人可再次占用同号，或删改这两条正文时无账本可查（「编号所有权凭证」失效）。

### B-11 ｜P1｜Rule 93 的 reserve/land 登记行未提交（账本唯一事实源不可跨会话共见）

- **现象**：工作区账本比 HEAD 多 2 行（Rule 93 reserved + landed），未提交。
- **证据**：`git diff plans/.rule-reservations.jsonl` → `+{"rule":93,"status":"reserved","task_id":"task-v195-spec-recall","ts":"2026-10-21","note":""}` / `+{"rule":93,"status":"landed",...}`；HEAD = `2448e01` 不含这两行。
- **影响**：Rule 20.6（`critical-rules.md:50`）明文要求「台账预留行与计划簿记随任务收口（land/commit）一并提交，禁止长期 uncommitted（**已提交台账 = 跨会话唯一共见事实源**）」→ 未提交 = 换会话/换 worktree 看不见 Rule 93 已被占用 → 撞号风险；且正文（discipline:590 / SKILL.md:95 / execution-recall-card.md）已在 HEAD（`a182b71` / `419dfb3`），**正文已提交而账本未提交 = 正文与账本不同步**。

### B-12 ｜P1｜Rule 93 正文在主仓已落地，但现行加载位（~/.zcode）0 命中

- **现象**：Rule 93（规范再召回纪律）在主仓有完整正文 + 执行接线 + 召回卡，在现行加载位完全不存在。
- **证据**：主仓 `skills/task-discipline/references/critical-rules-discipline.md:590`「### 93 规范再召回纪律（P0 — task-v195…）」；`skills/task-planner/SKILL.md:95`「**3g 规范召回（Rule 93）**」；`skills/task-discipline/references/execution-recall-card.md` 存在（4458 B，mtime 2026-10-21 11:29）。部署位：`grep -rl 'Rule 93' /home/terry/.zcode/skills/task-planner` = **0 命中**；`grep -c 'Rule 93\|### 93' /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md` = **0**；`/home/terry/.zcode/skills/task-discipline/references/` 无 `execution-recall-card.md`。
- **影响**：现行实际加载位缺失整条规范召回机制 → 长上下文/compaction 场景下执行规范遵守度衰减无召回兜底，而 SKILL.md 是会话实际加载面 → **会话行为与仓内规则不一致**，执行产出按旧规则产生，事后按新规则核验必然不通过。

### B-13 ｜P0｜4 个部署位全部落后主仓，且无任何可阻断的部署一致性门

- **现象**：现行加载位落后 19 提交，其余 47~74 提交；唯一 deploy 感知门为 report-only。
- **证据**：见 §3.1 滞后表（方法已在文首声明）；门实跑见 §3.4（exit 0，`Total: 3 PASS=3 FAIL=0`）；全仓 selftest 检索：除 `selftest-doc-script-paths.sh` 的 `--deploy` 外，**无第二处比对部署位文件内容的脚本**（`grep -ln 'deploy|部署位' skills/task-planner/scripts/selftest-*.sh` 仅命中 selftest-doc-script-paths.sh:11）。
- **影响**：部署漂移在门控层**完全静默**（有报告、无失败）；`.zcode` 位缺 Rule 93 全套 + 51.9–51.13 相关断言；`.claude/.cursor/.opencode` 缺 `verify_io.sh` / `selftest-verify-io.sh` / `selftest-gate-injection.sh` / `scripts/schemas/` 等机械面 → 在这些位上跑终验/IO 校验直接 404。

### B-14 ｜P1｜部署位缺失关键文件清单（文件级）见 §3.2 表格

- **影响**：`check-complete` / `verify_io` / `gate-injection` 机械面在 .claude/.cursor/.opencode 缺失；`task-discipline` 召回卡全 4 位缺失；`progress-tracker` 规则正文在 .claude/.opencode 缺失；`task-drift-guard/references/` 在 .cursor 整目录缺失；`error-fix-prompt-forge` 技能在 .opencode 整技能缺失 → 这些位上的卫星域规则正文 = 悬空引用。

### B-15 ｜P1｜主仓工作区 4 个未提交改动 = 已落地但未固化，也未进任何部署位

- **现象**：HEAD（`2448e01`）与工作区行为不一致；「0 母图即 COMPLETE」事故的封堵条款只存在于工作区。
- **证据**：`git status --short` → ` M plans/.rule-reservations.jsonl` / ` M skills/task-planner/SKILL.md` / ` M skills/task-planner/references/critical-rules.md` / ` M skills/task-planner/scripts/selftest-requirement-coverage.sh`；`git diff --stat` = **4 files, 69 insertions(+), 5 deletions(-)**：
  - `SKILL.md:214` 51 bullet 增补（51.9-51.12）
  - `references/critical-rules.md:98/100/102/104/106` 新增 51.9 / 51.10 / 51.11 / 51.12 / 51.13 五子条
  - `scripts/selftest-requirement-coverage.sh` +60 行新增断言
  - `.rule-reservations.jsonl` +2 行（Rule 93）
- **影响**：封堵条款 51.9–51.13（「可计数交付物全 R 化」「禁 0 产出为 covered 判据」「留口须逐字让步锚」）是 Rule 51 事故的修复面，**当前只在工作区**：任何一次 commit / 切分支 / 部署 / 容器化重建都会丢失；复现与核验的基线不确定（HEAD 不含、磁盘含），审计者无法确定「当前生效规则集」。
- **违反**：Rule 27（逐 Phase 提交，`SKILL.md:97`）+ Rule 20.6「禁止长期 uncommitted」。

### B-16 ｜P2｜部署位自身工作区不干净（版本不可定位）

- **现象**：3 个部署位的 git 工作区含未提交改动。
- **证据**：`/home/terry/.zcode` → ` M skills/task-planner/SKILL.md`、` M skills/task-planner/scripts/selftest-dispatch-grain.sh`；`/home/terry/.claude` → 5 个 task-planner 文件 `M`；`/home/terry/.opencode` → `?? skills/task-planner/`（整树未纳入版本控制）；`/home/terry/.cursor` → 无 .git（完全无版本控制）。
- **影响**：部署位内容 = 已提交 + 未提交混合态，无法用单一 commit 定位其真实版本；`.cursor` 位连版本溯源都没有 → 该位的执行产出完全不可核验（与「产出不可追溯」目标直接冲突）。

### B-17 ｜P1｜形态违反 Rule 81「在途在根、历史在 archive/」

- **现象**：根=在途 / archive=历史 的双向分区被三处破坏。
- **违反点**：
  1. 根侧混入已完成：8 个 Status 全 complete 计划留在 `plans/` 根（B-04）→ 违反 `skills/task-planner/SKILL.md:112`（Rule 81.1 归档触发点）与 `references/critical-rules.md:161`（81.1「跳过=违规」）
  2. 根侧混入非计划目录：7 个无 task_plan.md 目录（B-05），其中 1 个空目录（`plans/task-v183/`）—— 根侧「在途」集合本身定义不成立
  3. archive 侧混入未完成：`plans/archive/task-v069-context-hygiene/task_plan.md:180/218/238` 三条 pending（B-07）
  4. 存量治理四步从未执行：`references/critical-rules.md:165`（Rule 81.5「存量治理（Rule 18 批门四步）」）要求 `dry-run → 试点 → 双采样 → 批量实做`；plans/ 根 8 个已完成 + 7 个无计划目录并存（2026-10-16 ~ 2026-10-21）即该条未落地的直接证据
- **影响**：Rule 81.1 自陈「Why：『在途在根、历史在 archive/』维持 plans/ 健康形态防堆积索引失真」——现状正是堆积 + 索引失真（B-01/B-03），且 Rule 81.3 反复声明「误归档在途=数据面事故」，说明该形态一旦失守的代价被技能自身认定为事故级。

### B-18 ｜P1｜形态违反 Rule 20.6 编号预留登记

- **违反点**：
  1. Rule 56 / Rule 83 正文在位、账本 0 记录（B-10）
  2. Rule 57 / 60 / 80 / 82 正文在位、账本无 landed（B-09）
  3. Rule 93 landed 行未提交（B-11）
  4. 账本 task_id 与正文署名错配（57→v142/v141、60→v145/v142），账本不可据以回溯正文来源（B-09 附注）
- **规则锚**：`skills/task-planner/references/critical-rules.md:50`（Rule 20.6 全文，含「编号所有权凭证」「查重登记」「合并后 land、废弃 release」「已提交台账 = 跨会话唯一共见事实源」）
- **影响**：编号所有权事实源失真 → 新增规则的撞号裁决（B-10）与「某规则是否已落地」的核验（B-09）都建立在错误账本上；且唯一机器门 selftest-rule-reserve-pairing.sh 的绿灯具有误导性（Total 3 PASS / exit 0）。

### B-19 ｜P2｜形态违反 Rule 18 批门：存量清退未走「四步 + 双采样 + 失败率>5% STOP」

- **违反点**：`skills/task-planner/references/critical-rules.md:165`（Rule 81.5 存量治理引 Rule 18 批门四步）+ `skills/task-discipline/references/critical-rules-discipline.md:31`（Rule 18 批量处理质量门控：批量前必须做质量影响评估、禁静默执行）
- **证据**：plans/ 根 8 个 complete 计划跨 2026-10-16~2026-10-21 长期并存，无任何 dry-run / 试点 / 双采样记录；`archive-plan.sh` 自身把误归档定义为数据面事故（`critical-rules.md:163`「fail-closed，误归档在途=数据面事故」）。
- **影响**：清退既未做批门评估，也无从证明「未牺牲质量」；一旦将来批量清退，8 个 complete + 7 个无计划目录（含 1 个空目录）混在同一批次里，空目录与无 Status 目录会被 status-none 拒绝 → 批内失败率天然 >5% → 按 Rule 18 应当整批 STOP。

### B-20 ｜P2｜INDEX 自动生成声明与实际内容脱节（生成器与产物口径不一致）

- **现象**：`plans/INDEX.md:2` 声明「Auto-generated by sync-todos.sh --index. 勿手改，重跑脚本刷新」，但现有产物存在列数错配（B-02）与漏行（B-01），说明生成器或被手改、或生成器本身有缺陷，但无从区分。
- **证据**：`plans/INDEX.md:2-3`；`:9` 分隔行 6 列 vs `:8` 表头 8 列；`git log -- plans/INDEX.md` → `2448e01` / `3c97d37` / `4415f32`（提交说明均含「INDEX 刷新」），而 `:3` 的 `Last refreshed: 2026-10-21_14:11` 早于 `2448e01` 的提交时刻 21:27:54 → **提交说明称「INDEX 刷新」但 Last-refreshed 时间戳与该提交不对应**。
- **影响**：INDEX 的权威性（`INDEX.md:5-6`「恢复时先读本文件」）依赖「自动生成 + 勿手改」；一旦生成器与手改混用，恢复面读到的是不可信索引。

---

## 5. 三条最严重

1. **B-09 + B-10 + B-11（编号账本事实源失真 + 机器门结构性假 PASS）**
   4 条已落地规则（57/60/80/82）被 EXEMPT_DANGLING 永久豁免、2 条已落地规则（56/83）零登记、Rule 93 的 land 行未提交；守门脚本实跑 `Total: 3 PASS=3 FAIL=0, exit 0`。账本是「规则是否落地」的唯一可核验凭证（Rule 20.6「编号所有权凭证」「已提交台账 = 跨会话唯一共见事实源」），当前既失真又被绿灯掩盖 → **规则落地与否不可核验**，且撞号裁决基于错误事实。

2. **B-04 + B-05 + B-06 + B-17（plans/ 簿记面形态失守）**
   根侧 8 个 Status 全 complete 计划未归档（其中 7 个守卫当下即可放行）、7 个目录无 task_plan.md（含空目录 `plans/task-v183/`）、3 个 plan 零 Status 行 → 状态机缺失、无法归档、无法被 guard 覆盖；archive 侧另有 1 个含 3 条 pending 的计划。Rule 81 明文「在途在根、历史在 archive/」被三向破坏，INDEX 同步失真（B-01/B-03）→ **执行产出与计划的对应关系不可追溯**。

3. **B-13 + B-14 + B-15（部署面漂移无门 + 在途改动未固化）**
   现行加载位 ~/.zcode 落后 19 提交且 Rule 93 整条缺失（SKILL.md 3g + 召回卡 + discipline 正文 + 索引计数），唯一 deploy 感知门为 report-only、exit 0，全仓无第二处部署 parity 门；同时 51.9–51.13 与其 60 行断言只存在于未提交工作区 → **会话实际加载并执行的规则 ≠ 仓内已审计规则，且仓内基线本身不稳定**，任何「执行产出是否合规」的核验都缺少可信基线。

---

## 6. 可立即执行的补救动作建议（只建议，不执行）

> 以下为建议清单，本审计未执行任何写操作。所有涉及部署位/保护区文件的动作需用户显式授权（AGENTS §六 / §十一）。

**建议 0（前置，阻塞项）— 先固化主仓在途改动**
1. 将 `skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/scripts/selftest-requirement-coverage.sh`、`plans/.rule-reservations.jsonl` 四个未提交文件按 Rule 27 逐文件提交（禁止 `git add -A` 盲扫，只 add scope 文件），使 51.9–51.13 与 Rule 93 登记进入 HEAD。理由：建议 1 与建议 2 的修复都依赖一个稳定基线，否则修复本身在下次切分支/部署时即丢失。

**建议 1 — 修复编号账本（对应 B-09 / B-10 / B-11）**
2. 补登账本行：Rule 56（正文 `critical-rules-discipline.md:260`）、Rule 83（正文 `critical-rules.md:181`）各补 `reserved` + `landed`；Rule 57 / 60 / 80 / 82 各补 `landed`（正文 file:line 见 B-09 表），task_id 统一取正文署名（57→task-v141、60→task-v142、80→task-v169、82→task-v171），与账本现有 task_id 的差异在 note 中留仲裁说明。
3. 收窄 `selftest-rule-reserve-pairing.sh:41` 的 `EXEMPT_DANGLING=(57 60 80 82)`：补 landed 后应移除这 4 项（脚本注释已写「新增失配对必须走仲裁改号或补登记，不得扩表静默放行」——此处是反向扩表）；重跑该脚本，确认 PR-02 由「豁免放行」转为「真实配对 PASS」。
4. 建议（需用户裁决）是否为 PR-02 增加一条「正文在位但账本无 landed」的交叉断言（正文侧 file:line 清单来自 §2.2 表），使「已落地漏登记」不再能被豁免表吸收。

**建议 2 — 收敛 plans/ 簿记面（对应 B-01 ~ B-08、B-17 ~ B-20）**
5. 按 Rule 81.5 四步清退 8 个已完成计划：`bash scripts/archive-plan.sh <task-id> --batch --dry-run` → 试点 1 个 → 双采样（批前抽 2 个预检，>0 即整批熔断）→ 显式 `--root` 批量实做；`s77-p2-fix` 待其 `.session-owner` 超过 24h（2026-10-22 06:07 后）再入批。归档后重跑 `bash scripts/sync-todos.sh --index`。
6. 补齐 3 个缺 Status 行的 plan（`task-defect-rrv13-dg12-false-pass` / `task-v192-deploy-zcode` / `task-v193-skill-goal-drift-fix`）的 Phase↔Status 状态机（当前各只有 0 个 Status 行，属 Rule 5 / Rule 81.3 fail-closed 前提缺失）。
7. 处理 7 个无 task_plan.md 目录：或补建最小 plan（Goal + Phase + Status），或按归档语义人工移入 `plans/archive/`（`task-v183` 空目录可直接清理）——二者择一需用户裁决，因 `task-v191-project-audit-sync` 含 delivery-summary 与 subagent-state，处置方式影响既有交付物可追溯性。
8. 修正 `plans/INDEX.md:9` 分隔行列数（6 → 8，与 `:8` 表头对齐），确认 `task-skill-audit-20261021` 出现在索引与「待处理」清单，并核对 `Last refreshed` 与提交说明的一致性（B-20）。
9. 清理 `plans/.active_plan_side/.tmp.cH2stf` 与 `.tmp.xfv7Mz`（指向不存在的 `task-batch-report-tmpl-fix`）及 `plans/.drift-rhythm/` 下 71 个陈旧 `.state`（先确认无活跃会话引用）。
10. 复核 `plans/archive/task-v069-context-hygiene/task_plan.md:180/218/238` 三条 pending：是补 complete 还是移出 archive，需用户裁决（改动已归档档案=数据面变更）。

**建议 3 — 收敛部署面（对应 B-12 ~ B-16，需用户显式授权）**
11. 将主仓 HEAD（含建议 0 的提交）同步至 4 个部署位，优先 `/home/terry/.zcode`（现行实际加载位），并确保 `skills/task-discipline/references/execution-recall-card.md` 到位（Rule 93 召回卡）；`.claude/.cursor/.opencode` 另需补 `verify_io.sh` / `selftest-verify-io.sh` / `selftest-gate-injection.sh` / `scripts/schemas/` / `progress-tracker/references/critical-rules-progress.md` / `task-drift-guard/references/` / `plan-resume/references/` / `error-fix-prompt-forge/`。
12. 把 `selftest-doc-script-paths.sh --deploy` 的 report-only 悬空引用升级为可阻断项，或新增一个部署位内容 parity 门（比对部署位 `SKILL.md` / `critical-rules.md` / `critical-rules-discipline.md` 与主仓 HEAD 的 blob 哈希）——否则部署漂移永久静默。
13. 清理部署位工作区未提交改动（B-16）；`/home/terry/.cursor` 与 `/home/terry/.opencode` 位需先纳入版本控制，否则该位产出不可溯源。

---

## 7. 审计自证

- **只读性**：全部操作为 `ls` / `stat` / `grep` / `diff` / `read` / `git log` / `git diff` / `git status` / `git rev-list` / `git cat-file` / `git show` / 执行仓内只读 selftest 脚本（`selftest-rule-reserve-pairing.sh`、`selftest-doc-script-paths.sh --deploy`，二者自述零写入）。**无任何 git 写操作**（未 checkout / stash / clean / commit / add / reset），**未修改或删除任何文件**，唯一写入 = 本检查点文件。
- **未触碰他仓**：仅读取 `/home/terry/.zcode`、`.claude`、`.cursor`、`.opencode` 下 `skills/` 与 `.git` 元数据；未访问 `/home/terry/videop1` 等其他仓。
- **排除 .backup**：所有 `diff -rq` 均带 `--exclude=.backup`。
- **未验证项（明确标注）**：
  1. 部署位「落后 N 提交」为**内容哈希比对推导值**，非部署位仓自身与主仓的 git 祖先关系（两仓历史无共同祖先，`git cat-file 2448e01` 在各部署位均报 `Not a valid object name`）；该值随主仓继续提交而增长。
  2. 8 个 complete 计划的「守卫可放行」结论基于 archive-plan.sh:94-147 源码逐条比对 + 实际 mtime 推算，**未实跑 archive-plan.sh**（该脚本会执行 `git mv`，非只读）。
  3. 3 个无 Status 行 plan 的真实状态未知（`sync-todos.sh` 写入 INDEX 的 `pending / 0/0 / (no goal)` 为解析兜底值，非事实）。
  4. `plans/archive/task-v069-context-hygiene` 的 3 条 pending 是否为「归档后追加」或「归档前漏翻转」未追溯（需查该目录 git 历史）。
  5. `plans/task-v183/` 是否为删除残留抑或计划从无产出，未从 git 历史确认。
