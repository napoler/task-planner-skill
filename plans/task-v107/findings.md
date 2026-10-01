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
- **[Phase 1 S1] bash -n 全量语法扫描（2026-10-02，主进程 ④ 接管=mini provider rejected，白名单③）**：skills/ 下 10 个 skill 全部 `*/scripts/*.sh` 共 **75 个脚本，0 语法 FAIL**。证据：`for f in skills/*/scripts/*.sh; do bash -n; done` → `scanned=75 syntax_fail=0`。v106 基线稳定性在语法面成立。


#### [sub:2-executor] 全量回归
- **[Phase 1 S2] 42 selftest 全量回归（2026-10-02，sub:2-executor 执行，22.3① 改派自 code-runner mini）**：42/42 脚本 rc=0，0 FAIL，0 timeout。逐脚本 PASS 求和 **660**、FAIL 求和 **0**，与 v106 基线 660/0 完全一致。特例：`selftest-final-gate-hash.sh` 无 `Total:` 行（rc=0），结果行原文为 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`（计入求和）。逐脚本 rc+Total 行原文（42 行）见 checkpoint `subagent-state/2-code-runner.md`。

#### [sub:S3] 三宿主部署位盘点（2026-10-02，主进程 ④ 接管，白名单③）
- **主仓**：10 个 skill（task-planner + 4 卫星 plan-{collab-router,cost-guard,research-router,template-kit} + plan-resume/todo-skill/task-drift-guard/progress-tracker + iterative-optimizer）+ review-library 池 11 技能（skills/task-planner/review-library/）
- **~/.zcode/skills**：10 skill + 11 池技能相对软链（→ task-planner/review-library/*）✓ 全在位
- **~/.claude/skills**：10+11 全在位（池=同款相对软链）✓
- **~/.opencode/skills**：10+11 全在位 ✓
- **⚠️ 发现**：`~/.config/opencode/skills` 存在**第二套旧部署**——含 task-planner/task-drift-guard/部分池技能，但**缺** iterative-optimizer、plan-collab-router、plan-cost-guard、plan-research-router、plan-resume、plan-template-kit、progress-tracker、todo-skill；与 ~/.opencode/skills 的关系（opencode 实际加载位/废弃残留）待 Phase 3 核实


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
