# S0 OpenSpec tasks.md 同步检查点

## 任务
- 目标：将 `openspec/changes/todo-default-engine/tasks.md` 中 S3/S4 条目按 Rule 59.1 粒度门拆分，同步为 S3+S8、S4+S9。
- 计划：`task-todo-default-engine-20261123`
- 执行时间：2026-11-23
- 执行体：general-doc-processor

## 读文件
- `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/tasks.md`（26 行，Read 全文确认 old_string 逐字匹配）

## 修改
单处 Edit 替换（精确匹配成功）：

**old_string**（原 1.3 + section 2 标题 + 2.1-2.3）：
```
- [ ] 1.3 [S3] 规则锚四处同步 B1-B5→B1-B8：critical-rules-discipline.md:747-750（Rule 106.5）+ SKILL.md:256 + task-discipline/SKILL.md:86 索引 + skill-collaboration.md（引擎检测=B6 默认动作）

## 2. 三层载体（S4）

- [ ] 2.1 sync-todos.sh --json 输出追加 B1-B8 八条基线项条目（最小增量，不改主流程）
- [ ] 2.2 templates/task_plan.md Todo 同步段（:455-470）显式列出 B1-B8 清单锚
- [ ] 2.3 selftest-skill-collab.sh 加 B6/引擎检测锚断言 + selftest-registry.tsv 登记（不新增守护脚本）
```

**new_string**（拆分为 1.3[S3]+1.4[S8]，section 2 改为 S4+S9，2.1/2.2 标 [S4]，2.3 拆为 [S9]）：
```
- [ ] 1.3 [S3] 规则锚同步A：critical-rules-discipline.md:747-750（Rule 106.5）+ task-planner/SKILL.md:256，引用 B6/B7/B8，禁改既有语义（BP-08 SKILL.md 净增 ≤9 行）
- [ ] 1.4 [S8] 规则锚同步B：task-discipline/SKILL.md:86 索引 B1-B5→B1-B8（拆分自原 1.3，Rule 59.1 粒度门）；skill-collaboration.md 引擎检测=B6 默认动作随 1.2 一并落地

## 2. 三层载体（S4 + S9）

- [ ] 2.1 [S4] sync-todos.sh --json 输出追加 B1-B8 八条基线项条目（最小增量，不改主流程）
- [ ] 2.2 [S4] templates/task_plan.md Todo 同步段（:455-470）显式列出 B1-B8 清单锚
- [ ] 2.3 [S9] selftest-skill-collab.sh 加 B6/引擎检测锚断言 + selftest-registry.tsv 登记（拆分自原 2.3，Rule 59.1 粒度门；不新增守护脚本）
```

## 验证

### Read 复核（Edit 后）
已 Read 复核全文，新文本已落盘：1.3/1.4 拆分、section 2 标题为 `S4 + S9`、2.1/2.2 标 `[S4]`、2.3 标 `[S9]`，其余条目未变。

### OpenSpec validate
命令：
```bash
cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-todo-default-engine-20261123 && npx openspec validate todo-default-engine
```
原始输出：
```
Change 'todo-default-engine' is valid
```

## 结论
- status: PASS
- 仅修改了目标文件的指定 1 处；未触碰其他文件；未执行 git 提交。
