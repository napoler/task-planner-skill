# Checkpoint — S21a 修复（code-assistant，task-v166 P0 锚漂移 + F-4 冗余声明）

## T1 · 修复执行记录（2026-10-11 11:14 CST）

- 目标文件：/mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability/skills/task-planner/scripts/check-complete.sh（唯一改动文件）
- P0 修法来源：20-general-purpose.md 审查问题清单 P0 行（锚漂移判例）
- 步骤遵循：严格 4 步（P0 修 → F-4 修 → 自验 → 落盘），无额外动作

## 修改明细（file:line + 原文对照）

1. **P0 代码锚**（check-complete.sh:976 grep / :979 awk，原 :972/:975）
   - 原文：`^##[[:space:]]*(5\.|五、)[[:space:]]*下一步建议`（grep -qE 行 + awk 行各一处）
   - 现文：`^##[[:space:]]*(5\.|6\.|五、|六、)[[:space:]]*下一步建议`（双形态兼容新旧模板）
   - 同行注释（:975）加 [2026-10-11 task-v166] 锚漂移修复注
2. **P0 注释双形态**（:940 / :946-949）
   - :940 `「## 5. 下一步建议」` → `「## 5./6. 下一步建议」`
   - :946-949 区块锚注释 `## 5.` → `## 5./6.`，追加 [2026-10-11 task-v166] 顺延说明（§3 审查清单级联）+ 双形态兼容注
3. **F-4 变量清理**（:1033，原 :1029）
   - 原文：`local vf rl_ph_n rl_circ`
   - 现文：`local vf rl_ph_n`（rl_circ 全文 grep 无其他使用点=冗余已删；rl_ph_n 保留=跨检查⑤(:1012)/⑥ 同名复用，有意不新造变量，加复用说明注释）

## 自验证据

- `bash -n check-complete.sh` → SYNTAX_OK
- `grep -n '5\.|6\.|五、|六、' check-complete.sh` → 命中 :949/:975（注释）+ 代码行 :976/:979 实测（grep -nE '5\\\.|六、' 三处代码/注释命中）
- 夹具实证（/tmp/rl-fixture，已清理）：
  - 新形态：delivery-summary.md 含「## 6. 下一步建议」且缺看点/动作 → 函数提取法（awk 抽 run_report_lint + PLAN_DIR_GUESS/SKILL_ROOT 注入 source 执行）输出 `[report-lint] ⚠ 下一步建议缺看点/动作定位三要素 (Rule 48.4/70④)`，EXIT=0（fail-open 语义不变）
  - 旧形态回归：含「## 5. 下一步建议」且看点/动作齐 → 检查②不误报（仅夹具缺 §3 触发既有的 76.2 warn，属预期），EXIT=0
- 无功能性删除：仅删未使用的 local 声明 rl_circ；全部 6 项检查逻辑（①②③④⑤⑥）保留原样

## 负结果核查

- 检查依赖文件 20-general-purpose.md（P0 修法与本文一致，无冲突）
- 全文 grep rl_circ：仅 :1029 声明处 1 命中，无使用点 → 删除安全
- rl_ph_n 两处 local 声明（:1012 检查⑤、:1033 检查⑥）均在使用，不删
- 仅改动 check-complete.sh 单文件；未触碰 plans 产物 / 其他脚本 / git 写操作

## T5 · 最终结论（= 返回格式 8 字段块）

```
status: done
acceptance: 4/4 pass — [1:PASS(双形态锚 grep 命中代码行:976/:979) 2:PASS(bash -n SYNTAX_OK) 3:PASS(「## 6.」夹具触发三要素 warn 且旧「## 5.」含要素不误报) 4:PASS(仅删未用 rl_circ，无功能性删除)]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v166-summary-readability/skills/task-planner/scripts/check-complete.sh(+10/-4)
evidence: check-complete.sh:976 grep '^##[[:space:]]*(5\.|6\.|五、|六、)[[:space:]]*下一步建议' 与 :979 awk 同源锚; :1033 'local vf rl_ph_n'(rl_circ 删); bash -n → SYNTAX_OK; 夹具「## 6. 下一步建议」缺要素 → '[report-lint] ⚠ 下一步建议缺看点/动作定位三要素 (Rule 48.4/70④)' EXIT=0; 旧「## 5.」含要素回归不误报 EXIT=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v166-summary-readability/subagent-state/21a-code-assistant.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
