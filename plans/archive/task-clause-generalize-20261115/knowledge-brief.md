# Knowledge Brief — task-clause-generalize-20261115（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-clause-generalize-20261115/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-clause-generalize-20261115/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：把 task-drift-fakeqc-20261115 落地的三条判例特化条款（94.7/51.14/64.7）按 critic 21 项审查的授权清单（P1+P2+级联 15 项）泛化修订，验收=VC-1..5 全 PASS（草案落位+回归 ⊆ 基线+部署 15 对 diff=0）。
- 背景/动机：用户裁定「不要每次修改只针对一个特化问题」——条款须跨域照字面可判定。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 三条款 | 94.7 对象状态分区与规模跳变确认门（discipline）/51.14 完成声称操作类型与物理可行性门（planner）/64.7 用户原话对照锚强制（drift-guard） |
| gen-fix | Phase 2 四路并行插改组（S1 discipline/S2 core/S3 drift/S4 级联面） |
| L1-L4 档位 | 51.14 操作类型语义档位表：机械/统计＜抽样＜逐件语义＜创作改写 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 三条款 v2 落位主仓（源仓 e4235af+b2e138c） | skills/task-discipline/references/critical-rules-discipline.md:616,618；skills/task-planner/references/critical-rules.md:107；skills/task-drift-guard/references/critical-rules-drift.md:63,68 | 修订以整行替换+句尾增量为唯一形态 |
| 部署位布局=$pos/<skill>/…（无 skills/ 前缀段） | /home/terry/.zcode/skills/task-discipline/references/critical-rules-discipline.md 实测 | 拼路径禁 $pos/skills/$f（VC-5 曾犯） |
| 64.6 行实际行文=`64.6 **零新 config 键…`（无 - 前缀） | critical-rules-drift.md:67 | VC-2 判据串必须按实际行文写（判据先 grep） |
| 回归基线=97 脚本 FAIL=9 集合 | tmp/regression-final-20261115.txt | VC-4 判据=comm -13 为空 |
| alignment-review 13 项中 11 项=授权外候选 | plans/task-clause-generalize-20261115/subagent-state/5-alignment.md | 修复仅限授权条款自引入矛盾（F4/F7） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-discipline/references/critical-rules-discipline.md | :616/:618 | 94.5 衔接句（+94.7 衔接）/94.7 v2 整行 |
| skills/task-planner/references/critical-rules.md | :106/:107 | 51.13 既有锚/51.14 v2 整行 |
| skills/task-drift-guard/references/critical-rules-drift.md | :63/:67/:68 | 64.4 四锚行/64.6 零新键锚/64.7 v2 整行 |
| plans/task-clause-generalize-20261115/clause-drafts-v2.md | §0-§6 | 15 项映射+三条款全文+级联 spec（唯一事实源） |

## §4 易错点与禁止假设清单
1. 判据串禁凭记忆写——先对目标文件 grep 实测再落 verification.md（本任务 64.6 判例）
2. findings/progress append 类回填 old_string 锚=既有行尾部片段，禁整行替换（F2/F3 两犯判例）
3. S4 级联输入列路径 token ≤2：clause-drafts-v2 去 .md 后缀写法
4. 结构文件插改=整行替换，new 逐字取草案禁自适配风格
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2 吞锚/格式自适配」行（106.1a 三规约内联）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 起草 | §1 + §2 + §3 | /mnt/data/dev/task-planner-skill/plans/review-clause-generality-20261115.md + plans/archive/task-drift-fakeqc-20261115/clause-drafts.md + plans/task-clause-generalize-20261115/user-session-log.md#2 |
| S1-S4 插改 | §2 + §3 + §4 | /mnt/data/dev/task-planner-skill/plans/task-clause-generalize-20261115/clause-drafts-v2.md |
| S1 复检 | §2 + §3 | 同上草案+subagent-state/2-insert-S1..S4.md |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | ~/.zcode/skills/task-planner/SKILL.md | 本任务全流程 SOP（attest/委派门/VC 机制） | 主进程按 SOP 执行 |
| alignment-review | ~/.zcode/skills/alignment-review/SKILL.md | 收尾对齐审查（CR 配置登记） | 已按登记消费（critic 承载，Handoff#5） |

> 扫描说明：本任务=规则文本修订画像，comet 族/头脑风暴族无匹配点，未激活（Rule 59.3 显式留痕）。

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-clause-generalize-20261115>` → 生成 knowledge/entries/_draft-task-clause-generalize-20261115.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

