# task-v099-reliability-institution 计划撰写任务书（主进程派发 plan-writer）

角色: plan-writer。为 task-v099-reliability-institution 撰写完整 task_plan.md（全量替换占位）+ knowledge-brief.md（五段）。六文件已初始化于 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/。

【用户三条原话（2026-09-30，/goal 自主会话延续, interaction_mode: silent）】
1. 「在执行任务时，主动为项目补充质量审查技能。涉及质量审查/涉及任务时发现缺失专业质量审查技能，就需要补充。比如写文章，若当前项目没有质量审查技能就需要补充。每个项目 10 个以上的想法过于呆板，撤销——改为：主动检测，需要用到质量审查时没有专用技能就补充。补充在项目级。」
2. 「最重要的是通过制度性确保执行可靠性。不要相信模型阐述（模型会说莫名其妙但以为是正确的东西，其实是幻觉），通过验证来确保执行可靠度。另外用更小模型消耗解决问题——不可能所有任务都用巨大模型，成本受限，通过制度（Agent 制度）解决。」
3. 「候选/建议当前比较弱智。以后遇到问题应主动选择最优解，可以通过各种方式验证方案的可靠性。」

【主进程 D2 已裁方案骨架（纯增量，勿推翻，可细化）】
新增 **Rule 42「质量审查技能主动检测与补充」** 五子条：
- 42.1 触发条件：任务类型涉及质量审查面（内容组 writing/research/publish=发布前质量审计面；代码组=Code Review 面；机制画像 template-mapping §九 为准）
- 42.2 检测顺序：项目级 skills（.zcode/skills、.agents/skills 工作区级）→ 用户级（~/.zcode/skills、~/.agents/skills）→ 环境既有 agents（code-reviewer/critic/quality-reviewer 类）→ 均未命中=缺口
- 42.3 补充合约（缺口处置）：在该任务项目级补建专用质量审查技能（骨架=SKILL.md 审查清单+触发描述+输出合约 APPROVED/CHANGES_REQUESTED；三点登记：计划「质量审查工具」行+selftest 守护+部署）；补充动作本身作为一个 S-unit 登记进计划（禁无登记私建技能）
- 42.4 消费登记：计划配置表加「质量审查工具」行（检测结论=技能名/既有 agent 名/待补充 S-unit 指针）；执行期质量审查动作必须用该行登记的工具，登记「未检测」即违规（Rule 26 降质面）
- 42.5 机制：零新 config 键；selftest 静态断言；mini 档豁免（Rule 38.3）

新增 **Rule 43「执行可靠性制度化」** 四子条：
- 43.1 证据先行反幻觉：交付物中每个「已完成/正确/通过」重要声称必须附机器可复现验证证据（命令+关键输出/Read 路径+关键行/diff 行号）；未验证内容只能以「未验证」显式登记，禁止混入完成表述；子代理 8 字段返回的 evidence 列无证据=该项视为未完成（不信口供制度，完成门三条件既有机制的制度化声明面）
- 43.2 模型档位经济性路由：计划期 S-unit 表逐行标注「建议档位」（对齐子代理路由表 model 档位列，取可承载该步的最小档位：机械 IO=mini、轻量编辑=haiku-1、判断型=sonnet-1、复杂判断=opus）；执行期失败先按 22.3 升档而非默认大模型；禁止整计划默认大模型（成本制度面）
- 43.3 方案预验证与最优选择：提推荐/选项化询问（D1-D6）前须枚举 ≥2 候选方案，每候选过最轻验证动作（探针/锚点 grep/最小样本，Rule 35.6 衔接）后登记「候选对比表」（方案/验证法/验证结果/成本/裁决依据）选已验证最优为推荐；验证成本过高 → 降级「假设清单+验证顺序」并登记假设；禁止呈现未验证即「貌似合理」的选项
- 43.4 机制：C30/C31 检查点消费；selftest 静态断言；零新 config 键

【配套联动（先 Read 核实行号）】
- SKILL.md（当前 435 行）：合规清单 C29 后加 C30（Rule 42 消费）+C31（Rule 43 消费）；Rule 41 摘要行后加 Rule 42/43 摘要行；「含 Rule 40/41」→「含 Rule 42/43」（字面「Rules 1-39」两处保留+「1-40」禁引入，v097 对策 b 锁）；行数级联 selftest-skill-split.sh:41（-le 435→实测，label task-v099）
- templates/task_plan.md（434 行）：配置表加「质量审查工具」行（+ mini-lite-type.md 豁免声明行 + subagent_dispatch.md 无改动或 +1 提示行，你裁）
- companion/agents/plan-writer.md：加义务行（S-unit 建议档位必填+质量审查工具检测登记+候选对比表义务）
- 新建 scripts/selftest-reliability-institution.sh（R-01..R-12 静态断言，对齐 selftest-self-resolution.sh SR 范式）+ selftest-registry.tsv +1
- 条款 references/critical-rules.md（当前 413 行）：EOF 纯追加 Rule 42+43（grep '^42\.' =5、'^43\.' =4 口径你定稿时统一；格式同构 39/40/41）

【硬性计划要求】
- 配置表：template_type: rule-enhancement、code_review: required、interaction_mode: silent、isolation: worktree（/mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution，分支 wt/task-v099-reliability-institution，基线 master 当前 HEAD 请先 git rev-parse master 实测——v098 簿记提交后已前进）
- **B 类登记（用户 09-30 持久指令「完成修改之后记得部署到各个平台，然后提交到GitHub进行备份」沿用于本次交付）**：P4 含三位部署 + `git push origin master`（注册 Decisions Made，证据=用户原话引用于本任务说明段）
- VC ≥6 条（建议：42/43 子条 grep 计数/SKILL 锚+级联/模板行在位/plan-writer 契约行/新 selftest 过+全量 0 FAIL（基线 38 脚本 616/0）/合并部署+push/边界 22.3/28/39/40/41 原文零改动+零新 config 键）
- 每 Phase ≥2 V-N；Executor 字段齐（主进程仅 P1 基线+git 编排/P4 部署簿记，理由措辞含白名单关键词字面「①git 编排/②计划系统文件/③机械验证」——v097/v098 教训 25.4a 豁免正则）；派发型 Phase 附 S-unit 表（纯数字 ID/NNmin/≤2 文件 100 行 15min/输入 ≤2 路径/**每行标建议档位**——本计划即 43.2 首个示范）
- FMEA 覆盖（SKILL 级联锚断裂 RPN 高=既有 5 处 ≤558+skill-split 435 目标线+4 宽容正则锚锁字面 Rules 1-39；v097/v098 实证 RPN 前二风险）
- Phase 结构 5 段：P1 基线+worktree → P2 条款层（Rule 42+43 纯追加+SKILL 锚+级联）→ P3 模板+plan-writer 契约+selftest+registry → P4 合并回+三位部署+push+清理 → P5 CR Gate+终验簿记

【基线事实（本会话已实测，采信）】master 在 v098 簿记提交后前进（HEAD 待你 rev-parse 实测）；全量 selftest=38 脚本 616 PASS/0 FAIL；SKILL.md=435 行；critical-rules.md=413 行；「Rules 1-39」字面 2 处（SKILL :241/:295 区）；「1-40」零；check-complete 委派率=0.4 WHITELIST-EXEMPT 先例。

【输出】Write task_plan.md + knowledge-brief.md；完成前把结论写检查点 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/01-plan-writer.md。

【返回 8 字段模板（标签逐字）】status: / phase: / completed_steps: / files_written: / evidence: / issues: / next_step: / self_check:
