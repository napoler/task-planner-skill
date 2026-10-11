# Epoch Cascade Unit 7 — task-v169 Phase 4（reliability-institution + execution-honesty）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-reliability-institution.sh — R-09（:86 grep 与 :88 ok/bad 消息）：`含 Rule 40-[4567][0-9](\+[0-9]+)? 全集` 中的字符类扩展为 `40-[4-8][0-9]`（正则其余部分含转义加号族不变）；负断言 `grep -c '1-40'` = 0 的逻辑禁动；:85 注释追加 task-v169 演进记录
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-execution-honesty.sh — EH-09（:98 grep 与 :100/:102 ok/bad 消息）：ERE 并列集合 `(5[3-9]|6[0-9]|7[0-6])` 末尾追加成员 80
- 两个脚本的其余断言一律禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- reliability-institution 的 R-09 必须 ok 且 `1-40` 负断言仍为 0；execution-honesty 的 EH-09 变 ok

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/13-code-assistant-epoch7.md（纪律见协议）

## 5. 粒度与预算
2f/8l/15min；超时 15 分钟立即返回 partial
