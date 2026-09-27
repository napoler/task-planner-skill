#!/usr/bin/env bash
# selftest-registry.sh — task-v091/S25 C-4: selftest 分域 registry(selftest-registry.tsv)一致性自守护
# [2026-09-27 task-v091 S25] 提案 C-4「registry 一致性自守护断言」的最小实现(独立小脚本形态,
# 非既建 selftest 内嵌段): 双向核对 TSV 与本目录实际 selftest-*.sh 清单——
#   T01 TSV 在位 + 表头 4 列(script/domain/trigger_scenarios/dep_anchors)
#   T02 无缺失: 每个实际 selftest-*.sh 都有 registry 行(新增未登记→FAIL)
#   T03 无孤儿: 每个 registry 行指向存在的脚本(改名/删除残留旧行→FAIL, 提案验证设计③)
#   T04 无重复行
#   T05 字段完整: 每行恰 4 个 tab 字段且无空单元格
# 本脚本已在 registry 末行自登记("self-registered"); 增删/改名任何 selftest-*.sh 必须同步
# TSV, 否则本守护 FAIL。守护自身不递归(仅读 TSV 与 ls, 不做任何写操作)。
# 全 PASS exit 0; 任一 FAIL exit 1。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV="$SCRIPT_DIR/selftest-registry.tsv"
HDR_EXP='script	domain	trigger_scenarios	dep_anchors'
PASS=0; FAIL=0
pass() { PASS=$((PASS+1)); printf 'T%s PASS\n' "$1"; }
fail() { FAIL=$((FAIL+1)); printf 'T%s FAIL %s\n' "$1" "$2"; }

# T01 TSV 在位 + 表头
if [ -f "$TSV" ] && [ "$(head -1 "$TSV")" = "$HDR_EXP" ]; then
  pass 01
else
  fail 01 "tsv 缺失或表头错误: $TSV"
fi

if [ -f "$TSV" ]; then
  ACTUAL="$(cd "$SCRIPT_DIR" && ls selftest-*.sh 2>/dev/null | sort)"
  ROWS="$(awk -F'\t' 'NR>1{print $1}' "$TSV" | sort)"

  # T02 无缺失: 实际脚本未登记
  MISSING="$(comm -23 <(printf '%s\n' "$ACTUAL") <(printf '%s\n' "$ROWS") | tr '\n' ' ')"
  if [ -z "$MISSING" ]; then pass 02; else fail 02 "未登记: $MISSING"; fi

  # T03 无孤儿: registry 行指向不存在的脚本
  ORPHAN="$(comm -13 <(printf '%s\n' "$ACTUAL") <(printf '%s\n' "$ROWS") | tr '\n' ' ')"
  if [ -z "$ORPHAN" ]; then pass 03; else fail 03 "孤儿行: $ORPHAN"; fi

  # T04 无重复行
  DUPES="$(printf '%s\n' "$ROWS" | uniq -d | tr '\n' ' ')"
  if [ -z "$DUPES" ]; then pass 04; else fail 04 "重复行: $DUPES"; fi

  # T05 字段完整: 每行恰 4 字段且无空单元格
  BADF="$(awk -F'\t' 'NR>1{bad=0; if(NF!=4) bad=1; for(i=1;i<=NF;i++) if($i=="") bad=1; if(bad){print NR; exit}}' "$TSV")"
  if [ -z "$BADF" ]; then pass 05; else fail 05 "字段缺陷行: $BADF"; fi

  printf 'Total: %d PASS=%d FAIL=%d (registry rows=%d, actual selftest=%d)\n' \
    "$((PASS+FAIL))" "$PASS" "$FAIL" \
    "$(printf '%s\n' "$ROWS" | grep -c .)" "$(printf '%s\n' "$ACTUAL" | grep -c .)"
fi
exit $((FAIL > 0))
