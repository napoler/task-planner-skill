#!/usr/bin/env bash
# selftest-methodology.sh — task-v063 Phase6/S1: methodology 门控面 hermetic 守护套件
# (task-v075 P4 B1 扩至 M-08..M-11: fmea_enforce 三档分化端到端守护, 见 :11-14 与 M-08..M-11 段)
# 守护 v063 引入的 FMEA/内容质量门控嵌入点 (config 两键 + methodology.md + 模板/指针):
#   M-01 config.json 两键存在 (fmea_enforce + content_quality_enforce 均在 .properties)
#   M-02 两键默认值=warn 且 enum 含 enforce/warn/off (default=warn, enum 长度=3)
#   M-03 methodology.md 存在且含 9 条方法名关键词 (Poka-Yoke/FMEA/… ≥9)
#   M-04 模板 FMEA 段在位 (task_plan.md "FMEA 预演"=1 + RPN 表 7 列 "RPN=S×O×D" ≥1)
#   M-05 writing-type.md 质量门控指针在位 ("五维评分卡"=1)
#   M-06 SKILL.md 3 处指针在位 (grep -c "methodology" ≥3)
#   M-07 README 键说明 21 项在位 ("21 项"=1 + 两键名 grep ≥2)
#   M-08..M-11 (task-v075 P4 B1): fmea_enforce 三档分化在 attest-plan.sh 端到端可观测
#     (无 FMEA 段 warn 档锁定成功+stderr 有 ⚠ / enforce 档 exit 1 / 高 RPN 无兜底 enforce
#      exit 1 / off 档静默无 fmea-gate 输出; 均经 --skip-dispatch-check --skip-template-check
#      隔离既有两道门控; 高 RPN 有兜底行放行由 M-10 对照断言覆盖)
# hermetic: mktemp 夹具 = 真实 worktree 文件最小镜像 (<root>/skills/task-planner/… cp 而来),
# 用例只对 fixture 跑, 不污染真实仓且防 CWD 依赖; trap 清理; 对真实文件只读。
#   M-12..M-16 (task-v084): 思维方法论 T1-T5 守护 (五方法名关键词≥5 / §思维方法论章标题=1
#     +同法不同时交叉引用钉 / 14 条联动在位+9 条清零双向钉 / SKILL 解构 bullet+Poka-Yoke 指针 /
#     plan-writer 四问契约行; fixture 增镜像 companion/agents/plan-writer.md)
# 16 用例 (M-01..M-16) 全 PASS exit 0; 任一 FAIL exit 1。幂等: 连跑两遍结果一致 (fixture 每次重建)。

set -u

# 真实仓文件定位: 本脚本在 <root>/skills/task-planner/scripts/ 内, 真实根 = SCRIPT_DIR/..
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

PASS=0; FAIL=0

assert() {
  # assert <m_num> <desc> <cond_rc: 0=pass>
  local num="$1" desc="$2" rc="$3"
  if [ "$rc" -eq 0 ]; then
    PASS=$((PASS+1)); printf 'M-%s PASS %s\n' "$num" "$desc"
  else
    FAIL=$((FAIL+1)); printf 'M-%s FAIL %s\n' "$num" "$desc"
  fi
}

# 夹具: 真实文件最小镜像 (仅 cp, 不动真实仓)
FIX="$TMP/skills/task-planner"
mkdir -p "$FIX/references" "$FIX/templates/variant"
cp "$REAL_ROOT/config.json"              "$FIX/config.json"
cp "$REAL_ROOT/SKILL.md"                 "$FIX/SKILL.md"
cp "$REAL_ROOT/README.md"                "$FIX/README.md"
cp "$REAL_ROOT/references/methodology.md" "$FIX/references/methodology.md"
cp "$REAL_ROOT/templates/task_plan.md"   "$FIX/templates/task_plan.md"
cp "$REAL_ROOT/templates/variant/writing-type.md" "$FIX/templates/variant/writing-type.md"
# task-v084: M-16 需镜像 plan-writer 契约行
mkdir -p "$FIX/companion/agents"
cp "$REAL_ROOT/companion/agents/plan-writer.md" "$FIX/companion/agents/plan-writer.md"
# task-v075 P4 B1: M-08..M-11 端到端跑真实 attest-plan.sh (fixture 镜像内), 需镜像 scripts/
cp -r "$REAL_ROOT/scripts" "$FIX/scripts"
CFG="$FIX/config.json"

# M-01: config.json 两键存在
M01_RC=1
jq -e '.properties.fmea_enforce and .properties.content_quality_enforce' "$CFG" >/dev/null 2>&1
M01_RC=$?
assert 01 "config 两键存在" "$M01_RC"

# M-02: 两键 default=warn 且 enum 长度=3 (含 enforce/warn/off)
M02_RC=1
if [ "$(jq -r '.properties.fmea_enforce.default' "$CFG")" = "warn" ] \
   && [ "$(jq -r '.properties.content_quality_enforce.default' "$CFG")" = "warn" ] \
   && [ "$(jq -r '.properties.fmea_enforce.enum | length' "$CFG")" = "3" ] \
   && [ "$(jq -r '.properties.content_quality_enforce.enum | length' "$CFG")" = "3" ]; then
  M02_RC=0
fi
assert 02 "两键 default=warn 且 enum 长度=3" "$M02_RC"

# M-03: methodology.md 含 9 条方法名关键词
KCNT="$(grep -c "Poka-Yoke\|FMEA\|checkpoint\|三级引用\|交叉验证\|去 AI 化\|五维评分卡\|8 字段\|chunk" "$FIX/references/methodology.md" 2>/dev/null)"
[ "${KCNT:-0}" -ge 9 ]
M03_RC=$?
assert 03 "methodology.md 方法名关键词 ≥9 (实测 ${KCNT:-0})" "$M03_RC"

# M-04: 模板 FMEA 段在位
N_A="$(grep -c "FMEA 预演" "$FIX/templates/task_plan.md" 2>/dev/null)"
N_B="$(grep -c "RPN=S×O×D" "$FIX/templates/task_plan.md" 2>/dev/null)"
[ "${N_A:-0}" -eq 1 ] && [ "${N_B:-0}" -ge 1 ]
M04_RC=$?
assert 04 "模板 FMEA 段在位 (预演=1, RPN 7 列表头 ${N_B:-0})" "$M04_RC"

# M-05: writing-type.md 质量门控指针
N_C="$(grep -c "五维评分卡" "$FIX/templates/variant/writing-type.md" 2>/dev/null)"
[ "${N_C:-0}" -eq 1 ]
M05_RC=$?
assert 05 "writing-type.md 五维评分卡指针" "$M05_RC"

# M-06: SKILL.md 3 处 methodology 指针
N_D="$(grep -c "methodology" "$FIX/SKILL.md" 2>/dev/null)"
[ "${N_D:-0}" -ge 3 ]
M06_RC=$?
assert 06 "SKILL.md methodology 指针 ≥3 (实测 ${N_D:-0})" "$M06_RC"

# M-07: README 键说明 21 项在位
N_E="$(grep -c "21 项" "$FIX/README.md" 2>/dev/null)"
N_F="$(grep -c "fmea_enforce\|content_quality_enforce" "$FIX/README.md" 2>/dev/null)"
[ "${N_E:-0}" -eq 1 ] && [ "${N_F:-0}" -ge 2 ]
M07_RC=$?
assert 07 "README 21 项说明 (实测 ${N_E:-0}/${N_F:-0})" "$M07_RC"

# ── task-v075 P4 B1: fmea_enforce 三档分化端到端守护 (M-08..M-11) ─────────────────
# 夹具计划 = 含 Executor 行 (现代计划, 非 legacy fail-open) 的最小 task_plan.md;
# --skip-dispatch-check --skip-template-check 隔离既有两道门控, 只留 FMEA 段;
# 档位一律经 env TASK_PLANNER_FMEA_ENFORCE 注入 (高于 config 键, hermetic 不受真实
# config 默认值影响); CWD 锁定 $TMP 使 attest 活跃计划探测链 (resolve-plan-dir.sh)
# 解析不到真实仓 plans/, 零主仓写入; attest 落盘 .plan-attestation 只在 $TMP 内。
cd "$TMP"
PLAN_T="$TMP/plan-fmea.md"
cat > "$PLAN_T" <<'EOF'
# Task Plan
### Phase 1: X
- **Executor:** executor（sonnet-1）
- **Status:** pending
EOF
ATT="$TMP/.plan-attestation"
ATTARGS=(--skip-dispatch-check --skip-template-check "$PLAN_T")
M08_RC=1
out_w="$(TASK_PLANNER_FMEA_ENFORCE=warn bash "$FIX/scripts/attest-plan.sh" "${ATTARGS[@]}" 2>&1)"; rc_w=$?
if [ "$rc_w" -eq 0 ] && [ -f "$ATT" ] && printf '%s' "$out_w" | grep -q 'fmea-gate.*⚠'; then
  M08_RC=0
fi
assert 08 "无 FMEA 段计划: warn 档锁定成功且 stderr 有 ⚠ (实测 rc=$rc_w attested=$([ -f "$ATT" ] && echo y || echo n))" "$M08_RC"

# M-08: 无 FMEA 段夹具 attest 实测 (warn/enforce/off 三档分化, M-10/M-11 复用同夹具)
# M-09: 同夹具 enforce 档 → 拒绝锁定 exit 1
rm -f "$ATT"
M09_RC=1
out_e1="$(TASK_PLANNER_FMEA_ENFORCE=enforce bash "$FIX/scripts/attest-plan.sh" "${ATTARGS[@]}" 2>&1)"; rc_e1=$?
if [ "$rc_e1" -eq 1 ] && [ ! -f "$ATT" ] && printf '%s' "$out_e1" | grep -q 'fmea-gate.*✗'; then
  M09_RC=0
fi
assert 09 "无 FMEA 段计划: enforce 档 (env TASK_PLANNER_FMEA_ENFORCE=enforce) attest exit 1" "$M09_RC"

# M-10: 高 RPN(>100) 行: 无兜底 enforce 档 exit 1; 补兜底后同档位通过
cat > "$PLAN_T" <<'EOF'
# Task Plan
### Phase 1: X
- **Executor:** executor（sonnet-1）
- **Status:** pending

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|---------|---|---|---|-----|------------------------------|
| P1 | 依赖缺失 | 7 | 4 | 5 | 140 |  |
EOF
rm -f "$ATT"
M10_RC=1
out_e2="$(TASK_PLANNER_FMEA_ENFORCE=enforce bash "$FIX/scripts/attest-plan.sh" "${ATTARGS[@]}" 2>&1)"; rc_e2=$?
if [ "$rc_e2" -eq 1 ] && [ ! -f "$ATT" ] && printf '%s' "$out_e2" | grep -q 'RPN>100 行缺预设兜底'; then
  M10_RC=0
fi
# 补兜底: 把数据行末尾空列替换为登记动作 (sed 单行替换, 免重写整段 heredoc)
sed -i 's/| 140 |  |/| 140 | 按 22.3② 拆细重派 |/' "$PLAN_T"
rm -f "$ATT"
out_e3="$(TASK_PLANNER_FMEA_ENFORCE=enforce bash "$FIX/scripts/attest-plan.sh" "${ATTARGS[@]}" 2>&1)"; rc_e3=$?
[ "$M10_RC" -eq 0 ] && [ "$rc_e3" -eq 0 ] && [ -f "$ATT" ] || M10_RC=1
assert 10 "高 RPN(>100) 无兜底行 enforce 档 exit 1; 有兜底行通过 (实测 rc=$rc_e2/$rc_e3)" "$M10_RC"

# M-11: off 档完全静默 (无任何 fmea-gate 输出, 锁定成功) — 复用无 FMEA 段夹具
rm -f "$ATT"
cat > "$PLAN_T" <<'EOF'
# Task Plan
### Phase 1: X
- **Executor:** executor（sonnet-1）
- **Status:** pending
EOF
out_o="$(TASK_PLANNER_FMEA_ENFORCE=off bash "$FIX/scripts/attest-plan.sh" "${ATTARGS[@]}" 2>&1)"; rc_o=$?
M11_RC=1
if [ "$rc_o" -eq 0 ] && [ -f "$ATT" ] && ! printf '%s' "$out_o" | grep -q 'fmea-gate'; then
  M11_RC=0
fi
assert 11 "off 档: 无 FMEA 段计划静默锁定成功 (实测 rc=$rc_o)" "$M11_RC"

# ── task-v084: 思维方法论 T1-T5 守护 (M-12..M-16) ─────────────────

# M-12: methodology.md 含 T1-T5 方法名关键词
TCNT="$(grep -c "问题先行\|问题解构四问\|金字塔原理\|逐步推导剖析\|消费点" "$FIX/references/methodology.md" 2>/dev/null)"
[ "${TCNT:-0}" -ge 5 ]
M12_RC=$?
assert 12 "methodology.md T1-T5 方法名关键词 ≥5 (实测 ${TCNT:-0})" "$M12_RC"

# M-13: §思维方法论章标题 + 同法不同时交叉引用钉
N_T="$(grep -c "^## §思维方法论" "$FIX/references/methodology.md" 2>/dev/null)"
N_X="$(grep -c "同法不同时" "$FIX/references/methodology.md" 2>/dev/null)"
[ "${N_T:-0}" -eq 1 ] && [ "${N_X:-0}" -ge 1 ]
M13_RC=$?
assert 13 "§思维方法论章标题=1 且 同法不同时≥1 (实测 ${N_T:-0}/${N_X:-0})" "$M13_RC"

# M-14: 14 条联动在位 + 9 条清零 (双向钉)
N_14="$(grep -c "14 条" "$FIX/references/methodology.md" 2>/dev/null)"
N_9="$(grep -c "9 条" "$FIX/references/methodology.md" 2>/dev/null)"
[ "${N_14:-0}" -ge 1 ] && [ "${N_9:-0}" -eq 0 ]
M14_RC=$?
assert 14 "机械联动 14 条≥1 且 9 条=0 (实测 ${N_14:-0}/${N_9:-0})" "$M14_RC"

# M-15: SKILL.md 思维方法论指针 (解构 bullet + Poka-Yoke 行内)
N_B="$(grep -c "思维方法论问题解构" "$FIX/SKILL.md" 2>/dev/null)"
N_P="$(grep -c "§R1/R2/§思维方法论" "$FIX/SKILL.md" 2>/dev/null)"
[ "${N_B:-0}" -ge 1 ] && [ "${N_P:-0}" -ge 1 ]
M15_RC=$?
assert 15 "SKILL.md 解构 bullet≥1 且 Poka-Yoke 指针≥1 (实测 ${N_B:-0}/${N_P:-0})" "$M15_RC"

# M-16: plan-writer 产出契约表四问契约行
N_W="$(grep -c "问题解构四问" "$FIX/companion/agents/plan-writer.md" 2>/dev/null)"
[ "${N_W:-0}" -ge 1 ]
M16_RC=$?
assert 16 "plan-writer 问题解构四问契约行 (实测 ${N_W:-0})" "$M16_RC"

printf 'Total: %d PASS=%d FAIL=%d\n' "$((PASS+FAIL))" "$PASS" "$FAIL"
exit $((FAIL > 0))
