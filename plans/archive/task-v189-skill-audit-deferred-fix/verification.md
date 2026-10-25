# Verification Contract & Phase Gates

## Goal (1 sentence)

修复 task-v188 审计的 4 项 deferred 高风险项（P0 bun / F5 平台 / F11 I/O Schema / S76 原子写+锁），验证零回归后合并回 master。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: 3 脚本 shebang 改 node --experimental-strip-types 可运行
  Evidence: `node --experimental-strip-types scripts/session-catchup.ts` exit 0（sync-ide-folders.ts + register-hooks-cj.ts 同改）
- [x] VC-2: init-session.sh 补 .zcode/plan-templates 探测 + SKILL.md:47 相对化
  Evidence: `grep -c .zcode/plan-templates scripts/init-session.sh` = 2；SKILL.md:47 = `node scripts/plan-created.cjs`（无 ~/.zcode 绝对路径）
- [x] VC-3: 新建 schema + verify_io.sh + selftest-verify-io.sh
  Evidence: `ls scripts/schemas/check-delegation-stats.schema.json` 在位；`bash scripts/selftest-verify-io.sh` 4 PASS 0 FAIL
- [x] VC-4: cli_todo-manager.ts 原子写 + O_EXCL lockfile
  Evidence: 5 轮 20 路并行 create count=20（竞态消除）；store.json 非零；只读命令免锁
- [x] VC-5: 无回归（selftest 套件）
  Evidence: worktree 92 脚本 90 PASS 2 FAIL；master 91 脚本 89 PASS 2 FAIL；FAIL 清单一致（pre-existing）

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

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
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
- [x] VC-1: 3 脚本 node strip-types exit 0 → PASS
- [x] VC-2: init-session.sh .zcode/plan-templates ≥2 + SKILL.md:47 相对化 → PASS
- [x] VC-3: schema 在位 + verify_io.sh + selftest 4 PASS → PASS
- [x] VC-4: 5 轮并行 count=20 + store.json 非零 → PASS
- [x] VC-5: selftest 2 pre-existing FAIL 与 master 一致 → PASS

outcome: COMPLETE
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

---

## 收口增补（2026-10-26）

### Phase Gates 收口映射（替代上方模板 {Name} 段）
- Phase 1 Requirements & Discovery（4 项输入+用户「1,2,3,4」授权）→ V-1.1→VC-1..4 — complete
- Phase 2 Planning & Structure（方案选型）→ V-2.1→VC-1..4 — complete
- Phase 3 Implementation（worktree 执行+merge 3fa1e02）→ V-3.1→VC-1..4 — complete
- Phase 4 Testing & Verification（套件对跑+竞态验证）→ V-4.1→VC-4, VC-5 — complete
- Phase 5 Delivery（merge+清理+delivery-summary+归档）→ V-5.1→VC-5 — complete

### 委派统计复验（Rule 25.4）
机器口径：check-delegation.sh stats → delegated=0/5, main_direct=5, violations=[Phase 3 self_declared_reason（2026-10-19 worktree 会话历史直改，无派发留痕，如实登记）], verdict=violation → check-complete exit 1 → **outcome=PARTIAL**。
2026-10-19 delivery-summary 的 COMPLETE=产品面口径（VC-1..5 全过、零回归、已合并）；本收口按委派纪律口径修正终态 PARTIAL——两者并存如实留档，非矛盾。

### Goal Gate（2026-10-26）
- [x] VC-1..VC-5 全 PASS（2026-10-26 Agent B 独立复核 4 项全 resolved + run-selftests --fresh 93/93）
- outcome: **PARTIAL**（产品 solved；流程遗留=Phase 3 历史直改委派纪律违规；建议后续按 Rule 96 默认派发）
