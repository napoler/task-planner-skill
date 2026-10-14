---
task_id: task-batch-report-tmpl-fix
template_type: general
plan_tier: standard
created: 2026-10-13
session_id: dwfdwfrun6b3716ca917e4c8bb2fccefffb4
---

# Task Plan: task-batch-report-tmpl-fix

## Goal

修复 `skills/task-planner/templates/batch_report.md` 第 5 行断裂的相对路径引用（R-17）：`references/batch-quality-gate.md` 实际位于 `skills/task-discipline/references/` 而非 `skills/task-planner/references/`（后者无此文件），改为指向真实位置的绝对路径写法，符合「路径引用必须使用绝对路径」规范。

## Decisions Made

| 决策 | 理由 |
|------|------|
| 绝对路径采用 `${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/../task-discipline/references/batch-quality-gate.md` 写法 | 对齐既有跨 skill 引用惯例（subagent_dispatch.md:2/76/100 引用 task-dispatch 的同款写法），可从任意 cwd 解析 |
| R-13 计数漂移（37≠35）不修改任何文件 | 问题描述明示「非该文件的问题而是系统级漂移」，多出匹配在 `deprecated.md` 与 `session-handoff.md`，超出本任务文件范围（scope_files 单一），按漂移纪律不越权修改 |

## 执行范围限制

| 层级 | 范围（禁止超出） |
|------|----------------|
| 本轮唯一修改文件（scope_files=1） | `skills/task-planner/templates/batch_report.md`（仅第 5 行注释，1 行最小化修改） |
| 会话重入追加（36.2 归因登记，2026-10-13） | `skills/task-planner/templates/subagent_dispatch.md`（行 22 输入标题 R-08 + 行 40 知识储备标题 R-13，共 2 行最小化修改；git 既有工作树变更归属同批 workflow） |
| 模板审计修复追加（36.2 归因登记，2026-10-13） | `skills/task-planner/templates/variant/memory-hygiene-type.md`（R-17 绝对路径 + R-25 精简至 ≤100 行 + R-29 调研需求三态，由模板修复员子代理执行） |
| 模板审计修复追加（36.2 归因登记，2026-10-13） | `skills/task-planner/templates/variant/motion-camera-type.md`（R-10 执行范围限制区块 + R-13 知识储备统一标题 + R-17 绝对路径 + R-23 execution_lane + R-25 ≤100 行 + R-29 调研需求三态，由模板修复员子代理执行） |
| 明确禁止触碰 | `templates/deprecated.md`、`templates/session-handoff.md`（R-13 系统级漂移，非本任务范围）；其他任何 skill 文件 |
| 本计划自身 | `plans/task-batch-report-tmpl-fix/**`（hatch: 为通过哨兵门而创建的最小计划） |

## Phases

### Phase 1: 修复 batch_report.md:5 断裂相对路径

- **Status:** complete

**目标**：将第 5 行 `<!-- 详见:references/batch-quality-gate.md §三/§四 -->` 的相对路径改为绝对路径写法（对齐 subagent_dispatch.md:2 的 `${TASK_PLANNER_ROOT:-...}/../task-discipline/references/...` 惯例），修正所指位置并满足 R-17。

**动作**：
1. Edit `skills/task-planner/templates/batch_report.md` 第 5 行（单行替换，不动其他行）✅ 2026-10-13 已执行（check-scope 预演 rc=0，check-skill-modify warn 档放行）
2. 验证：修改后 grep + git diff 复核（见 VC）✅
3. 确认不再含裸相对路径前缀 ✅

**验收**：第 5 行含 `${TASK_PLANNER_ROOT:-` 前缀且路径指向 `/skills/task-discipline/references/batch-quality-gate.md`（该文件已确认存在：`ls skills/task-discipline/references/batch-quality-gate.md` 成功，13128 字节）；`skills/task-planner/references/` 下 6 文件不含此文件故不走该目录。

### Phase 2: 复核与交付

- **Status:** complete

**目标**：复核修复生效并确认无越权修改。

**动作**：
1. git diff 复核（改动仅第 5 行 1 insertion/1 deletion）✅
2. `git status --short` 确认无越权 ✅（见下）

**验收**：仅 batch_report.md + 本计划目录变更；知识储备章节保持原位不动（grep -c = 1）。

## Verification Contract

| VC | 验证 | 结果 |
|----|------|------|
| V-1 | `grep -n 'batch-quality-gate.md' skills/task-planner/templates/batch_report.md` → 仅 line 5 且含 `${TASK_PLANNER_ROOT:-` 前缀；`grep -nE '(^|[^/])references/batch-quality-gate'` 无命中 | ✅ PASS |
| V-2 | `ls skills/task-discipline/references/batch-quality-gate.md` → 存在（2026-10-13 22:58, 13128B） | ✅ PASS |
| V-3 | `grep -c '^## 📚 必要知识储备'` = 1（R-13 白名单标配保持） | ✅ PASS |
| V-4 | `git diff --stat` → 1 file changed, 1 insertion(+), 1 deletion(-) | ✅ PASS |

## Notes

- 本轮为单文件单行修复（1 line），改动可逆（git restore）。
- 第 5 行是 HTML 注释行（`<!-- -->`），属于模板可自由定制区（R-15 注释段自由度）。
- R-13 计数 37 vs 35 的系统级漂移已定位证据（deprecated.md / session-handoff.md），建议由 run owner 另行处置，不在本轮 scope。
- [2026-10-13 会话重入] subagent_dispatch.md 批量修复进度：R-13 已修复（行 40 标题统一为 `## 📚 必要知识储备` 全库唯一 grep 锚，后缀说明移入下行注释保留信息）；R-08 修复中（行 22「计划三文件必传」→「计划四文件必传」，对齐行 23-26 四文件清单与行 26「四文件契约第 4 文件」注释）。
