# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

终验交付链落「收尾回读梳理迭代」强制步骤（84.14）：交付前全量回读五文档体系互洽检查，偏移→迭代→再梳理，收敛后出 outcome。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: 84.14 条款+SKILL 终验链步骤在位（迭代环+收敛出口+五文档读取面）
  Evidence: grep 锚命中+条款文本 Read
  **Verify command**: WT=/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105; grep -q "84.14" $WT/skills/verification-gate/references/critical-rules-verification.md && grep -q "收尾回读梳理" $WT/skills/verification-gate/references/critical-rules-verification.md && grep -q "收尾回读梳理" $WT/skills/task-planner/SKILL.md && echo VC1-PASS
- [ ] VC-2: 模板三处承载在位（task_plan 梳理记录区块/delivery-summary 结论行/专档消费点⑥行）
  Evidence: grep 三模板锚
  **Verify command**: WT=/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105; grep -q "收尾回读梳理记录" $WT/skills/task-planner/templates/task_plan.md && grep -q "回读梳理结论" $WT/skills/task-planner/templates/delivery-summary.md && grep -q "⑥ 收尾回读" $WT/skills/task-planner/templates/user-session-log.md && echo VC2-PASS
- [ ] VC-3: todo-sync S4 前置引用在位
  Evidence: grep 锚
  **Verify command**: WT=/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105; grep -q "收尾回读" $WT/skills/task-planner/references/todo-sync.md && echo VC3-PASS
- [ ] VC-4: selftest 扩断言后全绿
  Evidence: 两 selftest 输出 0 FAIL
  **Verify command**: WT=/mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105; bash $WT/skills/task-planner/scripts/selftest-session-log.sh 2>&1 | tail -1 && ls $WT/skills/verification-gate/scripts/selftest-verification-gate.sh 2>/dev/null && bash $WT/skills/verification-gate/scripts/selftest-verification-gate.sh 2>&1 | tail -1 || echo "V-selftest 不存在时以 SL 系为准"
- [ ] VC-5: 全量 selftest 与 master 基线一致
  Evidence: worktree vs master FAIL 清单差集空
  **Verify command**: cd /mnt/data/dev/task-planner-skill-worktrees/task-finalrecall-20261105 && for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f" >/dev/null 2>&1 || echo "FAIL: $f"; done; echo VC5-DONE
- [ ] VC-6: 部署 3 位 diff=0
  Evidence: 3 位改动文件 0 diff
  **Verify command**: cd /mnt/data/dev/task-planner-skill && for f in skills/verification-gate/references/critical-rules-verification.md skills/task-planner/SKILL.md skills/task-planner/templates/task_plan.md skills/task-planner/templates/delivery-summary.md skills/task-planner/templates/user-session-log.md skills/task-planner/references/todo-sync.md; do diff -q "$f" "/home/terry/.zcode/$f" >/dev/null && diff -q "$f" "/home/terry/.claude/$f" >/dev/null && diff -q "$f" "/home/terry/.cursor/$f" >/dev/null || echo "DIFF: $f"; done; echo VC6-DONE
- [ ] VC-7: worktree 合并回+清理
  Evidence: git log merge commit+worktree list 无残留
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git log --oneline -2 && (git worktree list | grep -q finalrecall && echo "WORKTREE-REMAINS" || echo CLEAN)

---

## Phase Gates

### Phase 1: 调研缺口定位

**Goal**: 终验链与回读缺口盘点

**Depends on**: [previous phase or "none"]

**Done when**:
- [x] 检查点落盘+落点建议

**Verification** (run before moving on):
- [x] V-1.1: VC-1（缺口清单=落点依据）
- [x] V-1.2: VC-4（分工互斥设计）

Status: `complete` Last verified: 2026-11-05n_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: 设计定稿与计划审批

**Goal**: 84.14 条款设计+审批

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [x] V-2.1: VC-1（attest 一次锁定）
- [x] V-2.2: CA-1..CA-6 登记

Status: `complete` Last verified: 2026-11-05nner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

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
- [ ] VCx: {evidence} → PASS/FAIL（VCx=VC-1..VC-7 逐条）
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
