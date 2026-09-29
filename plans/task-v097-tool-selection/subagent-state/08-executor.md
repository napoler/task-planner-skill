# 08-executor checkpoint（P4-S2: template-guide 区块定制指南 + plan-writer 契约义务行）

执行时间: 2026-09-30 | 执行体: executor | worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection
禁 git commit/add —— 已遵守（仅 git diff/status 只读查询）。

## 步骤记录

### 1. 定位插入点 + 改前基线
- 场景最大号: `grep -n "场景" template-guide.md` → 场景 1..4（145/157/171/208 行），最大=4 → **N=5**
- 插入点: §六 Checklist（223 行 `## 六、定制后验证 Checklist`）之前、场景 4 代码块（219 行 ``` 收口）之后
- plan-writer.md 改前锚计数: `grep -c '问题解构四问'`=**1**（118 行表格行）; `grep -c '纯数字'`=**1**（119 行 s_unit_id 行）
- 插入点: 「掌握的技能」bullet 列表末尾=44 行 knowledge-brief bullet 之后、46 行 `## 模板类型` 之前

### 2. 插入执行（各只做插入，既有行零改动）
- 文件 1: 在场景 4 代码块收口与 `---` 之间插入「### 场景 5: 「🧰 工具选择与编排」区块定制（Rule 40 — task-v097）」全文（何时填/字段说明 3 条/定制红线 5 条，内容与任务书逐字一致）→ 新标题落 221 行，区块 221-232 行，§六 标题后移 234 行，diff 纯 +11 行
- 文件 2: 「掌握的技能」末 bullet 后追加 1 行「- 工具选择与编排区块（Rule 40.2,task-v097）: …」（内容逐字一致）→ 落 45 行，diff 纯 +1 行

## 验收实测输出（worktree 内执行）

1) `grep -c '工具选择与编排' skills/plan-template-kit/references/template-guide.md` → **1**（仅 221 行标题命中; 226 行正文为「工具面表 3 列」等措辞，不含该子串。**低于任务书验收线 ≥2**）
   佐证: `grep -n '工具选择与编排' template-guide.md` 输出仅 1 行:
   `221:### 场景 5: 「🧰 工具选择与编排」区块定制（Rule 40 — task-v097）`
2) `grep -c '工具选择与编排区块' skills/task-planner/companion/agents/plan-writer.md` → **1** ✅（45 行）
3) 锚零破坏: `grep -c '问题解构四问'` → 1（改前 1 = 改后 1）✅; `grep -c '纯数字'` → 1（改前 1 = 改后 1）✅
4) selftest:
   - `bash skills/task-planner/scripts/selftest-methodology.sh` → `Total: 16 PASS=16 FAIL=0`（M-16 PASS plan-writer 问题解构四问契约行）
   - `bash skills/task-planner/scripts/selftest-conclusion-discipline.sh` → `Total: 24 PASS=24 FAIL=0`（CD-21/CD-22 PASS 纯数字契约行）
5) `git diff --stat` → 3 files changed, 27 insertions(+):
   - template-guide.md +11（本步）
   - plan-writer.md +1（本步）
   - template-mapping.md +15（S1 存量 §十 工具选择映射节，非本步产生）
   `git status --short` 亦为 M×3 同上。本步恰 2 文件 ✅

## 问题上报
- **验收 1 口径冲突**: 任务书插入内容全文逐字插入后，「工具选择与编排」在 template-guide.md 仅出现 1 次（标题行），达不到「≥2（场景标题+正文）」的预期。根因=插入内容正文各 bullet 未重复该子串（正文用「工具面表」「本区块」等表述）。插入内容本身是任务书规定的逐字文本，executor 不得自行改写插入内容凑数——**待协调方裁决**: (a) 将验收 1 修正为 ≥1; 或 (b) 修订插入内容（标题外再含一次该子串）后重新派发。当前两文件插入均逐字忠实任务书。

## 结论
- 插入: 2/2 完成，逐字一致，纯插入零删除（git diff 全为 + 行）
- 验收: 2/3/4/5 通过; 1 实测 1 < 2（口径问题，已上报）
- checkpoint 完成，无未落盘中间状态
