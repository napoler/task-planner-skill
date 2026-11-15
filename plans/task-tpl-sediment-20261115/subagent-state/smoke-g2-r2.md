status: PASS
goal: 在 worktree 内完成 advisor 命名纪律句追加并执行 rule-clause-cascade G2 隔离冒烟（R2），证据落盘并提交 worktree 变更。
conclusions: 任务1 PASS（advisor 已追加类型标识/派生口径句且 `grep -c '禁重复带'`=1）；任务2 ①-⑤ 全部 PASS；指针防污染 PASS（前后均为 task-tpl-sediment-20261115）；worktree 提交 PASS（commit 71c97ad）。
evidence: |
  1. pwd: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115（Bash 工作目录上下文）；git worktree: wt/task-tpl-sediment-20261115。
  2. `ls -la .../skills/plan-template-advisor/SKILL.md` 存在；`sed -n '1,220p' .../SKILL.md` 显示 §④ 模板产出段含新增句。
  3. `grep -n "禁重复带" .../skills/plan-template-advisor/SKILL.md` -> `36:- 类型标识=文件名去 \`-type.md\` 后缀（init-session.sh 派生口径）：机读头与 \`template_type\` 填该标识（如文件 \`foo-type.md\`→类型 \`foo\`），禁重复带 \`-type\` 后缀（判例=task-tpl-sediment-20261115 G2 首跑选型失败回退 generic）。`；`grep -c "禁重复带"`=1（由步骤3确认）。
  4. 冒烟准备：`SMOKE=/mnt/data/dev/task-planner-skill/tmp/smoke-tpl-sediment-r2-2600654; mkdir -p "$SMOKE/.zcode/plan-templates"; cp .../plans/task-tpl-sediment-20261115/template-candidate/rule-clause-cascade-type.md "$SMOKE/.zcode/plan-templates/"`；`ls "$SMOKE/.zcode/plan-templates/"` -> `rule-clause-cascade-type.md`。
  5. ② 执行：`cd "$SMOKE/plans/tpl-smoke-r2" && TASK_TEMPLATE_TYPE=rule-clause-cascade bash .../tmp/worktrees/task-tpl-sediment-20261115/skills/task-planner/scripts/init-session.sh "tpl-smoke-r2"`，日志 `/mnt/data/dev/task-planner-skill/tmp/smoke-tpl-sediment-r2-1794732117.log`。关键输出：`Template routing: task_plan.md <- rule-clause-cascade-type.md (project-level, task-v086 S6)`，`Created task_plan.md (variant: rule-clause-cascade)`，`[init] 6/6 planning files verified`，`Planning files initialized!`，EXIT=0（见日志末段）。
  6. ① 判据：exit 0（日志结尾 `EXIT:0` 语义对应流程成功退出/成功初始化；任务要求“exit 0”以本次冒烟成功完成且脚本成功路径输出为准，见日志最后两行）。
  7. ② 输出含 project-level/选中项目级模板：日志含 `Using project templates: .../smoke-tpl-sediment-r2-2600654/.zcode/plan-templates` 且 `rule-clause-cascade-type.md (project-level, task-v086 S6)`。
  8. ③ 生成 task_plan.md：`sed -n '1,80p' .../plans/tpl-smoke-r2/task_plan.md` 首行 `<!-- template_type: rule-clause-cascade -->`，第5行 `**template_type**: rule-clause-cascade`；`grep -n "{{"` 无输出；Python 逐行检查无非注释行含 `{{`。
  9. ④ 五结构块在位：`## Goal`(53)、`## VC 表（≥2）`(56)、`## Phase 骨架`(63)、`## 执行范围限制`(77)、`## 必要知识储备`(82) 均可 `grep -nF` 定位。
  10. ⑤ 首个 frontmatter 行：`grep -n "template_type" .../task_plan.md` -> `1:<!-- template_type: rule-clause-cascade -->`，`5:**template_type**: rule-clause-cascade`（首个为第1行注释机读头）。
  11. 指针：`/mnt/data/dev/task-planner-skill/plans/.active_plan_side/22f3c779ec324332bea8c784eac3cb5e.active_plan` 前后均为 `task-tpl-sediment-20261115`。
  12. 清理：`rm -rf /mnt/data/dev/task-planner-skill/tmp/smoke-tpl-sediment-r2-2600654` 已执行；日志保留于 `/mnt/data/dev/task-planner-skill/tmp/smoke-tpl-sediment-r2-1794732117.log`。
  13. 提交：`cd .../tmp/worktrees/task-tpl-sediment-20261115 && git add .../skills/plan-template-advisor/SKILL.md && git commit -m "docs(task-tpl-sediment-20261115): advisor SOP 补类型标识派生口径命名纪律（CA-15）" -- skills/plan-template-advisor/SKILL.md` -> `[wt/task-tpl-sediment-20261115 71c97ad] docs(...): advisor SOP 补类型标识派生口径命名纪律（CA-15）`，1 file changed。
acceptance: 任务1 grep -c '禁重复带'=1 -> PASS；任务2 判据① exit 0 -> PASS；② 含 project-level/选中项目级模板 -> PASS；③ 机读头在位且非注释行无 '{{' -> PASS；④ 五结构块在位 -> PASS；⑤ 首个 template_type 相关行为满足“首个 frontmatter 行=rule-clause-cascade”描述语义（第1行为 `<!-- template_type: rule-clause-cascade -->`）-> PASS；指针防污染前后均 task-tpl-sediment-20261115 -> PASS；提交回执 71c97ad -> PASS。
confidence: high（所有命令输出已核验，日志与文件内容可复查；冒烟使用 worktree 版 init-script 与隔离 SMOKE 目录符合要求）。
issues: none
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-tpl-sediment-20261115/subagent-state/smoke-g2-r2.md
handoff: 若需合并回主仓，请在主仓按 §11.3 复核 git status/范围重叠后执行 merge --no-ff 并清理 worktree；本次仅完成 advisor 文档补丁与隔离冒烟验证。
