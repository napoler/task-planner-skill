# Task Plan: [长文/连续创作任务]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="用户需求原文,根源覆盖表,不变量声明区,规范基线,进度产出基线,CodeReview配置,双轮质检与同步完整性声明,核心目标达成裁决,Goal单元表,执行范围限制,变更标注表,必要知识储备,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,工具选择与编排,防倒退终检,收尾回读梳理记录,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,DriftLog,BatchReport,委派统计,SubagentHandoff登记表,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- template_type: longform-continuity -->
<!-- 长文与连续创作专用 — 适用于长篇小说/连载/剧集长篇剧情/长论文/长报告/需跨章节一致性的长文与续写改写 -->
<!-- 强制：加载并遵循 skills/longform-continuity/SKILL.md 与 skills/task-planner/references/longform-continuity-methodology.md；对齐 Rule 107（项目级资产先行+全局检索+冲突禁静默覆盖）与 task-dispatch 22.4d 派发契约 -->

<!-- plan_tier: standard -->
## Goal
[一句话：产出什么长文/连续内容（项目/系列名、范围与目标单元），并保证与既有大纲/设定/前文一致]

## 连续性模式（必填）
- [ ] 序列创作（多集/多章/连载/系列脚本/分镜）
- [ ] 长文连续（长论文/长报告/技术长文/长教程等跨章节一致）
- [ ] 续写/改写/扩写既有项目（必须先检索既有资产与前文）
- 豁免登记（非连续独立批量）：n/a（本模板默认不豁免）

## 项目级连续性资产包（Rule 107.0 — 计划期必登记，优先项目级固定路径）
| 资产 | 路径（绝对或项目内可定位） | 状态(已有/待建/待校验) | 本轮使用范围 |
|---|---|---|---|
| 总纲/主大纲 (outline) | docs/<项目>/outline.md |  | 目标单元对应段/接口 |
| 设定与世界观圣经/设定库 (setting-bible) | docs/<项目>/setting-bible.md |  | 相关人物/规则/时间线 |
| 知识库/事实库 (knowledge-base) | docs/<项目>/knowledge-base.md |  | 相关术语/事实/论点/证据 |
| 脑图/结构图 (structure-map) | docs/<项目>/structure-map.md 或 .mmd |  | 相关节点/依赖/伏笔 |
| continuity 台账（增量流水） | <plan-dir>/continuity-ledger.md 或项目既有 |  | 本轮增量与回写 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 大纲先行门：总纲与分单元拆解已建立/校验，目标单元接口明确后才动笔 | 读取 outline 对应段+拆解/接口记录 | outline/plan |
| VC-2 | 动笔前全局检索完成：已检索总纲对应段+相关设定/知识+台账+前序及相关历史单元（非仅紧邻） | 检索/回读清单与证据锚点 | findings/progress |
| VC-3 | 项目级资产为事实源：计划内仅登记引用与增量，核心设定不只埋在计划目录 | 资产路径在位且可读 | 资产文件 |
| VC-4 | 单元完成沉淀回写：台账更新且受影响项目级资产（outline/setting-bible/knowledge-base/structure-map）同步回写 | diff/条目在位 | 资产+台账 |
| VC-5 | 一致性与冲突裁决：与既有设定/前文/论点一致；冲突显式裁决并回写，**无静默覆盖** | 一致性核对记录+冲突登记 | findings/资产 |
| VC-6 | 长文本优化策略执行：分段推进+最小必要上下文加载+里程碑全局一致性审查（按范围） | 单元拆分与审查记录 | plan/progress |

## Phases

### Phase 1: 资产盘点与大纲先行（门禁）
- [ ] 加载 `longform-continuity` 技能与方法论；盘点/创建项目级资产包（outline/setting-bible/knowledge-base/structure-map + continuity 台账）
- [ ] 建立或校验总纲与分单元拆解、单元目标与承上启下接口（小说/剧集=分集章骨架；论文/报告=提纲与章节论点）
- [ ] 登记本轮目标单元与对应大纲段；未满足大纲先行门=禁止动笔
- **V-N:** VC-1, VC-3
- **Status:** pending

### Phase 2: 目标单元全局检索与一致性检查（动笔前）
- [ ] 检索/Read 总纲对应段与相关依赖段
- [ ] 检索/Read setting-bible、knowledge-base 相关条目（人物/时间/术语/设定/论点/事实）
- [ ] Read continuity 台账 + 紧邻前序单元 + 台账/大纲指向的**相关更早单元**（禁止仅看 N）
- [ ] 产出本单元“一致性检查清单”（必须遵守/禁改/待回收伏笔或论点接口）；未完成检索禁动笔
- **V-N:** VC-2
- **Status:** pending

### Phase 3: 分段写作/续写（最小必要上下文）
- [ ] 按章/集/节单元推进，仅加载最小必要上下文包（总纲段+相关设定/知识+接口+必要前序摘要）
- [ ] 新设定/新论点先做冲突检查；发现冲突走裁决流程后落笔
- **V-N:** VC-2, VC-5, VC-6
- **Status:** pending

### Phase 4: 单元验收、沉淀回写与一致性核对
- [ ] 对照项目级资产+台账+前序/相关历史做一致性核对；冲突=返工或显式裁决并回写（禁止静默覆盖）
- [ ] 更新 continuity 台账并回写受影响的 outline/setting-bible/knowledge-base/structure-map
- **V-N:** VC-4, VC-5
- **Status:** pending

### Phase 5: 里程碑全局审查与收尾（按范围）
- [ ] 阶段/卷/章节组全局一致性审查（设定/时间线/术语/伏笔或论证链），问题回写资产
- [ ] 记录遗留风险与下一单元入口
- **V-N:** VC-5, VC-6
- **Status:** pending

## 子代理派发约束（Rule 107.2/22.4d）
- 派发 prompt 必须携带：项目级资产路径+本单元大纲段、continuity 台账、紧邻前序产出、相关更早单元/设定节点路径。
- 子代理首动作：加载 `skills/longform-continuity/SKILL.md` 并完成全局检索与一致性检查后再动笔；未检索禁动笔。

## 参考
- 技能：`skills/longform-continuity/SKILL.md`
- 方法论：`skills/task-planner/references/longform-continuity-methodology.md`
- 规则：Rule 107、task-dispatch 22.4d
