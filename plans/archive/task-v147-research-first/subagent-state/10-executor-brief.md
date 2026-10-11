# 任务书：守卫锚 1-63 级联宽化（Handoff #10，executor 执行）

## 背景
SKILL.md 计数锚已由 task-v147 从 `Critical Rules 1-62` 演进为 `Critical Rules 1-63`（Rule 63 检索优先与反推诿纪律已落地，63.1-63.6 六子条实测在位）。6 个守卫脚本的旧字面锚断言需同范式演进——纯机械字面替换+注释追加，不改断言语义结构。
格式模板=各脚本内既有注释「[2026-10-08 task-v144 合并级联] 'Rules 1-39'=2 → 'Critical Rules 1-62'≥1」，本次照抄追加 task-v147 一代。

## 需求锚
R4（有理有据）关联守卫面；53.2 根治判据=守卫载体随规则演进同步。

## 计划三文件（22.4a 读写契约）
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/task_plan.md —— 只读
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/findings.md —— 可读+可写=仅追加你自己的小节 `#### [sub:10-executor] 守卫锚级联宽化回执` 到「## Research Findings」段末尾
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/progress.md —— 可读+仅在 Phase 4 段「Actions taken」下追加 `[sub:10]` 子项
- /mnt/data/dev/task-planner-skill/plans/task-v147-research-first/knowledge-brief.md —— 只读；必读 §4（易错点：禁触碰既有断言语义）与 §2（selftest 基线口径）

## 工作文件（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first/skills/task-planner/scripts/ 下；行号以 grep 实时重验为准）
- selftest-lane-advancement.sh（LA-12，约 :122-130 一族）：`'Critical Rules 1-62'` → `'Critical Rules 1-63'`（注释行+断言行+ok/bad 文案同步）
- selftest-requirement-coverage.sh（RC-11，约 :118-128 一族）：同上宽化
- selftest-self-resolution.sh（SR-07，约 :11-12/:68-71）：同上宽化
- selftest-tool-selection.sh（TS-05，约 :9-10/:55-58）：同上宽化
- selftest-workflow-orchestration.sh（WF-10，约 :8-13/:59-67）：族求和双模式 `'Critical Rules 1-62'`+`'1-62'` → `'Critical Rules 1-63'`+`'1-63'`（阈值 ≥3 不变；ok/bad 文案同步）
- selftest-drift-check-subagent.sh（DCS-11，约 :55-56）：`grep -q 'Rule 40-62 全集'` → `grep -q 'Rule 40-63 全集'`（SKILL.md :276 头注已演进为 40-63 全集；Rule 61 两锚不变）

每个脚本在改动断言的注释行追加一代演进注（照抄既有格式）：
`[2026-10-08 task-v147 合并级联] '1-62'→'1-63'：Rule 63 已由 task-v147 合法落地（63.1-63.6 实测六子条），锚同步演进`
（DCS-11 版本写：`[2026-10-08 task-v147 合并级联] 'Rule 40-62 全集'→'Rule 40-63 全集'：Rule 63 已落地，头注全集括注同步演进`）

## 验收标准（在 scripts/ 目录内逐一运行，逐项 PASS/FAIL 回执）
- 宽化六脚本各跑一遍全绿：lane-advancement / requirement-coverage / self-resolution / tool-selection / workflow-orchestration / drift-check-subagent 全部 FAIL=0
- bash selftest-research-first.sh 仍 `12 PASS=12 FAIL=0`（确认未误伤新守护）
- `git -C <worktree> diff --stat` 仅上述 6 文件

## Scope 禁改清单
仅允许 Edit 上述 6 个 selftest 脚本；禁止改 SKILL.md/critical-rules.md/模板/业务脚本/其他 selftest；禁止任何 git add/commit；禁止改计划三文件既有内容。

## 工作路径 / 时长预算 / 上下文预算
- 工作路径：/mnt/data/dev/task-planner-skill-worktrees/task-v147-research-first
- 时长预算：14min；上下文预算：Grep 定位后局部 Read，禁通读全仓
- 检索优先契约（Rule 63 dogfood）：遇到不确定（断言语义/行号漂移）→ 先 Read 源码上下文定位（附 file:line 来源），穷尽前禁止以「不知道」作答；无法解决→blockers+已检索清单，禁止编造

## 检查点（22.8，T1-T5）
/mnt/data/dev/task-planner-skill/plans/task-v147-research-first/subagent-state/10-executor.md —— 里程碑即落盘；T5 最终结论段=8 字段块置 status。

## 返回格式（严格，8 字段，字段后无内容）
status: done|partial|failed|timeout
acceptance: n/total 逐项 PASS/FAIL 及 ≤20 字原因
files: 绝对路径 +N/-M
evidence: file:line 或 命令→关键输出
checkpoint: 绝对路径 + status
findings_written: 小节锚点|none
blockers: none|一句话
confidence: HIGH|MED|LOW
