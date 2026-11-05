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
- R1-R4（逐字见 user-session-log.md #1 / task_plan R 区块）：① 房车入户门两侧都有=基础认知检查错误却 QC 放行；② 「场景图只有场景无人物」硬约束未达成却通过；③ 优先优化当前技能文件强化 QC 门；④ 所有基础性可发现错误须根治，后期验证严格性必须有保障。
- 修复载体=技能条款面（media Rule 47.6/50.5 + companion 图/视频执行体 SOP），非仅修补 Toonflow 工作区资产；Toonflow 侧同族计划 task-imgqc-basicknowledge-fix-001 只动工作区协议文件（grep 零命中本仓技能文件），与本计划互补不冲突。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回回填锚:cp-01-explore / cp-02-analyst -->
- **[cp-01-explore] QC 门载体盘点（Explore, 2026-11-05）**：规则层唯一载体=`skills/media-planner/references/critical-rules-media.md` L21 Rule 47.6（图侧常识清单=封闭式 3 项：解剖透视/文字乱码/主体错位）；L51 Rule 50.5=原子验收条目表+image-understand 取证机制（已有，但 47.6 门未强制接入）。SRC companion 两 agent 文件**均无 47.6 块**；部署位 6 份（~/.zcode|.claude|.cursor/agents/{image,video}-generation-executor.md）均含 47.6 块——**SRC↔部署双向漂移**（SRC 有 95.x 增量缺 47.6，部署有 47.6 缺 95.x）。缺口：Q1 部分/Q2 无（无空间布局类目）/Q3 无（自检无独立取证强制）/Q4 无（硬约束违反无 FAIL 语义）/Q5 有（47.5 三轮环在位）。检查点：subagent-state/01-explore-qc-carriers.md（39 行）
- **[cp-02-analyst] 事故取证（general-analyst, 2026-11-05）**：会话=sess_83f64e428b36b94e50f3378b5f076aa6（Toonflow 钓鱼佬日常 EP17 恢复，workdir=/mnt/data/dev/Toonflow）。缺陷 a=阿凯房车行车4格-v2 双门「误判 4/4 PASS」入 C48 候选，用户反馈≥2 次后作废（母图状态板 L46）；缺陷 b=B1-B4 场景重做件含人物（女子持竿）无 QC-FAIL 挂「待审核」，用户定判作废（L56-59）；同批 B5/B6 记「S13 imageQc 三检 PASS」=QC 管线在跑但判据缺项。根因三假设（带锚）：①检了但判据缺项→结构性漏检（高置信，L46「漏核逐格门位置…误判 4/4 PASS」）②软约束未硬化为 FAIL/未执行（中高，同批 B5/B6 PASS 对照）③PASS→候选→推荐链路无基础常识硬伤阻断（高置信，「竟然将作为合理的推荐给用户」）。权威日志=/home/terry/.zcode/cli/log/zcode-2026-11-05.jsonl（100MB，L20077 起）；检查点：subagent-state/02-analyst-incident.md

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
<!-- 有用的 URL/文件路径/API 供引用,发现即记 -->
- 规则层载体：`/mnt/data/dev/task-planner-skill/skills/media-planner/references/critical-rules-media.md`（L21=47.6，L51=50.5）
- SOP 载体（SRC）：`/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/image-generation-executor.md`、`video-generation-executor.md`
- SOP 载体（部署位基底）：`~/.zcode/agents/image-generation-executor.md`（47.6 块含 H 级清单，md5 5a5810c6=SRC 无块版对比基底）
- 事故证据：`/mnt/data/dev/Toonflow/workspaces/钓鱼佬日常/母图状态板.md` L46/L47/L56-59；`rejected-assets.md` L17-18/L25-26/L66
- 同族计划：`/mnt/data/dev/Toonflow/plans/task-imgqc-basicknowledge-fix-001`（工作区协议面）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
- **[S0-75.15 网络评估]（WebSearch, 2026-11-06，1 次轻量）**：业界 AI 图像 QC checklist 交叉验证——常见缺陷类别=①解剖（手指/肢体/牙列）②**空间一致性**（光影方向/反射/阴影跨物体连贯）③**常识物件摆放**（漂浮/比例失当/不可能重叠/物件相互融合）④纹理细节崩坏 ⑤文字乱码。结论：本计划 47.6b 类目设计（空间布局/场景构成/物件功能）与业界口径一致且互补；47.6b 条款可吸收业界细分子项（漂浮/比例失当/不可能重叠/物件融合）作判据示例。来源锚：Medium 实用 QA checklist（nathanli200011）、SEOPix AI Image QC Pass、VAIL Checklist PDF、GIJN 指南、Kellogg Insight/Quartz（解剖面）、AGIDefect-4K（arXiv 2608.20713，层级缺陷标注数据集）。
