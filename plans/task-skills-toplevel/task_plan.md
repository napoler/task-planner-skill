<!-- template_type: refactoring -->
# Task Plan: companion/skills 全部转移到仓库顶层 skills/ 统一安装源

## Goal
把 `skills/task-planner/companion/skills/{plan-resume,task-drift-guard}` 转移到仓库顶层 `skills/`，顶层 `skills/`（除 task-planner 本体）成为所有外围 skill 的唯一安装/回同步源，companion/ 仅保留 agents/；同步改写 install-companion.sh / sync-companion.sh 源指向、更新文档，并把 `~/.agents/skills/plan-resume` 软链重指到新路径。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改运行时基础设施脚本） |
| `session_id` | task-skills-toplevel |
| `worktree_path` | /home/terry/task-planner-skill-worktrees/task-skills-toplevel |
| `scope_files` | skills/task-drift-guard/**, skills/plan-resume/**, skills/task-planner/companion/skills/**, skills/task-planner/lib/install-companion.sh, skills/task-planner/scripts/sync-companion.sh, skills/task-planner/install.sh, skills/task-planner/docs/ARCHITECTURE.md, CHANGELOG.md |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 顶层 skills/ = task-planner, task-drift-guard, plan-resume, todo-skill；companion/skills/ 不复存在 | `ls` 两目录 | 命令输出 |
| VC-2 | 顶层 task-drift-guard 为 truth source 版本（含 haiku model 行 + Rule 18.3/18.6 批量漂移判定），与原运行副本逐字节一致 | `cmp` 合并后顶层 ↔ ~/.zcode/skills/task-drift-guard/SKILL.md | 命令输出 |
| VC-3 | 三个改动脚本 `bash -n` 通过；install-companion.sh --dry-run 能从顶层发现 3 个外围 skill；sync-companion.sh --dry-run 回同步目标为顶层 | dry-run 输出 | 命令输出 |
| VC-4 | 全仓不再有"companion/skills"活文档引用（CHANGELOG 历史条目除外） | `grep -rn "companion/skills"` 仅剩 CHANGELOG | grep 输出 |
| VC-5 | ~/.agents/skills/plan-resume 软链指向顶层 skills/plan-resume 且 v0.4 内容可读 | `readlink` + `grep v0.4` | 命令输出 |
| VC-6 | 合并后 master 干净、worktree 已清理、wt 分支已删 | `git worktree list` + `git branch` | 命令输出 |

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 仓内(worktree) | 上表 scope_files；plan-resume 以 v0.4 内容原样迁移（不做 v0.5 合并） | 触碰 v0.3/v0.4 内容合并；改 companion/agents/** |
| home 目录 | ~/.agents/skills/plan-resume 软链重指（仅 ln -sfn） | 触碰 ~/.zcode/skills/task-drift-guard、todo-skill 等真实部署副本 |
| 范围外 | ~/.claude/skills/plan-resume 仍不动 | — |

**前置裁决（已勘察）**: task-drift-guard 两副本分叉——companion 侧含 model:haiku + Rule 18.3/18.6 批量漂移判定，且与运行中部署副本逐字节一致（= truth source）；顶层侧为 2337ce0 重构残留（陈旧）。归一方向 = companion 覆盖顶层，零内容损失。

## Current Phase
Phase 4 — all complete

## Phases
### Phase 1: worktree 创建 + 内容转移
- [x] git worktree add /home/terry/task-planner-skill-worktrees/task-skills-toplevel -b wt/task-skills-toplevel master
- [x] 顶层陈旧 task-drift-guard 移除 → companion 版 git mv 至顶层;plan-resume git mv 至顶层(cmp 运行副本逐字节一致✓)
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排+运行时基础设施路径操作,子代理无法承载本会话软链依赖）

### Phase 2: 脚本改写（安装/回同步源指向顶层）
- [x] install-companion.sh: skills 段源改顶层 skills/ + 仓根校验(REPO_ROOT 二级 dirname)
- [x] sync-companion.sh: 回同步目标同改 + 校验
- [x] install.sh Phase 5.6 注释更新
- [x] dry-run 冒烟(VC-3)✓——首跑暴露 REPO_ROOT 少一级 dirname 已修;中途 pretooluse 哨兵假阳性拦截,经 plan-created.cjs 正规清除(见 progress)
- **Status:** complete
- **Executor:** 主进程（同上）

### Phase 3: 文档 + CHANGELOG + 验证
- [x] ARCHITECTURE §2.5/2.6/2.7 + INSTALL §4.5 + plan-resume README 改写;活引用清零(余 5 处均为迁移说明性文字)
- [x] CHANGELOG [Unreleased] 变更条目;bash -n x3 + 双脚本 dry-run 冒烟通过
- [x] worktree 提交 4728906;smoke 8/22 FAIL 定性为 v0.3 测试 vs v0.4 脚本既有缺口(归 v0.5)
- **Status:** complete
- **Executor:** 主进程

### Phase 4: 合并回 master + 软链重指 + 清理
- [x] 合并前置检查(master 仅未跟踪目录,无重叠)→ merge --no-ff = **1957fec** → 顶层 ls + cmp drift-guard 复验✓
- [x] ln -sfn 重指 ~/.agents/skills/plan-resume → 顶层;VC-5:readlink✓ v0.4×5✓ bash -n✓
- [x] worktree remove + branch -d ✓;VC-1/6 全过
- **Status:** complete
- **Executor:** 主进程

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（master 仅 plans/、.zcode/ 未跟踪目录,无重叠） |
| `isolation` | worktree（命中 §11.1.5:本仓经软链被所有会话实时加载;开发在 wt/,合并才生效） |
| `merge_back` | merged(1957fec),实现提交 4728906(+68/−258,17 files) |

## Notes
- 软链断窗:合并后到重指前 ~/.agents/skills/plan-resume 短暂悬空(指向已迁移的旧路径),Phase 4 内紧邻操作消除;当前会话已加载的 skill 不受影响
- todo-skill 随统一源语义纳入分发范围（用户批准方案原文:"把安装源统一到顶层 skills/（plan-resume/todo-skill 提升上来…）"）
- 回滚:git revert 合并提交 + ln -sfn 指回 companion 路径(该路径在 revert 后恢复)
