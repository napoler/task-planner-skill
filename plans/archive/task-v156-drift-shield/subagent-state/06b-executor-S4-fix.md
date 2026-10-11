# [sub:06b-executor] S4 修正 — check-complete.sh [judge-gate] 计数行鲁棒化

status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment/skills/task-planner/scripts/check-complete.sh(+2/-1); /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/findings.md(+1 block); /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/progress.md(+1 line)
evidence: 缺陷复现→captured=[0\n0] / `[: 0\n0: integer expression expected` GATE PASSED; 修后 bash -n rc=0, grep -c '[judge'=6; 隔离 diff @@ -1330,7 +1330,8 @@ 仅 _jl 行(1删2增); 单测 zero captured=[0] branch=ZERO / match captured=[2] branch=OK / missing→归零, [ 0 -eq 0 ] rc=0; enforce 零留痕 exit=1 / off SKIPPED exit=0 / warn 零留痕 exit=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/06b-executor-S4-fix.md (status: done)
findings_written: findings.md 锚点 #### [sub:06b-executor] [judge-gate] 计数行鲁棒化修复
blockers: none
confidence: HIGH

## 修改规格（逐字落地）
old(1 行):
        _jl="$(grep -c '\[judge\]\|\[align\]' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null || echo 0)"
new(2 行):
        _jl="$(grep -c '\[judge\]\|\[align\]' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null || true)"
        case "$_jl" in ''|*[!0-9]*) _jl=0 ;; esac

## 根因
grep -c 零匹配时打印 "0" 且 exit 1；命令替换内 `|| echo 0` 触发 → 捕获 "0\n0"；`[ "0\n0" -eq 0 ]` 报 integer expression expected 且判假 → 走 else → warn 永不告警 / enforce 永不 exit 1（违 Rule 51.1a R3 需求锚）。

## Scope 遵守
- 仅改 [judge-gate] 段 2 行；未触其他行/文件；未动主仓 /mnt/data/dev/task-planner-skill/**；无 git 写操作（仅只读 git status/log/diff）
- 冒烟用 /tmp harness 抽取生产 case 块，未改生产逻辑
