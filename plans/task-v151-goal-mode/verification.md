# Verification Contract & Phase Gates — task-v151 终验档案

## Goal (1 sentence)

task-planner 技能新增 Rule 66「goal 单元固化与 /goal 驱动推进纪律」：规划获批后任务自动分解固化为 goal 单元（goal-id+任务名+目标+完整验证方式），执行按 goal 逐个调度推进、验证通过才翻 complete，并与 ZCode 内置 /goal 命令做映射供料，确保后期执行可靠性。

---

## Verification Contract（逐条终验，2026-10-10 复验）

- [x] VC-1: critical-rules.md 含 Rule 66 六子条；SKILL.md Rule 66 登记+1-66 计数级联完成
  Evidence: `grep -c '^66\.[1-6] ' skills/task-planner/references/critical-rules.md` = 6（行 848-860）；SKILL.md 行 9/281/362 `1-66` 三处 + Rule 66 摘要行 + C45 合规行；检查点 03-executor-S1（S1 三行验证输出）
- [x] VC-2: 模板含「🎯 Goal 单元表」区块 + check-plan-dispatch.sh attest 期四要素机械校验（缺列/缺验证方式=拒锁）
  Evidence: 模板行 104 起六列表头；66.5 段行 314 起（档位三分支：显式 standard|full 硬门/mini 豁免/无标记缺省跳过——S4b D2 裁决）；正样本（本计划 G1-G6）66.5 违规=0、剥离区块负样本 rc=1（检查点 10/15 三态试跑原文）
- [x] VC-3: check-complete.sh 终验追加 Goal 单元表逐行对照（验证方式证据 vs 状态，未完成禁 COMPLETE）
  Evidence: [goal-gate] 段行 1212 起（CR F2 后档位口径与 66.5 统一：grep 显式 standard|full）；G2 pending 时实测输出「[goal-gate] ⚠ 有 goal 未 complete (G2), 终态最高 PARTIAL」，G2 翻 complete 后该提示消失（终验 exit 0 输出）
- [x] VC-4: 新 selftest-goal-unit-goal-mode.sh 全 PASS 且登记 registry
  Evidence: `bash scripts/selftest-goal-unit-goal-mode.sh` → `Total: 9 PASS=9 FAIL=0` exit 0；registry.tsv 末行含新脚本（wc -l = 65）；全量回归 final-regression.log「scripts=64 ΣFAIL=0」
- [x] VC-5: 零回归 + 部署位同步后 diff 空
  Evidence: 全 selftest ΣFAIL=0（final-regression.log）；zcode/cursor/claude 三位置 8 核心文件 cmp 全 OK（部署位 SKILL.md 平台前缀差异=install 固有定制面，8 文件口径判定）；master ebb5fba（feat 101475f + CR 修复 6cf8cd7）+ 7fa66ac（S9 官方文档 66.2 增强 d56276e）

---

## Phase Gates

### Phase 1: 需求定稿与 /goal 实证
**Done when**: R1-R5 逐字落盘 + /goal 无程序化触达面实证 + 检查点 01-explore
Status: `complete` Last verified: 2026-10-10

### Phase 2: 机制设计定稿（worktree + 基线 + 设计草案）
**Done when**: worktree 创建且 5 关键文件 vs 部署位 diff OK + baseline ΣFAIL=0 + design-draft.md 含 66.1-66.6 草案+钉值清单
Status: `complete` Last verified: 2026-10-10

### Phase 3: 实现（worktree 内，逐 S-unit 派发）
**Done when**: S1-S4+S4b 全交付 + 回归 ΣFAIL=0
Status: `complete` Last verified: 2026-10-10

### Phase 4: Code Review Gate
**Done when**: 全量 CR + CHANGES F1-F3 修复闭环（6cf8cd7）
Status: `complete` Last verified: 2026-10-10

### Phase 5: 交付与合并回
**Done when**: smart-merge 合并回 + worktree/分支清理 + 部署对账 + rule-reserve land 66 + check-complete exit 0
Status: `complete` Last verified: 2026-10-10

### Phase 6: 官方文档对照与重 CR（用户追加）
**Done when**: 官方 /goal 文档落盘（09 检查点）+ 重 CR 偏差裁决（15 检查点，必须修 0/增强 2）+ 增强落地 7fa66ac + 三部署位对账
Status: `complete` Last verified: 2026-10-10

---

## Goal Gate 终验（2026-10-10 复跑）

```
Goal Verification — Rule 66 全链落地且零回归
对照 VC 逐条：
- [x] VC-1: critical-rules 66 六子条 grep=6 + SKILL 级联 → PASS
- [x] VC-2: 模板 Goal 单元表 + 66.5 四态实测 → PASS
- [x] VC-3: [goal-gate] 三语义实测（G2 pending 时拦截提示在位，全 complete 后消失） → PASS
- [x] VC-4: 新 selftest 9/9 + registry + 全量 ΣFAIL=0 → PASS
- [x] VC-5: 三部署位 8 文件 cmp OK + master 7fa66ac 终态 → PASS
check-complete.sh plans/task-v151-goal-mode/task_plan.md exit=0（仅剩 warn 档提示：rcov 覆盖核对表=51.1a 登记面/warn 不阻断，见下方回填）
outcome: COMPLETE
```

## 需求覆盖核对表（Rule 51.1a — 51.3 终验载体）

| R | 状态 | 证据路径 |
|---|------|---------|
| R1 | covered | plans/task-v151-goal-mode/subagent-state/03-executor-S1.md（66 条款落地）+ worktree 提交 101475f git log |
| R2 | covered | subagent-state/10-executor-S4b.md（回归 ΣFAIL=0 行）+ 15-code-reviewer-S9.md（V1 偏差对照=官方写法要点对齐确认） |
| R3 | covered | subagent-state/00-goal-empirical.md（/goal 实证三处「不存在」结论）+ 09-goal-official-docs.md（官方文档定位=内置命令，与 R3 一致） |
| R4 | covered | critical-rules.md 行 856（66.4 分解→调度→逐个解决推进序）+ 检查点 04/06（模板+attest 段落地） |
| R5 | covered | task_plan.md Errors Encountered 表 R5 误判行 + Decisions veto 行 + ledger-main.jsonl error 事件 |

## 委派统计复验（Rule 25.4）

JSON 输出（check-delegation.sh stats plans/task-v151-goal-mode 原样）：
```json
{"phases_total":6,"phases_delegated":4,"main_direct_count":2,"delegation_rate":0.667,"main_direct":[{"phase":"2 机制设计定稿（worktree + 基线 + 设计草案）","executor":"主进程（例外理由:① git/worktree 编排 + ② 计划系统文件维护（design-draft/基线落盘属 plans/ 计划系统文件）——Rule 25.3 白名单）"},{"phase":"5 交付与合并回","executor":"主进程（例外理由:① git 编排（合并/清理/部署对账）+ ② 簿记（交付总结/账本/attest）——Rule 25.3 白名单）"}],"violations":[],"verdict":"ok"}
```
- [x] 主进程直做 2 条理由=白名单①②（check-complete 输出 WHITELIST-EXEMPT 面：rate=0.333 时因 S6/S8/S9 未登记曾判 violation，委派面清账后 verdict=ok）
- [x] 委派率 0.667 < floor 0.7 但全部直做理由命中 Rule 25.3 白名单 → WHITELIST-EXEMPT 放行（25.4）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查：触发 2 项（S4 回归 24 FAIL=22.3 兜底面/Q 降质无命中）、豁免 0 项、未处置 0 项
- [x] Evidence 抽查 3 条：检查点 03/04/10 三处 grep 输出原文可 Read（本轮终验已复跑 grep -c '^66.'=6 复验通过）
- [x] 豁免登记：无（Q3 不适用——本任务无伪造证据面）

## Goal Gate (终验)
> outcome: **COMPLETE**（全部 VC 通过；Goal 单元表 G1-G6 全 complete 且 [goal:G1..G6] 证据行逐落在 progress.md）

**遗留面（不阻塞 COMPLETE，登记在 delivery-summary 风险点）**：仓内 .backup 目录外移（用户裁决）、新会话 /goal 行为面冒烟（需新会话）、宪法 §一 同步（保护区文件须授权）。
