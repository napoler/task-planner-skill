# 13-executor Phase 5 Step 3: INSTALL/README hook 段落地

- [milestone 1] Read INSTALL.md L170-214 / README.md L14-23 基线确认：INSTALL 270 行、README 238 行；`### 5.2` 在 L179，README L19 子串 `PreToolUse（范围阻断）` 唯一
- [milestone 2] INSTALL.md §5.2 前插入新小节 `### 5.1a ZCode PreToolUse matcher 须含 Agent（派发契约守卫，Rule 22.4c）`（标题+空行+正文+空行=4 行，无重编号）→ INSTALL 274 行 (+4 ≤6)
- [milestone 3] README.md L19 行内替换 `PreToolUse（范围阻断）` → `PreToolUse（范围阻断 + 委派门控 + Agent 派发契约守卫，matcher 须含 Agent）`，README 行数不变 238
- [milestone 4] 验收 5/5 PASS（grep 计数、行号序 179<183、行数差 +4、git diff --stat INSTALL +4 / README 1±）

## 最终结论
status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract/skills/task-planner/INSTALL.md(+4/-0); /mnt/data/dev/task-planner-skill-worktrees/task-v057-subagent-io-contract/skills/task-planner/README.md(+1/-1)
evidence: INSTALL.md:179 `### 5.1a`(179) < `### 5.2`(183); grep -c "Write|Edit|Agent"=1, check-dispatch=1, selftest-dispatch=1; README.md:19 grep "matcher 须含 Agent"=1; git diff --stat → INSTALL 4 ++++ / README 2 +-
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v057-subagent-io-contract/subagent-state/13-executor-p5s3.md (status: done)
findings_written: [sub:13-executor] INSTALL/README hook 段落地
blockers: none
confidence: HIGH
