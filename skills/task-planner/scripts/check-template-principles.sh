#!/bin/bash
# check-template-principles.sh — 原则→模板区块覆盖守卫（spec_version=1）
# [2026-11-25 task-json-template P5] JSON 模板优先：白名单/段锚/lineage 从 templates/json/*.template.json 的
#   meta.lineage + sections[].anchor 读；无对应 JSON 才回退旧 MD 注释（旧计划/自造模板兼容）。
# WHY: JSON 已成为模板权威源；若只读 MD，JSON-only 模板会被误判缺 lineage/区块，pruned 段会被误判缺失。
# 读 principle-template-registry.md，对 base+derived 模板校验必选原则载体。
# 退出码：0=全绿(PRINCIPLES-COVERAGE PASS)，1=存在 enforce 缺失；warn 仅输出不计 FAIL。
# 用法：
#   bash check-template-principles.sh            # 实跑（相对脚本定位仓库根）
#   bash check-template-principles.sh --selftest-smoke  # 正反夹具自验（临时目录，用完即清理）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
REGISTRY="$REPO_ROOT/skills/plan-template-kit/references/principle-template-registry.md"

usage() {
  echo "Usage: $0 [--selftest-smoke]" >&2
}

# print check results; sets globals FAIL_COUNT WARN_COUNT
FAIL_COUNT=0
WARN_COUNT=0
FAIL_ITEMS=()
WARN_ITEMS=()

reset_counts() { FAIL_COUNT=0; WARN_COUNT=0; FAIL_ITEMS=(); WARN_ITEMS=(); }

# [2026-11-25 P5] JSON 真源映射：base=task_plan.template.json，derived=<type>.template.json；无 JSON 返回空串。
json_for_template() { # md-file -> json-file|""
  local b="$1"
  [ -n "${JSON_DIR:-}" ] || { printf '%s' ""; return 0; }
  b="$(basename "$b")"
  case "$b" in
    task_plan.md) printf '%s' "${JSON_DIR:-}/task_plan.template.json" ;;
    *-type.md) printf '%s' "${JSON_DIR:-}/${b%-type.md}.template.json" ;;
    *) printf '%s' "" ;;
  esac
}

# [2026-11-25 P5] 模板可读文本：优先 JSON 的 sections[].anchor + 规范化 lineage 行，缺 JSON 才 cat 旧 MD。
# 用 shell grep/sed 逐字段读，不依赖 Python；JSON 是紧凑单行，字段边界由正则限定。
template_text() { # file -> text
  local f="$1" jf anchors lineage lvl parent base sv pruned
  jf="$(json_for_template "$f")"
  if [ -z "$jf" ] || [ ! -f "$jf" ]; then
    cat "$f" 2>/dev/null || true
    return 0
  fi
  anchors="$(grep -oE '"anchor":"[^"]*"' "$jf" | sed 's/^"anchor":"//;s/"$//' || true)"
  lineage="$(grep -oE '"lineage":\{[^}]*\}' "$jf" || true)"
  lvl="$(printf '%s' "$lineage" | grep -oE '"level":"[^"]*"' | head -n1 | cut -d'"' -f4 || true)"
  parent="$(printf '%s' "$lineage" | grep -oE '"parent":"[^"]*"' | head -n1 | cut -d'"' -f4 || true)"
  base="$(printf '%s' "$lineage" | grep -oE '"base":"[^"]*"' | head -n1 | cut -d'"' -f4 || true)"
  sv="$(printf '%s' "$lineage" | grep -oE '"spec_version":[0-9]+' | head -n1 | cut -d: -f2 || true)"
  pruned="$(grep -oE '"pruned":\[[^]]*\]' "$jf" | sed 's/^"pruned":\[//;s/\]$//;s/"//g' || true)"
  printf '%s\n' "$anchors" "template-lineage: level=$lvl parent=$parent base=$base spec_version=$sv pruned=\"$pruned\""
}

# [2026-11-25 P5] JSON lineage.pruned 是有意裁剪清单，命中即不算缺失（MD 无此机制保持旧行为）。
pruned_allows() { # file token
  local jf pruned p token_nospace
  jf="$(json_for_template "$1")"
  [ -f "$jf" ] || return 1
  pruned="$(grep -oE '"pruned":\[[^]]*\]' "$jf" | sed 's/^"pruned":\[//;s/\]$//;s/"//g' || true)"
  [ -n "$pruned" ] || return 1
  token_nospace="${2//[[:space:]]/}"
  for p in ${pruned//,/ }; do
    [ -n "$p" ] || continue
    if [[ "$token_nospace" == *"$p"* ]]; then
      return 0
    fi
  done
  return 1
}

has_token() { # file token
  local text
  text="$(template_text "$1")"
  [[ "$text" == *"$2"* ]]
}

has_exempt() { # file keyword (principle/section hint)
  local text
  text="$(template_text "$1")"
  [[ "$text" == *'<!-- principle-exempt:'* && "$text" == *"$2"* ]]
}

check_enforce_token() { # file token label scope(is base/derived name)
  local f="$1" token="$2" label="$3" scope="$4"
  if has_token "$f" "$token" || pruned_allows "$f" "$token"; then
    return 0
  fi
  # try exemption by token or label keywords
  if has_exempt "$f" "$token" || has_exempt "$f" "$label"; then
    return 0
  fi
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAIL_ITEMS+=("$scope :: 缺失原则载体[$label] token=[$token]")
  return 1
}

check_warn_token() { # file token label scope
  local f="$1" token="$2" label="$3" scope="$4"
  if has_token "$f" "$token" || pruned_allows "$f" "$token"; then
    return 0
  fi
  if has_exempt "$f" "$token" || has_exempt "$f" "$label"; then
    return 0
  fi
  WARN_COUNT=$((WARN_COUNT + 1))
  WARN_ITEMS+=("$scope :: warn-缺失[$label] token=[$token]")
  return 0
}

is_exempt_variant_name() { # basename
  local b="$1"
  case ",$EXEMPT_VARIANTS_CSV," in
    *,"$b",*) return 0 ;;
    *) return 1 ;;
  esac
}

run_checks() {
  local root="$1" registry="$2"
  reset_counts
  # defaults aligned to spec_version=1 registry
  BASE_REL="skills/task-planner/templates/task_plan.md"
  VARIANT_REL="skills/task-planner/templates/variant"
  # [2026-11-25 P5] JSON 权威模板目录（run_checks 的 root 可为 selftest 临时仓，故从 root 派生）
  JSON_DIR="$root/skills/task-planner/templates/json"
  EXEMPT_VARIANTS_CSV="mini-lite-type.md,l0-lite-type.md"
  OUTPUT_EXAMPLE_TOKEN="🧩 输出示例与格式契约"
  # parse registry assertions if present (lightweight)
  if [ -f "$registry" ]; then
    local inblock=0 line
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in
        '```registry-assertions') inblock=1; continue ;;
        '```') if [ $inblock -eq 1 ]; then inblock=0; fi; continue ;;
      esac
      if [ $inblock -eq 1 ]; then
        case "$line" in
          BASE_TEMPLATE=*) BASE_REL="${line#BASE_TEMPLATE=}" ;;
          VARIANT_DIR=*) VARIANT_REL="${line#VARIANT_DIR=}" ;;
          EXEMPT_VARIANTS=*) EXEMPT_VARIANTS_CSV="${line#EXEMPT_VARIANTS=}" ;;
          OUTPUT_EXAMPLE_TOKEN=*) OUTPUT_EXAMPLE_TOKEN="${line#OUTPUT_EXAMPLE_TOKEN=}" ;;
        esac
      fi
    done < "$registry"
  fi

  local base="$root/$BASE_REL"
  local vdir="$root/$VARIANT_REL"

  # base checks (enforce). 指令理解迭代 in-flight base exempt per registry note -> not enforced.
  if [ ! -f "$base" ]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAIL_ITEMS+=("base :: 缺失文件[$BASE_REL]")
  else
    check_enforce_token "$base" "level=base" "lineage(base)" "base:$BASE_REL" || true
    check_enforce_token "$base" "📦 进度产出基线" "防倒退-进度产出基线" "base:$BASE_REL" || true
    check_enforce_token "$base" "🛡 防倒退终检" "防倒退-终检" "base:$BASE_REL" || true
    check_enforce_token "$base" "🔒 规范基线" "规范基线" "base:$BASE_REL" || true
    check_enforce_token "$base" "🎯 用户需求原文" "用户需求原文" "base:$BASE_REL" || true
    check_enforce_token "$base" "🧮 根源覆盖表" "根源覆盖" "base:$BASE_REL" || true
    check_enforce_token "$base" "🎯 Goal 单元表" "Goal 单元" "base:$BASE_REL" || true
    check_enforce_token "$base" "✅ Verification Contract" "验证契约" "base:$BASE_REL" || true
    check_enforce_token "$base" "📊 FMEA 预演" "FMEA 预演" "base:$BASE_REL" || true
    check_enforce_token "$base" "🔍 证据面清单" "证据锚/证据面" "base:$BASE_REL" || true
    # [2026-11-25 task-output-example-contract] Rule 113 输出示例契约（base enforce）。
    check_enforce_token "$base" "$OUTPUT_EXAMPLE_TOKEN" "输出示例契约(Rule 113)" "base:$BASE_REL" || true
  fi

  # derived checks
  if [ ! -d "$vdir" ]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    FAIL_ITEMS+=("derived :: 缺失目录[$VARIANT_REL]")
  else
    local f b
    for f in "$vdir"/*.md; do
      [ -e "$f" ] || continue
      b="$(basename "$f")"
      # [2026-11-25 task-output-example-contract] Rule 113 全档必填（用户明确要求「所有计划任务都包含完整示例」）：
      #   豁免档只跳过其他原则，输出示例契约不豁免——先于 continue 检查。
      check_enforce_token "$f" "$OUTPUT_EXAMPLE_TOKEN" "输出示例契约(Rule 113)" "derived:$VARIANT_REL/$b" || true
      if is_exempt_variant_name "$b"; then
        continue
      fi
      # lineage 列 = enforce FAIL（derived 治理核心）
      if ! has_token "$f" "template-lineage"; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAIL_ITEMS+=("derived:$VARIANT_REL/$b :: 缺失原则载体[lineage] token=[template-lineage]")
        continue
      fi
      check_enforce_token "$f" "template-lineage" "lineage(derived)" "derived:$VARIANT_REL/$b" || true
      # warn 列输出计数不计 FAIL：derived 原则区块按逐步补齐口径（S5 落地阈值，防一次性阻塞）
      check_warn_token "$f" "🔒 规范基线" "规范基线" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "🎯 用户需求原文" "用户需求原文" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "🧮 根源覆盖表" "根源覆盖" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "🎯 Goal 单元表" "Goal 单元" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "✅ Verification Contract" "验证契约" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "📊 FMEA 预演" "FMEA 预演" "derived:$VARIANT_REL/$b" || true
      check_warn_token "$f" "🔍 证据面清单" "证据锚/证据面" "derived:$VARIANT_REL/$b" || true
      # 防倒退 pointer warn-only for derived（当前 3/29，逐步补齐后再翻 enforce）
      check_warn_token "$f" "进度产出基线" "防倒退-指针" "derived:$VARIANT_REL/$b" || true
    done
  fi

  # output
  if [ ${#WARN_ITEMS[@]} -gt 0 ]; then
    local w
    for w in "${WARN_ITEMS[@]}"; do
      echo "[principles][WARN] $w"
    done
  fi
  if [ ${#FAIL_ITEMS[@]} -gt 0 ]; then
    local e
    for e in "${FAIL_ITEMS[@]}"; do
      echo "[principles][FAIL] $e"
    done
  fi
  echo "[principles] summary: fail=$FAIL_COUNT warn=$WARN_COUNT"
  if [ $FAIL_COUNT -eq 0 ]; then
    echo "PRINCIPLES-COVERAGE PASS"
    return 0
  else
    echo "PRINCIPLES-COVERAGE FAIL"
    return 1
  fi
}

run_selftest_smoke() {
  local tmp rc_ok=0 rc_bad=0
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  mkdir -p "$tmp/skills/task-planner/templates/variant" "$tmp/skills/plan-template-kit/references"
  cat > "$tmp/skills/plan-template-kit/references/principle-template-registry.md" <<'REG'
# registry (smoke)
```registry-assertions
SPEC_VERSION=1
BASE_TEMPLATE=skills/task-planner/templates/task_plan.md
VARIANT_DIR=skills/task-planner/templates/variant
EXEMPT_VARIANTS=mini-lite-type.md,l0-lite-type.md
OUTPUT_EXAMPLE_TOKEN=🧩 输出示例与格式契约
```
REG
  # OK base fixture
  cat > "$tmp/skills/task-planner/templates/task_plan.md" <<'EOF'
# Task Plan
<!-- template-lineage: level=base spec_version=1 -->
## 📦 进度产出基线
## 🔒 规范基线
## 🎯 用户需求原文
## 🧮 根源覆盖表
## 🎯 Goal 单元表
## ✅ Verification Contract
## 📊 FMEA 预演
## 🔍 证据面清单
## 🛡 防倒退终检
## 🧩 输出示例与格式契约
EOF
  # OK derived fixture
  cat > "$tmp/skills/task-planner/templates/variant/ok-type.md" <<'EOF'
# ok
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 -->
## 🔒 规范基线
## 🎯 用户需求原文
## 🧮 根源覆盖表
## 🎯 Goal 单元表
## ✅ Verification Contract
## 📊 FMEA 预演
## 🔍 证据面清单
## 🧩 输出示例与格式契约
防倒退：进度产出基线指针
EOF
  # exempt variants (skipped for other principles, but Rule 113 output-example is mandatory for all)
  cat > "$tmp/skills/task-planner/templates/variant/mini-lite-type.md" <<'EOF'
# mini-lite exempt
## 🧩 输出示例与格式契约（Rule 113 · 极简档）
EOF
  cat > "$tmp/skills/task-planner/templates/variant/l0-lite-type.md" <<'EOF'
# l0-lite exempt
## 🧩 输出示例与格式契约（Rule 113 · 极简档）
EOF

  echo "[smoke] case-1: all-ok fixture expects PASS"
  if run_checks "$tmp" "$tmp/skills/plan-template-kit/references/principle-template-registry.md" >/tmp/_tp_smoke_ok.$$ 2>&1; then
    if grep -q "PRINCIPLES-COVERAGE PASS" /tmp/_tp_smoke_ok.$$; then
      echo "  [smoke][PASS] all-ok"
      rc_ok=1
    else
      echo "  [smoke][FAIL] all-ok missing PASS marker" >&2
      cat /tmp/_tp_smoke_ok.$$ >&2
    fi
  else
    echo "  [smoke][FAIL] all-ok returned non-zero" >&2
    cat /tmp/_tp_smoke_ok.$$ >&2
  fi

  # break fixture: remove enforce block from base
  echo "[smoke] case-2: missing-block fixture expects FAIL"
  # create broken base missing 终检
  cat > "$tmp/skills/task-planner/templates/task_plan.md" <<'EOF'
# Task Plan
<!-- template-lineage: level=base spec_version=1 -->
## 📦 进度产出基线
## 🔒 规范基线
## 🎯 用户需求原文
## 🧮 根源覆盖表
## 🎯 Goal 单元表
## ✅ Verification Contract
## 📊 FMEA 预演
## 🔍 证据面清单
EOF
  if run_checks "$tmp" "$tmp/skills/plan-template-kit/references/principle-template-registry.md" >/tmp/_tp_smoke_bad.$$ 2>&1; then
    echo "  [smoke][FAIL] missing-block unexpectedly PASS" >&2
    cat /tmp/_tp_smoke_bad.$$ >&2
  else
    if grep -q "PRINCIPLES-COVERAGE FAIL" /tmp/_tp_smoke_bad.$$ && grep -q "防倒退-终检" /tmp/_tp_smoke_bad.$$; then
      echo "  [smoke][PASS] missing-block"
      rc_bad=1
    else
      echo "  [smoke][FAIL] missing-block wrong output" >&2
      cat /tmp/_tp_smoke_bad.$$ >&2
    fi
  fi

  rm -f /tmp/_tp_smoke_ok.$$ /tmp/_tp_smoke_bad.$$
  if [ $rc_ok -eq 1 ] && [ $rc_bad -eq 1 ]; then
    echo "SELFTEST-SMOKE PASS"
    return 0
  else
    echo "SELFTEST-SMOKE FAIL"
    return 1
  fi
}

main() {
  if [ "${1:-}" = "--selftest-smoke" ]; then
    run_selftest_smoke
    exit $?
  elif [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage; exit 0
  elif [ -n "${1:-}" ]; then
    usage; exit 2
  fi
  run_checks "$REPO_ROOT" "$REGISTRY"
}

main "$@"
