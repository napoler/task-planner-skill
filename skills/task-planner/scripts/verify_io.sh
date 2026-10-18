#!/usr/bin/env bash
# verify_io.sh — I/O 契约机器校验（F11 修复，task-v189）
# 职责：① 7 文件在位断言 ② check-delegation stats JSON schema 校验（jq + 迷你 schema 断言）
# 用法：bash verify_io.sh <plan-dir>
# 设计决策（task-v189 子代理评估）：
#   - 不插进 check-complete.sh（2067 行 + C-2 SKIP-BY-HASH 键③锚区间，高回归风险）
#   - 真正可 schema 化的面 = check-delegation stats JSON（7 键），非 7 个 Markdown 文件（伪校验）
#   - 7 文件在位 = 存在性断言（bash -f），与既有 check-3file-gate / selftest-* 锚断言同构
#   - verdict enum 实证自 check-delegation.sh:571-572（local verdict="ok" / 违规置 violation）
# 依赖：bash + check-delegation.sh（同目录）+ jq（可选，缺失打 SKIP）+ python3（迷你 schema 断言）
set -u

PLAN_DIR="${1:?用法: bash verify_io.sh <plan-dir>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="$SCRIPT_DIR/schemas/check-delegation-stats.schema.json"
FAIL=0

# ─── ① 7 文件在位断言（存在性契约） ─────────────────────────────────────────────
# 7 文件名单实证自 SKILL.md:44「7 文件在位（task_plan/findings/progress/notepad-learnings/verification/knowledge-brief/user-session-log，Rule 80）」
SEVEN_FILES=(task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md user-session-log.md)
for f in "${SEVEN_FILES[@]}"; do
  if [ -f "$PLAN_DIR/$f" ]; then
    echo "[verify-io] present: $f"
  else
    echo "[verify-io] missing: $f"
    FAIL=1
  fi
done

# ─── ② check-delegation stats JSON schema 校验 ──────────────────────────────────
# 消费方=check-complete.sh:453-524（jq 解析 + grep fallback），本脚本独立守护 schema 契约
STATS="$("$SCRIPT_DIR/check-delegation.sh" stats "$PLAN_DIR" 2>/dev/null)"
if [ -z "$STATS" ]; then
  echo "[verify-io] check-delegation stats 输出为空，跳过 schema 校验"
else
  echo "[verify-io] stats JSON: $STATS"
  # jq 语法校验（jq 缺失打 SKIP）
  if ! command -v jq >/dev/null 2>&1; then
    echo "[verify-io] jq 缺失，跳过 stats JSON 语法校验"
  elif ! echo "$STATS" | jq -e . >/dev/null 2>&1; then
    echo "[verify-io] FAIL: stats 非合法 JSON"
    FAIL=1
  else
    # 迷你 schema 校验（python3 内联，不引入 jsonschema 依赖——环境实测无该模块）
    # 校验：required 键齐全 + 各键类型匹配 + verdict enum ∈ {ok, violation}
    python3 - "$STATS" "$SCHEMA" <<'PYSCHEMA' && echo "[verify-io] schema PASS" || { echo "[verify-io] FAIL: schema 校验未通过"; FAIL=1; }
import json, sys, pathlib
stats = json.loads(sys.argv[1])
schema = json.loads(pathlib.Path(sys.argv[2]).read_text(encoding="utf-8"))
# required 键齐全
missing = [k for k in schema.get("required", []) if k not in stats]
if missing:
    print(f"缺 required 键: {missing}")
    sys.exit(1)
# 各键类型匹配（递归 object/array/基本类型）
TYPE_MAP = {"object": dict, "array": list, "integer": int, "number": (int, float), "string": str, "boolean": bool}
for key, prop in schema.get("properties", {}).items():
    if key not in stats:
        continue
    expected = TYPE_MAP.get(prop.get("type"))
    if expected and not isinstance(stats[key], expected):
        print(f"键 {key} 类型错: 期望 {prop['type']}, 实际 {type(stats[key]).__name__}")
        sys.exit(1)
# integer 排除 bool（Python bool 是 int 子类）
for key, prop in schema.get("properties", {}).items():
    if prop.get("type") == "integer" and isinstance(stats.get(key), bool):
        print(f"键 {key} 类型错: integer 不能是 bool")
        sys.exit(1)
# verdict enum
verdict_enum = set(prop.get("enum", [])) if (prop := schema.get("properties", {}).get("verdict")) else set()
if verdict_enum and stats.get("verdict") not in verdict_enum:
    print(f"verdict={stats.get('verdict')} 不在 {sorted(verdict_enum)}")
    sys.exit(1)
PYSCHEMA
  fi
fi

# ─── 结果 ─────────────────────────────────────────────────────────────────────────
if [ "$FAIL" -eq 0 ]; then
  echo "[verify-io] PASS"
  exit 0
else
  echo "[verify-io] FAIL"
  exit 1
fi
