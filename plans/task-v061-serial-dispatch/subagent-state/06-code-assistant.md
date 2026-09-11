# checkpoint 06-code-assistant — task-v061-serial-dispatch / Phase 6 / S1

status: done
milestone: 夹具就绪 / 修复完成 / 新增完成（三里程碑全部达成）

## 改动（仅 1 文件，+80/-0 级别插入）
`/mnt/data/dev/task-planner-skill-worktrees/task-v061-serial-dispatch/skills/task-planner/scripts/selftest-dispatch.sh`

1. **互扰修复（T10/T12 裸跑变红）**：
   - 根因（实测复现：基线 T10/T12 FAIL rc=2）：T01(enforce 合规放行) 与 T05(warn 放行) 在 `check-dispatch.sh` 契约通过路径写入新鲜锁
     `<plan-dir>/subagent-state/.dispatch-inflight`（serial_slot_check, check-dispatch.sh:216-246），残留新鲜锁使 T10/T12 的 enforce
     调用撞锁被 exit 2 正确阻断。
   - 修法（最小改动，随现行夹具风格）：在 T05 开始前（:87-90）与 T11 前（即 T10 之后，:122-124）各加一行
     `rm -f "$PLAN/subagent-state/.dispatch-inflight"`，附 `[2026-09-12 task-v061]` 注释说明原因。
   - 修复后 T01-T12 全 PASS（实测 12/12）。

2. **新增 TS-01..06**（:133-207）：
   - 独立夹具：`$TMP/tscl/plans/task-ts`（含 task_plan.md/findings.md/progress.md + subagent-state/），
     合规 prompt 全 7 必检项指向夹具目录；不触真实 plans/，TMP 由既有 trap 清理。
   - 触发方式：`env TASK_PLANNER_PLAN_DIR=$TSCLP TASK_PLANNER_DISPATCH_ENFORCE=<档> bash check-dispatch.sh pretool <prompt> $SID`
     （真实入口；外层档位用 off 避免 env 覆盖扰动，显式 env 强制目标档位）。
   - TS-01 无锁+enforce → rc=0 且锁写入为数字（head -n1 grep ^[0-9]+$ 断言）
   - TS-02 新鲜锁+enforce → rc=2 且 stderr 含「串行」
   - TS-03 新鲜锁+warn → rc=0 且 stderr 含「串行」
   - TS-04 陈旧锁(now-200s)+enforce → rc=0 且锁刷新为 >now-120s 的新值
   - TS-05 新鲜锁+off → rc=0 且锁内容未改写（写哨兵值 1234567890 断言不变）+ stdout 为空（静默）
   - TS-06 清锁路径：rm 锁后 enforce 调用 rc=0，再 rm 模拟 PostToolUse 清锁，断言文件消失
   - 计数并入既有 PASS/FAIL 计数器，Total 行格式不变 → `Total: 18 PASS=18 FAIL=0`

## 验证证据
- `bash -n` 通过（SYNTAX OK）
- 裸跑两遍均 `Total: 18 PASS=18 FAIL=0` EXIT=0（无夹具残留依赖，两遍结果一致）
- `git -C worktree diff --stat` → 仅 selftest-dispatch.sh 1 文件（+80 行级插入，0 删除）
- 未触碰：check-dispatch.sh / zcode-posttooluse.sh / 真实 plans/ / 其他任何文件（scope 外零改动）

## 负结果/排除项
- 确认 T 序列中 T02-T04/T09(enforce 阻断路径) 不写锁（缺项 exit 2 早于 serial_slot_check），无需清锁
- TS 夹具与 PLAN 夹具目录隔离，TS 用例不污染 T 用例；exit 路径中残留锁随 $TMP trap 删除
- jq 依赖：pretool 入口 get_mode 需 jq（测试环境有，T10 用例本已依赖 jq）
