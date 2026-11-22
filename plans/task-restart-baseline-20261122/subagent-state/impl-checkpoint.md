# 实现子代理自审检查点（impl-checkpoint）

- 任务：task-restart-baseline-20261122 —— 固化「弃旧开新 restart-from-baseline」机制（纯文本条款，零脚本）
- 角色：general-coder（实现子代理）
- 执行日期：2026-11-22
- worktree：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-restart-baseline-20261122`（分支 `wt/task-restart-baseline-20261122`，基线 master）
- status：done —— 4/4 文件改毕，逐文件 Read 回读 + 结构化 grep 校验通过
- 零脚本确认：仅改 4 个既有 markdown；未新建/修改任何 .sh/.py/hook/配置文件

## 改动明细（worktree 内绝对路径 + 关键行号）

1. `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-restart-baseline-20261122/skills/task-planner/references/worktree-isolation.md`
   - L120-147 插入 `## 4.6 方向性止损与弃旧开新（restart-from-baseline 2026-11-22，用户诉求）`（+29 行，落在 §4.5 与 §5 之间）。
   - 六个加粗子块齐：定位与核心原则(L122) / 触发门三级(L124-127) / 有效数据提取白名单 salvage-manifest(L129-131) / 从基线牵新版本标准命令序列(L133-138) / 旧线冻结登记(L140) / 反模式❌清单(L142-147)。
   - §5 反模式标题仍在 L149、§6 在 L160，未被吞。
2. `.../skills/task-planner/SKILL.md` — L185 步骤 4.5 单行末尾追加交叉锚，细则指针改为 §4.5+§4.6（+1/-1，单行未换行）。
3. `.../skills/task-planner/templates/task_plan.md` — L347 Git checkpoint 条目单行末尾追加弃旧开新(§4.6)锚（+1/-1，单行未换行）。
4. `.../skills/task-planner/templates/progress.md` — L27 在 Git checkpoint 行下新增 `[restart]` 弃旧开新占位行（+1）。

## 验收逐项（任务书 acceptance）

- [x] §4.6 六子块齐（grep + Read L120-147 复核）
- [x] 三处交叉锚在位（SKILL.md L185 / task_plan.md L347 / progress.md L27）
- [x] 零脚本（git status 仅 4 个 .md 被修改）
- [x] §5 反模式标题未被吞（L149 完好）
- [x] 4 文件均在 worktree 路径下（未碰主仓 plans/、未碰其他 worktree、未做合并）
- [x] 每个改动最小：§4.6 新节 29 行（要求 25-35），其余 3 文件各 1 行

## 验证证据

- `git diff --stat`：4 files changed, 32 insertions(+), 2 deletions(-)
- `grep -nE` 结构标题：§4.6 六子块 + §5(L149) + §6(L160) 边界完整
- `git status --short`：仅列出的 4 个 skills markdown，无越界文件
- 逐文件 Read 回读：4 个文件锚点行原文与改动意图一致，交叉锚均保持单行

## 遗留风险（≤3）

1. `outcome: RESTARTED` 为本节新引入的状态词，若计划校验/状态机脚本需识别该词，须由协调方另行评估（本任务范围仅文本条款，未改任何脚本）。
2. §4.6 引用的 Rule 96.7/103.8b/61/64/27/100/102.1e 与 §4③ 均为既有规则号，未新造编号；规则号语义以原文为准。
3. 本检查点写在派发契约明确指定的主仓路径（属契约授权例外，非越权改计划三文件 task_plan/findings/progress）。
