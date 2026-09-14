# Findings & Decisions
<!-- 
  WHAT: Your knowledge base for the task. Stores everything you discover and decide.
  WHY: Context windows are limited. This file is your "external memory" - persistent and unlimited.
  WHEN: Update after ANY discovery, especially after 2 view/browser/search operations (2-Action Rule).
-->

## Requirements
<!-- 
  WHAT: What the user asked for, broken down into specific requirements.
  WHY: Keeps requirements visible so you don't forget what you're building.
  WHEN: Fill this in during Phase 1 (Requirements & Discovery).
  EXAMPLE:
    - Command-line interface
    - Add tasks
    - List all tasks
    - Delete tasks
    - Python implementation
-->
<!-- Captured from user request -->
- 用户原话(2026-09-04):"我的目的就是优化该技能,确保从流程上可以避免降低质量……核心诉求就是质量高于速度,从流程上来提高质量、惩罚。优化该技能的相关步骤。"
- 拆解三条硬要求:①质量 > 速度(价值排序) ②流程性防降质(非口头提醒) ③对降质行为有惩罚(可判定后果)
- 任务本质:把"质量优先"从原则变成 task-planner 自身的可执行门控 + 可触发降级 outcome 的规则

## Research Findings
<!-- 
  WHAT: Key discoveries from web searches, documentation reading, or exploration.
  WHY: Multimodal content (images, browser results) doesn't persist. Write it down immediately.
  WHEN: After EVERY 2 view/browser/search operations, update this section (2-Action Rule).
  ⚠️ Rule 19.1: 子代理(Explore/web-search/doc-search/research-assistant 等)返回的结论写这里 —
     返回后紧邻一次 Edit,含结论摘要 + 证据路径(URL/file:line);禁止只留会话记忆。
  EXAMPLE:
    - Python's argparse module supports subcommands for clean CLI design
    - JSON module handles file persistence easily
    - Standard pattern: python script.py <command> [args]
-->
<!-- Key discoveries during exploration; subagent returns land here (Rule 19.1) -->
- **SKILL.md**(613 行,2026-09-04 Read):关键节定位 — 「合规检查清单 C1-C14」在 line 191-209;「终验交付」节在 line 302-313;「Critical Rules」引用在 line 300;「子代理路由与模型分级」在 line 359+;「代码编辑强制隔离」在 line 441+;「任务模板库」在 line 555+;「Chain 模式详解」在 line 241+
- **references/critical-rules.md**(158 行):现有 Rule 1-25。**关键现成范式**:Rule 18 = 批量质量门控(双采样 + 失败率熔断);Rule 19.2 = progress 回填门控;Rule 25.4 = 「委派率<50% 且无登记理由 → outcome 最高 PARTIAL」降级惩罚,可直接对齐为 Rule 26 的写法范式
- **templates/verification.md**(69 行):含 VC 表 + Phase Gates + 委派统计复验 + Goal Gate;无独立「质量统计段」(委派率已存在 line 70-72)
- **templates/task_plan.md**(367 行模板):本计划在此模板上填充,保留 Goal / VC / Scope / Phases / 隔离决策 / Todo 同步 / Decisions / Batch Report / 委派统计 / Handoff 登记 / Chain 区块 等全部章节
- **scripts/check-complete.sh**(行 167-185 块):**发现脚本自身 bug** — line 173-177 因 4 空格缩进落入 line 167 `if total == 0` 早退分支内,导致含 Phase 的计划执行时 `aggregator_missing` 永不初始化,line 183 顶层引用触发 NameError → exit 1。影响所有含 Phase 的计划,与本计划内容无关。修正属 Phase 4d 触发条件 → 必做
- **冲突扫描**:仅信号①(.plan-required 与 plans/),无 ②③④⑤,无主仓重叠

### Phase 2 现状盘点 — 差距清单(codebase-analyzer,2026-09-04,抽查 5/5 引用属实)

**结论**:现有机制(Rule 18/19.2/22.5/25.4)只**间接**约束降质;无统一"质量违规→惩罚"条款、verification.md 无质量统计段、C1-C14 无质量违规检查项 — 即 Rule 26 补强空间。

| # | 已有机制 (file:line) | 缺口 | Rule 26 候选补强点 |
|---|---------------------|------|-------------------|
| 1 | Rule 18 批量门控 `critical-rules.md:73-83` | 只覆盖批量场景;单 Phase 跳验证无门控 | 质量违规抽成独立维度,单/跨 Phase 跳步也熔断 |
| 2 | Rule 19.2 回填门控 `critical-rules.md:91` | 卡"是否回填",不验回填内容真实性 | 回填须含客观痕迹(Read 输出/命令返回/文件 size) |
| 3 | Rule 25.4 委派率 `critical-rules.md:156`+`SKILL.md:183` | 只统计"是否派",不验"派后真用" | 委派率造假/未真用列为违规项触发 PARTIAL |
| 4 | C5 + completion-gate Read 验证 `SKILL.md:200`+`completion-gate.md:6-9` | 未覆盖主进程直做路径(无独立验证) | 主进程直做 Phase 须自带自验证 gate |
| 5 | C1-C14 `SKILL.md:193-209` | 全是流程合规项,无"质量违规→降级"项 | 新增 C15 质量门控项,违规对应 outcome 降级映射 |
| 6 | verification.md 模板 `templates/verification.md:69-72` | 无质量违规统计段/验证压缩记录 | 新增质量违规日志段(结构可抄委派统计段) |
| 7 | Rule 11/15 漂移检测 `critical-rules.md:35-44` | 只检计划偏离,不检质量偏离(砍 VC/压缩验证) | drift-guard 增 quality 轴 |
| 8 | goal-gate outcome 规则 `goal-gate.md:13-18` | outcome 仅由 VC 通过率决定,无过程违规扣分 | outcome = f(VC 通过率, 过程合规) |
| 9 | task_plan 模板 VC 表 `templates/task_plan.md:29-48` | 无质量门控类 VC | VC 表新增必选"质量门控 VC"≥1 条 |
| 10 | check-complete.sh `SKILL.md:187-189` | 只查 Phase 状态,不查质量动作做过没 | 脚本质量指纹校验(先修 NameError bug) |

**6 类降质行为门控判定**:跳过 VC 复验=部分(缺自动化校验);压缩验证步骤=**无**(非批量场景);未 Read 子代理产出=**有**(三处交叉);伪造证据=弱(attestation 只锁 plan 不锁 findings/progress);批量牺牲准确性=**有**(Rule 18 全套);主进程越权直做=部分(只统计不验真实性)。

**负结果报告**:未发现"质量违规→降级"统一条款/质量统计段/C15+ 质量项;hooks 层证据校验未查(低置信度待补,不阻塞设计)。

来源:agent_d3f3522e(9 tool_uses);主进程抽查:SKILL.md:183/200、critical-rules.md:121、goal-gate.md:4、verification.md:69 全命中。

## 方案设计(Phase 3 权威产出 — architect agent_28ba4222,锚点已经主进程复核)

### Rule 26 条款全文(粘贴进 critical-rules.md 末尾,25.6 之后)

```markdown
### 26 质量优先于速度门控(P0)— 验证步骤不可压缩,降质行为必触发可判定惩罚

Rule 18 管批量质量、19.2 管回填存在性、25 管委派率,但单/非批量场景"为赶速度压缩验证、伪造证据、复验走形式"无门控。本规则把「质量 > 速度」做成可判定门控:每种降质行为对应可观察判定式 + 确定性惩罚。执行者自评的速度收益不得作为跳过/压缩验证的理由。

26.1 **触发条件(可观察判定式)**:
- **Q1 跳过 VC 复验**:task_plan.md 中 `**Status:** complete` 的 Phase,其在 verification.md 对应段的 V-N 项存在未勾选 `- [ ]` 或 Evidence 字段为空(grep + Read 可判)
- **Q2 压缩验证步骤(非批量)**:progress.md 该 Phase 段「Test Results」字段缺失/为空/仅写"跳过",且无 26.4 豁免登记
- **Q3 证据不实(伪造/篡改)**:抽查 ≥3 条 Evidence(VC 总数 <3 时全查),任一条路径 Read 失败、或重跑命令输出与声称结论矛盾、或引用内容在指定 file:line 处不存在
- **Q4 未 Read 子代理产出**:Handoff 登记表该 Phase 行 `verify_done` 未勾或 progress.md 无 Read 复核记录,而该 Phase 已标记 complete
- **Q5 委派率 <50% 且无登记理由**:判定与处置引用 Rule 25.4,此处不重复定义
- **Q6 批量违规未处置**:Batch Report 八字段缺项(Rule 18.6)或 failure_rate >5% 未执行 STOP(Rule 18.3)

26.2 **判定时机(双检查点)**:① 执行期——Phase 标记 complete 前核查 Q1/Q2/Q4(单 Phase 粒度);② 终验期——Goal Gate 判定 outcome 前核查 Q3(抽查)+ Q5/Q6(汇总),结果写入 verification.md「质量门控统计」段。

26.3 **惩罚映射(确定性,无自由裁量)**:

| 触发 | 处置 |
|------|------|
| Q1/Q2/Q4 首次、单 Phase | 强制回炉:撤销 complete → 补做验证/Read 复核 → 重走 Rule 19.2 回填 |
| Q1/Q2/Q4 会话内累计 ≥2 Phase | outcome 最高 PARTIAL |
| Q3 证据不实 | 最高档:不得自判 COMPLETE/PARTIAL,以 BLOCKED 上报 + STOP 等用户裁决;禁止以"补做验证"恢复 |
| Q5 | outcome 最高 PARTIAL(Rule 25.4 原处置) |
| Q6 | 按 Rule 18.3 STOP/熔断;若 Phase 已 complete 而未处置 → outcome 最高 PARTIAL |

26.4 **例外与豁免**:仅用户**显式文字**豁免有效——写入计划(VC 表/Executor 字段)或会话明确答复(如"跳过 V-3"),且登记进 verification.md「质量门控统计」段豁免行(项号/范围/理由/日期);口头含糊表态(「尽快」「先这样」)不构成豁免;执行期不得以速度压力自我豁免;**Q3 无事前豁免**——事后处置权在用户,不在执行者。

26.5 **与相关 Rule 关系**:18 管批量门控本体、19.2 管回填存在性、22.5 管 Handoff Read、25 管委派率——各自管检测,26 统一管「违规 → 惩罚」映射,并补齐非批量场景的验证压缩门控;检测点不重复,惩罚不双计(同一行为由其属主条款处置一次)。

26.6 **失败联动**:违规即以 `[quality-violation]` 标签写 progress.md Error Log + task_plan.md Errors 表(复用 Rule 6/19.4 通道);终验 outcome 判定前,质量门控统计段存在未处置违规 → 禁止 COMPLETE;C15 未勾 → 禁止进入终验交付。
```

### 跨文件落地清单(锚点已主进程逐条复核 2026-09-04)

| # | 目标文件 | 锚点(已复核) | 改动 |
|---|---------|------|--------------|
| 1 | references/critical-rules.md | 末尾 25.6 之后 | 追加 Rule 26 全文 |
| 2 | SKILL.md | :300 Rule 25 索引行后 | 追加 2a 索引行 |
| 3 | SKILL.md | :183「委派率统计」bullet 后 | 追加 2b 质量门控统计 bullet |
| 4 | SKILL.md | :209 C14 行后 | 表格新增 C15 行(2c) |
| 5 | templates/verification.md | :72 委派统计段后、:74 Goal Gate 前 | 新增 3a 小节 |
| 6 | scripts/check-complete.sh | :171-177 | 去掉 :173-177 的 4 空格缩进使 `aggregator_missing = []` 顶层初始化(architect 已临时副本验证:NameError 消失,输出 ALL PHASES COMPLETE)——必做 |
| 7 | scripts/check-complete.sh | 不改动 | 质量硬校验本期不采纳(理由:数据源只有 plan,新解析面 + 旧计划兼容成本;降级为后续可选项) |

**2a**(SKILL.md :300 后):
`- **Rule 26（P0）质量优先于速度门控**：6 类降质行为可观察触发式 + 确定性惩罚映射（回炉→PARTIAL→BLOCKED），伪造证据无豁免（详见 references/critical-rules.md Rule 26）`

**2b**(SKILL.md :183 bullet 后):
`- **质量门控统计（Rule 26）**：按 verification.md「质量门控统计」段核查 Q1-Q6 触发与豁免登记；抽查 ≥3 条 Evidence（路径可 Read、结论可复现）；存在未处置违规 → 按 Rule 26.3 降级 outcome；Q3 → outcome 判 BLOCKED 并 STOP`

**2c**(SKILL.md C15 行):
`| C15 | 本 Phase 无未处置质量违规：V-N 全勾且 Evidence 非空、Handoff verify_done 已勾、无 Rule 26 触发项（或已豁免登记）（Rule 26） | ☐ |`

**3a**(verification.md 新小节,插在委派统计复验段与 Goal Gate 之间):
```markdown
## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP
```

### 预填决策裁决(architect)

| 预填决策 | 裁决 | 理由 |
|---------|------|------|
| 沿用 Rule 25.4 降级范式 | 采纳 | 强化:Q3 伪造证据单列 BLOCKED 档(PARTIAL 对信任破坏不够重) |
| 触发条件 6 条 | 调整 | Q5/Q6 引用 25.4/18.3 不重定义;每条补可观察判定式+双检查点 |
| verification.md 嵌入委派统计段 | 推翻嵌入,改紧邻独立小节 | Q1-Q6 计数与委派率字段不同构,混入会自相矛盾;仅多 ~5 行不违 YAGNI |
| C 清单新增 C15 | 采纳 | 与 C14 同构;不加 C16 |
| check-complete.sh 修 bug+硬校验 | 拆分:修复采纳,硬校验不采纳(本期) | 修复已验证必做;硬校验有新故障面+旧计划兼容成本 |

### 后续可选项(本期不实施)
check-complete.sh `--quality` 可选参数 / hooks 层 Evidence 存在性校验 / drift-guard quality 轴 / task_plan 模板「质量门控 VC」必选 / goal-gate.md outcome=f(VC,过程合规)(26.6 已间接覆盖)。

风险:check-complete.sh 是 Stop hook 依赖脚本,修复后行为从"全 NameError exit 1"变"正常 exit 0/1",合并回后需用真实旧计划回归一次(纳入 Phase 5b)。

来源:agent_28ba4222(15 tool_uses);置信度高;主进程锚点复核 4/4(SKILL.md:300/209、verification.md:69-74、critical-rules.md 末尾 25.6)。

## critic 审查结论(Phase 5a — agent_18df94ed,置信度 HIGH)

**总裁定:ISSUES_FOUND(非阻塞)——主体一致可合并**。六项验收 5 PASS + 1 PASS(NIT)。亮点验证:check-complete.sh `git diff -w` 为空=纯缩进修复(AST 证实);3a/2a/2b/2c 与设计稿字节级一致;Rule/C 编号无冲突。

已处置:
- 🟡 SKILL.md:288/:350 "Rules 1-25"陈旧范围标签 → 主进程行定位修复为 1-26(worktree commit 367f388)
- NIT 全角括号:worktree 内部统一全角(与 Rule 25 一致),保留;设计稿以本段为准视为已归一

已知遗留(记录不阻塞,期后处理):
- 💬 C15 检查时机与"每 Phase 开始前"清单标题语义错位(C14 同有,属既有模式);实际行为由 Rule 26.2 双检查点定义(执行期末自查+终验复核),使用时按此勾选
- 💬 段名引用用子串「质量门控统计」(heading 带 (Rule 26) 后缀),与既有「委派统计」前缀引用惯例一致,不改

## Technical Decisions
<!-- 
  WHAT: Architecture and implementation choices you've made, with reasoning.
  WHY: You'll forget why you chose a technology or approach. This table preserves that knowledge.
  WHEN: Update whenever you make a significant technical choice.
  EXAMPLE:
    | Use JSON for storage | Simple, human-readable, built-in Python support |
    | argparse with subcommands | Clean CLI: python todo.py add "task" |
-->
<!-- Decisions made with rationale -->
| Decision | Rationale |
|----------|-----------|
| 沿用 Rule 25.4 「委派率 <50% → outcome 最高 PARTIAL」作为 Rule 26 降级惩罚范式 | 现有最相近的可判定降级机制,降低用户学习成本;Rule 25.4 已被验证可用 |
| Rule 26 触发条件清单:跳过 VC 验证 / 压缩验证步骤 / 伪造证据 / 未读子代理产出即标记 complete / 委派率 <50% 无理由 / 批量场景 failure_rate >5% | 覆盖"为赶速度牺牲质量"的高频反模式;每条配 outcome 降级映射 |
| verification.md 质量统计段:嵌入既有「委派统计复验」段,不新增独立段 | YAGNI;现成 line 69-72 已含委派率,只需在 Phase Gates 各 Phase 增"质量违规计数"字段 |
| C 清单新增 C15「本 Phase 质量门控通过(无违规触发 Rule 26)」,对齐 C14 既有写法 | 与 C1-C14 同构,符合用户原话"流程上"语义 |
| scripts/check-complete.sh 必改:修复 line 173-177 缩进 bug + 新增 C15 硬校验(若 batch 报告完整则 exit 0) | 缩进 bug 已在 plan 撰写期发现;若不修,check-complete.sh 对所有计划持续 NameError,与本任务"质量门控"主旨冲突 |

## Issues Encountered
<!-- 
  WHAT: Problems you ran into and how you solved them.
  WHY: Similar to errors in task_plan.md, but focused on broader issues (not just code errors).
  WHEN: Document when you encounter blockers or unexpected challenges.
  EXAMPLE:
    | Empty file causes JSONDecodeError | Added explicit empty file check before json.load() |
-->
<!-- Errors and how they were resolved -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 
  WHAT: URLs, file paths, API references, documentation links you've found useful.
  WHY: Easy reference for later. Don't lose important links in context.
  WHEN: Add as you discover useful resources.
  EXAMPLE:
    - Python argparse docs: https://docs.python.org/3/library/argparse.html
    - Project structure: src/main.py, src/utils.py
-->
<!-- URLs, file paths, API references -->
-

## Visual/Browser Findings
<!-- 
  WHAT: Information you learned from viewing images, PDFs, or browser results.
  WHY: CRITICAL - Visual/multimodal content doesn't persist in context. Must be captured as text.
  WHEN: IMMEDIATELY after viewing images or browser results. Don't wait!
  EXAMPLE:
    - Screenshot shows login form has email and password fields
    - Browser shows API returns JSON with "status" and "data" keys
-->
<!-- CRITICAL: Update after every 2 view/browser operations -->
<!-- Multimodal content must be captured as text immediately -->
-

---
<!-- 
  REMINDER: The 2-Action Rule
  After every 2 view/browser/search operations, you MUST update this file.
  This prevents visual information from being lost when context resets.
-->
*Update this file after every 2 view/browser/search operations*
*This prevents visual information from being lost*
