#!/usr/bin/env bash
# check-lazy-refs.sh — Rule 116 惰性文件引入机器门（L1-L4, fail-closed）
#
# What:
#   扫描 --root 下各技能的惰性引用指针行，执行 L1-L4 四项判定：
#     L1 路径存在：指针行提取路径 token → test -f（多基解析：技能根/文件所在目录/仓根）
#     L2 触发标记：SKILL.md 常载面指针行含 `触发：` token（全角/半角冒号均认）
#     L3 简介存在：行内剥离路径与触发段后实质描述字符 ≥6
#     L4 可达性：references/**/*.md 惰性文件须有来自同技能 SKILL.md 的带触发指针；无 = 不可达死文件 FAIL
#   指针行判定 = 行内含 .md/.sh/.json 路径 token 且含惰性语义词
#     （按需加载/按需 Read/详见/需要时读/需要时加载/→ 见）。
#   豁免 token：lazyref-exempt（行内）跳过判定。
#
# Why:
#   惰性文件自身不被加载时其内部触发描述永远不可见（Rule 116.1 常载面判定原则）。
#   门将“触发判定信息挂常载面”从文本承诺升级为可机器判的 fail-closed 前置条件。
#
# Usage:
#   bash check-lazy-refs.sh [--root <skills-dir>]
#     --root  扫描根目录（默认：相对仓根的 skills/；不存在则 fallback 当前 cwd/skills）
#
# Output:
#   [lazyref] FAIL [L?] <location> <reason>
#   [lazyref] PASS [L?] ...（可选，细节行）
#   [lazyref] summary: N pass / M fail, rc=R
#
# Exit: 0=全过  1=任一 FAIL（fail-closed）  2=用法/输入错误

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 仓根推断：scripts/ -> skill-root -> skills/ -> repo-root
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { echo "[lazyref] ERROR: --root requires a value" >&2; exit 2; }
      ROOT="$2"; shift 2 ;;
    --root=*)
      ROOT="${1#--root=}"; shift ;;
    -h|--help)
      sed -n '2,40p' "$0"; exit 0 ;;
    *)
      echo "[lazyref] ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$ROOT" ]; then
  if [ -d "$REPO_ROOT/skills" ]; then
    ROOT="$REPO_ROOT/skills"
  elif [ -d "$PWD/skills" ]; then
    ROOT="$PWD/skills"
  else
    ROOT="$PWD"
  fi
fi

if [ ! -d "$ROOT" ]; then
  echo "[lazyref] ERROR: --root not a directory: $ROOT" >&2
  exit 2
fi
ROOT="$(cd "$ROOT" && pwd)"
# repo root for L1 multi-base: prefer git toplevel from ROOT, else inferred
if git -C "$ROOT" rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$ROOT" rev-parse --show-toplevel)"
else
  # fallback: if ROOT ends with /skills, parent; else ROOT
  case "$ROOT" in
    */skills) REPO_ROOT="$(cd "$ROOT/.." && pwd)" ;;
    *) REPO_ROOT="$ROOT" ;;
  esac
fi

PASS_COUNT=0
FAIL_COUNT=0
FAIL_LINES=()

emit_fail() {
  local code="$1" loc="$2" reason="$3"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAIL_LINES+=("[lazyref] FAIL [$code] $loc $reason")
}

emit_pass() {
  local code="$1" loc="$2" reason="$3"
  PASS_COUNT=$((PASS_COUNT + 1))
  # pass lines kept quiet by default? spec says "FAIL/PASS 行+summary+rc" - emit pass for traceability
  printf '[lazyref] PASS [%s] %s %s\n' "$code" "$loc" "$reason"
}

# Lazy semantic words (pointer line判定)
has_lazy_semantic() {
  local line="$1"
  printf '%s' "$line" | grep -qE '按需加载|按需 Read|详见|需要时读|需要时加载|→ 见'
}

# Trigger token (L2): fullwidth or halfwidth colon
has_trigger_token() {
  local line="$1"
  printf '%s' "$line" | grep -qE '触发：|触发:'
}

# Extract path tokens from a line (.md/.sh/.json) - outputs one per line
extract_path_tokens() {
  local line="$1"
  # grab tokens that look like paths ending in .md/.sh/.json, allow common path chars
  # strip surrounding backticks, quotes, parens, brackets, commas, semicolons
  printf '%s\n' "$line" \
    | grep -oE '[A-Za-z0-9_./@+-]+[.](md|sh|json)' \
    | sed -E 's#^[./]+##' \
    | awk '!seen[$0]++'
}

# Runtime compass files (non-repo runtime artifacts) - skip L1
is_runtime_compass_file() {
  case "$1" in
    task_plan.md|plan-state.json|findings.md|progress.md|verification.md|user-session-log.md|knowledge-brief.md|notepad-learnings.md)
      return 0 ;;
  esac
  return 1
}

# Resolve path token against multi-base: skill root / file dir / repo root
# + bare-filename calibration: bare .sh -> <skill-root>/scripts/; bare .md -> <skill-root>/references/
resolve_path() {
  local token="$1" skill_root="$2" file_dir="$3"
  local cand base
  base="$(basename "$token")"
  for cand in \
    "$skill_root/$token" \
    "$file_dir/$token" \
    "$REPO_ROOT/$token" \
    "$ROOT/$token" \
    "$REPO_ROOT/skills/$token" \
    "$(dirname "$skill_root")/$token" \
    "$skill_root/${token#./}" \
    "$file_dir/${token#./}"
  do
    if [ -f "$cand" ]; then
      printf '%s' "$cand"
      return 0
    fi
  done
  # Bare filename extension-based skill subdir bases (S5-fixup calibration)
  if [ "$base" = "$token" ]; then
    case "$token" in
      *.sh)
        for cand in "$skill_root/scripts/$token" "$file_dir/scripts/$token"; do
          if [ -f "$cand" ]; then printf '%s' "$cand"; return 0; fi
        done
        ;;
      *.md)
        for cand in "$skill_root/references/$token" "$file_dir/references/$token"; do
          if [ -f "$cand" ]; then printf '%s' "$cand"; return 0; fi
        done
        ;;
      *.json)
        for cand in "$skill_root/config/$token" "$skill_root/assets/$token"; do
          if [ -f "$cand" ]; then printf '%s' "$cand"; return 0; fi
        done
        ;;
    esac
  fi
  # also try as-is if absolute-ish under root
  if [ -f "$token" ]; then printf '%s' "$token"; return 0; fi
  return 1
}

# Substantive description length after stripping path tokens and trigger segment (L3)
# L3: "行内剥离路径与触发段后实质描述字符 ≥6"
substantive_desc_len() {
  local line="$1"
  local s="$line"
  # remove trigger segment: from '触发：' or '触发:' to end (or to '关键词：' if present - keep simple: strip from trigger token onward)
  s="$(printf '%s' "$s" | sed -E 's/[；;]?[[:space:]]*触发[：:].*$//')"
  # remove path tokens
  s="$(printf '%s' "$s" | sed -E 's#[A-Za-z0-9_./@+-]+[.](md|sh|json)##g')"
  # remove common pointer markers / punctuation / markdown list markers / backticks
  s="$(printf '%s' "$s" | sed -E 's/[`|>→#*-]//g; s/详见|按需加载|按需 Read|需要时读|需要时加载|见//g; s/[[:space:][:punct:]：；，。()（）【】\[\]]//g')"
  # count chars (unicode-safe via python3 fallback, else wc -m)
  local n
  if command -v python3 >/dev/null 2>&1; then
    n="$(printf '%s' "$s" | python3 -c 'import sys; print(len(sys.stdin.read().strip()))')"
  else
    n="$(printf '%s' "$s" | wc -m | tr -d ' ')"
  fi
  printf '%s' "${n:-0}"
}

# Determine if a SKILL.md line is a pointer line to be judged
is_pointer_line() {
  local line="$1"
  # exempt
  printf '%s' "$line" | grep -qF 'lazyref-exempt' && return 1
  # must contain path token
  printf '%s' "$line" | grep -qE '[A-Za-z0-9_./@+-]+[.](md|sh|json)' || return 1
  # must contain lazy semantic word
  has_lazy_semantic "$line" || return 1
  return 0
}

# Collect skills: directories under ROOT that contain SKILL.md
mapfile -t SKILL_FILES < <(find "$ROOT" -mindepth 2 -maxdepth 2 -name 'SKILL.md' -type f | sort)

if [ ${#SKILL_FILES[@]} -eq 0 ]; then
  # also try ROOT itself if it is a skill dir
  if [ -f "$ROOT/SKILL.md" ]; then
    SKILL_FILES=("$ROOT/SKILL.md")
  fi
fi

# If still none, maybe --root points at repo containing skills/*; look one deeper
if [ ${#SKILL_FILES[@]} -eq 0 ]; then
  mapfile -t SKILL_FILES < <(find "$ROOT" -mindepth 3 -maxdepth 3 -name 'SKILL.md' -type f | sort)
fi

checked_any=0

for skill_md in "${SKILL_FILES[@]}"; do
  skill_root="$(dirname "$skill_md")"
  skill_rel="${skill_root#"$REPO_ROOT"/}"
  [ "$skill_rel" = "$skill_root" ] && skill_rel="$skill_root"

  # ---- L1/L2/L3 on SKILL.md pointer lines ----
  line_no=0
  while IFS= read -r line || [ -n "$line" ]; do
    line_no=$((line_no + 1))
    is_pointer_line "$line" || continue
    checked_any=1
    loc="$skill_rel/SKILL.md:$line_no"

    # Extract path tokens
    mapfile -t tokens < <(extract_path_tokens "$line")
    if [ ${#tokens[@]} -eq 0 ]; then
      emit_fail "L1" "$loc" "pointer line has no extractable .md/.sh/.json path token"
      continue
    fi

    # L1: each token must resolve (runtime compass files skipped - not repo lazy refs)
    l1_ok=1
    l1_checked=0
    for tok in "${tokens[@]}"; do
      tok_base="$(basename "$tok")"
      if is_runtime_compass_file "$tok_base"; then
        continue
      fi
      l1_checked=1
      if ! resolve_path "$tok" "$skill_root" "$skill_root" >/dev/null 2>&1; then
        emit_fail "L1" "$loc" "dead path token '$tok' (multi-base: skill-root/file-dir/repo-root)"
        l1_ok=0
      fi
    done
    if [ "$l1_ok" -eq 1 ]; then
      if [ "$l1_checked" -eq 1 ]; then
        emit_pass "L1" "$loc" "path exists (${tokens[*]})"
      else
        emit_pass "L1" "$loc" "runtime-compass tokens only, L1 skipped (${tokens[*]})"
      fi
    fi

    # L2: trigger token
    if has_trigger_token "$line"; then
      emit_pass "L2" "$loc" "has trigger token"
    else
      emit_fail "L2" "$loc" "missing trigger token '触发：' (lazy pointer must declare trigger on always-loaded surface)"
    fi

    # L3: substantive description >= 6 chars after stripping path+trigger
    desc_len="$(substantive_desc_len "$line")"
    if [ "$desc_len" -ge 6 ]; then
      emit_pass "L3" "$loc" "substantive desc len=$desc_len"
    else
      emit_fail "L3" "$loc" "substantive description too short after stripping path+trigger (len=$desc_len, need>=6)"
    fi
  done < "$skill_md"

  # ---- L4: each references/**/*.md must be reachable from SKILL.md with filename+触发 ----
  if [ -d "$skill_root/references" ]; then
    while IFS= read -r ref_file; do
      [ -f "$ref_file" ] || continue
      checked_any=1
      ref_base="$(basename "$ref_file")"
      ref_rel="${ref_file#"$REPO_ROOT"/}"
      [ "$ref_rel" = "$ref_file" ] && ref_rel="$ref_file"
      # Find a line in SKILL.md that contains filename AND (trigger token OR lazyref-exempt)
      if grep -F "$ref_base" "$skill_md" | grep -qF 'lazyref-exempt'; then
        emit_pass "L4" "$skill_rel/SKILL.md" "references/${ref_base} exempt (lazyref-exempt)"
      elif grep -F "$ref_base" "$skill_md" | grep -qE '触发：|触发:'; then
        emit_pass "L4" "$skill_rel/SKILL.md" "references/${ref_base} reachable (filename+trigger)"
      elif grep -Fq "$ref_base" "$skill_md"; then
        emit_fail "L4" "$skill_rel/SKILL.md" "指向 ${ref_file#"$skill_root"/} 有指针缺触发标记（同行无 触发： token）"
      else
        emit_fail "L4" "$skill_rel/SKILL.md" "未指向 ${ref_file#"$skill_root"/}（常载面零指针=不可达死文件）"
      fi
    done < <(find "$skill_root/references" -type f -name '*.md' | sort)
  fi
done

# Print failures (collected so summary is last)
for fl in "${FAIL_LINES[@]+"${FAIL_LINES[@]}"}"; do
  printf '%s\n' "$fl"
done

rc=0
[ "$FAIL_COUNT" -gt 0 ] && rc=1
printf '[lazyref] summary: %d pass / %d fail, rc=%d\n' "$PASS_COUNT" "$FAIL_COUNT" "$rc"

# If nothing checked at all, fail-closed to avoid silent green on wrong --root
if [ "$checked_any" -eq 0 ]; then
  printf '[lazyref] FAIL [L0] %s no pointer lines or references scanned (check --root)\n' "$ROOT"
  printf '[lazyref] summary: %d pass / %d fail, rc=1\n' "$PASS_COUNT" "$((FAIL_COUNT + 1))"
  exit 1
fi

exit "$rc"
