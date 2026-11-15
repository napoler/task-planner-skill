# Verification Contract & Phase Gates
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；{语义占位}/<plan-dir>=模型/调用方填写面 -->

## Goal (1 sentence)

为 task-planner 建成「执行路径→模板」主动沉淀机制（Rule 34.8/34.9+两级审查门）并新增 plan-template-advisor 子技能，以本仓 dogfood 产出首个过门项目模板。

---

## Verification Contract (≥5 items, objective standards)

> These are the FINAL checks. All must pass for goal to be COMPLETE.
> Each item: observable, testable, traceable to evidence.
> 命令基准目录=主仓根（终验时 worktree 已合并回）；含 worktree 前缀的命令在合并回前对 worktree 根执行。

- [ ] VC-1: 34.8（执行期沉淀触点+候选暂存+两级审查门 G1-G4）与 34.9（项目级沉淀位）条款在位；既有 34.1-34.7 行零改动
  Evidence: worktree+主仓 critical-rules-template.md grep 回执+git diff 对照
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -cE '^34\.8 \*\*' skills/plan-template-kit/references/critical-rules-template.md && grep -cE '^34\.9 \*\*' skills/plan-template-kit/references/critical-rules-template.md && git diff af18ad3..HEAD -- skills/plan-template-kit/references/critical-rules-template.md | grep -E '^-' | grep -vE '^---' | grep -cE '^-[[:space:]]*34\.[1-7] ' | sed 's/^/removed-341-347-lines=/' （判据=前两个 grep ≥1 且 removed 计数=0；基线=建 worktree 时 master HEAD af18ad3，2026-11-15 实测——他任务 bookkeeping 已使 master 前进，旧锚 0ceda55 作废）
- [ ] VC-2: skills/plan-template-advisor/SKILL.md 在位：frontmatter name/description + SOP 六步锚
  Evidence: 文件+grep 回执
  **Verify command**: cd /mnt/data/dev/task-planner-skill && test -f skills/plan-template-advisor/SKILL.md && grep -c '^name: plan-template-advisor' skills/plan-template-advisor/SKILL.md && grep -cE '项目分析|问题预测|缺口映射|模板产出|审查|登记' skills/plan-template-advisor/SKILL.md （判据=test 0 退出+name=1+六步锚 ≥6）
- [ ] VC-3: 级联面全绿：路由表行/路由索引/install 清单/kit 指针齐，「11 卫星」旧串清零、新串 12 在位
  Evidence: 5 级联文件 grep 回执
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -c 'plan-template-advisor' skills/task-planner/SKILL.md && grep -c 'plan-template-advisor' skills/task-planner/references/critical-rules.md && grep -c 'plan-template-advisor' skills/task-planner/lib/install-stub.sh && grep -c 'plan-template-advisor' skills/plan-template-kit/SKILL.md && grep -c '12 卫星' skills/task-planner/SKILL.md && grep -c '11 卫星' skills/task-planner/SKILL.md; true （判据=前 5 个 grep ≥1 且「11 卫星」=0）
- [ ] VC-4: dogfood 项目模板候选过审查门：.zcode/plan-templates/ 新增 1 个 *-type.md 且 G1/G2/G3 逐项 PASS 留痕
  Evidence: 产物文件+verification.md 门记录段
  **Verify command**: cd /mnt/data/dev/task-planner-skill && ls .zcode/plan-templates/*-type.md 2>/dev/null | grep -c . && grep -cE 'G1.*(PASS|✅)|G2.*(PASS|✅)|G3.*(PASS|✅)' plans/task-tpl-sediment-20261115/verification.md （判据=模板文件 ≥1+门记录三项 ≥3）
- [ ] VC-5: render 冒烟 PASS：候选经 render_template 渲染无 {{残留}}；init tmp 隔离实跑选中该类型
  Evidence: tmp/ 冒烟日志+渲染产物（路径记 progress）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && SMOKE_LOG=$(ls -t tmp/smoke-tpl-sediment-*.log | head -1) && grep -c 'FAIL\|残留未定义' "$SMOKE_LOG" | sed 's/^/smoke-fail=/' && grep -c 'template-sediment-smoke\|project-level' "$SMOKE_LOG" （判据=smoke-fail=0 且选中证据 ≥1；冒烟 spec=clause-drafts.md §3）
- [ ] VC-6: 全量回归零增量：部署后 run-selftests.sh --fresh FAIL 集合 ⊆ 基线
  Evidence: tmp/regression-tpl-sediment-baseline.txt 与 tmp/regression-tpl-sediment-final.txt
  **Verify command**: cd /mnt/data/dev/task-planner-skill && comm -13 <(sort tmp/regression-tpl-sediment-baseline.txt) <(sort tmp/regression-tpl-sediment-final.txt) | wc -l （判据=0）
- [ ] VC-7: 部署对账 diff=0：task-planner 目录 --deploy 3 槽位+advisor 宿主位+cursor 位
  Evidence: 部署回执记 progress
  **Verify command**: cd /mnt/data/dev/task-planner-skill && diff -q skills/plan-template-advisor/SKILL.md "$HOME/.zcode/skills/plan-template-advisor/SKILL.md" && diff -q skills/task-planner/SKILL.md "$HOME/.zcode/skills/task-planner/SKILL.md" && diff -q skills/plan-template-kit/references/critical-rules-template.md "$HOME/.zcode/skills/plan-template-kit/references/critical-rules-template.md" （判据=全部 diff 静默=0 退出；其余槽位对账清单随部署回执）

**终验规则**：全部 VC 通过 → COMPLETE；通过但有已知遗留 → PARTIAL；≥1 VC 失败重试 3 次无效 → BLOCKED。

---

## Phase Gates

### Phase 1: 设计定稿与起草

**Goal**: clause-drafts（34.8/34.9 v1+两级门清单）+advisor 草案落盘并定稿

**Depends on**: none

**Done when**:
- [ ] clause-drafts.md+advisor-draft.md 在位且主进程定稿复核完成

**Verification** (run before moving on):
- [ ] V-1.1: clause-drafts 含 34.8/34.9 v1+门清单+级联 spec（映射 VC-1）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && test -f plans/task-tpl-sediment-20261115/clause-drafts.md && grep -cE '^#+ .*34\.8|^34\.8 \*\*' plans/task-tpl-sediment-20261115/clause-drafts.md && grep -cE 'G1|G2|G3|G4' plans/task-tpl-sediment-20261115/clause-drafts.md （判据=test+标题 ≥1+门锚 ≥4）
- [ ] V-1.2: advisor 草案六步锚+frontmatter 合规（映射 VC-2）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && test -f plans/task-tpl-sediment-20261115/advisor-draft.md && grep -c '^name:' plans/task-tpl-sediment-20261115/advisor-draft.md && grep -cE '分析|预测|缺口|产出|审查|登记' plans/task-tpl-sediment-20261115/advisor-draft.md （判据=test+name ≥1+步骤锚 ≥6）

Status: `in_progress` Last verified: —

---

### Phase 2: worktree 实现插改

**Goal**: 条款+SKILL+级联五落点+dogfood 候选在 worktree 落位

**Depends on**: Phase 1

**Done when**:
- [ ] 六 S-unit 产物齐+主进程验收 Read

**Verification**:
- [ ] V-2.1: worktree 条款两标题串在位+既有行零改动（映射 VC-1）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115 && grep -cE '^34\.8 \*\*|^34\.9 \*\*' skills/plan-template-kit/references/critical-rules-template.md （判据=2）
- [ ] V-2.2: worktree 级联点 grep 齐+旧计数串清零（映射 VC-3）
  **Verify command**: cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-tpl-sediment-20261115 && grep -c 'plan-template-advisor' skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/task-planner/lib/install-stub.sh skills/plan-template-kit/SKILL.md README.md docs/ARCHITECTURE.md && grep -c '11 卫星' skills/task-planner/SKILL.md; true （判据=各文件 ≥1+旧串=0）
- [ ] V-2.3: dogfood 候选在位（映射 VC-4）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && ls plans/task-tpl-sediment-20261115/template-candidate/*-type.md | grep -c . （判据=1）

Status: `pending` Last verified: —

---

### Phase 3: 审查门+回归（worktree 内）

**Goal**: critic APPROVED+render 冒烟+selftest 基线对照全过

**Depends on**: Phase 2

**Done when**:
- [ ] 复检 verdict=APPROVED+冒烟 PASS+FAIL ⊆ 基线

**Verification**:
- [ ] V-3.1: critic 检查点 verdict=APPROVED（映射 VC-4 质量面）
  **Verify command**: grep -c 'verdict.*APPROVED\|APPROVED' plans/task-tpl-sediment-20261115/subagent-state/review-critic.md （判据=≥1）
- [ ] V-3.2: 冒烟日志零 FAIL/零残留（映射 VC-5）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && grep -cE 'FAIL|残留未定义' "$(ls -t tmp/smoke-tpl-sediment-*.log | head -1)"; true （判据=0）
- [ ] V-3.3: worktree selftest FAIL ⊆ 主仓基线（映射 VC-6）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && comm -13 <(sort tmp/regression-tpl-sediment-baseline.txt) <(sort tmp/regression-tpl-sediment-final.txt) | wc -l （判据=0）

Status: `pending` Last verified: —

---

### Phase 4: 合并回+部署同步+终验交付

**Goal**: 合并对账 diff=0+部署后回归+push+归档+kb 入库

**Depends on**: Phase 3

**Done when**:
- [ ] 全 VC 复验 PASS+归档回执+收尾回读收敛

**Verification**:
- [ ] V-4.1: 部署位逐对 diff=0（映射 VC-7）
  **Verify command**: 见 VC-7 Verify command
- [ ] V-4.2: 部署后 --fresh 回归 comm 判据=0（映射 VC-6）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && comm -13 <(sort tmp/regression-tpl-sediment-baseline.txt) <(sort tmp/regression-tpl-sediment-final.txt) | wc -l （判据=0）
- [ ] V-4.3: 归档回执（映射收尾完整性）
  **Verify command**: test -d plans/archive/task-tpl-sediment-20261115 && echo ARCHIVED （判据=ARCHIVED）

Status: `pending` Last verified: —

---

## 项目模板审查门记录（Rule 34.8 两级门执行留痕 — VC-4 判据面）

- G1 结构 lint: **PASS** — 候选 39 行 ≤100+机读头 `<!-- template_type: rule-clause-cascade -->`+五结构块齐（P2-S6 自检+critic R1-R3 轮 E 项复核）
- G2 render 冒烟: **PASS** — 首跑 FAIL（类型标识双后缀→generic 回退，CA-15 修复）→复跑 PASS（检查点 smoke-g2-r2.md：project-level 选中+非注释行零 {{}}+五块在位+主指针无污染；日志 tmp/smoke-tpl-sediment-r2-*.log）
- G3 独立审查: **PASS** — critic R1/R2/R3 轮覆盖候选（E 项 PASS+路径修正 C-5 落实，review-critic-r3.md APPROVED）
- G4 官方级联: N/A（项目级沉淀免官方级联；候选未写入官方 templates/variant/）
- 落位: `.zcode/plan-templates/rule-clause-cascade-type.md`+manifest `README.md`（2026-11-15，CA-8）

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| Rule 34 全文（:11-22） | 34.8/34.9 文风/机制句/判例锚形态对照 | 终验填 |
| check-template-type.sh:1-43 | 34.9 项目级命名 *-type.md 约束与白名单机制一致性 | 终验填 |
| init-session.sh:65-97,570-730 | 34.9 沉淀位与原生发现机制表述一致 | 终验填 |
| TL-17 计数锚（:186-204） | 未动官方 variant/计数串「30 个」保持 | 终验填 |
| plan-template-kit/SKILL.md 先例 | advisor SKILL 形态/行数对齐 | 终验填 |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
# 证据（粘贴以下 JSON 原文）
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats plans/task-tpl-sediment-20261115
```

JSON 输出：
```json
{终验时粘贴}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率 < 0.7 或含白名单外理由或 stats verdict=violation → check-complete exit 1 回炉

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项
- [ ] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 __
- [ ] 豁免登记:项号/范围/理由/日期 __ (仅用户显式文字豁免;Q3 不适用)
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级;Q3 → BLOCKED + STOP

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 建成路径沉淀机制+advisor 子技能+dogfood 过门
对照 Verification Contract 逐条复验：
- [ ] VC-1..VC-7: {evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

> **验证独立性**：终验核查动作由全新独立子代理执行，主进程仅编排与簿记（Rule 33.3）。

---

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1（attest 后 draft 组派发） |
| 2 | Where am I going? | Phase 2 插改→Phase 3 审查回归→Phase 4 部署收尾 |
| 3 | What's the goal? | Goal 语句见上 |
| 4 | What have I learned? | findings F1-F10 |
| 5 | What have I done? | progress.md Phase 1 段 |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区（本任务外） |
