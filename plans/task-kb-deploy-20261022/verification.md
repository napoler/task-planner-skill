# Verification Contract & Phase Gates

## Goal (1 sentence)

知识库机制（任务模板收尾「归档→知识提取入库」两步）同步到三个部署位，且本仓全部修改提交推送到 origin/master。

---

## Verification Contract (≥5 items, objective standards)

- [ ] VC-1: 三部署位与 repo skills/task-planner 逐字一致（差异仅部署位独有运行态）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && for d in ~/.zcode ~/.claude ~/.cursor; do echo "== $d"; diff -rq skills/task-planner "$d/skills/task-planner"; done
  Evidence: （执行后填——每位的差异行仅运行态如 .drift-rhythm）
- [ ] VC-2: 三位部署位模板含「归档计划」「知识提取入库」收尾两步
  **Verify command**: for d in ~/.zcode ~/.claude ~/.cursor; do grep -c "归档计划\|知识提取入库" "$d/skills/task-planner/templates/task_plan.md"; done
  Evidence: （执行后填——每位计数 ≥2）
- [ ] VC-3: 删除项目级 task_plan 覆盖后本仓新计划仍含两步 + knowledge-brief 仍带 §7
  **Verify command**: cd /mnt/data/dev/task-planner-skill && rm -rf /tmp/kb-deploy-smoke && mkdir -p /tmp/kb-deploy-smoke && cd /tmp/kb-deploy-smoke && bash /home/terry/.zcode/skills/task-planner/scripts/init-session.sh >/dev/null 2>&1; grep -c "归档计划\|知识提取入库" */task_plan.md; grep -c "§7 项目知识库回链" */knowledge-brief.md
  Evidence: （执行后填——两步命中 ≥2 且 §7 命中 ≥1）
- [ ] VC-4: 提交后工作树干净（除有意忽略的运行态）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git status --short
  Evidence: （执行后填——仅剩预期项/为空）
- [ ] VC-5: origin/master 与本地 master 一致（推送成功）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git rev-parse master origin/master && git log --oneline -3 origin/master
  Evidence: （执行后填——两 hash 相等）
- [ ] VC-6: 知识库机制端到端可用（检索命中 + 索引幂等）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-search.sh 派发 | head -20 && bash scripts/kb-rebuild-index.sh && git diff --stat knowledge/INDEX.md
  Evidence: （执行后填——检索有命中且索引重建无 diff）

---

## Phase Gates

### Phase 1: 部署同步（三位）

**Goal**: repo skills/task-planner 同步到三个部署位且 diff 归零

**Depends on**: none

**Done when**:
- [ ] 三位 diff -rq 差异行仅运行态
- [ ] 三位模板 grep 两步 ≥2

**Verification** (run before moving on):
- [ ] V-1.1: mapped to VC-1
- [ ] V-1.2: mapped to VC-2

Status: `in_progress` Last verified: —

---

### Phase 2: 单源清理 + 冒烟 + 回归

**Goal**: 删项目级 task_plan 覆盖后本仓回落部署位仍生效，且全量 selftest 零回归

**Depends on**: Phase 1

**Done when**:
- [ ] .zcode/plan-templates/task_plan.md 已删且 init 冒烟含两步 + §7
- [ ] 全量 selftest FAIL=0

**Verification**:
- [ ] V-2.1: mapped to VC-3
- [ ] V-2.2: mapped to VC-6

Status: `pending` Last verified: —

---

### Phase 3: 提交推送 + 独立复核

**Goal**: 全部修改提交并推送 origin/master，工作树干净

**Depends on**: Phase 2

**Done when**:
- [ ] git status 预期项
- [ ] master == origin/master

**Verification**:
- [ ] V-3.1: mapped to VC-4
- [ ] V-3.2: mapped to VC-5

Status: `pending` Last verified: —

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| planflow-plan-lifecycle-gates.md | attest/check-complete 门序列是否按序执行 | |
| discipline-execution-honesty.md | 完成声称是否三证据齐备 | |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats plans/task-kb-deploy-20261022
```

JSON 输出：
```json
{粘贴 stats 命令原文输出}
```

- [ ] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）
- [ ] 委派率与 verdict 合规（verdict ≠ violation）

## 质量门控统计（Rule 26）
- [ ] Q1-Q6 逐项核查完成
- [ ] Evidence 抽查 ≥3 条
- [ ] 存在未处置违规 → outcome 已按 Rule 26.3 降级

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 知识库机制部署位同步 + 全部修改提交 GitHub
对照 Verification Contract 逐条复验（各项验证命令见上方 Verification Contract 段）：
- [ ] 复验 VC-1：{evidence} → PASS/FAIL
- [ ] 复验 VC-2：{evidence} → PASS/FAIL
- [ ] 复验 VC-3：{evidence} → PASS/FAIL
- [ ] 复验 VC-4：{evidence} → PASS/FAIL
- [ ] 复验 VC-5：{evidence} → PASS/FAIL
- [ ] 复验 VC-6：{evidence} → PASS/FAIL

 outcome: COMPLETE / PARTIAL / BLOCKED
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 1 部署同步 |
| 2 | Where am I going? | Phase 2 冒烟回归 → Phase 3 提交推送 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
