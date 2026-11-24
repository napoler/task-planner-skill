# Drift Checkpoint (seq 32)
- time: 2026-11-24 (收尾前偏移检查，距上次超10次工具调用)
- trigger: 冒烟阶段收尾前
- verdict: DRIFT

## 三锚证据
- 原话锚: user-session-log.md:42-69 #1-#3（R1要求“skill缺陷…必须解决”，#2三裁决）；task_plan.md:13-24 R1-R4/VC映射。判定以原话为准，R条目未冲突。
- 动作锚: progress.md:134-144 P6动作+D-20降级记录；errors E8/E9(161-162)已记录；verification.md:23 VC-8=pass。
- scope锚: `git log -2`顶=d9f68655 OK；`diff --stat 9e42c0b HEAD|tail -1`=10 files changed,42+/34- OK；`status --short -- skills`=4个M脚本(他会话) OK；goal-drill-20261124不存在 OK；.plan_required_side=8 OK；worktree list无本任务wt OK；4运行位decision-arbiter model均为GLM-5.3(与锚16预期一致) OK。

## 重点核对
1. VC-8 独立判断：**DRIFT/名不副实**。VC-8判据写明“新会话行为演练…”(verification.md:23,task_plan.md:77)，实际为同会话模拟演练(drill-report.md:3 明示降级、证明力受限、非无人值守自发行为)。drill-report/D-20披露充分，但verification.md将VC-8无条件标pass有误导风险。建议：将VC-8改为“pass(降级模拟,非新会话)”或在evidence/判据列醒目标注；交付必须披露未覆盖面。
2. scope外文件：未见主进程触碰他会话哨兵/未提交skills脚本/运行位agent定义/complex-planner/~/.zcode/commands/goal.md；scope锚命令均符合预期。
3. 失败/降级记录：subagent-state含历史REJECTED(02-critic R1/R2)与28-general-ops B4中止(已恢复,D-19/E8记录)；D-20记录演练降级。未发现未记录失败，但VC-8“pass”表述与降级事实不匹配，属记录口径风险。

## 建议
- 收尾前修正VC-8呈现（pass+降级限定）并在交付显著披露；其余scope合规。