#!/usr/bin/env bash
# selftest-methodology.sh — task-v063 Phase6/S1: methodology 门控面 hermetic 守护套件
# 守护 v063 引入的 FMEA/内容质量门控嵌入点 (config 两键 + methodology.md + 模板/指针):
#   M-01 config.json 两键存在 (fmea_enforce + content_quality_enforce 均在 .properties)
#   M-02 两键默认值=warn 且 enum 含 enforce/warn/off (default=warn, enum 长度=3)
#   M-03 methodology.md 存在且含 9 条方法名关键词 (Poka-Yoke/FMEA/… ≥9)
#   M-04 模板 FMEA 段在位 (task_plan.md "FMEA 预演"=1 + RPN 表 7 列 "RPN=S×O×D" ≥1)
#   M-05 writing-type.md 质量门控指针在位 ("五维评分卡"=1)
#   M-06 SKILL.md 3 处指针在位 (grep -c "methodology" ≥3)
#   M-07 README 键说明 21 项在位 ("21 项"=1 + 两键名 grep ≥2)
# hermetic: mktemp 夹具 = 真实 worktree 文件最小镜像 (<root>/skills/task-planner/… cp 而来),
# 用例只对 fixture 跑, 不污染真实仓且防 CWD 依赖; trap 清理; 对真实文件只读。
# 7 用例全 PASS exit 0; 任一 FAIL exit 1。幂等: 连跑两遍结果一致 (fixture 每次重建)。

set -u

# 真实仓文件定位: 本脚本在 <root>/skills/task-planner/scripts/ 内, 真实根 = SCRIPT_DIR/..
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

PASS=0; FAIL=0

assert() {
  # assert <m_num> <desc> <cond_rc: 0=pass>
  local num="$1" desc="$2" rc="$3"
  if [ "$rc" -eq 0 ]; then
    PASS=$((PASS+1)); printf 'M-%s PASS %s\n' "$num" "$desc"
  else
    FAIL=$((FAIL+1)); printf 'M-%s FAIL %s\n' "$num" "$desc"
  fi
}

# 夹具: 真实文件最小镜像 (仅 cp, 不动真实仓)
FIX="$TMP/skills/task-planner"
mkdir -p "$FIX/references" "$FIX/templates/variant"
cp "$REAL_ROOT/config.json"              "$FIX/config.json"
cp "$REAL_ROOT/SKILL.md"                 "$FIX/SKILL.md"
cp "$REAL_ROOT/README.md"                "$FIX/README.md"
cp "$REAL_ROOT/references/methodology.md" "$FIX/references/methodology.md"
cp "$REAL_ROOT/templates/task_plan.md"   "$FIX/templates/task_plan.md"
cp "$REAL_ROOT/templates/variant/writing-type.md" "$FIX/templates/variant/writing-type.md"
CFG="$FIX/config.json"

# M-01: config.json 两键存在
M01_RC=1
jq -e '.properties.fmea_enforce and .properties.content_quality_enforce' "$CFG" >/dev/null 2>&1
M01_RC=$?
assert 01 "config 两键存在" "$M01_RC"

# M-02: 两键 default=warn 且 enum 长度=3 (含 enforce/warn/off)
M02_RC=1
if [ "$(jq -r '.properties.fmea_enforce.default' "$CFG")" = "warn" ] \
   && [ "$(jq -r '.properties.content_quality_enforce.default' "$CFG")" = "warn" ] \
   && [ "$(jq -r '.properties.fmea_enforce.enum | length' "$CFG")" = "3" ] \
   && [ "$(jq -r '.properties.content_quality_enforce.enum | length' "$CFG")" = "3" ]; then
  M02_RC=0
fi
assert 02 "两键 default=warn 且 enum 长度=3" "$M02_RC"

# M-03: methodology.md 含 9 条方法名关键词
KCNT="$(grep -c "Poka-Yoke\|FMEA\|checkpoint\|三级引用\|交叉验证\|去 AI 化\|五维评分卡\|8 字段\|chunk" "$FIX/references/methodology.md" 2>/dev/null)"
[ "${KCNT:-0}" -ge 9 ]
M03_RC=$?
assert 03 "methodology.md 方法名关键词 ≥9 (实测 ${KCNT:-0})" "$M03_RC"

# M-04: 模板 FMEA 段在位
N_A="$(grep -c "FMEA 预演" "$FIX/templates/task_plan.md" 2>/dev/null)"
N_B="$(grep -c "RPN=S×O×D" "$FIX/templates/task_plan.md" 2>/dev/null)"
[ "${N_A:-0}" -eq 1 ] && [ "${N_B:-0}" -ge 1 ]
M04_RC=$?
assert 04 "模板 FMEA 段在位 (预演=1, RPN 7 列表头 ${N_B:-0})" "$M04_RC"

# M-05: writing-type.md 质量门控指针
N_C="$(grep -c "五维评分卡" "$FIX/templates/variant/writing-type.md" 2>/dev/null)"
[ "${N_C:-0}" -eq 1 ]
M05_RC=$?
assert 05 "writing-type.md 五维评分卡指针" "$M05_RC"

# M-06: SKILL.md 3 处 methodology 指针
N_D="$(grep -c "methodology" "$FIX/SKILL.md" 2>/dev/null)"
[ "${N_D:-0}" -ge 3 ]
M06_RC=$?
assert 06 "SKILL.md methodology 指针 ≥3 (实测 ${N_D:-0})" "$M06_RC"

# M-07: README 键说明 21 项在位
N_E="$(grep -c "21 项" "$FIX/README.md" 2>/dev/null)"
N_F="$(grep -c "fmea_enforce\|content_quality_enforce" "$FIX/README.md" 2>/dev/null)"
[ "${N_E:-0}" -eq 1 ] && [ "${N_F:-0}" -ge 2 ]
M07_RC=$?
assert 07 "README 21 项说明 (实测 ${N_E:-0}/${N_F:-0})" "$M07_RC"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
