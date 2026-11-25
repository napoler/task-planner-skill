<!-- template_type: mini-lite -->
<!-- [task-perf-default-mini 2026-11-24] What: mini-lite 适用面 ≤2→≤5 文件（缺省 mini 档）；Why: 缺省 mini 后 3-5 文件任务也走本模板，旧字面会误导为不适用。 -->
<!-- JSON 模板源(task-json-template-20261125)：skills/task-planner/templates/json/mini-lite.template.json — 本 MD 为教学/临时视图；权威源=plan-state.json 的 template_doc/template_checks；勾选请用 planctl set --section template_checks ... -->
<!-- template_meta: {"type": "mini-lite", "name": "轻量任务", "summary": "轻量任务（≤5 文件（缺省 mini 缺省档；task-perf-default-mini 2026-11-24）且≤15min 且单模块），跳过中/重仪式区块，单 Phase 实施加验收合一。", "scenarios": ["轻量任务", "单文件小改", "快修/微调", "15 分钟内小任务", "白名单内免派发任务"], "features": ["Goal", "Verification Contract", "执行范围限制", "单 Phase 实施加验收合一", "Subagent Handoff 表"]} -->
<!-- plan_tier: mini -->
<!-- 适用场景: 轻量任务（≤5 文件（缺省 mini 缺省档；task-perf-default-mini 2026-11-24） ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 触发关键词: 轻量/小改/单文件/快修/微调/15 分钟/小任务 -->
<!-- 推荐 subagent: 主进程直做（白名单②）或 executor(haiku) 单文件小改；无强制派发 -->
<!-- 38.3 区块白名单: 仅 Goal/VC/执行范围限制表/单 Phase/Handoff 表, 增其他仪式区块=模板违约(selftest-plan-tier 断言); [task-v094 T-B2] 2 Phase→单 Phase(实施+验收合一) -->
<!-- Rule 40.2 豁免声明（task-v097）: mini 档不加「🧰 工具选择与编排」区块——Rule 38.3 轻量模板区块白名单的自然延伸,mini 免计划期工具分析仪式;显式声明以防误判缺区块为违约 -->
<!-- Rule 42.5 豁免声明（task-v099）: mini 档不含「质量审查工具」配置行——Rule 38.3 轻量模板契约的自然延伸（同 40.2 豁免行范式） -->
<!-- Rule 42.6 豁免声明（task-v102）: mini 档不含「对齐审查」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5 豁免行范式） -->
<!-- Rule 44 豁免声明（task-v103）: mini 档不含「自动超时默认项」配置行——Rule 38.3 轻量模板契约自然延伸（同 40.2/42.5/42.6 豁免行范式） -->

# Task Plan: [轻量任务名]

## Goal
[一句话: 目标 + 「预估 ≤15min」（Rule 38.1 机器条件，必写 Goal 行）]

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | [轻量任务产物判定（可观察）] | [Read / 命令 / 测试] | [文件 / 输出] |
| VC-2 | [回归/无副作用判定] | [命令] | [输出] |

**终验规则**: 全部 VC 通过 → COMPLETE（VC ≥2，无 V-N 映射表；mini 档免逐 Phase V-N 映射，Rule 38.4②）

## ⚠️ 执行范围限制

| 改什么（scope_files ≤5 文件（缺省 mini 缺省档；task-perf-default-mini 2026-11-24）） | 禁碰什么 |
|-------|------|
| [文件 1] | [禁改文件 / 禁改范围] |
| [文件 2（可空）] | [禁改文件 / 禁改范围] |

约束: 单模块；任一机器条件不满足 → [plan-tier] MISMATCH 提示，改回 standard 全量模板

## Phases（固定 1：实施+验收合一，[task-v094 T-B2]；3-File 双条件在本 Phase 照常一次，Rule 19.2 降档）

### Phase 1: 实施+验收（合一）
- [1-3 条实施动作]
- [Read 回填复核 + 回归验证（与实施同 Phase 闭环）]
- **V-N:** VC-1, VC-2（总计 ≥2，允许集中映射）
- **Status:** pending
- **Executor:** 主进程（白名单②⑥登记）/ executor

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | （派发时填写；全程主进程填「无」） | | pending | | |

## 🧩 输出示例与格式契约（Rule 113 · 极简档）
> 本档至少 1 条：完整示例 + 同结构模板（字段可最小化，但结构必须真实可模仿）。

- 交付物 / 格式：article.json / JSON
- 完整示例：`{"title":"示例标题","count":3}`
- 可复用模板：`{"title":"<TITLE>","count":<INT>}`
- 对应 VC：VC-1
