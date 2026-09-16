# 检查点 05 — executor S3：critical-rules.md 追加 Rule 36 七子条
> 任务：task-v079-skill-modify-conservatism Phase2/S3；执行者：executor（sonnet-1）；工作树：/mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism
> 范围：仅 skills/task-planner/references/critical-rules.md 文件末尾追加 Rule 36 块，纯新增，零改写既有行。

## 状态：completed
- [x] 已读材料包：knowledge-brief.md（§1/§2/§3/§4）、02-rule36-design-brief.md「## Rule 36 条款设计」节（36.1-36.7 全文逐字采用，仅做条款格式排版）
- [x] 已读目标文件 L245-299（Rule 31/32/35 块格式范式）；确认文件当前 299 行、Rule 35 块 @L292-299
- [x] Edit 追加 Rule 36 块（old_string=35.6 行唯一锚定；标题行 + 引言段 + 36.1-36.7）
- [x] 自验通过（见下）

## diff 摘要
- `git diff --stat`：`skills/task-planner/references/critical-rules.md | 12 ++++++++++++`（1 file changed, 12 insertions(+), 0 deletions）
- 新增区 @L301-312：L301 标题行 `### 36 技能修改保守化与功能删除防护（P0 — task-v079，目标：<brief 标题行全文>）`；L302 引言段（三条链路：错不盲改/删必留痕+确认/默认纯增量，压缩自 brief 用户诉求节 3 句）；L303-312 = 36.1-36.7 七条
- 删除行数 = 0（`git diff | grep -cE '^-[^-]'` = 0），既有行零改写
- worktree `git status --short` 仅 `M skills/task-planner/references/critical-rules.md`，无其他文件变更

## 自验证据
- `grep -cE '^36\.[1-7] ' critical-rules.md` = 7（锚 @L305-311：36.1=305 / 36.2=306 / 36.3=307 / 36.4=308 / 36.5=309 / 36.6=310 / 36.7=311）
- 36.2 含「按 31.2 完成四维归因」「与 31.3 衔接：31.3 已规定执行期内本体修改走后续任务」衔接句
- 36.4 含「属 Rule 28 D6 级硬停点语义（引用不扩列，不改 Rule 28 既有语义）」
- 36.7 含三件消费侧（check-skill-modify.sh 挂 zcode-pretooluse Write/Edit / check-complete.sh SKILL-MODIFY GATE / selftest-skill-modify.sh）+ 开关键 `config.json#skill_modify_enforce`（默认 warn）
- 文件总行数 299 → 311（追加 12 行：标题 1 + 空行 1 + 引言 1 + 空行 1 + 七条 7 + 尾部…实际 12 insertions 与 git stat 一致）

## 边界声明
- 未触碰 Rule 28/31/32/35 既有文字（仅引用衔接）；未改其他任何文件
- 条款正文逐字采用 02-brief「## Rule 36 条款设计」节，仅排版（去 bullet 前缀、36.x 独立成行，密度对齐 31.x/32.x）
