<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-goal-unattended-protocol-20261124

- task_id: `task-goal-unattended-protocol-20261124`
- 时间: created_at=2026-11-23T16:44:25Z / updated_at=2026-11-23T22:37:41Z
template_type: rule-enhancement
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 用户原话（user-session-log #1 逐字）：「当前  skill子啊  goal 模式下导致不能自主确认推进 ,导致无效多次循环是严重的缺陷  没有达到自主角色目标  sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb 会话就是示例 必须对skill缺陷进行解决」
- **R2（手段）** user-session-log #2 裁决一：goal 模式部署预授权+护栏
- **R3（手段）** user-session-log #2 裁决二：本次部署到全部运行位
- **R4（手段）** user-session-log #2 裁决三：decision-arbiter 对齐 GLM-5.4 + max

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 用户原话（user-session-log #1 逐字）：「当前  skill子啊  goal 模式下导致不能自主确认推进 ,导致无效多次循环是严重的缺陷  没有达到自主角色目标  sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb 会话就是示例 必须对skill缺陷进行解决」 | VC-1, VC-2, VC-3, VC-8 | plan-brief §B3, 原类型=结果 |
| R2 | 手段 | user-session-log #2 裁决一：goal 模式部署预授权+护栏 | VC-2, VC-7 | plan-brief §B3, 原类型=手段 |
| R3 | 手段 | user-session-log #2 裁决二：本次部署到全部运行位 | VC-4, VC-5 | plan-brief §B3, 原类型=手段 |
| R4 | 手段 | user-session-log #2 裁决三：decision-arbiter 对齐 GLM-5.4 + max | VC-6, VC-9 | plan-brief §B3, 原类型=手段 |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | 修复 Skill 家族在 goal 模式下不能自主确认推进、无效多次循环的缺陷（Rule 28.9 + 载体级联）。 |  |  |
| G2 | 修复在全部运行位生效（合并 + 部署 5 位）。 |  |  |
| G3 | 独立裁决体 decision-arbiter 在当前宿主可派发（源配置对齐见 VC-6；派发冒烟见 VC-9）。 |  |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | G1 | 修复 Skill 家族在 goal 模式下不能自主确认推进、无效多次循环的缺陷（Rule 28.9 + 载体级联）。 | 见 ✅ Verification Contract 对应 VC | - | pending |
| G2 | G2 | 修复在全部运行位生效（合并 + 部署 5 位）。 | 见 ✅ Verification Contract 对应 VC | - | pending |
| G3 | G3 | 独立裁决体 decision-arbiter 在当前宿主可派发（源配置对齐见 VC-6；派发冒烟见 VC-9）。 | 见 ✅ Verification Contract 对应 VC | - | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete | S1, S2 |  | 计划建立与独立审计 | 2026-11-23T18:04:59Z | plan-brief §B5 |
| P2 | complete | S3, S4, S5, S6, S7, S8, S9, S18, S19 |  |  | 2026-11-23T20:00:34Z |  |
| P3 | complete | S10, S11, S20, S21, S22, S23 | VC-1, VC-2, VC-3 | 验证与独立审查 | 2026-11-23T20:04:07Z | plan-brief §B5 |
| P4 | complete | S12 | VC-4 | 合并 | 2026-11-23T20:32:57Z | plan-brief §B5 |
| P5 | complete | S13, S14 | VC-5 | 部署 5 位 | 2026-11-23T20:34:52Z | plan-brief §B5 |
| P6 | in_progress | S15, S16, S17 | VC-8, VC-9 | 冒烟与收尾 | 2026-11-23T21:00:27Z | plan-brief §B5 |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1, VC-2, VC-3, VC-8 |
| R2 | VC-2, VC-7 |
| R3 | VC-4, VC-5 |
| R4 | VC-6, VC-9 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 续推指令消费 | 无「收到续推怎么办」条款，每轮续推被当成新工作（前 10 轮空转） | 28.9③ 续推识别 + ④ 首次差异归因 + ⑤ 固定点应答 | VC-1,VC-2,VC-8 |
| 升级路径出口 | 所有升级终点都是问用户，硬门为开放集合，无法自主确认 | 28.9② 授权预算矩阵取代开放硬门 + ⑥ 决策冻结 + ⑦ 授权到达即执行 | VC-2,VC-6,VC-7 |
| 决策仲裁 | 无决策冻结/翻转预算，部署决策翻转 3 次 | 28.9⑥ 翻转上限 1 次 + D-1..D-7 冻结 | VC-2,VC-7 |
| 终验判据 | 「确保」类目标词无合法出口；PARTIAL 要求 VC 全 PASS，改判据被反作弊禁 | 84.5 语义保证型判据拆分（计划期登记拆分项） | VC-1,VC-3 |
| 授权消息处置 | 无「授权到达→命中待授权清单→立即执行预案」规则，用户授权被丢弃 | 28.9⑦ 授权到达即执行 + ⑧ 终点覆盖 | VC-2,VC-8 |
| 独立裁决体 | decision-arbiter 源 GLM-5.3 + enabled 在当前宿主不可用，拖到第 10 轮 | 源配置对齐 GLM-5.4 + max（运行位不动）+ 冒烟派发 | VC-6 |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 条款锚在位且旧措辞清零。 判据：6 个载体文件逐一打印的「28.9」计数均 ≥1；`old-wording-in-SKILL=0`。（改前：6 个计数全为 0、old=2——具判别性） | cd /mnt/data/dev/task-planner-skill && for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do echo "$(grep -c '28\.9' "$f") $f"; done; echo "old-wording-in-SKILL=$(grep -c '仅单次降级收口停止' skills/task-planner/SKILL.md)" |  |
| VC-2 | Rule 28.9 本体在位：条款行 =1，八个子条标记 ①-⑧ 齐全，且含部署护栏原文。 判据：第一数 =1；第二数 =8；第三数 ≥3。 | cd /mnt/data/dev/task-planner-skill && F=skills/task-discipline/references/critical-rules-discipline.md; grep -c '^28\.9 ' $F; sed -n '/^28\.9 /p' $F \| grep -o '[①②③④⑤⑥⑦⑧]' \| sort -u \| wc -l; sed -n '/^28\.9 /p' $F \| grep -o -E '逐位 diff 判向\|禁整文件覆盖\|部署前备份\|verify 对账' \| wc -l |  |
| VC-3 | 语法与 selftest 回归不破基线（selftest 基线 = `baseline-selftest.log`：104 PASS / 0 FAIL）。 判据：输出 `SYNTAX_OK`；fresh selftest 汇总行 FAIL 数 =0 且 PASS 数 =104（与基线相同）。 | cd /mnt/data/dev/task-planner-skill && bash -n skills/task-planner/scripts/*.sh && echo SYNTAX_OK; bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -4 |  |
| VC-4 | 合并进 master 且隔离区已清理。 判据：第一数 ≥1；第二数 =0；第三数 =0。 | cd /mnt/data/dev/task-planner-skill && git log --oneline -6 \| grep -c 'task-goal-unattended-protocol-20261124'; git worktree list \| grep -c 'task-goal-unattended-protocol-20261124'; git branch --list 'wt/task-goal-unattended-protocol-20261124' \| wc -l |  |
| VC-5 | 5 个运行位逐文件新锚在位（30 个位文件计数均 ≥1、无 MISSING），且部署对账不差于基线（`verify.sh` 基线 23 pass / 3 fail）。 判据：输出 `site-files-bad=0`；summary 行 pass ≥23 且 fail ≤3。 | cd /mnt/data/dev/task-planner-skill && for s in /home/terry/.zcode /home/terry/.agents /home/terry/.claude /home/terry/.config/opencode /home/terry/.cursor; do for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do t="$s/$f"; if [ -f "$t" ]; then grep -c '28\.9' "$t"; else echo MISSING; fi; done; done \| awk '{ if ($1=="MISSING" \|\| $1+0<1) bad++ } END { print "site-files-bad=" bad+0 }'; TASK_PLANNER_ROOT=/mnt/data/dev/task-planner-skill/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 \| grep summary |  |
| VC-6 | decision-arbiter 源配置对齐。 判据：=2（model 行与 thoughtLevel 行各 1）。 | cd /mnt/data/dev/task-planner-skill && sed -n '1,12p' skills/task-planner/companion/agents/decision-arbiter.md \| grep -cE '^model: "account:zai-individual-coding-plan/GLM-5\.4"$\|^thoughtLevel: max$' |  |
| VC-7 | 项目 AGENTS.md 含 goal 部署预授权例外。 判据：≥1（改前 =0）。 | grep -c 'goal 模式部署预授权' /mnt/data/dev/task-planner-skill/AGENTS.md |  |
| VC-8 | 新会话行为演练四判据全 PASS（D1 零等待式提问；D2 首轮即产出预算内成果并登记待授权清单与判据上限；D3 其后 3 轮模拟续推每轮 ≤10 行、无工具调用步骤、决策不翻转；D4「授权」当轮即执行待授权预案并验证）。 判据：第一数 =4；第二行 `skeleton-ok`。报告行严格按模板「- D<n> 判据 <名称>：PASS\|FAIL」每条一行；原始证据骨架 `drill-skeleton.txt`（主进程从演练会话记录抽取的逐消息骨架）非空，D1-D4 由主进程对照骨架判定并在报告中引用骨架行号。 | grep -cE '^- (D[1-4]) 判据[^:]*：PASS' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-report.md; test -s /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-skeleton.txt && echo skeleton-ok |  |
| VC-9 | decision-arbiter 派发冒烟成功（S15）：裁决体在当前宿主正常返回并落 checkpoint。 判据：≥1（checkpoint 缺失时命令失败 = FAIL，具判别性）。 | grep -c '^status: done' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/12-decision-arbiter.md |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 计划建立与独立审计
- **Status:** complete
- **Started:** 2026-11-23T18:04:59Z
- **Executor:** plan-writer(sonnet-1)、critic(opus-1)
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1 | [P1] 计划文档编码（plan-state.json + 4 视图 + knowledge-brief.md）（计划文档编码（plan-state.json + 4 视图 + knowledge-brief.md）；按 plan-brief §A 执行步骤推进） | plan-writer(sonnet-1) | plans/task-goal-unattended-protocol-20261124/plan-brief.md §B（唯一内容源，逐字编码 12 段语义）；plan-state.json（权威源，经 planctl 写入） | planctl validate 通过；render 后 4 视图无模板占位残留；§B 各段清点一致 | 15min | 2f/80l/15min | 无 | - | pending |
| S2 | [P1] 计划独立审计（Rule 109）（计划独立审计（Rule 109）；按 plan-brief §A 执行步骤推进） | critic(opus-1) | plans/task-goal-unattended-protocol-20261124/task_plan.md（已批准计划逐字，Rule 109 审计面）；plan-brief.md §A/§B（审批与编码对照） | critic 出具 Rule 109 独立审计结论并落 findings.md | 10min | 2f/60l/10min | 无 | - | pending |

### Phase 2:
- **Status:** complete
- **Started:** 2026-11-23T20:00:34Z
- **Executor:** executor(haiku-1)、general-purpose
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S3 | [P2] discipline 条款（E1a-E7 + E2 插入）（按 edit-spec.md E1a-E7 与 E2 插入修改 discipline） | executor(haiku-1) | skills/task-discipline/references/critical-rules-discipline.md（28.9 插入点+措辞/指针锚） | E2 八子条在位、①-⑧=8；旧措辞归零 | 15min | 1f/2l/15min | 无 | - | pending |
| S4 | [P2] SKILL.md 措辞/指针（E8-E13）（按 edit-spec.md E8-E13 修改 SKILL.md） | executor(haiku-1) | skills/task-planner/SKILL.md（旧措辞 132/133/136/268 + 指针 123-124/346） | 旧措辞计数=0；净增 ≤8 行 | 15min | 1f/0l/15min | 无 | - | pending |
| S5 | [P2] critical-rules.md 索引与指针（E14-E16）（按 edit-spec.md E14-E16 修改 critical-rules.md） | executor(haiku-1) | skills/task-planner/references/critical-rules.md（:10 索引 + 66.2 + 109.2） | 索引行与 66.2/109.2 goal 指针在位 | 10min | 1f/0l/10min | 无 | - | pending |
| S6 | [P2] verification-gate 两文件（E17-E20）（按 edit-spec.md E17-E20 修改 verification-gate 两文件） | executor(haiku-1) | skills/verification-gate/references/critical-rules-verification.md + skills/verification-gate/SKILL.md | 84.5 判据拆分 + 反作弊第 9 条同步 | 15min | 2f/0l/15min | 无 | - | pending |
| S7 | [P2] dispatch 升级出口指针（E21-E22）（按 edit-spec.md E21-E22 修改 dispatch） | executor(haiku-1) | skills/task-dispatch/references/critical-rules-dispatch.md（:53 retry_limit、:225 96.7） | 两处 goal 指针在位 | 10min | 1f/0l/10min | 无 | - | pending |
| S8 | [P2] decision-arbiter 源配置（E23-E24）（按 edit-spec.md E23-E24 对齐源配置） | executor(haiku-1) | skills/task-planner/companion/agents/decision-arbiter.md（frontmatter model/thoughtLevel） | VC-6 model 与 thoughtLevel 两行命中 | 10min | 1f/3l/10min | 无 | - | pending |
| S9 | [P2] AGENTS.md §2 goal 部署例外（E25）（按 edit-spec.md E25 在主仓 AGENTS.md §2 增例外） | executor(haiku-1) | AGENTS.md（仓库根，未跟踪文件；§2 增 goal 部署预授权例外，主仓直接编辑） | VC-7 grep 计数≥1；git status 仅 AGENTS.md 变更 | 5min | 1f/1l/5min | 无 | - | pending |
| S18 | [P2] discipline 引用面锁步（E26-E28：Rule 69 三处旧配置字面）（按 edit-spec.md E26-E28 把 Rule 69 中 decision-arbiter 的 GLM-5.3/enabled 字面同步为 GLM-5.4/max） | general-purpose | skills/task-discipline/references/critical-rules-discipline.md | E26-E28 new 串各=1；Rule 69 段内旧配置字面=0 | 10min | 1f/0l/10min | 无 | - | pending |
| S19 | [P2] 断言面与覆盖表锁步（E29-E30：agent-coverage 第 40 行、selftest DA-02）（按 edit-spec.md E29-E30 同步覆盖表与 DA-02 断言到 GLM-5.4（断言强度不变，仍为逐字锚）） | general-purpose | skills/task-dispatch/references/agent-coverage.md；skills/task-planner/scripts/selftest-decision-arbiter.sh | bash skills/task-planner/scripts/selftest-decision-arbiter.sh 输出 16 PASS/0 FAIL | 10min | 2f/3l/10min | 无 | - | pending |

### Phase 3: 验证与独立审查
- **Status:** complete
- **Started:** 2026-11-23T20:04:07Z
- **Executor:** 主进程（白名单③ 机械验证命令）、critic(opus-1)、general-purpose
- [x] V-3.1: VC-1（Phase 3 验证契约映射）
- [x] V-3.2: VC-2（Phase 3 验证契约映射）
- [x] V-3.3: VC-3（Phase 3 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S10 | [P3] VC-1/VC-2/VC-3 机械验证（selftest 基线 = baseline-selftest.log 104/0）（VC-1/VC-2/VC-3 机械验证；按 plan-brief §A 执行步骤推进） | 主进程（白名单③ 机械验证命令） | plans/task-goal-unattended-protocol-20261124/baseline-selftest.log（selftest 基线 104 PASS / 0 FAIL）；VC-1/VC-2/VC-3 命令（plan-brief §B4 逐字） | VC-3 输出 SYNTAX_OK；fresh selftest PASS=104 且 FAIL=0（与 baseline-selftest.log 基线相同） | 15min | 2f/20l/15min | 无 | - | pending |
| S11 | [P3] 条款文本独立审查（子条互斥/自洽/冲突面）（条款文本独立审查（子条互斥/自洽/与既有规则冲突面）；按 plan-brief §A 执行步骤推进） | critic(opus-1) | skills/task-discipline/references/critical-rules-discipline.md + 另 5 个载体文件（plan-brief §A 方案 B 表）；plan-brief §B7 变更标注表（替代四条件） | critic 审查报告无未解决条款冲突；冲突已就地修正并回读 | 15min | 2f/0l/15min | 无 | - | pending |
| S20 | [P3] E29 修订落地（agent-coverage 第 40 行收回为 GLM-5.4 强档）（按 edit-spec.md E29 修订把第 40 行的 GLM-5.4 强档 max 收回为 GLM-5.4 强档） | general-purpose | skills/task-dispatch/references/agent-coverage.md | selftest-agent-coverage 输出 9 PASS/0 FAIL；全量 --fresh 104 PASS/0 FAIL | 5min | 1f/1l/5min | 无 | - | pending |
| S21 | [P3] dispatch 引用面同步（E31-E32：template-mapping 第 305 行、critical-rules-dispatch 第 245 行）（按 edit-spec.md E31-E32 把 decision-arbiter 的 GLM-5.3 字面同步为 GLM-5.4） | general-purpose | skills/plan-template-kit/references/template-mapping.md；skills/task-dispatch/references/critical-rules-dispatch.md | E31/E32 new 串各=1、old 串各=0；同行档位泛称未动 | 5min | 2f/2l/5min | 无 | - | pending |
| S22 | [P3] agent 定义旧注释与断言注释改如实（E33-E34）（按 edit-spec.md E33-E34 改两处注释，frontmatter 与断言不动） | general-purpose | skills/task-planner/companion/agents/decision-arbiter.md；skills/task-planner/scripts/selftest-decision-arbiter.sh | E33/E34 new 串各=1、old 串各=0；selftest-decision-arbiter 16 PASS/0 FAIL；脚本行数 111 不变 | 5min | 2f/2l/5min | 无 | - | pending |
| S23 | [P3] PARTIAL 判据口径对齐（E35：verification-gate SKILL.md 第 68 行）（按 edit-spec.md E35 补「且残余风险清单已登记」） | general-purpose | skills/verification-gate/SKILL.md | E35 new 串=1、old 串=0 | 5min | 1f/1l/5min | 无 | - | pending |

### Phase 4: 合并
- **Status:** complete
- **Started:** 2026-11-23T20:32:57Z
- **Executor:** 主进程（①）
- [x] V-4.1: VC-4（Phase 4 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S12 | [P4] smart-merge-back + 清理 worktree/分支（smart-merge-back（不带 --deploy）+ 清理 worktree/分支；按 plan-brief §A 执行步骤推进） | 主进程（①） | tmp/worktrees/task-goal-unattended-protocol-20261124（分支 wt/…，基于 master 9e42c0b）；smart-merge-back.sh（不带 --deploy） | VC-4 git log 命中≥1、worktree 与分支计数均=0 | 10min | 2f/30l/10min | 无 | - | pending |

### Phase 5: 部署 5 位
- **Status:** complete
- **Started:** 2026-11-23T20:34:52Z
- **Executor:** general-ops(sonnet-1)、主进程（③）
- [x] V-5.1: VC-5（Phase 5 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S13 | [P5] 逐位 diff 判向 + 备份 + 精确增量同步（按 deploy-runbook.md 执行：阶段 A=逐位 diff 判向+备份+补丁预演（不写运行位），主进程复核后下发阶段 B=仅对预演 OK 项做逐文件 patch 增量并验证） | general-ops(sonnet-1) | ~/.zcode、~/.agents、~/.claude、~/.config/opencode、~/.cursor 五个运行位同相对路径的 9 个 skills 文件（清单以 deploy-runbook.md 为准，D-16/D-17）；tmp/deploy-backups/task-goal-unattended-protocol-20261124/（备份） | VC-5 存在位逐文件 28.9 计数≥1；缺失位如实列 MISSING；备份目录有对应文件 | 15min | 2f/30l/15min | 无 | - | pending |
| S14 | [P5] verify.sh 对比部署对账基线（baseline-verify.log 23/3）（verify.sh 对比基线；按 plan-brief §A 执行步骤推进） | 主进程（③） | plans/task-goal-unattended-protocol-20261124/baseline-verify.log（部署对账基线 23 pass / 3 fail）；lib/verify.sh 实跑输出 | verify.sh summary 行 pass ≥23 且 fail ≤3（不差于部署对账基线 baseline-verify.log 23/3） | 5min | 2f/20l/5min | 无 | - | pending |

### Phase 6: 冒烟与收尾
- **Status:** in_progress
- **Started:** 2026-11-23T21:00:27Z
- **Executor:** decision-arbiter(GLM-5.4)、主进程（② 计划文件维护 / ③ 只读回读）、主进程（②）
- [x] V-6.1: VC-8（Phase 6 验证契约映射）
- [x] V-6.2: VC-9（Phase 6 验证契约映射）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S15 | [P6] decision-arbiter 派发冒烟（checkpoint：subagent-state/12-decision-arbiter.md）（decision-arbiter 派发冒烟；按 plan-brief §A 执行步骤推进） | decision-arbiter(GLM-5.4) | skills/task-planner/companion/agents/decision-arbiter.md（源 GLM-5.4 + max）；subagent-state/12-decision-arbiter.md（checkpoint；VC-9 命令锚） | VC-9：grep -c "^status: done" plans/task-goal-unattended-protocol-20261124/subagent-state/12-decision-arbiter.md ≥1（checkpoint 缺失=FAIL） | 5min | 2f/20l/5min | 无 | - | pending |
| S16 | [P6] 新会话 goal 行为演练 + drill-report.md + drill-skeleton.txt（新会话 goal 行为演练 + drill-report.md；按 plan-brief §A 执行步骤推进） | 主进程（② 计划文件维护 / ③ 只读回读） | plan-brief.md §A 步骤 8（模拟续推 3 轮 + 授权到达）；plans/task-goal-unattended-protocol-20261124/drill-report.md + drill-skeleton.txt（新建，D1-D4 逐消息骨架与判据行） | VC-8：drill-report.md 中 D1-D4「- D<n> 判据 <名称>：PASS」行计数=4，且 drill-skeleton.txt 非空输出 skeleton-ok；报告引用骨架行号 | 15min | 2f/60l/15min | 无 | - | pending |
| S17 | [P6] 记忆 / 台账 / 归档 / 清哨兵（记忆 / 台账 / 归档 / 清哨兵；按 plan-brief §A 执行步骤推进） | 主进程（②） | plans/task-goal-unattended-protocol-20261124/progress.md（仅追加）；项目级 ledger 与记忆目录（一事一文件）；计划归档 | 记忆条目×1、台账更新、计划归档、哨兵清理均有落盘证据 | 10min | 2f/60l/10min | 无 | - | pending |

## 🧮 根源覆盖表
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| 续推指令消费 | 无「收到续推怎么办」条款，每轮续推被当成新工作（前 10 轮空转） | 28.9③ 续推识别 + ④ 首次差异归因 + ⑤ 固定点应答 | VC-1,VC-2,VC-8 |
| 升级路径出口 | 所有升级终点都是问用户，硬门为开放集合，无法自主确认 | 28.9② 授权预算矩阵取代开放硬门 + ⑥ 决策冻结 + ⑦ 授权到达即执行 | VC-2,VC-6,VC-7 |
| 决策仲裁 | 无决策冻结/翻转预算，部署决策翻转 3 次 | 28.9⑥ 翻转上限 1 次 + D-1..D-7 冻结 | VC-2,VC-7 |
| 终验判据 | 「确保」类目标词无合法出口；PARTIAL 要求 VC 全 PASS，改判据被反作弊禁 | 84.5 语义保证型判据拆分（计划期登记拆分项） | VC-1,VC-3 |
| 授权消息处置 | 无「授权到达→命中待授权清单→立即执行预案」规则，用户授权被丢弃 | 28.9⑦ 授权到达即执行 + ⑧ 终点覆盖 | VC-2,VC-8 |
| 独立裁决体 | decision-arbiter 源 GLM-5.3 + enabled 在当前宿主不可用，拖到第 10 轮 | 源配置对齐 GLM-5.4 + max（运行位不动）+ 冒烟派发 | VC-6 |

## 📦 进度产出基线
| 基线项 | 动工前快照 | 关键产出/指标 | 禁倒退清单 | 状态 |
|---|---|---|---|---|
| Rule 28.9 八子条（discipline）×1 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | Rule 28.9 八子条（discipline）×1 | 禁倒退：Rule 28.9 八子条（discipline）×1 | pending |
| 载体措辞/指针：SKILL.md（132/133/136/268 措辞 + 123-124/346 指针）、discipline（28.8②③ + :28/:55/:183/:186/:395 指针）、critical-rules.md（:10 索引行 + 66.2 + 109.2）、verification-gate（84.3⑤/84.5 + SKILL.md 终验/反作弊第 9 条）、dispatch（retry_limit + 96.7） | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | 载体措辞/指针：SKILL.md（132/133/136/268 措辞 + 123-124/346 指针）、discipline（28.8②③ + :28/:55/:183/:186/:395 指针）、critical-rules.md（:10 索引行 + 66.2 + 109.2）、verification-gate（84.3⑤/84.5 + SKILL.md 终验/反作弊第 9 条）、dispatch（retry_limit + 96.7） | 禁倒退：载体措辞/指针：SKILL.md（132/133/136/268 措辞 + 123-124/346 指针）、discipline（28.8②③ + :28/:55/:183/:186/:395 指针）、critical-rules.md（:10 索引行 + 66.2 + 109.2）、verification-gate（84.3⑤/84.5 + SKILL.md 终验/反作弊第 9 条）、dispatch（retry_limit + 96.7） | pending |
| decision-arbiter 源 frontmatter 修正 ×1 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | decision-arbiter 源 frontmatter 修正 ×1 | 禁倒退：decision-arbiter 源 frontmatter 修正 ×1 | pending |
| AGENTS.md goal 部署例外 ×1 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | AGENTS.md goal 部署例外 ×1 | 禁倒退：AGENTS.md goal 部署例外 ×1 | pending |
| 5 位部署同步 + 备份 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | 5 位部署同步 + 备份 | 禁倒退：5 位部署同步 + 备份 | pending |
| 演练报告 drill-report.md ×1 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | 演练报告 drill-report.md ×1 | 禁倒退：演练报告 drill-report.md ×1 | pending |
| 记忆条目 ×1 | 动工前基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）；部署对账=baseline-verify.log（23 pass/3 fail，预存漂移 claude/opencode/cursor）；见 plan-brief §A 步骤 0 | 记忆条目 ×1 | 禁倒退：记忆条目 ×1 | pending |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|---|---|---|
| 源码/规则载体（P2-P3 写） | skills/task-discipline/references/critical-rules-discipline.md, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/verification-gate/references/critical-rules-verification.md, skills/verification-gate/SKILL.md, skills/task-dispatch/references/critical-rules-dispatch.md, skills/task-planner/companion/agents/decision-arbiter.md | 其他 skills/**, worktree, 主仓其他文件, ~/.zcode/skills 运行位（P2-P3 阶段） |
| 项目说明（P2 主仓直改） | AGENTS.md（仓库根，未跟踪；§2 goal 部署例外） | ~/.zcode/AGENTS.md, 其他项目文件 |
| 计划目录（全期） | plans/task-goal-unattended-protocol-20261124/** | user-session-log.md（只读需求锚）, delegations（H1-H7 勿改）, task_plan.md 逐字文本（状态由主进程翻转） |
| 部署位（仅 P5 写） | ~/.zcode/skills/同相对路径, ~/.agents/skills/同相对路径, ~/.claude/skills/同相对路径, ~/.config/opencode/skills/同相对路径, ~/.cursor/skills/同相对路径 | 整槽覆盖 install.sh / smart-merge-back --deploy, 缺该 skill 目录时新建安装, ~/.zcode/commands/goal.md |
| 备份与隔离区 | tmp/deploy-backups/task-goal-unattended-protocol-20261124/**, /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124 | 主分支直接写入实现类变更, 未授权 git 写操作（本 S1） |
| 对齐核查锁步（P2 写；回归 selftest 与引用面核查补出） | skills/task-dispatch/references/agent-coverage.md, skills/task-planner/scripts/selftest-decision-arbiter.sh |  |

## 📋 变更标注表
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据（证据） | 执行动作 |
|---|---|---|---|---|---|---|
| CH1 | Rule 28.9（discipline，新增一条） | 增量 | 仅 goal 语境生效；非 goal 语义不变 | — → 八子条全文（edit-spec.md E2） | 判例 sess_df5b8b4a + 用户批准计划（user-session-log #3） | 新增 |
| CH2 | 「仅单次降级收口停止 / 单次阻塞降级收口 / …并停止该目标迭代」类措辞（全仓字面面 9 处：SKILL.md:132/136/268、critical-rules.md:10/134、discipline:55/64/183/186）+ SKILL.md:133「不可越权硬门例外」 | **替代** | goal 语境硬门处置方式改变；非 goal 不变 | 停表等待 → 预算外硬门登记待授权清单后继续，续推按 28.9③-⑤ | 替代四条件：①既有内容被 sess_df5b8b4a 第一手记录证伪（停→续推→再停成环）且用户明示要求修复；②28.9②-⑦ 完整覆盖旧场景（硬门/不可自治项处置）；③已 Read 旧文全文；④改后 selftest 全绿 | 替代并保留 28.8 指针 |
| CH3 | 84.5 终验判定 + 反作弊第 9 条 | 增量 | 终验 PARTIAL 判定新增一类合法入口 | 增加「语义保证型判据拆分：计划期拆分不属中途改判据；拆分项全 PASS → PARTIAL」 | 同上 | 增量 |
| CH4 | decision-arbiter 源 frontmatter `model`/`thoughtLevel` | 替代 | 裁决体从「派发必败」变为可派发；运行位不动 | `GLM-5.3` + `enabled` → `GLM-5.4` + `max` | 用户裁决（user-session-log #2 裁决三）；ListModels 实测该宿主 individual 计划仅 GLM-5.4 / GLM-5.3-Flash，GLM 系列档位 low/high/max | 替代 |
| CH5 | 项目 AGENTS.md §2 | 增量 | 仅 /goal 语境的部署判定 | 新增「goal 模式部署预授权」一条 | 用户裁决（#2 裁决一） | 增量 |

## ⚠️ 核心问题定义
| 字段 | 值 |
|---|---|
| 核心问题 | goal 语境下「用户不在场」且「宿主会自动续推」时，skill 如何做到零提问、零停表、续推幂等、授权到达即执行？ |
| 核心问题判断 | 以 VC-1..VC-8 全 PASS 为准；非 goal 语境语义不变 |
| 裁决 | 已批准计划（user-session-log #3 D1=yes） |

## Current Phase
Phase 6

## 🔀 隔离决策
| 字段 | 值 |
|---|---|
| conflict_scan | risk（实现类、改运行行为的受管文件；AGENTS.md 未跟踪，经用户批准在主仓直接编辑） |
| isolation/worktree_path | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124 |
| branch | wt/task-goal-unattended-protocol-20261124 |
| merge_back | merged(d9f68655) |

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|---|---|---|---|---|---|---|
| P3 | 新措辞与既有条款（28.8/44.3/95/109）冲突 | 6 | 4 | 3 | 72 | critic 独立审查 + 回读互检；冲突就地修正 |
| P2 | SKILL.md 行数触 581 钉（selftest G-09） | 3 | 3 | 1 | 9 | 当前 469 行，预计净增 ≤8；触顶按「实值+25」调钉并登记 |
| P3 | 改措辞击破 selftest 文本锚 | 7 | 2 | 2 | 28 | 实测脚本面对旧措辞零锚（grep=0）；fresh 全量对比基线 |
| P5 | 整文件覆盖抹掉运行位自有增量 | 8 | 3 | 2 | 48 | 逐位 diff 判向；位≠旧源→就地锚定增量；先备份到 tmp/deploy-backups |
| P4 | 合并与他会话改动冲突 | 6 | 3 | 2 | 36 | smart-merge-back V3/V5/V6；目标文件当前无未提交改动 |
| P6 | 新会话演练卡在权限审批 | 4 | 3 | 1 | 12 | 退回本会话演练并在交付标注 |

## Decisions Made
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

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|---|---|---|---|
| 首次派发 Plan Writer 被 [dispatch-block] 串行槽占用拦截（锁 age=26s） | 1 | 等待锁过期后重发成功 | 禁止用守卫脚本做派发预检；只做字数与结构核对 |
| 派发 critic 被步骤枚举门拦截（6>4，Rule 21.1b） | 1 | 把六维审查维度的圈号编号改为并列表述后重发成功 | 派发稿只保留 Step1-Step4 一套步骤编号，其余列表不用圈号/第N步 |
| attest 拒锁：Phase 1/2 缺 S-unit 表或数据行（Rule 22.6） | 1 | S-unit 改整数编号 S1-S17，P2 拆为 S3-S9（每单元≤2 文件/≤100 行/≤15 分钟）后过门 | 计划期 S-unit 一律整数编号并按粒度上限拆分（拆单元而非放宽） |
| attest 拒锁：rvc-coverage 覆盖缺口（R2 引用不存在的 VC） | 1 | R2 的 vc 改为 VC-2、VC-7 后过门 | 映射列只写 VC 编号；注释放判据列 |
| audit-add 第 2 轮登记失败但输出被 `tail -1 >/dev/null` 静音，主进程未察觉（复核时发现 audits 仅有 R1） | 1 | 去掉静音重跑并显示报错；issues.state 改用合法枚举（fixed/accepted）后登记成功 | 写操作批处理必须检查 returncode；失败路径不得重定向到 /dev/null |
| 隔离区 fresh selftest：104 中 1 FAIL（selftest-decision-arbiter DA-02「model 非 GLM-5.3 强档」），基线为 104/0 | 1 | 断言与 Rule 69/覆盖表的旧配置字面随 frontmatter 锁步到 GLM-5.4（E26-E30，S18/S19），重跑 selftest 复验 | 改 frontmatter model/thoughtLevel 时，对齐核查必须把「模型字面」纳入字面面与断言面扫描 |
| S18 派发 executor(haiku-1) 两次挂起（各约 10 分钟、9 分钟无任何动作，隔离区工作树始终干净） | 2 | 两次均 TaskStop 终止并留痕 agent-failure ledger；按 Rule 22.3 升档改派 general-coder(sonnet-1) | 同型连续停摆 2 次即升档，不第三次原法重试 |
| 隔离区全量 selftest：104 中 103 PASS/1 FAIL（selftest-agent-coverage AC-04「候选 agent 缺位: max」；基线 104/0） | 1 | 修订规格 E29 并追加单元 S20 重改该行（D-15），重跑受影响 selftest 与全量回归 | 改矩阵登记列前先跑 selftest-agent-coverage；登记列只放实体名与版本号 |
| 部署阶段 B 中止：B2 硬校验在第 2 项判不符，执行体按 B4 停止并恢复 ~/.zcode 位 SKILL.md（45 项补丁已全部落位 rc=0） | 1 | 主进程修订硬校验口径为整行相等匹配（D-19），只读复核 44 项达标、1 项未部署；下发续做（仅补该 1 项并对 45 项重跑校验） | 校验口径下发前先在源码上自检（当前源码应全过）并做反向自检（基线版本应能判出）；子代理的 B4 停止机制保留 |
| 初版骨架与演练报告写「新会话首个工具调用即被拦截」，与事实不符：宿主日志显示新会话（build 权限模式）完成加载技能与一条 shell 命令后，在第 3 个工具调用的权限请求处等待 | 1 | 已查宿主日志（按会话 id 过滤 tool.call 与 tool.permission 事件）更正骨架与报告 | 行为演练的事实描述以宿主日志的工具调用与权限事件为准 |
| D-22 部署后 verify 从 23 pass/3 fail 变为 22 pass/4 fail：新增 zcode 位 SKILL.md 与 canonical 漂移，归因他会话 commit c0490005（05:48 更新 canonical SKILL.md，zcode 位停在 04:50），非本次 34 文件造成且 SKILL.md 不在授权清单。 | 1 | disclosed |  |

## 📊 委派统计
| 字段 | 值 |
|---|---|
| 总单元数 | 6 |
| 子代理执行数 | 5 |
| 最大并行宽度 | 1 |
| 复验通过数 | 0 |
