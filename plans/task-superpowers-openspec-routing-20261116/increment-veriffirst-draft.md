# #2 增量设计稿：验证前置定位（等待前计划 merge 后执行 — 本文件为续跑方 scratch，不属前计划六文档体系）

> 状态：DESIGNED-NOT-EXECUTED（2026-11-16 02:48 主进程落盘）
> 触发条件：前计划 task-superpowers-openspec-routing-20261116 的 Phase 5 完成（master 含 wt 分支 merge commit + worktree 清理 + 部署位同步收尾）后启动本增量。
> 理由：前计划已 attest 锁定（SHA dd1fa197）且 R1-R5/VC-1..7 不含 #2 验证前置诉求（其 task_plan 02:41:55 定稿早于 #2 入档 02:42:06，写入方未见过 #2）；为避免双写竞态，#2 以独立 mini 增量落地，落点与其三载体同文件、执行序在其 merge 之后。

## 增量任务定义（mini 档，plans/task-veriffirst-20261116/）
- **Goal**: 在 spec-mode.md 落「验证前置定位」段（目标/验证前置驱动宣言+三载体映射+反模式），SKILL.md:65 Spec 模式行尾追加指针（PREFIX-OK 纯增量），与 §1b 复杂度路由决策表互引成「定位层+路由层」融合闭环——响应用户 #2 原话（锚=user-session-log.md#2，前计划专档）。
- **R1**（[目标]，#2 逐字锚节选）:「就是将将验证放在前置，就是验证脚本或者是验证规则规范放在前置，确保就是在整个任务开始的初期，在不偏移的情况下，就确定好目标以及评审方案。而不是后期执行，在任务偏移之后，出现了执行，然后再去编写验证」
- **范围**: ①skills/task-planner/references/spec-mode.md（新增段）②skills/task-planner/SKILL.md（:65 行尾追加，禁改既有文字）③可选：skill-collaboration.md 初筛段加一行验证依赖信号（若前计划初筛段已有覆盖语义则跳过并登记）。master 直改（§十一 11.5② 纯文档豁免）或从已 merge 后 master 建 worktree（以届时主仓 clean 状态定）。

## spec-mode.md 新增段全文（插入位=§1b 之后；届实测 post-merge 文件再定节号，若 §1b 后已有 §2 则本段为 §1c 或追加至文件尾作 §5）

```markdown
## 1c. 验证前置定位（2026-11-16 用户 /goal 锚定）
> **定位**：本项目所有任务按「目标驱动/测试驱动」运行——任务初期先定目标+边界+验证方案（验证脚本/规则规范前置），再持续实现；**禁止「先执行、偏移后补验证」**（用户原话锚：后期执行偏移后再编写验证=「可能会存在严重的隐患」，plans/task-superpowers-openspec-routing-20261116/user-session-log.md#2）。

**验证三载体映射（调用不复制，R6 铁律同源）**：
| 阶段 | 验证载体 | 调用形态 |
|------|---------|---------|
| 计划面（目标+评审机制前置） | task-planner 自有：R 锚定（51.1）+VC/V-N 契约（51.2/84）+attest 锁定 | 本技能既有链路，无外部调用 |
| 执行面（先测后写） | Superpowers `test-driven-development` / `verification-before-completion` | `Skill("test-driven-development")`（实现/修 bug 前）、`Skill("verification-before-completion")`（完成声称前） |
| 收口面（变更收口验证） | OpenSpec `openspec-verify-change` | `Skill("openspec-verify-change")`（变更归档前三维验证） |

**与 §1b 路由的关系**：验证依赖强度=§1b 决策表的信号修正项——强验证依赖（可执行验收/规格留存）→ 优先 OpenSpec（verify 阶段前置）或 TDD 嵌入；弱验证单点任务 → 本技能 VC 契约直执行。
**反模式**：❌ 任务偏移后才补写验证脚本/验收标准（后期补验证）；❌ 以「先跑起来再说」跳过初期目标+评审机制设定。
```

## VC 判据（执行期落 verification.md）
- grep -q "验证前置定位" skills/task-planner/references/spec-mode.md
- grep -q "后期补验证" skills/task-planner/references/spec-mode.md
- grep -q "test-driven-development" skills/task-planner/references/spec-mode.md
- grep -q "openspec-verify-change" skills/task-planner/references/spec-mode.md
- grep -q 'spec-mode.md` §1c' skills/task-planner/SKILL.md（指针行尾追加后）
- 回归：run-selftests.sh FAIL 无新增（前计划 Phase 5 后的 master Total 为基线）
- 部署位同步：spec-mode.md/SKILL.md × 4 位 diff=0（逐对 diff 判向后覆盖）

## 执行序（验证前置自律——本增量自身按此模式跑）
1. 采基线（master Total FAIL）
2. init mini 计划目录（plan_tier:mini）+R/VC 落档
3. 主进程直写两载体（例外理由② 计划系统文件维护；PREFIX-OK 纪律）
4. 回归对照+部署位同步+收尾簿记
