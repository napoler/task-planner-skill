#!/usr/bin/env bash
# check-spec-baseline.sh — 规范基线「计划期九项 / 终验期四项」机器门（task-spec-consumption-chain S4）
# [2026-11-26 task-spec-consumption-chain S4] What:
#   计划期读 <plan-dir>/task_plan.md 的「## 🔒 规范基线」渲染表（主）与 plan-state.json 的
#   spec_baseline[]（辅），检查 ①基线表在位 ②扫描回执 ③无 pending ④must 候选逐条处置
#   ⑤SPEC 判定式非空话 ⑥来源锚文件存在且 sha256 前 12 位一致 ⑦内容类四槽齐全
#   ⑧非主进程 S-unit 被 applies 绑定 ⑨每条 SPEC 在正文 VC/判据处被点名；通过写 .spec-baseline.json。
#   --final 读 verification.md 的「基线-产物逐条核验表（Rule 84.15）」，检查 ①表在位
#   ②每 SPEC 一行 ③观测非空非占位 ④结论全 PASS ⑤证据锚非空非占位（与观测同口径）；
#   [2026-11-26 C2/C3] 另加 F6: 内容类计划零 SPEC 不放行终验 SKIP（四槽仅 NA 也不能绕过）。
#   通过写 .spec-final.json。
# Why: 规范不消费的根因是「基线只写在计划里、派发与终验无回执」；本门把规范从文本承诺升级为
#   可机器判的锁定/完成前置条件（attest-plan.sh 与 check-complete.sh 的 shell-out 消费者）。
#   纯 bash + grep/sed/awk/wc/sha256sum（禁 python/jq），与 check-evidence-anchor.sh 同风格，
#   避免门自身依赖被门约束的工具链；失败同时写 stdout（规范）与 stderr（调用方捕获编号）。
# 用法: bash check-spec-baseline.sh <plan-dir> [--final]（两种参数顺序均可）
# 退出码: 0=通过（含 l0-lite SKIP） / 1=检查不通过 / 2=输入缺失或未知参数
set -euo pipefail

# ── 单一词表位置：内容类判定（§4.4，改清单只改这里）──────────────────────────────
CONTENT_TEMPLATES='longform-continuity|writing|script-dev|storyboard|character-design|prompt-struct|video-prompt|image|video|video-fix'
CONTENT_EXECUTORS='script-writer|script-auditor|storyboard-reviewer|general-writer'
SLOTS='naming rhythm language reference'
SLOT_ZH_naming='命名'; SLOT_ZH_rhythm='节奏'; SLOT_ZH_language='语言'; SLOT_ZH_reference='参考'
# 判定式「非空话」：比较/存在性判据任一命中；纯散文（遵守规范/人工确认/通过）不命中
RULE_OPERATORS='≤|≥|<|>|=|:=|⊆|∈|grep|wc|diff|sha'
PLACEHOLDER_OBS='^(tbd|todo|略|待终验|待补|待填|无|none|n\/a|-+|—+)$'

PLAN_DIR=''
MODE='plan'
for arg in "$@"; do
    case "$arg" in
        --final) MODE='final' ;;
        -h|--help)
            printf 'Usage: %s <plan-dir> [--final]\n' "$0"
            exit 0
            ;;
        --*) printf '[spec-baseline] ERROR: 未知参数 %s\n' "$arg" >&2; exit 2 ;;
        *)
            if [ -n "$PLAN_DIR" ]; then
                printf '[spec-baseline] ERROR: 多个 plan-dir 参数: %s\n' "$arg" >&2
                exit 2
            fi
            PLAN_DIR="$arg"
            ;;
    esac
done
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '[spec-baseline] ERROR: plan-dir 缺失或非目录: %s\n' "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
PLAN_FILE="$PLAN_DIR/task_plan.md"
STATE_FILE="$PLAN_DIR/plan-state.json"
VERIFY_FILE="$PLAN_DIR/verification.md"
SCAN_JSON="$PLAN_DIR/.spec-scan.json"
REPO_ROOT="$(cd "$PLAN_DIR/../.." 2>/dev/null && pwd || printf '%s' "$PLAN_DIR")"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/spec-baseline.XXXXXX")"
trap 'rm -f "$TMP/baseline.tsv" "$TMP/state.tsv" "$TMP/must.txt" "$TMP/sunits.tsv" "$TMP/final.tsv" "$TMP/body.txt"; rmdir "$TMP" 2>/dev/null || true' EXIT
# [2026-11-26 task-spec-consumption-chain 复核修复] What: mktemp 后预创建全部工作 TSV 为空文件。
# Why: 现场负例实测——早失败（如 C2 扫描未执行）后，后续 `while … done < "$TMP/xxx.tsv"` 的重定向目标不存在，bash 逐行吐「No such file or directory」噪声（rc=1 语义仍正确，但失败报告被噪声淹没）。预创建为空文件后各循环自然 no-op，失败输出只剩门自己的规范行。
touch "$TMP/baseline.tsv" "$TMP/state.tsv" "$TMP/must.txt" "$TMP/sunits.tsv" "$TMP/final.tsv" "$TMP/body.txt"

FAILS=0
# fail <编号> <符号> <原因> — stdout 为规范输出面，stderr 供调用方/夹具捕获编号
fail() {
    local msg="[spec-baseline] ✗ $1($2) $3"
    printf '%s\n' "$msg"
    printf '%s\n' "$msg" >&2
    FAILS=$((FAILS + 1))
}

# ── 抽取器：MD 视图为主，JSON 权威源为辅 ─────────────────────────────────────────
# [2026-11-26 task-spec-consumption-chain gate-fix3] What: extract_baseline 改为「候选段收集 + 择优」：
#   收集全部匹配 /规范基线/ 标题的段（按出现顺序编号）并缓存各段合法表行，END 时选首个存在
#   ≥9 格数据行的段（canonical 9 列渲染）；若所有段都不满足则回退取最后一个匹配段。
# Why: 真计划 task_plan.md 的 output_examples 把 OE-1 示例裸排为 Markdown（零围栏），示例内同样含
#   字面「## 🔒 规范基线」标题与 5 列伪表；旧逻辑「首段命中即采集并立即打印」会把示例当真表，
#   连锁误报 C4/C6/C8。以列数（真表 9 列 vs 示例伪表 5 列）作结构判据，无围栏时也能锁定真实基线。
# [2026-11-26 task-spec-consumption-chain gate-fix2] What: 两个抽取器（extract_baseline/extract_body）新增 ``` 围栏状态跟踪：
#   行首（允许前导空白）三反引号切换 fenced 0/1；fenced=1 时跳过段落进入判定与全部行采集，围栏行自身也不采集。
# Why: output_examples 的产出示例内含字面「## 🔒 规范基线」标题与 5 列伪表；此前无围栏状态就把示例当首个真实基线段，
#   连锁造成 C3/C4/C6/C8 误报（示例 SPEC-1 的 sha 1000e69e8653 被当作真表值）；围栏隔离后只消费真实基线段。
extract_baseline() {
    awk '
    # What: 围栏切换 + 围栏内行整行跳过；Why: 示例标题/伪表不得触发 inside 与表行采集
    /^[[:space:]]*```/ { fenced = 1 - fenced; next }
    fenced { next }
    # What: 新标题结束当前段（不退出文件扫描）；命中 /规范基线/ 则开启下一段候选并编号
    # Why: 示例伪表在前、真表在后，必须继续扫描才能收集全部候选段
    /^##[[:space:]]/ {
        if (inside) inside = 0
        if ($0 ~ /规范基线/) { inside = 1; seg++; next }
        next
    }
    inside && /^###[[:space:]]/ { inside = 0; next }
    inside && /^\|/ {
        n = split($0, c, "|")
        id = c[2]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        if (id !~ /^(SPEC-[0-9]+|NA-[0-9]+|SRC-[0-9]+|MK[0-9]*|SB[0-9]*|none-justified)$/) next
        for (i = 1; i <= 9; i++) f[i] = ""
        for (i = 2; i <= 10 && i <= n - 1; i++) {
            v = c[i+0]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); gsub(/\t/, " ", v)
            f[i-1] = v
        }
        # What: 扫描期只缓存行，不直接输出；同时按「n-2 ≥ 9」标记该段是否含 9 格数据行
        # Why: | a | ... | i | 被 split 成 n=11（首尾空串），5 列示例伪表仅 n=7；先收集后择优才不会误读示例
        if (n - 2 >= 9) seg_ok[seg] = 1
        segbuf[seg] = segbuf[seg] sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], f[9])
    }
    END {
        if (seg == 0) exit
        # What: 首个有 ≥9 格数据行的候选段胜出；全部不满足时回退最后一个匹配段（兼容老 5 列计划）
        # Why: 真计划的示例伪表在前、真 9 列表在后；结构判据替代「首个匹配」，杜绝伪表污染 C4/C6/C8
        chosen = 0
        for (i = 1; i <= seg; i++) if (seg_ok[i]) { chosen = i; break }
        if (!chosen) chosen = seg
        printf "%s", segbuf[chosen]
    }
    ' "$PLAN_FILE" > "$TMP/baseline.tsv"
}

# state_spec_rows — 从 plan-state.json 的 spec_baseline[] 抽 id/rule/src/verbatim
# Why: src 关联字段不在 MD 9 列渲染视图内，must 候选处置闭环只能回权威源核对。
extract_state() {
    awk '
    function field(buf, key,    s) {
        if (match(buf, "\"" key "\"[[:space:]]*:[[:space:]]*\"[^\"]*\"")) {
            s = substr(buf, RSTART, RLENGTH)
            sub(/^[^:]*:[[:space:]]*"/, "", s); sub(/"$/, "", s)
            return s
        }
        return ""
    }
    /"spec_baseline"[[:space:]]*:/ { inarr=1; buf=""; next }
    inarr && /^[[:space:]]*][,]?[[:space:]]*$/ { exit }
    inarr {
        buf = buf $0 "\n"
        if ($0 ~ /^[[:space:]]*}/) {
            id = field(buf, "id")
            if (id != "") printf "%s\t%s\t%s\t%s\n", id, field(buf, "rule"), field(buf, "src"), field(buf, "verbatim")
            buf = ""
        }
    }
    ' "$STATE_FILE" > "$TMP/state.tsv" 2>/dev/null || : > "$TMP/state.tsv"
}

extract_must_ids() {
    [ -f "$SCAN_JSON" ] || return 0
    awk '
    { line = line " " $0 }
    /}/ {
        if (line ~ /"cls"[[:space:]]*:[[:space:]]*"must"/ &&
            match(line, /"id"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
            s = substr(line, RSTART, RLENGTH)
            sub(/^.*:[[:space:]]*"/, "", s); sub(/"$/, "", s)
            print s
        }
        line = ""
    }
    ' "$SCAN_JSON" | sort -u > "$TMP/must.txt"
}

extract_sunits() {
    awk '
    /^\|[[:space:]]*S[0-9]+[[:space:]]*\|/ {
        n = split($0, c, "|")
        id = c[2]; ex = (n >= 4 ? c[4] : "")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", ex)
        if (id == "" || ex == "" || ex ~ /主进程/) next
        print id "\t" ex
    }
    ' "$PLAN_FILE" | sort -u > "$TMP/sunits.tsv"
}

# is_content_plan — 内容类判定唯一口径（C7 与 C3/F6 共用同一词表，避免双源漂移）
# [2026-11-26 task-spec-consumption-chain C3] What: 三路任一命中即内容类：
#   ①task_plan.md template_type/template_ref 命中 CONTENT_TEMPLATES
#   ②plan-state.json scenarios 命中创作场景词
#   ③S-unit 执行体命中 CONTENT_EXECUTORS（须先 extract_sunits）
# Why: 计划期 C7 四槽检查与终验期零 SPEC SKIP 必须用同一词表；否则内容类计划可借「零 SPEC」整链绕过。
# 返回: 0=内容类 / 1=非内容类；不输出任何文本。
is_content_plan() {
    if grep -E '^(template_type|template_ref):' "$PLAN_FILE" 2>/dev/null | grep -qE "$CONTENT_TEMPLATES"; then
        return 0
    fi
    if [ -f "$STATE_FILE" ] && grep -E '"scenarios"' "$STATE_FILE" 2>/dev/null | grep -qE '小说|剧本|分镜|长篇|创作'; then
        return 0
    fi
    if awk -F'\t' -v re="$CONTENT_EXECUTORS" '$2 ~ re {f=1} END{exit(f?0:1)}' "$TMP/sunits.tsv"; then
        return 0
    fi
    return 1
}

extract_final_rows() {
    awk '
    /^##[[:space:]]/ {
        if (inside) exit
        if ($0 ~ /基线-产物逐条核验表/) { inside=1; next }
    }
    inside && /^\|/ {
        n = split($0, c, "|")
        # [2026-11-26 C2] What: 抽取第 5 数据列 c[6]（证据锚 path:line 或回执）供 F5 验真。
        # Why: 26-critic.md:58-62 实证终验四项只抽 id/obs/concl，证据锚留空+观测任意文本+PASS 即过门。
        id = c[2]; obs = (n >= 5 ? c[5] : ""); concl = (n >= 7 ? c[7] : ""); anchor = (n >= 6 ? c[6] : "")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", obs)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", concl)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", anchor)
        if (id !~ /^SPEC-[0-9]+$/) next
        printf "%s\t%s\t%s\t%s\n", id, obs, concl, anchor
    }
    ' "$VERIFY_FILE" > "$TMP/final.tsv" 2>/dev/null || : > "$TMP/final.tsv"
}

# 正文 = task_plan.md 去掉所有规范基线段（含 output_examples 伪表），供 ⑨ VC 点名判定
extract_body() {
    awk '
    # What: 围栏内行既不切换 skip 也不写入正文；Why: 示例伪表中的 SPEC-id 不得冒充正文 VC 点名
    /^[[:space:]]*```/ { fenced = 1 - fenced; next }
    fenced { next }
    /^##[[:space:]]/ { skip = ($0 ~ /规范基线/) ? 1 : 0 }
    !skip { print }
    ' "$PLAN_FILE" > "$TMP/body.txt"
}

# ── l0-lite 零 attest 档自然豁免 ─────────────────────────────────────────────────
if [ -f "$PLAN_FILE" ] && grep -E '^(template_type|template_ref):.*l0-lite|^plan_tier:[[:space:]]*l0-lite' "$PLAN_FILE" >/dev/null 2>&1; then
    printf '[spec-baseline] SKIP l0-lite（零 attest 档豁免）\n'
    exit 0
fi

extract_baseline
extract_state

if [ "$MODE" = 'final' ]; then
    # ══ 终验期五项 + 内容类零 SPEC 阻断 ══════════════════════════════════════════
    # [2026-11-26 C2/C3] What: 终验五项执行前先数 task_plan.md 基线段 SPEC-* 行；
    #   非零 → 跑 F1..F5；为零 → 仅非内容类计划（与 C7 同一词表）才判「无可验基线」SKIP，
    #   内容类计划即使四槽全为 NA 也直接 F6 失败。
    # Why: 26-critic.md:64-67 实证「标题+扫描回执+零 SPEC+none-justified」可过计划门，
    #   --final 见 n_spec=0 即 PASS/spec=0 → 整链绕过；同时原抽取器丢弃证据锚列，
    #   空锚+任意观测+PASS 即可过门（C2）。这里同时收紧两处，非内容 legacy 计划保留 SKIP。
    extract_sunits
    n_spec=0; n_pass=0
    n_spec="$(awk -F'\t' '$1 ~ /^SPEC-/ {n++} END{print n+0}' "$TMP/baseline.tsv")"
    if [ "$n_spec" -eq 0 ]; then
        if is_content_plan; then
            fail 'F6' '⑥' '内容类计划零 SPEC（四槽 NA-only 不放行终验跳过）'
        else
            ZERO_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
            printf '{"status":"PASS","spec":0,"pass":0,"at":"%s"}\n' "$ZERO_AT" > "$PLAN_DIR/.spec-final.json"
            printf '[spec-baseline] ✓ 终验跳过（计划无 SPEC-* 行，无可验基线）\n'
            exit 0
        fi
    else
        extract_final_rows
        if [ ! -f "$VERIFY_FILE" ] || ! grep -qF '基线-产物逐条核验表（Rule 84.15）' "$VERIFY_FILE"; then
            fail 'F1' '①' "verification.md 缺「基线-产物逐条核验表（Rule 84.15）」标题"
        fi
        while IFS=$'\t' read -r sid _; do
            [ -n "$sid" ] || continue
            case "$sid" in SPEC-*) n_spec=$((n_spec + 1)) ;; esac
        done < "$TMP/baseline.tsv"
        while IFS=$'\t' read -r sid obs concl anchor; do
            [ -n "$sid" ] || continue
            if ! awk -F'\t' -v s="$sid" '$1 == s {f=1} END{exit(f?0:1)}' "$TMP/baseline.tsv"; then
                continue    # 核验表中多出的行不属于本计划 SPEC 集合，不参与覆盖判定
            fi
            if ! grep -qF -- "$sid" "$TMP/final.tsv"; then
                fail 'F2' '②' "$sid 核验表缺行"
                continue
            fi
            if [ -z "$obs" ] || printf '%s' "$obs" | grep -qiE "$PLACEHOLDER_OBS" \
               || printf '%s' "$obs" | grep -q '<'; then
                fail 'F3' '③' "$sid 观测列为空或占位（$obs）"
            fi
            # [2026-11-26 C2] 证据锚与观测同口径：空/占位/尖括号未替换均不放行。
            if [ -z "$anchor" ] || printf '%s' "$anchor" | grep -qiE "$PLACEHOLDER_OBS" \
               || printf '%s' "$anchor" | grep -q '<'; then
                fail 'F5' '⑤' "$sid 证据锚列为空或占位（${anchor:-<空>}）"
            fi
            if [ "$concl" != 'PASS' ]; then
                fail 'F4' '④' "$sid 结论非 PASS（${concl:-<空>}）"
            else
                n_pass=$((n_pass + 1))
            fi
        done < "$TMP/final.tsv"
        # 覆盖反向核对：每个 SPEC 必须在核验表有一行（F2）
        while IFS=$'\t' read -r sid _; do
            case "$sid" in
                SPEC-*) grep -qF -- "$sid" "$TMP/final.tsv" || fail 'F2' '②' "$sid 核验表缺行" ;;
            esac
        done < "$TMP/baseline.tsv"
    fi
else
    # ══ 计划期九项 ═══════════════════════════════════════════════════════════════
    if [ ! -f "$PLAN_FILE" ] || ! grep -qE '^##[[:space:]]+.*规范基线' "$PLAN_FILE"; then
        fail 'C1' '①' 'task_plan.md 缺「## 🔒 规范基线」标题行（render 产物）'
    fi
    # ② 扫描已执行：sidecar 或三文件内 [spec-scan] 收据
    scan_ok=0
    [ -f "$SCAN_JSON" ] && scan_ok=1
    if [ "$scan_ok" -eq 0 ]; then
        for f in "$PLAN_FILE" "$PLAN_DIR/findings.md"; do
            [ -f "$f" ] && grep -qF '[spec-scan]' "$f" && scan_ok=1
        done
    fi
    [ "$scan_ok" -eq 1 ] || fail 'C2' '②' '扫描未执行：.spec-scan.json 与 task_plan.md/findings.md 均无 [spec-scan] 收据'
    # ③ pending 未清（权威源 + MD 视图双查）
    # [2026-11-26 task-spec-consumption-chain gate-fix2] What: 两处 pending 检查均排除 SRC-* 行，非 SRC 的 pending 仍按原语义报告。
    # Why: SRC-* 是 spec-scan 候选，按设计 rule=pending（违规化会与扫描回执矛盾）；其处置闭环由 C4 经权威源 src 关联核对
    #   （SPEC(src=SRC-*) 或 NA(src=SRC-*) 且理由非空），不需要把候选行本身改为非 pending。
    if [ ! -f "$STATE_FILE" ]; then
        fail 'C3' '③' 'plan-state.json 缺失，无法核对 pending'
    else
        pending_id="$(awk -F'\t' '$1 !~ /^SRC-/ && $2 == "pending" {print $1; exit}' "$TMP/state.tsv")"
        [ -z "$pending_id" ] || fail 'C3' '③' "plan-state.json spec_baseline 存在 rule=pending 行（$pending_id）"
    fi
    if awk -F'\t' '$1 !~ /^SRC-/ && $4 == "pending" {print $1; exit}' "$TMP/baseline.tsv" | grep -q .; then
        fail 'C3' '③' 'MD 基线表存在非 SRC-* 且判定式=pending 行'
    fi
    # ④ 强制候选逐条处置：must 候选须有 SPEC(src=id) 或 NA(src=id, verbatim 理由非空)
    # [2026-11-26 task-spec-consumption-chain gate-fix3] What: NA「理由非空」判定由 $2 改为 $4（verbatim）。
    # Why: extract_state 输出列序固定为 id,rule,src,verbatim，NA 行的 $2(rule) 恒空导致旧判定恒假，
    #   真计划已登记的 NA-1/2/3 理由在 $4，误报 C4 SRC-2/4/5。
    extract_must_ids
    while IFS= read -r cid; do
        [ -n "$cid" ] || continue
        if ! awk -F'\t' -v c="$cid" '
            $1 ~ /^SPEC-/ && $3 == c {f=1}
            $1 ~ /^NA-/ && $3 == c && length($4) > 0 {f=1}
            END{exit(f?0:1)}' "$TMP/state.tsv"; then
            fail 'C4' '④' "must 候选 $cid 无 SPEC-* 或 NA-* 处置行（NA 须理由非空）"
        fi
    done < "$TMP/must.txt"
    # ⑤ SPEC 行判定式非空且是双向判定式（含比较/存在性判据，拒纯散文）
    while IFS=$'\t' read -r sid verb anchor rule sha rest; do
        case "$sid" in SPEC-*) ;; *) continue ;; esac
        if [ -z "$rule" ] || ! printf '%s' "$rule" | grep -qE "$RULE_OPERATORS"; then
            fail 'C5' '⑤' "$sid 双向判定式为空或纯散文（须含比较/存在性判据）"
        fi
    done < "$TMP/baseline.tsv"
    # ⑥ 来源锚验真：首个 path:line 的 path 存在；sha 列非空且等于该文件 sha256 前 12 位
    while IFS=$'\t' read -r sid verb anchor rule sha rest; do
        case "$sid" in SPEC-*) ;; *) continue ;; esac
        path="$(printf '%s' "$anchor" | awk '
            { if (match($0, /:[0-9]+/)) {
                s = substr($0, 1, RSTART - 1)
                n = split(s, a, /[[:space:]]|,|，|\+|（|\(|）/)
                print a[n]
              }
            }')"
        if [ -z "$path" ]; then
            fail 'C6' '⑥' "$sid 来源锚无 path:line（$anchor）"
            continue
        fi
        resolved=''
        case "$path" in
            /*) [ -f "$path" ] && resolved="$path" ;;
            *)  for cand in "$PLAN_DIR/$path" "$REPO_ROOT/$path" "$path"; do
                    [ -f "$cand" ] && { resolved="$cand"; break; }
                done ;;
        esac
        if [ -z "$resolved" ]; then
            fail 'C6' '⑥' "$sid 来源锚文件不存在（$path）"
            continue
        fi
        if [ -z "$sha" ]; then
            fail 'C6' '⑥' "$sid sha 列为空（须为来源文件 sha256 前 12 位）"
            continue
        fi
        actual="$(sha256sum "$resolved" | awk '{print $1}' | cut -c1-12)"
        expected="$(printf '%s' "$sha" | cut -c1-12)"
        if [ "$actual" != "$expected" ]; then
            fail 'C6' '⑥' "$sid sha 不一致（声明 $expected / 实测 $actual: $path）"
        fi
    done < "$TMP/baseline.tsv"
    # ⑦ 内容类四槽：naming/rhythm/language/reference，每槽 ≥1 SPEC(kind=槽) 或 NA(含槽名+理由)
    # [2026-11-26 C3] 判定统一走 is_content_plan()（与终验 F6 同一词表；extract_sunits 已在两模式入口调用）
    extract_sunits
    if is_content_plan; then
        for slot in $SLOTS; do
            zh="SLOT_ZH_$slot"; zh="${!zh}"
            if ! awk -F'\t' -v s="$slot" -v z="$zh" '
                $1 ~ /^SPEC-/ && tolower($6) == s { f=1 }
                $1 ~ /^NA-/ {
                    v = tolower($2)
                    if (index(v, s) > 0 || index(v, z) > 0) {
                        rest = v; gsub(s, "", rest); gsub(z, "", rest)
                        gsub(/[[:space:],，。:：（）()]/, "", rest)
                        if (length(rest) > 0) f=1
                    }
                }
                END{exit(f?0:1)}' "$TMP/baseline.tsv"; then
                fail 'C7' '⑦' "内容类四槽缺 $slot（需 SPEC kind=$slot 或 NA 理由）"
            fi
        done
    fi
    # ⑧ 绑定：每条非主进程 S-unit 的 S-id 被 ≥1 条 SPEC 的 applies 点名（含 * / all）
    while IFS=$'\t' read -r sid ex; do
        [ -n "$sid" ] || continue
        if ! awk -F'\t' -v s="$sid" '
            $1 ~ /^SPEC-/ && $8 ~ ("(^|[^A-Za-z0-9])(" s "|\\*|all)([^A-Za-z0-9]|$)") {f=1}
            END{exit(f?0:1)}' "$TMP/baseline.tsv"; then
            fail 'C8' '⑧' "$sid（执行体 $ex）未被任何 SPEC 的 applies 绑定"
        fi
    done < "$TMP/sunits.tsv"
    # ⑨ VC 点名：每条 SPEC-id 在正文（排除基线段/示例伪表）至少出现一次
    extract_body
    while IFS=$'\t' read -r sid _; do
        case "$sid" in
            SPEC-*) grep -qF -- "$sid" "$TMP/body.txt" || fail 'C9' '⑨' "$sid 未在 task_plan.md 正文（VC/判据列）被点名" ;;
        esac
    done < "$TMP/baseline.tsv"
fi

if [ "$FAILS" -gt 0 ]; then
    # 失败即清对应旧 sidecar：避免上一次 PASS 残留被 B19 证据串误读为当前通过（fail-closed）
    if [ "$MODE" = 'final' ]; then
        rm -f "$PLAN_DIR/.spec-final.json"
    else
        rm -f "$PLAN_DIR/.spec-baseline.json"
    fi
    printf '[spec-baseline] ✗ %d 项检查不通过（mode=%s）\n' "$FAILS" "$MODE" >&2
    exit 1
fi

AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [ "$MODE" = 'final' ]; then
    printf '{"status":"PASS","spec":%d,"pass":%d,"at":"%s"}\n' "$n_spec" "$n_pass" "$AT" > "$PLAN_DIR/.spec-final.json"
    printf '[spec-baseline] ✓ 终验四项全过（spec=%d pass=%d）→ %s/.spec-final.json\n' "$n_spec" "$n_pass" "$PLAN_DIR"
else
    n_spec="$(awk -F'\t' '$1 ~ /^SPEC-/ {n++} END{print n+0}' "$TMP/baseline.tsv")"
    n_na="$(awk -F'\t' '$1 ~ /^NA-/ {n++} END{print n+0}' "$TMP/baseline.tsv")"
    n_src="$(awk -F'\t' '$1 ~ /^SRC-/ {n++} END{print n+0}' "$TMP/baseline.tsv")"
    printf '{"status":"PASS","spec":%d,"na":%d,"src":%d,"at":"%s"}\n' "$n_spec" "$n_na" "$n_src" "$AT" > "$PLAN_DIR/.spec-baseline.json"
    printf '[spec-baseline] ✓ 计划期九项全过（spec=%d na=%d src=%d）→ %s/.spec-baseline.json\n' "$n_spec" "$n_na" "$n_src" "$PLAN_DIR"
fi
exit 0
