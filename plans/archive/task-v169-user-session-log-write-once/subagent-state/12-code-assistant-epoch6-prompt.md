# Epoch Cascade Unit 6 — task-v169 Phase 4（capability-persistence + iteration-persistence）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-capability-persistence.sh — CP-05（:82 grep 与 :83 ok/bad 消息）：`40-[567][0-9]` → `40-[5-8][0-9]`；语义=断言 SKILL.md 的全集括注（Rule 40-80 全集），阈值 =1 不变；注释同形锚同步
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-iteration-persistence.sh — IP-12（:151 grep 与 :152 ok/bad 消息）：`Rule 40-[567][0-9]` → `Rule 40-[5-8][0-9]`；阈值 ≥1 不变
- 两个脚本的其余断言一律禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- capability-persistence 的 CP-05 必须 ok 且其实测计数=1（SKILL.md 只有 Line 313 一处 40-80 全集）；若实测 ≠1 在 evidence 贴 grep 命中行原文并如实报告（禁为凑数改 SKILL.md）

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/12-code-assistant-epoch6.md（纪律见协议）

## 5. 粒度与预算
2f/8l/15min；超时 15 分钟立即返回 partial
