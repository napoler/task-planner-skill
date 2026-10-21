# Verification Contract & Phase Gates

## Goal (1 sentence)

长上下文/压缩后技能执行规范遗忘问题的结构化补救落地：召回卡（execution-recall-card.md）+ Rule 93 双触发节奏 + 模板承载 + 全仓计数级联，合并回 master 且回归零增量。

---

## Verification Contract (≥5 items, objective standards)

> WT=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall（VC-1..6 于 worktree 内执行；VC-7/8 于主仓执行）

- [ ] VC-1: 召回卡在位且 ≤120 行、A-F 六节、条目锚 ≥20
  **Verify command**: `WT=/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall; test -f $WT/skills/task-discipline/references/execution-recall-card.md && [ $(wc -l < $WT/skills/task-discipline/references/execution-recall-card.md) -le 120 ] && [ $(grep -c "^- " $WT/skills/task-discipline/references/execution-recall-card.md) -ge 20 ] && echo VC1-PASS`
  Evidence: 命令输出 VC1-PASS
- [ ] VC-2: Rule 93 子条锚 ≥6 且既有条款零删除（纯追加）
  **Verify command**: `grep -c "^93\." $WT/skills/task-discipline/references/critical-rules-discipline.md`（≥6）；`git -C $WT diff master -- skills/task-discipline/references/critical-rules-discipline.md | grep -c "^-[^-]"`（=0）
  Evidence: 两个命令输出
- [ ] VC-3: task-planner SKILL.md 接线在位
  **Verify command**: `[ $(grep -c "3g 规范召回" $WT/skills/task-planner/SKILL.md) -eq 1 ] && [ $(grep -c "execution-recall-card" $WT/skills/task-planner/SKILL.md) -ge 1 ] && echo VC3-PASS`
  Evidence: 命令输出 VC3-PASS
- [ ] VC-4: 计数级联一致（权威面 1-92 零残留+路由行含 93；README/docs 当前声明行已更新且历史叙述仅余 2 处）
  **Verify command**: `[ $(grep -rn "Rules 1-92" $WT/skills/task-planner/SKILL.md $WT/skills/task-planner/references/ $WT/README_zh.md $WT/CLAUDE.md | wc -l) -eq 0 ] && [ $(grep -c ",93" $WT/skills/task-planner/references/critical-rules.md) -ge 1 ] && [ $(grep -h "Rules 1-92" $WT/skills/task-planner/README.md $WT/skills/task-planner/docs/ARCHITECTURE.md | wc -l) -eq 2 ] && echo VC4-PASS`
  Evidence: 命令输出 VC4-PASS（口径注：README.md/ARCHITECTURE.md 各保留 1 处历史叙述字面——ARCHITECTURE :4 的 task-v191 时点注释与 :121 演进史条目；已在 CA-9 登记）
- [ ] VC-5: task_plan 模板召回行在位
  **Verify command**: `[ $(grep -c "规范召回" $WT/skills/task-planner/templates/task_plan.md) -ge 1 ] && echo VC5-PASS`
  Evidence: 命令输出 VC5-PASS
- [ ] VC-6: selftest 回归零增量（改后 FAIL 总数 ≤ 改前基线）
  **Verify command**: `bash $WT/skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -5`（改前基线存 subagent-state/selftest-baseline.txt，两值对照记 progress）
  Evidence: 基线/改后两份输出
- [ ] VC-7: 编号账本 landed
  **Verify command**: `grep '"rule":93' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl | grep landed | grep task-v195`
  Evidence: 命令输出
- [ ] VC-8: 合并回 master+worktree 清理完成
  **Verify command**: `git -C /mnt/data/dev/task-planner-skill log --oneline master -3 | grep -c spec-recall`（≥1）；`git -C /mnt/data/dev/task-planner-skill worktree list | grep -c task-v195-spec-recall`（=0）
  Evidence: 两个命令输出

---

## Phase Gates

### Phase 1: discipline 域落地（召回卡 + Rule 93）

**Goal**: 召回卡新文件 + Rule 93 条款 + discipline SKILL.md 计数行落 worktree

**Depends on**: none

**Done when**:
- [ ] S1/S2 产出在位且主进程 Read 复核通过

**Verification** (run before moving on):
- [ ] V-1.1: VC-1 命令 → VC1-PASS（映射 VC-1）
- [ ] V-1.2: VC-2 两条命令 → ≥6 与 =0（映射 VC-2）

Status: `pending` Last verified: —

---

### Phase 2: planner 接线与全仓计数级联

**Goal**: SKILL.md 3g 步骤 + 纪元计数级联 + 模板召回行落 worktree

**Depends on**: Phase 1

**Done when**:
- [ ] S3/S4/S5 产出在位且主进程 Read 复核通过

**Verification**:
- [ ] V-2.1: VC-3 + VC-4 命令 → PASS（映射 VC-3/VC-4）
- [ ] V-2.2: VC-5 命令 → PASS（映射 VC-5）

Status: `pending` Last verified: —

---

### Phase 3: 回归验证 + 独立审查

**Goal**: selftest 零增量 + critic 审查 APPROVED

**Depends on**: Phase 2

**Done when**:
- [ ] S6/S7 结论回收并处置

**Verification**:
- [ ] V-3.1: VC-6 基线/改后两值 → 改后 ≤ 基线（映射 VC-6）
- [ ] V-3.2: S7 critic 结论行 = APPROVED（映射 VC-2/3/4/5 全面复核）

Status: `pending` Last verified: —

---

### Phase 4: 合并收口与交付

**Goal**: 合并回 master + land 93 + 簿记归档 + 交付总结

**Depends on**: Phase 3

**Done when**:
- [ ] check-complete exit 0 + 归档执行

**Verification**:
- [ ] V-4.1: VC-7 命令 → landed 行（映射 VC-7）
- [ ] V-4.2: VC-8 两条命令 → PASS（映射 VC-8）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| critical-rules-discipline.md（格式+92 尾锚） | diff 显示纯追加、条目格式与 92 同构 | 待终验 |
| task-planner SKILL.md（锚位） | 3g 与 3f 同层、计数行与 v181 判例同构 | 待终验 |
| 两份侦察检查点 | 设计决策可溯源至检查点结论 | 待终验 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：

```bash
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v195-spec-recall
```

JSON 输出：
```json
{终验时粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 4=① git 编排+② 簿记）
- [ ] 委派率 ≥ 0.7（计划预估 3/4=0.75；以 stats 机器输出为准）

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 规范召回机制落地
对照 Verification Contract 逐条复验（VC-1 至 VC-8 共 8 项，证据见上方各条）：

 outcome: COMPLETE / PARTIAL / BLOCKED
```

> **验证独立性**：终验核查动作（S6 回归/S7 审查）由独立子代理执行，主进程仅编排与簿记（Rule 33.3）。

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
