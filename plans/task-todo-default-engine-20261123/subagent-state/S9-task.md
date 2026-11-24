# S9 任务书：selftest 守护加锚（B6 引擎检测）

## 1. 背景
todo 基线组扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）。本单元在既有 selftest 中加锚断言，使 B6 契约不被静默删除——**不新增守护脚本**（用户"最简单方案"）。

## 2. 目标文件（2 个，绝对路径）
1. /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-collab.sh — 协同路由面守护套件（现有 T1-T10 共 19 断言）
2. /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv — 守护登记（第 23 行为 selftest-skill-collab.sh 登记行）

## 3. 精确改动
**文件 1（selftest-skill-collab.sh）**：
- 在现有 T1-T10 之后新增一组断言（如 T11），检查 B6 引擎检测锚存在：
  - `t "T11a todo-sync 含 B6 引擎检测" grep -q 'B6' "$ROOT/references/todo-sync.md"`（$ROOT=skills/task-planner，参照脚本内既有变量定义）
  - `t "T11b Rule106.5 含 B6" grep -q 'B6' "$ROOT/../task-discipline/references/critical-rules-discipline.md"`
  - 断言写法必须遵循脚本既有的 `t "描述" <command>` 框架（先看脚本头 20 行的 t() 定义与 ROOT 变量），不要自创语法。
- 更新脚本头部注释的断言计数（如"19 断言"→"21 断言"）。

**文件 2（selftest-registry.tsv）**：
- 在第 23 行 selftest-skill-collab.sh 的登记行，把 trigger_scenarios 或 dep_anchors 列补上 B6/引擎检测锚（用 tab 分隔，保持 TSV 4 列格式），例如 dep_anchors 追加 `references/todo-sync.md;../task-discipline/references/critical-rules-discipline.md`（若已含则去重）。

## 4. 硬约束
- 只改这 2 个文件；不新增脚本文件。
- 新增断言必须可机械执行（grep/python3），依赖路径在脚本内已解析（先读脚本头确认变量名，禁猜）。
- 用 Edit 精确替换；写后 Read 回读。

## 5. 验收（必须实跑，贴原始输出）
- `bash <selftest-skill-collab.sh>` → exit 0，所有断言 PASS（贴输出尾部）。
- 确认新增断言在 S2/S3 完成后才 PASS（若当前 S2/S3 尚未完成导致 FAIL，如实报告并说明时序依赖，不强行改断言）。
- 若 selftest 有基线 FAIL（与本次改动无关），如实列出并说明。

## 6. 返回契约（8 字段）
status / acceptance / files / evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S9-selftest-anchor.md，目录已存在）/ findings_written / blockers / confidence
