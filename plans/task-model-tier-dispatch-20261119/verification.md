# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 规则体系落地 Rule 110「任务分级×模型档位强制匹配」，堵住 sess_a7eb0603 判例暴露的纯机械操作整体占用大模型子代理的资源滥用路径。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 每条 VC 的 **Verify command** 行=attest vc-gate（attest-plan.sh:244-285）判据面——模板必须预置该行（缺失验证区块判例 task-tpl-verify-fix-20261113）。

- [ ] VC-1: Rule 110 全段在位（### 110 标题+110.1-110.7 七子条锚全命中）
  Evidence: skills/task-dispatch/references/critical-rules-dispatch.md 新增段
  **Verify command**: test $(grep -c '^### 110 ' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md) -eq 1 && test $(grep -cE '110\.[1-7] \*\*' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md) -eq 7
- [ ] VC-2: 契约模型边界+判例锚在 110 段内（sess_a7eb0603 判例锚入条款正文）
  Evidence: critical-rules-dispatch.md 110 段 Why 行
  **Verify command**: grep -A 8 '^### 110 ' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | grep -c 'a7eb0603' | grep -v '^0$'
- [ ] VC-3: 失效链堵点三锚在位（110.3 混合拆分/110.4 继承禁止/110.5 临场 tier-class token）
  Evidence: critical-rules-dispatch.md 110 段
  **Verify command**: grep -cE '110\.3 \*\*混合任务强制拆分|110\.4 \*\*继承档位传染禁止|110\.5 \*\*临场派发同约束' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md | grep '^3$'
- [ ] VC-4: SKILL.md 级联完成（1-110 计数≥3 处+Rule 110 双文件归属行）
  Evidence: skills/task-planner/SKILL.md + skills/task-dispatch/SKILL.md
  **Verify command**: test $(grep -c '1-110' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md) -ge 3 && test $(grep -cE '\| 110 \||68,110' /mnt/data/dev/task-planner-skill/skills/task-dispatch/SKILL.md) -ge 2
- [ ] VC-5: 零回归（既有 Rule 21.3/22.6/59.1/96.2/104 段原文零改动——行数守恒抽样+全量 selftest 基线）
  Evidence: git diff 判向 + run-selftests 输出落盘 progress.md
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git diff --stat master -- skills/task-dispatch/references/critical-rules-dispatch.md | grep -E '1 file changed, [0-9]+ insertion' | grep -v 'deletion'

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

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>
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
