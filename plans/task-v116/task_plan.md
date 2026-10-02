# Task Plan: task-v116 v107 R 系列遗留修复（用户「继续」=清偿最后一笔遗留）
<!-- 纯文档/口径修正——L1（跨文件但零逻辑变更） -->

<!-- template_type: bugfix -->
<!-- plan_tier: standard -->

## Goal

执行 v107 审查 R 系列中经后续轮次核实仍遗留的修复项（用户「继续」授权）：R-01 SKILL:64 五文件锚/R-06 cost-guard 17.5 幽灵 STOP 档/R-08 plan-bookkeeper 幽灵行/R-09 根级 scripts 命令/R-10 session-catchup.py 幽灵/R-13 INSTALL 卸载验证命令/R-14 英文死链/R-11 INSTALL+README 数字簇按回流后 29 实测全新刷新。全部纯文档修正零逻辑变更；worktree 实施；fresh 子代理回归与对齐审查。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 文档面） |
| `session_id` | 0ab0afaded5e4ad8a4d685e36cf9419b |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v116` |
| `scope_files` | `skills/task-planner/SKILL.md`（:64）、`skills/plan-cost-guard/{SKILL.md,references/cost-control.md}`、`skills/progress-tracker/SKILL.md`、根目录 `README_zh.md/INSTALL_zh.md`（+CLAUDE.md 树补 knowledge-brief 行=连带） |
| `interaction_mode` | `ask`（D1 已获用户「继续」授权） |
| `对齐审查` | fresh alignment-review 收尾 |
| `自动超时默认项` | 无 2+ 选项询问点（豁免登记） |
| `质量审查工具` | alignment-review（fresh） |

## ✅ Verification Contract

| # | 判定标准 | 验证 |
|---|----------|------|
| VC-1 | R 项逐条修复且全库 grep 旧表述零残留（5 个文件/>15 次强制 STOP/plan-bookkeeper/bash scripts/install.sh/session-catchup.py/根 INSTALL.md 链接） | grep 实测 |
| VC-2 | INSTALL/README 数字簇与实测一致（29 variant/40 键/脚本数/6 文件——以当次实测为准逐项核） | 对照表 |
| VC-3 | 全量 42 selftest 0 FAIL（fresh，合并后主仓场） | 42 rc |
| VC-4 | 对齐审查通过（fresh） | checkpoint |
| VC-5 | 合并回+三宿主部署（根目录文档不入部署位,skills 面同步）+porcelain 干净 | diff |
| VC-6 | memory 更新（v107 R 系列清账）+变更记录 | memory |

## ⚠️ 执行范围限制

上表 scope_files 全集；禁改其他文件；INSTALL/README 数字只按实测更新不扩写。

## 📚 必要知识储备

v107 report §3.5/§4（R 项定义）+ 实测基线（29 variant/40 config 键/42 selftest/6 计划文件）——已核实。

## ⚠️ 核心问题定义

v107 审查证实的文档面缺陷（P1×7）经 v108-v115 部分消解后仍余 8 项——纯文档修正即可收敛，修复后 v107 遗留全部清零。
- [x] 能交付 [x] 必要 [x] 方法清晰

## Current Phase

Phase 1

## Next Step

主进程批量修复（纯文档 L1 精简）→ worktree 提交

## 🧰 工具选择与编排（Rule 40）

| Phase | 工具面 | 理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程直做（25.3 ⑥ 纯文档 ≤20 行级联×多文件——按 38.7 本应 L0，因跨 8 文件取 L1 但流程精简） | 纯文档修正零逻辑 |
| Phase 2 | executor fresh（回归）+ 主进程（部署+簿记） | 机械面 |

**workflow 编排判定**: 未命中；**/goal**: 未使用

## Phases

### Phase 1: R 项批量修复（主进程纯文档直做+worktree）
- [ ] R-01 SKILL:64「5 个文件」→6+knowledge-brief；R-06 cost-guard:21 删幽灵 STOP 档（cost-control:33 对齐核查）；R-08 plan-bookkeeper 行→实存承接方（task-planner 簿记职能）；R-09 README 根级 scripts→skills/task-planner 实位；R-10 session-catchup.py→.ts（README×5+INSTALL:61）；R-13 INSTALL 卸载/验证命令实位化；R-14 英文死链→skills/task-planner/ 实位；R-11 数字簇按实测刷新（29 variant/40 键/6 文件/81 项脚本——逐项 ls 实测后改）
- [ ] worktree commit
- **V-N:** VC-1, VC-2
- **Status:** in_progress
- **Executor:** 主进程（⑥ 纯文档修正扩展口径——零逻辑变更，逐项 ls 实测驱动）

### Phase 2: 回归+合并+部署+对齐审查+簿记
- [ ] fresh 42 selftest（合并后主仓）→ 对齐审查（fresh）→ 部署 skills 面 → INDEX+commit+memory 清账
- **V-N:** VC-3, VC-4, VC-5, VC-6
- **Status:** pending
- **Executor:** executor fresh（回归/审查）+ 主进程（① 部署+② 簿记）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①：v115 簿记+本计划目录） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v116` |
| `branch` | wt/task-v116 |
| `merge_back` | pending |

## 📊 FMEA 预演

| 失败模式 | RPN | 兜底 |
|---------|-----|------|
| INSTALL 数字改错（实测驱动可防） | 32 | 每个数字 ls 实测后落笔 |
| 级联漏网 | 48 | Phase 2 grep 复验+回归 |

## 🔁 原生 Todo 同步

| Phase | 已建 |
|-------|------|
| Phase 1 | ☐ |
| Phase 2 | ☐ |

## Key Questions

1. 各数字锚实测值？（修复时逐项 ls）
2. 根目录文档不入部署位——部署面=skills/（cost-guard/progress-tracker/SKILL）✓

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D 类新任务 task-v116 | v115 已终态；「继续」=清偿 v107 遗留（Rule 8.1） |
| 主进程直做修复（⑥） | 纯文档零逻辑变更+逐项实测驱动；L1 流程精简（38.7 精神） |
| R-02/C-P6 不列入 | 核实已自然消解（Rule 16 枚举已全量/billing 已 .ts） |
| 思路复述已呈示 | 2026-10-02 |
| silent: 自动裁决 D1（44.3：用户「继续」即当前指令授权） | — |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|-----------|
|       | 1       |            | → progress.md Error Log |

## 🚨 Drift Log

| 时间 | 结果 | VC | 结论 |
|------|------|----|------|
|      |      |    |      |

## 📊 委派统计（终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 2 |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 |  |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|----------------|------|
| 1 | | executor | Phase 2 回归 | queued | | | | plans/task-v116/subagent-state/1-executor.md | - / 0 / ☐ |
| 2 | | executor | Phase 2 对齐审查 | queued | | | | plans/task-v116/subagent-state/2-executor.md | - / 0 / ☐ |
