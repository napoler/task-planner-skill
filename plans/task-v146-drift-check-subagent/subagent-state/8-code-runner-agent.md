# 8-code-runner-agent 检查点 — task-v146 改动后终验轮（全量 selftest 回归）

- status: **FINAL**（58/58 脚本执行完；双法独立复算一致；FAIL 原文全量提取；worktree 副作用检查通过）
- 工作副本: /mnt/data/dev/task-planner-skill-worktrees/task-v146 (branch wt/task-v146, HEAD **4ec0b63** "Phase 4 S5 — selftest-drift-check-subagent 20 断言守护+registry 登记"，commit 时间 2026-10-08 05:21:09 +0800 = 2026-10-07 21:21:09 UTC)
- 脚本目录: /mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/scripts
- 基线对照: 1-code-runner-agent.md（da1f308：57 脚本 ΣPASS=863 ΣFAIL=21，FAIL≠0 = 15 个）
- 测前/测中 worktree 状态修正（如实记录）: precheck 快照（约 21:20 UTC）曾见 ` M selftest-registry.tsv` + `?? selftest-drift-check-subagent.sh` 2 处未提交；父进程于 21:21:09 UTC 提交 4ec0b63（恰含这 2 个文件，88 插入行）后工作树转净。**测试实际运行于 2026-10-07T21:23:34Z – 21:25:35Z，执行状态 = HEAD 4ec0b63、工作树 clean（测后 status 仍为空）**。
- 执行方式: /tmp/tpv146_run.sh（后台串行）；逐脚本 `timeout 90 bash <script>`，完整输出落 /tmp/tpv146_full/<script>.sh.out，进度+rc+耗时落 /tmp/tpv146_progress.log
- 时间戳: START 2026-10-07T21:23:34Z；ALL_DONE 2026-10-07T21:25:35Z（总 121s）

## ① 逐脚本 Total 行清单（58 个，原文）

| # | 脚本 | Total 行原文 |
|---|------|-------------|
| 1 | selftest-active-plan.sh | `Total: 29 PASS=29 FAIL=0` |
| 2 | selftest-agent-coverage.sh | `Total: 9 PASS=7 FAIL=2 SKIPPED=0` |
| 3 | selftest-ask-default-timeout.sh | `Total: 11 PASS=10 FAIL=1` |
| 4 | selftest-batch-pilot.sh | `Total: 10 PASS=10 FAIL=0` |
| 5 | selftest-capability-persistence.sh | `Total: 20 PASS=18 FAIL=2` |
| 6 | selftest-check-conflicts.sh | `Total: 7 PASS=7 FAIL=0` |
| 7 | selftest-check-drift.sh | `Total: 6 PASS=6 FAIL=0` |
| 8 | selftest-conclusion-discipline.sh | `Total: 24 PASS=24 FAIL=0` |
| 9 | selftest-context-hygiene.sh | `Total: 12 PASS=12 FAIL=0` |
| 10 | selftest-delegation.sh | `Total: 38    PASS=38  FAIL=0` |
| 11 | selftest-dispatch-grain.sh | `Total: 10 PASS=10 FAIL=0` |
| 12 | selftest-dispatch.sh | `Total: 31 PASS=31 FAIL=0` |
| 13 | selftest-drift-check-subagent.sh | `Total: 20 PASS=20 FAIL=0` |
| 14 | selftest-error-loop.sh | `Total: 16 PASS=16 FAIL=0` |
| 15 | selftest-evidence-goal-gate.sh | `Total: 21 PASS=21 FAIL=0` |
| 16 | selftest-execution-honesty.sh | `Total: 14 PASS=13 FAIL=1` |
| 17 | selftest-execution-stability.sh | `Total: 19  PASS=19  FAIL=0` |
| 18 | selftest-fallback.sh | `Total: 31  PASS=31  FAIL=0` |
| 19 | selftest-final-gate-hash.sh | `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（无 Total 行，等效结果行） |
| 20 | selftest-fine-grain-steps.sh | `Total: 11 PASS=11 FAIL=0` |
| 21 | selftest-interaction.sh | `Total: 11 PASS=11 FAIL=0` |
| 22 | selftest-iteration-persistence.sh | `Total: 18 PASS=16 FAIL=2` |
| 23 | selftest-iterative-optimizer.sh | `Total: 8 PASS=8 FAIL=0` |
| 24 | selftest-knowledge-brief.sh | `Total: 16  PASS=16  FAIL=0` |
| 25 | selftest-lane-advancement.sh | `Total: 14 PASS=13 FAIL=1` |
| 26 | selftest-mechanism-profile.sh | `Total: 19 PASS=19 FAIL=0` |
| 27 | selftest-media-agents.sh | `Total: 10 PASS=9 FAIL=1` |
| 28 | selftest-media-dispatch.sh | `Total: 9 PASS=8 FAIL=1` |
| 29 | selftest-methodology.sh | `Total: 16 PASS=16 FAIL=0` |
| 30 | selftest-periodic-review.sh | `Total: 10 PASS=5 FAIL=5` |
| 31 | selftest-plan-dispatch.sh | `Total: 12 PASS=12 FAIL=0` |
| 32 | selftest-plan-tier.sh | `Total: 32 PASS=32 FAIL=0` |
| 33 | selftest-reflect-verify.sh | `Total: 12 PASS=12 FAIL=0` |
| 34 | selftest-registry.sh | `Total: 5 PASS=4 FAIL=1 (registry rows=57, actual selftest=58)` |
| 35 | selftest-reliability-institution.sh | `Total: 16 PASS=14 FAIL=2` |
| 36 | selftest-requirement-coverage.sh | `Total: 23 PASS=21 FAIL=2` |
| 37 | selftest-requirement-grading.sh | `Total: 7 PASS=6 FAIL=1` |
| 38 | selftest-rescue-chain.sh | `Total: 11 PASS=11 FAIL=0` |
| 39 | selftest-review-library.sh | `Total: 15 PASS=15 FAIL=0` |
| 40 | selftest-root-resolution.sh | `Total: 17 PASS=16 FAIL=1` |
| 41 | selftest-rule23-conflict-scan.sh | `Total: 3 PASS=3 FAIL=0` |
| 42 | selftest-rule-reserve.sh | `Total: 10 PASS=10 FAIL=0` |
| 43 | selftest-self-resolution.sh | `Total: 13 PASS=10 FAIL=3` |
| 44 | selftest-shared-tracker.sh | `Total: 11 PASS=11 FAIL=0` |
| 45 | selftest-skill-collab.sh | `Total: 25  PASS=25  FAIL=0` |
| 46 | selftest-skill-modify.sh | `Total: 9 PASS=9 FAIL=0 (SKIP=0)` |
| 47 | selftest-skill-split.sh | `Total: 41  PASS=41  FAIL=0` |
| 48 | selftest-smart-merge.sh | `Total: 17 PASS=17 FAIL=0` |
| 49 | selftest-sync-index.sh | `Total: 13 PASS=13 FAIL=0` |
| 50 | selftest-task-boundary.sh | `Total: 11 PASS=11 FAIL=0` |
| 51 | selftest-template-lifecycle.sh | `Total: 24 PASS=24 FAIL=0` |
| 52 | selftest-template-sense.sh | `Total: 8 PASS=8 FAIL=0` |
| 53 | selftest-tier-b.sh | `Total: 18 PASS=18 FAIL=0` |
| 54 | selftest-tool-selection.sh | `Total: 12 PASS=11 FAIL=1` |
| 55 | selftest-user-instruction-priority.sh | `=== ALL PASS ===`（无 Total 行；内部 ✓ 标记恰 7 个 → 计算口径 PASS=7 FAIL=0） |
| 56 | selftest-vc-gate.sh | `Total: 11 PASS=11 FAIL=0` |
| 57 | selftest-veto.sh | `Total: 13 PASS=13 FAIL=0` |
| 58 | selftest-workflow-orchestration.sh | `Total: 16 PASS=15 FAIL=1` |

## ② 汇总行

- 脚本数: **58**（57 基线 + 1 新增）
- ΣPASS: **876**
- ΣFAIL: **28**
- FAIL≠0 脚本数: **17**
- 独立复算（两法一致）: ① sed/awk 法 — 56 个 Total 行 ΣPASS=847 ΣFAIL=28，另加 final-gate-hash 结果行 22/0 + uip 计算 7/0 → 876/28；② Python 解析法（/tmp/tpv146_recalc.py）— 58/58 文件解析、876/28、逐行 Total==PASS+FAIL 校验 0 MISMATCH
- rc 分布: FAIL≠0 的 17 脚本全部 rc=1，其余 41 脚本 rc=0（rc 与 FAIL 状态严格一致）
- 耗时: 总 121s；单脚本最大 16s（final-gate-hash / vc-gate），0 TIMEOUT（90s 限无触碰）

## ③ 与基线差值分析（基线 da1f308: 57 脚本 863/21/15 个 FAIL≠0）

**预期口径（派发声明）**: 新脚本 +20 PASS 0 FAIL；selftest-agent-coverage.sh FAIL 1→2（AC-04 暂态）；其余脚本 FAIL 状态同基线。→ 预期应 ΣPASS=882、ΣFAIL=22。

**实际**: ΣPASS 863→876（净 +13）、ΣFAIL 21→28（净 +7）、脚本 57→58。

### 命中预期的部分
1. **selftest-drift-check-subagent.sh（新）20 PASS / 0 FAIL rc=0** — 与 +20 PASS 预期完全一致。20 条新断言原文（全 PASS）:
   - `DCS-01 PASS [DRIFT CHECK] 步骤行含 drift-checker`
   - `DCS-02 PASS 只读检测执行体行含 drift-checker 无 task-drift-guard`
   - `DCS-03 PASS Chain 步骤 4 含 drift-checker`
   - `DCS-04 PASS C4 行含 drift-checker`
   - `DCS-05 PASS B/C 类处理完行含 drift-checker`
   - `DCS-06 PASS Rule 15 bullet+高频漂移纠正摘要行含 drift-checker`
   - `DCS-07 PASS 路由表漂移检测行含 drift-checker+haiku-1`
   - `DCS-08 PASS SKILL.md Skill(task-drift-guard) 计数=0`
   - `DCS-09 PASS References 双载体说明行`
   - `DCS-10 PASS 反模式偏移比对禁止行含 Rule 61`
   - `DCS-11 PASS 索引括注 40-61+头部 1-39 保全+Rule 61 摘要 bullet`
   - `DCS-12 PASS Rule 61 标题+六锚齐全`
   - `DCS-13 PASS 15.4 锚+Skill(task-drift-guard) 计数=0`
   - `DCS-14 PASS drift-checker.md 存在+tools Read/Write+model 非空`
   - `DCS-15 PASS 双载体三态一致`
   - `DCS-16 PASS subagent-state/ 检查点契约串`
   - `DCS-17 PASS agent-coverage.md 含 drift-checker 行`
   - `DCS-18 PASS hook 含 drift-checker 无 task-drift-guard`
   - `DCS-19 PASS SKILL.md 行数<=558+61.4 清零+61.5 check-drift.sh`
   - `DCS-20 PASS 全 skills/ 树 Skill(task-drift-guard) 精确串=0`
2. **selftest-agent-coverage.sh 8/1→7/2** — 新增 `AC-04 FAIL §一 候选 agent 47 中缺位: drift-checker（B 类复发，需补实体或修正矩阵名）`。独立验证与"未部署暂态"一致：`test -f $HOME/.zcode/agents/drift-checker.md` = **缺失**（该目录现有 95 文件）；worktree 内 companion 副本 `/mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/companion/agents/drift-checker.md` **存在**（DCS-14 PASS 佐证）。AC-04 口径 = 矩阵 §一 候选实体在 `$HOME/.zcode/agents/<name>.md` 的 test -f 存在性（目录在位不 fail-open）。
3. **registry 同步**: rows 56→57（新脚本已登记，selftest-registry.tsv 第 58 行含 `selftest-drift-check-subagent.sh` 行）；T02 仍为 `未登记: selftest-periodic-review.sh`（基线同款遗留，非本轮引入）。

### 预期外部分（6 个脚本各 1 条 PASS→FAIL 翻转，Total 总数均未变）——全部同一根因
| 脚本 | 新 FAIL 断言原文 |
|------|-----------------|
| selftest-capability-persistence.sh | `CP-05 FAIL SKILL.md '40-55' 计数=0（应 =1）` |
| selftest-iteration-persistence.sh | `IP-12 FAIL SKILL.md 全集声明「Rule 40-5[5-9]」=0（应 ≥1，级联漏改）` |
| selftest-reliability-institution.sh | `R-09 FAIL SKILL.md 括注锚漂移（含 Rule 40-5[3-9] 全集=0 应 ≥1 / 1-40=0 应 0）` |
| selftest-self-resolution.sh | `SR-08 FAIL Rule 40/41 共存锚损伤（含 Rule 40-5[3-9] 缺失或 ^40\. 子条数 ≠6）` |
| selftest-execution-honesty.sh | `EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-5[3-9]」=0（应 ≥1，级联漏改）` |
| selftest-root-resolution.sh | `RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-5[3-9]」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）` |

**根因第一手证据（只读核查，未改动任何文件）**:
- SKILL.md:271 索引行被 Phase 3 载体切换改写：da1f308 原文 `详见 \`references/critical-rules.md\`（Rules 1-39（含 Rule 40-55 全集，Rule 55 可复用能力落盘纪律））：` → HEAD 现状 `详见 \`references/critical-rules.md\`（Rules 1-39（含 Rule 40-61 全集，Rule 55 可复用能力落盘纪律 / Rule 61 偏移检查子代理化））：`（`git diff da1f308..HEAD -- SKILL.md` 单行改动）。
- `grep -c '40-5' SKILL.md`: da1f308 = 1（即行 271）；HEAD = **0**。6 个守卫的宽容锚 `Rule 40-5[3-9]`（脚本注释自述"防钉死"设计，历史覆盖 40-53..40-59 各纪元）不再命中 `40-61`。
- 即：本任务新增 Rule 61 后索引括注按既有惯例从 `40-55` 推进到 `40-61`（DCS-11 反向确认 40-61 在位），但超出 6 个守卫锚的宽容窗口 → 6 条非预期 FAIL 全部由这一处载体编码演进级联触发。修复口径（改 6 个守卫锚宽容化 vs 调整索引行措辞）属主进程裁决；本子代理未修复、未改动任何仓库文件。

### 其余
- 其余 41 个脚本逐脚本 PASS/FAIL 与基线完全一致：其中 10 个 FAIL 集原样（ask-default-timeout RT-09、lane-advancement LA-14、media-agents MA-10、media-dispatch MD-08、periodic-review PR-03/04/05/09/10、registry T02、requirement-coverage RC-13/15、requirement-grading RG-07、tool-selection TS-12、workflow-orchestration WF-12，全部为 config.json properties 键数=42（应 40）与基线历史 FAIL）＋ 全部 0-FAIL 脚本。
- 差值核对: 预期 ΣFAIL=22 vs 实际 28 = +6，恰等于上表 6 条翻转；预期 ΣPASS=882 vs 实际 876 = -6，同一来源。此外无任何其他偏差。

## ④ FAIL≠0 脚本的 FAIL 断言原文（17 脚本 / 28 条，未美化）

### selftest-agent-coverage.sh — `Total: 9 PASS=7 FAIL=2 SKIPPED=0`
- `AC-04 FAIL §一 候选 agent 47 中缺位: drift-checker（B 类复发，需补实体或修正矩阵名）`
- `AC-07 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）`

### selftest-ask-default-timeout.sh — `Total: 11 PASS=10 FAIL=1`
- `RT-09 FAIL config.json properties 键数=42（应 40）`

### selftest-capability-persistence.sh — `Total: 20 PASS=18 FAIL=2`
- `CP-05 FAIL SKILL.md '40-55' 计数=0（应 =1）`
- `CP-16 FAIL config.json properties 键数=42（应 40，零新键被破坏）`

### selftest-execution-honesty.sh — `Total: 14 PASS=13 FAIL=1`
- `EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-5[3-9]」=0（应 ≥1，级联漏改）`

### selftest-iteration-persistence.sh — `Total: 18 PASS=16 FAIL=2`
- `IP-12 FAIL SKILL.md 全集声明「Rule 40-5[5-9]」=0（应 ≥1，级联漏改）`
- `IP-15 FAIL config.json properties 键数=42（应 40，零新键被破坏）`

### selftest-lane-advancement.sh — `Total: 14 PASS=13 FAIL=1`
- `LA-14 FAIL config.json properties 键数=42（应 40，Rule 49 零新键被破坏）`

### selftest-media-agents.sh — `Total: 10 PASS=9 FAIL=1`
- `MA-10 FAIL config.json properties 键数=42（应 40，零新键承诺被破坏）`

### selftest-media-dispatch.sh — `Total: 9 PASS=8 FAIL=1`
- `MD-08 FAIL config.json properties 键数=42（应 40，Rule 47 零新键被破坏）`

### selftest-periodic-review.sh — `Total: 10 PASS=5 FAIL=5`
- `PR-03 FAIL Rule 57 前后对照检查维度缺失`
- `PR-04 FAIL Rule 57 自动纠正机制缺失`
- `PR-05 FAIL Rule 57 开关键缺失`
- `PR-09 FAIL selftest-registry.tsv 注册缺失`
- `PR-10 FAIL SKILL.md C39 引用缺失`

### selftest-registry.sh — `Total: 5 PASS=4 FAIL=1 (registry rows=57, actual selftest=58)`
- `T02 FAIL 未登记: selftest-periodic-review.sh`

### selftest-reliability-institution.sh — `Total: 16 PASS=14 FAIL=2`
- `R-09 FAIL SKILL.md 括注锚漂移（含 Rule 40-5[3-9] 全集=0 应 ≥1 / 1-40=0 应 0）`
- `R-12 FAIL config.json properties 键数=42（应 40）`

### selftest-requirement-coverage.sh — `Total: 23 PASS=21 FAIL=2`
- `RC-13 FAIL config.json properties 键数=42（应 40，Rule 51 零新键被破坏）`
- `RC-15 FAIL critical-rules.md '56.' 子条命中=5（应 =0，编号假设被破坏）`

### selftest-requirement-grading.sh — `Total: 7 PASS=6 FAIL=1`
- `RG-07 FAIL config.json properties 键数=42（应 40，Rule 50 零新键被破坏）`

### selftest-root-resolution.sh — `Total: 17 PASS=16 FAIL=1`
- `RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-5[3-9]」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）`

### selftest-self-resolution.sh — `Total: 13 PASS=10 FAIL=3`
- `SR-08 FAIL Rule 40/41 共存锚损伤（含 Rule 40-5[3-9] 缺失或 ^40\. 子条数 ≠6）`
- `SR-09 FAIL config.json properties 键数=42（应 40）`
- `SR-12 FAIL registry 漂移（selftest-self-resolution 命中 1 应 ≥1 / 总行数 58 应 59=脚本数+表头）`

### selftest-tool-selection.sh — `Total: 12 PASS=11 FAIL=1`
- `TS-12 FAIL config.json properties 键数=42（应 40）`

### selftest-workflow-orchestration.sh — `Total: 16 PASS=15 FAIL=1`
- `WF-12 FAIL config.json properties 键数=42（应 40）`

## ⑤ 负结果 / 异常注记

- **TIMEOUT=0**：58/58 均在 90s 限内（最大 16s）；无 rc=124；无脚本崩溃。
- **含"FAIL"字样但为 PASS 的行**（未计入任何 FAIL）: `IP-08 PASS critical-rules.md 四要素锚 … PASS-FAIL=2 …`、`RR-10 PASS 负向自检: 缺锚副本使 RR-03 同款判定 FAIL…`（基线同款两条负向自检说明）。
- **测试副作用**：测后 `git status --porcelain` 为空；无文件被测试修改（脚本自述只读）。
- **时间线说明**：precheck 首问（约 21:20 UTC）见 2 处未提交变更；父进程 21:21:09 UTC 提交 4ec0b63（内容=新脚本 87 行 + registry +1 行，88 插入）后转净；回归运行于 clean @4ec0b63。若父进程需要 "dirty 态" 复跑请另派（本次实际为干净提交态）。
- **未发现**: 环境 flake（rc 与 FAIL 严格一一对应）；解析歧义（两法一致 + Total==PASS+FAIL 全校验通过）；SKIPPED 异常（唯一 SKIPPED=0 字段为正常输出）。

## ⑥ Post-verify

- 独立复算: sed/awk 法 847+28（56 Total 行）+ 22/0 + 7/0 = 876/28；Python 法 876/28；文件覆盖 58/58；逐行 Total==PASS+FAIL 0 MISMATCH。
- 抽查: 新脚本输出 20 行 DCS-xx PASS + `Total: 20 PASS=20 FAIL=0`；registry.tsv 第 58 行为新脚本登记行（grep 确认）；$HOME/.zcode/agents/drift-checker.md test -f 缺失（AC-04 暂态实证）。
- 根因核查: `git diff da1f308..HEAD -- SKILL.md` 的 40-55→40-61 单行演进 + `grep -c '40-5' SKILL.md`=0 为 6 条翻转 FAIL 的直接证据（只读核查）。
