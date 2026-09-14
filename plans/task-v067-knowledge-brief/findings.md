# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 加强「主动知识对齐」：计划文档阶段就补充知识与资料库（不只列清单）
- 建立「任务知识简略要点」(knowledge-brief) 产物，执行期小模型读 brief 即可稳定执行
- brief 须接入执行链路（材料包/派发），否则沦为孤文件

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- **Phase 1 全链路盘点（seq 01 explore，全文锚点见 subagent-state/01-explore-knowledge.md）**：
  - 模板侧：必要知识储备章节 20/20 模板齐备（task_plan.md:79 + 12 variant + 7 辅助模板），但**纯清单+人工 checkbox，零机械校验**（check-3file-gate/check-complete 均不校验）
  - agent 侧：**plan-writer.md 全文 0 处「必要知识储备」——填写/预写职责空档实锤**（:98-116 产出契约八字段无此项）
  - 材料包链路：subagent_dispatch.md:25-29 已有「知识上下文包」表 = brief 锚点引用最佳插入位；critical-rules 21.2:115/22.4:127/22.4a:128/22.4c:130
  - KQ2 波及面：22.4a 扩四文件需改 check-dispatch.sh 7 处 + selftest-dispatch 5 组断言（T08 行数断言 :102-107 最脆）+ 文档 3 处 + init/check-scope——**高风险**
  - KQ3 依据：brief 纳入 3file-gate 会强制存量 5 文件计划全量补建否则 exit 1 → **破坏存量兼容，否决**
  - 联动雷点：init-session 第 6 文件必须同步 check-scope.sh:66 白名单（否则执行期写 brief 被 scope guard 拦截）+ template-mapping.md:163 白名单表 + template-guide.md:65 grep 锚（现为 20，brief 模板不含该章节标题则计数不变）+ config.json:327 additionalProperties:false（新键必须登记 properties）

#### [sub:02-executor] S1 产出
- templates/knowledge-brief.md 新建五段模板（§1 任务速览/§2 已验证事实/§3 锚点表/§4 易错点+FMEA 兜底指针/§5 S-unit 材料包索引），头部注释声明 init 复制+计划期填写主体，全文 0 命中「## 📚 必要知识储备」（grep -rl 计数仍=20 不变）
- init-session.sh :91 循环 +knowledge-brief.md；:122 复核 for 列表 +knowledge-brief.md；:133 文案 5/5→6/6；头部注释追加 task-v067 说明
- check-scope.sh:66 白名单 +knowledge-brief.md（功能验证：legacy 哨兵下 knowledge-brief.md exit 0 放行，其他文件 exit 1 拦截，语义正确）
- 联动项登记：check-3file-gate.sh:42 文案 "5 planning files"→"6 planning files"（grep "5 planning files\|5 files" 全仓唯一命中）；tests/smoke.sh 无 5 文件断言（未改）；selftest-*.sh 无 5 文件断言（未改）；init-session.ps1 未改（S-unit scope 未含，非 bash 链路）
- 验收 6/6 全过：bash -n 两脚本过；端到端临时目录 6 文件齐+[init] 6/6；模板 5 段标题齐；grep 必要知识储备 模板=0；check-scope 白名单命中；git status 仅 3 改+1 新增

#### [sub:03-executor] S2 产出
- references/template-mapping.md:163 白名单表 5→6 文件（+knowledge-brief，注明 init-session.sh 建档），行号引用按 worktree 现状修正为 init-session.sh:122 / check-scope.sh:66（原 :62/:59 漂移）
- references/template-guide.md:70-73 新增 §2.5 knowledge-brief.md 条目（+5 行）：第 6 计划文件/五段结构/计划期产出执行期回填/不含 2.4 章节故 grep 锚计数维持 20/白名单 5→6 交叉指针
- templates/knowledge-brief.md L9 注释微修：原「【不含】『必要知识储备章节』标题字样」改为「本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 20」；`grep -c "必要知识储备" templates/knowledge-brief.md` = 0
- 验收 5/5 PASS：两 references grep "knowledge-brief" 各 1 命中；`grep -rl "## 📚 必要知识储备" templates/ | wc -l` = 20；brief 该词 0；S2 diff 仅 3 .md（mapping +1/-1、guide +5、brief 注释 -1/+1）；零脚本/零禁改项触碰
- 证据: subagent-state/03-executor-s2.md（8 字段全量）

#### [sub:04-executor] S3 产出
- critical-rules.md:115 Rule 21.2 行尾追加 brief 沉淀句（五段语义 + 模板 templates/knowledge-brief.md 由 init-session 建档 + 材料包引用 §1-§5 节锚点）；:127 Rule 22.4 九字段「输入」枚举内补「brief 存在时材料包摘要应引用 `<plan-dir>/knowledge-brief.md` 对应节锚点（§1-§5）」；22.4a/22.4c 原文零改动（KQ2 轻量方案）
- subagent_dispatch.md:29 知识上下文包表 +1 行 brief（知识源=`<plan-dir>/knowledge-brief.md`/定位=§1-§5 五段/注入方式=引用对应节锚点+索引节 §5；§5 措辞=「索引节(§5)」与五段定位列自指消歧）
- 验收 5/5 PASS：V1 grep "knowledge-brief" critical-rules.md 命中 :115/:127；V2 git diff 22.4a/22.4c 行零变化；V3 dispatch :29 brief 行存在；V4 git diff --stat S3 恰 2 文件（3 insertions/2 deletions）；V5 纯 .md 无逻辑改动
- 证据: subagent-state/04-executor-s3.md（8 字段全量）

#### [sub:06-executor] S5 产出
- plan-writer.md 三落点：:45 掌握的技能 +knowledge-brief 产出职责（五段 §1-§5 + 禁凭记忆编造 + §5 与 S-unit 输入列互链）；:113 产出契约表 +knowledge_brief 必填行（五段齐备 + §2/§3 各 ≥1 真实条目）；:192 禁止行为 +「brief 缺失或五段空壳禁交付」；frontmatter :4 顺带 +「(+knowledge-brief 任务知识简略要点)」
- 验收 5/5 PASS：grep -c "knowledge-brief\|知识简略要点" = 4（≥3）；契约表新行管道符对齐；frontmatter/验证协议区 diff 核对零破坏；git diff --stat 恰 1 文件（+4/-1）；纯 .md
- 证据: subagent-state/06-executor-s5.md（8 字段全量）

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| （Phase 2 定稿见下节） | |

## Phase 2 设计定稿（2026-09-13 主进程裁定 = S1-S6 材料包源）

### KQ1-KQ4 裁定
- **KQ1 = init-session 第 6 文件** `plans/<task-id>/knowledge-brief.md`（模板 templates/knowledge-brief.md）：避免 task_plan 膨胀（Rule 19.6）；init-session :90 循环/:120 复核/:131 文案 6/6
- **KQ2 = 轻量方案（不扩 22.4a 硬契约）**：brief 路径经 22.4 材料包段 + subagent_dispatch.md 知识上下文包表引用注入（材料包本就是九字段必传项）；22.4a 扩四文件波及 check-dispatch 7 处+selftest 5 组+存量兼容 → 登记为后续独立任务；selftest-dispatch 零波及
- **KQ3 = 不纳入 check-3file-gate**：存量计划兼容优先；brief 存在性由 init-session 建档+plan-writer 产出职责+SKILL.md 流程条款保障；knowledge_brief_enforce 三档纯流程层（enforce 预留）
- **KQ4 = 补流程约束（非硬契约）**：22.4 材料包段补一句「brief 存在时，材料包摘要应引用 brief 对应节锚点」；plan-writer 职责段要求 S-unit 输入列注明 brief 节锚点

### knowledge-brief 五段格式定稿（S1 模板正文骨架）
```
# Knowledge Brief — {task-id}（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。
## §1 任务速览与核心概念
（任务一句话 + 领域术语/概念速查表，每条 ≤1 行）
## §2 已验证关键事实
（表格：事实 | 证据 file:line/URL | 影响;禁止录入未验证推测）
## §3 关键文件锚点表
（表格：路径 | 行号 | ≤10 行摘要;执行期照此定位,禁止凭记忆改文件）
## §4 易错点与禁止假设清单
（编号清单:历史教训/陷阱/禁止动作,含本任务 FMEA RPN>100 项的兜底指针）
## §5 S-unit 材料包索引
（表格:S-unit ID | 应读本 brief 哪节 | 额外材料路径;与 task_plan.md S-unit 表「输入」列互链）
```

### 接入链定稿（含联动文件——变更联动审计 P0）
| # | 文件 | 改动 | S-unit |
|---|------|------|--------|
| 1 | templates/knowledge-brief.md | 新建五段模板 | S1 |
| 2 | scripts/init-session.sh | :90 循环+:120 复核+:131 文案 6/6（模板复制走 copy_template） | S1 |
| 3 | scripts/check-scope.sh | :66 白名单 +knowledge-brief.md（**否则执行期写 brief 被 scope guard 拦截**） | S1 |
| 4 | references/template-mapping.md | :163 白名单表 5→6 文件（顺带修该处行号漂移） | S2 |
| 5 | references/template-guide.md | §2.4 补 brief 说明；:65 grep 锚核对（brief 模板不含「必要知识储备」标题则 20 不变） | S2 |
| 6 | references/critical-rules.md | Rule 21.2 补 brief 锚点句 + 22.4 材料包段补 brief 引用句（不动 22.4a） | S3 |
| 7 | templates/subagent_dispatch.md | :25-29 知识上下文包表 +1 行 brief | S3 |
| 8 | SKILL.md | :509 段强化（清单→采集+提炼产物）+ References +1 指针行，净增 ≤10 | S4 |
| 9 | companion/agents/plan-writer.md | 计划期产出 brief 职责（掌握的技能/产出契约/禁止行为三处落点） | S5 |
| 10 | config.json | +1 键 knowledge_brief_enforce（:81-90 范式，:327 properties 登记） | S6 |
| 11 | scripts/selftest-knowledge-brief.sh | 新建（T1 模板五段存在/T2 init 端到端 6 文件/T3 check-scope 白名单含 brief/T4 SKILL 指针+行数/T5 critical-rules 两处/T6 dispatch 表行/T7 plan-writer 职责/T8 config 键/T9 键名一致/T10 全量锚点 grep） | S6 |
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

#### [sub:07-executor] S6 产出
- **config.json**：skill_collab_enforce 块后插入同构键 `knowledge_brief_enforce`（type string / enum enforce,warn,off / default warn / 三档流程层执行、enforce 语义预留），已登记 properties（:327 additionalProperties:false 合规）；`python3 json.load` 无异常，读到 default=warn
- **SKILL.md :512**：执行期材料包引用行末补开关键指针 `config.json#knowledge_brief_enforce`（T10a 跨文件键名一致前提；S4 净增 ≤10 不受影响，wc -l 513 ≤520）
- **scripts/selftest-knowledge-brief.sh（新建）**：T1-T10 共 16 断言，全 PASS exit 0；结构/style 照抄 selftest-skill-collab.sh（set -u / t() 计数器 / BASH_SOURCE 相对推导 / T9 双路径 python3+grep 降级）
- **T5b 修正记录**：指令预期 `grep "knowledge-brief" check-3file-gate.sh =0` 与 S1 现状冲突（check-3file-gate.sh:42 注释行含 knowledge-brief.md，S1 文案联动 5→6 产物）；按「断言必须对当前实现为真」原则，T5b 锚定为存在性循环首行 `^for f in .*knowledge-brief` 计数=0（KQ3 实质=循环不含 brief，:39 for 行仅含 PLAN_FILE/FINDINGS/PROGRESS）
- **回归**：selftest-dispatch 18/18 exit 0（零波及）；selftest-skill-collab 19/19 exit 0（无回归）
- **scope 合规**：S6 净产出 = config.json(M) + selftest-knowledge-brief.sh(??) 恰 2 处；SKILL.md :512 开关键指针为 S4 落点的行内补全（T10a 硬前提），git status 中 SKILL.md 的 M 状态已由 S4 变更叠加，未新增文件
