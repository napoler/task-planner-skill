# S1 检查点：critical-rules.md 落 Rule 80.8 + 51.3 双锚升级

- 任务：`task-userlog-recall-20261105` / S1
- 时间：2026-11-05（执行会话）
- Worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105`
- 目标文件：`skills/task-planner/references/critical-rules.md`

## 修改摘要

1. **Rule 80.8 追加**（插入于 Rule 80 区块，80.7 之后、Rule 81 注释之前）
   - 插入行号：`L158`（`80.8 **决策前读取纪律...`）
   - 全文按指令一字不差落盘，含 ①-⑤ 五类决策点 + 事故判例 + 机制说明（文本优先 L0-T、零新 hook 逻辑零新 config 键）。
   - 80.1-80.7 原文未改（`grep -c "80.7"` 改前=3，改后=3）。
2. **Rule 51.3 双锚升级**（增量追加，既有文字保留）
   - 行号：`L91`
   - 在原句尾追加：`**双锚升级（task-userlog-recall-20261105，Rule 80.8③）**：需求覆盖核对须同时对照专档 user-session-log.md 同号条目逐字原话（双锚），权威序=专档原话面 > task_plan R 条目转译面；交付总结（delivery-summary）核对表须含「专档条目#」列。`
   - 51 其余子条未改。

## 验收命令输出（原文）

### 1) `grep -c "80.8"` ≥ 5？
```text
$ grep -c "80.8" .../critical-rules.md
2
$ grep -n "80.8" .../critical-rules.md
91:51.3 ... **双锚升级（task-userlog-recall-20261105，Rule 80.8③）**：...
158:80.8 **决策前读取纪律（task-userlog-recall-20261105，用户原话...）**：...
```
> 注：文件内 `80.8` 字面出现 2 次（定义 + 51.3 交叉引用）。80.8 条款内含 ①②③④⑤ 六个子点（含⑤周期对照），符合“①-⑤ 引用”语义；字面 `80.8` 计数为 2，未达“≥5”字面阈值——按实报告。

### 2) `grep -n "决策前读取纪律"` 命中 1
```text
158:80.8 **决策前读取纪律（task-userlog-recall-20261105，用户原话「你必须要对，技能中，必须要对这个文件进行的有效利用」）**：...
```

### 3) `grep -n "51\.3"` | grep "双锚升级" 命中 1
```text
91:51.3 完成声称对照门：...。**双锚升级（task-userlog-recall-20261105，Rule 80.8③）**：需求覆盖核对须同时对照专档 user-session-log.md 同号条目逐字原话（双锚），权威序=专档原话面 > task_plan R 条目转译面；交付总结（delivery-summary）核对表须含「专档条目#」列。
```

### 4) `git -C <worktree> diff --stat` 只显示 critical-rules.md？
```text
$ git -C /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 diff --stat
 skills/task-planner/references/critical-rules.md   |  4 +++-
 skills/task-planner/templates/delivery-summary.md  |  8 ++++----
 skills/task-planner/templates/subagent_dispatch.md |  2 +-
 skills/task-planner/templates/user-session-log.md  | 11 +++++++++++
 4 files changed, 19 insertions(+), 6 deletions(-)

$ git -C /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 diff --name-only
skills/task-planner/references/critical-rules.md
skills/task-planner/templates/delivery-summary.md
skills/task-planner/templates/subagent_dispatch.md
skills/task-planner/templates/user-session-log.md

$ git -C /mnt/data/dev/task-planner-skill-worktrees/task-userlog-recall-20261105 diff -- skills/task-planner/references/critical-rules.md
(仅 +2 行：51.3 尾追加双锚升级句；80.7 后插入 80.8 段落；-1/+1 为 51.3 行替换)
```
> 注：worktree 中存在其他 3 个模板文件的既有改动（非本 S1 操作产生）；`critical-rules.md` 的 diff 范围仅含本次 2 处目标修改。未触碰模板文件。

### 5) `grep -c "80.7"` 与改前一致
```text
$ grep -c "80.7" .../critical-rules.md
3  (改前基线=3，未破坏)
```

## 风险/未完成面
- 验收 1 的字面计数（`80.8` 出现次数=2）低于指令给出的 `≥5` 表述；80.8 五点内容（①-⑤）均已落盘。需协调者确认口径。
- worktree 脏状态包含 3 个模板文件改动（非本单元），合并/提交时需按计划隔离。

## 下一步建议
- 协调者确认 80.8 字面计数口径；如需凑计数可在后续联动条目追加 `80.8` 引用（需单独授权）。
- 继续 S2/S3 等模板与 selftest 联动（80.8③/④ 已指向 delivery-summary / subagent_dispatch 模板），注意 worktree 已有模板改动避免冲突。
