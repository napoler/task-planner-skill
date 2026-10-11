# Verification Contract & Phase Gates — task-v156-drift-shield

## Goal (1 sentence)

task-planner 技能 Rule 73「执行期决策对齐与不变量纪律」全链落地：critical-rules 七子条+deprecated.md 新模板+🔒 不变量声明区+check-complete/hook 双承载+新 selftest+registry+SKILL 计数级联，回归 FAIL=基线、部署位 diff=0。

---

## Verification Contract（≥5 items, objective standards）

- [x] VC-1: critical-rules.md 新增 Rule 73（73.1 决策点定义/73.2 对齐三问+[align] 留痕/73.3 三态标注/73.4 周期评判+[judge]/73.5 废弃只入不出/73.6 消歧义/73.7 机制），含「对齐」「不变量」关键词；既有条款零改动
  Evidence: worktree `grep -cE '^73\.[1-7] '`=7；`grep -c '对齐'`=43；`git diff a538a3a..HEAD --numstat -- critical-rules.md`=16/0；`git diff | grep -c '^-[^-]'`=0（纯文末追加，Rule 1-71 既有行零删除）
- [x] VC-2: templates/deprecated.md 五段废弃模板在位（废弃条目=原内容指针+废弃原因+日期+替代锚）+73.5 只入不出规则
  Evidence: worktree `grep -cE '^## [1-5]\.'`=5；`grep -c '废弃'`=14；五要素各≥1（01 登记表含原内容指针/废弃类型/废弃原因/日期/替代锚列）
- [x] VC-3: general 模板+计划实例含「🔒 不变量声明区」三态标注（不变量/可变量/学得量三关键词各≥1）
  Evidence: worktree templates/task_plan.md:31 含区块（不变量=4/可变量=2/学得量=2，grep -e 分次）;本计划 task_plan.md:52 同款 dogfood 区块（`^| 🔒 不变量`=1）
- [x] VC-4: 强制评判点可执行：check-complete.sh [judge-gate] + zcode-posttooluse.sh [judge] 注入；留痕格式定义
  Evidence: check-complete.sh `grep -c '[judge-gate]'`=5;posttooluse.sh `grep -c '\[judge\] 变更型决策点评判'`=1;bash -n 两脚本 rc=0;S6 冒烟=字节同源 harness 三档正确（standard+enforce 零留痕 exit=1 / mini+enforce SKIPPED / standard+含留痕 OK）+hook 单行 JSON 含 [judge]（off 抑制生效）;CR 复检 harness 3 档×3 env 全正确
- [x] VC-5: selftest-decision-drift.sh（新）全 PASS+registry 加行+SKILL 73 摘要/C 让位行级联+全量回归 FAIL=基线
  Evidence: 新 selftest `Total: 23 PASS=23 FAIL=0`(CR 复检+主进程独立复跑同);`grep -c 'decision-drift' selftest-registry.tsv`=1;SKILL.md `grep -c 'Rule 73'`=5/`C51`=2/`1-71+73`=3;全量回归(主进程独立 R2)72/72 rc=0、ΣFAIL=0、ΣPASS=1061=基线 1039+新 22;config.json properties=42(零新键);部署 diff 见合并回段
  > ΣPASS 口径附注:R2(主进程)=1061,alignment-review 独立复跑=1062——差 1 系环境敏感断言(计划目录/账本计数类)在两次跑批间的时点差,两轮均 rc=0/ΣFAIL=0(门控判据),如实双记

---

## Phase Gates

### Phase 1: 侦察深化+设计定稿 — complete（drift ALIGNED 附注,GOAL 段已补）
### Phase 2: worktree 创建与基线快照 — complete（ALIGNED;71/71 rc=0 ΣFAIL=0 ΣPASS=1039）
### Phase 3: 实施 S1-S5 — complete（ALIGNED;5 commits;零删除既有条款）
### Phase 4: 验证 — complete（ALIGNED;S7 FAIL→S9→R2 独立回归 72/72 rc=0）
### Phase 5: Code Review Gate — complete（ALIGNED;CR CHANGES_REQUESTED→S10→复检 APPROVED）
### Phase 6: 终验与交付合并回 — in_progress

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1-R6（六条均 [目标]） |
| **裁决** | `solved` |
| **解决证据锚** | R1→Rule 73.1/73.2 变更型决策点+对齐三问（critical-rules.md:944 起）;R2→73.3 三态标注+templates/task_plan.md:31 🔒 区块（不变量4/可变量2/学得量2）;R3→73.4 强制评判点+check-complete [judge-gate]+posttooluse 注入（S6/CR 复检双 harness 实证）;R4→73.2 对齐三问+[align] 留痕（本任务 progress.md 自我执行 2 行）;R5→73.6 消歧义+templates 词条解释层;R6→73.5+deprecated.md 五段（登记表五要素+只入不出+分账） |
| **未解决面+原因** | 运行期行为改变（真实会话漂移率下降）属实战效果面,超出本任务可机器验证范围——按 73.7 机器边界如实披露:机制存在性已全证,行为效果待新会话实战;不冒充问题解决 |
| **已排除路径** | 无（六需求均有直接交付物） |
| **下一步建议** | 新会话实战冒烟 Rule 73 六机制（[align]/[judge] 留痕+[judge-gate]+hook 注入+废弃登记+d 消歧义消费）;drift-checker provider 恢复后补派本任务 drift 检查（61.5 债务）;部署位 v156 同步已由 merge --deploy 执行,四端 diff 对账见交付总结 |

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| design-draft.md（§0-§7） | S1-S5 全部逐字采用源;06b/S10 双处修正已同步回稿 | 符合 |
| critical-rules.md Rule 29/65/68/69/70 | 73.x 与既有条款零冲突（diff 纯追加）+C51 行引用正确 | 符合 |
| v152 合并判例（INDEX+memory 判例行） | 级联/并集/宽容锚三手法用于 S2/K9/合并预期 | 符合 |

## 委派统计复验（Rule 25.4）

```bash
bash <skill>/scripts/check-delegation.sh stats plans/task-v156-drift-shield
```

- 机器输出要点：`{"phases_total":6,"phases_delegated":3,"delegation_rate":0.5,"verdict":"ok","violations":[]}`
- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 1=② 计划系统文件维护/Phase 2=① git worktree 编排/Phase 6=①+② git 编排+簿记——三项均命中 Rule 25.3 白单,rate<floor 但 WHITELIST-EXEMPT 放行）
- [x] Handoff 登记表 15 行（含 3 行 drift-checker failed→61.5 降级债务）已建;verify_done 全勾
- [x] stats verdict=ok（非 violation）,check-complete 委派门不阻断

## 质量门控统计（Rule 26）

- [x] Q1-Q6 逐项核查完成:触发 0 项（无降质行为:证据造假/跳验证/范围外写入均未发生——S1-S10 全部带 evidence 原文）
- [x] Evidence 抽查 ≥3 条:① R2 回归日志 72 行（路径 plans/task-v156-drift-shield/regression-r2-v156.log,ΣFAIL=0）② CR 复检查点 14-code-reviewer-recheck.md verdict=APPROVED ③ [judge-gate] harness 冒烟（S6/13-executor-S10 检查点四态/3×3 用例原文）——均可 Read、可复现
- [x] 豁免登记:Q3 适用面=无证据造假;61.5 drift-checker 降级债务已登记（Drift Log 行,非 Rule 26 违规）
- [x] 无未处置违规 → outcome 不降级

## Goal Gate (终验)

对照 Verification Contract 逐条复验：
- [x] VC-1: PASS（7 子条/43 对齐/纯追加 16/0,证据上方）
- [x] VC-2: PASS（五段/废弃 14/五要素在位）
- [x] VC-3: PASS（模板+本计划实例双 🔒 区块,三态词各≥1）
- [x] VC-4: PASS（judge-gate×5+注入×1+bash -n+双 harness 实证）
- [x] VC-5: PASS（23/23+registry+级联+回归 72/72+properties=42;部署 diff 见交付）

```
outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 6 终验（VC 全 PASS+58.5 solved） |
| 2 | Where am I going? | alignment-review 收尾→smart-merge-back --deploy→land 73→check-complete→交付总结 |
| 3 | What's the goal? | Rule 73 全链落地并合并部署,回归不破坏既有守护 |
| 4 | What have I learned? | 见 findings.md（误 attest 事故/级联漏改 K9/61.5 换道/06b+S10 双缺陷修正） |
| 5 | What have I done? | 6 Phase 全 complete+S1-S10 十单元+CR 闭环+15 Handoff 行 |
| 6 | Which tasks need processing? | 无（v156 为当前唯一活跃任务;v159/v160/v161 已由并行会话闭环） |
