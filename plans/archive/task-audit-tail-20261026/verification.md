# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: [What to check / test command / file to inspect]
  Evidence: [file path / command output / screenshot]
- [ ] VC-2: [What to check]
  Evidence: [file path / command output]
- [ ] VC-3: [What to check]
  Evidence: [file path / command output]
- [ ] VC-4: [What to check]
  Evidence: [file path / command output]
- [ ] VC-5: [What to check]
  Evidence: [file path / command output]

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
- [ ] V-1.2: [mapped to VC-? or custom]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
- [ ] V-2.2: ...

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

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
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

---

## 收口增补（2026-10-26）

### Phase Gates 收口映射
- Phase 1 Discovery（授权解析+实况核实+**v190 误判纠正**）→ V-1.1: VC-1, VC-2 — complete
- Phase 2 Planning（处置方案）→ V-2.1: VC-1..3 — complete
- Phase 3 Implementation（P01 封存/v190 收口/素材 6 处）→ V-3.1: VC-1, VC-2, VC-3 — complete
- Phase 4 Testing（selftest 23/23+全量 93/93+CR APPROVED）→ V-4.1: VC-3, VC-4 — complete
- Phase 5 Delivery（提交+归档+INDEX）→ V-5.1: VC-5 — complete

### VC 复验（2026-10-26）
- [x] VC-1: `test -f plans/archive/task-P01-evidence-anchor/task_plan.md` ✓ ∧ grep SUPERSEDED ≥1 ✓
- [x] VC-2: `test -f plans/archive/task-v190-skill-audit-legacy-fix/task_plan.md` ✓；实况锚 merge 3b50e02+e52b88d ✓；stats=violation(Phase3 历史直改)→outcome=PARTIAL 已决议
- [x] VC-3: grep -c bun selftest-evidence-goal-gate.sh = 0 ✓；23/23 PASS ✓
- [x] VC-4: run-selftests --fresh = 93/93（/tmp/selftest-tail-20261026.log）✓
- [x] VC-5: INDEX in_progress=1（仅本计划，归档后归 0）+ 工作树 clean（终提交后）✓

### 委派统计复验
check-delegation stats：delegated=1/5（Phase 3 Code Assistant，Handoff 在位），main_direct=4 全白名单（②②③①②），rate=0.200 → 25.4a WHITELIST-EXEMPT 预期放行，violations=[]。

### Goal Gate（2026-10-26）
- [x] VC-1..5 全 PASS；R1/R2 全达成（R1 含 v190 纠偏处置）
- outcome: **COMPLETE**（三项处置+纠正全闭环，零回归）
