# Task Plan: task-planner 技能只读全面审查（/workflow 动态工作流执行）

<!-- plan_tier: standard -->
## Goal
通过动态工作流（Rule 39 路由 /workflow）对 skills/task-planner 当前技能做只读全面审查，产出含证据与独立验证的审查报告 `plans/task-planner-skill-review/report.md`；只列问题，不实施修复。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯调研/只读审查，机制画像=调研组） |
| `template_type` | `general` |
| `interaction_mode` | `ask` |
| `scope_files` | `plans/task-v089-skill-review/**`（计划簿记） + `plans/task-planner-skill-review/report.md`（工作流写出的交付报告）；审查对象 skills/task-planner/** 全程只读 |
| `git_commit` | `deferred`（plans/ 按仓约定不入库；本任务无 scope 代码产物） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 审查报告存在且非空（含 4 领域分节 + 发现证据 + 确定性门结果 + 未覆盖说明） | Read 报告全文 | `plans/task-planner-skill-review/report.md` |
| VC-2 | 27/27 selftest 逐一运行并汇报 Total 行；FAIL>0 的脚本逐一名列 | 工作流阶段 1 日志 + 报告 §门控结果 | 报告「确定性门结果」节 |
| VC-3 | 每个领域（4 个）有独立审计结论，每条发现带 confirmed/unconfirmed 标注 | 报告各发现 status 字段 | 报告 4 领域分节 |
| VC-4 | 三文件回填 + INDEX 刷新：findings.md 有审计结论摘要，progress.md 有动作记录，INDEX.md 状态更新 | Read 三文件 + INDEX | `plans/task-v089-skill-review/` |
| VC-5 | 交付结论数字与 verified 值一致（断言总数/发现数/确认数互相对得上） | 报告结论段 vs verified 段交叉核对 | 报告 ①③ 节 |

**终验规则**：全部 VC 通过 → outcome: **COMPLETE**；VC 通过但遗留 → **PARTIAL**；≥1 VC 失败重试 3 次无效 → **BLOCKED**。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 计划簿记 | plans/task-v089-skill-review/{task_plan,findings,progress,verification,notepad-learnings,knowledge-brief}.md + INDEX.md | 其他 plans/ |
| 交付报告 | plans/task-planner-skill-review/report.md（工作流写） | 其他 plans/ 目录 |
| 审查对象 | skills/task-planner/**（只读：Read/grep/跑 selftest 与 bash -n） | 对 skills/ 的任何 Write/Edit |

**执行前自我检查:** 文件在列表内？修改必要？用户要求？全 Yes → 执行；任一 No → 先问用户。

## 📚 必要知识储备
| 类别 | 名称/主题 | 定位 | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 技能本体 | /mnt/data/dev/task-planner-skill/skills/task-planner/（SKILL.md 558 行 / config.json 440 键 / 27 selftest / 12 references / 11 templates） | 必读 | ☑ |
| 规范/标准 | 工作流编写契约 | dynamic-workflows skill（本会话已加载，§16 编译器契约） | 必读 | ☑ |
| 规范/标准 | 宪法纪律 | ~/.zcode/AGENTS.md §一（子代理优先）/§三（证据铁律）/§四（防漂移） | 参考 | ☑ |

## ⚠️ 核心问题定义
**核心问题**: 当前 task-planner 技能在「规则文档 ↔ 机器守卫 ↔ selftest 覆盖」三层之间是否存在漂移/缺口，以及技能质量的健康度如何？
- [x] 核心问题解决后，交付一份可复核的审查报告（即结果可交付）
- [x] 不解决则后续技能增强建立在未验证的现状上（其他工作白费）
- [x] 方法清晰可执行（确定性门 + 4 领域并行审计 + 独立验证 + 两轮批判）

## Current Phase
Phase 2

## Next Step
终验闭环：sync-todos 刷新 INDEX + check-complete 终验 → 交付结论

## Phases

### Phase 1: 工作流执行（确定性门 + 4 领域审计 + 验证 + 批判 + 报告）
- [x] 修正脚本 critique 变量编译错并重新提交 CreateWorkflow（path）
- [x] 工作流阶段 1：27 selftest + bash -n 语法检查（门控判定）
- [x] 工作流阶段 2：4 领域并行审计（docs/critical+templates/config+selftests/lib）+ 逐条独立验证
- [x] 工作流阶段 3：两轮独立批判
- [x] 工作流阶段 4：报告写入 plans/task-planner-skill-review/report.md 并 artifact 发布
- [x] 收取运行结果（conclusion + findings + verified/notCovered）
- **V-N:** VC-1, VC-2, VC-3, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:④ 用户显式要求 /workflow 动态工作流编排——Rule 39 路由，Skill("dynamic-workflows") 已加载；工作流内部 21.4 并行豁免按 39.4 登记；机械验证命令 world.run 由脚本执行=白名单③）
- **Evidence:** run dwfrun-133695f0 completed；报告 plans/task-planner-skill-review/report.md（21864B）

### Phase 2: 簿记回填与终验交付
- [x] findings.md 回填：4 领域结论摘要 + 工作流 run id + 报告路径
- [x] progress.md 回填 Phase 1/2 动作记录（工作流各阶段结果）
- [x] verification.md 逐条 VC-1..5 复验 + 委派统计段填写
- [x] sync-todos.sh --index 刷新 INDEX.md；check-complete.sh 终验 exit 0
- [x] 交付：向用户报告结论（发现数/确认数/高严重项）
- **V-N:** VC-1, VC-4, VC-5
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单②）

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（仅信号①=本计划目录自身未跟踪，与审查范围无重叠） |
| `isolation` | `direct`（纯调研/只读任务，命中 §11.5 例外③；skills/ 零写入） |
| `worktree_path` | n/a |
| `branch` | n/a |
| `merge_back` | n/a |

## 📊 FMEA 预演
| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作 |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 工作流脚本编译/运行失败（如断言行解析漏匹配） | 3 | 2 | 2 | 12 | 22.3 ①改派：按诊断 Edit draft 文件后 AmendWorkflow(path) 修订重跑（39.3 机制映射） |
| Phase 1 | 子代理 provider 侧错误导致 run stopped | 4 | 1 | 2 | 8 | 39.3 断点机制：ResumeWorkflowRun 续跑同一 run |
| Phase 2 | 工作流未跑完用户已离开（跨会话） | 3 | 2 | 3 | 18 | 22.8 检查点：Read 三文件 + GetWorkflowRun 快照恢复 |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 计划创建时（TodoWrite） | 工作流执行 |
| Phase 2 | ☐ | | 簿记回填 |

## Key Questions
1. 4 领域共发现多少条问题，其中多少经独立验证 confirmed？
2. 27 个 selftest 是否全绿（总断言数 vs memory 记录 453/0 基线）？
3. 规则 1-39 文档面与机器守卫面是否有新的级联漂移（前序 v088 已修 1-39 级联）？

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 执行方式=动态工作流（非 21.4 串行 Agent 派发） | 用户显式 /workflow → Rule 39.1 触发纪律；39.2 skill 已加载；39.4 21.4 并行豁免登记：4 领域审计并行执行，不套串行铁律 |
| 报告落 plans/task-planner-skill-review/report.md | plans/ 按仓约定不入库，避免 git_commit 纠缠；用户可打开的文件 |
| 审查只读、不实施修复 | 用户要求=「审查」；修复类=新任务（Rule 8.1 D 类），报告列建议即可 |
| 门控=全量 27 selftest + bash -n（最强层） | 仓库最强自检面就是 selftest 全集，脚本世界面 exit code 判定，不信任子代理自报 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| CreateWorkflow 编译错 L183/L204 critique used-before-assigned | 1 | Edit draft 文件 `let critique: string;` → `let critique = ""` | 循环前初始化为空值而非延迟赋值 |

## Notes
- 更新 Phase 状态 pending → in_progress → complete
- 重大决策前重读本计划
- 全部错误即时记录

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|  |  |  |  |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 2 |
| 主进程直做 Phase 清单 | Phase 1（④ 用户显式 /workflow 编排 + ③ 机械验证）；Phase 2（② 计划簿记） |
| 委派率 | 0（两条白名单理由均命中 25.3 ④② → WHITELIST-EXEMPT） |

## 🔗 Subagent Handoff 登记表
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| - | 本计划未走 21.4 Agent 派发（Rule 39 workflow 路由；内部子代理为工作流机制，登记于 Decisions） | | | | | | | | | 0 | ☑ |
