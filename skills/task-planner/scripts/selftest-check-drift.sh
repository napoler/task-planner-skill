#!/usr/bin/env bash
# selftest-check-drift.sh — task-v092/S12: check-drift.sh 三 quirk(3a/3b/3c)修复行为级回归
# 被测对象: check-drift.sh check_phase_order(3a 初值误报, S8=f3966eb 修, 初值 "pending"→"none",
# 现 :132)与 check_scope_breach(3b/3c 区间式提取恒空+禁止列反向风险, S9=11c294c 修, 接
# lib/plan-parse.sh plan_parse_scope 列限形态)。每夹具在 /tmp mktemp 唯一目录动态构造最小
# task_plan.md/progress.md(禁固定路径跨运行污染, v078 教训), 实跑被测脚本断言 stdout 关键
# 字面 + 退出码。正反双向: 正向锁「修复后不再误报/fail-open 保持」, 反向锁「真越级仍报警/
# 越权文件仍报出」——修复不得削弱报警能力。断言均为 rc+字面计数, 非恒真恒假(负向验证法:
# 以 CD_TARGET 指向 :132 初值临时还原为 "pending" 的 /tmp 副本, CD-01/CD-02 必须转红,
# 见 findings.md S12 节)。任一 FAIL exit 1。只读被测脚本, 写入仅 /tmp, 退出清理。
#   CD-01 3a 正向: 全 complete 计划 → 无 CRITICAL PHASE-SKIP + INFO PHASE-ORDER + rc=0
#   CD-02 3a 正向: complete,in_progress,pending 正常推进态(S8 实证缺陷面 fixture-c)
#          → 无 CRITICAL PHASE-SKIP + INFO PHASE-ORDER + rc=0
#   CD-03 3a 反向: pending,complete,pending 真越级 → CRITICAL PHASE-SKIP 恰 1 条 + rc=1
#          (报警不削弱; 另 S8 probe-e pending,pending,complete 同路径, 不重复设案)
#   CD-04 3b 正向: 三列范围表(允许列含逗号清单+禁止列点分路径) + progress 越权引用
#          → BREACH 报出且禁止列文件(forbidden/secret.py, hack/evil.py)在报文内、
#            允许列 src/main.py 不误报(S9 列限提取+反向风险修复语义)、rc=1
#   CD-05 3b 负向(fail-open 保持): 无范围表计划 + progress 含文件引用 → INFO SCOPE-NONE
#          + rc=0(无表不因此判漂移)
#   CD-06 两列表(仅允许列)越权 → BREACH 报出 hack/evil.py、允许列 src/main.py 不误报、rc=1
# CD_TARGET 环境变量可指向被测脚本副本(默认本目录 check-drift.sh), 仅供负向验证用;
# 副本须自带 lib/plan-parse.sh(check-drift 以脚本自身绝对路径 source 统一库)。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${CD_TARGET:-$SCRIPT_DIR/check-drift.sh}"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'CD-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'CD-%s FAIL %s\n' "$1" "$2"; }
diag() { printf '  detail: %s\n' "$1"; }

OUT=""; RC=0
ROOT="$(mktemp -d /tmp/drift-selftest.XXXXXX)"
trap 'rm -rf "$ROOT"' EXIT

# mk_case <name> <s1> <s2> <s3> <scope 段|-> <progress 文本>: 写夹具并实跑被测脚本
#   计划骨架刻意最小化以隔离被测检查: Goal 不足 10 字走 GOAL-EMPTY 短路、无 VC-N 条目、
#   无 Errors 表——其余四项检查全落 INFO/静默且不计分, 不污染被测断言面。
mk_case() {
    local name="$1" s1="$2" s2="$3" s3="$4" scope="$5" progress="$6"
    local d="$ROOT/$name"
    mkdir -p "$d"
    {
        printf '# Task: drift-selftest %s\n\n' "$name"
        printf '## Goal\n占位\n\n'
        if [[ "$scope" != "-" ]]; then printf '%s\n\n' "$scope"; fi
        printf '## Phases\n\n'
        printf '### Phase 1: 实施\n**Status:** %s\n\n' "$s1"
        printf '### Phase 2: 验证\n**Status:** %s\n\n' "$s2"
        printf '### Phase 3: 收尾\n**Status:** %s\n\n' "$s3"
        printf '## Key Questions\n- 无\n'
    } > "$d/task_plan.md"
    printf '%s\n' "$progress" > "$d/progress.md"
    : > "$d/findings.md"
    OUT="$(bash "$TARGET" "$d/task_plan.md" "$d/progress.md" "$d/findings.md" 2>"$d/stderr.txt")"
    RC=$?
}

# 三列范围表: 第 3 字段=允许列(含逗号清单), 第 4 字段=禁止列(点分路径)——
# S9 列限(maxcol=3)下禁止列不入 allowed 清单, 禁止列文件被 progress 引用时必须报 BREACH
SCOPE3='## ⚠️ 执行范围限制

| 类别 | 允许 | 禁止 |
|------|------|------|
| 代码 | src/main.py, src/util.py | forbidden/secret.py, hack/*.py |
| 文档 | docs/guide.md | internal/notes.md |'

# 两列表: 仅类别+允许列(复刻 findings S9 t1 形态: 竖线收尾)
SCOPE2='## ⚠️ 执行范围限制

| 类别 | 允许 |
|------|------|
| 代码 | src/main.py, docs/guide.md |'

# CD-01 3a 正向: 全 complete → 零 PHASE-SKIP 误报, rc=0
mk_case cd01 complete complete complete "-" "- Phase 1 完成
- Phase 2 完成"
if [ "$RC" -eq 0 ] \
   && [ "$(printf '%s\n' "$OUT" | grep -cF 'PHASE-SKIP')" -eq 0 ] \
   && printf '%s\n' "$OUT" | grep -qF '[DRIFT-INFO] PHASE-ORDER: Phase 顺序正常'; then
  ok 01 "全 complete 计划零 PHASE-SKIP 误报, INFO PHASE-ORDER, rc=0"
else
  bad 01 "全 complete 仍误报或 rc 不符(得 rc=$RC)"
  diag "rc=$RC"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CD-02 3a 正向: complete,in_progress,pending 正常推进态(S8 缺陷面) → 零误报, rc=0
mk_case cd02 complete in_progress pending "-" "- Phase 1 完成
- Phase 2 进行中"
if [ "$RC" -eq 0 ] \
   && [ "$(printf '%s\n' "$OUT" | grep -cF 'PHASE-SKIP')" -eq 0 ] \
   && printf '%s\n' "$OUT" | grep -qF '[DRIFT-INFO] PHASE-ORDER: Phase 顺序正常'; then
  ok 02 "complete,in_progress,pending 推进态零误报, INFO PHASE-ORDER, rc=0"
else
  bad 02 "正常推进态仍误报或 rc 不符(得 rc=$RC)"
  diag "rc=$RC"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CD-03 3a 反向: pending,complete,pending 真越级 → CRITICAL 恰 1 条, rc=1
mk_case cd03 pending complete pending "-" "- Phase 1 待启动
- Phase 2 已完成(越级)"
BREACH3="$(printf '%s\n' "$OUT" | grep -F 'PHASE-SKIP' || true)"
if [ "$RC" -eq 1 ] \
   && [ "$(printf '%s\n' "$OUT" | grep -cF 'PHASE-SKIP')" -eq 1 ] \
   && printf '%s' "$BREACH3" | grep -qF '[DRIFT-CRIT] PHASE-SKIP: 发现 phase 越级：在 pending phase 之后直接完成 phase'; then
  ok 03 "真越级仍报 CRITICAL PHASE-SKIP 恰 1 条, rc=1(报警不削弱)"
else
  bad 03 "真越级未报警或计数不符(得 rc=$RC, PHASE-SKIP 行数=$(printf '%s\n' "$OUT" | grep -cF 'PHASE-SKIP'))"
  diag "rc=$RC"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CD-04 3b 正向: 三列表 + 禁止列点分 + progress 越权 → BREACH 含禁止列文件, 允许列不误报
mk_case cd04 complete complete complete "$SCOPE3" "- 修改 src/main.py 完成
- 追加 forbidden/secret.py（越权）
- 追加 hack/evil.py（越权）"
BREACH4="$(printf '%s\n' "$OUT" | grep -F 'SCOPE-BREACH' || true)"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$BREACH4" | grep -qF 'forbidden/secret.py' \
   && printf '%s' "$BREACH4" | grep -qF 'hack/evil.py' \
   && [ "$(printf '%s' "$BREACH4" | grep -cF 'src/main.py')" -eq 0 ]; then
  ok 04 "三列表: 越权+禁止列文件均报 BREACH, 允许列不误报, rc=1(S9 反向风险语义)"
else
  bad 04 "三列表 BREACH 报文不符(得 rc=$RC)"
  diag "rc=$RC; BREACH 行: $BREACH4"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CD-05 3b 负向: 无范围表 + progress 含文件引用 → SCOPE-NONE, rc 不因此变 1(fail-open 保持)
mk_case cd05 complete complete complete "-" "- 修改 src/main.py 完成
- 追加 hack/evil.py"
if [ "$RC" -eq 0 ] \
   && printf '%s\n' "$OUT" | grep -qF '[DRIFT-INFO] SCOPE-NONE' \
   && [ "$(printf '%s\n' "$OUT" | grep -cF 'PHASE-SKIP')" -eq 0 ]; then
  ok 05 "无范围表计划 SCOPE-NONE 跳过, rc=0(fail-open 保持)"
else
  bad 05 "无范围表计划 rc 不符或缺 SCOPE-NONE(得 rc=$RC)"
  diag "rc=$RC"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

# CD-06 两列表越权 → BREACH 报 hack/evil.py, 允许列不误报, rc=1
mk_case cd06 complete complete complete "$SCOPE2" "- 修改 src/main.py 完成
- 追加 hack/evil.py"
BREACH6="$(printf '%s\n' "$OUT" | grep -F 'SCOPE-BREACH' || true)"
if [ "$RC" -eq 1 ] \
   && printf '%s' "$BREACH6" | grep -qF 'hack/evil.py' \
   && [ "$(printf '%s' "$BREACH6" | grep -cF 'src/main.py')" -eq 0 ]; then
  ok 06 "两列表越权报 BREACH 含 hack/evil.py, 允许列不误报, rc=1"
else
  bad 06 "两列表 BREACH 报文不符(得 rc=$RC)"
  diag "rc=$RC; BREACH 行: $BREACH6"; printf '%s\n' "$OUT" | sed 's/^/  out| /'
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
