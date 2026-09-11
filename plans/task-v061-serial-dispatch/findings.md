# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户原话（2026-09-12）：「对当前 skill 进行优化，当前解决问题时候存在严重的违背小步快跑原则，还有就是违背串行原则，我发现当前执行任务并行操作，只为了追求速度导致质量极具降低……我希望可以一个个串行，并行只会将错误不断的放大」
- 拆解：① 废除 skill 内全部"并行派发"条款；② 确立串行派发铁律（一次一个、验收通过再派下一个）；③ 强化小步快跑（失败拆细先于一切补救）；④ 机制化守卫（不只靠文本自觉）；⑤ selftest + 部署对账（v059/v060 同构质量基线）
- 实证会话：sess_1316c7f8-6ca3-4dd5-8afe-4f0758b9a276

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| memory: task-planner-repo-deploy-flow.md | `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-repo-deploy-flow.md` | ☑(索引) | 9 位部署拓扑/重部署 SOP → Phase 7 |
| memory: fine-grained-dispatch-philosophy / split-before-upgrade-small-steps | 同目录 memory/ | ☑(索引) | 小步快跑既有条款 Rule 21.1b/22.3②/22.4⑨/22.6 → Phase 2 |
| 仓内并行条款盘点 | Explore 子代理 agent_83cae444 报告 | ☑ | 「并行条款盘点（6 处）」段 |
| 会话取证 sess_1316c7f8 | ReadSessionContext(lite) | ☑ | 「会话取证」段 |
| check-dispatch.sh 现行实现 | `skills/task-planner/scripts/check-dispatch.sh` | ☐ Phase 5 开工前必读 | 串行守卫设计段 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 会话取证 sess_1316c7f8（并行 → 质量崩塌实证，2026-09-12 ReadSessionContext）
- 并行规模：16 个编辑批同时跑 + 语义审查×2 并行 + 补研 6 篇×5 搜索并行 + 擅自扩权 4 个并行调研批（被用户当场取消，零结果）
- 质量后果：1051 悬空代词 / 440 断裂句 / 357 双点标点 / 560 从句误接 / 296 断裂+德语残留 / 485+296 品牌误计；548 主题跑偏成划船机→二次重写；子代理 marker 写错目录；两轮补研子代理零产出需主进程接管 48 次搜索；并行审查通过后 gate/e2e 仍出 5 问题
- 用户反馈链（msg 289-304）：「为什么这么快…质量不高？」→「方向完全错误」→「我要求的是修改 Skill 你竟然恶意偏移」→「严重惰性，只流于形式优化」→「一直做已明确被淘汰的 Meta」
- 佐证：plan-compass hook 连续告警 findings/progress 未回填（Rule 19.7），并行推进时三文件罗盘失守

### 并行条款盘点（6 处，Explore agent_83cae444，2026-09-12）
- **Phase 3 落地回填（主进程复核 sub:3-1/sub:3-2，05:33）**：SKILL.md 6 处收口（:84 严格串行引 21.4；:135 fan-out 串行逐个；:240 依次消费；:244 串行逐个派发 2A→2B→2C；:250 互不阻塞→按 21.4 串行；:272 摘要行补"派发严格串行"）；CLAUDE.md:33 目录树"并行同步协议"→"串行同步协议"。证据：worktree diff（SKILL.md +6/-6、CLAUDE.md +1/-1），残留 grep exit=1。
- **Phase 4 落地回填（主进程复核 sub:4-1，05:36）**：completion-gate.md「并行任务同步」整节改为「多任务同步（串行）」：S-unit 串行链（验证 complete 才派下一个）+ "互不依赖不构成并行理由"(21.4) + 失败停止派发走 22.3（拆细先于升档）。证据：worktree diff +4/-4，残留 grep 0。条款层（4 文档）至此全部收口。
- **Code Review Gate 回填（sub#9 code-reviewer，05:58）**：结论 APPROVED（confidence HIGH，10 组定向实验 + selftest 三连跑）。findings：[P1] selftest run_case 继承外层 ENFORCE=off 时 T05 假红（gate 流水线命中，需 warn 档硬覆盖）；[P2] check-dispatch.sh:244 锁写 permission denied 由父 shell 泄漏 stderr（rc 仍 0，非静默）；[P2] posttooluse 跨会话误删锁理论窗口（120s TTL 自愈）；[P3] 时钟回拨钳 age=0 判占用（保守可接受）；[P3] TS run_case 嵌套可读性。负结果：并发 12 路竞态无漏检、缺项路径不写锁、fail-open 完备、stdout 零污染、断言无恒真。处置：P1+P2(stderr)+注释补充 → 串行修复轮派发 #10；P2 跨会话窗口注释标注即可；P3 记录不阻断。
- **Phase 2 落地回填（主进程复核 sub:2-1，05:29）**：critical-rules.md 3 处已改——:117 Rule 21.4 升格串行铁律（至多 1 活跃子代理/后台占槽/Why=_sess_1316c7f8 实证_/唯一例外=用户显式授权/违规走 Rule 26）；:127 22.4a 改「各子代理只写自己的锚点(派发本身仍按 21.4 串行)」；:168 25.2 改「所有 S-unit 严格串行派发…互不依赖不构成并行理由」。证据：worktree git diff 3 hunks(@114/@124/@165)，残留 grep exit=1（零残留）。子代理返回 8 字段 done/4PASS/HIGH，主进程 Read diff 复核一致。
| # | 位置 | 现文要点 | 定性 |
|---|------|---------|------|
| 1 | `skills/task-planner/SKILL.md:84` | 执行循环 2.5 委派检查点「逐 S-unit…互不依赖者可并行」 | 鼓励并行 |
| 2 | `skills/task-planner/SKILL.md:135` | Chain fan-out「多个下游 Block 同时 pending → 并行派发」 | 鼓励并行 |
| 3 | `skills/task-planner/SKILL.md:238-244` | fan-out 节「同时派发 Block 2A/2B/2C」「互不阻塞」 | 鼓励并行 |
| 4 | `skills/task-planner/references/critical-rules.md:168` | Rule 25.2「互不依赖…的 S-unit 可同一消息并行派发」（v056 后补例外句） | 鼓励并行·首改 |
| 5 | `skills/task-planner/references/critical-rules.md:127` | Rule 22.4a「并行子代理各写各锚点」 | 允许并行措辞 |
| 6 | `skills/task-planner/references/completion-gate.md:19-28` | 「Wave 1(并行)→全部验证→Wave 2(串行)」 | Wave 内并行范式 |
- 串行基底：`critical-rules.md:110-117` Rule 21.4「按依赖串行派发，完成一个验收一个…通过才派下一个」——仅限"按依赖"，需升格为无条件
- 无关命中（不改）：SKILL.md:10-11/65/303 与 critical-rules.md:139 的"并行会话"= active-plan-race 会话层互顶，非派发方式；critical-rules.md Rule 23 = 跨任务冲突规避（--runtime 四级），保留；critical-rules.md:210 Rule 27.2"其他并行任务产物"= 提交隔离语境，保留；todo-sync.md:12 / worktree-isolation.md"并行开发"= 会话层，保留
- 机制空白：`check-dispatch.sh` 只校验契约字段（三文件路径+8 字段返回+checkpoint），无任何派发时序/数量校验
- 其他：`CLAUDE.md:33`（仓根）目录树描述「completion-gate.md← 子代理验证 + 并行同步协议」需联动；selftest 5 套件位于 `skills/task-planner/scripts/`（selftest-{dispatch,active-plan,delegation,plan-dispatch,fallback}.sh，v060 基线 90 用例 fail=0）

## 串行铁律设计（v061 — 派发材料包源，Phase 2-6 照此执行）

### A. 条款层精确改法（old → new）
1. **critical-rules.md Rule 21.4**（约 :110-117）现「子任务按依赖串行派发，完成一个验收一个…通过才派下一个」→ 升格为：
   「21.4 **串行派发铁律（P0，2026-09-12 task-v061）**：执行期同一时刻**至多 1 个活跃子代理**——上一 S-unit 完成三证据验收（执行记录/产出 Read 复核/验证证据）之前，**禁止派发下一个** S-unit，无论其是否依赖前序产出；"互不依赖"不构成并行理由。后台派发（run_in_background）视为持续占用串行槽，收取结果前不得派发新 S-unit。Why：并行只在共享全局状态（文件/部署位/分支/同一交付物）下省时，代价是错误跨单元放大——2026-09-12 用户实证（sess_1316c7f8）：16 个编辑批并行 → 千级机械残迹 + 主题跑偏重写 + 零产出子代理。质量优先于速度（Rule 26 同源）。**唯一例外**：用户在当前任务中显式说"可以并行"，须登记 Decisions Made（指令原文+时间）后方可；违规按 Rule 26 降质惩罚映射处置。」
2. **critical-rules.md Rule 25.2**（:168）「…互不依赖（不同文件、无输入引用）的 S-unit 可同一消息并行派发」→「…所有 S-unit 严格串行派发（Rule 21.4 铁律）：一次一个、验收通过再派下一个；"互不依赖"不构成并行理由」
3. **critical-rules.md Rule 22.4a**（:127）「并行子代理各写各锚点」→「各子代理只写自己的锚点文件（派发本身仍按 Rule 21.4 串行）」
4. **SKILL.md:84**「逐 S-unit（22.6 表每行一次，互不依赖者可并行）」→「逐 S-unit（22.6 表每行一次，严格串行：一次一个、验收通过再派下一个 — Rule 21.4）」
5. **SKILL.md:135**「多个下游 Block 同时 pending → 并行派发，全部完成才汇合」→「多个下游 Block 同时 pending → 串行逐个派发（Rule 21.4），全部完成才汇合」
6. **SKILL.md:238-244** fan-out 节「同时派发 Block 2A/2B/2C」→「串行逐个派发 Block 2A→2B→2C（Rule 21.4 铁律，"互不依赖"不构成并行理由）」；「每个 Block 独立执行，互不阻塞」→「每个 Block 独立执行，派发仍按 Rule 21.4 串行」
7. **SKILL.md:272-274** Critical Rules 摘要 Rule 21 行补「串行派发铁律(21.4)」字样
8. **completion-gate.md:19-28** Wave 范式：「Wave 1（并行）→ 全部验证 → Wave 2（串行）」→「每 Wave 内部串行逐个派发（验收一个再派下一个 — Rule 21.4），Wave 间串行接力」
9. **CLAUDE.md:33**（仓根）「子代理验证 + 并行同步协议」→「子代理验证 + Wave 串行同步协议」
- 注：行号为 master 3dc6a1b 快照，执行时以 grep 特征串定位为准，行号漂移不构成偏差。

### B. 机制层设计（check-dispatch.sh 串行槽守卫）
- 锁文件：`<plan-dir>/subagent-state/.dispatch-inflight`，内容 = unix 时间戳 + sid
- PreToolUse(Agent) 路径（check-dispatch.sh 现有入口）：锁存在且 age<120s → 判并行尝试：enforce 档 exit 2（stderr 提示 Rule 21.4 串行铁律 + 锁 age）；warn 档 stderr 警告 exit 0；off 档跳过。无锁或锁陈旧（≥120s，崩溃残留）→ 写入新锁放行
- PostToolUse(Agent) 路径（zcode-posttooluse.sh）：Agent 调用返回后清锁（串行槽释放）
- 已知边界（如实写入注释）：run_in_background 的 Agent 调用 PostToolUse 立即返回即清锁，后台并发不被该守卫捕获 → 由 Rule 21.4 文本条款覆盖（后台视为占用串行槽）
- 兼容性：不改变现有契约字段校验（三文件路径/8 字段/checkpoint）与档位机制；锁路径复用 subagent-state/（已存在目录约定）

### C. selftest 用例设计（selftest-dispatch.sh 追加，风格随既有 T01-T12）
- TS-01 无锁 + enforce → exit 0 且锁已写入
- TS-02 新鲜锁(<120s) + enforce → exit 2 且 stderr 含"串行"
- TS-03 新鲜锁 + warn → exit 0 且 stderr 警告
- TS-04 陈旧锁(≥120s, touch -d) + enforce → exit 0 且锁被刷新
- TS-05 新鲜锁 + off → exit 0
- TS-06 清锁路径调用后锁不存在
- 验收：既有 T01-T12 全过 + TS-01..06 全过，5 套件全量 fail=0

## 联动周全审计（Phase 9 材料包源 — 用户 09-12 指令触发，06:2x）

**根因**：VC-1 特征串清单不含"并行同步"，且联动面只核了 4 个文档——SKILL.md:11/:303 References 表与 :10 目录描述漏网。教训：联动检查必须宽口径（扫所有"并行"字样逐条分类），不能依赖预设关键词清单。

**分类表（宽口径 `grep -rn "并行" skills/task-planner/` 全量 18 命中）**：

| 位置 | 现文要点 | 判定 |
|------|---------|------|
| SKILL.md:10 | examples.md 描述"（…错误恢复/并行任务）" | **失效联动·修**（examples.md 实无并行任务内容，双重失效） |
| SKILL.md:11 | "references/completion-gate.md: 子代理验证 + 并行同步" | **失效联动·修**（该文件已改串行同步，描述未联动） |
| SKILL.md:303 | References 表同句"并行同步" | **失效联动·修**（同上） |
| check-dispatch.sh:217/240 | 守卫自身注释/阻断文案"判并行派发尝试/禁止并行派发" | 合规保留（新守卫语义） |
| completion-gate.md:26 | "互不依赖"不构成并行理由 | 合规保留（新串行条款自身） |
| SKILL.md:92 / critical-rules.md:210 | Rule 27"并行任务产物"（提交隔离语境） | 合规保留 |
| SKILL.md:274 / critical-rules.md:141 | Rule 23 并行任务检测（跨任务冲突规避） | 合规保留 |
| check-conflicts.sh:56 / worktree-isolation.md:3/12/55 | worktree"并行工作/并行开发"隔离语境 | 合规保留 |
| set-active-plan.sh:4/21 | 多会话并行安全（active-plan-race） | 合规保留 |
| todo-sync.md:12 | 多任务并行时用 Task 系统（会话层工具选择） | 合规保留 |
| templates/variant/migration-type.md:22/82 | 迁移双跑（新旧版本并行跑回归） | 合规保留（与子代理派发无关） |
| README.md / companion/ | 0 命中 | 无联动 |
| examples.md | 0 命中（无并行派发示范） | 无联动 |

**修法**：SKILL.md:10 去"/并行任务"；:11 与 :303 "并行同步"→"串行同步"。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 串行为默认且强制,废除全部并行例外（含 v056 补的 25.2 例外句） | 用户 2026-09-12 指令 + sess_1316c7f8 实证并行放大错误;质量优先(Rule 26 同源);唯一例外=用户显式授权 |
| 守卫用 inflight 锁而非"同批调用计数" | PreToolUse 逐调用触发,锁的写入/存在性即串行槽占用信号,无需新增 hook 事件;陈旧阈值 120s 防崩溃残留误拦 |
| 后台并发不纳入守卫捕获范围 | run_in_background 的 PostToolUse 立即返回,锁无法覆盖后台生命周期;文本条款(21.4 后台占槽)覆盖,注释如实标注 |
| code_review: required | 本任务新增 shell 逻辑(守卫+清锁+selftest),按"质量优先于速度"原则过 Code Review Gate |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| （暂无） | |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 实证会话：sess_1316c7f8-6ca3-4dd5-8afe-4f0758b9a276（50 篇文章 SEO 内容优化）
- 同构先例：plans/task-v060-drift-collect/task_plan.md（收编+验证+重部署对账全流程）
- 部署拓扑：memory task-planner-repo-deploy-flow.md（9 位=task-planner×3 + companion×6；另有 plan-writer agent 2 位）

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-（无）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
