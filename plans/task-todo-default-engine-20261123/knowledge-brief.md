# Knowledge Brief — task-todo-default-engine-20261123（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
<!--
  模板说明（复制后随正文保留至文件头部注释区，执行期可删除）:
  - 本模板由 scripts/init-session.sh 复制到 plans/task-todo-default-engine-20261123/knowledge-brief.md（第 6 计划文件）
  - 填写主体：计划期 plan-writer/主进程；执行期各 S-unit 完成后持续回填 §2/§3
  - 定位一句话：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；
    计划期产出，执行期回填
  - 与三文件罗盘关系：本文件=知识维（knowledge），不替代 findings（决策维）/ progress（进度维）/ task_plan（目标维）
  - 注意：本模板不含任务计划主模板的知识章节标题，templates/ 全库该标题 grep 锚计数维持 35（task-v115 videop1 回流 12 类后实测，template-guide.md 计数口径，验收以 guide §2.4 统一 grep 锚为准，不引行号）
-->
<!-- 填写指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: init-session.sh 建 plans/task-todo-default-engine-20261123/knowledge-brief.md 后即按 §1-§5 填写；
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
- 任务一句话：把 todo 基线组 B1-B5 扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）+ 补冲突补救 SOP + 修三层载体；达成 VC-1..7 全 PASS、B1-B5 逐字保留、3 selftest 零新增 FAIL
- 背景/动机：用户投诉默认 worktree 下仍多会话争夺写同一文件 / 发现同写冲突不走 worktree 补救 / OpenSpec·Superpowers 已声明为引擎却从未激活；根因=对齐等默认项是纯文本契约，无产出器·模板·守护三层载体

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| todo 基线组 B1-B5 | 原生 Todo 两组结构之一，承载全任务恒存的强制流程步骤，唯一事实源=references/todo-sync.md |
| B6 引擎检测 | 建 todo 时默认检测 OpenSpec/Superpowers 适配性，结论落盘 Decisions |
| B7 对齐核查 | 吸收旧计划 task-align-mandatory-step 对齐语义，叠加不重写 |
| B8 worktree 核验 | 实现类任务强制 worktree 隔离核验，未勾不得直接改主树 |
| 三层载体 | 产出器 sync-todos.sh + 模板 task_plan.md + 守护 selftest-skill-collab.sh |
| 冲突补救 SOP | 检出同写冲突→补建 worktree→迁移未提交改动→后期 smart-merge-back |

<!-- 填写说明：只录【已验证】事实，每条必须带证据锚点（file:line 或 URL）；未验证推测禁止入表，写进 progress.md「假设」区 -->
<!-- 台账供料源（Rule 21.2.1 台账供料优先）：基线定数类事实（行数/Rule 编号/计数/selftest 基线）证据列优先填台账路径锚（如 plans/.rule-reservations.jsonl:10、plans/task-vXXX/subagent-state/…），并保留原文重验锚并列 -->
<!-- 台账缺口维度（Rule 条款正文/模板区块结构/config 键语义）禁用台账行顶替，须如实填原文锚（file:line） -->
## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| B1-B5 清单唯一事实源在 todo-sync.md S1 条目（实测行 35-40） | skills/task-planner/references/todo-sync.md:35-40 | B 组扩展先改此处；行号实施日须重验（锚会漂移） |
| Rule 106.5 语义锚定义 B1-B5 五项 + 门禁硬挂钩 | skills/task-discipline/references/critical-rules-discipline.md:747-750 | 四处规则锚之一，须与 todo-sync.md 同步到 B1-B8 |
| task-planner SKILL.md S1 指针含"B1-B5"字面（实测行 256） | skills/task-planner/SKILL.md:256 | 改基线组须同步此行；BP-08 上限 470/当前 461，净增 ≤9 行 |
| sync-todos.sh --json 只输出 task entries，无 B 组（:200 `echo "[$json_entries]"`） | skills/task-planner/scripts/sync-todos.sh:156-200 | S4 须追加 B1-B8 条目，否则默认项不自动带出（F1 根因） |
| skill_collab_enforce 默认 warn、enforce 档仅语义预留、三档无 hook 校验 | skills/plan-collab-router/references/skill-collaboration.md:5-9 | 引擎激活停在软路由=用户缺陷③；B6 升级为 todo 默认必检 |
| 对齐默认项旧计划从未落地（plan-state 5 Phase pending；主仓 4 文件无 B7/对齐默认项专属锚，本轮 grep 实测） | plans/task-align-mandatory-step-20261123/plan-state.json + 主仓 4 文件 | 纠正用户"像之前加的对齐一样"前提；B7 重新落地不依赖旧产物 |
| 本计划自身 OpenSpec change 已 validate 通过（4/4 artifacts） | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/（proposal/specs×3/design/tasks） | 引擎激活在计划层自我实证，非脑补；实施按 tasks.md 清单 |

<!-- 填写说明：执行期照此表定位文件，禁止凭记忆改文件；「≤10 行摘要」列指该路径关键区段不超过 10 行的内容摘要，非行数限制语 -->
<!-- 设计插入点+范式锚（台账供料，Rule 21.2.1）：设计类 S-unit 行必含 ①目标文件插入点锚 ②最新范式块锚（来源=编号账本推最大 landed Rule → 文尾块行号）③时效戳（供料日期+快照来源）；锚区间会漂移且部署位在途写入，过期锚须重测不得盲用 -->
## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/references/todo-sync.md | :35-40 | S1 两组结构：B1-B5 定义/生命周期/门禁挂钩/mini 豁免；基线组唯一事实源 |
| skills/task-discipline/references/critical-rules-discipline.md | :747-750 | Rule 106.5 两组 todo 驱动对齐，B1-B5 清单 + 门禁硬挂钩 |
| skills/task-planner/SKILL.md | :256 | S1 两组结构指针（任务组+基线组 B1-B5，Rule 106.5） |
| skills/task-planner/templates/task_plan.md | :455-470 | Todo 同步段模板，当前无基线组清单（B6/B7/B8 露出缺口） |
| skills/task-discipline/SKILL.md | :86 | Rule 106 索引含 B1-B5（语义锚） |
| skills/plan-collab-router/references/skill-collaboration.md | :5-9,53-109 | 软路由三档 enforce 默认 warn；命中矩阵（引擎激活软指针） |
| skills/task-planner/scripts/sync-todos.sh | :156-200 | --json 只构造 task entries，:200 输出 JSON 数组（无 B 组） |
| skills/task-planner/scripts/selftest-skill-collab.sh + selftest-registry.tsv | 守护位 | B6/引擎检测锚断言落点（S4 加锚，不新增脚本） |
| skills/task-planner/references/worktree-isolation.md | 全文 | 隔离 SOP，当前无"冲突补救"段（S7 新增） |

<!-- 填写说明：编号清单；含历史教训/陷阱/禁止假设；末尾必须挂本任务 FMEA RPN>100 项的兜底动作指针（→ task_plan.md FMEA 表对应行） -->
## §4 易错点与禁止假设清单
1. 禁止删改 B1-B5 任一文案：Rule 106.5 语义锚 + todo-sync.md 唯一事实源两处须逐字保留，B6/B7/B8 只做叠加（用户"之前添加的东西不要丢弃"）
2. 禁止把 SKILL.md 当主战场：461/470 行、净增 ≤9 行（BP-08），B 组细节写 references，SKILL.md 只压缩指针
3. 禁止把引擎激活做成运行时 exit 非0 硬门：用户指定"依赖 todo 引擎=最简单方案"+文本优先铁律；机器硬门仅登记升级项
4. 禁止脑补锚行号：todo-sync.md:35-39 / critical-rules-discipline.md:747-750 / SKILL.md:256 为本轮盘上实测，实施日须重验（Rule 106.1a）
5. 禁止把 MD 派生视图当权威源：VC 命令以 plan-state.json vcs[].command 原文为准，MD 中 `\|` 仅 markdown 转义
- FMEA RPN>100 兜底指针：本计划无 RPN>100 项（唯一 F1 P3 rpn=75）；最高风险兜底=F1 fallback「VC-4 真断言输出含 B6/B7/B8；S4 selftest 加锚；失败回退 .history」→ task_plan.md FMEA 表 F1 行

<!-- 填写说明：与 task_plan.md S-unit 表「输入」列互链；「应读本 brief 哪节」精确到 §x；额外材料路径必须是绝对路径或 plan 目录相对路径 -->
<!-- 台账供料（Rule 21.2.1）：设计类 S-unit 行「额外材料路径」列直接填台账产物绝对路径（替代 prompt 内联），「应读本 brief 哪节」精确到 §2/§3 供料行 -->
## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 | §1 + §2 + §3 | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/tasks.md |
| S2 | §2(基线) + §3(锚点) + §4(禁改 B1-B5) | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/specs/todo-baseline-defaults/spec.md |
| S3 | §3(四处规则锚) | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/design.md |
| S4 | §2(产出器/守护根因) + §3 | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/tasks.md |
| S5 | §2(SKILL.md 行数) + §4 | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/design.md |
| S6 | §1(达成标准) + §4(MD 转义) | plans/task-todo-default-engine-20261123/plan-state.json |
| S7 | §2(冲突补救规格) | tmp/worktrees/task-todo-default-engine-20261123/openspec/changes/todo-default-engine/specs/worktree-conflict-recovery/spec.md |
<!-- 填写说明：任务画像期扫描 ~/.zcode/skills 与 ~/.agents/skills 索引，把匹配本任务画像的强化技能（comet 族、superpowers 族、brainstorming 等）入表——What=执行前技能扫描先于派发；Why=技能库 200+ 若从不扫描匹配，强化执行能力（头脑风暴/流程强化）永远处于「从未激活」的闲置状态（Rule 59.3，对应用户 R5） -->
<!-- 用户触发型判别（Rule 59.3 判别条款）：comet 族等 frontmatter 声明 disable-model-invocation（用户显式触发）设计的技能，「激活方式」列只准写「用户手动触发（仅提示）」，禁止主进程/子代理自动代激活——治理解法=显式可见性（扫描入表供用户与执行体择用），而非越权代触发 -->
## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| using-superpowers | ~/.agents/skills/using-superpowers/SKILL.md | 用户明令用 Superpowers 解决体系缺陷；B6 引擎检测方法论底座 | 主进程 Skill 调用（本任务已用） |
| brainstorming | ~/.agents/skills/brainstorming/SKILL.md | 方案 A 叠加 vs 替换的发散收敛 | 主进程 Skill 调用（规划期已用） |
| writing-plans | ~/.agents/skills/writing-plans/SKILL.md | 5 Phase/7 S-unit 计划产出 | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| systematic-debugging | ~/.agents/skills/systematic-debugging/SKILL.md | 4 路取证定位"纯文本契约无载体"根因 | 子代理 prompt 挂载 |
| openspec-new-change / openspec-verify-change | ~/.zcode/skills/openspec-new-change/SKILL.md 等 | 用户明令 OpenSpec 为引擎；本计划 change 已 init+validate | 主进程 Skill 调用（已实证 4/4 artifacts） |
| using-git-worktrees | ~/.agents/skills/using-git-worktrees/SKILL.md | 宪法 §十一 强制隔离 + 用户缺陷①②（同写冲突/补救） | 子代理 prompt 挂载 / 主进程 Skill 调用 |
| comet 族 | ~/.zcode/skills/comet/SKILL.md | 技能族扫描命中 | 用户手动触发（仅提示，disable-model-invocation） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
<!-- 项目级覆盖段：仅本仓（.zcode/plan-templates/ 覆盖生效）；源模板无此段 -->
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh <本计划目录相对路径，如 plans/archive/task-todo-default-engine-20261123>` → 生成 knowledge/entries/_draft-task-todo-default-engine-20261123.md
- **精炼**：draft 为机械提取原文，需人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 INDEX.md（勿手改）
- **条目规范**：见 knowledge/README.md 与 knowledge/entry-template.md（主题级合成、Rule 71 无源不写、sources 仓相对路径）

