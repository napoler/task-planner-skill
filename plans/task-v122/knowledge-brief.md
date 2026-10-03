# Knowledge Brief — task-v122（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地 Rule 47 媒体制作任务派发纪律（媒体拆分轴+具名执行体路由+试点先行+零新键），三文件联动+新建 selftest，全量回归 0 FAIL 后部署 3 位。
- 背景/动机：用户反馈视频生成/图片生成/剧集创作任务在 task-planner 治理下子代理拆分粗、总落 general-purpose 默认代理。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 媒体族 | §九矩阵中 video/video-fix/image+工序 11 类共 14 个媒体制作 template_type |
| 媒体拆分轴 | 制作阶段（写词→生成→质检→处置→组装）× 生产单元（集/场/镜/张/音频条）的 S-unit 切分维度 |
| 工序 variant 模板 | templates/variant/ 下媒体工序专用计划模板（如 image-type/storyboard-type），派发时作为 SOP 随 prompt 下发 |
| 兜底路由 | 画像引用的项目专属资产缺位时的通用执行体映射（executor+模板 SOP+生成技能） |
| v121 预扩锚位 | commit 53936ec 把规则号锚扩为 1-4[5-9]，Rule 47-49 增加不再级联 |

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------|------|
| 画像矩阵含媒体 14 类，执行体列引用项目专属资产 | template-mapping.md:273-274,277-278（tools/gen.py·qc.py、script-writer/script-auditor） | 资产在通用环境缺位→路由落空，47.2 兜底注是正解 |
| ~/.zcode/agents/ 无视频/图片/剧集执行体 | explore #2 盘点（仅 article-* 12 个+写作类） | 候选 B（新建 agent 族）成本高，选 A |
| SKILL.md 路由表无媒体制作行 | SKILL.md §子代理路由表（:322-347 区） | S2 加 2 行 |
| Rule 21.1b 拆分轴纯代码导向 | critical-rules.md:141 | 47.1 媒体轴等效换算（预估时长主判据不变） |
| SKILL.md 行数上限断言 ≤558（3 处），现 444 行 | selftest-knowledge-brief.sh:38 / selftest-skill-collab.sh:82 / selftest-execution-stability.sh:72 | 净增 ≤10 行安全 |
| v121 预扩锚 1-4[5-9] | commit 53936ec（RT-08/PT-08/CD-12 宽容化） | Rule 47 零级联 |
| general-purpose=最后兜底非默认 | ~/.zcode/skills/skill-agent-router/SKILL.md:17-18 | 47.2 禁令的对齐依据 |
| 部署=smart-merge-back.sh --deploy 3 默认位 | scripts/smart-merge-back.sh:10-29 | Phase 5 直接复用 |
| 零新键断言范式 | scripts/selftest-reliability-institution.sh（43.4 同款） | S4 MD-08 照抄写法 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/references/critical-rules.md | :440-483 | Rule 43 尾注+44/45/46 规则块（新规则范式参照）；Rule 47 插入点=文末 46.5 之后 |
| skills/task-planner/SKILL.md | :281-305 | Critical Rules 摘要 bullet 区+references 表（S2 落点 :282 后/:305 行尾） |
| skills/task-planner/SKILL.md | :322-347 | 子代理路由表（S2 加行位置=「业务文档/配置/技能文件」行后） |
| skills/plan-template-kit/references/template-mapping.md | :258-297 | §九矩阵 30 行+不适用注（S3 兜底注插 :297 后） |
| skills/plan-template-kit/references/template-mapping.md | :303-312 | §十工具映射表（S3 特化行插 :306 后） |
| skills/task-planner/scripts/selftest-reliability-institution.sh | 全文 | S4 范式参照（t() 断言函数+零新键写法） |
| skills/task-planner/scripts/smart-merge-back.sh | :1-40 | 部署机制（--deploy 3 位对账） |

## §4 易错点与禁止假设清单
1. 禁改 §九矩阵既有 30 行与 §十既有行语义（Rule 36.4 需逐项确认）——只允许纯增量（兜底注+特化行）。
2. SKILL.md 净增 ≤10 行纪律（scope 表强制约束）+ wc -l ≤558 断言；禁碰行数上限断言本身。
3. S-unit ID 纯数字、预估时长 NNmin 格式、输入列 ≤2 文件路径（check-plan-dispatch.sh attest 机器校验）。
4. 改 SKILL.md 前先 grep 复扫既有锚断言（1-4[5-9]/Rules 1-）；新增内容致既有 selftest FAIL 时按 v121 宽容化先例判定锚过窄 vs 内容越界，禁改断言语义掩盖问题。
5. 单会话单 S-unit（Rule 46.1）；并行组 [S1,S2,S3] 各=独立 Agent 会话。
6. 禁触碰 plans/task-v116/.dispatch-inflight、task-v118/、task-v121/ 既有簿记残留。
7. 部署对账 diff≠0 即停，先读 smart-merge-back 输出（22.3.0 资料先行）。
- FMEA RPN>100 兜底指针：无（最高 96=Phase 3 回归未知 FAIL，兜底已入 task_plan FMEA 表）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1+§2+§3（critical-rules 行） | findings.md §Rule 47 条款草案全文 |
| S2 | §2（558 断言行）+§4.2/4.4 | findings.md §SKILL 联动草案 |
| S3 | §3（template-mapping 两行）+§4.1 | findings.md §mapping 联动草案 |
| S4 | §2（零新键范式行） | findings.md §selftest 断言清单 + scripts/selftest-reliability-institution.sh |
| S5 | §4.4 | progress.md 基线段 |
| S6/S7 | task_plan VC 表 | verification.md |
