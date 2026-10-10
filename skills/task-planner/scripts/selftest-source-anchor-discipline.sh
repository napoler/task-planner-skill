#!/usr/bin/env bash
# selftest-source-anchor-discipline.sh — task-v158: Rule 71「无源不写·空段占位·写必带锚」载体存在性静态守护（零新 config 键）
# 断言清单来源 = plans/task-v158-source-anchor-discipline/design-rule71.md §五（SA-01..SA-12）
# 素材锚 = plans/task-v153-parallel-scheduling/fix-prompts.md（71.4 引用锚防腐，SA-10）
# 12/12 PASS → exit 0；SA-11 registry 登记行在 S10 登记前未落 = 预期 FAIL（11/12 → exit 1），S10 登记后转 PASS。
# 只读守护，不修改任何文件。2026-10-10 task-v158 新建。

set -u

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES="$SKILL_ROOT/references/critical-rules.md"
SKILL="$SKILL_ROOT/SKILL.md"
DISPATCH_TPL="$SKILL_ROOT/templates/subagent_dispatch.md"
FINDINGS_TPL="$SKILL_ROOT/templates/findings.md"
PROGRESS_TPL="$SKILL_ROOT/templates/progress.md"
FIXPROMPTS="$SKILL_ROOT/../../plans/task-v153-parallel-scheduling/fix-prompts.md"
REGISTRY="$SKILL_ROOT/scripts/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"

pass=0; fail=0
ok() { pass=$((pass+1)); printf '%s PASS %s\n' "$1" "$2"; }
ng() { fail=$((fail+1)); printf '%s FAIL %s\n' "$1" "$2"; }
# chk <SA-XX> <标签> <命令串> — eval 命令串（成功=PASS/失败=FAIL）；命令串内 \$ 延迟到 eval 时展开
chk() { local tag="$1" label="$2" cmd="$3"; if eval "$cmd" 2>/dev/null; then ok "$tag" "$label"; else ng "$tag" "$label"; fi; }

# SA-01 条款标题 + 71.1-71.7 七子条号锚
chk "SA-01" "critical-rules.md 含 '### 71 无源不写' 标题且 71.1-71.7 七子条锚全在" "grep -qF '### 71 无源不写' \"\$RULES\" && test \$(grep -cE '^71\.[1-7] ' \"\$RULES\") -eq 7"
# SA-02 71.1 四来源枚举 + 从严
chk "SA-02" "71.1 行含四来源（file:line/URL/命令输出原文/工具调用记录）与「从严」" "line=\$(grep '^71\.1 ' \"\$RULES\"); test -n \"\$line\" && grep -qF 'file:line' <<<\"\$line\" && grep -qF 'URL' <<<\"\$line\" && grep -qF '命令输出原文' <<<\"\$line\" && grep -qF '工具调用记录' <<<\"\$line\" && grep -qF '从严' <<<\"\$line\""
# SA-03 71.2 五问要素 + 口诀
chk "SA-03" "71.2 行含五问要素与口诀「无源不写，空段占位，写必带锚」" "line=\$(grep '^71\.2 ' \"\$RULES\"); test -n \"\$line\" && grep -q '①' <<<\"\$line\" && grep -q '⑤' <<<\"\$line\" && grep -qF '无源不写，空段占位，写必带锚' <<<\"\$line\""
# SA-04 71.4 审计表五列头 + 「补一个源」禁令
chk "SA-04" "71.4 行含审计表五列头（单元位置/事实摘要/三态判定/源锚或/处置建议）与「补一个源」禁令" "line=\$(grep '^71\.4 ' \"\$RULES\"); test -n \"\$line\" && grep -qF '单元位置' <<<\"\$line\" && grep -qF '事实摘要' <<<\"\$line\" && grep -qF '三态判定' <<<\"\$line\" && grep -qF '源锚或' <<<\"\$line\" && grep -qF '处置建议' <<<\"\$line\" && grep -qF '补一个源' <<<\"\$line\""
# SA-05 71.5 无锚点行=违规退回
chk "SA-05" "71.5 行含「无锚点行=违规退回」" "line=\$(grep '^71\.5 ' \"\$RULES\"); test -n \"\$line\" && grep -qF '无锚点行=违规退回' <<<\"\$line\""
# SA-06 71.7 零新 config 键 + 机器边界披露
chk "SA-06" "71.7 行含「零新 config 键」与「机器边界如实披露」" "line=\$(grep '^71\.7 ' \"\$RULES\"); test -n \"\$line\" && grep -qF '零新 config 键' <<<\"\$line\" && grep -qF '机器边界如实披露' <<<\"\$line\""
# SA-07 SKILL.md Rule 71 bullet + C50 行 + 1-71/1-72/1-75 计数
# [2026-10-10 task-v163 级联: SKILL 计数演进 1-72→1-75（Rule 75 落地）, 计数锚 1-7[12]→1-7[125]（容忍 71/72/75 纪元），判据 ≥2 不减]
# [2026-10-10 task-v162 合并并集演进] 钉值锚形态 grep -cF '1-74'（Rule 74 落地）保留为历史记录字面（AD-12 _pin_lit 兼容），主断言由 v163 级联扩为 1-7[125] 宽容族]
chk "SA-07" "SKILL.md 含 'Rule 71（无源不写' bullet + '| C50 |' 行 + '1-71/1-72/1-75' 计数 ≥2（容忍 1-75 纪元）" "grep -qF 'Rule 71（无源不写' \"\$SKILL\" && grep -qF '| C50 |' \"\$SKILL\" && test \$(grep -cE '1-7[125]' \"\$SKILL\") -ge 2"
# SA-08 dispatch 模板防幻觉契约段 + 五问回溯行
chk "SA-08" "subagent_dispatch.md 含 '## 10. 防幻觉契约' 段与 '写入前五问' 回溯行" "grep -qF '## 10. 防幻觉契约' \"\$DISPATCH_TPL\" && grep -qF '写入前五问' \"\$DISPATCH_TPL\""
# SA-09 findings/progress 模板 Rule 71 注释锚合计 ≥3
chk "SA-09" "findings.md/progress.md 各含 'Rule 71' 注释锚且合计 ≥3" "test \$(grep -cF 'Rule 71' \"\$FINDINGS_TPL\") -ge 1 && test \$(grep -cF 'Rule 71' \"\$PROGRESS_TPL\") -ge 1 && test \$(( \$(grep -cF 'Rule 71' \"\$FINDINGS_TPL\") + \$(grep -cF 'Rule 71' \"\$PROGRESS_TPL\") )) -ge 3"
# SA-10 fix-prompts 素材锚活（71.4 引用锚不腐）
chk "SA-10" "fix-prompts.md 含「提示词 A — 溯源审计」（素材锚活）" "test -f \"\$FIXPROMPTS\" && grep -qF '提示词 A — 溯源审计' \"\$FIXPROMPTS\""
# SA-11 registry 登记行（S10 登记前=预期 FAIL；登记后转 PASS，脚本逻辑不变）
chk "SA-11" "selftest-registry.tsv 含 'selftest-source-anchor-discipline.sh' 登记行" "grep -qF 'selftest-source-anchor-discipline.sh' \"\$REGISTRY\""
# SA-12 零新 config 键负断言
chk "SA-12" "config.json 不含 source_anchor/anti_halluc/no_source 任一键名" "! grep -qE 'source_anchor|anti_halluc|no_source' \"\$CONFIG\""

printf 'Total: %d pass, %d fail\n' "$pass" "$fail"
exit $((fail > 0))
