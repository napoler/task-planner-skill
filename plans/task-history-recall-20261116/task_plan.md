# Task Plan: 新建 plan-history-recall 技能（跨任务历史经验挖掘）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 已由 init-session.sh render_template() 渲染；尖括号中文占位=模型填写面 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  选定 variant 后 template_type 填所选类型名；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}；execution_lane ∈ {L0, L1, L2}（缺省 L1）
  check-template-type.sh 三形态之一：行首 `^template_type:`；本块用行首形态 -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
- **R1**: 「我希望引入一个新的技能……基于当前的文档体系进行调研……作为一个理解用户整个创造过程，或者说开发过程的全流程的理解」<sub>（[目标]）</sub>
- **R2**: 「再配合，再加上Git的提交历史记录，这样就更可以更完善的了解之前做过什么，便于后期下结论」<sub>（[目标]）</sub>
- **R3**: 「后期的一些对任务的规划，作为一些经验，或者说是类似的一些参考……作为梳理之前的一些任务的一些参考」<sub>（[手段]：产出形态=规划期经验简报+轻接线）</sub>
- **R4**: 「[$using-superpowers] 方法论载体（brainstorming→writing-plans 先行）」<sub>（[手段]：过程合规锚）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 6 交付物在位可 grep；真实主题全链实测简报含盘上可查证据锚 |
| R2 | VC-2, VC-4 | 简报含 git 提交面证据锚；selftest 注册且通过 |
| R3 | VC-3, VC-6 | 护栏数字落字可 grep；task-planner 接线行在位+零回归 |
| R4 | VC-6 | brainstorming/design/ece4419 过程留痕+收尾对齐审查 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-history-recall-20261116/user-session-log.md`（模板 = /home/terry/.zcode/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 路由（INDEX/grep） | 关键词盲搜漏合规件（task-enumerate-first 判例） | S1 SOP 双通道路由（INDEX 主表+git log --grep）+候选清单留排除理由 | VC-2 |
| 挖掘（子代理读档） | 子代理编造输出（subagent-verifier-fabricated 判例） | S2 卡 schema 强制文件级证据锚+主进程盘上抽查（VC-2 反造谣门） | VC-2 |
| 简报综合 | 无对标下结论/脑补 | S3 模板强制证据锚索引+未覆盖面段 | VC-2, VC-3 |
| 触发（接线） | 技能惰性闲置（task-v139 判例） | S5 task-planner L1+ 规划期建议指针 | VC-6 |
| 回归（selftest） | 基线漂移误判（64.6 笔误判例） | S6+S8 registry 登记+--fresh 基线对照（已知 FAIL=2 为基线） | VC-4, VC-6 |

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R4 原文；VC-1..6 判据；成本护栏数字（候选 ≤8/≤3 并行×每代理 ≤3 任务/简报 ≤150 行/卡 ≤60 行）；只读纪律（禁写任何历史任务文件）；部署 diff=0 标准 | 本文件 R/VC 段+design §5/§6 |
| 🔀 可变量 | S-unit 排期与执行体选型；SKILL.md 非锚定性措辞微调；部署位枚举实测结果；简报/卡的具体行数（≤上限内） | design §4 |
| 📈 学得量 | 实测发现/经验卡内容/教训 → findings.md / notepad-learnings.md；禁反写不变量 | findings.md |

## Goal
新建 plan-history-recall 技能全家桶（SKILL.md+经验卡 schema+简报模板+history-miner 伴飞子代理+task-planner 轻接线+selftest），使规划期可按需从 plans/ 文档体系+git 历史挖掘过往任务经验并产出证据锚齐全的简报。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（含 bash selftest 脚本+受管 SKILL.md 修改） |
| `session_id` | db9eb46e66514334996910187b91c25f（本会话） |
| `worktree_path` | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-history-recall-20261116 |
| `scope_files` | skills/plan-history-recall/**, skills/task-planner/companion/agents/history-miner.md, skills/task-planner/SKILL.md(接线行), skills/task-planner/scripts/selftest-plan-history-recall.sh, skills/task-planner/scripts/selftest-registry.tsv(+1 行), plans/task-history-recall-20261116/**, 四技能部署位+双 agent 部署位镜像 |
| `interaction_mode` | ask |
| `对齐审查` | 已登记：收尾跑 alignment-review（Rule 42.6 标准收尾） |
| `自动超时默认项` | brainstorming 三询问点已问已答（回执留痕）；部署矩阵=实测探测先行（自动裁决 5min）；CR 轮次默认 2 轮上限 5min/轮 |
| `new_rule` | 留空 |
| `质量审查工具` | critic（既有 agent，CR 门；Rule 42.2 检测结论=既有在位） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：独立复检由 critic 子代理执行（Phase 4 S9）；主进程自测不作为唯一验收。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 6 交付物在位且 frontmatter 合规（SKILL.md/schema/template/history-miner/接线行/selftest+registry 行） | 盘上 test+grep 锚 | 见 verification.md VC-1 Verify command |
| VC-2 | 真实主题全链实测（dogfood）：history-brief.md 存在且 ≥3 条证据锚盘上命中（反造谣门） | 产出文件+锚抽查 | plans/task-history-recall-20261116/history-recall/history-brief.md |
| VC-3 | 成本护栏数字在 SKILL.md 落字可 grep（候选 ≤8/每代理 ≤3 任务/简报 ≤150 行/卡 ≤60 行） | grep 四锚 exit 0 | skills/plan-history-recall/SKILL.md |
| VC-4 | selftest-plan-history-recall.sh 注册 registry 且 --only 跑批 FAIL=0 | runner 回执 | skills/task-planner/scripts/selftest-registry.tsv |
| VC-5 | 部署同步：4 技能位+2 agent 位+task-planner 3 变更文件×4 位 diff=0 | diff -rq 全对账 | 部署位实测路径（§Phase 5） |
| VC| VC-6 | task-planner SKILL.md 接线行在位；--fresh 全量回归无新增 FAIL（判据=FAIL 数等于基线记录值，基线实测 2026-11-16=5 见 baseline-selftest.log；「FAIL=2」系陈旧记忆值已废弃） | grep+runner+基线对比 | skills/task-planner/SKILL.md |

**终验规则**：全部 VC 通过 → COMPLETE；有遗留 → PARTIAL 列明；3 次重试无效 → BLOCKED。
> code_review: required → 终验前必须过 CR Gate（critic APPROVED，Phase 4 S9）。

## 🛡 双轮质检与同步完整性声明（Rule 103）
| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | S1-S6（派发型实质产出：执行体自审 checkpoint + 全新子代理独立复检 S9 覆盖全部产物） |
| 豁免登记 | S7 实测（主进程编排+产物即复验对象，103.7 理由：验证类动作自带第二道）；S8 机械脚本跑批 |
| 多文件变更集预判 | Phase 5 部署（≥2 受管文件跨 6 部署位）→ 103.6 关联面四族核对清单：SKILL 家族（源仓 3 文件+4 位镜像）/agent 家族（源+2 位）/selftest 家族（脚本+registry）/计划档案（本目录） |

## 🎯 核心目标达成裁决（Rule 58.5 — 终验必填）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2 |
| **裁决** | （终验填：solved/partial/not-solved） |
| **解决证据锚** | （终验填） |
| **未解决面+原因** | （如 partial） |
| **已排除路径** | （如 not-solved） |
| **下一步建议** | （如 not-solved） |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 计划锁定 | attest 全门绿锁定计划 | attest-plan.sh exit 0+SHA 回执 | Phase 2 | pending |
| G2 | 交付物在位 | worktree 内 6 交付物落位合规 | VC-1 Verify command exit 0 | S1-S5/Phase 3 | pending |
| G3 | selftest 绿 | 新 selftest 注册且通过+全量零回归 | VC-4+VC-6 Verify command exit 0 | S6,S8/Phase 3-4 | pending |
| G4 | 实测反造谣门 | dogfood 简报证据锚盘上命中 | VC-2 Verify command exit 0 | S7/Phase 4 | pending |
| G5 | CR APPROVED | critic 复检 6 交付物通过 | critic 回执两态=APPROVED | S9/Phase 4 | pending |
| G6 | 部署合并收口 | 6 部署位 diff=0+merge 回 master+worktree 清理 | VC-5 Verify command+git worktree list 无 wt/task-history-recall | Phase 5 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新技能 | skills/plan-history-recall/SKILL.md、references/experience-card-schema.md、references/brief-template.md | 其他技能目录 |
| 伴飞 agent | skills/task-planner/companion/agents/history-miner.md | 其他 agent 文件 |
| 受管修改 | skills/task-planner/SKILL.md（仅 1 行接线增量）、scripts/selftest-registry.tsv（仅 +1 行） | critical-rules.md 及其他规则文件 |
| selftest | skills/task-planner/scripts/selftest-plan-history-recall.sh | 其他 selftest 脚本 |
| 计划档案 | plans/task-history-recall-20261116/** | 其他任务计划目录（旧任务交接登记除外，已落） |
| 部署位 | 四技能位+双 agent 位镜像文件（文件级 cp） | 部署位其他文件 |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据 | 执行动作 |
|------|------------------|------|---------|----------------|------|---------|
| CA-1 | skills/plan-history-recall/SKILL.md（新建） | 新增 | 增量 | 「引入一个新的技能」 | design §3 | S1 落位 |
| CA-2 | skills/plan-history-recall/references/experience-card-schema.md（新建） | 新增 | 增量 | 同 R1 | design §5 | S2 |
| CA-3 | skills/plan-history-recall/references/brief-template.md（新建） | 新增 | 增量 | 同 R1 | design §4 | S3 |
| CA-4 | skills/task-planner/companion/agents/history-miner.md（新建，路径修订：伴飞先例实际在 companion/agents/，非仓库根 agents/） | 新增 | 增量 | 同 R1 | design §3 修订注记+drift-checker 先例 | S4 |
| CA-5 | skills/task-planner/SKILL.md:C2 段（L50-51 初始化首动作委派块后）+1 行 | 修改 | 增量 | 「后期的一些对任务的规划，作为一些经验」 | design §7 | S5 |
| CA-6 | scripts/selftest-plan-history-recall.sh + selftest-registry.tsv:+1 行（新建/追加） | 新增 | 增量 | 同 R2 | design §8 VC-4 | S6 |

## 📚 必要知识储备（开工前必填）
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部 | drift-checker.md（伴飞 agent 格式先例） | skills/task-planner/companion/agents/drift-checker.md | 必读 | ☑（Explore 实读 36 行全文） |
| 项目内部 | plan-resume/SKILL.md（技能格式先例） | skills/plan-resume/SKILL.md | 必读 | ☑（frontmatter+骨架实读） |
| 项目内部 | selftest-cross-validation.sh（selftest 结构先例） | skills/task-planner/scripts/selftest-cross-validation.sh | 必读 | ☑（头注释+断言模式实读） |
| 项目内部 | selftest-registry.tsv（4 列 schema） | skills/task-planner/scripts/selftest-registry.tsv | 必读 | ☑ |
| 项目内部 | run-selftests.sh 用法 | skills/task-planner/scripts/run-selftests.sh | 必读 | ☑（--fresh/--only/--status） |
| 项目内部 | worktree-isolation.md | /home/terry/.zcode/skills/task-planner/references/worktree-isolation.md | 必读 | ☑（§十一 引用） |
| 项目内部 | subagent_dispatch.md（8 字段派发模板） | /home/terry/.zcode/skills/task-planner/templates/subagent_dispatch.md | 参考 | ☐（执行期派发前确认） |
| 项目内部 | 本任务 design/findings/user-session-log | plans/task-history-recall-20261116/ | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 新技能能否被触发并产出「证据锚可盘上验证」的历史经验简报？
- [x] 核心问题解决后，产品/结果能交付吗？（能——VC-2 即解决判据）
- [x] 核心问题不解决，其他工作都白费吗？（是——SOP/schema/agent 均为此服务）
- [x] 核心问题的解决方法是清晰的、可执行的？（design §4 五段数据流）

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|--------------|--------------|
| 全部 S-unit | LOCAL-ONLY | （本仓内部事实，findings.md 已锚定一手事实） | 本仓文件+git | 交付物文件 | 不适用 |

> 豁免声明：本任务为仓内基建任务，设计期调研已完成（findings.md，Explore 子代理一手取证）；无 NET-* 条目系 LOCAL-ONLY 全表覆盖。

## 🔍 证据面清单（Rule 58.1）
n/a（纯执行类——产出为技能文件，非结论/判断/归因类报告；参照物=既有技能先例已在知识储备表锚定）

## Current Phase
Phase 4（实测+回归+CR）

## Next Step
S7 dogfood 实测（派 history-miner 挖「worktree 隔离与合并回」主题）→ S9 critic CR → 六位部署+merge back+归档收口

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | Agent 子代理 Explore/drift-checker + AskUserQuestion 用户门 | brainstorming 方法论：调研委派+裁决用户门（已完成） |
| Phase 2 | 主进程（attest/写计划） | ② 计划系统文件维护——Rule 25.3 白名单 |
| Phase 3 | Agent 子代理 executor（worktree 内落位） | 内容已完整定稿于 plan+draft，executor 机械落位保真 |
| Phase 4 | Agent 子代理 history-miner（实测）/critic（CR+复检）+主进程机械跑批 | 实测即技能真实用法；独立复检委派 |
| Phase 5 | 主进程 | ① git 编排+② 簿记——Rule 25.3 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（S-unit 链式依赖强：S1→S2-S5→S6→实测→部署），走 Rule 21.4 独立性守门调度
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal（/goal [$using-superpowers] 历史经验挖掘技能）的证据源

## Phases

### Phase 1: Requirements & Discovery（brainstorming 三裁决+design 获批）
- [x] 用户意图澄清（Q1 按需/Q2 显式+轻接线/Q3 全家桶，AskUserQuestion 回执）
- [x] 项目上下文调研（findings.md：185 归档/七文档/kb 基座/缺口确认）
- [x] 设计获批+落盘（design.md，commit ece4419，drift ALIGNED）
- [x] 知识储备必读项确认（见必要知识储备表）
- **V-N:** VC-2（设计含反造谣门）、VC-3（护栏数字已定）
- **Status:** complete
- **Executor:** 主进程（例外理由：brainstorming 用户对话门必须主进程；调研已派 Explore 子代理+drift-checker 偏移检查）

### Phase 2: Planning & Structure（计划定稿+attest 锁定）
- [x] 实施契约事实收集（Explore 四族：agent 格式/selftest 体系/接线点/部署位实测）
- [x] task_plan.md+verification.md+draft-SKILL.md 定稿
- [ ] attest-plan.sh 锁定（Goal 单元表/VC/FMEA 门链全绿）
- **V-N:** VC-1, VC-6（本 Phase 验收映射）
- **Status:** in_progress
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Implementation（worktree 内 6 交付物）
- [x] git worktree add tmp/worktrees/task-history-recall-20261116 -b wt/task-history-recall-20261116 master（HEAD=4840758，drift 检查点#2 ALIGNED）
- [x] 按 S-unit 表逐单元派发落位；每单元完成回填 Handoff 表+progress.md（S1-S6 done，feat cbc9c2a）
- [ ] 规范召回（Rule 93）：每 3 个 S-unit/Phase 翻转主进程 Read ../task-discipline/references/execution-recall-card.md 并 progress 留 [recall] 行
- **V-N:** VC-1, VC-3（本 Phase 验收映射）
- **Status:** complete
- **Executor:** executor（S-unit 表派发；worktree 绝对路径写入每份派发 prompt；禁触碰其他 worktree）

<!-- S-unit 派发单元表(Rule 22.6)：机器契约——预估时长 NNmin；输入列路径 token ≤2；ID 纯数字；粒度三值列 Nf/Nl/Nmin；10 列固定列序禁增列禁转义；前置依赖必填无则 - -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 创建 skills/plan-history-recall/SKILL.md（draft 落位+frontmatter 适配） | executor | plans/task-history-recall-20261116/draft-SKILL.md（完整内容草稿：frontmatter 三字段+五步工作流+护栏数字+边界表） | 文件在位；grep name: plan-history-recall 命中；95±15 行 | 15min | 1f/95l/15min | 无 | - | pending |
| S2 | 创建 references/experience-card-schema.md（九字段卡契约） | executor | plans/task-history-recall-20261116/design.md（§5 九字段表+证据锚格式+禁脑补条款+落盘命名 cards/<task-id>.md） | 文件在位；九字段表头 grep 命中；≤60 行 | 10min | 1f/50l/10min | 无 | S1 | pending |
| S3 | 创建 references/brief-template.md（简报结构模板） | executor | plans/task-history-recall-20261116/design.md（§4 Stage 3-4+§6 护栏：候选清单/四维结论/证据锚索引/未覆盖面） | 文件在位；四维结论段+证据锚索引表 grep 命中 | 10min | 1f/55l/10min | 无 | S1 | pending |
| S4 | 创建 companion/agents/history-miner.md（对齐 drift-checker 先例） | executor | skills/task-planner/companion/agents/drift-checker.md（frontmatter 逐字段先例：name/description/model custom 串/thoughtLevel/tools/color）+ plans/task-history-recall-20261116/design.md（§5 卡契约引用） | frontmatter 六字段齐；SOP 步骤+只读硬约束 grep 命中 | 10min | 1f/45l/10min | 无 | S1 | pending |
| S5 | task-planner SKILL.md 接线：C2 段（初始化首动作委派块）后 +1 行建议指针 | executor | skills/task-planner/SKILL.md（L50-51 插入点上下文）+ plans/task-history-recall-20261116/design.md（§7 措辞草案逐字） | 接线行 grep 'plan-history-recall' 命中；仅 +1 行无其他改动（git diff 行数核对） | 5min | 1f/3l/5min | 无 | S1 | pending |
| S6 | 创建 selftest-plan-history-recall.sh + registry +1 行 | executor | skills/task-planner/scripts/selftest-cross-validation.sh（结构先例：头注释用例编号+set -u+PASS/FAIL 计数+Total+exit 约定）+ skills/task-planner/scripts/selftest-registry.tsv（4 列 schema） | 脚本可执行 exit 0；registry 行首 selftest-plan-history-recall.sh grep 命中 | 15min | 2f/75l/15min | 无 | S2、S3、S4、S5 | pending |

### Phase 4: Testing & Verification（实测+回归+独立复检）
- [ ] S7 dogfood 全链实测（主题=「worktree 隔离与合并回」）：按 SKILL SOP Stage 0→4，派 history-miner 产卡+简报落 plans/task-history-recall-20261116/history-recall/
- [ ] S8 selftest：--only plan-history-recall FAIL=0；--fresh 全量基线对照（FAIL≤2 无新增）
- [ ] S9 独立复检+CR：critic 对 6 交付物+design 逐条对照（两轮收敛 APPROVED）
- [ ] Verify all requirements met（VC 逐条复验）+ test results 落 progress.md
- [ ] 全文档收尾回读梳理记录（Rule 84.14）
- **V-N:** VC-2, VC-4（本 Phase 验收映射）
- **Status:** in_progress
- **Executor:** 主进程（例外理由：技能实测编排=主进程职责+S8 机械跑批；独立复检/CR 已派 critic 子代理）

### Phase 5: Delivery（部署+合并回+收口）
- [ ] 部署六位文件级同步：技能 4 位（~/.zcode|~/.agents|~/.claude|~/.cursor/skills/plan-history-recall/）+agent 2 位（~/.zcode|~/.claude/agents/history-miner.md）+task-planner 3 变更文件×4 技能位（SKILL.md/selftest 脚本/registry.tsv）；diff -rq 全对账=0
- [ ] 合并回：git merge --no-ff wt/task-history-recall-20261116 → Read 关键文件+git log 复验 → git worktree remove + git branch -d（§11.3 六条全满足）
- [ ] master 复跑 run-selftests --fresh 基线对照 + attest VC 复验
- [ ] INDEX 刷新 + 归档：check-complete exit 0 后 set-active-plan --clear → archive-plan.sh task-history-recall-20261116 --root <plans根>（Rule 81）
- [ ] 知识提取入库（条件式）：bash scripts/kb-sync-from-plan.sh plans/task-history-recall-20261116 → 精炼改名 → kb-rebuild-index.sh
- [ ] 归档计划：同上 Rule 81 行
- [ ] 知识提取入库（条件式：项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做）
- **V-N:** VC-5, VC-6（本 Phase 验收映射）
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14）
| 轮次 | 发现 | 处置 |
|------|------|------|
| 1    |      |      |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（新目录为主；受管面=task-planner SKILL.md +1 行/registry +1 行，与并行任务无重叠——并行会话已收口 4189ec6） |
| `isolation` | worktree（§11.1① 保护区强制） |
| `worktree_path` | /mnt/data/dev/task-planner-skill/tmp/worktrees/task-history-recall-20261116 |
| `branch` | wt/task-history-recall-20261116 |
| `merge_back` | pending |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|---------|---|---|---|-----|------------------------------|
| Phase 3 | selftest 断言锚与产物实际字符串不一致 | 6 | 6 | 4 | 144 | 兜底④主进程接管修正：锚串取自 draft-SKILL.md 实测字符串，S6 派发前主进程 grep draft 预验锚串存在 |
| Phase 3 | history-miner frontmatter 模型串不可路由 | 7 | 4 | 5 | 140 | 兜底④：model 行逐字复制 drift-checker 同款 provider 串（custom:9e221f47-…:haiku-1 形态），S4 验收含 frontmatter 六字段核对 |
| Phase 4 | 简报证据锚虚假（子代理编造） | 8 | 4 | 6 | 192 | 兜底④：主进程盘上抽查 ≥3 锚（VC-2 反造谣门）；发现虚假=重派并按 §三 记 Error Log |
| Phase 5 | 部署位漂移/漏位 | 7 | 5 | 5 | 175 | 兜底④：文件级 cp（pathspec 锁定）+diff -rq 全对账；位清单以实测探测为准（plan-resume/drift-checker 实锚已探） |
| Phase 5 | merge 冲突 | 6 | 3 | 4 | 72 | （≤100 免兜底；发生时 22.3 链） |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-16 | brainstorming 十项 Todo 全链跟踪 |
| Phase 2 | ☑ | 2026-11-16 | TodoWrite 实施段六项 |
| Phase 3 | ☑ | 2026-11-16 | 同上（实施+收口段） |
| Phase 4 | ☑ | 2026-11-16 | 同上 |
| Phase 5 | ☑ | 2026-11-16 | 同上 |

## Key Questions
1. dogfood 实测主题是否能在 ≤8 候选内命中足够相关任务？（Phase 4 验证；不足则换主题重跑，记 findings）
2. 接线行是否触碰既有 selftest 内容断言？（S5 后跑 --fresh 对照确认）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| agent 路径修订为 skills/task-planner/companion/agents/history-miner.md | Explore 实测：仓库根无 agents/，伴飞先例 drift-checker 在 companion/agents/（36 行实读）；design §3 已补修订注记 |
| history-miner model 行复制 drift-checker 同款 provider 串（haiku-1 级） | 仓内实证可路由；轻档符合 §一 分档（读档提取=轻任务） |
| dogfood 主题=「worktree 隔离与合并回」 | 本仓归档高密度主题（task-v195/v182/worktree-isolation 等多任务相关），实测命中率高 |
| SKILL.md 控制在 ≤95 行 | attest S-unit 粒度门 ≤100l；plan-* 家族为轻量卫星（plan-research-router 先例） |
| selftest 基线=FAIL 2（master 既有预存） | 记忆 task-docmod-recheck 判例：master 2 预存 selftest FAIL；判据=无新增而非 FAIL=0 |
| Phase 3 派发 executor 而非主进程直写 | 委派纪律+保真：内容已定稿于 plan/draft，落位=机械执行 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （暂无） | 1 | | |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 实测/部署命令相对仓根执行；worktree 内产物路径=worktree 相对路径

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-16 | drift-checker ALIGNED（brainstorming 收口点） | 设计面 | 检查点 plans/task-history-recall-20261116/.drift-checkpoint.md（commit ece4419） |
| 2026-11-16 | ALIGNED #2（Phase 2 收口）/#3（Phase 4 CR1 修复轮收口） | 设计面+执行面 | 同检查点追加条目；CR2 后台复检中 |

## 📦 Batch Report（Rule 18.6）
| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | （终验填，预判 2/5） |
| 主进程直做 Phase 清单 | Phase 1（brainstorming 用户门）Phase 2（②白名单）Phase 5（①②白名单） |
| 委派率 | （终验填；主进程 Phase 均有白名单理由登记） |
| 激活子代理数（Rule 96.5） | （终验填） |
| 最大并行宽度（Rule 96.5） | （终验填） |
| 串行化例外理由（Rule 96.4） | none（S-unit 链式依赖，无并行组） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-16 | Explore | plans 体系与召回技能面调研 | done | 185 归档/七文档集/缺口确认；抽查一致 | findings.md 全文 | findings.md §1-4 | - | - / 0 / ☑ |
| 2 | 2026-11-16 | drift-checker | brainstorming 收口偏移检查 | done | ALIGNED | .drift-checkpoint.md | task_plan Drift Log | plans/task-history-recall-20261116/.drift-checkpoint.md | - / 0 / ☑ |
| 3 | 2026-11-16 | Explore | 实施契约四族事实 | done | agent 格式/selftest 体系/接线点 C2/部署位实测 | 本计划知识储备表 | findings.md+本计划 | - | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 终验时评估填写；初判=技能型交付已有 16 类画像外先例（plan-* 卫星族），不沉淀 variant 概率高
