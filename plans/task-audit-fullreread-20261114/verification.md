# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 技能体系将「审核阶段（独立复检）由全新子代理重读被修改文件全文并做整体分析」绑定落地为条款——修订 103.3/103.5+SKILL.md 3h 指针+106.1b 分工指针，全量回归零新增 FAIL。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: 审计报告在位：verdict+五要素判定表+≥6 条证据+合理性分析
  Evidence: plans/task-audit-fullreread-20261114/checkpoints/audit-report.md
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/audit-report.md && grep -q 'verdict' plans/task-audit-fullreread-20261114/checkpoints/audit-report.md && grep -q '五要素' plans/task-audit-fullreread-20261114/checkpoints/audit-report.md
- [ ] VC-2: 103.3 含「复检体全文回读被改文件+整体分析」义务句
  Evidence: skills/task-dispatch/references/critical-rules-dispatch.md 103.3 段
  **Verify command**: sed -n '/^103\.3 /,/^103\.4/p' skills/task-dispatch/references/critical-rules-dispatch.md | grep -q '全文回读'
- [ ] VC-3: 103.5 复检任务书含第五要素（全文回读+读取证据）
  Evidence: skills/task-dispatch/references/critical-rules-dispatch.md 103.5 段
  **Verify command**: sed -n '/^103\.5 /,/^103\.6/p' skills/task-dispatch/references/critical-rules-dispatch.md | grep -q '全文回读'
- [ ] VC-4: SKILL.md 3h 指针含全文回读表述
  Evidence: skills/task-planner/SKILL.md 3h 行
  **Verify command**: sed -n '/3h 双轮质检/p' skills/task-planner/SKILL.md | grep -q '全文回读'
- [ ] VC-5: Rule 106 家族含 106.1b 审核阶段分工交叉引用
  Evidence: skills/task-discipline/references/critical-rules-discipline.md 106.1b 段
  **Verify command**: sed -n '/106\.1b/,/^106\.2/p' skills/task-discipline/references/critical-rules-discipline.md | grep -q '103.3'
- [ ] VC-6: 全量 selftest 零新增 FAIL（当前 FAIL 数 ≤ 基线，基线=checkpoints/baseline-selftest.txt 记录值）
  Evidence: plans/task-audit-fullreread-20261114/checkpoints/baseline-selftest.txt + 回归输出（progress.md）
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/baseline-selftest.txt && test "$(cat plans/task-audit-fullreread-20261114/checkpoints/baseline-selftest.txt)" -ge "$(for t in skills/task-planner/scripts/selftest-*.sh; do bash "$t" >/dev/null 2>&1; done; for t in skills/task-planner/scripts/selftest-*.sh; do bash "$t" 2>/dev/null; done | grep -c 'FAIL')"
- [ ] VC-7: 合并回后越界自检：主仓合并 commit 仅含 scope 文件（三语料+plans/）
  Evidence: git show <merge-commit> --name-only 输出（progress.md 留痕）
  **Verify command**: ! git show --name-only --format= HEAD | grep -vE '^skills/(task-dispatch/references/critical-rules-dispatch\.md|task-discipline/references/critical-rules-discipline\.md|task-planner/SKILL\.md)|^plans/' | grep -q .

---

## Phase Gates

### Phase 1: 审计与基线固结

**Goal**: 五要素三态判定落盘+主仓 selftest 基线记录

**Depends on**: none

**Done when**:
- [ ] 审计报告+基线记录落盘

**Verification** (run before moving on):
- [ ] V-1.1: 审计报告在位（→VC-1）
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/audit-report.md && grep -q 'verdict' plans/task-audit-fullreread-20261114/checkpoints/audit-report.md
- [ ] V-1.2: 基线记录落盘（→VC-6 前置）
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/baseline-selftest.txt

Status: `in_progress` Last verified: 2026-11-14

---

### Phase 2: worktree 创建与隔离基线

**Goal**: worktree 就绪+worktree 内基线与主仓基线一致+级联面枚举落盘

**Depends on**: Phase 1

**Done when**:
- [ ] worktree 在位+基线一致+级联面清单落盘

**Verification**:
- [ ] V-2.1: worktree 在位
  **Verify command**: git worktree list | grep -q task-audit-fullreread-20261114
- [ ] V-2.2: 级联面枚举清单落盘
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/cascade-surface.md

Status: `pending` Last verified: —

---

### Phase 3: 条款修订实施（CA-1~CA-4，worktree 内）

**Goal**: 四锚位条款增量落地且段结构无损

**Depends on**: Phase 2

**Done when**:
- [ ] CA-1~CA-4 全部落地+106.1a 段清单守恒

**Verification**:
- [ ] V-3.1: 103.3 义务句在位（→VC-2）
  **Verify command**: sed -n '/^103\.3 /,/^103\.4/p' skills/task-dispatch/references/critical-rules-dispatch.md | grep -q '全文回读'
- [ ] V-3.2: 103.5 第五要素在位（→VC-3）
  **Verify command**: sed -n '/^103\.5 /,/^103\.6/p' skills/task-dispatch/references/critical-rules-dispatch.md | grep -q '全文回读'
- [ ] V-3.3: 3h 指针刷新（→VC-4）
  **Verify command**: sed -n '/3h 双轮质检/p' skills/task-planner/SKILL.md | grep -q '全文回读'
- [ ] V-3.4: 106.1b 在位（→VC-5）
  **Verify command**: sed -n '/106\.1b/,/^106\.2/p' skills/task-discipline/references/critical-rules-discipline.md | grep -q '103.3'

Status: `pending` Last verified: —

---

### Phase 4: 独立复检与全量回归

**Goal**: 新条款 dogfood 复检 APPROVED+回归 FAIL≤基线

**Depends on**: Phase 3

**Done when**:
- [ ] 复检回执 APPROVED+回归对照基线通过

**Verification**:
- [ ] V-4.1: 独立复检回执 APPROVED（含全文回读证据）
  **Verify command**: grep -q 'APPROVED' plans/task-audit-fullreread-20261114/checkpoints/recheck-report.md
- [ ] V-4.2: 回归 FAIL≤基线（→VC-6）
  **Verify command**: test "$(cat plans/task-audit-fullreread-20261114/checkpoints/baseline-selftest.txt)" -ge "$(for t in skills/task-planner/scripts/selftest-*.sh; do bash "$t" 2>/dev/null; done | grep -c 'FAIL')"

Status: `pending` Last verified: —

---

### Phase 5: 合并回+部署+push+归档交付

**Goal**: 主仓越界自检过+部署位同步+三仓 push+归档

**Depends on**: Phase 4

**Done when**:
- [ ] VC-7 过+部署 diff 留痕+归档完成

**Verification**:
- [ ] V-5.1: 越界自检（→VC-7）
  **Verify command**: ! git show --name-only --format= HEAD | grep -vE '^skills/(task-dispatch/references/critical-rules-dispatch\.md|task-discipline/references/critical-rules-discipline\.md|task-planner/SKILL\.md)|^plans/' | grep -q .
- [ ] V-5.2: 部署位逐对 diff 判向留痕
  **Verify command**: test -s plans/task-audit-fullreread-20261114/checkpoints/deploy-diff.txt

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
