# Task Learnings: task-v082-minimal-probe

## New Requests
- 2026-09-18 用户指令：优化 task-planner skill，补充「最小测试原则」——测试 bash 是否可用只需执行一个最简单输出测试，类似的完全没必要搞复杂化。→ 已落地为 Rule 35.6 最小探针原则（范围=Rule 35 族+SKILL 两处+CD selftest+CHANGELOG，无扩围）。

## What Worked
- 预登记降级路由（Decisions ④：haiku-1/sonnet 系不可启动即 22.3④ 接管；P4 CR：Explore 不可用即主进程对照 diff 复审）两次兑现零空转，材料包照抄策略使接管近乎零成本
- FMEA 7 列表头一次写对（吸取 v080 教训），attest fmea-gate 一次通过
- 最小探针原则自我应用：全程验证均为单条 grep/diff/wc 探针，无过度搭建

## What Didn't Work
- **[环境性] 子代理派发全线不可用延续**：code-assistant(haiku-1) reasoning-level-missing、Explore(mini)×2 provider server error——与 v081 同日同因。类别=数据源过时/环境性；非技能本体缺陷。对策=预登记路由（本任务已实践）；后续轮若平台恢复应重探针验证档位可用性再改回主路由
- **[规则缺位-轻微] CD selftest 头注记-标签 off-by-one（v077 遗留）**：注记 CD-01..23 实际标签到 CD-24，新断言被迫跳号 CD-25。登记 findings 供后续清理轮，未越界修
- **[执行偏差-自纠] 内联 shell 解析伪影**：求和脚本把 Total 行第二个数字当 FAIL 数导致全脚本"FAILING"假象——立即用显式 `FAIL=` 值+rc 双查口径重跑定论。教训：统计口径先自证（v081 '='分列教训的同族变体）

## Notes for Next Time
- 并行会话推进 master 已成常态（v081/v083 同夜）：push 前必重验 HEAD+祖先关系，合并后全量在最终 HEAD 重跑（不采信中间 HEAD 结果）
- plans/ 簿记入库是本仓实然约定（v080/v081/v082 先例），scope_files 应含 plans/ 任务目录以让 Rule 27.3 预检覆盖簿记提交
- CD selftest 新增断言前先 grep 既有标签最大号（当前 CD-25），防撞号

## 🚫 被否决方案（User Rejected — Rule 32）
- （本任务无用户否决登记）
