# S4 检查点：兼容形态映射 + 残留校验 fail-closed + 接线

- 单元：S4 状态：**DONE（裁决 B 已实施，六项实弹全 PASS）**
- 时间：2026-10-24
- 文件：`/mnt/data/dev/task-planner-skill-worktrees/task-tplrender-20261024/skills/task-planner/scripts/init-session.sh`
- diff：`git diff --numstat` = **197 / 0**（纯新增，未删任何既有行）

## 裁决 B 实施（2026-10-24 coordinator 裁决）

新增 `_strip_html_comments()`（L113-121）：`awk '/<!--/,/-->/ {next} {print}'` 丢弃 HTML 注释区间行。
残留校验（render_template **L257**）与调用侧 gate（**L997**）均先经该过滤器再 grep `\{\{[A-Z_][A-Z_0-9]*\}\}`。
Why：注释里举例 token 名（如 `{{VAR}}`）是文档性内容，非待渲染正文；不过滤会让模板「渲染契约」
注释自触雷（跨单元冲突判例）。非注释行严格度不放松。边界注释已写入助手头 + 残留段（What+Why）。

## 实现要点

1. **8 条兼容映射**（render_template 内 L227-234）：`{task-id}`/`<task-id>`/`<task>` → e_task_id；
   `{task-name}`/`[Brief Description]` → e_task_name；`[DATE]` → e_date；`[YYYY-MM-DD HH:MM]` → e_datetime；
   `${TASK_PLANNER_ROOT:-$HOME/.zcode/skills/task-planner}` → e_root。
   顺序 `<task-id>` 先于 `<task>`；pattern 转义 `\[...\]`/`\$`/`\.`；死串只吃前缀保后缀。
2. **残留校验**（L250-262）：rc 语义 0=成功 / 2=残留（stderr 列清单）/ 1=文件或 sed 错。
3. **接线**（L961-993）：missing_files 复核后、`6/6 verified` 前；`for _rf in *.md` 逐文件一次；rc≠0 → FAIL 行 + `exit 1`。
   位置满足三约束：在 inject_* 之后、在 PROJECT_NAME(L395) 之后、在 verify 回显之前（VC-4）。
4. 结构：`_sed_escape_repl` L105-111 / `_strip_html_comments` L113-121 / `render_template` L172-264 / 接线 L961-993。

## 六项实弹结果（/tmp/s4final/plans/task-s4check，真实 worktree 内置模板，init "S4测试"）

> 注：CWD 守卫要求父目录名为 `plans`，故用 `plans/task-s4check`（规格给的 `/tmp/s4final/task-s4check` 会因守卫 exit 1）。

| # | 项 | 期望 | 实测 |
|---|---|---|---|
| 1 | `bash -n` | 0 | **OK** |
| 2 | init rc | 0 | **0** |
| 3 | 八形态+`<task>` 计数（跳过注释） | 0 | **0**（对照：不过滤=7，即 7 条契约注释 `{{VAR}}`） |
| 4 | VC-2 真实值命中（文件数） | ≥1 | TASK_ID=3 / TASK_NAME=2 / DATE=1 / DATETIME=1 / ROOT=2 |
| 5 | 语义保留 | 在位 | `<用户原话`=1 / `<按需增行`=1 / `#N`=2 |
| 6 | fail-closed（正文注入 `{{UNDEFINED_VAR_XYZ}}`） | rc≠0+token | **rc=1**，`[render] FAIL: verification.md 残留未定义 token: {{UNDEFINED_VAR_XYZ}}` |
| + | 注释豁免（注释内注入同 token） | rc=0 | **rc=0，0 条 render 输出** |
| + | 幂等（同目录二次 init） | 零变化 | **rc=0，7/7 md5 OK** |

渲染样例：`# Task Plan: S4测试`；`- **Started:** 2026-10-24 05:05`；root 渲染为 worktree 绝对路径。

## 遗留风险

1. 模板旧形态尚未全量迁移（实测 worktree 模板仍有 `{task-id}`×5 / `<task-id>`×20 / `<task>`×8 / `TASK_PLANNER_ROOT:-`×16）——由兼容映射覆盖，非缺陷；兄弟单元完成迁移后这些映射退化为 project 级模板兜底。
2. 校验只认 ASCII `{{大写}}`；模板若引入中文大写 token 不被拦（有意收窄防误伤）。
3. 注释豁免的代价：真实待渲染 token 若被误置于 HTML 注释内不会被 fail-closed 捕获（设计取舍，已文档化）。
