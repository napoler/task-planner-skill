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

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
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
## Goal Verification — {Goal 语句}
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
...

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

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

## 终验裁决（2026-10-08）
| VC | 结果 | 证据 |
|----|------|------|
| VC-1 59.1 条款+enforce | PASS | `### 59` ×1+八子条;check-plan-dispatch ⑤-c 三 fixture(超限 exit1/合规 0/旧格式 SKIPPED);check-dispatch ⑥ p1 rc=2 |
| VC-2 伴飞落地 | PASS | dispatch 模板伴飞子节(三要素)+check-dispatch ⑦(p2 rc=2)+S-unit 表伴飞列 |
| VC-3 能力预防+模板列 | PASS | 59.4 条款+task_plan 模板 9 列(Nf/Nl/Nmin) |
| VC-4 技能扫描 | PASS | 59.3 条款+knowledge-brief §6 区块+comet 用户触发型判别注释 |
| VC-5 analyze-splits | PASS | 190→202 行;超限 rc1/合规 rc0/例外登记 token 跳过 |
| VC-6 59.5 分段锚 | PASS | 条款+46.1 联动表述+豁免收窄 |
| VC-7 新守护 | PASS | 23 断言全 PASS+registry 登记 |
| VC-8 全量回归 | PASS | 59 脚本 58 PASS;唯一 FAIL=periodic-review(PR-03/04/05/10=v141 存量遗留,登记非本任务范围) |
| VC-9 部署位 | PASS | ~/.zcode/skills/task-planner diff IDENTICAL(excl backup)+守护部署位实跑 23/23 |

**outcome: COMPLETE**（VC-1..9 全 PASS;CR 两轮闭环:首轮 CHANGES_REQUESTED 7 项全修,复审 APPROVED+2 建议已修）
**遗留登记**: periodic-review PR-03/04/05/10(v141 实质缺口:Rule 57 检查维度/自动纠正/开关键/C39 消费接线未落地)——后续任务承载
