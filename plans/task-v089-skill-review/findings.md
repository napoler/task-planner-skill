# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户 `/workflow` 显式点名 → 按 Rule 39 走动态工作流对 skills/task-planner 当前技能做只读全面审查，产出含证据与独立验证的审查报告；只列问题不实施修复。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 技能本体 | /mnt/data/dev/task-planner-skill/skills/task-planner/ | 是 | Research Findings |
| 工作流编写契约 | dynamic-workflows skill（会话已加载） | 是 | Technical Decisions |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **工作流 run dwfrun-133695f0-d27d-4ee7-aa1a-343d01c8f767 完成（2026-09-25，基线 commit f926af6）**：4 领域 28 条发现（27 confirmed + 1 unconfirmed），批判去重后实质 distinct 约 17 条；全量报告 `plans/task-planner-skill-review/report.md`（primary 交付物）。
- **确定性门**：仓侧 27 selftest Σ=453 断言 PASS=453 FAIL=0（.sh 零失败）；「门未全绿」唯一根因=工作流门命令 dwf.ts:90 把 2×.cjs+2×.ps1+3×.ts 共 7 个非 shell 文件喂给 `bash -n`（必报假阳性；node --check 两个 .cjs 通过）→ 属编排脚本缺陷非测试缺陷。
- **high 级（仓内实质）**：① `scripts/subagent-fallback.sh:46-52` load_config 四层 jq 单层路径全解析为 null，config 覆盖静默失效；② `scripts/check-plan-dispatch.sh:115-116` step_max_minutes/step_max_files（及 check-dispatch.sh:268 prompt_max_chars）单层路径 + `//` 兜底静默回退默认值，同文件 :118 已是双层写法两种并存。
- **medium 级文档漂移**：Rule 12（critical-rules.md:49 + templates/task_plan.md:232）worktree 旧路径 `../<repo>-wt-` 残留，集中目录 `<repo-parent>/<repo>-worktrees/` 在 SKILL/references 全文 0 命中；Rule 16 知识储备 grep 锚 21→22 漂移（video-type.md 51ca883 补建后未级联）且 video 类型未入 template-mapping §九矩阵/§一决策树（Rule 34.2 四点同步缺口）；goal-gate.md:7「≥5 条 VC」未同步 Rule 38 mini 档降档（机器侧 5→2 已降、文档权威源未降）；README.md 7 处数字脱节（12 篇/64 脚本/357 commits/17 smoke/22/25 模板等）；check-complete.sh:549-550 VC-GATE 阈值硬编码 5/2 从不读 max_vc/min_verification_per_phase（config description 声称联动但脱钩）；check-doc-sync.sh:12 注释引用不存在的 sync_interval_calls 键。
- **low 级**：SKILL.md:70「5 个文件」未随 v067 第 6 文件 knowledge-brief 更新（同文件 L352/L556 自相矛盾）；SKILL.md:455/507 行号前向引用陈旧（322-324→372-374、353-361→402-412）；reference.md:235「5Q」标题实为 6 问；SKILL.md 558 行超 500 健康边界且无 selftest 行数守护；selftest Total 行 4 种格式变体并存（skill-modify 含 SKIP 口径）；selftest-conclusion-discipline 宽容锚注释/代码/文案三方区间漂移 [5-7]/[5-8]/[5-9]（现值 1-39 巧合全过）；cost-control.md §七 3 hook 注入点 0 命中（文件自注未实现）。
- **unconfirmed（1 条）**：「19 条 Rule 无专属 selftest 守护（Rules 1-7、9-17、19-21、23、24、26、27）」独立验证未复现；另 5 个脚本（check-conflicts/check-drift/check-doc-sync/ledger-append/plan-doctor）零 selftest 引用。
- **部署位缺口（批判轮实跑新发现，未单列 finding）**：selftest-workflow-orchestration.sh 在部署位 `~/.zcode/skills/task-planner` WF-10 FAIL（命中 3<6，`SKILL_ROOT/../../` 解析 CLAUDE.md/README_zh.md 落到 ~/.zcode/ 不可达）——selftest 对运行位置不鲁棒；「全量 453/0」结论须限定 as-of 仓侧。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 执行方式=动态工作流（Rule 39，21.4 并行豁免登记） | 用户显式 /workflow；4 领域 fan-out 并行 + 逐条独立验证 + 两轮批判 |
| 报告落 plans/task-planner-skill-review/report.md | 用户可打开的交付面；plans/ 不入库免 git 纠缠 |
| 只审不修 | 用户指令=「审查」；修复=新任务（Rule 8.1 D 类） |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 工作流脚本编译错 critique used-before-assigned（L183/L204） | Edit draft `let critique = ""` 初始化后 path 重提交通过 |
| 门命令 bash -n 假阳性（dwf.ts:90 纳 .cjs） | 批判轮定位，报告 ③⑤ 如实披露；仓侧 .sh 实际全绿，不影响审查结论 |
| 部署位 WF-10 对运行位置不鲁棒（3<6） | 如实登记 findings/verification 遗留，修复=后续任务 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 全量审查报告：/mnt/data/dev/task-planner-skill/plans/task-planner-skill-review/report.md（基线 f926af6）
- 工作流 run：dwfrun-133695f0-d27d-4ee7-aa1a-343d01c8f767（scriptPath=skills/task-planner/.zcode/workflow-drafts/task-planner-技能审查.dwf.ts）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
