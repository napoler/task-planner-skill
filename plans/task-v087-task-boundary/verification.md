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

## 终验（task-v087）

| # | 判定 | 证据 | 结论 |
|---|------|------|------|
| VC-1 | critical-rules.md 含 8.1 新任务边界子条 | `grep '^8\.1 ' references/critical-rules.md` → 非空含「新任务边界判定（D 类，task-v087）」（部署位亲验） | PASS |
| VC-2 | SKILL.md 含 D 行+特判段+C12 扩 D | `grep 'D 新任务边界' SKILL.md`、`grep 'Rule 8.1 — task-v087' SKILL.md`、`grep 'C12' | grep 'D/A/B/C'` 均非空 | PASS |
| VC-3 | UPS hook note 含 D 类指引 | stdin JSON 冒烟：jq -r additionalContext 含「D 新任务边界(与当前 Goal/范围/交付物均无关联)→开新计划目录...不相干内容禁止混入当前计划(Rule 8.1)」；jq -e JSON 合法 | PASS |
| VC-4 | todo-sync.md S5 含 D 类分支 | `grep 'D=新任务边界，Rule 8.1' references/todo-sync.md` 非空（旧计划 Todo 映射保留语义在位） | PASS |
| VC-5 | selftest 守护+全量回归+三位部署 | selftest-task-boundary.sh Total: 11 PASS=11 FAIL=0；主仓全量循环求和 **441/0**（26 脚本）；部署位逐脚本 26/26 全 PASS（自报总数 440 因 batch-pilot 自跳 BP-08 口径差 1，逐脚本行无 FAIL，取主仓 441 为权威数）；三位 diff -r=IDENTICAL | PASS |

**委派统计（Rule 25.4）**：子代理执行 Phase 数 / 总 Phase 数 = 0/5；主进程直做清单=全 5 Phase（例外理由：Phase 1③机械只读勘察；Phase 2②计划系统文件维护+⑥trivial 条款行追加（规则增强先例 v079-v086 同型）；Phase 3②selftest 体系维护；Phase 4①git 编排+②簿记；Phase 5②簿记——全部命中 Rule 25.3 白名单①②③⑥）→ WHITELIST-EXEMPT。

**outcome: COMPLETE**（合并 a2ae738，部署 sm-rc=0 三位 IDENTICAL）
