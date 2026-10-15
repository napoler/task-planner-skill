# Verification Contract & Phase Gates

## Goal (1 sentence)

把「修正 skill 确保某类 bug 不再出现」的制度层诉求被执行偏差为实例层修复的现象,制度化为 Rule 31.8 诉求层级契约条款(skill 文本,纯增量),确保同类偏差被规则拦截。

---

## Verification Contract (≥5 items, objective standards)

> mini 档 VC ≥2(Rule 38.4②);本任务 3 条,均含可执行验证命令(Rule 84.1)。

- [x] VC-1: 31.8 条款在位且五段完整
  Evidence: `grep -o "31\.8" skills/task-discipline/references/critical-rules-discipline.md`=1(标题唯一出现);五段锚 ①制度层/②实例层/③双层/④存疑/⑤31.3 衔接 grep -o 全命中(见 progress.md Test Results;VC 原文「grep -c ≥5」系口径措辞误差,单行条款格式下以五段锚达成意图,[corrected] 已登记)
- [x] VC-2: 纯增量零回归(既有子条零改动)
  Evidence: `git diff --stat` = 2 insertions(+), 0 deletions(-);`bash ~/.zcode/skills/task-planner/scripts/selftest-error-loop.sh` = Total: 16 PASS=16 FAIL=0
- [x] VC-3: 交付前单波 fresh 全量零 FAIL
  Evidence: `bash skills/task-planner/scripts/run-selftests.sh` = Total: 81 PASS=81 FAIL=0 (run=81 reused=0)

---

## Phase Gates

### Phase 1: Rule 31 追加 31.8(实施+验收合一)

**Goal**: 31.8 五段子条落入 critical-rules-discipline.md Rule 31 段末,纯增量零回归

**Depends on**: none

**Done when**:
- [x] 31.8 条款在位(VC-1)+ diff 纯增量(VC-2)+ 全量零 FAIL(VC-3)

**Verification** (run before moving on):
- [x] V-1.1: git diff 仅新增行 → mapped to VC-2
- [x] V-1.2: selftest-error-loop + fresh 全量 → mapped to VC-2/VC-3

Status: `complete` Last verified: 2026-10-16

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 38.7 L0-T 档(critical-rules-template.md:49) | 变更面=单 .md 纯文本 ∧ 零新增脚本/键/hook;验证=存在性 grep+既有 selftest 子集+fresh 全量;簿记=单 commit | 符合 |
| Rule 74 变更吸收三判 | 补充条目只追加不替代(git diff 0 删除) | 符合 |
| Rule 61/64 偏移检查 | drift-checker 子代理派发,判定 ALIGNED,检查点 subagent-state/1-drift-checker.md + ledger drift_check 行 | 符合 |

## 委派统计复验（Rule 25.4）

L0-T 主进程直做(Executor 字段白名单②⑥登记),check-complete LANE-L0 skip DELEGATION GATE(38.7 thin,无委派统计面)——机器 skip 已留痕,本节按 L0 薄化豁免。

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 0 项,豁免 0 项,未处置 0 项
- [x] Evidence 抽查 ≥3 条:git diff 输出/selftest 两级输出/31.8 五段锚 grep,均主进程亲验可复现(progress.md Test Results 附命令原文)
- [x] 豁免登记:无
- [x] 存在未处置违规 → 无

## 全量终验（fresh 单波,交付前）

```bash
bash skills/task-planner/scripts/run-selftests.sh
# 末行原文:
Total: 81 PASS=81 FAIL=0 (run=81 reused=0)
```

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 制度层偏差制度化进 skill(Rule 31.8),同类偏差被规则拦截
对照 Verification Contract 逐条复验：
- [x] VC-1: 五段锚 grep 全命中+条款在位 → PASS
- [x] VC-2: diff 2+/0- + selftest-error-loop 16/16 → PASS
- [x] VC-3: fresh 全量 81/81 FAIL=0 → PASS

 outcome: COMPLETE
```

**遗留(不在本任务 scope,待用户授权)**：部署位同步(~/.zcode/skills/task-discipline/references/critical-rules-discipline.md 与仓内 diff 待用户单独授权后同步;宪法 §六 保护区+历史判例)。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 complete,终验交付 |
| 2 | Where am I going? | 归档+交付报告 |
| 3 | What's the goal? | Rule 31.8 制度化落地 |
| 4 | What have I learned? | 见 findings.md/notepad |
| 5 | What have I done? | 见 progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
