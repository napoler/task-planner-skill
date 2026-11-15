# Knowledge Brief — task-initdelegation-20261115（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：优化 task-planner 技能，使 L1+ 任务在初始化阶段（需求分析+计划文档创建）首动作委派子代理，主代理仅回收收据并完成会话绑定/确认流程。
- 背景/动机：降低主代理初期上下文占用、提高子代理激活率并增强隔离；同时保持 L0/mini/trivial 轻量路径不加仪式（R1-R3，user-session-log.md#1）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 首动作委派 | init 后第一动作将需求分析与计划文档创建交给计划子代理执行，主代理不在主上下文展开中间过程。 |
| 收据（receipt） | 子代理完成后返回的最小结构化结果：`task_id`, `files_created[]`, `open_questions[]`, `摘要`（≤20 行）。 |
| L1+ | `execution_lane: L1/L2` 的标准/完整执行通道；本优化适用面，不含 L0/mini/trivial 豁免档。 |
| 会话绑定脚本 | init-session.sh / attest-plan.sh / set-active-plan.sh / plan-created.cjs 等具会话态副作用的脚本，归主进程职责。 |
| dogfood | 本次计划产出本身即新范式首实例（Plan Writer 首派失败后改派 general-purpose 完成）。 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 计划制作循环初始化分为机械子动作与智能子动作，随后计划确认含 D1/attest/交互模式/new_rule 预留 | skills/task-planner/SKILL.md:36-63 | R1 条款需插入 init→计划确认链路并重分职责，不能破坏现有 D1/attest/sentinel 语义。 |
| init 机械子动作当前包含 init-session、7文件在位、S1 sync-todos、plan-created.cjs 清哨兵等 | skills/task-planner/SKILL.md:38-47 | “哪些仍由主进程做”必须在条款中显式列出（会话绑定/收据回收），计划子代理不跑这些脚本。 |
| 已有 L0/mini/trivial/auto-tier 与比例原则口径，投诉响应段强调不叠加新门控 | skills/task-planner/SKILL.md:40-45,194-202 | R2 要求的收益不得通过给轻任务加仪式实现；条款需写明 L1+ 适用、轻量豁免不变。 |
| core critical-rules 为四文件罗盘核心域索引，规则编号账本 next 当前为 109（只读查询） | skills/task-planner/references/critical-rules.md:1-40,320-360；`bash skills/task-planner/scripts/rule-reserve.sh next` → 109（2026-11-15） | 若新增 core Rule，实施前须 check/reserve，落地后 land；计划中先作为候选并设 VC/步骤。 |
| 源仓 task-planner selftest 脚本共 97 个 | `find skills/task-planner/scripts -maxdepth 1 -name 'selftest*.sh' | wc -l` → 97（2026-11-15） | Phase 3 需建立改前基线与改后零增量 FAIL 证据，范围按改动锚点选定全量/子集并记录。 |
| Plan Writer agent 定义存在且为专职计划产出体 | /home/terry/.zcode/agents/plan-writer.md:1-80 | 条款可指定“首选 Plan Writer”，并保留 provider/能力失败降级 general-purpose 路径。 |
| 本次计划产出为 dogfood 实例：首派 Plan Writer 失败 reason=reasoning-level-missing，改派 general-purpose 完成 | 本会话派发上下文 + plans/task-initdelegation-20261115/progress.md（本次记录） | 计划与条款应把降级留痕纳入收据/证据口径，证明 fallback 可行。 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :36-63 | 计划制作循环：初始化机械/智能子动作、计划确认（D1/attest/交互模式/new_rule）；R1/R3 主改锚面。 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :194-202 | 投诉响应与 L0 边界审查、L0-E 说明；R2 轻量豁免与比例原则对齐锚。 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :1-40 | core 规则头部与定位；新增 Rule（若采用）插入/索引更新参考区。 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md | :320-360 | Rule 81-83 末段与卫星路由索引前后；编号/索引风格参考（实施时以最新 landed 为准重验）。 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/rule-reserve.sh | :1-80 | Rule 编号预留/检查/land/release 用法；实施 Phase 新 Rule 流程依据。 |
| /home/terry/.zcode/agents/plan-writer.md | :1-40 | Plan Writer 职责、模型与产出契约；首选执行体依据。 |
| /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/user-session-log.md | :41-50 | R1-R3 用户原话与理解镜像；需求与验收锚。 |
| /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/task_plan.md | :16-28,392-415 | 本计划 R/VC 映射、隔离决策、FMEA；执行期对照锚。 |

## §4 易错点与禁止假设清单
1. 禁止把“首动作委派”扩展到 L0/mini/trivial/L0-E 轻量路径；条款必须显式豁免并保持 Rule 38.6/38.7 比例原则。
2. 禁止让计划子代理执行会话绑定脚本（init-session.sh、attest-plan.sh、set-active-plan.sh、plan-created.cjs、哨兵清理等）或代行 D1 确认；这些归主进程。
3. 禁止在未做改前基线的情况下修改 selftest/守护面后直接声称“零增量 FAIL”；必须先记录基线再对比。
4. 禁止未经 `rule-reserve.sh check/reserve` 就定稿新 Rule 编号为已占用事实；109 仅为本计划时点 next 候选，实施时重验。
5. 禁止只改源仓不做部署对账；本仓技能为运行中基础设施，源与 ~/.zcode/~/.agents 部署位需 diff 验证并记录差异处理。
6. 禁止把 receipt 扩写为长篇分析进入主上下文；主代理仅回收 `{task_id, files_created[], open_questions[], 摘要}` 并据此呈现最小结论。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 1 设计锚点漂移/编号冲突」「Phase 2 条款改动破坏既有门控」「Phase 3 自测回归引入增量 FAIL」对应行。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P1-S1 | §1, §2, §3 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:36-80,194-202；/mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/findings.md |
| P1-S2 | §2, §3, §4 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md；/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/rule-reserve.sh |
| P2-S1 | §1-§4 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md；/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md；/mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/task_plan.md（VC/变更标注表） |
| P3-S1 | §2, §4 | /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/（selftest 相关）；/mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/verification.md |
| P4-S1 | §2, §3, §4 | /mnt/data/dev/task-planner-skill/skills/task-planner/**；~/.zcode/skills/task-planner/**；~/.agents/skills/task-planner/** |
| P5-S1 | §1-§5 | /mnt/data/dev/task-planner-skill/plans/task-initdelegation-20261115/{task_plan.md,findings.md,progress.md,verification.md} |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | /home/terry/.zcode/skills/task-planner/SKILL.md | 本任务直接优化 task-planner 初始化/计划制作循环与核心规则条款，需遵循四文件罗盘与计划契约。 | 主进程 Skill 调用 / 子代理 prompt 挂载 |
| task-dispatch | /home/terry/.zcode/skills/task-dispatch/SKILL.md | 设计“首动作委派”、执行体选择与降级、S-unit 派发契约及子代理激活率提升相关规则。 | 子代理 prompt 挂载 / 主进程按需读取 |
| task-discipline | /home/terry/.zcode/skills/task-discipline/SKILL.md | 条款变更需遵守变更吸收、注释/证据纪律、禁止越权扩 scope 等执行纪律。 | 子代理 prompt 挂载 |
| verification-gate | /home/terry/.zcode/skills/verification-gate/SKILL.md | VC 可执行命令、终验与证据链设计（Rule 84.x）支撑本计划 verification.md 与落地验收。 | 主进程/子代理按需读取 |
| plan-template-kit | /home/terry/.zcode/skills/plan-template-kit/SKILL.md | 模板/轻量档分级（Rule 16/34/38）相关，确保 L0/mini/trivial 豁免口径一致。 | 主进程按需读取 |
| writing-plans | /home/terry/.agents/skills/writing-plans/SKILL.md | 结构化计划撰写与 S-unit/验收表述可借鉴，提升计划可执行性。 | 子代理 prompt 挂载（可选） |
| brainstorming | /home/terry/.agents/skills/brainstorming/SKILL.md | Phase 1 若条款形态存在多方案分叉（SKILL-only vs SKILL+core Rule），可用于方案对比前澄清。 | 子代理 prompt 挂载（可选） |
| subagent-driven-development | /home/terry/.agents/skills/subagent-driven-development/SKILL.md | 与“首动作委派/子代理驱动”模式匹配，可作为执行期派发与验收节奏参考。 | 子代理 prompt 挂载（可选） |
| verification-before-completion | /home/terry/.agents/skills/verification-before-completion/SKILL.md | 终验前强制证据化核验，匹配 Phase 5 VC 全绿与零增量 FAIL 交付门。 | 子代理 prompt 挂载（可选） |
| comet | /home/terry/.zcode/skills/comet/SKILL.md | 若用户后续要求按 comet 工作流推进实现，可作为流程强化入口；本任务当前未被用户显式触发。 | 用户手动触发（仅提示） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-initdelegation-20261115>` → 生成 knowledge/entries/_draft-task-initdelegation-20261115.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
