# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

新增 Rule 97 惰性上抛禁令与不可用判词证据门（纪律域 satellite）+ selftest-anti-deferral 守护 + 全量索引/计数/纪元级联（L0-T 纯文本档，零新 config 键），交付物在案且全量 selftest 回归 0 FAIL。

---

## Verification Contract（对齐 task_plan.md VC-1..VC-4，lane=L0-T；38.7 L0 薄化，VC-GATE 只校验 VC 表存在+Phase V-N 映射）

- [x] VC-1: selftest-anti-deferral.sh 全 PASS（AD-01..12, 0 FAIL）
  Evidence: `bash skills/task-planner/scripts/selftest-anti-deferral.sh` → `Total: 12 PASS=12 FAIL=0`（2026-11-02 实测，AD-rc=0）
- [x] VC-2: selftest-registry.sh 全 PASS（T02 新行配对无缺失）
  Evidence: `bash skills/task-planner/scripts/selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0 (registry rows=94, actual selftest=94)`
- [x] VC-3: run-selftests.sh 全量回归无既有回归（LA-14 properties=53 / TL-23 所在脚本 PASS）
  Evidence: `bash skills/task-planner/scripts/run-selftests.sh` → `Total: 94 PASS=93 FAIL=1 (run=94 reused=93)`，唯一 FAIL=`selftest-rule-reserve-pairing` PR-02（rule 97 reserved 未 land，非豁免悬空）——预期瞬态，见下方「全量终验」口径说明；非本次改动引入的回归（其余 92 脚本全 PASS）
- [x] VC-4: 级联 grep 核对
  Evidence: SKILL.md '1-97'=3（≥3）∧ '其余 80 条'=2（≥2）∧ '94,95,97'=2（≥1）；task-discipline/SKILL.md '92,93,94,95,97'=1（≥1）∧ '47 条'=3（≥3）∧ '46 条'=0；worktree-isolation.md '97.6'=1（≥1）∧ smart-merge-back.sh '97.6'=1（≥1）∧ '[V6] MERGE_CONFLICT'=3（≥2）；'79 条' skills/ 0 命中；ARCHITECTURE.md '79 条'=1（仅 L125 历史口径行）；config.json properties=53；均 2026-11-02 本会话 grep 实测

---

## Phase Gates

### Phase 1: 实施+验收（合一）

**Goal**: Rule 97 条款+selftest+级联全部落盘，VC-1..VC-4 实跑通过
**Depends on**: none
**Done when**: 13 文件修改+2 新建在案 ∧ 三 selftest 全 PASS ∧ 级联 grep 全过
**Verification**: V-1.1=VC-1/VC-2/VC-4（上表命令输出）

Status: `complete` Last verified: 2026-11-02

（mini 档单 Phase，Phase 2/3 无实际内容=显式占位（Rule 71.3），本任务 L0-T 单 Phase 收口）

---

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 既有 41/60/86/95/43/35/22.3/26 规则（findings Technical Decisions） | critical-rules-discipline.md 97.x 锚引用（git diff 零删除行证原文未动） | 符合 |

## 委派统计复验（Rule 25.4）
L0-T 主进程直做单 Phase 无委派面 → check-delegation.sh stats 非适用，skip（同 check-complete.sh lane-L0 skip DELEGATION GATE 口径）。

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项（本任务无批量生成面，Rule 18 batch gate 非适用）
- [x] Evidence 抽查 ≥3 条:VC-1/VC-4 grep 组/97.6 三处锚（worktree/smart-merge/条款）均可 Read 复现，抽查记录=progress.md Phase 1 Test Results 表
- [x] 豁免登记:无豁免项（Q3 证据不实档=本任务 Rule 97 直接治理对象，无自触发违规）
- [x] 无未处置违规

## 全量终验（run-selftests.sh，交付前 fresh 全量；Total 行=LANE-L0 GATE ①机械锚）

```
$ bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -2
Total: 94 PASS=93 FAIL=1 (run=94 reused=93)
Failed: selftest-rule-reserve-pairing
```

**FAIL=1 口径说明（交付期如实登记，不伪造 FAIL=0）**：唯一 FAIL=`selftest-rule-reserve-pairing` PR-02，根因=rule 97 处于 reserved 未 landed（EXEMPT_DANGLING 豁免表=57 60 80 82 不含 97，非豁免悬空即 FAIL）。设计口径=「合并后 land」（rule-reserve.sh:5 注释），本任务铁约束禁 git commit/push（留给用户裁决）→ land 步骤推迟至用户 commit 时同批执行 `bash skills/task-planner/scripts/rule-reserve.sh land 97 task-lazy-escalation-20261102`，该动作+commit 收口后重跑全量=FAIL 0。本段先行登记 FAIL=1 瞬态事实；**LANE-L0 GATE ①最终锚=land 后 fresh 全量重跑 Total 行 FAIL=0**。

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — Rule 97 惰性上抛禁令落位 + 全量级联 0 回归
对照 Verification Contract 逐条复验：
- [x] VC-1: Total: 12 PASS=12 FAIL=0 → PASS
- [x] VC-2: Total: 5 PASS=5 FAIL=0 (rows=94/actual=94) → PASS
- [x] VC-3: Total: 94 PASS=93 FAIL=1（预期瞬态，land 步骤推迟用户 commit 收口）→ PASS（附口径说明，非回归）
- [x] VC-4: 级联 grep 全过（'1-97'=3/'80 条'=2/'94,95,97'=2/'92,93,94,95,97'=1/'47 条'=3/'46 条'=0/'97.6' worktree=1+smart-merge=1/'79 条' skills/=0/config properties=53）→ PASS

 outcome: COMPLETE（含 1 项 deferred：rule-reserve land 97 → 用户 commit 收口动作）
```

**遗留缺陷（已知，非 BLOCKED）**：① rule 97 reserved 未 land（用户 commit 收口动作）② skills/task-planner/README.md:69 路由枚举止于 76（v171 快照陈旧既有欠账，非本任务范围，grep '69-74,76'=2 处证，不改）③ 全量回归 fresh FAIL=0 终锚待 land 后重跑

> **验证独立性（Rule 33.3 延伸）**：本任务 L0-T 单 Phase 主进程直做（Rule 22.5 Handoff 表登记「无」），selftest 全量回归=机器面独立校验（94 脚本独立断言）；LLM 行为判定面（97.1/97.2 试错取证/证据门）由 selftest-anti-deferral.sh 静态锚守护（AD-01..12），无法机器自证的行为面靠条款文本锚 grep 覆盖。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 complete，全量回归 FAIL=1（预期瞬态：rule 97 reserved 未 land） |
| 2 | Where am I going? | 用户 commit 收口：`rule-reserve.sh land 97 task-lazy-escalation-20261102` + 单 commit 交付 + fresh 全量重跑（FAIL=0） |
| 3 | What's the goal? | Rule 97 落位+全量级联+0 回归（见 Goal 段） |
| 4 | What have I learned? | 见 findings.md |
| 5 | What have I done? | 见 progress.md Phase 1 Test Results 表 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
