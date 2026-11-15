# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critic 21 项审查报告 | /mnt/data/dev/task-planner-skill/plans/review-clause-generality-20261115.md | ☑ | Research Findings F1（§三改写意图=草案基线；§四 C-3/G-8 判定=授权边界确认） |
| 三条款 v1 原文 | plans/archive/task-drift-fakeqc-20261115/clause-drafts.md + worktree 三载体 | ☑ | clause-drafts-v2.md §1/§2/§3 行首格式与判例锚沿 v1 |
| 用户授权清单 | plans/task-clause-generalize-20261115/user-session-log.md #2 | ☑ | 草案授权范围行 + Research Findings F1 ⑥⑦ |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **F1（Phase 1/S1 起草+定稿复核）**：clause-drafts-v2.md 落盘（146 行，15/15 授权项落位，§0 映射表在位）；主进程盘上复核 PASS——①old 片段×7 与 worktree 盘面逐字对账全 1/1 命中 ②new 含 old 连续子串接缝×7 全 1/1 ③三条款单行+行首格式与 v1 一致 ④判例锚×9 保留 ⑤无 :NNN 行号锚 ⑥C-3 未纳入（未授权；critic §四判"部分重叠不冲突"与授权镜像一致）⑦G-8 保持 Rule 74 直挂（未授权不改）。定稿修订 2 处：§4.5 片段1 new 补「四锚合计为『四锚输入』」字面、§5 new 补「94.7 管范围静默扩张」字面（对齐 VC-3 判据串）。证据：plans/task-clause-generalize-20261115/clause-drafts-v2.md §0-§6 + VC-1/V-1.2 PASS（2026-11-15 14:15 复核记录）
- **F2（Phase 2/S1-S4 gen-fix 四并行插改）**：4 执行体全落位且主进程盘上复核 PASS——①新串×3 各=1（94.7 对象状态分区/操作类型档位/含目标指令类内容）②既有锚 94.6=1、51.13=1、64.6 行零改动（numstat 证实；VC-2 判据串字面笔误已修：实际行文=「64.6 **零新 config 键」）③级联四点=SKILL 51.14×1/card 94.7+64.7×2/四锚输入×1/94.7 衔接×1 ④三条款整行与草案 diff 一致（947-IDENTICAL 抽样）⑤numstat 合计=2/2+1/1+2/2+1/1+3/3 与计划粒度列一致 ⑥worktree status 仅 5 授权文件。S4 报 partial 原因=派发书自验阈值笔误（≥3 写错，VC-3 实判 ≥1），非产物缺陷。证据：tmp/worktrees/task-clause-generalize-20261115 五文件 git diff + subagent-state/2-insert-S1..S4.md（2026-11-15 14:40 复核）
- **F3（Phase 3/S1 critic 独立复检）**：verdict=APPROVED（8/8 全 PASS，逐项 grep/diff 证据见检查点）；附 3 项残留均非落位偏差——R-1 🟡（64.7 非 trivial 档专档缺失 BLOCKED 枚举缺失=v1 语义回退，裁决句尾增量修复，见 Decisions）、R-2 🟡（64.4 三锚/四锚表述并存，new⊃old 纪律所致且句内已自明「缺任一即不完整」→ 不修留痕）、R-3 💬（标题判例锚重复/`/` 分隔符复用/card A 漏「终态完成」→ NIT 不修留痕）。证据：plans/task-clause-generalize-20261115/subagent-state/3-recheck.md（2026-11-15 14:50）
- **F4（Phase 3/S2 部署后全量回归）**：code-runner --fresh 全量 97 脚本 PASS=88 FAIL=9，comm 子集判定=空（FAIL 集合与基线 tmp/regression-final-20261115.txt 完全一致）；主进程独立复验 tail+comm 同结论。证据：tmp/regression-generalize-final.txt + subagent-state/4-regression.md（2026-11-15 15:03）

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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
