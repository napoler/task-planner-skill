# S9 checkpoint — worktree 内全量 selftest 跑批（code-runner-agent/mini）

- **任务**: task-v162-change-absorption-safety / Phase 6 / S9（全量 selftest 跑批 + FAIL 清单落盘）
- **执行体**: code-runner-agent(mini)
- **执行时间**: 2026-10-10（工作树内跑批）
- **worktree（操作区）**: /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety
- **跑批目录**: <wt>/skills/task-planner/scripts/
- **约束遵守**: 只读跑批（S9 未修复任何文件）；未触碰其他 worktree 内容
- **跑批命令**（逐脚本 120s 超时 + rc 落盘）:
  `cd <wt>/skills/task-planner/scripts && for f in selftest-*.sh; do timeout 120 bash "$f" > "/tmp/v162-$f.log" 2>&1; rc=$?; printf '%s rc=%s\n' "$f" "$rc" >> /tmp/v162-selftest-results.txt; done`

## 总览（机械计数，逐脚本 Total 行求和）

- **脚本总数**: 72（含新建 selftest-absorption-discipline.sh）
- **rc=0: 62 / rc=1: 10 / 超时(rc=124): 0**
- **ΣPASS = 1082，ΣFAIL = 12**（FAIL= 大写格式 11 条 + 小写 "N fail" 格式 1 条；两路求和交叉一致）
- 72/72 脚本 Total 行齐备（2 个异格式脚本已单独解析，见"负结果与甄别记录"）
- **新建 selftest-absorption-discipline.sh：rc=0，`Total: 14 pass, 0 fail`（AD-01..AD-14 全 PASS）**
- **结论：10 脚本 FAIL、共 12 条失败断言；FAIL 清单（原文逐字）见下节，供 S10 修复档消费。**

## 每脚本结果表（72 行；PASS/FAIL 判定 = rc=0 且 FAIL=0）

```
SCRIPT                                         rc   PASS   FAIL   RESULT
selftest-absorption-discipline.sh              0    14     0      PASS
selftest-active-plan.sh                        0    29     0      PASS
selftest-agent-coverage.sh                     0    9      0      PASS
selftest-ask-default-timeout.sh                0    11     0      PASS
selftest-batch-pilot.sh                        0    10     0      PASS
selftest-capability-persistence.sh             0    20     0      PASS
selftest-check-conflicts.sh                    0    7      0      PASS
selftest-check-drift.sh                        0    6      0      PASS
selftest-conclusion-discipline.sh              0    24     0      PASS
selftest-context-hygiene.sh                    0    12     0      PASS
selftest-context-pressure.sh                   1    8      1      FAIL
selftest-decision-arbiter.sh                   0    16     0      PASS
selftest-delegation.sh                         0    38     0      PASS
selftest-dispatch-grain.sh                     0    10     0      PASS
selftest-dispatch.sh                           0    31     0      PASS
selftest-drift-check-subagent.sh               1    19     1      FAIL
selftest-drift-enforcement.sh                  0    23     0      PASS
selftest-error-fix-prompt-forge.sh             0    8      0      PASS
selftest-error-loop.sh                         0    16     0      PASS
selftest-evidence-goal-gate.sh                 0    21     0      PASS
selftest-execution-honesty.sh                  1    13     1      FAIL
selftest-execution-stability.sh                0    19     0      PASS
selftest-fallback.sh                           0    31     0      PASS
selftest-final-gate-hash.sh                    0    22     0      PASS
selftest-fine-grain-steps.sh                   0    11     0      PASS
selftest-four-file-dataflow.sh                 0    18     0      PASS
selftest-goal-unit-goal-mode.sh                0    9      0      PASS
selftest-interaction.sh                        0    11     0      PASS
selftest-iteration-persistence.sh              0    18     0      PASS
selftest-iterative-optimizer.sh                0    8      0      PASS
selftest-knowledge-brief.sh                    0    16     0      PASS
selftest-lane-advancement.sh                   1    13     1      FAIL
selftest-mechanism-profile.sh                  0    19     0      PASS
selftest-media-agents.sh                       0    10     0      PASS
selftest-media-dispatch.sh                     0    9      0      PASS
selftest-methodology.sh                        0    16     0      PASS
selftest-parallel-scheduling.sh                0    9      0      PASS
selftest-periodic-review.sh                    0    10     0      PASS
selftest-plan-dispatch.sh                      0    12     0      PASS
selftest-plan-tier.sh                          0    32     0      PASS
selftest-pointer-lifecycle.sh                  0    10     0      PASS
selftest-reflect-verify.sh                     0    12     0      PASS
selftest-registry.sh                           0    5      0      PASS
selftest-reliability-institution.sh            0    16     0      PASS
selftest-report-reviewability.sh               0    13     0      PASS
selftest-requirement-coverage.sh               1    22     1      FAIL
selftest-requirement-grading.sh                0    7      0      PASS
selftest-rescue-chain.sh                       0    11     0      PASS
selftest-research-first.sh                     1    11     1      FAIL
selftest-review-library.sh                     0    15     0      PASS
selftest-root-resolution.sh                    1    15     2      FAIL
selftest-rule23-conflict-scan.sh               0    3      0      PASS
selftest-rule-reserve.sh                       0    10     0      PASS
selftest-self-resolution.sh                    1    11     2      FAIL
selftest-shared-tracker.sh                     0    11     0      PASS
selftest-skill-collab.sh                       0    25     0      PASS
selftest-skill-modify.sh                       0    9      0      PASS
selftest-skill-split.sh                        0    41     0      PASS
selftest-smart-merge.sh                        0    18     0      PASS
selftest-source-anchor-discipline.sh           1    11     1      FAIL
selftest-split-pattern-library.sh              0    13     0      PASS
selftest-subagent-granularity-skill-escort.sh  0    23     0      PASS
selftest-sync-index.sh                         0    13     0      PASS
selftest-task-boundary.sh                      0    11     0      PASS
selftest-template-lifecycle.sh                 0    24     0      PASS
selftest-template-sense.sh                     0    8      0      PASS
selftest-tier-b.sh                             0    18     0      PASS
selftest-tool-selection.sh                     1    11     1      FAIL
selftest-user-instruction-priority.sh          0    7      0      PASS
selftest-vc-gate.sh                            0    11     0      PASS
selftest-veto.sh                               0    13     0      PASS
selftest-workflow-orchestration.sh             0    16     0      PASS
```

## FAIL 清单（10 脚本 / 12 条失败断言，原文逐字）

> 下表 FAIL 断言行均来自各脚本日志原文（/tmp/v162-<script>.log）；行首 `N:` 为 grep 行号前缀，断言文本自身逐字未改。

### selftest-context-pressure.sh（rc=1）

- Total 行（原文）: `Total: 9 PASS=8 FAIL=1`
- 失败断言（原文逐字）:

```
7:CP-07 FAIL 1-(69|71)=1 CR=0 C48=2 C49=1 C50=1
```

- 完整日志（原文，10 行）:

```
CP-01 PASS 六子条锚=6
CP-02 PASS 主动评估=5≥2 ∧ 主动优化=3≥1
CP-03 PASS HEALTHY=3 PRESSURE=4 CONFUSED=4 hook=4≥1
CP-04 PASS 「不等 Phase complete」语义锚存在
CP-05 PASS 五段各=1 ∧ session-catchup=1 ∧ plan-resume=1 ∧ 62.1=1
CP-06 PASS bash -n OK ∧ env=3≥2 ∧ [context-pressure]=2 ∧ emit=12==12
CP-07 FAIL 1-(69|71)=1 CR=0 C48=2 C49=1 C50=1
CP-08 PASS registry 含 selftest-context-pressure ∧ 4 列
CP-09 PASS config properties=42=42
Total: 9 PASS=8 FAIL=1
```

### selftest-drift-check-subagent.sh（rc=1）

- Total 行（原文）: `Total: 20 PASS=19 FAIL=1`
- 失败断言（原文逐字）:

```
11:DCS-11 FAIL DCS-11 条件缺失
```

- 完整日志（原文，21 行）:

```
DCS-01 PASS [DRIFT CHECK] 步骤行含 drift-checker
DCS-02 PASS 只读检测执行体行含 drift-checker 无 task-drift-guard
DCS-03 PASS Chain 步骤 4 含 drift-checker
DCS-04 PASS C4 行含 drift-checker
DCS-05 PASS B/C 类处理完行含 drift-checker
DCS-06 PASS Rule 15 bullet+高频漂移纠正摘要行含 drift-checker
DCS-07 PASS 路由表漂移检测行含 drift-checker+haiku-1
DCS-08 PASS SKILL.md Skill(task-drift-guard) 计数=0
DCS-09 PASS References 双载体说明行
DCS-10 PASS 反模式偏移比对禁止行含 Rule 61
DCS-11 FAIL DCS-11 条件缺失
DCS-12 PASS Rule 61 标题+六锚齐全
DCS-13 PASS 15.4 锚+Skill(task-drift-guard) 计数=0
DCS-14 PASS drift-checker.md 存在+tools Read/Write+model 非空
DCS-15 PASS 双载体三态一致
DCS-16 PASS subagent-state/ 检查点契约串
DCS-17 PASS agent-coverage.md 含 drift-checker 行
DCS-18 PASS hook 含 drift-checker 无 task-drift-guard
DCS-19 PASS SKILL.md 行数<=558+61.4 清零+61.5 check-drift.sh
DCS-20 PASS 本技能目录 Skill(task-drift-guard) 精确串=0
Total: 20 PASS=19 FAIL=1
```

### selftest-execution-honesty.sh（rc=1）

- Total 行（原文）: `Total: 14 PASS=13 FAIL=1`
- 失败断言（原文逐字）:

```
9:EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-(5[3-9]|6[0-9])」=0（应 ≥1，级联漏改）
```

- 完整日志（原文，15 行）:

```
EH-01 PASS critical-rules.md 54.0「有依据原则」=1
EH-02 PASS critical-rules.md 54.1「就绪语义」=1
EH-03 PASS critical-rules.md 54.2「阻塞影响矩阵」=1
EH-04 PASS critical-rules.md 54.3「仪式性进展禁令」=1
EH-05 PASS critical-rules.md 54.4「推迟举证四要素」=1
EH-06 PASS critical-rules.md 54.5「决策依据落盘」=1
EH-07 PASS critical-rules.md 54.6「机制（零新 config 键」=1
EH-08 PASS critical-rules.md 关键短语 evidence-first=1≥1 / decision-basis=1≥1 / 零新 config 键=63≥1
EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-(5[3-9]|6[0-9])」=0（应 ≥1，级联漏改）
EH-10 PASS delivery-summary.md「54.1」=1≥1 且「54.4」=1≥1（真实进展对照行双锚）
EH-11 PASS image-generation-executor.md「Rule 54」指针行=1
EH-12 PASS video-generation-executor.md「Rule 54」指针行=1
EH-13 PASS critical-rules.md 54 块尾 55.x 属 task-v138 合法 Rule 55 块（^### 55 task-v138 标题=1，子条 6 ≤6）（task-v138 合并级联口径）
EH-14 PASS config.json 零新键：「"execution_honesty」命中=0（54.6 零 config 键声明成立）
Total: 14 PASS=13 FAIL=1
```

### selftest-lane-advancement.sh（rc=1）

- Total 行（原文）: `Total: 14 PASS=13 FAIL=1`
- 失败断言（原文逐字）:

```
12:LA-12 FAIL SKILL.md 主锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
```

- 完整日志（原文，15 行）:

```
LA-01 PASS critical-rules.md Rule 49 子条锚 5 ≥5
LA-02 PASS critical-rules.md Rule 49 标题锚在位
LA-03 PASS critical-rules.md「推进三条件」语义锚在位
LA-04 PASS critical-rules.md「跨 Phase 前移合法」语义锚在位
LA-05 PASS critical-rules.md「[advance]」登记锚在位
LA-06 PASS critical-rules.md「汇合点强串行」边界锚在位
LA-07 PASS critical-rules.md「Phase complete 翻转语义不变」门控锚在位
LA-08 PASS SKILL.md Rule 49 摘要 bullet 在位
LA-09 PASS SKILL.md 合规清单 C34 行在位
LA-10 PASS SKILL.md 执行循环步骤 2.5 推进检查括注在位
LA-11 PASS SKILL.md References 表 Rule 49 名在位
LA-12 FAIL SKILL.md 主锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
LA-13 PASS SKILL.md '1-40' 变体命中 0（负断言成立）
LA-14 PASS config.json properties 键数 42（零新增，基线含 v145 2 键）
Total: 14 PASS=13 FAIL=1
```

### selftest-requirement-coverage.sh（rc=1）

- Total 行（原文）: `Total: 23 PASS=22 FAIL=1`
- 失败断言（原文逐字）:

```
11:RC-11 FAIL SKILL.md 主锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39 变体非 0，SR-07 主锚被改动）
```

- 完整日志（原文，24 行）:

```
RC-01 PASS critical-rules.md Rule 51 子条锚 9 ≥7
RC-02 PASS critical-rules.md Rule 51 标题锚在位
RC-03 PASS critical-rules.md「需求原文锚定」语义锚在位
RC-04 PASS critical-rules.md「覆盖判据」语义锚在位
RC-05 PASS critical-rules.md「需求覆盖核对表」语义锚在位
RC-06 PASS critical-rules.md「自缩水禁令」语义锚在位
RC-07 PASS critical-rules.md「前置盘点」语义锚在位
RC-08 PASS critical-rules.md「零新 config 键」承诺锚在位
RC-09 PASS SKILL.md Rule 51 摘要 bullet 在位
RC-10 PASS SKILL.md 合规清单 C35 行在位
RC-11 FAIL SKILL.md 主锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39 变体非 0，SR-07 主锚被改动）
RC-12 PASS delivery-summary.md「需求覆盖核对」区块在位且编号区块数 =5
RC-13 PASS config.json properties 键数 42（零新增，基线含 v145 2 键）
RC-14 PASS registry.tsv 已登记 selftest-requirement-coverage.sh
RC-15 PASS critical-rules.md '66.' 子条命中 6（Rule 66 已合法落地 66.1-66.6，task-v151 钉值级联重锚）
RC-16 PASS critical-rules.md 51.7「纠正=回锚重译」=1 且判例锚「一个月→72小时两次改写」=1 且事故报告路径 =1
RC-17 PASS check-window-consistency.sh 在位可执行; 正例(锚=一个月 载荷=30天 同族) exit=0 无⚠; 负例(载荷=7天 无豁免) exit=1 有⚠
RC-18 PASS check-complete.sh R-COVERAGE 门锚在位（R-COVERAGE=4 rcov-gate=6，均 ≥1）
RC-19 PASS R-COVERAGE 负例（summary 缺行）enforce 档 exit=1≠0 且 stderr 含 rcov-gate 拒 COMPLETE 文案
RC-20 PASS R-COVERAGE 双断: 裸 uncovered 无让步 enforce exit=1≠0 拒 COMPLETE 含「只可 PARTIAL」; uncovered+让步行 exit=0=0 PARTIAL 放行（rcov-gate 提示行在位）
RC-21 PASS zcode-userpromptsubmit.sh TAMPERED 文案锚「无登记的重锁视为篡改信号」=1 且 Rule 51.7 引用 =1（G3 重锁前置收紧在位）
RC-22 PASS init-session.sh silent 路径 INFO 锚双行各 =1（主锁+兜底锁，G3 即时落盘在位）
RC-23 PASS critical-rules.md 51.8 行锚=1 且语义锚「未测试就声称完成」在位 且 SKILL.md '51.8' 联动 2 ≥1
Total: 23 PASS=22 FAIL=1
```

### selftest-research-first.sh（rc=1）

- Total 行（原文）: `Total: 12 PASS=11 FAIL=1`
- 失败断言（原文逐字）:

```
7:FAIL RF-07 SKILL 双锚(bullet 全角括号+头注 1-71 全集) (got=(1,0) expect=(>=1,>=1))
```

- 完整日志（原文，13 行）:

```
PASS RF-01 critical-rules ### 63 标题=1
PASS RF-02 critical-rules 63.1-63.6 六子条=6
PASS RF-03 63 块语义内核四词齐备(公理/检索/禁令/有据)
PASS RF-04 63.2 四步检索链词齐备
PASS RF-05 63.4 有理有据边界(编造+not-solved)
PASS RF-06 SKILL 1-6X 计数（宽容锚）≥3(三处联动)
FAIL RF-07 SKILL 双锚(bullet 全角括号+头注 1-71 全集) (got=(1,0) expect=(>=1,>=1))
PASS RF-08 SKILL C44 合规行含 Rule 63
PASS RF-09 dispatch 模板契约行(Rule 63+禁止编造)
PASS RF-10 FF-16 宽容化在位(66.x≥2 ∧ 65.x 残留=0)
PASS RF-11 registry 含本脚本登记行
PASS RF-12 config 零新键(research 字面=0)
Total: 12 PASS=11 FAIL=1
```

### selftest-root-resolution.sh（rc=1）

- Total 行（原文）: `Total: 17 PASS=15 FAIL=2`
- 失败断言（原文逐字）:

```
9:RR-09 FAIL SKILL.md 全集 1-(5[3-9]|6[0-9]) 命中=0（应 =1）或旧 1-51 残留=0（应 =0，级联漏改）
16:RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-(5[3-9]|6[0-9]|7[0-1])」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）
```

- 完整日志（原文，18 行）:

```
RR-01 PASS critical-rules.md 53.1「结果级需求全链工序审计」=1
RR-02 PASS critical-rules.md 53.2「根治判据」=1
RR-03 PASS critical-rules.md 53.3「决策管辖二分」=1 且「唯一权威边界」=1
RR-04 PASS critical-rules.md 53.4「返工成本核算」=1 且「三元组」=1
RR-05 PASS critical-rules.md 53.5「机制」=1 且 Q7 惰性推诿=2≥1 且 Q8 无根治判据=2≥1
RR-06 PASS critical-rules.md 51.1a「载体双机制」=1
RR-07 PASS SKILL.md Rule 53 摘要 bullet =1
RR-08 PASS SKILL.md 合规清单 C36 行 =1 且含「根源覆盖表」
RR-09 FAIL SKILL.md 全集 1-(5[3-9]|6[0-9]) 命中=0（应 =1）或旧 1-51 残留=0（应 =0，级联漏改）
RR-10 PASS task_plan.md「🎯 用户需求原文」=1 且「🧮 根源覆盖表」=1
RR-11 PASS rule-enhancement-type.md「🎯 用户需求原文」=1
RR-12 PASS subagent_dispatch.md「需求锚（Rule 51.1a」=1
RR-13 PASS init-session.sh inject_requirement_block=7≥2（定义+调用）且「根源覆盖表」=13≥1
RR-14 PASS attest-plan.sh「第 4 锚」=7≥1 且 [requirement-gate]=2≥2
RR-15 PASS critical-rules.md 旧判别面字面「或无客观判据的真实偏好二选」=0（critic P0 收口钉住）
RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-(5[3-9]|6[0-9]|7[0-1])」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）
RR-17 PASS critical-rules.md 区块锚「^### 53 」=1（索引行 40-54 全集的条款侧落点在位）
Total: 17 PASS=15 FAIL=2
```

### selftest-self-resolution.sh（rc=1）

- Total 行（原文）: `Total: 13 PASS=11 FAIL=2`
- 失败断言（原文逐字）:

```
7:SR-07 FAIL SKILL.md 字面锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
8:SR-08 FAIL Rule 40/41 共存锚损伤（含 Rule 40-(5[3-9]|6[0-9]|7[0-1]) 缺失或 ^40\. 子条数 ≠6）
```

- 完整日志（原文，14 行）:

```
SR-01 PASS critical-rules.md 六子条锚 = 6
SR-02 PASS critical-rules.md G1/G4 门槛锚各 ≥1
SR-03 PASS 「已尝试清单」+「D6 硬停点语义保留不弱化」措辞锚在位
SR-04 PASS trivial 裁定措辞「直接做」+「留用户裁决」在位
SR-05 PASS 41.6 行内锚（零新 config 键 / selftest-self-resolution.sh）在位
SR-06 PASS SKILL.md Rule 41 锚 3 ≥3 且 C29 项 =1
SR-07 FAIL SKILL.md 字面锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
SR-08 FAIL Rule 40/41 共存锚损伤（含 Rule 40-(5[3-9]|6[0-9]|7[0-1]) 缺失或 ^40\. 子条数 ≠6）
SR-09 PASS config.json properties 键数 42（v145 已合法加 2 键）
SR-10 PASS SKILL.md 摘要行锚「升级四门槛」在位
SR-11 PASS selftest-skill-split.sh task-v099/task-v1x label + -le 4/5 前缀断言行在位
SR-12 PASS registry selftest-self-resolution 登记行 ≥1 且总行数 73=脚本数+表头（动态）
SR-13 PASS 22.3.0 资料先行档行存在 + 资料先行/换道评估顺序/官方文档 关键词在位
Total: 13 PASS=11 FAIL=2
```

### selftest-source-anchor-discipline.sh（rc=1）

- Total 行（原文）: `Total: 11 pass, 1 fail`
- 失败断言（原文逐字）:

```
7:SA-07 FAIL SKILL.md 含 'Rule 71（无源不写' bullet + '| C50 |' 行 + '1-71' 计数 ≥2
```

- 完整日志（原文，13 行）:

```
SA-01 PASS critical-rules.md 含 '### 71 无源不写' 标题且 71.1-71.7 七子条锚全在
SA-02 PASS 71.1 行含四来源（file:line/URL/命令输出原文/工具调用记录）与「从严」
SA-03 PASS 71.2 行含五问要素与口诀「无源不写，空段占位，写必带锚」
SA-04 PASS 71.4 行含审计表五列头（单元位置/事实摘要/三态判定/源锚或/处置建议）与「补一个源」禁令
SA-05 PASS 71.5 行含「无锚点行=违规退回」
SA-06 PASS 71.7 行含「零新 config 键」与「机器边界如实披露」
SA-07 FAIL SKILL.md 含 'Rule 71（无源不写' bullet + '| C50 |' 行 + '1-71' 计数 ≥2
SA-08 PASS subagent_dispatch.md 含 '## 10. 防幻觉契约' 段与 '写入前五问' 回溯行
SA-09 PASS findings.md/progress.md 各含 'Rule 71' 注释锚且合计 ≥3
SA-10 PASS fix-prompts.md 含「提示词 A — 溯源审计」（素材锚活）
SA-11 PASS selftest-registry.tsv 含 'selftest-source-anchor-discipline.sh' 登记行
SA-12 PASS config.json 不含 source_anchor/anti_halluc/no_source 任一键名
Total: 11 pass, 1 fail
```

### selftest-tool-selection.sh（rc=1）

- Total 行（原文）: `Total: 12 PASS=11 FAIL=1`
- 失败断言（原文逐字）:

```
5:TS-05 FAIL SKILL.md 字面锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
```

- 完整日志（原文，13 行）:

```
TS-01 PASS critical-rules.md 六子条锚 = 6
TS-02 PASS 40.3 披露措辞「不可代调」命中 3
TS-03 PASS 40.4 显式点名 + 40.6 零新 config 键 行内锚在位
TS-04 PASS SKILL.md Rule 40 锚命中 5 ≥3
TS-05 FAIL SKILL.md 字面锚漂移（Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0）
TS-06 PASS SKILL.md 既有三锚（Rule 39 摘要行/C27/协同路由 dynamic-workflows）保全
TS-07 PASS SKILL.md C28 清单项在位
TS-08 PASS general 模板 🧰 区块与「上游分析记录」定位声明在位
TS-09 PASS mini-lite 豁免声明 =1 且 48 行 ≤80
TS-10 PASS subagent_dispatch 工具面提示行在位
TS-11 PASS 卫星两文档 + plan-writer 契约锚在位
TS-12 PASS config.json properties 键数 42（v145 已合法加 2 键）
Total: 12 PASS=11 FAIL=1
```

## 负结果与甄别记录

- **rc=0 日志中无隐藏失败**：对全部 62 个 rc=0 日志做 FAIL 字样扫描（排除 FAIL=0 / "N fail" 汇总行），仅 3 处为 PASS 描述文本中的字样（均非失败）：
  1. `selftest-iteration-persistence.sh` IP-08 PASS 行含 "PASS-FAIL=3"（描述性关键词计数）；
  2. `selftest-rule-reserve.sh` RR-10 PASS 行含 "同款判定 FAIL（有牙齿实测）"（负向自检 PASS 描述）；
  3. `selftest-smart-merge.sh` SM-06 PASS 行含 "staging-fail"（故障注入场景名）。
- **异格式脚本甄别（无 Total: 前缀，已单独解析，均 rc=0）**：
  - `selftest-final-gate-hash.sh`：结果行 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`，22 PASS 全列 [PASS]，判定 PASS；
  - `selftest-user-instruction-priority.sh`：结果行 `=== ALL PASS ===`，7 个 ✓ 断言，判定 PASS。
- **无超时**：全部 72 脚本 rc ∈ {0,1}，无 rc=124。
- **失败面观察（供 S10 参考，非根因结论，未验证）**：10 个 FAIL 脚本中 9 个的失败信息含 `1-71` 全集/字面锚漂移模式（如 "Critical Rules 1-71=0 应 ≥1 / 1-39=0 应 0"、"头注 1-71 全集"、"含 '1-71' 计数 ≥2"），另有 EH-09 / RR-09 / RR-16 / SR-08 涉及 `Rule 40-(5[3-9]|6[0-9])` 级联锚；与 v162 落地的 `1-74` 锚演进可能相关。只读旁证（worktree 内 SKILL.md）：`wc -l = 539`、`grep -cF '1-71' = 0`、`grep -cF '1-74' = 3`。根因定位与修复归 S10，本检查点只记录事实。
- **跑批后 worktree git status**（只读检查，跑批未产生测试残留）：
  `M SKILL.md / M references/critical-rules.md / M scripts/selftest-registry.tsv / M templates/subagent_dispatch.md / M templates/task_plan.md / ?? scripts/selftest-absorption-discipline.sh`（均为本任务预期工作集）。

## 证据与复现

- 原始 rc 清单: /tmp/v162-selftest-results.txt（72 行 rc + ALL_DONE）
- 逐脚本日志: /tmp/v162-selftest-*.log（72 个）
- 机械汇总表: /tmp/v162-table.txt（72 行，无表头）
- 复现命令: `cd /home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/skills/task-planner/scripts && for f in selftest-*.sh; do timeout 120 bash "$f" > "/tmp/v162-$f.log" 2>&1; rc=$?; printf '%s rc=%s\n' "$f" "$rc" >> /tmp/v162-selftest-results.txt; done`（可重跑）
