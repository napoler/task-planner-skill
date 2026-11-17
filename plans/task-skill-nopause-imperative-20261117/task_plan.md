---
plan_tier: mini
---
# task-skill-nopause-imperative-20261117

## Goal
task-discipline Rule 95 增补 95.7「祈使-征询区分与已下指令禁再上抛」，根治 sess_2842c8c1 收尾把已授权祈使（"有错误就修正/提交全部"）读成征询「是否要我修/要不要提交」的缺陷（用户判例「你为什么又暂停了 而不解决skill的缺陷」）。

## Scope（1 文件，纯文本增量，零脚本零新键）
- `skills/task-discipline/references/critical-rules-discipline.md`（插入 95.7 单条，既有 95.0-95.6 原文零改动）

## VC-1（机器可验）
- `grep -c '95.7 祈使-征询区分' skills/task-discipline/references/critical-rules-discipline.md` = 1
- `grep -c '95.6 复盘锚' skills/task-discipline/references/critical-rules-discipline.md` = 1（既有锚保留）
- 该文件 selftest 无 Rule 95 子条计数断言（已 grep 确认 scripts/ 命中 0）→ 零回归

## 验证
- 上列 VC-1 grep 全命中；`git status` 仅本文件 + 部署位（不动他人未提交文件）
