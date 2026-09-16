# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户指令（2026-09-17「的解决」）：接续 v077 交付报告的 deferred 区——解决两个守卫误报：①提醒链（plan-compass/plan-sync/升级警告）对已交付计划反复误报 v076 文件；②check-dispatch 打包检测把契约条文示例 ID 计为多 S-unit 打包阻断（本次考古派发即被实证拦截一次）。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **Explore 考古（01-explore，2026-09-17）**：①提醒链唯一源=zcode-posttooluse.sh（计划陈旧 L156/findings L175 升级 L184/progress L204）；既有豁免 L100 只查 task_plan.md 的 outcome，而本仓约定 outcome 在 verification.md → 豁免永不触发（v076/v077 误报根因）；修复=L100 后补 verification.md 兜底。compass/stale 在 selftest 零覆盖，execution-stability T11a/b fixture 无 verification.md（加兜底不改既有行为）。②打包检测=check-dispatch.sh L264 `grep -oE 'S[0-9]+...` 全位置计数；FG-03 是唯一多 S-unit 用例；**设计陷阱=单条件 subagent-state/ 豁免会废掉打包门**（所有合规派发检查点路径都在其下）→ 采用「任务书」+subagent-state/ 双条件豁免出 SKIPPED 提示。③簿记：variant 模板来源不明改动已留档还原；.gitignore 补 .session-owner 生效；旧哨兵 038d（v075 P11 误入库）staged 待提交；发现并行信号 plans/task-v079-skill-modify-conservatism/（裸模板存根，非本会话所建，不碰）。完整锚点=subagent-state/01-explore.md。
- **P1 基线（p1-baseline，2026-09-17）**：worktree 187194b 就绪；主进程 awk 求和 = **337 PASS/0 FAIL**（20 Total 行整，与 v077 交付定数一致）。plan-writer 第二次空/退化返回（仅句点）但产出完整——返回消息不可靠、落盘产出为准的又一实证。
- **P2 完成（p2-s3/p2-s4，2026-09-17，主进程已复核）**：S3=zcode-posttooluse.sh L103-105 verification.md outcome 兜底（plan_dir 复用既有变量；三重因果对照：有 COMPLETE 无提醒/无 verification.md 仍提醒/禁用新分支对照组仍提醒）；S4=check-dispatch.sh L264-277 双条件豁免（「任务书」+subagent-state/ → SKIPPED 提示跳过计数，warn/enforce 一致不阻断；既有计数逻辑进 else 分支一字未改）+selftest-dispatch FG-05（23/23；FG-03 无回归；执行者 enforce 双向实测 RC0/RC2）。主进程手测时 sid 未传走了解析降级分支（v075 已知字母序锚陷阱的又一表现，非本任务缺陷）。P2 worktree 提交（3 文件 +25/-1）。
- **P3 完成（p3-s5/p3-s5b，2026-09-17，主进程已复核）**：T13a 正例+T13b 因果对照落地；**首版非密闭缺陷**（固定 sid state 持久 → 重跑落入 plan-sync 冷却窗口，主进程复跑 FAIL 实证）→ 主进程 bash -x 确诊后派 executor 修正 ST13_SID 唯一化，连续两遍 19/0 密闭验证。**P4 全量回归：主进程 awk=340/0（=337+FG-05 1+T13a/b 2）**；CHANGELOG 仓根条目由 code-assistant 落位（委派守卫已转 enforce，S7 主进程直做改为委派——Handoff 登记偏差）。
- 并行信号处置记录：plans/task-v079-skill-modify-conservatism/（裸模板存根）全程未碰未提交；variant 模板游离改动已留档还原；.gitignore 补 .session-owner；旧哨兵 038d staged 删除随 P5 簿记。
- **P2 完成（p2-s3/p2-s4，2026-09-17，主进程已复核）**：S3=zcode-posttooluse.sh L103-105 verification.md outcome 兜底（plan_dir 复用既有变量；三重因果对照：有 COMPLETE 无提醒/无 verification.md 仍提醒/禁用新分支对照组仍提醒）；S4=check-dispatch.sh L264-277 双条件豁免（「任务书」+subagent-state/ → SKIPPED 提示跳过计数，warn/enforce 一致不阻断；既有计数逻辑进 else 分支一字未改）+selftest-dispatch FG-05（23/23；FG-03 无回归；执行者 enforce 双向实测 RC0/RC2）。主进程手测时 sid 未传走了解析降级分支（v075 已知字母序锚陷阱的又一表现，非本任务缺陷）。P2 worktree 提交（3 文件 +25/-1）。

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
