# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染 -->

## Goal (1 sentence)

在本仓验证链固化「隔离上下文 + 多角度独立验证 + 分歧升级 + 伪造识别信号」的交叉验证方法论（Rule 108 条款 + SKILL 级联 + 验证模板步骤区块 + selftest 守护 + dogfood 实弹），使执行产出的错误、缺陷与虚构声称可由独立路径及时识别。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 108 交叉验证纪律条款在位 verification-gate 卫星规则文——五子条锚（108.1 触发面/108.2 独立重推导/108.3 双视角交叉/108.4 分歧升级/108.5 伪造信号）各 ≥1 且伪造判例锚在位；既有 Rule 84 段零改动
  Evidence: grep 计数输出 + git diff 既有段零改动记录
  **Verify command**: test "$(grep -cE '108\.[1-5]' skills/verification-gate/references/critical-rules-verification.md)" -ge 5 && grep -q 'fabricated-output' skills/verification-gate/references/critical-rules-verification.md
- [ ] VC-2: SKILL 级联与模板步骤在位：verification-gate/SKILL.md 与 task-planner/SKILL.md 各含 Rule 108 引用 ≥1；verification.md 模板含「交叉验证记录」区块锚
  Evidence: grep 输出三文件命中行
  **Verify command**: grep -q 'Rule 108' skills/verification-gate/SKILL.md && grep -q 'Rule 108' skills/task-planner/SKILL.md && grep -q '交叉验证记录' skills/task-planner/templates/verification.md
- [ ] VC-3: selftest-cross-validation.sh 在位可执行、exit 0、selftest-registry.tsv 登记行在位
  Evidence: 脚本运行输出 EXIT=0 + registry 行
  **Verify command**: bash skills/task-planner/scripts/selftest-cross-validation.sh && grep -q 'selftest-cross-validation' skills/task-planner/scripts/selftest-registry.tsv
- [ ] VC-4: dogfood 交叉验证实弹报告在位：双独立路径结论（机械面重推导+语义面复检）+一致/分歧判定行+108.4 协议留痕
  Evidence: plans/task-crossvalidate-20261115/cross-validation-report.md
  **Verify command**: test -s plans/task-crossvalidate-20261115/cross-validation-report.md && grep -q '交叉验证判定' plans/task-crossvalidate-20261115/cross-validation-report.md && grep -q '双路径' plans/task-crossvalidate-20261115/cross-validation-report.md
- [ ] VC-5: 全量回归无新增 FAIL：run-selftests.sh ΣFAIL ≤ master 基线预存量（基线数落 .regression-baseline）
  Evidence: 回归输出 Total 行 + 基线分账行（progress.md）
  **Verify command**: test -f plans/task-crossvalidate-20261115/.regression-baseline && test "$(bash skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | tail -1 | cut -d= -f2)" -le "$(cat plans/task-crossvalidate-20261115/.regression-baseline)"
- [ ] VC-6: 合并回落地：主仓 git log 含 wt/task-crossvalidate-20261115 合并提交、worktree 目录与分支已清理、rule-reserve land 108 landed 行在位
  Evidence: git log --oneline + ls 输出 + reservations 账本行
  **Verify command**: git log --oneline -8 | grep -q 'task-crossvalidate-20261115' && ! test -d tmp/worktrees/task-crossvalidate-20261115 && grep -q '"rule":108,"status":"landed"' plans/.rule-reservations.jsonl

---

## Phase Gates

### Phase 1: 侦察与起草

**Goal**: 锁定验证链插入点与守护面（F1-F6），产出 Rule 108 五子条条款草案与模板区块草案

**Depends on**: none

**Done when**:
- [ ] findings.md F1-F6 六节齐（各含 file:line 锚）
- [ ] clause-drafts.md §1/§2/§3 在位（五子条全文+模板区块草案+级联 spec）

**Verification** (run before moving on):
- [ ] V-1.1: findings F1-F6 六节齐
  **Verify command**: test "$(grep -cE '^### F[1-6]' plans/task-crossvalidate-20261115/findings.md)" -ge 6
- [ ] V-1.2: 条款草案五子条锚齐+级联 spec 三节
  **Verify command**: test "$(grep -cE '108\.[1-5]' plans/task-crossvalidate-20261115/clause-drafts.md)" -ge 5 && grep -q '§3 级联 spec' plans/task-crossvalidate-20261115/clause-drafts.md

Status: `pending` Last verified: —

---

### Phase 2: 落地插改（worktree）

**Goal**: 条款+级联+模板区块+守护脚本+registry 全部落 worktree

**Depends on**: Phase 1

**Done when**:
- [ ] 五个 S-unit 产出全在 worktree 且 106.1a 回读通过

**Verification**:
- [ ] V-2.1: worktree 规则文五子条锚 ≥5+判例锚+既有段零改动（git diff 计数）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && test "$(grep -cE '108\.[1-5]' skills/verification-gate/references/critical-rules-verification.md)" -ge 5 && grep -q 'fabricated-output' skills/verification-gate/references/critical-rules-verification.md
- [ ] V-2.2: worktree 双 SKILL 级联+模板区块锚
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && grep -q 'Rule 108' skills/verification-gate/SKILL.md && grep -q 'Rule 108' skills/task-planner/SKILL.md && grep -q '交叉验证记录' skills/task-planner/templates/verification.md
- [ ] V-2.3: worktree 新 selftest exit 0+registry 行在位
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && bash skills/task-planner/scripts/selftest-cross-validation.sh && grep -q 'selftest-cross-validation' skills/task-planner/scripts/selftest-registry.tsv
- [ ] V-2.4: EN-06 纪元演进后本机通过（1-108 ≥3 处）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115 && bash skills/task-planner/scripts/selftest-enumerate-first.sh

Status: `pending` Last verified: —

---

### Phase 3: 验证（回归+复检+dogfood 实弹）

**Goal**: 全量回归分账零新增 FAIL+critic 复检回执+dogfood 双视角交叉验证报告

**Depends on**: Phase 2

**Done when**:
- [ ] .regression-baseline 落盘且 ΣFAIL ≤ 基线
- [ ] critic 回执 checkpoint 在位含 CR 结论行
- [ ] cross-validation-report.md 含判定行

**Verification**:
- [ ] V-3.1: 回归分账（ΣFAIL ≤ 基线）
  **Verify command**: test -f plans/task-crossvalidate-20261115/.regression-baseline && test "$(bash skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | tail -1 | cut -d= -f2)" -le "$(cat plans/task-crossvalidate-20261115/.regression-baseline)"
- [ ] V-3.2: critic 复检回执在位含结论行
  **Verify command**: grep -q 'CR 结论' plans/task-crossvalidate-20261115/subagent-state/p3s2-critic-checkpoint.md
- [ ] V-3.3: dogfood 报告判定行在位
  **Verify command**: grep -q '交叉验证判定' plans/task-crossvalidate-20261115/cross-validation-report.md

Status: `pending` Last verified: —

---

### Phase 4: 收口

**Goal**: 合并回+清理+land 108+部署核验+归档+kb 入库

**Depends on**: Phase 3

**Done when**:
- [ ] VC-1~VC-6 主仓全过 + worktree/分支清理 + 归档完成

**Verification**:
- [ ] V-4.1: 合并提交与清理证据
  **Verify command**: git log --oneline -8 | grep -q 'task-crossvalidate-20261115' && ! test -d tmp/worktrees/task-crossvalidate-20261115
- [ ] V-4.2: rule-reserve land 108 账本行
  **Verify command**: grep -q '"rule":108,"status":"landed"' plans/.rule-reservations.jsonl
- [ ] V-4.3: 归档证据（ARCHIVED 或 ALREADY_ARCHIVED）
  **Verify command**: test -d plans/archive/task-crossvalidate-20261115 || grep -q 'ALREADY_ARCHIVED' plans/task-crossvalidate-20261115/progress.md

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| critical-rules-verification.md 结构 | Rule 108 插入位置与文件既有格式一致（P2-S1 回读） | |
| selftest-registry.tsv 行格式 | 新行 4 列 TSV 对齐（P2-S4） | |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115
```

JSON 输出：
```json
{终验时粘贴}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或 stats verdict=violation → check-complete.sh exit 1 阻断交付

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 交叉验证方法论固化
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL
- [ ] VC-6: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。
**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。
**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3 独立验证延伸）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 |
| 2 | Where am I going? | Phase 2 worktree 落地 → Phase 3 验证 → Phase 4 收口 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
