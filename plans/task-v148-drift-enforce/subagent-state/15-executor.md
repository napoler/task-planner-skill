# S7-fix2 执行检查点（15-general / 22.7 换道重派）

status: done
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce (branch wt/task-v148-drift-enforce)

## 关键发现（入场事实）
- 前次派发**并非零落地**：worktree 内 zcode-posttooluse.sh 已含 F9/F10 修复草案
  （due 第三键 + 末尾延迟 emit + end-emit 前置守卫），selftest-drift-enforcement.sh 已扩到 21 断言（DCE-19/20/21）。
- 但复跑 selftest 暴露 **2 处真实 FAIL**（DCE-20 bytes=188；DCE-21 due=1），修复草案未真正闭环。

## 本轮实际修复（最小侵入，仅 2 文件）
1. `skills/task-planner/scripts/zcode-posttooluse.sh`
   - 新增「F10 完结/超龄 → 清 due」块，置于 `age` 计算之后、既有 `:147 [age>86400] && exit 0` 之前。
     What/Why 注释含 Rule 64.3 + Rule 45。
   - 根因：早调用写 due=1，但既有 :147/:150/:155 静默守卫直接 exit 0，永远到不了末尾 end-emit，
     due 残留。新块「同条件重查」（task_plan.md / verification.md 的 outcome + age>24h）只清状态、零 stdout，
     不修改任何既有分支/守卫。
   - F9 延迟 emit 结构保留（早调用仅计数+due，末尾统一 emit → 单轮单 JSON）。
2. `skills/task-planner/scripts/selftest-drift-enforcement.sh`
   - 修正 DCE-20 fixture：`- **Outcome:** COMPLETE` → `- **outcome: COMPLETE**`。
     根因：既有守卫正则 `outcome: *(COMPLETE|BLOCKED)` 要求值紧随 `outcome:`；仓内真实约定为
     `- **outcome: COMPLETE**（...）`（grep plans/*/task_plan.md 实证）。旧 fixture 格式不匹配既有正则，
     致守卫不触发、emit 188 字节。

## 验收证据（全部可复现）
- `bash -n zcode-posttooluse.sh` → OK
- `selftest-drift-enforcement.sh` → **Total: 21 PASS=21 FAIL=0**
- `selftest-drift-check-subagent.sh` → 20/20
- `selftest-four-file-dataflow.sh` → 18/18；`selftest-registry.sh` → 5/5 (rows=61=actual)
- 独立复现（reviewer 12-call 路径，rhythm N=10 + todo_n=10 同频）：**MAXLINES=1**（master 曾在 call10=2 行）
- 独立 F10 三场景：task_plan.md outcome COMPLETE / verification.md outcome COMPLETE / mtime>24h
  → 均 **bytes=0 且 due=0**

## 约束遵守
- 仅动 zcode-posttooluse.sh + selftest-drift-enforcement.sh；主仓只读；无 git 写操作；critical-rules.md 零改动。
- 函数计数语义保持（每次工具调用 +1）；单次调用 stdout ≤1 行 JSON（0 或 1 行）。
