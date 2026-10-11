# Epoch Cascade Unit 2 — task-v169 Phase 4（lane-advancement + self-resolution）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
把两个脚本的 `'Critical Rules 1-7[4-9]'` 字面锚扩展为 `'Critical Rules 1-[7-8][0-9]'`（覆盖 1-80 纪元），命令字面、ok/bad 消息字面、注释同形锚三处同步：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-lane-advancement.sh — 断言行 :140 的 grep 命令与 :142 的 ok/bad 消息；注释 :139 同步
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-self-resolution.sh — 断言行 :84 的 grep 命令与 :86 的 ok/bad 消息；注释 :83 同步
- 阈值语义不变（均 ≥1）；负断言 `1-39`=0 判定逻辑禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- 改后每脚本 `grep -c '1-7\[4-9\]'` = 0（旧形态零残留）且 `grep -c '1-\[7-8\]\[0-9\]'` ≥1

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/08-code-assistant-epoch2.md（纪律见协议）

## 5. 粒度与预算
2f/8l/15min；超时 15 分钟立即返回 partial
