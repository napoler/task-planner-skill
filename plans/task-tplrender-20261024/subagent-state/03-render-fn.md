# S3 检查点：render_template() 渲染函数主体（{{VAR}} 主形态）

- 单元：S3（仅渲染函数主体；旧形态兼容映射 + 残留校验 = S4，未实现）
- 状态：**DONE**
- 时间：2026-10-24
- worktree：`/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024`
- 目标文件：`skills/task-planner/scripts/init-session.sh`（改前 1023 行 → 改后 1126 行）

## 做了什么

纯增量插入两段（copy_template 之后、inject_requirement_block 之前）：

1. `_sed_escape_repl()`（L105-112）：sed 替换段转义助手，顺序 `\` → `&` → `|`
   （`\` 必须最先，避免二次转义）。Why：值中的 `&`（sed=整匹配）、`|`（定界符）、
   `\`（转义引导）未转义会破坏替换结果。
2. `render_template()`（L160-200）：对传入文件就地（`sed -i`）单遍替换 6 个
   `{{VAR}}` token，函数头含完整变量表（6 变量 × 来源 × 用途）+ What/Why 双层注释
   + sed vs bash 内建取舍说明 + 已知局限。末尾 `return 0` 后留独立序列区供 S4 追加 `-e`。

## 变量来源（实测锚点，非推测）

| token | 来源（文件实态） |
|---|---|
| `{{TASK_ID}}` | `basename "$PWD"`（CWD 守卫 L56 保证 CWD=plans/<task-id>/；与 L998/1011 用法同源） |
| `{{TASK_NAME}}` | `${PROJECT_NAME:-project}`（**L395 `PROJECT_NAME="${1:-project}"`**，非 TASK_NAME） |
| `{{DATE}}` | `${DATE:-$(date +%Y-%m-%d)}`（复用 L479 既有 `DATE=`，防御性兜底） |
| `{{DATETIME}}` | `date '+%Y-%m-%d %H:%M'`（分钟精度） |
| `{{TASK_PLANNER_ROOT}}` | `$(cd "${SCRIPT_DIR}/.." && pwd)`（复用 L61 `SCRIPT_DIR`；脚本内无 TASK_PLANNER_ROOT 变量） |
| `{{PLAN_DIR}}` | `$PWD` |

## diff 摘要

`git diff --stat`：`1 file changed, 103 insertions(+)`，**0 deletions**（`git diff -U0` 行首仅 `+`）→ 未改任何既有行，未接线 copy_template/主流程。

## 自测结果（三项 + 功能）

1. `bash -n init-session.sh` → **exit 0**
2. 函数体内 6 token 各 1 次，且均位于 `sed -i -e "s|{{...}}|...|g"` 语句：
   `-e "s|{{TASK_ID}}|${e_task_id}|g"` … `-e "s|{{PLAN_DIR}}|${e_plan}|g"`（6 条）
3. `git diff` 纯新增 103 行、0 删除 → copy_template 函数体未改
4. 功能测试（/tmp 隔离，提取两函数 + 真实 SCRIPT_DIR）：
   - `TASK_ID=my-task-1`、`PROJECT_NAME='a&b|c\d'` → 渲染后 `name=a&b|c\d` **逐字保留**（&/|/\ 转义正确）
   - `root` 解析为 worktree 的 `skills/task-planner` 绝对路径；`dir` = 计划目录绝对路径
   - 未知 token `{{KEEP}}` 原样保留
   - 幂等：二次渲染 md5 SAME
   - 缺失文件 → stderr WARN + rc=1；空文件/无 token 文件 → rc=0 内容不变

## 遗留风险（≤3）

1. **二次替换**：替换值自身若含 `{{OTHER_VAR}}` 字样会被同遍后续 `-e` 再替换（sed 顺序语义）。真实值域（任务名/路径/日期）概率可忽略，S4 残留校验兜底；已写入函数头「已知局限」。
2. **未接线**：当前 `render_template` 零调用点（S4 负责在 `copy_template` 之后接线）。若 S4 在 `PROJECT_NAME`（L395）赋值前调用，`${PROJECT_NAME:-project}` 会回落 'project' → S4 需保证调用点在 L395 之后。
3. **GNU sed 依赖**：沿用 `sed -i`（脚本 L694 既有同款假设），BSD sed 需 `-i ''`；非本单元范围。
