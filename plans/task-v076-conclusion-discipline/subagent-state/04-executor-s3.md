# Checkpoint: 04-executor-s3（Rule 35 条款 + 22.4 补救句）

- 时间: 2026-09-16 23:0x
- 执行体: executor（sonnet-1）
- 状态: DONE（可提交）
- resume_from: 无需

## 输入
- 任务: S3 向 critical-rules.md 追加 Rule 35 条款 + 22.4 行末补救句，只改这一个文件
- 目标文件（worktree）: /mnt/data/dev/task-planner-skill-worktrees/task-v076-conclusion-discipline/skills/task-planner/references/critical-rules.md
- 参考: plans/task-v076-conclusion-discipline/task_plan.md S3 行验收标准 + findings.md

## 锚点确认（改前）
- 改前文件 290 行，Rule 34 段止于 L290（34.6 机制行），文件尾有换行
- L127 = `22.4 **派发 prompt 必须自包含且短**...(Rule 21.2 强化)`，行末原文 `check-dispatch.sh 校验 prompt 字符数 vs prompt_max_chars 与多 S-unit 打包，挂 dispatch_contract_enforce 档位）`
- 改前 `grep -c '35\.[1-6]'` = 0（无既有 35.x，无冲突）

## 改动
1. L290（34.6 行）后追加 `### 35 执行结论纪律：能力否定查证 + 大输入落盘引用（P0 — task-v076）` 标题 + 35.1-35.6 六子条全文（逐字照任务文本），现位于 L292-299
2. L127 行末追加：`；超限补救=Rule 35.3 大输入落盘引用（内容写文件+prompt 只放路径与 Read 指令），禁止失败收场`（行内追加，原 22.4 内容一字未改）

## 自验输出（原文）
```
== grep -c 35.[1-6] ==
7
== grep -n Rule 35.3 锚点 ==
127:22.4 **派发 prompt 必须自包含且短**...(全文) …挂 dispatch_contract_enforce 档位）；超限补救=Rule 35.3 大输入落盘引用（内容写文件+prompt 只放路径与 Read 指令），禁止失败收场
== wc -l ==
299
== git diff --stat ==
 skills/task-planner/references/critical-rules.md | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)
```
- 结构确认: `### 35` = L292；35.1=L294 … 35.6=L299（grep -n '^35\.[1-6] \|^### 35 ' 全中）
- Rule 35 块共 8 行（标题+空行+35.1..35.6），10 行 insertions = 8 行新内容 + 2 行（L127 被替换为加长行 +1，末尾空行处理）
- 偏差说明: 任务预期 wc -l ≈309-312，实际 299（任务原文「一字不改」文本逐字写入，未增删任何字符；预期区间可能基于带额外空行的排版假设，以逐字条款为准）
- grep -c '35\.[1-6]' = 7 ≥ 6 ✓

## 结论
- 两处改动完成且自验全过；除 critical-rules.md 外无任何文件改动（git diff --stat 单文件）
- progress.md P2 段已追加 S3 动作行（主仓 plans/，簿记）
- 后续 S4/S5/S6 不受本步阻塞；S6 CD 断言可直接 grep '### 35 ' / '35\.[1-6]' / L127 'Rule 35.3' 锚
