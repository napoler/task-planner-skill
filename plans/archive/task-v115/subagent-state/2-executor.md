# Checkpoint — sub:2-executor（task-v115 Phase 2 线A 回流+级联）
status: in_progress
agent: executor
started: 2026-10-02
scope: worktree /mnt/data/dev/task-planner-skill-worktrees/task-v115 (wt/task-v115) 内 12 variant 收编+3 分叉文件合并+29 全链级联

## 里程碑 1: 收编完成
- 12 variant 已从 /home/terry/.zcode/skills/task-planner/templates/variant/ cp 入 WT（cmp 12/12 identical）
- WT variant 计数: 17 → 29（ls 实测 29）
- 头部复验: 12/12 `template_type:` 在 :2, `plan_tier: standard` 在 :7; 全 29 文件 grep template_type 齐备
- 存量 2 文件（rule-enhancement/video-fix）plan_tier 缺失属主仓既有形态，不在本轮修正面（偏差: 见最终结论披露）

## 里程碑 2: 合并完成
- guide: :32 标题 29+收编注 / :53-64 表插 12 行（主仓 memory-hygiene 行保留）/ 总文件数句 37 模板+实际 39 .md / :66 §2.4 标题 35/39 / :70 应为 35 / :71 含锚 28 / §2.5 现为 35
- mapping: §一 决策树 +12 行 / Rule 34 句合成 29 口径 / §一 清单 +12 行 / §六 速查表 +12 行（主仓 4 行全保留）/ 互斥表 +4 行 / §九 矩阵 +12 行（18→30 数据行）/ 不适用 3 行→15 行+2 条括注 / §十 内容组扩列（保留主仓 21.4 新句）
- plan-writer: 映射表 +12 行（30 行=29 variant+general）; 两版本体 IDENTICAL 无冲突
- plan-template-kit/SKILL.md:19 「16 类」→「29 类」(task-v115 回流标注)（扩展锚 1/5）

## 最终结论（主进程代补 2026-10-02：代理返回截断但工作经机械验证全部完成）
- 级联自洽实证：variant=29、selftest-template-lifecycle 21/21、skill-split 41/41、残留旧计数 grep=0
- 12/12 收编合规+guide/mapping/plan-writer 合并完成（plan-writer 两版 IDENTICAL 无需改）
- status: done（机械验证替代自报）
