---
template_type: rule-enhancement
plan_tier: mini
---

# Task Plan: task-v101-alignment-review — 第 11 个技能 alignment-review（对齐/同步一致性审查）

<!--
  WHAT: review-library 追加第 11 个技能 alignment-review（对齐审查：文档↔代码↔配置↔引用同步一致性）+ 级联 3 处（selftest RL-01/DIRS 10→11、CRIT 42.2 枚举 +alignment、general-review 枚举 +alignment）+ 全量回归 + 部署 push。
  WHY: 用户 2026-09-30 指令「对齐功能作为 skill 补充为专业的 skill,用于对齐文档代码等等各个方面,确保所有更新的同步更新」——本会话反复实例（三级→四级级联/计数锚漂移/B 类澄清未回溯枚举）正是对齐失效,技能化。
  交互模式: silent（/goal 延续）。plan-writer 档位死亡（v099/v100 实测）→主进程直接撰写（白名单②,同 v100 模式）。
-->

## Goal
review-library 追加第 11 个技能 `alignment-review`（对齐/同步一致性审查,四要素+清单 ≥10,范式对标 general-review）,级联更新 3 处计数/枚举锚（selftest RL-01 与 DIRS 10→11、CRIT 42.2 ④层枚举、general-review 触发段枚举）,全量 selftest 0 FAIL 后合并回 master、三部署位 IDENTICAL（池 11/11）、push GitHub、worktree 清理。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（新 SKILL.md 主审+级联面） |
| `session_id` | task-v101-alignment-review |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review |
| `branch` | wt/task-v101-alignment-review（基线 master@4194f34） |
| `scope_files` | skills/task-planner/review-library/alignment-review/SKILL.md(新); skills/task-planner/scripts/selftest-review-library.sh(RL-01/DIRS 级联); references/critical-rules.md(仅 42.2 枚举); review-library/general-review/SKILL.md(仅触发段枚举) |
| `interaction_mode` | silent |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 |
|---|----------|----------|
| VC-1 | alignment-review/SKILL.md 在位:四要素（触发条件/审查清单/证据要求/输出合约）+frontmatter name=目录名+清单 ≥10 条领域具体化+引 Rule 43.1+来源注释「成员 11/11」 | grep 四要素/清单计数/RL-04..07 循环 PASS |
| VC-2 | 级联 3 处:RL-01 断言与 DIRS 含 alignment-review 且 =11;CRIT 42.2 枚举含 alignment 且「11 类」;general-review 枚举含 alignment;三处外零改动 | grep+diff numstat |
| VC-3 | selftest-review-library 全 PASS（RL-01..10,计数 11）;全量回归（40 脚本）0 FAIL 且 PASS ≥ 638+新技能循环增量（主进程双形态求和定数） | bash 全量 |
| VC-4 | 合并部署 push 清理:merge+三位 IDENTICAL（池 11/11）+push（ls-remote 终验）+清理 0/0 | smart-merge-back+ls-remote |
| VC-5 | 边界零回归+CR APPROVED:CRIT/general-review 改动仅枚举片段;config 零改动;CR 隔离审查通过 | diff 面+CR 结论 |

**终验规则**: 全 VC → COMPLETE;遗留 → PARTIAL;3 次无效 → BLOCKED（41.4 清单前置）。

## ⚠️ 执行范围限制
| 类别 | 允许 | 禁止 |
|------|------|------|
| 新技能 | review-library/alignment-review/SKILL.md | 其他新文件 |
| selftest | scripts/selftest-review-library.sh（RL-01 计数+DIRS 清单+相关文本 10→11 级联,断言语义零改动） | 其他 selftest |
| 条款 | references/critical-rules.md 仅 42.2 行内枚举（+alignment,「10 类」→「11 类」） | Rule 1-43 其余任何行 |
| 既有技能 | review-library/general-review/SKILL.md 仅 :8 触发段枚举 +alignment | 该文件其余行;其他 9 个技能 |
| 配置 | （无） | config.json 零改动 |
| 计划 | plans/task-v101-alignment-review/** | 其他 plans/ |

## 📚 必要知识储备
| 名称 | 定位 | 必读 | ☑ |
|------|------|------|---|
| S1 范式+security 领域化写法 | review-library/{general-review,security-review}/SKILL.md | 必读 | ☑ |
| selftest RL-01/DIRS 锚 | scripts/selftest-review-library.sh :5,:27-35 | 必读 | ☑ |
| CRIT 42.2 枚举 | :420 | 必读 | ☑ |
| general-review 枚举行 | general-review/SKILL.md :8 | 必读 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 跨产物一致性（改代码漏改文档/改一处漏改引用/计数与枚举漂移/多副本失同步）无专用审查技能——新增 alignment-review 领域技能后,Rule 42.2 四级检测可按任务类型精准命中,对齐失效在交付前被系统性拦截。
- [x] 能交付 / [x] 唯一目标 / [x] 方法清晰

## Current Phase
Phase 2

## Next Step
主进程建 worktree（@4194f34）+ 基线复测（40 脚本 638/0）。

## 🧰 工具选择与编排（Rule 40）
| Phase | 工具面 | 理由 |
|-------|--------|------|
| P1 | ①③② | worktree/基线求和白名单 |
| P2 | ③ executor S1（sonnet-1 内容判断型）→S2（haiku-1 级联轻量编辑）串行 | 21.4 串行 |
| P3 | ⑥ 主进程全量求和 | 白名单③ |
| P4 | ① git 全链 | merge/deploy/push/cleanup |
| P5 | ③ code-reviewer + ②⑤ | CR 隔离+白名单 |

**workflow 判定**: 未命中（S1→S2 强依赖+用户未点名 /workflow）→21.4 串行。**/goal 对齐**: Goal+VC 即证据源;/goal 用户侧不可代调（40.3 披露）。

## Phases

### Phase 1: 基线 + worktree
- [x] worktree 建立 @4194f34,porcelain=0
- [x] 基线复测: 40 脚本 638/0（双形态求和）+wc+RL 计数 10 现状+级联锚定位
- **V-N:** VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（①git 编排+③机械验证——白名单）

### Phase 2: alignment-review 技能+级联 3 处
- [ ] S1: 新建 review-library/alignment-review/SKILL.md（范式对标 general-review;领域清单 ≥10: 文档↔代码同步/代码↔配置同步/引用完整性(失效链接与锚)/计数与枚举联动/多副本部署同步/术语一致性/变更日志同步/锚点有效性/版本对齐/跨文件语义一致——本会话实例: 三级→四级级联/RL-01 计数/B 类澄清枚举回溯,均为清单来源）
- [ ] S2: 级联 3 处——selftest RL-01 =10→=11+DIRS +alignment-review+相关文本;CRIT 42.2 枚举 +alignment-review 且「10 类」→「11 类」;general-review :8 枚举 +alignment（B 类澄清回溯防线: grep 全池 alignment 一致性）
- **V-N:** VC-1, VC-2
- **Status:** in_progress
- **Executor:** executor（S1 建议档位 sonnet-1 / S2 建议档位 haiku-1;21.4 串行 S1→S2——S2 依赖 S1 产出的枚举一致性）
| ID | 目标 | 执行体 | 建议档位 | 输入 | 验收 | 预估 | 状态 |
|----|------|--------|---------|------|------|------|------|
| S1 | alignment-review 技能 | executor | sonnet-1 | 范式 general-review+security;本计划核心问题段（清单来源=本会话实例） | 50-70 行;四要素;清单 ≥10;成员 11/11 注释 | 15min | pending |
| S2 | 级联 3 处 | executor | haiku-1 | selftest :5,:27-35+CRIT :420+general-review :8 | RL-01=11;DIRS 含 alignment;枚举 2 处含 alignment;三处外零改动 | 10min | pending |

### Phase 3: 全量回归
- [ ] 主进程全量回归定数（40 脚本双形态求和: selftest-review-library 11/0+全量 0 FAIL,PASS ≥ 638+循环增量）
- **V-N:** VC-3
- **Status:** pending
- **Executor:** 主进程（③机械验证——白名单）

### Phase 4: 合并+部署+push+清理
- [ ] 预检→smart-merge-back --deploy（池 11/11 三位）→push（ls-remote 终验）→清理 0/0
- **V-N:** VC-4
- **Status:** pending
- **Executor:** 主进程（①②③——白名单）

### Phase 5: CR Gate + 终验簿记
- [ ] CR: code-reviewer 审全量 diff（新技能内容主审+级联面）;APPROVED 才终验;CHANGES_REQUESTED→fix-phase
- [ ] 簿记: verification/INDEX/notepad/memory/check-complete（簿记提交后）/收尾
- **V-N:** VC-5
- **Status:** complete
- **Executor:** code-reviewer（sonnet-1）+ 主进程（② 计划系统文件簿记 + ⑤ 终验机械复核——Rule 25.3 白名单②⑤）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | safe（P1 复扫） |
| `isolation` | worktree |
| `worktree_path` | /mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review |
| `branch` | wt/task-v101-alignment-review（@4194f34） |
| `merge_back` | pending |

## 📊 FMEA
| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P2 | 级联漏点（「10」字样还有未发现出现处） | 7 | 4 | 3 | 84 | S2 验收含 `grep -n '10 类'` 全池零残留断言;漏点→补修（22.3②） |
| P2 | alignment-review 清单空壳化 | 7 | 3 | 3 | 63 | 清单来源=本会话真实实例（非杜撰）;CR 主审 |
| P3 | RL-01 改 11 后其他断言连锁（DIRS 循环自动适配,预期零连锁） | 5 | 3 | 2 | 30 | 全量求和定数兜底 |

## 🔁 原生 Todo 同步
| Phase | 已建 | 备注 |
|-------|------|------|
| P1-P5 | S1 映射批准后建 | 5 条 |

## Key Questions
1. 为何 alignment-review 不做进 general-review？（答: 用户明示「补充为专业的 skill」——独立技能才能被 42.2 按任务类型精准命中;对齐审查是独立审查面非通用兜底子集）
2. 「恰 10」断言改 11 是否违背 v099 撤销的固定数？（答: 否——v099 撤销的是「每项目配额」;池内计数断言是池完整性自检,随用户指令扩展）

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| silent: 池计数断言 10→11 随本指令扩展（非固定配额复活） | 用户明示新增对齐技能;RL-01 是池完整性自检非配额 |
| silent: alignment 清单来源=本会话真实对齐失效实例 | 43.3 候选预验证精神——清单条目全部有实证案例,非杜撰 |
| silent: 主进程直接撰写计划（白名单②） | plan-writer 档位 v099/v100 两度实测死亡;v100 同模式 |
| silent: push 沿用 09-30 持久指令 | v098/v099/v100 三度确认 |
| silent: 摘要/模板改动新会话生效 | 快照语义 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes
- alignment-review 清单条目全部来自本会话真实实例（级联锚/计数漂移/枚举回溯/多副本同步）——技能即经验制度化
- 禁「1-4x」越界字面;「Rules 1-39」字面 2 处不动

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
| `rollback_point` | master@4194f34 |

## 📊 委派统计
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 | 1 / 5（P2;P5-CR 部分） |
| 主进程直做 | P1/P3/P4/P5（①②③⑤——白名单） |
| 委派率 | 预期 0.2 → 25.4a WHITELIST-EXEMPT |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|-----------|------|
| 1 | 2026-09-30 | executor | P2-S1 alignment-review 技能 | done | 50 行四要素+清单 14 条（10 来源案例化+4 补强）;6/6 验收过（主进程抽验） | 01-exec-p2s1.md | findings Requirements | plans/task-v101-alignment-review/subagent-state/01-exec-p2s1.md | - / 0 / ☑ |
| 2 | 2026-09-30 | executor | P2-S2 级联 3 处 10→11 | done | RL-01=11/DIRS+alignment/CRIT 11 类/gen 枚举+alignment;三处外零改动;3 脚本 0 FAIL;RL-02..10 文案 10→11 由主进程白名单③补全（9 处） | 02-exec-p2s2.md+主进程复核 | findings Research | plans/task-v101-alignment-review/subagent-state/02-exec-p2s2.md | - / 0 / ☑ |
| 3 | 2026-09-30 | code-reviewer | P5 CR Gate | done | 首审 APPROVED（0 P0/2 P1 文案级/2 P2）→fix-phase 全处置（P1×2 一词级+P2-b 归因纠正+P2-a 登记） | 03-cr-p5.md | verification CR 段 | plans/task-v101-alignment-review/subagent-state/03-cr-p5.md | - / 0 / ☑ |

## 🔗 Chain 区块交接配置
| 字段 | 值 |
|------|-----|
| **chain_mode** | single |
| **current_block** | Block 1 |
| **handoff_on_complete** | ✅ 是 |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
- 已知类型;终验处置: 不沉淀理由:已知类型消费+池成员扩展（非新审查制度形态）,34.3 不命中（终验登记）
