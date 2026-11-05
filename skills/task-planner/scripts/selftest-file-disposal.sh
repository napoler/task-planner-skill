#!/usr/bin/env bash
# [2026-11-05 task-trashcan-20261105 S4] selftest-file-disposal.sh — 垃圾桶机制(Rule 100.6)机器守护静态断言套件（FD-01..06）
# WHAT: 机械断言 Rule 100.6「垃圾桶机制（trash/，判废即移）」全链落点 6 组：
#      FD-01 task-discipline critical-rules 含 100.6 垃圾桶机制标题锚
#      FD-02 同文件含「判废即移」+「唯一回取例外」
#      FD-03 media-planner critical-rules 含 Rule 100.6
#      FD-04 variant 两模板含 trash（image-type ≥1；video-type ≥2，Rule 100.6 判废即移语境）
#      FD-05 deprecated.md 含 Rule 100.6；worktree 根 .gitignore 含 ^trash/$ 规则行
#      FD-06 负断言：variant 两模板 + media 规则中「当日归档（-failed」作为处置动作的正向表述 = 0 命中
#           （「禁……-failed」否定引用不算，用 grep -c "当日归档（-failed" = 0 判定）
# WHY: 用户原话铁律——废弃稿件移入 trash/，后期检索排除 trash/；防 -failed 原地堆放回归（事故判例=几十版废弃稿误用）。
# 纪律: 本脚本只做只读静态断言，禁写配置/禁 git 写操作；路径全部用 SCRIPT_DIR 相对推导，禁硬编码绝对路径。
#       全 PASS exit 0, 任一 FAIL exit 1。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                    # <repo>/skills/task-planner
WT_ROOT="$SCRIPT_DIR/../../.."           # worktree 根（.gitignore 所在）
DISCIPLINE_CR="$ROOT/../task-discipline/references/critical-rules-discipline.md"
MEDIA_CR="$ROOT/../media-planner/references/critical-rules-media.md"
IMG_TPL="$ROOT/templates/variant/image-type.md"
VID_TPL="$ROOT/templates/variant/video-type.md"
DEPR_TPL="$ROOT/templates/deprecated.md"
WT_GITIGNORE="$WT_ROOT/.gitignore"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}
# td: 带诊断输出的断言（失败时打印缺失文件/锚，不吞 stderr）
td() { # td <name> <bash-expr-string> [diag-msg]
    local name="$1" expr="$2" diag="${3:-}"
    if bash -c "$expr" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
        [ -n "$diag" ] && echo "  [diag] $diag"
    fi
}

# FD-01: skills/task-discipline/references/critical-rules-discipline.md 含 `100.6 垃圾桶机制`（实际标题 **100.6 垃圾桶机制（...）**）
td "FD-01 task-discipline critical-rules 含 '100.6 垃圾桶机制'" \
   "[ -f '$DISCIPLINE_CR' ] && grep -qF '100.6 垃圾桶机制' '$DISCIPLINE_CR'" \
   "missing file=$DISCIPLINE_CR OR anchor='100.6 垃圾桶机制'"

# FD-02: 同文件含 `判废即移` 且含 `唯一回取例外`
td "FD-02 task-discipline critical-rules 含 '判废即移' 且含 '唯一回取例外'" \
   "[ -f '$DISCIPLINE_CR' ] && grep -qF '判废即移' '$DISCIPLINE_CR' && grep -qF '唯一回取例外' '$DISCIPLINE_CR'" \
   "missing file=$DISCIPLINE_CR OR anchor='判废即移'/'唯一回取例外'"

# FD-03: skills/media-planner/references/critical-rules-media.md 含 `Rule 100.6`
td "FD-03 media-planner critical-rules 含 'Rule 100.6'" \
   "[ -f '$MEDIA_CR' ] && grep -qF 'Rule 100.6' '$MEDIA_CR'" \
   "missing file=$MEDIA_CR OR anchor='Rule 100.6'"

# FD-04: image-type.md 含 `trash`（Rule 100.6 判废即移语境）；video-type.md 含 `trash` 计数 ≥2
td "FD-04a variant/image-type.md 含 'trash' (Rule 100.6 判废即移语境)" \
   "[ -f '$IMG_TPL' ] && grep -qF 'trash' '$IMG_TPL'" \
   "missing file=$IMG_TPL OR anchor='trash'"
_fd04b_n="$(grep -c 'trash' "$VID_TPL" 2>/dev/null)" || _fd04b_n=0
if [ "$_fd04b_n" -ge 2 ]; then
    PASS=$((PASS+1)); echo "[PASS] FD-04b variant/video-type.md 含 'trash' 计数 ≥2 (got=$_fd04b_n)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] FD-04b variant/video-type.md 含 'trash' 计数 ≥2 (got=$_fd04b_n)"
    echo "  [diag] expected count>=2 in $VID_TPL"
    grep -n 'trash' "$VID_TPL" 2>/dev/null | sed 's/^/  [diag] present: /' || true
fi

# FD-05: skills/task-planner/templates/deprecated.md 含 `Rule 100.6`；worktree 根 .gitignore 含 `^trash/$` 规则行
td "FD-05a templates/deprecated.md 含 'Rule 100.6'" \
   "[ -f '$DEPR_TPL' ] && grep -qF 'Rule 100.6' '$DEPR_TPL'" \
   "missing file=$DEPR_TPL OR anchor='Rule 100.6'"
td "FD-05b worktree 根 .gitignore 含 '^trash/$' 规则行" \
   "[ -f '$WT_GITIGNORE' ] && grep -qE '^trash/\$' '$WT_GITIGNORE'" \
   "missing file=$WT_GITIGNORE OR no line matching '^trash/\$'"

# FD-06: 负断言——variant 两模板+media 规则中不存在「-failed 重命名」作为处置动作的正向表述
# （grep -c "当日归档（-failed" 应 0 命中；「禁……-failed」否定引用不算——用该字面 = 0 判定）
_fd06_img="$(grep -c '当日归档（-failed' "$IMG_TPL" 2>/dev/null)" || _fd06_img=0
_fd06_vid="$(grep -c '当日归档（-failed' "$VID_TPL" 2>/dev/null)" || _fd06_vid=0
_fd06_med="$(grep -c '当日归档（-failed' "$MEDIA_CR" 2>/dev/null)" || _fd06_med=0
_fd06_sum=$((_fd06_img + _fd06_vid + _fd06_med))
if [ "$_fd06_sum" -eq 0 ]; then
    PASS=$((PASS+1)); echo "[PASS] FD-06 负断言: 三文件 '当日归档（-failed' 处置动作正向表述=0 (image=$_fd06_img video=$_fd06_vid media=$_fd06_med)"
else
    FAIL=$((FAIL+1)); echo "[FAIL] FD-06 负断言: 三文件 '当日归档（-failed' 处置动作正向表述=0 (got sum=$_fd06_sum image=$_fd06_img video=$_fd06_vid media=$_fd06_med)"
    echo "  [diag] expected 0 hits in $IMG_TPL $VID_TPL $MEDIA_CR"
    grep -n '当日归档（-failed' "$IMG_TPL" "$VID_TPL" "$MEDIA_CR" 2>/dev/null | sed 's/^/  [diag] hit: /' || true
fi

# ── 汇总（Total/exit 语义对齐既有 selftest 范式）──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
