# Verification Contract & Phase Gates

## Goal (1 sentence)

B 收口后在终验交付序列中主动检测挂起计划并以【计划回切通告】征得用户确认后路由 plan-resume 定向恢复 A（不自动切），且回切闭环落于 SKILL.md 终验/通告区与 discipline Rule 94 交叉锚、scope 仅两文件。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate 判据面。

- [ ] VC-1: 缺口诊断与机制衔接可审计（findings 含 M1-M12、R-1~R-4、S1-S3 与关键锚点证据）
  Evidence: plans/task-intentresume-20261116/findings.md（M1-M12/R-1~R-4/方案/证据摘录）
  **Verify command**: grep -nE 'M1|M12|R-1|R-4|S1|S2|S3|SKILL\.md:130|discipline:615' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/findings.md
- [ ] VC-2: SKILL.md 终验交付段落地挂起计划回切检查条款（outcome 判定后、归档前；查 [intent-switch] 旧=<id> 与 plans/INDEX.md；yes 路由 Skill("plan-resume") 定向恢复、no 登记保持挂起+回切状态；不自动切）
  Evidence: skills/task-planner/SKILL.md 终验交付段（:130-145 邻域）新增条款
  **Verify command**: grep -nE '挂起计划回切检查（intent-switch 回切）|outcome 判定后|归档前|\[intent-switch\]|旧=<id>|plans/INDEX\.md|Skill\("plan-resume"\)|不自动切|回切状态' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] VC-3: SKILL.md 显性通告区落地回切通告模板（含 B 已收口/检测到挂起链/是否切回 及 yes/no 处置语义）
  Evidence: skills/task-planner/SKILL.md 用户新指令处理/通告区（:202-204 邻域）新增回切通告模板
  **Verify command**: grep -nE '回切通告模板|【计划回切通告】|B 已收口|检测到挂起链|是否切回' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] VC-4: discipline Rule 94 段末补 intent-switch 回切交叉锚并保留 94 权威语义（衔接 94.4 封存待 resume 与回切触发，指向 SKILL.md「终验交付」挂起计划回切检查/【计划回切通告】/Skill("plan-resume")，不自动切；`^### 94` 与 94.4 仍在位）
  Evidence: skills/task-discipline/references/critical-rules-discipline.md:607-625 邻域交叉锚
  **Verify command**: grep -nE 'intent-switch 回切|94\.4|封存待 resume|回切触发|SKILL\.md「终验交付」|挂起计划回切检查|【计划回切通告】|Skill\("plan-resume"\)|不自动切' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -nE '^### 94|94\.4' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md
- [ ] VC-5: scope 与恢复路由约束可观察（改动仅两受管文件；plan-resume 在位且本任务不改其实现，回切复用 Skill("plan-resume")）
  Evidence: git diff --name-only（worktree/主仓）+ 只读存在性校验
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git diff --name-only -- skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md; test -f /home/terry/.zcode/skills/plan-resume/SKILL.md && echo plan-resume-present
- [ ] VC-6: 计划文档与验证载体完整可执行（task_plan/verification/knowledge-brief/findings/progress 关键区块齐备；verification 各 VC 含 Verify command；R1→VC 映射与 CA 表在位）
  Evidence: plans/task-intentresume-20261116/{task_plan,verification,knowledge-brief,findings,progress}.md
  **Verify command**: grep -nE '^template_type:|^plan_tier:|^execution_lane:|## Goal|R→VC|Verification Contract|## Phases|隔离决策|变更标注表' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/task_plan.md && grep -n '\*\*Verify command\*\*' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/verification.md

---

## Phase Gates

### Phase 1: 诊断与回切方案计划定稿

**Goal**: 固化回切缺口诊断、锚点证据与 S1-S3 最小增强方案并落盘六文档

**Depends on**: none

**Done when**:
- [x] findings 含 M1-M12、R-1~R-4、S1-S3、证据摘录
- [x] task_plan 含 R1/Goal/R→VC/VC/Phases+S-unit/CA/隔离决策/Goal 单元表
- [x] verification/knowledge-brief/progress 已填充并与计划一致

**Verification** (run before moving on):
- [ ] V-1.1: VC-1 诊断锚点可检索
  **Verify command**: grep -nE 'M1|M12|R-1|R-4|S1|S2|S3' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/findings.md
- [ ] V-1.2: VC-6 计划/验证结构锚点齐备
  **Verify command**: grep -nE '^template_type:|R→VC|Verification Contract|变更标注表' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/task_plan.md && grep -c '\*\*Verify command\*\*' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/verification.md

Status: `complete` Last verified: 2026-11-16

---

### Phase 2: 回切闭环机制增强实现（worktree）

**Goal**: 在 SKILL.md 落地终验回切检查与回切通告模板，在 discipline Rule 94 落地回切交叉锚

**Depends on**: Phase 1, D1 批准, worktree 就绪

**Done when**:
- [ ] SKILL.md 含挂起计划回切检查条款与回切通告模板（含不自动切、yes/no、回切状态）
- [ ] discipline:619 后含 intent-switch 回切交叉锚且 94.4/`^### 94` 语义锚在位

**Verification**:
- [ ] V-2.1: VC-2 终验回切检查条款 token 命中
  **Verify command**: grep -nE '挂起计划回切检查（intent-switch 回切）|outcome 判定后|归档前|\[intent-switch\]|旧=<id>|plans/INDEX\.md|Skill\("plan-resume"\)|不自动切|回切状态' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] V-2.2: VC-3 回切通告模板 token 命中
  **Verify command**: grep -nE '回切通告模板|【计划回切通告】|B 已收口|检测到挂起链|是否切回' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
- [ ] V-2.3: VC-4 Rule 94 回切交叉锚与权威锚命中
  **Verify command**: grep -nE 'intent-switch 回切|94\.4|封存待 resume|回切触发|SKILL\.md「终验交付」|挂起计划回切检查|【计划回切通告】|Skill\("plan-resume"\)|不自动切' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -nE '^### 94|94\.4' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md

Status: `pending` Last verified: —

---

### Phase 3: 回归验证与同步核验

**Goal**: 全量执行 VC 命令、确认 scope/sync 与 plan-resume 未改

**Depends on**: Phase 2

**Done when**:
- [ ] VC-1~VC-6 证据记录且命令可复现
- [ ] 103.6 多文件变更集同步核对清单全绿

**Verification**:
- [ ] V-3.1: VC-5 scope 与 plan-resume 约束通过
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git diff --name-only -- skills/task-planner/SKILL.md skills/task-discipline/references/critical-rules-discipline.md; test -f /home/terry/.zcode/skills/plan-resume/SKILL.md && echo plan-resume-present
- [ ] V-3.2: VC-1~VC-4,VC-6 计划与文档锚点复验
  **Verify command**: grep -nE 'M1|M12|R-1|R-4' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/findings.md && grep -n '\*\*Verify command\*\*' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/verification.md

Status: `pending` Last verified: —

---

### Phase 4: Code Review、终验与交付

**Goal**: CR 通过、VC 全绿、R1 目标达成裁决并形成可交付结论

**Depends on**: Phase 3

**Done when**:
- [ ] code-review APPROVED（required）
- [ ] 核心目标达成裁决填写，收尾回读梳理收敛

**Verification**:
- [ ] V-4.1: VC 全量复验（run-verification 或逐条命令）
  **Verify command**: grep -nE '^template_type:|R→VC' /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/task_plan.md
- [ ] V-4.2: 交付前计划完整性门（由主进程执行 check-complete/archive 前置条件）
  **Verify command**: test -f /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/task_plan.md && test -f /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116/verification.md && echo plan-files-present

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| skills/task-planner/SKILL.md:130-145,193,202-204 | S1/S2 落点与 VC-2/VC-3 token 对照 | （终验填写） |
| skills/task-discipline/references/critical-rules-discipline.md:607,615,619 | S3 交叉锚与 94.4/`^### 94` 保持对照 | （终验填写） |
| plans/archive/task-intentswitch-20261116/{task_plan,findings}.md | findings M12/方案衔接引用 | （终验填写） |
| /home/terry/.zcode/skills/plan-resume/SKILL.md（只读） | VC-5 未改且路由复用 `Skill("plan-resume")` | （终验填写） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-intentresume-20261116
```

JSON 输出：
```json
{终验粘贴}
```

- [ ] 主进程直做 Phase/S-unit 均在计划字段登记白名单内例外理由（Rule 25.3）
- [ ] 委派率 < floor 或含白名单外理由或 stats verdict=violation → 按规则回炉/降级

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — B 收口后主动回切挂起计划 A（用户确认，不自动切）
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
- [ ] VC-3: {evidence} → PASS/FAIL
- [ ] VC-4: {evidence} → PASS/FAIL
- [ ] VC-5: {evidence} → PASS/FAIL
- [ ] VC-6: {evidence} → PASS/FAIL

outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。
**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。
**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3 延伸）。

---

## 交叉验证记录（Rule 108）
<!-- 触发面：L2+/≥2受管文件改动；mini/L0 豁免。未触发登记原因；触发但单路径=FAIL。 -->

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|----------|------------------------|--------------------------|------------------------------|
| 回切条款与锚点 | VC-1~VC-6 grep/git diff | CR/code-review 复检结论 | （终验填写） |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 complete, pending D1 批准后 Phase 2 |
| 2 | Where am I going? | Phase 2(S1-S3)→Phase 3(VC)→Phase 4(CR/终验/交付) |
| 3 | What's the goal? | B 收口后主动检测挂起链并在用户确认下回切 A（不自动切） |
| 4 | What have I learned? | findings.md（M1-M12, R-1~R-4, 方案/锚点） |
| 5 | What have I done? | Phase 1 计划六文档落盘与锚点实测 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务外；回切检查实现后将扫描 [intent-switch] 链+INDEX） |
