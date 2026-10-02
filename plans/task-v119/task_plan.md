# Task Plan: task-v119 创建高复杂度规划备用 Agent（GLM5.3/Opus 级）

<!-- plan_tier: standard -->
## Goal

新建 `complex-planner` agent（GLM5.3 完整版 / Opus 级模型 frontmatter），定位为**高复杂度任务的解决规划备用方案**——仅当任务复杂度过高或常规档反复失败时启用——canonical 入库 `skills/task-planner/companion/agents/`，部署 zcode/claude 两部署位，并在 skill-agent-router 路由表登记触发行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯新增 1 个 .md agent 定义文件 + 单行路由登记，无代码文件改动；轻 diff 豁免） |
| `session_id` | `8e008b7fa380491996f76341cb771c8a` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v119` |
| `scope_files` | `skills/task-planner/companion/agents/complex-planner.md`（仓内唯一源文件）；部署位与路由表见「执行范围限制」 |
| `interaction_mode` | `ask`（缺省回落 config，D1 批准门控生效） |
| `对齐审查` | 产出为新增单文件（纯新增无联动改写），完成前对 complex-planner.md 过 alignment-review 快检（42.6.2 标准收尾）；无版本一致性联动面（42.6.1 n/a） |
| `自动超时默认项` | 本任务唯一 2+ 选项询问点 = D1 计划批准（默认=本计划推荐方案，超时 5 分钟）；其余选型差异项已在 Decisions Made 直接裁决登记（44.2 低区分度不打扰） |
| `质量审查工具` | 检测结论（Rule 42.2 四级）：①项目级无专用技能 ②用户级 alignment-review 在位（用于收尾对齐快检）③环境既有 agents 中 frontmatter-linter 可做机械校验（备选，本任务以主进程 grep 断言为主——前置调研证明 selftest 仅锚 plan-writer 单文件，新增文件零守卫破坏）④review-library 池不适用（非代码/内容审查面）。执行期用登记工具：alignment-review |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：VC-4 由 code-runner-agent 独立执行；VC-5/VC-6/VC-7 由主进程机械命令产出证据（白名单③只读）；结构断言均以 grep/md5/diff 第一手输出为准。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | canonical 文件存在且 frontmatter 四要素完整：`name: Complex Planner`、`tools:` 含 Read/Bash/Agent、`model: "account:zai-individual-coding-plan/GLM-5.3"`（引号式裸 providerId/modelId）、`thoughtLevel: enabled` | grep 逐行断言 | `grep -n '^name:\|^tools:\|^model:\|^thoughtLevel:' <worktree>/skills/task-planner/companion/agents/complex-planner.md` |
| VC-2 | description 含①高复杂度门控语义（含"仅/只有/复杂度过高"等义锚）②≥3 个触发词 ③与 complex-problem-solver 的分工边界句 | grep 断言 | 同上文件 `grep -n 'description:'` 输出对照本表 |
| VC-3 | 正文含①触发门槛段 ②禁用清单段 ③规划产出契约五段锚（问题解构/方案候选/分步计划/风险兜底/验收标准）④证据要求段 ⑤禁止行为段（不直接改业务代码/常规任务禁用） | grep 段落锚 | 同上文件 grep 五段标题 |
| VC-4 | 全量 selftest 回归 fail=0（基线 42 脚本 660 用例，不降级） | code-runner-agent 独立执行 | worktree 内 selftest 输出全文存 progress.md |
| VC-5 | 部署 2 位到位：`~/.zcode/agents/complex-planner.md` 与 canonical md5 一致；`~/.claude/agents/complex-planner.md` 仅 model 行不同（=`model: opus`） | md5sum + diff | 两部署位 md5 与 diff 输出 |
| VC-6 | skill-agent-router 路由表含 complex-planner 行（含高复杂度门控措辞）；`~/.agents/skills/skill-agent-router/` 若存在同名文件则同步 | grep | `grep -n 'complex-planner' ~/.zcode/skills/skill-agent-router/SKILL.md` |
| VC-7 | 合并回完成：master `git log` 含 wt/task-v119 合并提交；`git worktree list` 无 task-v119 残留；`git branch` 无 wt/task-v119 | git log/worktree list/branch | 命令输出 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: n/a`，无 Code Review Gate 前置。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 仓内源文件（worktree 内） | `skills/task-planner/companion/agents/complex-planner.md`（新增） | task-planner SKILL.md / references/critical-rules.md / templates/** / 既有 3 个 companion agent / config.json / scripts/** |
| 部署位（合并回后） | `~/.zcode/agents/complex-planner.md`（新增）；`~/.claude/agents/complex-planner.md`（新增，model 行=opus） | 既有 87 个 agent 文件、`~/.zcode/cli/config.json`、任何 hook/技能文件 |
| 路由登记 | `~/.zcode/skills/skill-agent-router/SKILL.md`（路由表追加 1 行）；`~/.agents/skills/skill-agent-router/SKILL.md`（若存在，同步同一行） | 该文件其他区块、sub-agents/SKILL.md（调研确认无需同步） |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？（本计划 D1 批准 = 上表写入授权，含保护区文件逐项列名）
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（agent 创建+可被路由触发=用户原始诉求）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 宿主可用模型清单（GLM-5.3 完整版在位） | ListModels 输出（本会话 2026-10-03，`account:zai-individual-coding-plan/GLM-5.3` levels low/high/max） | 必读 | ☑ |
| 项目内部文档/知识库 | agent 结构先例（升级型 agent 范式） | `~/.zcode/agents/complex-problem-solver.md`（全文 60 行已读） | 必读 | ☑ |
| 项目内部文档/知识库 | 裸 providerId/modelId model 行在用先例 | `~/.zcode/agents/executor.md:5`（`model: 9a69b164-.../agnes-3.0-flash`） | 必读 | ☑ |
| 项目内部文档/知识库 | claude 位 model 适配逻辑 | `skills/task-planner/lib/install-companion.sh:70-86` adapt_model_line | 参考 | ☑ |
| 项目内部文档/知识库 | 路由表登记位 | `~/.zcode/skills/skill-agent-router/SKILL.md:97`（complex-problem-solver 行范式） | 必读 | ☑ |
| 项目内部文档/知识库 | 守卫波及面调研结论 | findings.md §Research Findings（selftest 仅锚 plan-writer，新增零破坏） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 常规档（haiku/sonnet 档 agent）承载不了的高复杂度任务缺少专用的大模型规划升级出口——新建一个仅在"任务复杂度过高"时启用的 GLM5.3/Opus 级规划 agent 作为备用方案。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（agent 文件入库+部署+路由登记后即可被 auto-router/主进程在高复杂度场景派发）
- [x] 核心问题不解决，其他工作都白费吗？（是——文件本身即交付物）
- [x] 核心问题的解决方法是清晰的、可执行的？（先例充分：complex-problem-solver 结构 + executor.md model 行式 + install-companion 部署链）

## Current Phase

Phase 4（in_progress — P1-P3 已 complete，合并回+部署+终验）

## Next Step

smart-merge-back 合并 wt/task-v119 → 部署 2 位 → 终验 VC-1..7 → 簿记交付

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) | 单文件 .md 撰写，判断型任务，规格已在 knowledge-brief §5 全文给定，executor 照规格转写+自验 |
| Phase 2 | Agent 子代理 code-runner-agent(mini) | 跑全量 selftest=机械测试执行，独立验证视角（VC-4 独立性要求） |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) | 单文件单行追加（≤3 行 trivial 级），机械插入 |
| Phase 4 | 机械守卫脚本 + git 编排（主进程白名单①②③） | 合并回/部署 cp/终验簿记均为编排与簿记动作 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（4 Phase 线性依赖链，无独立并行子任务）→ 按 Rule 21.4 独立性守门串行调度（P1→P2 同仓内产物有验收依赖；P3 依赖 P1 定稿的 agent 名与措辞；未声明并行组）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定，不适用

## Phases

### Phase 1: 撰写 complex-planner.md（worktree 内）
- [ ] 建 worktree `/home/terry/task-planner-skill-worktrees/task-v119`（分支 wt/task-v119，基线 master）
- [ ] 按 knowledge-brief §5 全文规格撰写 `skills/task-planner/companion/agents/complex-planner.md`
- [ ] 执行体自跑结构断言（frontmatter 四要素 grep + 五段锚 grep）并回传 8 字段结果
- [ ] 主进程 Read 复核全文 + findings.md 回填
- **V-N:** VC-1, VC-2, VC-3（P1 全过：R8 一手复核+三组 grep 证据）
- **Status:** complete（2026-10-03 04:20）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 按 knowledge-brief §5 规格逐字撰写 agent 文件并自跑两组 grep 断言 | 继承（executor, sonnet-1） | `<plan-dir>/knowledge-brief.md` §5 全文规格（约 55 行 .md：frontmatter 7 行+正文五段）+ §3 模型行格式决策 | 文件存在；VC-1/VC-2/VC-3 三组 grep 断言全过；8 字段返回含 grep 原始输出 | 10min | pending |

### Phase 2: 全量 selftest 回归（worktree 内）
- [ ] code-runner-agent 在 worktree 内跑全量 selftest（无聚合 runner：`for t in <worktree>/skills/task-planner/scripts/selftest-*.sh; do bash "$t" || echo "FAIL: $t"; done`，共 42 脚本）
- [ ] 结果全文回 progress.md；fail>0 → 走 Rule 22.3 兜底链
- **V-N:** VC-4, VC-1（VC-4 过：TOTAL=42 FAIL=0 + smoke 17/0）
- **Status:** complete（2026-10-03 04:2x；执行体改主进程接管，白名单③——provider 2 连拒后 Rule 22.7 换道）
- **Executor:** code-runner-agent（mini）→ 实际执行主进程（接管登记：Rule 25.3 白名单③ 机械验证命令；Handoff #2）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S2 | worktree 内 for 循环跑 42 个 selftest-*.sh 并汇总 fail 数 | 继承（code-runner-agent, mini） | worktree 根路径（绝对路径派发时给出）+ 循环命令一行 | 输出 FAIL 计数=0；各脚本 pass/fail 汇总行回传 | 10min | pending |

### Phase 3: skill-agent-router 路由登记（部署位）
- [ ] code-assistant 在 `~/.zcode/skills/skill-agent-router/SKILL.md` 路由表 L97 `complex-problem-solver` 行后追加 1 行（行内容见 knowledge-brief §6，diff 先展示后写）
- [ ] 探测 `~/.agents/skills/skill-agent-router/SKILL.md` 是否存在；存在则同步同一行，不存在记一行跳过
- [ ] 主进程 Read 复验两处 + findings.md 回填
- **V-N:** VC-6（过：:98 行在位，主进程 Read 一手复核；.agents 位不存在=计划预期分支，记行跳过）
- **Status:** complete（2026-10-03 04:35）
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S3 | 路由表追加 complex-planner 行（+可选 .agents 位同步） | 继承（code-assistant, haiku-1） | 派发 prompt 内含待写入行全文（knowledge-brief §6）+ 目标文件绝对路径 + L97 锚点行原文 | grep 'complex-planner' 命中；表格行数 +1 且列数对齐 | 5min | pending |

### Phase 4: 合并回 + 部署 2 位 + 终验簿记交付
- [ ] worktree 内 Phase 1-3 产物已提交、status 干净 → `smart-merge-back.sh`（ALREADY_MERGED/预检走智能门）→ 清理 worktree+分支
- [ ] 部署：`cp` canonical → `~/.zcode/agents/complex-planner.md`；`cp` + sed model 行 → `~/.claude/agents/complex-planner.md`（`model: opus`）；md5/diff 复验（定向单文件 cp，禁 rm -rf 整目录）
- [ ] 终验：逐条复验 VC-1..VC-7 + check-complete.sh + 委派统计/3-File Gate/质量门控统计
- [ ] 簿记：INDEX 刷新、memory 更新、交付总结五要素（存证 plans/task-v119/delivery-summary.md）
- **V-N:** VC-5, VC-7（双过：md5 6bcf4195 双位一致/diff 仅 model 行=opus；merge a4bbd19+worktree/分支清零）
- **Status:** complete（2026-10-03 04:5x）
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排 + ② 计划系统文件/簿记——Rule 25.3 白名单；部署 cp 为编排动作白名单①）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`：信号① 未提交变更 3 处（plans/task-v118/ 未跟踪 + task-v116 dispatch-inflight 修改——均与本任务 scope 零重叠）；信号② 存在 1 个并行 worktree `/home/terry/task-planner-skill-worktrees/task-v118`（wt/task-v118，Rule 46 任务，scope=critical-rules/templates，与本任务 scope=companion/agents/ 零重叠）；信号③ 遗留 wt/task-v118 分支（属 v118 自身未合并态，非本任务孤儿）；信号④⑤ 无 |
| `isolation` | `worktree`（§11.1.1 保护区命中：agent 定义文件；与 v118 并行任务隔离） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v119` |
| `branch` | `wt/task-v119` |
| `merge_back` | `merged(a4bbd19)`（smart-merge-back V1-V6 全过，worktree+分支已清理） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。并行纪律：禁止触碰 wt/task-v118 内容与其 scope 文件（critical-rules.md/templates/**），主仓不切分支。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | executor 偏离规格（漏门控语义/五段锚） | 6 | 3 | 2 | 36 | 验收 grep 断言不过 → 打回重写（改派档①，同 S-unit 重派 1 次），仍不过 → 主进程按白名单⑤接管 |
| Phase 1 | GLM model 行格式不被 harness 解析（新范式无行为级先例） | 7 | 2 | 4 | 56 | 结构同构断言兜底（executor.md 裸式先例）+ 交付报告显式登记"行为级未验证"+ 新会话冒烟建议（Rule 43.1 未验证显式登记）；若用户回报不可用，单行 sed 切 `opus-1` 即降级 |
| Phase 3 | 路由表行格式破坏表格 | 4 | 2 | 2 | 16 | 单行追加+Read 复验列数；破坏则 git/备份还原该文件后重插 |
| Phase 4 | 部署覆盖/漂移 | 8 | 2 | 3 | 48 | 定向单文件 cp（禁整目录 rm）+ md5/diff 双复验；目标已存在则先 Read 对照再覆盖 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-03（S1 建映射） | pending→待批准 |
| Phase 2 | ☑ | 2026-10-03（S1 建映射） | pending |
| Phase 3 | ☑ | 2026-10-03（S1 建映射） | pending |
| Phase 4 | ☑ | 2026-10-03（S1 建映射） | pending |

## Key Questions

1. GLM-5.3 在 agent frontmatter 如何声明？→ 已裁决（D2）：裸 providerId/modelId 引号式，同 executor.md 先例形态；`custom:` 式不适用（GLM 不在 ccr UUID provider 下）
2. 行为级验证（真实派发 GLM 档）能否本会话完成？→ 不能：agent 类型列表会话启动固化（v055 先例），新 agent 本会话不可派发 → 结构验证 + 新会话冒烟建议（D6，Rule 43.1 显式登记）
3. 与既有 complex-problem-solver 如何分工？→ CPS=失败升级+问题分解（sonnet 档，通用疑难）；complex-planner=高复杂度任务的深度规划（GLM5.3/Opus 级，产出可执行计划）。互补不重叠，CPS 不改动
4. 触发面如何保证"只有复杂度过高才用"？→ 三层：description 门控语义（Agent 工具匹配层）+ skill-agent-router 表行（路由层）+ 正文禁用清单（agent 自拒单层）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 命名 `complex-planner`（Complex Planner） | 与 complex-problem-solver 命名族一致且简短；弃 high-complexity-planner（冗长）。**计划批准=本表全部文件写入授权（含保护区逐项列名）** |
| D2 model 行 `model: "account:zai-individual-coding-plan/GLM-5.3"`（引号式裸 providerId/modelId） | ListModels 确认在位（levels low/high/max 默认 max=Opus 级同档）；裸式有 executor.md 在用先例；引号防 YAML 冒号歧义；`custom:ccr-uuid:` 式不适用（GLM 非 ccr provider） |
| D3 claude 位 model 行 = `opus` | claude 平台无 GLM 提供方；用户原话"或者其他 Opus 级别模型"授权等价档；符合 install-companion adapt_model_line 降级精神（custom:→纯档位名） |
| D4 task-planner SKILL.md:339/349 + critical-rules.md:149「升级 ComplexProblemSolver」叙事联动 → **deferred 待用户裁决** | 用户未要求改 task-planner 技能本体；Rule 36 保守化（语义扩展需单独确认）；且 v117 教训=技能口径改动易撞 RT-08/CD-12/PT-08 旧守卫。本任务触发面靠 description+router 已闭环 |
| D5 template_type: general | 29 个 variant 无 agent-creation 类；首例不触发 34.3① 同类第 2 次条件，终验按 34.3② 复评沉淀必要性 |
| D6 行为级冒烟测试 → 新会话建议（交付后） | agent 类型列表会话启动固化；本会话只能结构验证。诚实登记不声称"已验证可派发" |
| D7 沉淀触发预评（Rule 34.3②） | agent 创建类首例，若终验判定可泛化（第二步同类任务出现再沉淀），本轮不建 variant |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | | | |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 并行约束：全程不触碰 wt/task-v118、plans/task-v118/**、task-v116 残留信号文件

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-03 04:2x（P1 后） | ALIGNED（Skill("task-drift-guard") 调用：scope 内 1 文件+48 行提交，无计划外写入） | VC-1/2/3 | 继续 |
| 2026-10-03 04:3x-04:5x（P2/P3 后内联同口径检查：progress/grep/git 证据对照 scope 表） | ALIGNED（P2 零仓内写变更；P3 仅 :98 授权行） | VC-4/VC-6 | 继续 |
| 2026-10-03 04:5x（P4/交付点） | ALIGNED（部署位 2+路由行均在批准 scope；merge a4bbd19 仅含 Phase 1 单文件） | VC-5/VC-7 | 交付 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4（机器口径 check-delegation stats：delegated=2, violations=0, verdict=ok） |
| 主进程直做 Phase 清单 | Phase 2（白名单③ 机械验证命令——provider 2 连拒后 Rule 22.7 换道接管）；Phase 4（白名单①② git/worktree 编排+簿记） |
| 委派率 | 0.5（< 0.7 但直做理由全命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 0 | 2026-10-03 | Explore(mini) | companion agents/模型行格式/守卫面/路由联动面调研 | done | 3 个 companion agent；model 行 9 种格式主流 custom: 式；selftest 仅锚 plan-writer 零破坏；router L97 需登记 | Q1-Q5 各证据行 | §Research Findings | -（只读调研无检查点） | - / 0 / ☑ |
| 1 | 2026-10-03 | executor | 撰写 complex-planner.md + 自验（sonnet-1 档） | done | 48 行与 §6.1 逐字一致；三组 grep 自验过；主进程 Read 一手复核（R8） | worktree 文件 :2-6/:13-48 | §Research Findings R8 | plans/task-v119/subagent-state/1-executor.md | - / 0 / ☑ |
| 2 | 2026-10-03 | code-runner-agent | worktree 内全量 selftest 回归（mini 档） | done(接管) | 派发 2 连 Provider rejected → 主进程接管（白名单③）；TOTAL=42 FAIL=0 + smoke 17/0 | subagent-state/2-code-runner-agent.md | progress.md Phase 2 | plans/task-v119/subagent-state/2-code-runner-agent.md | rescue=主进程接管档④(白名单③) / retry=2 / ☑ |
| 3 | 2026-10-03 | code-assistant | skill-agent-router 表追加行（haiku-1 档） | done | :98 单行插入，3 列对齐，表行 55→56；主进程 Read 复核 | ~/.zcode/skills/skill-agent-router/SKILL.md:98 | progress.md Phase 3 | plans/task-v119/subagent-state/3-code-assistant.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺（agent 创建类，29 variant 无对应）→ 落 general 兜底
- Rule 34.3②: 沉淀预登记 —— 首例，暂不沉淀（D7）；若后续出现第 2 例同类任务再按 34.4 提炼
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由 = 首例无复用压力（D7 已登记）→ 指向 plan-template-kit 卫星 SOP
