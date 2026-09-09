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
# 约束:fail-open 不适用本脚本(写操作需明确);被 hook 调用(--verify)时任何异常 exit 2 视为"未锁定"。
set -uo pipefail

plan_file=""
mode="attest"
skip_dispatch=""
for arg in "$@"; do
  case "$arg" in
    --show) mode="show" ;;
    --verify) mode="verify" ;;
    --clear) mode="clear" ;;
    --skip-dispatch-check) skip_dispatch=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \?//'; exit 0 ;;
    *) plan_file="$arg" ;;
  esac
done

# ─── 探测活跃计划(未显式给路径时)────────────────────────────────────────
if [ -z "$plan_file" ]; then
  if [ -d "plans" ]; then
    plan_file="$(ls -t plans/*/task_plan.md 2>/dev/null | head -1)"
  fi
  [ -z "$plan_file" ] && [ -f "task_plan.md" ] && plan_file="task_plan.md"
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
    hash="$(sha256sum "$plan_file" | awk '{print $1}')"
    printf 'plan_sha256=%s\nplan_file=%s\nattested_at=%s\n' "$hash" "$(cd "$plan_dir" && pwd)/$(basename "$plan_file")" "$(date -Iseconds)" > "$attest_file"
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
