# Subagent Dispatch Prompt（S17 — CR 闭环修复 P1-2+P2-1，Rule 35.3 落盘版）

## 1. 目标
CR 闭环修复（Code Reviewer 判定 CHANGES_REQUESTED 的 P1-2 与 P2-1）：落地 check-plan-dispatch.sh 粒度三值 enforce 门控 + Rule 59 消费侧落点。
> 本会话只执行本 S-unit（Rule 46.1）；首动作：Read 本文件全文后按验收执行
- **需求锚（Rule 51.1a）**: R1:「还是当前拆分子代理存在严重的缺陷 没有将子代理任务拆分细致 导致单个子代理解决巨量任务」（59.1 声称的计划期硬门必须真实存在）

## 2. 输入(计划三文件必传,绝对路径 — Rule 22.4a 读写契约)
- task_plan: /mnt/data/dev/task-planner-skill/plans/task-v144/task_plan.md — 只读
- findings: /mnt/data/dev/task-planner-skill/plans/task-v144/findings.md — 可读;可写=仅追加 `#### [sub:17-code-assistant] <标题>` 到 `## Research Findings` 段末（材料索引对齐 brief §5 口径）
- progress: /mnt/data/dev/task-planner-skill/plans/task-v144/progress.md — 可读;可写=仅在 Phase 3 段「Actions taken」下追加 `  - [sub:17] <摘要>`
- 材料包（CR 发现原文已含定位）:
  - 目标 A: worktree=/mnt/data/dev/task-planner-skill-worktrees/task-v144 下 skills/task-planner/scripts/check-plan-dispatch.sh——P1-2 选方案 (a): 在既有 S-unit 行解析区（约 :225-265,`$7` 时长校验之后）新增 `$8` 粒度三值校验——`awk -F'|' '{print $8}'` trim 后匹配 `^([0-9]+)f/([0-9]+)l/([0-9]+)min$`（空/不匹配→SKIPPED 一行提示「粒度三值未填报（Rule 59.1 强制）」不阻断——旧格式计划兼容 fail-open）;匹配则逐值对 jq 读 `subagent.step_max_files/lines/minutes`（缺失回退默认 2/100/15）超限 → add_violation（复用该脚本既有 violation 管线,enforce 拒锁）,提示串含「Rule 59.1 粒度三值硬门」
  - 目标 B: worktree 下 skills/task-planner/references/critical-rules.md——59.1 子条措辞精确化: 「check-dispatch.sh/check-plan-dispatch.sh 由原 SKIPPED 提示升级为 enforce」改为「check-plan-dispatch.sh attest 时对粒度三值列超限 SKIPPED→enforce 拒锁（本条落地,task-v144）;check-dispatch.sh 派发侧为新增检测（该脚本此前无粒度检查）,prompt 含 Nf/Nl/Nmin token 超限即 enforce」;顺带 P2-4: 文件尾补行尾换行
  - 目标 C: worktree 下 skills/task-planner/SKILL.md——P2-1 消费侧三落点: 合规清单 C42 之后新增 C43 行（Rule 59: S-unit 三值/伴飞自查——计划期粒度三值强制填报+超限回炉,派发任务书伴飞技能注入）;执行循环 2.5（约 :85 委派检查点段）追加 Rule 59 指针一行;Critical Rules 摘要 bullet 列表（Rule 58 与 62 bullet 之间）补 Rule 59 一行
- 上下文依赖: 全部前序单元 complete;P1-1（SKILL:9 换行）已由主进程修复
- 工具面提示: Edit+Bash 验证

## 3. 验收标准(可观察证据)
- [ ] check-plan-dispatch.sh 三 fixture 实测: 含 `| S1 | ... | 10min | 3f/150l/20min | ... |` 的超限计划→exit 1 且输出含「Rule 59.1」;合规计划（/mnt/data/dev/task-planner-skill/plans/task-v144/task_plan.md 真实表）→exit 0;无粒度列旧格式→SKIPPED 提示+exit 0（贴命令与关键输出行）
- [ ] critical-rules.md 59.1 措辞更新+文件尾换行（`tail -c1 | xxd` 验证 0a）
- [ ] SKILL.md C43+2.5 指针+59 bullet 三落点（grep 各命中）
- [ ] 三文件改后: bash scripts/selftest-subagent-granularity-skill-escort.sh 仍全 PASS;bash scripts/check-plan-dispatch.sh <本任务计划> exit 0
- [ ] git diff 仅这三文件

## 4. Scope 禁改清单
- 禁止修改: worktree 内除三目标文件外一切 | 禁止: git add/commit
## 5. 工作路径
- /mnt/data/dev/task-planner-skill-worktrees/task-v144（禁触其他 worktree）
## 6. 时长预算
- CR 修复 → 15 分钟超时返回 partial
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
- /mnt/data/dev/task-planner-skill/plans/task-v144/subagent-state/17-code-assistant.md（最终结论=第 7 节同一 8 字段块,置 status）
