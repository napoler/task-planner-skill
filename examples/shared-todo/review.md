# 跨任务共用待办（todo.json）：产出实物与审查清单

> 本目录回答两个问题：**共用的待办文件长什么样**、**后期如何审查**。
> 证据采集：2026-11-26，worktree `wt/task-shared-todo-20261126`（基点 master `e796da72`）。
> 实物来源：`todo.example.json` 为本机制的 pretty-print 示例（非虚构历史数据）；审查命令全部**实跑**，下表「实测输出」为真实输出摘录，夹具为 `mktemp -d` 沙箱，未改写仓库根目录的 `todo.json`。
> 对应条款：`skills/task-planner/references/critical-rules.md` Rule 117；唯一写入口 `skills/task-planner/scripts/todoctl.py`。

## 1. 实物清单（可直接打开看）

| 文件 | 作用 | 来源 |
|---|---|---|
| `todo.example.json` | 共用待办 JSON 的可读示例（含未结/已结两类条目） | 本次采集，按 Rule 117 数据契约构造 |
| `review.md` | 本文件：逐字段对照 + 审查命令 + 实测输出 | 本次采集 |

## 2. 产出长什么样（字段级对照）

| 层级 | 字段 | 实际值 / 形态 | 审查要点 |
|---|---|---|---|
| 顶层 | `schema_version` | `1` | 必须为整数 1；`check` 拒其他值（C6 负控制） |
| 顶层 | `updated_at` | `2026-11-26T14:00:00Z` | ISO8601Z 秒级；每次写入刷新 |
| 顶层 | `items[]` | 数组 | 已解决项保留不删（统计「已解决 vs 未解决」的基础） |
| 条目 | `id` | `TODO-0001` | `TODO-<4位以上数字>`，全局唯一、自增；`add` 生成 |
| 条目 | `status` | `open` / `done` | 取值 `open\|in_progress\|done\|cancelled`；终态必须有 `resolved_at`，未结必须为 `null` |
| 条目 | `priority` | `high` / `normal` | 取值 `low\|normal\|high\|urgent` |
| 条目 | `title` / `detail` | 一句话标题 + 现象/判定标准 | 标题非空；`add` 对未结项同标题幂等 |
| 条目 | `source` | `{type,plan_id,ref,session_id}` | **开放标签**，全部可选；`type` 不写死任务类型（可 `task`/`scan`/`review`/任意值） |
| 条目 | `tags` | `["bug","unresolved"]` | 字符串数组、开放标签，机制零枚举 |
| 条目 | `created_at` / `updated_at` | ISO8601Z | 创建/最近更新时间 |
| 条目 | `resolved_at` / `resolution` | `null` 或时间戳 / 处置说明 | 未结为 `null`；`resolve` 自动填时间戳与 `--note` |

## 3. 审查命令与判据（6 条，全部实跑；证据为本次真实输出）

| # | 命令 | 预期 | 实测输出 |
|---|---|---|---|
| C1 | `python3 -m json.tool <root>/todo.json >/dev/null` | exit 0 | `rc=0` |
| C2 | `python3 <skill>/scripts/todoctl.py check --root <tmp-root>` | `TODOCTL CHECK schema: PASS`，rc 0 | `TODOCTL CHECK schema: PASS`；`rc=0` |
| C3 | `python3 <skill>/scripts/todoctl.py stats --root <tmp-root>` | `open=1 in_progress=0 done=1 cancelled=0` | `open=1 in_progress=0 done=1 cancelled=0`；`rc=0` |
| C4 | `python3 <skill>/scripts/todoctl.py add --title "新增待办" --source-type scan --root <tmp-root>` | 新 id、合法 JSON | `{"status": "created", "item": {"id": "TODO-0003", ... "source": {"type": "scan", ...}}}`；`rc=0` |
| C5 | `python3 <skill>/scripts/todoctl.py resolve TODO-0001 --note "已修于 commit xxx" --root <tmp-root>` | status=done 且 resolved_at 非空 | `{"status": "resolved", "item": {"id": "TODO-0001", "status": "done", "resolved_at": "2026-11-26T13:42:55Z", "resolution": "已修于 commit xxx"}}`；`rc=0` |
| C6 | 把 fixture 的 `schema_version` 改成 `"x"` 后重跑 `check` | **FAIL**（负控制） | `TODOCTL CHECK schema: FAIL schema_version 必须为 1`；`rc=1` |

## 4. 后期审查流程（固定动作）

1. 打开 `todo.example.json`，按 §2 字段表逐行核对；实际项目的 `<root>/todo.json` 应与之一致（仅条目不同）。
2. 跑 §3 的 C1–C6，逐条比对输出；**C6 必须 FAIL**，其余必须 PASS。
3. 任何条款/脚本改动后，重跑 C1–C6 + `bash skills/task-planner/scripts/run-selftests.sh --only todoctl`；示例实物与条款锚不一致即视为回归。
4. 统计未结问题用 `todoctl.py list`（默认 open）与 `todoctl.py stats`；不要手改 JSON（唯一写入口=CLI，Rule 117.3）。

## 5. 已知边界

- 已解决项永久保留（status=done），不物理删除；如需重新处理用 `reopen`。
- `add` 的幂等仅针对**未结项且标题完全相同**；标题相近但不同仍视为新问题。
- worktree 并行时其 `todo.json` 副本按普通文件参与 merge-back；收口后在主仓复跑 `stats` 确认条目汇合，CLI 的 `--root` 可显式指向任一 checkout。
- 本示例不预填真实遗留问题（禁止脑补）；实际项目文件由 `todoctl.py init` 建空骨架。
