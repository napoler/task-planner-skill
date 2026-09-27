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

## Research Findings（workflow 取证汇总，2026-09-26）

工作流 dwfrun-0f320de1 完成：4 领域取证（workflow-evidence/01..04-*.md）→ 瓶颈总表 29 条（05-bottlenecks-and-designs.md）→ 两轮批判+独立终审 → 终稿 efficiency-proposal.md（Tier A 10 / Tier B 7）。核心实测锚（全部 file:line 或计时实证，全文见提案）：

1. **hook 热路径（慢的最大单源）**：PreToolUse 每次 Write/Edit 实测 1.23s——Rule 23 冲突扫描无状态过滤遍历全部 37 个历史计划逐个 ≈9 次 fork（zcode-pretooluse.sh:91-116，439 clone/次）；UserPromptSubmit 每条用户消息实测 0.85-3.06s（check-conflicts --runtime 9 处 git 调用 + attest --verify，zcode-userpromptsubmit.sh:39,61,136）；PostToolUse 无 matcher 挂全工具 + 每次固定 5 个 jq 读同一 config.json = 143ms/×所有工具调用
2. **派发协议开销**：每 S-unit 派发周期固定 ≈10-11 次协议动作其中 1 次是工作（22.4 九字段/22.4a 三文件/22.4b 8 字段/22.5 Handoff 12 列/22.8 检查点，critical-rules.md:132-142）；计划建立期 ≈15-18 步固定仪式先于一切实际工作（SKILL.md:60-80）
3. **mini 档未生效于流程**：mini 只裁「计划文档区块」不裁「流程步数」——2 Phase×6 步闭环、3-File Gate×2、Todo S1-S5×4-6、attest、check-complete 全保留（critical-rules.md:341 边界明示）
4. **复杂任务乘积结构**：每 Phase 固定仪式 ≥16 个主上下文动作（含 2 个 Skill 全文加载 ~10K tokens）×Phase 数；27 selftest 全量 65.7s/轮×每任务 ≥2-3 轮；21.4 串行链式等待
5. **提案结构**：Tier A 10 项（A-1 mini 自动降档/A-2 锚点口径/A-3 重复检测合并/B-1 契约压缩/B-2 单写者澄清/C-1 hook 热路径合并/C-2 终验哈希复用/C-3 index 单 awk/C-4 selftest 分域/C-5 部署对账两级化）；Tier B 7 项（T-B1 分槽并行/T-B2 mini 单 Phase/T-B3 mini silent/T-B4 直做通道/T-B5 T5 免写/T-B6 CR 分级/T-B7 findings 增量放宽）；质量护栏段含逐项 selftest 守护+子代理干净上下文验证设计（约束⑦已织入）
