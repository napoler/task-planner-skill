#!/usr/bin/env bash
# [2026-08-28] check-conflicts.sh — task-planner 任务启动前冲突分析 + 运行时并发冲突检测
#
# 职责:
#   1. 计划创建时冲突分析(原有):扫描当前仓库是否存在"正在工作的内容"与当前任务潜在冲突
#   2. 运行时并发冲突检测(--runtime 模式,v2.4.0 新增):检测现有 in_progress plan 的 scope 交集
#
# 用法:
#   check-conflicts.sh [repo_path]                  # 计划创建时(原有模式)
#   check-conflicts.sh --runtime [repo_path]        # 运行时检测(新)
#
# 退出码: 0 = 无冲突; 1 = 存在风险(信号已列出)
# 注意: 工作树隔离是 task-planner 的**默认首选**,本脚本结果只是附加依据
#       详见 references/worktree-isolation.md。

set -u
# [2026-09-27 task-v091 S16 C-1c] scope 提取统一库(语义权威源+调用方清单见 lib/plan-parse.sh);
# 在下方 cd "$repo" 之前以脚本自身绝对路径 source, 不受目标仓库切换影响
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/plan-parse.sh
. "$SCRIPT_DIR/lib/plan-parse.sh"
REPO_PATH=""
RUNTIME=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runtime) RUNTIME=true; shift ;;
    *) REPO_PATH="$1"; shift ;;
  esac
done
repo="${REPO_PATH:-$PWD}"
cd "$repo" 2>/dev/null || { echo "[conflict-scan] 无法进入 $repo,跳过"; exit 0; }

command -v git >/dev/null 2>&1 || { echo "[conflict-scan] 无 git,跳过"; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "[conflict-scan] 非 git 仓库,跳过"; exit 0; }
# [2026-09-27 task-v091 C-1f] 探测合并方案(status 单调用兼任探测+信号①采集, runtime 3→2)
# 实测为净负优化已回退: status 作为首个仓库子命令会拖慢其后 plans/* 目录循环的 fork-exec
# 链(主仓配对中位 +44ms, 20/20 同向), 大于省 1 次 rev-parse 的 ~10ms; 探测保持 rev-parse
# 独立形, porcelain 由 init/D 段各自采集(与原行为一致)。证据见 S18 checkpoint。

# [2026-09-27 task-v091 C-1f] worktree 清单单次采集+多消费点共享(原 --porcelain 计数与
# 普通格式列表两次独立调用合并为一); 计数等价性: 两种格式每个 worktree 恰好输出一行,
# 非空行计数与原 '^worktree ' 计数一致; 列表经同一 tail/sed 管道输出与原逐字节一致。
# 惰性采集: --runtime 无活跃 plan 快路径提前 exit 0 不触发, 该路径保持仅 1 次仓库探测调用
CC_WT_LIST=""
cc_wt_loaded=false
cc_worktree_list() {
  if [ "$cc_wt_loaded" = false ]; then
    CC_WT_LIST="$(git worktree list 2>/dev/null)"
    cc_wt_loaded=true
  fi
}

risk=0
echo "[conflict-scan] repo=$repo mode=$([ "$RUNTIME" = true ] && echo "runtime" || echo "init")"

# ─── 原有模式:计划创建时冲突分析 ────────────────────────────────────────────
if [ "$RUNTIME" = false ]; then
  # ①⑤ 未提交变更
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

  # ② 额外 worktree
  # [2026-09-27 task-v091 C-1f] 单次 worktree 采集+计数/列表同变量消费(原两次独立调用:
  # --porcelain 计数 + 普通格式列表); 计数等价=每 worktree 恰一行, 列表管道与原逐字节一致
  cc_worktree_list
  wt="$(printf '%s\n' "$CC_WT_LIST" | grep -c . || true)"
  wt_extra=$(( wt - 1 ))
  if [ "$wt_extra" -gt 0 ]; then
    risk=1
    echo "[conflict-scan] ⚠ 信号②: 存在 ${wt_extra} 个额外 worktree(可能有并行工作):"
    printf '%s\n' "$CC_WT_LIST" | tail -n +2 | sed 's/^/    /'
  fi

  # ③ 遗留隔离分支
  # [2026-09-27 task-v091 C-1f] 计数+列表合并为单次采集同变量消费(原两次独立 branch 调用)
  wt_branches="$(git branch --list 'wt/*' 2>/dev/null)"
  lb="$(printf '%s\n' "$wt_branches" | grep -c . || true)"
  if [ "$lb" -gt 0 ]; then
    risk=1
    echo "[conflict-scan] ⚠ 信号③: 遗留 wt/* 分支 ${lb} 个(可能含未合并的隔离工作):"
    printf '%s\n' "$wt_branches" | sed 's/^/    /'
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
fi

# ─── 运行时模式:并发冲突检测(Rule 23) ──────────────────────────────────────
# 检测维度:
#   A 同文件(scope_files 交集非空)
#   B 同 worktree(共享隔离区)
#   C 同 task-id(同名 plans/)
#   D 环境信号(复用五信号①-⑤)

# 收集所有 in_progress plan 的 scope
declare -A plan_scopes      # plan_dir -> 文件列表(每行一个)
declare -A plan_sessions    # plan_dir -> session_id
declare -A plan_worktrees   # plan_dir -> worktree_path
declare -a active_plans=()  # in_progress plan 目录列表

# [2026-09-27 task-v092/S5] 原管道首段 sed 区间 end 模式 /^|-------/ 被表头紧邻的分隔行
# (首列≥7 连字符)命中 → 区间只输出表头+分隔行 2 行, 数据行永不入管道 → active_plans 恒空
# (根因取证: plans/task-v092-guard-quirk-fixes findings S1)。修法: end 改为首个不以 | 开头
# 的行(整表入管道), 管道中段 grep -vE 滤除分隔行(仅 |/-/:/空格 构成的行)
if [ -f plans/INDEX.md ]; then
  while IFS='|' read -r task_id status phase_total goal mtime _icon; do
    # 只处理 in_progress
    [[ "$status" != "in_progress" ]] && continue
    # [2026-09-27 task-v092/S6] 原 plan_dir="plans/$task_id"(相对) 与下方 current_plan_dir 的
    # glob "$repo/plans"/* (绝对/含 $repo 前缀) 字符串比较恒不等 → 自计划跳过失效,
    # A(scope 自交)/B(worktree 自等) 恒自报(1b, 根因取证见 plans/task-v092 findings S1);
    # 改为与 glob 同源构造, 两侧共享逐字 $repo/plans/ 前缀, repo 传参任意形态恒等
    plan_dir="$repo/plans/$task_id"
    [ -f "$plan_dir/task_plan.md" ] || continue
    active_plans+=("$plan_dir")
    
    # 提取 session_id, worktree_path, scope_files
    session_id="$(awk '/^session_id:/{print $2; exit}' "$plan_dir/task_plan.md" 2>/dev/null || echo "")"
    worktree_path="$(awk '/^worktree_path:/{print $2; exit}' "$plan_dir/task_plan.md" 2>/dev/null || echo "")"
    # scope_files 从「⚠️ 执行范围限制」区块提取
    # [2026-09-27 task-v091 S16 C-1c] 原内联整行清洗(表头/类别/禁止列均产出+逗号拆分, 无点分过滤)
    # 改统一库 plan_parse_scope(点分整格语义, 语义权威源见 lib/plan-parse.sh);
    # 行为差异: 35/37 本仓计划提取结果变化, 两两交集 528 对(表头碰撞假阳性)→5 对(真实共享路径),
    # v090 类无 emoji 表头由提取恒空变可提取——量化见 plans/task-v091 S16 checkpoint
    scope="$(plan_parse_scope "$plan_dir/task_plan.md")"
    
    plan_sessions["$plan_dir"]="$session_id"
    plan_worktrees["$plan_dir"]="$worktree_path"
    plan_scopes["$plan_dir"]="$scope"
  done < <(sed -n '/^| Task ID/,/^[^|]/p' plans/INDEX.md | tail -n +2 | grep '^|' | grep -vE '^[[:space:]:|-]+$' | sed 's/^|//;s/|$//' | awk -F'|' '{gsub(/[[:space:]]*/, "", $1); gsub(/[[:space:]]*/, "", $2); print $1"|"$2"|"$3"|"$4"|"$5"|"$6}')
fi

# 判断当前 plan 的目录
current_plan_dir=""
for candidate in "$repo/plans"/*; do
  [ -f "$candidate/task_plan.md" ] || continue
  mt="$(stat -c %Y "$candidate/task_plan.md" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  [ $((now - mt)) -lt 86400 ] || continue
  current_plan_dir="$candidate"
  break
done

if [ -z "$current_plan_dir" ]; then
  echo "[conflict-scan] 无活跃 plan,跳过运行时检测"
  exit 0
fi

current_session="$(awk '/^session_id:/{print $2; exit}' "$current_plan_dir/task_plan.md" 2>/dev/null || echo "")"
current_worktree="$(awk '/^worktree_path:/{print $2; exit}' "$current_plan_dir/task_plan.md" 2>/dev/null || echo "")"
# [2026-09-27 task-v091 S16 C-1c] 同上方 plan_scopes 处: 原内联整行清洗改统一库(点分整格语义)
current_scope="$(plan_parse_scope "$current_plan_dir/task_plan.md")"

# A 同文件检测
for other_plan in "${active_plans[@]}"; do
  [[ "$other_plan" == "$current_plan_dir" ]] && continue
  other_session="${plan_sessions[$other_plan]}"
  other_worktree="${plan_worktrees[$other_plan]}"
  other_scope="${plan_scopes[$other_plan]}"
  
  # A: 文件交集
  if [ -n "$current_scope" ] && [ -n "$other_scope" ]; then
    overlap="$(comm -12 <(echo "$current_scope" | sort) <(echo "$other_scope" | sort) | head -5)"
    if [ -n "$overlap" ]; then
      risk=1
      echo "[conflict-scan] 🔴 冲突 A(同文件): plan $(basename $other_plan) session=$other_session 覆盖文件:"
      echo "$overlap" | sed 's/^/    /'
    fi
  fi
  
  # B: 同 worktree
  if [ -n "$current_worktree" ] && [ "$current_worktree" != "n/a" ] && [ -n "$other_worktree" ] && [ "$other_worktree" != "n/a" ] && [ "$current_worktree" = "$other_worktree" ]; then
    risk=1
    echo "[conflict-scan] ⚠️ 冲突 B(同 worktree): 两个 plan 共享 worktree $current_worktree"
  fi
  
  # C: 同 task-id
  current_taskid="$(basename "$current_plan_dir")"
  other_taskid="$(basename "$other_plan")"
  if [ "$current_taskid" = "$other_taskid" ] && [ "$current_session" != "$other_session" ]; then
    risk=1
    echo "[conflict-scan] 🔴 冲突 C(同 task-id): 不同 session 使用同一 plan $current_taskid"
  fi
done

# D: 环境信号(复用五信号,仅风险信号)
# [2026-09-27 task-v091 C-1f] ①保持独立采集(探测合并方案实测负优化已回退, 见探测段注释);
# ②改单次 worktree 采集共享(原独立调用, 计数等价=每 worktree 一行)
porcelain="$(git status --porcelain 2>/dev/null)"
dirty="$(printf '%s' "$porcelain" | grep -c . || true)"
[ "$dirty" -gt 0 ] && risk=1 && echo "[conflict-scan] ⚠ 信号①: 未提交变更 ${dirty} 个文件"
cc_worktree_list
wt="$(printf '%s\n' "$CC_WT_LIST" | grep -c . || true)"
wt_extra=$(( wt - 1 ))
[ "$wt_extra" -gt 0 ] && risk=1 && echo "[conflict-scan] ⚠ 信号②: 存在 ${wt_extra} 个额外 worktree"

if [ "$risk" -eq 0 ]; then
  echo "[conflict-scan] ✓ 运行时并发冲突检测通过"
fi
exit $risk
