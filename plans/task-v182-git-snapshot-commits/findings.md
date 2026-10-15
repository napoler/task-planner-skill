# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1 [手段] 优化当前项目技能（task-planner）→ 载体=新增 Rule 90 增量条款
- R2 [目标] 使用前/使用后 Git 备份版本，确保可恢复可控 → 90.1 首快照 + 90.2 尾提交
- R3 [目标] 开始和结尾各做一次 Git 提交（两次提交）→ 90.1+90.2 双锚；本任务 dogfood（VC-6）
- R4 [目标] 合并等类似操作的合理性 → 90.3（merge --no-ff/并集解/消息规范）
- R5 [目标] 所有需管理数据有效管理 → 90.4（计划簿记/归档/台账随首尾提交入库）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **[计划期侦察] 规则落点与范式**：Rule 85-89 五条先例全落 `skills/task-discipline/references/critical-rules-discipline.md`（文件 562 行；header 形态 `### NN 标题（P0 — task-vNNN，目标…判定面…衔接…，既有条款原文零改动）`+建制段+子条+机制段）；Rule 89 段=551-562 行，追加锚=562 行末（file:line 实证）。
- **[计划期侦察] 级联面清点**：v181 先例（git show 188050b --stat）仅改 2 文件=discipline 正文+task-planner/SKILL.md；本次另含 task-discipline/SKILL.md:24/:80 与 critical-rules.md:182 两处索引（"1-89"字面 ×5 处于 SKILL.md:9/175/217 等）；计数口径「其余 75 条」→76、「41 条规则全文」→42。
- **[计划期侦察] 纪元锚分布**：`1-8[0-9]`×52、`1-8[0134]`×21、`'1-89'`×1，分布 20 个 selftest 脚本（grep 实证清单见 task_plan S3 行）；SKILL.md "1-89"→"1-90" 后这些锚将失配——记忆判例「1-90 会再炸一次」成立，须实跑→按 FAIL 清单放宽→复跑（selftest-absorption-discipline.sh:78-85 演进注释=放宽范式先例）。
- **[计划期侦察] 在途任务协调（§6.1 三查）**：在途 task-defect-rrv13-dg12-false-pass 持有 3 个未提交 selftest 文件（decision-grading/registry.tsv/report-reviewability，今晨 05:44 mtime，progress 缺失疑似中断）；**落点零交集**实证=3 文件 grep 纪元锚族=0 命中；处置=知悉不碰不排队不代管（Rule 88.2①）。遗留 wt/task-v168-machine-parked 分支=他域遗留知悉不碰。
- **[计划期侦察] Rule 90 空闲**：`rule-reserve.sh check 90`→free；台账尾部 87/88/89 均 landed（plans/.rule-reservations.jsonl tail 实证）。
- **[计划期侦察] 分工面**：Rule 27=Phase 级提交门控（:200-209）；worktree-isolation §6.3=协调态（预留行/簿记）收口随行提交；新 Rule 90=任务级首尾两端快照——三分工不重叠，90.5 衔接句按此写。plans/ 目录 git 跟踪态=已入库（git ls-files plans/ | wc -l=2715，仅运行态 .gitignore），首提交把计划入库有先例可循（v181 .plan-attestation/findings/progress 均跟踪）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| Rule 90 六子条结构=90.1 首快照/90.2 尾提交/90.3 合并合理性/90.4 数据管理/90.5 衔接分工/90.6 机制段 | 与 85-89 范式同构（总纲→细则→衔接→机制）；90.6 声明 L0-T opt-in 零脚本 |
| 首快照语义=「确保基线存在」而非「无条件制造空提交」：工作区干净→登记 HEAD 为基线锚；有未提交变更→先落基线提交 | git 空提交无恢复价值；语义对齐用户「可恢复」本意；worktree 场景首锚=创建前主仓干净+worktree 首笔 feat 提交 |
| 锚放宽策略=实跑驱动（跑全集→FAIL 清单→逐 site 放宽）而非盲改正则 | 锚有正/负样本双向语义（absorption-discipline.sh:82 负样本判例），盲改可能破坏「不命中」断言 |

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
