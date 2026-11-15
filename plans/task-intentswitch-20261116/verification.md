# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 技能族增强会话内「A→B 意图切换」的识别与计划隔离切换显性度：以单入口快速判定卡+显性通告+切换登记最小字段+hook 快速锚收敛既有 Rule 8.1/94/102 机制，使切换可被及时触发、用户可感知、事后可审计，且不破坏 drift-checker 既有安全网语义。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: 诊断与根因可审计——findings.md 含现有机制全景表（含文件:行号）+ H1-H6 逐条诊断（verified/refuted/partially + 证据）+ R-1~R-5 根因排序 + ≥2 候选方案（S-A/S-B）含取舍
  Evidence: /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md（Research Findings/Technical Decisions 段）
  **Verify command**: grep -qE '机制全景表' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE '\| H1 \|' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE '\| H6 \|' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'R-1' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'R-5' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'S-A' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'S-B' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md
- [ ] VC-2: SKILL.md「用户新指令处理」单入口具备快速判定卡（对照 user-session-log 最新原话与当前 Goal/范围/交付物三要素零交集判定）、显性通告模板要素（挂起旧计划/触发原话锚/新计划/下一步）、切换登记最小字段指引，且保留 :190 收口序列语义
  Evidence: /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:188-260（用户新指令处理区块）
  **Verify command**: grep -qF 'user-session-log' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -qF 'Goal/范围/交付物' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '显性通告' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '切换登记' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '挂起' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '新指令统一收口序列' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] VC-3: Rule 94/102 与 SKILL.md 单入口交叉锚收敛——SKILL.md 为切换执行单入口清单，Rule 94/102 保留权威细则并含指向/一致表述，无并行漂移步骤
  Evidence: /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md + /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md（Rule 94/102 邻近）
  **Verify command**: grep -q 'Rule 94' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q 'Rule 102' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q 'Rule 94' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q 'Rule 102' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q 'SKILL.md' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md
- [ ] VC-4: UPS hook [plan-note] 默认提示含快速判定锚句（Goal/范围/交付物与最新专档原话比对→均无关走 D 类切换并挂起/新建/显性通告/登记；可判定换目标触发走 E 类先确认），且保留 102.0/80.8②/8.1 关键约束
  Evidence: /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh:287（默认 note）
  **Verify command**: grep -qF 'Goal/范围/交付物' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q '专档' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q '显性通告' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q '切换登记' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q 'Rule 102.0' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q '80.8' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh
- [ ] VC-5: 边界显性且无语义回归——文案明确 drift-checker 为执行偏移/目标漂移安全网而非意图切换发起器；Rule 64.2.1/64.7 关键锚与目标漂移零交集语义未删除或反转
  Evidence: /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（DRIFT CHECK/新指令处理边界说明）+ /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:59,68
  **Verify command**: grep -q '64\.2\.1' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md && grep -q '64\.7' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md && grep -q '零交集' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md && grep -q 'drift-checker' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '意图切换' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] VC-6: 交付一致性与回归可观察——本计划文档关键区块完整（R1/VC/Phase/隔离决策/verification Verify command），且实现期改动文件限定在 scope 内可审计
  Evidence: plans/task-intentswitch-20261116/{task_plan,verification,findings,knowledge-brief,progress}.md + `git -C /mnt/data/dev/task-planner-skill diff --name-only`
  **Verify command**: grep -q '^template_type: general' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -q '^plan_tier: standard' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -q 'R→VC 映射' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -q '隔离决策' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -qF '**Verify command**:' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/verification.md && test -f /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/knowledge-brief.md && test -f /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/progress.md

---

## Phase Gates

### Phase 1: 诊断与增强计划定稿

**Goal**: 固化现有意图切换/计划隔离机制全景、H1-H6 根因诊断与 S-A/S-B 方案，并产出可执行增强计划（R1→VC 映射完整）。

**Depends on**: none

**Done when**:
- [x] findings.md 含机制全景表+H1-H6+R-1~R-5+≥2 方案
- [x] task_plan.md/verification.md/knowledge-brief.md/progress.md 填充完成且与 R1 一致

**Verification** (run before moving on):
- [ ] V-1.1: VC-1 诊断与根因可审计
  **Verify command**: grep -qE '\| H1 \|' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE '\| H6 \|' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'R-1' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'S-A' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'S-B' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md
- [ ] V-1.2: VC-6 计划文档关键区块与验证命令形态在位
  **Verify command**: grep -q 'R→VC 映射' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -q '隔离决策' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && grep -qF '**Verify command**:' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/verification.md

Status: `in_progress` Last verified: 2026-11-16

---

### Phase 2: 单入口与显性化增强实现（worktree）

**Goal**: 在 worktree 内完成 SKILL.md 单入口增强、hook 快速锚升级、Rule 94/102 交叉锚收敛与 drift-checker 边界说明。

**Depends on**: Phase 1

**Done when**:
- [ ] S1-S4 完成且各自产出可 grep 证实

**Verification** (run before moving on):
- [ ] V-2.1: VC-2 + VC-4 入口与 hook 显性增强落地
  **Verify command**: grep -q '显性通告' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q '切换登记' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -qF 'Goal/范围/交付物' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh && grep -q '显性通告' /home/terry/.zcode/skills/task-planner/scripts/zcode-userpromptsubmit.sh
- [ ] V-2.2: VC-3 + VC-5 交叉锚与边界语义无回归
  **Verify command**: grep -q 'SKILL.md' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q '64\.2\.1' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md && grep -q '64\.7' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md

Status: `pending` Last verified: —

---

### Phase 3: 回归验证与一致性核验

**Goal**: 运行 VC 全量机械校验、完成 103.6 同步核对清单与 scope diff 审计，修正发现的措辞漂移。

**Depends on**: Phase 2

**Done when**:
- [ ] VC-1~VC-6 命令执行并记录证据
- [ ] 多文件变更集同步核对清单全绿，git diff 限定 scope 内

**Verification** (run before moving on):
- [ ] V-3.1: VC-6 交付一致性与 scope 可审计
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md && test -f /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/verification.md && test -f /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md
- [ ] V-3.2: VC-3/VC-5 关键锚点回归通过
  **Verify command**: grep -q 'Rule 94' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q 'Rule 102' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q '零交集' /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md

Status: `pending` Last verified: —

---

### Phase 4: Code Review、终验与交付

**Goal**: 通过 code-review gate，完成 VC 终验、R1 目标达成裁决与交付摘要，具备归档条件。

**Depends on**: Phase 3

**Done when**:
- [ ] code_review APPROVED（required）
- [ ] 全部 VC PASS 且收尾回读梳理连续一轮零新发现

**Verification** (run before moving on):
- [ ] V-4.1: VC-1 诊断证据仍完整（无回归覆盖）
  **Verify command**: grep -qE '\| H1 \|' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md && grep -qE 'S-A' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/findings.md
- [ ] V-4.2: VC-6 计划与验证载体齐备
  **Verify command**: grep -qF '**Verify command**:' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/verification.md && grep -q '^plan_tier: standard' /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116/task_plan.md

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| skills/task-planner/SKILL.md:188-201 | Phase 2 S1 改动后保留收口序列并含增强要素 | 待终验 |
| skills/task-discipline/references/critical-rules-discipline.md:607-618,695-706 | Rule 94/102 语义保留+交叉锚存在 | 待终验 |
| /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md:59,68 | 64.2.1/64.7 锚与零交集语义未改 | 待终验 |
| plans/task-intentswitch-20261116/user-session-log.md#1 | R1 原文逐字、R→VC 映射、裁决引用一致 | 符合（计划期） |

## 委派统计复验（Rule 25.4）

```bash
# 证据（终验时粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-intentswitch-20261116
```

JSON 输出：
```json
{终验时粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 为 task-planner 技能族增强会话内「A→B 意图切换」的识别与计划隔离切换显性度
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL
- [ ] VC-6: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

## 交叉验证记录（Rule 108）
<!-- 触发面：≥2受管文件实现改动与子代理验证产出采信前；终验填写。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| VC-2~VC-5 改动一致性 | （终验填写：grep/git diff 命令与结果） | （终验填写：独立复检体结论） | 待填写 |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（诊断与计划定稿，文档落盘收尾） |
| 2 | Where am I going? | Phase 2 worktree 实施（S1-S4）→ Phase 3 回归 → Phase 4 CR/终验 |
| 3 | What's the goal? | 增强 A→B 意图切换识别与计划隔离切换显性度（可触发、可感知、可审计、不破坏 drift 安全网） |
| 4 | What have I learned? | 见 findings.md（M1-M15 全景，H1-H6，R-1~R-5，S-A 推荐） |
| 5 | What have I done? | 见 progress.md（P0 调研与计划文档落盘） |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（未在本轮变更） |