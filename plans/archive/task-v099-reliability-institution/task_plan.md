---
template_type: rule-enhancement
plan_tier: standard
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    executor: 2
    code-reviewer: 1
  estimated_opus_equivalent: 1.3
  estimated_savings_vs_naive: 0.7
---

# Task Plan: task-v099-reliability-institution — Rule 42 质量审查技能主动检测与补充 + Rule 43 执行可靠性制度化（规则增强）

<!--
  WHAT: 本计划落地纯增量 Rule 42（五子条）+ Rule 43（四子条）+ selftest 静态守护 + SKILL 三锚联动（C30/C31/摘要行/括注）+ 模板配置表「质量审查工具」行 + mini-lite 豁免行 + plan-writer 契约义务行 + 新建 selftest-reliability-institution.sh（R-01..R-12）+ registry +1，worktree 隔离交付 + 三位部署 + push。
  WHY: 用户三条原话（Rule 31.1 触发①, 2026-09-30 /goal 自主会话延续, interaction_mode: silent）:
    1. 「在执行任务时，主动为项目补充质量审查技能……主动检测，需要用到质量审查时没有专用技能就补充。补充在项目级。」（原「每个项目 10 个以上」撤销，改主动检测制）
    2. 「最重要的是通过制度性确保执行可靠性。不要相信模型阐述……通过验证来确保执行可靠度。另外用更小模型消耗解决问题——通过制度（Agent 制度）解决。」
    3. 「候选/建议当前比较弱智。以后遇到问题应主动选择最优解，可以通过各种方式验证方案的可靠性。」
  归因（主进程已完成 31.2 四维，直接采用）:
    现象 = 质量审查靠临时起意无检测制度 + 完成声称混入未验证内容（幻觉）+ 选项化呈报未预验证候选
    直接原因 = 无「质量审查技能主动检测与补充」条款；无「证据先行」交付条款；无「S-unit 档位经济性」条款；无「候选预验证」条款
    根因（5 Whys 终点）= 可靠性依赖模型自觉而非制度性结构 → 补两条制度条款 + selftest 静态守护 + 计划/模板/契约消费面
    类别 = 规则缺位（→ Rule 36.2 归因指向本体，修改提案合法）
  方案骨架: 主进程 D2 已裁（01-task-brief.md 全文），纯增量五子条+四子条，零新 config 键，本计划细化不推翻。
  交互模式: /goal 自主会话延续, interaction_mode: silent（D6 硬停点两模式一致不可豁免, Rule 41 不弱化 D6）。
-->

<!-- plan_tier: standard -->
## Goal
在 task-planner 技能内落地纯增量 Rule 42「质量审查技能主动检测与补充」（42.1-42.5 五子条）+ Rule 43「执行可靠性制度化」（43.1-43.4 四子条）：critical-rules.md EOF 纯追加（格式同构 39/40/41）；SKILL.md 三锚联动（C30/C31 合规清单行 + Rule 42/43 摘要行 + 「含 Rule 42/43」括注）+ 行数级联 selftest-skill-split.sh:41；templates/task_plan.md 配置表加「质量审查工具」行 + templates/variant/mini-lite-type.md 豁免声明行；companion/agents/plan-writer.md 加义务行（S-unit 建议档位必填 + 质量审查工具检测登记 + 候选对比表义务）；新建 scripts/selftest-reliability-institution.sh（R-01..R-12，对齐 selftest-self-resolution.sh SR 范式）+ selftest-registry.tsv +1；全量 selftest 0 FAIL（基线 38 脚本 616 PASS）后合并回 master、三位部署 IDENTICAL、`git push origin master`（用户 09-30 持久指令 B 类登记）、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含新建 .sh 脚本 selftest-reliability-institution.sh，模板画像代码组触发） |
| `session_id` | task-v099-reliability-institution（plan 目录即会话锚，注册表=plans/INDEX.md） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution` |
| `branch` | `wt/task-v099-reliability-institution`（基线 master@55c24fc，2026-09-30 实测 `git rev-parse master`=55c24fcf7bb88a3af044437d13e2ee3a20557ddd） |
| `scope_files` | `skills/task-planner/references/critical-rules.md`; `skills/task-planner/SKILL.md`; `skills/task-planner/templates/task_plan.md`; `skills/task-planner/templates/variant/mini-lite-type.md`; `skills/task-planner/companion/agents/plan-writer.md`; `skills/task-planner/scripts/selftest-reliability-institution.sh`(新); `skills/task-planner/scripts/selftest-registry.tsv`; `skills/task-planner/scripts/selftest-skill-split.sh`（8 文件全列） |
| `interaction_mode` | `silent`（/goal 自主会话延续；D6 外不 AskUserQuestion + 静默决策清单登记，Rule 41.2 语义兼容） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 42/43 条款完整：critical-rules.md EOF 纯追加（既有 413 行零改动），`grep -c '^42\.'` = 5 且 `grep -c '^43\.'` = 4；42.2 含三级检测顺序（项目级→用户级→环境 agents）与「均未命中=缺口」；42.3 含「补充动作本身作为一个 S-unit 登记进计划（禁无登记私建技能）」；43.1 含「未验证内容只能以「未验证」显式登记」与「子代理 8 字段返回的 evidence 列无证据=该项视为未完成」；43.2 含「取可承载该步的最小档位」；43.3 含「候选对比表」；42.5/43.4 各含「零新 config 键」 | `grep -c '^42\.'` / `grep -c '^43\.'` + 逐措辞 grep | worktree 内 `references/critical-rules.md` 末段 |
| VC-2 | SKILL.md 三锚落地：C29（:194）后新增 C30（Rule 42 消费）+ C31（Rule 43 消费）两行；Rule 41 摘要行（:273）后新增 Rule 42/43 摘要行；:242「（Rules 1-39（含 Rule 40/41）」→ 括注追加 42/43（「含 Rule 42/43」字面在位，改写形态=扩括注不改「Rules 1-39」字面）；行数级联 selftest-skill-split.sh:41 `-le 435`→P2-S2 worktree 内 `wc -l` 实测值（label 注明 task-v099，435→实测，≤558 上限维持）；字面子串 `grep -c 'Rules 1-39'` = 2 且 1-4x 越界数字子串 = 0（v097 对策 b 锁，越界子串=Rules 序列号跳越字面 1-39 的 4 开头子串） | 逐锚 `grep -n` + `wc -l` 对照 + `bash scripts/selftest-skill-split.sh` 全 PASS | worktree 内 `SKILL.md` / `scripts/selftest-skill-split.sh` |
| VC-3 | 模板与契约落地：templates/task_plan.md 配置表（:26 `code_review` 行后）新增「质量审查工具」行（Rule 42.4 消费登记行，检测结论=技能名/既有 agent 名/待补充 S-unit 指针）；templates/variant/mini-lite-type.md 新增「质量审查工具」行豁免声明行（Rule 38.3 区块白名单自然延伸，对齐 40.2 豁免行 :7 形态）；companion/agents/plan-writer.md 新增义务行（S-unit 建议档位必填 + 质量审查工具检测登记 + 候选对比表义务，落 :40-45 撰写义务区） | `grep -n '质量审查工具'` 双模板各 ≥1 + Read plan-writer.md 义务行在位 | worktree 内三文件 |
| VC-4 | plan-writer.md 义务行在位且 selftest 可锚定：义务行含「S-unit 表每行标注建议档位」与「质量审查工具行检测登记」与「候选对比表」三要素措辞（selftest R-xx 断言锚） | `grep -c '建议档位' companion/agents/plan-writer.md` ≥1 + 三要素逐措辞 grep | worktree 内 `companion/agents/plan-writer.md` |
| VC-5 | 新 selftest 全 PASS + 全量回归 0 FAIL：`bash scripts/selftest-reliability-institution.sh` R-01..R-12 全 PASS exit 0；selftest-registry.tsv 40 行（39+1）且 `bash scripts/selftest-registry.sh` PASS（双向一致）；全量回归=worktree 内逐脚本实跑（38+1=39 脚本），Total 行求和正则**双形态覆盖**（`Total:` 行 + `==== selftest` 行，v098 教训——selftest-final-gate-hash.sh 走 `==== selftest` 形态，单正则漏 22 断言）= 0 FAIL 且总 PASS ≥ 616（P1 基线实测）+ R 断言增量（主进程逐脚本求和定数，禁采信子代理自报） | worktree 内逐脚本实跑 + 主进程求和复核 | progress.md Selftest Log / 各脚本输出 |
| VC-6 | 合并部署清理闭环：`git merge --no-ff wt/task-v099-reliability-institution` 成功；`bash scripts/smart-merge-back.sh <worktree> --deploy` 三位输出 IDENTICAL（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）；B 类用户指令 `git push origin master` 成功（推送前只读预检：`git rev-list --count master..origin/master` = 0，origin 无领先量）；`git worktree remove` + `git branch -d` 完成，`git worktree list` 无 wt/task-v099* 残留（0/0）；主仓 Read 关键文件复验（部署位 `grep -c '^42\.'`=5 命中） | merge 输出 + smart-merge-back [DEPLOY] 行 + push 输出 + `git worktree list` | 主仓 git log / 部署位文件 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策——升级前必须先过 Rule 41.4 消解清单并附「已尝试清单」）

> **注意**：`code_review: required` → 终验前必须先过 Code Review Gate（改动以 .md 条款与模板为主 + 新建 .sh，预计轻 diff 走单轮轻量审查亦可，按 task-v094 T-B6 分级），APPROVED 才可交付。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `skills/task-planner/references/critical-rules.md`（EOF 纯追加 Rule 42 节 + Rule 43 节，格式同构 39/40/41：节头+行首 42.N/43.N 子条+末子条机制收尾） | 改既有任何 Rule 原文/语义（**Rule 22-41 任何原文零改动**）；机械锚点级联（行号引用随追加漂移）除外且登记 |
| 技能正文 | `skills/task-planner/SKILL.md`（三锚联动：C30/C31 行新增 / Rule 42/43 摘要行新增 / :242 括注追加 42/43） | 动「Rules 1-39」字面 2 处（:242/:297）；新增段落禁产生越界数字子串（v097 对策 b 锁）；三锚外大段新增 |
| 模板 | `skills/task-planner/templates/task_plan.md`（配置表 +1「质量审查工具」行）；`skills/task-planner/templates/variant/mini-lite-type.md`（+1 豁免声明行） | 模板契约标记（`<!-- template_type: -->` 机读行等）任何改动；其他模板文件 |
| 契约 | `skills/task-planner/companion/agents/plan-writer.md`（撰写义务区 +1 行） | 删改既有义务行；frontmatter 改动 |
| 测试 | `skills/task-planner/scripts/selftest-reliability-institution.sh`（新建，R-01..R-12）；`scripts/selftest-registry.tsv`（+1 行）；`scripts/selftest-skill-split.sh`（仅 :41 行数断言值级联，label 注明 task-v099）；`scripts/selftest-self-resolution.sh`（仅 SR-11/SR-12 两处锚值级联——v098 旧守护在 v099 级联下的必要修正，B 类扩围 2026-09-30 登记：SR-11 锚 token task-v098→task-v099、SR-12 registry 行数 39→40，断言语义零改动） | 其他 selftest/check 脚本；断言逻辑语义改写 |
| 配置 | （无） | `config.json`（**零新键**，properties=40 维持）；其他任何配置 |
| 计划文件 | `plans/task-v099-reliability-institution/**`（三件套 + knowledge-brief + subagent-state） | 其他 plans/ 目录；如实披露：27.3 预检会把 `**` 剥成裸目录 token，本目录簿记提交前恒为 untracked → check-complete 定于 P5 簿记提交之后复跑（v097/v098 先例） |

**执行前自我检查:**
- [x] 这个文件在上面的列表中吗？
- [x] 这个修改对完成任务有必要吗？
- [x] 用户明确要求我做这个修改吗？（用户三条原话点名制度缺失=Rule 42/43 提案授权；Rule 36.2 归因类别=规则缺位指向本体）
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | Rule 39/40/41 既有条款范式（节头+子条+机制收尾） | `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` :383-413 | 必读 | ☑（S0 撰写方已 Read） |
| 项目内部文档/知识库 | SKILL.md 三锚现状（C29/Rule 41 摘要行/「Rules 1-39」字面 2 处/References 行） | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` :194, :273, :242, :297 | 必读 | ☑ |
| 项目内部文档/知识库 | selftest SR 静态断言范式（变量头/ok()/bad()/编号断言/exit 语义） | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-self-resolution.sh` :1-99 | 必读 | ☑ |
| 项目内部文档/知识库 | 行数级联断言点（T-主 -le 435, :41） | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-skill-split.sh` :41 | 必读 | ☑ |
| 项目内部文档/知识库 | 模板配置表现状（5 行 :25-30）与 mini-lite 豁免行形态（:7） | `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` :25-30; `templates/variant/mini-lite-type.md` :7 | 必读 | ☑ |
| 项目内部文档/知识库 | plan-writer 撰写义务区（任务分解/VC 设计/knowledge-brief 产出/工具选择行） | `/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/plan-writer.md` :40-45 | 必读 | ☑ |
| 项目内部文档/知识库 | registry 双向一致契约（39 行含表头，末行=selftest-self-resolution） | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-registry.tsv` :1-39 | 参考 | ☑ |
| 项目内部文档/知识库 | Rule 42/43 六子条方案骨架全文（主进程 D2 已裁） | `plans/task-v099-reliability-institution/subagent-state/01-task-brief.md` :10-22 | 必读 | ☑ |
| 同族先例 | v098 交付计划（结构/字段形态/Decisions 三条经验继承：workflow 编排/25.4a 白名单/级联 wc 实测） | `plans/task-v098-auto-resolution/task_plan.md` 全文 | 必读 | ☑ |
| 用户级宪法 | §十一 worktree 隔离 / §六 保护区 | `/home/terry/.zcode/AGENTS.md` | 参考 | ☑ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL/版本/commit SHA）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 执行可靠性当前依赖模型自觉（质量审查临时起意、完成声称可混入幻觉、选项化呈报未预验证候选、默认大模型消耗）——把可靠性从「相信模型阐述」转为「制度性结构+机器可复现验证」（Rule 42 检测/补充/消费登记 + Rule 43 证据先行/档位经济/候选预验证/42.5/43.4 机制面），升级/审查从默认缺失变为条款 gated 的纪律。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？（Rule 42 五子条 + Rule 43 四子条 + 三锚联动 + 模板/契约消费面 + selftest 守护 + 部署 = 交付）
- [x] 核心问题不解决，其他工作都白费吗？（不解决则用户点名的三类行为模式——审查缺位/幻觉完成/弱智候选——无制度约束，门控照旧缺失）
- [x] 核心问题的解决方法是清晰的、可执行的？（D2 已裁：纯增量五+四子条 + 零新键 + selftest 静态断言 + C30/C31 消费侧；方案骨架用户已定，本计划细化不推翻）

**如果无法回答核心问题，禁止开始任务！**（已回答，归因见文件头注）

## Current Phase
（终态）Phase 5 complete

## Next Step
交付报告呈示（含委派率机面口径披露+静默决策清单）;收尾=INDEX/账本/memory。派 executor 执行 P2-S1:critical-rules.md L413 后纯追加 Rule 42 五子条+Rule 43 四子条（任务书 03-task-brief.md,材料包=01-task-brief :10-22 骨架全文+brief §1/§2）。：check-conflicts 复扫（信号①=plans 指针+本目录）→ 建 worktree（@55c24fc, 分支 wt/task-v099-reliability-institution）→ worktree 内复测基线（selftest 求和/wc/grep 锚）并落 progress.md，携实测值启动 P2 派发。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | ⑥ 机械守卫脚本（check-conflicts.sh/selftest 全量求和）+ ② 计划系统文件维护（基线落盘 progress）+ ① git 编排（worktree 建立） | 基线测绘与 worktree 编排为白名单①②③直做面；基线求和纪律禁子代理自报（25.3 白名单③机械验证） |
| Phase 2 | ③ Agent 子代理 executor（S1 建议档位 sonnet-1 / S2 建议档位 haiku-1） | 条款撰写=判断型（sonnet-1 承载 42/43 语义精度）；三锚联动+级联=轻量编辑（haiku-1 可承载，43.2 最小档示范） |
| Phase 3 | ③ Agent 子代理 executor（S1 建议档位 haiku-1 / S2 建议档位 sonnet-1）+ ⑥ 机械验证（全量回归主进程求和） | 模板/契约行=轻量编辑 haiku-1；新建 selftest 12 断言=代码组判断型 sonnet-1；回归求和=白名单③主进程复核定数 |
| Phase 4 | ① git 编排（merge/deploy/push/cleanup 主进程白名单①）+ ③ 机械验证（只读预检/git status） | 部署编排是 git 生命周期操作；push=B 类用户持久指令随本 Phase |
| Phase 5 | ③ Agent 子代理 code-reviewer(sonnet-1)（Code Review Gate）+ ② 簿记 + ③ 机械验证（check-complete.sh 终验） | CR 上下文隔离审查（建议档位 sonnet-1）；簿记=白名单②；终验=白名单③ |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 维持 Rule 21.4 串行（Phase 间强依赖：P2 条款→P3 守护→P4 合并部署，无可并行独立子任务，无长链复用，用户未点名 /workflow；v098 的 CreateWorkflow 编排经验继承为「用户点名才路由」先例登记）。
**/goal 对齐（Rule 40.3）**: 用户已用 /goal 锚定自主会话延续（interaction_mode: silent 即其映射）；本计划 Goal+VC 表即该会话目标完成审计的证据源；如实披露：/goal 为用户侧 harness 命令，技能层不可代调、不可读取其运行态，对齐证据 = VC 证据链本身。

## Phases

### Phase 1: 基线测绘 + worktree 隔离
- [ ] check-conflicts 复扫（信号①=plans 指针+本目录，与 scope 零重叠确认；隔离决策表 conflict_scan=safe 落 P1 复扫结果）
- [ ] worktree 建立：`git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution -b wt/task-v099-reliability-institution master`（@55c24fc，porcelain=0 确认）
- [ ] worktree 内基线复测落 progress.md：selftest 逐脚本 Total 双形态求和（`Total:` 与 `==== selftest` 双正则，基线 38 脚本 616 PASS/0 FAIL）+ `wc -l` SKILL=435/CRIT=413 复核 + `grep -c 'Rules 1-39'`=2 + registry 39 行（P1 实测值即 P2-S2 级联输入）
- [ ] 知识储备必读项逐项勾选确认
- **V-N:** VC-1, VC-2, VC-5——全部 ✅（progress.md Phase 1 Test Results: 435/413/字面 2/registry 39/全量 616/0）
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排 + ② 计划系统文件维护（基线落盘 progress）+ ③ 机械验证（selftest 求和/wc/grep 只读）——Rule 25.3 白名单①②③；基线求和纪律禁子代理自报（主进程逐脚本求和定数））

### Phase 2: 条款层 Rule 42+43（critical-rules.md EOF 纯追加）+ SKILL 三锚联动 + 行数级联
- [x] S1: critical-rules.md EOF（L413 后）纯追加 `### 42 质量审查技能主动检测与补充` 节头 + 42.1-42.5 五子条 + `### 43 执行可靠性制度化` 节头 + 43.1-43.4 四子条（内容骨架=01-task-brief.md :10-22 主进程 D2 已裁全文；格式同构 39/40/41：节头（P0 — task-v099 目标句式）+ 行首 42.N/43.N + 末子条机制收尾「零新 config 键」）
- [x] S2: SKILL.md 三锚联动——①C29（:194）后加 C30（Rule 42 消费：质量审查工具行在位+检测登记措辞）+C31（Rule 43 消费：证据先行/档位/候选预验证措辞）；②Rule 41 摘要行（:273）后加 Rule 42/43 摘要行（子条一句话分解，句式对齐 :272/:273）；③:242「（Rules 1-39（含 Rule 40/41）」括注扩为含 Rule 42/43（字面「Rules 1-39」本体不动）；④行数级联——worktree 内 S2 完成后 `wc -l SKILL.md` 实测 N，改 selftest-skill-split.sh:41 `-le 435`→`-le N`（label 改注 task-v099，对齐 v098 先例「433→435」句式）
- **V-N:** VC-1, VC-2, VC-4（`grep -c '^42\.'`=5 且 `'^43\.'`=4；三锚+级联在位；括注后 `grep -c 'Rules 1-39'`=2 硬断言）
- **Status:** complete
- **Executor:** executor（S-unit 表见下，逐行建议档位；P2 内按 21.4 串行 S1→S2）
<!-- S-unit 派发单元表(Rule 22.6 — 单步 ≤2 文件/≤100 行/≤15min;ID 纯数字;时长 NNmin;输入列=路径+≤10 行摘要;「建议档位」列=43.2 首个示范,取可承载该步最小档位: 机械 IO=mini/轻量编辑=haiku-1/判断型=sonnet-1/复杂判断=opus) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 建议档位 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|
| S1 | critical-rules.md EOF 追加 Rule 42 五子条 + Rule 43 四子条全文 | executor(sonnet-1) | sonnet-1 | `skills/task-planner/references/critical-rules.md`:383-413（Rule 40/41 节头+子条+机制收尾格式范式）；`plans/task-v099-reliability-institution/subagent-state/01-task-brief.md`:10-22（42/43 子条骨架全文）；`plans/task-v099-reliability-institution/knowledge-brief.md` §1/§2 | `grep -c '^42\.'`=5 且 `'^43\.'`=4；节头含（P0 — task-v099）；42.2 含三级检测顺序；42.3 含「S-unit 登记」；43.1 含「未验证」登记+8 字段 evidence 无证据=未完成；43.2 含最小档位；43.3 含候选对比表；既有 413 行 diff 零改动 | 15min | pending |
| S2 | SKILL.md 三锚联动 + selftest-skill-split.sh 行数级联 | executor(haiku-1) | haiku-1 | `skills/task-planner/SKILL.md`:194（C29 句式）、:273（Rule 41 摘要行句式）、:242（括注位）；`skills/task-planner/scripts/selftest-skill-split.sh`:41（级联断言行现状）；`plans/task-v099-reliability-institution/knowledge-brief.md` §3/§4 | C30/C31 行在位；摘要行在位；括注含「含 Rule 42/43」且 `grep -c 'Rules 1-39'`=2；级联值=wc 实测 N（P1 基线 435 为输入下限）且 label 含 task-v099；`bash scripts/selftest-skill-split.sh` 全 PASS | 10min | pending |

### Phase 3: 模板 + 契约 + 新 selftest + registry
- [x] S3: templates/task_plan.md 配置表（:26 `code_review` 行后）+1「质量审查工具」行；templates/variant/mini-lite-type.md +1 豁免声明行（对齐 :7 Rule 40.2 豁免行形态：「质量审查工具」行 mini 档豁免，Rule 38.3 区块白名单自然延伸）；companion/agents/plan-writer.md 撰写义务区（:40-45 内）+1 行义务（S-unit 建议档位必填 + 质量审查工具检测登记 + 候选对比表义务）
- [x] S4: 新建 scripts/selftest-reliability-institution.sh（R-01..R-12 静态断言，对齐 selftest-self-resolution.sh SR 范式：变量头/ok()/bad()/编号断言/exit 语义；断言清单=42 计数=5/43 计数=4/C30/C31/摘要行/括注「含 Rule 42/43」/模板行/mini-lite 豁免行/plan-writer 义务行/级联 label task-v099/registry 行/零新键 properties=40）；selftest-registry.tsv +1 行（script=selftest-reliability-institution.sh / domain=Rule 42/43 质量审查检测+执行可靠性制度化 / trigger_scenarios / dep_anchors 四列齐）+ 跑 `bash scripts/selftest-registry.sh` 验双向一致（tsv=40 行）
- [x] 全量回归：主进程在 worktree 内逐脚本实跑（39 脚本），Total 行双形态求和（`Total:` 与 `==== selftest` 双正则，v098 教训）——0 FAIL 且总 PASS ≥ 616 + R 断言增量（定数主进程复核定数，禁采信子代理自报）
- **V-N:** VC-3, VC-4, VC-5（模板/契约行在位；新 selftest 全 PASS；全量 0 FAIL 基线不回退）
- **Status:** complete
- **Executor:** executor（S-unit 表见下，逐行建议档位；P3 内按 21.4 串行 S3→S4，回归求和主进程白名单③）
<!-- S-unit 派发单元表(Rule 22.6;「建议档位」列=43.2 示范,取可承载该步最小档位) -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 建议档位 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|---------|-------------|---------|------|------|
| S3 | 模板配置表「质量审查工具」行 + mini-lite 豁免行 + plan-writer 义务行 | executor(haiku-1) | haiku-1 | `skills/task-planner/templates/task_plan.md`:24-30（配置表 5 行现状）；`skills/task-planner/templates/variant/mini-lite-type.md`:7（Rule 40.2 豁免行形态范式）；`skills/task-planner/companion/agents/plan-writer.md`:40-45（撰写义务区）；`plans/task-v099-reliability-institution/knowledge-brief.md` §3 | 三文件各 +1 行且 `grep -c '质量审查工具'` 模板双命中；plan-writer 义务行含建议档位/检测登记/候选对比表三要素；模板契约标记零改动 | 10min | pending |
| S4 | 新建 selftest-reliability-institution.sh（R-01..R-12）+ registry +1 行 | executor(sonnet-1) | sonnet-1 | `skills/task-planner/scripts/selftest-self-resolution.sh`:1-99（SR 范式全文：变量头/ok()/bad()/编号断言/exit）；`skills/task-planner/scripts/selftest-registry.tsv`:1-39（四列表头+末行格式）；`plans/task-v099-reliability-institution/knowledge-brief.md` §4/§5（易错点+材料包） | `bash scripts/selftest-reliability-institution.sh` 全 PASS exit 0；tsv=40 行四列齐；`bash scripts/selftest-registry.sh` PASS；只读零仓库写入（守护脚本自身） | 15min | pending |

### Phase 4: 合并回 master + 三位部署 + push + worktree 清理
- [x] 只读预检：`git rev-list --count master..origin/master` = 0（origin 无领先量，push 安全）；主仓 `git status --short` 确认与 scope 无重叠未提交变更（v098 教训：并行会话残留须先 STOP 报告）
- [x] `git merge --no-ff wt/task-v099-reliability-institution`（smart-merge-back V1-V6 校验）→ 主仓 `grep -c '^42\.'`=5 亲验
- [x] `bash scripts/smart-merge-back.sh <worktree> --deploy` 三位 IDENTICAL（~/.zcode、~/.claude、~/.config/opencode）
- [x] B 类用户指令：`git push origin master`（用户 2026-09-30「完成修改之后记得部署到各个平台，然后提交到GitHub进行备份」持久指令沿用，Decisions 登记；v086 P4/v098 B 类先例）
- [x] 清理：`git worktree remove` + `git branch -d wt/task-v099-reliability-institution`，`git worktree list` 无残留（0/0）
- **V-N:** VC-5, VC-6（全量 0 FAIL 在合并前 worktree 内终复；部署+push+清理闭环）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排（merge/deploy/push/cleanup 全链）+ ② 计划系统文件簿记（merge_back 字段回填）+ ③ 机械验证（只读预检/git status 只读输出可控）——Rule 25.3 白名单①②③）

### Phase 5: CR Gate + 终验簿记
- [x] Code Review Gate：code-reviewer(sonnet-1) 上下文隔离审查本任务改动（selftest-reliability-institution.sh 为 .sh 主审面；critical-rules.md/SKILL.md/模板/.tsv 为 .md/.tsv 轻审面）；APPROVED 才进终验；CHANGES_REQUESTED → fix-phase（≤3 轮，Rule 33.4）
- [x] 终验：Read verification.md 逐条复验 VC-1..VC-6（每条带证据路径）；`bash scripts/check-complete.sh`（执行顺序：先完成计划八件套簿记提交使 plans 目录入 tracked，27.3 预检转 clean 后再跑，v097/v098 先例）；委派率统计（预期 2/5=0.4<0.7，主进程直做 P1/P4/P5 全命中白名单①②③ → 25.4a WHITELIST-EXEMPT 放行登记，v098 先例）
- [x] 簿记收尾：findings.md 回填全部 Handoff 行 verify_done；progress.md Error Log Prevention 列回填；Decisions Made 补登 silent: 决策；task_plan.md 各 Phase 翻 complete + 隔离决策 merge_back=merged(<commit>)；计划八件套随簿记提交入库
- [x] 学习闭环终验：check-complete Learning Gate（Error Log Root Cause 非空）；REFLECT-GATE 两行落 progress.md
- **V-N:** VC-5, VC-6（CR APPROVED + 终验全 VC 复验 + 零回归 + 部署位复验）
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+ 主进程簿记（例外理由:② 计划系统文件簿记 + ⑤ 委派统计/质量门控机械复核——Rule 25.3 白名单②⑤；CR 本体经子代理隔离执行非主进程亲审）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（信号①=plans 指针 + 本目录，与 8 文件 scope 零重叠——主进程 P1 复扫确认；②无额外 worktree；③无遗留 wt/* 分支；④无待处理任务在册；⑤本任务 scope 即运行中基础设施→按隔离处理而非冲突） |
| `isolation` | `worktree`（修改 skills/ 运行中基础设施，宪法 §十一 11.1-1/5 强制命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution`（§11.2 集中目录，仓外绝对路径） |
| `branch` | `wt/task-v099-reliability-institution`（基线 master@55c24fc，2026-09-30 实测） |
| `merge_back` | `merged(d066159)`（V1-V6+三位 IDENTICAL+push 55c24fc..d066159 ls-remote 终验+清理 0/0） |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`。并行开发约束：CWD 不迁移，worktree 内禁碰其他 worktree，禁 checkout/reset --hard/clean -fd。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 2 | SKILL 行数级联断裂：三锚+摘要行净增超估 → selftest-skill-split T-主 `-le 435` 与既有 ≤558 目标线双断言失配（v098 实证 RPN 前列风险） | 9 | 4 | 4 | 144 | 兜底=级联值一律以 P2-S2 完成后 worktree 内 `wc -l SKILL.md` 实测为准禁手估（P2-S2 输入列已预携 P1 实测 435 下限）；FAIL 时回 S-unit 单断言修复重派（22.3 ②），禁改 selftest 断言语义迁就 |
| Phase 2 | 「Rules 1-39」字面 2 处（:242/:297）保全失败：括注改写误伤字面或新增文本产生越界子串 → skill-split/既有静态断言 FAIL（v097 对策 b 锁） | 8 | 5 | 3 | 120 | 兜底=括注采用扩写形态（「含 Rule 40/41/42/43」式追加，字面本体不动）+ P2-S2 验收 `grep -c 'Rules 1-39'=2` 硬断言前置；FAIL 时 S-unit 拆细修正措辞重派（22.3 ②） |
| Phase 3 | 新 selftest R 断言与既有 39 脚本口径冲突（properties=40 漂移/级联值与 wc 实测不一致/registry 双向不一致）→ 全量回归 FAIL | 7 | 4 | 3 | 84 | 断言值以 P1 基线实测为准（§2 已验证事实表）；FAIL 走 22.3 完整兜底链（改派 debug 定位→拆细→降档→主进程接管） |
| Phase 4 | 部署位 DRIFT 或 push 撞 origin 领先量（并行会话推过）→ 部署 fail-closed / push 非快进拒绝 | 6 | 3 | 3 | 54 | smart-merge-back 自带 fail-closed；push 前只读预检 `git rev-list --count master..origin/master`，非 0 → STOP 报告用户（G3 对外不可撤回面，41.2 四门槛） |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填（写清走 22.3 哪一档）。本表为规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链（本任务自身消解时先过 41.4 清单，升级上报附「已尝试清单」）。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | S1 映射在计划批准后立即建立 |
| Phase 2 | ☐ |  | 含 S1-S2 两个 S-unit |
| Phase 3 | ☐ |  | 含 S3-S4 两个 S-unit + 主进程回归求和 |
| Phase 4 | ☐ |  | 主进程直做 |
| Phase 5 | ☐ |  | CR Gate+终验 |

> 契约详见 `~/.zcode/skills/task-planner/references/todo-sync.md`。

## Key Questions

1. Rule 42 三级检测顺序的项目级/用户级边界以哪份机制画像为准？（答：42.1 明文「机制画像 template-mapping §九 为准」——内容组=发布前质量审计面/代码组=Code Review 面；检测顺序=项目级（.zcode/skills、.agents/skills 工作区级）→用户级（~/.zcode、~/.agents）→环境既有 agents，均未命中=缺口）
2. Rule 43 四子条与既有 22.3/28/35.6 语义如何共存？（答：43 为后置制度层——43.1 声明完成门三条件既有机制的制度化面、43.2 衔接子代理路由表模型档位列、43.3 衔接 35.6 最小探针；既有原文零改动，42.5/43.4 统一「零新 config 键」）
3. selftest-reliability-institution.sh 12 断言与既有 SR/TS/WF 断言集如何零口径冲突？（答：对齐 SR 范式纯静态 grep/wc/jq；properties=40 与 TS-12/WF-12 同口径；级联值以 wc 实测为准；registry 双向一致由 selftest-registry.sh 独立守护）
4. 全量回归求和正则为何必须双形态？（答：v098 教训——selftest-final-gate-hash.sh 的 Total 行走 `==== selftest` 形态而非 `Total:` 行，单正则漏 22 断言；VC-5 明文双覆盖，主进程求和定数）
5. 委派率 0.4<0.7 会被 check-complete 阻断吗？（答：不会——主进程直做 P1/P4/P5 全命中 25.3 白名单①②③⑤，25.4a WHITELIST-EXEMPT 放行（v098 先例），P5 统计段如实登记）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D2（已裁，沿用）: 纯增量新增 Rule 42 五子条 + Rule 43 四子条，不改 22.3/28/39/40/41 任何原文 | 后置制度层经 checklist 生效；Rule 36.5 纯增量纪律；既有升档链/询问点原文零触碰 |
| 零新 config 键（42.5/43.4） | 与 task-v087/v088/v097/v098 同范式；判定面=LLM 行为无需开关键；properties=40 维持使 TS-12/WF-12 断言零改动 |
| 消费侧=C30/C31（合规清单行）而非新 hook/check 脚本 | 轻量消费（v098 C29 先例）；机器面由 selftest-reliability-institution.sh 静态断言承载 |
| 主进程直做 P1/P4/P5，P2/P3 派发；理由命中白名单①②③⑤ | 基线求和纪律（禁子代理自报）+git 编排+簿记+机械验证=白名单面；判断型工作派 executor；S-unit 表逐行建议档位=43.2 首个示范（本计划自身 dogfooding） |
| silent: plan-writer 档位死亡（reasoning-level-missing 实测）→executor 接管撰写（22.3④+25.3 白名单⑤,接管先于派发登记） | plan-writer 在实测中缺 reasoning 档位无法承担条款撰写；接管动作本身先登记后执行（本表+Handoff 表第 1 行双落），避免无登记私改执行体 |
| silent: push 授权=用户 09-30 持久指令沿用（「完成修改之后记得部署到各个平台，然后提交到GitHub进行备份」） | B 类指令 v086 P4/v098 先例成立；G3 对外不可撤回面已过（用户显式授权）；push 随 P4 部署后执行，只读预检前置 |
| B 类扩围（主进程登记 2026-09-30, 非用户指令, 任务内必要修正）: selftest-self-resolution.sh SR-11/SR-12 锚值随 v099 级联更新（label 439/registry 40 行） | v098 旧守护断言锚随级联漂移是 v097/v098 先证模式;修正=两处锚值,断言语义零改动,范围表同步登记 || silent: 模板/契约改动新会话生效 | templates/ 与 companion/agents/plan-writer.md 为会话加载面，改动仅对计划批准后的新会话生效，本会话内执行期行为以本计划 VC 为准；登记防「改完即生效」误判 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| plan-writer 档位 reasoning-level-missing 实测死亡 | 1 | executor 接管撰写（22.3④+25.3 白名单⑤,接管先于派发登记;Handoff 第 1 行双落） | 机器事实源字段口径:档位存活先探针后派发（v081 先例）——Prevention 已入 notepad |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- 本任务自身即 Rule 43 首个适用对象：S-unit 建议档位示范（43.2）+ 全量回归主进程求和（43.1 证据先行）+ 候选预验证（43.3）——dogfooding 是 VC 之外的隐性验收
- 禁止在 SKILL.md/模板新增文本中产生越界数字子串（v097 对策 b 锁）；「Rules 1-39」字面 2 处（:242/:297）本体不可动，只可括注扩写

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

> 本任务非批量（chain_mode: single，S-unit 合计 4 个均异质、无 ≥5 同构单元批量操作），八字段按 0 值零单元声明填写（v097/v098 先例——非批量任务填 0 值声明，禁填 n/a：check-complete 18.6 门 n/a 判缺项）。

| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——本任务非批量,无 ≥5 同构单元批量操作） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0%（0/0,无批量面;>5% → STOP 条款不适用） |
| `sampled_pass` | 0（零单元,抽检不适用） |
| `sampled_fail` | 0（零单元,熔断条款不适用） |
| `pre_check` | Q1:否（每 Phase 独立判断，非同质单元）/Q2:有（VC 表客观验收）/Q3:能（worktree+git 可回滚） |
| `rollback_point` | master@55c24fc（worktree 隔离天然回滚点） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（P2、P3——executor 派发；P5 部分=code-reviewer 隔离审查） |
| 主进程直做 Phase 清单 | P1（①git 编排+②计划系统文件+③机械验证）/ P4（①git 编排+②簿记+③机械验证）/ P5（②簿记+⑤委派统计机械复核；CR 经 code-reviewer 隔离）——全部命中 25.3 白名单 |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL；预期 0.4 走 25.4a WHITELIST-EXEMPT 判定，v098 先例） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-09-30 | executor | 接管 plan-writer 面撰写本计划 task_plan.md + knowledge-brief.md（plan-writer 档位死亡,22.3④+25.3 白名单⑤） | done | 计划全量落盘（8 区块+VC 6 条+S-unit 4 行带建议档位）;检查点 02-executor.md | plans/task-v099-reliability-institution/task_plan.md:1 | task_plan.md Decisions/本行 | plans/task-v099-reliability-institution/subagent-state/02-executor.md | - / 0 / ☐ |
| 2 | 2026-09-30 | executor | P2-S1 条款层 Rule 42/43 九子条追加 | done | +19 行纯增（413→432）,^42.=5/^43.=4,八措辞全命中,越界字面 0 | 03-executor-p2s1.md+主进程复核 numstat 19/0 | findings Research 条 3 | plans/task-v099-reliability-institution/subagent-state/03-executor-p2s1.md | - / 0 / ☑ |
| 3 | 2026-09-30 | executor | P2-S2 SKILL 三锚+级联 | done | C30/C31/摘要×2/括注扩写,SKILL 439 行,级联 439,4 脚本 0 FAIL,字面 1-39=2/1-40=0（主进程复核一致） | 04-executor-p2s2.md | findings Research 条 4 | plans/task-v099-reliability-institution/subagent-state/04-executor-p2s2.md | - / 0 / ☑ |
| 4 | 2026-09-30 | executor | P3-S3/S4 模板+契约+selftest+registry | done | 5 文件落地（R-01..12 首跑 12/0/tsv 40 行）;SR-11/12 锚级联主进程白名单③修正（B 类扩围登记）;全量 628/0 | 05-executor-p3.md+主进程全量定数 | findings Research 条 5 | plans/task-v099-reliability-institution/subagent-state/05-executor-p3.md | - / 0 / ☑ |
| 5 | 2026-09-30 | code-reviewer | P5-S1 CR 隔离审查 d066159 | done | **APPROVED**（0 P0/P1/2 P2 非阻断,6 专项全 PASS;P2-a 注释同步已处置,P2-b exec bit 家族惯例登记） | 06-cr-p5.md | findings/verification CR 段 | plans/task-v099-reliability-institution/subagent-state/06-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置（可选）

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single`（单 block，无 chain 区块） |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是（/goal 会话目标审计） |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | plans/task-v099-reliability-institution/ 三件套+knowledge-brief | `bash scripts/check-complete.sh` | - |

## 🔁 模板感知
<!-- template_type: general -->
<!-- task-v096 P2-S1: 运行时追加区块（非模板本体）; general=类型空缺兜底, 已知 16 类类型不产生本区块;
     上方注释行为 check-template-type 第三形态机读标记（general 恒合法, gate exit 0）, 同时完成 Rule 34.3② 预登记 -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 不沉淀理由: 本任务为 rule-enhancement 已知类型（本计划 frontmatter 即 template_type: rule-enhancement）第 N 次消费,34.3 三触发条件（同类新类型/类型空缺/用户点名沉淀）均不命中 → 沿用既有 rule-enhancement-type 不另沉淀（2026-09-30 终验登记）
- **无删除声明（Rule 36.3/36.6 登记,2026-09-30 终验）**: 本任务全量 diff 零功能性删除——critical-rules.md 纯追加 19 行;SKILL.md 3 处 deletion 均为行内括注/枚举扩写（CR 专项 1 核过）;模板/契约各 +1 行;config.json 零改动（properties=40）——删除性行为清单=空
