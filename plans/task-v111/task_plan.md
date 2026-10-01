# Task Plan: task-v111 注释完整性规范（Rule 45：完整注释+思路入注）
<!-- 规范演进模板 — 用户裁决沉淀：所有产出完整注释，禁止为美观删减，思路入注释 -->

<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->

## Goal

将用户 2026-10-02 注释纪律裁决沉淀为技能规范 **Rule 45（注释完整性规范）**：所有产出（代码/脚本/文档/模板/配置）必须包含完整注释——每函数/逻辑段带 What（做什么）+ Why（设计思路与取舍理由），头注释含用途/输入/输出/依赖；**禁止为美观或简洁减少注释**；显式声明用户裁决优先于平台默认「克制注释」风格。含级联（Rules 1-45 口径/SKILL 索引面/selftest 宽容锚）与存量补强清单（交用户裁决）；全部验证由全新独立子代理执行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（修改面=规范 .md+selftest 断言；脚本逻辑零变更） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v111`（§11.2） |
| `scope_files` | `references/critical-rules.md`（Rule 45 新增+Rules 1-45 口径级联）、`SKILL.md`（索引面两处 :246 括注+:304 索引行）、selftest 宽容锚行（Phase 1 普查清单为准）、`templates/subagent_dispatch.md`（如需）；memory 新增 feedback 条目；写入面 `plans/task-v111/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前**独立子代理**按 alignment-review 审查；变更记录三要素 |
| `自动超时默认项` | D1 批准默认超时 5 分钟；存量回溯范围=列清单交用户（44.2 裁决不自动扩） |
| `质量审查工具` | alignment-review（独立子代理）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 修订后全量 selftest 回归 0 FAIL（**独立子代理**，主仓合并后终验场） | fresh 42 脚本逐项 rc | subagent-state/ |
| VC-2 | Rule 45 落地+Rules 1-45 口径全链一致（SKILL 索引面两处/critical-rules 标题/selftest 宽容锚——Phase 1 清单为准，grep「1-44」旧口径零残留或已挂演进标注） | **独立子代理** grep 实测 | checkpoint |
| VC-3 | 注释标准自证：本任务自身新增/修改的脚本行按 Rule 45 标准注释（含 Why），**独立子代理**按新规范审查通过 | fresh 审查 checkpoint | subagent-state/ |
| VC-4 | 存量注释补强清单落盘（脚本/文档逐个评估注释缺口+补强建议+工作量分级），交用户裁决不自动实施 | 清单 Read 核对 | plans/task-v111/legacy-comment-audit.md |
| VC-5 | worktree 合并回+对账结论+porcelain 干净 | 合并输出+diff | progress.md |
| VC-6 | 对齐审查通过+memory feedback 条目（三要素：用户裁决原话+平台默认风格冲突声明+失效条件） | checkpoint+memory Read | findings+memory |

> **验证独立性铁律（延续 P0）**：全部验证由全新独立子代理执行。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规范面（worktree） | `references/critical-rules.md`（Rule 45 新增+口径级联） | 其他 Rule 语义 |
| 索引面（worktree） | `SKILL.md` 索引面两处+References 表行；selftest 宽容锚行（普查清单） | 清单外 |
| memory 面（非仓库） | 新增 feedback 记忆条目+MEMORY.md 索引行 | 其他记忆文件 |
| 计划系统文件 | `plans/task-v111/*` | 其他 plan 目录 |
| 明确排除 | 宪法 §九（用户级保护区，交付时提醒同步）；存量脚本/文档注释回溯（仅列清单，Phase 1 产出） | 未授权扩围 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 用户裁决 | 注释纪律原话（完整注释/便于理解维护/禁为美观减少/思路入注释） | 本计划 Goal+Phase 1 存档 | 必读 | ☑ |
| 平台冲突 | ZCode 平台默认注释倾向=克制（「注释只写代码无法自明的约束」），用户裁决相逆 | 系统提示注释纪律段+Phase 1 确认 | 必读 | ☑ |
| 宪法既有 | §九注释条款（修改注明原因时间原行为/新增 docstring/修 bug 三要素/禁 TODO 替代） | ~/.zcode/AGENTS.md §九（只读参照，不修改） | 必读 | ☑ |
| 级联先例 | Rules 1-44→1-45 口径级联面（v103/v109/v110 三代教训：SKILL 索引面两处+宽容锚） | memory task-v103/v110 | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 注释纪律此前无技能级规范承载（宪法 §九有条款但 skill 侧零映射，且平台默认「克制注释」倾向与用户「完整注释+思路入注」要求相逆）——需要 Rule 45 固化新标准，使今后所有产出执行统一注释纪律，并显式声明用户裁决优先。

**核心问题判断**:
- [x] 解决后能交付吗？——能：Rule 45+级联+自证审查+存量清单=可交付
- [x] 不解决白费吗？——是：无规范则产出注释密度随机，维护成本不可控
- [x] 方法清晰可执行？——是：普查→Rule 45→级联→自证→合并，先例充分

## Current Phase

Phase 1

## Next Step

派 fresh executor 普查注释规范面（条款现状/口径级联面/注释密度基线）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面 | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) fresh | 普查判断型只读 |
| Phase 2 | Agent 子代理 executor(sonnet-1) + worktree | Rule 45 新增+级联 |
| Phase 3 | Agent 子代理 executor fresh ×2 | 回归+自证审查+对齐审查 |
| Phase 4 | Agent 子代理 executor(对账) + 主进程（① git+② 簿记+③ memory） | 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中（串行依赖链）；**/goal 对齐**: 用户未使用

## Phases

### Phase 1: 注释规范面普查（fresh 只读）
- [ ] 技能内注释条款全集（critical-rules/SKILL/CLAUDE.md 中「注释/docstring/comment」相关表述）
- [ ] Rules 1-45 口径级联面：SKILL :246 括注+:304 索引行+critical-rules 标题「Rules 1-44」+selftest 宽容锚（grep「1-44\|1-3\[」全集）
- [ ] 脚本注释密度基线：75 脚本抽样分层（头注释在位率/函数注释率/逻辑段注释率/Why 注释存在性）
- [ ] Rule 45 草案：条款结构（适用范围/What+Why 双层要求/头注释四要素/禁止删减/平台冲突声明/例外面）
- **V-N:** VC-2, VC-4
- **Status:** in_progress
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 普查+Rule 45 草案+存量清单 | 继承 | critical-rules/SKILL/CLAUDE.md+scripts 抽样 | ≤15min | pending |

### Phase 2: Rule 45 新增与级联（worktree）
- [x] Rule 45 七子条落地（critical-rules.md:453-463）+括注级联 3 处（SKILL frontmatter/:246/:304）——字面锚「Rules 1-39」计数不减（括注模式），PT-08/WF-10 selftest 全绿实证
- [x] selftest 零级联达成（括注策略）；全量回归归 Phase 3 独立验证
- [x] worktree commit 干净
- **V-N:** VC-2, VC-3, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | Rule 45+口径级联+断言 | 继承 | Phase 1 草案+级联清单 | ≤15min | pending |

### Phase 3: 独立验证（fresh ×2）
- [ ] 全量 42 selftest 回归（worktree）
- [ ] 注释标准自证审查（fresh 按 Rule 45 审本任务 diff 中脚本/文档改动的注释合规）+ alignment-review 对齐审查
- **V-N:** VC-1, VC-3, VC-6
- **Status:** pending
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 回归 | 继承 | worktree selftest 42 个 | ≤15min | pending |
| S2 | 自证审查+对齐审查 | 继承 | worktree diff+Rule 45+alignment-review SKILL | ≤15min | pending |

### Phase 4: 合并回与终验簿记
- [ ] smart-merge-back+清理+主仓复验
- [ ] 部署对账（fresh）+结论登记
- [ ] memory feedback 条目（裁决原话+平台冲突声明+失效条件）+MEMORY.md 索引
- [ ] verification.md+check-complete+INDEX+簿记 commit
- **V-N:** VC-4, VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（① git+② 簿记+③ memory——白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v110 notepad+本计划目录，属预期） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v111` |
| `branch` | wt/task-v111 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底 |
|-------|---------|---|---|---|-----|---------|
| Phase 2 | Rules 1-45 口径级联漏改（宽容锚第 N 变种） | 6 | 5 | 3 | 90 | Phase 1 grep 全集清单+Phase 3 回归+全库 grep 复验 |
| Phase 2 | Rule 45 与宪法 §九语义冲突（重复/矛盾） | 5 | 3 | 3 | 45 | Rule 45 定位=skill 侧承载+引用宪法条款衔接，不重复不矛盾 |
| Phase 3 | 自证审查与规范循环依赖 | 3 | 3 | 2 | 18 | fresh 审查者仅按 Rule 45 文本审 diff |
| Phase 5 | 合并冲突 | 6 | 2 | 2 | 24 | V5 预案（v109/v110 先例） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |

## Key Questions

1. 技能内注释条款现状与缺口？（Phase 1）
2. Rules 1-45 口径级联面全集？（Phase 1 grep）
3. Rule 45 条款结构如何兼顾完整注释与「注释要有意义」（避免无意义灌水注释）？（Phase 1 草案——双层=What+Why 都要，但须真实有效）
4. 存量补强范围与工作量？（Phase 1 清单→用户裁决）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=rule-enhancement | 规范演进；白名单合法值 |
| D 类新任务 task-v111 | 用户注释裁决=独立规范变更（Rule 8.1） |
| Rule 编号=45（新增独立 Rule） | 注释纪律值得独立条款承载（selftest 守卫+模板引用锚点）；并入 Rule 9 会使条款过载 |
| 平台冲突显式声明入条款 | 系统默认「克制注释」倾向与用户裁决相逆，Rule 45 内声明「用户裁决优先」防执行层摇摆 |
| 存量回溯不自动实施 | 工程量大且易引回归；列清单交用户裁决范围（保守策略） |
| 验证全部独立子代理（延续 P0） | v108-v110 用户明示 |
| 思路复述已呈示 | 2026-10-02 按 28.2.1 |
| silent: 自动裁决 D1 批准（Rule 44.3：超时 5min/默认批准/触发 2026-10-02/理由=用户裁决指令明确+worktree+独立验证兜底/被覆盖=等显式 yes） | — |

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
|      |             |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 4 |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 |  |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | executor | Phase 1 普查+草案+存量清单 | queued | | | | plans/task-v111/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 Rule 45+级联 | queued | | | | plans/task-v111/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 3 回归 | queued | | | | plans/task-v111/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 自证+对齐审查 | queued | | | | plans/task-v111/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 4 部署对账 | queued | | | | plans/task-v111/subagent-state/5-executor.md | - / 0 / ☐ |
