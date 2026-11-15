---
id: draft-task-intentresume-20261116
title: "（draft）task-intentresume-20261116 知识蒸馏待精炼"
tags: [draft, 未精炼]
sources: [plans/task-intentresume-20261116/knowledge-brief.md, plans/task-intentresume-20261116/findings.md]
updated: 2026-11-16
---

# （draft）task-intentresume-20261116 知识蒸馏（来源: plans/task-intentresume-20261116/knowledge-brief.md）

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 终验交付机械子动作末步为归档，当前无回切检查 | skills/task-planner/SKILL.md:130,136 | S1 必须在 outcome 判定后、归档前插入回切检查，不能破坏 Rule 81.1 顺序 |
| 终验交付智能子动作含 outcome 判定与 84.14 收尾回读 | skills/task-planner/SKILL.md:138,140 | 回切检查条款落点需与 outcome 判定后时序一致，措辞写明“outcome 判定后、归档前” |
| 前向 A→B 切换清单/通告/登记字段已在位 | skills/task-planner/SKILL.md:202,203,204 | S2 回切通告模板与 :203 对称共存，不替代前向模板；可复用 `[intent-switch]` 载体记回切状态 |
| Rule 94.4 明确旧计划封存待 plan-resume | skills/task-discipline/references/critical-rules-discipline.md:615 | S3 交叉锚必须衔接 `94.4` 与 `封存待 resume`，不改权威语义 |
| Rule 94 已有前向 intent-switch 交叉锚 | skills/task-discipline/references/critical-rules-discipline.md:619 | S3 在 :619 之后追加回切交叉锚，保持单入口指向 SKILL.md |
| plan-resume 具备交付终态触发与定向续推能力（只读） | /home/terry/.zcode/skills/plan-resume/SKILL.md:15,65-69 | yes 分支路由 `Skill("plan-resume")` 即可，无需改恢复实现；scope 禁含 plan-resume |
| 挂起候选双源：`[intent-switch]` 登记链 + INDEX 待处理区 | skills/task-planner/SKILL.md:204；plans/INDEX.md:8-57 | 回切检查需同时查 `旧=<id>` 登记与 `plans/INDEX.md` 待处理区定位 A |
| scope 硬约束：仅改 SKILL.md 与 discipline 两文件 | plans/task-intentresume-20261116/user-session-log.md#1（任务输入约束）；task_plan.md CA-1~CA-3 | VC-5 以 git diff 名单校验；禁止触碰 plan-resume 与其他受管文件 |
| VC 判据须与锚形态一致（教训） | discipline:607 为 `^### 94` 裸编号；既有 token 实测于 :619,708,:202-204 | verification 命令已按实测形态锁定 token；实施时按 CA token 落文案避免错配 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| skills/task-planner/SKILL.md | :130-145 | 终验交付机械/智能子动作：:136 Rule 81.1 归档，:138 outcome 判定，:140 84.14 收尾回读——S1 插入回切检查锚区（outcome 判定后、归档前） |
| skills/task-planner/SKILL.md | :193,202-204 | 意图切换快速判定卡、前向执行清单①-④、【计划切换通告】、`[intent-switch]` 最小字段——S2 回切通告模板邻近参照/对称落点 |
| skills/task-discipline/references/critical-rules-discipline.md | :607,615,619 | Rule 94 标题与 94.4“封存待 plan-resume”、既有 intent-switch 单入口交叉锚——S3 在 :619 后追加回切交叉锚 |
| skills/task-discipline/references/critical-rules-discipline.md | :708 | Rule 102 intent-switch 交叉锚（判定侧，只读对齐，不改语义） |
| /home/terry/.zcode/skills/plan-resume/SKILL.md | :15,33,65-69 | 恢复触发点③交付终态、旧计划封存待 resume、自主选 Top1 续推——只读参照，yes 分支路由目标 |
| plans/INDEX.md | :8-57 | 待处理/已完成索引与表结构——回切检查双源之一（待处理态佐证） |
| plans/archive/task-intentswitch-20261116/task_plan.md | :43-44,202-204 | 上承已交付锚点（A→B 切换清单/通告/登记）——方案衔接基线 |
| plans/task-intentresume-20261116/findings.md | 全文 | 本任务 M1-M12、R-1~R-4、S1-S3 方案与证据摘录（执行前必读） |
| plans/task-intentresume-20261116/task_plan.md | CA/VC/Phases | CA-1~CA-3 锁定插入 token、VC-1~VC-6 验收命令、S-unit 顺序与依赖 |

## §4 易错点与禁止假设清单
1. **禁止自动切回**：回切必须经用户确认（是否切回）；yes 才释放指针+路由 `Skill("plan-resume")`，no 登记保持挂起并写回切状态。自动切回=违规（违背 R1 与 94.3/E 类确认精神）。
2. **判据-产物形态错配判例**：写/改 VC 命令或条款 token 前再 grep 实测锚形态；discipline 用 `^### 94` 裸编号。实施文案须与 CA/VC 锁定 token 一致（`挂起计划回切检查（intent-switch 回切）`、`回切通告模板`、`intent-switch 回切` 等）。
3. **禁止改 plan-resume 与 scope 外文件**：主仓/deploy 位 plan-resume 均禁改；scope 仅 `skills/task-planner/SKILL.md`、`skills/task-discipline/references/critical-rules-discipline.md`。
4. **插入时序约束**：回切检查必须声明/落位于 outcome 判定后、归档前，且不得破坏 :136 Rule 81.1 归档与 84.14 收尾回读语义。
5. **Rule 94/102 权威语义不反转**：S3 仅追加交叉锚增量，`^### 94`/94.4 处置语义保持；Rule 102 本任务不改。
6. **[intent-switch] 载体复用**：不新建文件；回切状态写入既有载体（progress/Decisions 同源语义）并可审计。
7. **S-unit ID 纯数字**：S1/S2/S3，禁字母后缀（attest/check-plan-dispatch 约束）。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 2 插入位置破坏终验/归档顺序或 84.14/outcome 语义」(RPN 160)；「Phase 2 回切被实现为自动切回」(RPN 108)；「Phase 2 VC 判据 token 与最终措辞错配」(RPN 140)。

<!-- 精炼指引: 合并去重 → 主题化 → 补证据锚行号 → 去除 draft 前缀改名后重跑 kb-rebuild-index.sh -->
