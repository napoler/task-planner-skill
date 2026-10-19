#!/bin/bash
# [2026-09-04] 新增 5 文件存在性复核（Rule 19.5 配套），缺失/空文件 exit 1
# [2026-09-13 task-v067] 第 6 文件 knowledge-brief.md 纳入建立/复核（5 文件→6 文件）
# [task-perf-opt 2026-10-13 Change #1/#7] trivial 代码修复档：TASK_AUTO_TIER=1 ∧ TASK_SCOPE_FILES=1 ∧
#   TASK_SCOPE_MODULES=1 ∧ TASK_EST_MINUTES≤15 ∧ TASK_EST_LINES≤3 ∧ TASK_SCOPE_FILE_LIST 唯 1 个代码文件
#   （.sh/.ts/.cjs/.js/.py/.json）→ auto-tier 第四条件命中 mini+L0（TRIVIAL_CODE_TIER=1），
#   且 7 计划文件缩减为 3（task_plan/progress/verification），user-session-log.md 改按需创建。
# Initialize planning files for a new session
# Usage: ./init-session.sh [project-name] [template-type] [plan-tier]  (tier: mini, env TASK_PLAN_TIER 亦可, task-v086 Rule 38.2)
#        bash init-session.sh --list [--project]  列出可用模板(内置 14 variant+项目目录 *-type.md+当前默认项), 不创建文件
#        默认模板: 项目 plan-templates/default 文件(内容=模板名) > env TASK_TEMPLATE_DEFAULT > 缺省 general (task-v086 S6)
#
# Template priority (per-file):
#   1. {project}/.claude/plan-templates/{filename}   (project-level, optional)
#   2. ~/.zcode/skills/task-planner/templates/{filename}    (built-in fallback)
#
# Path resolution: look for .claude/plan-templates/ by traversing upward from CWD

set -e

# [2026-09-21 task-v086 S6] --list 子命令: 输出当前可用模板清单(内置 variant+项目目录 *-type.md+当前默认项),
# 不创建任何文件, 无需 plans/<task-id> CWD 守卫, 直接 exit 0
LIST_TEMPLATES=0
for a in "$@"; do [ "$a" = "--list" ] && LIST_TEMPLATES=1; done
if [ "$LIST_TEMPLATES" = 1 ]; then
    _sdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _bvd="$_sdir/../templates/variant"
    _list_pdir=""
    _d="$(pwd)"
    while [ "$_d" != "/" ]; do
        if [ -d "$_d/.claude/plan-templates" ]; then _list_pdir="$_d/.claude/plan-templates"; break; fi
        if [ -d "$_d/.zcode/plan-templates" ]; then _list_pdir="$_d/.zcode/plan-templates"; break; fi
        _d="$(dirname "$_d")"
    done
    _def=""
    if [ -n "$_list_pdir" ] && [ -f "$_list_pdir/default" ]; then
        _def="$(head -n1 "$_list_pdir/default" 2>/dev/null | tr -d '[:space:]')"
    fi
    [ -z "$_def" ] && _def="${TASK_TEMPLATE_DEFAULT:-}"
    echo "Available templates (task-v086 S6 --list):"
    for f in "$_bvd"/*-type.md; do
        [ -e "$f" ] || continue
        echo "  $(basename "$f" | sed 's/-type\.md$//') (built-in)"
    done
    if [ -n "$_list_pdir" ]; then
        for f in "$_list_pdir"/*-type.md; do
            [ -e "$f" ] || continue
            echo "  $(basename "$f" | sed 's/-type\.md$//') (project)"
        done
    fi
    [ -n "$_def" ] && echo "[default] $_def" || echo "[default] general"
    exit 0
fi

# 2026-09-06 task-v053: CWD 守卫 — 原 PLAN_ROOT="$(cd .. && pwd)" 无校验,在非 plans/<task-id>/ 目录运行会把模板写进任意目录并向 ${PLAN_ROOT}/.active_plan(可能为根目录)写指针(实测 /tmp 运行 PLAN_ROOT 解析为 /)
if [ "$(basename "$(dirname "$(pwd)")")" != "plans" ]; then
    echo "[init] ERROR: 必须在 plans/<task-id>/ 目录下运行(当前目录: $(pwd),父目录: $(dirname "$(pwd)"))" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILTIN_TEMPLATES="${SCRIPT_DIR}/../templates"  # <platform-home>/skills/task-planner/templates/ (由安装位置派生, 平台无关)

# Find project-level templates: traverse upward from CWD to find .claude/ or .zcode/plan-templates/
find_project_templates() {
    local dir="$(pwd)"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude/plan-templates" ]; then
            echo "$dir/.claude/plan-templates"
            return 0
        fi
        if [ -d "$dir/.zcode/plan-templates" ]; then
            echo "$dir/.zcode/plan-templates"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Copy a template file: project-level if exists, else built-in
# Usage: copy_template <filename>
copy_template() {
    local filename="$1"
    local project_templates

    if project_templates=$(find_project_templates) && [ -f "$project_templates/$filename" ]; then
        cp "$project_templates/$filename" "$filename"
        echo "  └─ $filename (project-level)"
    elif [ -f "$BUILTIN_TEMPLATES/$filename" ]; then
        cp "$BUILTIN_TEMPLATES/$filename" "$filename"
        echo "  └─ $filename (built-in)"
    else
        echo "  └─ $filename: no template found, skipping"
        return 1
    fi
}

# ============================================================================
# [2026-10-05 task-v131 Phase 2] inject_requirement_block —
# Rule 51.1「🎯 用户需求原文」+ 第 4 锚「🧮 根源覆盖表」（Rule 53.1 载体）
# 区块的生成面注入兜底（审计 H-3 清账 + critic P1-3 对称性修复）
#
# What: 对任何刚生成/复制完成的 task_plan.md——两个区块锚**各自独立判断**：
#   锚 A `## 🎯 用户需求原文` / 锚 B `根源覆盖表`，缺哪个补哪个（模板已含其一
#   则只注入缺的那个；两者都缺则一次插入两个区块：🎯 区块在前、🧮 区块紧随其后，
#   格式对齐主模板 task_plan.md 现有同名区块）；非 mini 档 → 在第一个 `## Goal`
#   标题行之前插入脚手架（即头部「空行/HTML 注释/frontmatter 定界」块之后；无
#   Goal 行 → 头部块之后的首正文行之前；首行即正文时回落第 1 行）；占位符保留供
#   规划者填写；两锚俱在（主模板/rule-enhancement 变体自带载体）→ echo 一行
#   INFO 跳过。
# Why: 29 个 variant 模板零载体（审计 H-3）——前序单元只给了主模板+
#   rule-enhancement 变体载体；生成面注入是最后兜底，保证任何模板生成的新
#   计划必有 Rule 51.1 载体（计划侧零兜底修复）。critic P1-3：根源覆盖表无
#   锁定门与 51.1 三锚不对称 → 53.5 定稿「attest 51.1 门第 4 锚=根源覆盖表」，
#   生成面同步兜底（非 mini 计划两区块必在位，「不适用+定性理由」声明由规划者
#   在表格区填写，注入脚手架保留占位）。fail-open 设计：注入失败
#   （awk/写文件/磁盘/权限）仅 stderr 警告后继续 init、函数恒 return 0——
#   注入是增强而非前置依赖：缺区块不应阻断 6 文件校验与活跃指针写入，
#   规划者仍可手补（attest 侧四锚门另行把关）。
#   mini 豁免（Rule 38.2 区块白名单）：mini-lite 白名单仅 Goal/VC/执行范围
#   限制表/单 Phase/Handoff 表，增仪式区块=模板违约（selftest-plan-tier
#   断言）→ mini 档跳过注入。判定沿用脚本内既有分流变量/文件标记（二者或）：
#     ① TASK_PLAN_SRC=variant/mini-lite-type.md（L195 tier 分流路由产物）
#     ② 产物含 `plan_tier: mini` 标记（mini-lite 模板 :2 frontmatter /
#        auto-tier 命中标记 L256-258）
#   ①②都未命中而 PLAN_TIER=mini 且 variant 定制优先（L191-197 忽略场景）时，
#   产物实为中档定制 → 不豁免照注入（中档计划必须载 Rule 51.1/53.1 区块）。
# 幂等：锚 A/锚 B 独立判断，已含者永不重复插入；task_plan.md 已存在走
#   skip 分支的重复 init 再入本函数亦被锚判定短路。
# 插入量=🎯 脚手架 10 行（空行分隔符 1 + 9）；🧮 脚手架 11 行（空行分隔符 1
#   + 10，含 HTML 注释 2 行+四列表+占位行，格式对齐 templates/task_plan.md :19-25）；
#   双缺场景共写 21 行。
# ============================================================================
inject_requirement_block() {
    local file="task_plan.md"
    local scaffold insat inja injb

    [ -f "$file" ] || return 0

    # Gate 1: 双锚独立判断（P1-3：模板已含其一则只注入缺的那个）
    # 锚 A = 51.1 需求原文区块；锚 B = 53.1 根源覆盖表（grep「根源覆盖表」字样）
    inja=0; injb=0
    grep -q '## 🎯 用户需求原文' "$file" 2>/dev/null || inja=1
    grep -q '根源覆盖表' "$file" 2>/dev/null || injb=1
    if [ "$inja" -eq 0 ] && [ "$injb" -eq 0 ]; then
        echo "[init] INFO: task_plan.md 已含 🎯 用户需求原文 + 🧮 根源覆盖表 双区块（模板自带载体）— 注入跳过"
        return 0
    fi

    # Gate 2: mini 档豁免（Rule 38.2 白名单；判定见函数头注释 ①②）
    if [ "$TASK_PLAN_SRC" = "variant/mini-lite-type.md" ] \
       || grep -q 'plan_tier: mini' "$file" 2>/dev/null; then
        echo "[init] INFO: mini 档豁免（Rule 38.2 区块白名单）— 不注入 🎯 用户需求原文/🧮 根源覆盖表 区块"
        return 0
    fi

    # 插入位计算: 第一个 `## Goal` 标题行之前；无 Goal 行 → 文件头部注释块
    # （顶部连续的 空行 / HTML 注释行 / --- frontmatter 定界行）之后
    insat="$(grep -n '^## Goal' "$file" | head -n1 | cut -d: -f1)"
    if [ -z "$insat" ]; then
        # Why 用 awk 单遍扫描而非 shell 循环: 头部判定需跟踪多行 HTML 注释
        # 开闭状态（<!-- ... --> 跨行），awk 变量比 shell 临时文件干净
        # [2026-10-05 task-v131 CR-fix P1-1] 原 awk 在 { } 块内使用 pattern-action
        # 混合形式（`:154-186 区段`）gawk/mawk 均报 syntax error → 命令替换吞错
        # 置 insat=1 插文件顶、破坏 frontmatter，且 fail-open WARN 永不触发（与函数头
        # 文档不符）。整体重写为顶层 if/else 语句链 + END，语义不变=记录最后一个
        # 空行/分隔行位置作为插入点（frontmatter 注释块之后）。同步修正 :99 函数头
        # 「插文件头部注释块之后」不实描述与 :158 旧注释「mawk 不支持 || &&」错误
        # 前提（原行为 mawk 1.3.4 / gawk 5.2.1 实测均支持 || &&，该注释无实据）。
        # [2026-10-05 task-v131 CR-fix P1-1b] 注释开闭判定修正：
        # ① 单行自闭注释（含 --> 一行内闭合）原被误置 cmt=1；
        # ② 多行注释闭行若 --> 前有其它文本（如 "     multi-line note -->"），
        #    行首锚定正则 ^--> / ^[[:space:]]*--> 均不命中 → cmt 永不复位 →
        #    后续正文行全被吞为「注释内部」→ last 滑到文件尾 → 插入点越界
        #    （insat=文件行数+1，脚手架静默丢失，实测 insat=6/5 行文件）。
        # 修法：闭行判定改为「行内含 -->」（自闭注释与多行闭行同命中，cmt 复位）。
        insat="$(awk '
            {
                if (done) next
                # 首行即正文（非空行/非 HTML 注释开/非 frontmatter 定界）→ 插文件顶
                if (NR==1 && $0 !~ /^[[:space:]]*$/ && $0 !~ /^<!--/ && $0 !~ /^---$/) { print 1; done=1; exit }
                # 行内含 -->（自闭注释行 或 多行注释闭行，闭行 --> 前可带任意文本/缩进）
                # → 注释态复位，头部块记到本行
                if ($0 ~ /-->/) { cmt=0; last=FNR; next }
                # 空行 / frontmatter 定界行属头部块
                if ($0 ~ /^[[:space:]]*$/ || $0 ~ /^---$/) { last=FNR; next }
                # 多行 HTML 注释开（<!-- 起且本行未闭合，上一 if 已排除）
                if ($0 ~ /^<!--/) { cmt=1; last=FNR; next }
                # 多行 HTML 注释内部行（既非开也非闭）
                if (cmt) { last=FNR; next }
                # 首个正文行 → 头部块止于上一行（插入点=本行行号，即"之后"）
                print FNR; done=1; exit
            }
            END { if (!done) print (last>0 ? last+1 : 1) }
        ' "$file" 2>/dev/null)"
        if [ -z "$insat" ]; then
            # [2026-10-05 task-v131 CR-fix P1-1] awk 失败原本仅 `|| insat=""` 静默回落
            # insat=1，fail-open WARN 永不触发（与 :107-110 文档不符）。改为显式
            # WARN 到 stderr 后回落（fail-open 语义保留：仅警告不阻断 init）
            echo "[init] WARN: 需求区块插入位计算失败（awk 扫描异常）— 回落第 1 行注入（fail-open: 规划者可复核插入位置）" >&2
            insat=1
        fi
    fi

    # 脚手架落临时文件（quoted heredoc: 占位符 <...> 与 ** 须原样保留，禁展开）
    # 双区块独立拼接：缺哪个注入哪个；双缺=🎯 在前 🧮 紧随（主模板 :19-25 顺序）
    scaffold="$(mktemp)" || {
        echo "[init] WARN: 需求区块注入失败（mktemp 失败）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        return 0
    }
    if [ "$inja" -eq 1 ]; then
        cat > "$scaffold" <<'EOF'
## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：init 注入载体（审计 H-3 清账；Rule 51.1 计划侧零兜底修复）。R 行=用户原话逐条编号；映射=每条核心需求 ≥1 VC；本脚手架由规划者填写后 attest 校验 -->

- **R1**: 「<用户原话第 1 条，逐字抄录，禁转译>」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | <判据：计数=0/文件在位+绝对路径/命令输出形态> |
EOF
    fi
    if [ "$injb" -eq 1 ]; then
        # 双缺场景补空行分隔 🎯/🧮 两区块；单缺场景（仅注 🧮）前补空行与上文隔开
        printf '\n' >> "$scaffold"
        cat >> "$scaffold" <<'EOF'
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 2026-10-05 task-v131：Rule 53.1 载体（critic P1-3 对称性修复：attest 51.1 门第 4 锚=根源覆盖表，
     53.5 定稿）；结果级需求（确保质量/性能/可靠类）必须分解生产管线逐工序审计缺陷面；
     非结果级（单点动作）任务须写「不适用（非结果级需求）」+一句定性理由（53.1 禁裸豁免，
     attest/终验可核）；attest 锚级 grep 本区块标题/字样判定在位 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| <工序 1> | <此工序削弱该结果的缺陷/缺口，无则"无"> | <修复 S-unit/Phase> | <VC-n> |
EOF
    fi
    # 在 insat 行之前打印脚手架 + 1 行空行分隔（保住 markdown 结构；写入行数
    # =🎯 9 行 / 🧮 10 行 / 双缺 9+1+10，见函数头「插入量」注释）
    if ! awk -v f="$scaffold" -v insat="$insat" '
        NR==insat && !done { while ((getline s < f) > 0) print s; print ""; done=1 }
        { print }
    ' "$file" > "${file}.v131tmp" 2>/dev/null; then
        # fail-open（见函数头 Why）: awk 失败 → stderr 警告，清理，继续 init
        echo "[init] WARN: 需求区块注入失败（awk 写出异常）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v131tmp" "$scaffold"
        return 0
    fi
    if ! mv "${file}.v131tmp" "$file" 2>/dev/null; then
        # fail-open: 磁盘/权限类写回失败同样不中断 init
        echo "[init] WARN: 需求区块写回失败（磁盘/权限）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v131tmp" "$scaffold"
        return 0
    fi
    rm -f "$scaffold"
    if [ "$inja" -eq 1 ] && [ "$injb" -eq 1 ]; then
        echo "    [init] 🎯 用户需求原文 + 🧮 根源覆盖表 双脚手架已插入（Rule 51.1/53.1 生成面兜底, task-v131 P1-3；规划者填写 R 行/映射/覆盖表后 attest 校验）"
    elif [ "$inja" -eq 1 ]; then
        echo "    [init] 🎯 用户需求原文 脚手架已插入（Rule 51.1 生成面兜底, task-v131；规划者填写 R 行+映射后 attest 校验；🧮 根源覆盖表已含于模板）"
    else
        echo "    [init] 🧮 根源覆盖表 脚手架已插入（Rule 53.1 载体, critic P1-3；🎯 用户需求原文已含于模板；规划者填表或写「不适用+定性理由」后 attest 校验）"
    fi
    return 0
}

# ============================================================================
# [2026-10-07 task-v143 CR-fix F-1] inject_evidence_goal_block —
#   Rule 58 计划载体生成面兜底（镜像 inject_requirement_block 范式，task-v131 先例）。
#
# What:
#   variant 路由任务（cp variant/<x>-type.md task_plan.md 直拷，含 research-type.md——
#   恰是 Rule 58 的首要覆盖面）的产物不含主模板新增的「🔍 证据面清单」「🎯 核心目标达成裁决」
#   双区块；本函数对缺锚产物按同一脚手架兜底注入，使 58.1/58.7「init 全任务注入」声明在
#   主模板与 variant 双路径下均成立。
#
# Why:
#   Rule 58 的任务级强制依赖模板载体（58.7 消费侧声明）；仅主模板携带而 variant 零载体 =
#   调研/分析类任务（research-type 路由）恰成覆盖盲区（CR F-1 MAJOR，2026-10-07）。
#   与 51.1 注入兜底（task-v131 因 29 variant 零载体补建）同构。
#
# 语义（与 inject_requirement_block 同范式）:
#   幂等：锚 C（证据面清单）/锚 D（达成裁决）独立判断，已含者永不重复插入；重复 init 走
#   skip 分支再入本函数亦被锚判定短路。mini 档豁免（Rule 38.2，判定同 51.1 函数：mini-lite
#   路由或 plan_tier: mini 标记）。插入位=「## Current Phase」行之前（对齐主模板区块序）；
#   无该行回落「## Goal」行之前；再无（极端残缺模板）→ stderr WARN 跳过（fail-open：
#   注入是增强非前置依赖，规划者可手补），不阻断 init。
# 插入量=🔍 脚手架 13 行（含 HTML 注释 4+空行分隔）+🎯 脚手架 16 行（含 HTML 注释 5）
#   +区块间空行 1；双缺共写 30 行；单缺按需。内容与 templates/task_plan.md 对应区块一致。
# ============================================================================
inject_evidence_goal_block() {
    local file="task_plan.md"
    local insc insd insat scaffold

    [ -f "$file" ] || return 0

    # Gate 1: 双锚独立判断
    insc=0; insd=0
    grep -q '## 🔍 证据面清单' "$file" 2>/dev/null || insc=1
    grep -q '## 🎯 核心目标达成裁决' "$file" 2>/dev/null || insd=1
    if [ "$insc" -eq 0 ] && [ "$insd" -eq 0 ]; then
        echo "[init] INFO: task_plan.md 已含 🔍 证据面清单 + 🎯 核心目标达成裁决 双区块（模板自带载体）— 注入跳过"
        return 0
    fi

    # Gate 2: mini 档豁免（Rule 38.2 白名单，与 inject_requirement_block 同判定）
    if [ "$TASK_PLAN_SRC" = "variant/mini-lite-type.md" ] \
       || grep -q 'plan_tier: mini' "$file" 2>/dev/null; then
        echo "[init] INFO: mini 档豁免（Rule 38.2 区块白名单）— 不注入 🔍 证据面清单/🎯 核心目标达成裁决 区块"
        return 0
    fi

    # 插入位：优先「## Current Phase」行前（主模板区块序）；回落「## Goal」行前；
    # 均无 → WARN 跳过（fail-open，不阻断 init）
    insat="$(grep -n '^## Current Phase' "$file" | head -n1 | cut -d: -f1)"
    if [ -z "$insat" ]; then
        insat="$(grep -n '^## Goal' "$file" | head -n1 | cut -d: -f1)"
    fi
    if [ -z "$insat" ]; then
        echo "[init] WARN: Rule 58 区块插入位未找到（无 Current Phase/Goal 锚行）— 跳过注入（fail-open: 规划者可手补双区块）" >&2
        return 0
    fi

    # 脚手架落临时文件（quoted heredoc: 占位符原样保留，禁展开）；双区块独立拼接
    scaffold="$(mktemp)" || {
        echo "[init] WARN: Rule 58 区块注入失败（mktemp 失败）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        return 0
    }
    if [ "$insc" -eq 1 ]; then
        cat > "$scaffold" <<'EOF'
## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复，镜像 51.1 注入兜底范式）。适用判定:产出=结论/判断/建议/原因解释的任务；
     豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免 -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | （自身内容/产品/数据） | | | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） | | | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） | | | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。
EOF
    fi
    if [ "$insd" -eq 1 ]; then
        # 双缺/单缺场景统一前补空行与上文隔开
        printf '\n' >> "$scaffold"
        cat >> "$scaffold" <<'EOF'
## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复）。58.4 手段/目标二分在需求区 R 行标注 [手段]/[目标]；
     本区块终验时回收目标型需求的解决状态；not-solved/partial 禁止标 COMPLETE（58.5②） -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。
EOF
    fi
    # 在 insat 行之前打印脚手架 + 1 行空行分隔（保住 markdown 结构）
    if ! awk -v f="$scaffold" -v insat="$insat" '
        NR==insat && !done { while ((getline s < f) > 0) print s; print ""; done=1 }
        { print }
    ' "$file" > "${file}.v143tmp" 2>/dev/null; then
        echo "[init] WARN: Rule 58 区块注入失败（awk 写出异常）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v143tmp" "$scaffold"
        return 0
    fi
    if ! mv "${file}.v143tmp" "$file" 2>/dev/null; then
        echo "[init] WARN: Rule 58 区块写回失败（磁盘/权限）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v143tmp" "$scaffold"
        return 0
    fi
    rm -f "$scaffold"
    if [ "$insc" -eq 1 ] && [ "$insd" -eq 1 ]; then
        echo "    [init] 🔍 证据面清单 + 🎯 核心目标达成裁决 双脚手架已插入（Rule 58.1/58.5 生成面兜底, task-v143 CR-fix F-1；规划者填写取证行/裁决表后 attest 复核）"
    elif [ "$insc" -eq 1 ]; then
        echo "    [init] 🔍 证据面清单 脚手架已插入（Rule 58.1 生成面兜底, task-v143；🎯 核心目标达成裁决已含于模板）"
    else
        echo "    [init] 🎯 核心目标达成裁决 脚手架已插入（Rule 58.5 生成面兜底, task-v143；🔍 证据面清单已含于模板）"
    fi
    return 0
}

# [2026-09-15 task-v074 P4-S1] 1) TEMPLATE_TYPE 位置参数为空时兜底 env TASK_TEMPLATE_TYPE
#    (消 SKILL.md:505 "自动路由"语义漂移——SKILL 描述与实现一致化) # 2026-10-08 task-v149 行号锚对齐实态（D10）
#    2026-10-11 task-v170 S10f Rule 45 锚校准: 原锚 :505 已失真（"自动路由" 字样在当前 SKILL.md 全文 0 命中）；
#    该注释想指向的「模板类型选取由 init-session.sh 自动处理」描述现值 = SKILL.md:60（「模板优先级（由 init-session.sh 自动处理，无需手动干预）」），锚 :505→:60
#    2) VALID_TYPES 改为从 $BUILTIN_TEMPLATES/variant/*-type.md 动态派生 + general 兜底
#    (Rule 34.1 单一事实源=模板目录, 与 check-template-type.sh 同源原则; 原行为保留:
#     未知/缺失类型 WARNING 回退 generic task_plan.md)
PROJECT_NAME="${1:-project}"
TEMPLATE_TYPE="${2:-${TASK_TEMPLATE_TYPE:-}}"   # positional first, env fallback
# [2026-09-20 task-v086 P2-S2 Rule 38.2] 第 3 位置参或 env TASK_PLAN_TIER=mini（tier 路由，
#   与 template_type 正交；38.4 非 mini 零影响铁律）
# [2026-09-27 task-v091 S22 A-1 Rule 38.6] 缺省契约改写（36.4 清单①登记）：
#   原「缺省=现状行为逐字节不变」→「四条件全命中（env TASK_AUTO_TIER=1 提交体量事实且
#   预估 ≤15min ∧ scope_files ≤2 ∧ 单模块 ∧ ④排除未命中）且未显式指定 tier 时自动 mini」；
#   无 TASK_AUTO_TIER=1 输入的调用路径仍与 task-v091 前逐字节一致
PLAN_TIER="${3:-${TASK_PLAN_TIER:-}}"
# [2026-09-21 task-v086 S6] 复制源命中项目级自造模板=1 (frontmatter 插入判定用)
PROJECT_TPL_USED=0
# [2026-09-27 task-v091 S22 A-1] auto-tier 四条件判定（Rule 38.6；慢源 R16=忘传 tier 即落
#   419 行 general 重档）。主进程调用前以 env 提交任务体量事实（三体量条件为派发前模型估计、
#   ④排除同为模型自判——提案质量风险披露），脚本侧机器闸门：四条件全过且未显式指定 tier
#   才自动降 mini；任一不过/输入缺失/非法 → 保持缺省档（fail-safe，兼容 38.4 非 mini 零影响
#   铁律：无 TASK_AUTO_TIER=1 的调用零影响）。显式优先：第 3 位置参 > env TASK_PLAN_TIER >
#   自动判定（显式声明任何档位时本块不参与，auto_tier 不覆盖显式值）。
#   ④排除语义：目标命中保护区（§六 skills/agents/commands/AGENTS.md）、Rule 36 技能修改类、
#   D6 高危类（schema/基础设施/破坏性操作）→ 禁止自动降 mini（显式指定 mini 仍可）。
AUTO_TIER_FIRED=0
# [task-perf-opt 2026-10-13 Change #1] TRIVIAL_CODE_TIER：trivial 代码修复档标记（第四条件分支命中时置 1）。
# 与既有 AUTO_TIER_FIRED 正交：AUTO_TIER_FIRED 记「自动降 mini」事实（终验 AUTO-TIER 复核段消费锚），
# TRIVIAL_CODE_TIER 记「trivial 代码修复」子类（Change #7 三文件缩减 + L0 通道强制共用同一条件，
# 条件口径与本块第四分支逐字一致，避免两处判定漂移）。
TRIVIAL_CODE_TIER=0
_s22_uint() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }
# trivial 代码修复判定（Change #1 第四条件）：TASK_SCOPE_FILE_LIST 逗号分隔文件名列表中
# 唯 1 个文件 ∧ 该文件匹配代码扩展名（.sh/.ts/.cjs/.js/.py/.json）。
# 主进程在调用 init-session.sh 前以 env 提交 TASK_SCOPE_FILE_LIST（从用户指令解析的 scope 文件列表）
# 与 TASK_EST_LINES（预估变更行数）；未设置/非法 → 本判定=0，fail-safe 落既有四条件/缺省档。
_trivial_code=0
if [ "${TASK_SCOPE_FILES:-}" = "1" ] && [ "${TASK_SCOPE_MODULES:-}" = "1" ] \
   && _s22_uint "${TASK_EST_MINUTES:-}" && [ "${TASK_EST_MINUTES}" -le 15 ] \
   && _s22_uint "${TASK_EST_LINES:-}" && [ "${TASK_EST_LINES}" -le 3 ] \
   && [ -n "${TASK_SCOPE_FILE_LIST:-}" ]; then
    _t_nfiles="$(printf '%s' "${TASK_SCOPE_FILE_LIST}" | awk -F',' '{print NF}')"
    if [ "${_t_nfiles:-0}" = "1" ]; then
        _t_fname="$(printf '%s' "${TASK_SCOPE_FILE_LIST}" | tr -d '[:space:]')"
        case "$_t_fname" in
            *.sh|*.ts|*.cjs|*.js|*.py|*.json) _trivial_code=1 ;;
        esac
    fi
    # [H2-fix 2026-10-14] 保护区路径检查：扩展名命中 ≠ trivial 可放行。
    # 宪法 §11.5 条件4 明确要求「非保护区文件」，此处机器化该前提：
    # 镜像 check-delegation.sh:332-345 保护区 case 列表，保护区路径命中则强制 _trivial_code=0，
    # 防止 trivial 档将保护区文件（~/.zcode/skills/ 下脚本、package.json 等基础设施）路由到 L0 薄验证通道。
    if [ "${_trivial_code:-0}" = "1" ]; then
        case "$_t_fname" in
            */.zcode/skills/*|*/.zcode/agents/*|*/.zcode/commands/*|*/.zcode/AGENTS.md|*/.zcode/cli/*)
                _trivial_code=0 ;;
            */.claude/skills/*|*/.agents/skills/*|*/.agents/AGENTS.md|*/.agents/agents/*|*/.agents/commands/*|*/.config/opencode/*)
                _trivial_code=0 ;;
            skills/*|*/skills/*|agents/*|*/agents/*)
                _trivial_code=0 ;;
            *package.json|*pyproject.toml|*/.github/*|*/.gitlab-ci.yml|*/k8s/*)
                _trivial_code=0 ;;
            *docker-compose*|*/.env*|*Dockerfile|*nginx.conf)
                _trivial_code=0 ;;
        esac
        [ "${_trivial_code}" = "0" ] && echo "[init] trivial 代码修复档：文件 ${_t_fname} 命中保护区（§六/§11.5 条件4），强制不降档"
    fi
fi
if [ -z "$PLAN_TIER" ] && [ "${TASK_AUTO_TIER:-}" = "1" ]; then
    if [ "${TASK_TIER_EXCLUDE:-}" = "1" ]; then
        echo "[init] auto-tier: 命中④排除条件（保护区/Rule 36 技能修改/D6 高危），不自动降 mini（Rule 38.6；显式指定 mini 仍可）"
    elif [ "$_trivial_code" = "1" ]; then
        # [task-perf-opt Change #1] 第四条件分支：trivial 代码修复（单文件代码 ∧ ≤3 行 ∧ ≤15min ∧ 单模块
        # ∧ ④排除未命中）→ mini 档 + L0 微变更通道。Why：L0 通道存在但 lane-detect 禁滥用条款将代码文件
        # 改动一律排除（lane-detect.sh:86 实测），trivial 单文件 ≤3 行修复被误落 L1 重档；本分支为
        # 既有 mini 通道补 trivial 代码子类，复用 mini 豁免（多波验证/推演自证/委派仪式）+ L0 薄验证。
        PLAN_TIER="mini"
        AUTO_TIER_FIRED=1
        TRIVIAL_CODE_TIER=1
        echo "[init] auto-tier: trivial 代码修复命中（scope=单文件代码 ${TASK_SCOPE_FILE_LIST} ∧ 预估 ${TASK_EST_LINES} 行 ≤3 ∧ ${TASK_EST_MINUTES}min ≤15 ∧ 单模块 ∧ ④排除未命中）→ mini+L0（Rule 38.6 第四条件, task-perf-opt）"
    elif _s22_uint "${TASK_EST_MINUTES:-}" && [ "${TASK_EST_MINUTES}" -le 15 ] \
       && _s22_uint "${TASK_SCOPE_FILES:-}" && [ "${TASK_SCOPE_FILES}" -ge 1 ] && [ "${TASK_SCOPE_FILES}" -le 2 ] \
       && _s22_uint "${TASK_SCOPE_MODULES:-}" && [ "${TASK_SCOPE_MODULES}" -eq 1 ]; then
        PLAN_TIER="mini"
        AUTO_TIER_FIRED=1
        echo "[init] auto-tier: 四条件全过（预估 ${TASK_EST_MINUTES}min ≤15 ∧ scope_files ${TASK_SCOPE_FILES} ≤2 ∧ 单模块 ∧ ④排除未命中）→ 自动降档 mini（Rule 38.6）"
    else
        echo "[init] auto-tier: 体量三条件未全命中或输入缺失/非法，保持缺省档（Rule 38.6 fail-safe）"
    fi
fi
DATE=$(date +%Y-%m-%d)

echo "Initializing planning files for: $PROJECT_NAME"

# Template type routing (Rule 16, v2.2.1 + Rule 34.1 动态派生): variant task_plan selected by template_type
# Usage: ./init-session.sh [project-name] [template-type] | TASK_TEMPLATE_TYPE=<type> ./init-session.sh [project-name]
# [2026-09-15 task-v074 P4-S1] 白名单动态派生: general + ls $BUILTIN_TEMPLATES/variant/*-type.md 去后缀
#    (与 check-template-type.sh 同源自模板目录, 消除硬编码 12 类清单副本)
VARIANTS_DIR="${BUILTIN_TEMPLATES}/variant"
VALID_TYPES="general $(ls "$VARIANTS_DIR"/*-type.md 2>/dev/null | sed 's/.*\///;s/-type\.md$//' | tr '\n' ' ')"
VALID_TYPES="$(printf '%s' "$VALID_TYPES" | tr -s ' ')"
# [2026-09-21 task-v086 S6] 项目 plan-templates 目录内的 *-type.md(去后缀)并入合法类型集合;
# 无项目目录 → 集合与改前逐字节一致(非默认路径零影响)
PDIR_RESOLVED="$(find_project_templates || true)"
if [ -n "$PDIR_RESOLVED" ]; then
    _pextra="$(ls "$PDIR_RESOLVED"/*-type.md 2>/dev/null | sed 's/.*\///;s/-type\.md$//' | tr '\n' ' ')"
    [ -n "$_pextra" ] && VALID_TYPES="$(printf '%s %s' "$VALID_TYPES" "$_pextra" | tr -s ' ')"
fi
# [2026-09-21 task-v086 S6] 默认模板(每次只加载 1 个的选择入口):
# 项目级 plan-templates/default 文件(内容=模板名) > env TASK_TEMPLATE_DEFAULT > 缺省=现状 general 行为逐字节不变
if [ -z "$TEMPLATE_TYPE" ]; then
    _default_src=""
    _default_type=""
    if [ -n "$PDIR_RESOLVED" ] && [ -f "$PDIR_RESOLVED/default" ]; then
        _default_type="$(head -n1 "$PDIR_RESOLVED/default" 2>/dev/null | tr -d '[:space:]')"
        [ -n "$_default_type" ] && _default_src="project default 文件(.claude/plan-templates/default)"
    fi
    if [ -z "$_default_type" ] && [ -n "${TASK_TEMPLATE_DEFAULT:-}" ]; then
        _default_type="$TASK_TEMPLATE_DEFAULT"
        _default_src="env TASK_TEMPLATE_DEFAULT"
    fi
    if [ -n "$_default_type" ]; then
        TEMPLATE_TYPE="$_default_type"
        echo "Template routing: 未显式给 template_type, 采用默认模板 $TEMPLATE_TYPE (${_default_src}, task-v086 S6)"
    fi
fi
TASK_PLAN_SRC="task_plan.md"
if [ -n "$TEMPLATE_TYPE" ]; then
    if echo " $VALID_TYPES " | grep -q " $TEMPLATE_TYPE "; then
        VARIANT_REL="variant/${TEMPLATE_TYPE}-type.md"
        VARIANT_ABS_BUILTIN="${BUILTIN_TEMPLATES}/${VARIANT_REL}"
        if [ -f "$VARIANT_ABS_BUILTIN" ]; then
            TASK_PLAN_SRC="$VARIANT_REL"
            echo "Template routing: task_plan.md <- $VARIANT_REL (template_type: $TEMPLATE_TYPE)"
        else
            # [2026-09-21 task-v086 S6] 内置未命中 → 查项目 plan-templates 目录(项目模板发现:
            # 项目 *-type.md 已并入 VALID_TYPES 前置段); 命中 → 复制源=项目文件
            if [ -n "$PDIR_RESOLVED" ] && [ -f "$PDIR_RESOLVED/${TEMPLATE_TYPE}-type.md" ]; then
                TASK_PLAN_SRC="$PDIR_RESOLVED/${TEMPLATE_TYPE}-type.md"
                echo "Template routing: task_plan.md <- ${TEMPLATE_TYPE}-type.md (project-level, task-v086 S6)"
            else
                echo "WARNING: variant template not found: $VARIANT_REL — falling back to generic task_plan.md"
            fi
        fi
    else
        echo "WARNING: unknown template_type '$TEMPLATE_TYPE' — valid: $VALID_TYPES"
        echo "Falling back to generic task_plan.md"
    fi
fi

# [2026-09-20 task-v086 P2-S2 Rule 38.2] tier 分流: mini 档 → mini-lite 模板
# 正交语义: 已命中 variant template_type(定制中档)时 tier=mini 不生效, 仅提示
if [ "$PLAN_TIER" = "mini" ]; then
    if [ -n "$TEMPLATE_TYPE" ] && [ "$TASK_PLAN_SRC" != "task_plan.md" ]; then
        echo "[init] tier=mini 忽略：template_type=$TEMPLATE_TYPE 定制优先（variant 即中档定制，mini 不适用，Rule 38.2）"
    else
        TASK_PLAN_SRC="variant/mini-lite-type.md"
        echo "Template routing: task_plan.md <- variant/mini-lite-type.md (plan_tier: mini, Rule 38.2)"
    fi
fi

# Check for project-level templates
if project_templates=$(find_project_templates); then
    echo "Using project templates: $project_templates"
else
    echo "No project-level templates found, using built-in defaults"
    echo "  (Add .claude/plan-templates/ to your project for custom templates)"
fi
echo ""

# Initialize each template file (only if it doesn't exist)
# [task-perf-opt Change #7] trivial 代码修复档（TRIVIAL_CODE_TIER=1，条件与 Change #1 第四分支统一）
# 缩减为 3 文件（task_plan.md + progress.md + verification.md），跳过 findings/notepad-learnings/knowledge-brief
# （trivial 单文件 ≤3 行修复无调研/知识沉淀需求）；verification.md 仍创建（LANE-L0 GATE ① 全量终验锚依赖）。
# 非 trivial 档（含既有 mini 档）保持 5 文件全量，行为逐字节不变。
if [ "${TRIVIAL_CODE_TIER:-0}" = "1" ]; then
    _init_files="progress.md verification.md"
else
    _init_files="findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md"
fi
for file in $_init_files; do
    if [ -f "$file" ]; then
        echo "$file already exists, skipping"
    else
        if copy_template "$file"; then
            echo "    Created $file"
        fi
    fi
done

# task_plan.md handled separately (may come from variant/)
if [ -f "task_plan.md" ]; then
    echo "task_plan.md already exists, skipping"
else
    if [ "$TASK_PLAN_SRC" != "task_plan.md" ]; then
        # variant source: copy directly to task_plan.md (project-level override first)
        # [2026-09-21 task-v086 S6] TASK_PLAN_SRC 为绝对路径=项目 plan-templates 自造模板
        # (项目发现段命中, 内置未命中回落项目文件); 直接 cp 并置 PROJECT_TPL_USED=1
        case "$TASK_PLAN_SRC" in
            /*)
                cp "$TASK_PLAN_SRC" "task_plan.md"
                PROJECT_TPL_USED=1
                ;;
            *)
                if project_templates=$(find_project_templates) && [ -f "$project_templates/$TASK_PLAN_SRC" ]; then
                    cp "$project_templates/$TASK_PLAN_SRC" "task_plan.md"
                else
                    cp "${BUILTIN_TEMPLATES}/${TASK_PLAN_SRC}" "task_plan.md"
                fi
                ;;
        esac
        # [2026-09-21 task-v086 S6] 自造模板 frontmatter 兜底: 复制产物无 template_type 标识行
        # (首行注释或表格行均无) 时头部插入一行, 保证 check-template-type 机器门控可识别
        if [ "$PROJECT_TPL_USED" = 1 ] && [ -n "$TEMPLATE_TYPE" ]; then
            if ! head -1 "task_plan.md" | grep -q "template_type" \
               && ! grep -qE '^[[:space:]]*\|[[:space:]]*template_type[[:space:]]*\|' "task_plan.md"; then
                awk -v tt="$TEMPLATE_TYPE" 'NR==1{print "<!-- template_type: " tt " -->"} {print}' "task_plan.md" > "task_plan.md.tmp" \
                    && mv "task_plan.md.tmp" "task_plan.md"
                echo "    [init] 项目模板缺 template_type 标识, 已插入 frontmatter 行 (template_type: $TEMPLATE_TYPE, task-v086 S6)"
            fi
        fi
        # [2026-09-27 task-v091 S22 A-1] auto_tier 标记：自动降档命中的 mini 产物在 plan_tier: mini
        # 行后插一行 auto_tier: mini（终验 AUTO-TIER 复核段消费锚，提案终审 #7 闭环：把误判从
        # 「单程 warn 提示」升级为「终验可观察复核点」）。显式声明 mini 不打标（auto_tier 只记
        # 自动判定，显式优先=不覆盖显式值）；variant 定制优先场景产物无 plan_tier: mini 行 →
        # 不打标（38.2 正交语义同 :164 分流）。
        if [ "$AUTO_TIER_FIRED" = 1 ] && grep -q 'plan_tier: mini' "task_plan.md" 2>/dev/null; then
            awk '!_s22done && /plan_tier: mini/ { print; print "<!-- auto_tier: mini -->"; _s22done=1; next } { print }' \
                "task_plan.md" > "task_plan.md.tmp" && mv "task_plan.md.tmp" "task_plan.md"
            echo "    [init] auto-tier 命中: frontmatter 已记 auto_tier: mini 标记 (Rule 38.6, task-v091 S22)"
        fi
        if [ -n "$TEMPLATE_TYPE" ]; then
            echo "    Created task_plan.md (variant: $TEMPLATE_TYPE)"
        elif [ -n "$PLAN_TIER" ]; then
            echo "    Created task_plan.md (plan_tier: $PLAN_TIER)"
        else
            echo "    Created task_plan.md"
        fi
    elif copy_template "task_plan.md"; then
        echo "    Created task_plan.md"
    fi
fi

# [2026-10-11 task-v169 Rule 80.1] user-session-log.md（第 7 计划文件）独立建档：
# What: 六文件创建完成、task_plan.md 单独处理块结束之后，独立创建 user-session-log.md
#       （用户会话逐字记录专档）；故意**不并入上方六文件 for 循环**——六件套语义、
#       「六件套全量 verified」字面回显与六文件复核循环一字不动（selftest T3b/T10b 断言依赖）。
# Why: task_plan.md 受 attest 哈希锁禁追加，用户需求逐字记录须外置专档（需求锚 R1 全部
#       记录、R3 防会话异常丢失）；专档内容 append-only 只写不改（R5），复制模板即冻结
#       初始载体，后续只追加条目。
# 幂等: 文件已存在（重复 init）→ 打 already exists, skipping 后跳过，不覆写既有条目。
# [task-perf-opt Change #7] trivial 代码修复档（TRIVIAL_CODE_TIER=1）：user-session-log.md 改按需创建
# （mini 档 Rule 80 豁免口径，首次写入才建档），init 不预建；非 trivial 档保持强制建档原行为不变。
if [ "${TRIVIAL_CODE_TIER:-0}" != "1" ]; then
    if [ -f "user-session-log.md" ]; then
        echo "user-session-log.md already exists, skipping"
    else
        if copy_template "user-session-log.md"; then
            echo "    Created user-session-log.md (task-v169 Rule 80.1 第 7 计划文件, append-only 逐字记录专档)"
        fi
    fi
fi

# [2026-10-15 task-v176 D4] user-session-log append-only 完整性基线 .session-log-baseline（Rule 80.2 机器承载）
# What: user-session-log.md 存在且基线未建时，写 `.session-log-baseline` =
#       「<首条目行 sha256> <条目数>」单行（首条目=首个 `## #[0-9]` 行；无条目时记 `- 0`——
#       模板占位行 `## #N` 因 N 非数字不计入条目，沿用 SESSION-LOG GATE 既有口径）。
# Why: 专档「append-only 只写不改」（Rule 80.2）此前无完整性载体——历史改写/删条机器不可检测，
#      而 task_plan.md 有 SHA-256 锁=记录强度倒挂（S1-7：用户原话权威源反成最弱载体）。
#      check-complete.sh SESSION-LOG GATE enforce 档据此校验「现存条目数 ≥ 基线条目数 ∧ 现存首条目
#      sha == 基线 sha」（禁删条/禁改首条；append 新条目合法——条目数只增不减、首条冻结不变）。
# 幂等: 基线已存在（重复 init）→ 不重建（重生成会重置完整性锚=让篡改后重跑 init 洗白，须保冻结语义）。
# 档位: 非 trivial 档强制建档路径生成；trivial 档 user-session-log 按需创建（Change #7），
#       文件缺席时本块自然跳过——首次建档由后续 append 触发场景兜底（基线缺失时 GATE fail-open）。
if [ -f "user-session-log.md" ] && [ ! -f ".session-log-baseline" ]; then
    _sl_first_line="$(grep -m1 -E '^## #[0-9]' "user-session-log.md" 2>/dev/null || true)"
    if [ -n "$_sl_first_line" ]; then
        _sl_first_rec="$(printf '%s\n' "$_sl_first_line" | sha256sum | awk '{print $1}')"
    else
        _sl_first_rec="-"
    fi
    _sl_entry_n="$(grep -cE '^## #[0-9]' "user-session-log.md" 2>/dev/null || true)"
    case "${_sl_entry_n:-}" in ''|*[!0-9]*) _sl_entry_n=0 ;; esac
    printf '%s %s\n' "$_sl_first_rec" "$_sl_entry_n" > ".session-log-baseline"
    echo "    [init] .session-log-baseline created (task-v176 D4: first-entry-sha=${_sl_first_rec:0:12}… entries=${_sl_entry_n}, append-only 完整性基线)"
fi

# [2026-10-11 task-v167 Rule 38.7] 执行通道（lane）定级接线：计划文件创建后调 lane-detect.sh 对
# 当前 git 状态判定（BASE=env TASK_LANE_BASE, 默认 HEAD；非 git 仓/判不定 → lane-detect 兜底 L1,
# fail-safe 向重侧）。lane=执行通道, 与 plan_tier=模板轻重正交（两者并存写入计划头）。
# 写入行 execution_lane: L0|L1|L2 供 check-complete.sh L0 门组消费（缺 L1 行=零行为变化）。
if [ -f "task_plan.md" ] && [ -f "${SCRIPT_DIR}/lane-detect.sh" ]; then
    # 2>/dev/null + || true: 判不定 rc=2（非 git 仓/BASE 无效）不得经 set -e 传播中断 init 主流程
    #（lane-detect 已兜底 stdout 输出 L1, 此处取不到合法值时同样兜底 L1——fail-safe 向重侧）
    # [M1/M5-fix 2026-10-14] TRIVIAL_CODE_TIER=1 时传 --trivial，使 lane-detect 统一判定面内
    # 可审计「代码文件改动可进 L0」的 trivial 例外（取代原 L640 覆写：lane-detect L1 → init-session 强制 L0
    # 的分离判定逻辑，使 Rule 38.7 禁令与 trivial 例外在同一判定点内显式调和）。
    if [ "${TRIVIAL_CODE_TIER:-0}" = "1" ]; then
        _lane="$(bash "${SCRIPT_DIR}/lane-detect.sh" --diff "${TASK_LANE_BASE:-HEAD}" --trivial 2>/dev/null)" || true
    else
        _lane="$(bash "${SCRIPT_DIR}/lane-detect.sh" --diff "${TASK_LANE_BASE:-HEAD}" 2>/dev/null)" || true
    fi
    _lane="${_lane#execution_lane: }"; case "${_lane}" in L0|L1|L2) ;; *) _lane=L1 ;; esac
    # 2i 而非 1i: 保持文件首行语义不变（自造模板 frontmatter 插入落在首行, 既有 selftest
    # plan-tier PT-24/27 断言 head -1；lane 行居第 2 行不位移任何既有首行锚）
    grep -qE '^[[:space:]]*execution_lane:' "task_plan.md" 2>/dev/null || sed -i "2i execution_lane: ${_lane}" "task_plan.md"
    # Why if 块式: set -e 下「[ ... ] && echo」尾链在 L1 时返回 1 会中断脚本（实测 selftest 回归）
    if [ "$_lane" = "L0" ]; then
        echo "    [lane] L0 微变更通道已激活（相关 selftest 子集+交付前 fresh 全量终验）"
    fi
fi

# [2026-09-29 task-v096 P2-S1 T1 分支①] template-sense 区块（Rule 34.3② 预登记触发点）：
# 仅当 TEMPLATE_TYPE 最终决议为 general（类型空缺落 general 兜底）时 emit 提示行并向 task_plan.md
# 末尾追加「🔁 模板感知」区块。已知 16 类（bugfix 等）零调用，known-type 路径逐字节不变。
# 区块内同时声明 template_type: general + 34.3② 预登记 → check-template-type 三形态命中
# （模板本体 task_plan.md 无 template_type 标记，运行时追加而非改本体，§4 条 1 约束）。
# 正交性（§4 条 10）：本调用点在 tier 分流/复制之后，mini 档只改 tier 不碰 sense；
# unknown 类型分支（L183-186 区段）本 S-unit 不动（P2-S2）。
# 幂等保护：同任务目录重复运行 init（task_plan.md 已存在=skip 分支）不重复追加。
# [task-v096 CR-fix] 仅非 general 的 known-type 标记产物才抑制（防 mini/known-type 产物被二次标记）:
# 新鲜 general 兜底副本（templates/task_plan.md）→ 触发；
# bugfix 等 known-type / mini-lite 产物带 template_type: <非 general 类型> 标记 → 不触发。
# [H3-fix 2026-10-14] 无标记守卫精确化：built-in task_plan.md 的 frontmatter 头本次已自带
# 行首 `template_type: general`（task_plan 模板 frontmatter 化引入，见 git diff L6），
# 原守卫 `! grep -q 'template_type:'` 恒命中 general 兜底产物 → [template-sense] 永不触发
# （selftest-template-sense case-1/case-2 FAIL 根因：general 空缺/unknown 均无法触发感知）。
# 根因=general 是兜底语义而非 known-variant，原守卫把 general 也算作"已标记"收窄过严；
# 修法=仅当产物带"非 general 的行首 template_type 值"（真正的 known-variant 标记）时才抑制，
# general 兜底产物与无标记产物一律照常触发。守卫覆盖三形态（行首 / HTML 注释 `<!-- template_type: X -->` /
# 表格行），与 check-template-type 三形态对齐；frontmatter 注释文档行（"行首 `^template_type:`（本块）"）
# 不匹配行首正则故不干扰。幂等保护（下方 模板感知 grep）不变。
_tt_val="$(grep -m1 -E '^[[:space:]]*(<!--[[:space:]]*)?template_type:[[:space:]]*[^[:space:]|)]+' "task_plan.md" 2>/dev/null | sed -E 's/^[[:space:]]*(<!--[[:space:]]*)?template_type:[[:space:]]*//' || true)"
_has_known_tt=0
[ -n "${_tt_val:-}" ] && [ "${_tt_val}" != "general" ] && _has_known_tt=1
if [ -z "$TEMPLATE_TYPE" ] && [ -f "task_plan.md" ] \
   && [ "${_has_known_tt}" -eq 0 ]; then
    echo "[template-sense] ⚠ 任务类型空缺（general 兜底）——按 Rule 34.3②/34.7 评估沉淀，终验必查"
    if ! grep -q '🔁 模板感知' "task_plan.md" 2>/dev/null; then
        cat >> "task_plan.md" <<'EOF'

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
EOF
        echo "    [template-sense] task_plan.md 末尾已追加「🔁 模板感知」区块"
    fi
fi

# [2026-09-29 task-v096 P2-S2 T1 分支②] unknown 类型感知块（Rule 34.3② 预登记触发点）：
# 显式给了未知类型（不在白名单, L183-186 WARNING 分支，WARNING 行为原样保留）→ 落 general 兜底：
# 与 P2-S1 同款 emit 提示行（措辞区分）+ 追加同款「🔁 模板感知」区块（机读注释行同为
# <!-- template_type: general -->, 因 unknown 最终落 general 产物; 区块正文与注释行区分 unknown 语义）。
# 判定条件与 L180/L183 白名单判定同构: TEMPLATE_TYPE 非空 ∧ 不在 VALID_TYPES ∧ 最终 TASK_PLAN_SRC
# 仍为 generic task_plan.md（unknown+tier=mini 时 mini 分流胜出=产物非 general, 不触发;
# 白名单内类型文件缺失（L181-182 WARNING）不触发——不在白名单才是 unknown）。
# 与 P2-S1 块互斥（一为 -z、一为 -n）; TASK_TEMPLATE_DEFAULT 显式=general（TEMPLATE_TYPE=general
# 在白名单内）不触发——字面语义=用户显式选了 general 不算空缺/未知（P2-S1 裁量项维持, findings 登记）。
# 幂等去重与 P2-S1 同款 grep。
# [task-v096 CR-fix] 仅无 template_type 标记的产物才追加（防 mini/known-type 产物被二次标记）:
# unknown 路径重跑时产物可能是已带标记的 mini/known-type 产物 → 不触发（与 P2-S1 同根，
# 既有 TASK_PLAN_SRC 来源守卫保留, 与无标记守卫双条件同时成立才追加）。
if [ -n "$TEMPLATE_TYPE" ] && ! echo " $VALID_TYPES " | grep -q " $TEMPLATE_TYPE " \
   && [ "$TASK_PLAN_SRC" = "task_plan.md" ] && [ -f "task_plan.md" ] \
   && [ "${_has_known_tt:-0}" -eq 0 ]; then
    echo "[template-sense] ⚠ 任务类型未知（$TEMPLATE_TYPE 不在白名单）——将落 general 兜底，按 Rule 34.3②/34.7 评估沉淀，终验必查"
    if ! grep -q '🔁 模板感知' "task_plan.md" 2>/dev/null; then
        cat >> "task_plan.md" <<EOF

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S2: 运行时追加区块（非模板本体）; unknown=显式类型 $TEMPLATE_TYPE 不在白名单, 落 general 兜底; 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 显式类型 $TEMPLATE_TYPE 不在白名单 → WARNING 后落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
EOF
        echo "    [template-sense] task_plan.md 末尾已追加「🔁 模板感知」区块"
    fi
fi

# [2026-10-05 task-v131 Phase 2] Rule 51.1 生成面注入调用点（审计 H-3 清账）：
# 调用点选择理由：须在整个模板复制/tier 分流/template-sense 追加完成之后执行——
# 此时 TASK_PLAN_SRC/plan_tier 标记/frontmatter 插入均定型，mini 判定 ①② 数据齐备；
# 且须放在下方 6 文件存在性复核（L"missing_files"循环）之前，保证注入产物参与复核。
# 幂等：已含锚/mini 档均 return 0（函数头注释）；重复 init（task_plan.md 已存在
# 走 skip 分支）再入亦被锚判定短路。fail-open：任何失败仅 WARN，不阻断 init。
inject_requirement_block
# [2026-10-07 task-v143 CR-fix F-1] Rule 58 载体注入调用点（与上方 51.1 调用点同位理由：
# 模板复制/tier 分流定型后、6 文件复核前；幂等+mini 豁免+fail-open 同范式）
inject_evidence_goal_block

echo ""
# [2026-09-04 Rule 19.5 配套] 文件存在性复核：缺失或空 → exit 1
# [2026-09-13 task-v067] 5 文件→6 文件（+knowledge-brief.md）
# [task-perf-opt Change #7] trivial 代码修复档（TRIVIAL_CODE_TIER=1）按需创建 3 文件 + user-session-log 改按需
# （首次写入才建档，mini 档 Rule 80 豁免口径），复核面=实际创建的文件集；非 trivial 档复核面保持 6+1 不变。
if [ "${TRIVIAL_CODE_TIER:-0}" = "1" ]; then
    _req_files="task_plan.md progress.md verification.md"
else
    _req_files="task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md"
fi
missing_files=()
for f in $_req_files; do
    if [ ! -s "$f" ]; then
        missing_files+=("$f")
    fi
done
if [ ${#missing_files[@]} -gt 0 ]; then
    for f in "${missing_files[@]}"; do
        echo "[init] ERROR: $f missing or empty — planning files incomplete"
    done
    exit 1
fi
# [task-perf-opt Change #7] 非 trivial 档保持「六文件全量 verified」字面回显（selftest-knowledge-brief T3b + session-log SL-07 断言锚依赖）；
# trivial 档按实际创建文件数回显（3/3，诚实不粉饰）。
if [ "${TRIVIAL_CODE_TIER:-0}" = "1" ]; then
    echo "[init] 3/3 planning files verified (trivial 代码修复档, Change #7: 缩减 3 文件)"
else
    echo "[init] 6/6 planning files verified"
fi
# [2026-10-11 task-v169 Rule 80.1] 第 7 文件 user-session-log.md 独立存在性复核：
# 六文件复核循环与「六件套全量 verified」回显行保持原样，第 7 文件单独成段——缺失或空 → ERROR + exit 1
# （错误必须曝光，禁静默放行；既有条目 append-only，本处只做存在/非空校验不改内容）
# [task-perf-opt Change #7] trivial 代码修复档：user-session-log.md 改按需创建（mini 档 Rule 80 豁免口径），
# init 不强制建档——首次由主进程/追加动作创建；非 trivial 档保持强制建档复核不变。
if [ "${TRIVIAL_CODE_TIER:-0}" != "1" ]; then
    if [ ! -s "user-session-log.md" ]; then
        echo "[init] ERROR: user-session-log.md missing or empty — 第 7 计划文件未建档（task-v169 Rule 80.1）" >&2
        exit 1
    fi
    echo "[init] user-session-log.md verified (7th planning file, task-v169 Rule 80.1)"
else
    echo "[init] user-session-log.md on-demand (trivial 代码修复档, Change #7; mini 档 Rule 80 豁免, 首次写入时建档)"
fi
# [2026-10-05 task-v132 G3 R3] silent 路径锚哈希即时落盘（G3：防窗口期篡改）：
# 原因: silent/自动档交互模式（Rule 28 唯一权威解析口径, 层级见下方 ALIGN-P1b 注）下
#       计划生成后即直接执行、无用户批准环节——原行为哈希锁定（attest-plan.sh）延后到执行中
#       甚至遗漏，审批→锁定之间存在窗口期，期间 task_plan.md 可被篡改而无 attestation 门禁；
#       非 silent（ask）路径保持原行为（锁定发生在用户批准计划时，见 SKILL.md Rule 28），零改动。
# 时间: 2026-10-05 (task-v132 Phase 3 R3; Phase 4 ALIGN-P1b 解析口径修正)
# 原行为: init 生成 6 文件后仅写活跃计划指针，不做任何哈希锁定；silent 档的 .plan-attestation
#         依赖后续人工/执行中补跑 attest-plan.sh，锁定前窗口期内篡改无机器门禁。
# [2026-10-05 task-v132/Phase4 ALIGN-P1b] silent 判定接权威解析器（06-code-reviewer P1-ALIGN-2:
# 原实现仅 ① env 直判, 经 ②/③ 判定 silent 的计划不会即时落锁=窗口期保护缺口; :530 注释自称
# 「Rule 28 解析口径」与实现不符）。判定层级（对齐 Rule 28 解析优先级 env>plan>config）:
#   第一优先 = env TASK_PLANNER_INTERACTION_MODE=silent 直判（保留 Phase 3 原判定, 零额外调用）;
#   第二/三优先 = 权威解析器 resolve-interaction-mode.sh（② 计划配置表行 → ②b mini 档缺省
#     → ③ config.json → ④ 兜底 ask）: 非交互环境 env 缺失时经 ②/②b/③ 判定 silent 的计划
#     此前永不落锁, 现在也走两级落锁。
#   覆盖性论证: 解析器第一层即 env（合法值原样输出）——env 直判命中时解析器恒同结果,
#   故「env 直判 + 解析器补充」= 解析器的超集; 非交互环境 env 缺失解析器兜底 ask 的担忧
#   不成立——env 通道恒可达（调用方显式设 env 即命中第一优先）, silent 落锁不会永不触发。
#   解析器缺失/异常 → 其自身 fail-safe 降级 ask（exit 恒 0 + 兜底 ask）= 保持 Phase 3 原行为,
#   ask 路径零改动。
# fail-open: attest 失败（磁盘/权限/脚本异常）仅 WARN 不阻断 init（与 inject_requirement_block
# 同范式：增强而非前置依赖，规划者可事后手补 attest）。两级锁定策略（2026-10-05 实测 /tmp/v132-g3
# 发现：标准档新计划无 S-unit 表→dispatch 门 exit 1 拒锁，直接 attest 成功率为 0，G3 落盘目标落空）：
#   ① 主锁 attest-plan.sh（全门控）——已填 S-unit 表的计划一次成功；
#   ② 兜底加 --skip-dispatch-check --skip-fmea-check 再试——新计划无 S-unit 表/无 FMEA 段属
#      规划期常态（非篡改信号），此时先锁哈希堵住窗口期；--skip 仅限 dispatch/fmea 两可跳过
#      门（脚本既有先例，WARN 可留痕），Rule 51.1 需求原文四锚门仍 fail-closed 在位不绕——
#      缺锚的 silent 计划照样拒锁+WARN，门禁语义不倒退；两锁均失败 → WARN 落 stderr，init 照过。
# 幂等: 重复 init（task_plan.md 已存在走 skip 分支）再次触发 attest=重锁既有哈希，无副作用。
# 留痕: 落锁输出带 silent 判定来源（env=第一优先直判 / resolver=二三优先解析器口径）。
silent_lock=0
silent_src=""
if [ "${TASK_PLANNER_INTERACTION_MODE:-}" = "silent" ]; then
    silent_lock=1
    silent_src="env"
elif [ -f "task_plan.md" ]; then
    # 二三优先（ALIGN-P1b）: 权威解析器 ②计划配置表行 → ②b mini 缺省 → ③config.json → ④兜底 ask。
    # 传参=当前计划目录（解析器 usage: <plan_dir> → 取 <dir>/task_plan.md 配置表行）;
    # 取 stdout 首行（解析器契约: stdout 单行 ask|silent, exit 恒 0）; 脚本缺失/无输出 → 保持非 silent。
    _ri="$(bash "$SCRIPT_DIR/resolve-interaction-mode.sh" "$(pwd)" 2>/dev/null | head -n1)"
    case "$_ri" in
        silent)
            silent_lock=1
            silent_src="resolver"
            ;;
        *)
            # ask/无输出/解析器缺失 → fail-safe 保持非 silent 路径（Phase 3 原行为, 零改动）
            :
            ;;
    esac
fi
if [ "$silent_lock" -eq 1 ] && [ -f "task_plan.md" ]; then
    if ! bash "$SCRIPT_DIR/attest-plan.sh" "$(pwd)/task_plan.md" >/dev/null 2>&1; then
        # 兜底级（见 fail-open 注两级策略）：dispatch/fmea 可跳过门逃生再试，51.1 硬门仍生效
        if bash "$SCRIPT_DIR/attest-plan.sh" --skip-dispatch-check --skip-fmea-check "$(pwd)/task_plan.md" >/dev/null 2>&1; then
            echo "[init] INFO: silent 路径兜底锁已落盘 .plan-attestation（G3：防窗口期篡改；判定来源=${silent_src}; dispatch/fmea 门逃生锁，S-unit 表/FMEA 段补齐后应重跑全门控 attest 复锁）"
        else
            echo "[init] WARN: silent 路径 attest-plan.sh 锁定失败（判定来源=${silent_src}; 主锁/兜底锁均拒锁——51.1 需求区块缺失或磁盘/脚本异常）— 不阻断 init（fail-open: 规划者须事后补跑 attest-plan.sh 锁定）" >&2
        fi
    else
        echo "[init] INFO: silent 路径已即时落盘 .plan-attestation（G3：防窗口期篡改；判定来源=${silent_src}）"
    fi
fi
# [2026-09-05 task-active-plan] 自动写活跃计划指针(最新创建的计划=默认活跃);
# 失败仅警告不阻断(指针缺失时 resolve-plan-dir.sh 回退 mtime 最新)
# 2026-09-10 active-plan-race: 原行为=无条件覆写全局 plans/.active_plan(后写者赢,多并行会话互顶,
#   09-09 实锤 7 次 check-dispatch 误拦)。改为:env CLAUDE_CODE_SESSION_ID 有值(ZCode 会话)→
#   原子写会话私有 side 指针 .active_plan_side/<sidkey>.active_plan,不碰全局 fallback 指针;
#   无值(cron/纯脚本单会话场景)→保持原行为写全局 fallback 指针(7am cron 兼容)。
# [2026-10-10 task-v164] 上两行原措辞以「legacy」描述全局 plans/.active_plan 层,改述为「全局 fallback 指针」:
#   实为工作树内瞬态兜底(路径随 $PWD 本地化;git rm --cached + .gitignore,与 .active_plan_side/ 同族瞬态运行态);
#   正常路径 = side 会话私有指针(权威层);退役「legacy/移交」旧叙事。
# [2026-09-16 task-v074 P10] PLAN_ROOT 解析修正：原 `cd .. && pwd` 假设 CWD=plans/<task-id>/
# （即 <root>/plans/<task-id>），哨兵/指针写到 <root>/.active_plan_side；但 canonical 侧
# 目录（task-plan-init.cjs :76 / resolve-plan-dir.sh :33 / set-active-plan.sh / check-scope.sh
# 及主仓真实布局）均在 <root>/plans/ 下。原错位下新写的指针 resolve 侧查不到 →
# P1-2 指针/哨兵错位根因之一。修正：CWD=plans/ → root=CWD；CWD=plans/<task-id>/（既有标准
# 运行方式）→ root=..（行为不变）；其他（非标准目录）→ 维持旧 cd ..（降级，无破坏）。
# 副作用登记：CWD=plans/<task-id> 运行时全局 fallback 指针与 side 指针落点从 <root>/.active_plan
# 迁移到 <root>/plans/.active_plan{,_side}，与 set-active-plan/resolve/attest 的现有口径对齐。
# [2026-10-10 task-v164] 上一行原措辞以「legacy」框定该全局层,改述为「全局 fallback 指针」(语义见 :720 注记)。
if [ "$(basename "$(pwd)")" = "plans" ]; then
    PLAN_ROOT="$(pwd)"
elif [ "$(basename "$(dirname "$(pwd)")")" = "plans" ]; then
    PLAN_ROOT="$(cd .. && pwd)"
else
    PLAN_ROOT="$(cd .. && pwd)"  # 非标准目录：维持旧行为（CWD 守卫已限制风险面）
fi
SIDSRC="${CLAUDE_CODE_SESSION_ID:-}"
if [ -n "$SIDSRC" ]; then
    # [2026-10-07 fix-pointer-race RC-1] canon 对齐:剥 sess 前缀(与 task-plan-init.cjs normSidkey /
    # resolve-plan-dir.sh / set-active-plan.sh / check-scope.sh 一致)。原只剥非字母数字,ZCode env sid
    # 带 sess 前缀时指针/哨兵落 sess* 双命名空间,resolve 侧查不到 → mtime 兜底被并行会话劫持。
    SIDKEY="$(printf '%s' "$SIDSRC" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    case "$SIDKEY" in
        sess*) SIDKEY="${SIDKEY#sess}" ;;
    esac
    # [2026-09-16 task-v074 P10 sid 哨兵探测 fallback] env CLAUDE_CODE_SESSION_ID 与
    # hook stdin .session_id 是两个命名空间(SessionStart 哨兵用 hook sid 写,init 用 env sid
    # 清/登记 → 指针/哨兵错位,见 findings P1-2)。
    # [2026-10-07 fix-pointer-race RC-2] 兜底两级化:① .sidmap 确定性映射(SessionStart 写
    # <env_sidkey>.sidmap=hook sidkey)优先——消除"最新哨兵=本会话"猜测;② 无映射才探测最新哨兵,
    # 且仅当其 mtime ≤120s(会话刚启动场景)才抢用;陈旧哨兵=并行会话的,抢用=把指针写进他会话
    # 命名空间(2026-10-07 事故根因,实时复现 4272173a 污染)。超窗拒抢+WARN。
    # [2026-10-07 fix-pointer-race CR-fix] sidmap 升级为权威身份事实:
    # ① 命中不再要求目标哨兵存在——目标哨兵已被正常清除属常态(同会话第二次建计划时
    #    plan-created 已删哨兵,身份映射仍有效); ② 仅当本 env sidkey 不存在 sidmap 文件时才允许
    #    新鲜窗探测(有 sidmap=身份已确定,绝不抢他会话); sidmap 内容损坏(_mapped 为空)同样跳过
    #    ②(fail-conservative: 指针按 env sid 落盘,不抢)。修后语义: ① sidmap 在→用映射键;
    #    ② 无 sidmap→新鲜窗探测; ③ 其余→env key 原样。
    _sidmap_checked=0
    if [ -n "$SIDKEY" ] && [ ! -f "${PLAN_ROOT}/.plan_required_side/${SIDKEY}.plan_required" ]; then
        _sent_dir="${PLAN_ROOT}/.plan_required_side"
        _map="${_sent_dir}/${SIDKEY}.sidmap"
        if [ -f "$_map" ]; then
            _sidmap_checked=1   # 读到 sidmap 文件存在即置位: 身份已确定, ② 不再探测(无论映射是否有效)
            _mapped="$(head -n 1 "$_map" | tr -cd 'a-zA-Z0-9' | head -c 40)"
            if [ -n "$_mapped" ] && [ "$_mapped" != "$SIDKEY" ]; then
                echo "[init] INFO: env sid(${SIDKEY}) 经 sidmap 映射到会话哨兵 sid(${_mapped})(目标哨兵缺失属已清除常态)"
                SIDKEY="$_mapped"
            fi
        fi
    fi
    if [ "$_sidmap_checked" -eq 0 ] && [ -n "$SIDKEY" ] && [ ! -f "${PLAN_ROOT}/.plan_required_side/${SIDKEY}.plan_required" ]; then
        _sent_dir="${PLAN_ROOT}/.plan_required_side"
        if [ -d "$_sent_dir" ]; then
            _latest_sent=""
            _latest_mt=0
            for _sf in "$_sent_dir"/*.plan_required; do
                [ -e "$_sf" ] || continue
                _mt=$(stat -c %Y "$_sf" 2>/dev/null || echo 0)
                if [ "$_mt" -gt "$_latest_mt" ]; then _latest_mt=$_mt; _latest_sent="$_sf"; fi
            done
            if [ -n "$_latest_sent" ]; then
                _sent_sid="$(basename "$_latest_sent" .plan_required)"
                _sent_sid="$(printf '%s' "$_sent_sid" | tr -cd 'a-zA-Z0-9' | head -c 40)"
                case "$_sent_sid" in sess*) _sent_sid="${_sent_sid#sess}" ;; esac
                _now="$(date +%s)"
                _sent_age=$(( _now - _latest_mt ))
                if [ -n "$_sent_sid" ] && [ "$_sent_sid" != "$SIDKEY" ] && [ "$_sent_age" -le 120 ]; then
                    echo "[init] INFO: env sid(${SIDKEY}) 无对应哨兵,fallback 最新哨兵 sid(${_sent_sid}, age=${_sent_age}s≤120s)"
                    SIDKEY="$_sent_sid"
                elif [ -n "$_sent_sid" ] && [ "$_sent_sid" != "$SIDKEY" ]; then
                    echo "[init] WARN: env sid(${SIDKEY}) 无对应哨兵,最新哨兵(${_sent_sid}) age=${_sent_age}s>120s 疑似他会话 → 不抢用;指针按本 env sid 落盘,如错位请跑 set-active-plan.sh set <task> --sid" >&2
                fi
            fi
        fi
    fi
    # [2026-10-10 task-v159] F3 init 侧: side 写入所有权守卫(与 set-active-plan.sh set 分支同语义)
    # Why: 写 ${SIDKEY}.active_plan 前须确认该 sid 键未被"在途"的他计划沿袭占用——
    #   D3 缺陷=v156/v157 owner=sesscbab959f 共享 SessionStart key,init 误写他会话指针空间。
    #   扫 plans/*/.session-owner: claimant=声明 sess<${SIDKEY}> 的计划目录;
    #   ①claimant≠本计划(当前 PWD)且其 task_plan.md Status=in_progress→skip 本键写入防互踩;
    #   ②claimant 不存在或已 complete→fail-open 正常写(只 INFO/WARN, 不拦)。
    #   sidmap 映射逻辑(:759-794)保留不动——映射值撞车由本守卫兜底。
    # 基线行为: init 直接写 side 键, 无所有权检查。
    SKIP_SIDE_WRITE=0
    _claimant=""
    for _ownfile in "${PLAN_ROOT}"/*/.session-owner; do
        [ -f "$_ownfile" ] || continue
        # [2026-10-10 CR修复 MAJOR-F3] owner 匹配兼容双形态 ^(sess)?${SIDKEY}$
        # Why: 同 set-active-plan.sh set 分支 F3 修复——裸 uuid owner 会话(无 sess 前缀)被漏判,
        #   守卫失效直接写入(trample)。修法=兼容双形态, 整行锚定($)实现 norm 后比较。
        if grep -qE "^(sess)?${SIDKEY}$" "$_ownfile" 2>/dev/null; then
            _claimant="$(basename "$(dirname "$_ownfile")")"
            break
        fi
    done
    if [ -n "$_claimant" ] && [ "$_claimant" != "$(basename "$PWD")" ]; then
        if [ -f "${PLAN_ROOT}/${_claimant}/task_plan.md" ] \
           && grep -qi 'Status.*in_progress' "${PLAN_ROOT}/${_claimant}/task_plan.md" 2>/dev/null; then
            echo "[init] WARN: side 键 sid=${SIDKEY} 已被在途计划 ${_claimant} 声明，skip 写入防沿袭互踩" >&2
            SKIP_SIDE_WRITE=1
        else
            echo "[init] INFO: side 键 sid=${SIDKEY} 曾被计划 ${_claimant} 声明（已 complete/不存在），fail-open 继续写入"
        fi
    fi
    SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
    if [ -n "$SIDKEY" ] && [ "$SKIP_SIDE_WRITE" = "0" ] && mkdir -p "$SIDE_DIR" 2>/dev/null; then
        side_tmp="$(mktemp "${SIDE_DIR}/.tmp.XXXXXX" 2>/dev/null)" || side_tmp=""
        if [ -n "$side_tmp" ]; then
            printf '%s\n' "$(basename "$PWD")" > "$side_tmp" 2>/dev/null \
                && mv -f "$side_tmp" "${SIDE_DIR}/${SIDKEY}.active_plan" 2>/dev/null \
                && echo "[init] active_plan side 指针已指向: $(basename "$PWD")(sid=${SIDKEY})"
        fi
    fi
else
    if printf '%s\n' "$(basename "$PWD")" > "${PLAN_ROOT}/.active_plan" 2>/dev/null; then
        echo "[init] active_plan 指针已指向: $(basename "$PWD")"
    else
        echo "[init] WARN: 指针写入失败(hook 将回退 mtime 最新解析)"
    fi
fi
echo "Planning files initialized!"
