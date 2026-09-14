# Task Plan: task-v072 错误学习闭环（Rule 31 — 用户指出错误 → 根因分析 → 计划/规则优化 → 防复现）

## Goal
补齐 task-planner 技能「用户指出错误/打断/补充数据 → 盲目修改」缺陷：新增 **Rule 31 错误学习闭环**——用户指出错误时先做结构化的根因分析（5 Whys 式 4 维归因），再按归因修正计划/规则/数据源，再执行修复，最后把防复现措施沉淀进 notepad-learnings 供后续任务消费；配 Error Log 加列（Root Cause / Prevention）、终验 Learning Gate（check-complete.sh 静态校验 + C19 检查项）、开关键 `config.json#error_loop_enforce`（默认 warn）、selftest-error-loop.sh 静态守护。

## 背景（用户 2026-09-14 反馈 + Explore 探查结论）
现状 5 个缺失环节（本次全部补齐或显式登记）：
1. B/C 类用户指令流程无根因分析强制环节（Rule 8 只要求改文档，不回答"为什么错"）
2. Error Log 表无根因/防复现字段（progress.md 4 列 / task_plan.md Errors 3 列）
3. 三击协议第 3 击"考虑更新计划"非强制、无沉淀（reference.md:229-233）
4. 防复现闭环缺失：notepad-learnings "What Didn't Work / Notes for Next Time" 写了无人读（记录侧+消费侧双断）
5. meta-corrector 复盘仅限批量 failure_rate>10%（Rule 18.8），未推广到用户指出错误场景

## 范围（实现文件清单 — 全部在 worktree 内，权威源 skills/task-planner/ 仓内副本）
| # | 文件 | 改动 |
|---|------|------|
| F1 | skills/task-planner/references/critical-rules.md | 新增 Rule 31（31.1 触发 / 31.2 分析 / 31.3 修正 / 31.4 沉淀 / 31.5 消费 / 31.6 机制+门控）；Rule 8 加 31.4 引用 |
| F2 | skills/task-planner/SKILL.md | ① frontmatter references 行 1-28→1-31 ② Critical Rules 摘要加 Rule 31 行 ③ References 表 critical-rules 行 1-28→1-31 ④ C19 合规检查项 ⑤「🆕 用户新指令处理」段尾部加"错误指出→Rule 31"指针 |
| F3 | skills/task-planner/templates/progress.md | Error Log 表加 2 列：Root Cause（根因 1-2 句）/ Prevention（防复现措施+落点，`<待沉淀>` 占位） |
| F4 | skills/task-planner/templates/task_plan.md | Errors Encountered 表加 1 列：Prevention 指针（`→ progress.md Error Log`） |
| F5 | skills/task-planner/templates/notepad-learnings.md | "What Didn't Work" 段加结构化字段注释 + "Notes for Next Time" 加消费侧契约注释（31.5） |
| F6 | skills/task-planner/config.json | properties + default 双处加 `error_loop_enforce`（enum enforce/warn/off，默认 warn；additionalProperties:false 需双处同步） |
| F7 | skills/task-planner/scripts/check-complete.sh | 终验加静态 Learning Gate：progress.md 存在且有 ≥1 条 Error Log 数据行时，各行 Root Cause 列非空（`<待沉淀>` 占位不算）→ 有缺失 = Learning Gate FAIL 计入 exit 1 原因；无 Error 行 → PASS（静默） |
| F8 | skills/task-planner/scripts/selftest-error-loop.sh | 新建静态守护（~12 断言：条款存在性/字段锚点/config 键/SKILL 联动/C19/模板列） |

> 明确不做（YAGNI，登记 Decisions）：① 不新建 7th 计划文件 error-log.md（Error Log 加列 + notepad 段即可，避免文件面膨胀——三文件罗盘原则）；② 不建独立 check-error-loop.sh（学习闭环门控挂在 check-complete.sh 终验静态校验 + 31.5 消费侧为流程层 SOP，对齐 Rule 29/30 的"流程层执行无 hook 校验"范式）；③ Rule 31 的 31.2/31.3/31.5 执行主体为主进程（分析/修正属调度判断，非业务代码执行，Rule 14 不适用；分析落盘 = 计划系统文件维护白名单②）。

## Phases

### Phase 1: 规则层 — critical-rules.md Rule 31 + Rule 8 联动
- **Status:** pending
- **Executor:** executor(code-assistant 档位)
- **Scope:** F1
- **Steps:**
  1. 31.1 触发条件（任一，用户指令判为"错误指出"）：① 用户指出 agent 已产出/执行结果有误 ② 用户对同一问题重复反馈 ≥2 次（复用宪法 §四 漂移信号）③ 用户执行中打断并补充新数据/约束推翻既有结论 ④ check-drift.sh 输出含"同一错误同 Phase ≥3 次"错误循环信号（ERROR-LOOP）
  2. 31.2 结构化根因分析（禁止跳过直接修改）——五要素 4 维归因表，写入 progress.md Error Log 对应行：
     | 维度 | 追问 | 示例 |
     |------|------|------|
     | 现象 | 用户原话 + 触发位置 | "部署位 B 漏了" |
     | 直接原因 | 哪个动作/假设导致 | 按旧约定写死 3 实体位 |
     | 根因(5 Whys ≤5 层) | 为什么会犯 | 部署拓扑变更后 SKILL 未联动 |
     | 类别 | 信息缺失/假设未验/规则缺位/数据源过时/执行偏差 | 规则缺位 |
     分析完成前禁止动手修改（= Rule 7 三击第 3 击"考虑更新计划"升格为强制）
  3. 31.3 修正路由（按类别定向改，禁止"盲目改症状处"）：
     - 假设未验/执行偏差 → 修 task_plan.md 对应 Phase/VC + findings.md 修正结论（B/C 类按 Rule 8 走 S5 同步）
     - 规则缺位/检查清单缺口 → 更新计划内防线（新增 V-N / C-check / 检查项）；规则本身（critical-rules）缺口 → 登记 Decisions Made + 提案进 notepad "Notes for Next Time"（技能规则本体修改走后续任务，本任务不越权改运行中技能——宪法 §六）
     - 信息缺失 → 立即补齐调研（WebSearch/Read 真实数据，宪法 §九"修 bug 前先 Read 真实数据样本"）
     - 数据源过时 → 修正数据源 + 标注旧值 superseded（Rule 29.2a 语义）
  4. 31.4 沉淀（强制，与 31.3 同一动作内完成）：notepad-learnings.md 三段各写一行——`What Didn't Work`（错误描述+类别）/ `Notes for Next Time`（触发条件 + 防线一句话）；progress.md Error Log 行的 `Prevention` 列由 `<待沉淀>` 翻成实际措施
  5. 31.5 消费侧（防"写了没人读"）：① 下一 Phase 开工前 Read notepad "Notes for Next Time" 未消费项，命中同类场景 → 按注记执行 ② 终验 Learning Gate（F7）：Error Log 各行 Root Cause 非空 ③ 新任务计划创建时（init-session 后）Read 上一 completed 任务 notepad "Notes for Next Time" 作风险预演输入（仅指针，无脚本，流程层）
  6. 31.6 机制：开关键 `config.json#error_loop_enforce`（默认 warn：漏 31.2 分析在 progress.md 记一行；off 不触发；enforce 预留）；check-complete.sh 静态 Learning Gate（F7）；selftest-error-loop.sh 静态守护（F8）
- **VC-1:** critical-rules.md 含 `^31\.[1-6]` 六个子条款，31.2 含 5 Whys 锚点，31.4 含 notepad 沉淀语义
- **VC-2:** Rule 8 文本含 Rule 31 引用（联动）

### Phase 2: 模板层 + SKILL.md 联动
- **Status:** pending
- **Executor:** executor(code-assistant 档位)
- **Scope:** F2-F5
- **Steps:** ① progress.md Error Log 加列 ② task_plan.md Errors 加列 ③ notepad 段注释 ④ SKILL.md 五处（frontmatter/摘要行/References 表/C19/新指令处理指针）⑤ C19 文案：用户指出错误（B/C 类命中"错误指出"）已按 Rule 31 走 31.2 根因分析且 Error Log 行 Root Cause 非空
- **VC-3:** 模板 3 文件列结构正确（grep 表头锚点）
- **VC-4:** SKILL.md 含 "Rule 31" 摘要行 + C19 行 + frontmatter `1-31`

### Phase 3: config + check-complete.sh Learning Gate
- **Status:** pending
- **Executor:** executor(code-assistant 档位)
- **Scope:** F6-F7
- **Steps:** ① config.json properties + default 双处 `error_loop_enforce`（jq 校验 JSON 合法 + additionalProperties:false 下键已声明）② check-complete.sh 加 Learning Gate 段（静态：解析 progress.md Error Log 表数据行，Root Cause 列空或 `<待沉淀>` → 打印 Learning Gate FAIL + 计入 exit 1；注意 awk 区间提取用状态机式（gawk 5.2 陷阱，见 memory task-planner-awk-scope-extraction-bug））③ 无 Error 行/无表 → PASS 静默
- **VC-5:** `jq . config.json` 通过；`python3 -c "import json;json.load(open('...'))"` 通过
- **VC-6:** 构造含未沉淀 Error 行的假 progress.md → check-complete.sh 报 Learning Gate FAIL；沉淀完整 → 不报（端到端 2 用例）

### Phase 4: selftest-error-loop.sh + 全量回归
- **Status:** pending
- **Executor:** executor(code-runner 档位 / 主进程机械命令)
- **Scope:** F8
- **Steps:** ① 新 selftest ~12 断言（对照 selftest-shared-tracker.sh 范式：条款存在性 + 语义锚点 + config 键 + SKILL 联动 + C19 + 模板列 + check-complete Learning Gate 代码锚点）② 全量 selftest 回归（19+ 脚本跑一遍，历史 227 断言基线 + 新增）
- **VC-7:** selftest-error-loop 全绿
- **VC-8:** 全量 selftest 无新增 fail（旧断言不回归）

### Phase 5: 变更联动审计 + 交付簿记
- **Status:** pending
- **Executor:** 主进程（白名单②计划系统文件维护 + ③机械验证）
- **Scope:** 仓内引用扫描 + plans 三文件 + ledger
- **Steps:** ① 宽口径 grep `Critical Rules 1-` / `Rules 1-` / `Rule 30`（确认无应联动未联动处；Rule 30 行不动）② skill-collaboration.md 是否需加 meta-corrector 协同行（31.x 引用 meta-corrector？——设计裁定：31.2 主进程分析为主，meta-corrector 作为"同法反复失败"可选升级项在 31.6 提及即可，矩阵不加行，避免双权威源）③ 交付簿记：INDEX v072 + .zcode/ledger 账本 done 条目
- **VC-9:** grep 审计清单留痕 progress.md；账本条目登记

## Execution Scope 表（scope_files）
F1-F8 全部文件 + scripts/selftest-*.sh 只读回归

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Rule 编号 31（task-v072） | 30 已被共享追踪占用；用户裁决"修好"= 新任务编号延续 |
| Error Log 加列而非新文件 | 三文件罗盘原则；新文件 = 认知面+5（init-session 6→7 文件），列扩展零成本 |
| Learning Gate 挂 check-complete.sh 终验 | 对照 19.5 3-File Gate 终验静态范式；执行期靠 31.2 流程层 + warn 提醒（对齐 29/30 无 hook 校验范式） |
| 31.2/31.3/31.5 主进程执行 | 根因分析属调度判断；落盘=计划系统文件白名单② |

## 隔离决策
- worktree：/mnt/data/dev/task-planner-skill-worktrees/v072（分支 wt/task-v072）
- 合并回：Phase 4 全绿 + git status 干净 → smart-merge-back.sh → 3 实体位部署（rm+cp -rL + diff -r）
