# Epoch Cascade Unit 8 — task-v169 Phase 4（drift-check-subagent 的 DCS-11）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
单文件 /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-drift-check-subagent.sh：
- DCS-11（:64 grep 判定）：ERE 并列集合 `(69|71|73|7[4-9])` 末尾追加成员 80，正则其余部分（含转义加号族与「全集」字面）不变
- 若该行附近有 ok/bad 消息或注释含同形锚（形如 40-(69|71|73|7[4-9])），同步扩展
- 其余断言（DCS-19 行数 ≤581、DCS-20 精确串清零等）一律禁动

## 2. 输入（只读对象，绝对路径）
上述单文件（先 Read 核对 :60-70 区间实际内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 本脚本独立跑 PASS（贴 Total 行原文）；DCS-11 变 ok
- 改后本文件 grep -c 新形态锚（含 80 成员）≥1

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/14-code-assistant-epoch8.md（纪律见协议）

## 5. 粒度与预算
1f/6l/15min；超时 15 分钟立即返回 partial
