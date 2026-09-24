#!/usr/bin/env bash
# selftest-workflow-orchestration.sh — task-v088 P4-S1: Rule 39 动态工作流编排静态守护
# 零新 config 键范式同 v087：本脚本仅做静态断言（grep -q 为主），WF-01..16 全 PASS exit 0；任一 FAIL exit 1。
# [2026-09-25 task-v090] WF-13..16 追加（39.7 边界锚/禁副本负断言/pretooluse 观察分支/register-hooks matcher）
#   WF-01..06 critical-rules.md Rule 39 条款锚（头 + 39.1/39.3/39.4/39.5 + 39.6 机制+零新 config 键）
#   WF-07..09 SKILL.md 联动（Rule 39 摘要行 + C27 清单项 + 协同路由 dynamic-workflows 行）
#   WF-10/11  4 索引文档（SKILL.md/CLAUDE.md/README_zh.md/skills/task-planner/README.md）
#             "Rules 1-39" 命中总和 ≥6；"Rules 1-38" 残留 =0（仓内 CLAUDE/README_zh 按
#             SKILL_ROOT/../.. 解析；部署位上跳路径缺失时该文件计 0 不 FAIL，仅对存在文件求和；
#             critical-rules.md 38.5 条款内 1 处历史描述不在 WF-11 检查范围）
#   WF-12     config.json properties 键数 = 40（零新增；jq 缺失时打 SKIPPED 不 FAIL）
#   WF-13     [2026-09-25 task-v090] 39.7 动态激活边界锚（39.7 头 + 39.7.1/39.7.2/39.7.3 三子条 + 39.5 观察面注记）
#   WF-14     [2026-09-25 task-v090] 禁自建副本负断言（39.7.2）：~/.zcode/skills 与
#             ~/.agents/skills 下无 dynamic-workflows/ 目录（存在=遮蔽官方 bundled skill）
#   WF-15     [2026-09-25 task-v090] zcode-pretooluse.sh 39.7.3 workflow 观察分支锚
#             （四工具 case 分支 + workflow-observe 提醒文案 + 分支内无 exit 2）
#   WF-16     [2026-09-25 task-v090] register-hooks-cj.ts PreToolUse matcher 含 workflow 四工具锚

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRIT="$SKILL_ROOT/references/critical-rules.md"
SKILLMD="$SKILL_ROOT/SKILL.md"
CONFIG="$SKILL_ROOT/config.json"
CLAUDE="$SKILL_ROOT/../../CLAUDE.md"
README_ZH="$SKILL_ROOT/../../README_zh.md"
SKILLS_README="$SKILL_ROOT/README.md"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'WF-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'WF-%s FAIL %s\n' "$1" "$2"; }

# WF-01 Rule 39 头
if grep -q '^### 39 ' "$CRIT" && grep '^### 39 ' "$CRIT" | grep -q '动态工作流编排'; then ok 01 "Rule 39 头"; else bad 01 "Rule 39 头缺失"; fi
# WF-02 39.1 触发纪律锚
if grep -q '^39\.1 \*\*触发纪律' "$CRIT"; then ok 02 "39.1 触发纪律锚"; else bad 02 "39.1 触发纪律锚缺失"; fi
# WF-03 39.3 四机制映射锚
if grep -q '^39\.3 \*\*四机制映射' "$CRIT"; then ok 03 "39.3 四机制映射锚"; else bad 03 "39.3 四机制映射锚缺失"; fi
# WF-04 39.4 并行豁免锚
if grep -q '^39\.4 \*\*并行豁免' "$CRIT"; then ok 04 "39.4 并行豁免锚"; else bad 04 "39.4 并行豁免锚缺失"; fi
# WF-05 39.5 机器校验边界锚
if grep -q '^39\.5 \*\*机器校验边界' "$CRIT"; then ok 05 "39.5 机器校验边界锚"; else bad 05 "39.5 机器校验边界锚缺失"; fi
# WF-06 39.6 机制锚 + 零新 config 键
if grep -q '^39\.6 \*\*机制' "$CRIT" && grep -q '零新 config 键' "$CRIT"; then ok 06 "39.6 机制锚（零新 config 键）"; else bad 06 "39.6 机制锚缺失"; fi
# WF-07 SKILL.md Rule 39 摘要行
if grep -qF 'Rule 39（动态工作流编排' "$SKILLMD"; then ok 07 "SKILL.md Rule 39 摘要行"; else bad 07 "SKILL.md 缺 Rule 39 摘要行"; fi
# WF-08 SKILL.md C27 合规清单项
if grep -qF '| C27 |' "$SKILLMD"; then ok 08 "SKILL.md C27 清单项"; else bad 08 "SKILL.md 缺 C27 行"; fi
# WF-09 SKILL.md 协同路由 dynamic-workflows 行
if grep -qF 'dynamic-workflows（用户显式点名' "$SKILLMD"; then ok 09 "SKILL.md 协同路由 dynamic-workflows 行"; else bad 09 "SKILL.md 协同路由缺 dynamic-workflows 行"; fi
# WF-10 4 索引文档 "Rules 1-39" 命中总和 ≥6（文件缺失计 0 不 FAIL，仅对存在文件求和）
cnt=0
for f in "$SKILLMD" "$CLAUDE" "$README_ZH" "$SKILLS_README"; do
  if [ -f "$f" ]; then c="$(grep -c 'Rules 1-39' "$f" || true)"; cnt=$((cnt + c)); fi
done
if [ "$cnt" -ge 6 ]; then ok 10 "4 索引文档 Rules 1-39 命中总和 $cnt ≥6"; else bad 10 "Rules 1-39 命中总和 $cnt <6"; fi
# WF-11 4 索引文档 "Rules 1-38" 残留 =0（同 WF-10 口径；critical-rules.md 内 1 处历史描述不在范围）
res=0
for f in "$SKILLMD" "$CLAUDE" "$README_ZH" "$SKILLS_README"; do
  if [ -f "$f" ]; then res=$((res + $(grep -c 'Rules 1-38' "$f" || true))); fi
done
if [ "$res" -eq 0 ]; then ok 11 "Rules 1-38 残留 0"; else bad 11 "Rules 1-38 残留 $res（应 0）"; fi
# WF-12 config.json properties 键数 = 40（jq 缺失打 SKIPPED 不 FAIL，家族范式无先例故自定义）
if command -v jq >/dev/null 2>&1; then
  keys="$(jq -r '.properties|keys|length' "$CONFIG" 2>/dev/null || true)"
  if [ "$keys" = "40" ]; then ok 12 "config.json properties 键数 40（零新增）"; else bad 12 "config.json properties 键数=$keys（应 40）"; fi
else
  printf 'WF-12 SKIPPED jq 缺失，无法校验 config.json 键数（安装 jq 后重跑）\n'
fi

# WF-13 39.7 动态激活边界锚（头 + 三子条 + 39.5 观察面注记；39.5 既有锚 WF-05 语义不变）
if grep -q '^39\.7 \*\*动态激活边界与禁自建副本' "$CRIT" \
   && grep -q '39\.7\.1 /workflow 自动激活' "$CRIT" \
   && grep -q '39\.7\.2 禁自建 dynamic-workflows 副本' "$CRIT" \
   && grep -q '39\.7\.3 唯一允许的操作面=matcher 观察扩展' "$CRIT" \
   && grep -q '观察面扩展 ≠ 守卫面扩展' "$CRIT"; then
  ok 13 "39.7 动态激活边界锚（三子条 + 39.5 观察面注记）"
else
  bad 13 "39.7 动态激活边界锚缺失（critical-rules.md 头/子条/39.5 注记）"
fi
# WF-14 禁自建副本负断言（39.7.2）：用户级两 skills 目录无 dynamic-workflows/
# （部署位运行本脚本时 $HOME 亦有效；目录不存在=PASS 的常态）
shadow=""
[ -d "$HOME/.zcode/skills/dynamic-workflows" ] && shadow="$shadow ~/.zcode/skills/dynamic-workflows"
[ -d "$HOME/.agents/skills/dynamic-workflows" ] && shadow="$shadow ~/.agents/skills/dynamic-workflows"
if [ -z "$shadow" ]; then
  ok 14 "用户级 skills 目录无 dynamic-workflows 副本（39.7.2 负断言）"
else
  bad 14 "检测到自建副本（遮蔽官方 bundled skill）:$shadow — 删除走 Rule 36.4 逐项确认"
fi
# WF-15 zcode-pretooluse.sh 39.7.3 workflow 观察分支锚（四工具 case + 观察文案 + 分支内无 exit 2）
PRE="$SKILL_ROOT/scripts/zcode-pretooluse.sh"
branch="$(awk '/CreateWorkflow\|AmendWorkflow\|SaveWorkflow\|EvalWorkflowSnippet\)/{f=1} f{print} /^esac$/{if(f)exit}' "$PRE" 2>/dev/null)"
if [ -n "$branch" ] && printf '%s' "$branch" | grep -qF '[workflow-observe]' \
   && ! printf '%s' "$branch" | grep -q 'exit 2'; then
  ok 15 "zcode-pretooluse.sh 39.7.3 workflow 观察分支（观察文案在位且零阻断）"
else
  bad 15 "zcode-pretooluse.sh 缺 39.7.3 workflow 观察分支（或分支含 exit 2=阻断语义漂移）"
fi
# WF-16 register-hooks-cj.ts PreToolUse matcher 含 workflow 四工具锚（观察面扩围登记）
REG="$SKILL_ROOT/scripts/register-hooks-cj.ts"
if grep -q 'CreateWorkflow|AmendWorkflow|SaveWorkflow|EvalWorkflowSnippet' "$REG"; then
  ok 16 "register-hooks-cj.ts matcher 含 workflow 四工具（39.7.3 观察面扩围）"
else
  bad 16 "register-hooks-cj.ts matcher 未扩围（缺 workflow 四工具）"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
