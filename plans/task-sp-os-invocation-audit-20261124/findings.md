<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-sp-os-invocation-audit-20261124

- task_id: `task-sp-os-invocation-audit-20261124`
- 时间: created_at=2026-11-23T20:11:24Z / updated_at=2026-11-24T00:45:50Z

## Requirements
- 「我希望可以分析一下当前的技能的真实情况。」
- 「你可以调研一下最近几个最近的，就是说在修改之后的运行日志，查看是否存在这种情况」
- 「并给出相应的改进。」
- 「Superpowers或者是Openspec这两个就是技能的调用不是很理想，就是没有达到说解决问题，使用Superpowers或者是OpenSpec主动去解决问题，这是一个严重的问题。」

## Findings
| id | text | source | tags |
|---|---|---|---|
| FR-1 | 探针断点（主进程一手实测）：代理 Bash 与 bash -lc 中 command -v openspec 返回 rc=1、command -v comet 返回 rc=1；PATH 不含 /home/terry/.npm-global/bin（导出语句在 ~/.bashrc:127）；绝对路径调用 openspec 返回 1.6.0。协同路由矩阵规定 OpenSpec 族「CLI 探针前置 command -v openspec」且「探针失败 → 该族标记不可接管」。 | T/probe-path.txt（主进程实测输出）+ ~/.zcode/skills/plan-collab-router/references/skill-collaboration.md:60,68 | 第一手, 设计层 |
| FR-2 | 上游入口机制（zread 抓取原文）：obra/superpowers 的 hooks.json 只有一个 SessionStart hook（matcher startup\|clear\|compact → run-hook.cmd session-start）。本会话开场 SessionStart 注入内容仅有 task-plan 与 task-resume 两段，无 Superpowers 入口内容。是否在本机 ZCode 接线待 S4 核 hooks 配置。 | https://github.com/obra/superpowers/blob/master/hooks/hooks.json（2026-11-24 抓取，原文存 T/upstream-superpowers-hooks.json） | 外部来源, 设计层 |
| FR-3 | 冲突分析（check-conflicts.sh init 模式）：信号①未提交 50 个文件（他会话）、信号⑤其中 5 个为运行中基础设施文件（他会话修改）、信号②3 个额外 worktree、信号③4 个 wt 分支、信号④28 个未完成任务。与本任务写域（PD/ 与 T/）无重叠。 | T/check-conflicts.log | 隔离决策 |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 取证盲区（S7 实证+主进程复核）：结构化日志 zcode-*.jsonl 只有 context.toolName、无工具入参，无法判定被调用的是哪个 SP/OS 技能；11-24 Skill 调用 11 次只是 Skill 工具调用计数，禁止写成 SP/OS 被调用。db.sqlite 只读探测亦无法补：skill 字段=user message 的 tools.Skill=true 开关，assistant tool_calls 抽样 500 条无技能名；rollout 文件有 input 但数分钟轮转仅剩 3 个。SP/OS 归因须靠设计层驱动缺口(S3-S6)+侧证(S11/S12)+文本提及对照，日志只能量化调用强度。 — T/schema-notes.md:3-7,23-26; T/recheck-notes.md db.sqlite 段; T/parts/2026-11-24.json raw
- S8 全量扫描主进程盘上复核通过：7 日文件全覆盖（11-18..24）、parse_bad=0；6 个归档日 lines_scanned 与独立 wc -l 逐一相等；恰 5 个待回写 null 字段（sessions_main_with_sp_used/os_used、sessions_with_calls_main、session_evid_rows、verdict）；sessions_main=169/sessions_sub=2003 为真实去重数（S8 纠正主进程派发摘要的置 0 误述，符合 §H）；raw skill_calls_total=99 仅为 Skill 工具调用强度、非 SP/OS 调用数；VC-3 rc=0、VC-4/10 rc=1 符合 S8 阶段预期。 — T/scan-stats.json files/totals/raw; 主进程 6 日 wc -l 独立比对; T/recheck-notes.md
- S9 逐会话证据主进程复核通过（纠正主进程首次复核漏 .totals 前缀的自身错误后）：5 字段实值 sessions_main_with_sp_used/os_used=0、sessions_with_calls_main=0、session_evid_rows=0、verdict 双面口径；全 null 字段=0；VC-4/9/10 rc=0；62 个 main+skill>0 会话复算属实，report-log.md 86 行第三节列前 35 符合 >35 blockers 验收；recheck 段仍留白待 S10。verdict 区分日志盲区不可判定与设计层12缺口+侧证可判定两面。 — T/scan-stats.json totals; T/report-log.md:15-21,82-86; T/writes.txt; 主进程 VC 实跑
- S10 独立复检 PASS（主进程纠正自身两处复核命令错误后确认）：recheck 段 rechecker=Verifier/status=done/max_rel_diff=0/commands=8/sample_lines=3；4 数字重算 sessions_main=169（跨日去重，253 为错误口径）、skill_calls_sp/os=0、openspec_cli_calls=0；3 条原始日志锚经三重过滤独立命中 tool.call.started+toolName=Skill 且 context 无 skill/input/command（坐实盲区）；去掉 recheck 后 sha256=846f9e99… 与回写前一致（字节保真）；VC-4/9/10 rc=0。 — T/scan-stats.json recheck; /home/terry/.zcode/cli/log/zcode-2026-11-{18,19,20}.jsonl 原始行; 主进程精确复核
- S13 H1-H3 裁定全 CONFIRMED（3 锚/条，缺口在驱动层不在文本层）：H1 config.json:29-40 仅 zcode-sessionstart.sh、4 个 zcode-*.sh SP/OS 提及=0；H2 SKILL.md:114 唯一文本指针+spec-mode.md 文本路由、check-*.sh SP/OS 命中=0；H3 sync-todos.sh:201-214 B1-B8 脚本带出但 SP/OS=0、B6 建组一次性。主进程独立复跑 hooks.events.SessionStart 仅 1 条、zcode-*.sh 提及=0、SKILL.md:114 在位，一致。 — T/report-rootcause-1.md:7-33,41-49; 主进程 config.json jq + grep 复跑
- S14 H4/H5 裁定全 CONFIRMED 并经主进程复核（独立复跑：本仓根无 openspec/ test -d rc=1、command -v openspec rc=1 vs 绝对路径 1.6.0、planctl.py:1271 parallel 占渲染第8列、s_units 10 键无 escort、§F 7 列无伴飞列，全复现）；三类计数复算：零调用 107（169-62）、仅提及 0（日志文本提及盲区口径值非事实断言）、调用后未承接 0（技能名不可判≠未承接）；99 次 Skill 调用只作强度，未写成 SP/OS 调用或零调用。 — T/report-rootcause-2.md:7-44; 主进程独立命令复跑; T/scan-stats.json totals
- S17 critic 第3轮 NOT APPROVED（0C/1I/6W/5N），12 发现经主进程盘上逐条复核全部成立：I-1 proposal:38 目标 references/plan-writer.md ls=ENOENT（真实文件 companion/agents/plan-writer.md:37「掌握的技能」节、grep 伴飞/escort=0）；W-1 variant 实 31 个(28 有列/3 轻量无表)非 28/19；W-2 cmd_init(planctl.py:780-808)仅消费 tier 拿不到需求特征→两级判定；W-3 新 hook 脚本缺 install.sh+verify.sh 部署同步；W-4 openspec 硬编码路径不可移植；W-5 root_causes[H4].fix 残留 no-op PATH 接线；W-6 VC-8 直取 audits[-1] 由 round4 支撑、本轮 verdict 未入账。R-BLIND-1/C2/C4/C5/D-3 无回归。 — PD/subagent-state/17-critic.md 第3轮段; 主进程盘上 ls/grep/jq 复跑
- S18/S19 完成：VC-2..10 逐条复跑全 rc=0（命令取自 plan-state.json vcs[] 原文）；writes.txt 45→46→47 行全在 PD/T 内、越界 0；Rule 84.14 六文档回读一致（P1-P5 complete/P6 in_progress/P7 pending、D-1..D-17、H1-H5 verified=true、VC 10 行、R4 verdict=APPROVED 双写一致）；PD/REPORT.md 45 行≤100 结论先行+窗口盲区+关键数字(169/2003/99/16/11/12缺口/SP0/OS1/rel_diff0)+H1-H5 file:line+方案A指针。 — 主进程 Bash 复跑 + PD/REPORT.md + T/drift-check.md S18/S19 留痕
- 用户 #2 明确授权推进方案 A 实施（原话见 user-session-log.md#2），指定用 using-superpowers 作入口+针对性 brainstorming/OpenSpec；审计阶段 C1/D-3（只读不实施）由此覆盖。实施期三事实核实：① config.json 真实结构是 hooks.events.SessionStart（:29-40 挂 zcode-sessionstart.sh，审计锚点正确）；② master 工作区 planctl.py 未提交改动属他任务 task-cli-help-examples，hunk 在 :136/:219/:560/:669/:810/:1775 与 H5 目标行(:127-128/:555-558/:1271)基本不重叠；③ hook 输出契约=严格单行 JSON {"additionalContext":...}、fail-open exit 0。 — 主进程 Bash 实测 config.json jq + git diff hunk + zcode-sessionstart.sh 源码
- 方案A三族实施完成并主进程独立复核通过：H1(zcode-sp-inject.sh 单行JSON注入三关键词+install Phase4.5+verify check11) / H5(planctl三处escort_skills+schema+plan-writer+check-dispatch fail-closed，dispatch selftest 4套件64断言PASS) / H2+H3(check-spec-route.sh 296行三档实测L1→SP嵌入/L0→不路由/bad-feature rc=1，B12/B13基线组B1-B11逐字保留)。patch apply --check rc=0 可干净入master(他任务脏改动hunk不重叠实证)。 — 主进程 Read 三族报告+独立实跑 selftest/check-spec-route/语法/verify-implementation+git apply --check
- 探针断点（主进程一手实测）：代理 Bash 与 bash -lc 中 command -v openspec 返回 rc=1、command -v comet 返回 rc=1；PATH 不含 /home/terry/.npm-global/bin（导出语句在 ~/.bashrc:127）；绝对路径调用 openspec 返回 1.6.0。协同路由矩阵规定 OpenSpec 族「CLI 探针前置 command -v openspec」且「探针失败 → 该族标记不可接管」。 — T/probe-path.txt（主进程实测输出）+ ~/.zcode/skills/plan-collab-router/references/skill-collaboration.md:60,68
- 上游入口机制（zread 抓取原文）：obra/superpowers 的 hooks.json 只有一个 SessionStart hook（matcher startup|clear|compact → run-hook.cmd session-start）。本会话开场 SessionStart 注入内容仅有 task-plan 与 task-resume 两段，无 Superpowers 入口内容。是否在本机 ZCode 接线待 S4 核 hooks 配置。 — https://github.com/obra/superpowers/blob/master/hooks/hooks.json（2026-11-24 抓取，原文存 T/upstream-superpowers-hooks.json）
- 冲突分析（check-conflicts.sh init 模式）：信号①未提交 50 个文件（他会话）、信号⑤其中 5 个为运行中基础设施文件（他会话修改）、信号②3 个额外 worktree、信号③4 个 wt 分支、信号④28 个未完成任务。与本任务写域（PD/ 与 T/）无重叠。 — T/check-conflicts.log

## Technical Decisions
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

## Issues Encountered
| Issue | Resolution |
|---|---|
| （本任务暂无问题记录） |  |

## Resources
- （本任务暂无资源引用）

## Visual/Browser Findings
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
## 本任务 tag 倒排引用
- （本任务暂无tag 引用）
