# S10 检查点 — 项目级 plan-templates/knowledge-brief.md token 化

- 任务: task-tplrender-20261024 / S10（项目级双轨对齐）
- 状态: DONE
- 唯一改动文件: `/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024/.zcode/plan-templates/knowledge-brief.md`（+2/-1 行；86→87 行，Δ+1 ≤10）
- 未触碰: 内建 `skills/task-planner/templates/knowledge-brief.md`（兄弟单元产物）及其余任何文件

## 变更内容（2 处）
1. L1 标题 `# Knowledge Brief — {task-id}（...）` → `# Knowledge Brief — {{TASK_ID}}（...）`（花括号机械形态 → {{VAR}} 主形态）
2. L2 新增渲染契约注释：`<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->`

## 自检数字
- 花括号/方括号/路径类机械形态 grep 计数（`{task-id}|[Brief Description]|{task-name}|[DATE]|[YYYY-MM-DD|${TASK_PLANNER_ROOT:-`）= **0**
- 文件内 `{{VAR}}` 放置 = 2 处（L1 TASK_ID、L2 契约注释内 {{VAR}} 说明字面量）
- 残留 `<task-id>` = 3 处（L5/L13 注释指引、L83 命令示例），均属**语义合法面**（路径约定/填写指引），与内建版同口径保留
- 行数变化 = +1（86→87），≤10 达标

## 与内建版差异
- 内建版 = 同 2 处改动（title→{{TASK_ID}} + 契约注释），差异仅在注释文字（内建写 `{语义占位}/<plan-dir>=模型/调用方填写面`，项目级写「项目级双轨…同契约」）
- 项目级独有 §7「项目知识库回链」段（内建无此段）；其余 §1-§6 结构逐行一致 → 仅 token 迁移，未重构内容

## 依据
- 渲染器 `skills/task-planner/scripts/init-session.sh` render_template()：6 主形态 {{VAR}} + 8 兼容旧形态（含 `<task-id>`→task_id），故注释内 `<task-id>` 于 init 渲染产物中被正确替换（VC-1 产物级 grep=0 仍成立）
