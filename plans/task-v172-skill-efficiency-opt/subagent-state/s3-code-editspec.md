# s3 code-editspec（task-v172 CA-1 补齐 + CA-2 + CA-3）— 供 code-assistant 精确执行

worktree 根目录：`/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt`
逐条 Edit，old_string 必须与文件当前内容精确匹配（已核对 2026-10-13 工作树状态：UPS 的 awk-guard if/else/fi 已由主进程先行落地，限频块/config 待你补）。

---

## E1 文件：skills/task-planner/config.json

old_string：
```
    "smart_inject_type_gate": {
      "type": "string",
      "enum": ["off", "on"],
      "default": "off",
      "description": "[task-perf-opt Change #5] UserPromptSubmit smart 注入 prompt 类型门控: off=每轮注入(原行为); on=短闲聊/追问(prompt<50 字符且不含 Goal 关键 token)跳过 smart 注入块, 仅保留 [plan-note] 节流注入。opt-in, 默认 off。"
    },
```
new_string：
```
    "smart_inject_type_gate": {
      "type": "string",
      "enum": ["off", "on"],
      "default": "on",
      "description": "[task-perf-opt Change #5] UserPromptSubmit smart 注入 prompt 类型门控: off=每轮注入(原行为); on=短闲聊/追问(prompt<50 字符且不含 Goal 关键 token)跳过 smart 注入块, 仅保留 [plan-note] 节流注入。opt-in, 默认 off。[task-v172 CA-1] default off→on: 每轮无条件注入 0.22-0.26s+1-1.5KB 复利开销实测, 与内容限频双闸启用。"
    },
    "smart_inject_interval": {
      "type": "integer",
      "default": 20,
      "minimum": 0,
      "description": "[task-v172 CA-1 / R3] smart 注入限频周期: 计划文件 mtime 未变时每 N 轮兜底刷新一次(N=0 恢复每轮注入); 计划文件被编辑(mtime 变)立即注入不计数。状态 /tmp/task-planner-ups-inject-<sid>.state; attest --verify 每轮不变(防篡改不降载)。"
    },
    "light_tier_interval_multiplier": {
      "type": "integer",
      "default": 2,
      "minimum": 1,
      "description": "[task-v172 CA-2 / R3] 轻档(plan_tier=mini ∨ execution_lane=L0)陈旧提醒周期倍率: task_plan/progress/findings 的 15/20/25min 阈值乘 N(默认 2=30/40/50)。fail-open: 非数字或计划档位读取失败=不放大。"
    },
```

## E2 文件：skills/task-planner/scripts/zcode-userpromptsubmit.sh

old_string：
```
# 职责 1(smart 注入,Rule 20.4,2026-09-02):活跃计划存在时,每轮注入"结构感知计划复诵块"——
#       Goal / Next Step / Current Phase / in_progress Phase 全文 / Decisions 末 3 行 + progress 尾 5 行,
#       以 ===BEGIN-PLAN-DATA=== / ===END-PLAN-DATA=== 包裹,标记为数据非指令(20.3)。
#       证据:turn-start 注入是防漂移最有效手段;per-tool-call 注入省略(v3 autonomous 结论)。
```
new_string：
```
# 职责 1(smart 注入,Rule 20.4,2026-09-02):活跃计划存在时注入"结构感知计划复诵块"——
#       Goal / Next Step / Current Phase / in_progress Phase 全文 / Decisions 末 3 行 + progress 尾 5 行,
#       以 ===BEGIN-PLAN-DATA=== / ===END-PLAN-DATA=== 包裹,标记为数据非指令(20.3)。
#       [task-v172 CA-1,2026-10-13] 限频: 计划文件 mtime 变更(被编辑)立即注入;未变更时每
#       config.smart_inject_interval 轮(默认 20,0=每轮)兜底刷新——根因=R3: 原每轮无条件注入
#       复利型开销(0.22-0.26s/轮+1-1.5KB/轮,50 轮≈55KB,perf-diagnosis report.md:177-178),
#       且驱使主会话反复重读任务计划文件。Change #5 类型门控 default=on(config 双闸)。
#       per-tool-call 注入省略(v3 autonomous 结论)。
```

## E3 文件：skills/task-planner/scripts/zcode-userpromptsubmit.sh

old_string：
```
  [ "$_smart_skip" = "1" ] && echo "[ups] smart 注入跳过（Change #5 prompt 类型门控：短 prompt 不含 Goal 关键 token; [plan-note] 节流注入不受影响）" >&2
fi

# ─── smart 注入块(Rule 20.4 — 结构感知,字段级提取)──────────────────────────
```
new_string：
```
  [ "$_smart_skip" = "1" ] && echo "[ups] smart 注入跳过（Change #5 prompt 类型门控：短 prompt 不含 Goal 关键 token; [plan-note] 节流注入不受影响）" >&2
fi

# ─── [task-v172 CA-1] smart 注入内容限频(变更触发 + 周期兜底)──────────────────
# WHY(R3,2026-10-13): 用户实测「就这么点工作,来回折腾多次读取 Task 文件……当前这种更新频率
#   是否会导致效率急剧降低?」。根因=smart 注入每轮无条件重扫 task_plan.md 双遍 awk+progress
#   tail-5 并注入 1-1.5KB(0.22-0.26s/轮;50 轮≈55KB 复利,report.md:177-178),主会话被每轮
#   复诵块驱使重读计划文件。改为: ① plan mtime 变化(计划被编辑)立即注入(内容变了才复诵);
#   ② 未变化则每 config.smart_inject_interval 轮兜底刷新(防长对话失锚,默认 20 轮,0=每轮);
#   ③ fail-open: 状态读写异常→照常注入(不跳);attest --verify 每轮不变(防篡改不降载)。
# 状态文件独立于 [plan-note] 节流的 ups_state(零语义干扰,可各自清零/失效)。
inject_state="/tmp/task-planner-ups-inject-${UPS_SID}.state"
inject_interval="$(jq -r '.properties.smart_inject_interval.default // 20' "$SKILL_ROOT/config.json" 2>/dev/null || echo 20)"
case "$inject_interval" in ''|*[!0-9]*) inject_interval=20 ;; esac
if [ "$inject_interval" != "0" ]; then
  plan_mt="$(stat -c %Y "$plan" 2>/dev/null || echo 0)"
  last_mt=""; last_rnd=0
  [ -f "$inject_state" ] && { last_mt="$(sed -n '1p' "$inject_state" 2>/dev/null || true)"; last_rnd="$(sed -n '2p' "$inject_state" 2>/dev/null || true)"; }
  case "$last_rnd" in ''|*[!0-9]*) last_rnd=0 ;; esac
  last_rnd=$(( last_rnd + 1 ))
  if [ "$plan_mt" != "$last_mt" ]; then
    last_rnd=0
  elif [ $(( last_rnd % inject_interval )) -eq 0 ]; then
    last_rnd=0
  else
    _smart_skip=1
  fi
  printf '%s\n%s\n' "$plan_mt" "$last_rnd" > "$inject_state" 2>/dev/null || true
  [ "$_smart_skip" = "1" ] && echo "[ups] smart 注入跳过（CA-1 限频：计划未变更且未到第 ${inject_interval} 轮兜底刷新; [plan-note]/conflict 不受影响）" >&2
fi

# ─── smart 注入块(Rule 20.4 — 结构感知,字段级提取)──────────────────────────
```

## E4 文件：skills/task-planner/scripts/zcode-posttooluse.sh（CA-3：drift-rhythm 3×sed → 1×awk）

old_string：
```
  local count=0 last_inject=0 v
  v="$(sed -n 's/^count[[:space:]]\{1,\}//p' "$sfile" 2>/dev/null | head -1)"
  case "$v" in ''|*[!0-9]*) ;; *) count="$v" ;; esac
  v="$(sed -n 's/^last_inject[[:space:]]\{1,\}//p' "$sfile" 2>/dev/null | head -1)"
  case "$v" in ''|*[!0-9]*) ;; *) last_inject="$v" ;; esac
```
new_string：
```
  local count=0 last_inject=0 _dr_c _dr_l
  # [task-v172 CA-3] 2×sed → 1×awk 单次读(纯进程孵化优化,零逻辑变化)。容错语义不变:
  #   缺文件/坏行 awk 无输出 → _dr_c/_dr_l 空 → 下方 case 兜底 0(fail-open 同原行为)。
  read -r _dr_c _dr_l < <(awk '/^count[[:space:]]/{c=$2} /^last_inject[[:space:]]/{l=$2} END{if(c!="")printf "%s %s\n",c,(l==""?0:l)}' "$sfile" 2>/dev/null)
  case "${_dr_c:-}" in ''|*[!0-9]*) ;; *) count="$_dr_c" ;; esac
  case "${_dr_l:-}" in ''|*[!0-9]*) ;; *) last_inject="$_dr_l" ;; esac
```

## E5 文件：skills/task-planner/scripts/zcode-posttooluse.sh（CA-3：/tmp state 8×cut → 1×awk）

old_string：
```
count="$(cut -d' ' -f1 "$state" 2>/dev/null || true)"
cd_left="$(cut -d' ' -f3 "$state" 2>/dev/null || true)"
cd_findings="$(cut -d' ' -f4 "$state" 2>/dev/null || true)"
cd_progress="$(cut -d' ' -f5 "$state" 2>/dev/null || true)"
f_last="$(cut -d' ' -f6 "$state" 2>/dev/null || true)"
p_last="$(cut -d' ' -f7 "$state" 2>/dev/null || true)"
f_miss="$(cut -d' ' -f8 "$state" 2>/dev/null || true)"
p_miss="$(cut -d' ' -f9 "$state" 2>/dev/null || true)"
```
new_string：
```
# [task-v172 CA-3] 8×cut → 1×awk 单次读(纯进程孵化优化,零逻辑变化;字段序 $1,$3..$9 不变,
# 缺字段/缺文件 → 变量空 → 紧随的 case 兜底 0,fail-open 同原行为;旧 5 字段文件兼容不变)。
read -r count cd_left cd_findings cd_progress f_last p_last f_miss p_miss < <(awk '{print $1,$3,$4,$5,$6,$7,$8,$9}' "$state" 2>/dev/null || true)
```

## E6 文件：skills/task-planner/scripts/zcode-posttooluse.sh（CA-2：tier-aware 提醒周期）

old_string：
```
progress_n="$(printf '%s' "$_cfg_tsv" | cut -f5)"
```
new_string：
```
progress_n="$(printf '%s' "$_cfg_tsv" | cut -f5)"
# [task-v172 CA-2] tier-aware 提醒周期(轻档 ×mult): plan_tier=mini ∨ execution_lane=L0 计划
#   的 task_plan/progress/findings 陈旧阈值 15/20/25min → ×mult(默认 2=30/40/50min)。
#   WHY(R3): 原阈值全 tier 统一,低复杂度任务被 [plan-sync]/[plan-compass] 反复打回写
#   计划文件=「来回读写 task_plan」体感来源之一。fail-open: mult 非数字/0 → 1(不放大);
#   计划档位读取失败 → grep 未命中 → 不放大(保持原阈值,todo/calls 类阈值不动)。
_TIER_MULT="$(jq -r '.properties.light_tier_interval_multiplier.default // 2' "$SKILL_ROOT/config.json" 2>/dev/null || echo 2)"
case "$_TIER_MULT" in ''|*[!0-9]*|0) _TIER_MULT=1 ;; esac
if [ "$_TIER_MULT" -gt 1 ] && grep -qE '(plan_tier:[[:space:]]*mini|execution_lane:[[:space:]]*L0)' "$plan" 2>/dev/null; then
  plan_min=$(( plan_min * _TIER_MULT ))
  findings_n=$(( findings_n * _TIER_MULT ))
  progress_n=$(( progress_n * _TIER_MULT ))
fi
```

---

## 完成后必须做的自检（把每条命令原文+结果写入检查点）
1. `bash -n /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt/skills/task-planner/scripts/zcode-userpromptsubmit.sh && echo SYNTAX_OK_UPS`
2. `bash -n /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt/skills/task-planner/scripts/zcode-posttooluse.sh && echo SYNTAX_OK_PTU`
3. `jq -e . /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt/skills/task-planner/config.json >/dev/null && echo JSON_OK`
4. `cd /home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt && git diff --stat`  （贴入检查点）
