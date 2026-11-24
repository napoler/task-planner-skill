# 派发稿：部署阶段收尾偏移检查（seq 30）

目标：对 task-goal-unattended-protocol-20261124 做一次偏移检查（触发点=部署阶段收尾前，且距上次检查已超 10 次工具调用），输出三态判定 ALIGNED|DRIFT|BLOCKED。

## 三锚（逐锚引用证据写进检查点，缺锚的 ALIGNED 无效）

- 原话锚：user-session-log.md 全部条目（#1 原始指令、#2 三项裁决、#3 计划批准；重点 #2 的裁决一与裁决二）+ task_plan.md 的 R 条目；两者冲突以原话为准。
- 动作锚：progress.md 尾部（decisions D-13 至 D-19、actions A24-A26、errors E8-E9）。
- scope 锚（命令与预期）：
  - `git -C /mnt/data/dev/task-planner-skill log --oneline -3`（预期合并提交 d9f68655 在 master 顶端）
  - `git -C /mnt/data/dev/task-planner-skill diff --stat 9e42c0b HEAD`（预期 10 个 skills 文件，+42/-34）
  - `git -C /mnt/data/dev/task-planner-skill worktree list`（预期不含 task-goal-unattended-protocol-20261124）
  - 部署范围：/home/terry/.zcode、/home/terry/.agents、/home/terry/.claude、/home/terry/.config/opencode、/home/terry/.cursor 五个运行位下 deploy-runbook.md「固定量」列出的 9 个相对路径文件。
  - `git -C /mnt/data/dev/task-planner-skill status --short -- skills`（预期只有他会话的 4 个未提交脚本：attest-plan.sh、init-session.sh、planctl.py、task-plan-init.cjs）。
  - 运行位 agent 定义不在部署范围：对 /home/terry/.claude/agents/decision-arbiter.md、/home/terry/.agents/agents/decision-arbiter.md、/home/terry/.config/opencode/agents/decision-arbiter.md、/home/terry/.cursor/agents/decision-arbiter.md 各执行 `grep -m1 '^model:'`，预期仍是 GLM-5.3（即未被本任务改动）。

## 近期动作摘要（只是线索，证据必须自查）

- 已合并进 master 并清理隔离区；已按手册对 5 个运行位逐文件打补丁增量（共 45 项），部署前已备份。
- 部署手册的文件清单由计划期的 6 个修订为 9 个（新增的 3 个是对齐 decision-arbiter 配置时随动的引用面与断言面，登记在 D-16、D-17）。
- 部署首轮曾因校验口径有误而安全中止并恢复 1 个文件，修订口径后续做完成（E9、D-19）。

## 需重点核对

- 部署的 9 个文件是否都在用户授权范围内。判据：用户裁决一=goal 模式下把已合并且 selftest 通过的 skills 内容同步到运行位属预授权，护栏四项；明示不含 agent 定义的 model/frontmatter。特别核对 selftest-decision-arbiter.sh（一个脚本）入列是否越界。
- 是否有动作改了 scope 外文件（四个运行位的 agent 定义副本、complex-planner 配置、~/.zcode/commands/goal.md、示例会话遗留待授权项、他会话的未提交文件）。
- 护栏四项是否都有证据：逐位 diff 判向（备份目录下 pre-diff.txt）、禁整文件覆盖（apply.txt 的记录为 patch 增量）、部署前备份（pre 目录 45 个文件）、部署后对账（progress 中的 verify 结果）。备份目录：/mnt/data/dev/task-planner-skill/tmp/deploy-backups/task-goal-unattended-protocol-20261124

## 验收标准

检查点不超过 18 行，含时间/触发点/判定/证据（file:line 或命令输出原文）/建议；三锚各有证据引用。

## 步骤

- Step1 Read task_plan.md、user-session-log.md、progress.md 尾部、deploy-runbook.md 的「固定量」段。
- Step2 执行 scope 锚命令并对照。
- Step3 逐锚比对，写检查点。
- Step4 按 8 字段返回。
