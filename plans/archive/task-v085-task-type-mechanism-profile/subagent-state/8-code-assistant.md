# S7 checkpoint — check-complete.sh 机制画像抽查段（task-v085 Phase 3）
status: complete（双档实测通过，26 个真实计划回归 rc 不变）

## 改动
- 文件: /home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/scripts/check-complete.sh
- 位置: L855-864（SKILL-MODIFY GATE 之后、warn-count 段之前，python_rc=0 放行分支内）
- 净增 10 行（≤15 约束内），git diff --stat: 10 insertions(+)，零删除
- 逻辑: 档位 env TASK_PLANNER_MECHANISM_PROFILE_ENFORCE > config.json mechanism_profile_enforce.default > warn（jq 缺失 fail-open 到 warn）；off 整段跳过；template_type 两路提取（frontmatter `^template_type:` 行 → 表格行 awk 找 key 列取下一列，兼容反引号，参照 check-template-type.sh L20-24 扩展）；内容组 writing/research/publish 且含 `code_review: required`（字面行或模板表格行 `| \`code_review\` | \`required\` |`）→ warn 打 `[mechanism-profile] ⚠ ...` 不改 exit；enforce 打 `[mechanism-profile] ✗ ...` 后 exit 1（非提前路径：置于全部既有 gate 之后，复用脚本既有「各 gate 依次放行/阻断」的 exit 语义，python_rc 已=0 才走到此段）

## 双档实测（fake plan = mktemp 目录: template_type=writing 表格行 + code_review required 表格行 + 2 个 complete Phase + VC 表 2 行 + findings/progress 非 stub）
```
=== WARN (default, 无 env) ===
bash skills/task-planner/scripts/check-complete.sh <fake>/task_plan.md
WARN_RC=0
[mechanism-profile] ⚠ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；如属显式例外请登记理由）
（python 段 ALL PHASES COMPLETE 判定通过，基线 exit 0 不变）
=== ENFORCE ===
TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=enforce bash ... check-complete.sh <fake>/task_plan.md
ENFORCE_RC=1
[mechanism-profile] ✗ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；enforce 档 exit 1 — 显式例外须在计划 Decisions 登记理由或改 n/a）
（前段 [rescue] ✓ 等既有 gate 输出仍完整打印，exit 1 来自新段）
=== OFF ===
TASK_PLANNER_MECHANISM_PROFILE_ENFORCE=off bash ... check-complete.sh <fake>/task_plan.md
OFF_RC=0，mechanism-profile 输出=0（整段跳过）
```

## 回归（26 个真实计划，final 10 行版）
```
task-v055 rc=1  task-v056 rc=1  task-v057 rc=1  task-v058 rc=0  task-v059 rc=0
task-v060 rc=1  task-v061 rc=0  task-v062 rc=0  task-v063 rc=0  task-v064 rc=0
task-v065 rc=1  task-v066 rc=1  task-v067 rc=1  task-v068 rc=1  task-v069 rc=1
task-v070 rc=0  task-v071 rc=0  task-v072 rc=1  task-v073 rc=1  task-v074 rc=1
task-v075 rc=0  task-v076 rc=0  task-v077 rc=0  task-v078 rc=0  task-v079 rc=1
task-v080 rc=0  task-v081 rc=0  task-v082 rc=0  task-v083 rc=0  task-v084 rc=0
（全部 triggered=0：无内容组计划声明 code_review: required 冲突；rc 与插入前基线逐项一致）
```

## 备注
- template_type 提取比 check-template-type.sh 更宽：该脚本硬取 $3（`| template_type | X |` 固定列位），本段改用 awk 找 key 所在列取下一列，兼容 `| 字段 | 值 |` 表头型（本计划 L12-16 即此形态，实测提取=writing 成功命中）
- jq 缺失 fail-open 实测未单独跑（本环境有 jq）；逻辑上 `|| mp_tier=""` + case 兜底到 warn，与既有 resolve_*_tier 段同范式
