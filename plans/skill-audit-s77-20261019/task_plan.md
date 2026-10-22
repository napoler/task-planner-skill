# Task Plan: S77 机械/智能流程分治审查（skill-fix Standard 77）

template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1）

- **R1**: 「使用新版的Skill Fix这个技能来优化当前的执行，当前的项目中的技能」<sub>（[目标]）</sub>
- **R2**: 「我希望使用Task Planner中的工作流模式来推进当前任务」<sub>（[手段]）</sub>
- **R3**: 「因为当前的Skill Fix这个技能引入了就是区分机械与智能化的部分，我希望可以审查一下当前已有的项目」<sub>（[目标]）</sub>

### R→VC 映射
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1, VC-2 | 每个含 ≥2 步骤的 skill 已产出 S77 步骤分治表 |
| R2 | VC-4 | 审查通过 Task Planner 四文件罗盘 + Phase 执行循环推进 |
| R3 | VC-1, VC-3 | S77 分治表覆盖全部 28 技能（17 核心 + 11 review-library），报告落盘 |

## Goal

对 task-planner-skill 仓 skills/ 下全部 28 个技能（17 核心 + 11 review-library），按 skill-fix Standard 77（机械/智能流程分治）逐项审查：① 识别每个含 ≥2 步骤 skill 的机械/智能/混合属性 ② 产出步骤分治表 ③ 检查 77.1-77.6 六项审计 ④ 汇总发现并落盘诊断报告。纯只读审查，不修改任何技能文件；修复动作由用户裁决后另开任务。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 全部含 ≥2 步骤的 skill（预计 ≥10 个）已产出 S77 步骤分治表 | 检查 plans/skill-audit-s77-20261019/findings.md 含每个 skill 的分治表 | `grep -c "步骤分治表" findings.md` ≥ 10 |
| VC-2 | 每个分治表含 77.1-77.6 六项检查结果（M/A 标注 + SOP 锚点 + 机械校验 + 智能思路 + 反模式 + 混合拆分） | 逐表检查 | 每个分治表段含 6 项 |
| VC-3 | 诊断报告落盘 plans/skill-audit-s77-20261019/s77-audit-report.md，含全部 28 技能判定（✅/⚠️/❌/豁免） | 文件在位 + 28 行判定 | `wc -l s77-audit-report.md` ≥ 28 判定行 |
| VC-4 | 审查通过 Task Planner 四文件罗盘推进（task_plan/findings/progress/verification 四文件齐备 + Phase 状态翻转） | 检查四文件在位 | `ls plans/skill-audit-s77-20261019/{task_plan,findings,progress,verification}.md` 全存在 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 失败重试 3 次 → BLOCKED。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 审查（只读） | skills/*/SKILL.md + skills/*/references/*.md（全部 28 技能） | 其他目录 |
| 产出（写入） | plans/skill-audit-s77-20261019/** | 任何 skills/ 下的文件 |
| 修复 | 本任务**不做修复**——修复由用户裁决后另开任务（需 worktree §十一） | 修改任何 SKILL.md |

## 📋 变更标注表（Rule 74.3）

| 编号 | 对象 | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------|------|---------|------|---------|
| CA-1 | plans/skill-audit-s77-20261019/** | 新增 | 增量 | R3 用户要求审查 | 创建审查产出 |

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（git status 干净，仅新增 plans/ 产物） |
| `isolation` | direct（纯只读审查 + plans/ 产出，命中 §十一 11.5 第 3 条例外「纯调研/只读」） |
| `worktree_path` | n/a |
| `branch` | n/a |

## Phases

### Phase 1: Inventory & Categorize
- [x] 盘点全部 26 技能（15 核心 + 11 review-library）：行数 / 步骤数（Phase/Step/≥2 条件）/ 是否含 Agent() / 是否单步豁免
- [x] 按 S77 豁免规则分类：需审查（≥2 步骤）/ 豁免（单步/纯查询）
- [x] 登记到 findings.md §1
- **V-N:** VC-1, VC-4
- **Status:** complete
- **Executor:** explore（haiku）

### Phase 2: S77 分治审查（核心 8 技能）
- [x] 逐个 Read 核心 skill 的 SKILL.md + references/，识别每个 Phase/Step
- [x] 对每个含 ≥2 步骤的 skill 产出步骤分治表（77.1-77.6）
- [x] 机械步骤检查 SOP 锚点 + 可机械校验；智能步骤检查 ≥2 思路 + 选择条件
- [x] 汇总到 findings.md §2
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）
（S-unit 派发单元表见下方）

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|------|------|------|---------|---------|------|
| S1 | 核心 8 技能（task-planner/task-dispatch/task-discipline/verification-gate/plan-resume/progress-tracker/todo-skill/iterative-optimizer）S77 分治表 | 继承 | skills/{8 技能}/SKILL.md + references/ | findings.md §2.1-2.8 含 8 分治表 | 40min | 8f/500l/40min | skill-fix S77 | Phase 1 | pending |
| S2 | 核心 9 技能（task-drift-guard/error-fix-prompt-forge/media-planner/plan-research-router/plan-collab-router/plan-cost-guard/plan-template-kit + review-library 4）S77 分治表 | 继承 | skills/{9 技能}/SKILL.md | findings.md §2.9-2.17 + §3.1-3.4 | 35min | 13f/400l/35min | skill-fix S77 | Phase 1 | pending |

### Phase 3: S77 分治审查（review-library 11 技能 + 汇总）
- [x] 剩余 11 个 review-library 技能 S77 分治表
- [x] 全部 26 技能判定汇总（19 needs-review + 7 exempt）
- [x] 写 s77-audit-report.md（含全部判定 + P0/P1/P2 发现 + 修复建议）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）

### Phase 4: Delivery
- [x] 四文件齐备检查（task_plan/findings/progress/verification）
- [x] 交付总结五要素
- [x] 下一步建议（修复任务规划）
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由：② 簿记 + ① 交付——Rule 25.3 白名单）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 纯只读审查，不修改技能文件 | 用户要求「审查」非「修复」；修复需 worktree（§十一），另开任务 |
| 审查范围 = 28 技能（17 核心 + 11 review-library） | 用户说「当前的项目中的技能」「当前已有的项目」= 全量 |
| 用 Task Planner 四文件罗盘推进 | 用户 R2 明确要求 |
| 跳过 S77 豁免类（单步/纯查询） | S77 §7 豁免规则：仅报告不强制 |

## 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读 | 已确认 |
|------|-----------|------|------|--------|
| 规范/标准 | Skill Fix Standard 77 全文 | ~/.zcode/skills/skill-fix/references/mechanical-adaptive-split.md | 必读 | ☑ |
| 规范/标准 | Skill Fix 审计检查项 77.1-77.6 | 同上 §4 | 必读 | ☑ |
| 项目内部文档 | 28 技能 SKILL.md + references/ | skills/*/ | 必读 | ☑ |

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象 | 取证方式 | 状态 |
|--------|---------|---------|------|
| ① 自身样本 | 28 技能 SKILL.md 内容 | Read + grep 步骤/Phase 标记 | ☐ |
| ② 对标样本 | Skill Fix S77 参考规范 | Read mechanical-adaptive-split.md | ☑ |
| ③ 外部约束 | 无（纯文本面审查） | n/a | ☑ |

## Drift Log

| 时间 | 检测结果 | 涉及 VC | 结论 |
|------|---------|--------|------|

## 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4 |
| 主进程直做 Phase 清单 | Phase 1（inventory，≤15min 判读）+ Phase 4（delivery 簿记） |
| 委派率 | 0.5（Phase 2+3 = 2/4 由子代理执行） |

## Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|-------------|-----------|------|
| 1 | 2026-10-19 | explore（haiku） | Phase 1: 26 技能 inventory | done | 19 needs-review + 7 exempt-query | findings.md §1 | §1 | - | verify_done ☑ |
| 2 | 2026-10-19 | agent-quality-auditor | Phase 2: 核心 8 技能 S77 分治表 | done | 8/8 ⚠️ 部分；77.1 全局缺失 | findings.md §2 | §2 | - | verify_done ☑ |
| 3 | 2026-10-19 | agent-quality-auditor | Phase 3: review-library 11 技能 + 汇总 | done | 8⚠️ + 3❌；s77-audit-report.md 已落盘 | findings.md §3 + s77-audit-report.md | §3 | - | verify_done ☑ |

## Current Phase
Phase 4 (complete)

## Next Step
S77 审查已交付。如需修复，另开任务（需 worktree §十一），按 P1→P2 优先级逐批修复。
