<!-- template_type: code-edit -->
<!-- 任务: task-active-plan — 移植上游 .active_plan 指针机制,消除 hook 按 mtime 猜活跃计划的歧义 -->

# Task Plan: 多计划 .active_plan 指针机制

## Goal
移植上游 planning-with-files 的 resolve-plan-dir/set-active-plan 精简版:计划目录引入 `plans/.active_plan` 指针,hook 探测从"mtime 最新猜测"升级为"指针优先、mtime 兜底",消除多活跃计划并行时 hook 注入非预期计划的歧义。来源:task-pwf-reuse 调研发现的可选后续(上游 resolve-plan-dir.sh 解析链),$PLAN_ID 环境变量层不移植(本仓无该约定)。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | resolve-plan-dir.sh:指针有效→输出指针计划;指针缺失/无效→mtime 最新;无 plans→空;兼容 legacy 根 task_plan.md | 四用例脚本测试 | 测试输出 |
| VC-2 | set-active-plan.sh:写指针;init-session.sh 创建计划后自动写指针指向新计划 | 实跑+cat 指针内容 | 测试输出 |
| VC-3 | zcode-userpromptsubmit.sh 与 zcode-posttooluse.sh 探测改为指针优先:指针指向计划 A(mtime 较旧)时 hook 注入 A 而非 mtime 最新的 B;指针无效时回退 mtime | 双 hook 实跑对照(fake 两计划) | 测试输出 |
| VC-4 | plan-doctor.sh 第 2 段显示指针状态(指向/缺失回退说明) | 实跑输出 | 命令输出 |
| VC-5 | 合并回 master + 2 部署位 rsync diff IDENTICAL + smoke.sh 全绿 | git+diff+smoke | 命令输出 |

**outcome: COMPLETE**（2026-09-05,merge ad7900d）——VC-1~VC-5 全部通过(resolve 五场景/set 三模式/init 自动写/双 hook 内容标记对照/doctor/smoke 17-0);移植复用为主,主进程直做已登记例外。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新脚本 | skills/task-planner/scripts/{resolve-plan-dir.sh, set-active-plan.sh} | 上游其他脚本 |
| 改脚本 | scripts/{init-session.sh, zcode-userpromptsubmit.sh, zcode-posttooluse.sh, zcode-sessionstart.sh(仅当其确有 plan 探测), plan-doctor.sh} | 其他既有脚本 |
| 文本 | CHANGELOG.md、SKILL.md(仅 Notes/I-O 一句) | 其他 references |
| 计划 | plans/task-active-plan/** | 其他 plans/ |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 | 已确认 |
|------|------|------|------|--------|
| 上游源码 | resolve-plan-dir.sh 解析链(PLAN_ID→active_plan→mtime→legacy) | 上游 repo scripts/resolve-plan-dir.sh | 必读 | ◐ ledger-append 头注释已含解析链文档,Phase 1 读源码对齐 |
| 本仓现状 | userpromptsubmit/posttooluse 探测段(ls -t 模式) | 两脚本 L20-25/L26-34 | 必读 | ✅ |
| 本仓现状 | sessionstart 是否探测计划 | zcode-sessionstart.sh | 必读 | ☐ Phase 1 |
| 本仓现状 | init-session.sh 尾部(指针写入点) | init-session.sh 末尾 | 必读 | ✅ |

## Current Phase
complete（outcome: COMPLETE,merge ad7900d;2026-09-07 簿记对账:Phase 状态翻转与 outcome 对齐,产物与合并已核实）

## Next Step
无——任务完成;簿记对账 2026-09-07（v053 会话,用户选项 2）

## Phases

### Phase 1: 侦察补全与方案定稿
- [x] 读 zcode-sessionstart.sh 计划解析方式
- [x] 读上游 resolve-plan-dir.sh 源码对齐解析语义
- [x] 方案定稿写入 findings.md
- **Status:** complete
- **Executor:** 主进程（例外理由:zread MCP 仅主进程可用+定向 Read）

### Phase 2: worktree 创建
- [x] git worktree add .../task-planner-skill-worktrees/active-plan -b wt/active-plan master
- **Status:** complete
- **Executor:** 主进程（git 簿记白名单）

### Phase 3: 实施
- [x] 3a 新建 resolve-plan-dir.sh(解析链:指针→mtime→legacy)
- [x] 3b 新建 set-active-plan.sh + init-session.sh 尾部自动写指针
- [x] 3c 两 hook 探测段改指针优先(保留 legacy 兜底)
- [x] 3d plan-doctor 第 2 段指针状态 + CHANGELOG + SKILL.md 一句
- **Status:** complete
- **Executor:** 主进程(移植适配裁剪,例外同 pwf-reuse D4 登记)

### Phase 4: 验证
- [x] resolve 四用例;set-active-plan+init 自动写;双 hook 指针对照;doctor 输出;smoke 全绿
- **Status:** complete
- **Executor:** 主进程(一次性验证命令)

### Phase 5: 终验+合并回+部署同步
- [x] VC 复验→commit→merge→清理→rsync 双位→记忆更新
- **Status:** complete（部署拓扑其后已升级为实体副本 9 位,v053 会话 2026-09-07 diff -r 全 IDENTICAL 复验）
- **Executor:** 主进程(主仓操作白名单)

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`(会话级未跟踪,无其他活跃 worktree) |
| `isolation` | `worktree`(§11.1.4 scripts 命中) |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/active-plan` |
| `branch` | `wt/active-plan` |
| `merge_back` | `pending` |

## Key Questions

1. 指针内容格式?→ task-id 单行(如 task-active-plan),解析为 plans/<task-id>/task_plan.md;路径式也兼容
2. 多计划并行谁写指针?→ init-session 创建时自动指向新计划(最新创建=最可能活跃);手动切换用 set-active-plan.sh;不引入会话级追踪(YAGNI)
3. hook 性能?→ 子进程调用 resolve-plan-dir.sh(~10ms),plan-doctor 实测 sessionstart 159ms 量级,可接受

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 指针文件 = plans/.active_plan,内容 task-id 单行 | 上游同款位置约定(.planning/.active_plan),适配本仓 plans/ 布局 |
| D2 解析链 = 指针有效→mtime 最新→legacy 根目录 | 上游 resolve-plan-dir 同链,保底兼容现状 |
| D3 init-session 自动写指针 | "最新创建即活跃"符合单任务串行主流;多并行时用户/agent 可 set-active-plan 显式切换 |
| D4 hook 调 resolve-plan-dir.sh 子进程而非三处内联 | 单一实现免漂移(上游同设计);性能实测可接受 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 前序:task-pwf-reuse(9b65e2e)已完成 ledger/plan-doctor/gate 信号;本任务是其"后续可选"清单第一项
- v05(plan-resume v0.5)已由并行会话完成合并(01061db),本任务与其无文件重叠
