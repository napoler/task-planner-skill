---
task_id: task-v078-guard-fp-fixes
template_type: rule-enhancement
interaction_mode: silent
chain_mode: single
created: 2026-09-17
---

# Task Plan: 修复两类守卫误报（提醒链已交付计划误报 + check-dispatch 打包检测误计示例 ID）

## Goal
修复两类守卫误报：提醒链 zcode-posttooluse.sh 对已交付计划误报（补 verification.md 兜底检查）与 check-dispatch.sh 打包检测误计契约条文示例 ID（新增「任务书」+subagent-state/ 双条件豁免出 SKIPPED 提示），各自 selftest 守护，全量 20 脚本 selftest 0 FAIL 后合并 master、从主仓副本执行部署 3 位并 push。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | 不声明（任务书照填：本任务不改 SKILL.md 条款，改动 4 个 .sh + CHANGELOG，行为级 selftest 验证） |
| `interaction_mode` | `silent`（登记依据：自治会话 + v074-v077 四轮先例） |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | zcode-posttooluse.sh 在 L100 既有 outcome 检查后新增 verification.md 兜底分支（同目录 verification.md，同 `outcome:` 正则 grep -qi，容前导空格） | `grep -n 'verification.md' skills/task-planner/scripts/zcode-posttooluse.sh` 命中 ≥1 + Read 复核；行为=有 verification.md 且 outcome COMPLETE 的计划不再触发 compass/sync 陈旧提醒 | scripts/zcode-posttooluse.sh |
| VC-2 | check-dispatch.sh 打包检测（L264 计数前）新增双条件豁免：prompt 同时含「任务书」与 `subagent-state/` → 输出 `[dispatch-guard] SKIPPED 打包检测: prompt 引用落盘任务书(Rule 35.3 范式), 打包判定以任务书内容为准` 且不计 hits（warn/enforce 两档行为一致=不阻断）；非豁免 prompt 行为不变 | 构造双条件 prompt 实跑 check-dispatch.sh（warn/enforce 两档）看 SKIPPED 文案且 exit≠2；构造无豁免词 prompt 对照行为不变 | scripts/check-dispatch.sh L264 前后 |
| VC-3 | selftest-dispatch.sh 新增 FG-05（prompt 含「任务书」+subagent-state/ 路径+多个示例 ID → 输出含 SKIPPED 打包提示且不含「S-unit ID」阻断文案）；FG-03（无豁免词多 S-unit prompt）仍被检测（回归保护）；selftest-dispatch 全量 0 FAIL | 实跑 selftest-dispatch.sh 看 FG-03/FG-05 PASS + Total 行 0 FAIL | scripts/selftest-dispatch.sh |
| VC-4 | selftest-execution-stability.sh 新增行为用例（fixture：plan 含 verification.md 且 outcome: COMPLETE → POSTTOOL 执行后无 findings/progress 陈旧提醒输出；对照=无 verification.md 的既有 T11a/b 行为不变）；该脚本全量 0 FAIL | 实跑 selftest-execution-stability.sh 看新用例与 T11a/b 全 PASS + Total 行 0 FAIL | scripts/selftest-execution-stability.sh |
| VC-5 | 全量 20 脚本逐 Total awk 求和 0 FAIL（主进程机械求和，禁采信子代理自报）+ merge master + 3 部署位 diff=0（主仓副本执行 smart-merge-back --deploy）+ 主进程 diff -r 亲验 + push origin | 主进程 `for f in selftest-*.sh` 逐 Total 行求和 + `diff -r` 3 部署位 + `git log` 看 merge commit + `git push` 输出 | progress.md Selftest Log + 部署 diff 输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | `skills/task-planner/scripts/zcode-posttooluse.sh`（L100 一带新增兜底分支 ≤4 行，:97 24h 静默与 :106-119 配置读取逻辑不动） | 其他逻辑改动 |
| 脚本 | `skills/task-planner/scripts/check-dispatch.sh`（L264 计数前新增双条件豁免） | 改 L45-47 注释口径、get_mode 逻辑 |
| 脚本 | `skills/task-planner/scripts/selftest-dispatch.sh`（新增 FG-05，FG-03 保持） | 删改既有用例（selftest 只增不减） |
| 脚本 | `skills/task-planner/scripts/selftest-execution-stability.sh`（新增行为用例） | 删改既有用例 |
| 文档 | `CHANGELOG.md`（仓根，[Unreleased] 新增一条；v077 实证该文件在仓根非技能目录） | 其他文档 |
| 簿记 | 主仓 `.gitignore`（随簿记提交） | 主仓其他文件 |
| 禁碰 | `SKILL.md` / `config.json`（零新键）/ `references/**` / `templates/**` / `critical-rules.md` | 全部禁改 |

**强制约束**:
- 两脚本均为运行中基础设施（部署位实时加载）——改动须最小化且行为级验证（T11a/b 回归 + 新用例双向）
- config 零新键：豁免逻辑内置于脚本，不加开关键
- 豁免锚=双条件（「任务书」+ `subagent-state/`）；单条件 subagent-state 豁免为被否决方案（考古 ①L68/290/300 证实会废掉打包门），禁用
- 锚点引用一律以 01-explore.md 实核值为准，禁凭记忆改写

## Phases

### Phase 1: 隔离与基线
- [x] S1 建 worktree（187194b=当前 master HEAD）
- [x] S2 跑 20 脚本全量基线（主进程 awk=337 PASS/0 FAIL，证据 p1-baseline.md）
- **Status:** complete
- **Executor:** 主进程（白名单① git 编排）+ code-runner-agent（S2 selftest 派发）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S1 | 建 worktree 并确认基线 commit | 主进程（白名单①） | 01-explore.md §③（并行信号 plans/task-v079-skill-modify-conservatism/ 不碰不提交） | `git worktree list` 见新 worktree + 基线 commit=187194b | 10min | done |
| S2 | 跑 20 脚本全量基线 | code-runner-agent | 材料包=01-explore.md §①（compass/stale selftest 零覆盖；T11a/b fixture 无 outcome/verification.md——基线为回归保护前提） | 逐 Total 行落盘 subagent-state 检查点（主进程 awk=337 PASS/0 FAIL） | 15min | done |

### Phase 2: 修复实现
- [x] S3 zcode-posttooluse.sh verification.md 兜底（VC-1；L103-105，三重因果对照，主进程复核）
- [x] S4 check-dispatch.sh 双条件豁免 + selftest-dispatch.sh FG-05/FG-03（VC-2/VC-3；23/23，enforce 双向实测）
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S3 | zcode-posttooluse.sh L100 后新增 verification.md 兜底分支 | 继承 | 01-explore.md §①（L100 既有 `grep -qiE 'outcome: *(COMPLETE\|BLOCKED)'` 豁免；本仓约定 outcome 写 verification.md） | VC-1 逐条 PASS（grep ≥1 命中 + 行为验证：COMPLETE 计划不再触发 compass/sync） | 10min | pending |
| S4 | check-dispatch.sh L264 计数前新增双条件豁免（SKIPPED 文案照 VC-2 原文，warn/enforce 两档均走豁免不累计 hits）；selftest-dispatch.sh 新增 FG-05 并保持 FG-03 | 继承 | 01-explore.md §②（L264 `grep -oE 'S[0-9]+'` 全位置计数；FG-03 L254-264 唯一多 S-unit 用例；L68/290/300 单条件陷阱） | VC-2+VC-3 逐条 PASS（双条件 prompt 两档均 SKIPPED 不阻断；FG-03/FG-05 均 PASS） | 15min | pending |

### Phase 3: 守护扩展
- [x] S5 selftest-execution-stability.sh 新增 T13a/T13b 行为用例（VC-4；含 T13 非密闭修正，主进程连续两遍 19/0 密闭验证）
- **Status:** complete
- **Executor:** executor（sonnet-1）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S5 | 新增 verification.md 兜底行为用例（含 T11a/b 回归保护） | 继承 |01-explore.md §①（selftest-execution-stability.sh :16 POSTTOOL 定义、:106-107/:133-135 T11a/b；fixture 无 outcome/verification.md） | VC-4 逐条 PASS：新用例 PASS + T11a/b 行为不变 + 脚本全量 0 FAIL；前置先跑 T11a/b 基线 | 12min | done |

### Phase 4: 全量回归+文档同步
- [x] S6 全量 20 脚本回归逐 Total 求和（主进程 awk=340 PASS/0 FAIL，证据 p4-regression.md）
- [x] S7 CHANGELOG.md（仓根）[Unreleased] 新增一条（code-assistant 落位——委派守卫 enforce 化，Executor 偏差登记 Handoff）
- **Status:** complete
- **Executor:** code-runner-agent（S6）+ 主进程（白名单②③ S7）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S6 | 全量 20 脚本回归逐 Total 求和 | code-runner-agent | 材料包=task_plan.md VC-5（主进程机械求和定数，禁采信子代理自报总数；新增 FG-05+新行为用例计数以实跑为准） | 逐 Total 行求和 0 FAIL 落检查点 | 15min | pending |
| S7 | CHANGELOG [Unreleased] 新增一条 | 主进程（白名单②③） | 材料包=task_plan.md Decisions Made（免重复：本轮两条修复结论） | `grep -c` [Unreleased] 下新条目 =1 + 样式与既有条目一致 | 5min | pending |

### Phase 5: 合并回+部署+簿记
- [x] S8 主仓副本执行 smart-merge-back --deploy → merge commit af49bf9；三位 IDENTICAL sm-rc=0（基准=主仓文案即 v077 修复生效）；主进程 diff -r 亲验三位=0
- [x] worktree 清理（v078 自有；v079 并行会话 worktree 不碰）+ push origin（187194b..af49bf9）
- [x] 簿记：verification.md 终验 + INDEX/ledger + 旧哨兵 038d staged 删除 + .gitignore 提交（本批）
- **Status:** complete
- **Executor:** 主进程（白名单①③）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|------------------------|-------------|---------|------|
| S8 | 合并回+部署 3 位+簿记+push | 主进程（白名单①③） | 01-explore.md §③（.gitignore 已补 .session-owner 生效；旧哨兵 038d...plan_required staged 待随簿记提交；并行存根不碰不提交） | VC-5 逐条 PASS：merge master + 3 部署位 diff=0（diff -r 亲验）+ push origin + worktree/分支清理 + merge_back=merged(<commit>) | 15min | pending |

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（主仓仅 plans/ 簿记与 .gitignore 改动=v078 会话自身簿记；并行存根目录 plans/task-v079-skill-modify-conservatism/ 非本会话所建，不碰不提交，登记于此） |
| `isolation` | `worktree` |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v078-guard-fp-fixes |
| `branch` | wt/task-v078-guard-fp-fixes（自 master 新建） |
| `merge_back` | merged(af49bf9) 2026-09-17 |

## 🔁 原生 Todo 同步
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  |  |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☑ | 2026-09-17 | P5 complete 同步 |

## Key Questions
1. 全量基线 337/0 中新增断言数（FG-05 + 新行为用例）实跑后最终总数为何值？（S6 以实跑为准，P1 基线先行锚定）
2. `outcome:` 正则对 verification.md 中非终态词（如 IN PROGRESS）是否天然不命中？——兜底分支仅应认 COMPLETE\|BLOCKED 终态词（S3 行为级验证覆盖）。

## Decisions Made
| # | Decision | Rationale |
|---|----------|-----------|
| D1 | interaction_mode=silent | 自治会话 + v074-v077 四轮先例 |
| D2 | config 零新键 | 豁免逻辑内置于脚本，不加开关键（避免配置面膨胀） |
| D3 | 豁免锚=「任务书」+subagent-state/ 双条件 | 单条件 subagent-state 豁免被否决：考古 ①L68/290/300 证实所有合规派发的检查点路径都在 subagent-state/ 下，单条件=废掉打包门；双条件对应 Rule 35.3 落盘任务书范式，打包判定以任务书内容为准（对齐 P11「复杂度由模型判断」） |
| D4 | Rule 23 并行信号处置 | plans/task-v079-skill-modify-conservatism/ 不碰不提交（非本会话所建裸模板存根，登记隔离决策表） |
| D5 | 共享追踪不适用 | Rule 30：本任务单链 chain_mode=single，无跨任务共享追踪需求 |
| D6 | C20 veto 检查 PASS | 本轮改动不涉及任何已否决项 |

## FMEA（预演）
| 风险 | 缓解 |
|------|------|
| 豁免过松削弱打包门 | 双条件 + SKIPPED 显式提示 + FG-05/FG-03 双向用例守护（正向豁免 + 反向回归） |
| verification.md 兜底误伤未交付计划 | 正则只认 COMPLETE\|BLOCKED 终态词；execution-stability 新用例双向验证（有/无 verification.md） |
| T11a/b fixture 回归破坏 | 既有用例无 verification.md → 行为路径不变；S5 前置先跑 T11a/b 基线 |

## 📚 必要知识储备
| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 提醒链锚点与豁免现状 | plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md §① | ☑ |
| 项目内部 | 打包检测口径与设计陷阱 | plans/task-v078-guard-fp-fixes/subagent-state/01-explore.md §② | ☑ |
| 项目内部 | selftest 写法范式（T11a/b + mk_fixture） | scripts/selftest-execution-stability.sh :106-135 | ☑ |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（P2 executor、P3 executor；P1/P4 混排按主白名单动作计主进程、P5 主进程）；子代理派发共 8 次（Explore 1/plan-writer 1/code-runner 2/executor 4/code-assistant 1），严格串行 |
| 主进程直做 Phase 清单 | P1（白名单① git 编排+③ 基线求和）、P4-S10/求和（白名单②③）、P5（白名单①③）——stats verdict=ok |
| 委派率 | 0.400（delegation_rate_floor 0.7，全直做理由命中 Rule 25.3 白名单 → WHITELIST-EXEMPT 放行；JSON 证据=verification.md） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|----------------|-----------------|---------------|----------------|------------------------|-------------|-------------|
| 1 | 05:4x | explore | 锚点考古（提醒链+打包检测） | done | 两误报根因+设计陷阱（单条件豁免会废打包门）全落盘 | subagent-state/01-explore.md | findings.md Research Findings | subagent-state/01-explore.md | 派发被旧守卫拦截一次→任务书落盘 | 0 | ☑ |
| 2 | 05:4x | plan-writer | 计划+knowledge-brief 撰写 | done | 返回消息退化为句点但产出完整（主进程 Read 复核通过） | task_plan.md 全文 | findings.md | subagent-state/02-plan-writer.md | 22.8 落盘核查，无需重派 | 0 | ☑ |
| 3 | 05:5x | code-runner-agent | P1 S2 全量基线 | done | 全 rc=0；主进程 awk=337/0 | subagent-state/p1-baseline.md | progress.md P1 段 | subagent-state/p1-baseline.md | - | 0 | ☑ |
| 4 | 06:0x | executor | P2 S3 提醒链 verification 兜底 | done | L103-105 三重因果对照验证 | zcode-posttooluse.sh:103-105 | findings.md P2 条 | subagent-state/p2-s3.md | - | 0 | ☑ |
| 5 | 06:1x | executor | P2 S4 打包双条件豁免+FG-05 | done | 23/23；enforce 双向实测 RC0/RC2 | check-dispatch.sh:264-277 | findings.md P2 条 | subagent-state/p2-s4.md | 任务书落盘 | 0 | ☑ |
| 6 | 06:3x | executor | P3 S5 T13 行为用例 | done | 首版非密闭（固定 sid）→ 主进程确诊后修正+密闭验证 19/0×2 | selftest-execution-stability.sh:145-205 | findings.md P3 条 | subagent-state/p3-s5.md+ p3-s5b.md | ⑤接管诊断+派发修正 | 1 | ☑ |
| 7 | 07:0x | code-runner-agent | P4 S6 全量回归 | done | 全 rc=0；主进程 awk=340/0 | subagent-state/p4-regression.md | progress.md P4 段 | subagent-state/p4-regression.md | - | 0 | ☑ |
| 8 | 07:1x | code-assistant | P4 S7 CHANGELOG 条目 | done | 仓根 L12 落位（委派守卫 enforce 化，S7 主进程直做改派） | CHANGELOG.md:12 | progress.md P4 段 | subagent-state/p4-s7.md | 主进程直做被守卫拦截→改派 | 0 | ☑ |
