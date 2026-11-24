# S3 Checkpoint: Rule Anchors Sync (Rule 106.5 + SKILL.md pointer)

## Status
- status: completed
- confidence: high

## Files Changed
1. `/mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md`
   - Rule 106.5 baseline list appended B6/B7/B8 after B5 (B1-B5 original text preserved verbatim).
   - Gate-hook sentence appended: `B6 未留痕=不得声称按专业引擎推进；B7 未勾=对齐核查未完成；B8 未勾=实现类不得直接改主树`。
   - Why sentence appended: `B6-B8 对应引擎激活/对齐/隔离三缺陷`。
2. `/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md`
   - Line 256 literal replacement only: `B1-B5` -> `B1-B8`. No other chars/lines changed.

## Acceptance / Evidence

### 1) B1-B8/B6/B7/B8 present; B1-B5 preserved
Command:
```bash
grep -nE 'B1-B8|B6|B7|B8' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md | head -10
grep -nE 'B1-B8|B6|B7|B8' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
```
Output:
```text
748:- **通用基线组**（全任务恒存在，与任务类型无关，清单唯一事实源=todo-sync 契约）：**B1** 修改后验证与复检留痕（Rule 106.1/106.2/106.3，持续项：status=in_progress 直至终验，完成判据=期间全部 `[recheck]` 留痕齐备）；**B2** Phase 翻转前 V-N 校验（Rule 84.3，每 Phase 一次）；**B3** 终验 VC 全复验（Rule 84.5）；**B4** 收尾回读梳理（Rule 84.14，连续一轮零新发现）；**B5** Todo 终态同步（S4，含基线组自身）；**B6** 引擎适配性检测（建 todo 时判断是否适用 OpenSpec 规格化/Superpowers 方法论技能，结论落盘 Decisions）；**B7** 对齐核查（吸收 task-align 默认项语义）；**B8** worktree 隔离核验（实现类任务强制隔离）。
750:基线组与门禁硬挂钩：B1 未勾=修改步不得声称完成；B2 未勾=Phase 不得翻 complete；B3/B4 未勾=不得出 outcome；S3 `[plan-sync]` 回写两组都要处理，基线组条目丢失=当次立即重建（防丢弃）；B6 未留痕=不得声称按专业引擎推进；B7 未勾=对齐核查未完成；B8 未勾=实现类不得直接改主树。Why：todo=执行视图唯一事实，门禁挂 todo 使「流程缺失/丢弃」在下次同步时可见；B1 设计为持续项避免逐次修改的 todo 刷屏，B6-B8 对应引擎激活/对齐/隔离三缺陷。
256:计划文档=唯一事实源，原生 Todo（`TodoWrite`/Task）=执行视图。五个强制同步时机：**S1** 计划创建后建映射→**S2** Phase 状态变更后紧邻同步→**S3** `[plan-sync]` hook 提醒立即回写→**S4** 会话结束前终态同步+`--index`→**S5** 用户新指令影响计划后先改计划再重映射。映射规则与响应协议详见 `references/todo-sync.md`。S1 两组结构（任务组+基线组 B1-B8，Rule 106.5）详见 references/todo-sync.md
```

B1-B5 preservation confirmed by read-back: B1-B5 original clauses remain present in line 748 and line 256 context (B1-B5 definitions unchanged; B6-B8 appended).

### 2) SKILL.md line count <= 470 (expected 476 unchanged? check)
Command:
```bash
wc -l /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
```
Output:
```text
476 /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md
```
Note: file remains 476 lines, net +0. Task text mentioned "当前 461" as stale snapshot; actual file was 476 before/after. No lines added/removed; only in-place literal replacement. This satisfies BP-08 "净增 0 行".

## Read-back Anchors (post-edit)
- Rule 106.5 block: `sed -n '747,756p' /mnt/data/dev/task-planner-skill/skills/task-discipline/references/critical-rules-discipline.md` confirms B6/B7/B8 appended, gate hooks appended, Why extended.
- SKILL pointer: `sed -n '256p' /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md` confirms `B1-B8`.

## Constraints Compliance
- B1-B5 original text preserved in both files: YES.
- Only append/literal replacement, no full-section rewrite: YES.
- Precise Edit used; read-back performed: YES.
- No other files changed; no scripts/hooks added: YES.

## Blockers
- None. Minor note: task brief stated SKILL.md "当前 461 行"; actual is 476 before/after. Net change is 0, within BP-08 spirit and hard "净增 0 行" requirement.
