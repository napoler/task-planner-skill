# Epoch Cascade Unit 4 — task-v169 Phase 4（summary-readability + research-first）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-summary-readability.sh — SRV-03（:72 cntE 调用）：`'1-7[4-9]'` → `'1-[7-8][0-9]'`；:74/:76 的 ok/bad 消息与 :71 注释同形锚同步；阈值 ≥3 不变
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-research-first.sh — 两处：RF-06（:75 cnt 调用）`'1-7[0-9]'` → `'1-[7-8][0-9]'`（阈值 ≥3 不变）；RF-07（:77 pair 调用的第二个 cntE 参数）ERE 交替集 `40-(65|69|71|7[4-9]) 全集` 的并列集合末尾追加成员 80（改后形如 40-(65|69|71|7[4-9]|80) 全集）；:75/:77 行尾的演进注释各追加一行 task-v169 记录（对齐该文件既有演进注释风格）
- SRV-04/SRV-05/SRV-06 等其余断言一律禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- 改后 research-first 内 `grep -c '1-7\[4-9\]'` = 0 且 RF-07 新锚命令能在 SKILL.md 上命中（贴该 grep 的实测计数）；summary-readability 内 `grep -c '1-\[7-8\]\[0-9\]'` ≥1

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/10-code-assistant-epoch4.md（纪律见协议）

## 5. 粒度与预算
2f/12l/15min；超时 15 分钟立即返回 partial
