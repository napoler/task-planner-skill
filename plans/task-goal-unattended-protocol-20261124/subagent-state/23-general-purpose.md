# checkpoint — sub:23-general-purpose（E31 / E32，S21）

工作路径（worktree）：/mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124

## 里程碑

- [E31] DONE — `skills/plan-template-kit/references/template-mapping.md:305`：`decision-arbiter(GLM-5.3)` → `decision-arbiter(GLM-5.4)`；改后行已回读，新串计数 1（第 305 行），旧串计数 0；`git diff --stat` = 1 行增 1 行删。
- [E32] DONE — `skills/task-dispatch/references/critical-rules-dispatch.md:245`：`质量争议升级 decision-arbiter GLM-5.3 强档）` → `质量争议升级 decision-arbiter GLM-5.4 强档）`；同行「复检重档（GLM5.3/Opus 级）」保持不动（回读/grep 证）；新串计数 1（第 245 行），旧串计数 0；`git diff --stat` = 1 行增 1 行删。

## 自检输出（原样保存）

```text
--- E31 new ---
305:| decision-arbiter | 判断/裁决组 | 裁决执行体路由（Rule 69 触发点 T1-T6：方案终裁/失败定级/验收争议/DRIFT 处置/CR 分歧） | 高频轻量判定（drift-checker 管辖）、产物挑刺（critic 管辖）、机械判断（41.3 直做） | decision-arbiter(GLM-5.4) |
--- E31 old count ---
0
--- E32 new ---
245:103.4 **复检升档映射与封顶**：按 96.2 三档表——轻档（haiku-1）→复检中档（sonnet-1）；中档（sonnet-1）→复检重档（GLM5.3/Opus 级）；重档→封顶同档（独立上下文已消除污染增量；质量争议升级 decision-arbiter GLM-5.4 强档）。派发 model 参数显式指定，禁降档复检；22.3 provider 降档链仍适用、降档登记 scaling-redispatch。复检档位按计划期声明的执行体档位计算（22.3 provider 降档属运行时应变，不拉低质检基准）；decision-arbiter 的裁决产出为终审形态，不再派复检（重档封顶+独立裁决体已含独立性增量），其结论争议由用户终裁（69.1 T6），禁复检递归。
--- E32 old count ---
0
--- E32 generic tier untouched ---
245:103.4 **复检升档映射与封顶**：按 96.2 三档表——轻档（haiku-1）→复检中档（sonnet-1）；中档（sonnet-1）→复检重档（GLM5.3/Opus 级）；重档→封顶同档（独立上下文已消除污染增量；质量争议升级 decision-arbiter GLM-5.4 强档）。派发 model 参数显式指定，禁降档复检；22.3 provider 降档链仍适用、降档登记 scaling-redispatch。复检档位按计划期声明的执行体档位计算（22.3 provider 降档属运行时应变，不拉低质检基准）；decision-arbiter 的裁决产出为终审形态，不再派复检（重档封顶+独立裁决体已含独立性增量），其结论争议由用户终裁（69.1 T6），禁复检递归。
--- git diff --stat ---
 skills/plan-template-kit/references/template-mapping.md    | 2 +-
 skills/task-dispatch/references/critical-rules-dispatch.md | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
--- status ---
 M skills/plan-template-kit/references/template-mapping.md
 M skills/task-dispatch/references/critical-rules-dispatch.md
```

通用纪律核对：old 串与盘上逐字一致，无标点/空白调整（无 evidence  adjustment 项）；未插段、未重排、未格式化其他文字；两文件改动行已逐行回读并与 `git diff` 对照；未改机器门/selftest/agent 定义/运行位；未 commit/push/merge/stash。

## 最终结论

status: done
acceptance: 2/2 pass — [E31:PASS E32:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/plan-template-kit/references/template-mapping.md(+1/-1); /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/task-dispatch/references/critical-rules-dispatch.md(+1/-1); /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/23-general-purpose.md(created)
evidence: E31 — /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/plan-template-kit/references/template-mapping.md:305 → `decision-arbiter(GLM-5.4)`，新串=1、旧串=0；E32 — /mnt/data/dev/task-planner-skill/tmp/worktrees/task-goal-unattended-protocol-20261124/skills/task-dispatch/references/critical-rules-dispatch.md:245 → `质量争议升级 decision-arbiter GLM-5.4 强档）`，新串=1、旧串=0，同行 `复检重档（GLM5.3/Opus 级）` 未动；`git diff --stat` 原始行： skills/plan-template-kit/references/template-mapping.md    | 2 +- ; skills/task-dispatch/references/critical-rules-dispatch.md | 2 +- ; 2 files changed, 2 insertions(+), 2 deletions(-)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/23-general-purpose.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
