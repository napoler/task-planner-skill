#!/usr/bin/env bash
# selftest-review-library.sh — task-v100 P3-S6: Rule 42 质量审查兜底池（review-library）静态守护
# 范式同 selftest-self-resolution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc/ls 为主），RL-01..RL-13 全 PASS exit 0；任一 FAIL exit 1。
#   RL-01     review-library/ 目录数 = 11（恰 11 目录）[2026-09-30 task-v101 +alignment-review]
#   RL-02     11 个目录名与清单精确一致（逐一 -d 判定）
#   RL-03     每目录含 SKILL.md（11 个 -f 全过）
#   RL-04     每个 SKILL.md frontmatter 含 `name:` 与 `description:`（11×2 grep）
#   RL-05     每个 SKILL.md 含「APPROVED」「CHANGES_REQUESTED」「Rule 43.1」（11×3）
#   RL-06     每个 SKILL.md 清单条目 `grep -c '^- \[ \]'` ≥10（11 个全查,循环,任一不达标即 FAIL）
#   RL-07     每个 SKILL.md 四要素标题（## 触发条件/## 审查清单/## 证据要求/## 输出合约）各 ≥1（11×4）
#   RL-08     SKILL.md（主文件）`grep -c '| C30 |'`=1 且「四级顺序」≥1（C30 四级化同步锚）
#   RL-09     CRIT 42.2 四级化主体锚：行内「task-planner 内置 review-library 兜底池」≥1 且「均未命中=缺口」≥1
#             且 CRIT `grep -c '三级检测顺序'`=0（关键负断言,防三级残留）
#             [task-v100 锚修正: 原文 ④ 与池 token 之间有 `**` 强调符,故主体锚去 ④ 前缀,防假断言]
#   RL-10     全池 11 文件 `grep -nE '1-4[0-9]'` 零命中（越界字面负断言）
#   RL-11     alignment-review 验证优先升级锚：「写入前校验」≥2、「未经一致性校验，不直接追加新内容」=1、「变更记录输出」≥1（task-v102）
#   RL-12     alignment-review 闸门深化锚（task-v104）：「全文扫描」≥1 且「删除或归档」≥1 且「变更范围」≥1（alignment-review/SKILL.md）
#   RL-13     42.6.3 三要素升级锚（task-v104）：CRIT 42.6.3 行「三要素」≥1 且 SKILL.md C32 行「三要素」≥1
# 静态只读（grep/wc/ls），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RLIB="$SKILL_ROOT/review-library"
SKILLMD="$SKILL_ROOT/SKILL.md"
CRIT="$SKILL_ROOT/references/critical-rules.md"

DIRS="general-review code-quality-review test-quality-review security-review image-review content-quality-review documentation-review data-quality-review ui-quality-review release-review alignment-review"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'RL-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'RL-%s FAIL %s\n' "$1" "$2"; }

# RL-01 目录数 = 11
n="$(ls "$RLIB" | wc -l | tr -d ' ')"
if [ "$n" -eq 11 ]; then ok 01 "review-library/ 目录数 = 11"; else bad 01 "review-library/ 目录数 $n（应 11）"; fi
# RL-02 目录名精确一致
missing=""
for d in $DIRS; do [ -d "$RLIB/$d" ] || missing="$missing $d"; done
if [ -z "$missing" ]; then ok 02 "11 个目录名与清单精确一致"; else bad 02 "目录名缺失:$missing"; fi
# RL-03 每目录含 SKILL.md
missf=""
for d in $DIRS; do [ -f "$RLIB/$d/SKILL.md" ] || missf="$missf $d"; done
if [ -z "$missf" ]; then ok 03 "11 目录各含 SKILL.md"; else bad 03 "缺 SKILL.md:$missf"; fi
# RL-04 frontmatter name/description（11×2）
missfm=""
for d in $DIRS; do
  f="$RLIB/$d/SKILL.md"
  [ "$(grep -c '^name:' "$f" || true)" -ge 1 ] && [ "$(grep -c '^description:' "$f" || true)" -ge 1 ] || missfm="$missfm $d"
done
if [ -z "$missfm" ]; then ok 04 "11 个 SKILL.md frontmatter name/description 全在位"; else bad 04 "frontmatter name/description 缺失:$missfm"; fi
# RL-05 APPROVED / CHANGES_REQUESTED / Rule 43.1（11×3）
missv=""
for d in $DIRS; do
  f="$RLIB/$d/SKILL.md"
  if [ "$(grep -c 'APPROVED' "$f" || true)" -ge 1 ] && [ "$(grep -c 'CHANGES_REQUESTED' "$f" || true)" -ge 1 ] && [ "$(grep -c 'Rule 43.1' "$f" || true)" -ge 1 ]; then
    :
  else
    missv="$missv $d"
  fi
done
if [ -z "$missv" ]; then ok 05 "11 个 SKILL.md APPROVED/CHANGES_REQUESTED/Rule 43.1 全在位"; else bad 05 "值锚缺失:$missv"; fi
# RL-06 清单条目 ≥10（循环,任一不达标即 FAIL）
missi=""
for d in $DIRS; do
  f="$RLIB/$d/SKILL.md"
  items="$(grep -c '^- \[ \]' "$f" || true)"
  [ "$items" -ge 10 ] || missi="$missi $d($items)"
done
if [ -z "$missi" ]; then ok 06 "11 个 SKILL.md 清单条目均 ≥10"; else bad 06 "清单条目 <10:$missi"; fi
# RL-07 四要素标题（11×4）
misst=""
for d in $DIRS; do
  f="$RLIB/$d/SKILL.md"
  if [ "$(grep -c '^## 触发条件' "$f" || true)" -ge 1 ] && [ "$(grep -c '^## 审查清单' "$f" || true)" -ge 1 ] &&
     [ "$(grep -c '^## 证据要求' "$f" || true)" -ge 1 ] && [ "$(grep -c '^## 输出合约' "$f" || true)" -ge 1 ]; then
    :
  else
    misst="$misst $d"
  fi
done
if [ -z "$misst" ]; then ok 07 "11 个 SKILL.md 四要素标题全在位"; else bad 07 "四要素标题缺失:$misst"; fi
# RL-08 C30 四级化同步锚（主 SKILL.md）
c="$(grep -c '| C30 |' "$SKILLMD" || true)"
q="$(grep -c '四级顺序' "$SKILLMD" || true)"
if [ "$c" -eq 1 ] && [ "$q" -ge 1 ]; then ok 08 "SKILL.md C30 项 =1 且「四级顺序」$q ≥1"; else bad 08 "SKILL.md C30 项 $c（应 1）或 四级顺序 $q（应 ≥1）"; fi
# RL-09 CRIT 42.2 四级化主体锚 + 三级残留负断言
pool="$(grep -c 'task-planner 内置 review-library 兜底池' "$CRIT" || true)"
gap="$(grep '^42\.2' "$CRIT" | grep -c '均未命中=缺口' || true)"
old="$(grep -c '三级检测顺序' "$CRIT" || true)"
if [ "$pool" -ge 1 ] && [ "$gap" -ge 1 ] && [ "$old" -eq 0 ]; then
  ok 09 "CRIT 42.2 池主体锚 ≥1 / 均未命中=缺口 ≥1 / 三级检测顺序 =0"
else
  bad 09 "CRIT 42.2 锚漂移（池主体 $pool 应 ≥1 / 42.2 行内 均未命中=缺口 $gap 应 ≥1 / 三级检测顺序 $old 应 0）"
fi
# RL-10 越界字面负断言（全池 11 文件）
hits="$(grep -nE '1-4[0-9]' "$RLIB"/*/SKILL.md || true)"
if [ -z "$hits" ]; then ok 10 "全池 11 文件 1-4[0-9] 越界字面零命中"; else bad 10 "全池越界字面命中:$(printf '%s' "$hits" | head -3)"; fi
# RL-11 alignment-review 验证优先升级锚（task-v102）
A="$RLIB/alignment-review/SKILL.md"
g="$(grep -c '写入前校验' "$A" || true)"
h="$(grep -c '未经一致性校验，不直接追加新内容' "$A" || true)"
i="$(grep -c '变更记录输出' "$A" || true)"
if [ "$g" -ge 2 ] && [ "$h" -eq 1 ] && [ "$i" -ge 1 ]; then
  ok 11 "alignment-review 验证优先锚：写入前校验 $g ≥2 / 未经一致性校验 $h =1 / 变更记录输出 $i ≥1"
else
  bad 11 "alignment-review 验证优先锚漂移（写入前校验 $g 应 ≥2 / 未经一致性校验 $h 应 =1 / 变更记录输出 $i 应 ≥1）"
fi
# RL-12 alignment-review 闸门深化锚（task-v104）
s="$(grep -c '全文扫描' "$A" || true)"
u="$(grep -c '删除或归档' "$A" || true)"
v="$(grep -c '变更范围' "$A" || true)"
if [ "$s" -ge 1 ] && [ "$u" -ge 1 ] && [ "$v" -ge 1 ]; then
  ok 12 "alignment-review 闸门深化锚：全文扫描 $s ≥1 / 删除或归档 $u ≥1 / 变更范围 $v ≥1"
else
  bad 12 "alignment-review 闸门深化锚漂移（全文扫描 $s 应 ≥1 / 删除或归档 $u 应 ≥1 / 变更范围 $v 应 ≥1）"
fi
# RL-13 42.6.3 三要素升级锚（task-v104）
p="$(grep '^42\.6\.3' "$CRIT" | grep -c '三要素' || true)"
m="$(grep '^| C32 |' "$SKILLMD" | grep -c '三要素' || true)"
if [ "$p" -ge 1 ] && [ "$m" -ge 1 ]; then
  ok 13 "42.6.3 三要素升级锚：CRIT 42.6.3 行三要素 $p ≥1 / SKILL.md C32 行三要素 $m ≥1"
else
  bad 13 "42.6.3 三要素升级锚漂移（CRIT 42.6.3 行三要素 $p 应 ≥1 / SKILL.md C32 行三要素 $m 应 ≥1）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
