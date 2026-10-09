# 8-code-runner 检查点 — v154 worktree 全量 selftest 回归对照基线（S8 / VC-5）

> 任务：在 worktree /mnt/data/dev/task-planner-skill-worktrees/v154-decision-arbiter（wt/v154-decision-arbiter，HEAD=3322259）只读执行全量 selftest-*.sh，与 master 基线（64 脚本 ΣPASS=1002 ΣFAIL=0，见 1-code-runner.md）对照分类。
> 执行方式：逐个 `timeout -k 5 120 bash <脚本绝对路径>`，cwd=worktree 根；无参数（脚本 BASH_SOURCE 自定位）。
> 口径（已验证可复现基线 1002/0）：末行 `PASS=n FAIL=m`（多空格容错）记断言计数；无汇总行者按 `^✓` 行计数；rc 原样记录（124=timeout）。
> 只读约束：不修改仓库任何文件；唯一仓库内写入=本检查点；辅助日志/结果/运行器在 /tmp/selftest-v154/（仓库外）。

## 执行时间
- 开始：2026-10-10 约 11:15（+0800）（待结束回填）

## 脚本总数
- worktree 枚举 **65**（=基线 64 + 新增 selftest-decision-arbiter.sh）；渐进回填中

## 逐脚本结果表（渐进回填）
| # | 脚本 | rc | PASS | FAIL | 结果 | 耗时ms | 基线PASS对照 |
|---|------|----|------|------|------|--------|--------------|
| 1 | (pending) | | | | | | |

## ΣPASS / ΣFAIL（阶段性）
- 待回填

## FAIL 清单与分类表（待回填）
- 待回填

## 备注
- 待回填
