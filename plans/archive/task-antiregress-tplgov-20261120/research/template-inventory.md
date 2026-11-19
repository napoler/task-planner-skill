# task-planner-skill 模板体系与防倒退现状盘点（只读）

- **盘点时间**：2026-11-20
- **仓库**：`/mnt/data/dev/task-planner-skill`（git repo，HEAD=`76a6466 kb: Rule 110 任务分级×模型档位经验入库（判例 sess_a7eb0603)`，`git log -5` 证据同见）
- **工作树快照**：`git status --porcelain -uall` 显示 18 个已修改(M) + 多个未跟踪(??)，无 staged（证据：`/mnt/data/dev/task-planner-skill` 下 `git status --porcelain -uall`）
- **目的**：为“防倒退机制 + 模板治理体系（原则注入/主动加载/存量模板改造/分级派生 lineage）”设计摸底；判定 18 个未提交修改归属；识别既有防倒退/基线冻结与模板分级现状。

---

## 1. 未提交改动归属判定（18 个 M）

**证据来源**：`git diff --stat HEAD`（18 files, 146 insertions, 424 deletions）、`git diff --name-status HEAD`、逐文件 `git diff -- <file>`；diff 关键字统计 `git diff | grep -c '理解迭代'`=11、`git diff | grep -c 'anti-regress|防倒退|Spec-Baseline|spec_baseline'`=2（且 2 处均为 `knowledge/INDEX.md` 新增条目行，非规则正文新增，证据：`git diff | grep -n 'Spec-Baseline|防倒退|anti-regress|74\.7|51\.15|106\.7|22\.4e|103\.3b'` 命中 `knowledge/INDEX.md` +18/+27 行）。核心/纪律/派发三份 critical-rules 中 74.7/106.7/51.15/22.4e 等防倒退条款正文经 `git blame` 确认为已提交 HEAD（274bb9e3, 2026-11-19），非本次未提交改动（证据：`git blame -L495,495 skills/task-discipline/references/critical-rules-discipline.md` 等）。

| 文件(绝对路径) | diffstat/关键证据摘录 | 主题 | 疑似所属在途任务 | 与本新任务冲突度 |
|---|---|---|---|---|
| `/mnt/data/dev/task-planner-skill/skills/plan-resume/SKILL.md` | -424/+重写，净大幅收缩（438 行变更）。摘录：`v0.6 决策自主化契约...自主推进不等决策点`；§7 细节外移，新增指针 `详见 references/autonomous-resume-detail.md`、`规则全文见 references/critical-rules-resume.md`。无“理解迭代”命中。 | plan-resume 自主续推/决策框架重构与瘦身（v0.4→v0.6 契约压缩、引用外部 references） | **未能从 diff/文件内锚定具体 task-id**（疑似 plan-resume 自治化在途重构；与提示两任务无直接文本证据） | 低（与模板治理/防倒退机制域不重叠；仅技能文档结构变动） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` | +13/-?（13 行变更）。摘录：`- **指令理解对齐（Rule 28.2.2）**：计划确认前须已完成/呈示 3-4 轮理解迭代草稿...`；D1 门控补充 `goal/目标迭代（28.8）优先`；新指令序列插入 `③ 指令理解迭代（Rule 28.2.2...）`；I/O 输出含 `理解迭代草稿（28.2.2...）`。 | 指令理解迭代/意图对齐前置（28.2.2）+ goal 自治衔接（28.8）接线 | 疑似 **`task-instruction-iteration-20261117` / `task-intent-iter-20261117`**（与 diff 中文本锚“28.2.2…理解迭代”一致；discipline 28.2.2 条文内写 `Why:判例=sess_105b4097(...模板体系升级被误解跑偏)+...task-intent-iter-20261117`） | 中（计划制作主流程/SKILL 为模板治理改造高频触点，文本会合流） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` | +7。摘录：新增 `## 🧭 指令理解迭代草稿（Rule 28.2.2 — 执行前方向对齐｜粗稿非定稿）` 含①原始指令复述②模型理解③思路与候选④大体执行方向。 | 主计划模板增加“理解迭代草稿”区块 | 疑似 **`task-instruction-iteration-20261117`**（同 28.2.2 理解迭代主题） | **高**（本新任务含“存量模板改造/模板体系结构”——主模板为核心改造对象，直接冲突面） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` | 2 行变更。摘录：Rule 1 `执行/计划细化前按 Rule 28.2.2 完成 3-4 轮理解迭代草稿（方向对齐）`，并细化 goal/28.8 与 D1 超时/非 goal 分支表述。 | 核心规则 Rule 1 接线 28.2.2/28.8（理解迭代+goal 自治） | 疑似 **`task-instruction-iteration-20261117`** | 中（核心 rules 为高敏文件；本次改动小但同域） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/worktree-isolation.md` | +46/-?（46 行变更）。摘录：冲突信号表处置改为`默认不打断执行`（①未提交变更→实现类默认隔离、`执行期不打断`、合并期按V3解决）；决策矩阵“禁止就该安全默认向用户发起确认/询问”；新增 `①-备份(前置)...git stash push...`；新增`执行期不打断原则（P0，对齐用户裁决）`；6.1/6.2 同落点盘点在 worktree 内不阻断执行。 | worktree 隔离/并行冲突处理：执行期不打断、冲突记录延后合并期(V3/V5/V6,101.2) | **未能锚定具体 task-id**（主题=执行稳定性/冲突延迟处理；与“理解迭代”不同） | 低-中（非模板治理主域，但涉及执行流程规则，若新任务触碰隔离策略需合并） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/config.json` | 2 行变更。摘录：`interaction_mode` description 改为 `ask=关键决策点(D1-D6)给选项供用户选择；执行前按 28.2.2 完成 3-4 轮理解迭代草稿...`。 | 交互模式配置描述同步 28.2.2 | 疑似 **`task-instruction-iteration-20261117`** | 低-中（配置说明文案；模板治理若增 config 键需合并） |
| `/mnt/data/dev/task-planner-skill/knowledge/INDEX.md` | 6 行变更（计数 33→37，生成时间 2026-11-19T00:23:08Z）。新增条目含 `modification-compliance-gate`(anti-regression)、`spec-baseline-freeze-anti-regression`(anti-regression)、`draft-task-model-tier-dispatch-20261119`、`task-auditgate-machine-20261116` 等。 | 知识库索引再生成/补录近期条目（含已落地防倒退条目引用） | 疑似 **多任务收尾副产物/kb 维护**（条目指向已完成任务 task-spec-baseline-freeze-20261119、task-modification-compliance-gate-20261119 等） | 低（索引可重建；内容与新任务背景强相关但文件本身易再生） |
| `/mnt/data/dev/task-planner-skill/CLAUDE.md` | +2。摘录：新增 `**项目定位（2026-11-15 锚定）**：用方法论方案，在不使用高档模型的前提下产出更稳定、更准确的质量内容...` 指向 README_zh.md。 | 项目定位锚定（方法论/子代理优先/稳定性/长上下文数据工程） | 疑似 **`task-intent-project-align-20261117`**（提示任务名含 intent/project-align；定位日期 2026-11-15） | 低 |
| `/mnt/data/dev/task-planner-skill/README_zh.md` | +17。摘录：新增 `## 项目定位` 四要点 + `定位原话锚（用户 2026-11-15 /goal，逐字）`。 | 项目定位文档化/意图对齐 | 疑似 **`task-intent-project-align-20261117`** | 低 |
| `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` | +1（净增 28.2.2 段落）。摘录：新增 `28.2.2 **指令理解迭代草稿与歧义门控...task-intent-iter-20261117**`（含歧义门控、goal/28.8 优先覆盖、与 28.2.1 分工、Why 判例 sess_105b4097）。文件内既有 `74.7`/`106.7` 防倒退条款属 HEAD 已提交（blame 274bb9e3），非本 diff 新增。 | 纪律域新增 28.2.2 理解迭代规则 | 疑似 **`task-instruction-iteration-20261117`**（条文内显式 `task-intent-iter-20261117`） | 中（纪律规则文件常与新治理规则同改，需合并；本次增量主题不同） |
| `/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md` | 4 行变更。摘录：`23.3` 增补“worktree 内执行期：A-D级冲突/注入均仅作合并期收口记录，不中断执行、不向用户询问 scope…”；`23.8` 注入 `[conflict]` 记录“仅合并期处理，worktree/执行期不打断、不询问”。文件内既有 `22.4e`/`103.3b` Spec-Baseline 承载属 HEAD 已提交。 | 派发域并行冲突检测：执行期不打断、合并期解决 | **未能锚定具体 task-id**（与 worktree-isolation/冲突 hook 同主题簇） | 低-中 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-conflicts.sh` | 2 行变更。摘录：输出由 `实现类任务仍默认首选工作树隔离(用户可否决)` → `实现类任务仍默认首选工作树隔离(默认执行，不就此询问；仅用户显式豁免且合规时直改)`。 | 冲突扫描文案：默认执行不询问 | 疑似同“执行期不打断”簇 | 低 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-pretooluse.sh` | 2 行变更。摘录：`[conflict]` additionalContext 改为“仅作合并期收口记录：worktree/执行期不打断、不向用户确认 scope…smart-merge-back V3/V5/V6, Rule 101.2”。 | PreToolUse 冲突提示降噪为记录、不打断 | 疑似同“执行期不打断”簇 | 低-中（hook 行为变更，若新任务涉及守卫需注意） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/zcode-userpromptsubmit.sh` | 2 行变更。摘录：冲突消息前缀 `[并行冲突记录·仅合并期处理·执行不打断(勿就此询问/暂停)]`。 | UserPromptSubmit 冲突提示标注不打断 | 疑似同“执行期不打断”簇 | 低-中 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-interaction.sh` | +21。摘录：新增 TI-14 “28.2.2 指令理解迭代草稿+歧义门控锚在位(discipline+SKILL+core/config 接线)” 静态守护（grep 28.2.2/理解迭代/歧义门控）。 | 交互自测补 28.2.2 锚守护 | 疑似 **`task-instruction-iteration-20261117`**（TI-14 注释含 task-intent-iter-20261117） | 中（若模板/规则治理调整同锚文本，守卫需同步） |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/user-session-log.md` | +1。摘录：理解镜像注释追加 `Rule 28.2.2（理解迭代草稿...）可在本镜像或同号追加块中记录 3-4 轮要点...`。 | 会话日志模板接线 28.2.2 | 疑似 **`task-instruction-iteration-20261117`** | 中（模板治理改造面） |
| `/mnt/data/dev/task-planner-skill/skills/todo-skill/SKILL.md` | 2 行变更。摘录：路径说明改为 `工具表中 tools/<cmd>.ts 形式为技能目录相对路径...`（措辞微调）。 | 文档微调 | **未锚定 task-id**（疑似零星修正） | 低 |
| `/mnt/data/dev/task-planner-skill/skills/workflow-model-tiers/SKILL.md` | 2 行变更。摘录：权威规则路径由 `plan-collab-router/references/...` 改为 `../plan-collab-router/references/...`。 | 相对路径修正 | **未锚定 task-id**（疑似零星修正） | 低 |

**归属汇总（证据驱动）**：约 9 个文件强指向“指令理解迭代”链路（28.2.2/理解迭代锚，`task-intent-iter-20261117` 在 discipline/selftest 文本出现）→ 疑似 **`task-instruction-iteration-20261117`**；2 个文件（CLAUDE/README 项目定位）→ 疑似 **`task-intent-project-align-20261117`**；5 个文件（worktree-isolation + dispatch 23.3/23.8 + 3 hooks/scripts）构成“执行期冲突不打断、合并期解决”一致簇→ **未命名在途改动（同主题半成品）**；plan-resume 大重构、knowledge/INDEX 再生成、todo-skill/workflow-model-tiers 微修→ **归属未明/杂项在途**。所有判定均基于 diff 文本与锚字，未见对应 `plans/task-instruction-iteration-20261117/` 或 `plans/task-intent-project-align-20261117/` 目录存在于当前工作树（`ls plans`/`git status` 未显示其目录；`plans/INDEX.md` 亦未列）。

### 1.1 未跟踪项：`.zcode/plans/plan-session_da2769c3*.md`

- **文件**：`/mnt/data/dev/task-planner-skill/.zcode/plans/plan-session_da2769c3c2c1d1b81d16227fac006126.md`（证据：`git status` ??、`find -name '*plan-session_da2769c3*'`）
- **主题**：轻量豁免档/极简 stub 提案（l0-lite）。证据摘录（`cat ... | head -120`）：
  - 标题：`# 让「轻量豁免档」真正可用 —— 用极简 stub 替代死掉的关键词豁免`
  - 内容要点：根因指向 `check-scope.sh` `_lightweight_release`、`task-plan-init.cjs` 轻量关键词依赖 SessionStart prompt 不可达、L0-T 文档未接线；方案=写 ≤12 行含 `plan_tier: mini` 的 l0-lite stub 复用 D10 + ④b 双门放行；改动清单含新增 `templates/variant/l0-lite-type.md`、修 `zcode-pretooluse.sh:21` 文案、L0-T 接线、模板计数级联等。
- **归属判断**：疑似独立在途/草稿提案（session-scoped plan），与 `plans/INDEX.md` 中 `task-l0lite-exempt-20261103`(pending, 0/0) 主题高度相关但文档落点不同（session plan vs task 计划目录）；与本新任务“模板治理/分级派生”相关（涉及 variant 新增与计数），冲突度 **中**。

### 1.2 未跟踪项：`forensics/` 目录清单与主题

**证据**：`ls -la /mnt/data/dev/task-planner-skill/forensics/`、各文件 `head -30`。

| 文件(绝对路径) | 大小 | 主题/证据摘录 |
|---|---:|---|
| `/mnt/data/dev/task-planner-skill/forensics/main-dirty-diff-4targets.txt` | 25530 | 主仓脏改动四目标 diff 快照。摘录：`diff --git a/skills/task-discipline/references/critical-rules-discipline.md ...`（含 28.2.2 等变更上下文），用于取证对比。 |
| `/mnt/data/dev/task-planner-skill/forensics/modification-compliance-gap-20261119.md` | 30600 | “修改合规缺口”取证分析（对应 task-modification-compliance-gate-20261119 / sess_ba603cf5 判例）。 |
| `/mnt/data/dev/task-planner-skill/forensics/sess-ba603cf5-events.jsonl` | 18883972 | sess_ba603cf5 事件流水（大体量原始会话事件）。 |
| `/mnt/data/dev/task-planner-skill/forensics/sess-ba603cf5-project-findings.md` | 38508 | sess_ba603cf5 项目侧发现/取证摘要。 |
| `/mnt/data/dev/task-planner-skill/forensics/sess-ba603cf5-skill-gap-analysis.md` | 23598 | sess_ba603cf5 技能缺口分析（指向规范基线/修改合规缺口）。 |
| `/mnt/data/dev/task-planner-skill/forensics/sess-ba603cf5-transcript-findings.md` | 59226 | sess_ba603cf5 转录发现。 |

**主题归属**：整体围绕 **sess_ba603cf5 判例**（4-12s 硬约束被降级/无依据放宽）及由此衍生的“规范基线冻结防倒退”与“通用修改合规门”取证，直接支撑已落地的 Rule 51.15/74.7/106.7/22.4e/103.3b 等机制及两篇未跟踪 knowledge entry；与本新任务“防倒退机制”背景**高度相关（证据源）**，但属取证/产物未入库状态。

### 1.3 未跟踪计划目录（当前任务）

- `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/*`（`.session-log-baseline`、`findings.md`、`knowledge-brief.md`、`notepad-learnings.md`、`progress.md`、`task_plan.md`、`user-session-log.md`、`verification.md`，以及本次新建 `research/template-inventory.md`）——本任务初始化产物，非在途半成品归属对象。

---

## 2. 未跟踪知识条目（全文摘要）

### 2.1 `knowledge/entries/spec-baseline-freeze-anti-regression.md`
- **路径**：`/mnt/data/dev/task-planner-skill/knowledge/entries/spec-baseline-freeze-anti-regression.md`
- **元数据**：id=`spec-baseline-freeze-anti-regression`；tags `[kb, anti-regression, spec-baseline, attest-lock, verification-gate, vacuous-gate-fix]`；sources 含 `plans/task-spec-baseline-freeze-20261119/*`、`skills/task-planner/references/critical-rules.md`；updated 2026-11-19。
- **核心结论（与防倒退直接相关）**：
  - **判例/根因**：sess_ba603cf5，用户硬约束“单镜 4-12s”被静默降级为 3s/15s（EP33-44 共 59 镜）。根因非单点篡改：4-12s 双界仅在规格/脚本模板层定义，未下沉 storyboard-craft 等 QC 强制门；C87 只写 `≤12s` 缺 `≥4s` 下限，越界可经“超拍登记/NOTE”软豁免放行——硬约束从未固化为受管基线。
  - **解法（Spec-Baseline Freeze 闭环，零新脚本，复用 attest SHA-256 锁）**：把“已确立且影响验收的业务硬约束”登记进 `task_plan.md`「🔒 规范基线」区块，随 Rule 20.1 attestation 锁定面，四环消费：①**冻结** core Rule 51.15（区间必须双向登记上下界，禁单边；篡改/软豁免=`[SPEC-BASELINE TAMPERED]` P0）；②**派发携带** dispatch 22.4e（spec_id+原文verbatim+双向判定式+sha256，禁转译/重建/放宽）；③**复检回归** dispatch 103.3b（第5维基线-产物一致性，拦软豁免/降单边/前序合规本轮退化）；④**返工续写回归** discipline 106.7 + **终验门** verification 84.15（全量逐条核验，流程绿≠规范合规）。
  - **易错点**：双边登记铁律（单边=无下限）；验收命令须负控制防恒真假门；占位专档≠空专档（80.8）；跨仓 StoryLab 修复边界；并行会话指针按 sid 分属。
  - **验证状态**：commit 7db7a25→merge 879fb48，selftest 4 脚本 84 PASS/0 FAIL，3 部署位核心规则锚 12/12+模板 4/4。
- **对新任务意义**：已提供“防倒退/基线冻结”既有制度化设计（登记+锁+四环消费+双向显式+none-justified），新任务应复用/扩展而非重造；同时提示模板层需承载/暴露基线区块与校验。

### 2.2 `knowledge/entries/modification-compliance-gate.md`
- **路径**：`/mnt/data/dev/task-planner-skill/knowledge/entries/modification-compliance-gate.md`
- **元数据**：id=`modification-compliance-gate`；tags `[kb, anti-poison, modification-gate, compliance-quadruple, spec-baseline, anti-regression]`；sources 含 `plans/task-modification-compliance-gate-20261119/*`、`forensics/modification-compliance-gap-20261119.md`、`skills/task-discipline/references/critical-rules-discipline.md`；updated 2026-11-19。
- **核心结论**：
  - **问题/根因**：同判例 sess_ba603cf5，追问“修改是否合规”。取证结论：无单点篡改，体系缺“所有已确立规范”的通用修改前合规论证+授权硬门；已归档 51.15 仅冻结**已登记** Spec-Baseline，缺口 B1 未登记规范、B2 执行期就地放宽、B3 单边/软豁免未识别。
  - **机制（Rule 74.7，P0，纯文本零新脚本）**：**合规四元组**（落地前必登 `task_plan.md`「📋 变更标注表」）= `变更对象+当前值(verbatim) → 拟变更值 + 变更依据(证据/用户逐字授权) + 影响评估(放宽了哪些既有约束) + 处置`。**无依据放宽=禁止落地**：删下界/抬上界/改单边/加软豁免均属放宽，无授权+证据→`[MODIFICATION NON-COMPLIANT]`（P0）。**分工**：先过 74.7（通用前置门），再判叠加 51.15；禁以“未登记”为由绕过。
  - **四处联动**：`critical-rules.md:109`（51.15 none-justified 登记前置+74.7 指针）、`SKILL.md:122`（2.5d 执行期改规范回填）、`critical-rules-dispatch.md:66`（22.4e 执行体禁自行放宽）、`discipline.md:757`（106.7 通用放宽判据）。
  - **关键教训**：部署位形态差异（SKILL 薄壳）、幂等断言锚禁用正则行首符、Rule 27.3 porcelain 预检误判处理、check-delegation 白名单前缀、EVIDENCE-ANCHOR 域内路径要求；范围边界=制度层，StoryLab 历史产物跨仓不回溯。
- **对新任务意义**：防倒退不止“基线冻结”，还需“修改合规前置门”；模板/原则注入应与变更标注表、Spec-Baseline 登记位、none-justified 口径协同。

---

## 3. 模板体系结构

### 3.1 `skills/task-planner/templates/` 全量清单与数量

**证据**：`ls -la /mnt/data/dev/task-planner-skill/skills/task-planner/templates/`、`ls templates/variant/ | sort`、`find ... -maxdepth 1 -type f | wc -l`(13)、`find .../variant -maxdepth 1 -type f | wc -l`(31)。

- **根级模板/文档（13 个文件）**：`batch_report.md`、`deprecated.md`、`delivery-summary.md`、`findings.md`、`knowledge-brief.md`、`notepad-learnings.md`、`progress.md`、`session-handoff.md`、`shared-tracker.md`、`subagent_dispatch.md`、`task_plan.md`、`user-session-log.md`、`verification.md`。
- **变体模板（31 个文件，`variant/` 下，命名规律统一 `*-type.md`）**：
  `audio-voice-type.md`、`bugfix-type.md`、`character-design-type.md`、`code-edit-type.md`、`deployment-type.md`、`diagnostic-type.md`、`final-assembly-type.md`、`image-type.md`、`l0-lite-type.md`、`longform-continuity-type.md`、`memory-hygiene-type.md`、`migration-type.md`、`mini-lite-type.md`、`motion-camera-type.md`、`multiview-ref-type.md`、`performance-tuning-type.md`、`physics-compliance-type.md`、`prompt-struct-type.md`、`publish-type.md`、`qc-defect-type.md`、`refactor-type.md`、`research-type.md`、`rule-enhancement-type.md`、`schema-migration-type.md`、`script-dev-type.md`、`storyboard-type.md`、`test-writing-type.md`、`video-fix-type.md`、`video-prompt-type.md`、`video-type.md`、`writing-type.md`。
- **总计**：44 个 .md（根 13 + variant 31，证据：`wc -l ...templates/*.md ...templates/variant/*.md` total 行数统计末行 5622 total / 44 files 级别）。

> 备注：`templates/` 下另有目录 `variant/`；未见 `*.j2`/`*.yaml` 模板元数据侧车文件（`ls` 证据）。

### 3.2 主模板 `task_plan.md` 章节区块清单

- **路径**：`/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md`（601 行）
- **头部/frontmatter**：`# Task Plan: {{TASK_NAME}}` + 渲染契约注释；行首元数据 `template_type: general`、`plan_tier: standard`、`execution_lane: L1`（Rule 16/34.1/38.7 说明注释，证据 head 1-20 行）。
- **主要章节（`grep -n '^## |^### '` 证据，节选全貌）**：
  - 需求与对齐：`## 🎯 用户需求原文（Rule 51.1）`、`### R→VC 映射（Rule 51.2）`、`### 🗣️ 用户会话逐字记录（Rule 80）`、`## 🧭 指令理解迭代草稿（Rule 28.2.2）`。
  - 审计/基线/约束：`## 🧮 根源覆盖表（Rule 53.1）`、`## 🔒 不变量声明区（Rule 73.3）`、`## 🔒 规范基线（Spec-Baseline，Rule 51.15）`、`## Goal`、`## 🔍 Code Review 配置`。
  - 验证与裁决：`## ✅ Verification Contract`、`## 🛡 双轮质检与同步完整性声明（Rule 103）`、`## 🎯 核心目标达成裁决（Rule 58.5）`、`## 🎯 Goal 单元表（Rule 66.1）`。
  - 范围与知识：`## ⚠️ 执行范围限制`、`## 📋 变更标注表（Rule 74.3）`、`## 📚 必要知识储备`、`## ⚠️ 核心问题定义`、`## 🔍 调研需求与检索计划（Rule 75.1）`、`## 🔍 证据面清单（Rule 58.1）`。
  - 执行推进：`## Current Phase`、`## Next Step`、`## 🧰 工具选择与编排（Rule 40）`、`## Phases`（含 Phase 1-5 等子节）、`## 🔁 收尾回读梳理记录（Rule 84.14）`。
  - 协作/隔离/同步：`## 🔀 隔离决策`、`## 📊 FMEA 预演`、`## 🔁 原生 Todo 同步（S1–S5）`、`## Key Questions`、`## Decisions Made`、`## Errors Encountered`、`## Notes`、`## 🚨 Drift Log`、`## 📦 Batch Report`、`## 📊 委派统计（Rule 25.4）`、`## 🔗 Subagent Handoff 登记表（Rule 22.5）`、`## 🔗 Chain 区块交接配置` 等。

### 3.3 Variant 与主模板结构差异（抽样 2 个）

**证据**：`grep -n '^## |^### ' templates/variant/bugfix-type.md`、`.../video-type.md`；head 对比。

| 对比项 | `variant/bugfix-type.md` (183行, `/.../templates/variant/bugfix-type.md`) | `variant/video-type.md` (113行, `/.../templates/variant/video-type.md`) | 主模板 `task_plan.md` |
|---|---|---|---|
| 头部标识 | `<!-- template_type: bugfix -->`、`<!-- plan_tier: standard -->`（注释形态） | `# Task Plan: [视频创作任务]` + `<!-- template_type: video -->`、`<!-- plan_tier: standard -->` | 行首 `template_type: general`/`plan_tier`/`execution_lane` + 丰富注释契约 |
| 体量/定位 | 中等，通用缺陷修复骨架 | 较短，强领域化（视频创作） | 601 行，全量通用“超集”模板 |
| 章节覆盖 | Goal、Code Review、VC、执行范围、必要知识储备、Current Phase、工具选择、Phases(复现/根因/方案/修复/验证)、隔离决策、Todo/问题/决策/错误/Notes、Drift Log、委派统计、Handoff、Goal单元表、派发表骨架、Batch Report | Goal、Code Review、任务分型(A/B/C)、VC、执行范围、工具选择、Phases(基线核验→草稿QC→G1人工门→视频生成→成片QC)、子代理隔离铁律、必要知识储备、Drift Log/委派统计/Handoff/Goal单元表/派发表/Batch Report | 含 R→VC映射、用户会话逐字记录指针、**指令理解迭代草稿(28.2.2)**、根源覆盖表、不变量、**Spec-Baseline(51.15)**、变更标注表、调研需求、证据面清单、FMEA预演、Chain 等大量主模板专属区块 |
| 差异程度 | **显著特化**：保留 VC/Phase/范围/Handoff 等核心骨架，但裁剪/未包含主模板多项治理区块（未见 Spec-Baseline/理解迭代草稿/R→VC 映射等章节）；Phase 语义按 bugfix 生命周期定制 | **高度领域特化**：流程与门控围绕视频生产（G1 人工门、子代理隔离铁律、类型分型），与主模板通用结构差异更大 | 基准全集 |

**结论**：variant 并非主模板的轻量参数化拷贝，而是按任务类型裁剪/重组的独立骨架；主模板新增区块（如 28.2.2 理解迭代草稿）与 Spec-Baseline 治理区块在抽样 variant 中未对齐体现（需存量改造评估）。

### 3.4 模板分级/派生声明（parent/base/spec_version/lineage）

- **检索证据**：
  - `grep -rn 'spec_version|lineage|^parent:|base_template|derived_from' /mnt/data/dev/task-planner-skill/skills/task-planner/templates` → **无命中**。
  - `grep -rn 'spec_version|lineage|\bparent\b'` 全仓命中：`spec_version` **0**、`lineage` **0**；`parent` 命中集中于路径/父目录语义与历史计划文档（如 `worktree-isolation.md`/`smart-merge-back.sh` 中 `parent`/`repo-parent` 路径变量与说明、`sync-todos.sh` “plans/ parent level”、归档 `subagent-state` 中 `parent: <commit>` 等），**未见** `parent:` 作为模板血缘元数据、无 `base_template/derived_from`。
- **结论**：**不存在模板分级/派生声明机制**（无 parent/base/spec_version/lineage/frontmatter 血缘字段）。现有“分层”仅体现为：通用主模板(`general`) vs `variant/*-type.md` 类型特化、以及项目级 `.zcode/plan-templates/*.md` 覆盖发现（init-session 机制），但无版本化/血缘谱系元数据。

---

## 4. 模板技能面

### 4.1 `skills/plan-template-kit/SKILL.md`
- **路径**：`/mnt/data/dev/task-planner-skill/skills/plan-template-kit/SKILL.md`
- **职责**：卫星技能、纯知识层——沉淀模板选型决策树、定制契约与路径规范；机械层（variant 库、init-session.sh、check-template-type.sh、attest 门控）留守 task-planner。主路由：Rule 16 选模板/Rule 34 沉淀时 `Skill("plan-template-kit")`。
- **参考面（何时读哪份）**：
  - `references/template-mapping.md`（唯一选型权威源）：§一分流决策树+类型清单、§六路径速查、§七定制红线、§八验证命令、§九机制适用性矩阵(Rule 37)。
  - `references/template-guide.md`：双层优先级（项目级 `.claude|zcode/plan-templates` 覆盖内置）、脚本契约标记、定制示例、路径引用规范。
  - `references/critical-rules-template.md`（模板域规则全文）：含 Rule 16/34/37/38（34.1-34.9 覆盖选取门控、四点同步、沉淀触发/流程/防滥用/三点感知网 34.7 全自动生成合约、执行期沉淀 34.8、项目级适配沉淀位 34.9 等；证据文件头/grep）。
- **选择/适配判定机制**：选型委托 mapping 决策树与白名单（动态派生自 `../task-planner/templates/variant/`）；34.3 触发沉淀评估（同类第2次/新类型可泛化/用户点名）；34.5 查重+泛化性闸门；34.7 终验 COMPLETE+命中 34.3 可全自动生成 variant（不问用户）并走 34.2 四点同步+计数级联。
- **升级/改造机制描述**：34.2 四点同步（template-mapping.md、plan-writer 映射表、task-planner SKILL 模板节、template-guide.md 变体表与计数）；一致性由 `selftest-template-lifecycle.sh` 守护；执行期候选/项目级生产由 plan-template-advisor (34.8/34.9)。
- **模板清单/数量**：SKILL 文本提及“白名单动态派生自 variant/ 目录（task-v115 videop1 回流后 29 类）”等描述；权威清单与计数在 `references/template-mapping.md`、`references/template-guide.md`（本技能 references/ 下存在，证据 `ls skills/plan-template-kit/references`）。kit 自身不承载模板实体文件。

### 4.2 `skills/plan-template-advisor/SKILL.md`
- **路径**：`/mnt/data/dev/task-planner-skill/skills/plan-template-advisor/SKILL.md`
- **存在性**：存在；无 `references/` 子目录（证据 `ls .../plan-template-advisor/references` 不存在）。
- **职责**：轻量卫星，项目模板适配分析与沉淀建议（纯 SOP、零新脚本）。基于项目证据分析任务类型与缺口，产出可审查的项目级计划模板候选；激活：用户直呼或 Rule 34.8/34.9 路由。
- **选择/适配判定机制**：SOP 六步——①项目分析（AGENTS/CLAUDE/README、plans/INDEX+archive 分布、findings/错误/git 指纹）②问题预测（高频类型×典型坑，证据限定）③缺口映射（对照 `templates/variant/*-type.md` 30 类与项目级既有模板，`ls` 查重；无专用 variant 的高频类型→候选新类型，已有但需本地化→适配版候选）④模板产出（候选落 `template-candidate/`，项目级落 `<项目>/.zcode/plan-templates/<类型>-type.md` 或 `.claude/plan-templates/`；仅 `*-type.md`；单次 ≤3）⑤审查（34.8 项目级门 G1-G3：结构lint/render冒烟/独立审查）⑥登记（manifest/README 登记+回链证据）。
- **升级/改造机制**：面向项目级适配沉淀（34.9），不直接改官方 variant；官方入库须走 34.8 G1-G4 与 plan-template-kit/task-planner 主路由。
- **模板清单**：不维护官方清单；消费官方白名单（30 类）与项目级目录发现机制（init-session 原生发现）。

---

## 5. 模板加载链

### 5.1 `init-session.sh` 模板选择与感知

- **路径**：`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh`（86628 bytes，证据 `ls -la scripts/`）
- **项目级模板发现**：`find_project_templates()` 自 CWD 向上遍历，优先命中 `.claude/plan-templates/`，其次 `.zcode/plan-templates/`（证据：脚本 64-79 行 `if [ -d "$dir/.claude/plan-templates" ]; ... elif [ -d "$dir/.zcode/plan-templates" ] ...`）；`--list` 同样遍历并枚举项目 `*-type.md`（31-33, 56-61 行附近）。
- **复制优先级（per-file）**：项目级 `{project}/.claude|.zcode/plan-templates/{filename}` > 内置 `$BUILTIN_TEMPLATES`（`~/.zcode/skills/task-planner/templates/`，由脚本位置派生）（证据：头注 11-17 行、`copy_template()` 84-99 行）。
- **默认模板解析**：项目 `plan-templates/default` 文件内容 > env `TASK_TEMPLATE_DEFAULT` > 缺省 `general`（证据：`--list` 段 `_def` 解析、默认类型解析段 `_default_type`/`_default_src`）。
- **类型/白名单扩展**：内置 variant (`templates/variant/*-type.md`) + 项目级 `*-type.md`（去后缀）并入合法类型集合；内置未命中可查项目 `plan-templates`（证据：679-736 行注释与逻辑片段 grep）。
- **template-sense 感知（T1，Rule 34.3②/34.7）**：
  - general 兜底/类型空缺：输出 `[template-sense] ⚠ 任务类型空缺（general 兜底）...` 并向 `task_plan.md` 末尾追加“🔁 模板感知”区块（证据：898-936 行附近 `echo "[template-sense]..."`、追加区块与提示）。
  - 未知类型（不在白名单）：输出 `[template-sense] ⚠ 任务类型未知...` 并追加区块（956-969 行附近）。
  - 已知类型（如 bugfix）不触发（证据：`selftest-template-sense.sh` case-3 断言 `[template-sense]` 计 0）。
  - 设计意图：预登记沉淀评估，终验必查（T3 由 `check-complete.sh` 兜底）。
- **其他**：计划指针/哨兵/sid 处理、tier 分流、渲染 `render_template()` 等（init-session 还承担初始化与落盘职责）。

### 5.2 template-sense 相关脚本与 Rule 34.3/34.7

- **规则权威**：`/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/critical-rules-template.md`
  - Rule 34.3 沉淀触发（同类第2次/类型不覆盖且可泛化/用户点名）。
  - Rule 34.7 模板感知三时点+全自动生成合约：T1 init-session 机器提示+追加“🔁 模板感知”区块；T2 计划期 LLM 评估；T3 `check-complete.sh` 终验 warn 兜底；COMPLETE 且命中 34.3 → 主进程直接派执行体生成 variant（34.5 双闸门），34.2 四点同步+计数级联。
  - Rule 34.8/34.9 执行期候选暂存审查门与项目级沉淀位。
- **脚本/守卫**：
  - `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh`（T1 发射与区块追加，见 5.1）。
  - `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh`（证据 664-675 行）：若含 `🔁 模板感知` 且未登记“沉淀/不沉淀理由”则输出 `[template-sense] ⚠ 计划含模板感知区块但终验未登记沉淀/不沉淀理由（Rule 34.7 全自动生成合约）`（warn，不阻断）。
  - `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-sense.sh`：守护 T1(general/unknown 触发、bugfix 不触发)、条款锚(34.7 在 critical-rules-template 与 plan-template-kit SKILL)、T3 warn 行为。
  - `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-lifecycle.sh`：守护 34.x 条款锚/34.3 三条件等（锚目标已迁至 plan-template-kit references）。

### 5.3 `config.json` 模板相关配置键

- **路径**：`/mnt/data/dev/task-planner-skill/skills/task-planner/config.json`
- **证据键**：
  - `template_priority.project_level`: `.claude/plan-templates/{filename}`；`template_priority.builtin`: `~/.zcode/skills/task-planner/templates/{filename}`；`template_priority.description` 指向 `references/template-guide.md`。
  - `template_gate_enforce`（默认 `warn`，enum enforce/warn/off）：Rule 34 模板选取门控，白名单源 `templates/variant/` 动态派生+general，见 `references/critical-rules.md` Rule 34。
  - `mechanism_profile_enforce`（默认 `warn`）：Rule 37 任务类型机制画像，详见 `template-mapping.md` §九。
  - `knowledge_brief_enforce` 描述关联 `templates/knowledge-brief.md` 与 `companion/agents/plan-writer.md` 契约。
  - （非键但相关）`interaction_mode` 描述含 28.2.2 理解迭代草稿要求（当前未提交改动）。

### 5.4 plan-writer agent 模板加载指令

- **路径（仓内伴生）**：`/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/plan-writer.md`
- **路径（部署/全局）**：`/home/terry/.zcode/agents/plan-writer.md`（head 对比与仓内一致）
- **关键指令/证据**：
  - `template_type` 必填 frontmatter（Rule 16）；“禁止 frontmatter 缺 template_type”；attest 前 `check-template-type.sh` 机器校验（白名单=variant/ 动态派生+general）。
  - “模板选择:根据 `template_type` 参数从 `templates/variant/` 选择对应模板填充”；给出类型→模板文件映射表（general/research/diagnostic/writing/publish/code-edit/refactor/bugfix/migration/test-writing/deployment/performance-tuning/schema-migration/rule-enhancement/video-fix/video/mini-lite/memory-hygiene/image/script-dev/...audio-voice/final-assembly 等）及默认关键词匹配顺序。
  - 门控契约引用 Rule 34.1；产出契约含 7 文件/knowledge-brief/S-unit/VC/Scope 等；工具选择与编排引用 `../plan-template-kit/references/template-mapping.md`。
  - 说明仅产出文档、不执行 Phase、不调子代理。

**加载链现状（一句话预览）**：init-session.sh 按 CWD 上溯发现 `.claude/.zcode/plan-templates`（项目级优先于内置 templates），结合类型/默认项与 tier 渲染 7 文件；对 general/未知类型发 `[template-sense]` 并追加感知区块，check-complete.sh T3 终验未登记理由则 warn；白名单由 variant 动态派生并由 check-template-type/attest 门控；plan-writer 按 `template_type` 从 `templates/variant/` 选模板填充并受 Rule 16/34 约束（证据见 5.1-5.4）。

---

## 6. 守卫面

### 6.1 `skills/task-planner/scripts/` 下 `selftest-*.sh` 与 `check-*.sh` 清单

**证据**：`ls /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/`

- **check-*.sh（25 个）**：`check-3file-gate.sh`、`check-complete.sh`、`check-conflicts.sh`、`check-context-hygiene.sh`、`check-delegation.sh`、`check-dispatch.sh`、`check-doc-sync.sh`、`check-drift.sh`、`check-evidence-anchor.sh`、`check-gate-degraded.sh`、`check-goal-cjk.sh`、`check-plan-audit-gate.sh`、`check-plan-dispatch.sh`、`check-rvc-coverage.sh`、`check-scope.sh`、`check-skill-modify.sh`、`check-state-consistency.sh`、`check-step-placeholders.sh`、`check-stop-guard.sh`、`check-template-type.sh`、`check-tier-consistency.sh`、`check-vc-nonvacuous.sh`、`check-window-consistency.sh`。（另有 `check-complete.ps1` 非 .sh）
- **selftest-*.sh（大量，示例/关键）**：含 `selftest-template-lifecycle.sh`、`selftest-template-sense.sh`、`selftest-plan-tier.sh`、`selftest-skill-split.sh`、`selftest-skill-collab.sh`、`selftest-interaction.sh`、`selftest-check-drift.sh`、`selftest-dispatch.sh`、`selftest-mechanism-profile.sh`、`selftest-knowledge-brief.sh`、`selftest-session-log.sh`、`selftest-workflow-orchestration.sh` 等（完整目录共百余 selftest 脚本，见脚本目录 ls 结果）；统一入口 `run-selftests.sh`，注册表 `selftest-registry.tsv`。

### 6.2 与模板区块相关的断言（结构检查/variant 同步检查）

- **`check-template-type.sh`**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-template-type.sh`）：attest 前校验 `template_type ∈ 白名单`；白名单=`general + templates/variant/*-type.md` 动态派生（Rule 34.1，禁硬编码副本）；提取支持 frontmatter 行首、表格行、HTML 注释三形态（`<!-- template_type: X -->`）；缺失/非法报 `[template-gate] INVALID`。
- **`check-complete.sh`**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh:664-675`）：template-sense T3 warn——计划含 `🔁 模板感知` 区块且未登记“沉淀/不沉淀理由”则 stderr `[template-sense] ⚠ ...`（不阻断，零新 config 键）。
- **`selftest-template-lifecycle.sh`**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-lifecycle.sh`）：守护 Rule 34/37/48 条款锚与 34.3 沉淀触发三条件等；锚位迁移至 `plan-template-kit/references/critical-rules-template.md`（注释记录 task-v171 迁移）。
- **`selftest-template-sense.sh`**（`/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-sense.sh`）：守护 T1 init-session general/unknown 触发与追加区块、known-type 零触发；34.7 条款锚在 critical-rules-template + plan-template-kit SKILL；T3 warn 行为。
- **`selftest-plan-tier.sh` / `selftest-skill-split.sh` / `selftest-skill-collab.sh`**：存在并涉及模板/计数锚级联（会话 plan 提案与历史经验提示，证据：脚本存在于目录；l0-lite 提案明确列为计数级联风险点）。
- **配置门控**：`config.json#template_gate_enforce`（默认 warn）由 attest/check-template-type 语义消费；`config.json#mechanism_profile_enforce` 关联 Rule 37 画像（template-mapping §九）。

### 6.3 `grep spec_version|lineage|parent` 全仓（派生机制确认）

- **命令**：`cd /mnt/data/dev/task-planner-skill && grep -rn "spec_version|lineage|\bparent\b" ...`（证据输出）。
- **结果**：`spec_version`=0 命中，`lineage`=0 命中。`parent` 命中广泛但语义为 **路径/父目录/父提交**（如 worktree-isolation、smart-merge-back 父目录变量、sync-todos 注释 “plans/ parent level”、归档 subagent-state `parent: <sha>`、shell `dirname/parent`），**不存在**模板派生血缘字段（无 `parent_template/base/spec_version/lineage` 元数据）。
- **结论**：**仓库当前无模板分级/派生(lineage)机制实现或元数据约定。**

---

## 7. 规则面

### 7.1 三份 critical-rules 最大 Rule 编号

**证据**：`grep -n '^### [0-9]' <file> | tail`（绝对路径）。

| 文件 | 最大 Rule 编号（文件内出现的最大主编号标题） | 证据摘录(行) |
|---|---:|---|
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` (core, 四文件罗盘域) | **109** | `198:### 109 独立审计门（audit-before-delivery）— task-planaudit-20261116...`（文件含 1/2/3/5/19/20/26/51/62/66/80/81/82/83/109 等非连续编号） |
| `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` | **106** | `733:### 106 文档修改复检与 todo 驱动对齐纪律...`（尾部含 88/89/90/92/93/94/95/97/98/99/100/101/102/105/106） |
| `/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md` | **110** | `310:### 110 任务分级×模型档位强制匹配...`（尾部含 23/25/46/52/59/68/96/103/104/110） |

### 7.2 三份规则中的“倒退/回归/基线/baseline”既有条款

**证据**：`grep -rn '倒退|回归|regression|基线|baseline' skills/task-planner/references/critical-rules.md skills/task-discipline/references/critical-rules-discipline.md skills/task-dispatch/references/critical-rules-dispatch.md`（命中覆盖 51.15/74.7/106.7/22.4e/103.3b 及相关基线/回归表述）。关键条款已在 HEAD 提交（`git blame` 274bb9e3：core:109 行 51.15、discipline:495 行 74.7、discipline:758 行 106.7、dispatch:66 行 22.4e 等）。

- **Core `/skills/task-planner/references/critical-rules.md`**：
  - **Rule 51.15 规范基线冻结与防倒退（Spec-Baseline Freeze，P0）**：`task_plan.md`「🔒 规范基线」逐条登记（spec_id/约束原文verbatim/来源锚/双向判定式/sha256），随 20.1 attest 锁；区间必须上下界双向显式，禁单边；改/放宽/删或软豁免越界=`[SPEC-BASELINE TAMPERED]` P0；四环绑定（22.4e/103.3b/106.7/verification 84.15）；none-justified 登记前置；与 74.7 分工（先 74.7 再 51.15）。摘录见 `:109`。
  - 另有 Rule 62 等处提及“基线事实/前集基线”语义（调研/连续创作基线传递），非防倒退门控但属 baseline 用语（grep 证据）。
- **Discipline `/skills/task-discipline/references/critical-rules-discipline.md`**：
  - **Rule 74.7 通用修改合规门（P0）**：合规四元组+无依据放宽禁止（`[MODIFICATION NON-COMPLIANT]`），覆盖未登记规范/B2/B3；与 51.15 分工。摘录 `:495`。
  - **Rule 106.7 规范基线防倒退回归门（P0）**：返工/续写/QC 重开触发点对全部基线项全量回归，退化=倒退事件 STOP+`[spec-regression]`；禁默认前序合规；延伸通用放宽判据（缺上下界/软豁免=STOP）。摘录 `:758`。
  - 另：32/36 等含“基线/防静默移除/倒退重提”语义，106.3 同文件二次修改全量回归、101.1 起点 baseline 提交等（grep 多处）——构成广义回归/基线纪律，但“规范基线防倒退闭环”核心为 74.7+106.7(+与 51.15 联动)。
- **Dispatch `/skills/task-dispatch/references/critical-rules-dispatch.md`**：
  - **22.4e 规范基线强制携带**（51.15 派发面承载）：prompt 必带 spec_id/原文/双向判定式/sha256 与逐条核验表要求；禁子代理重建/转译/放宽；执行体禁自行改规范口径（联动 74.7）。摘录 `:66`。
  - **103.3b 规范基线逐条回归门**（复检面）：增“基线-产物一致性回归”第5维，拦软豁免放行/降单边/前序合规本轮退化，缺失或 FAIL=CHANGES_REQUESTED。摘录 `:241`。
  - 21.2.1 台账供料“基线事实”等属调研基线语义（grep 证据）。

**结论**：防倒退/基线冻结**已具备成体系规则落地**（Spec-Baseline 登记-锁定-派发-复检-返工回归-终验 + 通用修改合规门），且已提交；当前未提交改动未引入新的防倒退规则正文（仅 INDEX 引用新增条目）。

---

## 8. `plans/INDEX.md` 待处理区现状

- **路径**：`/mnt/data/dev/task-planner-skill/plans/INDEX.md`
- **证据**：文件头 `Last refreshed: 2026-11-16_22:45`、`## 待处理（需关注）`、`## 汇总` `in_progress: 0 | pending: 15 | complete: 12`。
- **Pending 清单（15 项，均 0/0 未开始）**：

| Task ID | 状态行(证据) |
|---|---|
| `task-anchor-eread-20261113` | pending, 未开始 (0/0) |
| `task-anticheat-20261116` | pending, 未开始 (0/0) |
| `task-antitamper-20261116` | pending, 未开始 (0/0) |
| `task-crossprojauth-20261104` | pending, 未开始 (0/0) |
| `task-defect-rrv13-dg12-false-pass` | pending, 未开始 (0/0) |
| `task-l0lite-exempt-20261103` | pending, 未开始 (0/0) — 目标含“极简豁免档/≤12 行 l0-lite stub”（与未跟踪 `.zcode/plans/plan-session_da2769c3...` 主题相关） |
| `task-mdedit-repeatfix-20261116` | pending, 未开始 (0/0) |
| `task-positioning-20261115` | pending, 未开始 (0/0) — 与未提交 CLAUDE/README 项目定位改动主题相关 |
| `task-skillfix-20261105` | pending, 未开始 (0/0) |
| `task-skillfix-audit-20261109` | pending, 未开始 (0/0) |
| `task-unknownconcept-research-20261105` | pending, 未开始 (0/0) |
| `task-v193-skill-goal-drift-fix` | pending, 未开始 (0/0) |
| `task-variant-upgrade-20261113` | pending, 未开始 (0/0) — 目标含“28 个 variant 独立全文模板统一升级…”（与本新任务“存量模板改造/分级派生”高度相关、潜在冲突/衔接对象） |
| `task-veriffirst-20261116` | pending, 未开始 (0/0) |
| `task-workflow-multimodel-delegation-20261109` | pending, 未开始 (0/0) |

- **观察**：INDEX 未列 `task-instruction-iteration-20261117`、`task-intent-project-align-20261117`，但工作树存在与之语义匹配的未提交改动簇（见 §1），提示“在途半成品/未登记计划”风险；`task-variant-upgrade-20261113`、`task-l0lite-exempt-20261103`、`task-positioning-20261115` 与当前未提交/未跟踪产物存在主题交叉。

---

## 9. 设计相关关键现状结论（供后续设计引用）

1. **防倒退既有基础已强**：51.15(Spec-Baseline 冻结+四环) + 74.7(通用修改合规门) + 106.7/103.3b/22.4e(回归与派发/复检承载) 已成闭环且提交；两篇未跟踪 knowledge entry 已总结判例与教训，但未入 git。新机制应避免重复造轮子，重点补“模板域原则注入/主动加载/存量对齐/血缘版本化(lineage)”缺口。
2. **模板治理现状**：variant 31 个 + 根模板 13 个；白名单动态派生+check-template-type 门控+template-sense(T1/T3)+34.x 生命周期规则较完整；但**无 spec_version/lineage/parent 等派生元数据**，variant 与主模板结构漂移明显（主模板已含 Spec-Baseline/理解迭代等治理区块，抽样 variant 未同步），项目级覆盖靠目录发现无版本谱系。
3. **工作树风险**：18 个未提交改动分属多主题（理解迭代、项目定位、冲突不打断、plan-resume 重构等），且 forensics/session-plan/knowledge entry 未跟踪；在此基础上开展“模板治理+防倒退增强”需先做变更归属确认与基线隔离（尤其 `task_plan.md` 模板、task-planner SKILL、critical-rules*、config 与自测守卫）。

*（本报告基于只读命令输出与文件内容生成；所有路径为绝对路径，结论均附上述证据来源。）*
