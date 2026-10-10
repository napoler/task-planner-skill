# S7 executor checkpoint — 两 hook 注释改述（2026-10-10）

## 里程碑
- [2026-10-10] 读 7-prompt-material.md + findings [sub:4] + knowledge-brief §3；基线 grep 定位 UPS:23 / PTU:43-44 旧语义
- [2026-10-10] 改述 zcode-userpromptsubmit.sh:23（+5/-1，纯 `#` 行）
- [2026-10-10] 改述 zcode-posttooluse.sh:43-44（+6/-2，纯 `#` 行）
- [2026-10-10] 验收四查全过（grep task-v164=1/1；旧语义 rc=1 空；bash -n 双过；代码区非#行=0）

## 编辑锚
- UPS:23 原「并行会话不再互顶全局 legacy 指针」→ 三点语义块（全局=工作树内瞬态 fallback；正常路径=side 权威层 2026-10-07 后；退役"互顶"叙事）+`[2026-10-10 task-v164]` 注记（原措辞以「legacy 全局指针被并行会话互顶」描述，避开字面串防 grep 误伤）
- PTU:43-44 原「不再被全局 legacy 指针互顶」→ 同三点语义块 +`[2026-10-10 task-v164]` 注记

## 验收证据
- `grep -c 'task-v164'` → zcode-userpromptsubmit.sh:1 / zcode-posttooluse.sh:1
- `grep -nE '互顶全局|全局 legacy'` 两脚本 → rc=1（空集）
- `bash -n` 两脚本 → 双 OK
- `git diff -U0 | 非#行 | grep -c .` → 0（代码区零改动）
- `git status --short` → 仅两目标脚本 M（+ `.dispatch-inflight`/`7-prompt-material.md` 为派发期既有，非本次产生）

## 最终结论
status: done
acceptance: 4/4 pass — grep -c task-v164=1/1；旧语义 rc=1 空；bash -n 双过；代码区非#行=0
files: skills/task-planner/scripts/zcode-userpromptsubmit.sh (+5/-1); skills/task-planner/scripts/zcode-posttooluse.sh (+6/-2)
evidence: zcode-userpromptsubmit.sh:23-27; zcode-posttooluse.sh:43-47; git diff 仅注释行
checkpoint: /mnt/data/dev/task-planner-skill-worktrees/v164-pointer-worktree-local/plans/task-v164-pointer-worktree-local/subagent-state/7-executor.md (status: done)
findings_written: #### [sub:7-executor] S7 两 hook 注释改述
blockers: none
confidence: HIGH
