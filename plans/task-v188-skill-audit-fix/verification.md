# Verification Contract & Phase Gates

## Goal (1 sentence)

修正 skill-audit-20261019 诊断报告发现的可修复缺陷（批次1 引用一致性+批次2 硬编码路径+批次3 文档卫生），高风险项登记不动。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 2026-10-26 收口复验：VC-1/VC-3 原 grep 口径已按当前文件形态修正（修正理由随条目注明）。

- [x] VC-1: 批次1 引用一致性——跨技能 `skills/卫星/` 引用残留与 verification-gate 脚本位置矛盾消除
  Evidence: 2026-10-26 复跑 `grep -rnE "skills/(task|media|plan|progress|verification|error|iterative)-" skills/task-planner/references/ skills/task-planner/SKILL.md` 仅 3 命中：SKILL.md:21 平台家目录注释 / SKILL.md:44 `<platform-home>/skills/task-planner/templates/`（平台前缀语境）/ methodology.md:61 JSON 示例 artifact 字段——均非仓内跨技能引用（原 VC 期望 0 的口径把平台路径注释也算入，过宽）；F7 修复面 critical-rules-verification.md:44 已为 `selftest-verification-gate.sh（task-planner/scripts/，机械层留守主技能）`；残留 2 处「本卫星 scripts/」均指 run-verification.sh（该脚本确在 verification-gate/scripts/，正确自述）→ **实质 PASS**
- [x] VC-2: 批次2 硬编码——split-pattern-library/template-mapping `/home/terry` 清零 + article-generation 写死清除
  Evidence: 2026-10-26 复跑 `grep -rc "/home/terry" skills/task-dispatch/references/split-pattern-library.md skills/plan-template-kit/references/template-mapping.md` → 0/0；`grep -rn "article-generation" skills/plan-template-kit/references/` → 0 命中；Agent B 全 skills/ 独立扫描硬编码残留缺陷=0（videop1 5 处+MIGRATION.md:40 sed 旧值=登记例外，checkpoint plans/skill-audit-20261026/subagent-state/B-runtime-hardcoded.md）→ **PASS**
- [x] VC-3: 批次3 文档卫生——task-discipline 索引含 Rule 85-90 行 + 三卫星 frontmatter 统一 allowed-tools
  Evidence: 2026-10-26 复跑：索引行现格式为裸数字行（`| 85 | 用户输入一致性纪律 | 同上 |` … `| 90 |` … `| 95 |`，task-discipline/SKILL.md:68-77），85-95 全在位——原 VC grep `Rule 8[5-9]` 期望 ≥6 的口径基于旧「Rule NN」行格式，现裸数字行不含「Rule」前缀故计数=2 为口径过时非缺陷；计数声明统一「本索引现共 46 条全文可消费」（:79/:90）；`grep -l "^tools:" skills/task-dispatch/SKILL.md skills/task-discipline/SKILL.md` → 无文件命中（已统一 allowed-tools）→ **PASS**
- [x] VC-4: 无回归——改动脚本语法通过 + 引用目标存在 + 提交只含 scope 面
  Evidence: commit 4722bb1（2026-10-19）文件清单=plans/ 本任务产物+skills 修复面 ⊆ scope_files 声明；2026-10-26 Agent B `bash -n` 全量 .sh 语法门 TOTAL_FAILS=0；run-selftests.sh --fresh 2026-10-26 = **93 PASS / 0 FAIL** → **PASS**
- [x] VC-5: 登记项——P0(bun)/F5(平台)/F11(I/O Schema)/S76(非原子写) 四类登记不静默
  Evidence: `test -f plans/task-v188-skill-audit-fix/register-deferred.md` exit 0，grep 四类关键词 6 命中；2026-10-26 Agent B 逐项复核 **4 项全 resolved**：bun→node strip-types 落地（session-catchup.ts 实跑 EXIT=0）/F5 init-session.sh 双平台探测齐/F11 verify_io.sh+schemas/check-delegation-stats.schema.json 在位/S76 cli_todo-manager.ts:233-242 原子写+:253-315 O_EXCL 锁 → **PASS**

---

## Phase Gates

### Phase 1: Requirements & Discovery（审计诊断）

**Goal**: 产出 15 技能审计诊断报告（缺陷全清单）

**Depends on**: none

**Done when**:
- [x] 诊断报告落盘（P0×1/P1×9/P2×12，plans/skill-audit-20261019/diagnostic-report.md）

**Verification** (run before moving on):
- [x] V-1.1: mapped to VC-1（F4/F6/F7/F8 发现清单=批次1 输入）
- [x] V-1.2: mapped to VC-4（报告含 sha256 取证防虚构）

Status: `complete` Last verified: 2026-10-26

---

### Phase 2: Planning & Structure（批次划分+登记）

**Goal**: 修复批次划分 + 高风险不动项登记

**Depends on**: Phase 1

**Done when**:
- [x] 批次1-4 方案与 scope_files 约束表落盘（task_plan.md）

**Verification**:
- [x] V-2.1: mapped to VC-5（register-deferred.md 4 类登记，2026-10-19 建）
- [x] V-2.2: mapped to VC-4（scope 表+隔离决策=direct 纯文本面在案）

Status: `complete` Last verified: 2026-10-26

---

### Phase 3: Implementation（批次1-4 修复执行）

**Goal**: 批次1 引用一致性/批次2 硬编码/批次3 文档卫生修复 + 批次4 登记落地

**Depends on**: Phase 2

**Done when**:
- [x] 三批次修复入库（commit 4722bb1，2026-10-19）

**Verification**:
- [x] V-3.1: mapped to VC-1, VC-2, VC-3（grep 复核 0 残留，progress.md 2026-10-19 段记录）
- [x] V-3.2: mapped to VC-4（4722bb1 清单核验 + 2026-10-26 复跑全过）

Status: `complete` Last verified: 2026-10-26

---

### Phase 4: Testing & Verification（独立复验）

**Goal**: VC-1..5 独立复验 + 全量回归

**Depends on**: Phase 3

**Done when**:
- [x] 两路 general-reviewer 独立复审 + selftest 全量回归

**Verification**:
- [x] V-4.1: mapped to VC-1..VC-5（2026-10-26 复跑，Evidence 见上方各条）
- [x] V-4.2: mapped to VC-4（run-selftests.sh --fresh 93/93 PASS，日志 /tmp/selftest-fresh-20261026.log）

Status: `complete` Last verified: 2026-10-26

---

### Phase 5: Delivery（收口交付）

**Goal**: 三文件收口+归档+INDEX 刷新

**Depends on**: Phase 4

**Done when**:
- [x] task_plan/progress/verification 收口 + archive + INDEX

**Verification**:
- [x] V-5.1: mapped to VC-4（git 状态核验）
- [x] V-5.2: mapped to VC-5（登记移交：新发现 B-01..B-05 → plans/skill-audit-20261026/ 载体承接）

Status: `complete` Last verified: 2026-10-26

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| skill-fix SKILL.md 审计标准 S40/S56/S64/S2/S25/S63/S67/S75/S68/S74/S76 | 诊断报告按标准逐条映射（diagnostic-report.md §4 按标准分类速查） | 符合 |
| 诊断报告 plans/skill-audit-20261019/diagnostic-report.md | 批次1-4 输入=报告 F/P2 条目；已修项 2026-10-26 grep 复核 0 残留 | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：`bash skills/task-planner/scripts/check-delegation.sh stats plans/task-v188-skill-audit-fix`

JSON 输出（2026-10-26 收口回填后口径，详见 task_plan.md 委派统计段）：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,
 "main_direct":[{"phase":"2 Planning & Structure","reason":"②计划系统文件维护——白名单"},
                {"phase":"3 Implementation","reason":"历史直改如实登记——无白名单命中(self_declared_reason)"},
                {"phase":"5 Delivery","reason":"①git 编排+②簿记——白名单"}],
 "violations":[{"type":"self_declared_reason","phase":"3 Implementation"}],
 "verdict":"violation"}
```

- [x] 主进程直做 Phase 均在 Executor 字段登记理由——Phase 2/5 命中白名单①②；**Phase 3 为 2026-10-19 历史直改，无白名单编号命中，如实登记不虚构派发**
- [x] 委派率 0.400 < floor 0.7 且含白名单外理由 → check-complete DELEGATION GATE FAILED（exit 1）→ 按 Rule 25.4 处置 **outcome=PARTIAL**（产品面 5/5 VC 全过；流程违规留档不掩盖）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（收口轮无新执行面；Phase 3 委派违规已按 25.4 处置登记）
- [x] Evidence 抽查 ≥3 条:VC-1/2/3 grep 复跑命令+输出已录上方；Agent B checkpoint 可 Read 复现
- [x] 豁免登记:n/a（无豁免项）
- [x] 存在未处置违规 → 无（Phase 3 违规已处置=outcome PARTIAL）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 修正 skill-audit 诊断报告发现的可修复缺陷（批次1-3+登记）
对照 Verification Contract 逐条复验：
- [x] VC-1: grep 复跑+Agent 独立复核 → PASS（口径修正：残留命中均为平台路径注释/正确自述）
- [x] VC-2: grep 0/0 + article-generation 0 → PASS
- [x] VC-3: 索引 85-95 裸数字行在位+46 条口径统一+allowed-tools 齐 → PASS（grep 口径过时已修正）
- [x] VC-4: 4722bb1 ⊆ scope + bash -n 全过 + selftest 93/93 → PASS
- [x] VC-5: register-deferred.md 在位含 4 类，Agent B 复核全 resolved → PASS

 outcome: PARTIAL
```

**PARTIAL**：VC 全过但存在已知遗留 → ✅ **本计划终态**。遗留=流程级 1 项（Phase 3 批次执行为 2026-10-19 主进程直改，委派纪律违规，Rule 25.4 封顶 PARTIAL，如实留档不掩盖）；产品面无未解决缺陷。建议后续：文本面批量修一律按 Rule 96 默认派发（code-assistant/executor）。

> **验证独立性**（Rule 33.3）：终验核查由全新独立子代理执行——2026-10-26 已由两路 general-reviewer（A 引用完整性+计数算术 / B 运行时+硬编码+登记现势）+ run-selftests.sh --fresh（93/93）独立完成，主进程仅编排与簿记。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全部 Phase complete，收口归档（2026-10-26） |
| 2 | Where am I going? | 归档+INDEX 刷新；新发现移交 plans/skill-audit-20261026/ |
| 3 | What's the goal? | 修正审计 P1/P2 缺陷+高风险登记——已完成（4722bb1+复验全过） |
| 4 | What have I learned? | 见 findings.md + notepad-learnings.md |
| 5 | What have I done? | 批次1-4 修复+独立复验+收口（progress.md 两 Session 段） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（skill-audit-20261026 承接新发现） |
