# task-v146 S7 executor 检查点

## 状态: FINAL

## 目标
修复 2 个 selftest 脚本的级联断言（SKILL.md 索引括注已演进 40-55→40-61，锚需随行）。

## 文件清单（仅 2 文件）
1. `/mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/scripts/selftest-capability-persistence.sh`
2. `/mnt/data/dev/task-planner-skill-worktrees/task-v146/skills/task-planner/scripts/selftest-reliability-institution.sh`

## 进度
- [x] Step 1: 写检查点
- [x] Step 2: Read 两文件目标区
- [x] Step 3: 精确修改
- [x] Step 4: 自跑验证
- [x] Step 5: FINAL

## 验证结果
- selftest-capability-persistence.sh: Total: 20 PASS=19 FAIL=1（CP-16 基线预存 FAIL，允许）
  - CP-05 PASS SKILL.md '40-5x/40-6x' 全集声明 =1
  - CP-06 PASS SKILL.md '40-53' 旧纪元字面 =0（演进收口）
- selftest-reliability-institution.sh: Total: 16 PASS=15 FAIL=1（R-12 基线预存 FAIL，允许）
  - R-09 PASS SKILL.md「含 Rule 40-5x/6x 全集」宽容锚 1 ≥1 且越界 1-40 =0
  - R-12 FAIL config.json properties 键数=42（应 40）— 基线预存，允许

## git diff
- 仅 2 文件变更，未 git commit
