#!/usr/bin/env bash
# selftest-reliability-institution.sh — task-v099 P3: Rule 42/43 质量审查检测+执行可靠性制度化静态守护
# 范式同 selftest-self-resolution.sh（SCRIPT_DIR/SKILL_ROOT 解析、ok()/bad() 结构、Total 行、exit 语义同构）：
# 本脚本仅做静态断言（grep/wc/jq 为主），R-01..R-16 全 PASS exit 0；任一 FAIL exit 1。
#   R-01     critical-rules.md Rule 42 子条锚 `grep -c '^42\.'` = 11 [2026-10-01 task-v102 B 类扩围: 42.6 追加级联, 5→10] [任务v167 演进: 42.7 新增, 10→11]
#   R-02     Rule 43 六子条锚 `grep -c '^43\.'` = 6 [2026-10-05 task-v133: 43.5/43.6 新增级联, 4→6]
#   R-03     42.2 行内锚：「均未命中=缺口」≥1（三级检测缺口判定）
#   R-04     42.3 行内锚：「S-unit」≥1（补充动作 S-unit 登记禁私建）
#   R-05     43.1 行内锚：「未验证」≥1（证据先行/未验证显式登记）
#   R-06     43.2 行内锚：「最小档位」≥1（档位经济）
#   R-07     43.3 行内锚：「候选对比表」≥1（候选预验证）
#   R-08     SKILL.md `grep -c '| C30 |'` = 1 且 `grep -c '| C31 |'` = 1（合规清单 C30/C31 消费行）
#   R-09     SKILL.md `grep -cE '含 Rule 40-[4-8][0-9](\+[0-9]+)? 全集'` ≥1 且 `grep -c '1-40'` = 0（括注全集宽容锚+越界负断言）
#            [2026-10-05 task-v131 CR P1-2 级联: SKILL.md:278 括注演进「（含 Rule 40/41/42/43/44/45/46/47/48/49/51）」→「（含 Rule 40-53 全集）」, 锚随之演进, 原锚「含 Rule 40/41/42/43」, 判例 SR-11 锚演进必同步] # 2026-10-08 task-v149 行号锚对齐实态（D12）
#   R-10     模板/契约消费面：templates/task_plan.md「质量审查工具」≥1 且 plan-writer.md「质量审查工具检测登记」≥1
#   R-11     mini-lite 豁免锚：variant/mini-lite-type.md「Rule 42.5 豁免」≥1
#   R-12     零新 config 键——config.json properties 键数 = 44（同 WF-12 口径; task-perf-opt 合法新增 2 键 42→44; jq 缺失时打 SKIPPED 不 FAIL）
#   R-13     43.5 行内锚：「实际生成测试」≥1（提示词/参数修改后必须实测，task-v133 新增）
#   R-14     43.6 行内锚：「优点」≥1（未验证结果禁止优点宣传，task-v133 新增）
#   R-15     53.5 行 Q9 触发面登记锚（Q9 属主=43.5/43.6/51.8，挂 26.3 惩罚映射语义，先例 Q7/Q8，task-v133 新增）
#   R-16     SKILL.md 合规清单 C37 行 =1（未验证优点宣传核查消费行，C31 行内追加不受 '| C31 |' 计数影响，task-v133 新增）
# 静态只读（grep/wc/jq），零仓库写入；无临时文件（无需 mktemp）。

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
# [task-v171 纪律域搬迁 2026-10-12] Rule 42（质量审查技能主动检测与补充）、43（执行可靠性制度化）、
#   53（根源解决与决策管辖）均属纪律域，原文已迁至 skills/task-discipline/references/critical-rules-discipline.md
#   （核心 critical-rules.md 只剩 11 条核心规则）；本文件全部 CRIT 断言（R-xx）改指 CRIT_D，CRIT 保留指向核心。
#   断言语义零改动。
CRIT_D="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
TPL="$SKILL_ROOT/templates/task_plan.md"
MINILITE="$SKILL_ROOT/templates/variant/mini-lite-type.md"
PLANWRITER="$SKILL_ROOT/companion/agents/plan-writer.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'R-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'R-%s FAIL %s\n' "$1" "$2"; }

# R-01 Rule 42 子条锚（42.1-42.5 五子条+42.6 主体+42.6.1-.4 五行 [2026-10-01 task-v102 B 类扩围: 42.6 追加级联, 5→10] [任务v167 演进: 42.7 新增, 10→11]）
n="$(grep -c '^42\.' "$CRIT_D" || true)"
if [ "$n" -eq 11 ]; then ok 01 "critical-rules.md Rule 42 子条锚 = 11"; else bad 01 "critical-rules.md Rule 42 子条数 $n（应 11）"; fi
# R-02 Rule 43 六子条锚 [task-v133 演进: 43.5/43.6 新增, 4→6]
n="$(grep -c '^43\.' "$CRIT_D" || true)"
if [ "$n" -eq 6 ]; then ok 02 "critical-rules.md Rule 43 六子条锚 = 6"; else bad 02 "critical-rules.md Rule 43 子条数 $n（应 6）"; fi
# R-03 42.2 三级检测缺口判定锚
if grep '^42\.2' "$CRIT_D" | grep -q '均未命中=缺口'; then
  ok 03 "42.2 行内锚「均未命中=缺口」在位"
else
  bad 03 "42.2 行内锚缺失（均未命中=缺口）"
fi
# R-04 42.3 补充合约 S-unit 登记锚
if grep '^42\.3' "$CRIT_D" | grep -q 'S-unit'; then
  ok 04 "42.3 行内锚「S-unit 登记」在位"
else
  bad 04 "42.3 行内锚缺失（S-unit 登记）"
fi
# R-05 43.1 证据先行锚
if grep '^43\.1' "$CRIT_D" | grep -q '未验证'; then
  ok 05 "43.1 行内锚「未验证」在位"
else
  bad 05 "43.1 行内锚缺失（未验证）"
fi
# R-06 43.2 档位经济锚
if grep '^43\.2' "$CRIT_D" | grep -q '最小档位'; then
  ok 06 "43.2 行内锚「最小档位」在位"
else
  bad 06 "43.2 行内锚缺失（最小档位）"
fi
# R-07 43.3 候选预验证锚
if grep '^43\.3' "$CRIT_D" | grep -q '候选对比表'; then
  ok 07 "43.3 行内锚「候选对比表」在位"
else
  bad 07 "43.3 行内锚缺失（候选对比表）"
fi
# R-08 [task-v171 核心瘦身] C30/C31 合规行 → 卫星路由表 task-discipline 行 + CRIT_D Rule 42 标题锚
#   现象：SKILL.md 瘦身后合规清单 C30（Rule 42 消费行）/C31（Rule 43 消费行）随清单表退役，双双归零，R-08 恒 FAIL。
#   根因：Rule 42/43 属纪律域；非核心域合规项经卫星路由表行承载（Rule 82 禁回潮，C 行不回填）。
#   修法：a=路由表 discipline 行 =1（42/43 合规消费面载体）；b=CRIT_D '^### 42 ' 标题 =1（条款本体在位双保险）。
a="$(grep -cE '^\| task-discipline \|' "$SKILLMD" || true)"
b="$(grep -cE '^### 42 ' "$CRIT_D" || true)"
if [ "$a" -eq 1 ] && [ "$b" -eq 1 ]; then ok 08 "SKILL.md 卫星路由表 discipline 行=1（C30/C31 合规面载体）∧ CRIT_D Rule 42 标题=1"; else bad 08 "SKILL.md 路由表 discipline 行 $a（应 1）/ CRIT_D Rule 42 标题 $b（应 1）"; fi
# R-09 SKILL.md 括注全集锚 + 越界负断言
# [2026-10-05 task-v131 CR P1-2 级联: 锚「含 Rule 40/41/42/43」→「含 Rule 40-53 全集」(SKILL.md:278 括注演进), 1-40 负断言保留] # 2026-10-08 task-v149 行号锚对齐实态（D12）
# [2026-10-05 task-v136 S2 级联: 括注演进「40-54 全集」, 锚宽容化 40-5[3-9]（v118/v131/v132 教训: 先扫后改, 宽容正则优先）, 1-40 负断言保留]
# [2026-10-05 task-v138 合并级联: 括注演进「40-55 全集」（Rule 55 落地），宽容正则 40-5[3-9] 仍覆盖 40-55，保持宽容锚不重新钉死（宽容正则优先先例；v138 侧 40-55 固定锚在合并面让位于宽容锚，语义强度不降）]
# [2026-10-08 task-v144 合并级联（附带, 同 IP-12 宽容正则先例）: SKILL.md 全集声明已演进为「Rule 40-62 全集」(L273), 旧宽容正则 40-5[3-9] 失配=0, 随动 40-5[3-9]→40-[56][0-9]（覆盖 40-53..40-69 全区间, 语义强度不降: 仍为宽容锚不重新钉死）, 1-40 负断言保留]
# [2026-10-10 task-v158 级联（宽容锚随动）: SKILL.md:288 全集声明实态=「Rule 40-71 全集」, 宽容正则 40-[56][0-9] 上界 69 < 71 失配=0, 随动 40-[56][0-9]→40-[567][0-9]（覆盖 40-53..40-79, 宽容锚不重新钉死先例, 1-40 负断言保留）]
# [2026-10-10 task-v156 CR/M 级联] 锚随 SKILL 计数「1-71+73」插入形态宽容化:DCS-11/R-09/RF-07/RR-09/P-05 正则加 `(\+[0-9]+)?` 族（K9）,负断言保留
# [2026-10-11 task-v169 纪元演进: Rule 80 落地 SKILL.md, 括注实态「含 Rule 40-80 全集」, 字符类 40-[4567][0-9]→40-[4-8][0-9]（覆盖 40-40..40-89, B 类宽容锚演进先例）, 转义加号族 `(\+[0-9]+)?` 与 1-40 负断言均不变]
# [2026-10-12 task-v171 分层口径切换: SKILL.md 瘦身后全集括注「含 Rule 40-80 全集」演进为「Rules 1-80 全集索引」（核心 12 条+10 卫星路由表），旧宽容锚 40-[4-8][0-9] 失配=0，随动演进为 '1-80' 全集口径锚（宽容正则优先范式延续，1-40 负断言不变）]
a="$(grep -cE '1-[89][0-9]' "$SKILLMD" || true)"
b="$(grep -c '1-40' "$SKILLMD" || true)"
if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then ok 09 "SKILL.md 全集口径锚 '1-[89][0-9]' $a ≥1 且越界 1-40 =0（v171 分层口径）"; else bad 09 "SKILL.md 全集锚漂移（'1-80'=$a 应 ≥1 / 1-40=$b 应 0）"; fi
# R-10 模板配置表「质量审查工具」行 + plan-writer 义务行（检测登记）
a="$(grep -c '质量审查工具' "$TPL" || true)"
b="$(grep -c '质量审查工具检测登记' "$PLANWRITER" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 10 "模板「质量审查工具」行 $a ≥1 且 plan-writer「质量审查工具检测登记」义务行 $b ≥1"; else bad 10 "模板/契约消费面漂移（模板 质量审查工具=$a 应 ≥1 / plan-writer 检测登记=$b 应 ≥1）"; fi
# R-11 mini-lite 豁免声明锚
n="$(grep -c 'Rule 42.5 豁免' "$MINILITE" || true)"
if [ "$n" -ge 1 ]; then ok 11 "mini-lite「Rule 42.5 豁免」声明行 $n ≥1"; else bad 11 "mini-lite 豁免声明行缺失（Rule 42.5 豁免 命中 $n 应 ≥1）"; fi
# R-12 零新 config 键——properties 键数 = 44（同 WF-12 口径; task-perf-opt 合法新增 smart_inject_type_gate+selftest_heavy_concurrent 2 键, 42→44; jq 缺失打 SKIPPED 不 FAIL）
# [2026-10-08 task-v144 合并级联: v145 新增 2 键(config=42),FF 守护 42 为准,旧定数 40→42]
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "53" ]; then ok 12 "config.json properties 键数 53（基线含 v145 2 键 + task-perf-opt 2 键 + task-v172 合法新增 smart_inject_interval+light_tier_interval_multiplier 2 键 44→46；P-01 合法新增 evidence_anchor_enforce 1 键 46→47）"; else bad 12 "config.json properties 键数=$keys（应 53）"; fi
else
  printf 'R-12 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# R-13 43.5 行内锚：「实际生成测试」≥1（提示词/参数修改后必须实测）
if grep '^43\.5' "$CRIT_D" | grep -q '实际生成测试'; then
  ok 13 "43.5 行内锚「实际生成测试」在位"
else
  bad 13 "43.5 行内锚缺失（实际生成测试）"
fi
# R-14 43.6 行内锚：「优点」≥1（未验证结果禁止优点宣传）
if grep '^43\.6' "$CRIT_D" | grep -q '优点'; then
  ok 14 "43.6 行内锚「优点」在位"
else
  bad 14 "43.6 行内锚缺失（优点）"
fi
# R-15 53.5 行 Q9 触发面登记锚（Q9 属主=43.5/43.6/51.8，挂 26.3 惩罚映射语义，先例 Q7/Q8）
if grep '^53\.5' "$CRIT_D" | grep -q 'Q9'; then
  ok 15 "53.5 行「Q9」触发面登记在位"
else
  bad 15 "53.5 行「Q9」登记缺失（未验证结果优点宣传触发面失锚）"
fi
# R-16 [task-v171 核心瘦身] C37 合规行 → 终验交付段 Rule 26.3 违规降级门（未验证优点宣传核查的现存合规载体）
#   现象：SKILL.md 瘦身后合规清单 C37 行（未验证优点宣传核查消费行）随清单表退役，命中=0，R-16 恒 FAIL。
#   根因：C37 消费语义（未处置违规降级 outcome）在瘦身后由终验交付段「质量门控统计（Rule 26）…未处置违规按
#     Rule 26.3 降级 outcome，Q3→BLOCKED+STOP」承载；Q9 触发面登记锚由 CRIT_D 53.5（R-15）守护。
#   修法：改断言 SKILL.md 含 'Rule 26.3' ≥1（降级门执行载体）。
n="$(grep -c 'Rule 26.3' "$SKILLMD" || true)"
if [ "$n" -ge 1 ]; then ok 16 "SKILL.md 终验交付段 Rule 26.3 违规降级门=$n（C37 合规面瘦身后由降级门承载）"; else bad 16 "SKILL.md Rule 26.3 锚=$n（应 ≥1）"; fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
