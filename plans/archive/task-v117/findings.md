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

## 系统性对齐核查（sub:60，2026-10-02 10:xx 完成，只读）

<!-- 来源=plans/task-v116/subagent-state/60-explore-v107-legacy.md（主进程转写的 Explore 检查点） -->
- v116「R 系列全部清零」声称偏乐观：实测 8 处残留（critical-rules.md:320/326「13 变体」、R-07 裸引用×4、CONTRIBUTING 幽灵命令×6、CLAUDE.md:81 py_compile、CLAUDE.md 树缺 knowledge-brief 行、batch-quality-gate.md:111、CHANGELOG:108 删除段=(无)）
- 三裁决口径：P-5 SKILL.md:9 具名枚举止于 36（用户授权补齐 37-45）；T-2 委派统计缺 27 家+Handoff 缺 v115 族 12 家（用户授权全部补齐，mini-lite 设计豁免留痕）；C-P6 session-catchup 三处统一全路径（用户授权）
- 部署面：三宿主 selftest-workflow-orchestration.sh 为 v116 前旧版（md5 三宿主一致，单向 cp 即可，无回流面）
- 风险登记：WF-10 守卫命中合计实测=6 恰好压线（零余量）；companion/ 4 个 .backup-* 目录 gitignore 覆盖可择机清理（非阻塞，不入本任务）

## P1（Phase 1 executor 批次 1：S2/S3/S4，2026-10-02，worktree 内，未 commit）
<!-- 来源=plans/task-v117/subagent-state/1-executor.md（executor 检查点） -->
- S2: critical-rules.md:320「已有 13 变体」→「已有 variant（v074 时点 13, 现行 29）」（历史叙事保本体+双时点括注）；:326 34.5「对齐既有 13 变体」→「对齐既有 29 个 variant」。grep '13 变体' 0 命中 ✅
- S3: R-07 裸引用×4 修实位（../../task-planner/references/critical-rules.md）：cost-control.md:168、cost_log.md:69、cost_log.md:7（头部叙述式「critical-rules.md Rule 17.5」同型裸名一并修）、template-mapping.md:39。判定面 grep 全带前缀 ✅；余留 plan-cost-guard/SKILL.md:29=跨技能指针解释说明行（非引用，判定不改，登记）
- S4: CONTRIBUTING(_zh).md 幽灵面清零：目录树仓根 scripts/ 面（幽灵）删、实位改 skills/task-planner/{install.sh,uninstall.sh,lib/verify.sh}；`bash scripts/validate.sh`（:47/:52）→`TASK_PLANNER_ROOT=... bash skills/task-planner/lib/verify.sh`；`--force`（install.sh 行 :51）删→`--no-backup`+实 flag 面注记（--canonical/--tools/--no-verify/--no-backup/--dry-run，install.sh:32-44 实测）；`--target /tmp/test-skill-install`（:137）→`--canonical /tmp/test-skill-install`（--dry-run 预检+实跑）保留测试语义。双文件 grep 'validate.sh|--force|--target' 0 命中 ✅；CHANGELOG 未动
- 改动面: 6 文件（git diff --stat 见 1-executor.md）；critical-rules.md 改动=2 行行内替换（行数锚值不变，S11 级联面=零）
