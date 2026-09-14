# Task Plan: 全平台重部署 master 9b167fe 到 9 实体部署位

## Goal

以 canonical 仓 master `9b167fe`（= ad7900d + 去重 5228d06 + Rule 27 门控）为唯一 truth source，重部署 3 个 task-planner 部署位（zcode/claude/opencode），diff -r 终验 9/9 位一致；6 个兄弟 skill 部署位经预检 IDENTICAL 零改动保持。

> 授权来源：用户指令"在所有平台中重新部署最新版本"（2026-09-05，显式授权，含保护区部署位写入）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯部署快照替换，canonical 零改动） |
| `session_id` | deploy-9b167fe-20260905 |
| `worktree_path` | 不适用（部署写入仓外部署位，canonical 源码零改动；沿用 task-deploy-master-20260905 先例） |
| `scope_files` | `~/.zcode/skills/task-planner`, `~/.claude/skills/task-planner`, `~/.config/opencode/skills/task-planner`（整目录替换）、plans/task-deploy-9b167fe/**、记忆文件、plans/INDEX.md |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 3 个 task-planner 部署位与 canonical(master 9b167fe) 字节级一致，且 WORKFLOW.md 不存在于部署位（删除同步） | `diff -rq` 输出为空 + `ls WORKFLOW.md` 不存在 | 命令输出留 progress.md |
| VC-2 | 6 个兄弟部署位（todo-skill×2/plan-resume×2/task-drift-guard×2）保持与 canonical 一致（本任务零改动不破坏） | `diff -rq` 逐一 | 命令输出留 progress.md |
| VC-3 | canonical 仓零改动：master HEAD 仍 9b167fe，skills/ 无未提交变更，git status 无新增项 | `git log -1` + `git status --porcelain skills/` | 命令输出留 progress.md |
| VC-4 | 记忆 task-planner-repo-deploy-flow.md 同步基线更新为"9 位 = 9b167fe 已部署" | Read 复核 | 记忆文件 |
| VC-5 | plans/INDEX.md 刷新且本任务入册终态 | sync-todos --index | INDEX.md |

**终验规则**：全部 VC 通过 → COMPLETE。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 部署位写入 | 3 个 task-planner 部署位（rm -rf + cp -rL 整目录替换,先 tar 备份到 /tmp） | 6 个兄弟部署位内容改动（仅只读 diff） |
| 源码 | （零改动） | skills/task-planner 任何源文件 |
| 簿记 | 记忆 task-planner-repo-deploy-flow.md、plans/INDEX.md | 其他会话状态 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部知识库 | 记忆 task-planner-repo-deploy-flow.md（9 位拓扑/SOP/verify.sh 误报警示） | ~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/ | 必读 | ☑ 本会话已通读 |
| 项目内部知识库 | 上次部署计划 plans/task-deploy-master-20260905/（rm+cp+diff 范式/备份惯例） | plans/ | 参考 | ☑ 已读关键段 |
| 项目内部知识库 | master 变更清单 ad7900d..9b167fe | git diff 输出（8 files,仅 task-planner） | 必读 | ☑ 已确认 |

## ⚠️ 核心问题定义

**核心问题**：部署端停留 ad7900d 旧快照（缺 Rule 27 门控与全部去重修正），实体副本模型下不会自动传播——按 SOP 显式重部署能否达成 9/9 位与 master 9b167fe 字节级一致？能（SOP 已验证过一轮）。

**核心问题判断**: [x] 能交付 [x] 不解决则部署端持续落后 [x] 方法清晰（备份→rm→cp -rL→diff -r）

## Current Phase

已交付（无活跃 Phase — outcome: **COMPLETE**,2026-09-05 17:45）

## Next Step

无后续动作。部署基线 = master 9b167fe,9/9 位字节级一致;回滚点 /tmp/deploy-backup-9b167fe/。

## Phases

### Phase 1: 计划初始化与预检
- [x] init-session 5 文件 + active_plan 指针
- [x] 变更范围确认：`git diff --name-status ad7900d..master` = 8 files 仅 skills/task-planner/**（7 M + WORKFLOW.md D）
- [x] 6 个兄弟部署位预检 diff -rq = 全部 IDENTICAL（零改动依据）
- **Status:** complete
- **Executor:** 主进程（例外理由:git 编排+计划文档白名单）

### Phase 2: 备份 + 3 位重部署
- [x] tar 备份 3 个 task-planner 部署位到 /tmp/deploy-backup-9b167fe/
- [x] 逐位 `rm -rf <位> && cp -rL $REPO/skills/task-planner <位>`（rm+cp 整目录替换 = 同步 WORKFLOW.md 删除;禁逐文件挑拣）
- **Status:** complete
- **Executor:** 主进程（例外理由:机械整目录快照替换 = 三条命令,无逐文件编辑判断（上次部署同理由）;部署位写入已获用户显式授权）

### Phase 3: 9 位终验 + 记忆/索引更新 + 交付
- [x] diff -rq 复验 3 个重部署位 + 6 个兄弟位（9/9 IDENTICAL）+ WORKFLOW.md 缺席确认
- [x] canonical 零改动核验（VC-3）
- [x] 记忆基线更新（VC-4）+ INDEX 刷新（VC-5）+ 交付报告
- **Status:** complete
- **Executor:** 主进程（例外理由:git/簿记编排与终验白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（canonical 只读;部署位写入在仓外,用户已显式授权） |
| `isolation` | `direct`（部署动作非实现类开发,canonical 源码零改动,沿用上次部署先例） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-05 | S1 |
| Phase 2 | ☑ | 2026-09-05 | S1 |
| Phase 3 | ☑ | 2026-09-05 | S1 |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 只重部署 3 个 task-planner 位,兄弟位仅验证 | master 变更仅 task-planner（git diff 证据）;兄弟位预检 IDENTICAL;写入最小化 |
| rm -rf 整目录替换而非 cp 覆盖 | cp 不删除多余文件——WORKFLOW.md 已在 master 删除,覆盖式 cp 会留残影导致 diff 不一致 |
| 重部署前 tar 备份到 /tmp | 上次部署惯例;/tmp 在扫描路径外合规;回滚廉价 |
| 验证用 diff -r 不用 verify.sh | memory 警示:verify.sh 两态判定对实体副本误报 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| （暂无） | — | — |

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-09-05 | 范围自检（只触碰 scope 3 部署位+簿记,canonical 零写入,6 兄弟位只读）+ 每步命令即验（部署即 diff） | 全部 | ALIGNED（未单独跑 Skill("task-drift-guard"),以范围自检+即时复验替代,如实记录） |

## 📊 委派统计（Rule 25.4）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 3 |
| 主进程直做 Phase 清单 | P1 编排+预检;P2 机械三命令替换（上次部署同理由登记）;P3 编排+终验 |
| 委派率 | 0%（均有登记理由） |

## 🔗 Subagent Handoff 登记表

无子代理派发。

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|-------------|
| — | — | — | 无派发 | — | — | — | — | — |
