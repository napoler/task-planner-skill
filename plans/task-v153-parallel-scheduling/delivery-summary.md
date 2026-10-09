# Delivery Summary — task-v153-parallel-scheduling（Rule 68 计划期依赖分析、并行分组、组内异构分摊与组域写一致性）

## 一、说明
用户目标：让 task-planner 在**计划初期**分析任务依赖、可并行者并行加速、有依赖者串行逐个击破；借鉴 dynamic-workflows 并行策略但纠正其「所有子任务丢给同一模型」缺陷（需不同 Agent+不同模型运作）；分组后组内更新状态防错乱。产出=新 Rule 68（七子条）+模板列+守卫两档+selftest+模式库/示例，全部落仓并合并部署。

## 二、产出清单（绝对路径）
- 条款：/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md:862-878（Rule 68 七子条；68.1 依赖分析/68.2 分组推导/68.3 组内异构/68.4 组域写隔离/68.5 workflow 三要点/68.6 守卫/68.7 机制）
- 模板列：/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md:277,279（S-unit 表「前置依赖」列）
- 守卫：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-plan-dispatch.sh:414+（H1-H4 hard+W1-W2 advisory+注解形态组归属兜底+F8 裸管道/列数漂移）
- selftest：/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-parallel-scheduling.sh（P-01..09）+ registry:66 行登记
- 入口：/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（计划期强制步骤:76/C46:220/1-68 级联×3/Rule 68 bullet:341）
- 文档：references/split-pattern-library.md:110（P12）+references/dispatch-examples.md:52（异构派发示例）+CHANGELOG.md[Unreleased]头条
- 修订：7+1 旧 selftest 钉值级联（含 G-07 健壮化）+三仓文档 1-65→1-68
- 簿记：plans/task-v153-parallel-scheduling/{task_plan,findings,progress,verification,design-rule68,plan-brief,delivery-summary}.md+baseline-selftest.log+regression-v1.log（R1-R5）+subagent-state/*（17 份）
- 合并：master b20974f（零冲突自动归并，v151 终态 5afba9c 与本任务 74177a6 并集）；三部署位 IDENTICAL；Rule 68 已 land

## 三、审查详细
- V1 回归 5 轮（独立执行体+主进程）：R1=7 FAIL（旧钉未级联）→级联修复→R2/R3/R4/R5 全 65/65 rc=0 ΣFAIL=0（基线 64 零新增失败）
- Code Review 两轮（code-reviewer 独立执行体）：R1=CHANGES_REQUESTED（1 MAJOR+7 MINOR）→fix A/B/C→R2=**APPROVED**（修复前后对照复现+夹具+负例；3 新 MINOR 中 2 已修）
- 对齐审查：载体（gp+Skill）两次取消→22.3.1 路由变更主进程六维机械核验全绿（已登记 Decisions+findings）
- 本计划自身=新机制第一个消费者：p3-core/p3-guard/p3-docs 三组并行+组内三 provider 混派（longcat/agnes×2）+组域写隔离；p3-core 墙钟 6min vs 串行预估 ~40min（R6「执行慢」直接对照）

## 四、风险点（必须列举）
- Rule 68.3 异构分摊当前无机器硬拦（advisory WARN）——为防误拦 68.7 壁垒半开；后续可对齐 43.2 档位表出硬门（已登记 design §四边界）
- 组间同波并行未开放（21.4 组间串行语义保留）——需富锁升级 {组名:ts}，为已知后续任务项（68.6 如实披露）
- 计划期依赖分析为 LLM 行为面（显式列+守卫一致性），非自动推断（YAGNI 明确排除）
- 未做「整体功能面/用户请求面」行为级冒烟验证（仅机制面 selftest——v150/v151 同款遗留登记）
- plan-writer/drift-checker provider 故障（当日多会话实证）与 alignment-review 载体取消：均已绕行+登记，待用户授权修复 agent 定义/排查 provider
- findings 初版含一次幻觉注入段（当次删除+Error Log 根因沉淀）

## 五、下一步建议
- 对象=scripts/check-plan-dispatch.sh W1 档位：看点=advisory→hard 提案依据；动作=下一任务评估模型可用性事实源后收口
- 对象=scripts/check-dispatch.sh serial_slot_check：看点=全局单锁；动作=富锁 {组名:ts} 使独立组可同波并行（68.2 边界演进）
- 对象=~/.zcode/agents/plan-writer.md frontmatter：看点=custom:9e221f47... sonnet-1 reasoning-missing；动作=用户授权后补 reasoning 档或换 provider
- docs/1 指针：验证方式=检查 /mnt/data/dev/task-planner-skill/CHANGELOG.md [Unreleased] 首条=v153 条目；看点=变更记录三要素齐全
