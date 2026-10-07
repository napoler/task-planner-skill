<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v074 变体; 本任务=task-v146 偏移检查子代理化 -->

# Task Plan: 偏移检查子代理化（Rule 61）— task-v146

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「优化当前技能的防止偏移策略」
- **R2**: 「我希望可以优化在检查偏移时候可以将检查任务偏移放入到子代理中检查 这样既可以保持上下文干劲 又可以规避上下文爆炸」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 / VC-3 | Rule 61 条款在位（grep 锚）+ 6 处触发点载体全切换（`Skill("task-drift-guard")` 执行链路 0 命中） |
| R2 | VC-2 / VC-3 / VC-4 | drift-checker 子代理载体在位 + 检查点落盘契约 + selftest 守护 + 回归 0 FAIL |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
结果级需求 =「保持主上下文干净 + 规避上下文爆炸」——偏移检查生产管线逐工序审计：

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 触发（6 处载体） | 载体=主上下文 skill 调用，检查时读计划全文+git 输出涌入主上下文 | SKILL.md 六处+hook 文案切 drift-checker 派发 | VC-3 |
| 检查执行 | 无隔离执行体，SOP 在主上下文展开 | drift-checker 伴随 agent 封装 SOP（haiku-1 档） | VC-2 |
| 产出回收 | 检查报告全文进主上下文 | 单行判定+检查点指针（61.3） | VC-2 |
| 失败兜底 | 子代理失败无降级路径会停摆 | 61.5 降级链（重试→check-drift.sh 机械检） | VC-1 |
| 防退化 | 未来改回主上下文执行无守护 | selftest-drift-check-subagent.sh 静态守护 | VC-4 |
| 部署一致 | 新 agent 不入部署位=有名无实 | companion/agents 通配部署+3 位对账 | VC-5 |

<!-- plan_tier: standard -->
## Goal
落地 Rule 61 偏移检查子代理化：Rule 15.1 全部触发点从 `Skill("task-drift-guard")` 主上下文执行改为派发专属 `drift-checker` 伴随 agent（haiku-1 档、只读+检查点），主进程只消费单行判定+检查点指针；task-drift-guard 卫星保留为交互/独立场景载体（双载体三态语义一致）；全量 selftest 0 FAIL 后合并回 master 并部署。

## 配置表
| 字段 | 值 | 说明 |
|------|-----|------|
| `template_type` | `rule-enhancement` | 规则增强类 |
| `interaction_mode` | `silent` | 用户已给明确总诉求（偏移检查移入子代理/保持上下文干净），执行链无语义分叉；静默决策清单随交付呈报（Rule 28） |
| `new_rule` | `61` | Rule 20.6 预留（rule-reserve check 已确认 free；59/60 为并行任务 v144/v145 预留，已避开） |
| `code_review` | `required` | 改动含 .sh 脚本（hook 文案+新 selftest）；预计 2 代码文件且 >50 行 → 重 diff 全量 CR |
| `git_commit` | `per-phase` | Rule 27 逐 Phase 提交（worktree 内） |
| `chain_mode` | `single` | 单 block |

## 🔍 Code Review / 质量审查 / 询问点登记（Rule 42/44 消费）
| 项 | 登记值 |
|----|--------|
| 质量审查工具（42.2 检测结论） | `alignment-review`（用户级在位，~/.zcode/skills/alignment-review）；CR 用 `code-review` skill 上下文隔离审查 |
| 自动超时默认项（44） | 本计划无 2+ 选项询问点（silent 模式自主裁决），豁免登记 |
| 对齐审查（42.6.2） | 完成前对全部产出跑 alignment-review，变更记录随交付落盘 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 61 条款完整（61.1-61.6 子条锚）+ Rule 15.4 载体条款落盘 + critical-rules 索引括注扩展至 Rule 40-61（头部 `Rules 1-39` 保持不动防级联） | grep 子条锚 + Read 条款节 | `references/critical-rules.md` |
| VC-2 | `companion/agents/drift-checker.md` 在位（frontmatter model=haiku 档、tools 只读+Write 检查点、三态 SOP、checkpoint 契约、禁改仓库文件约束）∧ `references/agent-coverage.md` 登记行在位 ∧ selftest-agent-coverage 通过 | Read + grep + selftest-agent-coverage.sh | 两文件 + selftest 输出 |
| VC-3 | SKILL.md 执行链路 `Skill("task-drift-guard")` 精确串 **0 命中**（负断言），6 处触发点（执行循环步骤6/Chain交接/用户新指令B-C/C4/Rule15摘要/路由表+References）全部 drift-checker 派发锚；SKILL.md 行数 ≤558 现行断言内；`zcode-userpromptsubmit.sh` hook 载体文案已切（新串命中+旧串 0） | grep 正负断言 + wc -l | SKILL.md / zcode-userpromptsubmit.sh |
| VC-4 | `scripts/selftest-drift-check-subagent.sh` ≥15 断言落地 + selftest-registry.tsv 登记行 + 全量回归 FAIL 集合 ⊆ Phase 1 基线集合（基线=863 PASS/21 FAIL 全预存，见 findings §4）+ 唯一允许暂态新增=AC-04（drift-checker 部署前实体存在性，Phase 5 部署后必须复跑转 PASS 并留证）+ 新 selftest 全 PASS（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报**） | for f in selftest-*.sh 逐个跑求和 + 部署后复跑 selftest-agent-coverage | progress.md Selftest Log |
| VC-5 | smart-merge-back --deploy 合并回 master，部署位 diff=0，`~/.zcode/agents/drift-checker.md` 在位；rule-reserve land 61；CR APPROVED；alignment-review 通过 | 部署对账输出 + 账本 | verification.md / 交付总结 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（Rule 15 追加 15.4 + 文末追加 Rule 61 + 索引括注扩展） | 改 Rule 15.1 触发时机/三态/处置链既有语义；动 Rule 59/60 相关行（并行任务在飞） |
| SKILL | `skills/task-planner/SKILL.md`（6 处载体+路由行+反模式+C4+References+索引括注；净增 ≤20 行，≤558 断言内） | 大段新增；动其他章节 |
| 新建 | `companion/agents/drift-checker.md`、`scripts/selftest-drift-check-subagent.sh` | 其他新文件 |
| 矩阵 | `references/agent-coverage.md`（追加 drift-checker 行）+ `scripts/selftest-agent-coverage.sh`（AC-09 上界 128→129 随行级联，label 注记 task-v146） | 动既有行；动 AC-09 以外断言 |
| 卫星 | `skills/task-drift-guard/SKILL.md`（纯增量「子代理消费模式」节 ≤10 行） | 改既有 SOP 语义 |
| hook | `scripts/zcode-userpromptsubmit.sh`（:220 载体文案 1 行） | 其他 hook 逻辑 |
| registry | `scripts/selftest-registry.tsv`（追加 1 行） | 动既有行 |
| 模板联动 | `templates/variant/`（9 个 variant 的 drift 行）+ `templates/task_plan.md`（:391 一行） | 动模板其他区块 |
| 文档联动 | `../plan-cost-guard/references/{billing,cost_log,cost-control}.md`（成本表载体行）、`README.md`（:21 功能行；:249 历史行保留）、`INSTALL.md`（:221-232 故障排查命令行；:146 部署表保留）、`docs/ARCHITECTURE.md`（:115 架构表行） | 其他文档段落 |
| 禁区 | — | config.json（零新键）；v143/v144/v145 worktree 及其计划文件；其他卫星技能正文（plan-resume/task-drift-guard README 比较表保留）；changelog 历史行；deploy 路径注释（install.sh:180/install-companion.sh:6） |

**强制约束**:
- ⚠️ **锚定级联**：`Rules 1-39` 头部串被 selftest-error-loop EL-11 / selftest-conclusion-discipline CD-18 / selftest-reflect-verify RV-10 宽容正则锚定——索引行只扩括注（`含 Rule 40-61 全集`），禁止改头部数字
- Rule 61 编号已 reserve-check free；attest 自动登记账本；合并后 land
- SKILL.md 索引行/合规清单 C4 措辞与 critical-rules 条款同 Phase 内一致（禁双源漂移）
- 派发契约：executor prompt 必含计划三文件绝对路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）；单会话单 S-unit（46.1）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | Bash 机械命令（白名单③）+ code-runner-agent | 基线回归=测试跑批归执行体；锚扫描输出可控（行清单）主进程直做 |
| Phase 2 | executor(sonnet-1) ×2 串行 | 条款+agent 定义为判断型写作，sonnet-1 档 |
| Phase 3 | executor(sonnet-1) ×2 串行 | SKILL 多点精确编辑，锚多易错，sonnet-1 |
| Phase 4 | executor(sonnet-1) + code-runner-agent | 守护脚本写作+回归跑批分离 |
| Phase 5 | 主进程（白名单①②） | git 编排+部署对账+簿记为主进程法定职责 |

workflow 编排判定：未命中（无 fan-out/长链复用，S-unit 串行依赖链）；/goal 对齐：不适用（用户侧命令）。

## 🔀 隔离决策（check-conflicts 2026-10-08 实测）
- 信号①未提交变更 8 文件：全部为 plans/ 并行任务文件，与本任务 skills/ 范围零重叠
- 信号②③：3 个在飞 worktree（task-v143/v144/v145，并行会话所有）——**禁止触碰**；Rule 59/60 已被其预留，本任务用 61
- **决策：worktree 隔离**（宪法 §十一 + 保护区命中）：`git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-v146 -b wt/task-v146 master`（基点 a7c01a8）
- 合并冲突预判：critical-rules.md 尾部追加行（v143/v144/v145 落 59/60 时）——并存解法先例=task-v129（50/51 并存）；合并时按行内容解冲突，禁覆盖他任务条款

## Phases

### Phase 1: 隔离、基线与精确锚扫描
- **状态:** complete（2026-10-08；证据=findings §4 基线分类 + subagent-state/1-code-runner-agent.md + KB §5.4 锚表；无仓内产物故无 commit 项）
- worktree 建立（命令见隔离决策）+ 全量 selftest 基线 + 断言锚精确清单落 findings
- **Executor:** 主进程（白名单① git 编排 + ③ 机械只读命令）+ code-runner-agent（基线回归）
- 验收：worktree 在位且 `git status` 干净；基线 Total 求和落 progress.md；锚清单（`grep -n 'task-drift-guard\|Skill("task-drift' scripts/*.sh` + check-complete/attest/check-plan-dispatch 中 C4/漂移断言行 + agent-coverage 断言面）落 findings.md

### Phase 2: Rule 61 条款 + drift-checker agent 定义 + 覆盖矩阵行
- **状态:** complete（2026-10-08；证据=S1/S2 checkpoint + 主进程独立复验 grep + diff --stat 四文件）
- **Executor:** executor（sonnet-1），串行（S2 引用 S1 编号语义）
<!-- 派发型 Phase 必附 S-unit 7 列表 -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S1 | critical-rules.md：Rule 15 块内 4 处载体措辞切换+追加 15.4（knowledge-brief §5.2）+ 文末追加 Rule 61（§5.1 全文）+ 索引括注扩展 40-61 | executor(sonnet-1) | worktree 内 references/critical-rules.md（Rule 15 在 :57 附近；尾部 Rule 60.8 后插入 61）+ knowledge-brief §5.1/§5.2 草案 | grep 61.1-61.6 六锚+15.4 锚命中；`Skill("task-drift-guard")` 全文 0 命中；头部 `Rules 1-39` 未动 | 15min | pending |
| S2 | 新建 companion/agents/drift-checker.md（全文草案=knowledge-brief §5）+ agent-coverage.md 追加登记行 | executor(sonnet-1) | knowledge-brief §5 agent 草案 + agent-coverage.md 既有行范式 | frontmatter 四字段在位（name/description/tools/model=haiku 档）；coverage 行含实体名与路由说明 | 12min | pending |

### Phase 3: 载体切换全链（SKILL + 卫星 + hook + 模板联动 + 文档联动）
- **状态:** complete（2026-10-08；证据=全 skills/ 树 `Skill("task-drift-guard")`=0 + commit dd71178 19 文件 + 各 S-unit checkpoint 4/5/6/9）
- **Executor:** executor（sonnet-1），串行（S3 依赖 Phase 2 编号语义落地；S4b/S4c 文件集与 S3/S4 不相交但沿用同一措辞表，保持串行免组声明复杂度）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S3 | SKILL.md 六处触发点载体切换+路由表行+反模式+C4+References+索引括注（逐处锚=Phase 1 锚清单） | executor(sonnet-1) | worktree 内 SKILL.md + findings.md 锚清单 + knowledge-brief §5 措辞表 | `Skill("task-drift-guard")` 全文 0 命中；六处新锚命中；wc -l ≤558 | 18min | pending |
| S4 | task-drift-guard/SKILL.md 增补「子代理消费模式」节 + zcode-userpromptsubmit.sh:220 载体文案切换 | executor(sonnet-1) | 卫星 SKILL.md（82 行）+ knowledge-brief §5.5/§5.6 草案 | 卫星增量 ≤10 行纯追加；hook 新串命中旧串 0；其余行零改动 | 8min | pending |
| S4b | 模板联动切换：9 个 variant 模板 drift 行 + templates/task_plan.md:391（措辞=KB §5.9） | executor(sonnet-1) | KB §5.9 逐文件锚清单 + grep 定位 | 全部目标行切换；`grep -rc 'Skill("task-drift-guard")' templates/` = 0；其余区块零改动 | 12min | pending |
| S4c | 文档联动切换：plan-cost-guard 3 refs + README:21 + INSTALL:221-232 + ARCHITECTURE:115（措辞=KB §5.9） | executor(sonnet-1) | KB §5.9 逐文件锚清单 | 目标行切换；history/deploy 注释行保留；`grep -rn 'Skill("task-drift-guard")' ../plan-cost-guard/` = 0 | 12min | pending |

### Phase 4: selftest 守护 + registry + 全量回归
- **状态:** in_progress（2026-10-08）
- **Executor:** executor（sonnet-1）+ code-runner-agent
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S5 | 新建 selftest-drift-check-subagent.sh（DCS-01..18 断言清单=knowledge-brief §5）+ registry.tsv 追加行 | executor(sonnet-1) | knowledge-brief §5 断言清单 + selftest-veto.sh 范式 | 新脚本自跑 PASS=18 FAIL=0；registry.sh 一致性通过 | 15min | pending |
| S6 | 全量回归（58 脚本逐个跑）+ 主进程逐 Total 行求和 | code-runner-agent | worktree scripts/ 全量 | 求和 FAIL 集合=基线 21 + AC-04 暂态；结果见检查点 8 | 10min | done |
| S7 | 守卫锚宽容化①：capability-persistence CP-05（字面 40-55→40-(5[3-9]\|6[0-9])）+ reliability-institution R-09 | executor(sonnet-1) | 回归检查点 8 的 6 条级联 FAIL 原文 + 各脚本锚行 | 两脚本自跑对应断言 PASS；其余断言不受影响 | 6min | pending |
| S8 | 守卫锚宽容化②：iteration-persistence IP-12 + root-resolution RR-16 | executor(sonnet-1) | 同上 | 同上 | 6min | pending |
| S9 | 守卫锚宽容化③：self-resolution SR-08 + execution-honesty EH-09 | executor(sonnet-1) | 同上 | 同上 | 6min | pending |

### Phase 5: 合并回 + 部署 + 审查 + 簿记 + 交付
- **Executor:** 主进程（白名单① git 编排 + ② 计划系统文件）
- CR Gate（code-review，重 diff 全量）→ alignment-review → smart-merge-back --deploy（3 实体位对账+agents 位验证）→ `rule-reserve.sh land 61 task-v146` → INDEX/ledger 簿记 → worktree 清理 → delivery-summary 落盘+呈报（含静默决策清单）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | Rule 15 现文/Rule 58 尾部范式 | references/critical-rules.md:57-72/:656 | ☑ |
| 项目内部 | 伴随 agent 范式（frontmatter/超时约束） | companion/agents/plan-writer.md | ☑ |
| 项目内部 | selftest 范式 | scripts/selftest-veto.sh | ☑ |
| 项目内部 | 锚级联判例 | selftest-error-loop.sh:59 / conclusion-discipline:86 / reflect-verify:60 | ☑ |
| 项目内部 | 台账供料（现状链路+锚清单+草案全文） | `<plan-dir>/knowledge-brief.md` §1-§5 | ☑ |

## Decisions Made
| # | 决策 | 理由/授权来源 |
|---|------|--------------|
| 1 | 载体语义改写（Skill→Agent 派发，6 处） | 授权=用户原始指令 R2 逐字（Rule 36.4 D6 确认来源=用户本条指令本身；非执行期失败补救，36.2 归因=功能增强诉求） |
| 2 | 专用 drift-checker 伴随 agent 而非复用通用 agent | Rule 52.1 专用体优先；haiku-1 高频经济性；先例=task-v124 媒体执行体；高频检查模型钉死防漂移 |
| 3 | task-drift-guard 卫星保留（双载体） | 零功能删除（36.5 纯增量）；保留交互/独立场景直用；三态语义一致性由 selftest 断言 |
| 4 | SOP 嵌入 agent 定义，不运行时 Read 卫星文件 | 消除部署路径耦合；一致性靠 DCS 断言而非运行时依赖 |
| 5 | 零新 config 键 | 53.5/54.6/55.6 同款惯例；selftest 静态守护承载 |
| 6 | 触发频率语义不变（15.1 原样），仅载体切换 | 忠实用户范围（R2 只要求换执行位置）；防自触发清零条款（61.4）补高频派发新风险 |
| 7 | `interaction_mode: silent` | v142/v144 同款先例；用户指令明确无语义分叉；静默决策清单随交付呈报复核 |
| 8 | 检查点沿用 22.8 命名（每检一盘小文件） | 与 check-dispatch 守卫/验收 Read 纪律完全兼容，一致性优先于微优化 |
| 9 | 载体切换全仓联动扩展（2026-10-08 S4b/S4c 纳入） | 全仓扫描发现 9 个 variant 模板+主模板+plan-cost-guard 3 refs+README/INSTALL/ARCHITECTURE 仍指示旧载体——不切换则新计划仍走旧通道，优化不生效；依据=变更联动审计 P0（改 A 必同步联动引用）+Rule 53 根源解决；同一载体语义的传播非新语义，silent 登记 |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  / 5 |
| 主进程直做 Phase 清单 | Phase 1（白名单①③）、Phase 5（白名单①②） |
| 委派率 | （终验填写；目标 ≥0.7） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 | 2026-10-08 | Explore | 偏移检查现状侦察 | done | 现状链路+10 落点候选+关键约束（子代理无 Skill() 工具） | SKILL.md:98/383, critical-rules:57-72 | §1 现状链路 | （主进程侦察，无检查点） |
| 2 | 2026-10-08 | code-runner-agent | Phase 1 全量基线 | done | 57 脚本 ΣPASS=863 ΣFAIL=21（15 脚本带 FAIL 全预存分类：13×config键数+5×periodic-review+2×registry+1×RC-15） | subagent-state/1-code-runner-agent.md | §4 | subagent-state/1-code-runner-agent.md |
| 3 | 2026-10-08 | executor | S1 条款 | done | Rule 15 四处+15.4+Rule 61 六条+5 处规则内互引全切换；`Skill("task-drift-guard")`=0（复验通过）；725 行；首轮漏检查点已补（登记 deviations） | diff 22+/9-，checkpoint 2-executor.md | §2 | subagent-state/2-executor.md |
| 4 | 2026-10-08 | executor | S2 agent+矩阵 | done | drift-checker.md 新建（frontmatter/三态/SOP 全锚）；矩阵行 128→129；AC-09 上界级联 ≤129 新跑 PASS；AC-04 部署前暂态 FAIL 已登记（Phase 5 转 PASS）；AC-07 预存 | checkpoint 3-executor.md | §2 | subagent-state/3-executor.md |
| 5 | 2026-10-08 | executor | S3 SKILL 载体 | done | 十二处切换；旧串 0；488 行 ≤558；主进程复验六锚全过 | SKILL.md diff 12+/10- | §3 | subagent-state/4-executor.md |
| 6 | 2026-10-08 | executor | S4 卫星+hook | done | 卫星 +3 行双载体节；hook 文案切换 bash -n 通过 | 卫星 82→85 行 | §3 | subagent-state/5-executor.md |
| 7 |  | executor | S5 selftest | queued |  |  | §4 | subagent-state/6-executor.md |
| 8 |  | code-runner-agent | S6 全量回归 | queued |  |  | §4 | subagent-state/7-code-runner-agent.md |
| 9 | 2026-10-08 | executor | S4b 模板联动 | done | 首会话停滞停止后改派续做；10 文件全部切换；templates/ 旧串 0、drift-checker 10 文件 | checkpoint 6-executor.md | §3 | subagent-state/6-executor.md |
| 10 | 2026-10-08 | executor | S4c 文档联动 | done | 6 文件 9 处切换；plan-cost-guard 旧串 0；history/deploy 行保全 | checkpoint 9-executor.md | §3 | subagent-state/9-executor.md |
| 11 | 2026-10-08 | executor | S5 selftest 守护 | done | 20 断言全 PASS；registry 行登记；registry.sh 无新增 FAIL | Total: 20 PASS=20 FAIL=0 | §4 | subagent-state/7-executor.md |
| 12 | 2026-10-08 | code-runner-agent | S6 全量回归 | done | 58 脚本 ΣPASS=876 ΣFAIL=28：基线 21+新脚本 20PASS+AC-04 暂态 1+**预期外 6 条锚级联**（40-55→40-61 断 6 守卫宽容锚 40-5[3-9]） | 检查点 8-code-runner-agent.md | §4 | subagent-state/8-code-runner-agent.md |
