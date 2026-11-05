# S6 — hook 脚本文案追加「对照专档」提示句（Rule 80.8②）

## 目标文件
`/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105/skills/task-planner/scripts/zcode-userpromptsubmit.sh`

## 定位
`grep -n "plan-note"` 确认反思门/新指令提示文案集中在 3 处 note 赋值（L283 / L285 / L287），分别对应 E 类取消、B 类邻近引用、通用反思门分支。均在 `[plan-note]` 节流注入路径内，属文案字符串，未触碰 shell 逻辑/变量/条件判断。

## 修改（纯文案追加，3 处）
在以下三处 `note="..."` 字符串句尾追加同一句（与既有文案风格一致，含中文括号与「」）：
> `新指令到达时先对照专档（user-session-log.md）既有条目——已答过的问题禁再上抛，冲突以逐字原话为准（Rule 80.8②）。`

- L283 `[取消/E 类] [plan-note]` 文案：已追加
- L285 `[邻近引用→B 类] [plan-note]` 文案：已追加
- L287 `[plan-note] 新指令到达 — 先做反思门(Rule 102.0)` 通用文案：已追加

## 验收自证

### 1) `grep -n "80.8"` 命中 ≥1（实际 3 处）
```
283:    note="[取消/E 类] [plan-note] ...新指令到达时先对照专档（user-session-log.md）既有条目——已答过的问题禁再上抛，冲突以逐字原话为准（Rule 80.8②）。"
285:    note="[邻近引用→B 类] [plan-note] ...新指令到达时先对照专档（user-session-log.md）既有条目——已答过的问题禁再上抛，冲突以逐字原话为准（Rule 80.8②）。"
287:    note="[plan-note] 新指令到达 — 先做反思门(Rule 102.0)...新指令到达时先对照专档（user-session-log.md）既有条目——已答过的问题禁再上抛，冲突以逐字原话为准（Rule 80.8②）。"
```

### 2) `bash -n` 语法检查
```
$ bash -n /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105/skills/task-planner/scripts/zcode-userpromptsubmit.sh; echo "exit:$?"
exit:0
```

### 3) `git diff --stat`（仅此文件）
```
 skills/task-planner/scripts/zcode-userpromptsubmit.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
```

### 4) 行数变化 ≤ 6 行
修改前后 `wc -l` 均为 **318 行**（净变化 0 行；diff 为 3 处字符串替换，+3/-3）。

## 约束遵守
- 仅改文案字符串，未改任何 shell 逻辑/变量/条件判断。
- 引号/中文括号/「」与既有风格一致，`bash -n` 通过。