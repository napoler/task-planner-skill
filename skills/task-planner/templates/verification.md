# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架仅供 init，VC 与 Phase Gates 经 planctl add --section vcs / vc-pass|vc-fail 写入后 render 派生——直接填写会在首次 render 被覆盖；领域段(task-json-template-20261125)：JSON 模板为源；plan-state.json 的 template_doc/template_checks 为权威，task_plan.md 为 render 派生视图；template_body 仅旧计划兼容（deprecated）-->

## Goal (1 sentence)

[One sentence describing the end state — must be objectively verifiable]

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。
> 禁反引号包裹与尾注；若误写，执行器按 canonical 命令归一化（仅容错，非推荐写法）[2026-11-25 task-skill-deploy-fix A8]。

- [ ] VC-1: [判定标准：可观察判据]
  Evidence: [file path / command output]
  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被 attest vc-gate 拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>
- [ ] VC-2: [判定标准：可观察判据]
  Evidence: [file path / command output]
  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被 attest vc-gate 拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>
- [ ] VC-3: [判定标准：可观察判据]
  Evidence: [file path / command output]
  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被 attest vc-gate 拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>
- [ ] VC-4: [判定标准：可观察判据]
  Evidence: [file path / command output]
  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被 attest vc-gate 拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>
- [ ] VC-5: [判定标准：可观察判据]
  Evidence: [file path / command output]
  **Verify command**: <可执行纯命令——禁占位（must be runnable 类模板串会被 attest vc-gate 拒）；禁真空（true/echo 类）；命令须引用本 VC 产出物；判据=退出码>

> **输出示例对照（Rule 113）**：凡 VC 判定标准涉及输出格式/结构（JSON/Markdown 表格/YAML/文件树/API payload 等），须在 `task_plan.md`「🧩 输出示例与格式契约」区块有对应 `output_examples` 条目（完整示例 + 同结构可复用模板 + `vc_refs` 指向本 VC）；验收时产出形态与示例不一致 = VC 未通过，禁仅凭命令退出码放行。

## 域适配说明：基线-产物逐条核验表（Rule 84.15）
<!-- 说明性区块（2026-11-26 task-spec-consumption-chain S14）：表体由 `planctl render` 从 `plan-state.json#spec_baseline` 自动生成（仅存在 SPEC-* 行时生成同名区块），模板侧只写列定义与填写规则，禁预置同名表体，避免 render 覆盖/双表冲突 -->
- 列定义：`spec_id` | `双向判定式`（区间上下界齐全，禁单边） | `校验命令`（可执行纯命令） | `观测`（命令实测输出） | `证据锚(path:line 或回执)` | `结论`（PASS/FAIL）。
- 填写规则 note：存在 SPEC 行时逐条必填（缺行=终验 FAIL），观测/结论未取到显式写「待终验」；无基线任务经 spec-scan 确认后填 `none`，禁静默留空；终验 `check-spec-baseline.sh <plan-dir> --final`（判定器）经 check-complete.sh SPEC-GATE 消费 未逐条验真不得判 COMPLETE（Rule 51.15/84.15）。

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
  **Verify command**: <命令>
- [ ] V-1.2: [mapped to VC-? or custom]
  **Verify command**: <命令>

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
  **Verify command**: <命令>
- [ ] V-2.2: ...
  **Verify command**: <命令>

Status: `pending` Last verified: —

---

### Phase 3: {Name}

...

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash {{TASK_PLANNER_ROOT}}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash {{TASK_PLANNER_ROOT}}/scripts/check-delegation.sh stats <plan-dir>
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由或 stats verdict=violation → check-complete.sh `exit 1` 阻断交付,须按 violations 清单回炉补 plan 或转 PARTIAL 重跑

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — {Goal 语句}
对照 Verification Contract 逐条复验：
- [ ] VC-1: {evidence} → PASS/FAIL
- [ ] VC-2: {evidence} → PASS/FAIL
...

 outcome: COMPLETE / PARTIAL / BLOCKED
 confirmed: false # BLOCKED 时须用户确认后改 true
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
| {VC/交付物/产出} | {cmd + exit/摘录 + 证据路径} | {复检体/critic + 结论 + 证据路径} | 一致 PASS / 分歧→{第三方裁决+留痕} |

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase N |
| 2 | Where am I going? | Remaining phases |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
