<!-- template_type: rule-enhancement -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程 -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发；v071-v073 同套路轮次佐证） -->

# Task Plan: 设计简报=台账供料机制实施（提案落点 1-4 + 21.2.1 子条款）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->

- **R1**: 「$task-planner 以下是一次执行task =planner 任务你时候的消耗分析 太多消耗冗余 : 另外说清楚一件容易被忽略的事：这轮跑掉的 1478 万 token 里，绝大部分花在盘点代理读仓（每个 20 万到 66 万 token）和门禁补强设计代理（341 万单个）上。如果这条链路要反复迭代，下一个真正省钱的地方是把设计代理的输入收窄——现在它每次都要重读大批规范文件，而这个信息在盘点台账里已经有了。」
- **R2**: 「继续」（2026-10-05，对呈示的「落点 1-4 + critical-rules 21.2.1 子条款」实施范围的授权指令）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-3, VC-4 | 四落点供料机制在位：brief 模板供料行型 + dispatch 注入纪律行 + 21.2.1 条款 + variant 必读表行（grep 锚各 ≥1，绝对路径可查） |
| R2 | VC-5, VC-6 | 回归全绿（51 脚本 0 FAIL 主进程逐 Total 求和）+ 合并部署 IDENTICAL + 簿记完成 |

<!-- plan_tier: standard -->

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 设计/审计代理派发供料 | 基线定数靠 prompt 内联重建（v116 A2 变体）与执行期重复读原文，锚漂移即成谣言源 | brief §2/§3/§5 台账供料行型（落点 1）+ dispatch 注入纪律行（落点 2） | VC-1, VC-2 |
| 派发契约条款承载 | 「台账供料优先」无条款级强制，靠约定俗成 | critical-rules 21.2.1 子条款（落点 3，纯增量） | VC-3 |
| 计划期感知 | 规则增强型计划初始化时不知道要用台账供料 | rule-enhancement-type 必读表行（落点 4） | VC-4 |
| 回归与部署 | 改动破坏既有守卫或部署位漂移 | Phase 回归 + IDENTICAL 对账 | VC-5, VC-6 |

## Goal
[一句话: 落地「设计简报=台账供料」机制（knowledge-brief 模板供料行型 + subagent_dispatch 注入纪律行 + critical-rules 21.2.1 子条款 + rule-enhancement-type 必读表行，零新 Rule/零新键/零新文件），全量 selftest 0 FAIL 后合并回 master 并部署实体位]

## 🔀 隔离决策（check-conflicts.sh 2026-10-05 实测）
- 信号①未提交变更 22 个：均为 plans/ 簿记（.rule-reservations/INDEX/task-v122 等）与 .zcode/plans，与本任务范围（skills/task-planner/** + 部署位）零重叠
- 信号②③额外 worktree 与 wt 分支：wt/task-v134（@4e734b2，技能修复普及化）、wt/task-v135（@15a3ecf，智能拆分分析）在途——两者改 critical-rules.md/SKILL.md，与本任务 hunk 位置不重叠（本任务 CR 改动=21.2@:145 后插 ≤3 行；它们计划未提及 brief/dispatch/variant 模板），合并期按 hunk 解冲突
- **决策：worktree 隔离**（路径 /home/terry/task-planner-skill-worktrees/task-v137，分支 wt/task-v137，基于 master@4e734b2）；CWD 不迁移，计划文档留主仓 plans/task-v137/
- 部署位现状：zcode 位落后源仓 1-3 行（v133 部署滞后，方向安全=非领先）；本任务 Phase 4 部署一并吸收

## 📊 FMEA 预演（高风险项）
| 风险 | RPN | 兜底 |
|------|-----|------|
| 锚漂移致 selftest 碎（v131/v132/v133 已使 21.2 :144→:145、dispatch 73→76 行） | 高 | 实施前逐锚重验（本计划锚点均为 2026-10-05 实测）；执行体回执行号与实测不符即回炉 |
| 合并冲突（v134/v135 同期合入 critical-rules） | 高 | 本任务 CR 改动为 21.2 后孤立 ≤3 行插入，hunk 距离远；冲突时 hunk 级手工合流+全量回归 |
| T1b 五段锚被破 | 高 | 落点 1 只改填写说明与表行，禁新增 `## §` 段；Phase 回归 T1b 实跑 |
| SKILL.md 478 压钉 | 中 | 本任务 SKILL.md 零改动承诺（VC-5 复核 wc -l=478） |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `not-required`（纯 .md 增行，无 .sh/.ts 代码文件） |
| `对齐审查` | `required` | Rule 42.6 消费：完成前跑 alignment-review；变更记录随交付落盘 |
| `自动超时默认项` | 询问点无（本计划无 2+ 选项询问点，44.2 低区分度均直接裁决登记 Decisions Made）；兜底超时 5 分钟 |
| `质量审查工具` | alignment-review（review-library 池，42.2 四级检测：项目级/用户级未建专用，环境既有 review-library 命中） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | knowledge-brief.md 模板 §2/§3/§5 各含「台账供料行型」填写说明/示例 ≥1 处；五段锚 `^## §` 仍 =5；模板 ≤150 行 | grep 供料行型锚 + grep -c '^## §' + wc -l | `skills/task-planner/templates/knowledge-brief.md` |
| VC-2 | subagent_dispatch.md 📚 表含注入纪律行（台账路径锚供料+禁内联基线）；§2 三文件必传块与 §7 八字段块零改动 | grep 纪律行 + sed 抽查 :22-27/:47+ 区块 | `skills/task-planner/templates/subagent_dispatch.md` |
| VC-3 | critical-rules.md 21.2.1「台账供料优先」子条款在位（21.2 之后 ≤3 行、引用化）；T6 窗口断言 PASS（22.4 行号仍 100<line<200） | grep '^21.2.1' + selftest-knowledge-brief.sh T6 实跑 | `references/critical-rules.md` + selftest 输出 |
| VC-4 | rule-enhancement-type.md 📚 必读表含台账供料简报行 | grep 台账供料 | `templates/variant/rule-enhancement-type.md` |
| VC-5 | 全量 selftest 0 FAIL（总数=主进程逐脚本 Total 行求和，基线 51 脚本）+ SKILL.md 行数保持 478（零改动承诺兑现） | for f in selftest-*.sh 逐个跑求和 + wc -l SKILL.md | progress.md Selftest Log |
| VC-6 | 合并后实体位部署 IDENTICAL（diff=0）+ INDEX/ledger 簿记完成 + worktree 清理 | smart-merge-back --deploy 输出 + git worktree list | 部署输出 + INDEX.md |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 模板 | `templates/knowledge-brief.md`、`templates/subagent_dispatch.md`（📚 表）、`templates/variant/rule-enhancement-type.md`（📚 表） | 新增 `## §` 段；动 dispatch §2/:19-27 与 §7 八字段块；动其他模板 |
| 条款 | `references/critical-rules.md`（21.2 后插 21.2.1，≤3 行纯增量） | 改既有规则语义；新增 Rule 编号 |
| SKILL | **零改动** | 任何 SKILL.md 变更（478 压钉） |
| config | **零改动** | 零新键承诺 |
| 文档 | plans/task-v137/** 计划系统文件 | 其他 plans/ 文件 |

**强制约束**:
- 全部改动纯增量（Rule 36.5）：无删除、无既有行语义改写；36.3 删除基线=空清单（无删除性行为）
- Rule 20.6：无 new_rule 声明，编号账本零写入（land 阶段跳过）
- 派发契约：executor prompt 必含计划三文件路径 + 8 字段标签（check-dispatch.sh 逐字校验）；单会话单 S-unit（46.1）
- Rule 51.5 生成前盘点：执行体动手前 Read 目标文件现状并对照本计划锚点，不符即 STOP 回报

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | 机械 git 编排（主进程白名单①） | worktree/分支创建属纯 git 操作 |
| Phase 2 | Agent 子代理 executor(sonnet-1) ×4 串行 | 保护区 .md 编辑，路由表「业务文档/技能文件」行；四落点不同文件可串行小步，46.1 单会话单单元 |
| Phase 3 | Agent 子代理 code-runner-agent | 机械验证命令，路由表「跑测试/构建」行 |
| Phase 4 | 机械 git/部署编排（主进程白名单①②） | smart-merge-back/部署/簿记属计划系统与 git 运维 |
| workflow 编排判定 | 不命中（无 fan-out/长链复用，四落点串行小步） | 未点名 /workflow，Rule 39.1 不路由 |

## Phases

### Phase 1: worktree 建立与锚点基线 ✅ complete（2026-10-05）
- git worktree add /home/terry/task-planner-skill-worktrees/task-v137 -b wt/task-v137 master；基线 selftest 求和（主进程逐 Total 行）；四落点锚点终验（对照本计划 2026-10-05 实测值）
- **Executor:** 主进程（白名单① git 编排）
- **证据:** worktree 在位（wt/task-v137@4e734b2）；锚点全对齐（21.2@:145、`^## §`=5、SKILL=478）；基线 51 脚本 PASS=760 FAIL=0（findings.md Research Findings 段）

### Phase 2: 四落点实施（隔离区内）✅ complete（2026-10-05，4 文件 +11/-0，详见 progress.md Phase 2 段与 Handoff 表 2-5 行）
<!-- S-unit 表：attest 机器校验执行体列；46.1 单会话单单元串行派发 -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | knowledge-brief.md §2/§3/§5 加台账供料行型填写说明与示例（+10~15 行） | executor(sonnet-1) | worktree 内 templates/knowledge-brief.md（61 行五段锚 §2@:33/§3@:41/§5@:56）+ 提案 §2.2 三条格式约定 | grep 供料行型 ≥3 处；`^## §` 计数=5；wc -l ≤150 | 15min | complete |
| S2 | subagent_dispatch.md 📚 表加注入纪律行（台账路径锚+禁内联） | executor(sonnet-1) | worktree 内 templates/subagent_dispatch.md（76 行，📚 表:32-36）+ 提案落点 2 | grep 纪律行 ≥1；§2/§7 块行内容不变 | 10min | pending |
| S3 | critical-rules.md 21.2@:145 后插 21.2.1 子条款（≤3 行） | executor(sonnet-1) | worktree 内 references/critical-rules.md（590 行）+ 提案 §2.3 权威条款承载段 | grep '^21\.2\.1' =1；21.2 与 22.4 之间行距 ≤4 行增 | 10min | pending |
| S4 | rule-enhancement-type.md :93 必读表加台账供料简报行 | executor(sonnet-1) | worktree 内 templates/variant/rule-enhancement-type.md（122 行）+ 提案落点 4 | grep 台账供料 ≥1；必读表竖线列结构完整 | 8min | complete |

### Phase 3: 回归验证（隔离区内）✅ complete（2026-10-05，51 脚本 FAIL=0、SKILL=478，详见 progress.md Phase 3 段）
- selftest-knowledge-brief.sh 全组 + selftest-skill-split.sh + check-dispatch.sh 冒烟 + 全量 selftest 逐脚本求和（对照 Phase 1 基线）+ SKILL.md wc -l=478 复核
- **Executor:** code-runner-agent（mini）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S5 | worktree 内全量 selftest 回归 + SKILL.md 行数复核 | code-runner-agent | worktree 根（scripts/selftest-*.sh 51 个）+ Phase 1 基线求和值 | 逐脚本 Total 行求和 0 FAIL；wc -l SKILL.md=478 | 15min | complete |

### Phase 4: 合并部署与簿记 ✅ complete（2026-10-05，合并 4bca3dd+b11f3fd、四位 IDENTICAL、51 脚本 FAIL=0，详见 progress.md Phase 4 段）
- worktree 内 Phase 产物 commit（Rule 27 逐 Phase）→ smart-merge-back.sh --deploy → 4 实体位 IDENTICAL 对账 → INDEX/ledger 簿记 → worktree 清理 → alignment-review 收尾
- **Executor:** 主进程（白名单①② git 与计划系统编排）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 任务提案 | 设计代理输入收窄方案（机制/守卫/落点唯一权威源） | plans/cost-analysis-2026-10-05/design-input-narrowing-proposal.md | ☑ |
| 项目内部 | 21.2 条款与五段 brief 范式 | references/critical-rules.md:145 + templates/knowledge-brief.md | ☑ |
| 项目内部 | 派发模板 📚 表与 §2/§7 硬契约 | templates/subagent_dispatch.md:22-76 | ☑ |
| 项目内部 | 守卫锚清单（T1b/T1c/T2/T6/T7、SKILL ≤478 钉） | scripts/selftest-knowledge-brief.sh:33-61、scripts/selftest-skill-split.sh:41 | ☑ |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## Decisions Made
| 时间 | 决策 | 依据 |
|------|------|------|
| 2026-10-05 | 用户会话内「继续」= 对呈示落点范围（落点 1-4 + 21.2.1）的实际授权，D1 计划确认门控以该指令满足 | 授权发生在落点清单呈示之后（同会话 2026-10-05） |
| 2026-10-05 | 走 21.2.1 子条款，不新增 Rule | Rule 53 已被 task-v131 占用（账本 landed，critical-rules:581）；提案 §三 时效补记 |
| 2026-10-05 | 计划撰写由主进程直做（白名单②） | plan-writer 派发两度被 check-dispatch KQ3 误拦（任务书含计划结构描述被计为多单元打包/步骤超限），22.3④ 接管；已登记 progress.md Error Log |
| 2026-10-05 | Phase 4 部署吸收 v133 部署滞后，部署后跑 IDENTICAL 对账 | 部署位落后源仓 1-3 行，方向安全；先例=各任务部署即对账 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4（Phase 2 executor×4 单元、Phase 3 code-runner→general-purpose；plan-writer 派发 blocked×2 不计完成） |
| 主进程直做 Phase 清单 | Phase 1（白名单① git 编排）、Phase 4（白名单①② git 与计划系统编排）、计划撰写（白名单②，KQ3 误拦后 22.3④ 接管） |
| 委派率 | 0.5（2/4 Phase；主进程直做理由全部命中 Rule 25.3 白名单①②与 22.3④ 接管 → WHITELIST-EXEMPT） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 | 2026-10-05 | plan-writer | 填写 task-v137 计划 | blocked×2 | 派发守卫 KQ3 误拦（任务书计 4 单元/10 步） | dispatch-guard 输出 | Error Log | subagent-state/1-plan-writer-prompt.md |
| 2 | 2026-10-05 | executor | S1 brief 模板供料行型 | done✓ | +7/-0 纯增量；五段锚=5；68≤150；主进程 Read 复核通过 | worktree git diff / knowledge-brief.md:33-62 | Research Findings[S1] | subagent-state/2-executor-s1.md |
| 3 | 2026-10-05 | executor | S2 dispatch 注入纪律行 | done✓ | +2/-0；📚表 :34/:38；§2/§7 零变化；复核通过 | worktree git diff / subagent_dispatch.md:34-38 | Research Findings[S2] | subagent-state/3-executor-s2.md |
| 4 | 2026-10-05 | executor | S3 critical-rules 21.2.1 子条款 | done✓ | +1/-0 @:146；T6 报告真实 22.4@:168 PASS；「22.4」字面误配已微调修复 | worktree git diff / critical-rules.md:146 | Research Findings[S3] | subagent-state/4-executor-s3.md |
| 5 | 2026-10-05 | executor | S4 variant 必读表行 | done✓ | +1/-0 @:100；4 列对齐；主进程 Read 复核通过 | worktree git diff / rule-enhancement-type.md:100 | Research Findings[S4] | subagent-state/5-executor-s4.md |
| 6 | 2026-10-05 | code-runner-agent→general-purpose | 全量 selftest 回归 + SKILL 行数复核 | done✓ | 首派 provider 拒改派；51 脚本 FAIL=0，排除口径差异后=基线 760；SKILL=478 | subagent-state/6-code-runner-regression.md 明细 | progress Phase 3 | subagent-state/6-code-runner-regression.md |
| 7 | 2026-10-05 | general-purpose(alignment-review 执行体) | 四落点对齐审查 | done✓ | CHANGES_REQUESTED：P0 :146 错挂+P2 B8 泄漏+P2 T6 脆弱（既存）；无漂移无越界守卫全绿 | subagent-state/7-alignment-review.md | progress Phase 4 | subagent-state/7-alignment-review.md |
| 8 | 2026-10-05 | executor | 审查修复波（P0+P2-1） | done✓ | 3 处行内改词零净增减；T6 报真实 22.4(168)；grep 三项 0 | subagent-state/8-executor-fix.md | progress Phase 4 | subagent-state/8-executor-fix.md |
