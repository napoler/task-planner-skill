#!/usr/bin/env bash
set -euo pipefail

# inject-template-lineage.sh
# Idempotently inject <!-- template-lineage: ... --> headers into variant/base templates.
# Placement (返工#1 fix): insert after first H1 (`# `) line.
#   - base task_plan.md: if H1 is immediately followed by `<!-- 渲染契约` comment line, insert after that comment line.
#   - variants: insert immediately after H1 line.
# Usage:
#   inject-template-lineage.sh [--dry-run] [--with-base]
# Run from anywhere; paths resolved relative to script location (worktree root).

DRY_RUN=0
WITH_BASE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --with-base) WITH_BASE=1 ;;
    -h|--help)
      sed -n '1,24p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BASE="$ROOT/skills/task-planner/templates/task_plan.md"
VARIANT_DIR="$ROOT/skills/task-planner/templates/variant"
KIT_SKILL="$ROOT/skills/plan-template-kit/SKILL.md"

EXEMPT_RE='^(mini-lite-type\.md|l0-lite-type\.md)$'
PRUNED_REASON='variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）'

python3 - "$ROOT" "$BASE" "$VARIANT_DIR" "$KIT_SKILL" "$DRY_RUN" "$WITH_BASE" "$EXEMPT_RE" "$PRUNED_REASON" <<'PY'
import sys, os, re, glob

root, base_path, variant_dir, kit_skill, dry_run, with_base, exempt_re, pruned_reason = sys.argv[1:9]
dry_run = dry_run == '1'
with_base = with_base == '1'
exempt_re = re.compile(exempt_re)

def norm_heading(line):
    s = re.sub(r'^##\s*', '', line.rstrip('\n'))
    s = re.sub(r'[^\w\s\u4e00-\u9fff（）()—\-：:/]+', '', s, flags=re.UNICODE)
    core = re.split(r'[（(—]', s, maxsplit=1)[0]
    core = re.sub(r'\s+', '', core)
    core = core.strip('：: -')
    return core

def headings_ordered_unique(path):
    keys = []
    seen = set()
    with open(path, encoding='utf-8') as f:
        for line in f:
            if line.startswith('## '):
                k = norm_heading(line)
                if k and k not in seen:
                    seen.add(k)
                    keys.append(k)
    return keys

def heading_set(path):
    s = set()
    with open(path, encoding='utf-8') as f:
        for line in f:
            if line.startswith('## '):
                k = norm_heading(line)
                if k:
                    s.add(k)
    return s

base_keys = headings_ordered_unique(base_path)

def compute_pruned(vpath):
    vset = heading_set(vpath)
    missing = [k for k in base_keys if k not in vset]
    return ','.join(missing) if missing else 'none'

def find_h1_index(lines):
    for i, l in enumerate(lines):
        if l.startswith('# '):
            return i
    return 0

def desired_index(lines, is_base):
    h = find_h1_index(lines)
    if is_base:
        j = h + 1
        if j < len(lines):
            lj = lines[j]
            if lj.startswith('<!-- 渲染契约') and '-->' in lj:
                return j + 1
    return h + 1

def upsert_lineage(path, header_line, is_base):
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()
    removed = False
    filtered = []
    for l in lines:
        if l.startswith('<!-- template-lineage:'):
            removed = True
            continue
        filtered.append(l)
    idx = desired_index(filtered, is_base)
    if idx < 0:
        idx = 0
    if idx > len(filtered):
        idx = len(filtered)
    result = filtered[:idx] + [header_line] + filtered[idx:]
    if result == lines:
        return 'unchanged'
    action = 'replace' if removed else 'insert'
    if not dry_run:
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(result)
    return action

def inject_variant(vpath):
    name = os.path.basename(vpath)
    if exempt_re.match(name):
        return ('skip-exempt', name, None)
    pruned = compute_pruned(vpath)
    header = f'<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="{pruned}" pruned_reason="{pruned_reason}" -->\n'
    action = upsert_lineage(vpath, header, is_base=False)
    return (action, name, pruned)

def ensure_base():
    header = '<!-- template-lineage: level=base spec_version=1 -->\n'
    return upsert_lineage(base_path, header, is_base=True)

def ensure_kit():
    want = '> 模板规范版本: spec_version=1（2026-11-20 task-antiregress-tplgov-20261120 建立；模板规范升级时递增并按 retrofit SOP 改造存量，见 S6）\n'
    with open(kit_skill, encoding='utf-8') as f:
        lines = f.readlines()
    idx = None
    for i,l in enumerate(lines):
        if l.startswith('> 模板规范版本: spec_version='):
            idx = i
            break
    if idx is not None:
        if lines[idx] == want:
            return 'unchanged'
        if not dry_run:
            lines[idx] = want
            with open(kit_skill, 'w', encoding='utf-8') as f:
                f.writelines(lines)
        return 'replace'
    insert_at = 0
    for i,l in enumerate(lines):
        if l.startswith('# '):
            insert_at = i+1
            break
    new_lines = lines[:insert_at] + ['\n', want] + lines[insert_at:]
    if not dry_run:
        with open(kit_skill, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
    return 'insert'

variants = sorted(glob.glob(os.path.join(variant_dir, '*-type.md')))
counts = {'insert':0,'replace':0,'unchanged':0,'skip-exempt':0}
for vp in variants:
    action, name, pruned = inject_variant(vp)
    counts[action] = counts.get(action,0)+1
    plen = len(pruned) if pruned else 0
    print(f'VARIANT {action}: {name} pruned_len={plen}')
print(f'SUMMARY variants total={len(variants)} insert={counts.get("insert",0)} replace={counts.get("replace",0)} unchanged={counts.get("unchanged",0)} skip-exempt={counts.get("skip-exempt",0)} dry_run={dry_run}')

if with_base:
    ba = ensure_base()
    ka = ensure_kit()
    print(f'BASE {ba}: {base_path}')
    print(f'KIT {ka}: {kit_skill}')
PY
