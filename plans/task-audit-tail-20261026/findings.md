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
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **v190 误判纠正（本轮核心发现）**：早前「v189 逐字节副本零独立工作」仅比对 progress.md 单文件所致失实；全目录 diff+delivery-summary 标题+git 链（f6593e8 修复/3b50e02 合并/e52b88d 交付）+复验（register-hooks-cj.ts:21,98 unlinkSync 实证；split-pattern-library 13/13+tier-b 18/18——v189 期 2 项 pre-existing FAIL 已清零）证实=真实完成工作 → 删除改收口归档（§五 删除前看目标铁律生效判例）
- **P01 覆盖证据修正**：63c70ae 仅簿记引用；真覆盖源=plans/verification-upgrade-2026-10-16/ 工作流 P-01 落地，活证据=check-complete [evidence-anchor] 门在位且 2026-10-26 实测通过
- **素材换词语义安全判据**：check-complete.sh:1845 命令词表 \b(bash|bun|node|python)\b 含 node → `bun run x`→`node x` 等价命令词单信号，EG-22/EG-23 断言语义不变（23/23+93/93 实证）

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
