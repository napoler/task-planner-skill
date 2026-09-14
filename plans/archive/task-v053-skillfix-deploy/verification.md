# Verification Contract & Phase Gates

## Goal (1 sentence)

对 canonical 仓 task-planner 技能完成 skill-fix 全流程审计与批修（8+ 项已诊断缺陷），worktree 内修复并验证后合并 master、推送 GitHub（origin/master），并完成 task-planner×3 部署位重部署 + 全部 9 位 diff -r 复验。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 审计报告含 8+ 缺陷逐项 file:line 取证（含"修复前"实测证据）
  Evidence: subagent-state/01-general-purpose.md §B（8/8 表格+摘录）§F（/tmp/scope_test.md buggy 1 行 vs 状态机 3 行等实测）;主进程已 Read 复核（W2）
- [x] VC-2: awk scope 修复后实测提取非空（gawk 5.2）
  Evidence: 检查点 02 修复1（buggy 0 行→状态机 4 行）;生产位部署后对真实 v053 计划提取返回完整表格行;INDEX.md task-active-plan 行 scope 列首次被填充
- [x] VC-3: verify.sh 修复后对实体副本部署位不再误报 fail
  Evidence: 检查点 02 修复3（--help exit 0;三态分支命中）;部署位终验 `TASK_PLANNER_ROOT=~/.zcode/skills/task-planner bash lib/verify.sh` → 20 pass / 0 fail（原:静默空输出）
- [x] VC-4: git diff 范围与锁定清单一致（无范围外文件）
  Evidence: worktree 提交 8ad79b6 恰好 7 文件（5 脚本+2 文档,全在 scope 表）;git status 干净
- [x] VC-5: tests/smoke.sh 回归全过
  Evidence: worktree 两轮 17 pass/0 fail exit 0;合并后 master 再跑 17 pass/0 fail
- [x] VC-6: master 合并 + origin/master 同步
  Evidence: merge commit 19a40ca;push e126e04..19a40ca;`git rev-list --count origin/master..master` = 0
- [x] VC-7: 9 部署位 diff -r 全 IDENTICAL
  Evidence: 终验 9/9 IDENTICAL 输出（task-planner×3 已更新+新标记抽查 ×3;其余 6 位不变）;备份 /tmp/deploy-backup-task-v053/（3 tar 各 182K）
- [x] VC-8: worktree+分支清理完成,INDEX/记忆/三文件簿记齐
  Evidence: `git worktree list` 仅主仓;`git branch -a | grep wt/` = 0;INDEX.md 经修复后 sync-todos --index 刷新（v053 登记）;记忆 ×3 更新;deferred-issues.log 落盘

---

## Phase Gates

### Phase 1: 审计
**Goal**: 8 项已知缺陷取证 + 新缺陷扫描（只读）
**Depends on**: none
**Done when**: 检查点落盘且主进程 Read 复核
**Verification**:
- [x] V-1.1: 检查点 01 七段齐全（A/B/C/D/E/F/G）
- [x] V-1.2: 8/8 缺陷 file:line+摘录,3 项实测实锤
Status: `complete` Last verified: 2026-09-06

### Phase 2: 脚本批次修复
**Goal**: awk×4/init-session 守卫/verify.sh 三态+main/check-complete porcelain 预检
**Depends on**: Phase 1
**Verification**:
- [x] V-2.1: bash -n 全过 + smoke 17/0
- [x] V-2.2: 各修复项验证证据落检查点 02
Status: `complete` Last verified: 2026-09-06

### Phase 3: 文档批次修复
**Goal**: 6 项文档缺陷（frontmatter/Rule 10/14/16/21.5/27.3）
**Depends on**: Phase 1
**Verification**:
- [x] V-3.1: 21.5 计数=1;frontmatter 2 条新增 grep 命中;S62 无悬空
- [x] V-3.2: 恰好 2 文件 modified;template-mapping.md 零改动
Status: `complete`（重派轮 2） Last verified: 2026-09-07

### Phase 4: 验证
**Goal**: 回归+专项+S61/S62
**Depends on**: Phase 2/3
**Verification**:
- [x] V-4.1: porcelain 预检合成仓三分支实测（2 paths clean/脏 exit 1/仓外 skip）
- [x] V-4.2: 主进程 3 处边界修补（仓外路径/、切词/裸文件名）全部带注释+实测
Status: `complete` Last verified: 2026-09-07

### Phase 5: 合并+GitHub+部署
**Goal**: master 合并+推送+9 位部署一致
**Depends on**: Phase 4
**Verification**:
- [x] V-5.1: merge 19a40ca+push ahead=0+worktree/分支清零
- [x] V-5.2: 9/9 IDENTICAL+生效抽查+部署位 verify.sh 20/0
Status: `complete` Last verified: 2026-09-07

### Phase 6: 簿记收尾
**Goal**: INDEX/记忆/deferred/总结
**Depends on**: Phase 5
**Verification**:
- [x] V-6.1: INDEX 刷新（修复后脚本端到端 rc=0）
- [x] V-6.2: 记忆 ×3 + deferred-issues.log + S58 总结块
Status: `complete` Last verified: 2026-09-07

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| deploy-flow 记忆 | 部署 SOP 严格按 rm+cp -rL+diff -r;worktree 路径新规 | 符合 |
| known-defects 记忆 | 修复清单 6 项全部覆盖 | 符合 |
| awk-bug 记忆 | 状态机式替换,新 awk 提取点与 template-mapping §八对齐 | 符合 |
| skill-fix SKILL.md | Step 0 锚定/范围锁定/S59/S61/S62/S66/S74 执行 | 符合（S66 确定性修复豁免测试副本,已注明） |

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 4 / 总数 6（67%）
- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（P5=① git 编排;P6=② 簿记;P4 修补=验证驱动微修）
- [x] 委派率 67% 略低于 0.7 阈值,但缺口全部为白名单内职责（合并/部署/簿记天然主进程） → 依据 Rule 25.3 不降级（对齐 v052 先例:编排/簿记型任务属正常形态）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 3 项（三证据/S61/S62）,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:检查点 01/02/03 路径可 Read、结论可复现（主进程 grep 复核 ×2 轮）
- [x] 豁免登记:无
- [x] 存在未处置违规 → 无（交叠事故已在 Error Log 登记+重派修复,产出已验证）

## Goal Gate (终验)

```
## Goal Verification — skill-fix 批修+GitHub+9 位部署
对照 Verification Contract 逐条复验：
- [x] VC-1: 检查点 01 §B/§F → PASS
- [x] VC-2: 检查点 02+生产位提取非空 → PASS
- [x] VC-3: 部署位 verify.sh 20 pass/0 fail → PASS
- [x] VC-4: 提交 8ad79b6 恰 7 文件 → PASS
- [x] VC-5: smoke 17/0 ×3（worktree×2+master×1） → PASS
- [x] VC-6: 19a40ca+ahead=0 → PASS
- [x] VC-7: 9/9 IDENTICAL → PASS
- [x] VC-8: worktree 清零+簿记齐 → PASS

 outcome: COMPLETE
```

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 全 Phase complete,终验 COMPLETE |
| 2 | Where am I going? | 无（仅剩 commit plans 簿记+push） |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（task-active-plan 挂账,见 deferred-issues #4） |
