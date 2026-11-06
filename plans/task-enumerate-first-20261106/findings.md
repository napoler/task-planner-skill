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
- R1: 素材集合可枚举（几十个）时关键词盲搜致漏检→错误决定，须纠正（见 user-session-log #1 逐字）
- R2: 纠正形态=ls 全量枚举后从中选择匹配；制度层交付（规则条款），非修单次现场

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| critical-rules-discipline.md（Rule 105 载体现状） | skills/task-discipline/references/critical-rules-discipline.md（705 行，止于 Rule 102 @694-705） | ☑ | §调研结论·节 A/C |
| SKILL.md 全集索引与路由 | skills/task-planner/SKILL.md（281 行；:9/:222/:265 计数行） | ☑ | §调研结论·节 B |
| selftest-registry.tsv 契约 | skills/task-planner/scripts/selftest-registry.tsv（tab 4 列 96 数据行） | ☑ | §调研结论·节 B4 |
| 用户判例原文 | user-session-log.md #1 | ☑ | §Requirements |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 调研结论（Phase 1 S1 · Explore agent_fd858b8e · checkpoint=subagent-state/01-explore-enumerate-first.md · 2026-11-06）

**节 A — Rule 105 为空白区（确认无 Rule 82 镜像风险）**：
- 关键词族 10 词全仓 grep：`全量枚举/盲搜/搜索面/命名族/ls 命令/关键词检索/没搜到` 全零命中
- 最近邻 3 条款均不覆盖 105 核心面：Rule 35（discipline:109-115，能力否定查证「我没找到≠不存在」，对象=API/CLI 能力非本地小集合检索方式）、Rule 63.2（research:32，本地检索手段=Grep/Read 未禁盲搜）、Rule 75.15①（research:42-82，本地盘点未规定枚举方式）
- 写法建议：引 35/63.2①/75.15① 不重述，只立「枚举优先+零命中回退」本体；交叉锚 100.6（discipline:681，trash/ 检索排除）

**节 B — 级联锚面清单（104→105，主仓抽查复核吻合）**：
1. 纪元字面 `1-104`：仅 skills/task-planner/SKILL.md 3 处（:9/:222/:265）+「其余 87 条」2 处（:9/:222→88 条）；scripts/ 零命中
2. 宽锚：29 个 selftest 已预放宽 11x 窗（`1-(8[0-9]|9[0-9]|10[0-9]|11[0-9])`）→ **1-105 落窗内，selftest 脚本断言零改动**；`其余 [89][0-9] 条` 正则（anti-deferral:89/subagent-activation:68）覆盖 88
3. SKILL.md 路由行：:17(frontmatter)/:209(task-discipline 行)/:211(research 行)/:255(指针段) 依域判定追加 105
4. registry：tab 4 列（script/domain/trigger_scenarios/dep_anchors）96 数据行，末行 selftest-file-disposal.sh；无纪元断言
5. BP-08 钉：selftest-batch-pilot.sh:66（≤285，实值 281，margin 4）→ 同址改写零净增行则零改动
6. 卫星侧：discipline 文件尾（Rule 102 之后）新增 `### 105` + task-discipline/SKILL.md 规则索引表 +1 行

**节 C — 归属判定：task-discipline（执行纪律域）**：
- 依据 4 条（checkpoint 详）：discipline 域=「所有执行期纪律」兜底（SKILL.md:12-16）；research 域自述排除「纯本地」（SKILL.md:4）；105 最近邻=Rule 35/60 均在 discipline；discipline 域 98-102 连续五号同为用户执行卫生类
- research 侧可加 63.2① 交叉指认句（可选 L0-T）

**自审遗留（落地时处理）**：①「其余 87 条→88」按「14 核心+88 非核心=104 有效号+3 废弃号(77/78/79)」复核 ② discipline/SKILL.md 规则索引表 105 行照 102 行格式抄写

### Rule 105 设计定稿（Phase 2 · 主进程 · 2026-11-06）

**条款全文（蓝本，executor 落地时逐字转录进 discipline 文件尾 Rule 102 之后；段标题形态照既有 `### 103 双轮质检…` 范式）**：

```markdown
### 105 可枚举集合全量枚举优先纪律（ls-first，P0 — task-enumerate-first-20261106，2026-11-06）

> **Why（判例锚 user-session-log task-enumerate-first-20261106 #1，用户裁决「必须进行纠正 这种完全是因小失大」）**：素材命名全集仅几十个（候选集合可枚举），执行体却用「全库搜『装备车/二层/飞桥/帘/天幕』命名族」关键词检索做匹配——关键词族选错（搜索面窄）→漏掉用户点名的合规件→推出错误 asset-first 决定。关键词检索在可枚举小集合上无谓引入漏检风险。本条把「候选集合可枚举时怎么选检索方式」从模型临场自判改为显式纪律；与 Rule 35（能力否定查证）/63.2①（本地检索手段）/75.15①（本地盘点）互补不重叠——那些条款管「结论口径/是否检索/盘点义务」，本条管「检索动作在可枚举集合上的执行方式」。

105.1 **全量枚举优先判据（P0）**：做存在性判断/匹配选择的对象集合可全量枚举（判据=单层目录或名称清单 ≤200 项，如素材库/资产目录/命名族/配置项清单）时，**必须先 ls（或等价全量列出：ls/find -maxdepth 1/目录列表 Read）取得完整清单，在完整清单上选择匹配**；禁止用关键词检索（grep/find -name/Glob pattern/模糊搜）替代全量枚举做该判断。判断顺序=先枚举后匹配；枚举面排除 trash/（Rule 100.6）。

105.2 **零命中≠不存在（回退复核义务，P0）**：关键词检索仅限不可枚举大集合的预过滤；凡以「没搜到/搜不到 X」支持「X 不存在/缺失/无合规件」类结论前，**必须回退全量枚举复核检索面**（ls 候选集合全集，人工目检清单），复核仍无才可下否定结论（否定结论上报口径仍受 Rule 35 约束）。

105.3 **缺陷信号条款（禁错误方向修复）**：出现「搜索面太窄/漏了 X/换个关键词再搜」类自我归因时，判定=检索策略缺陷信号而非关键词没选好；**纠正动作=回退全量枚举（105.2），禁止扩大关键词族继续盲搜**（Rule 22.3 同法 ≥2 次失败禁令在检索面同理适用）。

105.4 **适用边界**：本条管「可枚举小集合的匹配/存在性判断」；大仓代码搜索/海量日志排查（不可枚举集合）仍走关键词检索（Explore 路由/Rule 63.2 检索链），本条不适用。边界判据=候选集合能否一次列出完整清单（≤200 项经验值，可按目录实况放宽但须能一屏人工目检）。

105.5 **反例锚（判例存档）**：2026-11-06 用户判例——素材命名全集几十个，执行体用「装备车/二层/飞桥/帘/天幕」命名族关键词全库搜索，漏掉用户点名的合规件，归因「搜索面太窄」后错误决定 asset-first 路线；正确动作=ls 素材目录全量列出，在完整清单上选择匹配。
```

**selftest-enumerate-first.sh 断言清单（≥7 条）**：
1. EN-01 规则文档含行首 `### 105 ` 段标题
2. EN-02 105.1-105.5 五个子条行首锚（`^105\.[1-5] `）各命中一次
3. EN-03 关键判据词计数：`全量枚举`≥4（2026-11-06 修正：定稿时 ≥5 为未数词频的拍脑袋值，条款全文实际 4 处已覆盖判据面，阈值按文本实况校准）、`零命中`≥1、`回退`≥1、`ls`≥2
4. EN-04 反例锚：`装备车` 或 `命名族` 在位于 105.5 段
5. EN-05 交叉引：`Rule 35`、`100.6` 引用在位
6. EN-06 SKILL.md 级联：`1-105` ≥3 处命中 + 路由行（discipline 枚举）含 `105`
7. EN-07 负断言：SKILL.md 内 `1-104` 字面残留=0

**级联执行清单（S3 输入，源自 Phase 1 节 B）**：SKILL.md:9（1-104→1-105+87→88）/ :222（同+括注追加 Rule 105 域归属句）/ :265（1-104→1-105）/ :209（discipline 路由行追加 ,105）/ :255（指针段追加 105 表述）/ task-discipline/SKILL.md 规则索引表 +1 行（照 102 行格式）/ discipline 文件尾新增 ### 105。BP-08 margin 4 行内全部同址改写零净增。

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
