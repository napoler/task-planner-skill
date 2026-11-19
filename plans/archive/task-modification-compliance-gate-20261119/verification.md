# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

在 task-planner 技能体系中落地通用修改合规门（Rule 74.7 及联动条款），使任何对已确立规范/规则/阈值/区间的修改在落地前必须完成合规四元组论证与授权，杜绝无依据放宽与投毒式篡改。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> 每条 VC 的 **Verify command** 行=attest vc-gate 判据面；命令须可执行、非恒真、引用本 VC 产出物、退出码判定。

- [x] VC-1: Rule 74.7 通用修改合规门在位（合规四元组 + 无依据放宽 P0 禁止 + 三类缺口覆盖）
  Evidence: skills/task-discipline/references/critical-rules-discipline.md:494
  **Verify command**: `grep -q '^74.7 .*合规四元组' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && grep -q '无依据放宽=禁止落地（P0）' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && echo VC1_OK`
- [x] VC-2: 4 处联动条款在位（51.15 跨域指针+none-justified / SKILL 2.5d 回填 / dispatch 22.4e 回传 / 106.7 通用放宽判据）
  Evidence: critical-rules.md:109 / SKILL.md:122 / dispatch.md:66 / discipline.md:757
  **Verify command**: `grep -q 'none-justified' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md && grep -q '通用修改合规门（Rule 74.7' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md && grep -q 'Rule 74.7 派发面联动' /mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md && grep -q '通用放宽判据（Rule 74.7' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && echo VC2_OK`
- [x] VC-3: 5 处纯增量零回归；selftest 4 脚本全 PASS
  Evidence: 主仓 commit 79debfa；4 脚本实跑 80 PASS/0 FAIL/1 中性 SKIP
  **Verify command**: `for s in selftest-absorption-discipline selftest-requirement-coverage selftest-dual-qc selftest-final-gate-hash; do bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/$s.sh >/dev/null 2>&1 || exit 1; done && echo VC3_OK`
- [x] VC-4: 覆盖 B1-B4 缺口、无漂移/撞号/删改/新脚本；drift-checker ALIGNED
  Evidence: subagent-state/drift-check-modcomp-20261119.md:9-11（ALIGNED P0=无 P1=无）
  **Verify command**: `grep -q 'status: ALIGNED' /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/subagent-state/drift-check-modcomp-20261119.md && grep -q 'P0: 无' /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/subagent-state/drift-check-modcomp-20261119.md && test "$(grep -c '^74.7 ' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md)" -eq 1 && echo VC4_OK`
- [x] VC-5: 2 部署位条款生效（zcode 5 锚 + agents 6 锚），负控制非恒真
  Evidence: 两部署位 grep 锚计数；负控制错锚=0
  **Verify command**: `test "$(grep -c '^74.7 ' /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md)" -eq 1 && test "$(grep -c '^74.7 ' /home/terry/.agents/skills/task-discipline/references/critical-rules-discipline.md)" -eq 1 && test "$(grep -c 'Rule 74.7 通用修改合规门' /home/terry/.agents/skills/task-planner/references/critical-rules.md)" -eq 1 && echo VC5_OK`

---

## Phase Gates

### Phase 1: 取证与决策

**Goal**: 产出 B1-B5 缺口/C1 根因/C2 最小修复面，判定 D 类新任务。
**Depends on**: none
**Done when**:
- [x] forensics 报告 + findings F1-F7 落盘
**Verification**:
- [x] V-1.1: → VC-1（取证底稿在位）
  **Verify command**: `test -s /mnt/data/dev/task-planner-skill/forensics/modification-compliance-gap-20261119.md && echo V11_OK`
- [x] V-1.2: → VC-4（取证底稿含 C2 修复面锚）
  **Verify command**: `grep -q 'C2. 最小修复面' /mnt/data/dev/task-planner-skill/forensics/modification-compliance-gap-20261119.md && echo V12_OK`
Status: `complete` Last verified: 2026-11-19

### Phase 2: 规划与隔离

**Goal**: 反思门 D 类决策 + worktree 隔离就绪。
**Depends on**: Phase 1
**Done when**:
- [x] 决策 D1-D6 + stash + worktree ①-校验通过
**Verification**:
- [x] V-2.1: → VC-4（决策落盘）
  **Verify command**: `grep -q 'D 类新任务' /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/findings.md && echo V21_OK`
- [x] V-2.2: → VC-3（merge_back 已登记）
  **Verify command**: `grep -q 'merged(79debfa)' /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/task_plan.md && echo V22_OK`
Status: `complete` Last verified: 2026-11-19

### Phase 3: 实现

**Goal**: 4 文件 5 处纯增量条款落地并合并回 master。
**Depends on**: Phase 2
**Done when**:
- [x] 7 锚=1 + commit 274bb9e → merge 79debfa
**Verification**:
- [x] V-3.1: → VC-1（主仓条款锚）
  **Verify command**: `test "$(grep -c '^74.7 ' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md)" -eq 1 && echo V31_OK`
- [x] V-3.2: → VC-2（4 联动锚）
  **Verify command**: `grep -q 'none-justified' /mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md && grep -q '通用放宽判据（Rule 74.7' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md && echo V32_OK`
Status: `complete` Last verified: 2026-11-19

### Phase 4: 验证与部署

**Goal**: 零回归 + 独立 drift ALIGNED + 2 部署位生效。
**Depends on**: Phase 3
**Done when**:
- [x] selftest 4 脚本 PASS + drift ALIGNED + 部署锚=1
**Verification**:
- [x] V-4.1: → VC-3（selftest）
  **Verify command**: `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-final-gate-hash.sh >/dev/null 2>&1 && echo V41_OK`
- [x] V-4.2: → VC-5（部署位锚）
  **Verify command**: `test "$(grep -c '^74.7 ' /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md)" -eq 1 && echo V42_OK`
Status: `complete` Last verified: 2026-11-19

### Phase 5: 交付与收尾

**Goal**: 五维互洽回读 + check-complete exit=0 + 归档。
**Depends on**: Phase 4
**Done when**:
- [x] 收尾回读收敛 + VC 全通过
**Verification**:
- [x] V-5.1: → VC-4（drift 检查点）
  **Verify command**: `grep -q 'status: ALIGNED' /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119/subagent-state/drift-check-modcomp-20261119.md && echo V51_OK`
- [x] V-5.2: → VC-5（部署位 agents SKILL 锚）
  **Verify command**: `grep -q '通用修改合规门（Rule 74.7' /home/terry/.agents/skills/task-planner/SKILL.md && echo V52_OK`
Status: `complete` Last verified: 2026-11-19

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| 宪法 §二/§六/§十一/§十三 | D1-D6 决策 + worktree 隔离 + 纯文本 | 符合 |
| forensics 底稿 B1-B5/C1-C3 | findings F1-F7 + 5 处条款覆盖 | 符合 |
| critical-rules*.md 5 锚原文 | Edit 前 Read + 纯增量 diff | 符合 |

## 委派统计复验（Rule 25.4）

```bash
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-modification-compliance-gate-20261119
```

- [x] 主进程直做 Phase 均在白名单内（Phase 2/3/5 = Rule 25.3 白名单②/①）
- [x] 委派率 0.400（低于 floor 但全为白名单②/①豁免，同构判例 task-spec-baseline-freeze 0.200 已放行）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 2 项（Q4 保护区/ Q6 部署），豁免 0，未处置 0
- [x] Evidence 抽查 ≥3 条:74.7 锚/部署位锚/drift 检查点三处可 Read 可复现
- [x] 豁免登记:无
- [x] 无未处置违规

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 落地通用修改合规门（Rule 74.7 及联动条款），杜绝无依据放宽与投毒式篡改
对照 Verification Contract 逐条复验：
- VC-1: discipline:494 74.7 合规四元组+P0 → PASS
- VC-2: 4 联动锚全=1 → PASS
- VC-3: selftest 4 脚本 80 PASS/0 FAIL → PASS
- VC-4: drift ALIGNED(P0=无) + 74.7 唯一 + 纯增量 → PASS
- VC-5: zcode5/agents6 锚=1 + 负控制=0 → PASS

outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

> 验证独立性：独立 drift-checker 三态判定已派（Rule 61/103 第二道），主进程仅编排与簿记。

---

## 交叉验证记录（Rule 108）

| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定 |
|----------|------------------------|--------------------------|------|
| 74.7+联动条款目标对齐 | grep 7 锚全=1 + selftest 80P | drift-checker ALIGNED(P0=无) | 一致 PASS |

## 5-Question Reboot Check

| # | Question | Answer |
|---|----------|--------|
| 1 | Where am I? | Phase 5 complete |
| 2 | Where am I going? | 交付完成 |
| 3 | What's the goal? | 通用修改合规门（Rule 74.7） |
| 4 | What have I learned? | findings.md F1-F7 |
| 5 | What have I done? | progress.md 5 Phase |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（历史遗留，未经确认不动） |
