# sess_ba603cf5 技能规则缺口审计（task-planner 技能体系）

- 审计对象：`/mnt/data/dev/task-planner-skill/skills/`（task-planner / task-dispatch / task-discipline / todo-skill）
- 证据来源（直接采信，未重新取证）：`forensics/sess-ba603cf5-transcript-findings.md`、`forensics/sess-ba603cf5-project-findings.md`
- 方法：静态条款取证（grep 定位 + 原文逐字摘录）→ 与取证根因链对照 → 缺口定性 → 文本级最小修复草案
- 纪律：本报告**不修改**任何 skill/agent 文件（§六保护区）；所有修复仅为可直接落地的条款文本草案；零脚本、零 config 键扩张（遵循体系既有「文本优先/零新键」纪律）
- 关键事实锚（采信）：会话跨 `2026-11-17T06:50Z→11-18T03:41Z`（约 9h，`transcript-findings.md:16`）；54 子代理、1797/2036 工具调用来自 subagent（Read 598/Bash 864/Edit 129，`transcript-findings.md:319`）；目标被操作化为「逐集闭环 EP33–EP44」（`project-findings.md:210-212`）

---

## 结论总览

| 问题 | 判定 | 性质 | 优先级 | 置信度 |
|---|---|---|---|---|
| A 子代理总量预算 | **缺口成立**：仅有每 Phase/每派发局部上限，无全局总数/总轮次/总时长上限 | 确实缺失条款 | P0 | HIGH |
| B goal 范围无限扩展 | **缺口成立**：28.8 强制自治 + 94.7「全部」豁免叠加，无范围锚定与分批 checkpoint | 确实缺失条款（现有条款被豁免洞绕过） | P0 | HIGH |
| C 同一文档返工上限 | **缺口成立**：QC FAIL 后无条件重开双轮；无内容返工次数硬上限；67.1 仅「评估」不 STOP | 确实缺失条款 | P0 | HIGH |
| D worktree 产物提交 | **条款已存在，属执行违规/漂移**；但豁免措辞对「创作型 .md」边界模糊，是漂移借口 | 已有条款未生效 + 边界措辞缺口 | P1/P2 | HIGH |
| E 公共上下文重复读取 | **部分缺口**：62.4 先查后调机制存在但仅覆盖调研型；103.3a 全文回读义务反向放大 | 已有机制覆盖不足 | P1 | HIGH |
| F worktree 规则版本校验 | **缺口成立**：feedback 记忆有明确 How-to-apply，技能条款无对应硬门 | 已有记忆未固化为条款 | P1 | HIGH |

归属：**A/B/C/E/F 为本次应修的技能缺陷**；**D 主要为 StoryLab 执行违规（次要为条款边界措辞）**；剧本文档流水线本体（S2–S6 阶段、QC-G2/G3/G4 门禁、人数词面系列规范、单文档 clean/log 形态）属 StoryLab 项目自身 script-craft 定义，**不在本仓，本次不动，仅报告**（见文末划分）。

---

## A. 子代理拆分：有没有全局总数/总轮次/总时长预算上限？

**检查**：Rule 59（粒度硬门）、Rule 46.6（单元上限）、Rule 96（并行激活）、Rule 22.1/21.1b、config.json 预算键。

- **[ISSUE] 子代理总量预算缺失**
  - 检查：全局预算闸门 existence
  - 结果：**失败（确实缺失条款）**
  - 证据：
    - `skills/task-dispatch/references/critical-rules-dispatch.md:155` 原文：「每个 S-unit 必须在 task_plan.md S-unit 表强制填报三值 Nf/Nl/Nmin（文件数/新增行数/预估分钟…）」——59.1 只约束**单个 S-unit 的大小**，不约束总数。
    - `.../critical-rules-dispatch.md:51` Rule 22.1 原文：「单 Phase 内 `Agent()` 派发次数 ≤`../../task-planner/config.json#subagent.max_per_phase`(默认 5)」——**仅每 Phase**，非全局。
    - `skills/task-planner/config.json:496-504` 原文：`"max_per_phase": 5, "retry_limit": 2, "max_files_per_dispatch": 3, "step_max_minutes": 15`——全是**局部/单次**阈值，无任何 `global_max_*` / `total_*` 键。
    - `.../critical-rules-dispatch.md:217` Rule 96.5 原文：「追加三行——① **激活子代理数**（Agent() 派发总次数）② **最大并行宽度**…」——只**统计留痕**，不设上限、不触发刹车。
    - `.../critical-rules-dispatch.md:191` Rule 96 标题原文：「①治「激活率低」…②治「并行推进率低」…」——体系导向是**鼓励多用**子代理，无反向刹车条款。
  - 机制：局部上限的聚合漏洞——11 集 × 每集 9–12 子代理（`project-findings.md:232`：「每集典型链：知识包/剧本→QC-G2→S4修正→QC-G3→独立二审→分镜→QC-G4→修正→r2复审→S6归档」）只要把每阶段登记为独立 Phase，`max_per_phase=5` 与 46.6「1 单元/派发」**逐项全合规**，54 轮累计无人叫停。这正是 8–9h 的直接放大器。
  - 最小修复建议（P0）：在 `critical-rules-dispatch.md` Rule 96 后新增 **Rule 96.7（全局预算闸门，文本锚，零新 config 键）**：
    > 「**96.7 全局子代理预算与长序列分批 checkpoint**：单一会话/单一 `/goal` 目标迭代内 `Agent()` 累计派发 **>40 次** 或累计执行时长 **>60 分钟**，任一先到即触发**强制 checkpoint**——停止新派发，向用户呈报「已完成单元/剩余单元/已耗预算/推荐续批范围」，经确认后续批；同一 goal 内禁止静默续批。可数交付单元 **>20** 的长序列任务，计划期必须拆为多个独立分批计划（每批 ≤10 单元），批间以 checkpoint 交接，禁止单计划承载全序列。阈值可按 Decisions Made 登记调整，但不得取消 checkpoint 门。（判例锚：sess_ba603cf5 54 子代理/9h）」
  - 置信度：**HIGH**（config 与条款逐行核对，无全局键/条款）

---

## B. 目标膨胀：28.8 会把「用户授权全部执行」误当成无限扩展吗？

**检查**：Rule 28.8、Rule 94.7、Rule 28.2.2、Rule 66 单元固化。

- **[ISSUE] 范围锚定与分批 checkpoint 缺失；现有豁免洞被「全部」命中**
  - 检查：goal 自治 vs 范围扩张门控
  - 结果：**失败（缺口成立，且现有条款被绕过）**
  - 证据：
    - `skills/task-discipline/references/critical-rules-discipline.md:64` Rule 28.8 原文：「所有需用户选择/确认/裁决的点（含 D1-D5、方案/路径/参数取舍、授权征询等凡非用户当轮已明确给出的新裁决）一律按「推荐项/最优可行项」静默自主决策…**禁止**调用 AskUserQuestion、禁止输出「请选择/请确认/回复 yes」等等待式询问」——goal 语境下**禁一切询问**。
    - `.../critical-rules-discipline.md:623` Rule 94.7 原文：「**豁免**：用户原话已显式覆盖该对象范围（含「全部/都/整个/所有/all」类泛指且与对象集合一致）→ 不停，progress 记一行原话锚+覆盖结论后继续」——用户「全部执行」**恰好命中此豁免**；虽同条有「范围上限不可判定时仍须停下复述范围描述」，但被前置豁免抢先。
    - `.../critical-rules-discipline.md:55` Rule 28.2.2 原文：「**goal 语境下 28.2.2 的 ask-选项确认分支一律不适用**——无论明确或歧义/多候选/范围待裁决，均禁止向用户提问…」，同段末：「goal 下阻塞询问致空转复发(sess_ba603cf5)根治需 28.8 显式覆盖 28.2.2」——**注意**：28.8 判例针对的是「反复请求确认死循环」，其解药（全静默自治）却同时**取消了范围扩张的确认机会**。
    - 取证实证：`project-findings.md:210` 子代理 prompt 原文：「用户已授权「全部执行」（逐集闭环 EP33–EP44）」；`project-findings.md:221`：「从「离开罗布湖之后剧本的创作」扩展为 EP33-EP44 全量剧本+分镜流水线闭环，显著放大了工件数量…」。
  - 机制：28.8「禁问」+ 94.7「全部豁免」双重叠加 → downstream 把「全部执行」自由复述为 EP33–EP44 且无人复核范围上界 → 11 集规模爆炸（根因 1）。**没有**「可数单元上界锚定 + 分批交付 checkpoint」任一条款；Rule 66 goal 单元表只固化**已批准计划内**的 goal，无法约束**计划外范围扩张**。
  - 最小修复建议（P0）：
    1. 修改 `critical-rules-discipline.md:64` Rule 28.8，在②后追加：
       > 「**范围锚定例外（不属禁问范围）**：goal 自治不豁免范围扩张门——计划期须在 user-session-log 固化 Goal 的**可数交付单元上界**（如「EP33–EP39 共 7 集」）；执行中交付单元数超过已登记上界，或跨过 10 个单元仍未 checkpoint，视为新范围，必须按 94.7 停下复述并呈报，禁静默续扩。28.8 的禁问仅覆盖**上界内的执行手段自决**，不覆盖范围扩张。」
    2. 修改 `critical-rules-discipline.md:623` Rule 94.7 豁免句，末尾追加：
       > 「但用户原话的泛指（全部/所有/逐集）**仅在上界可判定时生效**；泛指未给出明确终集/总量时仍须停下复述范围描述、固定单位并登记上界，禁自行推定 N 后按豁免续跑。」
  - 置信度：**HIGH**（28.8 与 94.7 原文逐字对照，豁免命中逻辑明确）

---

## C. 返工循环：有「同一文档返工 N 次 STOP 并换策略」硬上限吗？

**检查**：Rule 103.8、Rule 67.1、Rule 106.3、Rule 18.3、Rule 22.7、Rule 109.2。

- **[ISSUE] 内容返工次数硬上限缺失；QC FAIL 后无条件重开双轮**
  - 检查：rework cap existence
  - 结果：**失败（确实缺失条款）**
  - 证据：
    - `skills/task-dispatch/references/critical-rules-dispatch.md:245` Rule 103.8 原文：「复检 FAIL→Rule 31/32 错误闭环（先归因不直接返工）；**修复后变更集重新走双轮（修复=新修改轮）**」——FAIL 后**无条件**重开 executor+reviewer，无次数上限、无换策略门、无上抛。
    - `.../critical-rules-discipline.md:377` Rule 67.1 原文：「**高危信号档**：periodic-review 判 CONTRADICTION…、**同一文件 ≥3 次往复修改**…」——触发的是「**当次评估**」（原文「三档信号任一命中即当次评估」），**不是 STOP、不是换策略、不是上抛**。
    - `.../critical-rules-discipline.md:741` Rule 106.3 原文：「同一文件在本任务内被第 ≥2 次修改后，复检面自动升级为「全文档不变量回归」」——只加严复检面，**不叫停**。
    - `.../critical-rules-discipline.md:38` Rule 18.3 原文：「累计 failure_rate；>5% → STOP 报告等决策；>20% → 自动熔断」——管的是**失败单元比例**，非同一文档返工次数。
    - `.../critical-rules-dispatch.md:68` Rule 22.7 原文：「子代理连续失败 ≥2 次 →…换档重试…⑤ STOP 报告用户」——管的是**工具/子代理运行失败**，非 QC 内容判定 FAIL。
    - `skills/task-planner/references/critical-rules.md:200` Rule 109.2 原文：「REJECTED→打回修正…轮次不设上限；**连续 ≥3 轮无实质进展→呈报用户裁决**」——这是**计划审计门**的唯一「3 轮上抛」先例，**未覆盖 QC 内容返工**。
  - 机制：EP33 人数词面 13 处 MAJOR→修正→rereview、EP34 BLOCKER→补写→G3复审、EP35 MAJOR→r2 等（`project-findings.md:178-185`）每次都合法触发 103.8 新双轮；67.1 的「≥3 次往复」只提醒评估，模型在「不要怕浪费资源」文化下继续迭代。无归因分层强制 → 模板口径错误被逐处修、规范漂移被按新规反复判错（见 F）。
  - 最小修复建议（P0）：在 `critical-rules-dispatch.md` Rule 103.8 段末追加（或新增 103.8b）：
    > 「**103.8b 同一交付物返工上限（rework cap）**：同一 canonical 文件（同一绝对路径）因 QC FAIL/MAJOR 进入**第 3 轮返工前必须 STOP**，禁止无条件重开 executor+reviewer 双轮。主进程先做归因分层（①模板/口径错误②规范版本错配③执行疏忽④需求歧义），按归因换策略（①→全系列批量修模板而非逐处改；②→对齐版本后重做，见 worktree §4①-校验；④→呈报），并在 progress 登记 `[rework-cap]` 三件套（已返工轮次/归因/换策略）。仅换策略后的首轮可继续，禁止同策略第 3 轮。与 104.5 分工：104.5 管工具失败，本条管内容返工。（判例锚：EP33–EP39 多起同文档返工）」
  - 置信度：**HIGH**（六个相关条款逐一核对，仅 109.2 有计划域上抛，QC 域确无）

---

## D. worktree 产物提交：现有规则是否要求阶段性 checkpoint 提交？

**检查**：Rule 27 全文、worktree-isolation.md §4/§4 合并合约。

- **[AUDITED] 阶段提交条款** —— 检查：worktree 逐 Phase commit 门控 — 结果：**通过（条款已明确存在）** — 证据：`skills/task-discipline/references/critical-rules-discipline.md:214` Rule 27.1 原文：「实现类 Phase…在执行循环步骤 4.5 完成提交，才可翻转 complete…**禁止跨 Phase 攒批、禁止留到终验才提交**」；`skills/task-planner/references/worktree-isolation.md:63-66` 原文：「③ worktree 内提交 — **每 Phase 完成即提交(Rule 27)，禁止攒批到最后**；禁止把未提交变更带回合并」；同文件 `:87` 合并合约第 2 条：「worktree 内无未提交变更(git status 干净)」。 — 置信度：**HIGH**
- **[ISSUE] EP33–EP39 全程 `??` 未提交 = 执行违规（非条款缺失）**
  - 检查：条款与实际落点一致性
  - 结果：**失败（执行层）** — 证据：`project-findings.md:196` 原文：「EP33-EP39 在 worktree 为未跟踪产物（`git status` 显示 `?? episodes/ep33..ep39`），无提交历史」。条款在位却未执行 → 属**部署漂移/执行违规**，直接后果是「改错难追溯、难对比、难回滚」（根因 4）。
  - **[ISSUE] 豁免措辞边界模糊（次生条款缺口，P2）**
    - 证据：`critical-rules-discipline.md:214` Rule 27.1 原文：「**纯调研/纯 plans/ 写入(无仓内产物)的 Phase 豁免本条**,progress.md 记一行‘无仓内产物’」——剧本文档为 `.md`，易被误归入「纯文档/纯 plans/」而套用豁免。
    - 修复建议（P2，文本级）：在 Rule 27.1 该句后追加：
      > 「**创作型交付物（剧本/分镜/文案/报告等 .md）不属 plans/ 写入，无论文件后缀均视为仓内产物，必须逐 Phase 提交；‘内容创作文档=纯文档豁免’为禁止解读。**」
  - 置信度：**HIGH**（条款与取证 git status 直接对照）

---

## E. 重复检索：Rule 62 为何没阻止每个子代理全量回读？

**检查**：Rule 62（全条）、Rule 103.3a、Rule 107.0、Rule 22.4。

- **[ISSUE] 公共上下文「一次读取 + 显式引用传递」覆盖不足；且全文回读义务反向放大**
  - 检查：上下文复用机制覆盖面
  - 结果：**部分失败（机制存在但覆盖窄）**
  - 证据：
    - `skills/task-planner/references/critical-rules.md:120` Rule 62.4 原文：「调研型 S-unit 派发 prompt 的材料包摘要**必须**引用 knowledge-brief.md 对应节锚点…**命中已验证结论的禁止从零重调研**」——机制**存在**，但限定词「**调研型 S-unit**」把创作型/QC 型排除在外。
    - 同文件 `:124` Rule 62.6 原文：「适用面 = 所有 Agent() 派发（62.2）与**调研型 Phase（62.3-62.5）**，纯机械 S-unit…豁免」——明示 62.3-62.5 只管调研型。
    - `skills/task-dispatch/references/critical-rules-dispatch.md:235` Rule 103.3a 原文：「复检体收到任务书后**必须完整回读被修改文件的全文（分页读完，非 diff/非片段）**再下判定…触发面=每轮独立复检」——**每轮每复检体强制全文回读**，直接制造重复读取。
    - `skills/task-discipline/references/critical-rules-discipline.md:759` Rule 107.0 原文：「长序列/长文在首个内容单元动笔前，必须先建立或校验总纲…**动笔前全局检索**」——要求检索，但无「读一次后传递引用」的后续机制。
    - 取证实证：`project-findings.md:236` 原文：「子代理 prompt 明确要求全量回读前置材料（如 EP38/39 writer prompt 列出站设计/知识包/前集/continuity/brief 等）…bible/continuity/站设计/skill 规范/前集快照等公共材料被多 agent 重复读取」。
  - 机制：62.4 的复用协议只连到调研型 S-unit 与 kb 节；剧本创作/QC 的公共上下文（bible/continuity/站设计/前集基线/skill 规范）在体系内属「项目级连续性资产」（Rule 107.0），却**没有**蒸馏入 kb 并逐子代理传引用的条款；叠加 103.3a 每轮全文回读义务 → 结构性重复检索（根因 2）。
  - 最小修复建议（P1，文本级）：在 `critical-rules.md` Rule 62.4 后追加 **62.4b**，或在 Rule 107.0 追加：
    > 「**62.4b 公共上下文一次读取与引用传递（创作/QC 型扩展）**：长序列/连续创作任务的公共上下文（bible/continuity/站设计/前集基线/skill 规范）由主进程在计划期一次读取并蒸馏为 knowledge-brief 对应节；后续创作/QC 型 S-unit 派发 prompt 只传「绝对路径 + kb 节锚 + ≤10 行摘要」，禁止要求每个子代理全量回读公共材料。Rule 103.3a 的全文回读义务**仅限被修改文件本身**，不扩张至公共上下文基线；命中 kb 已蒸馏结论的禁止从零重读原文件。62.4 覆盖面由调研型扩展至创作型/QC 型。」
  - 置信度：**HIGH**（62.4/62.6 限定词与 103.3a 原文明确，取证 prompt 实证支持）

---

## F. 版本漂移：创建 worktree 后是否有「校验规则文件与主仓一致」硬门？

**检查**：worktree-isolation.md §4 全流程、记忆 feedback、全技能 grep。

- **[ISSUE] worktree 规则版本一致性硬门缺失（记忆有、条款无）**
  - 检查：worktree 创建后版本校验 gate existence
  - 结果：**失败（缺口成立）**
  - 证据：
    - 记忆 `/home/terry/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/worktree-branch-desync.md:23` 原文（type: feedback）How to apply：「**创建 worktree 后，先检查关键文件是否与主仓一致（行数/关键规则是否存在）；如不一致，从其他 worktree 或主仓 git 历史中获取正确版本。**」——**方法论已存在**。
    - `skills/task-planner/references/worktree-isolation.md:57-60` §4 原文：「① 创建…`git worktree add … -b wt/<task-id> main`」「② 开发:所有文件操作用 worktree 绝对路径…」——创建后**直接进开发，无校验步骤**。
    - 同文件 `:51-55` §4①-备份原文：「worktree 自 main 创建已天然隔离于主仓工作区…①-备份用于清理主仓脏状态与稳定合并回,非 worktree 内容来源」——把 main 当稳定基线，但**未校验 main 的规则版本 == 当前工作分支版本**。
    - 全仓 grep（`skills/` 全域）**未找到**任何「worktree 创建后校验关键规则文件与主仓一致」的条款锚（仅 101.3 讲 SOP 文档间漂移、无版本校验门）。
    - 取证实证：`project-findings.md:201` 原文：「worktree `HEAD c179cee` 为 2026-11-17 旧规则集…而 EP34 创作于 2026-11-18、主工作树已硬化新门禁；审计按现行版判 FAIL 并要求补登记」；`:234`：「创作与审查依据的规则版本不一致时，产物可能‘按旧规完成、按新规判错’」。
  - 机制：feedback 记忆未固化为条款 → worktree 从 main 创建时携带旧规则集 → 创作按旧规、审查按新规 → EP34 BLOCKER 等**纯流程性返工**（根因 5）。
  - 最小修复建议（P1，文本级）：在 `worktree-isolation.md` §4 步骤①之后新增 **①-校验**：
    > 「**①-校验（创建后规则版本一致性硬门，固化为 worktree-branch-desync feedback）**：worktree 创建后、进入②开发前，必须比对 worktree 与当前工作分支（master/HEAD）的关键规则文件（`*/SKILL.md`、`*/references/critical-rules*.md`）的行数与关键规则锚。任一不一致 = **禁止进入开发**，按 feedback 从主仓/其他 worktree 同步正确版本后重校，并在「隔离决策」登记版本锚；**创作与审查必须基于同一规则版本快照，禁止按旧规创作、按新规判 FAIL**。」
  - 置信度：**HIGH**（feedback 原文与 worktree §4 缺步直接对照，grep 全域无硬门）

---

## 技能缺陷 vs StoryLab 项目自身问题（归属划分）

**本次应修的技能缺陷（本仓 `/mnt/data/dev/task-planner-skill`）**：
- A 全局预算闸门（新增 Rule 96.7）— P0
- B 范围锚定 + 94.7 豁免收紧（改 Rule 28.8 / 94.7）— P0
- C 内容返工上限（新增 Rule 103.8b）— P0
- E 公共上下文引用传递（新增 Rule 62.4b）— P1
- F worktree 版本校验硬门（新增 §4①-校验）— P1
- D 次生：创作型 .md 不豁免提交（改 Rule 27.1）— P2

**StoryLab 项目自身 script-craft 流水线问题（不在本仓，本次不动，仅报告）**：
- 每集 9–12 子代理的 S2调研/S3剧本/QC-G2/S4修正/QC-G3/独立二审/S5分镜/QC-G4/修正/r2复审/S6归档阶段定义——属 StoryLab agent/skill 定义（`docs/series/jipin-nvdiaoshou/` 侧），task-planner 只提供通用粒度/预算纪律，不定义剧集工序。
- QC-G2/G3/G4 门禁判据、「3人+1狗」全系列逐字统一规范、`writing-upgrade-ep33plus.md`/`story-completeness-guide.md` 等规范缺口——项目内部规范，需 StoryLab 侧补。
- 单文档 `EPxx-剧本-clean.md`/`-log.md` 形态（无 draft/r1/r2 快照）——项目产物形态约定；技能层 Rule 92（产出文件尺寸/拆分）不强制版本快照。
- 工具失败重试（Edit code 6/8、write_file_not_read ×28，`transcript-findings.md:300-306`）——模型/运行时层，非 task-planner 条款可覆盖。

---

## 负结果报告（检查了但未发现 / 已排除）

1. **检查了** config.json 全部 `max_*`/`budget`/`limit`/`total` 键（`:415-504`）：**未发现**任何全局子代理总数、总轮次、总时长键——A 缺口确认，排除「有键未启用」的可能。
2. **检查了** Rule 18.3 / 22.7 / 67.1 / 106.3 / 109.2 五种「上限/熔断/评估」机制：**未发现**任何一个以「同一文档内容返工次数」为对象——C 缺口确认，排除「已有类似上限只是没触发」。
3. **检查了** worktree-isolation.md §1–§6 全部段落及全 `skills/` grep 版本校验关键词：**未发现**创建后规则版本一致性硬门——F 缺口确认；版本一致性仅存于 feedback 记忆，未入条款。
4. **检查了** Rule 27.1–27.6 与 worktree §4③/§4合约第2条：**确认**阶段提交条款完整存在——D 判定为执行违规而非条款缺失，排除「规则没写」。
5. **检查了** Rule 62.1–62.6 全覆盖：**确认** 62.4 复用机制存在，但限定调研型；E 判定为覆盖不足而非完全无机制，排除「四文件罗盘无用」的过度结论。
6. **已排除**：把 StoryLab script-craft 工序缺陷误判为 task-planner 缺陷——取证显示每集工序由项目 prompt/agent 定义，技能层无对应条款可修，故划归「本次不动」。

## 审计后验证

- 关键发现均经 Read/grep 精确行号复现（A: config + 5 条款；B: 28.8/94.7/28.2.2；C: 6 条款；D: Rule 27 + worktree §4；E: 62.4/62.6/103.3a/107.0；F: feedback 记忆 + worktree §4 + 全域 grep）。
- 验证失败项：无。所有摘录行号与原文一致。
- 本审计**未修改**任何 skill/agent 文件（符合 §六保护区纪律）。
