# 04-executor checkpoint — task-v148 S2 接线

## 状态: 全部完成

## 已完成

### 1. ledger-append.sh 修改
- :28 VALID_EVENTS 值尾追加 ` drift_check`（既有 7 项零改动）
- :24 docblock 追加 drift_check 事件枚举注释行（文案=rule64-draft.md §2.1）
- :27 追加 drift_check 第 8 项注释行

### 2. check-3file-gate.sh 修改
- docblock 判定逻辑清单追加第 6 条描述行（Rule 64.2 drift 痕迹门控）
- 追加三个函数：drift_check_activity() / drift_checkpoint_activity() / drift_exempt_check()
- 条件 5 之后追加条件 6 段（Rule 64.2 drift 痕迹门控）
  - 判定序：ledger drift_check 行 → subagent-state mtime → drift_exempt 豁免 → env 降档
  - env 三态：off=跳过 / warn=stderr 不阻断 / 默认 exit 1
  - 锚点复用既有 Started 时间戳解析，无锚点退化 stale 阈值

## 自验结果（全部通过）

### 自验 1: ledger-append drift_check 写入测试
- 命令: `bash skills/task-planner/scripts/ledger-append.sh /tmp/ledger-test-Ftozk9 drift_check "ALIGNED 测试" --phase 1`
- 输出: `[ledger] tick 1 -> /tmp/ledger-test-Ftozk9/ledger-main.jsonl (event=drift_check agent=main)`
- grep 验证: `{"tick":1,"ts":"2026-10-08T04:17:44Z","agent":"main","phase":"1","event":"drift_check","summary":"ALIGNED 测试","files":[]}`

### 自验 2: gate 行为级两态测试
- 2a 无 drift 痕迹: exit=1, stderr=`[drift-gate] Rule 64.2: 本 Phase 窗口内无 drift_check 痕迹——派发 drift-checker（Rule 61 载体）并按 64.1 留痕三件套，或在 task_plan.md 登记 drift_exempt`
- 2b TASK_PLANNER_DRIFT_ENFORCE=warn: exit=0, stderr 含 Rule 64.2 提示 + stdout PASS
- 2c drift_exempt: 1: exit=0, stdout=`[3file-gate] drift_exempt 豁免放行（Phase 1 已登记豁免）`

### 自验 3: 既有行为无回归 + 正向测试
- 回归 1 不存在路径: `[3file-gate] invalid plan path: /tmp/nonexistent-path-xyz` exit=1（与基线一致）
- 回归 2 空目录无文件: `[3file-gate] FAIL (Rule 19.2) — missing .../task_plan.md` exit=1（与基线一致）
- 正向 1 ledger drift_check 痕迹: exit=0, stdout=`[3file-gate] PASS — ...（ledger 语义信号）`
- 正向 2 subagent-state mtime 兜底: exit=0, stdout=`[3file-gate] PASS — ...（mtime 判定:锚点 ...）`
- 正向 3 TASK_PLANNER_DRIFT_ENFORCE=off: exit=0, stdout=`[3file-gate] TASK_PLANNER_DRIFT_ENFORCE=off — 跳过 Rule 64.2 drift 痕迹门控`

### 自验 4: /tmp 清理
- 本任务临时物（ledger-test-* / gate-test-* / gate-pos-*）已全部清理

## 产出文件
- /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce/skills/task-planner/scripts/ledger-append.sh（+3 行）
- /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce/skills/task-planner/scripts/check-3file-gate.sh（+55 行）
