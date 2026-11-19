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
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## §1 判例取证：sess_a7eb0603 模型滥用失效链（2026-11-19）

### 1.1 铁证（盘上第一手）
- **agent_4224ef20**（`~/.zcode/cli/agents/sess_a7eb0603-*/agent_4224ef20-bdd0-4e34-899f-9eca30ee234f/metadata.json`）：profileId=**article-content-editor**，profileSnapshot.modelSelection=`9e221f47/deepseekv4anthropic/deepseek-v4-pro`，createdAt=2026-11-18T23:25Z。实际产出=仅删 1 句重复句（1173→1166 词，-0.60%），其余全为 8 步机械操作（定位备份/sha256/双文件替换/gate/push/回读/报告/探针复验）——task.output 尾部自述"词数 1173→1166（-7, -0.60%）"。
- **agent_4f8cfac1**（同目录 agent_4f8cfac1-*，2026-11-14T22:12Z）：同模型，描述"data 块卫生 109+175"=机械比对任务，一样用 deepseek-v4-pro。
- **agent-model-tiering 记忆**（`~/.zcode/cli/memories/projects/.zcode-c4bb56bd9710299a/memory/agent-model-tiering.md`）明确："article-writer 走独立 provider 9e221f47 的 deepseek-v4-pro"=**内容创作契约专用**；机械型应 haiku-1/mini。契约模型被泛化到机械步骤=边界条款缺失。

### 1.2 失效链四环（规则已有条款为何没防住）
1. **Rule 96.2 触发面漏洞**：96.2 只管"计划期 S-unit 表正向选档"（critical-rules-dispatch.md:211）；判例中 886 修复是**执行期临场派发**（article-generation plans/task-coffee-gate-repair-20261113/task_plan.md grep "886|article-content-editor|继承"=零命中）——临场派发无分类约束。
2. **混合任务无拆分义务**：任务="删 1 句（创作边缘）+8 步机械"，59.1 三值门（Nf/Nl/Nmin）量的是体量不是**任务类别**，混合单元整体派出。
3. **"继承"档位传染**：22.6 允许 S-unit 执行体"继承=Phase Executor"——Phase 声明重档执行体时机械子步骤全被传染重档。
4. **契约模型边界仅存记忆**：deepseek-v4-pro=创作专用的约定在 agent-model-tiering 记忆文件，未进 task-planner 规则体系，跨项目无约束力。

### 1.3 级联面现状（写入前基线）
- 全集最大 Rule 编号=109（core 在位 15 条+卫星 90 条，SKILL.md:9/:260/:304 计数行=1-109）→ 新条款编号 **110**。
- selftest 纪元锚已预放宽 11x 窗（selftest-absorption-discipline.sh:42 等 R8 预放宽；上界外探针已移 1-120）→ 1-110 级联预期零 selftest 冲突。
- SKILL.md:293 dispatch 卫星指针行职责已含"模型档位"——Rule 110 落 dispatch 卫星自洽。
- 需确认：selftest-anti-deferral.sh AD-10"其余 NN 条"锚当前形态（历史 84→86→90，若为动态/放宽=零锁步；执行期跑回归对照基线定夺）。

### 1.4 风险披露（如实登记）
纯文本条款（96.2 同款判定面=LLM 行为）在超长会话（判例=1096 agent 目录）中的执行力有限——96.2 落地于 10-24 未防住 11-14/11-18 的滥用即为实证。机器面（check-dispatch 增 tier-class token 校验）按文本优先铁律（宪法 §二 P0 2026-10-15）列为**待授权候选**，本任务不实施。

## §2 验证与复检结论（2026-11-19 Phase 4）
- 103.3 critic 独立复检：**APPROVED**（四判据 PASS：逐字 md5 一致/纯增量 21+0/衔接自洽 cmp 一致/判例锚一手复现）。发现 3 MINOR+1 QUESTION+3 NIT。
- 采纳修正（CR 修正轮，消歧收紧非放宽）：M2→110.3 补「任一步骤属创作类即触发拆分义务」；M3→110.6 补「判定对象=任务目标物，过程性报告不属产出物」。NIT-3→findings §1.1 modelSelection 路径已修正。
- 未采纳（登记观察）：M1（创作类→重档 vs 96.2 重档定义接缝，110.6/110.7 已兜底）；QUESTION（tier-class token 自证性=已披露风险，机器面待授权）；NIT cli-executor-agent(mini) 示例（派发可 override，非事实错误）。
- 预存 selftest FAIL 7 项（与本任务无关，基线同集同数）：EN-06 锚死陈旧纪元 1-108/BP-08 pin 311 行（74.7 后实际 320）/registry 孤儿行 md-edit-ops/active-plan worktree 环境性/execution-stability T11b/summary-readability SRV-11·12/self-resolution SR-12——待另行任务锁步。
- task-dispatch/SKILL.md 历史欠账：索引表缺 Rule 96/103/104 行（110 前已缺，本任务仅加 110 未扩范围）——待另行任务补齐。
- 并行会话协调：master 在本任务 worktree 期间前进至 79debfa（74.7 任务），已 worktree 内吸收合并（零冲突）。
