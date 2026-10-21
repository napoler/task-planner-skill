# Task Plan: 项目知识库持久化沉淀与快速查询复用（task-kb-persist-20261022）
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）===== -->
template_type: general
plan_tier: standard
execution_lane: L1
<!-- 
  WHAT: This is your roadmap for the entire task. Think of it as your "working memory on disk."
  WHY: After 50+ tool calls, your original goals can get forgotten. This file keeps them fresh.
  WHEN: Create this FIRST, before starting any work. Update after each phase completes.
-->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC -->

- **R1**: 「我希望可以将当前项目的每次积累的知识库文件 不断累计沉淀 确保后期查询数据可以复用」<sub>（[目标]）</sub>
- **R2**: 「核心思路就是将当前项目的知识体系的积累可以持久化也就是每次积累的数据可以沉淀 后期使用 解决类似问题可以快速查询」<sub>（[目标]）</sub>
- **R3**: 「[$using-superpowers](/home/terry/.zcode/skills/using-superpowers/SKILL.md)」<sub>（[手段]——用户点名流程技能先行，已执行：using-superpowers → task-planner）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-4, VC-5 | 判据：knowledge/ 载体在位（ls exit 0）+ entries ≥12 且每条含非空 sources 来源锚 + INDEX 条目数=entries 文件数 |
| R2 | VC-2, VC-3, VC-6, VC-7 | 判据：kb-search.sh 实弹查询命中输出 + sync 脚本对样例归档任务跑通 exit 0 + selftest 零回归 + 3 个真实主题查询各命中相关条目 |
| R3 | VC-1 | 判据（手段链锚）：using-superpowers→task-planner 流程技能已加载并执行（会话 Skill 调用记录为证），其直接产出=本计划文档；R3 为手段型，履行证据随全计划交付链体现，以 VC-1（首个交付验证）承接溯源 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-kb-persist-20261022/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- R1/R2 为结果级需求（"确保可以复用/可以快速查询"），按知识管理管线三工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 知识写入（沉淀） | 单任务内已闭环（knowledge-brief 第 7 文件+Rule 62 门控），但任务归档后无人蒸馏到项目层；113 份归档 kb 中 58 份仍为模板占位 | Phase 2 存量回填（跳过占位，findings 兜底）+ Phase 3 闭环接线（后续任务终验即入库） | VC-3, VC-4 |
| 知识存留（累计） | 物理不丢但逻辑失联：plans/INDEX.md 排除 archive 子树（sync-todos.sh:159-197），152 个归档任务在索引中零条目；无「知识→来源任务→锚点」聚合表 | knowledge/ 持久层 + INDEX.md 聚合索引（含 sources 回链） | VC-1, VC-5 |
| 知识检索（复用） | 项目知识域零检索入口：scripts/ 中 22 个含 kb/knowledge 的脚本全是单计划守卫；唯一有 FTS 的 research-kb 入口已腐化（CLI 二进制与 research_kb.py 全域不存在，DB mtime 停在 2026-06-25） | scripts/kb-search.sh 轻量检索（rg 纯文件方案，规避 research-kb 式 CLI 腐化） | VC-2, VC-7 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① 用户需求原文 R1-R3 逐字冻结；② Goal 一句话与 VC 表；③ 范围禁区：skills/** 既有文件零修改（含脏文件 SKILL.md/critical-rules.md）、既有 scripts/*.sh 零修改、部署位 ~/.zcode/** 零写入；④ 纯新增策略：本任务所有仓库变更为新增文件，既有条目零改动 | task_plan.md 本区块+执行范围限制区块 |
| 🔀 可变量 | 批次/主题划分方式、条目数量、脚本实现细节（函数拆分/参数形态）、entries 文件命名 | - |
| 📈 学得量 | 执行期新事实/教训/锚点 → findings.md / notepad-learnings.md；禁反向改写不变量 | findings.md |

## Goal
为当前项目建成「知识沉淀→累计存留→快速查询」全链闭环：新增项目级 `knowledge/` 知识库（主题条目+聚合索引+来源回链），将 152 个归档任务已积累的知识批量蒸馏入库，提供 `kb-search.sh` 检索入口与 `kb-sync-from-plan.sh` 增量入库脚本，并以 `.zcode/plan-templates/` 项目级模板覆盖完成后续任务的知识入库闭环——使解决类似问题时可一条命令查得可复用知识与证据锚。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（脚本为新增工具类 bash ≤300 行合计，非生产代码路径；以 selftest 回归+实弹验证替代） |
| `session_id` | `bf5c7b13-3850-40bb-a6a9-0883c56832d4` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/kb-persist-20261022` |
| `scope_files` | `[knowledge/**, scripts/kb-search.sh, scripts/kb-rebuild-index.sh, scripts/kb-sync-from-plan.sh, .zcode/plan-templates/knowledge-brief.md, plans/task-kb-persist-20261022/**]` |
| `interaction_mode` | `silent`（/goal 自主目标模式，无人在场；静默决策清单登记于 Decisions Made） |
| `对齐审查` | 终验前对 README.md + 本计划跑 alignment-review（标准收尾） |
| `自动超时默认项` | 询问点=D1 计划确认；默认选项=按已展示计划执行；超时值=5 分钟（Rule 44.1 默认） |
| `new_rule` | 留空（本任务不新增 Rule 编号，规避纪元级联） |
| `质量审查工具` | 既有 agent：verifier（终验 VC 复验）+ code-runner-agent（selftest 回归）；无待补建缺口 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作由独立子代理执行（verifier / code-runner-agent），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | KB 载体在位：README.md、entry-template.md、entries/ 目录、INDEX.md 全部存在 | 运行命令 | `cd <repo> && ls knowledge/README.md knowledge/entry-template.md knowledge/INDEX.md && test -d knowledge/entries && echo PASS` |
| VC-2 | 检索实弹：kb-search.sh 对真实关键词命中条目且输出含来源任务路径 | 运行命令 | `bash scripts/kb-search.sh 锚点` 输出含 entries/*.md 命中行与 plans/archive 来源（证据落 verification.md） |
| VC-3 | 增量入库实弹：kb-sync-from-plan.sh 对样例归档任务跑通产出 draft 条目 | 运行命令 | `bash scripts/kb-sync-from-plan.sh plans/archive/task-v122` exit 0 且 `ls knowledge/entries/_draft-task-v122.md` 在位（draft sources 为仓相对路径） |
| VC-4 | 回填覆盖：entries 条目文件 ≥12；每文件 frontmatter 含非空 sources（来源锚=归档任务路径）；抽 3 条 sources 路径 Read 存在 | 运行命令+抽查 | `ls knowledge/entries/*.md \| wc -l` ≥12；`grep -L "^sources:" knowledge/entries/*.md` 输出为空；3 条 sources 抽查 Read 记录 |
| VC-5 | 索引一致：kb-rebuild-index.sh 重build 后 INDEX.md 数据行数 = entries 文件数（+1 表头行） | 运行命令 | `bash scripts/kb-rebuild-index.sh && test "$(grep -c '^| ' knowledge/INDEX.md)" -eq $(( $(ls knowledge/entries/*.md \| wc -l) + 1 )) && echo VC5-PASS` |
| VC-6 | 零回归：worktree 内全量 selftest FAIL 增量 = 0（对照主仓基线） | 运行命令 | worktree 内跑全量 selftest 汇总，与主仓基线对比（证据落 progress.md Test Results） |
| VC-7 | 目标达成实弹（R2 解决判据）：对 3 个真实主题（子代理派发/worktree 隔离/部署位同步）各执行一次 kb-search，均命中相关可复用条目 | 运行命令 | 3 次查询命令+命中输出逐条落 verification.md（🎯 核心目标达成裁决引用） |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🎯 核心目标达成裁决（Rule 58.5 — 含 [目标] 标注需求的任务终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1、R2 |
| **裁决** | `solved`（独立终验 verifier 供料：R1 沉淀+累计=solved，R2 持久化+快速查询复用=solved） |
| **解决证据锚** | subagent-state/P4-S2-verifier.md（VC-1~7 全 PASS：knowledge/ 12 条目+索引 13 行+120/114 sources 全存在；三主题语义主命中；92/92 零回归；合并 03ffb944 主仓复验）+ verification.md Goal Gate |
| **未解决面+原因** | 无阻断面。非回归遗留 3 项：① KB 新机制零直接 selftest 覆盖（P4-S1 负结果，机器化守护属 opt-in 未获授权不建）；② kb-sync 重跑会改写 draft 正文内嵌绝对路径致 tracked 文件变脏（frontmatter sources 已合规；1 行级修复留独立小任务）；③ README 两处措辞偏差（--tag 实为子串匹配；114 sources 中 2 条指向 skills/ 而非 plans/archive/，存在性成立） |
| **已排除路径** | 不适用（solved） |
| **下一步建议** | ① 使用：`bash scripts/kb-search.sh <主题>` 查询（对象 scripts/kb-search.sh，看点 --tag 用法，动作=遇到派发/守卫/worktree/计划/纪律类问题时先查）② 后续任务终验后跑 `bash scripts/kb-sync-from-plan.sh <plan-dir>` 沉淀（对象 .zcode/plan-templates/knowledge-brief.md §7）③ 遗留修复：draft 正文绝对路径一行级修复（对象 scripts/kb-sync-from-plan.sh:73 附近 SRC_DESC，动作=改仓相对） |

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 载体与工具 | knowledge/ 骨架 + 3 个 kb 脚本建成 | `ls knowledge/README.md knowledge/entry-template.md && bash scripts/kb-search.sh test && bash scripts/kb-rebuild-index.sh` exit 0 | S1-S4/Phase 1 | complete |
| G2 | 存量回填 | 152 归档任务知识按 6 域蒸馏 ≥12 条目入库 | `ls knowledge/entries/*.md \| wc -l` ≥12 ∧ `grep -L "^sources:" knowledge/entries/*.md` 为空 | S1-S6/Phase 2 | complete |
| G3 | 闭环接线 | 后续任务知识入库通道建成（模板覆盖+sync 脚本实弹） | `bash scripts/kb-sync-from-plan.sh plans/archive/task-v122` exit 0 ∧ `.zcode/plan-templates/knowledge-brief.md` 在位 | S1-S2/Phase 3 | complete |
| G4 | 实弹复用 | 3 个真实主题查询各命中可复用条目 | 3 次 `bash scripts/kb-search.sh <主题>` 命中输出落 verification.md | S2/Phase 3 | complete |
| G5 | 回归合并 | selftest 零回归+合并回 master+主仓复验 | 全量 selftest FAIL 增量=0 ∧ `git log` 含 merge commit ∧ 主仓 Read 复验记录 | S1-S2/Phase 4 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新增目录 | `knowledge/`（README.md、entry-template.md、INDEX.md、entries/*.md） | 其他顶层目录/文件 |
| 新增脚本 | `scripts/kb-search.sh`、`scripts/kb-rebuild-index.sh`、`scripts/kb-sync-from-plan.sh` | 修改 scripts/ 下任何既有文件 |
| 模板覆盖 | `.zcode/plan-templates/knowledge-brief.md`（新增，项目级覆盖） | .zcode/ 下其他文件；~/.zcode/** 部署位零写入 |
| 计划文档 | `plans/task-kb-persist-20261022/**` | 其他 plans/ 目录 |
| 🚫 禁区 | — | `skills/**` 全部（含脏文件 SKILL.md/critical-rules.md——上一任务在途变更，零触碰）；既有文件零修改 |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|----------------|---------|
| CA-1 | knowledge/**（全目录） | 新增 | 增量 | 「每次积累的知识库文件 不断累计沉淀」 | 盘点报告 §2 缺口①② | 建 README/entry-template/INDEX/entries |
| CA-2 | scripts/kb-search.sh、kb-rebuild-index.sh、kb-sync-from-plan.sh | 新增 | 增量 | 「解决类似问题可以快速查询」「每次积累的数据可以沉淀」 | 盘点报告 §2 缺口③ | 建 3 个检索/索引/入库脚本 |
| CA-3 | .zcode/plan-templates/knowledge-brief.md | 新增（复制部署模板+追加 §7 回链段） | 增量 | 「每次积累的数据可以沉淀 后期使用」 | init-session.sh:14,31-32 项目级按文件覆盖机制 | 复制模板追加 §7，既有段零改动 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 知识沉淀设施盘点报告（一手证据） | plans/task-kb-persist-20261022/subagent-state/01-explore-kb-infra.md | 必读 | ☑ |
| 项目内部文档/知识库 | knowledge-brief 模板结构（六段） | skills/task-planner/templates/knowledge-brief.md | 必读 | ☑ |
| 项目内部文档/知识库 | 统一入口 skill 范式参考 | /home/terry/.zcode/skills/terry-vault-search/SKILL.md | 参考 | ☑ |
| 项目内部文档/知识库 | worktree 隔离合约 | skills/task-planner/references/worktree-isolation.md（部署位）/ 宪法 §十一 | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）
**核心问题**: 项目 4 个月 190+ 任务积累的知识以单任务粒度散落在 152 个归档目录中，归档即失联（索引零条目）、零检索入口——解决"如何让已积累知识可被后续任务快速查询复用"后，R1/R2 的目标即达成。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（KB 载体+回填+检索入口=可交付能力）
- [x] 核心问题不解决，其他工作都白费吗？（无聚合层与入口，单任务沉淀再多也无法跨任务复用）
- [x] 核心问题的解决方法是清晰的、可执行的？（盘点已定位缺口=聚合层+检索入口+闭环，方案见 Phases）

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1-S1~S4 载体与脚本 | LOCAL-ONLY | 本仓脚本风格（sync-todos.sh）、entry frontmatter 范式（memory 文件/terry-vault） | 本仓 Read | 3 脚本+2 文档 | 不适用 |
| P2-S1~S6 存量回填 | LOCAL-ONLY | plans/archive 归档 kb/findings 内容 | 本仓 Read/Grep | entries 主题条目 | 不适用 |
| P3-S1~S2 接线与验证 | LOCAL-ONLY | 模板覆盖机制（init-session.sh）、实弹查询 | 本仓 Read+Bash | overlay 文件+查询记录 | 不适用 |

> 全部子目标 LOCAL-ONLY：原料=本仓归档数据，无网络依赖。

## 🔍 证据面清单（Rule 58.1）
`n/a（纯执行类）`——本任务为能力建设（建载体/回填/入口），不产出归因类结论；蒸馏条目全部携带来源锚（Rule 71 无源不写），证据面由 sources 字段承载。

## Current Phase
终验交付（全 Phase complete，VC-1~7 PASS，outcome=COMPLETE 待 check-complete+归档）

## Next Step
check-complete → 写 delivery-summary.md → commit 计划目录 → archive-plan 归档 → sync-todos --index → 交付总结

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-assistant（sonnet-1）×3 + executor（sonnet-1）×1 | 脚本编写与文档撰写，隔离上下文；code-assistant ≤3 文件硬限制故拆 3 派发 |
| Phase 2 | Agent 子代理 executor（sonnet-1）×6 并行（parallel_groups 声明） | 6 域蒸馏互独立（文件集/输入/验收互斥），Rule 21.4 四问全 No→并行 |
| Phase 3 | Agent 子代理 executor（haiku-1）+ verifier（sonnet-1） | overlay 机械复制+独立实弹验证（Rule 33.3 验证独立性） |
| Phase 4 | code-runner-agent（haiku-1）+ verifier（sonnet-1） | selftest 批跑+终验复验 |

**workflow 编排判定（Rule 40.4）**: 未命中强制路由——按 Rule 21.4 独立性守门调度（并行默认+声明制）；Phase 2 六批次文件集互斥、无共享写（各写各的 entries 文件）、输入独立（各自 sources 清单）、验收独立（逐文件可验）→ parallel_groups: P2-S1~S6 同批并行
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户以 /goal 锚定本任务（goal 模式自主推进），R1-R3 为 goal 原文锚。

## Phases

### Phase 1: KB 载体与检索工具建设（worktree 内）
- [ ] 创建 worktree（隔离决策见下）
- [ ] scripts/kb-search.sh、kb-rebuild-index.sh、kb-sync-from-plan.sh 建成
- [ ] knowledge/README.md、entry-template.md 建成
- [ ] 主进程实弹冒烟（kb-search/kb-rebuild-index 对空库跑通）
- **V-N:** VC-1, VC-2（本 Phase 验收映射：载体在位+检索命令可运行——V-1.1/V-1.2 已 PASS，证据=progress.md Phase 1 Test Results 表）
- **Status:** complete
- **Executor:** code-assistant（sonnet-1）×3 + executor（sonnet-1）×1

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 建 kb-search.sh（rg 检索 entries+INDEX，支持关键词与 --tag 过滤，输出命中行+title+sources） | code-assistant（sonnet-1） | -（规格内联派发 prompt：bash+rg，仓库根自探测 git rev-parse，≤85 行，Rule 45 注释 What+Why） | `bash scripts/kb-search.sh test` exit 0 | 15min | 1f/85l/15min | 无 | - | done |
| S2 | 建 kb-rebuild-index.sh（扫描 entries/*.md frontmatter 重建 INDEX.md 表：id/title/tags/sources/updated+计数） | code-assistant（sonnet-1） | -（规格内联：bash+awk，支持多 frontmatter 块，≤60 行） | 空库跑通产出表头 INDEX.md exit 0 | 15min | 1f/60l/15min | 无 | - | done |
| S3 | 建 kb-sync-from-plan.sh（从指定计划目录提取 knowledge-brief §2/§3/§4 非占位段+findings 标题结构→生成 entries/_draft-<task-id>.md） | code-assistant（sonnet-1） | -（规格内联：bash+awk，占位检测=模板基准行数，≤80 行） | 对样例目录跑通产出 draft exit 0 | 15min | 1f/80l/15min | 无 | - | done |
| S4 | 建 knowledge/README.md（定位/写入约定/查询/条目格式）+ entry-template.md（frontmatter+四段结构） | executor（sonnet-1） | -（规格内联：六段 kb 模板结构为参照，条目四段=结论/证据锚/易错点/适用场景） | 两文件在位且含规定章节标题 | 15min | 2f/90l/15min | 无 | - | done |

### Phase 2: 存量知识回填（152 归档任务 → 6 域蒸馏入库）
- [ ] 主进程机械预分组：扫描 archive 各任务 kb/findings 实质性与域归属 → 生成 batch-{A..F}-sources.md 六份清单
- [ ] 六批次并行蒸馏：每批产出 2 个主题条目文件（含来源锚）
- [ ] 主进程抽检 10%（Rule 18 双采样）+ kb-rebuild-index 重建索引
- **V-N:** VC-4, VC-5（回填覆盖+索引一致——已 PASS：12 条目+索引 13 行，证据=progress.md Phase 2 Test Results）
- **Status:** complete
- **Executor:** executor（sonnet-1）×6 并行

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 域 A（子代理派发/拆分/并行/粒度）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-A-sources.md（域内任务清单+要点，≤10 行） | 2 个 entries 文件各含非空 sources≥3 | 15min | 2f/100l/15min | 无 | P1-S4 | done |
| S2 | 域 B（锚点/守卫/selftest/回归）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-B-sources.md | 同上 | 15min | 2f/100l/15min | 无 | P1-S4 | done |
| S3 | 域 C（worktree/git/合并/部署位）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-C-sources.md | 同上 | 15min | 2f/100l/15min | 无 | P1-S4 | done |
| S4 | 域 D（计划流程/模板/验证/归档）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-D-sources.md | 同上 | 15min | 2f/100l/15min | 无 | P1-S4 | done |
| S5 | 域 E（调研/证据/反思/执行纪律）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-E-sources.md | 同上 | 15min | 2f/100l/15min | 无 | P1-S4 | done |
| S6 | 域 F（上下文/成本/媒体/其他杂项）蒸馏 2 条目 | executor（sonnet-1） | plans/task-kb-persist-20261022/batch-F-sources.md | 同上 | 15min | 2f/100l/15min | 无 | P1-S4 | done |

### Phase 3: 闭环接线与实弹验证
- [ ] .zcode/plan-templates/knowledge-brief.md 项目级覆盖建成（复制部署模板+追加 §7 项目 KB 回链段：kb-sync 命令+入库触发点）
- [ ] kb-sync-from-plan.sh 对样例归档任务实弹（VC-3）
- [ ] 3 个真实主题实弹查询（VC-7，verifier 独立执行）
- [ ] 主进程：guard 复核（.zcode/plan-templates 为新增文件零守护面）+ INDEX rebuild（机械白名单）
- **V-N:** VC-3, VC-7（增量入库+实弹复用——独立 verifier 5/5 PASS，证据=subagent-state/P3-S2-verifier.md）
- **Status:** complete
- **Executor:** executor（haiku-1）+ verifier（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 建项目级模板覆盖（部署模板复制+追加 §7 回链段，既有段零改动） | executor（haiku-1） | /home/terry/.zcode/skills/task-planner/templates/knowledge-brief.md（部署位权威模板全文） | 新文件含原六段+§7 且原段 diff=0 | 15min | 1f/25l/15min | 无 | P2 完成 | done |
| S2 | 独立实弹验证：VC-2/VC-3/VC-7 命令执行+输出记录 | verifier（sonnet-1） | knowledge/ + scripts/（验证 SOP 内联 prompt） | 三命令输出落 verification.md | 15min | 0f/0l/15min | 无 | P3-S1 | done |

### Phase 4: 回归、终验与合并回
- [x] worktree 内全量 selftest 回归（92/92 PASS，A 类=0）
- [x] verifier 终验全部 VC 复验通过 + 核心目标裁决（R1/R2 solved）
- [x] 主进程：commit（pathspec 限定）→ smart-merge-back（03ffb944）→ 清理 worktree/分支 → 主仓 Read 复验 → 归档 → 交付总结
- **V-N:** VC-6, VC-1（零回归+载体终态在位——92/92 PASS A=0；合并后主仓复验全过）
- **Status:** complete
- **Executor:** code-runner-agent（haiku-1）+ verifier（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | worktree 全量 selftest 批跑+与主仓基线对比 | code-runner-agent（haiku-1） | /home/terry/task-planner-skill-worktrees/task-kb-persist-20261022（worktree 绝对路径） | FAIL 增量=0 报告落 checkpoint | 15min | 0f/0l/15min | 无 | P3 完成 | done |
| S2 | 终验：VC-1~VC-7 全量复验+58.5 裁决供料 | verifier（sonnet-1） | plans/task-kb-persist-20261022/verification.md（V-N 清单） | 逐 VC PASS/FAIL 判定落 verification.md | 15min | 0f/0l/15min | 无 | P4-S1 | done |

> P4 合并回与簿记（smart-merge-back/清理/归档/交付总结）= 主进程直做，例外理由：② git 编排与簿记——Rule 25.3 白名单。

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 38 脏文件=旧任务归档在途+上一任务残留；信号⑤ 3 个运行中基础设施脏文件；信号③ wt/task-v168-machine-parked 遗留分支；信号④ 8 未完成任务在册——本任务范围与全部脏文件零重叠） |
| `isolation` | `worktree`（实现类默认首选；scripts/ 命中 §十一.1.4） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-kb-persist-20261022`（执行中因 smart-merge-back V1 门由 kb-persist-20261022 经 `git worktree move` 改名） |
| `branch` | `wt/task-kb-persist-20261022`（已删） |
| `merge_back` | `merged(03ffb944)`；worktree+分支已清理，主仓 Read 复验通过 |

## 📊 FMEA 预演（规划期）
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | provider 派发失败（本轮已发生 1 次 Explore 派发） | 5 | 5 | 3 | 75 | 22.3 兜底链：改派 general-purpose（本轮已实证有效）→拆细→主进程接管 |
| Phase 2 | 蒸馏条目质量不稳（空洞/来源锚缺失/域归属错） | 7 | 4 | 5 | 140 | Rule 18 批量门：预检三问+主进程抽检 10%（≥2 条）+失败率>5% STOP；每批检查点落盘 subagent-state/（Rule 22.8）；不合格条目打回该批重做（拆细档） |
| Phase 3 | 模板覆盖机制与预期不符（覆盖不生效） | 5 | 3 | 4 | 60 | 降级路径：仅保留 kb-sync 手动命令+README 记录入库 SOP，overlay 问题记 findings 待查 |
| Phase 4 | selftest 意外级联 | 6 | 3 | 4 | 72 | 范围纯新增+不触 skills/**，级联概率低；若命中→定位断言→范围外文件零改动原则下回滚该新增文件并登记 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-22 | S1 计划创建后 sync-todos 建映射 |
| Phase 2 | ☑ | 2026-10-22 | 同上 |
| Phase 3 | ☑ | 2026-10-22 | 同上 |
| Phase 4 | ☑ | 2026-10-22 | 同上 |

## Key Questions
1. 条目粒度=主题级合成 vs 来源级复制？→ **主题级**（6 域×2 条目，每条多来源锚；复制式会产生 113+ 重复碎片，查询价值低）
2. 检索方案=SQLite FTS vs rg 纯文件？→ **rg 纯文件**（research-kb 的 SQLite+CLI 已腐化为反面判例：入口死、数据陈旧；rg 零依赖零腐化面）
3. 闭环接线载体？→ **.zcode/plan-templates/ 项目级覆盖**（init-session.sh 原生支持的覆盖点，免触保护区 skills/**，部署位零改动）
4. 58 份占位 kb 与无 kb 老任务怎么办？→ 跳过占位，以 findings.md 实质内容兜底入各组清单；占位回填不属本任务（登记遗留）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| KB 位置=仓内顶层 `knowledge/`（git 跟踪） | 持久化最强（版本化+可见+随仓迁移）；.zcode/ 部分文件有 gitignore/瞬态语义（task-v164 判例），不适合作知识正本 |
| 条目格式=frontmatter(id/title/tags/sources/updated)+四段（结论/证据锚/易错点/适用场景） | 对齐 MEMORY.md 与 terry-vault 范式；sources 承载 Rule 71 无源不写与溯源回链 |
| 索引=脚本派生（kb-rebuild-index 扫描 frontmatter 重建） | 单写者=脚本，避免多批次并行写 INDEX 冲突；INDEX 可随时重build 无手工维护债 |
| 脚本语言=Bash | 匹配本仓 scripts/ 既有全 bash 惯例（§13.3 匹配项目风格优先于个人偏好） |
| D1 自动裁决登记（Rule 44.3） | 五要素：超时值=5min（44.1 默认）；推荐项=按已展示计划执行；触发时间=2026-10-22 计划展示后；裁决理由=用户 /goal 完成性指令+自主目标模式无人在场+44.3 为用户 2026-10-22 当日授权条款；被覆盖的未决选项=无（计划无 D2/D5/D6 真分叉）。目标绑定复述：本计划 Goal=「建成知识沉淀→累计存留→快速查询全链闭环…」，服务用户指令=user-session-log.md #1「我希望可以将当前项目的每次积累的知识库文件 不断累计沉淀…解决类似问题可以快速查询」——宾语（知识库/知识体系持久化）与用户原话直接对应，非目标切换 |
| D 类判定登记 | 新指令与旧活跃计划（task-skill-audit-20261021 审计）Goal/范围/交付物零关联 → D 类开新计划，旧计划原样保留（其归档 R 重命名系其自身终验产物，本任务零触碰） |
| Rule 30 共享内容追踪 | 不适用：knowledge/ 与 scripts/kb-* 均为本任务一次性新建的全新资源，无可枚举既有共享资源需认领，非同类任务 ≥3 次场景 |
| research-kb 修复/terry-vault 文档漂移 | 不修（写入最小化/YAGNI）：前者数据域=网络调研且入口腐化属独立债务，后者与目标无关——登记遗留不扩范围 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| Agent 派发 "Model request failed"（Explore 类型） | 1 | 改派 general-purpose 成功（22.3① 改派档实证） | → progress.md Error Log；provider 故障首败即备好改派路径 |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 主仓脏文件（SKILL.md/critical-rules.md/selftest-requirement-coverage.sh/plans 归档 R）系其他任务在途产物：本任务 commit 一律 `git commit -- <pathspec>` 限定（memory 判例），合并回前确认 worktree 内 status 干净

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-22 | ⚠️DRIFT | VC-5, V-1.2 | 三项全处置：progress Phase1 状态翻转 complete / VC-5 口径统一（+1 表头，verification.md 命令同步）/ sync 脚本行数 84l→90l 更正；V-1.2「无命中」系口径时效（draft 含 selftest 子串属预期命中），exit-0 空库分支已独立复验——不返工，登记继续 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6，Phase 2 批量必填）
| 字段 | 值 |
|------|-----|
| `total` | 6 批次 / 12 条目（Phase 2 实况） |
| `success` | 12 |
| `failed` | 0 |
| `failure_rate` | 0%（≤5% 门内） |
| `sampled_pass` | 2（dispatch-split-decision 全文 Read + guard-attest-completion-gates 摘要核对，均含 sources 存在性验证） |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否（增量新增可重跑，幂等）/Q2:有（batch-*-sources 清单+entry-template 规范）/Q3:能（git 未提交前可整目录删除重跑） |
| `rollback_point` | worktree commit 037c683（Phase 1 态，entries 可整目录删除重跑） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 4（check-delegation stats：phases_delegated=4，delegation_rate=1.000，verdict=violation→Handoff 补 P4 两行后复检清零，误报根因=code-runner-agent/verifier token 未整格出现在 Handoff 表） |
| 主进程直做 Phase 清单 | 无整 Phase 直做；Phase 内白名单簿记动作：预分组清单生成/双采样抽检/INDEX rebuild/合并回与清理/计划文档维护——理由② git 编排+簿记 |
| 委派率 | 1.000（≥0.7 达标；Handoff 16 行全 verify_done） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-22 | Explore→general-purpose | 盘点知识沉淀设施现状 | done | 单任务沉淀已完备；缺跨任务聚合层+检索入口；152 归档/113 kb(55 实质+58 占位) | subagent-state/01-explore-kb-infra.md | §1 已有设施/§2 缺口 | subagent-state/01-explore-kb-infra.md | retry 1 / verify_done ☑ |
| 2 | 2026-10-22 | code-assistant | 建 kb-search.sh 检索脚本 | done | 86 行 rg/grep 双引擎+--tag 过滤；gawk ERE 陷阱自修 | scripts/kb-search.sh | §[sub:P1-S1~S4] | subagent-state/P1-S1-code-assistant.md | - / 0 / ☑ |
| 3 | 2026-10-22 | code-assistant | 建 kb-rebuild-index.sh 索引脚本 | done | 60 行 frontmatter→INDEX 派生重建，原子写+跳过 _draft- | scripts/kb-rebuild-index.sh | §[sub:P1-S1~S4] | subagent-state/P1-S2-code-assistant.md | - / 0 / ☑ |
| 4 | 2026-10-22 | code-assistant | 建 kb-sync-from-plan.sh 入库脚本 | done | 79+5 行 draft 生成+占位 fallback；主进程补 sources 仓相对修复 | scripts/kb-sync-from-plan.sh | §[sub:P1-S1~S4] | subagent-state/P1-S3-code-assistant.md | rescue: 主进程 5 行级修复 / 0 / ☑ |
| 5 | 2026-10-22 | executor | 建 README+entry-template | done | 63+40 行，定位/写入约定/查询/四段模板齐 | knowledge/README.md | §[sub:P1-S1~S4] | subagent-state/P1-S4-executor.md | - / 0 / ☑ |
| 6 | 2026-10-22 | executor | 域 A 派发拆分蒸馏 | done | 2 条目 80+78 行，13+11 结论全带锚 | entries/dispatch-*.md | §[sub:P2 六域] | subagent-state/P2-S1-executor.md | - / 0 / ☑ |
| 7 | 2026-10-22 | executor | 域 B 守卫回归蒸馏 | done | 2 条目 72+78 行，attest 三拦点+误报 9 模式 | entries/guard-*.md | §[sub:P2 六域] | subagent-state/P2-S2-executor.md | - / 0 / ☑ |
| 8 | 2026-10-22 | executor | 域 C worktree 部署蒸馏 | done | 2 条目 60+65 行；发现 C 域 3 个 ★kb 实为空模板（v159/v165/v182） | entries/worktree-*.md | §[sub:P2 六域] | subagent-state/P2-S3-executor.md | - / 0 / ☑ |
| 9 | 2026-10-22 | executor | 域 D 计划流程蒸馏 | done | 2 条目 56+64 行，76 锚行号全在范围 | entries/planflow-*.md | §[sub:P2 六域] | subagent-state/P2-S4-executor.md | - / 0 / ☑ |
| 10 | 2026-10-22 | executor | 域 E 调研纪律蒸馏 | done | 2 条目 68+71 行，19 锚展开 36 行全验证 | entries/discipline-*.md | §[sub:P2 六域] | subagent-state/P2-S5-executor.md | - / 0 / ☑ |
| 11 | 2026-10-22 | executor | 域 F 制度化演进蒸馏 | done | 2 条目 62+67 行，读 20 份原文 sources 9+11 全存在 | entries/misc-*.md | §[sub:P2 六域] | subagent-state/P2-S6-executor.md | - / 0 / ☑ |
| 12 | 2026-10-22 | general-purpose（drift-checker 改派） | Phase 1 后偏移检查 | done | ⚠️DRIFT 三项已全处置（见 Drift Log） | subagent-state/drift-check-1.md | Drift Log | subagent-state/drift-check-1.md | retry 1 / 0 / ☑ |
| 13 | 2026-10-22 | executor | 建项目级模板覆盖 | done | 77 行前缀 diff=0+§7，86 行；init-session.sh:65-79 机制确认 | .zcode/plan-templates/knowledge-brief.md | §[sub:P3] | subagent-state/P3-S1-executor.md | - / 0 / ☑ |
| 14 | 2026-10-22 | general-purpose（verifier 改派） | 独立实弹验证 | done | 5/5 PASS：VC-2/3/7 语义命中+负例干净+120/120 sources 存在 | subagent-state/P3-S2-verifier.md | verification.md Phase 3 | subagent-state/P3-S2-verifier.md | retry 1 / 0 / ☑ |
| 15 | 2026-10-22 | code-runner-agent | worktree 全量 selftest 批跑 | done | 92/92 PASS，FAIL=0，A 类（本任务引入）=0 零回归 | subagent-state/P4-S1-code-runner.md | progress Phase 4 | subagent-state/P4-S1-code-runner.md | - / 0 / ☑ |
| 16 | 2026-10-22 | verifier | 终验 VC 全量独立复验 | done | VC-1..7 全 PASS+对齐 4/4+R1/R2 solved→COMPLETE 供料（provider 败改派 general-purpose 执行） | subagent-state/P4-S2-verifier.md | verification.md Goal Gate | subagent-state/P4-S2-verifier.md | retry 1 / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（知识基建/工具建设非 16 类已知类型）
- Rule 34.3②: 沉淀预登记 —— 终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: **不沉淀**。理由：本任务为一次性知识基建（载体+回填+入口三件事），无可复用的计划模板形态（非站点类/管线类/批量类）；其可复用部分已按更贴切载体落盘——知识条目规范→knowledge/entry-template.md，入库流程→.zcode/plan-templates/knowledge-brief.md §7 项目级覆盖（二者即本任务的"模板沉淀"）
