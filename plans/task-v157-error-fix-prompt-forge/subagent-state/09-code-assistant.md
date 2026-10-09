# checkpoint — sub:09-code-assistant 合并级联修复:FP-07 含口径化

## 里程碑
- [M1] Edit selftest-error-fix-prompt-forge.sh: FP-07 段(原 :74-79)改含口径 + 头注释 :16 同步改「含口径登记」并注记合并级联原因
- [M2] 四脚本复跑全 exit 0

## 修改
- 文件: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh (+7/-4, 89 行 ≤90)
- 原文: `if [ -f "$REG" ] && tail -1 "$REG" | grep -q 'error-fix-prompt-forge'; then ... bad 07 "...末行快照: $(tail -1 ...)"`
- 新文: `n="$(grep -c 'error-fix-prompt-forge' "$REG" 2>/dev/null || true)"; [ "$n" -ge 1 ]` PASS/FAIL 消息带 $n 诊断
- FP-01..06/08 零改动; 头注释 FP-07 行改「registry 含口径登记」+ 注记「[2026-10-10 合并级联修复 sub:09] 末行口径改含口径... 对齐 G-07 含口径范式防复发」
- Scope 禁改清单核查: 仅动该脚本 FP-07 段+头注释行; registry/其他 selftest/SKILL.md/模板 零改动; 无 git 写操作

## 复跑证据(逐条命令→输出)
1. `bash -n selftest-error-fix-prompt-forge.sh && wc -l` → 语法 OK, 89 行
2. `bash selftest-error-fix-prompt-forge.sh` → FP-07 PASS「registry 含 error-fix-prompt-forge 数据行(命中 1 ≥1)」, Total: 8 PASS=8 FAIL=0, exit 0
3. `bash selftest-registry.sh` → T01-T05 全 PASS, Total: 5 PASS=5 FAIL=0 (registry rows=68, actual selftest=68), exit 0
4. `bash selftest-self-resolution.sh` → SR-12 PASS「registry selftest-self-resolution 登记行 ≥1 且总行数 69=脚本数+表头(动态)」, Total: 13 PASS=13 FAIL=0, exit 0
5. `bash selftest-report-reviewability.sh` → RRV-01..13 全 PASS, Total: PASS=13 FAIL=0 WARN=0, exit 0

## 契约追加
- findings.md 追加 `#### [sub:09-code-assistant] 合并级联修复:FP-07 含口径化` 小节(现象/根因/修法/回归四段)
- progress.md 追加 Phase 5 段 Actions taken 行 `  - [sub:09] FP-07 含口径化,回归 PASS`

## 最终结论
```
status: done
acceptance: 4/4 pass — [1:PASS FP-07 含口径改写+头注同步 PASS/FAIL 带$n诊断/其余断言零改动+语法+89行] [2:PASS 自跑 exit 0 Total 8 PASS=8 FAIL=0] [3:PASS 连带复跑 registry 5/5 + self-resolution 13/13(SR-12 registry 69行动态口径) + report-reviewability 13/13 全 exit 0] [4:PASS findings/progress 按契约追加]
files: /mnt/data/dev/task-planner-skill-worktrees/v157-error-fix-prompt-forge/skills/task-planner/scripts/selftest-error-fix-prompt-forge.sh(+7/-4); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/findings.md(+1 小节); /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/progress.md(+1 Phase 5 段)
evidence: bash selftest-error-fix-prompt-forge.sh→「Total: 8 PASS=8 FAIL=0」exit 0; bash selftest-registry.sh→「T05 PASS / Total: 5 PASS=5 FAIL=0 (registry rows=68, actual selftest=68)」exit 0; bash selftest-self-resolution.sh→「SR-12 PASS ... 总行数 69=脚本数+表头(动态)」Total 13/13 exit 0; bash selftest-report-reviewability.sh→「Total: PASS=13 FAIL=0 WARN=0」exit 0; bash -n OK, wc -l=89≤90
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v157-error-fix-prompt-forge/subagent-state/09-code-assistant.md (status: done)
findings_written: #### [sub:09-code-assistant] 合并级联修复:FP-07 含口径化
blockers: none
confidence: HIGH
```
