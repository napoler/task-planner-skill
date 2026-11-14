# Knowledge Brief — task-serial-sync-20261115（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-serial-sync-20261115/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-serial-sync-20261115/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：在技能规范层新增 Rule 107 序列创作知识同步纪律（台账沉淀+动笔回读+验收一致性三环闭环）+五载体级联，根治「写剧本上一集知识到下一集丢失」缺陷；达成标准=VC-1~VC-5 全过+selftest 回归绿+双部署位 diff=0。
- 背景/动机：用户实证投诉（user-session-log #1）——写剧本时上一集知识到下一集丢失；既有条款只覆盖工序产物依赖与文档写后回读，叙事知识既无介质可传也无纪律可依。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 序列知识台账（continuity ledger） | 序列创作任务的叙事知识介质：人物状态/世界观/时间线/伏笔/前序产出清单五字段；107.0 计划期声明路径，107.1 单元完成沉淀 |
| 三环闭环 | 107.1 台账沉淀（产出期）→107.2 动笔前强制回读（消费期）→107.3 验收一致性（验收期），主进程 107.4 编排接续 |
| 纪元锚 | 规则全集编号上界字面（如 '1-106'→'1-107'），散布在 SKILL.md 与 selftest 断言内，新规则落地必须级联 |

| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| Rule 107 六子条在权威载体在位 | tmp/worktrees→主仓 skills/task-discipline/references/critical-rules-discipline.md:740-753（merge 2660f6f 后行号以主仓实测为准） | VC-1 判据；后续任务引用 107.x 需重测行号 |
| 22.4d 派发硬条款（缺前序产出+台账路径禁派发） | skills/task-dispatch/references/critical-rules-dispatch.md:64 | VC-2 判据；序列任务派发契约面 |
| 47.7 媒体面指针（工序串行≠知识传递） | skills/media-planner/references/critical-rules-media.md:27 | 媒体族序列任务消费 107 |
| 纪元 1-107×3+路由行 ,107 | skills/task-planner/SKILL.md:9/:210/:223/:266 | 索引面级联完成 |
| EN-06 锁步+DQ-08 计数窗锁步 | selftest-enumerate-first.sh:9/:92-99；selftest-dual-qc.sh:11/:97/:100/:102 | 级联面=双形态族（字面纪元+计数窗口断言） |
| worktree 编辑前基线 FAIL=2（active-plan+execution-stability 预存） | /tmp/serialsync-st-before.log（临时的；持久记录=progress.md Phase 3/4 Test Results） | VC-3 动态阈值=2 |
| 主仓合并 2660f6f（7 文件 +36/-15）+rule 107 land | git log 2660f6f；plans/.rule-reservations.jsonl | VC-4 主仓状态核验通过 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-discipline/references/critical-rules-discipline.md | :740-753 | Rule 107 六子条全文（权威载体） |
| skills/task-dispatch/references/critical-rules-dispatch.md | :64 | 22.4d 序列回读输入必附（前序产出+台账双路径） |
| skills/media-planner/references/critical-rules-media.md | :27 | 47.7 序列剧集叙事知识同步（Rule 107 媒体面指针） |
| skills/task-planner/SKILL.md | :9/:210/:223/:266 | 纪元 1-107+全集索引 Rule 107 行+路由表 ,107 |
| skills/task-planner/templates/subagent_dispatch.md | :30 | §2 前序产出与序列台账行（非序列任务填 none） |
| skills/task-planner/scripts/selftest-dual-qc.sh | :11/:97/:100/:102 | DQ-08 计数窗 9[0-9] 锁步 |
| skills/task-planner/scripts/selftest-enumerate-first.sh | :9/:92-99 | EN-06 断言 1-107 锁步 |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁假设「级联面=字面纪元 grep 就够」——计数窗口断言（如 dual-qc '其余 8[0-9] 条'）随规则数演进溢出，级联面枚举须含双形态族：字面 '1-1[0-9][0-9]' + 计数窗 '其余 [0-9][0-9] 条'（DQ-08 判例，Error Log 2026-11-15）
2. 禁盲 grep '1-106' 判残留——SKILL.md:105 的「106.1-106.4」区间字面含 '1-106'，属 Rule 106 本体引用禁改；残留判定须排除本体引用
3. git merge 遇「HEAD 无此文件但 index 已 staged」的保守拦截（merge 不动该路径也拦）→ 走 stash 窗口合并法：stash push -- pathspec（含 staged 新文件）→ merge → stash pop（staged 态可保留）；先例=task-docmod-recheck
4. 部署位结构差异：~/.agents/skills/task-planner 为 stub 安装（无 SKILL.md/templates/scripts），勿假设两位部署面同构
- FMEA RPN>100 兜底指针：task_plan.md FMEA 表「Phase 3 级联面漏改」行——兜底=Phase 1 全量枚举清单驱动+103.6 同步核对四族全绿才翻转（已执行，DQ-08 属清单外新形态由复检体兜住）

## §5 S-unit 材料包索引
| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| Phase 3 S1-S3 | §2+§3 | findings.md §Technical Decisions（条款终稿全文五载体） |
| Phase 4 复验体 | §2+§3+§4 | subagent-state/4-general-reviewer.md |
| 后续序列创作任务 | §1（三环闭环概念）+§3（条款锚点） | 主仓 Rule 107 :740-753 重测行号 |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）
| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| verification-gate | /mnt/data/dev/task-planner-skill/skills/verification-gate/SKILL.md | VC 设计/执行期 V-N 校验/终验复验 SOP | 已内置执行（本计划 VC 即其契约） |
| alignment-review | /mnt/data/dev/task-planner-skill/skills/task-planner/review-library/alignment-review/SKILL.md | 收尾对齐审查（42.6 标准收尾流程） | 主进程终验触发 |
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
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-serial-sync-20261115>` → 生成 knowledge/entries/_draft-task-serial-sync-20261115.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

