# S11 检查点：SKILL.md 指示面更新（tplrender）

## 改动（1 文件：skills/task-planner/SKILL.md @ worktree）
1. `SKILL.md:40` — 初始化命令示例补任务名参数：`bash scripts/init-session.sh` → `bash scripts/init-session.sh "<任务名>"`（任务名=$1，渲染进产物）
2. `SKILL.md:41` — 新增 1 行要点「脚本侧渲染（tplrender 2026-10-24）」：6 变量+8 旧形态兼容映射、${TASK_PLANNER_ROOT:-…} 死串修复、模型禁手工修正机械占位、语义占位例外、fail-closed exit 1
3. `SKILL.md:234` — I/O 契约「示例：」行同步为 `bash <skill>/scripts/init-session.sh "<任务名>"`

## 自检数字
- `grep -n "渲染层\|render_template"` → 命中 :41（≥1 通过）
- `grep -c 'init-session.sh'` 改前后 = 3 行 vs 3 行（:40/:43/:234，只增不丢）
- 行数 268 → 269（+1，≤ +6/-3 通过）
- 其他区块/frontmatter 未动；负结果：未发现 init-session.sh 其他出现处（grep 全文件仅 3 行）

## 状态：DONE
