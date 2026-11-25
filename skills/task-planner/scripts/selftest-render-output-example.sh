#!/bin/bash
# selftest-render-output-example.sh — JSON 模板生成器正负例守护（Rule 113 产出可靠性）
# 覆盖：正例渲染/示例往返/原子落盘/占位符 fail-closed/空 vc_refs/未知字段/TBD 拒绝/
#       dry-run 不落盘/VC 参照校验/非法模板 rc2/产物可被 planctl add 消费
set -euo pipefail

PASS=0
FAIL=0
ok()  { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
bad() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RENDER="$SKILL_ROOT/scripts/render-output-example.py"
PLANCTL="$SKILL_ROOT/scripts/planctl.py"
PY="$(command -v python3 || true)"

echo "=== selftest-render-output-example: CLI 传参 → 合规 JSON ==="

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [ -n "$PY" ] && [ -f "$RENDER" ] && [ -f "$PLANCTL" ]; then
  ok "ROE-01: 脚本/解释器在位"
else
  bad "ROE-01: 缺 python3 或脚本: $RENDER / $PLANCTL"
  echo "Total: $((PASS + FAIL)) PASS=$PASS FAIL=$FAIL"
  [ "$FAIL" -eq 0 ]
fi

cat > "$TMP/example.json" <<'EOF'
{"title":"示例标题","count":3}
EOF
cat > "$TMP/template.json" <<'EOF'
{"title":"<TITLE>","count":"<INT>"}
EOF

BASE_ARGS=(--set id=OE-1 --set deliverable=article.json --set format=JSON
           --example-file "$TMP/example.json" --template-file "$TMP/template.json" --vc-ref VC-1)

# ROE-02: dry-run 正例 → stdout 合法 JSON + 必填字段齐全
if "$PY" "$RENDER" "${BASE_ARGS[@]}" --dry-run >"$TMP/out" 2>"$TMP/err"; then
  if "$PY" -c '
import json,sys
d=json.load(open(sys.argv[1]))
need={"id","deliverable","format","example","template","vc_refs"}
assert need <= set(d), sorted(need-set(d))
assert d["vc_refs"]==["VC-1"], d["vc_refs"]
assert d["id"]=="OE-1" and d["format"]=="JSON"
' "$TMP/out" 2>/dev/null; then
    ok "ROE-02: dry-run 产出合法 output_example_item JSON"
  else
    bad "ROE-02: stdout 字段/取值不符"
  fi
else
  bad "ROE-02: dry-run 非 0 退出: $(head -c 200 "$TMP/err")"
fi

# ROE-03: example/template 往返可被 json.loads 还原（双重转义防护）
if "$PY" -c '
import json,sys
d=json.load(open(sys.argv[1]))
assert json.loads(d["example"])["title"]=="示例标题"
assert json.loads(d["template"])["count"]=="<INT>"
' "$TMP/out" 2>/dev/null; then
  ok "ROE-03: example/template 无双重转义，往返一致"
else
  bad "ROE-03: example/template 往返失败（疑似双重转义）"
fi

# ROE-04: --out 原子落盘 + 文件 JSON 合法
if "$PY" "$RENDER" "${BASE_ARGS[@]}" --out "$TMP/oe.json" >"$TMP/out2" 2>"$TMP/err2" && [ -f "$TMP/oe.json" ]; then
  if "$PY" -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["id"]=="OE-1"' "$TMP/oe.json" 2>/dev/null; then
    ok "ROE-04: --out 落盘且 JSON 合法"
  else
    bad "ROE-04: 落盘文件 JSON 非法"
  fi
else
  bad "ROE-04: --out 失败: $(head -c 200 "$TMP/err2")"
fi

# ROE-05: 模板占位符未提供 → fail-closed rc=1
if "$PY" "$RENDER" --set id=OE-9 --set deliverable=x.json --set format=JSON --vc-ref VC-1 --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-05: 缺 EXAMPLE/TEMPLATE 参数却放行"
elif grep -Fq '模板占位符未提供参数' "$TMP/err"; then
  ok "ROE-05: 占位符缺失 fail-closed"
else
  bad "ROE-05: 拒绝但原因不符: $(head -c 200 "$TMP/err")"
fi

# ROE-06: 空 vc_refs → rc=1
if "$PY" "$RENDER" --set id=OE-1 --set deliverable=x.json --set format=JSON --set example=ok --set template=tpl --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-06: 空 vc_refs 却放行"
elif grep -Fq 'vc_refs 必须是非空' "$TMP/err"; then
  ok "ROE-06: 空 vc_refs 被拒"
else
  bad "ROE-06: 拒绝但原因不符"
fi

# ROE-07: 未知字段 → rc=1
cat > "$TMP/bogus.template.json" <<'EOF'
{"id":"{{ID}}","deliverable":"{{DELIVERABLE}}","format":"{{FORMAT}}","example":"{{EXAMPLE}}","template":"{{TEMPLATE}}","vc_refs":[],"bogus":"x"}
EOF
if "$PY" "$RENDER" --template "$TMP/bogus.template.json" --set id=OE-1 --set deliverable=x.json --set format=JSON --set example=ok --set template=tpl --vc-ref VC-1 --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-07: 未知字段却放行"
elif grep -Fq '未知字段: bogus' "$TMP/err"; then
  ok "ROE-07: 未知字段被拒"
else
  bad "ROE-07: 拒绝但原因不符"
fi

# ROE-08: TBD/略 占位文本 → rc=1
if "$PY" "$RENDER" --set id=OE-1 --set deliverable=x.json --set format=JSON --set example=TBD --set template=tpl --vc-ref VC-1 --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-08: TBD 示例却放行"
elif grep -Fq '禁用的占位文本' "$TMP/err"; then
  ok "ROE-08: TBD 占位示例被拒"
else
  bad "ROE-08: 拒绝但原因不符"
fi

# ROE-09: dry-run + --out 不落盘
if "$PY" "$RENDER" "${BASE_ARGS[@]}" --out "$TMP/should-not-exist.json" --dry-run >"$TMP/out" 2>"$TMP/err" && [ ! -e "$TMP/should-not-exist.json" ]; then
  ok "ROE-09: dry-run 不落盘"
else
  bad "ROE-09: dry-run 意外落盘或失败"
fi

# ROE-10: --plan-dir 存在但 VC 不在其中 → rc=1（planctl init 要求目录先存在）
mkdir -p "$TMP/plan"
"$PY" "$PLANCTL" init --plan-dir "$TMP/plan" --task-id ROE-TEST --tier mini --lane L0 >/dev/null 2>&1
if "$PY" "$RENDER" "${BASE_ARGS[@]}" --plan-dir "$TMP/plan" --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-10: 引用不存在 VC 却放行"
elif grep -Fq '引用不存在的 VC' "$TMP/err"; then
  ok "ROE-10: VC 参照校验生效"
else
  bad "ROE-10: 拒绝但原因不符: $(head -c 200 "$TMP/err")"
fi

# ROE-11: 非法模板 JSON → rc=2
printf '{not json' > "$TMP/bad.template.json"
if "$PY" "$RENDER" --template "$TMP/bad.template.json" --set id=OE-1 --dry-run >"$TMP/out" 2>"$TMP/err"; then
  bad "ROE-11: 非法模板 JSON 却放行"
else
  rc=$?
  if [ "$rc" -eq 2 ] && grep -Fq '模板非法 JSON' "$TMP/err"; then
    ok "ROE-11: 非法模板 JSON → rc=2"
  else
    bad "ROE-11: rc=$rc 不符预期（原因: $(head -c 160 "$TMP/err")）"
  fi
fi

# ROE-12: 产物可被 planctl add --section output_examples 消费 + render 派生区块
"$PY" "$PLANCTL" add --plan-dir "$TMP/plan" --section vcs \
  --json '{"id":"VC-1","criterion":"产出合法 JSON","command":"python3 -c \"import json;json.load(open(\\\"out.json\\\"))\"","status":"pending","evidence":""}' >/dev/null 2>&1
if "$PY" "$RENDER" "${BASE_ARGS[@]}" --plan-dir "$TMP/plan" --out "$TMP/oe2.json" >/dev/null 2>"$TMP/err" \
   && "$PY" "$PLANCTL" add --plan-dir "$TMP/plan" --section output_examples --json "$(cat "$TMP/oe2.json")" >/dev/null 2>"$TMP/err" \
   && "$PY" "$PLANCTL" render --plan-dir "$TMP/plan" >/dev/null 2>&1 \
   && grep -Fq '🧩 输出示例与格式契约' "$TMP/plan/task_plan.md"; then
  ok "ROE-12: 产物经 planctl add → render 派生区块"
else
  bad "ROE-12: 产物未被 planctl 链消费: $(head -c 200 "$TMP/err")"
fi

echo "Total: $((PASS + FAIL)) PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
