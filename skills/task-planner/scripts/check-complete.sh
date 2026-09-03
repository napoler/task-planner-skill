#!/bin/bash
# Check if all phases in task_plan.md are complete
# Supports single-block and multi-block chain tasks (chain_mode: linked / fan-out)
# Always exits 0 — uses stdout for status reporting
# Used by Stop hook to report task completion status

PLAN_FILE="${1:-task_plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[plan] No task_plan.md found — no active planning session."
    exit 0
fi

python3 - "$PLAN_FILE" << 'PYEOF'
import sys, re

plan_file = sys.argv[1]
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
            sys.exit(0)
        else:
            print("[plan] Some blocks not yet complete.")
            sys.exit(1)
    else:
        print(f"[plan] ALL PHASES COMPLETE ({complete}/{total})")
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
exit $?
