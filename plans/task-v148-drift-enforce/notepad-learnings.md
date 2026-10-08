# Task Learnings: {task-name}

## New Requests
<!-- Log user-injected requests here. Each entry: timestamp + request + implied scope + plan impact. -->
- 2026-10-08 11:20 R1「对防偏移进行加强」——强化 task-planner 防偏移体系，scope=技能规则/守卫/载体，plan=本任务 task-v148
- 2026-10-08 11:20 R2「执行任务的时候，防偏移这个东西非常容易（失效/被忽略）」——用户观察：现有触发依赖模型自觉、实践中易被跳过；plan=调研面 B（失效取证）
- 2026-10-08 11:20 R3「需要进行时刻记得纠正」——目标形态=高频/常驻/机械化的纠正机制；plan=方案设计主轴
- **D 类判定（Rule 8.1，2026-10-08 11:21）**：新指令与磁盘上 in-flight 计划 task-v147-research-first（Goal=Rule 63 检索优先与反推诿纪律，Rule 63 已预留）Goal/范围/交付物均无关联 → 开新计划 task-v148-drift-enforce，旧计划 task-v147 原样保留（attest 已锁 cacfb3cf、worktree wt/task-v147-research-first 在位、11:16 后无活跃写入=上下文重置孤儿态，可随时 resume）。证据：plans/task-v147-research-first/task_plan.md Goal 段 + plans/.rule-reservations.jsonl rule=63 行

## What Worked
-

## What Didn't Work
<!-- [task-v072 Rule 31.4] 结构化条目 = 错误描述 + 类别标签（信息缺失/假设未验/规则缺位/数据源过时/执行偏差）；来源：31.2 根因分析闭环（用户指出错误/重复反馈/打断补充数据）与三击协议 -->
-

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

## 通用规则（General Rules — Rule 31.7）
<!-- [task-v134 Rule 31.7] 从具体案例抽象的通用规则；消费侧优先匹配通用规则 -->
| 规则名称 | 适用条件 | 具体措施 |
|----------|----------|----------|
|          |          |          |

## What Worked
- 22.3①/22.7 换道 general-purpose：今日 provider 通道不稳（haiku 拒×2/sonnet 滞挂×4）下 5/5 成功且最快 3min 闭环——「按当日通道实绩动态选路」优于固定档位表
- CR 四轮链每轮抓到真缺陷（F1 mini 豁免缺失/F9 双行 JSON/N1 投递饥饿）：聚焦式复审 brief（上轮发现+修法对照+禁全文件重审）是高轮次闭环的关键
- 调研取证先行（25 Phase 0% 执行率）：把用户口语观察转译为数据基线，使条款设计（三层闭环）与 CR 维度（判定序/投递必达）全部锚在实证上

## Notes for Next Time
- 触发条件=技能/规则类任务落地日：条款内禁硬编码行号锚（:28 案）与断言枚举数（DCE-01~16 案）——写「以 grep X 为准/随守护面演进」；防线=alignment-review 联动清单
- 触发条件=部署动作：部署目标=部署位根+去「skills/」前缀子路径，cp 后必须 diff -q 对账（本轮嵌套 skills/skills/ 垃圾树即靠对账暴露）；防线=对账不可省
- 触发条件=hook 内新增 emit：单轮 stdout ≤1 行 JSON 是平台硬约束，早判定+延投递+due 持久化三件套缺一不可（F9/N1 两轮教训）；防线=DCE-19/22/23 行为断言
- 触发条件=分派发任务书：子代理自报「零落地」可能是探测时机误差——以 worktree 产物探针+检查点双源核实再定性（S7-fix2 误判案例）
- FMEA RPN>100 兜底指针：本任务最高 80（部署竞态）未触发；尾部合并冲突预判命中但由 v147 侧承担（63→64 序已转达）
