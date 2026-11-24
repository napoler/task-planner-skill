#!/usr/bin/env bash
# selftest-template-json.sh — P6 JSON 原生模板 + 结构化勾选链路行为级自测（TJ-01..08）
# 被测面: templates/json/*.json（33 份）/ planctl.py init|get|set|render /
#         check-state-consistency.sh 的 JSON-first S-3 负控制。
# What: TJ-01 模板在位与 JSON 合法性；TJ-02 结构与"无 MD 全文复制"；TJ-03 三份抽样模板
#       meta.lineage/template_type 与 MD 注释逐字段一致；TJ-04 init→render 往返；
#       TJ-05 planctl set checked→render→get bool；TJ-06 手改 MD 勾选的负控制 + render 回正；
#       TJ-07 旧计划 template_body 兼容；TJ-08 V-N / S-unit 状态按 JSON 派生（缺失保持旧行为）。
# Why: 勾选唯一权威源已迁到 plan-state.json（MD 为 render 派生视图）。生产脚本并行切换期间
#       若只看 MD 会形成假绿，故用独立夹具实跑全链；本脚本只读仓库文件，写入限 /tmp 夹具，
#       不修改任何生产脚本，也不触碰其他会话的计划目录。
# 口径: #!/usr/bin/env bash + set -euo pipefail；PASS/FAIL 计数；末行 echo "PASS=n FAIL=m"，
#       FAIL>0 exit 1。耗时控制：全部结构校验合并为单次 Python 调用，lineage 只抽样 3 份。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANCTL="$SCRIPT_DIR/planctl.py"
GATE="$SCRIPT_DIR/check-state-consistency.sh"
TPL_DIR="$(cd "$SCRIPT_DIR/../templates/json" && pwd)"
TPL_ROOT="$(cd "$SCRIPT_DIR/../templates" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
LEGACY_STATE="$REPO_ROOT/plans/archive/task-align-mandatory-step-20261123/plan-state.json"

FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/selftest-template-json.XXXXXX")"
OUT="$FIXTURE_ROOT/stdout.log"
ERR="$FIXTURE_ROOT/stderr.log"
cleanup() { rm -rf "$FIXTURE_ROOT"; }
trap cleanup EXIT

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf 'TJ-%s PASS %s\n' "$1" "$2"; }
bad() { FAIL=$((FAIL+1)); printf 'TJ-%s FAIL %s\n' "$1" "$2"; }
diag(){ printf '  detail: %s\n' "$1"; }

# report <python 输出的 code<TAB>PASS|FAIL<TAB>msg 行>：逐行转入统一 PASS/FAIL 计数。
report() {
    local code status msg
    while IFS=$'\t' read -r code status msg; do
        [ -n "$code" ] || continue
        if [ "$status" = "PASS" ]; then ok "$code" "$msg"; else bad "$code" "$msg"; fi
    done <<< "$1"
}

# ── TJ-01 33 份模板在位 + json.tool 可解析 ──────────────────────────────────────────────
TJ01_FILES="$(find "$TPL_DIR" -maxdepth 1 -type f -name '*.template.json' -print | sort)"
TJ01_N="$(printf '%s\n' "$TJ01_FILES" | grep -c . || true)"
if [ "$TJ01_N" -eq 33 ]; then
    ok 01a "templates/json 共 33 份 *.template.json"
else
    bad 01a "模板数应为 33，实际 $TJ01_N"
fi
TJ01_BAD=0
while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! python3 -m json.tool "$f" >/dev/null 2>>"$ERR"; then
        TJ01_BAD=$((TJ01_BAD+1)); diag "python3 -m json.tool 失败: $f"
    fi
done <<< "$TJ01_FILES"
if [ "$TJ01_BAD" -eq 0 ]; then ok 01b "33 份模板全部通过 python3 -m json.tool"; else bad 01b "JSON 解析失败 $TJ01_BAD 份"; fi

# ── TJ-02 结构：顶层键白名单 / section kind / 唯一 id / 无整份 MD 原文 ──────────────────
# 合并到一次 Python 调用（慢盘上 33 文件只读一遍）；错误以 TSV 报告回传 shell。
if ! TJ02_REPORT="$(python3 - "$TPL_DIR" <<'PY'
"""TJ-02: JSON 模板结构断言；返回 code<TAB>PASS/FAIL<TAB>msg 行，供 shell 计数。"""
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
files = sorted(root.glob("*.template.json"))
problems = {"02a": [], "02b": [], "02c": [], "02d": []}


def walk_text(node):
    """递归收集所有 text 字段长度（block.markdown/raw/checklist item 均覆盖）。"""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "text" and isinstance(value, str):
                yield len(value)
            else:
                yield from walk_text(value)
    elif isinstance(node, list):
        for value in node:
            yield from walk_text(value)


for path in files:
    doc = json.loads(path.read_text(encoding="utf-8"))
    name = path.name
    if set(doc) != {"schema_version", "meta", "sections"}:
        problems["02a"].append(f"{name}: 顶层键={sorted(doc)}")
    section_ids = []
    raw_count = 0
    for section in doc.get("sections", []):
        if not isinstance(section, dict):
            problems["02b"].append(f"{name}: section 非 object")
            continue
        section_ids.append(str(section.get("id", "")))
        if section.get("kind") not in ("ref", "blocks"):
            problems["02b"].append(f"{name}/{section.get('id')}: kind={section.get('kind')!r}")
        for block in section.get("blocks", []):
            if isinstance(block, dict) and block.get("kind") == "raw":
                raw_count += 1
    if len(section_ids) != len(set(section_ids)):
        problems["02c"].append(f"{name}: 重复 section id={section_ids}")
    longest = max(list(walk_text(doc)) or [0])
    # 判据：单个 text ≤2000 字符、单模板 raw 块 ≤2 —— 超过即疑似整份 MD 原文复制。
    if longest > 2000 or raw_count > 2:
        problems["02d"].append(f"{name}: max_text={longest}, raw_blocks={raw_count}")
labels = {
    "02a": "顶层仅 schema_version/meta/sections",
    "02b": "section kind 仅 ref|blocks",
    "02c": "无重复 section id",
    "02d": "无整份 MD 原文复制(text<=2000, raw<=2)",
}
for code, errs in problems.items():
    status = "FAIL" if errs else "PASS"
    msg = labels[code] + ("；" + "; ".join(errs[:5]) if errs else f"（{len(files)} 份）")
    print(f"{code}\t{status}\t{msg}")
PY
)"; then
    bad 02x "结构检查 Python 执行失败"; diag "$TJ02_REPORT"
else
    report "$TJ02_REPORT"
fi

# ── TJ-03 lineage/template_type 抽样：task_plan / research / audio-voice 与 MD 注释逐字段一致 ──
if ! TJ03_REPORT="$(python3 - "$TPL_ROOT" <<'PY'
"""TJ-03: JSON meta 与 MD template-lineage/template_type 注释逐字段比对（仅抽样 3 份）。"""
import json
import pathlib
import re
import shlex
import sys

root = pathlib.Path(sys.argv[1])
pairs = [
    ("task_plan", "json/task_plan.template.json", "task_plan.md"),
    ("research", "json/research.template.json", "variant/research-type.md"),
    ("audio-voice", "json/audio-voice.template.json", "variant/audio-voice-type.md"),
]


def md_fields(text):
    """解析 `<!-- template-lineage: k=v ... -->`；缺省字段按空值处理（base 模板无 parent）。"""
    match = re.search(r"<!--\s*template-lineage:\s*(.*?)-->", text, re.S)
    if match is None:
        return {}
    return dict(part.split("=", 1) for part in shlex.split(match.group(1)))


def md_type(text):
    """兼容 `<!-- template_type: x -->` 与 base 模板 HTML 注释块内的行首形态。"""
    match = re.search(r"<!--\s*template_type:\s*(\S+)\s*-->", text)
    match = match or re.search(r"(?m)^\s*template_type:\s*(\S+)\s*$", text)
    return match.group(1) if match else ""

for idx, (label, json_rel, md_rel) in enumerate(pairs):
    meta = json.loads((root / json_rel).read_text(encoding="utf-8"))["meta"]
    text = (root / md_rel).read_text(encoding="utf-8")
    tok = md_fields(text)
    expected = {
        "level": tok.get("level", ""),
        "parent": tok.get("parent", ""),
        "base": tok.get("base", ""),
        "spec_version": int(tok.get("spec_version", "0")),
        "pruned": tok.get("pruned", "").split(",") if tok.get("pruned", "") else [],
        "pruned_reason": tok.get("pruned_reason", ""),
    }
    actual = meta.get("lineage", {})
    diffs = [f"{k}: json={actual.get(k)!r} md={v!r}" for k, v in expected.items() if actual.get(k) != v]
    status = "PASS" if not diffs else "FAIL"
    print(f"03{chr(97 + idx * 2)}\t{status}\t{label} template_type: json={meta.get('template_type')!r} md={md_type(text)!r}" if meta.get("template_type") == md_type(text)
          else f"03{chr(97 + idx * 2)}\tFAIL\t{label} template_type 不一致: json={meta.get('template_type')!r} md={md_type(text)!r}")
    print(f"03{chr(98 + idx * 2)}\t{status}\t{label} lineage 逐字段一致" if not diffs
          else f"03{chr(98 + idx * 2)}\tFAIL\t{label} lineage 不一致: {'; '.join(diffs[:3])}")
PY
)"; then
    bad 03x "lineage 抽样检查 Python 执行失败"; diag "$TJ03_REPORT"
else
    report "$TJ03_REPORT"
fi

# ── TJ-04/05/06/08 共享夹具：demo JSON 模板（用户认可的勾选形态，EV-SELF/EV-BENCH 初始 false） ──
DEMO="$FIXTURE_ROOT/demo.template.json"
PLAN="$FIXTURE_ROOT/plan-json"
mkdir -p "$PLAN"
cat > "$DEMO" <<'JSON'
{"schema_version":1,"meta":{"template_type":"general","name":"JSON 勾选自测模板","summary":"selftest demo","scenarios":["selftest"],"features":["structured-checks"],"lineage":{"level":"base","parent":"","base":"","spec_version":1,"pruned":[],"pruned_reason":""}},"sections":[{"id":"sec-evidence","anchor":"## 结构化勾选证据","level":2,"kind":"blocks","required":true,"blocks":[{"id":"checks","kind":"checklist","items":[{"id":"EV-SELF","text":"EV-SELF 自验证勾选","checked":false,"note":""},{"id":"EV-BENCH","text":"EV-BENCH 基准勾选","checked":false,"note":""}]}]}]}
JSON

flow_group() {
    local rc

    # TJ-04 init → render 往返：JSON 三字段落库、旧 template_body 缺席、MD 勾选为未勾。
    if ! python3 "$PLANCTL" init --plan-dir "$PLAN" --task-id SELFTEST-JSON --tier standard \
        --template-json "$DEMO" >"$OUT" 2>"$ERR"; then
        bad 04a "planctl init --template-json 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 04a "init --template-json rc=0"
    if python3 - "$PLAN/plan-state.json" <<'PY'
"""TJ-04: 断言 template_ref/template_doc/template_checks 落库且无 template_body。"""
import json
import sys

doc = json.load(open(sys.argv[1], encoding="utf-8"))
assert doc.get("template_ref"), "缺 template_ref"
assert isinstance(doc.get("template_doc"), dict) and doc["template_doc"].get("sections"), "缺 template_doc.sections"
checks = doc.get("template_checks")
assert isinstance(checks, list) and len(checks) == 2, f"template_checks 异常: {checks!r}"
assert {c.get("id") for c in checks} == {"EV-SELF", "EV-BENCH"}, checks
assert all(c.get("checked") is False for c in checks), checks
assert "template_body" not in doc, "新计划不得写 template_body（勾选双源）"
PY
    then ok 04b "plan-state.json 三字段到位、两项 checked=false、无 template_body"
    else bad 04b "init 落库字段不符契约"; diag "$(python3 -m json.tool "$PLAN/plan-state.json" 2>/dev/null | grep -E 'template_(ref|doc|checks|body)' | head -5 || true)"
    fi
    if ! python3 "$PLANCTL" render --plan-dir "$PLAN" >"$OUT" 2>"$ERR"; then
        bad 04c "planctl render 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 04c "render rc=0"
    if grep -q '^- \[ \] EV-SELF 自验证勾选$' "$PLAN/task_plan.md"; then ok 04d "MD 出现 '- [ ] EV-SELF'"; else bad 04d "MD 缺 '- [ ] EV-SELF'"; fi

    # TJ-05 set checked → get bool → render：唯一权威源在 JSON，勾选随 JSON 翻转。
    if ! python3 "$PLANCTL" set --plan-dir "$PLAN" --section template_checks --id EV-SELF \
        --field checked --value true >"$OUT" 2>"$ERR"; then
        bad 05a "planctl set checked 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 05a "set --section template_checks --field checked --value true rc=0"
    if ! python3 "$PLANCTL" get --plan-dir "$PLAN" --section template_checks --id EV-SELF >"$FIXTURE_ROOT/get-self.json" 2>"$ERR"; then
        bad 05b "planctl get template_checks 失败"; diag "$(<"$ERR")"
    else
        if python3 - "$FIXTURE_ROOT/get-self.json" <<'PY'
"""TJ-05: checked 必须是 JSON bool true（不是字符串 "true"）。"""
import json
import sys

entry = json.load(open(sys.argv[1], encoding="utf-8"))
assert entry.get("id") == "EV-SELF", entry
assert entry.get("checked") is True, f"checked={entry.get('checked')!r}"
PY
        then ok 05b "get EV-SELF 返回 bool true"; else bad 05b "get EV-SELF 非 bool true"; fi
    fi
    if ! python3 "$PLANCTL" render --plan-dir "$PLAN" >"$OUT" 2>"$ERR"; then
        bad 05c "set 后 render 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 05c "set 后 render rc=0"
    if grep -q '^- \[x\] EV-SELF 自验证勾选$' "$PLAN/task_plan.md" \
       && grep -q '^- \[ \] EV-BENCH 基准勾选$' "$PLAN/task_plan.md"; then
        ok 05d "MD 出现 '- [x] EV-SELF' 且 EV-BENCH 仍未勾"
    else
        bad 05d "MD 勾态未按 JSON 更新"; diag "$(grep -E '^- \[[ xX]\] EV-' "$PLAN/task_plan.md" || true)"
    fi

    # TJ-06 负控制：手改派生视图（MD）勾选 → 门按 JSON 判失败 → render 再回正。
    sed -i 's/^- \[ \] EV-BENCH/- [x] EV-BENCH/' "$PLAN/task_plan.md"
    if GATE_OUT="$(bash "$GATE" "$PLAN" 2>"$ERR")"; then rc=0; else rc=$?; fi
    if [ "$rc" -ne 0 ]; then ok 06a "JSON=false 但 MD=[x] → check-state-consistency rc=$rc"; else bad 06a "手改 MD 未被门控拦截（假绿）"; fi
    if printf '%s\n' "$GATE_OUT" | grep -q '\[state-mismatch\] S-3 check EV-BENCH'; then
        ok 06b "门输出 S-3 check EV-BENCH 差异行"
    else
        bad 06b "门缺 S-3 差异行"; diag "$GATE_OUT"
    fi
    if ! python3 "$PLANCTL" render --plan-dir "$PLAN" >"$OUT" 2>"$ERR"; then
        bad 06c "负控制后 render 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 06c "负控制后 render rc=0"
    if grep -q '^- \[ \] EV-BENCH 基准勾选$' "$PLAN/task_plan.md"; then ok 06d "render 恢复 JSON 决定的未勾形态"; else bad 06d "MD 手改未被 render 覆盖"; fi

    # TJ-08 V-N / S-unit 状态派生（与勾选同夹具）：pass→[x]、fail/pending→[ ]、缺失 VC 保留旧 [x]。
    for payload in \
        '{"id":"VC1","criterion":"c1","command":"echo","status":"pass","evidence":"e"}' \
        '{"id":"VC2","criterion":"c2","command":"echo","status":"fail","evidence":"e"}' \
        '{"id":"VC3","criterion":"c3","command":"echo","status":"pending","evidence":"e"}'; do
        if ! python3 "$PLANCTL" add --plan-dir "$PLAN" --section vcs --json "$payload" >"$OUT" 2>"$ERR"; then
            bad 08a "add vcs 失败: $payload"; diag "$(<"$ERR")"; return 1
        fi
    done
    if ! python3 "$PLANCTL" add --plan-dir "$PLAN" --section phases \
        --json '{"id":"P1","status":"pending","s_units":[],"v_checks":["VC1","VC2","VC3","VC-UNKNOWN"]}' \
        >"$OUT" 2>"$ERR"; then
        bad 08a "add phases 失败"; diag "$(<"$ERR")"; return 1
    fi
    for payload in \
        '{"id":"SU-PASS","phase":"P1","name":"pass unit","status":"pass"}' \
        '{"id":"SU-RUN","phase":"P1","name":"in_progress unit","status":"in_progress"}' \
        '{"id":"SU-DEF","phase":"P1","name":"default unit"}'; do
        if ! python3 "$PLANCTL" add --plan-dir "$PLAN" --section s_units --json "$payload" >"$OUT" 2>"$ERR"; then
            bad 08a "add s_units 失败: $payload"; diag "$(<"$ERR")"; return 1
        fi
    done
    ok 08a "vcs(3)/phases(1)/s_units(3) 经 planctl add 写入 rc=0"
    if ! python3 "$PLANCTL" render --plan-dir "$PLAN" >"$OUT" 2>"$ERR"; then
        bad 08b "状态派生 render 失败"; diag "$(<"$ERR")"; return 1
    fi
    if python3 - "$PLAN/task_plan.md" <<'PY'
"""TJ-08: V-N checkbox 由 vcs[].status 派生；未登记的 VC 保持旧 [x] 行为。"""
import sys

text = open(sys.argv[1], encoding="utf-8").read()
expected = [
    "- [x] V-1.1: VC1",
    "- [ ] V-1.2: VC2",
    "- [ ] V-1.3: VC3",
    "- [x] V-1.4: VC-UNKNOWN",
]
missing = [line for line in expected if line not in text]
assert not missing, f"V-N 派生缺失: {missing}"
PY
    then ok 08b "V-N 派生 pass→[x] / fail,pending→[ ] / 缺失 VC→旧 [x]"
    else bad 08b "V-N checkbox 未由 JSON 派生"; diag "$(grep -E '^- \[[ xX]\] V-' "$PLAN/task_plan.md" || true)"
    fi
    if python3 - "$PLAN/task_plan.md" <<'PY'
"""TJ-08: S-unit 表第 10 列由 s_units[].status 派生；缺省保持 pending。"""
import sys

rows = {}
for line in open(sys.argv[1], encoding="utf-8"):
    if line.startswith("|"):
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0] in ("SU-PASS", "SU-RUN", "SU-DEF"):
            rows[cells[0]] = cells[-1]
expected = {"SU-PASS": "pass", "SU-RUN": "in_progress", "SU-DEF": "pending"}
assert rows == expected, f"S-unit 状态列异常: {rows!r}"
PY
    then ok 08c "S-unit 状态列 status 派生、缺省 pending"
    else bad 08c "S-unit 状态列未按 JSON 派生"
    fi
}
flow_group || true

# ── TJ-07 旧计划兼容：copy 存量 template_body 计划 → render 附录仍在、get 空数组不抛 KeyError ──
legacy_group() {
    local legacy_dir="$FIXTURE_ROOT/legacy"
    mkdir -p "$legacy_dir"
    if [ ! -f "$LEGACY_STATE" ]; then bad 07a "存量夹具缺失: $LEGACY_STATE"; return 1; fi
    cp "$LEGACY_STATE" "$legacy_dir/plan-state.json"
    if python3 - "$legacy_dir/plan-state.json" <<'PY'
"""TJ-07: 确认夹具本身是 template_body 有值、template_checks 缺席的存量计划。"""
import json
import sys

doc = json.load(open(sys.argv[1], encoding="utf-8"))
assert isinstance(doc.get("template_body"), str) and doc["template_body"], "template_body 应非空"
assert "template_checks" not in doc, "夹具不应含 template_checks"
PY
    then ok 07a "存量夹具含 template_body 且无 template_checks"; else bad 07a "存量夹具形态不符"; return 1; fi
    if ! python3 "$PLANCTL" render --plan-dir "$legacy_dir" >"$OUT" 2>"$ERR"; then
        bad 07b "旧计划 render 失败"; diag "$(<"$ERR")"; return 1
    fi
    ok 07b "旧计划 render rc=0"
    if grep -q '^## 📎 领域模板原文附录' "$legacy_dir/task_plan.md"; then ok 07c "template_body 附录仍输出"; else bad 07c "旧计划附录丢失"; fi
    if python3 "$PLANCTL" get --plan-dir "$legacy_dir" --section template_checks >"$FIXTURE_ROOT/get-legacy.json" 2>"$ERR"; then
        if python3 - "$FIXTURE_ROOT/get-legacy.json" <<'PY'
"""TJ-07: 可选数组段缺省必须稳定返回 []，不得 KeyError/traceback。"""
import json
import sys

value = json.load(open(sys.argv[1], encoding="utf-8"))
assert value == [], f"期望 []，实际 {value!r}"
PY
        then ok 07d "get 缺省 template_checks 返回 []"; else bad 07d "get 缺省返回值非 []"; fi
    else
        bad 07d "get 缺省 template_checks 抛错 rc 非 0"; diag "$(<"$ERR")"
    fi
}
legacy_group || true

echo "PASS=$PASS FAIL=$FAIL"
exit $((FAIL > 0))
