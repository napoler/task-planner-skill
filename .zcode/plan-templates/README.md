# 项目级计划模板 manifest（task-planner-skill 仓）
<!-- 机制：init-session.sh 原生发现 .zcode/plan-templates/*-type.md 并入 template_type 白名单（Rule 34.9 沉淀位）；生产者=plan-template-advisor 技能（Rule 34.8/34.9） -->
<!-- [2026-11-25 task-json-template-docs] What: 补充说明项目级模板的 MD 教学视图与 JSON 结构化源双轨形态；Why: 33 个骨架已有对应 JSON 源，使用者需明确 MD 不是权威填写面，勾选须走 planctl。 -->

## 双轨形态（task-json-template-20261125）

- **MD 教学视图**：即下表所列 `*-type.md`（主仓骨架为 `skills/task-planner/templates/task_plan.md` 与 `templates/variant/*-type.md`），供人阅读与选型；每份 MD 第 3 行的 `JSON 模板源(task-json-template-20261125)` 注释指向自己的 JSON 对应源。
- **JSON 源**：`skills/task-planner/templates/json/<type>.template.json`，其中 `<type>` 取下表「类型标识」列（例：`rule-clause-cascade` → `rule-clause-cascade.template.json`）。结构化的 `sections`/`blocks` 落到 `plan-state.json` 的 `template_doc`/`template_checks` 后由 `planctl render` 派生 `task_plan.md`；勾选请用 `planctl set --section template_checks ...`，不要直接改 MD 骨架（render 会覆盖）。
- **映射预览**：`bash skills/task-planner/scripts/template-catalog.sh to-json --dry-run` 列出 33 条「骨架 → `<type>.template.json`」映射与字段计数，默认 dry-run 不写盘；只有显式 `--write` 才生成/覆盖 JSON 模板。

| 模板文件 | 类型标识 | 适用类型 | 来源任务 | 审查日期 | 门记录 |
|----------|----------|----------|----------|----------|--------|
| `rule-clause-cascade-type.md` | `rule-clause-cascade` | 本仓规则/条款级联修订（规则增款、子条插段、索引/纪元/卫星计数与多文件级联同步） | task-tpl-sediment-20261115（P2-S6 dogfood，首个项目适配模板） | 2026-11-15 | G1 PASS（39 行五结构块）/G2 PASS（smoke-g2-r2.md：project-level 选中+零残留）/G3 PASS（critic R1-R3 E 项）；G4 N/A（项目级免官方级联） |
