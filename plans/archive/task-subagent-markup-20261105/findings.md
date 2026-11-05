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

## Research Findings — Phase 1 现状盘点（2026-11-05，来源=Explore 检查点 subagent-state/01-inventory.md）

**既有标注载体（机制存在但颗粒度粗）**：
- 计划期：task_plan 模板 Phase 级 `**Executor:**` 字段 + S-unit 表「执行体(subagent_type(model))」列（默认值「继承」）；机器面=check-plan-dispatch.sh（执行体空=拒锁/粒度超限=拒锁）
- 执行期：check-delegation.sh pretool **只拦主进程写动作**（读/调研/检查类零拦截面——用户观察的结构性缺口证据）
- 终验统计：stats 只扫 Phase 级 Executor 行，不消费 S-unit 执行体列

**Rule 96 七类触发**（critical-rules-dispatch.md:194-204，A1-A7）：制定计划/调研分析/多文件搜索定位/大文件长输出消化/验证审查/批量既定步骤/独立创作单元——全部"命中即默认派子代理"，主进程直做=三条窄白名单；**判定面=LLM 行为零机器门**（:188 题注自述）。

**缺口 12 条（G1-G12，四维度）**：
- 计划期：G1/G2/G3——S-unit 表无「96 类别命中」列；check-plan-dispatch 不校验"命中 A1-A7 但执行体=主进程"
- 执行期：G4/G5/G6——SKILL.md 2.5 委派检查点对 96/52 全指针化（:250/:270），七类清单+白名单须跨文件跳读；无逐 S-unit 激活留痕
- 默认值语义：G7/G8/G9——例外登记只认 ①-⑥ 编号；96.1 窄白名单无编号 token；无"默认建议派子代理"软档（只有硬拦+WARN 两极）
- 弹性微调：G10/G11/G12——例外出口与违规判定口径不一；96.5 指标回填无终验消费方

**selftest 锚点**：13 个相关脚本全断言"条款在位"，不断言"逐行标注面存在"；selftest-subagent-activation.sh SA-01..15 为主要锚族。

## Research Findings — Phase 3 落地（2026-11-05，S1/S2/S3+S1-fix 四轮派发）
- **S1 dispatch 载体**：首轮插入位置致编号乱序（96→104→103）+二级标题违三级惯例 → S1-fix 修正轮重定位至 103 段后（行 276 起）+形态改 `### 104 ` 主标题+正文行子条 `104.x **`；验证 grep 全过（主条=1/旧形态=0/子条=6/markup-exempt=2）
- **S2 SKILL 载体**：2.5 委派检查点后插 7 行就地速查表（行 82-88），缩进对齐，grep=1
- **S3 模板载体**：S-unit 表头加「96 类别」列+104.3 注释行（grep=2）
- **教训**：规则段载体插入前先 grep 既有标题层级惯例（### N vs ## Rule N）与编号顺序——首轮材料包未给形态锚导致返工一轮

## Issues Encountered — S1-fix 自报失实（2026-11-05）
- **Issue**: S1-fix 子代理自报「grep -c '^## Rule 104' = 0」但磁盘实测=1（旧区块残留 43 行：主标题+104.1~104.5 标题被拦腰截断残留）
- **Resolution**: 主进程按兜底链第 4 档接管（连续两轮派发失败换道）——Read 218-292 精确定位残留区间（222-263）→ python 按行号断言式删除 → 四锚复验全过（旧=0/新主条=1/子条=6/markup-exempt=3，顺序 96→103→104）
- **Prevention**: 子代理自报 grep 结果必须主进程磁盘重跑交叉验证（判例 [[subagent-verifier-fabricated-output-20261103]] 第 2 次实证）；区块级删除动作的验收锚必须含「旧形态=0」负断言
