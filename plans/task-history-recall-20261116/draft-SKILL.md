---
name: plan-history-recall
model: sonnet
description: 跨任务历史经验挖掘——从 plans/ 文档体系（含 archive/）+git 提交历史按需挖掘过往任务经验，产出证据锚齐全的简报供规划参考。触发：用户要求梳理过往任务/经验/教训（「梳理一下之前做过的 X」「之前有没有做过类似的」）；task-planner L1+ 规划期同类改造/既有机制扩展/曾犯错领域建议触发。不做中断恢复（plan-resume）、不做在途账本（progress-tracker）、不做外部调研缓存（research-kb）、不做全量沉淀库。
---

# plan-history-recall — 跨任务历史经验挖掘

从本仓 plans/ 计划档案（含 plans/archive/）+ git 提交历史，按主题挖掘过往任务「做了什么/什么成功/什么犯错」，产出可落盘的经验简报，作为后续任务规划的经验参考。

## 何时触发

- **显式**：用户要求梳理过往相关任务/经验/教训/成败。
- **建议**（task-planner L1+ 规划期指针）：新任务主题属同类改造、既有机制扩展、曾犯错领域。
- **不触发**：L0-T/mini 纯新增任务；主题与历史无关。

## 不做的事

- 只读纪律：禁写任何 plans/ 历史任务文件（唯一写入=§落盘 的消费方产物）。
- 不做中断恢复/续推（→ plan-resume）；不做在途进度账本（→ progress-tracker）；
  不做外部网络调研缓存（→ research-kb）；不做 knowledge/ 检索（→ scripts/kb-search.sh）。
- 不做全量沉淀库/增量索引脚本（YAGNI，design §9）。

## 工作流（五步）

### 1 输入解析
输入=主题/问题（必需）+范围（可选，默认 `$PWD/plans/` 含 `plans/archive/`）。

### 2 路由（主进程）
- 通道 A：grep INDEX.md 主表（Task ID|Status|Goal 列）匹配主题关键词。
- 通道 B：`git log --oneline --grep "<关键词>"` 反查 subject 括号内 task-id。
- 两路并集 → 候选任务清单 **候选任务 ≤8**（按相关性排序；排除项留一句理由，禁盲搜漏合规件）。

### 3 并行挖掘派发（history-miner 伴飞子代理）
- **≤3 并行**，**每代理 ≤3 任务**；超 8 个候选 → 分轮。
- 派发材料包（Rule 35.3）：任务目录清单（绝对路径）+主题+卡片落盘路径+八字段返回要求。
- 子代理逐任务读五文档（task_plan/findings/progress/user-session-log/knowledge-brief，限行数）+
  `git log --grep "<task-id>"` 提交面 → 按 references/experience-card-schema.md 产卡落盘。

### 4 综合简报（主进程）
按 references/brief-template.md 填充，**简报 ≤150 行**：
跨任务结论四维（成功模式/失败教训频次与根因聚类/用户偏好演变/可复用资产）；
每条结论必须带证据锚（卡路径+源文件:行号）；无锚结论禁写，查不到的字段如实标「未查到」。

### 5 落盘
- 任务上下文内（规划期）：`<plans>/<消费任务id>/history-recall/cards/<task-id>.md` + `<plans>/<消费任务id>/history-brief.md`
- 独立咨询：`plans/history-recall/<topic>-<date>/`（cards/ + brief.md）

## 失败兜底

| 失败 | 兜底 |
|------|------|
| INDEX.md 缺失/新项目空仓 | 降级纯 `git log --grep` 扫描+简报注明降级原因 |
| history-miner 失败 | 重派 1 次 → 仍败主进程直读（≤2 任务）并在简报留痕 |
| 候选零命中 | 如实产出「无相关历史」简报+已查维度清单（禁编造相关性） |
| 子代理产出存疑 | 主进程盘上抽查 ≥3 条证据锚（路径+行号命中才采信；虚假=记 Error Log 并重派） |

## 成本护栏（硬数字）

候选任务 ≤8；history-miner ≤3 并行 × 每代理 ≤3 任务；简报 ≤150 行；经验卡 ≤60 行/卡。

## 与其他 skill 的关系

| 技能 | 边界 |
|------|------|
| plan-resume | 它管中断计划续推（恢复执行视角）；本技能只读提炼经验，不推进任何计划 |
| progress-tracker | 它管项目级在途/完成事实账本；本技能挖过程经验（成败/教训/偏好） |
| research-kb / kb-search.sh | 它们管外部调研缓存与 knowledge/ 域；本技能域=plans/ 档案+git 历史 |
| task-planner Rule 93/84.14 | 单任务执行期召回/收口回读；本技能是跨任务经验层（互补非替代） |

## 参考

- 设计与调研：plans/task-history-recall-20261116/{design.md,findings.md}
- 卡契约：references/experience-card-schema.md；简报契约：references/brief-template.md
- 派发执行体：skills/task-planner/companion/agents/history-miner.md（伴飞，只读+卡落盘）
