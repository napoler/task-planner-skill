#!/bin/bash
# Check if all phases in task_plan.md are complete
# Supports single-block and multi-block chain tasks (chain_mode: linked / fan-out)
# Exits 1 when gates fail (Batch Report Rule 18.6 / Aggregator Rule 23.6 / 3-File Gate Rule 19.5)
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

# [2026-09-07 task-v055 task-v055/Phase 3] 终验委派率接线(Rule 25.4)
# 行为:全 Phase complete 判定通过前,调 check-delegation.sh stats 输出 JSON。
# - verdict==violation  或  全 complete 且 delegation_rate < floor  或  main_direct 含 violations
#   → 摘要输出到 stderr + exit 1(禁止 COMPLETE 交付)
# - stats 命令自身失败(jq/解析/脚本异常)= fail-open:stderr 一行警告,不阻断(与 A 批约定一致)
# - 顺带输出 warn 档触发计数(/tmp/task-planner-warn-<sid>.count 若存在,提醒终验关注 M-1)
# 实现位置:放在 python 内联末尾之后(已通过 3-File Gate/Porcelain 等前置门),
# 所有判定放行后才查委派率 — 这是「最后一道闸」。
DELEGATION_RATE_FLOOR="$(jq -r '.properties.delegation_rate_floor.default // 0.7' "$SKILL_ROOT/config.json" 2>/dev/null || echo 0.7)"

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
