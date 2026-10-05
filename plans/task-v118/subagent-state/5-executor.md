# 5-executor checkpoint — task-v118 守卫②任务书豁免收窄

- status: in_progress
- worktree: /home/terry/task-planner-skill-worktrees/task-v118
- target: skills/task-planner/scripts/check-dispatch.sh（守卫②打包检测 Rule 35.3 任务书豁免：整体跳过 → 对任务书内容计数 S-unit ID）
- plan: ①Read 现状 ②改守卫②分支+注释(L43-47,L295-310) ③三态fixture验证+selftest ④落盘结论

## 结论（2026-10-03）
- status: done
- 改动文件: /home/terry/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts/check-dispatch.sh
  - 头注释 L48-53: 豁免收窄说明（Rule 46.2, 原行为=task-v078 双条件整体跳过）
  - 守卫②分支 L304-327: 双条件触发不变; 新逻辑=提取 subagent-state/ 引用路径(≤3,去标点) → cat 合并 -f且-r 文件 → distinct S[0-9]+ 计 n; n≥2 打印「任务书检出 N 个 S-unit ID（Rule 46.2 任务书豁免收窄）」计入 hits; n≤1/不可解析 → 既有 SKIPPED 行追加「(任务书无多 S-unit 或不可解析)」fail-open 不计 hits
  - 守卫①③④/缺项扫描/档位管线零改动（git diff 仅守卫②分支+两处注释，diff stat: +27 -3）
- 验证（enforce 档, TASK_PLANNER_PLAN_DIR=/tmp/v118-fixture/plan 含三文件）:
  - a) 任务书含 S1+S2 → rc=2, stderr 含「任务书检出 2 个 S-unit ID」+「[dispatch-block] 🚫 细粒度检测未通过(Rule 22.4 KQ3): 任务书打包(2 个 S-unit ID)」
  - b) 任务书不存在 → rc=0, stderr 含「SKIPPED 打包检测 ... (任务书无多 S-unit 或不可解析)」
  - c1) 附加: 任务书仅 1 个 S ID → rc=0 SKIPPED fail-open（首跑 rc=2 为串行锁 C-1 既有行为, 清锁后 rc=0 复验通过）
  - c) selftest-dispatch.sh: Total 31 PASS=31 FAIL=0（FG-05 PASS）; selftest-fine-grain-steps.sh: Total 11 PASS=11 FAIL=0
- 证据置信度: HIGH（fixture 实跑 + 双 selftest 全 PASS + bash -n 语法通过）
- checkpoint: done
