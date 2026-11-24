# 2-critic — 计划独立审计（Rule 109 / S2）

status: done

## 已完成里程碑（append-only）

- 2026-11-24T04:20+08:00 读取审计输入：task_plan.md / findings.md / progress.md / user-session-log.md / plan-brief.md / knowledge-brief.md（只读）。
- 2026-11-24T04:26+08:00 需求锚逐字对照：R1-R4 与 user-session-log.md:43 原文做子串精确匹配，4/4 True（脚本输出 EXACT_SUBSTR=True ×4）。
- 2026-11-24T04:29+08:00 VC 判据可执行性实测：管道符转义测试（`grep -c '^\| SP-'` 对 3 行文件返回 3，`'^| SP-'` 返回 1）；`jq -e '.a\|has("b")'` 返回 rc=3 语法错误；plan-state.json 9 条 command 中反斜杠管道符 0 条，task_plan.md 渲染 VC 行 5 条含 `\|`（VC-2/3/4/7/9）。
- 2026-11-24T04:30+08:00 VC-7 结构可达性实测：plan-state root_causes[0] 字段仅 id/process/defect/fix/vc；schema definitions.root_cause_item additionalProperties=false；VC-7 需 evidence+verified → 结构不可达。
- 2026-11-24T04:31+08:00 环境实测：/home/terry/.zcode/cli/log 仅 zcode-2026-11-18..24.jsonl 共 7 个日文件（无 11-17），合计约 990MB；S4 所列 5 个 hook/sync 脚本在 /home/terry/.zcode/skills/task-planner/scripts/ 下均存在。
- 2026-11-24T04:32+08:00 planctl 自检复跑：validate PASS；check vc-nonvacuous PASS；check rvc PASS；check evidence「0 条证据合格 / 9 条空证据 SKIP」。
- 2026-11-24T04:33+08:00 六维结论与分级问题清单定稿：1C / 8I / 8W，裁决 REJECTED。

## 进行中

- 无。

## 产出文件清单

- /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md（本文件，唯一写入）

## 错误与受阻

- 无。全程只读；未修改计划任何文件、任务书、仓库文件或其他计划目录。

## 最终结论

status: done
acceptance: 4/4 pass — [1:PASS 六维逐维结论齐备且每条带 file:line+最小修正 2:PASS 17 项分级（1C/8I/8W）+ key + state=open 3:PASS 裁决=REJECTED（0C/0I 门槛未达） 4:PASS evidence 末尾附 audit-add JSON 数组]
files: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (+1/-0); none
evidence: 裁决=REJECTED（C=1 / I=8 / W=8，共 17）。
  六维结论：①需求覆盖 PASS——R1→VC-2、R2→VC-3/4/5/6、R3→VC-8、R4→VC-4/7/8（plan-state.json requirements.vc），R1-R4 与 user-session-log.md:43 逐字 100% 一致；「运行日志」=11-18..24 全量 7 日（plan-brief.md:49/D-2）非抽样，「改进」=2-3 方案+推荐+FILE-CHANGE+DRIVE-POINT（plan-brief.md:69）非泛泛建议；无自缩水。②机制设计 FAIL——I-2/I-3/I-4/I-5（见下）。③冲突面 FAIL——I-8；C1-C7 逐条核对：C1 只读（task_plan.md:191）、C2 归因口径（task_plan.md:198）、C3 全量（plan-brief.md:38）、C4 未提否决项（plan-brief.md:39,69）均符合；Rule 109.2 输入包=task_plan+逐字锚+knowledge-brief（task_plan.md:96）与裁决映射一致；缺 Rule 109.4 报告面审计。④比例 PASS——standard/L1 与 7 Phase/12 S-unit 相称，Rule 109.3 未误用豁免；仅 W-8 预算偏紧。⑤可执行性 FAIL——C-1/I-1/I-6/I-7 + W-1/W-5/W-6/W-7；字段名一致性已核：recheck.rechecker=Verifier（task_plan.md:74）、PLANS-EVID/OS-ARTIFACT（:75）、(Recommended)/FILE-CHANGE/DRIVE-POINT（:77）与 S-unit 验收同形。⑥篡改面 PASS——R1-R4 逐字命中，R3/R4 的 type 改写在 task_plan.md:23-24 与 plan-brief.md:17-18 双向注明 schema 限制，无需求外功能加戏；W-3 属背景断言证据不全，非需求篡改。
  【C-1】task_plan.md:76 + schemas/plan-state.schema.json#definitions.root_cause_item — VC-7 结构不可达。原文「[.root_causes[]|select((.evidence|length)>=2 and has("verified"))]|length>=3」；schema additionalProperties=false 仅允许 id/process/defect/fix/vc，plan-state 5 条 root_causes 无 evidence/verified（D-8 已自承 planctl 拒写），缺失字段 length=0 → VC-7 永假，S9/P7 必 FAIL。最小修正：VC-7 改判 config.hypotheses（已含 verified+anchor）：jq -e '[.config.hypotheses[]|select(.verified!=null and (.anchor|length)>0)]|length>=5'。置信度 HIGH。
  【I-1】task_plan.md:72（VC-3）+ plan-brief.md:49 — 原文「files ≥8 项，每项 lines_scanned>0 且 parse_bad 为数值」；实测 /home/terry/.zcode/cli/log 仅 11-18..24 共 7 个日文件、11-17 缺失，D-1 窗口起点无对应文件；且 VC 无日期覆盖断言，任意 8 文件即可 PASS。最小修正：改 length>=7 + 断言 files[].file 覆盖 11-18..11-24 各一日，§H 声明 11-17 缺失为事实。HIGH。
  【I-2】task_plan.md:73（VC-4）vs plan-brief.md:85 — 原文只要求 sessions_main/…_with_sp/…_with_os/skill_calls_*/escort_reads_*/openspec_cli_calls；§H 定义的 mentions_text_sp/os、sessions_sub、definitions{} 不入必需集 → S6 漏产「提及」计数仍 PASS，机械门无法证明「被调用」与「被提到」可区分（R4 核心）。最小修正：VC-4 增 has("mentions_text_sp")/has("mentions_text_os")/has("definitions") + verdict 方向校验。HIGH。
  【I-3】task_plan.md:118+180 — 原文「files≥8 + totals 八字段 + per_session≥10」；G1 判据「调用并用于推进」在 totals 无 used/effect 字段，report-log.md 逐会话时间线无任何 VC 承载 → 缺「推进」证据仍全 PASS。最小修正：§H 增 sessions_main_with_sp_used（调用后实质动作）并纳入 VC-4；report-log.md 加行首标记 SESSION-EVID + 对应 VC。HIGH。
  【I-4】task_plan.md:105-106（plan-brief.md:56 g-ro 成员 S3/S4/S5/S8）— 原文「report-design.md 技能清单表每技能一行」/「report-design.md「驱动点缺口」表每条标题含 DRIVER-GAP-<n>」；两 unit 并发且输出同一文件，整文件写互相覆盖，FMEA 未登记。最小修正：拆为 report-design.md + report-driver-gap.md，或 S4 改依赖 S3 串行追加，VC-2 同步。HIGH。
  【I-5】task_plan.md:118-119,137,146,147,164 — 原文「| 15min | 2f/150l/15min | 依赖 S5 | - | pending |」；依赖被写进「伴飞技能」列，plan-state s_units[].parallel 取值含「依赖 S5」而 depends_on 全为 null，「前置依赖」列全 "-" → 派发侧无机器依赖，S6 可早于 S5 执行；§G2 要求的 parallel 字段被污染。最小修正：依赖移入 depends_on（planctl set），parallel 仅留 g-ro/无。HIGH。
  【I-6】task_plan.md:71,72,73,76,78（对照 plan-state.json vcs[].command 0 处转义）— 原文「test "$(grep -c '^\| SP-' …/report-design.md)" -ge 14」；render 把 `|` 转义为 `\|`：BRE 下 `^\| SP-` 退化为「^ OR ' SP-'」匹配所有行（实测 3 行文件返回 3），jq `\|` 语法错（实测 rc=3）→ 从视图执行 VC-3/4/7 恒 FAIL、VC-2/9 失去判别力；task_plan.md:105 的「行首 \| SP-<name> \|」照抄与 `^| SP-` 不匹配。最小修正：S12 验收声明「VC 命令唯一取自 plan-state.json」；S3 验收改写「行首 `| SP-`」；render 转义登记为仓库待修项（本轮不改）。MED。
  【I-7】task_plan.md:76 vs :37（G2「逐条验证或推翻 H1-H5」）— 原文「root_causes 中 evidence ≥2 且含 verified 字段的条目 ≥3」；5 条假设只需 3 条即可 PASS，漏 2 条也能交付。最小修正：加全覆盖断言 ([.config.hypotheses[].id] - [.root_causes[].id])|length==0。HIGH。
  【I-8】task_plan.md:164 vs critical-rules.md:208/210（Rule 109.4/109.5）— 原文「VC-1..9 逐条复验；Rule 84.14 全文档回读；写交付报告」；REPORT.md 含判断结论属报告面，须交付前独立审计（84.7/简版留痕），计划仅 S11 审改进方案，S12 主进程自写自验。最小修正：P7 增 critic 简版复核（留痕 [audit-before-delivery]）或 S12 验收加 report-audit 段。HIGH。
  【W-1】task_plan.md:72 — VC-3 不设 parse_bad 上限，100% 解析失败仍 PASS；修正：增 .parse_bad/.lines_scanned<=0.05。HIGH。
  【W-2】task_plan.md:61 — root_causes[0].process 被截断为 66 字符「…不注入 using-supe」（config.hypotheses 存有全文）；修正：planctl 补全 process。HIGH。
  【W-3】task_plan.md:197 — 「至少已 5 次被提出（10-08 R5、11-15、11-16、11-23、11-24）」中仅 10-08 有锚（knowledge-brief.md §2），其余 4 处无 file:line；修正：补锚或改「至少 3 次（有锚）」。MED。
  【W-4】task_plan.md:147 — S11 评审面只列「C4 合规」，C5（必须每次发生→sync-todos.sh 基线组成员）无评审项；修正：增 C5 合规检查项。HIGH。
  【W-5】task_plan.md:96 + progress.md:22-23 — S2 验收仅「出具 APPROVED 或问题清单」，progress 审计轮次表无「问题清单/修复对照」列，Rule 109.6 留痕要素无落点；修正：S2 验收加 [plan-audit-R1] 段（轮次/审计体/结论/问题清单/修复对照）。HIGH。
  【W-6】task_plan.md:78 — VC-9 只校验自报 writes.txt，越界写不登记即不可检出；修正：增 git status 白名单抽查或 mtime 比对。MED。
  【W-7】task_plan.md:106 — S4 输入列用裸脚本名「sync-todos.sh；zcode-sessionstart.sh / zcode-userpromptsubmit.sh / zcode-pretooluse.sh / zcode-posttooluse.sh」，无绝对路径（5 文件实测存在于 /home/terry/.zcode/skills/task-planner/scripts/）；修正：展开绝对路径。HIGH。
  【W-8】task_plan.md:118 — S6 15min 覆盖 ~990MB/7 文件逐行解析偏紧（FMEA F4 有分片兜底但预算未体现）；修正：时长改 25min 或粒度注明按日后台分片。MED。
  验证摘要：总发现 17 / 已验证 17（命令或原文实读复核）/ 通过率 100%；负结果：C1-C7 无违反（除 I-8 的 109.4 报告面），Rule 44.3 口径（D-7）核实属「完成性指令」适用面、不构成违规，R1-R4 无篡改、无需求外加戏，S-unit 产物路径与字段名除 I-4/I-6 所列外一致，planctl validate/vc-nonvacuous/rvc 均 PASS（其对 C-1 无检出能力）。
  [{"key":"C-1","severity":"C","state":"open"},{"key":"I-1","severity":"I","state":"open"},{"key":"I-2","severity":"I","state":"open"},{"key":"I-3","severity":"I","state":"open"},{"key":"I-4","severity":"I","state":"open"},{"key":"I-5","severity":"I","state":"open"},{"key":"I-6","severity":"I","state":"open"},{"key":"I-7","severity":"I","state":"open"},{"key":"I-8","severity":"I","state":"open"},{"key":"W-1","severity":"W","state":"open"},{"key":"W-2","severity":"W","state":"open"},{"key":"W-3","severity":"W","state":"open"},{"key":"W-4","severity":"W","state":"open"},{"key":"W-5","severity":"W","state":"open"},{"key":"W-6","severity":"W","state":"open"},{"key":"W-7","severity":"W","state":"open"},{"key":"W-8","severity":"W","state":"open"}]
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

## R2 简版再审（2026-11-24T04:50+08:00，只审变更增量 + R1 清单闭环）

### 里程碑

- 2026-11-24T04:44+08:00 读取增量：plan-state.json（vcs/s_units/phases/goals/root_causes/core_question/fmea/progress_baseline）、plan-brief.md §K §L（并逐段对照 §F/§H/§I/§J 是否同步）。
- 2026-11-24T04:47+08:00 实跑 10 条 VC：VC-1 rc=1 / VC-2 rc=2 / VC-3 rc=2 / VC-4 rc=2 / VC-5 rc=2 / VC-6 rc=2 / VC-7 rc=1 / VC-8 rc=2 / VC-9 rc=0 / VC-10 rc=2；`jq -r '.vcs[].command' | grep -c '|'` = 0。
- 2026-11-24T04:48+08:00 planctl 自检：validate PASS；vc-nonvacuous PASS 10 条；rvc PASS R=4 VC=10。
- 2026-11-24T04:49+08:00 发现内容源双版本规范（§H:84-85 / §I:92-111 / §F:65,67 / §J:117 未随 §K/§L 更新），立项 C-2。

### R1 清单闭环（16 closed / 1 open，共 17）

| key | 状态 | 证据 |
|---|---|---|
| C-1 | closed | VC-7 已改判 schema 实有字段：`defect[0:9]=="CONFIRMED" or defect[0:7]=="REFUTED"` + `process[60:61]!=null` + H1-H5 全覆盖（plan-state.json vcs[VC-7].command），实跑 rc=1（改前占位 verified=false 前缀 → FAIL，具判别性） |
| I-1 | closed | VC-3 改 `.files[-7] != null` + 7 个日志绝对路径逐一 `any()` + parse_bad ≤5%；磁盘实测恰为 11-18..24 七个文件（`ls` 无 11-17）；rc=2 |
| I-2 | closed | VC-4 增 `mentions_text_sp/mentions_text_os/definitions` 与 used 字段，非空断言齐备；rc=2 |
| I-3 | open（部分） | used/ritual + SESSION-EVID + VC-10 已落在 §K K3 与 plan-state，但规范结构 §H:85 仍是旧 12 字段、无 SESSION-EVID 行格式 → 合并登记 C-2 |
| I-4 | closed | S3→report-design.md、S4→report-driver-gap.md（s_units[S4].verify 明写「与 S3 的 report-design.md 分文件写，无并发同写」），VC-2 分别读两文件，FMEA 增 F5 |
| I-5 | closed | `parallel` 仅 g-ro/无（13 个 s_units 实测），依赖以「前置=Sx」写入 actions（S2/S6/S7/S9/S10/S11/S12/S13 均在位）；depends_on 不被 schema 接受已如实登记于 K5 与 D-8 |
| I-6 | closed | 10 条 command 管道符计数 0；10 条实跑 rc 如上（9 条非 0、VC-9 为不变量）；S12 verify 增「VC 命令唯一取自 plan-state.json，不从 MD 视图照抄」。残余视图转义 → I-10 |
| I-7 | closed | VC-7 增 `any(.id=="H1".."H5")` 全覆盖 + `.root_causes[-5]!=null`（≥5 条） |
| I-8 | closed | 新增 S13（critic，[audit-before-delivery]，0C/0I 才可交付）；`phases[P7].s_units=["S12","S13"]` 实测 |
| W-1 | closed | VC-3 增 `(.parse_bad - 0) <= (.lines_scanned * 0.05)`（同时以 `(.parse_bad-0)==.parse_bad` 排除非数值） |
| W-2 | closed | 五条 process 长度 65-78（H1=78，全文「待验证假设（全文）：…不注入 using-superpowers。」），无截断 |
| W-3 | closed | core_question.text 改「至少 4 次有锚：10-08/11-15/11-16/11-24 + 11-23 二手标注」 |
| W-4 | closed | S11 verify 增「K11：C5 合规——『必须每次发生』步骤是否落为 sync-todos.sh 基线组成员」 |
| W-5 | closed | S2 verify 增「K12：[plan-audit-R<N>] 留痕由主进程登记（轮次/审计体/结论/问题清单/修复对照）」 |
| W-6 | closed | VC-9 改 `grep -v -e <PD>/ -e <T>/` 白名单（实跑 rc=0）；S12 verify 增 K13 双源交叉（子代理 files 字段逐条核） |
| W-7 | closed | S4 files 展开 5 个脚本绝对路径 + `/home/terry/.zcode/cli/config.json`（5 脚本实测存在） |
| W-8 | closed | S6 duration=25min、granularity=2f/150l/25min（plan-state s_units[S6]） |

### R2 新增问题（续号）

- 【C-2】plan-brief.md:84-85、:92-111、:65/:67、:117 — 内容源存在双版本规范。原文（§H:84-85）「files[] … 覆盖 11-17..24 全部日志文件」/「totals：sessions_main…verdict」（无 used / sessions_with_calls_main / session_evid_rows）；§I:100-101 仍是旧 9 条含管道符 VC；§F:65 S6 仍「11-17 至 11-24 … 15min」、§F:67 S8「11-17 起」；§J:117「D-1=A1 窗口自 11-17」。而 §K K2/K3/K15/K18 与 §L、plan-state 已是新口径（7 文件 / 15 字段 / 25min / 11-18..24）。knowledge-brief.md:82 的 S6 材料包仍指向「plan-brief.md §H（:82-90）」→ S6 按 §H 汇总必产出旧 12 字段，VC-4（13 字段）与 VC-10 结构性不可达；S12 若读 §I 会复用旧命令。原因：增量只追加 §K/§L，未废止/替换被引用的规范段。最小修正：①§H 整段替换为新结构（files 7 文件 + totals 15 字段 + report-log SESSION-EVID 行格式与 used/ritual 判据表）；②§I 标注「已废止，见 §L」或整段替换；③§F 的 S6 时间窗/时长与 S8 起点、§J 的 D-1/D-2 同步。置信度 HIGH。

- 【I-9】plan-brief.md:126（§K K3）— VC-10 行粒度歧义。原文「对每个有调用的主会话写一行，行首 `SESSION-EVID <session_id> <SP|OS> <skill> <used|ritual> <证据锚>`」；行格式只承载单个 `<skill>`，一个主会话调用多个 SP/OS 技能时若按技能写多行，`session_evid_rows > sessions_with_calls_main` → VC-10 等值断言假 FAIL；若按会话写一行，字段无法表达多技能。最小修正：K3 明确「每会话一行，skill 列为逗号分隔技能清单」，或 VC-10 改为「distinct session_id 覆盖」断言（`([.per_session[]... ]|unique|length)==.totals.sessions_with_calls_main`）。置信度 MED。

- 【I-10】plan-state.json vcs[VC-2].command 与 plan-brief.md §L VC-2、task_plan.md:106 — 判据与验收标记不一致。plan-state 用 `'^. SP-'`（任意单字符前缀），§L 写作 `'^[|] SP-'`（K6 声称「逐字采用」）；渲染视图 task_plan.md:106 仍显示「行首 `\| SP-<name> \|`」「行首标记写作『行首 \| SP-』」。照抄视图产出 `\| SP-…` 行时 `^. SP-` 不匹配（首字符 `\`、第二字符 `|` 非空格）→ VC-2 假 FAIL；反之 `^.` 会把「x SP-」类行误计为 SP 技能行。最小修正：命令统一为 `'^[|] SP-'`（`[|]` 不含裸管道符，render 安全），S3 verify 改写「行首竖线 + 空格 + `SP-`」，或在 S3 verify 附一句「以 plan-state vcs[VC-2].command 为准」。置信度 HIGH。

- 【W-9】plan-state.json:501（core_question.checks）/ task_plan.md:202 / task_plan.md:166 — 原文「以 VC-1..VC-9 全 PASS 为准」「S12 … VC-1..9 逐条复验」，与 VC 集（10 条）、S12 verify「VC-1..10 全 PASS」不一致。最小修正：三处统一 VC-1..VC-10。

- 【W-10】plan-state.json vcs[VC-1].criterion/command — 原文判据「计划与报告均经独立审计达标」，命令仍只读 `.audits[-1].verdict`；S12（复核 VC-1）在 S13（报告面审计）之前，S13 之后无单元再跑 VC-1。最小修正：S13 verify 增「复跑 VC-1 命令 rc=0」，或 VC-1 增 audits 末轮 kind=report 字段断言。

- 【W-11】plan-state.json goals[G2]/[G3].verify — 原文 G2「VC-7/VC-10」、G3「VC-8/VC-10」；VC-10（逐会话推进证据）属 G1/R4 取证面，与 G3（改进方案）无关。最小修正：G2/G3 去掉 VC-10，仅 G1 保留。

### R2 裁决

- 新增 C=1 / I=2 / W=3；R1 清单 16 closed、1 open（I-3 部分闭环并入 C-2）。
- 0C/0I 未达 → **REJECTED**。

## 最终结论（R2）

status: done
acceptance: 4/4 pass — [1:PASS 17 条逐条闭环状态齐备且各附实测证据 2:PASS 增量新问题 6 条（C-2/I-9/I-10/W-9/W-10/W-11）均带 file:line+最小修正 3:PASS 裁决=REJECTED（新增 1C/2I） 4:PASS evidence 末尾附 audit-add JSON（仅 open/新增）]
files: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (+1/-0); none
evidence: 裁决=REJECTED（R2：新增 C=1 / I=2 / W=3；R1 清单闭环 16/17，I-3 部分闭环）。
  ①R1 闭环：C-1 closed（VC-7 改判 defect 前缀 CONFIRMED/REFUTED + process[60:61] + H1-H5 全覆盖，实跑 rc=1）；I-1 closed（VC-3 seven 文件绝对路径逐一覆盖 + parse_bad≤5%，磁盘实测恰 7 文件，rc=2）；I-2 closed（VC-4 增 mentions/definitions/used，rc=2）；I-3 open（used/SESSION-EVID/VC-10 已入 plan-state 与 §K，但 §H:85 未同步 → C-2）；I-4 closed（S3/S4 分文件，FMEA F5）；I-5 closed（parallel 仅 g-ro/无，8 处「前置=Sx」入 actions，depends_on 不支持已登记 D-8）；I-6 closed（10 条 command 管道符 0，实跑 9 条非 0 / VC-9 rc=0，S12 禁视图照抄；残余 I-10）；I-7 closed（VC-7 增 H1-H5 全覆盖）；I-8 closed（S13 + P7=[S12,S13] + [audit-before-delivery] + 0C/0I 门）；W-1..W-8 closed（parse_bad 5%、process 全文 65-78 字、4 锚核心问题、S11 C5、S2 留痕五要素、VC-9 白名单+K13 双源、S4 绝对路径、S6 25min）。
  ②增量新问题：【C-2】plan-brief.md:84-85/92-111/65,67/117 + knowledge-brief.md:82 — 双版本规范：§H 旧 files「11-17..24」与旧 12 字段 totals、§I 旧 9 条含管道符 VC、§F S6「11-17 至 11-24 … 15min」、§J「D-1 窗口自 11-17」均未随 §K/§L 更新，而 S6 材料包仍指向 §H:82-90 → S6 按 §H 汇总必缺 used/sessions_with_calls_main/session_evid_rows，VC-4/VC-10 结构性不可达；修正=§H 整段替换（7 文件/15 字段/SESSION-EVID 与 used-ritual 判据表）、§I 标废止或替换、§F S6·S8 与 §J D-1·D-2 同步；HIGH。【I-9】plan-brief.md:126（K3）— 「每个有调用的主会话写一行」但行格式仅单 `<skill>`，多技能会话按技能多行则 VC-10 等值断言假 FAIL、按会话一行则字段装不下；修正=明确每会话一行+逗号分隔技能，或 VC-10 改 distinct session 覆盖；MED。【I-10】plan-state vcs[VC-2] 与 §L VC-2、task_plan.md:106 — plan-state 用 `^. SP-`（任意单字符前缀）、§L 写 `^[|] SP-`（K6 称逐字采用）、视图仍显示 `\| SP-<name> \|`；照抄视图则 `^. SP-` 不匹配（假 FAIL），`^.` 又会误计「x SP-」行；修正=统一 `^[|] SP-` 并改写 S3 验收措辞；HIGH。【W-9】plan-state.json:501 / task_plan.md:202,166 — core_question.checks 与 S12 标题仍「VC-1..VC-9」。【W-10】vcs[VC-1] — 判据含「报告面审计达标」但命令只读末轮 verdict，S12 先于 S13 复核、S13 后无再复验。【W-11】goals[G2/G3] — VC-10 误挂 G2/G3（属 G1/R4）。
  ③验证摘要：实跑 10 条 VC（rc=1/2/2/2/2/2/1/2/0/2）；command 管道符计数 0；planctl validate/vc-nonvacuous(10 条)/rvc(R4/VC10) 全 PASS；磁盘日志恰 7 文件（无 11-17）；s_units parallel 实测 13 条仅 g-ro/无；phases[P7]=[S12,S13]；root_causes process 长度 65-78。负结果：C1-C7 仍无违反；R1-R4 逐字未变；S3/S4 拆文件后无并发同写；VC-9 改后仍为不变量检查（设计如此，非漏报）。
  [{"key":"C-2","severity":"C","state":"open"},{"key":"I-3","severity":"I","state":"open"},{"key":"I-9","severity":"I","state":"open"},{"key":"I-10","severity":"I","state":"open"},{"key":"W-9","severity":"W","state":"open"},{"key":"W-10","severity":"W","state":"open"},{"key":"W-11","severity":"W","state":"open"}]
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

## R3 简版再审（2026-11-24T05:05+08:00，只核 R2 未闭环 7 条 + 本次增量）

### 里程碑

- 2026-11-24T05:00+08:00 读 v2 任务书（`grep '^## ' plan-brief.md` = §A/§B/§C/§D/§E/§F/§G/§H/§I/§J/§K，无 §L）与 plan-state.json 增量（vcs/goals/s_units/decisions/core_question）。
- 2026-11-24T05:02+08:00 实跑 10 条 VC：VC-1 rc=1、VC-2..VC-6 rc=2、VC-7 rc=1、VC-8 rc=2、VC-9 rc=0、VC-10 rc=2；plan-state.json `grep -c 'VC-1\.\.VC-9\|VC-1\.\.9'` = 0。
- 2026-11-24T05:03+08:00 正则字符类实测：`printf '| SP-x | a |\nx SP-y\n\\| SP-z\n' | grep -c '^[|] SP-'` → 1（仅首行命中）；`printf '\\| SP-z\n' | grep -c '^[|] SP-'` → 0。
- 2026-11-24T05:04+08:00 planctl validate PASS / vc-nonvacuous PASS（10 条）/ rvc PASS（R=4 VC=10）。

### R2 未闭环 7 条

| key | 状态 | 证据 |
|---|---|---|
| C-2 | closed | plan-brief.md 仅 §A-§K 十一段（无 §L）；§H:84-102 为 v2 单一结构（files 七文件、totals 15 字段、SESSION-EVID 行格式、used/ritual 判据表）；§F S6「11-18 至 11-24 全部日志文件」、S8「11-18 起」；§J D-1「可取证窗口 11-18..11-24（11-16、11-17 日志已不在磁盘）」；§I 含 `^- **VC-` 计数 10 且字符类外竖线 0；§K 首行「仅留痕，规范以正文为准」 |
| I-3 | closed | §H 明确定义 `sessions_main_with_sp_used`/`_os_used`、`sessions_with_calls_main`、`session_evid_rows` 与 SESSION-EVID 行格式及 used/ritual 判据表；VC-4（13 字段）、VC-10（等值）消费之，实跑均 rc=2（改前 FAIL） |
| I-9 | closed | §H：「每个有 Skill 调用的主会话**恰好一行**：`SESSION-EVID <session_id> <used/ritual> <技能清单，逗号分隔，形如 SP:brainstorming,OS:openspec-propose> <证据锚>`」+「`session_evid_rows`：SESSION-EVID 行数。二者必须相等」— 行粒度与计数口径已闭合 |
| I-10 | closed | plan-state.json vcs[VC-2].command 与 §I VC-2 均为 `^[|] SP-` / `^[|] OS-`；字符类语义实测正确（`| SP-x`→1、`\| SP-z`→0）；S3 verify 无竖线字符（「第一列为技能标识 SP-<name>…（该行以竖线、空格再接 SP- 或 OS- 开头）」）；D-10 改「竖线只允许出现在正则字符类内」。残余（W 级、未立项）：执行体若手写 `\| SP-` 前缀仍不计数，但验收文本已不再给出该形式 |
| W-9 | closed | plan-state.json 中 `VC-1..VC-9`/`VC-1..9` 命中 0；S12 name/verify = VC-2..VC-10；core_question.checks =「VC-1..VC-10 全 PASS」。残余文字见 W-12 |
| W-10 | closed | vcs[VC-1].criterion 增「在 S13 登记之后由主进程复跑」；S12 verify 范围为 VC-2..VC-10；S13 verify「主进程登记审计后复跑 VC-1 与 VC-8（rc=0）才可交付」 |
| W-11 | closed | goals：G1 verify = VC-2/3/4/5/6/10，G2 = VC-7，G3 = VC-8（VC-10 仅挂 G1） |

### 本次增量核验（S8 执行体变更）

- S8 `executor=general-analyst(sonnet-1)`（plan-state s_units[S8]）；D-11 登记理由「Explore 为只读搜索体（工具面无 Write 与 Edit），无法落盘 T/report-plans.txt 与检查点」；brief §F S8 行同步 general-analyst。变更合理，无新风险（S8 仍只写 T/）。
- 残余：S8 `actions` 仍写「清点 11-17 起」，与 name/verify「11-18 起」及 task_plan.md:129 不一致 → 立项 W-13。

### R3 新增问题（续号）

- 【W-12】plan-state.json s_units[S12].actions 与 task_plan.md:166 — 原文「逐条复验 VC-1..VC-10」与同 unit verify「VC-2..VC-10 逐条复验」冲突；audits 当前为空，实测 VC-1 rc=1，若 S12 照 actions 执行会把 VC-1 当交付前必备项而误判失败。最小修正：actions 改「VC-2..VC-10（VC-1 与 VC-8 由 S13 后主进程复跑）」。置信度 MED。
- 【W-13】plan-state.json s_units[S8].actions 与 task_plan.md:129 — 原文「清点 11-17 起各 plans/ 与 archive/ 的 SP/OS 痕迹」，与 name/verify「11-18 起」冲突（11-17 无日志，D-1 已限定 11-18..24）。最小修正：actions 改「11-18 起」。置信度 HIGH。

### R3 裁决

- 新增 C=0、I=0、W=2；R2 未闭环 7 条全部 closed（含残余说明）→ **APPROVED**（WARNING 留档不阻断）。

## 最终结论（R3）

status: done
acceptance: 4/4 pass — [1:PASS 7 条逐条闭环状态齐备且各附实测/原文证据 2:PASS 本次增量（S8 执行体 → general-analyst + D-11）核验通过，新增 2 项 W（W-12/W-13） 3:PASS 裁决=APPROVED（新增 0C/0I） 4:PASS evidence 末尾附 audit-add JSON（仅 open/新增：W-12、W-13）]
files: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (+1/-0，追加 R3 段); none
evidence: 裁决=APPROVED（R3：新增 C=0 / I=0 / W=2；R2 未闭环 7/7 closed）。
  ①7 条闭环：C-2 closed（plan-brief.md 仅 §A-§K、无 §L；§H:84-102 = files 七文件 + totals 15 字段 + SESSION-EVID 行 + used/ritual 判据表；§F S6「11-18 至 11-24」、S8「11-18 起」；§J D-1「11-18..11-24」；§I 10 条 VC 且字符类外竖线 0；§K「仅留痕，规范以正文为准」）；I-3 closed（§H 定义 used 字段/sessions_with_calls_main/session_evid_rows，VC-4/VC-10 消费，实跑 rc=2）；I-9 closed（§H「每个有 Skill 调用的主会话恰好一行…技能清单逗号分隔」+「session_evid_rows：SESSION-EVID 行数。二者必须相等」）；I-10 closed（plan-state 与 §I 均 `^[|] SP-`/`^[|] OS-`，实测 `| SP-x`→1、`\| SP-z`→0；S3 verify 无竖线；D-10 限定竖线只在正则字符类内）；W-9 closed（`VC-1..VC-9|VC-1..9` 命中 0；S12=VC-2..VC-10；core_question=VC-1..VC-10）；W-10 closed（VC-1 判据「S13 登记之后由主进程复跑」；S12 范围 VC-2..VC-10；S13 验收含复跑 VC-1/VC-8 rc=0）；W-11 closed（G1 含 VC-10、G2=VC-7、G3=VC-8）。
  ②增量：S8 executor=general-analyst(sonnet-1)，D-11 登记「Explore 无 Write/Edit 无法落盘」，brief §F 同步 — 变更合理。【W-12】plan-state s_units[S12].actions / task_plan.md:166 — 原文「逐条复验 VC-1..VC-10」与 verify「VC-2..VC-10」冲突；audits 为空时 VC-1 实测 rc=1，照 actions 执行会误判 S12 失败；修正=actions 改「VC-2..VC-10（VC-1/VC-8 由 S13 后主进程复跑）」；MED。【W-13】plan-state s_units[S8].actions / task_plan.md:129 — 原文「清点 11-17 起」与 name/verify「11-18 起」及 D-1 冲突；修正=改「11-18 起」；HIGH。
  ③验证摘要：实跑 10 条 VC（rc=1/2/2/2/2/2/1/2/0/2）；planctl validate PASS、vc-nonvacuous PASS（10 条）、rvc PASS（R=4 VC=10）；字符类正则两向实测（命中 1 / 转义形式 0）；plan-brief 段落清单 11 段无 §L；§I VC 计数 10、字符类外竖线 0。负结果：C1-C7 无违反；R1-R4 逐字未变；P7=[S12,S13] 与 VC-1/VC-8 复跑时序自洽，无新增循环；VC 判别力未被降低（10 条改前仍全部非 0，VC-9 为设计不变量）。
  [{"key":"W-12","severity":"W","state":"open"},{"key":"W-13","severity":"W","state":"open"}]
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH

---

## R4 增量再审（第 4 轮，只审 v3 增量 + R3 遗留闭环；快照 plan-state.json sha=816a1966b5077d36 mtime=05:17）

> 只读审计：本条仅追加，R1-R3 原文未改。审计对象=v3 重拆（S1-S20）、VC-1 加固、VC-2/6/8 新产物名、D-11/D-12/D-13、W-12/W-13 闭环、全局不变量。计划为活文件（主进程并发写 drift-check.md@05:29/writes.txt@05:30），本段以 05:17 的 plan-state 快照为准。

### 实跑证据（全部命令实测，不写结论式声称）

- 10 条 VC 逐条 `bash -c` 实跑 rc：VC-1=1、VC-2=2、VC-3=2、VC-4=2、VC-5=2、VC-6=2、VC-7=1、VC-8=2、VC-9=0、VC-10=2（改前非 0；VC-9 为设计不变量，rc=0 属预期）。
- `planctl.py validate` → `VALIDATE PASS` rc=0；`check vc-nonvacuous` → `PASS 10 条 VC 命令均有判定力` rc=0；`check rvc` → `PASS R=4 VC=10 双向覆盖完整` rc=0。
- `check-plan-dispatch.sh PD/task_plan.md` → rc=0，`✗` 行计数=**0**；另有一行 `SKIPPED Phase 7 S20 输入 5 个文件路径 > step_max_files(2) — 建议拆分(提示不阻断)`（对 S20 审计单元的**输入**文件计数的软提示，非粒度三值违规：S20 granularity=0f 硬检通过）。
- command/criterion 与 §I 逐字比对：10/10 command VERBATIM-MATCH，10/10 criterion CRIT-VERBATIM；竖线仅出现在 VC-2 的两处 `^[|]` 字符类内（偏移 19、131），字符类外裸竖线=0。
- §F 表行 vs s_units 程序比对：20/20 行 phase/executor/duration/granularity 全等（MISMATCHES=none；state∩brief 无缺无余）。
- 粒度三值：20 单元逐一解析 `Nf/Nl/Nmin`，files≤2、lines≤100、dur≤15 **全部达标，0 违规**（S1=2f/80l、S3-S6/S11-S14=1f/100l/15min、S10=1f/40l/12min、S12=1f/60l/15min、S2/S17/S18/S20=0f）。
- 前置依赖：「前置=Sx」文本 11/11 与 §F 依赖表一致（S8←S7、S9←S8、S10←S9、S13←S3,S4,S5,S6、S14←S10,S13、S15←S13,S14、S16←S15、S17←S16、S18←S17、S19←S18、S20←S19）。
- VC-1 加固正反样本实测：前缀实测长度=**47**（`[audit-before-delivery] verdict=APPROVED round=`）；`[0:48]` 对应 1 位轮次（47+1）、`[0:49]` 对应 2 位轮次（47+2）。合成样本实跑：报告面已登记 round=3→rc=0；两位数 round=12→rc=0；末轮 REJECTED→rc=1；登记轮次(2)≠末轮(3)→rc=1；当前真实计划（audits[-1]=R3 APPROVED）→**rc=1**（符合「不得因末轮 APPROVED 就判 VC-1 应通过」）。S20.verify 已同步「登记留痕 + 复跑 VC-1/VC-8 rc=0 才可交付」；D-13 已登记；actions A11 已留痕。
- D-11 一致性：`/home/terry/.zcode/agents/explore.md` 为「只读代码搜索」，常用工具 Glob/Grep/Read、禁止行为「不修改代码/不执行 Bash/不调用 Skill」；`general-analyst.md` model=custom:…sonnet-1 且有 Write/Edit——D-11「Explore 无 Write/Edit 无法落盘」与实测一致。
- 全局不变量：R1-R4 与 `user-session-log.md:43` 子串精确匹配 4/4；G1.verify=VC-2/VC-3/VC-4/VC-5/VC-6/VC-10、G2=VC-7、G3=VC-8，无 VC-10 误挂；audits=[R1 REJECTED 1/8/8, R2 REJECTED 1/3/3, R3 APPROVED 0/0/2]，末轮非报告面，VC-1 实测 rc=1（正确）。
- 负结果（检查但未发现问题，不立 W）：①g-ro 并发组 S3/S4/S5/S6/S7/S11/S12 产物两两不同，**无并发同写**；scan-stats.json 由 S8 创建→S9 回写 totals→S10 写 recheck，为顺序依赖（S9←S8、S10←S9）且 §H 明确设计，非缺陷。②VC-9 rc=0，writes.txt 全 5 条路径均存在（drift-check.md 于 05:29 生成，非幽灵记录）。③state/task_plan 无「S12 终验 / S13 报告审计」旧编号残留。④T/ 下产物当前不存在=改前 FAIL 设计预期，不判缺陷。⑤phases[] JSON 无 executor 键，但 planctl 由 s_units 派生并在 task_plan.md:91-159 渲染 `- **Executor:**`，§G.2「phases 含 Executor」在渲染面满足。

### R3 遗留闭环

- **W-12 → closed**：v3 终验单元 S18 verify=「VC-2..VC-10 逐条复验」，s_units 的 actions/verify 内已无「VC-1..VC-10」（全库「VC-1..VC-10」仅存于 core_question.checks 全局行「VC-1..VC-10 全 PASS 为准」及 A2 历史文本，均非单元 action/verify 冲突；grep 实测）。证据：plan-state.json:875（S18.verify）、task_plan.md:172。
- **W-13 → closed**：v3 计划侧证单元 S11 actions=「11-18 起 `REPO/plans/` 与 `REPO/plans/archive/`…」，task_plan.md:132 同步；「11-17」仅存于 D-1「11-16、11-17 日志已不在磁盘」的正确上下文（plan-state.json:960）。证据：plan-state.json s_units[S11].actions、task_plan.md:132。

### R4 新增问题

- 【R4-W-1】plan-state.json:1321 与 :1333（`"id": "A2"` 两处）— actions 数组存在**两条完全相同的 A2**（text/at 一致，`unique` 去重后仅 1 条）。重复行动记录污染留痕、A2 编号不再唯一，易误导后续「修复对照」指向。最小修正：删除重复的一条 A2（保留早期那条并可在 text 前缀 `[R2 历史]` 标注其为 v2 期记录）。置信度 HIGH。
- 【R4-W-2】plan-state.json:123（VC-1 command 的 `.text[0:48]`/`.text[0:49]`）— 切片仅覆盖 1-2 位轮次；三位数轮次（round≥100，前缀+3 位=50 字符）两个子句都不匹配 → 假阴性（合成 round=123→rc=1）。实际不可达（审计轮次单调递增、报告面审计轮次通常 <100），故仅留档。最小修正（可选）：改用 startswith 并断言其后为空格/结束，或按 `$r` 位数动态切片。置信度 LOW。

### R4 裁决

- 新增 C=0、I=0、W=2（R4-W-1、R4-W-2）；R3 遗留 W-12/W-13 **2/2 closed** → **APPROVED**（WARNING 留档不阻断）。

## 最终结论（R4）

status: done
acceptance: 4/4 pass — [1:PASS v3 重拆 20 单元：粒度三值 20/20 达标、check-plan-dispatch ✗=0、无并发同写、前置依赖 11/11 对齐、主进程例外 4/4 已登记 2:PASS VC-2/6/8 新产物名逐字对齐 §I + 字符类外裸竖线 0 + 改前 rc≠0（2/2/2） 3:PASS VC-1 加固五组样本实测与判据语义一致、切片 [0:48]/[0:49] 对应 1/2 位轮次、S20.verify/D-13/A11 同步 4:PASS D-11/D-12 与实测一致、W-12/W-13 闭环且 R1-R4 逐字不变、全局映射无误挂、VC-1 未因末轮 APPROVED 误判通过]
files: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (+追加 R4 段 / -0，R1-R3 原文未改); none
evidence: 裁决=APPROVED（R4：新增 C=0 / I=0 / W=2；R3 遗留 2/2 closed）。
  ①增量核验：v3 20 单元 §F↔state 20/20 全等；粒度 0 违规；deps 11/11；dispatch ✗=0；VC 命令/判据 10/10 逐字；VC-2/6/8 改前 rc=2/2/2 具判别力。【R4-W-1】plan-state.json:1321/1333 重复 A2，HIGH。【R4-W-2】plan-state.json:123 VC-1 三位数轮次切片假阴性，不可达，LOW。
  ②VC-1 加固：【判据⇔命令一致】末轮 APPROVED + 留痕轮次一致；前缀 47，[0:48]=1 位、[0:49]=2 位；【实测】报告已登记 rc=0、两位数轮次 rc=0、末轮驳回 rc=1、登记≠末轮 rc=1、真实计划 rc=1；【S20.verify 同步】「登记留痕 + 复跑 VC-1/VC-8 rc=0」；D-13 登记；A11 留痕。
  ③验证摘要：实跑 10 VC rc=1/2/2/2/2/2/1/2/0/2；planctl validate PASS、vc-nonvacuous PASS(10)、rvc PASS(R=4 VC=10)；dispatch rc=0/✗=0（1 行 S20 输入软 SKIPPED）；字符类外裸竖线 0；D-11 对 Explore 只读定义实测一致；G1/G2/G3 verify 映射无 VC-10 误挂；audits[-1]=R3 APPROVED(0/0/2) 且 VC-1 rc=1 未误判通过。负结果：g-ro 无并发同写、scan-stats.json 顺序分阶段=§H 设计非缺陷；VC-9 rc=0 且 writes.txt 5 条路径均存在；无旧编号残留；T/ 产物缺失=改前 FAIL 预期；phases Executor 渲染面满足。
  [{"key":"R4-W-1","severity":"W","state":"open"},{"key":"R4-W-2","severity":"W","state":"open"}]
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/subagent-state/2-critic.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
