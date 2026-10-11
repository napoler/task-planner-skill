# S32-verify-group2-a1-a2.md — 组2（A-1 mini 自动降档 + A-2 锚点口径注释）干净上下文独立验证

- 验证者：全新子代理（无既有验证上下文），2026-09-27
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-v091（HEAD=a05bd5e，只读）
- 脚本：skills/task-planner/scripts/{init-session.sh, check-complete.sh, check-plan-dispatch.sh}
- 夹具：/tmp/s32v（自建，验证后自清）

## 总判定：PASS（a/b/c 全组通过；A-2 注释判定=不失实）

---

## a) 四构造任务实跑 init-session（TASK_AUTO_TIER=1，cd /tmp/s32v/plans/<task> 下调用）

| 任务 | env | 期待 | 实跑结果 | 判定 |
|---|---|---|---|---|
| 甲 | EST=10 FILES=1 MODS=1 | 自动 mini + auto_tier 标记 | rc=0；`[init] auto-tier: 四条件全过（预估 10min ≤15 ∧ scope_files 1 ≤2 ∧ 单模块 ∧ ④排除未命中）→ 自动降档 mini（Rule 38.6）`；产物 frontmatter L1-3 = `<!-- template_type: mini-lite -->` / `<!-- plan_tier: mini -->` / `<!-- auto_tier: mini -->`（auto_tier 插在 plan_tier 行后，init-session.sh:251-260 注释同口径） | PASS |
| 乙 | EST=60 FILES=3 MODS=1 | 非 mini 保持缺省 | rc=0；`[init] auto-tier: 体量三条件未全命中或输入缺失/非法，保持缺省档（Rule 38.6 fail-safe）`；产物=generic task_plan.md，L8 `<!-- plan_tier: standard -->`，auto_tier 0 命中 | PASS |
| 丙 | TASK_PLAN_TIER=general（显式） | 显式优先、不打标 | rc=0；输出无任何 auto-tier 行（自动判定未参与，init-session.sh:116 前置 `[ -z "$PLAN_TIER" ]` 闸门实证）；产物 L8 `<!-- plan_tier: standard -->`，auto_tier 0 命中 | PASS |
| 丁 | EST=10 FILES=1 MODS=1 + TASK_TIER_EXCLUDE=1 | ④排除不降档 | rc=0；`[init] auto-tier: 命中④排除条件（保护区/Rule 36 技能修改/D6 高危），不自动降 mini（Rule 38.6；显式指定 mini 仍可）`；产物 L8 `<!-- plan_tier: standard -->`，auto_tier 0 命中 | PASS |

回归：`bash skills/task-planner/scripts/selftest-plan-tier.sh` → `Total: 32 PASS=32 FAIL=0`（提案期待 ≥28 PASS 0 FAIL，满足）。

## b) AUTO-TIER 复核段（check-complete.sh:944-960）

夹具：/tmp/s32v/b-compliant（auto_tier:mini，2 Phase，白名单④理由，3-File 齐备）与 /tmp/s32v/b-oversize（同 + Phase 3）。

- 合规 mini：rc=0，输出含 `[plan] AUTO-TIER REVIEW PASSED (auto_tier=mini 体量复核合规: Phase ≤2 ∧ 执行范围表数据行 ≤2)`，**无** AUTO-TIER WARNING
- 超限 mini（3 Phase）：rc=0（warn 档不阻断，符合 S23 设计），输出含：
  `[plan] AUTO-TIER WARNING (task-v091 S23 Rule 38.6 复核, warn 档不阻断): auto_tier=mini 但实际体量超限 — Phase 数=3 >2 — 误降档计划带收缩门组走完全程, 复核任务体量与 38.1 条件（后续任务可显式 TASK_PLAN_TIER=standard）`
- 备注：初版夹具因 Executor 理由缺白名单关键词触发 DELEGATION GATE exit 1（既有 25.4 门，非 AUTO-TIER 段行为）；补「用户显式：白名单④登记」后 b-compliant rc=0。此为夹具修正，非缺陷。

## c) A-2 注释对照 check-plan-dispatch 实跑（关键判定）

修订后 38.4③ 注释（critical-rules.md:340，S24 40a1880 引入）逐句对照：

| 注释断言 | 实跑证据 | 判定 |
|---|---|---|
| 「无 Executor 行的 Phase 按派发型从严（cpd 头注）」 | c10b（同形非 mini 对照）rc=1：`[plan-dispatch] ✗ Phase 2: 缺 S-unit 表或数据行(Rule 22.6)` | 属实 |
| 「其 mini 豁免落点是 ④ 的 MINI_EXEMPT 活分支」 | c11a（mini + Phase2 无 Executor 行且无表，无子代理声明）rc=0：`[plan-dispatch] ✓ 1 个派发型 Phase 均有带执行体的 S-unit 表`（MINI_EXEMPT=1 路径，cpd:86-89,181-183） | 属实 |
| ③「floor→0.0 使 25.4a 白名单分支不可达，视白名单直通=效果等价表述」 | check-complete.sh:115-120：mini 时 DELEGATION_RATE_FLOOR=0.0，rate≥0.0 恒真 → `if [ "$rate_ok" -eq 0 ]` 白名单比对分支不可达（b-compliant 实跑 rate=0.000 floor=0.0 直走 PASSED） | 属实 |
| ③④ 并存非冗余、禁以「死代码」定性误删 | c11a（④ 活放行）vs c10b（非 mini 违规）同形对照差异仅 plan_tier 一行，证明 ④ 分支确承载 mini 豁免；删 ④ = 行为变更 | 属实 |

补充探针（如实登记，均不推翻注释）：
- 全文无 `- **Executor:**` 行 → legacy fail-open（cpd:56-61），rc=0 跳过门控（c1/c2 实测）。提案 A-2 设计「无 Executor 行样例 rc=0 且含 ✓ S-unit 表」的语义对应「计划内有无 Executor 行的 Phase」（c11a/c11b，✓ 行实测在案）；legacy 捷径是既有 v065 F-2 行为，非 ④ 分支，注释未失实。
- 有子代理 Executor 声明（has_subagent=1）时 MINI_EXEMPT 恒 0，mini 亦不豁免缺表（c3/c5 实跑 rc=1，cpd:89 逻辑实证）——与注释「仍声明子代理 Executor 的 Phase 不豁免」一致。

## 结论

- A-1（S22/S23/SKILL L64）：四条件闸门、显式优先、④排除、auto_tier 标记、AUTO-TIER 复核（超限点名/合规放行）全部实测符合提案 §三 A-1 设计。PASS
- A-2（S24 38.4③ 注释）：逐断言对照 cpd 实跑与源码，注释不失实；④ MINI_EXEMPT 活分支实证在案（c11a rc=0 ✓ 行 / c10b rc=1 对照）。PASS
- 回归 selftest-plan-tier.sh 32/0。

## 负结果登记

- 无 FAIL 项。c5/c7「子代理声明存在 + 无 Executor 行 Phase 缺表」在 mini 下不豁免（rc=1）——这是 ④ 的既定边界（has_subagent 计数全文级），非缺陷；已入补充探针。
- b-compliant 首轮 rc=1 属夹具白名单理由缺失，修正后复跑 rc=0，根因非 AUTO-TIER 段。
