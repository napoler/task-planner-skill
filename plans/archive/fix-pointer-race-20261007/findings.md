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

## fix-pointer-race 结论回填（2026-10-07）
- 根因链: RC-1 写读命名空间分裂（init-session.sh:615/userpromptsubmit.sh:182 不剥 sess 前缀 vs resolve-plan-dir.sh 只读剥前缀形态）+ RC-2 init-session "抢最新哨兵"兜底多会话互抢（本会话 init 实时复现 4272173a 污染）+ RC-3 mtime 兜底把 miss 放大为持续劫持
- 修复: 7 文件 +309/-14（wt/fix-pointer-race 8f6c0f3）——双命名空间读写统一 + <env_sidkey>.sidmap 确定性映射（SessionStart 落盘）+ 兜底两级化（映射权威优先→≤120s 新鲜窗探测→拒抢 WARN）+ gc 扫 sidmap
- CR: NEEDS_FIXES 4 项 → 3 修 1 deferred（见 subagent-state/6-code-reviewer.md）
- 验证: selftest-active-plan 29/29（T12a-g,i-l,T13,T14 行为级）；定向回归 execution-stability 19/19、delegation 38/38；全量回归 15 FAIL 经 master 对照全为既有（零增量）；部署位 7 文件 IDENTICAL；实测解析 fe4545→fix-pointer-race-20261007 正确
- deferred: ① plan-created 哨兵删除 write-delete 竞态（CR P3，窗口窄）；② master 全量 selftest 基线漂移（15 脚本 FAIL，含 v142 在途 periodic-review，需独立排查任务）
