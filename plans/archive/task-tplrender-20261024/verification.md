# Verification Contract & Phase Gates

## Goal (1 sentence)

init-session.sh 内建变量渲染层（{{VAR}} 传参+兼容形态映射+残留 fail-closed），init 产物机械占位符全部由脚本直接替换为真实值，模型只填语义内容。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.

- [ ] VC-1: init 实弹产物机械占位符零残留（八形态合计计数=0；⚠️ CWD 守卫要求父目录名为 plans——S4 实测判例）
**Verify command**: `T=/tmp/tplrender-v1-$$; mkdir -p $T/plans/task-v1test && cd $T/plans/task-v1test && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh "VC测试任务" >/dev/null 2>&1 && test "$(grep -rE '\{\{[A-Z_]+\}\}|\[Brief Description\]|\{task-id\}|<task-id>|\{task-name\}|\[DATE\]|\[YYYY-MM-DD|\$\{TASK_PLANNER_ROOT:-' . | grep -v '<!--' | wc -l)" -eq 0`
  Evidence: 命令输出 0（progress.md Phase 2 留痕）
- [ ] VC-2: 渲染值正确（task-id/当日日期/任务名/根路径四类真实值命中）
  **Verify command**: `T=/tmp/tplrender-v2-$$; mkdir -p $T/plans/task-v2test && cd $T/plans/task-v2test && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh "VC2值测试" >/dev/null 2>&1 && n1=$(grep -rl task-v2test --include='*.md' . | wc -l) && n2=$(grep -rl "VC2值测试" . | wc -l) && n3=$(grep -rl "$(date +%Y-%m-%d)" --include='*.md' | wc -l) && n4=$(grep -rl "skills/task-planner" --include='*.md' | wc -l) && test "$n1" -ge 1 && test "$n2" -ge 1 && test "$n3" -ge 1 && test "$n4" -ge 1`
  Evidence: 四条 grep 输出（progress.md Phase 2 留痕）
- [ ] VC-3: 语义占位零误替换（`<用户原话`、`<按需增行>` 等仍在位）
  **Verify command**: `T=/tmp/tplrender-v3-$$; mkdir -p $T/plans/task-v3test && cd $T/plans/task-v3test && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh "VC3语义测试" >/dev/null 2>&1 && A=$(grep -rc '<用户原话' --include='*.md' . | awk -F: '{s+=$2} END{print s}') && B=$(grep -rc '<按需增行>' --include='*.md' . | awk -F: '{s+=$2} END{print s}') && test "$A" -ge 1 && test "$B" -ge 1`
  Evidence: 计数输出（progress.md Phase 2 留痕）
- [ ] VC-4: 残留校验 fail-closed（未定义 token → exit≠0 且报错含 token 名）
  **Verify command**: `T=/tmp/tplrender-v4-$$; rm -rf $T; mkdir -p $T/plans/task-v4test $T/.zcode/plan-templates && printf '# VC4 注入测试模板 {{UNDEFINED_VAR_XYZ}}\n' > $T/.zcode/plan-templates/verification.md && cd $T/plans/task-v4test && bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh "VC4注入测试" 2>&1 | grep -q "UNDEFINED_VAR_XYZ"`
  Evidence: exit code+报错行（progress.md Phase 2 留痕）
- [ ] VC-5: 零回归（worktree 全量 selftest ΣFAIL=0，对照 Phase 1 基线）
**Verify command**: `cd /mnt/data/dev/task-planner-skill && bash skills/task-planner/scripts/run-selftests.sh 2>&1 | tail -1 | grep -q "Total: 93 PASS=93 FAIL=0"`
  Evidence: selftest 尾部输出（progress.md Phase 5 留痕）
- [ ] VC-6: SKILL.md 指示面更新在位（初始化段渲染契约+禁手工修正指示）
  **Verify command**: `L=$(grep -m1 -n "渲染层" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md | cut -d: -f1) && test "$L" -lt 60`
  Evidence: grep 输出（progress.md Phase 4 留痕）
- [ ] VC-7: 部署位同步 diff=0（~/.zcode/skills/task-planner 改动文件逐一对齐）
  **Verify command**: `fail=0; for f in scripts/init-session.sh scripts/selftest-plan-tier.sh scripts/selftest-session-log.sh templates/task_plan.md templates/user-session-log.md templates/notepad-learnings.md templates/progress.md templates/findings.md templates/verification.md templates/knowledge-brief.md SKILL.md; do diff -q "$HOME/.zcode/skills/task-planner/$f" "/mnt/data/dev/task-planner-skill/skills/task-planner/$f" >/dev/null || fail=1; done; test "$fail" -eq 0`
  Evidence: diff 空输出（progress.md Phase 5 留痕）

---

## Phase Gates

### Phase 1: 契约定稿与隔离建起

**Goal**: 变量契约三清单落 findings + worktree/基线就绪

**Depends on**: none

**Done when**:
- [ ] findings.md 含 {{VAR}} 变量表+兼容映射表+语义保留清单（S1）
- [ ] worktree 在位且基线 ΣFAIL 快照记 progress.md（S2）

**Verification** (run before moving on):
- [x] V-1.1: findings.md 三清单齐全 → mapped to VC-3（边界判据）
- [x] V-1.2: `git worktree list` 含 task-tplrender-20261024 + 基线数字在 progress.md → mapped to VC-5（对照物）

Status: `in_progress` Last verified: 2026-10-24

---

### Phase 2: 渲染层实现

**Goal**: render_template() 落地且 tmp 实弹四 VC 现场通过

**Depends on**: Phase 1

**Done when**:
- [ ] S3+S4 渲染函数/兼容映射/校验/接线完成，bash -n 过
- [ ] S5 实弹 VC-1/2/4 证据落 progress.md

**Verification**:
- [x] V-2.1: VC-1 命令输出 0
- [x] V-2.2: VC-4 exit≠0 含 token 名

Status: `pending` Last verified: —

---

### Phase 3: 模板 token 化

**Goal**: 核心 7+项目级 8 文件机械占位→{{VAR}}，语义占位逐字保留

**Depends on**: Phase 1（契约）

**Done when**:
- [ ] S6-S10 五单元完成，worktree 内 8 文件旧机械形态计数=0（variant 不在射程）

**Verification**:
- [x] V-3.1: worktree templates/ 8 文件 `grep -lE '\{task-id\}|<task-id>|\[DATE\]'` 仅剩语义合法面 → mapped to VC-1
- [x] V-3.2: `grep -c '<用户原话' templates/task_plan.md` 数值与改前一致 → mapped to VC-3

Status: `pending` Last verified: —

---

### Phase 4: SKILL.md 指示面更新

**Goal**: 初始化段渲染契约文字在位

**Depends on**: Phase 1

**Done when**:
- [x] S11 完成，初始化段含渲染契约+禁手工修正指示

**Verification**:
- [x] V-4.1: VC-6 grep 命中（SKILL.md:41）
- [x] V-4.2: SKILL.md 行数变化 +3/-2 ≤15 行（scope 控制自检）

Status: `complete` Last verified: 2026-10-24

---

### Phase 5: 回归终验与合并部署

**Goal**: selftest 零回归+VC 全 PASS+合并部署+清理

**Depends on**: Phase 2/3/4 全 complete

**Done when**:
- [ ] S12+S13 回归绿；S14 独立终验全 PASS；S15 合并+部署+清理+主仓 Read 复验

**Verification**:
- [x] V-5.1: VC-5 ΣFAIL=0
- [ ] V-5.2: VC-7 部署位 diff=0
- [ ] V-5.3: `git worktree list` 无 task-tplrender 残留+`git branch` 无 wt/task-tplrender

Status: `pending` Last verified: —

## 📚 必要知识储备符合性核验（终验项）
<!-- WHEN: 终验时逐条核对「必读」知识源是否被实际遵循 -->
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
|           |                      |                     |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据（机器去口供化：占位检测 + Handoff 交叉校验，非信任 Executor 字段自报）。

```bash
# 证据（粘贴以下 JSON 原文）
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>
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
## Goal Verification — init 渲染层使机械占位符脚本直出，模型只填语义
对照 Verification Contract 逐条复验（终验时逐条补 PASS/FAIL 与证据锚）：
- VC-1 实弹产物机械占位八形态计数=0
- VC-2 四类真实值（task-id/日期/任务名/根路径）命中
- VC-3 语义占位保留计数≥2
- VC-4 未定义 token fail-closed exit≠0
- VC-5 selftest ΣFAIL=0 对照基线
- VC-6 SKILL.md 渲染契约 grep 命中
- VC-7 部署位逐文件 diff=0

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

**PARTIAL**：VC 通过但存在已知遗留缺陷 → 列出 + 建议后续。

**BLOCKED**：≥1 VC 失败且 3 次重试无效 → 升级用户决策。

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
