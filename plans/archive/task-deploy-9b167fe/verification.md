# Verification Contract & Phase Gates

## Goal (1 sentence)

以 canonical master 9b167fe 重部署 3 个 task-planner 部署位（zcode/claude/opencode），diff -r 终验 9/9 位字节级一致，6 兄弟位验证零改动，canonical 源码零写入。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 3 个 task-planner 部署位与 canonical(9b167fe) 字节级一致，WORKFLOW.md 不存在于部署位
  Evidence: 重部署后即时 diff -rq ×3 = 3/3 IDENTICAL；`ls <位>/WORKFLOW.md` 均不存在（删除已同步）；Rule 27 抽查部署位 SKILL.md 提及 ×5 与 canonical 一致
- [x] VC-2: 6 个兄弟部署位保持一致（本任务零改动）
  Evidence: 预检 diff -rq 6/6 IDENTICAL + 终验复验 6/6 IDENTICAL（两次独立核验）
- [x] VC-3: canonical 零改动
  Evidence: `git log -1` = 9b167fe；`git status --porcelain -- skills/` 为空
- [x] VC-4: 记忆基线更新
  Evidence: task-planner-repo-deploy-flow.md（description + 当前同步基线行 → 9b167fe 已部署 + 回滚点路径）；MEMORY.md 索引行同步（已 Read 复核两处）
- [x] VC-5: plans/INDEX.md 刷新且本任务入册
  Evidence: sync-todos --index 输出（complete=16,本任务在册终态）

---

## Phase Gates

### Phase 1: 计划初始化与预检
**Done when**: [x] 变更范围确认（仅 task-planner 8 files）+ 6 兄弟位预检 IDENTICAL + attest 873346ab
**Verification**: [x] V-1.1 git diff 范围证据 [x] V-1.2 兄弟位 diff ×6
Status: `complete` Last verified: 2026-09-05

### Phase 2: 备份 + 3 位重部署
**Done when**: [x] tar 备份 + 3 位 rm -rf/cp -rL + 即时复验
**Verification**: [x] V-2.1 即时 diff ×3 IDENTICAL [x] V-2.2 WORKFLOW.md 缺席 ×3
Status: `complete` Last verified: 2026-09-05

### Phase 3: 9 位终验 + 记忆/索引更新 + 交付
**Done when**: [x] 9/9 IDENTICAL + canonical 零改动 + 记忆/INDEX 更新
**Verification**: [x] V-3.1 终验 ×9 [x] V-3.2 check-complete exit 0
Status: `complete` Last verified: 2026-09-05

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 记忆 task-planner-repo-deploy-flow.md | 9 位拓扑照单执行;rm+cp+diff SOP 照做;verify.sh 未使用;备份放扫描路径外 | 符合 |
| 上次部署计划（SOP 先例） | 备份→rm→cp -rL→diff 范式与直发（非 worktree）决策沿用 | 符合 |

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 0 / 总数 3
- [x] 主进程直做 Phase 均登记例外理由（编排/机械三命令替换/终验）
- [x] 0% 均有登记理由 → 不触发 PARTIAL 降级

## 质量门控统计（Rule 26）
- [x] Q1-Q6:触发 0,豁免 0,未处置 0（Q1 VC 5/5 带证据;Q2 Test Results 全填;Q3 抽查 3 条可复现:tar 包存在/9 位 diff 输出/git log;Q4 无子代理;Q5 见委派统计;Q6 非批量）
- [x] Rule 27 git 提交核验:本任务 canonical 零改动、部署位在仓外无 git 语义——`git status --porcelain -- skills/` 为空 ✓
- [x] 无未处置违规

## Goal Gate (终验)

```
## Goal Verification — 全平台重部署 master 9b167fe
- [x] VC-1: 3 位 IDENTICAL + WORKFLOW.md 缺席 → PASS
- [x] VC-2: 6 兄弟位两次核验 IDENTICAL → PASS
- [x] VC-3: canonical 9b167fe + skills/ porcelain 空 → PASS
- [x] VC-4: 记忆 2 文件更新复核 → PASS
- [x] VC-5: INDEX 刷新入册 → PASS

 outcome: COMPLETE
```

**遗留（不影响 COMPLETE）**：
1. 旧 plans/INDEX.md 中 task-active-plan 行仍为陈旧 in_progress（实际已合并,历史簿记未核销,与前两次任务同认）
2. 回滚点 /tmp/deploy-backup-9b167fe/ 为临时目录,重启可能清除（canonical git 历史为最终回滚依据）

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 已交付（outcome: COMPLETE） |
| 2 | Where am I going? | 无剩余 Phase |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
