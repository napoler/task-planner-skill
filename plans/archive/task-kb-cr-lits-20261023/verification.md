# Verification Contract & Phase Gates

## Goal (1 sentence)

修完 task-kb-deploy-20261022 CR 复审登记的 L-1~L-8 全部 8 项，全量 selftest 零回归，CR 通过后合并 master、三位部署位同步并推送 origin。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence. 工作目录 WT=/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023

- [x] VC-1:（终验 PASS 2026-10-23） L-1 check-delegation.sh 两处保护区清单 k8s glob 口径一致（两侧均列 .k8s/ 与 k8s/ 双形态）
  **Verify command**: `cd $WT && grep -n 'k8s' skills/task-planner/scripts/check-delegation.sh`
  Evidence: 两清单行（④c is_protected_path 函数内 vs ④b mini 分支 case 内）逐行对照，k8s glob 集合相同
- [x] VC-2:（终验 PASS 2026-10-23） L-2 check-tier-consistency.sh LANE 精确解析——`execution_lane: L0-E` 2-Phase 夹具 exit 0；`L0` 2-Phase 夹具 exit 1（守卫不回退）；`L0-T` 单 Phase+scope12 文件夹具 exit 0（L0T cap 生效）且 L0-T 2-Phase 夹具 exit 1（单 Phase cap 不回退，L-2 最小修口径=仅 L0-E 豁免）
  **Verify command**: `cd /mnt/data/dev/task-planner-skill && for f in plans/task-kb-cr-lits-20261023/fixtures/vc2-l0e plans/task-kb-cr-lits-20261023/fixtures/vc2-l0 plans/task-kb-cr-lits-20261023/fixtures/vc2-l0t plans/task-kb-cr-lits-20261023/fixtures/vc2-l0t2ph; do bash skills/task-planner/scripts/check-tier-consistency.sh $f >/dev/null 2>&1; echo "$f exit=$?"; done`（期望 l0e=0, l0=1, l0t=0, l0t2ph=1；夹具=worktree 删除前迁至本计划目录 fixtures/）
  Evidence: 四组 exit code 记录 progress.md Test Results 段
- [x] VC-3:（终验 PASS 2026-10-23） L-3 selftest-requirement-coverage.sh 含 51.13 守护断言 RC-28 且全绿；L-4 头注计数=实际最大 RC 号
  **Verify command**: `cd $WT && bash skills/task-planner/scripts/selftest-requirement-coverage.sh | tail -1 && head -12 skills/task-planner/scripts/selftest-requirement-coverage.sh | grep -c 'RC-01..RC-28'`（期望末行 `Total: 28 PASS=28 FAIL=0`，grep=1）
  Evidence: 末行输出 + 头注行
- [x] VC-4:（终验 PASS 2026-10-23） L-5 README.md 与 docs/ARCHITECTURE.md 规则计数=实测唯一规则编号数（实测后同步，非拍脑袋）
  **Verify command**: `cd $WT && grep -oE '^### [0-9]+' skills/*/references/critical-rules-*.md | grep -oE '[0-9]+' | sort -un | wc -l && grep -n '条已按域迁移\|条规则\|74' skills/task-planner/README.md skills/task-planner/docs/ARCHITECTURE.md | head`（首行=实测值 N，后两处文档表述=N 且旧值 74 零残留）
  Evidence: 实测 N 值落 progress.md + 两文件 diff 仅计数词变化
- [x] VC-5:（终验 PASS 2026-10-23） L-6 init.cjs 无「跳过计划门控」失准文案且新文案含真语义锚；L-7 check-scope 机械产物判定单函数复用；L-8 三 nit 闭环；全量 selftest FAIL=0
  **Verify command**: `cd $WT && grep -c '跳过计划门控' skills/task-planner/scripts/task-plan-init.cjs; grep -c '_is_mechanical_artifact' skills/task-planner/scripts/check-scope.sh; for s in skills/task-planner/scripts/selftest-*.sh; do bash $s >/dev/null 2>&1 || echo "FAIL $s"; done`（期望 0 / ≥3 / 无 FAIL 行）
  Evidence: 三组输出 + progress.md L-8 逐项关闭记录
- [x] VC-6:（终验 PASS 2026-10-23） 收口链——合并提交在位 + 三位部署 diff（zcode=0；claude/cursor 仅 9 flavor 内）+ origin/master 与本地一致
  **Verify command**: `cd /mnt/data/dev/task-planner-skill && git log --oneline -3 master && git status -sb | head -1 && for loc in ~/.zcode ~/.claude ~/.cursor; do diff -rq skills/task-planner $loc/skills/task-planner 2>/dev/null | grep -v flavor || echo "$loc clean-or-flavor-only"; done`（期望：合并 commit 在位、`master...origin/master` 无 ahead/behind、zcode 位无 diff 或仅 flavor 文件）
  Evidence: progress.md 终态段三行命令输出

---

## Phase Gates

### Phase 1: 修复（worktree 内 S1..S7 并行）

**Goal**: 8 项修复在 worktree 内完成，逐 S-unit 留痕 commit

**Depends on**: none（worktree 已由主进程建成）

**Done when**:
- [ ] S1-S7 检查点齐（subagent-state/1..7-*.md）+ 主进程 Read 抽查 PASS
- [ ] 逐 S-unit commit（只 add scope 文件）

**Verification** (run before moving on):
- [ ] V-1.1: 映射 VC-1,VC-2,VC-5 —— S1/S2/S3/S4/S5 修复点 grep 断言 PASS
- [ ] V-1.2: 映射 VC-3,VC-4 —— S6/S7 修复点断言 PASS（selftest 28/28 + 头注 + 计数实测）

Status: `pending` Last verified: —

---

### Phase 2: 回归

**Goal**: 全量 selftest + 夹具零回归

**Depends on**: Phase 1

**Done when**:
- [ ] 全量 selftest-*.sh FAIL=0 + tier 三夹具 exit 符合期望 + scope 夹具 PASS

**Verification**:
- [ ] V-2.1: 映射 VC-2 —— 三夹具复跑 exit code 记录
- [ ] V-2.2: 映射 VC-5 —— 全量 selftest 无 FAIL 行

Status: `pending` Last verified: —

---

### Phase 3: CR 门控

**Goal**: 独立 diff 审查 APPROVED + 文档面 alignment 通过

**Depends on**: Phase 2

**Done when**:
- [ ] Code Reviewer 裁决 APPROVED（0 Blocker；NIT 项登记不阻断）
- [ ] alignment-review 文档面（README/ARCHITECTURE）结论在检查点

**Verification**:
- [ ] V-3.1: 映射 VC-5 —— CR 检查点 subagent-state/9-s9-cr.md 含裁决行
- [ ] V-3.2: 映射 VC-6 —— 收口前置条件（三条件）逐条核对

Status: `pending` Last verified: —

---

### Phase 4: 收口（合并/部署/推送/归档）

**Goal**: master 合并 + 三位部署 + push origin + 归档

**Depends on**: Phase 3

**Done when**:
- [ ] smart-merge-back 合并 + --deploy 三位 + diff 复验 + `git push origin master` + worktree/分支清理 + archive-plan

**Verification**:
- [ ] V-4.1: 映射 VC-6 —— 收口链命令组输出（log/diff/status 三行）
- [ ] V-4.2: 映射 VC-6 —— origin/master==本地 master（`git status -sb` 无 ahead/behind）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| findings.md L-1~L-8 登记原文 | 8 项修复逐条对照「待修方向」列 | 终验填写 |
| 10-22 口径①修复先例 | L-6 文案不回退哨兵写入 | 终验填写 |
| L0-E 权重 0 口径 | L-2 L0-E 豁免判定 | 终验填写 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-kb-cr-lits-20261023
```

JSON 输出：
```json
{终验粘贴}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Phase 4=①git 编排+②簿记）
- [ ] 委派率 ≥ floor(0.7) 或含白名单外理由 → 回炉

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成
- [ ] Evidence 抽查 ≥3 条
- [ ] 未处置违规 → 按 26.3 降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 修完 L-1~L-8 + 收口链
对照 Verification Contract 逐条复验（终验时逐行补 PASS/FAIL+证据锚）：
- VC-1: 两清单 k8s 双 glob 同列 → PASS/FAIL
- VC-2: 三夹具 exit（0/1/0）→ PASS/FAIL
- VC-3: Total: 28 PASS=28 + 头注 → PASS/FAIL
- VC-4: 计数=实测 N → PASS/FAIL
- VC-5: 文案 0 残留 + 单函数 ≥3 + selftest 全绿 → PASS/FAIL
- VC-6: 合并/部署/推送三行 → PASS/FAIL
 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。
**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出。
**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作由独立子代理执行，主进程仅编排与簿记（Rule 33.3 延伸）

---

## 全量终验（L0 门① Total 锚）
- 执行体：S8 全量回归（检查点 subagent-state/8-s8-regression.md）
- 命令：worktree 内逐脚本 `for f in skills/task-planner/scripts/selftest-*.sh; do bash "$f"; done`（2026-10-23，交付前 fresh 全量）
- 结果：Total: 92 PASS=92 FAIL=0（断言 1271）；tier 五夹具 0/1/0/1/1 全中；check-scope 最小场景 8/8
- 对应 VC：VC-5 全量段

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 |
| 2 | Where am I going? | Phase 1→4 + 终验 |
| 3 | What's the goal? | 修 L-1~L-8 全 8 项 + 收口链 |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
