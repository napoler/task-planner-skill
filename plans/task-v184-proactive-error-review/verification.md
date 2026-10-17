# Verification Contract & Phase Gates

## Goal (1 sentence)

将 5 个未接线判定器（P-02/03/06/08/09）接进 attest/check-3file-gate/check-complete 自动门链实现规划期/翻转期/终验期三时点主动拦截，并补齐内容错误审查层（证据声明↔内容机器核对 + Rule 84.7 内容审查门 + 注入式行为回归），全量回归 0 新增失败。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: v183 收口完成（check-complete exit 0 + 归档 + Rule 90 首锚提交 + 基线 90/90）
  **Verify command**: `bash skills/task-planner/scripts/check-complete.sh plans/task-v183-verif-closeout/task_plan.md; echo rc=$?; ls plans/archive/ | grep -c v183; git log --oneline -3; bash skills/task-planner/scripts/run-selftests.sh --fresh | tail -3`
  Evidence: 命令输出（rc=0 / 归档命中 / 提交哈希 / Total: 90 PASS=90 FAIL=0）
- [ ] VC-2: 主动拦截生效——5 判定器接线后逐门注入缺陷计划走真实门链被拦，干净夹具+活计划零误报
  **Verify command**: `bash skills/task-planner/scripts/selftest-gate-injection.sh; echo rc=$?`
  Evidence: 输出含 ≥5 门注入断言全 PASS（exit≠0+留痕行）+ 干净夹具 exit=0；rc=0
- [ ] VC-3: 内容核对层——证据格声明串与证据文件实际内容不符→FAIL，相符→PASS，存量误报率量化
  **Verify command**: `bash skills/task-planner/scripts/check-evidence-anchor.sh /tmp/claim-mismatch-fixture; echo rc_mismatch=$?; bash skills/task-planner/scripts/check-evidence-anchor.sh /tmp/claim-match-fixture; echo rc_match=$?; bash skills/task-planner/scripts/selftest-evidence-anchor.sh | tail -3`
  Evidence: rc_mismatch≠0 / rc_match=0 / selftest FAIL=0；146 存量误报清单入 findings.md Research Findings
- [ ] VC-4: Rule 84.7 内容审查门条款落地两载体+静态锚
  **Verify command**: `grep -c '84\.7' skills/verification-gate/references/critical-rules-verification.md; grep -c '84\.7' skills/verification-gate/SKILL.md`
  Evidence: 两计数各 ≥1；selftest 静态锚 PASS；alignment-review 结论 APPROVED 入 findings
- [ ] VC-5: 无回归破坏——全量 selftest 0 新增失败，registry 双向一致
  **Verify command**: `bash skills/task-planner/scripts/run-selftests.sh --fresh | tail -3; bash skills/task-planner/scripts/selftest-registry.sh | tail -3`
  Evidence: FAIL=0 且 Total ≥ 90；registry rows=actual

---

## Phase Gates

### Phase 1: v183 收口与基线

**Goal**: 未提交基座（52 文件）落库为 Rule 90 首锚，取得干净回归基线 90/90。

**Depends on**: none

**Done when**:
- [ ] v183 check-complete exit 0（簿记修正后）
- [ ] v183 归档入 plans/archive/ + INDEX 刷新
- [ ] git 提交落库（逐项 add，禁 -A）
- [ ] 全量回归基线取证 FAIL=0

**Verification** (run before moving on):
- [ ] V-1.1: `bash skills/task-planner/scripts/check-complete.sh plans/task-v183-verif-closeout/task_plan.md` → exit 0（mapped to VC-1）
- [ ] V-1.2: `bash skills/task-planner/scripts/run-selftests.sh --fresh | tail -3` → Total=90 FAIL=0（mapped to VC-1, VC-5）

Status: `pending` Last verified: —

---

### Phase 2: 接线批次（主动发现——R1/R2）

**Goal**: 5 判定器接进 attest-plan / check-complete / check-3file-gate 三门链，全 warn 起步，注入式验收。

**Depends on**: Phase 1

**Done when**:
- [ ] S1-S5 全部派发完成且各注入夹具在真实链 exit≠0
- [ ] selftest-gate-injection.sh 落地并 registry 登记
- [ ] config 档位键级联（键数断言）逐处最小同步

**Verification**:
- [ ] V-2.1: `bash skills/task-planner/scripts/selftest-gate-injection.sh` → rc=0 全 PASS（mapped to VC-2）
- [ ] V-2.2: 活计划全量零误报扫描（各判定器对 plans/task-v18*/ 全 exit=0）（mapped to VC-2）

Status: `pending` Last verified: —

---

### Phase 3: 内容错误审查层（核心——R3）

**Goal**: check-evidence-anchor 增 CLAIM_MATCH 内容核对层 + Rule 84.7 内容审查门条款两载体 + selftest 断言。

**Depends on**: Phase 1（S6-S8 与 Phase 2 无文件交集，可交错但按 Phase 序）

**Done when**:
- [ ] S6 内容核对层落地（warn 起步）+ 146 存量误报基线量化入 findings
- [ ] S7 selftest-evidence-anchor 扩断言 + registry 一致
- [ ] S8 84.7 条款两载体 + alignment-review APPROVED

**Verification**:
- [ ] V-3.1: 内容不符夹具 exit≠0 + 相符夹具 exit=0（mapped to VC-3）
- [ ] V-3.2: `grep -c '84\.7' skills/verification-gate/references/critical-rules-verification.md` ≥1 且 `grep -c '84\.7' skills/verification-gate/SKILL.md` ≥1（mapped to VC-4）

Status: `pending` Last verified: —

---

### Phase 4: Testing & Verification

**Goal**: 全量回归 + Code Review Gate + Verifier 独立复验全 VC。

**Depends on**: Phase 2, Phase 3

**Done when**:
- [ ] run-selftests.sh --fresh FAIL=0
- [ ] code-review skill 输出 APPROVED（code_review: required）
- [ ] Verifier 独立复验 VC-1..5 逐条带证据

**Verification**:
- [ ] V-4.1: 全量回归 FAIL=0（mapped to VC-5）
- [ ] V-4.2: CR Gate APPROVED + Verifier 复验记录入 findings（mapped to VC-2, VC-3, VC-4, VC-5）

Status: `pending` Last verified: —

---

### Phase 5: Delivery

**Goal**: Rule 90 尾锚提交 + delivery-summary 五要素 + 部署位同步呈报。

**Depends on**: Phase 4

**Done when**:
- [ ] 尾锚 git 提交落库
- [ ] delivery-summary.md 五要素齐
- [ ] 部署位同步选项呈报用户（默认不部署）

**Verification**:
- [ ] V-5.1: `git log --oneline -2` 尾锚在位 + scope 文件无未提交残留（mapped to VC-1, VC-5）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| plans/verification-upgrade-2026-10-16/report.md §5/§5.1/§7 | 接线点对照「落地方式」列原文逐条一致 | ☐ |
| plans/task-v183-verif-closeout/delivery-summary.md | 5 风险与本计划 CA 表逐条对应 | ☐ |
| check-complete.sh:431 shell-out 先例 | S1-S4 接线形态对照先例 | ☐ |
| critical-rules-verification.md Rule 84 现行文 | 84.7 子条不与 84.1-84.5 冲突 | ☐ |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats plans/task-v184-proactive-error-review
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — {Goal 语句}
对照 Verification Contract 逐条复验：
- VC-1: {evidence} → PASS/FAIL（复验时逐条替换为实际证据）
- VC-2: {evidence} → PASS/FAIL
- VC-3: {evidence} → PASS/FAIL
- VC-4: {evidence} → PASS/FAIL
- VC-5: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
