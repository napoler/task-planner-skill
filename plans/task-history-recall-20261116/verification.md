# Verification Contract & Phase Gates — task-history-recall-20261116

## Goal (1 sentence)

新建 plan-history-recall 技能全家桶并完成实测/回归/部署/合并收口，使规划期可按需从 plans/+git 历史产出证据锚齐全的经验简报。

---

## Verification Contract (6 items, objective standards)

> 命令相对仓根执行；worktree 阶段在 worktree 内执行同构命令。基线：master 既有预存 selftest FAIL=5（实测 2026-11-16=baseline-selftest.log；判据=无新增，FAIL 集合 ⊆ 基线集合）。

- [ ] VC-1: 6 交付物在位且 frontmatter 合规（SKILL.md/references 两文件/history-miner.md/接线行/selftest 脚本+registry 行）
  Evidence: 盘上文件+grep 锚回执
  **Verify command**: test -f skills/plan-history-recall/SKILL.md && test -f skills/plan-history-recall/references/experience-card-schema.md && test -f skills/plan-history-recall/references/brief-template.md && test -f skills/task-planner/companion/agents/history-miner.md && test -f skills/task-planner/scripts/selftest-plan-history-recall.sh && grep -q '^name: plan-history-recall' skills/plan-history-recall/SKILL.md && grep -q '^name: history-miner' skills/task-planner/companion/agents/history-miner.md && grep -q '^selftest-plan-history-recall.sh' skills/task-planner/scripts/selftest-registry.tsv
- [ ] VC-2: dogfood 全链实测反造谣门——history-brief.md 存在且 ≥3 条证据锚盘上命中
  Evidence: plans/task-history-recall-20261116/history-recall/history-brief.md + 抽查回执
  **Verify command**: test -s plans/task-history-recall-20261116/history-recall/history-brief.md && grep -qE 'plans/(archive/)?task-[a-z0-9-]+/[a-z-]+\.md:[0-9]+' plans/task-history-recall-20261116/history-recall/history-brief.md
- [ ] VC-3: 成本护栏硬数字在 SKILL.md 落字可 grep（候选 ≤8/每代理 ≤3 任务/简报 ≤150 行/卡 ≤60 行）
  Evidence: grep 四锚 exit 0
  **Verify command**: grep -q '候选任务 ≤8' skills/plan-history-recall/SKILL.md && grep -q '每代理 ≤3 任务' skills/plan-history-recall/SKILL.md && grep -q '简报 ≤150 行' skills/plan-history-recall/SKILL.md && grep -q '≤60 行' skills/plan-history-recall/SKILL.md
- [ ] VC-4: 新 selftest 注册 registry 且 --only 跑批 FAIL=0
  Evidence: run-selftests.sh 回执
  **Verify command**: bash skills/task-planner/scripts/run-selftests.sh --only plan-history-recall 2>&1 | tail -1 | grep -qE 'FAIL=0'
- [ ] VC-5: 部署六位 diff=0（技能 4 位+agent 2 位，task-planner 3 变更文件×4 位含内；代表链如下，Phase 5 全矩阵对账留 progress）
  Evidence: diff -rq 零输出
  **Verify command**: diff -rq skills/plan-history-recall /home/terry/.zcode/skills/plan-history-recall && diff -rq skills/plan-history-recall /home/terry/.claude/skills/plan-history-recall && diff -q skills/task-planner/companion/agents/history-miner.md /home/terry/.zcode/agents/history-miner.md && diff -q skills/task-planner/SKILL.md /home/terry/.cursor/skills/task-planner/SKILL.md
- [ ] VC-6: 接线行在位且全量回归 FAIL 数=基线记录值（无新增；基线=baseline-selftest.log 实测 5；判据=命令双侧非空且相等，防空串恒真）
  Evidence: grep 接线锚+runner 回执
  **Verify command**: grep -q 'plan-history-recall' skills/task-planner/SKILL.md && A="$(bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 | grep -E '^Total:' | grep -oE 'FAIL=[0-9]+')" && B="$(grep -oE 'FAIL=[0-9]+' plans/task-history-recall-20261116/baseline-selftest.log | tail -1)" && [ -n "$A" ] && [ -n "$B" ] && [ "$A" = "$B" ]

---

## Phase Gates

### Phase 1: Requirements & Discovery（brainstorming）

**Goal**: 三裁决+设计获批+调研落盘。

**Depends on**: none

**Done when**:
- [x] design.md 获批落盘（ece4419）+drift ALIGNED

**Verification**:
- [x] V-1.1: design 覆盖 goal 三锚（映射 VC-2 设计）
  **Verify command**: grep -q '证据锚' plans/task-history-recall-20261116/design.md
- [x] V-1.2: 三裁决登记专档
  **Verify command**: grep -q 'Q3' plans/task-history-recall-20261116/user-session-log.md

Status: `complete` Last verified: 2026-11-16

---

### Phase 2: Planning & Structure

**Goal**: 计划四件套定稿+attest 锁定。

**Depends on**: Phase 1

**Done when**:
- [ ] attest-plan.sh exit 0（SHA 回执留 progress）

**Verification**:
- [ ] V-2.1: VC 表 ≥5 条且全带 Verify command
  **Verify command**: grep -c 'Verify command' plans/task-history-recall-20261116/verification.md
- [ ] V-2.2: S-unit 表机器契约（NNmin/纯数字 ID）
  **Verify command**: grep -cE '\| S[0-9]+ \|' plans/task-history-recall-20261116/task_plan.md

Status: `in_progress` Last verified: 2026-11-16

---

### Phase 3: Implementation（worktree 交付物）

**Goal**: worktree 内 6 交付物落位合规。

**Depends on**: Phase 2

**Done when**:
- [ ] S1-S6 全部完成+Handoff 回填

**Verification**:
- [ ] V-3.1: VC-1 交付物锚（worktree 内执行）
  **Verify command**: （VC-1 同构命令，worktree cwd）
- [ ] V-3.2: VC-3 护栏锚（worktree 内执行）
  **Verify command**: （VC-3 同构命令，worktree cwd）

Status: `pending`

---

### Phase 4: Testing & Verification

**Goal**: dogfood 实测+selftest 回归+CR APPROVED。

**Depends on**: Phase 3

**Done when**:
- [ ] VC-2/VC-4 通过+critic APPROVED

**Verification**:
- [ ] V-4.1: 简报锚抽查 ≥3 命中
  **Verify command**: （VC-2 命令+人工抽查 3 锚留回执）
- [ ] V-4.2: selftest --only FAIL=0
  **Verify command**: （VC-4 同构命令，worktree cwd）

Status: `pending`

---

### Phase 5: Delivery

**Goal**: 六位部署 diff=0+merge 回 master+worktree 清理+归档准备。

**Depends on**: Phase 4

**Done when**:
- [ ] VC-5/VC-6 通过+worktree 无遗留+check-complete exit 0

**Verification**:
- [ ] V-5.1: 六位 diff=0
  **Verify command**: （VC-5 全矩阵命令，master cwd）
- [ ] V-5.2: worktree 已清理
  **Verify command**: git worktree list | grep -v task-history-recall

Status: `pending`
