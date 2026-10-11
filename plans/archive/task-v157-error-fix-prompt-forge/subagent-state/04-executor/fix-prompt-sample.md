# fix-prompt · 修正任务书

## 1. 任务与范围
- 一句话: 对 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md 跑提示词 A 溯源审计（无来源虚构内容专项），产出审计表+总计行。
- 范围(files): /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md（只读）；/mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/audit-report.md（写入审计报告）。

## 2. 背景与根因
- 根因结论: 写入前无自检关口，导致模板空段被填入无来源虚构内容。
- 证据锚: /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md:3-5（事故描述：2026-10-09 task-v153 编写 findings.md 时，在 Visual/Browser Findings 模板空段填入一段本会话无任何来源的内容）。

## 3. 复现
- 命令/步骤: 不可复现。原因：事故内容已被主进程当次自查删除，无法重放。审计路径=直接对当前 findings.md 跑提示词 A 口径。

## 4. 约束与禁改区
- 禁改区: 只读 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md；只写审计报告到 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/audit-report.md；禁止修改 findings.md 本身。

## 5. 执行步骤
1. 读取 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md 全文。
2. 把文件切成事实单元（每条含具体事实的句子或表格单元格=1 个单元）。
3. 逐单元三态判定：有源（附 file:line / URL / 命令输出原文 / 本会话工具调用记录四者之一）/ 无源含事实（无上述来源却含具体事实）/ 显式占位（合法形态）。
4. 输出审计表（单元位置 | 事实摘要 | 三态判定 | 源锚或「无」 | 处置建议）+ 总计行（违规数/合规数）到 /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/audit-report.md。

## 6. 验收判据
- 审计报告存在且含三态判定列+总计行；总计行违规数=0（当前 findings.md 无无源虚构内容）。

## 7. 验证命令
- 命令: grep -c "无源含事实" /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/04-executor/audit-report.md
- 期望输出: 0

## 8. 回滚
- 恢复方式: 审计报告为新增文件，无需回滚；findings.md 只读未改，无需恢复。

## 9. 未验证假设区
- （空）

## 参考材料
- /mnt/data/dev/task-planner-skill/plans/task-v153-parallel-scheduling/fix-prompts.md（提示词 A 口径定义）

**定义完成(DoD)**: 1-8 全部填写 + 7 验证命令实际跑通 = 完成；9 有内容则三态结论 PARTIAL，否则 READY。
