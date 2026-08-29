#!/usr/bin/env bash
# [2026-08-28] check-conflicts.sh — task-planner 任务启动前冲突分析（工作树隔离决策输入）
#
# 职责:扫描当前仓库是否存在"正在工作的内容"与当前任务潜在冲突,输出信号清单:
#   ① 未提交变更(与任务范围重叠会互相踩踏)
#   ② 额外 worktree(可能并行工作)
#   ③ 遗留 wt/* 隔离分支(未合并的隔离工作)
#   ④ plans/INDEX.md 待处理区在册任务(并行会话可能同时推进)
#   ⑤ 运行中基础设施文件(hooks/skills/config/agents)有未提交改动——改动即影响所有会话
#
# 用法: check-conflicts.sh [repo_path]     (默认 PWD)
# 退出码: 0 = 无冲突风险; 1 = 存在风险(信号已列出)
# 注意: 工作树隔离是 task-planner 的**默认首选**(防改坏运行中功能),本脚本结果
#       只是附加依据——干净仓库也建议隔离,详见 references/worktree-isolation.md。

set -u
repo="${1:-$PWD}"
cd "$repo" 2>/dev/null || { echo "[conflict-scan] 无法进入 $repo,跳过"; exit 0; }

command -v git >/dev/null 2>&1 || { echo "[conflict-scan] 无 git,跳过"; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "[conflict-scan] 非 git 仓库,跳过"; exit 0; }

risk=0
echo "[conflict-scan] repo=$repo"

# ①⑤ 未提交变更(⑤ 为其中基础设施文件的子集高亮)
porcelain="$(git status --porcelain 2>/dev/null)"
dirty="$(printf '%s' "$porcelain" | grep -c . || true)"
if [ "$dirty" -gt 0 ]; then
  risk=1
  echo "[conflict-scan] ⚠ 信号①: 未提交变更 ${dirty} 个文件(与任务范围重叠时互相踩踏):"
  printf '%s\n' "$porcelain" | head -8 | sed 's/^/    /'
  [ "$dirty" -gt 8 ] && echo "    ...(共 ${dirty})"
  live="$(printf '%s\n' "$porcelain" | grep -cE '(hooks/|skills/|config\.json|AGENTS\.md|agents/)' || true)"
  if [ "$live" -gt 0 ]; then
    echo "[conflict-scan] ⚠ 信号⑤: 其中 ${live} 个是运行中基础设施(hooks/skills/config/agents)——直接改动即影响所有会话,强烈建议工作树隔离"
  fi
fi

# ② 额外 worktree(porcelain 列表含主仓,故减 1)
wt="$(git worktree list --porcelain 2>/dev/null | grep -c '^worktree ' || true)"
wt_extra=$(( wt - 1 ))
if [ "$wt_extra" -gt 0 ]; then
  risk=1
  echo "[conflict-scan] ⚠ 信号②: 存在 ${wt_extra} 个额外 worktree(可能有并行工作):"
  git worktree list 2>/dev/null | tail -n +2 | sed 's/^/    /'
fi

# ③ 遗留隔离分支
lb="$(git branch --list 'wt/*' 2>/dev/null | grep -c . || true)"
if [ "$lb" -gt 0 ]; then
  risk=1
  echo "[conflict-scan] ⚠ 信号③: 遗留 wt/* 分支 ${lb} 个(可能含未合并的隔离工作):"
  git branch --list 'wt/*' 2>/dev/null | sed 's/^/    /'
fi

# ④ 在册未完成任务
if [ -f plans/INDEX.md ]; then
  act="$(sed -n '/^## 待处理/,/^## 已完成/p' plans/INDEX.md | grep -c '^- \*\*' || true)"
  if [ "$act" -gt 0 ]; then
    risk=1
    echo "[conflict-scan] ⚠ 信号④: ${act} 个未完成任务在册(plans/INDEX.md)——并行会话可能同时推进"
  fi
fi

if [ "$risk" -eq 0 ]; then
  echo "[conflict-scan] ✓ 未发现冲突信号;实现类任务仍默认首选工作树隔离(用户可否决)"
fi
exit $risk
