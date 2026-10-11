# 11-executor — task-v131 Phase 3 critic 吸收修订（S-unit 2: Rule 53.1-53.5 四处/五处精准修订）

## 任务
worktree=/home/terry/task-planner-skill-worktrees/task-v131
只动 skills/task-planner/references/critical-rules.md 一个文件。
按 critic 10-critic.md 的 CHANGES_REQUESTED + 主进程定稿，对 Rule 53.1/53.2/53.3/53.4/53.5 做逐字替换（5 处）。

## 执行
方法：python3 脚本对 critical-rules.md 做 5 处 exact-string replace（每处前置 assert 出现次数==1 才替换，防误匹配）。
- E1 (53.1)：在「判例反例」句前插入结果级判定口径句（疑似从严默认/对齐 50.2/禁裸豁免）。
- E2 (53.2)：句尾「按 Rule 26 降质面回炉」→「按 Rule 26.3 惩罚映射语义处置（触发面=Q8 无根治判据，登记于 53.5；不扩 26.1 既有 Q1-Q6 枚举）」。
- E3 (53.3)：整条重写为以 Rule 41.2 四门槛为唯一权威边界的决策管辖二分（含 Q7 惰性推诿挂 26.3 + 41.4 已尝试清单 + 41.3/44.2 联动）。
- E4 (53.4)：「禁选浅路径。」后插入核算口径=可陈述三元组 + 无客观证据从严默认彻底路径。
- E5 (53.5)：「消费点=」前插入触发面登记（Q7/Q8 挂 26.3）+ attest 51.1 门第4锚=根源覆盖表 + check-dispatch.sh advisory（warn 档 fail-open 如实披露）+ RC-15 断言演进。

## 验证结果（工具复现）
- 每个 exact-insert 字符串 grep -c = 1：
  - 结果级判定口径=用户表述含结果性词 = 1
  - 按 Rule 26.3 ... 触发面=Q8 ... = 1
  - 升级呈报前按 41.4 消解清单附「已尝试清单」 = 1
  - 核算口径=可陈述三元组 = 1
  - RC-15 断言 = 1
- 旧 53.3 句「或无客观判据的真实偏好二选」grep -c = 0（已替换）✅
- 「唯一权威边界」= 1；「疑似从严默认」= 1；「三元组」= 1 ✅
- 「Q7 惰性推诿」= 2（53.3 + 53.5 双登记，属定稿文本设计内，非误重复）；「Q8 无根治判据」= 2（53.2 + 53.5 双登记，设计内）。
- git diff --stat -- critical-rules.md = 1 文件（16 行增 2 删）；wc -l = 586。
- 仓库级 git status 另有 SKILL.md / subagent_dispatch.md / task_plan.md 处于 modified 态 = Phase 1/2 既有未提交变更（commit 92cab23/9924b0a 之后工作树遗留），非本 S-unit 改动。本 S-unit 仅写 critical-rules.md。

## 遗留/上报
- 未 commit（按任务要求）。
- §5 定稿同步更新、SKILL C36 对齐等由主进程做，本 S-unit 未触碰其他文件。
- Q7/Q8 全仓各出现 2 次（条款登记面 53.x + 载体登记 53.5），若 critic 验收口径要求「严格=1」需主进程裁决是否将 53.5 登记面改写；本 S-unit 按逐字定稿执行，双登记为定稿文本固有。
