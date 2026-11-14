# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在技能规范层根治序列创作知识设定同步缺陷：动笔前强制回读+台账沉淀+验收一致性三环闭环条款落地且回归绿。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: Rule 107 条款全文（≥4 子条锚 107.1-107.4）在权威载体 critical-rules-discipline.md 逐字在位
  Evidence: grep 命令输出（worktree 内执行，合并回后主仓复跑）
  **Verify command**: bash -c 'c1=$(grep -c "序列创作知识同步" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md); c2=$(grep -cE "107\.[1-4]" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md); test "$c1" -ge 1 -a "$c2" -ge 4'
- [ ] VC-2: 派发面+媒体面级联条款在位（两文件均含「前序产出」条款）
  Evidence: grep 命令输出
  **Verify command**: bash -c 'a=$(grep -c "前序产出" /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md); b=$(grep -c "前序产出" /mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md); test "$a" -ge 1 -a "$b" -ge 1'
- [ ] VC-3: 全量 selftest 失败脚本数 ≤ worktree 编辑前基线（动态阈值；判据模式=FAIL=[1-9] 行计数，[corrected] 原 FAIL 行计数恒定无判别力）
  Evidence: progress.md 轮次行+selftest 日志 /tmp/serialsync-selftest.log+基线文件 /tmp/serialsync-st-baseline.count（worktree 实测基线=3：2 失败脚本+Total 行）
  **Verify command**: bash -c 'bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-selftest.log 2>&1; test "$(sed -n "s/^Total: .* FAIL=\([0-9]*\).*/\1/p" /tmp/serialsync-selftest.log | tail -1)" -le "$(cat /tmp/serialsync-st-baseline.count)"'
- [x] VC-4: 合并回主仓后 scope 文件零未提交变更（三个预存在途文件除外）且 Rule 107 段 Read 复验一致
  Evidence: git status 2026-11-15=仅 3 在途文件+plans/（stash 窗口合并法 41.1 消解）；主仓 grep 序列创作知识同步=1（discipline:740）
  **Verify command**: bash -c 'out=$(git -C /mnt/data/dev/task-planner-skill status --porcelain -- skills/); test "$(echo "$out" | grep -cvE "plan-resume|todo-skill|workflow-model-tiers")" -eq 0'
- [x] VC-5: check-complete exit 0 且部署位 diff=0（zcode/claude/cursor 三位 7 文件 diff=0 实测 2026-11-15；agents 位 task-planner 为 stub 安装无 SKILL.md=跳过登记）
  Evidence: check-complete 输出+三位 diff 输出（progress Phase 5 段）
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115

---

## Phase Gates

### Phase 1: 侦察与根因定位

**Goal**: 全量枚举+执行链定位产出缺口清单与落点事实，落 findings.md

**Depends on**: none

**Done when**:
- [ ] findings.md 含命中清单（文件:行）+缺口判定+selftest 基线 FAIL 数+纪元面精确清单

**Verification** (run before moving on):
- [ ] V-1.1: findings.md 含 Research Findings 命中清单
  **Verify command**: bash -c 'f=/mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115/findings.md; test -s "$f" && grep -q "Research Findings" "$f"'
- [ ] V-1.2: findings.md 含缺口判定+selftest 基线登记
  **Verify command**: bash -c 'f=/mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115/findings.md; grep -q "缺口" "$f" && grep -q "run-selftests" "$f"'

Status: `complete` Last verified: 2026-11-15（V-1.1/V-1.2 PASS+drift ALIGNED+3file PASS）

---

### Phase 2: 条款设计与定稿

**Goal**: Rule 107 条款文本+传播面清单+变更标注表终稿并经用户确认

**Depends on**: Phase 1

**Done when**:
- [ ] findings §Technical Decisions 含条款终稿；task_plan 变更标注表终稿；用户确认留痕

**Verification**:
- [ ] V-2.1: findings.md 含 Rule 107 条款终稿
  **Verify command**: bash -c 'grep -q "Rule 107" /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115/findings.md'
- [ ] V-2.2: task_plan.md 变更标注表含终稿行（CA-1 起）
  **Verify command**: bash -c 'grep -qE "CA-1" /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115/task_plan.md'

Status: `complete` Last verified: 2026-11-15（V-2.1/V-2.2 PASS+用户 #3 yes+drift ⚠️→闭合）

---

### Phase 3: worktree 实施

**Goal**: 权威载体+级联面+索引/纪元面条款全部在 worktree 落地

**Depends on**: Phase 2

**Done when**:
- [ ] VC-1/VC-2 判据命令在 worktree 前缀下通过；纪元锚残留=0

**Verification**:
- [ ] V-3.1: worktree 内 Rule 107 锚命中
  **Verify command**: bash -c 'w=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills; c1=$(grep -c "序列创作知识同步" "$w/task-discipline/references/critical-rules-discipline.md"); c2=$(grep -cE "107\.[1-4]" "$w/task-discipline/references/critical-rules-discipline.md"); test "$c1" -ge 1 -a "$c2" -ge 4'
- [ ] V-3.2: worktree 内级联条款命中
  **Verify command**: bash -c 'w=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills; a=$(grep -c "前序产出" "$w/task-dispatch/references/critical-rules-dispatch.md"); b=$(grep -c "前序产出" "$w/media-planner/references/critical-rules-media.md"); test "$a" -ge 1 -a "$b" -ge 1'

Status: `complete` Last verified: 2026-11-15（V-3.1/V-3.2 PASS+drift ALIGNED+103.6 四族清单全绿+commit c5300a0）

---

### Phase 4: 回归验证

**Goal**: selftest 与 master 基线一致+VC-1/VC-2 独立复验

**Depends on**: Phase 3

**Done when**:
- [ ] worktree 全量 selftest FAIL ≤ 基线；复检回执落 progress.md

**Verification**:
- [ ] V-4.1: worktree 全量 selftest
  **Verify command**: bash -c 'bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-serial-sync-20261115/skills/task-planner/scripts/run-selftests.sh > /tmp/serialsync-st-wt.log 2>&1; test "$(sed -n "s/^Total: .* FAIL=\([0-9]*\).*/\1/p" /tmp/serialsync-st-wt.log | tail -1)" -le "$(cat /tmp/serialsync-st-baseline.count)"'
- [ ] V-4.2: 独立复检回执落 progress.md
  **Verify command**: bash -c 'grep -q "复检回执" /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115/progress.md'

Status: `complete` Last verified: 2026-11-15（V-4.1 PASS：FAIL=2=基线；V-3.1/V-3.2 复跑 PASS；103.3a 全文比对载体 1-5 一致；DQ-08 锁步 2eded71）

---

### Phase 5: 合并回与收口

**Goal**: merge back+部署 diff=0+check-complete+归档

**Depends on**: Phase 4

**Done when**:
- [ ] 主仓 scope 零未提交变更（预存 3 文件除外）；check-complete exit 0；归档完成

**Verification**:
- [ ] V-5.1: 主仓状态复核
  **Verify command**: bash -c 'out=$(git -C /mnt/data/dev/task-planner-skill status --porcelain -- skills/); test "$(echo "$out" | grep -cvE "plan-resume|todo-skill|workflow-model-tiers")" -eq 0'
- [ ] V-5.2: check-complete 门
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115

Status: `complete` Last verified: 2026-11-15（V-5.1 PASS：git status skills/ 仅 3 在途文件；V-5.2=check-complete 全门 exit 0 见 Phase 5 证据；三位部署 diff=0；merge 2660f6f）

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| critical-rules-discipline.md | Rule 107 插入于 106.5 后且格式对齐既有 NN.M 条款形态（:740-753 实测） | 符合 |
| critical-rules-dispatch.md | 22.4d 插于 22.4c 后/22.5 前，契约面条款形态一致（:64 实测） | 符合 |
| critical-rules-media.md | 47.7 插于 47.6 后/49 前，指针条款形态一致（:27 实测） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-serial-sync-20261115
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":3,"main_direct_count":2,"delegation_rate":0.600,"main_direct":[{"phase":"2 Planning & Structure","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单（self_declared=0）"},{"phase":"5 Delivery","reason":"例外理由:① git 编排+② 簿记——Rule 25.3 白名单（self_declared=0）"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单：② 计划系统文件维护/① git 编排+② 簿记）
- [x] 委派率 0.600<0.7 但主进程直做理由全部命中白名单 → 25.4a WHITELIST-EXEMPT 放行路径（rate<floor 时理由全命中=不降级）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（S-unit 执行均有自审+复检双轮；DQ-08 回归由复检体抓到并修复=质检闭环实证）
- [x] Evidence 抽查 4 条:路径可 Read、结论可复现——①S1 命中清单复核（三重点文件零命中 grep 2026-11-15）②S2/S3 落地 grep 复核（22.4d@64/47.7@27/1-107×3）③DQ-08 修复后 dual-qc 14/14 直跑 ④三部署位 7 文件 diff=0
- [x] 豁免登记: none（CA-6 主进程直补=白名单①单行 trivial，非质量豁免）
- [x] 存在未处置违规 → 无（Error Log DQ-08 已闭环；drift 两处 ⚠️→均闭合）

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
