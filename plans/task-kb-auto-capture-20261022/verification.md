# Verification Contract & Phase Gates

## Goal (1 sentence)

任务模板 Phase 5 收尾内建归档+知识提取两步，新任务 init 即携带，执行体收尾主动提取

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: repo 模板 Phase 5 含归档+知识提取末两步且纯插入（+3 行 0 删除，grep=2）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -c "Archive plan\|知识提取入库" skills/task-planner/templates/task_plan.md
  Evidence: （执行后填，≥2）
- [x] VC-2: 项目级覆盖与 repo 模板逐字一致（diff 空）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && diff .zcode/plan-templates/task_plan.md skills/task-planner/templates/task_plan.md && echo VC2-PASS
  Evidence: （执行后填）
- [x] VC-3: worktree init 冒烟——新计划收尾含两步（生成 task_plan.md:353/:355）
  **Verify command**: cd <worktree> && mkdir -p plans/tmp-smoke && cd plans/tmp-smoke && bash /home/terry/.zcode/skills/task-planner/scripts/init-session.sh >/dev/null 2>&1 && grep -c "Archive plan\|知识提取入库" task_plan.md
  Evidence: （执行后填，≥2）
- [x] VC-4: 全量 selftest 零回归（92/92，6 模板守卫逐一 PASS）
  **Verify command**: cd <worktree> && for f in skills/task-planner/scripts/selftest-*.sh; do timeout 60 bash "$f" >/dev/null 2>&1 || echo "FAIL:$f"; done; echo DONE
  Evidence: （执行后填，FAIL 计数=0）
- [x] VC-5: 合并回后主仓生效+部署位零改动（merged a0c09cf；部署位 mtime 未变）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && diff .zcode/plan-templates/task_plan.md skills/task-planner/templates/task_plan.md && git log --oneline -1 && ls -la /home/terry/.zcode/skills/task-planner/templates/task_plan.md
  Evidence: （执行后填，部署位 mtime/内容与任务前一致）

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

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
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
## Goal Verification — 模板收尾两步内建（归档→知识提取）
对照 Verification Contract 逐条复验（2026-10-22 主仓 a0c09cf）：
- VC-1: grep=2 + git diff +3/-0 → PASS
- VC-2: diff 为空 → PASS
- VC-3: init 冒烟 :353/:355 含两步 → PASS
- VC-4: 92/92 PASS（subagent-state/P1-S4-code-runner.md）→ PASS
- VC-5: 主仓 diff 一致 + 部署位未动 → PASS

 outcome: **COMPLETE**（R1 solved：新任务 init 即携带收尾两步，知识提取主动触发；R2 手段落地即用户点名的最简载体）

## 58.5 裁决供料
| 字段 | 值 |
|------|-----|
| 裁决 | solved（R1 目标型：主动触发载体生效实证=VC-3 冒烟；R2 手段型=用户点名载体逐字落地=VC-1/2） |
| 证据锚 | verification.md 本区块 + progress.md Test Results + subagent-state/P1-S4-code-runner.md |
| 遗留 | 部署位同步（本仓覆盖已生效；其他项目需部署位更新后才能用通用条件式两步）；覆盖文件在部署位同步后可删回单一源 |
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
