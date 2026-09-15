# Checkpoint 01-plan-writer (task-v075-fine-grain-methodology)

## M1 已读输入 (2026-09-16)
- [x] findings.md（全节：A S-unit 粒度零机器校验 / B methodology 开关键零消费方 / Technical Decisions 三行 / v063 遗留①②）
- [x] plans/task-v074-template-matrix-reflect-loop/task_plan.md（结构参照：VC 表/S-unit 表/Handoff 表/FMEA/隔离决策/Frontmatter 缺省）
- [x] skills/task-planner/templates/variant/rule-enhancement-type.md（要填充的变体模板本体，含 7 列 S-unit 表注）
- [x] scripts/check-plan-dispatch.sh（138 行；:37-40 legacy fail-open；:84-124 Phase 扫描与 S-unit 表头/行/执行体三项校验；不查规模数值）
- [x] scripts/check-dispatch.sh（253 行；scan_missing 七项文本存在性；无 prompt 长度/多 S-unit 打包检测；:167-179 三级解析兜底 warn fail-open）
- [x] scripts/attest-plan.sh（139 行；:80-120 template-gate 三档 resolve_template_tier 范式=新 fmea 门控挂载范式；fail-open 显式化先例 :92-97）
- [x] scripts/check-complete.sh（781 行；:453 已挂 check-plan-dispatch；:464 RESCUE-CHAIN；无 FMEA/methodology grep 命中）
- [x] config.json（:339-357 step_max_files/lines/minutes + prompt_max_chars 键定义区与 :394-397 默认值区；:61 dispatch_contract_enforce；:71 content_quality_enforce；:81 fmea_enforce；:101 knowledge_brief_enforce）
- [x] lib/verify.sh（:225-235 §9 循环 = check-delegation.sh/allow-direct.sh/selftest-delegation.sh 存在性检查；未含 selftest-methodology）
- [x] templates/task_plan.md（:182 S-unit 表 HTML 注释；:229 FMEA 段标题）
- [x] selftest-methodology.sh（96 行；M-01..M-07 七断言；hermetic mktemp 夹具范式）
- [x] critical-rules.md（:114 21.1b；:117 21.4；:124 22.3；:127 22.4；:132 22.6；:169 25.1）
- [x] methodology.md（:37-51 R2 FMEA RPN；:137 DeepMind 2023 与 :158 Anthropic 2024 两处「待补」出处=v063 遗留②）
- [x] git master=3e9a451；status：plans/.active_plan 删除 + 2 个 .plan_required_side 删除 + task-v074 .plan-attestation 修改 + task-v075 目录 untracked——全部在 plans/ 内，与实现类 scope 零重叠

## M2 骨架完成 (2026-09-16)
- [x] 10 Phase 骨架定稿（P1 worktree/P2=A1/P3=A2/P4=B1/P5=B3/P6 模板 2 文件/P7 SKILL+critical-rules 2 文件/P8 CHANGELOG+README_zh 2 文件/P9 全量回归/P10 合并部署推送簿记）；P2-P8 每 Phase S-unit 表 7 列、NNmin≤15、输入≤2 文件
- [x] VC 7 条 + FMEA RPN 表 5 行（含 RPN>100 兜底）+ 隔离决策/Decisions/deferred 清单定稿

## M3 终稿落盘
- [ ] task_plan.md 全量填充
- [ ] knowledge-brief.md 五段填充

## M3 终稿落盘 (2026-09-16)
- [x] task_plan.md 全量填充（10 Phase + 13 S-unit 行 + VC 7 条 + FMEA 5 行 + 隔离决策/Decisions/Deferred/Handoff 全表；knowledge_brief 指针行已登记）
- [x] knowledge-brief.md 五段填充（§1 速览 7 术语 / §2 9 条已验证事实 / §3 10 锚点 / §4 7 易错点+FMEA 兜底指针 / §5 13 S-unit 材料包索引）
- [x] 结构自检：10 个 `### Phase`；13 行 S-unit 全 NNmin 且 ≤15min；Phase 状态由「## Phases」总览表 + 各 Phase `- **Status:** pending` 行承载（10/10）；VC 7 条非空；无 "Batch Report"/裸 Status/裸 [complete] 契约标记误触风险；S1..S3 输入列均 ≤2 文件

status: complete
acceptance: V1-V7 为执行期判定（本计划为规划产物，plan-writer 不执行 Phase）；计划结构自检通过
