# task-v069 S1+S2 检查点（1-code-assistant）

status: completed
acceptance: ① `grep -c "Rule 29" references/critical-rules.md` = 1（≥1 达标）；`grep "29\.6"` 命中（六子条款 29.1-29.6 完整，grep -n "^29\.[1-6]" 全命中 231-236 行）② `grep -c "Rule 29" SKILL.md` = 2（执行循环 2.6 检查点 + Critical Rules 指针行，达标）③ md 格式：Read 复核新增区块（critical-rules.md L227-236 / SKILL.md L87、L277-285），列表缩进与现有 2.x 步骤、Rule 指针行风格一致，无 markdown 破损 ④ git diff --stat 见下
evidence: critical-rules.md 新增 `### 29 上下文与工作文件主动维护(P0 — task-v069,目标:上下文质量不拖垮运行)` 节（含引言 + 29.1-29.6 六条，全部要素：触发时机/节流/context_hygiene_enforce、check-context-hygiene.sh exit 码、superseded 删除线留痕、≥5 条压缩归档、progress >10 行折叠、compaction 前检查/2KB 注入/500 行压缩、plan-hygiene.sh --dry-run/--execute/--age、plans/archive/、set-active-plan.sh gc、git worktree prune、sync-todos.sh --index、plan_hygiene_enforce、plan_archive_age_days 三键语义、五条反模式）；SKILL.md：执行循环 2.5 之后插入 2.6 上下文卫生检查点（Rule 29.1① 每 2 Phase、两脚本、开关键），Critical Rules 清单规则数 1-28→1-29 并追加 Rule 29 指针行
checkpoint: 本文件
summary: 在 worktree wt/task-v069-context-hygiene @f783880 内完成 S1+S2：references/critical-rules.md 末尾追加 Rule 29（11 行新增，六子条款完整）；SKILL.md 三处改动（2.6 步骤新增、Rules 1-28→1-29、Rule 29 指针行），共 4 插入 1 删除。未触碰其他 worktree，计划三文件未修改。未提交 commit（合并回合约由主编排处理）；工作区留 modified 两文件供主进程 Read 复验后统一提交。
retry_count: 0
rescued: 否
files_modified:
  - /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene/skills/task-planner/references/critical-rules.md (+11)
  - /home/terry/task-planner-skill-worktrees/task-v069-context-hygiene/skills/task-planner/SKILL.md (+3/-1 逻辑, +4/-1 stat)

## git diff --stat
 skills/task-planner/SKILL.md                     |  4 +++-
 skills/task-planner/references/critical-rules.md | 11 +++++++++++
 2 files changed, 14 insertions(+), 1 deletion(-)

## 负结果报告
- 检查依赖：scripts/ 现存 check-conflicts.sh、plan-created.cjs、set-active-plan.sh、sync-todos.sh（规则引用均有效）；check-context-hygiene.sh / plan-hygiene.sh 为 task-v069 后续阶段（S3+）待建脚本，规则按计划先行引用，无冲突
- config.json 三键（context_hygiene_enforce/plan_archive_age_days/plan_hygiene_enforce）按任务背景已预置，规则语义与之一致
- 排除风险：未修改 SKILL.md 其他既有 Rule 语义；未触碰 plans/ 只读参考文件；markdown 列表缩进复核通过
