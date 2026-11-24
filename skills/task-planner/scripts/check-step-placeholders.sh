#!/usr/bin/env bash
# check-step-placeholders.sh — 计划步骤占位符扫描（P-03：不可执行/模糊动词步骤判定器）
# [2026-10-16 P-03 实施] 审计提案 P-03：task_plan.md 的 Phase 步骤行常写成模糊动词占位
#   （如「优化一下性能让它快一点」「处理一下那个 bug」），既无对象也无验收点，
#   全链检查（VC/覆盖/一致性）仍全绿 →「全链通过但步骤空转」。本脚本新增独立判定面：
#   扫描 Phase 段内 checkbox 步骤行，命中模糊动词且无任何具体锚 = 占位步骤。
#
# What（判定契约 + 输入输出）：
#   输入: <plan-dir>/task_plan.md（唯一读取面）
#   扫描面: 仅 `### Phase N` 起、下一 `## ` 标题止的段内 `- [ ]` / `- [x]` 步骤行
#           （Phase 外散文里的「等/看看」不进判定面——防散文误报）
#   判定（两步 AND）:
#     ① 模糊动词字面命中: {优化一下|处理一下|看看|检查下|完善|提升|改进一下|做一下|搞定|跑一下测试|等}
#        ——「等」按字面计入词表（模糊列举收尾词；行内含 `bun test` 等命令锚仍可救，
#        由 ② 的豁免面兜住，实测 SP-05/06 正例含「等」不误拦）。
#     ② 无任何具体锚: 行内无路径 token（含 `/` 的相对路径，或 .ext 扩展名 token，
#        如 `src/auth.ts:42`）∧ 无命令 token（≥2 个连续 ASCII 词的命令，如 `bun test`、
#        `npm install`）= 占位。带任一具体锚 → 可执行 → 放行（模糊动词 + 具体对象 ≠ 占位）。
#   输出（stdout）: 命中逐行 `[step-placeholder] ✗ <行号> 不可执行步骤: <原文>`
#   退出码: 0=无可执行性缺陷；1=存在占位步骤；2=plan-dir 缺失 / task_plan.md 缺失
# 依赖: 纯 bash（read 状态机 + grep -E 字面/锚判定），无 awk/python/jq；
#   [2026-11-25 P4] 仅当计划目录存在 plan-state.json 时额外调用 planctl.py get（JSON 权威源），
#   用于跳过 template_checks 结构化勾选行（其文本来自 JSON，不参与 MD 占位启发式）。
#
# Why（设计取舍，逐条给理由）:
#   · 为什么只判「模糊动词 ∧ 无锚」的 AND 面而非模糊动词全拦：「在 src/a.ts 完善边界处理」
#     有明确对象与落点，是可执行步骤；只拦动词会把「动词模糊但对象具体」的合法步骤误杀
#     （误报面 = P-03 反面的等价伤害）。误报调优面 = FUZZY_RE 词表与 ANCHOR 正则，改动前先跑
#     selftest-step-placeholders.sh 全断言。
#   · 为什么命令锚用「≥2 个连续 ASCII 词」而非单词命令词表：单列命令词表（bun/npm/git…）
#     永远追不上工具面演进；「两个连续 ASCII token」对 `bun test`、`npm install`、`git merge`
#     全命中且把中文散文里的孤立英文单词（如「用 etc 之类」）判为非命令（单 token 不算），
#     精度/召回取舍偏向低误报。
#   · 为什么 Phase 边界用「下一 ## 标题」而非「下一个 ### Phase」：Phase 段常含
#     「- **Status:**」等元信息行，只把 `- [ ]`/`- [x]` 行判为步骤面；跨 Phase 不并段
#     （段边界 = 任意 `## ` 级标题，`###` 子标题不断段，允许 Phase 内小节）。
#   · 诚实边界：① 非 checkbox 形态的步骤（纯文本列项、表格行）不在判定面（fail-open，
#     与 check-complete 系列「缺形态即跳过」范式一致）；② 锚判定是「有锚即放行」的字面面，
#     不校验锚的真实性（真实性 = P-01 check-evidence-anchor.sh 判定面，两门互补不代偿）。
set -u

# ── 常量：词表与锚（误报调优面，改动前先跑 selftest-step-placeholders.sh）──────
# 模糊动词字面集（P-03 审计提案给定词表 + 「等」字面计入）
FUZZY_RE='优化一下|处理一下|看看|检查下|完善|提升|改进一下|做一下|搞定|跑一下测试|等'
# 具体锚（命中任一即视为可执行，豁免模糊动词判定）:
#   ① 路径 token: 含 / 的相对路径（src/auth.ts:42、plans/x/…）∧ 或带白名单式扩展名 token（file.ext）
#   ② 命令 token: ≥2 个连续 ASCII 词（[a-z]+ 词 ×2），如 "bun test"、"npm install"、"git merge"
ANCHOR_RE='[a-zA-Z0-9_.@-]*/[a-zA-Z0-9_.@-]+|\.[a-z][a-z0-9]+|[[:space:]][a-z]+[[:space:]]+[a-z]+'

CHECKER="$0"
PLAN_DIR="${1:-}"
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[step-placeholder] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
PLAN_FILE="$PLAN_DIR/task_plan.md"
if [ ! -f "$PLAN_FILE" ]; then
    printf '[step-placeholder] ERROR: task_plan.md 缺失: %s\n' "$PLAN_FILE" >&2
    exit 2
fi

# ── [2026-11-25 task-json-template P4] 结构化勾选行豁免面 ───────────────────
# What: plan-state.json + template_checks 非空时，收集每条 check 的 id 与 text 作为标签；
#       扫描到 `- [ ]/<mark> <label>`（含 render 注记形态 `<label>（...）`）即跳过该行，
#       不计入 CHECKED、不参与模糊动词启发式。无 JSON → 标签为空，原扫描行为逐字不变。
# Why:  这些勾选文本由 JSON 提供（P1 权威性迁移），其「已确认/看看」等字面不是工序步骤，
#       拿 MD 启发式判它们会误报；而手改 MD 勾选由 check-state-consistency.sh S-3 负责。
JSON_CHECK_LABELS=""
if [ -f "$PLAN_DIR/plan-state.json" ]; then
    _sp_py="$(cd "$(dirname "$0")" && pwd)/planctl.py"
    if [ ! -f "$_sp_py" ]; then
        printf '[step-placeholder] ERROR: plan-state.json 存在但 planctl.py 缺失（JSON 权威源不可读，禁回退 MD）: %s\n' "$_sp_py" >&2
        exit 2
    fi
    _sp_err="$(mktemp "${TMPDIR:-/tmp}/step-placeholder-json.XXXXXX")"
    _sp_out="$(mktemp "${TMPDIR:-/tmp}/step-placeholder-checks.XXXXXX")"
    python3 "$_sp_py" get --plan-dir "$PLAN_DIR" --section template_checks > "$_sp_out" 2>"$_sp_err"
    _sp_rc=$?
    if [ "$_sp_rc" -ne 0 ]; then
        printf '[step-placeholder] ERROR: planctl get template_checks rc=%d: %s\n' "$_sp_rc" "$(<"$_sp_err")" >&2
        rm -f "$_sp_err" "$_sp_out"
        exit 2
    fi
    JSON_CHECK_LABELS="$(python3 - "$_sp_out" <<'PYEOF'
import json, sys
try:
    arr = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception as exc:
    print(f"[step-placeholder] template_checks JSON 解析失败: {exc}", file=sys.stderr)
    sys.exit(2)
if arr is None:
    arr = []
if not isinstance(arr, list):
    print("[step-placeholder] template_checks 必须是 array", file=sys.stderr)
    sys.exit(2)
for c in arr:
    if not isinstance(c, dict):
        continue
    for key in ("id", "text"):
        v = str(c.get(key) or "")
        if v:
            print(v)
PYEOF
)"
    _sp_parse_rc=$?
    rm -f "$_sp_err" "$_sp_out"
    if [ "$_sp_parse_rc" -ne 0 ]; then
        printf '[step-placeholder] ERROR: template_checks 解析失败 rc=%d（禁回退 MD）\n' "$_sp_parse_rc" >&2
        exit 2
    fi
fi

# _is_json_check <勾选行文本体> — 文本体是否 ∈ JSON check 标签（精确或 render 注记前缀）
_is_json_check() {
    [ -n "$JSON_CHECK_LABELS" ] || return 1
    local body="$1" lab
    while IFS= read -r lab; do
        [ "$body" = "$lab" ] && return 0
        case "$body" in "$lab（"*) return 0 ;; esac
    done <<< "$JSON_CHECK_LABELS"
    return 1
}

FAILS=0
CHECKED=0
SKIPPED_JSON=0
IN_PHASE=0
lineno=0

# 逐行状态机: ## 标题重置 Phase 段 → ### Phase N 进入扫描面 → `- [ ]/- [x]` 行 = 步骤面
while IFS= read -r line || [ -n "$line" ]; do
    lineno=$((lineno + 1))
    case "$line" in
        '### '*)  IN_PHASE=1; continue ;;   # ### Phase N / ### 子标题（不断段，保持 Phase 扫描面）
        '## '*)   IN_PHASE=0; continue ;;   # 其他 ## 级标题（## Phases / ## Decisions…）出 Phase 段
    esac
    [ "$IN_PHASE" -eq 1 ] || continue
    case "$line" in
        '- [ ] '*|'- [x] '*|'- [X] '*)
            # [P4] JSON template_checks 的结构化勾选行由 JSON 文本提供，不参与 MD 占位启发式
            if _is_json_check "${line:6}"; then
                SKIPPED_JSON=$((SKIPPED_JSON + 1))
                continue
            fi
            CHECKED=$((CHECKED + 1))
            # ① 模糊动词命中 且 ② 无任何具体锚 = 占位步骤
            if printf '%s' "$line" | grep -qE "$FUZZY_RE" \
               && ! printf '%s' "$line" | grep -qE "$ANCHOR_RE"; then
                FAILS=$((FAILS + 1))
                printf '[step-placeholder] ✗ %s 不可执行步骤: %s\n' "$lineno" "$line"
            fi
            ;;
    esac
done < "$PLAN_FILE"

_json_note=""
[ "$SKIPPED_JSON" -gt 0 ] && _json_note="（JSON 结构化勾选已豁免 $SKIPPED_JSON 行）"
if [ "$FAILS" -gt 0 ]; then
    printf '[step-placeholder] ✗ %d 项占位/不可执行步骤（扫描 checkbox 步骤 %d 行%s）— 补具体对象/命令/文件锚后重跑\n' \
        "$FAILS" "$CHECKED" "$_json_note"
    exit 1
fi
printf '[step-placeholder] ✓ 无可执行性缺陷（扫描 checkbox 步骤 %d 行%s）\n' "$CHECKED" "$_json_note"
exit 0
