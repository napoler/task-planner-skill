# S4 检查点 — 通用 templates/task_plan.md 两处微调（code-assistant）

status: complete（本 S-unit 落盘，commit 由主进程逐 Phase 执行）

## 改动明细（纯插入，2 行 ≤8，删除=0）
目标文件：/home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/templates/task_plan.md

1. Code Review 配置节：`| `code_review` | `n/a` / `required` |` 值行之后插入（现 L25）：
   `> 默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值。`
2. Executor 示例行 `- **Executor:** code-assistant（haiku-1）`（现 L181）之后追加注记（现 L182）：
   `（示例为代码组画像；非代码任务按 template-mapping.md §九 机制画像选内容类执行体，如 article-writer）`

既有行零改动（git diff 仅 2 个 + 块）。

## 验收 grep 实际输出
命令：`grep -n "机制画像" skills/task-planner/templates/task_plan.md`（worktree 根执行）
```
25:> 默认按 template_type 机制画像自动判定（Rule 37 + template-mapping.md §九）：代码组默认 required，内容组默认 n/a，通用组未声明时按通用守卫；显式声明优先于画像默认值。
182:（示例为代码组画像；非代码任务按 template-mapping.md §九 机制画像选内容类执行体，如 article-writer）
```
命中 2 处（验收要求 ≥2，通过）。

命令：`git diff --numstat skills/task-planner/templates/task_plan.md`
```
2	0	skills/task-planner/templates/task_plan.md
```
删除=0、净增 2 行 ≤8，通过。

## 读写契约核对
- 读：材料包 4-code-assistant-brief.md（S4 节）+ 目标文件 L5-39/L170-194
- 写：仅目标文件 + 本检查点；plans 三文件只读未写；未触碰其他 worktree/主仓 skills 文件
- 负结果：既有条目区（L22-28 表格、L182-188 派发单元表注释）无冲突，纯插入未破坏 check-complete.sh 可能 grep 的既有锚行（FMEA R4 核对：锚区行文本未变，仅下行位 +1）

## next_step
主进程：commit S4 → 派发 S5（seq 6，template-guide.md 计数联动 + selftest-template-lifecycle 全量）→ Phase 2 收尾 commit。
