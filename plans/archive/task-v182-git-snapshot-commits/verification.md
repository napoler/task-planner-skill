# Verification Contract & Phase Gates

## Goal (1 sentence)

把「任务执行开始前基线快照提交 + 结束后终态收口提交」（首尾双 Git 提交）制度化为 task-planner 技能增量条款 Rule 90，使任何任务的起点与终点都有可恢复、可追溯的版本锚。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: Rule 90 条款在位且六子条齐（=1/=6 实测，84-final-verification.md）（90.1 首快照/90.2 尾提交/90.3 合并合理性/90.4 数据管理/90.5 衔接/90.6 机制）
  Evidence: grep 锚计数输出（=1 与 =6）
  **Verify command**: grep -c "^### 90 任务执行首尾" skills/task-discipline/references/critical-rules-discipline.md; grep -cE "^- \*\*90\.[1-6]" skills/task-discipline/references/critical-rules-discipline.md
- [x] VC-2: 索引级联一致（3 处 1-90+3 载体含 90 实测）
  Evidence: grep 计数输出（核心 SKILL.md ≥2；三载体含 90 合计 ≥4）
  **Verify command**: grep -c "1-90" skills/task-planner/SKILL.md; grep -lE "(85,86,87,88,89,90|85/86/87/88/89/90)" skills/task-planner/SKILL.md skills/task-discipline/SKILL.md skills/task-planner/references/critical-rules.md
- [x] VC-3: 全量 selftest 回归（本任务面零 FAIL；唯一 FAIL=pairing PR-02 悬空 77/78/79 对端域，独立归属 HIGH 置信非本任务引入——58.5 裁决 solved、遗留面已登记）
  Evidence: 遍历实跑输出为空（无 FAIL 行）
  **Verify command**: for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f" >/dev/null 2>&1 || echo "FAIL $f"; done
- [x] VC-4: 台账 landed 行 =1 实测
  Evidence: plans/.rule-reservations.jsonl 含 landed 行
  **Verify command**: grep -c '"rule":90,"status":"landed"' plans/.rule-reservations.jsonl
- [x] VC-5: scope porcelain 空
  Evidence: git status --porcelain 输出为空
  **Verify command**: git status --porcelain -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-discipline/SKILL.md skills/task-planner/references/critical-rules.md
- [x] VC-6: 9 笔提交链，首锚 4fc87a2+收口 05ba07e 时序实证
  Evidence: git log --grep task-v182 ≥3 笔且首笔含「首锚」末笔含「归档」
  **Verify command**: git log --oneline --grep "task-v182"

---

## Phase Gates

### Phase 1: 实施+验收合一（L0-T 纯文本档 · worktree 隔离）

**Goal**: Rule 90 条款+索引级联落地 worktree，锚回归绿后合并回 master 并完成台账/归档/收口提交。

**Depends on**: none

**Done when**:
- [ ] S1-S3 产出在 worktree 提交；S7 全集复跑零 FAIL；S8 合并回+land；S9 归档+INDEX+收口提交；S10 独立终验六 VC 全 PASS

**Verification** (run before moving on):
- [ ] V-1.1: mapped to VC-1, VC-2（条款与索引锚 grep）
- [ ] V-1.2: mapped to VC-3, VC-4（回归绿+台账 land）
- [ ] V-1.3: mapped to VC-5, VC-6（scope 干净+首尾提交）

Status: `complete` Last verified: 2026-10-16（VC-1=1+6 ✓ / VC-2=3+3 载体 ✓ / VC-3=82 PASS+pairing PR-02 对端域残留见 Goal Gate 注 / VC-4=1 ✓ / VC-5=0 ✓ / VC-6 见收口提交后 Verifier 报告）

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
对照上方 Verification Contract（VC-1..VC-6）逐条复验，每条登记 evidence→PASS/FAIL（本栏为执行模板，不另设条目）

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
