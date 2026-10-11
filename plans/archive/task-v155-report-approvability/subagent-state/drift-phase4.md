# Drift Checkpoint — Phase 4 偏移检查（Rule 61 载体 22.3.1 改派执行）

- **时间**: 2026-10-10
- **Phase**: 4（触点修补 B — 模板面）
- **检查性质**: 只读 + 检查点（Phase 4 complete 前检查）
- **需求锚（Rule 51.1a）**: 不适用（偏移检查单元）

## 三锚

- **① Goal**: task-planner 技能全工作流呈报触点强制 Rule 70 四要素 + 机器守护
- **② 近期动作**: worktree 内四模板文件呈报规格补全（S5/S6/S7）
- **③ scope**: 本 Phase 仅允许 `skills/task-planner/templates/` 下 4 个文件（task_plan.md 三处行内追加 /:100/:135/:337；batch_report.md :6 注释行 +1；variant/image-type.md :88 +1；variant/multiview-ref-type.md :27 +1）

## 检查证据

### 1. worktree 未提交改动 scope 核对

命令：`git -C /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability diff --numstat`

```
1	0	skills/task-planner/templates/batch_report.md
3	3	skills/task-planner/templates/task_plan.md
1	0	skills/task-planner/templates/variant/image-type.md
1	0	skills/task-planner/templates/variant/multiview-ref-type.md
```

判定：恰好 4 文件，与 task_plan.md:108「执行范围限制」模板面允许列表逐一对应，无越界文件；无其他 Phase 3 残留未提交改动（Phase 3 三文件已提交）。

### 2. Rule 70 与四要素词抽验

| 文件 | 行 | 内容摘要 | 材料包对照 |
|------|----|---------|-----------|
| task_plan.md | :100 | 下一步建议行末追加「（按 Rule 70：对象路径+看点+动作）」 | T7 逐字 |
| task_plan.md | :135 | 先问用户行末追加「（问询按 Rule 70 四要素）」 | T7 逐字 |
| task_plan.md | :337 | FMEA 填写规则行末追加「（AskUser/呈报按 Rule 70 四要素）」 | T7 逐字 |
| batch_report.md | :6 | HTML 注释行「面向用户呈报时按 Rule 70 四要素：失败/跳过单元逐项清单（编号+简介）+产物绝对路径+看点（失败原因列）+动作（重试/放弃+默认项）」 | T8 逐字 |
| image-type.md | :88 | 「审查地址清单规格（Rule 70 四要素）：逐件清单须逐件附编号+一句话简介（①）与看点（看什么：主体一致性/构图缺陷）（③）与动作（选定/重抽+默认项）（④）；仅有地址缺①③④=未送审」 | T9 逐字 |
| multiview-ref-type.md | :27 | 同 T9 措辞（Rule 70 四要素 + ①③④） | T9 逐字 |

### 3. 纯追加零破坏核验

- batch_report.md / image-type.md / multiview-ref-type.md：`+1/-0` 纯新增行
- task_plan.md：`+3/-3` 为行内追加（word-diff=porcelain 确认三处均为既有行行末追加，无行替换/删除语义；既有文本逐字保留）

### 4. 既有行语义零改动

task_plan.md word-diff 显示三处修改点均为「既有文本 + 追加括号注」形态：
- :100 `（not-solved 必填：可执行的下一步）` → `（not-solved 必填：可执行的下一步）（按 Rule 70：对象路径+看点+动作）`
- :135 `先问用户` → `先问用户（问询按 Rule 70 四要素）`
- :337 `两者不互相替代。` → `两者不互相替代。（AskUser/呈报按 Rule 70 四要素）`

## 检查结论

- verdict: **ALIGNED**
- 依据：未提交改动恰好 4 文件且全部在 scope 允许列表内；Rule 70 与四要素词六处全部命中且与 T7/T8/T9 材料包逐字一致；纯追加零破坏，既有行语义零改动。

## 最终结论

```
status: done
acceptance: 2/2 pass — [1:PASS scope 恰配（numstat 恰好 4 文件全在允许列表） 2:PASS Rule 70+四要素六处命中且材料包逐字一致]
files: /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/templates/task_plan.md(+3/-3), /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/templates/batch_report.md(+1/-0), /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/templates/variant/image-type.md(+1/-0), /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/templates/variant/multiview-ref-type.md(+1/-0)
evidence: git diff --numstat→恰 4 文件（1/0,3/3,1/0,1/0）；grep -n "Rule 70"→task_plan.md:100/:135/:337, batch_report.md:6, image-type.md:88, multiview-ref-type.md:27；word-diff=porcelain→三处行内追加既有文本逐字保留；task_plan.md:108 允许列表逐一对应对账
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/drift-phase4.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
