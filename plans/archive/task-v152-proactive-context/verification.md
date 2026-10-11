# Verification Contract & Phase Gates — task-v152-proactive-context

## Goal (1 sentence)
task-planner 技能新增 Rule 67「上下文压力主动评估与会话交接纪律」：三档信号主动评估上下文压力（HEALTHY/PRESSURE/CONFUSED），PRESSURE 命中即压缩整理，CONFUSED 兜底写会话交接文档转新会话，全链落地并三部署位同步。

## Verification Contract 终验（2026-10-10 07:4x）

- [x] VC-1: critical-rules.md 文末 Rule 67 六子条（67.1-67.6）在位含主动评估/主动优化关键词；既有条款零改动
  Evidence: worktree/主仓 `grep -cE '^67\.[1-6] '` =6、`grep -c '主动评估'`=5；`git show master:skills/task-planner/references/critical-rules.md | grep -n '### 6[6-9] '` = 66/67/68/69 编号序；五方并集零回归（regression-final.log 69/69/0）
- [x] VC-2: 三态 verdict + PRESSURE 即压缩（不等 Phase complete）+ 29.2 引用
  Evidence: critical-rules Rule 67.2/67.3 段（:865-875）；冒烟双态 run1/run2.out（subagent-state/7-code-runner-S6-*.out）
- [x] VC-3: templates/session-handoff.md 五段+恢复链锚
  Evidence: 五段标题 grep 各=1；session-catchup/62.1/plan-resume 锚≥1；master 已含（git show master:…templates/session-handoff.md）
- [x] VC-4: hook 单 emit 双行承载+env 降档+零新 config 键+实弹冒烟
  Evidence: zcode-posttooluse.sh [context-pressure] 块（TASK_PLANNER_CONTEXT_PRESSURE/_N，_cpn/rhythm_n 双除零）；冒烟 run1 lines=1 双段/run2 off=仅 drift；`jq '.properties|length' config.json`=42
- [x] VC-5: 新 selftest 9/9 + registry 登记 + SKILL 级联（时点口径 1-67；主仓演进后由 v158 承接为 1-(69|71) 宽容锚仍 9/9）+ 回归零新增 + 三部署位 diff=0
  Evidence: 交付态 selftest-context-pressure 9/9（部署位实弹同 9/9）；主仓现行 9/9（v158 0cea211「CP-07 纪元宽容化」）；regression-final.log 69/69/0；三部署位 IDENTICAL（a7b1619 刻对账）

## Phase Gates

- Phase 1 设计定稿 → complete（drift ALIGNED tick4；design-draft.md 四段）
- Phase 2 worktree+基线 → complete（drift ALIGNED tick8；baseline 63/63/0）
- Phase 3 实施（13+4 单元）→ complete（drift ALIGNED tick9；改动集恰=scope）
- Phase 4 验证 → complete（drift ALIGNED tick12；64/64/0+冒烟）
- Phase 5 CR Gate → complete（drift ALIGNED；round2 APPROVED，990 PASS）
- Phase 6 终验合并回 → complete（drift tick19 DRIFT=收尾缺口→补齐→复核确认；master a7b1619；land 67）

## 📚 必要知识储备符合性核验（终验项）

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| Rule 29/64.5-64.6/65 原文锚 | design-draft §1 引用+67.x 与既有条款衔接措辞 | 符合（六处交叉引用全实存） |
| posttooluse drift-rhythm 块 | S4 施工+CR 复核+冒烟 | 符合（F9 单 emit/F10/三键零改动实测） |
| 钉值/登记面 | 16 文件并集+S2-S17 修复 | 符合（C49 让位链/v158 归属确认） |
| 编号账本 | attest 查重+land | 符合（67 reserved→landed） |

## 委派统计复验（Rule 25.4）

```json
{"phases_total":6,"phases_delegated":3,"main_direct_count":3,"delegation_rate":0.500,"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 3 Phase 均登记白名单例外（①git/worktree编排 ②计划系统文件维护）
- [x] rate 0.5 < 0.7 但 violations=[] + 全白名单 → Rule 25.4a WHITELIST-EXEMPT 放行（check-complete 机器口径 verdict=ok）

## 质量门控统计（Rule 26）

- Q1 伪造证据=0（全部结论带 file/命令锚）；Q2 验证缩水=0（fix-wave 六修全实测）；Q3 未验证当已完成=0；Q4 范围蔓延=0（B 类扩展全登记 Decisions）；Q5 静默降级=0（provider 失败×3 均按 22.3 换道并登记）；Q6 流程仪式挤占=0
- Evidence 抽查 3 条：① selftest-context-pressure.sh（Read+跑 9/9）② 7-code-runner-S6-run1.out（Read+冒烟复现）③ rule-reservations.jsonl 末行（67 landed）
- 豁免登记：无

## Goal Gate（终验）

- [x] VC-1 → PASS ｜ [x] VC-2 → PASS ｜ [x] VC-3 → PASS ｜ [x] VC-4 → PASS ｜ [x] VC-5 → PASS
- **outcome: COMPLETE**

> 验证独立性：验证动作由 8 个独立子代理执行（code-runner S6/code-reviewer S7 两轮/drift-checker×6 轮/alignment-review×1），主进程仅编排与簿记。

## 需求覆盖核对（Rule 51.3）

| 需求# | 用户原话（摘） | 判定 | 证据路径 |
|-------|--------------|------|---------|
| R1 | 「在遇到上下文过长，或者说出现就是出现混乱的时候，我希望可以进行主动地进行压缩，或者说是整理优化」 | covered | critical-rules.md Rule 67.1-67.3（worktree/主仓）；冒烟 run1/run2.out |
| R2 | 「如果实在是解决不了，也可以撰写交接文档，要求在新的会话中开启」 | covered | skills/task-planner/templates/session-handoff.md 五段；67.4 恢复链 |
| R3 | 「核心就是主动评估、主动优化」 | covered | 67.1 三档触发+67.2 [assess] 留痕；grep '主动评估'=5；posttooluse [context-pressure] 注入 |

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | 终态：COMPLETE（Rule 67 已 land+部署） |
| 2 | Where am I going? | 用户下一任务=task-v156-drift-shield（防漂移强化，已 init） |
| 3 | What's the goal? | 见 Goal 段 |
| 4 | What have I learned? | findings.md（A-G/级联面/三轮并集/五方尾补） |
| 5 | What have I done? | progress.md（Phase 0-6 全段） |
| 6 | Which tasks need processing? | 主仓 plans/INDEX.md + plans/task-v156-drift-shield/ |
