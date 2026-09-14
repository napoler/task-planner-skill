# Ledger 条目格式与查询参考

## 路径解析（项目级优先）

```bash
# 项目级：git 仓库根目录下的 .zcode/ledger/
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
LEDGER="$PROJECT_ROOT/.zcode/ledger"

# 用户级回退（仅当无项目上下文且用户显式指定）
# LEDGER="$HOME/.zcode/ledger"
```

下文所有查询命令中的 `$LEDGER` 均指向上述解析结果。

## 完整条目字段说明

每行一条 JSON。写入用 `jq -n`（含 `changed` 数组时）或 `echo`（简单条目）。

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| `ts` | string | 是 | ISO8601 UTC 时间戳 | `"2026-09-14T10:00:00Z"` |
| `topic` | string | 是 | 主题名（kebab-case，= 目录名） | `"site-maintenance"` |
| `target` | string | 是 | 操作对象（URL / 文件路径 / 模块名） | `"https://example.com"` |
| `action` | string | 是 | 做了什么（动词开头，一句话） | `"更新首页文章链接"` |
| `changed` | array | 否 | 受影响文件/资源列表 | `["src/index.html"]` |
| `status` | string | 是 | 枚举：`done` / `in_progress` / `blocked` / `reverted` | `"done"` |
| `effect` | string | 否 | 预期效果或验证信号（供后续回查） | `"访问数 +2，链接 301 正常"` |
| `note` | string | 否 | 补充说明（可选） | `"等待下周数据确认"` |

## 完整示例

### 网站维护场景

```json
{"ts":"2026-09-14T09:00:00Z","topic":"site-maintenance","target":"https://mysite.com/about","action":"更新关于页面联系方式","changed":["pages/about.html"],"status":"done","effect":"新邮箱已上线，旧链接 301 跳转正常"}
{"ts":"2026-09-14T14:30:00Z","topic":"site-maintenance","target":"https://mysite.com/pricing","action":"调整定价表第三档价格","changed":["templates/pricing.jinja"],"status":"done","effect":"价格从 $49 改为 $39，已同步 Stripe 定价"}
{"ts":"2026-09-14T16:00:00Z","topic":"site-maintenance","target":"https://mysite.com/blog","action":"批量发布 3 篇新文章","changed":["blog/post-1.html","blog/post-2.html","blog/post-3.html"],"status":"done","effect":"3 篇全部上线，Sitemap 已更新"}
```

### 开发功能路线图场景

```json
{"ts":"2026-09-10T10:00:00Z","topic":"feature-roadmap","target":"auth-module","action":"实现 JWT 登录流程","changed":["src/auth/login.ts","src/auth/token.ts"],"status":"done","effect":"单元测试 12/12 通过，登录耗时 <200ms"}
{"ts":"2026-09-12T09:00:00Z","topic":"feature-roadmap","target":"auth-module","action":"实现 refreshToken 自动续期","changed":["src/auth/refresh.ts","src/auth/middleware.ts"],"status":"in_progress","effect":"续期逻辑完成，待 E2E 测试验证"}
{"ts":"2026-09-13T11:00:00Z","topic":"feature-roadmap","target":"user-profile","action":"设计用户资料表 schema","changed":["migrations/002_user_profile.sql"],"status":"done","effect":"schema 已 review，含 8 个字段，索引 2 个"}
```

> 注意：`changed` 中的文件路径用**项目内相对路径**，便于仓库可移植。

## INDEX.md 格式

`$LEDGER/INDEX.md` 结构：

```markdown
# Ledger 索引

| 主题 | 描述 | 记录数 | 最近更新 |
|------|------|--------|---------|
| site-maintenance | 网站长期内容维护（文章/链接/定价） | 3 | 2026-09-14 |
| feature-roadmap | 开发功能实现追踪（auth/profile） | 3 | 2026-09-13 |
| content-batch | 批量内容创作进度 | 0 | - |
```

记录数 = `grep -c '' "$LEDGER/<topic>/<topic>.jsonl"`（行数）。
最近更新 = 该文件最后一行的 `ts` 字段（UTC 日期部分）。

## 常用查询命令

```bash
# 解析路径
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
LEDGER="$PROJECT_ROOT/.zcode/ledger"

# 1. 列出所有主题及记录数
for f in "$LEDGER"/*/*.jsonl; do echo "$(dirname "$f" | xargs basename): $(grep -c '' "$f") 条"; done

# 2. 某主题全部记录（按时间正序）
cat "$LEDGER/site-maintenance/site-maintenance.jsonl" | jq -r '[.ts,.target,.action,.status] | @tsv' | column -t -s $'\t'

# 3. 某 target 的最近 5 条
grep -F "https://mysite.com/pricing" "$LEDGER/site-maintenance/site-maintenance.jsonl" | tail -5

# 4. 某 action 关键词是否有 done 记录（先查后写用）
grep -F "更新首页" "$LEDGER/site-maintenance/site-maintenance.jsonl" | grep -F '"status":"done"' && echo "已记录" || echo "未记录"

# 5. 查找所有 in_progress 条目（待办）
grep '"status":"in_progress"' "$LEDGER"/*/*.jsonl

# 6. 查找所有 blocked 条目（需跟进）
grep '"status":"blocked"' "$LEDGER"/*/*.jsonl

# 7. 某主题按 target 分组统计
cat "$LEDGER/site-maintenance/site-maintenance.jsonl" | jq -r '.target' | sort | uniq -c | sort -rn

# 8. 最近 7 天所有更新
find "$LEDGER" -name "*.jsonl" -mtime -7 | xargs grep -l . 2>/dev/null
```

## 追加条目脚本

> ⚠️ **注意**：`append_entry` 函数仅处理 `effect` 字符串字段，**无法写入 `changed` 数组**。
> 含 `changed` 字段的条目请优先使用「jq 构造完整条目」，`append_entry` 只用于最简单场景。

```bash
# 用法: append_entry.sh <topic> <target> <action> [status] [effect]
# 写入到 $LEDGER（需先设置 LEDGER 变量）
append_entry() {
  local topic="$1" target="$2" action="$3" status="${4:-done}" effect="${5:-}"
  local ledger_dir="$LEDGER/$topic"
  local ledger_file="$ledger_dir/$topic.jsonl"
  mkdir -p "$ledger_dir"
  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local entry='{"ts":"'"$ts"'","topic":"'"$topic"'","target":"'"$target"'","action":"'"$action"'","status":"'"$status"'"'
  [ -n "$effect" ] && entry="$entry, \"effect\":\"$effect\""
  entry="$entry}"
  echo "$entry" >> "$ledger_file"
  echo "[progress-tracker] 已追加: $ledger_file (status=$status)"
}
# 示例（先设置 LEDGER）:
# PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
# LEDGER="$PROJECT_ROOT/.zcode/ledger"
# append_entry site-maintenance "https://mysite.com" "更新首页链接" done "访问数 +5"
```

## jq 构造完整条目（推荐 — 含 changed 数组）

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
LEDGER="$PROJECT_ROOT/.zcode/ledger"
TOPIC="site-maintenance"
mkdir -p "$LEDGER/$TOPIC"

jq -cn \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg topic "$TOPIC" \
  --arg target "https://mysite.com/pricing" \
  --arg action "调整第三档价格" \
  --arg status "done" \
  --arg effect "已同步 Stripe 定价" \
  --argjson changed '["templates/pricing.jinja"]' \
  '{ts:$ts, topic:$topic, target:$target, action:$action, status:$status, effect:$effect, changed:$changed}' \
  >> "$LEDGER/$TOPIC/$TOPIC.jsonl"
```

## 注意事项

- **项目级优先**：默认写入 `<project-root>/.zcode/ledger/`；仅当无项目上下文且用户显式指定时回退到 `~/.zcode/ledger/`
- **`changed` 路径用项目内相对路径**：便于仓库可移植，团队其他成员 clone 后仍有效
- **JSON 字符串内的双引号**须转义为 `\"`，含 `changed` 数组时用 `jq -n --argjson` 更安全
- 主题名变化（如重命名）时，旧文件保留，新建新主题文件，不合并历史
- `reverted` 状态用于记录"某操作被回滚"，保留历史条目不删除
- `.zcode/ledger/` 建议加入项目 `.gitignore` 排除规则以外的版本控制范围（即**提交到 git**，让团队共享进度）
