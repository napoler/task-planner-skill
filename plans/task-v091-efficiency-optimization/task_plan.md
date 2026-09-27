<!-- template_type: rule-enhancement -->
<!-- 适用场景: task-planner 技能效率优化——机制性慢源定位（简单/复杂任务全链路）→ 两轮批判检验的优化提案 → 用户裁决 → 纯增量实施 + selftest 守护 → 部署簿记 -->
<!-- 触发关键词: 效率优化/执行缓慢/提速/慢源定位/不降质量 -->
<!-- 推荐 subagent: dynamic-workflows 编排取证（用户 /workflow 显式授权）; executor(sonnet-1) 精修与实施; code-runner-agent 跑 selftest; 合并部署主进程 -->
<!-- 沉淀出处: task-v091（D 类新任务，Rule 8.1 判定；上游=task-v089 全量审查报告 plans/task-planner-skill-review/report.md 的效率类发现） -->

# Task Plan: task-planner 技能执行效率优化（简单/复杂任务慢源定位 + 两轮批判优化提案，质量门控零削弱）

<!-- plan_tier: standard -->
## Goal
定位 task-planner skill 在简单/复杂任务下执行缓慢的机制性根因，产出经两轮批判检验、用户裁决采纳后纯增量实施的优化提案，全量 selftest 0 FAIL 且既有质量门控（Rule 26/18.9/21.4 串行/三证据/3-File/verification）零削弱。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（Phase 3 改动含 .sh 脚本与规则条款） |
| `interaction_mode` | `ask`（Phase 2 用户 D1 裁决为硬门） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 瓶颈清单每条含实证锚（SKILL/critical-rules 文件:行 或 计时数据或派发开销计数），4 取证领域（派发协议开销/守卫脚本与 hook 开销/简单任务全链路/复杂任务全链路）各 ≥3 条，无凭记忆断言 | Read workflow-evidence/01..04 取证文件逐条核对锚 | `plans/task-v091-efficiency-optimization/workflow-evidence/01..04-*.md` |
| VC-2 | `workflow-evidence/efficiency-proposal.md` 存在且经两轮批判修订（批判记录可查：每轮含对前稿的反例/风险点 + 修订响应），Tier A 逐项含质量保持论证 | Read 提案的「批判轮次记录」段 + Tier A 表逐行核 | `plans/task-v091-efficiency-optimization/workflow-evidence/efficiency-proposal.md` |
| VC-3 | 提案含独立「质量护栏」段：明确列出不可削弱项（Rule 21.4 串行派发=09-12 裁决、Rule 26 质量优先、Rule 18.9 试点先行=09-18 训诫、三证据/3-File/verification 门控）+ 每项对应的守护 selftest 名 | Read 护栏段 + grep 对应 selftest 脚本存在 | 提案护栏段 + `skills/task-planner/scripts/selftest-*.sh` |
| VC-4 | 用户裁决记录在 Decisions Made（D1：Tier A 采纳清单 + Tier B 单列裁决结果）；采纳项实施后主仓全量 selftest 主进程逐脚本 Total 行求和 = 0 FAIL（当前基线 457 PASS/27 脚本，实施后 ≥457 且 FAIL=0；禁采信子代理自报总数） | `for f in scripts/selftest-*.sh; do bash $f; done` 逐脚本求和 + Read Decisions Made | progress.md Selftest Log + task_plan.md Decisions Made |
| VC-5 | 部署三实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）`diff -r` 与仓侧 IDENTICAL；关键改动文件（提案采纳项涉及的脚本/条款）逐一 Read 复验语义 | `diff -r <repo>/skills/task-planner <deploy>/skills/task-planner` ×3 + Read 抽验 | Phase 4 progress.md 部署记录 + diff 输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 取证/提案（Phase 1-2） | `plans/task-v091-efficiency-optimization/workflow-evidence/*.md`（新建取证 4 件 + efficiency-proposal.md） | 碰 skill 本体任何文件 |
| 规则条款（Phase 3） | `skills/task-planner/references/critical-rules.md`（纯增量：新 Rule 块/新子条追加） | 改既有规则语义；废除/绕过 Rule 21.4 原文 |
| 脚本（Phase 3） | `skills/task-planner/scripts/` 内提案采纳项点名的脚本（纯增量或行位微调）+ 新建 selftest | 未在提案/裁决清单内的其他脚本 |
| SKILL（Phase 3） | `skills/task-planner/SKILL.md`（**净增 ≤10 行**：索引行/摘要行行位替换优先） | 大段新增；行数断言（4 处 ≤558）超限 |
| 文档（Phase 3） | `skills/task-planner/references/template-mapping.md`（如提案涉模板联动）；`plans/task-v091-efficiency-optimization/` 全部计划文件 | 其他 references/；旧计划 task-v089/v090 原样保留禁碰 |
| 部署（Phase 4） | 3 实体位经 `smart-merge-back --deploy` 写入 + `plans/INDEX.md` 刷新 | 手工散拷部署位 |

**强制约束（硬约束——写入 Decisions Made 与提案护栏段，不可削弱）**:
- ① Rule 21.4 串行派发 = 用户 2026-09-12 裁决（critical-rules.md:122）：提案只可优化**单次派发的协议/材料开销**；废除/绕过/并行化 = Tier B 单列交用户裁决（按 Rule 32.4 引用本指令为新证据并标注否决出处 critical-rules.md:122 / 2026-09-12 sess_1316c7f8）
- ② Rule 26 质量优先于速度（:182）、Rule 18.9 批量试点先行（:86，用户 09-18 训诫 :87-88）、小步快跑拆分（09-09 用户核心诉求）三项不可削弱
- ③ 三证据验证 / 3-File 门控（Rule 19.2/19.5）/ verification 门控全部保留，优化只可降**开销**不可降**判定力**
- ④ Phase 3 默认纯增量（Rule 36.5，critical-rules.md:315）；语义变更须逐行登记执行范围表 + progress 新旧对照
- ⑤ Phase 1 并行取证依据 Rule 39.4（用户显式 /workflow 授权，critical-rules.md:359）：豁免登记 Decisions Made + progress.md 后方可在 workflow run 内并行；Phase 2-4 回归 Rule 21.4 严格串行
- ⑥ scope_files（Phase 3 允许文件细单）待提案定稿后由 B 类重规划回填——届时执行范围表逐行补登，attest 重锁
- ⑦ 【用户补充裁决 2026-09-26】技能修正/技能修改或其他涉及上下文的修改之后，必须在**子代理（全新干净上下文）**中测试验证；主进程既有上下文内的测试不视为有效验证（受先前上下文影响，无法确保干净独立）。提案每个方案/Tier A 每项必须自带「子代理干净上下文验证设计」，Phase 3 每 S-unit 验收按此执行
- ⑧ 【用户授权 2026-09-26】全链路推进：优化完成后合并所有修改并完成部署（Phase 3→4 连续执行）；Tier B 涉裁决项仍按计划单列交用户裁决，不因本授权跳过

## Phases

### Phase 1: /workflow 动态工作流审计 + 方案设计（4 领域并行取证 → 综合 → 3 方案 → 两轮批判 → 终稿）
- [x] CreateWorkflow 启动（Rule 39.1 显式点名路由）；39.4 并行豁免登记 Decisions Made + progress.md
- [x] 4 领域并行取证落 workflow-evidence/01..04-*.md（每领域 ≥3 条瓶颈，条条带 file:line/计时锚）→ 综合成瓶颈总表
- [x] 3 方案设计（各含改动面/预估收益/质量风险/护栏）→ 批判两轮（轮 1 质量降级风险+用户禁令 Rule 32.2 检查；轮 2 修订稿复核+反例补刀）→ 终稿 efficiency-proposal.md（Tier A/B 分层 + 质量护栏段）
- [x] 3-File 回填（findings 瓶颈总表摘要 / progress Actions）+ check-3file-gate 过 → complete
- **Status:** complete
- **Executor:** dynamic-workflows 编排（用户已显式 /workflow 授权，Rule 39.1 路由；CreateWorkflow 承载 4 领域并行取证+综合+批判循环；39.4 并行豁免已声明，登记后生效——例外理由：用户显式点名 workflow 编排，官方「explicit request is binding」）

<!-- S-unit 表：workflow 内部步骤非 Agent() 派发（39.5：派发契约非 hook 强制，此处表为编排蓝图） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 4 领域并行取证（派发协议开销/守卫脚本与 hook 开销/简单任务全链路/复杂任务全链路），各落 1 份取证文件 | workflow subagent（并行 fan-out，39.4 豁免内） | skills/task-planner/SKILL.md（558 行：L88-120 执行循环 6 步+2.5 委派检查点、L210 用户新指令处理）；references/critical-rules.md（365 行：L122 Rule 21.4、L86-88 Rule 18.9/18.11、L182 Rule 26、L135 22.4c hook 守卫）；scripts/ 59 个 .sh/.cjs（check-dispatch/check-3file-gate/check-complete/attest-plan/zcode-userpromptsubmit）；config.json 40 键 | 01..04-*.md 各 ≥3 条瓶颈、每条含 file:line 或计时数据 | 20min | pending |
| S2 | 综合 4 份取证 → 瓶颈总表（按开销频次×影响排序）+ 3 方案设计 | workflow 编排主链 | workflow-evidence/01..04-*.md（S1 产出）；plans/task-planner-skill-review/report.md（28 条发现，L21/38/49 效率类：goal-gate mini 未同步/VC-GATE 硬编码等） | 总表每条回链 01..04 小节号；3 方案各含改动面/收益/风险/护栏 | 10min | pending |
| S3 | 批判两轮：轮 1 质量降级风险 + 用户禁令全查（32.2 三禁令源）；轮 2 修订稿复核 | workflow 编排主链（critic 视角） | S2 瓶颈总表+3 方案；禁令源=plans/task-v091-*/notepad-learnings.md + plans/*/notepad-learnings.md 历史段 + memory | 两轮记录可查（每轮列反例/风险+响应）；Tier A 逐项质量保持论证成文 | 12min | pending |
| S4 | 终稿 efficiency-proposal.md（Tier A 不触裁决 / Tier B 单列引 32.4）+ 护栏段 | workflow 编排主链 | S3 批判记录；critical-rules.md:272（Rule 32.4 解禁格式） | 提案含 Tier A/B 分层+护栏段（4 不可削弱项+对应 selftest 名）；落盘待 Read 复核 | 8min | pending |

### Phase 2: 提案精修 + 用户裁决（Tier A 直接采纳 / Tier B 单列交 D1 决策）
- [x] 主进程 Read efficiency-proposal.md 全文复核 + 与取证文件抽查互证（≥3 条回链，实际 6 锚全命中）- [x] 提案精修：Tier A 逐项实施细节已在提案 §三（改动面到行号+36.4 清单+验证设计）；scope_files 细单经 D1 裁决固化为 Phase 3 S-unit 表（下方实例化）
- [x] 向用户展示提案（Tier A 推荐清单 + Tier B 裁决单）→ 等待 D1 决策（ask 模式硬门）；裁决结果登记 Decisions Made（用户「采纳」：Tier A 全采纳 + Tier B 暂缓）
- [x] 3-File 回填 + gate 过 → complete（scope_files 细单已按采纳项草拟并实例化进 Phase 3 S-unit 表）
- **Status:** complete
- **Executor:** 主进程（白名单②计划系统文件写入 + 用户交互 D1 裁决；例外理由：用户裁决不可代理，精修对象为 plan 目录内文档，白名单内）

### Phase 3: 实施采纳项（worktree 隔离 + 纯增量优先 + selftest 守护）
- [x] worktree 建立（`/mnt/data/dev/task-planner-skill-worktrees/task-v091`，branch wt/task-v091-efficiency-optimization，宪法 §十一新路径规范）+ 基线复跑（2026-09-26 实测：27 脚本逐行求和 **457 PASS/0 FAIL 全 rc=0**，与 v090 基线一致）
- [x] **B 类重规划（2026-09-26 完成）**：scope_files 细单 + S-unit 表已按 D1 采纳项（Tier A 10 项）实例化（下方表）；attest 重锁后动刀
- [x] 按 S-unit 串行实施（Rule 36.5 纯增量优先；语义变更逐行登记+新旧对照）；SKILL 行数变更同步 4 处 selftest ≤558 断言（selftest-batch-pilot BP-08 / selftest-knowledge-brief T2b / selftest-execution-stability T8b / selftest-skill-collab T10，A-3 改写 C 表可致行数变化）（S11-S30 全部 complete，S-unit 表逐行带 commit sha）
- [x] **子代理干净上下文测试（硬约束⑦）**：每项改动生效验证派全新子代理执行（S32 验证包 3/3 组 g1-hooks/g2-mech-flow/g3-guards 全 PASS；g3 双干净上下文独立复验 18/18；另本会话 S32-verify-group1..5 五组派发：g1 C-1 六子项 PASS / g2 A-1+A-2 PASS / g3 A-3 三小项 PASS / g4 B-1+B-2 PASS / g5 C-2/3/4 PASS + **C-5 locale 缺陷实证**（comm 未 pin→zh_CN 假 IDENTICAL）→ S33 修复闭环 cc64c1b+eb7d728；主进程上下文自查不作为有效验收——全部验证均在全新子代理完成，检查点落盘 subagent-state/S32-*.md）
- [x] 新增/修订 selftest 守护 + worktree 内全量回归 0 FAIL → 3-File 回填 → complete（S31 全量 32 脚本 516/0；新增 6 脚本 rule23-conflict-scan/check-conflicts/sync-index/final-gate-hash/registry+dispatch DX 断言；3-File 已回填）
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行派发（Rule 21.4；worktree 内逐 S-unit 派发，22.4 九字段 prompt + 22.8 检查点）

<!-- S-unit 表：B 类重规划 2026-09-26 实例化；输入列 P§n=提案 efficiency-proposal.md §三小节锚；每项独立 commit 可单独回滚（提案 §七） -->
| ID | 目标(≤1 句) | 执行体 | 目标文件 | 验收(可观察) | 状态 |
|----|------------|--------|----------|-------------|------|
| S11 | C-1b 位点组 1：config 双层路径修复（P§三C-1b） | executor | zcode-posttooluse.sh、check-plan-dispatch.sh | config 覆盖值生效（临时 config 夹具实测读出覆盖值，非 default 兜底） | complete(de69956) |
| S12 | C-1b 位点组 2：同修复扩面（P§三C-1b） | executor | check-dispatch.sh、subagent-fallback.sh、check-complete.sh | 同上三位点逐一夹具验证 | complete(2d5f791，扩面 14 处) |
| S13 | C-1a① stdin .cwd 修复（P§三C-1a①） | executor | zcode-pretooluse.sh | cwd=/tmp 夹具不再误扫本仓（xtrace 或输出对照） | complete(6e79257) |
| S14 | C-1a② 前置：Rule23 冲突扫描行为级 selftest 三夹具（P§三C-1a②）+ check-delegation:131 C-1b 补位点（S13 发现③并入） | executor | scripts/selftest-rule23-conflict-scan.sh（新建）、check-delegation.sh | 三夹具按提案期待语义落 selftest；现行基线如实红（1/3 PASS——R23-01/03 根因=awk 正则缺陷 scope 提取恒空，已锚定），S15 改后转绿 3/3【2026-09-27 B 类微修：原验收「全 PASS（对现行实现）」措辞与提案 TDD 设计（红→绿）不符，按提案原文 L129-130 修正】 | complete(fb67f3a) |
| S15 | C-1a②③ 扫描集收窄（仅剔 COMPLETE）+5 进程 awk 链→单 awk + 提取正则修复（P§三C-1a②③） | executor | zcode-pretooluse.sh | S14 三夹具 3/3 PASS 转绿+R1 实测 <500ms+常规对拍逐字节+verification.md 兜底专项（V1-V4） | complete(fb28b70) |
| S16 | C-1c scope 管道 lib 化组 1（P§三C-1c） | executor | lib/plan-parse.sh（新建）、check-conflicts.sh、zcode-pretooluse.sh（注释锚） | scope 提取对拍（37 计划 byte-identical/真实 --runtime 零回归）+假阳性 528→5 净改进+selftest 3/3 保持 | complete(73730f7) |
| S17 | C-1c/d 续：sync-todos 调用点替换 + check-scope python3→realpath（P§三C-1c,d） | executor | sync-todos.sh、check-scope.sh | 对拍一致（37/37 计划+10/10 realpath 组）+篡改仲裁段零 diff+3 selftest 全绿 | complete(28221a7) |
| S17 | C-1c/d 续：sync-todos 调用点替换 + check-scope python3→realpath（P§三C-1c,d） | executor | sync-todos.sh、check-scope.sh | 对拍一致+篡改仲裁段 :142-144 零 diff | pending |
| S18 | C-1f 前置 selftest+9 处 git 调用合并（P§三C-1f，先补后动） | executor | scripts/selftest-check-conflicts.sh（新建）、check-conflicts.sh | 夹具先 PASS（改前 6/6）→改后仍 6/6+五类信号输出语义一致（IDENTICAL）+git 调用 9→6 | complete(24e6609) |
| S19 | C-1e UPS 6 进程字段提取→单 awk（P§三C-1e） | executor | zcode-userpromptsubmit.sh | 注入内容 diff 为空（5 场景对拍逐字节含对抗边界）+单次耗时下降（中位 248→195ms） | complete(aff5e06) |
| S20 | C-2 终验两门四元内容键 SKIP-BY-HASH+selftest（P§三C-2） | executor | check-complete.sh、scripts/selftest-final-gate-hash.sh（新建） | 六步夹具全 PASS（22 断言：TAMPERED 仍抓/touch -r SKIP/未变 SKIP 余门照跑/键①②③④各变化不 SKIP/损坏兜底/真变化仍拦）+7 既有 selftest 回归零失败 | complete(216e912) |
| S21 | C-3 --index selftest 前置+单 awk 全量重算（P§三C-3） | executor | scripts/selftest-sync-index.sh（新建）、sync-todos.sh | 37 计划仓 INDEX 改前/改后 diff 为空+归档夹具行同步消失+selftest 13/13 前后（execve 861→8、2744→107ms） | complete(d3a787c) |
| S22 | A-1 机制层：init-session auto-tier 四条件+critical-rules 38.6（38.5 已被 v086 占用，纯追加顺延）+auto_tier 标记（P§三A-1） | executor | init-session.sh、critical-rules.md | 四组构造任务 frontmatter 断言（mini/general/显式优先/④排除）全过+28/28 零回归 | complete(3ad2adb) |
| S23 | A-1 消费层：SKILL L64+check-complete AUTO-TIER 复核+selftest-plan-tier 增断言（P§三A-1） | executor | SKILL.md、check-complete.sh、selftest-plan-tier.sh | AUTO-TIER 对超限 auto_tier 计划 WARNING+selftest 32 PASS 0 FAIL（+final-gate-hash 22/0 零扰动+SKILL 净增 0） | complete(9026ca9) |
| S24 | A-2 38.4③ 口径注释（纯注释零删除，P§三A-2） | executor | critical-rules.md | 脚本 diff 为空+三例夹具与口径一致+无 Executor 行样例 check-plan-dispatch rc=0 | complete(40a1880) |
| S24 | A-2 38.4③ 口径注释（纯注释零删除，P§三A-2） | executor | critical-rules.md | 脚本 diff 为空+无 Executor 行样例 check-plan-dispatch rc=0 | complete(40a1880) |
| S25 | C-4 registry.tsv+36.6 增补子条+一致性自守护（P§三C-4） | executor | scripts/selftest-registry.tsv（新建）、critical-rules.md | 一致性断言 PASS（32/32 对齐+改名负例咬住）+按场景子集实跑 ≤25s（23.7s 实测） | complete(3cdab78) |
| S26 | A-3 流程层：SKILL 三处（102/107/173-204 C 表改写）+Rule 15/24 同步（P§三A-3） | executor | SKILL.md、critical-rules.md | drift 恰 1 次/无 plan-resume/C 项仅列脚本未覆盖；三态对拍等价；10 selftest 锚核对冲突=0；SKILL 558→556 | complete(53ff783) |
| S27 | A-3 机器层：check-complete COMPLIANCE-CHECK（tier 感知）+10 selftest C 锚核对（P§三A-3） | executor | check-complete.sh、10 个 selftest（锚 token 保留或同步） | 缺项构造计划 warn 点名+mini 分域不误报+10 selftest 全 PASS+键③零扰动 | complete(a243253) |
| S28 | B-1 模板压缩 122→60+dispatch-examples 外置+22.4b 绑定修订+静态断言（P§三B-1） | executor | templates/subagent_dispatch.md、references/dispatch-examples.md（新建）、critical-rules.md、selftest-dispatch.sh | 好/坏样例双向 rc+22.4b↔examples 同 commit 静态断言 PASS+40+ 锚 token 零丢失 | complete(349d94e+f8284d0) |
| S29 | B-2 22.4a 单写者澄清+Handoff 12→10 列折叠（P§三B-2） | executor | critical-rules.md、templates/task_plan.md | check-delegation stats 对等价新旧表格 verdict/数字一致 | complete(1b9437e) |
| S30 | C-5 部署对账两级化（P§三C-5） | executor | smart-merge-back.sh | /tmp 沙箱 ≥8 文件四场景（清单内差异/多文件/残留/全一致）+15/15 回归 | complete(a05bd5e) |
| S31 | SKILL 行数断言同步（如触发）+worktree 全量回归 | 主进程白名单③（code-runner 档不稳接管，22.3④ 登记） | 4 处 ≤558 断言 selftest | 全量 32 脚本逐脚本求和 0 FAIL：主进程实跑 **516 PASS/0 FAIL**（≥457 达成；SKILL 556 ≤558 四处断言全绿无需同步） | complete |
| S32 | 干净上下文验证包：按提案 §三验证设计分组派全新子代理（C-1/A-1+A-2/A-3/B-1+B-2/C-2+C-3+C-4+C-5） | 全新子代理×5 | 提案 §三各项「验证设计」+worktree 路径 | 逐组 rc/输出原文回贴落盘 subagent-state | complete（3/3 组全 PASS：g1-hooks/g2-mech-flow/g3-guards 检查点在案） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| 时间 | seq-subagent_type | 目标 | 状态 | findings 落点 | checkpoint 路径 |
|------|-------------------|------|------|---------------|-----------------|
| 09-26 | S1-plan-writer | 计划撰写 | done+verified | task_plan/knowledge-brief 已 Read 复核 | subagent-state/S1-plan-writer.md |
| 09-26 | S10-code-runner | worktree 基线复跑 | provider 拒绝→主进程白名单③接管 | progress.md（457/0） | subagent-state/S10-baseline.md（主进程直录） |
| 09-26 | S11-executor | C-1b 位点组 1 | done+verified（diff Read 复核+夹具三 case） | progress.md S11 行 | subagent-state/S11-c1b-group1.md |
| 09-26 | S12-executor | C-1b 位点组 2 扩面 | done+verified（diff Read 复核+三 case 对拍） | progress.md S12 行 | subagent-state/S12-c1b-group2.md |
| 09-27 | S13-executor | C-1a① .cwd 修复（双 agent 合并：首轮 captcha 超时遗留修改=第二 executor 逐行核实采信并补齐验证；diff Read 复核+端到端夹具） | done+verified(6e79257) | progress.md S13 行 | subagent-state/S13-c1a1-cwd.md + S13-c1a-cwd.md |
| 09-27 05:38 | S14-executor ×2（竞态：新会话 executor 进场检测并发按硬约束零写入退出；旧窗口 executor 完成交付，其协调者 commit fb67f3a） | C-1a② selftest 三夹具 + check-delegation:131 补位点 | done+verified（主进程独立复现 Total 3 PASS=1 FAIL=2 基线红符合提案 TDD；check-delegation diff 三层结构正确） | progress.md S14 行 | subagent-state/S14-rule23-selftest.md + S14-duplicate-dispatch-alert.md |
| 09-27 05:59 | S15-executor ×3（竞态：旧窗口 executor 05:54/06:03 两轮写入后死亡未 commit；我方两轮收尾 executor 按硬约束停手留警报+裁定；终由我方二次接管 executor 按 4 裁定落码） | C-1a②③ 扫描收窄+awk 合并+正则修复+verification.md 兜底 | done+verified(fb28b70)（主进程 Read diff 复核+selftest 独立复跑 3/3+R1 405-437ms+对拍 cmp PASS+兜底 V1-V4） | progress.md S15 行 | subagent-state/S15-rule23-narrow.md + S15-rule23-narrow-duplicate-alert.md |
| 09-27 06:20 | S16-executor | C-1c lib 化组 1（lib+check-conflicts 两处+pretooluse 锚） | done+verified(73730f7)（主进程 diff 复核+selftest 复跑 3/3+37 计划 byte-identical） | progress.md S16 行 | subagent-state/S16-plan-parse-lib.md |
| 09-27 06:28 | S17-executor | C-1c/d 组 2（sync-todos:197 接入 lib+check-scope:51 python3→realpath） | done+verified(28221a7)（主进程 diff 复核+checkpoint 移正+selftest 复跑） | progress.md S17 行 | subagent-state/S17-sync-checkscope.md |
| 09-27 06:40 | S18-executor | C-1f check-conflicts 9 处 git 合并（先补 selftest） | done+verified(24e6609)（主进程 selftest 复跑 6/6+证伪实验留证复核） | progress.md S18 行 | subagent-state/S18-conflicts-git-merge.md |
| 09-27 07:00 | S19-executor | C-1e UPS 6 进程字段提取→单 awk | done+verified(aff5e06)（主进程 stat 复核+对拍 5/5 复核） | progress.md S19 行 | subagent-state/S19-ups-single-awk.md |
| 09-27 07:15 | S20-executor | C-2 终验两门四元内容键 SKIP-BY-HASH+selftest | done+verified(216e912)（主进程 selftest 复跑 22/0+7 回归复核） | progress.md S20 行 | subagent-state/S20-final-gate-hash.md |
| 09-27 07:35 | S21-executor | C-3 sync-todos --index 单 awk 全量重算+selftest | done+verified(d3a787c)（主进程 selftest 复跑 13/13） | progress.md S21 行 | subagent-state/S21-sync-index-awk.md |
| 09-27 07:55 | S22-executor | A-1 机制层：init-session auto-tier 四条件+critical-rules 38.6+auto_tier 标记 | done+verified(3ad2adb)（主进程 selftest-plan-tier 复跑 28/28） | progress.md S22 行 | subagent-state/S22-auto-tier-mech.md |
| 09-27 08:10 | S23-executor | A-1 消费层：SKILL L64+check-complete AUTO-TIER 复核+selftest-plan-tier 增断言 | done+verified(9026ca9)（主进程 selftest 复跑 32/0） | progress.md S23 行 | subagent-state/S23-auto-tier-consume.md |
| 09-27 08:25 | S24-executor | A-2 38.4③ 口径注释（纯注释） | done+verified(40a1880)（确定性重构证明+三例夹具一致） | progress.md S24 行 | subagent-state/S24-anchor-comment.md |
| 09-27 08:45 | S25-executor | C-4 registry.tsv+36.6 增补子条+一致性自守护（+lib:10 注释顺手修） | done+verified(3cdab78)（主进程守护复跑 5/5+32/32 对齐） | progress.md S25 行 | subagent-state/S25-selftest-registry.md |
| 09-27 09:05 | S26-executor | A-3 流程层：SKILL 三处（102/107/173-204 C 表改写）+Rule 15/24 同步 | done+verified(53ff783)（主进程 stat 复核+锚核对 10 全绿） | progress.md S26 行 | subagent-state/S26-drift-check-merge.md |
| 09-27 09:30 | S27-executor | A-3 机器层：check-complete COMPLIANCE-CHECK（tier 感知） | done+verified(a243253)（主进程 stat 复核+final-gate-hash 22/0） | progress.md S27 行 | subagent-state/S27-compliance-check.md |
| 09-27 10:05 | S28-executor | B-1 模板压缩 122→60+dispatch-examples 外置+22.4b 绑定 | done+verified(349d94e+f8284d0)（主进程 selftest-dispatch 29/29 复跑+零丢失核对复核） | progress.md S28 行 | subagent-state/S28-dispatch-template.md |
| 09-27 09:35 | S29-executor（旧窗口并行交付，双方零行冲突） | B-2 22.4a 单写者澄清+Handoff 12→10 列折叠 | done+verified(1b9437e)（主进程 Read diff 复核：22.4a 单写者段+22.4b 绑定行 语义正确） | progress.md S29 行 | subagent-state/S29-b2-single-writer.md |
| 09-27 09:25 | S30-executor（旧窗口进行中） | C-5 部署对账两级化 | done+verified(a05bd5e)（主进程 stat 复核+四场景沙箱证据+15/15 复跑） | progress.md S30 行 | subagent-state/S30-c5-deploy-diff.md |
| 09-25 | dynamic-workflows编排 | Phase 1 四领域并行取证→29 瓶颈→3 方案→两轮批判→终稿 efficiency-proposal.md（用户 2026-09-25 显式 /workflow 授权，Rule 39.1 路由） | done+verified | workflow-evidence/efficiency-proposal.md（主进程 Read 全文+6 锚互证命中） | 产出=workflow-evidence/01..05+efficiency-proposal.md（run=dwfrun-0f320de1） |
| 09-27 | S31-主进程 | worktree 全量回归（code-runner 档不稳→白名单③机械验证接管，22.3④ 登记） | done（主进程逐脚本 32/32 实跑 516 PASS/0 FAIL ≥457） | progress.md S31 行 | （主进程直录 progress.md） |
| 09-27 11:45 | S33-主进程（簿记接管白名单②③：fix-c5locale 子代理中断只留计划段，主进程 commit cc64c1b；SM-15 用例按 22.3② 拆细派 executor eb7d728） | C-5-locale 尾巴（S32 组5 独立发现 comm 未 pin→zh locale 假 IDENTICAL 缺陷） | done（worktree 双 commit→合并 36e9aaa→worktree/分支已清理；三实体位定向 cp 两文件+diff -r ×3=0；master 全量 32 脚本 518/0） | progress.md c5locale 行 | subagent-state/S32-fix-c5locale.md + S32-verify-group5-c2-c5.md |

### Phase 4: 终验 + 合并部署 + 簿记
- [x] 主仓合并前检查（worktree 干净/主仓无重叠未提交变更）→ `git merge --no-ff` + 关键文件 Read 复验（合并 b5b9bc0；dispatch-examples/final-gate SKIP-BY-HASH/lib plan-parse/auto_tier 锚全在位）
- [x] `smart-merge-back --deploy` 三实体位 + `diff -r` ×3 IDENTICAL（VC-5）（V4 ALREADY_MERGED 快合并跳过属脚本正常分支；主进程独立 diff -r ×3 IDENTICAL+新文件实查不信任脚本自报）
- [x] 全量 selftest 终验（主进程逐脚本 Total 求和，≥457 且 0 FAIL）+ worktree 清理（remove + branch -d）（主仓 32 脚本 516 PASS/0 FAIL 全 rc=0；worktree remove + branch -d 完成，无遗留 wt/*）
- [x] INDEX 刷新（sync-todos.sh --index）+ ledger/verification COMPLETE + Decisions Made 终态核对（verification.md 全 VC 回填+委派 stats verdict ok 0.5 WHITELIST-EXEMPT；INDEX in_progress→complete；c5locale 尾巴 36e9aaa 三实体位定向 cp 两文件+diff -r ×3=0 双轮复验；master 全量终验 518/0）
- **Status:** complete
- **Executor:** 主进程（白名单①git 编排 + 白名单②计划系统文件；例外理由：合并/部署/簿记为编排动作，deploy 脚本须主进程授权链）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（Phase 1-2 仅写 plans/；Phase 3 触碰 skill 前建 worktree；主仓当前仅 .zcode/workflow-drafts/ 与本计划目录 untracked，无重叠） |
| `isolation` | `worktree`（Phase 3-4 实施与合并走隔离区；Phase 1-2 纯计划文件 direct 豁免——纯文档不改运行行为，§十一 11.5②） |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v091（Phase 3 建立时生效） |
| `branch` | wt/task-v091-efficiency-optimization |
| `merge_back` | merged(b5b9bc0 + 36e9aaa)（2026-09-27；主合并 --no-ff b5b9bc0 + c5locale 尾巴 36e9aaa（S32 组5 locale 缺陷修复）；双轮三实体位部署 IDENTICAL + master 518/0 终验；两 worktree/分支均已清理） |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-25 05:25 | init-session 建 S1 映射；workflow run 内子步不重复建 todo |
| Phase 2 | ☐ | | Phase 1 complete 时建 |
| Phase 3 | ☐ | | B 类重规划后按 S-unit 细分建 |
| Phase 4 | ☐ | | Phase 3 complete 时建 |

## ❓ Key Questions
1. 4 领域取证中，哪类开销占简单任务全链路耗时大头——派发协议（22.4 九字段+三文件契约）、hook 守卫链（check-dispatch/check-delegation/pretooluse）、还是仪式区块（attest/FMEA/VC 表）？
2. 复杂任务的慢源是结构性（串行铁律下 S-unit 依赖链长）还是材料性（每步重读大文件）？优化空间在单次派发开销内有多少净收益？
3. Tier B 中涉用户裁决项（串行派发豁免扩大/拆分粒度放宽）按 32.4 重议时，本次用户指令「效率提升但不可降质量」作为新证据的说服边界在哪？
4. 哪些门控可改写为「懒执行/合并执行」（如多 hook 合并单次扫描）而不降判定力？

## 🧭 Decisions Made
| 时间 | 决策 | 理由/依据 |
|------|------|----------|
| 2026-09-25 | D 类新任务判定（Rule 8.1，critical-rules.md:29）：与 task-v089/v090 三要素均无关联，开新计划目录，旧计划原样保留 | 调用方已判定；两要素无主题/范围/交付物交集 |
| 2026-09-25 | Phase 1 用 dynamic-workflows 编排并行取证（Rule 39.1 显式点名路由 + 39.4 并行豁免登记制） | 用户指令显式 /workflow 授权；豁免仅限本 workflow run 内，Phase 2-4 回归 21.4 串行 |
| 2026-09-25 | 提案分层 Tier A（不触既有裁决）/Tier B（涉裁决项按 32.4 引新证据重议） | 硬约束①③要求质量门控不可削弱；分层使可直接采纳项与裁决项解耦 |
| 2026-09-25 | scope_files 细单延后至 Phase 2 末草拟、Phase 3 B 类重规划回填 | 提案未定稿前列不全；届时 attest 重锁（Rule 17.3 不适用——本次为计划内声明的既定重规划点） |
| 2026-09-25 | 39.4 并行豁免登记（Phase 1 workflow run 内）：用户 2026-09-25 显式 /workflow 授权 | Rule 39.4（critical-rules.md:359）要求豁免一行登记 Decisions Made + progress.md |
| 2026-09-26 | B 类扩展（S5）：用户补充硬约束⑦（子代理干净上下文测试）+ 授权⑧（优化→合并→部署全链路） | 用户 2026-09-26 原话；计划已增补约束⑦⑧与 Phase 3 测试项 |
| 2026-09-26 | **D1 裁决落地**：用户回复「采纳」=按主进程推荐执行——Tier A 10 项全采纳（=对 §三 9 项 36.4 删除性清单一次性确认，A-2 纯注释除外）；Tier B 7 项**暂缓**（暂缓非否决：不写 veto，待 Tier A 落地实测后凭新数据按 32.4 重议） | 用户 2026-09-26 原话「采纳」；呈示推荐=Tier A 全采纳+Tier B 搁置 |
| 2026-09-27 | Phase 4 收口：合并 b5b9bc0 + 部署三实体位（主进程 diff -r ×3 IDENTICAL，不信任脚本自报）+ 主仓 32 脚本 516/0 终验 + worktree/分支清理 | 宪法 §十一 11.3 合并合约全部满足 |
| （已由上行取代） | D1 用户裁决 | Phase 2 完成时登记 |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 全量审查报告（效率类发现） | plans/task-planner-skill-review/report.md | ☑ |
| 项目内部 | 慢源结构总览 | knowledge-brief.md §1-§3 | ☑ |
| 项目内部 | 用户裁决史（串行/批量/宁慢勿错） | references/critical-rules.md :86-88, :122, :182 | ☑ |
| 项目内部 | workflow 编排约定 | references/critical-rules.md :343-365（Rule 39） | ☑ |
