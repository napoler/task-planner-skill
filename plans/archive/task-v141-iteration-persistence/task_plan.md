# Task Plan: 迭代测试轮次落盘纪律（Rule 57）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「当前技能在执行过程中存在着只越执行，执行过程中，然后数据就不落盘了，不落盘导致数据就发生偏移」
- **R2**: 「最大的问题就是核心就是在执行过程中没有落盘数据，导致原本上应该就是，比如说尤其在测试的时候，第一轮测试、第二轮测试、第三轮、第四轮、第五轮、第六轮，类似依次类推，测试了几十轮之后，因为没有任何的数据落盘，导致的后期的就是各种错误累积」
- **R3**: 「尤其这种迭代，各种迭代测试或者迭代更新的时候，一定要及时落盘，否则的话，因为尤尤其在迭代操作中，会不断的累加数据，导致上下文的分散，及时落盘才可以及时救回」
- **R4**: 「你核心需求是还是需要你去改造，数据落，确保数据落盘，及时落盘」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | Rule 57 条款写入 critical-rules.md，grep 可查 |
| R2 | VC-2 | 每轮测试结果落盘到 progress.md，含轮次编号+命令+结果 |
| R3 | VC-3 | 迭代更新时数据及时落盘，防止上下文分散 |
| R4 | VC-4 | 机器守护脚本 selftest-iteration-persistence.sh 存在且可执行 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则定义 | 无"迭代测试轮次落盘"专门规则，现有 Rule 3/19 只覆盖通用落盘 | 新增 Rule 57 明确每轮测试/迭代结果落盘 | VC-1 |
| 执行流程 | 执行时未遵守落盘规则，数据只在内存中累积 | 在 SKILL.md 执行循环中增加落盘检查点 | VC-2 |
| 机器守护 | 无针对"测试轮次落盘"的机器校验 | 创建 selftest-iteration-persistence.sh | VC-4 |

## Goal

确保 task-planner 执行过程中每轮测试/迭代结果都及时落盘到文件，防止数据偏移和错误累积。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v141` |
| `scope_files` | `references/critical-rules.md, SKILL.md, scripts/selftest-iteration-persistence.sh, scripts/selftest-registry.tsv` |
| `interaction_mode` | `silent` |
| `对齐审查` | `[登记]` Rule 42.6 消费：任务产出或更新的文档在完成前跑 alignment-review 对齐审查 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` Rule 44 消费 |
| `new_rule` | `57` |
| `质量审查工具` | `[检测结论]` Rule 42 消费登记 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 57 条款写入 critical-rules.md | `grep -n "Rule 57" references/critical-rules.md` | 文件存在且含 Rule 57 条款 |
| VC-2 | 每轮测试结果落盘到 progress.md | 检查 progress.md 含轮次编号+命令+结果 | 文件内容可查 |
| VC-3 | 迭代更新时数据及时落盘 | 检查 SKILL.md 执行循环含落盘检查点 | 文件内容可查 |
| VC-4 | 机器守护脚本存在且可执行 | `bash scripts/selftest-iteration-persistence.sh` | 脚本 exit 0 |
| VC-5 | selftest-registry.tsv 已更新 | `grep "iteration-persistence" scripts/selftest-registry.tsv` | 文件内容可查 |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能文件 | `references/critical-rules.md`, `SKILL.md` | 其他技能文件 |
| 脚本 | `scripts/selftest-iteration-persistence.sh`, `scripts/selftest-registry.tsv` | 其他脚本 |
| 文档 | `plans/task-v141-iteration-persistence/*` | 其他文档 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | task-planner critical-rules.md | `/home/terry/.zcode/skills/task-planner/references/critical-rules.md` | 必读 | ☑ |
| 规范/标准 | task-planner SKILL.md | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 必读 | ☑ |
| 项目内部文档/知识库 | selftest-registry.tsv | `/home/terry/.zcode/skills/task-planner/scripts/selftest-registry.tsv` | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 执行过程中（尤其是迭代测试/迭代更新）没有落盘数据，导致多轮测试后错误累积。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，确保每轮测试结果落盘
- [x] 核心问题不解决，其他工作都白费吗？— 是，数据偏移会导致后续步骤基于错误数据操作
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，新增 Rule 57 + 机器守护

## Current Phase

Phase 1

## Next Step

编写 Rule 57 条款并写入 critical-rules.md

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) | 技能文件修改需要判断型执行体 |
| Phase 2 | Agent 子代理 executor(sonnet-1) | 脚本创建需要判断型执行体 |
| Phase 3 | Agent 子代理 code-runner-agent(mini) | 机械验证命令执行 |
| Phase 4 | 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单） | 计划系统文件维护 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源

## Phases

### Phase 1: 规则定义与写入

- [x] 编写 Rule 57 条款（迭代测试轮次落盘纪律）
- [x] 写入 critical-rules.md
- [x] 更新 SKILL.md 执行循环
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

### Phase 2: 机器守护脚本创建

- [x] 创建 selftest-iteration-persistence.sh
- [x] 更新 selftest-registry.tsv
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

### Phase 3: 验证与回归

- [x] 运行 selftest-iteration-persistence.sh
- [x] 运行全量 selftest 回归
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

### Phase 4: 交付

- [x] 终验交付
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe` |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v141` |
| `branch` | `wt/task-v141` |
| `merge_back` | `pending` |

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 规则条款与现有 Rule 冲突 | 6 | 4 | 3 | 72 | — |
| Phase 2 | 守护脚本误报 | 5 | 3 | 4 | 60 | — |
| Phase 3 | selftest 回归失败 | 7 | 3 | 3 | 63 | — |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-06 |  |
| Phase 2 | ☑ | 2026-10-06 |  |
| Phase 3 | ☑ | 2026-10-06 |  |
| Phase 4 | ☑ | 2026-10-06 |  |

## Key Questions

1. Rule 57 的具体条款内容如何定义？
2. 每轮测试结果落盘的具体格式是什么？
3. 机器守护脚本如何校验落盘是否发生？

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 新增 Rule 57 而非修改现有 Rule | 现有 Rule 3/19 是通用落盘规则，Rule 57 专门针对迭代测试轮次 |
| 使用 worktree 隔离 | 技能文件修改属于运行中基础设施，需要隔离保护 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| | 1 | | → progress.md Error Log |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| | | | |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）

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
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 |  |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | | | queued | | | | | - / 0 / ☐ |
| 2 | | | | | | | | | - / 0 / ☐ |
| 3 | | | | | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
