# 01 Explore 考古任务书（task-v078 守卫误报修复，2026-09-17）

你在只读考古 /mnt/data/dev/task-planner-skill 仓（只读，不改任何文件）。任务：为修复 2 个守卫误报问题收集精确锚点。

三文件路径（每行一个）：
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/task_plan.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/findings.md
/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/progress.md
检查点：/mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md

## 背景——两个待修复问题
① 提醒链对已交付（complete）计划无豁免：hook 提醒形如 `[plan-compass] 🧭 findings.md 已 N 分钟未更新（阈值 20）: <plans/task-v076...>/findings.md`、`[plan-sync] ⏰ 计划文档已 N 分钟未更新`、以及升级警告（连续 2 次未回填）——v076 计划已 COMPLETE 交付多日仍反复被告警。
② check-dispatch 打包检测误计：prompt 中契约条文里的示例 ID（形如「数字加在 S 后」的命名举例、或「既有 XX/XX 基础上」的交叉引用）被 `单 prompt 检出 N 个 S-unit ID` 计为多 S-unit 打包而阻断（Rule 22.4 KQ3）。考古派发本身已被阻断一次，即问题②的实证。

## 收集项
A. 提醒链脚本定位：`grep -rn "plan-compass" skills/task-planner/scripts/` 找出生成该提醒的脚本与行号；同查 plan-sync 与「升级警告」。给出：脚本名、提醒触发条件代码段行号（mtime 阈值比较逻辑）、该脚本如何解析活跃计划（resolve-plan-dir?）、当前是否读取计划完成状态（在该脚本内 grep Status/complete/outcome）、豁免插入点建议行。
B. 提醒链开关与阈值配置：config.json 中 compass/sync 相关键名与默认值行号。
C. 提醒链既有 selftest 覆盖：`grep -rln "compass" skills/task-planner/scripts/selftest-*.sh`；相关用例行号与断言方式（若无可说明无覆盖）。
D. check-dispatch.sh 打包检测：L255-275 上下文，检测正则原文行号（S 加数字的去重计数逻辑）、命中后 warn/block 分支、fine_grain_checks 档位读取处。
E. selftest-dispatch.sh 打包用例：FG 系列中覆盖多 S-unit 检测的用例行号与断言原文；FG-01..04 各自主题一行。
F. 豁免设计取证：`grep -n "subagent-state/" skills/task-planner/scripts/check-dispatch.sh`——现有对检查点路径的校验逻辑（22.8.1），判断「prompt 引用 subagent-state/ 下任务书」能否作为低成本豁免锚（现有代码是否已解析出该路径）。
G. variant 模板头部注释行号清单（skills/task-planner/templates/variant/rule-enhancement-type.md 前 6 行原文），供主进程核对一处来源不明改动。

输出：按 A-G 紧凑清单（file:line+≤25 字引用），总量 ≤120 行。结论同时写入检查点文件。

## 8 字段严格返回模板
status: done|failed
files_changed: 空（只读）
acceptance: A-G 各项齐全（逐项原文行）
evidence: 检查点路径
issues: none|列表
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md
findings_written: none
blockers: none|一句话
