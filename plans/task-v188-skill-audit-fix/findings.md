# Findings & Decisions
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
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **2026-10-19（审计轮）**：15 技能 skill-fix 标准审计 → P0×1/P1×9/P2×12 全清单落 plans/skill-audit-20261019/diagnostic-report.md（4 子代理检查点同目录 subagent-state/）
- **2026-10-26（收口复验轮）**：VC-1..5 全部复跑实质通过——VC-1 残留 3 命中均为平台家目录注释/JSON 示例（原口径过宽）；VC-3 索引行格式已演进为裸数字行（`| 85 |`…`| 95 |`），「Rule 8[5-9]」grep 计数=2 为口径过时非缺陷，46 条口径统一。证据=verification.md 各 VC Evidence 条
- **2026-10-26 Agent B（运行时+硬编码独立复审，checkpoint=plans/skill-audit-20261026/subagent-state/B-runtime-hardcoded.md）**：4 项 register-deferred 登记全 resolved（bun→node 实跑 EXIT=0 / F5 双平台探测齐 / F11 verify_io.sh+schema 在位 / S76 原子写+O_EXCL 锁已修）；skills/ 硬编码残留缺陷 0（videop1 5 处+MIGRATION sed 旧值=登记例外）；bash -n 语法门 TOTAL_FAILS=0；**新发现 B-01..B-05**（3 MAJOR=INSTALL.md:200/:274 与 MIGRATION.md:100 可执行 bash 块残留 `bun run`；2 MINOR=INSTALL.md:15 依赖行+install.sh:8 注释陈旧）→ 移交 skill-audit-20261026 载体修复
- **2026-10-26 回归基线**：run-selftests.sh --fresh = 93 PASS / 0 FAIL（/tmp/selftest-fresh-20261026.log）——机器守护面零缺陷，本轮缺陷均为 selftest 覆盖外的文档/运行时面

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| 2026-10-26 verification.md 全文 Edit 报 String not found（模板占位符重建中文/变量混排段易失配，与 2026-10-19 Error Log 同族） | 改 Write 整文件覆写（该文件全模板占位，无既有内容需保留） |
| INDEX 显示 0/5 与 progress.md 批次1-4 全 complete 矛盾（10-19 会话收口中断于 git commit 后、task_plan 状态未回写） | 2026-10-26 收口轮：真实 Phase 映射回填+VC 复验+归档，outcome=PARTIAL（Phase 3 历史直改如实登记，Rule 25.4） |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
