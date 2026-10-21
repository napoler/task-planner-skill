---
id: discipline-execution-honesty
title: 执行纪律与能力沉淀
tags: [执行诚实, 错误闭环, 能力沉淀, 验证优先, 知识管理]
sources:
  - plans/archive/task-v072-error-loop/task_plan.md
  - plans/archive/task-v157-error-fix-prompt-forge/knowledge-brief.md
  - plans/archive/task-v157-error-fix-prompt-forge/findings.md
  - plans/archive/task-v076-conclusion-discipline/findings.md
  - plans/archive/task-v099-reliability-institution/knowledge-brief.md
  - plans/archive/task-v067-knowledge-brief/findings.md
  - plans/archive/task-quality-over-speed/findings.md
  - plans/archive/task-v087-task-boundary/findings.md
  - plans/archive/task-v163-proactive-research/findings.md
  - plans/archive/task-pwf-reuse/findings.md
updated: 2026-10-22
---

# 执行纪律与能力沉淀

> 主题级合成：把「出错怎么闭环」「结论怎么标诚实」「数字怎么才算数」「能力怎么落盘可复用」「知识沉淀到哪」串成一条可执行链；每条结论标注来源任务。

## 结论（可直接复用）

1. **错误闭环四步（触发→归因→修正→沉淀）**：①触发（用户指出错误 / 同一问题重复反馈 ≥2 次 / 执行中打断并补充新数据推翻既有结论 / 漂移检查输出同一错误同 Phase ≥3 次）→②结构化根因分析（五要素 4 维归因：现象=用户原话+触发位置、直接原因=哪个动作/假设、根因=5 Whys ≤5 层、类别=信息缺失/假设未验/规则缺位/数据源过时/执行偏差），**分析完成前禁止动手修改**；③按类别定向修正（假设未验/执行偏差→改计划与结论；规则缺位→新增防线或登记提案；信息缺失→立即补调研；数据源过时→修正并标注旧值 superseded），禁止盲改症状处；④强制沉淀（notepad「What Didn't Work」写错误描述+类别、「Notes for Next Time」写触发条件+防线一句话，Error Log 的 Prevention 列由 `<待沉淀>` 翻成实际措施）。（来源：task-v072-error-loop）
2. **沉淀要有人读**：消费侧三条——下一 Phase 开工前 Read notepad「Notes for Next Time」未消费项并按注记执行；终验 Learning Gate 校验 Error Log 各行 Root Cause 非空；新任务建计划后读上一 completed 任务的 note 作风险预演输入。防止「写了没人读」的双断。（来源：task-v072-error-loop）
3. **错误记在原文处，不新建文件**：Error Log 加两列（Root Cause / Prevention）而非新建第 7 个计划文件；Root Cause 为空或仍为 `<待沉淀>` → 终验 Learning Gate FAIL 并计入退出码；无 Error 行时静默 PASS。（来源：task-v072-error-loop）
4. **结论三态化**：READY（全 PASS）/ PARTIAL（存在未验证区）/ BLOCKED（根因未定位或验收不可判定）；无证据锚的根因禁入结论主体，只能进「未验证假设区」并显式标注；阻断级缺口（缺机器可检查验收 / 缺复现路径 / 缺范围定义）禁出稿。（来源：task-v157-error-fix-prompt-forge）
5. **交付前六条自检（QC-FP）**：①自包含（无代词悬指/裸文件名，全部绝对路径）②根因证据锚在位可复现 ③≥1 机器可检查验收判据 ④单 S-unit 范围单一 ⑤无占位符与「应该没问题」类措辞 ⑥未验证内容已隔离且显式标注；自检禁主观自报——机检项必须实跑命令并附输出。（来源：task-v157-error-fix-prompt-forge）
6. **子代理产出一手复核**：不信子代理自报的数字——全量 selftest 逐脚本跑、逐 `Total:` 行求和，子代理自报 253 实为算术错（逐行真值 313）；子代理写完的产物必须由主进程 Read 复核后才可采信；子代理结论必须自带证据锚。（来源：task-v076-conclusion-discipline）
7. **回归定数口径（Total 行双形态）**：求和正则须同时覆盖 `Total: N PASS=x FAIL=y` 与 `==== selftest xxx 结果: PASS=x FAIL=y ====`（final-gate-hash 独有）；单正则漏数=基线误判；定数一律由主进程求和。（来源：task-v099-reliability-institution）
8. **能力落盘三件套 + 登记联动**：可复用能力=SKILL.md（≤100 行范式：frontmatter→Goal→触发条件→输入契约→执行流程→门控铁律→输出合约→反模式）+ scripts/selftest-*.sh（静态守护，断言独立编号、相对路径解析、exit 0）+ selftest-registry.tsv 追加 1 行（仅末行 append，既有行零改动，否则双向断言 FAIL）；新增能力必须同时声明「不触发」边界清单，指名既有能力，避免越界重复造。（来源：task-v157-error-fix-prompt-forge）
9. **降质行为→确定性惩罚映射**：6 类降质行为各有可观察判定式与固定处置——跳过 VC 复验 / 压缩验证步骤 / 未 Read 子代理产出即标 complete / 委派率 <50% 且无登记理由 / 批量违规未处置 / 证据不实；首次单 Phase=强制回炉（撤销 complete→补做→重走回填），会话内累计 ≥2 Phase=outcome 最高 PARTIAL，证据不实=BLOCKED+STOP 且无事前豁免。豁免仅用户显式文字有效并登记（项号/范围/理由/日期），口头「尽快/先这样」不构成豁免，执行期不得以速度压力自我豁免。（来源：task-quality-over-speed）
10. **问题自主消解与任务边界**：遇障第一反应=自动消解（消解链含多条替代路径检索），AskUser/STOP 升级前必过消解清单；新请求判定在 A（无关）/B（扩展）/C（矛盾）之外补 D 类「无关新任务」——判为新任务就开新的 task_plan.md，不把不相干内容混进旧计划。（来源：task-v163-proactive-research + task-v087-task-boundary）
11. **知识沉淀设施现状（knowledge-brief 五段）**：§1 任务速览与核心概念 / §2 已验证关键事实（每条必带 file:line 证据锚，禁录未验证推测）/ §3 关键文件锚点表 / §4 易错点与禁止假设清单 / §5 S-unit 材料包索引；定位=执行期小模型的稳定知识底座（只读本文件即可恢复全部已对齐知识）；接入链=init-session 建为第 6 计划文件 + check-scope 白名单放行（否则执行期写 brief 被 scope guard 拦截）+ plan-writer 产出契约必填（五段齐备且 §2/§3 各 ≥1 真实条目，brief 缺失或五段空壳禁交付）。（来源：task-v067-knowledge-brief）
12. **复用上游先做能力对账**：复用外部成熟实现前，先盘点本宿主真实能力再决定移植/适配——宿主无对应事件承载的模块不移植，已有等效实现的不重复造，每条「不移植/不采用」写明理由；并把上游明确否定的做法（如以文件 mtime 判断停滞不可靠）登记为自研门控的已知缺陷。（来源：task-pwf-reuse）

## 证据锚

| 结论 | 锚点 |
|------|------|
| 1-3 错误闭环四步/消费侧/Error Log 加列 | plans/archive/task-v072-error-loop/task_plan.md:17、:26、:35、:36-43、:44-48、:49、:50、:51 |
| 4-5 三态结论/QC-FP 六条 | plans/archive/task-v157-error-fix-prompt-forge/knowledge-brief.md:14、:67、:76、:77、:78 |
| 6 子代理自报 253 实为 313（主进程求和） | plans/archive/task-v076-conclusion-discipline/findings.md:24、:26-28 |
| 7 Total 行双形态与主进程定数 | plans/archive/task-v099-reliability-institution/knowledge-brief.md:20、:60 |
| 8 三件套/registry 末行追加/边界清单 | plans/archive/task-v157-error-fix-prompt-forge/knowledge-brief.md:21、:23、:88；plans/archive/task-v157-error-fix-prompt-forge/findings.md:35-41、:48、:66-67 |
| 9 6 类降质行为与惩罚映射/豁免口径 | plans/archive/task-quality-over-speed/findings.md:62、:87-96、:97 |
| 10 消解优先/升级前置清单与 D 类新任务边界 | plans/archive/task-v163-proactive-research/findings.md:61-62；plans/archive/task-v087-task-boundary/findings.md:49、:52-55 |
| 11 knowledge-brief 五段与接入链 | plans/archive/task-v067-knowledge-brief/findings.md:22、:27、:45、:63-77 |
| 12 上游能力对账与不移植清单 | plans/archive/task-pwf-reuse/findings.md:26、:28、:29 |

## 易错点

1. 用户指出错误就直接改文件：跳过 4 维归因 → 盲改症状处，下一轮同一错误复发。
2. 沉淀只写不读：notepad 有记录但下一 Phase 未 Read，防复现链断在消费侧。
3. 采信子代理自报的总数/结论：算术错（253 vs 313）与未复核产物直接进交付。
4. 用单正则求和回归数：漏掉 `==== selftest` 形态脚本 → 基线误判为回归或漏报。
5. registry 追加时改动既有行或把登记写到非末行：双向一致性断言 FAIL，且破坏他任务的追加约定。
6. 结论写成「应该没问题」「基本可用」这类无判据措辞，或把未验证内容混入主体而不隔离。
7. 以速度压力自我豁免质量门控（口头「尽快/先这样」），或以为执行者有权豁免证据不实。
8. 落盘时新建平行文件体系（额外 error-log、平行索引文档）造成认知面膨胀与双份漂移。
9. 断言子代理产出「已验证」而不自己 Read 复核文件/不跑命令——一手复核缺失。

## 适用场景

- 用户指出错误、重复反馈、执行中打断补充约束时；
- 需要输出结论/交付物并附验收判据（含派发修正任务书）时；
- 汇总子代理产出、跑全量回归、需要报出确数时；
- 新建/沉淀一项可复用能力（skill、脚本、守护断言）时；
- 需要把知识写进固定去处供后续任务复用的规划期工作；
- 引入外部成熟实现、评估移植范围时。
