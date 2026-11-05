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

## Research Findings（2026-11-05 Phase 1 调研收口）

**执行体**：Explore（haiku，1028k tokens/38 工具调用/460s），检查点=`subagent-state/01-explore-userlog.md`（主进程 Read 复核通过）

**核心结论**：Rule 80（critical-rules.md L144-156）7 子条中 6 条纯写入纪律，全体系唯一读触发=80.4（仅会话恢复场景）；80.7"回溯对照"仅为设计目的描述无强制读取动作。用户抱怨场景对应的决策面全部无读档要求。

**缺口清单（按严重度）**：
1. [P0] AskUserQuestion/裁决上抛前不读专档（Rule 44/86.1/95/72）——用户抱怨直接成因
2. [P0] Rule 102.0 反思门不读专档（L693-704 + hook 三处 note 文案）
3. [P1] 交付总结不读专档（51.3 数据源=task_plan R 条目转译面；仅 51.11 让步锚读专档）
4. [P1] 子代理派发需求锚只引 R 条目转译，子代理感知不到专档原话（subagent_dispatch.md L19-20）——与 drift-checker CA-7（已读专档）双源断链
5. [P2] 缺统一读取纪律子条 80.8（读取面仅 80.4+drift-checker+D1 目标绑定+G1b 四弱读点）

**实盘佐证**：全仓 20+ 份实盘专档，唯一确证读取面=drift-checker 检查点 3 例；主进程在决策/上抛/交付前读档对照的实盘记录=零。

## 设计稿（2026-11-05 Phase 2 设计定稿）

**统一锚=新增 Rule 80.8「决策前读取纪律」**，五决策点读取面：

- **80.8 ①** 上抛裁决前（AskUserQuestion/暂停请示前）：先读专档最近条目，若问题已有用户原话裁决→按原话执行禁上抛（R1 直接封堵）
- **80.8 ②** 新指令反思门（102.0 第⑤问）：判定 D/A/B/C/E 时对照专档既有条目——新指令与既有原话冲突/已被裁决时以原话为准
- **80.8 ③** 完成声称与交付前（51.3 双锚）：需求覆盖核对=task_plan R 条目+专档同号条目双锚（80.4 权威序：原话面 > 转译面）
- **80.8 ④** 子代理派发需求锚双锚（subagent_dispatch 需求锚字段带专档条目 #N）
- **80.8 ⑤** 周期对照（3f 每 S-unit 对照时纳入专档尾部原话，主进程 Read 专档尾部 ≤30 行）
- 会话恢复=80.4 既有，重申不新增

**文件落点**（8 文件增量修改）：
1. `skills/task-planner/references/critical-rules.md`：追加 80.8（五决策点）+51.3 双锚升级
2. `skills/task-discipline/references/critical-rules-discipline.md`：95.4 增第④问+102.0 增第⑤问+86.1 前置读档门
3. `skills/task-planner/SKILL.md`：G9 扩展读取面自查项+Rule 80 bullet 更新
4. `skills/task-planner/templates/user-session-log.md`：增「消费点」区块（五决策点读取触发点表）
5. `skills/task-planner/templates/delivery-summary.md`：需求覆盖核对表增专档条目列
6. `skills/task-planner/templates/subagent_dispatch.md`：需求锚字段双锚
7. `skills/task-planner/scripts/selftest-session-log.sh`：SL 断言扩展（80.8 锚+模板双锚锚）
8. hook 脚本文案（S6 可选轮次，用户裁决）：UserPromptSubmit note 追加对照提示句

**关键设计决策**：
- 80.8 为子条非新 Rule（无 new_rule 声明）；不动 80.1-80.7（不变量）
- 「定时回顾」的承载=3f 周期性对照扩展（既有节奏机制纳入专档，零新 hook/零新脚本，文本优先）
- 51.3 双锚权威序：专档原话面 > task_plan R 条目转译面（80.4 延伸，防转译冒充原话）
