# 02 critic checkpoint — task-goal-unattended-protocol-20261124

status: done

- M1（2026-11-24）Read plan-brief.md §A/§B、edit-spec.md E0-E25、task_plan.md/findings.md/progress.md、user-session-log.md、knowledge-brief.md、01-plan-writer.md。
- M2（2026-11-24）机器核验：edit-spec 的 17 条 old 串逐条 grep，17/17 在声称行命中；6 个载体文件改前 28.9 计数=0、SKILL.md 旧措辞=2（132/268）；5 个运行位 6/6 载体文件均在位；baseline-selftest.log 与 baseline-verify.log 实读。
- M3（2026-11-24）六维审查完成，裁决 REJECTED（1C/6I/8W/2Q）。
- M4（2026-11-24）问题清单 JSON 与最终 8 字段块落盘。

## 六维审计

| 维度 | 结论 | 证据锚 |
|---|---|---|
| ①需求覆盖完整性（含 51.9 自缩水检查） | FAIL | R1-R4→VC-1..VC-8 映射在位（task_plan.md:21-24）；但 G3「decision-arbiter 可派发」无对应 VC（task_plan.md:31/38/75），VC-5 允许 MISSING 通过（task_plan.md:74）；51.9 无计数交付物不触发，D-7 排除项已经 D1 批准（user-session-log.md:63-68），未见未授权缩水 |
| ②机制设计合理性 | FAIL | 28.9④ 单点「一次独立仲裁」无不可用兜底（edit-spec.md:20）；⑤ 固定点/待授权清单无持久化载体；③/⑦ 对用户手输消息优先级未定 |
| ③既有机制冲突面 | FAIL | 41.5/72.1/97.5 未被 ⑧ 点名（discipline:144/449/653）；72.1 A 级「必须询问」与 ②「不询问」冲突；E5/E6 同句「停止该目标迭代」+「不停表…继续」（edit-spec.md:49-54）；执行期「判据上限」新增拆分项 vs 反作弊第 9 条冻结（verification-gate/SKILL.md:95/98） |
| ④比例原则与豁免面 | PASS | 纯文本、零新脚本/门/hook/selftest（plan-brief.md:26、D-4）；goal 语境限定；95/64/103 仅固定点应答豁免；84.5 拆分仅语义保证型判据 |
| ⑤可执行性（VC 命令判别性） | FAIL | VC-3/S10 把 verify 的 23/3 误作 selftest 基线（task_plan.md:122 vs baseline-selftest.log:105「Total: 104 PASS=104 FAIL=0」）；VC-5 MISSING 放行；VC-8 自证 grep 格式脆弱（task_plan.md:77） |
| ⑥篡改面（逐字锚/加戏检查） | FAIL | 28.9②「本仓源码修改」列入 /goal 预授权，超出用户 #2 仅部署裁决（edit-spec.md:20 vs user-session-log.md:53-55），与 28.8③/§六 及 E0 头「28.8①-④原文语义保留」矛盾；E24「两次失败」无锚；R1 逐字锚与 17/17 旧串锚通过 |

## 问题清单 JSON

```json
{
  "audit_round": "R1",
  "verdict": "REJECTED",
  "counts": {"C": 1, "I": 6, "W": 8, "Q": 2},
  "issues": [
    {
      "key": "C-1",
      "severity": "C",
      "state": "open",
      "title": "28.9⑦ 泛化授权可放行 D6 不可逆项",
      "location": "edit-spec.md:20 (E0 ⑦)；skills/task-discipline/references/critical-rules-discipline.md:144 (41.5)；:449 (72.1 A 级)",
      "evidence": "⑦「多项待授权而消息未指明时按清单推荐项执行」；②把 D6 类列入预算外并登记待授权清单；41.5「D6 项除外——D6 未获答复必须等待，不得按推荐项自走」",
      "suggestion": "⑦ 增加「D6 类项不适用泛化放行，须逐项显式确认；未指明时仅执行非 D6 推荐项」；E8/E9/E11/E12 同步加「D6 除外」",
      "confidence": "HIGH"
    },
    {
      "key": "I-1",
      "severity": "I",
      "state": "open",
      "title": "VC-3/S10 将 verify 基线 23/3 误作 selftest 基线",
      "location": "task_plan.md:122；knowledge-brief.md:34；plan-brief.md:50；baseline-selftest.log:105；baseline-verify.log:28",
      "evidence": "baseline-selftest.log:105「Total: 104 PASS=104 FAIL=0」；baseline-verify.log:28「23 pass / 3 fail」；task_plan.md:122 称 baseline-selftest.log（23 pass / 3 fail 基线）",
      "suggestion": "拆分两基线：VC-3=selftest 0 FAIL（对比 104/0）；S14=verify 23/3；修正 S10 输入与 knowledge-brief §2",
      "confidence": "HIGH"
    },
    {
      "key": "I-2",
      "severity": "I",
      "state": "open",
      "title": "28.9② 将「本仓源码修改」列入 /goal 预授权，超出用户裁决且与 28.8③/§六 冲突",
      "location": "edit-spec.md:20 (E0 ②)；plan-brief.md:28/46；user-session-log.md:53-55；critical-rules-discipline.md:64 (28.8③)",
      "evidence": "②「/goal 指令本身即授权…本仓源码修改」 vs 28.8③「D6/§六 技能与指令文件修改等须用户显式授权」；用户 #2 仅裁决部署预授权，未裁决源码修改预授权",
      "suggestion": "限定为「已批准计划 scope 内的项目源码」；skills/ 保护区源码仍须计划授权；E0 头改为「28.8①-④除②明确取代的硬门集合外语义保留」",
      "confidence": "HIGH"
    },
    {
      "key": "I-3",
      "severity": "I",
      "state": "open",
      "title": "E5/E6 同句保留「并停止该目标迭代」又追加「不停表…继续」",
      "location": "edit-spec.md:49-54 (E5/E6)；critical-rules-discipline.md:183/186",
      "evidence": "E5 new「按 28.8② 单次阻塞说明+降级收口并停止该目标迭代；预算外项不停表：…继续」；E1b 的澄清只在 28.8②",
      "suggestion": "改为「不再自发重做该目标迭代（不停表…）」；或把 E1b 澄清同步到 44.3/44.5 载体",
      "confidence": "HIGH"
    },
    {
      "key": "I-4",
      "severity": "I",
      "state": "open",
      "title": "28.9④C 执行期「判据上限」可新增机器可验拆分项，绕过反作弊第 9 条冻结",
      "location": "edit-spec.md:20 (E0 ④C)；skills/verification-gate/SKILL.md:95/98",
      "evidence": "④C「列机器可验拆分项（命令+PASS）+残余风险清单」 vs 判据行「自 attest 锁定起冻结，执行期禁改」；E20 例外仅覆盖计划期拆分（edit-spec.md:126）",
      "suggestion": "执行期只出 outcome（PARTIAL/BLOCKED）+残余风险，不新增判据行；或把 ④C 限制在计划期",
      "confidence": "HIGH"
    },
    {
      "key": "I-5",
      "severity": "I",
      "state": "open",
      "title": "41.5/72.1/97.5 未被 ⑧ 点名，72.1 A 级「必须询问」与 ②「不询问」冲突",
      "location": "edit-spec.md:20 (E0 ②/⑧)；critical-rules-discipline.md:144 (41.5)；:449 (72.1 A)；:653 (97.5)",
      "evidence": "②「预算外项不询问」 vs 72.1 A 级「必须询问，禁擅自执行」、41.5「单次 AskUserQuestion 列全」、97.5「四类门=用户专属决策点」",
      "suggestion": "⑧ 点名 41.5/72.1/97.5 并声明 goal 语境改待授权清单；或加指针与豁免说明",
      "confidence": "HIGH"
    },
    {
      "key": "I-6",
      "severity": "I",
      "state": "open",
      "title": "28.9④「一次独立仲裁」无不可用兜底",
      "location": "edit-spec.md:20 (E0 ④)；plan-brief.md:192 (FR-7)",
      "evidence": "「经一次独立仲裁（decision-arbiter→critic 降级）确认后冻结」；FR-7 载 decision-arbiter 曾派发失败并拖到第 10 轮",
      "suggestion": "加「两体均不可用=登记不可用证据并按 28.9⑥ 冻结默认，续推固定点应答」",
      "confidence": "MED"
    },
    {
      "key": "W-1",
      "severity": "W",
      "state": "open",
      "title": "G3（decision-arbiter 可派发）无 VC 映射",
      "location": "task_plan.md:31/38/75/151",
      "evidence": "G3「见 ✅ Verification Contract 对应 VC」但 VC 表无对应项；S15 冒烟未映射 VC",
      "suggestion": "新增 VC-9（S15 派发成功+结论落 progress.md）或把 G3 evidence 指向 S15",
      "confidence": "HIGH"
    },
    {
      "key": "W-2",
      "severity": "W",
      "state": "open",
      "title": "VC-5 允许 MISSING 通过，未强制 R3「全部运行位」",
      "location": "task_plan.md:74；plan-brief.md:107",
      "evidence": "「存在的位文件计数 ≥1；缺失的位文件以 MISSING 行如实列出」；未定义 MISSING 为 FAIL",
      "suggestion": "判据加「MISSING 行=0」，或对缺失位登记用户让步锚（51.4）",
      "confidence": "HIGH"
    },
    {
      "key": "W-3",
      "severity": "W",
      "state": "open",
      "title": "28.9③ 与 ⑦ 对用户手输消息的优先级未定",
      "location": "edit-spec.md:20 (E0 ③/⑦)",
      "evidence": "③「消息正文自称…=续推指令」；⑦「后续用户消息命中待授权清单=放行」；用户手输消息可同时命中",
      "suggestion": "加「用户手输消息优先按⑦/新指令判定；仅非用户手输的自动再入按③」",
      "confidence": "MED"
    },
    {
      "key": "W-4",
      "severity": "W",
      "state": "open",
      "title": "固定点/待授权清单无持久化载体",
      "location": "edit-spec.md:20 (E0 ②/⑤)",
      "evidence": "「登记待授权清单」未指定文件；⑤「零工具调用」无法回读盘上状态",
      "suggestion": "指定 progress.md `[goal-pending]`/`[goal-fixed-point]` 为权威源；固定点应答允许只读回读该段",
      "confidence": "MED"
    },
    {
      "key": "W-5",
      "severity": "W",
      "state": "open",
      "title": "④C「PARTIAL/BLOCKED」与 E18「不得判 BLOCKED」不一致",
      "location": "edit-spec.md:20 (E0 ④C)；edit-spec.md:114 (E18)",
      "evidence": "「定态 PARTIAL/BLOCKED」 vs 「拆分项全 PASS…⇒ PARTIAL（…不得…判 BLOCKED）」",
      "suggestion": "④C 明确：拆分项全 PASS→PARTIAL；未全 PASS/残余风险超限→BLOCKED",
      "confidence": "HIGH"
    },
    {
      "key": "W-6",
      "severity": "W",
      "state": "open",
      "title": "edit-spec 完成后自检 1 与 E1a 保留片语矛盾",
      "location": "edit-spec.md:172；edit-spec.md:29 (E1a)",
      "evidence": "自检「不得再有…单次阻塞降级收口」 vs E1a new「走②单次阻塞降级收口，…」",
      "suggestion": "自检预期改为「仅 discipline:64 的 28.8③ 保留片语 + E5/E6 的『并停止该目标迭代』」",
      "confidence": "HIGH"
    },
    {
      "key": "W-7",
      "severity": "W",
      "state": "open",
      "title": "pending Phase 的 V-N 复选框显示 [x]（render 硬编码）",
      "location": "task_plan.md:96/99-102,114/117-119,126/129,135/138,145/148；subagent-state/01-plan-writer.md:27/31/36",
      "evidence": "Phase status pending 但 `[x] V-2.1`…`[x] V-6.1` 已勾；plan-writer 载 planctl.py:1282 硬编码",
      "suggestion": "主进程裁决修复渲染器或登记豁免；D1 前确保 V-N 勾选态不误导",
      "confidence": "HIGH"
    },
    {
      "key": "W-8",
      "severity": "W",
      "state": "open",
      "title": "VC-8 drill-report grep 格式脆弱且为自证",
      "location": "task_plan.md:77",
      "evidence": "grep -cE '^- (D[1-4]) 判据[^:]*：PASS'；S16 未给报告行模板",
      "suggestion": "S16 输入附精确行模板；或改为独立复核+附件，不以自报 grep 为唯一判据",
      "confidence": "MED"
    },
    {
      "key": "Q-1",
      "severity": "Q",
      "state": "open",
      "title": "28.9① 工具返回文案「use best judgment/do not invent a preference」无第一手锚",
      "location": "edit-spec.md:20 (E0 ①)",
      "evidence": "plan-brief/FR-1 未载该文案；仅称 AskUserQuestion 9 次无应答",
      "suggestion": "改为行为判据「工具返回无有效用户答复/未作答」；如保留文案，补工具回执锚",
      "confidence": "MED"
    },
    {
      "key": "Q-2",
      "severity": "Q",
      "state": "open",
      "title": "E24「判例 sess_df5b8b4a 两次失败」次数无锚",
      "location": "edit-spec.md:151-153；plan-brief.md:192 (FR-7)",
      "evidence": "FR-7 只载失败留痕路径，未载次数",
      "suggestion": "补失败回执次数锚，或改为「多次失败」",
      "confidence": "MED"
    }
  ]
}
```

## 验证摘要

总发现 17 / 已验证 17 / 通过率 100%。

- edit-spec E1a-E25 的 17 条 old 串逐条 grep，均在声称行命中（含 E1a/E1b 同在 discipline:64、E5:183、E6:186、E7:395、E10:124、E13:346、E14:10、E16:204、E17:24、E18:40、E19:68、E20:98、E21:53、E22:225、E23:3-5）。
- baseline-selftest.log:105 与 baseline-verify.log:28 实读；task_plan.md:122、knowledge-brief.md:34、plan-brief.md:50 对照。
- 41.5:144、72.1:449、97.5:653、28.8:64、84.5:40、verification-gate/SKILL.md:95/98 实读。
- 5 个运行位 6/6 载体文件均在位（/home/terry/.zcode、.agents、.claude、.config/opencode、.cursor）。

## 负结果与排除项

- 未发现旧串失配：17/17 命中，edit-spec 的 old 串可直接施工；E1a/E1b 不重叠，E2 插入点明确（28.8 行与 `### 29` 之间）。
- 未发现改前 28.9 误报：6 个载体文件改前 28.9 计数均为 0；SKILL.md 旧措辞 2 处（132/268），VC-1 具判别性。
- 未发现 5 位缺文件：5 个运行位均 6/6；VC-5 的 MISSING 分支在实践中不触发，但其判据仍不强制「全部」（W-2）。
- 未发现 R1 原话篡改：task_plan.md:13 与 user-session-log.md:43 逐字一致；R2-R4 与 #2 选项一致。
- 未发现新增顶级规则号/脚本/门/hook/selftest：28.9 为 Rule 28 子条；D-4 与 edit-spec 未含脚本改动。
- 未发现 51.9 计数交付缩水：本任务无可计数媒体交付；D-7 排除项（goal.md/示例会话待授权项）经 D1 批准，非未授权缩水。
- 未发现主仓目标文件脏：7 个目标文件 git status 干净，仅 AGENTS.md 未跟踪；其余 48 个未提交变更不在 scope，未列为直接冲突（P4 合并仍需复核）。
- 排除「28.9 条款行重复」：E0 为单行，VC-2 的 `grep -c '^28\.9 '` 预期 =1 可成立。
- 排除「部署整槽覆盖」：28.9②/E25 均写逐位 diff、禁整文件覆盖、备份、verify；与 D-5 一致。

## 最终结论

status: done
acceptance: 1/6 pass — [1:FAIL 需求覆盖完整性：G3 无 VC（task_plan.md:31/38）、VC-5 允许 MISSING 通过（task_plan.md:74）；R1/R2/R4 映射在位，51.9 未触发、D1 已批准排除项 2:FAIL 机制设计合理性：④ 单点仲裁无兜底（edit-spec.md:20）、⑤ 固定点无持久化载体、③/⑦ 优先级未定 3:FAIL 既有机制冲突面：41.5/72.1/97.5 未点名（discipline:144/449/653）、72.1 A 级必须询问 vs ② 不询问、E5/E6 停止与不停表同句冲突（edit-spec.md:49-54）、执行期判据拆分 vs 反作弊 9（verification-gate/SKILL.md:95/98） 4:PASS 比例原则与豁免面：纯文本零脚本/门/hook/selftest（plan-brief.md:26/D-4）、goal 限定、95/64/103 仅固定点豁免 5:FAIL 可执行性：VC-3/S10 把 verify 23/3 误作 selftest 基线（task_plan.md:122 vs baseline-selftest.log:105 104/0）、VC-5 MISSING 放行、VC-8 自证 grep 格式脆弱 6:FAIL 篡改面：28.9② 本仓源码修改超用户裁决（edit-spec.md:20 vs user-session-log.md:53-55）、E0 头 28.8①-④语义保留与②取代硬门矛盾、E24 两次失败无锚；R1 逐字与 17/17 旧串锚通过]
files: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md(+1/-0)
evidence: edit-spec.md E1a-E25 old串 17/17 grep 命中；baseline-selftest.log:105 "Total: 104 PASS=104 FAIL=0" vs baseline-verify.log:28 "23 pass / 3 fail" vs task_plan.md:122 "23 pass / 3 fail 基线"；critical-rules-discipline.md:144 41.5 D6 未获答复必须等待；:449 72.1 A 级必须询问；:64 28.8③ 须用户显式授权；critical-rules-verification.md:40 84.5 BLOCKED 升级用户；verification-gate/SKILL.md:95/98 判据冻结。
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md (status: done)
findings_written: none
blockers: REJECTED：C-1 28.9⑦ 泛化授权可放行 D6 不可逆项；I-1 VC-3 基线误写（selftest 104/0 被写成 23/3）；I-2..I-6 见 checkpoint issues[]。
confidence: HIGH

---

## R2 计划审计（Rule 109 简版再审，2026-11-24）

status: done
verdict: REJECTED
prior_closed: 17/17
prior_open: 0/17
new_open: I-7（I，新增冲突）、W-9（W，派生视图残留）

### 逐项闭环（上轮 17 项）

| key | state | 闭环证据 |
|---|---|---|
| C-1 | closed | ⑦ 增加「D6 类与 A 级项不适用泛化放行，须逐项显式确认」（edit-spec.md:21）；E11 加「D6/A 级项须逐项显式确认」（edit-spec.md:79） |
| I-1 | closed | 双基线分离：selftest 104/0、verify 23/3（plan-brief.md:51）；VC-3/S10/S14 对应（task_plan.md:72/123/143）；knowledge-brief.md:34 已改 |
| I-2 | closed | 源码预授权收窄为「/goal 指令明示为任务对象」（edit-spec.md:21 ②）；未明示 skills/**、agent、指令文件列预算外；D-9 登记（plan-brief.md:195） |
| I-3 | closed | E5/E6 改为「停止该目标迭代」=不再自发重做 + 不停表说明（edit-spec.md:51/55） |
| I-4 | closed | ④C/E18/E19/E20 统一「执行期不新增、不改判据行；以计划期拆分为准」（edit-spec.md:21/115/123/127） |
| I-5 | closed | ②/⑧ 点名 41.5/72.1/97.5；预算外不询问=登记待授权清单、保持未执行（edit-spec.md:21） |
| I-6 | closed | ④C 增「两体均不可用=登记不可用证据后按既有证据定态」（edit-spec.md:21） |
| W-1 | closed | G3→VC-6/VC-9（plan-brief.md:83/92）；VC-9 命令锚 12-decision-arbiter.md（plan-brief.md:120-122；task_plan.md:78） |
| W-2 | closed | VC-5 改 30 文件无 MISSING + site-files-bad=0 + verify summary（plan-brief.md:108-110；task_plan.md:74） |
| W-3 | closed | ③「用户手输消息一律优先按⑦或新指令判定」（edit-spec.md:21） |
| W-4 | closed | ⑤ 待授权清单/gap key 登记 progress（planctl add --section decisions）；压缩恢复允许一次只读回读（edit-spec.md:21） |
| W-5 | closed | ④C 与 E18 统一：全 PASS→PARTIAL；未全 PASS/未拆→BLOCKED（edit-spec.md:21/115） |
| W-6 | closed | 自检 1 改为「仅剩 1 处 28.8③ 保留片语；并停止/仅单次=0」（edit-spec.md:174） |
| W-7 | closed | D-8 登记为已知局限，不改渲染器，交付披露（plan-brief.md:194） |
| W-8 | closed | VC-8 加报告行模板 + drill-skeleton.txt + skeleton-ok（plan-brief.md:117-119；task_plan.md:77） |
| Q-1 | closed | ① 补工具回执逐字 + 消息 ID（edit-spec.md:21；plan-brief.md:199） |
| Q-2 | closed | E24 两次派发失败=首轮与第十轮，附消息 ID（edit-spec.md:153；plan-brief.md:205） |

### R2 issues JSON

```json
{
  "audit_round": "R2",
  "verdict": "REJECTED",
  "prior_closed": 17,
  "prior_open": 0,
  "new_open": 2,
  "issues": [
    {"key": "C-1", "severity": "C", "state": "closed", "location": "edit-spec.md:21 (E0 ⑦)；edit-spec.md:79 (E11)", "suggestion": "closed：D6/A 级项逐项显式确认，泛化授权仅放行非 D6/A 推荐项"},
    {"key": "I-1", "severity": "I", "state": "closed", "location": "plan-brief.md:51；task_plan.md:72/123/143；knowledge-brief.md:34", "suggestion": "closed：selftest 104/0 与 verify 23/3 双基线分离"},
    {"key": "I-2", "severity": "I", "state": "closed", "location": "edit-spec.md:21 (E0 ②)；plan-brief.md:195 (D-9)", "suggestion": "closed：源码预授权收窄为 /goal 明示任务对象；未明示 skills/**、agent、指令文件预算外"},
    {"key": "I-3", "severity": "I", "state": "closed", "location": "edit-spec.md:51/55 (E5/E6)", "suggestion": "closed：停止=不再自发重做 + 不停表说明"},
    {"key": "I-4", "severity": "I", "state": "closed", "location": "edit-spec.md:21 (④C)；edit-spec.md:115/123/127 (E18/E19/E20)", "suggestion": "closed：执行期不新增/不改判据行；以计划期拆分为准"},
    {"key": "I-5", "severity": "I", "state": "closed", "location": "edit-spec.md:21 (E0 ②/⑧)", "suggestion": "closed：②/⑧ 点名 41.5/72.1/97.5；登记待授权清单并保持未执行"},
    {"key": "I-6", "severity": "I", "state": "closed", "location": "edit-spec.md:21 (E0 ④C)", "suggestion": "closed：两体均不可用=登记证据后按既有证据定态"},
    {"key": "W-1", "severity": "W", "state": "closed", "location": "plan-brief.md:83/92/120-122；task_plan.md:78", "suggestion": "closed：G3 映射 VC-6/VC-9；VC-9 落 checkpoint"},
    {"key": "W-2", "severity": "W", "state": "closed", "location": "plan-brief.md:108-110；task_plan.md:74", "suggestion": "closed：30 文件无 MISSING + site-files-bad=0 + verify summary"},
    {"key": "W-3", "severity": "W", "state": "closed", "location": "edit-spec.md:21 (E0 ③)", "suggestion": "closed：用户手输消息优先按⑦/新指令"},
    {"key": "W-4", "severity": "W", "state": "closed", "location": "edit-spec.md:21 (E0 ⑤)", "suggestion": "closed：待授权清单/gap key 登记 progress；压缩恢复允许一次只读回读"},
    {"key": "W-5", "severity": "W", "state": "closed", "location": "edit-spec.md:21 (④C)；edit-spec.md:115 (E18)", "suggestion": "closed：④C 与 E18 统一 PARTIAL/BLOCKED 条件"},
    {"key": "W-6", "severity": "W", "state": "closed", "location": "edit-spec.md:174", "suggestion": "closed：自检预期改为仅剩 1 处 28.8③ 保留片语"},
    {"key": "W-7", "severity": "W", "state": "closed", "location": "plan-brief.md:194 (D-8)", "suggestion": "closed：登记已知局限，不改渲染器，交付披露"},
    {"key": "W-8", "severity": "W", "state": "closed", "location": "plan-brief.md:117-119；task_plan.md:77", "suggestion": "closed：报告行模板 + drill-skeleton.txt + skeleton-ok"},
    {"key": "Q-1", "severity": "Q", "state": "closed", "location": "edit-spec.md:21 (E0 ①)；plan-brief.md:199 (FR-1)", "suggestion": "closed：补工具回执逐字 + 消息 ID"},
    {"key": "Q-2", "severity": "Q", "state": "closed", "location": "edit-spec.md:153 (E24)；plan-brief.md:205 (FR-7)", "suggestion": "closed：两次派发失败=首轮与第十轮，附消息 ID"},
    {"key": "I-7", "severity": "I", "state": "open", "title": "28.9② 将 72.1 A 级整体列永不自动，与 41.2 G4/44.3 D2-D5/28.8① 冲突", "location": "edit-spec.md:21 (E0 ②/⑧)；skills/task-discipline/references/critical-rules-discipline.md:449 (72.1 A④)、:140 (41.2 G4)、:183 (44.3 goal)、:64 (28.8①)", "evidence": "②「D1-D5 选择点（A 级决策点除外）」+「永不自动…A 级决策点（72.1）」；41.2 G4「silent 模式按 T3 推荐项自动+登记」；44.3 goal「D2/D5 真分叉…按推荐项自治裁决推进」；28.8①「含 D1-D5…一律静默自主决策」", "suggestion": "将 A 级拆为 A①-A③ 与 A④：A④ G4/D2-D5 保留 41.2 silent/44.3 goal 自治；或在 ⑧ 点名 41.2/44.3/28.7 并取得用户对语义反转的授权；同时修正 E0 头「28.8①-④原文语义保留」为「除②明确取代的硬门与 A 级子集外」", "confidence": "HIGH"},
    {"key": "W-9", "severity": "W", "state": "open", "title": "progress_baseline PB1-PB7 仍将 selftest 基线写成 23/3", "location": "task_plan.md:170-176；plan-state.json progress_baseline PB1-PB7", "evidence": "snapshot 仍为「baseline-selftest.log 23 pass/3 fail」；plan-brief.md:51/VC-3/task_plan.md:72/123 已改 104/0", "suggestion": "planctl set progress_baseline PB1-PB7 snapshot 为双基线（selftest 104/0；verify 23/3）并 render；或从 plan-brief §B9 派生", "confidence": "HIGH"}
  ]
}
```

### R2 验证摘要

- 17/17 上轮问题 closed；本轮只审 plan-brief/edit-spec 增量 + 计划三文件派生视图。
- 新发现：I-7（新增冲突，I 级，open）；W-9（派生视图残留，W 级，open）。
- 复核：edit-spec 修订后 E5/E6/E15/E18/E19/E20/E24 的 new 文本与 E0 ④C/⑤/⑦/⑧ 互查；41.2:140、44.3:183、72.1:449、28.8:64 实读。
- 未发现旧串锚变化；未发现新增 C 级；未发现部署/合并/VC 命令新增冲突。

### R2 最终结论

status: done
acceptance: 17/17 closed — [C-1:closed（edit-spec.md:21 ⑦/E11:79 D6/A 逐项确认）; I-1:closed（plan-brief.md:51 双基线；task_plan.md:72/123/143；knowledge-brief.md:34）; I-2:closed（edit-spec.md:21 ② + D-9:195）; I-3:closed（edit-spec.md:51/55）; I-4:closed（edit-spec.md:21/115/123/127 执行期不新增判据行）; I-5:closed（edit-spec.md:21 ②/⑧ 点名 41.5/72.1/97.5）; I-6:closed（edit-spec.md:21 ④C 仲裁兜底）; W-1:closed（plan-brief.md:83/92/120-122 + task_plan.md:78 VC-9）; W-2:closed（plan-brief.md:108-110 + task_plan.md:74 site-files-bad=0）; W-3:closed（edit-spec.md:21 ③ 用户手输优先）; W-4:closed（edit-spec.md:21 ⑤ progress 登记）; W-5:closed（edit-spec.md:21/115 ④C=E18）; W-6:closed（edit-spec.md:174）; W-7:closed（plan-brief.md:194 D-8 已知局限）; W-8:closed（plan-brief.md:117-119 + task_plan.md:77 模板+skeleton）; Q-1:closed（edit-spec.md:21 ① + FR-1:199）; Q-2:closed（edit-spec.md:153 + FR-7:205）]
files: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md(+1/-0，R2 段追加)
evidence: R2 闭环：C-1 edit-spec.md:21 ⑦「D6/A 级项不适用泛化放行」；I-1 plan-brief.md:51 + baseline-selftest.log:105 104/0；I-2 D-9 plan-brief.md:195；I-3 E5/E6 edit-spec.md:51/55；I-4 ④C/E18/E19/E20「执行期不新增判据行」；I-5 ②/⑧ 点名 41.5/72.1/97.5；I-6 ④C 仲裁兜底；W-1 VC-9；W-2 VC-5 site-files-bad=0；W-3 ③ 用户手输优先；W-4 ⑤ progress 登记；W-5 ④C/E18；W-6 edit-spec.md:174；W-7 D-8；W-8 VC-8 模板+skeleton；Q-1 ①/FR-1:199；Q-2 E24:153/FR-7:205；新 I-7 edit-spec.md:21 ② A 级 vs discipline:449/140/183/64；新 W-9 task_plan.md:170-176 PB 残留。
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md (status: done)
findings_written: none
blockers: REJECTED：新增 I-7（28.9② 将 72.1 A 级整体列永不自动，与 41.2 G4 silent 自动、44.3 goal D2/D5 自治、28.8① D1-D5 静默冲突）；W-9 派生 progress_baseline 仍写 selftest 23/3。
confidence: HIGH

---

## R3 计划审计（Rule 109 简版再审，2026-11-24）

status: done
verdict: APPROVED
prior_open: 0（I-7/W-9 均 closed）
new_open: W-10（W，非阻断）

### I-7 / W-9 闭环

| key | state | 闭环证据 |
|---|---|---|
| I-7 | closed | ② 只把 D6 类（72.1 A②/A③）列预算外，A①/A④ 归预算内自治（edit-spec.md:21 ②）；⑦ 泛化授权只对 D6 类逐项确认（同处 ⑦）；⑧ 明确 A①/A④ 与 41.2 G4 的 goal 处置不变（同处 ⑧）；D-10 登记（plan-brief.md:196） |
| W-9 | closed | PB1-PB7 快照改为双基线：selftest=baseline-selftest.log（104 PASS/0 FAIL）、部署对账=baseline-verify.log（23 pass/3 fail）；task_plan.md:170-176 同步（plan-state.json progress_baseline 实读） |

### 相容性核对

- 72.1 A①/A④：② 归预算内，按 28.8①（:64）与 44.3（:183）推荐项自治；41.2 G4（:140）silent 自动；⑧ 明示「处置不变」——成立。
- 72.1 A②/A③：②/⑧ 归 D6 类预算外；⑧ 点名 41.5 的 D6 项保持未执行；⑦ 只对 D6 类逐项确认——C-1 修复同时成立。
- 41.5 D6：⑧ 保持未执行、不询问；44.3 D2/D5：② 归预算内自治；28.8① D1-D5：② 明示含 A①/A④ 自治——无新冲突。
- 97.5/72.2 的「呈报确认」由 ⑧「凡以…呈报确认为终点动作」兜底，未见新增冲突。

### R3 issues JSON

```json
{
  "audit_round": "R3",
  "verdict": "APPROVED",
  "prior_open": 0,
  "new_open": 1,
  "issues": [
    {"key": "I-7", "severity": "I", "state": "closed", "location": "edit-spec.md:21 (E0 ②/⑦/⑧)；plan-brief.md:196 (D-10)", "suggestion": "closed：A①/A④ 预算内自治；A②/A③ 与 D6 类预算外/逐项确认"},
    {"key": "W-9", "severity": "W", "state": "closed", "location": "plan-state.json progress_baseline PB1-PB7；task_plan.md:170-176", "suggestion": "closed：双基线快照（selftest 104/0；verify 23/3）"},
    {"key": "W-10", "severity": "W", "state": "open", "title": "A① 含「范围」，与「超 28.8④ 上界=预算外」边界未明示", "location": "edit-spec.md:21 (E0 ②)；critical-rules-discipline.md:64/449", "evidence": "72.1 A① 含「范围」；② A① 括注自治；同段「超 28.8④ 上界的范围扩张」列预算外，未写 A① 仅上界内", "suggestion": "A① 括注「仅限 28.8④ 上界内；超上界仍预算外」", "confidence": "HIGH"}
  ]
}
```

### R3 最终结论

status: done
acceptance: 2/2 closed — [I-7:closed（edit-spec.md:21 ②/⑦/⑧ + D-10:196：A①/A④ 预算内自治、A②/A③ 与 D6 类预算外、⑦ 只对 D6 类逐项确认）; W-9:closed（plan-state PB1-PB7 + task_plan.md:170-176 双基线 selftest 104/0、verify 23/3）]
files: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md(+1/-0，R3 段追加)
evidence: I-7 edit-spec.md:21 ②「A①/A④ 预算内」+ ⑧「A①/A④ 与 41.2 G4 goal 处置不变」+ D-10:196；C-1 edit-spec.md:21 ⑦「仅执行非 D6 类推荐项；D6 类逐项确认」；W-9 plan-state PB1-PB7 实读「selftest=...104 PASS/0 FAIL；部署对账=...23 pass/3 fail」+ task_plan.md:170-176；相容性 72.1:449/41.2:140/44.3:183/28.8①:64 实读；新 W-10（非阻断）A① 范围边界未明示。
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/02-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
