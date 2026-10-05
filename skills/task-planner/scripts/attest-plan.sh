#!/usr/bin/env bash
# [2026-09-02] attest-plan.sh — 计划 attestation(SHA-256 锁定,Rule 20.1)
# 职责:用户批准计划后,把 task_plan.md 的 SHA-256 写入同目录 .plan-attestation;
#       此后 zcode-userpromptsubmit.sh 每次注入前校验,哈希不匹配 → [PLAN TAMPERED] 拒绝注入计划内容。
#       防止计划被静默篡改(意外编辑/注入攻击)后仍在执行循环中被当作事实源。
# Usage:
#   attest-plan.sh [plan_file]              # 锁定(默认: 探测活跃计划)
#   attest-plan.sh --show   [plan_file]     # 显示已存 attestation
#   attest-plan.sh --verify [plan_file]     # 校验: exit 0=匹配 1=不匹配 2=未锁定
#   attest-plan.sh --clear  [plan_file]     # 清除锁定(计划重规划并重新获批后使用)
#   attest-plan.sh --skip-template-check [plan_file]  # 跳过模板门控(Rule 34.1, 须在交付报告披露)
#   attest-plan.sh --skip-fmea-check [plan_file]      # 跳过 FMEA 门控(v075 P4, 与 --skip-dispatch-check 同构, 须在交付报告披露)
# 说明: Rule 51.1 需求原文区块门(缺区块/无 R 行/无 R→VC 映射/无 🧮 根源覆盖表 → 拒锁)为 fail-closed 硬门, 无 --skip 逃生口;
#       mini 档(plan_tier: mini)整块豁免(与 FMEA mini 豁免同先例), 非 mini 计划必含四锚(51.1 三锚 + 53.1 第 4 锚)方可锁定。
# 约束:fail-open 不适用本脚本(写操作需明确);被 hook 调用(--verify)时任何异常 exit 2 视为"未锁定"。
set -uo pipefail

plan_file=""
mode="attest"
skip_dispatch=""
skip_template=""
skip_fmea=""
for arg in "$@"; do
  case "$arg" in
    --show) mode="show" ;;
    --verify) mode="verify" ;;
    --clear) mode="clear" ;;
    --skip-dispatch-check) skip_dispatch=1 ;;
    --skip-template-check) skip_template=1 ;;
    --skip-fmea-check) skip_fmea=1 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) plan_file="$arg" ;;
  esac
done

# ─── 探测活跃计划(未显式给路径时)────────────────────────────────────────
# task-v065/V-8 [2026-09-13] 优先走会话隔离解析链 resolve-plan-dir.sh [root] [sid]
# (Rule 22.9: side 会话指针 → legacy 全局指针 → mtime → legacy 根单文件, 口径与
#  zcode-userpromptsubmit hook 一致); resolver 缺失/无输出时回落原 ls -t 并 stderr 说明
if [ -z "$plan_file" ]; then
  resolver="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-plan-dir.sh"
  up_sid="${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}"
  if [ -f "$resolver" ]; then
    plan_file="$(bash "$resolver" "$(pwd)" "${up_sid}" 2>/dev/null | head -n 1)"
    if [ -z "$plan_file" ]; then
      echo "[attest] WARN: resolve-plan-dir.sh 无解析结果, 回落 ls -t mtime 探测" >&2
    fi
  else
    echo "[attest] WARN: resolve-plan-dir.sh 缺失, 回落 ls -t mtime 探测" >&2
  fi
  if [ -z "$plan_file" ]; then
    if [ -d "plans" ]; then
      plan_file="$(ls -t plans/*/task_plan.md 2>/dev/null | head -1)"
    fi
    [ -z "$plan_file" ] && [ -f "task_plan.md" ] && plan_file="task_plan.md"
  fi
fi
if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
  echo "[attest] ERROR: no task_plan.md found (pass path or run from project root)" >&2
  exit 2
fi

plan_dir="$(cd "$(dirname "$plan_file")" && pwd)"
attest_file="$plan_dir/.plan-attestation"

case "$mode" in
  attest)
    # [2026-09-09 task-v058] 计划期 S-unit 执行体校验(Rule 22.6/25.1 机制化);--skip-dispatch-check 可跳过
    cpl="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check-plan-dispatch.sh"
    if [ -z "$skip_dispatch" ]; then
      if [ -x "$cpl" ]; then
        bash "$cpl" "$plan_file" || { echo "[attest] ✗ 派发型 Phase 未规划子代理,拒绝锁定(Rule 22.6/25.1);紧急 --skip-dispatch-check(将记 ledger 告警)" >&2; exit 1; }
      else
        # [2026-09-16 task-v074 P10] fail-open 显式化(CR P2a 收口):脚本缺失/不可执行时不再静默跳过
        echo "[plan-dispatch] SKIPPED (check-plan-dispatch.sh 不可执行)" >&2
      fi
    else
      echo "[attest] WARN: --skip-dispatch-check 跳过 S-unit 执行体校验" >&2
    fi
    # [2026-09-15 task-v074 Rule 34.1] 模板选取门控: 锁定前校验 template_type ∈ 白名单
    # 档位解析(对齐 P2 REFLECT-GATE resolve 范式):
    #   env TASK_PLANNER_TEMPLATE_GATE_ENFORCE > config.json template_gate_enforce.default > warn(jq 不可用回退 warn)
    # off=整体跳过; enforce=缺失/非法拒绝锁定; warn=告警放行; --skip-template-check 逃生(须交付报告披露)
    if [ -z "$skip_template" ]; then
      tcfg="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json"
      resolve_template_tier() {
        local m="${TASK_PLANNER_TEMPLATE_GATE_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$tcfg" ]; then
          m="$(jq -r '.properties.template_gate_enforce.default // "warn"' "$tcfg" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
      }
      TTIER="$(resolve_template_tier)"
      if [ "$TTIER" != "off" ]; then
        ctt="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check-template-type.sh"
        if [ -x "$ctt" ]; then
          bash "$ctt" "$plan_file"; t_rc=$?
        else
          # [2026-09-16 task-v074 P10] fail-open 显式化(CR P2a 收口):脚本缺失/不可执行时不再静默跳过
          echo "[template-gate] SKIPPED (check-template-type.sh 不可执行)" >&2
          t_rc=0
        fi
        if [ "$t_rc" -eq 0 ]; then
          echo "[attest] [template-gate] OK (Rule 34.1)"
        else
          case "$TTIER" in
            enforce)
              echo "[attest] ✗ 模板门控失败,拒绝锁定(Rule 34.1/34.6, template_gate_enforce=enforce); 修正 template_type 或紧急 --skip-template-check(须记交付报告)" >&2
              exit 1
              ;;
            *)
              echo "[attest] [template-gate] WARNING (warn 档不阻断: TASK_PLANNER_TEMPLATE_GATE_ENFORCE=enforce 或 config.json template_gate_enforce=enforce 可升级; 紧急 --skip-template-check)" >&2
              ;;
          esac
        fi
      fi
    else
      echo "[attest] WARN: --skip-template-check 跳过模板门控(Rule 34.1, 须在交付报告披露)" >&2
    fi
    # [2026-10-05 task-v131 S-unit P2-S3] Rule 51.1 需求原文区块门(审计 H-3 清账, 锁定面载体):
    # ① What: 非 mini 计划锁定前必含四锚——51.1 三锚(标题「## 🎯 用户需求原文」+ R 需求行 ≥1
    #   (正则 ^[[:space:]]*[-*][[:space:]]+\*\*R[0-9] 覆盖行首/缩进、- 或 * 号列表项的
    #   `**R1**` 形态)+ 「R→VC 映射」标题行)+ 第 4 锚「🧮 根源覆盖表」标题行
    #   (Rule 53.1 载体, critic P1-3 对称性修复: 根源覆盖表无锁定门 与 51.1 三锚不对称
    #   → 与三锚同 fail-closed 门控)。53.1 口径: 非结果级需求可写
    #   「不适用（非结果级）」声明, 但必须附定性理由——本门 grep 标题行「根源覆盖表」,
    #   该声明写在表格区/标题行之后, 区块在位即算通过(锚级检查, 声明内容合规性由
    #   53.1 条文侧 attest/终验把关, 不在此门做语义判定)。
    #   任一缺失 = 51.1/53.1「缺区块=计划无效」的机器化, fail-closed 拒绝锁定(exit 1)。
    # ② Why: 51.1 原文锚堵「绕过 init 手写计划」的转译漂移入口(判例: 一个月→72h, videop1 S15
    #   改写后全链绿灯); 第 4 锚堵同入口的 53.1 侧(结果级需求无全链工序审计=只修最显性层,
    #   51.3 口径 partial/uncovered); 本门为锁定面硬门(生成面=init-session.sh 注入已同任务落地),
    #   故不新增 --skip 逃生口——缺区块只能回炉补区块后重 attest(与「先哈希后写」纪律同向:
    #   门失败退出时不产生 .plan-attestation, 未获批内容不会被 hook 当事实源注入)。
    # ③ 位置: check-plan-dispatch → check-template-type 之后、锁定写入(哈希)之前(本文件
    #   :266 注释口径「三道前置门」扩展为四道); mini 档(plan_tier: mini)整块豁免——
    #   轻量计划不做需求逐条抄录(与 FMEA mini 豁免 Rule 38.4① 同先例, 口径=全文 grep)。
    tier_flag="$(grep -qm1 'plan_tier: mini' "$plan_file" 2>/dev/null && printf mini || printf standard)"
    if [ "$tier_flag" = "mini" ]; then
      echo "[requirement-gate] INFO: plan_tier: mini 豁免(Rule 51.1 mini 档不要求需求原文区块, 同 FMEA mini 先例)"
    else
      req_msgs=""
      grep -q '^## 🎯 用户需求原文' "$plan_file" 2>/dev/null || req_msgs="${req_msgs}· 标题「## 🎯 用户需求原文」缺失"
      # [2026-10-05 task-v131 CR-fix P2-2] 原正则 `^- \*\*R[0-9]` 只认行首非缩进的 `- **R1**`
      # 形态, 注释自称覆盖「宽松 **R1**」形态不实(CR 实锤)。放宽为接受缩进与 * 号列表项:
      # `^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]`(R1/R10 均命中, 原行为 缩进/星号形态被误拒)。
      grep -qE '^[[:space:]]*[-*][[:space:]]+\*\*R[0-9]' "$plan_file" 2>/dev/null || req_msgs="${req_msgs} · R 需求行(≥1, 正则 ^[[:space:]]*[-*][[:space:]]+\\*\\*R[0-9], 接受缩进与 * 号列表项)缺失"
      # [2026-10-05 task-v131 CR-fix P2-3] 「R→VC 映射」原为纯子串 grep `R→VC 映射`,
      # 正文任意提及即可满足(CR P2 弱化项)。升级为标题行锚 `^#{2,3}.*R→VC 映射`
      # (= ###/## 级标题行内含字样, 正文提及不再满足; 模板/注入脚手架/既有合规计划
      # 实测均匹配, 原行为 子串任意位置命中即过)。
      grep -qE '^#{2,3}.*R→VC 映射' "$plan_file" 2>/dev/null || req_msgs="${req_msgs} · 「R→VC 映射」标题行(^#{2,3})缺失（第 3 锚, CR P2-3 锚升级）"
      # [2026-10-05 task-v131 CR-fix P2-3] 第 4 锚「根源覆盖表」同升级为 ## 级标题行锚
      # `^##[^#].*根源覆盖表`(仅 ## 级, 排除 ### 及更深; 模板/注入脚手架/既有合规计划实测均匹配)。
      grep -qE '^##[^#].*根源覆盖表' "$plan_file" 2>/dev/null || req_msgs="${req_msgs} · 「🧮 根源覆盖表」## 标题行缺失（第 4 锚, Rule 53.1 载体；非结果级须写「不适用（非结果级）」+定性理由于表格区, 标题行在位即算在位）"
      if [ -n "$req_msgs" ]; then
        echo "[attest] ✗ 缺 Rule 51.1 用户需求原文区块或第 4 锚「🧮 根源覆盖表」（Rule 53.1 载体, critic P1-3 对称性修复）；mini 档豁免——先回炉补区块再锁定" >&2
        echo "[attest] ✗ 缺失锚:${req_msgs} (fail-closed 硬门, 无 --skip 逃生口; 补区块或声明 plan_tier: mini 后重 attest)" >&2
        exit 1
      fi
      echo "[attest] [requirement-gate] OK (Rule 51.1 三锚 + 第 4 锚「🧮 根源覆盖表」(Rule 53.1) 共四锚在位)"
    fi
    # [2026-09-16 task-v075 P4 B1] FMEA 门控(v063 fmea_enforce 首次消费; 与 check-complete.sh 终验双点):
    # 档位解析(挂载范式照抄上方 resolve_template_tier 段 :77-100):
    #   env TASK_PLANNER_FMEA_ENFORCE > config.json fmea_enforce.default > warn(jq 缺失回退 warn+一行说明)
    # off=完全跳过无输出; warn=失败打 [fmea-gate] ⚠ 后继续锁定; enforce=打 [fmea-gate] ✗ 后 exit 1
    # 校验对象=被 attest 的 task_plan.md:
    #   ① 含「📊 FMEA」段标题(固定锚 grep「FMEA 预演」)且 RPN 表数据行 ≥1
    #      (数据行=以 | 开头且第 6 数据列可解析为纯数字; 表头行第 6 列=RPN 表头文本、
    #       分隔行=短横线均不可解析, 天然排除; awk -F'|' 下 $7=第 6 数据列)
    #   ② RPN 数值 >100 的数据行, 其第 7 数据列(预设兜底动作)trim 后非空(KQ2 定死口径)
    # legacy 计划(无 `- **Executor:**` 行)对齐 check-plan-dispatch.sh:37-40 fail-open 先例 → 跳过
    # check-fmea-gate <plan>: 0=通过/不适用; 1=违规(stdout 列明违规行); 2=无 FMEA 段或数据行=0
    check-fmea-gate() {
      local pf="$1"
      grep -q 'FMEA 预演' "$pf" 2>/dev/null || { echo "无「📊 FMEA 预演」段标题"; exit 2; }
      local datanum=0
      local badlines=""
      local ln rpn fb
      while IFS= read -r ln; do
        [ -n "$ln" ] || continue
        rpn="$(printf '%s\n' "$ln" | awk -F'|' '{v=$7; gsub(/^[ \t]+|[ \t]+$/, "", v); print v}')"
        case "$rpn" in (*[!0-9]*|'') continue ;; esac
        datanum=$((datanum + 1))
        if [ "$rpn" -gt 100 ]; then
          fb="$(printf '%s\n' "$ln" | awk -F'|' '{v=$8; gsub(/^[ \t]+|[ \t]+$/, "", v); print v}')"
          [ -z "$fb" ] && badlines="${badlines}RPN=${rpn}(兜底动作列空) "
        fi
      done < <(grep '^|' "$pf" 2>/dev/null)
      [ "$datanum" -ge 1 ] || { echo "RPN 表数据行=0(须 ≥1)"; exit 2; }
      [ -n "$badlines" ] && { echo "RPN>100 行缺预设兜底: ${badlines% }"; exit 1; }
      return 0
    }
    if [ -n "$skip_fmea" ]; then
      echo "[fmea-gate] SKIPPED (--skip-fmea-check 逃生, fmea_enforce 门控被跳过, 须在交付报告披露)"
    else
      fcfg="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../config.json"
      resolve_fmea_tier() {
        local m="${TASK_PLANNER_FMEA_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$fcfg" ]; then
          m="$(jq -r '.properties.fmea_enforce.default // "warn"' "$fcfg" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
      }
      FTIER="$(resolve_fmea_tier)"
      if [ "$FTIER" != "off" ]; then
        if ! grep -qE '^- \*\*Executor:\*\*' "$plan_file" 2>/dev/null; then
          # [2026-09-16 task-v075 P4] legacy fail-open(对齐 check-plan-dispatch.sh:37-40 先例)
          : # legacy 计划无 FMEA 段 = 旧模板, 跳过门控
        else
          fmea_msgs="$(check-fmea-gate "$plan_file" 2>/dev/null)"; fmea_rc=$?
          case "$fmea_rc" in
            0)
              echo "[fmea-gate] OK (fmea_enforce=$FTIER)"
              ;;
            2)
              # [2026-09-20 task-v086 P2-S3 Rule 38.4①] mini 档 FMEA 豁免: RC=2=无「FMEA 预演」段或
              # RPN 表数据行=0 → mini 计划直接视为通过(打 SKIP 行); 非 mini 走下方 *) 原逻辑零改动;
              # RC=1(有 FMEA 段但违规, mini 填了就得合规)不豁免仍走 *)
              if grep -qm1 'plan_tier: mini' "$plan_file" 2>/dev/null; then
                echo "[fmea-gate] MINI-TIER SKIP (plan_tier: mini 豁免, Rule 38.4①)"
              else
                if [ "$FTIER" = "enforce" ]; then
                  echo "[fmea-gate] ✗ $fmea_msgs" >&2
                  echo "[fmea-gate] ✗ FMEA 门控失败,拒绝锁定(fmea_enforce=enforce; 补 FMEA 数据行/兜底或紧急 --skip-fmea-check)" >&2
                  exit 1
                else
                  echo "[fmea-gate] ⚠ $fmea_msgs (warn 档不阻断: TASK_PLANNER_FMEA_ENFORCE=enforce 或 config.json fmea_enforce=enforce 可升级; 紧急 --skip-fmea-check)" >&2
                fi
              fi
              ;;
            *)
              if [ "$FTIER" = "enforce" ]; then
                echo "[fmea-gate] ✗ $fmea_msgs" >&2
                echo "[fmea-gate] ✗ FMEA 门控失败,拒绝锁定(fmea_enforce=enforce; 补 FMEA 数据行/兜底或紧急 --skip-fmea-check)" >&2
                exit 1
              else
                echo "[fmea-gate] ⚠ $fmea_msgs (warn 档不阻断: TASK_PLANNER_FMEA_ENFORCE=enforce 或 config.json fmea_enforce=enforce 可升级; 紧急 --skip-fmea-check)" >&2
              fi
              ;;
          esac
        fi
      fi
    fi
    # [2026-10-04 task-v128 D3] Rule 编号查重段(Rule 20.6, fail-open):
    # 全仓计划锁定入口, 稳定性优先 —— rule-reserve.sh 缺失 / 查重失败 / 账本损坏
    # → 打印 SKIPPED 并继续锁定(knowledge-brief §4-1, 禁阻断全仓 attest)。
    # 解析 new_rule 两种声明形态(对齐 check-template-type.sh 三形态先例 :20-30):
    #   ① HTML 注释 `<!-- new_rule: <N> -->` ② 配置表行 `| `new_rule` | <N> |`
    # 值为 none/缺失 → 整段跳过零输出(F4 逐字节 diff 零硬门, 老计划行为不变)
    new_rule="$(grep -m1 -oE '<!--[[:space:]]*new_rule:[[:space:]]*[A-Za-z0-9-]+' "$plan_file" 2>/dev/null | sed 's/.*new_rule:[[:space:]]*//')"
    if [ -z "$new_rule" ]; then
      new_rule="$(grep -m1 -E '^[[:space:]]*\|[[:space:]]*`?new_rule`?' "$plan_file" 2>/dev/null | awk -F'|' '{gsub(/[[:space:]`]/, "", $3); print $3}')"
    fi
    case "$new_rule" in
      ''|none|None|NONE|留空)
        : # 未声明/显式 none → 零输出(F4)
        ;;
      *[!0-9]*)
        echo "[rule-reserve] SKIPPED (new_rule 解析失败: '${new_rule}', fail-open 继续, Rule 20.6)" >&2
        ;;
      *)
        rr="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/rule-reserve.sh"
        if [ ! -f "$rr" ]; then
          echo "[rule-reserve] SKIPPED (rule-reserve.sh 缺失, fail-open 继续, Rule 20.6)" >&2
        else
          rr_task="$(basename "$plan_dir")"
          # 账本路径 env 透传: RULE_RESERVE_LEDGER 由调用方设置(测试台阶=/tmp 临时账本),
          # 未设置时 rule-reserve.sh 走 CWD 祖先 plans/ 解析三级链(D2 契约)
          rr_out="$(bash "$rr" check "$new_rule" 2>&1)"; rr_rc=$?
          # check 非 0 且输出无「rule <N>」持有人行 = 查重自身失败(账本损坏/路径解析失败) → fail-open
          if [ "$rr_rc" -ne 0 ] && ! printf '%s\n' "$rr_out" | grep -q "rule ${new_rule}"; then
            echo "[rule-reserve] SKIPPED (查重失败 fail-open: ${rr_out:-无输出}, Rule 20.6)" >&2
          else
            case "$rr_rc" in
              0)
                # 空闲 → 自动登记(D3 ③)
                rr_rev="$(bash "$rr" reserve "$new_rule" "$rr_task" 2>&1)"; rr_rev_rc=$?
                if [ "$rr_rev_rc" -eq 0 ]; then
                  echo "[rule-reserve] INFO: rule ${new_rule} 空闲 → 自动登记 (task=${rr_task}, 账本见 rule-reserve.sh)"
                else
                  # 登记自身失败(竞态被他人抢占等) → fail-open 不阻断
                  echo "[rule-reserve] SKIPPED (登记失败 fail-open: ${rr_rev:-无输出})" >&2
                fi
                ;;
              3)
                # 被持有(D3 ④/⑤): 持有人=本任务 → INFO 已登记(幂等, 含 contested 本任务在 claimants);
                # 他人持有/contested → WARN + next 建议, 默认不阻断
                if printf '%s\n' "$rr_out" | grep -qE "held by ${rr_task}[[:space:]]*\(|contested\[[^]]*${rr_task}"; then
                  echo "[rule-reserve] INFO: rule ${new_rule} 已由本任务登记/持有 (${rr_out}; task=${rr_task})"
                else
                  rr_next="$(bash "$rr" next 2>/dev/null)"
                  echo "[rule-reserve] WARN: ${rr_out} (task=${rr_task}; 建议改号 next=${rr_next:-?}; 默认不阻断, TASK_PLANNER_RULE_RESERVE_STRICT=1 可阻断)" >&2
                  if [ "${TASK_PLANNER_RULE_RESERVE_STRICT:-0}" = "1" ]; then
                    echo "[attest] ✗ Rule 编号冲突: new_rule=${new_rule} 被持有/contested, 拒绝锁定 (Rule 20.6, TASK_PLANNER_RULE_RESERVE_STRICT=1; 改号或用 \`rule-reserve.sh next\` 取建议号后重 attest)" >&2
                    exit 2
                  fi
                fi
                ;;
              *)
                # 非 0/3 的异常退出码(用法/IO 等) → fail-open
                echo "[rule-reserve] SKIPPED (rule-reserve.sh check exit ${rr_rc}: ${rr_out:-无输出}, fail-open 继续, Rule 20.6)" >&2
                ;;
            esac
          fi
        fi
        ;;
    esac
    hash="$(sha256sum "$plan_file" | awk '{print $1}')"
    # Why（task-v115 线C 补强）: 先哈希后写——哈希取的是通过 S-unit/模板/51.1 需求区块/FMEA
    # 四道前置门之后的
    # 计划内容；若先写 attestation 再跑门控，门失败退出时留下一份锁定着「未获批计划」的哈希，
    # 后续 hook 会把未获批内容当事实源注入（篡改语义等价）。锁定动作必须是批准流程的终点。
    # [2026-09-13 task-v068 E2] 追加 attested_by_sid 字段: 记录锁定时会话 sid(同 sid 获取链,
    # 无 sid 时空串;向后兼容: verify 仅读 plan_sha256, 旧 attestation 无此字段不影响校验)
    attest_sid="${ZCODE_SESSION_ID:-${CLAUDE_SESSION_ID:-}}"
    printf 'plan_sha256=%s\nplan_file=%s\nattested_at=%s\nattested_by_sid=%s\n' "$hash" "$(cd "$plan_dir" && pwd)/$(basename "$plan_file")" "$(date -Iseconds)" "$attest_sid" > "$attest_file"
    echo "[attest] ✅ 计划已锁定: $plan_file"
    echo "[attest]   SHA-256: $hash"
    echo "[attest]   存储于: $attest_file(计划重规划并重新获批后重跑本命令更新锁定)"
    ;;
  show)
    if [ -f "$attest_file" ]; then cat "$attest_file"; else echo "[attest] 未锁定: $attest_file 不存在"; exit 2; fi
    ;;
  clear)
    # Why（task-v115 线C 补强）: --clear 幂等设计——锁定文件不存在时不报错而是提示「无锁定可清除」
    # 并 exit 0：重规划流程常连跑「clear → 重新 attest」，中间态（已清/从未锁）必须可重复执行；
    # 若 clear 失败路径 exit 非 0，重规划脚本链会误报失败阻断重新批准流程。
    if [ -f "$attest_file" ]; then rm "$attest_file" && echo "[attest] 已清除: $attest_file"; else echo "[attest] 无锁定可清除"; fi
    ;;
  verify)
    [ -f "$attest_file" ] || exit 2
    stored="$(grep '^plan_sha256=' "$attest_file" | head -1 | cut -d= -f2)"
    [ -z "$stored" ] && exit 2
    actual="$(sha256sum "$plan_file" | awk '{print $1}')"
    [ "$stored" = "$actual" ] && exit 0 || exit 1
    ;;
esac
exit 0
