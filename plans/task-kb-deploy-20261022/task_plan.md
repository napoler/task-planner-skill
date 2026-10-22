# Task Plan: 知识库机制部署位同步 + 全部修改提交 GitHub
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）===== -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「现在开始帮我部署。」<sub>（[目标]）</sub>
- **R2**: 「并提交所有修改到GitHub。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-6 | 判据：三个部署位（~/.zcode / ~/.claude / ~/.cursor）与 repo skills/task-planner 逐字一致；部署位模板含「归档计划」「知识提取入库」两步 |
| R2 | VC-4, VC-5 | 判据：git status 干净（除有意忽略的运行态）、origin/master 与本地 master 一致、提交内容含本轮全部改动 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-kb-deploy-20261022/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结（Rule 80.2）
- **恢复协议**：会话恢复后先读专档（#1 至最新条目），再读 task_plan.md
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 部署同步 | repo 模板与三个部署位漂移（实测 9 文件 differ），其他项目拿不到收尾自触发两步 | rsync repo→三位 + diff 校验归零 | VC-1, VC-2 |
| 模板单源 | 项目级覆盖 task_plan.md 与 repo 模板重复，两处改易漂移 | 部署位同步后删覆盖，回落部署位单源 | VC-3 |
| 交付闭环 | 仓库存在未提交改动（含 10-21 另一任务遗留 5 文件 + 多个未跟踪计划目录） | 全量提交 + push origin/master | VC-4, VC-5 |

## 🔒 不变量声明区（Rule 73.3）

| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① R1/R2 原文冻结；② 部署内容 = repo skills/task-planner 现况（源单向部署位，不反向改 repo）；③ 部署位除同步外零改动；④ 既有已归档计划与记忆文件零改写 | 本区块+执行范围限制 |
| 🔀 可变量 | 部署方式（rsync/cp）、提交分组方式、验证子代理选型 | - |
| 📈 学得量 | 部署位漂移基线、提交前工作树实际脏文件清单→findings.md | findings.md |

## Goal
把知识库机制（任务模板收尾「归档→知识提取入库」两步 + kb-*.sh 检索/入库脚本）同步到三个部署位，并把本仓全部修改提交推送到 origin/master，使所有项目的新任务在收尾时自动完成知识提取。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（部署同步 + git 提交，无代码逻辑改动） |
| `session_id` | `87cd12b7093c4119a68444f4ab58e3f1` |
| `worktree_path` | `（无——部署为只读源→部署位写；仓内改动=提交既有工作树内容，非新实现）` |
| `scope_files` | `[skills/task-planner/**(只读), ~/.zcode/skills/task-planner/**, ~/.claude/skills/task-planner/**, ~/.cursor/skills/task-planner/**, .zcode/plan-templates/**, .gitignore, plans/task-kb-deploy-20261022/**]` |
| `对齐审查` | `[登记]` 本任务产出=部署位同步结果与提交历史，交付前核对 repo↔部署位 diff=0（等价对齐审查） |
| `自动超时默认项` | `[默认选项: 部署位同步+提交] [超时值: 5 分钟]` |
| `new_rule` | 留空（本任务不新增 Rule） |
| `质量审查工具` | `[检测结论]` 本任务无质量审查面（机械同步+git 操作），按 Rule 42.2 判为不适用 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 三部署位与 repo skills/task-planner 逐字一致（差异仅部署位独有运行态） | 运行命令 | `diff -rq skills/task-planner <位>` 差异行仅 `.drift-rhythm` 等运行态 |
| VC-2 | 部署位模板含收尾自触发两步 | 运行命令 | `grep -c "归档计划\|知识提取入库" ~/.zcode/skills/task-planner/templates/task_plan.md` ≥2（三位同） |
| VC-3 | 删除项目级 task_plan 覆盖后，本仓新计划仍含两步（回落部署位）且 knowledge-brief 仍带 §7 | 运行命令 | init 冒烟生成物 grep + §7 命中 |
| VC-4 | 提交后工作树干净（除有意忽略的运行态） | 运行命令 | `git status --short` 仅剩预期项 |
| VC-5 | origin/master 与本地 master 一致（推送成功） | 运行命令 | `git rev-parse master origin/master` 相等 ∧ `git log --oneline -1 origin/master` |
| VC-6 | 知识库机制端到端可用（检索命中 + 索引幂等） | 运行命令 | `scripts/kb-search.sh 派发` 命中 ∧ 重建索引后 `git diff --stat knowledge/INDEX.md` 无变化 |

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**；VC 通过但有遗留 → **PARTIAL**；≥1 VC 失败且重试 3 次无效 → **BLOCKED**。

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| 目标型 R 行 | R1, R2 |
| 问题解决判据 | R1=其他项目的新任务收尾自动携带归档+知识提取两步（部署位模板实证）且本仓生效路径不回归；R2=全部修改进入 origin/master（推送实证） |
| 裁决 | **COMPLETE** —— VC-1~VC-6 全 PASS（zcode 位 15 卫星逐字零差异 / 三位模板收尾两步 grep=2 / 删覆盖后冒烟回落生效 / 全量 selftest 92-0 / master==origin/master / 知识库检索命中+索引幂等）；独立子代理复核 VERDICT: PASS；无遗留阻塞 |

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 三位部署 | repo 技能树同步到 ~/.zcode ~/.claude ~/.cursor 三部署位 | `diff -rq` 差异行仅运行态 + 三位 grep 两步 ≥2 | S1-S3/Phase 1 | complete |
| G2 | 单源与冒烟 | 删项目级 task_plan 覆盖后本仓 init 仍带两步 + §7 知识回链 | init 冒烟生成物 grep 命中 + §7 命中 | S4-S6/Phase 2 | complete |
| G3 | 提交推送 | 全部修改提交并 push origin/master，工作树干净 | `git status --short` 预期项 + `master == origin/master` | S7-S8/Phase 3 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 部署位（写） | ~/.zcode/skills/task-planner/**、~/.claude/skills/task-planner/**、~/.cursor/skills/task-planner/** | 部署位其他技能/配置；~/.zcode/AGENTS.md；~/.zcode/skills/task-planner/ 之外的一切 |
| 仓内（写） | .gitignore、.zcode/plan-templates/task_plan.md（删除）、plans/** | skills/task-planner/** 内容改动（源单向部署位，本任务不改源） |
| 计划文档 | plans/task-kb-deploy-20261022/** | 其他 plans/ 目录的内容改写（仅新增提交，不改历史） |
| 🚫 禁区 | — | ~/.zcode/skills/** 非 task-planner 目录；~/.agents/**；主仓 SKILL.md/critical-rules.md/selftest 内容改写（仅提交既有改动） |

**执行前自我检查**：文件在列表中？改动必要？用户明确要求？全部 Yes → 执行。

## 📋 变更标注表（Rule 74.3）

| 编号 | 对象（文件+锚点） | 类型 | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据 | 执行动作 |
|------|------------------|------|-----------------------|----------------|------|---------|
| CA-1 | ~/.zcode ~/.claude ~/.cursor 三位 skills/task-planner/** | 更新（部署同步） | 增量 | R1「现在开始帮我部署」 | repo skills/task-planner 为源，同步后 diff 归零 | rsync -a（不加 --delete） |
| CA-2 | .zcode/plan-templates/task_plan.md | 删除 | 删除 | R1（部署后单源） | 与部署位模板已逐字一致（CA-1 后），保留即双源漂移 | `git rm` 覆盖文件 |
| CA-3 | .gitignore | 新增 2 行 | 增量 | R2（提交所有修改） | .video_agent/ 与 plans/archive/.drift-rhythm/ = 运行态产物，入库会污染仓库 | 追加忽略条目 |
| CA-4 | 10-21 遗留 5 文件 + 未跟踪计划目录 | 更新（提交） | 增量 | R2「提交所有修改到GitHub」 | 工作树实况（git status），内容属已完工任务（Rule 51.9-51.13 文本+守卫） | 统一提交并推送 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 知识源 | 用途 | 已读 |
|--------|------|------|
| knowledge/entries/planflow-plan-lifecycle-gates.md | attest/check-complete 门控序列 | 是 |
| knowledge/entries/discipline-execution-honesty.md | 完成声称三证据 | 是 |
| skills/task-planner/references/worktree-isolation.md | 部署位与隔离边界 | 是 |

## ⚠️ 核心问题定义

| 问题 | 答案 |
|------|------|
| 问题 | 「部署」= 把 repo 技能树同步到三个部署位（~zcode/~claude/~cursor），使所有项目生效 |
| 为什么不是别的 | 部署位写入属保护区（§六），但用户本轮显式授权「开始帮我部署」；本任务不碰 task-planner 之外的受保护文件 |
| 成功判据 | VC-1~VC-6 全 PASS |

## 🔍 调研需求与检索计划（Rule 75.1）

三态分析：本地可判定（部署位漂移 = 本地 diff 事实）→ **不触发网络调研**（无外部事实依赖）。

## 🔍 证据面清单（Rule 58.1）

| 事实 | 证据来源 | 采集方式 |
|------|---------|---------|
| 部署位漂移基线 | diff -rq（部署前实测 9 文件 differ） | Bash |
| 同步后一致性 | diff -rq 归零 | Bash |
| 提交与推送 | git status / git log / rev-parse | Bash |
| 独立验收 | 独立子代理复核部署位 diff | Agent 派发 |

## Current Phase
Phase 3 全部 complete（待归档）。

## Next Step
归档计划（Rule 81.1）→ 交付总结。

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面 | 选择理由 |
|-------|-----------|---------|
| Phase 1 | 主进程直做（Bash 机械同步，白名单②） | 纯文件同步，diff 需主进程即时复核 |
| Phase 2 | 主进程直做（Bash 冒烟 + 后台回归批） | 回归批已后台运行 |
| Phase 3 | 主进程直做（git 编排，白名单②）+ general-purpose 独立复核 | 复核视角独立，避开主上下文既有结论（Rule 33.3） |

## Phases

### Phase 1: 部署同步（三位）
- [ ] rsync repo skills/task-planner → ~/.zcode 位，diff 校验
- [ ] rsync → ~/.claude 位、~/.cursor 位，diff 校验
- [ ] 三位模板含收尾两步（grep 实证）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** 主进程（例外理由:② 机械同步/环境配置类操作，Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|---------|------|------|------|------|------|
| S1 | 同步 ~/.zcode 位 | 主进程（白名单②） | repo skills/task-planner | diff 归零 | 3min | 0f/0l/3min | 无 | - | done |
| S2 | 同步 ~/.claude 位 | 主进程（白名单②） | 同上 | diff 归零 | 3min | 0f/0l/3min | 无 | S1 | done |
| S3 | 同步 ~/.cursor 位 | 主进程（白名单②） | 同上 | diff 归零 | 3min | 0f/0l/3min | 无 | S2 | done |

### Phase 2: 单源清理 + 冒烟 + 回归
- [ ] 删除 .zcode/plan-templates/task_plan.md（部署位已同源）
- [ ] init 冒烟：新计划仍含收尾两步 + knowledge-brief 带 §7
- [ ] 全量 selftest 零回归
- **V-N:** VC-3, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:② 机械校验类操作，Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|---------|------|------|------|------|------|
| S4 | 删项目级 task_plan 覆盖 | 主进程（白名单②） | .zcode/plan-templates/ | 文件消失且 init 回落部署位 | 2min | 1f/0l/2min | 无 | S3 | done |
| S5 | init 冒烟复验 | 主进程（白名单②） | 临时计划目录 | 新计划含两步 + §7 | 4min | 0f/0l/4min | 无 | S4 | done |
| S6 | 全量 selftest 回归 | 主进程（后台批） | skills/task-planner/scripts | FAIL=0 | 15min | 0f/0l/15min | 无 | S5 | done |

### Phase 3: 提交推送 + 独立复核 + 归档
- [ ] .gitignore 追加运行态忽略条目
- [ ] git add/commit/push origin/master
- [ ] 独立子代理复核部署位一致性
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:② git 编排类操作，Rule 25.3 白名单）

| ID | 目标(≤1 句) | 执行体 | 输入 | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|------|---------|------|------|------|------|------|------|
| S7 | .gitignore 追加 + 全量提交推送 | 主进程（白名单②） | 工作树全量 | 推送成功且 master==origin/master | 6min | 1f/0l/6min | 无 | S6 | done |
| S8 | 独立复核部署位一致性 | general-purpose | 三位路径 + repo | 复核结论 diff=0 | 5min | 0f/0l/5min | 无 | S7 | done |

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `low`（仓内改动=提交既有工作树内容，非新实现；部署位为单向同步） |
| `isolation` | `none-needed`（用户显式授权部署 + 仓内无新实现代码，§十一.5.4 小改例外） |
| `merge_back` | 不适用（无分支/worktree） |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1 | rsync 覆盖掉部署位独有文件 | 8 | 2 | 3 | 48 | 不使用 --delete；同步后 diff 逐项复核 |
| Phase 3 | 误提交运行态/半成品 | 5 | 4 | 3 | 60 | 提交前逐条审 git status；运行态入 .gitignore |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-22 | 6 项 todo 已建 |
| Phase 2 | ☑ | 2026-10-22 | |
| Phase 3 | ☑ | 2026-10-22 | |

## Key Questions
- 部署位漂移范围？→ 实测 9 文件 differ + 部署位独有运行态目录。
- 提交是否含其他会话遗留？→ 是（10-21 Rule 51.9-51.13 文本+守卫），用户明示「提交所有修改」。

## Decisions Made
1. 部署范围=三个部署位（~/.zcode ~/.claude ~/.cursor），与本仓历史做法一致（三位 IDENTICAL 口径）。
2. 共享模板 knowledge-brief.md 不加 §7：避免对无知识库机制的项目产生悬空引用；§7 保留在本仓项目级覆盖 `.zcode/plan-templates/knowledge-brief.md`。
3. 删项目级 task_plan.md 覆盖（部署后与部署位同源，保留=双源漂移）；knowledge-brief 覆盖保留（承载 §7 项目专属段）。
4. 运行态（.video_agent/、plans/archive/.drift-rhythm/）入 .gitignore，不入库。
5. 部署采用「三方并集 + 冲突人工裁决」而非单向覆盖：部署位含仓库没有的活内容（Rule 44.3 / L0-E，10-22 03:21 同步），单向 rsync 覆盖 = 静默删除当天上线的规则。
6. 并集结果回写仓库作单一源，再由仓库同步三位：保证 GitHub 版本 = 实际生效版本（否则「提交所有修改」推上去的仍是不含 44.3/L0-E 的旧源）。
7. 部署位比 base 提交更旧时弃用 base 做 3 方合并（方向会反转），改「仓库最新内容 + 按平台还原运行时 flavor」两段式。
8. 部署范围扩到 15 卫星全树（不止 task-planner）：卫星 task-discipline 缺 Rule 93 与 execution-recall-card.md，而 task-planner 的 task_plan.md:312 / SKILL.md:95 引用该卡，仅同步主技能会留下悬空引用。

## Errors Encountered
1. 并集解在「部署位比 base 更旧」时取错侧（cursor 键数断言留旧值 47）→ 改两段式：仓库最新内容 + 按平台还原运行时 flavor（详见 progress.md Error Log #1）。
2. attest 拒锁「12 条 VC 中仅 6 条含可执行验证命令」→ Goal Gate 复选行改前缀「复验 VC-N：」，避免与 VC 条目同形被重复计数。
3. init 冒烟在 /tmp 下被硬校验拒绝 → 冒烟目录改落本仓 plans/ 下，用后删除并清指针。

## Notes
- 部署位与仓库呈**双向**差异（部署位含 videop1 流 10-22 03:21 同步的 Rule 44.3 / L0-E；仓库含 Rule 93 / 51.9-51.13 / KB 两步）——单向覆盖会静默删掉当天上线的活规则，这是本次部署最关键的判定。
- 卫星 task-discipline 此前缺 Rule 93 与 execution-recall-card.md，而 task-planner 的 task_plan.md:312 / SKILL.md:95 引用该卡 → 部署必须连卫星一起同步，否则新规则指向空文件。
- 平台运行时差异（bun vs node）是部署位的合法差异，不写入共享模板，由部署环节单独还原。

## 🚨 Drift Log（漂移检测记录）
- 2026-10-22 08:10 检测：执行方向始终为「部署位同步 + 提交入库」，未偏离用户指令（部署 + 提交 GitHub）；中途发现卫星层遗漏后主动扩到 15 卫星全树（用户指令「部署」的自然射程，非范围漂移）。
- 2026-10-22 08:25 检测：未触碰三个其他会话在途任务（task-defect-rrv13-dg12-false-pass / task-P01-evidence-anchor / task-v188-skill-audit-fix）——仅将其计划文件随「提交所有修改」入库，未改动其内容。

## 📊 Batch Report（批量处理质量门控 — Rule 18.6）
本任务为三位置机械同步（非内容生产批），按 Rule 18.6 判不适用：每位置 diff 逐项复核 = 逐批验收。

## 📊 委派统计（Rule 25.4 — 终验前必填）
- 机器统计为事实源：`check-delegation.sh stats plans/task-kb-deploy-20261022` → `{"phases_total":3,"phases_delegated":0,"main_direct_count":3,"delegation_rate":0.000,"violations":[],"verdict":"ok"}`
- 主进程直做 Phase 均为白名单②机械/环境/git 类操作（登记于各 Phase Executor 字段）；独立复核子代理已实际派发（Handoff #1，general-purpose）

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | general-purpose | 独立复核三部署位与 repo 技能树一致性 | done | VERDICT: PASS（6/6 项：三位模板收尾两步=2、critical-rules 51.9-51.13 在位、zcode 位差异=0、claude/cursor 差异恰 9 个 flavor 文件且无非 flavor 差异、零冲突标记、三位 selftest-requirement-coverage 27/27） | plans/task-kb-deploy-20261022/subagent-state/1-general-purpose.md |
| 2 | 无 | 主进程直做（S1-S7 机械同步/校验/提交） | done | 部署+提交主流程 | - |
