# 6-executor 检查点 — 守卫④任务书口径：行首 markdown 编号入步骤枚举计数

- 状态: done
- 时间: 2026-10-03
- 文件: /home/terry/task-planner-skill-worktrees/task-v118/skills/task-planner/scripts/check-dispatch.sh（单文件改动，47 insertions / 9 deletions）

## 改动明细
1. `count_step_markers` 增加第二参 `taskbook`（L264 区段）：
   - `local f="$1" taskbook="${2:-}"`（单参调用行为零变化，自由 prompt 口径不变）
   - 任务书模式下追加行首 markdown 编号项入去重集合：
     `[ -n "$taskbook" ] && grep -E '^[[:space:]]*[0-9]+[.、)）]' "$f" 2>/dev/null | sed -E 's/^[[:space:]]+//; s/[^0-9].*//'`
   - 只提取行首序号位数字，避免正文数字（如 "1. 改 step 3"）拖入
   - 函数口径注释同步：注明「任务书模式例外（第二参 taskbook, Rule 46.2 收窄）」+ task-v116 实证 + 原行为（两模式统一排除）
2. 守卫④任务书分支（L365-372 区段）改用 `count_step_markers "$tb" tb`；自由 prompt 分支保持 `count_step_markers "$pf"` 单参调用（markdown 编号依旧排除）
3. 头注释 ④ 段（L48-52 区段）追加「任务书模式例外」说明（Rule 46.2 / task-v118 / 原行为）

## 禁改约束确认
- 守卫②（现 L313 区段任务书豁免收窄，git diff 显示为已有改动）本任务零新增改动
- 守卫①③、scan_missing、serial_slot_check、档位管线零改动（diff 仅含上述三处 + 注释）
- 自由 prompt 步骤计数行为零变化（单参调用路径不变）

## 验证证据（worktree 脚本实跑）
- a) fixture 任务书含 `1.`-`6.` 行首编号 6 类动作（无 StepN）→ rc=2，stderr 含 `步骤枚举超限(6>4)` PASS
- b) 自由 prompt 含 6 个行首 markdown 编号（无「任务书」双条件）→ rc=0，无步骤拦截 PASS
- c) 回归:
  - `bash selftest-fine-grain-steps.sh` → SG-01..11 全 PASS（Total: 11 PASS=11 FAIL=0），SG-06 任务书 13 步仍拦
  - `bash selftest-dispatch.sh` → T01..12 + TS-01..08 + FG-01..05 + DX-01..05b 全 PASS（Total: 31 PASS=31 FAIL=0）
- fixture 目录: /tmp/tp118-fix（可复查）
