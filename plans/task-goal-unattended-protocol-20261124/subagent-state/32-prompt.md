# 派发稿：冒烟与收尾阶段偏移检查（seq 32）

目标：对 task-goal-unattended-protocol-20261124 做收尾前的最后一次偏移检查（触发点=冒烟阶段收尾前，且距上次检查已超 10 次工具调用），输出三态判定 ALIGNED|DRIFT|BLOCKED。

## 三锚（逐锚引用证据写进检查点，缺锚的 ALIGNED 无效）

- 原话锚：user-session-log.md 全部条目（#1 原始指令、#2 三项裁决、#3 计划批准）+ task_plan.md 的 R 条目；两者冲突以原话为准。
- 动作锚：progress.md 尾部（decisions D-13 至 D-20、actions A24-A27、errors E8-E9、research FR-13、FR-14）。
- scope 锚（命令与预期）：
  - `git -C /mnt/data/dev/task-planner-skill log --oneline -2`（预期顶端 d9f68655）
  - `git -C /mnt/data/dev/task-planner-skill diff --stat 9e42c0b HEAD | tail -1`（预期 10 files changed）
  - `git -C /mnt/data/dev/task-planner-skill status --short -- skills`（预期只有他会话的 4 个未提交脚本）
  - `ls /mnt/data/dev/task-planner-skill/plans/goal-drill-20261124`（预期不存在：演练目录已清理）
  - `ls /mnt/data/dev/task-planner-skill/plans/.plan_required_side/ | wc -l`（预期 8：演练会话的哨兵已清理，其余为他会话所有，不得动）
  - `git -C /mnt/data/dev/task-planner-skill worktree list`（预期不含本任务 worktree）
  - 运行位 agent 定义未被改动：对 /home/terry/.claude/agents/decision-arbiter.md、/home/terry/.agents/agents/decision-arbiter.md、/home/terry/.config/opencode/agents/decision-arbiter.md、/home/terry/.cursor/agents/decision-arbiter.md 各 `grep -m1 '^model:'`，预期仍是 GLM-5.3。

## 近期动作摘要（只是线索，证据必须自查）

- 冒烟阶段两项：decision-arbiter 派发成功并裁决 COMPLETE（subagent-state/12-decision-arbiter.md）；goal 行为演练因新会话卡在权限审批而降级为同会话模拟演练（D-20），drill-report.md 与 drill-skeleton.txt 已写，演练产物已清理。
- 九项验收全部标 pass（`python3 skills/task-planner/scripts/planctl.py status --plan-dir <计划目录>`）。

## 需重点核对（请独立判断，不要顺着摘要走）

1. 验收项 VC-8 的本意是「新会话行为演练四判据全 PASS」。实际做的是同会话模拟演练（主进程自己扮演执行者、自己判定），现被标为 pass。请读 verification.md 中 VC-8 的判据原文与 drill-report.md 开头的「形态说明」，判断：这个 pass 是否名实相符？是否构成对用户的误导风险？若你认为应改判或必须以某种方式醒目披露，请明确写出（DRIFT 或附条件的 ALIGNED 均可，给出理由）。
2. 主进程是否在演练或冒烟中触碰了 scope 外文件（他会话哨兵、他会话未提交文件、运行位 agent 定义、complex-planner 配置、~/.zcode/commands/goal.md）。
3. 是否存在任何未被如实记录的失败、降级或未完成项（对照 progress.md 的 errors 与 decisions 自查：主仓 git 状态、子代理检查点目录 subagent-state/ 下的 status: failed 或 REJECTED 字样）。

## 验收标准

检查点不超过 18 行，含时间/触发点/判定/证据（file:line 或命令输出原文）/建议；三锚各有证据引用；对上面第 1 点必须有明确的独立判断。

## 步骤

- Step1 Read task_plan.md、user-session-log.md、progress.md 尾部、verification.md、drill-report.md。
- Step2 执行 scope 锚命令并对照；grep 子代理检查点中的失败字样。
- Step3 逐锚比对并形成对第 1 点的判断，写检查点。
- Step4 按 8 字段返回。
