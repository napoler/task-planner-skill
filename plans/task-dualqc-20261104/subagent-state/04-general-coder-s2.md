# 检查点：04-general-coder-s2（task-dualqc-20261104）

## 自审（S2）
- [x] 文件 1 修改：skills/task-dispatch/references/critical-rules-dispatch.md
  - 在 96.2 段落（以「……不改任何既有升降档语义。」结尾）后插入新段落「**复检升档衔接（Rule 103.4）**：双轮质检的第二轮复检体按本表升一档选型（轻→中→重封顶；重档封顶同档独立上下文，争议升级 decision-arbiter）→ Rule 103（双轮质检与同步完整性细则）。」
  - 96.2/96.3 原文零改动（git diff 显示仅插入，无删除行）
- [x] 文件 2 修改：skills/verification-gate/references/critical-rules-verification.md
  - 在 84.7 块末行（以「——内容错误审查能力为本任务 R3 核心诉求，84.7 是其规则层载体。」结尾）后追加 bullet「- **衔接（Rule 103，task-dualqc-20261104）**：双轮质检与同步完整性审查细则（103.2 执行体自审/103.3 全新子代理独立复检升档/103.5 复检任务书简洁四要素/103.6 同步核对清单）→ task-dispatch 卫星 Rule 103；本条 84.7.2 为其先例面，复检档位与四要素以 103 为准。」
  - 84.7 块原文零改动

## 验收自核
- `grep -c '复检升档衔接（Rule 103.4）' /mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104/skills/task-dispatch/references/critical-rules-dispatch.md` = 1
- `grep -c '衔接（Rule 103，task-dualqc-20261104）' /mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104/skills/verification-gate/references/critical-rules-verification.md` = 1
- `git -C /mnt/data/dev/task-planner-skill-worktrees/task-dualqc-20261104 diff --stat` 仅这两文件、纯插入（共 34 行新增，0 行删除）

## 结果
状态：done
