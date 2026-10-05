<!-- template_type: rule-enhancement -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、消费侧门控、selftest 守护、SKILL 联动（变体模板 rule-enhancement-type.md） -->
# Task Plan: v131 — 技能行为缺陷根源修复（流于表面/偏差/推诿/质量优先 → Rule 53 + Rule 51.1 载体 + 回填与部署收口）

<!-- plan_tier: standard | execution_lane: L1（多代理派发+worktree+部署） -->
<!-- interaction_mode: silent（/goal 自主会话，用户不可实时应答；goal 原文=显式预授权"将所有的问题彻底地从根源上解决"；D6 硬停点语义保留） -->
<!-- new_rule: 53 -->
<!-- code_review: required（改动含 .sh 脚本与技能条款） -->
<!-- worktree_path: /home/terry/task-planner-skill-worktrees/task-v131 (branch wt/task-v131) -->
<!-- session_id: afd0b28ec78a4e8ca9f0acde60eeaaf7 -->

## 🎯 用户需求原文（Rule 51.1 锚定 — 本区块=逐条抄录，禁转译）

> 来源：/goal 指令原文（语音转写原文照录，含重复与口语噪声；解释见 findings.md §Requirements，解释不替代原文）

- **R1**: 「当前技能存在严重的缺陷。执行过程中并没有，有时候解决问题多数都流于表面，并没有直指核心的彻底解决，从根源上解决问题。」
- **R2**: 「还有就是在解决问题的时候，存在严重的偏差现象。」
- **R3**: 「还有就是解决问题的时候，并恶意将就是低风险的选择推给用户，这是严重的惰性。」
- **R4**: 「记住，我需要的是将所有的问题彻底地从根源上解决。解决问题的时候，而不是只解决一基础性的问题。」
- **R5**: 「比如说我提示我要求确保产出内容质量高质量内容。但是当前的解决方案只解决一些最基础的，比如说要求标题怎么写怎么写，而没有彻底地从内容创作的流程及其他部分的缺陷进行挖掘错误。」
- **R6**: 「记住，我需要的是产出质量高于就是说解决问题的速度。任何的呃任何的返工都比要缓慢的、及时的解决要来的来的无效多。」
- **R7**: 「将将原将原本可以非常容易判断的内容恶意推给用户。」（R3 重申=权重加倍）

### R→VC 映射（51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-4, VC-9 | critical-rules.md 含 53.1/53.2 条款锚；交付含需求覆盖核对表 |
| R2 | VC-2, VC-3 | 试生成计划含需求原文区块；attest 对缺区块计划拒绝锁定（负例输出） |
| R3+R7 | VC-4, VC-9 | 53.3 决策管辖二分条款锚 + SKILL C36 消费行 |
| R4 | VC-4, VC-6 | Rule 53 全条款 + 审计 13 发现逐条处置表 |
| R5 | VC-4, VC-9 | 53.1 全链工序审计条款（结果级需求→生产管线分解→逐工序缺陷挖掘） |
| R6 | VC-4, VC-5 | 53.4 返工成本核算条款 + 全量 selftest 0 FAIL |

## Goal
从根源修复 task-planner 技能四大行为缺陷：①解决问题流于表面不挖根源（R1/R4/R5）②执行偏差/指令改写（R2）③把可自行判断的低风险决策推给用户（R3/R7）④速度优先导致返工（R6）。落地 = **Rule 53（根源解决与决策管辖）五子条 + Rule 51.1 计划侧载体双机制（init 注入 + attest 校验）+ 派发需求锚 + zcode 位领先内容回填真源 + 对齐审计 13 发现全处置 + 四部署位同步**，全量 selftest 0 FAIL 后合并 master 并部署对账。

## 核心问题定义（T2 解构 — 5 Whys 根因）
| 缺陷 | 根因链（Why×5 收敛） | 根因 |
|------|---------------------|------|
| D1 流于表面 | 只改标题→方案停在最易触达显性层→计划期无"结果级需求→全链审计"强制动作→Rule 50 只管评级不管覆盖广度、Rule 51 只管原文/声称不管解决深度→**根源覆盖无载体** | 缺 53.1/53.2 |
| D2 偏差 | 一个月→72h→执行链转译需求无拦截→计划侧无原文锚（51.1 计划侧零载体=审计 HIGH-3 实证）+派发 prompt 无需求锚→条款在、挂点无 | 缺 51.1 载体+派发锚 |
| D3 推诿 | 推给用户零成本→41.3/44.2 有"直接裁决"条款但无管辖二分硬判据→可判项包装成"待确认"不触发违规 | 缺 53.3 |
| D4 质量劣后 | 快而浅→返工成本不可见→验收深度无返工成本核算判据 | 缺 53.4 |

## 根源覆盖表（53.1 dogfood — 本任务自身工序链 × 缺陷面 × 修复点）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规划 | 计划无需求原文锚→偏差入口 | Phase 2 载体双机制 | VC-2/3 |
| 回填 | zcode 位领先真源（审计 H-1）→重装即抹产出 | Phase 1 回填 | VC-1 |
| 条款 | 四缺陷无对应纪律条款 | Phase 3 Rule 53 | VC-4 |
| 派发 | 子代理 prompt 无需求锚→转译变异 | Phase 3 派发模板锚 | VC-4 |
| 守卫 | 规则无机器守护→再漂移无告警 | Phase 4 selftest | VC-5 |
| 文档/登记面 | 审计 M/L 级缺陷（口径/死路径/锚缺失） | Phase 5/6 | VC-6 |
| 验证 | 回归深度不足→返工 | Phase 7 全量+CR+align | VC-5/8 |
| 部署 | 部署位漂移（cursor 落后 114/口径两套） | Phase 8 | VC-7 |
| 簿记 | 账本/编号/记忆滞后 | Phase 9 | VC-9 |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（重 diff：脚本+条款多文件） |
| `对齐审查` | alignment-review skill（42.6.2 全产出收尾）|
| `自动超时默认项` | 本任务 silent 模式无 2+ 选项询问点；如出现→默认项第 1 位+5 分钟超时 |
| `质量审查工具` | 检测结论：用户级 `code-reviewer` agent（CR）+ `alignment-review` skill（对齐）+ `critic`（方案挑刺，Phase 3 条款设计后一轮）|
| `interaction_mode` | silent（见 frontmatter 注释）|

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 回填后 worktree 内 3 文件（SKILL.md/critical-rules.md/selftest-skill-split.sh）与 zcode 部署位 diff=0 | `diff` 逐文件输出 | progress.md Phase 1 段 |
| VC-2 | init-session 试生成的新计划必含「🎯 用户需求原文」区块与 R→VC 映射段（tmp 目录实验，覆盖 general+rule-enhancement 两模板路径） | 生成实验 Read 输出 | progress.md Phase 2 段 |
| VC-3 | attest-plan.sh 对缺区块计划拒绝锁定（exit≠0）且对含区块计划正常（负例+正例双测；mini 档豁免口径生效） | 命令输出原文 | progress.md Phase 2 段 |
| VC-4 | Rule 53 五子条锚（53.1-53.5）+ SKILL 索引行/摘要行/C36 + 派发模板需求锚字段 + SKILL:9 全集数与 :251 索引修正（含补 Rule 50） | grep 逐锚 | references/critical-rules.md, SKILL.md, templates/ |
| VC-5 | selftest-root-resolution.sh 新建通过 + 全量 selftest 回归 Total 主进程逐脚本求和 0 FAIL | 逐脚本运行输出求和 | progress.md Selftest Log |
| VC-6 | 对齐审计 13 发现（3H+5M+5L）逐条处置表：修复/豁免+证据路径，无悬空 | 处置表逐行核对 | findings.md §审计处置表 |
| VC-7 | master 合并 + zcode/claude/opencode 位与真源 diff=0 + cursor 位重同步 diff=0 且 7 项旧遗留清理（备份先行） | diff 输出+备份清单 | progress.md Phase 8 段 |
| VC-8 | code-reviewer APPROVED + alignment-review PASS + 变更记录三要素落盘 | 审查返回原文 | plans/task-v131/ |
| VC-9 | 交付总结五要素 + 需求覆盖核对表（R1-R7 全 covered 或显式让步） | Read 交付文件 | plans/task-v131/delivery-summary.md |

**终验规则**：全部 VC 通过 → COMPLETE；任一 R uncovered → PARTIAL 并列明；证据不实 → BLOCKED。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 条款 | `references/critical-rules.md`（追加 Rule 53 + 45.7 死路径修 + Rule 16 措辞修=纯增量） | 改既有规则语义（36.4 D6） |
| 模板 | `templates/task_plan.md`、`templates/variant/rule-enhancement-type.md`（补需求原文区块）、`templates/subagent_dispatch.md`（需求锚字段） | 其余 27 variant 逐个改（由 init 注入机制兜底，见 Decisions） |
| 脚本 | `init-session.sh`、`attest-plan.sh`、新建 `selftest-root-resolution.sh`、级联 `selftest-skill-split.sh`/`selftest-requirement-coverage.sh`/`selftest-agent-coverage.sh`、`check-dispatch.sh`（注释） | 其他脚本 |
| SKILL | `SKILL.md`（Rule 53 摘要 bullet+索引修正+C36+2.5 行 Rule 52.4 括注；净增 ≤12 行） | 大段新增 |
| 文档 | ARCHITECTURE.md、INSTALL.md、install-stub.sh、detect-tools.sh、README.md（口径/数字修正） | 其他文档 |
| 部署 | 四位（zcode/claude/opencode/cursor）部署脚本同步 | 部署前未回填真源即重装（审计 H-1 红线） |

**强制约束**：新 Rule 编号=53（账本 next）；合规清单接续 C36；锚级联前 `grep -rn "Rules 1-\|≤461\|≤475\|1-51\|1-52" scripts/` 全扫一次修齐；派发契约=九字段+8 字段返回标签+检查点路径；SKILL 行数阈值级联同步上调+label 注明 task-v131。

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| 1 | 主进程 git 编排 + executor(sonnet-1) | worktree=白名单①；cp 回填=委派 |
| 2-6 | executor(sonnet-1) ×逐 S-unit | 条款/脚本/模板判断型编辑 |
| 7 | code-runner-agent(mini) + code-reviewer(sonnet-1) + alignment-review skill | 回归/审查分工 |
| 8 | 主进程 + smart-merge-back --deploy | git/部署编排白名单① |
| 9 | 主进程 | 计划簿记白名单② |

## 🔀 隔离决策
check-conflicts：仅信号①（14 个未提交 plans/ 簿记文件，与本任务 scope skills/task-planner/** 零重叠，不阻塞）。**决策：worktree 隔离**（宪法 §十一 11.1：技能文件+多会话并行环境；路径=/home/terry/task-planner-skill-worktrees/task-v131，分支 wt/task-v131）。计划三文件留主仓 plans/task-v131/。

## Phases

### Phase 1: worktree 建立 + zcode 位领先内容回填真源（审计 H-1 红线先行）
- **Status:** complete（commit 92cab23；VC-1 证据=progress.md Phase 1 段）
- 主进程建 worktree（白名单①）；S-unit 执行在 worktree 内，绝对路径派发
- **Executor:** executor(sonnet-1)（worktree 建立=白名单① git 编排，由会话主控先行完成）
- S-unit 表：
| ID | 内容 | 文件（worktree 相对） | 执行体 |
|----|------|----------------------|--------|
| S1 | 回填 SKILL.md + scripts/selftest-skill-split.sh（cp 部署位→真源，SKILL 461→475 行） | skills/task-planner/SKILL.md, scripts/selftest-skill-split.sh | executor(sonnet-1) |
| S2 | 回填 references/critical-rules.md（567→574：21.4.1+23.9-23.13） | skills/task-planner/references/critical-rules.md | executor(sonnet-1) |
| S3 | diff=0 验证 + git commit（message 注明 task-v130 回填） | （验证+git） | executor(sonnet-1) |
- [x] V-1.1: VC-1（证据=progress.md Phase 1 段）
- [x] V-1.2: VC-9（证据=progress.md Phase 1 段）

### Phase 2: Rule 51.1 计划侧载体双机制（偏差根修 D2）
- **Status:** complete（commit 9924b0a；VC-2/VC-3 证据=progress.md Phase 2 段）
- 机制设计：① init-session.sh 生成时注入「🎯 用户需求原文」区块（任何模板生成的新计划必含，mini 档豁免）② attest-plan.sh 锁定时校验区块在位+≥1 条 R 行+R→VC 映射段（非 mini；缺=拒锁）③ 主模板+rule-enhancement 变体补可见区块
- **Executor:** executor(sonnet-1)
- S-unit 表：
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | templates/task_plan.md + templates/variant/rule-enhancement-type.md 补区块（R 行+映射段+根源覆盖表段） | 2 模板文件 | executor(sonnet-1) |
| S2 | scripts/init-session.sh 注入逻辑（copy 后若无区块则插入；mini 豁免；fail-open） | scripts/init-session.sh | executor(sonnet-1) |
| S3 | scripts/attest-plan.sh 校验（正例/负例双测：tmp 构造缺区块计划 exit≠0） | scripts/attest-plan.sh | executor(sonnet-1) |
- [x] V-2.1: VC-2（证据=progress.md Phase 2 段）
- [x] V-2.2: VC-3（证据=progress.md Phase 2 段）

### Phase 3: Rule 53 条款 + SKILL 联动 + 派发需求锚（D1/D3/D4 根修）
- **Status:** complete（commit 535be31；critic CHANGES_REQUESTED→当轮吸收闭环；VC-4 证据=progress.md Phase 3 段）
- Rule 53（根源解决与决策管辖）：53.1 结果级需求全链工序审计（含判例反例=用户 R5 原文）；53.2 根治判据（修复须给出"同类问题如何被系统性阻止"——机制/守卫/载体三选一，纯症状修补=Rule 26 回炉）；53.3 决策管辖二分（代理可判=可逆/有判据/信息在手/范围内→必须裁决+Decisions 登记；用户专属=G1-G4+真实偏好；推诿=惰性违规挂 Rule 26）；53.4 返工成本核算（验收深度覆盖根治判据；返工期望成本>彻底增量成本时禁选浅路径）；53.5 机制（零新 config 键+selftest-root-resolution.sh+C36）
- **Executor:** executor(sonnet-1)；条款草案后加一轮 critic(sonnet-1) 挑刺（独立视角）
- S-unit 表：
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | critical-rules.md：Rule 53 块 + 51.1 追加"载体双机制+派发锚"纯增量子句 + 45.7 死路径修正 + Rule 16"全部模板"措辞修正 | references/critical-rules.md | executor(sonnet-1) |
| S2 | SKILL.md：Rule 53 摘要 bullet + 索引行补 Rule 50（:251）+ 全集 1-51→1-53（:9）+ C36 行 + 执行循环 2.5 行 Rule 52.4 括注（审计 M-4） | SKILL.md | executor(sonnet-1) |
| S3 | templates/subagent_dispatch.md：§需求锚 字段（治理 R 条目逐字引用，禁转译——直击一个月→72h 变异路径） | templates/subagent_dispatch.md | executor(sonnet-1) |
| S4 | critic 挑刺（条款可绕过性/表述歧义/与 26/41/44/50/51 边界冲突），结论回 findings | （只读+findings 落盘） | critic(sonnet-1) |
- [x] V-3.1: VC-4（证据=progress.md Phase 3 段）
- [x] V-3.2: VC-9（证据=progress.md Phase 3 段）

### Phase 4: 守卫与锚级联（防再漂移）
- **Status:** complete（commit 75e717c；三 selftest 全绿；VC-5 部分证据=progress.md Phase 4 段）
- **Executor:** executor(sonnet-1)
- S-unit 表：
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | 新建 scripts/selftest-root-resolution.sh：53.x 条款锚+SKILL C36/索引锚+51.1 载体锚（init/attest/模板）+派发锚+负断言 | scripts/selftest-root-resolution.sh | executor(sonnet-1) |
| S2 | selftest-skill-split.sh 行数阈值级联（475→实际新行数，label 注 task-v131）+ 全锚扫描 | scripts/selftest-skill-split.sh | executor(sonnet-1) |
| S3 | selftest-requirement-coverage.sh RC-15 类断言 ^53 演进 + 新载体断言 | scripts/selftest-requirement-coverage.sh | executor(sonnet-1) |
- [x] V-4.1: VC-5（部分）（证据=progress.md Phase 4 段）
- [x] V-4.2: VC-9（证据=progress.md Phase 4 段）

### Phase 5: 部署文档与路径口径清账（审计 M-1/L-5）
- **Status:** complete（VC-6 部分证据=progress.md Phase 5 段）
- **Executor:** executor(sonnet-1)
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | INSTALL.md 薄壳口径→实盘全量副本口径修正 | INSTALL.md | executor(sonnet-1) |
| S2 | install-stub.sh 口径注释同步 | install-stub.sh | executor(sonnet-1) |
| S3 | detect-tools.sh + README.md opencode 物理路径 ~/.config/opencode/skills/task-planner 修正 | detect-tools.sh, README.md | executor(sonnet-1) |
- [x] V-5.1: VC-6（部分）（证据=progress.md Phase 5 段）
- [x] V-5.2: VC-9（证据=progress.md Phase 5 段）

### Phase 6: 结构与脚本小修（审计 L-1/L-3）
- **Status:** complete（VC-6 部分证据=progress.md Phase 6 段）
- **Executor:** executor(sonnet-1)
| ID | 内容 | 文件 | 执行体 |
|----|------|------|--------|
| S1 | ARCHITECTURE.md 结构数字与目录树更新（references 9/scripts 89/templates 10+29） | ARCHITECTURE.md | executor(sonnet-1) |
| S2 | check-dispatch.sh :71-72 SKILL_ROOT 语义注释修正（实指 scripts/ 目录） | scripts/check-dispatch.sh | executor(sonnet-1) |
| S3 | selftest-agent-coverage.sh 增 agent-coverage.md 行数锚（对称守护） | scripts/selftest-agent-coverage.sh | executor(sonnet-1) |
- [x] V-6.1: VC-6（部分）（证据=progress.md Phase 6 段）
- [x] V-6.2: VC-9（证据=progress.md Phase 6 段）

### Phase 7: 全量回归 + CR Gate + 对齐审查
- **Status:** complete（VC-5=770/0 主进程求和；VC-8=CR APPROVED+ALIGN APPROVED）
- **Executor:** executor(sonnet-1)+code-reviewer(sonnet-1)+executor(sonnet-1)（回归跑批+CR 两轮+CR 修复批+alignment 执行体；求和复核=主进程白名单③机械验证）
- [x] V-7.1: VC-5（证据=progress.md Phase 7 段）
- [x] V-7.2: VC-8（证据=progress.md Phase 7 段）

### Phase 8: 合并回 master + 四位部署同步
- **Status:** complete（merge 17a06cf；四位 IDENTICAL；worktree 已清理；VC-7 证据=progress.md Phase 8 段）
<!-- merge_back=merged(17a06cf) -->
- 前置：VC-1..6/8 复验通过；主仓 scope 无重叠未提交变更
- 主进程：smart-merge-back.sh --deploy（合并+部署对账）；cursor 位全量重同步+7 项旧遗留清理（**备份先行** tar → ~/skill-deploy-backups-*）；部署位 selftest 抽验
- **Executor:** 主进程（白名单①git/部署编排）
- [x] V-8.1: VC-7（证据=progress.md Phase 8 段）
- [x] V-8.2: VC-9（证据=progress.md Phase 8 段）

### Phase 9: 簿记与交付
- **Status:** complete（VC-9=delivery-summary.md 五要素+R1-R7 全 covered）
- rule-reserve.sh land 53；INDEX/sync-todos；memory 更新（align-audit 状态+本次规则）；delivery-summary 五要素+需求覆盖核对表；check-complete.sh
- **Executor:** 主进程（白名单②）
- [x] V-9.1: VC-9（证据=progress.md Phase 9 段）
- [x] V-9.2: VC-9（证据=progress.md Phase 9 段）

## 📊 FMEA 预演（RPN>100 必有兜底）
| ID | 风险 | 概率 | 影响 | 检测性 | RPN | 兜底动作 |
|----|------|------|------|--------|-----|----------|
| F1 | 部署覆盖致 zcode 位半残 | 4 | 8 | 5 | 160 | 回填先行（真源⊇部署位）+位备份 tar+部署后 selftest 抽验 |
| F2 | 锚级联漏改→回归 FAIL（历史第 3 次教训） | 6 | 6 | 4 | 144 | Phase 4 全 grep 扫锚+全量回归门 |
| F3 | attest 新校验误伤在途计划 | 5 | 6 | 4 | 120 | 仅锁定时点生效+mini 豁免+正负例双测 |
| F4 | critic 挑刺触发条款返工 | 6 | 5 | 3 | 90 | Phase 3 内吸收一轮；超限登记 deferred |

## Decisions Made
| 时间 | 决策 | 依据 |
|------|------|------|
| 10-05 | silent: interaction_mode=silent | /goal 自主会话，goal 原文=预授权 |
| 10-05 | silent: 载体=init 注入+attest 校验双机制，非 30 模板逐个补块 | 生成面单点全覆盖 29 variant（根源），写入最小化；主模板+rule-enhancement 变体补可见区块（2 文件） |
| 10-05 | silent: Rule 53 零新 config 键 | v126+ 全部近例先例（49-52 均零键） |
| 10-05 | silent: 编号 53 | 账本 next=53，无占用 |
| 10-05 | silent: cursor 位清理前 tar 备份 | 破坏性可恢复化 |
| 10-05 | silent: 计划文档主进程撰写 | 白名单②；设计上下文已在主进程，转译给 plan-writer 反引入 D2 风险 |

## 🔗 Subagent Handoff 登记表
| 时间 | subagent_type | 目标 | 状态 | findings 落点 | checkpoint | verify_done |
|------|--------------|------|------|--------------|-----------|-------------|
| 10-05 06:0x | executor | 回填 SKILL.md+selftest-skill-split.sh（P1） | complete | §Research Findings 回填锚 | subagent-state/01-executor.md | ✅ |
| 10-05 06:1x | executor | 回填 critical-rules.md（P1） | complete | §Research Findings 回填锚 | subagent-state/02-executor.md | ✅ |
| 10-05 06:2x | executor | 3 对终验+commit 92cab23（P1） | complete | 同上 | subagent-state/03-executor.md | ✅ |
| 10-05 06:3x | executor | 模板补需求原文区块（P2） | complete | §审计处置表 H-3 行 | subagent-state/04-executor.md | ✅ |
| 10-05 06:4x | executor | init 注入机制（P2） | complete | 同上 | subagent-state/05-executor.md | ✅ |
| 10-05 06:5x | executor | attest 51.1 三锚门（P2） | complete | 同上 | subagent-state/06-executor.md | ✅ |
| 10-05 07:1x | executor | Rule 53+51.1a+45.7+Rule16 落盘（P3） | complete | §审计处置表 M-2/3/5+L-2 行 | subagent-state/07-executor.md | ✅ |
| 10-05 07:3x | executor | SKILL 六锚联动（P3） | complete | 同上 M-3/M-4 行 | subagent-state/08-executor.md | ✅ |
| 10-05 07:4x | executor | 派发锚+覆盖表脚手架（P3） | complete | §Technical Decisions | subagent-state/09-executor.md | ✅ |
| 10-05 07:5x | critic | Rule 53 五维挑刺 | complete | §Issues（CHANGES_REQUESTED 全文在 10-critic.md） | subagent-state/10-critic.md | ✅ |
| 10-05 08:0x | executor | P0/P1 吸收修订-条款（P3） | complete | 同上 | subagent-state/11-executor.md | ✅ |
| 10-05 08:1x | executor | P0/P1 吸收修订-四锚门（P3） | complete | 同上 | subagent-state/12-executor.md | ✅ |
| 10-05 08:3x | executor | selftest-root-resolution 新建+RR-14 修正（P4） | complete | §Issues 裁定记录 | subagent-state/13,14-executor.md | ✅ |
| 10-05 08:5x | executor | skill-split 阈值 477 级联（P4） | complete | 同上 | subagent-state/15-executor.md | ✅ |
| 10-05 08:5x | executor | RC-15 ^54 演进（P4） | complete | 同上 | subagent-state/16-executor.md | ✅ |
| 10-05 08:5x | executor | INSTALL 口径（P5） | complete | §审计处置表 M-1 行 | subagent-state/17-executor.md | ✅ |
| 10-05 09:0x | executor | install-stub 口径（P5） | complete | 同上 | subagent-state/18-executor.md | ✅ |
| 10-05 09:1x | executor | opencode 路径（P5） | complete | 同上 L-5 行 | subagent-state/19-executor.md | ✅ |
| 10-05 09:2x | executor | ARCHITECTURE+INSTALL 残留（P6） | complete | §审计处置表 L-4 行 | subagent-state/20-executor.md | ✅ |
| 10-05 09:4x | executor | check-dispatch advisory+模板对齐（P6） | complete | 同上 L-1 行+§Issues P1-4 | subagent-state/21-executor.md | ✅ |
| 10-05 09:5x | executor | AC-09 行数锚（P6） | complete | 同上 L-3 行 | subagent-state/22-executor.md | ✅ |
| 10-05 10:1x | executor | 全量回归跑批+根因定位（P7） | complete | §Issues 根因 A/B | subagent-state/23-executor.md | ✅ |
| 10-05 10:3x | executor | 夹具清账 A/B 批（P7） | complete | 同上 | subagent-state/24,25-executor.md | ✅ |
| 10-05 10:5x | code-reviewer | CR Gate 两轮（P7） | complete | §Issues CR 段 | subagent-state/26-code-reviewer.md | ✅ |
| 10-05 11:1x | executor | CR 修复 A/B 批+级联微修（P7） | complete | 同上 | subagent-state/27,28,29-executor.md | ✅ |
| 10-05 11:3x | executor | alignment-review（P7） | complete | §审计处置表+30 检查点 | subagent-state/30-executor.md | ✅ |

## Errors
| 时间 | 错误 | 处置 | Root Cause |
|--------|------|------|------------|
| 10-05 12:05 | registry tsv 编辑误增 tab（NF=5→T02/T03/T05 FAIL，部署位同步了坏行） | git 原行断言式重建（tabs=3）+修正提交+四位重同步+registry 5/5 恢复 | Edit 工具手打整行无法保真 tab 结构；修法=以 git 原行为基准做受断言保护的最小替换 |
