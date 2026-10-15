#!/usr/bin/env bash
# selftest-sync-index.sh — task-v091/S21 C-3: sync-todos.sh --index 行为级自测(改造前置)
# [2026-09-27 task-v091 S21] 锁定 --index 全量重算产出的 INDEX.md 结构语义, 作为
# 「每 plan 多进程 → 单 awk 全量重算」重构的行为锚(改前/改后都必须全 PASS):
#   T01 rc=0 + Wrote 摘要行 / T02 头部+表头结构 / T03 行数(归档排除)+行态枚举
#   / T04 complete 落已完成区且不落待处理区 / T05 in_progress 待处理行形
#   / T06 pending 待处理行形 + 无 frontmatter sid=none / T07 goal 注释剥离+50 字符截断
#   +scope 头 10 条逗号 join+括号注记 status 归一计数
#   / T08 D1 撤回注记: 注记含 complete 的 in_progress 不得翻 complete(2026-10-15 task-v176)
#   / T09 D1 星号列表符 '* **Status:**' 双入口一致(sync-todos 与 --index 同判 complete)
#   / T10 归档夹具整行消失 / T11 汇总计数 / T13 mtime 反映文件真实状态(P2 副本,全量重算无缓存)
#   / T14 行序=路径排序 / T15 待处理区仅 in_progress/pending 且字段形完整
#   / T12 空 plans fail-open(T24 移最后, 防 call "$EMPTY" 覆写共享 $IDX)
# [2026-10-15 task-v176/D1] 原 T08-T13 顺延为 T10-T15, 新插 T08/T09 锁定状态判定统一
# 口径(行首列表锚+全词判定, 注记含 complete 字样不得翻 complete)。
# hermetic: 夹具全在 mktemp -d, 跑完 trap rm -rf; 不触真实 plans/。全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC="$SCRIPT_DIR/sync-todos.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

pass() { PASS=$((PASS+1)); printf 'T%s PASS %s\n' "$1" "$1"; }
fail() { FAIL=$((FAIL+1)); printf 'T%s FAIL %s\n' "$1" "$2"; }

call() {  # call <plans_dir> → 跑 --index, 置 RC/COUT/CERR
  RC=0; COUT="$(bash "$SYNC" --index "$1" 2>"$TMP/err")"; RC=$?
  CERR="$(cat "$TMP/err")"
}

row_of() {  # row_of <task-id> → 取该任务表格行, 日期列归一为 DATE(消除跑测日期噪声)
  grep -F "| $1 |" "$IDX" | head -1 | sed -E 's/\| [0-9]{4}-[0-9]{2}-[0-9]{2} \|/| DATE |/'
}
sec() {  # sec <起标题> <止标题> → 截取 INDEX 区段(含起止行); 前缀匹配(真实标题带后缀括注,
         # 口径同消费方 check-conflicts.sh:97 的 /^## 待处理/,/^## 已完成/p, 禁加 $ 锚)
  sed -n "/^## $1/,/^## $2/p" "$IDX"
}

# ─── 夹具: active/complete/pending 三态 + 归档, 共 5 计划(≥4) ──────────────────
ROOT="$TMP/fixture"
P="$ROOT/plans"
IDX="$P/INDEX.md"
mkdir -p "$P/task-20260920-111101" "$P/task-20260921-111102" "$P/task-20260922-111103" \
         "$P/task-20260923-111104" "$P/archive/task-20260924-111105"

# F1 complete: 2/2 全完成, frontmatter sid/wt, scope 表 4 个点分单元格(允许+禁止列均收)
cat > "$P/task-20260920-111101/task_plan.md" <<'EOF'
---
session_id: sess-complete
worktree_path: /wt/complete
---
# Task complete

## Goal
Complete task goal line

## ⚠️ 执行范围限制

| 类别 | 允许 | 禁止 |
|------|------|------|
| 脚本 | a1.sh | b1.sh |
| 文档 | a2.md | b2.md |

### Phase 1: one
- [x] step
- **Status:** complete（2026-09-19）

### Phase 2: two
- [x] step
- **Status:** complete
EOF

# F2 active: 1/3(in_progress 带括号注记), 无 scope 区段 → scope_files 空单元格
cat > "$P/task-20260921-111102/task_plan.md" <<'EOF'
---
session_id: sess-active
worktree_path: /wt/active
---
# Task active

## Goal
Active task goal line

### Phase 1: one
- [x] step
- **Status:** complete

### Phase 2: two
- [ ] step
- **Status:** in_progress(2026-09-27, S21 注记)

### Phase 3: three
- [ ] step
- **Status:** pending
EOF

# F3 pending: 0/2 全未开始, 无 frontmatter(sid→none, wt→空)
cat > "$P/task-20260922-111103/task_plan.md" <<'EOF'
# Task pending

## Goal
Pending task goal

### Phase 1: one
- [ ] step
- **Status:** pending

### Phase 2: two
- [ ] step
- **Status:** pending
EOF

# F4 meta-rich: goal 首行 HTML 注释(剥离)+缩进长行(50 截断), scope 12 条(验证头 10 上限),
# status 含小写与括号注记
G58="VisibleGoalLine-Pad0123456789012345678901234567890123456789"
{
  printf -- '---\nsession_id: sess-rich\nworktree_path: /wt/rich\n---\n'
  printf -- '# Task rich\n\n## Goal\n\n<!-- hidden hint -->\n   %s\n\n' "$G58"
  printf -- '## 执行范围限制\n\n| 类别 | 允许 | 禁止 |\n|------|------|------|\n'
  for i in 01 02 03 04 05 06 07 08 09 10 11 12; do
    printf -- '| 组 | r%s.sh | x%s.sh |\n' "$i" "$i"
  done
  printf -- '\n### Phase 1: one\n- [x] step\n- **Status:** complete\n\n'
  printf -- '### Phase 2: two\n- [ ] step\n- **status:** in_progress（2026-09-27, note）\n'
} > "$P/task-20260923-111104/task_plan.md"

# F5 归档: 完成态但位于 plans/archive/ 深度 3 → 不得出现在 INDEX 任何位置
cat > "$P/archive/task-20260924-111105/task_plan.md" <<'EOF'
# Task archived

## Goal
Archived task goal

### Phase 1: one
- [x] step
- **Status:** complete
EOF

# [2026-10-15 task-v176/D1] F6 撤回注记: Phase 2 状态行注记含 complete 字样
# (「前一轮 complete 判定已撤回」)——原 write_index contains 匹配会把它误计
# complete(进行中→已完成失真)。全词判定后: 1/2 → in_progress。
mkdir -p "$P/task-20260925-111106" "$P/task-20260926-111107"
cat > "$P/task-20260925-111106/task_plan.md" <<'EOF'
# Task d1-retract

## Goal
D1 retract note fixture

### Phase 1: one
- [x] step
- **Status:** complete

### Phase 2: two
- [ ] step
- **Status:** in_progress（前一轮 complete 判定已撤回）
EOF

# [2026-10-15 task-v176/D1] F7 星号列表符: Status 行用 '* ' 列表符(原 forward_sync
# 仅锚 '- ' → 捕获不到, write_index 无行首锚 → 计 complete, 两入口分裂)。
# 统一行首列表锚(剥 '- '/'* ')后: 1/1 → 双入口同判 complete。
cat > "$P/task-20260926-111107/task_plan.md" <<'EOF'
# Task d1-starlist

## Goal
D1 star list bullet fixture

### Phase 1: one
- [x] step
* **Status:** complete
EOF

# T01 基本面: rc=0, stdout 摘要, INDEX.md 落盘, stderr 无噪声
# [task-v176/D1] F6/F7 入列后: complete=2(F1+F7) in_progress=3(F2+F4+F6) pending=1(F3)
call "$P"
if [ "$RC" = 0 ] && printf '%s' "$COUT" | grep -q '^\[index\] Wrote .*/INDEX.md (in_progress=3 pending=1 complete=2)$' \
   && [ -f "$IDX" ] && [ -z "$CERR" ]; then pass 01; else fail 01 "rc=$RC out=$COUT err=$CERR"; fi

# T02 头部+表头结构(逐字节)
if [ "$(sed -n '1p' "$IDX")" = "# Task Index" ] \
   && [ "$(sed -n '2p' "$IDX")" = "<!-- Auto-generated by sync-todos.sh --index. 勿手改，重跑脚本刷新。 -->" ] \
   && sed -n '3p' "$IDX" | grep -q '^<!-- Last refreshed: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}:[0-9]\{2\} -->$' \
   && grep -qF '> 恢复时先读本文件：in_progress=中断待续 / pending=未开始 / complete=已完成。' "$IDX" \
   && grep -qFx '| Task ID | Status | Phase 进度 | Goal | session_id | worktree | scope_files | 最后更新 | 待办 |' "$IDX" \
   && grep -qFx '|---------|--------|-----------|------|---------|------|' "$IDX"; then
  pass 02
else
  fail 02 "head=$(sed -n '1,12p' "$IDX" | tr '\n' '/')"
fi

# T03 行数=6(F1-F4+F6+F7, 归档排除)+每行态枚举合法
# [task-v176/D1] 原 4 行, F6/F7 新增两在途夹具 → 6
ROWS="$(grep -c '^| task-' "$IDX")"
BADROWS="$(grep '^| task-' "$IDX" | grep -Evc '^\| task-[0-9-]+ \| (complete|in_progress|pending) \| [0-9]+/[0-9]+ \| ')"
if [ "$ROWS" = 6 ] && [ "$BADROWS" = 0 ]; then pass 03; else fail 03 "rows=$ROWS bad=$BADROWS"; fi

# T04 complete: 表行字段齐(含 scope 允许+禁止列全收)+落已完成区+不落待处理区
R4="$(row_of task-20260920-111101)"
DONE_SEC="$(sec 已完成 汇总)"
TODO_SEC="$(sec 待处理 已完成)"
if [ "$R4" = "| task-20260920-111101 | complete | 2/2 | Complete task goal line | sess-complete | /wt/complete | a1.sh,b1.sh,a2.md,b2.md | DATE | ✓ |" ] \
   && printf '%s' "$DONE_SEC" | grep -qE '^- task-20260920-111101 ✓ \(2/2\) — [0-9]{4}-[0-9]{2}-[0-9]{2}$' \
   && ! printf '%s' "$TODO_SEC" | grep -q 'task-20260920-111101'; then
  pass 04
else
  fail 04 "row=$R4 done=$(printf '%s' "$DONE_SEC" | tr '\n' '/')"
fi

# T05 in_progress 待处理行形(括号注记 status 计入 in_progress; 无 scope 区段→空单元格;
# 行形断言用 grep -e 防 '- ' 开头被解析为选项)
if [ "$(row_of task-20260921-111102)" = "| task-20260921-111102 | in_progress | 1/3 | Active task goal line | sess-active | /wt/active |  | DATE | ⚠ 续 |" ] \
   && printf '%s' "$TODO_SEC" | grep -qxF -e '- **task-20260921-111102** — in_progress, Phase 1/3（中断恢复首选）'; then
  pass 05
else
  fail 05 "row=$(row_of task-20260921-111102)"
fi

# T06 pending 待处理行形+无 frontmatter → sid=none, wt/scope 空格占位
if [ "$(row_of task-20260922-111103)" = "| task-20260922-111103 | pending | 0/2 | Pending task goal | none |  |  | DATE | ⚠ 未开始 |" ] \
   && printf '%s' "$TODO_SEC" | grep -qxF -e '- **task-20260922-111103** — pending, 未开始 (0/2)'; then
  pass 06
else
  fail 06 "row=$(row_of task-20260922-111103)"
fi

# T07 goal 注释剥离+前导空白剥离+50 截断; scope 12 条→头 10 条逗号 join; 小写 status 计数
GEXP="${G58:0:50}"
SEXP="$(printf 'r%s.sh,x%s.sh,' 01 01 02 02 03 03 04 04 05 05 | sed 's/,$//')"
if [ "$(row_of task-20260923-111104)" = "| task-20260923-111104 | in_progress | 1/2 | ${GEXP} | sess-rich | /wt/rich | ${SEXP} | DATE | ⚠ 续 |" ]; then
  pass 07
else
  fail 07 "row=$(row_of task-20260923-111104) sexp=$SEXP"
fi

# [2026-10-15 task-v176/D1] T08 撤回注记夹具: 注记含 complete 字样的 in_progress
# 行不得翻 complete(原 write_index contains 匹配失真点)。
# 断言: F6 表行 in_progress 1/2 + 待处理区 in_progress 行 + 汇总 complete 计数
# 仍=2(仅 F1+F7, F6 注记的 complete 字样未计入) + 未落已完成区。
if [ "$(row_of task-20260925-111106)" = "| task-20260925-111106 | in_progress | 1/2 | D1 retract note fixture | none |  |  | DATE | ⚠ 续 |" ] \
   && printf '%s' "$TODO_SEC" | grep -qxF -e '- **task-20260925-111106** — in_progress, Phase 1/2（中断恢复首选）' \
   && grep -qFx -- '- in_progress: 3 | pending: 1 | complete: 2' "$IDX" \
   && ! printf '%s' "$DONE_SEC" | grep -q 'task-20260925-111106'; then
  pass 08
else
  fail 08 "row=$(row_of task-20260925-111106) summary=$(grep '^## 汇总' -A2 "$IDX" | tail -1)"
fi

# [2026-10-15 task-v176/D1] T09 星号列表符 '* **Status:**' 双入口跨口径一致:
# 原 forward_sync 仅锚 '- '(捕获不到) 而 write_index 无行首锚(计 complete)——同工具
# 一结论分裂。统一行首列表锚后: --index 记 complete 1/1, 且 sync-todos(非 --index)
# 报告同样输出 complete(同一判定梯)。
FWD_HUMAN="$(bash "$SYNC" "$P" 2>"$TMP/fwd_err")"; FWD_RC=$?
FWD_JSON="$(bash "$SYNC" --json "$P" 2>/dev/null)"
# 期望行形放变量——字符串含 '|' 且跨续行时, 双引号内反斜杠续行会被 bash 按
# 新命令上下文解析(| 报 syntax error), 变量先赋值再引用可完全绕开
EXP7='| task-20260926-111107 | complete | 1/1 | D1 star list bullet fixture | none |  |  | DATE | ✓ |'
if [ "$(row_of task-20260926-111107)" = "$EXP7" ] \
   && printf '%s' "$FWD_HUMAN" | grep -qF '[sync-todos] task-20260926-111107 | Phase 1 | complete | task-20260926-111107/Phase 1: one' \
   && printf '%s' "$FWD_JSON" | grep -qF '"task_id":"task-20260926-111107","phase":1,"status":"complete"'; then
  pass 09
else
  fail 09 "row=$(row_of task-20260926-111107) exp=$EXP7 fwd=$FWD_HUMAN json=$FWD_JSON"
fi

# T10 归档夹具: 深度 3 计划在 INDEX 全文零出现(全量重算天然删行, 防 29.6 统计回归)
if ! grep -q 'task-20260924-111105' "$IDX"; then pass 10; else fail 10 "$(grep -n 'task-20260924-111105' "$IDX")"; fi

# T11 汇总行计数
# [task-v176/D1] F6/F7 入列后: in_progress=3(F2+F4+F6) pending=1(F3) complete=2(F1+F7)
if grep -qFx -- '- in_progress: 3 | pending: 1 | complete: 2' "$IDX"; then pass 11; else fail 11 "$(grep '^## 汇总' -A2 "$IDX" | tail -1)"; fi

# T13 mtime 反映文件真实状态(v3 全量重算口径: 无 mtime 缓存/跳过, touch 即生效)
# [2026-10-15 task-v176/T24] 改用 P2 独立副本: 原实现 touch 共享 P 内文件并 call "$P"
# 回写主 $IDX, 而 T12 空 plans fail-open 的 call "$EMPTY" 会把 $IDX 覆写为
# _No tasks found_——T13 必须前移至 T12 之前并基于独立 P2, 隔离后断言语义不变:
# P2 仅改 F3 mtime, 行序/计数与主 $IDX 同构。
P2="$(mktemp -d "$TMP/fixture2.XXXX")/plans"
IDX2="$P2/INDEX.md"
mkdir -p "$P2/task-20260920-111101" "$P2/task-20260921-111102" "$P2/task-20260922-111103" \
         "$P2/task-20260923-111104" "$P2/task-20260925-111106" "$P2/task-20260926-111107"
for d in task-20260920-111101 task-20260921-111102 task-20260922-111103 \
         task-20260923-111104 task-20260925-111106 task-20260926-111107; do
  cp "$P/$d/task_plan.md" "$P2/$d/task_plan.md"
done
touch -d '2020-01-01 12:00' "$P2/task-20260922-111103/task_plan.md"
call "$P2"
if grep -F 'task-20260922-111103' "$IDX2" | grep -qF '| 2020-01-01 |'; then pass 13; else fail 13 "$(grep -F 'task-20260922-111103' "$IDX2" | head -1)"; fi

# T14 行序=find 路径字典序(与旧实现 sort 口径一致)
# [task-v176/D1] F6/F7(111106/111107)入列后行序尾部顺延
# [task-v176/T24] 前移至 T12 空 plans fail-open 之前——T12 的 call "$EMPTY"
# 会覆写 $IDX, 故行序断言基于 T13(P2 副本) 重建的 IDX2。
ORDER="$(grep '^| task-' "$IDX2" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | tr '\n' ' ')"
if [ "$ORDER" = "task-20260920-111101 task-20260921-111102 task-20260922-111103 task-20260923-111104 task-20260925-111106 task-20260926-111107 " ]; then
  pass 14
else
  fail 14 "order=$ORDER"
fi

# T15 待处理区仅 in_progress/pending 且字段形完整(消费方 check-conflicts.sh:97 依赖 ^- \*\*)
# [task-v176/T24] 前移理由同 T14; 基于 T13 重建的 IDX2 待处理区断言
# [task-v176/D1] F6(in_progress)入待处理区 → NTODO=4(F2+F3+F4+F6)
TODO_SEC2="$(sed -n '/^## 待处理/,/^## 已完成/p' "$IDX2")"
BADTODO="$(printf '%s' "$TODO_SEC2" | grep '^- \*\*' | grep -Evc '^- \*\*task-[0-9-]+\*\* — (in_progress, Phase [0-9]+/[0-9]+（中断恢复首选）|pending, 未开始 \([0-9]+/[0-9]+\))$')"
NTODO="$(printf '%s' "$TODO_SEC2" | grep -c '^- \*\*')"
if [ "$NTODO" = 4 ] && [ "$BADTODO" = 0 ]; then pass 15; else fail 15 "n=$NTODO bad=$BADTODO"; fi

# T12 空 plans fail-open: 写 _No tasks found_ 而非报错
# [task-v176/T24] 后移至 T13/T14/T15 之后——call "$EMPTY" 会把共享 $IDX 覆写为
# _No tasks found_, 必须在所有基于 $IDX 的断言完成后执行(断言本身只读 $EMPTY/INDEX.md,
# 语义不变)
EMPTY="$TMP/empty/plans"; mkdir -p "$EMPTY"
call "$EMPTY"
if [ "$RC" = 0 ] && grep -qF "_No tasks found under $EMPTY" "$EMPTY/INDEX.md"; then pass 12; else fail 12 "rc=$RC out=$COUT"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
