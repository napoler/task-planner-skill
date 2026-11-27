#!/usr/bin/env bash
# selftest-assertion-guard.sh — 零断言 selftest 必须 FAIL（防假绿门）
# What:
#   扫描目标 selftest 的计数收尾行（兼容存量 Total/直接 PASS=FAIL= 格式）；PASS=0 且 FAIL=0（或缺失计数锚）→ exit 1，否则 exit 0。
#   第二参可选 = 预先捕获的输出文件（run-selftests.sh 复用已执行结果，避免重复跑脚本）。
# Why（2026-11-27 Task4 基线实测）：
#   selftest-user-instruction-priority.sh / selftest-verify-io.sh 断言全过但无机器可读计数，
#   harness 按 PASS=0 FAIL=0 计为通过 = 假绿；本门把"零断言"显式判为验证失败。
# 退出码：0 通过 / 1 零断言（验证失败）/ 2 目标或输出文件非法（用户/环境错误）
set -uo pipefail

TARGET="${1:-}"
[ -n "$TARGET" ] && [ -f "$TARGET" ] || { echo "[assertion-guard] rc2: bad target" >&2; exit 2; }
OUTFILE="${2:-}"
if [ -n "$OUTFILE" ]; then
  [ -f "$OUTFILE" ] || { echo "[assertion-guard] rc2: bad output file" >&2; exit 2; }
  output="$(cat "$OUTFILE")"
else
  output="$(bash "$TARGET" 2>&1)" || true
fi
# 规范行 = "Total: N PASS=x FAIL=y"；存量脚本另有 "Total: N  PASS: x  FAIL: y"、
# "Total: N pass, N fail"、"TOTAL: N PASS / N FAIL" 三种 Total 变体，以及两个无 Total 前缀的
# "结果: PASS=x FAIL=y" / "PASS=x FAIL=y" 收尾行（2026-11-27 实测），故按行取计数锚后再抽数字，
# 避免把真断言脚本误判零断言；仍拒绝完全无计数锚或 PASS/FAIL 双 0 的假绿脚本。
total="$(printf '%s\n' "$output" | grep -iE 'total:' | tail -1 || true)"
[ -z "$total" ] && total="$(printf '%s\n' "$output" | grep -E 'PASS=[0-9]+[[:space:]]+FAIL=[0-9]+' | tail -1 || true)"
[ -n "$total" ] || { echo "[assertion-guard] FAIL: no Total/count line: $TARGET" >&2; exit 1; }
pass_n="$(printf '%s' "$total" | grep -oE 'PASS=[0-9]+' | tail -1 | cut -d= -f2 || true)"
fail_n="$(printf '%s' "$total" | grep -oE 'FAIL=[0-9]+' | tail -1 | cut -d= -f2 || true)"
# Why（2026-11-27 Task4 reviewer Important finding）：
#   原回退式正则同一分支里 `PASS[: ]+n` 与 `n PASS` 并存，`Total: 4  PASS: 0` 时左起先命中
#   `4 PASS`，把 Total 计数当 PASS 数，双 0 被误判有断言（guard rc=0 假绿）。
# What：先抽标签前置 `PASS[:=] n` / `FAIL[:=] n`（数值紧跟标签）；仅缺失时回退数值前置
#   `n PASS` / `n FAIL`，回退取首个匹配，保持 TOTAL: n PASS / n FAIL 等存量格式。
if [ -z "$pass_n" ]; then
  pass_n="$(printf '%s' "$total" | grep -ioE 'PASS[:=][[:space:]]*[0-9]+' | grep -oE '[0-9]+' | tail -1 || true)"
fi
if [ -z "$pass_n" ]; then
  pass_n="$(printf '%s' "$total" | grep -ioE '[0-9]+[[:space:]]+PASS' | grep -oE '[0-9]+' | head -1 || true)"
fi
if [ -z "$fail_n" ]; then
  fail_n="$(printf '%s' "$total" | grep -ioE 'FAIL[:=][[:space:]]*[0-9]+' | grep -oE '[0-9]+' | tail -1 || true)"
fi
if [ -z "$fail_n" ]; then
  fail_n="$(printf '%s' "$total" | grep -ioE '[0-9]+[[:space:]]+FAIL' | grep -oE '[0-9]+' | head -1 || true)"
fi
if [ "${pass_n:-0}" -eq 0 ] && [ "${fail_n:-0}" -eq 0 ]; then
  echo "[assertion-guard] FAIL: zero assertions in $TARGET" >&2; exit 1
fi
echo "[assertion-guard] OK: $total"
exit 0
