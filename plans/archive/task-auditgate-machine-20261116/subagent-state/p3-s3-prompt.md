# Phase 3 S3 实现任务书 — task-auditgate-machine-20261116（selftest-plan-audit-gate.sh）

你是本计划 Phase 3 S3 的执行体（executor）。**工作目录=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-auditgate-machine-20261116（worktree 隔离区）**——skills/** 修改只在此 worktree；禁碰主仓 skills/**。

## 需求锚（逐字）

用户原话「三、未完成项与风险 1 授权 2 测试」（/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/user-session-log.md #1）；R2=「2 测试」。

## 权威规格（动工前必读）

1. /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md「Design Decisions」D3 段（15 用例全清单）
2. /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md VC-3（:23）与 VC-2（:21 attest 行为断言参照）
3. 范式参照（worktree 内只读）：scripts/selftest-vc-nonvacuous.sh（ok/bad 计数+Total 行）、scripts/selftest-plan-dispatch.sh（fixture 范式）

## 产物（worktree 内新建 scripts/selftest-plan-audit-gate.sh）

按 findings D3 15 用例实现（S1 产物 checker=scripts/check-plan-audit-gate.sh 与 S2 接线后 attest-plan.sh 已在位，直接对真脚本做行为断言）：
①规范示意 APPROVED 通过（`- 问题清单: 无`）rc0；②真实生产形态 APPROVED 通过（R6 段字节形态 `- 问题清单（留档，不阻断）:`）rc0；③无留痕 L1+ 拒锁 rc1；④无声明→rc0+输出含 `SKIP legacy-no-decl`；⑤轻量档 `[plan-audit-skip]`（**行首声明行**，非散文提及）放行 rc0；⑥L1+ 含行首 skip 声明拒锁 rc1；⑦mini 跳过 rc0；⑧mini×L1 冲突必审 rc1；⑨APPROVED 形态残缺 FAIL rc1；⑩中间态假阳性（REJECTED 段+后随 H2 修复轮块含反引号 APPROVED 元引用）rc1；⑪仅锚定假 PASS 路径（fixture a：段内裸文 APPROVED 意见文本）rc1；⑫仅边界假 PASS 路径（fixture b：后随 H2 块锚定 APPROVED 行）rc1；⑬rc2=删除 progress.md 文件+WARN；⑭缓存隔离（enforce→off→enforce 不复用缓存）；⑮attest 行为断言（enforce 无留痕拒锁不写锁+APPROVED 放行写锁）

要点：
- fixture 全 /tmp（mktemp -d+trap 'rm -rf' 清理）；正负例独立 task_plan 内容或每例清 /tmp/attest-cache-*
- task_plan fixture 最小化（frontmatter plan_tier/execution_lane+标题即可；若走 attest 真门链（用例⑮）须过其门链——508 行 attest 对 fixture 有 51.1 需求区块等硬门，可用 `--skip-dispatch-check --skip-template-check --skip-fmea-check --skip-vc-check --skip-goal-check` 跳其余门（本用例只证审计门交互），披露于注释）
- 输出 `PAG-<N> PASS/FAIL <描述>` 前缀 + `Total: <N> PASS=<n> FAIL=<m>` 末行（与 run-selftests.sh:166-167 汇总解析兼容）；全过 exit 0
- 注意 checker 对含 `[plan-audit-skip]` 散文提及的 task_plan 不误判（行首锚定）——fixture 的 task_plan 里若引用该 token 字符串须放行文/反引号内

## acceptance:（验收）

- `bash -n` rc=0；`bash selftest-plan-audit-gate.sh` exit 0 且 Total 行 FAIL=0；15 用例逐条 PASS 贴真实输出
- run-selftests.sh 能发现并聚合：`bash skills/task-planner/scripts/run-selftests.sh 2>&1 | grep plan-audit-gate`（**非 --fresh**，快速验证；全量回归归 Phase 5）
- registry 暂不登记（归 Phase 4 CA-12；但你须在收据中给出拟登记四列行草稿）
- 禁改主仓/checker/attest（发现其缺陷→报告，不自行改）

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/p3-s3.md（动工前登记，完成回填）

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
