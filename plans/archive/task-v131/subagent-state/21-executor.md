# subagent-state 21-executor — task-v131/Phase 6 S2 (check-dispatch.sh L-1 注释修正 + P1-4 需求锚 advisory + 模板注释对齐)

## 任务范围（3 子步，2 文件）
- F1: skills/task-planner/scripts/check-dispatch.sh
  - B1: :71-72 SKILL_ROOT 语义注释修正（L-1：selftest-agent-coverage.sh:17 SKILL_ROOT=skill 根,与本脚本 scripts/ 语义相反；只改注释不改代码路径解析）
  - B2: 新增需求锚 advisory（Rule 51.1a/53.5 机器边界，warn 档 fail-open，不改变任何 exit 码；头注释 What+Why：P1-4 裁定锚义务由派发者承担，机器面仅提醒）
- F2: skills/task-planner/templates/task_plan.md
  - B3: 「🧮 根源覆盖表」区块 HTML 注释对齐 53.1 终稿口径（「不适用（非结果级需求）」+ 一句定性理由，与 init-session.sh:198-201 注入版脚手架同口径）
- 禁触碰其他文件；不 commit

## 执行记录
### B1 — SKILL_ROOT 注释修正 ✅
- 位置: check-dispatch.sh:72-77（原 71-73）
- 改法: 原注释行保留,新增 5 行 `[2026-10-05 task-v131 P6-S2 审计 L-1]` 语义注明——变量名 SKILL_ROOT 为遗留误称,实指 scripts/ 目录;与 selftest-agent-coverage.sh:17(= $SCRIPT_DIR/..) 语义相反,跨脚本阅读勿混用;CONFIG_JSON 上跳佐证。变量名/解析逻辑/CONFIG_JSON 派生零改动。

### B2 — 需求锚 advisory ✅
- 位置: fine_grain_checks() 内 ④ 之后、`[ -z "$hits" ] && return 0` 之前（现 check-dispatch.sh:410-419）
- 实现: `grep -qF '需求锚' "$pf"` 未命中 → stderr 一行 `[dispatch-guard] ⚠ 派发 prompt 未含「需求锚」字段（Rule 51.1a：需求相关 S-unit 须逐字引用治理 R 条目；纯机械单元可写「不适用（纯机械单元）」）——advisory 不阻断`
- 关键设计: 刻意不并入 hits 计数管线（①-④ 在 enforce 档 exit 2 阻断;本项任何档位均只提醒,保持成功路径静默 exit 0 与既有档位语义零变化）;函数头注释 What+Why 双层齐备（P1-4 裁定: 锚义务在派发者,机器面仅提醒）
- 触发点: warn 兜底放行路径与 enforce 无缺项路径均经 fine_grain_checks,两条路径都可达;off/nojq 档在函数调用前 return,天然跳过

### B3 — 模板注释对齐 ✅
- 位置: templates/task_plan.md:20-22
- 改法: 「非结果级（单点动作）任务可写「不适用（非结果级需求）」」→「须写「不适用（非结果级需求）」+ 一句定性理由（53.1 禁裸豁免，attest/终验可核；与 init-session.sh 注入版脚手架注释同口径）」——与 init-session.sh:198-201 注入版逐字同口径

## 验证证据（原文输出）
1. `bash -n skills/task-planner/scripts/check-dispatch.sh` → SYNTAX_OK
2. /tmp/v131-dispatch-test 最小三文件+合规 prompt（含 8 字段+subagent-state/ 检查点,故意无「需求锚」）实跑:
   - run1 enforce 档无缺项: `[dispatch-guard] ⚠ 派发 prompt 未含「需求锚」字段（Rule 51.1a：…）——advisory 不阻断` + **exit=0**（advisory 不改变退出码，实证）
   - run2b 含「需求锚」字段、enforce 档、清串行锁后: **exit=0, stderr bytes=0**（静默路径不变，实证）
   - run3 warn 档缺三文件: `[dispatch-warn] ⚠ 派发契约缺项: task_plan.md,findings.md,progress.md,subagent-state/` exit=0（既有缺项路径零变化，实证）
   - off 档: exit=0, stderr bytes=0（off 全程放行语义不变）
3. git diff --stat（本 S-unit 2 文件）: check-dispatch.sh +14 行 / task_plan.md 3 行(2+1-)；worktree 全量 status 中 INSTALL.md/ARCHITECTURE.md 两文件为本派发前已存在的他会话（P6-S1）未提交变更，本 S-unit 零触碰

## 验证边界（如实记录）
- 实跑在 /tmp 最小参数下进行（TASK_PLANNER_PLAN_DIR 显式 + TASK_PLANNER_DISPATCH_ENFORCE 档位 env 注入），未走 jq 读 config.json 分支与 resolve-plan-dir 三级解析链（既有逻辑零改动，无需重验）
- run2 首跑命中既有串行槽锁（前次测试写入 <120s 锁）exit 2 阻断，属既有 serial_slot_check 行为（非本 S-unit 改动引入），清锁后 run2b 复验通过
- check 子命令（cmd_check）不消费 fine_grain_checks，需求锚 advisory 在 check 档不触发——符合「prompt 校验主流程」任务定位（check 为纯缺项检查，档位无关，既有语义未改）

## 状态: complete
