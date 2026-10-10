# S4 引用面分级 — checkpoint（sub:4-executor, 2026-10-10）

## 里程碑
- [2026-10-10] 取全集：28 文件 / 170 hits（材料记 166，实测 170，差 4；文件数 28 一致）
- [2026-10-10] 读 S3 两文件头注释（set-active-plan.sh:1-35 / resolve-plan-dir.sh:1-35）→ 目标措辞"全局 fallback"，旧措辞"全局 legacy 指针/移交/跨树共享"
- [2026-10-10] trigger 词 grep（入库/git跟踪/全局 legacy/移交/跨树共享/全局指针）→ 定位旧语义注释块
- [2026-10-10] 逐文件 ±5 行上下文判定 28 文件
- [2026-10-10] findings.md 追加段 28 行表 + 汇总行（awk 计数据行=28）；progress.md Phase 3 追加单行
- [2026-10-10] 验收：git status --short 无 skills/ 条目

## 分级结果（汇总）
- 只读消费方 14：selftest-check-conflicts.sh / selftest-rule23-conflict-scan.sh / plan-hygiene.sh / allow-direct.sh / plan-doctor.sh / ledger-append.sh / selftest-delegation.sh / check-scope.sh / zcode-sessionstart.sh / selftest-drift-enforcement.sh / check-conflicts.sh / selftest-active-plan.sh / selftest-pointer-lifecycle.sh / check-skill-modify.sh
- 措辞更新方 12：INSTALL.md / README.md / zcode-userpromptsubmit.sh / SKILL.md / zcode-posttooluse.sh / task-plan-init.cjs / init-session.sh / zcode-pretooluse.sh / check-complete.sh / plan-created.cjs / check-dispatch.sh / references/critical-rules.md
- 已改述（S3）2：resolve-plan-dir.sh / set-active-plan.sh

## 最终结论
```
status: done
acceptance: 3/3 pass — [① findings.md 追加段数据行=28（awk 计数据行输出 28）+汇总行 14+12+2=28 在位（findings.md:114）；② 每行带 file:line 锚+一句理由，分类仅用三值；③ git status --short 无 skills/ 条目（输出 NONE）]
files: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/findings.md (+34/-0) | /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/progress.md (+1/-0)
evidence: grep -rn 'active_plan' skills/task-planner/ | wc -l → 170；grep -rln → 28 文件；findings.md:114 汇总行"只读 14 / 措辞更新 12 / 已改述 2（=28）"；git status --short | grep 'skills/' → NONE
checkpoint: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/subagent-state/4-executor.md (status: done)
findings_written: #### [sub:4-executor] S4 引用面分级
blockers: none
confidence: HIGH
```
