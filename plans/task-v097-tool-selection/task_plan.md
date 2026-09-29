# Task Plan: task-v097-tool-selection — Rule 40 harness 工具面主动选择（纯增量规则增强）

<!--
  模板: templates/variant/rule-enhancement-type.md（task-v097 依据 D2 已裁方案实例化）
  撰写者: plan-writer（2026-09-30, /goal 自主会话, interaction_mode: silent）
  方案骨架 D2 已裁勿推翻: 纯增量新增 Rule 40「harness 工具面主动选择」, 六子条, 零新 config 键
-->

<!-- template_type: rule-enhancement -->

## Goal
落地 critical-rules.md Rule 40「harness 工具面主动选择」（40.1-40.6 六子条：工具面清单/计划期主动分析区块//goal 对齐/workflow 编排计划期路径/机器校验边界如实披露/selftest 守护，零新 config 键），同步 SKILL.md 四锚 + 三类模板 + 卫星两文档 + plan-writer 契约 + 新建 selftest-tool-selection.sh，全量 selftest 0 FAIL 后 smart-merge-back --deploy 合并回 master 且三部署位 IDENTICAL、worktree 清理。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | （启动时生成,注册表追踪） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection` |
| `scope_files` | 见「⚠️ 执行范围限制」表逐行,共 10 文件（8 改 + 2 新建） |
| `interaction_mode` | `silent`（/goal 自主会话,Rule 28;静默决策以 Decisions Made 表 `silent:` 前缀行登记） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 40 六子条全文在位且 grep 可验：`grep '^40\.[1-6]' references/critical-rules.md` 六条全命中；40.1 六类工具面（/workflow 即 CreateWorkflow 族、/goal 会话目标、Agent 子代理、卫星技能、MCP web_reader/node_repl、机械守卫脚本）、40.4 指向 Rule 39.4 并行豁免登记、40.5 含机器校验边界如实披露措辞、40.6 声明零新 config 键+selftest-tool-selection.sh 守护 | `grep -c '^40\.' <CRIT>` ≥6 + 逐子条关键词锚 grep | worktree 内 `skills/task-planner/references/critical-rules.md` |
| VC-2 | SKILL.md 四锚同步：① 协同路由段 Rule 40 行（L47 后）② 合规清单 C28 行（C27 后）③ Critical Rules 摘要行 Rule 40（L268 后）④ References 表 Rules 1-39→1-40 与摘要行计数措辞更新；SKILL.md 净增行数 ≤ 上限断言,4 处既有 selftest 行数断言（knowledge-brief T2b / skill-collab T10 / skill-split T-主 / execution-stability T8b / batch-pilot BP-08,以 grep 实测为准）全部过 | `bash scripts/selftest-knowledge-brief.sh` 等 4 脚本 Total 行 0 FAIL + `grep -n 'Rule 40' SKILL.md` ≥3 锚 | worktree 内 selftest 输出 + progress.md Selftest Log |
| VC-3 | 模板层三落点在位：general `templates/task_plan.md` 含「🧰 工具选择与编排」区块（定位=Executor 上游分析记录,注明不替代 Executor 委派门控机器事实源）；`templates/variant/mini-lite-type.md` 明确豁免不加区块（Rule 38.3 轻量契约）；`templates/subagent_dispatch.md` 补工具面提示行 | `grep -c '🧰 工具选择' templates/task_plan.md` ≥1；`grep '豁免' variant/mini-lite-type.md` 命中；`grep '工具面' subagent_dispatch.md` 命中 | worktree 内 templates/ 三文件 grep 输出 |
| VC-4 | 卫星与 agent 契约在位：plan-template-kit `template-mapping.md` 新增「工具选择映射」节、`template-guide.md` 新增该区块定制指南；companion `agents/plan-writer.md` 增工具选择区块撰写义务行；既有消费方 selftest（methodology M-16 / conclusion-discipline CD-20 / knowledge-brief / template-lifecycle TL-03）零回归 | 卫星两文件 grep 新节命中 + plan-writer.md grep「工具选择」命中 + 4 脚本 Total 0 FAIL | worktree 内 selftest 输出 + grep 记录 |
| VC-5 | 新 selftest 过且全量回归 0 FAIL：`selftest-tool-selection.sh` 全 PASS 并登记 registry（tsv+sh 双落点）；全量 `for f in selftest-*.sh` 逐脚本 Total 行求和 = 0 FAIL 且 PASS 总数 ≥ P1 实测基线（**总数=主进程逐脚本 Total 行机械求和,禁采信子代理自报**;基线以 P1 实测为准,记忆参考 36 脚本 592/0 仅预期） | `for f in scripts/selftest-*.sh; do bash $f; done` 逐 Total 行求和 | progress.md Selftest Log（P1 基线段 + P5 复跑段） |
| VC-6 | 合并部署收尾闭环：smart-merge-back --deploy 三位（~/.zcode、~/.claude、~/.config/opencode 下 skills/task-planner）+ companion/agents 同步部署;三位部署 diff 复验输出 IDENTICAL（对账基准=主仓 skills/task-planner）;`git worktree list` 无本任务残留、`git branch` 无 wt/task-v097-tool-selection;plan `merge_back=merged(<commit>)` | `bash scripts/smart-merge-back.sh <wt> --deploy` 输出 MERGED+全位 IDENTICAL + `git worktree list` + `git branch --list 'wt/task-v097*'` 为空 | progress.md Phase 6 段 + 合并 commit SHA |
| VC-7 | 边界与无回归：Rule 39.1 显式点名 /workflow 才路由的原文零改动（`grep '39.1' CRIT` 原文 diff 保全）；39.7.2 禁自建 dynamic-workflows 副本条款未触碰；40.3 如实披露 /goal 为用户侧 harness 命令、技能不可代调；既有 36 脚本零行为回归（并入 VC-5 全量求和） | `git diff master..wt -- CRIT` 中 39.1/39.7 行未出现于变更集 + 40.3 条款含披露措辞 grep | worktree `git diff` 输出 + findings.md P2 段 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required` → 终验前必须先过 Code Review Gate（Skill("code-review") 上下文隔离审查,Phase 7 承载），否则不得标记 COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

<!--
  🚫 禁止发散规则: 只操作本列表中明确列出的文件;未在列表中的文件一律不碰;扩展须用户授权。
  全部实现类改动在 worktree 内进行（保护区文件,宪法 §11.1）。
  路径均相对仓根 /mnt/data/dev/task-planner-skill/（worktree 内对应路径同构）。
-->
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/task-planner/references/critical-rules.md`（末尾追加 Rule 40,纯增量,禁动 Rule 1-39 任何语义,禁重编号） | 改既有规则;动 39.1/39.7 原文 |
| SKILL 主文档 | `skills/task-planner/SKILL.md`（4 锚行内增改：协同路由行/C28/Rule 40 摘要行/References 计数,净增行数受行数断言约束,行位替换优先） | 大段新增;动既有锚子串（「Rule 39（动态工作流编排」「| C27 |」「Rules 1-39」改写时旧断言口径须同步） |
| 模板 | `skills/task-planner/templates/task_plan.md`（general 加「🧰 工具选择与编排」区块）;`skills/task-planner/templates/variant/mini-lite-type.md`（豁免声明行）;`skills/task-planner/templates/subagent_dispatch.md`（工具面提示行） | 其他 variant 模板（13+3 个零改）;模板脚本契约标记（template-guide §四格式） |
| 卫星 | `skills/plan-template-kit/references/template-mapping.md`（加「工具选择映射」节）;`skills/plan-template-kit/references/template-guide.md`（加区块定制指南） | 两卫星 SKILL.md 本体（v095 拆分后结构零改动）;plan-cost-guard / plan-collab-router 等其他卫星 |
| agent 契约 | `skills/task-planner/companion/agents/plan-writer.md`（加工具选择区块撰写义务） | plan-writer.md 其余段落语义;article-batch-publisher.md / article-field-fixer.md |
| selftest | 新建 `skills/task-planner/scripts/selftest-tool-selection.sh`;`skills/task-planner/scripts/selftest-registry.tsv` + `selftest-registry.sh`（登记新行）;既有 4-5 处 selftest 行数断言行内上调（grep 定位,只动上限数字与 label 注释） | 其他既有 selftest 脚本行为断言;check-*.sh 消费侧脚本（本任务零新 config 键零新门控键,消费面=LLM 行为层） |
| 文档簿记 | `plans/task-v097-tool-selection/**`（三件套回填）+ `plans/INDEX.md` + ledger | 其他计划目录;部署位文件（部署走 smart-merge-back --deploy,禁手改部署位） |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（silent 模式登记 Decisions Made 后继续）

**强制约束**（D2 已裁 + v088/v095/v096 教训,全部 P0）:
1. 纯增量：Rule 40 接续当前最大编号（现最大 39）,C28 接续 C27;禁重排/重编号/改 1-39 语义（Rule 36.5）
2. 零新 config 键（WF-12 断言 properties=40 维持;40 判定面=LLM 行为,机器面只加 selftest 静态守护,与 v087/v088 同范式）
3. Rule 39.1 显式点名路径原文保留不动;40.4 计划期路径只做「建议登记 CreateWorkflow + 按 39.4 并行豁免登记」,不新增自动路由
4. ⚠️ 锚定级联三层（v088 教训）：改 SKILL.md 前先 `grep -rn "Rules 1-" skills/task-planner/scripts/` 扫全部锚断言一次修齐（宽容正则优先）;SKILL 净增行数必同步既有行数断言（knowledge-brief T2b / skill-collab T10 / skill-split T-主 / execution-stability T8b / batch-pilot BP-08,以 P1 grep 实测清单为准,共约 4-5 处,上限与 label 注明 task-v097）
5. 每个 S-unit 动手前先 grep 消费方 selftest 断言（内容型锚必漏,清单只作导航——v095/v096 Error Log Prevention）
6. selftest 总数=主进程逐脚本 Total 行求和,禁采信子代理自报;单用例调试 ≤2 轮,超则记 blockers 交主进程
7. 全部改动 worktree 隔离,逐 Phase git 提交（Rule 27,禁攒批/禁 `git add -A`）;message: `<type>(<scope>): task-v097/Phase N — <摘要>`
8. 派发 prompt 的 subagent_type 只写纯 token（executor/code-reviewer/code-assistant）,禁括号模型后缀（v095 教训）;派发契约 8 字段标签逐字校验（check-dispatch.sh）
9. mini-lite 模板豁免是 Rule 38.3 区块白名单的自然延伸（超白名单=模板违约）,措辞为声明行不新增仪式区块
10. /goal 披露纪律（Rule 35.2 防虚构）：40.3 必须如实写明 /goal 是用户侧 harness 会话命令,技能层只做「计划 Goal+VC 与 session goal 映射指引」,禁止声称技能可代调 /goal 或读取其运行态

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 39 全文（六子条范式直接对标） | `skills/task-planner/references/critical-rules.md:339-390`（### 39 节） | 必读 | ☑ |
| 项目内部文档/知识库 | Rule 39 SKILL 四锚现状（协同路由行/C27/摘要行/References） | `skills/task-planner/SKILL.md:47,191,268,292` | 必读 | ☑ |
| 项目内部文档/知识库 | 行数断言基线（≤558 五处 + skill-split ≤430 目标） | `scripts/selftest-knowledge-brief.sh:38`、`selftest-skill-collab.sh:82`、`selftest-skill-split.sh:41`、`selftest-execution-stability.sh:72`、`selftest-batch-pilot.sh:55` | 必读 | ☑ |
| 项目内部文档/知识库 | rule-enhancement 模板范式 | `skills/task-planner/templates/variant/rule-enhancement-type.md`（全文 80 行） | 必读 | ☑ |
| 项目内部文档/知识库 | selftest + registry 范式 | `scripts/selftest-workflow-orchestration.sh`（WF-01..16 静态断言范式）+ `selftest-registry.tsv`（37 行,含表头） | 必读 | ☑ |
| 项目内部文档/知识库 | 卫星两文档插入点 | `skills/plan-template-kit/references/template-mapping.md:205-230`（§九后）+ `template-guide.md:143-279`（§五场景后） | 参考 | ☑ |
| 项目内部文档/知识库 | plan-writer 契约现状 | `skills/task-planner/companion/agents/plan-writer.md:38-66`（掌握的技能段） | 参考 | ☑ |
| 项目内部文档/知识库 | v096 同族任务全流程先例 | `plans/task-v096-template-auto-record/task_plan.md`（8 Phase 结构/兜底/教训） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: task-planner 计划期对 harness 已有工具面（/workflow 编排、/goal 目标、Agent 子代理、卫星技能、MCP、机械脚本）无主动分析机制,计划常默认串行 Agent 派发一条路——把「工具面清单 + 计划期主动分析区块 + /goal 对齐 + workflow 编排计划期建议路径」以纯增量 Rule 40 落地后,plan-writer/主进程能在计划期显式选择最合适的执行工具,问题即解决、结果可交付。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（六子条条款+模板区块+卫星映射+selftest 守护,可交付）
- [x] 核心问题不解决，其他工作都白费吗？（是——本任务唯一目标就是该机制）
- [x] 核心问题的解决方法是清晰的、可执行的？（D2 已裁六子条骨架,范式对标 Rule 39,零新 config 键）

## Current Phase
（终态）Phase 7 complete — outcome: COMPLETE

## Next Step
交付报告呈示用户（含静默决策清单）;远端 push 留用户授权。

## Phases（7 Phase;P2-P5 串行派发,P1/P6/P7 主进程 git 编排与簿记收敛）

<!-- 🧰 工具选择与编排（Rule 40 计划期主动分析 — 本计划自身即 40.2 区块的首个消费示范）
     定位声明: 本区块是 Executor 字段的上游分析记录;Executor 字段仍是委派门控机器事实源（check-delegation/check-plan-dispatch 消费）,本区块不替代。
     工具面清单（40.1）与逐 Phase 选择:
     | Phase | 命中工具面 | 选择理由 |
     |-------|-----------|---------|
     | P1 | 机械守卫脚本（check-conflicts/全量 selftest）+ git 编排 | worktree 创建属主仓 git 操作;基线求和纪律禁子代理自报（硬约束 6）→ 主进程白名单①③ |
     | P2 | executor(sonnet-1) 子代理 | 条款+SKILL 四锚=判断型多文件编辑,>3 文件走 executor |
     | P3 | executor(sonnet-1) 子代理 | 模板三文件=技能文件编辑,规模 ≤3 文件/Phase |
     | P4 | executor(sonnet-1) 子代理 | 卫星两文档+agent 契约=文档型编辑 |
     | P5 | executor(sonnet-1) 写脚本 + 主进程复跑全量求和 | selftest 编写判断型;终验求和属③机械验证纪律 |
     | P6 | 主进程 smart-merge-back --deploy | git 编排+部署位终裁,白名单①③ |
     | P7 | code-reviewer(sonnet-1) 子代理 + 主进程簿记 | CR 隔离审查;终验结论定级主进程终裁（⑤） |
     workflow 编排判定（40.4 计划期路径）: 本任务 Phase 间强串行依赖（条款→模板→卫星→selftest→合并）,无独立并行子任务/fan-out/长链复用 → 不建议 CreateWorkflow,维持 21.4 串行派发,登记于此（silent 决策）。
     /goal 对齐（40.3）: 本计划 Goal+VC-1..7 即 /goal 自主会话目标的计划期映射;40.3 如实披露 /goal 为用户侧 harness 命令,技能不可代调。 -->

### Phase 1: 基线测绘与 worktree 创建
- [x] worktree 建立: `git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection -b wt/task-v097-tool-selection master`（基线 master@26f938c,status 干净）
- [x] 全量 selftest 基线实测: worktree 内逐脚本 Total 行求和 = **36 脚本 592 PASS / 0 FAIL**（progress.md Phase 1 Test Results）
- [x] 行数断言与级联锚实测清单: 5 处 ≤558 + ≤430 目标线 + 4 处宽容正则锚 + WF-10 ≥6——对策 b 确证（progress.md 登记）
- [x] 知识储备必读项全部确认可获取（P1 复核: brief 行号基本无漂移;36 vs 37 计数偏差已记录）
- **V-N:** VC-5, VC-7（基线=VC-5 求和起点 ✓;级联清单=VC-7 锚保全输入 ✓）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排——worktree 创建属主仓 git 操作;③ 机械验证命令——全量基线求和纪律禁子代理自报总数,Rule 25.3 白名单）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 建 worktree+分支并确认干净 | 主进程（白名单①） | knowledge-brief §2 F1（worktree 路径与命名 SOP） | `git worktree list` 含新路径;`git -C <wt> status` 干净;分支=wt/task-v097-tool-selection 基于 master | 10min | pending |
| S2 | 全量 selftest 基线+级联锚清单 | 主进程（白名单③机械验证） | knowledge-brief §2 F2/F3（37 脚本现状与行数断言五处清单） | progress.md 落 Total 逐行求和数字与 0 FAIL;级联锚清单（Rules 1-39 命中处+行数断言处）登记 progress.md | 15min | pending |

### Phase 2: 条款层 Rule 40 与 SKILL 同步
- [x] critical-rules.md 末尾（L391 后）纯追加 Rule 40 六子条全文（391→402,deletions=0;证据 progress.md Phase 2）
- [x] SKILL.md 四锚行内同步: L48 协同路由行/L193 C28/L271 摘要行/L241+L295 括注「Rules 1-39（含 Rule 40）」
- [x] 行数纪律: 430→433 实测,selftest-skill-split 上限同步 433（label task-v097）;4 处 ≤558 复跑 0 FAIL
- [x] 改前快照 diff 对账: WF-07/08/09 锚子串各=1,39.1/39.7 区块零触碰（P2-S1 deletions=0）
- **V-N:** VC-1, VC-2, VC-7（六子条在位/四锚同步+行数断言过/39 系原文保全）——全部 ✅（progress.md Phase 2 Test Results）
- **Status:** complete
- **Executor:** executor
<!-- 派发契约: 逐 S-unit 九字段 prompt（templates/subagent_dispatch.md）,严格串行,一次一个验收通过再派下一个（Rule 21.4） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 写入 Rule 40 六子条全文（纯追加 L391 后） | executor | knowledge-brief §1（六子条合约定义）/§3 A1（CRIT 尾部锚）/§4 条 1-3+10 + 用户原话（本计划 Goal 段引述） | `grep -c '^40\.'` =6;`git diff` 证明 L339-391 零变化;40.3 含 /goal 披露措辞;40.6 含零新 config 键+selftest 名 | 15min | pending |
| S2 | SKILL.md 四锚同步+行数断言级联上调 | executor | knowledge-brief §3 A2（SKILL 四锚行号）/§2 F2-F4（行数断言五处与 WF-07..11 口径）/§4 条 4-6 + P1-S2 级联清单 | 4 锚 grep 命中;既有锚子串保全（快照差集对账）;净增行数在断言内;knowledge-brief/skill-collab/skill-split/execution-stability/batch-pilot 五脚本 Total 0 FAIL | 15min | pending |
| S3 | Phase 2 提交+条款自验 | 继承 | worktree `git status`/`git diff --stat` + VC-1/VC-2 判定标准 | `git status --porcelain -- <scope>` 空;Rule 40 摘要行/协同路由行 grep 命中;`git log` 含 Phase 2 commit | 10min | pending |

### Phase 3: 模板层（general 区块 + mini-lite 豁免 + dispatch 提示行）
- [x] general `templates/task_plan.md` 加「🧰 工具选择与编排」区块（L133,+14 行;定位声明/工具面表/40.4/40.3 判定行齐;init-session 冒烟 6/6）
- [x] `templates/variant/mini-lite-type.md` 加豁免声明行（45≤80,selftest-plan-tier 32/0）
- [x] `templates/subagent_dispatch.md` §2 补工具面提示行（8 字段标签零破坏,selftest-dispatch 29/0）
- [x] 下游解析兼容实测: init-session 冒烟通过+伪行禁令 0/0+模板契约标记零触碰（commit 676319a）
- **V-N:** VC-3, VC-7（新区块+豁免在位/下游解析无回归）——全部 ✅（progress.md Phase 3 Test Results）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | general 模板加「🧰」区块+定位声明 | executor | knowledge-brief §1（区块六要素）/§3 A3（task_plan.md L133-139 Phases 段插入点）/§4 条 9 + 本计划「🧰」区块实例（演示格式） | `grep '🧰 工具选择'` 命中;区块含「不替代 Executor」定位声明;mini-lite 38.3 白名单负例核对（本模板不受影响） | 15min | pending |
| S2 | mini-lite 豁免行+dispatch 工具面提示行 | executor | knowledge-brief §3 A4（mini-lite 44 行全文+白名单锚）/§3 A5（dispatch §2 输入段插入点）/§4 条 7 | mini-lite `grep '豁免'` 命中且仍 ≤80 行（selftest-plan-tier T11 口径）;dispatch `grep '工具面'` 命中;九字段结构零破坏 | 10min | pending |

### Phase 4: 卫星层与 agent 契约
- [x] plan-template-kit `references/template-mapping.md` 加「工具选择映射」节（§十,L232,+15 纯增;§九 表零删改）
- [x] plan-template-kit `references/template-guide.md` 加「🧰 工具选择与编排」区块定制指南（场景 5,+11 行,红线 5 条）
- [x] companion `agents/plan-writer.md` 「掌握的技能」段加工具选择区块撰写义务行（+1 行,锚零破坏）
- [x] 既有消费方 selftest 回归: methodology 16/0+conclusion-discipline 24/0（knowledge-brief/template-lifecycle 并入 P5 全量）
- **V-N:** VC-4, VC-7（卫星两文档与 plan-writer 契约在位/既有消费 selftest 零回归）——全部 ✅（progress.md Phase 4）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | template-mapping 加「工具选择映射」节 | executor | knowledge-brief §3 A6（mapping §九表 L205-230 结构）/§1 映射表六行 | 新节 grep 命中;§九矩阵表零改动（快照 diff）;mapping 总行数 ≤300 纪律复核 | 10min | pending |
| S2 | template-guide 加区块定制指南+plan-writer 义务行 | executor | knowledge-brief §3 A7（guide §五后插入点）/§3 A8（plan-writer L38-66 技能段） | guide 新节 grep 命中且路径引用为绝对路径规范（§七）;plan-writer `grep '工具选择'` 命中;methodology M-16/conclusion-discipline CD-20 锚保全（两脚本 Total 0 FAIL） | 15min | pending |

### Phase 5: selftest 与全量回归
- [x] 新建 `scripts/selftest-tool-selection.sh`（TS-01..12 静态只读断言,WF 范式同构,首跑 12/0,bash -n rc=0;纯静态无临时文件,零仓库写入达成）
- [x] registry 双落点登记: tsv 38 行;registry.sh 动态 comm 口径无需改动,rows=actual=37 一致
- [x] worktree 内全量 selftest 复跑: 主进程（白名单③）逐 Total 行求和 **604 PASS / 0 FAIL**（基线 592+新增 12 咬合）
- [x] 新 selftest 调试纪律: 首跑即过,零调试轮次
- **V-N:** VC-5, VC-1（新 selftest 过+全量 0 FAIL/条款锚断言咬合验证）——全部 ✅（progress.md Phase 5）
- **Status:** complete
- **Executor:** executor
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 编写 selftest-tool-selection.sh | executor | knowledge-brief §3 A9（selftest-workflow-orchestration.sh WF 范式 L23-80）/§2 F5（registry 37 行格式） | 新脚本全 PASS;`bash -n` 0;mktemp 沙箱零仓库写入;断言覆盖 40.1-40.6+四锚+模板+卫星+契约+零 config 键 | 15min | pending |
| S2 | registry 登记+单脚本复跑 | executor | knowledge-brief §2 F5 + scripts/selftest-registry.sh:26-49（T02 无缺失/T03 无孤儿口径） | tsv+sh 双 grep 命中新脚本名;registry 脚本 Total 0 FAIL 且 rows=actual;单脚本复跑 Total 全 PASS | 10min | pending |
| S3 | worktree 全量 selftest 复跑 | 继承 | P1-S2 基线数字 + knowledge-brief §4 条 6 | 逐脚本 Total 行清单落 progress.md;0 FAIL;PASS 总数 ≥ 基线（主进程复核定数在 P6） | 15min | pending |

### Phase 6: 合并回与三位部署
- [x] 合并前置检: worktree 干净/逐 Phase 提交完整（4 commit）/主仓无 scope 重叠（V3）
- [x] smart-merge-back --deploy: V1-V6 全 OK → merge commit **52b434f** → 三部署位 IDENTICAL
- [x] companion/agents 部署位同步: install-companion 两 target 完成;zcode 位 IDENTICAL,claude 位 model 行=平台适配（机制内建）,opencode 位现状保持（silent 决策）
- [x] 清理: worktree remove+branch -d → 残留 0/0;主仓合并内容 grep 复验 6/5/1/1
- **V-N:** VC-6, VC-5（合并部署 IDENTICAL+清理 ✓/部署位上全量求和复验→P7 终验收口）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排与主仓合并;③ 机械验证——部署位终裁与基线对账禁委派（v096 先例）,Rule 25.3 白名单）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 合并前置检清单核验 | 主进程（白名单①③） | VC-1..VC-5 证据 + worktree `git status`/`git log` + knowledge-brief §4 条 5 | status 干净;逐 Phase 提交 ≥P2..P5 各 1;VC 复验表全勾 | 10min | pending |
| S2 | smart-merge-back --deploy+清理 | 主进程（白名单①） | scripts/smart-merge-back.sh:347-395（--deploy 三位 SLOTS 与对账基准=主仓） + knowledge-brief §2 F1 | 输出 MERGED+全位 IDENTICAL;`git worktree list` 无本任务残留;`git branch --list 'wt/task-v097*'` 空;merge commit SHA 落 progress.md | 15min | pending |
| S3 | companion 部署+主仓复验 | 主进程（白名单①③） | skills/task-planner/lib/install-companion.sh:5（companion/agents/*.md → 三位 agents/） + P6-S2 输出 | 三位 agents/plan-writer.md 与主仓 diff 一致;主仓 Read critical-rules.md/SKILL.md 关键锚复验命中 | 10min | pending |

### Phase 7: CR Gate 与终验簿记
- [x] Code Review Gate: code-reviewer 审查 26f938c..52b434f 全量 diff → **APPROVED**（7 专项全 PASS,零 P0/P1;checkpoint 11-code-reviewer.md）
- [x] CR P2 处置: P2-a 注释修复+commit+三位 diff -r IDENTICAL;P2-b 备份移出扫描路径（用户既有政策）;P2-c 维持现状登记
- [x] 主进程 VC-1..7 逐条勾验（verification.md 全 VC 记录+委派率 JSON 原文: 0.571 WHITELIST-EXEMPT verdict=ok）
- [x] 簿记收尾: INDEX/ledger/notepad 沉淀/静默决策清单（Decisions Made silent: 行 ×13）齐备
- **V-N:** VC-6, VC-7, VC-4——全部 ✅（verification.md Goal Gate 全 PASS → outcome: COMPLETE）
- **Status:** complete
- **Executor:** code-reviewer + 主进程（主进程例外理由:⑤ 终验裁决与终验结论定级属主进程终裁;② 计划系统文件/簿记落盘（三件套+INDEX+ledger）,Rule 25.3 白名单）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | CR 审查 wt 全量 diff | code-reviewer | `git diff master..wt/task-v097-tool-selection` + knowledge-brief §4 条 2/3/8 | APPROVED/BLOCKED 结论+问题清单落检查点;锚保全与 40.3 披露措辞专项核对 | 15min | pending |
| S2 | 终验簿记+呈示 | 主进程（白名单⑤②） | verification.md + 七 VC 证据 + check-delegation stats JSON | 七 VC 全勾;委派率 JSON 原文落 verification.md;INDEX/ledger 条目落盘;结论呈示用户 | 10min | pending |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号⑤命中=运行中基础设施改动→必须隔离;①未提交变更仅 plans/.active_plan 与本任务计划目录,与 scope 无重叠;②③④无信号） |
| `isolation` | `worktree`（保护区文件 skills/** 修改,宪法 §11.1 第 1 条强制命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection` |
| `branch` | `wt/task-v097-tool-selection` |
| `merge_back` | `merged(52b434f)`（V1-V6 预检过,merge --no-ff 回 master;三部署位 IDENTICAL;companion 两部署位同步;worktree+分支已清理） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | SKILL 行数断言级联遗漏（五处 ≤558 断言任一 FAIL,v088 教训复刻） | 8 | 5 | 3 | 120 | P1-S2 级联清单先行+P2-S2 输入列强制携带;FAIL 时 22.3① 改派回 P2-S2 补修单处上限（label 注明 task-v097）,不扩散 |
| Phase 2 | 39.1/39.7/C27 既有锚子串断裂（selftest-workflow WF-04..09 FAIL） | 7 | 5 | 2 | 70 | 改前快照差集对账（硬约束 5）+P7 CR 专项核对;断裂即 git restore 单行重写（⑥ trivial 级） |
| Phase 3 | general 模板新区块破坏下游解析（check-scope/check-3file-gate/check-template-type 读 task_plan.md） | 8 | 4 | 3 | 96 | 区块以 HTML 注释+表格纯增,插 Phases 段前;P3-S1 验收含下游兼容实测;FAIL 时 22.3② 拆细区块为纯注释形态 |
| Phase 5 | 新 selftest 断言与实际产出漂移（条款措辞微调致 grep 锚失配） | 6 | 5 | 3 | 90 | 断言宽容正则（对齐 CD-18/19 范式）;单用例调试 ≤2 轮超限记 blockers（硬约束 6）;22.3④ 主进程接管定锚 |
| Phase 6 | 部署位 DRIFT/REJECTED（三位 slot 被并行会话污染,宪法 §十一 并行开发期） | 8 | 3 | 4 | 96 | smart-merge-back fail-closed exit 6 已机制化;DRIFT 时 STOP 按 28 D6 报告等决策,禁手工覆盖部署位 |
| Phase 6 | 委派率 <0.7 或白名单外理由被计 violation | 5 | 3 | 2 | 30 | 主进程直做仅 P1/P6/P7 局部且理由全落 25.3 六项白名单;终验前自查 check-delegation stats verdict |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填;RPN≤100 可留空。本表是规划期预演,执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | | S1 计划批准后建立映射 |
| Phase 2 | ☐ | | |
| Phase 3 | ☐ | | |
| Phase 4 | ☐ | | |
| Phase 5 | ☐ | | |
| Phase 6 | ☐ | | |
| Phase 7 | ☐ | | |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions

1. Rule 40 六子条的 SKILL.md 联动净增行数最终是多少,是否触碰 430 目标线（skill-split T-主）与 558 上限？（P2-S2 实测回答）
2. 既有 selftest 中除已知五处行数断言外,是否还有隐藏的「Rules 1-39」计数措辞断言需级联？（P1-S2 grep 清单回答）
3. 「🧰 工具选择与编排」区块在 general 模板的插入位置（Phases 段前 vs Code Review 配置后）哪种对下游脚本解析零干扰？（P3-S1 实测回答）
4. companion/agents 部署位（~/.zcode、~/.claude、~/.config/opencode 的 agents/）是否全部存在 plan-writer.md,opencode 位缺失时的部署语义？（P6-S3 实测回答）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| silent: 纯增量新增 Rule 40（D2 已裁）,零新 config 键 | 与 v087/v088 同范式;判定面=LLM 行为无需门控键;WF-12 properties=40 断言维持 |
| silent: Executor 字段仍是委派门控机器事实源,「🧰」区块只是其上游分析记录 | check-delegation/check-plan-dispatch 机器消费面不改;区块提供分析可见性,两层职责分离（用户约束 40.2 原文） |
| silent: 40.4 计划期路径=建议登记制,Rule 39.1 显式点名原文不动 | 39.1 官方红线「explicit request is binding」;计划期只做登记建议不新增自动路由（Rule 36.5 纯增量） |
| silent: worktree 基线 master 而非 main | 本仓默认分支实测为 master（git branch 输出）;smart-merge-back 默认 --base master |
| silent: mini-lite 豁免=声明行而非加区块 | Rule 38.3 区块白名单超限=模板违约;mini 档 ≤15min 任务免计划期工具分析仪式 |
| silent: workflow 编排对本任务不适用（🧰 区块判定） | Phase 间强串行依赖（条款→模板→卫星→selftest→合并）,无独立并行子任务/fan-out/长链复用 |
| silent: VC 设 7 条（>最低 5） | 用户硬性要求 6 项覆盖面 + 边界条款（VC-7）独立成条便于 CR 专项核对 |
| silent: interaction_mode: silent | /goal 自主会话用户明示;静默决策以本表 silent: 行登记供交付复核（Rule 28） |
| silent: P2-S3 提交由主进程执行（白名单① git 编排,同 P1/P6 先例） | S-unit 表执行体标「继承」但纯 git commit 属 Rule 25.3 白名单①;省一次派发开销,commit 后 porcelain 终检已做（scope 三文件零残留） |
| silent: 派发 prompt 走任务书落盘引用（Rule 35.3） | 首派 P2-S1 因 prompt>3000 被守卫拦截两次（缺三文件 token+超长）,改「任务书写文件+prompt 只放路径与 Read 指令」后通过——后续 S-unit 一律沿用此形态 |
| silent: P4-S1/S2 验收①口径缺陷裁定（grep ≥2→≥1,产物采信） | executor 正确拒绝擅改逐字内容凑数;缺陷在任务书撰写未对产物自测锚计数（Error Log 已登记 Prevention） |
| silent: P5-S3 全量复跑由主进程直做（白名单③机械验证） | 求和纪律禁子代理自报（计划硬约束 6+硬约束表第 6 条）;与 P1 基线同范式,executor 复跑数字仅参考无增量价值 |
| silent: worktree 清理在 P6 内即执行（不等 CR） | CR fix-phase 若有走 v096 先例 master 直修+重部署差异位;清理先行使 VC-6 证据完整闭合 |
| silent: opencode 位不部署 companion agents/plan-writer（现状保持） | KQ4 实测 ABSENT=该平台无对应 agent 生态（agents 目录异构）;其消费面=skills/task-planner 已由 smart-merge-back IDENTICAL 覆盖;强行安装=越权扩散 |
| silent: CR P2-b 备份残留按用户既有政策移出扫描路径（~/skill-deploy-backups-task-v097/） | memory P0 纠正「备份禁留技能目录扫描路径」为持久授权;移出而非删除规避 rm -rf 授权门槛;.gitignore 增补留用户裁决 |
| silent: CR P2-c（SKILL frontmatter 索引括注）维持现状 | CR 自评 PT-08 锚约束下有意保守,信息性缺口非违约;擅改 frontmatter 有锚断裂风险 |
| silent: 34.3 模板沉淀评估=沿用 rule-enhancement-type 不另沉淀 | 本任务即规则增强本体,无新任务类型泛化点;34.3 三条件均未命中新类型 |
| silent: Rule 40.2 义务行已写入 plan-writer 契约并部署两 agents 位（新会话生效） | install-companion 提示 frontmatter/正文为快照语义;本会话不再复用 plan-writer |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| P4-S1/S2 两次 partial: 任务书验收①（grep ≥2）与逐字插入文本实际出现次数（1）矛盾 | 1 | 裁定验收①修订为 ≥1（产物正确,executor 正确拒绝擅改逐字内容凑数） | 写验收标准前必须先对「逐字插入文本」自测 grep 计数;验收阈值从产物事实导出,不凭感觉定 → notepad 沉淀 |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本计划自身「🧰」区块=Rule 40.2 首个消费示范;执行期 plan-writer 契约改动不影响本计划（契约改动在 P4 落地,本计划已在 P0 按草案义务撰写）
- 部署位手改禁令:全部部署走 smart-merge-back --deploy 与 install-companion.sh,禁直接 Edit 部署位文件

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-30 P1 翻转后 | ALIGNED | VC-5/7 | 写入面=plans 簿记+worktree 创建,零计划外 |
| 2026-09-30 P2 翻转后 | ALIGNED | VC-1/2/7 | 写入面=恰 3 scope 文件,commit a83a8c6,证据齐 |
| 2026-09-30 P3 翻转后 | ALIGNED | VC-3/7 | 三模板落点,commit 676319a |
| 2026-09-30 P4 翻转后 | ALIGNED | VC-4/7 | 三卫星/契约落点,commit 21ae9f1;两次 partial 为验收口径缺陷非漂移 |
| 2026-09-30 P5 翻转后 | ALIGNED | VC-5/1 | selftest+registry,commit ccfc70f,604/0 |
| 2026-09-30 P6 翻转后 | ALIGNED | VC-6 | 52b434f+三位 IDENTICAL+清理 0/0 |
| 2026-09-30 终验 | ALIGNED | VC-1..7 | CR APPROVED+全 VC PASS → outcome COMPLETE |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

<!-- 本任务非批量任务（无 chain_mode: fan-out,无 ≥5 同构单元批量操作）,本区块预登记口径:不适用。执行期若出现批量操作（如多部署位逐位处理）≥5 单元再按模板回填,否则终验时以「不适用」结案。 -->

| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——本任务非批量,无 ≥5 同构单元批量操作） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0%（0/0,无批量面;>5% → STOP 条款不适用） |
| `sampled_pass` | 0（零单元,抽检不适用） |
| `sampled_fail` | 0（零单元,熔断条款不适用） |
| `pre_check` | Q1:否（无每单元独立判断依赖）/Q2:有（VC 逐条客观验收）/Q3:能（worktree+git 可回滚） |
| `rollback_point` | master@26f938c（P1 基线,已合并 52b434f 后回滚点=其父提交） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 7（P2/P3/P4/P5 全派发;P7-S1 CR 亦派发） |
| 主进程直做 Phase 清单 | P1（①git 编排+③基线求和）、P6（①合并部署+③部署终裁）、P7-S2（⑤终验裁决+②簿记）;另 P2-S3/P5-S3 提交与求和（①③）——全部 25.3 白名单内 |
| 委派率 | **0.571（机器 stats）** <0.7 → **25.4a WHITELIST-EXEMPT 放行**（violations=[],verdict=ok;JSON 原文见 verification.md） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-09-30 | plan-writer | 撰写 task-v097 计划全文+knowledge-brief | done | 计划 349 行 7Phase/19S/VC7;brief 五段齐;WF-10 计数风险预判对策 b | task_plan.md 全文+knowledge-brief.md §2 | Research Findings 条 1-5 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/01-plan-writer.md | - / 0 / ☑ |
| 2 | | executor | P1-S1/S2 基线（如主进程委派时登记;白名单①③内亦可主进程直做） | | | | | plans/task-v097-tool-selection/subagent-state/ | - / 0 / ☐ |
| 3 | 2026-09-30 | executor | P2-S1 Rule 40 六子条全文 | done | 纯增 11 行（391→402）,六子条 `^40\.` 全命中,40.2 含伪行禁令/40.3 披露/40.6 零键全在位 | wt diff --stat 11 insertions 0 deletions | Research Findings 条 6 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/03-executor.md | - / 0 / ☑ |
| 4 | 2026-09-30 | executor | P2-S2 SKILL 四锚同步+行数级联 | done | SKILL 433 行净增 3;Rule40 锚×5;字面 1-39 保留×2/1-40 零命中;6 selftest 复跑 0 FAIL（主进程复核一致） | 04-executor.md+主进程复跑 Total 行 | Research Findings 条 7 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/04-executor.md | - / 0 / ☑ |
| 5 | 2026-09-30 | executor | P3-S1+S2 模板层三落点 | done | S1 区块+14 行冒烟 6/6;S2 mini-lite 豁免行（45≤80）+dispatch 提示行;plan-tier 32/0+dispatch 29/0（主进程抽验一致） | 05/06-executor.md+主进程复核 | Research Findings 条 8 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/05-executor.md | - / 0 / ☑ |
| 6 | 2026-09-30 | executor | P4-S1+S2 卫星+plan-writer 契约 | done | S1 mapping §十 15 纯增;S2 guide 场景5+plan-writer 义务行;锚零破坏;methodology 16/0+conclusion-discipline 24/0;两次 partial 均为任务书验收①口径缺陷（≥2 vs 逐字文本 1 处）,裁定 ≥1 采信 | 07/08-executor.md+主进程复核 | Research Findings 条 9+Error Log | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/07-executor.md | - / 0 / ☑ |
| 7 | 2026-09-30 | executor | P5-S1+S2 selftest 新建+registry 登记 | done | S1 12 断言首跑全 PASS;S2 tsv 38 行 rows=actual=37,registry 自守护 5/0（主进程复跑一致） | 09/10-executor.md+主进程复核 | Research Findings 条 10 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/09-executor.md | - / 0 / ☑ |
| 8 | 2026-09-30 | 主进程（白名单③） | P5-S3 全量复跑求和 | done | 37 脚本 604 PASS/0 FAIL（=基线 592+新增 12,精确咬合;commit ccfc70f） | progress.md Phase 5 求和行 | Research Findings 条 10 | 无（主进程机械验证,无子代理检查点） | - / 0 / ☑ |
| 9 | 2026-09-30 | code-reviewer | P7-S1 CR 审查 26f938c..52b434f | done | **APPROVED**（7 专项全 PASS,零 P0/P1;P2×3 已处置:a 注释修复+部署同步/b 备份移出扫描路径/c 维持现状登记） | 11-code-reviewer.md+CR 独立复跑 12 selftest | verification.md VC-7 | /mnt/data/dev/task-planner-skill/plans/task-v097-tool-selection/subagent-state/11-code-reviewer.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否（单 skill 任务,本区块留置默认态） |

## 🔁 模板感知

<!-- template_type: rule-enhancement -->
<!-- rule-enhancement 为已知 16 类之一,不触发 general 兜底区块;34.7 终验沉淀评估:本任务即规则沉淀本体,终验时按 34.3 三条件例行评估（同类第 N 次走既有 variant,预期登记「沿用 rule-enhancement-type 不另沉淀」） -->
- 触发信号: rule-enhancement 命中（加规则/新增 Rule/条款/门控/守护）
- Rule 34.3②: 沉淀预登记 —— 终验时例行评估,预期登记不另沉淀理由
- 终验必查: check-complete T3（template-sense warn 兜底,已知类型应零触发）
- 处置登记处: **不沉淀理由**（2026-09-30 终验登记）——本任务即规则增强本体（rule-enhancement 已知类型）,无新任务类型泛化点,34.3 三条件均未命中新类型 → 沿用 rule-enhancement-type 不另沉淀（Decisions Made 同步登记）
