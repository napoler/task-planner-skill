# D-fixes — todo-skill 3 项 + store 重置（F-01..F-04, F-06）

执行时间：2026-10-19 ｜ worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v191-project-audit-sync（只改此 worktree）

## 逐条结果

### F-01 ｜ skills/todo-skill/WORKFLOW.md:14 ｜ 已修
- 改前：`| **Model** | mini |`
- 改后：`| **Model** | haiku |`
- 依据：同目录 SKILL.md frontmatter L17 `model: haiku`（Read 确认）；「mini」不在 ZCode 模型档位词汇内
- 验证：grep `mini` WORKFLOW.md 零命中 ✅

### F-02 ｜ skills/todo-skill/WORKFLOW.md:15 ｜ 已修
- 改前：`| **SKILL.md** | \`~/.claude/skills/todo-skill/SKILL.md\` |`
- 改后：`| **SKILL.md** | \`~/.zcode/skills/todo-skill/SKILL.md\` |`
- 验证：grep `.claude/skills` WORKFLOW.md 零命中 ✅

### F-03 ｜ skills/todo-skill/tools/cli_todo-manager.ts:64 ｜ 已修
- 改前：`*   迁移对等对照表见 plans/task-todo-skill-ts/progress.md。`（该目录不存在，死引用）
- 改后：`*   进度账本已随 task 归档，见 git log（2026-08-29 迁移）。`
- 验证：grep `task-todo-skill-ts` 全 cli 文件零命中 ✅

### F-04 ｜ skills/todo-skill/SKILL.md:40/53/100 ｜ 已修
- 改法：在工具表（原 L40）后**就近加一行说明注释**，不改变任何命令本身（L53 `plan`、L100 `update` 调用保持原样）
- 新增（L42）：`> 路径说明：工具表中 \`tools/...\` 为技能目录相对路径；已安装时解析基准 = \`~/.zcode/skills/todo-skill/tools/\`（cwd≠技能目录时需带全路径调用）。`
- 依据：仓内裸相对路径惯例（task-discipline 同式）保留，仅补解析基准
- 验证：grep `路径说明` SKILL.md 命中 L42 ✅

### F-06 ｜ skills/todo-skill/tools/store.json:1-5 ｜ 已重置
- 改前：`{"tasks":[],"created_at":"2026-06-29T…","updated_at":"2026-07-05T…"}`（历史生产数据残留；tasks 本为空）
- 改后：`{"tasks":[],"created_at":null,"updated_at":null}`
- 依据：cli L124 `DEFAULT_STORE = { tasks: [], created_at: null, updated_at: null }`（Read 确认），重置形态与 CLI 空结构完全一致；读路径读空 store 不触发 created_at 回填（仅写命令回填）
- 验证：`TODO_STORE_FILE=/tmp/… node cli_todo-manager.ts list` → `{"tasks":[],"count":0}` 正常 ✅

### F-05 ｜ iterative-optimizer / error-fix-prompt-forge frontmatter 缺 model/tools ｜ **只登记不修**
- 登记内容：两技能 frontmatter 均无 model 行与 tools/allowed-tools 声明；仓级 frontmatter 现状不统一（task-planner 亦无 model），属仓级约定缺失，需用户单独裁决后再统一补（若补，三处同补防风格漂移）

## 验证汇总
- CLI 改动后实跑：`node --experimental-strip-types cli_todo-manager.ts --help` 与 `list` 均通过（node v22.22.0）
- grep 自检 F-01/F-02/F-03/F-04 全部通过（见上）
- 负结果：本组 3 技能内 `~/.claude`、`task-todo-skill-ts`、`mini` 字样已清零；硬编码绝对路径未新增
- git status：本 worktree 内本次改动仅 4 文件（SKILL.md / WORKFLOW.md / cli_todo-manager.ts / store.json，均在 skills/todo-skill/ 下）
