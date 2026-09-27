# S23 A-1 消费层 checkpoint（auto-tier 提示 + AUTO-TIER 复核 + 断言扩展）

- 状态: complete（待主进程验收合并）
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v091（基线 HEAD=3ad2adb, clean）
- 改动文件（仅 3 个，约束内）:
  - skills/task-planner/SKILL.md L64: 行位替换加 trivial 判定/auto-tier env 提示（净增 0 行）
  - skills/task-planner/scripts/check-complete.sh: mechanism-profile 段后插 AUTO-TIER 复核段 +19 行
  - skills/task-planner/scripts/selftest-plan-tier.sh: PT-29..32 断言 + 头注释（28→32）
- 关键决策:
  - SKILL.md 行位替换（净增 0）→ 4 处 ≤558 行数断言全绿（batch-pilot 10/0, knowledge-brief 16/0, execution-stability 19/0, skill-collab 25/0），无需 S31 处理
  - AUTO-TIER 复核条件口径同 CPD 38.1 MISMATCH：Phase 数>2 或 执行范围表 `^|` 行>4（数据行>2）；warn 档不阻断（Rule 38.6「止于 warn」）；不消费新 config 键
  - 插入段注释曾含锚字面量致键③哈希漂移（833bdef1≠df727b47），已改写措辞避锚 → 键③与 HEAD 逐字节一致
  - selftest 夹具构造修正：plan_tier 行形态为 `<!-- plan_tier: mini -->`，replace 须行级插入（S22 awk 同语义）
- 验证记录:
  - bash -n 两脚本通过（SKILL.md 为 markdown 非校验对象）
  - selftest-plan-tier.sh: Total: 32 PASS=32 FAIL=0
  - selftest-final-gate-hash.sh: PASS=22 FAIL=0（S20 SKIP 块零扰动）
  - SKILL.md 行数: 558（=上限，净增 0）
- SKILL.md 行数登记: 实施前 558 → 实施后 558（行位替换，净增 0，无需 S31 补偿）
