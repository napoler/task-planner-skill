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
# 约束:fail-open 不适用本脚本(写操作需明确);被 hook 调用(--verify)时任何异常 exit 2 视为"未锁定"。
set -uo pipefail

plan_file=""
mode="attest"
skip_dispatch=""
skip_template=""
for arg in "$@"; do
  case "$arg" in
    --show) mode="show" ;;
    --verify) mode="verify" ;;
    --clear) mode="clear" ;;
    --skip-dispatch-check) skip_dispatch=1 ;;
    --skip-template-check) skip_template=1 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \?//'; exit 0 ;;
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
      [ -x "$cpl" ] && { bash "$cpl" "$plan_file" || { echo "[attest] ✗ 派发型 Phase 未规划子代理,拒绝锁定(Rule 22.6/25.1);紧急 --skip-dispatch-check(将记 ledger 告警)" >&2; exit 1; }; }
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
        [ -x "$ctt" ] && { bash "$ctt" "$plan_file"; t_rc=$?; } || t_rc=0
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
    hash="$(sha256sum "$plan_file" | awk '{print $1}')"
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
