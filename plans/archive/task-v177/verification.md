# Verification Contract & Phase Gates

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 86 全文在位（四分类闸+禁问面+三件套，子条 ≥4）
  Evidence: `grep -cE "^### 86\.[0-9]" skills/task-discipline/references/critical-rules-discipline.md` ≥4 + Read 四分类段
  **Verify command**: `grep -cE "^### 86\.[0-9]" skills/task-discipline/references/critical-rules-discipline.md`
- [ ] VC-2: 新 selftest-rule86 守护全 PASS（含反例断言）
  Evidence: 运行输出 Total PASS FAIL=0
  **Verify command**: `bash skills/task-planner/scripts/selftest-rule86-autonomous-decision.sh`
- [ ] VC-3: media SOP 段在位（自主迭代取优+禁抛重抽选项）
  Evidence: grep 关键词命中 + Read SOP 段
  **Verify command**: `grep -c "自主迭代\|N 轮\|淘汰记录" skills/media-planner/references/critical-rules-media.md`
- [ ] VC-4: 全量 selftest FAIL=0（81→82+ 脚本）
  Evidence: run-selftests 尾行
  **Verify command**: `bash skills/task-planner/scripts/run-selftests.sh --fresh`
- [ ] VC-5: 三部署位 diff=0
  Evidence: 三个 wc -l =0 输出
  **Verify command**: `diff -rq skills/task-planner ~/.zcode/skills/task-planner | wc -l`

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: 落点表在位（Rule 44 边界+AskUserQuestion 触点≥6 处 file:line）— mapped to VC-1
  **Verify command**: `grep -c "^- \|file:" plans/task-v177/subagent-state/1-explore.md`
- [ ] V-1.2: Rule 86 草稿四分类闸齐备 — mapped to VC-1
  **Verify command**: `grep -c "可测\|偏好\|不可逆\|预算\|合规" plans/task-v177/findings.md`

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
