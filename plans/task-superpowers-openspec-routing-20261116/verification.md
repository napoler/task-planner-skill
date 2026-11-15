# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

task-planner 在既有载体（spec-mode.md / skill-collaboration.md / SKILL.md 指针行）落「复杂度主轴+信号修正」的 Superpowers×OpenSpec 择一路由决策条款：零新文件零脚本、三受管文件增量、selftest 无新增 FAIL、四部署位同步 diff=0。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [x] VC-1: spec-mode.md §1b「复杂度分档→族选择」决策表在位：四档映射+信号修正行+择一语义段
  Evidence: skills/task-planner/references/spec-mode.md §1b 小节
  **Verify command**: grep -q "复杂度分档→族选择" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md && grep -q "L1（中等）且无规格留存需求" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md && grep -q "L2+ 或规格留存需求" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md && grep -q "择一语义" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md
- [x] VC-2: skill-collaboration.md §二含「复杂度主轴初筛」段：初筛轴+信号修正覆盖+与 §1b 同构互引
  Evidence: skills/plan-collab-router/references/skill-collaboration.md §二判定顺序段后
  **Verify command**: grep -q "复杂度主轴初筛" /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md && grep -q "覆盖复杂度初判" /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md
- [x] VC-3: task-planner/SKILL.md Spec 模式检查行行尾含 §1b 择一路由指针（既有文字零改动）
  Evidence: skills/task-planner/SKILL.md:65 行尾
  **Verify command**: grep -q 'spec-mode.md` §1b' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [x] VC-4: selftest 回归无新增 FAIL：worktree 全量 FAIL 数 ≤ master 基线 FAIL 数（基线对照防预存 FAIL 误判）
  Evidence: 双跑 Total 行对照记录（progress.md Test Results）
  **Verify command**: m=$(bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | head -1 | cut -d= -f2); w=$(bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116/skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | head -1 | cut -d= -f2); [ -n "$m" ] && [ -n "$w" ] && [ "$w" -le "$m" ]
- [x] VC-5: 三受管文件 × 4 部署位（zcode/agents/claude/cursor）同步后逐对 diff=0
  Evidence: 部署对账记录（progress.md Test Results）
  **Verify command**: for p in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do diff -q "$p/task-planner/SKILL.md" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md >/dev/null && diff -q "$p/task-planner/references/spec-mode.md" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md >/dev/null && diff -q "$p/plan-collab-router/references/skill-collaboration.md" /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md >/dev/null || exit 1; done
- [x] VC-6: 合并回 master 完成（merge 记录在案）且 worktree 已清理（列表无残留）
  Evidence: git log + git worktree list
  **Verify command**: git -C /mnt/data/dev/task-planner-skill log --oneline --grep="task-superpowers-openspec-routing-20261116" | grep -q . && ! git -C /mnt/data/dev/task-planner-skill worktree list --porcelain | grep -q "tmp/worktrees/task-superpowers-openspec-routing-20261116"
- [x] VC-7: 调研结论在盘：findings-external-families.md 含 A 段集成现状结论（R4 已答）
  Evidence: plans/task-superpowers-openspec-routing-20261116/findings-external-families.md
  **Verify command**: grep -q "A. 仓内集成现状" /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116/findings-external-families.md

---

## Phase Gates

### Phase 1: 调研与双裁决

**Goal**: 产出自包含调研 findings + 用户载体/判据双裁决

**Depends on**: none

**Done when**:
- [x] findings-external-families.md A-F 六段落盘且证据锚抽查一致
- [x] AskUserQuestion 双裁决回传并锚定 user-session-log #1

**Verification** (run before moving on):
- [x] V-1.1: findings 在盘（映射 VC-7）
  **Verify command**: grep -q "A. 仓内集成现状" /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116/findings-external-families.md
- [x] V-1.2: 现有路由条款在位（插锚前提，映射 VC-1 前置事实）
  **Verify command**: grep -q "Spec 模式触发判定" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md

Status: `complete` Last verified: 2026-11-16

---

### Phase 2: 计划定稿与 attest 锁定

**Goal**: 计划文档定稿并通过 attest 门链锁定

**Depends on**: Phase 1

**Done when**:
- [x] attest-plan.sh 锁定 exit 0（SHA dd1fa197→终态重锁定见 Decisions/progress）

**Verification**:
- [x] V-2.1: attest 锁定在位（映射 Goal 单元表 G2）
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/attest-plan.sh --verify
- [x] V-2.2: 专档逐字条目在位（映射 R 锚）
  **Verify command**: grep -q "^## #1 | 2026-11-16" /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116/user-session-log.md

Status: `complete` Last verified: 2026-11-16

---

### Phase 3: worktree 隔离与三文件条款实现

**Goal**: worktree 内 CA-1/2/3 三处增量落地，既有行零删除

**Depends on**: Phase 2

**Done when**:
- [x] 三文件条款在位且 git diff 显示纯增量（+12/-0、+2/-0、+1/-1 前缀保真）

**Verification**:
- [x] V-3.1: §1b 决策表在位（映射 VC-1）
  **Verify command**: grep -q "复杂度分档→族选择" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116/skills/task-planner/references/spec-mode.md
- [x] V-3.2: 初筛段在位（映射 VC-2）
  **Verify command**: grep -q "复杂度主轴初筛" /mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116/skills/plan-collab-router/references/skill-collaboration.md
- [x] V-3.3: 指针行在位（映射 VC-3）
  **Verify command**: grep -q 'spec-mode.md` §1b' /mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116/skills/task-planner/SKILL.md

Status: `complete` Last verified: 2026-11-16（V-3.x 于 worktree 清理前实测 PASS；merge 后 master 路径同内容已复核）

---

### Phase 4: 回归与独立复检

**Goal**: selftest 基线对照零新增 FAIL + 独立子代理复检全绿

**Depends on**: Phase 3

**Done when**:
- [x] VC-4 基线对照通过（worktree 98/96/2 = master 98/96/2 逐字一致，零新增）
- [x] 复检子代理结论=一致并落 verification.md 交叉验证记录（verify-report.md 97 行）

**Verification**:
- [x] V-4.1: selftest 基线对照（映射 VC-4）
  **Verify command**: m=$(bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | head -1 | cut -d= -f2); w=$(bash /mnt/data/dev/task-planner-skill/tmp/worktrees/task-superpowers-openspec-routing-20261116/skills/task-planner/scripts/run-selftests.sh 2>&1 | grep -oE 'FAIL=[0-9]+' | head -1 | cut -d= -f2); [ -n "$m" ] && [ -n "$w" ] && [ "$w" -le "$m" ]
- [x] V-4.2: 交叉验证记录行在位（映射 Rule 108）
  **Verify command**: grep -q "交叉验证记录" /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116/verification.md

Status: `complete` Last verified: 2026-11-16

---

### Phase 5: 合并回+部署同步+收尾

**Goal**: merge 回 master + 4 部署位 diff=0 + worktree 清理 + 收尾回读/归档

**Depends on**: Phase 4

**Done when**:
- [x] VC-5 部署 diff=0、VC-6 merge+清理完成、收尾回读收敛

**Verification**:
- [x] V-5.1: 部署 diff=0（映射 VC-5）
  **Verify command**: for p in /home/terry/.zcode/skills /home/terry/.agents/skills /home/terry/.claude/skills /home/terry/.cursor/skills; do diff -q "$p/task-planner/SKILL.md" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md >/dev/null && diff -q "$p/task-planner/references/spec-mode.md" /mnt/data/dev/task-planner-skill/skills/task-planner/references/spec-mode.md >/dev/null && diff -q "$p/plan-collab-router/references/skill-collaboration.md" /mnt/data/dev/task-planner-skill/skills/plan-collab-router/references/skill-collaboration.md >/dev/null || exit 1; done
- [x] V-5.2: merge 记录+worktree 清理（映射 VC-6）
  **Verify command**: git -C /mnt/data/dev/task-planner-skill log --oneline --grep="task-superpowers-openspec-routing-20261116" | grep -q . && ! git -C /mnt/data/dev/task-planner-skill worktree list --porcelain | grep -q "tmp/worktrees/task-superpowers-openspec-routing-20261116"

Status: `complete` Last verified: 2026-11-16

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| findings-external-families.md | §1b/初筛段设计=F 段建议 F1/F2/F5 逐条对照（调用不复制/轻量决策表/统一权威源） | 符合（复检语义三性 PASS+drift ALIGNED） |
| spec-mode.md（插锚对象） | CA-1 插入点=§1 表后 §2 前；既有行 diff 零删除（+12/-0） | 符合（numstat 证据） |
| skill-collaboration.md §二 | CA-2 插入点=判定顺序段后；互引句指向 §1b（+2/-0） | 符合（103.6(a) 双向互引 PASS） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-superpowers-openspec-routing-20261116
```

JSON 输出：
```json
{"phases_total":5,"phases_delegated":2,"main_direct_count":3,"delegation_rate":0.400,"main_direct":[{"phase":"2 计划定稿与 attest 锁定","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单","self_declared":0},{"phase":"3 worktree 隔离与三文件条款实现","reason":"例外理由:② 计划系统文件维护——本仓=task-planner 技能自身，条款措辞与既有锚强一致，拆派需转述全量设计上下文，收益<风险——Rule 25.3 白名单","self_declared":0},{"phase":"5 合并回+部署同步+收尾","reason":"例外理由:① git 编排+② 簿记——Rule 25.3 白名单","self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单：P2/P3=②计划系统文件维护，P5=①git 编排+②簿记）
- [x] 委派率 0.4<0.7 但主进程 Phase 均持白名单理由，stats verdict=**ok**（violations=[]），不触发 PARTIAL 封顶

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项（无批量门/派发契约违规面）,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:①VC-1..3 grep 四处（主进程亲跑）②selftest Total 双跑日志 ③部署位 diff=0 四行回执④verify-report.md 语义三性 file:line——均可 Read/复现，抽查记录在 progress.md 各 Phase Test Results
- [x] 豁免登记: none（无用户豁免面）
- [x] 存在未处置违规 → 无；outcome 未降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — task-planner 在既有载体落「复杂度主轴+信号修正」的 Superpowers×OpenSpec 择一路由决策条款
对照 Verification Contract 逐条复验：
- [x] VC-1: §1b 决策表 grep 四关键词（master 路径实测 1/1/1/1） → PASS
- [x] VC-2: 初筛段 grep 两关键词（master 路径实测 1/1） → PASS
- [x] VC-3: 指针行 grep（master 路径实测 1） → PASS
- [x] VC-4: selftest 基线对照（wt 98/96/2 = master 98/96/2，双跑命令原文在 progress Phase 4） → PASS
- [x] VC-5: 部署位 diff=0（4 位逐位 DIFF=0 回执在 progress Phase 5） → PASS
- [x] VC-6: merge+worktree 清理（42ab794/54ec525 命中+WT/BR 清理完成） → PASS
- [x] VC-7: findings 在盘（A 段标题 grep 命中） → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 交叉验证记录（Rule 108）
<!-- 触发面见 critical-rules-verification.md 108.1（L2+/≥2受管文件/子代理验证产出采信前/用户明确要求）；mini/L0 豁免。未触发登记：`未触发（原因）`；触发但单路径=FAIL。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| VC-1/2/3 条款落地 | grep 三组 exit 0（V-3.1..3；master 路径复跑 1/1/1/1、1/1、1） | Phase 4 复检子代理（A5）语义三性 PASS（verify-report.md：权威源一致/择一语义无歧义/调用形态一致） | 一致 PASS |
| selftest 基线 | 双跑 Total：master 98 PASS=96 FAIL=2 / worktree 98 PASS=96 FAIL=2（同 2 预存） | 复检子代理 cross-check + selftest-skill-collab 25/25 实跑 | 一致 PASS |
| 目标对齐 | git show 42ab794/54ec525 仅三受管文件+部署位 diff=0 | drift-checker 三态判定 ALIGNED 零偏移（.drift-checkpoint.md） | 一致 PASS |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 2（计划定稿+attest） |
| 2 | Where am I going? | Phase 3 worktree 条款 → Phase 4 回归复检 → Phase 5 合并部署 |
| 3 | What's the goal? | Goal 语句见上 |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
