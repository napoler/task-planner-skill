# S77 修复后技能执行 — 新会话验证清单

> **用途**：S77 P1/P2 修复合并回 master 后，在**全新会话**中验证技能执行正确性。
> **Why 新会话**：技能文件（SKILL.md/WORKFLOW.md）改动需新会话加载方生效；本会话内存中的旧版技能定义不能代验（§十二 已知限制）。
> **验证时间**：2026-10-20
> **基线**：master @ 42d72b4（S77 P1 merge c75384d + P2 merge 42d72b4）

---

## 一、task-planner [M]/[A] 拆分执行流验证（重点）

### 1.1 加载验证
- [ ] 新会话中 `Skill(skill="task-planner")` 加载的 SKILL.md 含 [M]/[A]/[M+A] 标记（grep 验证）
- [ ] 标记分布与 master 一致（task-planner 12 处 / todo-skill 7 处 / 19 技能合计）

### 1.2 执行流顺序验证（⚠️ 已知缺陷）
- [ ] **Phase 执行循环顺序**：确认执行时按 1→2→2.5→2.5b→2.5c→2.5d→3→4→4.5→5→6 逻辑顺序，而非文档顺序（[M]块 1,2,3,4,4.5,5 → [A]块 2.5,2.5b,2.5c,2.5d,6）
- [ ] **关键判据**：2.5 委派检查点（Rule 25）必须在 3 执行 Phase 工作**之前**执行——若新会话中执行顺序颠倒（先 3 后 2.5），则缺陷坐实
- [ ] 观察 executor 是否因子步文档后移而误判执行顺序

### 1.3 门控/守卫验证
- [ ] PreToolUse hook（哨兵/委派门控/skill-modify）在 [M]/[A] 标记插入后仍正常触发
- [ ] check-scope.sh / check-delegation.sh / check-skill-modify.sh 对新标记文本无误判
- [ ] init-session.sh 生成的 7 文件结构不受标记影响

### 1.4 回归验证
- [ ] 新会话跑 `bash scripts/run-selftests.sh` → 92/92 PASS / 0 FAIL

---

## 二、P2 修复验证

### 2.1 P2-3 task-planner 智能步骤就地化
- [ ] SKILL.md [A] 思维方法论解构步骤含「就地触发条件摘要」段（T1-T5 触发场景）
- [ ] executor 无需打开 methodology.md 即可判定 T1-T5 触发时机
- [ ] 摘要内容与 methodology.md §思维方法论 T1-T5 一致（无转述失真）

### 2.2 P2-4 todo-skill WORKFLOW.md 更新
- [ ] WORKFLOW.md §3 "Step checklist items" 行为 "✅ Yes (Step 1-6)"
- [ ] WORKFLOW.md §4 描述 6 步工作流，无 "Single-step" 残留
- [ ] 与 SKILL.md 6 步工作流一致

---

## 三、行为面冒烟（新会话实弹）

- [ ] 新会话触发一次 task-planner 轻量任务（≤2 文件 trivial 修改），观察 [M]/[A] 步骤是否按逻辑顺序执行
- [ ] 观察 [A] 智能步骤（委派/DRIFT 判定）是否在新标记下仍正常触发
- [ ] 观察 [M] 机械步骤（脚本调用/落盘）是否在新标记下仍正常执行

---

## 四、已知缺陷与建议

### 4.1 [M]/[A] 拆分执行流缺陷（✅ 已修复 2026-10-21）
- **现象**：Phase 执行循环 [A] 子步（2.5/2.5b/2.5c/2.5d/6）文档顺序后移至 [M] 子步（3/4/4.5/5）之后，与逻辑执行顺序（2.5 须先于 3）冲突
- **证据**：git 69a05b1^ vs 69a05b1 — 拆分前 1→2→2.5→3→…→6 交错，拆分后 [M]块+[A]块分离
- **修复**（用户裁决最简方案，2026-10-21）：保留小数点编号 + 内联 [M]/[A] 标签，合并两块标题为单条目，恢复交错（1[M]→2[M]→2.5[A]→2.5b[A]→2.5c[A]→2.5d[A]→3[M]→4[M]→4.5[M]→5[M]→6[A]）。commit 0c9a408 + merge 45eda8c，已部署仓库位→安装位。
- **验证**：worktree 全量 selftest 92/92 PASS（干净 ledger 基线）；子步顺序经脚本断言 1→2→2.5→…→6 升序。
- **残留**：master selftest 91/92（唯一 FAIL=selftest-rule-reserve-pairing，task-v195-spec-recall 在途 reserved-93，非本任务回归，待其 land 转绿）。

---

**生成时间**：2026-10-20
**生成执行体**：主进程（行为面验证 + P2 修复）
