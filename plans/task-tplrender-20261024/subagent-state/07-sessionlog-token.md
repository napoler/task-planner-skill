# S7 单元检查点 — session-log / notepad 模板 token 化

- 任务：task-tplrender-20261024
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024
- 状态：DONE（含 1 条跨文件系统性风险上报，需主进程裁决）
- 时间：2026-10-24

## 1. 变更清单（仅 2 文件，git diff --stat 实测）

```
skills/task-planner/templates/notepad-learnings.md | 3 ++-
skills/task-planner/templates/user-session-log.md  | 5 +++--
```

| 文件 | 变更 | 行数 |
|------|------|------|
| user-session-log.md | L1 `{task-id}` → `{{TASK_ID}}`；L8 `plans/<task-id>/` → `plans/{{TASK_ID}}/`；标题下新增渲染契约注释行 | 26 → 27 (+1) |
| notepad-learnings.md | L1 `{task-name}` → `{{TASK_NAME}}`；标题下新增渲染契约注释行 | 42 → 43 (+1) |

合计行数变化 +2（约束 ≤8，通过）。

## 2. 逐字保留清单（未动）

user-session-log.md：L11 `## #N | YYYY-MM-DD | 来源：…` 示例行、L15 `### #N 理解镜像 | YYYY-MM-DD`、
L16 `<模型对该条请求的整理理解…>`、L12/13 `<用户任务需求…>`/`<引用块续行…>`、L18-22 注释内 `#N`/`YYYY-MM-DD`/`#1、#2 顺延` 教学文字、L26 恢复协议 `#1`。
notepad-learnings.md：L17 `<日期/出处>`/`<新证据>`、L26/27 `[specific change confirmed]`/`[specific issue and resolution]`、L42 空表行。
未出现 `{task-name}`/`[DATE]`/`[YYYY-MM-DD HH:MM]`/`${TASK_PLANNER_ROOT:-…}` 其它形态（grep 盘点确认）。

## 3. 自检数字（实测命令）

- `grep -c '{task-id}' user-session-log.md` = **0**（改前 1）；notepad `{task-name}` = **0**（改前 1）
- `<task-id>` 残留 = 0（改前 1）
- 残留机械形态全扫描（`{task-id}|{task-name}|<task-id>|<task>|[DATE]|[YYYY-MM-DD HH:MM]|TASK_PLANNER_ROOT`）rc=1 无匹配
- 渲染仿真（复制到 /tmp 跑脚本同款 6 条 sed）：`{{TASK_ID}}`→demo-task、`{{TASK_NAME}}`→demo-project 均生效；`#N`/`YYYY-MM-DD` 渲染后仍保留
- `#N` / `YYYY-MM-DD` 计数偏差说明：user-session-log `#N` 6→**7**、`YYYY-MM-DD` 3→**4**；notepad `#N` 0→**1**、`YYYY-MM-DD` 0→**1**。偏差全部来自**规定新增的渲染契约注释行本身**（其文本含 `#N` 与 `YYYY-MM-DD` 字样）。以内容级 diff 证明原有示例行零改动：
  `git show HEAD:<file> | grep -E '#N|YYYY-MM-DD'` 与 现文件同行（剔除契约行）`diff` → **IDENTICAL_BY_CONTENT**（行号位移 +1 由新增行导致）。

## 4. 风险上报（P0，需主进程裁决 — 跨 7 个模板的系统性问题）

**现象**：init-session.sh 在 S4 加入 fail-closed 残留 token 门禁（L233-247 `render_template` 内 + L979-990 调用侧），扫描 ERE `\{\{[A-Z_][A-Z_0-9]*\}\}`，命中即 `return 2` → init 整体 `exit 1`。

**证据**：规定的注释文本含字面量 `{{VAR}}`，命中该 ERE。渲染仿真（7 个模板全部跑一遍脚本同款 sed 后执行门禁同款 grep）：

```
findings.md -> RESIDUAL: {{VAR}}
knowledge-brief.md -> RESIDUAL: {{VAR}}
notepad-learnings.md -> RESIDUAL: {{VAR}}
progress.md -> RESIDUAL: {{VAR}}
task_plan.md -> RESIDUAL: {{VAR}}
user-session-log.md -> RESIDUAL: {{VAR}}
verification.md -> RESIDUAL: {{VAR}}
```

即：**按字面执行该注释模板会让每次 init-session 在渲染阶段中止**（7/7 模板全部命中）。本单元按派发指令逐字保留 `{{VAR}}`（与 4 个兄弟单元产物保持一致），未擅自改写，以免造成跨文件不一致。

**建议修法（二选一，主进程统一决策）**：
- A（推荐，1 行）：门禁扫描前剥离 HTML 注释——如 `sed 's|<!--.*-->||g'`（多行注释块需先按行处理）或在残留 grep 上加 `| grep -v '^<!--'`；注释本是给模型/读者的人读文本，不应参与渲染契约校验。
- B（5 文件）：把 7 个模板注释里的 `{{VAR}}` 统一改为不匹配 `[A-Z_]` 的写法（如 `{{大写变量名}}`）。

## 5. 未完成/遗留

- 未验证 init-session.sh 端到端（超出本单元范围；脚本本身仍在被 S3/S4 单元修改中）。
- 未触碰任何其它文件（`git status` 显示的 findings.md/progress.md/task_plan.md/init-session.sh 变更来自兄弟单元）。
