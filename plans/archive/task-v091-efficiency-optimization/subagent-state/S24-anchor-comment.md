# S24 A-2 checkpoint — 38.4③ 锚点口径注释对齐

- status: done (commit 40a1880 @ wt/task-v091-efficiency-optimization, parent 9026ca9)
- 改动: worktree `skills/task-planner/references/critical-rules.md:338` Rule 38.4③ 行内括注纯增 359 字符（口径注释 [2026-09-27 task-v091 S24 A-2]：锚③仅免委派率统计格式要求、floor→0.0 使 rate 恒≥floor、25.4a 白名单分支 mini 下不可达、放行本体在 25.4a；④ 是无 Executor 行 Phase 从严判定的 MINI_EXEMPT 活豁免，③④ 并存非冗余）。脚本零改动，零删除零语义变更（366 行不变）。
- 纯增证明: 剥离括注后与 HEAD:338 逐字节一致（确定性重构法 PASS）；git diff --stat = 1 file, 1 insertion 1 deletion（同行内插入）。
- 夹具验证（/tmp/s24-a2-fixture/）: mini+无 Executor 行 Phase → rc=0 含「✓ 1 个派发型 Phase 均有带执行体的 S-unit 表」（MINI_EXEMPT 活分支）；同结构 standard → rc=1「✗ Phase 2: 缺 S-unit 表或数据行」（活豁免实证，等价提案 sed '178,180d' 实验）；零 Executor 行全文 → legacy rc=0。
- selftest: selftest-plan-tier.sh Total: 32 PASS=32 FAIL=0（PT-05 38.4 锚断言含「零影响铁律」+「VC 最低要求 5→2」未受影响）；selftest-template-lifecycle.sh Total: 18 PASS=18 FAIL=0（grep 确认只锚 Rule 34，非 38.4 消费方）。
- next: S24 后续项或主进程合并流程；无遗留风险。
