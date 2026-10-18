#!/usr/bin/env bash
# selftest-subagent-return.sh — Rule 22.4b 返回格式污染三面守护 (task-v161 S4, 登记 selftest-registry.tsv)
# What: 静态+行为断言四件上游产物: check-subagent-return.sh(返回侧四判据) / check-dispatch.sh return_section_check(prompt 侧段结构) / subagent_dispatch.md §7 三反污染条款 / critical-rules-dispatch.md 22.4b 污染三面句（[task-v171 2026-10-12] Rule 22 归属 task-dispatch，随迁）; 任一 FAIL → rc 1, 全 PASS → rc 0(末行 Total/PASS/FAIL 摘要)
# Why: task-v152 实证 summary: 契约外字段混入 + §7 段被 ①②③ 任务清单替换——上游产物是漂移载体, 本脚本机器化防回退; 纯读断言(零 VCS 命令/禁写被断言文件)
# Usage: bash selftest-subagent-return.sh(A3-A5 stdin 喂合规块/契约外 summary/块尾「## 附」段; A9 heredoc 污染夹具重复标题+①②③ → pretool rc≠0 且 stderr「返回格式段结构违规」; A10 干净夹具 §7 模板块+三文件+brief 引用+subagent-state/ → pretool rc=0)
# A9/A10 子 shell export TASK_PLANNER_PLAN_DIR 指真实计划目录(三文件在位使缺项扫描通过, 只测段结构门), 父 shell 无泄漏+显式 unset; 锁 .dispatch-inflight 运行前备份、尾回写, 零残留
# [task-v171 回归修复 2026-10-12] 该计划目录已被主仓批归档, PLAN 现指 plans/archive/ 归档位(见 :16 注记); 残留脆弱点: 主仓绝对路径硬编码, 部署位/worktree 外运行时 A9/A10 会 fail-open 空转, 后续可改 $TMP hermetic 夹具(同 selftest-dispatch.sh:17 / selftest-interaction.sh:64 范式)——本轮不做设计级重构, 仅修路径
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v171 回归修复 2026-10-12 派发域搬迁] 现象: A1-A5 FAIL(check-subagent-return.sh 不存在, rc=127)｜
# 根因: 该脚本随派发域迁至 skills/task-dispatch/scripts, 旧写法 $SCRIPT_DIR/../task-dispatch 少一级,
#   解析到 skills/task-planner/task-dispatch(不存在)｜修法: 改锚 $SCRIPT_DIR/../../task-dispatch/scripts
#   (scripts 目录上两级=skills/, 同行 D 指向本目录 check-dispatch.sh 不受影响)
RS="$SCRIPT_DIR/../../task-dispatch/scripts/check-subagent-return.sh"; D="$SCRIPT_DIR/check-dispatch.sh"
TPL="$SCRIPT_DIR/../templates/subagent_dispatch.md"
# [task-v171 回归修复 2026-10-12 规则分层搬迁] 现象: A7 FAIL(22.4b 段三面句/脚本名在核心已不存在)｜
# 根因: P7 核心瘦身后 Rule 22 归属 task-dispatch, 22.4b 段随迁 critical-rules-dispatch.md｜
# 修法: CR 改锚 $SCRIPT_DIR/../../task-dispatch/references/critical-rules-dispatch.md(git 纯改名内容原样,
#   与同行 RS 锚同一相对层级模式)
CR="$SCRIPT_DIR/../../task-dispatch/references/critical-rules-dispatch.md"
REG="$SCRIPT_DIR/selftest-registry.tsv"
# [task-v171 回归修复 2026-10-12 纪律域轮] 现象: A9 FAIL(污染夹具 rc=0, 无 stderr 输出)｜
# 根因: PLAN 硬编码主仓 plans/task-v161-subagent-return-format, 该计划 2026-10-12 07:23 被主仓
#   task-v170 收口批归档(d229faa)mv 入 plans/archive/, 旧路径不存在 → check-dispatch.sh pretool
#   命中 enforce 档目录不存在 fail-open(check-dispatch.sh:323 [ -d "$pd" ] || exit 0)静默 exit 0,
#   返回格式段结构门(return_section_check)根本没跑到, A9 收不到「返回格式段结构违规」; A10 同因
#    trivial PASS(放行语义被 fail-open 满足, 断言力已空转)｜修法: PLAN 改锚 archive/ 归档位
#   (归档为终态, batch archive 不会再移动; 语义与第 1 轮转绿时完全一致——同目录同内容, 仅路径更新)
PLAN="$SCRIPT_DIR/../../../plans/archive/task-v161-subagent-return-format"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
ok() { PASS=$((PASS+1)); echo "A$1 PASS $2"; }
bad() { FAIL=$((FAIL+1)); echo "A$1 FAIL $2${3:+ ($3)}"; }
# ① check-subagent-return.sh 存在且 bash -n 通过(缺脚本 = 上游 S3 未交付, 后续行为断言全跳)
[ -f "$RS" ] && bash -n "$RS" && ok 1 'check-subagent-return.sh 存在+bash -n' || bad 1 '脚本缺或语法错'
# ② 内置 5 夹具自检全 PASS(rc=0; 非 0 = 自检 FAILCNT 置位; [task-v172 CA-4] 第 5 夹具=checkpoint 值带「（待主进程代建）」注记 → PASS)
rc=1; bash "$RS" --selftest >/dev/null 2>&1 && rc=0
[ "$rc" = 0 ] && ok 2 '--selftest rc=0' || bad 2 "--selftest rc=$rc exp=0"
# ③ stdin 喂合规 8 字段块 → rc=0 且 stdout 含 [return-guard] PASS
OUT="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/subagent-state/x.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' | bash "$RS")"; RC=$?
[ "$RC" = 0 ] && printf '%s' "$OUT" | grep -qF '[return-guard] PASS' && ok 3 '合规 8 字段块 rc=0+PASS' || bad 3 "合规块 rc=$RC" "$OUT"
# ④ 契约外字段块(status 后紧跟 summary: 长文本, v152 实证形态) → rc=1 且输出点名 summary
OUT="$(printf '%s\n' 'status: done' 'summary: S4 自测——契约外长文本字段(v152 实证形态)' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/x.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' | bash "$RS" 2>&1)"; RC=$?
[ "$RC" = 1 ] && printf '%s' "$OUT" | grep -qF 'summary' && ok 4 '契约外字段 rc=1+点名 summary' || bad 4 "契约外字段 rc=$RC" "$OUT"
# ⑤ 合规块尾追加「## 附:验收细节」+两行说明 → rc=1(判据三块尾附加)
OUT="$(printf '%s\n' 'status: done' 'acceptance: 1/1 pass — [1:PASS]' 'files: none' 'evidence: e' 'checkpoint: /p/x.md' 'findings_written: none' 'blockers: none' 'confidence: HIGH' '## 附:验收细节' '说明一' '说明二' | bash "$RS" 2>&1)"; RC=$?
[ "$RC" = 1 ] && ok 5 '块尾附加 rc=1' || bad 5 "块尾附加 rc=$RC" "$OUT"
# ⑥ §7 三反污染条款字面各 ≥1(计数先入变量再判, 防长行引号嵌套; 模板缺 = 反污染条款被删)
N6A="$(grep -cF '优先级声明（task-v161' "$TPL" 2>/dev/null)"; N6B="$(grep -cF '点名禁令（task-v161' "$TPL" 2>/dev/null)"; N6C="$(grep -cF '段填写禁令（task-v161' "$TPL" 2>/dev/null)"
[ "${N6A:-0}" -ge 1 ] && [ "${N6B:-0}" -ge 1 ] && [ "${N6C:-0}" -ge 1 ] && ok 6 '§7 三条款各≥1' || bad 6 '§7 条款缺失' "counts=[$N6A,$N6B,$N6C]"
# ⑦ 22.4b 段(22.4b 行起至 22.4c 行止区间)含污染三面句+check-subagent-return.sh(区间正则放变量, 防 awk 单引号嵌套)
RE='/^22\.4b /{f=1} f&&/^22\.4c /{exit} f'; SEG="$(awk "$RE" "$CR" 2>/dev/null)"
printf '%s' "$SEG" | grep -qF '污染三面与主进程动作闭环（task-v161）' && printf '%s' "$SEG" | grep -qF 'check-subagent-return.sh' && ok 7 '22.4b 段含三面句+脚本名' || bad 7 '22.4b 段缺三面句或脚本名'
# ⑧ check-dispatch.sh 含 return_section_check 函数定义行(段结构门被删 = prompt 侧污染失明)
grep -qE 'return_section_check\(\)[[:space:]]*\{' "$D" && ok 8 'return_section_check 定义在位' || bad 8 'return_section_check 定义缺失'
# ⑨ heredoc 用户实证污染夹具(要素: 三文件绝对路径+brief/§ 引用+subagent-state/+重复标题+①②③ 三行任务清单)
cat > "$TMP/bad.md" <<'EOF'
## 返回格式## 返回格式
① v3.1 23 段新配置摘要表
② style_exempt 统一口径
③ 合图锚占位清单
EOF
cat >> "$TMP/bad.md" <<EOF
- task_plan: $PLAN/task_plan.md
- findings: $PLAN/findings.md
- progress: $PLAN/progress.md
knowledge-brief 见 $PLAN/knowledge-brief.md §3
status:
acceptance:
checkpoint: $PLAN/subagent-state/9-code-assistant.md
EOF
( export TASK_PLANNER_PLAN_DIR="$PLAN"; exec bash "$D" pretool "$TMP/bad.md" selftest-9 ) > "$TMP/o9" 2> "$TMP/e9"; RC=$?
[ "$RC" -ne 0 ] && grep -qF '返回格式段结构违规' "$TMP/e9" && ok 9 "污染夹具 pretool rc=$RC+stderr 点名" || bad 9 "污染夹具 rc=$RC" "$(head -n1 "$TMP/e9")"
# 清 A9 新鲜锁防 A10 撞「串行槽占用」(同 selftest-dispatch T05 前清锁范式; 锁为守卫瞬态机制文件, 非断言对象); 备份运行前形态供脚本尾零残留回写
LOCK="$PLAN/subagent-state/.dispatch-inflight"
[ -f "$LOCK" ] && cp -f "$LOCK" "$TMP/lock.bak"
rm -f "$LOCK"
# ⑩ 干净夹具=§7 八字段模板块(段内四 key 齐、标题唯一)+三文件路径+brief 引用+subagent-state/ 检查点路径 → pretool rc=0。模板块逐字提取模板 §7 代码围栏(不含「**返回前必做**:1.-4.」行——行首编号会触 fine_grain ④ 步骤枚举门, 与本断言段结构门正交)
TPL7="$(sed -n '/^## 7\. 返回格式/,/^## 8/p' "$TPL" | sed -n '/^```/,/^```/p' | sed '1d;$d')"
{
  echo '## 7. 返回格式'
  printf '%s\n' "$TPL7"
  echo "checkpoint 路径: $PLAN/subagent-state/10-selftest.md"
} > "$TMP/good.md"
cat >> "$TMP/good.md" <<EOF
- task_plan: $PLAN/task_plan.md
- findings: $PLAN/findings.md
- progress: $PLAN/progress.md
knowledge-brief 见 $PLAN/knowledge-brief.md §3
需求锚: 不适用（纯机械单元）
EOF
( export TASK_PLANNER_PLAN_DIR="$PLAN"; exec bash "$D" pretool "$TMP/good.md" selftest-10 ) > "$TMP/o10" 2> "$TMP/e10"; RC=$?
[ "$RC" = 0 ] && ok 10 '干净夹具 pretool rc=0' || bad 10 "干净夹具 rc=$RC" "$(head -n2 "$TMP/e10" | tr '\n' ' ')"
unset TASK_PLANNER_PLAN_DIR   # 子 shell export 本不外泄, 按材料包要求显式 unset 双保险
# ⑪ registry 自登记(查重后追加; tab 四列同既有行; 重复登记=双行漂移, 先查重)
NEWROW='selftest-subagent-return.sh\tRule 22.4b 返回格式污染三面守护\tsubagent_dispatch.md §7 / critical-rules.md 22.4b / check-subagent-return.sh / check-dispatch.sh return_section_check 改动\tskills/task-planner/templates/subagent_dispatch.md;skills/task-planner/references/critical-rules.md;skills/task-planner/scripts/check-subagent-return.sh;skills/task-planner/scripts/check-dispatch.sh'
if grep -qF 'selftest-subagent-return.sh' "$REG" 2>/dev/null; then ok 11 'registry 行已在位'
else
  printf '%b\n' "$NEWROW" >> "$REG"   # %b 把 \t 展开为真实 tab(TSV 硬要求; %s 留字面反斜杠)
  NCOLS="$(tail -n 1 "$REG" | awk -F '\t' '{print NF}')"
  [ "$NCOLS" = "4" ] && ok 11 'registry 行已追加(4 列)' || bad 11 'registry 追加失败' "NF=$NCOLS"
fi
# 锁零残留: A10 放行使 serial_slot_check 重写瞬态锁 .dispatch-inflight; 回写运行前形态(有备份→cp 回写, 本无锁→删新锁), 守护脚本不留机制文件脏 diff(纯 cp/rm, 零 VCS 写操作)
if [ -f "$TMP/lock.bak" ]; then cp -f "$TMP/lock.bak" "$LOCK" 2>/dev/null || true
elif [ -f "$LOCK" ]; then rm -f "$LOCK"; fi
# ⑫ CA-4 [task-v172]: critical-rules-dispatch.md 含 22.8.6 只读型 checkpoint 主进程代建豁免（四锚字面全在位; 条款被删 = 豁免回归）
if grep -q '22.8.6' "$CR" && grep -q '主进程代建' "$CR" && grep -q '待主进程代建' "$CR" && grep -q 'tools 不含 Write' "$CR"; then
  ok 12 "CA-4: critical-rules-dispatch.md 含 22.8.6 只读型 checkpoint 主进程代建豁免（四锚全在位）"
else
  bad 12 "CA-4: critical-rules-dispatch.md 缺 22.8.6 代建豁免（grep 命中不足）"
fi
echo "Total: $((PASS+FAIL)) PASS=$PASS FAIL=$FAIL"
exit $(( FAIL > 0 ))
