# Knowledge Brief — task-v120（任务知识简略要点）

## §1 任务速览与核心概念
- 任务一句话：complex-planner 以纯增量方式联入 task-planner 技能 2 处升级叙事（SKILL.md:349 + critical-rules.md:149），行数不变，回归后定向部署 2 文件×3 位。
- 背景/动机：task-v119 D4 遗留——用户 2026-10-03 选"2"授权落地。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 升级叙事 | SKILL.md 路由表「超限动作」列 + critical-rules 失败兜底链中"失败后升级到哪个 agent"的指引文本 |
| EX-1 videop1 fork | zcode 位 templates/variant=28 vs 仓 17 的分叉（待裁决）——禁整目录重部署的原因 |
| 定向部署 | 只 cp 改动的 2 个文件到 3 部署位，不 rm -rf 整目录 |
| hunk 距离 | git 按 diff 块合并；本任务改动行与 v118 改动区（CR 尾部/SKILL 2.5 区）距离远，可干净合并 |

## §2 已验证关键事实

| 事实 | 证据 file:line | 影响 |
|------|---------------|------|
| SKILL.md :349 原文末列 = `升级 ComplexProblemSolver` | sed -n 349p 一手提取（2026-10-03） | D2 diff 的 before 依据 |
| critical-rules.md :149 原文含 `回计划阶段重拆或升级 Complex Problem Solver;换道评估顺序=` | sed -n 149p 一手提取 | D3 diff 的 before 依据 |
| 两文件基线行数 SKILL.md=444 / critical-rules.md=483 | wc -l @ master a4bbd19 | VC-3 判据 |
| v118 scope 含同两文件（CR 尾部追加 Rule 46 / SKILL 2.5 区净增 ≤10 行） | plans/task-v118/task_plan.md 执行范围表 | hunk 距离远可干净合并；登记隔离决策 |
| zcode 位 variant=28 分叉待裁决 | memory task-planner-repo-deploy-flow [UPDATE 2026-10-02] | P3 禁 rm -rf，定向部署 |
| :339 debug 行不改 | D1 裁决 | complex-planner 不做调试 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/SKILL.md | :349 | 「规划 / 架构 / 编排」路由行，6 列表格末列=超限动作 |
| skills/task-planner/references/critical-rules.md | :149 | Rule 22.3 失败兜底链段（**失败兜底链不变**开头） |
| 3 部署位 | - | ~/.zcode/skills/task-planner、~/.claude/skills/task-planner、~/.config/opencode/skills/task-planner |

## §4 易错点与禁止假设清单
1. 禁止改 :339 debug 行 / 两文件其他任何行 / templates/** / scripts/**
2. 禁止整目录 rm -rf 部署（EX-1 fork 摧毁风险）
3. 部署前必须先方向审计（diff 部署位 vs master 基线，有未收编前向更新 = STOP 收编）
4. CR:149 标点随原文半角风格（`,` `;` `()`），SKILL:349 用全角（）随表格风格——两处风格不同是原文使然，勿"统一"
5. 行数必须不变（444/483）——行数定数断言零级联 + v118 合并撞面最小化
- FMEA RPN>100 兜底指针：无 >100 项（最高 48，逐行兜底已写入 task_plan FMEA 表）

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| S1（P1 code-assistant） | §2 + §4 + §6 | 无 |
| S2（P2 code-runner） | §3（worktree 路径派发时给出） | 无 |

## §6 交付物 diff 原文（S1 逐字执行依据）

### 改动 1：skills/task-planner/SKILL.md :349（表格末列行内追加，全角括号随 SKILL 风格）

before（该行当前全文）：
```
| **规划 / 架构 / 编排** | `architect` / `planner` / `task-orchestrator` | 继承主会话 | ❌ | ≤1 模块 | 升级 ComplexProblemSolver |
```
after（仅末列单元格追加）：
```
| **规划 / 架构 / 编排** | `architect` / `planner` / `task-orchestrator` | 继承主会话 | ❌ | ≤1 模块 | 升级 ComplexProblemSolver 或升级 complex-planner（高复杂度规划备用，GLM5.3/Opus 级） |
```

### 改动 2：skills/task-planner/references/critical-rules.md :149（行内插入括注，半角标点随原文风格）

before（片段）：
```
回计划阶段重拆或升级 Complex Problem Solver;换道评估顺序=
```
after（片段，仅插入括注）：
```
回计划阶段重拆或升级 Complex Problem Solver(高复杂度规划类亦可升级 complex-planner,GLM5.3/Opus 级备用);换道评估顺序=
```

### 自验命令（worktree 内）
```
grep -n 'complex-planner' <wt>/skills/task-planner/SKILL.md          → 1 处（:349）
grep -c '升级 ComplexProblemSolver' <wt>/skills/task-planner/SKILL.md → ≥1（保留证据，:339+:349 均 still）
grep -n 'complex-planner' <wt>/skills/task-planner/references/critical-rules.md → 1 处（:149）
wc -l <wt>/skills/task-planner/SKILL.md                              → 444
wc -l <wt>/skills/task-planner/references/critical-rules.md          → 483
awk -F'|' 'NR==349{print NF}' <wt>/skills/task-planner/SKILL.md      → 管道列数与改动前一致
```
