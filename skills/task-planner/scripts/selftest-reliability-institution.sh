#!/usr/bin/env bash
# selftest-reliability-institution.sh — task-v099 P3: Rule 42/43 质量审查检测+执行可靠性制度化静态守护
# 范式同 selftest-self-resolution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc/jq 为主），R-01..R-16 全 PASS exit 0；任一 FAIL exit 1。
#   R-01     critical-rules.md Rule 42 子条锚 `grep -c '^42\.'` = 10 [2026-10-01 task-v102 B 类扩围: 42.6 追加级联, 5→10]
#   R-02     Rule 43 六子条锚 `grep -c '^43\.'` = 6 [2026-10-05 task-v133: 43.5/43.6 新增级联, 4→6]
#   R-03     42.2 行内锚：「均未命中=缺口」≥1（三级检测缺口判定）
#   R-04     42.3 行内锚：「S-unit」≥1（补充动作 S-unit 登记禁私建）
#   R-05     43.1 行内锚：「未验证」≥1（证据先行/未验证显式登记）
#   R-06     43.2 行内锚：「最小档位」≥1（档位经济）
#   R-07     43.3 行内锚：「候选对比表」≥1（候选预验证）
#   R-08     SKILL.md `grep -c '| C30 |'` = 1 且 `grep -c '| C31 |'` = 1（合规清单 C30/C31 消费行）
#   R-09     SKILL.md `grep -c '含 Rule 40-53 全集'` ≥1 且 `grep -c '1-40'` = 0（括注全集锚+越界负断言）
#            [2026-10-05 task-v131 CR P1-2 级联: SKILL.md:266 括注演进「（含 Rule 40/41/42/43/44/45/46/47/48/49/51）」→「（含 Rule 40-53 全集）」, 锚随之演进, 原锚「含 Rule 40/41/42/43」, 判例 SR-11 锚演进必同步]
#   R-10     模板/契约消费面：templates/task_plan.md「质量审查工具」≥1 且 plan-writer.md「质量审查工具检测登记」≥1
#   R-11     mini-lite 豁免锚：variant/mini-lite-type.md「Rule 42.5 豁免」≥1
#   R-12     零新 config 键——config.json properties 键数 = 40（同 WF-12 口径；jq 缺失时打 SKIPPED 不 FAIL）
#   R-13     43.5 行内锚：「实际生成测试」≥1（提示词/参数修改后必须实测，task-v133 新增）
#   R-14     43.6 行内锚：「优点」≥1（未验证结果禁止优点宣传，task-v133 新增）
#   R-15     53.5 行 Q9 触发面登记锚（Q9 属主=43.5/43.6/51.8，挂 26.3 惩罚映射语义，先例 Q7/Q8，task-v133 新增）
#   R-16     SKILL.md 合规清单 C37 行 =1（未验证优点宣传核查消费行，C31 行内追加不受 '| C31 |' 计数影响，task-v133 新增）
# 静态只读（grep/wc/jq），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL="$SKILL_ROOT/templates/task_plan.md"
MINILITE="$SKILL_ROOT/templates/variant/mini-lite-type.md"
PLANWRITER="$SKILL_ROOT/companion/agents/plan-writer.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'R-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'R-%s FAIL %s\n' "$1" "$2"; }

# R-01 Rule 42 子条锚（42.1-42.5 五子条+42.6 主体+42.6.1-.4 五行 [2026-10-01 task-v102 B 类扩围: 42.6 追加级联, 5→10]）
n="$(grep -c '^42\.' "$CRIT" || true)"
if [ "$n" -eq 10 ]; then ok 01 "critical-rules.md Rule 42 子条锚 = 10"; else bad 01 "critical-rules.md Rule 42 子条数 $n（应 10）"; fi
# R-02 Rule 43 六子条锚 [task-v133 演进: 43.5/43.6 新增, 4→6]
n="$(grep -c '^43\.' "$CRIT" || true)"
if [ "$n" -eq 6 ]; then ok 02 "critical-rules.md Rule 43 六子条锚 = 6"; else bad 02 "critical-rules.md Rule 43 子条数 $n（应 6）"; fi
# R-03 42.2 三级检测缺口判定锚
if grep '^42\.2' "$CRIT" | grep -q '均未命中=缺口'; then
  ok 03 "42.2 行内锚「均未命中=缺口」在位"
else
  bad 03 "42.2 行内锚缺失（均未命中=缺口）"
fi
# R-04 42.3 补充合约 S-unit 登记锚
if grep '^42\.3' "$CRIT" | grep -q 'S-unit'; then
  ok 04 "42.3 行内锚「S-unit 登记」在位"
else
  bad 04 "42.3 行内锚缺失（S-unit 登记）"
fi
# R-05 43.1 证据先行锚
if grep '^43\.1' "$CRIT" | grep -q '未验证'; then
  ok 05 "43.1 行内锚「未验证」在位"
else
  bad 05 "43.1 行内锚缺失（未验证）"
fi
# R-06 43.2 档位经济锚
if grep '^43\.2' "$CRIT" | grep -q '最小档位'; then
  ok 06 "43.2 行内锚「最小档位」在位"
else
  bad 06 "43.2 行内锚缺失（最小档位）"
fi
# R-07 43.3 候选预验证锚
if grep '^43\.3' "$CRIT" | grep -q '候选对比表'; then
  ok 07 "43.3 行内锚「候选对比表」在位"
else
  bad 07 "43.3 行内锚缺失（候选对比表）"
fi
# R-08 SKILL.md C30/C31 合规清单消费行各 = 1
a="$(grep -c '| C30 |' "$SKILLMD" || true)"
b="$(grep -c '| C31 |' "$SKILLMD" || true)"
if [ "$a" -eq 1 ] && [ "$b" -eq 1 ]; then ok 08 "SKILL.md C30/C31 合规清单项各 =1"; else bad 08 "SKILL.md C30 项 $a（应 1）/ C31 项 $b（应 1）"; fi
# R-09 SKILL.md 括注全集锚 + 越界负断言
# [2026-10-05 task-v131 CR P1-2 级联: 锚「含 Rule 40/41/42/43」→「含 Rule 40-53 全集」(SKILL.md:266 括注演进), 1-40 负断言保留]
a="$(grep -c '含 Rule 40-53 全集' "$SKILLMD" || true)"
b="$(grep -c '1-40' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then ok 09 "SKILL.md「含 Rule 40-53 全集」锚 $a ≥1 且越界 1-40 =0"; else bad 09 "SKILL.md 括注锚漂移（含 Rule 40-53 全集=$a 应 ≥1 / 1-40=$b 应 0）"; fi
# R-10 模板配置表「质量审查工具」行 + plan-writer 义务行（检测登记）
a="$(grep -c '质量审查工具' "$TPL" || true)"
b="$(grep -c '质量审查工具检测登记' "$PLANWRITER" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 10 "模板「质量审查工具」行 $a ≥1 且 plan-writer「质量审查工具检测登记」义务行 $b ≥1"; else bad 10 "模板/契约消费面漂移（模板 质量审查工具=$a 应 ≥1 / plan-writer 检测登记=$b 应 ≥1）"; fi
# R-11 mini-lite 豁免声明锚
n="$(grep -c 'Rule 42.5 豁免' "$MINILITE" || true)"
if [ "$n" -ge 1 ]; then ok 11 "mini-lite「Rule 42.5 豁免」声明行 $n ≥1"; else bad 11 "mini-lite 豁免声明行缺失（Rule 42.5 豁免 命中 $n 应 ≥1）"; fi
# R-12 零新 config 键——properties 键数 = 40（同 WF-12 口径；jq 缺失打 SKIPPED 不 FAIL）
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 12 "config.json properties 键数 40（零新增）"; else bad 12 "config.json properties 键数=$keys（应 40）"; fi
else
  printf 'R-12 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# R-13 43.5 行内锚：「实际生成测试」≥1（提示词/参数修改后必须实测）
if grep '^43\.5' "$CRIT" | grep -q '实际生成测试'; then
  ok 13 "43.5 行内锚「实际生成测试」在位"
else
  bad 13 "43.5 行内锚缺失（实际生成测试）"
fi
# R-14 43.6 行内锚：「优点」≥1（未验证结果禁止优点宣传）
if grep '^43\.6' "$CRIT" | grep -q '优点'; then
  ok 14 "43.6 行内锚「优点」在位"
else
  bad 14 "43.6 行内锚缺失（优点）"
fi
# R-15 53.5 行 Q9 触发面登记锚（Q9 属主=43.5/43.6/51.8，挂 26.3 惩罚映射语义，先例 Q7/Q8）
if grep '^53\.5' "$CRIT" | grep -q 'Q9'; then
  ok 15 "53.5 行「Q9」触发面登记在位"
else
  bad 15 "53.5 行「Q9」登记缺失（未验证结果优点宣传触发面失锚）"
fi
# R-16 SKILL.md 合规清单 C37 行 =1（未验证优点宣传核查消费行，C31 行内追加不受 '| C31 |' 计数影响）
n="$(grep -c '| C37 |' "$SKILLMD" || true)"
if [ "$n" -eq 1 ]; then ok 16 "SKILL.md C37 合规清单项 =1"; else bad 16 "SKILL.md C37 合规清单项 $n（应 1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
