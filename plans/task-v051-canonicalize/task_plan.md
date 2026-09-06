# Task Plan: plan-resume v0.5.1 改动收编 canonical + 全平台部署

## Goal

把部署位 `~/.agents/skills/plan-resume/scripts/select-and-resume.sh` 的 v0.5.1 改进（auto-pushed-by-cron 防重入改选逻辑,18:07 出现于部署位）收编回 canonical 仓并提交（经 worktree 隔离）,随后部署 2 个 plan-resume 部署位,9/9 位 diff 终验一致。

> 授权来源：用户 2026-09-05 选定"选项 A（收编回 canonical 再全平台部署）"——确认该改动为预期改动。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（原样收编既有改动,零创作判断;smoke 回归兜底） |
| `session_id` | v051-canonicalize-20260905 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v051-canonicalize` |
| `scope_files` | `skills/plan-resume/scripts/select-and-resume.sh`（canonical,收编目标）、`~/.claude/skills/plan-resume/**`、`~/.agents/skills/plan-resume/**`（部署位）、plans/task-v051-canonicalize/**、记忆文件 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | canonical 的 select-and-resume.sh 与部署位 v0.5.1 版本内容一致（收编完整） | diff -q | worktree 内 diff 输出 |
| VC-2 | plan-resume smoke 回归通过 | bash skills/plan-resume/tests/smoke.sh | smoke 输出 |
| VC-3 | master 收到 --no-ff 合并,commit 含 v0.5.1 改动;worktree/分支清理 | git log + worktree list | 命令输出 |
| VC-4 | 2 个 plan-resume 部署位（claude/agents）与 canonical 一致,9/9 位终验 IDENTICAL | rm+cp -rL 后 diff -rq ×9 | 命令输出留 progress.md |
| VC-5 | canonical 除本次收编外零副作用（git show --stat 仅 1 文件）;记忆基线更新 | git show --stat + Read | 输出留 progress.md |

**终验规则**：全部 VC 通过 → COMPLETE。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| canonical | skills/plan-resume/scripts/select-and-resume.sh（仅此 1 文件,原样收编） | 其他任何源文件;禁止"顺手改进"收编内容 |
| 部署位 | 2 个 plan-resume 位整目录替换（先 tar 备份） | 其他 7 位内容改动（仅只读验证） |
| 簿记 | 记忆基线行、plans/INDEX.md | 其他会话状态 |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读 | 已确认 |
|------|-----------|------|------|--------|
| 项目内部知识库 | v0.5.1 差异全文（@@ -219,7 +219,28 @@ 防重入改选块） | diff -u 输出（会话内） | 必读 | ☑ 已逐行审读:逻辑自洽,含 v0.5.1 注释 |
| 项目内部知识库 | 部署 SOP（rm+cp -rL+diff -r,verify.sh 误报警示） | memory task-planner-repo-deploy-flow.md | 必读 | ☑ |
| 项目内部知识库 | plan-resume smoke 套件 | skills/plan-resume/tests/smoke.sh | 必读 | ☑（将运行） |

## ⚠️ 核心问题定义

**核心问题**：部署位出现未回写 canonical 的正向改动（v0.5.1）,违反 truth source 原则——收编+提交+重部署能否恢复"canonical 唯一事实源 + 9 位一致"且不丢改动？能（先拷回再整目录替换,顺序保证不丢）。

**核心问题判断**: [x] 能交付 [x] 不解决则 truth source 持续分裂 [x] 方法清晰

## Current Phase

已交付（无活跃 Phase — outcome: **COMPLETE**,2026-09-05 18:2x）

## Next Step

无后续动作。部署基线 = master 48340c0（9/9 IDENTICAL）;回滚点 /tmp/deploy-backup-9b167fe/（含 plan-resume-2targets-pre-v051.tar.gz）。

## Phases

### Phase 1: 计划初始化与 worktree 建立
- [x] init-session 5 文件 + plan-created 清哨兵
- [x] 收编前快照确认:漂移文件 mtime 稳定（18:07:27,无后续变化）,差异仍在一处
- [x] worktree 建立（wt/task-v051-canonicalize @ master 8732dd9）
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排+计划文档白名单）

### Phase 2: 收编 + 提交 + 合并回（worktree 隔离）
- [x] 部署位 v0.5.1 文件拷入 worktree 对应路径 → diff -q 复验与部署位一致（VC-1）
- [x] plan-resume smoke 回归（VC-2）
- [x] commit（Rule 27 message 格式）→ 主仓 merge --no-ff → Read 复验 → worktree/分支清理（VC-3）
- **Status:** complete
- **Executor:** 主进程（例外理由:原样收编=单文件拷贝,零编辑判断;规则文档/脚本快照替换,Rule 14 不适用（同上次部署先例）;smoke 为只读验证）

### Phase 3: 全平台部署 + 9 位终验 + 簿记 + 交付
- [x] tar 备份 2 个 plan-resume 位 → rm -rf + cp -rL 重部署 → diff -rq
- [x] 9/9 位终验（VC-4）+ canonical 副作用核验（VC-5）
- [x] 记忆基线更新 + INDEX 刷新 + 计划终验 + 交付
- **Status:** complete
- **Executor:** 主进程（例外理由:机械三命令替换+簿记编排（上次部署同理由））

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（漂移文件已稳定;worktree 隔离收编;部署位有备份） |
| `isolation` | `worktree`（canonical skill 源码变更,实现类强制隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v051-canonicalize` |
| `branch` | `wt/task-v051-canonicalize` |
| `merge_back` | `merged(48340c0)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-05 | S1 |
| Phase 2 | ☑ | 2026-09-05 | S1 |
| Phase 3 | ☑ | 2026-09-05 | S1 |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 原样收编,零改写 | 收编语义=把既有改动纳为正典;任何"顺手优化"都会偏离用户确认的版本 |
| 收编顺序:先拷回→再整目录替换部署位 | 保证 v0.5.1 改动在任何覆盖操作前已安全入库 |
| 只部署 2 个 plan-resume 位 | 变更范围仅 plan-resume;其余 7 位本轮已验证一致 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| （暂无） | — | — |

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-05 | 范围自检（canonical 仅 1 文件/部署仅 2 位/其余 7 位只读）+ 每步即验（收编即 diff、部署即 diff、smoke 39/39）+ Rule 27 dogfood（e87cde5 逐 Phase 提交） | 全部 | ALIGNED（未单独跑 Skill("task-drift-guard"),以范围自检+即时复验替代,如实记录） |

## 📊 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 3 |
| 主进程直做 Phase 清单 | P1 编排;P2 单文件拷贝+smoke（零编辑判断）;P3 机械替换+簿记（均有登记理由） |
| 委派率 | 0%（均有登记理由） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|-------------|
| — | — | — | 无派发 | — | — | — | — | — |
