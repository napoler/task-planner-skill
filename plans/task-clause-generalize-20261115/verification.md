# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

根治"判例特化条款"：三条款按 critic 授权清单（P1+P2+级联 15 项）完成泛化修订并清零消费点。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: 修订稿 clause-drafts-v2.md 在位且三条款 v2 标题串齐
  Evidence: plans/task-clause-generalize-20261115/clause-drafts-v2.md
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md && test $(grep -cE '94\.7 对象状态分区与规模跳变确认门|51\.14 完成声称操作类型与物理可行性门|64\.7 用户原话对照锚强制' /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md) -ge 3
- [ ] VC-2: 三主仓载体 v2 新串命中且既有锚零改动
  Evidence: 主仓 3 载体文件
  **Verify command**: test $(grep -c "94\.7 对象状态分区与规模跳变确认门" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -ge 1 && test $(grep -c "操作类型档位" /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md) -ge 1 && test $(grep -c "含目标/指令类内容的" /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md) -ge 1 && test $(grep -c "94\.6 机制（文本优先" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -eq 1 && test $(grep -c "51\.13 \*\*机制" /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md) -eq 1 && test $(grep -c "64\.6 \*\*零新 config 键" /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md) -eq 1
- [ ] VC-3: 级联面四点命中（零消费点清零）
  Evidence: SKILL.md/recall card/drift 64.4/discipline 94.5
  **Verify command**: test $(grep -c "51\.14" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md) -ge 1 && test $(grep -cE "94\.7|64\.7" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/execution-recall-card.md) -ge 1 && test $(grep -c "四锚输入" /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md) -ge 1 && test $(grep -c "94\.7 管范围静默扩张" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -ge 1
- [ ] VC-4: 全量回归 FAIL 集合 ⊆ 基线 9 项（基线=tmp/regression-final-20261115.txt）
  Evidence: tmp/regression-generalize-final.txt
  **Verify command**: bash /home/terry/.zcode/skills/task-planner/scripts/run-selftests.sh --fresh > /mnt/data/dev/task-planner-skill/tmp/regression-generalize-final.txt 2>&1; test "$(comm -13 <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-final-20261115.txt | awk '{print $2}' | sort -u) <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-generalize-final.txt | awk '{print $2}' | sort -u) | wc -l)" -eq 0
- [ ] VC-5: 部署 5 文件×3 位 diff=0
  Evidence: 逐对 diff -q 输出
  **Verify command**: for f in task-discipline/references/critical-rules-discipline.md task-planner/references/critical-rules.md task-drift-guard/references/critical-rules-drift.md task-planner/SKILL.md task-discipline/references/execution-recall-card.md; do diff -q "/mnt/data/dev/task-planner-skill/skills/$f" "/home/terry/.zcode/skills/$f" || exit 1; done && for f in task-discipline/references/critical-rules-discipline.md task-planner/references/critical-rules.md task-drift-guard/references/critical-rules-drift.md task-planner/SKILL.md task-discipline/references/execution-recall-card.md; do diff -q "/mnt/data/dev/task-planner-skill/skills/$f" "/home/terry/.claude/skills/$f" || exit 1; done && for f in task-discipline/references/critical-rules-discipline.md task-planner/references/critical-rules.md task-drift-guard/references/critical-rules-drift.md task-planner/SKILL.md task-discipline/references/execution-recall-card.md; do diff -q "/mnt/data/dev/task-planner-skill/skills/$f" "/home/terry/.cursor/skills/$f" || exit 1; done

---

## Phase Gates

### Phase 1: 修订稿起草（clause-drafts-v2）

**Goal**: 产出三条款 v2 全文+级联四点 edit spec（15 授权项逐项可指认）。

**Depends on**: none

**Done when**:
- [ ] clause-drafts-v2.md 落盘且 15 授权项逐项落位、三条款单行格式、判例锚保留

**Verification** (run before moving on):
- [ ] V-1.1: 修订稿在位且三标题串齐
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md && test $(grep -cE '94\.7 对象状态分区与规模跳变确认门|51\.14 完成声称操作类型与物理可行性门|64\.7 用户原话对照锚强制' /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md) -ge 3
- [ ] V-1.2: 15 授权项编号在草案中逐项可指认
  **Verify command**: test $(grep -cE 'G-[1-6]|C-[1-5]|D-[1-4]' /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md) -ge 12

Status: `in_progress` Last verified: 2026-11-15

---

### Phase 2: worktree 并行插改（gen-fix 4 并行）

**Goal**: 三条款 v2+级联四点在 worktree 五文件落位。

**Depends on**: Phase 1

**Done when**:
- [ ] 新串命中+既有锚零改动（git diff 仅授权面）

**Verification**:
- [ ] V-2.1: 三载体新串命中
  **Verify command**: 在 worktree 内执行 VC-2 同款 grep 组合（路径前缀 tmp/worktrees/task-clause-generalize-20261115/）
- [ ] V-2.2: 既有锚零改动
  **Verify command**: git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-clause-generalize-20261115 diff --stat 仅含 5 授权文件

Status: `pending` Last verified: —

---

### Phase 3: 独立复检+全量回归

**Goal**: 复检 APPROVED+部署后回归 FAIL 集合 ⊆ 基线 9 项。

**Depends on**: Phase 2

**Done when**:
- [ ] 复检检查点 verdict=APPROVED；回归 comm 子集判定通过

**Verification**:
- [ ] V-3.1: 回归子集判定
  **Verify command**: 见 VC-4（部署后执行）

Status: `pending` Last verified: —

---

### Phase 4: 合并回+部署同步+终验交付

**Goal**: 主仓合并+15 对部署 diff=0+三仓 push+归档。

**Depends on**: Phase 3

**Done when**:
- [ ] VC-5 全通过；归档 ARCHIVED

**Verification**:
- [ ] V-4.1: 部署对账
  **Verify command**: 见 VC-5

Status: `pending` Last verified: —

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
