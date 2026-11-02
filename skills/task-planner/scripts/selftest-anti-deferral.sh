#!/usr/bin/env bash
# selftest-anti-deferral.sh — task-lazy-escalation-20261102: Rule 97 惰性上抛禁令与不可用判词证据门静态守护
# 守护定位（Rule 97 为 LLM 行为面条款+38.7 L0-T opt-in 静态守护，本脚本=防条款误删/半截落地/纪元级联残留/未授权新 config 键的静态锚，断言对象=技能源文件，只读零副作用）:
#   AD-01 critical-rules-discipline.md 含 Rule 97 段标题（^### 97 惰性上抛禁令）
#   AD-02 97.1 可执行验证问题+先自主试错取证 锚（行域=含 97.1 的行）
#   AD-03 97.2 不可用+已试清单+各自输出+Rule 26 Q3 判词证据链 锚（行域=含 97.2 的行）
#   AD-04 97.3 ≥3 种不同策略 穷尽锚+41.4 清单项策略源 锚（行域=含 97.3 的行）
#   AD-05 97.4 推荐项置顶+依据+验证方式 三件套锚（行域=含 97.4 的行）
#   AD-06 97.5 四类合法门四词齐（偏好/不可逆/预算/合规）+穷尽门不吞并 锚（行域=含 97.5 的行）
#   AD-07 97.6 三仲裁锚各 grep ≥1：『41.4 优先于 D3』『83 是 60 的特例』『资料先行档替代路径』
#         （『22.3.0 替代路径』非连续串不作单锚，已弃）
#   AD-08 SKILL.md task-discipline 路由枚举扩员 '94,95,97' ≥1（frontmatter 卫星行+正文路由表两行）
#   AD-09 SKILL.md 纪元字面 '1-98' ≥3（line9 指针行/line210 全集索引/line253 References 表）
#   AD-10 SKILL.md '其余 81 条' ≥2（line9+line210；79→80 计数级联随动，Rule 97 并入后全集计数上移；80→81：2026-11-03 task-ctxcorrect-20261103 Rule 98 并入纪律域）
#   AD-11 [负] config.json properties 键数=53（同 selftest-lane-advancement.sh LA-14 line148 口径；jq 缺失打 SKIPPED 不 FAIL——无 jq 属环境降级非内容漂移，沿用 LA-14 先例）
#   AD-12 [负] 防越界+登记闭环: 规则文件 ^97.8 子条=0（八子条 97.0-97.7 上限）∧ selftest-registry.tsv 已登记本脚本（selftest-registry.sh T02 双向配对兜底）
# 全 PASS exit 0; 任一 FAIL exit 1。只读，不修改任何文件。
# 输入: 无参数（断言对象路径自推导，范式同 selftest-subagent-activation.sh）
# 输出: stdout AD-NN PASS/FAIL 逐行 + 末行 Total；AD-11 缺 jq 时打 AD-11 SKIPPED 行（不计 FAIL）
# 依赖: bash+coreutils(grep/awk)；AD-11 需 jq（缺失降级 SKIPPED）

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RULE="$SKILL_ROOT/../task-discipline/references/critical-rules-discipline.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
REGISTRY="$SCRIPT_DIR/selftest-registry.tsv"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'AD-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'AD-%s FAIL %s\n' "$1" "$2"; }
cnt()  { grep -cF "$1" "$2" 2>/dev/null || true; }
cntE() { grep -cE "$1" "$2" 2>/dev/null || true; }
# 行域 grep（What=在含子条编号的行内找锚词; Why=防其他规则行锚词误命中/防锚词漂出 97.x 子条行）
linekw() { grep -F "$1" "$RULE" 2>/dev/null | grep -cF -- "$2" || true; }

# AD-01 Rule 97 段标题
if grep -q '^### 97 惰性上抛禁令' "$RULE"; then ok 01 "Rule 97 段标题在位"; else bad 01 "Rule 97 段标题缺失"; fi
# AD-02 97.1 可执行验证问题+先自主试错取证
if [ "$(linekw '97.1' '可执行验证问题')" -ge 1 ] && [ "$(linekw '97.1' '先自主试错取证')" -ge 1 ]; then
  ok 02 "97.1 可执行验证问题自主试错取证门"
else
  bad 02 "97.1 锚缺失（可执行验证问题/先自主试错取证，行域=含 97.1 的行）"
fi
# AD-03 97.2 不可用+已试清单+各自输出+Rule 26 Q3
ad03a="$(linekw '97.2' '不可用')"; ad03b="$(linekw '97.2' '已试清单')"; ad03c="$(linekw '97.2' '各自输出')"; ad03d="$(linekw '97.2' 'Rule 26 Q3')"
if [ "${ad03a:-0}" -ge 1 ] && [ "${ad03b:-0}" -ge 1 ] && [ "${ad03c:-0}" -ge 1 ] && [ "${ad03d:-0}" -ge 1 ]; then
  ok 03 "97.2 不可用判词证据门（已试清单+各自输出+Rule 26 Q3 判定口径）"
else
  bad 03 "97.2 证据链锚缺失（不可用=${ad03a:-0}/已试清单=${ad03b:-0}/各自输出=${ad03c:-0}/Rule 26 Q3=${ad03d:-0}，均须 ≥1）"
fi
# AD-04 97.3 ≥3 种不同策略+41.4 策略源
ad04a="$(linekw '97.3' '≥3 种不同策略')"; ad04b="$(linekw '97.3' '41.4')"
if [ "${ad04a:-0}" -ge 1 ] && [ "${ad04b:-0}" -ge 1 ]; then
  ok 04 "97.3 ≥3 种不同策略穷尽门（41.4 清单项入策略源）"
else
  bad 04 "97.3 穷尽锚缺失（≥3 种不同策略=${ad04a:-0}/41.4=${ad04b:-0}，均须 ≥1）"
fi
# AD-05 97.4 推荐项置顶三件套
ad05a="$(linekw '97.4' '推荐项置顶')"; ad05b="$(linekw '97.4' '依据')"; ad05c="$(linekw '97.4' '验证方式')"
if [ "${ad05a:-0}" -ge 1 ] && [ "${ad05b:-0}" -ge 1 ] && [ "${ad05c:-0}" -ge 1 ]; then
  ok 05 "97.4 推荐项置顶三件套（推荐项置顶+依据+验证方式）"
else
  bad 05 "97.4 三件套锚缺失（推荐项置顶=${ad05a:-0}/依据=${ad05b:-0}/验证方式=${ad05c:-0}，均须 ≥1）"
fi
# AD-06 97.5 四类合法门四词齐+穷尽门不吞并
ad06a="$(linekw '97.5' '偏好')"; ad06b="$(linekw '97.5' '不可逆')"; ad06c="$(linekw '97.5' '预算')"; ad06d="$(linekw '97.5' '合规')"; ad06e="$(linekw '97.5' '穷尽门不吞并')"
if [ "${ad06a:-0}" -ge 1 ] && [ "${ad06b:-0}" -ge 1 ] && [ "${ad06c:-0}" -ge 1 ] && [ "${ad06d:-0}" -ge 1 ] && [ "${ad06e:-0}" -ge 1 ]; then
  ok 06 "97.5 四类合法用户门保留（偏好/不可逆/预算/合规 四词齐+穷尽门不吞并）"
else
  bad 06 "97.5 锚缺失（偏好=${ad06a:-0}/不可逆=${ad06b:-0}/预算=${ad06c:-0}/合规=${ad06d:-0}/穷尽门不吞并=${ad06e:-0}，均须 ≥1）"
fi
# AD-07 97.6 三仲裁锚（各 grep ≥1；『22.3.0 替代路径』非连续串弃用）
ad07a="$(linekw '97.6' '41.4 优先于 D3')"; ad07b="$(linekw '97.6' '83 是 60 的特例')"; ad07c="$(linekw '97.6' '资料先行档替代路径')"
if [ "${ad07a:-0}" -ge 1 ] && [ "${ad07b:-0}" -ge 1 ] && [ "${ad07c:-0}" -ge 1 ]; then
  ok 07 "97.6 升级优先级仲裁（41.4 优先于 D3 / 83 是 60 的特例 / 资料先行档替代路径 三锚齐）"
else
  bad 07 "97.6 仲裁锚缺失（41.4 优先于 D3=${ad07a:-0}/83 是 60 的特例=${ad07b:-0}/资料先行档替代路径=${ad07c:-0}，均须 ≥1）"
fi
# AD-08 SKILL.md task-discipline 路由枚举扩员
ad08="$(cnt '94,95,97' "$SKILLMD")"
if [ "${ad08:-0}" -ge 1 ]; then ok 08 "SKILL.md task-discipline 路由枚举 94,95,97=${ad08:-0} 处（≥1）"; else bad 08 "SKILL.md 缺 94,95,97 路由枚举（=0，需 ≥1: frontmatter 卫星行+正文路由表）"; fi
# AD-09 SKILL.md 纪元字面 1-98 ≥3
ad09="$(cnt '1-98' "$SKILLMD")"
if [ "${ad09:-0}" -ge 3 ]; then ok 09 "SKILL.md 纪元字面 1-98=${ad09:-0} 处（≥3）"; else bad 09 "SKILL.md 纪元字面 1-98 仅 ${ad09:-0} 处（需 ≥3: 指针行/全集索引/References 表）"; fi
# AD-10 SKILL.md 其余 81 条 ≥2
ad10="$(cnt '其余 81 条' "$SKILLMD")"
if [ "${ad10:-0}" -ge 2 ]; then ok 10 "SKILL.md 计数级联 其余 81 条=${ad10:-0} 处（≥2）"; else bad 10 "SKILL.md 计数级联缺失（其余 81 条=${ad10:-0}，需 ≥2）"; fi
# AD-11 [负] config.json properties 键数=53（LA-14 同口径；jq 缺失 SKIPPED 不 FAIL）
if command -v jq >/dev/null 2>&1; then
  keys="$(jq '.properties | length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "53" ]; then
    ok 11 "config.json properties 键数 53（零新 config 键，Rule 97 不扩配置面）"
  else
    bad 11 "config.json properties 键数=$keys（应 53，未授权新键）"
  fi
else
  printf 'AD-11 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi
# AD-12 [负] 子条越界 + registry 登记
ad12a="$(cntE '^97\.8' "$RULE")"; ad12b="$(cnt 'selftest-anti-deferral.sh' "$REGISTRY")"
if [ "${ad12a:-0}" -eq 0 ] && [ "${ad12b:-0}" -ge 1 ]; then
  ok 12 "无 97.8 越界子条（八子条 97.0-97.7 上限）∧ registry 已登记本脚本"
else
  bad 12 "越界或漏登记（97.8=${ad12a:-0} 应 0 / registry 行=${ad12b:-0} 应 ≥1）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
