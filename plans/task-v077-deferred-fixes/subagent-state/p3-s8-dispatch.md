# P3 派发单元 S8 任务书（CD selftest 扩展 6 断言锁 P2 契约）

在 task-planner 仓 worktree 中执行本单元：selftest-conclusion-discipline.sh 扩展 CD-18..CD-23 六断言。只改这一个文件。

三文件路径（绝对路径，每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p3-s8.md
知识包：/mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/knowledge-brief.md §3 锚点表最后一行（selftest-conclusion-discipline 行）+§4 易错点 5

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes/skills/task-planner/scripts/selftest-conclusion-discipline.sh

## 改动清单（先 Read 全文拿现状再 Edit）
1. 变量区（L21-26 现有 SCRIPT_DIR/SKILL/RULES/DISPATCH/TMPL/NOTEPAD_TPL）追加三个路径变量（照既有变量定义风格，SCRIPT_DIR 相对解析）：
   - SMART="$SCRIPT_DIR/smart-merge-back.sh"
   - PLANWRITER="$SCRIPT_DIR/../companion/agents/plan-writer.md"
   - TPL_PLAN="$SCRIPT_DIR/../templates/task_plan.md"
   - README_SKILL="$SCRIPT_DIR/../README.md"
   - BGATE="$SCRIPT_DIR/../references/batch-quality-gate.md"
   （按实际需要的数量加，命名照既有风格微调即可）
2. CD-17（L60-61）之后、Total 行（L63）之前插入六条新断言（沿用既有 check 函数调用风格，锚用 grep 行内容非裸行号）：
   - CD-18: README_SKILL 含 `Rules 1-35`
   - CD-19: BGATE 含 `隶属 Rules 1-35`
   - CD-20: PLANWRITER 含 `纯数字`（s_unit_id 契约行）
   - CD-21: TPL_PLAN 含 `ID 列一律纯数字`（④ 注释行）
   - CD-22: TMPL（subagent_dispatch）含 `机械求和`（禁自报汇总行）
   - CD-23: SMART 含 `DEPLOY_SRC`（部署源换源在位）且含 `禁回退 SKILL_ROOT`（fail-closed 在位）——可拆两条则 CD-23/CD-24
3. 头注释同步：L4-15 断言清单区追加 CD-18..(23|24) 描述行；L17 计数 `17 断言` → 实际新总数（23 或 24）
4. 引用描述（如头注释有「task-v076」字样的定位句）按需补一行 task-v077 扩展注记

## 自验
1. worktree 内实跑 `bash skills/task-planner/scripts/selftest-conclusion-discipline.sh` 末行 Total：全 PASS FAIL=0（总数=既有 17+新增数）
2. `bash -n` 语法过
3. `git -C /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes diff --stat` 本次新增仅该文件
4. 邻接保护：`bash skills/task-planner/scripts/selftest-smart-merge.sh` 末行仍 15/15（确认无连带破坏）

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 4 条自验逐项原文行
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/p3-s8.md
findings_written: none
blockers: none|一句话
