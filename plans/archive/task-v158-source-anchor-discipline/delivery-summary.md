# Delivery Summary — task-v158 无源不写·空段占位·写必带锚纪律（Rule 71）制度化

> 日期：2026-10-10 ｜ worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline`（wt/task-v158-source-anchor-discipline，基于 master@5280cb3）｜ 计划：plans/task-v158-source-anchor-discipline/task_plan.md（attest SHA 520a7c51…，B 类扩展两次重锁有登记）
> outcome：**COMPLETE**（VC-1..VC-7 全过，58.5 裁决=solved，证据见 §三）

## 一、说明（做了什么）
把 v153 幻觉补位事故的修复提示词组（fix-prompts A/B/C）制度化为 task-planner 技能层 **Rule 71「无源不写·空段占位·写必带锚」**：critical-rules 七子条（规则总纲）+ dispatch 派发契约段（传播面）+ findings/progress 模板占位注释（事故温床直填）+ selftest 12 断言（机器守护），并完成 1-71 计数级联与宽容锚 7x 纪元扩展。

## 二、产出（可定位清单）
| 载体 | 文件:锚 | 内容 |
|------|---------|------|
| 规则条 | skills/task-planner/references/critical-rules.md:888-902 | Rule 71 七子条（71.1 三态/71.2 五问/71.3 占位合法/71.4 审计 SOP/71.5 契约/71.6 关系/71.7 机制） |
| SKILL 登记 | skills/task-planner/SKILL.md:225(C48)/:288(详见行 1-71)/:347(bullet)/:372(References 1-71) | 四处增量 |
| 派发契约 | skills/task-planner/templates/subagent_dispatch.md:88-91 | §10 防幻觉契约段（五问回溯） |
| 模板注释 | templates/findings.md:6,41 + progress.md:6 | 占位合法形态判例 |
| 守护脚本 | scripts/selftest-source-anchor-discipline.sh（52 行，SA-01..12） | 12/12 PASS + registry.tsv:68 登记 |
| 计数级联 | 4 selftest ×15 处 1-69→1-71；CLAUDE.md:33、README_zh.md:136,229 三处 1-68→1-71 | 纯标签替换 |
| 宽容锚扩展 | 14 selftest 文件（S15a-g 五类形态） | 7x 纪元扩容（v144 判例同范式） |
| CHANGELOG | [Unreleased] 首条 Rule 71 条目 | S16 落盘 |
| 计划档案 | plans/task-v158-source-anchor-discipline/（8 文件+15 checkpoint） | 全程留痕 |

## 三、审查详情（验证证据）
- **全量回归**：S8 独立验收（code-runner-agent）67/67 PASS（comm 差集核验无遗漏）+ 主进程复跑双源一致——对照基线 66/66 零破坏。
- **新守护**：selftest-source-anchor-discipline 12/12（SA-11 registry 转正闭环）。
- **级联**：1-69/1-68 在目标面清零（grep 验证）；宽容锚 7 批各自 selftest 转绿（14 FAIL→0）。
- **过程质量**：S-unit 级 verify_done 双条件（Read 产出+findings 回填）全覆盖；14 FAIL 首检→五类归因→B 类扩展登记→7 批并行→全绿的因果链全程留痕（progress.md）。
- **编译/语法**：全部改动脚本 bash -n 过。

## 四、风险（必须列举）
1. **机器边界（如实披露，71.7）**：三态判定的语义面不可静态机检——守护只锚载体存在性，运行时审计靠 71.4 SOP 人工/子代理执行。
2. **宽容锚纪元债**：`40-[567][0-9]` 类锚在全集跨 80 时需再扩（15f 已把先例写入注释防钉死）。
3. **部署位分叉**：部署位 ~/.zcode 现为「1-69+70」（v155 Rule 70 已部署、主仓未合）；本任务合并回主仓后部署对账必须做并集（保 70+71 并存），**禁止单向覆盖**——已列 Phase 6 部署对账步骤。
4. **并行会话冲突面**：v152/v155 在途（改 critical-rules/SKILL/selftest 钉值），合并冲突预期发生，策略=并集解（v149/v150 先例）。
5. **遗留小项**：error-loop.sh:14 头注释仍为 6x 纪元文案（S15a 按禁改条款未动，纯注释无功能影响）；CLAUDE.md:33 行内 HTML 注释叙事滞后（同理未动）。
6. **非本任务范围观察**：v150 计划存在 attest 后未重锁的历史簿记（hook 曾告警，活跃指针已移走、告警源消失；本任务评估后不代改历史计划，留档披露）。

## 五、下一步建议
1. **合并回主仓**：`git merge --no-ff wt/task-v158-source-anchor-discipline`（冲突按并集解；合并后重跑 67 selftest 复核）。
2. **部署对账**：smart-merge-back --deploy 前先 diff 部署位（保 v155 的 Rule 70 与本任务 71 并存，防单向覆盖）；部署后 smoke 三部署位 IDENTICAL。
3. **rule 71 land**：主仓 `rule-reserve.sh land 71 task-v158-source-anchor-discipline` 收台账。
4. **记忆沉淀**：会话收尾写 memory（宽容锚纪元扩展判例+python replace 静默失配教训+worktree 初建即对账主仓 HEAD）。
5. **后续候选**（不阻塞）：溯源审计 agent 化（fix-prompts A 八字段形态已有）；S8 若干新 Rule 均可考虑纳入 selftest 宽容锚的集中管理（当前分散在各脚本）。

## 附：执行统计
- S-unit：S1+S2/S3+S4/S5+S9/S10+S11-S14+S15a-g（并行组 anchor-7x）+S8+S16 = 16 单元，16 done
- 委派率：主进程仅 Phase 1/6 簿记与编排（25.3 白名单）→ 0.94
- 事故零：无 BLOCKED/REJECTED；1 次计划 S-unit 行插入静默失配（python replace 无匹配不报错）被 68.2 hard 门拦截后修复——机器门有效实证
