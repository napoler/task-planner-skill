#!/bin/bash
# selftest-final-gate-hash.sh — [2026-09-27 task-v091/S20 C-2] 终验重复门四元内容键 SKIP-BY-HASH 六夹具
# 被测对象: scripts/check-complete.sh 的 PLAN-DISPATCH 门 + FMEA 门四元内容键复用逻辑
#   (提案 §三 C-2 v3: plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md:139-146)。
# 六夹具(任务书 v3 口径):
#   ① TAMPERED — 篡改 plan(内容哈希≠attest 锁定) → attest --verify rc≠0 仍抓(TAMPERED 分支零改动) +
#                check-complete 不 SKIP 走全量
#   ② touch -r — 内容未变仅 mtime 变(plan 与 cpd 均 touch) → 仍按 SKIP 语义处理(键①为内容哈希,
#                缓存键不进 mtime; 附断言: 状态文件内容禁 mtime/size 字样)
#   ③ 未变重跑 — 两门 SKIP-BY-HASH + 余门照跑(VC-GATE/SKILL-MODIFY/DELEGATION 标记仍在)+ 终态 rc 不变
#   ④ 四元键任一变化不 SKIP — 键①(计划内容,含 re-attest 后 attest 层已绿的状态层拦截)/键②(cpd 文件)/
#                键③(FMEA 段)/键④(消费键: fmea_enforce 与 subagent.step_max_minutes 两代表性突变)
#   ⑤ 状态文件缺失/损坏 → fail-open 全量 + 自愈重写(可再 SKIP)
#   ⑥ SKIP 后真变化的门仍拦截 — Executor 改子代理(派发型缺 S-unit 表) → 全量重跑
#                PLAN-DISPATCH GATE FAILED + rc=1; 恢复后 SKIP 复效(失败轮未落状态)
# 前置断言(提案 L141 指定): 程序化 grep 两脚本 jq .properties.* 消费集合 == 键④五键枚举。
# 环境: /tmp 沙箱复制 skill 树运行(一切篡改发生在副本,不动仓内文件); 结束清理沙箱与状态文件。

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CC="$SKILL_ROOT/scripts/check-complete.sh"
CPD="$SKILL_ROOT/scripts/check-plan-dispatch.sh"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  [PASS] %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  [FAIL] %s\n' "$1"; }

SB="$(mktemp -d "${TMPDIR:-/tmp}/fg-hash-selftest.XXXXXX")" || { echo "selftest-final-gate-hash: mktemp failed" >&2; exit 2; }
SKL="$SB/skill"
PLAN_DIR="$SB/plans/t1"
PLAN="$PLAN_DIR/task_plan.md"
STATE_FILE="${TMPDIR:-/tmp}/task-planner-final-gate-$(printf '%s' "$PLAN_DIR" | sha256sum | cut -c1-16).state"
trap 'rm -rf "$SB"; rm -f "$STATE_FILE" 2>/dev/null' EXIT

# run_cc — 跑沙箱副本 check-complete, 输出落 $SB/cc.out, echo rc
run_cc() { bash "$SKL/scripts/check-complete.sh" "$PLAN" > "$SB/cc.out" 2>&1; echo $?; }

# skip_lines — $SB/cc.out 中 SKIP-BY-HASH 行数(两门各一行)
skip_lines() { grep -c 'SKIP-BY-HASH' "$SB/cc.out" 2>/dev/null || true; }

# 键④完整性守护: 剥注释行后提取 .properties.* 消费 token, 归一化为逻辑键
# 归一化: 去 .properties. 前缀 → 去 .default 后缀 → 折叠残余 .properties. 段
fg_logical_keys() {
    sed -E 's/^[[:space:]]*#.*$//' "$1" 2>/dev/null \
        | grep -oE '\.properties\.[A-Za-z0-9_.]+' \
        | sed -e 's/^\.properties\.//' -e 's/\.default$//' -e 's/\.properties\./\./' \
        | sort -u
}

# ── 前置断言: 键④枚举完整性(提案 L141: selftest 程序化 grep 守护)────────────────
pre_key4_integrity() {
    local seg="$SB/cc-fmea-seg.txt"
    # 与实现同锚: 首锚匹配(sed 命令行自身)→挽救门注释行, = 键③哈希覆盖段
    sed -n '/FMEA 门控终验点/,/失败挽救链路终验门控/p' "$CC" > "$seg" 2>/dev/null
    { fg_logical_keys "$CPD"; fg_logical_keys "$seg"; } | sort -u > "$SB/keys.actual"
    printf 'fmea_enforce\nplan_tier_enforce\nsubagent.step_max_files\nsubagent.step_max_minutes\nsubagent.step_max_steps\n' \
        | sort > "$SB/keys.expected"
    if diff -u "$SB/keys.expected" "$SB/keys.actual" > "$SB/keys.diff" 2>&1; then
        ok "前置-键④完整性: 两脚本 jq .properties.* 消费集合==五键枚举 ($(tr '\n' ' ' < "$SB/keys.actual"))"
    else
        bad "前置-键④完整性漂移(键④枚举需同步更新): $(head -20 "$SB/keys.diff" | tr '\n' '; ')"
    fi
}

# ── 沙箱建立: 复制 skill 树 + 夹具计划三件套 + attest 锁定 ────────────────────
setup_sandbox() {
    cp -r "$SKILL_ROOT" "$SKL" || return 1
    cp "$SKL/scripts/check-complete.sh" "$SB/cc.orig"
    cp "$SKL/scripts/check-plan-dispatch.sh" "$SB/cpd.orig"
    cp "$SKL/config.json" "$SB/config.orig"
    mkdir -p "$PLAN_DIR" || return 1
    # [2026-10-05 task-v131 回归清账 Rule 45] 原行为: 夹具计划无 Rule 51.1 区块, Phase 2 新增的
    #   四锚 fail-closed 门先于锁定拒 attest → setup_sandbox 走「沙箱建立失败」exit 2, 0 用例执行。
    #   修法: 夹具补四锚最小集 (51.1 标题 + R1 行 + R→VC 映射 + 🧮 根源覆盖表, 非结果级按
    #   53.1 口径写「不适用」声明+定性理由), 六夹具 SKIP-BY-HASH 原测试目标不变。
    cat > "$PLAN" <<'EOF'
---
template_type: general
---

# 夹具计划(task-v091 C-2 selftest)

## Goal

验证终验重复门四元内容键 SKIP-BY-HASH 行为(自测夹具,非真实任务)。

## Phases

### Phase 1: 执行
- **Status:** complete
- **Executor:** 主进程（白名单①：git 编排）

## Handoff / 子代理交接

| 子代理 | 检查点路径 |
|---|---|
| explorer | plans/t1/subagent-state/1-explore.md |

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「验证终验重复门四元内容键 SKIP-BY-HASH 行为（selftest 夹具，非真实任务）」

### R→VC 映射

## 🧮 根源覆盖表

> 不适用（非结果级需求）: 本夹具为自测镜像计划, 无「确保质量/性能/可靠」类结果级需求,
> 无需全链工序审计（Rule 53.1 口径）。

## 📊 FMEA 预演

| 失效模式 | 影响 | 严重度 | 发生度 | 检测度 | RPN | 预设兜底动作 |
|---|---|---|---|---|---|---|
| 状态文件损坏 | 低 | 2 | 2 | 2 | 8 | 无需(RPN≤100) |
EOF
    cat > "$PLAN_DIR/findings.md" <<'EOF'
# Findings(夹具)

- 夹具发现 A: 四元内容键=键①计划内容+②cpd 文件+③FMEA 段+④config 消费键全集
- 夹具发现 B: SKIP 语义仅覆盖两道重复门,余门照跑
- 夹具发现 C: 状态文件损坏或缺失一律 fail-open 回全量
EOF
    cat > "$PLAN_DIR/progress.md" <<'EOF'
# Progress(夹具)

- 夹具进度 1: 沙箱建立并锁定计划
- 夹具进度 2: 全量基线跑通并写入四元键状态
- 夹具进度 3: 六夹具顺序执行并各自恢复现场
EOF
    bash "$SKL/scripts/attest-plan.sh" "$PLAN" > "$SB/attest-setup.out" 2>&1
}

echo "==== selftest-final-gate-hash (task-v091/S20 C-2) ===="
pre_key4_integrity

if ! setup_sandbox; then
    echo "[selftest] 沙箱建立失败" >&2; exit 2
fi
if ! grep -q 'plan_sha256=' "$PLAN_DIR/.plan-attestation" 2>/dev/null; then
    bad "setup: attest 锁定失败($(cat "$SB/attest-setup.out" | tail -3 | tr '\n' ' '))"; exit 1
fi
ok "setup: 沙箱 skill 副本+夹具计划+attest 锁定就绪"

# ── 基线(priming)全量轮: 无状态 → 必全量,过两门后落状态 ─────────────────────
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "0" ] \
   && grep -q '\[plan-dispatch\]' "$SB/cc.out" && grep -q '\[fmea-gate\] OK' "$SB/cc.out" \
   && grep -q '^fg_key=[0-9a-f]\{64\}$' "$STATE_FILE" 2>/dev/null; then
    ok "基线: 全量轮 rc=0 无 SKIP, 两门实跑([plan-dispatch]+[fmea-gate] OK), 状态已落 fg_key"
else
    bad "基线: rc=$rc skip=$(skip_lines) state=$(grep -c '^fg_key=' "$STATE_FILE" 2>/dev/null || echo missing); 输出尾部: $(tail -5 "$SB/cc.out" | tr '\n' ' ')"
fi

# ── 夹具① TAMPERED(篡改 plan 后哈希不符)仍抓 ───────────────────────────────
cp "$PLAN" "$SB/plan.bak"
printf '\n<!-- tamper-probe-① -->\n' >> "$PLAN"
av="$(bash "$SKL/scripts/attest-plan.sh" --verify "$PLAN" > /dev/null 2>&1; echo $?)"
if [ "$av" != "0" ]; then ok "①a: attest --verify 篡改后 rc=$av (TAMPERED 仍抓, attest 本体零改动)"; else bad "①a: 篡改后 attest --verify rc=0, TAMPERED 未抓"; fi
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "①b: check-complete 不 SKIP 走全量(rc=$rc, [plan-dispatch] 实跑在证), 篡改未被 SKIP 吞掉"
else
    bad "①b: rc=$rc skip=$(skip_lines) — 篡改轮不应 SKIP"
fi
mv "$SB/plan.bak" "$PLAN"
av="$(bash "$SKL/scripts/attest-plan.sh" --verify "$PLAN" > /dev/null 2>&1; echo $?)"
[ "$av" = "0" ] && ok "①c: 恢复后 attest --verify rc=0" || bad "①c: 恢复后 verify rc=$av"

# ── 夹具② touch -r(内容未变仅 mtime 变)仍按 SKIP 语义处理 ───────────────────
touch_ref="$SB/mtime-ref"; : > "$touch_ref"; touch -d '2020-01-01 00:00:00' "$touch_ref"
touch -r "$touch_ref" "$PLAN"
touch -r "$touch_ref" "$SKL/scripts/check-plan-dispatch.sh"
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "2" ]; then
    ok "②a: plan+cpd mtime 改到 2020 后仍 SKIP×2 rc=0(缓存键不进 mtime)"
else
    bad "②a: rc=$rc skip=$(skip_lines) — mtime 变化不应破坏 SKIP"
fi
if ! grep -qiE 'mtime|size' "$STATE_FILE" 2>/dev/null; then
    ok "②b: 状态文件内容无 mtime/size 字样(提案护栏: 缓存键禁 mtime/size)"
else
    bad "②b: 状态文件出现 mtime/size 字样"
fi

# ── 夹具③ 未变重跑 SKIP + 余门照跑 + 终态 rc 不变 ──────────────────────────
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "2" ]; then
    ok "③a: 未变重跑两门 SKIP-BY-HASH×2, 终态 rc=0 与全量轮一致"
else
    bad "③a: rc=$rc skip=$(skip_lines) — 未变重跑应双 SKIP"
fi
rem_cnt=0
for marker in 'DELEGATION GATE' 'VC-GATE' 'LEARNING-GATE' 'SKILL-MODIFY GATE'; do
    grep -q "$marker" "$SB/cc.out" && rem_cnt=$((rem_cnt + 1))
done
if [ "$rem_cnt" -ge 3 ]; then
    ok "③b: 余门照跑在证(四类余门标记命中 ${rem_cnt}/4)"
else
    bad "③b: 余门标记仅 ${rem_cnt}/4 — SKIP 被扩大到余门"
fi

# ── 夹具④ 四元键任一变化(含键④消费键)不 SKIP ──────────────────────────────
# ④-a 键①: 计划内容变 + re-attest(attest 层已绿) → 状态层仍拦
cp "$PLAN" "$SB/plan.bak"
printf '\n<!-- key1-probe -->\n' >> "$PLAN"
bash "$SKL/scripts/attest-plan.sh" "$PLAN" > /dev/null 2>&1
rc="$(run_cc)"
if [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "④a(键①): 内容变+re-attest 后不 SKIP(attest 层绿,状态层键①拦截)"
else
    bad "④a(键①): skip=$(skip_lines) — re-attest 后不应 SKIP"
fi
mv "$SB/plan.bak" "$PLAN"
bash "$SKL/scripts/attest-plan.sh" "$PLAN" > /dev/null 2>&1

# ④-b 键②: cpd 文件加一行
printf '# selftest-key2-probe\n' >> "$SKL/scripts/check-plan-dispatch.sh"
rc="$(run_cc)"
if [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "④b(键②): check-plan-dispatch.sh 变更后不 SKIP"
else
    bad "④b(键②): skip=$(skip_lines) — 门脚本变更后不应 SKIP"
fi
cp "$SB/cpd.orig" "$SKL/scripts/check-plan-dispatch.sh"

# ④-c 键③: FMEA 段内插注释行(段哈希变)
awk '{print} /\[fmea-gate\] SKIP-BY-HASH/ && !ins {print "        # selftest-key3-probe(夹具④键③段内探针)"; ins=1}' \
    "$SKL/scripts/check-complete.sh" > "$SB/cc.key3" && mv "$SB/cc.key3" "$SKL/scripts/check-complete.sh"
rc="$(run_cc)"
if [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "④c(键③): check-complete.sh FMEA 段变更后不 SKIP"
else
    bad "④c(键③): skip=$(skip_lines) — FMEA 段变更后不应 SKIP"
fi
cp "$SB/cc.orig" "$SKL/scripts/check-complete.sh"

# ④-d 键④: config 消费键突变两例(顶层覆盖优先)
jq '.fmea_enforce = "enforce"' "$SKL/config.json" > "$SB/cfg.tmp" && mv "$SB/cfg.tmp" "$SKL/config.json"
rc="$(run_cc)"
if [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "④d(键④/fmea_enforce): 消费键值 warn→enforce 后不 SKIP"
else
    bad "④d(键④/fmea_enforce): skip=$(skip_lines) — 消费键变化后不应 SKIP"
fi
cp "$SB/config.orig" "$SKL/config.json"
jq '.subagent.step_max_minutes = 9' "$SKL/config.json" > "$SB/cfg.tmp" && mv "$SB/cfg.tmp" "$SKL/config.json"
rc="$(run_cc)"
if [ "$(skip_lines)" = "0" ] && grep -q '\[plan-dispatch\]' "$SB/cc.out"; then
    ok "④e(键④/step_max_minutes): 消费键值 15→9 后不 SKIP"
else
    bad "④e(键④/step_max_minutes): skip=$(skip_lines) — 消费键变化后不应 SKIP"
fi
cp "$SB/config.orig" "$SKL/config.json"
# 恢复合规校验: 状态=上轮全量通过条件(键④残留 step_max_minutes=9) → 还原后首轮全量重锁, 次轮 SKIP 复效
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "0" ] && grep -q '^fg_key=[0-9a-f]\{64\}$' "$STATE_FILE" 2>/dev/null; then
    ok "④f-1: 还原后首轮全量重锁 rc=0(状态语义=最近全量通过条件, 上轮键④残留触发)"
else
    bad "④f-1: rc=$rc skip=$(skip_lines) — 还原后首轮应全量重锁"
fi
rc="$(run_cc)"
[ "$(skip_lines)" = "2" ] && ok "④f-2: 次轮 SKIP 复效(四类突变还原完整性)" || bad "④f-2: skip=$(skip_lines) rc=$rc — 还原不完整或键计算不稳"

# ── 夹具⑤ 状态文件损坏/缺失兜底(fail-open 全量 + 自愈)──────────────────────
rm -f "$STATE_FILE"
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "0" ] && grep -q '^fg_key=[0-9a-f]\{64\}$' "$STATE_FILE" 2>/dev/null; then
    ok "⑤a: 状态缺失→全量 rc=0 且自愈重写 fg_key"
else
    bad "⑤a: rc=$rc skip=$(skip_lines) — 缺失状态应全量并自愈"
fi
printf 'garbage-not-a-key\x00binary-junk' > "$STATE_FILE"
rc="$(run_cc)"
if [ "$rc" = "0" ] && [ "$(skip_lines)" = "0" ] && grep -q '^fg_key=[0-9a-f]\{64\}$' "$STATE_FILE" 2>/dev/null; then
    ok "⑤b: 状态损坏(含 NUL)→全量 rc=0 且自愈重写"
else
    bad "⑤b: rc=$rc skip=$(skip_lines) — 损坏状态应全量并自愈"
fi

# ── 夹具⑥ SKIP 后真变化的门仍拦截 ──────────────────────────────────────────
rc="$(run_cc)"
[ "$(skip_lines)" = "2" ] || bad "⑥pre: 前置失败(应 SKIP,skip=$(skip_lines))"
cp "$PLAN" "$SB/plan.bak"
# 注: 替换文本不得含半角冒号(check-delegation type_hint 的 #*: 冒号前缀剥离会误伤括号内说明)
sed -i 's/- \*\*Executor:\*\* 主进程（白名单①：git 编排）/- **Executor:** explorer（夹具⑥调研定位）/' "$PLAN"
av="$(bash "$SKL/scripts/attest-plan.sh" --verify "$PLAN" > /dev/null 2>&1; echo $?)"
[ "$av" != "0" ] && ok "⑥a: 篡改后 attest --verify rc=$av(TAMPERED)" || bad "⑥a: verify rc=0"
rc="$(run_cc)"
if [ "$rc" = "1" ] && grep -q 'PLAN-DISPATCH GATE FAILED' "$SB/cc.out" && [ "$(skip_lines)" = "0" ]; then
    ok "⑥b: 真变化(Executor→子代理,缺 S-unit 表)全量重跑被拦 rc=1(SKIP 未吞掉门失败)"
else
    bad "⑥b: rc=$rc skip=$(skip_lines) — 真变化必须被门拦截"
fi
mv "$SB/plan.bak" "$PLAN"
av="$(bash "$SKL/scripts/attest-plan.sh" --verify "$PLAN" > /dev/null 2>&1; echo $?)"
rc="$(run_cc)"
if [ "$av" = "0" ] && [ "$rc" = "0" ] && [ "$(skip_lines)" = "2" ]; then
    ok "⑥c: 恢复后 verify rc=0 且 SKIP 复效(失败轮未污染状态)"
else
    bad "⑥c: verify=$av rc=$rc skip=$(skip_lines) — 恢复后应回到 SKIP"
fi

printf '\n==== selftest-final-gate-hash 结果: PASS=%d FAIL=%d ====\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
