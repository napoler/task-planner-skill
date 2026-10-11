# Task Learnings: {task-name}

## New Requests
- 2026-09-18 用户指令：为 task-planner 技能补充批量处理纪律——「单个处理都做不好 还恶意批量处理，和投毒有什么区别。记住在没有十足把握之前不要轻易尝试批量处理。我接受速度慢一点但不能接受批量处理出现问题」。隐含 scope：仅本技能（不动 AGENTS.md）；落地为 Rule 18 族 18.9-18.11 增补（本计划 Goal）

## What Worked
- 计划期预登记兜底（FMEA R-2 接管/R-3 合并竞态）全部按预案兑现，执行期零临时决策：v082 抢先合并时 V5 中止→worktree merge master→解 1 处 CHANGELOG 冲突→重跑全量→再合并，一步不乱
- mini 探针对照法：code-assistant 2 连败 + mini PASS → 精确定位"haiku-1 档死、环境分档活"，为 ④ 接管提供第一手依据而非凭 v081 旧印象
- SKILL.md 净增 0 约束使 v082/v083 同文件并行零行冲突（唯一冲突在双方都插入的 CHANGELOG，一条 Edit 解决）

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
- [假设未验] selftest BP-10 的 CHANGELOG 路径写了 SKILL_ROOT/../../../（多跳一层落到 worktree 父目录）→ SKIP；根因=凭层级直觉没画目录树；修法=SKILL_ROOT/../../；防线=涉及相对路径上跳时先 stat 验证目标存在
- [执行偏差] Edit task_plan 更新 P2 Executor 时 old_string 含 S-unit 表但 new_string 漏表 → 表被误删，下一步立即发现恢复；防线=Edit 前核对 new_string 是否完整保留 old_string 中仍需要的块
- [假设未验] progress.md Started 时间凭感觉写 19:05（实际 03:13）→ 3-File Gate mtime 锚失效 FAIL；防线=Started 必须取 `date` 实测或 stat 文件真实时间

## 🚫 被否决方案（User Rejected — Rule 32）
<!-- [task-v073 Rule 32.1] 用户裁决「不允许/禁止/X 是错的/不要再做」的方案登记于此：方案描述 + 否决原文 + 日期 + 适用范围。
     32.2 计划期/32.3 执行期提出任何方案候选前必查本段（plans/ 历史 notepad 同查）；32.4 无新验证证据禁止重提——
     重提须标注「此前被否决于 <日期/出处>，现因 <新证据> 申请重议」交用户裁决；解禁仅限用户显式撤销（veto-lift 行）。
     31.5 消费侧联动：下一 Phase 开工前/新任务 init-session 后必读本段。 -->
- **被否决操作方式：单件未验证即启动批量处理**（veto: 无试点批量）——否决原文：「单个处理都做不好 还恶意批量处理，和投毒有什么区别。记住在没有十足把握之前不要轻易尝试批量处理」（2026-09-18）；适用范围：一切对 ≥2 同构对象的写操作（脚本循环/循环派发/批量 API/批量写入）；落地条款=critical-rules.md 18.9/18.10/18.11（本任务交付）；解禁条件=单件试点通过+把握四构成齐备（即 18.9 合规本身，非 veto-lift）
- **被否决权衡：以速度为由压缩验证**——否决原文：「我接受速度慢一点但不能接受批量处理出现问题」（2026-09-18）；适用范围：18.9/18.10 语境下「为了快/省时间/任务急」类豁免理由一律无效（18.11 条款化）

## Files Modified
- master（经 8fed498）: skills/task-planner/references/critical-rules.md（+3：18.9-18.11）/ references/batch-quality-gate.md（+37/-3：v2.3+§八详解）/ SKILL.md（Rule 18 行内，净增 0）/ scripts/selftest-batch-pilot.sh（新）/ CHANGELOG.md（v083 条目）
- 部署×3: ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner（diff -r IDENTICAL 亲验）
- plans/task-v083-batch-pilot-first/ 全套 + .zcode/ledger/task-planner-maintenance/（认领 in_progress→done）

## Verification Results
- Verified: 全量 selftest master 377 PASS/0 FAIL（bc 机械求和 23 脚本 Total 行）；三位部署 diff -r IDENTICAL 主进程亲验；origin push c10e8f2..8fed498
- Failed: 无（worktree 期 BP-10 路径 SKIP 已修；v082 CHANGELOG 冲突已解）

## 📚 必要知识储备备注
<!-- WHAT: 本次任务新发现的知识源/值得入库的书目文献/待补齐的知识缺口 -->
- 本次新发现的知识源:
- 值得入库的书目/文献:
- 待补齐的知识缺口:

## Notes for Next Time
<!-- [task-v072 Rule 31.4/31.5] 消费侧契约：条目格式 = 触发条件 + 防线一句话；31.5 ① 下一 Phase 开工前 Read 未消费项命中即执行并记 [learn-apply]；31.5 ② 新任务 init-session 后 Read 上一 completed 任务同段作风险预演输入 -->
-
