<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-sp-os-invocation-audit-20261124

- task_id: `task-sp-os-invocation-audit-20261124`
- 时间: created_at=2026-11-23T20:11:24Z / updated_at=2026-11-24T00:45:50Z
template_type: diagnostic
plan_tier: standard
execution_lane: L1
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 「我希望可以分析一下当前的技能的真实情况。」
- **R2（目标）** 「你可以调研一下最近几个最近的，就是说在修改之后的运行日志，查看是否存在这种情况」
- **R3（目标）** 「并给出相应的改进。」
- **R4（目标）** 「Superpowers或者是Openspec这两个就是技能的调用不是很理想，就是没有达到说解决问题，使用Superpowers或者是OpenSpec主动去解决问题，这是一个严重的问题。」

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 「我希望可以分析一下当前的技能的真实情况。」 | VC-2 | plan-brief §B R1=目标, user-session-log.md#1 |
| R2 | 目标 | 「你可以调研一下最近几个最近的，就是说在修改之后的运行日志，查看是否存在这种情况」 | VC-3, VC-4, VC-5, VC-6 | plan-brief §B R2=目标, user-session-log.md#1 |
| R3 | 目标 | 「并给出相应的改进。」 | VC-8 | plan-brief §B R3=结果（schema 仅 目标/手段，归目标）, user-session-log.md#1 |
| R4 | 目标 | 「Superpowers或者是Openspec这两个就是技能的调用不是很理想，就是没有达到说解决问题，使用Superpowers或者是OpenSpec主动去解决问题，这是一个严重的问题。」 | VC-4, VC-7, VC-10 | plan-brief §B R4=约束（schema 仅 目标/手段，归目标）, user-session-log.md#1 |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 用一手证据查清 11-16 路由修改后 SP/OS 两族技能是否被主动调用（调用并用于推进解决，仅文字提及不计）。 |  | plan-brief §A Goal |
| G2 | 定位「未被调用」的技能设计层根因（缺哪个驱动点/门 + file:line），逐条验证或推翻 H1-H5。 |  | plan-brief §A Goal |
| G3 | 产出可被驱动的改进方案（2-3 方案 + 推荐 + FILE-CHANGE + DRIVE-POINT）并经独立评审，待用户批准、本轮不实施。 |  | plan-brief §A Goal |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | G1 | 用一手证据查清 11-16 路由修改后 SP/OS 两族技能是否被主动调用（调用并用于推进解决，仅文字提及不计）。 | VC-2/VC-3/VC-4/VC-5/VC-6/VC-10 | S3, S4, S5, S6, S7, S8, S9, S10, S11, S12 | pending |
| G2 | G2 | 定位「未被调用」的技能设计层根因（缺哪个驱动点/门 + file:line），逐条验证或推翻 H1-H5。 | VC-7 | S13, S14 | pending |
| G3 | G3 | 产出可被驱动的改进方案（2-3 方案 + 推荐 + FILE-CHANGE + DRIVE-POINT）并经独立评审，待用户批准、本轮不实施。 | VC-8 | S15, S16, S17 | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1, S2 | VC-1, VC-9 | 计划建立与独立审计 | 2026-11-23T20:27:22Z | plan-brief §F |
| P2 | complete | S3, S4, S5, S6 | VC-2 | 设计层现状盘点（SP/OS 分文件 + 驱动点缺口两段） | 2026-11-23T21:36:37Z | plan-brief §F |
| P3 | complete | S7, S8, S9, S10 | VC-3, VC-4, VC-5 | 日志取证（schema→全量→逐会话→独立复检） |  | plan-brief §F |
| P4 | complete | S11, S12 | VC-6 | 侧证（计划目录 + OpenSpec 产物时间线） |  | plan-brief §F |
| P5 | complete | S13, S14 | VC-7 | 根因裁定（H1-H3 / H4-H5） | 2026-11-23T22:34:56Z | plan-brief §F |
| P6 | complete | S15, S16, S17 | VC-8 | 改进方案（对比推荐 + 落地清单 + 独立评审） | 2026-11-23T22:40:46Z | plan-brief §F |
| P7 | complete | S18, S19, S20 | VC-1, VC-2, VC-3, VC-4, VC-5, VC-6, VC-7, VC-8, VC-9, VC-10 | 终验交付（复验回读 + 报告 + 报告面审计） |  | plan-brief §F |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-2 |
| R2 | VC-3, VC-4, VC-5, VC-6 |
| R3 | VC-8 |
| R4 | VC-4, VC-7, VC-10 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 技能族入口依赖上游 SP 的 SessionStart hook 注入，但本机 config.json 的 SessionStart 事件只挂 task-planner 自家脚本，无任何 SP/OS 注入点；这不是执行方跳过，而是技能缺少可每次触发的入口驱动门（S13 H1 CONFIRMED，config.json:29-40 + 上游 hooks.json 抓取件）。 | CONFIRMED — SessionStart 缺注入 using-superpowers 入口技能的 hook 驱动点（config.json hooks.events.SessionStart 仅 zcode-sessionstart.sh 一条；上游 run-hook.cmd session-start 未接线；4 个 zcode-*.sh SP/OS 提及=0）。 | P6 方案阶段评估：SessionStart 增一条注入 using-superpowers 的 hook（对齐上游 run-hook.cmd session-start），须经独立评审与用户批准，本轮不实施。 | VC-7 |
| task-planner 的编排层对 SP/OS 只有文本级路由指针，命中触发条件后没有运行时脚本执行判定、也没有 CLI 探针驱动；对比自家 Plan Writer 派发有 todo/脚本驱动，SP 侧缺等价驱动点（S13 H2 CONFIRMED，SKILL.md:114 + spec-mode.md:7/12/16 + grep=0）。 | CONFIRMED — 路由触发面窄：SP/OS 仅 SKILL.md:114 一处文本指针（条件 L1+ 且模糊/多方向/规格类）+ spec-mode.md 文本路由表，check-*.sh 的 SP/OS 命中=0，无机器驱动门。 | P6 方案阶段评估：把 spec-mode 路由判定由文本路由表落成运行时驱动点、探针失败记不可接管；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| task-planner 自带与 SP 同功能的机制（修改后验证/Phase 翻转/终验门/收尾回读等）由 sync-todos.sh 脚本自动带出 B1-B8 必选组并配门链，形成稳定驱动；SP/OS 类比机制只有文本 iron law、无必选组/门，导致同功能被自家机制抢占（S13 H3 CONFIRMED，缺口在驱动层不在文本层）。 | CONFIRMED — 功能同构竞争：task-planner 自带机制有 sync-todos.sh:201-214 B1-B8 + todo-sync.md:28-40 六环门链驱动，SP/OS 仅文本指针、hook/todo 基线引用全 0。 | P6 方案阶段评估：把 SP/OS 技能到达做成 sync-todos.sh 必选基线组成员 + 门驱动（C5 指定形态）；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| OpenSpec 族技能的前置是项目根 openspec/ 目录与代理 PATH 内可调用的 openspec CLI；实测本仓根无该目录（隔离 scratch-init 验证 init rc=0 但这轮未执行以保 C1 只读），且 CLI 仅绝对路径可达、非登录 shell PATH 探针恒失败；窗口内唯一 OS 收据是已 merge 分支的遗留 worktree 未固化（S14 H4 CONFIRMED）。 | CONFIRMED — OpenSpec 落点缺失：本仓根无 openspec/（test -d rc=1、git log -- openspec=0）致 propose 无处落地，CLI 不在非登录 shell PATH（command -v openspec rc=1 / 绝对路径 1.6.0），窗口内 9 产物仅落遗留 worktree 未跟踪目录。 | 补项目根 openspec/ 初始化前置 + 探针内按可移植链解析 openspec CLI（$(npm config get prefix)/bin/openspec → command -v → 观测路径兜底），不硬编码绝对路径、不改 ~/.bashrc（其 :127 已有 export 但 probe rc=1=no-op）；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| Rule 59.2 规定技能靠伴飞 SKILL.md 路径+首动作 Read 到达子代理执行层（唯一可泛化注入路径），但承载该路径的字段在编码（s_units 无 escort）、渲染（parallel 占伴飞列）、门校验（check-dispatch 无 .md token 跳过）三处同时断链；本轮 S3-S6 技能到达靠派发 prompt 手填路径，属不可泛化补偿（S14 H5 CONFIRMED）。 | CONFIRMED — 到达不了执行层：伴飞技能字段载体三处断链（plan-brief.md:63 §F 7 列无伴飞列 / plan-state s_units 10 键无 escort / planctl.py:1271 用 parallel 串占渲染第8列），致 check-dispatch.sh:580/586 门无 .md token 跳过，Rule 59.2 路径+首动作 Read 无法制度性注入。 | P6 方案阶段评估：给 s_units 增伴飞字段并让渲染/门正确消费（修复 planctl.py:1271 列占用与 check-dispatch 门输入）；须经独立评审与用户批准，本轮不实施。 | VC-7 |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 计划与报告均经独立审计达标。判据：末轮审计 verdict=APPROVED，且存在与末轮轮次一致、以「[audit-before-delivery] verdict=APPROVED round=」开头的行动留痕（即报告面审计已登记）。改前：没有报告面审计留痕 → FAIL。 | jq -e --argjson r "$(jq -r '.audits[-1].round' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" '.audits[-1].verdict=="APPROVED" and (any(.actions[]; .text[0:48] == "[audit-before-delivery] verdict=APPROVED round=\($r)") or any(.actions[]; .text[0:49] == "[audit-before-delivery] verdict=APPROVED round=\($r)"))' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json |  |
| VC-2 | 设计层现状表落盘（R1）。判据：report-design-sp.md 的 SP 行 ≥14；report-design-os.md 的 OS 行 ≥11；report-driver-gap-1.md 与 report-driver-gap-2.md 的 DRIVER-GAP 行各 ≥1（改前文件不存在 → FAIL）。 | test "$(grep -c '^[\|] SP-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-sp.md)" -ge 14 -a "$(grep -c '^[\|] OS-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-os.md)" -ge 11 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-1.md)" -ge 1 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-2.md)" -ge 1 |  |
| VC-3 | 日志全量覆盖（R2）。判据：files ≥7 且逐一覆盖 11-18..11-24 七个日志文件的绝对路径；每文件 lines_scanned>0；parse_bad 为数值且 ≤ lines_scanned×5%。 | jq -e '.files[-7] != null and all(.files[]; .lines_scanned>0 and (.parse_bad - 0)==.parse_bad and (.parse_bad - 0) <= (.lines_scanned * 0.05)) and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-19.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-20.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-21.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-22.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-23.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-24.jsonl")' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  |
| VC-4 | 调用量化结论（R2/R4）。判据：totals 的会话数、调用数、used 数、提及数、openspec 调用数均存在，verdict 非空，definitions 非空。 | jq -e '.totals.sessions_main != null and .totals.sessions_main_with_sp != null and .totals.sessions_main_with_os != null and .totals.sessions_main_with_sp_used != null and .totals.sessions_main_with_os_used != null and .totals.skill_calls_sp != null and .totals.skill_calls_os != null and .totals.escort_reads_sp != null and .totals.escort_reads_os != null and .totals.openspec_cli_calls != null and .totals.mentions_text_sp != null and .totals.mentions_text_os != null and .totals.verdict != null and .totals.verdict != "" and .definitions != null' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  |
| VC-5 | 独立复检一致（R2）。判据：recheck.max_rel_diff ≤0.01 且 rechecker=Verifier。 | jq -e '.recheck.max_rel_diff<=0.01 and .recheck.rechecker=="Verifier"' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  |
| VC-6 | 侧证清点（R2）。判据：report-plans.txt 的 PLANS-EVID 行 ≥1；report-openspec-artifacts.txt 的 OS-ARTIFACT 行 ≥1。 | test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt -a "$(grep -c '^[P]LANS-EVID' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt)" -ge 1 -a "$(grep -c '^[O]S-ARTIFACT' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-openspec-artifacts.txt)" -ge 1 |  |
| VC-7 | 根因全覆盖（R4）。判据：root_causes 覆盖 H1-H5，每条 defect 以 CONFIRMED 或 REFUTED 开头，process 非空且 ≥61 字符（改前占位条目 defect 以 verified=false 开头 → FAIL）。 | jq -e 'all(.root_causes[]; (.defect[0:9]=="CONFIRMED" or .defect[0:7]=="REFUTED") and .process != "" and .process[60:61] != null) and .root_causes[-5] != null and any(.root_causes[]; .id=="H1") and any(.root_causes[]; .id=="H2") and any(.root_causes[]; .id=="H3") and any(.root_causes[]; .id=="H4") and any(.root_causes[]; .id=="H5")' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json |  |
| VC-8 | 改进方案 + 评审（R3）。判据：improvement-options.md 含 (Recommended) ≥1；improvement-proposal.md 的 FILE-CHANGE 行 ≥1、DRIVE-POINT ≥1；末轮审计 APPROVED。 | test "$(grep -c '[(]Recommended[)]' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-options.md)" -ge 1 -a "$(grep -c '^[F]ILE-CHANGE' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(grep -c 'DRIVE-POINT' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(jq -r '.audits[-1].verdict' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" = APPROVED |  |
| VC-9 | 写入范围零越界（C1）。判据：writes.txt 非空且不存在位于 `PD/`、`T/` 之外的路径。 | test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt -a -z "$(grep -v -e '^/mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/' -e '^/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt)" |  |
| VC-10 | 逐会话推进证据齐备（R4）。判据：sessions_with_calls_main 与 session_evid_rows 均存在且相等（零调用时二者均为 0）。 | jq -e '.totals.sessions_with_calls_main != null and .totals.session_evid_rows != null and .totals.sessions_with_calls_main == .totals.session_evid_rows' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 计划建立与独立审计
- **Status:** complete
- **Started:** 2026-11-23T20:27:22Z
- **Executor:** plan-writer(sonnet-1)、critic(opus-1)
- [x] V-1.1: VC-1（Phase 1 验证契约映射）
- [x] V-1.2: VC-9（Phase 1 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] 计划文档编码（计划文档编码） | plan-writer(sonnet-1) | plan-brief v3 §F 表行 S1（输入/验收/产物口径）；无独立产物文件（门控/复验/判定类） | §G 全部满足（工作文件 2 个：plan-state.json、knowledge-brief.md；checkpoint 文件另计） | 15min | 2f/80l/15min | 无 | - [parallel-group:无] | pending |
| S2 | [P1] 计划独立审计（Rule 109）（计划独立审计（Rule 109）） | critic(opus-1) | plan-brief v3 §F 表行 S2（输入/验收/产物口径）；无独立产物文件（门控/复验/判定类） | 出具 APPROVED 或分级问题清单；`[plan-audit-R<N>]` 留痕由主进程登记 | 10min | 0f/0l/10min | 无 | - [parallel-group:无] | pending |

### Phase 2: 设计层现状盘点（SP/OS 分文件 + 驱动点缺口两段）
- **Status:** complete
- **Started:** 2026-11-23T21:36:37Z
- **Executor:** agent-quality-auditor(sonnet-1)
- [x] V-2.1: VC-2（Phase 2 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S3 | [P2] Superpowers 族清单与驱动引用盘点（Superpowers 族清单与驱动引用盘点） | agent-quality-auditor(sonnet-1) | plan-brief v3 §F 表行 S3（输入/验收/产物口径）；T/report-design-sp.md | `T/report-design-sp.md`「技能清单」表：每技能一行，第一列为技能标识 `SP-<name>`（该行以竖线、空格再接 SP- 开头），列=安装位/触发条件原文/被引用处（文本指针、脚本、hook、模板、todo 基线组各几处）/证据 file:line；后附「上游入口机制与本机接线」小节 | 15min | 1f/100l/15min | 无 | - [parallel-group:g-ro] | pending |
| S4 | [P2] OpenSpec 族清单、CLI 可达性与项目初始化态（OpenSpec 族清单、CLI 可达性与项目初始化态） | agent-quality-auditor(sonnet-1) | plan-brief v3 §F 表行 S4（输入/验收/产物口径）；T/report-design-os.md | `T/report-design-os.md`「技能清单」表：每技能一行，第一列为 `OS-<name>`（该行以竖线、空格再接 OS- 开头），列同上；后附「CLI 可达性、各项目初始化态、opsx 命令在 ZCode 的可用性」小节；可选探针：仅在 `T/scratch-init/` 空目录用绝对路径试跑 `openspec init` 并记录产出，禁在仓库根或任何真实项目执行 | 15min | 1f/100l/15min | 无 | - [parallel-group:g-ro] | pending |
| S5 | [P2] 驱动点缺口·入口与计划期（会话启动、指令到达、初始化、计划制作、Spec 判定、审计、计划确认）（驱动点缺口·入口与计划期（会话启动、指令到达、初始化、计划制作、Spec 判定、审计、计划确认）） | agent-quality-auditor(sonnet-1) | plan-brief v3 §F 表行 S5（输入/验收/产物口径）；T/report-driver-gap-1.md | `T/report-driver-gap-1.md`：每条缺口标题含 `DRIVER-GAP-<n>`，列=应发生的时点/应由什么驱动/现状（驱动、仅提及、无）/证据 file:line/影响的技能 | 15min | 1f/100l/15min | 无 | - [parallel-group:g-ro] | pending |
| S6 | [P2] 驱动点缺口·执行与收口期（Phase 开启、派发前伴飞、执行中、完成声称前、收口归档）+ 对照机制（驱动点缺口·执行与收口期（Phase 开启、派发前伴飞、执行中、完成声称前、收口归档）+ 对照机制） | agent-quality-auditor(sonnet-1) | plan-brief v3 §F 表行 S6（输入/验收/产物口径）；T/report-driver-gap-2.md | `T/report-driver-gap-2.md`：同表结构；另含「对照机制」小节（取一个被稳定驱动的同类机制，列出其驱动链并与 SP/OS 逐点对比）；含子代理工具面清单（哪些 agent 有 Skill 工具）与 S-unit 伴飞列现状 | 15min | 1f/100l/15min | 无 | - [parallel-group:g-ro] | pending |

### Phase 3: 日志取证（schema→全量→逐会话→独立复检）
- **Status:** complete
- **Started:** 
- **Executor:** general-analyst(sonnet-1)、Verifier
- [x] V-3.1: VC-3（Phase 3 验证契约映射）
- [x] V-3.2: VC-4（Phase 3 验证契约映射）
- [x] V-3.3: VC-5（Phase 3 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S7 | [P3] 日志 schema 确认 + 扫描脚本 + 单日试跑（日志 schema 确认 + 扫描脚本 + 单日试跑） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S7（输入/验收/产物口径）；T/schema-notes.md, T/sp-os-scan.sh | `T/schema-notes.md`（≤50 行）+ `T/sp-os-scan.sh`（≤50 行：输入一个日志文件，流式输出 `T/parts/<日期>.json`，含 lines_scanned、parse_bad、bytes 与会话级信号计数）；已在 11-24 单日文件跑通且 lines_scanned 等于 `wc -l` | 15min | 2f/100l/15min | 无 | - [parallel-group:g-ro] | pending |
| S8 | [P3] 全量运行与汇总（前置=S7；全量运行与汇总） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S8（输入/验收/产物口径）；T/sp-os-assemble.sh, T/scan-stats.json | `T/sp-os-assemble.sh` + `T/scan-stats.json`（§H 结构；`recheck` 段留待 S10 写入；五个待 S9 回写的 totals 字段先置 null） | 15min | 2f/100l/15min | 无 | - [parallel-group:无] | pending |
| S9 | [P3] 逐会话推进证据与时间线（前置=S8；逐会话推进证据与时间线） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S9（输入/验收/产物口径）；T/report-log.md | `T/report-log.md`（≤100 行）；回写 `scan-stats.json` 的 totals 五个字段。若有 Skill 调用的主会话超过 35 个，先写前 35 个并在 blockers 报告 | 15min | 2f/100l/15min | 无 | - [parallel-group:无] | pending |
| S10 | [P3] 独立复检（前置=S9；独立复检） | Verifier | plan-brief v3 §F 表行 S10（输入/验收/产物口径）；无独立产物文件（门控/复验/判定类） | `scan-stats.json` 的 `recheck` 段（rechecker 固定为 `Verifier`、commands、max_rel_diff、sample_lines）；抽查 ≥3 条 SESSION-EVID 行各自对应的原始日志行 | 12min | 1f/40l/12min | 无 | - [parallel-group:无] | pending |

### Phase 4: 侧证（计划目录 + OpenSpec 产物时间线）
- **Status:** complete
- **Started:** 
- **Executor:** general-analyst(sonnet-1)
- [x] V-4.1: VC-6（Phase 4 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S11 | [P4] 计划目录侧证：11-18 起 `REPO/plans/` 与 `REPO/plans/archive/` 任务记录中的 SP/OS 使用痕迹（计划目录侧证：11-18 起 `REPO/plans/` 与 `REPO/plans/archive/` 任务记录中的 SP/OS 使用痕迹） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S11（输入/验收/产物口径）；T/report-plans.txt | `T/report-plans.txt`：`PLANS-EVID` 开头的行（≥1，每行带路径与日期）；末尾汇总窗口内任务数与各类型计数 | 15min | 1f/100l/15min | 无 | - [parallel-group:g-ro] | pending |
| S12 | [P4] OpenSpec 产物时间线：各项目 `openspec/changes/` 与归档（OpenSpec 产物时间线：各项目 `openspec/changes/` 与归档） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S12（输入/验收/产物口径）；T/report-openspec-artifacts.txt | `T/report-openspec-artifacts.txt`：`OS-ARTIFACT` 开头的行（≥1，含遗留 worktree 那个 openspec 目录的来源），每行带项目、路径、日期、状态 | 15min | 1f/60l/15min | 无 | - [parallel-group:g-ro] | pending |

### Phase 5: 根因裁定（H1-H3 / H4-H5）
- **Status:** complete
- **Started:** 2026-11-23T22:34:56Z
- **Executor:** general-analyst(sonnet-1)
- [x] V-5.1: VC-7（Phase 5 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S13 | [P5] 根因裁定 H1-H3（入口、触发面、同构竞争）（前置=S3,S4,S5,S6；根因裁定 H1-H3（入口、触发面、同构竞争）） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S13（输入/验收/产物口径）；T/report-rootcause-1.md | `T/report-rootcause-1.md`：每条假设给 CONFIRMED 或 REFUTED、≥2 个独立证据锚（file:line 或命令与输出）、验证命令 | 15min | 1f/100l/15min | 无 | - [parallel-group:无] | pending |
| S14 | [P5] 根因裁定 H4-H5（落点、到达执行层）+ 未调用情况量化解读（前置=S10,S13；根因裁定 H4-H5（落点、到达执行层）+ 未调用情况量化解读） | general-analyst(sonnet-1) | plan-brief v3 §F 表行 S14（输入/验收/产物口径）；T/report-rootcause-2.md | `T/report-rootcause-2.md`：同上；另含「零调用 / 仅提及 / 调用后未承接」三类会话的计数与归因 | 15min | 1f/100l/15min | 无 | - [parallel-group:无] | pending |

### Phase 6: 改进方案（对比推荐 + 落地清单 + 独立评审）
- **Status:** complete
- **Started:** 2026-11-23T22:40:46Z
- **Executor:** 主进程（例外理由：需主进程 Skill 工具 + 编排决策）、主进程（例外理由：编排决策）、critic(opus-1)
- [x] V-6.1: VC-8（Phase 6 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S15 | [P6] 方案对比与推荐（主进程，使用 Superpowers `brainstorming`）（前置=S13,S14；方案对比与推荐（主进程，使用 Superpowers `brainstorming`）） | 主进程（例外理由：需主进程 Skill 工具 + 编排决策） | plan-brief v3 §F 表行 S15（输入/验收/产物口径）；PD/improvement-options.md | `PD/improvement-options.md`：2-3 方案、推荐项居首并标 `(Recommended)`、每个方案的取舍 | 10min | 1f/100l/10min | 无 | - [parallel-group:无] | pending |
| S16 | [P6] 推荐方案落地清单（前置=S15；推荐方案落地清单） | 主进程（例外理由：编排决策） | plan-brief v3 §F 表行 S16（输入/验收/产物口径）；PD/improvement-proposal.md | `PD/improvement-proposal.md`：`FILE-CHANGE` 开头的逐文件改动行、每项含 `DRIVE-POINT`（驱动点）说明；不触犯 C4 | 10min | 1f/100l/10min | 无 | - [parallel-group:无] | pending |
| S17 | [P6] 方案独立评审（前置=S16；方案独立评审） | critic(opus-1) | plan-brief v3 §F 表行 S17（输入/验收/产物口径）；无独立产物文件（门控/复验/判定类） | APPROVED（0C/0I）或问题清单；评审面含 C1-C8 合规（含 C4 已否决项与 C5 基线组 todo 形态）及每项改动是否有驱动点 | 10min | 0f/0l/10min | 无 | - [parallel-group:无] | pending |

### Phase 7: 终验交付（复验回读 + 报告 + 报告面审计）
- **Status:** complete
- **Started:** 
- **Executor:** 主进程（例外理由：终验裁决与收尾回读属编排职责）、主进程（例外理由：编排职责）、critic(opus-1)
- [x] V-7.1: VC-1（Phase 7 验证契约映射）
- [x] V-7.2: VC-2（Phase 7 验证契约映射）
- [x] V-7.3: VC-3（Phase 7 验证契约映射）
- [x] V-7.4: VC-4（Phase 7 验证契约映射）
- [x] V-7.5: VC-5（Phase 7 验证契约映射）
- [x] V-7.6: VC-6（Phase 7 验证契约映射）
- [x] V-7.7: VC-7（Phase 7 验证契约映射）
- [x] V-7.8: VC-8（Phase 7 验证契约映射）
- [x] V-7.9: VC-9（Phase 7 验证契约映射）
- [x] V-7.10: VC-10（Phase 7 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S18 | [P7] 终验复验与收尾回读（前置=S17；终验复验与收尾回读） | 主进程（例外理由：终验裁决与收尾回读属编排职责） | plan-brief v3 §F 表行 S18（输入/验收/产物口径）；无独立产物文件（门控/复验/判定类） | VC-2..VC-10 逐条复验；双源交叉（各子代理返回的 files 字段逐条核对均位于 `PD/` 或 `T/` 内，结果记 actions）；root_causes 按 S13、S14 的裁定编码（每条 defect 以 CONFIRMED 或 REFUTED 开头，process ≥61 字符；`config.hypotheses` 的 verified 与 anchor 同步）；全文档收尾回读（Rule 84.14）。VC 命令唯一取自 `plan-state.json` 的 `vcs[].command`，不从 MD 视图照抄 | 10min | 0f/0l/10min | 无 | - [parallel-group:无] | pending |
| S19 | [P7] 交付报告撰写（前置=S18；交付报告撰写） | 主进程（例外理由：编排职责） | plan-brief v3 §F 表行 S19（输入/验收/产物口径）；PD/REPORT.md | `PD/REPORT.md`（≤100 行：结论先行，含窗口与盲区声明、关键数字、根因、推荐方案指针） | 10min | 1f/100l/10min | 无 | - [parallel-group:无] | pending |
| S20 | [P7] 报告面简版独立审计（[audit-before-delivery]）（前置=S19；报告面简版独立审计（[audit-before-delivery]）） | critic(opus-1) | plan-brief v3 §F 表行 S20（输入/验收/产物口径）；PD/REPORT.md, PD/improvement-options.md, PD/improvement-proposal.md, T/report-rootcause-1.md, T/report-rootcause-2.md | 对 PD/REPORT.md、PD/improvement-options.md、PD/improvement-proposal.md、T/report-rootcause-1.md、T/report-rootcause-2.md 出具 APPROVED（0C/0I）或问题清单；主进程登记审计时同时写一条以「[audit-before-delivery] verdict=APPROVED round=<轮次>」开头的行动留痕，随后复跑 VC-1 与 VC-8（rc=0）才可交付 | 10min | 0f/0l/10min | 无 | - [parallel-group:无] | pending |

## 🧮 根源覆盖表
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 技能族入口依赖上游 SP 的 SessionStart hook 注入，但本机 config.json 的 SessionStart 事件只挂 task-planner 自家脚本，无任何 SP/OS 注入点；这不是执行方跳过，而是技能缺少可每次触发的入口驱动门（S13 H1 CONFIRMED，config.json:29-40 + 上游 hooks.json 抓取件）。 | CONFIRMED — SessionStart 缺注入 using-superpowers 入口技能的 hook 驱动点（config.json hooks.events.SessionStart 仅 zcode-sessionstart.sh 一条；上游 run-hook.cmd session-start 未接线；4 个 zcode-*.sh SP/OS 提及=0）。 | P6 方案阶段评估：SessionStart 增一条注入 using-superpowers 的 hook（对齐上游 run-hook.cmd session-start），须经独立评审与用户批准，本轮不实施。 | VC-7 |
| task-planner 的编排层对 SP/OS 只有文本级路由指针，命中触发条件后没有运行时脚本执行判定、也没有 CLI 探针驱动；对比自家 Plan Writer 派发有 todo/脚本驱动，SP 侧缺等价驱动点（S13 H2 CONFIRMED，SKILL.md:114 + spec-mode.md:7/12/16 + grep=0）。 | CONFIRMED — 路由触发面窄：SP/OS 仅 SKILL.md:114 一处文本指针（条件 L1+ 且模糊/多方向/规格类）+ spec-mode.md 文本路由表，check-*.sh 的 SP/OS 命中=0，无机器驱动门。 | P6 方案阶段评估：把 spec-mode 路由判定由文本路由表落成运行时驱动点、探针失败记不可接管；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| task-planner 自带与 SP 同功能的机制（修改后验证/Phase 翻转/终验门/收尾回读等）由 sync-todos.sh 脚本自动带出 B1-B8 必选组并配门链，形成稳定驱动；SP/OS 类比机制只有文本 iron law、无必选组/门，导致同功能被自家机制抢占（S13 H3 CONFIRMED，缺口在驱动层不在文本层）。 | CONFIRMED — 功能同构竞争：task-planner 自带机制有 sync-todos.sh:201-214 B1-B8 + todo-sync.md:28-40 六环门链驱动，SP/OS 仅文本指针、hook/todo 基线引用全 0。 | P6 方案阶段评估：把 SP/OS 技能到达做成 sync-todos.sh 必选基线组成员 + 门驱动（C5 指定形态）；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| OpenSpec 族技能的前置是项目根 openspec/ 目录与代理 PATH 内可调用的 openspec CLI；实测本仓根无该目录（隔离 scratch-init 验证 init rc=0 但这轮未执行以保 C1 只读），且 CLI 仅绝对路径可达、非登录 shell PATH 探针恒失败；窗口内唯一 OS 收据是已 merge 分支的遗留 worktree 未固化（S14 H4 CONFIRMED）。 | CONFIRMED — OpenSpec 落点缺失：本仓根无 openspec/（test -d rc=1、git log -- openspec=0）致 propose 无处落地，CLI 不在非登录 shell PATH（command -v openspec rc=1 / 绝对路径 1.6.0），窗口内 9 产物仅落遗留 worktree 未跟踪目录。 | 补项目根 openspec/ 初始化前置 + 探针内按可移植链解析 openspec CLI（$(npm config get prefix)/bin/openspec → command -v → 观测路径兜底），不硬编码绝对路径、不改 ~/.bashrc（其 :127 已有 export 但 probe rc=1=no-op）；须经独立评审与用户批准，本轮不实施。 | VC-7 |
| Rule 59.2 规定技能靠伴飞 SKILL.md 路径+首动作 Read 到达子代理执行层（唯一可泛化注入路径），但承载该路径的字段在编码（s_units 无 escort）、渲染（parallel 占伴飞列）、门校验（check-dispatch 无 .md token 跳过）三处同时断链；本轮 S3-S6 技能到达靠派发 prompt 手填路径，属不可泛化补偿（S14 H5 CONFIRMED）。 | CONFIRMED — 到达不了执行层：伴飞技能字段载体三处断链（plan-brief.md:63 §F 7 列无伴飞列 / plan-state s_units 10 键无 escort / planctl.py:1271 用 parallel 串占渲染第8列），致 check-dispatch.sh:580/586 门无 .md token 跳过，Rule 59.2 路径+首动作 Read 无法制度性注入。 | P6 方案阶段评估：给 s_units 增伴飞字段并让渲染/门正确消费（修复 planctl.py:1271 列占用与 check-dispatch 门输入）；须经独立评审与用户批准，本轮不实施。 | VC-7 |

## 📦 进度产出基线
| 基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态 |
|---|---|---|---|---|
| T/report-design-sp.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-design-sp.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-design-os.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-design-os.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-driver-gap-1.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-driver-gap-1.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-driver-gap-2.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-driver-gap-2.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/schema-notes.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/schema-notes.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/sp-os-scan.sh | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/sp-os-scan.sh 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/sp-os-assemble.sh | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/sp-os-assemble.sh 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/scan-stats.json | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/scan-stats.json 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-log.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-log.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-plans.txt | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-plans.txt 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-openspec-artifacts.txt | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-openspec-artifacts.txt 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-rootcause-1.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-rootcause-1.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| T/report-rootcause-2.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：T/report-rootcause-2.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| PD/improvement-options.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：PD/improvement-options.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| PD/improvement-proposal.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：PD/improvement-proposal.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |
| PD/REPORT.md | 动工前基线：文件不存在（改前对应 VC FAIL）；plan-brief v3 §J Rule 111 进度产出基线 | 一单元一产物文件：PD/REPORT.md 在位且满足 v3 §F 对应 S-unit 验收 | 禁就地删降替；禁把多个单元产物并回单文件（粒度硬门回炉原因） | pending |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|---|---|---|
| 计划目录（S1 唯一可写面） | /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/knowledge-brief.md, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/1-plan-writer.md | /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/task_plan.md, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/findings.md, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/progress.md, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/verification.md（禁手工 Edit/Write，仅 render 派生）, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/user-session-log.md, /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-brief.md（只读需求锚/内容源）, delegations 段 H1（保留勿重复建） |
| 临时取证目录（执行期 S3-S9 可写） | /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/** | REPO 受管文件, 其他计划目录 |
| 仓库与基础设施（全期只读） | /mnt/data/dev/task-planner-skill（只读调研） | skills/, agents/, hooks/, ~/.zcode 配置, 任何部署位, 其他项目文件, 仓库其它文件 |
| 会话绑定脚本（禁运行） |  | attest-plan.sh, init-session.sh, set-active-plan.sh, plan-created.cjs |

## ⚠️ 核心问题定义
| 字段 | 值 |
|---|---|
| 核心问题 | 问题=用户观察到解决问题时 SP/OS 未被主动调用。至少 4 次有锚：10-08（/home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md:157 R5）、11-15（REPO/skills/task-planner/references/spec-mode.md:3）、11-16（同文件 :18）、11-24（PD/user-session-log.md #1）；另 11-23 记忆引述（二手：~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-slowness-forensics-20261123.md:10）。历次修复均为文本路由条款，问题仍在。本质（假设链 H1-H5，待 P2-P5 取证）=入口无驱动点 / 路由触发面窄 / 功能同构竞争 / OpenSpec 落点缺失 / 到达不了执行层。解决方案=根因确认后产出 2-3 个可驱动改进方案（首选 A 必选 todo 基线组 + 驱动点）并推荐。执行方案=P1 计划与审计 → P2 设计层审计 ∥ P3 日志取证 ∥ P4 侧证 → P5 根因 → P6 方案+评审 → P7 终验交付。 |
| 核心问题判断 | 以 VC-1..VC-10 全 PASS 为准；根因未定位前禁给修复方案（P6 必在 P5 之后）；C2 归因口径=技能缺驱动点 + file:line。 |
| 裁决 | 计划编码阶段（S1）；假设 H1-H5 均未验证，待 P5 取证定论。 |

## 🧰 工具选择与编排
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|---|---|---|
| P1 | planctl.py（set/render/validate/check） + Write（knowledge-brief.md + checkpoint） | 权威源经 planctl 写入，4 视图由 render 派生；禁手工 Edit MD。 |
| P2 | Agent agent-quality-auditor(sonnet-1) ×2 并发（g-ro） | 设计层只读审计互不依赖，Rule 21.4 独立性四问全否→并行组。 |
| P3 | Agent general-analyst(sonnet-1) ×2 + Verifier + Bash 扫描脚本 | schema 发现+脚本编写属复杂任务（Rule 110/C7）；Verifier 独立命令复检。 |
| P4 | Agent Explore | 跨目录侧证清点，只读大范围检索。 |
| P5-P6 | general-analyst(sonnet-1) / 主进程 Skill(brainstorming) / critic(opus-1) | 根因综合需证据归并；方案需主进程 Skill 工具；评审需独立上下文。 |
| workflow 编排 | 不命中 CreateWorkflow | 用户未点名 /workflow，Rule 39.8 激活条件未命中（plan-brief §J）。 |
| /goal 对齐 | 用户未使用 /goal | 如实披露：本任务为普通指令（plan-brief §J Rule 40.3）。 |

## 🔀 隔离决策
| 字段 | 值 |
|---|---|
| conflict_scan | safe（纯调研只读，无共享可变资源；宪法 §11.5 ③） |
| isolation/worktree_path | n/a（主工作树直做，无 worktree） |
| branch | n/a |
| merge_back | n/a（只读无合并） |

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|---|---|---|---|---|---|---|
| P3 | 日志 schema 判读错误致统计失真 | 6 | 3 | 2 | 36 | S7 独立复检 + 主进程核对原始样例行 |
| P5 | 根因写成「执行方」归因（违反 C2） | 5 | 2 | 2 | 20 | critic 驳回重写；每条根因写成技能缺驱动点 + file:line |
| P6 | 方案重提已否决项（C4）或无驱动点 | 5 | 2 | 2 | 20 | critic 驳回；C4 两条禁项逐项核对 |
| P3 | 全量扫描超时（单日 72M-226M） | 4 | 3 | 2 | 24 | 按日分片后台运行、逐日落盘 |
| P2 | 并发单元写同一文件（已由一单元一产物文件消除） | 3 | 1 | 1 | 3 | v3 §J：一单元一产物文件，S3-S6 各自独立产物（report-design-sp/os、report-driver-gap-1/2） |

## Decisions Made
| Decision | Rationale |
|---|---|
| D-1=可取证窗口 11-18..11-24（11-16、11-17 日志已不在磁盘，结论适用范围以此为限；由 S5 评估 db.sqlite 能否补） | v2 §J Decisions；§E F4 磁盘实测 7 个日志文件；11-16/11-17 无法取证。 |
| D-2=「运行日志」口径=ZCode 结构化日志为主、plans/ 记录与 openspec/ 产物为侧证，全量扫描禁抽样外推 | v2 §J Decisions；硬约束 C3 一手全量 + user-session-log #1 理解镜像 A2。 |
| D-3=A3「给出相应的改进」=交改进方案待批，本轮不实施（Phase 4 不在本计划）。 | user-session-log #1 理解镜像 A3 + plan-brief §A 方法论；根因未定位前禁给修复方案。 |
| D-4=Rule 30 不适用：本任务纯调研只读，无共享可变资源认领。 | plan-brief §D C1 只读；无 worktree、无技能源码写入。 |
| D-5=隔离=主工作树直做，无 worktree。 | 宪法 §11.5 ③纯调研/只读例外 + plan-brief §J 隔离决策。 |
| D-6=P3 执行体用 general-analyst(sonnet-1) 而非默认 log-distiller(haiku-1)。 | schema 发现 + 扫描脚本编写属复杂任务，Rule 110 + 硬约束 C7；禁 haiku 档做 schema 发现。 |
| D-7=D1 口径=非 goal 完成性指令，展示后 5 分钟超时按默认项自动通过（Rule 44.3），自动裁决记录落 progress。 | plan-brief §J Decisions；本任务非 /goal，按 44.3 默认项推进并留痕。 |
| D-8=root_causes 的 H1-H5 为待验证假设（schema 的 root_cause_item 为 additionalProperties=false，故假设明细放 config.hypotheses，s_units 无 depends_on 字段，前置依赖以 actions 文本承载） | v2 §J Decisions；实测 planctl schema 对 root_causes/s_units 均 additionalProperties=false，不降校验强度、不手工 Edit 权威源。 |
| Spec 模式触发判定=命中：spec-mode §1「优化改进类」+ §1b 信号修正「bug 排查→systematic-debugging」。调查阶段按 systematic-debugging 四阶段执行（本会话已实际调用该技能）；方案阶段 S10 按 §1b「L1 无规格留存→Superpowers 嵌入」用 brainstorming；OpenSpec propose 本轮不调用（本仓未 init，前置不满足），交 S4 取证并在方案中处置。 | 本任务是只读审计，审计期间执行 openspec init 会改变被审计对象的状态（H4），且写入并行会话共用的主工作树；init 属 spec-mode §2 免用户门动作，放到获批后的实施任务开头执行。依据 spec-mode.md:7,24,26。 |
| D-10=VC 命令中竖线只允许出现在正则字符类内（render 会把竖线转义，作管道用会失判别力） | v2 §J Decisions + §I 标题：VC-2 的 ^[\|] SP- / ^[\|] OS- 是字符类，非 shell/jq 管道；命令逐字取自 v2 §I。 |
| D-11=S11、S12 执行体用 general-analyst(sonnet-1)（Explore 为只读搜索体，无 Write 与 Edit，无法落盘产物与检查点） | plan-brief v3 §J Decisions；Rule 59.1 粒度硬门实测拒绝后回炉重拆，未放宽门槛。 |
| D-12=按粒度硬门把 S-unit 由 13 个重拆为 20 个，一单元一产物文件；S1 的工作文件为 2 个（checkpoint 文件另计） | plan-brief v3 §J Decisions；Rule 59.1 粒度硬门实测拒绝后回炉重拆，未放宽门槛。 |
| D-13=VC-1 加固：除末轮审计 APPROVED 外，还要求存在与末轮轮次一致的报告面审计留痕（行动文本以 [audit-before-delivery] verdict=APPROVED round= 开头）。 | 原 VC-1 只读末轮 verdict，计划审计 R3 已 APPROVED 时在报告面审计发生前即通过，无判别力（Plan Writer 自检如实报告）。加固版经五组正反样本实测。 |
| D-14=执行期视图刷新后重新 attest：P1/P2 Phase 状态翻转、盲区 R-BLIND-1 渲染、重复 A2 删除三次合法 render 改写 task_plan.md，致锁定哈希 7fa80a75 与当前 49c6eb7e 不符（PLAN TAMPERED）；经核实均为 planctl 权威源派生的合法变更、Decisions 已登记 D-13，故按 Rule 51.7 登记本条后重锁，非内容篡改。 | UserPromptSubmit hook 报 PLAN TAMPERED；主进程 sha256 对比+Decisions/actions 核查确认系自身多次 render 未重锁，符合 hook 处置路径（自己重规划→重跑 attest），无外部篡改证据。 |
| D-15=S9 复核结论（R-S9-1/A16）入权威源后再次重锁：render 改写 task_plan.md 致哈希 6911ee6c→新值，属执行期视图刷新、非内容篡改；按 Rule 51.7 登记后重跑 attest。 | 沿用 D-14 先例：planctl add research/actions 必然 render 刷新派生视图，attest 锁的是 task_plan.md 哈希，每次入账后须重锁。D-14 已登记同类纠正，本条为 S9 复核节奏的具体编号。 |
| D-16=P2/P3/P4→complete、P5→in_progress 相位翻转 + S10/S13 结论入账（R-S10-1/R-S13-1/A17）后重锁：phase-done/start 首次因漏 --plan-dir 未生效，已用正确参数补做；render 改写哈希，按 Rule 51.7 登记后重跑 attest。 | 沿用 D-14/D-15 先例：权威源写入+render 必然改哈希，每次入账后须重锁。本次为 P5 阶段切换的具体编号。 |
| D-17=P5→P6 相位翻转+root_causes 五条编码+hypotheses 五条 verified+parallel_groups.g-ro 七元素修正+S14 结论入账（R-S14-1/A18）后重锁；parallel_groups 修正系 S18 已登记待修项，提前做以减少重锁次数，不改任何 S-unit 语义。 | 沿用 D-14/D-15/D-16 先例：权威源写入+render 必改哈希，按 Rule 51.7 登记后重跑 attest。 |
| D-18=R-S17-1/R-S17-2 入账 + W-5 root_causes[H4].fix 去除 no-op PATH 接线 + proposal/options 按 S17 第3轮 1I/6W/5N 修订后重锁；按 Rule 51.7 登记后 render + attest，避免 PLAN TAMPERED。 | 权威源写入必改 task_plan.md 哈希；先登记决策编号再重跑 attest 是历次重锁先例；W-6 VC-8 口径由 S20 round=5 verdict 入账后自然闭合，禁预填 APPROVED。 |
| D-19=S20 报告面审计 round=5 APPROVED（0C/0I）+ [audit-before-delivery] 行动留痕 A20 入账后 render + attest 重锁；W-6 VC-8 口径闭合（audits[-1]=round5 APPROVED）。 | 权威源写入改 task_plan.md 哈希，按 Rule 51.7 先登记再重跑 attest；禁预填 APPROVED，verdict 来自 critic 复审实证。 |
| D-20=用户授权进入实施阶段（方案 A 全量 H1-H5），脱离 D-3 只读边界。实施载体=worktree tmp/worktrees/task-sp-driven-invocation-20261124(分支 wt/...)，三文件族并行子代理(general-coder)改 canonical 源 skills/；master 脏改动用 patch apply 避让、禁 git add -A 盲扫；config.json 由主进程备份+精确插入 hook（子代理禁碰）。 | §十一实现类强制 worktree 隔离；用户不满反复确认已明确推进；master 有他任务在途脏改动须 pathspec 限定；先登记决策再 render+attest 重锁(Rule 51.7)。 |
| D-21=方案A五驱动点全量实施完成：impl.patch(12文件) apply到master rc=0、部署位install同步(check11四项全绿)、config.json SessionStart hook精确注册(只增1条，其他事件不变)、verify-implementation.sh 21/21 PASS、全量selftest106/106。 | install rc=1 仅因4项既有漂移(smart-merge-back.sh/init-session.sh含$HOME硬编码，patch计数=0非本任务)，如实在台账记录不掩盖；用户#2授权推进已闭环。 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| planctl add --section actions（id=A1）→ AttributeError: Namespace object has no attribute id；动作未写入 | 1 | 改用 A2 写入并复验 | 顺带发现：935 行应为 entry.get(id)；本任务只读（C1）不改脚本，列入交付报告待授权 |

## 📊 委派统计
| 字段 | 值 |
|---|---|
| 总单元数 | 12 |
| 子代理执行数 | 10 |
| 最大并行宽度 | 4 |
| 复验通过数 | 0 |
