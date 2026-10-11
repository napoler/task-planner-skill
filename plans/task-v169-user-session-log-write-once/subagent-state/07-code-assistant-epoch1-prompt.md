# Epoch Cascade Unit 1 — task-v169 Phase 4（tool-selection + requirement-coverage）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文（背景/映射表/改法纪律/通用验收四条/禁改面/检查点纪律）。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
把两个脚本的 `'Critical Rules 1-7[4-9]'` 字面锚由旧纪元扩展为 `'Critical Rules 1-[7-8][0-9]'`（覆盖 1-80 纪元），命令字面、ok/bad 消息字面、注释里的同形锚三处同步：
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-tool-selection.sh — 断言行 :67 的 grep 命令与 :69 的 bad 消息；注释 :66 的锚说明同步
- /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-requirement-coverage.sh — 断言行 :139 的 grep 命令与 :141/:143 的 ok/bad 消息；注释 :135 的锚说明同步
- 阈值语义不变（两个脚本均为 ≥1）；负断言 `1-39`=0 的判定逻辑禁动

## 2. 输入（只读对象，绝对路径）
以上两个脚本（先 Read 核对实际行内容再改，禁凭任务书行号盲改——行号若与实态偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 两脚本各自独立跑 PASS，返回 evidence 贴两个 Total 行原文
- 改后 `grep -c '1-7\[4-9\]' <每个脚本>` = 0（旧形态零残留）；`grep -c '1-\[7-8\]\[0-9\]' <每个脚本>` ≥1

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/07-code-assistant-epoch1.md（纪律见协议）

## 5. 粒度与预算
2f/8l/15min；超时 15 分钟立即返回 partial
