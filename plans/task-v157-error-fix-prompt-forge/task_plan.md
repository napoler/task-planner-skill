---
template_type: general
plan_tier: standard
---

# Task Plan: 新建顶层 skill error-fix-prompt-forge（错误排查结果 → 专业修正提示词锻造器）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「创建一个skill」<sub>（[手段]）</sub>
- **R2**: 「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-5, VC-6 | 三件文件在位含锚（grep 输出）/selftest PASS/全量回归 FAIL=0/部署 IDENTICAL |
| R2 | VC-4（问题解决判据）+ VC-1..3 支撑 | 真实 fixture 实跑产物 fix-prompt 样例通过自检表（无占位符/绝对路径/≥1 机器可检查验收） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

R2 是结果级需求（可靠产出「可供后期修正的专业提示词」）。逐工序审计缺陷面：

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 输入收集 | 把「帮忙看看 bug」类未定位材料当排查结果 → 垃圾进垃圾出 | 输入契约 fail-closed：症状/复现/根因/证据锚缺一即 STOP；根因未定位=BLOCKED 退回排查（与 debugger/systematic-debugging 划界） | VC-1 |
| 结构化抽取 | 根因结论无证据锚 → 提示词夹带未经证实的断言（造谣传导） | 证据锚（file:line / 命令输出）必填；无锚只能进「未验证假设区」且明示 | VC-1, VC-4 |
| 缺口分析 | 执行体缺验收判据 → 修完无法判定对错 | 阻断级缺口（无机器可检查验收/无复现路径）存在即禁出稿，列清单交用户补 | VC-4 |
| 渲染 | 提示词不自包含（代词悬指/相对路径/多修复混塞）→ 子代理跑偏 | 模板槽位+派发纪律（绝对路径、单 S-unit、≤3000 字符、禁花括号缩写） | VC-2, VC-4 |
| 自检交付 | 「应该没问题」式自报 → 不可验证交付 | QC-FP 自检表逐条 PASS/未验证显式标注；三态结论 READY/PARTIAL/BLOCKED | VC-3, VC-4 |

## Goal
在仓库新建顶层执行型 skill `error-fix-prompt-forge`：把已完成根因定位的错误排查调研结果，经输入校验→结构化抽取→缺口分析→模板渲染→自包含自检五步闭环，转化为可直接派发子代理执行修正的专业任务书（fix prompt），含 selftest 守护与三宿主部署，全量回归零 FAIL。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（产物含 .sh selftest 脚本，属代码组画像 Rule 37） |
| `session_id` | env sid=de2c5bba705847e28d6af0566b838159（sidmap→cbab959f7d0d49848a4394755f9541a3） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge |
| `scope_files` | skills/error-fix-prompt-forge/**; skills/task-planner/scripts/selftest-registry.tsv; plans/task-v157-error-fix-prompt-forge/** |
| `interaction_mode` | `silent`（用户指令自包含且当前不可交互；D6 硬停点保留；silent 决策登记 Decisions Made `silent:` 行） |
| `对齐审查` | Phase 3 产出与 Phase 5 收尾跑 `Skill("alignment-review")`（Rule 42.6.2 标准收尾）；变更记录落 delivery-summary |
| `自动超时默认项` | 本任务无 2+ 选项询问点（用户指令明确、silent 自主决策已逐条登记）→ 豁免登记 |
| `new_rule` | 留空（新建顶层 skill 不涉 Rule 新增，v106 先例） |
| `质量审查工具` | 四级检测结论：项目级无 / 用户级无 / 环境既有 agents=Code Reviewer（code-review skill 本会话可用清单缺失 → 按 22.3① 改派 code-reviewer subagent）/ 内置池未启用（有具名 agent，不进兜底池） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | `skills/error-fix-prompt-forge/SKILL.md` 存在且含触发条件/输入契约/五步流程/门控铁律/输出合约/反模式六区块 | grep 区块锚 + Read 复核 | skills/error-fix-prompt-forge/SKILL.md |
| VC-2 | `skills/error-fix-prompt-forge/templates/fix-prompt-template.md` 存在且槽位覆盖：根因+证据锚/复现/范围/禁改区/机器可检查验收/回滚/定义完成 | grep 槽位锚 | skills/error-fix-prompt-forge/templates/fix-prompt-template.md |
| VC-3 | `skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh`（位置=仓库惯例集中位）存在、可执行、≥8 断言全 PASS；selftest-registry.tsv 末行登记 error-fix-prompt-forge | 跑脚本看 exit 0 + tail registry | 命令输出 + registry 末行 |
| VC-4 | 行为冒烟：用真实排查 fixture 实跑五步流程，产物 fix-prompt 样例通过 QC-FP 自检表（无占位符/绝对路径/≥1 机器可检查验收/单 S-unit），结论三态之一显式 | Read 样例 + 自检表逐条证据 | plans/task-v157-error-fix-prompt-forge/subagent-state/*/fix-prompt-sample.md |
| VC-5 | 全量 selftest 回归 FAIL=0（含新增脚本；总数级联计数无残留 FAIL） | 跑 scripts 目录全量 + 汇总数主进程独立重算 | progress.md Round 记录 + 汇总输出 |
| VC-6 | worktree 合并回 master；三宿主（~/.zcode/skills、~/.agents/skills、~/.claude 位）diff IDENTICAL；INDEX.md/ledger/attest 簿记完整 | git log 复验 + diff -r 三宿主 | merge commit + diff 输出 |

**终验规则**：全部 VC 通过 → COMPLETE；VC 通过但有已知遗留 → PARTIAL；≥1 VC 失败重试 3 次无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5 — 终验时填写）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R2 |
| **裁决** | solved |
| **解决证据锚** | VC-4：plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/fix-prompt-sample.md（九槽位自包含任务书：绝对路径 8 行/单 S-unit/grep 机器验收）+ qc-fp-selfcheck.md（QC-FP-1..6 全 PASS，结论 READY）——「排查结果→专业修正提示词」能力经实际生成测试证实可用 |
| **未验证面+原因** | 无 |
| **已排除路径** | n/a |
| **下一步建议** | 首次实战使用后回灌经验（QC 定义质量依赖排查结果包质量，已登记 verification.md 遗留项） |

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后立即填写）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 侦察定界 | 摸清既有排查/生成能力，划定 skill 边界与差异化 | subagent-state/01-explore.md + findings 边界清单（主进程 Read 复核） | S1/Phase 1 | complete |
| G2 | 设计定稿 | 五步流程+fix-prompt 槽位表+QC-FP 自检项定稿 | findings.md 设计段 + Decisions Made 设计行 | Phase 2 | complete |
| G3 | 三件编写 | SKILL.md+模板+selftest+registry 落盘 | grep 六区块/槽位锚 + selftest 自跑 exit 0 | S1-S3/Phase 3 | complete |
| G4 | 冒烟回归 | fixture 实跑产出 fix prompt + 全量 FAIL=0 | fix-prompt-sample.md 自检表全 PASS + 回归汇总输出 | S1-S3/Phase 4 | complete |
| G5 | 部署收口 | worktree 合并+三宿主 IDENTICAL+终验 | merge commit + `diff -r` 三宿主 + check-complete exit 0 | Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码（新增） | skills/error-fix-prompt-forge/SKILL.md | 其他 skill 的 SKILL.md |
| 脚本（新增） | skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh（仓库惯例=全部 selftest 集中于 task-planner/scripts，iterative-optimizer 先例） | 其他 selftest 脚本（回归级联修复除外：Phase 4 S3 条件性授权，仅限断言计数/锚同步类最小改动并登记） |
| 配置 | skills/task-planner/scripts/selftest-registry.tsv（仅追加 1 行） | config.json 及其他配置 |
| 文档 | skills/error-fix-prompt-forge/templates/fix-prompt-template.md；plans/task-v157-error-fix-prompt-forge/** | 其他 plans/ 目录（v152/v154/v155/v156 等在册任务产物） |

**执行前自我检查:** 文件在列表中？修改有必要？用户要求？全 Yes → 执行。

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner 派发纪律（22.4 九字段/Rule 59 粒度/Rule 46 专注/22.4c 守卫） | ~/.zcode/skills/task-planner/references/critical-rules.md（与仓库副本 init-session diff IDENTICAL） | 必读 | ☐ |
| 项目内部文档 | 顶层 skill 范式（iterative-optimizer 97 行结构） | skills/iterative-optimizer/SKILL.md | 必读 | ☐ |
| 项目内部文档 | v106 新建顶层 skill 交付先例（selftest/registry/install-companion 部署） | memory: projects/task-planner-skill-fba311568bf6d7b3/memory/task-v106-iterative-optimizer.md | 必读 | ☐ |
| 项目内部文档 | 真实排查调研 fixture（A/B/C fix-prompts 形态） | plans/task-v153-parallel-scheduling/fix-prompts.md | 参考 | ☐ |

## ⚠️ 核心问题定义

**核心问题**: 排查结论与修正执行之间存在「高质量修正任务书」断层——根因/证据/验收/约束散落在会话上下文，直接派人修会丢信息、跑偏、无法验收；本 skill 把排查结果固化为自包含、可验收的 fix prompt 后该断层消除，结果可交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（fix prompt 可直接驱动后期修正）
- [x] 核心问题不解决，其他工作都白费吗？（skill 若无输入校验/自检闭环即失去存在意义）
- [x] 核心问题的解决方法是清晰的、可执行的？（五步闭环+模板+QC-FP 自检表）

## 🔍 证据面清单（Rule 58.1）

`n/a（纯执行类——产物为 skill 本体，非结论/归因判断；Phase 1 侦察为能力 inventory 非归因结论）`

## Current Phase
Phase 5（complete — 终验通过，outcome=COMPLETE，check-complete 待跑）

## Next Step
跑 check-complete.sh 终验 + sync-todos.sh --index 更新 INDEX，随后输出交付总结五要素

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 只读侦察隔离上下文，防仓库清单涌入主进程 |
| Phase 2 | 主进程规划（Rule 25.3 白名单②） | 设计决策属调度管理器规划职责 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) | ≤3 文件 ≤300 行文档/脚本编写，最小可承载档 |
| Phase 4 | Agent 子代理 executor(sonnet-1) 冒烟 + code-runner-agent(mini) 回归 + code-assistant(haiku-1) 级联修复 | 冒烟需判断型执行；回归机械跑批；修复小改 |
| Phase 5 | 主进程 git 编排（白名单①）+ 机械守卫脚本（install-companion/check-complete） | 合并/部署/终验属簿记编排类 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S-unit 全链强依赖 S1→S2→S3，无可 fan-out 独立子任务）→ 按 Rule 21.4 独立性守门串行调度。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；/goal 为用户侧 harness 命令，技能层不代调。

## Phases

### Phase 1: Requirements & Discovery — 存量能力侦察与边界划定
- [x] 派 explore 子代理完成能力 inventory（仓内 skills/ + ~/.zcode/skills + plans/task-v153 fix-prompts fixture 形态）
- [x] 产出边界清单：与 debugger agent / systematic-debugging skill / iterative-optimizer 的职责划界
- [x] findings.md 落侦察结论 + knowledge-brief.md 材料包索引
- **V-N:** VC-1, VC-4
- **Status:** complete
- **Executor:** explore

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|--------------|----------|-----------|----------|----------|------|
| S1 | 摸清既有错误排查/提示词生成能力与派发任务书格式约定，划出 skill 边界 | explore（mini） | knowledge-brief.md（侦察清单：debugger agent、systematic-debugging、iterative-optimizer、task-v153 fix-prompts.md 五处） | subagent-state/01-explore.md 含边界清单+主进程 Read 复核 | 15min | 0f/0l/15min | 无 | - | pending |

### Phase 2: 设计定稿 — 五步流程/槽位表/QC-FP
- [x] 据 Phase 1 结论定稿：五步流程、fix-prompt 槽位表、QC-FP-1..6 自检项、三态结论
- [x] Decisions Made 登记设计取舍 + silent 行
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由：② 计划系统文件维护+规划职责——Rule 25.3 白名单）

### Phase 3: 编写三件 — SKILL.md + 模板 + selftest + registry
- [x] S1 编写 SKILL.md（≤100 行）
- [x] S2 编写 fix-prompt-template.md（与 Step 4 自检槽位对齐）
- [x] S3 编写 selftest 脚本 + registry 追加 1 行
- [x] alignment-review 对齐审查（Rule 42.6.1 版本一致性+42.6.2）
- [x] 级联修复（Phase 4 S3 提前执行：selftest 平移至 task-planner/scripts，Round 3 回归 66/66 FAIL=0）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|--------------|----------|-----------|----------|----------|------|
| S1 | 编写 SKILL.md：触发/输入契约/五步流程/门控铁律/输出合约/反模式 | 继承 | knowledge-brief.md（Phase 2 定稿材料包：槽位表+QC-FP+锚命名+iterative-optimizer 结构范式） | 六区块 grep 锚齐全且 ≤100 行（wc -l） | 15min | 1f/95l/15min | 无 | - | pending |
| S2 | 编写 templates/fix-prompt-template.md，槽位与 SKILL.md Step 4 自检项一一对齐 | 继承 | knowledge-brief.md（含 S1 产物路径+槽位对齐要求摘要） | 七槽位 grep：根因证据锚/复现/范围/禁改区/验收/回滚/DoD | 10min | 1f/60l/10min | 无 | S1 | pending |
| S3 | 编写 selftest-error-fix-prompt-forge.sh（≥8 断言）并在 selftest-registry.tsv 追加 1 行 | 继承 | knowledge-brief.md（含 registry 格式样例+断言对象清单） | 脚本可执行 exit 0；registry 末行含 error-fix-prompt-forge | 15min | 2f/90l/15min | 无 | S1、S2 | pending |

### Phase 4: 行为冒烟 + 全量回归 + 级联修复
- [x] S1 用真实 fixture（task-v153 fix-prompts.md）实跑五步流程产出 fix-prompt 样例+自检表
- [x] S2 全量 selftest 回归，汇总 FAIL 计数（主进程按白名单③独立执行+复算：66 脚本/820 断言/FAIL=0）
- [x] S3 条件性级联修复（已提前至 Phase 3 执行：selftest 平移，Round 3/4 回归归零；本 Phase 无新增 FAIL，S3 无触发条件）
- [x] Round 结果按 Rule 57 逐轮落盘 progress.md（Round 1-4）
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** executor / code-runner-agent / code-assistant（按 S-unit 行；档位与主进程白名单③执行登记见 Decisions Made）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------------------------|--------------|----------|-----------|----------|----------|------|
| S1 | fixture 实跑 skill 五步流程，产出 fix-prompt 样例 + QC-FP 自检表 | executor（sonnet-1） | knowledge-brief.md（材料包索引：SKILL.md/模板/fixture 三路径+跑法说明） | subagent-state/04-executor/fix-prompt-sample.md 自检表逐条 PASS | 15min | 1f/80l/15min | 无 | Phase 3 S3 | pending |
| S2 | 跑 scripts 目录全量 selftest，汇总 N 脚本/M 断言/FAIL 数与级联面 | code-runner-agent（mini） | knowledge-brief.md（回归命令清单+汇总四要素要求） | subagent-state 落汇总：脚本数+断言数+FAIL 清单（或 FAIL=0） | 15min | 0f/0l/15min | 无 | S1 | pending |
| S3 | 条件性：修复 S2 汇总的 FAIL 项（仅断言计数/锚同步类最小改动） | code-assistant（haiku-1） | knowledge-brief.md（S2 FAIL 清单指针） | 修复后重跑相关脚本 exit 0 | 15min | 2f/100l/15min | 无 | S2 | pending |

### Phase 5: 合并回 + 三宿主部署 + Code Review + 终验交付
- [x] worktree 内 VC 全复验 + git status 干净 → smart-merge-back.sh 合并（6d46d3ec，含 3 轮 master 竞态追并+registry 冲突解并集）
- [x] install-companion --target ×3 部署 + diff -r 三宿主对账 IDENTICAL；task-planner 本体三位（zcode/claude/opencode）--deploy IDENTICAL
- [x] Code Review Gate（code-reviewer）→ APPROVED；P1×3/P2×2/Nit×1 修复轮完成
- [x] 终验 VC 逐条复验 → 委派统计（stats verdict=ok，白名单豁免）→ check-3file-gate exit 0
- [x] INDEX.md/ledger 更新 + 交付总结五要素
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由：① git/worktree 编排 + ② 计划系统文件维护——Rule 25.3 白名单；CR Gate 与编写/冒烟轮为子代理派发）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`：信号①未提交 5 文件均为 plans/（INDEX.md+v152/v154/v155/v156 计划目录），与本任务 skills/ scope 不重叠；信号②③ 其他 3 worktree/wt 分支属并行任务，只读不碰；信号④ 11 任务在册 |
| `isolation` | `worktree` |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge |
| `branch` | `wt/v157-error-fix-prompt-forge`（base=master HEAD 78b9659，**非 main**——main=15a3ecf 落后 master，按 worktree-branch-desync 教训） |
| `merge_back` | merged(6d46d3ec)（smart-merge-back --no-ff；合并前经 3 轮 master 竞态追并 ce670cb→f1a61d0→4b914b3→de1f65e；registry.tsv 冲突=v155 report-reviewability 行与本任务行解并集） |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|----------|---|---|---|-----|------------------------------|
| Phase 1 | 侦察遗漏关键既有能力导致重复造轮子 | 6 | 4 | 4 | 96 | — |
| Phase 3 | 子代理一次成型不符仓库风格（锚命名/行数/格式） | 7 | 5 | 5 | 175 | S1 拆两轮（主体→锚修订）；code-assistant 失败按 22.3① 改派 executor(sonnet-1) |
| Phase 4 | 冒烟自检 FAIL（提示词质量不达标） | 6 | 4 | 4 | 96 | 回 Phase 3 S1 重渲染 ≤2 轮，超限 PARTIAL+遗留清单 |
| Phase 4 | 全量回归计数级联 FAIL（脚本总数 65→66 类断言） | 5 | 5 | 4 | 100 | S3 级联修复（最小改动）；汇总数主进程独立重算防幻觉 |
| Phase 5 | 部署位 diff 漂移 | 7 | 3 | 3 | 63 | 重跑 install-companion --target ×3 后再对账 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | attest 后 S1 建映射 |
| Phase 2 | ☐ |  | |
| Phase 3 | ☐ |  | |
| Phase 4 | ☐ |  | |
| Phase 5 | ☐ |  | |

## Key Questions

1. 与 debugger/systematic-debugging 的边界？（定稿方向：本 skill 消费已定位结论、不重新排查；根因未定位=BLOCKED 退回排查）
2. 提示词自包含标准？（定稿方向：绝对路径+证据锚+复现命令+≥1 机器可检查验收+禁改区；≤3000 字符，超限按 Rule 35.3 落盘引用）
3. 无机器可检查验收的场景？（定稿方向：禁出稿；或降级进「未验证假设区」并显式标注，结论最多 PARTIAL）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| skill 命名 error-fix-prompt-forge，顶层执行型非池成员 | 对齐 iterative-optimizer 范式（v106 先例）；与 debugger/systematic-debugging 边界=消费排查结论不重新排查 |
| `silent:` interaction_mode=silent（计划配置表声明） | 用户指令自包含且当前不可交互；D6 硬停点保留；全部自主决策登记本表 silent: 行供交付复核 |
| worktree base=master 而非 main | main(15a3ecf)落后 master(78b9659)，从 main 建 worktree 会文件不同步（worktree-branch-desync 教训，v135/v141 复发） |
| template_type=general + 终验评估模板沉淀 | variant 目录无 skill-creation 类型（skill-enhancement 已不在位）；按 Rule 34.3② 同类第 2 次触发时评估沉淀新 variant，本次终验必查登记 |
| 无 new_rule | 新建顶层 skill 不涉 Rule 编号新增（v106 先例零新 Rule） |
| code_review=required | 产物含 .sh selftest 脚本属代码组画像（Rule 37）；code-review skill 本会话不可用 → Code Reviewer agent 改派（22.3①） |
| `silent:` 设计=五步闭环(Step0 输入校验→Step1 抽取→Step2 缺口→Step3 渲染→Step4 自检)+QC-FP 6 条+三态结论 | 与 iterative-optimizer 范式同构;fail-closed 三处对应根源覆盖表 5 缺陷面;边界 6 条写「不触发」 |
| `silent:` 模板独立成文件而非内联 | 输出物=提示词本身,槽位模板即其 schema,selftest FP-05/06 可机械断言(v106 无模板因其输出为摘要表) |
| `silent:` selftest 全静态断言 FP-01..08 | 行为面由 Phase 4 冒烟承担(Rule 43.5 提示词类须实际生成测试),静态/行为互补 |
| `silent:` selftest 落位=skills/task-planner/scripts/（非 skill 自带目录） | selftest-registry.sh T03 实证:registry 行只认 task-planner/scripts 计数的 actual 集,顶层 skill 自带 scripts/ 位置会被判孤儿(iterative-optimizer 先例即在该位);回归 Round 1 两处级联 FAIL 后平移+路径块修正,Round 3 归零 |
| `silent:` 终验前 Executor 字段/Handoff 列规范化=裸注册类型名（档位信息移至本表与 S-unit 表） | check-delegation stats 实证 violation:Executor 带档位后缀(explore(mini) 等)致 Handoff 交叉校验失配,含「主进程」字样致 Phase 3/4 误判 main-direct(v150「Handoff 裸名」教训本轮复发一次);按 Rule 51.7 登记本条后重签 attest;档位事实=explore(mini)/code-assistant(haiku-1)/executor(sonnet-1)/code-runner-agent(mini)/code-reviewer(sonnet-1) |
| `silent:` Phase 3 对齐审查与 Phase 4 S2 回归由主进程执行 | 白名单③机械验证命令+②计划系统文件维护(alignment-review 结论落 findings 由主进程单写);非 Phase 级委派,不改 Executor 事实 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| init-session.sh 在仓根运行报错（须计划目录内运行） | 1 | cd plans/task-v157-error-fix-prompt-forge 后重跑成功 | 脚本 CWD 守卫，跑前先读 usage → progress.md Error Log |

## Notes

- Phase 状态随做随翻：pending → in_progress → complete
- 每 Phase complete 前跑 check-3file-gate.sh；派发 drift-checker 留痕三件套（Rule 64.1）
- 子代理 prompt 自带 worktree 绝对路径与「禁触其他 worktree」约束（§11.4）
- 用户需求原文中「对错误排查调研 将排查结果 并且生成提供专业的提示词 用于后期的修正」= R2 目标：把排查结果转化为后期修正可用的专业提示词

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-10 04:55 | ALIGNED（降级） | 全 VC | drift-checker provider 2 连拒→61.5 check-drift.sh 佐证无漂移；三锚比对符合；恢复后补派复核 |
| 2026-10-10 05:05 | ALIGNED（降级） | 全 VC | drift-checker 第 3 次拒→按 22.3 永久切 61.5 降级（check-drift.sh 无漂移）；本任务后续 Phase 走降级佐证 |
| 2026-10-10 06:05 | ALIGNED（降级） | 全 VC | check-drift.sh 无漂移；Phase 3 产出与 Goal/需求/scope 三锚比对符合；Phase 3 产物已按 Rule 27 提交 worktree |
| 2026-10-10 06:40 | ALIGNED（降级） | 全 VC | check-drift.sh 无漂移；冒烟 READY+Round 4 回归 820 断言 FAIL=0 三锚符合 |
| 2026-10-10 07:45 | ALIGNED（降级） | 全 VC | check-drift.sh 无漂移；合并回 6d46d3ec+三宿主 IDENTICAL+终验 COMPLETE 三锚符合 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 1 explore、Phase 3 code-assistant×3 轮+级联/CR 修复×2 轮、Phase 4 executor 冒烟） |
| 主进程直做 Phase 清单 | Phase 2（②规划）、Phase 5（①git/worktree 编排+②簿记）；Phase 4 S2 回归（③机械验证命令，白名单内已登记）；CR Gate 派发 code-reviewer 计入子代理 |
| 委派率 | 3/5=0.6；直做理由全部命中 Rule 25.3 白名单②①③ → WHITELIST-EXEMPT 不降级 |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 04:30 | explore | Phase 1 能力 inventory 与边界划定 | done | 仓内无排查→修正任务书转换能力;边界 6 条(不重排查/不实施修复/非通用提示词工程/非审查/非完成验证/非 skill 维护);fixture=fix-prompts.md A/B/C 自包含任务书形态 | findings.md####[sub:01-explore] | subagent-state/01-explore.md | 只读代理,主进程代写回填 / 0 / ☑ |
| 2 | 05:10 | code-assistant | Phase 3 S1 编写 SKILL.md | done | 84 行落盘;六区块/三态/QC-FP-1..6/尾部锚齐现;主进程 Read 复核通过 | worktree skills/error-fix-prompt-forge/SKILL.md:1-84 | findings.md####[sub:02-code-assistant] | subagent-state/02-code-assistant.md | - / 0 / ☑ |
| 3 | 05:20 | code-assistant | Phase 3 S2 编写模板 | done | 49 行落盘;九槽位+DoD+What/Why 注释;槽位词互现 8/8;主进程 Read 复核通过 | worktree .../templates/fix-prompt-template.md:1-49 | findings.md####[sub:03-code-assistant] | subagent-state/03-code-assistant.md | - / 0 / ☑ |
| 4 | 05:35 | code-assistant | Phase 3 S3 selftest+registry | done | 82 行脚本 FP-01..08;自跑 8/8 PASS exit 0(主进程复跑一致);registry 66→67 末行追加既有行零改动 | worktree .../scripts/selftest-error-fix-prompt-forge.sh;registry.tsv:67 | findings.md####[sub:03b-code-assistant] | subagent-state/03b-code-assistant.md | - / 0 / ☑ |
| 5 | 06:20 | executor | Phase 4 S1 行为冒烟 | done | fixture 实跑五步产出 fix-prompt 样例(九槽位/绝对路径/单 S-unit/grep 验收)+QC-FP 6/6 PASS+结论 READY;主进程 Read 双产物复核,复算绝对路径行=8(自检表自报 7,判据不受影响已登记) | subagent-state/04-executor/fix-prompt-sample.md:1-39;qc-fp-selfcheck.md:1-17 | findings.md####[sub:04-executor] | subagent-state/04-executor/ | - / 0 / ☑ |
| 6 | 06:30 | code-runner-agent | Phase 4 S2 全量回归 | done(改主进程) | 原计划派 code-runner-agent;实际由主进程按白名单③机械验证命令执行(Round 4/5/6 三轮),独立复算 68 脚本 836 断言 FAIL=0 | progress.md Round 4-6 行 | progress Round 4-6 | subagent-state/05-code-runner-agent.md | 白名单③直做已登记 Decisions / 0 / ☑ |
| 7 | 05:55 | code-assistant | Phase 4 S3 提前执行:selftest 位置平移级联修复 | done | 平移到 task-planner/scripts+路径块修正;三脚本 exit 0(fp 8/8/reg T01-05/sr 13/13);主进程复跑+全量 66/66 一致 | worktree .../task-planner/scripts/selftest-error-fix-prompt-forge.sh | findings.md####[sub:06-code-assistant] | subagent-state/06-code-assistant.md | Round1→Round3 归零 / 0 / ☑ |
| 8 | 06:50 | code-reviewer | Phase 5 Code Review Gate | done | REVIEW: APPROVED(P1×3/P2×2/Nit×1 断言强度建议;试跑 8/8 exit 0;bash -n OK);P1/P2/Nit 已由 sub:08 修复轮全修 | subagent-state/07-code-reviewer.md:26 | progress Phase 5 | subagent-state/07-code-reviewer.md | - / 0 / ☑ |
