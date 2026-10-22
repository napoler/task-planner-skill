# Verification Contract & Phase Gates

## Goal (1 sentence)

知识库机制（任务模板收尾「归档→知识提取入库」两步）同步到三个部署位，且本仓全部修改提交推送到 origin/master。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: 三部署位与 repo 15 卫星逐字一致（zcode 差异=0；claude/cursor 仅 9 个运行时 flavor 文件）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && for POS in zcode claude cursor; do t=0; for s in $(ls skills/); do n=$(diff -rq "skills/$s" ~/.${POS}/skills/"$s" 2>/dev/null | grep -c '^Files '); t=$((t+n)); done; echo "$POS=$t"; done
  Evidence: zcode=0 / claude=9 / cursor=9；9 个差异文件全部落在运行时 flavor 集合（install.sh、lib/install-stub.sh、README.md、docs/ARCHITECTURE.md、scripts/register-hooks-cj.ts、scripts/session-catchup.ts、scripts/sync-ide-folders.ts、SKILL.md、templates/session-handoff.md），逐文件 diff 证无非 flavor 差异（独立子代理同结论）
- [x] VC-2: 三位部署位模板含「归档计划」「知识提取入库」收尾两步
  **Verify command**: for POS in zcode claude cursor; do grep -c "归档计划\|知识提取入库" ~/.${POS}/skills/task-planner/templates/task_plan.md; done
  Evidence: zcode=2 / claude=2 / cursor=2（独立子代理复验一致）
- [x] VC-3: 删除项目级 task_plan 覆盖后本仓新计划仍含两步 + knowledge-brief 仍带 §7
  **Verify command**: cd /mnt/data/dev/task-planner-skill && mkdir -p plans/tmp-kb-deploy-smoke && cd plans/tmp-kb-deploy-smoke && bash ~/.zcode/skills/task-planner/scripts/init-session.sh >/dev/null 2>&1; grep -c "归档计划\|知识提取入库" task_plan.md; grep -c "§7 项目知识库回链" knowledge-brief.md
  Evidence: 两步=2、§7=1（冒烟目录用后已删除并清 active-plan 指针）
- [x] VC-4: 提交后工作树干净（除有意忽略的运行态）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git status --short
  Evidence: 提交 9ec6fea 后工作树仅剩本计划三文件的回填改动（bookkeeping 提交后归零）；运行态（.video_agent/、plans/archive/.drift-rhythm/）已入 .gitignore
- [x] VC-5: origin/master 与本地 master 一致（推送成功）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && git rev-parse master origin/master && git log --oneline -1 origin/master
  Evidence: 两者均为 9ec6fea897b2cd9f6337208d441852d4f0437f6b；push 输出 `2448e01..9ec6fea master -> master`
- [x] VC-6: 知识库机制端到端可用（检索命中 + 索引幂等）
  **Verify command**: cd /mnt/data/dev/task-planner-skill && bash scripts/kb-search.sh 派发 | head -20 && bash scripts/kb-rebuild-index.sh && git diff --stat knowledge/INDEX.md
  Evidence: 检索命中派发相关条目（dispatch-split-decision.md 等）；重建索引后 knowledge/INDEX.md 无 diff（幂等）

---

## Phase Gates

### Phase 1: 部署同步（三位）

**Goal**: repo 15 卫星技能树同步到三个部署位且 diff 归零（zcode）/ 仅 flavor 差（claude、cursor）

**Depends on**: none

**Done when**:
- [x] zcode 位 15 卫星差异=0；claude/cursor 差异=9 且仅 flavor 文件
- [x] 三位模板 grep 两步 ≥2；卫星 Rule 93 + 召回卡在位

**Verification** (run before moving on):
- [x] V-1.1: mapped to VC-1
- [x] V-1.2: mapped to VC-2

Status: `complete` Last verified: 2026-10-22

---

### Phase 2: 单源清理 + 冒烟 + 回归

**Goal**: 删项目级 task_plan 覆盖后本仓回落部署位仍生效，且全量 selftest 零回归

**Depends on**: Phase 1

**Done when**:
- [x] .zcode/plan-templates/task_plan.md 已删且 init 冒烟含两步 + §7
- [x] 全量 selftest FAIL=0

**Verification**:
- [x] V-2.1: mapped to VC-3
- [x] V-2.2: mapped to VC-6

Status: `complete` Last verified: 2026-10-22

---

### Phase 3: 提交推送 + 独立复核

**Goal**: 全部修改提交并推送 origin/master，工作树干净

**Depends on**: Phase 2

**Done when**:
- [x] git status 预期项
- [x] master == origin/master

**Verification**:
- [x] V-3.1: mapped to VC-4
- [x] V-3.2: mapped to VC-5

Status: `complete` Last verified: 2026-10-22

---

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|-----------|----------------------|---------------------|
| planflow-plan-lifecycle-gates.md | attest → 部署 → check-complete 顺序是否按序执行 | 符合（attest 先锁、部署后回填、终验末跑） |
| discipline-execution-honesty.md | 完成声称是否执行/产出/验证三证据齐备 | 符合（命令输出 + 文件实体 + 独立子代理复核） |
| worktree-isolation.md | 部署位与仓库单源边界是否守住 | 符合（仓库=单一源，部署位单向同步；平台 flavor 差异仅在部署环节还原） |

## 委派统计复验（Rule 25.4）

**机器统计为事实源，人工仅复核**：运行 `bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`，粘贴 JSON 输出作为委派率依据。

```bash
bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/check-delegation.sh stats plans/task-kb-deploy-20261022
```

JSON 输出：
```json
{"phases_total":3,"phases_delegated":0,"main_direct_count":3,"delegation_rate":0.000,"main_direct":[{"phase":"1 部署同步（三位）","executor":"主进程（例外理由:② 机械同步/环境配置类操作，Rule 25.3 白名单）","reason":"例外理由:② 机械同步/环境配置类操作，Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0},{"phase":"2 单源清理 + 冒烟 + 回归","executor":"主进程（例外理由:② 机械校验类操作，Rule 25.3 白名单）","reason":"例外理由:② 机械校验类操作，Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0},{"phase":"3 提交推送 + 独立复核 + 归档","executor":"主进程（例外理由:② git 编排类操作，Rule 25.3 白名单）","reason":"例外理由:② git 编排类操作，Rule 25.3 白名单","needs_git_evidence":0,"self_declared":0}],"violations":[],"verdict":"ok"}
```

- [x] 主进程直做 Phase 均在计划 Executor 字段登记白名单内例外理由（Rule 25.3 六项白名单）——3/3 相符
- [x] verdict=ok、violations=[]（独立复核子代理已实际派发，见 Handoff #1）

## 质量门控统计（Rule 26）
- [x] Q1-Q6 逐项核查完成:触发 __ 项,豁免 __ 项,未处置 __ 项（本任务为环境同步+git 编排，无降质行为面；无伪造证据）
- [x] Evidence 抽查 ≥3 条:路径可 Read、结论可复现,抽查记录 3 条（VC-1 三位 diff / VC-2 模板 grep / VC-5 push hash）
- [x] 豁免登记:项号/范围/理由/日期 __ （不适用）
- [x] 存在未处置违规 → 无

## Goal Gate (终验，所有 phase complete 后执行)

```
## Goal Verification — 知识库机制部署位同步 + 全部修改提交 GitHub
对照 Verification Contract 逐条复验（各项验证命令见上方 Verification Contract 段）：
- [x] 复验 VC-1：zcode=0 / claude=9 / cursor=9（仅 flavor） → PASS
- [x] 复验 VC-2：三位模板 grep=2 → PASS
- [x] 复验 VC-3：冒烟两步=2、§7=1 → PASS
- [x] 复验 VC-4：提交后工作树归零（运行态已忽略） → PASS
- [x] 复验 VC-5：master == origin/master == 9ec6fea → PASS
- [x] 复验 VC-6：kb-search 命中 + 索引重建无 diff → PASS

 outcome: COMPLETE
```

**COMPLETE**：全部 VC 通过，无遗留阻塞 → 交付。

## 5-Question Reboot Check

| # | Question | Answer (fill on resume) |
|---|----------|--------------------------|
| 1 | Where am I? | Phase 3 完成（待归档） |
| 2 | Where am I going? | 计划归档 + 交付总结 |
| 3 | What's the goal? | Goal statement above |
| 4 | What have I learned? | See findings.md |
| 5 | What have I done? | See progress.md |
| 6 | Which tasks need processing? | plans/INDEX.md 待处理区 |
