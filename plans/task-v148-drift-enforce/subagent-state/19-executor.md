# 19-executor — task-v148 / N2-fix 检查点

## 任务
CR 终审 N2（非阻断 minor）：critical-rules.md Rule 64.3 条款内状态文件描述「两键 {count,last_inject}」
与实现三键（含 due）不一致，行内同步。

## 状态：done

## 落点
- worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v148-drift-enforce
- 文件: skills/task-planner/references/critical-rules.md（第 777 行 = Rule 64.3，本任务自产块内）
- 仅 1 行行内改写，行数 783 不变（改前 783 / 改后 783）

## 改动内容（行内改写）
1. 状态描述：
   - 旧: `（两键 `{count, last_inject}`，fail-open：目录不可写/解析失败即静默跳过）`
   - 新: `（三键 `{count, last_inject, due}`，due=待投递标志——分支命中轮延迟投递的持久位；fail-open：目录不可写/解析失败即静默跳过）`
2. 同句尾性能约束：
   - 旧: `性能约束：状态文件两键读写 O(1)`
   - 新: `性能约束：状态文件三键读写 O(1)`

### 关于「两键」出现两处的说明
任务正文「仅此一处措辞」引用的替换只覆盖状态描述；但验收②要求文件内 `grep '两键'` 0 命中，
同行性能约束「状态文件两键读写」为第二处，必须一并改（同属 64.3 键数描述，语义一致）。
如 CR 判定第二处不应动，回退该 4 字符即可（`三键读写`→`两键读写`），不影响状态描述主改。

## 自验（可复现）
- ① `grep -n '三键' critical-rules.md` → 777 行含新表述；`grep -o '三键 `{count, last_inject, due}`' critical-rules.md | wc -l` = 1
  （文件级 286 行另有既有无关「三键独立」= Rule 29.5，绝对「命中 1」预存不可达，已在回执注明）
- ② `grep -c '两键' critical-rules.md` = 0
- ③ `bash skills/task-planner/scripts/selftest-drift-enforcement.sh` → `Total: 23 PASS=23 FAIL=0`
  （DCE-02 子条锚 `^64\.[1-6] \*\*` = 6 仍在）
- ④ `git diff --numstat -- critical-rules.md` → `18 0`（0 删除行）；`wc -l` 783 → 783（无净新增行）
- 基线：改前 selftest 亦为 23/23（无回退）

## 硬约束核对
- 仅改 64.3 行内键数措辞：PASS
- 禁 git 写（未 commit/未 add/未 stash）：PASS
- 主仓代码只读（仅写 plans/ 下 findings.md 追加 + 本检查点）：PASS
- task_plan.md / progress.md 零改动：PASS

## 遗留 / 下一步
- deferred: 无
- next: 主进程复核 findings.md 回执与 64.3 行文本；如需将「状态文件两键读写」恢复为原样请明确指示。
