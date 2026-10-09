# 15e RR/SR 宽容锚扩展 检查点

status: DONE
agent: Code Assistant
S-unit: 15e（worktree task-v158-source-anchor-discipline 内修 2 个 selftest 宽容锚）
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v158-source-anchor-discipline

## 改动清单（仅 2 文件，禁改面零触碰）

1. skills/task-planner/scripts/selftest-root-resolution.sh（RR-16）
   - :176 主断言 `Rule 40-(5[3-9]|6[0-9])` → `Rule 40-(5[3-9]|6[0-9]|7[0-1])`
   - :177 ok 文案、:182 bad 文案同步扩 7x 纪元
   - 新增 :172 级联注释行 [2026-10-10 task-v158]；:174 口径注释更新
   - 兜底判定（50+53 逐号式）保留不动

2. skills/task-planner/scripts/selftest-self-resolution.sh（SR-08）
   - :86 主断言 `grep -cE '含 Rule 40-(5[3-9]|6[0-9])'` → `含 Rule 40-(5[3-9]|6[0-9]|7[0-1])`
   - :89 bad 文案同步；`^40\.` 子条数=6 断言保留不动（按 S-unit 明示）
   - 新增 :85 级联注释行 [2026-10-10 task-v158]

## 实态依据
- SKILL.md:288 索引行 = `详见 references/critical-rules.md（Critical Rules 1-71（含 Rule 40-71 全集…`（grep -n 实证）
- 40-71 命中 7[0-1] 纪元 → 旧正则 6[0-9] 上限脱钩 = FAIL 根因

## 验收证据
- bash selftest-root-resolution.sh → Total: 17 PASS=17 FAIL=0（RR-16 PASS）
- bash selftest-self-resolution.sh → Total: 13 PASS=13 FAIL=0（SR-08 PASS）
- bash -n 双脚本 → BASH-N-OK
- git diff 复核：两文件 diff 面仅为上述锚扩展 + 注释行，无越面改动

## 负结果/风险排除
- 未改 critical-rules.md / SKILL.md / config.json / 其他 5 个 selftest 脚本
- worktree 内其余已修改文件（plans/.plan-attestation、task_plan.md、selftest-drift-check/execution-honesty/reflect-verify/skill-split/veto）= 前序 S-unit 遗留，本 S-unit 零触碰
- 排除风险：SR-08 ok 文案「含 Rule 40-5x」为历史 label 未改（不在 S-unit 指定面），语义仍准确（宽容锚命中 5x/6x/7x 任一）；如后续要 label 精确化可另开 S-unit
