# S9 检查点 — verification.md / knowledge-brief.md token 化

- 时间：2026-10-24
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024
- 状态：**完成（含 1 条跨单元阻断级发现，需协调者裁决）**

## 1. 变更文件（仅此 2 个）
| 文件 | 变更 |
|------|------|
| skills/task-planner/templates/verification.md | +3/-2（+1 契约注释行；L77/L81 两处路径 token 化） |
| skills/task-planner/templates/knowledge-brief.md | +2/-1（+1 契约注释行；L1 标题 `{task-id}`→`{{TASK_ID}}`） |

替换明细：
- verification.md L77/L81：`${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` → `{{TASK_PLANNER_ROOT}}`（2 处，`<plan-dir>` 原样保留）
- knowledge-brief.md L1：`{task-id}` → `{{TASK_ID}}`（1 处）
- 两文件首行标题下各追加契约注释（文本逐字按派发要求）

## 2. 自检数字（命令 + 结果）
- `grep -c '\${TASK_PLANNER_ROOT:-' verification.md` → **0**（要求 0）✓
- `grep -c '{task-id}' knowledge-brief.md` → **0**（要求 0）✓
- `grep -c '{{TASK_PLANNER_ROOT}}' verification.md` → 2；`grep -c '{{TASK_ID}}' knowledge-brief.md` → 1
- 行数：129→130 / 77→78，合计 **+2 行**（要求 ≤8）✓
- 语义占位改前后计数（HEAD vs NOW）：`{Goal 语句}` 1/1、`{evidence}` 2/2、`{粘贴 stats 命令原文输出}` 1/1、`{Name}` 3/3、`VC-` 9/9、`### Phase` 3/3、`<task-id>` 0/0（verification）/2/2（knowledge）；`<plan-dir>` 2→3、0→1（增量仅来自契约注释文本本身，非语义改动）
- 渲染模拟（/tmp 沙箱，复用脚本内 `render_template` 真身 + 真值 sed 序列）：
  - `{{TASK_ID}}` → `demo-task-20261024` ✓
  - `{{TASK_PLANNER_ROOT}}` → `/…/skills/task-planner` 绝对路径，`/scripts/check-delegation.sh stats <plan-dir>` 后缀原样 ✓

## 3. 保留清单（逐字未动）
`<plan-dir>`（3 处：1 指令行 + 1 代码块 + 1 契约注释）、`{Goal 语句}`、`{Name}`×3、`{evidence}`、`{粘贴 stats 命令原文输出}`、`[date]`/`Last verified`、VC-1..VC-5 示例行与 Phase Gates 三段结构、knowledge-brief.md 注释内 `<task-id>`×2（L4/L12 指引文字，命中「模板注释全部指引文字禁改」；且 compat 层 `s|<task-id>|` 已可渲染，无功能损失）、`YYYY-MM-DD`/`<待沉淀>`（两文件本无）。

## 4. ⚠️ 跨单元阻断发现（需 S3/S4 或协调者处置，不在本单元文件范围）
契约注释字面含 `{{VAR}}`，命中 `render_template()` 残留校验 ERE `\{\{[A-Z_][A-Z_0-9]*\}\}`（init-session.sh:243 + 调用侧 :982）→ 渲染 **rc=2**，调用侧置 `_render_fail=1` → **init exit 1（fail-closed）**。已在 /tmp 沙箱实测复现：
```
[render] 残留未定义 token: {{VAR}} （文件: verification.md，fail-closed）
--- verification.md rc=2
```
影响面：全部 7 个已加该注释的模板（findings/progress/notepad-learnings/user-session-log/task_plan + 本单元 2 个）均会命中；即「新增计划文件后 init 必然失败」。
建议二选一（择一即可，勿叠加）：
- A（推荐，改一处）：residual 扫描跳过 HTML 注释行，或把 `VAR` 加入白名单 —— 保留统一注释文本，改动最小且语义正确（契约注释本就是说明 `{{大写var}}` 形态）。
- B：统一把注释里的 `{{VAR}}` 改写为不含大写 token 形态的等价表述（如「双花括号大写变量」），7 文件同步改，但契约文本失去可视化样例。
本单元按派发文本与既有 5 个兄弟文件保持一致，未擅自改动 init-session.sh（非本单元文件）。渲染功能本身（替换/幂等/语义占位不动）经沙箱验证正确。
