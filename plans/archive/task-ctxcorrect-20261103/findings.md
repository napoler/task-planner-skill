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
- R1 触发面一：用户明确否定/指出错误 → 主动整理上下文与历史文档（缺陷记录不继续污染后续工作）
- R2 交付层：该整理机制固化为一个专业技能（本仓新增），在需要的地方触发
- R3 触发面二：Agent 自主执行发现前后文矛盾 → 同触发
- R4 接线层：改造相关技能步骤（task-planner 用户指令处理 C 类/Rule 31 衔接/Rule 65 步骤5）
- 约束：文本优先档（§四.6，零新增机器守卫/自测脚本）；append-only 载体（user-session-log/ledger）禁改写；写入最小化（既有条款原文零改动，纯增量接线）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| 纪律域规则文风体例（31/32/65/95.6 段） | skills/task-discipline/references/critical-rules-discipline.md:70-105/334-348/628 | 是（主进程 Read，Explore 拒派接管） | Research Findings §机制缺口矩阵 |
| 纪元级联判例（1-94→1-97 锁步面） | 用户记忆 task-v195/task-l0lite；实测=全仓 grep | 是（grep 实测） | Research Findings §级联面清单 |
| 同族技能体例（frontmatter 契约） | skills/task-drift-guard/SKILL.md | 是（触发条件段） | Research Findings §体例参照 |
| 用户宪法 §四.6/§八 | /home/terry/.zcode/AGENTS.md | 是（会话注入） | Technical Decisions |

## Research Findings

### 机制缺口矩阵（P1-S1；Explore 两次 provider 拒派→主进程只读接管，判例=progress [research]/Errors 行）
| 既有机制 | 所在 | 触发面 | 覆盖「否定→记录整理」？ | 缺口结论 |
|---|---|---|---|---|
| Rule 31 错误学习闭环（31.1 触发①-⑤/31.2 四维归因/31.3 修正路由/31.4 沉淀/31.5 消费侧） | critical-rules-discipline.md:70-95 | 用户指出错误 | 部分 | 31.3 已有「数据源过时→旧值标 superseded（29.2a）」+修 task_plan/findings，但=事件级单点修；31 定位=错→析→修→防归因主链，记录面整理只是其 31.3 一个分支动作 |
| Rule 32 用户否决与禁令追踪 | :97-105 | 用户否决方案 | 部分 | 管方案禁令登记+提方案前必查（防倒退重提），不管被否方案已污染的历史记录整理 |
| Rule 65 周期性回顾与前后对照 | :334-348 | 每 8 次工具调用定时 | 部分 | 65.2 步骤4-5「前后对照发现矛盾→自动纠正+报告用户」=自主矛盾触发前身，但纠正=单点，无历史文档面枚举与留痕 |
| Rule 95.6 复盘锚 | :628 | 非必要暂停事件 | 不重叠 | 仅互引 |
| task-drift-guard 偏移三态 | skills/task-drift-guard/ | 周期/用户口令 | 不重叠（偏移=方向偏离） | 仅互引 |
| meta-corrector agent（用户级） | ~/.zcode/agents/ | 同法≥2 次失败 | 不重叠（死循环纠偏） | 仅互引 |

**结论**：无既有机制专职覆盖「否定/矛盾触发→上下文与历史文档整理」；新建独立技能 `context-corrector` 不违反 Rule 82（管辖面已逐条枚举互斥，非回潮非镜像）。

### 级联面清单（P1-S2；全仓 grep 实测锚，P3 执行前复核）
| 锚 | 位置（file:line） | 现状 | 目标 |
|---|---|---|---|
| 「Rules 1-97 全集索引」 | skills/task-planner/SKILL.md:9 | 1-97 | 1-98 |
| 「Rules 1-97 全集索引：核心在位 14 条…其余 80 条…纪律域列表（…95,97）」 | skills/task-planner/SKILL.md:210 | 1-97/80 条 | 1-98/81 条/列表补 98 |
| 卫星路由索引表 task-discipline 行 | skills/task-planner/references/critical-rules.md:191 起 | Rule 列表止于 97 | 补 98 |
| 卫星路由表 task-discipline 行（Rule 4,6,…,95,97 列表） | skills/task-planner/SKILL.md（「卫星路由表（11 卫星）」段） | 同上 | 补 98 |
| 仓内「15 技能」字面 | grep 实测=0 命中 | 无 | 无需改（15 计数仅存在于部署叙述/用户记忆） |

### 编号与部署面确认
- 规则号=**98**：plans/.rule-reservations.jsonl 末行=97 landed（task-lazy-escalation-20261102），无 98 预留，Rule 20.6 查重通过；attest 自动登记 reserve，P5 `rule-reserve.sh land 98`
- 部署位：仓内无 install/deploy 脚本（scripts/ 仅 kb-* 三件）；用户级 ~/.zcode/skills 等 4 部署位=历次任务惯例另行授权同步 → 本任务**只落 master 源仓**，部署同步登记为交付遗留（与 v194/v195 判例同口径）
- selftest 面：新增技能+Rule 98=纯文本档，零新增断言（§四.6 opt-in）；P4 全量 run-selftests 若既有纪元锚炸=锁步更新（级联维护，非新增守卫）

### 体例参照（task-drift-guard SKILL.md）
- frontmatter：name/description（触发词密集）/model/tools 契约；正文=「触发条件（命中任一即调用）」+判定流程+产出形态；98 段文风对齐 31/65/95 的「目标：…判定面=…衔接 Rule …既有条款原文零改动」尾注体例

### S3/S4 技能落盘实证（P2 执行记录，2026-11-03）
- 委派守卫拦主进程 Write 业务文件→改派 general-coder（provider 已恢复，S3/S4 由同一 agent 单文件一次写全，粒度 1f/90l 未超限）
- 产出：worktree 内 `skills/context-corrector/SKILL.md`（99 行 / 3924 字符 / 8165 字节）；frontmatter 三字段 name/description（T1 三判据+T2 三判据+用户口令触发词）/model:haiku
- 主进程 Read 全文复核：六块齐全（定位句/T1+T2 触发判据/SOP 六步 [M]/边界互引 6 行/非目标 3 行/产出形态 4 行）
- VC-1 前置 grep 命中：`^name: context-corrector`=1、`前后文矛盾`=3、`非目标`=1
- 度量子代理回报 `wc -c`=8165（字节）→V-2.2 判定基准统一为 `wc -m`（字符）=3924；原因=CJK 3 字节/字符，字节口径会误判超 5K 推荐值
- 遗留：description 触发词密度是否过密（>15 词）待 P4 alignment-review 口径核对

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 新技能名 `context-corrector`（独立技能，非第 12 卫星） | 与 *-corrector 家族对齐；规则全文仍落 task-discipline（Rule 82 分层：卫星=规则域，技能=执行 SOP 载体，同 error-fix-prompt-forge/todo-skill 先例） |
| 整理 SOP 六步（基线锚定→污染面枚举→处置三分→修正条目→下游阻断→复验清零） | 根源覆盖表五工序 |
| 处置三分=修正当地/标 superseded/授权删除；append-only 载体（user-session-log/ledger）豁免清单 | Rule 80 只写不改 + 宪法 §五 写入最小化 |
| 触发面判据：T1 用户显式（否定措辞/「错/不对/还是不行」/同问题≥2 次）∨ T2 自主（新证据推翻已落盘结论/两记录互斥/执行结果证伪先前假设） | R1/R3 原文 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| Agent(Explore) 派发 provider 连拒 2 次 | 22.3 第⑤档主进程只读接管（grep/Read 限定段），结论已回填本段；执行期 provider 恢复优先补派子代理 |
| task_plan 模板占位 Edit 3 次未命中（编码/内容差异） | 每次先 grep/sed 取实际行文再 Edit |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 用户宪法 §四.6 文本优先铁律+§八 记忆系统「过时记忆更新或删除」条款：/home/terry/.zcode/AGENTS.md
- 同族技能体例参照：skills/task-drift-guard/SKILL.md（frontmatter+触发条件+判定三态结构）
- attest 机检判例（2026-11-03 本任务实操）：check-plan-dispatch 要求每 Phase 各自带 S-unit 表（表随 Phase 段落，非集中尾表）；粒度三值超限=拒锁（120l>100l→拆两步）；attest 二次拒绝面「VC 含可执行验证命令」校验读的是 **verification.md** 每条 VC 下的行首 `**Verify command**:` 加粗字段（attest-plan.sh vc-gate，非 task_plan.md VC 表——2026-11-03 P4 对照源码更正，本行初版误写为 task_plan.md）；VC 全部 5 条补齐可执行命令后 PASS

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
（本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
