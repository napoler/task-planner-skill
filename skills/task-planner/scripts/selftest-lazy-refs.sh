#!/usr/bin/env bash
# selftest-lazy-refs.sh — Rule 116 惰性文件引入机器门行为回归
#
# Fixtures (mktemp sandbox):
#   good             -> PASS rc=0
#   missing-trigger  -> rc=1 (L2)
#   dead-path        -> rc=1 (L1)
#   unreachable      -> rc=1 (L4, references file not pointed from SKILL.md)
#   exempt           -> rc=0 (lazyref-exempt line skipped)
#   mutation         -> from good, delete trigger marker -> gate must turn FAIL
#
# Usage: bash selftest-lazy-refs.sh
# Exit: 0=FAIL=0  1=any FAIL

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$SCRIPT_DIR/check-lazy-refs.sh"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'LR-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'LR-%s FAIL %s\n' "$1" "$2"; }

assert_rc() {
  local id="$1" desc="$2" expect="$3" got="$4"
  if [ "$got" = "$expect" ]; then ok "$id" "$desc (rc=$got)"; else bad "$id" "$desc (expected=$expect got=$got)"; fi
}
assert_grep() {
  local id="$1" desc="$2" pattern="$3" file="$4"
  if grep -qE "$pattern" "$file"; then ok "$id" "$desc"; else bad "$id" "$desc (missing pattern: $pattern)"; fi
}

TMPBASE="$(mktemp -d "${TMPDIR:-/tmp}/lazyref-selftest.XXXXXX")"
trap 'rm -rf "$TMPBASE"' EXIT

run_check() {
  local root="$1" out="$2"
  bash "$CHECK" --root "$root" >"$out" 2>&1
  printf '%s' "$?"
}

# ---- fixture builders ----
mk_skill_base() {
  local root="$1" sname="$2"
  mkdir -p "$root/$sname/references"
}

# good: SKILL.md has pointer with trigger + desc; reference reachable
build_good() {
  local root="$1"
  mk_skill_base "$root" "good-skill"
  cat > "$root/good-skill/references/guide.md" <<'EOF'
# Guide
content
EOF
  cat > "$root/good-skill/SKILL.md" <<'EOF'
# Good Skill
- 规划指南（按需加载）→ 详见 references/guide.md；触发：编写计划需要模板细则时；关键词：规划 模板 指南
EOF
}

# missing-trigger: pointer line lacks 触发：
build_missing_trigger() {
  local root="$1"
  mk_skill_base "$root" "mt-skill"
  cat > "$root/mt-skill/references/guide.md" <<'EOF'
# Guide
EOF
  cat > "$root/mt-skill/SKILL.md" <<'EOF'
# MT Skill
- 规划指南（按需加载）→ 详见 references/guide.md；关键词：规划 模板 指南
EOF
}

# dead-path: pointer points to non-existent file
build_dead_path() {
  local root="$1"
  mk_skill_base "$root" "dp-skill"
  cat > "$root/dp-skill/SKILL.md" <<'EOF'
# DP Skill
- 规划指南（按需加载）→ 详见 references/missing.md；触发：编写计划需要模板细则时；关键词：规划 模板 指南
EOF
}

# unreachable: reference file exists but SKILL.md has no pointer with filename+trigger
build_unreachable() {
  local root="$1"
  mk_skill_base "$root" "ur-skill"
  cat > "$root/ur-skill/references/orphan.md" <<'EOF'
# Orphan
EOF
  cat > "$root/ur-skill/SKILL.md" <<'EOF'
# UR Skill
This skill has no lazy pointer to orphan.md.
EOF
}

# exempt: pointer line has lazyref-exempt, missing trigger but should be skipped
build_exempt() {
  local root="$1"
  mk_skill_base "$root" "ex-skill"
  cat > "$root/ex-skill/references/legacy.md" <<'EOF'
# Legacy
EOF
  cat > "$root/ex-skill/SKILL.md" <<'EOF'
# EX Skill
- 遗留说明（按需加载）→ 详见 references/legacy.md lazyref-exempt
EOF
}

# ---- LR-01 good fixture -> rc=0 ----
GOOD="$TMPBASE/good/skills"
mkdir -p "$GOOD"
build_good "$GOOD"
rc="$(run_check "$GOOD" "$TMPBASE/good.out")"
assert_rc "01" "good fixture rc=0" "0" "$rc"
assert_grep "02" "good summary has 0 fail" 'summary: .* 0 fail, rc=0' "$TMPBASE/good.out"

# ---- LR-03 missing-trigger -> rc=1 ----
MT="$TMPBASE/mt/skills"
mkdir -p "$MT"
build_missing_trigger "$MT"
rc="$(run_check "$MT" "$TMPBASE/mt.out")"
assert_rc "03" "missing-trigger fixture rc=1" "1" "$rc"
assert_grep "04" "missing-trigger reports L2" '\[L2\]' "$TMPBASE/mt.out"

# ---- LR-05 dead-path -> rc=1 ----
DP="$TMPBASE/dp/skills"
mkdir -p "$DP"
build_dead_path "$DP"
rc="$(run_check "$DP" "$TMPBASE/dp.out")"
assert_rc "05" "dead-path fixture rc=1" "1" "$rc"
assert_grep "06" "dead-path reports L1" '\[L1\]' "$TMPBASE/dp.out"

# ---- LR-07 unreachable -> rc=1 ----
UR="$TMPBASE/ur/skills"
mkdir -p "$UR"
build_unreachable "$UR"
rc="$(run_check "$UR" "$TMPBASE/ur.out")"
assert_rc "07" "unreachable fixture rc=1" "1" "$rc"
assert_grep "08" "unreachable reports L4" '\[L4\]' "$TMPBASE/ur.out"

# ---- LR-09 exempt -> rc=0 ----
EX="$TMPBASE/ex/skills"
mkdir -p "$EX"
build_exempt "$EX"
rc="$(run_check "$EX" "$TMPBASE/ex.out")"
assert_rc "09" "exempt fixture rc=0" "0" "$rc"
assert_grep "10" "exempt summary 0 fail" 'summary: .* 0 fail, rc=0' "$TMPBASE/ex.out"

# ---- LR-11 mutation: good -> remove trigger marker -> must turn FAIL ----
MUT="$TMPBASE/mut/skills"
mkdir -p "$MUT"
build_good "$MUT"
# confirm good baseline
rc="$(run_check "$MUT" "$TMPBASE/mut.good.out")"
if [ "$rc" != "0" ]; then
  bad "11" "mutation baseline not green (rc=$rc)"
else
  # mutate: remove trigger token from SKILL.md pointer line
  python3 - "$MUT/good-skill/SKILL.md" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding='utf-8')
s = s.replace('；触发：编写计划需要模板细则时', '')
s = s.replace(';触发：编写计划需要模板细则时', '')
s = s.replace('触发：编写计划需要模板细则时', '')
p.write_text(s, encoding='utf-8')
PY
  rc2="$(run_check "$MUT" "$TMPBASE/mut.after.out")"
  assert_rc "11" "mutation (trigger removed) turns FAIL" "1" "$rc2"
  assert_grep "12" "mutation reports L2 or L4" '\[L2\]|\[L4\]' "$TMPBASE/mut.after.out"
fi

# ---- LR-13 self-check: script is bash -n clean (caller also does, but cheap here) ----
if bash -n "$CHECK" >/dev/null 2>&1; then
  ok "13" "check-lazy-refs.sh bash -n clean"
else
  bad "13" "check-lazy-refs.sh bash -n FAIL"
fi

# ---- LR-14 bare-sh-resolves: bare .sh token resolves to <skill-root>/scripts/ ----
BS="$TMPBASE/bs/skills"
mkdir -p "$BS"
mk_skill_base "$BS" "bs-skill"
mkdir -p "$BS/bs-skill/scripts"
cat > "$BS/bs-skill/scripts/smart-merge-back.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$BS/bs-skill/references/guide.md" <<'EOF'
# Guide
EOF
cat > "$BS/bs-skill/SKILL.md" <<'EOF'
# BS Skill
- 合并回脚本（按需加载）→ 详见 smart-merge-back.sh；触发：需要执行合并回流程时；关键词：merge 合并 脚本
- 规划指南（按需加载）→ 详见 references/guide.md；触发：编写计划需要模板细则时；关键词：规划 模板 指南
EOF
rc="$(run_check "$BS" "$TMPBASE/bs.out")"
assert_rc "14" "bare-sh-resolves fixture rc=0" "0" "$rc"
assert_grep "15" "bare-sh-resolves no L1 fail" 'summary: .* 0 fail, rc=0' "$TMPBASE/bs.out"

# ---- LR-16 runtime-file-skip: runtime compass file names must not cause L1 FAIL ----
RF="$TMPBASE/rf/skills"
mkdir -p "$RF"
mk_skill_base "$RF" "rf-skill"
cat > "$RF/rf-skill/references/guide.md" <<'EOF'
# Guide
EOF
cat > "$RF/rf-skill/SKILL.md" <<'EOF'
# RF Skill
- 计划工件说明（按需加载）→ 详见 task_plan.md；触发：需要了解计划工件结构时；关键词：计划 task_plan 结构
- 规划指南（按需加载）→ 详见 references/guide.md；触发：编写计划需要模板细则时；关键词：规划 模板 指南
EOF
rc="$(run_check "$RF" "$TMPBASE/rf.out")"
assert_rc "16" "runtime-file-skip fixture rc=0" "0" "$rc"
assert_grep "17" "runtime-file-skip no L1 fail" 'summary: .* 0 fail, rc=0' "$TMPBASE/rf.out"

# ---- LR-18 L4 message split: filename present but no trigger token on same line -> "有指针缺触发标记" ----
L4M="$TMPBASE/l4m/skills"
mkdir -p "$L4M"
mk_skill_base "$L4M" "l4m-skill"
cat > "$L4M/l4m-skill/references/has-pointer.md" <<'EOF'
# Has Pointer
EOF
cat > "$L4M/l4m-skill/SKILL.md" <<'EOF'
# L4M Skill
- 参考文件（按需加载）→ 详见 references/has-pointer.md；关键词：参考 文件
EOF
rc="$(run_check "$L4M" "$TMPBASE/l4m.out")"
assert_rc "18" "L4 pointer-missing-trigger fixture rc=1" "1" "$rc"
assert_grep "19" "L4 reports has-pointer-missing-trigger wording" '有指针缺触发标记' "$TMPBASE/l4m.out"
if grep -qF '不可达死文件' "$TMPBASE/l4m.out" && grep -qF 'has-pointer.md' "$TMPBASE/l4m.out"; then
  bad "20" "L4 present-but-missing-trigger must not be labeled unreachable-dead-file"
else
  ok "20" "L4 present-but-missing-trigger not mislabeled as unreachable-dead-file"
fi

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
