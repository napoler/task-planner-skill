# 22-code-runner-agent Checkpoint — task-v166 fix 后全量回归（round 3）+ 12 条闭合验收
# T1 里程碑: 2026-10-11 12:06 CST — 76 脚本全量回归完成 + 夹具三组实证完成 + main HEAD 基线对照完成（写盘即 T5 收口）

## 0. 范围与环境（Precheck）
- worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability（只读跑批；未 cd、未切 CWD，全部绝对路径）
- 未修改任何仓内文件；未执行 git 写操作；夹具/日志仅 /tmp/fx166/** 与 /tmp/regression-r3.log
- 危险命令=0；glob 先计数 selftest-*.sh=76；依赖 bash/grep/awk 可用
- 执行命令: for f in <worktree>/skills/task-planner/scripts/selftest-*.sh; do echo "=== SCRIPT: $f ==="; bash "$f" 2>&1; echo "RC=$?"; done > /tmp/regression-r3.log
- 环境说明: 全部脚本在 bash "$f" 子进程内实跑（系统 grep，与生产运行态一致）

## 1. 全量回归逐脚本 Total 原文（76/76 全列，禁自报汇总）
- selftest-absorption-discipline.sh → Total: 14 pass, 0 fail, 0 skip
- selftest-active-plan.sh → Total: 29 PASS=29 FAIL=0
- selftest-agent-coverage.sh → Total: 9 PASS=9 FAIL=0 SKIPPED=0
- selftest-ask-default-timeout.sh → Total: 11 PASS=11 FAIL=0
- selftest-batch-pilot.sh → Total: 10 PASS=10 FAIL=0
- selftest-capability-persistence.sh → Total: 20 PASS=20 FAIL=0
- selftest-check-conflicts.sh → Total: 7 PASS=7 FAIL=0
- selftest-check-drift.sh → Total: 6 PASS=6 FAIL=0
- selftest-conclusion-discipline.sh → Total: 24 PASS=24 FAIL=0
- selftest-context-hygiene.sh → Total: 12 PASS=12 FAIL=0
- selftest-context-pressure.sh → Total: 9 PASS=9 FAIL=0
- selftest-decision-arbiter.sh → Total: 16 PASS=16 FAIL=0
- selftest-decision-drift.sh → Total: 23 PASS=23 FAIL=0
- selftest-decision-grading.sh → Total: PASS=12 FAIL=0 WARN=0
- selftest-delegation.sh → Total: 38    PASS=38  FAIL=0
- selftest-dispatch-grain.sh → Total: 10 PASS=10 FAIL=0
- selftest-dispatch.sh → Total: 31 PASS=31 FAIL=0
- selftest-drift-check-subagent.sh → Total: 20 PASS=19 FAIL=1
- selftest-drift-enforcement.sh → Total: 23 PASS=23 FAIL=0
- selftest-error-fix-prompt-forge.sh → Total: 8 PASS=8 FAIL=0
- selftest-error-loop.sh → Total: 16 PASS=16 FAIL=0
- selftest-evidence-goal-gate.sh → Total: 21 PASS=21 FAIL=0
- selftest-execution-honesty.sh → Total: 14 PASS=13 FAIL=1
- selftest-execution-stability.sh → Total: 19  PASS=19  FAIL=0
- selftest-fallback.sh → Total: 31  PASS=31  FAIL=0
- selftest-fine-grain-steps.sh → Total: 11 PASS=11 FAIL=0
- selftest-four-file-dataflow.sh → Total: 18 PASS=18 FAIL=0
- selftest-goal-unit-goal-mode.sh → Total: 9 PASS=9 FAIL=0
- selftest-interaction.sh → Total: 11 PASS=11 FAIL=0
- selftest-iteration-persistence.sh → Total: 18 PASS=18 FAIL=0
- selftest-iterative-optimizer.sh → Total: 8 PASS=8 FAIL=0
- selftest-knowledge-brief.sh → Total: 16  PASS=16  FAIL=0
- selftest-lane-advancement.sh → Total: 14 PASS=14 FAIL=0
- selftest-mechanism-profile.sh → Total: 19 PASS=19 FAIL=0
- selftest-media-agents.sh → Total: 10 PASS=10 FAIL=0
- selftest-media-dispatch.sh → Total: 9 PASS=9 FAIL=0
- selftest-methodology.sh → Total: 16 PASS=16 FAIL=0
- selftest-parallel-scheduling.sh → Total: 9 PASS=9 FAIL=0
- selftest-periodic-review.sh → Total: 10 PASS=10 FAIL=0
- selftest-plan-dispatch.sh → Total: 12 PASS=12 FAIL=0
- selftest-plan-tier.sh → Total: 32 PASS=32 FAIL=0
- selftest-pointer-lifecycle.sh → Total: 10 PASS=10 FAIL=0
- selftest-reflect-verify.sh → Total: 12 PASS=12 FAIL=0
- selftest-registry.sh → Total: 5 PASS=5 FAIL=0 (registry rows=76, actual selftest=76)
- selftest-reliability-institution.sh → Total: 16 PASS=16 FAIL=0
- selftest-report-reviewability.sh → Total: PASS=13 FAIL=0 WARN=0
- selftest-requirement-coverage.sh → Total: 23 PASS=23 FAIL=0
- selftest-requirement-grading.sh → Total: 7 PASS=7 FAIL=0
- selftest-rescue-chain.sh → Total: 11 PASS=11 FAIL=0
- selftest-research-first.sh → Total: 12 PASS=11 FAIL=1
- selftest-review-library.sh → Total: 15 PASS=15 FAIL=0
- selftest-root-resolution.sh → Total: 17 PASS=16 FAIL=1
- selftest-rule23-conflict-scan.sh → Total: 3 PASS=3 FAIL=0
- selftest-rule-reserve.sh → Total: 10 PASS=10 FAIL=0
- selftest-self-resolution.sh → Total: 13 PASS=12 FAIL=1
- selftest-shared-tracker.sh → Total: 11 PASS=11 FAIL=0
- selftest-skill-collab.sh → Total: 25  PASS=25  FAIL=0
- selftest-skill-modify.sh → Total: 9 PASS=9 FAIL=0 (SKIP=0)
- selftest-skill-split.sh → Total: 41  PASS=41  FAIL=0
- selftest-smart-merge.sh → Total: 18 PASS=18 FAIL=0
- selftest-source-anchor-discipline.sh → Total: 12 pass, 0 fail
- selftest-split-pattern-library.sh → Total: 13 PASS=13 FAIL=0
- selftest-subagent-granularity-skill-escort.sh → Total: 23 PASS=23 FAIL=0
- selftest-subagent-return.sh → Total: 11 PASS=11 FAIL=0
- selftest-summary-readability.sh → Total: PASS=12 FAIL=1 WARN=0
- selftest-sync-index.sh → Total: 13 PASS=13 FAIL=0
- selftest-task-boundary.sh → Total: 11 PASS=11 FAIL=0
- selftest-template-lifecycle.sh → Total: 24 PASS=24 FAIL=0
- selftest-template-sense.sh → Total: 8 PASS=8 FAIL=0
- selftest-tier-b.sh → Total: 18 PASS=18 FAIL=0
- selftest-tool-selection.sh → Total: 12 PASS=12 FAIL=0
- selftest-vc-gate.sh → Total: 11 PASS=11 FAIL=0
- selftest-veto.sh → Total: 13 PASS=13 FAIL=0
- selftest-workflow-orchestration.sh → Total: 16 PASS=16 FAIL=0
- selftest-final-gate-hash.sh → （无 Total: 行，特殊格式）==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ==== ｜ RC=0
- selftest-user-instruction-priority.sh → （无 Total: 行，特殊格式）=== ALL PASS === ｜ RC=0

### FAIL 明细（6 脚本红；其余 70 脚本 RC=0 全绿）
1. selftest-drift-check-subagent.sh — Total: 20 PASS=19 FAIL=1 ｜ DCS-11 FAIL DCS-11 条件缺失（需 40-(69|71|73|74) 全集（±+NN 形态） + Rule 61 偏移检查子代理化 + Rule 61 摘要 bullet）
2. selftest-execution-honesty.sh — Total: 14 PASS=13 FAIL=1 ｜ EH-09 FAIL SKILL.md Rule 54=3（应 ≥1）或 C38=1（应 =1）或「Rule 40-(5[3-9]|6[0-9]|7[0-4])」=0（应 ≥1，级联漏改）
3. selftest-research-first.sh — Total: 12 PASS=11 FAIL=1 ｜ RF-07 FAIL SKILL 双锚(bullet 全角括号+头注 1-NN(+N) 全集宽容锚) (got=(1,0) expect=(>=1,>=1))
4. selftest-root-resolution.sh — Total: 17 PASS=16 FAIL=1 ｜ RR-16 FAIL SKILL.md 索引行命中=1（应 =1）或索引行未含「Rule 40-(5[3-9]|6[0-9]|7[0-4])」（亦未同时含 50 与 53——级联漏改，CR P1-2 复发）
5. selftest-self-resolution.sh — Total: 13 PASS=12 FAIL=1 ｜ SR-08 FAIL Rule 40/41 共存锚损伤（含 Rule 40-(5[3-9]|6[0-9]|7[0-4]) 缺失或 ^40\. 子条数 ≠6）
6. selftest-summary-readability.sh — Total: PASS=12 FAIL=1 ｜ SRV-12 FAIL: 9 级联脚本(pass=6 fail=3 expect 9/9)（红=RF/RR/SR 三脚本）

### 基线对照与归因（决定性证据）
- main repo HEAD af321a3 同 5 脚本实跑全绿: drift-check-subagent 20/20・execution-honesty 14/14・research-first 12/12・root-resolution 17/17・self-resolution 13/13
- ⇒ 6 FAIL 系 worktree 内 v166 改动引入，非环境存量
- 断点=21d T2（SKILL.md:307『40-74』→『40-76』，全 diff 唯一触及该串的改动；21b checkpoint 11:19 自跑 13/13 含 SRV-12 9/9 时尚全绿）
- 5 锚原文: research-first.sh:77（cntE 'Critical Rules 1-[0-9]+(\+[0-9]+)?（含 Rule 40-(65|69|71|74) 全集'）・self-resolution.sh:94／execution-honesty.sh:98／root-resolution.sh:181（'含·Rule 40-(5[3-9]|6[0-9]|7[0-4])'）・drift-check-subagent.sh:63（'Rule 40-(69|71|73|74)(\+[0-9]+)? 全集'）
- 修复建议（下轮）: 5 锚上界扩至 76（如 40-(…|7[0-9]) 或并集补 76，同 context-pressure '1-(69|71|7[4-9])' 范式）→ SRV-12 自愈、summary-readability 回 13/13

## 2. 12 条闭合验收表（S19 5 条 + S20 7 条，逐条实测）
| 编号 | 问题锚 | 本轮实测证据 | 判定 |
|------|--------|--------------|------|
| S19 F-1 | SRV-07 未锚表头（:100-102） | 现 :106-109 先定位「## 3. 审查清单」标题、再取其后首个表格行、三列只查表头行；夹具 /tmp/fx166/skill-f1（删 §3 表数据行留标题）→『SRV-07 FAIL … got fn=0 path=0 desc=0』rc=1；真身 run SRV-07 PASS | closed |
| S19 F-2 | SRV-08/09/13 BRE 死守卫（:110,118,167） | :53 新增 cntE（grep -cE）；:117/:125/:174 三处改 ERE；夹具 /tmp/fx166/skill-f2（注入「### Phase 1: ① 旧式装饰标题」）→ SRV-08 FAIL(got 1) + SRV-13 FAIL(got 1)，rc=1；同夹具 BRE-old=0 vs ERE-new=1（死/活决定对比） | closed |
| S19 F-3 | 头注与实现脱节（:25） | 头注 :4-21 现为 SRV-01..13 全实现清单（含 SRV-07 表头描述与负断言描述）；grep '骨架|预留'=0 | closed |
| S19 F-4 | rl_circ 未使用（~:1017） | grep rl_circ=仅 :1029 注释「已删」留痕；:1031 现文 `local vf rl_ph_n`；复用经注释说明（判读：删除落地；重命名建议以复用注释替代——⑦在⑤之后执行、覆盖赋值无交叉，语义安全；微观察：注释内行号引用 :1012 实际为 :1016） | closed |
| S19 F-5 | registry 行数簿记 | wc -l=77（表头+76 数据行）；selftest-registry.sh 动态『rows=76, actual selftest=76』PASS；新脚本登记行 :77 四列；SR-12『总行数 77=脚本数+表头（动态）』PASS | closed |
| S20 P0 | report-lint 检查②锚漂移（:972/975） | :976/:979 现正则 `(5\.|6\.|五、|六、)` 双形态；夹具 direct 实跑 check-complete.sh /tmp/fx166/fxplan/task_plan.md 三连：A「## 6. 缺三要素」warn=1 ／ B「## 5.」warn=1 ／ C「## 6. 含看点+动作」warn=0 | closed |
| S20 P1-a | 67.6 叙述 1-74（:885） | :885 含「[2026-10-11 task-v166 级联演进] 全集 1-74→1-76，CP-07 锚族扩为 1-(69|71|7[4-9])」 | closed |
| S20 P1-b | 71.7 叙述 1-74（:954） | :954 含「[2026-10-11 task-v166 级联演进] 全集再演进 1-74→1-76」 | closed |
| S20 P1-c | 74.6 ④ 叙述（:1005） | :1005 现「Rules 全集演进至 1-76+合规清单 C51/C54」 | closed |
| S20 P2-a | image-type:21 圈号 | :21 现为「…／合规检（…）／一致性检（…）／质量检（…）」顿号列举；该行 ①②③ 命中=0 | closed |
| S20 P2-b | variant 头注释豁免登记 | 未寻得登记：worktree diff 无豁免新增行；21a/21b/21c/21d 无该处置；progress/knowledge-brief/verification 无条目（verification 仅模板复选框空置）；两模板 :4 注释维持原状；76.1 范围外字面仅「脚本内部步骤枚举注释」 | NOT-CLOSED（登记缺位；pre-existing/不渲染/不阻断判断仅存于 S20 建议） |
| S20 P2-c | SKILL.md 40-74→40-76（:305→:307） | :307『含 Rule 40-76 全集』=1、『40-74 全集』=0 —— 本体 closed；但该改动触发 5 锚级联 FAIL（见 §3 N-1） | closed(本体)+级联副作用 |

## 3. 新发现问题（12 条清单外，全量回归揭示）
- N-1: 5 锚级联 FAIL（DCS-11/EH-09/RF-07/RR-16/SR-08，锚上界 74 未随 76 扩）→ SRV-12 级联 → 6 脚本红；归因 21d T2；main HEAD 对照全绿证明非存量
- N-2: 12 条修复本体未引入额外红——summary-readability 自身 SRV-01..11+13 全 PASS，唯一红=SRV-12 级联
- N-3: 微观察：F-4 注释行号引用 :1012 vs 实际 :1016（不影响语义）

## 4. 复现命令
- 全量回归: for f in <WT>/skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done > /tmp/regression-r3.log
- F-1: bash /tmp/fx166/skill-f1/scripts/selftest-summary-readability.sh → rc=1
- F-2: bash /tmp/fx166/skill-f2/scripts/selftest-summary-readability.sh → rc=1
- P0: bash <WT>/scripts/check-complete.sh /tmp/fx166/fxplan/task_plan.md（夹具三态依次替换 delivery-summary.md）

## T5 最终结论（= 返回格式 8 字段块）
```
status: partial
acceptance: 2/3 pass — [1:PASS(76 脚本逐行 Total 原文+FAIL 明细在档) 2:PASS(闭合表 12 条全覆盖,每条带实测证据) 3:FAIL(非全部 closed: P2-b 登记缺位 + 6 脚本级联 FAIL)]
files: none
evidence: 回归70/76全绿,6 FAIL=(drift-check-subagent,DCS-11)(execution-honesty,EH-09)(research-first,RF-07)(root-resolution,RR-16)(self-resolution,SR-08)(summary-readability,SRV-12级联6/9); main HEAD对照5/5绿; F-1夹具skill-f1→SRV-07 FAIL fn=0 rc=1; F-2夹具skill-f2→SRV-08/13 FAIL got=1, BRE=0/ERE=1; P0夹具A=1/B=1/C=0; P1 :885/:954/:1005注在档; P2-a :21圈号=0; P2-c :307 40-76=1/40-74=0; P2-b登记缺位
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/22-code-runner-agent.md (status: done)
findings_written: none
blockers: 21d T2『40-74→40-76』触发5旧容差锚级联FAIL(6脚本红)+P2-b豁免登记缺位,需修复后复跑全量
confidence: HIGH
```
