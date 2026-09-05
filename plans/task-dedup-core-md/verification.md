# Verification Contract & Phase Gates

## Goal (1 sentence)

消除 task-planner 三核心文档重复：Chain Handoff Contract 与 Read-vs-Write 决策矩阵各收敛到唯一权威源，删除过期 WORKFLOW.md 及其全部活引用，经 worktree 隔离合并回 master。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Chain Handoff Contract 规范全文仅存 reference.md；SKILL.md 为指针 stub
  Evidence: 主仓 `grep -c verification_cmd skills/task-planner/SKILL.md` = 0；reference.md = 3；SKILL.md:327 stub 锚点指向真实标题「Chain Handoff Contract」（Read 主仓 :318-333 复核）
- [x] VC-2: Read-vs-Write 决策矩阵全文表仅存 SKILL.md（Rule 20.5 节）
  Evidence: 主仓 `grep -c "何时读/写文件" skills/task-planner/reference.md` = 0；SKILL.md 决策矩阵节 grep = 1
- [x] VC-3: WORKFLOW.md 已删除且 3 文件 4 处活引用清零
  Evidence: `ls skills/task-planner/WORKFLOW.md` = No such file；`grep -rln WORKFLOW skills/task-planner/`（主仓）无输出
- [x] VC-4: SKILL.md 对 reference.md 的两处描述与该文件实际内容一致
  Evidence: SKILL.md:8（frontmatter）与 :333（References 表）均为「Manus 原则 + 3-Strike + 5Q + Chain Handoff 合约 + Chain 重规划触发」，不再声称含 决策矩阵/Scope Guard
- [x] VC-5: 主仓 --no-ff 合并 + worktree/分支清理完成
  Evidence: 主仓 merge commit **5228d06**（ort，6 files, +6/−117，WORKFLOW.md delete mode 确认）；`git worktree list` 仅剩主仓；`wt/task-dedup-core-md` 分支已删（Deleted branch … was aaa1c5d）；主仓 status 仅剩既有未跟踪计划文件（.zcode//plans//progress.md）

---

## Phase Gates

### Phase 1: 隔离区建立与计划初始化

**Goal**: 计划落盘+锁定，worktree 隔离区就绪。

**Depends on**: none

**Done when**:
- [x] init-session 5 文件就绪、conflict 扫描安全（exit 0）、attest 锁定（eed2114d…）、worktree @ master ad7900d 建立、S1 Todo 映射

**Verification**:
- [x] V-1.1: check-conflicts.sh exit 0（仅信号①计划类未跟踪文件）→ VC-5 前置
- [x] V-1.2: git worktree add 成功（HEAD ad7900d）

Status: `complete` Last verified: 2026-09-05

---

### Phase 2: 三处去重编辑（worktree 内）

**Goal**: E1/E2/E3 去重编辑落地且 VC-1~VC-4 在 worktree 内验证通过。

**Depends on**: Phase 1

**Done when**:
- [x] SKILL.md 收敛+描述修正、reference.md 删决策矩阵、WORKFLOW.md 删除+引用清理

**Verification**:
- [x] V-2.1: grep 复验 8 项全过（见 progress.md Phase 2 Test Results 表）
- [x] V-2.2: bash -n install-stub.sh = syntax-ok；tests/smoke.sh **17 pass / 0 fail**

Status: `complete` Last verified: 2026-09-05

---

### Phase 3: 复验、合并回与清理

**Goal**: master 收到合并、隔离区清理、终验交付。

**Depends on**: Phase 2

**Done when**:
- [x] merge commit 5228d06、worktree remove、branch -d、主仓 Read+grep 复验

**Verification**:
- [x] V-3.1: VC-5 全部证据（见上）
- [x] V-3.2: check-complete.sh exit 0（见下方终验记录）

Status: `complete` Last verified: 2026-09-05

---

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| SKILL.md / reference.md / WORKFLOW.md / critical-rules.md 原文 | 去重判定与行号证据一一对照（findings.md §1） | 符合 |
| references/worktree-isolation.md §3/§4 | worktree 路径=集中目录规范 `<repo-parent>/<repo>-worktrees/<task-id>`；合并回 5 条款逐条满足 | 符合 |

## 委派统计复验（Rule 25.4）

- [x] 委派率已统计：子代理执行 Phase 0 / 总数 3
- [x] 主进程直做 Phase 均在计划 Executor 字段登记例外理由（P1 git 编排+计划白名单 / P2 .md 文档白名单+install-stub.sh 仅 2 处字面量（Rule 14 禁改清单不含 .sh）/ P3 git 编排+终验白名单）
- [x] 委派率 <50% 但**均有登记理由** → 不触发 PARTIAL 降级（Rule 25.4 条款为"<50% **且无登记理由**"）

## 质量门控统计（Rule 26）

- [x] Q1-Q6 逐项核查：触发 0 项，豁免 0 项，未处置 0 项
  - Q1 VC 复验：5/5 全勾且 Evidence 非空；Q2 Test Results 全填（非批量）；Q3 抽查 3 条——① 5228d06 diff stat 可复现 ② SKILL.md:327 Read 可见 ③ smoke 17 pass 输出在案，均可复现；Q4 本任务无子代理派发，Handoff 登记表已标注"无派发"；Q5 见委派统计复验；Q6 非批量任务，无 Batch Report 义务
- [x] Evidence 抽查 ≥3 条：路径可 Read、结论可复现（抽查记录见 progress.md Phase 3）
- [x] 豁免登记：无
- [x] 无未处置违规 → 不触发 Rule 26.3 降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 三核心文档去重(Chain Handoff/决策矩阵/WORKFLOW.md)
对照 Verification Contract 逐条复验：
- [x] VC-1: 主仓 grep SKILL.md verification_cmd=0;reference.md=3;stub :327 → PASS
- [x] VC-2: 主仓 grep reference.md 何时读/写文件=0;SKILL.md 节在 → PASS
- [x] VC-3: 文件已删;活引用 grep 无输出 → PASS
- [x] VC-4: SKILL.md:8/:333 Read 复核修正到位 → PASS
- [x] VC-5: merge 5228d06;worktree list 仅主仓;分支已删 → PASS

 outcome: COMPLETE
```

**遗留（不影响 COMPLETE 判定，均为本轮范围外的独立发现）**：
1. 9 实体部署副本仍为 ad7900d 基线 —— 本去重要在部署位生效需**显式重部署**（cp -rL + diff -r 复验），留用户决策
2. SKILL.md frontmatter references 列表缺 cost-control.md / batch-quality-gate.md 两条（清单不一致）
3. critical-rules.md Rule 10「详见 reference.md § 重规划触发」悬空
4. SKILL.md §任务模板库 与 template-mapping.md 决策树/互斥表部分重复且表述分化
5. Rule 14 禁改清单不含 .sh（规格缺口）；plans/INDEX.md 的 task-active-plan 过期索引待核销

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | 已交付（outcome: COMPLETE） |
| 2 | Where am I going? | 无剩余 Phase；仅遗留项待用户决策 |
| 3 | What's the goal? | 见上方 Goal |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（task-active-plan 过期索引待核销） |
