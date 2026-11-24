#!/usr/bin/env bash
# check-spec-route.sh — Spec 路由运行时判定 + SP/OpenSpec 技能到达探针（方案A/H2）
# 事实源：<skill>/references/spec-mode.md §1/§1b 文本表；运行时只读该表抽取「场景/档位→路由」，不另立规则、不内联技能内容（R6）。
# 两级时序：init 期 cmd_init 拿不到需求特征 → --tier <L0|L1|L2|L2+> 产初判收据；需求产出后 B13 →
#   --feature <特征[,特征...]> 读表产终判收据（--receipt-file 落 route-receipts.jsonl）。
# Usage: --tier <档> | --feature <特征[,特征...]> | --probe；通用 [--dry-run|--no-dry-run] [--receipt-file <path>] [--json] [--spec-mode <path>] [--require-cli] [-h]
# 退出码：0=成功（含不路由）/ 1=用户错误（缺参/未命中）/ 2=环境错误（事实源缺失）/ 3=验证失败（--require-cli 且 CLI 不可达）。
# 安全默认：--dry-run 默认开启且只读；仅 --no-dry-run + --receipt-file 追加写收据；不改 ~/.bashrc、不安装。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_MODE="$SCRIPT_DIR/../references/spec-mode.md"
DRY_RUN=true
MODE=""
TIER=""
FEATURE=""
RECEIPT_FILE=""
REQUIRE_CLI=false
JSON_OUT=false

usage() {
    sed -n '2,8p' "${BASH_SOURCE[0]}"
}

# What: 去掉字符串首尾空白（纯 bash，无外部依赖）。
# Why: 表格列与命令行入参带空格；去空白才能让 tier/feature 与事实源表的字面量稳定比对。
trim() {
    local s="${1-}"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# What: JSON 字符串转义（\ " 换行/回车/Tab）。
# Why: route/scenario 来自中文 Markdown 表且含反引号与 →，不转义会破坏收据 JSONL 与 B13 证据解析。
json_escape() {
    local s="${1-}"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# What: 抽取 spec-mode.md 指定章节的文本行（start/end 为行首字面量前缀）。
# Why: 事实源只认 §1/§1b 表，按标题边界截取可避免正文叙述行被误当路由规则。
section_lines() {
    local start="$1" end="$2"
    awk -v s="$start" -v e="$end" '
        index($0, s) == 1 { on = 1; next }
        on && index($0, e) == 1 { exit }
        on { print }
    ' "$SPEC_MODE"
}

# What: 取 Markdown 表格行 "| a | b | c |" 的第 n 列（1-based）。
# Why: §1/§1b 的路由执行体固定在第 2 列，通用取列便于两节共用同一解析逻辑。
col() {
    local line="${1-}" n="${2:-1}" i=1 rest="" c=""
    rest="${line#|}"
    while [[ $i -lt $n ]]; do
        rest="${rest#*|}"
        ((i++)) || true
    done
    if [[ "$rest" == *"|"* ]]; then c="${rest%%|*}"; else c="$rest"; fi
    trim "$c"
}

# What: OpenSpec CLI 可移植探针，按序解析 npm prefix/bin → PATH → 本机观测路径兜底。
# Why: PATH 常不含 npm 全局 bin（本机实测 command -v openspec 失败但可执行文件存在）；
#       改 ~/.bashrc 的 export 是 no-op，硬编码单一路径又会在换机/多工具部署时失效。
#       三级解析全部失败时返回 1，由调用方显式记「不可接管」，不静默跳过。
probe_openspec() {
    local candidate="" prefix=""
    if command -v npm >/dev/null 2>&1; then
        prefix="$(npm config get prefix 2>/dev/null || true)"
        if [[ -n "$prefix" && -x "$prefix/bin/openspec" ]]; then
            candidate="$prefix/bin/openspec"
        fi
    fi
    if [[ -z "$candidate" ]] && command -v openspec >/dev/null 2>&1; then
        candidate="$(command -v openspec)"
    fi
    if [[ -z "$candidate" && -x "/home/terry/.npm-global/bin/openspec" ]]; then
        candidate="/home/terry/.npm-global/bin/openspec"
    fi
    [[ -n "$candidate" ]] || return 1
    printf '%s' "$candidate"
}

# What: Superpowers 技能到达探针（brainstorming/systematic-debugging 的 SKILL.md）。
# Why: B12「SP/OS 技能到达检查」需同时覆盖两族；SP 无 CLI，只能探测已安装技能文件，
#       缺失同样记「不可接管」并让 B12 的承接收据门 fail-closed。
probe_sp_skill() {
    local f=""
    for f in "$HOME/.zcode/skills/brainstorming/SKILL.md" \
             "$HOME/.agents/skills/brainstorming/SKILL.md" \
             "$HOME/.zcode/skills/systematic-debugging/SKILL.md" \
             "$HOME/.agents/skills/systematic-debugging/SKILL.md"; do
        [[ -f "$f" ]] && { printf '%s' "$f"; return 0; }
    done
    return 1
}

# What: 参数解析（--dry-run 安全默认；每个带值参数校验非空）。
# Why: 缺值时 set -u 下会取空串并产生难以定位的「无匹配」假象，显式 rc=1 更安全。
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)      DRY_RUN=true ;;
        --no-dry-run)   DRY_RUN=false ;;
        --tier|--feature|--receipt-file|--spec-mode)
            [[ $# -ge 2 ]] || { echo "[check-spec-route] ERR: $1 缺少参数" >&2; exit 1; }
            case "$1" in
                --tier)         MODE="tier";    TIER="$2" ;;
                --feature)      MODE="feature"; FEATURE="$2" ;;
                --receipt-file) RECEIPT_FILE="$2" ;;
                --spec-mode)    SPEC_MODE="$2" ;;
            esac
            shift 2
            continue
            ;;
        --tier=*)         MODE="tier";    TIER="${1#--tier=}" ;;
        --feature=*)      MODE="feature"; FEATURE="${1#--feature=}" ;;
        --receipt-file=*) RECEIPT_FILE="${1#--receipt-file=}" ;;
        --spec-mode=*)    SPEC_MODE="${1#--spec-mode=}" ;;
        --probe)        MODE="probe" ;;
        --require-cli)  REQUIRE_CLI=true ;;
        --json)         JSON_OUT=true ;;
        -h|--help)      usage; exit 0 ;;
        *) echo "[check-spec-route] ERR: 未知参数 $1（用 --help 查看用法）" >&2; exit 1 ;;
    esac
    shift
done

[[ -n "$MODE" ]] || { echo "[check-spec-route] ERR: 必须指定 --tier / --feature / --probe 之一" >&2; exit 1; }
if [[ "$MODE" == "tier" && -z "$TIER" ]]; then
    echo "[check-spec-route] ERR: --tier 需要非空入参（L0/mini/L1/L2/L2+）" >&2; exit 1
fi
if [[ "$MODE" == "feature" && -z "$FEATURE" ]]; then
    echo "[check-spec-route] ERR: --feature 需要非空需求特征" >&2; exit 1
fi
if [[ "$MODE" != "probe" && ! -r "$SPEC_MODE" ]]; then
    echo "[check-spec-route] ERR: 事实源不可读: $SPEC_MODE（环境错误）" >&2; exit 2
fi

# 探针先跑：无论路由模式还是 --probe 模式，都显式产出可观测状态。
SP_STATUS=""
OS_STATUS=""
if sp_path="$(probe_sp_skill)"; then SP_STATUS="reachable:$sp_path"; else SP_STATUS="unavailable(不可接管)"; fi
if os_path="$(probe_openspec)"; then OS_STATUS="reachable:$os_path"; else OS_STATUS="unavailable(不可接管)"; fi
if $REQUIRE_CLI && [[ "$OS_STATUS" == unavailable* ]]; then
    echo "[check-spec-route] VERIFY-FAIL: OpenSpec CLI 不可接管（--require-cli）" >&2
    echo "[check-spec-route] sp=$SP_STATUS openspec=$OS_STATUS" >&2
    exit 3
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# What: 按 tier 在 §1b 决策表中查「择一路由」，输出 <场景>\t<路由>。
# Why: init 期拿不到需求特征，只能按复杂度档粗筛；表是唯一事实源，故不在此处复制档位规则。
route_by_tier() {
    local want="$1" line="" c1="" c2=""
    while IFS= read -r line; do
        [[ "$line" == \|* ]] || continue
        c1="$(col "$line" 1)"; c2="$(col "$line" 2)"
        [[ -n "$c2" ]] || continue
        case "$want" in
            L0*|mini*) [[ "$c1" == L0* || "$c1" == *mini* ]] || continue ;;
            L1*)       [[ "$c1" == L1* ]] || continue ;;
            L2*)       [[ "$c1" == L2* ]] || continue ;;
            *)         [[ "$c1" == *"$want"* ]] || continue ;;
        esac
        printf '%s\t%s' "$c1" "$c2"
        return 0
    done < <(section_lines '### 1b.' '## 2. 安装引导')
    return 1
}

# What: 按需求特征在 §1 + §1b 表中做字面量匹配，输出命中行（<场景>\t<路由>），可多次命中。
# Why: 特征级终判必须反映「何时调用哪个技能」，而该映射只存在于 §1 路由表；
#       §1b 信号修正单元格形如「A→X；B→Y」，按「；」切片后取含 token 的片段、再取「→」后为路由，
#       这仍是对事实源文本的解析，不是新规则。
route_by_feature() {
    local tok="" line="" c1="" c2="" seg="" route="" matched=""
    local -a tokens=() segs=()
    IFS=',' read -ra tokens <<< "$FEATURE"
    for tok in "${tokens[@]}"; do
        tok="$(trim "$tok")"
        [[ -n "$tok" ]] || continue
        matched=""
        while IFS= read -r line; do
            [[ "$line" == \|* ]] || continue
            [[ "$line" == *"$tok"* ]] || continue
            c1="$(col "$line" 1)"; c2="$(col "$line" 2)"
            [[ -n "$c2" ]] || continue
            route="$c2"
            if [[ "$c2" == *"→"* ]]; then
                IFS='；' read -ra segs <<< "$c2"
                route=""
                for seg in "${segs[@]}"; do
                    if [[ "$seg" == *"$tok"* ]]; then
                        route="${seg#*→}"
                        break
                    fi
                done
                [[ -n "$route" ]] || route="${segs[0]#*→}"
            fi
            [[ -n "$matched" ]] && matched="$matched\n"
            matched="$matched$c1	$route"
        done < <( { section_lines '## 1. 触发判定与路由表' '### 1b.'; section_lines '### 1b.' '## 2. 安装引导'; } )
        [[ -n "$matched" ]] && printf '%b\n' "$matched"
    done
}

# What: 写/打印一条收据 JSONL；dry-run 只打印，非 dry-run 且给 --receipt-file 才追加写。
# Why: 收据需被 B13 的 evidence 解析（末行 route/input），且 dry-run 绝不落盘以保证安全默认。
emit_receipt() {
    local level="$1" input="$2" scenario="$3" route="$4"
    local line
    line="$(printf '{"level":"%s","input":"%s","scenario":"%s","route":"%s","sp":"%s","openspec":"%s","source":"%s","ts":"%s"}' \
        "$(json_escape "$level")" "$(json_escape "$input")" "$(json_escape "$scenario")" \
        "$(json_escape "$route")" "$(json_escape "$SP_STATUS")" "$(json_escape "$OS_STATUS")" \
        "$(json_escape "spec-mode.md:$([[ "$level" == tier ]] && printf '§1b' || printf '§1+§1b')")" "$(json_escape "$TS")")"
    if ! $DRY_RUN && [[ -n "$RECEIPT_FILE" ]]; then
        printf '%s\n' "$line" >> "$RECEIPT_FILE" || {
            echo "[check-spec-route] ERR: 收据写入失败: $RECEIPT_FILE" >&2
            return 3
        }
    fi
    printf '%s\n' "$line"
}

if [[ "$MODE" == "probe" ]]; then
    if $JSON_OUT; then
        printf '{"sp":"%s","openspec":"%s","ts":"%s"}\n' \
            "$(json_escape "$SP_STATUS")" "$(json_escape "$OS_STATUS")" "$(json_escape "$TS")"
    else
        echo "[check-spec-route] mode=probe sp=$SP_STATUS openspec=$OS_STATUS"
    fi
    exit 0
fi

MATCH_COUNT=0
UNMATCHED=""
RECEIPTS=""

if [[ "$MODE" == "tier" ]]; then
    if result="$(route_by_tier "$TIER")" && [[ -n "$result" ]]; then
        scenario="${result%%$'\t'*}"
        route="${result#*$'\t'}"
        MATCH_COUNT=1
        RECEIPTS="$(emit_receipt tier "$TIER" "$scenario" "$route")" || exit $?
    else
        UNMATCHED="$TIER"
    fi
else
    # feature 模式：逐 token 匹配，每行是一条 <场景>\t<路由>。
    while IFS= read -r result; do
        [[ -n "$result" ]] || continue
        scenario="${result%%$'\t'*}"
        route="${result#*$'\t'}"
        ((MATCH_COUNT++)) || true
        r="$(emit_receipt feature "$FEATURE" "$scenario" "$route")" || exit $?
        [[ -n "$RECEIPTS" ]] && RECEIPTS="$RECEIPTS"$'\n'
        RECEIPTS="$RECEIPTS$r"
    done < <(route_by_feature)
    # 特征未命中任何表行 = 用户入参错误（fail-closed，禁止默认留在本技能）。
    IFS=',' read -ra _tokens <<< "$FEATURE"
    for _t in "${_tokens[@]}"; do
        _t="$(trim "$_t")"
        [[ -n "$_t" ]] || continue
        if ! printf '%s' "$RECEIPTS" | grep -qF "\"input\":\"$_t\"" \
           && ! printf '%s' "$RECEIPTS" | grep -qF "$_t"; then
            [[ -n "$UNMATCHED" ]] && UNMATCHED="$UNMATCHED,"
            UNMATCHED="$UNMATCHED$_t"
        fi
    done
fi

if [[ -n "$UNMATCHED" ]]; then
    echo "[check-spec-route] ERR: 下列入参未在事实源 spec-mode.md §1/§1b 表中命中: $UNMATCHED" >&2
    [[ $MATCH_COUNT -gt 0 ]] && printf '%s\n' "$RECEIPTS"
    exit 1
fi
[[ $MATCH_COUNT -gt 0 ]] || { echo "[check-spec-route] ERR: 无匹配路由（事实源表为空或格式漂移）" >&2; exit 1; }

if $JSON_OUT; then
    printf '%s\n' "$RECEIPTS"
else
    echo "[check-spec-route] level=$MODE input=$([[ "$MODE" == tier ]] && printf '%s' "$TIER" || printf '%s' "$FEATURE") source=spec-mode.md:$([[ "$MODE" == tier ]] && printf '§1b' || printf '§1+§1b')"
    echo "[check-spec-route] sp=$SP_STATUS openspec=$OS_STATUS dry_run=$DRY_RUN"
    printf '%s\n' "$RECEIPTS"
fi
exit 0
