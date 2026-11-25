---
name: plan-template-advisor
description: 项目模板适配分析与沉淀建议。主路由：激活后主动分析当前项目、预测潜在任务类型与坑并产出适配计划模板；用户直呼「项目模板适配分析」「沉淀项目级模板」「模板缺口分析」「分析当前项目制定模板」「为项目生成计划模板」时触发。排除：官方模板选型与生命周期权威判定请用 plan-template-kit；执行期创建/初始化计划请用 task-planner。
---

# Plan Template Advisor

轻量卫星=项目模板适配器（纯 SOP，零新脚本）：基于项目证据分析任务类型与缺口，产出可审查的项目级计划模板候选。与 task-planner（机械层：init-session/check-template-type/render 等模板发现与校验）分工为「分析与生产」对「执行与门控」；与 plan-template-kit（模板生命周期权威源，Rule 34 及其 references/）分工为「项目级适配沉淀」对「选型/定制/官方沉淀规则」。激活方式：用户显式激活；或 Rule 34.8/34.9 沉淀评估、缺口映射时路由至本技能。

## 使用入口

激活后按 SOP 六步执行，逐步落盘证据与产物（Rule 71 无源不写）。

### ① 项目分析
- 读取 AGENTS/CLAUDE/README、目录与技术栈画像，建立项目基线。
- 统计 `plans/INDEX.md` 与 `plans/archive/` 近期任务类型分布与频次。
- 提取 findings/knowledge 高频坑、错误日志与 `git log` 任务指纹。
- 证据与结论落盘当前任务 `findings.md`，禁止无盘上依据的推断。

### ② 问题预测
- 构建「高频任务类型 × 典型坑」映射表，类型来自步骤①统计。
- 坑来源限定：历史 findings、错误日志、归档计划教训与可追溯 git 记录。
- 标注每类任务的高风险环节（验证命令缺失、范围失控、知识储备不足等）。
- 输出预测清单并指向证据条目，供缺口映射引用。

### ③ 缺口映射
- 对照模板白名单：`templates/variant/*-type.md`（30 类，**教学视图**）与权威源 `templates/json/*.template.json`（33 个），以及项目级既有模板（`.claude/plan-templates/` 或 `.zcode/plan-templates/` 下的 MD 与 JSON，init-session.sh 原生发现并并入白名单的机制）；JSON 与 MD 同名时以 JSON 元数据（scenarios/features/lineage）为缺口判定依据。
- 无专用 variant 的高频类型 → 标记为候选新类型模板。
- 已有 variant 但 Verify command/执行范围限制需项目本地化 → 标记为适配版候选。
- JSON 缺口判定（2026-11-25）：扫描 `templates/json/` 与项目级 JSON 位——MD 已存在但缺 `<type>.template.json` = 待转换（交 task-planner `to-json` 机械转换）；JSON/MD 均缺 = 候选新类型；JSON 已有但 scenarios/features 不覆盖项目高频坑 = 适配版候选（改 JSON meta + blocks，而非只改 MD 文案）。
- 查重同时覆盖两种形态：同名 `*-type.md` 与 `*.template.json` 任一存在即视为已有类型，避免重复沉淀造成双源漂移。
- 清单来源：先跑 `template-catalog.sh list --json --scope all`，按 `source=json` / `preferred=true` 取官方权威候选；项目级 JSON 位由 `ls` 实测，禁止凭记忆判定缺口。
- 映射前先 `ls` 白名单与项目级目录查重，避免重复沉淀。

### ④ 模板产出
- 候选先落当前任务计划目录 `template-candidate/`，便于审查与回溯。
- 项目级落位 `<项目>/.zcode/plan-templates/<类型>-type.md`（或 `.claude/plan-templates/` 同名位）**及其 JSON 结构化源** `<项目>/.zcode/plan-templates/<类型>.template.json`（Claude Code 侧 `.claude/plan-templates/` 同名位）；task-planner `init-session.sh` 原生发现并入白名单，零接线。
- 只写 `*-type.md` 与同名 `*.template.json` 两种后缀文件；单次激活产出 ≤3 个类型（每类型的 JSON+MD 两份视为一个候选），防刷量与过度定制。
- 类型标识=文件名去 `-type.md` 后缀（init-session.sh 派生口径）：机读头与 `template_type` 填该标识（如文件 `foo-type.md`→类型 `foo`），禁重复带 `-type` 后缀（判例=task-tpl-sediment-20261115 G2 首跑选型失败回退 generic）；JSON 侧 `meta.template_type` 必须同值。
- 候选须同时产出两份：**JSON 结构化源**（`schema_version/meta{lineage:level,parent,base,spec_version,pruned,pruned_reason}/sections[{id,anchor,kind,blocks}]`）为权威 + **MD 教学视图**（`*-type.md`）供人读；勾选与表格用 JSON `blocks[].kind=checklist|table` 表达（item 含 `id/text/checked:bool/note/tags`），禁只在 MD 写 `- [ ]` 而 JSON 缺对应条目（render 会覆盖手改勾态）。
- 消费与自检（零新脚本）：`planctl.py init --template-json <path>` 落 `template_ref/template_doc/template_checks`；候选期用 task-planner `template-catalog.sh to-json --dry-run` 核对结构与勾选条目后再定稿；本技能不新增 `.sh`/hook/门。
- 审查分工：MD 教学视图承载 Goal/VC 表/Phase 骨架的展示文案，JSON `kind=ref` 段由 planctl 核心渲染器填值；两者不得各写一套勾态/状态字段，只有 JSON 的 `checked` 与 `plan-state.json` 参与门控比较。
- 模板须含机读头与最小结构骨架，适配项目实际验证命令与范围约束。

### ⑤ 审查
- 按 Rule 34.8 项目级门执行 G1 结构 lint：Goal/VC 表/Phase 骨架/执行范围限制/必要知识储备 + ≤100 行 + 机读头。
- G2：`render_template` 冒烟无 `{{}}` 残留（复用其既有 fail-closed 契约：残留 token 即渲染失败）。
- G3：独立审查派发（critic / agent-quality-auditor）复核适配性与证据一致性。
- 未过门模板留在候选位，禁止落位项目级目录，并登记未通过原因与证据指针。

### ⑥ 登记
- 在 `.zcode/plan-templates/README.md`（或对应项目级模板目录 manifest）登记：模板名/适用类型/来源任务/审查日期/门记录指针。
- 记录复用入口：由 task-planner `init-session.sh` 原生发现，无需额外接线配置。
- 若仅保留候选，同步登记候选状态与阻塞门项，供后续激活续审。
- 登记完成后回链当前任务 findings/progress，保持证据闭环。

## 边界铁律

> general 兜底非静默默认：选用 general 须在计划「🔁 模板感知」区块登记理由（为何无适配 variant + 数据依据），终验对照（R3，2026-11-20）

- 禁直接写官方 `templates/`（含 `variant/`）；官方沉淀必须走 Rule 34.8 官方门 G1-G4，由权威流程承接。
- 禁覆盖核心 7 计划文件模板（`task_plan`/`verification`/`progress`/`findings`/`knowledge-brief`/`user-session-log`/`notepad-learnings`）；本技能仅产出项目级 `*-type.md`。
- 分析与预测必须有盘上证据（Rule 71）；无证据结论不得写入模板或登记为事实。
- 产出上限与查重：单次激活 ≤3 个候选/落位；动笔前先核对白名单与项目级既有模板，防重复沉淀与命名冲突。
- 零新脚本：纯 SOP 技能，不新增 `.sh`/hook/守卫/机器门；验证复用既有 `render_template` 与审查派发能力。

## 卫星路由：plan-template-advisor — 域=项目模板适配与沉淀生产（Rule 34.8/34.9 消费面）

本技能承接项目级模板「分析→预测→缺口→候选→审查→登记」SOP，为 Rule 34.8/34.9 的项目侧消费面；模板生命周期/选型与官方沉淀权威规则见 `plan-template-kit` `references/critical-rules-template.md`，机械发现与校验由 task-planner 脚本层负责（init-session.sh 项目级模板发现机制/check-template-type.sh 白名单校验/render_template fail-closed 契约）。命中项目模板适配、沉淀评估或缺口映射时加载本技能；涉及官方 variant 入库与四点同步时回退 `plan-template-kit`/task-planner 主路由。
