# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

图片 QC 门条款（media Rule 47.6 与 companion 图/视频执行体 SOP）扩容出「硬约束逐条核验门 + 常识认知缺陷类目 + 先取证后判定」，并同步源仓与全部 12 处部署位 diff=0，使空间布局常识错误与硬约束违反类基础错误在 QC 环被强制拦截。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- VC-1: 47.6 条款扩容在位——media rules 含「硬约束逐条核验门」（清单提取+逐条 PASS/FAIL 留痕+任一 FAIL 禁入候选）与常识类目（空间布局/场景构成/物件功能），47.6a/b/c 三子条可 Read 复核
  **Verify command**: grep -c "硬约束逐条核验门" skills/media-planner/references/critical-rules-media.md | grep -qv '^0$' && grep -oE "空间布局|场景构成|物件功能" skills/media-planner/references/critical-rules-media.md | wc -l
  Evidence: 命令输出（首个 grep ≥1，类目计数 ≥3）+ Read 47.6 段行号
- VC-2: SRC 图/视频执行体 SOP 同族条款在位——两文件各含 47.6 块与「硬约束逐条核验门」
  **Verify command**: for f in skills/task-planner/companion/agents/image-generation-executor.md skills/task-planner/companion/agents/video-generation-executor.md; do grep -c "硬约束逐条核验门" "$f"; done
  Evidence: 两文件计数均 ≥1 + Read 47.6 块在位
- VC-3: 全量回归零新增 FAIL——worktree 内 selftest FAIL 数 ≤ master 预跑基线（基线值记录于 progress.md）
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tail -5
  Evidence: 套件输出 FAIL 计数与 progress.md 基线对照行
- VC-4: 12 处部署位 diff=0——6 agents 位 body 对齐+3 companion 副本 md5 一致+3 media-planner 副本 md5 一致，frontmatter 逐位保留
  **Verify command**: diff /home/terry/.zcode/agents/image-generation-executor.md <worktree>/skills/task-planner/companion/agents/image-generation-executor.md | head -3
  Evidence: subagent-state/07-deploy-audit.md 对账表 12 行全绿（逐位 diff 输出摘要）
- VC-5: 条款质量独立复检无 BLOCKER——全新 general-reviewer 复检三文件条款 diff，两缺陷判据可拦截判定成立
  **Verify command**: cat <plan-dir>/subagent-state/05-reviewer-verdict.md | grep -c BLOCKER
  Evidence: 复检回执文件（verdict=APPROVED 且 BLOCKER 计数=0）
- VC-6: master 合并后主仓复验在位——merge commit 存在且主仓文件含新条款
  **Verify command**: git log --oneline -3 && grep -c "硬约束逐条核验门" skills/media-planner/references/critical-rules-media.md
  Evidence: git log 显示 merge commit + 主仓 grep ≥1

---

## Phase Gates

### Phase 1: 取证收口（Requirements & Discovery）

**Goal**: 双路取证回收+findings 回填+S0 网络评估，条款设计输入齐备。

**Depends on**: none

**Done when**:
- [ ] findings.md Research Findings 含 [cp-01]/[cp-02] 两段+R 区块+S0 评估登记

**Verification** (run before moving on):
- [ ] V-1.1: findings.md 两取证段在位（映射 VC-1 判据输入） — `grep -c "cp-01-explore\|cp-02-analyst" <plan-dir>/findings.md` ≥2
- [ ] V-1.2: S0 网络评估结论落 findings（映射 VC-5 复检判据输入） — `grep -c "75.15\|S0" <plan-dir>/findings.md` ≥1

Status: `in_progress` Last verified: 2026-11-06

---

### Phase 2: 隔离与冲突扫描（Planning & Structure）

**Goal**: worktree 建立且三文件与主仓一致，部署位基底判向完成。

**Depends on**: Phase 1

**Done when**:
- [ ] worktree 就位+初建对账记录+部署位基底块 Read 登记

**Verification**:
- [ ] V-2.1: worktree 三文件与 master diff 为空 — `git -C <worktree> diff master --stat -- <三文件>` 空
- [ ] V-2.2: 部署位基底判向记录落 progress.md — `grep -c "判向" <plan-dir>/progress.md` ≥1

Status: `pending` Last verified: —

---

### Phase 3: 源仓条款修订（Implementation）

**Goal**: 三文件增量插入 47.6a/b/c 且回归零新增 FAIL。

**Depends on**: Phase 2

**Done when**:
- [ ] S1-S4 完成，VC-1/VC-2 grep 命中，VC-3 回归对照基线

**Verification**:
- [ ] V-3.1: media rules 条款在位（VC-1 命令） — `grep -c "硬约束逐条核验门" skills/media-planner/references/critical-rules-media.md` ≥1
- [ ] V-3.2: 双 agent SOP 条款在位（VC-2 命令） — 两文件 grep ≥1
- [ ] V-3.3: 回归 FAIL ≤ 基线（VC-3） — run-selftests --fresh 输出对照 progress 基线行

Status: `pending` Last verified: —

---

### Phase 4: 独立复检与合并回（Testing & Verification）

**Goal**: general-reviewer 复检无 BLOCKER，全 VC 复验通过后合并回 master。

**Depends on**: Phase 3

**Done when**:
- [ ] S5 复检回执 APPROVED；S6 merge commit 落 master 且主仓复验在位

**Verification**:
- [ ] V-4.1: 复检回执无 BLOCKER（VC-5） — `grep -c BLOCKER subagent-state/05-reviewer-verdict.md` =0
- [ ] V-4.2: 主仓条款在位（VC-6） — `git log --oneline -1` 含 merge + 主仓 grep ≥1

Status: `pending` Last verified: —

---

### Phase 5: 部署同步与收尾交付（Delivery）

**Goal**: 12 部署位 diff=0，六文档回读收敛，check-complete exit 0 后归档。

**Depends on**: Phase 4

**Done when**:
- [ ] S7-S13 完成；84.14 回读收敛出口达成；归档完成

**Verification**:
- [ ] V-5.1: 部署对账表全绿（VC-4） — `grep -c "diff=0\|md5 一致" subagent-state/07-deploy-audit.md` ≥12
- [ ] V-5.2: 收尾门通过 — `bash <skill>/scripts/check-complete.sh <plan-dir>` exit 0

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
## Goal Verification — 图片 QC 门条款扩容+12 位部署收敛
对照 Verification Contract 逐条复验（VC-1 ~ VC-6 全量，2026-11-06 终验）：
- VC-1: media rules 硬约束=1/类目词=3/47.6[abc]=3（grep 实测）→ PASS
- VC-2: 双 agent SOP grep 各=1+47.6 块完整（S2/S3 复核）→ PASS
- VC-3: worktree 94/96 vs master 94/96 零新增 FAIL（06-s4-regression.md）→ PASS
- VC-4: 12+3 部署位 md5 全绿（07-deploy-audit.md）→ PASS
- VC-5: 复检 VERDICT: APPROVED 零 BLOCKER（05-reviewer-verdict.md）→ PASS
- VC-6: merge 0508586+主仓三文件 grep 各=1 → PASS

 outcome: COMPLETE
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
