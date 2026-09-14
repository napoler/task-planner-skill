---
name: progress-tracker
description: 项目级任务进度追踪账本。维护当前项目 .zcode/ledger/ 下按主题组织的结构化进度记录，跨会话累积，防止重复更新，支持进度回查与效果评估。当用户提到"进度追踪"、"追踪文件"、"长期维护任务"、"任务进度记录"、"进度账本"、"ledger"、"记录这次更新做了什么"、"查看上次更新到哪了"、"避免重复更新"、"追踪维护效果"时触发。适用于网站长期维护、开发功能路线图、内容批量更新等跨会话项目任务。
model: haiku
---

# Progress Tracker

项目级任务进度追踪账本。在当前项目根目录的 `.zcode/ledger/` 下按主题维护结构化进度记录，跨会话累积。

## 核心原则

1. **先查后写**：追加条目前，先读该主题 ledger 文件，防止重复记录相同进度
2. **一事一条**：每次有意义的进度变更追加一条记录，不覆盖历史
3. **项目级优先**：数据存当前项目（`.zcode/ledger/`），不写入用户级目录；项目专属内容归项目所有，保持项目仓库可移植
4. **机器可查 + 人可读**：JSONL 行格式，一行一事件，可用 `grep`/`jq` 快速定位
5. **效果可评估**：条目包含"做了什么"和"预期效果/验证信号"，供后续回查

## 定位与存储路径

**项目级优先**：数据写入**当前项目根目录**（CWD 或其 git 根）的 `.zcode/ledger/`。

```
<project-root>/.zcode/ledger/
├── INDEX.md              # 所有主题的简要索引
├── site-maintenance/     # 主题目录，kebab-case 命名
│   └── site-maintenance.jsonl
├── feature-roadmap/
│   └── feature-roadmap.jsonl
└── content-batch/
    └── content-batch.jsonl
```

- 项目根目录 = 执行时 CWD，或 `git rev-parse --show-toplevel` 解析出的 git 根
- 无 git 仓库时 = 当前 CWD
- `.zcode/ledger/` 随项目仓库提交，团队/其他机器可复用
- 不存在时自动 `mkdir -p`

**用户级回退**（仅当用户显式指定 `~/.zcode/ledger/` 或无明确项目上下文时）：

数据写入 `~/.zcode/ledger/`，目录结构与项目级相同。

## 目录布局

- 主题名 = kebab-case，由任务性质决定（如 `site-maintenance`、`feature-roadmap`、`content-batch`）
- 每个主题一个 JSONL 文件，文件名 = 主题名

## 条目格式

每行一条 JSON 记录（完整字段说明与示例见 `references/ledger-format.md`）：

```json
{"ts":"2026-09-14T10:00:00Z","topic":"site-maintenance","target":"https://example.com","action":"更新首页文章链接","changed":["/home/site/index.html"],"status":"done","effect":"链接 301 正常，首页访问数 +2"}
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `ts` | 是 | ISO8601 时间戳（UTC） |
| `topic` | 是 | 主题名（kebab-case，= 目录名） |
| `target` | 是 | 操作对象（URL/文件路径/功能模块名等） |
| `action` | 是 | 做了什么（一句话，动词开头） |
| `changed` | 否 | 受影响的文件/资源列表（JSON 数组） |
| `status` | 是 | `done` / `in_progress` / `blocked` / `reverted` |
| `effect` | 否 | 预期效果或验证信号（供后续回查） |
| `note` | 否 | 补充说明 |

## 执行流程

### Step 0：解析项目根目录

```bash
# 有 git 仓库时
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
LEDGER_DIR="$PROJECT_ROOT/.zcode/ledger"
mkdir -p "$LEDGER_DIR/<topic>"
```

无项目上下文且用户显式要求用户级时：`PROJECT_ROOT="$HOME/.zcode"`，`LEDGER_DIR="$PROJECT_ROOT/ledger"`。

### Step 1：识别或创建主题

根据任务性质选主题名（kebab-case）。不确定时问用户。
若 `$LEDGER_DIR/INDEX.md` 不存在，创建它（格式见 references/ledger-format.md）。

### Step 2：先查后写

```bash
LEDGER_FILE="$LEDGER_DIR/<topic>/<topic>.jsonl"
# 查该 target 最近 5 条记录
grep -F "<target>" "$LEDGER_FILE" 2>/dev/null | tail -5
```

若已有相同 `target` + `action` 的 `done` 记录，提示用户"该进度已记录，是否仍要追加？"（防止重复）

### Step 3：追加条目

**含 `changed` 数组的条目必须用 `jq -n`（推荐，安全可靠）：**

```bash
jq -cn \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg topic "<topic>" \
  --arg target "<target>" \
  --arg action "<action>" \
  --arg status "done" \
  --arg effect "<effect>" \
  --argjson changed '["/path/to/file1.html","/path/to/file2.html"]' \
  '{ts:$ts, topic:$topic, target:$target, action:$action, status:$status, effect:$effect, changed:$changed}' \
  >> "$LEDGER_FILE"
```

**简单条目（无 `changed` 数组）可用 shell 直接写：**

```bash
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo '{"ts":"'"$TS"'","topic":"<topic>","target":"<target>","action":"<action>","status":"done","effect":"<effect>"}' \
  >> "$LEDGER_FILE"
```

> `changed` 字段是 JSON 数组，直接 shell 拼接容易出错（嵌套双引号）。含 `changed` 字段时一律用 `jq -n --argjson`，这是唯一正确方式。

写入后 Read 该文件最后 3 行，确认写入成功。

### Step 4：更新 INDEX.md

若该主题在 INDEX.md 中无条目，追加一行；若已有条目，更新记录数：

```
- **<topic>** — <一句话描述>（N 条记录）
```

## 查询接口

用户问"上次更新到哪了" / "查看进度" / "之前改过哪些"时：

```bash
# 该主题全部记录
cat "$LEDGER_DIR/<topic>/<topic>.jsonl"

# 该 target 最近 3 条
grep -F "<target>" "$LEDGER_DIR/<topic>/<topic>.jsonl" | tail -3

# 某 action 是否已完成
grep -F "<action关键词>" "$LEDGER_DIR/<topic>/<topic>.jsonl" | grep -F '"status":"done"'
```

更多查询场景与示例见 `references/ledger-format.md`。

## 闭环保障：自动创建 Todo 防止遗忘

**核心原则：追加 `in_progress` 条目 = 任务尚未完成，必须创建对应 Todo，完成后回来更新账本。**

### 何时触发

追加条目时 `status` 为 `in_progress` 或 `blocked` → 立即触发。

### 执行步骤

**Step A：追加账本条目**（status=`in_progress`，effect 字段写"完成后需更新为 done + 实际效果"）

**Step B：创建 Todo**（同一轮内完成，不可跳过）

```
TodoWrite 或 TaskCreate：
- subject: "[progress-tracker] 完成 <target> <action> 后更新 ledger 为 done"
- status: pending
- description: 完成后执行 progress-tracker 更新（Step 3，status=done + 实际 effect）
```

**Step C（任务完成后回来时）**：

1. 按 SKILL.md Step 2-4 更新账本：追加新条目（status=`done`，effect=实际验证结果）
2. 完成 Todo

> 若任务已完成才追加（status 直接 = `done`），则无需创建 Todo，直接完成 Step 4 即可。

## 与其他 skill 的边界

| skill | 职责 | 与 progress-tracker 的区别 |
|-------|------|--------------------------|
| `session-kv` | 会话级临时 KV（/tmp，重启即焚） | progress-tracker 是项目级长期账本（`.zcode/ledger/`，跨会话持久） |
| `task-planner` | 单次任务计划（plans/task-xxx/progress.md） | progress-tracker 跨任务累积，按主题归类 |
| `plan-bookkeeper` | task-planner 三文件机械回填 | progress-tracker 独立于 task-planner，直接追加 JSONL |
| `todo-skill` | 单任务步骤拆解 + TaskCreate 推进 | progress-tracker 记录历史进度，不管当前任务拆解 |
