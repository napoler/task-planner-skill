# P2-S2 任务书: install-companion.sh 池成员宿主分发（task-v105）

任务: worktree 内 `skills/task-planner/lib/install-companion.sh` 的 skills 分发循环中,task-planner 本体分支改为「池成员分发」——11 个 review-library 成员的 SKILL.md 单文件分发到宿主顶层 skills/<member>/。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/（只读）
- progress.md: 同目录（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v105-pool-host-enumerable/skills/task-planner/lib/install-companion.sh

## 硬约束
- **零改动面**: sync_one/adapt_model_line/agents 段/顶层 skills 非任务循环体/backup 逻辑/计数器语义——全部不动;只改 task-planner 分支 1 处
- **禁止覆盖独立 skill**: 目标文件已存在且与源内容不同 → skip+WARN（opencode 顶层 security-review 是用户既有独立 skill,必须保留）
- 池成员是纯文档 skill:只分发 SKILL.md 单文件
- 禁「1-4x」越界字面

## 操作内容
### 将现文（:172 附近）:
```bash
    [ "$skill_name" = "task-planner" ] && continue
```
改为（逐字）:
```bash
    if [ "$skill_name" = "task-planner" ]; then
      # [task-v105] 池成员宿主可枚举分发: review-library/<member>/SKILL.md → <root>/skills/<member>/SKILL.md
      # 单文件分发(池成员为纯文档 skill,零 scripts/config);幂等=cmp 等同由 sync_one 自跳;
      # 顶层已有独立 skill 且内容不同 → 独立 skill 不覆盖,skip+WARN 留痕
      pool_dir="$REPO_SKILLS/task-planner/review-library"
      if [ -d "$pool_dir" ]; then
        for member_dir in "$pool_dir"/*/; do
          [ -d "$member_dir" ] || continue
          member_name="$(basename "$member_dir")"
          member_skill="$member_dir/SKILL.md"
          [ -f "$member_skill" ] || continue
          member_dst="$TARGET_ROOT/skills/$member_name/SKILL.md"
          if [ -f "$member_dst" ] && ! cmp -s "$member_skill" "$member_dst"; then
            echo "[companion] WARN: skip pool member $member_name (顶层已存在独立 skill 且内容不同,不覆盖)"
            skipped=$((skipped+1))
            continue
          fi
          sync_one "$member_skill" "$member_dst"
        done
      fi
      continue
    fi
```

## acceptance: 验收标准
1) `bash -n lib/install-companion.sh` 语法过
2) `grep -c 'review-library'`≥2（注释+pool_dir）;`grep -c '独立 skill'`≥1;`grep -c 'install_pool_links'`=0（本文件不引用该函数）
3) git diff 仅该文件;sync_one/agents 段/非 task-planner 分支零改动（diff 上下文核对,纯增+原 1 行 continue 改为 if 块）
4) 幂等语义静态核对: cmp 等同路径不重复写（sync_one 自跳）;内容不同路径 skip+WARN+skipped 计数
5) `git -C <wt> status --short`: 仅 lib/install-companion.sh M（smart-merge-back 为 S1 存量）

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v105-pool-host-enumerable/subagent-state/02-exec-p2s2.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S2
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
