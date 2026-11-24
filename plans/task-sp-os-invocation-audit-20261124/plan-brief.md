# 任务书（唯一内容源，v3）— task-sp-os-invocation-audit-20261124

> 本文件由主进程撰写，供 Plan Writer 编码进 `plan-state.json`（经 planctl）并产出 `knowledge-brief.md`。
> v3 说明：在 v2 基础上按粒度硬门（每单元 ≤2 文件、≤100 行、≤15 分钟）把 S-unit 由 13 个重拆为 20 个；目标、范围、Phase 与 VC 判据不变。§K 仅为修正留痕，**不得作为规范引用**。
> 路径缩写：`PD=/mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124`；`T=/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124`；`REPO=/mnt/data/dev/task-planner-skill`。

## §A 身份与目标

- task_id：`task-sp-os-invocation-audit-20261124`；template_type：`diagnostic`；plan_tier：`standard`；lane：`L1`。
- **Goal（一句）**：用一手证据查清路由修改之后（可取证窗口 2026-11-18 至 11-24）Superpowers / OpenSpec 两族技能在最近实际运行中是否被主动调用，定位「未被调用」的技能设计层根因（缺哪个驱动点/门，file:line），并产出可被驱动的改进方案（待用户批准，本轮不实施）。
- **任务性质**：纯调研只读。零仓库受管文件变更；产物只落 `PD/` 与 `T/`。
- **方法论**：Superpowers `systematic-debugging` 四阶段——本计划覆盖 Phase 1（根因调查）/ Phase 2（模式对比）/ Phase 3（假设验证）；Phase 4（实施修复）不在本轮（须用户批准后另起任务）。**根因未定位前禁给修复方案**，所以 P6 方案必须在 P5 根因之后。

## §B 用户原话与需求锚（逐字，来源 `PD/user-session-log.md` #1）

- **R1（目标）**：「我希望可以分析一下当前的技能的真实情况。」
- **R2（目标）**：「你可以调研一下最近几个最近的，就是说在修改之后的运行日志，查看是否存在这种情况」
- **R3（目标）**：「并给出相应的改进。」
- **R4（目标）**：「Superpowers或者是Openspec这两个就是技能的调用不是很理想，就是没有达到说解决问题，使用Superpowers或者是OpenSpec主动去解决问题，这是一个严重的问题。」
- R→VC 映射：R1→VC-2；R2→VC-3, VC-4, VC-5, VC-6；R3→VC-8；R4→VC-4, VC-7, VC-10；流程约束→VC-1, VC-9。
- 「主动调用」判定标准（由 R4 导出）：被调用**并用于推进问题解决**；仅文字提及不计。

## §C 核心问题解构（T2 四问；根因部分为**待验证假设**，P2-P5 取证后才能定论）

- **问题是什么**：用户观察到解决问题时 SP/OS 未被主动调用。至少 4 次有锚：10-08（`/home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md:157` R5）、11-15（`REPO/skills/task-planner/references/spec-mode.md:3`）、11-16（同文件 `:18`）、11-24（`PD/user-session-log.md` #1）；另 11-23 记忆引述（二手：`~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-slowness-forensics-20261123.md:10`）。历次修复均为文本路由条款，问题仍在。
- **本质（假设链，逐条待证）**：
  - H1 入口无驱动点：SessionStart 只注入 task-plan/task-resume，不注入 `using-superpowers`。
  - H2 路由触发面窄：task-planner 仅「Spec 模式触发判定」一处指向 SP/OS，条件=L1+ 且需求模糊/多方向/规格类；诊断/审计/修复类任务不在触发面内。
  - H3 功能同构竞争：task-planner 自带与 SP 同功能的机制（理解迭代、Plan Writer、VC、worktree、Agent 派发）且有脚本/hook/todo 驱动；SP/OS 只有文本指针。
  - H4 OpenSpec 落点缺失：本仓根无 `openspec/`，propose 无处落地；CLI 不在代理环境的 PATH 上。
  - H5 到达不了执行层：多数子代理无 Skill 工具，技能靠「伴飞 Read」到达，S-unit 伴飞列未制度性填写。
- **解决方案候选**（根因确认后才定，P6 产出 2-3 个并推荐）：A 必选 todo 基线组 + 驱动点（首选候选形态）；B 入口注入 + 路由判定脚本化；C 其它。
- **执行方案**：P1 计划与审计 → P2 设计层审计 ∥ P3 日志取证 ∥ P4 侧证 → P5 根因 → P6 方案+评审 → P7 终验交付。

## §D 硬约束

- **C1 只读**：不改 `skills/`、agents、hooks、`~/.zcode` 配置、任何部署位、其他项目文件；产物只落 `PD/` 与 `T/`。每次写文件后把绝对路径追加到 `T/writes.txt`（每行一个路径）。
- **C2 归因口径**（用户 2026-11-24 裁决）：执行方没做到=技能缺陷。禁写「执行方跳过/模型未遵守/行为门被忽略」；每条根因写成「技能缺了哪个驱动点/门 + file:line」。
- **C3 一手全量**：日志必须全量扫描，禁二手提取或抽样外推；每个统计数字附可复跑命令。区分「已验证 / 未验证」。
- **C4 禁提已否决项**（用户 2026-11-23 否决）：①砍委派率硬门或改主进程直做；②planctl 降级或允许直改 4 个 MD 视图。
- **C5 改进形态首选**：「必须每次发生」的步骤做成 `sync-todos.sh` 必选基线组成员 + 脚本/hook 驱动点；不先设计大方案。
- **C6 完成声称三证据**（执行/产出/验证）；无第一手证据标「未验证」。
- **C7 模型档位**：复杂单元用 sonnet-1 档执行体，不用 haiku 档做 schema 发现/脚本编写（Rule 110）。
- **C8 粒度硬门**：每个 S-unit ≤2 文件、≤100 新增行、≤15 分钟（Rule 59.1）；超限靠再拆单元解决，不改小申报数字。

## §E 主进程已核实事实（复用前请自行复核并补 file:line）

- **F1** Superpowers 族：`/home/terry/.agents/skills/` 下 using-superpowers、brainstorming、systematic-debugging、test-driven-development、writing-plans、executing-plans、verification-before-completion、using-git-worktrees、subagent-driven-development、dispatching-parallel-agents、requesting-code-review、receiving-code-review、finishing-a-development-branch、writing-skills（14 个）+ final-readthrough、find-skills（归属待 S3 核实）；`/home/terry/.zcode/skills/` 另有 5 个同名副本（brainstorming、using-superpowers、verification-before-completion、writing-plans、writing-skills）。来源=本会话技能清单。
- **F2** OpenSpec：CLI `@fission-ai/openspec@1.6.0` 已全局安装于 `/home/terry/.npm-global/bin/openspec`；**代理 Bash 与 `bash -lc` 的 PATH 均不含该目录**（`command -v openspec` → rc=1；证据 `T/probe-path.txt`）；11 个 `openspec-*` 技能在 `/home/terry/.zcode/skills/`；已初始化 `openspec/` 的项目：`/mnt/data/dev/article-generation`、`videop1`、`skill-seo`、`nanoimage`、`decentralized-base`、`fc_django_supsports`、`fc_django_crazypowertools`、`/home/terry/openspec`、`/home/terry/.claude/openspec`；**本仓根无 `openspec/`**（仅遗留 worktree `REPO/tmp/worktrees/task-todo-default-engine-20261123/openspec`）。
- **F3** 路由修改锚：`c5b891d7`（11-15 Spec 模式集成）、`54ec5258`（11-16 §1b 复杂度分档决策表）、`fc37133d`（11-16 §5 验证前置）、`a3b01601`（11-16 §5 反作弊指针）。权威文档：`REPO/skills/task-planner/references/spec-mode.md`、`REPO/skills/plan-collab-router/references/skill-collaboration.md`（§二路由矩阵在 `:51-70`，其中 OpenSpec 探针在 `:60`、「探针失败→该族标记不可接管」在 `:68`）、`REPO/skills/task-planner/SKILL.md`「Spec 模式触发判定」段。来源=`git log`。
- **F4 日志源（窗口更正）**：磁盘上只有 `/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl` 至 `zcode-2026-11-24.jsonl` 共 7 个文件（约 993MB，11-24 文件仍在增长）。**11-16、11-17 两天的日志已不在磁盘**（`backup.log` 是配置仓 git 备份，与日志无关），这两天无法取证，结论适用范围以此为限。另有 `/home/terry/.zcode/cli/db/db.sqlite`（13GB）、`rollout/model-io-sess_*.jsonl`、`artifacts/sess_subagent_agent_*`。既有扫描输出 `REPO/tmp/logscan-1..7.out`（二手，仅作 schema 线索）。来源=`ls -la` 实测。
- **F5** 11-23 诊断边界：日志层面从未量化 SP/OS 调用（记忆 `task-planner-slowness-forensics-20261123.md:53`）。
- **F6** 本会话现场（一手）：SessionStart hook 仅注入 task-plan + task-resume；UserPromptSubmit/PostToolUse hook 注入的是 PLAN TAMPERED / plan-sync / drift-rhythm / context-pressure / judge，无任何 SP/OS 相关提示。
- **F7** 子代理多数无 Skill 工具，技能靠「伴飞 Read SKILL.md 路径」到达（`critical-rules-dispatch.md:161` Rule 59.2）。
- **F8** 上游入口机制：obra/superpowers 的 `hooks/hooks.json` 只有一个 SessionStart hook（`startup|clear|compact` → `run-hook.cmd session-start`）；来源 https://github.com/obra/superpowers/blob/master/hooks/hooks.json（2026-11-24 经 zread 抓取，原文存 `T/upstream-superpowers-hooks.json`）。本机是否接线由 S5 核 hooks 配置。
- **F9** 部署位与源仓的 `planctl.py:935` 在重复 id 的报错路径引用了 add 子命令未定义的 `args.id`（主进程实测崩溃，已绕行）；仅作顺带发现，本任务不改。

## §F Phases 与 S-unit（ID 纯数字；时长裸 NNmin；每单元 ≤2 文件、≤100 行、≤15 分钟）

**并行组 `g-ro`**（只读、互不依赖）：S3、S4、S5、S6、S7、S11、S12 同批并发。
**前置依赖**（schema 不接受 depends_on 字段，以 `actions` 文本「前置=Sx」承载）：S8←S7；S9←S8；S10←S9；S13←S3,S4,S5,S6；S14←S10,S13；S15←S13,S14；S16←S15；S17←S16；S18←S17；S19←S18；S20←S19。

| ID | Phase | 目标 | Executor | 验收（可观察） | 时长 | 粒度 |
|---|---|---|---|---|---|---|
| S1 | P1 | 计划文档编码 | plan-writer(sonnet-1) | §G 全部满足（工作文件 2 个：plan-state.json、knowledge-brief.md；checkpoint 文件另计） | 15min | 2f/80l/15min |
| S2 | P1 | 计划独立审计（Rule 109） | critic(opus-1) | 出具 APPROVED 或分级问题清单；`[plan-audit-R<N>]` 留痕由主进程登记 | 10min | 0f/0l/10min |
| S3 | P2 | Superpowers 族清单与驱动引用盘点 | agent-quality-auditor(sonnet-1) | `T/report-design-sp.md`「技能清单」表：每技能一行，第一列为技能标识 `SP-<name>`（该行以竖线、空格再接 SP- 开头），列=安装位/触发条件原文/被引用处（文本指针、脚本、hook、模板、todo 基线组各几处）/证据 file:line；后附「上游入口机制与本机接线」小节 | 15min | 1f/100l/15min |
| S4 | P2 | OpenSpec 族清单、CLI 可达性与项目初始化态 | agent-quality-auditor(sonnet-1) | `T/report-design-os.md`「技能清单」表：每技能一行，第一列为 `OS-<name>`（该行以竖线、空格再接 OS- 开头），列同上；后附「CLI 可达性、各项目初始化态、opsx 命令在 ZCode 的可用性」小节；可选探针：仅在 `T/scratch-init/` 空目录用绝对路径试跑 `openspec init` 并记录产出，禁在仓库根或任何真实项目执行 | 15min | 1f/100l/15min |
| S5 | P2 | 驱动点缺口·入口与计划期（会话启动、指令到达、初始化、计划制作、Spec 判定、审计、计划确认） | agent-quality-auditor(sonnet-1) | `T/report-driver-gap-1.md`：每条缺口标题含 `DRIVER-GAP-<n>`，列=应发生的时点/应由什么驱动/现状（驱动、仅提及、无）/证据 file:line/影响的技能 | 15min | 1f/100l/15min |
| S6 | P2 | 驱动点缺口·执行与收口期（Phase 开启、派发前伴飞、执行中、完成声称前、收口归档）+ 对照机制 | agent-quality-auditor(sonnet-1) | `T/report-driver-gap-2.md`：同表结构；另含「对照机制」小节（取一个被稳定驱动的同类机制，列出其驱动链并与 SP/OS 逐点对比）；含子代理工具面清单（哪些 agent 有 Skill 工具）与 S-unit 伴飞列现状 | 15min | 1f/100l/15min |
| S7 | P3 | 日志 schema 确认 + 扫描脚本 + 单日试跑 | general-analyst(sonnet-1) | `T/schema-notes.md`（≤50 行）+ `T/sp-os-scan.sh`（≤50 行：输入一个日志文件，流式输出 `T/parts/<日期>.json`，含 lines_scanned、parse_bad、bytes 与会话级信号计数）；已在 11-24 单日文件跑通且 lines_scanned 等于 `wc -l` | 15min | 2f/100l/15min |
| S8 | P3 | 全量运行与汇总 | general-analyst(sonnet-1) | `T/sp-os-assemble.sh` + `T/scan-stats.json`（§H 结构；`recheck` 段留待 S10 写入；五个待 S9 回写的 totals 字段先置 null） | 15min | 2f/100l/15min |
| S9 | P3 | 逐会话推进证据与时间线 | general-analyst(sonnet-1) | `T/report-log.md`（≤100 行）；回写 `scan-stats.json` 的 totals 五个字段。若有 Skill 调用的主会话超过 35 个，先写前 35 个并在 blockers 报告 | 15min | 2f/100l/15min |
| S10 | P3 | 独立复检 | Verifier | `scan-stats.json` 的 `recheck` 段（rechecker 固定为 `Verifier`、commands、max_rel_diff、sample_lines）；抽查 ≥3 条 SESSION-EVID 行各自对应的原始日志行 | 12min | 1f/40l/12min |
| S11 | P4 | 计划目录侧证：11-18 起 `REPO/plans/` 与 `REPO/plans/archive/` 任务记录中的 SP/OS 使用痕迹 | general-analyst(sonnet-1) | `T/report-plans.txt`：`PLANS-EVID` 开头的行（≥1，每行带路径与日期）；末尾汇总窗口内任务数与各类型计数 | 15min | 1f/100l/15min |
| S12 | P4 | OpenSpec 产物时间线：各项目 `openspec/changes/` 与归档 | general-analyst(sonnet-1) | `T/report-openspec-artifacts.txt`：`OS-ARTIFACT` 开头的行（≥1，含遗留 worktree 那个 openspec 目录的来源），每行带项目、路径、日期、状态 | 15min | 1f/60l/15min |
| S13 | P5 | 根因裁定 H1-H3（入口、触发面、同构竞争） | general-analyst(sonnet-1) | `T/report-rootcause-1.md`：每条假设给 CONFIRMED 或 REFUTED、≥2 个独立证据锚（file:line 或命令与输出）、验证命令 | 15min | 1f/100l/15min |
| S14 | P5 | 根因裁定 H4-H5（落点、到达执行层）+ 未调用情况量化解读 | general-analyst(sonnet-1) | `T/report-rootcause-2.md`：同上；另含「零调用 / 仅提及 / 调用后未承接」三类会话的计数与归因 | 15min | 1f/100l/15min |
| S15 | P6 | 方案对比与推荐（主进程，使用 Superpowers `brainstorming`） | 主进程（例外理由：需主进程 Skill 工具 + 编排决策） | `PD/improvement-options.md`：2-3 方案、推荐项居首并标 `(Recommended)`、每个方案的取舍 | 10min | 1f/100l/10min |
| S16 | P6 | 推荐方案落地清单 | 主进程（例外理由：编排决策） | `PD/improvement-proposal.md`：`FILE-CHANGE` 开头的逐文件改动行、每项含 `DRIVE-POINT`（驱动点）说明；不触犯 C4 | 10min | 1f/100l/10min |
| S17 | P6 | 方案独立评审 | critic(opus-1) | APPROVED（0C/0I）或问题清单；评审面含 C1-C8 合规（含 C4 已否决项与 C5 基线组 todo 形态）及每项改动是否有驱动点 | 10min | 0f/0l/10min |
| S18 | P7 | 终验复验与收尾回读 | 主进程（例外理由：终验裁决与收尾回读属编排职责） | VC-2..VC-10 逐条复验；双源交叉（各子代理返回的 files 字段逐条核对均位于 `PD/` 或 `T/` 内，结果记 actions）；root_causes 按 S13、S14 的裁定编码（每条 defect 以 CONFIRMED 或 REFUTED 开头，process ≥61 字符；`config.hypotheses` 的 verified 与 anchor 同步）；全文档收尾回读（Rule 84.14）。VC 命令唯一取自 `plan-state.json` 的 `vcs[].command`，不从 MD 视图照抄 | 10min | 0f/0l/10min |
| S19 | P7 | 交付报告撰写 | 主进程（例外理由：编排职责） | `PD/REPORT.md`（≤100 行：结论先行，含窗口与盲区声明、关键数字、根因、推荐方案指针） | 10min | 1f/100l/10min |
| S20 | P7 | 报告面简版独立审计（[audit-before-delivery]） | critic(opus-1) | 对 `PD/REPORT.md`、`PD/improvement-options.md`、`PD/improvement-proposal.md`、`T/report-rootcause-1.md`、`T/report-rootcause-2.md` 出具 APPROVED（0C/0I）或问题清单；主进程登记审计时同时写一条以「[audit-before-delivery] verdict=APPROVED round=<轮次>」开头的行动留痕，随后复跑 VC-1 与 VC-8（rc=0）才可交付 | 10min | 0f/0l/10min |

## §G 计划编码验收

1. `planctl validate` 通过；`check vc-nonvacuous` 与 `check rvc` 均 PASS；`bash /home/terry/.zcode/skills/task-planner/scripts/check-plan-dispatch.sh PD/task_plan.md` 无 ✗ 行。
2. requirements R1-R4 逐字；vcs VC-1..VC-10 各含 criterion 与 command（command 逐字取自 §I；竖线只允许出现在正则字符类 `^[|]` 内）；phases P1-P7 含 Executor；s_units S1-S20 纯数字 ID，含 executor/duration/granularity/parallel（parallel 仅填 `g-ro` 或 `无`）；并行组 `g-ro` 已声明；fmea ≥4；decisions ≥11；root_causes 占位五条 H1-H5（`defect` 以 `verified=false` 开头，供 VC-7 改前 FAIL）。
3. knowledge-brief.md §1-§5 齐，§2 ≥6 条事实，每条带 file:line（必须实际 Read 来源后再写）。
4. render 后四个视图非注释行无 `{{大写}}` 占位残留。

## §H `T/scan-stats.json` 与 `T/report-log.md` 约定（S8 汇总、S9 回写、S10 复检、VC 消费）

- `files[]`：每项 `file`（绝对路径）、`lines_scanned`、`parse_bad`、`bytes`——必须逐一覆盖 `/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl` 至 `zcode-2026-11-24.jsonl` 七个文件（如有补充源可追加条目）。
- `totals`（15 个字段，全部键必须存在）：
  - `sessions_main`：窗口内有记录的主会话数（会话 id 形如 `sess_<uuid>`，不含 `sess_subagent_*`）；`sessions_sub`：子代理会话数。
  - `sessions_main_with_sp`、`sessions_main_with_os`：主会话中 SP / OS 的 Skill 调用数 >0 的会话数。
  - `sessions_main_with_sp_used`、`sessions_main_with_os_used`：其中经 SESSION-EVID 判为 used 的会话数（S8 置 null，S9 回写）。
  - `sessions_with_calls_main`：Skill 调用数（SP+OS）>0 的主会话数（去重）；`session_evid_rows`：SESSION-EVID 行数。二者必须相等（S8 置 null，S9 回写）。
  - `skill_calls_sp`、`skill_calls_os`：Skill 工具调用且技能名属于 SP / OS 集合的次数（全部会话，`per_session` 里用 `kind` 区分主会话与子代理）。
  - `escort_reads_sp`、`escort_reads_os`：Read 工具调用且路径命中技能目录下 SKILL.md 的次数。
  - `openspec_cli_calls`：Bash 调用含 openspec 命令（裸名或绝对路径）的次数。
  - `mentions_text_sp`、`mentions_text_os`：文本提及次数（仅作对照，不计入调用）。
  - `verdict`：一句话，明确回答「窗口内是否存在未被主动调用的情况」（S8 置 null，S9 回写）。
- `per_session[]`：`session_id`、`kind`（main/sub）、`project`（如可得）、`first_ts`、`last_ts`、上述各信号计数。
- `by_day{}`：按日汇总。
- `recheck`：S10 写入——`rechecker`（固定为 `Verifier`）、`commands[]`、`max_rel_diff`（重算的 4 个关键数字：`sessions_main`、`skill_calls_sp`、`skill_calls_os`、`openspec_cli_calls`，各自相对差异的最大值）、`sample_lines[]`。
- `definitions{}`：SP/OS 技能名集合与各信号判定的原始模式（正则/字段路径）。
- `T/report-log.md`：①开头为 used / ritual 判据表（used=Skill 调用之后，同会话内有可指认的后续动作承接该技能的产物或流程，按技能族各写一条可观察判据；ritual=调用后无承接，含调用即报错）；②每个有 Skill 调用的主会话**恰好一行**：`SESSION-EVID <session_id> <used|ritual> <技能清单，逗号分隔，形如 SP:brainstorming,OS:openspec-propose> <证据锚>`；③最近 ≥10 个主会话的逐会话时间线。
- 盲区处理：若日志不含工具参数，如实记为盲区并写明是否改用 db.sqlite 抽样及抽样范围；不得用推测补数。

## §I Verification Contract（10 条；command 逐字采用；竖线只出现在正则字符类内）

- **VC-1** 计划与报告均经独立审计达标。判据：末轮审计 verdict=APPROVED，且存在与末轮轮次一致、以「[audit-before-delivery] verdict=APPROVED round=」开头的行动留痕（即报告面审计已登记）。改前：没有报告面审计留痕 → FAIL。
  `jq -e --argjson r "$(jq -r '.audits[-1].round' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" '.audits[-1].verdict=="APPROVED" and (any(.actions[]; .text[0:48] == "[audit-before-delivery] verdict=APPROVED round=\($r)") or any(.actions[]; .text[0:49] == "[audit-before-delivery] verdict=APPROVED round=\($r)"))' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json`
- **VC-2** 设计层现状表落盘（R1）。判据：report-design-sp.md 的 SP 行 ≥14；report-design-os.md 的 OS 行 ≥11；report-driver-gap-1.md 与 report-driver-gap-2.md 的 DRIVER-GAP 行各 ≥1（改前文件不存在 → FAIL）。
  `test "$(grep -c '^[|] SP-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-sp.md)" -ge 14 -a "$(grep -c '^[|] OS-' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-design-os.md)" -ge 11 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-1.md)" -ge 1 -a "$(grep -c 'DRIVER-GAP' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-driver-gap-2.md)" -ge 1`
- **VC-3** 日志全量覆盖（R2）。判据：files ≥7 且逐一覆盖 11-18..11-24 七个日志文件的绝对路径；每文件 lines_scanned>0；parse_bad 为数值且 ≤ lines_scanned×5%。
  `jq -e '.files[-7] != null and all(.files[]; .lines_scanned>0 and (.parse_bad - 0)==.parse_bad and (.parse_bad - 0) <= (.lines_scanned * 0.05)) and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-18.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-19.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-20.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-21.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-22.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-23.jsonl") and any(.files[]; .file=="/home/terry/.zcode/cli/log/zcode-2026-11-24.jsonl")' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json`
- **VC-4** 调用量化结论（R2/R4）。判据：totals 的会话数、调用数、used 数、提及数、openspec 调用数均存在，verdict 非空，definitions 非空。
  `jq -e '.totals.sessions_main != null and .totals.sessions_main_with_sp != null and .totals.sessions_main_with_os != null and .totals.sessions_main_with_sp_used != null and .totals.sessions_main_with_os_used != null and .totals.skill_calls_sp != null and .totals.skill_calls_os != null and .totals.escort_reads_sp != null and .totals.escort_reads_os != null and .totals.openspec_cli_calls != null and .totals.mentions_text_sp != null and .totals.mentions_text_os != null and .totals.verdict != null and .totals.verdict != "" and .definitions != null' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json`
- **VC-5** 独立复检一致（R2）。判据：recheck.max_rel_diff ≤0.01 且 rechecker=Verifier。
  `jq -e '.recheck.max_rel_diff<=0.01 and .recheck.rechecker=="Verifier"' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json`
- **VC-6** 侧证清点（R2）。判据：report-plans.txt 的 PLANS-EVID 行 ≥1；report-openspec-artifacts.txt 的 OS-ARTIFACT 行 ≥1。
  `test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt -a "$(grep -c '^[P]LANS-EVID' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-plans.txt)" -ge 1 -a "$(grep -c '^[O]S-ARTIFACT' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-openspec-artifacts.txt)" -ge 1`
- **VC-7** 根因全覆盖（R4）。判据：root_causes 覆盖 H1-H5，每条 defect 以 CONFIRMED 或 REFUTED 开头，process 非空且 ≥61 字符（改前占位条目 defect 以 verified=false 开头 → FAIL）。
  `jq -e 'all(.root_causes[]; (.defect[0:9]=="CONFIRMED" or .defect[0:7]=="REFUTED") and .process != "" and .process[60:61] != null) and .root_causes[-5] != null and any(.root_causes[]; .id=="H1") and any(.root_causes[]; .id=="H2") and any(.root_causes[]; .id=="H3") and any(.root_causes[]; .id=="H4") and any(.root_causes[]; .id=="H5")' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json`
- **VC-8** 改进方案 + 评审（R3）。判据：improvement-options.md 含 (Recommended) ≥1；improvement-proposal.md 的 FILE-CHANGE 行 ≥1、DRIVE-POINT ≥1；末轮审计 APPROVED。
  `test "$(grep -c '[(]Recommended[)]' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-options.md)" -ge 1 -a "$(grep -c '^[F]ILE-CHANGE' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(grep -c 'DRIVE-POINT' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/improvement-proposal.md)" -ge 1 -a "$(jq -r '.audits[-1].verdict' /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-state.json)" = APPROVED`
- **VC-9** 写入范围零越界（C1）。判据：writes.txt 非空且不存在位于 `PD/`、`T/` 之外的路径。
  `test -s /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt -a -z "$(grep -v -e '^/mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/' -e '^/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/writes.txt)"`
- **VC-10** 逐会话推进证据齐备（R4）。判据：sessions_with_calls_main 与 session_evid_rows 均存在且相等（零调用时二者均为 0）。
  `jq -e '.totals.sessions_with_calls_main != null and .totals.session_evid_rows != null and .totals.sessions_with_calls_main == .totals.session_evid_rows' /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/scan-stats.json`

## §J 隔离、风险、决策

- **隔离决策**：纯调研只读 → 主工作树直做，无 worktree（宪法 §11.5 ③）。冲突分析：信号①未提交 50 个文件（他会话）、⑤其中 5 个为运行中基础设施文件、②3 个额外 worktree、③4 个 wt 分支、④28 个未完成任务；与本任务写域无重叠。
- **FMEA**：F1（P3）日志 schema 判读错误致统计失真 S6/O3/D2=36 → 兜底：S10 独立复检 + 主进程核对原始样例行；F2（P5）根因写成「执行方」归因 S5/O2/D2=20 → 兜底：critic 驳回重写；F3（P6）方案重提已否决项或无驱动点 S5/O2/D2=20 → 兜底：critic 驳回；F4（P3）全量扫描超时 S4/O3/D2=24 → 兜底：按日分片后台运行、逐日落盘；F5（P2）并发单元写同一文件 S3/O1/D1=3 → 已由一单元一产物文件消除。
- **Decisions**：D-1=可取证窗口 11-18..11-24（11-16、11-17 日志已不在磁盘，结论适用范围以此为限；由 S7 评估 db.sqlite 能否补）；D-2=「运行日志」口径=ZCode 结构化日志为主、plans/ 记录与 openspec/ 产物为侧证，全量扫描禁抽样外推；D-3=「给出相应的改进」=交方案待批，本轮不实施；D-4=Rule 30 不适用（只读，无共享可变资源认领）；D-5=隔离=直做；D-6=P3 执行体用 general-analyst(sonnet-1) 而非默认 log-distiller(haiku-1)，理由=schema 发现+脚本编写属复杂任务；D-7=D1 口径=非 goal 完成性指令，展示后 5 分钟超时按默认项自动通过（Rule 44.3），自动裁决记录落 actions；D-8=root_causes 的 H1-H5 为待验证假设（root_cause_item 为 additionalProperties=false，假设明细放 config.hypotheses；s_units 无 depends_on 字段，前置依赖以 actions 文本承载）；D-9=Spec 模式触发判定=命中，调查阶段按 systematic-debugging 执行，方案阶段用 brainstorming，OpenSpec propose 本轮不调用（本仓未 init，前置不满足）；D-10=VC 命令中竖线只允许出现在正则字符类内；D-11=S11、S12 执行体用 general-analyst(sonnet-1)（Explore 为只读搜索体，无 Write 与 Edit，无法落盘产物与检查点）；D-12=按粒度硬门把 S-unit 由 13 个重拆为 20 个，一单元一产物文件；S1 的工作文件为 2 个（checkpoint 文件另计）。
- **调研需求三态（Rule 75.1）**：S3-S12 = LOCAL-ONLY；F8 的官方入口机制已由主进程抓取留痕（NET-RESEARCH 1 次，来源与日期见 §E）；S3 如需补充上游事实须同样留来源与日期，禁凭记忆写。
- **工具选择（Rule 40.2）**：workflow 编排不命中（未点名 /workflow，Rule 39.8 未命中）；用户未使用 /goal（40.3 如实披露）。
- **进度产出基线（Rule 111）**：`T/report-design-sp.md`、`T/report-design-os.md`、`T/report-driver-gap-1.md`、`T/report-driver-gap-2.md`、`T/schema-notes.md`、`T/sp-os-scan.sh`、`T/sp-os-assemble.sh`、`T/scan-stats.json`、`T/report-log.md`、`T/report-plans.txt`、`T/report-openspec-artifacts.txt`、`T/report-rootcause-1.md`、`T/report-rootcause-2.md`、`PD/improvement-options.md`、`PD/improvement-proposal.md`、`PD/REPORT.md`——交付/返工均不得就地删降替。

## §K 审计与门控修正留痕（仅留痕，规范以正文为准）

- R1（critic，REJECTED 1C/8I/8W）：VC-7 结构不可达、日志窗口、区分调用与提及、并发同写、依赖字段、视图转义、报告面审计、比例与措辞——已并入正文。
- R2（critic，REJECTED 新增 1C/2I/3W）：任务书双版本规范（合并为单一版本解决）、SESSION-EVID 行粒度、VC-2 命令统一、VC 编号残留、VC-1 复跑时点、VC-10 的 Goal 归属——已并入正文。
- R3（critic，APPROVED 0C/0I/2W）：两处文本不一致已修。
- attest 首次锁定被粒度硬门拒绝（9 个单元超过 ≤2 文件、≤100 行、≤15 分钟）：回炉重拆为 v3 的 20 个单元，未放宽任何门槛、未改小申报数字。
