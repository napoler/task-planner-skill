# Task Plan: task-planner 核心技能专业化拆分（四文件罗盘收口 + 76 规则分层归属）
execution_lane: L2

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->
<!-- 2026-10-07 task-v143：Rule 58.4 手段/目标二分——每条 R 行末尾标注 [手段] 或 [目标]；[目标] 行必须映射 ≥1 条「问题解决判据」VC（核心问题的可观察解决证据，非手段产物完成）；目标型任务终验必填「🎯 核心目标达成裁决」区块（58.5） -->

- **R1**: 「我希望就是将技能专业化，确保该技能主要就是处理记录记录任务这些相关的工作，就是只处理核心主主要技能……核心就是对这4个文档的进行管理。」<sub>（[目标]：task-planner 核心技能=四文件罗盘记录/文档管理）</sub>
- **R2**: 「其他的内容的话，我希望你可以其他的嗯就是比如其他更专业的工作，我希望可以单独独立化为专业技能，确保核心技能的唯一性，就是说专业性。」<sub>（[目标]：非记录类工作独立为专业技能，核心保持唯一性）</sub>
- **R3**: 「不要什么都负责，什么都负责只会导就是只会导致最终产出的东西混乱不堪。」<sub>（[目标]：杜绝全包，产出边界清晰不混乱）</sub>
- **R4**: 「基础任务，当前的技能的任务就是制作计划……核心工作就一个，所有的工作就是维护Task Planner这个文档以及相关的内容。」<sub>（[目标]：核心工作=制作计划+维护四文件罗盘及相关内容）</sub>
- **R5**: 「涉及其他的功能的话，其他技能的，就是调用其他技能来实现，而不是所有东西都自己实现。」<sub>（[手段]：非核心功能以路由调用卫星技能实现）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-4 | SKILL.md≤250 行且正文仅覆盖计划制作/四文件维护/卫星路由（grep 主题词分布可数）；七卫星各含其职责规则全文 |
| R2 | VC-3, VC-4 | 3 新卫星 SKILL.md frontmatter 合规+install-stub 注册行存在；7 既有卫星收编后 SKILL.md 索引更新 |
| R3 | VC-2, VC-5 | 78 条规则全集唯一完整机检 PASS（76 既有+81+82，并集解口径）；核心 selftest+task-dispatch 2 selftest 全量 FAIL=0 |
| R4 | VC-1 | SKILL.md 正文首屏即「四文件罗盘」定位段+计划制作循环；无非职责段落 |
| R5 | VC-4, VC-7 | 核心含卫星路由表（技能名/域/调用条件）；hook 链 4 adapter 调用目标全在位可执行 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则归属 | 76 规则全部堆在核心 critical-rules.md，无边界 | P4-P7 分层迁移到 10 个归属面 | VC-2 |
| 核心定位 | SKILL.md 什么都讲，无卫星路由 | P7 SKILL.md 重写+路由表 | VC-1 |
| 脚本引用 | 5 个 script 搬家后核心侧 caller 断链 | P4 S8-S11 caller 全域更新（design-architecture §5 清单） | VC-6, VC-7 |
| selftest 守护 | 56 selftest 断言 CRIT 里将被删的规则文本 | P7 锚修复 3 批+BP-08 口径演进 | VC-5 |
| 部署面 | master 合流但部署位未同步 | P8 merge-back+只读对账（写入待授权） | VC-8 |

<!-- plan_tier: standard -->
<!-- template_type: migration -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）
<!-- WHAT: 任务要素显式分三态——不变量(锁)/可变量(自主调+登记)/学得量(只入 findings、禁反写不变量)。
     WHY: 用户 R2「强化四文件，确保哪些不变/哪些可变/哪些学得」；无声明=执行期风格/范围漂移无对照物（R1 实证）。 -->
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R5 用户需求原文；VC-1..VC-8 全集；Rule 82=技能专业化分层纪律（防回归）；77 规则文本逐字保留（仅换归属位置不改文）；机器契约 step_max 与 attest 四锚不变 | task_plan.md 对应章节锚 |
| 🔀 可变量 | 各 Phase 执行体选型、S-unit 批次内规则排序、文档措辞、迁移批次切分粒度、工具编排 | - |
| 📈 学得量 | caller 面复查新增事实（install.sh）、BP-08 演进值实测、CR 意见 → findings.md；禁反向改写不变量 | findings.md |

## Goal
task-planner 核心技能完成专业化拆分：核心只负责四文件罗盘管理（计划制作+记录文档），76 条既有规则+5 个脚本+2 个目录分层归属到 task-dispatch/task-discipline/media-planner 三个新技能与 7 个既有卫星，SKILL.md 瘦身至 ≤250 行并挂卫星路由表，新增 Rule 82 制度化防回归；全量机器门控与 selftest 零回归。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（涉及脚本搬迁+门控/契约维护，非纯文档） |
| `session_id` | `pending-attest-gen`（attest 时生成注册） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v171-skill-specialization`（§十一 隔离决策同字段） |
| `scope_files` | `skills/task-planner/**`、`skills/task-dispatch/**`（新建）、`skills/task-discipline/**`（新建）、`skills/media-planner/**`（新建）、`skills/plan-research-router/**`、`skills/plan-template-kit/**`、`skills/plan-collab-router/**`、`skills/plan-cost-guard/**`、`skills/plan-resume/**`、`skills/progress-tracker/**`、`skills/task-drift-guard/**`、`plans/task-v171-skill-specialization/**` |
| `interaction_mode` | `ask`（Rule 28：KQ1-KQ3 三决策点+Phase 完成时确认） |
| `对齐审查` | P7 完成前跑 alignment-review（SKILL/critical-rules 与卫星 SKILL 交叉引用一致性）；文档更新前跑版本一致性校验；变更记录随交付物落盘 |
| `自动超时默认项` | KQ1 归属范围→推荐归一 task-discipline；KQ2 selftest 留守/随迁→推荐随迁 2 个+留守 75 个锚重定向；KQ3 部署同步→推荐 P8 止于 master merge+只读对账，写入待授权。超时 5 分钟默认项自动执行+登记五要素（Rule 44.3） |
| `new_rule` | `82` |
| `质量审查工具` | `critic`（P8 S43 CR Gate 独立审查+意见逐条闭环）；`alignment-review`（P7 收尾，review-library 池成员） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行（Executor 字段可填 V-类执行体），主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | SKILL.md ≤250 行且正文仅覆盖计划制作+四文件维护+卫星路由（无子代理派发/纪律/媒体执行内容） | `wc -l skills/task-planner/SKILL.md` + 主题词 grep 分布 | 命令输出+文件路径 |
| VC-2 | 78 条规则（76 既有+Rule 81+Rule 82）全集唯一完整：每个编号恰在一个 home 的 critical-rules/references 中出现一次 <!-- 2026-10-12 并集解口径修订：master 并行落地 task-v170 Rule 81（merge 前并集解，先例=1651371 v169 Rule 80 双纪元并集），Rule 81 归核心，全集 77→78 --> | 遍历 1-78 编号 grep 各归属文件，输出「编号×home」对照表核验无重复无缺失 | 脚本+对照表 |
| VC-3 | 3 新卫星（task-dispatch/task-discipline/media-planner）SKILL.md frontmatter 合规且含路由索引段 | frontmatter 解析+索引 grep | 文件路径+grep 输出 |
| VC-4 | 7 既有卫星各含其收编规则全文+SKILL.md 索引更新（16 条收编规则全部落位） | 逐卫星 grep 规则编号+标题 | grep 输出×7 |
| VC-5 | 全量回归 FAIL=0：核心 selftest 77→75（2 个随迁）+task-dispatch 2 个 selftest 各自全绿 | `run-selftests.sh` 输出+task-dispatch 独立跑 2 selftest | 命令输出 |
| VC-6 | 核心门控未破：check-complete 全门 exit 0；attest-plan 四锚+FMEA 门可正常锁定新计划 | attest-plan.sh 试跑+check-complete.sh 试跑 | 命令输出 |
| VC-7 | hook 链零断：4 个 zcode-*.sh adapter 调用目标脚本全在位可执行 | 逐 adapter grep 目标路径+-x 检查 | grep+test -x 输出 |
| VC-8 | 删除基线清零（Rule 36.3：核心无残留移走规则文本与悬空引用）；merge-back 完成（master 含 wt 分支合流 commit）；部署位只读对账完成 | grep 残留+git log 合流记录+diff 对账表 | 三件证据 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate（详见 SKILL.md），否则不得标记 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2, R3, R4 |
| **裁决** | `pending`（Phase 8 终验时三选一必填） |
| **解决证据锚** | （solved 必填：VC-1..VC-8 全绿证据+用户确认「核心技能唯一性」达成） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （not-solved 必填，按 Rule 70：对象路径+看点+动作） |

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 需求架构定稿 | 需求逐条归档+分层架构锁定+计划获批准锁 | attest-plan.sh exit 0 + Rule 82 预留回执 | P1-P3 | complete |
| G2 | dispatch 落成 | task-dispatch 11 规则+7 脚本+3 references 归位+caller 全更新 | 路径核对清单 grep 全绿+git status 干净 | P4 S2-S13 | pending |
| G3 | discipline 落成 | task-discipline 36 规则+capabilities/+plan-hygiene 归位 | 编号对照表 36 行全在位 | P5 S14-S21 | pending |
| G4 | 卫星体系落成 | media-planner 新建+7 卫星 16 规则收编 | 7 卫星 grep 全绿+frontmatter 合规 | P6 S22-S30 | pending |
| G5 | 核心瘦身 | SKILL.md≤250 行四文件专属+CR 重构+Rule 82 写入 | wc -l + grep 规则数=11 + 路由表段存在 | P7 S31-S40 | pending |
| G6 | 回归门控 | 全量 selftest FAIL=0+hook 链通+attest 门可锁新计划 | run-selftests 输出+四件门控试跑 | P8 S41-S42 | pending |
| G7 | 合并对账 | master 合流 commit 在位+部署位对账表完成 | git log+diff 对账 | P8 主进程动作 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/技能 | `skills/task-planner/**`（核心：SKILL.md、references/critical-rules.md、scripts 5 移出+caller 更新、selftest 锚修复、install.sh/install-stub.sh/lib/verify.sh caller 行、README/ARCHITECTURE）、`skills/task-dispatch/**`（新建）、`skills/task-discipline/**`（新建）、`skills/media-planner/**`（新建）、`skills/{plan-research-router,plan-template-kit,plan-collab-router,plan-cost-guard,plan-resume,progress-tracker,task-drift-guard}/**` | 其他 skill 目录、`hooks/`、`agents/`、`config.json` |
| 计划文档 | `plans/task-v171-skill-specialization/**` | 其他 plans 目录（含 archive） |
| 部署位 | 只读对账（`~/.zcode`、`~/.claude`、`~/.config/opencode`、`~/.cursor` 仅读取） | 任何部署位写入（§六/§十一：待用户显式授权） |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做修改吗？

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 依据（用户原话或证据） | 执行动作 |
|------|------------------|---------------------------|-----------|------------------------|---------|
| CA-1 | skills/task-planner/SKILL.md:1-556 | 更新 | 替代 | R1/R4/R5 | 全文重写≤250 行：四文件罗盘定位+计划制作循环+卫星路由表（P7 S33） |
| CA-2 | skills/task-planner/references/critical-rules.md:1-1046 | 更新 | 替代 | R2/R3 | 重构：删 65 条移走规则，留 11 条核心（1,2,3,5,19,20,26,51,62,66）+头部说明+路由索引（P7 S31） |
| CA-3 | critical-rules.md 新增 Rule 82 段 | 新增 | 增量 | R2/R5+Rule 20.6 预留 free | 技能专业化分层纪律（P7 S34） |
| CA-4 | skills/task-dispatch/SKILL.md | 新增 | 增量 | R2「单独独立化为专业技能」 | 新建：定位+11 规则路由索引（P4 S2） |
| CA-5 | skills/task-discipline/SKILL.md | 新增 | 增量 | 同上 | 新建：定位+36 规则路由索引（P5 S14） |
| CA-6 | skills/media-planner/SKILL.md | 新增 | 增量 | R2+Rule 47/49/50 归属 | 新建：媒体制作域定位+3 规则索引（P6 S22） |
| CA-7 | 7 既有卫星 SKILL.md+references | 更新 | 增量 | R2/R5 | 各加收编规则小节+索引行（P6 S24-S30） |
| CA-8 | skills/task-dispatch/scripts/ ← 5 script+2 selftest | 更新 | 替代 | R5「搬家不丢功能」 | git mv：analyze-splits/check-subagent-return/check-rescue-chain/subagent-fallback/plan-hygiene + selftest-rescue-chain/selftest-fallback（P4 S5-S7） |
| CA-9 | skills/task-dispatch/capabilities/ ← 核心 capabilities/ | 更新 | 替代 | R2+capability 纪律域 | git mv 整目录（P5 S21） |
| CA-10 | skills/task-dispatch/references/ ← 3 references；task-discipline/references/ ← 2 references | 更新 | 替代 | R2 | git mv：agent-coverage/dispatch-examples/split-pattern-library；batch-quality-gate/capability-registry（P4 S12-S13、P5 S21） |
| CA-11 | skills/task-planner/lib/install-stub.sh:36 SATELLITE_SKILLS | 更新 | 增量 | R3+安装链路完整性 | 追加 3 新卫星名（P7 S39） |
| CA-12 | 核心 75 selftest 的 CRIT 锚/rule 断言 | 更新 | 替代 | VC-5 防回归 | 3 批锚重定向到各归属 home（P7 S35-S37） |
| CA-13 | scripts/selftest-batch-pilot.sh BP-08 行数钉 | 更新 | 替代 | VC-5+CA-1 联动 | 558→275（≤250+25 边距先例）+rule-range 纪元锚扩（P7 S38） |
| CA-14 | check-complete.sh:632、install.sh:195-204、lib/verify.sh:240-243、4 selftest caller 路径 | 更新 | 替代 | VC-7 hook/门链零断 | 改指 `$SKILL_ROOT/../<归属>/scripts/` 模式（P4 S8-S11） |
| CA-15 | README.md+ARCHITECTURE.md | 更新 | 替代 | R3 产出可读 | 重写反映分层架构（P7 S40） |
| CA-16 | plans/task-v171-skill-specialization/{findings,progress,design-architecture}.md | 新增 | 增量 | 四文件罗盘纪律 | 过程落盘（P3 S1） |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner SKILL.md 全文（556 行） | /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md@wt/task-v171 | 必读 | ☑ |
| 规范/标准 | critical-rules.md 76 规则全文（1046 行，混合标题格式） | …/references/critical-rules.md@wt/task-v171 | 必读 | ☑ |
| 项目内部文档 | check-plan-dispatch.sh 机器契约（step_max/时长 NNmin/例外登记） | …/scripts/check-plan-dispatch.sh:270-300 | 必读 | ☑ |
| 项目内部文档 | install-stub.sh SATELLITE_SKILLS 注册点 | …/lib/install-stub.sh:36,244 | 必读 | ☑ |
| 项目内部文档 | worktree-isolation.md（§十一 SOP） | …/references/worktree-isolation.md | 参考 | ☑ |
| 先例 | task-v168 任务书（worktree 创建/S-unit 表先例） | plans/task-v168-session-anchor-skill-activation/task_plan.md | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: task-planner 什么都负责导致产出边界混乱（R3），专业化拆分后核心只维护四文件罗盘（R1/R4），且拆分过程不丢失任何既有规则/门控/守护（R3 不混乱的可观察形态）。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：核心+10 卫星分层交付，77 规则零丢失机检
- [x] 核心问题不解决，其他工作都白费吗？——是：不分层则 SKILL.md 继续膨胀，后续任何改动都踩全身
- [x] 核心问题的解决方法是清晰的、可执行的？——是：归属判定规则=「主题⟷四文件/计划生命周期门→核心；否则按域归卫星」+8 VC 机检

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

**豁免声明**：本任务全域 LOCAL-ONLY——所有工序均为本地文件搬迁/改写/机检/门控维护，零外部数据依赖（规则文本、机器契约、卫星结构全部已在本地仓实测建档，见 findings.md）；无 NET-RESEARCH/NET-DATA-DEPENDENT 条目。

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1-P8 全部 S-unit | LOCAL-ONLY | n/a（本地仓全域 grep 已建档） | n/a | findings.md 已落盘 | 否 |

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | critical-rules.md 76 规则全文+行图；SKILL.md 556 行；56 selftest CRIT 耦合；5 script 引用面（含 install.sh 复查补入） | 全域 grep+awk 行数统计 | findings.md §机器事实档 | ☑ |
| ② 对标样本 | 8 个既有卫星技能结构（plan-research-router 等）；task-v168 任务书先例；selftest-drift-check-subagent.sh:17 跨技能相对路径先例 | Read 比对 | findings.md §先例档 | ☑ |
| ③ 外部约束 | AGENTS.md §六/§十一（保护区+worktree 铁律）；Rule 36.4 D6 删除逐条确认；step_max 机器契约；attest 四锚+FMEA 门 | 宪法+脚本契约精读 | findings.md §约束档 | ☑ |

## Current Phase
Phase 3（complete）——计划已锁定（SHA-256 60f0754...），待用户批准

## Next Step
呈报用户（Rule 70 四要素）：对象=本计划 / 看点=分层架构+8 VC+43 S-unit / 动作=批准执行 Phase 4-8。批准后 P4 起按 S-unit 表执行。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理（主进程直做为主） | 调研=全域 grep 建档，主进程直接执行面最高 |
| Phase 2 | 主进程直做 | 计划系统文件维护（Rule 25.3 白名单②） |
| Phase 3 | Agent 子代理 general-purpose | design-architecture.md 大体量文档撰写，隔离上下文防主上下文膨胀（§一） |
| Phase 4 | Agent 子代理 executor（sonnet-1） | 纯机械搬迁+caller 更新 SOP 执行 |
| Phase 5 | Agent 子代理 executor（sonnet-1） | 同上（规则迁移批+目录移动） |
| Phase 6 | Agent 子代理 executor（sonnet-1） | 同上（卫星收编 9 组） |
| Phase 7 | Agent 子代理 code-assistant（sonnet-1） | SKILL.md 重写+selftest 锚修复需代码级精度 |
| Phase 8 | 机械守卫脚本+Agent 子代理（code-runner-agent(mini)+critic） | 回归跑批+独立 CR 视角 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件——Phase 间强依赖（搬迁→caller→瘦身→回归串行链），按 Rule 21.4 串行推进
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未使用 /goal 锚定

## Phases

### Phase 1: Requirements & Discovery
- [x] 理解用户意图（R1-R5 逐条归档）
- [x] 识别约束和需求（§六/§十一/Rule 36.4/机器契约精读）
- [x] 在 findings.md 记录发现（76 规则行图/77 selftest/56 CRIT 耦合/5 script 引用面含 install.sh 补入/step_max 契约/BP-08 钉/install-stub 注册点）
- [x] 知识储备必读项已确认可获取（见「必要知识储备」表全☑）
- **V-N:** VC-2, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 2: Planning & Structure
- [x] Define technical approach（分层归属架构定稿：核心 11+dispatch 11+discipline 36+media 3+卫星 16+新 Rule 82）
- [x] 创建 project structure if needed（worktree 已建：/mnt/data/dev/task-planner-skill-worktrees/task-v171-skill-specialization@wt/task-v171 from master 618df79）
- [x] Document decisions with rationale（见 Decisions Made 表）
- [x] Write task_plan.md 全文并 attest 锁定
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: Architecture Design Doc
- [x] 写 design-architecture.md：规则→归属全映射表（编号×源行区间×目标文件）+3 新卫星规格+7 卫星收编规格+caller 更新清单（含 install.sh:195-204）+删除基线（Rule 36.3）+边界案例
- [x] 回填 findings.md/progress.md
- [x] attest-plan.sh 锁定+预留 Rule 82
- [x] 呈报用户批准（Rule 70 四要素）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** general-purpose

<!-- S-unit 派发单元表（Rule 22.6） -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | 写 design-architecture.md 全文（映射表/卫星规格/caller 清单/删除基线） | 继承 | plans/task-v171-skill-specialization/task_plan.md（R/VC/CA 表）；plans/task-v171-skill-specialization/findings.md | 文件≥300 行含 77 规则映射全表+caller 清单 7 项+删除基线逐条；无占位符残留 | 15min | 1f/320l/15min 例外登记 | 无 | Phase 2 | pending |

### Phase 4: task-dispatch 新技能建设
- [x] 建 task-dispatch SKILL.md 骨架+11 规则路由索引
- [x] 迁移 11 规则（2 批：78l+65l）到 task-dispatch/references/
- [x] git mv 4 script+2 selftest（analyze-splits/check-subagent-return/check-rescue-chain/subagent-fallback + selftest-rescue-chain/selftest-fallback）到 task-dispatch/scripts/
- [x] 更新 7 处 caller（check-complete.sh:632、install.sh:195-204、lib/verify.sh:240-243、selftest-context-hygiene.sh:27、selftest-subagent-granularity-skill-escort.sh:55、selftest-subagent-return.sh:9、selftest-skill-collab.sh:14）
- [x] git mv 3 references（agent-coverage/dispatch-examples/split-pattern-library）到 task-dispatch/references/
- [x] 验证：task-dispatch 2 selftest 独立全绿+核心侧引用 grep 零悬空
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S2 | 建 task-dispatch SKILL.md 骨架（frontmatter+定位+11 规则路由索引） | 继承 | plans/task-v171-skill-specialization/design-architecture.md（task-dispatch 节） | frontmatter name/description 合规+索引含 12,13,14,21,22,23,25,46,52,59,68 全 11 编号 | 15min | 1f/60l/15min | 无 | - | pending |
| S3 | 迁移 Rule 12/13/14/21/22/23 六条到 task-dispatch references | 继承 | skills/task-planner/references/critical-rules.md（源行 48-233 区间）；plans/task-v171-skill-specialization/design-architecture.md | 6 规则标题+正文逐字在位+新文件行数≈90 | 15min | 1f/78l/15min | 无 | S2 | pending |
| S4 | 迁移 Rule 25/46/52/59/68 五条到 task-dispatch references | 继承 | skills/task-planner/references/critical-rules.md（源）；plans/task-v171-skill-specialization/design-architecture.md | 5 规则逐字在位+新文件合计行数≈155 | 15min | 1f/65l/15min | 无 | S3 | pending |
| S5 | git mv analyze-splits.sh+check-subagent-return.sh 入 task-dispatch/scripts/ | 继承 | plans/task-v171-skill-specialization/design-architecture.md（caller 清单） | 2 文件 git 状态 renamed+内容零改动（git diff --stat 空） | 5min | 2f/0l/5min | 无 | S2 | pending |
| S6 | git mv check-rescue-chain.sh+selftest-rescue-chain.sh 入 task-dispatch/scripts/ | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 5min | 2f/0l/5min | 无 | S5 | pending |
| S7 | git mv subagent-fallback.sh+selftest-fallback.sh 入 task-dispatch/scripts/ | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 5min | 2f/0l/5min | 无 | S6 | pending |
| S8 | caller 更新：check-complete.sh:632 + install.sh:195-204 | 继承 | plans/task-v171-skill-specialization/design-architecture.md（caller 清单+证据行） | 2 文件路径改指 ../task-dispatch/scripts/+grep 旧路径零命中 | 15min | 2f/30l/15min | 无 | S7 | pending |
| S9 | caller 更新：lib/verify.sh:240-243 + selftest-context-hygiene.sh:27 及 T07-T09 断言 | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 15min | 2f/30l/15min | 无 | S7 | pending |
| S10 | caller 更新：selftest-subagent-granularity-skill-escort.sh:55+SG-20 断言 + selftest-subagent-return.sh:9 | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 15min | 2f/20l/15min | 无 | S7 | pending |
| S11 | caller 更新：selftest-skill-collab.sh:14 FALLBACK 路径+T6 断言 | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 10min | 1f/20l/10min | 无 | S7 | pending |
| S12 | git mv agent-coverage.md+dispatch-examples.md 入 task-dispatch/references/ | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 2 文件 renamed+内容零改动 | 5min | 2f/0l/5min | 无 | S2 | pending |
| S13 | git mv split-pattern-library.md 入 task-dispatch/references/ | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 1 文件 renamed+内容零改动 | 5min | 1f/0l/5min | 无 | S12 | pending |

### Phase 5: task-discipline 新技能建设
- [x] 建 task-discipline SKILL.md 骨架+36 规则路由索引
- [x] 迁移 36 规则（6 批：20l+82l+84l+81l+86l+151l）到 task-discipline/references/
- [x] git mv capabilities/ 整目录+plan-hygiene.sh 入 task-discipline/scripts/；git mv batch-quality-gate.md+capability-registry.md 入 task-discipline/references/
- [x] 验证：36 编号对照表全在位+capabilities/ 新路径引用零悬空
- **V-N:** VC-2, VC-6
- **Status:** complete（执行载体=dynamic workflow dwfrun-eeaa3e10，用户 /workflow 指令；纪律规则撰写员·上/下+搬迁员 3 路）
- **Executor:** workflow 子代理（纪律规则撰写员·上/下、纪律文件搬迁员）+world.run 门

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S14 | 建 task-discipline SKILL.md 骨架（frontmatter+定位+36 规则路由索引） | 继承 | plans/task-v171-skill-specialization/design-architecture.md（task-discipline 节） | frontmatter 合规+索引 36 编号齐全 | 15min | 1f/70l/15min | 无 | - | pending |
| S15 | 迁移批1：Rule 4/6/7/8/9/10 六条 | 继承 | skills/task-planner/references/critical-rules.md（源）；plans/task-v171-skill-specialization/design-architecture.md | 6 规则逐字在位+新文件行数≈30 | 10min | 1f/20l/10min | 无 | S14 | pending |
| S16 | 迁移批2：Rule 18/28/29/31/32/33/35 七条 | 继承 | 同上 | 7 规则逐字在位+累计≈115 | 15min | 1f/82l/15min | 无 | S15 | pending |
| S17 | 迁移批3：Rule 36/41/42/43/44/45 六条 | 继承 | 同上 | 6 规则逐字在位+累计≈200 | 15min | 1f/84l/15min | 无 | S16 | pending |
| S18 | 迁移批4：Rule 48/53/54/55/56/57 六条 | 继承 | 同上 | 6 规则逐字在位+累计≈285 | 15min | 1f/81l/15min | 无 | S17 | pending |
| S19 | 迁移批5：Rule 27/60/65/67/69 五条 | 继承 | 同上 | 5 规则逐字在位+累计≈375 | 15min | 1f/86l/15min | 无 | S18 | pending |
| S20 | 迁移批6：Rule 70/71/72/73/74/76 六条 例外登记（末批合并搬迁+行数上限豁免：批次为最小原子组，拆条将产生重复往返） | 继承 | 同上 | 6 规则逐字在位+累计≈430 | 15min | 1f/151l/15min 例外登记 | 无 | S19 | pending |
| S21 | git mv capabilities/ 整目录+plan-hygiene.sh 入 task-discipline/scripts/；git mv batch-quality-gate.md+capability-registry.md 入 task-discipline/references/ 例外登记（原子搬迁组：目录+脚本+2 references 同属纪律域一次搬齐，拆开产生域内文件分散中间态） | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 全部 renamed+内容零改动+链到 capabilities/ 的引用（selftest-capability-persistence.sh 等）零悬空或已登记重定向 | 15min | 6f/10l/15min 例外登记 | 无 | S14 | pending |

### Phase 6: media-planner 新建 + 7 卫星收编
- [x] 建 media-planner SKILL.md+references（迁移 Rule 47/49/50）
- [x] plan-research-router 收编 Rule 58/63/75
- [x] plan-template-kit 收编 Rule 16/34/37/38
- [x] plan-collab-router 收编 Rule 39/40
- [x] plan-cost-guard 收编 Rule 17；plan-resume 收编 Rule 24；progress-tracker 收编 Rule 30；task-drift-guard 收编 Rule 11/15/61/64
- [x] 验证：7 卫星 grep 收编规则全绿+核心删除基线清零
- **V-N:** VC-2, VC-4
- **Status:** complete（执行载体=dynamic workflow dwfrun-eeaa3e10；8 个收编子代理并行——原子三动作只做落盘+索引，删核心原文由 P7 S31 统一）
- **Executor:** workflow 子代理（媒体规划技能建设员+7 收编员）并行

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S22 | 建 media-planner SKILL.md（frontmatter+媒体域定位+3 规则路由索引） | 继承 | plans/task-v171-skill-specialization/design-architecture.md（media-planner 节） | frontmatter 合规+索引含 47,49,50 | 15min | 1f/60l/15min | 无 | - | pending |
| S23 | 迁移 Rule 47/49/50 三条到 media-planner/references/ 例外登记（规则落盘+核心删除+索引三动作原子配对，拆开产生规则悬空） | 继承 | skills/task-planner/references/critical-rules.md（源）；plans/task-v171-skill-specialization/design-architecture.md | 3 规则逐字在位+新文件行数≈90 | 15min | 1f/90l/15min 例外登记 | 无 | S22 | pending |
| S24 | plan-research-router 收编 Rule 58/63/75：卫星 references 追加小节+核心删除+SKILL.md 索引行 例外登记（收编=落盘+删除+索引原子三动作） | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/plan-research-router/SKILL.md | 3 规则全文落位+索引行存在+核心侧对应文本已删 | 15min | 2f/120l/15min 例外登记 | 无 | - | pending |
| S25 | plan-template-kit 收编 Rule 16/34/37/38：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/plan-template-kit/SKILL.md | 4 规则落位+索引更新+核心已删 | 15min | 2f/110l/15min 例外登记 | 无 | - | pending |
| S26 | plan-collab-router 收编 Rule 39/40：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/plan-collab-router/SKILL.md | 2 规则落位+索引更新+核心已删 | 15min | 2f/60l/15min | 无 | - | pending |
| S27 | plan-cost-guard 收编 Rule 17：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/plan-cost-guard/SKILL.md | 1 规则落位+索引更新+核心已删 | 10min | 2f/40l/10min | 无 | - | pending |
| S28 | plan-resume 收编 Rule 24：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/plan-resume/SKILL.md | 1 规则落位+索引更新+核心已删 | 10min | 2f/40l/10min | 无 | - | pending |
| S29 | progress-tracker 收编 Rule 30：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/progress-tracker/SKILL.md | 1 规则落位+索引更新+核心已删 | 10min | 2f/40l/10min | 无 | - | pending |
| S30 | task-drift-guard 收编 Rule 11/15/61/64：同上三动作 | 继承 | skills/task-planner/references/critical-rules.md（源）；skills/task-drift-guard/SKILL.md | 4 规则落位+索引更新+核心已删 | 15min | 2f/110l/15min 例外登记 | 无 | - | pending |

### Phase 7: 核心瘦身与 selftest 锚修复
- [x] critical-rules.md 重构（删 65 条移走规则+头部说明+路由索引）
- [x] SKILL.md 重写 ≤250 行（四文件罗盘+计划制作循环+卫星路由表）
- [x] Rule 82 写入 critical-rules.md
- [x] selftest 锚修复 3 批（CRIT 指向重定向+rule 断言重定向）+BP-08 口径演进 558→275+rule-range 纪元锚扩
- [x] install-stub.sh 注册 3 新卫星
- [x] README+ARCHITECTURE 重写
- [x] alignment-review 收尾
- **V-N:** VC-1, VC-5
- **Status:** complete（执行载体=dynamic workflow dwfrun-eeaa3e10；锚修复 3 批并行+契约收尾员串后，偏离 plan 串行序的理由=Rule 21.4 独立性四问，已登记 findings）
- **Executor:** workflow 子代理（核心瘦身员+锚修复员×3+契约收尾员）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S31 | critical-rules.md 重构：删 65 条移走规则+写头部说明+路由索引 例外登记（单文件整体重构：删除面与保留面必须一次成型，分批删产生规则归属悬空中间态） | 继承 | skills/task-planner/references/critical-rules.md（现状）；plans/task-v171-skill-specialization/design-architecture.md（路由索引节） | 新文件≤235 行含 11 核心规则全文+头部+索引段；76 移走规则 grep 零残留 | 30min | 1f/950l/30min 例外登记 | 无 | S30 | pending |
| S32 | 重构自检：规则数=11 且编号唯一+路由索引 10 行（76 归属面） | 继承 | skills/task-planner/references/critical-rules.md（新）；plans/task-v171-skill-specialization/design-architecture.md | grep 计数=11+索引行逐条存在 | 10min | 1f/20l/10min | 无 | S31 | pending |
| S33 | SKILL.md 重写 ≤250 行：四文件罗盘定位段+计划制作循环+卫星路由表+核心规则指针 例外登记（整体重写不可拆——v168 先例；拆开产生半态 SKILL） | 继承 | skills/task-planner/SKILL.md（现状 556 行）；plans/task-v171-skill-specialization/design-architecture.md（SKILL 规格节） | wc -l≤250+主题词 grep 分布合规（无非职责段）+路由表 10 行在位 | 20min | 1f/250l/20min 例外登记 | 无 | S31 | pending |
| S34 | Rule 82（技能专业化分层纪律）写入 critical-rules.md | 继承 | skills/task-planner/references/critical-rules.md（新）；plans/task-v171-skill-specialization/design-architecture.md | 82 号段标题+正文在位+grep -cE '^### 82' =1 | 10min | 1f/40l/10min | 无 | S31 | pending |
| S35 | selftest 锚修复批1：CRIT 指向 task-discipline 的断言集（error-loop/reflect-verify/root-resolution/decision-grading 等按 design-architecture §selftest 批1 清单） | 继承 | plans/task-v171-skill-specialization/design-architecture.md（selftest 批清单） | 批内 selftest 路径改指+rule 断言重定向+bash -n 通过 | 15min | 2f/60l/15min | 无 | S34 | pending |
| S36 | selftest 锚修复批2：media/collab/skill-collab 关联断言集 | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 15min | 2f/60l/15min | 无 | S35 | pending |
| S37 | selftest 锚修复批3：dispatch 关联断言集（batch-pilot 外） | 继承 | plans/task-v171-skill-specialization/design-architecture.md | 同上 | 15min | 2f/60l/15min | 无 | S36 | pending |
| S38 | selftest 口径演进：BP-08 行数钉 558→275（≤250+25 边距先例）+rule-range 纪元锚扩（1-77 全集宽容） | 继承 | scripts/selftest-batch-pilot.sh:11,53；plans/task-v171-skill-specialization/design-architecture.md | 钉值=275+纪元锚含 77+bash -n 通过 | 10min | 2f/40l/10min | 无 | S37 | pending |
| S39 | install-stub.sh SATELLITE_SKILLS 追加 3 新卫星（task-dispatch/task-discipline/media-planner） | 继承 | skills/task-planner/lib/install-stub.sh:36,244 | 数组含 3 新名+bash -n 通过 | 10min | 1f/10l/10min | 无 | S22 | pending |
| S40 | README.md+ARCHITECTURE.md 重写反映分层架构 例外登记（文档整体重写不可拆） | 继承 | skills/task-planner/README.md；plans/task-v171-skill-specialization/design-architecture.md | 两文件含 10 技能分层图+路由表+回归命令 | 15min | 2f/150l/15min 例外登记 | 无 | S33 | pending |

### Phase 8: 终验回归与合并回
- [x] 全量回归：核心 75 selftest+task-dispatch 2 selftest 各自 FAIL=0
- [x] VC-1..VC-8 逐条复验（独立视角）
- [x] CR Gate：critic 独立审查+意见逐条闭环
- [x] merge-back：git merge --no-ff wt/task-v171-skill-specialization→master（主进程）
- [x] 部署位写入（2026-10-12 用户授权后 install.sh --tools zcode,claude,opencode,cursor 同步 4 位+3 新卫星；子代理递归 diff 全空；4 verify fail=pre-existing 欠账，详见 deployment-reconciliation.md §五）
- [x] 交付总结+核心目标达成裁决
- **V-N:** VC-5, VC-6, VC-7, VC-8
- **Status:** complete（执行载体=dynamic workflow dwfrun-eeaa3e10；S41 回归=world.run 门、S42/S43=VC 复核员+质量门评审员，CR 拦截循环 cap 2；merge-back/部署对账/呈报=workflow 后主进程）
- **Executor:** world.run 门 + workflow 子代理（验证条件复核员、质量门评审员）+ 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S41 | 全量回归：核心 selftest+task-dispatch selftest 跑批 | 继承 | skills/task-planner/scripts/run-selftests.sh；skills/task-dispatch/scripts/selftest-*.sh（2 个） | 输出 FAIL=0+Total 行与跑前基线一致 | 15min | 0f/0l/15min | 无 | S40 | pending |
| S42 | VC-1..VC-8 逐条复验（独立视角执行命令核对证据） | 继承 | plans/task-v171-skill-specialization/task_plan.md（VC 表） | 8 条证据行全落 progress.md | 15min | 0f/0l/15min | 无 | S41 | pending |
| S43 | CR Gate：critic 独立审查本任务全部产出+意见逐条闭环 | 继承 | plans/task-v171-skill-specialization/task_plan.md；git diff master..wt 全量 | critic verdict+每条意见处置记录（接受/驳回+理由） | 15min | 0f/0l/15min | 无 | S42 | pending |

<!-- 主进程动作（无 S-unit：git 编排+簿记白名单） -->
- [ ] merge-back：`git merge --no-ff wt/task-v171-skill-specialization`（主仓执行，前置：worktree 内 VC 全绿+git status 干净+主仓无重叠未提交变更——§十一 合并回合约）
- [ ] 部署位只读对账：~/.zcode、~/.claude、~/.config/opencode、~/.cursor 四位 diff 清单落盘 progress.md（写入需用户显式授权）
- [ ] delivery-summary 落盘+核心目标达成裁决三态填写

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号③：技能文件属所有会话实时加载的运行中基础设施；信号④：git status 含他会话未提交变更——plans/.rule-reservations.jsonl 等 4 个 task 目录） |
| `isolation` | `worktree`（实现类默认首选，§十一 P0） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v171-skill-specialization` |
| `branch` | `wt/task-v171-skill-specialization`（from master HEAD 618df79） |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 4 | 脚本搬家漏改 caller（install.sh 类隐藏调用点） | 8 | 5 | 6 | 240 | ①改派：design-architecture §5 caller 清单逐项 grep 核对，漏 1 处即停手补清单重派 |
| Phase 5 | 36 规则迁移文本截断/遗漏 | 9 | 5 | 7 | 315 | ②拆细：逐批编号对照表核验（6 批即 6 次检查点），失败批重派 code-assistant 补迁 |
| Phase 6 | 卫星收编规则悬空（核心已删卫星未落） | 9 | 4 | 7 | 252 | ④主进程接管+②拆细：收编 S-unit 内「落盘+删除+索引」原子配对；VC-2 全集机检兜底拦截 |
| Phase 7 | SKILL.md 重写丢机器锚/BP-08 未联动致回归红 | 8 | 6 | 5 | 240 | ②拆细：BP-08 演进独立 S-unit（S38）+回归 FAIL=0 验收门+CR Gate 拦截 |
| Phase 8 | 合并回合约破例（主仓有重叠变更仍合） | 9 | 3 | 4 | 108 | ⑤AskUserQuestion：主仓重叠未提交变更→STOP 报告用户决策（§十一.3 先例） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档：改派/拆细/降档/主进程接管/AskUserQuestion）；RPN≤100 可留空。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链，两者不互相替代。（AskUser/呈报按 Rule 70 四要素）

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-12 | 调研建档完成 |
| Phase 2 | ☑ | 2026-10-12 | 计划撰写中 |
| Phase 3 | ☐ | | attest 前建 |
| Phase 4 | ☐ | | Phase 3 批准后建 |
| Phase 5 | ☐ | | 同上 |
| Phase 6 | ☐ | | 同上 |
| Phase 7 | ☐ | | 同上 |
| Phase 8 | ☐ | | 同上 |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions
1. **KQ1 归属粒度**：36 条纪律类规则归一 task-discipline 单卫星，还是再拆多个小卫星？**推荐归一**——单一事实源避免卫星碎片化，且纪律规则互相引用频繁（拆散后交叉引用面爆炸）；卫星数已从 8 增至 11，再拆违背 R3。
2. **KQ2 selftest 归属**：与被测脚本行为绑定的 selftest-fallback/selftest-rescue-chain 随迁 task-dispatch，其余 75 个留守核心+锚重定向？**推荐随迁 2 个**——run-selftests.sh 扫描面不变（零 harness 改动），留守者锚点重定向到各归属 home 的 references。
3. **KQ3 部署同步时机**：P8 merge-back 后立即写 4 个部署位，还是止于只读对账？**推荐止于对账**——§六/§十一 保护区写入需用户显式授权，对账清单落盘后由用户裁决写入范围与时机。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| goal-gate.md 留核心 | VC/Goal 单元表是 task_plan.md 四文件产物，Goal Gate 机器检在核心 check-complete.sh；plan-collab-router 域=comet/OpenSpec/superpowers 协同，不含 Goal 门 |
| Rule 66 归核心 | goal 单元固化对象=四文件罗盘，命中「主题⟷四文件→核心」判定规则 |
| Rule 27 归 task-discipline | git/工作产物纪律域，非文档管理 |
| caller 更新用 `$SKILL_ROOT/../<归属>/scripts/` 模式 | 先例：selftest-drift-check-subagent.sh:17 SATELLITE_SKILL 相对路径 |
| selftest 锚修复三分法（随迁 2/留守重定向 75/BP-08 演进） | 随迁=零 harness 改动；留守重定向=run-selftests 扫描面不变 |
| install.sh Phase 5.7 路径必须更新 | subagent-fallback.sh 移走后 :195 fail-open 会静默丢 fallback bind 功能（VC-7） |
| 工作树从 master HEAD 618df79 创建 | 主分支 stale 1009 commits，worktree 必须基于 master（§十一 SOP） |
| 部署位写入待授权 | §六 保护区+§十一：显式授权前只读对账 |
| 2026-10-12 并集解：VC-2 口径 77→78 条（76 既有+Rule 81+Rule 82） | master 同日并行落地 task-v170 Rule 81 全链（基点 e82dd42 落后 master tip 23cffa5 32 提交），按现状 merge 将静默回退并行成果；merge-back 前强制 master→wt 并集解，依据=master 提交 1651371「v169 Rule 80 合流并集解 epoch 80/81 双纪元」先例；本次纠正由质量门第 1 轮拦截发现 |
| 2026-10-12 并集解：Rule 81 归核心 critical-rules.md（溯源注释+81.1-81.6 逐字并入，插 80.6 与 Rule 82 之间） | 归档域主题⟷计划生命周期门→核心归属判定规则；标题行适配本任务 `### N 标题` 惯例（与卫星迁移同范式），正文逐字零改动 |
| 2026-10-12 并集解：SKILL.md C56/C57 合规语义→G9/G10 行并集承载（合规清单表瘦身后核心域合规项由 G 表承载） | master :247/:248 的 C56(Rule 80)/C57(Rule 81) 行随瘦身退役，语义并入 G 表追加行（G1-G8 既有行不动，FF-11/TB-07 等 G 行断言不受影响）；另并回归档指针行（master:185）+Rule 81 摘要 bullet（master:383 语义）+全集锚 '1-80'→'1-81'×3 |
| 2026-10-12 并集解：selftest 纪元锚宽容化 '1-80'→'1-8[01]'（17 脚本，负样本 1-82 不命中） | 形态采用 master 版 selftest-session-log.sh SL-05 已立口径（覆盖 1-80/1-81 双纪元）；AD-12 pin 清单二次同步（5 精确 pin→"grep -cE '1-8[01]'"+3 tol pin 随 live 锚演进）；master 行数钉放宽 558→584 未采纳数值（动因=master 自身 SKILL 膨胀，合并树用 218 行重写版保留更紧上界，演进史注释已并集） |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| mawk 不支持 {2,4} 区间表达式，awk 规则行图污染（子标题误判顶层规则） | 1 | 改用 GNU grep -nE ERE 为权威行图 | 抽取工具一律 key off 规则编号+ERE，禁 awk 区间正则 → progress.md Error Log |
| 初版 caller map 漏 install.sh:195-204（subagent-fallback 隐藏调用点） | 1 | 全域 grep 复查补入 CA-14/S8 | 引用面取证=全扩展名扫描（.sh/.md/.json），禁抽样 → progress.md Error Log |
| 预估「5 script 引用面」低估（实际 7 项 caller+2 随迁 selftest） | 1 | Phase 4 S 表按 7 caller 拆分 4 个 S-unit | 搬迁类任务先建「引用面清单」再切 S-unit → progress.md Error Log |

## Notes
- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead
- 规则标题混合格式（`### N 标题` vs `## Rule N（`）已在 design-architecture 映射表处理，抽取工具禁 key off 行序
- Rule 82 预留=rule-reserve.sh check 82 → free（已实测）

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-12 | 计划撰写期自检：原「5 script 引用面」低估已补（install.sh） | VC-6, VC-7 | 已补 CA-14/S8，方向无偏移 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）
<!-- 适用 Phase：P5（36 规则 6 批迁移）、P6（卫星收编 9 组）；本表在涉及 Phase complete 时回填 -->

| 字段 | 值 |
|------|-----|
| `total` | （P5 批迁移单元数+P6 收编单元数） |
| `success` | |
| `failed` | |
| `failure_rate` | （>5% → STOP;>20% → 熔断回滚） |
| `sampled_pass` | （运行后抽 10%） |
| `sampled_fail` | （运行前抽 2,>0 → 整批熔断） |
| `pre_check` | （Q1:否/Q2:有/Q3:能） |
| `rollback_point` | （为空 → 禁止批量） |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 6 / 8 |
| 主进程直做 Phase 清单 | P1（② 计划系统文件维护）、P2（② 计划系统文件维护）、P8 merge-back+对账（① git 编排+② 簿记）——全在 Rule 25.3 白名单 |
| 委派率 | 0.75（≥ delegation_rate_floor 0.7 ✓） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|------------|--------------|----------------|------------------------|
| 1 | 2026-10-12 | 主进程（P1-P2 直做） | 需求归档+机器事实建档+计划撰写 | done | R1-R5 归档；76 规则行图/56 CRIT 耦合/step_max 契约/BP-08 钉实测落 findings | plans/task-v171-skill-specialization/findings.md §机器事实档 | §机器事实档/§先例档/§约束档 | - | - / 0 / ☐ |
| 2 | | general-purpose | 写 design-architecture.md | queued | | | | | - / 0 / ☐ |
| 3 | | executor（sonnet-1） | task-dispatch 建设（S2-S13） | queued | | | | | - / 0 / ☐ |
| 4 | | executor（sonnet-1） | task-discipline 建设（S14-S21） | queued | | | | | - / 0 / ☐ |
| 5 | | executor（sonnet-1） | 卫星体系（S22-S30） | queued | | | | | - / 0 / ☐ |
| 6 | | code-assistant（sonnet-1） | 核心瘦身（S31-S40） | queued | | | | | - / 0 / ☐ |
| 7 | | code-runner-agent（mini）+critic | 回归+VC 复验+CR Gate（S41-S43） | queued | | | | | - / 0 / ☐ |
