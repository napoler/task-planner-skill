# 回归单元 checkpoint — 全量 selftest 回归 V1（零新增失败硬门核验）

> 任务: task-v159-pointer-lifecycle（指针与部署生命周期五修复）
> 日期: 2026-10-10
> worktree: /mnt/data/dev/task-planner-skill-worktrees/v159-pointer-lifecycle（HEAD 2f27fcb, git status clean）
> 回归日志（主进程指定落点）: /mnt/data/dev/task-planner-skill/plans/task-v159-pointer-lifecycle/regression-v1.log

## 跑批覆盖
- worktree `skills/task-planner/scripts/` 下全部 69 个 selftest-*.sh 逐个执行（cwd=技能根；每脚本 timeout 90s；顺序跑批；stderr 全量扫描）
- 基线: /tmp/v159-baseline.tmp（66 脚本全 rc=0 / ΣFAIL=0 @5280cb3 态）

## 结果总览（逐行原文见回归日志）
- N=69 脚本；rc=0 计数=68/69；ΣFAIL=2
- 唯一新增失败: `scripts/selftest-smart-merge.sh rc=1 | Total: 17 PASS=15 FAIL=2`
  - `SM-06 FAIL rc=1(期望6) s1-IDENTICAL=缺 s2-DRIFT=缺`
  - `SM-14 FAIL rc=0(期望0) IDENTICAL=缺 slotB-SKILL_MARKER=canonical-v077(期望canonical-v077非stale-content)`
- 硬门判定（零新增失败, 需求锚 R1 跑批门）: **未过**（基线 ΣFAIL=0 → 本态 ΣFAIL=2）
- 其余 68 脚本 rc=0；新增 3 脚本全绿（error-fix-prompt-forge 8/8；pointer-lifecycle 10/10；report-reviewability PASS=13 FAIL=0）

## 差异清单（vs 基线）
- NEW(3): 本区间新增脚本, 全 rc=0（含本任务新 selftest-pointer-lifecycle 10/10）
- CHANGED(2):
  - selftest-registry.sh: 计数演进 (rows=66,actual=66)→(rows=69,actual=69)，rc=0 FAIL=0 不变（预期内）
  - selftest-smart-merge.sh: rc 0→1 / FAIL 0→2 ← 唯一硬差异
- REMOVED: 无
- 复现性: smart-merge 独立复跑 1 次, rc=1 同款两失败（确定性, 非抖动）

## 根因（源码级锚）
- smart-merge-back.sh 新 F5 默认路径（2f27fcb, staging/swap/post-verify）:
  - :671 `[DEPLOY] IDENTICAL: $slotdir` 仅 legacy 分支打印
  - :770 新路径终行仅 `[DEPLOY] OK: 全部部署位 IDENTICAL(...)`（不含旧格式 "[DEPLOY] IDENTICAL: <slot>"）
  - stage 失败 :700 输出 STAGE-FAIL + :707 `exit 1`（旧契约 exit 6）
- selftest-smart-merge.sh :237-238 / :433 断言仍为旧契约（期望 rc=6 + `[DEPLOY] IDENTICAL: <slot>`）；该脚本 5280cb3..HEAD 零提交（git log 口径 0）→ 断言与实现契约漂移, 非部署语义错误（SM-14 终态 slotB=canonical-v077 实质通过, 失败点=消息 grep）
- 波及面: 全量 grep 显示 "[DEPLOY] IDENTICAL/DRIFT/OK" 消费者仅 selftest-smart-merge.sh 一处
- 后续动作建议（供主进程裁决）: ① 推荐——更新 selftest-smart-merge.sh 断言至 F5 新契约（消息 OK/STAGED/SWAPPED + 退出码语义），与设计文档 F5 节对齐；② 不推荐——新路径回补旧格式消息/退出码（背离 F5 设计）

## 观察项（非新增失败, 不阻塞）
- selftest-fallback.sh :108/:110 jq 单引号内 `\"` 转义致 jq 编译错（stderr 可见）→ h1/h2 空串, :113 T07c "meta hash 不变" 退化为 空=空（断言弱化）；该脚本本区间零改动（与基线同文件同环境, 既存）

## 证据文件
- /mnt/data/dev/task-planner-skill/plans/task-v159-pointer-lifecycle/regression-v1.log（69 行原文 + 差异清单 + 总计行）
- 逐脚本原始 stdout/stderr 暂存: /tmp/v159-rlogs/（scratch；含 smart-merge-rerun1.out 复跑证据）

## 状态
- 跑批完成；硬门未过（已取证归因, 供主进程裁决修复动作）
