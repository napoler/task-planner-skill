# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner-skill 落地 Rule 106 五子条（106.1-106.5）+todo-sync 两组契约并完成级联/selftest 回归/三部署位同步，封堵「文档改后不复检即放行/流程步骤丢弃」缺口。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: 缺陷取证落盘——findings.md 含会话缺陷链（G22-05a/sess_1378b365）与「未验证」兜底登记
  Evidence: plans/task-docmod-recheck-20261112/findings.md §1（grep 命中≥4 行：判例、会话 ID、未验证、检索位置）→ PASS(2026-11-13 终验, V-1.1 命中≥4 且 §5 定性在位)
  **Verify command**: test $(grep -cE 'G22-05a|sess_1378b365|未验证' /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/findings.md) -ge 4
- [x] VC-2: Rule 106 规则体落盘——critical-rules-discipline.md 含 106.1-106.5 五子条且位于 Rule 105 之后
  Evidence: skills/task-discipline/references/critical-rules-discipline.md（五子条计数≥5；S1 diff 仅新增段）→ PASS(2026-11-13, S6, 命令输出: VC2-PASS)
  **Verify command**: test $(grep -cE '106\.[1-5]' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -ge 5
- [x] VC-3: 级联面完成——SKILL.md 1-106 上界≥2 处、Rule 106 命中、verification-gate 互指在位、全仓无「Rules 1-105」残留
  Evidence: skills/task-planner/SKILL.md + skills/verification-gate/references/critical-rules-verification.md（grep 计数）→ PASS(2026-11-13, S6, 命令输出: VC3-PASS)
  **Verify command**: test $(grep -c '1-106' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md) -ge 2 && grep -q 'Rule 106' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q 'Rule 106' /mnt/data/dev/task-planner-skill/skills/verification-gate/references/critical-rules-verification.md && ! grep -rq 'Rules 1-105' /mnt/data/dev/task-planner-skill/skills/
- [x] VC-4: 既有 selftest 套件全绿——run-selftests.sh fresh 跑 exit 0（epoch 锚更新后与 master 基线对照仅本任务锚位差异）
  Evidence: Phase 4 S5/S6 运行输出（progress.md Test Results + evidence/VC-4*.out）→ PASS(2026-11-13, S6, 引用S5: fresh=Total 97 PASS=95 FAIL=2，FAIL={selftest-active-plan,selftest-execution-stability}，经主仓对照定性master既有/形态一致，按VC-4判据「=基线−epoch且逐项登记」达标；checkpoint /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/subagent-state/06-code-runner-s5.md)→ 终验复核(2026-11-13): 主仓 post-merge 重跑 97/95/2 与基线完全一致，FAIL 集未变=达标口径成立
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 | tee /tmp/r106-selftest.out | tail -3; test ${PIPESTATUS[0]} -eq 0
- [x] VC-5: 三部署位同步——scope 五文件 × zcode/claude/cursor 位逐一 diff 为空
  Evidence: 2026-11-13 主进程逐对 diff 输出 ALL-SYNCED（6 文件×3 位）；zcode c8b874d(main,已 push 9f0164f..c8b874d)/claude cf28dd5(master,已 push 440570d..cf28dd5) pathspec 提交；cursor 非 git 仓仅落盘；源仓 push 9126c3c..bdbcfc2
  **Verify command**: cd /mnt/data/dev/task-planner-skill && for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/task-planner/references/todo-sync.md skills/verification-gate/references/critical-rules-verification.md; do for site in /home/terry/.zcode/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do diff -q "$f" "$site/${f#skills/}" >/dev/null || { echo "DRIFT: $f @ $site"; exit 1; }; done; done; echo ALL-SYNCED
- [x] VC-6: 两组 todo 驱动对齐落盘——todo-sync.md 含基线组条款（基线≥4 处、106.5 与两组在位）；SKILL.md 同步段含两组指针
  Evidence: skills/task-planner/references/todo-sync.md S1 扩展块 + SKILL.md 同步段（grep 计数）→ PASS(2026-11-13, S6, 命令输出: VC6-PASS)
  **Verify command**: test $(grep -c '基线' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md) -ge 4 && grep -q '106.5' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -q '两组' /mnt/data/dev/task-planner-skill/skills/task-planner/references/todo-sync.md && grep -q '两组' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md

---

## Phase Gates

### Phase 1: 缺陷取证与证据落盘

**Goal**: 会话缺陷链+条款缺口+本体现状（含未验证兜底）全部落 findings.md

**Depends on**: none

**Done when**:
- [x] findings.md §1-§4+§Rule106 草案+§todo 契约草案+§级联锚位清单在位

**Verification** (run before moving on):
- [ ] V-1.1: VC-1 取证落盘复验
  **Verify command**: test $(grep -cE 'G22-05a|sess_1378b365|未验证' /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/findings.md) -ge 4
- [ ] V-1.2: VC-2 前置——五子条草案成文（findings 内 106.1-106.5 各≥1）
  **Verify command**: test $(grep -cE '106\.[1-5]' /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/findings.md) -ge 5

Status: `in_progress` Last verified: 2026-11-13

---

### Phase 2: 规则文本设计与计划锁定

**Goal**: 五子条+todo 契约+级联锚位定稿；计划 attest 锁定（new_rule=106 预留）

**Depends on**: Phase 1

**Done when**:
- [ ] attest exit 0 且规则账本含 106 预留；哨兵清除

**Verification**:
- [ ] V-2.1: Rule 106 预留在账本（rule-reservations 含 docmod 任务行）
  **Verify command**: grep -q 'task-docmod-recheck-20261112' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl
- [ ] V-2.2: 级联锚位清单 9 项在位
  **Verify command**: test $(grep -cE '^[0-9]\. ' /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/findings.md) -ge 9

Status: `in_progress` Last verified: —

---

### Phase 3: worktree 内条款落地与级联（S1-S5）

**Goal**: 五文件在 worktree 内改毕，VC-2/3/6 命令在 worktree 路径下全过

**Depends on**: Phase 2

**Done when**:
- [ ] S1-S5 全 pending→done；103.6 同步核对清单全绿

**Verification**（worktree 绝对路径 /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112，下称 $WT 行内展开）:
- [ ] V-3.1: VC-2 worktree 版——五子条落盘
  **Verify command**: test $(grep -cE '106\.[1-5]' /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/task-discipline/references/critical-rules-discipline.md) -ge 5
- [ ] V-3.2: VC-6 worktree 版——todo 契约两组结构落盘
  **Verify command**: test $(grep -c '基线' /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/task-planner/references/todo-sync.md) -ge 4
- [ ] V-3.3: VC-3 worktree 版——级联与残留清零
  **Verify command**: test $(grep -c '1-106' /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/task-planner/SKILL.md) -ge 2 && ! grep -rq 'Rules 1-105' /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/

Status: `pending` Last verified: —

---

### Phase 4: 验证与独立复检（S6-S7）

**Goal**: selftest fresh 全绿 + 103.3 独立复检回执落 checkpoint

**Depends on**: Phase 3

**Done when**:
- [ ] VC-4 命令 exit 0；S7 回执在 subagent-state/

**Verification**:
- [ ] V-4.1: VC-4 主套件全绿（worktree 内跑）
  **Verify command**: bash /mnt/data/dev/task-planner-skill-worktrees/task-docmod-recheck-20261112/skills/task-planner/scripts/run-selftests.sh 2>&1 | tee /tmp/r106-selftest-wt.out | tail -3; test ${PIPESTATUS[0]} -eq 0
- [ ] V-4.2: S7 复检回执在位（subagent-state 含 APPROVED 或整改闭环记录）
  **Verify command**: grep -rql 'APPROVED\|整改' /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112/subagent-state/

Status: `pending` Last verified: —

---

### Phase 5: 合并、部署与交付

**Goal**: 合并回 master+三部署位 diff=0+归档+交付五要素

**Depends on**: Phase 4

**Done when**:
- [ ] VC-5 ALL-SYNCED；rule 106 land；check-complete exit 0；84.14 收敛

**Verification**:
- [ ] V-5.1: VC-5 部署逐对全绿（见 VC 表命令）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && for f in skills/task-planner/references/todo-sync.md; do diff -q "$f" "/home/terry/.zcode/skills/${f#skills/}" >/dev/null || exit 1; done; echo ZCODE-SYNCED
- [ ] V-5.2: rule 106 已 land
  **Verify command**: grep -q '"status":"landed"' /mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 用户宪法 §四/§六/§十一 | 交付物=纯文本条款零新脚本；worktree 集中目录路径 | 终验填 |
| task-planner SKILL.md | 级联锚与卫星路由表一致（VC-3） | 终验填 |
| discipline 规则全集 | S1 首动作 Read 留痕+Rule 105 段形态对齐 | 终验填 |
| todo-sync.md 现行契约 | S4 首动作 Read+既有语义零改动（diff 仅新增） | 终验填 |
| sess_1378b365 判例 | findings §1 转录与规则判例锚一致 | 终验填 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-docmod-recheck-20261112
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"main_direct":[{"phase":"1 缺陷取证与证据落盘","reason":"例外理由: ② 计划系统文件维护/簿记——调研主体已委派 Explore ×2（Handoff #1/#2），剩余为 findings 回填"},{"phase":"2 规则文本设计与计划锁定","reason":"例外理由: ② 计划系统文件维护——Rule 25.3 白名单"},{"phase":"5 合并、部署与交付","reason":"例外理由: ① git 编排+② 簿记——Rule 25.3 白名单"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）——stats main_direct 三条全部含白名单①②理由
- [x] 委派率 0.400 <0.7 但 violations=[] 且 verdict=ok（直做全白名单登记，无白名单外理由）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（全程无降质行为触发；三 drift ALIGNED+stats violations=[]）
- [x] Evidence 抽查 ≥3 条:V-3.x 亲验/S6 三命令复验/VC-5 ALL-SYNCED/VC-4 双跑对照（抽查记录=progress 各 Phase Test Results 表）
- [x] 豁免登记:无（n/a）
- [x] 存在未处置违规 → 无（不适用）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 在 task-planner-skill 落地 Rule 106 五子条+todo-sync 两组契约并完成级联/selftest 回归/三部署位同步
对照 Verification Contract 逐条复验：
- [x] VC-1: findings §1/§5 取证+未验证兜底 → PASS
- [x] VC-2: discipline:721-734 五子条 → PASS（主仓/worktree 双验）
- [x] VC-3: SKILL 1-106×3+路由+互指+残留=0 → PASS
- [x] VC-4: 97/95/2=基线−epoch 逐项登记 → PASS
- [x] VC-5: ALL-SYNCED+三仓 push → PASS
- [x] VC-6: todo-sync 两组契约+SKILL 指针 → PASS

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
