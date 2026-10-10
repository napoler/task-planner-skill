# S14 Executor Checkpoint — fix-wave posttooluse（MAJOR-1 + MINOR-3）

**Status:** complete
**Time:** 2026-10-10
**Unit:** S14
**File:** `skills/task-planner/scripts/zcode-posttooluse.sh`（worktree 内，1 文件 2 行级改动）

## 改动清单

### MAJOR-1: _cpn 除零防护
- **位置**: zcode-posttooluse.sh:350
- **原文（改前）**: `_cpn="${TASK_PLANNER_CONTEXT_PRESSURE_N:-1}"; case "$_cpn" in ''|*[!0-9]*) _cpn=1 ;; esac` 后无防护
- **改后**: 在 case 之后新增 `[ "$_cpn" -ge 1 ] 2>/dev/null || _cpn=1   # 除零防护（_cpn=0 纯数字绕过 case）`
- **原因**: `_cpn=0|00` 是纯数字通过 case 校验却为 0；`-eq 1` 为 false 时执行 `% _cpn` → division by 0

### MINOR-3: rhythm_n 钳位移出 _cp 块
- **位置**: zcode-posttooluse.sh:336（从 :349 移至 :336）
- **原文（改前）**: `[ "$rhythm_n" -ge 1 ] 2>/dev/null || rhythm_n=10` 位于 `if [ "${TASK_PLANNER_CONTEXT_PRESSURE:-on}" != "off" ]` 块内
- **改后**: 该行移至 `case "$rhythm_n" in ''|*[!0-9]*) rhythm_n=10 ;; esac` 之后（drift 分支统一处）
- **原因**: 使 rhythm 钳位与新开关 env 解耦，off 时 drift 文案不随新 env 变化

## 验证证据

| 验证项 | 命令 | 结果 |
|--------|------|------|
| 语法检查 | `bash -n zcode-posttooluse.sh` | PASS（无输出） |
| 位置确认 | `grep -n 'rhythm_n.*-ge 1\|_cpn.*-ge 1'` | :336（rhythm_n 钳位，在 _cp 块外）、:350（_cpn 防护，在 _cpn case 后） |
| 正常路径回归 | `bash 7-code-runner-S6-smoke.sh` | PASS（run1 双段 / run2 off 开关正确） |
| MAJOR-1 专项 | `TASK_PLANNER_CONTEXT_PRESSURE_N=0 bash hook` | rc=0, lines=1, json_valid=1, has_drift_rhythm=1, has_context_pressure=1, stderr=[]（无 division-by-0） |

## 改动量
- 文件数: 1
- 行数: +2/-1（净 +1 行）
