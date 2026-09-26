#!/usr/bin/env bash
# selftest-rule23-conflict-scan.sh — task-v091 C-1a② 前置: Rule 23 运行时并发冲突扫描行为级自测
# 被测对象: zcode-pretooluse.sh Rule 23 冲突扫描段(Write/Edit 分支; cwd 取 stdin .cwd, task-v091 C-1a① 已改)
# 每夹具在 /tmp 独立目录构造最小环境(plans/<id>/task_plan.md 桩 + stdin JSON 含 cwd/session_id/tool_input.file_path),
# 实跑被测脚本断言 stdout。stdin 必含 session_id——缺省落 default 会被委派门控(check-delegation.sh pretool)
# 拦截, Rule 23 段执行不到。
# 期待值编码「应然行为」(对齐 zcode-pretooluse.sh:6 起草语义「写入文件是否命中其他 in_progress plan 的 scope」;
# 完结判定字段/取值对齐 zcode-posttooluse.sh:100-105 grep -qiE 'outcome: *(COMPLETE|BLOCKED)')。
# 这是 C-1a② 改动前的行为基线捕捉: 现行实现与期待不符时如实记 FAIL, 不迁就实现改期待。
#   R23-01 并发在途计划: 第二计划(非 COMPLETE)scope 含被写文件 → 期待 stdout 含 [conflict]
#   R23-02 完结计划豁免: 第二计划 outcome: COMPLETE → 期待 stdout 不含 [conflict]
#   R23-03 无指针过期在途计划: 3 天前 mtime 的在途计划、无任何 active_plan 指针 → 期待仍被扫到(含 [conflict])
# 已知基线观察(2026-09-27, gawk 5.2.1): 现行实现 R23-01/R23-03 FAIL —— pretooluse:105/:110 的
#   awk /\\.[a-zA-Z]/ 中 `\\.` 被解析为「字面反斜杠+任意字符」, 普通点分路径(src/main.py)不命中,
#   other_scope 恒空 → [conflict] 不产出; R23-02 由此空转 PASS。C-1a② 修复提取与完结过滤后应 3/3 PASS。
# 3 断言全 PASS exit 0; 任一 FAIL exit 1。只读被测脚本, 写入仅 /tmp 夹具, 退出清理。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRETOOL="$SCRIPT_DIR/zcode-pretooluse.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'R23-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'R23-%s FAIL %s\n' "$1" "$2"; }
diag() { printf '  detail: %s\n' "$1"; }

# ── 夹具工具 ─────────────────────────────────────────────────────────────────
# make_plan <plans_dir> <task_id> <scope_file> <extra_header_line>
# task_plan.md 桩: 头部(session_id + 可选状态行) + 「## 执行范围限制」表格
# (scope_file 落第 3 列, 对齐 pretooluse 提取 awk 的 for(i=3;i<=NF) 起点)
make_plan() {
    local plans="$1" id="$2" scope_file="$3" extra="${4:-}"
    mkdir -p "$plans/$id"
    {
        printf '# task_plan: %s\n' "$id"
        printf 'session_id: sess-fixture-%s\n' "$id"
        if [ -n "$extra" ]; then printf '%s\n' "$extra"; fi
        printf '\n## 执行范围限制\n\n'
        printf '| # | 文件路径 | 操作 |\n'
        printf '|---|---------|------|\n'
        printf '| 1 | %s | 修改 |\n' "$scope_file"
    } > "$plans/$id/task_plan.md"
}

# build_fixture <root> <second_id> <second_extra_line> [second_age]
# 当前计划 task-cur(scope 不含被写文件, mtime=now 保 ls -t newest → 充当 $plan);
# 第二计划 scope 含 src/main.py(被写文件), mtime 调旧 → 稳定落入 other_plan 循环
build_fixture() {
    local root="$1" second_id="$2" second_extra="$3" second_age="${4:-2 hours ago}"
    make_plan "$root/plans" task-cur "src/other.py" ""
    make_plan "$root/plans" "$second_id" "src/main.py" "$second_extra"
    touch -d "$second_age" "$root/plans/$second_id/task_plan.md"
}

# run_fixture <root> → 打印被测脚本 stdout(stderr 落 $root/stderr.txt 供诊断)
# cwd=夹具根(hermetic): check-scope 无哨兵放行; 委派门控因 sid 非 default → 观察模式放行, 不触碰 WT 配置
run_fixture() {
    local root="$1"
    local sid="sess-selftest-r23-${root##*/}"   # 每夹具独立 sid, 防 observe 节流 flag 串场
    local stdin_json
    stdin_json="$(jq -n --arg cwd "$root" --arg file "$root/src/main.py" --arg sid "$sid" \
        '{session_id:$sid, cwd:$cwd, tool_name:"Write", tool_input:{file_path:$file}}')"
    ( cd "$root" && printf '%s' "$stdin_json" | bash "$PRETOOL" 2>"$root/stderr.txt" )
}

R1=""; R2=""; R3=""
cleanup() {
    [ -n "$R1" ] && rm -rf "$R1"
    [ -n "$R2" ] && rm -rf "$R2"
    [ -n "$R3" ] && rm -rf "$R3"
    return 0
}
trap cleanup EXIT

# R23-01 并发在途计划(非 COMPLETE)→ 期待含 [conflict]
R1="$(mktemp -d "${TMPDIR:-/tmp}/r23-selftest-1-XXXXXX")"
build_fixture "$R1" task-second "status: in_progress"
out1="$(run_fixture "$R1")"
if printf '%s' "$out1" | grep -qF '[conflict]'; then
  ok 01 "在途第二计划命中 scope → 报 [conflict]"
else
  bad 01 "在途第二计划未报 [conflict]"
  diag "stderr: $(head -c 160 "$R1/stderr.txt" 2>/dev/null || true)"
fi

# R23-02 完结计划(outcome: COMPLETE, posttooluse:100-105 同款字段/取值)→ 期待不含 [conflict]
R2="$(mktemp -d "${TMPDIR:-/tmp}/r23-selftest-2-XXXXXX")"
build_fixture "$R2" task-done "outcome: COMPLETE"
out2="$(run_fixture "$R2")"
if printf '%s' "$out2" | grep -qF '[conflict]'; then
  bad 02 "完结计划仍报 [conflict]"
  diag "stderr: $(head -c 160 "$R2/stderr.txt" 2>/dev/null || true)"
else
  ok 02 "完结计划被豁免"
fi

# R23-03 无 active_plan 指针的过期在途计划(3 天前 mtime)→ 期待仍被扫到
R3="$(mktemp -d "${TMPDIR:-/tmp}/r23-selftest-3-XXXXXX")"
build_fixture "$R3" task-stale "status: in_progress" "3 days ago"
out3="$(run_fixture "$R3")"
if printf '%s' "$out3" | grep -qF '[conflict]'; then
  ok 03 "无指针过期在途计划仍被扫到"
else
  bad 03 "无指针过期在途计划漏扫"
  diag "stderr: $(head -c 160 "$R3/stderr.txt" 2>/dev/null || true)"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
