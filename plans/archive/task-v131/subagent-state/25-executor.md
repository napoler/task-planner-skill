# 25-executor 检查点 — task-v131/Phase 7 S-unit2: 回归清账 根因 B 批（2 文件）

<!-- 执行位置: /home/terry/task-planner-skill-worktrees/task-v131; 执行方式: Edit 局部增量（禁全量替换）; 跑批时间: 2026-10-05 -->

## 1. 根因 B 定位（23-executor §2.2/§2.4 证据）

- 根因 B = P6 L-1 check-dispatch.sh:411-419 新增 51.1a 需求锚 advisory（`grep -qF '需求锚' "$pf"` 未命中 → stderr 一行提醒, fail-open 不阻断, 不进 hits/计数管线）
- 受害夹具: selftest-dispatch.sh FG-01（`fgc_prompt` 无需求锚字段, 断言零细粒度输出含 stderr 空）+ selftest-fine-grain-steps.sh SG-04（`P04` 无需求锚字段, 断言 enforce 档 exit 0 且 stderr 为空）
- 语义判定: 两用例本意均为**零 advisory 输出**的合规静默断言（非测 advisory 行为本身）→ 按任务书指定修法：夹具补「需求锚: 不适用（纯机械单元）」使 advisory 静默，原断言不变

## 2. 修改明细（2 文件, 纯增量 +12 行, 未动其他文件）

### 2.1 skills/task-planner/scripts/selftest-dispatch.sh（+5 行, fgc_prompt 内）
- `fgc_prompt` 生成的 prompt 在「- progress:」与「status:」之间插入一行：`需求锚: 不适用（纯机械单元）`
- 修改处注释: [2026-10-05 task-v131 回归清账] Why（P6 L-1 advisory 新契约 + 纯机械单元口径）+ 原行为（无需求锚字段 → advisory 打 stderr → FG-01 FAIL）
- 位置: selftest-dispatch.sh:244-258（fgc_prompt 函数体）
- 影响面: fgc_prompt 被 FG-01..05 共用（p1..p5）；FG-02..05 断言为 stderr 子串 grep（'prompt 长度'/'S-unit ID'/'knowledge-brief'/'SKIPPED 打包检测'），新增 advisory 静默后无副作用（重跑全 PASS 实证）

### 2.2 skills/task-planner/scripts/selftest-fine-grain-steps.sh（+7 行, SG-04 段）
- SG-04 运行前 `printf '需求锚: 不适用（纯机械单元）\n' >> "$P04"` 追加到 P04（SG-04 专属, 不污染 P13/任务书路径）
- 修改处注释: [2026-10-05 task-v131 回归清账] Why + 原行为 + 说明 SG-03/05/06/07 的 grep -q 子串断言不受 advisory 行影响
- 位置: selftest-fine-grain-steps.sh:82-91（SG-04 段）

## 3. 验证证据（worktree 内重跑, 原始输出）

| 脚本 | exit | Total 行原文 | 目标用例 |
|------|------|--------------|---------|
| selftest-dispatch.sh | 0 | `Total: 31 PASS=31 FAIL=0` | `FG-01 PASS (rc=0, 零细粒度输出, 基线一致)` |
| selftest-fine-grain-steps.sh | 0 | `Total: 11 PASS=11 FAIL=0` | `SG-04 PASS enforce 4 步 → exit 0 静默` |
| selftest-delegation.sh（消费方复验） | 0 | `Total: 38    PASS=38  FAIL=0` | — |

- 本批 diff 范围: `git diff --stat` 仅 2 目标文件 +5/+7（工作树另有 S-unit1 等其他批的 5 个 M 文件非本批产出, 未触碰）
- 未 commit（按任务书要求）; 日志: /tmp/v131-s25-{dispatch,fgs,delegation}.log

## 4. 负结果报告

- 未发现: 无 advisory 行为回归（FG-01 重跑 stderr 确为空, advisory 被夹具声明正确静默）
- 排除: selftest-delegation.sh 零破坏（38/38 PASS, 该脚本消费 check-delegation 而非 check-dispatch, 但按任务书要求顺带复验）
- 未改动: check-dispatch.sh 产品行为零改动（advisory 逻辑保持 L-1 原样）
