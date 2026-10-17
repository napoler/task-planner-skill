#!/bin/bash
# check-complete.sh — 终验完成度校验: 解析 task_plan.md 全部 Phase 的 - [x] 进度并在「全 complete」判定前
# 依次跑各门控(头注四要素范式对齐 Rule 45.3 / task-v115 线C 注释补强; 原头部无脚本名范式第一行, 此处补齐)
# 用途: 判定所有 Phase 是否 complete; 供 Stop hook 调用汇报任务完成状态 (Rule 18.6/19.5/23.6/31.5/25.4)
# 输入: $1=plan 文件路径(默认 task_plan.md, 相对/绝对均可); 读取同目录 findings.md/progress.md
#      (3-File Gate)、config.json 各门档位键(vc_gate_enforce/error_loop_enforce/fmea_enforce/delegation_rate_floor);
#      依赖外部命令: python3(段解析主体)/ jq(档位解析, 缺失时按各门 fail-open 语义回退)
# 输出: exit 0=全 complete 且各门放行(或全门 fail-open 通过); exit 1=门控失败或进度未完成;
#      stdout 输出 [plan] 行; 全 complete 时透传 [plan-deferred-delegation-check] plan_dir= 行供 shell 层委派率终验
# 依赖: 同目录 check-rescue-chain.sh / check-delegation.sh / check-plan-dispatch.sh(缺失各自行 fail-open)
#       + templates/progress.md(3-File Gate stub 判定对照)
# 支持 single-block 与 multi-block 链式任务 (chain_mode: linked / fan-out)
# 门控失败时 exit 1 (Batch Report Rule 18.6 / Aggregator Rule 23.6 / 3-File Gate Rule 19.5 / Learning Gate Rule 31.5)
# Used by Stop hook to report task completion status

PLAN_FILE="${1:-task_plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[plan] No task_plan.md found — no active planning session."
    exit 0
fi

# [2026-09-06 task-v053 Rule 27.3 porcelain 预检]
# 从 task_plan.md「执行范围限制」表格动态识别"允许的文件"列,
# 提取候选路径 → git status --porcelain -- <候选...> 检查未提交变更。
# 无 plan / 非 git 仓 / 候选列表为空 → 跳过,不改变退出码。
check_scope_porcelain() {
    local plan="$1"
    local plan_dir
    plan_dir="$(cd "$(dirname "$plan")" && pwd)"
    local repo_root
    if ! repo_root="$(git -C "$plan_dir" rev-parse --show-toplevel 2>/dev/null)"; then
        echo "[plan] Rule 27.3: 非 git 仓库,跳过 porcelain 预检"
        return 0
    fi

    # 状态机式 awk 抽取「执行范围限制」节,再分离表头找"允许的文件"列号
    local section_file
    section_file="$(mktemp)"
    awk '/^## .*执行范围限制/{f=1; next} /^## /{f=0} f' "$plan" > "$section_file" 2>/dev/null
    # 找表头行 + 列号
    local header_line allow_col
    header_line="$(grep -m1 -E '^\|[[:space:]]*类别' "$section_file" 2>/dev/null || grep -m1 -E '^\|[[:space:]]*类型' "$section_file" 2>/dev/null)"
    if [ -z "$header_line" ]; then
        rm -f "$section_file"
        echo "[plan] Rule 27.3: 范围限制节缺少表头行,跳过"
        return 0
    fi
    allow_col="$(printf '%s' "$header_line" | awk -F'|' '
        {
            for (i=2; i<NF; i++) {
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
                if ($i ~ /允许的文件|允许文件|Allowed/) { print i; exit }
            }
        }')"
    if [ -z "$allow_col" ]; then
        rm -f "$section_file"
        echo "[plan] Rule 27.3: 未识别到「允许的文件」列,跳过"
        return 0
    fi

    # 提取候选:取第 allow_col 列 → 剥 markdown 修饰 → 切词 → 过滤路径 token
    local candidates
    candidates="$(awk -F'|' -v c="$allow_col" '
        NR > 1 && /^\|/ && !/^[[:space:]]*\|?[[:space:]]*-[[:space:]]*\|/ {
            v=$c
            gsub(/`/, "", v)
            gsub(/\*\*/, "", v)
            gsub(/[（(][^）)]*[)）]/, "", v)
            # 2026-09-06 task-v053: 切词集补 、(U+3001) — 真实计划 scope 表用顿号分隔,漏切会把两路径粘成单 token(git pathspec 无匹配 → 假 clean)
            n=split(v, arr, /[[:space:]]+|[,，;；、]/)
            for (i=1; i<=n; i++) {
                tok=arr[i]
                # 2026-09-06 task-v053: 排除仓外路径(~前缀/绝对路径) — git pathspec 遇仓外路径整体 fatal,porcelain 恒空 → 假 clean(实测 skills/... 与 /home/... 混合即触发)
                # 2026-09-06 task-v053: 路径判定放宽为"含 / 或 ." — 裸文件名(tracked.md 类,无斜杠)此前被丢弃 → 脏文件漏检(实测)
                if ((tok ~ /[\/.]/) && tok !~ /^[~\/]/) print tok
            }
        }' "$section_file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | awk 'NF>0' | sort -u)"

    rm -f "$section_file"

    if [ -z "$candidates" ]; then
        echo "[plan] Rule 27.3: 范围限制列表为空,跳过 porcelain 预检"
        return 0
    fi

    # git status --porcelain 仅对候选路径(逐行展开为 args)
    local porcelain
    # shellcheck disable=SC2086
    porcelain="$(git -C "$repo_root" status --porcelain -- $candidates 2>/dev/null)"
    if [ -n "$porcelain" ]; then
        echo "[plan] Rule 27.3 violation: scope 内存在未提交变更"
        printf '%s\n' "$porcelain" | sed 's/^/[plan]   /'
        return 1
    fi
    echo "[plan] Rule 27.3: porcelain clean ($(printf '%s\n' "$candidates" | wc -l) scope path(s) verified)"
    return 0
}

# 仅当 plan 文件存在时跑预检(无 plan 场景由上方 early-exit 处理,此处不影响)
check_scope_porcelain "$PLAN_FILE" || {
    rc=$?
    if [ "$rc" -eq 1 ]; then
        exit 1
    fi
}

# [2026-09-04 Rule 19.5/19.6] Pass SKILL_ROOT so python can load templates/findings.md
# and templates/progress.md for stub detection in 3-File Gate.
    SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    PLAN_DIR_GUESS="$(cd "$(dirname "$PLAN_FILE")" && pwd)"
    # [2026-09-13 task-v065 T-3 V-9] VC-GATE 档位解析共用 config 路径
    CONFIG_JSON="$SKILL_ROOT/config.json"

    # [2026-10-11 task-v167 Rule 38.7] 执行通道（lane）消费: 计划头解析 execution_lane: L0|L1|L2（缺省 L1=
    # 逐行执行现状，零行为变化）。lane=执行通道，与 plan_tier=模板轻重正交（同计划可并存）。
    # L0=微变更通道（38.7）: 跳过的是重复验证项（thin），保留的是完成性底线（porcelain/report-lint/
    # goal-gate/pointer-lifecycle/SKILL-MODIFY + LANE-L0 GATE 三件校验绝不跳）。
    LANE_L0=0
    grep -qm1 -E 'execution_lane:[[:space:]]*L0' "$PLAN_FILE" 2>/dev/null && LANE_L0=1
    # [task-v167] L0 门入口守卫: L0 → return 0（门体可跳, skip 行在 stderr）; L1/L2 → return 1
    # （门体须执行, 逐行执行现状零变化）。调用范式: if ! l0_gate_open "..."; then <门体>; fi
    # （!取反: L0→!0=1→门体不执行=skip; L1→!1=0→门体执行——CR 修正 2026-10-11: 原 return 方向
    # 与调用方取反语义不匹配致 L0 误执行 DELEGATION 门体, 本处对齐「成功=可跳」语义）
    l0_gate_open() { [ "${LANE_L0:-0}" = 1 ] && { printf '[lane-L0] skip %s（38.7 非适用项, thin=跳重复验证项, 保留完成性底线）\n' "$1" >&2; return 0; }; return 1; }

    # ── [2026-10-16 P-04] STATE-CONSISTENCY GATE — 计划状态三源一致性前置 shell-out（仿 :431 DELEGATION 先例）──
    # What: 总门前置调用 check-state-consistency.sh（checkbox↔Status↔progress 交叉），拦截 caseB-textonly
    #       型「纸面证据链完整但现实未完成」假 COMPLETE（Phase **Status:** complete 但 checkbox 未勾 /
    #       progress 同名段仍 in_progress 且无 [goal:G 完成证据行）。诊断行走 stdout 中继；默认 enforce=exit 1。
    # Why: 既有解析器(:181-213)只读 `**Status:**` 行, 无 checkbox↔Status、plan↔progress 交叉比对——
    #      未勾却称 complete 的 Phase 可静默放行（探测·完成声称 caseB-textonly 全门 EXIT=0 根因）。
    # 约束: 纯计划内三源文本交叉(无外部路径/词表依赖); L0 微变更通道 skip(38.7 thin, l0_gate_open 守卫);
    #       脚本缺失 fail-open(不阻断终验)。
    if ! l0_gate_open "STATE-CONSISTENCY GATE (P-04 三源一致性——L0 thin 无 checkbox↔Status 簿记面)"; then
        sc_gate="$SKILL_ROOT/scripts/check-state-consistency.sh"
        if [ -f "$sc_gate" ]; then
            sc_out="$(bash "$sc_gate" "$PLAN_FILE" 2>/dev/null)"
            sc_rc=$?
            [ -n "$sc_out" ] && printf '%s\n' "$sc_out"
            if [ "$sc_rc" -eq 1 ]; then
                printf '[plan] STATE-CONSISTENCY GATE FAILED (P-04: 计划状态三源不一致 checkbox↔Status↔progress, 详见上方 [state-mismatch] 逐条)\n' >&2
                exit 1
            fi
        else
            printf '[state-consistency] ⚠ 门脚本缺失（fail-open 不阻断终验）: %s\n' "$sc_gate" >&2
        fi
    fi

    # [2026-09-07 task-v055 task-v055/Phase 3] 终验委派率接线(Rule 25.4)
# 行为:全 Phase complete 判定通过前,调 check-delegation.sh stats 输出 JSON。
# - verdict==violation  或  全 complete 且 delegation_rate < floor  或  main_direct 含 violations
#   → 摘要输出到 stderr + exit 1(禁止 COMPLETE 交付)
# - stats 命令自身失败(jq/解析/脚本异常)= fail-open:stderr 一行警告,不阻断(与 A 批约定一致)
# - 顺带输出 warn 档触发计数(/tmp/task-planner-warn-<sid>.count 若存在,提醒终验关注 M-1)
# 实现位置:放在 python 内联末尾之后(已通过 3-File Gate/Porcelain 等前置门),
# 所有判定放行后才查委派率 — 这是「最后一道闸」。
# [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
DELEGATION_RATE_FLOOR="$(jq -r '.delegation_rate_floor // .properties.delegation_rate_floor.default // 0.7' "$SKILL_ROOT/config.json" 2>/dev/null || echo 0.7)"
# [2026-09-20 task-v086 P2-S3 Rule 38.4③] mini 降档: 计划文件 grep「plan_tier: mini」命中 →
# floor 0.7→0.0（main_direct 全部理由视白名单直通, 即 rate 永远 >= floor）; violations 仍照常计(L441 verdict 路径不动);
# 非 mini 路径 DELEGATION_RATE_FLOOR 保持 config 原值=零改动
if grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
    DELEGATION_RATE_FLOOR="0.0"
fi

python3 - "$PLAN_FILE" "$SKILL_ROOT" "${LANE_L0:-0}" << 'PYEOF'
import sys, re

plan_file = sys.argv[1]
skill_root = sys.argv[2]
# [2026-10-11 task-v167 Rule 38.7] argv[3]=LANE_L0（1=L0 微变更通道）：L0 时 Batch Report 门与
# 3-File Gate 判定跳（38.7 thin：微变更无批量生成单元/无三文件簿记面），改由 LANE-L0 GATE
# 三段校验承载完成性；Phase 完成性判定本体零改动（L0 也必须全 Phase complete）。
LANE_L0 = (sys.argv[3] == "1") if len(sys.argv) > 3 else False
with open(plan_file, "r", encoding="utf-8") as f:
    lines = f.readlines()

content = "".join(lines)

# Detect chain_mode
# 2026-09-01 fix: value may contain hyphen (fan-out), original \w+ never matched it
chain_mode = "single"
for m in re.finditer(r'\|\s*\*\*chain_mode\*\*\s*\|\s*\x60?([\w-]+)\x60?\s*\|', content):
    if m.group(1) in ("linked", "fan-out"):
        chain_mode = m.group(1)
        break

# Segment on top-level --- separators
seg_bounds = []
cur = 0
for i, line in enumerate(lines):
    if line.strip().startswith("---"):
        seg_bounds.append((cur, i))
        cur = i + 1
seg_bounds.append((cur, len(lines)))
segments = [{"idx": si, "start": s, "end": e} for si, (s, e) in enumerate(seg_bounds)]

# Forward scan: find each Phase heading and its Status line
phase_entries = []
i = 0
while i < len(lines):
    stripped = lines[i].strip()
    if re.match(r'^###\s+Phase\s', stripped):
        ph_line = i
        status_txt = None
        i += 1
        while i < len(lines):
            ls = lines[i].strip()
            if re.match(r'^###\s+', ls) or ls.startswith("---"):
                break
            if ls.startswith("- **Status:**"):
                status_txt = ls
            i += 1
        phase_entries.append((ph_line, status_txt))
    else:
        i += 1

# Count per segment
seg_counts = {}
for seg in segments:
    seg_counts[seg["idx"]] = {"t": 0, "c": 0, "ip": 0, "p": 0}

for ph_line, status_txt in phase_entries:
    seg_idx = next((s["idx"] for s in segments if s["start"] <= ph_line < s["end"]), None)
    if seg_idx is None:
        continue
    sc = seg_counts[seg_idx]
    sc["t"] += 1
    if status_txt:
        if "**Status:** complete" in status_txt:
            sc["c"] += 1
        elif "**Status:** in_progress" in status_txt:
            sc["ip"] += 1
        elif "**Status:** pending" in status_txt:
            sc["p"] += 1

total = sum(s["t"] for s in seg_counts.values())
complete = sum(s["c"] for s in seg_counts.values())
in_progress = sum(s["ip"] for s in seg_counts.values())
pending = sum(s["p"] for s in seg_counts.values())

# Block config segments
block_config_segs = set()
for seg in segments:
    seg_text = "".join(lines[seg["start"]:seg["end"]])
    if re.search(r'^###\s+Block\s+\d+\s*:', seg_text, re.MULTILINE):
        block_config_segs.add(seg["idx"])

block_statuses = {}
for seg in segments:
    if seg["idx"] not in block_config_segs:
        continue
    seg_text = "".join(lines[seg["start"]:seg["end"]])
    for bm in re.finditer(r'^###\s+Block\s+(\d+)\s*:', seg_text, re.MULTILINE):
        bnum = bm.group(1)
        after = seg_text[bm.end():]
        sm = re.search(r'\|\s*\*\*status\*\*\s*\|\s*\x60?(\w+)\x60?\s*\|', after)
        if sm:
            block_statuses[bnum] = sm.group(1).strip().lower()

# Logical blocks for display
logical_blocks = []
for seg in segments:
    if seg["idx"] in block_config_segs:
        continue
    last = logical_blocks[-1] if logical_blocks else None
    if last is not None and last["segs"][-1] == seg["idx"] - 1:
        last["segs"].append(seg["idx"])
    else:
        logical_blocks.append({"segs": [seg["idx"]]})

if not logical_blocks and block_config_segs:
    logical_blocks = [{"segs": sorted(block_config_segs), "is_config_only": True}]

# Batch Report completeness check (Rule 18.6, v2.2.1)
# Trigger: chain_mode=fan-out OR plan contains a "Batch Report" section (batch task).
# Required 8 fields must be non-empty; empty value => treated as incomplete.
BATCH_FIELDS = ["total", "success", "failed", "failure_rate",
                "sampled_pass", "sampled_fail", "pre_check", "rollback_point"]
# [2026-10-11 task-v167] L0 时 Batch Report 门跳（微变更无批量生成单元, 38.7 thin）:
# 触发条件收紧为「非 L0 且 (fan-out 或 内容含 Batch Report)」——L0 计划即使内容提及
# 「Batch Report」字样也不强制 8 字段（提及字样常出现在规则引用中, 非真批量任务）。
batch_required = (chain_mode == "fan-out" or "Batch Report" in content) and not LANE_L0
batch_missing = []
if batch_required:
    bm = re.search(r'^##\s+.*Batch Report.*$', content, re.MULTILINE)
    if not bm:
        batch_missing = ["<entire Batch Report section>"]
    else:
        seg_text = content[bm.start():]
        nxt = re.search(r'^##\s+', seg_text[10:], re.MULTILINE)
        if nxt:
            seg_text = seg_text[:10 + nxt.start()]
        # [2026-09-16 task-v074 P9 Rule 18.6 零单元逃生] 段内整段声明「不适用（无批量生成单元）」
        # → 合法零单元声明, 跳过 8 字段校验; 否则维持既有 8 字段校验（fail-closed）
        if "不适用" in seg_text and "无批量" in seg_text:
            pass  # batch_missing stays []
        else:
            for fld in BATCH_FIELDS:
                fm = re.search(r'\|\s*`?' + re.escape(fld) + r'`?\s*\|\s*([^|\n]*)\s*\|', seg_text)
                val = (fm.group(1).strip() if fm else "")
                if not val:
                    batch_missing.append(fld)

# Display
for seg in segments:
    if seg["idx"] in block_config_segs:
        continue
    r = next((r for r in seg_counts.items() if r[0] == seg["idx"]), (seg["idx"], {"t":0,"c":0,"ip":0,"p":0}))
    st = "complete" if r[1]["c"] == r[1]["t"] and r[1]["t"] > 0 else ("in_progress" if r[1]["ip"] > 0 else "pending")
    print(f"  Segment {r[0]}: {r[1]['c']}/{r[1]['t']} phases ({st})")

for bnum, st in sorted(block_statuses.items(), key=lambda x: int(x[0])):
    print(f"  Block {bnum} config: {st}")

if chain_mode in ("linked", "fan-out"):
    print(f"[plan] chain_mode={chain_mode} ({len(logical_blocks)} block(s))")
    for lb in logical_blocks:
        segs = lb["segs"]
        is_config_only = lb.get("is_config_only", False)
        if is_config_only:
            done_c = sum(1 for bn, st in block_statuses.items() if st == "complete")
            print(f"  Block config: {done_c}/{len(block_statuses)} blocks complete")
        else:
            lt = sum(seg_counts[s]["t"] for s in segs)
            lc = sum(seg_counts[s]["c"] for s in segs)
            lip = sum(seg_counts[s]["ip"] for s in segs)
            st = "complete" if lc == lt and lt > 0 else ("in_progress" if lip > 0 else "pending")
            print(f"  Block: {lc}/{lt} phases ({st})")

# Exit code
# [2026-10-15 task-v176 D3] total==0（无任何 `### Phase N` 命中）改为 fail-closed exit 1：
# Why: Phase 标题变体（`## Phase 1:` 二级标题等，S2 缺陷5 fixture 实证 /tmp/s2-cc）使 :181 正则
#      不匹配 → total==0 → 原 fail-open exit 0 令 3-File/VC/goal-gate 全门链静默跳过 = 终验假 PASS
#      （最恶劣通道）。计划无效=先回炉，禁放行；报错走 stderr（对齐其他门 ✗ 行出口；stdout 保留
#      原 "No phases found" 行供 hook 既有解析零变动）。仅改此 fail-open 点，其余门逻辑不动。
if total == 0 and not block_statuses:
    print("[plan] No phases found in task_plan.md.")
    print("[plan] ✗ Phase 标题格式不匹配（要求 `### Phase N`）；计划无效先回炉，禁放行 (task-v176 D3: fail-closed, 原 exit 0=终验假 PASS 通道已封)", file=sys.stderr)
    sys.exit(1)

# Batch Report gate (Rule 18.6): incomplete fields block completion reporting

# Rule 23.6: fan-out 必须含 Aggregator Phase
aggregator_missing = []
if chain_mode == "fan-out":
    if not re.search(r'Phase\s+\d+:.*[Aa]ggregator', content) and not re.search(r'Phase\s+\d+:.*聚合', content):
        aggregator_missing = ["Aggregator Phase (Rule 23.6)"]

# [2026-09-04 Rule 19.5] 3-File Gate — findings.md / progress.md 必须存在且非模板 stub
# Why（task-v115 线C 补强）: 拦截「只建 task_plan.md 就声称完成」的三文件口径违背——findings/progress
# 是决策维/进度维承载面，缺失或仍是模板 stub（实质行<3）= 计划声称的 Research/Actions 无处落盘，
# 终验必须挡住。仅在 plan 目录有 Phase 内容（total>0 或 block_statuses 非空）时生效。
# 模板路径来自 argv[2]（SKILL_ROOT），缺失则跳过 stub 判定只检查文件存在。
import os
plan_dir = os.path.dirname(os.path.abspath(plan_file))
three_file_gate_active = (total > 0) or bool(block_statuses)
# [2026-10-11 task-v167 Rule 38.7] L0 thin: 3-File Gate 判据不要求 findings/progress 非 stub——
# 微变更通道簿记精简（38.7「单 commit+薄 verification」），findings/progress 允许模板 stub 原样；
# L1/L2 判定零改动（LANE_L0=False 时 active 语义与原版逐字节等价）。
if three_file_gate_active and not LANE_L0:
    for name in ("findings.md", "progress.md"):
        target = os.path.join(plan_dir, name)
        if not os.path.isfile(target):
            print(f"[plan] 3-File Gate failed (Rule 19.5) — {name} missing in {plan_dir}")
            print(f"[plan] Fix: create {name} via init-session.sh or copy from templates/{name}.")
            sys.exit(1)
        # Stub 判定：相对模板文件统计「实质行数」（strip 后非空、不在模板行集合、不以 <!-- 开头）
        tpl_path = os.path.join(skill_root, "templates", name)
        if os.path.isfile(tpl_path):
            try:
                with open(tpl_path, "r", encoding="utf-8") as tf:
                    tpl_lines = {ln.strip() for ln in tf.readlines() if ln.strip()}
            except Exception:
                tpl_lines = set()
            with open(target, "r", encoding="utf-8") as pf:
                plan_lines_raw = pf.readlines()
            substantive = 0
            for ln in plan_lines_raw:
                s = ln.strip()
                if not s:
                    continue
                if s.startswith("<!--"):
                    continue
                if s in tpl_lines:
                    continue
                substantive += 1
            if substantive < 3:
                print(f"[plan] 3-File Gate failed (Rule 19.5) — {name} is still a template stub (substantive lines < 3), backfill required")
                print(f"[plan] Fix: Edit {name} with concrete findings/progress; templates/{name} is the reference skeleton.")
                sys.exit(1)

# [2026-09-04 Rule 19.6] task_plan.md 膨胀 WARNING（不阻断，提醒迁移细节到 findings.md）
if len(lines) > 500:
    print(f"[plan] WARNING: task_plan.md has {len(lines)} lines (>500, Rule 19.6) — offload research/decision details to findings.md")

if batch_missing:
    print(f"[plan] Batch Report incomplete (Rule 18.6) — missing: {', '.join(batch_missing)}")
    print("[plan] Batch tasks must fill all 8 fields before completion (templates/batch_report.md).")
    sys.exit(1)
if aggregator_missing:
    print(f"[plan] fan-out plan missing Aggregator Phase (Rule 23.6) — {', '.join(aggregator_missing)}")
    print("[plan] fan-out plans must have a Phase dedicated to collecting and verifying subtask results.")
    sys.exit(1)

if complete == total and total > 0:
    if chain_mode in ("linked", "fan-out"):
        all_blocks_done = all(
            (any(seg_counts[s]["c"] == seg_counts[s]["t"] and seg_counts[s]["t"] > 0 for s in lb["segs"]))
            or not any(seg_counts[s]["t"] > 0 for s in lb["segs"])
            for lb in logical_blocks if not lb.get("is_config_only")
        )
        all_config_done = all(st == "complete" for st in block_statuses.values()) if block_statuses else True
        if all_blocks_done and all_config_done:
            cfg_part = f" across {len(logical_blocks)} block(s)" if chain_mode != "single" else ""
            print(f"[plan] ALL PHASES COMPLETE{cfg_part} ({complete}/{total})")
            # [2026-09-07 task-v055] 透传 plan_dir 给 shell 层做委派率终验
            print(f"[plan-deferred-delegation-check] plan_dir={plan_dir}")
            sys.exit(0)
        else:
            print("[plan] Some blocks not yet complete.")
            sys.exit(1)
    else:
        print(f"[plan] ALL PHASES COMPLETE ({complete}/{total})")
        # [2026-09-07 task-v055] 透传 plan_dir 给 shell 层做委派率终验
        print(f"[plan-deferred-delegation-check] plan_dir={plan_dir}")
        sys.exit(0)
else:
    print(f"[plan] Task in progress ({complete}/{total} phases complete)")
    if in_progress > 0:
        print(f"[plan] {in_progress} phase(s) still in progress.")
    if pending > 0:
        print(f"[plan] {pending} phase(s) pending.")
    if chain_mode in ("linked", "fan-out"):
        print("[plan] NOTE: chain mode active — ensure all blocks are complete before finishing.")
    print("[plan] WARNING: Not all phases complete — session should not end yet.")
    sys.exit(1)
PYEOF
python_rc=$?

# [2026-09-07 task-v055] 终验委派率接线 — shell 层 last gate
# 仅当 python 返回 0(全 Phase complete 判定通过)时执行;否则放过(python 自己已 exit 1)
# Why（task-v115 线C 补强）: 委派统计/率门是最后一道闸（置于所有判定门之后）——拦截「主进程全程
# 亲做却报 done」的委派纪律违背（Rule 25.4 去口供化）；stats 输出不可用时 fail-open 但留 stderr 痕迹，
# 门控自身故障不得锁死正常终验（fail-open 方向=放行，错误必须曝光）。
if [ "$python_rc" -eq 0 ]; then
    # l0_gate_open: L0 → 打 skip 行并 return 1（拦门）; L1/L2 → return 0（原样执行门体）
    # 调用范式: if ! l0_gate_open "..."; then <门体>; fi（L0 跳门体, L1/L2 逐行执行现状）
    if ! l0_gate_open "DELEGATION GATE (Rule 25.4 委派率终验——L0 主进程直做单 Phase, 无委派统计面, 38.7 thin)"; then
    # 委托率统计(fail-open:脚本异常不阻断,但 stderr 记警告)
    stats_output=""
    if [ -x "$SKILL_ROOT/scripts/check-delegation.sh" ]; then
        stats_output="$(bash "$SKILL_ROOT/scripts/check-delegation.sh" stats "$PLAN_DIR_GUESS" 2>/dev/null)" || stats_rc=$?
        # stats_rc 非 0 = violation(stats 自身 exit 1)or 错误(exit 1/2);继续解析
    else
        printf '[check-complete] check-delegation.sh not found or not executable — fail-open\n' >&2
    fi

    if [ -n "$stats_output" ]; then
        # 解析 JSON(jq 不可用时改用 grep fallback;stats_output 总是单行 JSON)
        delegation_rate=""
        main_direct_count=0
        violations_count=0
        verdict=""
        if command -v jq >/dev/null 2>&1; then
            delegation_rate="$(printf '%s' "$stats_output" | jq -r '.delegation_rate // empty' 2>/dev/null || true)"
            main_direct_count="$(printf '%s' "$stats_output" | jq -r '.main_direct | length' 2>/dev/null || echo 0)"
            violations_count="$(printf '%s' "$stats_output" | jq -r '.violations | length' 2>/dev/null || echo 0)"
            verdict="$(printf '%s' "$stats_output" | jq -r '.verdict // empty' 2>/dev/null || true)"
        else
            # 无 jq 兜底:正则提取
            delegation_rate="$(printf '%s' "$stats_output" | grep -oE '"delegation_rate":[^,}]+' | head -1 | cut -d: -f2 || true)"
            violations_count="$(printf '%s' "$stats_output" | grep -oE '"violations":\[[^]]*\]' | head -1 | grep -oE '\{"type"' | wc -l || echo 0)"
            main_direct_count="$(printf '%s' "$stats_output" | grep -oE '"main_direct":\[[^]]*\]' | head -1 | grep -oE '\{"phase"' | wc -l || echo 0)"
            if [ "$violations_count" -gt 0 ]; then verdict="violation"; else verdict="ok"; fi
        fi

        # 1) verdict==violation → exit 1(主进程直做理由含白名单外/委派率违规)
        # 2) 全 complete 且 delegation_rate < floor → exit 1(规则底线)
        # 3) violations 非空 → exit 1(同上,verdict 已聚合)
        # floor 比较:rate 是浮点字符串,用 awk
        rate_ok=1
        if [ -n "$delegation_rate" ]; then
            # [2026-09-09 task-v057] 修复比较反转:原 exit !(r<f) 与外层 if ! 双重取反,导致 rate>=floor 判 FAIL、rate<floor 放行(4420c08 引入);现 awk 在 r<f 时 exit 1 → rate_ok=0
            if ! awk -v r="$delegation_rate" -v f="$DELEGATION_RATE_FLOOR" 'BEGIN{exit (r+0 < f+0)}'; then
                rate_ok=0
            fi
            # [2026-09-09 D6 / Rule 25.4] rate<floor 时白名单豁免:main_direct 全空或每条 reason 均命中
            # 白名单关键词(①git 编排/②计划系统文件/③机械验证/④用户显式/⑤兜底接管/⑥trivial)→ 放行。
            # 依据 critical-rules 25.4:「全部直做理由均在白名单内 → 不降级(编排/簿记型任务属正常形态)」。
            # 防过度放行:任一 reason 未命中白名单 → 保持 rate_ok=0 (FAILED 不变);jq 缺失 → fail-closed 不放行。
            whitelist_exempt=0
            if [ "$rate_ok" -eq 0 ]; then
                if [ "$main_direct_count" -eq 0 ]; then
                    whitelist_exempt=1
                elif command -v jq >/dev/null 2>&1; then
                    wl_match="$(printf '%s' "$stats_output" | jq -r '.main_direct[]? | .reason // empty' 2>/dev/null \
                        | grep -cE '白名单[①②③④⑤⑥]|git 编排|worktree|计划系统文件|三件套|机械验证|用户显式|兜底接管|trivial' || true)"
                    [ "${wl_match:-0}" -ge "$main_direct_count" ] && whitelist_exempt=1
                fi
                [ "$whitelist_exempt" -eq 1 ] && { rate_ok=1; printf '[plan] DELEGATION RATE WHITELIST-EXEMPT (rate=%s < floor=%s, main_direct=%s 条理由全白名单内, Rule 25.4 不降级)\n' "$delegation_rate" "$DELEGATION_RATE_FLOOR" "$main_direct_count" >&2; }
            fi
        fi

        # 摘要输出(stderr 给主进程可视化;stdout 保留 [plan] 标记给 hook 解析)
        printf '[plan-delegation] phases=%s delegated=%s main_direct=%s violations=%s rate=%s floor=%s verdict=%s\n' \
            "$(printf '%s' "$stats_output" | grep -oE '"phases_total":[0-9]+' | head -1 | cut -d: -f2)" \
            "$(printf '%s' "$stats_output" | grep -oE '"phases_delegated":[0-9]+' | head -1 | cut -d: -f2)" \
            "$main_direct_count" \
            "$violations_count" \
            "$delegation_rate" \
            "$DELEGATION_RATE_FLOOR" \
            "$verdict" >&2

        if [ "$verdict" = "violation" ] || [ "$rate_ok" -eq 0 ]; then
            printf '[plan] DELEGATION GATE FAILED (Rule 25.4 / task-v055) — verdict=%s rate=%s floor=%s\n' "$verdict" "$delegation_rate" "$DELEGATION_RATE_FLOOR" >&2
            printf '%s\n' "$stats_output" >&2
            exit 1
        fi
        printf '[plan] DELEGATION GATE PASSED (rate=%s >= floor=%s, violations=%s)\n' "$delegation_rate" "$DELEGATION_RATE_FLOOR" "$violations_count" >&2
    else
        printf '[plan] DELEGATION GATE SKIPPED — check-delegation.sh stats produced no output (fail-open, see warning above)\n' >&2
    fi
    fi
    # [2026-10-11 task-v167] L0 跳过后 stats_output 为空 → 既有条款按 fail-open SKIPPED 处理, 不 exit 1

    # ── [task-v172 CA-8] DRIFT-GATE: 纠偏子代理执行率机器可观测（默认 warn 不拦, 保持 77/77 回归基线）──
    # What: 全 complete 的多 Phase（≥2 个 `### Phase` 段 `**Status:** complete`）计划, subagent-state/ 下应
    #       存在 drift-checker 纠偏检查点（*drift* 文件）；缺失 → stderr 一行 warn；
    #       TASK_PLANNER_DRIFT_GATE_ENFORCE=enforce 且 outcome 非 BLOCKED → 追加升级文案行（仍不改 exit 码）。
    # Why: R5 实证 drift-checker 检查点 v160 后 10 任务零执行——执行率无人机器可观测；本块只增 stderr 痕迹,
    #      enforce 默认 off 由用户 env 收紧, 永不 hard-fail（避免破坏既有 77/77 基线）。
    # 约束: 不新增 config.json 键（env var 方案, 避免 17 文件键数锚级联）; L0（l0_gate_open 命中）/
    #       plan_tier=mini 跳过本块; fail-open（变量缺失/目录不可读/grep 异常 → 静默跳过）。
    # 位置: DELEGATION GATE 段之后（仍处 python_rc==0 全 complete 域内）, 零改动既有门序。
    if ! l0_gate_open "DRIFT GATE (task-v172 CA-8 纠偏执行率观测——L0 thin, 无纠偏统计面)" \
       && ! grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
      _dg_complete_phases="$(grep -cE '^\-?[[:space:]]*\*\*Status:\*\*[[:space:]]*complete' "$PLAN_FILE" 2>/dev/null || true)"
      case "${_dg_complete_phases:-}" in ''|*[!0-9]*) _dg_complete_phases=0 ;; esac
      _dg_drift_found=0
      [ -n "${PLAN_DIR_GUESS:-}" ] && [ -d "${PLAN_DIR_GUESS}/subagent-state" ] && ls "${PLAN_DIR_GUESS}/subagent-state/" 2>/dev/null | grep -q 'drift' && _dg_drift_found=1
      # 触发=≥2 个 Phase complete ∧ subagent-state/ 无任何 *drift* 检查点（目录缺失同判无检查点）
      if [ "$_dg_complete_phases" -ge 2 ] && [ "$_dg_drift_found" -eq 0 ]; then
        printf '[DRIFT-GATE] ⚠️ 已完成多 Phase 但无 drift-checker 纠偏检查点（v146 Rule 61 载体；建议复盘是否漏派，Rule 64.1 留痕三件套）\n' >&2
        # enforce 档: outcome 非 BLOCKED 时升级措辞（BLOCKED 计划纠偏复盘不适用, 保持 warn 行）; 仍不 hard-fail
        if [ "${TASK_PLANNER_DRIFT_GATE_ENFORCE:-}" = "enforce" ]; then
          _dg_blocked=0
          grep -qiE 'outcome:[[:space:]]*BLOCKED' "$PLAN_FILE" 2>/dev/null && _dg_blocked=1
          [ -f "${PLAN_DIR_GUESS:-}/verification.md" ] && grep -qiE 'outcome:[[:space:]]*BLOCKED' "${PLAN_DIR_GUESS:-}/verification.md" 2>/dev/null && _dg_blocked=1
          if [ "$_dg_blocked" -eq 0 ]; then
            printf '[DRIFT-GATE] ⛔ 应返工补派 drift-checker（TASK_PLANNER_DRIFT_GATE_ENFORCE=enforce；仅升级措辞，不改 exit 码）\n' >&2
          fi
        fi
      fi
    fi

    # ── [2026-09-27 task-v091 C-2] 终验重复门四元内容键 SKIP-BY-HASH(提案 §三 C-2 v3, efficiency-proposal.md:139-146)──
    # 现象=同一计划终验 2-3 轮反复全量重跑两道重复门(PLAN-DISPATCH/FMEA,27 脚本 65.7s/轮);
    # 原行为=两门每轮无条件必跑; 新行为=四元内容键全一致→两门 SKIP-BY-HASH 引用 attest 结果,余门照跑。
    # 四元键(任何位置不使用 mtime/size — touch -r 绕过窗口由键①内容哈希闭合):
    #   ① task_plan.md 实时内容 sha256,且须等于 .plan-attestation 锁定哈希(未锁定/不一致→不 SKIP,走全量)
    #   ② check-plan-dispatch.sh 整文件 sha256(门脚本变更→陈旧 SKIP 由键②闭合)
    #   ③ 本脚本「FMEA 门段」sha256 — 锚=下行 sed 在全文件中的首个锚匹配(即 sed 命令行自身,含锚字面量)
    #      至 task-v065 S-1 F-1 挽救门注释行; 实际覆盖键计算+两门+状态写入整段(提案 FMEA 段的超集:
    #      只增失效不漏失效,SKIP 逻辑自身变更亦使状态失效)
    #   ④ 两门实际消费 config 键全集生效值(v3 终审 #3): plan_tier_enforce / subagent.step_max_minutes /
    #      subagent.step_max_files / subagent.properties.step_max_steps / fmea_enforce;
    #      完整性守护= selftest-final-gate-hash.sh 程序化 grep 两脚本 jq .properties.* 消费集合==此枚举。
    #      tier 两键 env 覆盖(TASK_PLANNER_PLAN_TIER_ENFORCE/TASK_PLANNER_FMEA_ENFORCE)计入快照:
    #      env 改变生效值同样不 SKIP — 只收窄不扩大 SKIP 面,符合提案「无残留窗口」意图。
    # 状态文件= ${TMPDIR:-/tmp}/task-planner-final-gate-<plan_dir 哈希前16位>.state(两门全过后写入;
    #   门失败路径已在下方 exit 1 不到达写点=失败永不落状态; 损坏/缺失→读不出 fg_key→全量 fail-open
    #   并自愈重写; 放 /tmp 不在计划目录产生未跟踪文件污染 Rule 27.3 porcelain,先例
    #   /tmp/task-planner-warn-<sid>.count; 键①含内容哈希→同路径新计划/归档重建不会误 SKIP)。
    # attest 本体与 TAMPERED 分支、UPS:61/posttooluse 重锁零改动(提案护栏)。
    fg_state_id="$(printf '%s' "$PLAN_DIR_GUESS" | sha256sum | cut -c1-16)"
    FG_STATE_FILE="${TMPDIR:-/tmp}/task-planner-final-gate-${fg_state_id}.state"
    FG_PLAN_HASH="$(sha256sum "$PLAN_FILE" 2>/dev/null | awk '{print $1}')"
    FG_ATTEST_LOCK=""
    [ -f "$PLAN_DIR_GUESS/.plan-attestation" ] && FG_ATTEST_LOCK="$(grep -am1 '^plan_sha256=' "$PLAN_DIR_GUESS/.plan-attestation" 2>/dev/null | cut -d= -f2-)"
    cpl="$SKILL_ROOT/scripts/check-plan-dispatch.sh"
    FG_CPD_HASH="$(sha256sum "$cpl" 2>/dev/null | awk '{print $1}')"
    FG_FMEA_SEG_HASH="$(sed -n '/FMEA 门控终验点/,/失败挽救链路终验门控/p' "$SKILL_ROOT/scripts/check-complete.sh" 2>/dev/null | sha256sum | awk '{print $1}')"
    # 键④: 单次 jq 取五键生效值(与门内解析同式: 顶层覆盖优先→schema 默认→字面兜底; jq 失败→空串→键必变→全量 fail-safe)
    FG_CFG_CSV="$(jq -r '[.plan_tier_enforce // .properties.plan_tier_enforce.default // "warn",
                         .subagent.step_max_minutes // .properties.subagent.properties.step_max_minutes.default // "15",
                         .subagent.step_max_files // .properties.subagent.properties.step_max_files.default // "2",
                         .properties.subagent.properties.step_max_steps.default // "4",
                         .fmea_enforce // .properties.fmea_enforce.default // "warn"] | @csv' "$CONFIG_JSON" 2>/dev/null || true)"
    FG_CFG_SNAP="env_plan_tier=${TASK_PLANNER_PLAN_TIER_ENFORCE:-_}|env_fmea=${TASK_PLANNER_FMEA_ENFORCE:-_}|cfg=${FG_CFG_CSV}"
    FG_KEY="$(printf '%s\n%s\n%s\n%s\n' "$FG_PLAN_HASH" "$FG_CPD_HASH" "$FG_FMEA_SEG_HASH" "$FG_CFG_SNAP" | sha256sum | awk '{print $1}')"
    FG_SKIP=0
    if [ -n "$FG_ATTEST_LOCK" ] && [ "$FG_ATTEST_LOCK" = "$FG_PLAN_HASH" ] && [ -f "$FG_STATE_FILE" ]; then
        FG_STORED="$(grep -am1 '^fg_key=' "$FG_STATE_FILE" 2>/dev/null | cut -d= -f2-)"
        [ -n "$FG_STORED" ] && [ "$FG_STORED" = "$FG_KEY" ] && FG_SKIP=1
    fi

    # [2026-09-09 task-v058] 计划期 S-unit 执行体终验门控(Rule 22.6/25.1);check-plan-dispatch.sh 缺失 → fail-open
    # [2026-09-27 task-v091 C-2] 四元键一致 → SKIP-BY-HASH 引用 attest 锁定结果(不重扫;余门照跑)
    if [ "$FG_SKIP" -eq 1 ]; then
        printf '[plan] PLAN-DISPATCH GATE SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果)\n' >&2
    elif [ -f "$cpl" ]; then bash "$cpl" "$PLAN_FILE" || { echo "[plan] PLAN-DISPATCH GATE FAILED (Rule 22.6/25.1)" >&2; exit 1; }; fi

    # [2026-09-16 task-v075 P4 B1] FMEA 门控终验点(fmea_enforce 双点消费之二,与 attest-plan.sh 同逻辑):
    # 档位解析范式同本文件既有 resolve_*_tier 段: env TASK_PLANNER_FMEA_ENFORCE > config.json fmea_enforce.default > warn
    # off=完全跳过无输出; warn=违规打 [fmea-gate] ⚠ 后继续; enforce=打 [fmea-gate] ✗ 后终验 FAIL(exit 1)
    # 判定口径与 attest-plan.sh check-fmea-gate 一致(KQ2): 含「FMEA 预演」段 + RPN 表数据行(第 6 数据列纯数字)≥1
    #   + RPN>100 行第 7 数据列(预设兜底动作)trim 后非空; legacy(无 Executor 行)fail-open 跳过
    resolve_fmea_tier() {
        local m="${TASK_PLANNER_FMEA_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ]; then
            # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
            m="$(jq -r '.fmea_enforce // .properties.fmea_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    FMEA_TIER="$(resolve_fmea_tier)"
    # [2026-10-11 task-v167 Rule 38.7] L0 skip FMEA GATE（Why: FMEA=子代理派发预演门, L0 单 Phase
    # 主进程直做无派发面, 38.7 非适用项; 保留线=LANE-L0 GATE 全量终验锚不跳）
    [ "${LANE_L0:-0}" = 1 ] && { printf '[lane-L0] skip FMEA GATE（38.7 非适用项: L0 主进程直做无派发面）\n' >&2; FMEA_TIER="off"; }
    # [2026-09-27 task-v091 C-2] 四元键一致 → SKIP-BY-HASH 引用 attest 锁定结果(键④已含 fmea_enforce 生效值)
    if [ "$FG_SKIP" -eq 1 ]; then
        printf '[fmea-gate] SKIP-BY-HASH (task-v091 C-2: 四元内容键一致, 引用 attest 锁定结果, fmea_enforce=%s)\n' "$FMEA_TIER" >&2
    elif [ "$FMEA_TIER" != "off" ] && grep -qE '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null; then
        # FMEA 判定(与 attest-plan.sh check-fmea-gate 同口径; 独立实现避免 source 依赖):
        fmea_datanum=0
        fmea_bad=""
        while IFS= read -r fmline; do
            [ -n "$fmline" ] || continue
            fmrpn="$(printf '%s\n' "$fmline" | awk -F'|' '{v=$7; gsub(/^[ \t]+|[ \t]+$/, "", v); print v}')"
            case "$fmrpn" in (*[!0-9]*|'') continue ;; esac
            fmea_datanum=$((fmea_datanum + 1))
            if [ "$fmrpn" -gt 100 ]; then
                fmfb="$(printf '%s\n' "$fmline" | awk -F'|' '{v=$8; gsub(/^[ \t]+|[ \t]+$/, "", v); print v}')"
                [ -z "$fmfb" ] && fmea_bad="${fmea_bad}RPN=${fmrpn}(兜底动作列空) "
            fi
        done < <(grep '^|' "$PLAN_FILE" 2>/dev/null)
        if ! grep -q 'FMEA 预演' "$PLAN_FILE" 2>/dev/null; then
            fmea_fail="无「📊 FMEA 预演」段标题"
        elif [ "$fmea_datanum" -lt 1 ]; then
            fmea_fail="RPN 表数据行=0(须 ≥1)"
        elif [ -n "$fmea_bad" ]; then
            fmea_fail="RPN>100 行缺预设兜底: ${fmea_bad% }"
        else
            fmea_fail=""
        fi
        if [ -n "$fmea_fail" ]; then
            case "$FMEA_TIER" in
                enforce)
                    echo "[fmea-gate] ✗ FMEA 门控失败: $fmea_fail (fmea_enforce=enforce, 补 FMEA 段数据行/兜底后重跑)" >&2
                    exit 1
                    ;;
                *)
                    echo "[fmea-gate] ⚠ FMEA 门控警告: $fmea_fail (warn 档不阻断: TASK_PLANNER_FMEA_ENFORCE=enforce 或 config.json fmea_enforce=enforce 可升级)" >&2
                    ;;
            esac
        else
            echo "[fmea-gate] OK (fmea_enforce=$FMEA_TIER)" >&2
        fi
    fi

    # [2026-09-29 task-v096 P4-S1 T3] template-sense warn 抽查段（Rule 34.7 全自动生成合约，
    # fmea-gate warn 范式：不阻断、零新 config 键）：
    # 计划含「🔁 模板感知」区块（init-session 运行时追加）且「处置登记处」未填写
    # （「不沉淀理由 / 沉淀理由」冒号后带实质内容方命中; 占位行关键词后无冒号不命中）
    # → 单行 warn；已登记 → 零输出。
    # [task-v096 CR-fix P2] 排除式收紧: 去掉无锚定「已沉淀」字面量（原式致计划任意处提及
    # 「已沉淀 3 个 variant」即静默吞 warn, 边缘误抑制）。剩余 fail-open 裁量: 仅当冒号前
    # 关键词与冒号间仅空白（不隔其他字）才排除 warn；「不沉淀理由: 无沉淀价值」等带实质
    # 内容必命中排除=登记有效，属既有语义保留。
    if grep -q '🔁 模板感知' "$PLAN_FILE" 2>/dev/null \
       && ! grep -qE '不沉淀理由[[:space:]]*[:：][^[:space:]]|沉淀理由[[:space:]]*[:：][^[:space:]]' "$PLAN_FILE" 2>/dev/null; then
        echo '[template-sense] ⚠ 计划含模板感知区块但终验未登记沉淀/不沉淀理由（Rule 34.7 全自动生成合约）' >&2
    fi

    # [2026-09-27 task-v091 C-2] 两门全过(全量通过,或本轮按四元键 SKIP)→ 写四元键状态供下轮 SKIP 判定;
    # 门失败路径已在上方 exit 1 不会到达此处=失败永不落状态; 状态文件不含 mtime/size(提案护栏)。
    # 写入前置 attest 一致: SKIP 语义=引用 attest 结果,为 attest 不匹配(篡改/未锁定)的内容落状态
    # 无复用价值且会污染已还原内容的复用键 — 篡改轮一律不写,保持状态=最近一次 attest 一致的全量通过条件
    if [ "$FG_SKIP" -ne 1 ] && [ -n "$FG_ATTEST_LOCK" ] && [ "$FG_ATTEST_LOCK" = "$FG_PLAN_HASH" ]; then
        printf 'fg_key=%s\nfg_v=1\nkey1_plan_sha256=%s\nkey2_cpd_sha256=%s\nkey3_fmea_seg_sha256=%s\nkey4_cfg_snap=%s\n' \
            "$FG_KEY" "$FG_PLAN_HASH" "$FG_CPD_HASH" "$FG_FMEA_SEG_HASH" "$FG_CFG_SNAP" > "$FG_STATE_FILE" 2>/dev/null || true
    fi

    # [2026-09-13 task-v065 S-1 F-1] 失败挽救链路终验门控(挽救而非摆烂);缺失 → fail-open
    # 档位由 check-rescue-chain.sh 自解析(config.json rescue_chain_enforce, 默认 warn):
    #   enforce 档存在违规 → 该脚本 exit 1 → 本门阻断 complete;warn/off 档恒 exit 0(仅提示)。
    # exit 2(参数错误)不阻断(避免门控自身配置问题锁死终验)。
    crc="$SKILL_ROOT/../task-dispatch/scripts/check-rescue-chain.sh"
    if [ -f "$crc" ]; then
        bash "$crc" "$PLAN_DIR_GUESS"
        crc_rc=$?
        if [ "$crc_rc" -eq 1 ]; then
            echo "[plan] RESCUE-CHAIN GATE FAILED (task-v065 F-1: failed/timeout 行缺 rescue 留痕/checkpoint)" >&2
            exit 1
        fi
    fi

    # [2026-09-13 task-v065 T-3 V-9] 终验 VC/V-N 门控（goal-gate.md 规 1/2）:
    # VC 表 ≥5 条 且 每个 Phase 段 V-N 映射 ≥2 条（映射目标须为已定义 VC 编号）。
    # 缺映射行即告警（v065 计划自身 8VC/0V-N 即实例——计划可以有 0 条 V-N 也过终验的漏洞）。
    # 档位: env TASK_PLANNER_VC_GATE_ENFORCE > config.json vc_gate_enforce > fail-open warn
    # warn=仅 stderr 警告 / enforce=exit 1 阻断 complete / off=跳过；脚本自身异常 → fail-open warn
    # Why（task-v115 线C 补强）: 本门拦截「VC 表形同虚设」——没有 V-N 映射的验证契约等于没写：
    # Phase 完成与否与声明的 Verification Contract 脱钩，主进程可以按自己的口径报完成。
    # 映射目标必须 ∈ 已定义 VC 编号，防止映射到不存在的 VC（自造编号即造假）；
    # mini 档降阈值（5→2/2→1）是 Rule 38.4② 体量豁免，不是放松 fail-closed 判定逻辑。
    resolve_vc_gate_tier() {
        local m="${TASK_PLANNER_VC_GATE_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if ! command -v jq >/dev/null 2>&1 || [ ! -f "$CONFIG_JSON" ]; then
            printf 'warn'
            return 0
        fi
        # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
        m="$(jq -r '.vc_gate_enforce // .properties.vc_gate_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }

    VC_GATE_TIER="$(resolve_vc_gate_tier)"

    # ── [2026-10-16 P-01 (终审意见 7)] EVIDENCE-ANCHOR GATE 档位解析 + shell-out 封装 ──────────
    # What: 前置调用 check-evidence-anchor.sh（证据锚真实性检查：存在性+行界+否定 trim+provenance 三层），
    #       两个调用点=R-COVERAGE 段前置（--source=coverage, 校 delivery-summary 证据格）
    #       + goal-gate 段前置（--source=goal, 校 progress.md [goal:Gn] 证据行）。
    # Why（接线不得挂起 / 终审意见 3）: 新门若只交付脚本不接线 = 复刻 periodic-review「发货即死」模式
    #       （脚本在位而无人调用，痛点照旧）。故本提案把接线与脚本同批交付，仿 :431 check-delegation.sh
    #       先例（shell-out + fail-open），**唯一差异点=诊断不裹 2>/dev/null**：原 stats 调用
    #       `2>/dev/null` 会把门控自身故障吞成静默（错误必须曝光 §五），且诊断丢失=门控变哑巴。
    #       本封装：脚本 stdout（[evidence-anchor] 明细）捕获后中继（PASS 走 stdout / FAIL 走 stderr，
    #       即「shell-out 诊断走 stdout」+ 终验 FAIL 归 stderr 双满足）；脚本 stderr 直通不抑制。
    # 档位: env TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE > config.json 顶层 > .properties 默认 > enforce
    #       （与 vc_gate_enforce 双层路径解析同范式；jq/config 缺失 → 回落 enforce，不静默降级为 warn）。
    # fail-open 方向: 脚本缺失 / rc=2 输入异常 → 一行 stderr 痕迹 + 放行（门控自身故障不得锁死正常终验）。
    resolve_evidence_anchor_tier() {
        local m="${TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if ! command -v jq >/dev/null 2>&1 || [ ! -f "$CONFIG_JSON" ]; then
            printf 'enforce'
            return 0
        fi
        m="$(jq -r '.evidence_anchor_enforce // .properties.evidence_anchor_enforce.default // "enforce"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'enforce' ;; esac
    }
    EVIDENCE_ANCHOR_TIER="$(resolve_evidence_anchor_tier)"

    # run_evidence_anchor <coverage|goal> — shell-out 本门并按档位裁决（enforce=exit 1 / warn=仅告警）
    run_evidence_anchor() {
        local src="$1" ea_out ea_rc
        [ "$EVIDENCE_ANCHOR_TIER" = "off" ] && return 0
        if [ ! -f "$SKILL_ROOT/scripts/check-evidence-anchor.sh" ]; then
            printf '[evidence-anchor] ⚠ 门脚本缺失（fail-open 不阻断）: %s\n' \
                "$SKILL_ROOT/scripts/check-evidence-anchor.sh" >&2
            return 0
        fi
        ea_out="$(bash "$SKILL_ROOT/scripts/check-evidence-anchor.sh" "$PLAN_DIR_GUESS" "--source=$src")"
        ea_rc=$?
        if [ "$ea_rc" -eq 2 ]; then
            printf '[evidence-anchor] ⚠ 输入异常 rc=2（fail-open 不阻断，source=%s）\n' "$src" >&2
            return 0
        fi
        if [ "$ea_rc" -eq 0 ]; then
            # PASS 走 stdout（shell-out 诊断走 stdout；终验可读「证据锚条数」作为交付证据）
            printf '%s\n' "$ea_out"
            return 0
        fi
        # FAIL: 明细中继到 stderr（终验 FAIL 归 stderr 是本仓门控惯例；P-01 verify ① 以
        # 「stderr 含 [evidence-anchor]」为验收面，此行为其机器锚点）
        printf '%s\n' "$ea_out" >&2
        case "$EVIDENCE_ANCHOR_TIER" in
            enforce)
                printf '[evidence-anchor] ✗ EVIDENCE-ANCHOR FAILED (P-01 终审意见 7, evidence_anchor_enforce=enforce, source=%s): 证据锚不真实或不归属本任务产出物（系统路径/死路径/行号越界/域外/机器落盘头缺失）— 拒 COMPLETE: 把证据格与 [goal:Gn] 证据行改为真实可定位路径（或补 run-verification.sh 落盘 evidence/VC-N.out）后重跑\n' \
                    "$src" >&2
                exit 1
                ;;
            *)
                printf '[evidence-anchor] ⚠ EVIDENCE-ANCHOR WARNING (P-01, warn 档不阻断: TASK_PLANNER_EVIDENCE_ANCHOR_ENFORCE=enforce 或 config.json evidence_anchor_enforce=enforce 可升级, source=%s)\n' \
                    "$src" >&2
                ;;
        esac
        return 0
    }

    # [2026-09-20 task-v086 P2-S3 Rule 38.4②] mini 档降档: 判定前置 grep 计划文件(init 复制产物)
    # 「plan_tier: mini」(standard 模板标记 plan_tier: standard 天然不命中);
    # mini: VC 最低 5→2 / 每 Phase V-N 阈值 2→1 / 无 V-N 映射行不阻断; 非 mini 变量取原值=零改动
    PLAN_TIER_MINI=0
    grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null && PLAN_TIER_MINI=1
    vc_min=5; [ "$PLAN_TIER_MINI" = 1 ] && vc_min=2
    vn_thresh_base=2; [ "$PLAN_TIER_MINI" = 1 ] && vn_thresh_base=1
    # [2026-10-11 task-v167 Rule 38.7] L0 薄化 VC-GATE: 只校验「VC 表存在(≥1) + 每 Phase V-N
    # 映射存在(≥1) + 映射目标 ∈ 已定义 VC」——跳过 ≥5/≥2 计数（38.7 薄 verification 三段之
    # 「VC 表」即存在性校验, 不降 fail-closed 判定逻辑; L1/L2 零改动）
    if [ "${LANE_L0:-0}" = 1 ]; then
        vc_min=1; vn_thresh_base=1
        printf '[lane-L0] skip VC-GATE 计数阈值(≥5/≥2→≥1/≥1, 38.7 薄化=只校验 VC 表存在且 Phase V-N 映射存在)\n' >&2
    fi
    if [ "$VC_GATE_TIER" != "off" ]; then
        vc_gate_section="$(mktemp)" || vc_gate_section="$(pwd)/.vc-gate-section.$$"
        # Phase 段 = `### Phase` 标题到下一 Phase/二级标题/--- 段边界（与 python 段切同口径）
        awk '/^###[[:space:]]+Phase[[:space:]]/{f=1;next}
             /^###|^##[[:space:]]|^---[[:space:]]*$/{f=0} f' "$PLAN_FILE" > "$vc_gate_section" 2>/dev/null

        # V-N 条目行 = verification 风格 `- [ ] V-P.N:`（占位/勾选/已完成均计；段边界外映射不计）
        # [2026-09-15 task-v074 P8 D11] 并集第二模式：v065 起现行计划用紧凑格式 `- **V-N:** VC-1, VC-2`
        #   （整行映射、无描述列）——原模式恒计 0 → VC-GATE 形同虚设（P1-3 诊断）；
        #   紧凑格式要求该 Phase 段内 ≥1 条即计（行去重）。两模式并集，不放松既有校验。
        # [task-v074 P8 D11] 紧凑格式语义：v065 起现行计划每 Phase 段仅 1 条 `- **V-N:** VC-x, VC-y`
        #   映射行（整行映射，非逐 P-N 条目；该段无逐 P-N 行）→ 1 条即实质达标；
        #   逐 P-N 格式（- [x] V-P.N:）保持 ≥2 语义（vn_total>vn_sub 判 target_bad 仅对其生效）。
        #   既有 `- [x] V-P.N:` 格式校验与映射目标 ∈ vc_defs 校验全部保留，不放松。
        vcgate_grep_map() {
            { grep -E '^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-[0-9]+\.[0-9]+\s*[:：]' "$1" 2>/dev/null \
              || true; \
              grep -E '^[[:space:]]*-[[:space:]]*\*\*V-N:[[:space:]]*\*\*.*VC-[0-9]+' "$1" 2>/dev/null \
              || true; } | grep -cE '^[[:space:]]*-[[:space:]]*(\[[ xX]\]| \*\*V-N:)' || true
        }
        # 模板占位识别（对齐 3-File Gate stub 判定口径）：V-N 行 strip 后 ∈ 模板行集合 → 非实质
        VN_TPL_LINES="$(sed 's/[[:space:]]*$//' "$SKILL_ROOT/templates/verification.md" 2>/dev/null | grep -E '^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-[0-9]+\.[0-9]+|^$' | sed 's/^[[:space:]]*//' | sort -u)"

        vcgate_count_substantive() {   # <段文件> <P号> <vc_defs> — 该 Phase 实质 V-N 映射数（剔除模板占位残留）
            local pf="$1" p="$2" vcd="$3" n=0
            local compact_seen=0 compact_def
            # [task-v074 P8 D11] 紧凑模式 `- **V-N:**` 整段仅 1 行（去重计数）；
            # 该行引用的全部 VC token 须 ∈ 已定义 VC，任一缺失 → 整段判 0（保持 fail-closed 语义）
            compact_def="$(grep -E '^[[:space:]]*-[[:space:]]*\*\*V-N:[[:space:]]*\*\*.*VC-[0-9]+' "$pf" 2>/dev/null \
                | grep -oE 'VC-[0-9]+' | sort -u || true)"
            while IFS= read -r ln; do
                [ -n "$ln" ] || continue
                case "$ln" in
                    '- **V-N:'*)
                        [ "$compact_seen" = 0 ] || continue
                        compact_seen=1
                        if [ -n "$vcd" ]; then
                            if [ -n "$compact_def" ] && printf '%s\n' "$compact_def" | grep -qxF -f <(printf '%s\n' "$vcd") 2>/dev/null; then
                                n=$((n + 1))
                            fi
                        else
                            n=$((n + 1))
                        fi
                        continue ;;
                esac
                if [ "$VN_TPL_LINES" != "" ] && printf '%s\n' "$VN_TPL_LINES" | grep -qxF -- "$ln"; then
                    continue
                fi
                n=$((n + 1))
            done < <({ grep -E '^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-'"$p"'\.[0-9]+\s*[:：]' "$pf" 2>/dev/null \
                         || true; \
                         grep -E '^[[:space:]]*-[[:space:]]*\*\*V-N:[[:space:]]*\*\*.*VC-[0-9]+' "$pf" 2>/dev/null \
                         || true; } | sed 's/^[[:space:]]*//')
            printf '%s' "$n"
        }

        vc_gate_fail=0
        # 1) VC 总数（v065 计划实测格式: `| VC-1 |...` 数据行；锚定首列为 VC-N，避免误匹配其他表格行）
        vc_count="$(grep -cE '^\|[[:space:]]*VC-[0-9]+' "$PLAN_FILE" 2>/dev/null || true)"
        vc_count="${vc_count:-0}"
        # 2) 已定义 VC 编号集合（映射目标校验用）
        vc_defs="$(grep -oE '^\|[[:space:]]*VC-[0-9]+' "$PLAN_FILE" 2>/dev/null | grep -oE 'VC-[0-9]+' | sort -u || true)"
        # 3) 逐 Phase 段查 V-N 映射（按段内 ### Phase 标题序编号 P1..Pn；
        #    segf = 「第 P 个 Phase 标题」到「第 P+1 个 Phase 标题」之间，段尾由 grep -m 行差截取）
        p_no=0
        vc_bad_phases=""
        phase_titles="$(grep -nE '^###[[:space:]]+Phase' "$PLAN_FILE" 2>/dev/null | cut -d: -f1 || true)"
        if [ -n "$phase_titles" ]; then
            mapfile -t phase_lines_arr <<< "$phase_titles"
            while IFS= read -r start_ln; do
                p_no=$((p_no + 1))
                if [ "$p_no" -lt "${#phase_lines_arr[@]}" ]; then end_ln="${phase_lines_arr[$p_no]}"; else end_ln=""; fi
                segf="$(mktemp)" || continue
                if [ -n "$end_ln" ]; then
                    sed -n "${start_ln},$((end_ln - 1))p" "$PLAN_FILE" > "$segf" 2>/dev/null
                else
                    sed -n "${start_ln},\$p" "$PLAN_FILE" > "$segf" 2>/dev/null
                fi
                vn_total="$(vcgate_grep_map "$segf")"
                vn_sub="$(vcgate_count_substantive "$segf" "$p_no" "$vc_defs")"
                # [task-v074 P8 D11] 紧凑段（无逐 P-N 行，段内存在 - **V-N:** 映射行）→ 1 条即达标；
                # 逐 P-N 段保持 ≥2 语义不变（segf 在 rm 前探测）
                _p_no_grep="$(grep -cE '^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-'"$p_no"'\.[0-9]+\s*[:：]' "$PLAN_FILE" 2>/dev/null || true)"
                _compact_grep="$(grep -cE '^[[:space:]]*-[[:space:]]*\*\*V-N:' "$segf" 2>/dev/null || true)"
                _vn_thresh=$vn_thresh_base
                if [ "${_p_no_grep:-0}" = "0" ] && [ "${_compact_grep:-0}" -gt 0 ]; then _vn_thresh=1; fi
                # [2026-09-20 task-v086 P2-S3 Rule 38.4②] mini 无 V-N 映射行不阻断(降档容忍缺口)
                if [ "$PLAN_TIER_MINI" = 1 ] && [ "${vn_sub:-0}" -eq 0 ]; then continue; fi
                rm -f "$segf"
                if [ "$vn_sub" -ge "$_vn_thresh" ]; then
                    # 实质映射达标 → 映射目标须全部 ∈ 已定义 VC（goal-gate「映射到 VC 编号」）
                    target_bad=0
                    if [ "$vn_total" -gt "$vn_sub" ]; then target_bad=1; fi
                    if [ -n "$vc_defs" ]; then
                        # [task-v074 P8 D11] 映射目标提取并集：逐 P-N 行（原有）+ 紧凑 `- **V-N:**` 行（新增）
                        if { grep -E '^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-'"$p_no"'\.[0-9]+\s*[:：]' "$vc_gate_section" 2>/dev/null \
                              | sed -E 's/^[[:space:]]*-[[:space:]]*\[[ xX]\][[:space:]]*V-[0-9]+\.[0-9]+\s*[:：][[:space:]]*//' \
                              | grep -oE 'VC-[0-9]+' 2>/dev/null || true; \
                              grep -E '^[[:space:]]*-[[:space:]]*\*\*V-N:[[:space:]]*\*\*.*VC-[0-9]+' "$vc_gate_section" 2>/dev/null \
                              | grep -oE 'VC-[0-9]+' || true; } \
                            | sort -u | grep -vxF -f <(printf '%s\n' "$vc_defs") 2>/dev/null | grep -q .; then
                            target_bad=1
                        fi
                    fi
                    if [ "$target_bad" -eq 1 ]; then
                        vc_bad_phases="${vc_bad_phases} Phase${p_no}(V-N 映射目标缺失/未定义 VC 或模板占位残留); "
                    fi
                    continue
                fi
                vc_bad_phases="${vc_bad_phases} Phase${p_no}(V-N 映射 ${vn_sub:-0} < ${_vn_thresh}); "
            done <<< "$phase_titles"
        fi
        rm -f "$vc_gate_section"

        # 判定: VC ≥5 且 所有 Phase 映射合规
        # [2026-09-20 task-v086 P2-S3 Rule 38.4②] mini 降档: 阈值用 $vc_min(5→2), 非 mini 恒 5
        if [ "$vc_count" -lt "$vc_min" ] || [ -n "$vc_bad_phases" ]; then
            vc_gate_fail=1
        fi

        if [ "$vc_gate_fail" -eq 1 ]; then
            vc_count_part="VC 表=${vc_count}"
            [ "$vc_count" -lt "$vc_min" ] && vc_count_part="${vc_count_part} (需≥${vc_min})"
            phase_part=""
            [ -n "$vc_bad_phases" ] && phase_part="; Phase V-N 映射缺口: ${vc_bad_phases%; }"
            case "$VC_GATE_TIER" in
                enforce)
                    printf '[plan] VC-GATE FAILED (task-v065 V-9: %s%s) — 补 VC 条目 / 每个 Phase ≥2 条 V-N 映射(映射到已定义 VC 编号)后重跑\n' \
                        "$vc_count_part" "$phase_part" >&2
                    exit 1
                    ;;
                *)
                    printf '[plan] VC-GATE WARNING (task-v065 V-9, warn 档不阻断: TASK_PLANNER_VC_GATE_ENFORCE=enforce 或 config.json vc_gate_enforce=enforce 可升级阻断) — %s%s\n' \
                        "$vc_count_part" "$phase_part" >&2
                    ;;
            esac
        else
            # [2026-09-20 task-v086 P2-S3 Rule 38.4②] 回显按档位: standard=≥2, mini=≥1(原措辞固定 2 对 mini 不准)
            printf '[plan] VC-GATE PASSED (VC 表=%s, %s 个 Phase 各 ≥%s 条 V-N 映射)\n' "$vc_count" "$p_no" "$vn_thresh_base" >&2
        fi
    fi

    # [2026-10-05 task-v132 G1 (Rule 51.1a) R-COVERAGE 门 — 72h 事故修复: 完成声称对照(51.3)的机器化]
    # 校验 delivery-summary.md「需求覆盖核对」区块是否逐项覆盖计划 R 行:
    #   ① R 行数=计划 R 行数(按 R 编号对齐, 缺行/多行=FAIL)
    #   ② 每行状态 ∈ {covered, partial, uncovered}(状态列缺失=FAIL)
    #   ③ covered/partial 行须带证据路径(证据区=状态列后的单元格, 实质内容引用/路径/锚, 空值与否定值=FAIL;
    #      判定=非空 ∧ ∉{无,—,N/A} — 原「含 / 或 . 字面 token」口径负向实测误伤 v131 R7「同 R3」式引用, 已放宽)
    #   ④ 任一 R partial/uncovered 且计划 Decisions Made 无对应让步登记 → 拒 COMPLETE 只可 PARTIAL(列缺口)
    # 档位复用既有 VC_GATE_TIER(env TASK_PLANNER_VC_GATE_ENFORCE > config.json vc_gate_enforce > 默认 warn, 零新键):
    #   违规时 warn 档输出 WARNING / enforce 档 exit 1; 已登记让步的 uncovered/partial 两档均不阻断, 只给 PARTIAL 语义提示。
    # delivery-summary.md 不存在 → fail-open INFO(既有计划豁免口径, FMEA F1 兜底); 无🎯区块/mini 豁免/无 R 行 → SKIPPED INFO。
    # 插入位=VC-GATE 块后(Requirement 51.1a 字面「VC-GATE 外增」), C-2 四元键③哈希锚区间(至 :502 行)之外=键哈希零扰动。
    # [2026-10-11 task-v167 Rule 38.7] L0 改抽查: 只校验 delivery-summary 需求覆盖核对表存在 + 前 3 数据行
    # 有证据路径（38.7 薄 verification=抽查表段；不降完成性判定——enforce 档缺口仍 exit 1 口径不变）。
    # [2026-10-16 P-01 (终审意见 7)] EVIDENCE-ANCHOR GATE — R-COVERAGE 段前置 shell-out（--source=coverage）
    # 判定面 = delivery-summary「需求覆盖核对」证据格：路径存在 / 行号 ≤ 文件行数 / 否定字面 trim 后判定 /
    # provenance（系统前缀·域外·机器落盘 evidence/ 头）。门控范围与 R-COVERAGE 自身对齐（mini 档豁免
    # Rule 38.4；L0 保留——38.7 的 L0 抽查面本就含证据列，证据真实性属完成性底线非重复验证项）。
    if [ "$VC_GATE_TIER" != "off" ] && [ "${PLAN_TIER_MINI:-0}" != 1 ]; then
        run_evidence_anchor coverage
    fi

    if [ "${LANE_L0:-0}" = 1 ] && [ "$VC_GATE_TIER" != "off" ]; then
        rcov_l0_file="$PLAN_DIR_GUESS/delivery-summary.md"
        if [ ! -f "$rcov_l0_file" ]; then
            printf '[lane-L0] skip R-COVERAGE GATE（38.7 非适用项: delivery-summary 无=抽查面缺失, 不阻断, 口径同既有 fail-open F1）\n' >&2
        else
            # 抽查=核对表存在 + 前 3 数据行证据路径非空（awk 口径同主门: 首列 R<n> 行, 状态列后单元格为证据区）
            rcov_l0_bad="$(awk '
                /需求覆盖核对/ {f=1; next}
                f && /^##[[:space:]]/ {f=0}
                f && /^\|/ {
                    n = split($0, a, "|")
                    if (n < 3) next
                    r = ""
                    for (i = 1; i <= n; i++) {
                        t = a[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t)
                        if (t ~ /^R[0-9]+$/) { r = t; break }
                    }
                    if (r == "") next
                    data++
                    if (data > 3) next
                    ev = ""
                    for (j = 2; j <= n; j++) {
                        t = a[j]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t)
                        if (index(t, "covered") || index(t, "partial") || index(t, "uncovered")) { ev = ev " " t; continue }
                        if (ev != "") ev = ev " " t
                    }
                    gsub(/^[[:space:]]+/, "", ev)
                    if (ev == "" || ev == " " || ev == "无" || ev == "—" || ev == "N/A") printf "%s(证据路径缺失) ", r
                }
                END { }' "$rcov_l0_file" 2>/dev/null)"
            rcov_l0_nodata="$(awk '/需求覆盖核对/ {f=1} f && /^##[[:space:]]/ {f=0} f && /^\|[[:space:]]*R[0-9]+/ {n++} END {print n+0}' "$rcov_l0_file" 2>/dev/null)"
            if [ -z "${rcov_l0_bad:-}" ] && [ "${rcov_l0_nodata:-0}" -ge 1 ]; then
                printf '[plan] R-COVERAGE L0 抽查 PASSED（38.7: 表存在 + 前 3 行证据路径在案, 数据行=%s）\n' "$rcov_l0_nodata" >&2
            else
                printf '[plan] R-COVERAGE L0 抽查 FAILED（38.7 薄化抽查: 缺表数据行/前 3 行缺证据路径: %s）\n' "${rcov_l0_bad:-<无数据行>}" >&2
                case "$VC_GATE_TIER" in
                    enforce) exit 1 ;;
                    *) : ;;  # warn 档沿用主门 fail-open 口径, 仅提示
                esac
            fi
        fi
    elif [ "$VC_GATE_TIER" != "off" ] && [ "${PLAN_TIER_MINI:-0}" != 1 ]; then
        # 计划 R 行集合: 「🎯 用户需求原文」区块内 `- **R<n>**: ...` 列表行(awk 状态机抽区块, 同 27.3 porcelain 预检范式;
        # 区块至下一个 ##/### 标题截止, 避免误吞 R→VC 映射表内的 R 编号)
        # [2026-10-05 task-v132/Phase4 CR-P1] R 集合提取锚定: R 编号只从 R 行**行首编号**提取,
        # 行内交叉引用（「另见 R9」「（R3 重申）」）一律不计数; 原行为=awk 抽全量 `- ` 列表行后
        # 未锚定 `grep -oE 'R[0-9]+'` 提 R 号, R7 行「（R3 重申）」先例及任意 R 行交叉引用都被误当
        # 需求编号, enforce 档下「真实需求未变却报核对表缺行」=误拦合法交付（72h 事故同形态误报面）。
        # 锚定形态（任务书给式）: `^[[:space:]]*[-*][[:space:]]*\**R[0-9]+`——行首即列表标记
        # （`-`/`*`, 可带缩进）+ 可选星号修饰 + R 编号; 状态机内 match() 取首个 R 数字串
        # （锚定保证首个=行首编号本体）直接输出 R 号, 后续 sort -u 即得 R 集合。
        # 核对表侧（下方 rcov_cov_awk 表格行首 R cell 提取）本就只认行首 R 号, 两侧口径一致。
        rcov_req_awk='
/^##[[:space:]].*🎯 用户需求原文/ {f=1; next}
f && /^##[[:space:]]/ {f=0}
f && /^[[:space:]]*[-*][[:space:]]*\**R[0-9]+/ {
    match($0, /R[0-9]+/)
    if (RSTART > 0) print substr($0, RSTART, RLENGTH)
}'
        _rcov_req_awk_file="$(mktemp "${TMPDIR:-/tmp}/rcov-req.XXXXXX" 2>/dev/null)" || _rcov_req_awk_file="$(pwd)/.rcov-req.$$"
        printf '%s\n' "$rcov_req_awk" > "$_rcov_req_awk_file" 2>/dev/null
        rcov_plan_rs="$(awk -f "$_rcov_req_awk_file" "$PLAN_FILE" 2>/dev/null | sort -u || true)"
        rm -f "$_rcov_req_awk_file" 2>/dev/null
        rcov_r_count="$(printf '%s\n' "$rcov_plan_rs" | grep -c 'R[0-9]' 2>/dev/null || true)"
        rcov_r_count="${rcov_r_count:-0}"
        if [ "$rcov_r_count" -lt 1 ]; then
            printf '[rcov-gate] SKIPPED (计划「🎯 用户需求原文」区块无 R 行=旧计划/无锚定计划, 不要求覆盖核对, 51.1a 触发条件 R 行数≥1 不满足)\n' >&2
        else
            rcov_file="$PLAN_DIR_GUESS/delivery-summary.md"
            if [ ! -f "$rcov_file" ]; then
                # FMEA F1 兜底: 旧计划无 delivery-summary/核对表 → fail-open INFO, 不阻断存量计划终验
                printf '[rcov-gate] SKIPPED (fail-open: %s 不存在, 既有计划豁免口径 F1 兜底, 不影响本计划终验)\n' "$rcov_file" >&2
            else
                # 「需求覆盖核对」区块数据行解析(awk 程序存临时文件走 -f, 免内联 $() 截断陷阱, 同 Learning Gate 范式):
                # 数据行=首列为 R<n> 的表格行; 首个含 covered/partial/uncovered 的单元格=状态列(uncovered 先判避免被 covered 子串吞);
                # 状态列之后的单元格=证据区。输出: R \t 状态(缺状态列=status_missing) \t 证据区 \t 证据区含/或. 路径 token(0/1)
                rcov_cov_awk='
/需求覆盖核对/ {f=1; next}
f && /^##[[:space:]]/ {f=0}
f && /^\|/ {
    n = split($0, a, "|")
    if (n < 3) next
    r = ""
    for (i = 1; i <= n; i++) {
        t = a[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t)
        if (t ~ /^R[0-9]+$/) { r = t; break }
    }
    if (r == "") next
    si = 0; st = ""; ev = ""
    for (j = 2; j <= n; j++) {
        t = a[j]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); gsub(/\*/, "", t)
        if (si == 0) {
            if (index(t, "uncovered") > 0) { si = j; st = "uncovered"; continue }
            if (index(t, "partial") > 0) { si = j; st = "partial"; continue }
            if (index(t, "covered") > 0) { si = j; st = "covered"; continue }
        } else { ev = ev " " t }
    }
    if (si == 0) { printf "%s\tstatus_missing\t\n", r }
    else {
        gsub(/^[[:space:]]+/, "", ev)
        # 证据路径判定: 证据区非空且非否定值(无/—/N/A); v131 实测 R7 证据="同 R3;…(Decisions Made 全登记)"
        # 不含 / 与 . 字面 → 原「含 / 或 . 路径 token」判定误伤存量合格 summary(负向实测 2026-10-05), 放宽为实质证据引用
        p = 0; if (ev != "" && ev != "无" && ev != "—" && ev != "N/A") p = 1
        printf "%s\t%s\t%s\t%d\n", r, st, ev, p
    }
}'
                _rcov_cov_awk_file="$(mktemp "${TMPDIR:-/tmp}/rcov-cov.XXXXXX" 2>/dev/null)" || _rcov_cov_awk_file="$(pwd)/.rcov-cov.$$"
                printf '%s\n' "$rcov_cov_awk" > "$_rcov_cov_awk_file" 2>/dev/null
                rcov_sum_rows="$(awk -f "$_rcov_cov_awk_file" "$rcov_file" 2>/dev/null)" || rcov_sum_rows=""
                rm -f "$_rcov_cov_awk_file" 2>/dev/null

                # ④ 让步登记判定: 计划「Decisions Made」区块内存在同时含该 R 编号与「让步」字面的数据行
                # → 视为已登记显式缩水
                # [2026-10-05 task-v132/Phase4 ALIGN-P2 收紧] 原行为=grep 链宽词同现
                # `grep -qE '让步|uncovered|partial'`: Decisions 行若仅以状态词描述（如「R3 目前是
                # partial」「uncovered 项见上」，非真让步语境）会被误判「已登记让步」→ 裸 uncovered/
                # partial 误放行。收紧为「R<k> 与 让步 明确同现」——「让步」字面=显式缩水声明的强
                # 信号，状态词 uncovered/partial 是弱信号不再计数（需求锚 R1:「任一 R uncovered/partial
                # 且无 Decisions 让步登记→拒 COMPLETE 只可 PARTIAL」——登记判据=让步，非状态词复述）。
                # RC-20 正例「R1 显式让步（uncovered 登记）」收紧后仍双命中(R1+让步)；负例 (a) Decisions
                # 行文案刻意避开「让步」字面（见 selftest 踩坑注）→ 判定结果不漂移。
                rcov_concession_registered() {
                    awk '/^##[[:space:]]*Decisions Made/{f=1; next} f && /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null \
                        | grep -E "\b$1\b" 2>/dev/null | grep -qE '让步'
                }

                rcov_viol=""
                rcov_partials=""
                rcov_sum_rs="$(printf '%s\n' "$rcov_sum_rows" | grep -oE '^R[0-9]+' | sort -u || true)"
                # 逐行判定: ② 状态列缺失 / ③ 证据路径缺失 / ④ partial·uncovered 的让步登记分岔
                while IFS=$'\t' read -r rr rst rev rhp; do
                    [ -n "$rr" ] || continue
                    case "$rst" in
                        status_missing)
                            rcov_viol="${rcov_viol} ${rr}(状态列缺失, 须 ∈ covered/partial/uncovered)" ;;
                        covered|partial)
                            [ "${rhp:-0}" = "1" ] || rcov_viol="${rcov_viol} ${rr}(${rst} 缺证据路径)"
                            if [ "$rst" = "partial" ]; then
                                if rcov_concession_registered "$rr"; then
                                    rcov_partials="${rcov_partials} ${rr}"
                                else
                                    rcov_viol="${rcov_viol} ${rr}(partial 且 Decisions 无让步登记)"
                                fi
                            fi
                            ;;
                        uncovered)
                            if rcov_concession_registered "$rr"; then
                                rcov_partials="${rcov_partials} ${rr}"
                            else
                                rcov_viol="${rcov_viol} ${rr}(uncovered 且 Decisions 无让步登记)"
                            fi
                            ;;
                    esac
                done <<< "$rcov_sum_rows"
                # ① 缺行/多行: 计划 R 集合 vs 核对表 R 集合双向对齐(按 R 编号)
                while IFS= read -r pr; do
                    [ -n "$pr" ] || continue
                    printf '%s\n' "$rcov_sum_rs" | grep -qxF "$pr" || rcov_viol="${rcov_viol} ${pr}(核对表缺行)"
                done <<< "$rcov_plan_rs"
                while IFS= read -r sr; do
                    [ -n "$sr" ] || continue
                    printf '%s\n' "$rcov_plan_rs" | grep -qxF "$sr" || rcov_viol="${rcov_viol} ${sr}(多行, 不在计划 R 清单)"
                done <<< "$rcov_sum_rs"

                if [ -n "$rcov_viol" ]; then
                    rcov_gap="${rcov_viol# }"
                    case "$VC_GATE_TIER" in
                        enforce)
                            printf '[rcov-gate] ✗ R-COVERAGE FAILED (task-v132 G1 Rule 51.1a, vc_gate_enforce=enforce): 缺口 — %s — 拒 COMPLETE 只可 PARTIAL: 回填 delivery-summary 需求覆盖核对表(补行/补证据路径)或 Decisions 登记让步后重跑\n' "$rcov_gap" >&2
                            exit 1
                            ;;
                        *)
                            printf '[rcov-gate] ⚠ R-COVERAGE WARNING (task-v132 G1 Rule 51.1a, warn 档不阻断: TASK_PLANNER_VC_GATE_ENFORCE=enforce 或 config.json vc_gate_enforce=enforce 可升级) — 缺口: %s\n' "$rcov_gap" >&2
                            ;;
                    esac
                elif [ -n "$rcov_partials" ]; then
                    # ④ 让步已登记的 uncovered/partial: 不阻断(enforce 亦 exit 0), 只给 PARTIAL 语义提示
                    # — 显式缩水 = 完成度只能 PARTIAL(终验规则「R uncovered→PARTIAL 列明」)
                    printf '[rcov-gate] PARTIAL 语义提示 (R-COVERAGE 门: %s uncovered/partial 已登记 Decisions 让步 — 完成状态只可 PARTIAL, 缺口已在覆盖核对表列明)\n' "${rcov_partials# }" >&2
                fi
                # 全部 R covered 且带证据路径 → PASS 静默(零输出, 与「PASS 静默」验收口径一致)
            fi
        fi
    fi

    # [2026-10-10 task-v155 S14 (Rule 48/70)] 交付总结呈报可审批性轻量守护 — report-lint 段
    # WHAT: 对同目录 delivery-summary.md 做三项轻量 lint——①「## 2. 产出清单」区表格数据行路径形态
    #       （Rule 48.2/70② 可定位性）②「## 5./6. 下一步建议」区看点/动作三要素（Rule 48.4/70④）
    #       ③「待裁决」行对象定位（Rule 70②）；命中即 printf '[report-lint] ⚠ ...' 到 stderr。
    # WHY : 消费方=check-complete 终验（交付总结呈报前的最后一道软提示）；fail-open 理由=exit 语义是
    #       交付门控承重墙——本段只增 warn 提示，绝不改 exit code / 写 FAIL 计数 / return 非 0 传播；
    #       delivery-summary.md 不存在则 SKIPPED 直接返回。依据=task-v155（Rule 48/70 呈报契约机器面）。
    # 插入位=rcov-gate 段结束之后、同层级（4 空格缩进）；风格对齐 rcov-gate（printf stderr / fail-open）。
    # 区块锚容忍模板阿拉伯数字式（`## 2.`/`## 5./6.`，金标准 templates/delivery-summary.md）
    # 与历史中文数字式（`## 二、`/`## 五、`）两种写法，定位语义不变、不弱化判定。
    # [2026-10-11 task-v166] 「下一步建议」段由 `## 5.` 顺延为 `## 6.`（新增 §3 审查清单级联），
    # 锚保留 (5.|6.|五、|六、) 双形态兼容新旧模板产物。
    run_report_lint() {
        local ds_file="$PLAN_DIR_GUESS/delivery-summary.md"
        # 1. 定位 delivery-summary.md；不存在 → fail-open SKIPPED 直接返回（不影响终验 exit 语义）
        if [ ! -f "$ds_file" ]; then
            printf '[report-lint] SKIPPED (fail-open: 无 delivery-summary.md, 不影响终验)\n' >&2
            return 0
        fi
        # 2. 检查① 产出清单路径形态：「## 2. 产出清单」标题行至下一个 ^## 之间的表格数据行
        #    （排除表头行=区块内首个表格行 / 分隔行=| --- |），若 ≥2 行不含 /（绝对/仓内路径形态）→ warn。
        local rl_nopath
        rl_nopath="$(awk '
            /^##[[:space:]]*(2\.|二、)[[:space:]]*产出清单/ {f=1; next}
            f && /^##[[:space:]]/ {f=0}
            f && /^[[:space:]]*\|/ {
                if ($0 ~ /^[[:space:]]*\|[[:space:]:|-]+\|[[:space:]]*$/) next   # 分隔行
                if (!hdr) { hdr=1; next }                                        # 区块内首个表格行=表头
                if (index($0, "/") == 0) n++
            }
            END {print n+0}' "$ds_file" 2>/dev/null)" || rl_nopath=0
        if [ "${rl_nopath:-0}" -ge 2 ]; then
            printf '[report-lint] ⚠ 产出清单存在无路径行 (Rule 48.2/70② 可定位性)\n' >&2
        fi
        # 3. 检查② 下一步建议三要素：「## 5./6. 下一步建议」区（至文件尾/下一 ^##）须同时含「看点」与「动作」，
        #    缺任一 → warn（Rule 48.4/70④）；区块不存在则跳过（不误报）。
        #    [2026-10-11 task-v166] 锚漂移修复：模板段号由 `## 5.` 顺延为 `## 6.`（新增 §3 审查清单级联），
        #    正则扩为 (5.|6.|五、|六、) 双形态兼容新旧模板，避免三要素 lint 静默失效。
        if grep -qE '^##[[:space:]]*(5\.|6\.|五、|六、)[[:space:]]*下一步建议' "$ds_file" 2>/dev/null; then
            local rl_sec5
            rl_sec5="$(awk '
                /^##[[:space:]]*(5\.|6\.|五、|六、)[[:space:]]*下一步建议/ {f=1; next}
                f && /^##[[:space:]]/ {f=0}
                f' "$ds_file" 2>/dev/null)" || rl_sec5=""
            if ! printf '%s\n' "$rl_sec5" | grep -q '看点' || ! printf '%s\n' "$rl_sec5" | grep -q '动作'; then
                printf '[report-lint] ⚠ 下一步建议缺看点/动作定位三要素 (Rule 48.4/70④)\n' >&2
            fi
        fi
        # 4. 检查③ 待裁决定位：「待裁决」字样所在行若同行无路径形态（/ 或 http）→ warn（Rule 70②）。
        # [2026-10-10 task-v155 修正] 原 `grep -n ... | grep -vqE` 在空输入（无「待裁决」行）时，
        # ugrep 的 `grep -vqE` 退出码=0（误报 warn），GNU grep=1（正确不报）。
        # 根因：ugrep 对空输入的 grep -v 语义与 GNU 不一致（ZCode 环境 grep=ugrep 7.8.4）。
        # 修法：先取命中行数 n，仅当 n>0 再判路径形态，与 :741 同惯用（显式测非空）。
        local rl_pending_n
        rl_pending_n=$(grep -c '待裁决' "$ds_file" 2>/dev/null || true)
        if [ "${rl_pending_n:-0}" -gt 0 ] && grep -n '待裁决' "$ds_file" 2>/dev/null | grep -vqE '/|http'; then
            printf '[report-lint] ⚠ 待裁决项缺对象定位 (Rule 70②)\n' >&2
        fi
        # 5. 检查④ Rule 76.2 审查清单表格段在位（task-v166 S8 / SRV-10，需求锚 R1「需要审查的内容列给我」）：
        #    delivery-summary.md 须含「## 3. 审查清单」标题（容忍模板阿拉伯/中文数字式）且其表头行同含
        #    「文件名」「路径」「描述」三列（Rule 76.2 可定位表格）；缺标题或三列任一 → warn。
        if ! grep -qE '^##[[:space:]]*(3\.|三、)[[:space:]]*审查清单' "$ds_file" 2>/dev/null; then
            printf '[report-lint] ⚠ 缺「审查清单」表格段标题 (Rule 76.2)\n' >&2
        else
            local rl_rc_hdr
            rl_rc_hdr="$(awk '
                /^##[[:space:]]*(3\.|三、)[[:space:]]*审查清单/ {f=1; next}
                f && /^##[[:space:]]/ {f=0}
                f && /^[[:space:]]*\|/ { if (!hdr) { hdr=1; print; next } }' "$ds_file" 2>/dev/null)" || rl_rc_hdr=""
            for col in 文件名 路径 描述; do
                if ! printf '%s\n' "$rl_rc_hdr" | grep -q "$col"; then
                    printf '[report-lint] ⚠ 审查清单表头缺「%s」列 (Rule 76.2)\n' "$col" >&2
                fi
            done
        fi
        # 6. 检查⑤ 占位符残留查（Rule 76.4 五要素完整，需求锚 R1）：delivery-summary.md（plans 产物，
        #    非模板）含「待补」/「TODO」/「<待...>」未解析占位符 → warn；模板文件含占位符合法故只查产物。
        #    显式取命中行数再判（与检查③同惯用，规避 ugrep 空输入 grep -v 退出码不一致陷阱）。
        local rl_ph_n
        rl_ph_n=$(grep -cE '待补|TODO|<待' "$ds_file" 2>/dev/null || true)
        if [ "${rl_ph_n:-0}" -gt 0 ]; then
            printf '[report-lint] ⚠ 总结残留未解析占位符 (Rule 76.4 五要素)\n' >&2
        fi
        # 7. 检查⑥ 用户面圈号负断言（Rule 76.1，需求锚 R3「圈1、圈2、圈3混在一起非常头疼」）：
        #    variant 两文件（image-type / multiview-ref-type，task-v166 S7 清除对象）中 Phase 标题行
        #    残留装饰圈号（「### Phase 1: ① ...」形态，G5 判据）→ warn。
        #    [修正] 首版单式 `grep -cE 'Phase[[:space:]]*[0-9]+[^①-⑨]*[①-⑨]'` 会误报：命中注释/正文里
        #    「Phase 7 批次末…②」等合法引用（image-type.md:5 注释行即命中）。限定 ^#{1,6} 标题行
        #    前缀（S7 后 Phase 标题全为「### Phase N. xxx」形态，无装饰圈号=0 命中）；两段 grep 管道：
        #    先抽 Phase 标题行再判行内圈号（两段式规避 ugrep 单 -E 多模式/区间组合差异，且显式锚定行首
        #    标题）。只判标题行，正文合法编号列表不受影响；模板文件不可达则跳过（fail-open 不误报）。
        #    [2026-10-11 task-v166 F-4] 清理冗余声明：原 `local vf rl_ph_n rl_circ` 中 rl_circ 从未使用
        #    （已删）；rl_ph_n 为跨检查⑤/⑥ 复用的循环内计数器（与 :1012 检查⑤ 同名，有意复用不新造变量）。
        local vf rl_ph_n
        for vf in "$SKILL_ROOT/templates/variant/image-type.md" "$SKILL_ROOT/templates/variant/multiview-ref-type.md"; do
            [ -f "$vf" ] || continue
            rl_ph_n="$(grep -E '^#{1,6}[[:space:]]*Phase[[:space:]]*[0-9]+' "$vf" 2>/dev/null | grep -cE '①|②|③|④|⑤|⑥|⑦|⑧|⑨' || true)"
            if [ "${rl_ph_n:-0}" -gt 0 ]; then
                printf '[report-lint] ⚠ variant 用户面残留 Phase 装饰圈号 (Rule 76.1): %s\n' "$(basename "$vf")" >&2
            fi
        done
        # 8. 全部检查只 printf warn 到 stderr；不改 exit code / 不写 FAIL 计数 / return 恒 0（fail-open）。
        return 0
    }
    run_report_lint

    # [2026-10-11 task-v169 Rule 80.6] SESSION-LOG GATE — 用户会话逐字记录专档门控面（需求锚 R4 任务需求/对话内容
    # 逐字入 task_plan 记录系 / R5 记录性文档只写不改）。指针区块判定：task_plan.md 含「🗣️ 用户会话逐字记录」
    # 标题=新模板计划，强制 $PLAN_DIR_GUESS/user-session-log.md 存在、非空（-s）且含 ≥1 条 `## #N` 记录条目（条目格式见 Rule 80.2）；
    # 标题缺失=存量计划（无指针区块），输出 SKIPPED INFO 后放行（存量豁免口径，同 R-COVERAGE GATE 无🎯区块 SKIP）。
    # 档位 env-only 零新 config 键（properties 恒 42，DD-20 不回归）：TASK_PLANNER_SESSION_LOG_ENFORCE 取值
    # enforce / warn（默认）/ off（其他值与空值回落 warn；本门不读 config.json，对齐 Rule 34.6 env 开关先例）。
    # 行为矩阵：enforce+违规=stderr `[session-log-gate] ✗` 后 exit 1 阻断 complete；warn+违规=stderr ⚠ 不阻断；
    # off=整门 SKIP；L0 lane（Rule 38.7）打印 skip 后跳过（[lane-L0] 前缀同款）；合规=stderr OK 带条目数。
    if [ "${LANE_L0:-0}" = 1 ]; then
        printf '[lane-L0] skip SESSION-LOG GATE（38.7 非适用项: L0 单 Phase 微变更无会话记录面）\n' >&2
    else
        sl_tier="${TASK_PLANNER_SESSION_LOG_ENFORCE:-}"
        case "$sl_tier" in enforce|warn|off) : ;; *) sl_tier="warn" ;; esac
        if [ "$sl_tier" != "off" ] && grep -q '🗣️ 用户会话逐字记录' "$PLAN_FILE" 2>/dev/null; then
            sl_log="$PLAN_DIR_GUESS/user-session-log.md"
            sl_entries=0
            if [ -s "$sl_log" ]; then
                sl_entries="$(grep -cE '^## #[0-9]' "$sl_log" 2>/dev/null || true)"
            fi
            if [ -s "$sl_log" ] && [ "${sl_entries:-0}" -ge 1 ]; then
                printf '[session-log-gate] OK user-session-log.md 在案（%s 条记录条目）\n' "$sl_entries" >&2
            else
                if [ "$sl_tier" = "enforce" ]; then
                    printf '[session-log-gate] ✗ 指针区块在案但 user-session-log.md 缺失/空/无「## #N」记录条目 — Rule 80.6 门控 enforce 档阻断 complete: 先 append-only 补写专档（templates/user-session-log.md）后重跑\n' >&2
                    exit 1
                else
                    printf '[session-log-gate] ⚠ 指针区块在案但 user-session-log.md 缺失/空/无记录条目（warn 档不阻断; 设 TASK_PLANNER_SESSION_LOG_ENFORCE=enforce 升级为阻断档）\n' >&2
                fi
            fi
            # [2026-10-15 task-v176 D4] append-only 完整性基线校验（.session-log-baseline，init-session.sh 建档时生成）
            # What: 基线在案时校验 ① 现存条目数 ≥ 基线条目数（禁删条）∧ ② 现存首条目行 sha256 == 基线首条
            #       sha（禁改首条；基线记 `-` = 建档时无条目，仅约束「不可回退为有旧首条」——删条/改首条面）。
            #       违规：enforce 档 → stderr `[session-log-gate] ✗ baseline-drift` 后 exit 1 阻断；
            #       warn 档 → stderr ⚠ WARNING 不阻断（保持既有默认档语义）。
            # [2026-10-15 task-v176 CR 修复 MAJOR-2] 空锚豁免（What+Why）：基线 sha 字段为 `-`（init 建档
            #       时无条目，D4a 设计的归一形态）→ 跳过 ② sha 比对，仅保留 ① 条目数回退校验。
            #       原行为：sl_cur_first_sha 非 `-`（append 首条后）≠ sl_bl_sha=`-` 恒成立 → enforce 档误判
            #       baseline-drift 阻断、warn 档每次新会话首条合法 append 都产生告警噪音。
            #       豁免语义=基线 `-` 只锚定「建档时无旧首条」——此后合法 append 首条/后续条目均不得判漂移；
            #       删条回退（条目数 < 基线条目数）仍由 ① 拦截，append-only 篡改面不放开。
            # Why: Rule 80.2「append-only 只写不改」此前无完整性载体——历史改写/删条机器不可检测，
            #      而 task_plan.md 有 SHA-256 锁=记录强度倒挂（S1-7）。基线=首条 sha+条目数最小锚：
            #      append 新条合法（条目数只增、首条冻结），删条/改首条=篡改面。
            # 幂等/兼容: 基线缺失（存量计划/重复 init 前手工建档）→ 静默跳过（fail-open，不溯及历史）；
            #       基线文件首行形如 `<sha|-> <count>`，解析失败 → 跳过（不阻断，与 SL 门体既有
            #       门控故障 fail-open 惯例一致，错误留 stderr 痕迹）。
            sl_baseline="$PLAN_DIR_GUESS/.session-log-baseline"
            if [ -s "$sl_baseline" ]; then
                sl_bl_sha="$(head -n1 "$sl_baseline" 2>/dev/null | awk '{print $1}')"
                sl_bl_cnt="$(head -n1 "$sl_baseline" 2>/dev/null | awk '{print $2}')"
                case "${sl_bl_cnt:-}" in ''|*[!0-9]*) sl_bl_cnt="" ;; esac
                sl_cur_first_sha="$(grep -m1 -E '^## #[0-9]' "$sl_log" 2>/dev/null | sha256sum 2>/dev/null | awk '{print $1}')"
                # 无 `## #[0-9]` 条目时 grep 输出空 → sha256sum 算的是空输入哈希（64 位非 `-`）→ 归一为 `-`
                if [ -z "$(grep -m1 -E '^## #[0-9]' "$sl_log" 2>/dev/null || true)" ]; then
                    sl_cur_first_sha="-"
                fi
                sl_drift=""
                if [ -n "${sl_bl_cnt:-}" ] && [ "${sl_entries:-0}" -lt "$sl_bl_cnt" ]; then
                    sl_drift="${sl_drift}条目数回退（现存 ${sl_entries:-0} < 基线 ${sl_bl_cnt}，删条=append-only 违背） "
                fi
                # [2026-10-15 task-v176 CR 修复 MAJOR-2] 空锚豁免：sl_bl_sha=`-`（建档时无条目）→
                # 跳过 ② sha 比对（合法 append 首条后 cur_sha 恒非 `-`，原逻辑每次必报漂移）；
                # 条目数回退校验 ① 保留（删条/回退面仍拦截）。原行为见上方「原行为」注释。
                if [ -n "$sl_bl_sha" ] && [ "$sl_bl_sha" != "-" ] && [ "$sl_cur_first_sha" != "$sl_bl_sha" ]; then
                    sl_drift="${sl_drift}首条目 sha 漂移（基线 ${sl_bl_sha:0:12}… → 现存 ${sl_cur_first_sha:0:12}…，改首条=append-only 违背） "
                fi
                if [ -n "$sl_drift" ]; then
                    if [ "$sl_tier" = "enforce" ]; then
                        printf '[session-log-gate] ✗ user-session-log.md baseline-drift (task-v176 D4, .session-log-baseline 在案): %s — append-only（Rule 80.2）篡改面, enforce 档阻断 complete: 恢复被删/被改条目（或重建基线仅当可证明基线生成早于合法 append 且经用户授权）后重跑\n' "${sl_drift% }" >&2
                        exit 1
                    else
                        printf '[session-log-gate] ⚠ user-session-log.md baseline-drift WARNING (task-v176 D4, warn 档不阻断): %s — 设 TASK_PLANNER_SESSION_LOG_ENFORCE=enforce 升级为阻断档\n' "${sl_drift% }" >&2
                    fi
                else
                    printf '[session-log-gate] OK append-only 基线一致（.session-log-baseline: entries≥%s ∧ 首条 sha 未变, task-v176 D4）\n' "${sl_bl_cnt:-?}" >&2
                fi
            fi
        elif grep -q '🗣️ 用户会话逐字记录' "$PLAN_FILE" 2>/dev/null; then
            # off 档：指针区块虽在案但整门 SKIP（off 语义=不校验会话记录）
            printf '[session-log-gate] SKIPPED (TASK_PLANNER_SESSION_LOG_ENFORCE=off 档整门跳过, 零新 config 键 env-only)\n' >&2
        elif [ "$sl_tier" != "off" ]; then
            printf '[session-log-gate] SKIPPED (task_plan.md 无「🗣️ 用户会话逐字记录」指针区块=存量计划, 门控触发条件不满足, 放行)\n' >&2
        fi
    fi

    # [2026-10-11 task-v167 波次4 Rule 42.7] CR-GATE — CR 风险信号触发制机器消费面（report-lint 后、LEARNING-GATE 前）
    # 基线 ref 三级 fallback（plan「## Diff 基线」区 baseline_ref: → git log --grep <task-id> 末条~1 → HEAD~1）+
    # diff（pathspec "."=本 plan 目录防串扰）→ 风险信号（代码文件>3 或合计>50 行）且 progress.md 无
    # CR APPROVED/审查 APPROVED 留痕 → exit 1；未命中=PASS（Decisions 登记=等价防线）；基线不可解析=从严 FAIL，
    # 非 git=SKIPPED；L0 lane（38.7）跳过。不降质量——免除的只是无信号场景的 2-4 轮 CR 惯例。
    if [ "${LANE_L0:-0}" = 1 ]; then
        printf '[lane-L0] skip CR-GATE（38.7 非适用项: L0 单 Phase 微变更无 CR 轮次面）\n' >&2
    elif ! grep -qE 'CR APPROVED|审查 APPROVED' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null; then
        cr_task_id="$(basename "$(dirname "$PLAN_FILE")")"
        # 基线 ref 三级 fallback：plan「## Diff 基线」区 baseline_ref: 行 → git log --grep <task-id> 末条~1 → HEAD~1
        CR_BASE_REF="$(awk '/^##[[:space:]]*Diff 基线/{f=1;next} f&&/^## /{exit} f{print}' "$PLAN_FILE" 2>/dev/null | grep -m1 -oE 'baseline_ref:[[:space:]]*[^[:space:]]+' | awk '{print $2}')"
        if [ -z "$CR_BASE_REF" ]; then cr_last="$(git -C "$PLAN_DIR_GUESS" log --oneline --grep "$cr_task_id" 2>/dev/null | tail -1 | awk '{print $1}')"; if [ -n "${cr_last:-}" ]; then git -C "$PLAN_DIR_GUESS" rev-parse --verify "${cr_last}~1^{commit}" >/dev/null 2>&1 && CR_BASE_REF="${cr_last}~1" || CR_BASE_REF="$cr_last"; elif git -C "$PLAN_DIR_GUESS" rev-parse --verify 'HEAD~1^{commit}' >/dev/null 2>&1; then CR_BASE_REF="HEAD~1"; fi; fi
        if git -C "$PLAN_DIR_GUESS" rev-parse --git-dir >/dev/null 2>&1; then
            { [ -n "$CR_BASE_REF" ] && git -C "$PLAN_DIR_GUESS" rev-parse --verify "${CR_BASE_REF}^{commit}" >/dev/null 2>&1; } || { printf '[CR-GATE] FAILED: 风险信号命中（基线 ref 不可解析, 从严）但无 CR APPROVED 记录 — 补 progress.md CR 留痕或计划「## Diff 基线」区 baseline_ref 行后重跑\n' >&2; exit 1; }
            cr_nfiles="$(git -C "$PLAN_DIR_GUESS" diff "$CR_BASE_REF" --name-only -- . 2>/dev/null | grep -cE '\.(py|sh|ts|tsx|js|jsx|go|rs|java|c|cpp|h|hpp)$' || true)"
            cr_tlines="$(git -C "$PLAN_DIR_GUESS" diff --shortstat "$CR_BASE_REF" -- . 2>/dev/null | grep -oE '[0-9]+ (insertions|deletions)' | awk '{s+=$1} END{print s+0}')"  # 单值=插入+删除合计（awk 替代 bc）
            # 风险信号判据=42.7 轻/重 diff 分级同口径（代码文件>3 或合计>50 行）；if 包裹防 || && 短路吞判
            if [ "${cr_nfiles:-0}" -gt 3 ] || [ "${cr_tlines:-0}" -gt 50 ]; then
                printf '[CR-GATE] FAILED: 风险信号命中（代码文件=%s, diff 合计=%s 行）但无 CR APPROVED 记录 — 按 42.7 触发 CR 并在 progress.md 留 CR APPROVED 行后重跑\n' "${cr_nfiles:-0}" "${cr_tlines:-0}" >&2; exit 1
            fi
        else
            printf '[CR-GATE] SKIPPED（非 git 目录无 diff 面，CR 惯例不变）\n' >&2
        fi
    fi
    printf '[CR-GATE] PASS（无风险信号命中/已豁免·Decisions 登记, 或 CR APPROVED 留痕在案）\n' >&2

    # [2026-09-14 task-v072 Rule 31] 终验 Learning Gate — 错误学习闭环:
    # progress.md 若含数据行(非模板占位)的「Root Cause」/「Prevention」列,则各行 Root Cause 非空
    # (<待沉淀> 占位/空 均 FAIL)。列识别:表头含 "Root Cause" 列;无表头/无该列/无 Error Log → PASS 静默(存量计划兼容)。
    # 状态机式 awk(非区间 /start/,/end/ 区间式,gawk 5.2 下起始行同配终止模式恒为空的已知陷阱,
    # 与本脚本 27.3 porcelain 预检段同一范式)。
    # 档位: env TASK_PLANNER_ERROR_LOOP_ENFORCE > config.json error_loop_enforce > warn;
    # enforce=FAIL 时 exit 1 / warn=仅 stderr 告警计数 / off=跳过
    resolve_error_loop_tier() {
        local m="${TASK_PLANNER_ERROR_LOOP_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ]; then
            # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
            m="$(jq -r '.error_loop_enforce // .properties.error_loop_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    ERROR_LOOP_TIER="$(resolve_error_loop_tier)"
    # [2026-10-11 task-v167 Rule 38.7] L0 skip LEARNING-GATE（Why: Error Log 四问归因=多轮执行
    # 学习闭环面, L0 单 Phase 微变更无错误堆/多轮修复面; 保留线=全量终验锚不跳）
    if [ "${LANE_L0:-0}" = 1 ]; then
        printf '[lane-L0] skip LEARNING-GATE（38.7 非适用项: L0 单 Phase 无多轮错误闭环面）\n' >&2
        ERROR_LOOP_TIER="off"
    fi
    if [ "$ERROR_LOOP_TIER" != "off" ]; then
        progress_file="$(dirname "$PLAN_FILE")/progress.md"
        if [ -f "$progress_file" ]; then
            learning_gate_rc=0
            learning_gate_report=""
            # 表头列号识别(状态机找 "## Error Log" 节后首个表头行的 Root Cause 列号)。
            # [task-v072 fix] 双层引号转义易错(内层单引号被吃/反斜杠层级混乱,实测恒 PASS),
            # 改 awk 程序先存 shell 变量再展开:awk 程序单引号内 $0 等无展开风险,
            # 正则 | 在 awk 正则里需 \| 匹配字面竖线。
            lg_rc_awk='
/^## Error Log/ {in_sec=1; next}
in_sec && /^## / {in_sec=0}
in_sec {
    if (cols == 0 && $0 ~ /^\|/) {
        n = split($0, a, "|")
        for (i = 1; i <= n; i++) {
            v = a[i]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
            if (v ~ /Root[[:space:]]+Cause/) { cols = i }
        }
        if (cols > 0) { print cols; exit }
    }
}'
            # [task-v072] 双文件参数(awk 脚本文件 + 数据文件):把程序存独立临时文件,
            # 走 awk -f 语义(不经 shell 引号展开,免内联 $() 程序被静默截断的已知陷阱)
            _lg_rc_awk_file="$(mktemp "${TMPDIR:-/tmp}/lg-rc.XXXXXX" 2>/dev/null)" || _lg_rc_awk_file="$(pwd)/.lg-rc.$$"
            printf '%s\n' "$lg_rc_awk" > "$_lg_rc_awk_file" 2>/dev/null
            rc_col="$(awk -f "$_lg_rc_awk_file" "$progress_file" 2>/dev/null)" || rc_col=""
            rm -f "$_lg_rc_awk_file" 2>/dev/null
            if [ -n "$rc_col" ]; then
                # 数据行校验:非表头/非分隔行,Root Cause=a[c] 与 Prevention=a[c+1] 两列 strip 后均须非空且 != <待沉淀>
                # [2026-10-11 task-v168 CR F3] 修改原因: ① off-by-one——原 c+1 单列只读 Prevention,
                # 而 FAIL 消息文案写「Root Cause/Prevention」, 原 Root Cause=a[c] 列实际未校验; 现两列均校验(与文案一致)。
                # ② 模板行误挡——pristine 模板占位行(|  |  | 1 |...| <待沉淀> |)原会被判 bad → enforce 档硬挡纯净模板;
                # 现按 lg_tpl_awk 同款模式跳过模板行。
                lg_bad_awk='
/^## Error Log/ {in_sec=1; next}
in_sec && /^## / {in_sec=0}
in_sec {
    if ($0 !~ /^\|/) next
    # 模板占位行豁免(与 lg_tpl_awk 同款模式: 序号列为 1 的空行)
    if ($0 ~ /^\|[[:space:]]*\|[[:space:]]*\|[[:space:]]*1[[:space:]]*\|/) next
    v = $0
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    if (v ~ /Root[[:space:]]+Cause/ || v ~ /^-/) next
    n = split($0, a, "|")
    if (c < 2 || c > n - 1) next
    badflag = 0
    cell = a[c]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
    if (cell == "" || cell == "<待沉淀>" || cell == "待沉淀") badflag = 1
    cell2 = a[c + 1]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell2)
    if (cell2 == "" || cell2 == "<待沉淀>" || cell2 == "待沉淀") badflag = 1
    if (badflag) print NR
}'
                # 同上:程序存临时文件走 awk -f,免内联被截断
                _lg_bad_awk_file="$(mktemp "${TMPDIR:-/tmp}/lg-bad.XXXXXX" 2>/dev/null)" || _lg_bad_awk_file="$(pwd)/.lg-bad.$$"
                printf '%s\n' "$lg_bad_awk" > "$_lg_bad_awk_file" 2>/dev/null
                bad_lines="$(awk -v c="$rc_col" -f "$_lg_bad_awk_file" "$progress_file" 2>/dev/null)" || bad_lines=""
                lg_tpl_awk='
/^## Error Log/ {in_sec=1; next}
in_sec && /^## / {in_sec=0}
in_sec && $0 ~ /^\|[[:space:]]*\|[[:space:]]*\|[[:space:]]*1[[:space:]]*\|/ {n++}
END {print n+0}'
                _lg_tpl_awk_file="$(mktemp "${TMPDIR:-/tmp}/lg-tpl.XXXXXX" 2>/dev/null)" || _lg_tpl_awk_file="$(pwd)/.lg-tpl.$$"
                printf '%s\n' "$lg_tpl_awk" > "$_lg_tpl_awk_file" 2>/dev/null
                template_rows="$(awk -f "$_lg_tpl_awk_file" "$progress_file" 2>/dev/null)" || template_rows=0
                rm -f "$_lg_bad_awk_file" "$_lg_tpl_awk_file" 2>/dev/null
                if [ -n "$bad_lines" ]; then
                    learning_gate_rc=1
                    learning_gate_report="$(printf '%s\n' "$bad_lines" | tr '\n' ' ')"
                elif [ -z "$bad_lines" ] && [ "${template_rows:-0}" -eq 0 ]; then
                    learning_gate_rc=2   # 列存在但无任何数据行 = 无 Error 记录 → PASS 静默
                fi
            fi
            case "$learning_gate_rc" in
                0)
                    printf '%s\n' '[plan] LEARNING-GATE PASSED (Rule 31.5: Error Log Root Cause 全部非占位)' >&2
                    ;;
                1)
                    case "$ERROR_LOOP_TIER" in
                        enforce)
                            printf '%s\n' "[plan] LEARNING-GATE FAILED (task-v072 Rule 31.5: 行 ${learning_gate_report} Root Cause/Prevention 缺失或 <待沉淀> 占位 — 按 31.2 四问归因回填 progress.md Error Log 后重跑)" >&2
                            exit 1
                            ;;
                        *)
                            printf '%s\n' "[plan] LEARNING-GATE WARNING (task-v072 Rule 31.5, warn 档不阻断: TASK_PLANNER_ERROR_LOOP_ENFORCE=enforce 或 config.json error_loop_enforce=enforce 可升级) — 行 ${learning_gate_report} Root Cause/Prevention 缺失或 <待沉淀> 占位" >&2
                            ;;
                    esac
                    ;;
                *)
                    : # rc=2 无数据行 / 无表头 = 存量兼容,PASS 静默
                    ;;
            esac
        fi
    fi

    # [2026-09-15 task-v074 Rule 33] 终验 Reflect Gate — 解决→反思→验证迭代循环:
    # 计划声明 reflect_verify: required 时,progress.md 须含 ≥2 行 `- [reflect] ` 前缀行
    # (33.3 落盘格式:反思+验证各至少 1)。未声明 → SKIPPED 不算失败;无 progress.md → SKIPPED。
    # 档位: env TASK_PLANNER_REFLECT_VERIFY_ENFORCE > config.json reflect_verify_enforce > warn;
    # enforce=缺失时 exit 1 / warn=仅 stderr 告警 / off=跳过(与 LEARNING-GATE 同解析范式)
    resolve_reflect_verify_tier() {
        local m="${TASK_PLANNER_REFLECT_VERIFY_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ]; then
            # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
            m="$(jq -r '.reflect_verify_enforce // .properties.reflect_verify_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    REFLECT_VERIFY_TIER="$(resolve_reflect_verify_tier)"
    # [2026-10-11 task-v167 Rule 38.7] L0 skip REFLECT-GATE（Why: 反思-验证迭代循环=多轮执行面,
    # L0 单 Phase 微变更不产生反思迭代需求; 保留线=LANE-L0 GATE 三段终验锚不跳）
    if [ "${LANE_L0:-0}" = 1 ]; then
        printf '[lane-L0] skip REFLECT-GATE（38.7 非适用项: L0 单 Phase 无反思迭代面）\n' >&2
        REFLECT_VERIFY_TIER="off"
    fi
    if [ "$REFLECT_VERIFY_TIER" != "off" ]; then
        if ! grep -q 'reflect_verify: required' "$PLAN_FILE" 2>/dev/null; then
            printf '[plan] REFLECT-GATE SKIPPED (task_plan.md 未声明 reflect_verify: required)\n' >&2
        else
            progress_file="$(dirname "$PLAN_FILE")/progress.md"
            if [ ! -f "$progress_file" ]; then
                printf '[plan] REFLECT-GATE SKIPPED (无 progress.md,无法校验 [reflect] 行)\n' >&2
            else
                reflect_lines="$(grep -c '^- \[reflect\] ' "$progress_file" 2>/dev/null)" || reflect_lines=0
                if [ "${reflect_lines:-0}" -ge 2 ]; then
                    printf '[plan] REFLECT-GATE PASSED (Rule 33: 反思-验证记录在案)\n' >&2
                else
                    case "$REFLECT_VERIFY_TIER" in
                        enforce)
                            printf '%s\n' "[plan] REFLECT-GATE FAILED (task-v074 Rule 33: 计划声明 reflect_verify: required 但 progress.md [reflect] 行=${reflect_lines:-0} <2 — 按 33.2 反思四问 + 33.3 独立验证补写 [reflect] 两行后重跑)" >&2
                            exit 1
                            ;;
                        *)
                            printf '%s\n' "[plan] REFLECT-GATE WARNING (task-v074 Rule 33, warn 档不阻断: TASK_PLANNER_REFLECT_VERIFY_ENFORCE=enforce 或 config.json reflect_verify_enforce=enforce 可升级) — 计划声明 reflect_verify: required 但 progress.md [reflect] 行=${reflect_lines:-0} <2" >&2
                            ;;
                    esac
                fi
            fi
        fi
    fi

    # [2026-09-17 task-v079] SKILL-MODIFY GATE (Rule 36.6/36.7②): 删除性行为清单登记校验
    # 涉及技能文件修改的计划(task_plan.md 执行范围限制段含 skills/task-planner/),
    # progress.md 须登记「删除性行为清单」或显式声明无功能性删除,否则按档位处理。
    resolve_skill_modify_tier() {
        local m="${TASK_PLANNER_SKILL_MODIFY_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ]; then
            # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
            m="$(jq -r '.skill_modify_enforce // .properties.skill_modify_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    SKILL_MODIFY_TIER="$(resolve_skill_modify_tier)"
    if [ "$SKILL_MODIFY_TIER" != "off" ] && grep -q 'skills/task-planner/' "$PLAN_FILE" 2>/dev/null; then
        sm_progress="$(dirname "$PLAN_FILE")/progress.md"
        if [ ! -f "$sm_progress" ]; then
            printf '[plan] SKILL-MODIFY GATE SKIPPED (无 progress.md,无法校验删除性行为清单)\n' >&2
        elif grep -E '删除性行为清单' "$sm_progress" 2>/dev/null \
            || grep -F '[skill-modify] 无功能性删除' "$sm_progress" 2>/dev/null \
            || grep -F '[skill-modify] 删除清单:' "$sm_progress" 2>/dev/null; then
            printf '[plan] SKILL-MODIFY GATE PASSED (Rule 36.6: 删除性行为清单/无删除声明已登记)\n' >&2
        else
            case "$SKILL_MODIFY_TIER" in
                enforce)
                    printf '%s\n' "[plan] SKILL-MODIFY GATE FAILED (task-v079 Rule 36.6: 涉及技能文件修改的任务须登记删除性行为清单或声明无功能性删除——对照 36.3 基线逐项确认后回填 progress.md 重跑)" >&2
                    exit 1
                    ;;
                *)
                    printf '%s\n' "[plan] SKILL-MODIFY GATE WARNING (task-v079 Rule 36.6, warn 档不阻断: TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce 可升级) — 未登记删除性行为清单/无删除声明" >&2
                    ;;
            esac
        fi
    else
        printf '[plan] SKILL-MODIFY GATE SKIPPED (计划未声明涉及技能文件修改)\n' >&2
    fi

    # [2026-09-20 task-v085 Rule 37] 机制画像抽查：内容组 (writing/research/publish) 计划声明 code_review: required 时，
    # warn=仅 stderr 提示不改 exit / enforce=exit 1 / off=跳过。档位 env > config.json mechanism_profile_enforce > warn(jq 缺失 fail-open)。
    mp_tier="${TASK_PLANNER_MECHANISM_PROFILE_ENFORCE:-}"
    # [2026-09-26 task-v091 C-1b：双层路径修复，顶层覆盖优先] 原单层路径致覆盖静默失效
    case "$mp_tier" in enforce|warn|off) ;; *) mp_tier="$(jq -r '.mechanism_profile_enforce // .properties.mechanism_profile_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || mp_tier=""; case "$mp_tier" in enforce|warn|off) ;; *) mp_tier="warn" ;; esac ;; esac
    if [ "$mp_tier" != "off" ]; then
        # [2026-10-11 task-v167 Rule 38.7] L0 skip mechanism-profile（Why: 机制画像抽查=内容组
        # 派发面, L0 无派发; 保留线=SKILL-MODIFY GATE 与 LANE-L0 GATE 不跳）
        if [ "${LANE_L0:-0}" = 1 ]; then
            printf '[lane-L0] skip mechanism-profile（38.7 非适用项: L0 无派发面）\n' >&2
        else
        mp_tt="$(grep -m1 '^template_type:' "$PLAN_FILE" 2>/dev/null | sed 's/^template_type:[[:space:]]*//;s/[[:space:]]*$//')"; mp_tt="${mp_tt%%[[:space:]（]*}"
        [ -z "$mp_tt" ] && mp_tt="$(grep -m1 'template_type' "$PLAN_FILE" 2>/dev/null | awk -F'|' '{for(i=1;i<=NF;i++){t=$i;gsub(/[[:space:]`]/,"",t);if(t=="template_type"){v=$(i+1);gsub(/[[:space:]`]/,"",v);print v;exit}}}' | head -1 | sed 's/（.*//')"
        case "$mp_tt" in writing|research|publish) grep -qE 'code_review: required|^[[:space:]]*\|[[:space:]]*`?code_review`?[[:space:]]*\|[[:space:]]*`?required`?[[:space:]]*\|' "$PLAN_FILE" 2>/dev/null && case "$mp_tier" in enforce) echo "[mechanism-profile] ✗ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；enforce 档 exit 1 — 显式例外须在计划 Decisions 登记理由或改 n/a）" >&2; exit 1 ;; *) echo "[mechanism-profile] ⚠ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；如属显式例外请登记理由）" >&2 ;; esac ;; esac
        fi
    fi

    # [2026-09-27 task-v091 S23 A-1 Rule 38.6] 终验 AUTO-TIER 复核段（提案 A-1 误判闭环，S22 风险①）:
    # 消费 S22 自动降档标记（auto_tier: mini）→ 复核实际体量是否超限（Phase 数>2 或 执行范围表
    # 数据行>2，机器可测口径同 CPD 38.1 MISMATCH 探针）→ 超限 WARNING 点名，warn 档不阻断
    # （Rule 38.6 明文「误判闭环止于 warn 的补强」；不消费新 config 键 → S20 C-2 键④五键枚举零扰动）。
    # 插入位=mechanism-profile 段后，位于 C-2 键③哈希覆盖段（:484 sed 锚对所夹区间）之外——注释
    # 措辞避开锚字面量，键③哈希与 S20 落地版逐字节一致（SKIP 块零扰动）。无标记/显式 mini 零影响。
    if grep -qm1 'auto_tier: mini' "$PLAN_FILE" 2>/dev/null; then
        atier_items=""
        atier_phases="$(grep -cE '^###[[:space:]]+Phase' "$PLAN_FILE" 2>/dev/null || true)"
        [ "${atier_phases:-0}" -gt 2 ] && atier_items="Phase 数=${atier_phases} >2 "
        atier_scope="$(awk '/^##[[:space:]]*.*执行范围限制/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null | grep -c '^|' || true)"
        [ "${atier_scope:-0}" -gt 4 ] && atier_items="${atier_items}执行范围表数据行>2（表格行=${atier_scope}） "
        if [ -n "$atier_items" ]; then
            printf '[plan] AUTO-TIER WARNING (task-v091 S23 Rule 38.6 复核, warn 档不阻断): auto_tier=mini 但实际体量超限 — %s — 误降档计划带收缩门组走完全程, 复核任务体量与 38.1 条件（后续任务可显式 TASK_PLAN_TIER=standard）\n' "${atier_items% }" >&2
        else
            printf '[plan] AUTO-TIER REVIEW PASSED (auto_tier=mini 体量复核合规: Phase ≤2 ∧ 执行范围表数据行 ≤2)\n' >&2
        fi
    fi

    # [2026-09-27 task-v091 S27 A-3] 终验 COMPLIANCE-CHECK 抽查段（提案 A-3「先加后删」护栏，终审 #8 互锁）:
    # 对 SKILL C 表声称「机器门承载」的关键可机器查产物做抽查点名——缺失 → [compliance] WARNING
    # 点名（warn 档不阻断，exit 码仍为 python_rc）。映射表=脚本内表（提案「脚本内表或 registry」取舍:
    # 零新文件、零 registry 同步负担，与 AUTO-TIER 段同范式）。
    # tier 感知分域（终审 #8 防 A-1 提高 mini 命中率后新断言误报）: 复用 :606 PLAN_TIER_MINI 前置判定——
    #   standard 域=全量抽查；mini 域只检 mini 适用子集（3-File / VC 行数降档 / Handoff 存在性），
    #   委派率 38.4③ floor 豁免项与 mini-lite 模板无产物的「委派统计段 / Handoff verify_done」两项在 mini 域跳过。
    # 插入位=本段位于 C-2 键③哈希覆盖段（FMEA 段）之后（注释措辞避开锚字面量，键③哈希零扰动），
    # S20/S23 既有块语义零改动（仅紧邻插入）；本段不消费新 config 键 → 键④五键枚举零扰动。
    compliance_missing=""
    cc_plan_dir="$(dirname "$PLAN_FILE")"
    if [ "${LANE_L0:-0}" = 1 ]; then
        # [2026-10-11 task-v167 Rule 38.7] L0 skip COMPLIANCE-CHECK（Why: 抽查段=委派统计/S-unit
        # 表/Handoff 登记等派发型产物面, L0 无派发无统计段; L0 簿记面由 LANE-L0 GATE 三段独立承载）
        printf '[lane-L0] skip COMPLIANCE-CHECK（38.7 非适用项: 派发型抽查面无, L0 簿记面由 LANE-L0 GATE 承载）\n' >&2
    else
    # ① 3-File 抽查（Rule 19.5/C16 承载声称）: mini/standard 同域（mini 38.3 区块白名单要求三文件，降档=19.2 非豁免）
    for cf in findings.md progress.md; do
        [ -f "$cc_plan_dir/$cf" ] || compliance_missing="${compliance_missing} 3-File ${cf} missing(C16/Rule 19.5) "
    done
    # ② VC 表行数（C6 承载声称）: 档位阈值与 VC-GATE 分域同口径 standard≥5 / mini≥2
    comp_vc_count="$(grep -cE '^\|[[:space:]]*VC-[0-9]+' "$PLAN_FILE" 2>/dev/null || true)"
    comp_vc_min=5; [ "${PLAN_TIER_MINI:-0}" = 1 ] && comp_vc_min=2
    [ "${comp_vc_count:-0}" -lt "$comp_vc_min" ] && compliance_missing="${compliance_missing} VC表=${comp_vc_count:-0}<${comp_vc_min}(C6) "
    # ③④ 仅 standard 域: mini 域 38.4③ 委派率豁免 + mini-lite 六列 Handoff 无 verify_done 列/无委派统计段产物 → 跳过不误报
    if [ "${PLAN_TIER_MINI:-0}" != 1 ]; then
        # ③ 委派统计段（Rule 25/C14 承载声称: verification.md「委派统计」段为委派率统计落点）
        grep -q '委派统计' "$cc_plan_dir/verification.md" 2>/dev/null || compliance_missing="${compliance_missing} verification.md 委派统计段缺失(C14/Rule 25) "
        # ③b S-unit 表抽查（Rule 22.6/C14 承载声称, 口径同 CPD 38.4④）: 声明子代理 Executor 的
        #     派发型计划须有 `| ID |…执行体…` 表头 + ≥1 行 `| S<n> |` 数据行；38.4④ 全主进程豁免跳过
        comp_sunit_hdr="$(grep -cE '^\|[[:space:]]*ID[[:space:]]*\|' "$PLAN_FILE" 2>/dev/null || true)"
        comp_sunit_rows="$(grep -cE '^\|[[:space:]]*S[0-9]+[[:space:]]*\|' "$PLAN_FILE" 2>/dev/null || true)"
        comp_subagent_pre="$(grep -E '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null | grep -vc '主进程' || true)"
        if [ "${comp_subagent_pre:-0}" -gt 0 ] && [ "${comp_sunit_hdr:-0}" -eq 0 ]; then
            compliance_missing="${compliance_missing} 派发型缺S-unit表(表头=0,Rule 22.6/C14) "
        elif [ "${comp_subagent_pre:-0}" -gt 0 ] && [ "${comp_sunit_hdr:-0}" -gt 0 ] && [ "${comp_sunit_rows:-0}" -eq 0 ]; then
            compliance_missing="${compliance_missing} S-unit表数据行=0(有表头无S行,Rule 22.6/C14) "
        fi
        # ④ Handoff 登记抽查（Rule 22.5/C16 承载声称: 声明子代理 Executor 时须有已填数据行且 verify_done 已勾）
        comp_subagent_exec="$(grep -E '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null | grep -vc '主进程' || true)"
        if [ "${comp_subagent_exec:-0}" -gt 0 ]; then
            # Handoff 数据行= `| N |` 开头且第 5 列（任务目标）非空非占位；限「Subagent Handoff 登记表」节内
            # （节标题锚=standard/mini-lite 两模板共有的「Subagent Handoff 登记表」字样，遇下一 ## 节截止）
            comp_handoff_filled="$(awk '/Subagent Handoff 登记表/{f=1;next} f&&/^##[[:space:]]/{f=0} f&&/^[[:space:]]*\|[[:space:]]*[0-9]+[[:space:]]*\|/{c=$5;gsub(/^[[:space:]]+|[[:space:]]+$/,"",c);if(c!=""&&c!="[任务目标(≤1句)]")n++}END{print n+0}' "$PLAN_FILE" 2>/dev/null)"
            if [ "${comp_handoff_filled:-0}" -eq 0 ]; then
                compliance_missing="${compliance_missing} Handoff登记表未回填(声明${comp_subagent_exec}个子代理Executor,Rule 22.5/C16) "
            else
                # verify_done 列位由表头行动态定位（仅 `|` 开头表头行，避开 HTML 注释内 mention；
                # B-2 列位折叠后自动跟列位）; 表头无该列 → fail-open 跳过
                comp_vd_col="$(grep -m1 '^[[:space:]]*|.*verify_done' "$PLAN_FILE" 2>/dev/null | awk -F'|' '{for(i=2;i<=NF;i++){v=$i;gsub(/^[[:space:]]+|[[:space:]]+$/,"",v);if(v=="verify_done"){print i;exit}}}' 2>/dev/null)"
                if [ -n "$comp_vd_col" ]; then
                    comp_vd_unchecked="$(awk -v c="$comp_vd_col" '/Subagent Handoff 登记表/{f=1;next} f&&/^##[[:space:]]/{f=0} f&&/^[[:space:]]*\|[[:space:]]*[0-9]+[[:space:]]*\|/{v=$c;gsub(/^[[:space:]]+|[[:space:]]+$/,"",v);if(v=="☐"||v==""||v=="[ ]")n++}END{print n+0}' "$PLAN_FILE" 2>/dev/null)"
                    [ "${comp_vd_unchecked:-0}" -gt 0 ] && compliance_missing="${compliance_missing} Handoff ${comp_vd_unchecked}行verify_done未勾(Rule 22.5/C16) "
                fi
            fi
        fi
    fi
    comp_tier_label="standard"; [ "${PLAN_TIER_MINI:-0}" = 1 ] && comp_tier_label="mini"
    if [ -n "$compliance_missing" ]; then
        printf '[compliance] WARNING (task-v091 A-3 终验抽查, warn 档不阻断, tier=%s 分域): 抽查缺项点名 — %s\n' "$comp_tier_label" "${compliance_missing% }" >&2
    else
        printf '[compliance] OK (task-v091 A-3 终验抽查通过, tier=%s 分域: 3-File/VC 行数%s/委派统计段%s/Handoff verify_done%s)\n' \
            "$comp_tier_label" \
            "$([ "$comp_tier_label" = mini ] && printf 降档阈值 || printf 全量)" \
            "$([ "$comp_tier_label" = mini ] && printf 豁免跳过 || printf 已检)" \
            "$([ "$comp_tier_label" = mini ] && printf 豁免跳过 || printf 已检)" >&2
    fi
    fi

    # [2026-10-09 task-v151 S3] Rule 66.3 Goal 单元表终验对照段
    # WHAT: 逐行对照 Goal 单元表 status=complete 的 goal 行与 progress.md [goal:Gn] 证据行
    #       + 存在 pending goal 行时降级 PARTIAL 提示
    # WHY: Rule 66.3 逐 goal 验证通过门——goal 行翻 complete 前必须①实跑验证方式 ②progress.md
    #      追加 [goal:Gn] 证据行（验证命令+PASS 结果+产物路径，三要素）；缺任一=禁止翻格。
    #      check-complete.sh 终验逐行对照（66.3 机器面），exit 1 与 64.2 门控同档
    # 挂点: COMPLIANCE-CHECK 段后、warn count 段前（终验段内，python_rc=0 条件下）
    # mini 档: 整段跳过（66.5 mini 豁免）
    # 输出前缀: [goal-gate] 便于 selftest 锚定（G-06）
    # [2026-10-09 task-v151 CR F2] 档位口径与 check-plan-dispatch.sh 66.5 三分支统一：
    #   What：原判定=`[ "${PLAN_TIER_MINI:-0}" != 1 ]`（非 mini 即进入 goal-gate），
    #         即「无 plan_tier 标记」的 legacy/合成夹具也会进入终验 goal-gate 段。
    #   Why ：check-plan-dispatch 采用 D2 裁决「仅显式 plan_tier: standard|full 才硬门；
    #         无标记=缺省档跳过」。二者分叉 → 无标记计划出现「attest 门放行、终验门却对
    #         complete 无 [goal:Gn] 证据 exit 1」的两门口径不一致。修正=统一为显式 standard|full
    #         才进入；无标记（legacy/合成夹具）与显式 mini 均跳过（66.5 mini 豁免 + 缺省档兼容）。
    #   原行为：`[ "${PLAN_TIER_MINI:-0}" != 1 ]`（无标记亦进入，与 attest 门分叉）。
    if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then
        # [2026-10-16 P-01 (终审意见 7)] EVIDENCE-ANCHOR GATE — goal-gate 段前置 shell-out（--source=goal）
        # 判定面 = progress.md 含 [goal:Gn] 的证据行（整行视为证据文本）：路径存在 / 行号 ≤ 文件行数 /
        # provenance 三层。门控范围与 goal-gate 自身对齐（同受 plan_tier: standard|full 门控，
        # mini 档 66.5 豁免 + 无标记 legacy 跳过 = 零行为变化）。
        run_evidence_anchor goal
        # awk 状态机抽「^## 🎯 Goal 单元表」区块（参照脚本行 92-94 既有状态机写法，禁区间 next 坍缩范式）
        goal_gate_sec="$(awk '/^##[[:space:]]*🎯[[:space:]]*Goal[[:space:]]*单元表/{f=1;next} /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null)"
        if [ -z "$goal_gate_sec" ]; then
            # 区块缺失=该段静默跳过+一行提示（不 exit 1）
            printf '[goal-gate] SKIPPED (计划无「🎯 Goal 单元表」区块, 66.5 mini 豁免或旧计划)\n' >&2
        else
            # 数据行提取: goal-id($2) + 状态($7)（六列契约: goal-id|任务名|目标|完整验证方式|对应S-unit/Phase|状态）
            goal_gate_complete=""
            goal_gate_pending=""
            while IFS= read -r row; do
                [ -n "$row" ] || continue
                gid="$(printf '%s' "$row" | awk -F'|' '{v=$2; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); print v}')"
                status="$(printf '%s' "$row" | awk -F'|' '{v=$7; gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); print v}')"
                case "$status" in
                    complete) goal_gate_complete="${goal_gate_complete} ${gid}" ;;
                    pending) goal_gate_pending="${goal_gate_pending} ${gid}" ;;
                esac
            done < <(printf '%s\n' "$goal_gate_sec" | grep -E '^\|[[:space:]]*G[0-9]+[[:space:]]*\|' || true)

            # ② status=complete 的 goal 行 → progress.md grep [goal:Gn] 证据行，缺 → exit 1
            # [2026-10-15 task-v176 D5] 证据行三要素强化校验（What）：存在性 grep 之后追加窗口校验——
            # [goal:Gn] 证据行同行或相邻 2 行内须命中三要素信号正则 (bash|bun|node|python|PASS|✅|FAIL=0|exit 0)
            # 至少其一，否则 fail-closed exit 1（与 66.3 禁翻格同档）。
            # Why: 原 `grep -q "[goal:Gn]"` 仅验存在性——一条 `- [goal:G1]` 空行即放行（S1-9 实证），
            # 66.3「实跑通过」退化为「写了行」。三要素=验证命令词(bash/bun/node/python)∨PASS 结果(✅/PASS/
            # FAIL=0/exit 0)∨产物路径（路径自由文本不可机器断言，取命令词+结果信号两族兜底）；窗口=±2 行，
            # 覆盖「命令在上、PASS 在下」的同段证据形态。fail-closed 方向=阻断（记录失真面，非门控故障面）。
            # [2026-10-15 task-v176 CR 修复 MINOR-3] 命令词类加词界 \b(bash|bun|node|python)\b：
            # 原裸子串匹配使叙述文本含 "node"（如「node_modules 目录清理」）即误过三要素校验——
            # 命令词信号须为独立单词才算「验证命令」语义；PASS/✅/FAIL=0/exit 0 为结果信号
            # （FAIL=0 本身含词界语义、exit 0 带空格定界），保持原样不加强。
            # [2026-10-15 task-v176 CR 二轮回修] 首轮修复把词界写成源码双反斜杠 \\b——ERE 中双反斜杠=
            # 字面「反斜杠+b」而非词界断言，命令词分支恒不匹配（实测 bash/bun/node/python 四词全不命中，
            # 接受面比修复前更窄）；本轮回修为源码单反斜杠 \b（ERE 词界断言）。stderr 消息串同步去掉
            # \b 字面（printf 格式串中 \b 被解释为退格符）改文字描述。实测判据：`bash x.sh` 命中、
            # `node_modules 清理` 不命中（词界有效，描述性词不代偿命令词信号）。
            goal_gate_fail=0
            for gid in $goal_gate_complete; do
                if ! grep -q "\[goal:${gid}\]" "$PLAN_DIR_GUESS/progress.md" 2>/dev/null; then
                    printf '[goal-gate] ✗ %s complete 无 [goal:%s] 证据行 (Rule 66.3: 补 progress.md 证据行后重跑)\n' "$gid" "$gid" >&2
                    goal_gate_fail=1
                    continue
                fi
                # [2026-10-15 task-v176 D5] 窗口抽取：awk 两遍式（先存全量行再扫 marker），输出每个
                # [goal:Gn] 命中行的 ±2 行窗口文本（首尾截断）；空窗口或窗口内无信号 → fail。
                _g_ev_window="$(awk -v m="[goal:${gid}]" '
                    { arr[NR] = $0 }
                    END {
                        for (i = 1; i <= NR; i++) {
                            if (index(arr[i], m)) {
                                s = (i > 2 ? i - 2 : 1); e = (i + 2 <= NR ? i + 2 : NR)
                                for (j = s; j <= e; j++) print arr[j]
                            }
                        }
                    }' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null || true)"
                if [ -z "$_g_ev_window" ] || ! printf '%s\n' "$_g_ev_window" | grep -qE '(\b(bash|bun|node|python)\b|PASS|✅|FAIL=0|exit 0)'; then
                    printf '[goal-gate] ✗ %s [goal:%s] 证据行缺三要素信号（同行或 ±2 行窗口内未命中 (命令词 bash/bun/node/python 独立单词 | PASS|✅|FAIL=0|exit 0 结果信号)；Rule 66.3 三要素=验证命令+PASS 结果+产物路径, 空行/纯叙述行不构成证据; task-v176 D5 + CR MINOR-3 命令词词界（CR 二轮单反斜杠回修））— 补实跑证据后重跑\n' "$gid" "$gid" >&2
                    goal_gate_fail=1
                fi
            done
            [ "$goal_gate_fail" -eq 1 ] && exit 1

            # ③ 存在 status=pending 的 goal 行 → 降级 PARTIAL 提示（不单独 exit 1，58.5 三态语义对齐）
            [ -n "$goal_gate_pending" ] && printf '[goal-gate] ⚠ 有 goal 未 complete (%s), 终态最高 PARTIAL (Rule 66.3/58.5)\n' "${goal_gate_pending# }" >&2

            # [2026-10-15 task-v176 D12] R 锚定复诵机器断言（goal-gate 同区段新增断言，非新门段——
            # 与 66.3 goal-gate 共享 plan_tier: standard|full 门控，故挂本条件块内）：
            # What: progress.md 每个 `### Phase` 标题段须含 `- **R 锚定**：` 行（逐段判定+计数对齐口径：
            #       awk 状态机逐段扫描，任一 Phase 段 0 命中 → fail-closed exit 1，并点名缺失段标题；
            #       逐段判定同时覆盖「全文件行数对齐但分布错位」的计数对齐漏洞——游离 R 锚定行
            #       不得为缺段段代偿）。
            # Why: v168「R 锚定复诵」（SKILL.md 流程 1「progress 段首行写 - **R 锚定**：本 Phase 服务 R<n>」）
            #       此前 0 脚本断言（S1 审计 A 类①「声称无承载」）——纪律退化无机器检测面，记录失真不可复验；
            #       本断言为其最小机器承载（只验存在性+计数对齐，不验复述内容语义，避免越权判「复述是否准确」）。
            # 口径: 段=标题行后至下一个 `### Phase` 标题前；progress.md 缺失或零 `### Phase` 段 → 静默跳过
            #       （存量计划/未开 Phase 面，fail-open 不误伤；L0/mini 由本块 plan_tier 门控天然豁免）。
            # [2026-10-15 task-v176 CR 修复 MINOR-4] R 锚定行匹配加行首锚（允许前导空白）：
            # 原裸子串匹配使段内描述性文字含「- **R 锚定**：」字样即可代偿缺行——与 write 侧
            # SKILL.md 流程 1「progress 段首行写 - **R 锚定**：本 Phase 服务 R<n>」契约对齐，
            # 判定面收紧为「列表行形态（行首/前导空白后以 `- **R 锚定**：` 起行）」，描述性内嵌引用不再代偿。
            _ra_prog="$PLAN_DIR_GUESS/progress.md"
            if [ -f "$_ra_prog" ]; then
                _ra_total_phases="$(grep -cE '^###[[:space:]]+Phase' "$_ra_prog" 2>/dev/null || true)"
                case "${_ra_total_phases:-}" in ''|*[!0-9]*) _ra_total_phases=0 ;; esac
                if [ "$_ra_total_phases" -ge 1 ]; then
                    _ra_anchor_n="$(grep -cE '^[[:space:]]*- \*\*R 锚定\*\*：' "$_ra_prog" 2>/dev/null || true)"
                    case "${_ra_anchor_n:-}" in ''|*[!0-9]*) _ra_anchor_n=0 ;; esac
                    # awk 状态机定位首个缺 R 锚定的 Phase 段标题（遇下一 Phase 标题时回溯判上一段
                    # cnt==0；END 判末段）；missing 只在首次命中时写入=「首个缺失段」而非末个；全在案→空
                    _ra_missing_ph="$(awk '
                        /^###[[:space:]]+Phase/ { if (missing == "" && started && cnt == 0) missing = title; started = 1; title = $0; cnt = 0; next }
                        /^[[:space:]]*- \*\*R 锚定\*\*：/ { if (started) cnt++ }
                        END { if (missing == "" && started && cnt == 0) missing = title; print missing }' "$_ra_prog" 2>/dev/null || true)"
                    # 判定面=逐段 awk（grep 全文件计数仅作展示——计数对齐是必要非充分条件：
                    # Phase 外游离 R 锚定行 + 某段缺行时总数仍对齐，逐段判定才不漏）
                    if [ -n "$_ra_missing_ph" ]; then
                        printf '[goal-gate] ✗ progress.md R 锚定复诵缺失（v168 逻辑层, task-v176 D12）: 段「%s」无「- **R 锚定**：」行（### Phase 段 %s 个 / 全文件 R 锚定行 %s，须逐段在案且计数对齐）— 补该段段首 R 锚定行后重跑\n' \
                            "$_ra_missing_ph" "$_ra_total_phases" "$_ra_anchor_n" >&2
                        exit 1
                    fi
                fi
            fi
        fi
    else
        printf '[goal-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 66.5)\n' >&2
    fi

    # [2026-10-11 task-v167 Rule 38.7] LANE-L0 GATE — L0 微变更通道专属三段校验（插于 goal-gate 后、judge-gate 前）
    # 定位=38.7「L0 薄 verification」的机器化保留线: 跳过的门（Batch/3File/FMEA/DELEGATION/VC计数/
    # R-COVERAGE/LEARNING/REFLECT/COMPLIANCE 等）都不降完成性底线——本段三件校验缺一即 exit 1:
    #   ① verification.md 存在且含「全量终验」字样 + Total 行（run=N 且 PASS=N=总脚本数——
    #      交付前单波 fresh 全量终验锚; 缺=fail-closed, 38.7「相关 selftest 子集 + 交付前全量终验」的机器承载）
    #      [task-perf-opt Change #4] Total 行格式=「Total: N PASS=x FAIL=y（+可选 reused=z）」，簿记可只抄前半
    #      （PASS=FAIL=Total）；缓存命中时 reused 计入 Total 行。GATE 只 grep `Total:`（不校验 PASS=/reused=
    #      是否存在），接受任意含 Total: 的行——缓存复用的 reused 行合法，无需修改校验口径（实测确认不误读）。
    #   ② task_plan.md Phase 状态真实翻转: 至少 1 行 `- **Status:** complete`（防状态机假完成）
    #   ③ 单 commit 惯性: 计划 scope 内 git log feat 提交数=1, 或计划 Decisions Made 区块声明
    #      「单 commit」惯性偏差理由（38.7 簿记精简=单 commit, 多 commit 须显式声明机理由）
    if [ "${LANE_L0:-0}" = 1 ]; then
        l0_fail=""
        l0_vf="$PLAN_DIR_GUESS/verification.md"
        if [ ! -f "$l0_vf" ] || ! grep -q '全量终验' "$l0_vf" 2>/dev/null || ! grep -qE 'Total:' "$l0_vf" 2>/dev/null; then
            l0_fail="${l0_fail}①verification.md 缺「全量终验」+Total 行（run=N/PASS=N 锚） "
        else
            # [M2-fix 2026-10-14] 结果性校验：Total 行 FAIL=N（N>0）→ ①不通过
            # 原 GATE 只验存在性（Total: 行有值即可放行），升级：FAIL>0 须补 fresh 全量重跑
            _l0_fail_n="$(grep -oE 'FAIL=[0-9]+' "$l0_vf" 2>/dev/null | head -1 | grep -oE '[0-9]+' || true)"
            if [ -n "${_l0_fail_n:-}" ] && [ "$_l0_fail_n" -gt 0 ]; then
                l0_fail="${l0_fail}①全量终验 FAIL=${_l0_fail_n}>0（L0 底线=0 FAIL；FAIL>0 须补 fresh 全量重跑） "
            fi
        fi
        l0_ph_n="$(grep -cE '\*\*Status:\*\*[[:space:]]*complete' "$PLAN_FILE" 2>/dev/null || true)"
        l0_ph_n="${l0_ph_n:-0}"
        [ "$l0_ph_n" -ge 1 ] || l0_fail="${l0_fail}②task_plan.md 无 complete Phase 行（状态未真实翻转） "
        # ③ 单 commit 惯性: 在 git 仓内对计划 scope（执行范围限制表允许文件列）数 feat|fix 提交;
        # [task-perf-opt Change #1④] feat→feat\|fix: trivial 代码修复档（Change #1）的 commit 前缀为 `fix:`，
        # 原 `--grep='feat'` 不匹配 `fix:` → L0 GATE ③ 对代码修复误判（feat 提交数=0≠1 → 阻断）。
        # 非 git 仓/无 git = fail-open（L0 定义在 git 体系内, 非 git 场景由人工兜底）
        repo_root="$(cd "$(dirname "$PLAN_FILE")" && git rev-parse --show-toplevel 2>/dev/null || true)"
        if [ -n "$repo_root" ]; then
            l0_ncommits="$(git -C "$repo_root" log --oneline --grep='feat\|fix' --since='30 days ago' 2>/dev/null | grep -c . || true)"
            if [ "${l0_ncommits:-0}" -ne 1 ] \
               && ! grep -qE '单[[:space:]]*commit|单commit' "$PLAN_FILE" 2>/dev/null; then
                # Decisions 声明口径: 计划内任意位置含「单 commit」声明视为机理由登记（38.7 簿记精简口径）
                [ -n "$(awk '/^##[[:space:]]*Decisions Made/{f=1; next} f && /^##[[:space:]]/{f=0} f' "$PLAN_FILE" 2>/dev/null | grep -E 'commit')" ] \
                    || l0_fail="${l0_fail}③单 commit 惯性缺口（feat|fix 提交数=${l0_ncommits:-0}≠1 且 Decisions 无机理由声明） "
            fi
        fi
        if [ -n "$l0_fail" ]; then
            printf '[lane-L0] LANE-L0 GATE FAILED（38.7 L0 保留线: %s — 补 fresh 全量终验/状态翻转/commit 声明后重跑）\n' "${l0_fail% }" >&2
            exit 1
        fi
        printf '[lane-L0] LANE-L0 GATE PASS（①verification 全量终验+Total 锚在案 ②Phase complete 翻转在案 ③单 commit 惯性合规/声明在案）\n' >&2
    fi

    # [2026-10-10 task-v156] Rule 73.4 [judge-gate] 强制评判点终验对照段
    # WHAT: standard/full 档计划对照 progress.md [judge]/[align] 留痕行数—— Phase complete 前
    #       强制评判（73.4②）未留痕=评判未执行；warn 默认提示，env TASK_PLANNER_DECISION_JUDGE=enforce 升 exit 1。
    # WHY: 用户 R3「周期性评判数据、及时发现错误」+R4「每次做出决定/更改前对齐设定」的机器承载面。
    # 档位: 仅 plan_tier: standard|full 进入（mini 档豁免，同 goal-gate 门控范式）;env TASK_PLANNER_DECISION_JUDGE = off(跳过)/enforce(缺失 exit 1)/默认 warn(提示不阻断)
    # [2026-10-10 06b 修正] 计数行鲁棒化：grep -c 零匹配已打印 0 且 exit 1 → `|| echo 0` 会捕获
    #       "0\n0" 致 [ -eq ] 报错、闸门对失败面静默失效；改 `|| true`+case 兜底（覆盖文件缺失/空值）
    # [2026-10-10 CR S8 修正] 档位门控补全（MAJOR）：按 goal-gate 同款 grep plan_tier 前置门,
    #       mini/legacy 计划走 SKIPPED 分支——否则 warn 对 mini 误报、enforce 对 mini exit 1 违背 C51「mini 档豁免」契约
    if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then
      case "${TASK_PLANNER_DECISION_JUDGE:-warn}" in
        off) printf '[judge-gate] SKIPPED (env TASK_PLANNER_DECISION_JUDGE=off)\n' >&2 ;;
        enforce|warn)
          _jl="$(grep -c '\[judge\]\|\[align\]' "$PLAN_DIR_GUESS/progress.md" 2>/dev/null || true)"
          case "$_jl" in ''|*[!0-9]*) _jl=0 ;; esac
          if [ "$_jl" -eq 0 ]; then
            printf '[judge-gate] ✗ progress.md 无 [judge]/[align] 留痕行 (Rule 73.4: 变更决策后/Phase complete 前/合并回前各一次评判)\n' >&2
            [ "${TASK_PLANNER_DECISION_JUDGE:-warn}" = enforce ] && exit 1
          else
            printf '[judge-gate] OK ([judge]/[align] 留痕 %s 行, Rule 73.4)\n' "$_jl" >&2
          fi
          ;;
      esac
    else
      printf '[judge-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 73.4/C51)\n' >&2
    fi

    # 顺带输出 warn 档触发计数(/tmp/task-planner-warn-*.count) — 提醒终验关注 M-1
    warn_count_files="$(ls /tmp/task-planner-warn-*.count 2>/dev/null || true)"
    if [ -n "$warn_count_files" ]; then
        printf '[plan] warn-mode triggers (delegation_enforce=warn 时本会话累计,提醒终验关注 M-1):\n' >&2
        for f in $warn_count_files; do
            n="$(cat "$f" 2>/dev/null || echo 0)"
            sid="${f##*/task-planner-warn-}"
            sid="${sid%.count}"
            printf '  - sid=%s count=%s\n' "$sid" "$n" >&2
        done
    fi

    # [2026-10-10 task-v159 pointer-lifecycle F1/D1] 移交提醒（Rule 25 完成项机制化）：
    # Why: D1 孤儿指针根因——任务完成后全局 fallback plans/.active_plan 常仍指向本任务，
    #   无人提示时漂移直到 gc 兜底清理；本段在终验成功（python_rc=0）时主动提醒清理（无需移交）。
    #   [2026-10-10 task-v164 补注] 上两行原措辞以「全局指针」框该层并称「提醒移交」,改述如下:
    #   全局 plans/.active_plan 实为工作树内瞬态 fallback(路径随 $PWD 本地化;git rm --cached+
    #   .gitignore,与 .active_plan_side/ 同族瞬态运行态),非跨树共享单例;正常路径=side 会话私有
    #   指针(权威层);退役「移交」叙事——终验提醒语义=提醒清理/无需移交(stderr 通道与 warn 形态不变)。
    # What: 读取 <plans>/.active_plan 当前值（PLAN_DIR_GUESS 的上级目录），若等于
    #   本任务 id（从 plan 目录名 basename 推导）则输出一行 warn 提醒（stderr，风格对齐
    #   同段 warn count 行）；warn 语义恒不改退出码（exit 码仍为 python_rc，零阻断）；
    #   指针缺失/不可读 → 静默跳过（fail-open，不影响终验判定）。
    # [2026-10-10 task-v164 fix-wave2] 原行为=直接重定向读取:指针缺失时 shell 的重定向失败信息漏 stderr(tr 的 2>/dev/null 捕不住 shell 重定向错误);改为存在性前置守卫,保持"缺失→静默跳过"语义(fail-open 不变)
    _cp_active_ptr=""; [ -f "$PLAN_DIR_GUESS/../.active_plan" ] && _cp_active_ptr="$(tr -d ' \r\n\t' < "$PLAN_DIR_GUESS/../.active_plan" 2>/dev/null || true)"
    if [ -n "$_cp_active_ptr" ] && [ "$_cp_active_ptr" = "$(basename "$PLAN_DIR_GUESS")" ]; then
        printf '[plan] 移交提醒( pointer-lifecycle ): 全局指针仍指向本任务，完成后无需移交、请清理（置空或指向在途任务；gc 亦会清理 stale）\n' >&2
    fi
fi

# [2026-10-11 task-v170 Phase 4 S7] ARCHIVE-GATE — 终验后「已完成计划未归档」提醒（Rule 81 机制件）
# What: 枚举 plans 根（PLAN_DIR_GUESS 的上级目录）直接子目录，按 archive-plan.sh guard_reason 同口径
#   （archive-plan.sh:88-123）逐目录判定「- **Status:** 行全 complete（总数>0）∧ 无 .active_plan /
#   .active_plan_side 指针指向该任务 ∧ .session-owner 新鲜窗口（mtime<1440min）外 ∧ 不在
#   plans/archive/」，对合格目录计数；N>0 → WARN 行提醒跑 archive-plan.sh --batch --dry-run，
#   N=0 → OK 行。
# Why: 「任务完成却不归档」是历史复发面——完成计划残留 plans/ 根目录使归档器无提醒入口、
#   active 指针/会话标记漂移无兜底可见性（R2「必须添加归档」）。warn 形态=不阻断既有
#   门控 exit 语义（本段恒不改退出码，插入点=全部既有门控段之后、脚本尾部 exit 汇合点前；
#   fail-open：plans 根不可解析/无目录 → SKIPPED 静默，终验不受影响）。
if [ -n "$PLAN_DIR_GUESS" ] && [ -d "$PLAN_DIR_GUESS/.." ]; then
    _ag_plans_root="$(cd "$PLAN_DIR_GUESS/.." && pwd 2>/dev/null)" || _ag_plans_root=""
    if [ -n "$_ag_plans_root" ] && [ -d "$_ag_plans_root" ]; then
        _ag_candidate_count=0
        while IFS= read -r _ag_name; do
            # 2026-10-11 CR-fix (034-code-reviewer-s14 MAJOR-1): 现象=侧指针命中某任务后,
            # 其后 sort 序候选目录均因 _ag_ptr_hit 残留被 continue 丢弃, 计数假阴性
            # (复现: 1 active 指针任务 + 2 complete 候选 → count=0, 期望 2);
            # 根因=while 体在当前 shell 执行, 变量跨迭代不自动清零, 标志一旦置 1 永不复位;
            # 修法=每轮目录判定前复位, 语义收窄为「当前目录是否被 active 指针指向」
            _ag_ptr_hit=""
            # 与 archive-plan.sh:166-189 同枚举口径：直接子目录仅 task-* 且含 task_plan.md，
            # archive 目标目录与圆点目录天然排除（glob 跳 dot 目录，无归类面）
            [ -n "$_ag_name" ] || continue
            case "$_ag_name" in
                task-*) : ;;
                *) continue ;;
            esac
            _ag_dir="$_ag_plans_root/$_ag_name"
            [ -f "$_ag_dir/task_plan.md" ] || continue
            # 幂等：目标已存在 = 已归档（archive-plan.sh:186 同判据），不计
            [ -e "$_ag_plans_root/archive/$_ag_name" ] && continue
            # 守卫① Status 全 complete（archive-plan.sh:109-121 同口径：总数>0 且全行 complete）
            _ag_status_total="$(grep -cE '^[[:space:]]*[-*][[:space:]]+\*\*Status:\*\*' "$_ag_dir/task_plan.md" 2>/dev/null)"
            _ag_status_ok="$(grep -c 'Status:\*\* complete' "$_ag_dir/task_plan.md" 2>/dev/null)"
            { [ -n "${_ag_status_total:-}" ] && [ "${_ag_status_total}" -ge 1 ] && [ "${_ag_status_total}" = "${_ag_status_ok:-0}" ]; } || continue
            # 守卫② active 指针（全局 .active_plan 或 .active_plan_side/*.active_plan 内容 == 任务 id）→ 在途，不计
            # （archive-plan.sh:92-100 同口径；指针缺失时 [ -f ] 前置使 glob 字面残留不产生误判）
            if [ -f "$_ag_plans_root/.active_plan" ] && [ "$(cat "$_ag_plans_root/.active_plan" 2>/dev/null)" = "$_ag_name" ]; then
                continue
            fi
            for _ag_ptr in "$_ag_plans_root/.active_plan_side/"*.active_plan; do
                [ -f "$_ag_ptr" ] || continue
                if [ "$(cat "$_ag_ptr" 2>/dev/null)" = "$_ag_name" ]; then
                    _ag_ptr_hit=1
                    break
                fi
            done
            [ -z "${_ag_ptr_hit:-}" ] || continue
            # 守卫③ 新鲜 .session-owner（mtime<1440min=24h 活会话窗口，archive-plan.sh:101-108 同口径）→ 活会话，不计
            if [ -f "$_ag_dir/.session-owner" ]; then
                _ag_fresh="$(find "$_ag_dir/.session-owner" -mmin -1440 2>/dev/null | wc -l | tr -d '[:space:]')"
                [ "${_ag_fresh:-0}" -ge 1 ] && continue
            fi
            _ag_candidate_count=$((_ag_candidate_count + 1))
        done < <(find "$_ag_plans_root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -n 1 basename 2>/dev/null | sort)
        if [ "$_ag_candidate_count" -gt 0 ]; then
            printf '[ARCHIVE-GATE] WARN: %s 个已完成计划未归档，运行 bash scripts/archive-plan.sh --batch --dry-run 查看\n' "$_ag_candidate_count"
        else
            printf '[ARCHIVE-GATE] OK: 0 个待归档\n'
        fi
    fi
fi

exit $python_rc
