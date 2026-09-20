# 2-code-assistant checkpoint（task-v085 S-unit）

## S1 — critical-rules.md 追加 Rule 37（完成）

- 文件：`/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/references/critical-rules.md`
- 行数变化：315 → 327（净增 12 行，上限 +70 内）
- 追加位置：`### 37` 章节 @ line 317；子条 37.1 @321 / 37.2 @322 / 37.3 @323 / 37.4 @324 / 37.5 @325；边界明示（FMEA R1 兜底）@327
- 纯追加验证：git diff 删除=0（numstat `12 0`），未改动既有任何行

### 验收 grep 实际输出
```
$ grep -n "^### 37 " skills/task-planner/references/critical-rules.md
317:### 37 任务类型机制画像（mechanism profile — 按 template_type 裁剪机制适用性）

$ wc -l skills/task-planner/references/critical-rules.md
327 skills/task-planner/references/critical-rules.md   （原 315，+12 ≤ +70）

$ git diff --stat skills/task-planner/references/critical-rules.md
 skills/task-planner/references/critical-rules.md | 12 ++++++++++++
 1 file changed, 12 insertions(+)

$ git diff --numstat ...
12 0 skills/task-planner/references/critical-rules.md   （删除=0，纯增行）

$ grep -n "^37\.\|边界明示（FMEA R1 兜底）" skills/task-planner/references/critical-rules.md
321:37.1 **画像表权威源** ...
322:37.2 **判定时点** ...
323:37.3 **三类机制组** ...
324:37.4 **消费侧** ...
325:37.5 **机制** ...
327:**边界明示（FMEA R1 兜底）** ...
```

### 内容符合度自查（对材料包 S1 逐条）
1. 末尾纯追加 `### 37`，零改写既有行 —— 通过（numstat 12/0）
2. 五子条齐备：37.1 权威源=template-mapping.md §九+防双源、37.2 判定时点=计划创建期+general 兜底自动判定、37.3 代码/内容/通用三组（内容组明示不适用 Code Review Gate 与代码执行体路由）、37.4 消费侧三点（2.5 委派检查点/CR Gate 触发条件/content_quality 终验）、37.5 机制（mechanism_profile_enforce 默认 warn 三档+check-complete 末段+selftest-mechanism-profile.sh）—— 通过
3. FMEA R1 兜底措辞逐字包含（Rule 19/25/15/31 通用守卫不变）—— 通过（line 327）
4. 风格对齐 Rule 36 密度，总增 12 行 ≤70 —— 通过

### 负结果报告（排除的风险）
- 检查了相邻 Rule 34/35/36 风格与全文 315 行：未发现既有 37.x 编号冲突，无重复章节
- 未检查其他文件（S2 属 3-code-assistant checkpoint 范围，本 S-unit 只写该文件 + 本 checkpoint）
- diff 确认无 BOM/空白行意外变更，git status 仅 M 该一个文件
