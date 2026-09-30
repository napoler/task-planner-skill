# Findings & Decisions
## Requirements
- 用户指令(2026-10-01,英文,自包含): 创建可复用 skill——循环迭代模式渐进优化内容;适用=提示词精修/参数调优/缺陷修正及同类优化任务;每轮自动=评估当前产出→识别弱点→定向改进→判定是否续轮;收敛条件=预定义质量标准达成或最大轮次;产出=稳定可重复模式+简短迭代摘要(改了什么/为什么/是否解决)
- 落地=顶层 skills/iterative-optimizer/SKILL.md+selftest IL-01..08+registry;三宿主部署;零 config;不动池/卫星/守护内容

## Research Findings
- [P0 实测 2026-10-01] master=e620a03;基线 41 脚本 652/0;SATELLITE_SKILLS 无 selftest 守护锚(grep 空→不加 install-stub,最小范围);名字唯一性已普查(2026-10-01 审计 A':20 skill 零重复);install-companion 顶层循环自动分发非 task-planner 的 skills/*(读 :167-190 实证)
- [范式源] 池成员四要素(触发/清单/证据/合约)+task-drift-guard 形态(81 行触发+流程+合约)+S54 Loop 元件(State+Gate 必选,Automation 可选)+S47/48 banned 词纪律

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 顶层 skill(非池成员) | 执行型工作流≠审查技能,42.2 ④层语义不匹配 |
| 质量标准前置契约 | 防「感觉更好」自报收敛(用户核心诉求=stable repeatable) |
| 单 focus+回归重跑 | 多轮归因有效性 |
| 无 gate 脚本 | 质量标准任务特定,「≥1 机器可检查」由调用方供给 |
| 不加 install-stub | install-companion 已覆盖;锚普查无守护引用;YAGNI |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
-

## Visual/Browser Findings
-
