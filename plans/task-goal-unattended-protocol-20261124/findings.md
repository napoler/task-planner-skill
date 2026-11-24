<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Findings: task-goal-unattended-protocol-20261124

- task_id: `task-goal-unattended-protocol-20261124`
- 时间: created_at=2026-11-23T16:44:25Z / updated_at=2026-11-23T22:37:41Z

## Requirements
- 用户原话（user-session-log #1 逐字）：「当前  skill子啊  goal 模式下导致不能自主确认推进 ,导致无效多次循环是严重的缺陷  没有达到自主角色目标  sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb 会话就是示例 必须对skill缺陷进行解决」
- user-session-log #2 裁决一：goal 模式部署预授权+护栏
- user-session-log #2 裁决二：本次部署到全部运行位
- user-session-log #2 裁决三：decision-arbiter 对齐 GLM-5.4 + max

## Findings
| id | text | source | tags |
|---|---|---|---|
| FR-1 | 示例会话形态：150 条消息；真实用户消息 2 条（`/goal`、`授权`）；宿主 verifier 续推 14 轮（消息 ID `msg_goal_verify_target_…_1..14`）；`AskUserQuestion` 9 次无应答；部署决策翻转 3 次；前 10 轮续推均触发实质动作；用户「授权」到达后模型未执行任何预案。来源：ReadSession 分页回读 + 落盘页 `~/.zcode/cli/artifacts/sess_18af15b1-d11e-45ab-8597-ca72e1b32c1c/call_1cb7005b66e9487f809f6713-tool-result-65480603-eed9-4f3f-8a19-08642e482f5f.json`；旁证 `plans/task-resource-utilization-20261123/REPORT.md` §7-§11、`task_plan.md`。 | plan-brief.md §B11 FR-1 | 第一手取证 |
| FR-2 | 非部署漂移：`~/.zcode` 与 `~/.agents` 运行位的 goal 自治相关文件与源仓逐文件 diff=0（仅 `.agents/task-planner/SKILL.md` 落后 5 行，属他任务欠账）。 | plan-brief.md §B11 FR-2 | 第一手取证 |
| FR-3 | 升级终点清单（均以「升级用户/AskUser」收尾）：`critical-rules-verification.md:24`（84.3⑤）、`:40`（84.5）；`critical-rules.md:204`（109.2）；`critical-rules-discipline.md:28`（escalation_threshold）、`:144`（41.5）、`:183`（44.3）、`:186`（44.5）、`:395`（69.3）、`:449`（72.1 A 级）、`:653`（97.5）；`critical-rules-dispatch.md:53`（retry_limit）、`:225`（96.7）；`SKILL.md:119/123-124/346`。 | plan-brief.md §B11 FR-3 | 第一手取证 |
| FR-4 | 旧措辞全仓字面面 9 处（grep 实测）：见 B7 第 2 行。 | plan-brief.md §B11 FR-4 | 第一手取证 |
| FR-5 | `TASK_PLANNER_GOAL_MODE` 全仓无写入方（`resolve-interaction-mode.sh:52-58` 的 goal 分支运行时不可达）；goal 语境实际靠模型读语境判定，示例会话判定正确——识别不是病因。 | plan-brief.md §B11 FR-5 | 第一手取证 |
| FR-6 | 28.8 无任何 selftest 文本锚（脚本面 grep「28.8 / 单次降级收口 / goal 自治 / 强制自治」仅 1 条注释命中）。 | plan-brief.md §B11 FR-6 | 第一手取证 |
| FR-7 | decision-arbiter：源 frontmatter `GLM-5.3 + thoughtLevel: enabled`；宿主 ListModels 显示 individual 计划下仅 `GLM-5.4`、`GLM-5.3-Flash`，GLM 系列档位 `low/high/max`；运行位 11-23 已为 `GLM-5.4 + max`。示例会话内两次派发失败：首轮（消息 `msg_mwsqaxy2_bc16e046-c10d-4221-951a-448c21068874`「裁决体因环境配置失败（Reasoning level unsupported，非限流）」）与第十轮（消息 `msg_mwssig10_3…`「decision-arbiter 因 reasoning level 不支持而失败」）；留痕 `plans/task-resource-utilization-20261123/.agent-failures/df5b8b4a85364c7e87acfd85024635eb.jsonl`。 | plan-brief.md §B11 FR-7 | 第一手取证 |
| FR-8 | `~/.zcode/commands/goal.md`（2026-08-26，143 行，引用 `~/.claude/skills/...`）通篇「等待确认/AskUserQuestion/升级用户/用户确认接受」；官方命令指南（zcode-guide `diagnosing-commands`）载明与内置命令撞名的本地命令在交互面被过滤——判为潜伏隐患、非本次主因。 | plan-brief.md §B11 FR-8 | 第一手取证 |
| FR-9 | 运行位现状（部署前实测，`pre-deploy-site-state.log`）：5 位 × 6 文件全部存在、均为普通文件；`~/.zcode` 6/6 与源一致；其余位存在既有差异（agents SKILL.md 5 行；claude discipline 4 行 + SKILL.md 5 行；opencode 5 个文件 1-10 行；cursor discipline 4 行 + SKILL.md 10 行）——均为其他任务的历史欠账，部署必须原样保留。 | plan-brief.md §B11 FR-9 | 第一手取证 |

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|---|---|---|---|
| （本任务暂无知识对齐记录） |  |  |  |

## Research Findings
- 示例会话形态：150 条消息；真实用户消息 2 条（`/goal`、`授权`）；宿主 verifier 续推 14 轮（消息 ID `msg_goal_verify_target_…_1..14`）；`AskUserQuestion` 9 次无应答；部署决策翻转 3 次；前 10 轮续推均触发实质动作；用户「授权」到达后模型未执行任何预案。来源：ReadSession 分页回读 + 落盘页 `~/.zcode/cli/artifacts/sess_18af15b1-d11e-45ab-8597-ca72e1b32c1c/call_1cb7005b66e9487f809f6713-tool-result-65480603-eed9-4f3f-8a19-08642e482f5f.json`；旁证 `plans/task-resource-utilization-20261123/REPORT.md` §7-§11、`task_plan.md`。 — plan-brief.md §B11 FR-1
- 非部署漂移：`~/.zcode` 与 `~/.agents` 运行位的 goal 自治相关文件与源仓逐文件 diff=0（仅 `.agents/task-planner/SKILL.md` 落后 5 行，属他任务欠账）。 — plan-brief.md §B11 FR-2
- 升级终点清单（均以「升级用户/AskUser」收尾）：`critical-rules-verification.md:24`（84.3⑤）、`:40`（84.5）；`critical-rules.md:204`（109.2）；`critical-rules-discipline.md:28`（escalation_threshold）、`:144`（41.5）、`:183`（44.3）、`:186`（44.5）、`:395`（69.3）、`:449`（72.1 A 级）、`:653`（97.5）；`critical-rules-dispatch.md:53`（retry_limit）、`:225`（96.7）；`SKILL.md:119/123-124/346`。 — plan-brief.md §B11 FR-3
- 旧措辞全仓字面面 9 处（grep 实测）：见 B7 第 2 行。 — plan-brief.md §B11 FR-4
- `TASK_PLANNER_GOAL_MODE` 全仓无写入方（`resolve-interaction-mode.sh:52-58` 的 goal 分支运行时不可达）；goal 语境实际靠模型读语境判定，示例会话判定正确——识别不是病因。 — plan-brief.md §B11 FR-5
- 28.8 无任何 selftest 文本锚（脚本面 grep「28.8 / 单次降级收口 / goal 自治 / 强制自治」仅 1 条注释命中）。 — plan-brief.md §B11 FR-6
- decision-arbiter：源 frontmatter `GLM-5.3 + thoughtLevel: enabled`；宿主 ListModels 显示 individual 计划下仅 `GLM-5.4`、`GLM-5.3-Flash`，GLM 系列档位 `low/high/max`；运行位 11-23 已为 `GLM-5.4 + max`。示例会话内两次派发失败：首轮（消息 `msg_mwsqaxy2_bc16e046-c10d-4221-951a-448c21068874`「裁决体因环境配置失败（Reasoning level unsupported，非限流）」）与第十轮（消息 `msg_mwssig10_3…`「decision-arbiter 因 reasoning level 不支持而失败」）；留痕 `plans/task-resource-utilization-20261123/.agent-failures/df5b8b4a85364c7e87acfd85024635eb.jsonl`。 — plan-brief.md §B11 FR-7
- `~/.zcode/commands/goal.md`（2026-08-26，143 行，引用 `~/.claude/skills/...`）通篇「等待确认/AskUserQuestion/升级用户/用户确认接受」；官方命令指南（zcode-guide `diagnosing-commands`）载明与内置命令撞名的本地命令在交互面被过滤——判为潜伏隐患、非本次主因。 — plan-brief.md §B11 FR-8
- 运行位现状（部署前实测，`pre-deploy-site-state.log`）：5 位 × 6 文件全部存在、均为普通文件；`~/.zcode` 6/6 与源一致；其余位存在既有差异（agents SKILL.md 5 行；claude discipline 4 行 + SKILL.md 5 行；opencode 5 个文件 1-10 行；cursor discipline 4 行 + SKILL.md 10 行）——均为其他任务的历史欠账，部署必须原样保留。 — plan-brief.md §B11 FR-9
- 计划审计三轮收敛：R1 REJECTED（1C/6I/8W/2Q）→ 修订后 R2 上轮 17 项全部闭环但新增 I-7（为堵「泛化授权」把 72.1 A 级整体划为永不自动，与 41.2 G4 silent、44.3 D2/D5、28.8① 冲突）→ 只拦 D6 类后 R3 APPROVED。条款设计教训：封堵漏洞时按子集拆分，禁把上位类别整体收紧；每轮修正都要回查与既有条款的相容性。 — subagent-state/02-critic.md（R1-R3 段）；plan-brief.md §B10 D-8/D-9/D-10；edit-spec.md E0
- task-planner 机器门实测口径（本任务踩坑）：手动运行 check-dispatch.sh pretool 做预检会写 subagent-state/.dispatch-inflight 串行锁（120s 内拦下一次派发）；派发稿里的圈号列表计入步骤枚举（上限 4）；S-unit 须整数编号且纯子代理 Phase 受 59.1 粒度三值硬门（≤2 文件/≤100 行/≤15 分钟）；R→VC 映射列只认 VC 编号；audit-add 的 issues.state 枚举为 open/fixed/accepted/new/deferred；planctl render 把 V-N 复选框硬编码为已勾（已知局限，未改渲染器）。 — 本会话错误留痕 E1-E5；check-dispatch.sh:634-680；check-plan-dispatch.sh:187-330；planctl.py:192-193
- 执行期独立审查（S11）R1：E1a-E25 逐条一致、28.9 行与规格逐字相同、结构正确、diff 统计吻合；两处已登记执行偏差（D-12 落点、注释闭合符迁移）均获认可；REJECTED 的 1C/1I 为「断言与规则正文仍写旧模型」——与主进程 fresh selftest 的 DA-02 FAIL 同源。 — subagent-state/10-critic.md；after-selftest.log
- S18 三次派发「停摆」的真实原因=供应商侧模型请求延迟：宿主日志按 agent id 过滤可见 subagent.background.started 后首个 model.request 从 19:40:32 到 19:43:22 才完成，其后每轮 2.5-3 分钟；hook.run.allowed（无钩子拦截），tool.call 持续推进；第四个执行体（general-purpose）约 9 分钟完成 S18。结论=非死锁、非守卫拦截；E7 的「通道停摆、未定位」表述据此更正。 — /home/terry/.zcode/cli/log/zcode-2026-11-24.jsonl（19:40-19:48Z 段，按 0f3e2e7a 过滤）
- 独立裁决体（decision-arbiter，GLM-5.4+max，派发冒烟成功）对部署完成声称裁决 COMPLETE：自写脚本整行相等核对 45 项 hard_bad=0、强校验 35/35、备份与改前记录 45/45 吻合、备份→现文件的变更行集与补丁行集 45/45 相等、9 份补丁与 git diff 逐字节相同、运行位独有行 0 丢失。另查明：opencode 位的 dispatch 规则文件等若干运行位文件本就是比源码更旧的版本（别的任务遗留的部署漂移），本次只落增量，旧漂移保留——verify.sh 的 3 个 fail 即此类。 — subagent-state/12-decision-arbiter.md；after-verify.log 与 baseline-verify.log 的 FAILED checks 段
- 示例会话形态：150 条消息；真实用户消息 2 条（`/goal`、`授权`）；宿主 verifier 续推 14 轮（消息 ID `msg_goal_verify_target_…_1..14`）；`AskUserQuestion` 9 次无应答；部署决策翻转 3 次；前 10 轮续推均触发实质动作；用户「授权」到达后模型未执行任何预案。来源：ReadSession 分页回读 + 落盘页 `~/.zcode/cli/artifacts/sess_18af15b1-d11e-45ab-8597-ca72e1b32c1c/call_1cb7005b66e9487f809f6713-tool-result-65480603-eed9-4f3f-8a19-08642e482f5f.json`；旁证 `plans/task-resource-utilization-20261123/REPORT.md` §7-§11、`task_plan.md`。 — plan-brief.md §B11 FR-1
- 非部署漂移：`~/.zcode` 与 `~/.agents` 运行位的 goal 自治相关文件与源仓逐文件 diff=0（仅 `.agents/task-planner/SKILL.md` 落后 5 行，属他任务欠账）。 — plan-brief.md §B11 FR-2
- 升级终点清单（均以「升级用户/AskUser」收尾）：`critical-rules-verification.md:24`（84.3⑤）、`:40`（84.5）；`critical-rules.md:204`（109.2）；`critical-rules-discipline.md:28`（escalation_threshold）、`:144`（41.5）、`:183`（44.3）、`:186`（44.5）、`:395`（69.3）、`:449`（72.1 A 级）、`:653`（97.5）；`critical-rules-dispatch.md:53`（retry_limit）、`:225`（96.7）；`SKILL.md:119/123-124/346`。 — plan-brief.md §B11 FR-3
- 旧措辞全仓字面面 9 处（grep 实测）：见 B7 第 2 行。 — plan-brief.md §B11 FR-4
- `TASK_PLANNER_GOAL_MODE` 全仓无写入方（`resolve-interaction-mode.sh:52-58` 的 goal 分支运行时不可达）；goal 语境实际靠模型读语境判定，示例会话判定正确——识别不是病因。 — plan-brief.md §B11 FR-5
- 28.8 无任何 selftest 文本锚（脚本面 grep「28.8 / 单次降级收口 / goal 自治 / 强制自治」仅 1 条注释命中）。 — plan-brief.md §B11 FR-6
- decision-arbiter：源 frontmatter `GLM-5.3 + thoughtLevel: enabled`；宿主 ListModels 显示 individual 计划下仅 `GLM-5.4`、`GLM-5.3-Flash`，GLM 系列档位 `low/high/max`；运行位 11-23 已为 `GLM-5.4 + max`。示例会话内两次派发失败：首轮（消息 `msg_mwsqaxy2_bc16e046-c10d-4221-951a-448c21068874`「裁决体因环境配置失败（Reasoning level unsupported，非限流）」）与第十轮（消息 `msg_mwssig10_3…`「decision-arbiter 因 reasoning level 不支持而失败」）；留痕 `plans/task-resource-utilization-20261123/.agent-failures/df5b8b4a85364c7e87acfd85024635eb.jsonl`。 — plan-brief.md §B11 FR-7
- `~/.zcode/commands/goal.md`（2026-08-26，143 行，引用 `~/.claude/skills/...`）通篇「等待确认/AskUserQuestion/升级用户/用户确认接受」；官方命令指南（zcode-guide `diagnosing-commands`）载明与内置命令撞名的本地命令在交互面被过滤——判为潜伏隐患、非本次主因。 — plan-brief.md §B11 FR-8
- 运行位现状（部署前实测，`pre-deploy-site-state.log`）：5 位 × 6 文件全部存在、均为普通文件；`~/.zcode` 6/6 与源一致；其余位存在既有差异（agents SKILL.md 5 行；claude discipline 4 行 + SKILL.md 5 行；opencode 5 个文件 1-10 行；cursor discipline 4 行 + SKILL.md 10 行）——均为其他任务的历史欠账，部署必须原样保留。 — plan-brief.md §B11 FR-9

## Technical Decisions
| Decision | Rationale |
|---|---|
| D-1 goal 模式部署 = 预授权+护栏（用户裁决 2026-11-24，#2 裁决一）。 | goal 模式部署 = 预授权+护栏（用户裁决 2026-11-24，#2 裁决一）。 |
| D-2 本次修复部署 = 全部运行位（#2 裁决二）。 | 本次修复部署 = 全部运行位（#2 裁决二）。 |
| D-3 decision-arbiter 源配置 = GLM-5.4 + max（#2 裁决三）。 | decision-arbiter 源配置 = GLM-5.4 + max（#2 裁决三）。 |
| D-4 零新脚本 / 零新门 / 零 hook / 零新 selftest（文本优先铁律 + 用户批准计划）。 | 零新脚本 / 零新门 / 零 hook / 零新 selftest（文本优先铁律 + 用户批准计划）。 |
| D-5 部署方式 = 逐位 diff 判向 + 精确增量；禁 `smart-merge-back --deploy` / `install.sh` 整槽覆盖（二者为整槽替换，会抹掉 claude/opencode/cursor 位自有增量；verify 基线已显示三位 SKILL.md 与源不一致）。 | 部署方式 = 逐位 diff 判向 + 精确增量；禁 `smart-merge-back --deploy` / `install.sh` 整槽覆盖（二者为整槽替换，会抹掉 claude/opencode/cursor 位自有增量；verify 基线已显示三位 SKILL.md 与源不一致）。 |
| D-6 D1 = yes：用户于计划模式显式批准计划（user-session-log #3），执行中不二次确认。 | D1 = yes：用户于计划模式显式批准计划（user-session-log #3），执行中不二次确认。 |
| D-7 不改 `~/.zcode/commands/goal.md`；不执行示例会话遗留的待授权项。 | 不改 `~/.zcode/commands/goal.md`；不执行示例会话遗留的待授权项。 |
| D-8（计划审计 R1 裁定，2026-11-24）C-1/I-1..I-6/W-1..W-6,W-8/Q-1,Q-2 全部采纳并在 edit-spec/plan-brief 修正；W-7（planctl render 硬编码 V-N 复选框为已勾）登记为已知局限——属既有渲染行为、不在本任务范围，依文本优先铁律不改渲染器，交付时如实披露。 | R1 裁定，2026-11-24）C-1/I-1..I-6/W-1..W-6,W-8/Q-1,Q-2 全部采纳并在 edit-spec/plan-brief 修正；W-7（planctl render 硬编码 V-N 复选框为已勾）登记为已知局限——属既有渲染行为、不在本任务范围，依文本优先铁律不改渲染器，交付时如实披露。 |
| D-9（计划审计 R1 I-2 裁定）28.9② 的源码修改预授权收窄为「/goal 指令明示为任务对象的源码修改」；指令未明示的 skills/** 技能源码、agent 定义、指令文件修改仍属预算外。用户裁决（#2）只覆盖部署，不扩大。 | R1 I-2 裁定）28.9② 的源码修改预授权收窄为「/goal 指令明示为任务对象的源码修改」；指令未明示的 skills/** 技能源码、agent 定义、指令文件修改仍属预算外。用户裁决（#2）只覆盖部署，不扩大。 |
| D-10（计划审计 R2 裁定，I-7）28.9 的预算外集合只拦 D6 类（含 72.1 A② 不可逆破坏、A③ 对外发布）；72.1 A①/A④（计划要素取舍、语义级目标分叉）在 goal 语境保持既有自治（28.8①、41.2 G4 silent、44.3 D2/D5 推荐项），不因 A 级名义转为预算外；⑦ 泛化授权只对 D6 类项要求逐项显式确认。 | R1 修正时把整个 A 级划为永不自动属矫枉过正，与 41.2/44.3/28.8① 冲突（审计 R2 I-7）；按审计建议拆分 A 级子集。 |
| D-11（计划审计 R3 W-10，已采纳）28.9② 中 72.1 A① 涉及范围者以 28.8④ 登记的交付单元上界为限：上界内的计划要素取舍属预算内，超上界的范围扩张属预算外。 | A① 含「范围」，需与「超 28.8④ 上界=预算外」对齐；R3 裁定 APPROVED 后立即修正，P3 条款审查复核。 |
| D1 目标绑定确认锚（2026-11-24T02:19:06+08:00）：本计划 Goal =「修复 Skill 家族在 goal 模式下不能自主确认推进、无效多次循环的缺陷（Rule 28.9 + 载体级联），合并并部署到全部运行位」；服务用户指令 = user-session-log #1 原话「当前  skill子啊  goal 模式下导致不能自主确认推进 ,导致无效多次循环是严重的缺陷  没有达到自主角色目标  sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb 会话就是示例 必须对skill缺陷进行解决」；确认方式 = 用户于计划模式显式批准计划（user-session-log #3）；计划审计 R1→R3 迭代后 APPROVED（0C/0I）。 | 用户批准计划即 D1=yes；确认锚形成后方可 attest 与清哨兵。 |
| D-12（执行偏差认可）E20 的例外条款落在反作弊第 9 条禁止句末尾（「私自改判据推进=交付作废）；例外…」），而非规格所指的「判据冻结协议」句之后。 | 新增文字与规格逐字相同、位于同一条款内、紧随其所例外的禁令；执行体已在回执披露。主进程盘上核验确认仅此一处落点差异，其余 E17-E19 逐条一致；P3 独立审查全量回读 diff 复核。 |
| D-13（回归发现，授权内级联）selftest-decision-arbiter.sh 的 DA-02 断言由钉 GLM-5.3 改为钉 GLM-5.4，断言强度不变（仍为逐字锚）；Rule 69（discipline 393/396/399）与 agent-coverage.md 第 40 行的旧配置字面同步。complex-planner 的同类配置（GLM-5.3 + enabled）不在授权范围，不改，交付时报告。 | 用户裁决三（#2）要求 decision-arbiter 对齐 GLM-5.4 + max；Rule 74 替代条件④要求改后 selftest 全绿；引用面与断言面必须随 truth source 锁步，否则后续会话可能把配置改回。 |
| D-14（不绕过委派门）三次子代理派发停摆后，主进程不直接编辑隔离区 skills/ 文件：委派门（check-delegation.sh）只认 plans/ 白名单、mini/L0-E 直做通道或用户本人在终端运行的 allow-direct.sh，设计上禁止模型自助绕过。处置=更换执行体类型继续派发。 | 用 sed 经 Bash 改 skills/ 文件可避开 Edit 钩子，但属于绕过体系（用户明令反对）；25.3 白名单⑤的「兜底接管」在机器面没有对应放行通道。 |
| D-15（规格修订 E29）agent-coverage.md 第 40 行新文案由「decision-arbiter(D1, GLM-5.4 强档 max)」收回为「decision-arbiter(D1, GLM-5.4 强档)」。 | 全量回归 selftest-agent-coverage AC-04 FAIL：该断言从矩阵「专用体」列提取小写英文 token 当 agent 名去 test -f，新增的 max 被判为缺位实体。矩阵该列是机器解析面，只能放实体名；max 档信息以 decision-arbiter.md frontmatter 与 Rule 69.5 为准（已写全）。另一选项=把 max 加进 selftest 豁免名单，属放宽守卫，不取。 |
| D-16（部署范围修订）deploy-runbook 的部署文件由 6 个修订为 8 个，新增 skills/task-dispatch/references/agent-coverage.md 与 skills/task-planner/scripts/selftest-decision-arbiter.sh。 | 二者是 decision-arbiter 配置对齐的随动引用面与断言面（D-13、D-15），属 skills/ 内容，落在用户裁决①的 goal 模式部署预授权内；不同步则运行位与源码矛盾。预检：两文件在 5 个运行位相对基线差异均为 0。agent 定义副本不在预授权内（裁决①明示 agent 定义的 model/frontmatter 不在此列）：仅 ~/.zcode/agents/decision-arbiter.md 为 GLM-5.4+max，claude/agents/opencode/cursor 四位仍为 GLM-5.3+enabled，不改，交付时报告待裁决。 |
| D-17（采纳执行期复审第二轮五处修订）新增规格 E31-E35：template-mapping.md 第 305 行与 critical-rules-dispatch.md 第 245 行的 decision-arbiter 配置字面同步为 GLM-5.4；decision-arbiter.md 第 14 行旧注释与 selftest 第 41 行注释改为如实表述；verification-gate SKILL.md 的 PARTIAL 判据补「且残余风险清单已登记」与 84.5 对齐。复审其余条目（W-2/W-3/Q-1/Q-2/N-2 与 DA-02 整文件 grep）维持提醒级不改。 | 前两处证明规格第 173 行的豁免归类有误（非 complex-planner 引用而是 arbiter 专属，且 103.4 紧邻「派发 model 参数显式指定」，照字面执行会重现已修复的派发失败）；后三处是本任务自身造成的不一致。均为引用面/注释/口径对齐，不改机器门、不新增断言（thoughtLevel 是否补断言留待用户裁决）。 |
| D-18（部署预演 FAIL 项处置）opencode 位的 critical-rules-dispatch.md 不用原补丁，改用主进程生成的专用补丁 site-opencode_critical-rules-dispatch.md.patch（只做本次三处片语替换，保留该位既有内容）。 | 该位文件是比基线更旧的版本（缺 11-19/11-20 的数段修订，别的任务未部署过去），22.3 行有既有差异致原补丁第 1 块上下文不匹配；另两块可过。证据：三处替换式作用于基线可逐字重现当前源码（diff 为空）；该位文件中三处旧串各出现 1 次；专用补丁预演 rc=0 且运行位文件未变。符合已批准计划步骤 7「位有自有内容→该位就地锚定增量」。 |
| D-19（部署校验口径修订）硬校验改为整行相等匹配：补丁的每个 + 行必须在运行位文件中整行存在、每个 - 行必须整行不存在（grep -x -F）；改前差异为 0 的位追加与当前源码逐字节比对。续做范围=仅对 ZCode 位 SKILL.md 补打补丁，其余 44 项不重复写入。 | 原口径（28.9 整行=1）只对 discipline 成立，对另 5 个载体恒为 0，属主进程规格错误；执行体按 B4 停止并恢复是正确行为。修订口径经自检：对当前源码 9 文件均 0 0，对基线版本可判出 6 6 / 1 1。44 项已达标不重复写入，符合写入最小化。 |
| D-20（演练降级）VC-8 的新会话行为演练未能进行：全新会话以 build 权限模式运行，第 3 个工具调用（第 2 条 shell 命令）的权限请求等待审批（needs_attention/approval），无人可批。按已批准计划的预案退回同会话模拟演练，四判据由主进程按 28.9 扮演执行者自评并全部 PASS（仅同会话模拟中）；证据骨架与报告醒目标注降级事实与未覆盖面。 | 会话权限模式由宿主设置决定，创建会话的接口无法指定；审批权在用户，不代批、不绕。演练会话已中断并归档，其哨兵与演练目录已清理。真实效果以用户下一次真实 /goal 运行为准。 |
| D-21（演练验收项改判未通过）VC-8 由 pass 改为 fail。收尾前偏移检查（subagent-state/32-drift-checker.md）判 DRIFT：VC-8 判据主语为「新会话行为演练」，实际做的是同会话模拟演练，标 pass 名实不符。处置：VC-8=fail；drill-report.md 四行结论改为 FAIL；同会话模拟演练降为补充证据；P6 不翻 complete；计划暂不归档，待用户以自动放行的权限模式开新会话（或手动审批）补做演练。 | 新会话以 build 权限模式运行，任何写入前都需审批，无人值守时演练无法进行；宿主权限审批不在 skill 条款控制范围。已批准计划的回退演练只能作补充证据，不能替代判据主语。改判为 fail 比带限定的 pass 更不易误导。 |
| D-22（用户新授权 2026-11-24）所有仍使用 GLM-5.3 的活跃配置全量更新为 GLM-5.4（5.3 已弃用），agent 定义 model/frontmatter 修改在此明确授权内（覆盖裁决一对 agent 定义的排除项）；thoughtLevel 断言不钉死 max，改为校验合法档位集合并拒绝 enabled 等无效值；历史判例/审计记录里的 5.3 引用保留不改（证据链）。 | 用户原话：所有涉及5.3的都可以更新为5.4，因为5.3已经被弃用了；这个级别不光可以设Max还有其他选项，只写Max是有问题的。 |
| D-23（D-22 执行结果，2026-11-24）活跃 5.3 全量刷新完成：源码 commit 1e07d949（fresh selftest 106 PASS/0 FAIL，DA-02b 合法档断言新增）；5 位 34 文件部署（skills 副本 25 + agents 定义 9，备份 34）；主进程独立复验源仓+5 位活跃 frontmatter 5.3=0、GLM agent thoughtLevel=max 10/10、ccr enabled 未动。verify 22 pass/4 fail（基线 23/3）：新增 zcode SKILL.md 漂移由他会话 commit c0490005 更新 canonical SKILL.md 所致，不在本次授权清单，未越权同步。用户澄清 opencode 与当前项目无关，从待裁决清单移除；历史判例/审计记录里的 5.3 引用保留不改。 | D-22 用户授权「所有涉及5.3的都可以更新为5.4，因为5.3已经被弃用了」「级别不光可以设Max还有其他选项」；子代理检查点 40/41 + 主进程盘上复验（git log/grep/verify 实跑）三证据齐备。 |

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
