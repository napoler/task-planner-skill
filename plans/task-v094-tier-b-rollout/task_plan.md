<!-- template_type: rule-enhancement -->
# Task Plan: task-v094 Tier B 全 7 项落地（执行消耗结构性削减）
## Goal
> **[清账标注 2026-10-02 task-v115]** 本计划 Tier B 7 项已由后续任务实际落地（v095 主技能拆分/v096 模板自动记录/v097 工具面主动选择——各任务 memory 可查）；本计划不再独立推进，状态翻 complete 归档。原始 Goal 保留如下：
落地 v091 提案 Tier B 全 7 项（用户 2026-09-28 AskUserQuestion 裁决「全 7 项」=Rule 32.4 显式解禁），削减简单/复杂任务执行消耗：T-B4 直做通道 / T-B3 mini silent / T-B2 mini 单 Phase / T-B5 T5 免写 / T-B7 findings 放宽 / T-B6 CR 分级 / T-B1 只读分槽并行。质量门控判定力不削弱（G1-G10 护栏延续）。
## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|---------|---------|
| VC-1 | 7 项全部落地且每项带正反 selftest 夹具；全量 selftest ≥525 且 0 FAIL（双侧） | 逐脚本实跑求和 |
| VC-2 | 每项 36.4 语义变更在 critical-rules/SKILL 原文行位可 grep 到新旧对照锚 | grep 锚点 |
| VC-3 | T-B4 直做通道端到端可用（mini+≤30 行任务主进程直做→委派 stats 豁免不 violation） | 构造夹具跑 stats |
| VC-4 | T-B1 只写分槽：写类仍被槽锁拦截（enforce），声明只读并行获放行 | 正反夹具 rc |
| VC-5 | 干净上下文验证组对 7 项抽验全 PASS；部署三位 diff -r IDENTICAL；push 远端 | 验证组检查点+diff |
## 执行范围
skills/task-planner/{references/critical-rules.md,SKILL.md,scripts/check-*.sh,scripts/selftest-*.sh,templates/mini-lite-type.md,config.json(如需键)}；worktree 隔离；Rule 36.4 语义变更清单=提案 §四 Tier B 表+本次用户裁决，逐项 commit。
## Phases
### Phase 1: T-B4 直做通道+委派联动（Rule 14/25.3/25.4/check-delegation）
- **Status:** complete
- **Executor:** 主进程（白名单④用户显式效率指令+本任务即 T-B4 试点 dogfood；复杂槽锁改造超限仍派发）
### Phase 2: T-B3 mini silent + T-B2 单 Phase（Rule 28.2/mini-lite 模板/check-complete mini 分支）
- **Status:** complete
- **Executor:** 主进程（同上）
### Phase 3: T-B5 T5 免写 + T-B7 findings 放宽（22.8.2/check-3file-gate）
- **Status:** complete
- **Executor:** 主进程（同上）
### Phase 4: T-B6 CR 分级+验证流程合并（SKILL CR Gate 段/修改后验证流程）
- **Status:** complete
- **Executor:** 主进程（同上）
### Phase 5: T-B1 只读分槽并行（21.4 豁免子条+check-dispatch 槽锁只读放行+selftest）
- **Status:** complete
- **Executor:** 主进程（超限派发 executor）
### Phase 6: 全量回归+干净上下文验证+合并部署+push+簿记
- **Status:** complete
- **Executor:** 主进程（白名单①③）
## 🧭 Decisions Made
| 时间 | 决策 | 依据 |
|-----|------|-----|
| 2026-09-28 | Tier B 全 7 项采纳=Rule 32.4 显式解禁（否决出处均标注于提案 §四 Tier B 表） | 用户 AskUserQuestion 裁决「全 7 项」 |
| 2026-09-28 | 主进程直做为默认执行体 | 用户「十几个小时太离谱」效率指令（白名单④）；executor 派发 5-20min/个与任务目标自相矛盾 |
