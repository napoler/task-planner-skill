# Knowledge Brief — task-v124（任务知识简略要点）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：新增 image/video-generation-executor 两个 companion 专业执行体 + Rule 47.2 联动行内替换 + 文档同步 + selftest-media-agents 守护，合并回并部署双位（用户指令：媒体任务专业化处理）。
- 背景/动机：task-v122 Rule 47 已建具名路由「executor+工序模板 SOP」，用户要求补专用执行体（v122 D2 候选 B 转正）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| companion agents | 本仓随行 agent 池（skills/task-planner/companion/agents/），install-companion.sh 分发到 ~/.zcode/agents 与 ~/.claude/agents |
| 双位 | ~/.zcode/agents/（model 原样）+ ~/.claude/agents/（model 经 adapt_model_line 转纯档名） |
| 行内替换 | 不增删行、只改行内文字 → 行数锚零级联（v122 教训） |
| 试水门 / G1 放行门 | image：批次首件过三检才扩批；video：任何 video 调用前必须有草稿放行登记 |
| MA-01..10 | 新守护断言编号（沿用 v122 MD-* 范式，前缀换 MA 防碰撞） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| 新增 companion agent 零机制改动（glob 自动分发） | lib/install-companion.sh:163；install.sh:178-188 | S1/S2 纯落盘即可被分发 |
| Claude 位 model 适配仅认 `custom:<uuid>:<slug>` | install-companion.sh:52-90；complex-planner `account:` 落 default 分支（v119 手工 sed 先例） | D2 选 A 使双位自动适配 |
| 全仓 selftest 无 agent 清单断言 | research-a 第 3 条（6 脚本仅锚 plan-writer.md） | 新增 agent 断言面=零 |
| 文档 stale 3 处（漏 complex-planner） | README_zh.md:114 / INSTALL_zh.md:306-308 / install.sh:179 / INSTALL.md:137-139 | S4/S5 一并修正 |
| smart-merge-back --deploy 不含 ~/.zcode/agents 槽 | smart-merge-back.sh:377-381 | agents 用户目录须 install-companion 或定向 cp 分发 |
| v119 部署先例：主进程 cp 2 位 + skill-agent-router 加 1 行 | plans/task-v119/progress.md:81；skill-agent-router/SKILL.md:98 | Phase 5 照做（仓外用户授权面） |
| agnes 调用面与硬约束 | agnes-ai-generation-skill/SKILL.md:36-131（video :112） | agent 技能段依据；video 参数域校验 |
| 工序门控纪律 | image-type.md:21-26（三检/试水/预算）；video-type.md:35（G1）；qc-defect-type.md:37,55-57 | agent Workflow/禁止行为依据 |
| 骨架范式（域执行体） | ~/.zcode/agents/article-writer.md:1-15 + article-batch-publisher.md | agent 正文六节结构 |
| registry T02 硬门：新增 selftest 必须登记 | selftest-registry.sh T02；SR-12 动态口径 | S6 双文件（脚本+tsv） |
| SKILL.md 现 447 行（skill-split 锁 ≤447） | selftest-skill-split.sh:41（v122 演进） | 行内替换净增 0 → 锚不受影响；禁增行 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/SKILL.md | :356-357 | 媒体两行（媒体生成工序/剧集创作管线）——S3 行内替换目标 |
| skills/plan-template-kit/references/template-mapping.md | :298, :308 | §九兜底注 / §十媒体制作族行——S3 目标 |
| skills/task-planner/companion/agents/complex-planner.md | 全文 | 最近 companion 先例（48 行，frontmatter 四要素） |
| ~/.zcode/agents/article-writer.md | :1-40 | 域执行体正文六节范式 |
| skills/task-planner/lib/install-companion.sh | :52-90, :163 | adapt 映射 / glob 分发 |
| skills/task-planner/scripts/selftest-registry.tsv | 末行 | 45 行目标（+1 登记） |
| ~/.zcode/skills/skill-agent-router/SKILL.md | :98 区 | 路由表（complex-planner 行）——Phase 5 加 2 行 |

## §4 易错点与禁止假设清单
1. 禁改既有 4 companion agent / config.json / 其他 selftest（纯增量，Rule 36.5）；SKILL/mapping 禁增删行（行内替换，净增 0）。
2. 行内替换前先 grep 核原文（不依赖行号——v123 可能先合并改行号）；锚不匹配 → BLOCKED 上报，禁猜测。
3. dispatch-guard 纪律：prompt 内禁多个 S-ID 字面量（组声明只写组名）、禁圈码枚举 >4；[readonly-parallel] 标记只读并行组。
4. S-unit ID 纯数字；时长 NNmin；输入列 ≤2 目标路径（findings 材料包为第 3 路径=advisory 已接受）。
5. video agent 的 G1 放行门=硬约束：缺放行登记=HARD_BLOCK，禁自行放行（隔离铁律 A/B 侧分体）。
6. 部署面（~/.zcode/agents 等）改动前先展示 diff；先 find 全部 skill-agent-router 存在位；备份语义（.backup-<date>）先核。
7. 禁触碰 task-v123 他会话 worktree/plans/目录。
- FMEA RPN>100 兜底指针：无（最高 40=provider 拒单，兜底=22.3① 改派 executor）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §2（骨架行）+§4.1 | findings.md §agent 草案 1 |
| S2 | §2（agnes/G1 行）+§4.5 | findings.md §agent 草案 2 |
| S3 | §3（SKILL/mapping 行）+§4.2 | findings.md §联动草案 1/2 |
| S4 | §2（stale 行） | findings.md §联动草案 3 |
| S5 | §2（stale 行） | findings.md §联动草案 3 |
| S6 | §2（registry 行）+§4.3 | findings.md §selftest 清单 + scripts/selftest-reliability-institution.sh |
| S7/S8 | §4.2 | progress.md 基线段 |
| S9/S10 | task_plan VC 表 | verification.md |
| S11 | §4.1 | selftest-media-agents.sh |
