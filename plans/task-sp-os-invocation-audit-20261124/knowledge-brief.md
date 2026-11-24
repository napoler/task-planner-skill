# Knowledge Brief — task-sp-os-invocation-audit-20261124（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。
>
> **规范权威声明**：plan-brief v3 为唯一规范（正文 §A-§J），§K 仅为审计修正留痕，禁作为规范引用；本 brief 全部节号引用均指向 v3 正文。
> 内容源：仅取自实际 Read 过的源码/文档/既有计划文件（逐条 file:line）；推测与假设不进 §2，只作 §4 待验证项。

## §1 任务速览与核心概念

- 任务一句话：用一手证据查清 11-16 路由修改后 Superpowers / OpenSpec 两族技能在最近实际运行中是否被「主动调用」（被调用并用于推进问题解决，仅文字提及不计），定位技能设计层根因（缺哪个驱动点/门 + file:line），产出可被驱动的改进方案待批（本轮不实施）。
- 背景/动机：用户 2026-11-24 原话判定该问题「是一个严重的问题」；至少 5 次被提出且历次修复均为文本路由条款，问题仍在（plan-brief v3 §C:25）。
- 方法论边界：Superpowers `systematic-debugging` 四阶段只覆盖 Phase 1-3（根因调查/模式对比/假设验证）；Phase 4 实施修复不在本轮。根因未定位前禁给修复方案（plan-brief v3 §A:12）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 主动调用 | Skill 工具调用且技能用于推进问题解决；仅文字提及不计（由 R4 导出，plan-brief v3 §B:16-20） |
| 驱动点 | 使技能「必须每次发生」被触发的脚本/hook/必选基线组成员，区别于仅文本指针（plan-brief v3 §C H3:29 + §D C5:41） |
| 伴飞 Read | 子代理多数无 Skill 工具，技能靠任务书注入 SKILL.md 绝对路径并首动作 Read 到达（critical-rules-dispatch.md:161） |
| 归因口径 C2 | 执行方没做到=技能缺陷；根因必须写成「技能缺哪个驱动点/门 + file:line」，禁写「执行方跳过/模型未遵守」（plan-brief v3 §D C2:38） |
| g-ro | 只读并行组，成员 S3/S4/S5/S6/S7/S11/S12 同批并发，互不依赖（plan-brief v3 §F:60） |
| H1-H5 | §C 五条待验证根因假设，计划期 verified=false 占位，P5 取证后逐条验证/推翻（plan-brief v3 §C H1-H5:26-31） |
| PD / T | PD=/mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124；T=/mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124（plan-brief v3:5） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| Spec 模式路由触发=L1+ 任务（mini/L0-T/L0-E 豁免）且需求模糊/多方向/「优化改进」未定边界/需规格或变更提案；L1+ 命中即走。 | /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md:7-8（实际 Read） | S5/S6 登记 DRIVER-GAP 的触发面原文；诊断/审计/修复类任务不在该触发面，是 H2 的取证起点 |
| §1b 复杂度分档：L0/mini 不路由；L1 无规格留存→Superpowers 嵌入；L2+ 或规格留存→OpenSpec 移交；bug 排查→systematic-debugging；判定顺序 comet→OpenSpec→superpowers。 | spec-mode.md:18-28（实际 Read） | S3/S4 触发条件列须逐字引用本表；S13 验证 H2 时区分「触发面窄」与「触发后未执行」 |
| task-planner 对 SP/OS 的接线只有 SKILL.md 初始化检查项内一处「Spec 模式触发判定」文本指针（L1+ 且模糊/多方向/规格类 → brainstorming / openspec-propose）。 | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:114（实际 Read） | 一手锚：H2「路由触发面窄」与 H3「只有文本指针、无脚本驱动」的直接证据；S3 按此定位唯一指针 |
| `using-superpowers` frontmatter 声明「Use when starting any conversation」，正文要求任何响应/动作前先调用技能、进入 plan mode 前先 brainstorming；但其自身无 hook/脚本驱动点。 | /home/terry/.agents/skills/using-superpowers/SKILL.md:3,10-24（实际 Read） | H1「入口无驱动点」的对照面：技能文本要求存在，缺的是把它注入会话的机制；S3/S5 须核 hook 接线 |
| Rule 59.2 技能伴飞：全部子代理具备 Read、仅 3 个 agent 具备 Skill 工具；技能靠任务书「路径 + 首动作 Read」到达，改 agent 定义属保护区。 | /home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md:161（实际 Read） | H5 直接证据；S-unit 伴飞列未制度性填写到达不了执行层；S15/S16 改进方案须给可执行驱动点 |
| Rule 59.3 要求任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills，把匹配技能写入 knowledge-brief「可用强化技能」区块；用户触发型技能仅提示、禁自动代激活。 | critical-rules-dispatch.md:163（实际 Read） | §6 技能扫描清单的设计依据；执行体不得把用户触发型技能当自动可用 |
| 用户 2026-10-08 R5 原话：「基本没有调研 /comet 技能来进行任务执行的强化执行 我从来没有见过激活 …… supowerpowers 的相关技能也从未激活过 比如 头脑风暴」。 | critical-rules-dispatch.md:157（实际 Read） | 问题至少自 10-08 存在；本次须区分「从未激活」与「修改后是否激活」，日志取证窗口自 11-17 |
| SessionStart hook 只调 `task-plan-init.cjs` 写哨兵，注入文本仅 task-plan-init 与未完成任务 [task-resume] 提醒（CWD/plans/INDEX.md），无 SP/OS 任何提示。 | /home/terry/.zcode/skills/task-planner/scripts/zcode-sessionstart.sh:3,12-13,16-17,60（实际 Read） | H1 一手证据；F6「本会话现场」的机器面复核；S5 列 DRIVER-GAP 时引用本行 |
| 用户 #1 原话与可逆假设 A1（修改之后=11-15/11-16 提交后）、A2（运行日志=ZCode 结构化日志 + plans/ 记录）、A3（改进=方案待批本轮不实施）。 | /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/user-session-log.md:42-53（实际 Read） | R1-R4 逐字编码源；D-1/D-2/D-3 依据；歧义判定=按推荐项自决不阻塞询问 |
| 本仓根无 `openspec/` 目录（实测 find 返回不存在）；11 个 openspec-* 技能在 ~/.zcode/skills/；CLI @fission-ai/openspec@1.6.0 在 /home/terry/.npm-global/bin。**更正（主进程 2026-11-24 复测）**：代理 Bash 与 `bash -lc` 的 PATH 均不含该目录，`command -v openspec` → rc=1。 | /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-brief v3 §E F2:48（实际 Read；find/ls 实测复核） | H4 取证起点；S12 侧证须去各项目 openspec/changes/ 而非本仓根；S8 统计 openspec_cli_calls 时注明 PATH 盲区 |
| 日志源形态：/home/terry/.zcode/cli/log/zcode-2026-11-17..24.jsonl 单日 72M–226M，11-23 记忆数字 971MB/117 万行/2312 会话为二手待核；既有 REPO/tmp/logscan-1..7.out 仅作 schema 线索。 | plan-brief v3 §E F4:50（实际 Read） | S7 必须先在 11-24 单日跑通 schema；S8 全量按日分片汇总；记忆数字标「未验证」不得直接引用为结论 |
| **探针断点**：协同路由矩阵规定 OpenSpec 族「CLI 探针前置 `command -v openspec` + `openspec/` 目录」，且「探针失败 → 该族标记不可接管」；代理执行环境实测 `command -v openspec` → rc=1、`command -v comet` → rc=1（PATH 不含 ~/.npm-global/bin；导出语句在 ~/.bashrc:127；绝对路径调用返回 1.6.0）。 | /home/terry/.zcode/skills/plan-collab-router/references/skill-collaboration.md:60,68（主进程实际 Read）+ /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/probe-path.txt（主进程实测输出） | 按设计文本，OpenSpec 与 comet 两族在代理环境每次探针都会被判「不可接管」；S5/S6 必列 DRIVER-GAP；S7 可统计日志中探针命令的出现次数 |
| **官方入口机制**：Superpowers 上游靠 SessionStart hook（matcher `startup|clear|compact` → `run-hook.cmd session-start`）把入口技能注入每个会话；本机本会话开场的 hook 注入中没有该内容。 | https://github.com/obra/superpowers/blob/master/hooks/hooks.json（2026-11-24 经 zread 抓取；原文存 /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/upstream-superpowers-hooks.json） | H1 对照面：入口驱动点在上游存在；是否在本机 ZCode 接线由 S3/S5 核 hooks 配置确认（当前仅确认「本会话注入内容里没有」） |
| **磁盘日志实况（K2 更正，取代上文 11-17..24 旧表述）**：/home/terry/.zcode/cli/log/ 下 zcode-2026-11-18.jsonl 至 zcode-2026-11-24.jsonl 共 7 个文件；11-16、11-17 两天已不在磁盘；backup.log 属配置仓 git 备份、与日志无关。 | 可复跑命令 `ls -1 /home/terry/.zcode/cli/log/zcode-2026-11-*.jsonl`（本会话实跑输出 7 行，逐行为 11-18..11-24）；plan-brief v3 §E F4:50 + §J D-1/D-2:140 | VC-3 判据改为 files≥7 且逐一覆盖 11-18..11-24 七个绝对路径；D-1/D-2 窗口同步更正；结论适用范围以此为限，11-16/11-17 能否补由 S7 评估 db.sqlite |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md | :1-8 | 定位=R6「调用不是复制」；§1 触发=L1+ 且模糊/多方向/规格类；路由表入口 |
| spec-mode.md | :18-28 | §1b 复杂度分档决策表 + 择一语义 + 探针缺失回落规则 |
| /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | :108-119 | 初始化检查项含唯一「Spec 模式触发判定」指针（:114）与计划独立审计门（:116-119） |
| /home/terry/.zcode/skills/task-dispatch/references/critical-rules-dispatch.md | :155-163 | Rule 59.1 粒度三值（:159）、59.2 伴飞（:161）、59.3 技能扫描（:163）与 R5 原话（:157） |
| /home/terry/.zcode/skills/task-planner/scripts/zcode-sessionstart.sh | :1-17 | SessionStart 适配器：读 stdin 取 session_id、调 task-plan-init.cjs、注入 [task-resume]；无 SP/OS |
| /home/terry/.agents/skills/using-superpowers/SKILL.md | :1-24 | frontmatter 声明 any conversation；The Rule=响应前先调用技能、plan mode 前先 brainstorming |
| /mnt/data/dev/task-planner-skill/plans/task-sp-os-invocation-audit-20261124/plan-brief.md | :1-5(v3 说明),7-12(§A),14-21(§B),23-33(§C),35-44(§D),46-56(§E),58-84(§F),86-91(§G),93-111(§H),113-134(§I),136-143(§J) | 任务书 v3 正文为唯一规范（§A-§J）；§K 仅审计留痕、不得作为规范引用 |
| PD/user-session-log.md | :42-53 | #1 逐字原话 + 理解镜像（A1-A3 可逆默认、歧义不阻塞） |
| PD/plan-state.json | 全文（经 planctl 写入） | 权威源：R4/G3/VC10/P7/S20/FMEA5/决策12/假设5/基线16；4 视图由 render 派生，禁手工 Edit |
| /home/terry/.zcode/skills/task-planner/scripts/planctl.py | :425-466,523-525,1781-1818,1247-1284 | 条目校验/root_causes required/vc-nonvacuous/rvc/render Phase Executor 派生逻辑 |
| /home/terry/.zcode/skills/task-planner/schemas/plan-state.schema.json | definitions.root_cause_item | root_cause_item additionalProperties=false（仅 id/process/defect/fix/vc），故 verified 状态另由 config.hypotheses 承载 |

## §4 易错点与禁止假设清单

1. **C1 只读**：不改 skills/、agents、hooks、~/.zcode 配置、任何部署位、其他项目文件；只允许写 PD/plan-state.json（经 planctl）、PD/knowledge-brief.md、PD/subagent-state/1-plan-writer.md；执行期产物只落 PD/ 与 T/，每次写文件后把绝对路径追加 T/writes.txt。
2. **C2 归因口径**：禁写「执行方跳过/模型未遵守/行为门被忽略」；每条根因写成「技能缺哪个驱动点/门 + file:line」。
3. **C3 一手全量**：日志全量扫描，禁二手提取或抽样外推；每个统计数字附可复跑命令；区分「已验证 / 未验证」。
4. **C4 禁提已否决项**：①砍委派率硬门或改主进程直做；②planctl 降级或允许直改 4 个 MD 视图。
5. **C5 改进形态**：「必须每次发生」的步骤做成 sync-todos.sh 必选基线组成员 + 脚本/hook 驱动点；不先设计大方案。
6. **根因未定位前禁给修复方案**：P6 必须在 P5 之后；H1-H5 计划期只是 verified=false 占位，禁当定论写入任何报告。
7. **planctl schema 限制**：root_cause_item 的 additionalProperties=false，额外 field（verified/evidence/tags）会被 add/set 拒绝；verified=false 由 config.hypotheses + root_causes[].defect 文本承载，S13/S14 裁定后按 VC-7 判据补 defect/process，禁手工 Edit 权威源绕过校验（已实测，见 D-8）。
8. **VC command 形态**：command 必须为纯命令、无反引号、PD/T 缩写展开为绝对路径；含反引号或缩写会使 vc-nonvacuous/可复跑性失效。
9. **S-unit ID 纯数字**：一律 S1、S2…（禁 S2a 等字母后缀）；duration 为裸 `NNmin`；g-ro 成员 S3/S4/S5/S6/S7/S11/S12 的 parallel 列须恰为 `g-ro`。
10. **禁运行会话绑定脚本**：attest-plan.sh、init-session.sh、set-active-plan.sh、plan-created.cjs 归主进程；本会话一律不调。
11. **禁手工 Edit/Write 4 个 MD 视图**：task_plan.md / findings.md / progress.md / verification.md 仅由 render 派生。
12. **NET-RESEARCH 禁脑补**：S3/S4「Superpowers 官方激活机制」若本机无 hooks 源文件，按检索词 `obra/superpowers hooks.json SessionStart using-superpowers` 经 zread/GitHub 真实抓取并记录来源 URL + 抓取日期。

- FMEA RPN>100 兜底指针：本任务 FMEA 最高 RPN=36（F1 日志 schema 判读错误），无 RPN>100 项；F1-F4 兜底动作见 task_plan.md FMEA 表（→ plan-state.json `fmea` 段）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 + §4 | PD/plan-brief.md（v3 正文 §A-§J 唯一规范；§K 仅留痕）；PD/user-session-log.md:42-53 |
| S2 | §1 + §4（Rule 109 审计面） | PD/task_plan.md（render 派生）；PD/knowledge-brief.md |
| S3 | §2(1)(2)(3)(4) + §3 + §4(12) | F1/F8=PD/plan-brief v3 §E:47,54；spec-mode.md:1-28；upstream-superpowers-hooks.json；T/report-design-sp.md |
| S4 | §2(5) + §3 + §4(12) | F2=PD/plan-brief v3 §E:48；probe-path.txt；T/report-design-os.md；T/scratch-init/（可选探针） |
| S5 | §2(1)(3)(8) + §4(2) | F3/F6=PD/plan-brief v3 §E:49,52；zcode-sessionstart.sh:1-17；sync-todos.sh；T/report-driver-gap-1.md |
| S6 | §2(4)(7) + §3 + §4(2) | critical-rules-dispatch.md:161-163；各 hook 脚本；T/report-driver-gap-2.md |
| S7 | §2(10)(11) + §3 + §4(3)(8) | F4=PD/plan-brief v3 §E:50；T/schema-notes.md + T/sp-os-scan.sh（各 ≤50 行） |
| S8 | §5(S7) + §4(3) | T/sp-os-assemble.sh + T/scan-stats.json（§H 结构，recheck 留待 S10） |
| S9 | §5(S8) + §2(11) + §4(3) | T/report-log.md（SESSION-EVID 每会话一行）+ 回写 scan-stats.json 五个 totals 字段 |
| S10 | §5(S7)(S8)(S9) + §4(3) | T/scan-stats.json 的 recheck 段；抽查 ≥3 条 SESSION-EVID 原始日志行 |
| S11 | §2(10) + §3 + §4(3) | REPO/plans/ 与 REPO/plans/archive/；T/report-plans.txt |
| S12 | §2(5)(10) + §3 | 各项目 openspec/changes/；遗留 worktree openspec 目录；T/report-openspec-artifacts.txt |
| S13 | §1 + §2(6)(7) + §4(2)(6)(7) | PD/plan-brief v3 §C H1-H3:27-29；T/report-rootcause-1.md |
| S14 | §1 + §2(5)(6)(7) + §4(2)(6) | PD/plan-brief v3 §C H4-H5:30-31；T/report-rootcause-2.md |
| S15 | §4(2)(4)(5)(6) | Superpowers brainstorming；T/report-rootcause-1.md/-2.md；PD/improvement-options.md |
| S16 | §4(2)(4)(5) | PD/improvement-options.md；PD/improvement-proposal.md |
| S17 | §4(2)(4)(5) | PD/improvement-options.md + PD/improvement-proposal.md；PD/plan-brief v3 §I VC-8:129-130 |
| S18 | §2(9) + §4(1)(8)(9)(10)(11) | PD/plan-brief v3 §G/§H/§I:86-134；T/writes.txt；4 派生视图；root_causes 编码 |
| S19 | §4(1)(8) | PD/REPORT.md（≤100 行，结论先行 + 窗口/盲区声明） |
| S20 | §4(1)(6)(8)(11) | PD/REPORT.md + PD/improvement-options.md + PD/improvement-proposal.md + T/report-rootcause-1.md/-2.md |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| using-superpowers | /home/terry/.agents/skills/using-superpowers/SKILL.md | 本任务调研 SP 族激活机制（§2(4)） | 主进程按需 Read；子代理伴飞注入路径（禁改 agent 定义） |
| systematic-debugging | /home/terry/.agents/skills/systematic-debugging/SKILL.md | §A 方法论四阶段（本轮只覆盖 Phase 1-3） | 主进程按需 Read / S9 伴飞 |
| brainstorming | /home/terry/.agents/skills/brainstorming/SKILL.md | S15 方案对比推荐（2-3 方案） | 主进程 Skill 调用（S15 Executor 例外理由） |
| verification-before-completion | /home/terry/.agents/skills/verification-before-completion/SKILL.md | C6 完成声称三证据 | 主进程 S18 终验按需 Read |
| openspec-propose | /home/terry/.zcode/skills/openspec-propose/SKILL.md | H4 落点缺失 / S12 侧证 | 只读核对其触发条件；本轮不实施改进 |
| 其余 openspec-*（共 11 个） | /home/terry/.zcode/skills/openspec-*/SKILL.md | apply-change / archive-change / bulk-archive-change / continue-change / explore / ff-change / new-change / onboard / sync-specs / verify-change（plan-brief v3 §E F2:48） | S3/S4 盘点清单；不自动代触发 |

## §7 项目知识库回链（终验后入库触发）

- **触发点**：任务终验交付完成后（S20 / VC-1..VC-10 全 PASS 后、归档前后皆可）。
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/task-sp-os-invocation-audit-20261124` → 生成 knowledge/entries/_draft-task-sp-os-invocation-audit-20261124.md。
- **精炼**：draft 为机械提取原文，需合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名。
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）。
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（Rule 71 无源不写）。
