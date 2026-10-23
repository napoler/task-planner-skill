# S8b — worktree 内全量 selftest 复跑（VC-3 证据）

- 单元: S8b
- 执行时间: 2026-10-23
- 执行目录: /mnt/data/dev/task-planner-skill-worktrees/task-focus-plan-split-20261023
- HEAD: 571ad73 `chore(task-focus-plan-split-20261023): rule-reserve land 94（前置配对，S8 PR-02 闭环）`
- 前置: land 94 已闭环 PR-02（HEAD 核验通过）
- 状态: done

## 命令与结果

### 1. 契约命令（缓存语义）

```
cd <worktree> && bash skills/task-planner/scripts/run-selftests.sh
```

- exit_code: 0
- 尾部: `Total: 92 PASS=92 FAIL=0 (run=92 reused=91)`
- 观察: 92 个脚本中 91 个命中输入指纹缓存（`[reused]`），仅 `selftest-rule-reserve-pairing` 真实执行（`[run]`）。
  缓存指纹 = 全部 selftest 脚本内容哈希 + `git rev-parse HEAD` + `git status --porcelain <SKILL_ROOT>`
  （见 scripts/run-selftests.sh:53-65）。指纹与 land 提交一致，缓存值为 land 后真实跑的产物，
  但本条命令本身不构成本单元独立实跑证据。

### 2. 补充实跑（`--fresh`，绕过缓存）

```
cd <worktree> && timeout -s TERM 540 bash skills/task-planner/scripts/run-selftests.sh --fresh
```

- exit_code: 0
- duration: 205s（< 600s 上限）
- 尾部: `Total: 92 PASS=92 FAIL=0 (run=92 reused=0)`
- `[run]` 计数 = 92；`[reused]` 计数 = 0 —— 全量真实执行
- `[FAIL]` 行: 0 条；`rc=[1-9]` 行: 0 条；全部脚本 `FAIL=0`
- 与磁盘 selftest 脚本数一致：`ls scripts/selftest-*.sh | wc -l` = 92

## VERDICT

PASS —— Total 92 / PASS 92 / FAIL 0 / 真实执行 92（reused 0），exit 0。VC-3 证据成立。

## 工作树保全

- `git status --short` 输出为空（无新增/修改/删除）
- HEAD 仍为 571ad73，未产生任何提交
- 未修改 worktree 内任何文件；仅写入本检查点（位于主仓 plans/，不在 worktree 内）
- 测试过程产物: /tmp/s8b_fresh.log（临时日志，非仓库文件）

## 风险 / 观察（非本单元引入）

- 3 个脚本断言数为 PASS=0（`selftest-source-anchor-discipline`、`selftest-user-instruction-priority`、
  `selftest-verify-io`）。在缓存态与 fresh 态两次运行中一致，非本次变更引入的回归；
  属既有"零断言通过"现象，仅记录不修复（禁改范围）。
- 契约命令默认走缓存，单次 `run-selftests.sh` 复位跑语义需显式 `--fresh`；建议后续 VC 复跑口径注明。

## next

无。
