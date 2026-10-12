#!/usr/bin/env bash
# [2026-09-13 task-v067-knowledge-brief] selftest-knowledge-brief.sh — 任务知识简略要点(knowledge-brief)面守护套件
# 守护 templates/knowledge-brief.md 六段骨架 + 全链路接入面
# [2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3）
# (SKILL.md / init-session.sh / check-scope.sh / check-3file-gate.sh / critical-rules.md /
#  subagent_dispatch.md / plan-writer.md / config.json#knowledge_brief_enforce) 一致性。
# 10 组用例 T1-T10, 全 PASS exit 0, 任一 FAIL exit 1。纯 grep/python3 机械断言, 无 fixture。
# 结构/style 照抄 scripts/selftest-skill-collab.sh (set -u / t() 计数器 / [PASS]/[FAIL] / Total / exit)。
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."                        # <repo-root>/skills/task-planner
BRIEF="$ROOT/templates/knowledge-brief.md"
SKILL="$ROOT/SKILL.md"
INIT="$SCRIPT_DIR/init-session.sh"
SCOPE="$SCRIPT_DIR/check-scope.sh"
GATE="$SCRIPT_DIR/check-3file-gate.sh"
# [task-v171 回归修复 2026-10-12 规则分层搬迁] Rule 21/22 归属 task-dispatch，21.2/22.4 两段的 knowledge-brief
#   覆盖断言(T6)随之改锚 CRIT_DP; 行号窗口随文件迁移重定(原 100<L<200 为旧核心 1046 行口径, DP 全文 173 行)
CRULES_DP="$ROOT/../task-dispatch/references/critical-rules-dispatch.md"
CRULES="$ROOT/references/critical-rules.md"
DISPATCH="$ROOT/templates/subagent_dispatch.md"
PLANWRITER="$ROOT/companion/agents/plan-writer.md"
CONFIG="$ROOT/config.json"

PASS=0; FAIL=0
t() { # t <name> <cond-expr...>
    local name="$1"; shift
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); echo "[PASS] $name"
    else
        FAIL=$((FAIL+1)); echo "[FAIL] $name"
    fi
}

# T1: knowledge-brief.md 存在 + 六段标题 + ≤150 行（[2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3））
t "T1a knowledge-brief.md 存在" test -f "$BRIEF"
t "T1b 六段标题 grep -c '^## §' = 6（[2026-10-08 task-v144 合并级联] 五段→六段（§6 技能扫描区块，Rule 59.3））" bash -c "[ \"\$(grep -c '^## §' '$BRIEF')\" -eq 6 ]"
t "T1c 行数 ≤150" bash -c "[ \"\$(wc -l < '$BRIEF')\" -le 150 ]"

# T2: SKILL.md 引用 knowledge-brief ≥2 且行数 ≤540
t "T2a SKILL.md grep 'knowledge-brief' ≥2" bash -c "[ \"\$(grep -c 'knowledge-brief' '$SKILL')\" -ge 2 ]"
# [2026-10-11 task-v170] master 侧演进注记并入：Rule 81 归档步骤+C56 使 master 版 SKILL.md 实值 559，master 将本钉放宽 558→584；task-v171 重写瘦身后 SKILL.md=222 行，保留更紧的 558 上界（对合并树恒真且判据更强，非回退——放宽动因在合并树不存在）
t "T2b SKILL.md 行数 ≤558（task-v076 扩充 545; [2026-09-17 task-v080] 调研路由增补 545→548; [2026-09-20 task-v085] 机制画像增量 548→549; [2026-09-20 task-v086] Rule 38 联动 549→551, 上限 549→552; [2026-09-22 task-v087] Rule 8.1 D 类联动 551→555, 上限 552→555; [2026-09-23 task-v088] Rule 39 联动 555→558, 上限 555→558; [2026-10-11 task-v170 master 注记] 558→584（master 版 SKILL 559 行所需，合并树不适用）)" bash -c "[ \"\$(wc -l < '$SKILL')\" -le 558 ]"

# T3: init-session.sh grep 'knowledge-brief.md' ≥2 (建立循环 + 复核循环) 且 '6/6' 校验行 ≥1
t "T3a init-session.sh 'knowledge-brief.md' ≥2" bash -c "[ \"\$(grep -c 'knowledge-brief.md' '$INIT')\" -ge 2 ]"
t "T3b init-session.sh '6/6' ≥1" bash -c "[ \"\$(grep -c '6/6' '$INIT')\" -ge 1 ]"

# T4: check-scope.sh 白名单含 knowledge-brief.md ≥1
t "T4 check-scope.sh 'knowledge-brief.md' ≥1" bash -c "[ \"\$(grep -c 'knowledge-brief.md' '$SCOPE')\" -ge 1 ]"

# T5: check-3file-gate.sh 文案联动 '6 planning files' ≥1 且存在性循环首行不含 knowledge-brief (KQ3 裁定)
# [task-v067 S6] 现行 check-3file-gate.sh:42 有注释行提及 'knowledge-brief.md'（S1 文案联动 5→6 产物，
# 位于 for 循环块内），全文件 grep 非 0；KQ3 实质=存在性循环首行(:39 for f in ...)不含 brief，
# 故 T5b 断言锚定 for 行本身(整行 grep 计数=0)
t "T5a 3file-gate '6 planning files' ≥1" bash -c "[ \"\$(grep -c '6 planning files' '$GATE')\" -ge 1 ]"
t "T5b 3file-gate 存在性循环首行不含 knowledge-brief (=0, KQ3)" bash -c "[ \"\$(grep -c '^for f in .*knowledge-brief' '$GATE')\" -eq 0 ]"

# T6: critical-rules knowledge-brief 行号覆盖 21.2 与 22.4 段（[task-v171 2026-10-12] 21/22 归属 task-dispatch，改锚 CRIT_DP）
# [task-v095 P6] critical-rules 新增 15.1-15.3 致 21.2/22.4 行号合法后移，窗口随迁（原上限 135）
# [task-v171 2026-10-12 规则分层搬迁] 窗口随目标文件重定: 原 100<L<200 为旧核心 1046 行文件口径(防命中漂到文件头注释区);
#   DP 全文 173 行, 等价口径=0<L≤DP 全文行数(命中须在规则正文区, >0=非缺失, ≤全文=非注释/超尾)
DP_LINES="$(wc -l < "$CRULES_DP")"
L_212=$(grep -n "knowledge-brief" "$CRULES_DP" | grep -F '21.2' | head -1 | cut -d: -f1)
L_224=$(grep -n "knowledge-brief" "$CRULES_DP" | grep -F '22.4' | head -1 | cut -d: -f1)
t "T6 critical-rules-dispatch 21.2($L_212)+22.4($L_224) 命中且 0<行号≤全文(${DP_LINES}行)" bash -c "[ '$L_212' -gt 0 ] && [ '$L_212' -le '$DP_LINES' ] && [ '$L_224' -gt 0 ] && [ '$L_224' -le '$DP_LINES' ] && [ '$L_212' -ne '$L_224' ]"

# T7: subagent_dispatch.md 知识包表行含 knowledge-brief ≥1
t "T7 subagent_dispatch.md 'knowledge-brief' ≥1" bash -c "[ \"\$(grep -c 'knowledge-brief' '$DISPATCH')\" -ge 1 ]"

# T8: plan-writer.md 'knowledge-brief|知识简略要点' ≥3
t "T8 plan-writer.md 'knowledge-brief|知识简略要点' ≥3" bash -c "[ \"\$(grep -c 'knowledge-brief\|知识简略要点' '$PLANWRITER')\" -ge 3 ]"

# T9: config.json knowledge_brief_enforce 存在 + default=warn + enum 三值
# [task-v067] 可移植性: 有 python3 走 JSON 断言; 无 python3 降级 grep 断言 (双路径风格照抄 selftest-skill-collab.sh T7)
# 键块用 sed 行内提取(避免块文本跨 shell 边界/嵌套引号转义); 断言用 test 式 [ $(...) -ge 1 ]
if command -v python3 >/dev/null 2>&1; then
    t "T9 config knowledge_brief_enforce=warn (python3)" python3 -c "
import json
k = json.load(open('$CONFIG'))['properties']['knowledge_brief_enforce']
assert k['default'] == 'warn'
assert set(k['enum']) == {'enforce','warn','off'}"
else
    t "T9 config knowledge_brief_enforce=warn (grep-fallback)" bash -c "
        c=\$(sed -n '/\"knowledge_brief_enforce\"/,/^[[:space:]]*}/p' '$CONFIG')
        [ \$(grep -c '\"default\" *: *\"warn\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"enforce\"' <<<\"\$c\") -ge 1 ] &&
        [ \$(grep -c '\"off\"' <<<\"\$c\") -ge 1 ]"
fi

# T10: 跨文件键名一致: knowledge_brief_enforce 键在位且无拼写变体 knowledge-brief-enforce (全 0)
# [task-v171 2026-10-12 SKILL.md 瘦身] 现象: 原 T10a FAIL(键名仅在 config.json 1 个文件)｜根因: S33 瘦身删除
#   「任务模板库」段(含 config.json#knowledge_brief_enforce 开关键描述, 模板生命周期归卫星 plan-template-kit);
#   该键本就零机器消费方(旧版实证: 仅 config.json + SKILL.md:558 描述 + 本自测三处), 权威 truth=config.json｜
# 修法: 保留「键在位 + 无变体」意图, 不再虚构第二个文件位(原 ≥2 文件面已不存在)
t "T10a knowledge_brief_enforce 在 config.json 且无拼写变体" bash -c "[ \"\$(grep -c 'knowledge_brief_enforce' '$CONFIG')\" -ge 1 ] && [ \"\$(grep -rc 'knowledge-brief-enforce' '$CONFIG' '$SKILL' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"
t "T10b 无拼写变体 knowledge-brief-enforce (全 0)" bash -c "[ \"\$(grep -rc 'knowledge-brief-enforce' '$CONFIG' '$SKILL' | awk -F: '{s+=\$2} END{print s+0}')\" -eq 0 ]"

# ── 汇总 ──
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
