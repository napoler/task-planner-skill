# S4a — user-session-log.md 模板增「消费点」区块

## 插入位置
- 目标：`/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105/skills/task-planner/templates/user-session-log.md`
- 在原 `## 恢复协议`（原第 25 行）**之前**插入 `## 消费点（读取触发点 — Rule 80.8 五决策点）` 区块（含注释 + 五决策点表：①上抛裁决前/②新指令反思门/③完成声称与交付前/④子代理派发/⑤周期对照/会话恢复），保留原 `## 恢复协议` 于其后。
- 模板既有内容（渲染契约注释、条目格式范式注释、恢复协议段、`{{TASK_ID}}` 等占位符）一字未改；未引入任何新 `{{` token。

## 验收输出
1. `grep -n "消费点" <目标文件>` → `25:## 消费点（读取触发点 — Rule 80.8 五决策点）`（命中 1）
2. `grep -c "Rule 80.8" <目标文件>` → `2`（≥1）
3. `grep -c "{{" <目标文件>` → `3`（改前 3，一致，未引入新占位符）
4. `git -C <worktree> diff --stat` →
   ```
    skills/task-planner/templates/user-session-log.md | 11 +++++++++++
    1 file changed, 11 insertions(+)
   ```

## 结论
S4a 完成；模板新增 Rule 80.8 五决策点消费点读取区块，恢复协议保留，禁改清单满足。