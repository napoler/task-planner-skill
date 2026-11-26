<!-- template_type: rule-enhancement -->
execution_lane: L2
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程 -->

# Task Plan: Task Planner 模板体系升级（调研前置生成/扫描优先级/派生与保存审批）

## 🎯 用户需求原文（Rule 51.1 逐条抄录 + 51.2 R→VC 映射; R 行=用户原话逐条编号抄录，每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉）

- **R1**: 「继续优化当前的Task Planner的…当前技能的模板体系。确保可以鼓励模型使用更好的路径去执行任务。…我希望模板可以更加有效…（按场景适配如剧本创作/小说/通用开发/应用开发/安卓开发等）…优化模板的模板的生成能力以及适配能力，确保可以更有效的分析…技能，或者说是项目…确保适配度更强…」<sub>（[目标]）</sub> — 见 user-session-log.md #1
- **R2**: 「…实现模板的时候，我希望你可以通过去网络调研，然后什么样的，比如说写小说都是怎么做的？怎么做才能写的小说更好啊？然后再基于调研结果，然后再去创建模板。…比如说开发安卓应用…什么样的结构？什么样的步骤？…全部需要进行调研之后再落实模板的创建。严禁…拍脑袋做决定，就是不经调研的，然后就去着手开始创建。…隐患我希望在初期就可以全部排除掉…对模板体系进行升级，模板的制作以及生成进行升级。」（并经 #2 纠正：调研是“生成模板的时候增加一个调研步骤”，即以后生成模板之前先做调研再生成，机制化落地，非当下零散领域调研）<sub>（[目标]）</sub> — 见 user-session-log.md #1,#2
- **R3**: 「…对模板的扫描进行升级，优先扫描项目下的模板文件…执行任务的时候…必须要首先去…先分析任务，分析完任务之后再扫描当前项目下的模板目录，然后再去扫描用户目录，匹配适配当前任务的模板进行执行。」<sub>（[目标]）</sub> — 见 user-session-log.md #1
- **R4**: 「…增加一个派生机制…可从相似模板派生更适配模板（如从小说创作派生剧本创作）…模板生成之后，我希望你可以询问用户是否需要保存，永久保存…主动创建的模板保存前都需要询问用户…所有的模板罗盘都需要经过用户的审核，然后统允许之后，授权之后才可以真正落盘。」<sub>（[目标]）</sub> — 见 user-session-log.md #1
- **R5**: 「…第一点我的明确指定就是在模板体系进行升级，这是我的原始指定，你…还问我是不是要做？…第二点…用户目录…项目目录对应哪个？…当前的Agent它是什么就使用什么？…当前是z代码，你为什么使用Claude Code的？…z code目录下的计划任务或者说是模板文件都是针对当前Agent优化过的。你如果调用claude code的话…可能就会出现错误。」<sub>（[目标]/[约束]）</sub> — 见 user-session-log.md #3

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-5 | 模板体系/生成与适配能力升级方案与落地项覆盖场景适配与分析匹配能力（规则/流程/映射/产物可审查）；交付物路径与变更可复核 |
| R2 | VC-2, VC-5 | 生成/制作模板流程中存在强制“调研前置步骤”（分析→网络调研并记录依据→基于调研结果创建）的规则/SOP/模板载体；无调研依据不得生成/落盘的约束可见 |
| R3 | VC-3, VC-5 | 执行/选型链路体现“先分析任务→扫描项目模板目录→扫描用户目录→匹配执行”的顺序，且按当前 Agent（ZCode）目录约定实现/规定 |
| R4 | VC-4, VC-5 | 派生机制与“主动创建/派生模板保存前询问用户、审核授权后才落盘”的机制落地（候选暂存、审批门、落盘目标可选）；不绕过审批自动持久化 |
| R5 | VC-3, VC-4, VC-5 | 目录解析/优先级以当前 Agent（ZCode：`.zcode`/`~/.zcode` 语境）为准，避免误用 `.claude` 作为 ZCode 默认错配；升级按指定推进 |

<!-- plan_tier: standard -->

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 模板选型/扫描 | 仅项目+内置、无用户层；未体现“分析后项目→用户”顺序；agent 目录混探测易错配 | 统一扫描/匹配顺序与 ZCode 优先目录解析（init/list/default/匹配指引） | VC-3 |
| 模板类型校验 | check-template-type 仅认内置 variant，项目/用户自定义类型 enforce 下失配 | 白名单与门控扩展到项目+用户层并与 init/attest 一致 | VC-3 |
| 模板生成/制作 | 无强制调研前置步骤，易拍脑袋产出低质模板 | 在 kit/advisor/规则与生成流程中加入“调研→依据→生成”硬步骤与载体 | VC-2 |
| 派生与沉淀 | 34.7 自动生成合约与“保存前必审必授权”冲突；缺派生一等流程 | 改为候选生成+展示+用户授权后落盘；定义派生基底选择与落盘目标 | VC-4 |
| 模板适配质量 | 类型映射/模板内容与领域最佳实践脱节风险 | 以调研依据驱动模板结构/Phase/VC/知识储备；按需生成场景模板（小说/剧本/开发/安卓等） | VC-1, VC-2 |
| 交付与可维护性 | 规则/脚本文档/计数锚不同步 | 同步 mapping/guide/SKILL/自测与计划证据 | VC-5 |

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | 现有 init-session.sh/check-template-type.sh/attest-plan.sh、template-mapping/guide、critical-rules-template、plan-template-kit/advisor、plan-writer | 代码与文档直读+委派探索 | findings.md#1-#3；progress.md Phase 1 | ☑ |
| ② 对标样本（58.2 强制） | 现有 Rule 34.7/34.8/34.9 与 template-candidate/manifest 实践；同类“审后落盘/候选暂存”机制 | 仓内规则与 .zcode/plan-templates 实例对照 | findings.md#2；critical-rules-template.md Rule 34 | ☑ |
| ③ 外部约束 | “生成模板前网络调研该领域做法”由用户指定为流程约束；具体领域最佳实践在每次生成时按 R2 执行调研获取（机制层不预置拍脑袋内容） | 用户原话+本计划机制设计 | user-session-log.md #1-#3；task_plan.md VC-2 | ☑ |

> 归因类结论不适用；本任务为机制升级设计与落地，外部领域知识按“生成时调研”机制承载。

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R5 |
| **裁决** | `partial→near-complete`（R1-R5 机制与文档/脚本落地并验证通过于 worktree commit 3b8a021；主仓合并与 worktree 清理因重叠未提交改动暂缓） |
| **解决证据锚** | findings.md#2-#3；progress.md Phase 2-4；worktree commit 3b8a021；selftest-template-sense 8/8、selftest-template-lifecycle 24/24、`init-session.sh --list` smoke |
| **未解决面+原因** | 主仓合并 `wt/tplsys-upgrade-20261117` 与 worktree/分支清理暂缓（主仓存在与本任务重叠的未提交修改：README_zh.md、task-planner SKILL/config 等）；行为面在后续真实任务中继续观察 |
| **已排除路径** | 脱离机制的即时领域调研代替流程升级（已按用户纠正排除） |
| **下一步建议** | 主仓工作树去除重叠脏改后执行：`git -C /mnt/data/dev/task-planner-skill merge --no-ff wt/tplsys-upgrade-20261117` → 验证 → `git worktree remove tmp/worktrees/wt-tplsys-upgrade-20261117` && `git branch -d wt/tplsys-upgrade-20261117` |

## Goal
将 Task Planner 模板体系升级为：执行时按当前 Agent（ZCode）约定“先分析任务→扫项目模板→扫用户模板→匹配执行”；模板生成/制作与派生流程强制“网络调研前置→基于调研结果创建候选→用户审核授权后才落盘”，提升适配度并避免低质模板埋雷。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（预期改动含 .sh/.md 规则与脚本，按实际落地范围执行） |
| `session_id` | `sess_tplsys_upgrade_20261117` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/wt-tplsys-upgrade-20261117`（分支 `wt/tplsys-upgrade-20261117`，commit 3b8a021；主仓脏重叠暂未合并/清理） |
| `scope_files` | 预估：skills/task-planner/{scripts,SKILL.md,references,templates?}、skills/plan-template-kit/**、skills/plan-template-advisor/**、相关自测与映射文档（实施前精确化） |
| `interaction_mode` | `ask`（涉及机制与落盘审批策略） |
| `对齐审查` | 已登记：文档/规则变更前后对齐 user-session-log #1-#3 |
| `自动超时默认项` | 待实施决策点登记 |
| `new_rule` | 留空（优先修订既有 Rule 34/16/37 等条款，避免无必要新编号） |
| `质量审查工具` | 规则/脚本改动走 code-reviewer/自测；方案阶段已做探索与需求对齐 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 模板体系生成/适配升级落地：选型/匹配指引与模板制作流程支持按任务与领域调研结果提升适配（含场景化能力的机制承载） | Read 变更后规则/SOP/mapping；对照 R1 | Rule 16/34、kit/advisor/guide/mapping/SKILL/plan-writer 已同步三层扫描+调研前置+审后落盘（commit 3b8a021） |
| VC-2 | 生成/制作模板含强制调研前置步骤：流程明确“分析→网络调研→记录依据→基于调研创建”，无调研不得生成/落盘 | grep/Read 相关条款与 SOP 步骤；候选模板载体含调研依据字段/要求 | critical-rules-template Rule 34.4/34.7/34.8、kit/advisor SKILL SOP 含强制调研与依据/候选/授权后落盘 |
| VC-3 | 扫描与匹配：先分析任务→扫项目模板目录→扫用户模板目录→匹配；当前 Agent(ZCode)目录约定生效（项目 `.zcode/plan-templates`、用户 `~/.zcode/plan-templates` 优先）且门控白名单一致 | 脚本/文档变更复核 + 实测 --list/选型/校验行为 | init-session.sh（三层发现/路由/--list）+ check-template-type.sh（项目/用户白名单）+ `--list` smoke + selftest-template-lifecycle 24/24 |
| VC-4 | 派生与保存审批：支持从相似模板派生候选；任何主动创建/派生模板落盘前询问并获用户审核授权，授权后才写入目标持久目录 | 规则/SOP/实现点检查；流程演练记录 | Rule 34.4/34.7/34.8/34.9 + advisor SOP（基底扫描/派生/候选/展示询问保存位置/授权后落盘）+ kit 34.7 合约 |
| VC-5 | 交付可追溯：计划四文件与变更记录完整，关键改动有验证证据；与 R1-R5 逐项对齐 | Read 计划文件+git diff/测试输出 | plans/task-tplsys-upgrade-20261117/* + commit 3b8a021 + selftest/syntax/smoke 记录 |

**终验规则**：全部 VC 通过 → COMPLETE；部分完成 → PARTIAL（列遗留）；证据不足 → 不得宣称完成。

## 🛡 双轮质检与同步完整性声明（Rule 103）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认适用派发型实质产出 S-unit（实施阶段细化） |
| 豁免登记 | 方案/计划文档整理阶段由主进程产出并自审（实施阶段再登记） |
| 多文件变更集预判 | 预判触发（规则+脚本+映射+文档多文件同步） |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能与规则 | `skills/task-planner/**`、`skills/plan-template-kit/**`、`skills/plan-template-advisor/**`（与本需求直接相关部分） | 无关技能/agent 大范围改写 |
| 项目配置 | `.zcode/plan-templates/**`（仅当本任务产出经授权的项目模板/manifest 变更时） | 未经授权落盘新模板 |
| 计划与记录 | `plans/task-tplsys-upgrade-20261117/**`、必要的索引同步 | 篡改既有归档计划 |

**强制约束**：
- 目录与行为以当前 Agent(ZCode)为准：项目 `.zcode/plan-templates`、用户 `~/.zcode/plan-templates`；不以 `.claude` 作为 ZCode 默认错配路径。
- 生成模板前必须经网络调研并记录依据；主动创建/派生模板保存前必须获用户审核授权后才落盘。
- 改动涉及脚本/规则时遵守保护区与最小化原则，实施前按需建 worktree 隔离。

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1（当前） | 主进程 + Agent(Explore/general-researcher 参考) + Read/Write | 纠偏、现状盘点、方案与计划成文 |
| Phase 2+ | Agent(executor/code-assistant/code-reviewer/code-runner) + Bash/Grep/Read/Edit + Skill(task-planner/plan-template-kit) | 多文件规则与脚本协同修改、验证与审查 |

## Phases

### Phase 1: 纠偏、现状盘点与升级方案
- 目标：按用户纠正固化理解；完成模板体系现状/差距分析；产出可执行升级方案与计划基线
- **Status:** complete
- **Executor:** 主进程（含委派探索/参考调研）
- **V-N:** VC-1(方案覆盖), VC-2(调研前置机制设计), VC-3(扫描顺序与ZCode目录设计), VC-4(派生与审批机制设计), VC-5(计划可追溯)

### Phase 2: 扫描与目录机制落地（ZCode 项目→用户）
- 目标：实现/规定项目→用户→内置扫描顺序；纳入 `~/.zcode/plan-templates`（及项目 `.zcode` 优先）发现与匹配；统一 init/list/default、check-template-type、attest 白名单一致性
- **Status:** complete
- **Executor:** executor/code-assistant（按实施拆分 S-unit）
- **V-N:** VC-3, VC-5

### Phase 3: 生成流程调研前置与派生/保存审批机制
- 目标：在 kit/advisor/Rule 34 等流程中固化“调研前置→依据→创建候选”与“派生相似模板”；主动创建/派生候选落盘前必须用户审核授权；调整与 34.7 等冲突点
- **Status:** complete
- **Executor:** executor/code-assistant + code-reviewer
- **V-N:** VC-2, VC-4, VC-5

### Phase 4: 适配能力增强、文档映射同步与验证
- 目标：完善 mapping/guide/SKILL/示例与场景模板生成指引（以调研驱动）；补充必要自测/验证并完成交付对齐
- **Status:** pending（parked：未入 master；[移植去向] task-tplsys-systematic-correction-20261127 已在 master 现状上等价移植 R2-R5）
- **Executor:** executor/code-runner + 主进程收口
- **V-N:** VC-1, VC-5

## 📚 必要知识储备
| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 模板机制与门控现状 | init-session.sh, check-template-type.sh, attest-plan.sh, template-mapping.md, template-guide.md, critical-rules-template.md, plan-template-kit/advisor | ☑ |
| 用户原话 | 需求与纠正（权威） | plans/task-tplsys-upgrade-20261117/user-session-log.md #1-#3 | ☑ |

- **调研需求三态（Rule 75.1）**：**必需（作为机制的一部分）**——本次升级的核心交付之一是将“生成模板前对目标领域进行网络调研并记录依据”固化为模板生成/制作流程；具体领域调研在后续每次生成模板时按该机制执行并留痕（本计划不以脱离机制的零散领域调研充数）。

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-17 | 初次偏离：把“调研前置机制”误作即时领域调研；在明确升级指令后不当确认 | R2,R5 | 已按 user-session-log #2,#3 纠正，转为机制化方案与计划落地 |
| 2026-11-17 | 合并暂缓：主仓存在与本任务重叠未提交修改，未执行 merge/cleanup | R1-R5 交付收口 | 已记录阻塞与待执行命令（progress/findings/task_plan），避免破坏并行改动 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理/主进程 Phase 数 | Phase 1: 2 子代理探索/参考 + 主进程整合（进行中累计） |
| 主进程直做 Phase 清单 + 委派率 | Phase 1 文档整合由主进程完成（方案/计划成文）；实施阶段将按 S-unit 委派并补全统计 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 | 2026-11-17 | Explore | 映射模板体系现状与扫描/选型/生成/派生/门控机制及差距 | completed | 项目+内置发现、无用户层扫描；init/check-template 白名单不一致；34.7 自动生成与审批需求冲突；渲染与注入机制清晰 | agent_5ffe726a-066c-46b5-bb25-ad504ed2372c | findings.md#1-#3 | （会话内返回） |
| 2 | 2026-11-17 | general-researcher | 收集流程模板结构参考（受限） | completed | 工具受限未获实时核验网页；给出通用结构性参考建议（仅作机制设计参考） | agent_65922d87-7a4e-4f92-8c1a-b9eba7d458e0 | findings.md（参考性） | （会话内返回） |

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 模板体系升级机制落地 | 扫描顺序+调研前置生成+派生与审后落盘按 R1-R5 生效 | 规则/脚本文档检查+门控/发现行为验证+计划证据对齐 | Phase 2-4 | pending |

## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（机制升级任务，非批量数据处理） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | 待实施阶段 worktree 分支（合并前可弃） |
