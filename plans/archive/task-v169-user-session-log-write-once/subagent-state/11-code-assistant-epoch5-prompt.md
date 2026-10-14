# Epoch Cascade Unit 5 — task-v169 Phase 4（context-pressure + root-resolution）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-context-pressure.sh — CP-07 两行（:102 c1 与 :103 c2）：ERE 并列集合 `(69|71|7[4-9])` 末尾追加成员 80（c1/c2 两个 grep 命令同步改）；:110/:112 的 ok/bad 消息同形锚同步；:101 注释追加 task-v169 演进记录；阈值 c1≥2 ∧ c2≥1 ∧ C48/C49/C50 各 ≥1 不变
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-root-resolution.sh — RR-16（:182-183 if 判定与 :183/:187 ok/bad 消息）：ERE 并列集合 `(5[3-9]|6[0-9]|7[0-6])` 末尾追加成员 80；其余断言（含 RR-09 宽容主断言与负断言 1-51/53/55）一律禁动
- 注意：RR-16 的兜底分支允许「同时含 50 与 53」替代，改锚时不得破坏该兜底逻辑

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- 改后 context-pressure 的 c1/c2 实测值贴入 evidence；root-resolution 的 RR-16 变 ok

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/11-code-assistant-epoch5.md（纪律见协议）

## 5. 粒度与预算
2f/12l/15min；超时 15 分钟立即返回 partial
