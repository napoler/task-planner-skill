# 02 General Analyst — 只读定位分析检查点

- 开始时间: 2026-11-24 05:22:08 CST
- 结束时间: 2026-11-24 05:25:04 CST
- 角色: general-analyst（只读；唯一写入=本检查点文件）
- 排除表: RETRIEVAL_EXCLUDE.md 仅 trash/（本次未触及）；范围=skills/ 源码 + 指定计划视图
- status: PASS（5 问全部取证；Q1 二阶段模式 / Q4 rule-enhancement 根因 Phase 标题为 NONE FOUND）
- acceptance: 每项 file:line + ≤3 行原文摘录；正文 ≤110 行；八字段返回；未见证据均标 NONE FOUND + grep 关键词

## Q1 split-pattern-library.md 拆分模式
文件: skills/task-dispatch/references/split-pattern-library.md
- P1 :22 任务边界三判据(Right-Sizing) — 独立可验收/可理解/接口清晰
- P2 :30 Bite-Sized 步级粒度(2-5min) — S-unit 内部原子步骤
- P3 :38 子系统拆分法 — 按子系统边界而非技术层拆
- P4 :46 任务书 No-Placeholder 与双明确 — 禁占位符，目标/方案/验收双明确
- P5 :54 独立性判定法(拆分期域划分) — 按根因/问题域分组，域内独立域间并行
- P6 :62 派发 Prompt 四要素 — Focused/Self-contained/Specific output/Constraints
- P7 :70 嵌套≤2 层与超时档位 — 子代理深度与每层超时硬限
- P8 :78 简单任务禁 spawn(L0) — 单步≤60s 主进程直做
- P9 :86 Spec 自审四查(挂 21.5) — 占位/一致/范围/歧义四查
- P10 :94 拆细先于升档(索引条目) — 失败先拆细再换强模型
- P11 :102 术语语义锚定与理解复述 — 领域名词需语义解释+溯源锚
- P12 :110 依赖分批并行(fan-out→join→串行链) — 拓扑分批，批内并行批间串行
二阶段模式: NONE FOUND。grep 关键词: 先修/根治/后续/早合并/两阶段/阶段二/worktree/followup/热修/hotfix/并行.*合并。
唯一近邻 :56「多任务按根因/问题域分组，每个域内任务独立（无共享状态、无顺序依赖），域间可并行」——仅静态域划分，无「阶段一快修早合并→阶段二新 worktree 根治」时序语义。

## Q2 planctl/plan-state schema
schema: skills/task-planner/schemas/plan-state.schema.json（required 顶层 :7-20）；权威写入: scripts/planctl.py
顶层 required(:7-20)=schema_version/task_id/plan_tier/execution_lane/created_at/updated_at/requirements/goals/vcs/phases/findings/audits/delegations/tags
顶层 optional(schema :46-80；planctl.py :71-83)=actions/files/test_results/errors/.../root_causes/.../chain/isolation/outcome/template_type/template_body/next_step 等
section 名=planctl.py ARRAY_SECTIONS :51-62（7 基础 + 29 语义段，共 36）
不新增 schema 字段记录「阶段二=阶段一根因后续」最小手段（按推荐度）:
① tags（schema :37 + tag_list :84-87；planctl.py :1055 tag-add/:2033）— 对 findings 或 root_causes 条目打 tag，如 `followup-of:<阶段一task_id>`；每条 tag_list 是 string[]、uniqueItems，tag-add 同步 .tags-index.json 倒排索引，跨计划可 tag-search O(1) 反查。零新字段，最贴合「后续任务登记」。
② root_causes 段（schema :53 / root_cause_item :361-372，字段 id/process/defect/fix/vc）— 阶段二先落根因线索条目，fix 写后续处置方向。
③ chain 对象（schema :76 / chain :646-655，字段 mode/blocks/handoffs，additionalProperties:false）— handoffs 字符串登记阶段交接。
④ execution_lane(schema :27 枚举 L0/L0-T/L0-E/L1/L2) / template_type(schema :50 自由字符串) — 仅表执行通道与模板，不表达来源关系，作辅助。
字段 origin/followup/parent: NONE FOUND（schema 全文无此三类键）；别名归一 FIELD_ALIASES 见 planctl.py :144-153（不含来源字段）。

## Q3 worktree 合并回权威步骤
docs: skills/task-planner/references/worktree-isolation.md；脚本: scripts/smart-merge-back.sh
最小命令集(worktree-isolation.md :50-84):
①-备份 :51-55 `git stash push -u -m pre-wt-backup:<task-id> -- . ':(exclude)plans' ':(exclude)tmp'`
①创建 :57-58 `git worktree add <ROOT>/tmp/worktrees/<task-id> -b wt/<task-id> main`（注意 :61-62 本仓 main 陈旧无关，实际改 master）
①-校验 :60-64 基线分支=当前主工作分支 + 关键规则文件行数/锚一致
②开发 :66-67 全用 worktree 绝对路径；③提交 :69-75 每 Phase/S-unit commit，禁 add -A
④合并 :77-78 `git merge --no-ff wt/<task-id> -m "merge: <task-id> <goal>"`
⑤清理 :80-81 `git worktree remove ... && git branch -d wt/<task-id>`
⑥复验 :83 Read 关键文件 + merge_back=merged(<commit>)
合约(:90-101) 5 条: 全 Phase complete+VC 复验 / worktree 干净 / 主仓无 scope 重叠未提交 / merge 后 Read+git log 复验 / 清理+merge_back 更新
机制化入口(:92) `bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]`；USAGE smart-merge-back.sh:114
脚本检查序列(:42-48): V1 双校验(exit2)/V2 干净(3)/V3 scope 重叠(4)/V4 ALREADY_MERGED(0)/V5 MASTER_AHEAD(5)/V6 --no-ff 合并(冲突 7)；退出码表 :92-102
「合并后再开第二个 worktree 承载后续根治任务」: NONE FOUND。grep 关键词: 后续/第二个 worktree/再开/followup/根治/阶段二/独立任务。
近邻(非同义): §4.6 :133-138 `git worktree add .../tmp/worktrees/<task-id>-rN -b wt/<task-id>-rN <baseline-commit>` = 方向错误弃旧开新(restart)，不是已合并后新开根治任务；§6.4 :189-193 同写冲突补救性隔离也非此语义。

## Q4 variant 模板 + Rule 34.2 + 根因 Phase
模板目录 skills/task-planner/templates/variant/ 共 32 个 *-type.md（用途见各文件 :2 template_meta.summary）:
audio-voice 声音工序/TTS 声线核对; bugfix bug修复+根因定位; character-design 角色资产工序; code-edit 单/多文件代码编辑; deployment 部署/CI/CD/基础设施; diagnostic 诊断/skill审计/bug排查; final-assembly 成片工序; image Agnes图像链路; l0-lite 极简豁免档; longform-continuity 长文连载; memory-hygiene 记忆治理; migration 语言/框架/CLI迁移; mini-lite 轻量任务; motion-camera 镜头运动写词; multiview-ref 定稿派生补制; performance-tuning 性能瓶颈; physics-compliance 合规判定审查; prompt-struct 写词层工序; publish 发布/批量部署; qc-defect 质检工序; refactor 行为不变重构; research 调研/SERP/竞品; rule-enhancement 规则/条款增强; schema-migration DB schema变更; script-dev 剧本工序; storyboard 分镜工序; test-writing 测试编写; video Agnes视频链路; video-fix video四级修正; video-prompt 图→视频写词; video 视频生产; writing 单篇/SEO写作
Rule 34.2 四点同步（原文写「四点」，用户问题称「三点」——以原文为准）锚: skills/plan-template-kit/references/critical-rules-template.md:16
四个落点: ①template-mapping.md 决策树与清单 ②companion/agents/plan-writer.md 映射表 ③SKILL.md 模板节 ④template-guide.md 变体表与计数（四文件均在仓内存在；init-session.sh 白名单动态派生免同步；selftest-template-lifecycle.sh TL-03 :67 守护四点）
相关：34.4 :18 沉淀流程含「完成 34.2 四点登记」；34.7 :21 终验全自动沉淀也按 34.2 同步
根因 Phase 标题原文:
- bugfix-type.md:85 `### Phase 2: 根因定位`（:86-89 调 systematic-debugging 5 步+证据链+findings 根因节）
- rule-enhancement-type.md: NONE FOUND。grep 关键词: 根因/root.?cause；该文件 5 个 Phase 标题见 :53/:58/:66/:71/:76（隔离基线/条款config门控/selftest/联动回归/合并部署），无根因 Phase。

## Q5 check-complete 门序 + check-3file-gate 条件
文件: skills/task-planner/scripts/check-complete.sh（门序按行号，均为 bash/python 终验段）
1 :27/:101 check_scope_porcelain 预检（执行范围未提交变更）
2 :127/:136 STATE-CONSISTENCY GATE（check-state-consistency.sh 三源一致）
3 :343 Batch Report gate（Rule 18.6，python 段）
4 :351 3-File Gate（findings/progress 存在且非 stub，python 段）
5 :450 DELEGATION GATE（check-delegation.sh stats）
6 :528 DRIFT-GATE（纠偏执行率，默认 warn）
7 :599/:603 PLAN-DISPATCH GATE（check-plan-dispatch.sh）
8 :607/:625 FMEA GATE（config fmea_enforce）
9 :699/:704 RESCUE-CHAIN GATE（check-rescue-chain.sh）
10 :735/:769 EVIDENCE-ANCHOR GATE（check-evidence-anchor.sh，--source=coverage/goal）
11 :813/:818 VC-NONVACUOUS（check-vc-nonvacuous.sh）
12 :857/:862 RVC-COVERAGE（check-rvc-coverage.sh）
13 :899 VC-GATE（VC 表+每 Phase V-N 映射）
14 :1059 R-COVERAGE GATE（delivery-summary 需求覆盖）
15 :1265 report-lint（delivery-summary 轻量 lint）
16 :1358 SESSION-LOG GATE（user-session-log 专档）
17 :1443 CR-GATE（CR 风险信号触发）
18 :1486 LEARNING-GATE（Error Log Root Cause 非占位）
19 :1594 REFLECT-GATE（reflect_verify required 时 ≥2 [reflect] 行）
20 :1637 SKILL-MODIFY GATE（删除性行为清单）
21 :1673 ALIGN-ANCHOR GATE（对齐四处锚）
22 :1715 mechanism-profile（template_type 画像抽查）
23 :1750 COMPLIANCE-CHECK（抽查 warn）
24 :1837 goal-gate（66.5，EVIDENCE-ANCHOR --source=goal）
25 :1949 LANE-L0 GATE（L0 专属三段）
26 :2008 judge-gate（Rule 73.4）
27 :2054 ARCHIVE-GATE（终验后未归档提醒）
门怎么读 plan-state 字段: 门主体读渲染后的 MD 派生视图（check-complete.sh:176 open(task_plan.md)；:5 读同目录 findings/progress），planctl.py VIEW_NAMES :49 从 plan-state.json render 4 视图；档位/字段直读仅 jq config.json（如 :722 vc_gate_enforce）+ 少量双读 JSON（check-vc-nonvacuous.sh:71 存在 plan-state.json 时转 planctl.py check）。即「JSON 为权威、门消费 MD 视图」。
最适合承载「根因线索包已落盘+后续任务已登记」消费检查: EVIDENCE-ANCHOR GATE(:735-769) — 它已按 --source 做证据锚真实性三层检查并可扩 source 类型；次选 LEARNING-GATE(:1486，已有 Root Cause 列校验)只覆盖根因不覆盖后续登记；新建专用门需改 check-complete 门序与 selftest 哈希锚（成本高）。
check-3file-gate.sh 当前条件: 7 条（头注 :8-24）——①findings/progress 缺失 ②无 in_progress Phase ③Started 锚点/stale 阈值 ④两文件 mtime 晚于锚 ⑤--require-kb 知识增量 ⑥:287 P-06 纯中文 Goal CJK 分词 ⑦:329 Rule 64.2 drift 痕迹；另 :368 STATE-CONSISTENCY shell-out 附加。

## 未决/存疑（交主进程决策）
- 用户裁决「两段式修复」目前无现成拆分模式/模板/门承载，落地需选：复用 tags+root_causes 记录（零 schema 变更）or 新增门/登记载体（越权，需用户授权）。
- 本仓 main 陈旧无关历史，所有 worktree 命令的基线分支应为 master（worktree-isolation.md:61-62）。
- Rule 34.2 原文为「四点同步」，用户问题写「三点」——按原文四点执行；若用户坚持三点需澄清删哪一点。
