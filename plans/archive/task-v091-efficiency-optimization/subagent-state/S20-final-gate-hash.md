# S20-final-gate-hash 检查点（task-v091/S20 C-2）

- 状态: COMPLETE
- commit: 216e912（wt/task-v091-efficiency-optimization，2 files changed, 345 insertions(+), 3 deletions(-)，worktree 提交后 clean）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（分支 wt/task-v091-efficiency-optimization，基线 aff5e06）
- 提案依据: plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md:139-146（C-2 v3 四元键定义）

## 改动（仅 2 文件，符合任务硬约束）
1. skills/task-planner/scripts/check-complete.sh
   - 四元内容键计算块（键①task_plan.md 实时 sha256 且==.plan-attestation 锁定哈希；键②check-plan-dispatch.sh 整文件哈希；键③本脚本 FMEA 门段哈希，锚=sed 命令行自身(484)→挽救门注释(570)，FMEA 段超集只增失效；键④五 config 消费键生效值+tier 两键 env 覆盖计入快照，只收窄不扩大 SKIP 面）
   - PLAN-DISPATCH 门与 FMEA 门各加 SKIP-BY-HASH 分支（显式 SKIP 行→stderr，余门照跑）
   - 两门全过后写状态：/tmp/task-planner-final-gate-<plan_dir哈希16>.state（写入前置 attest 一致+非 SKIP 轮；失败路径不到写点；不进 mtime/size）
   - 状态文件位置裁决理由：.plan-attestation 是 git 跟踪文件不可污染；plan 目录 sidecar 会产生未跟踪文件（Rule 27.3 porcelain 风险）且硬约束禁改 .gitignore；/tmp 有 /tmp/task-planner-warn-* 先例
2. skills/task-planner/scripts/selftest-final-gate-hash.sh（新建，六夹具+键④完整性前置断言，/tmp 沙箱复制 skill 树篡改副本，trap 清理）

## 验证证据
- bash -n 两脚本通过
- selftest-final-gate-hash.sh: PASS=22 FAIL=0（六夹具全 PASS：①TAMPERED ②touch-r ③未变重跑 SKIP+余门 ④四键五突变不 SKIP ⑤损坏/缺失 fail-open 自愈 ⑥SKIP 后真变化被拦 rc=1）
- 回归: 7 个引用 check-complete 的既有 selftest（mechanism-profile/delegation/skill-modify/error-loop/vc-gate/reflect-verify/plan-tier）全 rc=0
- 锚点复核: 起锚首匹配=484(sed 行)，终锚=570，无中间污染
- /tmp 沙箱与状态文件已清理

## 调试过程记录（3 轮迭代）
- ②a 失败→根因: 篡改轮也写状态污染键①→修复: 状态写入前置 attest 一致
- ④f 失败→根因: 状态=上轮全量通过条件，还原后需一轮重锁→修复: ④f 改两轮断言
- ⑥b 失败→根因1: Executor 改子代理触发 DELEGATION 门 Handoff unverified→修复: 夹具计划预置 Handoff 表+篡改为表内类型 explorer；根因2: 括号内半角冒号被 type_hint 的 #*: 剥离误伤→修复: 去冒号
