# 3c-template-cv — verification.md 插入交叉验证记录（Rule 108）

- 任务：worktree `verification.md` 模板插入「交叉验证记录（Rule 108）」步骤区块（clause-drafts §2 落位，剥离围栏）
- 目标文件：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/templates/verification.md`
- 草案来源：`/mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/clause-drafts.md` §2（:20-:25，剥离 ```md 围栏）

## T1 读目标与锚点定位
- Read 目标文件 :120-:140：锚行实际文与预期一致
  - `:127` `> **验证独立性**：终验核查动作（回归/抽查/对齐审查）由全新独立子代理执行，主进程仅编排与簿记——禁止以主进程既有上下文自测替代验收（Rule 33.3 独立验证延伸;2026-09-26 用户裁决）`
  - `:129` `---`
  - `:131` `## 5-Question Reboot Check`
- `grep -n '^## ' <目标>`（插入前）：4/10/34/80/86/103/109/112/131，共 9 段
- `grep -c '^## ' <目标>`（插入前）→ `9`
- `grep -c '交叉验证记录（Rule 108）' <目标>`（插入前）→ `0`
- clause-drafts §2 正文（:20-:25，剥离围栏）已逐字对照，内容与插入块一致

## T2 插入策略与防吞锚校验
- 采用 `old_string = "## 5-Question Reboot Check"`，`new_string = <CV 区块全文 + 空行> + old_string`（new_string 含 old_string 子串，防吞锚）
- 插入内容来源：clause-drafts §2（:20-:25）逐字复制（剥离外层 ```md 围栏行），既有行零改动（纯插入）

## T3 执行写入
- Edit 成功：`/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/templates/verification.md`

## T4 结构回读与验收
- 验收1：`grep -c '交叉验证记录（Rule 108）' <目标>` → `1` PASS
- 验收2：`grep -c '^## ' <目标>` → `10`（插入前 9，+1）PASS
- 验收3：插入位置正确（「验证独立性」引用行之后、「## 5-Question Reboot Check」之前，尾部回读段序完整）PASS
  - `grep -n '^## '`（插入后）含：`131:## 交叉验证记录（Rule 108）`、`138:## 5-Question Reboot Check`（原 131 后移）
  - `sed -n '120,150p'` 回读：`---` → CV 区块（标题+注释+表格）→ 空行后 `## 5-Question Reboot Check` → 5Q 表格完整保留

## T5 结论
- 仅修改 scope 内目标文件；主仓 skills/ 未触碰；既有行零改动（纯插入）。

```text
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/templates/verification.md(+7/-0)
evidence: /mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115/skills/task-planner/templates/verification.md:131 新增“## 交叉验证记录（Rule 108）”；:138 “## 5-Question Reboot Check”；grep -c '交叉验证记录（Rule 108）'→1；grep -c '^## ' 插入前9→插入后10；sed -n '120,150p' 回读显示CV区块位于验证独立性引用块/---之后、5Q之前且5Q表格完整
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-crossvalidate-20261115/subagent-state/3c-template-cv.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```