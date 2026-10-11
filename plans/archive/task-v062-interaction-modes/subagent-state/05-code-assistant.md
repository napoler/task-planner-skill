# 05-code-assistant 检查点

## 里程碑 1: 已读 resolve + selftest 全文
- resolve-interaction-mode.sh 接口确认:
  - env 变量 = TASK_PLANNER_INTERACTION_MODE, 非法值(非 ask|silent)忽略并降级 ②
  - ② 参数: 目录 → <dir>/task_plan.md; 文件 → 直接读; 无参数 → 跳过 ②
  - ② 解析: grep '^\|\s*`?interaction_mode`?' 取行, awk -F'|' '{print $3}' 取值列, trim 反引号/空白; 值必须 ∈ {ask,silent} 否则降级 ③
  - ③ config.json = 脚本所在目录的 ../config.json; 先 .properties.interaction_mode.default, 再顶层 .interaction_mode; jq 缺失/非法 → 降级 ④
  - ④ 兜底 ask; 退出码恒 0; stdout 单行
- selftest 原缺陷确认:
  - TI-01..04 只有注释无代码
  - TI-05 传未定义变量 $PLAN5 → 降级 ③, 但 ③ 读到的是 copy 所在目录的 ../config.json 错位
  - TI-06: config.json 放 $TSCRIPTS6/config.json, 但 resolve 找 $TSCRIPTS6/../config.json = $TMP/config.json(即 TI-05 写的 default=ask) → 输出 ask 而非 silent
  - TI-07 同被 $TMP/config.json 污染
  - 根因: 各 fixture 未独立 root, resolve 的 <script_dir>/../config.json 定位要求 config 放 <root>/config.json、resolve copy 到 <root>/scripts/

## 里程碑 2: 修复完成 (17:5x)
- 重写 selftest-interaction.sh (118 行): 补全 TI-01..04, 修 TI-05/06/07 fixture 隔离
  - TI-01: C07(无config)无参数无env → ask
  - TI-02: env=silent 无参数 → silent
  - TI-03: env=banana(非法) + $PLAN(silent行, 传目录) → silent (降级②)
  - TI-04: 无env + $PLAN 目录 → silent
  - TI-05: $PLAN5(banana行) + C05(config default=ask) → ask
  - TI-06: $PLANEMPTY(无行) + C06(config default=silent) → silent
  - TI-07: C07 无config无参数无env → ask, rc=0
  - TI-08: 传 $PLAN/task_plan.md 文件路径 → silent
- 验证: 连跑两遍均 8/8 PASS, EXIT=0 (见主进程回收处证据)
- commit: f7e2a14680bd82a0b1a0b11df55350dc1ea3250e (wt/task-v062-interaction-modes 分支)
  - git show --stat: 1 file changed, 118 insertions(+) create mode 100755
  - commit 后 git status --short 干净
- 未改动 resolve-interaction-mode.sh / critical-rules.md / SKILL.md / config.json / README
- 负结果报告: 无冲突; 未 push

## 最终结论
- status=completed, task_id=selftest-interaction-fix
- evidence: commit f7e2a14; 两遍自测 EXIT=0 且 8/8 PASS
- confidence=0.95 (唯一残留: TI-03 用 canonical $RESOLVE 验证 env 非法降级, 未额外验证 canonical 无 config 情形 —— 与 TI-01/07 的 C07 场景等价, 风险低)
- next_step: 主进程 Read 复核 selftest-interaction.sh + git log 确认 f7e2a14, 之后按计划走 worktree 合并回合约(11.3)
