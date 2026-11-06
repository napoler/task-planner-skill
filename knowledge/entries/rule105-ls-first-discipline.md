---
id: rule105-ls-first-discipline
title: "Rule 105 可枚举集合全量枚举优先纪律（ls-first）落地与级联维护要点"
tags: [rule-105, ls-first, 检索纪律, selftest, 级联锚]
sources: [plans/task-enumerate-first-20261106/knowledge-brief.md, plans/task-enumerate-first-20261106/findings.md, skills/task-discipline/references/critical-rules-discipline.md]
updated: 2026-11-07
---

# Rule 105 ls-first 纪律落地与级联维护要点（2026-11-07, task-enumerate-first-20261106）

## 条款本体与锚点
- Rule 105「可枚举集合全量枚举优先纪律」五子条落位：skills/task-discipline/references/critical-rules-discipline.md:707-721（105.1 枚举优先/105.2 零命中回退/105.3 缺陷信号/105.4 适用边界/105.5 反例锚）
- 机器守护：skills/task-planner/scripts/selftest-enumerate-first.sh（EN-01..07，:44 SEC105 awk 段内提取防空壳）；registry 登记 selftest-registry.tsv:98
- 编号闭环：plans/.rule-reservations.jsonl（landed by 本任务，commit e8ab2e8）

## Rule 编号演进级联面（后续新增 Rule 必读）
| 联动面 | 位置 | 动作 |
|--------|------|------|
| 全集索引计数行 | skills/task-planner/SKILL.md:9/:222/:265 | 1-10N 同址改写+「其余 NN 条」随动 |
| 卫星路由/指针 | SKILL.md:209/:255（+frontmatter :17 视域归属） | 枚举追加新号 |
| 卫星域计数 | skills/task-discipline/SKILL.md:15/:86/:97 | 「N 条」计数×3+索引表 +1 行（:84 相邻） |
| 行数钉 | selftest-batch-pilot.sh:66（BP-08 ≤285） | SKILL.md 净增行 >4 须升钉；优先同址改写零净增 |
| selftest 宽窗 | 29 个 selftest 的 1-(8[0-9]|9[0-9]|10[0-9]|11[0-9]) 预放宽 | 编号在窗内零改动 |

## 易错点
1. SKILL.md 计数行禁净增行（BP-08 margin 4）——全部同址改写
2. run-selftests 全量 FAIL 先主仓单跑对照分类（flaky 实证：selftest-active-plan T11/selftest-execution-stability T11b 沙箱态 FAIL 单跑可过），再判归因
3. verification.md 的 Verify command 必须纯命令（混中文说明=runner exit 127 全 FAIL）；阈值判据用 test 表达式
4. selftest 断言须段内锚定（SEC105 模式），全文 grep 断言可被删段空壳骗过（critic I-2 判例）
5. Executor 字段/Handoff 表用裸类型名（带括注=委派守卫 unverified 误报，v150 判例三犯）
