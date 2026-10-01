# Task Plan: task-v112 任务交付总结模板与终验规范（五要素交付总结）
<!-- 规范演进模板 — 用户裁决沉淀：交付总结模板（说明/产出/审查/风险/下一步） -->

<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->

## Goal

创建 **templates/delivery-summary.md 任务交付总结模板** 并规范终验交付流程：任务完成后必须按模板向用户输出完整交付总结，含五要素——①任务说明（目标回顾+执行过程摘要）②产出清单（文件级+验证状态）③审查信息（VC/回归/对齐审查/委派统计/质量门控尽量详细）④风险点列举（已知遗留/待裁决/失效条件/回滚方式，必须列举）⑤下一步建议（用户可执行行动项）；模板入库确保后期所有产出的总结按此执行；全部验证由全新独立子代理执行。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（修改面=模板 .md+SKILL 终验段指针+selftest 断言，无代码逻辑变更） |
| `session_id` | `afd0b28ec78a4e8ca9f0acde60eeaaf7` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v112`（§11.2） |
| `scope_files` | 新增 `templates/delivery-summary.md`；`SKILL.md`（终验交付段指针+References 表行）；selftest 断言（Phase 1 清单为准）；写入面 `plans/task-v112/*` |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前**独立子代理**按 alignment-review 审查；变更记录三要素 |
| `自动超时默认项` | D1 批准默认超时 5 分钟（44.3） |
| `质量审查工具` | alignment-review（独立子代理）；无需补建 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 修订后全量 selftest 回归 0 FAIL（**独立子代理**） | fresh 42 脚本逐项 rc | subagent-state/ |
| VC-2 | 模板落地+终验段指针+口径一致：delivery-summary.md 五要素区块齐备；SKILL 终验交付段挂模板指针；grep「delivery-summary」引用面一致；字面锚（Rules 1-39 等）零破坏 | **独立子代理** grep 实测+区块核对 | checkpoint |
| VC-3 | 模板自证：**fresh 子代理**按新模板对本任务（task-v112）产出真实交付总结样例，落 plans/task-v112/delivery-summary-sample.md，五要素完整可读 | 样例 Read 核对 | 交付总结样例 |
| VC-4 | 对齐审查通过（独立子代理） | checkpoint | subagent-state/ |
| VC-5 | worktree 合并回+对账结论+porcelain 干净 | 合并输出+porcelain | progress.md |
| VC-6 | memory feedback 条目（裁决原话+五要素规范+失效条件）+变更记录三要素 | memory Read | memory+verification |

> **验证独立性铁律（延续 P0）**：全部验证由全新独立子代理执行；Phase 3 样例总结即本任务交付总结的模板化首证。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板面（worktree） | 新增 `templates/delivery-summary.md` | 其他模板修改 |
| 规范面（worktree） | `SKILL.md` 终验交付段指针行+References 表行 | 其他段落 |
| 断言面（worktree） | selftest 新增断言（模板存在性+SKILL 指针，最小增量） | 既有断言改动 |
| memory 面（非仓库） | 新增 feedback 条目+MEMORY.md 索引行 | 其他记忆 |
| 计划系统文件 | `plans/task-v112/*` | 其他 plan 目录 |
| 明确排除 | 宪法（用户级）；check-complete.sh 逻辑改动（如需挂终验提示列 Phase 1 评估，默认不动脚本） | 未授权扩围 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 用户裁决 | 交付总结五要素原话（说明/产出/带审查/风险点列举/下一步建议，尽量详细确保用户充分了解） | 本计划 Goal+Phase 1 存档 | 必读 | ☑ |
| 项目内部文档 | 终验交付段现状（SKILL.md「终验交付」段流程）+verification.md 模板结构 | skills/task-planner/SKILL.md+templates/verification.md | 必读 | ☑ |
| 项目内部文档 | 既有交付实践样本（v107-v111 交付消息结构——自由格式无模板约束） | 本会话交付历史 | 参考 | ☑ |
| 级联先例 | 括注追加模式/selftest 断言最小增量（v109-v111 教训） | memory task-v110/v111 | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 任务交付时向用户输出的总结是自由格式——详略取决于执行者当时状态，产出清单/审查细节/风险点/下一步建议可能缺漏，用户难以充分了解产出全貌与后续行动；需要模板化强制五要素，使交付总结结构化、可预期、可执行。

**核心问题判断**:
- [x] 解决后能交付吗？——能：模板入库+终验段消费+自证样例=可交付
- [x] 不解决白费吗？——是：交付是用户感知任务价值的唯一界面，缺漏风险点会导致用户误判后续行动
- [x] 方法清晰可执行？——是：普查→模板+指针→验证（含自证样例）→合并，先例充分

## Current Phase

Phase 1

## Next Step

派 fresh executor 普查交付面现状+模板草案

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面 | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 executor(sonnet-1) fresh | 普查判断型只读 |
| Phase 2 | Agent 子代理 executor(sonnet-1) + worktree | 模板创建+指针级联 |
| Phase 3 | Agent 子代理 executor fresh ×2 | 回归+自证样例与对齐审查 |
| Phase 4 | Agent 子代理 executor(对账) + 主进程（① git+② 簿记+③ memory） | 白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中（串行依赖链）；**/goal 对齐**: 用户未使用

## Phases

### Phase 1: 交付面现状普查+模板草案（fresh 只读）
- [ ] 终验交付段现状（SKILL.md 终验段流程/check-complete 输出结构/verification.md 模板与交付消息的关系）
- [ ] 交付实践样本复盘（v107-v111 交付消息——五要素覆盖度评估：哪些总是有/哪些常缺）
- [ ] 模板草案：delivery-summary.md 完整结构（五要素区块+每区块填写指引+数据来源指针（从 verification.md/progress.md/report 引用而非重写）+详略标准（尽量详细以用户可独立决策为准））
- [x] 级联面清单：SKILL:157 插入行+References:314+template-guide.md:64 口径句+selftest 并入方案+脚本零改动；模板位置裁决=templates/ 根（variant/ 会错入白名单）
- **V-N:** VC-2, VC-6
- **Status:** complete
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 交付面普查+模板草案+级联清单 | 继承 | SKILL 终验段+verification 模板+v107-v111 交付样本 | ≤15min | pending |

### Phase 2: 模板创建与终验段级联（worktree）
- [ ] 新增 templates/delivery-summary.md（五要素区块+填写指引+数据来源指针+详略标准）
- [ ] SKILL.md 终验交付段挂模板指针（「交付总结：按 templates/delivery-summary.md 五要素输出」）+References 表行
- [ ] selftest 最小断言（模板文件存在+SKILL 指针行存在——新增 selftest 或并入既有，Phase 1 定）
- [ ] 逐批 commit，worktree 干净
- **V-N:** VC-2, VC-6
- **Status:** pending
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 模板+指针+断言 | 继承 | Phase 1 草案+级联清单 | ≤15min | pending |

### Phase 3: 独立验证（fresh ×2，含模板自证）
- [ ] 全量 42 selftest 回归（worktree）
- [ ] **模板自证（VC-3）**：fresh 子代理按新模板对 task-v112 本任务产出真实交付总结样例（delivery-summary-sample.md）+ alignment-review 对齐审查
- **V-N:** VC-1, VC-3, VC-4
- **Status:** pending
- **Executor:** executor（sonnet-1）fresh

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 回归 | 继承 | worktree selftest 42 个 | ≤15min | pending |
| S2 | 自证样例+对齐审查 | 继承 | 新模板+本任务三件套/report 类产出 | ≤15min | pending |

### Phase 4: 合并回与终验簿记
- [ ] smart-merge-back+清理+主仓复验
- [ ] 部署对账（fresh）+结论登记
- [ ] memory feedback 条目（五要素+失效条件）+MEMORY.md 索引
- [ ] verification.md+check-complete+INDEX+簿记 commit；**交付报告按新模板输出（首证）**
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（① git+② 簿记+③ memory——白名单）

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v111 notepad+本计划目录，属预期） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v112` |
| `branch` | wt/task-v112 |
| `merge_back` | pending |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底 |
|-------|---------|---|---|---|-----|---------|
| Phase 2 | 模板与 verification.md 职责重叠（用户面 vs 机器面混淆） | 5 | 3 | 3 | 45 | 模板定位=用户面总结（引用机器档案而非重写），Phase 1 划界 |
| Phase 2 | SKILL 终验段行数/锚破坏 | 5 | 3 | 3 | 45 | 纯指针追加；Phase 3 回归兜底 |
| Phase 3 | 自证样例与实际交付脱节 | 4 | 3 | 2 | 24 | 样例基于本任务真实产出 |
| Phase 5 | 合并冲突 | 6 | 2 | 2 | 24 | V5 预案（四轮先例） |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 计划批准后建 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |

## Key Questions

1. 交付总结与 verification.md 的职责边界？（Phase 1 划界：用户面总结 vs 机器面档案）
2. 五要素在既有交付实践中的缺漏分布？（Phase 1 复盘）
3. 模板自证样例能否达到「用户可独立决策」标准？（Phase 3）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| template_type=rule-enhancement | 规范演进；白名单合法值 |
| D 类新任务 task-v112 | 交付总结模板=独立规范变更（Rule 8.1） |
| 模板+SKILL 终验段指针，不新增 Rule 编号 | 交付总结属终验流程承载（非行为纪律）；避免 Rule 编号膨胀（45 后每裁决+1 不可持续）；check-complete 输出提示可选登记 |
| 模板定位=用户面总结，引用机器档案 | verification.md=机器面档案（VC/委派/门控），delivery-summary=用户面五要素（引用不重写），职责划界防重叠 |
| 验证全部独立子代理（延续 P0） | v108-v111 用户明示 |
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
| 1 | | executor | Phase 1 交付面普查+草案 | queued | | | | plans/task-v112/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 模板+指针+断言 | queued | | | | plans/task-v112/subagent-state/2-executor.md | - / 0 / ☐ |
| 3 | | executor | Phase 3 回归 | queued | | | | plans/task-v112/subagent-state/3-executor.md | - / 0 / ☐ |
| 4 | | executor | Phase 3 自证样例+对齐审查 | queued | | | | plans/task-v112/subagent-state/4-executor.md | - / 0 / ☐ |
| 5 | | executor | Phase 4 部署对账 | queued | | | | plans/task-v112/subagent-state/5-executor.md | - / 0 / ☐ |
