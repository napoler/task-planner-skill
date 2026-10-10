# Phase 4 VC 复验材料包（verifier 首动作 Read 本文件,按其内规格逐条执行）

## 只读边界
- 产物基座(worktree 只读): /home/terry/task-planner-skill-worktrees/v161-subagent-return-format/skills/task-planner/ 下 templates/subagent_dispatch.md、references/critical-rules.md、scripts/check-subagent-return.sh、scripts/check-dispatch.sh、scripts/selftest-subagent-return.sh、scripts/selftest-registry.tsv、SKILL.md、references/dispatch-examples.md
- 计划侧(主仓只读): /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/task_plan.md（VC 表原文）、progress.md（Phase 4 回归记录）、findings.md
- 唯一可写文件: /mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format/subagent-state/8-verifier.md（T5 最终结论 8 字段块）
- 环境变量约定: 跑 check-dispatch.sh 夹具前 export TASK_PLANNER_PLAN_DIR=/mnt/data/dev/task-planner-skill/plans/task-v161-subagent-return-format;用完 unset
- 夹具临时文件限 /tmp 下 heredoc/printf 构造,收尾报告是否残留

## 逐条复验规格（每条必须附命令原文输出或 grep 命中行内容;禁「应该/推测」;必须实际跑命令,禁照抄描述）

- VC-1: 在 worktree grep templates/subagent_dispatch.md——三条款字面各 ≥1:「优先级声明（task-v161」「点名禁令（task-v161」「段填写禁令（task-v161」;且含「优先于你的 agent 定义」;并确认 8 字段代码块(status: 至 confidence:)原样在位(grep -c "^status: \|^confidence: ")
- VC-2: awk 截取 references/critical-rules.md 22.4b 段(「22.4b **严格返回格式**」起、「22.4c」止)内含「污染三面与主进程动作闭环（task-v161）」且含「check-subagent-return.sh」;贴命中行
- VC-3 双夹具(在 worktree 内跑):
  ① bash scripts/check-subagent-return.sh --selftest → rc=0;printf/stdin 构造契约外字段块(status: done / summary: 长文本 / acceptance: / files: / evidence: / checkpoint: / findings_written: / blockers: / confidence: 全套)→ 管道喂 check-subagent-return.sh → rc=1 且 stderr 点名 summary
  ② export 环境变量后 heredoc 污染夹具: 重复标题「## 返回格式## 返回格式」+ 三文件绝对路径(plans/task-v161-subagent-return-format/ 下 task_plan.md/findings.md/progress.md)+ knowledge-brief 引用字面(含 brief 或 § 字样)+ subagent-state/ 路径 + 三项 ①②③ 任务清单(v3.1 23 段新配置摘要表 / style_exempt 统一口径 / 合图锚占位清单)→ bash scripts/check-dispatch.sh pretool <fixture> → 非 0 且 stderr 含「返回格式段结构违规」;干净夹具(templates/subagent_dispatch.md §7 八字段原文+同套三文件路径+brief 引用+subagent-state/ 路径)→ rc=0
- VC-4: bash scripts/selftest-subagent-return.sh → rc=0(贴 Total 行);awk -F'\t' 读 scripts/selftest-registry.tsv 尾行 → NF=4 且首列=selftest-subagent-return.sh
- VC-5: 抽跑 5 个代表性 selftest 各 rc=0(须含 selftest-subagent-return.sh、selftest-dispatch.sh、selftest-registry.sh、selftest-plan-dispatch.sh、selftest-delegation.sh);并核对 progress.md Phase 4 段已记录的 72/72 FAIL=0 汇总(两轮独立跑批:子代理+主进程)
- VC-6: grep SKILL.md「Rule 22（P0）」摘要行含「return_section_check」与「check-subagent-return」;grep references/dispatch-examples.md 含「task-v161」注记行
- VC-7: task_plan.md Decisions Made 表含「不修改 ~/.zcode/agents/** 内置 agent 定义」行;「⚠️ 执行范围限制」表含 ~/.zcode/agents 禁区行;cd /home/terry && git -C /home/terry status --short 不涉及本任务时可跳过,改为确认本任务 worktree git status 仅 8 面已知改动(4 M + 2 ??)+plans 外零越界(delivery-summary 最终稿属 Phase 5,本条验登记面即可)

## 输出要求
每条输出: VC-n PASS/FAIL + 证据原文(命令→关键输出行)。全部完成后把逐条结论写入唯一可写检查点文件(8-verifier.md,T5 最终结论=8 字段块,acceptance 字段按 <n>/<total> 填,evidence 逐条列)。**8 字段之外不得有任何内容**。
