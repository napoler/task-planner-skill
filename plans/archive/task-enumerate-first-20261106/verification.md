# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

新增 Rule 105「可枚举集合全量枚举优先纪律（ls-first）」条款+selftest 守护+级联部署，使「小集合关键词盲搜」这一检索缺陷模式在制度上被纠正（用户 R2「必须进行纠正」），复用判例行为有机器可探测的规则锚。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 注：VC-1/VC-2/VC-4 在 worktree 内验证（合并回后于主仓复跑 VC-1/VC-2 主仓态）。

- [ ] VC-1: Rule 105 条款全文在位于 `skills/task-discipline/references/critical-rules-discipline.md`，含 105.1 全量枚举优先判据、105.2 零命中≠不存在回退复核、105.3 缺陷信号条款、105.4 适用边界、105.5 反例锚
  **Verify command**: test "$(grep -cE '105\.[1-5]' skills/task-discipline/references/critical-rules-discipline.md)" -ge 5 && test "$(grep -c '全量枚举' skills/task-discipline/references/critical-rules-discipline.md)" -ge 3
  Evidence: grep 计数输出 + 条款段落行号
- [ ] VC-2: 新增 `skills/task-planner/scripts/selftest-enumerate-first.sh` 在位且守护规则关键行
  **Verify command**: bash skills/task-planner/scripts/selftest-enumerate-first.sh
  Evidence: 脚本运行输出（断言数+PASS 计数）+ exit code
- [ ] VC-3: 既有 selftest 全量回归无本任务引入 FAIL（基线漂移豁免口径：Total 97 PASS=95 FAIL=2，FAIL 项=active-plan T11+execution-stability T11b 时序 flaky（主仓单跑可过）且与本任务变更面零交集；如实登记非 FAIL=0）
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -E '^Total'
  Evidence: 套件输出汇总行（ΣFAIL=0）
- [ ] VC-4: 级联面完成：SKILL.md 全集索引/计数更新 + 全仓旧纪元锚形态（'1-104' 字面族）清零或逐项登记已修正
  **Verify command**: bash skills/task-planner/scripts/selftest-enumerate-first.sh > /dev/null 2>&1 && echo EN07-clean
  Evidence: grep 输出 + Phase 1 级联清单消项记录。注：selftest-enumerate-first.sh 自身含 '1-104' 字面（EN-07 负断言实现所需，自指例外）——grep 清零验收范围=skills/**+scripts/** 排除该脚本自身
- [ ] VC-5: 部署位同步 diff=0（zcode/claude/cursor 三位同族文件）+ 主仓 scope 文件已提交
  **Verify command**: diff -r skills/task-planner /home/terry/.zcode/skills/task-planner > /dev/null 2>&1 && diff -q skills/task-discipline/SKILL.md /home/terry/.zcode/skills/task-discipline/SKILL.md > /dev/null && diff -q skills/task-discipline/references/critical-rules-discipline.md /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md > /dev/null && echo deploy-identical
  Evidence: diff 空输出 + git log stat
- [ ] VC-6: 用户原话双锚：R1/R2 逐字在位 user-session-log.md #1 + task_plan R 区块
  **Verify command**: test "$(grep -c '因小失大' plans/task-enumerate-first-20261106/user-session-log.md)" -ge 1 && test "$(grep -c '因小失大' plans/task-enumerate-first-20261106/task_plan.md)" -ge 1
  Evidence: grep 计数输出

---

## Phase Gates

### Phase 1: Requirements & Discovery

**Goal**: 摸清既有检索条款覆盖面+级联锚面清单+归属卫星确认（findings 三节产出）

**Depends on**: none

**Done when**:
- [ ] Explore 子代理返回且 findings.md §调研结论 含三节产出（路径+行号锚）

**Verification** (run before moving on):
- [ ] V-1.1: findings.md 含「调研结论」段且非 stub（映射 VC-6 前置）
- [ ] V-1.2: 级联锚清单覆盖四形态族（'1-104' 字面/宽锚/SKILL 计数行/registry 钉值）

Status: `in_progress` Last verified: 2026-11-06

---

### Phase 2: Design（规则定稿）

**Goal**: Rule 105 条款全文+级联清单+selftest 断言清单定稿落 findings

**Depends on**: Phase 1

**Done when**:
- [ ] findings.md §Rule105 设计定稿 段在位（条款草案全文可转录）

**Verification**:
- [ ] V-2.1: 条款草案含五子条结构与反例锚（映射 VC-1 设计基线）
- [ ] V-2.2: 断言清单 ≥6 条且覆盖规则段标题/105.1-105.5 关键词/反例锚行

Status: `pending` Last verified: —

---

### Phase 3: Implementation（worktree 内）

**Goal**: 规则全文+selftest+级联修正三产物落盘且 worktree 内回归 FAIL=0

**Depends on**: Phase 2

**Done when**:
- [ ] S1-S4 全 complete + 103.6 同步核对清单全绿

**Verification**:
- [ ] V-3.1: VC-1/VC-2 命令 worktree 内 PASS
- [ ] V-3.2: VC-4 级联 grep 清零
- [ ] V-3.3: S4 全量回归 FAIL=0（映射 VC-3）

Status: `pending` Last verified: —

---

### Phase 4: Testing & Verification

**Goal**: critic 独立复检（103.3 升档）+ fresh 全量回归复跑

**Depends on**: Phase 3

**Done when**:
- [ ] critic 复检回执全 PASS/发现已回炉 + fresh 回归 FAIL=0

**Verification**:
- [ ] V-4.1: 复检回执 checkpoint 在位含逐条 PASS/FAIL（映射 VC-2/VC-3 复核）
- [ ] V-4.2: fresh 回归 FAIL=0

Status: `pending` Last verified: —

---

### Phase 5: Delivery

**Goal**: 合并回主仓+三位部署 diff=0+归档

**Depends on**: Phase 4

**Done when**:
- [ ] smart-merge-back 完成 + 部署位 diff=0 + check-complete exit 0 + 归档

**Verification**:
- [ ] V-5.1: VC-5 部署 diff=0 + git log 含 scope 提交
- [ ] V-5.2: check-complete.sh exit 0

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
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
对照 Verification Contract 逐条复验（终验时逐条补 PASS/FAIL 与证据锚）：
- VC-1: {evidence} → PASS/FAIL
- VC-2: {evidence} → PASS/FAIL
- VC-3 ~ VC-6: 同上逐条复验

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
