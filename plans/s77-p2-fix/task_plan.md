# Task Plan: S77 P2 问题修复（task-planner 智能步骤就地化 + todo-skill WORKFLOW.md 更新）

template_type: general
plan_tier: mini
execution_lane: L0

## 🎯 用户需求原文
- **R1**: 「P2 问题修复：如需修复 P2 问题（task-planner 智能步骤就地化、todo-skill WORKFLOW.md 更新）」<sub>（[手段]）</sub>
- **R2**: 「行为面验证：建议新开会话验证修复后的技能执行正确性（特别是 task-planner 的 [M]/[A] 拆分是否影响执行流程）」<sub>（[目标]）</sub>

### R→VC 映射
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1, VC-2 | 两处 P2 修复落地 + selftest 绿 |
| R2 | VC-3, VC-4 | 行为面验证结论 + 新会话验证清单 |

## Goal
在 worktree wt/s77-p2-fix 内修复 S77 审计的 2 项 P2 问题（P2-3 task-planner 智能步骤就地化 / P2-4 todo-skill WORKFLOW.md 更新），完成行为面验证并合并回 master。

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | P2-3：task-planner SKILL.md 智能步骤含就地触发条件摘要 | grep T1-T5 触发条件摘要段在位 | 1/1 PASS |
| VC-2 | P2-4：todo-skill WORKFLOW.md 与 SKILL.md 6 步工作流一致 | grep "Step 1-6" + 无 "Single-step" 残留 | 1/1 PASS |
| VC-3 | 行为面验证：selftest 全绿 + [M]/[A] 拆分执行流分析完成 | run-selftests.sh + 执行流分析结论 | 92/92 PASS |
| VC-4 | 新会话验证清单已交付（行为面完整验证需新会话） | 清单落盘 plans/s77-p2-fix/ | 1/1 PASS |
| VC-5 | 执行流顺序修复：Phase 循环 [A] 子步文档顺序恢复至逻辑顺序 | grep 子步顺序 1,2,2.5,2.5b,2.5c,2.5d,3,4,4.5,5,6 | 1/1 PASS |

## 隔离决策
| 字段 | 值 |
|------|-----|
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/s77-p2-fix |
| `branch` | wt/s77-p2-fix |
| `merge_back` | merged(42d72b4) |

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------------------|------|---------|------|---------|
| CA-1 | skills/task-planner/SKILL.md:63 [A] 思维方法论解构 | 修改 | 增量 | S77 审计 P2-3 | 补就地触发条件摘要（T1-T5 触发场景） |
| CA-2 | skills/todo-skill/WORKFLOW.md §3/§4 | 修改 | 增量 | S77 审计 P2-4 | 修正 "Single-step" 陈旧表述为 6 步工作流 |

## Phases

### Phase 1: 行为面验证（selftest + 执行流分析）
- [x] master 全量 selftest（92/92 PASS / 0 FAIL）
- [x] [M]/[A] 拆分执行流分析（git 证据：Phase 循环 [A] 子步文档顺序后移）
- [x] 新会话验证清单落盘
- **Status:** complete
- **Executor:** 主进程（例外理由：① 只读验证+分析——Rule 25.3 白名单）

### Phase 2: P2-3 + P2-4 修复（worktree 内）
- [x] P2-3：task-planner SKILL.md 智能步骤就地化
- [x] P2-4：todo-skill WORKFLOW.md 更新
- [x] worktree 内定向 selftest（92/92 PASS / 0 FAIL）
- **Status:** complete
- **Executor:** 主进程（例外理由：② 技能文件文本维护——Rule 25.3 白名单；worktree 隔离已满足 §十一）

### Phase 3: 合并回 + 清理
- [x] git commit（46ac207）+ merge --no-ff（42d72b4）
- [x] 清理 worktree（git worktree remove）+ 分支（git branch -d wt/s77-p2-fix）
- [x] 主仓 Read 复验（P2-3 1 处 / P2-4 Step 1-6 1 处 + Single-step 0 残留）
- **Status:** complete
- **Executor:** 主进程（例外理由：① git 编排——Rule 25.3 白名单）

### Phase 4: 执行流顺序修复（[M]/[A] 拆分缺陷 — 用户裁决最简方案）
- [x] task-planner SKILL.md Phase 执行循环：恢复交错（1→2→2.5→2.5b→2.5c→2.5d→3→4→4.5→5→6）+ 子步内联 [M]/[A] 标签，合并两块标题为单条目
- [x] worktree 内定向 selftest（92/92 PASS）
- [x] 合并回 master（45eda8c）+ 清理 worktree + 部署仓库位→安装位（SKILL.md IDENTICAL）
- **Status:** complete
- **Executor:** 主进程（例外理由：② 技能文件文本维护 + 机械重排——Rule 25.3 白名单；worktree 隔离已满足 §十一）

## ⚠️ 环境遗留（非本任务回归）
- master 全量 selftest 终态 **91/92 PASS / 1 FAIL**，唯一 FAIL=`selftest-rule-reserve-pairing` PR-02：规则号 **93 已 reserved（task-v195-spec-recall, 2026-10-21, 在途）未 land**。
- **归因**：93 是并行会话 task-v195 的未提交本地预留（git status M，HEAD 版无 93）；本任务 worktree 干净 ledger 下 selftest 92/92。
- **处置**：按 §十一 跨会话隔离不动并行预留；待 task-v195 land 93 后自动转绿。
