# Task Learnings: {task-name}

## New Requests
- 2026-09-18 用户指令：补充思维方法论——「解决问题前先思考问题 多问几个为什么 问题是什么 本质是什么 解决方案是什么 执行方案是什么 类似 不少于五个为什么思考法 金字塔原理 一步步推导刨析解决问题 确保后期执行不出问题不走弯路少走弯路事半功倍」。scope=本技能；落地=methodology §思维方法论 T1-T5（本计划 Goal）

## What Worked
- Code Review Gate 三轮真实收敛：审查方两轮 CHANGES_REQUESTED 抓出 7 个真问题（含两处「声称已改实则未改」），轮 3 用突变实测（/tmp 副本删节跑真脚本）给出 APPROVED——本会话 Code Reviewer(sonnet 档)存活可用，v083 的「声明未跑」缺口已补
- M-12 断言三级演进（聚合关键词→逐条关键词→标题锚 ^### T1..T5）：审查方指出关键词残留于例外注记/导语会使逐条口径穿透，标题锚才是变异安全锚——「断言要锚定结构位置而非内容词」
- attest 派发门在计划期拦截 P4 缺 S-unit 表（v083 是 P5 才补）——同一错误在计划期被抓住=门控前置化的价值
- 计划自身按 T2 四问作答（核心问题定义段）——方法论首轮消费自证

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环与三击协议 -->
- [执行偏差] Handoff 登记表未在派发前填行（22.5 要求派发前登记），终验委派统计 violation 才补——「登记(22.5)是派发前动作非终验补课」；防线=每次 Agent() 派发前先填 Handoff 行（v083 做了、v084 漏了，同会话内不一致）
- [执行偏差] P4 Executor 字段写复合描述「+ Code Reviewer（…）」→ 委派统计解析报未登记类型（v081 教训精确复现）；防线=机器事实源字段只写干净类型 token，补充说明进 Handoff/S-unit 行
- [信息缺失] init-session 哨兵 fallback 绑定到 subagent 残留 sid（active_plan 指针归属异常）→ 全程显式路径传参缓解；待后续轮修 init sid 归属校验
- [假设未验] 自查静态推演「关键词只出现在对应节」对 T3 不成立（例外注记/章导语/关系表三处残留）——被 CR 轮 2 突变实测抓出；防线=断言设计后做一次心智突变测试，或直接锚结构位置

## Files Modified
- master（经 871e71a）: skills/task-planner/references/methodology.md（§思维方法论 T1-T5+14 条联动）/ SKILL.md（三处，545 行）/ companion/agents/plan-writer.md（四问契约行）/ scripts/selftest-methodology.sh（M-12..16）/ CHANGELOG.md
- 部署×3: ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner（diff -r IDENTICAL 亲验）
- plans/task-v084-thinking-methodology/* + .zcode/ledger（认领 in_progress→done）

## Verification Results
- Verified: master 全量 23 脚本 bc 亲算 382/0；三位 diff -r IDENTICAL 亲验；Code Review Gate 轮 3 APPROVED（突变实测）；origin push 完成（经 pull 合并 v082 交错提交）
- Failed: 无遗留（CR 三项残留已全部修复并复审确认）

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
-

## Files Modified
-

## Verification Results
- Verified: [specific change confirmed]
- Failed: [specific issue and resolution]

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
-
