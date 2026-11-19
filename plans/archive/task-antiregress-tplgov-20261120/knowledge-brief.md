# Knowledge Brief — task-antiregress-tplgov-20261120（任务知识简略要点）
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；项目级双轨与内建 templates/knowledge-brief.md 同契约 -->
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由主进程（plan-writer 内联降级）产出，执行期持续回填。
> 依据：`subagent-state/01-planwriter-brief.md`（file:1）、`research/template-inventory.md`（file:1）。

## §1 任务速览与核心概念
- 任务一句话：为 task-planner-skill 建立「进度产出基线防倒退」机制并完成模板治理体系升级（原则注入/主动加载+场景覆盖/模板 spec_version+存量改造/分级派生 lineage），在 worktree 内分 P1→P4 实施并以机器 VC 验收。
- 背景/动机：用户要求防“拆东墙补西墙”式进度倒退、提升模板原则可靠性与主动适配、补齐模板升级与派生传导机制，避免核心原则沿派生链丢失（用户原话见 `task_plan.md` §🎯）。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 进度产出基线 | 动工前登记项目关键产出/进度快照+禁倒退清单，交付/合并前逐项终检，净效果<0 即 BLOCK（本任务 R1 新增面）。 |
| Spec-Baseline Freeze (51.15) | 已确立规范阈值登记→attest SHA-256 锁→四环回归的既有防倒退机制；管规范阈值面，与进度产出面分工互锁（`references/critical-rules.md:109`、inventory §7.2）。 |
| 修改合规门 (74.7) | 变更前合规四元组+无依据放宽禁止的通用前置门；管修改依据，与 51.15/新防倒退 Rule 分工（`critical-rules-discipline.md:495`）。 |
| template_type 白名单 | `general + templates/variant/*-type.md` 动态派生，由 `scripts/check-template-type.sh` 三形态提取校验（inventory §5.4/§6.2）。 |
| lineage/spec_version | 本任务拟新增的模板血缘与版本元数据；当前仓库 0 命中（inventory §3.4/§6.3，`grep -rn 'spec_version|lineage'` 无结果）。 |
| base/derived 分级 | base=`templates/task_plan.md` 主模板（最高可靠性），derived=`variant/*-type.md` 31 个；派生裁剪须逐级对齐 base 且二级派生 base+parent 双参照（R5 定义）。 |
| template-sense (T1/T3) | init-session 对 general/未知类型发 `[template-sense]` 并追加感知区块，check-complete 终验 warn 未登记理由（inventory §5.1/§5.2）。 |
| worktree 隔离 | 实现类任务在 `<project-root>/tmp/worktrees/<task-id>`（分支 `wt/<task-id>`）开发，验证后 `--no-ff` 合并并清理（brief §0/§4.1）。 |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 仓库 HEAD=76a6466，主仓 18 个未提交 M 文件分属三簇在途任务，本任务禁触碰 | `research/template-inventory.md:5`、`:11-34`、`:36`（`git status --porcelain -uall`/`git diff --stat HEAD` 证据） | 实施必须在 worktree（从 HEAD 建），合并期需处理与主模板等触点冲突，禁改 18 文件。 |
| 模板总量 44（根 13 + variant 31，命名 `*-type.md`） | `research/template-inventory.md:94-99`（`ls`/`wc -l` 证据） | R4/R5 批量注入 lineage/spec_version 面=31 variant+主模板等，须脚本生成+抽检，禁 31 次手工 Edit。 |
| 主模板含 601 行、已含 `🔒 规范基线 (51.15)`/`🧭 指令理解迭代草稿 (28.2.2)` 等治理区块；抽样 variant 未对齐 | `research/template-inventory.md:105-114`、`:117-127`、`:301` | P1 新增「📦 进度产出基线」「🛡 防倒退终检」须加主模板并定义 variant 同族策略；存量对齐是 P3 改造面。 |
| 仓库当前无 `spec_version/lineage/parent_template/base_template/derived_from` 元数据 | `research/template-inventory.md:130-133`、`:230-235`（`grep -rn` 0 命中） | R4/R5 需从零引入约定与守卫，须兼容既有脚本提取形态。 |
| 规则编号现状：core max 109、discipline max 106、dispatch max 110（110=任务分级已占用） | `research/template-inventory.md:242-248`（`grep -n '^### [0-9]'`） | 新防倒退 Rule 候选 111 起，实施前必须 `grep` 三份全集确认空号（brief §4.2）。 |
| 既有防倒退/合规闭环：51.15 + 74.7 + 106.7 + 22.4e + 103.3b 已提交 | `research/template-inventory.md:252-267`、`:300`（`git blame` 274bb9e3） | R1 新 Rule 必与 74.7/51.15 分工互锁不重复，复用登记→锁→四环回归范式。 |
| 模板加载链：init-session 发现 `.claude/.zcode/plan-templates`（项目优先）→ 渲染 7 文件；T1 template-sense 对 general/unknown 追加区块；T3 check-complete warn | `research/template-inventory.md:164-176`、`:178-185`、`:208-209` | R3 “主动加载+general 兜底须登记理由”需改 init-session/check-complete/advisor 链并保持门控兼容。 |
| check-template-type.sh 支持 frontmatter 行首/表格行/HTML 注释三形态提取，白名单动态派生 | `research/template-inventory.md:223`、`scripts/check-template-type.sh`（inventory 证据指向） | R5 variant 头注入 lineage/spec_version 不得破坏三形态提取（VC 必含兼容性验证）。 |
| 主仓未提交 `templates/task_plan.md` 含 28.2.2 理解迭代草稿区块改动，与本任务主模板改造高冲突 | `research/template-inventory.md:18`、`:125`（+7 行，28.2.2 区块） | 计划风险区必须登记合并冲突；worktree 从 HEAD 建，合并期按 V3/V5/V6 处理。 |
| plans/INDEX.md 待处理含 `task-variant-upgrade-20261113`（28 variant 升级）、`task-l0lite-exempt-20261103` 等主题交叉项 | `research/template-inventory.md:272-296` | R4 机制化 retrofit 需吸收 variant-upgrade 经验；场景覆盖补缺须数据驱动盘点且不与既有 pending 重复拍脑袋。 |

## §3 关键文件锚点表

| 路径 | 行号/锚点 | ≤10 行摘要（该区段做什么） |
|------|-----------|---------------------------|
| `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` | `:1-9`, `:62-67`, `:601-610` | 主模板 frontmatter（template_type/plan_tier/execution_lane）、`🔒 规范基线` 区块、末尾 `🔁 模板感知` 运行时区块；R1 将新增基线登记+终检区块。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` | `:109` (inventory) | core Rule 109/51.15 规范基线冻结（四环绑定、双向登记）；新防倒退 Rule 插入须与其分工并 grep 确认空号。 |
| `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` | `:495`, `:733` (inventory) | 74.7 修改合规门、106(末) 返工/回归相关；discipline max 106，新增级联锚候选位需实测。 |
| `/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md` | `:66`, `:241`, `:310` (inventory) | 22.4e 携带、103.3b 复检回归、110 任务分级；dispatch max 110，新增锚须避占用号。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-template-type.sh` | 全文（inventory §6.2） | template_type 白名单动态派生+三形态提取；lineage/spec_version 注入兼容性 VC 依赖此契约。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh` | `:64-99`, `:679-736`, `:898-969` (inventory) | 项目级模板发现/复制优先级、白名单扩展、T1 template-sense 触发与区块追加；R3 主动加载改造触点。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh` | `:664-675` (inventory) | T3 template-sense 未登记理由 warn；R3 可能升级为更强登记约束需配套守卫。 |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-mapping.md` | 全文（inventory §4.1） | 选型决策树/类型清单/机制画像权威源；R2 原则注册表、R3 场景覆盖与计数级联落点。 |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-guide.md` | 全文（inventory §4.1） | 双层优先级、变体表与计数、定制契约；spec_version/lineage/retrofit SOP 需同步。 |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/critical-rules-template.md` | 全文（inventory §4.1/§5.2） | Rule 16/34/37/38 模板域规则；R2/R3/R4/R5 条款与锚点落点候选。 |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/SKILL.md` | 全文（inventory §4.1） | 纯知识层卫星，选型/适配/升级路由；原则注册表与 retrofit 能力声明接线。 |
| `/mnt/data/dev/task-planner-skill/skills/plan-template-advisor/SKILL.md` | 全文（inventory §4.2） | 项目模板适配分析与候选产出 SOP；R3 主动适配/场景缺口盘点协同面。 |
| `/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/plan-writer.md` | 全文（inventory §5.4） | 模板选择/门控契约与类型映射；R3 主动加载策略若影响选型需同步。 |

## §4 易错点与禁止假设清单
1. 禁触碰主仓 18 个未提交 M 文件及未跟踪 forensics/session-plan/knowledge 草稿（`template-inventory.md:11-67`）；实现全在 `tmp/worktrees/task-antiregress-tplgov-20261120`。
2. 禁凭记忆分配 Rule 编号：110 已被 dispatch 任务分级占用（`template-inventory.md:248`），实施前必须 `grep -n '^### '` 三份 rules 全集实测空号后再落 111+。
3. 禁与 51.15/74.7 语义重复：R1 新 Rule 只管“进度产出面”防倒退并与“规范阈值面(51.15)/修改依据面(74.7)”显式分工互锁（`template-inventory.md:252-267`）。
4. 31 个 variant 批量注入 lineage/spec_version 必须“脚本生成+抽检复验”，禁止 31 次逐个手工 Edit（brief §4.4）；注入后必须通过 `check-template-type.sh` 三形态兼容验证（brief §4.5）。
5. selftest 动工前先全量跑基线并落盘预存 FAIL 清单，收尾同集零增量对比（brief §4.3）；不得以“与本任务无关”为由跳过基线记录。
6. R3 场景覆盖补缺必须数据驱动：统计 `plans/` 历史任务类型分布对照 31 variant 覆盖面后提出候选，不得拍脑袋（brief §2 R3）。
7. `templates/task_plan.md` 主仓存在在途未提交改动，合并期预期冲突（`template-inventory.md:18`）；worktree 从 HEAD 建，冲突按 V3/V5/V6 延后处理并在风险区登记。
8. general 兜底当前为“静默默认+T1/T3 感知 warn”（`template-inventory.md:170-176`, `:224-225`）；R3 要求改为须登记理由，需兼顾 init-session/check-complete/advisor 三点与现有 selftest 锚点。
9. 文本优先铁律：交付限规则条款/模板文本/注册表/守卫与 selftest 脚本等既有机器面惯例，不新增 hook/registry 之外基础设施（brief §4.10）。
10. 本计划自身为 P1 防倒退区块首个实弹载体：实施动工时须回填自身「📦 进度产出基线」（brief §4.7），计划期先在 P1 S-unit 中显式安排。
- FMEA RPN>100 兜底指针：→ `task_plan.md`「📊 FMEA 预演」表（合并冲突/白名单兼容破坏/部署漂移/selftest 基线误判/编号冲突各行）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1 (P1 基线与编号核实) | §1 + §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/plans/task-antiregress-tplgov-20261120/research/template-inventory.md` + `/mnt/data/dev/task-planner-skill/skills/task-planner/references/critical-rules.md` |
| S2 (P1 规则与模板区块) | §1 + §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/task_plan.md` + `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` + `/mnt/data/dev/task-planner-skill/skills/task-dispatch/references/critical-rules-dispatch.md` |
| S3 (P1 守卫/selftest/SKILL 接线) | §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` + `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-complete.sh` + `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/selftest-template-sense.sh` |
| S4 (P2 lineage 元数据与注入脚本) | §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/` + `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/check-template-type.sh` |
| S5 (P2 原则注册表与 kit 接线) | §1 + §2 + §3 | `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-mapping.md` + `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/template-guide.md` + `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/references/critical-rules-template.md` |
| S6 (P3 spec_version+retrofit SOP) | §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/skills/plan-template-kit/SKILL.md` + `/mnt/data/dev/task-planner-skill/plans/INDEX.md` + `/mnt/data/dev/task-planner-skill/research/template-inventory.md` |
| S7 (P3 主动加载+场景数据盘点) | §2 + §3 + §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/init-session.sh` + `/mnt/data/dev/task-planner-skill/skills/plan-template-advisor/SKILL.md` + `/mnt/data/dev/task-planner-skill/plans/`(历史分布扫描) |
| S8 (P4 部署同步与收尾) | §2 + §4 | `/mnt/data/dev/task-planner-skill/skills/task-planner/scripts/deploy.sh` + worktree 变更清单 + selftest 基线记录 |

## §6 可用强化技能清单（Rule 59.3 — 执行前技能扫描）

| 技能名 | SKILL.md 绝对路径 | 匹配点 | 激活方式 |
|--------|------------------|--------|---------|
| task-planner | `/home/terry/.zcode/skills/task-planner/SKILL.md` | 本任务为计划体系/模板/规则治理升级，需遵循计划格式、VC、S-unit 与门控约定 | 主进程/执行体按需 Skill 调用 |
| plan-template-kit | `/home/terry/.zcode/skills/plan-template-kit/SKILL.md` | R2/R3/R4/R5 直接涉及模板选型、原则注入、沉淀/升级契约与四点同步 | 子代理 prompt 挂载 / Skill 调用 |
| plan-template-advisor | `/home/terry/.zcode/skills/plan-template-advisor/SKILL.md` | R3 场景缺口盘点与项目/类型适配建议需数据驱动分析 | 子代理 prompt 挂载 / Skill 调用 |
| rule-enhancement | （模板画像对应类型）`/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/rule-enhancement-type.md` | 规则/机制治理类任务骨架参考，贴合 R1/R2/R4 的规则与守卫落地 | 计划模板选型参考（非 Skill 工具） |
| refactor | `/mnt/data/dev/task-planner-skill/skills/task-planner/templates/variant/refactor-type.md` | 批量模板结构改造与兼容性重构（R4/R5）流程参考 | 计划模板选型参考（非 Skill 工具） |
| verification-before-completion | `/home/terry/.zcode/skills/verification-before-completion/SKILL.md` | P4 收尾与 VC 终验需证据闭环，防“应已完成”口径 | 子代理 prompt 挂载 / 主进程按需调用 |
| systematic-debugging | `/home/terry/.agents/skills/systematic-debugging/SKILL.md` | selftest 回归/守卫兼容失败时先定位根因再修复，避免盲改 | 子代理 prompt 挂载 / 主进程按需调用 |
| comet | `/home/terry/.zcode/skills/comet/SKILL.md` | 若用户后续要求 comet 流程强化实施/验证可提示 | 用户手动触发（仅提示） |

## §7 项目知识库回链（终验后入库触发 — task-kb-persist-20261022 增补）
- **触发点**：任务终验交付完成后（check-complete exit 0 后、归档前后皆可）
- **入库命令**：`bash scripts/kb-sync-from-plan.sh plans/archive/task-antiregress-tplgov-20261120` → 生成 `knowledge/entries/_draft-task-antiregress-tplgov-20261120.md`（路径以实际归档位置为准）
- **精炼**：draft 机械提取后人工/模型合并去重→主题化→补证据锚行号→去除 `_draft-` 前缀改名
- **索引**：改名后 `bash scripts/kb-rebuild-index.sh` 重建 `INDEX.md`（勿手改）
- **条目规范**：见 `knowledge/README.md` 与 `knowledge/entry-template.md`（主题级合成、Rule 71 无源不写、sources 仓相对路径）
