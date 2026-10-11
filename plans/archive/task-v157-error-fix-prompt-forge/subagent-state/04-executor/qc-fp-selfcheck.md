# QC-FP 自检表 — fix-prompt-sample.md

> 被检产物: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/fix-prompt-sample.md
> 自检时间: 2026-10-10

| # | 判据 | 结果 | 证据 |
|---|------|------|------|
| QC-FP-1 | 自包含: 无代词悬指/裸文件名,全部绝对路径 | PASS | 机检: `grep -n '/mnt/data/dev/task-planner-skill' fix-prompt-sample.md` → 7 行绝对路径（行 4/5/9/15/18/21/27/37），关键锚全部绝对路径 |
| QC-FP-2 | 根因 + 证据锚在位且可复现 | PASS | 机检: Read /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md:3-5 → 事故描述原文存在（"2026-10-09 task-v153 编写 findings.md 时，在 Visual/Browser Findings 模板空段填入一段本会话无任何来源的内容"） |
| QC-FP-3 | ≥1 机器可检查验收判据(命令可跑) | PASS | 机检: 第 6 槽位验收判据=`grep -c "无源含事实" /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/audit-report.md`，期望输出=0；命令为有效 grep，指向绝对路径 |
| QC-FP-4 | 单 S-unit 范围,修复目标唯一 | PASS | 对照: 任务一句话="对 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md 跑提示词 A 溯源审计（无来源虚构内容专项），产出审计表+总计行" — 单一目标，无混塞 |
| QC-FP-5 | 无占位符/花括号缩写/「应该没问题」类措辞 | PASS | 机检: `grep -n '{' fix-prompt-sample.md` → NO_BRACE_PLACEHOLDER；`grep -n '应该没问题\|应该是\|大概\|或许\|可能有问题' fix-prompt-sample.md` → NO_VAGUE_PHRASE |
| QC-FP-6 | 未验证内容已隔离且显式标注 | PASS | 第 9 槽位「未验证假设区」小节存在，内容标注「（空）」— 无未验证内容需隔离 |

## 三态结论

**READY** — QC-FP 全 PASS，可直接派发。
