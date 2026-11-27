# 验收三态 verdict — 审查实物（Task 5 / Rule 113.10）

- 目标：证明机器 verdict 三态解析显式、BLOCKED 未经确认不得静默放行；正例 + 负控制 + mutation 可复现。
- 实测基线：worktree `wt/task-comet-trust-learning-20261127` @ `5ce7a24f`；下列命令在 worktree 根执行。
- 两层分离：业务 outcome（`templates/verification.md` 的 `COMPLETE|PARTIAL|BLOCKED`）与机器 verdict（`check-verdict.sh` 的 rc 0/1/2 + `[verdict] OK/rc1/rc2` 文本）互不替代；本门只读 verification 文本，不改 `check-complete.sh` 进程门。

## 实物

### 模板契约（`templates/verification.md` Goal Gate 代码块，:126-127）

```
 outcome: COMPLETE / PARTIAL / BLOCKED
 confirmed: false # BLOCKED 时须用户确认后改 true
```

### 机器输出（BLOCKED 未确认）

```
[verdict] rc1: BLOCKED without user confirmation
```

### 机器输出（BLOCKED 已确认）

```
[verdict] OK: BLOCKED
```

## 审查命令（C1–C4，全部实跑）

| ID | 命令 | 预期 | 实测 |
|---|---|---|---|
| C1 | `bash skills/task-planner/scripts/selftest-verdict-tristate.sh` | `PASS=2 FAIL=0`, rc=0 | `PASS TC-01` / `PASS TC-02` / `[selftest-verdict-tristate] Total: PASS=2 FAIL=0`；rc=0 |
| C2 | `printf 'outcome: BLOCKED\nconfirmed: true\n' \| bash skills/task-planner/scripts/check-verdict.sh /dev/stdin` | rc=0，`[verdict] OK: BLOCKED` | `[verdict] OK: BLOCKED`；rc=0 |
| C3 | `printf 'outcome: BLOCKED\nconfirmed: false\n' \| bash skills/task-planner/scripts/check-verdict.sh /dev/stdin` | rc=1，拒绝（负控制） | `[verdict] rc1: BLOCKED without user confirmation`；rc=1 |
| C4 | 临时副本删除 `if not c or c.group(1)!='true'` 确认检查后重跑 C3，再对原脚本重跑 C3 | mutant rc=0（门失效，mutation 可证伪）；原脚本 rc=1 | mutant `[verdict] OK: BLOCKED` rc=0；原脚本 `[verdict] rc1: BLOCKED without user confirmation` rc=1 |

C4 只改 `mktemp -d` 下的临时副本（断言锚唯一后替换），生产脚本未动；C4 证明 C3 的拒绝确实由确认检查产生，而非文本格式碰巧失败。

## brief 内联代码校正（实测，不改 brief）

- brief Step 2 写法 `python3 - "$F" <<'PY'` + `open(sys.argv[1])`：当 `F=/dev/stdin` 时，Python 源码 heredoc 占用 fd0，`open('/dev/stdin')` 读到源码末尾（空内容）→ 恒 rc1；实测红-green 过程中 TC-02 仍 FAIL，达不到 brief 自己声明的 `PASS=2 FAIL=0`。
- 修正：bash 层用 `python3 - "$F" 3<"$F" <<'PY'` 在 heredoc 替换 fd0 **之前**把目标文本挂到 fd3，Python 改从 `/dev/fd/3` 读原文。调用接口（位置参数 / `/dev/stdin`）、rc 契约与三态判定语义不变；普通文件路径同样适用。
- 红灯证据：门脚本缺失时 `PASS TC-01` / `FAIL TC-02` / `Total: PASS=1 FAIL=1`，rc=1。TC-01 在门缺失时因「命令不存在=非 0」平凡通过，判别性由 C1(绿) 与 C4(mutation) 共同承担。

## 已知边界

- 门是逐行正则文本解析（取首个 `outcome:` 与首个 `confirmed:`），不是 YAML parser；`COMPLETE`/`PARTIAL` 不要求 `confirmed`，只有 `BLOCKED` 要求 `confirmed: true`。
- 本门独立于 `check-complete.sh` 的进程门，未接入 PreToolUse / 终验门链；brief Step 2 明确要求独立新增，业务 outcome 的三态文案仍由模板持有。
- 模板新增行是填写契约，默认 `false`；BLOCKED 时须由用户确认后改 `true`，门只校验文本标记，不替代用户授权动作。
- selftest 以仓根相对路径调用门，须从 worktree / 仓根执行（与既有 harness 的命令口径一致）。
