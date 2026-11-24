# Knowledge Brief — task-goal-unattended-protocol-20261124（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer 产出，执行期持续回填。
> 唯一内容源：`plan-brief.md`（§A 已批准计划逐字 + §B 编码说明）。本文件不新增语义，只做索引与排雷。

## §1 任务速览与核心概念

- 任务一句话：修复 Skill 家族在 goal 模式下「用户不在场 + 宿主自动续推」时的空转缺陷（新增 Rule 28.9 八子条 + 6 载体措辞级联 + decision-arbiter 源配置对齐），合并回 master 并部署 5 运行位，VC-1..VC-8 全 PASS。
- 背景/动机：示例会话 `sess_df5b8b4a` 真实用户消息仅 2 条，宿主续推 14 轮、`AskUserQuestion` 9 次无应答、部署决策翻转 3 次，最后「授权」被丢弃；11-18 Rule 28.8 修法无效且非部署漂移（plan-brief.md:11-22）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| goal 模式无人值守 | 用户不发消息、宿主 Completion verifier 自动续推的运行语境；skill 必须零提问、零停表 |
| 续推指令 | 宿主在 verifier 轮次发出的继续信号；按 28.9③ 视为差距线索，不是新裁决或用户授权 |
| 授权预算矩阵（28.9②） | 取代开放集合式「不可越权硬门」：部署类=预算内预授权；护栏=仅已合并 master 且 selftest 通过、逐位 diff 判向、禁整文件覆盖、先备份、后 verify |
| 决策冻结（28.9⑥） | goal 任务决策翻转上限 1 次；冻结表见 plan-brief.md §B10 D-1..D-7 |
| 固定点应答（28.9⑤） | 预算外硬门首次说明≤10 行、零工具调用，豁免 95/64/103 及 hook 派发提醒 |
| 运行位 | `~/.zcode`、`~/.agents`、`~/.claude`、`~/.config/opencode`、`~/.cursor` 五处部署目的地；本仓 `skills/` 是权威源 |
| 逐位 diff 判向 | P5 部署法：位==旧源→备份后替换；位有自有内容→就地锚定增量；位缺该 skill 目录→跳过并报告 |
| 25.3 白名单①②③ | 主进程直做的唯一合法例外：① git/worktree 编排 ② 计划文件维护 ③ 机械验证/只读回读 |
| D1=yes | 用户已在计划模式显式批准计划（user-session-log #3），执行中不二次确认 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 示例会话 150 条消息、真实用户 2 条、续推 14 轮、AskUserQuestion 9 次无应答、决策翻转 3 次、授权后零动作 | plan-brief.md:186（FR-1，ReadSession 落盘页第一手） | 病因是规则设计不是模型偷懒；必须写续推/授权/冻结条款，不能靠提示词提醒 |
| 非部署漂移：`~/.zcode` 与 `~/.agents` 相关文件与源仓逐文件 diff=0（仅 `.agents/task-planner/SKILL.md` 落后 5 行属他任务欠账） | plan-brief.md:187（FR-2） | 禁止把修复退化为「重新部署一遍」；须改源仓条款文本 |
| 升级终点全部指向问用户，共 10 处载体锚（verification:24/40、critical-rules:204、discipline:28/183/186/395、dispatch:53/225、SKILL:119/123-124/346） | plan-brief.md:188（FR-3） | 每个锚都要加 goal 分支指针（28.9⑧），漏一处即留空转出口 |
| 旧措辞全仓字面面 9 处 + SKILL.md:133「不可越权硬门例外」 | plan-brief.md:148、189（B7 第 2 行 / FR-4） | VC-1 以 grep 计数=0 为硬判据；必须逐处改，不能只改主段 |
| `TASK_PLANNER_GOAL_MODE` 全仓无写入方，goal 语境靠模型读语境判定且示例会话判定正确 | plan-brief.md:190（FR-5） | 识别不是病因；禁止新增 env 门或脚本来「修识别」 |
| 28.8 无任何 selftest 文本锚 | plan-brief.md:191（FR-6） | 禁止把修复做成新 selftest（文本优先铁律 + D-4） |
| decision-arbiter 源 frontmatter 为 `GLM-5.3 + enabled`，宿主 individual 计划仅 `GLM-5.4`/`GLM-5.3-Flash`，档位 low/high/max；运行位 11-23 已为 GLM-5.4+max | plan-brief.md:192（FR-7）；`/home/terry/.zcode/agents/decision-arbiter.md:5` model 为 GLM-5.4 | 只改源配置；S6.1 冒烟必须实派一次验证可派发 |
| 双基线分离：`verify.sh` 部署对账基线 = 23 pass / 3 fail（预存漂移 claude/opencode/cursor 三位）；selftest 基线 = 104 PASS / 0 FAIL | `baseline-verify.log:28`（23/3）；`baseline-selftest.log:105`（Total: 104 PASS=104 FAIL=0）；plan-brief.md §B4 VC-3/VC-5（审计 R1 I-1 修订） | VC-3 判据 = fresh selftest PASS=104 且 FAIL=0；VC-5 判据 = 位点计数无 MISSING 且 verify summary pass≥23/fail≤3；两基线不得混用，也不得把 23/3 误作 selftest 基线 |
| worktree 已建且干净，分支 `wt/task-goal-unattended-protocol-20261124`，基于 master `9e42c0b` | plan-brief.md:52（§A 步骤 2） | P2 在该路径写；P4 合并后必须清理 worktree 与分支（VC-4） |
| 执行体 frontmatter 模型已实测：plan-writer=sonnet-1、critic=opus-1、executor=haiku-1、general-ops=sonnet-1、decision-arbiter=GLM-5.4 | `/home/terry/.zcode/agents/<name>.md` frontmatter `model:` 行（2026-11-24 实测） | Executor 列写 `subagent_type(model)`，模型号取此处；不得降到 haiku 或自拟 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `plans/task-goal-unattended-protocol-20261124/plan-brief.md` | :5-68 | §A 已批准计划逐字：根因 6 条、方案 A-D、执行步骤 0-9、不做的事 |
| 同上 | :69-194 | §B 编码说明：B1 基本字段、B2 Goal、B3 R→VC、B4 八条 VC 判据/命令、B5 Phase/S-unit、B6 scope、B7 变更、B8 FMEA、B9 基线、B10 决策、B11 取证 |
| `plans/task-goal-unattended-protocol-20261124/task_plan.md` | :1-148 | 已批准计划视图（只读）；本轮 S1.1 不改其逐字正文，状态由主进程翻转 |
| `skills/task-discipline/references/critical-rules-discipline.md` | :28、:55、:64、:183、:186、:395 | 28.8②③ 单次降级收口句 + 5 处升级出口指针插入点；28.9 插入在 28.8 紧随处（plan-brief.md:34-35 定位，实施日须重验行号） |
| `skills/task-planner/SKILL.md` | :119、:123-124、:132-134、:136、:268、:346 | 旧措辞 132/133/136/268 + 指针 123-124/346；净增 ≤8 行，当前 469 行、钉 581（plan-brief.md:36、158） |
| `skills/task-planner/references/critical-rules.md` | :10、:134、:204 | 索引行旧措辞 + 66.2 + 109.2 goal 指针（plan-brief.md:37、148） |
| `skills/verification-gate/references/critical-rules-verification.md` | :24、:40 | 84.3⑤ / 84.5 goal 指针 + 语义保证型判据拆分条款（plan-brief.md:38） |
| `skills/verification-gate/SKILL.md` | :68、:95-99 | 终验条款同步拆分；反作弊第 9 条注明计划期拆分不属中途改判据（plan-brief.md:39、20） |
| `skills/task-dispatch/references/critical-rules-dispatch.md` | :53、:225 | retry_limit / 96.7 升级出口加 goal 指针（plan-brief.md:40） |
| `skills/task-planner/companion/agents/decision-arbiter.md` | :4-5 | 源 frontmatter `model`→GLM-5.4、`thoughtLevel`→max，description 同步 + Rule 45 What+Why 注释（plan-brief.md:44） |
| `AGENTS.md`（仓库根，未跟踪） | §2 | 新增 goal 部署预授权例外，护栏指 28.9②；主仓直接改（plan-brief.md:46、50、76） |
| `plans/task-goal-unattended-protocol-20261124/baseline-selftest.log` / `baseline-verify.log` | 全文 | 动工前 FAIL 集合快照；VC-3 与 S5.2 对比基准（plan-brief.md:50） |
| `tmp/worktrees/task-goal-unattended-protocol-20261124` | 目录 | P2-P3 隔离开发区，分支 `wt/task-goal-unattended-protocol-20261124`（plan-brief.md:52） |

## §4 易错点与禁止假设清单

1. 禁止声明新顶级 Rule 编号：28.9 是 Rule 28 子条（先例 28.8），不触发纪元级联、不占 rule-reserve（plan-brief.md:74）。
2. 禁止改 `~/.zcode/commands/goal.md`（保护区、无仓库源、非本次主因）与执行示例会话遗留待授权项（plan-brief.md:63-64、182）。
3. 禁止整槽部署：`smart-merge-back --deploy` / `install.sh` 会抹掉 claude/opencode/cursor 位自有增量；必须逐位 diff 判向 + 备份 + 精确增量（plan-brief.md:57、180）。
4. 禁止把 VC-3 读成「0 FAIL」：基线已有 3 个预存漂移，判据是 FAIL 集合相等（plan-brief.md:50、103）。
5. 禁止新增脚本/门/hook/selftest 来「强化」28.9（文本优先铁律，D-4）；禁止中途改判据（84.5 拆分必须在 attest 锁定前登记）。
6. 禁止把续推指令当用户授权：续推=差距线索；只有真实「授权」消息命中待授权清单才执行预案（plan-brief.md:28 子条③⑤⑦）。
7. 主仓 `AGENTS.md` 是未跟踪文件，不随 worktree 走；只有它经用户批准在主仓直接编辑，其余实现类改动必须在 worktree（plan-brief.md:76）。
8. 禁止凭记忆引用行号：上表锚点来自 plan-brief §A/B 记录，S2.1/S3.2 执行前必须 Read 目标区段重验。
- FMEA RPN>100 兜底指针：本任务 FMEA 六条 RPN 最大为 72（无 >100 项）；最高项「新措辞与既有条款冲突」RPN=72，兜底=critic 独立审查 + 回读互检、冲突就地修正 → `task_plan.md` FMEA 表 F1 行；次高「整文件覆盖抹掉运行位自有增量」RPN=48 → F4 行（逐位 diff 判向 + 备份）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1.1 | §1 + §2 + §3（编码口径） | `plans/task-goal-unattended-protocol-20261124/plan-brief.md`（全文，唯一内容源）；`plan-state.json`（仅经 planctl 写） |
| S1.2 | §2 + §4（审计排雷） | `plans/task-goal-unattended-protocol-20261124/task_plan.md`（已批准逐字）；`plan-brief.md` §A/§B |
| S2.1 | §3（六载体锚）+ §4（禁止假设 1/2/8） | `plans/task-goal-unattended-protocol-20261124/edit-spec.md`（逐处编辑规格）；worktree 内 6 个 skills 文件 |
| S2.2 | §3（AGENTS.md §2）+ §4（禁止假设 7） | `AGENTS.md`（仓库根，未跟踪）；`plan-brief.md:46` |
| S3.1 | §2（基线 FAIL 集合）+ §4（禁止假设 4） | `plans/task-goal-unattended-protocol-20261124/baseline-selftest.log`；`plan-brief.md` §B4 VC-1/2/3 命令 |
| S3.2 | §2（升级终点清单）+ §4（禁止假设 1/5/8） | `plan-brief.md` §A 方案 B 表 + §B7 变更标注表；6 个载体文件回读 |
| S4.1 | §2（worktree 已建且干净）+ §4（禁止假设 7） | `tmp/worktrees/task-goal-unattended-protocol-20261124`；`skills/task-planner/scripts/smart-merge-back.sh`（不带 --deploy） |
| S5.1 | §1（逐位 diff 判向）+ §4（禁止假设 3） | `plans/task-goal-unattended-protocol-20261124/pre-deploy-site-state.log`；`tmp/deploy-backups/task-goal-unattended-protocol-20261124/`；`plan-brief.md:57` |
| S5.2 | §2（verify 基线） | `plans/task-goal-unattended-protocol-20261124/baseline-verify.log`；`skills/task-planner/lib/verify.sh` |
| S6.1 | §2（decision-arbiter 源/运行位）+ §3（frontmatter 锚） | `skills/task-planner/companion/agents/decision-arbiter.md`；`~/.zcode/agents/decision-arbiter.md` |
| S6.2 | §1（28.9③⑤⑦⑧）+ §4（禁止假设 6） | `plan-brief.md:58`（§A 步骤 8）；`plans/task-goal-unattended-protocol-20261124/drill-report.md`（本 S-unit 新建） |
| S6.3 | §2（基线/取证边界） | `plans/task-goal-unattended-protocol-20261124/progress.md`（仅追加）；项目 ledger 与记忆目录；`plan-brief.md:59` |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| verification-gate | `/home/terry/.zcode/skills/verification-gate/SKILL.md` | 本任务 8 条 VC 终验与 PARTIAL 判据拆分直接落在该技能 | 子代理 prompt 挂载 / 主进程 Skill 调用（P3 终验） |
| verification-before-completion | `/home/terry/.zcode/skills/verification-before-completion/SKILL.md` | 声称完成前必须有执行/产出/验证三重证据 | 子代理 prompt 挂载（各 Phase 收尾） |
| task-discipline | `/home/terry/.zcode/skills/task-discipline/SKILL.md` | 28.9 宿主技能，本任务主改对象 | 子代理 prompt 挂载（S2.1/S3.2） |
| task-dispatch | `/home/terry/.zcode/skills/task-dispatch/SKILL.md` | 派发契约与 8 字段返回格式来源 | 主进程 Skill 调用（各派发前） |
| task-drift-guard | `/home/terry/.zcode/skills/task-drift-guard/SKILL.md` | 计划批准已锁定语义，执行期防漂移 | 主进程 Skill 调用（Phase 切换前） |
| research-assistant | `/home/terry/.zcode/skills/research-assistant/SKILL.md` | 证据边界（FR-1 宿主续推正文/提示词不可读）如需补证时的调研链 | 主进程 Skill 调用（仅补证需要时） |
| brainstorming | `/home/terry/.agents/skills/brainstorming/SKILL.md` | 条款互斥/自洽性审查的发散面 | 子代理 prompt 挂载（S3.2 可选） |
| using-superpowers | `/home/terry/.agents/skills/using-superpowers/SKILL.md` | 技能族激活总览，供执行体择用 | 用户手动触发（仅提示） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/task-goal-unattended-protocol-20261124` → 生成 knowledge/entries/_draft-task-goal-unattended-protocol-20261124.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）
