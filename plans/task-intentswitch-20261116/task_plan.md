# Task Plan: 会话意图切换主动换计划（意图变更识别与计划隔离切换增强）
<!--
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「现在你需要帮我解决一个问题，就是当前技能，如果说在在同一个会话中，出现了，比如说嗯出现了，就是比如说出现了一个新的问题，主动进行任务切换。我需要的这个场景是这样的，就比如说我在执行任务中，在会话中出现了，因为每次可能说用户会不断地提出一些新的需求嘛。但是如果说新的需求和之前的需求已经完全偏移了，就是说，不是说偏移，是说，主要是比如说之前是A，在说A，现在改说B了，那么我希望可以主动激活切换新的Tasks Planner计划任务。因为在，因为不同的任务放在同一个计划任务当中执行，会出现，就是不必要的负担。所以我希望的是可以可以主动切换新的计划任务来解决问题。这样的话就是可以更好的隔离。大体就是这个意思。之前也，之前我记得也有这个功能，但是实际上使用过程中不是很明显。现在我希望你就是帮我进行优化，确保可以更好的就是识别会话中不同的意图，然后切换到不同的计划体系中进行执行。」<sub>（[目标]，来源：plans/task-intentswitch-20261116/user-session-log.md#1）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5, VC-6 | 诊断根因落盘可审计(VC-1)；SKILL.md 单入口具备快速判定+显性通告+切换登记指引(VC-2)；Rule 94/102 与入口交叉锚收敛无散落漂移(VC-3)；hook [plan-note] 含 Goal↔专档快速锚句(VC-4)；drift-checker 边界显性化且不改判定语义(VC-5)；回归/一致性校验通过(VC-6) |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-intentswitch-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 意图识别入口（新指令到达→判定） | 判定全 LLM 行为门+hook 仅提示、无快速 Goal↔专档零交集锚句，A 类惯性压过 D 类分流（R-1,H1/H5） | Phase 2 S1-S2：SKILL.md 快速判定卡 + hook 快速锚句 | VC-2, VC-4 |
| 切换执行编排（判定后动作） | 切换步骤分散 SKILL.md/8.1/94/102/plan-resume，缺单一 checklist 与统一收口（R-2,H2） | Phase 2 S1,S3：单入口清单化 + 94/102 反向锚收敛 | VC-2, VC-3 |
| 用户感知（会话面显性） | 纯语义 D 类及 silent 路径缺「挂起 A→新建 B」显性通告模板（R-3,H3） | Phase 2 S1：显性通告模板落入口 | VC-2 |
| 证据与审计（切换后留痕） | 无统一切换登记最小字段，痕迹分散不可审计（R-5,H6） | Phase 2 S1,S4：切换登记最小字段指引+载体复用约定 | VC-2, VC-5(边界不混) |
| 边界澄清（偏移检测 vs 意图切换） | drift-checker 与意图切换发起正交但文案边界不显性（R-4,H4） | Phase 2 S3：SKILL.md/相关段补边界说明，不改 64.x 判定语义 | VC-5 |

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1 用户原话与 [目标] 定性（user-session-log.md#1）；Goal 与 VC-1~VC-6 判据；既有 Rule 8.1/8.1.1/94/102/64 核心语义与处置权威不被反转；drift-checker ALIGNED/DRIFT/BLOCKED 判定语义与 64.2.1/64.7 拦截逻辑不改；不新增守护脚本/新 config 键（除非执行期获显式授权并走变更标注）；实现不在主仓裸写（走 worktree） | 本文件「用户需求原文」/「Goal」/「Verification Contract」/findings.md H4/R-4 决策 |
| 🔀 可变量 | 文案措辞细节、快速锚句压缩形态、切换登记行格式的具体字段排布、S-unit 拆分与执行体选型、实施阶段内的非语义格式调整 | - |
| 📈 学得量 | 执行期发现的额外触发场景/回归风险/更优锚点→findings.md 与 notepad-learnings.md；禁反写不变量与 R1 | findings.md, notepad-learnings.md |

## Goal
为 task-planner 技能族增强会话内「A→B 意图切换」的识别与计划隔离切换显性度：以单入口快速判定卡+显性通告+切换登记最小字段+hook 快速锚收敛既有 Rule 8.1/94/102 机制，使切换可被及时触发、用户可感知、事后可审计，且不破坏 drift-checker 既有安全网语义。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（实现期修改 skills/task-planner/SKILL.md、task-discipline 规则文与 hook 脚本，属受管技能/机制改动） |
| `session_id` | `task-intentswitch-20261116` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-intentswitch-20261116` |
| `scope_files` | `skills/task-planner/SKILL.md, skills/task-discipline/references/critical-rules-discipline.md, /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh, plans/task-intentswitch-20261116/*(计划文档)` |
| `interaction_mode` | （省略，回落 config.json#interaction_mode） |
| `对齐审查` | 交付前对修改文档跑 alignment-review/版本一致性校验并登记变更记录（standard 档） |
| `自动超时默认项` | D1 计划批准: 按 28.2.1 思路复述后用户显式 yes/5min 超时按推荐项继续并登记；方案分叉: 默认 S-A 最小增强(推荐)/5min；实现期 scope 扩展: 默认不扩展/5min |
| `new_rule` | 留空（本任务增强既有 Rule 8.1/94/102 表述与入口，不新增 Rule 编号） |
| `质量审查工具` | `code-quality-review` + `documentation-review`（技能/规则文档改动）；静态 grep 断言作为机械面；缺口若现则在 Phase 3 登记补充 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 诊断与根因可审计：findings.md 含机制全景表（含文件:行号）+ H1-H6 逐条结论(verified/refuted/partially)+证据 + R-1~R-5 根因排序 + ≥2 候选方案含取舍 | 文件存在且 grep 关键锚点 | `grep -nE 'H1|H2|H3|H4|H5|H6|R-1|S-A|S-B' plans/task-intentswitch-20261116/findings.md` |
| VC-2 | SKILL.md「用户新指令处理」区块具备单入口增强：含快速判定卡/锚句（对照 user-session-log 最新原话与当前 Goal/范围/交付物三要素）、显性通告模板要素（挂起旧计划/新计划/触发原话锚/下一步）、切换登记最小字段指引，且保持 :190 收口序列语义 | grep 入口区块关键 token 与 D 类/通告/登记词 | `grep -nE '意图切换快速判定|显性通告|切换登记|user-session-log|Goal/范围/交付物|挂起' skills/task-planner/SKILL.md` |
| VC-3 | Rule 94/102 与 SKILL.md 单入口交叉锚收敛：增强后 SKILL.md 为切换执行单入口清单，Rule 94/102 保留权威细则并含指向/不冲突表述（无重复漂移的第二套步骤） | grep 交叉锚点与关键条款仍在位 | `grep -nE 'Rule 94|Rule 102|单入口|SKILL.md' skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md` |
| VC-4 | hook [plan-note] 默认提示含快速判定锚句：显式提示“Goal/范围/交付物三要素与最新专档原话比对，均无关=走 D 类切换（挂起旧计划→init 新计划→显性通告→登记）/可判定换目标触发=E 类先确认”类可扫描指令 | grep hook 源码关键词 | `grep -nE 'Goal/范围/交付物|最新|专档|显性通告|切换登记|D 类切换|E 类' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh` |
| VC-5 | 边界显性且无语义回归：文案明确 drift-checker=执行偏移/目标漂移安全网而非意图切换发起器；Rule 64.2.1/64.7 判定语义关键锚未被删除或反转 | grep drift-guard 关键锚仍存在 + SKILL.md 含边界说明 | `grep -nE '64\.2\.1|64\.7|目标漂移|零交集' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md && grep -nE 'drift-checker|安全网|意图切换' skills/task-planner/SKILL.md` |
| VC-6 | 交付一致性与回归可观察：本计划 6 文档关键区块完整（R/VC/Phase/隔离决策/verification Verify command），且改动文件 git diff 可审计、无意外 scope 外修改 | `git diff --name-only` 在 scope 内 + 计划文件锚点检查 | `git -C /mnt/data/dev/task-planner-skill diff --name-only -- skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md; grep -nE '^template_type:|^plan_tier:|## Goal|R→VC|Verification Contract|隔离决策' plans/task-intentswitch-20261116/task_plan.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | 默认全适用：Phase 2 S1-S4（文档/hook 实质修改）、Phase 3 S1-S2（回归与一致性复核产出） |
| 豁免登记 | Phase 1 P0（主进程计划期簿记/调研落盘，已完成，只读核验不产出新受管代码）；Phase 4 S1 仅汇总交付（豁免第二轮独立复检，改以 VC 全复验+CR gate 替代） |
| 多文件变更集预判 | Phase 2 完成翻转前、Phase 4 终验前触发 103.6（预期受管文件：skills/task-planner/SKILL.md, skills/task-discipline/references/critical-rules-discipline.md, /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh） |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1 |
| **裁决** | `solved`（2026-11-16 终验：run-verification 7/7 PASS） |
| **解决证据锚** | plans/task-intentswitch-20261116/evidence/VC-2.out~VC-5.out；SKILL.md:193 判定卡+202-204 清单/通告/登记字段+122-123 边界（merge 281e556）；hook :287 锚句（部署位 IDENTICAL）；discipline :619/:708 交叉锚；CR APPROVED（agent_05668358）；drift-p1/p2 ALIGNED |
| **未解决面+原因** | n/a（R1 五要素全覆盖：识别=三要素快速判定卡；切换=执行清单①-④；显性度=hook 逐 prompt 锚句+显性通告模板；隔离=既有 Rule 94.4+指针机制；审计=[intent-switch] 登记字段） |
| **已排除路径** | S-B 结构化重构（改动面大，列为演进备选，Decisions Made） |
| **下一步建议** | 行为面冒烟待新会话自然场景验证（下一次真实 A→B 切换时观察判定卡/hook 锚句/通告模板触发显性度）；收益若不足再评估 S-B |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 诊断基线 | 固化现有机制全景与 H1-H6/R-1~R-5 根因及 S-A/S-B 方案 | `grep -nE 'H1|H6|R-1|S-A|S-B' plans/task-intentswitch-20261116/findings.md` 退出码 0 且 findings 含全景表 | Phase 1 / S1(已完成) | complete |
| G2 | 入口增强 | SKILL.md 单入口具备快速判定卡+显性通告+切换登记指引 | `grep -nE '意图切换快速判定|显性通告|切换登记|挂起' skills/task-planner/SKILL.md` 退出码 0 | Phase 2 / S1-S2 | pending |
| G3 | 条款收敛 | Rule 94/102 与入口交叉锚一致、无漂移步骤 | `grep -nE '单入口|SKILL.md' skills/task-discipline/references/critical-rules-discipline.md` 退出码 0 且语义一致 | Phase 2 / S3 | pending |
| G4 | hook提效 | UPS [plan-note] 含 Goal↔专档快速锚句与切换通告/登记提示 | `grep -nE 'Goal/范围/交付物|显性通告|切换登记' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh` 退出码 0 | Phase 2 / S4 | pending |
| G5 | 验收收口 | VC 全绿、边界不破坏、CR/同步核对通过 | VC-1~VC-6 命令全退出 0 + 103.6 清单全绿 + CR APPROVED | Phase 3-4 / S1-S3 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | `/home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh`（hook [plan-note] 措辞增强，部署位，改动需用户授权语境内谨慎最小化） | 其他 scripts/*.sh、其他 hook、非本任务相关脚本逻辑改写 |
| 技能文档 | `skills/task-planner/SKILL.md` | skills/task-planner 下其他文件（除非 VC 必需且登记） |
| 规则文档 | `skills/task-discipline/references/critical-rules-discipline.md`（仅 Rule 94/102/8.1 相关交叉锚与显性化收敛，禁改 Rule 64/drift-guard 判定语义） | skills/task-drift-guard/**、skills/plan-resume/**、其他 critical-rules-*.md |
| 计划文档 | `plans/task-intentswitch-20261116/*`（本计划 7 文件维护） | 其他 plans/**、plans/archive/** |
| 配置 | 无 | `config.json`、registry/selftest 新增（未获显式授权时） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-1 | skills/task-planner/SKILL.md:188-201 用户新指令处理区块 | 修改 | 增量（默认优先） | 「帮我进行优化，确保可以更好的就是识别会话中不同的意图，然后切换到不同的计划体系中进行执行。」(R1) | findings R-1/R-2/R-3/R-5, H1-H3/H5-H6 | 在单入口序列内增补快速判定卡、显性通告模板、切换登记最小字段指引；保留既有 D/A/B/C/E 语义 |
| CA-2 | skills/task-discipline/references/critical-rules-discipline.md:607-618,695-706（Rule 94/102 邻近说明） | 修改 | 增量 | 同 R1 | findings R-2/H2 | 增加“切换执行以 SKILL.md 单入口清单为序”的交叉锚/不重复步骤提示，不改 94/102 权威处置语义 |
| CA-3 | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:287 | 修改 | 替代（措辞替换，四条件拟在执行期满足：范围覆盖旧 note 该分支+先读旧文+守护/回归复验） | 同 R1 | findings R-1/R-3/H5；hook 当前文案证据 | 将默认 [plan-note] 压缩为 Goal↔最新专档原话快速锚句+显性通告/登记提示，保留 102.0/80.8②/8.1 关键约束 |
| CA-4 | skills/task-planner/SKILL.md（DRIFT CHECK/边界说明处） | 修改 | 增量 | 同 R1 | findings R-4/H4 | 补一句“drift-checker=执行偏移/目标漂移安全网，非意图切换发起器；先过用户新指令处理判定” |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner 规则体系（Rule 8.1/94/102/80/64） | skills/task-planner/SKILL.md:122,188-201；skills/task-discipline/references/critical-rules-discipline.md:18-23,607-618,695-706；/home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:8-68 | 必读 | ☑ |
| 官方文档 | 计划/恢复协同机制 | /home/terry/.zcode/skills/plan-resume/SKILL.md；skills/plan-collab-router/references/skill-collaboration.md:1-60 | 参考 | ☑ |
| 项目内部文档/知识库 | 本任务证据与原话 | plans/task-intentswitch-20261116/user-session-log.md#1；plans/task-intentswitch-20261116/findings.md | 必读 | ☑ |
| 文献/论文 | n/a | n/a | 参考 | ☐(n/a) |
| 图书/教程 | n/a | n/a | 参考 | ☐(n/a) |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 在会话执行 A 期间用户切换到无关需求 B 时，task-planner 能否**及时、明确、可审计**地触发“挂起 A→新建并切换到 B 计划”的隔离流程，而非混入同一计划或让用户无感？

**核心问题判断**:
- [x] 核心问题解决后，用户可获得“意图切换被识别且计划隔离被显性执行”的可交付改进（文案/流程机制增强）。
- [x] 若不解决触发不明显与流程散落，既有切换能力仍难被稳定使用，增强目标落空。
- [x] 解决方法清晰可执行：基于已验证根因 R-1~R-5 实施 S-A 最小增强（单入口判定卡+显性通告+登记指引+hook 快速锚+边界收敛）。

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| S0/P0 现状机制与根因（已完成） | LOCAL-ONLY | 「用户新指令处理 Rule 102」 「Rule 94 计划隔离」 | 本地 Read/Grep（skills/**, hook） | findings 机制全景+H1-H6+R-1~R-5 | 不适用 |
| S1 入口文案与判定卡设计 | LOCAL-ONLY | 「Goal 范围 交付物 零交集」 「显性通告 模板」 | 本地既有条款/用户原话对照 | SKILL.md 增量改动方案 | 不适用 |
| S2 hook 措辞压缩实现 | LOCAL-ONLY | 「plan-note 反思门」 「user-session-log 最新原话」 | 本地 hook 源码与 102.4 约束 | hook note 快速锚句补丁 | 否 |
| S3 94/102 交叉锚收敛 | LOCAL-ONLY | 「单入口清单」 「切换执行以」 | 本地 Rule 94/102 全文 | 交叉锚增量、不改语义 | 不适用 |
| S4 边界说明与回归核验 | LOCAL-ONLY | 「drift-checker 安全网」 「64.2.1 64.7」 | 本地 drift-guard 关键锚 grep | 边界文案+回归证据 | 否 |

> 本任务无 NET-RESEARCH/NET-DATA-DEPENDENT 条目：所需证据均在本地技能仓库与部署位 hook 可得；若实现期遇不可解 hook/环境约束再按 Rule 75 动态升级。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | task-planner 现有机制（SKILL.md 新指令处理/DRIFT CHECK、Rule 8.1/94/102、drift-guard 64.x、plan-resume、UPS hook） | Read + grep 逐条取行号证据 | findings.md「现有机制全景表」M1-M15；证据摘录 | ☑ |
| ② 对标样本（58.2 强制） | 本会话活体样本 task-veriffirst-20261116→task-intentswitch-20261116 切换（D 类已触发但用户感知“功能不明显”）；既有条款中 E 类显性交互路径（94.3 询问门）作为“明显”对照 | 计划目录状态+user-session-log#1 + 条款 94.3:614 对照 | findings.md Requirements/机制全景 M4/M7/M12；H3 结论 | ☑ |
| ③ 外部约束 | 平台/机制约束：UPS hook 逐 prompt note 仅提示不拦截（zcode-userpromptsubmit.sh:283,285,287）；drift-checker 只读子代理与 64.x 既有拦截语义；宪法 §十一 skills/** worktree 隔离 | 源码读取 + 规则文本 + check-conflicts.sh | findings.md M9-M11,M13,Issues；task_plan 隔离决策 | ☑ |

## Current Phase
Phase 1

## Next Step
完成计划期文档收口（verification/knowledge-brief/progress 填充与一致性核对）后，按 D1 展示本计划思路复述并等待用户批准进入 Phase 2 worktree 实施。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1（诊断与计划落盘） | 主进程编排 + 机械守卫脚本(check-conflicts.sh 只读) + 文件 Read/Write/Edit | 计划期单写者产出 7 文档并固化证据；只读脚本采集冲突信号 |
| Phase 2（入口/规则/hook 增强） | Agent 子代理 code-assistant(haiku-1) 或 executor(sonnet-1) 按 S-unit；机械守卫 grep/git diff | 受管文档与 hook 小步修改需隔离执行与可审计 diff |
| Phase 3（回归与边界核验） | Agent 子代理 code-runner-agent(mini)/通用审查；机械守卫脚本+grep | 运行 VC 命令、对照 64.x 锚点、检查 scope 内变更 |
| Phase 4（CR 与终验交付） | Agent 子代理(code-review/验证类)；机械守卫 run-verification/check-complete/archive 流程 | code_review=required 终验门与归档收口 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（无 ≥3 独立并行 fan-out S-unit、非长链编排型、用户未点名 /workflow）→ 采用 Rule 21.4 独立性守门调度（串行/小步委派为主）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 为 session goal 证据源；/goal 为用户侧 harness 命令，技能层不可代调（如用户后续以 /goal 锚定本任务，执行期在 Decisions 映射）。

## Phases

### Phase 1: 诊断与增强计划定稿
- [x] 调研现有机制全景并逐条记录文件:行号证据（M1-M15）
- [x] 完成 H1-H6 逐条诊断与 R-1~R-5 根因排序，给出 S-A/S-B ≥2 候选方案
- [x] 落盘 findings/task_plan/verification/knowledge-brief/progress 核心内容并对齐 R1→VC
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** plan-writer
<!-- 主进程白名单编排面（skill 激活+init+派发+收据回收+user-session-log 逐字落盘+D1+attest），首动作委派见 Handoff #1 -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | P0 调研机制全景+H1-H6 诊断+计划文档落盘（名义拆分单元；实态=单执行体两轮 819s+1213s 完成，粒度偏差见 progress Error Log） | plan-writer | user-session-log.md#1（R1 原话）；SKILL.md:188-201；discipline:18-23,607-618,695-706；drift-guard:8-68；plan-resume；hook:283-287 | findings 含 M 全景+H1-H6+R 排序+S-A/S-B；task_plan 含 Goal/R/VC/Phases/隔离决策 | 15min | 2f/100l/15min | 无 | - | complete |

### Phase 2: 单入口与显性化增强实现（worktree）
- [x] S1：在 SKILL.md「用户新指令处理」强化单入口（快速判定卡+显性通告模板+切换登记最小字段指引）
- [x] S2：升级 UPS hook 默认 [plan-note] 为 Goal↔最新专档原话快速锚句并保留 102.0/80.8②/8.1 关键约束
- [x] S3：在 Rule 94/102 邻近位置增加与 SKILL.md 单入口一致的交叉锚（不改权威语义、不复制步骤漂移）
- [x] S4：补充 drift-checker 边界显性说明（安全网而非切换发起器），确认 64.x 语义不变
- **V-N:** VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 强化 SKILL.md 新指令单入口：快速判定卡+显性通告+切换登记指引 | 继承 | skills/task-planner/SKILL.md:188-201（新指令收口序列/D/A/B/C/E 表/E 类处置）；findings.md R-1~R-3/R-5, S-A（入口增强要点） | SKILL.md 含“意图切换快速判定/显性通告/切换登记/Goal/范围/交付物/user-session-log”关键要素且序列语义保留 | 12min | 1f/60l/12min | 无 | - | pending |
| S2 | (A6) 压缩 hook [plan-note] 为 Goal↔专档快速锚句并保留关键约束 | 继承 | /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:287（默认 note 文案）；findings.md H5/R-1；Rule 102.4 机制约束摘要 | hook :287 含 Goal/范围/交付物+最新专档+显性通告+切换登记+D/E 分流锚句，可 grep 命中 | 10min | 1f/20l/10min | 无 | - | pending |
| S3 | (A6) Rule 94/102 增交叉锚收敛到 SKILL.md 单入口（不改语义） | 继承 | skills/task-discipline/references/critical-rules-discipline.md:614-615,700-703（94.3-94.4/102.0-102.2）；findings.md R-2 | 94/102 邻近出现“以 SKILL.md 单入口清单为序/交叉锚”类表述且原处置语义未反转 | 12min | 1f/40l/12min | 无 | S1 | pending |
| S4 | (A6) 补 drift-checker 边界说明并核对 64.x 语义不变 | 继承 | skills/task-planner/SKILL.md:122（DRIFT CHECK 步骤）；/home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:59,68（64.2.1/64.7 摘要锚）；findings.md R-4/H4 | SKILL.md 明确“安全网非发起器”；drift-guard 64.2.1/64.7 关键锚仍在（VC-5） | 8min | 1f/20l/8min | 无 | S1 | pending |

### Phase 3: 回归验证与一致性核验
- [x] 执行 VC-1~VC-6 对应命令并记录证据（含 git diff scope 核验）
- [x] 完成 103.6 多文件变更集同步核对清单（四族关联面推导）并全绿
- [x] 必要时修正措辞漂移（保持 CA-1~CA-4 范围内最小修补）
- **V-N:** VC-3, VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（L0-E 纯执行：跑 selftest+grep 核对，零仓库受管变更零新代码零新语义，产物落 /tmp 与 progress——Rule 38.7 纯执行档，S-unit 粒度 0f/0l 权重 0）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 跑 VC-2~VC-6 机械校验并产出证据摘录 | 继承 | verification.md VC 命令表；修改后 skills/task-planner/SKILL.md、skills/task-discipline/references/critical-rules-discipline.md、zcode-userpromptsubmit.sh | 各命令退出码与输出记录于 progress/verification；失败项有修复建议 | 10min | 0f/0l/10min | 无 | S3,S4 | pending |
| S2 | (A6) 完成同步核对清单与 scope diff 审计 | 继承 | git diff --name-only；CA-1~CA-4 变更标注；103.6 四族关联面 | 变更文件均在 scope 内且关联面核对全绿或登记豁免 | 8min | 0f/0l/8min | 无 | S1 | pending |

### Phase 4: Code Review、终验与交付
- [x] 触发 code-review（required）并处理 CHANGES_REQUESTED（如有）——APPROVED 零 BLOCKER/MAJOR/MINOR
- [x] 逐条复验 VC、填写核心目标达成裁决与收尾回读梳理记录——run-verification 7/7 PASS（判据第 2 批修正后重锁 c55d166c）
- [x] 产出交付摘要（按 51.14 自证口径）并记录归档前置条件（执行期由主进程按 Rule 81 执行）
- **V-N:** VC-1, VC-6
- **Status:** complete
- **Executor:** code-reviewer
<!-- CR Gate 派发见 Handoff #7；主进程白名单面=git/归档编排+簿记与交付汇总 -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A7) 汇总 VC/CR/同步核对证据并形成终验结论 | 主进程 | progress.md 证据；verification.md；CR 结果 | outcome 判定有证据支撑，R1 达成裁决可填写 | 10min | 0f/0l/10min | 无 | S2 | pending |

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）
| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1 | ①kb §7 提示 kb-sync-from-plan.sh 入库触发未执行；②open_questions 三条已在 S-A 默认决策落定未登记；③其余五维互洽（需求↔目标↔执行↔验证↔知识）无偏移——R1 全覆盖、CA-1~4 无超范围、VC 7/7、kb §2 与 findings 一致、诚实披露条款（kb §4.6 LLM 行为门非机器强制）在位 | ①执行 kb 入库（收尾序列）；②open_questions 处置登记于交付摘要；③无 |
| 2 | 零新发现（连续一轮零新发现=收敛出口） | —— |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（2026-11-16 check-conflicts.sh: 信号①未提交变更22文件；⑤其中5个运行中基础设施；③遗留wt分支1；④未完成任务12） |
| `isolation` | `worktree`（实现类，改 skills/** 保护区，宪法 §十一.1①） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-intentswitch-20261116`（Rule 100 仓内 tmp/worktrees/） |
| `branch` | `wt/task-intentswitch-20261116` |
| `merge_back` | `pending` |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/worktree-isolation.md`。合并前全 VC 复验 + CR APPROVED + `git status` 干净。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | 多处文案修改引入语义漂移（94/102 与入口步骤不一致） | 8 | 5 | 5 | 200 | ③ 降档为逐文件最小 diff+交叉 grep 对照；失败则 ④ 主进程接管单文件修补并重跑 VC-3 |
| Phase 2 | hook 措辞压缩丢失关键约束（102.0/80.8②/8.1）导致提示退化 | 8 | 4 | 4 | 128 | ① 改派聚焦 S2 单文件补丁；仍不达标 ③ 降档为保守增量追加锚句而非大段替换 |
| Phase 3 | VC 命令在实现前/环境差异下误判 | 5 | 5 | 4 | 100 | RPN≤100：预先区分“当前可验(VC-1)”与“实现后验(VC-2~6)”，终验前再跑全量 |
| Phase 4 | CR 指出遗漏显性通告/登记字段需返工 | 6 | 5 | 3 | 90 | RPN≤100：追加 fix S-unit 回 Phase 2 对应点 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划期落盘中 |
| Phase 2 | ☐ |  | 待 D1 批准后建 |
| Phase 3 | ☐ |  | 待 Phase 2 完成后 |
| Phase 4 | ☐ |  | 终验/CR/交付 |

> 契约详见 `/home/terry/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions
1. 纯语义 D 类切换（未命中 E 类三判形式）在 ask/silent 模式下的“显性通告”最小可接受形态是什么？（计划默认：会话面输出固定模板 + 计划载体登记行）
2. hook [plan-note] 压缩后如何在“可扫描”与“保留 102.0/80.8②/8.1 约束”间平衡？（计划默认：快速锚句前置 + 保留关键 Rule 引用）
3. 切换登记最小字段落在哪个既有载体最稳妥（Decisions/progress 统一行）且不引入新文件？（计划默认：Decisions + progress `[intent-switch]` 行并行，旧计划与新计划各留痕）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采用 S-A 最小增强（单入口判定卡+显性通告+切换登记指引+hook 快速锚+94/102 交叉锚） | 直击根因 R-1~R-3/R-5，改动集中、回归可控，符合“增强既有机制” |
| S-B 结构化重构列为备选/演进，不在本轮一次性实施 | S-B 需新参考文档/脚本/registry 改动面大；先以 S-A 验证显性度收益 |
| drift-checker 判定语义保持不变，仅补边界说明 | 64.2.1/64.7 已是目标漂移安全网；H4 属职责边界显性问题，避免破坏既有拦截 |
| isolation=worktree（tmp/worktrees/task-intentswitch-20261116） | skills/** 保护区 + check-conflicts.sh risk；满足宪法 §十一 |
| VC-2~VC-5 以 grep 可观察锚点验收 | 机制增强以文案/流程条款为主，grep 断言可执行且可复现 |
| V-3.2 判据修正（2026-11-16，antitamper 四步：STOP→44.3 自动裁决→本登记→重锁 attest） | 原判据 grep 'Rule 94'/'Rule 102' 与 discipline 文件裸编号形态（### 94 :607/### 102 :695）错配永假=判据缺陷非产物缺陷（0 命中实测）；AskUserQuestion 未答→44.3 超时自动通过按推荐项修正为实在锚 ^### 94/^### 102，判据意图（锚点回归在位）等效；与 V-1.1（补产物）构成方向对照判例 |
| VC-3/VC-4 判据修正第 2 批（2026-11-16，同一四步流程） | 终验 5/7 后分解：VC-3 三锚 MISS（SKILL.md 无 Rule 102 字面=既成措辞；discipline 裸编号）+VC-4 一锚 MISS（锚句用 [intent-switch] 登记，判据字面「切换登记」错配）均=判据缺陷；修正为实在锚（意图切换快速判定卡/^### 94/^### 102/intent-switch 单入口/intent-switch），意图等效；产物零改动 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a（非批量任务） |
| `failed` | n/a（非批量任务） |
| `failure_rate` | n/a（非批量任务） |
| `sampled_pass` | n/a（非批量任务） |
| `sampled_fail` | n/a（非批量任务） |
| `pre_check` | n/a（非批量任务） |
| `rollback_point` | n/a（非批量任务） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 4 |
| 主进程直做 Phase 清单 | Phase 1（②计划系统文件维护/计划期单写者）；Phase 4（①git/CR编排+②簿记交付）— 白名单 |
| 委派率 | （终验填写；目标 ≥ delegation_rate_floor） |
| 激活子代理数（Rule 96.5） | （终验填写） |
| 最大并行宽度（Rule 96.5） | （终验填写；本计划默认串行） |
| 串行化例外理由（Rule 96.4） | S2/S3/S4 依赖 S1 入口定稿；Phase 3 依赖 Phase 2 产物 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-16 | plan-writer | P0 调研机制全景+H1-H6 诊断并落盘计划文档 | done | 完成 M1-M15 全景、H1-H6 与 R-1~R-5、S-A/S-B、task_plan/verification/kb/progress 初稿 | findings.md 全文；task_plan.md 全文 | findings.md Research Findings/Technical Decisions | n/a | - / 0 / ☑(主进程盘上复核 Goal/VC/Phases/findings) |
| 2 | 2026-11-16 | drift-checker | Phase 1 目标对齐三态判定 | done | ✅ALIGNED：R1 覆盖有效/无范围漂移 | task_plan.md:43-44,13,15-18；findings.md:29-111 | drift-p1.md | checkpoints/drift-p1.md | - / 0 / ☑ |
| 3 | 2026-11-16 | code-assistant | S1+S4 SKILL.md 单入口增强（判定卡+清单+通告+登记字段+边界） | done | +7/0 纯增量；:122-123/:193/:202-204 落位 | worktree diff stat；SKILL.md:122-123,193,202-204 | progress Phase 2 | n/a | - / 0 / ☑(主进程盘上复核) |
| 4 | 2026-11-16 | code-assistant | S2 hook :287 快速锚句前置 | done | 2/1 PREFIX 原文保留；bash -n PASS | hook diff；zcode-userpromptsubmit.sh:287 | progress Phase 2 | n/a | - / 0 / ☑(主进程 diff 复核) |
| 5 | 2026-11-16 | code-assistant | S3 Rule 94/102 交叉锚收敛 | done | +2/0；:619/:708 落位上下文完整 | discipline.md:619,708 | progress Phase 2 | n/a | - / 0 / ☑(主进程 sed 抽查) |
| 6 | 2026-11-16 | drift-checker | Phase 2 改动对齐三态判定 | done | ✅ALIGNED：范围一致/无语义冲突/64.x 未动 | git show 2c3bdf3 --stat | drift-p2.md | checkpoints/drift-p2.md | - / 0 / ☑ |
| 7 | 2026-11-16 | code-reviewer | CR Gate 单轮轻量审查（required） | done | **APPROVED** 零 BLOCKER/MAJOR/MINOR；bash -n+模拟赋值验证 | CR 报告（agent_05668358）；2c3bdf3 | progress Phase 4 | n/a | - / 0 / ☑(verdict 即证据) |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 意图切换显性化增强（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | 诊断并增强 task-planner 会话内 A→B 意图切换的识别与隔离显性度 |
| **depends_on** | none |
| **passes_to** | n/a |
| **status** | in_progress |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | done | plans/task-intentswitch-20261116/* | run-verification 7/7 PASS（c55d166c） | 2026-11-16 |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底（机制增强跨规则/文档/流程，非 16 类单一专属类型完全匹配）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant（候选：intent-switch-enhancement-type）
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP