# Phase 3 S1+S2 实现任务书 — task-auditgate-machine-20261116

你是本计划 Phase 3 S1+S2 的执行体（executor）。**工作目录=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-auditgate-machine-20261116（worktree 隔离区，分支 wt/task-auditgate-machine-20261116）——所有 skills/** 修改一律在此 worktree 内**；禁碰主仓 /mnt/data/dev/task-planner-skill/skills/**；计划文档（plans/task-auditgate-machine-20261116/）只允许写检查点与（若必须）findings 回填。

## 需求锚（逐字）

用户原话「三、未完成项与风险 1 授权 2 测试」（/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/user-session-log.md #1）；R1=「1 授权」=CA-6 机器面接线（checker+attest [audit-gate]+selftest）。

## 权威设计规格（动工前必读）

1. /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md「Design Decisions」D1-D6 段（checker 全规格/attest 接线/selftest 清单/109.8 草案/插入锚点）
2. /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md VC-1（:15 判据+:17 Verify command 七态 r1..r7——你的 checker 必须逐态满足）与 VC-3（:23 用例全清单）
3. CA-7/CA-8 行（task_plan.md 变更标注表）

## S1：新增 checker（worktree 内 skills/task-planner/scripts/check-plan-audit-gate.sh）

按 findings D1 规格+VC-1 七态实现（bash，set -u，输出前缀 [audit-gate]）：
- 入参=<plan-dir>；task_plan.md 缺失或 progress.md 缺失/不可读 → rc2+`[audit-gate] WARN 判定器输入异常`（fail-open）；progress.md 存在但空 → rc1（无留痕）
- lane 判定（task_plan.md 行首 `^plan_tier:`/`^execution_lane:`，对齐 check-tier-consistency.sh:60-63 范式）：L1/L2 必审；mini×L1 并存按最严=必审；mini/L0/trivial 单独 → rc0+跳过提示行；无声明 → 输出 `[audit-gate] SKIP legacy-no-decl` rc0
- `[plan-audit-skip]` 在 task_plan.md：轻量档 rc0 / L1+ rc1
- APPROVED 末段聚合：awk 取最后一个 `^## \[plan-audit-R[0-9]+\] ` 段（**buf 止于下一个 `^## ` H2 行**；脚本注释登记「后随块必须 H2」前提）；结论判定 ERE 行首锚定 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`；三 token：`审计体:`+`轮次:`（段内子串）+`问题清单`（容忍括注 `^- 问题清单([（(][^）)]*[）)])?:` 行首）；REJECTED/形态残缺/无锚定 APPROVED → rc1+`[audit-gate] FAIL: <原因>`
- 单文件 ≤5K 字符推荐、≤100K 绝对；注释 What+Why（含两约束与容忍 token 的来源判例 R6a/R7 I-1/I-2）

## S2：attest 接线（worktree 内 skills/task-planner/scripts/attest-plan.sh 修改）

按 findings D2+CA-8：
1. :26-45 区新增 `--skip-audit-check` argv 解析→`skip_audit` 变量（同型 --skip-dispatch-check）
2. **插入点=window-lint 块 fi（:560）之后、`hash=`（:561）之前**：调用 `bash "$SCRIPT_DIR/check-plan-audit-gate.sh" "$plan_dir"` 捕获 rc+输出；阶梯=`TASK_PLANNER_AUDIT_GATE_ENFORCE`：enforce→rc1 时 echo `[attest] [audit-gate] 拒锁: <checker 输出>` 并 exit 1（不写锁）；warn（含未设，默认）→仅透传 checker 输出警告行不阻断；off→输出 `[audit-gate] SKIP (enforce=off)` 行；`skip_audit=1` → echo `[attest] [audit-gate] WARN: 已显式跳过审计门（--skip-audit-check）——交付须披露` 不阻断
3. :88 `_attest_cksum` printf 列表尾部追加三参数：`${skip_audit:-}`、`${TASK_PLANNER_AUDIT_GATE_ENFORCE:-}`、`$(sha256sum "$plan_dir/progress.md" 2>/dev/null | cut -d' ' -f1)`（格式保持既有 `%s|` 链）
4. 缓存回放 WARN 文案若列举旗标处补 skip-audit-check（逐字搜 `skip-fmea` 附近的回放 WARN 段对齐）

## acceptance:（验收）

- S1：`bash -n` rc=0；**VC-1 Verify command 七态实测**（/tmp fixture：r1 空文件 rc1/r2 mini×L1 rc1/r3 规范示意 APPROVED rc0/r4 中间态假阳性 rc1/r5 fixture a 段内裸文 rc1/r6 fixture b 后随 H2 块锚定 APPROVED rc1/r7 真实 R6 段字节形态 rc0）——七态贴真实输出；mini 单独 rc0；无声明 rc0+SKIP 行；缺 task_plan rc2；缺 progress 文件 rc2；空 progress rc1；chmod 000 progress rc2（uid=1000 可测）；轻量 skip rc0；L1+ skip rc1
- S2：`bash -n` rc=0；插入点锚 grep 证实（window-lint fi 与 hash= 之间）；--skip-audit-check 生效（mock 跑 attest 或 grep 链路证实）；cksum 三参数 grep 证实；**enforce 真实链路**：构造 /tmp fixture plan-dir（无留痕）→ `TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce bash attest-plan.sh <fixture>/task_plan.md` → rc≠0 且不产 .plan-attestation 且输出含 audit-gate；APPROVED fixture → rc=0 且产出锁文件（注意 attest 其余门链对 fixture 的要求——如 requirement-gate 51.1 区块，fixture 需最小合规；若 attest 门链过重可退化为只证 checker 调用链与 exit 传播，披露说明）
- worktree 内 `git status --short` 仅含预期两文件（+可能的 plans 检查点——检查点在主仓 plans/ 不在 worktree，勿写 worktree plans/）
- 禁改：SKILL.md/critical-rules.md/selftest-registry.tsv（Phase 4 面）/主仓任何文件

## checkpoint:

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/p3-s1s2.md（动工前登记，完成回填含实测输出）

## 输出格式（8 字段返回模板）

- status:/result:/evidence:/files_modified:/verification_results:/learnings:/next_steps:/risks:
