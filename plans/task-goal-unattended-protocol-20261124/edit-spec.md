# 编辑规格（edit-spec）— task-goal-unattended-protocol-20261124

> 执行体的唯一施工依据。所有路径若无特别说明，均相对 **worktree 根**：
> `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124`
> 唯一例外是 E25（主仓 `AGENTS.md`，未跟踪文件，不在 worktree 内）。
> 修订 R1（2026-11-24，响应计划审计 R1）：E0 条款全文、E5、E6，以及文件 3 至文件 5 的相关条目按审计意见修订；旧串锚未变。

## 通用纪律（每条编辑都必须遵守）

1. 每个文件动手前先 Read 目标行附近原文；`old` 串必须与盘上字符逐字一致。
2. 若 `old` 串与盘上仅存在标点全/半角、空白这类细微差异：以盘上为准调整 `old`，`new` 里的新增文字保持本规格原文不变；并在回执 `evidence:` 中列出每一处调整。
3. 结构文件插段（Rule 106.1a）：插入前 grep 段清单确认落点；Edit 后强制结构回读（行数变化、前后标题各一个空行）。
4. 就地增量：除本规格明确写「替代」的 old 串外，任何既有文字不得改动、不得重排、不得顺手格式化。
5. 每完成一个文件：`git diff --stat -- <file>` 并回读该文件全部改动行，确认与本规格逐条一致。

---

## E0. 新增条款全文（用于 E2；单行，行首为 `28.9 `）

```
28.9 **goal 无人值守与续推幂等协议（P0，2026-11-24 task-goal-unattended-protocol-20261124；判例 sess_df5b8b4a-8536-4c7e-87ac-fd85024635eb：宿主 verifier 续推 14 轮/AskUserQuestion 9 次无应答/部署决策翻转 3 次/用户「授权」到达被丢弃。目标：goal 语境下零提问、零停表、续推幂等、授权到达即执行；根因=28.8 规定「首次阻塞说明后停止迭代」，但 /goal 下是否续推由宿主 verifier 控制，且各升级路径终点均为「升级用户/AskUser」，无人应答即成环。判定面=LLM 行为+本条款文本锚，零新 config 键/脚本/门/hook；衔接 28.8/44.3/44.5/84.5/95/109——28.8①-④原文语义保留，仅其硬门处置由②明确取代）**：① **无人值守公理**：goal 语境=用户不在场（判定面同 28.8）。AskUserQuestion 视为不可用工具（0 次调用）；其返回无有效用户答复（未作答或被自动应答，如判例会话的工具回执「Continue using your best judgment; do not treat this as a rejection or invent a user preference」）=视同 44.3 超时，按②预算矩阵取默认项裁决并登记自动裁决记录五要素；「不发明偏好」的合规解=取预算矩阵默认项，而非臆造新范围。② **授权预算矩阵（取代开放硬门）**：/goal 指令本身即授权（预算内，静默自决留痕）=D1-D5 选择点（含 72.1 A 级中的 A①/A④——语义级分叉与计划要素取舍按 28.8① 与 44.3 推荐项自治留痕，不因 A 级名义转为预算外（A① 涉及范围者以 28.8④ 登记的交付单元上界为限：上界内的计划要素取舍属预算内，超上界的范围扩张属预算外））；worktree 建立与合并回主分支；/goal 指令明示为任务对象的源码修改及其 selftest/verify；**部署**——仅限已合并进 master 且相关 selftest 通过的 skills/ 内容，逐位 diff 判向、禁整文件覆盖、部署前备份、部署后 verify 对账（2026-11-24 用户裁决）；计划/台账/记忆写入。永不自动（预算外，即使 goal）=D6 类不可逆/破坏性/删除数据/强推/对外不可撤回发布/花钱（含 72.1 A 级中的 A② 不可逆破坏性与 A③ 对外发布）；指令未明示为任务对象的 skills/** 技能源码、agent 定义 model/frontmatter、~/.zcode/AGENTS.md 宪法、项目 AGENTS.md、~/.zcode/commands 指令文件的修改；推翻用户显式否决项（含记忆否决锚）；超 28.8④ 上界的范围扩张。预算外项**不询问**（41.5/72.1/97.5 的「询问/等待」在 goal 语境下即此形态）：登记「待授权清单」（项/理由/一键预案命令/可逆性）后继续执行其余可执行项，该项保持未执行，禁停表等待。③ **续推指令识别与效力**：用户手输消息一律优先按⑦（授权到达）或新指令判定，本条仅适用于非用户手输的自动续推——消息正文自称 Completion verifier/goal 续推/objective 未达成/含 Reason+Next action 结构，或（可见时）消息 ID 含 `goal_verify`。效力=**差距线索**（verifier 认为未达成的项），不是用户裁决、不是授权、不扩大②预算；其「向用户取得授权/确认/裁决」类步骤在 goal 语境不可执行，一律转④。④ **首次续推=差异归因（仅此一次）**：逐项登记 gap key 并四分类——类 A（预算内可执行）→执行并验证；类 B（预算外）→登记待授权清单；类 C（语义保证型判据：确保/保证/根治/不再/杜绝/所有，84.5 判据拆分条款）→判「判据上限」：执行期不新增、不改判据行，以计划期（attest 锁定前）登记的机器可验拆分项为准——拆分项全 PASS ⇒ PARTIAL，未全 PASS 或计划期未拆分 ⇒ BLOCKED，连同残余风险清单定态，经一次独立仲裁（decision-arbiter→critic 降级；两体均不可用=登记不可用证据后按既有证据定态）确认后冻结；类 D（已完成/误判）→给证据锚（file:line），不返工。⑤ **固定点应答**：续推的 gap key 集合 ⊆ 已登记集合（无新增可执行项）=固定点达成。待授权清单与 gap key 登记于 progress（planctl `add --section decisions`，标题含「待授权清单」），作为固定点应答的权威源。此后每轮续推只输出 ≤10 行「终态不变」应答（终态+登记位置+待授权清单+解锁指令），零工具调用（仅上下文已被压缩/恢复时允许一次只读回读上述登记段）；禁再调研/再自纠/再重写文档/再派子代理/再提问/再翻转。固定点应答豁免 95（非必要暂停禁令）、64（偏移留痕）、103（双轮质检）及 hook 提醒（drift-rhythm/judge/plan-sync）触发的派发。⑥ **决策冻结与翻转预算**：登记为终态的决策仅可被「新用户消息/新外部证据/独立仲裁」之一推翻，每个决策翻转上限 1 次；meta-corrector 的策略切换若与已登记终态相反，须先过独立仲裁，禁自翻转；已被记录驳回的论据禁重提为翻案依据。⑦ **授权到达即执行**：后续用户消息命中待授权清单（授权/同意/按推荐/继续/做X 等）=对应门放行，立即执行其预案并验证，禁再索要更精确措辞。多项待授权而消息未指明时，仅执行其中非 D6 类的推荐项并在首行声明所选项；D6 类项不适用泛化放行，须逐项显式确认，未获确认即继续挂起并列出待确认项。goal 被运行时关闭不清空待授权清单。⑧ **终点覆盖**：goal 语境下，凡以「升级用户/AskUser/等待答复/呈报确认」为终点动作的条款（含 84.3⑤/84.5/109.2/69.3/96.7/33.4/22.7/41.5/72.1/97.5/escalation_threshold/subagent.retry_limit）终点一律改按③④⑤执行；其中 D6 类（含 72.1 A②/A③ 与 41.5 的 D6 项）=登记待授权清单并保持该项未执行（「等待答复」的无提问形态），72.1 A①/A④ 与 41.2 G4 的 goal 语境处置不变（按推荐项自治）；这些条款的判定条件与轮次上限不变。Why:判例=sess_df5b8b4a——28.8 在运行位逐字生效（与源仓 diff=0）仍空转，证明「禁问+停表」在「用户不在场+宿主续推」前提下不收敛：停→verifier 判未完成→续推→再停，且 verifier 的 Next action 明写「请用户裁决」为再次提问提供了依据；本条把「停表」换成「登记后继续+固定点应答」，把开放硬门换成可判定的预算矩阵。
```

---

## 文件 1（S3） `skills/task-discipline/references/critical-rules-discipline.md`

### E1a（第 64 行，28.8③，替代片语）
- old：`走②单次阻塞降级收口，不得以循环询问试图推进。`
- new：`走②单次阻塞降级收口，不得以循环询问试图推进；预算外项不停表等待——按 28.9② 登记待授权清单后继续其余可执行项，收到续推指令按 28.9③-⑤ 幂等处理（2026-11-24 task-goal-unattended-protocol-20261124）。`

### E1b（第 64 行，28.8②，片语后追加）
- old：`不得空转重问（44.5 上限语义在 goal 语境下收紧为 1 次）`
- new：`不得空转重问（44.5 上限语义在 goal 语境下收紧为 1 次；「停止该阻塞目标的继续迭代」指不再自发重做，不等于可被续推指令重启为实质动作——续推按 28.9③-⑤）`

### E2（第 64 行之后插入 E0 全文一行）
- 落点：28.8 行（行首 `28.8 **goal/目标迭代模式强制自治`）与其后的 `### 29 上下文与工作文件主动维护` 标题之间。
- 结构要求：28.8 行 → 一个空行 → **E0 整行** → 一个空行 → `### 29 …` 标题。即文件净增 2 行。
- 禁止改动 28.8 行首尾与 `### 29 ` 标题本身。

### E3（第 28 行，escalation_threshold 终点，句后追加）
- old：`次失败则 AskUserQuestion。`
- new：`次失败则 AskUserQuestion。**goal 语境终点覆盖（28.9⑧，2026-11-24）**：本条的「升级用户/AskUser/等待答复」终点在 goal 语境下一律改按 28.9③④⑤执行（续推=差距线索→差异归因一次→待授权清单+固定点应答），判定条件与轮次上限不变。`

### E4（第 55 行，28.2.2，替代片语；逗号以盘上实际字符为准）
- old：`goal 下硬门仅单次降级收口停止,禁循环重问`
- new：`goal 下预算外硬门按 28.9② 登记待授权清单后继续,禁停表等待与循环重问`

### E5（第 183 行，44.3，替代片语）
- old：`按 28.8② 单次阻塞说明+降级收口并停止该目标迭代。`
- new：`按 28.8② 单次阻塞说明+降级收口（「停止该目标迭代」=不再自发重做；不停表：预算外项按 28.9② 登记待授权清单后继续，续推按 28.9③-⑤）。`

### E6（第 186 行，44.5，替代片语）
- old：`则仅单次阻塞说明+降级收口并停止该目标迭代，严禁每轮重问形成死循环。`
- new：`则仅单次阻塞说明+降级收口、不再自发重做该目标迭代（不停表：按 28.9② 登记待授权清单后继续，续推按 28.9③-⑤），严禁每轮重问形成死循环。`

### E7（第 395 行，69.3，替代片语）
- old：`ESCALATE-USER 消费=主进程转 AskUserQuestion/STOP（不自行代答）；`
- new：`ESCALATE-USER 消费=主进程转 AskUserQuestion/STOP（不自行代答）——goal 语境下 ESCALATE-USER 的消费=按 28.9②④ 登记待授权清单/判据上限并固定点应答，不 AskUser；`

---

## 文件 2（S4） `skills/task-planner/SKILL.md`

### E8（第 132 行，替代片语）
- old：`同问禁复发，D6/§六 不可越权硬门仅单次降级收口停止。`
- new：`同问禁复发；预算外硬门（28.9②）不停表——登记待授权清单后继续，收到续推指令按 28.9③-⑤ 幂等处理。`

### E9（第 133 行，替代片语）
- old：`受 Rule 109 审计门未达标禁自动放行约束；D6/§六 不可越权硬门例外）`
- new：`受 Rule 109 审计门未达标禁自动放行约束；预算外硬门按 28.9② 登记待授权清单、不停表）`

### E10（第 124 行，句中追加；反引号与盘上一致）
- old：`，见下方机器门行）。简版再审输入包收敛为`
- new：`，见下方机器门行）；goal 语境不 AskUser：独立仲裁一次后按 28.9②④ 登记待授权清单/判据上限，续推按 28.9⑤ 固定点应答。简版再审输入包收敛为`

### E11（第 136 行，替代片语）
- old：`不可越权硬门仅单次阻塞降级收口禁空转（见 critical-rules-discipline 28.8/44.3/44.5）`
- new：`预算外硬门不停表——按 28.9② 登记待授权清单后继续；宿主 goal verifier 续推指令一律按 28.9③-⑤（差异归因一次→固定点应答），用户授权消息到达按 28.9⑦ 立即执行预案（D6 类项须逐项显式确认）（见 critical-rules-discipline 28.8/28.9/44.3/44.5）`

### E12（第 268 行，替代片语）
- old：`同问禁复发（D6/§六 不可越权硬门仅单次降级收口停止）`
- new：`同问禁复发（预算外硬门按 28.9② 登记待授权清单后继续，不停表；续推与授权到达按 28.9③-⑦）`

### E13（第 346 行，句中追加）
- old：`次失败→AskUserQuestion（交互模式语义见 Rule 28）`
- new：`次失败→AskUserQuestion（交互模式语义见 Rule 28；goal 语境不 AskUser，按 28.9⑧ 终点覆盖）`

---

## 文件 3（S5） `skills/task-planner/references/critical-rules.md`

### E14（第 10 行，索引行，替代片语）
- old：`D6/§六 不可越权硬门仅单次降级收口停止）`
- new：`预算外硬门按 28.9② 登记待授权清单后继续、不停表，续推按 28.9③-⑤）`

### E15（第 134 行，66.2，替代片语）
- old：`不可越权硬门仅单次阻塞说明+降级收口并停止该目标迭代`
- new：`不可越权硬门仅单次阻塞说明+降级收口、不再自发重做该目标迭代（不停表：按 28.9② 登记待授权清单后继续，续推指令按 28.9③-⑤ 幂等处理，2026-11-24）`

### E16（第 204 行，109.2，句中追加）
- old：`轮次不设上限；连续 ≥3 轮无实质进展→呈报用户裁决`
- new：`轮次不设上限；连续 ≥3 轮无实质进展→呈报用户裁决（goal 语境：不 AskUser，独立仲裁一次后按 28.9②④ 登记待授权清单/判据上限，续推按 28.9⑤ 固定点应答）`

---

## 文件 4（S6，与文件 5 同属一个派发单元） `skills/verification-gate/references/critical-rules-verification.md`

### E17（第 24 行，84.3⑤，句后追加）
- old：`同一 V-N 重试 3 次 FAIL → AskUserQuestion（escalation_threshold）`
- new：`同一 V-N 重试 3 次 FAIL → AskUserQuestion（escalation_threshold）；goal 语境不 AskUser，按 28.9⑧ 终点覆盖（task-discipline Rule 28.9）`

### E18（第 40 行，84.5，句后追加）
- old：`≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户`
- new：`≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户；goal 语境 BLOCKED 的消费=按 28.9②④ 登记待授权清单/判据上限并固定点应答，不升级提问（task-discipline Rule 28.9）。**语义保证型判据拆分（2026-11-24 task-goal-unattended-protocol-20261124）**：VC/Goal 含「确保/保证/根治/不再/杜绝/所有」等机器不可证明的语义保证时，计划期（attest 锁定前）必须拆为「机器可验拆分项（逐项命令）+ 残余风险清单」并登记 Decisions；执行期不新增判据行，以计划期登记者为准——拆分项全 PASS 且残余风险清单已登记 ⇒ PARTIAL（不得判 COMPLETE）；拆分项未全 PASS 或计划期未拆分 ⇒ BLOCKED`

---

## 文件 5（S6 续） `skills/verification-gate/SKILL.md`

### E19（第 68 行，句后追加）
- old：`≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户`
- new：`≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户（goal 语境按 task-discipline Rule 28.9②④⑤ 消费，不升级提问）；语义保证型判据（确保/保证/根治/不再/杜绝/所有）计划期拆为机器可验拆分项+残余风险清单，执行期不新增判据行：拆分项全 PASS ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED`

### E20（第 98 行，反作弊第 9 条·判据冻结协议，句后追加）
- old：`「这个判据达不成了」的正确动作是 BLOCKED 升级用户，而不是改判据。`
- new：`「这个判据达不成了」的正确动作是 BLOCKED 升级用户，而不是改判据。例外（不属中途改判据）：计划期（attest 锁定前）的判据可达性拆分——语义保证型判据拆为机器可验拆分项+残余风险清单（Rule 84.5 判据拆分条款）；执行期不新增判据行；goal 语境下执行期才发现判据不可达 = 按 task-discipline Rule 28.9④ 类 C 定态并固定点应答，不提问。`

---

## 文件 6（S7） `skills/task-dispatch/references/critical-rules-dispatch.md`

### E21（第 53 行，22.3，句中追加；逗号以盘上实际字符为准）
- old：`→ 必须 AskUser,禁继续同法重试。`
- new：`→ 必须 AskUser,禁继续同法重试；goal 语境不 AskUser,按 28.9⑧ 登记待授权清单/降级交付后继续（task-discipline Rule 28.9）。`

### E22（第 225 行，96.7，句后追加）
- old：`经确认后续批；同一 goal 内禁止静默续批。`
- new：`经确认后续批；同一 goal 内禁止静默续批（goal 语境不停表等确认：按 28.9②④ 登记待授权清单「续批范围」并回收在途结果、禁新派发，续推按 28.9⑤ 固定点应答——task-discipline Rule 28.9）。`

---

## 文件 7（S8） `skills/task-planner/companion/agents/decision-arbiter.md`

### E23（frontmatter，三处替代）
- old：`model: "account:zai-individual-coding-plan/GLM-5.3"` → new：`model: "account:zai-individual-coding-plan/GLM-5.4"`
- old：`thoughtLevel: enabled` → new：`thoughtLevel: max`
- old（description 内）：`GLM-5.3 强档保判断质量` → new：`GLM-5.4 强档(max)保判断质量`

### E24（设计取舍注释块内，Why 段末尾追加；缩进与块内既有行一致）
```
  [2026-11-24 task-goal-unattended-protocol-20261124] 原行为=GLM-5.3 + thoughtLevel: enabled，在本宿主派发必败
  （"Reasoning level unsupported"，判例 sess_df5b8b4a 两次派发失败——首轮与第十轮各一次，独立仲裁拖到第 10 轮才打通）；
  根因=宿主 individual 计划下无 GLM-5.3(非 Flash) 模型，且 GLM 系列仅支持 low/high/max 三档；
  修法=对齐运行位已生效配置 GLM-5.4 + max（用户裁决 2026-11-24）。
```

---

## 文件 8（S9；**主仓，非 worktree**）`/mnt/data/dev/task-planner-skill/AGENTS.md`

### E25（§2「判定规则」项目符号列表，新增一条）
- 落点：在以 `- 只有用户**明确**要求「安装 / 部署 / 同步到某工具 / reinstall」时，才动部署位` 开头的那一条**之后**，插入同级别的新项目符号：
```
- **goal 模式部署预授权（2026-11-24 用户裁决）**：`/goal` 任务中，为使目标生效而把**已合并进 master 且相关 selftest 通过**的 `skills/` 内容同步到部署位，属 `/goal` 已预授权范围，不必等待显式部署指令；护栏=逐位 diff 判向、禁止整文件覆盖、部署前备份、部署后 `verify.sh` 对账（全文见 task-discipline Rule 28.9②）。agent 定义的 model / frontmatter 不在此列，仍须显式授权。
```
- 只新增这一条；该节其余文字与顺序不变。

---

## 对齐核查补出的引用面与断言面同步（S18；回归 selftest 与全仓字面面核查发现，2026-11-24）

> 背景：E23 把 decision-arbiter 源 frontmatter 改为 GLM-5.4 + max 后，`selftest-decision-arbiter.sh` 的 DA-02 断言（钉 GLM-5.3）失败；另有 3 处文档仍写旧配置。断言与引用必须随 frontmatter 锁步，否则文档与 truth source 互相矛盾。只改描述 decision-arbiter 的字面；描述 complex-planner 的 GLM-5.3 字样（complex-planner.md、agent-coverage.md 第 13、30 行、template-mapping.md、INSTALL.md）与泛指档位描述（critical-rules-dispatch.md 第 245 行）一律不动。

### E26（`skills/task-discipline/references/critical-rules-discipline.md` 第 393 行，Rule 69 定位，替代片语）
- old：`委派 decision-arbiter（GLM-5.3 强档）出唯一裁决`
- new：`委派 decision-arbiter（GLM-5.4 强档 max）出唯一裁决`

### E27（同文件第 396 行，替代片语）
- old：`执行体=decision-arbiter 伴随 agent（GLM-5.3 强档，`
- new：`执行体=decision-arbiter 伴随 agent（GLM-5.4 强档 max，`

### E28（同文件第 399 行，Rule 69.5，替代片语）
- old：`model=`account:zai-individual-coding-plan/GLM-5.3`，thoughtLevel enabled——判断质量依赖推理深度，对齐 complex-planner 强档先例，`
- new：`model=`account:zai-individual-coding-plan/GLM-5.4`，thoughtLevel max——判断质量依赖推理深度；原值 GLM-5.3 + enabled（对齐 complex-planner 强档先例）在当前宿主派发必败（Reasoning level unsupported），2026-11-24 用户裁决改为现值，`

### E29（`skills/task-dispatch/references/agent-coverage.md` 第 40 行，替代片语）
- old：`decision-arbiter(D1, GLM-5.3 强档)`
- new：`decision-arbiter(D1, GLM-5.4 强档)`
- 修订（2026-11-24 回归发现，D-15）：初版 new 为 `decision-arbiter(D1, GLM-5.4 强档 max)`，落地后 `selftest-agent-coverage.sh` 的 AC-04 把「专用体」列里新增的英文 token `max` 当作 agent 名去 `test -f`，报「候选 agent 缺位: max」。矩阵该列是机器解析面（小写连字符名提取），只能放实体名；max 档信息以 decision-arbiter.md frontmatter 与 Rule 69.5 为准（两处已写全）。故新文案收回为与同表其他行同构的版本号写法，不改 selftest 豁免名单（改名单=放宽守卫）。
- 落地状态：初版 new 已随提交 c8cc87b1 进隔离区，须按本修订再改一次：`decision-arbiter(D1, GLM-5.4 强档 max)` → `decision-arbiter(D1, GLM-5.4 强档)`（同文件第 40 行，仅此一处）。

### E30（`skills/task-planner/scripts/selftest-decision-arbiter.sh`，DA-02 断言锁步；断言强度不变，仍为逐字锚）
- old（第 39 行）：`# What: frontmatter model 值逐字 = account:zai-individual-coding-plan/GLM-5.3（grep -F 固定串）。`
- new：
```
# What: frontmatter model 值逐字 = account:zai-individual-coding-plan/GLM-5.4（grep -F 固定串）。
# [2026-11-24 task-goal-unattended-protocol-20261124] 原行为=钉 GLM-5.3；该配置在当前宿主派发必败（Reasoning level unsupported），
# 用户裁决对齐宿主可用配置 GLM-5.4 + max，断言随 frontmatter 锁步（仍为逐字锚，强度不变）。
```
- old（原第 41 行）：`if grep -qF 'account:zai-individual-coding-plan/GLM-5.3' "$ARBITER"; then ok 02 "model 逐字=GLM-5.3 强档"; else bad 02 "model 非 GLM-5.3 强档"; fi`
- new：`if grep -qF 'account:zai-individual-coding-plan/GLM-5.4' "$ARBITER"; then ok 02 "model 逐字=GLM-5.4 强档(max)"; else bad 02 "model 非 GLM-5.4 强档(max)"; fi`

---

## 执行期复审第二轮采纳的修订（2026-11-24；来源 subagent-state/22-critic.md 的 W-5/W-6/W-7/N-1/W-1，计划 decisions D-17）

> 背景：上节把 template-mapping.md 与 critical-rules-dispatch.md 第 245 行的 GLM-5.3 字样归为「complex-planner 引用 / 泛指档位」而豁免，复审查证该归类有误——前者是 decision-arbiter 行，后者含 arbiter 专属从句且紧邻「派发 model 参数显式指定」，照字面执行会重现派发失败。另三处是本任务自身造成的不一致（断言注释高估覆盖面、旧注释与新 frontmatter 矛盾、两载体 PARTIAL 判据口径不一）。以下全部为引用面 / 注释 / 口径对齐，不改任何机器门、不新增断言。

### E31（`skills/plan-template-kit/references/template-mapping.md` 第 305 行，替代片语）
- old：`decision-arbiter(GLM-5.3)`
- new：`decision-arbiter(GLM-5.4)`

### E32（`skills/task-dispatch/references/critical-rules-dispatch.md` 第 245 行，Rule 103.4，替代片语）
- old：`质量争议升级 decision-arbiter GLM-5.3 强档）`
- new：`质量争议升级 decision-arbiter GLM-5.4 强档）`
- 说明：同行的「复检重档（GLM5.3/Opus 级）」是档位泛称，不动。

### E33（`skills/task-planner/companion/agents/decision-arbiter.md` 第 14 行，设计取舍注释，替代片语；frontmatter 不动）
- old：`选 GLM-5.3 强档(对齐 complex-planner 先例)；`
- new：`选 GLM-5.4 强档 max 档(原选 GLM-5.3 强档、对齐 complex-planner 先例，2026-11-24 改，见下方注记)；`

### E34（`skills/task-planner/scripts/selftest-decision-arbiter.sh` 第 41 行，注释改为如实表述；断言不动、文件行数不变）
- old：`# 用户裁决对齐宿主可用配置 GLM-5.4 + max，断言随 frontmatter 锁步（仍为逐字锚，强度不变）。`
- new：`# 用户裁决对齐宿主可用配置 GLM-5.4 + max；本断言仅把 model 锚随 frontmatter 锁步（仍为逐字锚，强度不变），thoughtLevel 未设断言（范围=零新 selftest，是否补断言待用户裁决）。`

### E35（`skills/verification-gate/SKILL.md` 第 68 行，替代片语；与 84.5 判据逐字对齐）
- old：`拆分项全 PASS ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED`
- new：`拆分项全 PASS 且残余风险清单已登记 ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED`

---

## 完成后自检（S3-S9 全部完成后由主进程执行；各单元回执只贴与本单元文件相关的行）

在 worktree 根执行：
1. `grep -rn -o -E "仅单次降级收口停止|单次阻塞降级收口|并停止该目标迭代" skills --include="*.md" | sort | uniq -c` —— 预期**仅剩 1 处**：discipline 的 28.8③ 行保留片语「单次阻塞降级收口」（其后已接不停表说明）；「仅单次降级收口停止」与「并停止该目标迭代」计数均为 0。
2. `grep -c '28\.9' <六个载体文件逐个>` —— 每个均 ≥1。
3. `sed -n '/^28\.9 /p' skills/task-discipline/references/critical-rules-discipline.md | grep -o '[①②③④⑤⑥⑦⑧]' | sort -u | wc -l` —— 预期 8。
4. `wc -l skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md` —— SKILL.md ≤581；discipline = 775+2。
5. `git diff --name-only 9e42c0b HEAD` —— 仅本规格点名的 skills 文件（文件 1-8 与 E29-E35 涉及的 agent-coverage.md、selftest-decision-arbiter.sh、template-mapping.md）被修改，无其他文件（AGENTS.md 在主仓，另计：`grep -c 'goal 模式部署预授权' /mnt/data/dev/task-planner-skill/AGENTS.md` 预期 1）。
6. `grep -rn 'decision-arbiter' skills | grep 'GLM-5\.3'` —— 仅剩历史注记行（discipline 399 的「原值 GLM-5.3」、decision-arbiter.md 第 14 行的「原选 GLM-5.3」与其后的变更注记），无任何「现行配置=GLM-5.3」的表述。
