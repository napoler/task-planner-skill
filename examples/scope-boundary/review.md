# scope-boundary 审查实物（Rule 118 / Rule 113.10）

## 目标

验证范围边界机器门在计划声明、越界拦截、存量兼容、扩张授权四个面可审查、可复现。

## 实物

### plan-state.json 片段

```json
{
  "scope_boundary": {
    "enabled": true,
    "include": ["skills/task-planner/**", "examples/scope-boundary/**"],
    "exclude": ["skills/task-planner/scripts/legacy/**"],
    "declared_by": "plan+user",
    "updated_at": "2026-11-27T00:00:00Z"
  }
}
```

### 越界拦截输出

```text
[scope-boundary] BLOCKED 越界写入: /repo/README.md（计划=task-demo include=skills/task-planner/**,examples/scope-boundary/**；扩张通道: python3 planctl.py scope-extend --path /repo/README.md --reason 用户批准理由（须用户批准+Decisions 登记））
```

### 存量兼容输出

```text
[scope-boundary] WARN 未声明范围边界，按存量计划放行
```

## 审查命令（C-B1..C-B4）

| ID | 命令 | 预期 |
|---|---|---|
| C-B1 | `python3 skills/task-planner/scripts/planctl.py scope-set --plan-dir <plan> --include '<root>/src/**' --declared-by test && TASK_PLANNER_SID="" bash skills/task-planner/scripts/check-scope.sh Write '<root>/tmp/outside.md'` | exit 非0，stdout/stderr 含 `[scope-boundary] BLOCKED` |
| C-B2 | `TASK_PLANNER_SID="" bash skills/task-planner/scripts/check-scope.sh Write '<root>/src/inside.md'` | exit 0 |
| C-B3 | 对无 `scope_boundary` 字段的 plan-state.json 执行 `check-scope.sh Write '<root>/anywhere.txt'` | exit 0，输出含 `[scope-boundary] WARN 未声明范围边界，按存量计划放行` |
| C-B4 | 临时将 `check-scope.sh` 中 `[scope-boundary] BLOCKED` 标记改名后重跑 C-B1 | exit 0（门失效，证明 mutation 可证伪）；恢复原文件后 C-B1 再次 BLOCKED |

## 已知边界

- 匹配是路径/glob 语义，不做语义理解；复杂 glob 以 fnmatch/前缀规则为准。
- `plans/`、计划文件名豁免、轻量/机械产物区/gitignore 区仍由 check-scope.sh 既有分支优先放行。
- 扩张命令 `scope-extend` 只校验 `--reason` 非空，不替代“用户批准”这一人工授权；审批需在 Decisions/进度记录落证据。
- 存量计划无 `scope_boundary` 字段仅 WARN 放行，避免误伤旧计划。
