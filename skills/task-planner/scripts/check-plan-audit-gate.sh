#!/usr/bin/env bash
# [2026-11-17 task-auditgate-machine-20261116] check-plan-audit-gate.sh — 计划审计门独立判定器（[audit-gate]）
# 职责: attest 锁定前机器校验「计划独立审计留痕」——末段 [plan-audit-RN] 审计段必须含锚定 APPROVED 裁决+最小形态三 token
#       （Rule 109 audit-before-delivery 机器面, CA-7;「未经审计的产出禁交用户」的锁定时硬校验）。
# Usage:
#   check-plan-audit-gate.sh <plan-dir>     # rc 0=放行 1=拒锁 2=输入异常(fail-open+WARN)
# 判定规格（权威源=plans/task-auditgate-machine-20261116/findings.md Design Decisions D1; 判据=verification.md VC-1 七态 r1..r7）:
#   ① lane 判定（行首声明, 对齐 check-tier-consistency.sh:60-63 范式）:
#      L1/L2 必审; mini×L1 并存按最严=必审; standard/full 必审; mini/L0/trivial 单独=轻量档跳过 rc0;
#      无 plan_tier 且无 execution_lane 声明 → 输出 [audit-gate] SKIP legacy-no-decl rc0（存量迁移登记, R1 F12）。
#   ② [plan-audit-skip]: 轻量档含该 token → rc0 放行; L1+ 含该 token → rc1 拒锁（自声明旁路封堵, R1 F11）。
#   ③ APPROVED 末段聚合（R6a 加固两约束）:
#      buf=最后一个 `^## \[plan-audit-R[0-9]+\] ` 段, **止于下一个 `^## `（H2）行**——不吞后随修复轮/留痕块
#      （否则反引号元引用 `结论: **APPROVED**` 会被误判为裁决, 主进程 2026-11-17 /tmp 实测假阳性; R6a/R4 C-1）;
#      **前提: 审计段后随块必须用 H2 标题**——H3/粗体标题则边界不生效、约束静默退化（写作规范依赖, R7 Q-1, checker 注释登记）;
#      结论行 ERE 行首锚定 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`（禁匹配反引号内/行中元引用, R7 I-2 fixture a）;
#      REJECTED 或无锚定结论 → rc1。
#   ④ 最小形态三 token: `审计体:`+`轮次:`（段内子串即可, 不要求独立行——r3 内联形态与 r7 独立行两正例并存, R8 Q-1 钉死）
#      +`问题清单` **容忍全角/半角括注后接冒号** `^- 问题清单([（(][^）)]*[）)])?:`（真实段形态 `- 问题清单（留档, 不阻断）:`, R7 I-1——
#      字面连写冒号判据会使 checker 对本机制自己的 plan-dir 恒 rc1）。形态残缺 → rc1。
#   ⑤ rc2 分层（R7 Q-2）: plan-dir/task_plan.md 缺失 或 progress.md 缺失/不可读 → rc2 WARN fail-open; progress.md **存在但空** → 无留痕 rc1。
# What+Why 双层注释纪律: 本头注释即设计压缩, 改判定逻辑须同步 plans/archive/task-auditgate-machine-20261116/ 判例。

set -u

PLAN_DIR="${1:-}"
AG="[audit-gate]"

# ── 入口与 rc2 分层 ──────────────────────────────────────────────
if [ -z "$PLAN_DIR" ] || [ ! -d "$PLAN_DIR" ]; then
  echo "$AG WARN 判定器输入异常: plan-dir 缺失或不存在（fail-open rc2）" >&2
  exit 2
fi
PLAN_FILE="$PLAN_DIR/task_plan.md"
PROG="$PLAN_DIR/progress.md"
if [ ! -f "$PLAN_FILE" ]; then
  echo "$AG WARN 判定器输入异常: task_plan.md 缺失（fail-open rc2）" >&2
  exit 2
fi
# [2026-11-17 selftest PAG-04..07 判例] progress.md 缺失/不可读检查**必须在 lane/skip 判定之后**:
# 无声明 legacy/轻量档（mini/L0）计划本就无审计留痕要求, progress.md 缺失不应 rc2 抢跑——
# 判定序=lane/skip 先行（SKIP 路径不触 progress 检查）→ 必审路径才校验 progress（缺失/不可读=rc2, 存在但空=rc1）。
# 语义依据: D1 rc2 定义面向必审路径; VC-1 r1/r13 用例均为 standard 档 fixture, 与本序自洽。

# ── lane 判定（行首声明; 精确 token 对齐 check-tier-consistency.sh:60-63）────────
TIER="$(grep -m1 -E '^plan_tier:' "$PLAN_FILE" | sed -E 's/^plan_tier:[[:space:]]*//' | tr -d '[:space:]' | tr 'A-Z' 'a-z')"
LANE="$(grep -m1 -E '^execution_lane:' "$PLAN_FILE" | grep -oE 'L[012]([_-][A-Za-z0-9]+)*' | head -n 1)"

# 必审: lane=L1/L2（任意 tier, mini 并存按最严）或 tier=standard/full
# 轻量档: tier=mini/l0/trivial（无 L1/L2 lane）或 lane=L0*
# 无声明: tier 与 lane 均空 → SKIP legacy-no-decl
REQUIRED=0; LIGHT=0
case "$LANE" in
  L1|L2) REQUIRED=1 ;;
  L0*) LIGHT=1 ;;
esac
if [ "$REQUIRED" -eq 0 ]; then
  case "$TIER" in
    standard|full) REQUIRED=1 ;;
    mini|l0|trivial) [ "$LIGHT" -eq 0 ] && LIGHT=1 ;;
    "") : ;;  # tier 无声明
    *) REQUIRED=1 ;;  # 未知显式档位 fail-closed 按必审（防新档位静默旁路）
  esac
fi

if [ "$REQUIRED" -eq 0 ] && [ "$LIGHT" -eq 0 ]; then
  echo "$AG SKIP legacy-no-decl: 无 plan_tier/execution_lane 声明（存量迁移口径: 存量不重锁, 交付披露登记）"
  exit 0
fi

# ── [plan-audit-skip] 判定（轻量档放行 / L1+ 拒锁——自声明旁路封堵 R1 F11）────────
# 声明判定=行首锚定 `^\[plan-audit-skip\]`——子串 grep 会被计划正文讨论该机制的散文提及误触发
# （自指计划判例 2026-11-17: 本机制自己的计划 task_plan.md 通篇引用该 token, 子串匹配使 r3/r4 恒 rc1）;
# 与 plan_tier:/execution_lane: 行首声明范式一致（R1 F11 的「写 [plan-audit-skip] 登记」=声明行, 非任意提及）。
if grep -q '^\[plan-audit-skip\]' "$PLAN_FILE"; then
  if [ "$REQUIRED" -eq 1 ]; then
    echo "$AG FAIL: L1+ 计划含 [plan-audit-skip] 自声明豁免——109.3 仅轻量档适用, L1+ 唯一逃生=attest --skip-audit-check"
    exit 1
  fi
  echo "$AG SKIP: 轻量档 [plan-audit-skip] 登记豁免（109.3）"
  exit 0
fi

# 轻量档（无 skip token）→ 跳过（mini/L0 审计门不适用, SKILL 审计门分档 109.3）
if [ "$REQUIRED" -eq 0 ] && [ "$LIGHT" -eq 1 ]; then
  echo "$AG SKIP: 轻量档（mini/L0/trivial）跳过审计判定"
  exit 0
fi

# ── 必审路径: progress.md 输入校验（缺失/不可读=rc2 fail-open; 存在但空=rc1 无留痕——R7 Q-2 分层）──
if [ ! -e "$PROG" ]; then
  echo "$AG WARN 判定器输入异常: progress.md 缺失（fail-open rc2）" >&2
  exit 2
fi
if [ ! -r "$PROG" ]; then
  echo "$AG WARN 判定器输入异常: progress.md 不可读（fail-open rc2）" >&2
  exit 2
fi

# ── JSON 权威源 shim（2026-11-21 task-json-state-20261121）───────────────────
# What: 仅在"必须审计"分支（上文 lane/tier 预判、legacy-no-decl 与 [plan-audit-skip] SKIP 全部
#       保留原样）且 plan-state.json 存在时，转调 planctl.py check audit；结果翻译为旧
#       [audit-gate] PASS/FAIL 文案 + rc 0/1/2。不存在则落到下方原留痕段正则判定。
# Why: planctl 未完整覆盖 lane/tier 与 skip 语义，故不整体替换；progress.md 的 rc2 分层仍在
#       上文生效（「progress 缺失=2 在 enforce 下 attest 拒锁」外契约不变）。审计权威源改为 JSON。
SHIM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$PLAN_DIR/plan-state.json" ] && [ -f "$SHIM_SCRIPT_DIR/planctl.py" ]; then
  _pc_out="$(python3 "$SHIM_SCRIPT_DIR/planctl.py" check audit --plan-dir "$PLAN_DIR")"
  _pc_rc=$?
  _pc_reason="${_pc_out#PLANCTL CHECK audit: PASS }"
  _pc_reason="${_pc_reason#PLANCTL CHECK audit: FAIL }"
  case "$_pc_rc" in
    0)
      _rn="$(printf '%s' "$_pc_reason" | grep -oE 'R[0-9]+' | head -n1 || true)"
      echo "$AG PASS: 末段审计留痕 [plan-audit-${_rn:-JSON}] APPROVED（0C/0I 达标, Rule 109.2; JSON 权威源）"
      exit 0
      ;;
    1)
      echo "$AG FAIL: JSON 权威源审计未通过: $_pc_reason"
      exit 1
      ;;
    *)
      echo "$AG WARN 判定器输入异常: JSON 审计判定输入异常: $_pc_reason" >&2
      exit 2
      ;;
  esac
fi

# ── APPROVED 末段聚合（R6a 两约束: 边界止 H2 + 结论行行首锚定）──────────────────
# awk 语义: 命中审计段头 → inbuf=1 清 buf 重collect（头行不进 buf, token 均为体行）;
#           inbuf 中命中任何 `^## `（H2, 含其他审计段头之前先被第一条规则 next 截获）→ inbuf=0 停止collect;
#           buf 保留最后一个审计段体。**前提: 审计段后随块必须 H2 标题**（R7 Q-1）。
SEG="$(awk '/^## \[plan-audit-R[0-9]+\] /{inbuf=1; buf=""; next} inbuf && /^## /{inbuf=0} inbuf{buf = buf $0 "\n"} END{printf "%s", buf}' "$PROG")"

if [ -z "$SEG" ]; then
  echo "$AG FAIL: progress.md 无 [plan-audit-RN] 审计留痕段（L1+ 计划须经 critic 独立审计后由主进程登记留痕）"
  exit 1
fi

if printf '%s\n' "$SEG" | grep -qE '^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*REJECTED\*\*'; then
  echo "$AG FAIL: 末段审计结论 REJECTED（打回修复轮闭环后须复审 APPROVED 才可锁定）"
  exit 1
fi

# 结论行锚定（行首三段结构; 禁匹配反引号内/行中元引用——fixture a=r5 独立承重）
if ! printf '%s\n' "$SEG" | grep -qE '^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*'; then
  echo "$AG FAIL: 末段无锚定 APPROVED 结论行（形态残缺或裁决缺失; 判据=^- 轮次: R<N> | 审计体: <体> | 结论: **APPROVED**）"
  exit 1
fi

# 最小形态三 token（审计体:/轮次: 段内子串; 问题清单容忍括注——R7 I-1）
if ! printf '%s\n' "$SEG" | grep -q '审计体:' || ! printf '%s\n' "$SEG" | grep -q '轮次:'; then
  echo "$AG FAIL: 末段 APPROVED 段缺最小形态 token（审计体:/轮次:）"
  exit 1
fi
if ! printf '%s\n' "$SEG" | grep -qE '^- 问题清单([（(][^）)]*[）)])?:'; then
  echo "$AG FAIL: 末段 APPROVED 段缺 问题清单 token（容忍括注形态: - 问题清单: 或 - 问题清单（…）:）"
  exit 1
fi

RN="$(printf '%s\n' "$SEG" | sed -n 's/^- 轮次: R\([0-9][0-9]*\).*/R\1/p' | head -n 1)"
echo "$AG PASS: 末段审计留痕 [plan-audit-${RN:-?}] APPROVED（0C/0I 达标, Rule 109.2）"
exit 0
