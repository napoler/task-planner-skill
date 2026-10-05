#!/usr/bin/env bash
# check-dispatch.sh — Agent() 派发契约守卫 (Rule 22.4c / 22.8.1, task-v057 Phase 4)
# 校验派发 prompt 是否含: 计划三文件绝对路径(task_plan.md/findings.md/progress.md)
# + 8 字段返回 key 必检标记(status: / acceptance: / checkpoint:) + subagent-state/ 检查点路径。
# 缺项按档位处置: enforce=exit 2 阻断 / warn=exit 0 + 落盘告警 / off=跳过。
#
# Usage:
#   check-dispatch.sh pretool <prompt-file> [sid]     # hook 入口: exit 0 放行 / exit 2 enforce 阻断([dispatch-block]→stderr)
#   check-dispatch.sh check <prompt-file> <plan-dir>  # 纯检查: stdout 每行一个缺项名; exit 0 无缺项 / 1 有缺项(与档位无关)
#
# 环境覆盖: TASK_PLANNER_DISPATCH_ENFORCE=enforce|warn|off (档位;未设则 jq 读 config.json)
#           TASK_PLANNER_PLAN_DIR=<dir> (计划目录;未设则 resolve-plan-dir.sh "$PWD" 输出取 dirname)
#
# fail-open (exit 0 + stderr 记录): 无活跃计划 / 计划目录不存在 / prompt 文件不可读 / jq 缺失
# 退出码: 0=放行|无缺项|fail-open; 1=check 有缺项; 2=enforce 阻断
#
# [2026-09-10 task-planrequired-race] 修改说明(仅 cmd_pretool 的计划目录解析与违规处置语义;
# 其余函数/subcommand 字节不变):
#   原行为 = pd 仅按「env TASK_PLANNER_PLAN_DIR → resolve-plan-dir.sh 链」解析,缺项一律 exit 2;
#   全局指针 .active_plan 被并发会话/cron 频繁翻转指向他会话计划目录时,任何合规 prompt
#   (含本会话计划路径) 都被误判"缺项"而 exit 2 阻断派发(当日实锤 4 次,见 findings.md B5/B5a)。
#   现改三级解析: ① TASK_PLANNER_PLAN_DIR env 显式 → enforce(显式指定维持强校验);
#   ② prompt 自声明(三文件路径同目录三件齐 且 task_plan.md 真实存在,兼容 /home 与 /mnt/data
#   双视图拼写) → enforce; ③ resolve 链(sid 指针/global/mtime)兜底未命中 → 降级 warn:
#   打印一行 [dispatch-guard] ⚠ 到 stderr 后 exit 0(fail-open,根治 B5 跨会话误拦)。
#   TASK_PLANNER_DISPATCH_ENFORCE=off 全程放行 与 =warn 既有分支语义保持不变;成功路径(无缺项)保持静默 exit 0。
#
# [2026-09-10 task-path-identity] 身份判定改造记录(仅 scan_missing 三文件分支;档位分档不变):
#   现象 = 混拼写 prompt(task_plan 行 /home、findings 行 /mnt/data、progress 行 /home)在 enforce 档
#   被 grep -qF 字面匹配误判缺项 exit 2(bind mount 双视图: 同仓同文件两种拼写);
#   根因 = 旧 alt 拼写 $pd_real 依赖 pwd -P/realpath,而 realpath 不折叠 bind mount,alt 形同虚设;
#   修法 = 双轨文件身份判定: 两侧文件都存在 → stat -c %d:%i(device:inode)比对,拼写免疫;
#   任一不存在(拟创建计划)→ realpath -m 两侧规范串相等即命中;alt 拼写与 pd_real 变量一并废除。
#
# [2026-09-16 task-v075 P3-S1] 三项增量检测（Rule 22.4 KQ3，全部挂在既有 get_mode() 档位:
# enforce=exit 2 阻断 / warn=stderr 告警 + 计数落盘(复用本文件 :189-192 的
# task-planner-dispatch-warn-<sid> 计数文件范式) / off=跳过; 只增不改既有分支,
# scan_missing 七项判定/三级计划目录解析/serial_slot_check/成功路径静默 exit 0 语义不变）:
#   ① prompt 长度: `wc -m < prompt` > prompt_max_chars（jq 读 config.json
#      .properties.subagent.prompt_max_chars.default; jq 缺失/键缺失 → 回退默认 3000
#      + 一行 SKIPPED 说明, 复用 check-plan-dispatch.sh:63-77 的 P2 范式）。超限 →
#      `[dispatch-guard] ⚠ prompt 长度 N > 3000`
#   ② 多 S-unit 打包: `grep -oE 'S[0-9]+' prompt | sort -u | wc -l` ≥2 → 告警
#      `[dispatch-guard] ⚠ 单 prompt 检出 N 个 S-unit ID（Rule 25.2 逐 S-unit 派发）`。
#      口径（定死）: 全 prompt 内 distinct `S<n>` 字面集合计数（行首/非行首一律计,
#      非自由文本豁免——与 P2 KQ1 同源 token 计数范式）; warn 档默认仅作观察期数据,
#      误伤代价=计数警告, 观察数据回填后再定行首限定收紧（task_plan FMEA P3 行兜底）。
#      [2026-10-03 task-v118] 任务书豁免收窄（Rule 46.2）: 双条件（任务书 ∧ subagent-state/）命中时
#      不再整体 SKIPPED（原行为=task-v078 双条件整体跳过, 任务书塞多 S-unit 畅通无阻, task-v116 实证）,
#      改为从 prompt 提取 subagent-state/ 引用路径（定界=空白与「」()，;等; 去尾标点, ≤3 个）,
#      对存在且可读（-f）的文件合并内容计 distinct `S[0-9]+` 数 n:
#      n≥2 → 打包命中（「任务书检出 N 个 S-unit ID」行, 计入 hits 走既有档位管线）;
#      n≤1 或引用文件全部不存在/不可读 → fail-open: SKIPPED 行（不计 hits）。
#   ③ knowledge-brief 引用提示: 仅当计划目录已解析（pd 非空）且 <pd>/knowledge-brief.md
#      存在、且 prompt 既不含 `brief` 也不含 `§` → 告警提示引用 brief 节锚点
#      （Rule 21.2/22.4）; 无 brief / 已引用 → 静默, 不产生输出。
#   ④ 步骤枚举计数: [task-v081] count_step_markers(prompt) 的 distinct 步骤序号 >
#      step_max_steps（jq 读 .properties.subagent.properties.step_max_steps.default;
#      缺失 → 回退默认 4 + SKIPPED 一行, ①②③ 同范式）→ 告警+计入 hits, 按档位处置
#      （任务书豁免场景对任务书文件同步计数取最大, 防 13 步躲进落盘任务书绕门）。
#      [2026-10-03 task-v118] 任务书模式例外（Rule 46.2 收窄）: 任务书分支对任务书文件调用
#      count_step_markers <file> tb（行首 markdown 编号项计入去重集合）——task-v116 实证任务书
#      以 `1.`-`6.` 行首编号列 6 类动作时, 原行为=两模式统一排除行首 markdown 编号, 计数=0
#      全漏检; 自由 prompt 分支保持 count_step_markers <file> 单参口径（行首 markdown 编号
#      依旧不入口径, 防误伤合法 prompt 形态）。口径与边界见 count_step_markers 函数注释。
#   ①②③④ 均在缺项扫描之后追加; 缺项存在时（既有处置: warn=告警放行 / enforce=exit 2）
#   仍先执行既有缺项路径（行为不变）, 仅当缺项扫描通过（即将串行槽检查放行）时执行四项,
#   四项目前全部通过 → 保持既有静默 exit 0 语义（成功路径零输出）。
set -u

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# [task-v057] BASH_SOURCE 推导出的 SKILL_ROOT 是 scripts/ 目录;config.json 在 skill 根(上一级)
# [2026-10-05 task-v131 P6-S2 审计 L-1] 语义注明(仅注释,变量名与解析逻辑零改动):
#   变量名 SKILL_ROOT 为遗留误称,实指 **scripts/ 目录**(即 BASH_SOURCE 所在目录),并非 skill 根;
#   与 selftest-agent-coverage.sh:17 的 SKILL_ROOT(= $SCRIPT_DIR/..,指 skill 根)语义相反——
#   两脚本同名变量不同语义,跨脚本阅读时勿混用。CONFIG_JSON="$SKILL_ROOT/../config.json" 的上跳
#   即 skill 根,是本变量 scripts/ 语义的佐证。
CONFIG_JSON="$SKILL_ROOT/../config.json"

# 缺项扫描: $1=prompt 文件 $2=计划目录 → stdout 每行一个缺项名(固定顺序 P1..P3,R1..R3,C1)
# [2026-09-10 task-path-identity] 原行为=grep -qF 字面匹配+无效 alt 拼写（realpath 不折叠 bind mount），混拼写 prompt 被误判缺项；改为文件身份判定：存在文件→stat -c %d:%i inode 比对（bind mount 免疫），不存在→realpath -m 规范串比对；废除 alt 拼写
scan_missing() {
    local f="$1" pd="$2" item c hit id_cand id_ref dc dr
    pd="${pd%/}"
    # [2026-09-10 task-path-identity] 文件身份判定: 预抽取 prompt 中所有以三文件名结尾的候选路径
    local cands
    cands="$(grep -oE '[^[:space:][:cntrl:]]*/(task_plan|findings|progress)\.md' "$f" 2>/dev/null | sort -u || true)"
    for item in "$pd/task_plan.md" "$pd/findings.md" "$pd/progress.md" "status:" "acceptance:" "checkpoint:" "subagent-state/"; do
        case "$item" in
        */task_plan.md|*/findings.md|*/progress.md)
            # Why（task-v115 线C）: 三文件走文件身份判定(stat inode)、固定 key 走字面 grep -qF——
            # 取舍=身份类缺项须免疫 /home 与 /mnt/data 双视图拼写（bind mount 不折叠路径），
            # 而 "status:"/"checkpoint:" 等固定 key 无路径语义，字面匹配即精确且零误判。
            hit=0
            for c in $cands; do
                case "$c" in
                *"/${item##*/}") ;;      # 文件名须与 item 一致(task_plan.md 等), 避免跨名误判
                *) continue ;;
                esac
                if [ -e "$c" ] && [ -e "$item" ]; then
                    # a. 两侧都存在 → device:inode 相同即同一文件(bind mount 双拼写免疫)
                    id_cand="$(stat -c %d:%i -- "$c" 2>/dev/null)" || continue
                    id_ref="$(stat -c %d:%i -- "$item" 2>/dev/null)" || continue
                else
                    # b. 任一不存在(拟创建计划) → 目录身份优先: 两侧目录都在则 dirname 的
                    #    device:inode 比对(拼写免疫——全路径 realpath -m 不折叠 bind mount,
                    #    Phase 5 VC-3 实测跨视图拟创建仍误拦); 目录也不在才退 realpath -m 全路径
                    dc="$(dirname -- "$c" 2>/dev/null)" || continue
                    dr="$(dirname -- "$item" 2>/dev/null)" || continue
                    if [ -d "$dc" ] && [ -d "$dr" ]; then
                        id_cand="$(stat -c %d:%i -- "$dc" 2>/dev/null)" || continue
                        id_ref="$(stat -c %d:%i -- "$dr" 2>/dev/null)" || continue
                    else
                        id_cand="$(realpath -m -- "$c" 2>/dev/null)" || continue
                        id_ref="$(realpath -m -- "$item" 2>/dev/null)" || continue
                    fi
                fi
                [ -n "$id_cand" ] && [ "$id_cand" = "$id_ref" ] && { hit=1; break; }
            done
            if [ "$hit" -ne 1 ]; then
                case "${item##*/}" in
                task_plan.md) printf 'task_plan.md\n' ;;
                findings.md) printf 'findings.md\n' ;;
                progress.md) printf 'progress.md\n' ;;
                esac
            fi
            ;;
        *)
            grep -qF -- "$item" "$f" 2>/dev/null || printf '%s\n' "$item" ;;
        esac
    done
}

# 档位解析: 环境变量优先;未设 → jq 读 .properties.dispatch_contract_enforce.default // "enforce"
# (config 缺失/jq 解析失败 → enforce;jq 二进制缺失 → "nojq" sentinel,调用方 fail-open)
# Why（task-v115 线C）: 双轨 fail 方向取舍——config 缺失/解析失败属项目侧问题（守卫应生效却没配置），
# 取 fail-closed(enforce) 防静默逃逸；jq 二进制缺失属环境侧问题，若 fail-closed 则无 jq 宿主上
# 一切派发全被阻断锁死，故 "nojq" sentinel 交调用方走 fail-open + stderr 痕迹（错误必须曝光）。
get_mode() {
    local m="${TASK_PLANNER_DISPATCH_ENFORCE:-}"
    if [ -n "$m" ]; then
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
        return 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf 'nojq'; return 0
    fi
    if [ ! -f "$CONFIG_JSON" ]; then
        printf 'enforce'; return 0
    fi
    # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
    m="$(jq -r '.dispatch_contract_enforce // .properties.dispatch_contract_enforce.default // "enforce"' "$CONFIG_JSON" 2>/dev/null)" || m="enforce"
    case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
}

# 计划目录解析: 环境变量 TASK_PLANNER_PLAN_DIR 优先,否则 resolve-plan-dir.sh 输出(= task_plan.md 路径)取 dirname
# [2026-09-10 active-plan-race] resolver 二参带会话 sid(zcode-pretooluse.sh Agent 分支 export TASK_PLANNER_SID
# 传入;未设则回 env CLAUDE_CODE_SESSION_ID/resolver 内置 default) → .active_plan_side/<sid>.active_plan
# 会话私有指针优先,并行会话的派发守卫各查各的计划,不再被互顶的全局 legacy 指针误拦
resolve_plan_dir() {
    local pd="${TASK_PLANNER_PLAN_DIR:-}" pfile
    if [ -n "$pd" ]; then
        printf '%s' "$pd"; return 0
    fi
    pfile="$(bash "$SKILL_ROOT/resolve-plan-dir.sh" "$PWD" "${TASK_PLANNER_SID:-}" 2>/dev/null || true)"
    if [ -n "$pfile" ] && [ -f "$pfile" ]; then
        printf '%s' "$(dirname "$pfile")"
    fi
}

join_missing() { printf '%s\n' "$1" | tr '\n' ',' | sed 's/,$//'; }

cmd_pretool() {
    local pf="${1:-}" sid="${2:-unknown}"
    if [ -z "$pf" ]; then
        echo "[dispatch-guard] pretool: 缺 <prompt-file> 参数, fail-open" >&2; exit 0
    fi
    if [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] prompt 文件不可读($pf), fail-open" >&2; exit 0
    fi
    local mode pd missing names
    mode="$(get_mode)"
    if [ "$mode" = "nojq" ]; then
        echo "[dispatch-guard] jq 缺失, 派发契约守卫 fail-open" >&2; exit 0
    fi
    [ "$mode" = "off" ] && exit 0
    # Why（task-v115 线C）: 三级解析的取舍=锚定可信度决定档位——env 显式与 prompt 自声明是
    # 本会话自身给出的计划目录证据（可信），维持 enforce；resolve 链兜底的 side/全局指针
    # 可被并发会话翻转向他会话（B5 实锤 4 次误拦），只能当弱证据降级 warn，根治跨会话误拦。
    # [2026-09-10 task-planrequired-race] 三级计划目录解析,决定 pd 与处置档位(见头部修改说明):
    # ① TASK_PLANNER_PLAN_DIR env 显式 → enforce; ② prompt 自声明(声明含 task_plan.md 路径的目录
    # 且该目录 task_plan.md 真实存在,取首个命中拼写,兼容 /home 与 /mnt/data 双视图) → enforce;
    # ③ 均未锚定 → resolve 链(带 sid)兜底,一律降级 warn 放行(根治 B5 跨会话误拦)
    local pd_mode decl_taskdirs d
    # 自声明目录组 = prompt 中所有 task_plan.md 声明路径的 dirname(去重)
    decl_taskdirs="$(grep -oE '[^ [:cntrl:]]*/task_plan\.md' "$pf" 2>/dev/null | xargs -n1 dirname 2>/dev/null | sort -u || true)"
    if [ -n "${TASK_PLANNER_PLAN_DIR:-}" ]; then
        pd="${TASK_PLANNER_PLAN_DIR}"; pd_mode="enforce"
    else
        pd=""
        # 自声明锚定: 取 prompt 中 task_plan.md 声明路径的目录组(去重); 该目录下
        # task_plan.md 真实存在([ -f ])即锚定——双视图拼写下取首个可命中者;
        # 三件齐(组内同时含三文件名)是本条件最强形态, 缺 findings/progress 声明
        # 仍按缺项在 enforce 档被 scan 捕获(不得因此逃逸到 warn 档)
        for d in $decl_taskdirs; do
            if [ -f "$d/task_plan.md" ]; then
                pd="$d"; break
            fi
        done
        if [ -n "$pd" ]; then
            pd_mode="enforce"
        else
            pd="$(resolve_plan_dir)"
            pd_mode="warn"
        fi
    fi
    if [ "$pd_mode" = "warn" ]; then
        # [task-planrequired-race] B5 根治: env 显式与 prompt 自声明均未锚定本会话计划目录,
        # side/resolve 只是兜底(全局指针可能被并发会话翻转指向他会话) → 降级 warn 放行,不再 exit 2 误拦
        if [ -n "$pd" ] && [ -d "$pd" ]; then
            missing="$(scan_missing "$pf" "$pd")"
            # [task-v075 P3-S1] 兜底命中且无缺项 → 三项增量检测(warn 档计数观察)+ 串行槽检查
            [ -n "$missing" ] || { fine_grain_checks "$pf" "$pd" "$mode" "$sid"; local ro=0 pg=0; if grep -qm1 'parallel_readonly: true' "$pd/task_plan.md" 2>/dev/null && grep -qm1 '\[readonly-parallel\]' "$pf" 2>/dev/null; then ro=1; fi; # [2026-10-02 task-v110] 并行组放行: 计划 frontmatter 声明 parallel_groups: ∧ prompt 含 [parallel-group:<组名>] 标记 → pg=1(独立性四问责任在计划期声明, 守卫信任标记不做文件集比对); 无标记路径零改动
            grep -qm1 'parallel_groups:' "$pd/task_plan.md" 2>/dev/null && grep -qm1 '\[parallel-group:' "$pf" 2>/dev/null && pg=1; serial_slot_check "$pd" "$mode" "$sid" "$ro" "$pg"; exit 0; }
            names="$(join_missing "$missing")"
        else
            names="unknown"
        fi
        echo "[dispatch-guard] ⚠ 计划目录解析未命中本会话(side/自声明)，降级 warn 放行(pd=${pd:-空}) 缺项=${names}" >&2
        exit 0
    fi
    # enforce 档(env 显式 / prompt 自声明锚定成功): 沿用原有缺项扫描与分档处置
    [ -n "$pd" ] && [ -d "$pd" ] || exit 0   # 目录不存在 → fail-open(原语义)
    # [task-v075 P3-S1] 既有缺项扫描之后的三项增量(长度/打包/brief 引用), 挂既有档位处置
    missing="$(scan_missing "$pf" "$pd")"
    # [task-v061-serial-dispatch] 契约校验通过(无缺项), 即将放行前执行串行槽检查; 缺项 exit 2 路径不写锁不检查
    [ -n "$missing" ] || { fine_grain_checks "$pf" "$pd" "$mode" "$sid"; local ro=0 pg=0; if grep -qm1 'parallel_readonly: true' "$pd/task_plan.md" 2>/dev/null && grep -qm1 '\[readonly-parallel\]' "$pf" 2>/dev/null; then ro=1; fi; # [2026-10-02 task-v110] 并行组放行(与 warn 兜底路径同语义): 声明 parallel_groups: ∧ 组标记 → pg=1
    grep -qm1 'parallel_groups:' "$pd/task_plan.md" 2>/dev/null && grep -qm1 '\[parallel-group:' "$pf" 2>/dev/null && pg=1; serial_slot_check "$pd" "$mode" "$sid" "$ro" "$pg"; exit 0; }
    names="$(join_missing "$missing")"
    if [ "$mode" = "warn" ]; then
        echo "[dispatch-warn] ⚠ 派发契约缺项: $names"
        wf="${TMPDIR:-/tmp}/task-planner-dispatch-warn-${sid}"
        [ -f "$wf" ] && [ -n "$(find "$wf" -mmin +1440 2>/dev/null)" ] && rm -f "$wf"   # [p7fix] 24h TTL: 过期计数先清
        printf '%s [dispatch-warn] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$names" \
            >> "$wf" 2>/dev/null || true
        exit 0
    fi
    echo "[dispatch-block] 🚫 派发契约缺项(Rule 22.4a/b/22.8.1): $names — prompt 须含计划三文件绝对路径 + 8 字段返回模板 + subagent-state 检查点路径(templates/subagent_dispatch.md §2/§7/§8)" >&2
    exit 2
}

cmd_check() {
    local pf="${1:-}" pd="${2:-}"
    if [ -z "$pf" ] || [ ! -f "$pf" ] || [ ! -r "$pf" ]; then
        echo "[dispatch-guard] check: prompt 文件不可读, fail-open" >&2; exit 0
    fi
    if [ -z "$pd" ] || [ ! -d "$pd" ]; then
        echo "[dispatch-guard] check: plan-dir 为空/不存在, fail-open" >&2; exit 0
    fi
    local missing
    missing="$(scan_missing "$pf" "$pd")"
    if [ -n "$missing" ]; then
        printf '%s\n' "$missing"
        exit 1
    fi
    exit 0
}

# count_step_markers <file> [taskbook] — [task-v081] distinct 步骤枚举序号计数（fine_grain_checks ④ 消费）
# 口径（定死）: `StepN`/`step N`（大小写不敏感,允许空格）/ `步骤N`（允许空格）/ `第N步`（仅数字）
#   / 圆圈序号 ①-⑮。序号值归一去重（Step3/③/第3步 同序号计 1）。
# [2026-10-03 task-v118] 任务书模式例外（第二参 taskbook=1, Rule 46.2 收窄）: 额外计入行首 markdown
#   编号项（`^[[:space:]]*[0-9]+[.、)）]`）, 提取行首编号数字并入同一去重集合。
#   Why: task-v116 实证任务书以 `1.`-`6.` 行首编号列 6 类动作时, 原行为=两模式统一排除行首
#   markdown 编号, 计数=0 全漏检, ④ 步骤枚举门形同虚设; 任务书是计划层自写落盘产物, 行首编号
#   即「任务书动作枚举」, 误伤验收清单的风险低, 故仅任务书模式例外纳入; 自由 prompt 调用点
#   （第二参缺省）行为零变化——行首 markdown 编号与验收清单难区分, 仍不入口径防误伤合法 prompt 形态。
# 边界（如实）: 汉字数字（第十一步）不入口径; 口径外写法=计数偏低（fail-open 方向）,显式 StepN 类为拦截主口径。
count_step_markers() {
    local f="$1" taskbook="${2:-}"
    {
        grep -oiE 'step ?[0-9]{1,3}' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        grep -oE '步骤 ?[0-9]{1,3}' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        grep -oE '第[0-9]{1,3}步' "$f" 2>/dev/null | grep -oE '[0-9]{1,3}'
        # [2026-10-03 task-v118] 任务书模式: 行首 markdown 编号项编号入去重集合;
        # 只提取行首序号位数字（sed 剥前导空白+首个非数字截断）, 避免把正文数字（如 "1. 改 step 3"）拖入
        # [2026-10-03 task-v118 CR] 位数上限 {1,2}: 原行为 [0-9]+ 无上限定, 任务书含行首日期
        # 「2025.10.03 修订记录」时 2025/10/3 三个值混入去重集合 → enforce 档步骤枚举门误拦;
        # 枚举列表行首编号几乎不超 99, 位限后日期不再命中本口径。
        [ -n "$taskbook" ] && grep -E '^[[:space:]]*[0-9]{1,2}[.、)）]' "$f" 2>/dev/null | sed -E 's/^[[:space:]]+//; s/[^0-9].*//'
        grep -oE '①|②|③|④|⑤|⑥|⑦|⑧|⑨|⑩|⑪|⑫|⑬|⑭|⑮' "$f" 2>/dev/null | awk '{if($0=="①")print 1;else if($0=="②")print 2;else if($0=="③")print 3;else if($0=="④")print 4;else if($0=="⑤")print 5;else if($0=="⑥")print 6;else if($0=="⑦")print 7;else if($0=="⑧")print 8;else if($0=="⑨")print 9;else if($0=="⑩")print 10;else if($0=="⑪")print 11;else if($0=="⑫")print 12;else if($0=="⑬")print 13;else if($0=="⑭")print 14;else if($0=="⑮")print 15}'
    } | sort -n -u | grep -c . || true
}

# [2026-10-03 task-v118 CR-BLOCKER] 守卫②(任务书打包)/守卫④(任务书步骤计数)共用提取器
# 原行为 = ②④两处各自内联 grep -oE '[^[:space:]"]*subagent-state/[^[:space:]"]*' + sed 剥标点,
#   且两处字符类不一致(②剥「」④不剥); 字符类不含全角括号（）与全角冒号：, 中文最自然引用形态
#   「执行（任务书：/path/subagent-state/tb.md）按序」提取出整串含前后缀的 token, 对存在的文件
#   -f 判定失败 → fail-open, 守卫②④对全角形态失明(CR 必修项 1)。
# 修法 = 提取字符类两侧扩展 ASCII+全角定界(「」『』“”（）(),，。：:；;、！!?？等),
#   再用 LC_ALL=C sed 按字节剥残余非 ASCII 前后缀(纯 CJK 粘连形态「详见subagent-state/x.md按序」兜底),
#   归一为 1 行 1 个去重路径(≤3 个)供 ②④ 统一消费。
extract_subagent_state_refs() {
    local f="$1"
    grep -oE '[^[:space:]"「」『』“”（）(),，。：:；;、！!?？]*subagent-state/[^[:space:]"「」『』“”（）(),，。：:；;、！!?？]*' "$f" 2>/dev/null \
        | LC_ALL=C sed -E 's/^[^[:print:]]*//; s/[^[:print:]]*$//' \
        | sort -u | head -3 || true
}

# [task-v075 P3-S1 + task-v081] 四项增量检测（Rule 22.4 KQ3; 口径与档位语义见文件头注释 2026-09-16 段）
# $1=prompt 文件 $2=计划目录(可空=未解析) $3=档位(enforce|warn; off 不会到达此函数) $4=sid
# 全部通过 → 静默返回 0（成功路径零输出不变）; 命中任一项 → 按档位处置:
#   warn=每项 stderr 一行告警 + 全部命中项合并写一行计数到既有 warn 计数文件
#   enforce=全部命中项合并 stderr 一行阻断, exit 2
# 四项均对既有七项缺项判定/三级目录解析零影响: 本函数在缺项扫描通过后独立调用。
fine_grain_checks() {
    local pf="$1" pd="$2" mode="$3" sid="${4:-unknown}"
    local pmax pchar sids n hits wf h smax step_n tb tn
    # ① prompt 长度: wc -m vs prompt_max_chars(jq 读 config .properties.subagent.prompt_max_chars.default;
    #    与 ② 同源: jq 缺失/键缺失/非数字 → 回退 3000 + 一行 SKIPPED 说明(P2 check-plan-dispatch 范式)
    # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
    pmax="$(jq -r '.subagent.prompt_max_chars // .properties.subagent.properties.prompt_max_chars.default // "3000"' "$CONFIG_JSON" 2>/dev/null)" || pmax=""
    if ! [[ "$pmax" =~ ^[0-9]+$ ]]; then
        pmax=3000
        echo "[dispatch-guard] SKIPPED prompt_max_chars 未解析(jq 缺失或键缺),回退默认 3000" >&2
    fi
    pchar="$(wc -m < "$pf" 2>/dev/null || echo 0)"
    pchar="${pchar//[!0-9]/}"
    [ -n "$pchar" ] || pchar=0
    hits=""
    if [ "$pchar" -gt "$pmax" ]; then
        echo "[dispatch-guard] ⚠ prompt 长度 $pchar > $pmax" >&2
        echo "[dispatch-guard] ⚠ 补救(Rule 35.3): 大内容落盘 <plan-dir>/subagent-state/{seq}-prompt.md,prompt 只放路径+Read 指令,禁止失败收场" >&2
        hits="prompt 长度超限($pchar>$pmax)"
    fi
    # ② 多 S-unit 打包: 全 prompt distinct S<n> 字面集合计数(P2 KQ1 同源 grep -o|wc -l 范式);
    #    ≥2 → 告警(warn 档观察期数据用, 口径见头注释)
    # [2026-09-17 task-v078] 双条件豁免: 单条件 subagent-state 会被合规派发的检查点路径命中(废掉打包门), 禁用
    # [2026-10-03 task-v118] 任务书豁免收窄(Rule 46.2): 原行为=双条件命中→打包计数整体 SKIPPED(任务书塞多
    #    S-unit 畅通无阻, task-v116 实证); 新行为=双条件触发不变, 但从 prompt 提取 subagent-state/ 引用路径
    #    (grep -oE 定界=空白与「」"等, 与 ④ 同源范式, 去首尾标点, ≤3 个), 对 -f 且 -r 的文件 cat 合并内容
    #    计 distinct `S[0-9]+` 数 n: n≥2 → 打包命中计入 hits(走既有档位管线); n≤1 或引用文件全部不存在/不可读
    #    → fail-open: SKIPPED 行(不计 hits, 维持 selftest FG-05 fixture 语义——其引用文件从未创建)
    if grep -qF '任务书' "$pf" 2>/dev/null && grep -qF 'subagent-state/' "$pf" 2>/dev/null; then
        # [2026-10-03 task-v118 CR-BLOCKER] 提取器改共用函数 extract_subagent_state_refs:
        # 原行为 = 内联 grep 字符类 [^[:space:]"] 不含全角括号（）/全角冒号：, 全角引用形态
        # 提取出含前后缀的整串 token → -f 判定失败 fail-open; 且与守卫④内联提取字符类不一致
        # (②剥「」④不剥)。现 ②④ 统一消费共用提取器(字符类含全角定界+残余非 ASCII 前后缀按字节剥离)。
        tb="$(extract_subagent_state_refs "$pf")"
        tn=""
        for tb in $tb; do
            [ -f "$tb" ] && [ -r "$tb" ] && tn="$tn
$(cat -- "$tb" 2>/dev/null)"
        done
        n="$(printf '%s' "$tn" | grep -oE 'S[0-9]+' | sort -u | grep -c . || true)"
        if [ "$n" -ge 2 ]; then
            echo "[dispatch-guard] ⚠ 任务书检出 $n 个 S-unit ID（Rule 46.2 任务书豁免收窄）" >&2
            [ -n "$hits" ] && hits="$hits; "
            hits="${hits}任务书打包($n 个 S-unit ID)"
        else
            echo "[dispatch-guard] SKIPPED 打包检测: prompt 引用落盘任务书(Rule 35.3 范式), 打包判定以任务书内容为准 (任务书无多 S-unit 或不可解析)" >&2
            n=0
        fi
    else
    sids="$(grep -oE 'S[0-9]+' "$pf" 2>/dev/null | sort -u)"
    n="$(printf '%s' "$sids" | grep -c . || true)"
    if [ "$n" -ge 2 ]; then
        echo "[dispatch-guard] ⚠ 单 prompt 检出 $n 个 S-unit ID（Rule 25.2 逐 S-unit 派发）" >&2
        [ -n "$hits" ] && hits="$hits; "
        hits="${hits}多 S-unit 打包($n 个 ID)"
    fi
    fi
    # ③ knowledge-brief 引用提示: 仅 pd 非空且 brief 存在、且 prompt 既无 `brief` 也无 `§` 时告警
    # Why（task-v115 线C）: 只出提示不阻断——brief 是知识底座「应引非必引」（小模型宿主可自主定位），
    # 且双关键词(brief/§)判「未引用」存在漏报可能，升级为 enforce 误伤面大于收益，保持 warn 观察。
    if [ -n "$pd" ] && [ -f "$pd/knowledge-brief.md" ] && ! grep -qE 'brief|§' "$pf" 2>/dev/null; then
        echo "[dispatch-guard] ⚠ 计划含 knowledge-brief.md 但 prompt 未引用节锚点(brief/§), 建议按 Rule 21.2/22.4 引用 brief 相关节" >&2
        [ -n "$hits" ] && hits="$hits; "
        hits="${hits}knowledge-brief 未引用"
    fi
    # ④ 步骤枚举计数(task-v081, Rule 21.1b 小步快跑): 单次派发 distinct 步骤枚举序号
    #    > step_max_steps(默认 4) → 拆分信号, 计入 hits 走既有档位管线(enforce=exit 2)。
    #    计数对象=prompt 本体; ② 的任务书双条件豁免命中时, 追加对 prompt 引用的落盘任务书
    #    (subagent-state 路径,≤3 个,存在可读)计数取最大 — 防 13 步躲进任务书绕门(v078 同源)。
    #    jq 不可用/配置文件缺失 → 回退默认 4 + 一行 SKIPPED(禁静默失败);键缺失时 jq `//` 兜底
    #    静默回 4(①②③ 家族同口径,SKIPPED 行不触发)。
    smax="$(jq -r '.properties.subagent.properties.step_max_steps.default // "4"' "$CONFIG_JSON" 2>/dev/null)" || smax=""
    if ! [[ "$smax" =~ ^[0-9]+$ ]]; then
        smax=4
        echo "[dispatch-guard] SKIPPED step_max_steps 未解析(jq 缺失或键缺),回退默认 4" >&2
    fi
    step_n="$(count_step_markers "$pf")"
    if grep -qF '任务书' "$pf" 2>/dev/null && grep -qF 'subagent-state/' "$pf" 2>/dev/null; then
        # [2026-10-03 task-v118] 任务书分支改用任务书模式(第二参 tb): 行首 markdown 编号并入计数
        # (原行为=count_step_markers "$tb" 单参, 行首 markdown 编号不入口径, 任务书 `1.`-`6.` 全漏检)
        # [2026-10-03 task-v118 CR-BLOCKER] 提取器改共用函数 extract_subagent_state_refs:
        # 原行为 = 内联 grep 字符类 [^[:space:]"] 不含全角括号（）/全角冒号：且本处不剥「」
        # (与守卫②内联提取不一致), 全角引用形态 -f 判定失败 fail-open; 现 ②④ 统一消费共用提取器。
        tb="$(extract_subagent_state_refs "$pf")"
        for tb in $tb; do
            [ -f "$tb" ] || continue
            tn="$(count_step_markers "$tb" tb)"
            [ "$tn" -gt "$step_n" ] && step_n="$tn"
        done
    fi
    if [ "$step_n" -gt "$smax" ]; then
        echo "[dispatch-guard] ⚠ 单次派发步骤枚举 ${step_n} 步 > step_max_steps(${smax})(Rule 21.1b) — 回计划层拆成多个 S-unit 再派" >&2
        [ -n "$hits" ] && hits="$hits; "
        hits="${hits}步骤枚举超限(${step_n}>${smax})"
    fi
    # ⑤ 需求锚 advisory（[2026-10-05 task-v131 P6-S2, Rule 51.1a/53.5 机器边界; critic P1-4 裁定落地, warn 档 fail-open）
    # What: prompt 全文缺「需求锚」字样 → stderr 一行提醒, 不改变任何 exit 码。
    # Why: 锚定义务（需求相关 S-unit 逐字引用治理 R 条目, 禁转译）由派发者承担（P1-4 裁定）,
    #      机器面仅提醒不阻断——「需求相关/纯机械单元」判定在规划者侧, 强制机器断言误伤面大于收益;
    #      刻意不并入 ①-④ 的 hits/计数管线: ①-④ 在 enforce 档会 exit 2 阻断, 本项须在任何档位
    #      (含 enforce 无缺项路径) 都只输出 stderr 一行, 成功路径 exit 0 与静默语义保持不变。
    if ! grep -qF '需求锚' "$pf" 2>/dev/null; then
        echo "[dispatch-guard] ⚠ 派发 prompt 未含「需求锚」字段（Rule 51.1a：需求相关 S-unit 须逐字引用治理 R 条目；纯机械单元可写「不适用（纯机械单元）」）——advisory 不阻断" >&2
    fi
    [ -z "$hits" ] && return 0
    if [ "$mode" = "warn" ]; then
        wf="${TMPDIR:-/tmp}/task-planner-dispatch-warn-${sid}"
        [ -f "$wf" ] && [ -n "$(find "$wf" -mmin +1440 2>/dev/null)" ] && rm -f "$wf"   # 24h TTL, 同既有范式
        h="${hits//,/; }"
        printf '%s [dispatch-warn] 细粒度检测: %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$h" \
            >> "$wf" 2>/dev/null || true
        return 0
    fi
    echo "[dispatch-block] 🚫 细粒度检测未通过(Rule 22.4 KQ3): $hits" >&2
    exit 2
}

# [task-v061-serial-dispatch] 串行槽守卫(Rule 21.4): inflight 锁 <plan-dir>/subagent-state/.dispatch-inflight
# (unix 时间戳)。age<120s → 判并行派发尝试, 按 get_mode 分档处置; 无锁/陈旧(≥120s,崩溃残留) → 写新锁放行;
# 锁不可写/plan-dir 解析失败 → fail-open 静默放行(与既有 fail-open 原则一致)。
# 边界(如实): run_in_background 的 Agent 调用 PostToolUse 立即返回即清锁, 后台并发不由本守卫捕获,
# 由 Rule 21.4 文本条款(后台派发视为持续占用串行槽)覆盖。
# 边界(多会话): 全局指针被翻转向他任务且他会话 Agent 返回时,可能误删本任务锁(120s TTL 自愈,仅短暂旁路串行约束)
# [2026-10-02 task-v110] 并行组槽语义演进: 第⑤参 pg(声明 parallel_groups: ∧ prompt [parallel-group:] 双条件命中=1)
# → 槽占用放行(组内共享锁不覆盖); 无组标记路径(warn/enforce 拦截文案含「串行」)行为零改动, 守卫信任标记不做四问机器校验
serial_slot_check() {
    local pd="${1:-}" mode="${2:-}" sid="${3:-unknown}" ro="${4:-0}" pg="${5:-0}" lf now ts age
    case "$mode" in enforce|warn) ;; *) return 0 ;; esac        # off/nojq → 跳过
    [ -n "$pd" ] && [ -d "$pd" ] || return 0                     # plan-dir 未解析 → fail-open
    lf="$pd/subagent-state/.dispatch-inflight"
    mkdir -p -- "${lf%/*}" 2>/dev/null || return 0               # mkdir 失败 → fail-open
    now="$(date +%s)" || return 0
    if [ -f "$lf" ]; then
        ts="$(head -n1 -- "$lf" 2>/dev/null)"
        case "$ts" in ''|*[!0-9]*) ts="" ;; esac
        if [ -n "$ts" ]; then
            age=$(( now - ts ))
            [ "$age" -lt 0 ] && age=0
            if [ "$age" -lt 120 ]; then                           # 槽占用
                # [2026-09-28 task-v094 T-B1] 只读并行豁免: 计划声明 parallel_readonly: true ∧ prompt 含 [readonly-parallel] 标记
                # → 放行且不覆盖写类锁; 写类(无标记)仍严格串行; 残留面=只读子代理越权写入无机器防护(22.4a 只读契约+验收 Read 承载)
                if [ "$ro" = "1" ]; then
                    echo "[dispatch-readonly] 只读并行豁免命中(声明+标记双条件), 槽占用(age=${age}s)放行, 写类锁保留" >&2
                    return 0
                fi
                # [2026-10-02 task-v110] 并行组槽放行: 声明制组标记命中(计划 parallel_groups: ∧ prompt [parallel-group:<组名>]),
                # 槽占用放行且组内共享锁不覆盖; 组间/未声明仍走下方串行路径(无标记行为零改动)
                if [ "$pg" = "1" ]; then
                    echo "[dispatch-parallel-group] 并行组标记命中(10-02 独立性守门), 槽占用(age=${age}s)放行 — 组内四问责任在计划期声明, 组间串行不变" >&2
                    return 0
                fi
                if [ "$mode" = "warn" ]; then
                    echo "[dispatch-warn] ⚠ Rule 21.4 串行派发铁律: 串行槽被占用(锁 age=${age}s<120s), 本派发按 warn 档放行 — 应等上一个子代理验收通过" >&2
                    return 0
                fi
                echo "[dispatch-block] 🚫 Rule 21.4 串行派发铁律: 串行槽被占用(锁 age=${age}s<120s), 禁止并行派发 — 须等上一子代理三证据验收通过(清锁)后再派下一个" >&2
                exit 2
            fi
        fi
    fi
    { printf '%s' "$now" > "$lf"; } 2>/dev/null || return 0     # [2026-09-12 task-v061 p2fix] 槽空闲 → 写新锁放行; 重定向包进父级 { } 2>/dev/null: 重定向建立失败(如 Permission denied)由父 shell 报出, 原写法仅吞 printf 自身 stderr 而泄漏重定向错误, 破坏 fail-open 静默
    return 0
}

case "${1:-}" in
    pretool) cmd_pretool "${2:-}" "${3:-}" ;;
    check)   cmd_check "${2:-}" "${3:-}" ;;
    *) echo "[dispatch-guard] usage: pretool <prompt-file> [sid] | check <prompt-file> <plan-dir>" >&2; exit 0 ;;
esac
