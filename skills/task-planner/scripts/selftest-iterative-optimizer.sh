#!/usr/bin/env bash
# selftest-iterative-optimizer.sh — task-v106 P2-S2: 顶层 iterative-optimizer 循环迭代优化 skill 静态守护
# 范式同 selftest-reliability-institution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc 为主），IL-01..IL-08 全 PASS exit 0；任一 FAIL exit 1。
# 断言对象 = 顶层 skills/iterative-optimizer/SKILL.md（相对解析，禁写死绝对路径 S75-D1）。
#   IL-01     文件存在且 frontmatter `name: iterative-optimizer`（head -5 内 grep = 1）
#   IL-02     行数 90-120（wc -l 区间断言, 锁内容漂移膨胀/截断）
#   IL-03     五步锚：「评估 (evaluate)」「诊断弱点 (diagnose」「定向改进 (improve」「门控判定 (gate」各 ≥1
#   IL-04     状态文件锚 `plans/loop-<task-id>-state.md` ≥1
#   IL-05     输入契约锚：「≥3 条」≥1、「机器可检查」≥1、「max_iterations」≥1、「默认 5」≥1
#   IL-06     门控铁律：「禁止宣称 RESOLVED」= 1 且「连续 2 轮」≥1
#   IL-07     迭代摘要表头：「改了什么 (what)」≥1、「为什么 (why」≥1、「门控结果」≥1
#   IL-08     banned 词负断言：`grep -c '更好\|大致\|应该\|足够'` = 0
# 静态只读（grep/wc），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="$SKILL_ROOT/../iterative-optimizer/SKILL.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'IL-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'IL-%s FAIL %s\n' "$1" "$2"; }

# IL-01 文件存在且 frontmatter name 锚
if [ -f "$TARGET" ] && [ "$(head -5 "$TARGET" | grep -c 'name: iterative-optimizer' || true)" -eq 1 ]; then
  ok 01 "iterative-optimizer/SKILL.md 存在且 frontmatter「name: iterative-optimizer」=1"
else
  bad 01 "iterative-optimizer/SKILL.md 缺失或 frontmatter name 锚缺失"
fi
# IL-02 行数 90-120 区间断言
n="$(wc -l < "$TARGET" 2>/dev/null || echo 0)"
if [ "$n" -ge 90 ] && [ "$n" -le 120 ]; then ok 02 "SKILL.md 行数 $n ∈ [90,120]"; else bad 02 "SKILL.md 行数 $n（应 90-120）"; fi
# IL-03 五步锚（评估/诊断弱点/定向改进/门控判定）各 ≥1
a="$(grep -c '评估 (evaluate)' "$TARGET" || true)"
b="$(grep -c '诊断弱点 (diagnose' "$TARGET" || true)"
c="$(grep -c '定向改进 (improve' "$TARGET" || true)"
d="$(grep -c '门控判定 (gate' "$TARGET" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 03 "五步锚在位（评估 $a / 诊断弱点 $b / 定向改进 $c / 门控判定 $d, 各 ≥1）"
else
  bad 03 "五步锚漂移（评估=$a 诊断弱点=$b 定向改进=$c 门控判定=$d, 应各 ≥1）"
fi
# IL-04 状态文件锚
n="$(grep -c 'plans/loop-<task-id>-state\.md' "$TARGET" || true)"
if [ "$n" -ge 1 ]; then ok 04 "状态文件锚 plans/loop-<task-id>-state.md 行 $n ≥1"; else bad 04 "状态文件锚缺失（命中 $n 应 ≥1）"; fi
# IL-05 输入契约锚（≥3 条 / 机器可检查 / max_iterations / 默认 5）
a="$(grep -c '≥3 条' "$TARGET" || true)"
b="$(grep -c '机器可检查' "$TARGET" || true)"
c="$(grep -c 'max_iterations' "$TARGET" || true)"
d="$(grep -c '默认 5' "$TARGET" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ] && [ "$d" -ge 1 ]; then
  ok 05 "输入契约锚在位（≥3 条 $a / 机器可检查 $b / max_iterations $c / 默认 5 $d, 各 ≥1）"
else
  bad 05 "输入契约锚漂移（≥3 条=$a 机器可检查=$b max_iterations=$c 默认 5=$d, 应各 ≥1）"
fi
# IL-06 门控铁律：禁止宣称 RESOLVED = 1 且 连续 2 轮 ≥1
a="$(grep -c '禁止宣称 RESOLVED' "$TARGET" || true)"
b="$(grep -c '连续 2 轮' "$TARGET" || true)"
if [ "$a" -eq 1 ] && [ "$b" -ge 1 ]; then
  ok 06 "门控铁律在位（禁止宣称 RESOLVED=1 且 连续 2 轮 $b ≥1）"
else
  bad 06 "门控铁律漂移（禁止宣称 RESOLVED=$a 应 1 / 连续 2 轮=$b 应 ≥1）"
fi
# IL-07 迭代摘要表头锚
a="$(grep -c '改了什么 (what)' "$TARGET" || true)"
b="$(grep -c '为什么 (why' "$TARGET" || true)"
c="$(grep -c '门控结果' "$TARGET" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ] && [ "$c" -ge 1 ]; then
  ok 07 "迭代摘要表头在位（改了什么 (what) $a / 为什么 (why $b / 门控结果 $c, 各 ≥1）"
else
  bad 07 "迭代摘要表头漂移（改了什么 (what)=$a 为什么 (why=$b 门控结果=$c, 应各 ≥1）"
fi
# IL-08 banned 词负断言
n="$(grep -c '更好\|大致\|应该\|足够' "$TARGET" || true)"
if [ "$n" -eq 0 ]; then ok 08 "banned 词（更好/大致/应该/足够）命中 0"; else bad 08 "banned 词命中 $n（应 0）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
