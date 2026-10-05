# 28-executor — task-v131/Phase 7 CR 修复 B 批（3 文件=同一根因锚级联聚合）

- 状态: done（未 commit，按任务要求）
- worktree: /home/terry/task-planner-skill-worktrees/task-v131
- 范围: 仅 3 文件（SKILL.md / selftest-root-resolution.sh / selftest-agent-coverage.sh）

## S1 SKILL.md P1-2（索引行级联漏改）
- 位置: SKILL.md:266
- 改前: `详见 `references/critical-rules.md`（Rules 1-39（含 Rule 40/41/42/43/44/45/46/47/48/49/51））：`
- 改后: `详见 `references/critical-rules.md`（Rules 1-39（含 Rule 40-53 全集））：`
- 行内替换，git diff 仅 1 行 -/+，其余语义未动。
- 证据: `wc -l SKILL.md` = 477（改前 477，不变，行内替换 ✓）；`grep -n "含 Rule 40-53" SKILL.md` → `266:详见 …（含 Rule 40-53 全集）：`。

## S2 selftest-root-resolution.sh 新增 RR-16/RR-17（Total 15→17）
- 位置: selftest-root-resolution.sh:153-178（RR-15 后追加）；头部注释 :10 更新「RR-01..RR-15 十五」→「RR-01..RR-17 十七」。
- RR-16: 索引行定位锚 `grep -cF '（Rules 1-39'` =1，且该行须含「Rule 40-53」；兜底判定=若为逐号式括注则至少含 50 与 53 两个号（防下次级联漏改，CR P1-2 判例钉住）。
- RR-17: `grep -c '^### 53 '` =1（critical-rules.md 侧区块锚，索引行 40-53 全集的条款侧落点，防挂空锚；实测 critical-rules.md:580 `### 53 根源解决与决策管辖` 命中 =1）。
- 证据: 重跑输出 `Total: 17 PASS=17 FAIL=0`，rc=0；`RR-16 PASS … 含「Rule 40-53」全集括注（CR P1-2 防级联漏改）`、`RR-17 PASS …「^### 53 」=1`。

## S3 selftest-agent-coverage.sh P2-1（AC-09 精确断言→上界断言）
- 位置: selftest-agent-coverage.sh:196-209（AC-09 段）+ :6 头部用途行同步。
- 改前: `if [ "$ml" = "128" ]`（精确断言，注释「选精确=（非 ≤ 上限）」）。
- 改后: `if [ -n "$ml" ] && [ "$ml" -le 128 ]`（-le 上界，对齐 skill-split -le 惯例）；注释更新演进规则：行数只增不减的内容完整性由 AC-05（C 表 41 行逐行含 纳入|豁免 内容锚）守，AC-09 守上界防膨胀失控；超上界须走 Rule 52.3 增删同步并更新上界。
- 证据: 重跑输出 `AC-09 PASS 矩阵行数=128 ≤128 上界锚在位（task-v131 审计 L-3 对称守护 + CR P2-1；内容锚=AC-05，演进=Rule 52.3 增删同步）`；`Total: 9 PASS=9 FAIL=0 SKIPPED=0`，rc=0。

## S4 验证（三 selftest 全绿 + 行数）
- `bash -n` 两脚本语法 OK。
- selftest-root-resolution.sh → `Total: 17 PASS=17 FAIL=0` rc=0
- selftest-agent-coverage.sh → `Total: 9 PASS=9 FAIL=0 SKIPPED=0` rc=0
- selftest-skill-split.sh → `Total: 41 PASS=41 FAIL=0` rc=0
- SKILL.md wc -l = 477（不变）；selftest-root-resolution.sh 178 行；selftest-agent-coverage.sh 212 行（行数变化仅限 3 文件自身，符合 38.7 比例原则）。

## 负结果/风险排除
- worktree `git status` 另含 2 个未提交文件: scripts/init-session.sh（+41/-… 区域）与 scripts/attest-plan.sh（+27/-… 区域）——经 `git diff` 核为其内含 `[task-v131 CR-fix P1-1/P2-2/P2-3]` 标记注释，属 A 批 S-unit 先前落盘的存量未提交变更，本 B 批未触碰、未修改、未依赖其内容（本批断言仅 grep 行为锚，与 A 批改动无耦合）。
- 未 commit（任务明令）；分支仍为 wt/task-v131。
- 未触碰 critical-rules.md / 模板 / 其他脚本；scope_files=3 严格遵守。
