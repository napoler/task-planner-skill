# 批次一修复任务书（subagent-state/2-executor-prompt.md）

执行体：executor · worktree 前缀 WT = /mnt/data/dev/task-planner-skill-worktrees/task-v108

## 修复项（六项，全部修正/注释增量）
- **M-01**: `WT/skills/task-planner/templates/task_plan.md` 约 :249 `worktree_path` 行示例值 `../<repo>-wt-<task-id>` → `<repo-parent>/<repo>-worktrees/<task-id>`（只改示例值，保留行内其他文字与「或 n/a」）
- **M-02**: `WT/skills/task-planner/references/critical-rules.md` 约 :49 Rule 12 内同款旧约定串 → 同款新约定（只改路径范式，不改条款语义）
- **M-03**: `WT/skills/task-planner/templates/knowledge-brief.md` :9 头注释「grep 锚计数维持 20」→「维持 22」（括注验收指向去行号化——引 template-guide 计数口径不引行号）
- **M-05**: `WT/skills/plan-template-kit/references/template-guide.md` :63「实际 26 个 .md」→「实际 25 个 .md」；:65 标题「23/26」→「22/25」
- **M-06**: `WT/skills/task-planner/templates/variant/` 下 diagnostic-type.md、publish-type.md、research-type.md、writing-type.md 四文件头部注释区（首行标题后）各补一行，依次 `<!-- template_type: diagnostic -->` / `<!-- template_type: publish -->` / `<!-- template_type: research -->` / `<!-- template_type: writing -->`（无 -type 后缀；位置对齐 bugfix-type.md 既有范式）
- **M-10**: writing-type.md :11-12,63；research-type.md :14；publish-type.md :12,15,34,90 所引不存在脚本（article_json_editor.py/verify_content_originality.py/keyword_coverage.py/rollback.sh 等）——不删行不改脚本名；每个文件在该 VC 表下方加一条统一注脚：「> 注：VC 表中脚本路径为示例值（目标项目相对路径），非本技能仓文件」——避免逐行重复

## 验收
1. 六项逐项完成；`git -C WT diff --stat` 恰好涉及 8 文件（task_plan/knowledge-brief/critical-rules/template-guide + 4 variant）
2. 每项改后 grep 旧串零残留（如 grep -c "repo>-wt-" 两文件=0；grep -c "维持 20"=0；grep -c "26 个"=0）
3. 跑 `bash WT/skills/task-planner/scripts/selftest-template-lifecycle.sh` 确认 18/18 PASS
4. checkpoint 落盘含最终结论 8 字段块

## Scope 禁改
只改上述 8 文件；selftest 只读运行；禁止 git add/commit（主进程编排）；禁动 worktree 外文件

## 返回格式（8 字段，字段名与顺序不得改，无内容填 none，8 字段后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<4> pass — 逐项原文行
files: <绝对路径>(+N/-M); ...
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:2-executor]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
