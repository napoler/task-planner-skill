# S-unit 15b: selftest 宽容锚纪元 [4-6]→[4-7] (task-v158)

- status: done
- 改动文件（仅 2）:
  - skills/task-planner/scripts/selftest-reflect-verify.sh:60 — RV-10 断言 `Rules 1-(3[5-9]|[4-6][0-9])` → `Rules 1-(3[5-9]|[4-7][0-9])`，同行注释与头注释（L13）补 7x 纪元注记，PASS 文案 1-35..1-72
  - skills/task-planner/scripts/selftest-veto.sh:51 — VT-10 断言 `Rules 1-(3[1-9]|[4-6][0-9])` → `Rules 1-(3[1-9]|[4-7][0-9])`，同行注释与头注释（L13）补 7x 纪元注记，文案 1-3x..7x
- 验证:
  - `bash -n` 双脚本 SYNTAX-OK
  - `bash selftest-reflect-verify.sh` → Total: 12 PASS=12 FAIL=0, exit 0（RV-10 PASS）
  - `bash selftest-veto.sh` → Total: 13 PASS=13 FAIL=0, exit 0（VT-10 PASS）
- 时间: 2026-10-10, 预算 10min 内完成
- 备注: worktree 内另有其他 S-unit 已提交的修改（selftest-drift-check-subagent / execution-honesty / root-resolution / self-resolution / skill-split 等），非本 unit 产出；本 unit 仅触上述 2 文件。
