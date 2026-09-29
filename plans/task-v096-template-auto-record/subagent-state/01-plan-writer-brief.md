# task-v096-template-auto-record 计划撰写简报（供 Plan Writer 消费）

## 1. 任务背景与目标
- 用户指令（2026-09-29）：引入自动模板记录——遇到新类型任务时主动创建该类计划任务模板，供后期重复任务快速复用；且要求**遇到任务时点主动激活**
- 用户 D1 裁决（2026-09-29，AskUserQuestion 两问）：①激活策略=**三时点感知网**（init-session 机器提示+计划区块预登记 / check-complete 终验 warn 兜底 / Rule 34 计划期 LLM 行为；不碰 UserPromptSubmit hook——v091 实证 hook 税是最大慢源）②创建自动化=**全自动静默生成**（不问用户，生成动作全自动；34.5 防滥用闸门由生成执行体内置执行：ls variant 查重+泛化性评估，不足→登记不沉淀理由而非硬生成）
- 现状缺口（已侦察）：34.3 沉淀触发仅在终验且纯人工判定（C22「沉淀判定人工」无机器激活点）；init-session 类型空缺时静默落 general 无任何提示；v095 后模板 knowledge 层在 plan-template-kit 卫星（四点同步拓扑已变：template-mapping/guide 在卫星 references/，SKILL 模板节在主技能已指针化）
- 必读输入：本简报 + plans/task-v096-template-auto-record/ 下 init 已生成的 6 文件 + 侦察事实见 §3

## 2. 设计（已裁决，冻结）
### 2.1 三时点激活网
- **T1 计划创建期（init-session.sh，机器激活点）**：TEMPLATE_TYPE 为空落 general（类型空缺信号）或显式给了未知类型时：emit `[template-sense]` 提示行 + 向生成的 task_plan.md 末尾追加「🔁 模板感知」区块（含：触发信号、34.3② 预登记、终验必查标注、四点同步指针）。运行时追加，不改 templates/task_plan.md 模板文件本体（它有大量锚）。已知类型路由不触发（零噪音）
- **T2 计划期 LLM 行为**：critical-rules 纯追加 **34.7 模板感知（template-sense）** 子条：三时点定义+全自动生成条款+34.5 闸门内置于生成侧+计数级联要求；SKILL.md 三处联动（Rule 34 摘要行行内补「感知」语义——摘要行是 selftest 锚只能行内改关键词保全、初始化流程步骤加指针行、C22 行内改「沉淀判定人工」→「终验全自动生成（34.7）+登记」，净增 ≤3 行）
- **T3 终验期**：check-complete.sh 增 warn 抽查段（≤15 行）：plan 含「🔁 模板感知」区块且终验未登记沉淀/不沉淀理由 → warn 提醒（不阻断，对齐既有 warn 档风格）。终验主进程按 34.7 直接派执行体全自动生成（不 AskUserQuestion）
### 2.2 全自动生成合约（34.7 核心语义）
触发=终验时命中 34.3 任一条件且 outcome=COMPLETE → 主进程直接派执行体（plan-writer 或 code-assistant）生成 `templates/variant/<new-type>-type.md`（≤100 行，含 Goal/VC/Phase 骨架/执行范围/知识储备最小结构，对齐既有变体质量）→ 生成侧强制执行 34.5 闸门：ls variant 查重 + 泛化性评估（一次性/不可泛化 → 登记不沉淀理由收场）→ 34.2 四点同步（拓扑注意：template-mapping/template-guide 在 plan-template-kit/references/，SKILL 模板节指针在主技能，plan-writer 映射表在 companion）→ **计数级联**：template-guide「N 个」计数 +1 且 selftest-template-lifecycle TL-17 断言计数同步改（v093 教训：同源锚必须同改）→ selftest 全绿 → 沉淀登记 Decisions Made
### 2.3 硬约束
- 零新 config 键（warn 语义，无门控键）；Rule 1-39 编号冻结（34.7 纯追加）；templates/task_plan.md 模板本体零改动（运行时追加）；hook 接线零改动；UserPromptSubmit 不碰（hook 税）
- init-session.sh 是 v095 留守机械层——本任务用户显式要求的功能增量，Rule 36.2 归因成立（用户点名），修改合法；改后 bash -n + selftest-plan-tier/init-session 相关 selftest 必须全绿
- C22 行/Rule 34 摘要行是 grep 锚——行内改时关键词「template_type 已过 check-template-type.sh 门控」「Rule 34（P0）模板生命周期门控与沉淀」等既有子串保全
- 全部改动 worktree 隔离（保护区文件），逐 Phase 提交，合并回后 install.sh 全量部署三实体位+diff -r 复验
- 计划创建期侦察责任：每个改点 S-unit 前先 grep 消费方 selftest 断言（v095 Error Log Prevention——内容型锚必漏，清单只作导航）

## 3. 侦察事实（已实测）
- 34.3 现行：critical-rules.md L315「沉淀触发（终验时判定）」三条件；34.4 L316 提炼流程；34.5 防滥用；34.6 机制 template_gate_enforce
- init-session.sh L149-165：TEMPLATE_TYPE 空时 project default 文件 > env TASK_TEMPLATE_DEFAULT > 缺省 general（逐字节不变行为）；未知类型 L184 WARNING
- check-template-type.sh：白名单=general+ls variant/*-type.md 动态派生（新 variant 自动纳入，无需改）
- zcode-userpromptsubmit.sh：[plan-note] 注入点 L182（本任务不碰）
- C22 现行：SKILL.md L186「…命中 34.3 沉淀触发时已按 34.4 沉淀或登记不沉淀理由（沉淀判定人工）」
- plan-template-kit SKILL.md 34 行已含沉淀指针节（Rule 34.3→34.2 四点同步）

## 4. Phase 骨架（8 Phase，S-unit 按 22.6 细化 ≤2 文件/≤100 行/≤15min）
- P1 基线与隔离区（主进程白名单①③）：全量 selftest 基线实测记录（上一任务终态 35 脚本 584/0 为预期基线，以实测为准）+worktree add wt/task-v096-template-auto-record +迁移/改动点消费方断言清点
- P2 T1 init-session 感知块（executor）：general fallback 与 unknown 两分支 emit+追加区块；自验含「已知类型不触发」负例
- P3 条款层（executor）：critical-rules 34.7 纯追加+SKILL.md 三处联动（摘要行行内/C22 行内/流程指针行）
- P4 T3 终验层（executor）：check-complete warn 段
- P5 卫星联动（executor）：plan-template-kit SKILL.md 沉淀节补全自动合约+计数级联清单
- P6 selftest-template-sense 新建+registry（executor）：断言含 T1 正例/负例/34.7 锚/C22 新文案/check-complete warn 触发
- P7 全量验证+合并+部署（executor S1/S2+主进程 S3/S4 白名单①③）
- P8 CR Gate+终验簿记（code-reviewer+主进程白名单⑤②）

## 5. VC 草案（不可减，可润色）
- V1 init-session：general fallback 与 unknown 类型两分支均 emit [template-sense] 并在生成的 task_plan.md 产出「🔁 模板感知」区块；已知类型（如 bugfix）零触发（负例）
- V2 critical-rules 含 34.7 三时点+全自动合约+34.5 闸门条款（纯追加，Rule 编号完整性 170→171 类断言通过）；SKILL.md C22 行含「全自动」新语义且旧锚子串保全
- V3 check-complete：含感知区块未登记的计划 → warn 输出含 template-sense 字样；正常计划零误报
- V4 plan-template-kit SKILL.md 沉淀节含全自动合约+计数级联清单（TL-17 同步要求在列）
- V5 全量 selftest 0 FAIL 且 ≥ 基线实测值；新 selftest-template-sense 全绿并登记 registry
- V6 CR APPROVED + 三部署位部署 diff -r 一致

## 6. FMEA 候选（≥5）
- init-session 追加区块破坏下游解析（check-scope/check-3file-gate/check-template-type 读 task_plan.md）→ 追加前 grep 下游解析锚+两分支实测+selftest 兜底
- 全自动生成误沉淀一次性任务（34.5 失守）→ 生成侧双闸门（查重+泛化评估强制登记理由）+终验 CR 抽查沉淀质量
- 计数级联遗漏（新 variant 后 TL-17「16 个」断言 FAIL）→ 34.7 条款+卫星 SOP 把计数级联列为生成合约必做步+新 selftest 断言计数一致性
- C22/Rule 34 摘要行锚断裂 → 行内改关键词保全+改前快照差集对账
- check-complete 新 warn 段误报正常计划 → 区块存在性判定精确（grep「🔁 模板感知」）+正常计划负例断言

## 7. 格式与契约
- template_type: rule-enhancement（init 已写入）；plan_tier: standard；interaction_mode: ask；code_review: required；git_commit 逐 Phase（worktree 内）
- 隔离决策：worktree /mnt/data/dev/task-planner-skill-worktrees/task-v096-template-auto-record；上任务 v095 已交付合并（aa092cc..de8e8fe 已 push），无并行冲突面
- Decisions Made 必含：D1 两裁决（三时点网/全自动生成+34.5 闸门内置）、D 类判定、思路复述待呈示行、Handoff 表 subagent_type 列**纯 token**（executor/code-reviewer/code-assistant——v095 教训）
- 派发型 Phase 的 S-unit 表含检查点路径列；派发 prompt 材料包引用 knowledge-brief § 节锚（守卫要求）
- 知识储备登记：本简报+侦察事实+critical-rules Rule 34 现行段

## 8. 返回契约（8 字段严格格式）
status / 产出文件（task_plan.md+knowledge-brief.md 绝对路径+行数）/ 关键结论（Phase/S-unit/VC 计数）/ 证据 / 未完成项 / 失败与原因 / checkpoint（subagent-state/02-plan-writer.md）/ 下一步 / 风险提示
