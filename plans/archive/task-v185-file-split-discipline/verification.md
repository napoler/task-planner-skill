# Verification Contract & Phase Gates

## Goal (1 sentence)

向 task-planner 技能补充 Rule 92「产出文件尺寸纪律与优先拆分」（task-discipline 卫星），完成 1-92 编号级联、全量回归零破坏并合并回 master。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: Rule 92 正文在位（标题=1 ∧ 子条 92.1-92.7=7）
  **Verify command**: grep -c "^### 92 产出文件尺寸纪律与优先拆分" skills/task-discipline/references/critical-rules-discipline.md && grep -cE "\*\*92\.[1-7]" skills/task-discipline/references/critical-rules-discipline.md
  Evidence: 两条 grep 输出分别=1 与 ≥7（主仓合并后终态）
- [x] VC-2: 内容覆盖 R2-R5（优先拆分/代码按引用拆/其他文件/垂直化）
  **Verify command**: sed -n "/^### 92 产出文件尺寸/,/^### 93\|$/p" skills/task-discipline/references/critical-rules-discipline.md | grep -c "优先拆分"; 同段 grep -c "引用"；同段 grep -c "垂直"；同段 grep -c "92.4 非代码文件"
  Evidence: 四个计数分别 ≥2/≥1/≥2/≥1
- [x] VC-3: 编号级联完成（1-92 ≥3 处、1-91=0、两处清单含 92）
  **Verify command**: grep -cE "(Rules )?1-92" skills/task-planner/SKILL.md; grep -c "1-91" skills/task-planner/SKILL.md skills/task-planner/README.md; grep -c "89,90,92）" skills/task-planner/SKILL.md skills/task-discipline/SKILL.md
  Evidence: 首条 ≥3；次条均 0；末条 2 与 1
- [x] VC-4: 全量回归零破坏
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | tail -3
  Evidence: 末行 `FAIL=0`（worktree 内执行，合并后主仓可复跑）
- [x] VC-5: 编号账本 landed
  **Verify command**: bash skills/task-planner/scripts/rule-reserve.sh check 92
  Evidence: 输出含 task-v185-file-split-discipline（landed 态由 list 确认）
- [x] VC-6: 合并收口干净（scope 零未提交+worktree 已清理）
  **Verify command**: git status --short | grep -v "^?? plans/" | wc -l; git worktree list | grep -c task-v185-file-split-discipline
  Evidence: 首条 scope 残留=0（plans 簿记除外）；次条=0

---

## Phase Gates

### Phase 1: 计划与隔离基线
**Goal**: 计划锁定+worktree 就绪+首锚登记
**Depends on**: none
**Done when**:
- [ ] attest exit 0+哨兵清除；worktree 创建且 resolve 解析正确
**Verification**:
- [ ] V-1.1: `resolve-plan-dir.sh $(pwd) fae73c58…` → 本计划（映射 VC-6 基线）
- [ ] V-1.2: `git -C <worktree> status` 干净且分支=wt/task-v185-file-split-discipline（映射 VC-6）
Status: `complete` Last verified: 2026-10-17

### Phase 2: Rule 92 正文与编号级联
**Goal**: 六文件编辑点全部落地（worktree）
**Depends on**: Phase 1
**Done when**:
- [ ] S1/S2/S3 产物 grep 验收全过+主进程 Read 复核
**Verification**:
- [ ] V-2.1: VC-1 命令组（映射 VC-1）
- [ ] V-2.2: VC-3 命令组（映射 VC-3）
Status: `complete` Last verified: 2026-10-17

### Phase 3: 全量回归
**Goal**: selftest 全量 FAIL=0
**Depends on**: Phase 2
**Done when**:
- [ ] run-selftests --fresh 末行 FAIL=0（或断裂锚最小修复后复跑 FAIL=0）
**Verification**:
- [ ] V-3.1: 末行汇总行粘贴 progress（映射 VC-4）
- [ ] V-3.2: 若有修复，修复点逐处登记（映射 VC-4）
Status: `complete` Last verified: 2026-10-17

### Phase 4: 合并回主仓
**Goal**: --no-ff 合并+worktree 清理
**Depends on**: Phase 3
**Done when**:
- [ ] merge commit 在 master+worktree list 无本任务
**Verification**:
- [ ] V-4.1: `git log --oneline -3` 含 merge（映射 VC-6）
- [ ] V-4.2: 主仓 Read 复验关键文件（映射 VC-1）
Status: `complete` Last verified: 2026-10-17

### Phase 5: 终验与交付
**Goal**: CR APPROVED+独立 VC 复验+簿记收口
**Depends on**: Phase 4
**Done when**:
- [ ] 六项 VC 全 PASS（Verifier 独立复验）+land 92+INDEX+归档尝试+delivery-summary
**Verification**:
- [ ] V-5.1: VC-5 check 92=landed
- [ ] V-5.2: VC-6 git 终态干净
Status: `complete` Last verified: 2026-10-17

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| Rule 88-90 落位范式 | Rule 92 标题/子条/L0-T 机制条格式比对 | （终验填） |
| 级联面清单 | VC-3 命令组实跑 | （终验填） |
| 编号台账 | VC-5 check 92 实跑 | （终验填） |

## 委派统计复验（Rule 25.4）

```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v185-file-split-discipline
```

JSON 输出（16:05 实跑）：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"main_direct":[{"phase":"1 计划与隔离基线","reason":"例外理由:① 纯 git/worktree 编排 ② 计划系统文件维护——Rule 25.3 白名单①②"},{"phase":"4 合并回主仓","reason":"例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单①"},{"phase":"5 终验与交付","reason":"mini）（终验核查子代理；主进程簿记走白名单②"}],"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 Phase 均登记白名单内例外理由（Phase 1=①②、Phase 4=①；Phase 5 主体=Verifier 子代理，主进程仅簿记）
- [x] stats verdict=**ok**，violations=[]（16:05 实跑）

## 质量门控统计（Rule 26）
- [x] Q1 VC 复验：6/6 PASS（Verifier 独立实跑）；Q2 Test Results：progress 各 Phase 段已填；Q3 Evidence 抽查 ≥3：Rule 92 尾部 diff（S1）+8 grep（S2）+91/91 汇总（S4）均一手可复现；Q4 Handoff verify_done：7 行全勾（Read+回填双条件）；Q5 委派：stats verdict=ok；Q6 批量：n/a（非批量）
- [x] Evidence 抽查记录：findings §S1/S2/S3 回执+§Verifier 回执
- [x] 豁免登记：无
- [x] 未处置违规：无

## Goal Gate (终验)

```
## Goal Verification — Rule 92 落地+级联 1-92+回归绿+合并收口
- [x] VC-1: 标题=1 ∧ 92.1-92.7=7（S5 实跑）→ PASS
- [x] VC-2: 优先拆分 3/引用 4/垂直 6/92.4=1 → PASS
- [x] VC-3: 1-92=3、1-91=0×2、清单 92=2/1/1 → PASS
- [x] VC-4: Total: 91 PASS=91 FAIL=0（S4 实跑+主进程抽查×4）→ PASS
- [x] VC-5: rule 92 landed by task-v185-file-split-discipline → PASS
- [x] VC-6: skills/ 零未提交+worktree list=0+merge 73ce9ec 在 log → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过；CR APPROVED；align P1 已修正复验中（复验 APPROVED 即终态）。

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| Rule 88-90 落位范式 | Rule 92 标题/建制/子条/L0-T 机制条格式与 90 段逐面对照（CR 维度 3） | 符合 |
| 级联面清单 | VC-3 命令组实跑 6/6 | 符合 |
| 编号台账 | rule-reserve check 92=landed | 符合 |

---

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 5 终验（见 task_plan.md Current Phase） |
| 2 | Where am I going? | align 复验收口→check-complete→归档→交付 |
| 3 | What's the goal? | Goal 段（Rule 92+级联+回归+合并） |
| 4 | What have I learned? | findings.md |
| 5 | What have I done? | progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（他任务，不属本计划） |
