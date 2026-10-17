# Verification Contract & Phase Gates

## Goal (1 sentence)

关闭审计 dwfrun-04e929e0 遗留的 7 提案 + P-05 修复 + P-04 裁决，使 3 类漏检都有机器检查兜底且全量回归 0 新增失败。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: P-05 periodic-review tr 修复——矛盾检测器复活
  **Verify command**: `grep "tr -d '\*#-'" skills/task-planner/scripts/periodic-review.sh | wc -l` → 3；构造 /tmp 矛盾夹具 `bash skills/task-planner/scripts/periodic-review.sh <夹具>` → exit=1
  Evidence: 全仓 grep `tr -d '*-#'` 归零；干净夹具 exit=0
- [ ] VC-2: P-02 check-vc-nonvacuous.sh 拦截真空命令
  **Verify command**: `bash skills/task-planner/scripts/check-vc-nonvacuous.sh <真空夹具>` → exit≠0
  Evidence: 真空夹具（true/echo ok）exit≠0；`bash scripts/run-selftests.sh --only selftest-vc-nonvacuous` PASS
- [ ] VC-3: P-03/P-06/P-08/P-09 四新脚本 selftest PASS + registry 一致
  **Verify command**: `bash scripts/run-selftests.sh --only selftest-step-placeholders`（及 goal-cjk/rvc-coverage/tier-consistency）→ 全 PASS
  Evidence: 四脚本 selftest 全 PASS；selftest-registry.tsv 双向核对一致
- [ ] VC-4: 全量回归 0 新增失败（基线 84/84）
  **Verify command**: `bash scripts/run-selftests.sh --fresh` → Total: N PASS=N FAIL=0
  Evidence: --fresh 输出 Total 行 FAIL=0
- [ ] VC-5: P-04 档位裁决落地 + 守护同步
  **Verify command**: `grep vc_gate_enforce skills/task-planner/config.json` → 裁决值；`bash scripts/run-selftests.sh --only selftest-state-consistency` PASS
  Evidence: config 档位=warn（用户默认）；selftest-state-consistency PASS

---

## Phase Gates

### Phase 1: Requirements & Discovery

**Goal**: 取证基线 + 确认 7 提案范围
**Depends on**: none
**Done when**:
- [x] 真值回归 --fresh 84/84 绿（P-10 残留已证自愈）
- [x] 7 提案清单确认（P-02/03/05/06/07/08/09）
**Verification**:
- [x] V-1.1: 基线取证 → VC-4
- [x] V-1.2: 提案范围确认 → VC-1
Status: `complete` Last verified: 2026-10-16

---

### Phase 2: Planning & Structure

**Goal**: 计划获批 + 范围锁定
**Depends on**: Phase 1
**Done when**:
- [x] task_plan.md 四锚在位 + S-unit 表 + VC 可执行命令
- [x] attest-plan.sh 锁定
**Verification**:
- [x] V-2.1: 计划 attest → VC-3
- [x] V-2.2: 范围/隔离决策 → VC-5
Status: `in_progress` Last verified: 2026-10-16

---

### Phase 3: Implementation

**Goal**: G1-G8 逐 goal 落地
**Depends on**: Phase 2
**Done when**:
- [ ] S1-S8 全部 complete（6 新脚本 + P-05 修复 + P-04 档位）
**Verification**:
- [ ] V-3.1: P-05 修复验证 → VC-1
- [ ] V-3.2: 新脚本 selftest → VC-3
Status: `pending` Last verified: —

---

### Phase 4: Testing & Verification

**Goal**: 逐 VC 复验 + 全量回归
**Depends on**: Phase 3
**Done when**:
- [ ] 逐条复验 VC-1..VC-5 全 PASS
- [ ] --fresh 全量 0 新增失败
**Verification**:
- [ ] V-4.1: 逐 VC 复验 → VC-1, VC-2, VC-3
- [ ] V-4.2: 全量回归 → VC-4, VC-5
Status: `pending` Last verified: —

---

### Phase 5: Delivery

**Goal**: 交付 + Rule 90 收尾
**Depends on**: Phase 4
**Done when**:
- [ ] 全部 VC 全绿 + delivery-summary 交付
- [ ] git 快照（Rule 90）
**Verification**:
- [ ] V-5.1: 全量回归最终态 → VC-4
- [ ] V-5.2: 档位守护最终态 → VC-5
Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
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
## Goal Verification — 关闭审计遗留 7 提案 + P-05 + P-04
对照 Verification Contract 逐条复验：
- [ ] 复验 VC-1 → PASS/FAIL
- [ ] 复验 VC-2 → PASS/FAIL
...

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
