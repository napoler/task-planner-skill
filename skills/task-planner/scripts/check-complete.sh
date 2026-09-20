#!/bin/bash
# Check if all phases in task_plan.md are complete
# Supports single-block and multi-block chain tasks (chain_mode: linked / fan-out)
# Exits 1 when gates fail (Batch Report Rule 18.6 / Aggregator Rule 23.6 / 3-File Gate Rule 19.5 / Learning Gate Rule 31.5)
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

# [2026-09-07 task-v055 task-v055/Phase 3] 终验委派率接线(Rule 25.4)
# 行为:全 Phase complete 判定通过前,调 check-delegation.sh stats 输出 JSON。
# - verdict==violation  或  全 complete 且 delegation_rate < floor  或  main_direct 含 violations
#   → 摘要输出到 stderr + exit 1(禁止 COMPLETE 交付)
# - stats 命令自身失败(jq/解析/脚本异常)= fail-open:stderr 一行警告,不阻断(与 A 批约定一致)
# - 顺带输出 warn 档触发计数(/tmp/task-planner-warn-<sid>.count 若存在,提醒终验关注 M-1)
# 实现位置:放在 python 内联末尾之后(已通过 3-File Gate/Porcelain 等前置门),
# 所有判定放行后才查委派率 — 这是「最后一道闸」。
DELEGATION_RATE_FLOOR="$(jq -r '.properties.delegation_rate_floor.default // 0.7' "$SKILL_ROOT/config.json" 2>/dev/null || echo 0.7)"
# [2026-09-20 task-v086 P2-S3 Rule 38.4③] mini 降档: 计划文件 grep「plan_tier: mini」命中 →
# floor 0.7→0.0（main_direct 全部理由视白名单直通, 即 rate 永远 >= floor）; violations 仍照常计(L441 verdict 路径不动);
# 非 mini 路径 DELEGATION_RATE_FLOOR 保持 config 原值=零改动
if grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null; then
    DELEGATION_RATE_FLOOR="0.0"
fi

python3 - "$PLAN_FILE" "$SKILL_ROOT" << 'PYEOF'
import sys, re

plan_file = sys.argv[1]
skill_root = sys.argv[2]
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
batch_required = chain_mode == "fan-out" or "Batch Report" in content
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
if total == 0 and not block_statuses:
    print("[plan] No phases found in task_plan.md.")
    sys.exit(0)

# Batch Report gate (Rule 18.6): incomplete fields block completion reporting

# Rule 23.6: fan-out 必须含 Aggregator Phase
aggregator_missing = []
if chain_mode == "fan-out":
    if not re.search(r'Phase\s+\d+:.*[Aa]ggregator', content) and not re.search(r'Phase\s+\d+:.*聚合', content):
        aggregator_missing = ["Aggregator Phase (Rule 23.6)"]

# [2026-09-04 Rule 19.5] 3-File Gate — findings.md / progress.md 必须存在且非模板 stub
# 仅在 plan 目录有 Phase 内容（total>0 或 block_statuses 非空）时生效。
# 模板路径来自 argv[2]（SKILL_ROOT），缺失则跳过 stub 判定只检查文件存在。
import os
plan_dir = os.path.dirname(os.path.abspath(plan_file))
three_file_gate_active = (total > 0) or bool(block_statuses)
if three_file_gate_active:
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
if [ "$python_rc" -eq 0 ]; then
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

    # [2026-09-09 task-v058] 计划期 S-unit 执行体终验门控(Rule 22.6/25.1);check-plan-dispatch.sh 缺失 → fail-open
    cpl="$SKILL_ROOT/scripts/check-plan-dispatch.sh"
    if [ -f "$cpl" ]; then bash "$cpl" "$PLAN_FILE" || { echo "[plan] PLAN-DISPATCH GATE FAILED (Rule 22.6/25.1)" >&2; exit 1; }; fi

    # [2026-09-16 task-v075 P4 B1] FMEA 门控终验点(fmea_enforce 双点消费之二,与 attest-plan.sh 同逻辑):
    # 档位解析范式同本文件既有 resolve_*_tier 段: env TASK_PLANNER_FMEA_ENFORCE > config.json fmea_enforce.default > warn
    # off=完全跳过无输出; warn=违规打 [fmea-gate] ⚠ 后继续; enforce=打 [fmea-gate] ✗ 后终验 FAIL(exit 1)
    # 判定口径与 attest-plan.sh check-fmea-gate 一致(KQ2): 含「FMEA 预演」段 + RPN 表数据行(第 6 数据列纯数字)≥1
    #   + RPN>100 行第 7 数据列(预设兜底动作)trim 后非空; legacy(无 Executor 行)fail-open 跳过
    resolve_fmea_tier() {
        local m="${TASK_PLANNER_FMEA_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if command -v jq >/dev/null 2>&1 && [ -f "$CONFIG_JSON" ]; then
            m="$(jq -r '.properties.fmea_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    FMEA_TIER="$(resolve_fmea_tier)"
    if [ "$FMEA_TIER" != "off" ] && grep -qE '^- \*\*Executor:\*\*' "$PLAN_FILE" 2>/dev/null; then
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

    # [2026-09-13 task-v065 S-1 F-1] 失败挽救链路终验门控(挽救而非摆烂);缺失 → fail-open
    # 档位由 check-rescue-chain.sh 自解析(config.json rescue_chain_enforce, 默认 warn):
    #   enforce 档存在违规 → 该脚本 exit 1 → 本门阻断 complete;warn/off 档恒 exit 0(仅提示)。
    # exit 2(参数错误)不阻断(避免门控自身配置问题锁死终验)。
    crc="$SKILL_ROOT/scripts/check-rescue-chain.sh"
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
    resolve_vc_gate_tier() {
        local m="${TASK_PLANNER_VC_GATE_ENFORCE:-}"
        case "$m" in enforce|warn|off) printf '%s' "$m"; return 0 ;; esac
        if ! command -v jq >/dev/null 2>&1 || [ ! -f "$CONFIG_JSON" ]; then
            printf 'warn'
            return 0
        fi
        m="$(jq -r '.properties.vc_gate_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }

    VC_GATE_TIER="$(resolve_vc_gate_tier)"
    # [2026-09-20 task-v086 P2-S3 Rule 38.4②] mini 档降档: 判定前置 grep 计划文件(init 复制产物)
    # 「plan_tier: mini」(standard 模板标记 plan_tier: standard 天然不命中);
    # mini: VC 最低 5→2 / 每 Phase V-N 阈值 2→1 / 无 V-N 映射行不阻断; 非 mini 变量取原值=零改动
    PLAN_TIER_MINI=0
    grep -qm1 'plan_tier: mini' "$PLAN_FILE" 2>/dev/null && PLAN_TIER_MINI=1
    vc_min=5; [ "$PLAN_TIER_MINI" = 1 ] && vc_min=2
    vn_thresh_base=2; [ "$PLAN_TIER_MINI" = 1 ] && vn_thresh_base=1
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
            m="$(jq -r '.properties.error_loop_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    ERROR_LOOP_TIER="$(resolve_error_loop_tier)"
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
                # 数据行校验:非表头/非分隔行,Root Cause 列 strip 后非空且 != <待沉淀>
                lg_bad_awk='
/^## Error Log/ {in_sec=1; next}
in_sec && /^## / {in_sec=0}
in_sec {
    if ($0 !~ /^\|/) next
    v = $0
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
    if (v ~ /Root[[:space:]]+Cause/ || v ~ /^-/) next
    n = split($0, a, "|")
    if (c < 2 || c > n - 1) next
    cell = a[c + 1]
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
    if (cell == "" || cell == "<待沉淀>" || cell == "待沉淀") print NR
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
            m="$(jq -r '.properties.reflect_verify_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
        fi
        case "$m" in enforce|warn|off) printf '%s' "$m" ;; *) printf 'warn' ;; esac
    }
    REFLECT_VERIFY_TIER="$(resolve_reflect_verify_tier)"
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
            m="$(jq -r '.properties.skill_modify_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || m=""
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
    case "$mp_tier" in enforce|warn|off) ;; *) mp_tier="$(jq -r '.properties.mechanism_profile_enforce.default // "warn"' "$CONFIG_JSON" 2>/dev/null)" || mp_tier=""; case "$mp_tier" in enforce|warn|off) ;; *) mp_tier="warn" ;; esac ;; esac
    if [ "$mp_tier" != "off" ]; then
        mp_tt="$(grep -m1 '^template_type:' "$PLAN_FILE" 2>/dev/null | sed 's/^template_type:[[:space:]]*//;s/[[:space:]]*$//')"; mp_tt="${mp_tt%%[[:space:]（]*}"
        [ -z "$mp_tt" ] && mp_tt="$(grep -m1 'template_type' "$PLAN_FILE" 2>/dev/null | awk -F'|' '{for(i=1;i<=NF;i++){t=$i;gsub(/[[:space:]`]/,"",t);if(t=="template_type"){v=$(i+1);gsub(/[[:space:]`]/,"",v);print v;exit}}}' | head -1 | sed 's/（.*//')"
        case "$mp_tt" in writing|research|publish) grep -qE 'code_review: required|^[[:space:]]*\|[[:space:]]*`?code_review`?[[:space:]]*\|[[:space:]]*`?required`?[[:space:]]*\|' "$PLAN_FILE" 2>/dev/null && case "$mp_tier" in enforce) echo "[mechanism-profile] ✗ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；enforce 档 exit 1 — 显式例外须在计划 Decisions 登记理由或改 n/a）" >&2; exit 1 ;; *) echo "[mechanism-profile] ⚠ 内容组计划声明 code_review: required（Rule 37 画像默认不适用；如属显式例外请登记理由）" >&2 ;; esac ;; esac
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
fi

exit $python_rc
