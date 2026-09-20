# S8 checkpoint — selftest-mechanism-profile.sh 新建 + TL-18 追加（task-v085 Phase 3）
status: complete（新脚本 19/19 PASS exit 0 含行为级三档；lifecycle 18/0；相邻 selftest-dispatch/selftest-veto 回归 23/13 全 PASS）

## 改动
- 新建: /home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile/skills/task-planner/scripts/selftest-mechanism-profile.sh（151 行, bash, 仿 selftest-template-lifecycle/selftest-veto 范式）
  - 静态断言 16 条（MP-01..16）：Rule 37 头 + 37.1-37.5 五子条锚 + FMEA R1 兜底「通用守卫对全部任务类型不变」；template-mapping.md `^## 九、` + writing/research/publish 三行「不适用」；SKILL.md「类型适配（Rule 37）」+ `^| C25 ` 行 + Critical Rules 列表 Rule 37 行（grep -A 40 窗口）；config.json mechanism_profile_enforce（jq 校验 default=warn + enum 三档）；templates/task_plan.md「机制画像」≥2 处（实测 2）；template-guide.md「机制画像」≥1 处（实测 1）；check-complete.sh mechanism-profile 段三锚（`mechanism-profile` + `TASK_PLANNER_MECHANISM_PROFILE_ENFORCE` + `mechanism_profile_enforce`）
  - 行为级 3 条（MP-17/18/19）：fake plan（writing + code_review required + 2 complete Phase + S-unit 表 + Handoff 表 + VC 表 5 行 + findings/progress 非 stub）在 mktemp 目录，默认档 exit 0 且 ⚠ 提示 / enforce 档 exit 1 且 ✗ / off 档 0 行机制画像输出且 exit 0；rm -rf 清理（/tmp 残留实测 0）
- 追加: skills/task-planner/scripts/selftest-template-lifecycle.sh:21-22（头注释 17→18 + TL-18 行）与 L83-84（TL-18 断言 `grep -q '^## 九、' "$TMAP"`，TMAP 变量 L33 已定义, 断言 1 行 + else bad 一行）；Total 行为 `$((PASS+FAIL))` 动态计数, 无硬编码需同步
- 未改动: config.json / check-complete.sh（S6/S7 已交付, 本 S-unit 零触碰）

## fake plan 构造要点（实测修正, 供后续复用）
前置 gate 全放行需要（缺一即被拦, 归因不清）: ① findings/progress 各 ≥3 实质行（3-File Gate stub 判定）② 2 个 complete Phase（python 段 ALL PHASES COMPLETE → python_rc=0）③ Handoff 表含 article-writer 行（委派率 gate 否则 unverified_delegation → verdict=violation → 该 gate exit 1）④ 每 Phase S-unit 表 `| ID | 目标 | 执行体 | ...`（否则 PLAN-DISPATCH GATE FAILED）⑤ VC 表 ≥5 行 + 每 Phase `- **V-N:** VC-x` 映射（VC-GATE, 缺则 warn 不拦）⑥ 无 `skills/task-planner/` 字面行（SKILL-MODIFY GATE skip）
首版 probe 用 article-writer 无 Handoff → DELEGATION GATE FAILED rc=1 双档归因污染；补 Handoff + S-unit 表后默认档 rc=0、enforce rc=1、off rc=0 且 0 行输出

## 实测证据（worktree 内, 2026-09-20）
```
bash scripts/selftest-mechanism-profile.sh → MP-01..MP-19 全 PASS, Total: 19 PASS=19 FAIL=0, EXIT=0
bash scripts/selftest-template-lifecycle.sh → TL-01..TL-18 全 PASS, Total: 18 PASS=18 FAIL=0, EXIT=0
bash scripts/selftest-dispatch.sh          → Total: 23 PASS=23 FAIL=0, EXIT=0（回归不受影响）
bash scripts/selftest-veto.sh             → Total: 13 PASS=13 FAIL=0, EXIT=0（抽查第 2 个相邻）
git status --short: M config.json M scripts/check-complete.sh M scripts/selftest-template-lifecycle.sh
                   ?? scripts/selftest-mechanism-profile.sh（M 两项为 S6/S7 既有交付, 本 S-unit 未改）
```

## 备注
- MP-12 用 `grep -A 40 '^## Critical Rules'` 窗口匹配 Rule 37 行（Rule 37 摘要行在 Critical Rules 节内 L310）
- MP-14/15 计数用 grep -c 精确核对（task_plan=2 / guide=1, 与材料包「≥2 / 1 处」一致）
- 未做（范围外）: selftest-mechanism-profile.sh 未接入既有 selftest 聚合调用点（如存在 aggregate runner 由主计划侧处理）；bash -n 语法检查随实测执行隐式通过
- 文件模式: selftest-mechanism-profile.sh 落 755（对齐仓内 selftest-veto.sh/check-complete.sh 的 100755 约定）；selftest-template-lifecycle.sh 保持提交态 644（仓内既有非可执行, 未动模式）。曾误 chmod +x lifecycle 后已还原, git status 确认 M 仅含 5 行内容 diff 无 mode 变更
