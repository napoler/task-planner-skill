<!-- template_type: mini-lite -->
<!-- plan_tier: mini -->
<!-- 适用场景: 轻量任务（≤2 文件 ∧ 预估 ≤15min ∧ 单模块）——跳过中/重仪式区块，中/重任务禁用本模板（Rule 38.2） -->
<!-- 触发关键词: 轻量/小改/单文件/快修/微调/15 分钟/小任务 -->
<!-- 推荐 subagent: 主进程直做（白名单②）或 executor(haiku) 单文件小改；无强制派发 -->
<!-- 38.3 区块白名单: 仅 Goal/VC/执行范围限制表/2 Phase/Handoff 表, 增其他仪式区块=模板违约(selftest-plan-tier 断言) -->

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

| 改什么（scope_files ≤2） | 禁碰什么 |
|-------|------|
| [文件 1] | [禁改文件 / 禁改范围] |
| [文件 2（可空）] | [禁改文件 / 禁改范围] |

约束: 单模块；任一机器条件不满足 → [plan-tier] MISMATCH 提示，改回 standard 全量模板

## Phases（固定 2，每 Phase 仅 Phase 级一次 3-File 回填，Rule 19.2 降档）

### Phase 1: 实施
- [1-3 条实施动作]
- **V-N:** VC-1, VC-2
- **Status:** pending
- **Executor:** 主进程（白名单②登记）/ executor

### Phase 2: 验收
- [Read 回填复核 + 回归验证]
- **V-N:** VC-1, VC-2
- **Status:** pending
- **Executor:** 主进程

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要 | checkpoint 路径 |
|---|--------------|----------------|------|---------|----------------|
| 1 | （派发时填写；全程主进程填「无」） | | pending | | |
