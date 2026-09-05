<!-- template_type: code-edit -->
<!-- 任务: task-pwf-reuse — 复用上游 planning-with-files v3 已有实现（ledger 账本/plan-doctor/gate 信号升级） -->

# Task Plan: 复用上游 planning-with-files 已有实现

## Goal
将上游 [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) v2.4x/v3 的成熟实现移植进 task-planner,替换/增强 2026-09-05 task-3file-enforce 中自研的弱信号部分。用户原话："该项目 已有 实现 可以复用该项目的 已有实现"。

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据 |
|---|----------|----------|------|
| VC-1 | ledger-append.sh 移植完成:事件枚举/tick 全局单调/flock/UTF-8 安全保留,plan-dir 用显式传参简化;写入 plans/<task-id>/ledger-<agent>.jsonl 格式与上游一致(`{"tick","ts","agent","phase","event","summary","files"}`) | 脚本实跑 3 事件+tick 递增+jq 解析每行 | 测试输出 |
| VC-2 | check-3file-gate.sh 信号升级:Phase 开始以来 ledger 有新增行→PASS;无新增→FAIL;mtime 降为无 ledger 时的 fallback;上游"mtime 不可靠"批评在自设计中被吸收(注释注明) | ledger 有/无新增双用例+mtime fallback 用例 | 测试输出 |
| VC-3 | plan-doctor.sh 适配移植:检查 4 个 zcode hook 位(plan 探测/注入输出/scope)/部署面(2 实体位)/attestation/延迟;全部 exit 0 且诊断项在本机可跑通 | bash plan-doctor.sh 输出无 FAIL | 命令输出 |
| VC-4 | SKILL.md 契约同步:执行循环 3c 动作留痕含 ledger-append 调用点(Phase 翻转=phase_complete/子代理回填=progress/错误=error/gate 拦截=gate_block);critical-rules.md 19.2 补 ledger 语义信号优先级 | grep+Read | 文件 diff |
| VC-5 | ZCode 无 Stop hook 的事实落盘:plan-doctor 或 SKILL.md 注明"五守卫完成门 Tier1 硬阻断需 Stop 事件,ZCode 宿主不支持(仅 4 事件),gate-stop.sh 不移植" | grep + 本计划 findings 记录 | 文件 |
| VC-6 | 合并回 master + 2 部署位同步 diff IDENTICAL + smoke.sh 全绿 | git log+diff+smoke | 命令输出 |

**outcome: COMPLETE**（2026-09-05,merge 9b65e2e）——VC-1~VC-6 全部通过;移植复用为主（D4）,主进程直做已登记例外。

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 新脚本 | skills/task-planner/scripts/{ledger-append.sh, plan-doctor.sh} | 上游其他脚本(gate-stop/check-continue/inject-plan/resolve-plan-dir/set-active-plan 等本期不移植,理由落 findings) |
| 改脚本 | skills/task-planner/scripts/check-3file-gate.sh | 其他既有脚本 |
| 契约文本 | SKILL.md、references/critical-rules.md、CHANGELOG.md | 其他 references |
| 计划文档 | plans/task-pwf-reuse/** | 其他 plans/ 目录 |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 | 已确认 |
|------|------|------|------|--------|
| 上游源码 | ledger-append.sh 全文(300 行,tick/flock/UTF-8 trim/事件枚举) | github OthmanAdi/planning-with-files scripts/ledger-append.sh @master | 必读 | ✅ zread 全文已读 |
| 上游源码 | plan-doctor.sh 全文(六段自检) | 同上 scripts/plan-doctor.sh | 必读 | ✅ zread 全文已读 |
| 上游文档 | 完成门五守卫 G1-G5+停滞检测+宿主能力梯队 | zread.ai/OthmanAdi/planning-with-files/14-completion-gate | 必读 | ✅ WebFetch 提炼已读 |
| 上游文档 | gate-stop.sh(Stop 分发薄壳) | 同上 scripts/gate-stop.sh | 必读 | ✅ zread 全文已读 |
| 本仓现状 | check-3file-gate.sh(task-3file-enforce 自研版,mtime 信号) | skills/task-planner/scripts/check-3file-gate.sh @ab6fa0a | 必读 | ✅ 本会话自研 |
| 宿主能力 | ZCode hooks 事件面 | ~/.zcode/cli/config.json | 必读 | ✅ 仅 SessionStart/PreToolUse/PostToolUse/UserPromptSubmit |

## Current Phase
(全部 Phase complete,已交付)

## Next Step
Phase 1 完成（调研已在立项前做毕,findings 已回填）→ 直接进 Phase 2 worktree 创建

## Phases

### Phase 1: 上游调研与方案定稿
- [x] 抓取上游仓库结构(zread)+读 ledger-append/plan-doctor/gate-stop 全文+完成门提炼文档
- [x] 查证 ZCode hook 事件面(无 Stop→gate 不移植,落盘 VC-5)
- [x] 对比结论与可复用清单写入 findings.md
- **Status:** complete
- **Executor:** 主进程（例外理由:zread MCP 仅主进程可用,子代理无此工具）

### Phase 2: worktree 隔离区创建
- [x] `git worktree add .../task-planner-skill-worktrees/pwf-reuse -b wt/pwf-reuse master`
- [x] 验证 + 留痕 progress.md(簿记对账 2026-09-05 补记:工作已完成于 commit fa2b8ae,原会话中断未回填复选框)
- **Status:** complete
- **Executor:** 主进程（例外理由:git 簿记白名单）

### Phase 3: 实施（worktree 内）
- [x] 3a 移植 ledger-append.sh(显式传参 plan-dir 简化版,保留 tick/flock/UTF-8/事件枚举)
- [x] 3b check-3file-gate.sh 信号升级(ledger 行数主信号,mtime fallback)
- [x] 3c 移植适配 plan-doctor.sh(六段自检适配本仓 4 hook 位+2 部署位)
- [x] 3d SKILL.md/critical-rules.md 契约同步 + CHANGELOG
- **Status:** complete(对账:产物已在 master fa2b8ae/9b65e2e,plan-resume-v05 会话独立复核)
- **Executor:** 主进程（.sh 移植为上游已验证代码的适配裁剪,非新写业务逻辑——例外登记;若需大幅新写则派 code-assistant）

### Phase 4: 验证
- [x] ledger 三事件实跑+tick 递增+jq 逐行解析(VC-1)✓ 复测 tick=[1,2,3] 7 字段 JSON
- [x] gate 双信号用例(ledger 新增=0/无新增+新鲜 mtime=0/陈旧=1)(VC-2)✓ 原会话测试+续推会话独立复测
- [x] plan-doctor 本机全跑无 FAIL(VC-3)✓ 复测 7 PASS 0 FAIL
- [x] smoke.sh 全绿 + grep 契约一致(VC-4/5)✓ plan-resume smoke 39/39+bash -n×4;Stop 落盘 grep 命中
- **Status:** complete(对账:VC-1~VC-5 已由续推会话逐条独立复验)
- **Executor:** 主进程（一次性验证命令）

### Phase 5: 终验 + 合并回 + 部署同步
- [x] VC 逐条复验:VC-1 ledger tick/事件/jq✓ VC-2 gate 双信号三用例✓ VC-3 doctor 本机无 FAIL✓ VC-4 grep 契约✓ VC-5 ZCode 无 Stop 落盘(CHANGELOG+doctor 第 6 段+findings)✓
- [x] commit fa2b8ae(6 文件 301+)→ merge --no-ff → 9b65e2e → worktree remove + branch -d
- [x] 部署 2 位 rsync → diff -rq 双位 IDENTICAL → 部署位 doctor 9 PASS + ledger 冒烟 tick 1
- [x] 记忆更新(three-file-compass 补 ledger 段)+attest 更新
- **Status:** complete
- **Executor:** 主进程（主仓操作白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`(SessionStart 仅 ?? .zcode/ ?? plans/ 会话级;wt/plan-resume-v05 暂停方不重叠) |
| `isolation` | `worktree`(§11.1.4 scripts 命中) |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/pwf-reuse` |
| `branch` | `wt/pwf-reuse` |
| `merge_back` | `merged(9b65e2e)` |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 备注 |
|-------|-----------|------|
| Phase 1-5 | ✅ S1 已建 | 见 TodoWrite |

## Key Questions

1. 为什么不整体替换为上游 v3?→ 本仓已深度本土化(Rule 1-26 体系/worktree 隔离/委派门控/模板库/plan-resume 生态/五文件制);上游 .planning 目录布局/多语言/插件路由与本仓拓扑冲突;复用=取长补短非推倒重来
2. 为什么 gate-stop.sh 不移植?→ ZCode 无 Stop hook 事件(config.json 仅 4 事件),Tier1 硬阻断无宿主载体;现有 posttooluse 提醒链+模型自律调 gate 是当前宿主下的最大强制力
3. 为什么 ledger 优于 mtime?→ 上游 G5 明确批评 mtime "moves on any file touch,unreliable"(task-3file-enforce 自测中 touch 即可骗过门控);ledger 行数=语义化真实工作记录(tick 单调,事件枚举,不可通过 touch 伪造)

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 复用范围=ledger-append+plan-doctor+gate 信号升级三项;gate-stop/inject-plan/resolve-plan-dir/set-active-plan/check-continue 不移植 | 前者直接补齐自研弱信号;后者的宿主前提(ZCode 无 Stop)或结构前提(.planning 布局)不成立;check-continue 与 session-catchup 功能重叠 |
| D2 ledger 的 plan-dir 解析简化为显式传参 | 本仓脚本惯例全部显式传参(无 .active_plan 指针);多计划指针问题列为后续可选任务 |
| D3 gate 判定优先级:ledger 行数 > mtime fallback | 上游 G5 语义信号原理;向后兼容无 ledger 的存量计划 |
| D4 移植方式=适配裁剪非重写(保留上游已验证的 tick/flock/UTF-8 逻辑,改路径解析与输出文案) | 复用已有实现正是用户指令;重写=重新引入 bug 面 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 本计划自身执行按 task-3file-enforce 落地的新机制走:Phase 翻转前跑 check-3file-gate.sh(Phase 3 完成后 ledger 落地,此前用 mtime fallback)
- 计划文档留主仓,实现在 worktree
