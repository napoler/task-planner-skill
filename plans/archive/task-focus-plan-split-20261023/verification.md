# Verification Contract & Phase Gates

## Goal (1 sentence)

为 task-planner 技能体系新增 Rule 94「任务专注性与计划隔离纪律」：规则正文落入 task-discipline 卫星、全仓级联锚同步、selftest 零回归、worktree 合并回 master——全部可在仓内 grep/脚本复验。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: Rule 94 正文在归属卫星在位且完整（`### 94 任务专注性与计划隔离` + 94.1-94.6 六子条）
  Evidence: grep 计数输出落 progress.md
  **Verify command**: grep -c "^### 94 任务专注性与计划隔离" skills/task-discipline/references/critical-rules-discipline.md && grep -cE "^- \*\*94\.[1-6]" skills/task-discipline/references/critical-rules-discipline.md
- [ ] VC-2: 全仓级联锚同步——活跃字面 1-93→1-94（主 SKILL.md L9/L17/L196/L209/L251、核心 critical-rules.md 枚举、discipline SKILL.md 4 处计数+枚举、CLAUDE.md、README_zh.md、planner README.md、ARCHITECTURE.md）；历史注释行 1-93 保留（WF-10 锚依赖）
  Evidence: 逐文件 grep 命中清单落 progress.md
  **Verify command**: grep -c "Rules 1-94" skills/task-planner/SKILL.md CLAUDE.md README_zh.md skills/task-planner/docs/ARCHITECTURE.md && grep -c "90,92,93\|90,92,93,94\|93,94" skills/task-planner/references/critical-rules.md
- [ ] VC-3: selftest 全量零回归
  Evidence: run-selftests.sh 输出原文落 progress.md
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh
- [ ] VC-4: Rule 编号制度面配对（reserved+landed）
  Evidence: 账本 grep 输出落 progress.md
  **Verify command**: grep -c '"rule":94' plans/.rule-reservations.jsonl
- [ ] VC-5: worktree 合并回完成且清理（master 含 merge commit、worktree 已移除、主仓 Read 复验在位）
  Evidence: git log + git worktree list 输出落 progress.md
  **Verify command**: git log --oneline -3 && git worktree list
- [ ] VC-6: 行为面指针接线——主 SKILL.md 用户新指令段含 Rule 94 指针句 + 召回卡含 94 蒸馏行
  Evidence: grep 输出落 progress.md
  **Verify command**: grep -n "Rule 94" skills/task-planner/SKILL.md && grep -n "（Rule 94）" skills/task-discipline/references/execution-recall-card.md

---

## Phase Gates

### Phase 1: 需求与调研（级联面侦察+规则定稿）

**Goal**: 用户原话逐字落盘+级联面侦察结论落盘+规则 94 文本定稿

**Depends on**: none

**Done when**:
- [ ] user-session-log.md #1 在位；检查点 01-explore-cascade.md 含 1-7 项结论；findings.md 回填四条

**Verification** (run before moving on):
- [ ] V-1.1: 检查点文件在位且含判例 diff 文件清单（→VC-1 材料面）
- [ ] V-1.2: findings.md §Research Findings 含级联面/破裂锚/归属裁决四条（Rule 19.1）

Status: `in_progress` Last verified: 2026-10-23

---

### Phase 2: worktree 内实施（规则正文+级联锚+指针接线）

**Goal**: Rule 94 正文+召回卡行+9 文件级联锚+SKILL 指针句全部落地 worktree

**Depends on**: Phase 1

**Done when**:
- [ ] CA-1..CA-10 全部执行且逐行勾核通过；worktree 内 git 逐 Phase 提交

**Verification**:
- [ ] V-2.1: VC-1 双锚（正文+六子条）grep 计数达标
- [ ] V-2.2: VC-2 级联 grep（Rules 1-94 逐文件命中）
- [ ] V-2.3: VC-6 指针句+召回卡行 grep 命中

Status: `pending` Last verified: —

---

### Phase 3: 回归验证与 Code Review

**Goal**: selftest 全绿 + critic 审查 APPROVED

**Depends on**: Phase 2

**Done when**:
- [ ] run-selftests.sh FAIL=0；critic verdict=APPROVED（CHANGES_REQUESTED→回修重跑）

**Verification**:
- [ ] V-3.1: VC-3（selftest 输出原文）
- [ ] V-3.2: CR verdict 行落 progress.md

Status: `pending` Last verified: —

---

### Phase 4: 合并回+收口交付

**Goal**: 合并回 master+land 94+归档+worktree 清理+交付总结

**Depends on**: Phase 3

**Done when**:
- [ ] 全 VC 复验 PASS；merge --no-ff 完成；worktree/分支清理；账本 landed；计划归档

**Verification**:
- [ ] V-4.1: VC-4（账本 grep ≥2 行：reserved+landed）
- [ ] V-4.2: VC-5（merge commit+worktree list 无本任务路径）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 93 判例 diff | 交付 diff 触面 vs 判例 10 文件清单（模板面豁免已登记，CR 后扩至索引表行+注释链） | 符合（触面超判例处均经 CR 闭环并 CA 登记） |
| discipline 段式 | Rule 94 段结构与 88-93 段式对照（S9 critic 五维复核） | 符合（CR APPROVED 确认） |
| 级联面侦察结论 | 实施触面 vs 侦察清单逐项对照（CA-1..CA-13 vs 检查点 01 §3/§7） | 符合（侦察未覆盖的索引表行/注释链由 CR 补全） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats plans/task-focus-plan-split-20261023
```

JSON 输出（修正 Executor 字段后终值）：
```json
{"phases_total":4,"phases_delegated":3,"main_direct_count":1,"delegation_rate":0.75,"main_direct":[{"phase":"4 合并回+收口交付","executor":"主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）"}],"violations":[],"verdict":"ok"}
```
（过程记录：首跑 verdict=violation——Phase 1 Executor 括注含「主进程」token 致机器误分类，S1 侦察实为 general-purpose 派发；按 Rule 25.4 回炉修正字段为事实口径后 rate=0.75 ok）

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单：Phase 4=①git 编排+②簿记）
- [x] 委派率 0.75 ≥ 0.7 且 stats verdict=ok

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 2 项（Q3 完成声称三条件/S8-S16 测试轮次落盘；Q6 委派率），豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:VC-1 双锚 grep（可复现）/VC-4 账本行（可 Read）/CR 复审独立复算 77（第三方复核）——均可复现
- [x] 豁免登记:无（0 项）
- [x] 存在未处置违规 → 无（CR 两轮全部闭环；verdict APPROVED）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — Rule 94 任务专注性与计划隔离纪律落地（master HEAD=cea71e9）
对照 Verification Contract 逐条复验（主仓 Read 复验 2026-10-23）：
- VC-1: grep ^### 94=1 + 94.[1-6]=6（critical-rules-discipline.md:605-615） → PASS
- VC-2: Rules 1-94（SKILL 2/CLAUDE 1/README_zh 2/README 3/ARCH 5）+77 条×2+45 条×3；活跃 1-93 残留=0（ARCH:122=演进史记录行，历史事实链非活跃声称，CR 两轮判定保留） → PASS
- VC-3: run-selftests.sh --fresh @9021b43 → Total 92 PASS=92 FAIL=0 exit 0（checkpoint 20） → PASS
- VC-4: plans/.rule-reservations.jsonl "rule":94 = 2 行（reserved+landed） → PASS
- VC-5: merge commit cea71e9 --no-ff；worktree remove+branch -d 完成；worktree list 仅余主工作树 → PASS
- VC-6: SKILL.md:174 指针句=1 + 召回卡 L39（Rule 94）=1 → PASS

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
