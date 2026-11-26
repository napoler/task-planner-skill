---
name: plan-template-kit
description: 计划模板选型/定制/沉淀知识库。主路由：task-planner 在 Rule 16（选模板）与 Rule 34（沉淀）时显式 Skill("plan-template-kit") 调用；用户直呼「计划模板」「加任务类型」「模板定制/项目级覆盖」时也可触发。排除：执行期创建计划/初始化会话请用 task-planner。
---

# Plan Template Kit

> 模板规范版本: spec_version=1（2026-11-20 task-antiregress-tplgov-20261120 建立；模板规范升级时递增并按 retrofit SOP 改造存量，见 S6）
> 原则→模板区块注册表：`references/principle-template-registry.md`（spec_version=1 权威映射与覆盖守卫口径）；触发：需要查阅原则与模板区块映射、守卫断言或派生/豁免规则时；关键词：principle-template-registry 原则映射 守卫。
> 派生铁律：二级派生须 base+parent 双参照，裁剪=父级∪新增并逐级对齐 base，核心区块未经豁免不得静默丢失。
> Retrofit SOP（spec_version 存量改造）：`references/retrofit-sop.md`（scan-template-spec.sh 清单→改造→守卫复验→版本历史登记）；触发：执行模板规范版本升级、改造存量或复验守卫时；关键词：retrofit-sop 版本升级 改造守卫。

卫星技能：纯知识层——沉淀 task-planner 模板体系的选型决策树、定制契约与路径规范；机械层（variant 库、init-session.sh、check-template-type.sh、attest 门控）全部留守 task-planner।

## 何时读哪份 reference

- **选型/定制/加类型** → `references/template-mapping.md`（唯一选型权威源）：§一 分流决策树 + 类型清单 / §六 模板路径速查表 / §七 定制红线与互斥关系 / §八 验证命令 / §九 机制适用性矩阵（Rule 37 权威源，知识储备契约见 template-guide §2.4）；触发：需要按任务类型选模板、查路径速查表或机制适用性矩阵时；关键词：template-mapping 模板选型 决策树 机制画像。
- **模板优先级/项目级覆盖/路径规范** → `references/template-guide.md`：双层优先级（项目级 `.claude|zcode/plan-templates` 覆盖内置）、脚本契约标记（§四）、定制示例（§五）、路径引用规范（§七）；触发：需要确认模板覆盖优先级、项目级定制或路径规范时；关键词：template-guide 项目级模板 覆盖 路径规范。

## 与机械层（task-planner）的关系

- **权威源=JSON 模板** `../task-planner/templates/json/<type>.template.json`（33 个）；`../task-planner/templates/variant/` 的 MD 模板降级为**教学/展示视图**，不再是「把整份 MD 读进 Python」的数据源（仓内相对路径随部署位走；SKILL 内引用遵循 template-guide §七：优先 `${TASK_PLANNER_ROOT}` 绝对路径）
- 本技能**不执行**任何机械动作：模板查找/复制/白名单=init-session.sh，类型门控=check-template-type.sh + attest，均为 task-planner 脚本职责；JSON 模板落盘/勾选编辑同样属机械层——`planctl.py init --template-json <path>` 写 `template_ref/template_doc/template_checks`、`set --section template_checks --id <id> --field checked --value true` + `render` 同步派生视图，门控 `check-state-consistency.sh` 读 JSON 做负控制；本技能只提供选型与结构知识，不代执行
- 模板清单检索/克隆/派生 = task-planner `../task-planner/scripts/template-catalog.sh`（task-template-catalog-20261122）：`list --json --scope all` 拿模板名/简介/场景/功能、`clone`/`derive` 固化沉淀；本技能仅将此脚本作为选型时的只读清单来源，不复制其机械职责
- 白名单动态派生自 variant/ 目录（task-v115 videop1 回流后 29 类），本技能两份 reference 只描述、不改机械行为
- 收尾对齐与清理板块由 task_plan 基座模板 + `planctl.py` render 承载；variant 通过 template-lineage 的 `pruned` 声明裁剪该板块；mini-lite/l0-lite 档豁免，不进入正文。该板块的清理范围仅限会被 Agent 读进上下文的 Skill 说明 Markdown；代码文件（.py/.sh/.ts 等）里的注释属保护对象、禁止清理（便于后期理解、不占 Agent 上下文）。

## JSON 模板结构与勾选约定（权威源 — task-json-template-20261125）

<!-- [2026-11-25 task-json-template-docs] What: 补写 JSON 字段/块约定、to-json 用法与 lineage 位置；Why: 官方选型知识此前只描述 MD variant 目录，JSON 成为权威源后选型与沉淀若无结构口径会退回「读 MD 散文盲选」。 -->

- **字段结构**：`{schema_version:1, meta:{template_type,name,summary,scenarios,features,lineage{level,parent,base,spec_version,pruned,pruned_reason}}, sections:[{id,anchor,level,kind:ref|blocks,required,ref?:{path,renderer},blocks?:[]}]}`。`lineage.pruned[]` 显式登记被裁剪的区块、`pruned_reason` 写裁剪依据（Rule 34.5 派生登记在 JSON 内可机读）；`level=derived` 时 `parent`/`base` 双参照必填。
- **sections 两类**：`kind=ref` 的 `ref.path`/`ref.renderer` 指向 planctl 既有核心渲染器（goals/vcs/phases/scope_limits 等）；`kind=blocks` 按 `anchor` 在核心段之后按序追加。`blocks[].kind ∈ markdown|checklist|table|raw`，分别承载 `text` / `header+rows` / `items` / 原样正文。
- **checklist item 设计约定**：`{id,text,checked:false,note,tags?}`——`id` 全模板唯一（init 扁平化时重复即 fail-loud 拒绝），`checked` 严格 bool（禁字符串 `"true"`），`text` 即渲染出的 `- [ ] <text>` 文案，`note/tags` 仅作结构化备注。勾选唯一权威源是 `plan-state.json` 的 `template_checks[].checked`，MD 勾态是 render 派生，手改无效。
- **转换工具 `to-json`**：`bash ${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}/scripts/template-catalog.sh to-json [--dry-run|--write]`——默认 dry-run 只列 33 条源→目标与字段计数（含 checklist/table 计数），`--write` 才落盘 `templates/json/`；数量不等于 33 直接拒绝部分转换。存量 MD 骨架→JSON 的机械转换归 task-planner 脚本，本技能只描述何时用、不代跑。
- **选型清单来源**：`template-catalog.sh list --json --scope all` 同时列 `source=json`（权威首选）与 `source=legacy`（旧 MD 兼容），`preferred=true` 为选型首选；本技能选型时以 JSON 元数据（name/summary/scenarios/features）为准，同名 MD 仅作教学视图。

## 沉淀指针（Rule 34）

- Rule 34.3 触发条件命中（同类任务第 2 次 / 新类型可泛化 / 用户点名）→ 按 34.4 **研究前置与生成/沉淀流程**执行：先任务分析+项目/用户/内置相似模板扫描+网络调研并记录依据，再生成候选；候选先落计划目录 `template-candidate/`，**获用户明确审核授权后才可落盘**持久库（禁 silent 自动落盘、禁无调研依据生成）。落盘后执行 **34.2 四点同步**：① template-mapping.md 决策树与清单 ② plan-writer 映射表 ③ task-planner SKILL.md 模板节 ④ template-guide.md 变体表与计数；**JSON 模板同步口径（2026-11-25）**：四点点名与顺序不变，但新 variant 入库必须同步落 `templates/json/<type>.template.json`（先 `to-json --dry-run` 核对字段与勾选条目，再 `--write`），JSON 为第①点清单的权威数据面（含 lineage/pruned 登记），MD 变体仅作教学视图——即「四点同步 + 一份 JSON 权威源」，缺 JSON 视为沉淀未完成
- 一致性由 task-planner `../task-planner/scripts/selftest-template-lifecycle.sh` 守护；沉淀动作登记计划 Decisions Made 表
- **研究前置/审后落盘合约（34.7）**：终验 outcome=COMPLETE 且命中 34.3 任一条件 → 按 34.4 执行：先网络调研并记录依据，再生成/派生候选至 `template-candidate/`（可派 plan-writer/code-assistant 产出候选，但**不得**直接写入持久模板库）；候选须过 34.5 双闸门与 34.8 对应门禁；**必须向用户展示候选并询问是否保存/保存位置，获用户明确审核授权后才可落盘**到项目级/用户级/官方库（禁 silent 自动落盘）。一次性/不可泛化任务 → 登记「不沉淀理由」收场而非硬生成
- 同步清单：template-mapping.md 清单与计数、template-guide.md 变体表与「N 个」计数加一（均在本卫星 references/）、companion 的 plan-writer.md 映射表行、主 SKILL.md 模板节指针核对；计数级联要求=selftest-template-lifecycle TL-17「N 个」断言同改（v093 教训）；init-session 与 check-template-type 白名单动态派生免同步（扫描层/优先级规则变更须同步两脚本与文档）
- 执行期候选登记与项目级适配生产由 plan-template-advisor 卫星承接（Rule 34.8 执行期触点/34.9 项目级/用户级沉淀位）。

## 使用入口（两种）

1. 主路由：task-planner Rule 16 选模板 / Rule 34 沉淀时显式 `Skill(skill="plan-template-kit")`
2. 直接触发：用户问「计划模板怎么选」「加一种任务类型」「项目级模板定制」时加载

## 边界铁律

- 执行期创建/初始化计划 = task-planner 职责，本技能不承接
- 只读路由与知识描述，不修改 task-planner 侧文件；发现两份 reference 与机械层漂移 → 报告，不在本技能内修

## 卫星路由：plan-template-kit — 域=模板生命周期与难度分级（Rule 16,34,37,38）

规则全文见 references/critical-rules-template.md（Rule 16 任务开启期选模板、Rule 34 模板生命周期：选取门控 + 沉淀入库、Rule 37 任务类型机制画像、Rule 38 任务难度分级与轻量档，自 task-planner 核心 critical-rules.md 收编）；触发：涉及选模板与「📚 必要知识储备」章节（Rule 16）/模板沉淀入库与四点同步（Rule 34）/按 template_type 裁剪机制画像（Rule 37）/轻量档 mini 判定与门控豁免（Rule 38）时 Read 该文件；关键词：critical-rules-template Rule16 Rule34 Rule37 Rule38 模板生命周期 难度分级。
