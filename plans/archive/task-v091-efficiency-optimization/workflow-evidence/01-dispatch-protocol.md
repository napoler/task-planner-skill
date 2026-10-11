# 01 派发协议固定开销取证（领域：dispatch-protocol）

> 审计员：取证-派发协议开销（动态工作流子代理，只读审计）
> 日期：2026-09-27。审计对象 = 本仓 canonical 技能本体 `skills/task-planner/`（SKILL.md 558 行 / critical-rules.md 365 行 / config.json 440 行 / scripts 59 脚本 / templates）。
> 方法：全文 Read SKILL.md、critical-rules.md、config.json、templates/subagent_dispatch.md、templates/task_plan.md 关键段；逐脚本 Read zcode-pretooluse.sh / zcode-userpromptsubmit.sh / zcode-posttooluse.sh / check-dispatch.sh / check-3file-gate.sh / check-complete.sh（门控段）/ attest-plan.sh（门控段）；grep 取证 jq 调用数与门控行号。所有计数来自本轮实际读取，行号为本仓工作区当前版本。
> 交叉参考：plans/task-planner-skill-review/report.md（领域 3 finding 15-17 与本文件无重叠——该轮审 config 消费者与 jq 路径，本轮审协议往返步数）。

---

## 一、主计数：单文件小修改任务（simple）从用户指令到 COMPLETE 的强制协议步数

设定：单文件 ≤300 行修改、ask 模式（config.json:59 `interaction_mode` 默认 `ask`）、direct 非 worktree、按 Rule 38 走 mini 档（2 Phase：实施+验收，共 2 个 S-unit）。这是协议允许的**最轻**路径；standard 档在此基础上加 FMEA/知识储备/委派统计等区块。

### A 段 · 计划建立期（第一个字代码未写之前）

| # | 强制动作 | 锚 |
|---|---------|-----|
| A1 | SessionStart hook 写会话私有哨兵 | SKILL.md:61-62；本会话实况：SessionStart 注入「🚨 哨兵已写入」 |
| A2 | 复述指令 + 复杂度评估（T0） | 宪法 §二（技能外）；SKILL.md:27 Goal |
| A3 | `mkdir plans/{id}/` + `bash init-session.sh` 建 **6 个文件**（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief） | SKILL.md:64,70,556；init-session.sh 共 318 行 |
| A4 | `bun scripts/session-catchup.ts` 中断恢复探测 | SKILL.md:63 |
| A5 | `bash scripts/check-conflicts.sh` 五信号冲突分析 + 隔离决策写入计划 | SKILL.md:71,239 |
| A6 | 选 template_type（Rule 16，15 变体中选） | critical-rules.md:61 |
| A7 | **派 plan-writer 子代理**（路由表：计划撰写 ❌主进程）＝ 1 个完整派发周期：Handoff 登记 Edit → 九字段 prompt Agent() → Read 复核 → findings 回填 Edit → verify_done Edit（≥5 动作） | SKILL.md:371（「计划撰写 plan-writer sonnet-1 ❌」）；SKILL.md:556（brief 由 plan-writer 写入）；critical-rules.md:136（22.5 登记） |
| A8 | 主进程 Read 复核计划产出（委派纪律：子代理产出必须 Read 复核） | SKILL.md:165；宪法 §一 |
| A9 | S1：`sync-todos.sh --json` + TodoWrite 每 Phase 一条 | SKILL.md:72 |
| A10 | `node plan-created.cjs` 清哨兵 | SKILL.md:73 |
| A11 | 展示计划全文 + 28.2.1 口头复述思路（≤5 行）→ **等待用户显式 yes = 1 次强制用户往返** | SKILL.md:79-80,227 |
| A12 | `bash attest-plan.sh` 锁定（内置 check-plan-dispatch.sh + check-template-type.sh + FMEA 门三连） | attest-plan.sh:67,94,119-122 |

**A 段小计：≈15-18 次主进程工具调用 + 1 个 plan-writer 派发周期 + 1 次用户往返。其中与任务内容实质相关的只有 A2（复述）与 A6（选模板）。**

### B 段 · Phase 执行循环（每 Phase 一次，SKILL.md:88-108 明文「6 步顺序执行」+ 2.5/2.6/4.5 三个内嵌强制点）

以实施 Phase（含 1 个 S-unit）为例：

| # | 强制动作 | 锚 |
|---|---------|-----|
| B1 | Edit task_plan.md → in_progress（步 1） | SKILL.md:89 |
| B2 | TodoWrite → in_progress（步 2，与 B1「必须紧邻，禁止只做其一」） | SKILL.md:90 |
| B3 | 2.5 委派检查点：读 Executor 字段判定执行体 | SKILL.md:91 |
| B4 | Handoff 登记表填 1 行（**12 列**：时间/type/type/目标/状态/结论/证据/findings 落点/checkpoint 路径/rescue/retry_count/verify_done） | critical-rules.md:136（22.5）；templates/task_plan.md:356 |
| B5 | Agent() 派发 S-unit：九字段 prompt（首块=三文件绝对路径+读写契约、材料包、brief 锚点引用、验收 2-5 条、禁改清单、worktree 路径、时长预算、**8 字段返回模板+已填示例**、checkpoint 路径、上下文预算 ≤3000 字符/≤4 步枚举）；hook 侧 check-dispatch.sh 跑七项缺项扫描+四项 fine-grain（长度/打包/brief/步骤枚举）+串行槽锁 | critical-rules.md:132-135（22.4/22.4a/22.4b/22.4c）；check-dispatch.sh:36-44,296-355；templates/subagent_dispatch.md（122 行模板随 prompt 注入） |
| B6 | 子代理侧合同成本（对 1 行代码修改）：按需 Read 计划文件 + 执行 Edit + 检查点 T1-T5 落盘（T5 必做＝与返回消息**同块双写**的 8 字段「最终结论」）+ findings.md 追加 `#### [sub:…]` 小节 + progress.md 追加 `[sub:{seq}]` 子项 + 8 字段返回 ≈ **4-5 次额外写/读** | critical-rules.md:133-134,142（22.4a/22.4b/22.8.2）；templates/subagent_dispatch.md:77-91（返回前必做 4 条+T1-T5） |
| B7 | 主进程返回后 30s 内 Read 实际产出复核（禁信自报） | SKILL.md:165,440 |
| B8 | findings 回填 Edit（子代理未自写时兜底）或复核其小节（19.1/22.5 双条件之一） | critical-rules.md:95,136 |
| B9 | Handoff 行第 2 次 Edit：勾 verify_done（=B7 Read ✓ + B8 回填 ✓ 双条件） | critical-rules.md:136；SKILL.md:94 |
| B10 | `ledger-append.sh` progress 事件（19.8 语义工作信号） | SKILL.md:96；critical-rules.md:101 |
| B11 | progress.md 动作留痕 Edit（3c） | SKILL.md:96 |
| B12 | `bash check-3file-gate.sh`（19.2 硬门控：findings 本 Phase 实质增量 + progress 回填，exit 1 禁翻转） | SKILL.md:99；critical-rules.md:96；check-3file-gate.sh:1-16 |
| B13 | Edit task_plan.md → complete + 勾 checkbox + V-N Evidence（步 4） | SKILL.md:98 |
| B14 | 4.5 提交：`git add <scope 逐文件>` + `git commit`（格式化 message）+ `git status --porcelain` 校验（3 动作） | SKILL.md:100；critical-rules.md:216-218（27.1-27.3） |
| B15 | TodoWrite → completed（步 5 前半） | SKILL.md:101 |
| B16 | `bash sync-todos.sh --index` 刷 INDEX（步 5 后半） | SKILL.md:101 |
| B17 | `Skill("plan-resume")` 被动扫描——执行期「仅报告不续推」，写 plan-resume-report.md + 打 ≤5 行摘要 | SKILL.md:107；critical-rules.md:161,166 |
| B18 | `Skill("task-drift-guard")`（步 6）+ C4a `check-drift.sh --json` | SKILL.md:102,181 |
| B19 | （每 2 个 Phase 一次）`check-context-hygiene.sh` | SKILL.md:92 |

**B 段小计：1 个 S-unit 的实施 Phase ≈ 19-22 次主进程动作；真实工作只有 B5 的 1 次 Agent 派发（子代理内部 1 次 Edit）。验收 Phase 再跑一轮（≈15-18 次，跑测试本身又是 1 次派发）。**

### C 段 · 终验交付（SKILL.md:158-171）

| # | 强制动作 | 锚 |
|---|---------|-----|
| C1 | Read verification.md + 逐条 VC 复验（mini VC≥2 / standard VC≥5 且每 Phase V-N≥2）+ Evidence 勾选 Edit | SKILL.md:159-163；config.json:6-17（max_vc=5/min_verification_per_phase=2）；check-complete.sh:678（VC-GATE） |
| C2 | 委派率统计写入 verification.md「委派统计」段（Edit） | SKILL.md:161 |
| C3 | 质量门控统计 Q1-Q6 + **抽查 ≥3 条 Evidence**（Read 可达/命令可复现） | SKILL.md:163；critical-rules.md:187-194（26.1 Q1-Q6） |
| C4 | git porcelain 终验（scope 无未提交变更） | SKILL.md:167；critical-rules.md:220（27.5） |
| C5 | `bash check-complete.sh`：单脚本连过 **9 门** — 3-File Gate(:298)/DELEGATION GATE(:448，重跑 check-delegation.sh stats)/PLAN-DISPATCH GATE(:459，**重跑 check-plan-dispatch.sh**)/FMEA GATE(:501)/RESCUE-CHAIN GATE(:522)/VC-GATE(:678)/SKILL-MODIFY GATE/LEARNING-GATE(:783)/REFLECT-GATE(:825)+scope porcelain 预检 | check-complete.sh（895 行） |
| C6 | 交付报告（COMPLETE/PARTIAL/BLOCKED）+ silent 模式附静默决策清单 | SKILL.md:168,80 |

**C 段小计：≈10-14 次动作。**

### 总计与结论计数

- **mini 最轻路径 ≈ 55-65 次强制协议动作 + 1 次用户往返**（A 15-18 + B 19-22 + B' 15-18 + C 10-14），其中真正的任务工作 = 2 次 Agent 派发（子代理合计 ≈2-3 次实质 Edit/测试）。**簿记：实际工作 ≥ 15:1（按主进程动作计）**。
- 1 个 S-unit 派发周期的固定价 = 主进程侧 6 动作（B4/B5/B7/B8/B9/B10）+ 子代理侧 4-5 合同动作（B6）≈ **10-11 次动作，其中 1 次是工作**。
- 每轮常驻 hook 开销（横切全部动作）：UserPromptSubmit 每轮 = resolve-plan-dir.sh + `attest-plan.sh --verify`（SHA-256 重算，attest-plan.sh:221）+ sed/awk 字段提取 + 注入块（zcode-userpromptsubmit.sh:80-83,95-127；本会话每轮 `===BEGIN-PLAN-DATA===` 即实证）；PreToolUse 每次 Write/Edit = check-scope.sh + check-delegation.sh + check-skill-modify.sh **3 个 bash 进程**（zcode-pretooluse.sh:18,40,57），三脚本 + 适配器合计 jq 调用 0+8+2+9 次；每次 Agent = mktemp + check-dispatch.sh（zcode-pretooluse.sh:70-78）；每次工具 = PostToolUse 计数 + resolve-plan-dir.sh（zcode-posttooluse.sh:36-56，jq 11 处）。
- 复杂任务（complex）增量 = Phase 数 ×B 段 + S-unit 数 ×派发周期；Rule 21.4 串行使墙钟 = Σ各 S-unit 时长（见瓶颈 3）；chain 模式每次交接另加 5 动作（SKILL.md:131-137）。

---

## 二、逐条瓶颈（每条带实证锚；质量耦合 high = 该处提速直接威胁质量门控，不可纯增量删）

### 瓶颈 1：计划建立期 ≈15-18 步固定仪式 + 1 次强制 plan-writer 派发，先于一切实际工作
- **证据锚**：SKILL.md:60-80（初始化→哨兵→init-session 6 文件→session-catchup→check-conflicts→S1 同步→plan-created→展示+复述→等 yes→attest 全链）；SKILL.md:371（路由表「计划撰写 | plan-writer | ❌」——连 ≤2 文件 ≤15min 的 mini 计划也须派发子代理撰写，plan-writer 派发本身又是 1 个 10-11 动作周期）；SKILL.md:556（knowledge-brief 亦为 plan-writer 职责）。
- **任务类别**：both（simple 相对延迟占比最大）
- **质量耦合**：medium（计划质量与用户批准是真门控；但「计划必须由子代理写」对 49 行 mini-lite 模板（templates/variant/mini-lite-type.md）无质量增量——主进程照模板填写的质量风险与其派发成本不成比例）
- **预估影响**：简单任务的动手前延迟约占总墙钟一半；Rule 38 mini 档只减模板区块（419→49 行）不减 A 段步数——A3/A4/A5/A7/A9/A10/A12 全部照付。

### 瓶颈 2：每 S-unit 派发周期固定 ≈10-11 次协议动作，其中 1 次是工作；检查点 T5 与 8 字段返回为同块双写
- **证据锚**：critical-rules.md:136（22.5 Handoff 12 列、派发前后各 1 Edit、verify_done 双条件）；critical-rules.md:132-134（22.4 九字段+22.4a 三文件路径+22.4b 8 字段）；critical-rules.md:142（22.8.2 T5「最终结论=22.4b 同一 8 字段块……防返回消息丢失」——与 B5 返回内容逐字段重复）；templates/subagent_dispatch.md:77-91（返回前必做 4 条 + T1-T5）；critical-rules.md:127（22.1 单步 ≤2 文件 ≤100 行 ≤15min，step_max_files=2 意味着 3 文件任务强制 ≥2 个串行周期）。
- **任务类别**：both
- **质量耦合**：medium（8 字段返回与检查点有 v056 实证支撑——v056 实测 12 次派发 0 次自带三文件（check-dispatch.sh:60-62 注释），契约不可删；但「返回消息 + 检查点最终结论」双写、findings 小节 + progress 子项 + 里程碑行的三路落盘对 ≤15min 短任务是纯重复，短任务返回丢失概率极低）
- **预估影响**：砍掉或合并双写（如短任务 T5 免写、8 字段即最终结论）每 S-unit 省 2-3 次子代理动作 + 主进程 1 次复核读取；2 S-unit 任务省 ≈6 动作。

### 瓶颈 3：Rule 21.4 串行派发铁律——互不依赖的 S-unit 一律串行，墙钟 = Σ单步时长
- **证据锚**：critical-rules.md:122（「无论其是否依赖前序产出，『互不依赖』不构成并行理由……唯一例外：用户显式说可以并行」）；check-dispatch.sh:355-376（serial_slot_check：<plan-dir>/subagent-state/.dispatch-inflight 锁，enforce 档 age<120s 即 exit 2 阻断）；SKILL.md:143（fan-out 下游也逐个串行）。
- **任务类别**：both（complex 多 S-unit 时最重）
- **质量耦合**：**high**（该铁律源于 2026-09-12 用户实证事故 sess_1316c7f8：16 编辑批并行→千级机械残迹+主题跑偏重写+零产出子代理——条款原文自带 Why；提速即动质量红线，只能做「只读 explore 类与写类分槽」这类带护栏的分级，不可整体放开）
- **预估影响**：3 个独立只读探查 = 3× 串行等待；若对只读类（explore/web-search/doc-search，天然无共享写状态）设独立并行槽并保留写类串行，多 S-unit 任务墙钟可降 30-50%，且不触碰写类质量约束。

### 瓶颈 4：每 Phase 必付双检测——plan-resume 被动扫描（执行期零消费）+ drift-guard + check-drift.sh --json
- **证据锚**：SKILL.md:107（「Phase complete 后，在 DRIFT CHECK 之前被动调 Skill("plan-resume")」；「当前计划执行中 → 仅报告不续推（防打断）」——报告文件 `<cwd>/.zcode/plans/plan-resume-report.md` 在执行期没有任何后续消费动作）；critical-rules.md:169（24.7 已有 ≤3 Phase 跳过例外，但 >3 Phase 即每 Phase 必付）；SKILL.md:102,181（drift-guard + C4a check-drift.sh --json）。
- **任务类别**：both
- **质量耦合**：low（plan-resume 执行期分支被自身条款限定为「只报告不续推」——它对当前任务的完成质量零贡献，是面向下一个任务的运维扫描，挂在每 Phase 循环内属于位置错配）；drift-guard 部分medium（真漂移检测，保留）
- **预估影响**：把 plan-resume 从每 Phase 循环挪到交付终态/会话恢复触发点（其自身定义的「恢复触发点」），每 Phase 省 1 次 skill 调用 + 1 次报告写盘；2-Phase 任务按 24.7 本就该跳过，>3 Phase 任务每 Phase 白付一次。

### 瓶颈 5：C1-C27 合规清单 27 项逐 Phase 确认，未命中项也强制「记一行」
- **证据锚**：SKILL.md:173-204（表格标题「每 Phase 开始前逐项确认」）；SKILL.md:196-204（C19「未命中错误指出 → 本项 N/A 记一行」、C20「无禁令命中 → 本项 PASS 记一行」、C23/C24/C25/C26/C27 同构——N/A/PASS 也要落一行）。
- **任务类别**：both
- **质量耦合**：low（命中项是真门控，N/A 项登记是防「跳过不查」的留痕代理——可用更便宜的机器判定替代人工落行）
- **预估影响**：典型简单任务每 Phase ≥7 项 N/A/PASS 记录 ×2 Phase ≈ 14+ 条无信息量写入（写入对象是 progress/计划三文件，又反过来喂 3-File 门控的 mtime 信号）。改为「仅命中项落行 + 未命中项由终验脚本批量断言」可省每 Phase 5-7 次写入。

### 瓶颈 6：终验 9 门连跑中 PLAN-DISPATCH GATE 与 attest 期重复校验（计划已 SHA-256 锁定时）
- **证据锚**：check-complete.sh:459（终验重跑 `check-plan-dispatch.sh`）对照 attest-plan.sh:67（锁定时已跑同一脚本）；计划锁定后每轮 UserPromptSubmit 校验 SHA-256（zcode-userpromptsubmit.sh:80-90 → attest-plan.sh:221），哈希未变 ⇒ 计划文本逐字节未变 ⇒ 派发形状校验结果必然相同。同类重复：3-File Gate 每 Phase 已由 check-3file-gate.sh 硬查（critical-rules.md:96），check-complete.sh:298-299 终验再查（该重复有回填丢失防护价值，耦合中等，仅 PLAN-DISPATCH 一项属纯重复）。
- **任务类别**：complex（返工重验时每次全量重付）
- **质量耦合**：low（防篡改已由 attestation 层独立承担；「计划哈希未变则跳过形状重校」不弱化任何门控——哈希变了本来就走 TAMPERED 分支）
- **预估影响**：终验省 1 个子脚本（278 行）执行；更重要的是为「终验快速重跑」铺路——复杂任务返工后的终验当前是全量 9 门重付。

### 瓶颈 7：ask 默认模式每任务 ≥1 次强制用户往返（D1 yes + 28.2.1 复述）
- **证据锚**：config.json:59（`interaction_mode` 默认 `ask`）；SKILL.md:79（「等待用户显式 yes——无授权禁止执行」）；SKILL.md:227（28.2.1 复述+登记 Decisions Made）。
- **任务类别**：simple（相对延迟占比最大）
- **质量耦合**：**high**（用户批准是授权门控与 D6 同级语义，不可静默化；只能改默认档或对 mini 档给「silent + 交付复核清单」推荐项，属用户裁决项）
- **预估影响**：简单任务墙钟下限 = 用户响应时间，无人值守场景直接阻塞；mini 档默认 silent（静默决策清单已有 28.4 承载复核）可消掉该往返，但须用户显式裁决（宪法 §四 D1 语义）。

### 瓶颈 8：PreToolUse 每次 Write/Edit 串行 3 个 bash 守卫 + 每轮 UserPromptSubmit 重算 SHA-256 + 每次 Agent 1 个守卫——纯进程孵化延迟
- **证据锚**：zcode-pretooluse.sh:18,40,57（同一 hook 内 check-scope.sh → check-delegation.sh → check-skill-modify.sh 三连 bash 子进程；适配器自身 jq 9 处 + check-delegation.sh 8 处 + check-skill-modify.sh 2 处）；zcode-userpromptsubmit.sh:80-83（每轮 `bash attest-plan.sh --verify` 子进程 = SHA-256 重算，attest-plan.sh:221）；zcode-pretooluse.sh:70-78（每次 Agent mktemp + check-dispatch.sh）；zcode-posttooluse.sh:36-56（每次工具调用计数 + resolve-plan-dir.sh，jq 11 处）。
- **任务类别**：both
- **质量耦合**：low（守卫语义全部保留，纯执行形态合并：三脚本合为一次 bash 调用/单次 stdin 解析；SHA-256 结果可按 plan mtime 缓存）
- **预估影响**：每任务 50-100 次工具调用 × 每次 2-4 个子进程 ≈ 150-400 次进程孵化；单次数十至数百 ms，合计纯延迟数十秒级，零行为收益零风险，是最安全的 Tier A 优化面。

### 瓶颈 9：委派率 floor 0.7 + Rule 14 仅 ≤3 行豁免——3 行至 300 行之间的微小任务无直做通道
- **证据锚**：config.json:36-42（delegation_rate_floor 默认 0.7，低于 → outcome 最高 PARTIAL）；critical-rules.md:55（Rule 14：仅 ①计划系统文件 ②原生 Todo ③**单文件 ≤3 行 trivial** 可主进程直做）；critical-rules.md:176（25.3 白名单⑥同口径）；critical-rules.md:191,203（26 Q5 惩罚映射）。
- **任务类别**：simple
- **质量耦合**：medium-high（「主进程=调度器、降低主进程亲为」是 SKILL.md:31 明文第一设计目标，动机真实；但 ≤3 行与 ≤300 行之间无规模分级——20 行文档小改与 300 行重构走完全相同的全周期派发，其上下文保护收益对前者趋近于零）
- **预估影响**：20 行小改 = 1 次 Edit 被放大为 ≈10 次协议动作的派发周期（简单任务慢的最大单一来源）。可选缓解：mini 档下白名单⑥扩为「单文件 ≤30 行非保护区 + 登记」，或对 mini 计划把 floor 降至 0.0（check-complete.sh:38.4 已有 mini floor=0.0 先例——但那只在声明 plan_tier: mini 时生效，Rule 14 的 ≤3 行硬线并不随 mini 放宽）。注意：动此线 = 动 Rule 14/25 质量语义，必须交用户裁决。

### 瓶颈 10：19.2 门控「findings.md 本 Phase 实质增量」迫使纯实施 Phase 制造增量
- **证据锚**：critical-rules.md:96（19.2 双条件②「findings.md 在本 Phase 期间有实质增量」+ ledger/mtime 信号「任一信号不满足 → exit 1」）；check-3file-gate.sh:12-16（「宁可误报（代价=多一次回填动作），不可漏报」——设计取向自认以误报换安全）；配合瓶颈 5 的 N/A 记行，无调研内容的 Phase 也必须 Edit findings 一次才可翻转 complete。
- **任务类别**：both
- **质量耦合**：medium-high（3-File 落盘是防 Context Stuffing 的 P0 核心机制（Rule 19），不可削；可调的只是「每 Phase 必有增量」的粒度——如纯实施 Phase 允许一行「本 Phase 无调研产出，证据=产出文件路径」计入增量，语义仍诚实）
- **预估影响**：每 Phase 省 0-1 次制造性写入；主要收益是把「为过门而写」的形式化内容从 findings 里清出去（findings 质量本身受益），动作数收益小。

---

## 三、计数口径声明与未覆盖项（如实）

1. 步数为**协议文本规定的最小值**（全部动作一次通过、无返工无失败），实际执行因失败兜底（22.3 五档）、[plan-compass]/[plan-sync] hook 提醒响应（SKILL.md:97）只增不减；本会话自身即 Living proof：SessionStart 哨兵注入 + 每轮 ===BEGIN-PLAN-DATA=== 复诵均为实况观察。
2. 「主进程动作」按一次工具调用计；AskUserQuestion 交互、用户思考时间未计入。
3. 未逐一实跑 27 个 selftest 计时（本轮为静态文本审计 + hook 链 grep 计数，未做端到端计时实验）；「每次 bash+jq 数百 ms」为量级推断，未实测——已在瓶颈 8 影响栏措辞中保持量级而非精确值。
4. 上一轮审查报告（plans/task-planner-skill-review/report.md 领域 3 #15-17）指出的 jq 单层路径致 config 覆盖失效（check-plan-dispatch.sh:115-116 等）与本领域互补：那类 bug 使 step_max_* 等阈值静默回退默认值，意味着本文件引用的数值门控在用户改过 config 时可能并未按配置生效——两个发现叠加时，瓶颈 2 的「≤2 文件/≤100 行/≤15min」强制拆分面可能比文本更大（回退默认值=维持最严档）。
5. 瓶颈 1/7/9 涉及 Rule 14/25/28 语义边界与用户 D1 裁决权，属提案期决策项；本文件只给证据与耦合评级，不建议具体改法。
