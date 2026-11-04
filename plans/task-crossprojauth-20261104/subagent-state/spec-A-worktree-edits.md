# Agent A Spec — Rule 100 工作树/临时文件内放：worktree-isolation.md + 模板族 8 文件 + dispatch 参考 + smart-merge-back 注释

## 背景（自包含）
- 仓库：/mnt/data/dev/task-planner-skill（task-planner 技能源仓）
- 任务 task-crossprojauth-20261104 R2（2026-11-04 用户指令）：worktree 与一切临时文件统一放当前项目 `tmp/`（worktree=`<project-root>/tmp/worktrees/<task-id>`，分支名仍 `wt/<task-id>`）；`.gitignore` 含 `tmp/`（Rule 100）；旧仓外集中目录约定 `<repo-parent>/<repo>-worktrees/<task-id>` 废止。
- worktree-isolation.md 的 L3 头部「路径约定裁决（2026-11-04 用户，Rule 100）」注已由主进程落好，**不要动 L3**。
- 每项执行纪律：先 Read 目标文件相关区 → 确认 old 原文存在且唯一 → Edit；old 不匹配时该文件立即停止并在回报中登记「失配」，禁止猜测改写。只编辑本 spec 列出的文件，禁 git 操作，禁碰 AGENTS.md。

## 编辑清单（11 文件，逐项 old→new）

### 1. skills/task-planner/references/worktree-isolation.md（6 处 Edit）

**E1 §3 整段替换**：从 `## 3. 路径规范（消除散落 — 2026-08-29 立）` 行起、到 `- 分支名仍为 \`wt/<task-id>\`(与路径解耦)` 行止（约 L29–L46）整段替换为下方 NEW。原文（OLD）特征=「该仓专属的集中目录内」「<repo-parent>/<repo>-worktrees/」「~/.zcode-worktrees」「仓外、隐藏目录」「${REPO_PARENT} = 仓库父目录」。

NEW 文本（整段）：

```
## 3. 路径规范（消除散落 — 2026-08-29 立；2026-11-04 修订为 Rule 100 内放）

**强制（用户裁决 2026-11-04，Rule 100）**：所有 worktree 与一切临时产物必须落在**当前项目**的临时目录内，子目录 = `<task-id>`：

```
<project-root>/tmp/worktrees/<task-id>/
```

`${PROJECT_ROOT}` = 当前项目根目录的绝对路径(即任务所属 git 仓根,如 `/mnt/data/dev/task-planner-skill` 或 `~/.zcode`;按部署环境代入实际值),下文命令示例统一以 `${PROJECT_ROOT}` 书写。

**为什么**:原 2026-08-29 约定(`<repo-parent>/<repo>-worktrees/<task-id>`,仓外隐藏目录)解决了仓库旁散落问题,但临时态仍散在各项目 home 目录、跨项目盘点/清理成本高,且临时文件本无统一落点规则。2026-11-04 裁决(Rule 100,task-crossprojauth-20261104 R2)收拢为:worktree+一切临时产物统一落**当前项目** `tmp/`——`.gitignore` 一条 `tmp/` 统一忽略(Rule 100.2),`git worktree list` + `ls <project-root>/tmp/worktrees/` 全量盘点,清理时按子目录逐个处理不再遗漏。旧仓外集中目录约定**废止(2026-11-04)**:存量旧路径 worktree 按 §4/§6 逐个清理,新任务禁用旧路径。

**约束**:
- 必须用**绝对路径**(相对路径会因当前 cwd 解析错位置,落进主仓内部 — 已在 2026-08-29 验证过一次)
- 前置:`<project-root>/.gitignore` 含 `tmp/`(Rule 100.2;验证点 `git check-ignore -q tmp/` exit 0;任务起点缺则追加一行并登记 Decisions Made)
- `tmp/worktrees/` 位于主仓 gitignore 区 — 主仓忽略的是路径,worktree 内部 git 管理不受影响(其自身 HEAD 边界,worktree 内提交仍走 Rule 27)
- 子目录名 = task-id,不带 `wt-` 前缀(basename 语义不变,smart-merge-back.sh/check-conflicts.sh 的 basename=task-id 兼容逻辑不受影响)
- 分支名仍为 `wt/<task-id>`(与路径解耦)
```

**E2 §4 ① 注释行**：old `# ① 创建(路径见 §3 路径规范;分支名 wt/<task-id>)` → new `# ① 创建(路径见 §3 路径规范;分支名 wt/<task-id>;前置: <project-root>/.gitignore 含 tmp/ (Rule 100.2))`

**E3 §4 创建命令**：old `git worktree add ${REPO_PARENT}/<repo>-worktrees/<task-id> -b wt/<task-id> main` → new `git worktree add ${PROJECT_ROOT}/tmp/worktrees/<task-id> -b wt/<task-id> main`

**E4 §4 提交两行**：old `git -C ${REPO_PARENT}/<repo>-worktrees/<task-id> add <本 Phase 产物文件...>` → new `git -C ${PROJECT_ROOT}/tmp/worktrees/<task-id> add <本 Phase 产物文件...>`；old `git -C ${REPO_PARENT}/<repo>-worktrees/<task-id> commit -m "<type>(<scope>): task-<id>/Phase N — <摘要>"` → new `git -C ${PROJECT_ROOT}/tmp/worktrees/<task-id> commit -m "<type>(<scope>): task-<id>/Phase N — <摘要>"`

**E5 §4 清理命令**：old `git worktree remove ${REPO_PARENT}/<repo>-worktrees/<task-id> && git branch -d wt/<task-id>` → new `git worktree remove ${PROJECT_ROOT}/tmp/worktrees/<task-id> && git branch -d wt/<task-id>`

**E6 §5 反模式追加一行**：old `- ❌ 切换会话 CWD 到 worktree(破坏哨兵与 hook 相对路径约定)` → new 保持原行不变并在其后新增一行：`- ❌ 将 worktree/临时文件放在当前项目 tmp/ 之外(2026-11-04 Rule 100 内放;旧仓外集中目录路径已废止,见 §3)`

### 2-9. 模板族 worktree_path 字面（7 文件同型替换）
- skills/task-planner/templates/variant/{bugfix-type.md, test-writing-type.md, performance-tuning-type.md, refactor-type.md, code-edit-type.md, schema-migration-type.md}：
  old `| \`worktree_path\` | \`<repo-parent>/<repo>-worktrees/<task-id>\` |`
  → new `| \`worktree_path\` | \`<project-root>/tmp/worktrees/<task-id>\`(Rule 100:临时产物统一当前项目 tmp/,tmp/ 入 .gitignore) |`
- skills/task-planner/templates/task_plan.md：
  old `| \`worktree_path\` | \`<repo-parent>/<repo>-worktrees/{{TASK_ID}}\` 或 n/a |`
  → new `| \`worktree_path\` | \`<project-root>/tmp/worktrees/{{TASK_ID}}\` 或 n/a(Rule 100:tmp/ 入 .gitignore) |`
- skills/task-planner/templates/variant/deployment-type.md L4：
  old `<!-- 隔离: 涉及运行中基础设施 = §十一 P0 必 worktree(<repo-parent>/<repo>-worktrees/<task-id>) -->`
  → new `<!-- 隔离: 涉及运行中基础设施 = §十一 P0 必 worktree(路径=<project-root>/tmp/worktrees/<task-id>, Rule 100 临时目录统一;tmp/ 入 .gitignore) -->`

### 10. skills/task-dispatch/references/critical-rules-dispatch.md L8
old 片段 `(\`wt/<task-id>\` 分支,\`<repo-parent>/<repo>-worktrees/<task-id>\` 目录)`
→ new `(\`wt/<task-id>\` 分支,\`<project-root>/tmp/worktrees/<task-id>\` 目录 — 临时产物统一当前项目 tmp/,Rule 100;tmp/ 须入 .gitignore)`

### 11. skills/task-planner/scripts/smart-merge-back.sh（仅 2 行注释,代码逻辑零改动——basename=task-id 与新路径兼容）
先 `grep -n 'repo-worktrees\|repo-wt-' ` 定位（约 L105 与 L172）：
- old `#   兼容 task-id 尾缀变体命名(如集中目录 <repo>-worktrees/<task-id> 或旧式 <repo>-wt-<task-id>);`
  → new `#   兼容 task-id 尾缀变体命名(2026-11-04 Rule 100 = <project-root>/tmp/worktrees/<task-id>; 旧集中目录 <repo>-worktrees/<task-id> / 旧式 <repo>-wt-<task-id>);`
- old `# (worktree 目录名按 §11.2 新规范为 <repo>-worktrees/<task-id>, basename 即 task-id;`
  → new `# (worktree 目录名 basename 即 task-id: 2026-11-04 Rule 100 新规范 = <project-root>/tmp/worktrees/<task-id>, 旧 §11.2 集中目录 <repo>-worktrees/<task-id> 亦 basename=task-id;`
（若实际行文本与 old 不完全一致,以 Read 实况为准做最小同义替换,保留行尾 `;`,并在回报中登记实际替换文本）

## 验收（全部跑通后才可回报完成）
1. `grep -c 'repo-parent\|REPO_PARENT' skills/task-planner/references/worktree-isolation.md` = 0
2. `grep -c 'PROJECT_ROOT' skills/task-planner/references/worktree-isolation.md` ≥ 6
3. `grep -rn 'repo-parent\|repo-worktrees' skills/task-planner/templates/` = 0 命中
4. `grep -c 'tmp/worktrees' skills/task-dispatch/references/critical-rules-dispatch.md` = 1
5. `grep -c 'Rule 100' skills/task-planner/scripts/smart-merge-back.sh` = 2
6. `grep -n 'worktree remove ${PROJECT_ROOT}/tmp/worktrees' skills/task-planner/references/worktree-isolation.md` = 1
7. worktree-isolation.md 未出现 §1/§2/§4(合并回合约)/§6 区块的改动（只动了 §3/§4 命令块/§5 追加行）

## 里程碑与回报
- 完成 §1 后写检查点 skills 侧 6 处 Edit 结果 → /mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/01-executor-worktree.md（追加「§1 worktree-isolation.md 完成,6 处 Edit」）
- 全部完成后：检查点追加验收 grep 输出 + 失配登记（若有）+ 最终结论（完成/失配清单）。
- 返回消息=每文件 edit 计数 + 验收 grep 原文 + 检查点路径（8 字段口径:任务/文件/edit/验证/残留/状态/下一步/检查点）。
