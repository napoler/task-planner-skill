# Verification Contract & Phase Gates

> **VC 可执行性纪律（Rule 84.1）**：每条 VC 必须含**可运行验证命令**（bash 命令 / 路径+关键行 / diff 判据，三选一），禁止「检查没问题」类无据表述。计划期 attest-plan.sh 的 VC 可执行性门对 standard/full 档硬校验，缺命令=拒锁回炉。

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence, **with executable verification command (Rule 84.1)**.

- [ ] VC-1: [What to check]
  **Verify command**: [bash command OR path+key-line OR diff/evidence form — must be runnable]
  **Pass criteria**: [PASS/FAIL 判定标准]
  Evidence: [file path / command output / screenshot]
- [ ] VC-2: [What to check]
  **Verify command**: [runnable command]
  **Pass criteria**: [PASS/FAIL 判定标准]
  Evidence: [file path / command output]
- [ ] VC-3: [What to check]
  **Verify command**: [runnable command]
  **Pass criteria**: [PASS/FAIL 判定标准]
  Evidence: [file path / command output]
- [ ] VC-4: [What to check]
  **Verify command**: [runnable command]
  **Pass criteria**: [PASS/FAIL 判定标准]
  Evidence: [file path / command output]
- [ ] VC-5: [What to check]
  **Verify command**: [runnable command]
  **Pass criteria**: [PASS/FAIL 判定标准]
  Evidence: [file path / command output]

### VC 可执行性自检清单（计划期，attest 前逐项确认）

- [ ] 每条 VC 含可运行验证命令（bash / 路径+行 / diff 判据，三选一）
- [ ] 每条 VC 含 PASS/FAIL 判定标准（非「检查没问题」类无据表述）
- [ ] VC 条数达标（standard ≥5 / mini ≥2 / L0 ≥1）
- [ ] 每条 VC 映射到 ≥1 个 Phase 的 V-N（R→VC 映射，Rule 51.1）
- [ ] 验证命令可实际执行（非占位/非描述性）

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom] — **command**: [runnable]
- [ ] V-1.2: [mapped to VC-? or custom] — **command**: [runnable]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ... — **command**: [runnable]
- [ ] V-2.2: ... — **command**: [runnable]

Status: `pending` Last verified: —

---

### Phase 3: {Name}

...

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
## Goal Verification — {Goal 语句}
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
...

Outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

> **统一验证入口（可选）**：`bash <skill>/scripts/run-verification.sh <plan-dir>` 解析本文件 VC 命令字段自动执行并汇总 PASS/FAIL，作为逐条手动复验的补充。

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
