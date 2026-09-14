# Verification Contract & Phase Gates

## Goal (1 sentence)

把部署位的 plan-resume v0.5.1 改进收编回 canonical（原样、worktree 隔离、smoke 39/39）并提交合并（master 48340c0），重部署 2 个 plan-resume 部署位，9/9 位 diff 终验一致。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: canonical select-and-resume.sh 与部署位 v0.5.1 版本一致（收编完整零改写）
  Evidence: worktree 内 `diff -q` = IDENTICAL；master 48340c0 上 grep "v0.5.1 改进" ×1
- [x] VC-2: plan-resume smoke 回归通过
  Evidence: worktree 内 `bash skills/plan-resume/tests/smoke.sh` = **39/39 PASS, FAIL=0**
- [x] VC-3: master 收到 --no-ff 合并 + worktree/分支清理
  Evidence: merge commit **48340c0**（1 file, +22/−1, e87cde5 收编 commit）；`git worktree list` 仅主仓；分支已删（was e87cde5）
- [x] VC-4: 2 个 plan-resume 部署位与 canonical 一致,9/9 位终验 IDENTICAL
  Evidence: 重部署后 diff -rq ×9 = 9/9 IDENTICAL（drift=0）；v0.5.1 在 claude/agents 双位 grep 命中
- [x] VC-5: canonical 除收编外零副作用 + 记忆基线更新
  Evidence: `git show --stat HEAD` 仅 select-and-resume.sh 1 文件；skills/ porcelain 空；记忆 deploy-flow（description+基线行→48340c0+v0.5.1 教训）与 MEMORY.md 索引行已更新并 Read 复核

---

## Phase Gates

### Phase 1: 计划初始化与 worktree 建立
**Done when**: [x] 计划+attest 556a1bd4+worktree @ 8732dd9+漂移稳定性确认
**Verification**: [x] V-1.1 mtime 稳定 [x] V-1.2 worktree 建立成功
Status: `complete` Last verified: 2026-09-05

### Phase 2: 收编 + 提交 + 合并回
**Done when**: [x] 收编零改写+smoke 39/39+commit e87cde5+merge 48340c0+清理
**Verification**: [x] V-2.1 VC-1 [x] V-2.2 VC-2 [x] V-2.3 VC-3
Status: `complete` Last verified: 2026-09-05

### Phase 3: 全平台部署 + 9 位终验 + 簿记 + 交付
**Done when**: [x] 备份+2 位重部署+9/9 IDENTICAL+记忆/INDEX 更新
**Verification**: [x] V-3.1 VC-4 [x] V-3.2 VC-5 [x] V-3.3 check-complete exit 0
Status: `complete` Last verified: 2026-09-05

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| v0.5.1 差异全文 | 逐行审读逻辑自洽性（降级/防空/双标记复查）后才收编 | 符合 |
| 部署 SOP（memory） | rm+cp -rL+diff -r 范式;备份在扫描路径外;verify.sh 未使用 | 符合 |
| plan-resume smoke | 收编提交前实跑,39/39 通过后才 merge | 符合 |

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 0 / 总数 3
- [x] 主进程直做 Phase 均登记例外理由（编排/单文件拷贝零编辑判断/机械替换+簿记）
- [x] 0% 均有登记理由 → 不触发 PARTIAL 降级

## 质量门控统计（Rule 26）
- [x] Q1-Q6:触发 0,豁免 0,未处置 0（Q1 VC 5/5 带证据;Q2 Test Results 全填;Q3 抽查 3 条可复现:48340c0 show --stat/9 位 diff 输出/smoke 输出;Q4 无子代理;Q5 见委派统计;Q6 非批量）
- [x] Rule 27 dogfood:收编产物按 27.1 逐 Phase 提交（e87cde5）,27.5 终验 skills/ porcelain 空 ✓
- [x] 无未处置违规

## Goal Gate (终验)

```
## Goal Verification — plan-resume v0.5.1 收编 + 全平台部署
- [x] VC-1: 收编零改写（diff IDENTICAL）→ PASS
- [x] VC-2: smoke 39/39 PASS → PASS
- [x] VC-3: merge 48340c0 + worktree/分支清理 → PASS
- [x] VC-4: 9/9 位 IDENTICAL（drift=0）→ PASS
- [x] VC-5: canonical 单文件副作用 + 记忆更新 → PASS

 outcome: COMPLETE
```

**遗留（不影响 COMPLETE）**：
1. plans/INDEX.md 中 task-active-plan 陈旧 in_progress 行仍未核销（连续三个任务同认,建议单独小任务清理）
2. [plan-compass] 对已终态计划的陈旧报警（task-deploy-9b167fe）——建议 hook 侧跳过 outcome=COMPLETE 的计划（可并入既有 hook 缺陷批次）

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
