# 19-p2-s2-rule-triggers — 执行期错误即时纠正：Rule 31.1/33.1 触发面扩展 + Error Log 增列

> task-v168 Phase 2 S2 code-assistant 子代理产出（纯文本逻辑修订，worktree 内执行）。

## 改动明细

### 1. skills/task-planner/references/critical-rules.md — Rule 31.1 增第 5 触发条件
- 位置：`:322`（31.1 行）。原文四条件 ①②③④ 逐字保留，`④ …ERROR-LOOP 信号。` 句号改分号后追加：
  `⑤ 执行期机器可观察错误信号：工具 exit code 非零/测试 FAIL/hook 拦截/子代理返回 failed|partial——出现即触发 31.2-31.5 全链（根因四问→纠正→沉淀→消费侧）`
- Rule 45 注记（行末）：`[2026-10-11 task-v168 逻辑层] 增补第 5 触发条件⑤；原四条件（①②③④）语义不变，纯增量`

### 2. 同文件 — Rule 33.1 增第 4 触发点
- 位置：`:344`（33.1 行）。原文三触发点 ①②③ 逐字保留，追加：
  `④ 工具报错/测试 FAIL 出现时（问题出现即时触发，不等解决后——R4「及时纠正」）`
- Rule 45 注记：`[2026-10-11 task-v168 逻辑层] 增补第 4 触发点④；原三触发点（①②③）语义不变，纯增量`

### 3. skills/task-planner/templates/progress.md — Error Log 表尾增列
- 位置：`:42-52` 区。表头 `…| Root Cause | Prevention |` → `…| Root Cause | Prevention | 触发命令/工具 |`；模板占位行同步增一列（尾列空占位）；注释区追加 Rule 45 注记（原表头/修改原因=31.1⑤ 根因定位/时间 2026-10-11/纯增量兼容说明）。

## 兼容性证据（check-complete.sh Learning Gate，只读未改）
- `scripts/check-complete.sh:1097-1160` 区：Learning Gate 用状态机 awk 找「## Error Log」节首个表头行中 `Root[[:space:]]+Cause` 的**列号**（动态定位，非硬编码列序），表尾增「触发命令/工具」列不改变 Root Cause 列号 → 兼容。
- 模板占位行检测 awk（`lg_tpl_awk`，匹配 `|  |  | 1 |` 前三格）：占位行前三格未动 → 检测不变。
- `grep -c "触发命令/工具" scripts/check-complete.sh` = 0，脚本未触碰。

## 验收自验（worktree 内）
1. `grep -c "⑤ 执行期机器可观察错误信号" critical-rules.md` = 1 ✅
2. `grep -c "④ 工具报错/测试 FAIL 出现时" critical-rules.md` = 1 ✅
3. 原 4 条件/3 触发点逐字 grep（①②③④ 原文各 1 命中）✅
4. `grep -c "触发命令/工具" templates/progress.md` = 2（表头 1 + 注释 1）✅
5. check-complete.sh 未触碰（git status 无该文件；列名解析=表头动态定位，兼容增列）✅
6. `git status --short` = `M skills/task-planner/SKILL.md`、`M …/critical-rules.md`、`M …/templates/progress.md`。
   - 前两项中本代理只改 critical-rules.md 与 progress.md 两个文件；SKILL.md 的未提交修改（R 锚定/技能激活/3c 错误同轮四步等 task-v168 锚点，+5/-1 行）**非本子代理写入**，为 worktree 先行状态（其他 S2 子代理或主进程产出），未触碰、未覆盖。`git diff --stat` 确认本代理两文件 diff 仅 +4/-2 与 +6/-4 行，均在任务规格内。

## 最终结论
done。两处规则触发面纯增量扩展 + 模板表尾增列全部落地，既有语义逐字在位，Learning Gate 列名动态定位兼容增列，脚本/hook/config 零改动。唯一超出「git status 只有两个文件」验收的现实差异 = SKILL.md 携带他代理未提交改动（非本代理写入），已在 evidence 登记，请主进程裁决是否并入验收。
