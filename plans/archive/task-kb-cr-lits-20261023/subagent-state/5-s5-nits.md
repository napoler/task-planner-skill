# S5 检查点：定点 nit 修复（L-8：templates/task_plan.md 路径基准混用）

- 任务：task-kb-cr-lits-20261023 / Phase 1 S-unit S5
- worktree：/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023（分支 wt/task-kb-cr-lits-20261023，基 master 923aa54）
- 范围：仅 skills/task-planner/templates/task_plan.md；未 commit；未碰其他文件

## 1. diff 摘要

单行改动（原 :355，改后仍 :355，无行数增减）：
- 条件式描述 `项目存在 scripts/kb-sync-from-plan.sh 知识库机制` → `项目存在 <skill>/scripts/kb-sync-from-plan.sh 知识库机制`
- `bash scripts/kb-sync-from-plan.sh <plan-dir>` → `bash <skill>/scripts/kb-sync-from-plan.sh <plan-dir>`
- `bash scripts/kb-rebuild-index.sh` → `bash <skill>/scripts/kb-rebuild-index.sh`
- 行末新增一行内注释：`<!-- 路径基准：<skill>/ 相对技能根（与上行 353 归档命令同基准） -->`

`git diff skills/task-planner/templates/task_plan.md` 仅 :355 一行变化（上下文 7 行内的 :353/:354 未动，仍为 `<skill>/scripts/set-active-plan.sh` / `archive-plan.sh` 形态）→ 与 :353 行路径基准统一，符合「最小 diff、勿整段重写」。

工作树中另有 3 个 M 文件（scripts/check-delegation.sh、scripts/selftest-requirement-coverage.sh、scripts/task-plan-init.cjs）——系本计划前序 S 单元（S1-S4）遗留改动，非 S5 触碰；S5 未修改、未还原它们。

## 2. 日期项判定结论

**日期项 = 无确证依据，保持原样（未做任何日期改动）。**

git log 核验：
- `git log -S 'task-kb-auto-capture-20261022' -- templates/task_plan.md` → 命中 commit `aa5b0a6 feat(task-kb-auto-capture-20261022)`，commit 日期 2026-10-22（`--date=short`），与 :354 行注释 `task-kb-auto-capture-20261022 增` 一致，无矛盾。
- 文件内其余日期标注（:16 2026-10-05、:17 2026-10-07、:131 2026-10-09、:320/:321 2026-10-08、:502 2026-09-27 task-v091 等）分属不同历史 commit 的注释区块，git log 未能确证其中任何一条与实际 commit 事实矛盾；风格不一（ISO 日期 vs 任务 ID 内嵌日期）仅为风格混用，非事实矛盾，不满足「确证矛盾才改」门槛 → 一律不动。

## 3. 验证输出

```
$ git diff skills/task-planner/templates/task_plan.md
（见 §1，仅 :355 单行 +/- 对，无其他 hunk）

$ grep -n 'kb-sync-from-plan\|kb-rebuild-index' skills/task-planner/templates/task_plan.md
355:- [ ] 知识提取入库（条件式：项目存在 <skill>/scripts/kb-sync-from-plan.sh ...
     `bash <skill>/scripts/kb-sync-from-plan.sh <plan-dir>` ... `bash <skill>/scripts/kb-rebuild-index.sh` ...
```
→ 全文件该两个脚本的 3 处引用均在 :355 单行、全部为 `<skill>/scripts/` 基准，与 :353 行基准一致；无残留无前缀形态。

## 4. 模板语义保持

- 未增删任何步骤项（checkbox 条目数、顺序、文案语义不变），仅补路径基准 + 行内注释。
- 部署位多份拷贝（zcode/claude/cursor）消费同一模板，基准注明后语义不变；`<skill>` 占位符为 :353 行既有约定（本段落已在使用），非新发明。

## 5. 遗留 / 风险

- 遗留：worktree 内 3 个前序单元 M 文件未 commit（按任务约束 S5 不 commit，留待计划后续收口 Phase 统一提交/合并）。
- 风险 LOW：本行 3 处前缀中条件式描述处（「项目存在 <skill>/scripts/...」）同属 :355 基准统一的一部分，若后续 CR 认为描述处应保持项目相对表述可单独回退该 token——不影响 2 处 bash 命令行的基准一致性。

status: done（2026-10-23）

## CR 回退轮（MAJOR-1，2026-10-23）

**依据**：CR 复核认定首轮 S5 方向失准——`kb-sync-from-plan.sh` / `kb-rebuild-index.sh` 实体不在技能根 `skills/task-planner/scripts/`，而在【仓库根】`scripts/`。本轮回退前实测确证：
- `ls /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/ | grep -i kb` → exit=1（零命中）
- `ls /mnt/data/dev/task-planner-skill/scripts/ | grep -i kb` → 命中 `kb-rebuild-index.sh`、`kb-search.sh`、`kb-sync-from-plan.sh`
→ 首轮改出的 `<skill>/scripts/kb-*` 指向不存在路径，且该行是「条件式必做」知识提取步骤，失准路径会静默传导至后续所有计划 → 必须回退。

**diff 摘要（本轮，相对 HEAD 73e70a0 态）**：
- :355 三处 kb-* 引用回退为原项目相对形态：`项目存在 scripts/kb-sync-from-plan.sh 知识库机制则必做` / `bash scripts/kb-sync-from-plan.sh <plan-dir>` / `bash scripts/kb-rebuild-index.sh`
- :355 行末注释替换为双轨注明：`<!-- 路径基准双轨：归档/模板类命令 <skill>/=技能根；kb-* 脚本实体在仓库根 scripts/（项目相对），勿混统一（2026-10-23 task-kb-cr-lits-20261023 CR MAJOR-1 回退） -->`（防后续再误统一）
- `git diff skills/task-planner/templates/task_plan.md` 复核：仅 :355 单行 +/- 对（index 73e70a0..5667974），:353 行（`<skill>/scripts/set-active-plan.sh` / `archive-plan.sh`）与 :354 注释行未动
- `grep -n 'kb-sync-from-plan\|kb-rebuild-index'`：仅 :355 命中，三处引用全部为 `scripts/`（仓库根相对）形态，与实体位置一致
- 未 commit（工作区保留 M 状态）；未碰其他文件

status: done-CR回退轮（2026-10-23）
