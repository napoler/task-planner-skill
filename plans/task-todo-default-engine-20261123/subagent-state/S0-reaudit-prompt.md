# 简版复审任务书（Rule 109 修订重审，只读）

## 1. 目标
复审上一轮 critic 审计（REJECTED: C1 I6 W5）的修复是否闭环。只读，禁改任何文件。
**关键**：VC 命令以 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/plan-state.json 的 `vcs[].command` 原文为准；verification.md 派生视图里的 `\|` 是 planctl render 的 markdown 表格管道符转义，非命令本身——不得据此判命令不可执行。

## 2. 输入（绝对路径）
- plan-state.json（权威源，VC command/rvc/decisions/resources 以此为准）
- task_plan.md、user-session-log.md（用户原话 #1 #2）
- /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-auditor.md（上轮审计问题清单）
- findings.md、progress.md（可读，可追加锚）

## 3. 复审范围（仅变更增量 + 上轮 7 个问题闭环）
逐条判定上轮 C-1/I-1..I-6 是否已闭环（state: resolved/open），每条给 file:line 或 JSON 字段证据：
- C-1: VC-4/VC-6 命令转义。核实 JSON 权威源 vcs[].command 无 `\|`/反引号且可执行（VC-4 当前 rc=1 是因为尚未实施 sync-todos B 组输出，属预期非缺陷；判定力=实施后能 PASS、未实施时 FAIL）。
- I-1: 用户#1缺陷②"冲突后 worktree 补救"是否有 R6 + VC-7 + S7 落点（查 requirements/vcs/s_units 三段）。
- I-2: OpenSpec 移交是否入 Decisions（D1.decision 含 OpenSpec）。
- I-3: B7 对齐供料是否有 RES8 指向旧计划 task-align。
- I-4: VC-6 criterion/command 是否改为 3 个具体 selftest 而非空泛"全量"。
- I-6: D1 是否澄清"机器硬门exit非0"与"静态锚selftest"不矛盾。

## 4. 验收/裁决
0 CRITICAL 且 0 IMPORTANT ⇒ APPROVED；否则 REJECTED。W/Q 留档不阻断。
若发现新问题才计 C/I；上轮 W-1..W-5 已登记接受了结，不再阻断。

## 7. 返回格式（8 字段固定，之后无任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: none | <绝对路径>
evidence: verdict=<APPROVED|REJECTED>; counts=C<n>I<n>W<n>; 逐条C-1/I-1..I-6闭环结论(带证据); ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```

## 8. checkpoint
文件：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-reauditor.md
格式：头部status行+逐条闭环判定+最终结论（=第7节8字段块）；纯markdown无frontmatter。

## 9. 上下文预算
只读 plan-state.json 相关段+上轮 checkpoint；禁整库通读；总长≤900字。
