# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:01-planwriter] 计划撰写产出（2026-11-20，主进程代登）
- 产出：task_plan.md（454 行，R0-R5 逐字+20 VC+G1-G8+8 S-unit P1-P4+FMEA+📦基线/🛡终检 dogfood 区块+D1/D2+风险四要素）、knowledge-brief.md（88 行）
- 验收：结构自查 2/3 PASS+1 PARTIAL（23 脏项=盘点前既有，非本轮新增）；主进程 Read 全文复核通过
- 关键结论：①防倒退已有 51.15/74.7/106.7/22.4e/103.3b 地基（规范阈值面），本任务补「进度产出面」泛化 ②模板 44 文件无 lineage/spec_version/分级机制（R4/R5 全新建设）③template_type 选型 rule-enhancement ④新 Rule 编号候选 111+，实施前 grep 三份全集实测
- 遗留：VC-20 计划撰写口径的 `wc -l`=0 判据与 plans/ 子目录未跟踪态存在口径摩擦（实施期按实际口径登记调整，不阻塞）
- 证据锚：task_plan.md:10,44-51,253-305,364-372；checkpoint=subagent-state/01-general-planwriter.md

#### [sub:02-judge] 计划定稿可行性判别（2026-11-20，主进程兜底直判——子代理限流三连败，降级链穷尽，证据 progress D-03/D-04）
- **结论：PASS-WITH-RISKS（幻锚当场修订后放行）**
- 可执行性 PASS：8 S-unit 输入/产出/VC/时长齐备（task_plan.md:252-294）；37 处 `**Verify command**:` 机器判据；VC-18 负断言无占位符
- 相容性 PASS（修订后）：13 处锚实测验真——run-selftests.sh/check-template-type.sh/init-session.sh/check-complete.sh 存在（check-template-type 不支持 --all，VC-15 已留等效循环兜底口径）；variant/rule-enhancement-type.md 在位；kit/advisor SKILL 在位；防倒退地基五条款逐条验真=51.15@core:109、74.7@discipline:495、106.7@discipline:758、22.4e@dispatch:66、103.3b@dispatch:241（74.7 原文自证"先 74.7 再 51.15 两门互补"，新 Rule 进度产出面为第三门不冲突）；`### 111` 三份全集空号；三份最大号 109/106/110 与计划一致
- **幻锚修订（合规四元组）**：对象=VC-19/G8/FMEA-P3P4/终检表 4 处 `deploy.sh --check` 引用；当前值→拟值=机制无关实测口径（S8 实测部署机制+逐位 diff=0 清单）；依据=`ls skills/task-planner/scripts/deploy.sh`→No such file（一手实测）；影响=验证口径更准确，判据语义不变（仍=部署位与产物 diff=0）；处置=等价替代。修订发生在计划批准/attest 锁定前，属 Rule 74.4 判别回路合法修订
- 风险登记（缓解后放行）：①provider 限流已致子代理三连败——实施期派发可能同样受限，兜底=主进程直做+逐单登记（非静默）②VC-20 计划期 `wc -l`=0 口径与 plans/ 子目录未跟踪态摩擦（实施期按实际口径登记）③knowledge-brief 行数 98 vs 子代理报 88（口径微差非实质）④templates/task_plan.md 与在途 28.2.2 簇合并冲突（FMEA 已有兜底）
- 复核路径：本段全部判据为命令+输出，任何人可复跑验证

#### [sub:03-s2] S2 防倒退机制核心载体落地（2026-11-20，worktree 实施完成）
- 产出（4 文件，纯新增，0 删除）：`$W/skills/task-planner/references/critical-rules.md` 追加 `### 111 进度产出基线防倒退`（:235-250，111.1 登记/none-justified、111.2 attest锁同51.15、111.3 净效果门≥0+`[PROGRESS-REGRESSION]`、111.4 终检对照🛡、111.5 分工互锁74.7/51.15/111、111.6 四环绑定22.4f/106.8/🛡+Rule84/verification）；`$W/skills/task-discipline/references/critical-rules-discipline.md` 插入 `106.8 进度产出防倒退回归门`（:759，返工后/续写派发前/合并部署前/QC重开前全量对照+`[progress-regression]`三件套）；`$W/skills/task-dispatch/references/critical-rules-dispatch.md` 插入 `22.4f 进度产出基线强制携带`（:68，携带基线清单+来源锚+禁就地删降替指令，与`{spec_baseline}`同位注记）；`$W/skills/task-planner/templates/task_plan.md` 插入 `## 📦 进度产出基线`（:61-68，紧随`## 🔒 规范基线`后）与 `## 🛡 防倒退终检`（:392-402，Phase Executor后/`## 🔁 收尾回读梳理记录`前）。
- 验收：①`grep -h -c "^### 111 "` 三份=1,0,0 且含 拆东墙补西墙/净效果/51.15/74.7/PROGRESS-REGRESSION（`critical-rules.md:235,236,240,242,244,246`）②模板 `📦`=2 `🛡`=1 `净效果`=4（`task_plan.md:61,392,398,402`）③`git diff --stat` 仅4文件 39 insertions，`git diff -U0` 无内容删除行 ④`bash skills/task-planner/scripts/selftest-template-lifecycle.sh` RC=0（24 PASS=24 FAIL=0）⑤103.2自审已写入 checkpoint。
- 证据锚：checkpoint=`subagent-state/03-s2-antiregress.md`（里程碑+103.2表+最终结论）；worktree=`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120`。
- 备注：`git diff --stat` 中 discipline/dispatch 各显示 +2 行（单段插入块）属纯新增；既有条款零改动。

#### [sub:04-s3] S3 防倒退机制接线（2026-11-20，worktree 实施完成）
- 产出：①`skills/task-planner/SKILL.md:48,151` 计划期「进度产出基线登记（Rule 111）」+交付前「防倒退终检（Rule 111/106.8）」触发点 ②`skills/task-planner/scripts/init-session.sh:1049` `[init] 📦 提醒：计划期登记进度产出基线（Rule 111）` ③`skills/task-planner/scripts/check-complete.sh:677-681` `[anti-regress]` warn（含 `🛡 防倒退终检` 且无 `净效果` 判定时 stderr 警告，非阻断）④`skills/task-planner/scripts/selftest-antiregress.sh` 新建 AR-01..AR-09（9 PASS）⑤`skills/task-planner/scripts/selftest-registry.tsv:102` 登记行 ⑥3 variant 轻量指针 `templates/variant/rule-enhancement-type.md:5`、`bugfix-type.md:159`、`refactor-type.md:157`。
- 验收：5/5 PASS — [1:PASS VC-05 grep 面全命中 2/3/1/3/1/1/1  2:PASS selftest-antiregress Total:9 PASS=9 FAIL=0 rc=0 + registry 登记  3:PASS run-selftests Total:101 PASS=93 FAIL=8，Failed 集==基线 8 零新增  4:PASS S3 改动 8 文件 51 insertions/0 deletions，S2 产物未再改，相关 selftest-interaction/template-lifecycle/template-sense/knowledge-brief rc=0  5:PASS 103.2 自审入 checkpoint]。
- 证据锚：`bash scripts/selftest-antiregress.sh`→`Total: 9 PASS=9 FAIL=0`；`bash scripts/run-selftests.sh`→`Total: 101 PASS=93 FAIL=8` Failed={active-plan,batch-pilot,enumerate-first,execution-stability,registry,rule-reserve-pairing,self-resolution,summary-readability}；`git diff --numstat`(S3 7 文件 +1..+5) + untracked selftest-antiregress.sh(101 行)；VC-05 grep 命中 `SKILL.md` 2、`task_plan.md` 3、`init-session.sh` 1、`check-complete.sh` 3、各 variant 1。
- 备注：全量中 `selftest-registry (rc=1)` 为预存 T03 孤儿行 `selftest-md-edit-ops.sh`（registry 102 行 vs 实际 101 脚本），属于基线 8 FAIL 集，非本 S-unit 引入；本次追加的 registry 行脚本存在且自测通过。
- checkpoint：`/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/subagent-state/04-s3-wiring.md` (status: done)

#### [sub:05-s4] variant lineage/spec_version 批量注入（2026-11-20，worktree 实施，返工#1 后完成）
- 产出：①`skills/plan-template-kit/scripts/inject-template-lineage.sh`(165L,+x,幂等,`--dry-run`/`--with-base`；按 base `##` 标题序计算 pruned；返工#1 修复 placement=首个 H1 行后插入，base 额外置于 H1 后紧随的 `<!-- 渲染契约... -->` 注释行之后) ②29 个 variant lineage 头注入到各自 H1 后（mini-lite-type.md,l0-lite-type.md 豁免未注入，理由=轻量档豁免仪式区块先例/brief§0）③base `skills/task-planner/templates/task_plan.md` lineage 位于 `:3`（`:1` H1, `:2` 渲染契约）④kit `skills/plan-template-kit/SKILL.md:8` 加 `> 模板规范版本: spec_version=1...`。
- 验收：1) VC-13 PASS：base lineage 命中且 `grep -rl template-lineage skills/task-planner/templates/variant|wc -l`=29  2) VC-15 PASS：`check-template-type.sh` 逐 variant 循环 OK=31 FAIL=0 (`/tmp/s4-rework-check-template-type.log`)  3) VC-11 PASS：`task_plan.md:3` / `SKILL.md:8` spec_version 命中  4) PASS：`selftest-plan-tier.sh` Total:32 PASS=32 FAIL=0 PT-26 PASS (`/tmp/s4-rework-plan-tier.log`)；`selftest-template-lifecycle.sh` 24/24 rc=0；`selftest-antiregress.sh` 9/9 rc=0；全量 `run-selftests.sh` Total:101 PASS=93 FAIL=8, Failed={active-plan,batch-pilot,enumerate-first,execution-stability,registry,rule-reserve-pairing,self-resolution,summary-readability} ==基线8集零新增 (`/tmp/s4-rework-run-selftests.log`)  5) PASS：103.2 自审+3样本抽检(大/中/小 longform-continuity/writing/bugfix，pruned 32/23/16 全 MATCH)入 checkpoint。
- 幂等：`--with-base` rerun→insert=0 replace=0 unchanged=29 skip-exempt=2, BASE/KIT unchanged。
- Batch Report: total=31(success_injected=29,exempt=2) | success=29 | failed=0 | failure_rate=0% | pre_check=Q1:可脚本化=是(注入器)/Q2:回滚点=`git checkout -- skills/task-planner/templates/variant skills/task-planner/templates/task_plan.md skills/plan-template-kit/SKILL.md && rm -rf skills/plan-template-kit/scripts`(worktree commit 15fc6c5 干净基线)/Q3:幂等可重跑=能 | sampled_pass=3(longform-continuity-type.md,writing-type.md,bugfix-type.md; pruned 与 heading 差集逐一核对 MATCH) | sampled_fail=0 | rollback_point=commit 15fc6c5 + 上述 git checkout/rm 命令
- 证据锚：`skills/task-planner/templates/task_plan.md:1` H1/`:2` 渲染契约/`:3` base lineage；`skills/plan-template-kit/SKILL.md:8` spec_version；`grep -rl template-lineage skills/task-planner/templates/variant|wc -l`→29；`/tmp/s4-rework-plan-tier.log` PT-26 PASS；`/tmp/s4-rework-check-template-type.log` OK=31；`/tmp/s4-rework-template-lifecycle.log` 24/24；`/tmp/s4-rework-antiregress.log` 9/9；`/tmp/s4-rework-run-selftests.log` 101 PASS=93 FAIL=8；checkpoint `subagent-state/05-s4-inject.md` (done)。

#### [sub:06-s5] 原则→模板区块注册表 + 覆盖守卫 + 派生铁律（2026-11-20，worktree 实施完成）
- 产出：①`skills/plan-template-kit/references/principle-template-registry.md`(47L, spec_version=1)：原则→模板区块映射表（含防倒退/规范基线/用户需求原文/根源覆盖/Goal 单元/验证契约/FMEA/证据锚/指令理解迭代/lineage 派生治理，注明 base 必选、derived 载体口径、mini-lite/l0-lite 豁免、守卫断言）+ 备注与 warn/enforce 分层口径（base+lineage enforce，derived 原则面与防倒退指针 warn 逐步补齐；指令理解迭代 base 在途豁免“在途：主仓未提交改动簇，合并后对齐”）+ §派生铁律（派生登记/base+parent 双参照铁律/二级派生裁剪=父级∪新增逐级对齐 base/核心不可静默丢失/新原则落地同步）+ 机器可读 `registry-assertions` 块。②`skills/task-planner/scripts/check-template-principles.sh`(284L,+x)：读 registry 断言，对 base+29 derived(排除 mini-lite/l0-lite)校验；base enforce(防倒退双区块/规范基线/用户需求原文/根源覆盖/Goal 单元/验证契约/FMEA/证据锚+level=base)与 derived lineage enforce，derived 原则区块及防倒退指针 warn 计数不计 FAIL；支持 `<!-- principle-exempt: ... -->`；`--selftest-smoke` 内置正反夹具(全齐 PASS/缺块 FAIL)临时目录自验并清理；实跑输出 `PRINCIPLES-COVERAGE PASS` exit 0。③`skills/plan-template-kit/SKILL.md:8-10`：追加注册表路径指针与派生铁律句（含“双参照”关键词，满足 VC-14）。④`skills/task-planner/scripts/selftest-template-principles.sh`(91L,+x, TP-01..TP-07)+`selftest-registry.tsv:103` 登记。
- 验收：5/5 PASS — [1:PASS VC-06 `grep -c 防倒退/验证/证据/理解迭代 principle-template-registry.md`→3/2/4/4  2:PASS VC-07 `bash skills/task-planner/scripts/check-template-principles.sh --selftest-smoke`→`SELFTEST-SMOKE PASS rc=0`(all-ok/missing-block 夹具)  3:PASS VC-14 `grep -rn "双参照|二级派生" skills/plan-template-kit/ skills/task-planner/references/ skills/task-discipline/references/`→`skills/plan-template-kit/SKILL.md:10`,`principle-template-registry.md:28,31`  4:PASS 守卫实跑 base+29 derived enforce 全绿 `summary: fail=0 warn=145 PRINCIPLES-COVERAGE PASS rc=0`(/tmp/s5-principles-guard-final.log)  5:PASS 新 selftest `Total: 7 PASS=7 FAIL=0 rc=0` + registry:103；全量 `run-selftests.sh|tee /tmp/s5-run-selftests.log`→`Total: 102 PASS=94 FAIL=8` Failed={selftest-active-plan,selftest-batch-pilot,selftest-enumerate-first,selftest-execution-stability,selftest-registry,selftest-rule-reserve-pairing,selftest-self-resolution,selftest-summary-readability}==基线8集零新增，含 `selftest-template-principles (rc=0 PASS=7 FAIL=0)`]。
- 103.2 自审：覆盖 VC-06/07/14/实跑/新自测+registry/全量 FAIL 集比对；禁改面遵守（未改三份 rules、主模板、variant、P1-S4 既有产物；仅 M kit SKILL.md + selftest-registry.tsv，新增 registry/guard/selftest 3 文件）；主仓 18 个未提交在途文件未触碰；证据均为 file:line 或命令→输出行。
- 证据锚：`skills/plan-template-kit/references/principle-template-registry.md:1,8,28,31,38`；`skills/task-planner/scripts/check-template-principles.sh:1,172,281`；`skills/task-planner/scripts/selftest-template-principles.sh:1,90`；`skills/plan-template-kit/SKILL.md:8,10`；`skills/task-planner/scripts/selftest-registry.tsv:103`；`/tmp/s5-principles-guard-final.log`；`/tmp/s5-run-selftests.log`；checkpoint `subagent-state/06-s5-registry.md` (done)。

#### [sub:07-s6] R4 spec_version retrofit 扫描/改造 SOP 机制化（2026-11-20，worktree 实施完成）
- 产出：①`skills/plan-template-kit/scripts/scan-template-spec.sh`(128L,+x)：解析 kit `SKILL.md` 当前规范版本 `spec_version=<N>` 为权威源，扫描 base+31 variant lineage 头（mini-lite/l0-lite 豁免 SKIPPED-EXEMPT，根部辅助模板豁免），输出 `CURRENT-SPEC`/逐模板 `<file> spec_version=<v> OK|OUTDATED|MISSING|SKIPPED-EXEMPT`/`OUTDATED: <count>`；支持 `--target-spec <N>`（>当前 N 则全量列 OUTDATED=升级模拟）；退出码 OUTDATED=0→rc 0，存在 OUTDATED/MISSING→rc 1。②`skills/plan-template-kit/references/retrofit-sop.md`(18L,≤60)：六步流程（kit递增→注册表修订→scan清单→逐模板改造→守卫复验→登记）+ 机制化来源 `task-variant-upgrade-20261113` 判例 + 版本历史表首行 `1|2026-11-20|初版（lineage+原则注册表+守卫）|task-antiregress-tplgov-20261120`。③`skills/plan-template-kit/SKILL.md:11` 追加 retrofit SOP 指针行（含 `retrofit` 与 `spec_version` 关键词），既有 spec_version=1(:8)/派生铁律(:10) 零改动（git diff 仅 +1 行）。④`skills/task-planner/scripts/selftest-template-retrofit.sh`(116L,+x, TR-01..TR-08)+`selftest-registry.tsv:104` 登记。
- 验收：5/5 PASS — [1:PASS VC-12 `bash skills/plan-template-kit/scripts/scan-template-spec.sh --target-spec 1`→`CURRENT-SPEC: 1`/`OUTDATED: 0` rc=0（含 spec_version）；`--target-spec 2`→`OUTDATED: 44` rc=1  2:PASS SOP 六步+`task-variant-upgrade-20261113` 判例+版本历史表在位(`retrofit-sop.md:1,5,7,16,18`)  3:PASS kit 指针行在位且既有行零改动(`SKILL.md:8,10,11`; `git diff -U1 -- skills/plan-template-kit/SKILL.md` 仅 +retrofit 行)  4:PASS 新 selftest `selftest-template-retrofit.sh`→`Total: 8 PASS=8 FAIL=0 rc=0` + registry:104；全量 `run-selftests.sh`→`Total: 103 PASS=95 FAIL=8` Failed={selftest-active-plan,selftest-batch-pilot,selftest-enumerate-first,selftest-execution-stability,selftest-registry,selftest-rule-reserve-pairing,selftest-self-resolution,selftest-summary-readability}==基线8集零新增(/tmp/s6-run-selftests.log)  5:PASS 103.2 自审入 checkpoint]。
- 103.2 自审：交付物逐项对照 brief §1/§2；VC-12 行为级证据、SOP 行数/锚点、kit diff 仅增行、新 selftest+registry、全量 FAIL 集同基线 8 零新增；禁改面遵守（未改三份 rules/主模板/variant/既有脚本/注册表/守卫/注入器，未触主仓 18 在途）；证据均为 file:line 或 命令→输出行。
- 证据锚：`skills/plan-template-kit/scripts/scan-template-spec.sh:1,34,60,123`；`skills/plan-template-kit/references/retrofit-sop.md:1,5,7,16,18`；`skills/plan-template-kit/SKILL.md:8,10,11`；`skills/task-planner/scripts/selftest-template-retrofit.sh:1,115`；`skills/task-planner/scripts/selftest-registry.tsv:104`；`/tmp/s6-run-selftests.log`；checkpoint `subagent-state/07-s6-retrofit.md` (done)。

#### [sub:08-s7] 主动加载强化：general 兜底须登记理由（R3 wiring，2026-11-19T22:09Z，worktree 实施完成）
- 产出：①`skills/task-planner/scripts/init-session.sh:924,958` 在 template-sense general 空缺/unknown 两分支 emit 处追加 `[init] ⚠ general 兜底须登记理由（R3，2026-11-20 task-antiregress-tplgov-20261120）：计划期在 task_plan.md「🔁 模板感知」区块写明为何无适配 variant（数据依据=plans/ 类型分布），终验 check-complete 必查`（既有 `[template-sense]` 行与区块追加逻辑零改）。②`skills/task-planner/scripts/check-complete.sh:677-682` 在 T3 模板感知 warn 后追加 R3 warn：命中“🔁 模板感知”+`template_type: general`/注释形态且全文无“登记理由”→stderr `[template-sense] ⚠ general 兜底须登记理由（R3）...`，不做硬门。③`skills/plan-template-advisor/SKILL.md:53`「边界铁律」段首追加 `> general 兜底非静默默认：选用 general 须在计划「🔁 模板感知」区块登记理由（为何无适配 variant + 数据依据），终验对照（R3，2026-11-20）`。
- 验收：4/4 PASS — [1:PASS VC-08 `grep -n "登记理由"` 三文件各≥1→init-session.sh:924,958 / check-complete.sh:677,680,681 / plan-template-advisor/SKILL.md:53  2:PASS `bash skills/task-planner/scripts/selftest-template-sense.sh`→`Total: 8 PASS=8 FAIL=0 RC=0`；`git diff -U0 -- <3files>` 无删除行  3:PASS 改动面 3 文件 +10/-0（numstat 2/0,6/0,2/0）  4:PASS 103.2 自审入 checkpoint]。
- 103.2：按材料包 §2 四条逐项对照并落证据锚，禁改面遵守（未改既有 selftest、未触其他文件）。
- 证据锚：`grep -n "登记理由" skills/task-planner/scripts/init-session.sh skills/task-planner/scripts/check-complete.sh skills/plan-template-advisor/SKILL.md`；`git diff --numstat -- skills/task-planner/scripts/init-session.sh skills/task-planner/scripts/check-complete.sh skills/plan-template-advisor/SKILL.md`→`2 0`/`6 0`/`2 0`；`bash skills/task-planner/scripts/selftest-template-sense.sh`→`Total: 8 PASS=8 FAIL=0` `RC=0`；checkpoint `subagent-state/08-s7-wiring.md` (done)。
