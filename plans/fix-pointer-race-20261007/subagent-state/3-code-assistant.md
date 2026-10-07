# 3-code-assistant · Phase3-S1 cjs 组（active-plan 指针抢占修复）

## 结论：done

## 修改文件清单
1. `/mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race/skills/task-planner/scripts/task-plan-init.cjs`
2. `/mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race/skills/task-planner/scripts/plan-created.cjs`

## diff 摘要

### task-plan-init.cjs
- **修改 1a（RC-2 sidmap 落盘）**：在哨兵写入 try/catch 结束后、resume 判定注释之前，插入独立 try/catch 块：读 env `CLAUDE_CODE_SESSION_ID` → `normSidkey` → 仅当 envKey 存在且 ≠ hook sidkey 时，原子写 `<SIDE_DIR>/<envKey>.sidmap`（tmp+renameSync，内容为 hook sidkey），失败 fail-open 仅告警。
- **修改 1b（RC-1 resume 双命名空间读）**：resume 判定块内，`sidePlan2` 改为先查 `<sidkey>.active_plan`，miss 时回查 `sess<sidkey>.active_plan`（对齐 resolve-plan-dir.sh 兼容读），加注释注明历史裸 sid 落盘导致单读误判。

### plan-created.cjs
- **修改 2（RC-2 兜底两级化）**：`sentinelFallbackSidkey(primaryKey)` 整体替换为两级化版本，保留上方 2026-09-16 P10 注释块：
  - ① `.sidmap` 确定性映射优先（读 `<primaryKey>.sidmap` → normSidkey → 验证映射目标哨兵存在才采用，fail-open 降级到 ②）；
  - ② 最新哨兵探测加 120s 新鲜度窗（`SENTINEL_FALLBACK_MAX_AGE_MS = 120000`）：新鲜才采用，陈旧仅打 WARN「疑似他会话 → 不抢用」，维持 primaryKey。
- **修改 2b（RC-1 双命名空间读补查）**：grep 发现 2 处单一形态读取 `.active_plan` side 指针，均按 1b 同款模式补 sess 前缀回查（存在才回查、优先级让位主形态）：
  - `pointerCandidates` 会话指针处（sidkey 非空分支）：主形态 miss 且 `sess<sidkey>.active_plan` 存在时追加回查候选；
  - 无 sid 兜底清除循环处：`ptr` 主形态 miss 时回查 `sess<sk>.active_plan`（防止误判"无指针认领"而误删活跃会话哨兵）。

## 验收原始输出

### a) node --check
```
$ node --check task-plan-init.cjs && node --check plan-created.cjs && echo "== syntax OK =="
== syntax OK ==
```
两文件均无输出（语法通过）。

### b) grep -c sidmap
```
$ grep -c sidmap task-plan-init.cjs
6
$ grep -c sidmap plan-created.cjs
5
```
init 6≥4 ✓；plan-created 5≥4 ✓。

### c) grep -n "sess' + sidkey" task-plan-init.cjs
```
131:    sidePlan2 = path.join(sideDir2, 'sess' + sidkey + '.active_plan');
```
命中 1 处 ≥1 ✓。

## 负结果/风险排除
- 仅改动任务指定的 2 个文件，未触碰其他路径、未执行任何 git 命令。
- 保留全部既有注释（含 2026-09-16 P10 注释块、task-v068/task-v074 注释）。
- plan-created.cjs 中 `.active_plan` 单一形态读取共 2 处（pointerCandidates + 无 sid 兜底循环），均已补 sess 回查；无其他遗漏形态（legacy `plans/.active_plan` 全局指针与 sidkey 命名无关，不属双命名空间问题，未改）。
- 回查均保持"存在才回查 + 主形态优先"，不改变既有解析链优先级与 TTL 语义。

## 里程碑
- 1/1 完成（两文件修改 + 验收 a/b/c 全过 + 检查点落盘）。
