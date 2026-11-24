# Checkpoint — S12 general-analyst（OpenSpec 产物时间线侧证，P4）

status: done
task_id: task-sp-os-invocation-audit-20261124
s_unit: S12
executor: general-analyst(sonnet-1)
parallel_group: g-ro

## 八字段返回
- status: done
- acceptance: 逐条对照——①OS-ARTIFACT 行 24 条(≥1) ✓；②每行含 project/path/date/status ✓；③含遗留 worktree openspec 目录来源(开头「一、」段 + 来源链) ✓；④窗口判断基于 mtime + 内容 created 字段交叉，IN=9 条全在遗留 worktree、OUT=15 条 ✓；⑤「存在≠调用」专节三条明确区分并指向 S7/S8/S9 ✓。
- files: T/report-openspec-artifacts.txt (+1/-0)；T/writes.txt (+1 行=报告绝对路径，line14)；本 checkpoint (+1)。未改任何被分析对象。
- evidence: 14 个 openspec 根清点；窗口内产物仅 9 文件、全部位于 /mnt/data/dev/task-planner-skill/tmp/worktrees/task-todo-default-engine-20261123/openspec（mtime 11-23 04:34-04:46，.openspec.yaml created=11-22）；状态分布 legacy1/active4/archived7/none2；本仓根无 openspec/ 且 git log --all -- openspec 计 0；遗留 worktree openspec/ 为未跟踪(git status ?? openspec/)。
- checkpoint: 本文件（status: done）
- findings_written: /mnt/data/dev/task-planner-skill/tmp/sp-os-audit-20261124/report-openspec-artifacts.txt
- blockers: none（find 全盘首轮 120s 超时一次→改 targeted + pruned maxdepth 5 完成，非阻塞）
- confidence: HIGH（全部结论基于本机 find/stat/git 一手只读命令；内容日期已 Read proposal.md/.openspec.yaml/tasks.md 交叉）

## 关键结论摘要（供 P5 根因 S13/S14 引用）
1. 窗口 11-18..11-24 内**没有任何真实活跃项目**产生或归档 openspec 变更产物；唯一 in-window 产物是"遗留 worktree 内以 OpenSpec 规格化自身"的 todo-default-engine change（8 产物 + 根配置，11-22/11-23）。
2. 本仓根 openspec/ 不存在且 git 历史从未跟踪；该遗留 worktree 的 openspec/ 是未跟踪文件（?? openspec/），worktree 未清理——产物形态直接呼应 H4「OpenSpec 落点缺失」。产物正文自述"OpenSpec 连 root 都未初始化、Superpowers 仅为软路由文本"，是设计层的自指证据，非调用证据。
3. historical 项目（article-generation 157 归档 / .claude 21 归档 / decentralized-base 14 归档等）证明这些项目曾用 OpenSpec，但全部在窗口外（最晚 10-28），不能外推窗口内主动调用。
4. C2 合规：报告只陈述产物的位置/时间/状态与"落点缺失"形态，未写"执行方跳过/模型未遵守"；存在≠调用的区分已显式声明，未越界下调用量化结论。

## 复跑命令
grep -c '^OS-ARTIFACT' T/report-openspec-artifacts.txt  # 24
find <root> -type f -newermt '2026-11-18 00:00:00' ! -newermt '2026-11-25 00:00:00' -printf '%TY-%Tm-%Td %TH:%TM %p\n' | sort
git -C /mnt/data/dev/task-planner-skill log --all --format='%H' -- openspec | wc -l  # 0
git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-todo-default-engine-20261123 status --short  # ?? openspec/
