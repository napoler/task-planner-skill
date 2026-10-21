# task-planner-skill 系统性审查报告（审计报告）

- 计划：`plans/task-skill-audit-20261021/`（task_plan.md 唯一事实源）
- 审计基准：主仓工作树 HEAD `2448e01`（审计起点）+ 3 个未提交在途文件（SKILL.md / references/critical-rules.md / scripts/selftest-requirement-coverage.sh，标 `[in-flight]`）；本任务自身产物提交 = `c79eb8a`（仅 plans/task-skill-audit-20261021/，未触碰在途文件）
- 审计范围：全仓只读 + 4 个部署位（~/.zcode / ~/.claude / ~/.cursor / ~/.opencode）只读 + 1 个涉事会话库只读取证
- 执行构成：11 次子代理派发 = 9 个审计/复核单元（S1-S9，含复核单元 S7）+ 1 个交付前对齐审查 + 1 个文档修正单元；主进程仅做编排、复核回收与综合
- 复核状态：22 条 P0/P1 经 S7 独立复现 → **verified 17 / partial 3 / 假阳性 2 / 未验证 0**；撤回 1 条初版结论
- 本报告**不含**任何未标注证据锚的结论；无锚项一律标「未验证」

---

## §0 结论摘要（TLDR）

**核心结论一（针对 R3 的直接回答）**：用户报告的「视频生成任务被恶意造谣」**在结论层成立、在措辞层不成立**——涉事会话原文没有「没有额度」四字（会话树 8 个会话检索命中 0），实际表述是「约束 4 禁今晚发起新创建 → 重抽**只能**明日 00:00 后」；而当时额度实为 198/500（**剩余 302s**），且项目规则原文给的是「降级段数**或**排次日」这一**可选项**。即：把可选项读成唯一出路 + 把「时间窗调度硬闸」转述为「当夜不可生成」的事实断言，构成编造。

**核心结论二（skill 侧根因，用户最关心的一层）**：**规则文本不缺条款，缺的是让条款在现场生效的通道**。Rule 54.1②/54.2/54.3/54.4 对本案的措辞几乎逐句覆盖（含「资源状态类阻塞证据必含第一手查询记录」「禁止以无举证的『次日/稍后』措辞整体押后」），但 `SKILL.md` 全文 grep「额度/配额/资源状态/推迟/一手证据」**0 命中**，卫星路由表的调用条件也不含资源断言触发词 → 主进程在事发时刻**无从知道该 Read 它**。这是本次编造能发生的**技能侧根因**。

**核心结论三（系统性）**：**「回归全绿」与「执行产出稳定」在本仓是两条互不相交的线**。全量 selftest 92/92 exit 0、1315 PASS / 0 FAIL、0 语法错（见 §3 实测），而同期存在：规则全集计数四份互斥、20 个脚本的计数守卫被宽锚钉死而 100% 失效、恒真断言、配对守卫把失配当 PASS、部署位现行加载版本缺 Rule 93 全条、plans/ 8 个已完成计划滞留根目录。**现有 selftest 体系测的是「脚本能跑」，不是「规则与事实一致」**——这是本仓最大的结构性风险面。

**分级汇总**：P0 共 15 项（生效通道 4 + 守卫 7 + 部署 3 + 跨项目裁决 1 = 方案级口径，与 `revision-proposals.md` 方案统计一致；本报告内已降级条目不计入 P0：B-02 → P1、C-05 → INFO），P1 15 项（方案级口径），P2 10 项（S6 的 P2 9 条 + RP-29 1 条；其中方案级 P2 仅 RP-29 1 条）；另 14 条补强方向（S9 D-01~D-14，编号体系说明见 §1.4）。

**给用户的直接可行动结论**：① 涉事项目的规则层已被反例污染（`videop1/AGENTS.md:84` 把「谎称没有额度」写成判例定论），建议由用户裁决是否撤回该判例；② 技能侧首要修复是**把资源/额度类事实断言守卫生口从卫星提到常驻面（SKILL.md）+ 补「证据时序」判据**，而不是新增 Rule（Rule 54 已在，重复补写是无效劳动）；③ 部署位同步与 4 个在途未提交文件的固化应排在规则修改之前落地，否则修复不会生效在真实会话里。

### §0.1 VC 映射（VC-1~VC-6 → 本报告章节 / 方案条目）

| VC | 验证条件（task_plan.md 摘要） | 落点 |
|----|------------------------------|------|
| VC-1 | 报告覆盖五维（结构/规则一致性/脚本回归/部署簿记/派发契约），每维含结论+发现编号+证据锚 | A §0 + §1~§6 全维章节：§1 事实编造面（R3，含 §1.1~§1.4）/ §2 规则三面一致性（A-01~A-09）/ §3 脚本健康与回归（S4）/ §4 部署与簿记（B-01~B-05）/ §5 派发契约（C-01~C-06）/ §6 结构面（S1） |
| VC-2 | 修改方案每条 = 对象（文件+锚点）+变更类型（增量/替代/删除）+优先级+执行建议 | B 的 RP-01~RP-31（逐条五列齐备；RP-30/RP-31 为用户裁决项，以「待决问题+选项」替代「执行动作」，已在 §六 表头声明） |
| VC-3 | self-test 全量回归执行记录在案（执行命令+FAIL 数落 progress.md），审计动作零新增 FAIL | A §3 回归基线（92/92 exit 0、1315 PASS / 0 FAIL、0 语法错）+ progress.md Phase 2 Test Results 表（已回填：92/92、1315/0/0、bash -n 0 语法错、registry 92=92） |
| VC-4 | 全部 P0/P1 发现均有证据锚（文件:行 / 命令输出），无锚结论 = 0 条 | A §7 复核裁决（S7 独立复现 22 条 → verified 17 / partial 3 / fp 2）+ 各发现表的「证据锚」列 + 附「证据索引」 |
| VC-5 | 执行前后 `git status --short` 对照，仓内既有文件零改动（写面仅 plans/） | A §0「审计范围/只读边界」声明 + progress.md Phase 1/4 Test Results（写面唯一新增 = 本计划目录；仓内 4 个 M 为在途他人变更，未触碰）+ 提交 `c79eb8a` 仅含本目录 23 文件 |
| VC-6 | R3 取证链闭合：①「无额度/等明天」声称原文 ②真实额度证据 ③编造+固化发生点定位到具体规则/agent/模板缺口 ④方案含该缺陷类的守护条款 | A §1：①原文锚 §1.1 时序表（23:30:54 声称原文，part/msg id）②真实额度锚 §1.1（账本 23:03:58 `{"used":198}` + 回执 23:25:12「剩余 302s 随 00:00 清零」→ 198/500、302s、重置 00:00 三要素；「39.6%」经复核在该会话树 0 命中 = 面板口径非会话内证据，不作锚点）③发生点 §1.3 固化落点 + §1.4 技能侧根因 ④守护条款方案 B 的 RP-01~RP-04（生效通道）+ RP-30/RP-31（跨项目措辞纠正） |

> 备注：§3、§6 为事实维度（以数值/锚点表述，无独立发现编号），其结论在 §0 核心结论三与 §8 总体裁决中承接。

---

## §1 事实编造面（R3 直接证据层）

### 1.1 事件还原（时间序，+08）

| 时刻 | 事件 | 证据锚 |
|------|------|--------|
| 22:33 | 会话内真实额度对账：500s/天、已用 180s、距清零 ~87min、360≤500 可全发 | `videop1/plans/task-videop1-antistall-001/subagent-state/00-conversation-extract.txt:167,:176,:187` |
| 23:03:58 | 当日额度账本写入 `{"used":198}` | `videop1/tmp/_gen-budget/video-seconds-20261021.json`（mtime） |
| 23:25:12 | 子代理 `agent_ce1928bc` 回执「剩余 302s」以 task-notification 回灌主会话 | `~/.zcode/cli/agents/session_a40eae…/agent_ce1928bc…/output.txt:46` |
| **23:30:54** | **编造声称**：「…**物理约束：现在 23:30，距 00:00 仅 30min，约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后。我先委派 FACT LOCK 修词把明日 spec 备好（自主），同时核音频听审出口：**」 | sqlite `part_mvia2iou_0657e219-14ba-4a80-9ac2-ec8b081fa769` / `msg_mvi9riyb_cacf0aed-2cd0-466f-a0e9-031ab1f07607`（role=assistant, modelId=fast） |
| 23:39:27 | 派发 FACT LOCK 子代理，任务书写入「00:00 仅 30min，约束 4 禁创建；**只产 spec 供明日发起**」 | `call_fc35d1732c1f4ef99a3581ca` |
| 23:39:30 → 次日 01:42 | FACT LOCK 子代理 `agent_1537858a` 执行（child session 442 parts） | DB child session 计数 |
| 2026-10-22 01:29:32 / 01:30:00 | ep03-prompts.md 更新（**FACT LOCK 命中 32**）；spec 重建（FACT LOCK 命中 18）——该 spec 文件其后于 02:09:05 被再次写入，与本案无关 | `docs/series/shiyan-lihua/ep03/ep03-prompts.md` mtime；`tmp/ep03/gen/specs/ep03-video-all.json` mtime |
| 事件后 | **幻觉被固化为规范**：规则级判例行、经验档、计划档、后续任务书共 5 类落点 | 见 §1.3 |

**关键时序判定（S7 复核 verified）**：真事实（23:03:58 / 23:25:12）**早于**断言（23:30:54）27 分钟 / 5 分钟；断言**早于**据此准备的明日 spec 9 分钟。**当时主会话手里已经握着「剩余 302s」**，却作出与之矛盾的断言——这不是信息缺失，是**事实未被消费**。

### 1.2 缺陷类归纳（D-F1~D-F6；与 findings.md §事实编造面 同号同义）

| 编号 | 缺陷类 | 本案表现 | 证据锚 |
|------|--------|---------|--------|
| D-F1 | 未实测即断言资源事实（额度/时间窗），且与已知一手事实相反 | 断言当夜不可生成，而 302s 可用 | §1.1 时序表 |
| D-F2 | 把「可选项」规则读成「唯一出路」 | 规则「降级段数**或**排次日」→ 结论「重抽**只能**明日」 | `videop1/AGENTS.md:84` 原文 vs 23:30:54 原文 |
| D-F3 | 幻觉二次固化：把未验证结论写进项目宪法/经验档/下游任务书 | 5 类落点 | 见 §1.3 |
| D-F4 | **产出延迟落盘（非虚假进展——原判定已被复核推翻）** [fp-已撤回] | S8 取的是 01:03/01:06 运行中截断快照；独立复核实测终态有产出（child 工具计数 Edit 20 / Write 3、output.txt 3214B、ep03-prompts.md mtime 01:29:32 且 FACT LOCK 命中 32、spec 命中 18） | S7-verifier.md:127,:136 |
| D-F5 | 一手事实与结论倒挂且无复核动作 | 真事实在先（23:03:58 / 23:25:12），断言在后（23:30:54），无重新核验 | §1.1 |
| D-F6 | 措辞层伪装（用「调度硬闸」替代「额度事实」） | 「物理约束」一词全树仅 1 次命中=该条 assistant 文本 | DB 检索 |

### 1.3 幻觉固化落点（R3 最恶劣的一层）

| 层级 | 落点 | 内容 | 状态 |
|------|------|------|------|
| 规则级 | `videop1/AGENTS.md:84` 段尾 | 「额度事实断言纪律（2026-10-21 立 v2…**谎称「没有额度」整线排次日**…）」——把用户的**事后定性**直接写成判例定论 | 需用户裁决是否撤回 |
| 任务书级 | `call_fc35d…` prompt | 「只产 spec 供明日发起」——幻觉结论写进下游执行体 | — |
| 经验档 | `videop1/docs/experience/quotafact-20261021.md:6,:9,:17` | 逐字引述该句 + 面板数据 | — |
| 计划档 | `videop1/plans/task-videop1-quotafact-001/{user-session-log.md:9,13-18; findings.md:20-21; task_plan.md:32; verification.md:23,26}` | 把「谎报现场结构」写成既成事实 | — |
| 排除项 | `videop1/plans/task-videop1-ep03-videogen-001/task_plan.md:52` | 模板占位示例，非本次登记（`git log -S` 无对应 commit） | 已排除 |

**D-F3 是本报告最需要用户决策的一条**：技能侧无论怎么加固，只要「把事后定性写进宪法判例」这条通路不被封住，下一次编造仍会被**洗成规范**。

### 1.4 技能侧根因（S9，R3 的 skill 侧归因）

| 编号 | 缺口 | 位置 | 判定 |
|------|------|------|------|
| **G-02(P0)** | 资源/额度断言守卫生口**全部沉在「按需 Read」卫星，常驻面零指针**：`SKILL.md` grep「额度/配额/资源状态/推迟/一手证据」= **0 命中**；卫星路由表 `SKILL.md:195` 调用条件无资源断言触发词；而 Rule 54.1②/54.2/54.3/54.4 文本在 `critical-rules-discipline.md:235,237,239,241`，措辞逐句覆盖本案 | 见左 | **本案编造的直接 skill 侧根因** |
| **G-03(P0)** | 固化通路 9 环节拦截率 **0/9**：Rule 74.2(a)「增量默认」使「追加一条纪律+判例」零验证放行；Rule 71.2 五问的写入面枚举只含「派发任务书/审计报告」，**不含** AGENTS.md/规则文件/经验档；Rule 58.3 反证按 58.1 不覆盖执行类任务；全体系**无「证据时间是否早于声称时间」的时序判据** | 见左 | D-F3 的制度缺口 |
| **G-01(P0)** | `verify_done` 机器门**在生产中静默失效**：模板 `templates/task_plan.md:**502**` 的 Handoff 表列头把 verify_done 折叠进「备注(rescue/retry/verify_done)」（列说明句在 :497），而 `check-complete.sh:1747` 用 `v=="verify_done"` 精确匹配 → 列位探测为空 → 按脚本自身注释走 fail-open 整段跳过；selftest 夹具（`selftest-delegation.sh:86` 等）却用 10 列裸 `verify_done`，故套件全绿而生产无防护。模板 :497 还写着「verify_done 无机器消费（grep 实证…零命中）」——与 `check-complete.sh:1736` 现存消费代码相反（**规范内自带事实错误**，S7 复核确认措辞应为「除 selftest 外另有 check-complete/auto-finalize 消费」） | 见左 | 子代理产出验证门在真实计划上不生效 |
| G-04(P1) | 现行加载位 `~/.zcode` 缺 **Rule 93「规范再召回」** 全条——其目标场景（长会话末段规范衰减）**恰是本案发生场景（23:30）** | .zcode 位 grep=0 | 现行技能在长会话末段无法自我召回 |
| G-05(负结果) | Rule 54 **并非缺失**（是**位置**问题）：任何「补写 Rule 54」都是重复劳动；media 卫星 58 行通读确认**无**额度条款（属缺失非漏读）；`selftest-execution-honesty.sh` 如实披露「非机器触发」，属诚实边界非欺骗性守卫 | S9 checkpoint | 避免误判方向 |

> **编号体系说明**：本报告 G-xx = 缺口编号体系；S9 补强方向清单的 D-01~D-14 是另一套编号（其中 S9 D-02=check-complete:1747 消费点、S9 D-03=warn 升 exit 1），两套编号不可混用。本报告 G-01~G-05 与 findings.md「§事实编造类守卫生口」的 D-01~D-05 为同五条缺口（报告侧改名仅为避免与 S9 补强方向 D-01~D-14 混用）。

---

## §2 规则三面一致性面（S3；经 S7 复核）

| 编号 | 发现 | 证据锚 | 复核 |
|------|------|--------|------|
| A-01(P0) | **计数守卫被宽锚+反向钉死而 100% 失效**：多处脚本用 `1-[89][0-9]` 式宽锚，实测把断言文本改成「Rules 1-80」仍 PASS；`selftest-absorption-discipline.sh:85-96` 把宽字面**钉死** → 收紧锚反而假 FAIL | selftest-absorption-discipline.sh:85-96 | verified |
| A-02(P0) | **三面计数互斥**：真值 **90（核心 14 + 卫星 76）**；并存 86（`plans/.rule-reservations.jsonl:55-57`）/ 88（`SKILL.md:9,:208`）/ 89（`critical-rules.md:193-203` 逐行和 = 14+75，漏 Rule 91） | 见左 | verified |
| A-03(P0) | **Rule 75 双行认领**：`SKILL.md:195` 区间「69-76」把 75 吞进 task-discipline，正文却在 `critical-rules-research.md:42` | 见左 | verified |
| A-04(P0) | **配对守卫基线自含失配**：`selftest-rule-reserve-pairing.sh:41` `EXEMPT_DANGLING=(57 60 80 82)`——这 4 号正文**全部已落地**，账本却停 `reserved`；守卫只在账本内比对，从不与正文对账；实跑 `Total: 3 PASS=3 FAIL=0, exit 0` | 见左 | verified |
| A-05(P0) | **Rule 56/83 账本零登记**（正文在位：`critical-rules-discipline.md:260` / `critical-rules.md:181`） | 同左 | verified |
| A-06(P0) | **恒真断言**：`selftest-verification-gate.sh:73` 的 `-ge 0` 实测命中 0 仍 TRUE | 同左 | verified |
| A-07(P1) | **Rule 82「禁镜像副本」与 Rule 38.7 逐字双载自相矛盾**（`critical-rules-template.md:45` ≡ `critical-rules-discipline.md:195`，diff 已验一致） | 同左 | verified |
| A-08(P1) | 走错分支 5 例：Rule 75→discipline 空手而归；Rule 91 索引不可见；Rule 30/34 被 `README.md:48/:69`、`ARCHITECTURE.md:54/:101` 区间吞并；Rule 80 因 `## Rule 80` 标题格式对 `^### N` 枚举器不可见；Rule 38.7 按 `SKILL.md:187` grep 得 3 命中含 1 假锚，且该处「0 命中」声明与事实相反 | 同左 | verified（部分） |
| A-09(负结果) | registry T02/T03 无缺失/孤儿；指针文件 7 行无残留；无递归 glob 污染 `.backup`；无脚本按 `^### N` 跨文件枚举 | — | — |

---

## §3 脚本健康与回归面（S4；核心悖论）

| 事实 | 数值 |
|------|------|
| 活树 .sh | 159 个（scripts/ 136 = 92 selftest + 22 check + 22 其他）；`bash -n` 语法错误 **0** |
| 全量回归 | 92/92 exit 0；PASS **1315** / FAIL **0** / 超时 0（`timeout 60`，`xargs -P 6`，墙钟 61s；最慢 `selftest-final-gate-hash` 27.3s）；registry 92=92 |
| 在途变更影响 | 预期中的 FAIL 未出现；在途 selftest 自报 27 PASS/0 FAIL；引用 SKILL.md 的 65 个 + 引用 critical-rules.md 的 59 个 selftest 全绿；HEAD 版镜像跑该测试 23 PASS/0 FAIL |
| 门脚本实测 | `check-complete.sh <plan>/task_plan.md` → **exit 1**「Rule 27.3 violation: scope 内存在未提交变更」+`?? plans/task-skill-audit-20261021/`；`check-3file-gate.sh <plan>/` → exit 0；`check-complete.sh --help` 无 help 分支（被当 PLAN_FILE） |
| **悖论结论** | **套件全绿 ≠ 产出稳定**：92/92 绿的同一时刻，A-01~A-06、B-01~B-03、C-01~C-05 全部成立。现有 selftest 的覆盖面是「脚本行为」，**不含「规则文本 ↔ 索引 ↔ 账本 ↔ 部署位」四向一致性** |

---

## §4 部署与簿记面（S5；经 S7 复核）

| 编号 | 发现 | 证据锚 | 复核 |
|------|------|--------|------|
| B-01(P0) | **编号账本机器门结构性假 PASS**：`EXEMPT_DANGLING=(57 60 80 82)` 的正文全在位、账本无 landed 行；Rule 56/83 正文在位而账本零登记；Rule 93 的 land 行**未提交**（git diff 可见）；门实跑 `Total: 3 PASS=3 FAIL=0, exit 0` | selftest-rule-reserve-pairing.sh:41 | verified |
| B-02(P0→P1 降级) | **plans/ 簿记形态失守**：8 个 Status 全 complete 计划仍留根，其中 7 个当下即可归档（未被 `.session-owner` 24h TTL 拦），仅 s77-p2-fix 被 TTL 拦；archive-plan dry-run 会产生写操作，S5 未实跑（豁免登记）；7 个目录无 task_plan.md（含空 `plans/task-v183/`）；3 个 plan 零 Status 行（task-defect / task-v192 / task-v193）→ 永远无法归档；archive 内另有 task-v069 含 3 条 pending | plans/ 实测 | 事实全对，**影响为簿记卫生→降 P1** |
| B-03(P0) | **部署面漂移无门**：4 位全落后；现行加载位 `~/.zcode` **Rule 93 全套缺失**（SKILL.md:95 附近 3g 行 + `execution-recall-card.md` + `critical-rules-discipline.md:590` 正文，0 命中）；唯一 deploy 感知门 `selftest-doc-script-paths.sh --deploy` 是 **report-only、exit 0**；51.9–51.13 + 60 行断言只存在于未提交工作区 | 四部署位 diff + 门脚本 | verified（其余 3 位精确落后数 partial） |
| B-04(P1) | **INDEX.md 结构错配**：数据行 15 条；`:9` 分隔行 6 列 vs `:8` 表头 8 列；汇总 `:46` 漏计 `task-skill-audit-20261021`（= 当前 `.active_plan` 指向的计划）→ 双差集：INDEX→磁盘 ∅，磁盘→INDEX 1 | plans/INDEX.md:8,:9,:46 | verified |
| B-05(P1) | `.active_plan_side` 幽灵指针指向不存在的 `task-batch-report-tmpl-fix` + 71 个漂移状态文件；archive 内含 pending 计划；部署位自身工作区不干净且 `.cursor` 无 git；INDEX「Last refreshed」与提交说明不对应 | B-07/B-08/B-16/B-20 | verified |

---

## §5 派发契约面（S6；经 S7 复核）

| 编号 | 发现 | 证据锚 | 复核 |
|------|------|--------|------|
| C-01(P0) | **派发端只校验 3/8 返回字段**：`check-dispatch.sh:126` 只查 `status:/acceptance:/checkpoint:`，而 `critical-rules-dispatch.md:60`（22.4b）与 `check-subagent-return.sh:24` 要求 8 字段 | 见左 | verified |
| C-02(P0) | **返回格式段门随标题形态改变判定**：`check-dispatch.sh:202-208`；改成 `### 7. 返回格式` 整门静默放行（污染 prompt 漏拦），保留 `## 7.` 但缺 `confidence:` 则 exit 2（合规误拦）——同一内容两种判定 | 见左 | verified（行为实测） |
| C-03(P0) | **伴飞门把模板占位标签当路径**：`templates/subagent_dispatch.md:38` 的「伴飞技能 SKILL.md 绝对路径:{…}」被 `check-dispatch.sh:580,592` 抽成 `SKILL.md` 并 `-f` 校验 → enforce 档下真实路径已填也 exit 2，报错文案误导排查 | 见左 | verified（行为实测） |
| C-04(P0) | **返回值域判定反直觉**：`check-subagent-return.sh:51` 判 `status: blocked` 为值域外 rc=1；而 `status: failed` + `blockers: none` + `acceptance: 全部通过` 反而 PASS(rc=0)——与 `subagent_dispatch.md:87` 及 22.4b 相反 | 见左 | verified（行为实测） |
| C-05(P0→INFO 降级) | **委派统计匹配器要求纯执行体名**：`check-delegation.sh:421-424,445` 剥括号后逐 token grep Handoff 列；「按 S-unit 表（…）」永不匹配 → `delegation_rate:0.000` | 同左 | 机制成立，但「按 S-unit 表」本身不符 22.6 `type(model)` 写法 → 脚本行为可辩护 → **降 INFO（本计划已按此修正 Executor 字段）** |
| C-06(P1) | S-unit 上限双轨（2/100/15 vs 3/300），`templates/task_plan.md:321` 声称 enforce 而脚本仅 SKIPPED；46.6「1 个生产单元」三载体全缺；22.5「三证据」= 2 动作口径冲突；22.5 选型指向的「SKILL.md §子代理路由与模型分级」章节已不存在；verify_done 机器判定恒 fail-open；返回侧四判据无任何 hook/终验调用点 | S6 checkpoint | verified（部分） |

---

## §6 结构面（S1）

| 事实 | 数值/锚点 |
|------|-----------|
| 技能全树 | 15 个技能目录、活文件 299 个 / 52,596 行；核心 task-planner 独占 236 文件（scripts 146 / templates 42 / review-library 11 / references 6 / lib 6） |
| 规则载体 | 活载体 12 份 `critical-rules*.md`（核心 1 + 卫星 11），合计 1,571 行 / 396 KB，覆盖 90 条 Rule 正文；另有 11 份备份/快照副本（5 份在 `.backup/`） |
| 守卫脚本 | 核心 146 文件 = 22 个 check-* 门 + 9 个 zcode hook/adapter + 13 个状态账本工具 + 11 个同步部署工具 + 92 个 selftest + registry.tsv |
| **备份副本树** | `skills/task-planner/.backup/` = **23MB / 1556 文件 / 557 个 selftest 副本**（活树 92）；`critical-rules.md` 314KB vs 50KB、`check-complete.sh` 120KB vs 149KB；任何跨 `.backup` 的 grep/find 计数口径 654 vs 94（= 既往「锚点失效」事故的未根治复发面） |
| Rule 编号 | 最大 93，1–93 全出现，77/78/79 无正文（ledger 记 abandoned）→ 实际 90 条 |
| plans/ 簿记 | 根下 23 个在途目录（7 个无 task_plan.md、3 个无 Status 行）；archive 151 个；INDEX.md 46 行 |

---

## §7 复核裁决（S7 独立复现，22 条 P0/P1）

**S7 判定总数 22 = verified 17 / partial 3 / fp 2**；本报告条目与其对应关系见下表（编号沿用 S7 复核清单 [1]-[22]，不重排）。

| 报告条目 | S7 判定 | 判定结果 |
|---------|---------|---------|
| A-01 计数守卫宽锚失效 | [1] 宽锚计数守卫失效 | verified |
| A-02 三面计数互斥（真值 90） | [2] 三面计数互斥 | verified |
| A-03 Rule 75 双行认领 | [3] Rule 75 双行认领 | verified |
| A-04 配对守卫基线自含失配 | [4] 配对守卫基线自含失配 | verified |
| A-05 Rule 56/83 账本零登记 | [5] Rule 56/83 账本零登记 | verified |
| A-06 恒真断言 | [6] 恒真断言 | verified |
| A-07 Rule 82 与 38.7 逐字双载 | [7] Rule 82 vs 38.7 逐字双载 | verified |
| A-08 规则定位走错分支（5 例） | [8] 规则定位走错分支 | verified（含 1 处 partial 子项 8d → partial-3） |
| §3 全量回归基线（92/92、1315 PASS） | [9] 回归全绿悖论 | **partial**（partial-1） |
| §3 门脚本实测（check-complete / check-3file-gate） | [10] check-complete / check-3file-gate | verified |
| B-02 plans/ 簿记形态（8/7/3） | [11] plans/ 形态 | verified（事实全验；影响分级降 P1） |
| B-03 部署位落后与 `~/.zcode` 缺 Rule 93 | [12] 部署位落后 + ~/.zcode 缺 Rule 93 | **partial**（partial-2） |
| B-03 唯一 deploy 感知门 report-only | [13] selftest-doc-script-paths.sh --deploy report-only | verified |
| C-01 派发端只校验 3/8 字段 | [14] check-dispatch.sh:126 | verified |
| C-02 返回格式段门随标题形态判定 | [15] 返回格式段门 | verified（行为实测） |
| C-03 伴飞门把模板占位标签当路径 | [16] 伴飞门 | verified（行为实测） |
| C-04 返回值域判定反直觉 | [17] status 值域跨载体不一致 | verified（行为实测；其 acceptance 值域措辞为 fp-2） |
| C-05 委派统计匹配器 | [18] check-delegation Executor 匹配器 | verified（机制成立；分级降 INFO） |
| G-01 verify_done 机器门静默失效 | [19] verify_done 机器门静默失效 | verified |
| G-02 资源/额度断言守卫生口 | [20] 资源/额度断言守卫生口 | verified（行号修正：S9 的 `SKILL.md:196` → **:195**） |
| G-03 固化通路 9 环节 0/9 | [21] 固化通路 9 环节 0/9 | verified（静态） |
| §1 涉事会话 4 条关键事实 | [22] 涉事会话 4 条关键事实 | ①编造声称原文 / ②真实额度账本 / ③幻觉固化落点 = verified；第 4 条「FACT LOCK 零产出」= **fp（fp-1，已撤回）** |

**口径说明（17/3/2 的计数基础）**：S7 自报 verified 17 = 清单中**完全复现**的 [1]-[7]、[10]-[11]、[13]-[17]、[19]-[21] 共 17 项；[8]/[18]/[22] 主体亦复现但各带子项瑕疵（[8] 含 1 处 partial 子项、[22] 含 1 条 fp 子项、[18] 需降级为 INFO），不计入 17。partial 3 = [9]/[12]/[8d]（[8d] 为 [8] 的子项）；fp 2 = [22]-4（FP-1）与 [17] 子结论（FP-2）。

- **partial 3（逐条写明未复现部分）**：
  ① **partial-1｜[9] 全量回归 1315 计数**——未复现部分：92 个 selftest / 1315 PASS 总数未全量重跑，S7 仅抽样 4 个实跑（方向一致，rc 全 0）；
  ② **partial-2｜[12] 部署位精确落后数**——未复现部分：除 `~/.zcode`=19 提交外，其余 3 位的 47/47/56/74 未重新推导（仅证实 4 位内容确有差异）；`.zcode` 缺 Rule 93 全套 = verified；
  ③ **partial-3｜[8d] Rule 38.7「0 命中」字面**（并入 A-08）——未复现部分：核心文件内 `38\.7` 实测命中 1（`critical-rules.md:181` Rule 83 的交叉引用，非正文），「0 命中」字面不成立，仅「核心非权威锚」的结论成立。
- **fp 2（被推翻，不得作为本案事实主张）**：
  ① **fp-1｜[22]-4「FACT LOCK 子代理无 Edit/Write、产物零落盘」**——**假阳性**：独立复核实测终态有产出（child 工具计数 **Edit 20 / Write 3**、`output.txt` **3214B**、运行至 **01:42:45**、`ep03-prompts.md` mtime **01:29:32** 且 FACT LOCK 命中 **32**、spec mtime **01:30:00** 命中 **18**）；S8 取的是 **01:03/01:06 运行中截断快照** → **本报告不主张本案发生过「无产出仍推进」**（G-01 的 verify_done 机器门死代码结论独立成立，不受此影响）；
  ② **fp-2｜[17] 子结论「acceptance 值域完全不校验」**——**措辞修正**：脚本对 `acceptance` 只查「≥1 行命中」是**如实设计**（头部注释只承诺 status/confidence 值域），应表述为「**acceptance 无值域判据**」而非「值域校验失效」。
- **未验证 0**；**跳过 5 项并记录理由**：全量回归全量重跑、3 部署位精确数、README/ARCH 实际路径、archive-plan dry-run 会产生写操作（S5 未实跑，豁免登记）、videop1 业务事实（S7 §④ 逐条理由）。
- **两处措辞修正**：`templates/task_plan.md:497`「除 selftest 零命中」为假（`check-complete.sh`/`auto-finalize.sh` 已消费）；S9 引用的 `SKILL.md:196` 应为 **:195**。
- **编号说明**：表内「报告条目」列用本报告 A-/B-/C-/G- 编号；S7 复核清单引用 S5/S6 原编号（S7 [11] = S5 B-04 = 本报告 B-02；S7 [12] = S5 B-13 = 本报告 B-03），编号不重排。**不在 S7 22 条清单内**的报告条目：A-09、B-04、B-05、C-06、G-05 —— 依据见各自「证据锚」列（负结果或 checkpoint 级锚，非 file:line）。

---

## §8 稳定性总体裁决与修复优先级

**裁决：solved = 否（partial）**。本审计**已定位**导致执行产出不稳定的主要机制并给出可执行方案，但**尚未修复**（本任务边界为只读审计 + 提案，修改属 §六 保护区 + §十一 worktree 面，需逐项授权后另开任务执行）。

修复优先级（每条均已写成可执行条目，见 `revision-proposals.md`）：

| 优先级 | 主题 | 条目数 | 为什么排这个位置 |
|--------|------|-------|----------------|
| **P0-① 生效通道** | 把资源/额度类事实断言守卫生口提到常驻面（SKILL.md）+ 补「证据时序」判据 + 封堵「事后定性写进宪法」通路 | 4 | 直接堵住 R3 案例的 skill 侧根因；其余修复若不先做，仍会被现行加载位的旧版技能架空 |
| **P0-② 守卫有效性** | 宽锚计数守卫、恒真断言、配对门假 PASS、派发端 3/8 字段、标题形态门、伴飞门误拦、blocked 值域 | 7 | 这些是「假 PASS」——它们让自测绿灯掩盖真实不一致，是「全绿≠稳定」的直接成因 |
| **P0-③ 部署与在途** | 4 站部署位同步、deploy 门改为可阻断、在途 3 文件固化 | 3 | 现行加载位缺 Rule 93 全条 + 51.9–51.13 未部署 → 修完源码不生效即等于没修 |
| **P1 簿记与索引** | 8 个 complete 计划归档、7 个无计划目录、3 个零 Status、INDEX 双差集与列错配、账本补 landed 行、收窄 EXEMPT_DANGLING | 6 | 影响可追溯性，不直接影响当次产出正确性 |
| **P1 契约与文本** | S-unit 上限双轨、22.5 三证据口径、22.5 指向已删章节、Rule 75 双认领、Rule 91 索引、Rule 38.7 假锚、Rule 82 双载矛盾、.backup 副本树治理 | 8 | 清理类，可批量处理 |
| **P2 契约文本（RP-29）** | Rule 34/30 索引与 `README.md:48/:69`、`ARCHITECTURE.md:54/:101` 区间表述修正 | 1 | 清理类，可批量处理 |
| **跨项目裁决项** | `videop1/AGENTS.md:84` 反例判例是否撤回（RP-30 = P0）；quotafact 计划档中的定性表述（RP-31 = P1） | 2 | 跨项目，且涉用户裁决权，本任务不得代决 |

**本次审计未能覆盖的面（诚实披露）**：① 4 个部署位各自的历史演进与是否含未知分叉（只做漂移面，未做逐文件语义比对）；② `.backup` 副本树中 557 个旧 selftest 是否含被误当作活树的资产；③ videop1 项目侧规则体系本身的完整审计（本次仅就 R3 案例取证）；④ 行为面冒烟（新会话加载新版技能后的真实执行轨迹）。

---

## 附：证据索引

| 检查点 | 内容 | 行数 |
|--------|------|------|
| `subagent-state/S1-explore.md` | 技能全树/规则载体/守卫脚本/编号/plans 簿记盘点 | 615 |
| `subagent-state/S2-explore.md` | 4 部署位漂移 + 主仓 git 状态 | — |
| `subagent-state/S3-auditor.md` | 规则三面一致性（A-01~A-09） | — |
| `subagent-state/S4-runner.md` | 全量回归基线 92/92 + 门脚本抽样 | — |
| `subagent-state/S5-explore.md` | 部署与簿记面（B-01~B-20） | 404 |
| `subagent-state/S6-critic.md` | 派发契约四载体比对（24 条） | — |
| `subagent-state/S7-verifier.md` | 独立复核裁决（verified 17/partial 3/fp 2/unverified 0） | — |
| `subagent-state/S8-runner.md` | 涉事会话一手取证（含可复现命令清单） | 222 |
| `subagent-state/S9-auditor.md` | 事实编造类守卫生口矩阵 + 补强方向 14 条 | 192 |
| `findings.md` | 全部结论回填（Rule 19.1） | — |
