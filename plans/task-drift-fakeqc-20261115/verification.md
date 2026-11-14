# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

根治 skill 执行两缺陷：范围静默扩张与完成声称措辞升格——以 94.7/51.14/64.7 三条款增款落地为可验证完成。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: 取证报告在位且证据条目充分（E 锚点 ≥20 条）
  Evidence: plans/task-drift-fakeqc-20261115/evidence-session-extract.md
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/evidence-session-extract.md && test $(grep -cE '^\- \[E' /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/evidence-session-extract.md) -ge 20
- [ ] VC-2: 机制缺口 GA1-GA5 每条在 findings 落盘（带条款级锚）
  Evidence: plans/task-drift-fakeqc-20261115/findings.md F2 段
  **Verify command**: test $(grep -cE '^\- GA[1-5] ' /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/findings.md) -ge 5
- [ ] VC-3: 三条款（94.7/51.14/64.7）文本在主仓三载体在位
  Evidence: 主仓 3 载体文件（合并回后）
  **Verify command**: test $(grep -c "94\.7 语料状态边界与规模跳变确认门" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -ge 1 && test $(grep -c "51\.14 完成声称操作类型与物理可行性门" /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md) -ge 1 && test $(grep -c "64\.7 用户原话对照锚强制" /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md) -ge 1
- [ ] VC-4: 全量回归零增量（终跑 --fresh，[FAIL] 脚本集合 ⊆ 基线集合 9 项；基线=tmp/regression-baseline-20261115.txt，Total 97 PASS=88 FAIL=9）
  Evidence: tmp/regression-final-20261115.txt
  **Verify command**: bash /home/terry/.zcode/skills/task-planner/scripts/run-selftests.sh --fresh > /mnt/data/dev/task-planner-skill/tmp/regression-final-20261115.txt 2>&1; test "$(comm -13 <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-baseline-20261115.txt | awk '{print $2}' | sort -u) <(grep -E '^\[FAIL\]' /mnt/data/dev/task-planner-skill/tmp/regression-final-20261115.txt | awk '{print $2}' | sort -u) | wc -l)" -eq 0
- [ ] VC-5: 部署位同步 diff=0（3 位×3 载体文件）
  Evidence: 逐位 diff -q 输出
  **Verify command**: diff -q /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md && diff -q /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md /home/terry/.zcode/skills/task-planner/references/critical-rules.md && diff -q /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md

---

## Phase Gates

### Phase 1: 取证与复核

**Goal**: sess_a7eb0603 四组证据提取+主进程独立复核

**Depends on**: none

**Done when**:
- [x] 取证报告落盘且 4/4 复核一致

**Verification** (run before moving on):
- [x] V-1.1: 取证报告在位（映射 VC-1）
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/evidence-session-extract.md
- [x] V-1.2: findings F1/F2 回填（映射 VC-2）
  **Verify command**: grep -c "F1 会话取证结论" /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/findings.md

Status: `complete` Last verified: 2026-11-15

---

### Phase 2: 根因定位与缺口确认

**Goal**: GA1-GA5 机制缺口条款级锚落盘

**Depends on**: Phase 1

**Done when**:
- [x] findings F2 五条带锚

**Verification**:
- [x] V-2.1: GA 计数 ≥5（映射 VC-2）
  **Verify command**: test $(grep -cE '^\- GA[1-5] ' /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/findings.md) -ge 5

Status: `complete` Last verified: 2026-11-15

---

### Phase 3: 修复条款起草

**Goal**: 三条款草案+判例锚落盘 clause-drafts.md

**Depends on**: Phase 2

**Done when**:
- [x] clause-drafts.md 三条款齐

**Verification**:
- [x] V-3.1: 草案在位（映射 VC-3 前置）
  **Verify command**: grep -c "94\.7 语料状态边界与规模跳变确认门" /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/clause-drafts.md

Status: `complete` Last verified: 2026-11-15

---

### Phase 4: 三载体插段落地与回归（worktree）

**Goal**: worktree 内三条款纯增量 append+既有条款零改动+回归零增量

**Depends on**: Phase 3

**Done when**:
- [ ] 三条款在 worktree 三载体命中且 diff 纯增量（0 删行）

**Verification**:
- [ ] V-4.1: 三条款 worktree 命中（映射 VC-3 前置）
  **Verify command**: test $(grep -c "94\.7 语料状态边界与规模跳变确认门" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115/skills/task-discipline/references/critical-rules-discipline.md) -ge 1 && test $(grep -c "51\.14 完成声称操作类型与物理可行性门" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115/skills/task-planner/references/critical-rules.md) -ge 1 && test $(grep -c "64\.7 用户原话对照锚强制" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115/skills/task-drift-guard/references/critical-rules-drift.md) -ge 1
- [ ] V-4.2: 三文件 diff 纯增量零删行（映射 VC-3 既有零改动）
  **Verify command**: test "$(git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115 diff master --numstat -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/references/critical-rules.md skills/task-drift-guard/references/critical-rules-drift.md | awk '$2==0' | wc -l)" -eq 3

Status: `pending` Last verified: —

---

### Phase 5: 合并回+部署同步+终验交付

**Goal**: smart-merge-back→部署 3 位 diff=0→VC 全 PASS→归档

**Depends on**: Phase 4

**Done when**:
- [ ] VC-1~VC-5 全 PASS

**Verification**:
- [x] V-5.1: 主仓三条款命中（映射 VC-3）
  **Verify command**: test $(grep -c "94\.7 语料状态边界与规模跳变确认门" /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md) -ge 1
- [x] V-5.2: 部署位 diff=0（映射 VC-5）
  **Verify command**: diff -q /mnt/data/dev/task-planner-skill/skills/task-drift-guard/references/critical-rules-drift.md /home/terry/.zcode/skills/task-drift-guard/references/critical-rules-drift.md

Status: `complete` Last verified: 2026-11-15

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| task-discipline 规则全文（74/94 域） | 94.7 与 94.1-94.6 同范式衔接（94.6 后追加，L0-T 机制句内联）；74 B 类门引用一致 | 符合 |
| core 规则全文（51/26/80 域） | 51.14 与 51.3/51.8 分工句显式内联；51.13 机制条款零改动 | 符合 |
| task-drift-guard 规则全文（61/64 域） | 64.7 与 64.1/64.2.1/64.6 口径一致（未执行同口径引用）；64.6 零改动 | 符合 |
| 取证报告（判例证据） | 三条款判例锚均指向取证报告 E 锚（无 ：行号 形态） | 符合 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.4,"main_direct":[{"phase":"2","executor":"主进程（例外理由:② 计划三文件回填与根因簿记——Rule 25.3 白名单）"},{"phase":"3","executor":"主进程（例外理由:② 计划系统条款起草——Rule 25.3 白名单）"},{"phase":"5","executor":"主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）"}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [x] 委派率 0.4 但全部直做 Phase 均白名单内且机器 verdict=ok（violations=[]）→ 不触发回炉

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（S3 格式漂移/主进程吞锚/行号锚三错误均闭环于 Error Log 四步——Rule 31 链，非 Rule 26 Q1-Q6 降质面：无伪造/无跳验证/无范围外写入）
- [x] Evidence 抽查 ≥3 条:①evidence-session-extract.md E4-02/E4-05（224 篇声称链，主进程 4/4 复核）②subagent-state/2-recheck-clauses.md（复检 A-E 命令输出）③主仓三载体 grep=1+numstat 3×(+1/-0)（Bash 实跑输出在 progress Phase 4/5）——路径可 Read、结论可复现
- [x] 豁免登记:无（无用户显式豁免需求）
- [x] 存在未处置违规 → 不适用（0 未处置）

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 根治 skill 执行两缺陷：范围静默扩张与完成声称措辞升格——以 94.7/51.14/64.7 三条款增款落地为可验证完成。
对照 Verification Contract 逐条复验：
- [x] VC-1: evidence-session-extract.md E 锚 ≥20（实测 60+），主进程复核 4/4 一致 → PASS
- [x] VC-2: findings F2 GA1-GA5 五条带条款级 file:line 锚 → PASS
- [x] VC-3: 三条款主仓三载体在位（grep=1×3；既有 94.6/51.13/64.6 零改动=复检 APPROVED 2-recheck-clauses.md） → PASS
- [x] VC-4: --fresh 终跑 FAIL 集合=基线 9 项零新增（Total 97 PASS=88；tmp/regression-final-20261115.txt） → PASS
- [x] VC-5: 三部署位 diff=0（zcode 9 对对账+claude/cursor 扩展核验 CLAUDE-CURSOR-PASS） → PASS

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
