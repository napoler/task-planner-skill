# 01-explore 基线独立复验（S1）checkpoint

复验时间：2026-10-10 | 执行者：sub:01-explore | worktree HEAD=5280cb3

## 复验 1：级联面
- 命令1：grep -rn "1-69" skills/ | cut -d: -f1 | sort | uniq -c | sort -rn
- 输出：6 文件 16 处（selftest-requirement-coverage.sh×4、selftest-tool-selection.sh×3、selftest-self-resolution.sh×3、selftest-lane-advancement.sh×3、selftest-research-first.sh×2、SKILL.md×1）
- 与 findings §3 快照「16 处/6 文件」一致。
- 命令2：grep -rn "1-69" *.md | grep -v CHANGELOG | cut -d: -f1-2
- 输出：无（0 命中）
- 快照称仓根 3 处（CLAUDE.md:33、README_zh.md:136,229），实测该 3 处文本仍为 "Rules 1-68" 形态（sed -n 33p CLAUDE.md / 136p;229p README_zh.md 实证），grep "1-69" 不命中。
- 差异：skills/ 内 PASS；仓根快照「3 处 1-69」vs 实测「0 处 1-69」（3 处仍为 1-68，v154 未演进）。

## 复验 2：Rule 71 编号
- 命令：bash skills/task-planner/scripts/rule-reserve.sh check 71
- 输出：free
- 主仓 plans/.rule-reservations.jsonl 含 {"rule":71,"status":"reserved","task_id":"task-v158-source-anchor-discipline","ts":"2026-10-10",...}
- worktree 内 plans/.rule-reservations.jsonl 无 71 行（findings §84 已记录此差异及处置方案）。
- 差异：worktree 内 check 输出 "free"（不含 task-v158）；主仓台账 71=reserved by task-v158（已持有）。

## 复验 3：C48 可用性
- 命令：grep -nE "\| C47 | C48 " skills/task-planner/SKILL.md
- 输出：仅 :224 C47 行（含 Rule 69 描述），C48 零命中（exit 1）。
- 结论：PASS——C47 已被 Rule 69 占用，C48 空闲。

## 复验 4：dispatch 模板插入位
- 命令：grep -nE "^## (9|10)." skills/task-planner/templates/subagent_dispatch.md
- 输出：仅 85:## 9. 上下文预算(强制 — Rule 22.4 第 ⑨ 字段,小模型短上下文友好)
- §10 不存在（grep 无匹配）。
- 结论：PASS——现有段落止于 §9（:85），§10 可插入。

## 汇总
1: PASS（skills/ 内一致；仓根有差异）
2: PASS（主仓台账已持有；worktree 内显示 free 因台账未同步）
3: PASS
4: PASS
