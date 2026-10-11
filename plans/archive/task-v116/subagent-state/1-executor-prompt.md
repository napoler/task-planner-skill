# 根目录文档刷新任务书（subagent-state/1-executor-prompt.md）

执行体：executor · WT=/mnt/data/dev/task-planner-skill-worktrees/task-v116 · 只改 README_zh.md+INSTALL_zh.md

## 实测基线（直接采用，逐项落笔前仍 ls 复核）
- variant=29（video/image 家族 12 类）/config.json properties=40/scripts/ 81 项（.sh 72 含 42 selftest）/init-session 建 6 计划文件/Rules 1-45
- 安装脚本实位=skills/task-planner/install.sh（实 flag=--canonical/--tools/--no-verify/--no-backup/--dry-run；**无** --target/--uninstall/--force）
- 卸载=skills/task-planner/uninstall.sh；校验=skills/task-planner/lib/verify.sh；session-catchup=skills/task-planner/scripts/session-catchup.ts（bun/node，非 python）；英文版实位=skills/task-planner/{INSTALL,README}.md
- 安装模型=多工具检测软壳（detect-tools 五工具），非「~/.claude 单目录+--target」

## 刷新项（六类）
1. 安装命令口径：`bash scripts/install.sh`→`bash skills/task-planner/install.sh`；幽灵 flag 行重写（--target 行→多工具软壳模型描述；--uninstall→`bash skills/task-planner/uninstall.sh`；--force 行删或改实 flag）；`bash scripts/validate.sh`→`bash skills/task-planner/lib/verify.sh`；`bash scripts/uninstall.sh`→`bash skills/task-planner/uninstall.sh`
2. session-catchup.py 幽灵：全部→session-catchup.ts（bun/node）；INSTALL:61 python3 依赖行改 node/bun 或标注可选
3. 数字簇：13 变体→「29 类（含 video/image 家族 12 类）」；37 键→40；55 个脚本→「81 项（.sh 72 个，含 42 selftest）」；Rules 1-39→1-45；「5 个模板文件」→6；目录树补 knowledge-brief.md；1.3MB→实测 du 值
4. INSTALL:315 英文死链→skills/task-planner/{INSTALL,README}.md
5. 「26 个模板」类→实测 39 或「以 ls 为准（2026-10-02 实测）」
6. 保持语义通顺，不扩写不重排结构

## 验收
- grep 零残留：`grep -n "bash scripts/|session-catchup.py|13 变体|37 键|Rules 1-39|5 个模板文件" 两文档`=0
- 实测数字逐项对照列出
- checkpoint 含最终结论 8 字段块

## Scope 禁改
只改 README_zh.md+INSTALL_zh.md；禁动 skills/；禁 git add/commit；禁动 worktree 外文件

## 返回格式（8 字段，8 字段后不得有任何内容）
```
status: done | partial | failed
acceptance: <n>/<3> pass — 逐项
files: ...
evidence: ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: #### [sub:1-executor] | none
blockers: none
confidence: HIGH
```
