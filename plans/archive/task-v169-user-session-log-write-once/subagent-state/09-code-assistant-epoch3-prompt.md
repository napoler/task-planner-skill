# Epoch Cascade Unit 3 — task-v169 Phase 4（absorption-discipline 的 AD-04 锚 + AD-12 pin）

> 共用协议: Read /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/00-cascade-protocol.md 全文。
> 本文件只定义本单元专属面；需求锚=不适用（纯机械单元，Rule 51.1a 豁免口径）。

## 1. 目标（本单元专属）
单文件 /mnt/data/dev/task-planner-skill-worktrees/task-v169-user-session-log-write-once/skills/task-planner/scripts/selftest-absorption-discipline.sh 两处联动改：
- AD-04（:32 断言行）：`grep -cE '1-7[4-9]'` → `grep -cE '1-[7-8][0-9]'`（阈值 ≥3 不变）
- AD-12（:66-70 五行 pin）：四行 pin 的是其他脚本的 live 字面 `'Critical Rules 1-7[4-9]'`（分别 pin selftest-tool-selection.sh / selftest-requirement-coverage.sh / selftest-lane-advancement.sh / selftest-self-resolution.sh）——这四个脚本正在被本批其他单元改为 `'Critical Rules 1-[7-8][0-9]'`，故这四行 pin 字面同步改为 `'Critical Rules 1-[7-8][0-9]'`；第五行 pin 的是 selftest-source-anchor-discipline.sh 的 `"grep -cE '1-7[4-9]'"`（该脚本本批不改，pin 保持原样）
- AD-04 的 chk 消息与 :57/:60-63 注释里的 `1-7[4-9]` 同形锚同步；AD-08/AD-09/AD-10/AD-11 等其余断言一律禁动

## 2. 输入（只读对象，绝对路径）
上述单文件（先 Read 核对 :26-80 区间实际内容再改，行号偏差以实态为准）

## 3. 验收（通用四条之外的本单元专属）
- 本脚本独立跑 PASS（贴 Total 行原文）；AD-12 必须 ok（pin 与 live 锚一致）
- 改后本文件 `grep -c '1-7\[4-9\]'` = 1（仅剩 source-anchor 那行 pin，符合预期）且 `grep -c '1-\[7-8\]\[0-9\]'` ≥1
- 若被 pin 的四个脚本尚未被其他单元改完导致 AD-12 FAIL：在 evidence 中如实报告哪几个脚本的 live 锚仍为旧形态，把本脚本 pin 改为新锚后先只保证 AD-04 PASS，AD-12 状态在返回 acceptance 中如实标 partial 并说明（禁为了让 AD-12 过而反向把其他脚本改旧）

## 4. 检查点
/mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once/subagent-state/09-code-assistant-epoch3.md（纪律见协议）

## 5. 粒度与预算
1f/12l/15min；超时 15 分钟立即返回 partial
