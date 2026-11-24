# Phase 2c: 技能质量层逐技能审核报告

- 任务: `task-project-audit-20261123`
- 审核范围: 31 个正式技能（顶层 21 + `task-planner/review-library` 11）
- 审核日期: 2026-11-23
- 审核方式: 只读静态审查（`ls/wc/sed/grep/python3` 模式扫描 + 关键 SKILL.md 分段 Read）；未执行 selftest/脚本运行时验证，未修改任何技能文件
- 维度: S78 SOP严谨性 / S82 验证完备 / S83 泛化 / S85 脚本优先 / S86 模板优先 / 描述准确性
- 评级: `PASS`=满足；`WARN`=可用但有缺口/债务；`FAIL`=缺关键门控或存在高风险误导
- 严重度: `P0`=可导致错误执行/虚假完成/安全或流程失控；`P1`=显著影响质量或可维护性；`P2`=改进项

## 证据采集摘要

| 证据 | 命令/方法 | 结果 |
|---|---|---|
| 技能清单与规模 | `ls skills/*/SKILL.md`, `wc -l` | 31 个 SKILL.md 全部存在；核心 7 共 1142 行，`task-planner/SKILL.md` 440 行/83KB |
| 资源盘点 | Python `os.listdir` 盘点 scripts/templates/references | `task-planner` scripts=163, templates=15, refs=8；`task-dispatch` scripts=6；`plan-resume` scripts=4；`md-edit-ops` scripts=2；`verification-gate` scripts=1+template=1 |
| 模式扫描 | Python regex 扫描 `vague/verify/script/template/gate` | 仅 4 处疑似模糊词命中，人工复核后 1 处为真实模糊表达（见下） |
| S85/S86 引用核对 | Python 检查 scripts/templates/references 是否在 SKILL.md 文本出现 | 发现未在 SKILL.md 提及的资产：`md-edit-ops/selftest-md-edit-ops.sh`、`plan-template-kit/inject-template-lineage.sh`、`task-discipline/references/execution-recall-card.md`；`task-planner` 大量 scripts 未被 SKILL.md 直接索引（多数为 selftest/机械脚本，需区分） |

> 局限：本报告是静态质量审查，不等于运行时正确性证明；`task-planner/SKILL.md` 仅分段读取（head/middle/tail + 定向 grep），其余核心技能完整读取。

## 31 技能逐项审核表

| 技能 | S78 SOP严谨性 | S82 验证完备 | S83 泛化 | S85 脚本优先 | S86 模板优先 | 描述准确性 | 严重度 | 关键发现（file:line） |
|---|---|---|---|---|---|---|---:|---|
| `context-corrector` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 六步 SOP 有 [M]/载体/豁免规则，复验要求 grep 0 命中或 superseded、Read 抽查≥1、progress 收口行（`skills/context-corrector/SKILL.md:23,43,61,70-75,95-99`）。无 scripts/templates，不适用 S85/S86。 |
| `error-fix-prompt-forge` | PASS | PASS | PASS | N/A | PASS | PASS | P2 | 输入契约 fail-closed、五步流程、QC-FP 逐条机检、三态 READY/PARTIAL/BLOCKED（`skills/error-fix-prompt-forge/SKILL.md:18,34,39,46,55-87`）。模板 `templates/fix-prompt-template.md` 被明确引用（`:49`）。 |
| `iterative-optimizer` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 有硬停条件、双轨评分、门控失败 STOP、最小必要观测面（`skills/iterative-optimizer/SKILL.md:28-34,62-80,93-107`）。未声明 scripts/templates，流程本身以判断+观测为主。 |
| `longform-continuity` | PASS | WARN | PASS | N/A | WARN | PASS | P2 | 角色/锚点/预算有明确表，但验证偏流程性（“冲突时按漂移处置”），缺可执行检查命令或最小验收清单（`skills/longform-continuity/SKILL.md:29-35,56-68`）；引用模板概念但目录无 templates 资产（`templates/` 未见），S86 仅轻度 WARN。 |
| `md-edit-ops` | PASS | PASS | PASS | WARN | N/A | PASS | P2 | 语义清晰：何时用/不用、CLI、schema、七步流水线、exit code、禁止裸 sed/python（`skills/md-edit-ops/SKILL.md:7-85`）。`scripts/selftest-md-edit-ops.sh` 存在但 SKILL 未提及（`skills/md-edit-ops/scripts/`），S85 发现性 WARN。 |
| `media-planner` | PASS | WARN | PASS | N/A | N/A | PASS | P2 | 定位/边界清楚，路由到 `references/critical-rules-media.md`（`skills/media-planner/SKILL.md:16-47`）。本体无执行步骤、无验收/证据要求，依赖卫星规则；作为路由型技能可接受，但 S82 为 WARN。 |
| `plan-collab-router` | PASS | WARN | PASS | N/A | N/A | PASS | P2 | 路由表和边界明确（`skills/plan-collab-router/SKILL.md:18-44`）；无验证步骤/失败判据，S82 WARN。description 与“路由器”职责一致。 |
| `plan-cost-guard` | PASS | WARN | PASS | N/A | N/A | PASS | P2 | Rule 17 关键契约速记清楚，明确“只承载知识/模板，不执行节流判定”（`skills/plan-cost-guard/SKILL.md:20-43`）。无校验命令/验收标准，S82 WARN；引用 references 完整。 |
| `plan-history-recall` | PASS | PASS | PASS | N/A | WARN | PASS | P2 | 五步流程、成本护栏、失败兜底、证据锚要求明确（`skills/plan-history-recall/SKILL.md:30-75`）。模板在 `references/brief-template.md`、`experience-card-schema.md` 被引用，非独立 templates/ 目录，S86 记为 WARN（命名/发现性，不是能力缺口）。 |
| `plan-research-router` | PASS | WARN | PASS | N/A | N/A | PASS | P2 | 路由边界清晰，指向 critical-rules-research/research-routing（`skills/plan-research-router/SKILL.md:16-45`）。无本地验证门，S82 WARN。 |
| `plan-resume` | PASS | PASS | PASS | PASS | N/A | PASS | P1 | 触发/不做/六步流程/失败兜底/守卫底线具体，可操作性强（`skills/plan-resume/SKILL.md:16-99`）。4 个脚本均被引用（`:74-77,91`）。P1 因其自主续推行为影响面大，但规则已有守卫；建议补“执行后证据字段”最小格式示例以强化 S82。 |
| `plan-template-advisor` | PASS | WARN | PASS | N/A | WARN | PASS | P2 | 六步 SOP 与边界铁律清楚（`skills/plan-template-advisor/SKILL.md:15-63`）。G2/G3 提到审查，但缺具体命令/产物路径校验清单；模板产出有路径约定但无模板文件资产，S82/S86 WARN。 |
| `plan-template-kit` | PASS | WARN | PASS | WARN | PASS | PASS | P2 | 明确知识层边界、不承接机械动作，引用 `scan-template-spec.sh`（`skills/plan-template-kit/SKILL.md:9,18,23`）。`inject-template-lineage.sh` 存在但未被 SKILL.md 引用（`skills/plan-template-kit/scripts/inject-template-lineage.sh`），S85 WARN。验证依赖 task-planner selftest，S82 WARN。 |
| `progress-tracker` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 先查后写、JSONL 契约、Step 0-4、闭环 Todo、防重复、查询接口具体（`skills/progress-tracker/SKILL.md:13-199`）。无 scripts 但命令简单明确；S85 N/A。 |
| `task-discipline` | PASS | WARN | PASS | WARN | N/A | WARN | P1 | 域边界和 Rule 索引完整（`skills/task-discipline/SKILL.md:16-104`），但本体主要是索引/路由，S82 依赖外部规则文件。`references/execution-recall-card.md` 未被 SKILL.md 引用，却被 `critical-rules-discipline.md` 引用（`skills/task-discipline/references/critical-rules-discipline.md:604`），存在引用面不一致；描述准确但“工作产物维护”较宽泛。 |
| `task-dispatch` | PASS | PASS | PASS | PASS | N/A | PASS | P1 | 域边界、规则索引、脚本表清晰（`skills/task-dispatch/SKILL.md:16-63`）。S82 有 check/selftest 脚本。债务：索引表称 12 条但正文称 15 条含 Rule 96/103/104 未入表（`:59`）——S78 文档严谨性 P1。跨技能 selftest 路径依赖 task-planner 机械层，已说明。 |
| `task-drift-guard` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 只读漂移检测、触发条件、计划源、判态、批量附加判定、STOP 规则明确（`skills/task-drift-guard/SKILL.md:16-91`）。S82 以证据输出报告为验收，符合只读技能定位。 |
| `task-planner` | WARN | PASS | WARN | WARN | WARN | WARN | P1 | 核心能力强：G1-G10、3-File、Todo 同步、D/A/B/C/E 判定、worktree 隔离、VC/验证门、planctl SOP（`skills/task-planner/SKILL.md:196-360,370-433`）。问题：440 行超大单文件，混合路由/规则摘要/操作 SOP，S78/S83 维护成本高；`description` 与 frontmatter references 很长，易漂移。S85：scripts=163 但 SKILL 只直接点名少量关键脚本，133 个未被 SKILL.md 直接索引（多数是 selftest/内部机械脚本），发现性和审计成本高；S86：templates 有 15 个但 `notepad-learnings/subagent_dispatch/batch_report` 未被 SKILL.md 直接引用（仓内其他文档有引用）。未见 P0 级“无验证/可伪完成”缺口。 |
| `todo-skill` | WARN | WARN | PASS | PASS | N/A | PASS | P1 | 流程清楚且工具存在（`skills/todo-skill/SKILL.md:35-128`, `skills/todo-skill/tools/cli_todo-manager.ts`）。S78/S82 缺口：Step 5b 仍是“按 description 执行对应操作”这类通用指令，缺每步完成判据/验证产物要求；失败策略“重试一次仍失败则跳过并标记 completed”可能掩盖未完成（`:105-109`），与证据铁律存在张力，建议改为 blocked+留痕而非 completed。 |
| `verification-gate` | PASS | PASS | PASS | PASS | PASS | PASS | P1 | 验证全链路定义优秀：VC 可执行性、V-N、终验、反作弊、冻结协议、独立性、run-verification.sh（`skills/verification-gate/SKILL.md:18-122`）。P1 非缺陷：规则严格度高，执行成本大；需持续确保与 task-planner/check-complete 的门数/口径同步。 |
| `workflow-model-tiers` | PASS | WARN | PASS | N/A | N/A | PASS | P2 | 模型分档表和升级规则明确（`skills/workflow-model-tiers/SKILL.md:20-104`）。S82 缺“如何验证实际模型路由被遵守”的检查点，更多是策略指导。 |
| `review-library/alignment-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 非 stub，结构完整：触发、写入前闸门、五维识别、证据要求、二值结论（`skills/task-planner/review-library/alignment-review/SKILL.md:1-113`）。唯一模糊词命中“尽量保留信息”（`:31`）为建议性措辞，非门控条件，S78 记 PASS。 |
| `review-library/code-quality-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 有检查清单、证据要求、结论格式（`.../code-quality-review/SKILL.md:1-79`）。无脚本是合理的（审查类技能）。 |
| `review-library/content-quality-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 覆盖准确性/一致性/可读性等维度，含证据和结论门（`.../content-quality-review/SKILL.md:1-88`）。 |
| `review-library/data-quality-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 数据质量维度、证据、PASS/FAIL/结论结构完整（`.../data-quality-review/SKILL.md:1-70`）。 |
| `review-library/documentation-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 文档审查维度明确，要求证据与结论（`.../documentation-review/SKILL.md:1-65`）。 |
| `review-library/general-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 作为兜底审查技能边界清晰，有检查项和结论格式（`.../general-review/SKILL.md:1-82`）。 |
| `review-library/image-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 图像审查维度具体（构图/文字/一致性/缺陷），有证据要求（`.../image-review/SKILL.md:1-96`）。 |
| `review-library/release-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 发布审查覆盖版本、变更、回滚、验证，证据导向（`.../release-review/SKILL.md:1-73`）。 |
| `review-library/security-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 安全审查维度和高风险阻断表述明确（`.../security-review/SKILL.md:1-77`）。 |
| `review-library/test-quality-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | 测试质量检查项细，强调证据/覆盖/可重复（`.../test-quality-review/SKILL.md:1-90`）。 |
| `review-library/ui-quality-review` | PASS | PASS | PASS | N/A | N/A | PASS | P2 | UI 质量维度完整，含可访问性/一致性/证据要求（`.../ui-quality-review/SKILL.md:1-95`）。 |

## 核心技能深审

### 1. task-planner (`skills/task-planner/SKILL.md`, 440行)

- **S78 PASS/WARN 边界：WARN (P1)**。优点是 G1-G10 合规清单、D/A/B/C/E 新指令判定、worktree 强制、planctl 权威源硬规则都很具体（`skills/task-planner/SKILL.md:196-360,370-433`）。主要问题是单文件承载过多：路由、规则摘要、操作 SOP、历史注记混在一起，增加维护和误读风险。`按需 Read` 在 `:250,:293` 属路由语境，非模糊执行；真正风险是“文档即系统”导致的漂移成本。
- **S82 PASS**。验证面强：`check-3file-gate.sh`、`archive-plan.sh`、`check-complete`、VC/verification-gate、planctl `validate/check/render`、证据锚要求（`:120-170,199-210,370-433`）。未实跑脚本，但规则存在且明确。
- **S83 WARN (P1)**。有通用框架，但大量 task-vXXX/日期/仓内特定治理历史嵌入正文（如 `:288-291`），对“技能说明”读者造成噪音，泛化可读性下降。
- **S85 WARN (P1)**。scripts 目录 163 个文件，但 SKILL.md 只直接索引少量关键脚本。模式扫描显示 133 个脚本名未在 SKILL.md 出现；其中大量 `selftest-*` 属机械守护，未必都应写入主文档，但缺少“脚本索引入口/分类说明”会降低可发现性。建议在 SKILL.md 或 references 增加“核心脚本索引 + selftest 由 run-selftests.sh/registry 管理”的显式说明。
- **S86 WARN (P2)**。templates 15 个中，`notepad-learnings.md`、`subagent_dispatch.md`、`batch_report.md` 未在 SKILL.md 直接出现；但它们在 README/examples/selftests/companion 中被引用（仓内 grep 证据）。说明模板生态存在，但 SKILL 主入口发现性不足。
- **描述准确性 WARN (P1)**。frontmatter description 概括正确，但 `references` 列表和正文规模极大，存在漂移风险；“卫星路由表 12 卫星”与实际生态需持续守护（文档内已有守护脚本生态，但主文档维护负担高）。

### 2. task-dispatch (`skills/task-dispatch/SKILL.md`, 63行)

- **S78 WARN (P1)**。整体清晰，但存在显式文档债务：规则索引说 12 条，后文又说明 Rule 96/103/104 已并入未入表（`skills/task-dispatch/SKILL.md:33-45,59`）。这是可追踪债务，但会影响执行者按索引理解范围。
- **S82 PASS**。有 `check-subagent-return.sh`、`check-rescue-chain.sh`、`subagent-fallback.sh` 及 selftest（`:47-57`）；边界声明“返回格式归本技能，内容正确性归 verification-gate”明确（`:3,11`）。
- **S83 PASS**。规则抽象为派发/调度域，无项目特例绑定。
- **S85 PASS**。scripts/ 全部被 SKILL.md 引用；跨技能 selftest 指向 task-planner 机械层也已注明 Rule 82 原因。
- **S86 N/A**。无 templates 目录；调度类不强制模板资产。
- **描述准确性 PASS**。description 与正文职责一致。

### 3. verification-gate (`skills/verification-gate/SKILL.md`, 122行)

- **S78 PASS**。三阶段模型（计划期/执行期/终验期）+ Step 1/2/3a/3b + 反作弊 9 条 + 判据冻结协议，门控明确（`skills/verification-gate/SKILL.md:18-107`）。“必须/禁止/FAIL/STOP/BLOCKED”表述可执行。
- **S82 PASS (强项)**。VC 可执行命令、V-N 全 PASS 才 complete、run-verification.sh、check-complete 21 门、独立验证、负控制/盲探针等要求完整（`:36-79,96-122`）。
- **S83 PASS**。虽有少量历史注记日期，但规则本身抽象为验证域契约。
- **S85 PASS**。本卫星 `scripts/run-verification.sh` 被引用；机械层脚本留守 task-planner 的原因说明清楚（`:108-116`）。
- **S86 PASS**。`templates/verification.md` 被引用（`:39,120`）。
- **描述准确性 PASS**。frontmatter 准确覆盖 VC 设计、V-N、终验、子代理复核触发。

### 4. plan-resume (`skills/plan-resume/SKILL.md`, 99行)

- **S78 PASS**。模式分流、自主推进守卫、六步工作流、失败兜底、决策框架 T1-T4、合法停点都具体（`skills/plan-resume/SKILL.md:11-99`）。
- **S82 PASS/WARN 边界：PASS**。有报告落盘、证据字段、熔断、阻断状态排除、复核要求；但“续推至交付”的完成证据格式可再模板化。当前不构成 FAIL。
- **S83 PASS**。通用计划恢复技能，路径和阈值参数化。
- **S85 PASS**。`scan-plans.sh/extract-meta.sh/score-plans.py/select-and-resume.sh` 全部被引用（`:74-77,91`）。
- **S86 N/A**。输出报告路径固定，但无 templates 目录；可考虑模板化，非必须。
- **描述准确性 PASS**。description 详细且与行为一致（含 v0.6 决策自主化边界）。

### 5. progress-tracker (`skills/progress-tracker/SKILL.md`, 199行)

- **S78 PASS**。Step 0-4、字段契约、先查后写、防重复、闭环 Todo、append-only/INDEX 更新明确（`skills/progress-tracker/SKILL.md:62-175`）。
- **S82 PASS**。写入后 Read 最后 3 行确认、查询命令、重复记录提示、完成后更新 done+实际 effect（`:110-116,131-175`）。
- **S83 PASS**。项目级账本模型通用，不绑定特定项目名。
- **S85 N/A**。无 scripts；命令短且直接，暂不构成脚本优先缺口。
- **S86 N/A**。无 templates；格式在文档中已给出 JSON/jq 示例。
- **描述准确性 PASS**。描述与 ledger/JSONL/跨会话职责一致。

### 6. todo-skill (`skills/todo-skill/SKILL.md`, 128行)

- **S78 WARN (P1)**。主流程有 Step 1-6，但 Step 5b 仍偏通用（“按 description 执行对应操作”），缺少“何为该步完成”的最小判据（`skills/todo-skill/SKILL.md:110-117`）。步骤顺序和清理规则明确。
- **S82 WARN (P1)**。有状态翻转和 session-kv 错误记录，但无验收/证据字段要求；失败后“重试一次仍失败则跳过并标记 completed”（`:105-109`）可能制造虚假完成信号，与仓库证据铁律冲突。建议改为 `blocked/pending` + 记录原因，完成态只在有证据时设置。
- **S83 PASS**。通用任务拆解技能。
- **S85 PASS**。`tools/cli_todo-manager.ts` 被引用且实际存在（`skills/todo-skill/SKILL.md:40-44,53,103`; `skills/todo-skill/tools/cli_todo-manager.ts`）。
- **S86 N/A**。无模板目录；TaskCreate 描述模板已内嵌。
- **描述准确性 PASS**。描述与“Agent 拆解 + 原生 Task + 持久化同步”一致。

### 7. task-drift-guard (`skills/task-drift-guard/SKILL.md`, 91行)

- **S78 PASS**。触发条件、计划源选择、完成度判定、三态动作、批量漂移判定、铁律清楚（`skills/task-drift-guard/SKILL.md:16-85`）。
- **S82 PASS**。虽不写文件，但要求报告基于 git diff/Read/TaskList 证据，STOP/询问动作明确（`:66-85`）；对只读守卫型技能是合适的验证形态。
- **S83 PASS**。适用于 plan/comet/batch 等多种计划源，抽象合理。
- **S85 N/A**。无 scripts；主要是读取与比对流程。
- **S86 N/A**。无 templates；报告模板在 examples/文档生态中。
- **描述准确性 PASS**。与“只读漂移检测、发现偏差 STOP 报告”一致。

## 跨技能共性问题归纳

1. **路由型卫星技能 S82 普遍偏弱（P2）**：`media-planner`、`plan-collab-router`、`plan-cost-guard`、`plan-research-router`、`plan-template-advisor`、`plan-template-kit`、`workflow-model-tiers` 多为“规则/路由/知识”型，正文缺最小验收清单或“调用后如何确认生效”的检查点。建议统一加“最小验证”小节：至少包含“已读哪个 reference / 产出什么决策记录 / 证据落点”。
2. **S85 发现性债务集中在 task-planner 生态（P1）**：`task-planner` 有 163 个 scripts，SKILL.md 无法也不应全文列举，但应提供分层索引（核心入口脚本、检查脚本、selftest 由 registry/run-selftests 管理）。当前 133 个脚本未被 SKILL.md 直接提及，审计与接手成本高。小范围同类问题：`md-edit-ops` 未提 `selftest-md-edit-ops.sh`；`plan-template-kit` 未提 `inject-template-lineage.sh`。
3. **S86 模板发现性不一致（P2）**：部分模板存在于 references/ 或仓内其他位置而非 templates/，或模板被其他文档引用但 SKILL.md 不提。`task-planner` 的 `notepad-learnings/subagent_dispatch/batch_report` 属此类。建议统一约定“SKILL.md 至少给模板索引入口”。
4. **完成态语义需防“假完成”（P1）**：`todo-skill` 在失败重试后仍可标记 completed（`skills/todo-skill/SKILL.md:105-109`）。这与 verification-gate/证据铁律的“无证据不算完成”方向冲突。建议将失败终态改为 `blocked` 或 `pending`，并要求记录阻塞证据。
5. **文档规模与漂移风险（P1）**：`task-planner/SKILL.md` 440 行且包含历史任务注记、规则摘要、路由、SOP，易出现索引/计数/引用漂移。已看到 task-dispatch 存在规则索引欠账注记（`skills/task-dispatch/SKILL.md:59`）。建议把历史注记下沉到 plan/findings 或 changelog，SKILL 保留稳定契约。
6. **review-library 整体质量较稳（P2）**：11 个 review 子技能均非 stub，结构、证据要求、二值结论基本一致；无脚本/模板是合理设计。主要改进机会是统一“最低证据格式”和“何时不适用/降级到 general-review”的边界句式。

## 审核结论

- **FAIL 数**: 0
- **WARN 数**: 14（`longform-continuity, media-planner, plan-collab-router, plan-cost-guard, plan-research-router, plan-template-advisor, plan-template-kit, task-discipline, task-dispatch, task-planner, todo-skill, workflow-model-tiers, plan-history-recall(S86轻), md-edit-ops(S85轻)`；其中 review-library 全部 PASS）
- **P0 问题**: 0
- **P1 问题**: 5 项聚焦（task-planner 维护/发现性负担；task-dispatch 规则索引债务；todo-skill 失败后标 completed 的假完成风险；task-discipline 引用发现性；plan-resume 仅建议补证据模板）
- **P2 问题**: 路由型技能验证门偏弱、模板/脚本发现性不一致、少量文档债务

> 总体判断：31 个技能均可读且职责边界大体清晰，未发现 P0 级阻断缺陷；主要风险集中在“流程完备性证明”和“文档/资产发现性一致性”，而非技能缺失。
