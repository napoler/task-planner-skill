#!/usr/bin/env bash
# selftest-absorption-discipline.sh — task-v162: Rule 74「变更吸收三判纪律」载体存在性静态守护（零新 config 键）
# 断言清单来源 = plans/task-v162-change-absorption-safety/task_plan.md §守护断言清单（AD-01..AD-14）
# 范式 = scripts/selftest-source-anchor-discipline.sh（shebang/注释头/ok·ng·chk 断言函数/pass·fail 计数/退出码逐处对齐）
# 本文件（S7）= 上半 AD-01..AD-07；S8 在文件尾部续写标记之后追加下半 AD-08..AD-14。
# 只读守护，不修改任何文件。2026-10-10 task-v162 新建。

set -u

# SKILL_ROOT 由脚本自身位置推导（绝对路径，worktree 内），CWD 无关
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES="$SKILL_ROOT/references/critical-rules.md"
SKILL="$SKILL_ROOT/SKILL.md"
PLAN_TPL="$SKILL_ROOT/templates/task_plan.md"
DISPATCH_TPL="$SKILL_ROOT/templates/subagent_dispatch.md"

pass=0; fail=0; skip=0
ok() { pass=$((pass+1)); printf '%s PASS %s\n' "$1" "$2"; }
ng() { fail=$((fail+1)); printf '%s FAIL %s\n' "$1" "$2"; }
# sk — SKIP 中性态（S12 收紧：不计 pass 亦不计 fail，仅标注；防候选缺失时静默转绿，退出码不受影响）
sk() { skip=$((skip+1)); printf '%s SKIP %s\n' "$1" "$2"; }
# chk <AD-XX> <标签> <命令串> — eval 命令串（成功=PASS/失败=FAIL）；命令串内 \$ 延迟到 eval 时展开
chk() { local tag="$1" label="$2" cmd="$3"; if eval "$cmd" 2>/dev/null; then ok "$tag" "$label"; else ng "$tag" "$label"; fi; }

# AD-01 critical-rules.md 含 '### 74 变更吸收三判纪律' 标题行，且 74.1-74.6 六子条锚各 ≥1
chk "AD-01" "critical-rules.md 含 '### 74 变更吸收三判纪律' 标题且 74.1-74.6 六子条锚全在" "grep -qF '### 74 变更吸收三判纪律' \"\$RULES\" && grep -qE '^74\.1 ' \"\$RULES\" && grep -qE '^74\.2 ' \"\$RULES\" && grep -qE '^74\.3 ' \"\$RULES\" && grep -qE '^74\.4 ' \"\$RULES\" && grep -qE '^74\.5 ' \"\$RULES\" && grep -qE '^74\.6 ' \"\$RULES\""
# AD-02 条文三档关键词（增量（默认且优先）/四条件全满足才可/删除（最高门槛））+判据句「先问是补充还是替代」各 ≥1
chk "AD-02" "Rule 74 条文含三档关键词（增量（默认且优先）/四条件全满足才可/删除（最高门槛））与判据句「先问是补充还是替代」" "grep -qF '增量（默认且优先）' \"\$RULES\" && grep -qF '四条件全满足才可' \"\$RULES\" && grep -qF '删除（最高门槛）' \"\$RULES\" && grep -qF '先问是补充还是替代' \"\$RULES\""
# AD-03 条文内禁硬编码行号锚（:[0-9] 引用形态=FAIL）——仅审视 Rule 74 条文段（标题行至 EOF）
chk "AD-03" "Rule 74 条文段内无硬编码行号锚（:[0-9] 引用形态）" "sec=\$(sed -n '/^### 74 变更吸收三判纪律/,\$p' \"\$RULES\"); test -n \"\$sec\" && ! grep -qE ':[0-9]' <<<\"\$sec\""
# [2026-10-11 task-v169 Rule 80 纪元扩展] Rule 80 落地后 SKILL.md 全集索引演进 1-76→1-80：AD-04 旧 7x 纪元锚 → '1-[7-8][0-9]'（覆盖 1-70..1-89，含 1-74..1-79 历史纪元与 1-80，阈值 ≥3 不变）；AD-12 的 4 个 'Critical Rules' pin 同步改 '1-[7-8][0-9]'，source-anchor pin 因该脚本本体未随批演进保持原样
# AD-04 SKILL.md 接线锚 ≥5：全集行/索引段/References 表三处 1-(7[4-9]|8[01]) + 用户新指令处理段 '变更吸收三判门（Rule 74' + 合规清单 C51 行
# [2026-10-11 task-v170 S10h 纪元扩围（Rule 45 注释）] '1-7[4-9]'→'1-(7[4-9]|8[01])'：Why=task-v170 落地 Rule 81（计划完成后归档纪律），SKILL.md 三处接线锚实态演进为「Critical Rules 1-81」（L9 全集行/L314 索引段/L406 References 表，grep -nE '1-(7[4-9]|8[01])' 实测三处命中、逐行 1 次共 3 处，≥3 不变）；8x 纪元精化 8[01] 覆盖 80/81 两号、不放开越界值（负样本 '1-82'/'1-90' 实测不命中），判据不减（Rule 45：修改既有断言注明修改时间+原行为：原 grep -cE '1-7[4-9]'=2 失配 FAIL=AD-04）
chk "AD-04" "SKILL.md 接线锚 ≥5：'1-(7[4-9]|8[01])' 三处（全集/索引段/References 表）+ 新指令处理段 'Rule 74' + C51 行" "test \$(grep -cE '1-(7[4-9]|8[01])' \"\$SKILL\") -ge 3 && grep -qF '变更吸收三判门（Rule 74' \"\$SKILL\" && grep -qF '| C51 |' \"\$SKILL\""
# AD-05 触点锚：critical-rules 8.1/36.5/56.1 段 grep 'Rule 74' 命中 ≥3 + SKILL B 类行含 'Rule 74' + B/C 类新段含「可行性判别门」
chk "AD-05" "触点锚：critical-rules 8.1/36.5/56.1 段 'Rule 74' 命中 ≥3 + SKILL B 类行 'Rule 74' + B/C 类新段含「可行性判别门」" "test \$(grep -E '^(8\.1|36\.5|56\.1) ' \"\$RULES\" | grep -cF 'Rule 74') -ge 3 && grep -E '\| B 扩展 \|' \"\$SKILL\" | grep -qF 'Rule 74' && grep -F 'B/C 类' \"\$SKILL\" | grep -qF '可行性判别门'"
# AD-06 templates/task_plan.md 含「📋 变更标注表」且六列关键词齐备（编号/对象/类型/吸收判定/依据/执行动作）+四类型串「新增·修改·删除·更新」+吸收判定三态串「增量·替代·删除」
chk "AD-06" "templates/task_plan.md 含「📋 变更标注表」且六列（编号/对象/类型/吸收判定/依据/执行动作）+四类型串+吸收判定三态串齐备" "hdr=\$(grep -F '吸收判定' \"\$PLAN_TPL\" || true); test -n \"\$hdr\" && grep -qF '📋 变更标注表' \"\$PLAN_TPL\" && grep -qF '编号' <<<\"\$hdr\" && grep -qF '对象' <<<\"\$hdr\" && grep -qF '类型' <<<\"\$hdr\" && grep -qF '依据' <<<\"\$hdr\" && grep -qF '执行动作' <<<\"\$hdr\" && grep -qF '新增·修改·删除·更新' <<<\"\$hdr\" && grep -qF '增量·替代·删除' <<<\"\$hdr\""
# AD-07 templates/subagent_dispatch.md 含「定稿可行性判别模式」+三维关键词（可执行性/相容性/风险性）+三态串（PASS-WITH-RISKS）
chk "AD-07" "templates/subagent_dispatch.md 含「定稿可行性判别模式」+三维（可执行性/相容性/风险性）+三态串（PASS-WITH-RISKS）" "grep -qF '定稿可行性判别模式' \"\$DISPATCH_TPL\" && grep -qF '可执行性' \"\$DISPATCH_TPL\" && grep -qF '相容性' \"\$DISPATCH_TPL\" && grep -qF '风险性' \"\$DISPATCH_TPL\" && grep -qF 'PASS-WITH-RISKS' \"\$DISPATCH_TPL\""

# ─────────────────────────────────────────────────────────────
# === AD-08 续写锚（S8 在本行之后追加 AD-08..AD-14 断言）===
# AD-08 74.4 分工与豁免锚 / AD-09 registry 登记行 / AD-10 零新键
# AD-11 SKILL '1-71' 残留=0 / AD-12 pinning selftest '1-71' 字面 / AD-13 自举消费 / AD-14 自跑 exit 0
# ─────────────────────────────────────────────────────────────
# S8 追加段（下半 AD-08..AD-14；沿用 S7 的 chk/ok/ng 范式与 SKILL_ROOT 相对解析）
SCRIPTS="$SKILL_ROOT/scripts"
REGISTRY="$SCRIPTS/selftest-registry.tsv"
CONFIG="$SKILL_ROOT/config.json"
SELF="$SCRIPTS/selftest-absorption-discipline.sh"

# AD-08 Rule 74.4 分工与豁免锚在位：与 Rule 69.1 T1 的分工句（「69.1」引用）+ 74.4(f)「mini 档」豁免措辞各 ≥1
chk "AD-08" "Rule 74.4 分工与豁免锚：「69.1」引用 +「mini 档」豁免措辞各 ≥1" "sec=\$(sed -n '/^### 74 /,\$p' \"\$RULES\"); test -n \"\$sec\" && grep -qF '69.1' <<<\"\$sec\" && grep -qF 'mini 档' <<<\"\$sec\""
# AD-09 registry.tsv 含本脚本登记行（脚本名 + 守护面描述串「Rule 74」/「变更吸收」）
chk "AD-09" "registry.tsv 含 selftest-absorption-discipline.sh 登记行（脚本名+守护面描述串）" "row=\$(grep '^selftest-absorption-discipline\.sh' \"\$REGISTRY\" || true); test -n \"\$row\" && grep -qF 'Rule 74' <<<\"\$row\" && grep -qF '变更吸收' <<<\"\$row\""
# AD-10 config.json 零新键（Rule 74.6：禁新增 absorption 类配置键）
chk "AD-10" "config.json 零新键（grep「absorption」=0）" "n=\$(grep -c 'absorption' \"\$CONFIG\" 2>/dev/null); test \"\${n:-0}\" -eq 0"
# AD-11 SKILL.md『1-71』字面残留=0（全集行/索引段/References 表三处已演进 1-[7-8][0-9]）
chk "AD-11" "SKILL.md『1-71』字面残留=0（三处已演进 1-[7-8][0-9]）" "n=\$(grep -c '1-71' \"\$SKILL\" 2>/dev/null); test \"\${n:-0}\" -eq 0"
# AD-12 pinning selftest 锚 11 处逐个断言（S0 findings A3：精确 5 + 宽容/变体 6）
#   精确 5（_pin_lit）：断言各文件 live 锚字面在位——4 文件 'Critical Rules 1-(7[4-9]|8[01])'（断言行+消息串）+ SA-07 "grep -cE '1-7[4-9]'"（源锚未扩围保持原样）；
#     live 锚被静默回退/删除（如退回 1-71）即 FAIL（旧实现 grep '1-71' 仅命中迁移注释=判别力弱，S12 收紧）
#   宽容 6（_pin_tol）：断言各文件宽容正则族字面在位（task-v169 本批随纪元演进的三脚本 research-first/context-pressure/skill-split 的 pin 已同步为新 live 锚 '1-[7-8][0-9]'/'1-(69|71|7[4-9]|80)'/'Rules 1-(3[0-9]|[4-8][0-9])'，其余三项未随批演进保持原样）；用 -F 匹配文件内字面正则串，免 ERE 歧义
_pin_lit() { grep -qF "$2" "$1" 2>/dev/null; }             # 精确 pin：文件内 live 锚字面（如 'Critical Rules 1-[7-8][0-9]'）在位
_pin_tol() { grep -qF "$2" "$1" 2>/dev/null; }             # 宽容 pin：文件内字面正则族串在位
ad12=0
_pin_lit "$SCRIPTS/selftest-tool-selection.sh" 'Critical Rules 1-(7[4-9]|8[01])' || ad12=1
_pin_lit "$SCRIPTS/selftest-requirement-coverage.sh" 'Critical Rules 1-(7[4-9]|8[01])' || ad12=1
_pin_lit "$SCRIPTS/selftest-lane-advancement.sh" 'Critical Rules 1-(7[4-9]|8[01])' || ad12=1
# [2026-10-12 task-v170 S10p 级联同步] self-resolution 未统一改形：该文件 live 锚=两臂字面 'Critical Rules 1-7[4-9]|Critical Rules 1-8[01]([^0-9]|$)'
#   （grep -cF 统一新字面=0 实测；统一字面 1-(7[4-9]|8[01]) 仅 tool-selection/requirement-coverage/lane-advancement 三文件在位），
#   本行 pin 该文件现态两臂字面（失位即 FAIL）；若该文件日后统一改形，pin 须再同步（cascade 信号）
_pin_lit "$SCRIPTS/selftest-self-resolution.sh" 'Critical Rules 1-7[4-9]|Critical Rules 1-8[01]([^0-9]|$)' || ad12=1
_pin_lit "$SCRIPTS/selftest-source-anchor-discipline.sh" "grep -cE '1-7[4-9]'" || ad12=1
_pin_tol "$SCRIPTS/selftest-research-first.sh" '1-[7-8][0-9]' || ad12=1
_pin_tol "$SCRIPTS/selftest-context-pressure.sh" '1-(69|71|7[4-9]|80)' || ad12=1
_pin_tol "$SCRIPTS/selftest-workflow-orchestration.sh" '1-(68|69|71)' || ad12=1
_pin_tol "$SCRIPTS/selftest-conclusion-discipline.sh" '1-[4-7][0-9]' || ad12=1
_pin_tol "$SCRIPTS/selftest-skill-split.sh" 'Rules 1-(3[0-9]|[4-7][0-9]|81)' || ad12=1
_pin_tol "$SCRIPTS/selftest-source-anchor-discipline.sh" '^71\.[1-7] ' || ad12=1
if [ "$ad12" -eq 0 ]; then ok "AD-12" "pinning 锚 11 处逐个断言：live 锚字面（精确 5：Critical Rules 1-(7[4-9]|8[01]) / 1-7[4-9] 计数）或宽容正则族（6）二者居一"; else ng "AD-12" "pinning 锚形态漂移（live 锚字面或宽容正则族缺失）"; fi
# AD-13 自举消费：本计划 task_plan.md 变更标注表 ≥10 行 CA-n 条目（Rule 74.3 dogfood，本计划=首批 consumer）
#   候选（无机器相关硬编码，S12 收紧）：① env 注入 TASK_PLANNER_ABSORB_PLAN ② 主仓根（git-common-dir 推导，worktree 内可解析到主仓）
#     ③ repo 相对 $SKILL_ROOT/../../plans/…（部署位/主仓直跑）；均缺=SKIP 中性态（sk 不计 pass/fail，防静默转绿）
ad13_plan=""; ad13_gitroot=""
if command -v git >/dev/null 2>&1; then
  gd="$(git -C "$SKILL_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  [ -n "$gd" ] && ad13_gitroot="$(dirname "$gd")"
fi
for c in \
  "${TASK_PLANNER_ABSORB_PLAN:-}" \
  "${ad13_gitroot:+$ad13_gitroot/plans/task-v162-change-absorption-safety/task_plan.md}" \
  "$SKILL_ROOT/../../plans/task-v162-change-absorption-safety/task_plan.md"; do
  if [ -n "$c" ] && [ -f "$c" ]; then ad13_plan="$c"; break; fi
done
if [ -z "$ad13_plan" ]; then
  sk "AD-13" "自举消费 SKIPPED（候选均缺：env TASK_PLANNER_ABSORB_PLAN 未设 + 主仓根未解析 + repo 相对缺失；中性态不计 pass/fail）"
else
  nca=$(grep -cE '^\| CA-[0-9]+ \|' "$ad13_plan" 2>/dev/null); nca=${nca:-0}
  if [ "$nca" -ge 10 ]; then ok "AD-13" "自举消费：变更标注表含 $nca 行 CA-n 条目（≥10）"; else ng "AD-13" "变更标注表 CA-n 行=$nca（应 ≥10）"; fi
fi
# AD-14 脚本自身 chmod+x（可执行位）且 bash -n 语法通过（自跑 exit 0 由尾部退出码覆盖）
chk "AD-14" "脚本自身 chmod+x（可执行位）且 bash -n 语法通过" "test -x \"\$SELF\" && bash -n \"\$SELF\""

printf 'Total: %d pass, %d fail, %d skip\n' "$pass" "$fail" "$skip"
exit $((fail > 0))
