# Verification Contract & Phase Gates

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: [What to check / test command / file to inspect]
  Evidence: [file path / command output / screenshot]
- [ ] VC-2: [What to check]
  Evidence: [file path / command output]
- [ ] VC-3: [What to check]
  Evidence: [file path / command output]
- [ ] VC-4: [What to check]
  Evidence: [file path / command output]
- [ ] VC-5: [What to check]
  Evidence: [file path / command output]

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
- [ ] V-1.2: [mapped to VC-? or custom]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
- [ ] V-2.2: ...

Status: `pending` Last verified: —

---

### Phase 3: {Name}

...

---

## 委派统计复验（Rule 25.4）
- [x] 委派率已统计:子代理执行 Phase 4 / 总数 5(80%)— P2 codebase-analyzer、P3 architect、P4 executor A/B、P5a critic
- [x] 主进程直做 Phase 均在计划 Executor 字段登记例外理由(P5b-5f:合并回合约 §11.3 git 编排动作不可委派;另 Rule 22.3 兜底接管 2 处 trivial .md 修正均留痕)
- [x] 委派率 <50% 且无登记理由 → outcome 已降级 PARTIAL(不适用:80% ≥ 50%)

## 质量门控统计（Rule 26 — 本计划自身按新规自检）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项
  (Q1 各 complete Phase 的 VC 均有证据;Q2 progress.md Test Results 已填;Q3 证据经 critic 字节级/AST 级+主进程 grep 双重抽查 ≥3 条属实;Q4 Handoff 表 4 个子代理行 verify_done 全勾;Q5 80%;Q6 非批量不适用)
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现(抽查记录见上与 progress.md)
- [x] 豁免登记:无
- [x] 存在未处置违规 → outcome 已按 Rule 26.3 降级(不适用:无违规)

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 将"质量优先于速度"固化为 task-planner 流程门控与惩罚机制(Rule 26)
对照 Verification Contract 逐条复验(2026-09-04,合并后 master @ d2f030d):
- [x] VC-1: Rule 26 双落点 — `grep -c "^### 26 质量优先于速度门控" skills/task-planner/references/critical-rules.md` = 1(:160 起,26.1-26.6 齐全);SKILL.md :303 索引行 + :184 终验 bullet + :211 C15(grep 3 标记 = 3)→ PASS
- [x] VC-2: 惩罚映射可判定 — critical-rules.md 26.3 表格(Q1-Q6 → 回炉/最高 PARTIAL/BLOCKED),26.4 豁免条款含"Q3 无事前豁免" → PASS
- [x] VC-3: templates/verification.md:74 新增「## 质量门控统计（Rule 26）」段(grep=1),位于委派统计(:69-72)与 Goal Gate(:80)之间 → PASS
- [x] VC-4: 跨文件一致性 — critic(agent_18df94ed)六项审查 5 PASS+1 PASS(NIT);2 处 WARNING(SKILL.md:288/:350 陈旧"Rules 1-25")已修(commit 367f388),合并后 `grep -c "Rules 1-26" SKILL.md` = 2,无残留 1-25 标签 → PASS
- [x] VC-5: 无回归 — worktree init-session.sh 冒烟生成 5 文件(/tmp/qos-smoke);merge commit d2f030d 在 master;`git worktree list` 仅剩主树;分支 wt/task-quality-over-speed 已删 → PASS
- [x] VC-6: check-complete.sh 修复验证 — 修复前 NameError(本会话亲测复现);修复后真实未完成计划无 NameError 正常 exit 1;/tmp 全 complete 计划 ALL PHASES COMPLETE exit 0(合并前 worktree 与合并后 master 双验证) → PASS

Code Review Gate(code_review: required):改动 4 文件 = 3 .md + 1 .sh,均不在 gate 代码文件过滤列表(.py/.ts/…,排除 .md/.sh)→ 过滤后清单为空,gate 空置通过;实质审查已由 critic 5a 全量 diff(含脚本 AST 级验证)覆盖 → APPROVED

已知遗留(不阻塞,期后处理):① C15 检查时机与清单标题语义错位(C14 同款既有模式,行为由 Rule 26.2 双检查点定义);② 后续可选项见 findings.md「方案设计 §后续可选项」

 outcome: **COMPLETE**
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
