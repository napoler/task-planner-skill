# Critical Rules — 验证全链路域（Verification Gate 卫星）

> 本文件 = task-planner 第 11 卫星 verification-gate 规则全集，管**任务验证全链路**：计划期 VC 可执行化设计（Rule 84.1/84.3）→ 执行期 V-N 逐项校验与子代理产出复核（Rule 84.4）→ 终验 VC 逐条复验（Rule 84.5）。
>
> **迁移注记（task-v173 验证技能独立化）**：VC 规则由主技能 `references/goal-gate.md` 迁移为本文件 Rule 84.3；子代理验证协议由主技能 `references/completion-gate.md` 迁移为 Rule 84.4。迁移后主技能 `goal-gate.md`/`completion-gate.md` 改为指针（指向本文件），避免双份正文漂移（Rule 82 禁镜像副本）。
>
> **边界（Rule 82 分层）**：本卫星收编「验证机制规则」（VC 设计/可执行性/子代理验证/终验复验 SOP）；核心执行面规则保留原位——Rule 26（质量门控惩罚映射）、Rule 51（需求覆盖与完成声称）、Rule 66（goal 单元逐 goal 验证）全文仍在核心 `task-planner/references/critical-rules.md`，本文件以指针引用其验证面，不复制正文。

## 规则

### 84 验证技能独立化与 VC 可执行性纪律（P0 — task-v173，目标：把任务验证全链路从主技能罗盘管理解耦为独立卫星 verification-gate，VC 从描述性占位升级为可执行验证命令，确保「创建任务时即写好验证规则与脚本、所有产出及执行都有机器验证、执行稳定可复现」；判定面=计划期 VC 可执行性门（attest-plan.sh 拒锁）+ 执行期 V-N 校验 + 终验 VC 复验 SOP + selftest 静态守护，零新 config 键；衔接 Rule 20.1（attest）/26（质量门控）/51（完成声称）/66.3（goal 验证）/82（分层纪律），既有条款原文零改动）

**建制（为什么有这条）**：task-planner 此前把验证能力散落在主技能三处——`references/goal-gate.md`（VC 规则）、`references/completion-gate.md`（子代理验证）、`templates/verification.md`（VC 模板），三者都在核心罗盘管理域内，导致「验证」没有独立权威、VC 长期停留在描述性占位（`[What to check / test command / file to inspect]`，无强制可执行性）。用户 2026-10-14 裁决（R1-R4）：创建任务时必须把验证规则和脚本写到位，验证须独立于主技能之外并在执行步骤中引用，所有产出与执行都要有验证。本条把验证域建制为独立卫星并强制 VC 可执行化。

84.1 **VC 可执行性纪律（no-descriptive-only VC，P0）**：每条 VC（Verification Contract 条目）必须含**可运行验证命令**，三选一必具其一（Rule 66.1 同范式）——① 可运行的 bash 命令（如 `bash scripts/check-complete.sh <plan-dir>`、`grep -c 'Rule 84' file.md`）；② 文件路径+关键行（如 `skills/verification-gate/SKILL.md:5` 含 "Verification Gate"）；③ diff/输出形态判据。**禁止**「检查没问题」「验证通过」类无据表述。计划期 attest-plan.sh 的 VC 可执行性门（84.6 机制）对 standard/full 档硬校验：VC 条目缺可执行命令字段 = 拒锁回炉（fail-closed，与 66.5/59.1 同档）。mini/L0 档豁免（VC 条数降为 ≥2/≥1，但每条仍须有可执行命令）。

84.2 **验证域权威唯一性（satellite ownership）**：verification-gate 卫星 = 任务验证全链路唯一权威（VC 设计规则 84.3 + 子代理验证 84.4 + 终验复验 84.5）；主技能 task-planner 只管四文件罗盘管理，verification.md 契约的设计规则与终验 SOP 全文在本卫星，主技能 SKILL.md 只留指针（计划期/执行期/终验三处步骤引用 `Skill("verification-gate")`）。双份正文=漂移源（Rule 82），迁移后主技能 `goal-gate.md`/`completion-gate.md` 改为本文件指针，原正文删除。

84.3 **VC 规则（migrated from goal-gate.md）**：每个 `task_plan.md` 必须含 Verification Contract（VC 表），五条规则：
- ① **≥5 条 VC**（standard/full 档；mini ≥2；L0 ≥1）：客观、可测试、可追溯，且每条满足 84.1 可执行性
- ② **每 Phase ≥2 条 V-N**：映射到 VC 编号（Phase Gates 的 V-N 项）
- ③ **phase 间门控**：V-N 未全 PASS → 不进下一 Phase
- ④ **终验必做**：全 Phase complete ≠ 目标完成；必须逐条 VC 复验（84.5）
- ⑤ **升级阈值**：同一 V-N 重试 3 次 FAIL → AskUserQuestion（escalation_threshold）
- **VC 分级语义（Rule 50，指针）**：内容任务可按原子验收条目表做分级/加权评级（PASS/PARTIAL/FAIL 逐条 + 加权总分），作为二元三态之上的细化形态；不改变上述三态语义与五条规则（Rule 50 全文在核心 critical-rules.md）

84.4 **子代理验证协议（migrated from completion-gate.md）**：subagent 返回 "done" ≠ 完成，必须 Read 实际验证（Rule 5/26 Q4 互补）：
- ① **等通知** — 不轮询，等系统 notification
- ② **Read 实际文件** — 验证声称的变更确实存在（路径+行号+内容）
- ③ **标记 complete** — 仅验证通过后 Edit plan checkbox `- [ ]` → `- [x]`
- ④ **验证失败** — 不标记 complete，派 subagent 修复
- **证据要求**：Claims of "done" without evidence = FAILED。必须有文件路径+行号、验证输出（命令结果/文件内容）、Before/after 对比（适用时）
- **多任务同步（按 21.4 调度）**：未声明组=串行（S-unit 1 → 验证 complete → S-unit 2）；声明并行组（[P:Gn]）=组内成员可并行（独立性四问任一 yes=转串行），任一失败按 Rule 22.3 兜底（拆细先于升档）。Rule 21.4 全文在 task-dispatch 卫星

84.5 **终验复验 SOP（verification recheck SOP）**：全 Phase complete 后、交付前，按以下 SOP 执行终验（主技能「终验交付」步骤入口）：
- ① Read verification.md 的 Goal Gate 段
- ② 逐条 VC 执行 84.1 的可运行命令，对照判据出 PASS/FAIL
- ③ 可用统一入口 `run-verification.sh <plan-dir>`（本卫星 scripts/）解析 VC 命令自动执行并汇总
- ④ 质量门控统计（Rule 26 面）+ 委派统计（Rule 25.4 面）按模板段核查
- ⑤ 出 outcome：全 VC PASS → COMPLETE；VC PASS 但有已知遗留 → PARTIAL（列出+建议）；≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户
- ⑥ 终验前跑 `check-complete.sh`（21 门总门）exit 0 才可交付
- **验证独立性（Rule 33.3，指针）**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33 全文在 task-discipline 卫星）

84.6 **机制（零新 config 键）**：`run-verification.sh`（本卫星 scripts/，统一验证执行入口：解析 verification.md 的 VC 命令字段→逐条 bash 执行→输出 PASS/FAIL 汇总+未通过项清单）；`attest-plan.sh` 新增 **VC 可执行性门**（计划锁定前校验 standard/full 档 VC 条目每条含可执行命令字段，缺失拒锁，与 66.5/59.1 硬门同档，`--skip-vc-check` 逃生口对齐 `--skip-goal-check` 惯例，登记 Decisions）；`selftest-verification-gate.sh`（本卫星 scripts/）静态守护（84.1-84.6 子条文本锚 + 模板"验证命令"字段锚 + 主技能路由表/三处引用锚 + run-verification.sh/attest VC 门存在性 + 零新键负断言）；合规清单（主技能 SKILL.md 消费侧）。零新 config.json 键（properties 键数不变，env-only 开关 `TASK_PLANNER_VC_ENFORCE` 控 VC 可执行性门档位，对齐 64.6/80.6 env 开关先例）。

84.7 **内容审查门（task-v184，2026-10-17，R3 载体；P0）**：既有机器检查（84.6 机制面）止于格式/计数/存在性/词法/路径层，「语义级产出质量」零检查——文件真实但内容与声明无关、数字张冠李戴均无任何门拦截。84.7 在验证链路加一道独立内容审查门，管机器判不了的语义面：
- 84.7.1 **触发面**：VC 证据或交付物含非脚本产出（文档/报告/数据/配置/内容类）的计划 = 内容型交付；终验翻 COMPLETE 前必须完成一次独立内容审查（非内容型纯脚本交付不触发）
- 84.7.2 **独立性**：审查由独立子代理执行（Verifier/critic 档，全新上下文），主进程既有上下文自检不算（对齐 Rule 33.3 验证独立性的延伸——内容审查同受「主进程禁自测替代验收」约束）
- 84.7.3 **审查输入与维度**：输入 = 交付物全文 + VC 表 + 用户需求原文 R 行；维度 = ① 内容与声明一致性（防张冠李戴：交付物内容须与 VC 声明/plan 声称相符）② 数字/事实抽查（计数、路径、结论可复现，抽查命令留痕）③ 需求覆盖完整性（R 逐条对账，无遗漏无擅自扩面）④ 错误残留扫描（幻觉文件/幻觉事件/幻觉结论——声称存在的路径与结果逐一 Read 核证）
- 84.7.4 **结论落盘**：审查结论 = APPROVED / CHANGES_REQUESTED（+逐条意见）必须写入 findings.md 并带 file:line 证据；未落盘 = 禁止翻 COMPLETE；CHANGES_REQUESTED 未清 = 按 Rule 84.4 处置（不标记 complete，派子代理修复后重审）
- 84.7.5 **与机器层分工（互补不互代）**：CLAIM_MATCH（`check-evidence-anchor.sh` 内容层，task-v184 S6）管可判面（声明串 ↔ 证据文件内容核对）；本门管语义面（相关性/正确性/完整性）。机器层 PASS 不豁免本门，本门通过亦不替代机器层——两面须同时通过才可翻 COMPLETE
- **Why**：审计 report §7.3（severity high：全部机器检查止于格式/计数/存在性/词法/路径层，语义级产出质量零门拦截）+ 用户 2026-10-17 裁决原话「对内容的错误及时审查出来，确保可以及时纠偏。所有出现的错误都可以审查出来。提高内容错误的审查能力才是最核心的」——内容错误审查能力为本任务 R3 核心诉求，84.7 是其规则层载体。
