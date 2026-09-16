# plan-writer 派发材料包（task-v077 计划撰写全量参数，2026-09-17）

你是 plan-writer。先 Read 本文件与下方材料包，然后撰写计划文档。

## 第一步 Read 清单
1. /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/01-explore-v077.md（全部锚点与设计裁决，以此为准禁凭记忆）
2. /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/findings.md（Requirements+Research Findings 段）
3. /mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/rule-enhancement-type.md（模板骨架）

## 产出（覆盖写）
A. /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/task_plan.md
B. /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/knowledge-brief.md

## 计划参数（照填不得改）
- task-id: task-v077-deferred-fixes；template_type: rule-enhancement；interaction_mode: silent（登记依据：自治会话+v074/v075/v076 先例）；chain_mode: single；config.json 零新键（也不加 env 覆盖键，测试靠 fixture 造主仓内容）；code_review 不声明
- 隔离：worktree /mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes，分支 wt/task-v077-deferred-fixes 自 master 新建；冲突信号=主仓干净（5ad18f6，v076 簿记已提交）
- Goal：逐项修复 v076 交付登记的 4 个问题：①smart-merge-back.sh 部署源/对账基准从 SKILL_ROOT（脚本运行处，L498 cp/L524 diff）改为主仓 skills/task-planner（DEPLOY_SRC fail-closed）+selftest 新增陈旧副本回归用例钉死假 IDENTICAL；②skills/task-planner/README.md:67 与 references/batch-quality-gate.md:130 的 Rules 1-27→Rules 1-35；③companion/agents/plan-writer.md 与 templates/task_plan.md 补 S-unit ID=纯数字契约；④templates/subagent_dispatch.md §7 与 references/critical-rules.md 22.4b 补「统计类只贴逐项原文行禁自报汇总」；CD selftest 扩展断言锁契约；全量 selftest 0 FAIL 后合并 master、从主仓副本执行 smart-merge-back 部署 3 位并 push

## VC 五条（每条可观察验证）
- VC-1 smart-merge-back.sh 部署源与对账基准换为 $MAIN_REPO/skills/task-planner：L498 cp 与 L524 diff 两处换用 DEPLOY_SRC 变量；DEPLOY_SRC 源缺失→显式 DRIFT fail-closed 禁回退 SKILL_ROOT；头注释 L15/L41/L81 与 L538 尾注同步。验证：grep 'DEPLOY_SRC' ≥3 + Read 复核
- VC-2 selftest-smart-merge.sh 新增 SM-14（把脚本副本放进陈旧部署位运行，断言槽位终态内容==主仓内容）PASS 且既有 SM-01..13 全 PASS
- VC-3 两处 Rules 1-27→Rules 1-35 且全仓活跃文件（排除 plans/）grep 'Rules 1-2[0-9]' =0
- VC-4 四契约点就位（plan-writer.md L116 后新表行 S-unit ID=纯数字 / templates/task_plan.md L184 区补 ④ / subagent_dispatch.md L54 后禁自报汇总 / critical-rules.md L129 22.4b 行内子句）且 selftest-conclusion-discipline.sh 新增 CD-18..CD-23 六断言全 PASS + 头注释 L4-15 清单与 L17 计数（17→23）同步
- VC-5 全量 20 脚本逐 Total awk 求和 0 FAIL（主进程机械求和，禁采信子代理自报）+merge master+3 部署位 diff=0（本次必须从主仓副本执行 smart-merge-back；.zcode 位若被自保护拒绝则手动 rm+cp 补齐）+push origin

## Phase 骨架（5 Phase；每 Phase 填 Executor 字段+S-unit 7 列表；S-unit ID 全局纯数字 S1..S11 禁字母后缀——本次 dogfood 该契约；时长列 NNmin≤15；输入列 ≤2 文件）
- P1 隔离与基线（Executor: 主进程-白名单①git 编排；selftest 派 code-runner-agent）：S1 建 worktree 确认基线 commit；S2 跑 20 脚本全量基线（预期 330/0）逐 Total 行落盘检查点
- P2 修复实现（Executor: executor 严格串行）：
  - S3 smart-merge-back.sh 部署源修复（VC-1 全部要点；自位 SKILL_ROOT==slot 的 REJECTED 消息追加指引「请改用主仓副本运行或手动 rm+cp 部署该位」）
  - S4 selftest-smart-merge.sh fixture 扩展：mk_fixture(L63-85) 建 $repo/skills/task-planner 打内容标记；SM-06(L198-220) 预置源语义同步（L209 自测侧 SKILL_ROOT 独立定义改用主仓 fixture 路径）；新增 SM-14 陈旧副本用例（写法样板 SM-07 L222-230/run L114/report L121/Total L413 或 L415）+头注释用例清单同步
  - S5 文档滞后两行：README.md:67→Rules 1-35（括注样式自拟，如「1-12 核心执行约束 + 13-35 P0/P1 扩展门控与学习闭环」）；batch-quality-gate.md:130→隶属 Rules 1-35
  - S6 plan-writer.md L116 后新表行「S-unit ID=纯数字（S1/S2…禁 S2a 字母后缀——check-plan-dispatch.sh 数据行正则 ^\|\s*S[0-9]+\s*\| 不认，attest 拒锁教训）」+templates/task_plan.md L184 区补 ④ 同义注释
  - S7 subagent_dispatch.md L54 acceptance 行后追加「统计/测试类：acceptance 只准贴逐项原文行（如各脚本 Total: 行），禁止自报汇总数字——汇总由主进程机械求和」+critical-rules.md L129 22.4b 行内 acceptance 括注后插同义子句
- P3 守护扩展（Executor: executor）：S8 selftest-conclusion-discipline.sh 变量区 L21-26 加 SM/README 路径变量+CD-18..CD-23 六断言（VC-4 清单对应）插 L61 后+头注释 L4-15 与 L17 计数同步
- P4 全量回归+文档同步（Executor: code-runner-agent+主进程白名单③）：S9 全量 20 脚本回归逐 Total 求和（预期 330+6=336/0，以实跑为准）落检查点；S10 CHANGELOG.md [Unreleased] 新增一条（样式照既有）
- P5 合并回+部署+簿记（Executor: 主进程-白名单①③）：S11 smart-merge-back（主仓副本执行）+worktree 清理+3 位 diff 复验+.zcode 位如 REJECTED 手动 rm+cp+push+INDEX/ledger/merge_back 回写

## 执行范围限制
只改上述 9 文件+CHANGELOG；禁改 SKILL.md/config.json/lib/verify.sh/其他 references；selftest 只增不减

## Decisions Made 预置
①silent 依据；②零新键+不加 env 覆盖（fixture 造主仓内容，防绕过）；③自位 REJECTED 保留（bash 执行中自覆盖风险，S2 轮既有裁决）；④共享追踪不适用（Rule 30：无可枚举部分认领）；⑤C20 veto 检查：本任务方案不含用户已否决项（未查证否定结论收场/大输入不落盘）PASS

## FMEA 预演（≥3 行）
- SM fixture 改动致既有用例崩（兜底=改前先跑 SM 基线+逐用例对照）
- 非标准仓布局 $MAIN_REPO/skills/task-planner 缺失（已 fail-closed 设计，自测覆盖）
- CD 断言锚漂移（锚用行内容非裸行号）

## 硬约束
task_plan.md 正文禁字面 "Batch Report" 与正文行首 **Status:** 污染（Phase 状态行除外）；Phase 状态行照模板；锚点引用 01-explore-v077.md 实核值禁凭记忆改写

## 8 字段严格返回模板
status: done|failed
files_changed: [绝对路径]
acceptance: 逐条对照上述产出要求
evidence: file:line
issues: 无|列表
next: 建议
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v077-deferred-fixes/subagent-state/02-plan-writer.md
notes: 备注
