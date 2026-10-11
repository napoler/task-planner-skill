# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能内建立 Rule 74 变更吸收三判纪律（增量默认+替代四条件门+删除逐项授权+逐条变更标注+定稿可行性判别门），以条文+SKILL 接线+模板区块+selftest 静态守护+全量回归+双审查闭环确保「补充不替代」不再复发。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [x] VC-1: Rule 74 条文完整落盘 critical-rules.md
  Evidence: `grep -cE "^74\.[1-6] " critical-rules.md` =6；标题 `### 74 变更吸收三判纪律` =1（Rule 71 段之后 EOF）
- [x] VC-2: 三判门语义在位
  Evidence: 条文含「增量（默认且优先）」/「四条件全满足才可」/「删除（最高门槛）」+「先问是补充还是替代」各 ≥1
- [x] VC-3: 触点接线在位
  Evidence: critical-rules.md 8.1/36.5/56 三段 grep "Rule 74"=3；SKILL.md 用户新指令处理段 T4+B 类行 T5 各 ≥1
- [x] VC-4: 变更标注表模板在位
  Evidence: templates/task_plan.md grep "📋 变更标注表"=1，六列关键词齐备，四类型串在位
- [x] VC-5: 可行性判别门载体在位
  Evidence: critical-rules.md 74.4 子条+「69.1」分工锚+mini 档豁免；templates/subagent_dispatch.md 契约段三维+三态；SKILL.md 终验段联动半句
- [x] VC-6: 机器守护在位且自跑
  Evidence: selftest-absorption-discipline.sh 14 pass/0 fail/0 skip exit 0；registry.tsv 登记行在位；config.json 零新键
- [x] VC-7: 无回归
  Evidence: master 全量 selftest 74 脚本 ΣFAIL=0 ΣPASS=1094；SKILL.md『1-74』pin ≥2 命中且级联 pinning 脚本锚全清
- [x] VC-8: 双审查+合并回+覆盖核对
  Evidence: code-reviewer=APPROVED；alignment-review CHANGES→S14 修复 10 条全修；smart-merge-back MERGED d45e8e2；R 覆盖核对表全勾

---

## Phase Gates

### Phase 1: {Name}

**Goal**: [1 sentence, what this phase produces]

**Depends on**: [previous phase or "none"]

**Done when**:
- [ ] {objective completion condition}

**Verification** (run before moving on):
- [ ] V-1.1: [mapped to VC-? or custom]
- [ ] V-1.2: [mapped to VC-? or custom]

Status: `pending` / `in_progress` / `complete` / `FAILED(3-strike)` Last verified: [date]

---

### Phase 2: {Name}

**Goal**: ...

**Depends on**: Phase 1

**Done when**:
- [ ] ...

**Verification**:
- [ ] V-2.1: ...
- [ ] V-2.2: ...

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

**机器统计为事实源，人工仅复核**：运行 `bash <skill>/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash <skill>/scripts/check-delegation.sh stats <plan-dir>
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
## Goal Verification — Rule 74 变更吸收三判纪律
对照 Verification Contract 逐条复验：
- [x] VC-1: grep=6+标题=1 → PASS
- [x] VC-2: 三档关键词+判据句各≥1 → PASS
- [x] VC-3: 触点 3+2 处 grep 命中 → PASS
- [x] VC-4: 变更标注表六列+四类型在位 → PASS
- [x] VC-5: 74.4+契约段+终验段联动在位 → PASS
- [x] VC-6: AD-01..14 自跑 exit 0 → PASS
- [x] VC-7: 74 脚本 ΣFAIL=0 → PASS
- [x] VC-8: 双审查 APPROVED+合并回 d45e8e2 → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**已知遗留（不阻塞）**：
- 部署位同步待用户授权（CA-14 deferred；v158 遗留债务：部署位 1-69+70 vs 主仓 1-74 diff 面）
- R2 标注层漂移（Phase 6/7/8 V-N 列与 VC 定义错位）——Phase 8 终验前未修正，属簿记层非语义层
- R3 74.3(b)「selftest 静态守护」措辞微强于实际机器面（AD-06/AD-13 只护模板锚/本计划）

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
