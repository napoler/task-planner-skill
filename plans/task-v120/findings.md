# Findings & Decisions

## Requirements
- 用户指令（2026-10-03，对 v119 交付总结下一步建议选"2"）：落地 D4 遗留——task-planner SKILL.md:339/349 + critical-rules.md:149「升级 ComplexProblemSolver」叙事联动 complex-planner（用户授权技能本体语义扩展）

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| 3 处锚点原文 | sed -n '339p;349p' SKILL.md + sed -n '149p' critical-rules.md（一手） | ☑ | §Research R1 |
| v118 scope 声明 | plans/task-v118/task_plan.md 执行范围表 | ☑ | §Research R2 |
| EX-1 fork | memory task-planner-repo-deploy-flow UPDATE 段 | ☑ | §Research R3 |
| 基线行数 | wc -l（444/483 @ a4bbd19） | ☑ | §Research R4 |

## Research Findings

- **R1（一手提取 2026-10-03）**：SKILL.md :339 = debug 行超限动作 `升级 ComplexProblemSolver`；:349 = 规划行超限动作同文；critical-rules.md :149 = 失败兜底链 `…禁止同法重试(联动 Rule 7 三击协议),回计划阶段重拆或升级 Complex Problem Solver;换道评估顺序=现成方案(22.3.0)→子代理隔离→拆解逐个击破(22.3.0b)[task-v113];`——CR 侧原文用半角标点。
- **R2（v118 scope 一手核对）**：v118 允许面 = critical-rules.md（追加 Rule 46 块）+ check-dispatch.sh + selftest + subagent_dispatch.md + SKILL.md（净增 ≤10 行：摘要行+2.5 措辞+索引行）——与本任务改动点（:349 行内 / CR:149 行内）**hunk 距离远**，且本任务行数不变，git 合并冲突概率低；真撞由 v118 会话按其流程处置。
- **R3（EX-1）**：zcode 位 templates/variant=28 vs 仓 17 分叉待裁决 → P3 部署禁整目录 rm -rf，仅定向 cp 改动文件。
- **R4（基线）**：master a4bbd19 上 SKILL.md=444 行、critical-rules.md=483 行——两处均为行内追加不换行 → 行数不变（VC-3）。
- **R5（设计裁决）**：:339 debug 行不加 complex-planner——该 agent 规划不调试，加了误导路由（D1，用户"2"授权的合理解释范围）。
- **R6（D1 后基线复测 2026-10-03 05:2x）**：master 间隙前进 a4bbd19→53936ec（v118 df7e427 合并+CR 销项、v121 三锚预扩 13968d7）；一手复测两文件行数仍 444/483、锚点仍 :339/:349/:149 原文逐字未动 → VC-1/2/3 判据无漂移；仅 selftest 面 42→43 脚本（v118 新增 dispatch-grain），VC-4 基线上移（D7 B 类修订，重锁 SHA 269b8fd6）。
- **R7（P1 S1 产出一手复核 05:35）**：worktree 两行改动与 D2/D3 after 逐字一致（SKILL:349 末列含 CPS 保留+complex-planner 追加、CR:149 括注插入原句保留）；行数 444/483 不变；:339 debug 行未动。VC-1/2/3 全过。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 纯增量改法（子句追加/括注插入，零删除） | Rule 36.5 默认纯增量；CPS 保留=既有升级路径零回归风险；v117 教训（口径改动撞守卫）的规避=不动 frontmatter/口径键+行数不变 |
| 定向部署 2 文件×3 位 | EX-1 保护 + 写入最小化 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| v118 与本任务同文件并行 | hunk 距离远+行数不变；登记隔离决策与 FMEA 40 分项；master 先落不回退 |

## Resources
- v119 交付档案：plans/task-v119/delivery-summary.md（D4 遗留出处）
- complex-planner 规格：plans/task-v119/knowledge-brief.md §6

## Visual/Browser Findings
-（无）
