# S32-g2-mech-flow — 干净上下文验证终版检查点（A-1/A-2/B-1/B-2）

> 子代理 S32-g2（全新上下文）。worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v091/skills/task-planner（HEAD a05bd5e 时代，含 S28 f8284d0 / S29 1b9437e 终态）。
> 判定基准=提案 efficiency-proposal.md §三验证设计 + progress.md S22/S23/S24/S28/S29 行。
> 全部验证在 /tmp 夹具执行（a1verify/a2verify2/b1verify/b2verify），worktree 零写入。

## 逐项结论

### A-1 auto-tier 四组构造任务 — PASS
夹具：/tmp/a1verify/plans/task-a1{a,b,c,d}，跑 worktree init-session.sh（CWD 守卫要求 plans/<id>/）。脚本输入面=env（TASK_AUTO_TIER/TASK_EST_MINUTES/TASK_SCOPE_FILES/TASK_SCOPE_MODULES/TASK_TIER_EXCLUDE）+ 第3位参/env TASK_PLAN_TIER。

| 组 | 输入 | 期待 | 实际（原文） | 判定 |
|----|------|------|-------------|------|
| a | TASK_AUTO_TIER=1 EST=10 FILES=1 MODS=1 | mini + auto_tier 标记 | 输出「[init] auto-tier 命中: frontmatter 已记 auto_tier: mini 标记 (Rule 38.6, task-v091 S22)」；frontmatter 原文：`<!-- template_type: mini-lite -->` / `<!-- plan_tier: mini -->` / `<!-- auto_tier: mini -->`（task_plan.md:2-3） | PASS |
| b | 同上但 EST=60 FILES=3 | 不降档 | 「[init] auto-tier: 体量三条件未全命中或输入缺失/非法，保持缺省档（Rule 38.6 fail-safe）」；产物 420 行，`task_plan.md:8 <!-- plan_tier: standard -->`，无 auto_tier 行 | PASS |
| c | 同 a + 显式 TASK_PLAN_TIER=general | general 显式优先 | 无 auto-tier 判定行（init-session.sh:116 PLAN_TIER 非空短路）；`task_plan.md:8 <!-- plan_tier: standard -->`（general=缺省档用 standard 模板，无 mini 标记）、`grep -c auto_tier`=0、420 行 | PASS（显式优先铁律成立） |
| d | 同 a + TASK_TIER_EXCLUDE=1 | ④排除不降 | 「[init] auto-tier: 命中④排除条件（保护区/Rule 36 技能修改/D6 高危），不自动降 mini（Rule 38.6；显式指定 mini 仍可）」；`task_plan.md:8 <!-- plan_tier: standard -->`，无 auto_tier | PASS |

回归：`bash scripts/selftest-plan-tier.sh` → 原文 `Total: 32 PASS=32 FAIL=0`（≥28 期待满足，PT-29..32 为 S23 新增 4 断言）。
AUTO-TIER 复核段实证存在：check-complete.sh:944-959（`auto_tier: mini` grep 消费锚 + Phase 数/执行范围表复核 + WARNING/REVIEW PASSED 两分支，warn 档不阻断）——S23 落地属实。

### A-2 38.4③ 口径注释 — PASS（注释不失实）
注释原文（critical-rules.md:340 38.4③ 尾括注，2026-09-27 S24 A-2）：「③仅免委派率统计的格式要求（floor→0.0）…『视白名单直通』为效果等价表述而非独立机制，白名单放行本体在 25.4a；无 Executor 行的 Phase 按派发型从严（check-plan-dispatch 头注），其 mini 豁免落点是 ④ 的 MINI_EXEMPT 活分支——settle_phase 首分支须「有 Executor 行且=主进程」才免表，无 Executor 行 Phase 非 mini 将计违规，故 ③④ 作用对象不同、并存非冗余，禁以『死代码』定性误删」。
读码比对（check-plan-dispatch.sh）：
- `:5` 头注「无 Executor 行按派发型从严」—与注释「从严」口径一致
- `:175` settle_phase 首分支 `have_executor=1 ∧ executor_main=1 → return 0`（主进程免表）—与注释「首分支须有 Executor 行且=主进程」一致
- `:181-183` MINI_EXEMPT=1 且无表无行 → 免违规（活分支非死代码）—与注释「④ 是活豁免」一致
行为对拍（/tmp/a2verify2，各含 1 个无 Executor 行 Phase）：
- mini 样例：`bash check-plan-dispatch.sh` → 原文 `[plan-dispatch] ✓ 1 个派发型 Phase 均有带执行体的 S-unit 表` **rc=0**（活豁免在位，期待 rc=0 达成；✓ 行含「S-unit 表」字样，与提案判定口径吻合）
- standard 样例：`[plan-dispatch] ✗ Phase 1: 缺 S-unit 表或数据行(Rule 22.6)` **rc=1**（非 mini 计违规，注释「非 mini 将计违规」属实）
判定=注释与实际行为一致，无失实。附带披露（不改判定）：mini 样例 rc=0 时 ✓ 汇总仍打印（被豁免 Phase 计入 dispatch_count，文案称「均有带执行体的 S-unit 表」而该 Phase 实际无表——文案微口径差异，不影响 rc 与豁免语义）。

### B-1 契约可用性 — PASS
材料：templates/subagent_dispatch.md（实测 60 行；progress S28 中间态 67 行已由 f8284d0 修正 60）+ references/dispatch-examples.md（实测 41 行）+ critical-rules.md:134 22.4b 修订句（「派发 prompt 必须附模板路径引用（templates/subagent_dispatch.md）；已填示例以 references/dispatch-examples.md §1 落盘承载，派发 prompt 只放路径、需对照示例时 Read（原句『必须附该模板与一份已填示例』语义改写为路径引用…静态断言 selftest-dispatch.sh DX 组）」）。
干净读者判定（仅凭模板+examples）：可组装合法派发 prompt——
- 九字段齐全：模板 §1目标/§2输入(三文件读写契约+材料包)/§3验收/§4Scope/§5工作路径/§6时长预算/§7返回格式/§8checkpoint/§9上下文预算，判定 token（status:/acceptance:/checkpoint:/subagent-state/）与 check-dispatch scan_missing 对齐
- 8 字段返回：§7 代码块逐字段 status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence 与填写口径（统计类禁自报汇总等），examples §1 提供已填示例
无缺口需回补源文件。
机器验证：
- `bash scripts/selftest-dispatch.sh` → 原文 `Total: 29 PASS=29 FAIL=0`（含 DX-01..DX-05b；与 progress S29 记载 29/0 一致）
- 好样例 /tmp/b1verify/plans/task-b1/prompt_good.txt（894 字符，九字段组装+三文件绝对路径+8 字段 key 名+subagent-state 路径）：
  - `check-dispatch.sh check <good> <plan-dir>` → **rc=0**（无缺项）
  - `TASK_PLANNER_PLAN_DIR=<pd> TASK_PLANNER_DISPATCH_ENFORCE=enforce check-dispatch.sh pretool <good> s32` → **rc=0**（成功路径静默）
- 坏样例 prompt_bad.txt（仅 task_plan 路径+「8 fields」字样，缺其余三文件路径与返回 key 字面）：`check` → **rc=1**，stdout 逐行点名原文：`findings.md / progress.md / status: / acceptance: / checkpoint: / subagent-state/`（task_plan.md 因 prompt 含其绝对路径经 inode 身份命中不计缺项——点名与缺失事实一致）
签名澄清（如实披露，非行为偏差）：提案验证设计字面写 `pretool <样例> <plan-dir>`；实际签名 `pretool <prompt-file> [sid]`（check-dispatch.sh:8 自注释，第二参=sid），计划目录走 TASK_PLANNER_PLAN_DIR env 或 prompt 自声明锚定（三级解析 :166-192）。验证已按实际签名+env 锚定执行。

### B-2 表等价性（12 列 vs 10 列）— PASS
材料：templates/task_plan.md:356-367 Handoff 10 列表（`| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |`，rescue/retry_count/verify_done 折叠为「备注」单列，字段内容不删）+ critical-rules.md:133 22.4a 单写者括注（「findings.md/progress.md 的追加…由子代理**必做**；主进程仅在子代理未自写时兜底回填…**禁止双侧同写同一锚点**；主进程 Read 复核义务不变」）。
对拍（/tmp/b2verify：两目录计划，Phase 段（1 主进程白名单①+2 executor+3 architect）与 Handoff 数据逐字段等价，仅列结构 12 vs 10 不同）：
- `bash scripts/check-delegation.sh stats /tmp/b2verify/plans/task-b2-12` → 原文 `{"phases_total":3,"phases_delegated":2,"main_direct_count":1,"delegation_rate":0.667,"main_direct":[{"phase":"1 直做","executor":"主进程（白名单①：文档直改 ≤3行）","reason":"白名单①：文档直改 ≤3行","needs_git_evidence":1,"self_declared":0}],"violations":[],"verdict":"ok"}` rc=0
- `bash scripts/check-delegation.sh stats /tmp/b2verify/plans/task-b2-10` → JSON **逐字符一致**（verdict=ok / rate=0.667 / main_direct / violations 全同）rc=0
读码回答「stats 是否按列位解析 verify_done」=**不解析**（check-delegation.sh stats 本体 :435-545 无 verify_done 逻辑；`grep -rn verify_done scripts/*.sh | grep -v selftest` 唯一非 selftest 命中在 check-complete.sh:969-1010——:1007 由表头行动态定位列位，10 列折叠后「备注」单元内含 verify_done 字样仍动态命中，表头无该列 fail-open 跳过；与 S29 progress「verify_done 无机器消费+折叠感知 fail-open」披露一致）。
回归：`bash scripts/selftest-delegation.sh` → 原文 `Total: 38    PASS=38  FAIL=0`。

## 总判定
A-1 PASS / A-2 PASS / B-1 PASS / B-2 PASS（0 FAIL；2 处如实披露：① pretool 签名与提案字面差异（签名澄清非行为偏差）② check-plan-dispatch ✓ 汇总文案对 mini 豁免 Phase 仍称「均有 S-unit 表」（微口径差异，不影响 rc/判定））。

## 负结果排查记录
- 排除：auto-tier 非预期降档（b/c/d 三组均未降）；注释失实（读码+双侧 rc 对拍一致）；压缩后模板字段缺失（九字段/八字段全在，机器七项判定锚齐全）；10 列折叠破坏 stats（JSON 逐字符一致）。
- 遗留：A-1 c 组「general 显式」产物 standard 标记属 38.2 既有语义（显式 general=缺省档），非 A-1 范围；未跑 check-complete 全链（超本组职责，AUTO-TIER 段存在性与消费锚已静态实证）。

---
## 8 字段返回（T5 最终结论）

status: done
acceptance: 4/4 PASS — [A-1 四组+回归:PASS / A-2 注释对拍:PASS / B-1 契约+好坏rc:PASS / B-2 JSON对拍+读码:PASS]
files: /tmp/a1verify/plans/task-a1a/task_plan.md(+1, frontmatter:2-3 auto_tier 标记); /tmp/a1verify/plans/task-a1b/task_plan.md(+1); /tmp/a1verify/plans/task-a1c/task_plan.md(+1); /tmp/a1verify/plans/task-a1d/task_plan.md(+1); /tmp/a2verify2/mini_plan.md(+1); /tmp/a2verify2/std_plan.md(+1); /tmp/b1verify/plans/task-b1/task_plan.md(+1); /tmp/b1verify/plans/task-b1/prompt_good.txt(+1); /tmp/b1verify/plans/task-b1/prompt_bad.txt(+1); /tmp/b2verify/plans/task-b2-12/task_plan.md(+1); /tmp/b2verify/plans/task-b2-10/task_plan.md(+1); 检查点重写(+1); worktree 零写入
evidence: a组 init 输出「[init] auto-tier 命中...auto_tier: mini 标记」+frontmatter 原文行2-3; b组「体量三条件未全命中...保持缺省档」standard:8; c组 PLAN_TIER 非空短路 无判定行 standard:8 auto_tier grep=0; d组「命中④排除条件...不自动降 mini」; selftest-plan-tier `Total: 32 PASS=32 FAIL=0`; cpd mini `✓ 1 个派发型 Phase...` rc=0 / std `✗ Phase 1: 缺 S-unit 表或数据行(Rule 22.6)` rc=1; selftest-dispatch `Total: 29 PASS=29 FAIL=0`; check 好样例 rc=0 / 坏样例 rc=1 缺项原文 findings.md,progress.md,status:,acceptance:,checkpoint:,subagent-state/; stats 12列与10列 JSON 逐字符一致(verdict=ok,rate=0.667); selftest-delegation `Total: 38    PASS=38  FAIL=0`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v091-efficiency-optimization/subagent-state/S32-g2-mech-flow.md (status: done)
findings_written: none（验证执行者角色，无派生 findings 义务；全部结论在本检查点）
blockers: none
confidence: HIGH
