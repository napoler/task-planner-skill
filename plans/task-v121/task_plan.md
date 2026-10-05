# Task Plan: 三锚宽容化预扩 1-4[5-9]（task-v118 建议采纳）
<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard（scope 3 文件未达 mini ≤2 门槛；按 Rule 38.7 L0 精神压缩流程=2 Phase 2 S-unit） -->

## Goal
将 RT-08/PT-08/CD-12 三个版本锚的宽容口径从 1-4[56] 预扩至 1-4[5-9]，使后续 Rule 47-49 落地时 SKILL.md frontmatter 级联不再撞锚——纯 selftest 断言口径扩展（v117/v118 范式），条款与守卫零改动。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 selftest 断言正则扩宽，无业务逻辑；负向自检承担验证） |
| `session_id` | `sess_13ddd750-14f1-4a92-b7d4-143f8cef3532` |
| `scope_files` | `scripts/selftest-ask-default-timeout.sh, scripts/selftest-plan-tier.sh, scripts/selftest-conclusion-discipline.sh` |
| `interaction_mode` | `ask` |
| `对齐审查` | 豁免：纯断言正则扩宽无文档/文案更新，alignment 面由 VC-4 负向自检+全量回归承载 |
| `自动超时默认项` | 无 2+ 选项询问点（用户已显式选 3）；豁免登记 |
| `质量审查工具` | 负向自检（守卫牙齿验证）+ 全量回归，mini 级承载 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | RT-08 白名单口径 1-4[5-9]（a/b 两处 `grep -vE '^1-4[5-9]$'`） | grep 断言行 | selftest-ask-default-timeout.sh L66-68 |
| VC-2 | PT-08 字面锚宽容 1-4[5-9] | grep 断言行 | selftest-plan-tier.sh L77 |
| VC-3 | CD-12 n45 锚宽容 1-4[5-9]（≥3 门槛与 1-34 反回退不变） | grep 断言行 | selftest-conclusion-discipline.sh L68 |
| VC-4 | 三 selftest 单跑全 PASS + 全量回归 43 脚本 0 FAIL + 负向抽查有牙齿（**修正 2026-10-03 S1 后**：牙齿=1-40/1-44 计 1 仍拦；1-45..49 计 0 加白属预扩既定语义，原「1-47 计 1」为旧口径措辞已作废） | 负向 fixture + 全量求和 | progress.md Test Results |
| VC-5 | 合并 master + 三部署位 diff=0 + worktree/分支清理 | smart-merge-back --deploy + diff -rq | progress.md Phase 2 段 |

**终验规则**: 全部 VC 通过 → COMPLETE；任一失败 3 次 → BLOCKED

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| selftest | 上列 3 个文件（仅锚正则与注释） | 其他任何文件；条款/守卫/SKILL/config 零改动 |

**强制约束**: 注明修改原因+时间+原行为（Rule 45.4）；断言语义不反转（越界防护意图保留）；改动总量 ≤20 行（L0 线）。

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | Agent 子代理 executor + 机械守卫脚本 | 三文件正则编辑=判断型小改；负向自检 fixture 在子代理内闭环 |
| Phase 2 | 主进程（白名单①②） | git 编排+部署+簿记 |

**workflow 编排判定**: 未命中（单链 2 步）；**/goal 对齐**: 未用 /goal

## Phases

### Phase 1: 锚扩宽 + 验证
- [ ] S1 改三锚 1-4[56]→1-4[5-9]（RT-08 a/b 两处+PT-08 一处+CD-12 n45 一处+各注释同步）
- [ ] S2 全量回归 43 脚本（含负向抽查）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **证据**: commit（+10/-7）；三 selftest 全 PASS；43/43 回归 676/0；负向牙齿 1-40/44
- **Executor:** executor（S1）→ executor（S2）串行
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------------|-----------------------------|---------|------|------|
| S1 | 三锚宽容口径 1-4[56]→1-4[5-9]（4 处正则+注释同步，注明 task-v121 预扩） | executor | wt:selftest-ask-default-timeout.sh L60-68 + selftest-plan-tier.sh L75-77 + selftest-conclusion-discipline.sh L67-69 | 三 selftest 单跑全 PASS；负向：1-47 solo 计 1、同行 1-46 1-47 计 1、合法 1-46 计 0 | 10min | complete |
| S2 | 全量 selftest 回归 43 脚本求和 | executor | wt:scripts/selftest-*.sh | 43/43 rc=0 ΣFAIL=0（预期 ΣPASS=676） | 8min | complete |

### Phase 2: 合并回 + 部署 + 簿记
- [ ] smart-merge-back --deploy（含 ~/.zcode 运行位手动 rm+cp）+ worktree/分支清理 + 簿记
- **V-N:** VC-5, VC-4
- **Status:** complete
- **证据**: merge 53936ec；三位 diff=0；worktree/分支清零
- **Executor:** 主进程（例外理由: ① git 编排 ② 计划系统文件/簿记——Rule 25.3 白名单）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（主仓未提交变更仅 plans/ 计划文件，与 skills/ scope 无重叠） |
| `isolation` | `worktree`（§十一 11.1 条款 1：保护区技能文件） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v121` |
| `branch` | `wt/task-v121` |
| `merge_back` | `merged(53936ec)` |

## ⚠️ 核心问题定义
**核心问题**: Rule 47-49 落地时三锚将再次级联（每次改 SKILL.md frontmatter 全集必撞）——预扩一次消除三次未来级联成本。
**核心问题判断**: [x] 解决后 Rule 47 落地零锚改动 [x] 不解决则每轮重复 v117/v118 式级联 [x] 方法清晰（正则字符类扩一格）

## Current Phase
**COMPLETE（2026-10-03：5 VC 全过，43/43 selftest 676/0，三部署位 0 差异）**

## Next Step
无——已交付

## Key Questions
1. 预扩是否弱化当前防护？→ 是（已知权衡，用户选 3 时披露）：Rule 47 落地前 SKILL.md 出现 1-47/1-48/1-49 字面将过 RT-08——窗口期风险接受，Rule 47 落地后口径即真实
2. CD-11（n35 面 1-3[5-9]）是否同扩？→ 不动：该面管 1-3x 历史 Range，与 1-4x 无关
3. registry/RT-09（config 40 键）是否受影响？→ 否（零新脚本零新键）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 预扩 1-4[5-9] 而非逐轮级联（用户 2026-10-03 选 3） | 消除 Rule 47-49 三次未来级联；代价=窗口期 RT-08 对 1-47..49 越界字面失明（已披露接受） |
| 用户选 3 即批准（不重复询问） | 建议项措辞与本次计划 Goal 逐字一致，低区分度按 Rule 44.2 不再打扰 |
| CD-11/RT-09/registry 不动 | 与 1-4x 口径无关联，最小 diff |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 1 / 2 |
| 主进程直做 Phase 清单 | Phase 2（① git 编排 ② 簿记） |
| 委派率 | 0.5 <0.7 → WHITELIST-EXEMPT（直做理由均命中白名单①②） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 | executor | S1 三锚扩宽+负向自检 | done | 三 selftest 全 PASS；牙齿=1-40/44 拦/45-49 加白（我验收措辞陈旧已修正）；+10/-7 | wt:ask-default-timeout.sh:67-69 等 | Phase 1 段 | subagent-state/1-executor.md | - / 0 / ☑ |
| 2 | 2026-10-03 | executor | S2 全量回归 | done | 43/43 rc=0 ΣPASS=676 ΣFAIL=0 | subagent-state/2-executor.md | Phase 1 段 | subagent-state/2-executor.md | - / 0 / ☑ |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 处置登记: 不沉淀——task-v118 沉淀的 rule-enhancement variant 已覆盖本任务类型（同类复用，无新泛化点）
