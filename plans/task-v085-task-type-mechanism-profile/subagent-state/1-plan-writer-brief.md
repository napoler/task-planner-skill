# task-v085 S1 派发材料包 — plan-writer 撰写计划四文件

## 任务
为 task-v085（机制画像）撰写计划文档，写入四个文件（目录已存在）：
- task_plan.md（通用模板整体重写）
- findings.md（重写为初版）
- progress.md（重写为初版骨架）
- knowledge-brief.md（重写为五段初版）
verification.md 与 notepad-learnings.md 不动。
每完成一个文件，立即将「文件名+行数+要点」追加写入同目录 1-plan-writer.md（检查点）。

## 任务背景（用户原话）
「优化我的该技能（task-planner） 我希望可以区分任务 不是所有的任务都需要使用 比如 @Code Reviewer 在文章撰写任务完全不需要 这种skill的使用」
→ 让 task-planner 按 template_type 裁剪机制适用性：非代码任务不适用 Code Review Gate / code-assistant 路由，按类型给出「机制画像」。

## 已验证事实（findings.md 必录，标注来源=Explore 子代理一手调研 2026-09-20）
1. 缺口：writing/research/publish 三个内容类 variant 模板已干净（Executor 只指向 article-writer 等），但 SKILL.md §子代理路由表（L354 起）无类型适配注记；通用 templates/task_plan.md（416 行）L16-24 Code Review 配置节 n/a/required 二态无判定逻辑、L180 Executor 示例 code-assistant（代码向）——非代码任务被通用模板引向代码机制。
2. 先例：config.json 已有 content_quality_enforce（L71-80）按 writing/research/publish 分档——机制按 template_type 分档有先例可仿；config.json 为 JSON Schema 形态、additionalProperties:false、当前 38 顶级键。
3. check-template-type.sh 白名单=variant/ 动态派生+general（L15-17），新增章节不破坏 gate；attest-plan.sh 已集成该 gate。
4. selftest-template-lifecycle.sh（17 断言 TL-01..17）守护 template-mapping.md 与 template-guide.md（TL-17 断言「13 个」计数）；template-mapping.md 现 198 行、8 章节、§六互斥表 L145-154、§七定制红线。
5. SKILL.md 现 545 行；无行数硬断言但有 TL-14/15 等 grep 断言（C22 行、「模板选取门控与沉淀」段必须保留）。
6. Rule 32 禁令源核查：plans/task-v083-batch-pilot-first/notepad-learnings.md 两条 veto（无试点批量/速度理由压缩验证），与本任务方案无冲突。
7. 本任务改 .sh（check-complete.sh+新 selftest），按 rule-enhancement-type 模板 code_review: required 自律适用。

## 方案设计（写入 findings.md Technical Decisions）
「机制画像（mechanism profile）」方案：
- A. critical-rules.md 末尾新增 Rule 37 任务类型机制画像（≤70 行纯追加）：37.1 画像表权威源=template-mapping.md §九（Rule 37 只放指针+判定规则）；37.2 判定时点=计划创建期选定 template_type 后立即套用；37.3 三类机制组（代码组=Code Review Gate+code-assistant 路由+修改后验证流程；内容组=content_quality 门控+article-writer 路由；通用组=全部守卫不变）；37.4 消费侧（Phase 步骤 2.5 委派检查点先查画像再定执行体；Code Review Gate 仅当 template_type∈代码组或计划显式 code_review: required）；37.5 机制（config 新键 mechanism_profile_enforce 默认 warn+selftest）。明示「仅裁剪类型组机制，3-File/委派率/漂移检测等通用守卫全类型不变」。
- B. template-mapping.md 新增 §九 机制适用性矩阵（≤60 行）：14 行（13 variant+general）×列（类型/默认适用机制/不适用机制/执行体路由组）；写作/调研/发布行明确「不适用：Code Review Gate、code-assistant/debugger/code-reviewer 路由」；§一决策树尾加一行指针注记。
- C. SKILL.md 三处纯增量（≤10 行）：①路由表头部加类型适配注记行指向 Rule 37+§九 ②合规检查清单加 C25 行 ③Critical Rules 列表加 Rule 37 一行。
- D. 通用 templates/task_plan.md 三处微调（≤8 行）：Code Review 配置节加自动判定句「默认按 template_type 机制画像判定，代码组外默认 n/a」；Executor 示例加注「按机制画像选执行体，非代码任务见 template-mapping §九」。
- E. check-complete.sh 增画像抽查段（≤15 行）：终验读计划 template_type，∈writing/research/publish 且计划 code_review: required → warn 提示不改 exit（enforce 档 exit 1）。
- F. selftest-mechanism-profile.sh 新建（12-15 断言，含行为级：fake plan template_type=writing+code_review: required，warn 档 exit 0、enforce 档 exit 1）+ selftest-template-lifecycle.sh 追加 TL-18（template-mapping.md 含机制适用性矩阵节）。
- G. config.json 新增 mechanism_profile_enforce（enum warn/enforce/off 默认 warn，位置仿 template_gate_enforce 相邻）。
- 备选方案（否决）：每机制加 per-type 开关键×N——config 键爆炸、新机制必改 config；映射层一次收口，故选映射。

## task_plan.md 硬性要求
- 配置表：`| template_type | rule-enhancement |`、code_review: required、interaction_mode=ask、reflect_verify: required、isolation=worktree、git_commit 默认逐 Phase 提交
- 隔离决策区块：worktree（分支 wt/task-v085-task-type-mechanism-profile，路径 /home/terry/task-planner-skill-worktrees/task-v085-task-type-mechanism-profile 集中目录）；计划文档留主仓 plans/
- 核心问题定义段：问题=机制对全任务类型无差别套用→文章类任务被引向代码审查机制（误路由+浪费）；本质=机制适用性与任务类型无映射层；方案=机制画像映射（映射而非删除机制）
- 4 个 Phase，每 Phase 含：目标、S-unit 表（ID 纯数字、内容、Executor、验收三字段）、`- **Status:** pending` 独立行（只在 Phase 块内）、checkbox 清单：
  - Phase 1 规则与主文件层：1=critical-rules.md Rule 37 新增（Executor: code-assistant, haiku-1）；2=SKILL.md 三处纯增量（Executor: code-assistant, haiku-1）
  - Phase 2 模板与映射层：3=template-mapping.md §九+§一注记（Executor: code-assistant）；4=通用 task_plan.md 微调（Executor: code-assistant）；5=template-guide.md 计数联动核对（Executor: code-assistant）
  - Phase 3 脚本与守卫层：6=config.json 新键（Executor: json-edit-agent）；7=check-complete.sh 画像抽查段（Executor: code-assistant）；8=新 selftest+TL-18（Executor: code-assistant）
  - Phase 4 验证与交付层：9=关键文件 Read 复验+可靠性自查（Executor: verifier）；10=全量 selftest+主进程逐 Total 行求和（Executor: code-runner-agent）；11=Code Review Gate+终验+smart-merge-back --deploy+簿记（Executor: 主进程——白名单①③⑥理由登记）
- S-unit 合规：每 S-unit ≤2 文件 ≤100 行 ≤15min；执行期逐 S-unit 派发（禁打包）
- Handoff 登记表预填 11 行（seq/agent_type/目标/状态 pending/checkpoint 列=<plan-dir>/subagent-state/{seq}-{agent_type}.md）
- Decisions Made：调研来源（Explore 一手调研 2026-09-20）+方案对比（映射层 vs per-type 键×N）
- FMEA ≥3 项：R1=路由表注记被误读为「非代码豁免全部守卫」→兜底=注记明示「仅裁剪代码组机制，通用守卫不变」；R2=TL-17「13 个」计数断言 FAIL→兜底=只同步计数不改结构；R3=check-complete 新段破坏 exit 语义→兜底=warn 档不改 exit+enforce 行为断言
- 「📚 必要知识储备」段：Rule 25-26/34、template-mapping.md、content_quality_enforce 先例——本地可获取（已验证）

## knowledge-brief.md 五段
速览（一句话）/已验证事实（摘 4-5 条最关键）/文件锚点（SKILL.md L354 路由表、task_plan.md L16-24、template-mapping.md L145、config.json L71-80、check-template-type.sh L15-17、selftest TL-01..17）/易错点（TL-17 计数断言、check-complete exit 语义、additionalProperties:false、S-unit ID 纯数字、Phase 状态行只许 Phase 块内）/S-unit 材料包索引（各 S-unit 对应锚点）

## 其他硬约束
- S-unit ID 纯数字（attest 拒锁字母后缀命名）；禁假 Status 行/契约标记散落正文；禁止虚构行号
- 禁止改动 verification.md / notepad-learnings.md
