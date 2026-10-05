# Task Plan: 纠正技能中"未验证就声称完成"的严重缺陷

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「当前技能存在一个严重的缺陷，比如说存在着严重的惰性行为。我举例来说，比如说我在测试，比如说生成图像的提示词的，要求修改测试，修，不是要求修改那个图像生成的提示词之后，没有进行任何测试，还向我炫耀说，本次消耗图片生成额度为0。」
- **R2**: 「这是严重的违规行为，因为没有经过任何测试的图片生成嗯生成所带来的提示词全部都是属于完全性的脑补，不具有任何的参考价值，没有在实战中进行测试过的。」
- **R3**: 「却恶意的恶意的，却将这些作为作为嗯嗯作为就是优点来恶意的鼓吹，这是严重的投毒行为。」
- **R4**: 「我希望以后做所有工作的时候，必须是遵循之前我明确表示之前就是验证机制，就是没有经过验证就没有任何的参考。」
- **R5**: 「对当前的就下面上面说到的这个图片生成的提示词的优化一样，没有经过真实的图片测试。那么也就是说没有经过真实的验证，可信度几乎为0。」
- **R6**: 「必须就必须进行纠正这种低级错误。」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | 技能规则中明确禁止"未测试就声称完成"的条款存在 |
| R2 | VC-2 | 技能规则中明确要求"提示词/参数优化后必须实际生成测试"的条款存在 |
| R3 | VC-3 | 技能规则中明确禁止"将零消耗/未测试作为优点宣传"的条款存在 |
| R4 | VC-4 | 技能规则中明确"未经验证的结果禁止作为优点宣传"的条款存在 |
| R5 | VC-5 | 技能规则中明确"图像生成提示词优化后必须进行真实图片测试"的条款存在 |
| R6 | VC-6 | 所有修改经过用户确认，且 selftest 全部通过 |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 规则定义 | Rule 43/51 未明确覆盖"提示词/参数优化"类修改的验证要求 | 在 Rule 43 或 Rule 51 中增加"提示词/参数优化后必须实际生成测试"的明确条款 | VC-2, VC-5 |
| 规则定义 | 缺少对"将零消耗/未测试作为优点宣传"的明确禁止 | 在 Rule 43 或 Rule 26 中增加"禁止将未测试结果作为优点宣传"的条款 | VC-3, VC-4 |
| 执行流程 | 缺少对"提示词优化"类任务的验证门控 | 在 SKILL.md 或 critical-rules.md 中增加验证门控 | VC-1, VC-6 |
| 脚本守护 | 缺少对"未测试就声称完成"的脚本检测 | 在 selftest 脚本中增加相关断言 | VC-6 |

## Goal

纠正技能中"未验证就声称完成"的严重缺陷，确保所有修改（特别是图像生成提示词优化）必须经过实际测试验证，禁止将未测试结果作为优点宣传。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `ad57372796a04363aeba8760b3693967` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v133` |
| `scope_files` | `references/critical-rules.md, SKILL.md, scripts/selftest-reliability-institution.sh, scripts/selftest-requirement-coverage.sh` |
| `interaction_mode` | `silent` |
| `对齐审查` | 任务产出文档完成前跑 alignment-review |
| `自动超时默认项` | 无 2+ 选项询问点 |
| `new_rule` | 留空（不新增 Rule 编号，在现有 Rule 43/51 中增加条款） |
| `质量审查工具` | 无缺口（使用现有 code-review skill） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 技能规则中明确禁止"未测试就声称完成"的条款存在 | Read critical-rules.md 检查新增条款 | `references/critical-rules.md` |
| VC-2 | 技能规则中明确要求"提示词/参数优化后必须实际生成测试"的条款存在 | Read critical-rules.md 检查新增条款 | `references/critical-rules.md` |
| VC-3 | 技能规则中明确禁止"将零消耗/未测试作为优点宣传"的条款存在 | Read critical-rules.md 检查新增条款 | `references/critical-rules.md` |
| VC-4 | 技能规则中明确"未经验证的结果禁止作为优点宣传"的条款存在 | Read critical-rules.md 检查新增条款 | `references/critical-rules.md` |
| VC-5 | 技能规则中明确"图像生成提示词优化后必须进行真实图片测试"的条款存在 | Read critical-rules.md 检查新增条款 | `references/critical-rules.md` |
| VC-6 | 所有修改经过用户确认，且 selftest 全部通过 | 运行 selftest 脚本 | `bash scripts/selftest-reliability-institution.sh` |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文档 | `references/critical-rules.md` | 其他 .md 文件 |
| 技能文档 | `SKILL.md` | 其他技能文件 |
| 脚本 | `scripts/selftest-reliability-institution.sh`, `scripts/selftest-requirement-coverage.sh` | 其他脚本 |
| 配置 | `config.json` | 其他配置文件 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | Rule 43 执行可靠性制度化 | `references/critical-rules.md` | 必读 | ☑ |
| 规范/标准 | Rule 51 需求覆盖与完成声称门控 | `references/critical-rules.md` | 必读 | ☑ |
| 规范/标准 | Rule 26 质量优先于速度门控 | `references/critical-rules.md` | 必读 | ☑ |
| 项目内部文档/知识库 | selftest-reliability-institution.sh | `scripts/selftest-reliability-institution.sh` | 必读 | ☑ |
| 项目内部文档/知识库 | selftest-requirement-coverage.sh | `scripts/selftest-requirement-coverage.sh` | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 技能中缺少对"提示词/参数优化"类修改的验证要求，导致修改后未进行实际测试就声称完成，甚至将"零消耗"作为优点宣传。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，技能规则将完善
- [x] 核心问题不解决，其他工作都白费吗？— 是，所有未验证的修改都不可信
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，在现有 Rule 43/51 中增加明确条款

## Current Phase

Phase 4

## Next Step

Phase 4 交付：git commit（worktree 内）→ merge-back → 用户确认（VC-6）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) | 需要深入理解现有规则并设计修改方案 |
| Phase 2 | Agent 子代理 code-assistant(haiku-1) | 单文件小修改，精确编辑 |
| Phase 3 | Agent 子代理 code-runner-agent(mini) | 运行 selftest 验证 |
| Phase 4 | 主进程 | 簿记+交付 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源

## Phases

### Phase 1: 根因分析与修改方案设计
- [x] 分析现有 Rule 43/51 的缺陷
- [x] 设计修改方案（在哪些 Rule 中增加哪些条款）
- [x] 文档化修改方案
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** executor（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤ 1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 分析 Rule 43/51 缺陷并设计修改方案 | 继承 | critical-rules.md + SKILL.md | findings.md + modification-plan.md | 30min | done |

### Phase 2: 实施修改
- [x] 修改 critical-rules.md 增加验证条款（43.5/43.6/51.8/53.5-Q9，M1-M4+M6.4）
- [x] 修改 SKILL.md 增加验证门控（C37 合规行+C31 行内+Rule 43/51 摘要 bullet，M5）
- [x] 修改 selftest 脚本增加断言（R-02 演进+R-13..R-16、RC-23、skill-split 478、registry 两行，M6-M8）
- **V-N:** VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant（haiku-1）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤ 1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S2 | 实施 M1-M8 修改 | 继承 | modification-plan.md | 6 文件 git diff +51/-12 | 20min | done |

### Phase 3: 验证与测试
- [x] 运行 selftest 验证修改（4 目标脚本全绿：R-01..16/RC-01..23/skill-split 41 断言/registry 5 断言）
- [x] 确认所有 VC 通过（全量 51 个 selftest-*.sh 回归 0 FAIL）
- **V-N:** VC-6
- **Status:** complete
- **Executor:** code-runner-agent（mini）

<!-- S-unit 派发单元表(Rule 22.6) -->
| ID | 目标(≤ 1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S3 | 运行 selftest 验证 | 继承 | 4 目标 selftest 脚本 | 全量 51 个 selftest-*.sh 0 FAIL | 10min | done |

### Phase 4: 交付
- [ ] 用户确认
- [ ] 交付总结
- **V-N:** VC-6
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（技能文件修改，运行中基础设施） |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v133` |
| `branch` | `wt/task-v133` |
| `merge_back` | `pending` |

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 修改方案与现有规则冲突 | 6 | 4 | 3 | 72 | — |
| Phase 2 | 修改引入回归缺陷 | 7 | 3 | 4 | 84 | — |
| Phase 3 | selftest 失败 | 5 | 3 | 2 | 30 | — |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-05 |  |
| Phase 2 | ☑ | 2026-10-05 |  |
| Phase 3 | ☑ | 2026-10-05 |  |
| Phase 4 | ☑ | 2026-10-05 |  |

## Key Questions

1. 在 Rule 43 还是 Rule 51 中增加"提示词/参数优化后必须实际生成测试"的条款？
2. 如何确保"禁止将零消耗/未测试作为优点宣传"的条款得到有效执行？

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 在 Rule 43 中增加"提示词/参数优化后必须实际生成测试"的条款 | Rule 43 是执行可靠性制度化的核心规则，适合增加此类要求 |
| 在 Rule 26 中增加"禁止将未测试结果作为优点宣传"的条款 | Rule 26 是质量门控，适合增加此类禁止条款 |
| 使用 worktree 隔离开发 | 技能文件修改属于运行中基础设施，需要隔离 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）

| 字段 | 值 |
|------|-----|
| `total` |  |
| `success` |  |
| `failed` |  |
| `failure_rate` |  |
| `sampled_pass` |  |
| `sampled_fail` |  |
| `pre_check` |  |
| `rollback_point` |  |

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
