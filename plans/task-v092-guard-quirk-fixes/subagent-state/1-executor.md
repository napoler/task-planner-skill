# Checkpoint: S1 executor（Phase 1 取证 — check-conflicts 1a+1b）

- 时间：2026-09-27；基线 master 0b2208b；本 S-unit 只读取证，仓内零源码修改（仅计划簿记三件：findings.md/progress.md/checkpoint）
- 状态：**done**（1a+1b 根因双锁定，夹具 3 种覆盖）

## 最终结论（必入检查点）
1. **1a 恒空根因**：check-conflicts.sh:144 sed 区间 `/^| Task ID/,/^|-------/` 的 end 模式被真实 INDEX.md 分隔行（首列 9 连字符，紧邻表头）命中 → 区间只输出表头+分隔行 2 行 → tail -n +2 后只剩分隔行 → status=`--------` 恒 ≠ in_progress → :126 continue 恒命中 → active_plans 恒空、A/B/C 零触发。证据：/tmp/s1-evidence/stage1-5.txt（S1 段=2 行，S2 段=1 行分隔行）。
2. **1b 恒不等根因**：:170 `[[ "$other_plan" == "$current_plan_dir" ]]`，other_plan=:127 相对路径 `plans/$task_id`，current_plan_dir=:149 `$repo/plans`/* 绝对 glob → 字符串恒不等 → 自计划不跳过 → 恒自报冲突 A（scope 与自身交集），repo-fc 端到端 rc=1 实证。1a 修复后 1b 必显形（叠加缺陷）。
3. 夹具对照：repo-fa（真实形态）恒空复现 / repo-fb（表头分隔行间夹数据行）非空 / repo-fc（3 连字符分隔行）非空——缺陷触发条件=分隔行 ≥7 连字符且紧邻表头。
4. 真实 INDEX.md:9 分隔行仅 6 字段 vs 表头 9 字段（sync-todos 畸形产出，登记不修）；S13② plan glob 维持 deferred（夹具实测顶层 glob 正常，机理未展开）。

## 产物
- findings 小节：plans/task-v092-guard-quirk-fixes/findings.md `### S1 check-conflicts 取证`
- progress 行：plans/task-v092-guard-quirk-fixes/progress.md Phase 1 段
- 夹具：/tmp/s1-fixtures/{repo-fa,repo-fb,repo-fc}；逐段证据 /tmp/s1-evidence/stage1-5.txt

## 断点恢复
S1 无剩余子步。下一 S-unit=S2（check-drift 3a/3b/3c 复现，另一个 executor 会话）。
