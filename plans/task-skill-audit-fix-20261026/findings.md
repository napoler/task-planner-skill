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
- R1「完成当项目进行深度审查 对skill 各种缺陷进行分析挖掘 并修正」拆解=①两路并行审计（引用面+运行时面）②17 项缺陷修复 ③零回归证明。映射见 task_plan R→VC 表。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 前轮审计诊断报告 | plans/skill-audit-20261019/diagnostic-report.md | 已消费（作为「勿重复报已修项」基线） | Research Findings 第 1 条 |
| v188/v189 收口复验 | plans/archive/task-v18{8,9}-*/verification.md | 已消费 | Research Findings 第 2 条 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **A 路（引用完整性+计数算术，checkpoint=plans/skill-audit-20261026/subagent-state/A-ref-integrity.md）**：P1×2（critical-rules.md 卫星路由索引 task-discipline 漏 95 / plan-collab-router 漏 91——两条已落地规则未入索引）+P2×7（SKILL.md 裸引用双形态/plan-cost-guard 等 3 处 `task-planner/` 裸形/template-guide 路径不精确）+INFO×3；计数声明核心 14 条/卫星 79 条/discipline 46 条/11 卫星全部实测正确无错账。
- **B 路（运行时+硬编码，checkpoint=同目录 B-runtime-hardcoded.md）**：v188/v189 四项登记全 resolved（bun→node 实跑 EXIT=0/双平台探测/verify_io+schema/S76 原子写+O_EXCL）；skills/ 硬编码残留缺陷 0（videop1 5 处+MIGRATION sed 旧值为登记例外）；**新发现 B-01..B-05**：INSTALL.md:200/:274+MIGRATION.md:100 可执行 bash 块残留 `bun run`（照做即失败，MAJOR）+INSTALL 依赖表/install.sh:8 注释陈旧（MINOR）；bash -n 语法门 TOTAL_FAILS=0。
- **回归基线（2026-10-26）**：修复前 93/93 → 修复后第一轮 92/93（selftest-doc-script-paths 抓获 plan-cost-guard 技能根 `../../` 错形——守护有效性的正面实证）→ 修正后 **93/93 全绿**（/tmp/selftest-final-20261026.log）。
- **僵尸计划判定（plans/ 卫生）**：v188/v189=实况完成、本轮已收口归档（各 outcome=PARTIAL，流程债如实留档）；**v190=v189 逐字节副本（幽灵，无独立工作，处置待用户裁决——删除需授权 Rule 74.3）**；task-P01=已被 task-skill-audit-20261021 P-01 落地覆盖（可封存，待裁决）；task-defect-rrv13-dg12-false-pass=pending 无 goal（10-16 登记，未启动）；task-v192-deploy-zcode=pending 部署同步任务（另行）。

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
