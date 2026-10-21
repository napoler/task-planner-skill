# Task Plan: 执行规范召回机制（召回卡 + Rule 93 双触发节奏）
<!-- frontmatter：template_type 白名单校验见 check-template-type.sh；plan_tier/execution_lane 判定见 Rule 38.1/38.7 -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「那么是否有一些补救方案呢？比如说周期性的召回技能添加到上下文当中。或者说其他的，或者这其他的方案来确保，就是说严格遵守当前技能的规范。」<sub>（[目标]）</sub>
- **R2**: 「第一种可以每隔多少轮，然后加载一次技能文件，重新加载一次技能文件。或者说第二种，……在todo的，比如说todo的第三个条目，每隔三个条目或者每隔五个条目执行完成之后，执行，嗯，嗯，执行一个重新扫描技能文件的，或者说规范文件。」<sub>（[手段]）</sub>
- **R3**: 「还有就是当然不用全部重新加载整个技能，因为我思考的就是只加载一，只就是相当于只加载一部分关于执行规范的相关的条目即可，也就是说只加载部分文件，或者说是将这将将这些规范、设计规范以及执行相关的条目单独的列到一个文件中，专门每次阅读这个文件。」<sub>（[手段]）</sub>
- **R4**: 「说不合理的话，我希望你可以帮我分析出更合理的方案进行改。」<sub>（[目标]）</sub>

> 完整逐字原文（含口语）见 `user-session-log.md` #1。问题背景：上下文超过十几二十万或压缩后，「原本的技能的要求规范就已经被遗忘掉了」「导致……task plan的相关的规范被遗忘掉」。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3 | 召回卡文件在位（≤120 行）+ Rule 93 条款全文在位（≥6 子条锚）+ SKILL.md 接线 grep 命中 |
| R2 | VC-3, VC-5 | SKILL.md Phase 循环含 3g 规范召回步骤；task_plan 模板含召回行（计划文件承载节奏） |
| R3 | VC-1 | 召回卡=执行规范条目摘要文件（非全文重载），≤120 行硬界 |
| R4 | VC-6, VC-7, VC-8 | selftest 回归零增量 + 编号账本 landed + 合并回 master 且 worktree 清理 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-v195-spec-recall/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md；随后**主进程 Read 执行规范召回卡（Rule 93.3）**
- **理解镜像**：#1 已同号配对（Rule 80.7）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
> 结果级需求=R1/R4（确保规范被严格遵守）。规范遵守链路逐工序审计：

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| ① 规范初始载入 | 无缺陷（SKILL 加载即在上下文） | 无（既有） | - |
| ② 长会话保持 | 无周期性规范召回——3f/Rule 65/64.3 重读的均是三文件状态而非规范文本，>100k 后注意力稀释无矫正 | 召回卡 + Rule 93.2 主动节奏 | VC-1/VC-3 |
| ③ 压缩后恢复 | 恢复读序（19.3/62.1）只重建状态不重载规范；压缩把条款压成摘要后精确约束丢失 | Rule 93.3 被动强制触发 | VC-2/VC-3 |
| ④ 机制自身存活 | 节奏若只写在 SKILL.md，压缩后机制本身也被遗忘（递归遗忘） | 93.4 抗压缩设计：节奏写入 task_plan 模板，随四文件恢复存活 | VC-5 |
| ⑤ 留痕闭环 | 无召回执行凭证，跳过不可见 | 93.2 `[recall]` progress 留痕 | VC-2 |

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | 既有 Rules 原文零改动（含 Rule 92 尾部插入锚后既有内容逐字保留）；R1-R4 原文；VC 表；既有 selftest 断言语义（仅允许数字/清单级联修锚） | 本计划对应章节 |
| 🔀 可变量 | S-unit 拆分与执行顺序；断言锚的数字级联修复方式；召回节奏参数文案（2-5 区间内） | - |
| 📈 学得量 | 执行期新发现的锚点/计数面 → findings.md；禁反向改写不变量 | findings.md |

## Goal
长上下文/压缩后技能执行规范遗忘问题的结构化补救：新增执行规范召回卡（`execution-recall-card.md`，非权威单屏摘要）+ Rule 93 规范再召回纪律（主动节奏=每 3 个 S-unit/Phase 翻转重读；被动强制=压缩/恢复/PRESSURE 后第一动作），并完成计划模板承载与全仓计数级联，使执行规范可在长会话中周期性再对齐。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（技能规范文本改动，按惯例合并回前过 CR；本环境 `code-review` skill 不可用，按 Rule 83.2② 走 Agent 替代=critic 派发） |
| `session_id` | `<uuid>`（本会话） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall` |
| `scope_files` | 见「⚠️ 执行范围限制」 |
| `interaction_mode` | `silent`（无人值守 /goal 会话；用户 R4「进行改」=显式实施授权；静默决策清单随交付总结呈报） |
| `对齐审查` | `[登记]` 交付前对 SKILL.md/Rule 93/召回卡跑 alignment-review 视角核查（并入 critic 审查面） |
| `自动超时默认项` | `[询问点: 节奏参数 2-5 选择 → 默认 3 / 超时 5 分钟]`（无人值守，直接按默认裁决并登记 Decisions） |
| `new_rule` | `93` |
| `质量审查工具` | `critic`（agent；code-review skill 缺失已按 83.2 登记） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）
> VC-1~VC-5 在 worktree 内执行（合并前）；VC-7/VC-8 在主仓执行（合并后）。VC-6 两处各跑一次取基线/改后对比。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 召回卡在位且 ≤120 行、含 A-F 六节与 Rule 93 锚 | `test -f <wt>/skills/task-discipline/references/execution-recall-card.md && [ $(wc -l < <wt>/skills/task-discipline/references/execution-recall-card.md) -le 120 ] && grep -c "^- " <卡> ` ≥20 | 命令输出 |
| VC-2 | Rule 93 全文在位（93.0-93.5 子条锚 ≥6）且既有条款零改动 | `grep -c "^93\." <discipline>` ≥6；`git diff master...wt -- <discipline>` 无删除行（纯追加） | 命令输出 |
| VC-3 | task-planner SKILL.md 接线在位 | `grep -c "3g 规范召回" <wt>/skills/task-planner/SKILL.md` =1 且 `grep -c "execution-recall-card" 同文件` ≥1 | 命令输出 |
| VC-4 | 计数级联一致 | `grep -rn "Rules 1-92" <wt>/skills/ <wt>/README_zh.md <wt>/CLAUDE.md` 零命中；`grep -n ",93" <wt>/skills/task-planner/references/critical-rules.md` 命中路由行 | 命令输出 |
| VC-5 | task_plan 模板召回行在位 | `grep -c "规范召回" <wt>/skills/task-planner/templates/task_plan.md` ≥1 | 命令输出 |
| VC-6 | selftest 回归零增量 | 改后 `bash <wt>/skills/task-planner/scripts/run-selftests.sh` FAIL 总数 ≤ 改前基线 FAIL 总数（两值记 progress） | 命令输出两值 |
| VC-7 | 编号账本 landed | `grep '"rule":93' plans/.rule-reservations.jsonl` 含 landed+本任务 id | 命令输出 |
| VC-8 | 合并回+worktree 清理完成 | `git log --oneline master -3` 含本任务 merge；`git worktree list` 无本任务路径 | 命令输出 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留（如部署位同步）→ PARTIAL 并列明；≥1 VC 重试 3 次无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1、R4 |
| **裁决** | `solved` |
| **解决证据锚** | 召回卡+Rule 93 双触发机制落地：execution-recall-card.md（51 行）+ critical-rules-discipline.md:591-602（93.0-93.5）+ SKILL.md 3g 接线 + 模板召回行；合并回 master 2f1b88f；回归 fresh 92/92 FAIL=0（VC-1..6 全 PASS，S6/S7 独立验证） |
| **未解决面+原因** | 无（机制面完整交付；行为面长期效果待实际长会话观察——属机制生效后的正常观察项，非本任务缺口） |
| **已排除路径** | n/a（solved） |
| **下一步建议** | ① 部署位同步待用户单独授权（~/.zcode/skills/**，§六 保护区）；② 可选机器化守护（召回卡与规则原文同步性 selftest）=opt-in 待用户显式授权（Rule 93.1 文本锚已承载同步义务） |

> 本任务为手段型+目标型混合：R1/R4 目标型（补救机制落地即"解决"——机制有效性以 VC 落地+回归证明，非行为面长期统计）；R2/R3 手段型。

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | discipline 落地 | 召回卡新文件+Rule 93 条款+discipline SKILL 计数行落 worktree | VC-1/VC-2 grep 命令 + Read 复核 | S1,S2/Phase 1 | complete |
| G2 | planner 接线级联 | SKILL.md 3g 步骤+核心/根文档计数级联+模板召回行落 worktree | VC-3/VC-4/VC-5 grep 命令 | S3,S4,S5/Phase 2 | complete |
| G3 | 回归与 CR | selftest 零增量+critic 审查 APPROVED | VC-6 两值对比 + critic 结论行 | S6,S7/Phase 3 | complete |
| G4 | 合并收口 | 合并回 master+land 93+索引刷新+归档+交付 | VC-7/VC-8 命令输出 | Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新增 | `skills/task-discipline/references/execution-recall-card.md` | 其他新文件 |
| 修改（discipline） | `skills/task-discipline/references/critical-rules-discipline.md`（尾部追加 Rule 93）、`skills/task-discipline/SKILL.md`（:24/:76/:87 计数行） | 既有条款正文改动 |
| 修改（planner） | `skills/task-planner/SKILL.md`（3g 步骤+:141 短语+:9/:17/:196/:209/:251 计数）、`skills/task-planner/references/critical-rules.md`（:184 路由行）、`skills/task-planner/templates/task_plan.md`（召回行） | 其他模板/脚本 |
| 修改（根文档） | `README_zh.md`（:136/:229）、`CLAUDE.md`（:33） | - |
| 修改（级联补充 CA-9） | `skills/task-planner/README.md`（:36/:81/:123 当前声明行）、`skills/task-planner/docs/ARCHITECTURE.md`（:4 主文本+:13 主文本+:42 框图+:113 标题更新、:121 后追加演进条目；历史注释与历史条目字面保留） | 两文件其他段落 |
| 禁改 | 既有 Rules 正文/selftest 断言语义/scripts/**/config.json/部署位 `~/.zcode/skills/**` | - |

**执行前自我检查**: 每处修改均属本表；全部为增量或计数级联（见变更标注表）。

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据 | 执行动作 |
|------|------------------|------|---------|----------------|------|---------|
| CA-1 | skills/task-discipline/references/execution-recall-card.md（新文件） | 新增 | 增量 | R3「单独的列到一个文件中，专门每次阅读这个文件」 | 侦察②：全仓无摘要卡类文件 | 创建召回卡（≤120 行） |
| CA-2 | critical-rules-discipline.md（Rule 92 后追加） | 新增 | 增量 | R1「补救方案……确保严格遵守规范」 | 侦察①：无等效召回机制；编号 93 空闲（台账无 93） | 追加 Rule 93（93.0-93.5），既有内容逐字保留 |
| CA-3 | task-discipline/SKILL.md :24/:76/:87 | 更新 | 增量（计数级联，v181 判例） | 同上 | 规则清单行需含 93 | 清单加 `,93`、43→44 条 |
| CA-4 | task-planner/SKILL.md :86 后（3g 步骤）+:141（恢复矩阵短语） | 新增 | 增量 | R2「每隔三个条目……执行一个重新扫描……规范文件」 | 主挂点=Phase 执行循环 3e/3f 同层（侦察①） | 插入 3g 步骤+恢复矩阵追加召回卡短语 |
| CA-5 | task-planner/SKILL.md :9/:17/:196/:209/:251 + references/critical-rules.md :184 | 更新 | 增量（计数级联） | 同上 | 纪元字面 1-92→1-93、73→74 条、路由行加 93 | 仅数字/清单更新 |
| CA-6 | README_zh.md :136/:229 + CLAUDE.md :33 | 更新 | 增量（计数级联） | 同上 | 纪元字面+演进注释惯例（task-v191 判例） | 1-92→1-93+追加演进注释 |
| CA-7 | templates/task_plan.md Phase 3 checklist（:309-311 后） | 新增 | 增量 | R2「在todo计划文件中的计划中……重新读取一下这个规范文件」 | 93.4 抗压缩：节奏随计划文件存活 | 插入一行召回 checkbox |
| CA-8 | plans/.rule-reservations.jsonl | 新增 | 增量 | - | Rule 20.6 编号预留 | attest 自动 reserve；合并后 land 93 |
| CA-9 | skills/task-planner/README.md（:36/:81/:123）+ docs/ARCHITECTURE.md（:4/:13/:42/:113/:121 后追加） | 更新 | 增量（计数级联，执行期发现的面补全） | 同 R1 | V-2.1 执行时发现 skills/ 全域 grep 残留（计划侦察漏扫面）；历史叙述字面保留 | 当前声明行 1-92→1-93+73→74+清单加 93；演进史追加 task-v195 条目；主进程直做（白名单：trivial 计数级联，与 CA-5 同构） |
| CA-10 | skills/task-discipline/SKILL.md（:15 共 43→44 条+清单行补"规范再召回"）+ README.md（:4 73→74+演进注/:127 73→74）+ docs/ARCHITECTURE.md（:136 73→74） | 更新 | 增量（S7 critic CHANGES_REQUESTED 指出的 4 处计数漏改修复） | 同 R1 | S7 审查 C-1/C-2/C-3（同文件 43 vs 44、73 vs 74 自相矛盾） | 单 token 级联修复；主进程直做（白名单：trivial 计数级联） |

## 📚 必要知识储备（任务知识库对齐）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | critical-rules-discipline.md（Rule 格式+92 尾锚） | /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md | 必读 | ☑ |
| 项目内部文档 | task-planner SKILL.md（3f 锚+纪元字面位） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | 必读 | ☑ |
| 项目内部文档 | worktree-isolation.md（合并回合约） | skills/task-planner/references/worktree-isolation.md | 参考 | ☑ |
| 侦察底稿 | 两份 Explore 检查点（机制盘点+落点盘点） | plans/task-v195-spec-recall/subagent-state/01-*.md、02-*.md | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 长上下文（>100k）与压缩摘要导致早期载入的技能执行规范被稀释/丢失，且现有周期机制（3f/Rule 65/64.3/67）重读对象均为计划三文件状态而非规范文本——规范层面存在无召回载体的结构性缺口。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（召回卡+Rule 93 双触发落地=可交付）
- [x] 核心问题不解决，其他工作都白费吗？（规范遗忘不解决，长会话执行质量持续衰减）
- [x] 核心问题的解决方法是清晰的、可执行的？（摘要卡+双触发节奏，全部文本条款落地）

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|--------|------|-----------|---------|-------------|-------------|
| S1-S7 | LOCAL-ONLY | 规范召回、召回卡、context compaction 规范重载 | 本仓 grep/Read（侦察已完成） | 文本条款 | 不适用 |

> 计划期调研已完成（两路 Explore 检查点在位）；全部 S-unit 纯机械文本编辑，无网络依赖。

## 🔍 证据面清单（Rule 58.1）
| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|---------|---------|--------|------|
| ① 自身样本 | 现有周期机制 4 件（3f/Rule 65/64.3/67） | Read+grep | subagent-state/01-explore-existing.md | ☑ |
| ② 对标样本 | 「摘要/召回卡」全仓 grep 8 命中逐条判定=无等效载体 | grep 全域 | 同上 §2 | ☑ |
| ③ 外部约束 | 宪法 §四.6 文本优先/守护 opt-in；Rule 82 禁镜像 | 条款引用 | 93.1/93.5 条款设计 | ☑ |

## Current Phase
Phase 3

## Next Step
并行派发 S6（verifier 回归+VC 复验）+S7（critic diff 审查）

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | Agent 子代理 executor ×2 | 文本落地批量 SOP，文件集互斥可并行 |
| Phase 2 | Agent 子代理 executor ×3 | 同上（SKILL 接线/根文档/模板三组互斥） |
| Phase 3 | Agent 子代理 verifier + critic | 验证独立性（Rule 33.3）+独立审查视角 |
| Phase 4 | 主进程 | git 合并回+簿记=白名单①② |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（并行组 ≤3、非长链编排、用户未点名）→ Rule 21.4 声明制调度
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；/goal 为用户侧 harness 命令，技能层不代调

## Phases

### Phase 1: discipline 域落地（召回卡 + Rule 93）
- [x] S1 召回卡新文件落 worktree
- [x] S2 Rule 93 条款追加 + discipline SKILL.md 计数行
- [x] 主进程 Read 复核两产出（§一.3）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** executor
<!-- S-unit 表（Rule 22.6；并行组声明：S1∥S2 文件集互斥——S1 新文件、S2 discipline 两文件，Rule 21.4 声明制） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 创建执行规范召回卡（内容=计划 Decisions 区草案逐字） | 继承 | <wt>/skills/task-discipline/references/（新文件 execution-recall-card.md） | 文件在位 ≤120 行、A-F 六节、每条带规则锚 | 15min | 1f/90l/15min | 无 | - | pending |
| S2 | 追加 Rule 93 全文（93.0-93.5）+ discipline SKILL.md 三处计数行 | 继承 | <wt>/skills/task-discipline/references/critical-rules-discipline.md（Rule 92 尾 :588=追加锚）；<wt>/skills/task-discipline/SKILL.md（:24/:76/:87 计数行） | grep "^93\." ≥6；既有 92 原文零改动（diff 无删除行）；:24 清单含 ,93 | 15min | 2f/45l/15min | 无 | - | pending |

### Phase 2: planner 接线与全仓计数级联
- [x] S3 SKILL.md 3g 步骤+恢复矩阵短语+纪元计数
- [x] S4 根文档计数级联
- [x] S5 task_plan 模板召回行（主进程白名单直做——dispatch hook 两次拦截后 22.3 换道）
- [x] CA-9 计数面补全（README/docs，scope 扩展已登记+重 attest）
- [x] 主进程 Read 复核
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** executor
<!-- S-unit 表（并行组声明：S3∥S4∥S5 文件集互斥，Rule 21.4 声明制） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S3 | SKILL.md 插 3g 步骤+:141 短语+5 处纪元计数+critical-rules.md:184 路由行加 93 | 继承 | <wt>/skills/task-planner/SKILL.md（:86 3f 尾/:141/:9/:17/:196/:209/:251）；<wt>/skills/task-planner/references/critical-rules.md（:184） | grep "3g 规范召回"=1；SKILL 面 grep "Rules 1-92"=0；:184 含 ,93 | 15min | 2f/30l/15min | 无 | - | pending |
| S4 | README_zh/CLAUDE 纪元计数 1-92→1-93+演进注释 | 继承 | <wt>/README_zh.md（:136/:229）；<wt>/CLAUDE.md（:33） | 三处 1-92 零残留+演进注释在位 | 10min | 2f/12l/10min | 无 | - | pending |
| S5 | task_plan 模板 Phase 3 插规范召回行 | 继承 | <wt>/skills/task-planner/templates/task_plan.md（:309-311 checklist） | grep "规范召回"=1，既有行零改动 | 10min | 1f/8l/10min | 无 | - | pending |

### Phase 3: 回归验证 + 独立审查
- [x] S6 selftest 基线对比+VC-1..5 复验（92/92 零增量，全 PASS）
- [x] S7 critic 全量 diff 审查（CHANGES_REQUESTED：4 处计数漏改）
- [x] CR 修复+复核（CA-10 四处级联补齐 → S7b 复核 APPROVED）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5, VC-6
- **Status:** complete
- **Executor:** verifier + critic（双派发）
<!-- S-unit 表（S6∥S7 只读互不依赖，声明并行） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S6 | 跑 selftest 基线/改后对比+VC-1..5 命令清单 | 继承 | <plan>/verification.md（V-N 命令清单） | PASS/FAIL 汇总表+两基线值 | 15min | 1f/10l/15min | verification-gate | S1-S5 | pending |
| S7 | worktree 全量 diff 挑刺审查（正确性/漂移/范围） | 继承 | git diff master...wt（只读） | APPROVED 或 CHANGES_REQUESTED+逐条依据 | 15min | 0f/0l/15min | 无 | S1-S5 | pending |

### Phase 4: 合并收口与交付
- [x] 全 VC 复验通过后 smart-merge-back 合并回 master（2f1b88f；合并前解 s77-exec SKILL.md 冲突+master 前进 stash 窗口）
- [x] rule-reserve land 93 + INDEX 刷新 + 归档
- [x] 交付总结（五要素+静默决策清单）
- **V-N:** VC-6, VC-7, VC-8
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①未提交 10 文件均在 plans/与他域，与本任务 skills/ scope 零重叠；信号③ wt/task-v168-machine-parked 为既有遗留分支，报告不处置） |
| `isolation` | `worktree`（命中 §11.1：skills=运行中基础设施；§六 保护区） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v195-spec-recall` |
| `branch` | `wt/task-v195-spec-recall`（**自 master 建**——main(15a3ecf) 落后 master(42d72b4)，防不同步） |
| `merge_back` | `merged(2f1b88f)`（合并前解 s77-exec SKILL.md 冲突并集解+master 前进 stash 窗口处理；并行会话在途 5 文件 stash→pop 完好恢复） |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1 | Edit 锚失配/误改既有条款 | 6 | 4 | 3 | 72 | 派发前 grep 实锚+diff 复核（22.3①） |
| Phase 2 | selftest 计数断言级联 FAIL | 5 | 6 | 4 | 120 | 仅数字/清单级联修锚（22.3① 资料先行：先读断言行原文再改），逐处记 progress |
| Phase 4 | 合并冲突（并行会话合流） | 7 | 3 | 4 | 84 | smart-merge-back 冲突即 STOP 报告，并集解需用户裁决面则上报 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-21 | S1 建 |
| Phase 2 | ☑ | 2026-10-21 | S1 建 |
| Phase 3 | ☑ | 2026-10-21 | S1 建 |
| Phase 4 | ☑ | 2026-10-21 | S1 建 |

## Key Questions
1. 召回节奏缺省值？（裁决：3 个 S-unit，用户提"每隔三个……或者每隔五个"，取下界保守，允许计划级调 2-5，零 config 键）
2. 召回卡归属？（裁决：task-discipline/references——执行纪律域，Rule 82 归属判定；核心文件禁镜像）
3. 卡片与规则原文漂移如何防？（裁决：93.1 同步义务文本锚；机器化守护=opt-in 留待用户显式授权）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 采纳用户方案②+③（计划条目嵌入节奏+独立摘要文件），否决方案①（整文件周期重载） | 方案①重载 SKILL/critical-rules 全文会复现上下文膨胀；方案②③=精准低成本召回（R2/R3 原文采纳） |
| 召回动作=主进程亲自 Read，禁委派 | 子代理读取只矫正子代理上下文，主上下文不受益（Rule 61.1 反向边界；drift-checker 判例实证） |
| Rule 93 落 discipline 卫星，核心仅路由行 | Rule 82:167 禁核心镜像；编号 93 经台账查重空闲 |
| 不新增 selftest/hook/config 键 | 宪法 §四.6 文本优先+守护 opt-in；机器化留待用户显式授权 |
| interaction_mode=silent | 无人值守 /goal；用户 R4「进行改」=显式授权；静默决策随交付呈报 |
| worktree 自 master 建（非 main） | main 落后 master 6+ commit（15a3ecf vs 42d72b4），防 worktree-branch-desync 判例复发 |
| 节奏参数缺省 3，写入计划配置可调 2-5 | R2 用户原话区间取下界；零 config 键 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
| （暂无） | 1 | - | → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 长会话警示：本任务自身也适用 Rule 93.2——每 3 个 S-unit 主进程 Read 召回卡（建成后）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4 |
| 主进程直做 Phase 清单 | Phase 4（白名单① git 编排+② 簿记） |
| 委派率 | 0.75（≥0.7 达标） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-21 | Explore | 现有召回/压缩机制盘点 | done | 无等效召回机制；无重叠在途计划；模板主挂点=Phase 循环 | 01-explore-existing.md | findings §1 | plans/task-v195-spec-recall/subagent-state/01-explore-existing.md | - / 0 / ☑ |
| 2 | 2026-10-21 | Explore | 落点与守护级联面盘点 | done | next=93；宽锚不破；级联面 10 处；部署需授权 | 02-explore-landing.md | findings §1 | plans/task-v195-spec-recall/subagent-state/02-explore-landing.md | - / 0 / ☑ |
| 3 | 2026-10-21 | executor | S1 召回卡 | done | 卡 51 行/35 条目锚/34 规则编号全在位（安全网 5 项 MISSING=检查器误报复核排除） | execution-recall-card.md:1-51 | findings §[sub:S1-executor] | subagent-state/S1-executor.md | - / 0 / ☑ |
| 4 | 2026-10-21 | executor | S2 Rule 93+计数行 | done | +14/-0 纯追加（93.0-93.5 六锚）；SKILL.md :24/:76/:87 三处精确 | critical-rules-discipline.md:591-602 | findings §[sub:S2-executor] | subagent-state/S2-executor.md | - / 0 / ☑ |
| 5 | 2026-10-21 | executor | S3 接线级联 | done | 8 处编辑落位（3g 步骤/:141 短语/5 处纪元/路由行 ,93） | SKILL.md:86 后等 | findings §[sub:S3-executor] | subagent-state/S3-executor.md | - / 0 / ☑ |
| 6 | 2026-10-21 | executor | S4 根文档计数 | done | README_zh×2+CLAUDE×1 → 1-93+演进注释，历史注释保留 | README_zh.md:136/:229 | findings §[sub:S4-executor] | subagent-state/S4-executor.md | - / 0 / ☑ |
| 7 | 2026-10-21 | 主进程（白名单:① trivial 单文件 1 行；dispatch 契约 hook 两次拦截后 22.3 换道）+CA-9 同（trivial 计数级联） | S5 模板召回行+CA-9 | done | 模板召回行 1 行插入；README 3 处+ARCHITECTURE 6 处级联，历史字面保留 | task_plan.md:312 / README.md:36,81,123 / ARCHITECTURE.md:4,13,42,113,121,134 | progress Phase 2 段 | progress.md（本段） | - / 0 / ☑ |
| 8 | 2026-10-21 | verifier | S6 回归+VC 复验 | done | 92/92 零增量；VC-1..5 全 PASS；预警 master 前进合并冲突 | selftest 改后 Total 92 PASS=92 FAIL=0 | findings §[sub:S6-verifier] | subagent-state/S6-verifier.md | - / 0 / ☑ |
| 9 | 2026-10-21 | critic | S7 diff 审查 | done | CHANGES_REQUESTED→CA-10 修复→S7b 复核 APPROVED（4 处计数级联补齐，零越界） | subagent-state/S7-critic.md、S7b-critic-recheck.md | findings §[sub:S7-critic]/§[sub:S7b-critic-recheck] | subagent-state/S7-critic.md | rescue:1 轮修复 / 0 / ☑ |

## 🔁 模板感知（template-sense）
- task_type: general（兜底）
- Rule 34.3② 沉淀评估: 本任务=技能规范条款类变更，复用 general 模板合适，无新模板沉淀需求
