# 02-ledger-map — 盘点类台账测绘底稿（2026-10-05）

> 任务：找出 2026-10-05 前后 task-planner 对齐审计中盘点类代理的产物，测绘其信息维度与缺口，供下游免重读规范原文。
> 只读研究；本文件为唯一写入物。证据一律 path:line；「档案实证」=本会话亲读/亲跑，「推断」=基于实证的判断。

## 0. 审计轮次界定（档案实证）

本轮=2026-10-04 晚启动的动态工作流对齐审计（run `dwfrun-de932d4a-1aa4-4cc7-b465-929cb37e25c9`，脚本 `.zcode/workflow-drafts/task-planner-对齐审计.dwf.ts`）及其前后配套盘点线：
- 主体：三通道只读审计（结构盘点/部署比对/规范核对）+ 逐条独立复核 + 50 selftest 机器门，13/13 发现 verified（alignment-audit-workflow-20261004.md:13；align-audit-2026-10-05.md:11）。
- 前置盘点线：task-v125（87 agent 盘点+覆盖交叉审计+落仓矩阵，10-03/04）；跨任务复盘 round-retrospective（10-04）；v116/v117 对齐核查清偿线（10-02/03，源头 task-v107 报告 10-02）；后续 v130 行为冒烟（10-04 18:xx-10-05 03:30）。

## 1. ledgerArtifacts — 产物路径清单（档案实证，均本会话亲读）

### A. 本轮对齐审计直接产物
| # | 路径 | 是什么 | 证据 |
|---|------|--------|------|
| A1 | `/home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/align-audit-2026-10-05.md` | **本轮审计发现总台账**：13 发现全 verified（high 3/medium 5/low 5），逐条含 path:line 证据与修法 | :13-30 全清单；:11 审计口径 |
| A2 | `…/memory/alignment-audit-workflow-20261004.md` | 审计工作流拓扑+侦察一手事实（真源路径/SKILL 461 行/critical-rules 567 行/agent-coverage 128 行/规则标题格式 `### N`/50 selftest 无统一 runner/部署位实测） | :11-20 |
| A3 | `/mnt/data/dev/task-planner-skill/.zcode/workflow-drafts/task-planner-对齐审计.dwf.ts` | 审计工作流脚本（报告生成逻辑+看板列名） | :77 `artifact.board("findings-board")`、:306 `artifact.markdown("align-report")` |
| A4 | `/mnt/data/dev/task-planner-skill/.zcode/workflow-runs/dwfrun-de932d4a-1aa4-4cc7-b465-929cb37e25c9.mjs` | 该 run 编译快照 | ls 实测 24265B，10-05 00:23 |
| A5 | `/home/terry/.zcode/cli/exec/sess_dwf-dwfrun-de932d4a-1aa4-4cc7-b465-929cb37e25c9-actor_*/` | 各审计子代理原始执行日志目录（actor_1_1/1_2/1_3、actor_2_3/2_5） | `grep -rl dwfrun-de932d4a ~/.zcode/cli` 实测命中 |
| A6 | 发布产物 `align-report`（task-planner 对齐审计报告）+ `findings-board`（发现看板） | 工作流卡片产物；**磁盘落盘副本未找到**（find 全仓无 align-report/findings-board 文件）；持久面=A1 | 脚本 :306-310 定义 primary markdown 报告，字段=逐发现{位置/严重度/状态/证据/修复建议/复核}（:287-296） |

### B. 前置/配套盘点线产物
| # | 路径 | 是什么 | 证据 |
|---|------|--------|------|
| B1 | `skills/task-planner/references/agent-coverage.md`（128 行，落仓） | **Agent 覆盖矩阵**（Rule 52 单一事实源）：§一 26 行类型族×专用体×登记状态；§二 A/B 类缺口处置（B1-B5 带登记处锚）；§三 C 类 41 实体纳入/豁免表；§四 零专用体领域 10 行 | :9-40/:42-61/:63-111/:113-128；维护责任与守护脚本声明 :3-7 |
| B2 | `plans/task-v125/subagent-state/1-inventory.md` | 87 agent/14 族全量盘点：逐 agent{文件名/职责一句话/model 档}+model 档分布+9 大零专用体领域 | :14-160/:164-174/:179-188 |
| B3 | `plans/task-v125/subagent-state/2-coverage.md` | 三登记面×实体交叉审计：登记面锚 D1/D2/D3+覆盖矩阵+A/B/C 三类缺口（含 `test -f` 实证） | :7-11/:12-45/:47-74 |
| B4 | `plans/task-v125/findings.md`（27.5KB） | 审计 findings 汇总+Rule 52 全文草案+编号裁决留痕（48→50→52）+S1-S9 逐单元执行/复验记录+锚演进链 | :104-118 两审计转写；:49/:80 编号；:120-175 S1-S9 |
| B5 | `plans/task-v125/subagent-state/1-baseline-executor.md`（50.7KB） | 全量 selftest 基线：49 脚本逐脚本「==名/Total 行/rc 行」三行原文+910 行日志 | :1-13 头部+逐脚本段（selftest-active-plan Total 19 等亲读） |
| B6 | `plans/round-retrospective-2026-10-04.md` | 跨任务复盘报告（v118→v126）：任务全景+系统性发现 F1-F7+迭代优化评估+建议排序+风险提醒 | :9-18/:22-53/:55-61/:63-69/:71-74 |
| B7 | `…/memory/round-retro-2026-10-04-findings.md` | B6 的浓缩记忆版（七发现+迭代优化结论+优先建议） | 全文 |
| B8 | `plans/.rule-reservations.jsonl` | **Rule 编号预留账本**（v128 落地）：{rule,status:landed/contested/reserved,task_id,ts,note}，Rule 46-52 归属与 50 号撞号仲裁留痕 | 10 行亲读（50 contested 双认领 v125/v127） |
| B9 | `plans/task-v130/smoke-report.md` | 媒体执行体行为冒烟报告：L1 可见性/L2 SOP 守卫/L3 全链/L4 门控接受度 4 层判定+连带发现 F1（分隔符 /→+）/F2（Agnes 401） | :8-16/:24-29 |
| B10 | `plans/task-v117/findings.md:45-59` + `plans/task-v116/subagent-state/60-explore-v107-legacy.md` | sub:60 系统性对齐核查（8 残留逐条 path:line+三裁决口径+部署分叉审计+守卫零余量风险） | v117 findings :48-51；60-explore :9-33 |
| B11 | `plans/task-v107/report.md` | v107 深度审查报告（10-02，R 系列源头）：42 条目问题总表{ID/严重度/锚点/一句话/证据出处/修复建议}+三维分节 | :1-50+ 亲读（EX-1 videop1 分叉、P-1~P-6 等） |
| B12 | `plans/INDEX.md` + 各 `plans/task-*/ledger-main.jsonl` | 任务级进度台账（76 任务主表：Status/Phase/Goal/scope_files）+Phase 级流水（tick/ts/phase/event/summary） | INDEX.md:8-85；v125 ledger-main.jsonl 3 tick |
| B13 | `.zcode/ledger/task-planner-maintenance/task-planner-maintenance.jsonl` | 项目级长期维护账本（progress-tracker）；**最新条目 09-29，非本轮产物**，仅相邻 | INDEX.md 与 jsonl 尾 3 条亲读 |
| B14 | `plans/task-planner-skill-review/report.md` | v089 工作流审查报告（09-25）——**上一轮**，仅边界线索，非本轮产物 | ls 实测 21864B（内容未逐条读） |

## 2. dimensions — 台账实际承载的信息维度（逐维度给证据）

1. **Rule 条款级 path:line 锚点：有（发现级，非全文）**。A1 逐条锚到行（SKILL.md:251 索引缺 Rule 50、SKILL.md:9 陈旧「1-51」、SKILL.md:86 消费侧缺括注、check-dispatch.sh:71/:160、ARCHITECTURE.md:95-98/:13-16、delivery-summary.md:35-41、Rule 45.7 死路径→plans/task-v111/legacy-comment-audit.md）（align-audit-2026-10-05.md:20-26）；B3 登记面锚 D1=SKILL.md:333-357/D2=skill-agent-router:25-101/D3=template-mapping.md:258-289+:304-312（2-coverage.md:7-11）；B10 残留锚 critical-rules.md:320/326、cost-control.md:168、CLAUDE.md:81 等 8 处（v117 findings.md:48）；B11 §3 表每条带锚点列（P-1=SKILL.md:64、P-2=critical-rules.md:75 等）。
2. **断言/守卫名与断言值：有**。AC-01..08 逐条断言语义（agent-coverage.md:3、findings.md:64-75、findings.md [sub:S6] 实现细节含 awk FS 修复）；WF-10 守卫 6 命中压线零余量（60-explore:28）；WF-12 properties=40 零新键（findings [sub:baseline]）；RC-12 PASS（A1:16）、RC-15 负断言 ^52→^53 演进（findings [sub:S5]）；T-主/RL 系列 registry 计数（50=50）。
3. **行数定数与演进链：有**。SKILL.md 461（真源）vs 475（zcode 位）、critical-rules.md 567 vs 574、selftest-skill-split.sh:41 阈值 461→475（A1:14）；T-主 锚演进链 440→442→444→447→449→452→454→461（findings [sub:S5]）；agent-coverage.md 128 行（A2:16）；T-主 444→447（B6:14）；prompt 3013>3000（B6:40）。
4. **模板/登记面位置：有（位置与数量级，非区块结构）**。§九/§十执行体路由列锚区间+逐行锚（template-mapping.md:266/:268/:273-274/:277-288/:298 兜底条款/:304-312）（B3 §一二）；媒体工序 11 类具名清单（agent-coverage.md:37）；主模板 task_plan.md 440 行+29 variant 总数（A1:16）；v115 回流 12 variant 族清单（60-explore:21）。
5. **agent 实体清单与 model 档：有（全量）**。87 有效 agent 14 族逐行{文件名/职责/model 档}（B2:14-160）；model 档分布定数 haiku34/sonnet30/mini10/默认5/…（B2:164-174）；41 个未登记实体分相清单（B3:65-72）。
6. **部署位同步状态快照：有（10-04 晚时点）**。zcode 位 3 文件领先真源（禁按真源重装）、cursor 位 differ 35/缺 114/多 7、zcode SKILL mtime 10-04 23:17 晚于 HEAD 21:05 疑似在途（A1:14-15）；三宿主唯一分叉=selftest-workflow-orchestration.sh 旧版（60-explore:31）；videop1 双向漂移 28 vs 16 variant（B11 §2.3 EX-1）。
7. **selftest 基线与回归定数：有**。49 脚本基线逐脚本 Total 行+机械和 574（B4 [sub:baseline] + B5 全文）；50/50 rc=0、PASS 和 752=744+8（B4 [sub:S7]/[sub:S8]）；42/42 660/0（B11 §2.2）。
8. **缺口三类处置状态：有**。A 类兜底已登记/v124 承接、B1-B5 修正去向+状态、C 类 41 行逐行纳入/豁免+理由（B1 §二三四；B3 §二）。
9. **Rule 编号归属与撞号仲裁：有**。46-52 landed/contested/reserved 全留痕，50 号双认领待仲裁（B8）。
10. **任务级进度/范围/落点：有**。76 任务 Status/Phase/Goal/scope_files/日期（B12 INDEX.md）；Phase 流水含 commit/锚预扫摘要（v125 ledger-main.jsonl tick1-3）。
11. **行为冒烟结果与连带发现：有**。4 层判定+证据指针+deferred 改进建议（B9）。
12. **系统性发现与建议排序：有**。F1-F7 严重度分级+迭代优化适用性+推荐序（B6/B7）。

## 3. gaps — 台账没记、下游仍必须重读规范原文的信息（≤5）

1. **Rule 条款正文全文**：账本只记编号/状态/锚行（B8 仅 {rule,status,task_id,note}）；除 Rule 52 全文转写外（B4 findings.md:50-63），Rule 1-51 正文语义未入任何台账——按条款语义执行/判断冲突仍须读 `references/critical-rules.md` 对应行。
2. **SKILL.md 路由表与摘要区行级原文**：台账只给锚区间与漂移备注（D1=333-357，实测已漂至 :347-371，B4 [sub:S3]「行号漂移备注」自证），且 zcode 位 475 vs 真源 461 分叉在途（A1:14）——区间锚不可直接复用，逐行内容仍须读 SKILL.md 本体。
3. **模板本体内部结构**：台账记了位置与数量定数（主模板 440 行/29 variant/§九§十锚区间），但模板内区块字段、S-unit 表列定义、配置表行语义、variant 个体差异未入台账——生成或校验计划仍须读 `templates/task_plan.md` 与目标 variant 本体。
4. **config.json 门控键语义**：台账只记定数「properties=40 零新键」（AC-07）与「零新键」结论，键名→enforce 行为映射未入任何台账——改门控行为仍须读 `config.json` + 消费脚本。
5. **部署位实时同步状态**：A1 是 10-04 晚静态快照且自记 zcode 位疑似在途写入（mtime 10-04 23:17 > HEAD 21:05，A1:14）——differ 计数/行数定数随每次合并/部署过期，实时状态必须重跑 diff 实测，不能消费台账旧值。

## 4. 未找到 / 能力缺口（如实记录）

- 发布产物 `align-report`/`findings-board` 的磁盘落盘文件：**未找到**（find 全仓+~/.zcode 无命中）；其内容持久面=A1 记忆转写 + A5 原始 exec 日志。
- `ListWorkflowRuns`/`GetWorkflowRun` 在本子代理会话**不可用**（工具返回 capability gap），run 终态与 artifact 卡片正文无法经 API 读取——上述 A6 结论基于脚本源码+磁盘 find 实测。
- B14（v089 report）与 B13（项目级 ledger）内容未逐条读，仅定位与时间戳核实。

## 5. 最终结论（同 submit_result）

**ledgerArtifacts（11 项核心）**：①skills/task-planner/references/agent-coverage.md（落仓覆盖矩阵，26 族×专用体×登记态+A/B/C 缺口处置+零领域清单）②plans/task-v125/subagent-state/1-inventory.md（87 agent/14 族全量盘点+model 档分布）③plans/task-v125/subagent-state/2-coverage.md（三登记面×实体交叉审计，D1/D2/D3 锚）④plans/task-v125/findings.md（审计汇总+Rule 52 草案+锚演进链+S1-S9 复验）⑤plans/task-v125/subagent-state/1-baseline-executor.md（49 脚本基线原文）⑥plans/round-retrospective-2026-10-04.md（F1-F7 复盘）⑦~/.zcode/cli/memories/.../align-audit-2026-10-05.md（本轮 13 发现总台账，high3/medium5/low5 全带 path:line）⑧~/.zcode/cli/memories/.../alignment-audit-workflow-20261004.md（审计拓扑+侦察事实）⑨plans/.rule-reservations.jsonl（Rule 46-52 编号账本）⑩plans/task-v130/smoke-report.md（行为冒烟+F1/F2）⑪plans/task-v117/findings.md:45-59+plans/task-v116/subagent-state/60-explore-v107-legacy.md（sub:60 对齐核查 8 残留）；辅助：plans/task-v107/report.md（42 条目源头报告）、plans/INDEX.md+ledger-main.jsonl（任务级）。

**dimensions**：台账已承载——条款级 path:line 锚点（发现级）、断言/守卫名+断言值（AC/WF/RC/T-主）、行数定数与演进链、模板/登记面位置锚、87 agent 全量清单+model 档、部署位同步快照、selftest 基线定数（574/752/660）、缺口处置状态、Rule 编号归属、任务级进度、行为冒烟结果、系统性发现与建议（12 维，证据见底稿 §2）。

**gaps（下游仍须读原文）**：①Rule 1-51 条款正文全文（账本只记编号/状态/锚行）②SKILL.md 路由表/摘要区行级原文（锚区间已漂移+双位行数分叉）③模板本体区块/S-unit 表列结构④config.json 键名→enforce 行为映射⑤部署位实时同步状态（快照会过期且 zcode 位在途）。
