# Knowledge Brief — task-v123（Rule 48 交付总结可定位性与实用性）
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/<task-id>/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：落地 Rule 48「交付总结可定位性与实用性」——交付总结每个指针/行动项用户可直接打开或执行（模板+SKILL+规则+守卫四层），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。
- 背景/动机：用户 2026-10-03 指令——交付总结让审查对象缺路径/网址，「让人完全不知道到哪里审查」；要求系统性实用化。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 交付总结（delivery summary） | 终验后给用户的五要素总结（说明/产出/审查/风险/下一步），模板=templates/delivery-summary.md |
| 可定位性（Rule 48） | 指针必须为绝对路径/URL/可执行命令；禁裸文件名、模糊指代、未解析占位符 |
| 定位三要素（48.3） | 行动项=对象（路径/URL）+看点（锚点）+动作（做什么/反馈）；审查类必须含审查对象路径或网址 |
| 定位栏 | 总结头部 blockquote：机器档案/仓库/交付基线/部署位（绝对路径） |
| TL-19/20/21/22/23/24 | selftest-template-lifecycle.sh 的静态断言编号（19-21 既有；22-24 本任务新增） |
| 轻 diff CR | 代码文件 ≤3 个且 ≤50 行 → Code Review 单轮轻量审查（本任务 .sh 仅 1 文件） |
| 编号避让 | Rule 47 归并行会话 task-v122（在途）；本任务取 Rule 48（1-4[5-9] 预扩窗口零级联） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| SKILL.md 现 444 行；T-主 断言 ≤444 | `scripts/selftest-skill-split.sh:41` | 4 处编辑必须行内替换保零净增；P2 后 wc -l 复核 |
| 模板五区块计数断言 =5 | `scripts/selftest-template-lifecycle.sh:92` | 升级保持 `^## [1-5]\.` 5 个；定位栏用 blockquote |
| SKILL 中 delivery-summary 提及 ≥2 断言 | 同脚本 :94 | 行内替换不删提及 ✓ |
| frontmatter 现「Critical Rules 全集 1-46」 | `SKILL.md:9` | 改 1-48；PT-08 宽容锚 `1-4[5-9]` 匹配 |
| RT-08 断言 SKILL/CRIT 中 1-4[0-9] 越界零命中（1-4[5-9] 加白） | `selftest-ask-default-timeout.sh:65-69` | 禁写「1-4x」字面；写「Rule 48」安全 |
| 3 实体位与 master 一致（29 variants / SKILL 444 行） | `ls ~/.zcode/.claude/.config/opencode` 2026-10-03 实测 | --deploy 全位对账预期 IDENTICAL；仍须方向审计前置 |
| smart-merge-back --deploy 两级对账+原子替换 | `scripts/smart-merge-back.sh:348-470` | 部署=脚本驱动；DRIFT exit 6 fail-closed |
| v122 活跃（Rule 47 媒体派发）；wt/task-v122 @b07c0cb | `plans/task-v122/task_plan.md`（08:54 mtime）+ `git worktree list` | 同文件区冲突风险；块级/行尾追加+编号避让；禁触其产物 |
| critical-rules.md 483 行，Rule 44/45/46 块范式在 L438-483 | `references/critical-rules.md` | Rule 48 块照 46 范式写（标题行+子条动词短语+末条机制） |
| registry 43 脚本（tsv 44 行） | `scripts/selftest-registry.tsv` | 不新建脚本 → 零动 |
| templates/ 计数锚 35（知识章节标题口径） | `template-guide.md §2.4`（knowledge-brief 头注） | 升级不得新增被计标题（只用注释/blockquote/表格） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| `SKILL.md` | :158 | 终验交付段「交付总结（五要素）」行（R2 替换点） |
| `SKILL.md` | :247 | Critical Rules 引导行「Rules 1-39（含 Rule 40…46）」（R3） |
| `SKILL.md` | :305 | References 表 critical-rules.md 行（R4） |
| `SKILL.md` | :9 | frontmatter description「Critical Rules 全集 1-46…」（R1/R1b） |
| `templates/delivery-summary.md` | :1-46 | 头部注释指引区 + 五区块（S3 全文件升级，目标全文见 findings D2 区） |
| `scripts/selftest-template-lifecycle.sh` | :20-24 | 头注释 TL 清单（S6 追加 TL-22/23/24） |
| `scripts/selftest-template-lifecycle.sh` | :90-96 | TL-19/20/21 断言实现（S6 追加锚点区） |
| `references/critical-rules.md` | :483（文件尾） | Rule 46 块末尾，Rule 48 追加点 |
| `plans/task-v123/findings.md` | D2/D3/D4/D5 区 | 四个定稿文本（S3-S6 的输入材料包） |

## §4 易错点与禁止假设清单
1. 禁止凭记忆改文件——四文件全部先 Read 定位锚点（行号可能因并行会话合并漂移，用内容 grep 定位）
2. 禁止触碰并行会话产物：`plans/task-v122/**`、worktree `/mnt/data/dev/task-planner-skill-worktrees/task-v122`（§11.4）
3. SKILL.md 只许行内替换，禁止 +1 行（T-主 444 定数，撞则级联代价高）
4. 模板升级禁加 `## 6.` 之类新序号区块（TL-19 =5）；也禁新增「## 📚 必要知识储备」等被计标题（templates/ 计数 35）
5. 禁写「1-4x」形式字面（RT-08 零越界）；引用规则写「Rule 48」「48.1」形式
6. 负向自检必须实测（缺锚 fixture 必 FAIL），防恒 PASS 假绿（v118 教训）
7. 部署前必须方向审计（3 位现文件 ≡ master 基线）——有未收编更新则 STOP 收编，禁直接 --deploy 覆盖
8. 合并冲突（v122 同区）解决口径=「46/47/48 序并存」；解决后 wc -l/grep 全线复验
- FMEA RPN≥100 兜底指针：→ task_plan.md FMEA 表「Phase 3 TL-22/23/24 负向无牙齿（RPN=100）」行

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §3 + §4 | `plans/task-v123/findings.md`（Research Findings A 区：缺陷清单 v0 + 级联锚清单） |
| S2 | §2 | —（直接跑脚本） |
| S3 | §1 + §3 + §4 | `plans/task-v123/findings.md`（D2 定稿区：目标全文） |
| S4 | §3 + §4 | `plans/task-v123/findings.md`（D4 定稿区：4 处替换表） |
| S5 | §3 + §4 | `plans/task-v123/findings.md`（D3 定稿区：Rule 48 全文） |
| S6 | §3 + §4 | `plans/task-v123/findings.md`（D5 定稿区：TL-22/23/24 代码骨架） |
| S7 | §2 | —（直接跑脚本） |
| S8 | §1 + §2 | `plans/task-v123/findings.md`（全文）；`git diff master -- scripts/` |
| S9 | §1 + §3 | `plans/task-v123/findings.md` + `plans/task-v120/delivery-summary.md`（对照实例） |
| S10 | §1 + §2 | `plans/task-v123/delivery-summary-sample.md`（S9 产物） |
| S11 | §1 + §2 | wt 四文件 diff + `plans/task-v123/task_plan.md` |
