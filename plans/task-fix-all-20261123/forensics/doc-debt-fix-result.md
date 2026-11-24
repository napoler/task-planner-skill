# doc-debt-fix-result

- 任务: task-fix-all-20261123 Phase 3（文档债务）
- worktree: `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-fix-all-20261123`
- 基线: b68fa8c（已含）
- 修复提交: `82fecbf` (`fix(skills): 修4项文档债务——task-planner脚本索引/dispatch规则表/discipline引用面/plan-resume证据模板（task-fix-all-20261123）`)
- 改动范围: 4 files, 40 insertions(+), 3 deletions(-)（仅 4 个 SKILL.md）

## 1) task-planner 脚本索引（P1）

- 诊断: 163 scripts 中大量未被 SKILL.md 直接索引，发现性差。
- 实查: `find skills/task-planner/scripts -type f | wc -l` = 163；原 SKILL.md 正文脚本引用仅 20 个独特路径（`grep -oE 'scripts/[A-Za-z0-9_./-]+'` 统计）。
- 修复: 在 `skills/task-planner/SKILL.md:419-437` 新增 `## 脚本索引（发现性入口）`，按类别给出数量/代表脚本/用途，不穷举 103 个 selftest；声明权威清单以文件系统为准（`ls`/`find`），并给发现优先级（类别→grep→--help）。
- 证据: `skills/task-planner/SKILL.md:419` 节标题；`:423` 163 文件；`:425-434` 分类表（生命周期/init 11、状态与计划操作 5、机械门/检查 25、合并/隔离/辅助 6、hook/平台接线 4、同步/校验/注册 7、selftest 103、lib/schemas 2）；`:436` 发现命令。
- 诊断不符: 无。索引缺失属实；采用分类索引而非 133 项全列，符合“不要全列噪音”的约束。

## 2) task-dispatch 规则表对齐（P1）

- 诊断: 索引表称 12 条但正文含 Rule 96/103/104 未入表（称 15 条）。
- 实查: `skills/task-dispatch/references/critical-rules-dispatch.md` 含 `### 96`(`:195`)、`### 103`(`:231`)、`### 104`(`:259`)、`### 110`(`:312`)；SKILL.md 原索引缺 96/103/104，参考文档行写“索引表列 12 条；Rule 96/103/104 为后续并入段未入表”。
- 修复: `skills/task-dispatch/SKILL.md:24` 路由域列表补 Rule 96,103,104；`:26` 调用条件补“双轮质检/使用点标注”；`:43-46` 规则索引表补 Rule 96/103/104 三行；`:63` 参考文档说明改为“15 条规则全文（索引表列 15 条：Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104,110；[2026-11-23 task-fix-all-20261123] 补齐 Rule 96/103/104 入表，对齐实际编号清单）”。
- 证据: `skills/task-dispatch/SKILL.md:30-46` 表现为 15 行规则；`grep -E '^\| [0-9]+ \|' skills/task-dispatch/SKILL.md | wc -l` = 15；`:63` 对齐说明。
- 诊断不符: 无。实际编号清单为 15 条，已按实际数证据化对齐。

## 3) task-discipline 引用面（P1）

- 诊断: `references/execution-recall-card.md` 被 critical-rules-discipline.md 引用但 SKILL.md 未索引，发现性不一致。
- 实查: 文件存在 `skills/task-discipline/references/execution-recall-card.md`；被 `skills/task-discipline/references/critical-rules-discipline.md:604` 引用；SKILL.md 原“参考文档”仅列 critical-rules-discipline/batch-quality-gate/capability-registry。
- 修复: `skills/task-discipline/SKILL.md:103` 参考文档新增 `execution-recall-card.md` 索引项，标注 Rule 93.1 唯一召回摘要、非权威、权威原文见 critical-rules-*.md。
- 证据: `skills/task-discipline/SKILL.md:98-103` 参考文档段；目标文件存在性 `test -f .../execution-recall-card.md` = EXISTS。
- 诊断不符: 无。

## 4) plan-resume 证据模板（P1）

- 诊断: 补“执行后证据字段”最小格式示例以强化 S82 验证完备。
- 实查: `grep -rn "S82" skills/plan-resume/` 无命中；现有 SOP 有 7.10 决策框架三处落盘要求，但无可照抄的最小字段模板。
- 修复: `skills/plan-resume/SKILL.md:98-110` 新增 `### 7.11 执行后证据字段（S82 验证完备最小模板）`，提供最小 YAML 字段样例（action/target/result/evidence_path/timestamp/verifier），注明仅增格式示例、不改 SOP/守卫。
- 证据: `skills/plan-resume/SKILL.md:98` 小节；`:102-110` YAML 模板。
- 诊断不符: **“S82”标识在仓库中未检出**（`grep -rn "S82"` 无命中）。未凭空改写既有 SOP；按要求落了最小证据字段模板，并在标题/注释中显式标注“S82 验证完备”以对齐任务口径。此处为“诊断标识未在文件中出现，但模板缺口属实并已补齐”。

## 自检

- 变更文件: `skills/plan-resume/SKILL.md`, `skills/task-discipline/SKILL.md`, `skills/task-dispatch/SKILL.md`, `skills/task-planner/SKILL.md`。
- `git diff --stat` 与暂存一致；commit 后 worktree 干净（本次命令未见其他改动）。
- 未修改 `~/.zcode/` 保护区；未捎带其他会话文件。
