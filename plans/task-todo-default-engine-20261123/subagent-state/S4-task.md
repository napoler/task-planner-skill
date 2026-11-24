# S4 任务书：三层载体 — sync-todos.sh 产出器 + task_plan 模板露出

## 1. 背景
用户缺陷③根因：todo 默认项是纯文本契约——`sync-todos.sh --json` 不产出基线组、模板不露出，全靠执行体手抄。本单元让基线组由脚本自动带出。基线组扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）由 S2/S3/S8 落地，本单元只管产出器+模板露出。

## 2. 目标文件（2 个，绝对路径）
1. /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh — JSON 输出段（现第 156/200 行：`local json_entries=""` / `echo "[$json_entries]"`）
2. /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md — 原生 Todo 同步段（现第 455-470 行：`## 🔁 原生 Todo 同步（S1–S5 强制）`）

## 3. 精确改动

**文件 1（sync-todos.sh）**：
- 在 JSON 输出分支（`if $JSON_OUTPUT; then echo "[$json_entries]"`）之前，构造一个**基线组 JSON 数组常量**并并入最终输出，使 `--json` 输出形如：
  `[{"task_id":"...","phase":N,...}, ..., {"task_id":"B1","phase":0,"status":"baseline","subject":"修改后验证与复检留痕"}, ... B2..B8]`（B 组字段命名与现有 task entries 兼容：`task_id`/`phase`/`status`/`subject`，B1-B8 各一条，subject 用简短中文标识：B1 修改后验证 / B2 Phase翻转校验 / B3 终验VC复验 / B4 收尾回读 / B5 Todo终态 / B6 引擎检测 / B7 对齐核查 / B8 worktree核验）。
- **最小增量原则**：不改脚本主流程、不改 task entries 构造逻辑（第 156-198 行），只在 JSON 分支输出前追加 B 组拼接（例如新增 `local baseline_entries='...'` 并在 `echo "[...]"` 处把两段用逗号连接）。bash 反引号/引号小心，避免破坏现有 `\"` 转义。
- --help/usage 文案（第 33 行）若需注明"含 B1-B8 基线组"可加一句，但非必须。

**文件 2（templates/task_plan.md）**：
- 在 `## 🔁 原生 Todo 同步（S1–S5 强制）` 段的 `> 契约详见 ...todo-sync.md` 引用行之前，插入一段**基线组清单锚**（简短 3-5 行）：
  `**基线组 B1-B8（S1 建组必含，B1-B5 逐字保留）**：B1 修改后验证 / B2 Phase翻转校验 / B3 终验VC复验 / B4 收尾回读 / B5 Todo终态 / B6 引擎检测（OpenSpec/Superpowers）/ B7 对齐核查 / B8 worktree核验。门禁：B6 未留痕不得声称按引擎推进；B8 未勾实现类不得直接改主树。缺失=S3 当次重建。`
- 保持模板既有 `{{TASK_PLANNER_ROOT}}` 等渲染变量不被破坏。

## 4. 硬约束
- 不改脚本主流程、不新增脚本文件；只动这 2 个文件。
- 用 Edit 精确替换；写后 Read 回读两处锚点（Rule 106.1a）。
- bash 拼接务必实测语法正确（跑 `bash -n`）。

## 5. 验收（必须实跑，贴原始输出）
- `bash -n <sync-todos.sh>` → exit 0
- `bash <sync-todos.sh> --json plans/task-todo-default-engine-20261123` → 输出 JSON 串必须含 `B1`…`B8` 八个 task_id（用 python3 解析输出确认 8 个 B 组元素）。
- `grep -n 'B6\|B7\|B8' <templates/task_plan.md>` 命中。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S4-carrier.md，目录已存在）/ findings_written / blockers / confidence
