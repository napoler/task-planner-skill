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

#### [main:explore-1] 契约层与 agent 定义层双向调研（2026-10-10，并行 explore×2）
- **契约层现状（有规定但被架空）**：`skills/task-planner/templates/subagent_dispatch.md:62-77` 规定 8 字段严格返回（status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence），:62 明令「字段名与顺序不得改、不得增删、8 字段之后不得有任何内容」、:75「不加标题/前言/总结」；`references/critical-rules.md:184` Rule 22.4b 同文。delivery-summary.md:1 定位用户面终验产物，与子代理返回面文档层隔离——**契约文本不缺，缺的是执行层的优先级与校验**
- **污染主源（agent 定义层输出模板，~/.zcode/agents/）**：`executor.md:45-46`「🔍 step [N]/[total] … ⚙️ action → ✅ completed」步骤进度模板；`general-purpose.md:31-48`「任务交付报告」（标题+评分+已完成/未完成/验证证据/风险）；`explore.md:33-38`「每个发现格式」；`plan-bookkeeper.md:35-40` `[BOOKKEEPING]` 模板；`plan-writer.md:219` `[PLAN_WRITTEN]`——均未引用 8 字段，与派发契约在子代理上下文竞争
- **正确范式（对照）**：`drift-checker.md:29`「按派发 prompt 8 字段模板返回」+`decision-arbiter.md:50` 同——不定义自有输出模板，引用派发契约
- **污染传播载体**：`scripts/subagent-fallback.sh` bind 生成的 `<type>-fb` 变体 agent 正文原样复制源 agent（含冲突输出模板）
- **守卫盲区**：`scripts/check-dispatch.sh:120` 只校验派发 prompt 含 status:/acceptance:/checkpoint: 三 key，不校验子代理实际返回消息

#### [main:explore-2] 实证抽样（5 计划 58 份检查点）
- **合规率 24.1%**（14/58 严格 8 字段）；违规 44 份（75.9%）：完全无 8 字段块 38 份（v159 全部 11 份+v152 全部 26/27 份纯自然语言+表格）、8 字段块后附加自然语言段 6 份（v160）、契约外字段 1 份
- **v152 实证污染样本**：`plans/task-v152-proactive-context/subagent-state/2-executor-S1.md:32` 在 status 与 acceptance 之间混入 `summary:` 字段（契约外）——总结式字段插入 8 字段块的直接证据
- **v160 部分合规样本**：`plans/task-v160-decision-grading/subagent-state/2b-executor.md:20-41` 8 字段块后附「两处接线明细」表格+「边界与排除项」+「差异说明」共 22 行契约外内容（违反「块后不得有任何内容」）
- **变异体（同任务内合法形态）**：检查点文件允许「头部 status 行+里程碑+产出清单+最终结论」分段（22.8.3 人读格式），「最终结论」段=严格 8 字段块；findings.md `#### [sub:*]` 小节 bullet 形态、Handoff 表「结论摘要」列自然语言=主进程侧摘要，均不属返回消息污染面

#### [main:user-evidence] 用户 mid-turn 实证判例（2026-10-10，污染第一优先根因）
- **原话**：「我找到为什么会出现子代理中出现这种就是在最后的列表，最后的那就是总结阶段出现的错误……在输入给子代理的提示层包含了以下信息。以下为示例：## 返回格式## 返回格式 ① v3.1 23 段新配置摘要表（段×mode×refs 槽位）② style_exempt 统一口径 ③ 合图锚占位清单 ④ 段间链锚链图 ⑤ 机械自检输出 ⑥ 待裁项。」
- **形态判读**：派发 prompt 的「## 返回格式」段被填入 ①②③④⑤⑥ 任务要点/待裁项清单（非 8 字段模板块），且标题重复（「## 返回格式## 返回格式」=两段内容拼接痕迹）——即子代理收到的返回格式指令本身就是总结式清单；子代理照指令返回总结式内容=照章办事，非模型漂移
- **治理缺口**：`scripts/check-dispatch.sh:120` 只查 prompt 含 status:/acceptance:/checkpoint: 三 key 存在性——若 prompt 别处（如输入材料段）含这些字面即可通过；「返回格式」段结构本身（标题唯一+段内=8 字段块）零校验
- **与 agent 定义层竞争的关系**：两个独立污染面正交——段填写污染=指令本身就是错的（主进程填模板错误）；agent 定义竞争=指令对但角色模板抢赢（LLM 优先级）。修复需两侧同时设防（S6+S1/S3/S1）
- **内容溯源备注**：用户示例的「v3.1/style_exempt/合图锚」等词汇属 article 管线侧任务要点（非本仓产物），作为跨项目判例收录；本仓 v152/v159/v160 实证样本已在上节

#### [sub:2-code-assistant] Rule 22.4b 污染三面+主进程动作闭环（2026-10-10，主进程兜底回填）
- 操作：worktree critical-rules.md Rule 22.4b 段末（:184 长行后）追加任务书指定逐字句，git diff --numstat = 1 0
- 结论：污染三面（派发 prompt 段填写污染/agent 定义层输出模板竞争/返回回收零机械校验）已成文；主进程动作闭环显式化=收到返回先过 check-subagent-return.sh 四判据，VIOLATION 按 22.8.5 视为 partial+打回+检查点兜底+Handoff 记违规形态
- 证据：critical-rules.md:185；checkpoint subagent-state/2-code-assistant.md（8 字段最终结论块合规，status done）

#### 用户原话转译核对（Rule 51.1 反造谣自检）
- 用户反馈「现在返回了和正常执行任务返回一样的格式」= 子代理返回被总结式/步骤进度式自然语言格式替代固定列表格式，与上述三层根因完全对应（实证 75.9% 违规率 + 用户 §7 段污染样本）

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
