# efficiency-proposal.md — task-planner 技能效率优化提案（终稿 v3）

> 产出位置：`plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md`（按任务指定创建）。
> 版本链：四领域取证（01-04）→ 05 瓶颈总表与设计 v1 → 批判轮 1（14 issues 全采纳）修订 v2 → 终审独立复核轮 2（12 issues：2 high + 5 medium + 5 low，逐条实证后全部采纳）→ 本终稿 v3。
> 输入材料：四份取证（01 派发协议 / 02 守卫hook / 03 简单链路 / 04 复杂链路）、上一轮审查报告（plans/task-planner-skill-review/report.md）、两轮批判意见、本节点两轮共 20+ 次实跑核验（命令与输出见 §六）。
> 用户裁决硬约束：① Rule 21.4 串行派发（2026-09-12）；② Rule 18.9 批量试点先行/宁慢勿错（2026-09-18 训诫）；③ Rule 26 质量优先于速度；④ 小步快跑/拆细先于升档（2026-09-09）；⑤ 三证据验证/3-File/verification 门控——凡触及以上只能进 Tier B；⑥ Rule 36.3/36.4（task-v079）：技能文件的功能性删除或既有语义改写须逐项列清单交用户确认（终审轮 2 #1 采纳：本提案 Tier A 定性由「纯增量实施」修正为「不触①-⑤裁决 + 删除性行为逐项清单待 36.4 确认」，见 §三各项）；⑦ **用户 2026-09-26 补充裁决原文：「技能修改或其他涉及上下文的修改之后，必须在子代理（全新干净上下文）中测试验证——主进程既有上下文内的测试不视为有效验证（受先前上下文影响，无法确保干净独立）」**——本提案每项与每条护栏的验证设计均按此派发全新子代理执行。

---

## 一、瓶颈总表（四份取证去重合并，29 条，按 开销频次×影响面 降序）

评分口径：频次 1-5（5=每工具调用级 / 4=每写或每 Phase 级 / 3=每派发或每任务级 / 2=每技能修改或每终验级 / 1=每会话级）；影响面 1-5（5=占墙钟或主上下文大头 / 3=显著 / 1=轻微）。完整版（含去重说明）见 05-bottlenecks-and-designs.md §一。

| # | 瓶颈 | 频 | 面 | 分 | 来源 | 回链 | 关键锚（本节点已抽查属实） |
|---|------|---|---|---|------|------|--------------------------|
| R1 | PreToolUse Rule23 冲突循环 O(N_plans)：每次 Write/Edit 全 plans/*/task_plan.md 逐个 5 进程 awk 链，实测循环体 833ms、单 Edit 439 clone/1329-1403ms；:94 `CWD="${PWD}"` 忽略 stdin cwd | 5 | 5 | 25 | 02+03+04 | 02§1-B1/03§五-1/04§二-6 | zcode-pretooluse.sh:91-116（:94,:104 实查）；SKILL.md:451 自认 E4 deferred |
| R2 | 每 Phase 固定仪式 ≥16 轮主上下文动作 ×Phase 数乘积；mini 2 Phase 照付（plan-resume 分项对 ≤3 Phase 已按 24.7 豁免，仅 >3 Phase 照付） | 4 | 5 | 20 | 04+03 | 04§二-1/03§五-3 | SKILL.md:88-107；mini-lite-type.md:31-43 |
| R3 | UserPromptSubmit 每条用户消息 0.75-1.8s：check-conflicts --runtime（508-1820ms）+ attest --verify（112ms）+ 同一 task_plan.md 6 进程各读 | 4 | 4 | 16 | 02+03+04 | 02§1-B3/03§五-2/04§二-5 | zcode-userpromptsubmit.sh:136,:61,:73-79 |
| R4 | PostToolUse 无 matcher 挂全工具：每次任意工具 143-276ms（5 jq 单层路径+resolve-plan-dir 子进程） | 5 | 3 | 15 | 02 | 02§1-B2,B9 | zcode-posttooluse.sh:109-116,:43 |
| R5 | 【裁决项】Rule 21.4 串行派发铁律：互不依赖 S-unit 一律串行，墙钟=Σ单步；槽锁 age<120s exit 2 | 3 | 5 | 15 | 01+04 | 01§二-3/04§二-2 | critical-rules.md:122；check-dispatch.sh:350-376 |
| R6 | check-scope 每次写检查起 python3 解释器+哨兵期实时 sha256（129ms/次），Agent 等无文件工具也空跑 | 4 | 3 | 12 | 02 | 02§1-B5 | check-scope.sh:51,:142-144,:108 |
| R7 | plan-resume 每 Phase 全文加载 28.6KB（≈9K token）执行期恒「只报告」零消费（收益面仅 >3 Phase 任务，24.7 :169 实查） | 4 | 3 | 12 | 01+04 | 01§二-4/04§二-7 | SKILL.md:107；critical-rules.md:161,169 |
| R8 | C1-C27 清单每 Phase 逐项确认+未命中也强制记行（≥10 项与机器门重复） | 4 | 3 | 12 | 01+04+03 | 01§二-5/04§二-12/03§五-10 | SKILL.md:173-204（:196-204 N/A 记行） |
| R9 | sync-todos --index 每次全量重写 INDEX：37 plan×≈8 子进程=179-2642ms，4 触发点 | 4 | 3 | 12 | 02+04 | 02§1-B4/04§一矩阵 | sync-todos.sh:234,:215-233,:271 |
| R10 | 单 S-unit 派发周期固定 ≈10-11 协议动作其中 1 次是工作：Handoff 12 列×2 Edit+九字段 prompt+T1-T5+8 字段与 T5 同块双写+三路落盘 | 3 | 4 | 12 | 01+04 | 01§二-2/04§二-13 | critical-rules.md:132-136,:142；subagent_dispatch.md 122 行（wc 实查） |
| R11 | 计划建立期 ≈15-18 步固定仪式先于一切工作：哨兵→6 文件→catchup→conflicts→sync→清哨兵→展示复述→等 yes→attest；plan-writer 派发又是一整个周期（mini 同付） | 3 | 4 | 12 | 01+03 | 01§二-1/03§一表 | SKILL.md:60-80,:371,:556 |
| R12 | 【裁决相邻】ask 默认 D1 强制用户往返+28.2.1 复述：简单任务墙钟下限=用户响应时间 | 3 | 4 | 12 | 01+03 | 01§二-7/03§五-7 | config.json:58-59 default=ask；critical-rules.md:226 |
| R13 | 【裁决相邻】Rule 14 仅 ≤3 行直做+委派 floor 0.7：3-300 行微小任务无直做通道，20 行小改放大为 ≈10 动作派发周期 | 3 | 4 | 12 | 01 | 01§二-9 | critical-rules.md:54-55,:176；config.json:36-42 |
| R14 | jq 单层路径读 config：用户覆盖静默失效（效率×正确性双损，阈值门控回退最严默认），实测 4 脚本 5 位点 | 5 | 2 | 10 | 02+report | 02§1-B6/report #15,#16 | cpd:115-116、check-dispatch:268、fallback:46-52、check-complete:470（本节点逐一实查均单层） |
| R15 | 冲突检测三套实现并存+scope 提取管道四处逐字复制 | 5 | 2 | 10 | 02 | 02§1-B7 | pretooluse:102,107/check-conflicts:108,134/sync-todos:197 |
| R16 | mini opt-in 无自动判定：忘传 tier 即落 419 行 general 模板+VC≥5+FMEA 全套 | 3 | 3 | 9 | 03 | 03§五-4 | init-session.sh:99（实查）；PT-15/26 缺省=general |
| R17 | mini 验收 Phase 制度性重复：固定 2 Phase，验收对 3 行修改独立走完整 6 步闭环 | 3 | 3 | 9 | 03 | 03§五-8 | mini-lite-type.md:31-43 |
| R18 | drift 检测 5 触发点双实现叠加（Skill 全文载入+脚本同点双跑） | 4 | 2 | 8 | 04+03 | 04§一矩阵/03§五-10 | SKILL.md:102,106,181,522；critical-rules.md:58 |
| R19 | selftest 全量 27 脚本 65.7s/轮×每技能修改 2-3 轮（实录：v089 3 轮、v090 主仓+worktree 两轮） | 2 | 4 | 8 | 04 | 04§二-3 | critical-rules.md:316（36.6）；04 M15=65.674s |
| R20 | 双写/三写簿记：19.4 错误双写、选型双写、动作三写、hook 回灌 | 4 | 2 | 8 | 04 | 04§二-13 | critical-rules.md:98；SKILL.md:96,118 |
| R21 | 委派判定 4 门重复+Handoff 格式敏感误报（04 沙箱实测 violation 误报） | 3 | 2 | 6 | 04 | 04§二-9 | SKILL.md:91；check-complete.sh:381-455 |
| R22 | 终验 11 门中 PLAN-DISPATCH/FMEA 与 attest 逐字节重复（计划哈希未变必同结果）；porcelain 同 scope 5 门位 | 2 | 3 | 6 | 01+04 | 01§二-6/04§二-4 | check-complete.sh:459,:466-511,:476；attest-plan.sh:67 |
| R23 | mini 五锚点减负密度 ≈3/5：锚④对有 Executor 行的主进程 Phase 零增量（:172 已放行；:178 本身为无 Executor 行 Phase 的活豁免而非死代码，见 A-2）、锚③与 25.4a 重叠、五锚全落文档层 | 3 | 2 | 6 | 03 | 03§五-6（v2 修正） | cpd:172-180；check-complete.sh:424-433 |
| R24 | check-dispatch Agent 税 90-219ms（2 jq+stat 链+mktemp 往返+4 组 grep） | 3 | 2 | 6 | 02 | 02§1-B8 | pretooluse:70-76；check-dispatch.sh:160,:209,:247-255,:268 |
| R25 | 【裁决相邻】CR 多轮×修改后验证 4 步串行×Rule 33 反思循环：返工期乘法结构 | 2 | 3 | 6 | 04 | 04§二-11 | SKILL.md:145-156,459-463 |
| R26 | mini 终验 ≈10 门中 8 门照跑+attest 3 子门控照跑+回填义务全保留 | 2 | 2 | 4 | 03 | 03§五-5 | check-complete.sh 仅 :118-120,:547-550,:637-638 三个 mini 分支 |
| R27 | 部署三实体位 diff -rq 全树×3+部署位 selftest 再跑全量 | 2 | 2 | 4 | 04 | 04§二-10 | smart-merge-back.sh:375,:555 |
| R28 | 哨兵门强制 6 文件建档先于一切写入；notepad/knowledge-brief 对 mini 空档 | 3 | 1 | 3 | 03 | 03§五-9 | check-scope.sh:92-163；init-session.sh:183-251 |
| R29 | SessionStart node 冷启动 656ms 热/23.7s 冷离群未复现未定位 | 1 | 2 | 2 | 02 | 02§1-B10 | zcode-sessionstart.sh:13 |

量化横切（转引 02§0+03§二）：最小工作循环纯 hook 税 ≈5.6s（约 80% 来自与当前任务无关的历史计划全量重复扫描）；mini 任务全链 ≈20-35s 纯 hook 开销；simple 任务仪式:本体（计划侧写入比）≈16-22:1。

---

## 二、Tier 分层总览

| 层 | 项 | 所触瓶颈 | 定性 |
|----|----|---------|------|
| Tier A | A-1（簇①）auto-tier 路由 | R16,R11,R2 | 不触①-⑤裁决；含既有语义改写→36.4 清单待确认 |
| Tier A | A-2（簇①）mini 锚点口径对齐 | R23 | 纯注释零删除 |
| Tier A | A-3（簇①③）每 Phase 重复检测合并 | R7,R8,R18 | 含 4 项功能性删除→36.4 清单待确认 |
| Tier A | B-1（簇②）派发模板契约压缩 | R10 | 22.4b 语义改写+模板示例段删除→36.4 清单待确认 |
| Tier A | B-2（簇②）单写者澄清+Handoff 列折叠 | R10,R21 | 表结构变更→36.4 清单待确认 |
| Tier A | C-1（簇③）hook 热路径合并执行包 | R1,R3,R4,R6,R14,R15,R24 | a②扫描集收窄（36.4 清单）；b 位点修复为质量增强 |
| Tier A | C-2（簇③）终验重复门内容哈希复用 | R22 | 两门必跑语义→SKIP（36.4 清单）；零 mtime 信任 |
| Tier A | C-3（簇③）sync-todos --index 单 awk 重算 | R9 | 实现替换、输出字节不变（36.4 清单登记） |
| Tier A | C-4（簇③）selftest 分域索引+开发期增量 | R19 | 36.6 增补子条（36.4 清单）；终验全量总门不降 |
| Tier A | C-5（簇③）部署对账两级化 | R27 | 全树 diff→两级对账（36.4 清单） |
| Tier B | T-B1..T-B7（7 项） | R5,R17,R12,R13,R10,R25,R8 | 触①③④⑤裁决，须用户裁决（§四） |

---

## 三、Tier A 方案详设（三簇，逐项含 36.4 删除性行为清单与子代理干净上下文验证设计）

### 簇① 简单任务链路瘦身

#### A-1 mini 自动降档路由（auto-tier）

- **改动面**：`init-session.sh:95-99`（缺省且主进程判定三体量条件+④排除条件全过时以 `TASK_PLAN_TIER=mini` 传入，脚本显式参优先、缺省契约改写见 36.4 清单）；`SKILL.md:64` 增「trivial 判定→自动 mini」一步（纯新增）；`critical-rules.md` 增 38.5 纯增子条（判定条件/④排除/auto_tier 标记）；mini 命中时产物 frontmatter 记 `auto_tier: mini` 标记（终审 #7）；`check-complete.sh` 增 AUTO-TIER 复核段（auto_tier=mini 时复核 scope_files 实数与 38.1 条件，不符→WARNING 计入质量统计，warn 档起步；终审 #7）；`selftest-plan-tier.sh` 增自动路由+④排除断言。
- **④排除条件**（终审轮 1 #7）：目标命中保护区（§六：skills/agents/commands/AGENTS.md）、Rule 36 技能修改类、D6 高危类（schema/基础设施/破坏性操作）→ 禁止自动降 mini（显式指定仍可）。
- **预估收益**：消除 R16「忘传=419 行 general 模板+VC≥5+FMEA 全套」默认重档；对命中任务计划文档直降 ≈370 行（419-49，终审核实算术）。
- **质量风险与闭环**（终审 #7）：「预估≤15min」为派发前模型估计、④排除同为模型自判，而 plan_tier_enforce 默认 warn（cpd:101 实查「提示不阻断」）→ 误降档原会带收缩门组走完全程。闭环=auto_tier 标记+终验 AUTO-TIER 复核段，把误判从「单程 warn 提示」升级为「终验可观察复核点」。
- **护栏**：四条件全过才降档；显式参/env/用户口头永远优先；MISMATCH 探针保持；selftest-plan-tier.sh 28 断言保持+新增。
- **36.4 删除性行为清单**：① init-session.sh:98 注释所载「缺省=现状行为逐字节不变」契约→改为「四条件全命中且未显式指定时自动 mini」；② check-complete 新增 AUTO-TIER 复核段（新机器断言）。
- **子代理干净上下文验证设计**：派发全新子代理，prompt 仅含 worktree 绝对路径+四组构造任务（甲=单文件 2 处小改预估 10min→期待 plan_tier=mini 且 auto_tier 标记；乙=3 文件 60min→standard/general；丙=显式 TASK_PLAN_TIER=general→general；丁=单文件 ≤30 行改 critical-rules.md 裁决条款→命中④不自动降）+回归命令 `bash scripts/selftest-plan-tier.sh` 期待 ≥28 PASS 0 FAIL。判定=四段 frontmatter 原文+Total 行。

#### A-2 mini 锚点口径对齐（v2 重定性，纯注释）

- **背景**：v1「MINI_EXEMPT=死代码」定性被本节点复现实验证伪（`/tmp/a2verify`：mini 计划含无 Executor 行 Phase → 原版 rc=0、`sed '178,180d'` 后 rc=1；settle_phase 首分支要求 `have_executor=1 ∧ executor_main=1` 才放行，cpd:5「无 Executor 行按派发型从严」——:178 是活豁免）。
- **改动面**：`critical-rules.md` 38.4③ 增补口径注释（锚③仅免格式要求、放行本体在 25.4a；38.4④ 是无 Executor 行 Phase 从严判定的 mini 豁免，并存非冗余）。脚本零改动。
- **收益/风险/护栏**：防误删活分支（删除=语义变更且实伤简单链路）；风险≈0；护栏=脚本 diff 为空+selftest-plan-tier.sh 0 FAIL。
- **36.4 删除性行为清单**：无（纯注释新增）。
- **子代理干净上下文验证设计**：派发全新子代理，附修订后 38.4③ 段落+两个样例计划（有/无 Executor 行 Phase），指令=①对照注释与 cpd 实际行为判定注释是否失实 ②对无 Executor 行样例跑 `bash check-plan-dispatch.sh` 期待 rc=0 且含「✓ … S-unit 表」。判定=子代理独立读码结论+rc 原文（注释失实应报 FAIL）。

#### A-3 每 Phase 重复检测合并

- **改动面**：`SKILL.md:102`（drift 同点二选一）`:107`（plan-resume 移至交付终态/会话恢复触发点）`:173-204`（C1-C27 表改「机器门断言+仅脚本未覆盖 ≈10 项人工」+删 :196-204 N/A 记行条款）；`critical-rules.md` Rule 15/24 同步；`check-complete.sh` 新增 COMPLIANCE-CHECK 段（warn 档，**前置 plan_tier 判定或映射表按 tier 分域——终审 #8 互锁：防 A-1 提高 mini 命中率后对 mini 计划产生新断言误报**）；A-3 改动面增列**受影响 selftest 清单（终审 #5，本节点 grep 实证 10 个）**：selftest-veto.sh:47（'| C20 |'）、selftest-error-loop.sh:55（'| C19 |'）、selftest-skill-modify.sh:11,56（'| C24 |'）、selftest-plan-tier.sh:73（'^| C26 '）、selftest-workflow-orchestration.sh:49（'| C27 |'）、selftest-conclusion-discipline.sh、selftest-mechanism-profile.sh、selftest-reflect-verify.sh、selftest-task-boundary.sh、selftest-template-lifecycle.sh（均含 '| C[0-9]' 锚）——约束「C 项锚 token（'| C19 |'~'| C27 |' 格式）保留或与条款同步逐个修订，禁反向改 selftest 迁就措辞」。
- **预估收益**（v2 已修正适用面）：全档位每 Phase 省 1 次 check-drift（158ms）+5-8 个清单确认/落盘动作；plan-resume（28.6KB≈9K token/Phase）**仅 >3 Phase 任务**构成节省（≤3 Phase 已由 24.7:169 豁免）；6-Phase 任务省 ≈54K token+≥30 动作。
- **质量风险**：drift 频率降低漏漂移（同点二选一而非删除，Rule 15 触发点全保留）；C 项收敛覆盖空窗（先加后删）；**drift 二选一的两实现输出语义等价（终审 #10）**：Skill(task-drift-guard) 的 ALIGNED/DRIFT/BLOCKED→STOP 契约（critical-rules.md:38-46 实查三态在案）不得因留脚本弃 Skill 而缩水；**compass 误报放大（终审 #9）**：A-3 删 N/A 形式化写入+B-2 单写者条款使 findings/progress 写入密度双降，19.7（:102）mtime 阈值型 [plan-compass] 提醒与连续 2 次升级链误报面增大。
- **护栏**：先加后删（COMPLIANCE-CHECK 段+映射表先入 selftest 再删人工项）；每个被收敛 C 项映射到既有机器门或新断言；verify_done 等无机器承载项登记「人工保留，不收敛」（终审轮 1 #4）；**drift 二选一须过 ALIGNED/DRIFT/BLOCKED 三态对拍夹具**（终审 #10）；**实施时评估 [plan-compass] 信号源切 ledger 语义或阈值联动，防回填密度下降放大误报**（终审 #9）；受影响 selftest 清单逐个核对锚。
- **36.4 删除性行为清单**：① SKILL.md:107 每 Phase plan-resume 调用删除（移位至终态/恢复点）② SKILL.md:102 drift 同点双跑删一 ③ SKILL.md:196-204 N/A/PASS 强制记行条款删除 ④ C1-C27 表结构改写。
- **子代理干净上下文验证设计**：两个全新子代理。甲（流程层）：给修改后 SKILL.md Phase 循环段+2-Phase 样例计划，执行一遍 Phase complete 并列实际调用的每个检测——期待 drift 恰 1 次、无 plan-resume、C 项仅列脚本未覆盖项；乙（机器层）：对故意缺某 C 项产物的构造计划跑修改后 check-complete.sh——期待 warn 点名缺失项；丙（等价性）：对 ALIGNED/DRIFT/BLOCKED 三态构造样例分别跑保留侧实现——期待三态判定与被删侧一致（BLOCKED→STOP 语义不缩水）。

### 簇② 单次派发协议降开销（派发保持串行——Rule 21.4 原文与机器锁零改动）

> 诚实边界：R5（串行墙钟）是本簇理论最大开销源，但属用户裁决，只能进 Tier B（T-B1）。本簇 Tier A 收益集中在 prompt 预算与登记动作。

#### B-1 派发模板契约压缩

- **改动面**：`templates/subagent_dispatch.md`（122→≈60 行：九字段定义、三文件读写契约、验收条件、禁改清单等机器判定锚全保留；已填示例外置 `references/dispatch-examples.md` 按需 Read）；**`critical-rules.md:134`（22.4b）同步修订**：「派发 prompt 必须附该模板与一份已填示例」→「派发 prompt 必须附模板路径引用；已填示例以 dispatch-examples.md 落盘承载，使用时 Read」（终审轮 1 #5：不修订则严格执行者收益归零/宽松执行者静默违约）；`templates/task_plan.md:356` Handoff 说明同步；check-dispatch.sh 七项+四项判定零改动；**新增静态 selftest 断言：22.4b 条款含模板路径引用 ↔ references/dispatch-examples.md 存在（终审 #12：现状 grep 证实 22.4b/已填示例零 selftest 锚，「同一 commit 不可拆分」纯人肉纪律不足）**。
- **预估收益**：22.4b 修订完成后每派发释放 ≈1.5-2K prompt 字符（3000 预算的 50-60% 让给任务实质）；未修订前收益声明无效——两改动绑定。
- **质量风险**：格式漂移被 check-dispatch enforce 档逐字段校验兜住（可观察失败非静默降质）；与 v076 否决②「大内容落盘+使用时 Read」方向一致（轮 2 #1 确认无违规）。
- **护栏**：check-dispatch.sh 判定与 enforce 默认档零改动；22.4b 修订与模板压缩同一 commit；新静态断言入 selftest。
- **36.4 删除性行为清单**：① 22.4b:134 句「必须附该模板与一份已填示例」语义改写 ② subagent_dispatch.md 示例段移出（模板 122→≈60 行）。
- **子代理干净上下文验证设计**：派发全新子代理，附压缩后派发 prompt 样例全文+修订后 22.4b 原文，指令=①按契约返回 ②跑 `bash check-dispatch.sh pretool <样例> <plan-dir>` 期待 rc=0 七项全过 ③缺字段对照 prompt 期待 rc≠0 缺项点名。判定=8 字段返回原文+两条 rc。

#### B-2 单写者澄清+Handoff 低频列折叠

- **改动面**：`critical-rules.md:133`（22.4a 增补：findings/progress 追加由子代理必做、主进程仅缺漏兜底、禁止双侧同写；**主进程 Read 复核义务不变**）；`templates/task_plan.md` Handoff 12 列中 rescue/retry_count/verify_done 折叠为「备注」单列；check-delegation.sh stats 兼容性核对。
- **预估收益**：消除双写不确定（01§二-B8），每派发省 1-2 Edit；表宽 -25%；委派误报源缓解。
- **质量风险**（终审轮 1 #4 已如实化）：本节点 grep 实证 verify_done 零机器消费（`grep -rn verify_done scripts/*.sh` 除 selftest 0 命中）——本项不新增也不声称机器门；其人工义务在 A-3 映射表登记「人工保留」。
- **护栏**：check-delegation.sh stats 对等价新旧表格 verdict/数字一致（对拍夹具入 selftest）；22.5 双条件语义原文保留。
- **36.4 删除性行为清单**：Handoff 表 12 列→10 列结构变更（列位折叠，字段内容不删）。
- **子代理干净上下文验证设计**：派发全新子代理，附新旧两版等价样例计划+stats 段源码，跑 `bash check-delegation.sh stats <plan-dir>` 期待 verdict/数字一致，并读码回答「stats 是否按列位解析 verify_done」期待「不解析」（如实证明机器门边界）。

### 簇③ 守卫与 selftest 的合并/懒/增量执行

#### C-1 hook 热路径合并执行包（六子项独立可回滚）

- **改动面**：
  - a① `zcode-pretooluse.sh:94` `CWD="${PWD}"`→stdin JSON `.cwd`（正确性修复：本节点 xtrace 实证 cwd=/tmp 仍扫本仓）。
  - a② Rule23 循环扫描集收窄（**v3 重设计，终审 #2 采纳**）：**仅剔除 outcome=COMPLETE 的历史计划**（复用 posttooluse:100-105 判定先例），**保留全部非 COMPLETE 计划**——在途/无指针/gc 后计划（24h 残留 gc 语义见 critical-rules.md:240）仍在检测集，收窄面仅及已交付历史；残留漏检面明示=「COMPLETE 后被带外改动的计划不再参与冲突提醒」；**与 f 项同规格先补行为级 selftest（新 selftest-rule23-conflict-scan.sh）再动：三夹具=①第二计划 scope 命中且非 COMPLETE→期待 [conflict] 提醒 ②COMPLETE 计划 scope 命中→期待不提醒（降噪为预期行为）③过期/无指针的在途计划→期待仍被扫到**；③ 每计划 5 进程 awk 链→单 awk 多文件输入。
  - b config 双层路径**全位点修复（v3 扩面，终审 #6 采纳）**：zcode-posttooluse.sh:109-116（5 键）+check-plan-dispatch.sh:115-116（step_max_minutes/files，:117 注释自认双层才是实际结构）+check-dispatch.sh:268（prompt_max_chars）+subagent-fallback.sh:46-52（provider_fallback 4 键）+check-complete.sh:470（fmea_enforce，本节点核验中发现的追加位点）。
  - c scope 提取管道四处复制（pretooluse:102,107/check-conflicts:108,134/sync-todos:197）→ `lib/plan-parse.sh` 单函数 source。
  - d `check-scope.sh:51` python3→`realpath -m`（:142-144 D10'' 篡改仲裁**零改动**——v2 已剔除该处短路）。
  - e `zcode-userpromptsubmit.sh:73-79` 6 进程字段提取→单 awk。
  - f `check-conflicts.sh` 9 处 git 调用合并（先补行为级 selftest 再动，review #27 零覆盖——本节点 grep -l 实证 rc=1）。
- **预估收益**：Edit 链 1329-1403ms→<500ms（R1 循环 833→<50ms）；UPS 1796/752→~400ms；PostToolUse 143→~60ms；每任务 ≈150-400 次进程孵化消除大半；R14 正确性缺陷全位点闭合。
- **质量风险**：awk 合并语义回归；a② 检测面变更；check-conflicts 无现有回归网。
- **护栏**：每子项同输入快照对拍 stdout/rc 逐字节；三门（scope/delegation/skill-modify）语义零改动；a②/f 先补 selftest 后动脚本；a② 三夹具入 selftest-rule23-conflict-scan.sh。
- **36.4 删除性行为清单**：a② Rule23 冲突检测扫描集由「全量 plans/」收窄为「非 COMPLETE 全保留」（检测面语义变更，残留面已明示）；其余子项为实现替换/修复。
- **子代理干净上下文验证设计**：派发全新子代理，附 worktree+plans 快照+三类 stdin JSON 夹具（Edit 带 file_path/Agent/普通 Bash）+cwd=/tmp 夹具+三冲突场景夹具，逐夹具改前（git show 取原脚本）/改后对拍 diff stdout 与 rc；期待=常规夹具逐字节一致、/tmp cwd 改后不误扫、三冲突夹具新 selftest 全 PASS；`bash -n` 全部改动脚本。

#### C-2 终验重复门内容哈希复用（v3：键④补全为消费键全集）

- **改动面**：仅 `check-complete.sh:459`（PLAN-DISPATCH 门）与 `:466-511`（FMEA 门）——四元内容键，终验实时计算、**任何位置不使用 mtime**：① 当前 task_plan.md 内容 sha256（实时计算，与 `.plan-attestation` 锁定哈希比对）② check-plan-dispatch.sh 文件哈希 ③ check-complete.sh FMEA 段哈希 ④ **两门实际消费的 config 键全集（v3 补全，终审 #3 采纳，本节点逐一实查）：`plan_tier_enforce`（cpd:74，warn↔enforce 改变 MISMATCH 阻断/放行）+`subagent.step_max_minutes`（:115）+`subagent.step_max_files`（:116）+`subagent.properties.step_max_steps`（:118）+`fmea_enforce`（check-complete:470）**；四元全一致→两门 `SKIP-BY-HASH` 引用 attest 结果；任一变化→全量重跑。**键④完整性由 selftest 断言守护：程序化 grep 两脚本的 `.properties.*` 键消费集合与键④枚举一致（终审 #3 指定）**。UPS:61/posttooluse 重锁零改动（v2 已废弃其 (mtime,size) 短路——touch -r 绕过窗口原理不可闭合，112ms/轮收益不值得裁决项化）。
- **预估收益**：终验 441→~250ms 量级（04 M13）；返工重验由全量重付减为增量。
- **质量风险与护栏**：「计划未变但门控脚本/config 已变→陈旧 SKIP」由键②③④闭合；touch -r 由键①内容哈希闭合；缓存键禁 mtime/size（selftest 断言）；TAMPERED 分支与 attest 本体零改动；无任何残留窗口退路。
- **36.4 删除性行为清单**：两门「无条件必跑」→「四元键一致时 SKIP-BY-HASH」（检测语义变更）。
- **子代理干净上下文验证设计**：派发全新子代理，六步夹具测试：①原样 `attest-plan.sh --verify`→rc=0 ②sed 改计划一字节→TAMPERED rc≠0 ③touch -r 恢复 mtime→仍 TAMPERED ④未变计划跑 check-complete→两门 SKIP-BY-HASH 其余门照跑终态 rc 不变 ⑤对 check-plan-dispatch.sh 加一行后同计划重跑→期待不 SKIP ⑥config 改 plan_tier_enforce 或 fmea_enforce 值→期待不 SKIP（键④生效证据）。

#### C-3 sync-todos --index 单 awk 全量重算（v3：删除 mtime 行级选项）

- **改动面**：`sync-todos.sh:215-233` 每 plan ≈8 子进程→单 awk 多文件聚合；`:271` 保持全量重写（**v3 删除「按 mtime 仅重写变化行」选项——终审 #4 采纳：critical-rules.md:240 实查「归档后必须重跑 sync-todos.sh --index 修正 INDEX 统计（全量重写特性,防回归）」，mv 归档不改 mtime、目录消失时行级增量不删旧行→29.6 防的统计回归复现**）；输出与现行**逐字节一致**；前置补 sync-todos --index 行为级 selftest（现有 selftest-active-plan.sh:117-121 仅覆盖 --json 向上解析，终审 #4 实查）。
- **预估收益**：2642→~300ms 级（02§1-B4）；每次 Phase 翻转省 ≈2.3s；4 触发点全受益。
- **质量风险与护栏**：rollup 语义漂移→INDEX 行错；护栏=37 计划仓改前/改后 INDEX diff 必须为空（唯一验收标准）+归档夹具（mv 一计划入 archive/ 后重跑期待该行同步消失——单 awk 全量重算天然处理，与 29.4 兼容）+SessionStart 待处理区解析回归。
- **36.4 删除性行为清单**：无行为删除（实现替换、输出字节不变）；登记实现替换项。
- **子代理干净上下文验证设计**：派发全新子代理：①改前快照 INDEX ②改后重跑 diff 期待空 ③mv 归档一计划后重跑期待仅该行消失 ④touch 单 plan 重跑期待输出与全量重算逐字节一致。

#### C-4 selftest 分域索引+开发期增量+终验全量强制

- **改动面**：新增 `scripts/selftest-registry.tsv`（27 脚本×消费域）；`critical-rules.md` Rule 36.6 增纯增子条「开发过程中间轮次跑改动域子集；交付终验必须全量 27 脚本 0 FAIL——全量总门不降」；registry 一致性自守护断言。
- **预估收益**（v3 绑定实录，终审 #11）：收益前提=实录存在开发中/多轮全量（task-v089 实跑 3 轮、task-v090 主仓+worktree 两轮，05:35 转引）——按 v090 形态省 1 轮、按 v089 形态省 2 轮×65.7s（04 M15）；若未来流程本就只跑终验一轮则收益趋零（如实声明）。
- **质量风险与护栏**：分域漏项→改动域漏测；护栏=registry 一致性断言+**终验全量 0 FAIL 条款原文保留**+部署位 selftest 保持全量（C-5 特记）。
- **36.4 删除性行为清单**：36.6 增补子条改变「每修改全量」的执行解读（增补非删除，终审 #11 指出仍属 36.4 语义变更范畴，列入清单交确认）。
- **子代理干净上下文验证设计**：派发全新子代理：①tsv 与 selftest 清单一致性检查 ②按场景「改 check-dispatch.sh」查子集实跑期待全 PASS 且 ≤25s 或 ≤40% 基线（回贴 time 原文）③改名场景期待守护断言 FAIL。

#### C-5 部署对账两级化

- **改动面**：`smart-merge-back.sh:555` 全树 diff→两级：第一级**确定性文件清单集合差**（find|sort 逐行 diff，抓增/缺/改名）；第二级内容定向 diff（git porcelain 程序化清单+task_plan Files 列，禁手填）+随机 ≥3 清单外同名文件内容抽检；三 slot 原子替换（:375）与 V1-V4 预检（:35-89）零改动。
- **预估收益**：交付尾段省 2 次全树**内容读取**成本（558+365+59 脚本规模）；集合差保留全树文件面。
- **质量风险与护栏**：清单外**同名文件内容**带外热改不在定向清单内（残留风险明示）；集合差为确定性断言；**部署位 selftest 保持全量不裁**——report §⑤-1 实证部署位 WF-10 FAIL 恰由它抓出。
- **36.4 删除性行为清单**：全树 diff→两级对账（检测语义变更）。
- **子代理干净上下文验证设计**：派发全新子代理 /tmp 沙箱 ≥8 文件两棵树四场景：①清单内内容差异→第二级报出 ②部署位多文件→集合差确定性报出 ③仓侧已删部署位残留→集合差确定性报出 ④全一致→IDENTICAL 正确。

---

## 四、Tier B 清单（须用户裁决；每项含否决出处与新证据论证）

| # | 方案 | 所触裁决与出处（critical-rules.md） | 新证据论证（瓶颈锚） | 采纳后验证设计要点 |
|----|------|-----------------------------------|---------------------|-------------------|
| T-B1 | 只读/写类分槽并行（只读 explore/调研类独立并行槽，写类串行不变） | **① Rule 21.4**（:122，2026-09-12 裁决，Why 自带 sess_1316c7f8 事故）；39.4 豁免登记制（:359）为先例模式 | R5：3 个独立只读探查=3× 串行等待；01§二-3/04§二-2 估省 30-50% 链式等待 | 全新子代理验证 2 个独立只读 S-unit 分槽并发+写类槽锁仍 exit 2 |
| T-B2 | mini 验收 Phase 合并单 Phase | **⑤** 19.2 每 Phase 双条件（:96）+check-complete.sh:547-550,637-638 mini V-N 随 Phase 数减半+**Rule 38.3③**（38.3 位于 :337，§38 头 :331） | R17：3 行修改验收独立闭环 ≈10 动作 | 单 Phase mini 过 attest/check-complete 全链（VC≥2/V-N 以「总计 ≥2」等价入机器门）+3-File 门仍咬缺回填样例 |
| T-B3 | mini 默认 silent 消 D1 往返 | 28.2 D1（:226）+config.json:58-59 default=ask+宪法 §四批准语义 | R12：简单任务墙钟下限=用户响应时间；01§二-7 明示须用户显式裁决 | mini 任务 silent 档全链跑通+静默决策清单含 D1 等价登记行 |
| T-B4 | Rule 14 白名单⑥扩展（mini ≤30 行非保护区直做+登记）或 mini floor 降 0.0 | Rule 14（:54-55）+25.3（:176）+SKILL.md:31 第一设计目标+config.json:36-42 | R13：微小任务无直做通道=简单任务慢最大单一来源 | ≤30 行直做过终验按新口径+>30 行仍强制派发 |
| T-B5 | 短任务 T5 免写/8 字段即最终结论 | **⑤** 22.8.2（:142）+22.4b（:134）；v056 实证 12 派发 0 自带三文件（check-dispatch.sh:60-62） | R10：每 S-unit 省 2-3 子代理动作 | 检查点仅 T1-T4 落盘+三证据以返回消息+产出 Read 复核承载（降档后果显式登记） |
| T-B6 | CR 按 diff 分级+code-runner/build-error 合并单代理 | **③ Rule 26**（:182）+**④** 拆细先于升档（:129）；另贴靠 v083 否决「以速度为由压缩验证」（2026-09-18，plans/task-v083/notepad-learnings.md）双重理由 | R25：返工期乘法结构 | 轻 diff 走分级 CR 通过+重 diff 仍全量审查 |
| T-B7 | findings 增量条件放宽（纯实施 Phase 一行声明计增量） | **⑤** 19.2 实质增量语义（:96）；check-3file-gate.sh:12-16「宁可误报」自证属语义变更 | R8 关联：每 Phase 省 0-1 制造性写入，收益小 | 一行声明过门+有调研 Phase 仍要求实质增量 |

历史否决核对（本节点两轮实跑，v2 修正后口径）：真实否决共 **4 条**——task-v076（2026-09-16）2 条（未查证能力否定结论禁止上报/Rule 35.2；prompt 大内容必须落盘+Read/Rule 35.3）+task-v083（2026-09-18）2 条（无试点批量/以速度压缩验证）。本批对照：无重提 v076 两条（B-1 示例外置化与 v076 否决②「落盘+Read」方向一致）；Tier A 无批量写操作；T-B6 贴靠 v083 否决②故留 Tier B。v091 notepad 否决段为空模板（sed 实读）。

---

## 五、质量护栏段（逐项：不可削弱门控 + 守护 selftest 名 + 子代理干净上下文验证设计）

> 守护 selftest 名为本节点 `grep -l` 实测映射（27 个 selftest 文件名 `ls` 实查），非推断。每条的验证设计均按用户 2026-09-26 补充裁决（§头⑦原文）由全新干净上下文子代理执行。

| # | 不可削弱门控 | 条款/脚本锚 | 守护 selftest | 子代理干净上下文验证设计（无削弱证明） |
|---|-------------|------------|---------------|--------------------------------------|
| G1 | Rule 21.4 串行派发铁律（用户裁决①） | critical-rules.md:122；check-dispatch.sh:350-376 槽锁 age<120s exit 2 | selftest-dispatch.sh | 双派发夹具：同计划连续两次 Agent 调用，第二发期待 `[dispatch-block]` + exit 2——Tier A 全项不改派发时序，此回归每项合入后必跑 |
| G2 | Rule 18.9/18.11 试点先行/宁慢勿错（用户裁决②） | critical-rules.md:86,:88 | selftest-batch-pilot.sh | Tier A 无批量写操作（六子项均为单文件修改）；若未来引入任何 ≥2 同构对象写操作，先单件试点全链通过并落 progress 证据（C-1 六子项天然逐项独立 commit） |
| G3 | Rule 26 质量优先（用户裁决③）+终验门组 | critical-rules.md:182-210；check-complete.sh 全链 | selftest-vc-gate.sh / selftest-error-loop.sh / selftest-reflect-verify.sh / selftest-mechanism-profile.sh / selftest-delegation.sh / selftest-skill-modify.sh / selftest-plan-tier.sh | C-2 仅两门四元键一致 SKIP、其余门照跑；C-4 终验全量总门原文保留。验证：改动后对 task-v090 式完结计划跑 check-complete 期待 rc=0 且各门输出齐全（对照改前快照） |
| G4 | 三证据/派发契约（22.4/22.4a/22.4b/22.8.2） | critical-rules.md:132-135,:142；check-dispatch.sh 七项+四项 | selftest-dispatch.sh + selftest-fine-grain-steps.sh + selftest-conclusion-discipline.sh | B-1 压缩的是示例载荷、字段与判定零改动。验证：好/坏 prompt 样例双向 rc（好=0 七项过、坏=rc≠0 缺项点名）+子代理按契约返回 8 字段 |
| G5 | 3-File 门控（19.2/19.5，用户裁决⑤） | critical-rules.md:96,:99；check-3file-gate.sh+check-complete 3-File stub 段 | selftest-knowledge-brief.sh（check-3file-gate 唯一 selftest 引用位，实测）+ G3 系（check-complete 段） | A-3 不动 19.2 本体。验证：缺回填样例期待 exit 1 禁翻转 complete；A-3 COMPLIANCE-CHECK 对缺 C 项产物计划 warn 点名（先加后删无空窗） |
| G6 | attest 防篡改（Rule 20.1）+D10'' 仲裁 | attest-plan.sh --verify；check-scope.sh:140-145；zcode-userpromptsubmit.sh:61 | selftest-active-plan.sh / selftest-execution-stability.sh / selftest-methodology.sh / selftest-plan-dispatch.sh / selftest-plan-tier.sh / selftest-template-lifecycle.sh | v2/v3 已废弃全部 mtime 信任面（C-2 键①纯内容哈希；C-1d 不触碰 :142-144）。验证：C-2 六步之②③——改一字节→TAMPERED；touch -r 恢复 mtime→仍 TAMPERED |
| G7 | 委派门（Rule 25） | critical-rules.md:175-177；check-delegation.sh | selftest-delegation.sh + selftest-execution-stability.sh | B-2 折叠列后 stats 对等价新旧表格 verdict/数字一致+verify_done 缺失场景不虚报（如实边界） |
| G8 | Rule 29.4 INDEX 全量重写防回归 | critical-rules.md:240（「全量重写特性，防回归」实查） | selftest-active-plan.sh（现仅 --json 覆盖——终审 #4 证实缺口） | C-3 前置补 --index 行为级 selftest（含归档夹具）；验证：37 计划仓快照 diff 为空+mv 归档后行同步消失 |
| G9 | 冲突检测职能（Rule 23 P0） | zcode-pretooluse.sh:91-116+check-conflicts.sh（review #27 零覆盖实证） | 新增 selftest-rule23-conflict-scan.sh（C-1a② 前置）+check-conflicts 行为级 selftest（C-1f 前置） | a② 仅剔 COMPLETE、非 COMPLETE 全保留。验证：三夹具（第二计划命中→提醒/COMPLETE→不提醒/无指针在途→仍扫到）全 PASS |
| G10 | mini 门控语义（Rule 38+VC-GATE mini 分支） | critical-rules.md:331-341；check-complete.sh:547-550,:637-638；cpd:91-103 MISMATCH 探针 | selftest-plan-tier.sh | A-1 不扩 mini 豁免面只提命中率+auto_tier 终验复核。验证：四组构造任务 frontmatter 断言+AUTO-TIER 复核段对超限 auto_tier 计划 WARNING |

**用户 2026-09-26 补充裁决落实声明**：上表 G1-G10 每条验证设计与 §三各项验证设计均指定由**全新干净上下文子代理**执行（prompt 自含全部夹具与绝对路径、无主会话记忆），产出物（rc/输出原文/文件产物）即验证证据；主进程上下文内的自测不作为有效验证提交。

---

## 六、批判轮次记录（两轮意见与逐条处置）

### 轮 1（质量降级风险镜头 11 项 + 用户裁决与禁令镜头 3 项，全部采纳，v2 落地）

| # | issue（严重度） | 处置 | 本节点验证证据 |
|---|----------------|------|---------------|
| 1 | A-2 死代码定性被实验证伪（high） | A-2 全项重定性：放弃删除、仅补口径注释 | 复现实验 /tmp/a2verify：原版 rc=0、删 :178-180 rc=1；settle_phase 源码+cpd:5 实读 |
| 2 | C-2 脚本/config 变化复用陈旧判定（high） | 缓存键纳入脚本哈希+config 值；补验证步⑤⑥ | check-complete.sh:459 重跑 cpd 属实（v1 已抽查） |
| 3 | C-1d 短路用在 D10'' 篡改仲裁（medium） | 剔除该子项 | check-scope.sh:140-145 实读为实时 sha256 仲裁 |
| 4 | B-2 verify_done 第三样例不可操作（medium） | 删不可操作样例；义务登记 A-3 人工保留项 | grep verify_done scripts（除 selftest）0 命中 |
| 5 | B-1 与 22.4b 冲突（medium） | 22.4b 同步修订入改动面绑定同 commit（行号修正：原文在 :134，:135 为 22.4c） | grep -n "^22.4b" → :134 含「必须附该模板与一份已填示例」 |
| 6 | C-5 清单外漂移漏检（medium） | 两级对账（确定性集合差+内容定向） | 设计层采纳 |
| 7 | A-1 三条件缺风险维度（medium） | 增④排除条件+selftest 断言+夹具丁组 | 设计层采纳 |
| 8 | plan-resume 收益对 mini/simple 不成立（low） | R2/R7/A-3 收益面限定 >3 Phase | critical-rules.md:169 实查「≤3 个 phase → 跳过」 |
| 9 | A-4 Learning-Gate 锚失准（low） | 更正为消费 progress Error Log 列；结论不变 | grep notepad check-complete.sh 0 命中；:695-697 注释实读 |
| 10 | C-4 无判定阈值（low） | ≤25s 或 ≤40% 基线+回贴 time 原文 | 设计层采纳 |
| 11 | 否决普查漏计 task-v076（medium） | 普查修正为 4 条（v076×2+v083×2） | v076 notepad :20-21 实读（v1 grep 模式漏 `- 2026-09-16 用户否决：` 前缀） |
| 12 | C-2 残留窗口退路=门控削弱留 Tier A（medium） | 删退路；mtime 短路整体废弃；改纯内容哈希键 | 内容 sha256 对 touch -r 必检出（内容哈希必变）逻辑核验 |
| 13 | T-B2 行号微漂（low） | 改 38.3:337（§38 头 :331） | sed -n '331p;337p' 实查 |
| 14 | Tier B 无验证设计（low） | 表下增验证要点注记 | 设计层采纳 |

### 轮 2（终审独立复核，12 项：2 high + 5 medium + 5 low，本节点逐条实证后全部采纳，v3 落地）

| # | issue（严重度） | 处置 | 本节点验证证据 |
|---|----------------|------|---------------|
| 1 | Tier A「纯增量实施」定性漏 36.3/36.4（high） | 定性修正为「不触①-⑤+删除性行为逐项清单待 36.4 确认」；每项增 36.4 清单字段；§七 增确认流程 | critical-rules.md:313-316 实读：36.3 修改前基线/36.4「任何功能性删除或既有语义改写→逐项列清单交用户确认（D6 级）」 |
| 2 | C-1a② 扫描集收窄零守护+gc 漏检面（high） | 重设计：仅剔 COMPLETE、非 COMPLETE 全保留；先补 selftest-rule23-conflict-scan.sh 三夹具；残留面明示 | `grep -l check-conflicts selftest-*.sh` rc=1（零覆盖）；24h gc 语义 critical-rules.md:240 实查 |
| 3 | C-2 键④漏 plan_tier_enforce（medium） | 键④改为两门消费键全集（plan_tier_enforce/step_max_minutes/step_max_files/step_max_steps/fmea_enforce）+程序化 selftest 断言 | cpd:74,:115,:116,:118 与 check-complete:470 逐一实查 |
| 4 | C-3 mtime 行级选项与 29.4 冲突（medium） | 删除该选项，仅保留单 awk 全量重算同字节输出；补归档夹具；前置补 --index selftest | critical-rules.md:240 实查「归档后必须重跑 sync-todos.sh --index 修正 INDEX 统计（全量重写特性，防回归）」；selftest-active-plan.sh:117-121 仅 --json |
| 5 | A-3 漏盘 10 个 selftest C 项静态锚（medium） | 改动面增列受影响 selftest 清单+锚 token 保留约束 | grep -l '\| C[0-9]' → 10 个 selftest（veto:47/error-loop:55/skill-modify:11,56/plan-tier:73/workflow-orchestration:49 逐个实查+conclusion-discipline/mechanism-profile/reflect-verify/task-boundary/template-lifecycle） |
| 6 | R14 仅修 1/4 位点（medium） | C-1b 扩为全位点（+cpd:115-116/check-dispatch:268/fallback:46-52/check-complete:470） | 四位点逐一实查均单层路径（cpd:117 注释自认双层才是实际结构） |
| 7 | A-1 误判闭环止于 warn（medium） | auto_tier frontmatter 标记+check-complete AUTO-TIER 复核段（warn 起步） | cpd:101 实查 warn「提示不阻断」/enforce 才 exit 1 |
| 8 | A-1×A-3 COMPLIANCE-CHECK 需 tier 感知（low） | A-3 护栏补前置 plan_tier 判定/映射表分域 | 设计层采纳 |
| 9 | A-3×B-2 compass 误报放大（low） | A-3 护栏补 compass 信号源评估（切 ledger 或阈值联动） | critical-rules.md:102（19.7）实读 |
| 10 | drift 二选一缺三态对拍（low） | 护栏补 ALIGNED/DRIFT/BLOCKED 对拍夹具 | critical-rules.md:38-46 三态实查（grep 三词全命中） |
| 11 | C-4 收益前提存疑+36.6 增补属 36.4（low） | 收益绑定实录（v089 3 轮/v090 2 轮）+36.6 增补列入 36.4 清单 | 05:35 转引 task-v090 verification.md 两轮实录；04§二-3 v089 三轮 |
| 12 | B-1 22.4b↔模板一致性零机器守护（low） | 增静态 selftest 断言（22.4b 引用↔dispatch-examples.md 存在） | grep 22.4b/已填示例 selftest-*.sh 0 命中（实查） |

---

## 七、实施顺序与 Rule 36.4 确认流程

1. **36.4 逐项确认前置步**：用户批准本提案 = 对 §三各 Tier A 项「36.4 删除性行为清单」（共 9 项含删除/语义改写，A-2 除外）的一次性逐项确认；ask 模式下建议按项 AskUserQuestion 逐项过（36.4 D6 级语义）。确认前任何 Tier A 项不得动手。
2. **实施顺序**（每项独立 worktree+独立 commit，任一项可单独回滚）：① 质量增强型：C-1b（全位点双层路径）→ C-1a①（stdin cwd）② 纯性能型：C-1 其余子项（a②/f 先补 selftest）→ C-2 → C-3（先补 --index selftest）③ 机制型：A-1 → A-2 → C-4（先 registry 后增量）④ 流程型：A-3（先加后删）→ B-1（22.4b 绑定）→ B-2 → C-5。
3. **每项合入前**：§三该项子代理干净上下文验证通过 + §五 G1-G10 相关护栏回归 + selftest 终验全量 27 脚本 0 FAIL（部署位与仓侧双侧）。

## 八、诚实边界

1. 本提案计时/clone 计数转引自 01-04 取证（三源同对象数字存在区间，如 UPS 1796/752-3060/752ms，均如实保留；相对结论稳）；本节点未实跑 selftest 全量与 hook 计时复测。
2. selftest 断言基线 453（report 实测）vs 457（task-v090 verification 记载）差异未裁决。
3. SessionStart 23.7s 冷启动离群未定位，不作为优化标的。
4. a② 残留漏检面（COMPLETE 后带外改动计划不再参与冲突提醒）与 C-5 残留面（清单外同名文件内容带外热改靠概率抽检）均已在正文明示，非零风险项。
5. C-4 收益绑定实录前提（§三），若流程本就单轮全量则收益趋零。
6. 三份取证行号基于审计时刻工作区（基线 87d306b 前后），本节点累计抽查 40+ 锚全部命中；实施期按当次 worktree 重新定位。
