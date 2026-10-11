# P2-S2 checkpoint: install-companion.sh 池成员宿主分发

## 状态: done
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable
- 修改文件: skills/task-planner/lib/install-companion.sh（仅此 1 文件,原 :166 单行 continue 改为 if 块,逐字取任务书操作文本）

## 改动内容
- 原行 `[ "$skill_name" = "task-planner" ] && continue` 替换为 if 块:
  - `pool_dir="$REPO_SKILLS/task-planner/review-library"`;`[ -d "$pool_dir" ]` 守卫
  - for 遍历 `$pool_dir/*/`（11 成员实际存在:alignment-review…ui-quality-review,已核实）
  - `[ -f "$member_skill" ] || continue` 仅分发 SKILL.md 单文件
  - dst 已存在且 `! cmp -s` 内容不同 → `echo "[companion] WARN: skip pool member …(顶层已存在独立 skill 且内容不同,不覆盖)"` + `skipped=$((skipped+1))` + continue
  - 否则 `sync_one "$member_skill" "$member_dst"`（保持既有幂等:sync_one :107 cmp 等同自跳计入 skipped）
  - 块尾保留 `continue`（本体目录仍跳过顶层 find 循环,零行为回归）

## 零改动面核对（git diff 确认）
- diff 仅 +21/-1,全部位于 skills 分发循环内 task-planner 分支;sync_one/adapt_model_line/agents 段/backup 逻辑/计数器初始化/非 task-planner 分支逻辑零改动。

## 验收证据
1. `bash -n lib/install-companion.sh` → SYNTAX_OK
2. grep: `review-library` = 2（注释+pool_dir）;`独立 skill` = 2（≥1）;`install_pool_links` = 0 ✓
3. `git diff -- skills/task-planner/lib/install-companion.sh` 纯增 + 原 1 行改 if 块,上下文无其他变更 ✓
4. 幂等语义: 等同内容 → sync_one cmp 自跳（:107 skipped 计数）;内容不同 → 前置 cmp 拦截 skip+WARN+计数,不覆盖独立 skill ✓
5. `git -C <wt> status --short`: `M skills/task-planner/lib/install-companion.sh` + ` M skills/task-planner/scripts/smart-merge-back.sh`（S1 存量,任务书预期）✓

## 备注
- 未执行 git add / commit（禁项）。
- 未运行 install-companion.sh 实测（任务书未要求;静态验收 1-5 已全过）。
