#### [sub:B1修复] CR2 BLOCKER B1+MAJOR M1+N1 修复单元（2026-10-10）

## 目标
修复 CR2 复审发现的 B1（completed-ttl 误判）+ M1（部分完成漏判）+ N1（legacy 用例缺失）。

## 改动文件
1. `skills/task-planner/scripts/set-active-plan.sh` — B1/M1 修复
2. `skills/task-planner/scripts/selftest-smart-merge.sh` — N1 修复

## B1/M1 修复（set-active-plan.sh gc 分支）

**根因**：原判据 `grep -Ei 'Status.*in_progress'` 未锚定行首，命中模板固定行
`- Update phase status as you progress: pending → in_progress → complete`
（templates/task_plan.md 默认生成），导致真·完成态计划被判「非整体完成」而永不清除（B1）。
且未拦「部分完成」=1 阶段 complete + 其余 pending（M1）。

**修法**：锚定真实状态行两子句：
- `has_complete`: `grep -Eq '^[[:space:]]*[-*][[:space:]]*\*\*Status:\*\*[[:space:]]*complete'`
- `no_active`: `! grep -Eq '^[[:space:]]*[-*][[:space:]]*\*\*Status:\*\*[[:space:]]*(in_progress|pending)'`
- 仅当 has_complete && no_active && mtime>24h → 置空+stale 行
- 禁裸 `Status.*in_progress`

**位置**：set-active-plan.sh gc 分支 completed-ttl 判定段（原 CR修复 BLOCKER-F1 段替换为 CR2 修复 BLOCKER-B1+MAJOR-M1 段）

## N1 修复（selftest-smart-merge.sh）

**根因**：F5 后默认走 staging 新路径，`--legacy` 保留旧直写路径作 fallback；
原 SM-06/SM-14 已改断默认 staging 路径，`--legacy` 路径无回归覆盖。

**修法**：新增 SM-16 用例——跑 `--legacy` 路径，断言旧格式 `[DEPLOY] IDENTICAL: <slot>` 输出 + exit 0。
TOTAL_BASE 16→17。

**位置**：selftest-smart-merge.sh SM-15b 之后、全量清理之前

## 验收证据

### bash -n 语法检查
```
set-active-plan.sh OK
selftest-smart-merge.sh OK
```

### B1 夹具（多阶段全 complete + 含模板固定行 + 25h mtime）
```
[active-plan] gc 全局指针 stale(completed-ttl)=b1-done -> 已置空
.active_plan 大小: 0
判定: B1 PASS
```

### M1 夹具（1 阶段 complete + 其余 pending）
```
无 stale(completed-ttl) 行
.active_plan 内容: m1-partial（保留）
判定: M1 PASS
```

### 在途夹具（真实 in_progress 锚定行）
```
无 stale(completed-ttl) 行
.active_plan 内容: wip-task（保留）
判定: 在途 PASS
```

### selftest-pointer-lifecycle.sh
```
Total: 10 PASS=10 FAIL=0
```

### selftest-smart-merge.sh
```
SM-16 PASS rc=0(期望0) legacy-IDENTICAL旧格式=在
Total: 18 PASS=18 FAIL=0
```

### git diff --stat
```
 skills/task-planner/scripts/init-session.sh        |  5 ++-
 skills/task-planner/scripts/selftest-pointer-lifecycle.sh          | 15 +++----
 skills/task-planner/scripts/selftest-smart-merge.sh   | 52 +++++++++++++++++-----
 skills/task-planner/scripts/set-active-plan.sh     | 21 +++++++--
 skills/task-planner/scripts/smart-merge-back.sh   |  8 +++-
 5 files changed, 77 insertions(+), 24 deletions(-)
```
（其中 set-active-plan.sh +21/-4 与 selftest-smart-merge.sh +52/-3 为本单元改动；其余 3 文件为前序单元改动）

## 状态
- B1: fixed
- M1: fixed
- N1: fixed
