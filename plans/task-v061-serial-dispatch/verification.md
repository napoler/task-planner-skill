# Verification Contract & Phase Gates — task-v061-serial-dispatch

## Goal (1 sentence)

废除 task-planner skill 内 6 处并行派发条款，确立串行派发铁律（文本 + check-dispatch.sh 串行槽守卫机制 + selftest），合并回 master（af04679）并重部署 9+2 位对账，全程 worktree 隔离且全程串行执行。

---

## Verification Contract（终验逐条复验 — 2026-09-12）

- [x] VC-1: 条款净零 — `grep -rn "可并行\|并行派发\|同时派发\|并行消费\|互不阻塞\|同一消息并行"` 于 SKILL.md / references/critical-rules.md / references/completion-gate.md / CLAUDE.md → **exit=1（0 命中）**；无关语境（并行会话/Rule 23/Rule 27.2/worktree 并行开发）不在 4 文件中残留并行派发语义
  Evidence: 终验 grep 输出（exit=1）；合并探针 `grep -c "串行派发铁律"` → critical-rules=2、SKILL.md=1
- [x] VC-2: 串行铁律成文 — critical-rules.md:117 Rule 21.4 升格（至多 1 活跃子代理/后台占槽/Why=用户实证/唯一例外=用户显式授权/违规走 Rule 26 三要素齐备）；:127 22.4a、:168 25.2、SKILL.md 6 处（:84/:135/:240/:244/:250/:272）、completion-gate.md:19-28、CLAUDE.md:33 全部按 findings 设计表 A.1-A.9 就位
  Evidence: worktree 逐 Phase git diff 主进程 Read 复核（progress.md Phase 2-4 Test Results 全 PASS）
- [x] VC-3: 机制守卫生效 — check-dispatch.sh `serial_slot_check()`（:216-246）：主进程独立复测 fresh+enforce=rc2（stderr 含 Rule 21.4）/fresh+warn=rc0 告警/nolock=rc0 写锁/stale(200s)=rc0 刷新；posttooluse Agent 事件清锁端到端实测 LOCK_REMOVED、非 Agent 保留；selftest TS-01..06 全过
  Evidence: progress.md Phase 5 表（7 项 PASS）；selftest-dispatch 18/18（主进程独立复跑）
- [x] VC-4: 无回归 — 5 套 selftest 全量 **96 用例 fail=0**（dispatch 18 + active-plan 13 + delegation 38 + plan-dispatch 6 + fallback 21；基线 90 + 新增 6）；Code Review P1 修复后外层 `ENFORCE=off` 环境 18/18 实证
  Evidence: subagent-state/06b-code-runner.md + progress.md Phase 6 表 + 修复轮复验（4da4c0e）
- [x] VC-5: 合并回 + 重部署对账 — merge af04679（7 文件 +146/-20）；task-planner 3 位（zcode/claude/opencode）`rm+cp -rL` 重部署后 diff -rq 全 IDENTICAL + verify.sh **25 pass/0 fail ×3**（中性 CWD /tmp）；companion 6 位无新差异；plan-writer agent 2 位符合预期（claude 位仅 model 行）；主进程 3 项抽查一致
  Evidence: subagent-state/08-executor.md + 主仓合并探针（serial_slot_check=3、TS-0=21 处、串行同步协议=1）
- [x] VC-6: 全程隔离与簿记 — 全程串行派发（Handoff 表 11 行可证：一次仅一个活跃子代理，逐行 verify_done）；wt/task-v061-serial-dispatch 已 remove、分支已删（`git worktree list` 仅主仓）；Rule 27 逐 Phase 提交（c862215/8a84af8/2935327/ee078cd/ee15fc4/49898d6/4da4c0e，scope porcelain 逐次为空）；INDEX/attest/ledger（tick 1-9）齐备
  Evidence: git worktree list 输出 + git log --oneline + Handoff 表

---

## 委派统计复验（Rule 25.4 — 机器口径）

```json
{"phases_total":8,"phases_delegated":6,"main_direct_count":2,"delegation_rate":0.75,"verdict":"ok","violations":[]}
```

- [x] 主进程直做 Phase 均登记白名单例外理由：Phase 1（① git/worktree 编排 + ③ 机械验证）、Phase 8（② 计划系统文件维护）——Rule 25.3 六项白名单内
- [x] 委派率 0.75 ≥ delegation_rate_floor 0.7，verdict=ok，violations=0 → 不降级
- 簿记教训：Handoff 表 subagent_type 列须为**裸类型名**（`| executor |`），带 `(model)` 后缀会被 check-delegation.sh 判 unverified_delegation（本轮实测并已规整）

## 质量门控统计（Rule 26）

- [x] Q1-Q6 核查：未触发降质违规（无跳过验证/无伪造证据/无超范围）
- [x] 子代理契约违规 2 起如实登记（非降质项，属 22.4b 契约层）：#7 违反 8 字段返回格式 + checkpoint 缺失（产出经主进程直接复核采纳）；#8 虚报 findings_written（实际无写入，无损害）
- [x] Evidence 抽查 ≥3 条：VC-1 grep 可复现、VC-3 四场景可复现、VC-5 diff/verify 可复现（主进程均已第一手执行）
- [x] Code Review Gate：APPROVED（confidence HIGH，10 组定向实验）+ P1/P2 修复轮闭环（4da4c0e）

## 必要知识储备符合性核验

| 必读知识源 | 核验方式 | 结论 |
|-----------|---------|------|
| memory: task-planner-repo-deploy-flow.md | Phase 7 重部署 SOP（rm+cp -rL、diff -rq、verify 中性 CWD、9+2 位拓扑）完全按 memory 执行 | 符合 |
| memory: 小步快跑既有条款 | Rule 21.1b/22.3② 未动且被 21.4 新文引用；失败兜底链保持"拆细先于升档" | 符合 |
| findings.md 串行铁律设计表 | 9 处文本改动 + 守卫设计 + TS 用例逐条照表落地 | 符合 |

## Goal Gate 终验

```
## Goal Verification — 串行派发铁律落地（文本+机制+selftest+部署对账）
- [x] VC-1 条款净零（grep 0 命中） → PASS
- [x] VC-2 铁律成文（9 处就位） → PASS
- [x] VC-3 机制守卫（4+2 场景实测） → PASS
- [x] VC-4 无回归（96 用例 fail=0） → PASS
- [x] VC-5 合并+重部署对账（af04679, 25/0×3） → PASS
- [x] VC-6 隔离与簿记（全程串行可证） → PASS

 outcome: COMPLETE
```

**已知遗留（不阻塞，均登记）**：
1. hook 生效时序：check-dispatch.sh/zcode-posttooluse.sh 为部署位文件替换，按 v059 实证「hook 链路会话启动固化」，**新会话起**串行槽守卫才在生产 hook 链路生效（本会话内派发靠纪律自律，已做到）
2. `~/.zcode/AGENTS.md` §一 仍鼓励"互不依赖子任务同一消息并行派发"——用户级宪法不在本任务 scope，**仅建议**：用户如需全链路一致，可另行授权对齐（改为指向串行铁律）
3. inflight 锁无法覆盖 run_in_background 后台并发（PostToolUse 立即返回），由 21.4 文本条款"后台占槽"覆盖，脚本注释已如实标注
4. master 领先 origin 若干提交未 push（含本轮）——是否 push 由用户决定
