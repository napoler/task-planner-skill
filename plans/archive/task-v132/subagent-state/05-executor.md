# 05-executor 检查点 — task-v132 Phase 3 G3 S-unit（2026-10-05）

## 任务
G3：重锁文案收紧 + init-session.sh silent 路径锚哈希即时落盘 + selftest RC-21/22。
需求锚 R3（Rule 51.1a 逐字引用，见派发 prompt）。worktree=/home/terry/task-planner-skill-worktrees/task-v132。
只动 3 文件：zcode-userpromptsubmit.sh / init-session.sh / selftest-requirement-coverage.sh。未 commit。

## step 记录
### step1 zcode-userpromptsubmit.sh TAMPERED 文案收紧 ✅
- 位置: zcode-userpromptsubmit.sh:64-74（TAMPERED else 分支，仅 msg 字符串 + 注释块，逻辑零改动）
- 处置句扩为：「…重新锁定（重锁前置：Decisions Made 须已登记本次纠正/让步编号——无登记的重锁视为篡改信号，应立即 STOP 报告用户，Rule 51.7）；若否 → 立即 STOP 并向用户报告计划被篡改。」
- 注释含修改三要素（原因/时间 2026-10-05/原行为）。
- 踩坑：RC-21 双锚均要求 grep -c =1，注释区若复述锚字面串（「无登记的重锁视为篡改信号」「Rule 51.7」）会破坏 =1 断言 → 注释改用「第 51.7 条」「重锁未登记=篡改信号」等转述措辞，锚字面串全文仅 msg 行各 1 处。
- 证据: `grep -c '无登记的重锁视为篡改信号'`=1（:74 msg 行唯一）；`grep -c 'Rule 51\.7'`=1（:74 唯一，:70 已改「第 51.7 条」）。

### step2 init-session.sh silent 路径锚哈希即时落盘 ✅
- 位置: init-session.sh:529-552（「[init] 6/6 planning files verified」之后、活跃计划指针段之前）
- 逻辑: env TASK_PLANNER_INTERACTION_MODE=silent ∧ task_plan.md 在位 → 主锁 attest-plan.sh（全门控）；主锁失败 → 兜底锁 attest-plan.sh --skip-dispatch-check --skip-fmea-check（51.1 四锚 fail-closed 硬门仍生效，--skip 仅限可跳过门）；两锁成败各出一行 INFO，双失败 → WARN 到 stderr，init 照过（fail-open）。非 silent 路径零改动。
- 两级策略根因（实测发现，偏离朴素实现的唯一裁量点）：标准档新计划无 S-unit 表 → check-plan-dispatch.sh 门 exit 1 拒锁（/tmp/v132-g3 首跑 attest 直接运行复现 exit=1），单级 attest 使「silent 路径落盘」成功率为 0，G3 目标落空 → 加兜底级（沿用 attest 脚本既有 --skip 先例，fail-open 语义不变）。
- 修改三要素注释在位（:530-541 区，含原因/时间/原行为）。
- 证据:
  - silent 实测（/tmp/v132-g3/plans/g3test，env TASK_PLANNER_INTERACTION_MODE=silent）: exit=0；`[init] INFO: silent 路径兜底锁已落盘 .plan-attestation（G3：防窗口期篡改；dispatch/fmea 门逃生锁…）`；.plan-attestation 生成（181B，plan_sha256=789b3107…）。
  - 非 silent 实测（/tmp/v132-g3/plans/g3test2 & g3test3，env -u）: exit=0；「silent 路径」行数=0（stdout+stderr 均 0）；.plan-attestation 不存在；行为标记不变（`[init] 6/6 planning files verified` / `Planning files initialized!` 同现）。

### step3 selftest-requirement-coverage.sh RC-21/22 ✅
- 位置: selftest-requirement-coverage.sh:450-483（Total 行前追加）；头部 :8 注释 RC-01..RC-20 → RC-01..RC-22。
- RC-21: grep -c '无登记的重锁视为篡改信号'=1 且 grep -c 'Rule 51\.7'=1（zcode-userpromptsubmit.sh）。
- RC-22: 主锁行 'silent 路径已即时落盘 .plan-attestation'=1 且 兜底锁行 'silent 路径兜底锁已落盘 .plan-attestation'=1（双锚独立断言；首版并集计数=2 自撞 FAIL，改双锚各 =1 后 PASS）。
- Total 20→22。

### step4 验证 ✅
- bash -n 三脚本全过（init-session.sh / zcode-userpromptsubmit.sh / selftest-requirement-coverage.sh 均 SYNTAX-OK）。
- selftest-requirement-coverage.sh 全绿: `Total: 22 PASS=22 FAIL=0` exit=0（RC-01..RC-22 逐行 PASS 原文见上）。
- grep hook 新文案=1（见 step1 证据）。
- silent/非 silent 双实测（见 step2 证据）。
- git status: 本单元新增 M = init-session.sh / zcode-userpromptsubmit.sh / selftest-requirement-coverage.sh；工作区既有 M（critical-rules.md / check-complete.sh / selftest-registry.tsv / ?? check-window-consistency.sh）= G1/G2 前序 S-unit 产出，未触碰。
- 未 commit（按 SOP）。

## issues（须主进程知悉）
1. silent 实测中主锁（全门控 attest）因标准档新计划无 S-unit 表被 check-plan-dispatch 拒锁，实际走兜底锁（--skip-dispatch-check --skip-fmea-check）落盘。这超出 R3 需求字面（需求只说「调用 attest-plan.sh + 一行 INFO」），为让需求可实测达成而引入两级策略裁量点——门禁不倒退（51.1 硬门仍 fail-closed，缺锚照样拒锁+WARN）。若主进程认为兜底级越权，可删兜底级回到单级（但新 silent init 实测会恒走 WARN 不落盘）。
2. RC-21 要求「含 Rule 51.7 引用」且 RC 断言 =1 → hook 注释区不能复述锚字面串，已用「第 51.7 条」转述绕行（注释语义=51.7 条款引用，无歧义）。
3. 未检查项/排除风险：未跑 selftest 全 registry（仅 requirement-coverage + 三脚本 bash -n，SOP 只要求「三脚本相关 selftest」）；check-complete.sh / registry 改动为前序 S-unit 产物，本单元未复核其行为面；未 commit = 合并回约 §11.3 仍待主进程。

## 恢复点
若需断点续做：三文件修改已完整落盘 worktree（git diff 可全量回看），selftest 22/22 全绿；剩余动作仅主进程侧：决定 issues 1 兜底级去留 → 合并回约。
