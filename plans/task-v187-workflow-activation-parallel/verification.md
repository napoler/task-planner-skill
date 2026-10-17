# Verification Contract & Phase Gates

## Goal (1 sentence)

把 task-planner 工作流路由从「仅用户显式点名」演进为「用户常设授权+命中编排条件主动创建（含按难度模型分档）」，并消除并行调度的声明制惰性串行——使复杂任务实际走 CreateWorkflow 推进、工作流子代理按难度分档、无依赖 S-unit 默认并行。

---

## Verification Contract (≥5 items, objective standards)

> 路径缩写：`<WT>` = `/home/terry/task-planner-skill-worktrees/task-v187-workflow-activation-parallel`（worktree）；`<REPO>` = `/mnt/data/dev/task-planner-skill`。Phase 2/3 判定在 `<WT>` 下跑，Phase 4 合并后在 `<REPO>` 复跑。

- [ ] VC-1: collab.md Rule 39.1 演进+39.8 常设授权在位（39.1 含常设授权语义且非唯一显式触发；39.8 三要素齐）
  **Verify command**: `COLLAB=<WT>/skills/plan-collab-router/references/critical-rules-collab.md; grep -c "常设授权" "$COLLAB"`
  判据：输出 ≥2（39.1+39.8 各 ≥1）
  Evidence: progress.md Phase 2 段 grep 输出粘贴
- [ ] VC-2: SKILL.md 摘要行演进（旧锁死措辞清零+新语义在位）
  **Verify command**: `grep -c "仅用户显式点名" <WT>/skills/task-planner/SKILL.md <WT>/skills/plan-collab-router/SKILL.md; grep -cE "主动创建|主动激活|命中编排条件" <WT>/skills/task-planner/SKILL.md`
  判据：前半两文件计数均=0；后半 ≥1
  Evidence: progress.md Phase 2 段输出
- [ ] VC-3: Rule 91 分档联动+run 级 subagent_model 选档条款在位
  **Verify command**: `COLLAB=<WT>/skills/plan-collab-router/references/critical-rules-collab.md; grep -c "39.8" "$COLLAB"; grep -c "subagent_model" "$COLLAB"`
  判据：39.8 命中 ≥2（定义+91 联动）；subagent_model ≥1
  Evidence: progress.md Phase 2 段输出
- [ ] VC-4: 并行强化双条款在位（21.4.2 执行期扩组协议+68.2 惰性串行论证义务）
  **Verify command**: `DISP=<WT>/skills/task-dispatch/references/critical-rules-dispatch.md; grep -c "21\.4\.2" "$DISP"; grep -cE "惰性|全串行" "$DISP"`
  判据：21.4.2 ≥1；惰性/串行论证锚 ≥1
  Evidence: progress.md Phase 2 段输出
- [ ] VC-5: 锚级联同步+全量回归 ΣFAIL=0（worktree 验证+合并后主仓复跑双过）
  **Verify command**: `cd <WT>/skills/task-planner/scripts && for f in selftest-*.sh; do bash "$f" 2>&1 | tail -3; done | grep -cE "FAIL=[1-9]|ΣFAIL=[1-9]|FAIL: [1-9]"`
  判据：输出 =0（无非零 FAIL）
  Evidence: progress.md Phase 3 段回归输出；Phase 4 主仓复跑输出
- [ ] VC-6: 合并回主仓+部署位同步（scope 干净+部署位 IDENTICAL；部署须用户已授权）
  **Verify command**: `git -C <REPO> status --short | grep -cE "^.. skills/"; diff -rq <REPO>/skills/task-planner /home/terry/.zcode/skills/task-planner 2>/dev/null | grep -c "."`
  判据：scope 未提交变更=0；部署位差异行=0（部署执行后）
  Evidence: progress.md Phase 4 段输出+交付总结

---

## Phase Gates

### Phase 1: 诊断固化与修订方案定稿

**Goal**: findings.md 含断言面清单+四形态族扫描+四档映射摘要+六段方案定稿全文，Phase 2 可照单派发。

**Depends on**: none

**Done when**:
- [ ] S0 explore 返回并回填 findings §断言面清单
- [ ] 主进程落 findings §方案定稿（39.1/39.8/40.4/91/21.4.2/68.2 六段全文）

**Verification** (run before moving on):
- [ ] V-1.1: 方案六段锚完整（mapped to VC-1, VC-3 预检）——`grep -cE "^#+ (39\.1|39\.8|40\.4|91|21\.4\.2|68\.2|S4 消费侧)" /mnt/data/dev/task-planner-skill/plans/task-v187-workflow-activation-parallel/findings.md` ≥6
- [ ] V-1.2: 断言面侦察清单在位（mapped to VC-5 级联前置）——`grep -c "断言面" /mnt/data/dev/task-planner-skill/plans/task-v187-workflow-activation-parallel/findings.md` ≥1

Status: `pending` Last verified: —

---

### Phase 2: 规则文本修订（三波派发）

**Goal**: CA-1..CA-7 全部落地（五个文件六段条款），grep 断言全过。

**Depends on**: Phase 1

**Done when**:
- [ ] W1（S1∥S5）→ W2（S2∥S4）→ W3（S3）三波完成，逐段 Read 复核

**Verification**:
- [ ] V-2.1: mapped to VC-1（39.1/39.8 grep 断言）
- [ ] V-2.2: mapped to VC-2（SKILL 摘要行 grep 断言）
- [ ] V-2.3: mapped to VC-3（91 联动 grep 断言）
- [ ] V-2.4: mapped to VC-4（21.4.2/68.2 grep 断言）

Status: `pending` Last verified: —

---

### Phase 3: selftest 锚级联与全量回归

**Goal**: 受影响 selftest 锚同步至新措辞，全量回归 ΣFAIL=0，四形态族清零。

**Depends on**: Phase 2

**Done when**:
- [ ] S6/S8 锚同步+单脚本全 PASS；S7 全量回归 ΣFAIL=0
- [ ] 四形态族 worktree 内 grep 清零

**Verification**:
- [ ] V-3.1: mapped to VC-5（回归 ΣFAIL=0）
- [ ] V-3.2: 四形态族清零——`grep -rEc "仅用户显式点名|不得自主判断" <WT>/skills --include="*.md" | grep -cE ":[1-9]"` =0

Status: `pending` Last verified: —

---

### Phase 4: 合并回主仓+部署同步+交付

**Goal**: CR APPROVED→合并 master→清理 worktree→主仓复验→部署同步（授权点）→交付归档。

**Depends on**: Phase 3

**Done when**:
- [ ] CR Gate APPROVED；smart-merge-back 完成；VC-5 主仓复跑过；部署 diff=0；delivery-summary 出具

**Verification**:
- [ ] V-4.1: mapped to VC-5（主仓复跑）
- [ ] V-4.2: mapped to VC-6（scope 干净+部署位 diff=0）

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 官方 CreateWorkflow 工具描述（run 级 subagent_model 等） | 91 联动条款措辞对照工具 schema 事实 | 待终验 |
| collab.md Rule 39/40/91 原文 | 修订 diff 对照不变量③④（39.2-39.7/91.2 未动） | 待终验 |
| dispatch.md Rule 21.4/68 原文 | 修订 diff 对照不变量⑤（四问+组间串行未回退） | 待终验 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v187-workflow-activation-parallel
```

JSON 输出：
```json
{"phases_total":4,"phases_delegated":2,"main_direct_count":2,"delegation_rate":0.5,"main_direct":[{"phase":"1 诊断固化与修订方案定稿","reason":"② 计划系统文件维护——Rule 25.3 白名单（方案定稿主进程单写者，登记于 checklist）"},{"phase":"4 合并回主仓+部署同步+交付","reason":"① git 编排+② 簿记——Rule 25.3 白名单；CR 子步骤派 critic"}],"violations":[],"verdict":"ok"}
```
（2026-10-18 03:10 实跑；Executor 字段净化后：组标记/混合注记曾致 violation 误报已修——教训记 notepad）

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单：Phase 1=②、Phase 4=①②）
- [x] stats verdict=ok / violations=0（委派率 0.5 由 2 个白名单主进程 Phase 构成，非违规）

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 三缺陷修复（工作流主动激活/模型分级/并行度）
对照上方 Verification Contract 六条逐条复验（命令同 VC-1..VC-6 的 Verify command，主仓复跑）：
- [ ] 复验①（工作流激活条款）: {evidence} → PASS/FAIL
- [ ] 复验②（SKILL 摘要行）: {evidence} → PASS/FAIL
- [ ] 复验③（91 分档联动）: {evidence} → PASS/FAIL
- [ ] 复验④（并行强化条款）: {evidence} → PASS/FAIL
- [ ] 复验⑤（全量回归）: {evidence} → PASS/FAIL
- [ ] 复验⑥（合并+部署）: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
