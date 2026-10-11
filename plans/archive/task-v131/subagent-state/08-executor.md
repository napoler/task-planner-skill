# Checkpoint: 08-executor（Phase 3 第二 S-unit，单 S-unit）

status: completed（六锚全部落位，净增 +2 行，475→477，≤12 达标；未 commit）

## 六锚落位证据（SKILL.md = /home/terry/task-planner-skill-worktrees/task-v131/skills/task-planner/SKILL.md）

| 锚 | 位置 | 证据 |
|----|------|------|
| a | :9 | frontmatter `- references/critical-rules.md: Critical Rules 全集 1-53（…`（行内替换 1-51→1-53，grep "1-51" 0 命中） |
| b | :303 | **负结果**：Rule 50 摘要 bullet 已存在于索引（Phase 2 清账时已插入，前移一行至 :303），grep `Rule 50（内容要求` 命中 :303；本 S-unit 零改动，未重复插入 |
| c | :306 | 新增 `- **Rule 53（根源解决与决策管辖 — task-v131）**：结果级需求全链工序审计+根源覆盖表（53.1）/根治判据=机制·守卫·载体三选一防复发（53.2）/决策管辖二分反推诿（53.3）/返工成本核算质量优先（53.4）；零新 config 键+selftest-root-resolution.sh 守护（53.5）`（Rule 52 bullet 之后、## Completion Gate 之前；+1 行） |
| d | :204 | 新增 C36 行（C35 之后，四列对齐 C35 既有行：`\| C36 \| 根源解决纪律（Rule 53）… \| ☐ \|`）；+1 行 |
| e | :86 | 2.5 委派检查点行内追加「；执行体选型先查覆盖矩阵与三登记面（Rule 52.1）」于「…未声明组=一次验收一组成员再派下一组成员（10-02）」之后、`Agent()` 派发之前；行内改动 0 净增行 |
| f | :330 | References 表 critical-rules.md 行描述追加「/ Rule 53 根源解决与决策管辖」；行内改动 0 净增行 |

## 验证命令输出（原文）

- `wc -l skills/task-planner/SKILL.md` → `477 skills/task-planner/SKILL.md`（基线 475，净增 +2 ≤12 ✓）
- `grep -n "Rule 53\|C36\|1-53\|Rule 50（内容要求"` 命中：:9（1-53）、:204（C36）、:303（Rule 50 已存）、:306（Rule 53 bullet）
- `git diff --stat -- skills/task-planner/SKILL.md` → `skills/task-planner/SKILL.md | 8 +++++---`，5 insertions 3 deletions；hunk 位 = @@ -9、@@ -86、@@ -203,0 +204、@@ -304,0 +306、@@ -328，共 5 hunk 全在本 S-unit 六锚范围
- 全仓 diff 中 critical-rules.md 的 16 行变更 = Phase 2 前一 S-unit 既有未提交产出（git status 开工前即 `M`），本 S-unit 未触碰

## 合规
- 只动 skills/task-planner/SKILL.md 一个文件 ✓
- 未 commit（任务明确「不 commit」）✓
- 未触碰其他 worktree/其他文件 ✓
- 判例 §4 锚级联 grep：改后 `grep -n "1-51"` SKILL.md = 0 命中，无旧锚残留；行数 477 ≤ 上限 475 旧锚未出现在 SKILL.md 内（475 阈值属 selftest 脚本，Phase 4 范围）
