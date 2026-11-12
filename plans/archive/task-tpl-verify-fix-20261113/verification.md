# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

先修模板体系（task_plan/verification 模板补验证区块+10 列口径+plan-template-kit 契约），再按修正后口径清零全部同源漂移面，冒烟证明新模板一次过门并三部署位生效。

---

## Verification Contract (≥5 items, objective standards)

- [ ] VC-1: 取证落盘——五处模板-门漂移清单+模板源定位在 findings.md
  Evidence: plans/task-tpl-verify-fix-20261113/findings.md §1-§4
  **Verify command**: test $(grep -cE '96 类别|Verify command|对应 S-unit' /mnt/data/dev/task-planner-skill/plans/task-tpl-verify-fix-20261113/findings.md) -ge 4
- [x] VC-2: 模板修正——task_plan 模板无「96 类别」列名、含「对应 S-unit/Phase」、Phase4 示例带表；verification 模板含 **Verify command** 行格式
  Evidence: skills/task-planner/templates/{task_plan,verification}.md（S1/S2 checkpoint 01/02）→ PASS(2026-11-13 主仓终验：96 类别=0/列名在位/Verify command=10)
  **Verify command**: ! grep -q '96 类别' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && grep -q '对应 S-unit/Phase' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md && test $(grep -c 'Verify command' /mnt/data/dev/task-planner-skill/skills/task-planner/templates/verification.md) -ge 1
- [ ] VC-3: 模板 skill 同步——plan-template-kit 含验证区块契约+10 列序条款
  Evidence: skills/plan-template-kit/（SKILL/references 实测锚位）
  **Verify command**: test $(grep -rn 'Verify command' /mnt/data/dev/task-planner-skill/skills/plan-template-kit/ | wc -l) -ge 2
- [x] VC-4: 他处纠正——96 类别作为列名/列指引的残留=0（负面/迁移表述除外，口径=findings §4）；SKILL 注释块口径=（An）前缀（已无锚关闭——SKILL.md 实测零命中）
  Evidence: 全仓 skills/ grep 清单（S5 checkpoint 05）；唯一剩余=selftest:98 `cnt '96 类别'` 负断言计数实现（守卫用法，语义=模板须为 0）→ 判据白名单补 cnt 形态；dispatch 三锚+SA-19 翻转实证（checkpoint 05/07）→ PASS(2026-11-13 主仓终验)
  **Verify command**: test $(grep -rn '96 类别' /mnt/data/dev/task-planner-skill/skills/ | grep -vE '（An）前缀|口径迁移|已废止|禁「96 类别」|cnt ' | wc -l) -eq 0
- [x] VC-5: 冒烟+回归——smoke 计划过 check-plan-dispatch 零拒锁项；selftest=基线（2 预存 FAIL）
  Evidence: S6 checkpoint 06（渲染零泄漏/门 EXIT:0 三 Phase 全有表/清理干净）+SG 修复 checkpoint 07（SG 23/23；全量 97/95/2=基线）→ PASS(2026-11-13；第六漂移冒烟抓到→CA-11 闭环)
  **Verify command**: bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -1
- [x] VC-6: 部署生效——scope 变更文件 × 三位 diff=0；三仓 push
  Evidence: 7 文件×3 位 ALL-SYNCED（2026-11-13 主进程逐对 diff）；三仓 push（源 4d269d1..5a0e410 / zcode 9c4c35c..a2bf941 / claude 228d17b..056e5e0）
  **Verify command**: diff /mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md /home/terry/.zcode/skills/task-planner/templates/task_plan.md && echo SYNCED

---

## Phase Gates

### Phase 1: 漂移取证与证据落盘
**Verification**:
- [ ] V-1.1: VC-1 命令 PASS（2026-11-13 实跑 PASS，回填勾选于终验）
  **Verify command**: test $(grep -cE '96 类别|Verify command|对应 S-unit' /mnt/data/dev/task-planner-skill/plans/task-tpl-verify-fix-20261113/findings.md) -ge 4
Status: `complete` Last verified: 2026-11-13

### Phase 2: 修正模板 skill 与模板文件（worktree 路径 $WT）
- [x] V-2.1: VC-2 worktree 版（S1/S2 自检+主仓终验双证）
  **Verify command**: ! grep -q '96 类别' /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/task-planner/templates/task_plan.md && test $(grep -c 'Verify command' /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/task-planner/templates/verification.md) -ge 1
- [x] V-2.2: VC-3 worktree 版（S3 checkpoint 03）
  **Verify command**: test $(grep -rn 'Verify command' /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/plan-template-kit/ | wc -l) -ge 2
Status: `complete` Last verified: 2026-11-13

### Phase 3: 按修正后模板纠正他处
- [x] V-3.1: VC-4 worktree 版残留=0（S5 checkpoint 05：dispatch 三锚+SA-19 翻转；CA-7 无锚关闭）
  **Verify command**: test $(grep -rn '96 类别' /mnt/data/dev/task-planner-skill-worktrees/task-tpl-verify-fix-20261113/skills/ | grep -vE '（An）前缀|口径迁移|已废止|禁「96 类别」|cnt ' | wc -l) -eq 0
Status: `complete` Last verified: 2026-11-13

### Phase 4: 冒烟与独立复检
- [x] V-4.1: 冒烟 EXIT:0 零拒锁+基线回归（S6 checkpoint 06+SG 修复 checkpoint 07：97/95/2=基线；第六漂移 CA-11 闭环）+S7 APPROVED（checkpoint 08）
  **Verify command**: grep -q 'EXIT:0\|PASS' /mnt/data/dev/task-planner-skill/plans/task-tpl-verify-fix-20261113/subagent-state/06-code-runner-smoke.md
Status: `complete` Last verified: 2026-11-13

### Phase 5: 合并、部署与交付
- [x] V-5.1: 主仓 VC-2/3/4 全 PASS+三仓 push（5a0e410/a2bf941/056e5e0）
  **Verify command**: git -C /mnt/data/dev/task-planner-skill log --oneline -1
Status: `complete` Last verified: 2026-11-13

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| 上任务判例档 | findings §1 与归档档一致 | 终验填 |
| 门判据源码 | findings §2 锚行号复核 | 终验填 |
| 现行模板全文 | S1/S2 首动作 Read 留痕 | 终验填 |

## 委派统计复验（Rule 25.4）
```bash
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-tpl-verify-fix-20261113
```
JSON 输出：```json
{终验粘贴}
```

## 质量门控统计（Rule 26）
- [ ] Q1-Q6：触发 __ / 豁免 __ / 未处置 __
- [ ] Evidence 抽查 ≥3 条：__
- [ ] 豁免登记：__
- [ ] 未处置违规处置：__

## Goal Gate (终验)
```
- [ ] VC-1..VC-6 → PASS/FAIL
 outcome: COMPLETE / PARTIAL / BLOCKED
```

> **验证独立性**：终验核查由全新独立子代理执行（Rule 33.3 延伸）

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 1 complete/Phase 2 待 yes |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
