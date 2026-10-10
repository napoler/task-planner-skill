# S4 材料包 — selftest-subagent-return.sh 断言清单（子代理 Read 本文件后实现）

## 目标（worktree 内唯一可写）
- 新写 /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/selftest-subagent-return.sh
- 追加一行到 /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/scripts/selftest-registry.tsv

## 风格参照（只读）
skills/task-planner/scripts/selftest-dispatch.sh（断言写法/输出格式 `Total: N PASS=N FAIL=N`/rc 语义）

## 被断言对象（只读,禁改）
- scripts/check-subagent-return.sh（返回侧四判据脚本）
- scripts/check-dispatch.sh（prompt 侧段结构校验函数 return_section_check）
- templates/subagent_dispatch.md（§7 三反污染条款）
- references/critical-rules.md（Rule 22.4b 段污染三面句）

## 断言清单（逐条成测,任一 FAIL → rc 1;全过 → rc 0）
- 断言一: check-subagent-return.sh 存在且 bash -n 通过
- 断言二: bash check-subagent-return.sh --selftest → rc=0（内置 4 夹具全 PASS）
- 断言三: stdin 喂合规 8 字段块 → stdout 含 `[return-guard] PASS` rc=0
- 断言四: stdin 喂契约外字段块（status: done 后紧跟 summary: 长文本行）→ rc=1 且 stderr 点名 summary
- 断言五: stdin 喂块尾附加块（合规块后加「## 附:验收细节」+两行说明）→ rc=1
- 断言六: subagent_dispatch.md 含三条 task-v161 条款字面（「优先级声明（task-v161」「点名禁令（task-v161」「段填写禁令（task-v161」三段 grep 各 ≥1）
- 断言七: critical-rules.md 22.4b 段（22.4b 起 22.4c 止区间）内含「污染三面与主进程动作闭环（task-v161）」与「check-subagent-return.sh」
- 断言八: check-dispatch.sh 内含 `return_section_check` 函数定义（grep `^return_section_check()` 或 `return_section_check()` 定义行）
- 断言九: heredoc 构造用户实证污染夹具 → 跑 `bash check-dispatch.sh pretool <fixture>` 非 0 且 stderr 含「返回格式段结构违规」。夹具必含要素: 三文件绝对路径（plans/task-v161-subagent-return-format/ 下 task_plan.md/findings.md/progress.md）、knowledge-brief 引用字面（brief/§）、subagent-state/ 路径、重复标题「## 返回格式## 返回格式」、三项任务清单条目（v3.1 23 段新配置摘要表 / style_exempt 统一口径 / 合图锚占位清单,条目行首用 ①②③）
- 断言十: heredoc 干净夹具（templates/subagent_dispatch.md §7 八字段原文+三文件路径+knowledge-brief 引用+subagent-state/ 路径）→ pretool rc=0

## 硬约束
- 脚本 ≤90 行;头部注释含职责/用法/夹具说明（Rule 45 What+Why 双层）
- 纯读断言:禁 git 命令、禁写被断言文件
- 两种夹具的 TASK_PLANNER_PLAN_DIR 环境变量在断言内 export 为 /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format 后执行,执行后 unset（防污染后续测试）

## registry 登记（追加一行,tab 分隔 4 列,列格式同既有行）
第 1 列 script: selftest-subagent-return.sh
第 2 列 domain: Rule 22.4b 返回格式污染三面守护
第 3 列 trigger_scenarios: subagent_dispatch.md §7 / critical-rules.md 22.4b / check-subagent-return.sh / check-dispatch.sh return_section_check 改动
第 4 列 dep_anchors: skills/task-planner/templates/subagent_dispatch.md;skills/task-planner/references/critical-rules.md;skills/task-planner/scripts/check-subagent-return.sh;skills/task-planner/scripts/check-dispatch.sh

## 完成后自跑
bash -n、bash selftest-subagent-return.sh（rc=0+Total 行）、grep registry 新行、git diff --numstat 两个文件（新脚本 +N/-0、registry +1/-0）。输出写 evidence。
