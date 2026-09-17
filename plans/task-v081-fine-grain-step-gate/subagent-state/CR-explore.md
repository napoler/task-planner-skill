# CR 检查点 — task-v081 步骤枚举门控 diff 复审

- 审查方式: 主进程逐文件精读全量 diff（34c3959..HEAD,4 commits,8 文件 +252/-10）——Explore(mini) 独立复核两次派发均遇 provider server error,按 task-v064 先例+计划 P5 预登记改主进程复审
- 裁定: **APPROVED**（1 处 P3 发现已修复并提交）

## 发现与处置
| # | 位置 | 发现 | 严重度 | 处置 |
|---|------|------|--------|------|
| 1 | check-dispatch.sh fine_grain_checks 头注释 | "三项均对既有…"未随④同步为四项 | P3 | 已修（commit"CR 修正"，dispatch 23/0+SG 11/0 复跑绿） |
| 2 | check-dispatch.sh ④ `for tb in $tb` | 无引号分词为故意（多路径迭代）;含空格路径会错切——任务书路径均为计划目录派生绝对路径,实际无空格 | P3 注记 | 接受,口径注释已写明 ≤3 个存在可读 |
| 3 | count_step_markers `step ?N` 可匹配词中（如 "2-step 3"） | 过匹配方向=多计,枚举口径文档已声明边界（fail-open 主方向为漏计） | P3 注记 | 接受 |
| 4 | SKIPPED 文案"jq 缺失或键缺"与实际（仅 jq 不可用触发）不符 | 与 ①②③ 家族文案逐字一致,单方修正破坏一致性 | P3 注记 | 接受（家族一致优先,已在④注释补充双分支口径说明） |
| 5 | 纯增量核查 | 5 处 deletions 均为行内扩展原行,旧内容完整保留;config 既有键零变动 | — | PASS |
| 6 | selftest 密闭性 | sid 唯一($$+$RANDOM)/锁每例清除/mktemp+trap 自清理/三连跑 11/0 | — | PASS |
