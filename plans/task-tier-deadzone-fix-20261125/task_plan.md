<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-tier-deadzone-fix-20261125

- task_id: `task-tier-deadzone-fix-20261125`
- 时间: created_at=2026-11-24T17:23:24Z / updated_at=2026-11-24T19:10:27Z
plan_tier: standard
execution_lane: L1
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（手段）** 用户 2026-11-25 批注（对审计报告三死角原文）：「这是严重的问题」→ 修复 #1 跨工具零升级通道 / #2 幂等粒度会话级 / #3 半升级静默，含依赖 #5 outcome 对象守卫完结判定
- **R2（手段）** 范围外（本轮不动待批）：#4 计时 fail-open 告警 / #6 stub 通道 attest fail-closed / #7-#15 其余提案；不改 git 安全主门行为；不碰 ~/.claude/settings.json 等个人配置

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 手段 | 用户 2026-11-25 批注（对审计报告三死角原文）：「这是严重的问题」→ 修复 #1 跨工具零升级通道 / #2 幂等粒度会话级 / #3 半升级静默，含依赖 #5 outcome 对象守卫完结判定 | VC-1, VC-2, VC-3, VC-4, VC-5 |  |
| R2 | 手段 | 范围外（本轮不动待批）：#4 计时 fail-open 告警 / #6 stub 通道 attest fail-closed / #7-#15 其余提案；不改 git 安全主门行为；不碰 ~/.claude/settings.json 等个人配置 | VC-5 |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|
| G1 | #1/#2/#3+#5 依赖修复经夹具实跑验证 |  |  |
| G2 | merge+四位部署+verify 对账+归档 |  |  |

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|
| G1 | 修复三死角+依赖守卫 | #1/#2/#3+#5 依赖修复经夹具实跑验证 | T1-T5 全 PASS+selftest 零增量 | S2.1, S2.2, S2.3, S2.4, S2.5, S2.6, S3.1, S3.2 | pending |
| G2 | 合并部署收尾 | merge+四位部署+verify 对账+归档 | 四点 diff=0+verify 汇总+outcome COMPLETE | S4.1, S4.2, S4.3 | pending |

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | complete |  |  | 勘察与夹具基线 | 2026-11-25T01:20:00Z |  |
| P2 | complete |  |  | worktree 内实施（lib 抽取+三死角修复+三位接线+SKILL条款） | 2026-11-25T01:22:00Z |  |
| P3 | complete |  |  | 夹具验证+全量 selftest 回归+verify | 2026-11-24T18:04:39Z |  |
| P4 | complete |  |  | 合并回 master+四位部署+verify 对账+收尾 | 2026-11-24T18:24:55Z |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 | VC-1, VC-2, VC-3, VC-4, VC-5 |
| R2 | VC-5 |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC-1 | 死角#2：同 sid 第二个 mini 计划可升级——夹具先升 A 计划再对 B 计划（同 sid）触发，.tier_state 出现两个 per-plan state 且 B 面获 TU-1 | bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh T1 |  |
| VC-2 | 死角#3：半升级态自愈——plan_tier 已 standard 且无 state 无 TU-1 的未完结计划被补全链（TU-1+state+旧锁清理） | bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh T2 |  |
| VC-3 | 死角#3：升级链步骤失败显性曝光——render 故障时输出 [tier-upgrade] FAIL 行而非静默 | bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh T3 |  |
| VC-5 | 完结守卫双形态兼容（对象 outcome 不再误升档）+ 回归零增量（selftest 全量 FAIL 集与 master 基线一致 + verify ≥27 pass/4 已知 fail） | bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh T5 && bash skills/task-planner/scripts/run-selftests.sh |  |
| VC-4 | 死角#1：三位 hook 注册面含 tier 检查+单一事实源（tier_upgrade_check 定义仅 lib 一份） | bash plans/task-tier-deadzone-fix-20261125/fixtures-tier.sh T4 |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 勘察与夹具基线
- **Status:** complete
- **Started:** 2026-11-25T01:20:00Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S1.1 | [P1] 勘察与基线（install-stub/schema/hook 函数上下文全读+master selftest 基线） | 主进程 | 3 | install-stub 三工具 hook 契约清单落盘 | 10min | ≤100l | 无 | - [parallel-group:否] | pending |

### Phase 2: worktree 内实施（lib 抽取+三死角修复+三位接线+SKILL条款）
- **Status:** complete
- **Started:** 2026-11-25T01:22:00Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S2.1 | [P2] 抽共享库（新建 scripts/lib/tier-upgrade-lib.sh：tier_upgrade_check 全函数（emit 由宿主注入 tier_emit）+ 幂等键改 sid_task + 半升级自愈分支 + 步骤失败显性 FAIL emit + 完结守卫对象兼容） | 主进程 | 1 | bash -n lib + 函数单一事实源 grep | 30min | ≤100l | 无 | - [parallel-group:否] | pending |
| S2.3 | [P2] tier-upgrade-check.sh 新建（stdin 解析(sid/cwd)+定义 plain-text tier_emit+source lib+调用） | 主进程 | 1 | bash -n + T4 夹具 | 20min | ≤60l | 无 | - [parallel-group:否] | pending |
| S2.5 | [P2] SKILL.md 兜底条款（:51 与 :173 mini 常置口径块加「无 tier hook 工具位主进程自查升档」文本条款（触发时机=Phase 翻转/每10次工具调用/收尾回读）） | 主进程 | 1 | grep 新条款在位 | 15min | ≤20l | 无 | - [parallel-group:否] | pending |
| S2.6 | [P2] 语法冒烟（bash -n 全部改动文件+渲染冒烟） | 主进程 | 0 | rc=0 | 5min | ≤20l | 无 | - [parallel-group:否] | pending |
| S2.2 | [P2] zcode-posttooluse 改造（sourcing lib+删内联函数+主流程完结守卫对象兼容） | 主进程 | 1 | bash -n+trace 复演 | 20min | ≤100l | 无 | - [parallel-group:否] | pending |
| S2.4 | [P2] install-stub 三位注册（claude 数组追加/opencode·cursor frontmatter 加项/:208 示例链式更新） | 主进程 | 1 | T4 grep 三处模板 | 20min | ≤40l | 无 | - [parallel-group:否] | pending |

### Phase 3: 夹具验证+全量 selftest 回归+verify
- **Status:** complete
- **Started:** 2026-11-24T18:04:39Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S3.2 | [P3] 回归（run-selftests.sh 全量 vs master 基线 + verify.sh） | 主进程 | 0 | FAIL 集零增量+verify ≥27 pass | 20min | 0 | 无 | - [parallel-group:否] | pending |

### Phase 4: 合并回 master+四位部署+verify 对账+收尾
- **Status:** complete
- **Started:** 2026-11-24T18:24:55Z
- **Executor:** 主进程
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|---|---|---|---|---|---|---|---|---|---|
| S4.1 | [P4] 合并（worktree 干净后 merge --no-ff 回 master+Read 复验） | 主进程 | 0 | git log 复验 | 10min | 0 | 无 | - [parallel-group:否] | pending |
| S4.3 | [P4] 收尾（VC 证据回填+progress 回填+归档+记忆+交付报告） | 主进程 | 0 | outcome COMPLETE+报告发出 | 10min | 0 | 无 | - [parallel-group:否] | pending |
| S4.2 | [P4] 部署对账（install.sh 四位部署+关键文件 diff+verify 对账） | 主进程 | 0 | 四点 diff=0+verify 汇总行 | 15min | 0 | 无 | - [parallel-group:否] | pending |

## Next Step
P2 实施：worktree 内抽 lib/tier-upgrade-lib.sh（emit 注入式）→ zcode-posttooluse.sh 换源+完结守卫对象兼容 → 新建 scripts/tier-upgrade-check.sh → install-stub.sh 三位注册 → SKILL.md 兜底条款 → bash -n + 夹具

## Decisions Made
| Decision | Rationale |
|---|---|
| [intent-switch] 自 task-mini-tier-audit-20261125（挖掘 COMPLETE）切至本修复任务；范围=三死角(#1跨工具/#2幂等粒度/#3半升级静默)+依赖#5 outcome守卫，#4/#6-15 仍待批 | 用户 2026-11-25 原话批注：三个死角「这是严重的问题」；standard 档理由=多文件保护区手术复杂度已知 |
| [re-lock] 2026-11-25T01:33 attest 锁定后，02:04 执行期 planctl 正常写入(Phase 翻转/updated_at)+render 再生成四视图致哈希失配；补登记该轮合法写入并按 hook 分支①重锁 | 取证=task_plan.md 头部「planctl.py 从 plan-state.json 生成」标记+updated_at=2026-11-24T18:04:39Z+impl-report/fixtures 时间线；属流程自身产物，非外来篡改 |
| DEVIATION-1 接受：zcode 宿主 TIER_EMITTED=1 即 exit 0（含 FAIL 轮）——F9 平台严格 JSON 校验优先于提醒链顺延，tier 故障每轮重试不丢信息 | R1 实测 FAIL 轮不 exit=2 行 JSON 污染 hook 链；R2 critic 提案+主进程复核确认 |
