# plan-writer 派发任务书（task-v078-guard-fp-fixes 计划撰写，2026-09-17）

你是 plan-writer。先 Read 本文件与下方材料包，然后撰写计划文档。

## 第一步 Read 清单
1. /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md（全部锚点与设计裁决，以此为准禁凭记忆）
2. /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/findings.md（Requirements+Research Findings 段）
3. /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/rule-enhancement-type.md（模板骨架）

## 产出（覆盖写）
A. /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/task_plan.md
B. /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/knowledge-brief.md

## 计划参数（照填不得改）
- task-id: task-v078-guard-fp-fixes；template_type: rule-enhancement；interaction_mode: silent（登记依据：自治会话+v074-v077 四轮先例）；chain_mode: single；config.json 零新键；code_review 不声明
- 隔离：worktree /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes，分支 wt/task-v078-guard-fp-fixes 自 master 新建；冲突信号=主仓仅 plans/ 簿记与 .gitignore（v078 会话自身簿记）+ 并行存根目录 plans/task-v079-skill-modify-conservatism/（非本会话所建，不碰不提交，登记隔离决策表）
- Goal：修复两类守卫误报：①提醒链 zcode-posttooluse.sh 对已交付计划误报（L100 豁免只查 task_plan.md 的 outcome，而本仓约定 outcome 写在 verification.md → 补 verification.md 兜底检查）；②check-dispatch.sh 打包检测把契约条文示例 ID 计为多 S-unit 打包（新增「任务书」+subagent-state/ 双条件豁免 → SKIPPED 提示不阻断，对齐 P11「复杂度由模型判断」裁决）+ 各自 selftest 守护；全量 selftest 0 FAIL 后合并 master、从主仓副本执行部署 3 位并 push

## VC 五条（每条可观察验证）
- VC-1 zcode-posttooluse.sh 在 L100 既有 outcome 检查后新增 verification.md 兜底分支（同目录 verification.md，同 `outcome:` 正则 grep -qi，容前导空格）：grep -n 'verification.md' 该脚本 ≥1 + Read 复核；行为=有 verification.md 且 outcome COMPLETE 的计划不再触发 compass/sync 陈旧提醒
- VC-2 check-dispatch.sh 打包检测（L264 计数前）新增双条件豁免：prompt 同时含「任务书」与 `subagent-state/` → 输出 `[dispatch-guard] SKIPPED 打包检测: prompt 引用落盘任务书(Rule 35.3 范式), 打包判定以任务书内容为准` 且不计 hits（warn/enforce 两档行为一致=不阻断）；非豁免 prompt 行为不变
- VC-3 selftest-dispatch.sh 新增 FG-05（prompt 含「任务书」+subagent-state/ 路径+多个示例 ID → 输出含 SKIPPED 打包提示且不含「S-unit ID」阻断文案）；FG-03（无豁免词的多 S-unit prompt）仍被检测（回归保护）；selftest-dispatch 全量 0 FAIL
- VC-4 selftest-execution-stability.sh 新增行为用例（fixture：plan 含 verification.md 且 outcome: COMPLETE → POSTTOOL 执行后无 findings/progress 陈旧提醒输出；对照=无 verification.md 的既有 T11a/b 行为不变）；该脚本全量 0 FAIL
- VC-5 全量 20 脚本逐 Total awk 求和 0 FAIL（主进程机械求和，禁采信子代理自报）+ merge master + 3 部署位 diff=0（主仓副本执行 smart-merge-back --deploy）+ 主进程 diff -r 亲验 + push origin

## Phase 骨架（5 Phase；每 Phase 填 Executor 字段+S-unit 7 列表；S-unit ID 全局纯数字禁字母后缀；时长列 NNmin≤15；输入列 ≤2 文件）
- P1 隔离与基线（Executor: 主进程-白名单①git 编排；selftest 派 code-runner-agent）：S1 建 worktree 确认基线 commit；S2 跑 20 脚本全量基线（预期 337/0）逐 Total 行落盘检查点
- P2 修复实现（Executor: executor 严格串行）：
  - S3 zcode-posttooluse.sh verification.md 兜底（VC-1；改动 ≤4 行，位置 L100-102 一带；注意 :97 的 24h 静默与 :106-119 配置读取逻辑不动）
  - S4 check-dispatch.sh 双条件豁免（VC-2；改动位置 L264 计数前；SKIPPED 文案照 VC-2 原文；档位分支 warn/enforce 均走豁免后跳过 hits 累计）+ selftest-dispatch.sh FG-05 新增与 FG-03 保持（VC-3）
- P3 守护扩展（Executor: executor）：
  - S5 selftest-execution-stability.sh 新增行为用例（VC-4；写法样板=T11a/b L106-135；fixture 参照 mk_fixture 既有手法；断言=执行 POSTTOOL 后输出不含「plan-compass」与「plan-sync」陈旧提醒）
- P4 全量回归+文档同步（Executor: code-runner-agent+主进程白名单②③）：
  - S6 全量 20 脚本回归逐 Total 求和（预期 337/0+新增断言数，以实跑为准）落检查点
  - S7 CHANGELOG.md [Unreleased] 新增一条（样式照既有）
- P5 合并回+部署+簿记（Executor: 主进程-白名单①③）：
  - S8 smart-merge-back（主仓副本执行）+worktree 清理+3 位 diff 复验+.gitignore/.session-owner 与旧哨兵 staged 删除随簿记提交+push+INDEX/ledger/merge_back 回写

## 执行范围限制
只改 4 脚本（zcode-posttooluse.sh / check-dispatch.sh / selftest-dispatch.sh / selftest-execution-stability.sh）+CHANGELOG+（主进程簿记侧）.gitignore；禁改 SKILL.md/config.json/references/templates/critical-rules；selftest 只增不减

## Decisions Made 预置
①silent 依据（四轮先例）；②config 零新键（豁免逻辑内置于脚本，不加开关键）；③豁免锚=「任务书」+subagent-state/ 双条件（单条件 subagent-state 会被所有合规派发的检查点路径命中=废掉打包门，考古 §F 证实——此为被否决方案登记：「单条件 subagent-state 豁免」禁用）；④Rule 23 并行信号处置=plans/task-v079-skill-modify-conservatism/ 不碰不提交（非本会话所建的裸模板存根，登记隔离决策表）；⑤共享追踪不适用（Rule 30）；⑥C20 veto 检查 PASS（不涉及已否决项）
## FMEA 预演（≥3 行）
- 豁免过松削弱打包门（双条件+SKIPPED 显式提示+FG-05/FG-03 双向用例守护）
- verification.md 兜底误伤未交付计划（正则只认 COMPLETE|BLOCKED 终态词；execution-stability 新用例双向验证）
- T11a/b fixture 回归破坏（既有用例无 verification.md → 行为路径不变；S5 前置先跑 T11a/b 基线）

## 硬约束
task_plan.md 正文禁字面 "Batch Report" 与正文行首 **Status:** 污染（Phase 状态行除外）；锚点引用 01-explore.md 实核值禁凭记忆改写；两脚本均为运行中基础设施（部署位实时加载）——改动须最小化且行为级验证

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 逐项 PASS/FAIL 原文行
evidence: file:line
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/02-plan-writer.md
findings_written: 小节锚点|none
blockers: none|一句话
