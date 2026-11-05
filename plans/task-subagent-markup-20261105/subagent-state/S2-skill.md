动作摘要：在 worktree 内 skills/task-planner/SKILL.md 的 2.5 [A] 委派检查点行之后插入「使用点标注速查（Rule 104.2 就地版）」就地版表格。
修改文件清单：
- /mnt/data/dev/task-planner-skill-worktrees/task-subagent-markup-20261105/skills/task-planner/SKILL.md (+7 行)

验收证据（grep 输出原文）：
82:     **使用点标注速查（Rule 104.2 就地版 — 默认执行体，偏离须 `[markup-exempt] 理由`）**：
83-     搜索定位→Explore｜网络调研→Web Search Agent/general-researcher｜官方文档→Doc Search Agent｜
84-     大文件/日志→log-distiller｜检查验证审查→Verifier/Code Reviewer/critic｜批量既定步骤→executor｜
85-     媒体批量质检循环→image/video-generation-executor｜长耗时管道→code-runner 或后台执行｜
86-     批量簿记→plan-bookkeeper｜单文件小改→Code Assistant｜中等编码→general-coder｜
87-     独立创作→general-writer｜分析归因→general-analyst｜偏移检查→drift-checker｜方案终裁→decision-arbiter
88-     （全文与触发判据见 `../task-dispatch/references/critical-rules-dispatch.md` Rule 104；主进程保留=编排/路由/派发/回收/决策/三文件回填/白名单①-⑥）
grep -c "使用点标注速查": 1

插入行号：82-88（新插入块，插入于原 81 行之后）

邻近上下文 3 行（插入前后）：
80-  - [ ] **Phase 执行循环（每 Phase 独立闭环）**
81-  1. [M] **开启 Phase**：`Edit task_plan.md` 状态→`in_progress`；**R 锚定复诵**（v168）：Read「🎯 用户需求原文」→ progress 段首行写 `- **R 锚定**：本 Phase 服务 R<n>「<一句话复述>」`；与 Goal 或当前动作不符=先修计划再开工
82+     **使用点标注速查（Rule 104.2 就地版 — 默认执行体，偏离须 `[markup-exempt] 理由`）**：  （插入）
...
81 原行（修改后保留）：2.5 [A] **委派检查点（Rule 25）**：Phase Executor≠主进程 → ...（见 grep 上下文行号 81 在插入后序号不变；实际插入位置：原81行之后新添82-88，原82变为89）
（精确：sed -n '79,92p' 显示 81->原委派检查点，82起为新插入块，89为原2.5b）

未完成项：无
检查点路径：/mnt/data/dev/task-planner-skill/plans/task-subagent-markup-20261105/subagent-state/S2-skill.md
风险：无（仅插入指定内容，未改动其他行）
下一步建议：按计划继续后续子任务
