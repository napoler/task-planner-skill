# S13 检查点 — C-1a① PreToolUse hook cwd 来源修复

- task: task-v091-efficiency-optimization / subagent: S13 (executor)
- date: 2026-09-27
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（HEAD 基准 2d5f791 = S12 组2 交付；未 commit，改动留在工作区）
- status: complete

## 1. 改动文件（1 个，bash -n 通过，未 commit）

`skills/task-planner/scripts/zcode-pretooluse.sh` :94-97（diff = 1 file, +4/-1）：

```diff
-  CWD="${PWD}"
+  # [2026-09-26 task-v091 C-1a①：cwd 来源修复] 原 $PWD 是宿主进程 cwd 非目标项目根，改从 stdin JSON .cwd 取（兜底链保留）
+  # 范式对齐 zcode-posttooluse.sh:18-19 / zcode-userpromptsubmit.sh:16（.cwd // empty → ${CWD:-$PWD}）
+  CWD="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
+  CWD="${CWD:-$PWD}"
```

stdin 全文在 :10 `input="$(cat)"` 已读暂存，本修复复用 `$input` 变量，无二次读 stdin。兜底链为 `.cwd // $PWD`——原代码仅有 `$PWD` 一层，无环境变量中间层可保留（已 grep 全脚本确认 CWD 无其他来源）；形态与两个兄弟 hook 脚本既有范式逐行同构。

## 2. 关键决策

1. **发现上轮中断遗留**：进场时 worktree 已有同内容未提交修改（检查点缺失、无自测痕迹，判定为上轮 S13 执行中断产物）。逐行核实与任务书要求逐字一致（含注释原文）且与兄弟脚本范式同构 → 采信不重做，本轮补齐验证与检查点。
2. **夹具补 session_id**：任务书夹具无 session_id → sid 落 "default" → check-delegation 视为主进程 → a.txt 非白名单 enforce 拦截（EXIT=2 实测）。生产现实中 ZCode PreToolUse stdin 恒含 session_id（本脚本 :17/:30/:68 自身消费该字段），补 `"session_id":"c1afakesid123"` 走 mode_pretool ② 子代理分支放行，是最忠实于生产的测试形态（by-design 合规路径，非绕过）。
3. **conflict 端到端素材**：scope 条目须 `\.a.txt` 形态（见 §4.1 正则语义），夹具为 /tmp 测试物可自由调整。

## 3. 验证证据（全部原文）

- **bash -n**：`BASH-N: SYNTAX-OK`
- **验收①（含 .cwd，从主仓 cwd 调用，$PWD=/mnt/data/dev/task-planner-skill）**：xtrace（/tmp/c1a-run1b.trace）
  ```
  46:++ jq -r '.cwd // empty'
  47:+ CWD=/tmp/c1a-fake-proj
  48:+ CWD=/tmp/c1a-fake-proj
  ```
  EXIT=0；CWD 来自 stdin JSON 而非调用时 $PWD（差分对照成立）
- **Rule 23 扫描目标正向证明**：xtrace `+ plan=/tmp/c1a-fake-proj/plans/task-c1a-active/task_plan.md`；`for other_plan` 循环遍历 fake-proj 的两个 plan
- **端到端 conflict 注入**（EXIT=0，/tmp/c1a-run5.out）：
  ```
  {"additionalContext": "[conflict] 文件 /tmp/c1a-fake-proj/a.txt 可能与其他 plan(task-c1a-demo, session=c1a-fixture)冲突,请确认 scope"}
  ```
- **验收②（无 .cwd 字段）**：xtrace（/tmp/c1a-run4.trace）
  ```
  46:++ jq -r '.cwd // empty'
  47:+ CWD=
  48:+ CWD=/mnt/data/dev/task-planner-skill
  ```
  EXIT=0 无报错，落 $PWD 兜底
- **终态**：`git status --short` = 仅 ` M skills/task-planner/scripts/zcode-pretooluse.sh`；`+4 -1`；未 commit

## 4. 范围外发现（未改，仅登记）

1. **Rule 23 scope awk 正则语义**（zcode-pretooluse.sh :105/:110 `/\\.[a-zA-Z]/`）：ERE 中 `\\`=字面反斜杠、`.`=任意字符、`[a-zA-Z]`=字母，即条目须含「反斜杠+任意字符+字母」（实测 `MATCH-COL4:\.a.txt`；`a.txt`/`\.a` 均不匹配）。真实 plan 的 scope 表条目（如 task-v091 的 `` `plans/.../*.md` ``）无前导反斜杠 → current_scope/other_scope 恒空 → conflict 分支对常规 scope 表难触发。与 CWD 修复正交（本修复只改扫描目标来源），既有行为未动。
2. **plan 探测 glob**：`ls -t "$CWD"/plans/*/task_plan.md` 不匹配 `plans/task_plan.md` 顶层形态（仅匹配 plans/<dir>/task_plan.md），顶层兜底只查 `$CWD/task_plan.md`。上轮夹具遗留 `plans/task_plan.md` 顶层文件即属此形态，不影响本修复验证（CWD 赋值在探测之前）。
3. check-delegation `get_enforce_mode` 读 `.properties.delegation_enforce.default` 单层路径，疑似 C-1b 同款缺陷位点（S12 §2 扫描清单未见此键，需主进程裁决是否补位）。

## 5. 返回 8 字段

- status: complete
- files_written: skills/task-planner/scripts/zcode-pretooluse.sh（worktree 内，+4/-1，未 commit）+ 本检查点
- evidence: §3（xtrace CWD 三连、conflict 注入原文、bash -n、git 终态）
- key_decisions: §2（上轮遗留采信不重做 / 夹具补 session_id 忠实生产 / conflict 素材形态修正）
- risks: §4（scope awk 正则与 glob 顶层形态为既有缺陷未动；delegation 单层路径待裁决）
- next: 主进程验收 → VC 复验 → 合并回合约；脚本级回归按约定留 S32 干净上下文验证包
- fallback_used: none
- checkpoint_path: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S13-c1a-cwd.md
