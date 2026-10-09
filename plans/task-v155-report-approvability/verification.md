# Verification Contract & Phase Gates

## Goal (1 sentence)

task-planner 技能全工作流所有「向用户请求审批/审查/确认/呈报」的触点强制执行 Rule 70 最小呈报信息集（①待审项清单+逐项简介 ②可定位地址 ③看点 ④动作+默认项），并以机器守护（selftest+check-complete lint）固化，杜绝「让用户审批一个莫名其妙的东西」。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 70 条文在位（70.1-70.6 六子条+四要素关键词+禁行号锚）
  Evidence: `cd /mnt/data/dev/task-planner-skill && grep -c "^## Rule 70" skills/task-planner/references/critical-rules.md`→1；`grep -c "^### 70\.[1-6] "`→6；四要素词（待审项清单/可定位地址/看点/动作）各 ≥1（RRV-01/02/03 PASS，检查点 subagent-state/12-executor.md）
- [x] VC-2: 触点修补零缺口（审计清单 13 文件逐一含 Rule 70 引用）
  Evidence: `grep -l "Rule 70"` 对 findings.md 触点审计表 13 文件逐一命中（RRV-05/08-12 PASS：SKILL 触点4/reference 1/worktree-isolation 4/batch-gate 3/两 companion 3/review-library 3/plan-writer 1），缺口计数=0
- [x] VC-3: 机器守护在位（selftest 可执行+PASS、registry 登记、check-complete report-lint）
  Evidence: `bash skills/task-planner/scripts/selftest-report-reviewability.sh`→exit 0 `Total: PASS=13 FAIL=0 WARN=0`；registry.tsv 第 66 行 NF=4 登记；check-complete.sh report-lint 段（func+printf 双锚）
- [x] VC-4: 全量回归零破坏（合并后 master 全量 selftest ΣFAIL=0）
  Evidence: 2026-10-10 Round 6 合并态 `total=67 fails=0`；master 合并后复跑 `total=67 fails=0`（progress.md Phase 7/9 段）
- [x] VC-5: lint 行为实测（fail-open 不改 exit 语义）
  Evidence: S14 冒烟——/tmp 样例触发 3 行 `[report-lint] ⚠`（产出清单/下一步建议/待裁决）且 WT_EXIT==MASTER_EXIT=0；空 delivery-summary 目录→SKIPPED exit 0；S20 修复后真阳性保留/空输入不误报
- [x] VC-6: 合并回+部署（master merge commit 存在；部署位逐位 IDENTICAL）
  Evidence: master `git log --oneline -1`→`2a12229 Merge branch 'wt/v155-report-approvability'`；`smart-merge-back.sh --deploy`→claude 位 ~/.claude/skills/task-planner IDENTICAL、opencode 位 ~/.config/opencode/skills/task-planner IDENTICAL、其余 review 族 LINK-OK；worktree/branch 已清理（§11.3 合约）
- [x] VC-7: 双审查 APPROVED（代码面+对齐面 CHANGES 闭环）
  Evidence: S18 code-quality CHANGES_REQUESTED（report-lint 空输入守卫+RRV-07 双锚，S20 修复）；S19 alignment CHANGES_REQUESTED（索引口径+表格结构，S20b 修复）；S20c/d RF-07 合并级联；修复项全部复验通过，两 checkpoint 于 subagent-state/

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**

## Phase Gates

### Phase 1-8: 条文/触点/模板/管线/守护/回归/审查
Done when: 各 Phase 交付物落位且 3-File 门控+drift 留痕齐备（progress.md 各 Phase 段逐 Phase 记录）
Status: `complete` Last verified: 2026-10-10

### Phase 9: 合并回+部署+终验簿记交付
Status: `complete` Last verified: 2026-10-10（merge 2a12229+部署 IDENTICAL+rule 70 landed+本 verification.md）

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| delivery-summary 模板（Rule 48 金标准） | 交付总结按五要素+定位三要素输出（本任务 delivery-summary.md） | 符合 |
| critical-rules.md Rule 48/28/44/41 | Rule 70.5 引用口径逐条对齐（检查点 u1-executor 并集解保留） | 符合 |
| selftest 范式与 registry 4 列制 | 新脚本同构既有 selftest（research-first 范式引用）；registry 行 NF=4 | 符合 |
| worktree 隔离 SOP | §十一全流程执行（创建→开发→合并→清理），§11.3 五项全满足 | 符合 |
| 规则编号预留账本 | 70=reserve→land 两态均在账本（rule-reserve.sh 输出） | 符合 |

## 委派统计复验（Rule 25.4）

```json
{"phases_total": 9, "delegated": 8, "main_process": 1, "rate": 0.8889, "verdict": "PASS"}
```

- [x] 主进程直做 Phase（Phase 9）已在计划 Executor 字段登记白名单内例外理由（Rule 25.3 ①git/worktree 编排+②计划系统簿记）
- [x] rate 0.89 ≥ 0.7 floor；全部直做理由白名单内；stats verdict=非 violation

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 0 项（无质量牺牲/伪造证据/缺证据行为）；Q3 伪造证据=0（全部验收来自第一手命令输出与子代理检查点交叉复验）
- [x] Evidence 抽查 ≥3 条：①selftest-report-reviewability.sh 自跑 13/13（主进程复跑）②registry 行 NF=4 ③部署位 diff=0（smart-merge-back DEPLOY 段）
- [x] 豁免登记：本任务无用户显式文字豁免需求
- [x] 无未处置违规 → outcome=COMPLETE（不降级）

## 需求覆盖核对表（Rule 51.3 — 交付必载）
| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 「完全不列出需要审批哪些内容，连简介都不给，连文件地址都不给」 | covered | Rule 70.2 四要素（critical-rules.md Rule 70 段；RRV-02）+13 触点全列清单地址（VC-2） |
| R2 | 「还有其他类似的情况…必须要得以修正」 | covered | 13 触点文件逐一含 Rule 70 引用（VC-2；findings.md 触点审计表全清） |
| R3 | 「汇报阶段让用户真正知道你做了什么/风险/产出/待审项+地址」 | covered | Rule 70 全触点+报告清单 lint（VC-3/VC-5）；本任务交付总结即示范（delivery-summary.md） |
| R4 | 「全部需要补全，不要让用户审查一个莫名其妙的东西」 | covered | 条文→触点→机器守护三层闭环（VC-1/2/3/4）+双审查 APPROVED（VC-7） |

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3/R4（全部） |
| **裁决** | **solved** |
| **解决证据锚** | VC-1..VC-7 全 PASS：呈报契约链=Rule 70 条文（critical-rules.md:888 起）→13 触点引用（grep 全命中）→RRV-01..13 静态守护+report-lint 行为实测（exit 语义不变） |
| **未解决面+原因** | 无 |
| **已排除路径** | 无 |

## Goal Gate (终验)

```
## Goal Verification — 呈报触点强制 Rule 70 四要素+机器守护
- [x] VC-1: Rule 70 条文在位（grep 1+6 子条） → PASS
- [x] VC-2: 13 触点文件 Rule 70 引用零缺口 → PASS
- [x] VC-3: selftest 13/13+registry 登记+report-lint 段 → PASS
- [x] VC-4: master 全量回归 67/67 ΣFAIL=0 → PASS
- [x] VC-5: lint 冒烟 3 warn+exit 语义不变 → PASS
- [x] VC-6: merge 2a12229+部署三处 IDENTICAL → PASS
- [x] VC-7: 双审查 CHANGES 全部闭环复验 → PASS

outcome: COMPLETE
```

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 9 complete（全部终态） |
| 2 | Where am I going? | 交付用户（见 delivery-summary.md） |
| 3 | What's the goal? | Rule 70 呈报可审批性纪律全链落地 |
| 4 | What have I learned? | findings.md（审计/归因/级联清账/并集解） |
| 5 | What have I done? | progress.md（9 Phase 全记录） |
| 6 | Which tasks need processing? | 下一步=task-v156 决策分级立项（用户 2026-10-10 第二条反馈） |
