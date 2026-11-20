# S4 派发指令：selftest-pointer-lifecycle.sh 扩展 PL-11+ 行为断言（四类场景）

## 执行区（只改 worktree 内单文件）
- /mnt/data/dev/task-planner-skill/tmp/worktrees/task-pointer-switch-defect-20261120/skills/task-planner/scripts/selftest-pointer-lifecycle.sh
- 禁碰其他文件；禁新建脚本

## 背景（自包含）
P1/P2 已修复：init-session.sh（同 sid 在途 claimant 身份确定时通告+直写 `_sid_fallback` 门控；in_progress 锚定正则）、set-active-plan.sh（锚定正则+「指针未切换」前缀+claimant mtime 选取）、SKILL.md（D/E 释占用口径）。本单元把四类修复场景固化为回归断言。

## 修改要求（先 Read selftest 全文摸清 ok/bad 计数与 /tmp 夹具范式）
在既有 PL-01..PL-10 之后新增**行为断言 PL-11..PL-14**（沿用 ok/bad 函数与 /tmp 夹具隔离范式；头部注释 `PL-01..10` 措辞同步为 `PL-01..14`；Total 语义自动由计数承载）：
- **PL-11 init 一次切换**：夹具=old-claimant（`- **Status:** in_progress`+owner=sess<sid>）+new-task 目录，export CLAUDE_CODE_SESSION_ID 后 cd new-task 跑 init-session.sh（脚本路径=$SELF 同目录）→ 断言 side 键内容=new-task 且 stdout/stderr 含「明确切换意图」与 claimant 名、无「skip 写入」
- **PL-12 非加粗不漏判**：claimant=`- Status: in_progress`（非加粗）+owner，set target → 输出含「指针未切换」且 side≠target
- **PL-13 注释/散文不误拦**：claimant 仅注释行+散文行+`- **Status:** complete` → set target → side=target（fail-open 写入成功）
- **PL-14 fallback 门控保留**：伪造 freshness fallback 场景成本高，可降级为**静态断言**：init-session.sh 含 `_sid_fallback=1` 标记设置与「未确定」WARN 文案锚（grep 命中即可，注明静态断言原因）
- 每条断言失败消息含场景名；夹具用 `mktemp -d`+trap 清理；不同断言 sid 用不同随机前缀防互扰；set 夹具的目标计划需含 task_plan.md（slug 校验要求）
- 注释 What+Why（2026-11-20 task-pointer-switch-defect-20261120，四类场景对应 G1/G3/G4）

## 自验
- bash selftest-pointer-lifecycle.sh → FAIL=0 且输出含 `PASS PL-11`..`PASS PL-14` 各≥1 条、`PASS PL-01`..`PASS PL-10` 全在（共 14 PASS）
- bash -n 过

## acceptance
- selftest FAIL=0 + PL-11..14 各≥1 PASS + PL-01..10 无回退；git diff 仅本文件
