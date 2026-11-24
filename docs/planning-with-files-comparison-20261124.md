# 系统性对比文档：task-planner vs Planning with Files

> **文档版本**：v1.0 · **日期**：2026-11-24 · **对比对象**：本仓 `task-planner-skill`（master）vs `OthmanAdi/planning-with-files`（live v3.29.1）
> **证据纪律**：本文所有结论均附一手证据（本地路径 + 行号 / 命令输出 / 仓库源文件路径）。凡证据缺失处显式标注"未取到 / 未实测"，禁脑补、禁把推测包装为事实。
> **基线声明**：原版以 **live 3.29.1** 为准（`SKILL.md:31` / `plugin.json.version` / `CHANGELOG.md [3.29.1]` 三处一致）。zread 等缓存通道返回的是 v3.9.0 时代旧内容（"18+ platforms / 217 tests / metadata.version 3.9.0"），**已剔除**，不作为当前事实。

---

## 1. 执行摘要（结论先行）

**一句话定位**：两者共享同一条血脉——"磁盘文件 = Agent 工作记忆"（Manus Context Engineering）——但 **Planning with Files 把这条血脉做成了一个广泛兼容、机制精巧、诚实透明的"规划流程编码"**；**task-planner 则把它做成了一个重型、强门控、深度绑定 ZCode/Claude Code 工具链的"任务执行治理系统"**。

**最关键的 5 条差异**：

| # | 维度 | Planning with Files（原版） | task-planner（本仓） | 谁更强 |
|---|---|---|---|---|
| 1 | 核心定位 | 编码偏好（encoded preference）：让 agent 遵循 3 文件流程 | 方法论工程：用流程/门控/子代理替代高档模型依赖 | 不同赛道 |
| 2 | 状态权威源 | Markdown 文本 + grep 计数（无 schema） | `plan-state.json` 权威 + 4 个 MD 派生视图（planctl.py） | **task-planner** |
| 3 | 完成判定 | shell 读 phase 状态 + ledger 进展；无独立验证者 | VC/V-N 可执行命令 + 独立复检子代理 + 多层机器门 | **task-planner** |
| 4 | 生态/安装 | 60+ agent、19+ platform、5 语言变体、多宿主原生插件 | 4 工具软壳部署（claude/zcode/opencode/cursor）+ PowerShell 镜像 | **原版** |
| 5 | 评测/量化 | 有公开 eval/benchmark（恢复 5.0 vs 13.3 轮），但旗舰数字停在 v2.21/v3.4 | 108 个 selftest 静态守护 + 106/106 实测全绿，无行为级 benchmark | 各有短板 |

**选型一句话**：
- 要**跨平台、轻量接入、可进可退、生态兼容** → 原版 Planning with Files。
- 要**强验证、防漂移、防造假、多子代理并行治理、长任务可审计** → task-planner。
- 若两者都用：**原版解决"计划不丢"，task-planner 解决"完成可证伪"**——后者正是 README 声称的演进方向，本报告在 §5-§9 逐条验证这一声称是否成立。

---

## 2. 对比对象识别与定位过程（避免在错误的"Plan with file"上做对比）

用户口语中的 "Plan with file（将计划写入文件的技能）" 存在多个候选，定位过程如下（全部为本次真实抓取，非脑补）：

1. **候选 A：`catlog22/Claude-Code-Workflow` 的 `*-with-file` 技能族**（`roadmap-with-file` / `brainstorm-with-file` / `analyze-with-file` / `debug-with-file`）——经 `mcp__zread__get_repo_structure` 与 `WebFetch` 抓取 `.codex/skills/` 目录确认存在，但**没有独立的 `plan-with-file` 目录**（目录枚举结果：`analyze-with-file / brainstorm-with-file / debug-with-file / parallel-dev-cycle / roadmap-with-file / team-planex / workflow-lite-planex / workflow-plan / workflow-tdd-plan`）。排除。
2. **候选 B：`OthmanAdi/planning-with-files`**——`gh search repos "plan with files"` 首位命中，28,209 stars（2026-11-24 实测）。**关键证据**：本仓 `README_zh.md:36-38` 明确写"本 Skill 是 ['Plan with Files'](https://github.com/plan-with-files) 模式的直接演进版本"，并在 40-48 行给出 7 行对比表。README 里的 `github.com/plan-with-files` 是简写/旧链，实际权威仓为 `OthmanAdi/planning-with-files`（`homepage = https://planningwithfiles.tech/`）。**确认为目标。**

> 附：`gh search repos` 还返回多个 fork/移植版（如 `Asaka-RUM/dsh-planning-with-files` 移植到 DeepSeek Harness、`gaoliao1688/planning-with-files-zh` 中文版），均非本文对比对象。

**取证陷阱记录**：`mcp__zread__read_file` 对原版 README/SKILL.md 返回 v3.9 时代缓存（README "18+ platforms"、SKILL.md `metadata.version 3.9.0`）；经 `gh api repos/.../contents/<path> | base64 -d` 直取 live 文件后确认真实版本 3.29.1，README 1015 行/116,129 字节、SKILL.md 534 行/41,938 字节。本文所有原版数据以 live 抓取为准。

---

## 3. 双方基本信息对照

| 项目 | Planning with Files（原版） | task-planner（本仓） |
|---|---|---|
| 仓库 | `OthmanAdi/planning-with-files` | 本仓 `task-planner-skill`（canonical source） |
| 作者 | Ahmad Othman Adi（MIT, Copyright (c) 2026） | 仓库贡献者（MIT） |
| 当前版本 | **3.29.1**（2026-11-23） | CHANGELOG 顶部为 `[Unreleased]`（无发布版本号） |
| Stars / Forks | 28,209 / 2,330（`gh api` 2026-11-24） | 未取到（本仓为本地源码仓，未查 GitHub 元数据） |
| 创建 / 最近推送 | 2026-01-03 / 2026-11-23 | 未取到 |
| 许可证 | MIT | MIT（`README_zh.md:275-277`） |
| 核心哲学 | Manus Context Engineering："Markdown is my working memory on disk" | 同血脉 + "方法论换模型档位"（用户 2026-11-15 定位锚，`README_zh.md:9-22`） |
| 主文档 | README 1015 行（英文） | `README_zh.md` 283 行（中文主）+ Skill 包内英文文档 |
| Skill 入口 | SKILL.md 534 行 / 41.9KB | SKILL.md 289 行 / 60.65KB（更短行、更高密度） |
| 规模 | 108 个测试文件；4 CI job；5 语言变体 skill；7 类宿主 hook | 21 Skill 包；170 脚本；108 selftest；31 模板变体；9 伴生 agent；111 规则编号 |
| 仓库体积 | 未取到（未测） | 506MB / 23,165 文件（不含 .git） |

---

## 4. 设计哲学对比

### 4.1 共享的底座：RAM/Disk 公式

两者都把 `Context Window = RAM (volatile)`、`Filesystem = Disk (persistent)` 作为第一性原理：
- 原版：live `SKILL.md:105-112` 与 `reference.md` Principle 3 明文给出该公式。
- 本仓：`SKILL.md:148` "Context Window = RAM（易失），Filesystem = Disk（持久）"；`README_zh.md:28-34` 列出"计划跨 `/clear` 保存"等收益。

### 4.2 分歧点：编码偏好 vs 治理系统

| 维度 | 原版 | 本仓 |
|---|---|---|
| 自我定位 | `docs/evals.md`：**"encoded preference skill (not capability uplift)"**——Claude 不用技能也能规划，技能只是编码了一套 3 文件流程；benchmark 测的是"workflow fidelity"而非任务质量 | `README_zh.md:11-16`：明确以"不依赖高档模型，用方法论工程保证质量"为定位，目标直指质量稳定性 |
| 成功判据 | "文件模式是否被遵循" | "VC 是否客观通过 + 产物是否被独立 Read 验证 + 无漂移" |
| 对模型的假设 | 模型需要"被提醒"才能保持计划浮现（每轮注入） | 模型会漂移/造假/遗忘，需要"外力约束"（Hook + 门 + 子代理复核） |

**分析**：原版是**认知外挂**——它承认模型本身会规划，只是需要外部记忆与注意力管理。本仓是**行为约束系统**——它假设模型不可信，需要机器门把"完成"变成可证伪命题。这不是成熟度差异，而是设计目标差异：原版追求"广适配、低侵入"，本仓追求"高保证、可审计"。

### 4.3 方法论来源

- 原版：Manus 六原则（`reference.md`）——KV-cache 优化（引用 ~100:1 输入输出 token 比、cached $0.30/MTok vs uncached $3/MTok）、mask 而非 remove 工具、压缩可恢复、recitation 操纵注意力（"~50 tool calls 后模型忘记原始目标"）、保留错误、避免 few-shot 僵化。
- 本仓：除 Manus 原则（`skills/task-planner/reference.md`）外，叠加了大量自研方法论——思维方法论 T1-T5、`references/methodology.md` 的 FMEA/Poka-Yoke、双轮质检（Rule 103）、收尾回读（Rule 84.14）、无源不写（Rule 71）、变更类型三判（Rule 74）等 111 条规则编号。

---

## 5. 架构对比（逐维度）

### 5.1 文件模型

**原版——三文件 + sidecar 点文件**：
- `task_plan.md`：Goal / Next Step / Current Phase / `### Phase N: Name` + `**Status:** pending|in_progress|complete` / Key Questions / Decisions Made / Errors / Notes。每章节带 WHAT/WHY/WHEN 的 HTML 注释。
- `findings.md`：Requirements / Research Findings / Technical Decisions / Issues / Resources / Visual Findings；"2-Action Rule：每 2 次 view/browser/search 必须更新"。
- `progress.md`：Session 日期 / 各阶段 Status+Started / Actions / Files / Test Results 表 / Error Log（时间戳）/ 5-Question Reboot Check。
- sidecar：`.mode`（autonomous/gate/inject-smart/plan-guard-off tokens）、`.nonce`（16-hex 注入分隔符）、`.attestation`/`.plan-attestation`（SHA-256）、`.stop_blocks`、`.gate_last_ledger`、`ledger-<agent>.jsonl`、`.planning/sessions/<id>.attached`。
- 两模式：传统 root 模式（项目根 3 文件 + 点文件）与并行 slug 模式（`.planning/YYYY-MM-DD-<slug>/` + `.active_plan` 指针）。
- **默认 gitignore 且不归档**：`docs/workflow.md` "nothing archives them when a task finishes"。

**本仓——四文件罗盘 + 记录文档域 + JSON 权威源**：
- 四文件罗盘（`SKILL.md:31-36`）：`task_plan.md`（目标维：状态与指针，仅控制面板）、`findings.md`（决策维）、`progress.md`（进度维）、`knowledge-brief.md`（知识维）——是主代理↔子代理数据流转的**唯一协议介质**（Rule 62.1）。
- 记录文档域：`verification.md`（终验维：VC + V-N 可执行命令）、`user-session-log.md`（用户原话维，append-only 只写不改，Rule 80）、`notepad-learnings.md`。
- **关键差异**：`task_plan.md` 等 4 个 MD 是 `plan-state.json` 经 `planctl.py render` 的**派生视图，禁手工 Edit**（`SKILL.md:93,108`）；权威状态在 JSON（原子写 + 20 版备份 + tags 倒排 + check）。原版无结构化状态源，全部是 markdown 文本。
- 模板：`task_plan.md` 模板 590+ 行、30+ 区块（用户需求原文逐条抄录 / R→VC 映射 / 不变量声明 / 规范基线 / 进度产出基线 / VC 表 / Goal 单元表 / 执行范围限制 / 变更标注表 / FMEA 预演 / 委派统计 / Handoff 登记 / 隔离决策 / Drift Log 等）。

**小结**：原版文件模型**轻、通用、人可读**；本仓文件模型**重、结构化、机器可校验**。本仓用 JSON 权威源解决了"Markdown 手工编辑漂移"这一原版固有风险，但代价是 590 行模板与 170 个脚本的认知负担。

### 5.2 状态机与门控

| 子项 | 原版 | 本仓 |
|---|---|---|
| 状态原语 | `pending → in_progress → complete` + checkbox；`check-complete.sh` 取两种格式最大值 | 同三值，但翻转需过机器门，非叙述性勾选（`README_zh.md:31`） |
| 完成判据 | `TOTAL == grep -c "### Phase"`；complete 数 ≥ total（+ gate 5 条件） | VC 逐条可执行命令全 PASS + V-N 每 Phase ≥2 + 3-File Gate + 同步核对 + Git 差异 unresolved=0 + 对齐锚（`SKILL.md:117-118,126-144`） |
| 独立验证者 | **无**——完成判定由同一 agent 写的 plan 文件驱动，无第二模型复核 | **有**——双轮质检（Rule 103）：自审→Read 产出→派全新复检体全文回读→回执落盘；子代理"完成"须主代理 Read 实际文件才接受（`SKILL.md:115`） |
| 防篡改 | SHA-256 attestation（项目自述：普通本地哈希、非签名、能改 plan 者也能改 attestation） | `attest-plan.sh` 模板门/派发门/FMEA 门三档锁定 + 证据锚真实性门（路径归属/行界/provenance）+ 对齐锚门（`config.json:131-180`） |
| 失控护栏 | `.stop_blocks` cap 20 + stall 检测（ledger 行数）+ `stop_hook_active` | 3-strike 升级 + `escalation_threshold=3` + 委派率下限 0.7 + 防倒退终检（Rule 111） |
| 结论三态 | 无（完成/进行中二态，advisory Stop） | `COMPLETE / PARTIAL / BLOCKED`（`SKILL.md:29,141`） |

**这是两者差距最大的维度**。原版的"完成门"本质是 `grep "**Status:** complete"` 的确定性脚本——一个 agent 把所有状态改成 `complete` 即可放行（`SKILL.md:101` 自述 "This checks format, not task completion or attestation"）。本仓把"完成"变成了**可证伪命题**：VC 必须带可执行验证命令（`README_zh.md:197-204`）、证据必须指向真实产出路径且行号有效（`check-evidence-anchor.sh`）、VC 命令必须真实引用产出物（`check-vc-nonvacuous.sh`）、R→VC 双向覆盖（`check-rvc-coverage.sh`）。

**但本仓也有诚实边界**：`config.json` 中 `vc_gate_enforce`、`fmea_enforce`、`content_quality_enforce` 等仍默认 `warn`（观察期），即部分门"只告警不阻断"；且 `verify.sh` 实测 27 pass / 4 fail（部署位脚本硬编码路径），说明门控自身也有部署同步问题。

### 5.3 上下文工程与恢复

| 子项 | 原版 | 本仓 |
|---|---|---|
| 每轮注入 | `head -50 plan + tail -20 progress`（时间戳归一化为 `T00:00:00Z` 稳定 KV-cache 前缀），带 `===BEGIN/END PLAN DATA===` + nonce；v3.8 smart 注入；v3.24 未变更视图抑制 | UserPromptSubmit smart 注入，有类型门（短闲聊跳过）与限频（mtime 未变时每 20 轮兜底刷新）；配置明确记录"每轮无条件注入 0.22-0.26s + 1-1.5KB 复利开销实测"（`config.json:523-534`） |
| 注入开销 | ~330 tokens/turn + ~90 tokens/matched tool call（`docs/evals.md` Test 5 Result 4） | 1-1.5KB/轮（约 400-600 tokens 量级，未实测 token 数）；smart 限频后降低 |
| `/clear` 恢复 | **主动收窄**：自动恢复只读项目文件，不读宿主 session store；`session-catchup.py --metadata/--replay` 须用户显式要求 | `session-catchup.ts`（bun/node）自动检测残留计划；2026-11-24 新增 **compact-recovery**：压缩后 SessionStart hook 无条件注入技能正文全文（`planctl.py recover-skill`），有在途计划时附加 `plan-state.json` 权威状态（`SKILL.md:54`） |
| 上下文压缩 | PreCompact hook 只打印提醒"ensure progress.md captures recent actions"，**不写文件、不阻塞，不保证未保存进度落盘**（`SKILL.md:315-319`） | 压缩恢复直接注入完整技能体系 + 权威状态，针对"压缩冲掉整个技能体系"这一痛点（`SKILL.md:54`） |
| 2-Action Rule | 每 2 次 view/browser/search 写 findings | 同规则（`SKILL.md:109`），并叠加 2 次 view→findings、key action→progress、错误立即写 Error Log 四步闭环 |

**分析**：原版在"恢复"上有公开量化优势（上下文硬中止后 5.0 轮恢复 vs native 13.3 轮），但项目自己披露前提——"文件已写好"；其自动恢复已收窄为只读项目文件。本仓的 compact-recovery 是 2026-11-24 新增，未见量化 eval，但机制上更激进（无条件注入全文技能，避免压缩后技能体系丢失）。

### 5.4 并行与多任务

| 子项 | 原版 | 本仓 |
|---|---|---|
| 并行单元 | `.planning/YYYY-MM-DD-<slug>/` + `PLAN_ID` 严格绑定（解析失败 fail-closed）+ `PWF_PLAN_ROOT` 绝对 pin + 会话 attachment | `plans/task-XXX/` + 会话私有 side 指针（`resolve-plan-dir.sh [root] [sid]`）+ `plans/INDEX.md` 协调者 + `set-active-plan.sh gc` |
| owner/worker 协议 | README：一个 owner 写 plan + 共享摘要，worker 各自写 ledger/指定文件；per-agent `ledger-<agent>.jsonl` | 四文件罗盘作为主↔子唯一协议介质；`subagent_dispatch.md` 模板 + 九字段派发契约 + Handoff 登记表 |
| 并发写安全 | **无锁/无 merge/CAS**：parallel-write guard（v3.10）只在事后检测 checked items 减少打 advisory line，明确 "not a lock or merge mechanism"，不覆盖 progress/findings，按 plan path 而非 session 键控（`SKILL.md:419-427`） | **工作树隔离**：实现类默认 worktree（`references/worktree-isolation.md`），`check-conflicts.sh` 冲突分析 + `smart-merge-back.sh` 合并合约 + 并行冲突延后到合并阶段处理（`AGENTS.md` §11） |
| 子代理调度器 | **无**——文件级协调协议，不是内建 subagent 调度器 | **有**——`task-dispatch` 卫星技能 + `companion/agents/` 9 个专业 agent + 依赖分组/组内异构分摊（Rule 68）+ 失败改派（`provider_fallback`）+ 委派率门控 |
| 子代理上下文隔离 | 默认**泄漏**给 subagent，需 `PWF_SKIP_SUBAGENTS=1` opt-in（CHANGELOG v3.26 / issue #348） | 派发契约强制含三文件绝对路径 + 返回字段 + checkpoint（`check-dispatch.sh` enforce）；失败会话级留痕 |

**分析**：原版的并行是"文件级协议 + 建议用 worktree"，本仓把并行做成了"内建调度 + 工作树隔离 + 强派发契约"。原版的并发写 guard 自认是事后提醒；本仓用 git worktree 从物理上避免并发写冲突。这是本仓相对原版的**实质进步**，有 README 明证（`README_zh.md:44,60`）。

### 5.5 范围守护

| 子项 | 原版 | 本仓 |
|---|---|---|
| Hook 强制程度 | **提醒 + 可选门**：PostToolUse 只 echo "Update progress.md"；Stop 默认 advisory；只有 gated 模式 + Tier1 宿主才 block。**没有任何 hook 阻止 agent 编辑计划外文件**（`SKILL.md:441-451`） | **PreToolUse 硬阻断**：`check-scope.sh` 阻止计划目录外 Write/Edit，非交互 Shell 无法逃逸（`README_zh.md:32,58`）；哨兵存在期间拦截非 plans/ 路径 |
| 宿主能力分层 | 明示 Tier1 hard block / Tier2 follow-up inject / Tier3 notify only，"gate is real enforcement only on Tier 1" | 未做宿主能力分级；强绑定 ZCode/Claude Code 的 Hook/Agent/TodoWrite 能力，跨平台靠 PowerShell 镜像与软壳 |
| opt-out | `PLANNING_DISABLED=1` / `PWF_SKIP_SUBAGENTS=1` / `PWF_PLAN_GUARD=0` / `PWF_PRETOOL=always` | `config.json` 门控三档（enforce/warn/off）+ env 覆盖，无会话级全局 opt-out |

**分析**：这是 README 7 行表中"范围守护：原版手动 vs 本仓 Hook"的具体展开，**本条声称成立且有源码支撑**。原版明确说 Critical Rules 写在 SKILL.md 里是纪律而非机器门；本仓把范围守护做成了 PreToolUse 硬阻断。代价是本仓对宿主能力有强依赖，原版则跨宿主降级但保持可用。

### 5.6 配置与门控档位

**原版**：无中心配置文件——环境变量 11+（`PLAN_ID` / `PWF_PLAN_ROOT` / `PWF_INJECT=smart` / `PWF_GATE_CAP` / `PWF_SKIP_SUBAGENTS` / `PLANNING_DISABLED` 等）+ `.mode` 空格 token + 点文件 + 模板参数 + 各宿主 manifest；两模式 `--autonomous` / `--gated`；无 schema，配置面碎片化不可集中审计。

**本仓**：`config.json` 556 行、40+ 键、JSON Schema `additionalProperties: false`（拼错即报错）；覆盖 VC 数量、子代理上限/超时、注入节流、陈旧提醒、门控档位。多数质量门支持 `enforce / warn / off` 三档，且区分"默认 observe（warn）"与"结构类 enforce 起步"（evidence_anchor / align_anchor / vc_nonvacuous / rvc_coverage / step_placeholder / tier_consistency 默认 enforce）。解析优先级统一为 `env > 计划配置表 > config.json > 默认`。

**分析**：README 表"配置阈值：原版硬编码 vs 本仓 config.json"——**成立但表述不精确**。原版不是完全硬编码，而是"分散在环境变量/dotfile/manifest，无单一真源"；本仓的优势是**集中 + schema 校验 + 三档渐进**。

### 5.7 生态、安装与平台

**原版**（`README.md` Quick Install + `SKILL.md:300-313`）：
- 7 条安装路线：Claude Code plugin marketplace / `npx skills add` / `npm install` / `pi install` / Hermes 原生插件 / OpenCode 插件 / DeepSeek Harness 插件。
- 60+ agent、19+ platform；5 语言变体（ar/de/es/zh/zht），v3.10 后补齐全套机制。
- 命令集：`/plan` `/pwf` `/status` `/plan-doctor` `/plan-attest` `/plan-goal` `/plan-loop` `/plan-{lang}`。
- **plugin vs standalone 能力割裂**：plugin 路线 6 hook + commands；standalone skill 5 hook 且 activation-scoped（无 startup recovery）、无 commands。

**本仓**：`install.sh` 检测 claude-code / zcode / opencode / cursor 等工具，安装软壳/薄壳/全量副本；`--tools` / `--canonical` / `--no-verify` / `--dry-run`；PowerShell 镜像支持原生 Windows；21 个 Skill 家族（task-dispatch / task-discipline / verification-gate / media-planner 等卫星）。部署位：`~/.zcode/skills/` `~/.claude/skills/` `~/.agents/skills/` `~/.config/opencode/skills/` 等（源码=本仓 `skills/`，部署位为派生，见 `AGENTS.md` §2）。

**分析**：原版在**生态广度与安装路线丰富度**上显著领先（60+ agent vs 4 工具；5 语言变体 vs 中英双语）；本仓在**深度工具链集成**上更强（卫星技能族 + 子代理 + Hook 体系），但这也意味着迁移成本高、绑定深。

### 5.8 测试与质量体系

| 子项 | 原版 | 本仓 |
|---|---|---|
| 测试 | Python pytest ~696（最后精确公开值，2026-09-02）+ 多套 Vitest；108 个测试文件；4 CI job（3 OS matrix） | 108 个 selftest 脚本；实测 `run-selftests.sh` **106 PASS / 106 FAIL=0**（全部命中缓存） |
| 性质 | 行为级测试（hook 注入、路径解析、attestation、cross-project guard 等） | 绝大多数为**静态守护**（grep 锚点断言 / 版本一致性 / 契约存在性），少量行为夹具 |
| 自评工具 | `/plan-doctor` 自检注入/解析/attestation/安装面/时延；CHANGELOG v3.15 修复过 "doctor 假 PASS" | `lib/verify.sh` 安装对账；`plan-doctor.sh`；`check-3file-gate.sh` 等门控脚本 |
| 当前状态 | CI 最近一次 `action_required`，前两次 `success`（2026-11-24 抓取） | `verify.sh` 实测 **27 pass / 4 fail**（部署位脚本硬编码路径），与 README "0 fail" 宣称不符 |

**分析**：原版测试更偏**行为级 + 公开 eval**，但自曝过"测试假绿"（`test_path_fix.py` 实现了正确逻辑却从未 import 真正脚本，测试一直绿）；本仓 selftest 全绿但**多为静态断言**，且 `verify.sh` 当前有 4 项失败。两者都不能简单说"测试更强"，需按维度看。

---

## 6. 功能矩阵总表

图例：✅ 强 / ◐ 部分 / ❌ 无 / ⚠️ 有局限

| 能力维度 | Planning with Files | task-planner | 备注 |
|---|---|---|---|
| 磁盘持久化计划 | ✅ | ✅ | 共享底座 |
| 每轮计划重注入 | ✅ 成熟（smart + 抑制 + nonce） | ◐ smart 注入 + 限频 | 原版有公开 token 开销数字 |
| 结构化状态源 | ❌ markdown + grep | ✅ JSON 权威 + 派生视图 | 本仓进步点 |
| 阶段状态机 | ✅ 三值 | ✅ 三值 + 硬门控 | |
| 完成门（客观验证） | ⚠️ grep 状态，无独立验证者 | ✅ VC/V-N 可执行命令 + 证据锚 | 本仓核心优势 |
| 子代理真实验证 | ❌ | ✅ Read 实际文件 + 双轮质检 | 本仓核心优势 |
| 独立验证者/裁决 | ❌ | ✅ decision-arbiter + critic + drift-checker | |
| 范围守护硬阻断 | ❌ 提醒 + 可选门 | ✅ PreToolUse 硬阻断 | 本仓进步点 |
| 多任务并行 | ◐ 文件级协议 + 建议 worktree | ✅ 内建调度 + 工作树隔离 + 协调者 | |
| 并发写安全 | ⚠️ 事后 advisory，非锁 | ✅ worktree 物理隔离 + 合并合约 | |
| 集中配置 + schema | ❌ 11+ env + dotfile | ✅ config.json + JSON Schema | |
| 紧凑入口（注入体积） | ◐ 41.9KB SKILL.md | ⚠️ 60.65KB SKILL.md（但 289 行） | 本仓刚做过 slim 压缩 |
| 压缩恢复 | ⚠️ PreCompact 只提醒 | ✅ 无条件注入技能全文 + 权威状态 | 本仓新机制，未量化 |
| 跨会话恢复 | ◐ 只读项目文件；历史读取须显式 | ✅ session-catchup 自动检测 | 详见 §5.3 |
| 生态广度 | ✅ 60+ agent / 19+ platform / 5 语言 | ◐ 4 工具软壳 + PowerShell 镜像 | 原版显著领先 |
| 公开评测 | ✅ eval + benchmark（但数字旧） | ❌ 无行为级 benchmark（仅静态 selftest） | 原版领先但有时效问题 |
| 防漂移机制 | ❌ | ✅ drift-checker + 三态判定 | |
| 防造假机制 | ❌（attestation 自认非签名） | ✅ 证据锚 + 非真空 VC + R→VC 覆盖 + 委派率门 | |
| 文档诚实度 | ✅ 自曝多处局限（attestation 非签名、hook 静默失败等） | ◐ 有诚实边界条款，但 README 有数字陈旧与表内矛盾 | 原版更透明 |

---

## 7. 量化数据对照

| 指标 | Planning with Files | task-planner | 证据 |
|---|---|---|---|
| Stars | 28,209 | 未取到 | `gh api`（原版）/ 本仓未查 |
| Skill 入口 | 534 行 / 41,938 B | 289 行 / 60,650 B | `wc`（双方） |
| 计划模板行数 | 未取到（未测） | 590+ 行 / 30+ 区块 | `grep -nE '^#{1,4} '` |
| 脚本数 | 未取到（仓库根 scripts 约 20+，未精确统计） | 170（含 108 selftest） | `ls -1 ... \| wc -l` |
| 测试规模 | ~696 Python tests + 多套 Vitest（最后精确值 2026-09-02） | 108 selftest 脚本，实测 `Total: 106 PASS=106 FAIL=0`（部分脚本 PASS=0 无断言，故断言脚本数 < 文件数） | CHANGELOG 3.15.0 / `run-selftests.sh` |
| 每轮注入开销 | ~330 tokens/turn + ~90 tokens/工具调用 | 1-1.5KB/轮（未折算 token） | `docs/evals.md` / `config.json:523-534` |
| Hook 时延 | 289ms（v3.6 旧值）/ 新版未测 | 未取到 | README FAQ / 本仓未测 |
| 上下文恢复轮数 | 5.0 vs native 13.3（作者自测，v3.4.0） | 未测 | `docs/evals.md` Test 5 |
| 首轮正确率 | 96.7% (29/30) vs 无技能 6.7%（v2.21.0，作者自测） | 未测 | `docs/evals.md` Test 1 |
| 成本代价 | +68% tokens / +17% time；$0.634/15.3 turns | 未测 | `docs/evals.md` |
| 安装对账 | 未取到 | 27 pass / 4 fail（当前工作树实测） | `lib/verify.sh` 实测 |

> **量化对比的诚实边界**：原版的 96.7% / 5.0 轮等旗舰数字来自作者自测（`docs/evals.md` 自述 "internal v1, tasks are harness-authored"，且版本停在 v2.21/v3.4，约 20 个版本未重测），**不可当作独立第三方 benchmark**。本仓无行为级 eval，selftest 全绿只说明静态断言通过，不代表任务质量。**两者在"任务质量"这一最终指标上都没有可比的可信数据**。

---

## 8. 优缺点分析（双方各列，挖真实局限）

### 8.1 Planning with Files 的优点（带证据）

1. **把"计划"变成可注入的机制，而不只是提示**：5–8 个生命周期 hook 每轮把选中计划送进注意力窗口，输出带 DATA ONLY 分隔符；benchmark 将"每轮重新浮现计划"列为 pwf 独有机制（`SKILL.md:6-29`、`inject-plan.sh`、`docs/benchmark/index.html`）。
2. **恢复能力有公开量化且可复现**：上下文硬中止后 5.0 轮恢复 vs native 13.3 / 次优 filesystem 8.3（2.7×），77/77 正确率不下降；grader 确定性、77 cells 重跑可复现，并公开修正过的评分器 bug（`docs/evals.md` Test 5）。
3. **对自身局限的文档诚实度罕见**：明确写出 SHA-256 非签名、init 自动 attest 非人工批准、nonce 不是访问控制、PreCompact 不保证进度落盘、gate 只在 Tier1 真强制、parallel-write guard 非锁非合并、benchmark 是 internal 且任务 harness-authored（`SKILL.md:319,421-427,493-512`；`docs/evals.md` Test 5 scope）。
4. **完成门读磁盘产物而非读对话**：gate 以 plan 文件 phase 状态 + ledger 进展为终止 oracle，理由固定模板不含 plan body，配 cap/stall/`stop_hook_active` 三重失控护栏（`SKILL.md:429-460`、`check-complete.sh --gate`）。
5. **并行/多代理一等公民**：slug 隔离、`PLAN_ID` 严格绑定（解析失败绝不回退）、`PWF_PLAN_ROOT` 绝对 pin、会话 attachment、per-agent ledger、单一 plan owner、跨宿主共享 attestation 与 gate 计数（`README.md` multi-agent 节；`SKILL.md:259-293`）。
6. **强可诊断性**：`/plan-doctor` 自检注入/解析/attestation/安装面/时延；歧义路径打印可操作提示（"Pin the thread with PWF_PLAN_ROOT/PLAN_ID"）而非静默失败（`SKILL.md:247,285-291`）。
7. **供应链/安装面覆盖极广**：60+ agent、19+ platform、7 类宿主原生插件、5 语言变体且 v3.10 后补齐全套机制（`README.md` 平台与安装节）。
8. **向后兼容的演进纪律**：无 `.mode` 时保持 v2.43 兼容形状（"legacy invariant"），v3 全部 additive opt-in；每次 bump 用脚本同步 parity 副本并有测试拦截（CHANGELOG v3.0.0 / v2.43.0）。
9. **安全纵深**：分隔符隔离 → SHA attestation → v3 nonce → 未 attested 拒绝注入 → ledger summary 替代未 attested progress tail → 私有 SHA cache → realpath containment → 外部内容只写 findings（`SKILL.md:483-521`）。
10. **超长 CHANGELOG 与 issue 闭环**：64 个 v3 版本条目，修复多带 issue/PR 编号与复现条件（#212 / #209 / #178 等），维护强度高（`CHANGELOG.md`）。

### 8.2 Planning with Files 的缺点（带证据，挖真实局限）

1. **旗舰数字严重过期**：README 顶部 96.7% / 3-of-3 / 5.0 轮来自 v2.21.0（2026-03-06）与 v3.4.0（2026-07-06），当前 3.29.1；`docs/evals.md:275` 明说 "stay historical until a new measurement exists"。约 20 版本、5 个月未重测旗舰指标，autonomous/gated/并行写守护/归档均无 eval 覆盖。
2. **自动触发率只有 5/8（最大短板）**：无提示任务中 filesystem/naive-plan/spec-kit 靠常驻规则 8/8，pwf 作为 discoverable skill 只有 5/8；O2 变体恢复优势被压缩到 7.2 vs naive-plan 6.8 轮。项目自认 "Widening that auto-engage rate is the next roadmap item"（`docs/evals.md` Test 5 Result 2/3）。核心优势只在"计划已落盘后"成立。
3. **没有真正的并发控制**：parallel-write guard 只是事后 advisory，不拦截写、不做锁/合并，不覆盖 progress/findings，按 plan path 而非 session 键控；attestation 也明确 "cannot stop the stale write from landing"（`SKILL.md:419-427`）。
4. **"验证"是可被文本操纵的自评**：完成门本质是 grep `### Phase` + `**Status:**`，无校验阶段内容真完成、无独立验证者、无测试/构建结果作为客观条件；agent 把所有状态改成 `complete` 即可放行（`SKILL.md:101`）。
5. **attestation 安全叙事被项目自己削弱**：普通本地 SHA-256、非签名；能改 plan 的进程通常也能改 attestation；init 自动 attest 非人工批准；nonce 与 plan 同目录无法防御有写权限者（`SKILL.md:498,508-511`）。只能防意外/低权限改动。
6. **默认不归档、默认 gitignore，跨任务知识会丢**：`docs/workflow.md` 明说 "no automatic 'completed' or 'archived' state"；v3.28.0 才加入手动 preview + `--yes` 归档，且 SKILL.md 要求 "Never archive on age or completion alone"。
7. **复杂度与维护负担极高**：SKILL.md 534 行/42KB、`inject-plan.sh` 65KB、`session-catchup.py` 30KB、108 测试文件、4 CI job、7 类宿主 hook、18 份 parity 副本、64 个 v3 版本。CHANGELOG 反复出现同类回归（v2.36.x 连发 3 个同步补丁、v3.9 一条修复暴露 11/13 路线 opt-out 失效）。
8. **静默失败是历史常态**：Test 4 记录 "2 of 6 mechanisms were broken on Windows, silently"；`test_path_fix.py` 实现了正确修复却从未 import 真正脚本、测试一直绿；plan-doctor 曾把拒绝提示字节数算作 PASS（`docs/evals.md` Test 4；CHANGELOG v3.15.0）。
9. **强制程度弱于宣传**：PostToolUse 只提醒写 progress；Stop 默认 advisory；gate 只 Tier1 可硬阻断；没有任何机制阻止 agent 改计划外文件或跳 findings（`SKILL.md:441-451`）。
10. **恢复能力被主动收窄**：自动恢复只读项目文件；`--metadata/--replay` 须显式要求；PreCompact 只提醒不写盘。5.0 轮优势依赖"文件已写好"这一前提（live `SKILL.md:48-66`）。
11. **插件/独立安装能力割裂**：standalone skill 只有 5 个 activation-scoped hook（无 SessionStart recovery）、无 commands、无 `/plan-goal`/`/plan-loop`；skill-only 路线 "can end up silently hook-less"（`SKILL.md:300-313`）。
12. **配置面碎片化、不可集中审计**：无 config schema；行为散落 11+ 环境变量、`.mode` token、点文件、模板参数、各宿主 manifest；`PLAN_ID`/`PWF_PLAN_ROOT`/`.attached`/`.active_plan` 四种选择机制叠加。
13. **成本高于朴素方案**：eval 中 +68% tokens / +17% wall time；$0.634/15.3 turns vs 无规划 $0.31–0.42/7–10 turns；每轮 330 tokens + 每次工具 90 tokens 常驻开销（`docs/evals.md`）。
14. **子代理隔离默认关闭**：`PWF_SKIP_SUBAGENTS=1` 是 opt-in，默认泄漏计划上下文给 subagent（CHANGELOG v3.26 / issue #348），无子代理独立验收协议。
15. **评测覆盖面自认不足**：不做长程漂移/中途干扰/欠定义任务 brainstorming/plan quality 判定/跨 IDE/多天跨度（`docs/evals.md` Test 5 "What this test does not measure"）。

### 8.3 task-planner 的优点（带证据）

1. **JSON 权威源 + Markdown 派生视图**：`plan-state.json` 经 `planctl.py` 原子写入 + 20 版备份 + tags 倒排 + render，4 个 MD 为禁手改的派生视图，根治"Markdown 手工编辑漂移"（`SKILL.md:93,108,148`）。
2. **硬门控体系把"完成"变成可证伪**：范围守护 Hook + attest 锁定 + V-N/VC 可执行命令 + 证据锚真实性 + 非真空 VC + R→VC 双向覆盖 + 对齐锚 + 防倒退终检（`config.json:131-180`；`SKILL.md:117-144`）。
3. **多任务并行 + 协调者 + 工作树物理隔离**：N 子代理各有 `plans/task-XXX/`，`plans/INDEX.md` 协调，worktree 从物理层避免并发写冲突（`README_zh.md:34,60,210-228`；`AGENTS.md` §11）。
4. **子代理真实验证 + 独立裁决**：双轮质检（自审→Read→全新复检体全文回读）、`decision-arbiter` 强模型四态裁决 + 驳回单、`drift-checker` 三态判定、子代理"完成"须 Read 实际文件才接受（`SKILL.md:85,115,121`）。
5. **方法论换模型档位**：明确以流程工程替代高档模型依赖，有用户定位原话锚（`README_zh.md:11-22`）。
6. **配置驱动 + 三档渐进门控**：40+ 配置项 + JSON Schema + enforce/warn/off，结构类门 enforce 起步、内容类观察期 warn，避免一刀切（`config.json`）。
7. **compact-recovery 针对压缩丢技能体系**：压缩后无条件注入技能正文全文 + 权威状态（`SKILL.md:54`，2026-11-24 新增）。
8. **大规模自检 + 版本锁步**：108 selftest、注入包 slim 压缩（95KB→61KB，`SKILL.md` 480→289 行）、parity 对账（近期 commit `b36b49f3` / `bb3c0507`）。

### 8.4 task-planner 的缺点（带证据，挖真实局限）

1. **复杂度极高**：21 Skill / 170 脚本 / 111 规则 / 60KB SKILL.md / 590 行 plan 模板；学习成本与维护成本巨大，与"轻量 Skill"背道而驰。
2. **`verify.sh` 实测 4 fail**：27 pass / 4 fail（4 个部署位脚本硬编码路径），与 README "N pass / 0 fail"（`README_zh.md:85`）宣称不符——门控自身也有部署同步问题。
3. **文档数字陈旧**：README 声称 Rules 1-97 / 8 agent / 29 variant（`README_zh.md:131,147,153`），实测 111 / 9 / 31——自述与实态脱节。
4. **门控默认多为 warn（观察期）**：内容质量/FMEA/VC-GATE/skill_collab 等仍 warn，即"部分门只告警不阻断"，硬保证不完整（`config.json`）。
5. **强绑定特定生态**：依赖 ZCode/Claude Code 的 Hook/Agent/TodoWrite；跨平台靠 PowerShell 镜像与软壳，非通用。
6. **上下文注入开销**：SKILL.md 60KB + 每轮 hook 注入；config 明确记录"每轮无条件注入 0.22-0.26s + 1-1.5KB 复利开销实测"，靠限频缓解（默认 interval=20）（`config.json:523-534`）。
7. **无公开行为级 benchmark**：selftest 全绿只说明静态断言通过；无类似于原版的恢复轮数/正确率等量化证据，"方法论换质量"的核心主张缺量化支撑。
8. **工作树有大量未提交变更**：当前 worktree 存在大量 M/D/?? 文件（含 4 个脚本 M、多计划文件），交付/部署状态不稳。
9. **文档诚实度有瑕疵**：README 7 行对比表把原版描述得偏弱（"跨会话恢复=手动"与原版实有 `session-catchup.py` 的事实不符），见 §11。

---

## 9. 适用场景与选型建议

### 9.1 决策矩阵

| 场景 | 推荐 | 理由 |
|---|---|---|
| 跨多宿主（Claude/Codex/Cursor/OpenCode/…）交付的通用 Skill | **原版** | 60+ agent / 19+ platform / 5 语言 / 多安装路线 |
| 个人开发者单工具（ZCode 或 Claude Code）长任务 | **本仓** | 强门控 + 子代理 + 工作树保证质量 |
| 多子代理并行的大型工程任务 | **本仓** | 内建调度 + 工作树物理隔离 + 独立裁决（原版无锁 Only advisory） |
| 需要"完成可证伪"、防造假、可审计交付 | **本仓** | VC/证据锚/非真空门（原版 grep 状态可自评放行） |
| 快速试水、低侵入、随时可退出 | **原版** | 3 文件 + 提示，standalone 也能用 |
| 内容创作 / 媒体生成多单元流水线 | **本仓** | `media-planner` 卫星 + 单元线并行 + 内容分级 |
| 需要公开量化证据支撑选型 | **原版**（但注意数字旧） | 有 eval/benchmark；本仓无 |
| 上下文极易压缩/丢失的超长会话 | **本仓**（机制上） | compact-recovery 无条件注入全文（未量化，属新机制） |

### 9.2 迁移成本警示

从原版迁到本仓不是"换配置文件"，而是**范式切换**：三文件→四文件罗盘+JSON 权威源、提示纪律→PreToolUse 硬门、文件协调→子代理调度+worktree。学习曲线陡峭；团队需要理解 111 条规则与 21 个卫星的分工。

---

## 10. 迁移与升级路径（从 Planning with Files 到 task-planner 的概念映射）

| 原版概念 | 本仓对应 | 映射关系 |
|---|---|---|
| `task_plan.md`（3 文件之一） | `task_plan.md`（派生视图）+ `plan-state.json`（权威源） | 文件名同，语义从"权威"降为"视图" |
| `findings.md` / `progress.md` | 同名文件（派生视图） | 职责基本一致，本仓由 planctl 渲染 |
| — | `knowledge-brief.md` / `verification.md` / `user-session-log.md` | 本仓新增的知识/终验/原话维度 |
| `### Phase N` + `**Status:**` | Phase 状态 + VC/V-N + 机器门 | 状态原语同，完成判据强度不同 |
| `PLAN_ID` / `.active_plan` | `resolve-plan-dir.sh` side 指针 / `.active_plan_side/` | 会话隔离思想一致，实现不同 |
| `.attestation`（SHA-256） | `attest-plan.sh`（三档门 + 证据锚 + 对齐锚） | 从"防篡改哈希"扩展为"多维门控" |
| PostToolUse 提醒 | PreToolUse 硬阻断 + `[plan-sync]`/`[plan-compass]` hook | 从"提醒"升级为"阻断+回写驱动" |
| ledger-*.jsonl | `ledger-append.sh` + `.zcode/ledger/`（progress-tracker） | 事件账本思想一致 |
| owner/worker 文件协议 | 四文件罗盘 + task-dispatch + worktree | 从"约定"升级为"内建调度+物理隔离" |
| `--gated` 模式 | `config.json` 三档 enforce + 硬门体系 | gate 从单一开关扩展为 40+ 维配置 |

**迁移实操建议**：① 保留原版三文件作为人可读入口，把本仓 JSON 权威源当作"编译产物"；② 先启用本仓"结构类 enforce 门"（证据锚/对齐锚），把内容类 warn 门留观察期；③ 并行任务先上 worktree 隔离，再逐步接子代理调度。

---

## 11. 风险、局限与诚实边界（对比的公平性声明）

1. **对象形态不同**：原版是发布到 npm/plugin marketplace 的**产品化 Skill**（有 star/CI/版本/评测）；本仓是**源码仓库**（Skill 家族源码 + plans + docs + 脚本），无对外发布版本号。用 star 数、CI 状态做横向对比不完全公平。
2. **证据渠道差异**：原版证据来自 live 仓库直取（含作者自评 eval），本仓证据来自本地文件系统实测（`wc` / `grep` / `run-selftests.sh` / `verify.sh`）。两侧都有一手证据，但原版的量化数据多为**作者历史自测**（`docs/evals.md` 自述 internal v1 / harness-authored / 版本旧），本仓**无行为级 eval**。
3. **README 对比表的不准确处**（本仓自述 vs 一手证据）：
   - "跨会话恢复：原版=手动恢复"——**不准确**：原版有 `scripts/session-catchup.py`（30KB）及自动恢复机制，只是其能力在 v3 被主动收窄为"只读项目文件、历史读取须显式要求"。本仓 README 此格低估了原版。
   - "配置阈值：原版=硬编码"——**不精确**：原版是"环境变量/dotfile/manifest 分散配置，无单一真源"，非完全硬编码。
   - "多任务并行：原版 ❌ 仅单任务"——**不精确**：原版 v2.36+ 有 slug 模式 + PLAN_ID + owner/worker 协议支持多任务，只是无内建调度器与锁。
4. **未验证项显式声明**：本仓 GitHub star/创建时间/CI 未查；原版仓库体积、本仓 hook 时延、本仓 token 开销未实测；本仓 compact-recovery 无量化 eval。这些在 §7 表格中标"未取到/未测"。
5. **版本时效**：原版 3.29.1（2026-11-23）与本仓 master（2026-11-24 工作树，含未提交变更）的对比是时点快照，双方都在演进。
6. **本报告的立场**：不判定"谁更好"，只呈现"谁在什么维度更强、证据是什么"。选型建议（§9）是基于证据的推荐，非绝对结论。

---

## 12. 结论与建议

**核心结论**：
- 两者是**同源不同目标**的两个工具：原版 = 广适配的"计划持久化认知外挂"；本仓 = 高保证的"任务执行治理系统"。
- README 声称的三项核心改进（多任务并行、范围守护、硬验证门控）——本报告逐条验证：**范围守护（§5.5）与硬验证门控（§5.2）成立且证据充分**；多任务并行（§5.4）本仓确实有内建调度+worktree 的实质优势，但原版也非 README 描述的"仅单任务"，声称的对比基线偏低。
- 本仓最值得肯定的进步：JSON 权威源、可证伪完成门、子代理真实验证、工作树物理隔离。
- 本仓最需补强的短板：文档数字陈旧、verify.sh 当前 4 fail、无行为级 benchmark、复杂度与绑定过深、部分门仍 warn。
- 原版最值得借鉴：对局限的文档诚实度、公开可复现的 eval、跨宿主兼容与诊断工具（plan-doctor）。

**给本仓的具体建议（按优先级）**：
1. **P0** 修复 `verify.sh` 4 项部署位硬编码路径失败，恢复"0 fail"基线；
2. **P0** 更新 README 7 行对比表（§11 列出的 3 处不准确），避免低估原版、误导用户；
3. **P1** 同步 README 中的陈旧数字（Rules 1-97→1-111、8→9 agent、29→31 variant）；
4. **P1** 建立最小行为级 eval（如"注入是否真的落到上下文""压缩恢复是否真的注入全文"），支撑"方法论换质量"主张；
5. **P2** 评估把 compact-recovery 量化（恢复轮数/正确率），对标原版 Test 5；
6. **P2** 在保持强门控的同时，提供面向轻量场景的"standalone 降级档"，降低接入门槛。

---

## 附录 A：证据索引

**本仓（本地路径）**：
- `README_zh.md:9-48,71-85,131,147,153,197-204,210-228,275-277` — 定位/对比表/命令/规模/VC/并行/许可
- `skills/task-planner/SKILL.md:29-36,48-61,85,93,107-148,150` — 四文件罗盘/哨兵/裁决/回填/终验/RAM-Disk
- `skills/task-planner/config.json:24-180,221-253,523-546` — 阈值/门控档位/provider_fallback/注入节流
- `skills/task-planner/templates/task_plan.md` — 590+ 行结构（grep 标题行实测）
- `AGENTS.md` §1/§2/§11 — 源码 vs 部署位、worktree 隔离
- 实测命令：`ls -1 skills | wc -l`=21；`ls -1 skills/task-planner/scripts | wc -l`=170；`ls -1 .../selftest-* | wc -l`=108；`wc -l -c SKILL.md`=289/60650；`du -sh .`=506M；`bash lib/verify.sh`=27 pass/4 fail；`bash run-selftests.sh`=106 PASS/106 FAIL=0

**原版（live 仓库，2026-11-24 `gh api` 直取）**：
- `README.md`（1015 行）、`SKILL.md`（534 行，v3.29.1）、`CHANGELOG.md`（最新 [3.29.1]）、`LICENSE`
- `skills/planning-with-files/reference.md`、`scripts/inject-plan.sh`、`scripts/check-complete.sh`、`scripts/session-catchup.py`、`scripts/attest-plan.sh`
- `commands/{plan,pwf,start,status}.md`
- `docs/{workflow,evals}.md`、`docs/benchmark/index.html`
- `.claude-plugin/plugin.json`（version 3.29.1）、`.github/workflows/tests.yml`
- 元数据：`gh api repos/OthmanAdi/planning-with-files`（stars 28209 / forks 2330 / created 2026-01-03 / pushed 2026-11-23）

## 附录 B：术语表

| 术语 | 含义 |
|---|---|
| RAM/Disk 公式 | Context Window=易失 RAM，Filesystem=持久 Disk，重要信息落盘 |
| 四文件罗盘 | 本仓 task_plan/findings/progress/knowledge-brief 四文件数据流转协议（Rule 62.1） |
| VC / V-N | Verification Contract（完成判定标准）/ 阶段级验证项 |
| planctl.py | 本仓计划状态权威写入工具（plan-state.json + render + check） |
| attest | 计划锁定/防篡改（原版 SHA-256；本仓三档门+证据锚） |
| gate 三态 | 原版宿主能力分层：Tier1 hard block / Tier2 inject / Tier3 notify |
| compact-recovery | 本仓 2026-11-24 机制：压缩后无条件注入技能全文+权威状态 |
| encoded preference | 原版自述：技能是"编码的偏好"而非"能力增量" |
| worktree 隔离 | 本仓实现类任务默认在 `tmp/worktrees/<task-id>` 独立分支开发 |
