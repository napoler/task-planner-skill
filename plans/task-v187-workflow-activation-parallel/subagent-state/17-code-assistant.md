# [sub:cr-fix-m1] Code Assistant 检查点（task-v187 CR M-1 修复）

## 步骤与状态
- [x] 步骤 1 Read collab.md:28 全行——定位尾句「40.4 只增计划期建议登记面，不改 39.1「显式点名∨常设授权命中才路由」的触发纪律原文（Rule 36.5 纯增量）」（行内仅此一处旧句；S11 记录段所称 :28 双短语替换未见于本 worktree 实态，以 Read 为准）
- [x] 步骤 2 Edit 单句替换=任务指定新句逐字（39 段引言与 40.4 本体「建议登记面→主动路由义务」语义对齐；行内其余零动）
- [x] 步骤 3 验证三断言全过：grep -c "只增计划期建议登记面"=0；grep -c "主动路由义务（39.8 联动"=1；selftest-workflow-orchestration.sh 末行 `Total: 22 PASS=22 FAIL=0`
- [x] 步骤 4 findings.md 段末追加 `#### [sub:cr-fix-m1] M-1 修复记录`（≤4 行，禁改既有）

## 写入面
- worktree: skills/plan-collab-router/references/critical-rules-collab.md:28 单行内句替换（+1/-1）
- 主仓 plans: subagent-state/17-code-assistant.md（本检查点）+ findings.md 追加小节
- 其余零写入

## 状态
STATUS=done（2026-10-18，cr-fix-m1）
