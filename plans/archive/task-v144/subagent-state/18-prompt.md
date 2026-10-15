# Subagent Dispatch Prompt（S18 — CR 闭环修复 P2-2/P2-3/P2-5 + FG 键级联，Rule 35.3 落盘版）

## 1. 目标
CR 闭环收尾（Code Reviewer CHANGES_REQUESTED 剩余 P2 + S17 引出的 FG 键级联）：八子条统一/注释修正/local 卫生/FG 键枚举。
> 本会话只执行本 S-unit（Rule 46.1）；首动作：Read 本文件全文后按验收执行
- **需求锚（Rule 51.1a）**: R6:「总之就是存在严重的缺陷 子代理拆分细致拆分 以及 任务分段执行」（守护锚与实现一致性收尾）

## 2. 输入(读写契约)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v144/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v144/findings.md — 可读;可写=仅追加 `#### [sub:18-code-assistant] <标题>` 到 `## Research Findings` 段末（材料索引对齐 brief §5 口径）
- progress: /mnt/data/dev/task-planner-skill/plans/task-v144/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:18] <摘要>`
- 材料包（worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v144）:
  - P2-2 八子条统一: scripts/selftest-subagent-granularity-skill-escort.sh——SG-02 断言 `^59\.[1-7] ` =7 → 改 `^59\.[1-8] ` =8（59.8=关系澄清子条,对齐 Rule 58.8/60.7 惯例,入守护）;scripts/selftest-registry.tsv 本任务行「59.1-59.7 七子条」→「59.1-59.8 八子条」;三同步
  - P2-3 注释修正: scripts/analyze-splits.sh 约 :148 注释「缺段按 0 计——部分填报也体检已报值」与实现相反（实际缺段/畸形走 SKIPPED 放行）→ 改「缺段/畸形 → SKIPPED 放行（不计违规,与头注释口径一致）」
  - P2-5 local 卫生: scripts/check-dispatch.sh——fine_grain_checks 函数内 ⑥⑦ 新增的未声明局部变量（fmax/lmax/mmax/gtok/gfv/gl/gm/esrcs/er/epath/p/raw/f/l/m/k/kk/over/g1/g2/g3 等,以实际 grep 为准）并入函数顶部既有 local 声明（一行扩列或分号续行）;行为零变化（改后跑 selftest-dispatch.sh 31 断言+dispatch-grain 10+fine-grain-steps 11 全过）
  - FG 键级联（S17 blockers）: scripts/selftest-final-gate-hash.sh 键④枚举（当前 PASS=21 FAIL=1）——S17 的 check-plan-dispatch 新消费 `subagent.step_max_lines` 键致枚举漂移;把该键补入键④的 subagent.* 枚举清单（对齐既有键列格式）,级联注释 `[2026-10-08 task-v144 合并级联: check-plan-dispatch ⑤-c 新消费键]`
- 上下文依赖: S17 已 complete
- 工具面提示: Edit+Bash 验证

## 3. 验收标准(可观察证据)
- [ ] 四项修后实跑: selftest-subagent-granularity-skill-escort.sh（SG-02 过且总数≥23 全 PASS）/ analyze-splits.sh 双 fixture 仍 rc 0/1 判据不变 / selftest-dispatch.sh+selftest-dispatch-grain.sh+selftest-fine-grain-steps.sh 全 FAIL=0（local 卫生零行为变化）/ selftest-final-gate-hash.sh FAIL=0（贴各 Total 原文行）
- [ ] registry.tsv 本任务行文案更新（仅该行内改写）
- [ ] 每处修改三同步（适用处）+级联注释
- [ ] git diff 仅涉及的 4 个文件（SG 守护/registry/analyze-splits/check-dispatch/final-gate-hash 按实际触碰列）
## 4. Scope 禁改清单
- 禁止修改: worktree 内除上述目标文件外一切（periodic-review PR×4 是登记遗留禁修） | 禁止: git add/commit
## 5. 工作路径
- /mnt/data/dev/task-planner-skill-worktrees/task-v144（禁触其他 worktree）
## 6. 时长预算
- CR 收尾 → 12 分钟超时返回 partial
## 7. 返回格式(严格 — 8 字段,无内容填 none,之后不得有任何内容）
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <锚点> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
## 8. checkpoint 落盘路径(强制 — Rule 22.8)
- /mnt/data/dev/task-planner-skill/plans/task-v144/subagent-state/18-code-assistant.md（最终结论=第 7 节同一 8 字段块,置 status）
