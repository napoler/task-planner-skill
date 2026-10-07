# Checkpoint — task-v146 S1 executor (critical-rules.md)

## status: done

## 操作清单

### 步骤 1：Read 目标文件 Rule 15 块（:57-72）与文末 20 行，确认与材料包特征串一致
- Rule 15 块位于 :57-72，与 KB §5.2 描述一致
- 文末 60.8 机制行位于 :712
- 索引括注：文内无 `40-55` 式索引括注（仅 :408 有 `Rules 1-39`），步骤 5 不动

### 步骤 2：按 KB §5.2 表 a-d 用 Edit 逐处替换（4 处）
- **a** 导语段首句（:58）：`Skill("task-drift-guard")` → `drift-checker` 子代理偏移检查
- **b** 15.1 引导句（:60）：`Skill("task-drift-guard")` → `drift-checker` 子代理
- **c** 15.2 首句（:70）：`task-drift-guard 输出` → `drift-checker 判定`
- **d** 15.3 中句（:72）：`task-drift-guard` → `drift-checker` 子代理

### 步骤 3：15.3 行之后追加空行 + 15.4 行
- 追加 KB §5.2-e 的 15.4 行（子代理载体 Rule 61 — task-v146）

### 步骤 4：文末 60.8 行之后追加空行 + Rule 61 全文
- 追加 KB §5.1 的 Rule 61 全文（### 61 标题 + 引言行 + 61.1-61.6 六条）

### 步骤 5：索引括注检查
- 文内无 `40-55` 式索引括注，不动，deviations 记录

### 遗留 1 补切换（5 处旧载体引用）
- **:40** Rule 11 块内 `Skill("task-drift-guard")` → `派发 drift-checker 子代理偏移检查（Rule 61 载体）`
- **:46** Rule 11 块内 `task-drift-guard` 是只读检测层 → `drift-checker` 是只读检测执行体
- **:86** 17.4 行 `Skill("task-drift-guard")` ≤3 次 → `drift-checker` 派发 ≤3 次
- **:205** Rule 24 块 `在调 task-drift-guard **之前**` → `在派发 drift-checker **之前**`
- **:208** Rule 24 块 `(同 Rule 11 调 task-drift-guard 的时机)` → `(同 Rule 11 派发 drift-checker 的时机)`
- **:722** 61.3 双载体说明 `task-drift-guard` skill 保留为交互/独立场景载体 — 有意保留，禁改

## 关键 grep 数字

| 检查项 | 结果 |
|--------|------|
| `grep -c 'Skill("task-drift-guard")'` | 0 |
| `grep -n 'task-drift-guard'` | 仅 :722（61.3 双载体说明） |
| `grep -c '^### 61 '` | 1 |
| `grep -c '\*\*61\.[1-6]'` | 6 |
| `grep -c '\*\*15\.4'` | 1 |
| `grep -c 'Rules 1-39'` | 2 |
| `grep -c '清零'` | 1 |
| `grep -c 'check-drift.sh'` | 3 |

## wc 行数
- 725 行（原 712 行，净增 13 行）

## git diff --stat
```
 skills/task-planner/references/critical-rules.md | 31 +++++++++++++++++-------
 1 file changed, 22 insertions(+), 9 deletions(-)
```

## deviations
- 文内无 `40-55` 式索引括注（仅 :408 有 `Rules 1-39`），步骤 5 不动
- 遗留 1 的 5 处补切换（Rule 11 块内 2 处、17.4 行 1 处、Rule 24 块 2 处）为验收 `Skill("task-drift-guard")` = 0 的必需操作，按用户指示等义替换

## FINAL 状态
- 全部验收通过
- 未 git commit（主进程统一提交）
- 只改 critical-rules.md 单文件
