# S26 CR 修复批C 检查点（executor，worktree 内写）

- 执行对象：/mnt/data/dev/task-planner-skill-worktrees/task-v149-skill-alignment-audit
- 目标文件：skills/task-planner/scripts/sync-companion.sh + skills/task-planner/scripts/selftest-registry.tsv
- 需求锚：R3「修复其中的问题、错误以及不合理的地方」
- 结论：**completed**（L-2/L-3 全部修复，自验通过）

## L-2 修复：sync-companion.sh COMPAANION_DIR 拼写

- 判定：grep 确认 7 处全部使用 `COMPAANION_DIR`（多一个 A），定义+引用自洽，与 install-companion.sh 修复前状态相同（同款未定义拼写）
- 修复：7 处全部改为 `COMPANION_DIR`，逐处注 `# 2026-10-09 task-v149 CR L-2 拼写修正`
- 位置：行 16（定义）/ 行 42（两实例）/ 行 47 / 行 59 / 行 103 / 行 108 / 行 117
- 残留：`grep -c "COMPAANION" sync-companion.sh` = 0

## L-3 修复：selftest-registry.tsv properties=40 → properties=42

- 判定：grep 确认 10 行 `properties=40`（行 41/43/46/47/48/49/51/52/53/54）
- 修复：sed 全局替换 `properties=40` → `properties=42`，tab 分隔严守
- 残留：`grep -c "properties=40" selftest-registry.tsv` = 0

## 自验输出

```
=== bash -n sync-companion.sh ===
PASS
=== grep -c properties=40 ===
0
=== awk column check ===
0
=== COMPAANION residual ===
0
```

- bash -n 语法检查：PASS
- properties=40 残留：0
- awk 列数检查（NF!=4 计数）：0（全部 4 列，tab 分隔未破坏）
- COMPAANION 残留：0

## 证据

- sync-companion.sh:16 — `COMPANION_DIR="${TASK_PLANNER_ROOT:-$SKILL_ROOT}/companion" # 2026-10-09 task-v149 CR L-2 拼写修正`
- sync-companion.sh:42 — `[ -d "$COMPANION_DIR" ] || { echo "[sync] ERROR: companion dir missing: $COMPANION_DIR" >&2; exit 1; } # 2026-10-09 task-v149 CR L-2 拼写修正`
- selftest-registry.tsv:41 — `...config properties=42...`（原 40）
- selftest-registry.tsv:54 — `...config properties=42 零新键`（原 40）

## 异常

无

## 未验证项

无

## 下一步建议

无（S26 完成，等待 S27/S28 后续 CR 修复批）
