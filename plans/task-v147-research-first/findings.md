# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 解决问题=唯一不变目标，压制推诿与不作为 → Rule 63.1 目标公理 + 63.3 反推诿禁令
- R2 主动检索资料=首要信息源；网络权限→信息面基本无限制 → Rule 63.2 检索优先（四步检索链）
- R3 禁止未检索就说「不知道」；唯一边界=用户私人数据 → Rule 63.3（「不知道」持证上岗）
- R4 有理有据，禁止胡编乱造；真无解→带证据诚实报告 → Rule 63.4 有理有据边界
- R5 充分利用网络资源，「网络上什么都有」 → Rule 63.2 依据段

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules.md Rule 60/22.3.0/35/41/54/58 | skills/task-planner/references/critical-rules.md（master e54973d） | ☑ | §衔接面定位 |
| SKILL.md 联动锚点 | skills/task-planner/SKILL.md :9/:275/:346 + C43 尾 | ☑ | §SKILL 联动文案 |
| subagent_dispatch.md §2 契约结构 | skills/task-planner/templates/subagent_dispatch.md :22-44 | ☑ | §SKILL 联动文案 |
| FF-16 负断言 | scripts/selftest-four-file-dataflow.sh :27/:108 | ☑ | §守卫级联面 |

## Research Findings

### 衔接面定位（既有规则分工第一手结论）
- Rule 60（:680-714）：只管「遇障碍枚举替代方案」（执行受阻面），无检索优先语义；其 60.8 自述「机器面=无，纯行为约束」。
- 22.3.0（:166）：只管「失败 ≥2 次后的换道检索」（事后换道），非第一反应。
- Rule 35.2：管能力否定查证（「没找到」≠「不存在」），无检索义务本体。
- Rule 58：管调研类任务证据面完备性，适用面不含一般任务知识缺口。
- **结论：知识缺口场景（不知道→应检索）在现行规则体系为空白，用户指出的缺陷成立**。新规则 63 定位=公理层（63.1）+检索义务（63.2/63.3）+证据边界（63.4），触发面与上述规则互补（63.5 引用不重述）。

### Rule 63 条款草案（S1 落地锚——逐字照抄，落地时仅允许调整空白）

```markdown
<!-- Rule 63 (task-v147 2026-10-08): 纯增量新增；判例=用户 2026-10-08 会话原话 R1-R5（逐字抄录于 plans/task-v147-research-first/task_plan.md「🎯 用户需求原文」区块，51.1 口径）——「不知道的事情去网上查，不清楚的事情去网络上查」「所有的事情都需要有理有据」「网络上什么都有」 -->

### 63 检索优先与反推诿纪律（P0 — task-v147，目标：把「解决问题」立为唯一不变目标——遇到不知道/不清楚的事实第一反应=主动检索资料而非以「不知道」作答；联网检索=首要信息源（网络访问权限→可获取信息面基本无限制，唯一边界=用户私人数据）；一切结论有理有据，禁止胡编乱造，查证后确实无解的以证据诚实收场；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 7/22.3.0/35/41/54/58/60，既有 Rules 原文零改动）

本条源于用户 2026-10-08 反馈：agent 遇到不知道的事实/报错/用法时以「不知道」「无法确定」作答收场而不去检索——agent 拥有网络访问权限，可获取的资料面基本无限制（唯一边界=用户私人数据），未经检索的「不知道」= 推诿而非事实陈述（R3「这都是推诿的」）。用户同轮划定边界（R4）：不是要求胡编乱造，而是所有解决必须有理有据——检索有源、结论有锚；查证后确实无解的问题以证据诚实收场，编造比「不知道」更严重。

63.1 **目标公理（problem-solving axiom，对应 R1）**：技能存在的唯一不变目标 = 解决用户的问题；流程、门控、规则、模板全部是解决问题的手段而非目的，任何环节的产出以「是否让问题更接近解决」为判据。推诿（把本可消解的问题原样退回用户/以「不知道」收场/空转等待）与不作为 = 违规——与 Rule 41.3（消解优先）同源，本条把「解决问题」从隐含前提升格为显式公理，作为一切条款的消费总纲。

63.2 **检索优先（research-first mandate，对应 R2/R5）**：遇到不知道/不清楚/不确定/没听说过的事实、报错、API、工具用法、领域知识时，**第一反应 = 主动检索资料**，禁止以「不知道/不清楚」作为最终答复。检索链按序穷尽（宪法 §七 链路，引用不重述）：① 本地（代码库 Grep/Read、memory、knowledge-brief §2、既有 capability 脚本 Rule 55）→ ② 工具自带帮助面（--help/man 全文，22.3.0 第一步）→ ③ 官方文档与网络搜索（WebSearch / Doc Search Agent / research-assistant 多源）→ ④ 社区经验（Forum Search Agent / GitHub issues/PR）。依据（R5「网络上什么都有」）：agent 拥有网络访问权限，可获取信息面基本无限制；唯一边界 = 用户私人数据与未授权凭据——此类禁止检索并按隐私保护处理，其余数据默认「可查到，先查再说」。

63.3 **反推诿禁令（anti-deferral ban，对应 R3）**：「不知道/无法确定/超出知识范围/查不到」在**穷尽 63.2 检索链并附检索证据**之前，禁止作为最终答复、任务结论或阻塞上报内容出现。上报「不知道/未解决」的最小合法形态 = 「已检索 A/B/C（附证据锚）→ 仍无法确定 X → 建议下一步 Y」；缺失检索证据的「不知道」= 摆烂上报（Rule 6/22.7.1/60.5 同口径），按 Rule 26.3 处置。What=「不知道」从合法终答降级为须持证上岗的受检陈述；Why=R3「不要告诉我不知道这个不知道那个的」——网络权限下信息面近乎无限制，未检索的「不知道」几乎必然是推诿而非事实。

63.4 **有理有据边界（evidence boundary，禁胡编乱造，对应 R4）**：检索结论必须附来源锚（URL/文件路径/命令输出，54.5 格式）；检索片段与本地第一手事实冲突时以本地验证为准，未复核的检索内容引用时标注「待验证」（58.3 推测标注适用）。**编造（无来源断言/虚构检索结果/假装已查证）比「不知道」更严重**——按 Rule 26.3 Q3 证据不实最高档处置，无豁免。查证后确实无解（检索链穷尽+证据在案）→ 按 58.5 三态裁决以 not-solved 诚实收场并附已检索清单——「经检索仍无法解决」是合法终态，「未检索就说不知道」与「编造答案」都是违规，后者处罚更重。

63.5 **与既有规则关系（complementary，引用不重述）**：Rule 60 管遇障碍枚举替代方案（执行受阻面），本条管知识缺口检索优先（信息不足面）；22.3.0 管失败 ≥2 次后的换道检索（事后换道），本条把检索前移为第一反应（事前主动）；Rule 35 管能力否定的查证三关（「没找到」≠「不存在」），本条管检索义务本体；Rule 58 管调研类任务的证据面完备性，本条管一切任务的知识缺口即时检索；Rule 41 管升级收敛（不推给用户），本条管信息获取（不摊手不知）。触发面互补，检索工具链定义引用 22.3.0/宪法 §七，零语义重复。

63.6 **机制（零新 config 键 — 与 43.4/54.6/55.6/56.5/57.4/58.7 同范式）**：判定面=LLM 行为（知识缺口出现时自我审查是否已检索、答复前自查「不知道」是否持证）；机器面=`scripts/selftest-research-first.sh` 静态守护（63.1-63.6 子条文本锚 + subagent_dispatch.md §2 检索契约行 + SKILL 摘要行/合规清单 C44 锚 + selftest-four-file-dataflow.sh FF-16 宽容化后前向断言同步 + 零新键声明；只断言新增锚、不触碰既有脚本断言，防锚级联）；消费侧=SKILL.md Critical Rules 摘要 bullet + 合规清单 C44 + `templates/subagent_dispatch.md` §2 检索优先契约行（子代理侧传播——派发执行体同等受本条约束）。
```

### SKILL 联动文案锚（S2 逐字照抄）
1. **:9 行**：`1-62` → `1-63`；列表 `62 四文件罗盘数据流转与调研知识沉淀纪律（61 预留未落地），含 Rule 27` → `62 四文件罗盘数据流转与调研知识沉淀纪律（61 预留未落地）、63 检索优先与反推诿纪律，含 Rule 27`（⚠️ 「（61 预留未落地）」旧括注本次不动——61 已由 v146 落地，该括注属存量 stale 文案，超出本任务 scope，登记交对齐审查复核）
2. **:275 行**：`Critical Rules 1-62（含 Rule 40-62 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化）` → `Critical Rules 1-63（含 Rule 40-63 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化 / Rule 63 检索优先与反推诿纪律）`
3. **Critical Rules bullet 列表尾（Rule 62 bullet 之后）追加**：
```markdown
- **Rule 63（检索优先与反推诿纪律 — task-v147）**：目标公理=解决问题是唯一不变目标，推诿/不作为=违规（63.1）；检索优先=遇到不知道第一反应主动检索，四步链（本地→帮助面→官方文档/网络→社区），联网检索=首要信息源（网络权限→信息面基本无限制，用户私人数据除外）（63.2）；反推诿禁令=「不知道」穷尽检索链并附证据前禁止作答，合法形态=已检索清单+证据锚+下一步（63.3）；有理有据边界=结论附来源锚、禁编造（Q3 最高档）、查证无解按 58.5 三态诚实收场（63.4）；与 Rule 60/22.3.0/35/41/58 触发面互补（63.5）；机制=零新 config 键+selftest-research-first.sh 守护+派发模板契约行（63.6）（详见 references/critical-rules.md Rule 63）
```
4. **:346 References 表行**：`Critical Rules 1-62（` → `Critical Rules 1-63（`；尾部 `Rule 62 四文件罗盘数据流转与调研知识沉淀纪律）` → `Rule 62 四文件罗盘数据流转与调研知识沉淀纪律 / Rule 63 检索优先与反推诿纪律）`
5. **合规清单 C43 行后追加 C44**：
```markdown
| C44 | 检索优先与反推诿自查（Rule 63）：任务中出现「不知道/不清楚/无法确定」类判断前已按 63.2 四步检索链（本地→帮助面→官方文档/网络→社区）穷尽检索并附来源锚（63.2/63.4）；「不知道/未解决」类上报已取「已检索清单+证据锚+下一步建议」合法形态（63.3）；无来源断言/虚构检索结果零容忍（63.4，Rule 26 Q3 最高档）；本任务无知识缺口场景时登记豁免一行（机器面=selftest-research-first.sh 静态断言，检索过程人工核查；mini 档豁免） | ☐ |
```
6. **仓根 CHANGELOG.md [Unreleased]/新增 列表头部追加**：
```markdown
- **Rule 63 检索优先与反推诿纪律（task-v147）** — 目标公理（解决问题=唯一不变目标，推诿/不作为=违规，63.1）+ 检索优先（不知道第一反应四步检索链：本地→帮助面→官方文档/网络→社区；联网检索=首要信息源，网络权限→信息面基本无限制，用户私人数据除外，63.2）+ 反推诿禁令（「不知道」穷尽检索链并附证据前禁止作答，63.3）+ 有理有据边界（结论附来源锚、禁编造、查证无解按 58.5 三态诚实收场，63.4）；SKILL.md 三处计数 1-62→1-63+摘要 bullet+合规清单 C44；templates/subagent_dispatch.md §2 检索优先契约行（子代理侧传播）；selftest-four-file-dataflow.sh FF-16 负断言宽容化 `^63\.`→`^64\.`（锚演进，v121/v146 先例）；新增 scripts/selftest-research-first.sh 守护；零新 config 键
```

### subagent_dispatch.md §2 检索契约行（S3 逐字照抄，插入点=knowledge-brief 行（:26）之后）
```markdown
- 检索优先契约（Rule 63，task-v147）：任务中遇到不知道/不清楚的事实、报错、API 用法 → 第一反应检索资料（①本地 ②--help/man ③官方文档/网络搜索 ④社区），检索结论必须附来源锚；**穷尽检索前禁止以「不知道/无法确定」作答**；查证后仍无法解决 → 如实写 blockers 并附已检索清单，**禁止编造检索结果**（编造=Rule 26 Q3 最高档违规）
```

### RF 断言清单（S5 selftest-research-first.sh 设计锚）
| ID | 断言 | 目标 |
|----|------|------|
| RF-01 | `^### 63 检索优先与反推诿纪律` 计数=1 | critical-rules.md |
| RF-02 | `^63\.[1-6] ` 计数=6 | critical-rules.md |
| RF-03 | 63 块内含「目标公理」「检索优先」「反推诿禁令」「有理有据」四词各 ≥1 | critical-rules.md |
| RF-04 | 63.2 块含四步链语义词（「本地」「帮助面」「官方文档」「社区」）各 ≥1 | critical-rules.md |
| RF-05 | 63.4 块含「编造」≥1 且「not-solved」≥1 | critical-rules.md |
| RF-06 | SKILL.md `1-63` 计数 ≥3 | SKILL.md |
| RF-07 | SKILL.md 双锚：`Rule 63（检索优先与反推诿纪律`（全角括号）≥1（bullet 行）∧ `Critical Rules 1-63（含 Rule 40-63 全集` ≥1（头注行，其内规则名带空格非全角括号——[2026-10-08 主进程修正：原单模式 ≥2 系过度指定，致 S2 误判 AC2 FAIL 与 S5 空转]） | SKILL.md |
| RF-08 | SKILL.md `C44` 行含 `Rule 63` 同行命中 ≥1 | SKILL.md |
| RF-09 | subagent_dispatch.md `Rule 63` ≥1 且「禁止编造」≥1 | subagent_dispatch.md |
| RF-10 | selftest-four-file-dataflow.sh 含 `\^64\\.\[0-9\]` 断言（宽容化后）且不含 `\^63\\.\[0-9\]` 负断言残留 | 守卫级联 |
| RF-11 | selftest-registry.tsv 含 `selftest-research-first.sh` 行 | registry |
| RF-12 | config.json 无 `research_first`/`research-first` 键（零新键） | config.json |

#### [sub:1-executor] S1 落地回执

**目标**：critical-rules.md 文件末尾追加 Rule 63 全六子条（逐字照抄草案，纯增量，零删改既有内容）。

**执行**：
- 插入点=文件末尾（原第 766 行 59.8 之后），追加空行 + 头注 HTML 注释行 + `### 63 ...` 段落（63.1-63.6 全六子条）
- 条款文本来源=findings.md §「Rule 63 条款草案」```markdown 围栏内第 36-52 行（不含围栏本身），逐字照抄

**验证**：
- `grep -cE '^63\.[1-6] '` = 6 — PASS
- `grep -c '^### 63 '` = 1 — PASS
- `git diff -- critical-rules.md` 显示纯追加（仅 `+` 行，无 `-` 行删除/修改）— PASS
- `diff`（findings 草案第 36-52 行 vs 实际追加内容）= 逐字一致（VERBATIM_MATCH_OK）— PASS
- 文件末尾换行符确认（`tail -c 1 | xxd` = `0a`）— PASS

**结论**：S1 验收标准 4/4 全部 PASS。

#### [sub:2-executor] S2 落地回执

**任务**：worktree 内 SKILL.md 四处联动（三处计数 1-62→1-63、Critical Rules 列表追加 Rule 63 摘要 bullet、合规清单追加 C44）+ 仓根 CHANGELOG.md 新增条目

**验收结果**：
- AC1: PASS — `grep -c '1-63' SKILL.md` = 3，`grep -c '1-62' SKILL.md` = 0
- AC2: FAIL — `grep -c 'Rule 63（检索优先与反推诿纪律' SKILL.md` = 1（要求 >=2）
- AC3: PASS — C44 行含 Rule 63（:213）
- AC4: PASS — CHANGELOG 首条为 Rule 63（:12）
- AC5: PASS — git diff 仅 SKILL.md（6+/3-）和 CHANGELOG.md（1+）

**Blocker**：AC2 未通过。findings.md 的六条联动文案锚中没有关于 SKILL.md "头注"的说明。RF-07 验收标准提到"bullet+头注"，但 findings.md 中唯一的"头注"出现在第 98 行，指的是 critical-rules.md 的 HTML 注释行，不是 SKILL.md 的内容。

**已检索**：
- `grep -n 'Rule 63（' SKILL.md` → 仅 :324（bullet 行）
- `grep -n 'Rule 63' SKILL.md` → :213（C44）、:276（头注行，但格式为 `Rule 63 检索优先与反推诿纪律` 无左括号）、:324（bullet）、:348（References 表，无左括号）
- `grep -n '头注' findings.md` → :86（RF-07 描述）、:98（critical-rules.md HTML 注释行）

**证据**：
- SKILL.md:9 — `1-63` 计数
- SKILL.md:276 — `Critical Rules 1-63（含 Rule 40-63 全集...Rule 63 检索优先与反推诿纪律）`
- SKILL.md:324 — `- **Rule 63（检索优先与反推诿纪律 — task-v147）**：...`
- SKILL.md:213 — `| C44 | 检索优先与反推诿自查（Rule 63）：...`
- SKILL.md:348 — `Critical Rules 1-63（含...Rule 63 检索优先与反推诿纪律）`
- CHANGELOG.md:12 — `- **Rule 63 检索优先与反推诿纪律（task-v147）** — ...`

#### [sub:3-code-assistant] S3 落地回执（主进程兜底回填）
- status done；subagent_dispatch.md :27 单行插入「检索优先契约（Rule 63，task-v147）」（+1/-0）；§2 既有四契约行逐字未动；子代理未自写 findings（回执由 checkpoint 3-code-assistant.md 承载），按 22.4a B-2 兜底条款由主进程补记本节
- 证据：checkpoint T5 8 字段 + git diff +1/-0 + 主进程 grep 复验（Rule 63 ×1 且含「禁止编造」）

#### [sub:5-executor] S5 落地回执（主进程接管，22.3⑤）
- 两轮 executor 派发零产出（attempt1=RF-07 规格歧义推理空转；attempt2=脚本全文停留回复文本未调 Write）→ Rule 7 两败换道 → 主进程接管编写
- 调试记录：①子块提取 `awk /{f=1;next}/` 的 next 臂跳过 63.2/63.4 行自身致子块恒空（FF 参照脚本块尾提取无 next，属移植引入缺陷）②quart() 定义置于首次调用之后（bash 运行时序）——均修复后 12 PASS=12 FAIL=0
- 教训（→ notepad）：断言规格中的 grep 模式必须与目标文本实态逐字核对（本任务三处过度指定：S2 AC2、RF-07、均由主进程草拟时凭意图而非实态书写）
#### [sub:10-executor] 守卫锚级联宽化回执

**目标**：6 个 selftest 脚本的 `Critical Rules 1-62` / `1-62` / `Rule 40-62 全集` 锚演进为 `1-63` / `40-63 全集`（纯机械字面替换+注释追加，不改断言语义结构）。

**执行**：
- selftest-lane-advancement.sh（LA-12，:122-130）：注释+断言+ok/bad 文案 `1-62`→`1-63`；追加 task-v147 演进注
- selftest-requirement-coverage.sh（RC-11，:118-129）：同上
- selftest-self-resolution.sh（SR-07，:11-12/:68-71）：同上（两区域）
- selftest-tool-selection.sh（TS-05，:9-10/:55-58）：同上（两区域）
- selftest-workflow-orchestration.sh（WF-10，:8-13/:59-67）：族求和双模式 `1-62`→`1-63`；阈值 >=3 不变；ok/bad 文案同步
- selftest-drift-check-subagent.sh（DCS-11，:55-56）：`Rule 40-62 全集`→`Rule 40-63 全集`；Rule 61 两锚不变

**验证**：
- 6 脚本各跑一遍全绿：LA-12 14/14、RC-11 23/23、SR-07 13/13、TS-05 12/12、WF-10 16/16、DCS-11 20/20
- `bash selftest-research-first.sh` → Total: 12 PASS=12 FAIL=0
- `git diff --stat` → 6 files changed, 34 insertions(+), 25 deletions(-)，仅上述 6 文件

**结论**：验收标准 3/3 全部 PASS。

#### [sub:11-executor] 第二世代锚演进回执

**目标**：Rule 64（task-v148）合入后，SKILL.md 计数锚 1-63→1-64、Rule 40-63 全集→40-64 全集、Rule 64 bullet 追加；六守卫脚本字面锚 1-63→1-64；四尾部负断言 ^64\.→^65\.；守护脚本 RF-06/07/10 演进。纯机械字面替换+演进注释追加。

**执行**：
- SKILL.md 四处：:9 索引行/:277 头注/:325 后 Rule 64 bullet 追加/:349 References 表行
- 六守卫脚本：lane-advancement(LA-12)/requirement-coverage(RC-11)/self-resolution(SR-07)/tool-selection(TS-05)/workflow-orchestration(WF-10)/drift-check-subagent(DCS-11) 各追加第二代级联注
- 四尾部负断言：four-file-dataflow(FF-16)/evidence-goal-gate(EG-16)/iteration-persistence(IP-14)/requirement-coverage(RC-15) 各追加第二代级联注
- 守护脚本：RF-06 `1-63`→`1-64`；RF-07 `Critical Rules 1-63（含 Rule 40-63 全集`→`Critical Rules 1-64（含 Rule 40-64 全集`；RF-10 `'^64\.[0-9] '`→`'^65\.[0-9] '` 且残留 `'^63\.[0-9] '`→`'^64\.[0-9] '`

**验证**：
- 全量回归 ΣPASS=931 ΣFAIL=4（FAIL 全部来自 selftest-periodic-review.sh 基线预存）
- selftest-research-first.sh → 12 PASS=12 FAIL=0
- selftest-drift-enforcement.sh → 23 PASS=23 FAIL=0（v148 新脚本全绿）
- git diff --stat → 11 files changed, 60 insertions(+), 48 deletions(-)
- 残留扫描：无额外锚演进点（所有命中都是历史演进注或宽容正则）

**结论**：验收标准 4/4 全部 PASS。

#### [sub:9-alignment-b] 对齐审查回执（模板/日志面）

**结论**：CHANGES_REQUESTED（P1×1 / P2×2）——v147 模板/日志面三产物（dispatch 契约行 / CHANGELOG Rule 63 条目 / registry research-first 行）逐字保真全过；唯一 P1 落在 v148 drift-enforcement 登记行描述。

**审查范围**（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first）：
- `skills/task-planner/templates/subagent_dispatch.md:27` 检索优先契约行 vs findings §「subagent_dispatch.md §2 检索契约行」锚（:74）；与既有 §2 四契约行风格协调性
- `CHANGELOG.md:12`（Rule 63）/ `:13`（Rule 64）双条目 vs `skills/task-planner/references/critical-rules.md:769-783`（Rule 63）/ `:786-800`（Rule 64）原文
- `skills/task-planner/scripts/selftest-registry.tsv:62-63` 尾两行描述准确性

**证据（机器可复现）**：
- dispatch 契约行逐字=findings 锚：`sed -n '27p' subagent_dispatch.md` ≡ `sed -n '74p' findings.md`；格式同为 `- ` bullet + `（Rule XX，task-vXXX）` 括注，插入点=knowledge-brief 行（:26）后（与计划 S3 锚一致）
- CHANGELOG Rule 63 条目逐字=findings:69 锚：两处 `md5sum` 均为 `17049216789046ec7033887ec47f0530`；术语逐项对齐 63.1 目标公理 / 63.2 四步检索链（本地→帮助面→官方文档/网络→社区）/ 63.3 反推诿禁令 / 63.4 有理有据边界（58.5 三态 not-solved）
- CHANGELOG Rule 64 条目术语对齐 Rule 64 原文（标题 / 64.1-64.6 / 判例「25 Phase 执行率 0%」）
- registry:62（research-first）「RF-01..12」= 实际 12 个 RF 标签（`grep -oE 'RF-[0-9]+' … | sort -u | wc -l` = 12）；dep_anchors 5 条全存在

**发现项**：
| 级别 | file:line | 问题 | 建议 |
|------|-----------|------|------|
| P1 | `skills/task-planner/scripts/selftest-registry.tsv:63` | trigger_scenarios 写「静态 DCE-01~10 + 行为 DCE-11~16」（=16），与脚本实态（`grep -oE 'DCE-[0-9]+' selftest-drift-enforcement.sh \| sort -u \| wc -l` = 23，DCE-01..23）及所引条款 `critical-rules.md:798`（Rule 64.5）原文「DCE-01~23」均不符 | 改为「静态 DCE-01~10 + 行为 DCE-11~23」；同源 stale 文案在 `selftest-drift-enforcement.sh:2` 头注，两处同步修 |
| P2 | `CHANGELOG.md:12` | Rule 63 条目记 v147 中间态（FF-16 `^63\.`→`^64\.`、SKILL `1-62→1-63`），worktree 净态已为 `^65\.`（four-file-dataflow.sh:109）/`1-64`；`:13` Rule 64 条目未记其二次级联 | 在 Rule 64 条目补记 FF-16/SKILL 计数/六守卫二次演进，或将 Rule 63 条目改净态描述 |
| P2 | `skills/task-planner/SKILL.md:214`、`skills/task-planner/templates/subagent_dispatch.md:27` | 「Rule 26 Q3」 vs `critical-rules.md:779`（63.4）原文「Rule 26.3 Q3」术语变体（Rule 28.2:271 已有「Rule 26 Q3」先例） | 统一为「Rule 26.3 Q3」或保留（低优先，有先例） |

**参考**（超本审查范围，仅登记）：`selftest-registry.tsv:55`（EG 行）写「EG-01..20」，实际 EG 标签=21——同型 range 漂移先例，供主进程判是否一并收口。

#### [sub:7-alignment] 对齐审查回执（文档面）

**结论**：APPROVED（P0/P1 = 0；P2×1 + 存量债务登记×1）——Rule 63/64 条款文本 ↔ SKILL.md 联动面（索引行/Critical Rules 头注/bullet/合规清单 C44/References 表行）子条编号·名称·计数·术语逐项一致；两项发现均为 :9 索引行文档完备性事项，非本变更阻断面。

**审查范围**（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first，只读）：
- `skills/task-planner/references/critical-rules.md:769-783`（Rule 63 六子条）/ `:786-800`（Rule 64 六子条）
- `skills/task-planner/SKILL.md` 联动点：`:9`（索引行）/ `:214`（合规清单 C44）/ `:277`（Critical Rules 头注）/ `:325`（Rule 63 bullet）/ `:326`（Rule 64 bullet）/ `:350`（References 表行）
- 版本一致性（42.6.1）：SKILL.md frontmatter + CHANGELOG.md [Unreleased]

**证据（机器可复现）**：
- 子条编号/名称（校验点①）：`grep -cE '^63\.[1-6] '` = 6、`grep -cE '^64\.[1-6] '` = 6；SKILL:325 bullet 逐项 = 63.1 目标公理/63.2 检索优先/63.3 反推诿禁令/63.4 有理有据边界/63.5 衔接/63.6 机制；SKILL:326 bullet 逐项 = 64.1 留痕三件套/64.2 第三条件门控/64.3 节奏提醒/64.4 判定输入三锚/64.5-64.6 机制；C44（:214）引 63.2/63.3/63.4 名称语义与原文一致
- 头注计数（校验点②）：`:9`/`:277`/`:350` 三处「Critical Rules 1-64」；`:277`「含 Rule 40-64 全集」；`grep -n '1-62\|1-63\|40-62\|40-63' SKILL.md` exit=1（stale 零残留）
- Rule 64 bullet 术语（校验点④）：:326 与 `:790-800` 原文 64.1-64.6 术语一致（检查点/ledger drift_check/Drift Log、check-3file-gate、posttooluse ≥10 次、三锚、selftest-drift-enforcement.sh）
- 版本一致性：SKILL.md frontmatter 无 version 字段；CHANGELOG [Unreleased]（未发布 = 与未合并事实一致）

**发现项**：
| 级别 | file:line | 问题 | 建议 |
|------|-----------|------|------|
| P2 | `skills/task-planner/SKILL.md:9` | 索引行称「Critical Rules 全集 1-64」，但括注枚举（…60、62、63）止于 63，未列 Rule 64（第二世代计数已升 1-64，枚举未随动） | 在「63 检索优先与反推诿纪律」后补「、64 偏移检查留痕强制与节奏化触发纪律」（Rule 64 经 :277/:326/:350 可发现，非失效引用，故不阻断） |
| 债务 | `skills/task-planner/SKILL.md:9` | 括注「（61 预留未落地）」与事实不符：Rule 61 已落地（`critical-rules.md:716`，task-v146）——用户可见面声明与事实不符 | **定性=应记债**：pre-existing + 本任务两代刻意未修（scope 纪律）+ 非本变更产物 → 非本任务阻断项，建议专项后续任务收口；同源 stale 文案 `scripts/selftest-evidence-goal-gate.sh:34/:226`、`scripts/selftest-requirement-coverage.sh:165` 一并交 S6/主进程 |


#### [sub:6-code-reviewer] 审查回执

**结论**：APPROVED（P0=0；P1=1 文档口径 + P2=1 历史注解保真；均非行为阻断——全量 selftest ΣFAIL=4=基线零新增）。
审查对象=`git -C <worktree> diff e54973d..HEAD -- 'skills/task-planner/scripts/*.sh'`（14 文件：2 新增 + 12 改动；终态含 Rule 63+Rule 64 协同演进）。

**执行证据**（worktree，只读）：
- `bash scripts/selftest-research-first.sh` → `Total: 12 PASS=12 FAIL=0`（exit 0）；12 断言逐条匹配目标文本实态（`^63.[1-6] `=6 / 63 块四词 / 63.2 四链词 / 63.4 编造+not-solved / SKILL `1-64`×3+bullet 全角括号+头注 40-64 全集+C44 / dispatch Rule 63+禁止编造 / FF `^65\.[0-9] `=2 ∧ `^64\.[0-9] `=0 / registry 登记 / config research=0）
- `bash scripts/selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`（exit 0）
- 全量 62 脚本回归：`ΣFAIL=4`，构成=periodic-review PR-03/04/05/10（=知识简报 §2 基线构成，**零新增 FAIL**）
- `bash -n` 四脚本语法全绿；`selftest-registry.sh` rows=62=actual 62
- 第二世代自洽复核：`1-64`/`Critical Rules 1-64（含 Rule 40-64 全集`/`^65\.` 三面与 critical-rules.md:786-800（Rule 64 已落地）一致；FF-16 awk 语境 `^60\.6`→EOF 内 `^65\.[0-9] `=0 语义成立
- awk 子块无 next 设计正确（B62/B64 含首行自身，`[2026-10-08 修复]` 注释所述 next 臂致子块恒空的问题已修）；exit 语义 `[ FAIL -eq 0 ] && exit 0 || exit 1` 正确

**发现项**：
| 级别 | file:line | 问题 | 修复方向 | 置信 |
|------|-----------|------|----------|------|
| 🟡 P1 | `skills/task-planner/scripts/selftest-drift-enforcement.sh:2`（同 :35） | 头注「行为 DCE-11~16」≠ 实态（`DCE-11..23`，含 17/18/19/20/21/22/23 共 11 条行为断言），亦≠ Rule 64.5 权威文本 `critical-rules.md:798`「（DCE-01~23）」 | 头注 :2/:35 改为「静态 DCE-01~10 + 行为 DCE-11~23」；同源 registry:63 建议同步（.tsv 出本审查 .sh 范围，交主进程） | HIGH |
| 🟡 P2 | `skills/task-planner/scripts/selftest-evidence-goal-gate.sh:32`（同 :225） | v144 历史注解被**改写**：base 原文 `'^59\.' → '^63\.'` → HEAD `'^59\.' → '^64\.'`；致 v144 代次记录与同族六脚本「追加不改写」约定不一致（lane-advancement:127 / requirement-coverage:123,164 / self-resolution:69 / tool-selection:56 / workflow-orchestration:63 / drift-check-subagent 均**保留** v144 原文后再追新代行），且 63→64 第一代记录在该文件缺失 | 回滚 :32/:225 v144 行为原文（59→63），另起 v147 两代追加行（63→64、64→65），与同族脚本格式对齐 | MED |
| 💬 Nit | `skills/task-planner/scripts/selftest-four-file-dataflow.sh:27` | 注释「62 块尾上下文（末条 62.6 行起至文件尾）」≠ awk 实际起点 `/^60\.6 /{f=1} f`（pre-existing 口径漂移，本任务仅动 `^63\.`→`^65\.` 字面，未新增该不一致） | 建议后续专项统一「62 块尾/62.6」措辞或 awk 起点（非本任务阻断面） | LOW |

**负结果报告**：
- 检查范围：`skills/task-planner/scripts/*.sh` 全 14 文件 diff（e54973d..HEAD），含新增脚本全文与既有脚本逐 hunk
- 未发现越 scope 改动混入：14 文件全属 task-planner scripts，均为 Rule 63 落地 + Rule 64 协同演进两类落点，无 build/无关脚本
- 未发现安全类缺陷：脚本仅本地 `grep/awk/stat/sed`，env 变量（`TASK_PLANNER_DRIFT_RHYTHM_N`/`TASK_PLANNER_DRIFT_ENFORCE`）均经 `case ... in ''|*[!0-9]*)` 数字白名单或 `case` 枚举收敛，无命令注入/路径遍历面
- 未发现断言语义弱化：各宽化脚本仅字面锚演进（`1-62`→`1-64` / `40-62 全集`→`40-64 全集` / `^63\.`→`^65\.`），断言结构、阈值（≥1/≥3/=0/=6 等）、负断言方向全部不变
- 未发现回归：全量 `ΣFAIL=4` 且构成=基线（periodic PR-03/04/05/10），新脚本仅增 PASS（RF 12 + DCE 23）
## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新规则编号 63、名称「检索优先与反推诿纪律」 | rule-reserve check=free；名称覆盖 R1-R5；与 Rule 60/22.3.0 分工进 63.5 引用不重述 |
| 条款六子条结构（公理/检索/禁令/边界/衔接/机制） | 对齐 56-62 既有规则范式（引言判例+子条+机制段+零新键） |
| FF-16 宽容化方向 63.x→64.x | v121（1-4[5-9]）/v146（40-55→40-61）锚演进先例：负断言窗口随最新规则号平移 |
| 传播面三落点（SKILL bullet+C44+dispatch 契约行） | 主进程消费（bullet/C44）+子代理消费（dispatch 行）双面覆盖，Rule 62 同范式 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| SKILL.md :9 存量括注「（61 预留未落地）」与 v146 落地事实不符 | 超出本任务 scope，S2 不动该括注；登记本行，交 Phase 4 对齐审查复核定性 |

#### [sub:4-executor] S4 落地回执

**主改动（selftest-four-file-dataflow.sh FF-16 宽容化）**：
- :27 注释行 `^63\.[0-9] ` → `^64\.[0-9] `
- :108 断言行 `^63\.[0-9] ` → `^64\.[0-9] `
- 验证：`grep -n '64\\\.\[0-9\]'` 命中 :27/:108；`grep -n '63\\\.\[0-9\]'` 残留 = 0

**扫描结果（同类 63.x 负断言残留，3 个额外文件）**：

| 文件 | 命中行 | 处置 | 说明 |
|------|--------|------|------|
| selftest-evidence-goal-gate.sh | :29, :32, :220, :224, :231 | 宽容化（5 处） | EG-16，58 块尾上下文，与 FF-16 同范式 |
| selftest-iteration-persistence.sh | :21, :162, :175 | 宽容化（3 处） | IP-14，57 块尾上下文，与 FF-16 同范式 |
| selftest-requirement-coverage.sh | :162, :172 | 登记不改（2 处） | RC-15，裸全文 grep 无块尾上下文，超 ≤2 约束 |

**验证**：`bash selftest-four-file-dataflow.sh` → Total: 18 PASS=18 FAIL=0

**偏差登记**：任务约束"额外命中 ≤2 文件"，实际命中 3 个额外文件。改 2 个（EG-16/IP-14，与 FF-16 最相似），登记 RC-15 但不改。RC-15 的 `^63\.` 负断言在 Rule 63 落地后会 FAIL，需后续任务同步宽容化。

**RC-15 收尾（task-v147 追加）**：
- :162 注释行 `'^63\.'` → `'^64\.'`
- :171 后追加注释：`# [2026-10-08 task-v147 合并级联] '^63.'→'^64.'：Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），防线前移至 64（先例 v125 S5/v131/v136/v138/v144 重锚）`
- :172 断言行 `'^63\.'` → `'^64\.'`
- 验证：`grep -n '64\\\.'` 命中 :162/:173；`grep -n '63\\\.'` 残留 = 0；`bash selftest-requirement-coverage.sh` → Total: 23 PASS=23 FAIL=0

## Resources
- critical-rules.md 全文（master e54973d，766 行，尾部=Rule 59 段）
- plans/task-v146-drift-check-subagent/progress.md（selftest 基线 Σ934/4 台账锚）
- scripts/selftest-four-file-dataflow.sh（FF-16 :27/:108；selftest 范式参照）

## Visual/Browser Findings
-（无多模态产出）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
