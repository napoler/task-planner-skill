# 05 瓶颈总表与三方向优化设计（综合与方案设计 — 动态工作流综合节点）

> 日期：2026-09-27。**v2（批判轮 1 修订版）**：按两位独立批判员意见逐条实证处置后修订——A-2 死代码定性被本节点复现实验证伪（见 §八 处置记录 #1）、C-2 重设计（剔除全部 mtime 信任面）、C-1d 剔除篡改仲裁短路、否决普查修正为 4 条、其余 9 项修订见 §八。全部处置基于本节点实跑证据。
> 输入 = 四份取证（01 派发协议 / 02 守卫hook / 03 简单链路 / 04 复杂链路）+ 上一轮审查报告（plans/task-planner-skill-review/report.md）。
> 本文件职责：任务一（四份取证汇总去重成瓶颈总表）+ 任务二（三方向优化方案簇，Tier A/B 分层）。
> 方法与证据纪律：① 瓶颈条目全部来自四份取证（每条保留其 file:line / 实测命令 / 调用链计数锚），本节点做了转引抽查（见 §五）；② 方案的改动面具体到文件与条款/脚本；③ 每方案与每条 Tier A 项自带「子代理干净上下文验证设计」（用户 2026-09-26 约束⑦）；④ 分层纪律见 §四。
> 本会话实跑记录（非转引）：grep notepad 否决段（仅 task-v083 有 2 条真实否决：无试点批量 / 以速度压缩验证，2026-09-18）；critical-rules.md 裁决行号定位（Rule 14 :54、18.9 :86、18.11 :88、21.4 :122、21.1b :119、22.3 :129、26 :182、28.2 :226、38 :331、32.4 :272）；锚点抽查（zcode-pretooluse.sh:94 `CWD="${PWD}"`、:104 `for other_plan` 循环；check-complete.sh:459 重跑 check-plan-dispatch.sh；zcode-userpromptsubmit.sh:61 attest --verify；init-session.sh:99 `PLAN_TIER="${3:-...}"`；attest-plan.sh:67；check-dispatch.sh:350-376 串行槽锁 age<120s exit 2；check-complete.sh:547-550 mini vc_min=2/vn=1；wc -l 模板 122/49/419 行）。未实跑：selftest 全量、hook 计时复测——所有计时数字转引自取证文件并标注来源。

---

## 一、瓶颈总表（四份取证去重合并，29 条，按 开销频次×影响面 降序）

评分口径：频次 1-5（5=每工具调用级 / 4=每写或每 Phase 级 / 3=每派发或每任务级 / 2=每技能修改或每终验级 / 1=每会话级）；影响面 1-5（5=占墙钟或主上下文大头 / 3=显著 / 1=轻微）。综合分=频次×影响面。同分内按领域聚类排序。「来源领域」= 01派发协议 / 02守卫hook / 03简单链路 / 04复杂链路 / report=上轮审查。回链 = 原取证文件§小节-条号。

| # | 瓶颈 | 频次 | 影响面 | 分 | 来源领域 | 回链 | 关键锚（转引） |
|---|------|-----|-------|----|---------|------|---------------|
| R1 | PreToolUse Rule23 冲突循环 O(N_plans)：每次 Write/Edit 对全部 plans/*/task_plan.md 逐个 5 进程 awk 链，实测循环体 833ms、单次 Edit 439 clone/1329-1403ms；且 :94 用 `CWD="${PWD}"` 忽略 stdin cwd（xtrace 实证 cwd=/tmp 仍扫本仓 37 计划） | 5 | 5 | 25 | 02守卫+03简单+04复杂 | 02§1-B1 / 03§五-1 / 04§二-6 | zcode-pretooluse.sh:91-116（本节点抽查:94,:104 属实）；SKILL.md:451 自认 E4 deferred |
| R2 | 每 Phase 固定仪式 ≥16 轮主上下文动作 ×Phase 数乘积（翻转/Todo×2/委派检查/Handoff/回填/ledger/gate/commit/index/drift-guard/plan-resume/C清单）；mini 档 2 Phase 照付（注：plan-resume 分项对 ≤3 Phase 任务已按 24.7 豁免，仅 >3 Phase 复杂任务照付，见 R7） | 4 | 5 | 20 | 04复杂+03简单 | 04§二-1 / 03§五-3、§三 | SKILL.md:88-107；mini-lite-type.md:31-43；6-Phase≈100 仪式轮 |
| R3 | UserPromptSubmit 每条用户消息 0.75-1.8s：check-conflicts --runtime（508-1820ms）+ attest --verify（112ms）+ 同一 task_plan.md 被 6 进程各读一遍 | 4 | 4 | 16 | 02守卫+03简单+04复杂 | 02§1-B3 / 03§五-2 / 04§二-5、8 | zcode-userpromptsubmit.sh:136,:61,:73-79；本节点抽查:61 属实 |
| R4 | PostToolUse 无 matcher 挂全工具：每次任意工具 143-276ms（5 个 jq 单层路径读 config + resolve-plan-dir 子进程 + Agent 时再清锁 1 次） | 5 | 3 | 15 | 02守卫 | 02§1-B2、B9 | zcode-posttooluse.sh:109-116,:43,:30；hook config 无 matcher（02§0 表） |
| R5 | 【裁决项】Rule 21.4 串行派发铁律：互不依赖 S-unit 一律串行，墙钟=Σ单步时长；串行槽锁 age<120s exit 2 阻断 | 3 | 5 | 15 | 01派发+04复杂 | 01§二-3 / 04§二-2 | critical-rules.md:122（本节点定位）；check-dispatch.sh:350-376（本节点抽查属实） |
| R6 | check-scope 每次写检查起 python3 解释器 + 哨兵期实时 sha256sum（129ms/次），且对 Agent 等无文件工具也空跑加载链 | 4 | 3 | 12 | 02守卫 | 02§1-B5 | check-scope.sh:51,:142-144,:108；zcode-pretooluse.sh:18 无条件先跑 |
| R7 | plan-resume 每 Phase 全文加载 28.6KB/433 行（≈9K token），执行期恒「只报告不续推」零消费；报告文件执行期无任何后续动作（收益面仅 >3 Phase 任务——≤3 Phase 已由 24.7 豁免，critical-rules.md:169 本节点实查） | 4 | 3 | 12 | 01派发+04复杂 | 01§二-4 / 04§二-7 | SKILL.md:107；critical-rules.md:161,169（:169 本节点实查「≤3 个 phase → 跳过」）；04 实测 M17 wc=28,616B；M16 scan-plans 仅 22ms |
| R8 | C1-C27 合规清单每 Phase 逐项确认，≥10 项与机器门重复，未命中项也强制「记一行」（典型 ≥7 项 N/A/PASS ×每 Phase） | 4 | 3 | 12 | 01派发+04复杂+03简单 | 01§二-5 / 04§二-12 / 03§五-10 | SKILL.md:173-204（:196-204 N/A 记行条款） |
| R9 | sync-todos --index 每次全量重写 INDEX.md：37 plan × ≈8 子进程 = 179-2642ms/次；每 Phase 翻转 + 每 10 次工具心跳 + 归档 + S4 共 4 触发点 | 4 | 3 | 12 | 02守卫+04复杂 | 02§1-B4 / 04§一矩阵 | sync-todos.sh:234,:215-233,:271；02 实测 2642ms、04 实测 179ms |
| R10 | 单 S-unit 派发周期固定 ≈10-11 次协议动作其中 1 次是工作：Handoff 12 列行前后 2 Edit + 九字段 prompt + T1-T5 检查点 + 8 字段返回与 T5 同块双写 + findings/progress/里程碑三路落盘 | 3 | 4 | 12 | 01派发+04复杂 | 01§二-2 / 04§二-13（部分） | critical-rules.md:132-136,:142；templates/subagent_dispatch.md:77-91（本节点 wc=122 行属实） |
| R11 | 计划建立期 ≈15-18 步固定仪式先于一切实际工作：哨兵→init 6 文件→catchup→conflicts→sync→plan-created→展示复述→等 yes→attest，且 plan-writer 派发本身又是 1 个完整派发周期（mini 同付 A 段全部） | 3 | 4 | 12 | 01派发+03简单 | 01§二-1 / 03§一表 0-8 | SKILL.md:60-80,:371,:556；init-session.sh 6/6 建档（:183-251） |
| R12 | 【裁决相邻】ask 默认模式 D1 强制用户往返 + 28.2.1 复述：简单任务墙钟下限=用户响应时间，无人值守直接阻塞，无档位豁免 | 3 | 4 | 12 | 01派发+03简单 | 01§二-7 / 03§五-7 | config.json:58-59 default=ask（本节点抽查属实）；SKILL.md:79-80,227；critical-rules.md:226 |
| R13 | 【裁决相邻】Rule 14 仅 ≤3 行直做 + 委派率 floor 0.7：3 行至 300 行之间微小任务无直做通道，20 行小改被放大为 ≈10 动作派发周期 | 3 | 4 | 12 | 01派发 | 01§二-9 | critical-rules.md:54-55（本节点定位 :54）、:176、:191；config.json:36-42 |
| R14 | jq 单层路径 `.properties.X.default` 读 config：用户覆盖静默失效（效率×正确性双损，阈值门控回退最严默认值），遍布 4 个 hook 热路径脚本 | 5 | 2 | 10 | 02守卫+report | 02§1-B6 / report #15,#16 | check-plan-dispatch.sh:115-116（:118 已修正双层）；check-dispatch.sh:268；subagent-fallback.sh:46-52 |
| R15 | 冲突检测三套实现并存：Rule23 内联版 + check-conflicts --runtime INDEX 驱动版 + scope 表提取管道四处逐字复制（同一用户回合两套各扫全 plans/ 一遍） | 5 | 2 | 10 | 02守卫 | 02§1-B7 | zcode-pretooluse.sh:102,107 / check-conflicts.sh:108,134 / sync-todos.sh:197 |
| R16 | mini 启用 opt-in 无自动判定：init 无 tier 自动路由，SKILL 主流程无判定步骤，忘传即落 general 419 行模板 + VC≥5 + FMEA 全套 | 3 | 3 | 9 | 03简单 | 03§五-4、§3.1 | init-session.sh:99（本节点抽查属实）；selftest PT-15/PT-26 实证缺省=general |
| R17 | mini 验收 Phase 制度性重复：38.3③ 固定「实施+验收」2 Phase，验收对 3 行修改独立走完整 6 步闭环（≈10 个动作纯税） | 3 | 3 | 9 | 03简单 | 03§五-8、§四-6 | mini-lite-type.md:31-43；SKILL.md:88-107 |
| R18 | drift 检测 5 触发点双实现叠加：Skill(task-drift-guard) 全文载入 + check-drift.sh --json 同点双跑；Rule 15 高频触发每 2-3 todo/≥3 工具调用/切模块/每 Phase | 4 | 2 | 8 | 04复杂+03简单 | 04§一矩阵 / 03§五-10 | SKILL.md:102,106,181,522；critical-rules.md:58；04 实测 M8=158ms、M17 guard SKILL=3,455B |
| R19 | selftest 全量 27 脚本 65.7s/轮 × 每技能修改 2-3 轮（Rule 36.6 全量门 + worktree 一轮 + 交付位一轮），457 断言行主进程求和复核 | 2 | 4 | 8 | 04复杂 | 04§二-3 | critical-rules.md:316（36.6）；04 实测 M15=65.674s；task-v090 verification.md 实录两轮 457/0 |
| R20 | 双写/三写簿记：19.4 错误同条进 task_plan Errors 表 + progress Error Log；选型双写 Decisions Made；关键动作 progress + ledger + Decisions 三写；hook 又把 md 尾部反复回灌主上下文 | 4 | 2 | 8 | 04复杂 | 04§二-13 | critical-rules.md:98；SKILL.md:96,118；zcode-userpromptsubmit.sh:84-91 |
| R21 | 委派判定 4 门重复（每 Phase 检查点 + 每 Write/Edit hook + 终验 stats + verification 统计段）；且 Handoff 格式敏感致合法计划误报 violation（04 沙箱实测） | 3 | 2 | 6 | 04复杂 | 04§二-9 / 03§五-10 | SKILL.md:91；zcode-pretooluse.sh:40；check-complete.sh:381-455；critical-rules.md:177 |
| R22 | 终验 check-complete 11 门中 PLAN-DISPATCH 与 FMEA 两道与 attest 锁定期逐字节重复（计划哈希未变必同结果）；porcelain 同 scope 检查 5 门位 | 2 | 3 | 6 | 01派发+04复杂 | 01§二-6 / 04§二-4、§一矩阵 | check-complete.sh:459（本节点抽查属实）,:466-511,:476 注释自证同口径；attest-plan.sh:67（本节点抽查属实） |
| R23 | mini 五锚点减负密度 ≈3/5：锚④对「有 Executor 行的主进程 Phase」零增量（:172-174 已放行，探针实证输出一致——但 :178 分支本身是**无 Executor 行 Phase 的活豁免**而非死代码，见 A-2 v2 重定性）、锚③与 25.4a WHITELIST-EXEMPT 重叠（仅格式要求部分）、五锚全落文档层无一落流程层 | 3 | 2 | 6 | 03简单 | 03§五-6、§3.2（v2 修正） | check-plan-dispatch.sh:172-180；check-complete.sh:424-433；03 本会话探针 1/2/3（探针结论边界见 A-2 修订） |
| R24 | check-dispatch Agent 税 90-219ms：2 jq + scan_missing stat/realpath 链 + prompt 落盘 mktemp 往返 + 4 组 grep 步骤枚举计数 | 3 | 2 | 6 | 02守卫 | 02§1-B8 | zcode-pretooluse.sh:70-76；check-dispatch.sh:160,:171,:209,:247-255,:268 |
| R25 | 【裁决相邻】CR 多轮 × 修改后验证 4 步全串行链 × Rule 33 反思循环：每步子代理冷启动，返工期乘法结构 | 2 | 3 | 6 | 04复杂 | 04§二-11 | SKILL.md:145-156,459-463；critical-rules.md:275-284 |
| R26 | mini 终验 ≈10 门中 8 门照跑（仅 VC-GATE/委派 floor 两处 mini 分支）+ attest 3 子门控照跑；各门背后回填义务（委派统计/质量门控统计三段）对 mini 全保留 | 2 | 2 | 4 | 03简单 | 03§五-5 | check-complete.sh 仅 :118-120,:547-550（本节点抽查属实）,:637-638 三个 mini 分支；attest-plan.sh:66-201 |
| R27 | 部署三实体位 diff -rq 全树对账 ×3 + 部署位 selftest 再跑一轮全量（第 3+ 轮） | 2 | 2 | 4 | 04复杂 | 04§二-10 | smart-merge-back.sh:375,:555；task-v090 verification.md:23-24 实录 |
| R28 | 哨兵门强制 6 文件建档先于一切业务写入，其中 notepad-learnings/knowledge-brief 对 trivial 是空档产物（mini 不查其 stub） | 3 | 1 | 3 | 03简单 | 03§五-9 | check-scope.sh:92-163；init-session.sh:183-251；check-complete 3-File 段 :300-329 只查 findings/progress |
| R29 | SessionStart node 冷启动：热态 255-656ms，首轮 23.7s 冷离群未复现未定位（诚实存疑） | 1 | 2 | 2 | 02守卫 | 02§1-B10 | zcode-sessionstart.sh:13,:33；02 两轮复测 342/255ms |

去重说明：① 01#8（hook 进程税）拆入 R1/R3/R4/R6/R24；02 B-6 与 B-9 拆入 R4/R14；02 B-3 与 04#8 的 attest 重校验并入 R3（UPS 侧）与 R22/R6（短路设计面）。② 01#3 与 04#2（21.4 串行）合并为 R5。③ 01#4 与 04#7（plan-resume）合并为 R7。④ 01#5 与 04#12、03#10（C 清单）合并为 R8。⑤ 01#6 与 04#4（终验重复门）合并为 R22。⑥ 01#7 与 03#7（D1 往返）合并为 R12。⑦ 03#3（mini 不裁流程）并入 R2；03#6（锚点密度）单列 R23。⑧ 04#13（簿记双写）单列 R20，与 R10 的 T5 双写交叉引用。⑨ 04#6（O(N) 增长）并入 R1/R3 作为恶化放大器注记。
量化横切结论（转引 02§0 + 03§二）：一个「Edit 1 次 + Bash 3 次 + 派发 1 个 + 用户 2 条消息」的最小循环纯 hook 税 ≈5.6s，约 80% 来自与当前任务无关的 37-40 个历史计划全量重复扫描；mini 任务全链 ≈20-35s 纯 hook 开销，接近甚至超过任务本体；simple 任务仪式:本体（计划侧写入比）≈16-22:1（03§一）。

---

## 二、方案簇① 简单任务链路瘦身（mini 深化 + 纯税仪式豁免）

### A-1 mini 自动降档路由（auto-tier，Tier A）

- **改动面**：`skills/task-planner/scripts/init-session.sh:95-99`——第 3 位置参/env 均缺省时，增自动判定分支：预估 ≤15min ∧ scope_files ≤2 ∧ 单模块三条件由主进程在调用前判定并以 `TASK_PLAN_TIER=mini` 传入（脚本侧保持显式参优先，缺省行为零改动由调用侧路由实现，兼容 38.4 非 mini 零影响铁律）；`skills/task-planner/SKILL.md:64` 初始化步骤前加一步「trivial 三条件判定 → 命中即自动传 mini 并在 Decisions Made 登记一行」；`skills/task-planner/references/critical-rules.md` Rule 38 增补纯增量子条 38.5（自动降档路由：判定条件、显式优先、登记要求）；`scripts/selftest-plan-tier.sh` 增自动路由断言。
- **预估收益**（结构性论证）：消除 R16「忘传=419 行 general 模板 + VC≥5 + FMEA 全套」的默认重档。mini 判定三条件机器可测（check-plan-dispatch.sh:91-103 已有 MISMATCH 探针），自动路由把 mini 命中率从「模型自觉」变为「条件命中即触发」，对 R2/R11 的仪式面在计划文档层直接降 ≈370 行填充与对应确认动作。
- **质量风险**：误判 complex 为 mini → 门控面收缩（VC 5→2 等）。风险被三条件机器可测性压制；且 mini 的门组（attest/3-File/check-complete 10 门）本身仍全跑（R26 为另一独立问题，本项不扩 mini 豁免面，只提命中率）。**体量测度外的风险维度缺口（批判轮 1 #7 采纳）**：单文件 ≤30 行修改裁决条款或门控语义的场景三体量条件可全中，须以排除条件兜住。
- **护栏**：三条件全命中**且未命中第④排除条件**才降档——④ 排除条件：目标文件命中保护区（§六：skills/agents/commands/AGENTS.md）、Rule 36 技能修改类、D6 高危类（schema/基础设施/破坏性操作）→ **禁止自动降 mini**（用户显式指定 mini 仍可，显式优先）；任一体量条件不命中保持 general；显式 tier 参/env/用户口头「走 general」永远优先；selftest-plan-tier.sh 现有 28 断言 0 FAIL 保持 + 新增「命中④排除→不自动降档」断言；check-plan-dispatch MISMATCH 探针保持（mini 条件与计划实际不符仍探出）。
- **子代理干净上下文验证设计**：派发全新子代理（无本会话记忆），prompt 仅含：① worktree 绝对路径；② 四组构造任务描述（甲=单文件 2 处小改预估 10min；乙=3 文件重构预估 60min；丙=单文件小改但显式 `TASK_PLAN_TIER=general`；丁=单文件 ≤30 行修改 `references/critical-rules.md` 裁决条款——命中④排除）；③ 验收标准：对四组分别执行 init，`head` 产物 task_plan.md frontmatter，期待 plan_tier=mini / standard(或 general) / general / **非自动 mini**；④ 回归命令：`bash scripts/selftest-plan-tier.sh` 期待 ≥28 PASS 0 FAIL。判定=子代理返回的四段 frontmatter 原文 + selftest Total 行；因其无既有上下文，产出即独立证据。

### A-2 mini 锚点口径对齐（v2 重定性：放弃死代码删除，仅做文档口径对齐 —— Tier A）

> **批判轮 1 #1 采纳（high）**：v1 的「MINI_EXEMPT 分支=死代码」定性**被本节点复现实验证伪**——`/tmp/a2verify` 实测：mini 计划（全 Executor=主进程）含一个**无 Executor 行**的 Phase 2 时，原版 check-plan-dispatch.sh rc=0（`✓ 1 个派发型 Phase 均有带执行体的 S-unit 表`），`sed '178,180d'` 删除后 rc=1（`✗ Phase 2: 缺 S-unit 表或数据行(Rule 22.6)`）。源码核验：`settle_phase` 首分支要求 `have_executor=1 ∧ executor_main=1` 才放行，无 Executor 行的 Phase 跳过 ：172 直达 ：178——脚本头 ：5 明文「无 Executor 行按派发型从严」，:178 正是该从严在 mini 档的**活豁免**。03 取证探针的「永不可达」结论只对有 Executor 行的 Phase 成立，系其夹具覆盖缺口。

- **改动面**：`skills/task-planner/references/critical-rules.md` 38.4③ 增补口径注释：「锚③仅免『理由措辞像白名单』的格式要求，白名单放行本体在 25.4a；38.4④（check-plan-dispatch.sh MINI_EXEMPT 分支）是**无 Executor 行 Phase 从严判定的 mini 豁免**，二者语义不同、并存非冗余」；同表补注「对含子代理 Executor 的 Phase 不豁免（:86-87 has_subagent 判定）」。**脚本零改动**。
- **预估收益**：修正 v1 误判留下的文档歧义，防后续优化把 ：178 当死代码误删（删除=把「无 Executor 行 Phase 由 mini 豁免转从严」的语义变更伪装成清理，且会令 Executor 行遗漏的 mini 计划误触发回炉——实伤简单链路）。运行时收益=0，本项价值是正确性与防误删，如实声明。
- **质量风险**：≈0（纯注释，无行为变更）。
- **护栏**：脚本 diff 为空；selftest-plan-tier.sh 28 断言 0 FAIL；38.4③ 注释与 check-plan-dispatch.sh 实际行为一致（注释口径以本节点复现实验为准）。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 附两个样例计划全文（甲=有 Executor 行的主进程 Phase；乙=**无 Executor 行 Phase 的 mini 计划**）+ 修订后 critical-rules.md 38.4③ 段落，指令=① 对照注释与脚本实际行为判定注释是否失实；② 对乙样例跑 `bash check-plan-dispatch.sh` 期待 rc=0 且输出含「✓ … S-unit 表」。判定=子代理独立读码结论与 rc 输出原文——若注释与行为不符子代理应报 FAIL（验证注释本身的真实性，而非预设一致）。

### A-3 每 Phase 重复检测合并：drift 双计合一 + plan-resume 移位 + C 清单收敛（Tier A）

- **改动面**：`skills/task-planner/SKILL.md:102`（Phase complete 处 drift 检测改为「二选一」：Skill(task-drift-guard) 或 C4a check-drift.sh --json 保留其一，删除同点双跑）；`SKILL.md:107`（plan-resume 从每 Phase 循环移除，改为「交付终态 + 会话恢复触发点」两处——与其自身「恢复触发点」定义对齐）；对应 `references/critical-rules.md` Rule 24.1/24.7 与 Rule 15 条款同步修订；`SKILL.md:173-204`（C1-C27 表改为「脚本已覆盖项由机器门断言，人工仅确认脚本未覆盖的 ≈10 项」+ 删除 :196-204 的 N/A/PASS 强制记行条款）；`scripts/check-complete.sh` 新增 COMPLIANCE-CHECK 段（把被删的人工记行转为脚本断言，warn 档起步）。
- **预估收益**（结构性论证，锚 R7/R8/R18；**plan-resume 分量已按批判轮 1 #8 修正适用面**）：每 Phase 省 1 次 check-drift 脚本（158ms）+ 5-8 个清单确认/落盘动作——此项全档位适用；plan-resume Skill 全文载入（28.6KB≈9K token + 1 解读轮/Phase）**仅对 >3 Phase 任务构成节省**（≤3 Phase 已由 24.7 :169 豁免，mini/simple 不在其列）；6-Phase 任务省 ≈54K token 注入与 ≥30 次动作；C 清单收敛后「N/A 记行喂 3-File 门 mtime 信号」的形式化写入（01§二-5）同步消失。
- **质量风险**：drift 检测频率降低可能漏漂移——护栏是「同点二选一」而非删除，Rule 15 高频触发（每 2-3 todo / ≥3 工具调用 / 切模块前）全保留；C 清单收敛若先删人工项后加脚本断言会出现覆盖空窗。
- **护栏**：实施顺序强制「先加后删」——COMPLIANCE-CHECK 段与「C 项↔断言」映射表先落盘并入 selftest，再删人工记行；每个被收敛 C 项必须映射到既有机器门或新断言（映射完整性由 selftest 断言）；**无机器承载的人工义务显式登记承接项**（批判轮 1 #4 联动：verify_done 勾选义务当前仅 22.5/C15/C16 人工层承载、scripts 零机器消费，映射表中登记为「人工保留项，不收敛」而非假装有机器门）；VC-GATE/3-File/委派/attest 四类真门零改动；Rule 15 全部触发点保留。
- **子代理干净上下文验证设计**：两个全新子代理。子代理甲（流程层）：prompt 仅给修改后 SKILL.md 的 Phase 循环段全文 + 一个 2-Phase 样例计划目录，指令=按条款执行一遍 Phase complete 流程并列出实际调用的每个检测（名称+命令），期待=drift 检测恰 1 次、无 plan-resume 调用、C 项确认仅列脚本未覆盖项。子代理乙（机器层）：对一个故意缺某 C 项对应产物的构造计划跑修改后 check-complete.sh，期待 warn 输出点名缺失项（证明人工项删除后机器兜底咬合，无静默漏检）。

### A-4（评估结论：不建议实施）mini 建档 6→4 文件

R28 指出 notepad-learnings/knowledge-brief 对 mini 是空档产物，但结构性收益 ≈0：init-session.sh 单命令一次性创建全部 6 文件（03§五-9），删除仅省同一命令内两次 cp；且 check-complete.sh 的 Learning Gate（:694-795）实际消费的是 **progress.md Error Log 的 Root Cause/Prevention 列**（:695-697 注释与本节点 grep 实证：全文 `grep notepad` 0 命中——v1 此处锚失准，批判轮 1 #9 采纳更正），notepad-learnings 无终验机器消费，删除建档的门控交互面比 v1 设想的小；但收益仍微小（单命令内两次 cp）且牵动 6/6 复核口径与 selftest 断言 = 收益/改动比不成立，不建议实施。如实登记评估结论，不留半吊子改动面。

---

## 三、方案簇② 单次派发协议降开销（派发保持串行——Rule 21.4 原文与机器锁零改动）

> 边界声明：R5（串行墙钟）是本簇理论最大开销源，但 Rule 21.4 是 2026-09-12 用户裁决（critical-rules.md:122），只能进 Tier B（§四 T-B1）。本簇 Tier A 面较窄——派发契约的字段、检查点与证据落盘正是三证据质量载体——收益集中在 prompt 预算与登记动作，不在合同本身。此为诚实结构性结论，不夸大。

### B-1 派发模板契约压缩：122 行模板瘦身 + prompt 预算重分配（Tier A，v2 修订：补 22.4b 同步修订）

- **改动面**：`skills/task-planner/templates/subagent_dispatch.md`（122 行→≈60 行：九字段定义、三文件读写契约、验收条件、禁改清单等机器判定锚全保留；「已填示例」整段移至文末折叠示例节或外置 `references/dispatch-examples.md` 标注「按需 Read」）；**`skills/task-planner/references/critical-rules.md:134`（22.4b）同步修订——原文「派发 prompt 必须附该模板与一份已填示例」改为「派发 prompt 必须附该模板路径引用；已填示例以 references/dispatch-examples.md 落盘承载，派发方/被派发方使用时 Read」（批判轮 1 #5 采纳：不修订 22.4b 则严格执行者仍须贴全文入 prompt=收益归零，宽松执行者不贴=静默违约）**；`skills/task-planner/templates/task_plan.md:356` Handoff 表说明同步；`skills/task-planner/scripts/check-dispatch.sh` 七项缺项扫描与四项 fine-grain 判定逻辑**零改动**（四项判定不查示例存在性，故无需增检查；示例引用锚可选 warn 级提示）。
- **预估收益**：在 22.4b 同步修订**完成后**，每次派发 prompt 释放 ≈1.5-2K 字符（subagent.prompt_max_chars=3000 预算的一半以上让给任务实质内容）；子代理冷启动首读 token 同幅下降；对 R10 的派发周期，主进程与子代理两侧的模板誊写动作减少。未修订 22.4b 前本项收益声明无效——两改动绑定合入。
- **质量风险**：示例外置后模型可能不 Read 示例致返回格式漂移——该风险被 check-dispatch enforce 档逐字段校验兜住（格式漂移=派发被拦），属可观察可修复失败而非静默降质。另注：本项「示例落盘+使用时 Read」与 v076 否决②（prompt 大内容必须落盘+使用时 Read，2026-09-16）**方向一致**（批判轮 2 #1 确认无违规）。
- **护栏**：check-dispatch.sh 七项+四项判定与 dispatch_contract_enforce 默认 enforce 零改动；受影响 selftest 子集 + 终验全量 457 断言 0 FAIL；22.4b 修订与模板压缩同一 commit 不可拆分（防「条款未改、示例已外置」的违约窗口）。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 自含：① 按压缩后模板构造的派发 prompt 样例全文（含一个真实小任务）与修订后 22.4b 条款原文；② 指令「假设你是被派发方，按 22.4b 契约返回」；③ 两条机器判定命令：`bash scripts/check-dispatch.sh pretool <样例prompt文件> <plan-dir>` 期待 rc=0 七项全过；一个故意缺字段的对照 prompt 期待 rc≠0 且缺项点名（判定力未削的双向证明）。期待输出=子代理返回含全部 8 字段 + 两条命令的 rc 与关键行原文。

### B-2 单写者澄清 + Handoff 表低频列折叠（Tier A，v2 修订：verify_done 机器门缺口如实化）

- **改动面**：`skills/task-planner/references/critical-rules.md:133`（22.4a 增补纯增量一句：findings/progress 追加由子代理必做，主进程仅在缺漏时兜底，禁止双侧同写同段）；`skills/task-planner/templates/task_plan.md` Handoff 表 12 列中 rescue/retry_count/verify_done 三低频列折叠为「备注(verify_done/retry/rescue)」单列（verify_done 登记义务不变，仅列位合并）；`skills/task-planner/scripts/check-delegation.sh` stats 解析兼容性核对。
- **预估收益**（锚 R10/R21）：消除「子代理自写 + 主进程兜底」的双写不确定（01§二-B8 场景），每派发主进程省 1-2 次 Edit；Handoff 填表宽度 -25%；委派误报源之一（格式敏感）缓解。
- **质量风险**：列折叠若破坏 check-delegation.sh 解析 → 委派门误报（04 已实测一例格式敏感误报）——须先对拍解析器再合入；单写者条款若被误读为「主进程可不复核」则削 22.5——条款原文必须同时写明「主进程 Read 复核义务不变」。**verify_done 机器承载缺口（批判轮 1 #4 采纳）**：本节点 grep 实证 `grep -rn verify_done scripts/*.sh`（除 selftest）0 命中——verify_done 义务当前仅由 22.5/C15/C16 人工层承载，check-delegation.sh stats 按 Executor/Handoff 类型 token grep、不读该列。故本项**不新增也不声称** verify_done 机器门；其人工义务在 A-3 的 C 项映射表中登记为「人工保留项」防 A-3 压缩清单后悬空。
- **护栏**：check-delegation.sh stats 对「原 12 列 / 折叠 10 列」两个内容等价的样例计划输出 verdict 与数字完全一致（对拍夹具入 selftest）；22.5 双条件（Read 复核 + verify_done）语义原文保留。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 附两个内容等价的样例计划（原 12 列版/折叠 10 列版）与 check-delegation.sh stats 段源码，指令=对两者各跑 `bash scripts/check-delegation.sh stats <plan-dir>` 并回贴完整输出，另读码回答「stats 是否按列位解析 verify_done」。期待=两者 verdict/数字一致 + 读码结论「不解析 verify_done 列」（如实证明机器门边界，而非虚构门咬合）。

---

## 四、方案簇③ 守卫与 selftest 的合并执行/懒执行/增量执行（降判定开销，不降判定力）

### C-1 hook 热路径合并执行包（六项独立可回滚子项，Tier A）

- **改动面**（均在 `skills/task-planner/scripts/`）：
  a. `zcode-pretooluse.sh:91-116` Rule23 循环：① :94 `CWD="${PWD}"`→stdin JSON `.cwd`（**正确性修复**：本会话 xtrace 实证 cwd=/tmp 仍扫本仓）；② 循环加活跃计划过滤（仅 `.active_plan_side` 指针计划 + 非 COMPLETE 状态，复用 zcode-posttooluse.sh:100-105 的 outcome 跳过先例）；③ 每计划 5 进程 awk 链合并为单 awk 多文件输入（37 计划 ≈185 进程→1 进程）。
  b. `zcode-posttooluse.sh:109-116` 5 jq→1 次双层路径 jq（`.key // .properties.key.default`，**顺手修复 R14/review #15/#16 类覆盖失效**）；:43 resolve-plan-dir 结果进程内缓存传递。
  c. scope 表提取管道四处逐字复制（zcode-pretooluse.sh:102,107 / check-conflicts.sh:108,134 / sync-todos.sh:197）→ 提取 `lib/plan-parse.sh` 单函数，四处 source（本仓已有 lib/ 目录）。
  d. `check-scope.sh:51` python3→纯 bash `realpath -m`（**v2 修订：剔除 :142-144 (mtime,size) 短路子项**——批判轮 1 #3 采纳，本节点实查 :142-144 为 D10'' 篡改仲裁本体：`.plan-attestation` 的 plan_sha256 与 task_plan.md **实时 sha256sum** 比对判定「attested 计划未被篡改→放行」，属安全语义非纯性能哈希；mtime 短路会引入同字节替换+touch -r 误放行窗口，且 C-1 的对拍夹具不含篡改样例，防护层比 C-2 更薄）。
  e. `zcode-userpromptsubmit.sh:73-79` 6 进程字段提取（sed+3 awk+ip awk+decisions awk）→单 awk 一次遍历产出全部字段。
  f. `check-conflicts.sh` 9 处 git 调用合并（status×2/worktree list×2/branch×2 各并 1 次复用变量）。
- **预估收益**（转引取证定量锚）：Edit 事件链 1329-1403ms→理论 <500ms（R1 循环 833ms→<50ms，02§1-B1）；UPS 1796/752ms→~400ms（02§1-B3）；PostToolUse 143→~60ms（02§1-B2）；每任务 50-100 次工具调用 × 2-4 子进程 ≈150-400 次进程孵化消除大半（01§二-8）。随 plans/ 增长从线性恶化回归常数（04§二-6）。
- **质量风险**：awk 合并改写解析语义的回归风险（scope 提取/字段提取错读→守卫误判）；check-conflicts 零 selftest 覆盖（review #27）使 f 项回归风险无现有网。
- **护栏**：每子项改前/改后对同输入快照对拍（stdout 与 rc 逐字节）；三门（check-scope/check-delegation/check-skill-modify）判定语义零改动；**f 项先补行为级 selftest 再动脚本**（review #27 顺序要求）；a 项的冲突提示输出格式不变（仅扫描集合收窄，命中判定仍对活跃集全量）。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 自含：① worktree 绝对路径与本仓 plans/ 快照（只读）；② 三类 stdin JSON 夹具（tool=Edit 带 file_path / tool=Agent 带 prompt / tool=Bash 普通调用）+ 一个 cwd=/tmp 的 Edit 夹具；③ 指令=逐夹具分别跑改动前（git show 取原脚本到 /tmp）与改动后脚本，`diff` 两份 stdout 并比较 rc。期待=前两夹具 stdout 逐字节一致 rc 相同；/tmp cwd 夹具改动前误扫本仓（有 [conflict]/扫描行为）改动后不扫（正确性修复证据）；`bash -n` 全部改动脚本通过；受影响 selftest 子集 0 FAIL。

### C-2 终验重复门内容哈希复用（v2 重设计：剔除全部 mtime 信任面，仅保留 check-complete 门复用 —— Tier A）

> **批判轮 1 #2（high）与批判轮 2 #2（medium）双采纳**。v1 两处废弃：① UPS/posttooluse 的 (mtime,size) 短路子项**整体删除**——(mtime,size) 缓存对「同字节大小替换 + touch -r 恢复 mtime」存在**原理上不可闭合**的绕过窗口，用作 Rule 20.1 防篡改校验（UPS --verify）即verification 门控削弱，112ms/轮的收益不值得裁决项化，故放弃；② v1「实现层无法保证则降级+声明残留窗口」的退路**删除**——批判轮 2 #2 指出该退路等于允许带已知绕过窗口的门控削弱方案停留 Tier A。

- **改动面**：仅 `skills/task-planner/scripts/check-complete.sh:459`（PLAN-DISPATCH 门）与 `:466-511`（FMEA 门）——复用前提改为**四元内容键**，终验时实时计算、**任何位置不使用 mtime**：① 当前 task_plan.md 内容 sha256（实时 `sha256sum`，与 `.plan-attestation` 锁定哈希比对，一致才可能命中）；② `check-plan-dispatch.sh` 文件哈希；③ check-complete.sh FMEA 段文件哈希（或整脚本哈希，保守取整脚本）；④ 相关 config 键有效值（`step_max_minutes`/`step_max_files`/`step_max_steps`/`prompt_max_chars`/`fmea` 阈值键，按双层路径解析后的实际生效值）。四元全一致 → 两门输出 `SKIP-BY-HASH` 引用 attest 锁定期结果；任一变化（计划被改 / 门控脚本被改 / config 阈值被调）→ 两门全量重跑，TAMPERED 分支不变。UPS:61 与 posttooluse 重锁**零改动**（维持现状每轮重算）。
- **预估收益**（v2 下调，如实）：终验 441→~250ms 量级（04 M13，仅此分量）；复杂任务返工重验从「全量 9-11 门重付」减为增量（R22 的结构性收益）。v1 声称的 UPS 每轮省 112ms 与计划编辑省 262ms **随短路子项删除而放弃**。
- **质量风险**：v1 的「计划未变但门控脚本/config 已变→复用陈旧判定」失效场景（本仓最常态任务=技能修改后终验）由缓存键②③④闭合——脚本或 config 任一变化即全量重跑；touch -r 对抗场景由键①内容哈希闭合（改内容必变内容哈希→必不命中）。
- **护栏**：缓存键**禁止出现 mtime/size**（selftest 断言实现中无 `touch`/`mtime` 依赖）；attest-plan.sh --verify 本体与 TAMPERED 分支零改动；`touch -r` 对抗样例入 selftest（改内容+恢复 mtime → 因比较内容哈希必检出）；check-complete 其余 9 门零改动；不设任何「残留窗口声明上线」退路。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 自含构造夹具（样例计划 + 有效 .plan-attestation + 门控脚本副本）与六步测试：① 原样 `attest-plan.sh --verify` → rc=0（基线，证明未削弱）；② `sed` 改计划一字节再跑 → 期待 TAMPERED rc≠0；③ `touch -r` 恢复 mtime 再跑 → 期待**仍 TAMPERED**（内容哈希比较，无残留窗口）；④ 未变计划跑 check-complete.sh → 期待 PLAN-DISPATCH/FMEA 两门 `SKIP-BY-HASH` 且其余门照跑、终态 rc 不变；⑤ **对 check-plan-dispatch.sh 改一行（加无害 echo）后对同一未变计划重跑 → 期待两门不 SKIP、全量重跑**（脚本变化即失效，批判轮 1 #2 指定补充步）；⑥ config 阈值键改值后重跑 → 期待同⑤。子代理回贴六步 rc 与关键行原文。

### C-3 sync-todos --index 增量化（Tier A）

- **改动面**：`skills/task-planner/scripts/sync-todos.sh:215-233`（每 plan ≈8 子进程的 rollup+extract→单 awk 多文件聚合进程）、`:271`（全量重写→按 task_plan.md mtime 仅重写变化行，或单 awk 直接生成同字节输出）；INDEX.md 输出格式**零改动**。
- **预估收益**（转引）：2642→~300ms 级（02§1-B4，37 plan 规模）；每次 Phase 翻转省 ≈2.3s；4 触发点（R9）全部受益；O(N_plans) 常数化。
- **质量风险**：rollup/extract 语义漂移 → INDEX 行内容错 → SessionStart 待处理区恢复入口失真。
- **护栏**：37 计划仓改前快照 INDEX.md vs 改后输出 `diff -u` 必须为空；zcode-sessionstart.sh:18-28 待处理区解析回归；输出字节不变是唯一验收标准，不为省字节改格式。
- **子代理干净上下文验证设计**：派发全新子代理：① 跑改前脚本得 INDEX 快照 A；② 跑改后脚本得快照 B，`diff A B` 期待空；③ `touch` 任一 task_plan.md 后重跑期待仅该任务行变化（增量生效证据）或输出与全量重算逐字节一致（聚合方案证据）；④ 抽 3 个 plan 的行与源文件字段人工比对。

### C-4 selftest 分域索引 + 开发期增量 + 终验全量强制（Tier A）

- **改动面**：新增 `skills/task-planner/scripts/selftest-registry.tsv`（27 脚本 × 消费域映射：hook 热路径 / 派发契约 / 计划门 / 模板路由 / selftest 基建 / 部署）；`skills/task-planner/references/critical-rules.md` Rule 36.6 增补纯增量子条：「开发过程中间轮次跑改动域相关 selftest 子集；**交付终验必须全量 27 脚本 0 FAIL——全量总门不降**」；SKILL.md 执行循环同步一行；selftest 基建增「registry 完整性断言」（脚本清单与 tsv 行数/名称一致）。
- **预估收益**（转引 04 M15=65.674s/轮）：每技能修改任务开发期省 1-2 轮 × 65.7s ≈1-2 分钟纯墙钟 + 数千行 PASS 输出的求和复核（04§二-3）；全量门保留=回归总门零削弱。
- **质量风险**：分域映射漏项 → 改动域漏测且开发期失败晚暴露——护栏是 registry 一致性自守护 + 终验全量强制兜底。
- **护栏**：**终验全量 27 脚本 0 FAIL 条款原文保留**（本项只压缩开发中轮次，不触交付门）；registry 自身有 selftest 断言；部署位 selftest 保持全量（见 C-5 特记）。
- **子代理干净上下文验证设计**：派发全新子代理：① `wc -l` tsv 与 `ls scripts/selftest-*.sh | wc -l` 对照期待一致且名称集合差集为空；② 给定场景「改 check-dispatch.sh」，按 tsv 查出应跑子集并实跑，期待全 PASS 且**总耗时 ≤25s 或 ≤65.7s 基线的 40%**（子代理回贴 `time` 命令原文，机械可比对——批判轮 1 #10 采纳）；③ 构造「selftest 脚本改名后 tsv 未更新」场景跑一致性断言，期待 FAIL（守护咬合证明）。

### C-5 部署对账定向 diff（v2 修订：确定性集合差兜底；部署位 selftest 保持全量——护栏特记）

- **改动面**：`skills/task-planner/scripts/smart-merge-back.sh:555` diff -rq 全树 → 两级对账：**第一级（确定性，零内容读取成本）= 文件清单集合差**——`find src -type f | sort` 与 `find slot -type f | sort` 逐行 diff，抓「仓侧有部署位缺 / 部署位有仓侧无 / 文件名漂移」三类**清单外增缺漂移**；**第二级 = 内容级定向 diff**——按「本任务改动文件清单」（git porcelain 程序化生成 + task_plan Files 列，禁止手填）逐文件 `diff` 内容；三 slot 原子替换流程（:375）与合并回约 V1-V4 预检（:35-89）零改动。
- **预估收益**（转引 04§二-10）：交付尾段省 2 次全树 diff 的**内容读取**成本（558+365 行文档 + 59 脚本规模的三实体位比较）；集合差一级保留全树文件面覆盖。
- **质量风险**（批判轮 1 #6 采纳）：清单外**内容**漂移（部署位遗留旧版文件被带外改动、仓侧已删文件的内容残留）不在定向清单内——集合差只能抓增缺/改名，抓不到同名文件的内容带外热改。残留风险如实声明于设计文档与交付验证段。
- **护栏**：第一级集合差为**确定性断言**（差集非空即 FAIL，无概率性）；第二级内容抽检保留并对随机 ≥3 个清单外同名文件做内容对拍（概率性兜底，明示非确定保证）；清单必须程序化生成；**部署位 selftest 全量保持不裁**——review report §⑤-1 实证：部署位 WF-10 FAIL（仓侧 453/0 全绿背景下）恰由部署位 selftest 抓出，定向化会漏「位置型缺陷」这一已发生类别。
- **子代理干净上下文验证设计**：派发全新子代理在 /tmp 沙箱构造 src/slot 两棵树（各 ≥8 文件）：① 1 文件内容差异且在清单内 → 期待第二级报出；② 构造「部署位多出一个仓侧没有的文件」→ 期待第一级集合差确定性报出增文件；③ 构造「仓侧已删、部署位残留」→ 期待第一级确定性报出缺文件；④ 两树完全一致 → 期待 IDENTICAL 结论正确。四例均为确定性断言（批判轮 1 #6 修订：v1 的「抽检兜底报出」在较大树下是概率性的，已弃）。

---

## 五、分层纪律：Tier A / Tier B 划分与裁决出处

**Tier A（不触任何用户裁决，可纯增量实施）**：A-1、A-2、A-3、B-1、B-2、C-1、C-2、C-3、C-4、C-5 共 10 项。逐项核验：不涉 Rule 21.4 串行（:122，2026-09-12）、不涉 Rule 18.9/18.11 试点先行/宁慢勿错（:86/:88，2026-09-18 训诫，v083 notepad 否决原文核对一致）、不涉 Rule 26 质量优先（:182）、不涉小步快跑/拆细先于升档（:115/:119/:129）、不削弱三证据/3-File/verification 门控（19.2 :96、19.5 :99、26.2 :194、check-3file-gate/check-complete 语义）。其中 C-1a 的 stdin-cwd 修复、C-1b 双层路径、C-2 的脚本/config 四元键均为**质量增强**（修复 review #15/#16 high 与 $PWD 误源，并堵住 v1 版短路方案的陈旧判定面），符合「提升效率但绝不可降低质量」。

**Tier B（涉裁决项，须用户裁决后方可，写明否决出处）**：

| # | 项 | 所触裁决与出处 | 证据与预估 |
|---|----|---------------|-----------|
| T-B1 | 只读/写类分槽并行（只读 explore/调研类 S-unit 设独立并行槽，写类保持串行） | Rule 21.4 串行派发铁律 — critical-rules.md:122（2026-09-12 裁决，Why 自带 sess_1316c7f8 事故）；39.4 显式豁免登记制（:359）为既有先例模式 | R5：3 个独立只读探查=3× 串行等待；01§二-3/04§二-2 估 30-50% 链式等待可省 |
| T-B2 | mini 验收 Phase 合并为单 Phase（验收步骤内嵌实施 Phase） | ⑤ 三证据/3-File/verification 门控粒度 — 19.2 每 Phase 双条件（critical-rules.md:96）+ check-complete.sh:547-550,637-638 mini V-N 阈值随 Phase 数减半 + Rule 38.3③（38.3 位于 critical-rules.md:337，§38 条款头 :331——v2 行号修正，批判轮 2 #3） | R17：3 行修改的验收独立闭环 ≈10 动作 |
| T-B3 | mini 档默认 silent（或 ask 默认改 silent）消 D1 强制往返 | 28.2 D1 计划批准门 — critical-rules.md:226 + config.json interaction_mode default=ask（:58-59）+ 宪法 §四用户批准语义 | R12：简单任务墙钟下限=用户响应时间；01§二-7 明示「须用户显式裁决」 |
| T-B4 | Rule 14 白名单⑥扩展（mini 档单文件 ≤30 行非保护区直做+登记）或 mini 委派 floor 降 0.0 全量化 | Rule 14 主进程直做白名单 — critical-rules.md:54-55 + 25.3（:176）+ SKILL.md:31「主进程=调度器」第一设计目标 + 委派率 floor（config.json:36-42） | R13：20 行小改被放大为 ≈10 动作派发周期，简单任务慢的最大单一来源（01§二-9） |
| T-B5 | 短任务（≤15min 单 S-unit）T5 检查点免写、8 字段返回即最终结论 | ⑤ 三证据 — 22.8.2（critical-rules.md:142，T5=执行记录落盘证据）+ 22.4b（:134）；v056 实证 12 次派发 0 自带三文件（check-dispatch.sh:60-62 注释）支撑契约不可删 | R10：每 S-unit 省 2-3 子代理动作 + 1 复核读（01§二-2） |
| T-B6 | CR 按 diff 规模分级范围 + code-runner/build-error 合并单代理 | Rule 26 核心载体（CR 与独立验证，critical-rules.md:182）+ ④ 拆细先于升档（:129，合并两代理=反拆细方向） | R25：返工期乘法结构；04§二-11 |
| T-B7 | findings 增量条件放宽：纯实施 Phase 允许一行「本 Phase 无调研产出，证据=产出文件路径」计入增量 | ⑤ 3-File 19.2 实质增量语义 — critical-rules.md:96；check-3file-gate.sh:12-16「宁可误报」设计取向自证该放宽属语义变更 | R8 关联：每 Phase 省 0-1 次制造性写入，收益小（01§二-10） |

**Tier B 验证设计要点（批判轮 2 #4 采纳：任一项获用户裁决采纳后，须按 Tier A 同规格补「子代理干净上下文验证设计」并入 selftest 后方可实施；以下为要点）**：T-B1=全新子代理对「2 个独立只读 S-unit」场景验证分槽并发行为 + 写类串行槽锁仍 exit 2（check-dispatch.sh 锁语义回归）；T-B2=单 Phase mini 计划过 attest/check-complete 全链（VC≥2/V-N 义务以「总计 ≥2」等价形式入机器门）+ 3-File 门对该形态缺回填样例仍咬合；T-B3=构造 mini 任务在 silent 档全链跑通且静默决策清单含 D1 等价登记行；T-B4=≤30 行直做任务过终验（floor/白名单计数按新口径）+ >30 行仍强制派发；T-B5=短任务 8 字段返回场景检查点仅 T1-T4 落盘、三证据验收以返回消息+产出 Read 复核承载（降档后果显式登记）；T-B6=轻量 diff 样例走分级 CR 通过 + 重 diff 样例仍全量审查；T-B7=纯实施 Phase 一行声明过 3-File 门 + 有调研 Phase 仍要求实质增量。

历史否决核对（本会话实跑；**v2 修正普查结论——批判轮 2 #1 采纳**：v1 普查 grep 模式 `^- \*\*` 漏掉了 `- 2026-09-16 用户否决：` 前缀格式，实查全部 plans/*/notepad-learnings.md 否决段后**真实否决共 4 条**）：① task-v076（2026-09-16）2 条——「未查证的『无法查看/不存在』类能力否定结论禁止上报」（对应 Rule 35.2，用户原话「不可能完全不可能存在无法查看计划任务内容的情况」）与「prompt/提示词过大不落盘而失败收场——大内容唯一解法=落盘文件+使用时 Read 引用」（对应 Rule 35.3，用户原话「只需要将提示词存储到文件中…」）；② task-v083（2026-09-18）2 条——「单件未验证即启动批量处理」（原文「单个处理都做不好 还恶意批量处理…」）与「以速度为由压缩验证」（原文「我接受速度慢一点但不能接受批量处理出现问题」）。本批方案对照结论：无重提 v076 两条（B-1 示例外置化恰与 v076 否决②「落盘+Read」方向一致，批判轮 2 #1 确认无违规）；Tier A 十项均不属批量写操作、不压缩任何验证门；T-B6 的「CR 分级」涉以速度理由调整验证范围，除触 Rule 26 外同时贴靠 v083 否决②，双重理由留在 Tier B。v091 notepad 否决段为空模板（本节点 sed 实读确认）。

---

## 六、实施顺序建议（供计划层采纳，不改本审计职责）

1. 先做质量增强型 Tier A：C-1b（config 双层路径，修 review #15/#16 high）、C-1a①（stdin cwd）→ 再做纯性能型 C-1 其余子项、C-2、C-3。
2. 机制型次之：A-1、A-2（mini 路由）、C-4（selftest registry，先 registry 后增量）。
3. 协议与流程型最后：A-3（先加后删纪律）、B-1、B-2、C-5。
4. 每项独立 worktree + 独立 commit，任一项可单独回滚；每项合入前过 §五对应子代理干净上下文验证 + selftest 终验全量 0 FAIL。

## 七、未竟事项与诚实边界

1. 本节点为静态综合 + 锚点抽查：**未实跑** selftest 全量、**未复测** hook 计时——所有计时/clone 计数转引自 01-04 取证并逐条标注（02 为本机实测、03 为本会话实测、04 为本会话实测，三源数字存在同对象不同值，如 UPS 1796ms（02）vs 752-3060ms（03）vs 752ms（04），均如实保留区间，相对结论稳）。
2. selftest 断言基线 453（report 领域 4 实测）vs 457（task-v090 verification 记载）差异未裁决，本文件引用 457 处沿用任务书口径并标注存疑（承 02§7.3）。
3. R29 SessionStart 冷启动 23.7s 离群未定位（02 两轮复测未复现），不作为独立优化标的。
4. A-4 不建议实施的依据 v2 已更正：Learning Gate 实际消费 progress.md Error Log 列（:695-697），notepad-learnings 无终验机器消费；不建议实施的主论据是收益（单命令内两次 cp）远小于改动面（6/6 复核口径 + selftest 断言联动）。
5. 三份取证的行号基于各审计时刻工作区版本（基线 87d306b 前后），本节点抽查 12 处锚点全部命中；实施期仍须按当次 worktree 重新定位行号。

---

## 八、批判处置记录（批判轮 1，2026-09-27）

两位批判员（质量降级风险镜头 / 用户裁决与禁令镜头）共提出 14 项 issues（11+3，含 2 verdict 内评估）。逐条处置如下——**全部采纳**（其中 2 处对批判员自身行号做反向修正后采纳），无反驳项。所有验证命令均在本节点实跑。

| # | 批判 issue（来源/严重度） | 处置 | 本节点验证证据 | 修订落点 |
|---|--------------------------|------|---------------|---------|
| 1 | A-2「MINI_EXEMPT=死代码」被实验证伪（质量镜头，high） | **采纳，A-2 全项重定性**：放弃删除，改为仅补 38.4③/④ 口径注释（保留分支） | 复现实验 `/tmp/a2verify`：mini 计划含无 Executor 行的 Phase 2 → 原版 rc=0（✓ 均有带执行体的 S-unit 表）、`sed '178,180d'` 后 rc=1（✗ Phase 2: 缺 S-unit 表或数据行）；源码核验 settle_phase 首分支 `have_executor=1 ∧ executor_main=1` 才放行、脚本头 ：5「无 Executor 行按派发型从严」 | §二 A-2 整体重写（v2） |
| 2 | C-2 短路在门控脚本/config 变化时复用陈旧判定（质量镜头，high） | **采纳，C-2 重设计**：缓存键纳入两门脚本哈希+config 有效值；补验证步⑤⑥ | 逻辑核验成立：check-complete.sh:459 重跑 check-plan-dispatch.sh（本节点 v1 已抽查属实），其结果依赖脚本版本与 step_max_* 阈值 | §四 C-2 整体重写（v2） |
| 3 | C-1d 把 (mtime,size) 短路用在 D10'' 篡改仲裁上（质量镜头，medium） | **采纳，剔除该子项**（python3→realpath 保留） | 本节点实查 check-scope.sh:140-145：`.plan-attestation` plan_sha256 与**实时 sha256sum** 比对→「attested 计划未被篡改→放行」，安全语义非纯性能 | §四 C-1 子项 d（v2） |
| 4 | B-2 verify_done 第三样例不可操作、stats 适配是空操作（质量镜头，medium） | **采纳**：删不可操作样例，改为「如实证明机器门边界」；verify_done 义务在 A-3 映射表登记人工保留项 | `grep -rn verify_done scripts/*.sh`（除 selftest）**0 命中** | §三 B-2（v2）、§二 A-3 护栏 |
| 5 | B-1 收益与 22.4b「prompt 必须附模板与已填示例」冲突（质量镜头，medium） | **采纳（含行号反向修正）**：22.4b 同步修订入改动面且绑定同 commit；批判员引 ：135 实为 22.4c，「必须附该模板与一份已填示例」原文在 **:134（22.4b）**（本节点 grep 定位） | `grep -n "^22.4b" critical-rules.md` → :134，原文含「派发 prompt 必须附该模板与一份已填示例」 | §三 B-1（v2） |
| 6 | C-5 定向 diff 清单外漂移漏检、抽检兜底是概率性（质量镜头，medium） | **采纳**：升级为两级对账（确定性文件集合差 + 内容定向 diff+概率抽检明示） | 设计层采纳；集合差确定性断言由验证设计②③④钉死 | §四 C-5（v2） |
| 7 | A-1 三条件缺风险维度（质量镜头，medium） | **采纳**：增④排除条件（保护区/Rule 36/D6 高危禁自动降 mini）+ selftest 断言 + 验证夹具丁组 | 设计层采纳（§六保护区清单与 Rule 36 既有定义，无需新验证） | §二 A-1（v2） |
| 8 | R2/A-3 plan-resume 收益对 mini/simple 不成立（≤3 Phase 已豁免）（质量镜头，low） | **采纳**：R2/R7/A-3 收益面限定 >3 Phase 任务 | critical-rules.md:169 本节点实查：「本次任务 ≤3 个 phase（噪音大于价值）→ 跳过」 | §一 R2/R7 行、§二 A-3 收益段 |
| 9 | A-4「Learning-Gate 消费 notepad-learnings」锚失准（质量镜头，low） | **采纳**：更正为消费 progress.md Error Log Root Cause/Prevention 列；结论（不建议实施）不变 | `grep -n notepad check-complete.sh` **0 命中**；:695-697 注释实读「Root Cause/Prevention 列」 | §二 A-4（v2）、§七-4 |
| 10 | C-4 验证「显著低于 65.7s」无判定阈值（质量镜头，low） | **采纳**：改 ≤25s 或 ≤40% 基线 + 回贴 time 原文 | 设计层采纳 | §四 C-4 验证设计 |
| 11 | 否决普查漏计 task-v076 两条（裁决镜头，medium） | **采纳**：普查结论改为 4 条真实否决并补对照结论 | v076 notepad 实读 ：20-21 两条（2026-09-16，Rule 35.2/35.3）；v1 漏因 grep 模式 `^- \*\*` 不匹配 `- 2026-09-16 用户否决：` 前缀 | §五 历史否决核对段（v2） |
| 12 | C-2 残留窗口退路=带已知绕过的门控削弱停留 Tier A（裁决镜头，medium） | **采纳**：删除降级退路；mtime 短路子项整体废弃（原理不可闭合）；check-complete 门复用改纯内容哈希键（touch -r 无效）后无残留窗口，维持 Tier A | 逻辑核验：内容 sha256 比较对「改内容+恢复 mtime」必然检出（内容哈希必变）；mtime 在新键中不存在 | §四 C-2（v2，含「touch -r 必检出」硬验收） |
| 13 | T-B2 行号微漂（:331 实为 §38 头，38.3 在 :337）（裁决镜头，low） | **采纳**：改为「38.3 位于 :337，§38 头 :331」 | `sed -n '331p;337p'` 实查：:331=「### 38 任务难度分级与轻量档」、:337=「38.3 轻量模板契约」 | §五 T-B2 行 |
| 14 | 7 项 Tier B 均未附验证设计（裁决镜头，low） | **采纳**：表下增「验证设计要点」注记——任一项获用户采纳后按 Tier A 同规格补全并入 selftest 方可实施 | 设计层采纳 | §五 Tier B 表下注记 |

处置后分层状态：Tier A 仍 10 项（A-2 与 C-2/C-1d/C-5/B-1/B-2/A-1/A-3/C-4 均为原项修订，无升降层；C-2 的 UPS 短路子项废弃后剩余面不触⑤——四元内容键下无绕过窗口、无退路）；Tier B 仍 7 项（T-B2 行号修正，全表补验证要点）。瓶颈总表 29 条不变（R2/R7 仅注记修正）。

