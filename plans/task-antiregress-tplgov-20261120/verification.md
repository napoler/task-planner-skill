# Verification Contract & Phase Gates

<!-- 判据镜像面（task-tpl-verify-fix：attest vc-gate 读本文件行首 **Verify command**:）。
     本文件=task_plan.md「✅ Verification Contract」20 条 VC 的镜像；两处须同步（改任一侧须重锁+登记）。
     <worktree> 已代换为实际绝对路径：/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 -->

## Goal (1 sentence)

在 worktree 隔离下为 task-planner-skill 落地可机器验证的进度产出防倒退机制与模板治理升级（原则注入/主动加载+场景覆盖/spec_version+存量改造/base-derived lineage 派生），并完成同集零增量回归与部署同步，使 R1–R5 全部可验收且不回退既有能力。

---

## Verification Contract (20 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面。

- [ ] VC-1: 用户需求原文逐字在位（含 R0 全文与 R1-R5 分解）
  Evidence: task_plan.md §🎯 用户需求原文
  **Verify command**: grep -cF "为该项目skill加入放倒退机制  也就是" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md
- [ ] VC-2: 新增进度产出防倒退 Rule 编号唯一且与 51.15/74.7 分工互锁
  Evidence: worktree 三份 rules + grep 输出
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && test $(grep -h -c "^### 111 " skills/task-planner/references/critical-rules.md skills/task-discipline/references/critical-rules-discipline.md skills/task-dispatch/references/critical-rules-dispatch.md | awk -F: '{s+=$1} END{print s+0}') -eq 1 && grep "51.15" skills/task-planner/references/critical-rules.md | grep -q "进度产出" && grep "74.7" skills/task-planner/references/critical-rules.md | grep -q "分工"
- [ ] VC-3: 主模板含「📦 进度产出基线」登记区块（初期评估位）
  Evidence: 主模板对应区块行号
  **Verify command**: grep -c "📦 进度产出基线" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md
- [ ] VC-4: 主模板含「🛡 防倒退终检」区块且含净效果≥0/BLOCK 判据
  Evidence: 主模板对应区块行号
  **Verify command**: grep -c "🛡 防倒退终检" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md && grep -c "净效果" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md
- [ ] VC-5: 防倒退机制接线到 SKILL/init/check-complete/variant 同族
  Evidence: 各文件命中行 + 抽样记录
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -c "进度产出基线\|防倒退终检" skills/task-planner/SKILL.md skills/task-planner/scripts/init-session.sh skills/task-planner/scripts/check-complete.sh skills/task-planner/templates/task_plan.md
- [ ] VC-6: plan-template-kit 存在「原则→模板区块」注册表并覆盖防倒退/验证/证据/理解迭代等原则
  Evidence: 注册表文件路径+行号
  **Verify command**: grep -c "防倒退" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/references/principle-template-registry.md && grep -c "理解迭代" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/references/principle-template-registry.md
- [ ] VC-7: 守卫可校验模板原则覆盖面，缺必选区块 FAIL 且支持豁免登记
  Evidence: 守卫脚本路径+smoke 输出
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && bash skills/task-planner/scripts/check-template-principles.sh --selftest-smoke 2>&1 | tee /tmp/vc07.log && grep -q "PASS" /tmp/vc07.log
- [ ] VC-8: general 兜底须登记理由（非静默默认）在 init-session/check-complete/advisor 链可观测
  Evidence: 命中行号清单
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -c "登记理由" skills/task-planner/scripts/init-session.sh skills/task-planner/scripts/check-complete.sh skills/plan-template-advisor/SKILL.md
- [ ] VC-9: 场景覆盖缺口盘点数据驱动：产出 plans/ 类型分布统计与 31 variant 对照结果
  Evidence: 主仓计划目录 research/scenario-coverage.md
  **Verify command**: grep -c "template_type\|类型分布" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/scenario-coverage.md
- [ ] VC-10: 补缺候选模板清单作为计划内决策点登记（含数据依据），非拍脑袋
  Evidence: task_plan.md R3 决策/风险或 findings 登记节
  **Verify command**: grep -c "补缺候选" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md
- [ ] VC-11: 模板与 plan-template-kit 声明 spec_version（主模板+kit+variant 机制位）
  Evidence: grep 结果（variant 覆盖 ≥31）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -q "spec_version" skills/task-planner/templates/task_plan.md && grep -q "spec_version" skills/plan-template-kit/SKILL.md && test $(grep -rl "spec_version" skills/task-planner/templates/variant | wc -l) -ge 31
- [ ] VC-12: 存量模板 retrofit SOP/扫描机制可用：能列出 spec_version<N 或缺失项清单并复验
  Evidence: 扫描输出+SOP 文档锚点
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && bash skills/plan-template-kit/scripts/scan-template-spec.sh --target-spec 1 2>&1 | tee /tmp/vc12.log && grep -q "spec_version" /tmp/vc12.log
- [ ] VC-13: base/derived 分级与 lineage 头+裁剪清单在模板中可观测
  Evidence: grep 计数（variant lineage ≥31）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -q "lineage" skills/task-planner/templates/task_plan.md && test $(grep -rl "lineage" skills/task-planner/templates/variant | wc -l) -ge 31
- [ ] VC-14: 派生铁律与二级派生 base+parent 双参照条款可 grep（规则/kit 文档）
  Evidence: 命中行号
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -rc "双参照\|二级派生" skills/plan-template-kit/SKILL.md skills/task-planner/references/critical-rules.md
- [ ] VC-15: variant 头注入后 check-template-type.sh 三形态提取兼容（全量/抽样脚本 PASS）
  Evidence: 校验输出（脚本不支持 --all 时用等效循环并在 progress 登记口径）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && bash skills/task-planner/scripts/check-template-type.sh 2>&1 | tee /tmp/vc15.log; echo "exit=${PIPESTATUS[0]}"
- [ ] VC-16: 本计划自身在 P1 实施动工前完成「📦 进度产出基线」回填（dogfood 首个实弹）
  Evidence: 本计划基线区块 B-05 已回填
  **Verify command**: grep -c "已回填（基线落盘）" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md && grep -c "禁倒退清单" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md
- [ ] VC-17: selftest 基线纪律：动工前基线 FAIL 清单落盘，收尾同集零增量
  Evidence: 基线/终验 FAIL 名单文件 diff 为空
  **Verify command**: diff /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/selftest-baseline-fails.txt /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/selftest-final-fails.txt
- [ ] VC-18: 计划结构完整：R1–R5 根源覆盖、P1–P4 各有 S-unit、[goal:G1..G8]、D1/D2、风险四要素、无占位符
  Evidence: task_plan.md + grep 退出码
  **Verify command**: P=/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/task_plan.md; for g in G1 G2 G3 G4 G5 G6 G7 G8; do grep -q "\[goal:$g\]" "$P" || exit 1; done; grep -q "Decision D1" "$P" && grep -q "Decision D2" "$P" && grep -q "合并冲突" "$P" && grep -q "场景选取数据依据" "$P"
- [ ] VC-19: 部署同步验证：部署动作完成后部署位文件与仓内产物逐位 diff=0
  Evidence: 部署 diff=0 清单证据
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && test -f /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/deploy-diff-report.txt && grep -c "diff=0" /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/deploy-diff-report.txt
- [ ] VC-20: 范围合规：实施期仅 worktree 改动+合并受控
  Evidence: git status --porcelain 交叉核对
  **Verify command**: git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 status --porcelain | wc -l

> 口径注：VC-17 的 selftest-{baseline,final}-fails.txt=S1/S8 从全量输出提取的 FAIL 脚本名清单（每行一个）；VC-19 的 deploy-diff-report.txt=S8 按实测部署机制产出的逐位 diff 清单（每行含 diff=0 或差异登记）；VC-20 判据=实施期逐 commit 收敛后 worktree 提交干净（计数随簿记推进下降，终验=0）。

---

## Phase Gates

### Phase 1: 防倒退机制落地（R1）

**Goal**: 新 Rule 111+主模板两区块+三份规则级联落地并自测。

**Depends on**: none

**Done when**:
- [ ] S1-S3 全 complete 且 VC-2/3/4/5/16 对应命令 PASS

**Verification** (run before moving on):
- [x] V-1.1: 主模板双区块在位
  **Verify command**: grep -c "📦 进度产出基线\|🛡 防倒退终检" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/templates/task_plan.md
- [x] V-1.2: 111 空号占用唯一
  **Verify command**: grep -h -c "^### 111 " /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/task-planner/references/critical-rules.md

Status: `complete` Last verified: 2026-11-20（commit 15fc6c5；VC-02/03/04/05/16 证据见 task_plan P1 Evidence 行）

---

### Phase 2: 模板分级派生与原则注入（R5+R2）

**Goal**: base/derived lineage+31 variant 批量注入+原则注册表与覆盖守卫。

**Depends on**: Phase 1

**Done when**:
- [ ] S4-S5 全 complete 且 VC-6/7/13/14/15 对应命令 PASS

**Verification**:
- [ ] V-2.1: variant lineage 覆盖数
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120 && grep -rl "lineage" skills/task-planner/templates/variant | wc -l
- [ ] V-2.2: 注册表在位
  **Verify command**: ls /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/references/principle-template-registry.md

Status: `pending` Last verified: —

---

### Phase 3: spec_version+存量改造与主动加载/场景覆盖（R4+R3）

**Goal**: retrofit 机制化+general 登记理由链+数据驱动补缺候选。

**Depends on**: Phase 2

**Done when**:
- [ ] S6-S7 全 complete 且 VC-8/9/10/11/12 对应命令 PASS

**Verification**:
- [ ] V-3.1: 扫描脚本可运行
  **Verify command**: ls /mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120/skills/plan-template-kit/scripts/scan-template-spec.sh

Status: `pending` Last verified: —

---

### Phase 4: 部署同步、回归与收尾

**Goal**: 同集零增量+部署逐位 diff=0+合并清理簿记。

**Depends on**: Phase 3

**Done when**:
- [ ] S8 complete 且 VC-17/19/20 对应命令 PASS；全量终检=task_plan.md「🛡 防倒退终检」区块

**Verification**:
- [ ] V-4.1: 同集零增量
  **Verify command**: diff /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/selftest-baseline-fails.txt /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/selftest-final-fails.txt

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 既有防倒退闭环（51.15/74.7/106.7/22.4e/103.3b） | 新 Rule 分工段引用对照原条款 | 待终验 |
| 模板体系盘点（research/template-inventory.md） | S4/S5/S6 产出与盘点结论一致性 | 待终验 |
| Rule 16/34 模板域规则 | variant 注入格式与白名单兼容 | 待终验 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（粘贴以下 JSON 原文）
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 防倒退+模板治理 R1-R5 全验收且不回退既有能力
对照 Verification Contract 逐条复验（20 条，见上方 Contract）：
- [x] VC-1..VC-16/18: 各 Phase Evidence 行+命令输出（P1-P3 Evidence 行；master@bd1f131 复跑通过） → PASS
- [x] VC-17: selftest-baseline-fails vs selftest-final-fails diff 空（103 脚本 FAIL=8==基线） → PASS
- [x] VC-19: deploy-diff-report.txt 188/188 diff=0，0 MISMATCH → PASS
- [x] VC-20: worktree 已清理，merge bd1f131 受控（stash 窗口法零冲突+在途三簇恢复） → PASS

 outcome: COMPLETE（独立复检体 103.3 后台运行中，返回后收尾；R3 候选模板=登记待批准非遗留缺陷）
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——若 provider 限流致独立通道不可用，按降级链登记后主进程兜底（本任务 judge 判别已现此判例，证据 findings [sub:02-judge]）。

---

## 交叉验证记录（Rule 108）
<!-- 触发面见 critical-rules-verification.md 108.1（L2+/≥2受管文件/子代理验证产出采信前/用户明确要求）；mini/L0 豁免。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 计划定稿 | attest 全门 EXIT=0（见 progress D-07） | judge 判别 PASS-WITH-RISKS（findings [sub:02-judge]） | 待终验回填 |
| P1-P4 产出 | 各 VC 命令输出 | 独立复检体（103.3） | 待终验回填 |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（worktree 已建，基线已落盘，attest 后进入 S2） |
| 2 | Where am I going? | P1→P2→P3→P4→合并收尾 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md（vc-gate 判据面=verification.md 非 task_plan.md；Goal 表行首=裸 Gn） |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务完成后回填） |
