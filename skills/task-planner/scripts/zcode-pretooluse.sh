#!/usr/bin/env bash
# [2026-08-27] zcode-pretooluse.sh — ZCode PreToolUse 适配器(task-planner)
# 职责:
#   1. 哨兵期:检查 Write/Edit 是否在 plans/ 外(原有功能)
#   2. 运行时并发检测(Rule 23):写入文件是否命中其他 in_progress plan 的 scope
#   3. [2026-09-07 task-v055] 委派门控(Rule 25 执行期):Write/Edit/ApplyPatch 主进程白名单外文件
#      → check-delegation.sh pretool 判定(enforce=exit2 阻断 / warn=注入警告)
# 约束:fail-open —— 任何异常 exit 0 不阻塞指令
input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // .toolName // empty' 2>/dev/null)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // .tool_input.path // empty' 2>/dev/null)"
SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 原有哨兵检查
bash "$SKILL_ROOT/check-scope.sh" "$tool" "$file"
rc=$?
if [ "$rc" -eq 1 ]; then
  echo 'task-planner: 检测到 .plan-required 哨兵——本会话尚无有效计划，禁止写入 plans/ 之外路径。请先调用 Skill(skill="task-planner") 创建计划。' >&2
  exit 2
fi

# [2026-09-07 task-v055] 委派门控(Rule 25 执行期拦截)
# 仅 Write/Edit/ApplyPatch 触发;其他工具直接 return 0
# Edit 的 new_string 行数:从 stdin JSON 截前 4KB(M-4)后 wc -l;字段缺失传 "-"
case "$tool" in
  Write|Edit|ApplyPatch)
    sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null | tr -cd 'a-zA-Z0-9' | head -c 40)"
    sid="${sid:-default}"
    lines_arg="-"
    if [ "$tool" = "Edit" ]; then
      # 截前 4KB 后 wc -l(防 mega-string 撑爆)
      ns="$(printf '%s' "$input" | jq -r '.tool_input.new_string // empty' 2>/dev/null | head -c 4096)"
      if [ -n "$ns" ]; then
        lines_arg="$(printf '%s\n' "$ns" | wc -l | tr -d ' ')"
      fi
    fi
    bash "$SKILL_ROOT/check-delegation.sh" pretool "$file" "$sid" "$lines_arg"
    rc=$?
    if [ "$rc" -eq 2 ]; then
      # enforce 模式阻断:printf JSON 到 stdout 后 exit 2
      # 文案三选一路径(由 check-delegation 通过 sid 比较后判定);此处通用提示
      msg="[delegation-block] 🚫 主进程直做拦截 — file=${file}
按 SKILL.md 路由表派子代理执行(Write/Edit/ApplyPatch 业务代码默认派 code-assistant/executor);
若属误拦,确认文件路径是否应纳入 plans/ 白名单;
若用户明文要求主进程亲为,执行:
  bash ${SKILL_ROOT}/scripts/allow-direct.sh on --confirm-user-requested
(30 分钟窗口;会被 ledger 记录并在终验展示;同会话仅一次)"
      printf '{"additionalContext": %s}\n' "$(printf '%s' "$msg" | jq -Rs . 2>/dev/null || printf '"block"')"
      exit 2
    fi
    # rc=0 时 check-delegation 自身可能已输出 warn JSON(注入);不重复
    ;;
esac

# Rule 23: 运行时并发冲突检测(仅 Write/Edit)
if [ "$tool" = "Write" ] || [ "$tool" = "Edit" ]; then
  # 探测活跃 plan
  plan=""
  CWD="${PWD}"
  if [ -d "$CWD/plans" ]; then
    plan="$(ls -t "$CWD"/plans/*/task_plan.md 2>/dev/null | head -1)"
  fi
  [ -z "$plan" ] && [ -f "$CWD/task_plan.md" ] && plan="$CWD/task_plan.md"
  
  if [ -n "$plan" ]; then
    plan_dir="$(dirname "$plan")"
    current_scope="$(awk '/^## .*执行范围限制/{f=1; next} /^## /{f=0} f' "$plan" 2>/dev/null | grep '^|' | grep -v '^|---' | awk -F'|' '{for(i=3;i<=NF;i++) if($i ~ /\\.[a-zA-Z]/) printf "%s\n", $i}' | tr -d ' ')"
    # 检查写入文件是否在其他 plan 的 scope 中
    for other_plan in $(ls -t "$CWD/plans"/*/task_plan.md 2>/dev/null); do
      [ "$other_plan" = "$plan" ] && continue
      other_dir="$(dirname "$other_plan")"
      other_scope="$(awk '/^## .*执行范围限制/{f=1; next} /^## /{f=0} f' "$other_plan" 2>/dev/null | grep '^|' | grep -v '^|---' | awk -F'|' '{for(i=3;i<=NF;i++) if($i ~ /\\.[a-zA-Z]/) printf "%s\n", $i}' | tr -d ' ')"
      # 简单字符串匹配(file 在 other_scope 中)
      if echo "$other_scope" | grep -qF "$(basename "$file")"; then
        other_taskid="$(basename "$other_dir")"
        other_session="$(awk '/^session_id:/{print $2; exit}' "$other_plan" 2>/dev/null || echo 'unknown')"
        printf '{"additionalContext": %s}\n' "$(printf '[conflict] 文件 %s 可能与其他 plan(%s, session=%s)冲突,请确认 scope' "$file" "$other_taskid" "$other_session" | jq -Rs .)"
        break
      fi
    done
  fi
fi
exit 0
