# S11 检查点 — C-1b 位点组 1（jq 双层路径修复）

- **状态**: COMPLETE（2026-09-27）
- **worktree**: /mnt/data/dev/task-planner-skill-worktrees/task-v091（分支 wt/task-v091，未 commit，待主进程验收）
- **改动文件**: 仅 2 个，`git diff --stat` = `2 files changed, 12 insertions(+), 8 deletions(-)`
  1. `skills/task-planner/scripts/zcode-posttooluse.sh` :108-117 — 段内 6 个 `.properties.X.default` 读取全部改为 `.X // .properties.X.default // 原兜底`（todo_sync_interval_calls / plan_update_interval_minutes / stale_remind_cooldown_calls / findings_stale_minutes / progress_stale_minutes / compass_escalate_after），兜底值 10/15/10/20/25/2 不变，`|| true`、`2>/dev/null` 与 case 兜底行原样保留
  2. `skills/task-planner/scripts/check-plan-dispatch.sh` :115-118 — step_max_minutes / step_max_files 两键改为 `.subagent.X // .properties.subagent.properties.X.default // "15"/"2"`（与 :118 step_max_steps 已有双层路径同构）
- **与任务书偏差（已实查后裁量）**:
  1. 任务书/提案称 zcode-posttooluse.sh 段内 5 键，实查 :109-116 有 **6** 个同款单层读取（提案漏计 compass_escalate_after）；按"同段其余 .properties.X.default 读取"语义全修，只修 5 个会任留 1 个同款缺陷
  2. 嵌套键顶层覆盖路径取 `.subagent.X`（提案 :141 记法 `subagent.step_max_minutes` 印证）；properties 默认层取 :117 注释自认的 `.properties.subagent.properties.<key>.default`
- **结构核查（修前必做，已做）**: Read worktree config.json 全文——顶层仅 schema 关键字（$schema/description/type/properties/required/additionalProperties），当前无顶层覆盖键；部署副本 `~/.zcode/skills/task-planner/config.json` 与 worktree **IDENTICAL**。修复式在无覆盖时输出与原行为逐值一致（向后兼容零回归），覆盖机制即提案 R14"用户覆盖静默失效"所描述的顶层覆盖约定；提案 :114 给出权威修复式 `.key // .properties.key.default`
- **验收证据（/tmp/c1b-test 三夹具，表达式与修改后脚本逐字一致）**:
  - CASE1 顶层覆盖（todo_sync_interval_calls=5, subagent.step_max_minutes=20, step_max_files=7）: `todo_n=5` `STEP_MAX_MIN=20` `STEP_MAX_FILES=7`（未覆盖键 plan_min=15/cooldown=10/findings_n=20/progress_n=25/esc_after=2 落 properties 默认 ✓）
  - CASE2 原版无覆盖: `todo_n=10 plan_min=15 cooldown=10 findings_n=20 progress_n=25 esc_after=2 STEP_MAX_MIN=15 STEP_MAX_FILES=2`（全部落 properties 默认 ✓）
  - CASE3 `{}` 两者皆无: 同上数值（全部落原字面兜底 ✓）
  - 缺陷对照复现: 旧表达式在 CASE1 上 `old_flat_todo_n=10`（覆盖 5 被无视）、`old_nested_min=15`（路径缺层恒落兜底）
- **语法**: `bash -n` 两文件均 SYNTAX-OK
- **范围外发现（未改，仅登记）**: check-plan-dispatch.sh :74 `.properties.plan_tier_enforce.default`（cpd:74）与 attest-plan.sh:88 同款单层读取属 C-1b 其余位点（组 2，proposal :128），本任务范围外未动；zcode-posttooluse.sh SKILL_ROOT 读 `$OPENCODE_SKILL_ROOT`（历史名），未改
- **脚本级验证**: 按任务书约定留待 S32 干净上下文验证包执行（本节点仅夹具级 jq 表达式验证）
