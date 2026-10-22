# Task Plan: S77 P1 问题修复（77.1 标注 + 77.4 智能思路 + 77.6 混合拆分 + 77.2 机械锚点）

template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文
- **R1**: 「修正」（修复 skill-audit-s77-20261019 审查发现的 P1 问题）<sub>（[目标]）</sub>

### R→VC 映射
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1~VC-4 | 全部 P1 问题已修复，grep 验证无残留 |

## Goal
在 worktree wt/s77-fix 内修复 26 技能 S77 审查发现的 4 类 P1 问题：① 77.1 步骤属性标注（19 技能加 [M]/[A]/[M+A] 标记）② 77.4 智能思路（15 技能补 ≥2 思路+选择条件）③ 77.6 混合拆分（18 技能拆分混合步骤）④ 77.2 机械锚点（3 review 技能补 SOP 段）；全部修复后 VC 复验 + 合并回 master。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | 19 needs-review 技能全部含 [M]/[A]/[M+A] 步骤标注 | grep `[M]|\[A\]|\[M+A\]` 每技能 ≥1 命中 | 19/19 PASS |
| VC-2 | 15 技能智能步骤含 ≥2 思路+选择条件 | 人工检查 | 15/15 PASS |
| VC-3 | 18 技能混合步骤已拆分 | 人工检查 | 18/18 PASS |
| VC-4 | 3 技能机械锚点补全（SOP 段） | 文件在位 | 3/3 PASS |

## 隔离决策
| 字段 | 值 |
|------|-----|
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/s77-fix |
| `branch` | wt/s77-fix |
| `merge_back` | 待修复完成后 `git merge --no-ff wt/s77-fix` |

## Phases

### Phase 1: 77.1 步骤属性标注（19 技能）
- [x] 核心 8 技能加 [M]/[A]/[M+A] 标记（48 处）
- [x] review-library 11 技能加 [M]/[A]/[M+A] 标记（143 处）
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）×2 并行

### Phase 2: 77.4 智能思路（15 技能）
- [x] 核心 4 技能（iterative-optimizer 2 处 / todo-skill 1 处 / error-fix-prompt-forge 1 处 / verification-gate 1 处）
- [x] review-library 10 技能 16 处（code-quality-review / data-quality-review 无独立 [A]，空集满足）
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）×2 并行

### Phase 3: 77.6 混合拆分（18 技能）
- [x] 核心 4 技能 8 处 [M+A] 拆分（task-planner 4 / iterative-optimizer 1 / todo-skill 1 / verification-gate 2）
- [x] review-library 11 技能 68 处 [M+A] 拆分
- [x] 所有 [A] 子动作补充「可选思路」段
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）×2 并行

### Phase 4: 77.2 机械锚点（3 技能）
- [x] image-review 补「机械 SOP」段（6 个 [M] 步骤）
- [x] ui-quality-review 补「机械 SOP」段（6 个 [M] 步骤）
- [x] content-quality-review 补「机械 SOP」段（6 个 [M] 步骤）
- **Status:** complete
- **Executor:** agent-quality-auditor（sonnet-1）

### Phase 5: Verify + Merge Back
- [x] VC-1~VC-4 复验（VC-1: 19/19 ✅ / VC-2: 96 处 ✅ / VC-3: 0 残留 ✅ / VC-4: 3/3 ✅）
- [x] git commit（69a05b1）+ merge --no-ff（c75384d）
- [x] 清理 worktree（git worktree remove + git branch -d wt/s77-fix）
- **Status:** complete
- **Executor:** 主进程（例外理由：① git 编排——Rule 25.3 白名单）
