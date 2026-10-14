#!/usr/bin/env bash
# [2026-08-27] zcode-sessionstart.sh — ZCode SessionStart 适配器（task-planner 哨兵机制）
# 运行 task-plan-init.cjs 写入 .plan-required 哨兵；ZCode 对 hook stdout 做严格 JSON 校验，
# 纯文本输出会被判失败，故将脚本文本包装为 {"additionalContext": ...} 注入会话。
# 永远 exit 0（fail-open）：哨兵写入失败也不阻塞会话。
# [2026-09-10 task-planrequired-race] 读 stdin 提取 session_id 经 TASK_PLANNER_SID env 透传给 task-plan-init.cjs
# （原行为=不读 stdin、init 无条件写全局 <CWD>/.plan-required 致跨会话互写竞态 B1-B4；现改为会话私有 side 哨兵）。
# [2026-09-10 task-path-identity] 现象=L10 内嵌 node 绝对路径字面量,部署/迁移即坏;根因=硬编码 /home 拼写而非派生;修法=INIT_CJS 改 BASH_SOURCE 派生(对齐本文件 set-active-plan 调用既有范式),废除脚本内最后处路径字面量。
input="$(cat 2>/dev/null || true)"
sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
# [2026-09-10 task-path-identity] 原=内嵌绝对路径(部署迁移即坏);改 BASH_SOURCE 派生(对齐本文件既有范式)
INIT_CJS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/task-plan-init.cjs"
out="$(TASK_PLANNER_SID="$sid" node "$INIT_CJS" 2>/dev/null)"
rc=$?

# [2026-08-28] 未完成任务恢复提醒:读 CWD/plans/INDEX.md 待处理区,有欠账则追加 [task-resume] 段
# (每会话仅此一次;仅提示,未经用户确认不得自动拉起执行——防新会话意图被旧任务劫持)
# [2026-10-14 task-v172 CA-5] 陈旧任务折叠:in_progress 任务全部 >7 天未更新时,折叠为单行噪音抑制
# (根因:7 个 stale in_progress 制造噪音,每会话注入 top-3 陈旧任务无实际推进价值)
idx="$PWD/plans/INDEX.md"
if [ -f "$idx" ]; then
  # [CA-5] 提取待处理区所有未完成任务行(不限 top-3,用于新鲜度判定)
  pending_all="$(sed -n '/^## 待处理/,/^## 已完成/p' "$idx" | grep -E '^- \*\*')"
  if [ -n "$pending_all" ]; then
    n="$(printf '%s\n' "$pending_all" | grep -c '^- \*\*')"
    # [CA-5] 检查是否有任何任务在 7 天内有更新(读 INDEX.md 第 8 列「最后更新」)
    has_fresh="$(printf '%s\n' "$pending_all" | awk -F'|' -v now="$(date +%s)" '
      BEGIN { found = 0 }
      {
        gsub(/^[ \t]+|[ \t]+$/, "", $8)
        if (match($8, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)) {
          date_str = substr($8, RSTART, RLENGTH)
          cmd = "date -d \"" date_str "\" +%s 2>/dev/null"
          if ((cmd | getline epoch) > 0) {
            close(cmd)
            days = int((now - epoch) / 86400)
            if (days <= 7) { found = 1; exit }
          }
          close(cmd)
        }
      }
      END { print (found ? "fresh" : "stale") }
    ')"
    if [ "$has_fresh" = "stale" ]; then
      # [CA-5] 全部 >7 天未更新,折叠为单行(噪音抑制)
      out="${out}
[task-resume] 📋 ${n} 项历史任务(未更新>7 天),按需 plan-resume。"
    else
      # 有新鲜任务,保持 top-3 注入(既有行为)
      pending="$(printf '%s\n' "$pending_all" | head -3)"
      out="${out}
[task-resume] 📋 检测到 ${n} 个未完成任务(plans/INDEX.md 待处理区):
${pending}
开场时向用户提议是否继续;未经用户确认勿自动执行。"
    fi
  fi
fi

# [2026-09-10 active-plan-race] 顺带清扫过期会话指针(.active_plan_side/ mtime>24h,会话残留)
# fail-open: 失败静默,不阻塞会话启动
# [2026-09-10 task-planrequired-race] gc stdout 原混入 hook stdout 破坏「单行 JSON」契约(ZCode 严格校验,既有缺陷)→ 1>/dev/null 抑出,stderr 保留
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/set-active-plan.sh" gc 1>/dev/null 2>/dev/null || true

if [ "$rc" -eq 0 ] && [ -n "$out" ]; then
  printf '{"additionalContext": %s}\n' "$(printf '%s' "$out" | jq -Rs .)"
fi
exit 0
