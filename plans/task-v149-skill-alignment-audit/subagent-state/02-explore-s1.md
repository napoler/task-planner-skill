# S1 一致性扫描检查点（主进程代写落盘）
> 来源：Explore 子代理（agent_1d000e50）返回报告原样落盘——Explore 工具面只读无 Write，检查点由主进程 22.5 复核时代写（2026-10-08）。子代理原始返回=会话记录。

## 发现汇总
H=3 / M=4 / L=3（共 10）

## H-1 SKILL.md:9 frontmatter「61 预留未落地」断言错误
- 证据：SKILL.md:9 写「62 四文件罗盘数据流转与调研知识沉淀纪律（61 预留未落地）」
- 实态：critical-rules.md:716 `### 61 偏移检查子代理化` 已存在；SKILL.md:277 摘要列表也正确列有 Rule 61
- 建议修复：SKILL.md:9 改「61 预留未落地」→「61 偏移检查子代理化」
- 关联：即 findings L2/L3（v145/v146/v147 三任务遗留的 frontmatter 上界措辞+61 括注）

## H-2 selftest-registry.tsv:50 行号锚全部失效
- 证据：registry 声明锚 `SKILL.md:286,201,310 / critical-rules.md:522-530`
- 实态：SKILL.md:286=Rule 20 内容、SKILL.md:201=C30、SKILL.md:310=Rule 43、critical-rules.md:522-530=Rule 49——期望均应指 Rule 51 相关
- 建议修复：行号锚迁移至 Rule 51 实际位置（或改 label 锚）
- 关联：findings L7（v136/v138 deferred「registry 存量行号锚迁移」）

## H-3 init-session.sh:380 行号锚超出文件范围
- 证据：init-session.sh:380 引用 `SKILL.md:524`；SKILL.md 实际仅 498 行
- 建议修复：更新该注释锚至实际行号/改 label 锚

## M-1 SKILL.md C 清单缺 C39
- 证据：SKILL.md 合规清单编号 C1-C38, C40-C44，C39 不存在
- 建议：确认 C39 为预留或废弃，行内标注（禁自行补占——编号语义需考证后定）

## M-2 check-doc-sync.sh 引用 config.json#sync_interval_calls 键缺失
- 证据：check-doc-sync.sh 引用 `sync_interval_calls`；config.json 实有 `todo_sync_interval_calls`
- 建议：考证键名变更史，改脚本引用或登记

## M-3 config.json periodic_review 孤儿键（v142 遗留）
- 证据：config.json 有 `periodic_review_enforce`+`periodic_review_interval_calls`，critical-rules.md 无对应条款；selftest-evidence-goal-gate.sh:241 已记「既有基线漂移面，已登记 deferred」
- 建议：与 periodic-review 条款考古联动处置（恢复条款则键合法化；退役则清键）
- 关联：findings L5/M-3=v142 memory「config 孤儿键归他账待清」

## M-4 selftest-plan-dispatch.sh:37 行号锚注释漂移
- 证据：注释引 templates/task_plan.md:144 期望 Executor 示例，实态该行=「核心问题定义」
- 建议：更新注释锚或注释语义

## L-1 SKILL.md 卫星技能引用裸路径（设计预期）
- references/billing.md、cost-control.md、research-routing.md、skill-collaboration.md、template-mapping.md 在 task-planner/references/ 不存在，实存于卫星技能目录——设计模式非错误，登记不改（SKILL.md References 表实际用 ../plan-*/ 前缀的行正常；发现面=正文个别裸引用，处置时逐处核对是否带 ../ 前缀）

## L-2 selftest-self-resolution.sh:15,76 注释行号锚演进滞后
- 注释记录「含 Rule 40/41→含 Rule 40-53」演进，未反映当前实态；注释级更新

## L-3 selftest-reliability-institution.sh:14,80 注释行号锚演进滞后
- 同 L-2，注释级更新

## 证据形态
grep '^### [0-9]'（Rule 头）/ grep -o 'C[0-9]\+'（C 清单）/ grep -n 'SKILL.md:[0-9]…'（行号锚全集）/ 路径 token ls 验证 / config 键对照

## 未验证项（子代理自报）
- selftest 行为级正确性（只验锚存在性）；config 实际值；卫星技能目录完整性
