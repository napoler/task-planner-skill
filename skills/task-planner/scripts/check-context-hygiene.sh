#!/usr/bin/env bash
# check-context-hygiene.sh — 上下文退场机械检查器（Rule 29.2/29.3，task-v069）
#
# 用途: 扫描指定 plan-dir（plans/<task-id>/）下 findings.md + progress.md,
#   输出退场建议（每行前缀 [context-hygiene]）。只读,禁止写任何文件。
#
# 用法: bash scripts/check-context-hygiene.sh <plan-dir>
#
# 检查项:
#   1. findings.md 含 ~~ 删除线(superseded)条目 → 建议压缩进尾部 ## 压缩归档（非严重）
#   2. findings.md >500 行 → 建议压缩（严重, 29.3）
#   3. progress.md 已完成 Phase(### Phase N 且含 **Status:** complete) 段
#      Action 明细 >10 行 → 建议折叠为 3 行摘要（29.2c）；≥3 处 = 严重
#   4. findings.md 同一 ## 二级标题下 - 列表项 ≥5 → 建议折叠（非严重）
#
# 退出码（对齐 29.2 条款）:
#   0 = clean（无任何建议）/ 缺文件 fail-open
#   1 = 有退场建议（仅非严重项）
#   2 = 严重（第 2 类 findings>500 行, 或第 3 类折叠项 ≥3 处）

set -u

PFX="[context-hygiene]"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: bash scripts/check-context-hygiene.sh <plan-dir>" >&2
    exit 2
fi

PLAN_DIR="$(cd "$1" 2>/dev/null && pwd)" || {
    echo "${PFX} fail-open: plan-dir 不存在: $1"
    exit 0
}

FINDINGS="${PLAN_DIR}/findings.md"
PROGRESS="${PLAN_DIR}/progress.md"

if [ ! -f "$FINDINGS" ]; then
    echo "${PFX} fail-open: 无 findings.md"
    exit 0
fi

suggest=0   # 非严重建议计数
critical=0  # 严重计数

# --- [1] findings.md superseded(~~ 删除线)条目 → 压缩归档建议(非严重) ----
SUP_COUNT=$(grep -c '~~' "$FINDINGS" 2>/dev/null || true)
if [ "${SUP_COUNT}" -gt 0 ] 2>/dev/null; then
    echo "${PFX} 建议: findings.md 含 ${SUP_COUNT} 行 superseded(~~)条目 → 压缩进尾部 ## 压缩归档 段"
    suggest=$((suggest + 1))
fi

# --- [2] findings.md >500 行 → 严重(29.3) ----------------------------------
F_LINES=$(wc -l < "$FINDINGS" | tr -d '[:space:]')
if [ "${F_LINES}" -gt 500 ]; then
    echo "${PFX} 严重: findings.md ${F_LINES} 行 >500 → 触发压缩 SOP(29.3)"
    critical=1
fi

# --- [3] progress.md 已完成 Phase 段 Action 明细 >10 行 → 折叠建议(29.2c) --
if [ -f "$PROGRESS" ]; then
    fold_sites=$(awk '
        /^### Phase/ {
            if (cur != "" && done && lines > 10) c++
            cur = $0; done = 0; lines = 0
        }
        cur != "" {
            lines++
            if ($0 ~ /\*\*Status:\*\* complete/) done = 1
        }
        END {
            if (cur != "" && done && lines > 10) c++
            print c + 0
        }
    ' "$PROGRESS" 2>/dev/null || echo 0)
    if [ "${fold_sites}" -gt 0 ]; then
        # 列出命中段名
        awk -v n="0" '
            /^### Phase/ {
                if (cur != "" && done && lines > 10) {
                    n++; print n ": " cur
                }
                cur = $0; done = 0; lines = 0
            }
            cur != "" {
                lines++
                if ($0 ~ /\*\*Status:\*\* complete/) done = 1
            }
            END {
                if (cur != "" && done && lines > 10) print n + 1 ": " cur
            }
        ' "$PROGRESS" 2>/dev/null | while IFS= read -r line; do
            echo "${PFX} 建议: progress.md ${line} — Action 明细 >10 行 → 折叠为 3 行摘要(29.2c)"
        done
        if [ "${fold_sites}" -ge 3 ]; then
            echo "${PFX} 严重: progress.md ${fold_sites} 处已完成 Phase 段 >10 行(≥3) → 批量折叠"
            critical=1
        fi
        suggest=$((suggest + 1))
    fi
else
    echo "${PFX} info: 无 progress.md(跳过第 3 类检查)"
fi

# --- [4] findings.md 同 ## 二级标题下 - 列表项 ≥5 → 折叠建议(非严重) -------
awk '
    /^## / {
        if (h != "" && cnt >= 5) print h " (" cnt ")"
        h = $0; cnt = 0
        next
    }
    h != "" && /^- / { cnt++ }
    END {
        if (h != "" && cnt >= 5) print h " (" cnt ")"
    }
' "$FINDINGS" 2>/dev/null | while IFS= read -r line; do
    echo "${PFX} 建议: findings.md ${line} — 同主题 ≥5 条 → 折叠为 1 条带证据指针摘要"
done
FOLD4=$(awk '
    /^## / {
        if (h != "" && cnt >= 5) c++
        h = $0; cnt = 0
        next
    }
    h != "" && /^- / { cnt++ }
    END {
        if (h != "" && cnt >= 5) c++
        print c + 0
    }
' "$FINDINGS" 2>/dev/null || echo 0)
if [ "${FOLD4}" -gt 0 ] 2>/dev/null; then
    suggest=$((suggest + 1))
fi

# --- 汇总与退出码(对齐 29.2: 0=clean / 1=有建议 / 2=严重) ------------------
if [ "${critical}" -gt 0 ]; then
    echo "${PFX} 汇总: 严重项命中 → exit 2"
    exit 2
elif [ "${suggest}" -gt 0 ]; then
    echo "${PFX} 汇总: ${suggest} 类非严重退场建议 → exit 1"
    exit 1
else
    echo "${PFX} clean: 无退场建议"
    exit 0
fi
