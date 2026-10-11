# 20-executor — task-v148 / align-fix 检查点

## 任务
R1「对防偏移进行加强」——alignment-review P2 两处联动同步（本任务自产文本的陈旧锚/枚举）：
1. critical-rules.md Rule 64.5 行两处措辞（陈旧行锚 `:28`、陈旧枚举范围 DCE-11~16）
2. zcode-posttooluse.sh 残留「两键」注释 → 三键语义表述

## 状态：done

## 落点
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce
- 文件 1: skills/task-planner/references/critical-rules.md（第 781 行 = Rule 64.5）
- 文件 2: skills/task-planner/scripts/zcode-posttooluse.sh（第 88 行 = 容错注释）

## 改动内容（行内改写，仅两处）
### critical-rules.md Rule 64.5（同 1 行内两处）
1. 陈旧行锚：
   - 旧: `VALID_EVENTS 增 \`drift_check\` 枚举（:28 尾部追加，既有枚举零改动）`
   - 新: `VALID_EVENTS 增 \`drift_check\` 枚举（值尾追加，锚行随实现漂移以 grep VALID_EVENTS 为准，既有枚举零改动）`
2. 陈旧枚举范围：
   - 旧: `静态断言 DCE-01~10 + 行为级 fixture DCE-11~16`
   - 新: `静态断言+行为级 fixture（DCE-01~23，随守护面演进）`
   - 结果句：`守护面=\`scripts/selftest-drift-enforcement.sh\`（静态断言+行为级 fixture（DCE-01~23，随守护面演进），fixture 范式对照 selftest-four-file-dataflow.sh）`

### zcode-posttooluse.sh 第 88 行（残留「两键」）
- 旧: `# 容错: 旧两键 state（无 due 键）或坏行 → due 按 0 处理（向后兼容）。`
- 新: `# 容错: 三键 state {count, last_inject, due}（due=待投递持久位；缺 due 的旧 state）或坏行 → due 按 0 处理（向后兼容）。`
- 与 N2（Rule 64.3）同款语义：due=待投递持久位；`grep '两键'` 全文件 0 命中。

## 自验（可复现）
- ① `grep -c ':28 尾部追加' critical-rules.md` = 0；`grep -c 'DCE-01~23' critical-rules.md` = 1
- ② `grep -c '两键' zcode-posttooluse.sh` = 0
- ③ `bash skills/task-planner/scripts/selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`（无回退）
     `bash skills/task-planner/scripts/selftest-drift-check-subagent.sh` → `Total: 20 PASS=20 FAIL=0`（无回退）
- ④ `bash -n skills/task-planner/scripts/zcode-posttooluse.sh` → OK

## 硬约束核对
- 仅动这两文件这两处：PASS（git status 修改集与改前一致，未新增/未删文件）
- 主仓只读：PASS（仅写 plans/ 下 findings.md 追加 + 本检查点）
- 禁 git 写（未 commit/add/stash/reset）：PASS
- task_plan.md / progress.md 零改动：PASS

## 遗留 / 下一步
- deferred: 无
- next: 主进程复核 findings.md 回执与两处行文本；如需措辞微调请明确指示。
