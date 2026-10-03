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

## VC 终验复验（2026-10-04）
| VC | 判定 | 证据 |
|----|------|------|
| VC-1 Rule 49 五子条完整 | ✅ PASS | critical-rules.md:506-520（### 49 标题+引言+缺口+49.1-49.5）；grep -c '^49\.[1-5]'=5（主仓 957a7a8 后复验） |
| VC-2 SKILL 联动 4 锚+净增 ≤10 | ✅ PASS | :9 全集 1-49/:85 推进括注/:200 C34/:284 bullet/:306 References；净增 2 行（447→449）；主锚 Rules 1-39=2 且 1-40=0（LA-12/13 实证） |
| VC-3 selftest 守护+全量回归 | ✅ PASS | selftest-lane-advancement.sh 14 断言（LA-01..14）单跑 14/0；全量 45 脚本 702 PASS/0 FAIL（主进程逐 Total 求和，含 final-gate-hash 22 条口径修正） |
| VC-4 CR+alignment 双 APPROVED | ✅ PASS | findings.md [CR] 段（P0/P1/P2=0）+[align] 段（锚零残留/术语 5=5/编号成立） |
| VC-5 合并+部署 3 位+清理 | ✅ PASS | merge 957a7a8（--no-ff）；~/.claude+~/.config/opencode 脚本 IDENTICAL；~/.zcode 手动原子换位 diff=0+位上 14/0；worktree+wt 分支已删 |

## 委派统计（Rule 25）
- 派发型 Phase：P2（S1/S2 executor）、P3（S3 executor）、P4（S4 executor 承接改派）= 3 Phase
- 主进程 Phase：P1、P5（均白名单① git/worktree 编排 + ③ 机械验证命令）
- 委派率 3/5=0.6 < 0.7，但主进程直做理由全部命中 Rule 25.3 白名单①③ → **WHITELIST-EXEMPT 放行**
- 改派记录：S4 code-runner-agent(mini) provider 拒绝 → executor(sonnet-1)（22.3①）

## 结论：COMPLETE（VC 5/5 PASS）
