<!-- template_type: rule-enhancement -->
# Task Plan: task-v088 task-planner 接入 /workflow（dynamic-workflows 编排）路由与映射合约（Rule 39）

## Goal
在 task-planner 技能内落地 **Rule 39 动态工作流编排**：当用户显式调用 `/workflow` 或明确措辞要求 workflow 编排时，路由到 CreateWorkflow 编排（替代纯串行 Agent 派发），并把失败兜底（22.3）/断点续做（22.8）/人工升级（D5-D6）/模板沉淀（34.3）映射到 workflow 原生机制（AmendWorkflow cache / ResumeWorkflowRun / ResolveWorkflowQuestion / SaveWorkflow）；未点名时保持既有串行派发零改动。纯规则+守卫+文档同步，零新 config 键。

- 预估时长：中（~60min）
- 隔离：worktree（已创建）

<!-- plan_tier: standard -->

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（rule-enhancement 任务：规则文档 + bash selftest 守卫，无运行时逻辑变更；行为面条款由 selftest 静态守护） |
| `interaction_mode` | `ask`（默认；D1 计划批准、D2 并行豁免确认） |

## ✅ Verification Contract（全部通过 = 完成）

| VC | 判据 | 证据 | 映射 Phase |
|----|------|------|-----------|
| V-1 | critical-rules.md 新增 `### 39 动态工作流编排`，含 39.1/39.3/39.4/39.5/39.6 锚点（grep 可查） | grep 输出 | P2 |
| V-2 | SKILL.md 净增 ≤8 行、总行数 ≤563：Rule 39 摘要行 + C27 + 协同路由 dynamic-workflows 行 + L288/L340「Rules 1-39」索引 | wc -l + grep | P3 |
| V-3 | 「Rules 1-38→1-39」索引级联全同步（SKILL ×2 + CLAUDE.md + README_zh.md ×2 + skills/task-planner/README.md），grep -c "Rules 1-38" 残留 =0（selftest 历史注释除外，逐一核对） | grep 输出 | P3 |
| V-4 | 4 个既有 selftest 行数上限锚 555→563（batch-pilot BP-08 / execution-stability T8b / knowledge-brief T2b / skill-collab T10） | grep 563 命中 4 脚本 | P3 |
| V-5 | 新建 selftest-workflow-orchestration.sh（≥10 断言）全 PASS；全量 selftest（27 脚本）FAIL=0 | 运行输出 | P4/P5 |
| V-6 | config.json 键数恒 40（零新键），jq 校验 | jq 输出 | P5 |
| V-7 | worktree 合并 master + 清理 + 三位部署（~/.zcode/~/skill-deploy 惯例三实体位）IDENTICAL + push 远端 HEAD=本地 | git log + diff -r | P5 |
| V-8 | CHANGELOG.md 新增 v088 条目（含 Rule 39 六子条摘要） | Read CHANGELOG 头部 | P4 |

## ⚠️ 执行范围限制（强制 — 只操作列表内文件）

| 类别 | 允许的文件（均在 worktree /mnt/data/dev/task-planner-skill-worktrees/task-v088-workflow-orchestration 内，相对仓根） | 禁止 |
|------|------|------|
| 规则 | skills/task-planner/references/critical-rules.md（仅尾部追加 Rule 39） | 改 1-38 既有条款语义 |
| 技能主文档 | skills/task-planner/SKILL.md（净增 ≤8 行：摘要行+C27+路由行+索引 2 处换字） | 其他章节 |
| 索引文档 | CLAUDE.md、README_zh.md（各 1-2 行换字）、skills/task-planner/README.md（1 行换字） | 其他内容 |
| 守卫 | skills/task-planner/scripts/selftest-workflow-orchestration.sh（新建）；4 个既有 selftest 仅行数锚 555→563（batch-pilot/execution-stability/knowledge-brief/skill-collab 各 1-2 行） | 其他断言 |
| 变更簿 | CHANGELOG.md（头部新增条目） | 既有条目 |
| 计划系统 | plans/task-v088-workflow-orchestration/*（本计划目录） | 其他计划 |

**config.json 不新增键**（39.6 零键范式，与 v087 一致）。

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读 | 已确认 |
|------|-----------|------|------|--------|
| 官方技能文档 | dynamic-workflows SKILL.md（1521 行，工具契约+facade+终态语义） | /opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/SKILL.md | 必读 | ✅ Phase 1 子代理已通读并提炼（findings.md 有行号锚点） |
| 项目规范 | critical-rules.md Rule 38 尾部格式（子条撰写范式/边界明示段） | worktree skills/task-planner/references/critical-rules.md L327-341 | 必读 | ✅ 已读 |
| 项目规范 | selftest 脚本范式（t() helper + 静态断言 + 行数锚） | scripts/selftest-plan-tier.sh / selftest-reflect-verify.sh | 必读 | ✅ 已读范式 |
| 记忆 | 部署/守卫经验（三位部署=主仓副本跑 smart-merge-back --deploy；worktree 内技能编辑守卫 warn 假阳性；SKILL 净增 N 行必同步 4 selftest 行数断言） | memory task-v087/v086/v077/v078 条目 | 参考 | ✅ MEMORY.md 在上下文 |

## ⚠️ 核心问题定义

**核心问题**：task-planner 执行模型只有「串行 Agent() 逐 S-unit 派发」一条路——对多步、有类型化中间结果、需按停止条件循环的编排型任务，串行慢、无 cache 复用（失败重跑全量重付）、人工干预无原生通道；而 harness 已内置 dynamic-workflows 能力（Amend cache 导入/Resume 断点/dwfq 升级/SaveWorkflow 沉淀），技能层却零路由零映射，用户点名 /workflow 时无规范可执行、无验收契约可勾。

- [x] 核心问题解决后可交付（Rule 39 路由+映射落地，/workflow 触发有章可循）
- [x] 不解决则 /workflow 编排任务无规范，失败兜底/断点/升级全部裸奔
- [x] 方法清晰：纯增量规则 + 静态 selftest + 索引级联 + 部署，不动 1-38 语义

## Current Phase
Phase 4（complete）

## Next Step
Phase 5 主进程：全量 27 selftest（FAIL=0）→ git add scope + commit → smart-merge-back 三位部署 → worktree 清理 → push

## Phases

### Phase 1: 调研（dynamic-workflows 工具契约提炼）

- **Status:** complete
- **Executor:** 主进程（例外理由：④ 用户显式要求调研统筹 + ③ 机械验证——调研结论已落盘 findings.md）
- **动作**：Explore 子代理通读 dynamic-workflows SKILL.md（1521 行），提炼 7 项事实（工具契约/facade/终态语义/并发/沉淀/门控/冲突面）
- **证据**：findings.md「Research Findings」段（含官方文档行号锚点）；子代理产出已 Read 复核
- V-1..V-8 映射：P1 提供 V-2/V-3 撰写输入（锚点清单）

### Phase 2: Rule 39 条款撰写与追加

- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **动作**：按 findings.md 已定稿的 Rule 39 全文草稿，在 critical-rules.md 尾部（Rule 38 边界段之后）追加 `### 39 动态工作流编排` 及 39.1-39.6 六子条（草稿在 findings.md「Rule 39 定稿草稿」段，子代理逐字落盘，禁自行改写语义）
- **验收**：V-1（grep 六锚点 343/347/348/349/359/360/361 全命中）；实际 +20 行（草稿 19 行逐字+前导空行，341→361）；1-38 既有内容零改动（git diff 零删除行，hunk @@ -339,3 +339,23 @@ 仅尾部）——亲验 diff 逐字节 IDENTICAL

| ID | 执行体 | 输入（材料包） | 输出 |
|----|--------|----------------|------|
| S1 | 继承 | ① <plan-dir>/findings.md §Rule 39 定稿草稿（全文复制段）② critical-rules.md 尾部 Rule 38 边界段（插入锚点=文件末尾追加） ③ 范式参照=Rule 38 子条写法 | critical-rules.md 尾部追加 ~35 行；禁触碰 1-38 |

### Phase 3: SKILL/索引/selftest 联动同步

- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **动作**：5 组联动（逐 S-unit 严格串行）——① SKILL.md：Rule 39 摘要行（Critical Rules 段 Rule 38 行后）+ C27 合规清单项 + 🤝 协同路由矩阵 dynamic-workflows 行 + L288/L340「Rules 1-38」→「Rules 1-39」；② CLAUDE.md/README_zh.md/skills/task-planner/README.md 索引换字；③ 4 个既有 selftest 行数锚 555→563（含注释行）
- **验收**：V-2（SKILL 净增 ≤8 行/总 ≤563）、V-3（"Rules 1-38" 残留 =0，历史注释里的 555 字样不属于 1-38 不受影响——先 grep 全仓核对清单再动手）、V-4（4 处 ≤563）

| ID | 执行体 | 输入 | 输出 |
|----|--------|------|------|
| S1 | 继承 | findings.md §SKILL 联动定稿文案（5 处原文） | SKILL.md 净增 ≤8 行 |
| S2 | 继承 | findings.md §索引换字 2 文件 3 行 | "Rules 1-39" ×3 |
| S3 | 继承 | 同上 + grep 定位行 | 索引 1 行 + 行数锚 2 行（含注释） |
| S4 | 继承 | 同上 | 行数锚各 1-2 行 |
| S5 | 继承 | 同上 | 行数锚 1-2 行 |

### Phase 4: 新建守卫 selftest + CHANGELOG

- **Status:** complete
- **Executor:** code-assistant（haiku-1）
- **动作**：① 新建 scripts/selftest-workflow-orchestration.sh（WF-01..12 十二断言，范式=自检测 t() helper，路径锚定相对 SKILL_ROOT，参照 selftest-plan-tier.sh 结构）；② CHANGELOG.md 头部新增 v088 条目（Rule 39 六子条摘要+守卫+部署+零新键）
- **验收**：V-5 新 selftest 单跑 PASS、V-8 CHANGELOG 条目在位；bash -n 语法过

| ID | 执行体 | 输入 | 输出 |
|----|--------|------|------|
| S1 | 继承 | findings.md §WF 断言清单（12 条原文） | 新脚本 ~70 行，全 PASS |
| S2 | 继承 | findings.md §CHANGELOG 条目草稿 | 头部追加 1 条目 |

### Phase 5: 全量验证 + 合并部署 + push

- **Status:** pending
- **Executor:** 主进程（例外理由：③ 机械验证命令 + ①② git/worktree 编排与簿记——Rule 25.3 白名单）
- **动作**：全量 27 selftest 运行（FAIL=0）→ jq config 键数=40 复核 → bash -n 全脚本 → git add scope + commit（Rule 27）→ 主仓副本 smart-merge-back.sh --deploy（三位部署 IDENTICAL 亲验 diff -r）→ worktree remove + branch -d → push
- **验收**：V-5/V-6/V-7；合并后 master 全量 selftest 复跑 FAIL=0（worktree 基线与 master 可能被并行推进——部署前重跑兜底，v079 教训）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `isolation` | `worktree`（技能文件修改=§六保护区+§十一 11.1① 强制） |
| worktree 路径 | /mnt/data/dev/task-planner-skill-worktrees/task-v088-workflow-orchestration（集中目录规范 11.2，分支 wt/task-v088-workflow-orchestration） |
| 冲突信号 | ①无未提交变更（git status clean @51ca883）②无额外 worktree③无遗留 wt 分支④无待处理在册⑤运行中基础设施改动=是（task-planner 技能本体→必须 worktree） |
| 处置 | 实现全部在 worktree；计划文档留主仓 plans/；合并回走 smart-merge-back + 三位部署 |

> 注：本仓 .zcode/hooks 的 check-skill-modify/delegation 守卫在 worktree 内对技能文件编辑可能 warn 假阳性（v078/v079 教训），本计划已把全部目标文件列入上表「执行范围限制」= 授权依据；subagent 侧守卫 exit 0 不阻断（v078 实证）。

## 📊 FMEA 预演（规划期）

| 风险 | P | I | RPN | 预设兜底（39.x/22.3 对应） |
|------|---|---|-----|---------------------------|
| R1 行数锚漏扩（4 selftest 某处 555 残留→全量假 FAIL） | 2 | 4 | 8 | P3 执行前 grep -rn "555" scripts/selftest-*.sh 全量清单先行，逐处改；P5 全量兜底 |
| R2 "Rules 1-38" 索引漏同步（v085 教训：多锚位漏扩 3 处） | 3 | 3 | 9 | P3 验收 grep -c "Rules 1-38" 必须 =0；全仓 grep 清单先行（SKILL L288/L340、CLAUDE L32、README_zh L136/L229、skills/task-planner/README L67 共 6 处） |
| R3 部署源错位（v077 教训：SKILL_ROOT 脚本运行处=worktree 副本→对账假 IDENTICAL） | 2 | 5 | 10 | P5 用主仓副本 /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/smart-merge-back.sh 执行 --deploy，部署后 diff -r 三实体位亲验 |
| R4 并行会话推进 master（v079 教训：worktree 基线落后→合并冲突） | 2 | 4 | 8 | P5 合并前 git log 检查 master 是否被推进；冲突按 FMEA 兜底 merge master 解冲突重跑全量再合 |
| R5 Rule 39 映射与官方语义漂移（凭记忆写 dwfq/Amend 语义） | 2 | 4 | 8 | 映射表全部锚定 findings.md 已提炼行号；子代理只逐字落盘不改写；P5 selftest 锚断言兜底 |
| R6 子代理 provider 失败 | 2 | 3 | 6 | 22.3 拆细（S-unit 已 ≤2 文件）→ 主进程 22.3④ 接管（白名单⑤登记） |

## Key Questions
1. ~~workflow 内子代理是否受 check-dispatch hook 约束~~ → 官方文档未提及；处置=不在 Rule 39 声称机器守卫覆盖 workflow 内部，39.6 明示「机器校验归 harness 侧（ListWorkflowRuns/GetWorkflowRun）」，不虚构能力（Rule 35.2）
2. 21.4 串行铁律 vs workflow 并行 → 39.4 解法=显式调用期豁免+登记，用户要求串行时 max_concurrency=1
3. 是否加 config 键 → 否（v087 零键范式：判定=LLM 行为面，官方约束本身即机器守卫）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Rule 39 = 纯追加尾部子条（38→39），零新 config 键 | 与 v085-v087 追加范式一致；判定面是 LLM 行为（显式点名才触发），机器面=dynamic-workflows 官方自身约束（skill 加载前置/确认窗/typecheck），无需再造开关键 |
| 触发纪律=显式点名才路由（复刻官方「explicit request is binding」） | 官方红线：workflow 不得由 agent 自主判断启动；task-planner 侧对齐=未点名一律走既有 21.4 串行派发，Rule 39 零影响面 |
| 21.4 豁免走 39.4 登记（显式调用期+D2 确认）而非改 21.4 原文 | 36.5 纯增量铁律：不写「串行=仅默认」改写 21.4 语义；豁免是运行期登记制，Rule 21.4 文本零改动 |
| 沉淀出口=SaveWorkflow（project .zcode/workflows / global ~/.zcode/workflows）挂 34.3 触发 | 官方载体即既有沉淀通道的延伸；同名覆盖走 36.4 用户确认 |
| 守卫=新建 selftest-workflow-orchestration.sh 静态断言 | 本仓所有 Rule 守护范式=静态 selftest；行为面无法 bash 断言，锚+索引+行数即可守护 |
| 部署+push 纳入 P5（三实体位+远端） | 用户宪法 §二 部署拓扑记忆：仓库改动不自动生效；v086 P4 先例=实体位部署后 push 用户授权模式（本会话用户指令=优化技能→交付含部署，push 为既定交付节） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （暂无） | 1 | | → progress.md Error Log |

## Notes
- 全仓 `Rules 1-38` 命中位点（P3 前置 grep 清单）：SKILL.md L288/L340、CLAUDE.md L32、README_zh.md L136/L229、skills/task-planner/README.md L67——共 6 处
- 行数锚 555 位点：selftest-batch-pilot.sh L11 注释+L55 断言、selftest-execution-stability.sh L70 注释+L72 断言、selftest-knowledge-brief.sh L38、selftest-skill-collab.sh L80 注释+L81 断言
- 官方文档行号锚（findings 详列）：facade §16.2 L968-1346 / 终态 L761-776 / 升级 L861-906 / 路由红线 L46-55 / SaveWorkflow L1453-1498
- 模板形态注意：本计划 template_type=rule-enhancement 为注释形态 `<!-- template_type: X -->`（check-template-type.sh 第三形态 S7-1 兼容）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 项 | 值 |
|----|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3/5（P2/P3/P4 子代理；P1 主进程=调研统筹 ④；P5 主进程=①②③ 白名单） |
| 委派率 | 0.6 → **WHITELIST-EXEMPT**（主进程直做 P1/P5 理由全部命中 25.3 白名单①②③④，按 25.4 豁免条款不降级） |
| 主进程直做清单 | P1（调研统筹+子代理产出复核，白名单④③）；P5（机械验证+git 编排+部署簿记，白名单①②③） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| 时间 | subagent_type | 目标 | 状态 | findings 落点 | checkpoint 路径 | verify_done |
|------|---------------|------|------|---------------|-----------------|-------------|
| 02:38 | Explore | dynamic-workflows 工具契约 7 项提炼 | complete | findings §Research Findings | <plan-dir>/subagent-state/01-explore.md | ☑ |
| （P2 派发时填） | code-assistant | S2-1 | pending | | subagent-state/02-code-assistant.md | ☐ |

## 🔗 Chain 区块交接配置
chain_mode: single
