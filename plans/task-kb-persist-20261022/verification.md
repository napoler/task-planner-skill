# Verification Contract & Phase Gates

## Goal (1 sentence)

为当前项目建成「知识沉淀→累计存留→快速查询」全链闭环：knowledge/ 知识库 + 152 归档任务存量回填 + kb-search 检索入口 + 增量入库闭环，使解决类似问题时可一条命令查得可复用知识与证据锚。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: KB 载体在位——README.md、entry-template.md、INDEX.md、entries/ 目录全部存在
  **Verify command**: cd /mnt/data/dev/task-planner-skill && ls knowledge/README.md knowledge/entry-template.md knowledge/INDEX.md >/dev/null && test -d knowledge/entries && echo VC1-PASS
  Evidence: （终验时填命令输出）
- [x] VC-2: 检索实弹——kb-search.sh 对真实关键词命中条目且输出含来源任务路径
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-search.sh 锚点 | head -20
  Evidence: （终验时填：命中行含 entries/*.md 与 plans/archive 来源）
- [x] VC-3: 增量入库实弹——kb-sync-from-plan.sh 对样例归档任务跑通产出 draft 条目
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-sync-from-plan.sh plans/archive/task-v122 && ls knowledge/entries/_draft-task-v122.md && grep "^sources: \[plans/archive" knowledge/entries/_draft-task-v122.md
  Evidence: （终验时填：exit 0 + draft 文件路径）
- [x] VC-4: 回填覆盖——entries 条目 ≥12；每文件 frontmatter 含非空 sources；抽 3 条 sources 路径 Read 存在
  **Verify command**: cd /mnt/data/dev/task-planner-skill && ls knowledge/entries/*.md | wc -l && grep -L "^sources:" knowledge/entries/*.md | wc -l
  Evidence: （终验时填：计数 ≥12 + grep -L 输出为 0 + 3 条抽查 Read 记录）
- [x] VC-5: 索引一致——kb-rebuild-index.sh 重建后 INDEX.md 条目数 = entries 文件数
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-rebuild-index.sh && test "$(grep -c '^| ' knowledge/INDEX.md)" -eq $(( $(ls knowledge/entries/*.md | grep -v _draft | wc -l) + 1 )) && echo VC5-PASS
  Evidence: （终验时填：diff 为空或注释行折算后相等）
- [x] VC-6: 零回归——worktree 内全量 selftest FAIL 增量 = 0（对照主仓基线）
  **Verify command**: cd /home/terry/task-planner-skill-worktrees/kb-persist-20261022 && bash skills/task-planner/scripts/run-all-selftest.sh 2>&1 | tail -5
  Evidence: （终验时填：FAIL 数与主仓基线对比记录，落 progress.md Test Results）
- [x] VC-7: 目标达成实弹（R2 解决判据）——3 个真实主题（子代理派发/worktree 隔离/部署位同步）各执行一次 kb-search 均命中
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-search.sh 派发 | head -5 && bash scripts/kb-search.sh worktree | head -5 && bash scripts/kb-search.sh 部署位 | head -5
  Evidence: （终验时填：3 次命中输出，🎯 核心目标达成裁决引用）

---

## Phase Gates

### Phase 1: KB 载体与检索工具建设

**Goal**: knowledge/ 骨架 + 3 个 kb 脚本在 worktree 内建成并冒烟通过

**Depends on**: none

**Done when**:
- [ ] scripts/kb-search.sh、kb-rebuild-index.sh、kb-sync-from-plan.sh 在 worktree 存在且可执行
- [ ] knowledge/README.md、entry-template.md 存在
- [ ] 主进程冒烟：kb-search/kb-rebuild-index 对空库跑通 exit 0

**Verification** (run before moving on):
- [ ] V-1.1: (→VC-1) worktree 内 `ls knowledge/ scripts/kb-*.sh` 输出齐全
- [ ] V-1.2: (→VC-2) worktree 内 `bash scripts/kb-search.sh test` exit 0（空库允许零命中但命令不报错）

Status: `complete` Last verified: 2026-10-22（V-1.1/V-1.2 PASS，证据=progress.md Phase 1 Test Results；Phase 产物 commit 于 wt 分支）

---

### Phase 2: 存量知识回填

**Goal**: 152 归档任务知识按 6 域蒸馏 ≥12 主题条目入库且索引重建一致

**Depends on**: Phase 1

**Done when**:
- [ ] 6 份 batch-{A..F}-sources.md 清单生成（主进程机械预分组）
- [ ] ≥12 个 entries 条目文件在位，每条含非空 sources
- [ ] 主进程抽检 ≥2 条（10% 且 Rule 18 双采样）通过 + INDEX rebuild

**Verification**:
- [ ] V-2.1: (→VC-4) `ls knowledge/entries/*.md | wc -l` ≥ 12 且 `grep -L "^sources:"` 输出为空
- [ ] V-2.2: (→VC-5) rebuild 后 `grep -c '^| '` = entries 数 + 1（表头行）

Status: `complete` Last verified: 2026-10-22（V-2.1/V-2.2 PASS，证据=progress.md Phase 2 Test Results + P2-S{1..6} 检查点）

---

### Phase 3: 闭环接线与实弹验证

**Goal**: 后续任务知识入库通道建成（项目级模板覆盖 + sync 脚本实弹）+ 3 主题独立实弹查询

**Depends on**: Phase 2

**Done when**:
- [x] .zcode/plan-templates/knowledge-brief.md 覆盖文件在位（77 行前缀 diff=0 + §7 回链段，86 行；init-session.sh:65-79 机制源码级确认）
- [x] sync 实弹（VC-3）exit 0（draft 47 行，幂等 md5 恒定，sources 仓相对）
- [x] 三主题查询命中（VC-7，独立验证 5/5 PASS——派发/worktree/部署位均语义主命中非关键词碰瓷）

**Verification**:
- [x] V-3.1: (→VC-3) PASS——证据=subagent-state/P3-S2-verifier.md §2
- [x] V-3.2: (→VC-7) PASS 3/3——证据=subagent-state/P3-S2-verifier.md §3（含条目结论段信息量抽查）；负例探测+120/120 sources 全量存在性审计亦 PASS

Status: `complete` Last verified: 2026-10-22（独立 verifier 全新上下文执行，非执行者自测）

---

### Phase 4: 回归、终验与合并回

**Goal**: selftest 零回归 + VC 全量复验 + 合并回 master 并主仓复验

**Depends on**: Phase 3

**Done when**:
- [x] 全量 selftest FAIL 增量 = 0（92/92，A=0）
- [x] 终验全部 VC 复验通过 + 58.5 核心目标裁决（R1/R2 solved）
- [x] smart-merge-back 完成（03ffb944）+ worktree/分支清理 + 主仓 Read 复验

**Verification**:
- [x] V-4.1: (→VC-6) PASS——subagent-state/P4-S1-code-runner.md（92/92，含"套件有牙"负验证）
- [x] V-4.2: (→VC-1) PASS——主仓 ls 齐全+INDEX 13 行+git log 三 feat commit+merge

Status: `complete` Last verified: 2026-10-22

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 盘点报告 01-explore-kb-infra.md | 方案缺口对照（聚合层+检索入口+闭环 三缺口全覆盖） | 符合（knowledge/ 聚合层+kb-search 入口+§7 覆盖闭环，缺口一一对应） |
| knowledge-brief 模板六段结构 | overlay 文件原六段 diff=0 | 符合（77 行前缀 diff=0，P3-S1 验收 1） |
| terry-vault-search 范式 | kb-search 命令形态（关键词+过滤+命中输出） | 符合（关键词+--tag 过滤+frontmatter 摘要+来源回链） |
| worktree 隔离合约 | 合并回走 smart-merge-back + 清理 | 符合（V1-V5 门全过，merged(03ffb944)，worktree/分支已清） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**（终验时实跑，verdict=ok）：

```json
{"phases_total":4,"phases_delegated":4,"main_direct_count":0,"delegation_rate":1.000,"main_direct":[],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（无整 Phase 直做；簿记动作理由② git 编排+簿记）
- [x] 委派率 1.000 ≥ 0.7，verdict=ok（首轮 violation 系 P4 Handoff 未登记的口径误报，补登后清零）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（无降质行为触发面：批量有 Rule 18 门+双采样、完成声称有 VC 全过、无伪造证据——子代理产出均经主进程 Read 复核）
- [x] Evidence 抽查 ≥3 条:dispatch-split-decision 全文 Read（锚 file:line 可定位）/P3-S2 verifier 4 处行级锚展开验证/P4-S2 3 条 sources+全量 114 条存在性审计——路径可 Read、结论可复现
- [x] 豁免登记:无（Q3 不适用——非"减少范围/降标准"类任务）
- [x] 存在未处置违规 → 无；outcome 维持 COMPLETE

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 知识沉淀→累计存留→快速查询全链闭环
对照 Verification Contract 逐条复验（独立 verifier 终验 @ 主仓 master 03ffb94，证据=subagent-state/P4-S2-verifier.md）：
- VC-1: 3 文件+entries/ 在位 exit 0 → PASS
- VC-2: kb-search 锚点 命中条目含 title/tags/sources 摘要（sources 仓相对）→ PASS
- VC-3: sync plans/archive/task-v122 exit 0，draft 47 行，sources 仓相对，幂等 → PASS
- VC-4: 12 条目≥12，grep -L 空，抽 3 条存在；全量审计 114/114 sources 存在缺失 0 → PASS
- VC-5: rebuild 后 INDEX 13 行 = 12+1，VC5-PASS → PASS
- VC-6: 92/92 selftest PASS，FAIL=0，A 类（本任务引入）=0；佐证 diff 534255c..03ffb94 纯新增 20 文件 0 删除 → PASS
- VC-7: 派发→dispatch-*、worktree→worktree-*、部署位→worktree-lifecycle-mergeback 三主题语义主命中 → PASS

 outcome: **COMPLETE**（R1/R2 双 solved，58.5 裁决详见 task_plan.md；非回归遗留 3 项已登记）
```

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3；2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（计划已锁定待执行） |
| 2 | Where am I going? | P1 载体工具 → P2 存量回填 → P3 接线验证 → P4 回归合并 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
