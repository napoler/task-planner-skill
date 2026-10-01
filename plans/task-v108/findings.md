# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:1-executor] 模板普查
（全量只读普查 2026-10-02；六维结论 + 修复清单 v1；完整清单与证据存 subagent-state/1-executor.md）

- **维度1 v107 结论核实（全坐实）**：① task_plan.md:249 与 critical-rules.md:49 仍旧 worktree 约定 `../<repo>-wt-<task-id>`（worktree-isolation.md:32/37/50 已立新约定 `<repo-parent>/<repo>-worktrees/<task-id>` 并明文废止）；② knowledge-brief.md:9 注释「锚计数维持 20」≠ 实测 `grep -rl "## 📚 必要知识储备" templates/` = 22（guide:77 已 22，此注释未回写）；③ mapping §一清单 13 variant(L32-44)/§六速查 13 行(L133-145)/§九矩阵 14 行 均 ≠ ls variant/ 实测 16（缺 mini-lite/video/video-fix）；④ guide:63「实际 26 个 .md」≠ ls 实测 25、:65 标题「23/26」≠ 实测 22/25（同文件内与 :77 的 22 自相矛盾）；⑤ 4 variant（diagnostic/publish/research/writing）缺 `template_type:` 注释（grep -ln 仅 12 命中），16/16 有 plan_tier；⑥ T-1 坐实：writing:11-12/63、research:14、publish:12/15/34/90 所引 4 脚本全仓 find 0 命中 → 目标项目侧示例值。
- **维度2 区块完整性**：委派统计全 16 variant 缺（Rule 25.4 机器落点在 verification.md「委派统计复验」段 :74，variant 计划共用 verification.md 已覆盖 → task_plan 侧是否镜像节=待裁决 M-11）；Handoff 节仅 mini-lite:44（合法，38.3 白名单⑤），其余 15 缺 → **check-complete.sh:1014-1017 的 Handoff 抽查节锚对 variant 计划静默失效**（M-08 高风险联动）；Drift Log 7 variant 在位 / 9 标准 variant 缺（M-07）；mini-lite 缺委派统计与 Drift = 38.3 白名单合法豁免。
- **维度3 声明形态**：主模板 task_plan.md:8 仅 `plan_tier: standard`，无 `template_type:` 行（L22 正文提及）；12/16 variant 双注释在位。
- **维度4 新规范行**：「自动超时默认项/质量审查工具/对齐审查」3 行仅主模板 task_plan.md:31-33；15 标准 variant 配置表仅 code_review 单行；「🧰 工具选择与编排」仅主模板 L136（40.2 明言 general 承载 + mini 豁免 → variant 缺口需裁决 M-12）。
- **维度5 验证独立性**：templates/ 全库「验证由独立子代理执行」类表述 grep 0 命中；最近锚=Rule 33.3「独立验证（不信自报）」（critical-rules:304）。候选落点 A=verification.md:108 Goal Gate 段后加原则行（终验判定面）/ B=task_plan.md:35 VC 段头部（计划期声明面，Executor 可据此填 V-执行体）；备选 C=task_plan.md:214 Phase 4 / D=verification.md:74 复验段注。推荐 A+B。
- **维度6 四点同步面**：SKILL.md:274「standard 13 variant」、critical-rules:348「14 行：13 variant+general」、:361「现有 13 个 variant」均 ≠16；plan-writer.md:53-66 映射表 14 行缺 mini-lite/video；mapping §一/§六/§九 同缺；guide §2.2 已 16 行 ✓（四落点中 guide 无需改）；selftest-template-lifecycle.sh 实跑 18/18 PASS，TL-17 仅锚 guide「16 个」→ 修 13→16 零自测断裂。
- **修复清单 v1**：M-01~M-13 全文（ID/锚点/修法/性质/联动面）见 subagent-state/1-executor.md「修复清单 v1」表；其中 M-11（task_plan 侧委派统计节是否镜像 15 variant）与 M-12（40.2 口径：variant 补区块 or 改表述）两项待主进程裁决。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
