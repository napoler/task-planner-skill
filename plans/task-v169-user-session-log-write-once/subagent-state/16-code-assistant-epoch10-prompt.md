# Epoch Cascade Unit 10 — task-v169 Phase 4（reflect-verify + skill-split 的 Rules 1-3x..7x 锚）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-reflect-verify.sh — RV-10（:62 grep 与 ok/bad 消息）：ERE 末段字符类 `[4-7][0-9]` 扩展为 `[4-8][0-9]`（判定形态 Rules 1-(3[5-9]|[4-8][0-9])）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-skill-split.sh — T-锚（:82 bash -c 内 grep 与 t 描述串）：同形态 `[4-7][0-9]` → `[4-8][0-9]`（判定形态 Rules 1-(3[0-9]|[4-8][0-9])）
- 两个脚本各追加一行 task-v169 演进注释；其余断言一律禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- 改后每脚本 `grep -c '\[4-7\]\[0-9\]'` = 0（旧形态零残留）

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/16-code-assistant-epoch10.md（纪律见协议）

## 5. 粒度与预算
2f/6l/15min；超时 15 分钟立即返回 partial
