# Task Plan: 部署 master 最新版 task-planner 系 skill 到各平台
<!-- template_type: deployment -->

## Goal
执行用户指令"将最新修改版本安装到各个平台当中"：以 canonical 仓 /mnt/data/dev/task-planner-skill（master ad7900d）为唯一 truth source，把落后部署位同步到最新。调查已确认 ~/.zcode(×3)/~/.claude(×4)/~/.agents(×1) 共 8 个实体副本部署位与 master 字节级一致（diff 0 条、SKILL.md 哈希 0e56bb1d… 相同）；唯一落后的是 ~/.config/opencode/skills/task-planner（63 文件旧薄壳 vs 96 文件，缺 docs/lib/tests/install.sh 与 check-3file-gate/ledger-append/plan-doctor/resolve-plan-dir/set-active-plan 五脚本，SKILL.md/references/templates 均旧版）。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯部署快照替换，无代码编辑） |
| `session_id` | 会话内生成（单会话任务） |
| `worktree_path` | 不适用（部署动作写入仓外部署位，canonical 源码零改动） |
| `scope_files` | `~/.config/opencode/skills/task-planner/**`（整目录替换）、`plans/task-deploy-master-20260905/**`、记忆文件、plans/INDEX.md |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | opencode 部署位与 canonical skills/task-planner 字节级一致 | `diff -rq` 输出为空 | 命令输出留 progress.md |
| VC-2 | 8 个既有部署位（zcode×3/claude×4/agents×1）保持与 canonical 一致（本任务零改动不破坏） | `diff -r` 逐一 exit 0 | 命令输出留 progress.md |
| VC-3 | 仓根无本次任务残留污染（除任务前既有未跟踪项 .plan-required/.zcode/plans/progress.md） | `git status --short` 对照任务前快照 | 命令输出留 progress.md |
| VC-4 | 记忆 task-planner-repo-deploy-flow.md 已更新：部署状态、opencode 纳管、init-session 仓根运行坑 | Read 复核 | 记忆文件路径 |
| VC-5 | plans/INDEX.md 已刷新且本任务终态正确；task-active-plan 状态差异已向用户报告 | sync-todos --index 输出 + 报告 | INDEX.md |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 部署位写入 | ~/.config/opencode/skills/task-planner（整目录 rm+cp 快照替换） | 其余 8 个部署位内容改动（仅只读验证） |
| 源码 | （零改动） | skills/task-planner 任何源文件 |
| 计划 | plans/task-deploy-master-20260905/** | 其他 plans/ 目录（task-active-plan 状态仅报告不擅改） |
| 簿记 | ~/.zcode/cli/memories/.../memory/**、plans/INDEX.md（sync 脚本） | 其他会话状态 |

## Phases

### Phase 1: 现场清理与计划初始化
- **Status:** complete
- **Executor:** 主进程（例外理由：计划文件属主进程允许的纯计划/配置类；误写清理为删除本会话自己 12:10 创建的 4 个仓根模板 + /mnt/data/dev/.active_plan，git status 已对照确认均为新增未跟踪项，progress.md 原有文件未动）
- 已完成：误写清理 + plans/task-deploy-master-20260905 正确初始化（5 文件）+ plans/.active_plan 指向本计划
- 证据：本计划文件存在、`cat plans/.active_plan` = task-deploy-master-20260905

### Phase 2: opencode 部署位同步
- **Status:** complete
- 证据：diff -rq 空输出、96/96 文件（progress.md Phase 2 段）、备份 /tmp/opencode-task-planner-backup-20260905.tar.gz
- **Executor:** 主进程（例外理由：机械整目录快照替换 = rm -rf + cp -rL + diff -rq 三条命令，无逐文件编辑判断，派子代理的 prompt 传递成本高于执行本身；非业务代码编辑，Rule 14 不适用）
- 步骤：`rm -rf ~/.config/opencode/skills/task-planner && cp -rL skills/task-planner ~/.config/opencode/skills/task-planner`，随后 `diff -rq` 复验为空（VC-1）
- 风险控制：目标位为旧版快照（备份惯例 ~/skill-deploy-backups-20260904 在册），cp 前先 tar 备份到 /tmp 以便回滚

### Phase 3: 全平台终验 + 记忆/索引更新 + 交付报告
- **Status:** complete
- 证据：9/9 位 IDENTICAL（progress.md Phase 3 段 Test Results）、记忆已重写、INDEX 已刷新

---

## 🏁 终验记录（Verification Contract 复验）

| # | 判定标准 | 结果 | 证据 |
|---|----------|------|------|
| VC-1 | opencode 位与 canonical 字节级一致 | PASS | diff -rq 空输出、96/96 文件（progress.md Phase 2） |
| VC-2 | 8 既有位保持一致 | PASS | diff -r ×8 全 exit 0（progress.md Phase 3） |
| VC-3 | 仓根无任务残留污染 | PASS | git status 仅任务前既有 3 项；.plan-required 消失=清哨兵预期 |
| VC-4 | 记忆已更新 | PASS | task-planner-repo-deploy-flow.md 重写（9 位拓扑+基线 ad7900d） |
| VC-5 | INDEX 刷新 + task-active-plan 差异已报告 | PASS | sync-todos --index 输出；报告见交付段 |

**outcome: COMPLETE**（2026-09-05）——VC-1~VC-5 全 PASS。委派统计：0/3 子代理执行（3 Phase 全部主进程直做，例外理由已在各 Phase Executor 字段登记：机械 shell 快照替换与只读验证+簿记，无业务代码编辑）。
- **Executor:** 主进程（例外理由：只读验证命令 + 记忆簿记，无代码编辑）
- 步骤：8 位 diff -r 复验（VC-2）→ git status 对照（VC-3）→ 更新记忆（VC-4）→ sync-todos --index（VC-5）→ 清哨兵 plan-created.cjs → 交付报告（含 task-active-plan 状态差异说明）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | 状态 | findings 落点 | verify_done |
|------|---------------|------|------|---------------|-------------|
| （本任务无子代理派发，全部 Phase 已登记主进程直做例外理由） | - | - | - | - | - |

## Decisions Made

| 时间 | 决策 | 理由 |
|------|------|------|
| 2026-09-05 | opencode 纳入本次部署范围 | 用户指令"各个平台"；该位确为 task-planner 部署位且落后 33 文件；与其他 8 位同构同步 |
| 2026-09-05 | 8 个既有部署位不重写 | diff 已证明字节级一致（凌晨 active-plan 会话已部署），重写是无谓风险 |

## Errors

| 时间 | 错误 | 处置 |
|------|------|------|
| 2026-09-05 12:10 | init-session.sh 在仓根误跑（漏 `cd $_`）：4 模板写仓根 + 指针误写 /mnt/data/dev/.active_plan（脚本 PLAN_ROOT=`cd ..` 语义在仓根运行时指向仓外） | 已全部删除；于 plans/task-deploy-master-20260905 正确重建；经验记入 notepad-learnings 与记忆 |
