# Verification Contract & Phase Gates

## Goal (1 sentence)

Karpathy AGENTS.md 六组行为准则以 Rule 87 文本条款落入 task-planner skill（执行纪律域），差异点全量对齐处置，selftest 全量零回归。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 87 全文落盘执行纪律域文件，七组原则各有对应子条（87.1-87.8 齐备）
  **Verify command**: grep -cE "^### 87 |87\.[0-9]" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md
  Evidence: grep 计数 ≥9 + Read 子条与 user-session-log.md #1 原文逐组对照记录（progress.md）
- [ ] VC-2: 对齐矩阵覆盖规范全部条目，每个差异点均有显式处置（已对齐映射/管辖二分/增量条款），处置列无空值
  **Verify command**: grep -c "处置" /mnt/data/dev/task-planner-skill/plans/task-v179/findings.md
  Evidence: findings.md 对齐矩阵节（矩阵行 ≥20，处置列全非空，Read 复核）
- [ ] VC-3: 规则编号 87 预留+land 成功无撞号
  **Verify command**: grep -c '"rule":87' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl
  Evidence: 计数=2（reserved+landed 各一行）
- [ ] VC-4: 全量 selftest 零回归：worktree 内 run-selftests.sh 全量 FAIL=0
  **Verify command**: cd /mnt/data/dev/task-planner-skill-worktrees/task-v179 && bash skills/task-planner/scripts/run-selftests.sh
  Evidence: 汇总输出 Total/PASS/FAIL=0 落 progress.md（基线 81 脚本）
- [ ] VC-5: 索引级联同步：SKILL.md 全集索引 1-87、其余 73 条、域清单含 87；live 面 1-86 字面清零
  **Verify command**: grep -c "1-87" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
  Evidence: 计数 ≥1 且 `grep -rn "1-86" skills/*/SKILL.md skills/*/references/critical-rules*.md | grep -v archive | wc -l`=0
- [ ] VC-6: 合并回 master+worktree/分支清理完成
  **Verify command**: git -C /mnt/data/dev/task-planner-skill worktree list && git -C /mnt/data/dev/task-planner-skill branch --list "wt/task-v179"
  Evidence: worktree list 无 task-v179 残留+分支清单空+git log 含 Rule 87 提交

---

## Phase Gates

### Phase 1: 规范解析与对齐矩阵

**Goal**: 产出 Karpathy 六组原则×skill 现行规则对齐矩阵（差异三态+处置建议）

**Depends on**: none

**Done when**:
- [ ] 矩阵 checkpoint 落盘（subagent-state/1-explore.md，≤100 行）+findings.md 回填

**Verification** (run before moving on):
- [ ] V-1.1: 矩阵行 ≥20 且六组原则全覆盖（映射 VC-2）
- [ ] V-1.2: 每行带 file:line 锚且处置建议非空（映射 VC-2）

Status: `in_progress` Last verified: 2026-10-16

---

### Phase 2: Rule 87 条款设计与编号预留

**Goal**: 七子条草案定稿+87 编号预留无撞号

**Depends on**: Phase 1

**Done when**:
- [ ] 草案落 findings.md；rule-reserve reserve 87 成功

**Verification**:
- [ ] V-2.1: reserve 输出无冲突（映射 VC-3）
- [ ] V-2.2: 七子条覆盖六组原则+处置登记（映射 VC-2）

Status: `pending` Last verified: —

---

### Phase 3: worktree 隔离实施

**Goal**: worktree 内 Rule 87 全文+索引级联落盘

**Depends on**: Phase 2

**Done when**:
- [ ] CA-1..CA-4 全部落地，worktree 内 grep 断言过

**Verification**:
- [ ] V-3.1: grep 87.x 计数 ≥8（映射 VC-1）
- [ ] V-3.2: grep 1-87 命中且 1-86 live 面清零（映射 VC-5）

Status: `pending` Last verified: —

---

### Phase 4: 回归验证

**Goal**: worktree 内全量 selftest FAIL=0

**Depends on**: Phase 3

**Done when**:
- [ ] run-selftests.sh 汇总 FAIL=0 落 progress.md

**Verification**:
- [ ] V-4.1: selftest ΣFAIL=0（映射 VC-4）
- [ ] V-4.2: 炸红修复逐文件登记 CA-6（映射 VC-4）

Status: `pending` Last verified: —

---

### Phase 5: 合并归档交付

**Goal**: master 合并+清理+归档+对齐审查+交付总结

**Depends on**: Phase 4

**Done when**:
- [ ] 全 VC 复验 PASS+alignment-review 结论+归档完成

**Verification**:
- [ ] V-5.1: worktree/分支清理断言（映射 VC-6）
- [ ] V-5.2: reservations 87 land（映射 VC-3）

Status: `pending` Last verified: —

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
## Goal Verification — Karpathy 六组准则以 Rule 87 落入 skill 并全量对齐
对照 Verification Contract 逐条复验（结果记录）：
- VC-1: {evidence} → PASS/FAIL
- VC-2: {evidence} → PASS/FAIL
- VC-3: {evidence} → PASS/FAIL
- VC-4: {evidence} → PASS/FAIL
- VC-5: {evidence} → PASS/FAIL
- VC-6: {evidence} → PASS/FAIL

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
