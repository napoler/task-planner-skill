# 06 task_plan.md token 化检查点（S6 单元）

- 目标文件（唯一）：`/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024/skills/task-planner/templates/task_plan.md`
- 任务 id：task-tplrender-20261024
- 状态：DONE

## 替换处数清单（每处可对应迁移映射）

| # | 原形态 | 新形态 | 处数 | 行号（改后） |
|---|--------|--------|------|--------------|
| 1 | `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` | `{{TASK_PLANNER_ROOT}}` | 9 | 4, 30, 91, 377, 379, 408, 472(x2), 506 |
| 2 | `[Brief Description]`（L1 标题） | `{{TASK_NAME}}` | 1 | 1 |
| 3 | `plans/<task-id>/user-session-log.md` | `plans/{{TASK_ID}}/user-session-log.md` | 2 | 29, 30 |
| 4 | `archive-plan.sh <task-id> --root <plans根>` | `archive-plan.sh {{TASK_ID}} --root <plans根>` | 1 | 355 |
| 5 | `<repo-parent>/<repo>-worktrees/<task-id>` | `<repo-parent>/<repo>-worktrees/{{TASK_ID}}` | 1 | 373 |
| 6 | `wt/<task-id>` | `wt/{{TASK_ID}}` | 1 | 374 |
| — | 文件头新增渲染契约注释 | — | +1 行 | 2 |

合计：`{{TASK_PLANNER_ROOT}}`×9、`{{TASK_NAME}}`×1、`{{TASK_ID}}`×5、新增注释×1。

未命中形态（grep 实证为空）：`{task-id}`、`{task-name}`、`[DATE]`、`[YYYY-MM-DD HH:MM]`、`<task>`、`<task-name>`、`{{` 既有 token。

## 自检数字

- `grep -cE '\$\{TASK_PLANNER_ROOT:-|\[Brief Description\]'` = **0**（要求 0）✅
- `grep -c '<用户原话'` = **2**（改前 2，不变）✅
- `grep -n '<task-id>'` = 空（无残留）✅
- 行数：563 → 564（+1，要求 ≤35）✅
- diff 仅含 token 替换 + 1 行新注释，无其他改动 ✅

## 保留判定清单（语义占位，逐字保留）

按迁移映射仅替换 6 类机械 token；以下尖括号/方括号占位为模型填写面，全部逐字保留：

- 需求/验收类：`<用户原话第 1 条…>`(L19)、`<按需增行>`(L20)、`<判据…>`(L25)、`<工序 1>`(L41)、`<修复 S-unit/Phase>`(L41)、`<VC-n>`(L41)
- 契约/锚点类：`<Goal/VC 表…>`(L50)、`<task_plan.md 对应章节锚>`(L50)、`<执行细节…>`(L51)、`<执行期新事实…>`(L52)、`<示例…>`(L138/L174)、`<命令+判据…>`(L138)、`<S-unit id>`(L218)、`<关键词1>`/`<关键词2>`(L218)、`<findings 小节…>`(L218)、`<是/否/不适用>`(L218)
- 表格字段类：`<uuid>`(L73)、`<path>`(L74)、`[paths]`(L75)、`<NN>`(L79)、`[询问点…]`(L78)、`[登记]`(L77)、`[检测结论]`(L80)、`[明确列出…]`、`[路径或命令]`、`[交付物可观测要求 N]`、`[One sentence…]`(L61)、`[一句话下一步动作]`(L250)、`[Question to answer]`、`[本 block 独立目标]`、`[交接产物路径]` 等
- 命令/路径示例中的非映射占位：`<skill>`(L355/L356)、`<plans根>`(L355)、`<plan-dir>`(L357)、`<repo-parent>`/`<repo>`(L373)、`<commit>`(L375)
- 并行组：`<组名>`(L328)

边界判定（已替换，理由）：
- L29/L30 `plans/<task-id>/user-session-log.md`：迁移映射明确列为「命令/路径示例中的 `<task-id>`」→ 替换为 `{{TASK_ID}}`（渲染后即真实路径，教学语义仍成立）。
- L355 `archive-plan.sh <task-id>`：命令示例，同上替换。
- L373/L374 隔离决策区块路径形态示例：迁移映射显式允许 `<task-id>` → `{{TASK_ID}}`（渲染后即真实路径示例）；同区块 `<repo-parent>`/`<repo>` 不在映射内，保留。

## 遗留风险

1. `{{TASK_PLANNER_ROOT}}` 渲染值由 init-session.sh 决定；本单元未验证脚本侧渲染实现（超范围，属 S1-S5 单元）。
2. 新增注释行含字面 `{{VAR}}`，若渲染脚本对 `{{VAR}}` 做非白名单 token 报错需确认脚本容错（`{{VAR}}` 非合法 token 名，建议脚本忽略未知 token）。
