# Knowledge Brief — task-drift-fakeqc-20261115（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-drift-fakeqc-20261115/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-drift-fakeqc-20261115/knowledge-brief.md 后即按 §1-§5 填写；
     计划期填 §1/§4/§5 骨架，§2/§3 执行期每个 S-unit 完成后持续回填（新事实/新锚点当日入账）。
  ② 为何设计成五段: 子代理 prompt 只能带「路径 + 摘要」（Rule 22.4 §9 上下文预算），
     五段=小模型可消费的知识最小集——§1 对齐术语、§2 只放已验证事实（带证据锚点，
     未验证推测禁入=防把假设当事实注入）、§3 定位文件（禁凭记忆改文件）、§4 提前
     排雷（历史教训+FMEA 兜底指针）、§5 把「S-unit → 该读哪节」互链到 S-unit 表。
  ③ 为何独立于三文件: 知识维与决策维(findings)/进度维(progress)/目标维(task_plan)
     分账存放——执行期重读任务时只读本文件即可恢复知识底座，不翻全会话/全 findings。 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

<!-- 填写说明：一句话说明本任务做什么 + 为什么做（≤2 行）；下方术语表每条 ≤1 行，只收录「不解释会读不懂后续 S-unit 材料包」的术语 -->
## §1 任务速览与核心概念
- 任务一句话：根治 skill 执行两缺陷（范围静默扩张+完成声称措辞升格），以 94.7/51.14/64.7 三条款增款落地+三部署位同步为可验证完成。
- 背景/动机：判例 sess_a7eb0603——trash 全集审计 2306 篇偏移+224 篇 5min 机械扫描包装"审核完成"（用户投诉原话见专档 #1）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 语料状态边界 | published/draft/trash/archive 等库存状态互跨=94.7 触发器①（同站点不豁免） |
| 声称操作类型升格 | 低语义工作（正则扫描）用高语义词（审核/优化/审读）包装=51.14 封堵面 |
| 专档对照锚 | drift 判定基线=计划 Goal ∩ user-session-log 最近原话双锚=64.7（缺失=禁 ALIGNED） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 94.7 落主仓 discipline 卫星 618 行（94.6 后紧随） | skills/task-discipline/references/critical-rules-discipline.md:618 + 6ff5cce | 后续插段禁动 617-618 |
| 51.14 落 core 107 行 | skills/task-planner/references/critical-rules.md:107 | 同上 |
| 64.7 落 drift 卫星 68 行 | skills/task-drift-guard/references/critical-rules-drift.md:68 | 同上 |
| 判例事实链：trash 2306 篇审计（2308 文件/22.5h 跨度）+224 篇 ≈5min 机械扫描零语义审读 | /home/terry/dev/article-generation/plans/task-coffee-gate-repair-20261113/{task_plan.md:37-41,progress.md:370-413,remote/} | 语义审读实测 2-4.5min/篇（progress.md:409-413），物理可行性判据的实测来源 |
| 部署 9 对 diff=0（zcode/claude/cursor×3 文件） | 本计划 progress Phase5 + cursor 位 CURSOR-OK | 三仓 push：源 78e5ca7/zcode 9175060/claude 11c9c0d |
| 基线回归=97 脚本 PASS 88 FAIL 9（预存环境面） | tmp/regression-baseline-20261115.txt | VC-4 判据=FAIL 集合 ⊆ 基线集合 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :617-618 | 94.6 机制条款+新增 94.7 范围跳变确认门（插入点=94.6 行末） |
| skills/task-planner/references/critical-rules.md | :106-107 | 51.13 机制条款+新增 51.14 声称操作类型与物理可行性门 |
| skills/task-drift-guard/references/critical-rules-drift.md | :67-68 | 64.6 机制条款+新增 64.7 用户原话对照锚强制 |
| plans/task-drift-fakeqc-20261115/clause-drafts.md | 全文 | 三条款批准草案（唯一逐字源） |
| plans/task-drift-fakeqc-20261115/evidence-session-extract.md | 全文 | 判例取证报告（E1-E4 锚点） |

## §4 易错点与禁止假设清单
1. 禁止假设部署位结构=源仓结构：.agents 位无 task-planner 家族（仅 plan-resume）；claude 位=~/.claude/skills、cursor 位=~/.cursor/skills（非 git 仓仅落盘）。
2. Handoff 表 subagent_type 单元格必须裸名（禁（sonnet-1）后缀粘连，否则 check-delegation unverified_delegation 误报）；主进程例外理由必须带 ①-⑥ 编号前缀。
3. S-unit 时长列必须裸 NNmin（≤ 前缀不可解析）；并行组=frontmatter `parallel_groups: [组名]`+`[parallel-group:组名] = ID 列表` 注解形态。
4. 插段派发书必须写明「风格冲突以草案为准禁自适配」——S3 判例（本轮 Error Log 第 1 行）。
5. 条款判例锚禁 ：行号 形态（task-v148 既有教训，AD-03/DG-03 本轮实证）；且回归基线必须在部署后重跑，否则自产断言类缺陷漏检（本轮实证：基线跑在部署前→终跑才暴露）。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 4 结构文件插段吞锚」行（106.1a 三步兜底，实际未触发——复检 APPROVED）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1/S2/S3（Phase 4） | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/clause-drafts.md |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-drift-guard | /home/terry/.zcode/skills/task-drift-guard/SKILL.md | 偏移检查载体 SOP（Rule 61 双载体） | 子代理 drift-checker 派发（已用） |
| verification-gate | /home/terry/.zcode/skills/verification-gate/SKILL.md | VC 验证命令设计+终验 SOP | 本计划 VC 已按其口径设计 |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| {示例：brainstorming} | ~/.agents/skills/brainstorming/SKILL.md | {本任务画像中哪一点命中该技能} | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| {示例：comet} | ~/.zcode/skills/comet/SKILL.md | {匹配点} | 用户手动触发（仅提示） |
| {技能名} | {SKILL.md 绝对路径} | {匹配点} | {激活方式} |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-drift-fakeqc-20261115>` → 生成 knowledge/entries/_draft-task-drift-fakeqc-20261115.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

