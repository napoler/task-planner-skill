# P2-S3 任务书: RL-14/15 守护断言+头注释级联（task-v105）

任务: worktree 内 `skills/task-planner/scripts/selftest-review-library.sh` 追加 RL-14/RL-15 两条断言+头注释计数级联（13→15）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable/skills/task-planner/scripts/selftest-review-library.sh（当前 13 断言,Total: 13）

## 硬约束
- RL-01..RL-13 既有断言零改动;RL-02..RL-10 池成员「11 个」文案不动（池成员数未变）
- 头注释「RL-01..RL-13」→「RL-01..RL-15」（:4 行）;RL-13 描述行后追加 RL-14/15 描述行
- Total 行自然产出 15;禁「1-4x」越界字面

## 操作内容
### ① 头注释 :4 行 `RL-01..RL-13` → `RL-01..RL-15`;RL-13 描述行后追加 2 行:
`#   RL-14     池成员宿主枚举挂载锚（task-v105）：scripts/smart-merge-back.sh 'install_pool_links' ≥1 且 'LINK-WARN' ≥1（冲突跳过语义）`
`#   RL-15     install-companion 池分发锚（task-v105）：lib/install-companion.sh 'review-library' ≥1 且 '独立 skill' ≥1（不覆盖语义）`
### ② 变量区（RLIB= 附近）追加 2 个变量（照现文路径解析风格）:
`SMB="$SKILL_ROOT/scripts/smart-merge-back.sh"`
`ICOMP="$SKILL_ROOT/lib/install-companion.sh"`
（先 Read 现文确认 SKILL_ROOT 解析方式,变量名不与既有冲突）
### ③ 断言区 RL-13 之后追加（照 RL-09/RL-11 双条件范式）:
```bash
# RL-14 池成员宿主枚举挂载锚（task-v105）
a="$(grep -c 'install_pool_links' "$SMB" || true)"
b="$(grep -c 'LINK-WARN' "$SMB" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 14 "smart-merge-back 池挂载函数+冲突跳过锚在位"; else bad 14 "smart-merge-back 池挂载锚缺失(install_pool_links=$a/LINK-WARN=$b)"; fi
# RL-15 install-companion 池分发锚（task-v105）
a="$(grep -c 'review-library' "$ICOMP" || true)"
b="$(grep -c '独立 skill' "$ICOMP" || true)"
if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then ok 15 "install-companion 池分发+独立 skill 不覆盖锚在位"; else bad 15 "install-companion 池分发锚缺失(review-library=$a/独立 skill=$b)"; fi
```

## acceptance: 验收标准
1) `bash scripts/selftest-review-library.sh` → `Total: 15 PASS=15 FAIL=0`
2) RL-01..13 断言行零改动（git diff 仅 :4 计数行+2 描述行+2 变量+2 断言块）
3) `grep -c 'RL-15'`=3（头注释/断言区注释或变量/ok-bad 行≥2 即可,实测记录）
4) `bash -n` 语法过
5) worktree 复跑 3 脚本 0 FAIL: selftest-review-library/selftest-reliability-institution/selftest-self-resolution
6) `git -C <wt> status --short` scripts/ 仅该文件 M（前序存量 smart-merge-back+lib/install-companion 为 S1/S2）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/subagent-state/03-exec-p2s3.md（含 Total 行原文）。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S3
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
