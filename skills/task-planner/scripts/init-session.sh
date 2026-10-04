#!/bin/bash
# [2026-09-04] 新增 5 文件存在性复核（Rule 19.5 配套），缺失/空文件 exit 1
# [2026-09-13 task-v067] 第 6 文件 knowledge-brief.md 纳入建立/复核（5 文件→6 文件）
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
BUILTIN_TEMPLATES="${SCRIPT_DIR}/../templates"  # ~/.zcode/skills/task-planner/templates/

# Find project-level templates: traverse upward from CWD to find .claude/plan-templates/
find_project_templates() {
    local dir="$(pwd)"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude/plan-templates" ]; then
            echo "$dir/.claude/plan-templates"
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
# Rule 51.1「🎯 用户需求原文」区块的生成面注入兜底（审计 H-3 清账）
#
# What: 对任何刚生成/复制完成的 task_plan.md——若不含锚 `## 🎯 用户需求原文`
#   且非 mini 档 → 在第一个 `## Goal` 标题行之前插入脚手架区块（无 Goal 行则
#   插在文件头部注释块之后）；占位符保留供规划者填写；已含锚（主模板/
#   rule-enhancement 变体自带载体）→ echo 一行 INFO 跳过。
# Why: 29 个 variant 模板零载体（审计 H-3）——前序单元只给了主模板+
#   rule-enhancement 变体载体；生成面注入是最后兜底，保证任何模板生成的新
#   计划必有 Rule 51.1 载体（计划侧零兜底修复）。fail-open 设计：注入失败
#   （awk/写文件/磁盘/权限）仅 stderr 警告后继续 init、函数恒 return 0——
#   注入是增强而非前置依赖：缺区块不应阻断 6 文件校验与活跃指针写入，
#   规划者仍可手补（Rule 51.1 校验在 attest 侧另行把关）。
#   mini 豁免（Rule 38.2 区块白名单）：mini-lite 白名单仅 Goal/VC/执行范围
#   限制表/单 Phase/Handoff 表，增仪式区块=模板违约（selftest-plan-tier
#   断言）→ mini 档跳过注入。判定沿用脚本内既有分流变量/文件标记（二者或）：
#     ① TASK_PLAN_SRC=variant/mini-lite-type.md（L195 tier 分流路由产物）
#     ② 产物含 `plan_tier: mini` 标记（mini-lite 模板 :2 frontmatter /
#        auto-tier 命中标记 L256-258）
#   ①②都未命中而 PLAN_TIER=mini 且 variant 定制优先（L191-197 忽略场景）时，
#   产物实为中档定制 → 不豁免照注入（中档计划必须载 Rule 51.1 区块）。
# 幂等：已含锚 → return 0；task_plan.md 已存在走 skip 分支的重复 init 再入
#   本函数也被锚判定短路，不会重复插入。
# 插入量=空行分隔符 1 + 脚手架 9 行共 10 行（Rule 45 完整注释：What 如上，
#   Why=29 模板零载体 + mini 白名单违约风险 + fail-open 取舍）。
# ============================================================================
inject_requirement_block() {
    local file="task_plan.md"
    local scaffold insat

    [ -f "$file" ] || return 0

    # Gate 1: 已含锚（主模板/rule-enhancement 变体自带载体）→ INFO 跳过
    if grep -q '## 🎯 用户需求原文' "$file" 2>/dev/null; then
        echo "[init] INFO: task_plan.md 已含 🎯 用户需求原文 区块（模板自带载体）— 注入跳过"
        return 0
    fi

    # Gate 2: mini 档豁免（Rule 38.2 白名单；判定见函数头注释 ①②）
    if [ "$TASK_PLAN_SRC" = "variant/mini-lite-type.md" ] \
       || grep -q 'plan_tier: mini' "$file" 2>/dev/null; then
        echo "[init] INFO: mini 档豁免（Rule 38.2 区块白名单）— 不注入 🎯 用户需求原文 区块"
        return 0
    fi

    # 插入位计算: 第一个 `## Goal` 标题行之前；无 Goal 行 → 文件头部注释块
    # （顶部连续的 空行 / HTML 注释行 / --- frontmatter 定界行）之后
    insat="$(grep -n '^## Goal' "$file" | head -n1 | cut -d: -f1)"
    if [ -z "$insat" ]; then
        # Why 用 awk 单遍扫描而非 shell 循环: 头部判定需跟踪多行 HTML 注释
        # 开闭状态（<!-- ... --> 跨行），awk 变量比 shell 临时文件干净
        insat="$(awk '
            {
                if (done) next
                # 首行即正文（非空行/非 HTML 注释开/非 frontmatter 定界）→ 插文件顶
                # 注意: mawk 不支持 POSIX 逻辑运算符 || &&，多条件用 AND 串接
                if (NR==1 && $0 !~ /^[[:space:]]*$/ && $0 !~ /^<!--/ && $0 !~ /^---$/) { print 1; done=1; exit }
                # 空行 / frontmatter 定界 / HTML 注释开闭行均属头部块
                $0 ~ /^[[:space:]]*$/ || $0 ~ /^---$/ { last=FNR; next }
                $0 ~ /^<!--/ { cmt=1; last=FNR; next }
                $0 ~ /^-->[[:space:]]*$/ { cmt=0; last=FNR; next }
                # 多行 HTML 注释内部行（既非开也非闭）
                cmt { last=FNR; next }
                # 首个正文行 → 头部块止于上一行（插入点=本行行号，即"之后"）
                print FNR; done=1; exit
            }
            END { if (!done) print (last>0 ? last+1 : 1) }
        ' "$file")" || insat=""
    fi
    [ -n "$insat" ] || insat=1

    # 脚手架落临时文件（quoted heredoc: 占位符 <...> 与 ** 须原样保留，禁展开）
    scaffold="$(mktemp)" || {
        echo "[init] WARN: 🎯 用户需求原文 注入失败（mktemp 失败）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        return 0
    }
    cat > "$scaffold" <<'EOF'
## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：init 注入载体（审计 H-3 清账；Rule 51.1 计划侧零兜底修复）。R 行=用户原话逐条编号；映射=每条核心需求 ≥1 VC；本脚手架由规划者填写后 attest 校验 -->

- **R1**: 「<用户原话第 1 条，逐字抄录，禁转译>」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | <判据：计数=0/文件在位+绝对路径/命令输出形态> |
EOF
    # 在 insat 行之前打印脚手架 + 1 行空行分隔（共 10 行写入，保住 markdown 结构）
    if ! awk -v f="$scaffold" -v insat="$insat" '
        NR==insat && !done { while ((getline s < f) > 0) print s; print ""; done=1 }
        { print }
    ' "$file" > "${file}.v131tmp" 2>/dev/null; then
        # fail-open（见函数头 Why）: awk 失败 → stderr 警告，清理，继续 init
        echo "[init] WARN: 🎯 用户需求原文 注入失败（awk 写出异常）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v131tmp" "$scaffold"
        return 0
    fi
    if ! mv "${file}.v131tmp" "$file" 2>/dev/null; then
        # fail-open: 磁盘/权限类写回失败同样不中断 init
        echo "[init] WARN: 🎯 用户需求原文 区块写回失败（磁盘/权限）— 继续 init（fail-open: 注入是增强非前置依赖，规划者可手补）" >&2
        rm -f "${file}.v131tmp" "$scaffold"
        return 0
    fi
    rm -f "$scaffold"
    echo "    [init] 🎯 用户需求原文 脚手架已插入（Rule 51.1 生成面兜底, task-v131；规划者填写 R 行+映射后 attest 校验）"
    return 0
}

# [2026-09-15 task-v074 P4-S1] 1) TEMPLATE_TYPE 位置参数为空时兜底 env TASK_TEMPLATE_TYPE
#    (消 SKILL.md:524 "自动路由"语义漂移——SKILL 描述与实现一致化)
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
_s22_uint() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }
if [ -z "$PLAN_TIER" ] && [ "${TASK_AUTO_TIER:-}" = "1" ]; then
    if [ "${TASK_TIER_EXCLUDE:-}" = "1" ]; then
        echo "[init] auto-tier: 命中④排除条件（保护区/Rule 36 技能修改/D6 高危），不自动降 mini（Rule 38.6；显式指定 mini 仍可）"
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
for file in findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md; do
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

# [2026-09-29 task-v096 P2-S1 T1 分支①] template-sense 区块（Rule 34.3② 预登记触发点）：
# 仅当 TEMPLATE_TYPE 最终决议为 general（类型空缺落 general 兜底）时 emit 提示行并向 task_plan.md
# 末尾追加「🔁 模板感知」区块。已知 16 类（bugfix 等）零调用，known-type 路径逐字节不变。
# 区块内同时声明 template_type: general + 34.3② 预登记 → check-template-type 三形态命中
# （模板本体 task_plan.md 无 template_type 标记，运行时追加而非改本体，§4 条 1 约束）。
# 正交性（§4 条 10）：本调用点在 tier 分流/复制之后，mini 档只改 tier 不碰 sense；
# unknown 类型分支（L183-186 区段）本 S-unit 不动（P2-S2）。
# 幂等保护：同任务目录重复运行 init（task_plan.md 已存在=skip 分支）不重复追加。
# [task-v096 CR-fix] 仅无 template_type 标记的产物才追加（防 mini/known-type 产物被二次标记）:
# 新鲜 general 兜底副本（templates/task_plan.md）无 template_type: 标记 → 触发；
# bugfix 等 known-type / mini-lite 产物首行带 <!-- template_type: X --> 标记 → 不触发。
if [ -z "$TEMPLATE_TYPE" ] && [ -f "task_plan.md" ] \
   && ! grep -q 'template_type:' "task_plan.md" 2>/dev/null; then
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
   && ! grep -q 'template_type:' "task_plan.md" 2>/dev/null; then
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

echo ""
# [2026-09-04 Rule 19.5 配套] 文件存在性复核：缺失或空 → exit 1
# [2026-09-13 task-v067] 5 文件→6 文件（+knowledge-brief.md）
missing_files=()
for f in task_plan.md findings.md progress.md notepad-learnings.md verification.md knowledge-brief.md; do
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
echo "[init] 6/6 planning files verified"
# [2026-09-05 task-active-plan] 自动写活跃计划指针(最新创建的计划=默认活跃);
# 失败仅警告不阻断(指针缺失时 resolve-plan-dir.sh 回退 mtime 最新)
# 2026-09-10 active-plan-race: 原行为=无条件覆写全局 plans/.active_plan(后写者赢,多并行会话互顶,
#   09-09 实锤 7 次 check-dispatch 误拦)。改为:env CLAUDE_CODE_SESSION_ID 有值(ZCode 会话)→
#   原子写会话私有 side 指针 .active_plan_side/<sidkey>.active_plan,不碰全局 legacy;
#   无值(cron/纯脚本单会话场景)→保持原行为写全局 legacy(7am cron 兼容)。
# [2026-09-16 task-v074 P10] PLAN_ROOT 解析修正：原 `cd .. && pwd` 假设 CWD=plans/<task-id>/
# （即 <root>/plans/<task-id>），哨兵/指针写到 <root>/.active_plan_side；但 canonical 侧
# 目录（task-plan-init.cjs :76 / resolve-plan-dir.sh :33 / set-active-plan.sh / check-scope.sh
# 及主仓真实布局）均在 <root>/plans/ 下。原错位下新写的指针 resolve 侧查不到 →
# P1-2 指针/哨兵错位根因之一。修正：CWD=plans/ → root=CWD；CWD=plans/<task-id>/（既有标准
# 运行方式）→ root=..（行为不变）；其他（非标准目录）→ 维持旧 cd ..（降级，无破坏）。
# 副作用登记：CWD=plans/<task-id> 运行时 legacy 全局指针与 side 指针落点从 <root>/.active_plan
# 迁移到 <root>/plans/.active_plan{,_side}，与 set-active-plan/resolve/attest 的现有口径对齐。
if [ "$(basename "$(pwd)")" = "plans" ]; then
    PLAN_ROOT="$(pwd)"
elif [ "$(basename "$(dirname "$(pwd)")")" = "plans" ]; then
    PLAN_ROOT="$(cd .. && pwd)"
else
    PLAN_ROOT="$(cd .. && pwd)"  # 非标准目录：维持旧行为（CWD 守卫已限制风险面）
fi
SIDSRC="${CLAUDE_CODE_SESSION_ID:-}"
if [ -n "$SIDSRC" ]; then
    SIDKEY="$(printf '%s' "$SIDSRC" | tr -cd 'a-zA-Z0-9' | head -c 40)"
    # [2026-09-16 task-v074 P10 sid 哨兵探测 fallback] env CLAUDE_CODE_SESSION_ID 与
    # hook stdin .session_id 是两个命名空间(SessionStart 哨兵用 hook sid 写,init 用 env sid
    # 清/登记 → 指针/哨兵错位,见 findings P1-2)。当 env sid 无对应哨兵时,探测
    # .plan_required_side/ 下 mtime 最新的哨兵 stem 作为本会话真实 sidkey
    # (SessionStart 在会话启动时刚写入=本会话落地物)。多会话并发局限:最新 mtime 的
    # 启动会话优先,属已知取舍。无哨兵 → 维持现状 fallback(env sid 或无 sid)。
    if [ -n "$SIDKEY" ] && [ ! -f "${PLAN_ROOT}/.plan_required_side/${SIDKEY}.plan_required" ]; then
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
                if [ -n "$_sent_sid" ] && [ "$_sent_sid" != "$SIDKEY" ]; then
                    echo "[init] INFO: env sid(${SIDKEY}) 无对应哨兵,fallback 最新哨兵 sid(${_sent_sid})"
                    SIDKEY="$_sent_sid"
                fi
            fi
        fi
    fi
    SIDE_DIR="${PLAN_ROOT}/.active_plan_side"
    if [ -n "$SIDKEY" ] && mkdir -p "$SIDE_DIR" 2>/dev/null; then
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
