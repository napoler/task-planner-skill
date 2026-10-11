# [sub:09-executor] Fix-D checkpoint — task-v068 observe 节流 flag 自洁
status: done

## 修复点
- 文件: /home/terry/task-planner-skill-worktrees/task-v068-execution-stability/skills/task-planner/scripts/selftest-delegation.sh
- 位置: :440-441(T20 断言前,`cd "$TMP_T20" || exit 99` 之后、`out="$(bash "$CHECK" pretool ..."` 之前)
- 内容(+2 行):
  ```
  # [2026-09-13 task-v068 Fix-D] observe 节流 flag 自洁,防脏环境偶发 FAIL
  rm -f "/tmp/task-planner-observe-anysid.flag"
  ```
- sid 溯源: T20 fixture 用固定 sid `any-sid`(L442),canon `tr -cd 'a-zA-Z0-9'`(check-delegation.sh:255)→ `anysid`,与 :263 `observe_flag="/tmp/task-planner-observe-${sid_norm}.flag"` 逐字节一致。

## 根因
task-v068 observe 节流(check-delegation.sh:261-267):owner 缺失首次交互 emit observation + `touch flag`;同 sid 再次进入观察分支时 flag 已存在 → 静默。selftest T20b grep `delegation-observe|additionalContext` 依赖该次 emit → 脏环境(/tmp 残留 flag)下 T20b FAIL(实测 37/38)。

## 验收证据
1. `bash -n selftest-delegation.sh` → SYNTAX_OK
2. 干净环境 `bash scripts/selftest-delegation.sh` → `Total: 38    PASS=38  FAIL=0`
3. 脏环境: `touch /tmp/task-planner-observe-anysid.flag && bash scripts/selftest-delegation.sh` → `Total: 38    PASS=38  FAIL=0`(修复前同操作 = FAIL T20b, 37/38 —— 修复生效的直接证据)
4. `git diff --stat` → `skills/task-planner/scripts/selftest-delegation.sh | 2 ++` 恰 1 文件 ≤3 行
5. 测试后残留 flag 已 rm(`ls` 确认 No such file)

## Scope
- 只改 1 文件;未 git commit;findings.md 追加 `#### [sub:09-executor] Fix-D 产出` 小节
