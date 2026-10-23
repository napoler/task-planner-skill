# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能族新增 Rule 96（子代理激活默认化+并行推进硬条款）并完成模板承载、机器门、纪元级联回归与部署位同步，使"可委派默认委派、无依赖默认并行"在新会话生效。

---

## Verification Contract (≥5 items, objective standards)

- [ ] VC-1: Rule 96 条款落地（96 预留无冲突；含激活默认矩阵/例外白名单/依赖标注并行组/同消息并发/指标留痕五面子条）
  **Verify command**: `grep -nE "96\.[0-9]" /mnt/data/dev/task-planner-skill/skills/task-planner/critical-rules.md | wc -l`（≥6 子条命中）
  Evidence: grep 输出 + rule-reserve 台账行
- [ ] VC-2: 承载面同步（SKILL.md 级联/编排指针、subagent_dispatch 与 task_plan 模板含新条款锚定措辞）
  **Verify command**: `grep -rn "Rule 96" /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md /mnt/data/dev/task-planner-skill/skills/task-planner/templates/ | wc -l`（≥3 载体命中）
  Evidence: grep 输出
- [ ] VC-3: 机器门落地（新 selftest 全绿并登记 registry）
  **Verify command**: `bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-subagent-activation.sh`
  Evidence: 脚本 exit 0 输出
- [ ] VC-4: 全量回归零破坏（纪元级联 1-94→1-96 后全套 FAIL=0）
  **Verify command**: `for f in /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-*.sh; do bash "$f" || echo "FAIL: $f"; done`
  Evidence: 全量输出 FAIL=0
- [ ] VC-5: CR 双视角通过（alignment-review 视角 + critic 视角均 APPROVED 或 BLOCKER 全闭环）
  **Verify command**: `grep -h "VERDICT" /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/subagent-state/8a-cr-alignment.md /mnt/data/dev/task-planner-skill/plans/task-subagent-boost-20261023/subagent-state/8b-cr-critic.md`
  Evidence: 双 VERDICT: APPROVED
- [ ] VC-6: 合并+部署生效（master merge --no-ff 完成；zcode/cursor 部署位变更文件 diff=0；任一位权限被拒则如实登记 PARTIAL）
  **Verify command**: `git -C /mnt/data/dev/task-planner-skill log --oneline -2` + 部署位 `diff -rq` 对账输出
  Evidence: merge commit 哈希 + diff=0 表

---

## Phase Gates

### Phase 1: 三路并行调研映射

**Goal**: 冻结规则承载面/selftest 纪元锚/部署位三份映射

**Depends on**: none

**Done when**: 检查点 subagent-state/{1,2,3}-*.md 齐且含路径+行号

**Verification**:
- [ ] V-1.1: 检查点 1 含承载表（映射 VC-1）— `ls plans/task-subagent-boost-20261023/subagent-state/1-rule-mapper.md`
- [ ] V-1.2: 检查点 2 含级联清单（映射 VC-4）— `grep -c "1-94" plans/task-subagent-boost-20261023/subagent-state/2-anchor-mapper.md`

### Phase 2: 起草 Rule 96

**Goal**: draft-rule96.md（六子条全文+逐文件编辑计划+断言清单）

**Depends on**: Phase 1

**Done when**: draft 六子条齐+每处编辑带锚点

**Verification**:
- [ ] V-2.1: `grep -cE "^#+ *96\.[0-9]|96\.[0-9] " plans/task-subagent-boost-20261023/draft-rule96.md`（≥6）
- [ ] V-2.2: 编辑计划含 critical-rules/SKILL/templates/selftest 五类落点

### Phase 3: worktree 内实现

**Goal**: 条款文本+机器门+级联全部落地（并行 S5/S6）

**Depends on**: Phase 2

**Done when**: worktree 变更清单与编辑计划一致；新 selftest 可运行

**Verification**:
- [ ] V-3.1: `git -C /mnt/data/dev/task-planner-skill-worktrees/task-subagent-boost-20261023 status --short`（变更面=编辑计划范围）
- [ ] V-3.2: 新 selftest 脚本存在（映射 VC-3）

### Phase 4: 回归门+CR 双视角

**Goal**: 全量 FAIL=0 + 双 CR APPROVED

**Depends on**: Phase 3

**Done when**: 修复循环 ≤3 轮后绿；双 verdict 落盘

**Verification**:
- [ ] V-4.1: 全量 runner FAIL=0（映射 VC-4）
- [ ] V-4.2: 双 VERDICT: APPROVED（映射 VC-5）

### Phase 5: 合并部署+簿记收口

**Goal**: merge --no-ff + 部署位 diff=0 + delivery-summary

**Depends on**: Phase 4

**Done when**: merge commit 生成；对账输出 diff=0（或 PARTIAL 登记）

**Verification**:
- [ ] V-5.1: merge commit（映射 VC-6）
- [ ] V-5.2: delivery-summary 五要素齐（映射 VC-2/VC-6）
