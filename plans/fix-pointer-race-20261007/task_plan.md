# Task Plan: active-plan 指针抢占事故修复（双命名空间分裂 + 哨兵抢用）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我发现严重的bug 执行状态文件会被抢占覆盖 以下是示例:  两个问题：...② 会话指针被并行会话覆盖到了 task-videop1-blender-mcmodels-001（命中 memory 既有判例：指针竞争用 set --sid 恢复）。...」
- **R2**: 「我需要的只是修复当前技能，不是设计其他具体任务」

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1~VC-5 | 指针链写入方/读取方口径统一 + 哨兵抢用根治，行为级 selftest 断言全过 |
| R2 | VC-6 | 修复范围仅限本技能指针链 6 文件，部署位 IDENTICAL，不开其他任务 |

## 🧮 根源覆盖表（Rule 53.1）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 指针读取（resolve-plan-dir.sh） | 只读剥前缀形态，历史 sess* 指针失明 → mtime 兜底被劫持 | 双命名空间兼容读 | VC-1 |
| 指针写入（init-session.sh / userpromptsubmit.sh） | SIDKEY/认领文件名不剥 sess 前缀 | 写入方 canon 统一剥前缀 | VC-2/VC-4 |
| 会话身份映射（task-plan-init.cjs） | env sid 与 hook sid 两套 uuid 无映射 → init 抢最新哨兵=抢他会话命名空间 | SessionStart 写 .sidmap 映射，消费方优先查映射 | VC-3 |
| 哨兵抢用兜底（init-session.sh / plan-created.cjs） | "最新 mtime 哨兵=本会话"假设在多会话并发下失效 | 兜底加 ≤120s 新鲜度窗，超窗拒抢+警告 | VC-2/VC-3 |
| 资源回收（set-active-plan.sh gc） | sidmap 新文件型无清扫 | gc 同语义清扫 *.sidmap | VC-5 |
| 回归防护（selftest-active-plan.sh） | T12a 固化了抢用行为（含 sess 前缀文件名） | 更新预期+新增双读/映射/拒抢断言 | VC-5 |

## Goal

修复 task-planner 技能 active-plan 指针链的并行会话抢占缺陷：读取方双命名空间兼容、写入方剥 sess 前缀、SessionStart 落 sidmap 确定性映射、哨兵抢用加新鲜度窗，selftest 全过并同步部署位。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `fe4545507d38455d8f342d1d50f89910` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race` |
| `scope_files` | `skills/task-planner/scripts/resolve-plan-dir.sh, skills/task-planner/scripts/init-session.sh, skills/task-planner/scripts/zcode-userpromptsubmit.sh, skills/task-planner/scripts/task-plan-init.cjs, skills/task-planner/scripts/plan-created.cjs, skills/task-planner/scripts/set-active-plan.sh, skills/task-planner/scripts/selftest-active-plan.sh` |
| `interaction_mode` | `silent` |
| `new_rule` |  |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | resolve-plan-dir.sh 对 sess 前缀 side 指针可解析（双命名空间读） | selftest 行为断言（写 sess<sid>.active_plan → 剥前缀 sid 解析命中） | `bash skills/task-planner/scripts/selftest-active-plan.sh` |
| VC-2 | init-session.sh env sid 剥 sess 前缀 + sidmap 优先 + 哨兵兜底 ≤120s 新鲜窗（超窗拒抢） | selftest 行为断言（T12 系更新+新增） | 同上 |
| VC-3 | task-plan-init.cjs SessionStart 写 <env_sidkey>.sidmap；resume 判定双命名空间读 | grep 断言 + selftest | 同上 + `grep -c sidmap skills/task-planner/scripts/task-plan-init.cjs` |
| VC-4 | zcode-userpromptsubmit.sh 认领 side 指针文件名剥 sess 前缀（.session-owner 协议不变） | grep 断言 + selftest | 同上 |
| VC-5 | selftest-active-plan.sh 全 PASS；set-active-plan.sh gc 清扫 *.sidmap | `bash selftest-active-plan.sh` exit 0 | 同上 |
| VC-6 | 全量 selftest 无回归 + 部署位与仓内 IDENTICAL | 全量 selftest FAIL=0；`diff` 仓内 vs `~/.zcode/skills/task-planner/scripts/` 6 文件全等 | 全量 selftest + diff 输出 |
| VC-7 | code review 通过 + 合并回 master + worktree/分支清理（§11.3 全条） | `git log master` 含 merge commit；`git worktree list` 无 fix-pointer-race | git 命令输出 |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | worktree 内 `skills/task-planner/scripts/{resolve-plan-dir,init-session,zcode-userpromptsubmit,set-active-plan}.sh` | 其他 .sh |
| 脚本 | worktree 内 `skills/task-planner/scripts/{task-plan-init,plan-created}.cjs` | 其他 .cjs/.ts |
| 测试 | worktree 内 `skills/task-planner/scripts/selftest-active-plan.sh` | 其他 selftest |
| 主仓 | 仅 `plans/fix-pointer-race-20261007/**`（簿记） | 主仓 skills/ 直改（一律走 worktree） |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|------|---------|--------|
| 项目内部文档 | 指针机制四处 canon 注释 | worktree `skills/task-planner/scripts/resolve-plan-dir.sh` 头注 | 必读 | ☑ |
| 项目内部文档 | check-scope.sh:140 双命名空间补丁先例 | worktree `skills/task-planner/scripts/check-scope.sh` | 参考 | ☑ |
| 项目内部文档 | selftest-active-plan.sh T12 系现有断言 | worktree `skills/task-planner/scripts/selftest-active-plan.sh` | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 指针链写入方与读取方 sid canon 分裂（sess 前缀）+ 哨兵"抢最新"兜底在多会话并发下把 A 会话指针写进 B 会话命名空间，导致执行状态被并行会话抢占覆盖。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？— 是，指针解析确定性恢复
- [x] 核心问题不解决，其他工作都白费吗？— 是，并行会话互踩持续发生（本会话 init 已实时复现）
- [x] 核心问题的解决方法是清晰的、可执行的？— 是，六文件修改点已逐一锚定行号

## Current Phase

Phase 5

## Next Step

合并回 master + worktree 清理 + 交付总结

## 🧰 工具选择与编排

| Phase | 命中工具面 | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 code-assistant | 2 文件小改，≤3 文件限制内 |
| Phase 2 | Agent 子代理 code-assistant | 2 文件小改 |
| Phase 3 | Agent 子代理 code-assistant | 2 个 cjs 小改 |
| Phase 4 | Agent 子代理 code-assistant | selftest 单文件补断言+运行 |
| Phase 5 | 主进程（例外理由:① git 编排+② 簿记+③ 部署位同步——Rule 25.3 白名单） | CR/合并/部署/交付 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件。Phase 1/2/3 文件集互不重叠、无共享资源、输入独立、验收独立 → 独立性四问全否 → parallel_groups 声明：P1={Phase1-S1, Phase2-S1, Phase3-S1} 同消息并行派发；Phase 4 依赖 1-3 串行。
**/goal 对齐（Rule 40.3）**: 未使用 /goal；Goal+VC 即本任务锚。

## Phases

### Phase 1: 脚本组A修复（resolve-plan-dir.sh 双读 + set-active-plan.sh gc 扩展）
- [ ] resolve-plan-dir.sh side 查找剥前缀 miss 时回查 sess<sidkey> 形态
- [ ] set-active-plan.sh gc 增清扫 .plan_required_side/*.sidmap（mtime>24h）
- **V-N:** VC-1, VC-5
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | resolve 双读+gc 扫 sidmap | 继承 | worktree resolve-plan-dir.sh:58-70（side 查找块）+ set-active-plan.sh:125-144（gc 块）+ 派发 prompt 内嵌 diff 规格 | `bash -n` 两脚本过；grep 双读标记与 sidmap 清扫在位 | ≤15min | done |

### Phase 2: 脚本组B修复（init-session.sh canon+两级兜底 + userpromptsubmit.sh 认领文件名）
- [ ] init-session.sh SIDKEY 剥 sess 前缀；兜底改两级：.sidmap 映射优先 → 最新哨兵 ≤120s 新鲜窗（超窗拒抢+WARN）
- [ ] zcode-userpromptsubmit.sh 认领 side 指针文件名剥 sess 前缀（.session-owner 保持原口径）
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | init canon+兜底两级化+ups 剥前缀 | 继承 | worktree init-session.sh:613-650（SIDKEY+兜底块）+ zcode-userpromptsubmit.sh:165-185（认领块）+ 派发 prompt 内嵌 diff 规格 | `bash -n` 过；grep sess 剥离 case 与 120s 窗在位 | ≤15min | done |

### Phase 3: cjs 组修复（task-plan-init.cjs sidmap 落盘+resume 双读 + plan-created.cjs 映射优先）
- [ ] task-plan-init.cjs 哨兵写入后：env sid 与 hook sidkey 不同时原子写 <env_sidkey>.sidmap（内容=hook sidkey）；resume 判定 side 指针双命名空间读
- [ ] plan-created.cjs sentinelFallbackSidkey 前置 sidmap 查询；探测兜底加 ≤120s 新鲜窗
- **V-N:** VC-3
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 承接体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | cjs sidmap 写+读+窗 | 继承 | worktree task-plan-init.cjs:75-122 + plan-created.cjs:59-97 + 派发 prompt 内嵌规格 | `node --check` 两文件过；grep sidmap 写/读在位 | ≤15min | done |

### Phase 4: selftest 更新与全量回归
- [ ] selftest-active-plan.sh：T12a 预期改剥前缀文件名；新增双读/映射优先/超窗拒抢/env 带前缀直配/gc 扫 sidmap 断言
- [ ] 全量 selftest 跑通（基线 FAIL=0）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** code-assistant

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | selftest 补断言+跑通 | 继承 | worktree selftest-active-plan.sh 全文（220 行,T01-T12d 结构）+ Phase 1-3 改后脚本 | `bash selftest-active-plan.sh` exit 0 | ≤15min | done |
| S2 | CR 四项修复落地（P1 sidmap 权威化/P2 env-only 转译/P3 T12g 加固） | 继承 | CR 报告 5-code-assistant.md 规格 | selftest 29/29 + 定向回归双绿 | ≤15min | done |

### Phase 5: CR + 部署同步 + 合并回 + 交付
- [ ] code-reviewer/critic 审 diff → 修复意见闭环
- [ ] 6 文件同步 ~/.zcode/skills/task-planner/scripts/ + diff IDENTICAL
- [ ] 合并回 master（--no-ff）+ worktree/分支清理 + 交付总结
- **V-N:** VC-6, VC-7
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记+③ 部署位同步——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（改动面=指针链 6 脚本，主仓无重叠未提交变更；并行会话 v142 scope=critical-rules/SKILL/config 不相交） |
| `isolation` | `worktree`（§11.1 命中：技能文件+运行中基础设施） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/fix-pointer-race` |
| `branch` | `wt/fix-pointer-race`（自 master d806d05） |
| `merge_back` | `pending` |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 1-3 | 子代理改错行/漏改 | 6 | 3 | 2 | 36 | 主进程 Read 复核 diff，偏差回炉重派 |
| Phase 3 | cjs 语法错 | 7 | 2 | 1 | 14 | `node --check` 验收门拦截 |
| Phase 4 | 旧断言连锁 FAIL（T12a 预期变更） | 5 | 4 | 1 | 20 | 逐条 FAIL 对照规格修正断言 |
| Phase 5 | 部署位被并行会话同时改动 | 6 | 2 | 2 | 24 | cp 前 diff 基线，冲突即 STOP 报告 |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-07 | TodoWrite 已建 7 条 |
| Phase 2 | ☑ | 2026-10-07 | 同上 |
| Phase 3 | ☑ | 2026-10-07 | 同上 |
| Phase 4 | ☑ | 2026-10-07 | 同上 |
| Phase 5 | ☑ | 2026-10-07 | 同上 |

## Key Questions

1. sidmap 放哪个目录？— `plans/.plan_required_side/<env_sidkey>.sidmap`（与哨兵同目录，gc 同 TTL）
2. .session-owner 协议是否动？— 不动（posttooluse 比对口径自洽，动它扩大爆炸半径）
3. 哨兵兜底窗取值？— 120s（覆盖"会话刚启动即建计划"场景，与映射路径互补）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| sidmap 确定性映射为主，新鲜窗兜底为辅 | 抢最新哨兵在多会话并发=抢他会话命名空间（本会话 init 实时复现 4272173a 污染）；映射消除猜测 |
| 读取方双命名空间兼容 | 历史落盘的 sess* 指针文件仍需可解析（对齐 check-scope.sh:140 先例） |
| .session-owner 协议不动 | posttooluse:20 原始 SID 与 owner 文件同为裸前缀口径，自洽；改动扩大爆炸半径 |
| 用户否决 vNNN 任务编排，最小计划过闸 | R2 原话；守卫要求有效计划，最小化满足 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| 主进程 Edit 被 check-scope 哨兵拦 | 1 | init-session 建最小计划+plan-created 清哨兵 | 写业务代码前先确认会话哨兵状态 |
| 主进程 Edit 被 check-delegation 拦 | 1 | 改派 code-assistant 子代理 | 业务代码修改一律委派 |
| init-session 兜底实时抢用他会话哨兵(4272173a) 污染其指针 | 1 | 删除误写指针文件+本会话指针 canonical 归位 | 即本任务 RC-2 实锤，修复后由映射+新鲜窗根治 |

## Notes

- 事故实时复现证据：init-session 输出 `env sid(sessfe4545…) 无对应哨兵,fallback 最新哨兵 sid(4272173a…)`——RC-1+RC-2 同框实锤
- 本会话已自愈：指针 `fe4545….active_plan`→fix-pointer-race-20261007；`.session-owner` 已写；误写 4272173a 指针已删
- 陈旧全局 `plans/.active_plan`（指向 task-v098，9-30）属数据面，本次不动，仅交付说明登记

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-07 | 用户澄清"只修技能不开任务" | 全部 | 计划收缩为最小过闸形态，范围不变 |

## 📦 Batch Report

| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | worktree 分支 wt/fix-pointer-race（master d806d05） |

## 📊 委派统计

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5 |
| 主进程直做 Phase 清单 | Phase 5（例外理由:① git 编排+② 簿记+③ 部署位同步） |
| 委派率 | 0.8 |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | | code-assistant | Phase1-S1 resolve 双读+gc 扫 sidmap | done | 双读回查+gc sidmap 清扫落地；bash -n 过；grep 验收全过 | resolve-plan-dir.sh:65 / set-active-plan.sh:141-150 | findings.md 待回填 | plans/fix-pointer-race-20261007/subagent-state/1-code-assistant.md | - / 0 / ☑ |
| 2 | | code-assistant | Phase2-S1 init canon+兜底两级+ups 剥前缀 | done | SIDKEY/_sent_sid 剥前缀+sidmap 优先+120s 窗拒抢落地；验收全过 | init-session.sh:615-664 / zcode-userpromptsubmit.sh:180-190 | findings.md 待回填 | plans/fix-pointer-race-20261007/subagent-state/2-code-assistant.md | - / 0 / ☑ |
| 3 | | code-assistant | Phase3-S1 cjs sidmap 写读+窗 | done | sidmap 落盘+resume 双读+两级兜底+2 处自主双读补查（复核通过） | task-plan-init.cjs:102-135 / plan-created.cjs:73-125,146-152,250-260 | findings.md 待回填 | plans/fix-pointer-race-20261007/subagent-state/3-code-assistant.md | - / 0 / ☑ |
| 4 | | code-assistant | Phase4-S1 selftest 补断言+全量回归 | done | 26/26 过；全量 15 FAIL 均为 master 既有（零增量） | selftest-active-plan.sh:161-298 | findings.md 已回填 | plans/fix-pointer-race-20261007/subagent-state/4-code-assistant.md | - / 0 / ☑ |
| 5 | | Code Reviewer | CR 全量 diff 审查 | done | NEEDS_FIXES 4 项（P1 sidmap 残留抢占/P2 env-only 转译缺口/P3×2），变异测试验证断言判别力 | CR 报告（checkpoint 6） | findings.md 已回填 | plans/fix-pointer-race-20261007/subagent-state/6-code-reviewer.md | - / 0 / ☑ |
| 6 | | code-assistant | Phase4b CR 四项修复落地 | done | sidmap 权威化+env-only 转译+T12g 加固+T12j/k/l；29/29 过+定向回归双绿 | init-session.sh:629-652 / resolve-plan-dir.sh:58-80 / plan-created.cjs:77-125 | findings.md 已回填 | plans/fix-pointer-race-20261007/subagent-state/5-code-assistant.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 = 单点缺陷修复（bugfix），无新方法论/模板形态产出，不沉淀
