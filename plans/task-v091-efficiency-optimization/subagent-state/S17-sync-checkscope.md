# S17 C-1c/d 组 2 checkpoint: sync-todos 接入 plan-parse lib + check-scope realpath 化

## 状态（全部完成, commit 28221a7）
- [x] step 1/4 进场核对: HEAD=73730f7f01101d787c6ae2f6bad9568ebefd1185 (73730f7 开头 OK), status clean, 分支 wt/task-v091-efficiency-optimization
- [x] step 2/4 sync-todos.sh 接入: :15 一带 source lib(SCRIPT_DIR 范式同 check-conflicts S16); extract_plan_meta scopes 行 → `plan_parse_scope "$plan" | head -10 | tr '\n' ',' | sed 's/,$//'`(join 原样保留调用侧); lib 注释清单第 2 项 → "S17 已接入"; bash -n OK; diff: sync-todos +10/-1, lib +3/-1
- [x] step 3/4 check-scope.sh :51: `python3 -c abspath` → `realpath -m --`(保留 2>/dev/null||echo 回退结构); 对拍 10/10 组 SAME(绝对/不存在绝对/相对/不存在相对/../×1/../×2 混合/./ /尾斜杠/不存在带../ /dash 开头); 已界定边界: 空串 DIFF 不可达(:32 前置拦截), symlink 组件 realpath 解析为物理路径(下游无影响); bash -n OK; diff 仅 1 hunk @@ -48,7+48,14 @@; 仲裁段原 :142-144 = 现 :149-151 行号平移+7, 内容与 73730f7 逐字一致, 零 diff
- [x] step 4/4 验收+commit:
  - bash -n x3 OK (sync-todos / check-scope / lib)
  - 37 计划对拍(真实调用形态=命令替换内调用): 37/37 byte-identical + rc 一致; 首轮 harness 曾报 2 DIFF(v072/v073 old rc=1)系 harness 缺陷——顶层 set -e 生效, 而真实脚本 extract_plan_meta 运行于 meta="$(...)" 子 shell, bash 5.2.21 inherit_errexit=off 默认不继承 -e, 旧形态实际输出 none|| rc0, 与新形态一致(bash -x 实证 + 修正 harness 37/37)
  - 端到端 --index: 新旧 INDEX.md 除自动时间戳行外 byte-identical(89 行), 新版含 v072/v073 行(none||)
  - check-scope 冒烟 5/5: plans 豁免 0 / side 哨兵拦截 1(夹具 sidkey 规范化后重测) / legacy 拦截 1 / 无哨兵 0 / 无根 0
  - selftest(grep 引用 check-scope 者全跑): rule23 3/3, execution-stability 19/19, knowledge-brief 16/16 全绿
  - /tmp/s17-parity 已清理
  - commit 28221a7: 3 files changed, 19 insertions(+), 3 deletions(-); 工作树余 ?? plans/task-v091/(本 checkpoint, 未入 commit)

## 关键路径
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091
- scripts: skills/task-planner/scripts/{sync-todos.sh,check-scope.sh}
- lib: skills/task-planner/scripts/lib/plan-parse.sh
- 对拍基准: git show 73730f7:skills/task-planner/scripts/sync-todos.sh
- 主仓计划目录: /mnt/data/dev/task-planner-skill/plans/ (37 个计划)
