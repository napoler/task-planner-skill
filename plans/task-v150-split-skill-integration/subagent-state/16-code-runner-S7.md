# [sub:16-code-runner-S7] S7 全量回归 — code-runner-agent(mini)

- **status**: completed
- **task**: task-v150 S7（重派）worktree 全量 selftest 回归 + 基线三桶对照
- **worktree**: /mnt/data/dev/task-planner-skill-worktrees/task-v150-split-skill-integration（脚本根 skills/task-planner）
- **回归日志**: /mnt/data/dev/task-planner-skill/plans/task-v150-split-skill-integration/regression-worktree.log（63 行覆盖 63 脚本；无 rc=124 超时）
- **基线**: /mnt/data/dev/task-planner-skill/plans/task-v150-split-skill-integration/baseline-selftest.log（62 脚本，TOTAL=62；唯一 FAIL=periodic-review rc=1 FAIL=4）

## 三桶分类（机械 diff：baseline 去 TOTAL 行 vs regression-worktree.log，4 处差异）

### 桶① 已知基线 FAIL（1 个，diff 零差异逐字一致）
- `scripts/selftest-periodic-review.sh rc=1 | Total: 10 PASS=6 FAIL=4`

### 桶② 本次新增 FAIL（3 个，均 rc 0→1）
1. `scripts/selftest-registry.sh rc=1 | Total: 5 PASS=4 FAIL=1 (registry rows=62, actual selftest=63)`
   - 明细原文：`T02 FAIL 未登记: selftest-split-pattern-library.sh`
2. `scripts/selftest-self-resolution.sh rc=1 | Total: 13 PASS=12 FAIL=1`
   - 明细原文：`SR-12 FAIL registry 漂移（selftest-self-resolution 命中 1 应 ≥1 / 总行数 63 应 64=脚本数+表头）`
3. `scripts/selftest-skill-split.sh rc=1 | Total: 41  PASS=40  FAIL=1`
   - 明细原文：`[FAIL] T-主 行数 ≤500（…）且 ≤558 上限`
   - 实际值：`wc -l SKILL.md` = 502；断言在 selftest-skill-split.sh:44（`-le 500`）；来源提交 d4fb622 对 SKILL.md +4 行（`git show d4fb622^` = 498 行 → 现 502）

### 桶③ 其余全部 rc=0 PASS（含新增脚本）
- 新增脚本：`scripts/selftest-split-pattern-library.sh rc=0 | Total: 13 PASS=13 FAIL=0`（SP-01..SP-13 全 PASS）

## 特别核验
- selftest-split-pattern-library.sh 应 rc=0 且 Total FAIL=0 → 满足（回归日志第 52 行；完整输出 SP-01..SP-13 全 PASS，含 SP-02 模式数 11、SP-03 伴飞表 7 路径全存在）

## 根因小结（供主进程裁决，均超 runner 只读修复范围）
- registry 系 2 个 FAIL 同源：新脚本未登记 scripts/selftest-registry.tsv（脚本头自述"增删/改名任何 selftest-*.sh 必须同步"）
- skill-split FAIL 独立根因：SKILL.md 四点接线后 502 行 > 断言钉值 500（≤558 总上限内；脚本注释存在"钉值随内容演进同步上调"先例）

## 负结果报告
- 无 rc=124（无超时）；重跑 3 个新增 FAIL 脚本均复现同结果（非环境抖动）
- selftest-delegation.sh 末行非 Total 格式（以分隔线结尾）属基线同款（diff 零差异），非回归
