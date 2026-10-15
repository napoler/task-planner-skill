# S1 记录域机制审计（2026-10-15）

## 结论摘要（≤5 行）
- 机器面载体总体齐全（10 个自测脚本、check-complete 三大 GATE、attest 锚门均在位），但「记录 vs 现实」的真实性校验几乎全落在 LLM 自评，无独立验证者（C 类结构性缺口集中在 ledger/checkbox/证据路径三层）。
- 规则文本与机器实现存在多处漂移：51.1a 写「三锚门」而 attest 实为「四锚」；check-dispatch/check-3file-gate 脚本注释引用的 Rule 60.2/60.5 权威源实为 62.2/62.5；Rule 82 边界清单漏列 81/83。
- C56/C57 合规清单编号在 SKILL.md 与 critical-rules.md 间映射矛盾（80/81/83 三处争用），且 task-v171 瘦身后「合规清单」物理 C 行已不存在，规则文本仍声称 C56/C57 产物在位。
- 用户会话专档（user-session-log，80.4 权威源）无完整性锁：无哈希链/基线 diff，改写历史不可检测，而 task_plan.md 反而有 SHA-256 attest 锁——记录强度倒挂。
- 会话恢复（session-catchup.ts 只读扫描）与 19.3/80.4 恢复协议均无「记录状态 vs git/文件系统」对照校验，跨会话交接靠读序自觉（D 类缺位）。

## 缺口清单（≥5 条）：

- **缺口1 [B类]**：Rule 51.1a 规则文本描述 attest 为「锁定三锚门（标题/R 行/R→VC 映射缺一拒锁）」，但 attest-plan.sh 实际实现「四锚」（第 4 锚=「🧮 根源覆盖表」Rule 53.1 载体，task-v132 对称性修复后未回填规则文本）。
  - 证据：references/critical-rules.md:88 「attest-plan.sh 锁定三锚门（标题/R 行/R 映射缺一拒锁」 vs scripts/attest-plan.sh:162 「必含四锚——51.1 三锚…+ 第 4 锚「🧮 根源覆盖表」」、:199 「缺 Rule 51.1 用户需求原文区块或第 4 锚」。
  - 危害：按规则文本理解锁定标准的实现者/审计者会少认一个 fail-closed 锚；Rule 82 回归防线「删除前实测当前正文而非凭历史登记」所防的正是此类文本滞后——此处滞后已发生且无 selftest 断言两者一致（双份口径=漂移源）。

- **缺口2 [A类]**：执行期「R 锚定复诵」（每 Phase 开启读需求原文并在 progress 段首写 `- **R 锚定**：本 Phase 服务 R<n>`）声称是 v168 强制锚点，但无任何脚本/门控断言该复诵行存在——全 scripts/ 目录 grep「R 锚定」仅 1 处命中（selftest-goal-unit-goal-mode.sh:132，且只是 SKILL.md 行数钉值注释，非行为断言）。
  - 证据：SKILL.md:62 「R 锚定复诵（v168）：Read「🎯 用户需求原文」→ progress 段首行写…与 Goal 或当前动作不符=先修计划再开工」；:117 G2「本 Phase R 锚定复诵已写…☐」（纯人工自查框）。
  - 危害：复诵是「防上下文偏移」的第一锚点（用户核心诉求原话），LLM 漏写时无任何门控触发——偏移进入执行循环而记录面保持沉默，恰是用户要求的「主动发现不合理」缺位场景。

- **缺口3 [A类]**：Rule 81.6/83.4 声称自测脚本承载「合规清单 C56/C57 行」断言，但对应脚本实际无此类断言，且 task-v171 瘦身后 SKILL.md 合规清单已只剩 G1-G10（C 编号物理行不存在）——规则声称的产物指向空对象。
  - 证据：references/critical-rules.md:159 「合规清单 C56 行（S9 产物）」、:177 「合规清单 C57 行」 vs scripts/selftest-archive-plan.sh:6（头注自述仅 AP-01..AP-16 动态行为断言，正文 grep「C56/合规」0 命中）、scripts/selftest-channel-fast-fail.sh:2-4（头注自述 CF-01..06，无 C57）；SKILL.md:114-125 合规检查清单仅 G1-G10。
  - 危害：「声称自测守护 X」但自测未断言 X = 回归防线虚标；后续维护者按 81.6/83.4 文本去查 C56 行会扑空，误判守卫已移除（记录失真+维护幻觉）。

- **缺口4 [B类]**：C56/C57 编号在两份权威文档间映射矛盾，三处争用同一编号：SKILL.md 把 C56=Rule 80、C57=Rule 81；critical-rules.md 把 C56=Rule 81、C57=Rule 83；selftest-knowledge-brief.sh 又钉「Rule 81 归档步骤+C56」。
  - 证据：SKILL.md:124 「G9 | 用户会话逐字记录自查（Rule 80，原 C56 并集承载）」、:125 「G10 | …（Rule 81，原 C57 并集承载）」 vs references/critical-rules.md:147 「…fail-closed 可机器守卫的纪律——…+ 合规清单 C56」、:177 「Rule 83…合规清单 C57 行」 vs scripts/selftest-knowledge-brief.sh:42 「Rule 81 归档步骤+C56 使 master 版 SKILL.md 实值 559」。
  - 危害：C 编号是规则落点的索引锚；同一编号指向 3 个不同规则=索引失真，按 C 号检索守卫时必然查错对象（Rule 80 的会话记录纪律与 Rule 83 的通道快速失败被同一 C57 争用），是「前后对照」机制自身的对照基准已污染。

- **缺口5 [B类]**：脚本注释引用的规则编号系统性漂移——契约收窄 lint 权威条款是 Rule 62.2，kb 蒸馏门控权威条款是 Rule 62.5，但脚本注释写 Rule 60.2/60.5（该编号在 discipline 卫星实际对应「主动枚举替代方案/停止上报最小集」，与所承载机制无关）。
  - 证据：scripts/check-dispatch.sh:90 「契约收窄 lint（Rule 60.2 不可收窄禁令; 挂既有 get_mode() 档位:」、:172 同、scripts/check-3file-gate.sh:141 「[task-v145 S-2 Rule 60.5] kb 蒸馏语义信号」 vs references/critical-rules.md:105 「62.2 派发读写契约不可收窄禁令…机器面 = check-dispatch.sh 契约措辞 lint」、:111 「62.5 知识增量门控…check-3file-gate.sh --require-kb」；scripts/selftest-four-file-dataflow.sh:13 正确写「62.2 lint 实现锚」；critical-rules-discipline.md:296 「60.2 主动枚举替代方案」、:310 「60.5 停止上报最小集」。
  - 危害：task-v145 时编号为 60.x、重编号为 62.x 后脚本锚未随迁（与 Rule 82「迁移后 selftest 断言指向归属 home」同范式的漂移变体）——按 60.2 查「不可收窄禁令」会查到完全无关条款，规则索引在脚本层断裂。

- **缺口6 [B类]**：Rule 82 边界条文列出「核心只保留 12 条规则（1,2,3,5,19,20,26,51,62,66,80,82）」，但核心 critical-rules.md 实际含 14 个规则节（81、83 已落核心，SKILL.md 索引亦为 14 条）。
  - 证据：references/critical-rules.md:165 「核心 references/critical-rules.md 只保留核心域规则全文（1,2,3,5,19,20,26,51,62,66,80,82）」 vs 同文件:147 「### 81 计划完成后归档纪律」、:169 「### 83 通道不可用快速失败」；SKILL.md:9 「核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83」、:175 「核心在位 14 条」。
  - 危害：Rule 82 的分层纪律自述与实际规则数不符（81/83 落地后未级联更新 82 边界清单）——正是 82 自己声明要防的「索引编号区间与实际规则数不符」；后续按 82 条文做删留配对核验会把 81/83 误判为「核心不该有的非核心域规则」。

- **缺口7 [C类]**：user-session-log「append-only 只写不改」（80.2，用户原话 R5 铁律）无任何完整性载体：无哈希链/无基线 diff，历史条目被回头改写、删除、重排时机器面不可检测；check-complete SESSION-LOG GATE 只查「文件存在+非空+≥1 条 `## #N`」且默认 warn 档不阻断；80.5 明确把会话专档排除在 SHA-256 attest 锁之外。
  - 证据：references/critical-rules.md:136 「80.2 只写不改（append-only）：历史条目禁修改/禁删除/禁重排」、:142 「task_plan.md 受 Rule 20/51.7 哈希锁…故用户会话记录禁入 task_plan.md 正文，外置本专档」 vs scripts/check-complete.sh:1163-1172 「sl_entries=…grep -cE '^## #[0-9]'…（warn 档不阻断; 设 TASK_PLANNER_SESSION_LOG_ENFORCE=enforce 升级为阻断档）」；scripts/selftest-session-log.sh:2-9 头注「纯 grep/awk/jq 静态断言」（SL-01..10 全为规则文本锚，无运行期完整性校验）。
  - 危害：80.4 把会话专档定为「用户原话事实源/权威源」，但该文档的记录强度反而弱于 task_plan.md（有锁）——恢复会话时读到被篡改的历史条目，系统无任何发现手段，「如实记录」在载体层不成立。

- **缺口8 [C类]**：ledger（19.8 机器层主信号）只有 mtime 维度防伪（「不可 touch 伪造」），内容维度无完整性链，脚本明确将伪造风险让渡给 LLM：「伪造 ledger = Rule 26 无豁免违规，不靠脚本防」；而 Rule 26 Q3 的抽查执行者=被抽查对象本人（执行期自评），无独立验证者。
  - 证据：references/critical-rules.md:30 「ledger 是 19.2 门控的主信号(语义化真实工作,不可 touch 伪造)」 vs scripts/check-3file-gate.sh:128 「无 ledger 的存量计划自然退回 mtime fallback;伪造 ledger = Rule 26 无豁免违规,不靠脚本防」、:21 「mtime 是代理指标,可被无关写入污染」；references/critical-rules.md:66 「执行者自评的速度收益不得作为跳过/压缩验证的理由」（Q1-Q6 核查主体仍是执行者）。
  - 危害：Phase 结束前批量补记 ledger 事件（ts 天然晚于 Started 锚点）即可让 19.2 门控放行而工作并未发生——「记录与现实不符」的最典型结构性入口；主进程单写+无 verifier 使该路径无机器拦截。

- **缺口9 [C类]**：状态翻转与验证记录的真实性停留在「行存在」级校验——check-complete goal-gate 对 66.3 的 `[goal:Gn]` 证据行只做 `grep -q`（行在即过），不校验三要素（验证命令+PASS 结果+产物路径）内容，也不复跑验证命令；verification.md 委派统计/V-N 勾选同为执行者自写。
  - 证据：scripts/check-complete.sh:1566 「if ! grep -q "\[goal:${gid}\]" "$PLAN_DIR_GUESS/progress.md" …then exit 1」 vs references/critical-rules.md:121 「②progress.md 追加 [goal:Gn] 证据锚 行（验证命令+PASS 结果+产物路径，三要素）」；scripts/check-complete.sh:1484 「grep -q '委派统计' …verification.md 委派统计段缺失(C14/Rule 25)」（段存在性校验，无内容核真）。
  - 危害：一条 `[goal:G1] 已完成` 空行即可让 goal-gate 放行，66.3「实跑通过」的 P0 语义在机器面退化为「写了行」——状态与现实可在该门静默分叉。

- **缺口10 [D类]**：会话间交接（恢复）无「记录状态 vs 仓库/文件系统现实」的对照校验——session-catchup.ts 自述「纯只读扫描（readdir/readFile），无写路径」，仅检测最后更新的规划文件与未同步消息；19.3 读序、80.4「先读专档再读 task_plan」均为 LLM 行为协议，无任何脚本对照 git log/实际文件。
  - 证据：scripts/session-catchup.ts:14-16 「* 并行安全: 纯只读扫描（readdir/readFile），无写路径」、:1685 附近 grep git 仅 :268 「1. Run: git diff --stat」（错误提示行，非校验逻辑）；references/critical-rules.md:26 「19.3 恢复会话先读三文件:…三文件缺失任一 = 计划未正确初始化」、:140 「80.4 恢复协议：…先读本文件再读 task_plan.md」。
  - 危害：上会话 progress 记「Phase 2 已 commit」但 git 实际无该提交（或 worktree 合并遗漏）时，恢复读序会把失真记录当事实重建状态——用户要求的「前后对照」在会话边界完全缺位，是幻觉跨会话传播的结构性通道。

- **缺口11 [D类]**：计划期「需求覆盖判据」声明 vs 执行期实绩的对照门（R-COVERAGE，51.3 机器化）只校验表格结构+证据列非空，不验证证据路径真实存在/可读，默认 warn 档不阻断，L0 档进一步降为前 3 行抽查。
  - 证据：scripts/check-complete.sh:851-857 「校验 delivery-summary.md「需求覆盖核对」区块是否逐项覆盖计划 R 行…③ covered/partial 行须带证据路径(…非空 ∧ ∉{无,—,N/A}…）」、:866 「[lane-L0] skip…只校验…前 3 数据行」、:860 「违规时 warn 档输出 WARNING / enforce 档 exit 1（默认 warn）」。
  - 危害：判据声明的是「可观察证据形态（文件在位+绝对路径）」（critical-rules.md:90），但机器面放行「covered + 死路径」——完成声称对照门在证据真实性层面漏判，「前后对照」只对照了形式未对照内容。

## 附：读取的文件清单（绝对路径+行数）
- /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（233 行，全文）
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md（191 行，全文）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh（155-205 行，锚门段）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh（850-905、1154-1200、1483-1484、1527-1567、1685-1744 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-dispatch.sh（52-103、172-182 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-3file-gate.sh（12-21、67、125-154 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/session-catchup.ts（1-60、268 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-session-log.sh（1-40 行+全文 grep）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-archive-plan.sh（1-40 行）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-channel-fast-fail.sh（1-30 行）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-four-file-dataflow.sh（grep 节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh（grep 节选：5、556-562、627-642、760-799 行）
- /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ledger-append.sh（grep sha256/hash/integrity，0 命中）
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/completion-gate.md（7 行，全文）
- /mnt/data/dev/task-planner-skill/skills/task-planner/references/goal-gate.md（7 行，全文）
- /mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/critical-rules-template.md（40-50 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md（6、188-195、290-318 行，节选）
- /mnt/data/dev/task-planner-skill/skills/task-planner/config.json（python 统计 properties=46）

## 负结果（排除项）
- SKILL.md:154 声称 Rule 38.7 权威位置=plan-template-kit critical-rules-template.md:45 + task-discipline critical-rules-discipline.md:191——两处实测命中「38.7 执行通道分级」，锚有效，非 B 类。
- completion-gate.md/goal-gate.md 为 7 行指针 stub，符合 Rule 82「不留镜像副本」，无正文残留。
- SESSION-LOG GATE（check-complete.sh:1154）、ARCHIVE-GATE（:1685）、R-COVERAGE（:850）、goal-gate（:1527）、check-3file-gate/check-dispatch lint/check-plan-dispatch 四锚门均实存，机器面非虚标（但强度/内容核核面见缺口 7-11）。
- selftest-session-log.sh SL-09 实断言 properties=46 与 config.json 实测 46 一致（同文件头注第 7 行写「properties=44」为注释滞后，影响面极小未单列）。

## 行号自检抽查（读过的文件中任选 2 处）
1. references/critical-rules.md:88 —— 复检原文：「51.1a **载体双机制（task-v131 清账）**: …② scripts/attest-plan.sh 锁定三锚门（标题/R 行/R→VC 映射缺一拒锁；fail-closed）」→ 与缺口 1 引用一致，行号准确。
2. scripts/check-3file-gate.sh:128 —— 复检原文：「无 ledger 的存量计划自然退回 mtime fallback;伪造 ledger = Rule 26 无豁免违规,不靠脚本防。」→ 与缺口 8 引用一致，行号准确。
（补充第 3 处：SKILL.md:124 复检命中「原 C56 并集承载」，与缺口 4 引用一致。）

## 最终结论（8 字段块，Rule 22.8.2 T5 同块回收）
status: done
acceptance: 5/5 pass — [1:PASS 检查点文件已落盘(11 条缺口含 A/B/C/D 四类+证据+危害+负结果+读取清单) 2:PASS 缺口清单 11 条≥5 且每条含 file:line+关键摘录 3:PASS 证据均经 grep/sed 实复现 4:PASS 行号自检抽查 3 处全部命中(critical-rules.md:88 / check-3file-gate.sh:128 / SKILL.md:124) 5:PASS 全程只读, 唯一写入=本检查点文件]
files: /mnt/data/dev/task-planner-skill/plans/task-v176/subagent-state/1-explore.md (+1/-0 新建)
evidence: references/critical-rules.md:88→「锁定三锚门」vs attest-plan.sh:162→「必含四锚…第 4 锚根源覆盖表」; check-dispatch.sh:90→「Rule 60.2」vs critical-rules.md:105→「62.2 不可收窄」; critical-rules.md:165→12 条核心清单 vs 实际 14 节(:147/:169); SKILL.md:124/125 vs critical-rules.md:147/177 C56/C57 映射矛盾; check-complete.sh:1566 goal-gate grep -q 仅验行存在; check-complete.sh:1163-1172 SESSION-LOG GATE 默认 warn 仅查存在+≥1 条目
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v176/subagent-state/1-explore.md (status: done)
findings_written: none（派发 prompt 指定产出=本检查点文件, 未要求追加 findings.md 小节锚）
blockers: none
confidence: HIGH
