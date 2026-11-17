# R5 复审任务书 — task-auditgate-machine-20261116

你是本计划的独立审计体（R5 复审轮）。工作目录 /mnt/data/dev/task-planner-skill。除检查点外只读审查，禁修改任何仓库文件。

## 背景与需求锚

用户需求逐字锚（plans/task-auditgate-machine-20261116/user-session-log.md #1）：「三、未完成项与风险 1 授权 2 测试」——①授权 CA-6 机器面接线（计划审计门机器强门：新 checker check-plan-audit-gate.sh + attest [audit-gate] 接线 + selftest）②审计门测试（机器面正负例+selftest+行为面走门）。计划需求锚 R1=「1 授权」R2=「2 测试」R3=「三、未完成项与风险」（范围边界仅此两项，不扩其他机器面）。plan_tier=standard / execution_lane=L1。

历轮审计（progress.md 有完整登记）：R1 REJECTED 14 发现→修复轮 1；R2 REJECTED 6（N1-N6）→修复轮 2；R3 REJECTED（I1 fail-open+W1/N7/N8）→修复轮 3；R4 REJECTED（C-1[CRITICAL] grep -c 双零恒败 / I-1[IMPORTANT] worktree 时点互斥 / W-1 白名单缺 $ 锚 / W-2 scope-check 无 token / N-1 rc 掩蔽 / N-2 措辞）→修复轮 4（盘上复核在位）；微修轮 4b（VC-6 回归判据从绝对 FAIL=0 改「同集零增量」+Phase 1 selftest 基线冻结+基线漂移条款——因主进程实测存量基线 `Total: 99 PASS=92 FAIL=7`，7 个失败均为他任务在途遗留、R3 边界排除消解）。

## R5 复审范围（增量简版，禁重审全计划）

只审四面：
①R4 六发现的修复闭环（修复轮 4，progress.md「R4 修复轮」段+verification.md/task_plan.md 对应落点）：
- C-1：VC-6 尾部 config 断言改 `test -f && ! grep -q`（恒败消除）——核验新形态无逃逸（如 grep -q rc=2 语义、set -u 交互）
- I-1：VC-6 两段式（live worktree 断言删除→`[scope-check] SCOPE-OK` 留痕断言；断言本体下沉 task_plan「S2 内嵌命令」块 :293-311；:269 残留清理）——核验终验时点无 live 资源依赖、留痕断言与 S2 写入格式互洽
- W-1：白名单 `$` 尾锚（S2 内嵌命令内）——核验 `.bak/.orig` 类变异被拦
- W-2：token 格式 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 落 S2 步骤+验收
- N-1：rc 显式捕获（rc≥2 exit1，仅 0/1 合法）+白名单与 scope_files 一致性核对句
- N-2：VC-1 措辞含 r2
②微修轮 4b 闭环（唯一主题 VC-6 同集零增量）：
- task_plan.md Phase 1「selftest 基线冻结」块（:241-253）：Total/Failed 行与真实输出一致、归属说明、判据语义、基线漂移条款（`[baseline-shift]`+禁静默放宽）
- verification.md VC-6 判据/Evidence/Verify command：`FAIL=7` + `Failed:` 行整行精确相等双断言；「同集零增量」口径在 task_plan 6 处+verification 4 处同步无残留旧 FAIL=0 口径（**重点**：全仓 grep `FAIL=0` 核查是否残留矛盾口径——注意区分合法上下文如 selftest 各自脚本 PASS=… FAIL=0 行 vs VC-6 判据语义）
- 判据变更是否引入新问题：如 Total/PASS 数字漂移容忍度、他任务收口致合法漂移时的处置可操作性
③修复是否引入新缺陷（主进程已盘上复核：R1-R3 逐字锚 task_plan.md:16-18 未动、user-session-log.md #1 未动、progress.md 无审计段级 APPROVED 预写——你可独立复核）
④历轮 W/Q/NIT 遗留升级必要性（有新论据才升，无则留档）

## 输入材料（绝对路径，只读）

- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/task_plan.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/verification.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md（[plan-audit-R1..R4] 四段+各修复轮段=审计轨迹）
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/findings.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/knowledge-brief.md
- /mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/（历轮检查点：audit-R4.md、fix-R4.md、fix-R4b.md）

可对命令形态做 /tmp 沙箱模拟实测（禁写入仓库目录）；可跑只读命令（grep/sed/awk/bash -n/合成仓）。

## 裁决映射（审计体出具，主进程只登记）

`0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED，否则 REJECTED`；WARNING/QUESTION/NIT 留档不阻断。

## checkpoint:（唯一允许写入点）

/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/subagent-state/audit-R5.md — 动工前写（轮次/审计体=critic/开始时间/复审范围），完成后追加裁决与发现清单。

## 输出格式（8 字段返回模板）

- status: COMPLETE/FAILED
- result: R5 裁决与核心判断
- evidence: 每项判断的命令+输出锚（盘上实测，禁凭印象）
- files_modified: 仅检查点路径
- verification_results: /tmp 模拟实测命令与结果（如做）
- learnings: 本轮新教训（无则"无"）
- next_steps: 无（裁决归主进程登记）
- risks: 风险披露（无则"无"）

发现清单逐条：编号+严重度 CRITICAL/IMPORTANT/WARNING/QUESTION/NIT+文件:行+一句描述+修复建议；末行唯一裁决行 `结论: **APPROVED**` 或 `结论: **REJECTED**`。
