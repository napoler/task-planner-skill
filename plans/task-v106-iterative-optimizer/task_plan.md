---
template_type: skill-enhancement
plan_tier: standard
---

# Task Plan: task-v106-iterative-optimizer — 新建循环迭代优化 skill（评估→诊断→定向改进→门控收敛）

<!--
  WHAT: 仓内新建顶层 skills/iterative-optimizer/SKILL.md(循环迭代优化器:提示词精修/参数调优/缺陷修正类任务的「评估→诊断弱点→定向改进→门控判定」闭环,质量标准全 PASS 或达 max_iterations 收敛,输出迭代摘要表)+selftest-iterative-optimizer(IL-01..08)+registry 登记;三宿主部署+push。
  WHY: 用户 2026-10-01 指令:「Create a reusable skill that runs tasks in a loop-based iterative mode to progressively optimize content...prompt refinement, parameter tuning, defect correction...each iteration must automatically evaluate, identify weaknesses, apply targeted improvements, and decide whether another round is needed...until predefined quality criteria or maximum iteration limit...stable repeatable pattern...brief iteration summary (what changed, why, resolved?)」。
  交互模式: silent(指令完整自包含,无歧义)。主进程直接撰写计划(白名单②)。
-->

## Goal
新建顶层 skill `skills/iterative-optimizer/SKILL.md`(五步闭环:评估→诊断→定向改进→门控→收敛判定;输入契约含质量标准≥3 条且≥1 条机器可检查+max_iterations 默认 5;门控铁律禁 AI 自报/PARTIAL 禁宣称 COMPLETE/连续 2 轮无改善停止;状态文件 plans/loop-<task-id>-state.md 断点续跑;迭代摘要表=改了什么/为什么/门控结果+RESOLVED/PARTIAL/BLOCKED 结论) + selftest-iterative-optimizer.sh(IL-01..08)+registry +1 行;全量 selftest 0 FAIL(42 脚本)后合并、三宿主部署、push、清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | task-v106-iterative-optimizer |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer |
| `branch` | wt/task-v106-iterative-optimizer(基线 master@e620a03) |
| `scope_files` | skills/iterative-optimizer/SKILL.md(新建); task-planner/scripts/selftest-iterative-optimizer.sh(新建); task-planner/scripts/selftest-registry.tsv(+1 行); plans/INDEX.md(簿记) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | SKILL.md 在位:frontmatter name=iterative-optimizer+description(含触发词:迭代优化/循环/prompt refinement/parameter tuning/defect correction);五步流程锚(评估/诊断弱点/定向改进/门控/收敛)各≥1;输入契约表(质量标准≥3 条且≥1 机器可检查+max_iterations 默认 5)在位;门控铁律(禁自报/PARTIAL 禁宣称 COMPLETE/连续 2 轮无改善停止)≥3 条;状态文件锚 plans/loop-<task-id>-state.md;迭代摘要表(改了什么/为什么/门控结果)+结论枚举(RESOLVED/PARTIAL/BLOCKED) | grep+Read |
| VC-2 | selftest IL-01..08 全 PASS(Total: 8 PASS=8 FAIL=0)+registry 登记 43 行(SR-12 动态口径 42 脚本+表头) | bash |
| VC-3 | 全量回归 42 脚本 0 FAIL 且 PASS ≥652+8(主进程定数) | bash 全量 |
| VC-4 | 合并部署 push 清理:merge;三宿主新 skill 分发(install-companion 或定向 cp,三地 diff 一致);push ls-remote 终验;清理 0/0 | ls+diff+ls-remote |
| VC-5 | 边界零回归+CR APPROVED(diff 面=新建 2 文件+registry 1 行,既有 41 脚本与守护内容零改动) | CR 结论 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED(41.4 前置)。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 新建 | skills/iterative-optimizer/SKILL.md;task-planner/scripts/selftest-iterative-optimizer.sh | 动池成员/卫星既有内容 |
| 登记 | selftest-registry.tsv 追加 1 行 | 改既有行 |
| 配置 | (无) | config.json 零改动;install-stub SATELLITE_SKILLS 不动(install-companion 已覆盖分发,最小范围) |

## 📚 必要知识储备
| 名称 | 定位 | ☑ |
|------|------|---|
| 池成员四要素+输出合约范式 | review-library/general-review/SKILL.md | ☑ |
| selftest 范式(R 脚本:SCRIPT_DIR/ok-bad/Total/exit) | scripts/selftest-reliability-institution.sh | ☑ |
| registry 行形态 | scripts/selftest-registry.tsv | ☑ |
| 卫星 skill 形态(纯文档顶层) | skills/plan-template-kit/SKILL.md | ☑ |
| S54 Loop 元件(State+Gate 必选) | skill-fix Standard 54 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 优化类任务(提示词精修/参数调优/缺陷修正)缺乏可复用的迭代收敛模式——单次执行无评估闭环,「感觉更好了」式自报无法证伪,多轮改动归因失效。解=固定五步闭环(评估→诊断→定向改进→门控→收敛判定)+质量标准前置(≥3 条且≥1 机器可检查)+单 focus 原则(每轮只治最弱项)+状态文件断点+迭代摘要留痕,形成稳定可重复模式。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
(终态)Phase 5 complete — outcome: COMPLETE

## Next Step
交付报告呈示。\n主进程派发 S1(executor 撰写 SKILL.md,任务书含完整设计规格)。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P2 | ③ executor S1(sonnet-1 设计型撰写)→S2(haiku-1 selftest+registry)串行 | 21.4 |
| P3 | ⑥ 主进程求和 | 白名单③ |
| P4 | ① git 全链+install-companion 分发 | 白名单① |
| P5 | ③ CR+②⑤ 簿记 | 白名单②⑤ |

## Phases

### Phase 1: 基线 + worktree
- [x] worktree @e620a03,porcelain=0;基线 41 脚本 652/0;SATELLITE 锚普查(无守护锚,不加 install-stub)
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（① 纯 git/worktree 编排 + ③ 机械验证（基线求和纪律禁子代理自报）——Rule 25.3 白名单①③）

### Phase 2: skill+守护（S1→S2 串行）
- [ ] S1: 撰写 skills/iterative-optimizer/SKILL.md（任务书含逐段设计规格:frontmatter/Goal/触发条件/输入契约表/五步流程/门控铁律/状态文件/迭代摘要输出合约/反模式;90-120 行;纯文档零 scripts/config）
- [ ] S2: selftest-iterative-optimizer.sh(IL-01..08,断言对象=../iterative-optimizer/SKILL.md 相对仓根路径)+registry +1 行
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** executor（S1 sonnet-1/S2 haiku-1;21.4 串行）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | SKILL.md 撰写 | executor | sonnet-1 | 任务书逐段设计规格 | VC-1 全锚;banned 词扫描(更好/合理/优化成功 类主观判定词在 QC 上下文零命中) | 20min | pending |
| S2 | selftest+registry | executor | haiku-1 | IL-01..08 断言清单+registry 形态 | Total: 8/0;registry 43 行 | 10min | pending |

### Phase 3: 全量回归
- [ ] 主进程定数(42 脚本双形态求和:IL 8/0+全量 0 FAIL,PASS ≥660)
- **V-N:** VC-3
- **Status:** complete
- **Executor:** 主进程（③ 机械验证（全量求和定数禁子代理自报）——Rule 25.3 白名单③）

### Phase 4: 合并+部署+push+清理
- [ ] 预检→merge→task-planner 位 smart-merge-back --deploy→新 skill 三宿主分发(install-companion --target ×3 或定向 cp+diff 亲验)→push(ls-remote)→清理 0/0
- **V-N:** VC-4
- **Status:** complete
- **Executor:** 主进程（① git 编排（merge/deploy/分发/push/cleanup 全链）+ ③ 机械验证（diff/ls-remote 终裁）——Rule 25.3 白名单①③）

### Phase 5: CR Gate + 终验簿记
- [ ] CR(code-reviewer 隔离审 diff;ECONNREFUSED 时 22.3① 改派 executor);APPROVED 才终验
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete(簿记提交后)
- **V-N:** VC-5
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）（CR 隔离审查）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe(P1 复扫) |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v106-iterative-optimizer |
| `branch` | wt/task-v106-iterative-optimizer(@e620a03) |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | SKILL.md 混入主观判定词(Goal 质量铁律 S47/48 违规) | 7 | 3 | 3 | 63 | 任务书列 banned 词清单;S1 自验+CR 专项 |
| P2 | selftest 断言锚与实文漂移 | 6 | 3 | 3 | 54 | S2 动手前 Read S1 产出实测 |
| P4 | install-companion 顺带同步其他漂移文件 | 6 | 3 | 3 | 54 | 部署前后 git status+diff 面核对;漂移则改定向 cp |
| P4 | 新 skill 宿主面与前缀冲突 | 5 | 2 | 3 | 30 | 名字唯一性已普查(审计 A' 零重复) |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 6 条 |

## Key Questions
1. 为什么顶层而非池成员？（答: 迭代优化是执行型工作流 skill,不是质量审查技能——池 42.2 ④层语义不匹配;顶层+install-companion 分发=与卫星同构）
2. 为什么 Gate 不配脚本？（答: 质量标准任务特定,通用 gate 脚本无法评估任意内容;skill 强制「≥1 条机器可检查标准」由调用方供给,LLM 跑命令附证据=S74 口径）
3. 为什么不加 install-stub SATELLITE_SKILLS？（答: 该数组服务于 per-tool stub 安装场景,install-companion 顶层循环已覆盖全量分发;最小范围 YAGNI,锚普查确认无守护锚引用）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 顶层 skills/iterative-optimizer(非池成员) | 执行型工作流≠审查技能;42.2 ④层语义不匹配 |
| silent: 质量标准前置契约(≥3 条且≥1 机器可检查) | 防「感觉更好」自报收敛;S74 证据口径 |
| silent: 单 focus 原则(每轮 1-2 最弱项) | 多轮归因有效性;防大重写回归 |
| silent: max_iterations 默认 5 | 与 Rule 44 超时默认同类;调用方可覆盖 |
| silent: 主进程直接撰写计划 | 白名单②;plan-writer 档位死亡多度实测 |
| silent: push 沿用 09-30 持久指令 | 用户「部署到各个平台,然后提交到 GitHub 进行备份」多度确认 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- 用户原话锚: 「loop-based iterative mode」「progressively optimize」「prompt refinement, parameter tuning, defect correction」「evaluate, identify weaknesses, apply targeted improvements, decide whether another round」「predefined quality criteria or maximum iteration limit」「stable, repeatable」「what changed, why it changed, resolved」——全部入 SKILL.md 对应段
- 禁「1-4x」越界字面;「Rules 1-39」字面 2 处不动;config 零改动

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

## 📦 Batch Report
| 字段 | 值 |
|------|-----|
| `total` | 0（零单元声明——非批量） |
| `success` | 0 |
| `failed` | 0 |
| `failure_rate` | 0% |
| `sampled_pass` | 0 |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否/Q2:有/Q3:能 |
| `rollback_point` | master@e620a03 |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5(P2;P5-CR 部分) |
| 主进程直做 | P1/P3/P4/P5(①②③⑤——白名单) |
| 委派率 | 预期 0.2 → 25.4a 判定 |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-10-01 | executor | P2-S1 SKILL.md 撰写 | done | 96 行(fix 后 97);八锚全入;banned 零命中 | 01-exec-p2s1.md+主进程通读 | findings Requirements | plans/task-v106-iterative-optimizer/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-10-01 | executor | P2-S2 selftest+registry | done | IL 8/0;相对路径解析;SR-12 咬合 43 行 | 02-exec-p2s2.md | findings Research | plans/task-v106-iterative-optimizer/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-10-01 | code-reviewer | P5 CR Gate | done | **APPROVED**(0 P0/P1;4 P2→fix-phase 3 处置+1 证伪) | 03-cr-p5.md | verification CR 段 | plans/task-v106-iterative-optimizer/subagent-state/03-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: skill-enhancement -->
- 已知类型;终验处置: 不沉淀理由(34.3 不命中,终验登记)
