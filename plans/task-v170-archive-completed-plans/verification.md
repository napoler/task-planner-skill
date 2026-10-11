# Verification Contract & Phase Gates

## Goal (1 sentence)

task-planner 技能具备「计划完成后归档」机制（完成流程接线+archive-plan.sh+Rule 81+selftest）且存量约 110 个已完成计划全部归档进 plans/archive/。

---

## Verification Contract (≥5 items, objective standards)

- [ ] VC-1: archive-plan.sh 单任务归档实跑成功+幂等
  Evidence: progress.md Phase 5/8 段（git status rename 行、ALREADY_ARCHIVED 二次运行输出）
- [ ] VC-2: 安全守卫实证（active/session-owner/非 complete 三类拒绝 exit 1）
  Evidence: progress.md Phase 5 守卫实测段（fixture 路径+退出码）
- [ ] VC-3: 存量全归档（plans/ 根 Status=complete 数=0；archive 收容数=dry-run 候选数）
  Evidence: progress.md Phase 8 Batch Report + ls 计数双向对账
- [ ] VC-4: 流程与制度在位（SKILL.md 归档步骤行；Rule 81 正文；selftest 全 PASS）
  Evidence: grep 输出 + selftest-archive-plan.sh 输出
- [ ] VC-5: 全量 selftest 回归 FAIL=0
  Evidence: Phase 5 S9 输出汇总（基线对照：worktree 创建时先跑留存）
- [ ] VC-6: 引用面适配（INDEX 不含 archive；resolve-plan-dir/set-active-plan 实跑正确）
  Evidence: 命令输出
- [ ] VC-7: 合并回 master + ~/.zcode 与 ~/.claude 部署位 diff=0
  Evidence: merge commit + diff -r 输出

---

## Phase Gates

### Phase 1: 勘查定案
**Goal**: 完成流程/引用面/存量三类事实一手锁定
**Depends on**: none
**Done when**: S1 补验回收+三类清单对账
**Verification**:
- [ ] V-1.1: VC-3（三类计数表）
- [ ] V-1.2: VC-6（glob 行号证据）
Status: `in_progress` Last verified: 2026-10-11

### Phase 2: 设计定稿
**Goal**: 脚本契约/接入点/守卫集/Rule 81 条文定稿
**Depends on**: Phase 1
**Verification**:
- [ ] V-2.1: VC-1（契约定稿）
- [ ] V-2.2: VC-2（守卫集定稿）
Status: `pending`

### Phase 3: 实现 archive-plan.sh
**Done when**: S2 交付+bash -n+fixture 自测过
**Verification**:
- [ ] V-3.1: VC-1
- [ ] V-3.2: VC-2
Status: `pending`

### Phase 4: 流程/规则/引用面/守护接线
**Done when**: S3-S8 全部验收
**Verification**:
- [ ] V-4.1: VC-2
- [ ] V-4.2: VC-4
- [ ] V-4.3: VC-6
Status: `pending`

### Phase 5: 测试与实证
**Done when**: S9 回归 0 FAIL + S10 试点 + S11 dry-run 对账
**Verification**:
- [ ] V-5.1: VC-1
- [ ] V-5.2: VC-2
- [ ] V-5.3: VC-3
- [ ] V-5.4: VC-5
- [ ] V-5.5: VC-6
Status: `pending`

### Phase 6: Code Review Gate
**Done when**: code-reviewer APPROVED
**Verification**:
- [ ] V-6.1: VC-1/VC-4/VC-5 的 CR 再确认
Status: `pending`

### Phase 7: 合并回 master + 部署对账
**Done when**: smart-merge-back 成功+worktree 清理+部署 diff=0
**Verification**:
- [ ] V-7.1: VC-5
- [ ] V-7.2: VC-7
Status: `pending`

### Phase 8: 存量批量归档 + 终验交付
**Done when**: S13 实做+Batch Report+VC 复验+交付总结+check-complete 终跑 exit 0
**Verification**:
- [ ] V-8.1: VC-1
- [ ] V-8.2: VC-2
- [ ] V-8.3: VC-3
- [ ] V-8.4: VC-6
Status: `pending`

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论 |
|-----------|----------------------|------|
| SKILL.md:165-184 终验段 | 归档步骤插入位与契约一致 | 终验填 |
| plans/.rule-reservations.jsonl | new_rule=81 已 land | 终验填 |
| references/worktree-isolation.md | worktree 生命周期合规 | 终验填 |

## 委派统计复验（Rule 25.4）
```bash
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans
```
JSON 输出：`{终验粘贴}`

- [ ] 主进程直做 Phase 均登记白名单内例外理由
- [ ] 委派率 ≥ floor 或 WHITELIST-EXEMPT

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查；Evidence 抽查 ≥3 条
- [ ] 豁免登记：无
- [ ] 未处置违规：无

## Goal Gate (终验)
```
## Goal Verification — 完成后归档机制+存量全归档
对照 VC 逐条复验：
- [x] VC-1 archive-plan.sh 单任务归档+幂等 → PASS（031：ARCHIVED task-v055 exit 0+rename ce89682；ALREADY_ARCHIVED exit 0）
- [x] VC-2 守卫三类拒绝 → PASS（031：REJECT v170 status-incomplete exit 1；032 dry-run skip 分类实例；011 断言守卫五类）
- [x] VC-3 存量全归档 → PASS（040：ok=101 fail=0；根目录余 14=在途集合；archive/=123=旧 22+本任务 102）
- [x] VC-4 流程与制度在位 → PASS（SKILL.md:185 归档步骤；critical-rules.md:1049 Rule 81 六子条；selftest-archive-plan 16/16；registry.tsv:79）
- [x] VC-5 无回归 → PASS（030 78/78 FAIL=0；036 复评员独立复跑 78/78；合并态 79/79；smoke 17/0）
- [x] VC-6 引用面适配 → PASS（008 sync-todos:158/resolve-plan-dir:129；009 set-active-plan:239-243；040 INDEX 重生 archive 命中=0 在途在位）
- [x] VC-7 合并回+部署 IDENTICAL → PASS（merge 41e62f6 双亲实证；smart-merge-back --deploy IDENTICAL；worktree/branch 已清）
 outcome: COMPLETE
```

> 验证独立性：终验核查由独立子代理执行，主进程仅编排与簿记。

## 5-Question Reboot Check
| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 1 |
| 2 | Where am I going? | Phase 2-8 |
| 3 | What's the goal? | 见上 Goal |
| 4 | What have I learned? | findings.md |
| 5 | What have I done? | progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
