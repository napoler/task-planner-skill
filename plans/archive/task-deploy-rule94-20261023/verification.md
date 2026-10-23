# Verification Contract & Phase Gates

## Goal (1 sentence)

dev 仓 master 的 Rule 94 成果（7 文件）同步到 zcode/cursor 两部署位并机器验证 diff=0、锚在位、运行态零触碰。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.

- [ ] VC-1: 7 文件 ×2 部署位与 dev 仓 master 逐字一致（diff 静默=0 差异）
  Evidence: 循环 diff 输出落 progress.md
  **Verify command**: for f in task-planner/SKILL.md task-planner/references/critical-rules.md task-planner/README.md task-planner/docs/ARCHITECTURE.md task-discipline/SKILL.md task-discipline/references/critical-rules-discipline.md task-discipline/references/execution-recall-card.md; do diff -q "/mnt/data/dev/task-planner-skill/skills/$f" "/home/terry/.zcode/skills/$f" && diff -q "/mnt/data/dev/task-planner-skill/skills/$f" "/home/terry/.cursor/skills/$f"; done
- [ ] VC-2: 部署位 Rule 94 锚在位（两位置）
  Evidence: grep 计数输出落 progress.md
  **Verify command**: grep -c "^### 94 任务专注性与计划隔离" /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md /home/terry/.cursor/skills/task-discipline/references/critical-rules-discipline.md && grep -c "确认切换后的处置（Rule 94" /home/terry/.zcode/skills/task-planner/SKILL.md /home/terry/.cursor/skills/task-planner/SKILL.md
- [ ] VC-3: 部署位运行态与射程外文件零触碰（zcode 剩余差异=0；cursor 剩余=既有 6 文件+运行态，不多不少）
  Evidence: diff -rq 全目录计数落 progress.md
  **Verify command**: diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.zcode/skills/task-planner | grep -v drift-rhythm | wc -l && diff -rq /mnt/data/dev/task-planner-skill/skills/task-planner /home/terry/.cursor/skills/task-planner | grep -v drift-rhythm | wc -l
- [ ] VC-4: 计划归档完成
  Evidence: archive 目录在位
  **Verify command**: ls -d /mnt/data/dev/task-planner-skill/plans/archive/task-deploy-rule94-20261023

---

## Phase Gates

### Phase 1: 漂移预检
**Goal**: 部署位布局与漂移面定界
**Depends on**: none
**Done when**:
- [ ] findings §1 含 7+6 清单与布局结论
**Verification**:
- V-1.1: findings §1 三段清单在位（→VC-3 基线）
Status: `complete` Last verified: 2026-10-23

### Phase 2: 同步执行
**Goal**: 14 文件 cp 同步
**Depends on**: Phase 1
**Done when**:
- [ ] 14 cp rc=0
**Verification**:
- V-2.1: VC-1（diff 逐文件静默）
Status: `pending` Last verified: —

### Phase 3: 验证收口+归档
**Goal**: VC 全 PASS+归档
**Depends on**: Phase 2
**Done when**:
- [ ] 验证合同前三项全 PASS + archive 在位
**Verification**:
- V-3.1: VC-2/VC-3 命令实跑
- V-3.2: VC-4 archive 在位
Status: `pending` Last verified: —

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 漂移侦察结论（findings §1） | VC-3 剩余差异 vs 侦察基线对照 | 终验填 |

## 委派统计复验（Rule 25.4）
- [x] 主进程直做 Phase 均登记白名单例外理由（①机械部署编排/②簿记侦察验证；L0-E 口径=零 dev 仓受管变更）
- [x] 机械部署任务全白名单直做，产出落仓外部署位（非仓库受管区）

## 质量门控统计（Rule 26）
- [x] Q1-Q6: 触发 0 项（机械 diff 验证）
- [x] Evidence 抽查: VC-1 diff / VC-2 grep 双锚（可复现）
- [x] 豁免登记: 无

## Goal Gate (终验)
```
## Goal Verification — Rule 94 部署同步
- VC-1: {evidence} → PASS/FAIL
- VC-2: {evidence} → PASS/FAIL
- VC-3: {evidence} → PASS/FAIL
- VC-4: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过 → 交付。

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
