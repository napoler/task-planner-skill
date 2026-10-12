# 07-s4-posttooluse-periodic — S4 检查点（zcode-posttooluse.sh 新增 [periodic-ground]）

- [2026-10-11 S4-start] 基线已验：worktree 内 `bash zcode-posttooluse.sh --test` → S3 5/5 PASS (RC=0)；periodic-review.sh 只读确认（exit 0/1/2 语义 + 输出单行 JSON `detected[].code`，:169-192）

## 里程碑
- [2026-10-11 S4-m1] 头部注释 S4 [periodic-ground] 说明段 + --test 断言描述 5→10 更新
- [2026-10-11 S4-m2] 修复「pg_check 定义晚于调用点」踩坑：pg_check/pg_review 移至 re_anchor_check 定义后、drift_rhythm_check 调用点前（bash 顺序执行，S3 re-anchor 即为此范式）
- [2026-10-11 S4-m3] 计数自增调用点（F5 前移区）+ F12 早退清 due（F10/F11 对称）+ 末尾注入段（rhythm-due 并入 / re-anchor 独立轮并入 / 优先级 7 独立轮，F9 单轮单 JSON + _pg_emitted 双 emit 防护）
- [2026-10-11 S4-m4] 实测踩坑：(a) periodic-review.sh:89 `tr -d '*-#'` 在 C/C.utf8/en_US.utf8/zh_CN.utf8 全 locale 下报「range-endpoints reverse collating sequence order」→ keyword 恒空 → 检测器本机恒漏检（exit 1 不可达）——上游 tr 缺陷，本任务不改 periodic-review.sh（只读约束）；(b) tr 可用形态 `-` 放首位（'*#-' OK）但属修上游，超范围。B2/B3/B5 自测改走 fixture 桩（$OPENCODE_SKILL_ROOT/scripts/periodic-review.sh 桩，pg_review 定位链第一优先）覆盖三态 exit
- [2026-10-11 S4-m5] B4 踩坑：resolver side 层要求 ${pid}/task_plan.md 存在（resolve-plan-dir.sh:101），emptyplan 须自带 task_plan.md（缺 findings/progress 仍触发桩 exit 2）
- [2026-10-11 S4-m6] `--test` 全 PASS（10/10：S3 5 + S4 5），bash -n 通过；git diff 纯增量（仅 2 行被改的既有行 = S3 re-anchor 并入 emission 行 + rhythm F10 printf 行扩展）
- [2026-10-11 S4-m7] 最终结论（见下）

## 最终结论
```
status: done
acceptance: 5/5 pass — [1:PASS git-diff-visible 2:PASS test-10/10 3:PASS s3-intact 4:PASS periodic-review-untouched 5:PASS no-other-files]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v168-session-anchor-skill-activation/skills/task-planner/scripts/zcode-posttooluse.sh(+330/-2 相对 S3 提交基线含 S4 全量；S4 净增约 +330 行)
evidence: zcode-posttooluse.sh --test → "PASS (10/10: S3 re-anchor 5 + S4 periodic-ground 5)" RC=0; git status --short 仅既有 S1-S3 文件 + 本文件; git diff periodic-review.sh 空
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v168-session-anchor-skill-activation/subagent-state/07-s4-posttooluse-periodic.md (status: done)
findings_written: §里程碑 S4-m4（tr 缺陷 + 桩方案）/ S4-m5（resolver side 校验）
blockers: none
confidence: HIGH
```
status: done
