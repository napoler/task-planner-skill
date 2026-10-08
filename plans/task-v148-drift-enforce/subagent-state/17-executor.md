# S7-fix3 执行检查点 — 17-executor（N1 rhythm 投递饥饿修复）— FINAL

- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce (branch wt/task-v148-drift-enforce)
- 对象: skills/task-planner/scripts/zcode-posttooluse.sh + skills/task-planner/scripts/selftest-drift-enforcement.sh
- 硬约束: 仅动此 2 文件；主仓只读；禁 git 写；critical-rules.md 零改动
- status: done

## 缺陷（N1，16-code-reviewer 终审阻断）
- 早调用写 due=1；该轮优先级 1-4 命中即 exit 0，到不了末尾 end-emit → due 残留；
  下一轮早调用 count-last_inject<N 走 else，旧代码无脑写 due 0 clobber 残留位 →
  默认 N=10 与 todo_n=10 相位锁定时 [drift-rhythm] 永不投递（30 调用 0 次）。

## 修复（Option C：due 持久化）
- M1: drift_rhythm_check（早调用）写 state 前读回既有 due（读-改-写，防 clobber）；
  阈值命中轮置 due=1，未命中轮原样保留；旧两键 state 缺 due 键按 0 容错。
  位置：zcode-posttooluse.sh:81-100。注释含 Rule 64.3 + Rule 45（What+Why）。
- M2: 函数头「两键」→「三键 count/last_inject/due」；end-emit 块注释标题 F9/F10→F9/F10/N1。
- end-emit 块（due=1 投递+清零）与 F10 清 due 块逻辑零改动。

## 验收证据（可复现）
- `bash -n zcode-posttooluse.sh` / `bash -n selftest-drift-enforcement.sh` → OK
- selftest-drift-enforcement.sh → Total: 23 PASS=23 FAIL=0（新增 DCE-22、DCE-23）
- 独立 harness（mktemp 隔离）：30 连续调用 修复版 delivered=2 / pre-fix 对照 delivered=0（diff 仅 else 1 行）
- 单轮单 JSON：DCE-19 通过；DCE-22 轮1 lines=1 且 due 保留=1
- F10 不回退：DCE-20/DCE-21 → bytes=0 且 due=0
- 回归：drift-check-subagent 20/20；four-file-dataflow 18/18；registry 5/5（rows=61=actual）

## 收尾
- findings.md 已追加 `### S7-fix3 执行回执（17-general）`
- 未动 git（无 add/commit）；主仓只读
