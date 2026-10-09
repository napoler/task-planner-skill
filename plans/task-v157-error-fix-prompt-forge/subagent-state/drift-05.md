status: done（降级路径：drift-checker provider 持续不可用 → Rule 61.5 check-drift.sh 佐证）

## 比对过程
- 锚1 Goal（新建 skill+selftest+部署+回归零 FAIL）↔ Phase 5 实际动作=CR 门+修复+合并回 6d46d3ec+三宿主 IDENTICAL+终验 COMPLETE → 符合
- 锚2 需求 R1/R2 ↔ 交付物=可用的 skill（四文件+部署+冒烟证据）→ 符合
- 锚3 scope ↔ Phase 5 写入=worktree 内 scope 文件+宿主部署位（install-companion/smart-merge-back 既有 SOP，非任务外文件）+本计划目录 → 符合

## 降级登记
- check-drift.sh 输出「[DRIFT] 无漂移，执行与计划对齐」exit=0；drift-checker 本会话 3 次 provider 拒已永久切 61.5（drift-02 登记）

## 最终结论

status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: none（只读检查+本检查点）
evidence: check-drift.sh 无漂移行;merge commit 6d46d3ec;MASTER-FINAL 68/836/FAIL=0;部署 diff IDENTICAL
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/drift-05.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
DRIFT_CHECK: ALIGNED | 锚1Goal:符合(交付全链闭环) | 锚2需求:符合(skill 可用性达成) | 锚3scope:符合(SOP 部署+计划目录) | 证据:check-drift.sh 无漂移行
