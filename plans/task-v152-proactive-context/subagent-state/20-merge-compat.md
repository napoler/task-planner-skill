# Checkpoint: 20-merge-compat

- **Phase:** 6 merge-compat 微修复
- **Executor:** executor（主进程直做，单文件 ≤3 行 trivial 修改 + 非保护区运行行为文件——§11.5 例外④）
- **Timestamp:** 2026-10-10
- **Worktree:** /mnt/data/dev/task-planner-skill-worktrees/v152-proactive-context

## 任务

并集口径修复 G-07：`tail -1 "$REGISTRY"` 的「末行必含本脚本」假设在并行任务合并后不成立（v152 的新 selftest 行追加在其后，末行=selftest-context-pressure.sh）。改为全表行匹配。

## 改动

**文件:** `skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh`（唯一改动文件）

**改动 1 — 注释（L18-19）:**
```diff
-#         G-07 末行含 `selftest-goal-unit-goal-mode.sh`
+#         G-07 含 `selftest-goal-unit-goal-mode.sh`（并集口径：任意行，末行假设不适用于并行合并）
```

**改动 2 — 断言逻辑（L104-108）:**
```diff
-# G-07 selftest-registry.tsv 末行含 `selftest-goal-unit-goal-mode.sh`
-# What：断言 registry 末行登记本脚本。
+# G-07 selftest-registry.tsv 含 `selftest-goal-unit-goal-mode.sh`（并集口径）
+# What：断言 registry 全表含本脚本登记行。
 # Why：selftest-registry.tsv 是全部 selftest 脚本的登记账本；新脚本必须登记以形成闭环。
+#      并行任务合并后末行可能为其他 selftest 行，故用全表匹配（grep -q）替代末行假设。
 last_line="$(tail -1 "$REGISTRY" || true)"
-if printf '%s\n' "$last_line" | grep -q 'selftest-goal-unit-goal-mode.sh'; then ok 07 "selftest-registry.tsv 末行含 selftest-goal-unit-goal-mode.sh"; else bad 07 "selftest-registry.tsv 末行=$last_line（应含 selftest-goal-unit-goal-mode.sh）"; fi
+if grep -q 'selftest-goal-unit-goal-mode.sh' "$REGISTRY"; then ok 07 "selftest-registry.tsv 含本脚本登记（并集口径：任意行，末行假设不适用于并行合并）"; else bad 07 "selftest-registry.tsv 缺本脚本登记=$last_line"; fi
```

**保留:** `last_line` 变量供 bad 消息用；G-08/G-09 及其余断言零触碰。

## 验收

| 检查项 | 结果 |
|--------|------|
| `bash scripts/selftest-goal-unit-goal-mode.sh` | exit 0，9/9 PASS（G-07 新文案输出确认） |
| `git diff --check` | 通过（无输出=无空白错误） |
| 改动范围 | 仅 `selftest-goal-unit-goal-mode.sh` 1 文件 2 处，diff 确认 |

## 状态

DONE
