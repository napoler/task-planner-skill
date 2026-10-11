# S3 checkpoint — code-assistant(haiku-1) | 2026-10-10

## status: done

## 执行范围
- 只写 1 文件：/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/references/critical-rules.md
- 材料包：/mnt/data/dev/task-planner-skill/plans/task-v162-change-absorption-safety/task_plan.md L195-197（T1/T2/T3 逐字采用）

## 里程碑 M1 — 三处触点追加（完成）
锚点定位（grep）：
- `8.1 **新任务边界判定` = critical-rules.md:29（长段落行尾）
- `36.5 **保守化修改纪律` = :374（行尾）
- `56.1 **默认自动执行` = :644（「不添加人工审查步骤。」后）

追加内容（逐字=材料包）：
1. T1 @ 29 行尾（「selftest-task-boundary.sh 静态锚（防条款误删）。」之后）：
   `变更吸收语义门（Rule 74）：指令并入既有计划（A/B 类）时，对既有计划/规则/模板的每一处变更先过 74.2 三判门——增量默认、替代四条件、删除授权；答案登记 task_plan.md 变更标注表（74.3），无标注表禁入执行。`
2. T2 @ 374 行尾：
   `本条是 Rule 74.2 在技能保护区的特化（替代四条件+删除确认的同位实现）；技能区以外的吸收场景按 74.2 上位总则执行。`
3. T3 @ 644 行「不添加人工审查步骤。」后插入括注：
   `（吸收用户指令时的变更语义按 Rule 74.2 三判门处置：增量默认、替代四条件、删除授权）`

## 里程碑 M2 — 验证（完成）
- `grep -c "Rule 74" critical-rules.md` = 3 ≥3 PASS（S1 的 74.1-74.6 条文本身不含 "Rule 74" 字样，3 命中全为触点引用句）
- `git diff --stat`（S3 三处形态）：3 行修改，每行 + 均以 - 原文为前缀 = 纯行尾追加，宿主旧文 0 字符改动（74.2(a) 增量默认纪律满足）
- 注：`git diff` 同时含 S1 已写入的 74 节 9 个 + 行（Phase 2 遗留未提交工作树变更，非 S3 产物，S3 未触碰）

## 负结果报告
- 检查依赖：critical-rules.md 全文锚点逐行 Read（29/374/644 各 1 行）；材料包 T1-T3 原文（task_plan.md L195-197）
- 未发现冲突：三锚点唯一（grep 各命中 1 行）；三处行尾追加无重叠；T3 插注点在「不添加人工审查步骤。」与「质量保障通过…」之间，两侧旧文均未动
- 排除风险：未在 74 节条文内加 "Rule 74" 字样（避免 grep 计数虚高）；未改 SKILL.md/模板/其他 worktree

## 验收三字段
status: done
acceptance: grep -c "Rule 74" = 3（≥3 PASS）；S3 diff 形态 = 3 行行尾追加（旧文逐字保留为前缀），git diff --numstat 增量 12/-3 中 S3 占 3 行、其余 9+ 行为 S1 遗留 74 节
checkpoint: 本文件
