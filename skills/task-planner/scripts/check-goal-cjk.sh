#!/usr/bin/env bash
# check-goal-cjk.sh — 纯中文 Goal 的 CJK 分词补检（locale 鲁棒，P-06）
# [2026-10-16 P-06 实施] 审计提案 P-06「纯中文 Goal 漂移补检（CJK 分词）」。
#
# What（判定逻辑 + 输入输出契约）:
#   输入: <plan-dir>/task_plan.md 的 `## Goal` 段（到下一个 `## ` 标题止；剥 <!-- --> 注释行）。
#   分词: locale 鲁棒 CJK 分词 —— 经 `od -An -tx1` 把目标文本转 UTF-8 字节 hex 串，由 awk 逐字节
#         做 3 字节 UTF-8 状态机解码，判定字节序列是否落入 CJK 基本区 U+4E00-U+9FFF 的
#         UTF-8 字节范围 {E4B880-E9BFBF 的合法 3 字节序列}；相邻 CJK 字符（被非 CJK 字符切分）
#         聚成一个词（即 2-4 字 CJK 词串），输出「词数 N」。全程 LC_ALL=C，不依赖 grep -oP '\w+'、
#         不依赖 locale 的 [[:alpha:]] 类别 —— 纯 bash + awk + od，同
#         check-evidence-anchor.sh 的「纯 bash 无 jq/python」口径。
#   判定:
#     · Goal 无 CJK 字符            → 正常（漂移补检无判定面）  → exit 0
#     · Goal 含 CJK 且抽出词数 > 0  → 分词成功（check-drift 可消费）→ exit 0
#     · Goal 含 CJK 但抽出词数 = 0  → CJK 分词失败，漂移检测将静默跳过 → exit 1
#     · 输入缺失（plan-dir 非目录 / task_plan.md 缺）→ exit 2
#   输出（stdout，前缀 [goal-cjk]）:
#     通过: `[goal-cjk] ✓ 抽出 N 个 CJK 词` / `[goal-cjk] ✓ Goal 无 CJK（漂移补检跳过，正常）`
#     缺陷: `[goal-cjk] ✗ Goal 含 CJK 但抽出词数=0 — CJK 分词失败，漂移检测将静默跳过`
#     错误: `[goal-cjk] ERROR: ...`（exit 2）
#   可选 `--fault-inject`：故障注入面 —— 模拟分词器失效（视作用户 Goal 恒含 CJK 且抽出词数=0），
#   仅用于 selftest 负例（GCK-06）的行为级断言，生产调用不得带。
#
# Why（设计取舍，逐条给理由）:
#   · 为什么不用 grep -oP '\w+'：check-drift.sh:187 现状就是它 —— 在多数 locale 下 `\w` 的字符类
#     不含 CJK（POSIX/C locale 下 `\w`≈[A-Za-z0-9_]），纯中文 Goal 的 `\w+` 匹配为空或把整段连读
#     成一个非词 token → 抽不出任何「≥3 字符关键词」（check-drift 还有 `${#word} -lt 3` 过滤）→
#     GOAL-DRIFT 检对该类 Goal 静默跳过（探测二 3-miss 根因）。本脚本是补检门，先保证「能抽词」，
#     再由 check-drift 消费词表。
#   · 为什么走 od+awk 字节态机而非 grep 字节区间：本仓 grep 是 ugrep（POSIX ERE 下 `\xNN` 转义
#     与 `[\344-\351]` 八进制区间均不可靠，实测 rc=1 无匹配）；`od -An -tx1 | awk` 对字节
#     逐位处理是 locale 完全免疫的（hex 字符纯 ASCII），且 od/awk 为 POSIX 必备件，零外部依赖。
#   · 为什么只认 CJK 基本区 U+4E00-U+9FFF：与 P-06 提案口径一致（覆盖 99%+ 常用汉字）；扩展区
#     A/B/CJK 兼容字符不在判定面（诚实边界：生僻字 Goal 分词仍可能 0 词 → exit 1，属保守面而非误报面）。
#   · 为什么有 --fault-inject：负例行为断言需要「CJK 存在但 0 词」的可达状态；用故障注入开关让
#     selftest 无需构造 locale 病态输入即可确定性触发该面（静态根因锚另由 GCK-05 守护：
#     CJK_RANGE_DEF 非空且含 0x4E00 边界）。
# 用法: bash check-goal-cjk.sh <plan-dir> [--fault-inject]
# 退出码: 0=分词成功或 Goal 无 CJK（正常）；1=CJK 分词失败（Goal 有 CJK 但 0 词）；2=输入缺失
# 依赖: bash + awk + od（纯 bash 实现，无 jq、无 python；awk 仅用 split/substr/index/match，mawk 兼容）
# 档位: 纯判定器，不读 config 档位；enforce 与否由未来接线 caller（check-drift 消费链）裁决。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PREFIX="[goal-cjk]"
FAULT=0
PLAN_DIR=""
# 解析参数: <plan-dir> [--fault-inject]（顺序自由，fault-inject 为无值旗标）
while [ $# -gt 0 ]; do
    case "$1" in
        --fault-inject) FAULT=1; shift ;;
        -h|--help)
            printf 'Usage: %s <plan-dir> [--fault-inject]\n' "$0"
            exit 0
            ;;
        -*)
            printf '%s ERROR: 未知参数 %s（支持 --fault-inject）\n' "$PREFIX" "$1" >&2
            exit 2
            ;;
        *)
            if [ -z "$PLAN_DIR" ]; then PLAN_DIR="$1"; else
                printf '%s ERROR: 多余位置参数 %s\n' "$PREFIX" "$1" >&2; exit 2
            fi
            shift
            ;;
    esac
done

if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
    printf '%s ERROR: plan-dir 缺失或非目录: %s\n' "$PREFIX" "${PLAN_DIR:-<empty>}" >&2
    exit 2
fi
PLAN_DIR="$(cd "$PLAN_DIR" && pwd)"
PLAN_FILE="$PLAN_DIR/task_plan.md"
if [ ! -f "$PLAN_FILE" ]; then
    printf '%s ERROR: task_plan.md 缺失: %s\n' "$PREFIX" "$PLAN_FILE" >&2
    exit 2
fi

# ── CJK 分词（locale 鲁棒）────────────────────────────────────────────────────
# 目标文本 → UTF-8 字节 hex（od -An -tx1: 每字节 2 个小写 hex 字符 + 空格分隔，多行输出）
# → awk 逐字节状态机（先 toupper 归一）:
#   · ASCII（00-7F）→ 非 CJK 符 → 冲刷当前词, j++
#   · 2/3/4 字节序列 lead（C-F）→ 先冲刷再单步 j++（续字节在下轮按 80-BF 续字节/新 lead 处理，
#     保持同步；UTF-8 字节里 80-BF 绝非法 lead，C-F 绝非法续字节，单步不会错位）
#   · 80-BF（续字节或孤立非法字节）→ 冲刷, j++
#   · 序列 E4-E9 且两续字节合法（80-BF）→ 按 CJK 基本区 U+4E00-U+9FFF 判定 → 是则追加词
# 相邻 CJK 字符按非 CJK 符切分 = 词（典型 2-4 字串）；词数即 N。
# CJK_RANGE_DEF 是 GCK-05 静态锚：被破坏（置空/去 0x4E00）→ GCK-06 必红，防静默回归。
CJK_RANGE_DEF='CJK_BASIC_E4_E9'
AWK_CJK='
function is_cjk(b1, b2, b3) {
    # CJK 基本区 U+4E00-U+9FFF 的 UTF-8 3 字节序列判定（字节级，locale 免疫）
    if (b1 == "E4") { if (b2 >= "B8") { if (b2 > "B8" || b3 >= "80") return 1; } return 0 }
    if (b1 == "E5") { if (b2 >= "80" && b2 <= "BC") return 1; if (b2 == "BD" && b3 <= "A3") return 1; return 0 }
    if (b1 >= "E6" && b1 <= "E8" && b2 >= "80" && b2 <= "BF") return 1
    if (b1 == "E9") { if (b2 >= "80" && b2 < "BF") return 1; if (b2 == "BF" && b3 <= "BF") return 1; return 0 }
    return 0
}
{
    for (i = 1; i <= NF; i++) {
        b = toupper($i)
        if (b ~ /^[0-9A-F][0-9A-F]$/) { B[++NB] = b }
    }
}
END {
    j = 1; word = ""
    while (j <= NB) {
        b1 = B[j]
        if ((b1 ~ /^[0-7][0-9A-F]$/) || (b1 ~ /^8[0-9A-F]$/) || (b1 ~ /^9[0-9A-F]$/) || (b1 ~ /^[AB][0-9A-F]$/)) {
            # ASCII 单字节 (00-7F): 冲刷。注意不可写 [0-9A-B] —— 那会误吞 E4-F7 的 CJK 3 字节 lead
            flush(); j++; continue
        }
        if (b1 ~ /^C[0-9A-F]$/) { flush()
            if (B[j+1] ~ /^[89A-F][0-9A-F]$/) j += 2; else j++; continue }       # 2 字节序列 (U+0080-U+07FF): 非 CJK
        if (b1 ~ /^E[0-9A-F]$/) {
            b2 = B[j+1]; b3 = B[j+2]
            if (b2 ~ /^[89A-F][0-9A-F]$/ && b3 ~ /^[89A-F][0-9A-F]$/) {
                # 合法 3 字节序列: CJK 追加字符标记 (seen=1 独立于词数, 词数靠 flush 提交), 非 CJK 冲刷; 跳 3 字节
                if (is_cjk(b1, b2, b3)) { word = word "c"; seen = 1 }
                else { flush() }
                j += 3; continue
            }
            j++; continue            # 非法 3 字节头（续字节缺失/ASCII）: 只前进 1 字节, 保持同步
        }
        if (b1 ~ /^F[0-9A-F]$/) { flush()
            if (B[j+1] ~ /^[89A-F][0-9A-F]$/ && B[j+2] ~ /^[89A-F][0-9A-F]$/ && B[j+3] ~ /^[89A-F][0-9A-F]$/) j += 4; else j++
            continue }              # 4 字节序列头: 非基本区（诚实边界）
        flush(); j++               # 续字节/孤立非法字节: 冲刷保同步
    }
    flush()                        # 尾词提交（flush 内部: 非空才计数并清零）
    printf "%d %d\n", wcnt, seen
}
# flush: 提交当前词。注意调用方不得先 word="" 再 flush —— 那会使 flush 恒见空词, 词数恒 0
# （2026-10-16 实测踩坑: 初版「word = ""; flush()」双清空致 CJK 词数恒 0, 判定退化为恒「无 CJK」）
function flush() { if (word != "") { wcnt++; word = "" } }
'

if [ "$FAULT" -eq 1 ]; then
    # 故障注入面: 模拟「Goal 含 CJK 但分词器 0 词」（selftest GCK-06 的可达负例状态）
    N=0; CJK_PRESENT=1
else
    # 抽 ## Goal 段（到下一个 ^## 止；剥注释行；同 check-drift.sh:179 的取段口径）
    # Goal 段全文 UTF-8 字节 hex → awk 词统计 → "N CJK_PRESENT"
    stats="$(LC_ALL=C awk '
        /^##[[:space:]]+Goal/ { inf = 1; next }
        inf && /^##[[:space:]]/ { inf = 0 }
        inf && !/^<!--/ && !/^-->[[:space:]]*$/ { print }
    ' "$PLAN_FILE" | LC_ALL=C od -An -tx1 | LC_ALL=C awk "$AWK_CJK" | tr -s ' \n' ' ')"
    N="${stats%% *}"
    CJK_PRESENT="${stats#* }"
    # tr -s 收尾留尾随空格 → 须再压字段间空格（GCK-02 实测踩坑：CJK_PRESENT 带尾随空格不中 0|1 字面 → 误判无 CJK）
    CJK_PRESENT="${CJK_PRESENT%% *}"
    case "$N" in ''|*[!0-9]*) N=0 ;; esac
    case "$CJK_PRESENT" in 0|1) ;; *) CJK_PRESENT=0 ;; esac
fi

if [ "$CJK_PRESENT" -eq 0 ]; then
    printf '%s ✓ Goal 无 CJK（漂移补检跳过，正常）\n' "$PREFIX"
    exit 0
fi
if [ "$N" -gt 0 ]; then
    printf '%s ✓ 抽出 %d 个 CJK 词\n' "$PREFIX" "$N"
    exit 0
fi
printf '%s ✗ Goal 含 CJK 但抽出词数=0 — CJK 分词失败，漂移检测将静默跳过\n' "$PREFIX"
exit 1
