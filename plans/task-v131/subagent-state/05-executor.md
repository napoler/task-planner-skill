# 05-executor 检查点 — task-v131 Phase 2 第二 S-unit（init-session.sh 生成面注入）

status: SUCCESS | 时间: 2026-10-05

## 交付物
- worktree: /home/terry/task-planner-skill-worktrees/task-v131
- 改动文件（唯一）: skills/task-planner/scripts/init-session.sh（+116 行，未 commit）
  - 函数 inject_requirement_block（copy_template 定义后，≈L90 起）：
    Gate1 已含锚 → INFO 跳过；Gate2 mini 豁免（TASK_PLAN_SRC=mini-lite ∨ 产物 grep 'plan_tier: mini'）→ INFO 跳过；
    插入位=首个 '^## Goal' 行前；无 Goal 行 → awk 扫描文件头部注释块（空行/frontmatter 定界/HTML 注释开闭含跨行状态）之后；
    插入量=脚手架 9 行 + 1 空行分隔（Rule 45 注释内已声明）；quoted heredoc 保占位符。
  - 调用点：template-sense P2-S2 块之后、6 文件存在性复核（missing_files 循环）之前。
  - fail-open：awk 写出/mv 写回失败 → stderr WARN 并清理临时文件，return 0，init 不中断（理由=注入是增强非前置依赖）。

## bash -n
- SYNTAX_OK（GNU Awk 5.2.1 环境；awk 用 AND 串接条件，规避 mawk || && 限制；失败时 insat="" → 兜底 1）

## VC-2 功能实测（/tmp/v131-init-test/，CWD 必须 plans/<id> 布局）
| 路径 | 调用 | 结果 | 证据 |
|---|---|---|---|
| a general | init project-a | 锚=1（a-copy-task_plan.md；主模板自带→INFO 跳过） | grep -c '## 🎯 用户需求原文'=1，INFO 行 |
| a2 注入 bugfix | init project-a2 bugfix | 锚=1 脚手架插入 Goal 前（a2-copy；模板 181→191 行=+10） | 注入行 L9 起，模板 L8 `## Goal` 后 |
| a3 注入 无 Goal（ghost 项目模板） | init project-a3 ghost | 锚=1 插入头部注释块后（a3-copy；5→16 行=+10） | 首行即 `## 🎯...`，其后才 `<!-- template_type: ghost -->` |
| b rule-enhancement | init project-b rule-enhancement | 锚=1 INFO 跳过（b-copy） | 模板自带载体 |
| c mini 豁免 | init project-c "" mini | 锚=0，INFO 豁免行，plan_tier: mini=1（c-copy） | mini-lite 路由日志 |
| 幂等 | a2 目录重跑 init | 锚仍=1 无重复插入 | "task_plan.md already exists, skipping"+INFO |
| fail-open | CWD 只读+无锚无 Goal | WARN "awk 写出异常" → init 正常走完 6/6 verified exit=0，无锚写入、无 .v131tmp 残留 | f2/plans/tf2 |

留档副本: /tmp/v131-init-test/{a,a2,a3,b,c}-copy-task_plan.md

## issues / 登记
- mini 路径已真实可触发（tier=mini → mini-lite 路由，非"未测"）；豁免依据双标记 ①TASK_PLAN_SRC ②产物 grep plan_tier: mini。
- 已知取舍：variant 定制优先场景（PLAN_TIER=mini 但命中 variant）不豁免→照注入（中档产物必须载体），函数头注释已声明。
- 模板自带锚检测用 grep '## 🎯 用户需求原文'（H-3 锚），主模板与 rule-enhancement 变体命中即 INFO 短路。

## 恢复点
无断点，单元完成。后续（越界不归本单元）：commit 需协调前两单元未提交的 task_plan.md / rule-enhancement-type.md 改动。
