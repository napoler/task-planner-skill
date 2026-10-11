# sub:17 code-runner-agent — 全量回归复跑（task-v169 Phase 4 收口单元，VC-6 前半）

- 命令: cd /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner && bash scripts/run-selftests.sh
- 退出码: 0（EXIT=0 实测）
- 末行: Total: 78 PASS=78 FAIL=0 (run=0 reused=78)
- Failed 行: 不存在（日志 grep -c '^Failed'=0；FAIL=[1-9] 套件行=0）
- 套件行计数: 78（含新增件 [reused] selftest-session-log (rc=0 PASS=10 FAIL=0)，日志 :58）
- 备注: 78 项均为指纹未变 [reused] 缓存命中（run=0）；复用语义见 scripts/run-selftests.sh :8/:14（"指纹未变的脚本命中缓存即跳过重跑…rc/FAIL 数照缓存值入账"）；全量日志: /tmp/v169-regression-run.log
