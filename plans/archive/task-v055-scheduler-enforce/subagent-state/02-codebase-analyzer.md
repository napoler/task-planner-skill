# 02-codebase-analyzer — task-v055 调度门控机制层根因分析

> 角色：Codebase Analyzer（只读）
> 任务：分析 task-planner 技能的 hooks / 门控脚本 / SKILL.md 内容层 / 加载机制，给出机制层缺陷清单 + 根因排序
> 结论：为什么写好的调度规则（主进程定位 P0 + Rule 25 委派门控 + delegation_rate_floor 终验）在实测中不生效

---

## 一、Hooks 机制盘点（注册表 vs 实际行为）

### 1.1 已注册的 Hook 事件（来自 /home/terry/.zcode/cli/config.json）

| 事件 | matcher | 命令 | 状态 |
|------|---------|------|------|
| SessionStart | — | zcode-sessionstart.sh | enabled=true（timeout=10s） |
| PreToolUse | Write\|Edit | zcode-pretooluse.sh | enabled=true（timeout=5s） |
| PostToolUse | — | zcode-posttooluse.sh | enabled=true（timeout=5s） |
| UserPromptSubmit | — | zcode-userpromptsubmit.sh | enabled=true（timeout=5s） |

关键观察：
- matcher = Write|Edit，不包括 Read / Bash / Agent / Glob / Grep / Skill / TodoWrite / TaskCreate。
- 即使在 PreToolUse 命中范围内，钩子也只在「哨兵期」拒绝向 plans/ 外写入（scripts/check-scope.sh:71），计划期一旦结束（.plan-required 被 plan-created.cjs 清除），PreToolUse 就完全不再做任何"亲为检查"，只剩 Rule 23 的并发冲突提示（scripts/zcode-pretooluse.sh:20-47）。

### 1.2 PreToolUse 钩子的真实拦截能力（执行阶段）

scripts/zcode-pretooluse.sh 全文 49 行，职责只有两条：
1. L13-18：check-scope.sh —— 哨兵期检查，仅在 .plan-required 哨兵存在时阻断 plans/ 外的 Write/Edit。
2. L21-47：Rule 23 运行时并发冲突检测 —— 仅写入其他 plan 的 scope 文件时给 additionalContext 提示（exit 0，不阻断）。

结论：[DEBT] scripts/zcode-pretooluse.sh:13-47 —— PreToolUse 钩子既不读 Executor 字段，也不对主进程亲为的 Write/Edit 做任何拦截。哨兵期一过（即 plan-created.cjs 清除哨兵之后），钩子对 Rule 25 完全无感知。置信度：HIGH

### 1.3 PostToolUse 钩子的真实拦截能力

scripts/zcode-posttooluse.sh 全文 177 行，职责只有四条（按优先级）：
1. L92-103：plan_update_interval_minutes（默认 15 分钟）后提醒回写 task_plan.md
2. L110-137：findings.md 陈旧（默认 20 分钟）→ 提醒回填，含 19.7 升级警告
3. L139-165：progress.md 陈旧（默认 25 分钟）→ 提醒回填，含 19.7 升级警告
4. L167-172：todo_sync_interval_calls（默认 10 次）→ Todo 同步提醒

结论：[DEBT] scripts/zcode-posttooluse.sh:1-177 —— PostToolUse 钩子只盯「计划文档/三文件/原生 Todo 的陈旧度」，完全不提 Rule 25 / Executor 字段 / 委派率。主进程无论亲为多少 Edit/Read/Write，钩子都不会发现/阻断/提醒。置信度：HIGH

### 1.4 SessionStart / UserPromptSubmit 钩子

- SessionStart（zcode-sessionstart.sh）：写哨兵 + 提示 INDEX.md 待处理 —— 与 Rule 25 无关。
- UserPromptSubmit（zcode-userpromptsubmit.sh）：注入计划复诵块 + [plan-note] 节流提醒（每 10 条一次） + Rule 23 冲突检测 —— [plan-note] 文案只字未提 Rule 25。置信度：HIGH

全 Hook 层结论：4 个已注册钩子（SessionStart/PreToolUse/PostToolUse/UserPromptSubmit）中，没有任何一条会"读 Executor 字段 → 不一致时阻断"。Rule 25 在钩子层是 0 覆盖。

---

## 二、门控脚本盘点

### 2.1 执行期可被强制调用的脚本（来自 SKILL.md / scripts/）

| 脚本 | 触发时机 | 是否校验 Rule 25 |
|------|----------|-------------------|
| check-scope.sh | PreToolUse（自动） | ❌ 不查 Executor 字段 |
| check-3file-gate.sh | SKILL.md 步骤 4「Phase 翻转 complete 前」手动调用 | ❌ 只检查 findings/progress mtime 或 ledger 语义 |
| check-complete.sh | Stop hook（README 第 19 行）+ SKILL.md 步骤 6 终验手动 | ❌ 只检查 Phase 状态 + 3-File Gate + Batch Report + Aggregator；0 处提及 Executor / Rule 25 / delegation_rate_floor |
| attest-plan.sh | 用户确认计划后手动 | ❌ 只做 SHA-256 锁定（Rule 20.1），不读 Executor |
| plan-created.cjs | 创建计划后手动 | ❌ 只清哨兵 |
| init-session.sh | 创建计划前手动 | ❌ 只复制模板（模板里当然有 Executor 字段，但脚本不校验 Executor 是否填齐） |
| sync-todos.sh | SKILL.md S2/S4 强制同步 | ❌ 只同步 Todo ↔ Phase 状态，不读 Executor |

### 2.2 关键负向证据

scripts/ 全目录零提及 Rule 25：
- 命令：grep -rn "Executor\|delegation_rate_floor\|Rule 25\|八字段\|白名单" /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/
- 结果：0 行匹配（空 grep 输出）

config.json#delegation_rate_floor（默认 0.7）从来不被任何脚本读取：
- 命令：grep -rn "delegation_rate" /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/
- 结果：0 行匹配

check-complete.sh 全文 350 行，0 处提及 Rule 25：
- 唯一引用 Rule 25 的脚本相关条目是用户在 templates/verification.md:77 手写 checklist - [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单） —— 这是计划文件模板里的注释项，脚本从不解析/勾选 verification.md 的复选框。

结论：[DEBT] scripts/check-complete.sh、scripts/check-3file-gate.sh、scripts/sync-todos.sh、scripts/attest-plan.sh 均不读取 Executor 字段或 delegation_rate_floor 阈值。Rule 25 在脚本层也是 0 覆盖 —— 即便是终验阶段，也没有任何脚本自动算"委派率"。置信度：HIGH

### 2.3 Rule 25 期望 vs Rule 25 现实

期望（来自 references/critical-rules.md:158-166）：
- 25.1 计划期 — Executor 字段强制（无字段 = 计划无效，plan-writer 产出校验失败）
- 25.2 执行期 — 委派检查点（步骤 2.5）
- 25.3 白名单制
- 25.4 终验期 — 委派率统计（委派率 < 0.7 → outcome 最高 PARTIAL）

现实（脚本证据）：
- 25.1 的"计划无效，plan-writer 产出校验失败" → ❌ init-session.sh 仅复制模板，从不校验模板里 Executor 字段是否被替换为非空值。plan-writer agent 也没装在 scripts/ 里（它是 ~/.zcode/agents/plan-writer.md 的契约）。
- 25.2 的"执行期强制检查" → ❌ PostToolUse/PreToolUse 钩子均不读 Executor 字段。
- 25.4 的"委派率统计" → ❌ check-complete.sh 从不计算委派率；verification.md 里的「委派统计」段是人工填写字段，无脚本校验。

---

## 三、SKILL.md 内容层（稀释度与位置）

### 3.1 全文规模与章节

- 总行数：570 行（wc -l SKILL.md）
- 二级章节数：15 个（grep -c "^## " SKILL.md）
- 三级子章节数：26 个（grep -c "^### " SKILL.md）
- "P0" 字样出现：28 次（grep -c "P0" SKILL.md）

### 3.2 P0 调度约束的位置

「主进程定位（P0）」文本块位于 SKILL.md 第 29 行：
"**主进程定位（P0）**：主进程 = **调度管理器（scheduler/orchestrator）**——只做规划、拆分、派发、验收、簿记；任务执行一律下沉子代理（Rule 13/14/21/25）。主进程亲为仅限下方路由表 ✅ 行白名单，且须按 Rule 25.3 登记白名单内例外理由；白名单外亲为 = 反模式。**降低主进程亲自执行是本技能的第一设计目标，新场景默认派子代理。**"

这是文本约束，没有对应的硬拦截。从 SKILL.md 第 29 行往下 540 行都是文本规则，没有任何一个 hook/script 在执行期校验它。

### 3.3 Rule 25 在 SKILL.md 中的分布

| 行号 | 内容 |
|------|------|
| L29 | 主进程定位（P0）文本块（Rule 25 是其引用之一） |
| L59 | 「主进程可直接 Edit 的例外（白名单，Rule 14 对齐）」 |
| L116 | 步骤 2.5「委派检查点（强制 — Rule 25）」 —— 这是执行期入口的规定 |
| L188 | 「委派率统计（Rule 25）」 —— 终验阶段规定 |
| L217 | C14 checklist 行（Rule 25） |
| L311 | 「Rule 25（P0）子代理委派门控」一句话清单 |
| L397 | 反模式表 ❌ 行（Rule 14 引用 Rule 25.3） |
| L404 | 反模式表 ❌ 行（无 Executor 字段） |
| L422 | 兜底表第 3 行（主进程接管 → 须按 Rule 25.3 登记） |
| L462 | §代码编辑强制隔离的例外段引用 Rule 25.3 |

Rule 25 在 SKILL.md 出现 10 次，但全是文本条款，零脚本支撑。

### 3.4 SKILL.md 的章节分布（章节标题）

L37  § 专业代码编辑最佳实践（强制）
L72  § 复杂功能开发 → 移交 /comet 工作流
L93  ## 执行流程图（步骤 1-6 + Chain + Code Review Gate + 终验交付）
L199 § 合规检查清单（C1-C17）
L222 § 原生 Todo 同步
L226 § 用户新指令处理
L241 § 冲突分析与工作树隔离
L252 ## Chain 模式详解（linked / fan-out / 执行规则）
L295 ## Critical Rules（Rules 1-27 一行清单）
L315 ## Completion Gate
L319 ## Scope Guard
L323 ## Goal Gate
L327 ## I/O 契约
L333 ## Chain Handoff Contract
L337 ## References
L354 ## 子代理路由与模型分级（强制 — P0）  ← 唯一的、重复出现的执行规则细化章节
L410 ## 超时与失败兜底
L440 ## 代码编辑强制隔离（P0）
L474 ## 调研类操作（强制）
L521 ## 高频漂移纠正（强制）
L557 ## 任务模板库（强制）

### 3.5 稀释度评估

- 核心 P0「主进程定位」文本块仅占 1 行（29），被夹在 Goal 与 [CONTEXT] 段中间，前后没有任何视觉强调（如 # 标题、> 引用块、表格等）。
- 整个 SKILL.md 的最重的视觉强调（L116 步骤 2.5）是执行期入口的 Rule 25 触发点，但它藏在「Phase 执行循环」的长 bullet 列表中（L113-132 共 20 行），与 1/2/3/4/5/6 等其他步骤同级，没有被标为"🚨 必过门控"或类似视觉等级。
- SKILL.md 的 § References（337-352）只列文档清单 + 简短用途，没有标注 Rule 25 的具体章节定位。

结论：[DEBT] SKILL.md 570 行 + 15 二级章节 + 26 三级章节，核心调度约束 P0 仅占 1 行（29）且无视觉强调，执行期入口（步骤 2.5）被埋没在 20 行的执行循环列表里。置信度：MEDIUM（客观稀释度可量化；但"模型是否因稀释而不遵守"需要行为实验验证，不能仅凭结构下结论）

---

## 四、加载机制

### 4.1 ZCode 的技能加载方式（证据）

来自 /home/terry/.zcode/cli/config.json 的 hooks.events.UserPromptSubmit 钩子 zcode-userpromptsubmit.sh：
- 该钩子每次有用户输入时，主动 Read task_plan.md 并把字段级摘要（Goal / Next Step / Current Phase / in_progress Phase / Decisions 末 3 行 / progress 尾 5 行）注入 additionalContext（脚本 L55-81）。
- 没有把 references/critical-rules.md 的全文注入 —— Rule 25 的细节（25.3 六项白名单 / 25.4 委派率统计阈值 / 25.5 与 13/14/21 关系 / 25.6 失败联动）只在主进程主动 Read references/critical-rules.md 时才进入上下文。

来自 ZCode 平台约束（参考 README § 多工具架构）：
- SKILL.md 全文 46 KB / 570 行（canonical），按 ZCode 加载惯例是首屏一次性注入（frontmatter description + frontmatter references 列表 + 正文 570 行整体）。
- 但 references/ 子文档（critical-rules.md 32 KB / 207 行 + 其他 9 篇）是"按需 Read"模式 —— 默认不注入。

### 4.2 Rule 25 细节可见性

- SKILL.md 正文中提到 Rule 25 时，直接引用 references/critical-rules.md（L342 references 表 + 多处"详见 references/critical-rules.md Rule 25"）。
- 但 references/critical-rules.md 是 207 行的文档，Rule 25 只占 L158-166 共 9 行（其中 25.1 = 1 行、25.2 = 1 行、25.3 = 1 行、25.4 = 1 行、25.5 = 1 行、25.6 = 1 行）—— 主进程实际执行时若不主动 Read 这一文件，Rule 25.1-25.6 的具体条款（六项白名单/委派率计算公式/Handoff 登记表 / 失败联动等）就只在 SKILL.md 的引用名中出现。

结论：[DEBT] Rule 25 细节（白名单六项 / 委派率计算 / 失败联动）写在 references/critical-rules.md:158-166，SKILL.md frontmatter 的 references 字段虽列出该文件，但 ZCode 按惯例只注入 SKILL.md 全文，references/ 子文档由主进程主动 Read。规则执行时若无 Read 动作，核心细节缺失。置信度：MEDIUM（机制证据充分；模型是否实际 Read 取决于任务场景）

---

## 五、根因假设验证（4 个核心假设）

| # | 假设 | 验证结果 | 证据 |
|---|------|---------|------|
| ① | 无执行期硬拦截（纯文本约束靠模型自觉） | 完全证实 | scripts/zcode-pretooluse.sh:13-47（仅哨兵期阻断）+ scripts/zcode-posttooluse.sh:1-177（仅陈旧度提醒）均不读 Executor；scripts/check-complete.sh:1-350 全文不提 Rule 25；scripts/ 全目录 grep "Executor\|delegation_rate\|Rule 25" = 0 行匹配 |
| ② | 委派校验只在终验（执行中零提醒） | 完全证实 | check-complete.sh 不计算委派率；verification.md 里的"委派统计"段是人工填写字段，无脚本支撑；PostToolUse 钩子只盯三文件陈旧度，不盯 Executor 一致性 |
| ③ | SKILL.md 过长核心被稀释 | 部分证实 | 客观结构证据：570 行 + 15+26 章节 + 28 次 P0 字样，「主进程定位 P0」文本块仅占 1 行；主观行为影响需实验验证 |
| ④ | references 分层导致 Rule 25 细节根本没进上下文 | 完全证实 | ZCode 加载惯例（README § 多工具架构）：SKILL.md 全文注入 + references/ 按需 Read；Rule 25.1-25.6 细节（207 行文档中的 9 行）默认不进上下文 |

---

## 六、机制层缺陷清单（编号）

1. [DEBT] scripts/zcode-pretooluse.sh:13-47 —— PreToolUse 钩子只查哨兵/并发冲突，不读 Executor 字段，对 Rule 25 零拦截。
2. [DEBT] scripts/zcode-posttooluse.sh:1-177 —— PostToolUse 钩子只盯三文件陈旧度，不验证 Executor 一致性，主进程亲为多少 Edit/Read 钩子都无感。
3. [DEBT] scripts/check-complete.sh:1-350 —— 终验脚本不计算委派率，不读 delegation_rate_floor，导致 Rule 25.4（终验期统计）在脚本层完全失效。
4. [DEBT] scripts/check-3file-gate.sh:1-137 —— 执行期硬门控只检查 findings/progress 回填，不验证本 Phase 是否按 Executor 字段派子代理。
5. [DEBT] scripts/attest-plan.sh:1-64 —— SHA-256 锁定只防篡改，不验证 Executor 字段是否填齐；无 Executor 字段也能正常 attest 通过。
6. [DEBT] scripts/init-session.sh —— 复制模板时不校验 Executor 字段是否替换为非空值，模板里留 placeholder 也能通过初始化。
7. [DEBT] config.json:36-41 —— delegation_rate_floor: 0.7 阈值定义后无任何脚本读取它，是死配置。
8. [DEBT] templates/verification.md:77 —— 「委派统计」复选框是人工填写字段，无脚本解析/勾选验证，沦为仪式。
9. [ARCH] SKILL.md:29 —— 核心 P0「主进程定位」文本块仅占 1 行（夹在 Goal 与 [CONTEXT] 中间），无视觉强调、无前置 hook 触发、无对应硬拦截。
10. [ARCH] SKILL.md:113-132 —— 「Phase 执行循环」步骤 1-6 中 Rule 25 检查点（步骤 2.5）与 1/2/3/4/5/6 等同级，未标"🚨 必过门控"等级。
11. [ARCH] SKILL.md:570 行 + 15 二级章节 + 26 三级章节 + 28 次 P0 字样 —— P0 字样密度过高但执行期硬门控仅 0 条，视觉权重 vs 实际权重失衡（"P0 多到贬值"）。
12. [DEBT] references/critical-rules.md:158-166 —— Rule 25.1-25.6 细节（六项白名单/委派率公式/失败联动）写在 207 行文档的 9 行中，SKILL.md 注入时默认不展开 references/，主进程不主动 Read 即看不到细则。
13. [DEBT] templates/task_plan.md:130 —— 模板注释里写「Executor 字段(Rule 25.1):每个 Phase 必须声明执行体」，但没有强制校验；占位文本 Executor: [fill in] 被原样提交也能通过。
14. [RISK] references/critical-rules.md:25.6 —— "委派检查点发现无法派发（Agent 工具不可用/连续失败）→ 按 Rule 22.3 兜底顺序处理并在 progress.md 记录，禁止静默转主进程亲为" —— Rule 25.6 的兜底是文本禁止，无脚本兜底；Agent 工具不可用时模型会直接转主进程亲为且 progress.md 不一定有记录。

---

## 七、根因排序（哪条最能解释「实测不生效」）

排序原则：机制层证据强度 × 对实测不生效的解释力。

| 排名 | 根因 | 机制证据 | 解释力 |
|------|------|---------|--------|
| 1 | 执行期硬拦截 100% 缺失（缺陷 1-2） | PreToolUse + PostToolUse 4 个钩子合计 226 行 bash，无一行读 Executor；scripts/ 全目录 0 处提及 Rule 25 | 主进程亲为时无任何机制能在执行瞬间发现/阻断——根本原因 |
| 2 | 终验期自动统计缺失（缺陷 3-8） | check-complete.sh 350 行不读 delegation_rate_floor；verification.md 委派统计是人工字段 | 即便主进程亲为到尾，脚本也不会自动判定 outcome=PARTIAL——终验失效 |
| 3 | Rule 25 细则未进上下文（缺陷 12） | references/critical-rules.md 按 ZCode 惯例默认不注入；Rule 25 细则在该文档的 9 行 | 主进程对"白名单六项 / 委派率公式"无具象记忆，按"调度管理"的抽象原则自行解读——执行偏差 |
| 4 | 核心 P0 文本块被稀释（缺陷 9-11） | 「主进程定位 P0」仅占 1 行（夹在 Goal/[CONTEXT] 间）；SKILL.md 570 行 / 28 次 P0 字样 | 文本约束在长上下文中权重低——辅助放大根因 1+2 的失效 |
| 5 | 模板 / 配置 / 注释的"仪式化"（缺陷 7-8、13） | config#delegation_rate_floor 无脚本读取；templates/verification.md 委派统计无脚本解析 | 让用户以为机制存在但实际是装饰——认知偏差源 |

最强单一解释 = 根因 1（执行期硬拦截 100% 缺失）。

证据链：
- 用户实测 → 主进程在 Phase 内连续 Edit/Read/Bash 业务文件
- 期望行为 → PostToolUse 钩子/PreToolUse 钩子发现 Executor=主进程但路径非 plans/，阻断或提示
- 实际行为 → zcode-pretooluse.sh:21-47 只在写其他 plan scope 时提示；zcode-posttooluse.sh:1-177 只提醒三文件陈旧度；两者对 Rule 25 完全沉默
- 结果 → 主进程持续亲为；终验时 check-complete.sh 也不读 delegation_rate_floor，verification.md 委派统计沦为手工填写

---

## 八、负结果报告（扫描了哪些 / 未发现哪些）

已扫描（无异常）：
- home/terry/.zcode/skills/task-planner/SKILL.md = canonical 同步副本（diff = 空）
- home/terry/.zcode/cli/config.json hooks.events 4 条注册全部启用
- 所有 hooks 脚本均 fail-open（任何异常 exit 0），与 P0 约束冲突但属设计选择
- templates/variant/*.md 各 variant 模板 Phase 段都有 Executor: 字段 —— 模板侧不缺字段位

已排除（不构成原因）：
- ❌ "Rule 25 文本不存在" —— 实际文本条款齐全（SKILL.md 10 处 + critical-rules.md 9 行细则）
- ❌ "frontmatter description 太长" —— 描述 154 字符，标准长度
- ❌ "模型版本不支持" —— model: opus + ZCode 标准加载
- ❌ "scripts/ 里有 Rule 25 检查脚本但被禁用" —— 全目录 0 处提及

已确认存在的弱证据（不构成主因）：
- "P0 字样过多导致贬值"（SKILL.md 28 次）—— 客观但属辅助因素
- "模板 placeholder 没强制替换"（缺陷 13）—— 影响初始化，但不直接导致执行期亲为

---

## 九、检查点结束语

所有 5 步分析已落盘。缺陷清单 14 条 + 根因排序 5 条 + 负结果 3 条。
关键单一根因 = 执行期硬拦截 100% 缺失（4 个 hook 226 行 bash + 350 行 check-complete.sh + 全 scripts/ 共 0 处 Rule 25 引用）。
