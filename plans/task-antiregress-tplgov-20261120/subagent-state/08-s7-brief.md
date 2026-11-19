# S7 任务书：主动加载强化——general 兜底须登记理由（2026-11-20）

执行体：在 worktree 内把 general 兜底从静默默认改为须登记理由（R3）。数据侧已完成（research/scenario-coverage.md：93 任务实测 general 占 63%，主痛点在选择机制）。全程中文。

## 0. 绝对路径（worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- init 脚本：$W/skills/task-planner/scripts/init-session.sh（先 grep -n 'template-sense' 定位既有 general 兜底提示段）
- 终验脚本：$W/skills/task-planner/scripts/check-complete.sh（先 grep -n 'template-sense\|模板感知' 定位既有 T3 检查段）
- advisor：$W/skills/plan-template-advisor/SKILL.md（先 grep -n 'general' 定位兜底相关段）

## 1. 交付物（3 处，最小增量，全部跟随既有风格）

### ① init-session.sh（template-sense 段）
既有提示「任务类型空缺（general 兜底）——按 Rule 34.3②/34.7 评估沉淀，终验必查」增强/追加一行：
`[init] ⚠ general 兜底须登记理由（R3，2026-11-20 task-antiregress-tplgov-20261120）：计划期在 task_plan.md「🔁 模板感知」区块写明为何无适配 variant（数据依据=plans/ 类型分布），终验 check-complete 必查`
禁改既有行语义（追加行或最小措辞增强二选一，倾向追加行）。

### ② check-complete.sh（T3 检查段）
在既有模板感知检查附近追加一条 warn：计划 template_type=general 且「🔁 模板感知」区块存在但无「登记理由」字样 → stderr warn 一行（对齐既有 `[template-sense] ⚠` 风格，前缀可用 `[template-sense]`）。不做硬门。

### ③ plan-template-advisor/SKILL.md（兜底条款）
在 general 兜底相关段落追加条款行（含「登记理由」关键词）：
`> general 兜底非静默默认：选用 general 须在计划「🔁 模板感知」区块登记理由（为何无适配 variant + 数据依据），终验对照（R3，2026-11-20）`

## 2. 验收（自查 4 条，入 checkpoint 自审段）
1. VC-08：`grep -n "登记理由"` 在 init-session.sh / check-complete.sh / plan-template-advisor/SKILL.md 三文件各≥1 命中
2. 既有行为零破坏：init-session.sh 相关既有 selftest（如 selftest-template-sense.sh 若存在则跑）rc=0；check-complete.sh 改动仅 +行（git diff 无删除）
3. 改动面=3 文件、≤20 行新增
4. 103.2 自审逐条对照，证据锚 file:line 入 checkpoint
（VC-09/VC-10 已由数据侧与计划登记满足，本 S-unit 不重复做）

## 3. 禁改面
上列 3 文件外一切禁改（含 selftest 既有脚本禁改——若既有 selftest 因本改动 FAIL，回滚该处改法而非改 selftest）；主仓与部署位禁碰。
