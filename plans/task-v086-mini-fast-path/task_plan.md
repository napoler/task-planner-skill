<!-- template_type: rule-enhancement -->
<!-- task-v086 难度分级轻量档（mini fast-path）：轻量任务模板 + 门控豁免 + 判定标准 -->
<!-- 用户指令（09-20 原话）:「使用当前 skill 执行任务时候就非常缓慢，是否因为无论任务复杂度都使用统一模板导致的，是否可以提供不同的级别模板根据难度来选择，确保不会让任务缓慢」 -->

## Goal
落地 Rule 38 难度分级与轻量档（mini tier）：轻量任务判定标准 + 精简模板（≥3 个档位模板，覆盖轻/中/重）+ 机器门控对 mini 档的显式豁免（FMEA/知识储备/委派统计/VC 条数降档）+ SKILL 联动 + selftest 守护，全量回归 0 FAIL 后合并回 master 并部署 3 实体位。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule 38 条款完整（38.1 判定标准/38.2 档位矩阵/38.3 轻量模板契约/38.4 门控豁免清单/38.5 机制，子条=动词短语，末条声明 config 键+selftest） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | config 三档键 `plan_tier_enforce` 落地（enforce/warn/off，默认 warn，挂 properties 内） | `jq .properties.plan_tier_enforce` | `config.json` |
| VC-3 | 模板分流生效：init-session 支持 mini 档精简模板 + 中/重档全量模板；模板 frontmatter 含 `plan_tier` 标记 | init-session 实跑 + grep 模板标记 | 实跑输出 |
| VC-4 | 门控豁免生效：mini 档计划跳过 FMEA 段/知识储备/委派统计/VC 条数降为 ≥2；非 mini 档不受影响 | attest/check-complete 三档行为实测（mini 计划 + 全量计划各一次） | 脚本输出 |
| VC-5 | selftest 守护落地 + 全量回归 0 FAIL（总数=主进程逐 Total 行求和，禁采信子代理自报总数） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-6 | SKILL 联动（索引行 Rules 1-38/合规清单 C26/摘要行，净增 ≤10 行行位替换优先）+ 3 实体位部署 diff=0 + knowledge-brief 行数断言同步上调 | grep 联动锚 + smart-merge-back --deploy | SKILL.md / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加 Rule 38 块） | 改既有规则语义 |
| 配置 | `config.json`（properties 追加 plan_tier_enforce） | 动既有键 |
| 模板 | `templates/task_plan.md`（加 tier 标记）+ 新建 `templates/variant/mini-lite-type.md` 等轻量模板（≤3 个） | 删既有 variant |
| 脚本 | `scripts/init-session.sh`（tier 分流）+ 消费侧脚本豁免段 + 新建 `selftest-plan-tier.sh` | 其他脚本 |
| SKILL | `SKILL.md`（净增 ≤10 行） | 大段新增 |
| 文档 | `references/template-mapping.md`（§一决策树加 tier 行 + §九 matrix 注记） | 其他文档 |

**强制约束**:
- 新规则编号接续当前最大 Rule（38）；合规清单接续最大 C 编号（C26）
- ⚠️ **锚定级联**：改 SKILL "Rules 1-37" 字样前先 `grep -rn "1-3[567]" scripts/` 扫全部锚断言一次修齐（宽容正则 1-3[5-7] 式扩围，优先 1-3[x-y] 形态）
- SKILL.md 行数纪律：当前 549；knowledge-brief T2b 断言 ≤549 须同步上调并 label 注 task-v086
- 派发契约：executor prompt 必含计划三文件路径 + 8 字段标签（check-dispatch.sh 逐字校验）
- mini 档判定标准必须机器可测（≤2 文件 且 预估 ≤15min 且 无跨模块，写入 check-plan-dispatch 或独立判定段）

## Phases

### Phase 1: 隔离与基线
- worktree 建立（宪法 §十一：/home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path，分支 wt/task-v086-mini-fast-path）+ 全量 selftest 基线（主进程逐 Total 行求和，当前预期 402/0）+ 各消费侧脚本豁免插入点锚确认（attest-plan FMEA 段 / check-complete VC-GATE / 委派统计段 / init-session 模板分流）
- 模板设计：轻量档 3 个模板（mini-lite-type：≤80 行 2 Phase ≥2 VC，跳 FMEA/知识储备/委派统计/Batch 区块；mid 档=现有 variant 按 tier=standard 全量；重档=现有 general 全量）写入 findings.md 设计节
- **V-N:** VC-1, VC-3
- **Status:** complete
- **Executor:** 主进程（白名单① git 编排 + ② 计划系统文件维护）+ code-runner-agent（mini）跑基线

### Phase 2: 条款 + config 键 + 模板分流
- S1 写入 Rule 38 条款全文 + config 键 + SKILL 联动（净增 ≤10 行）
- S2 新建 mini-lite-type.md 模板 + init-session.sh tier 分流 + 模板 frontmatter plan_tier 标记
- S3 消费侧豁免：attest-plan FMEA 段/VC-GATE 条数/委派统计/knowledge-brief 按 plan_tier=mini 显式豁免（各 1 处 if 分支，非 mini 路径零改动）
- **V-N:** VC-2, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行派发
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S1 | 写入 Rule 38 条款+config 键+SKILL 联动 | 继承 | plans/task-v086-mini-fast-path/findings.md（条款草案+插入点锚） | 条款落盘且锚级联扫描 0 漏网 | 12min | pending |
| S2 | mini-lite 模板+init-session 分流+tier 标记 | 继承 | plans/task-v086-mini-fast-path/findings.md（模板设计节） | init 实跑 3 档模板正确落盘 | 12min | pending |
| S3 | 四消费侧脚本 mini 豁免段 | 继承 | plans/task-v086-mini-fast-path/findings.md（豁免插入点表） | mini 计划 attest 通过且全量计划门控不变 | 12min | pending |

### Phase 3: selftest 守护 + 回归
- 新建 selftest-plan-tier.sh（mini 判定/模板落盘/豁免行为/非 mini 不变，≥8 断言）+ 既有 selftest 锚修复（行数断言 549 上调等）+ 全量回归主进程复跑定数
- **S6 用户指令扩围（09-21「一个项目下支持多个模板，每次只加载一个，不用过于复杂」）轻量落地**：
  - ① 项目多模板发现：`TASK_TEMPLATE_TYPE` 支持指向项目级目录模板——在 `.claude/plan-templates/`（或 `.zcode/plan-templates/`）放任意 `<name>-type.md`，init 时 `--list` 列出全部可用模板（内置 variant + 项目目录文件）供选择；每次任务仍只复制 1 个模板（单加载语义不变）
  - ② 项目默认模板：init 支持第 4 参/env `TASK_TEMPLATE_DEFAULT` 或项目 `.zcode/plan-templates/default` 指针文件 → 未显式指定 template_type 时按项目默认选 1 个，缺省回落 general；选择后写 frontmatter 可追溯
  - ③ 机制保持极简：不新建目录结构、不引入模板注册表/清单文件，发现=ls 项目目录（与内置 variant 动态派生同范式）；init 输出增加一行「可用模板 N 个：<列表>」
- **V-N:** VC-4, VC-5
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** executor（sonnet-1）
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| S4 | 新建 selftest-plan-tier.sh（≥8 断言） | 继承 | plans/task-v086-mini-fast-path/findings.md（P2 豁免段清单） | selftest 单跑 8+/0 | 12min | pending |
| S5 | 既有 selftest 锚修复（行数断言等） | 继承 | 全量回归红清单（progress.md） | 全量 selftest 主进程求和 0 FAIL | 10min | pending |

### Phase 4: 合并回 + 部署 + 簿记
- **Status:** complete
- 全量回归 0 FAIL → **CR Gate（Code Reviewer 二轮范式）**：首轮 CHANGES_REQUESTED——**发现 1（BLOCKER）=init-session frontmatter 插入形态 `<!-- template_type: X -->` 注释 check-template-type 提取链不识别（只认行首直书 `^template_type:` 与表格行），mini 主路径在 template_gate enforce 档拒锁**；发现 2=38.4② 条款「2→1」与实现等效阈值 0 矛盾；发现 3=38.2 中/重禁用 mini 无机器锚；发现 4=selftest 样例手造双形态 plan_tier 标记偏离真实产物 → S7 修复单元（check-template-type 提取链补第三形态注释 form（gate 侧修复）+ 条款 2 处措辞对齐 + selftest 样例改真实 mini-lite cp 基座+PT-28）后复跑定数
- worktree 内提交 commit → 主仓 smart-merge-back（--no-ff）→ 部署 3 实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner，diff -r 复验 IDENTICAL）→ **push origin master（用户指令 09-20「提交 github」）** + INDEX/ledger 簿记 + worktree 清理 + 记忆沉淀
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（白名单①②）

## 🔀 隔离决策
| 字段 | 值 |
|------|-----|
| `conflict_scan` | 信号①仅本任务 plans/ 目录自身文件（task-v086 新建+active_plan 指针），无任务范围重叠；无额外 worktree/遗留 wt 分支 |
| `isolation` | `worktree`（技能实现类任务，宪法 §十一 必命中——修改 skills/task-planner/** 运行中基础设施） |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v086-mini-fast-path` |
| `branch` | `wt/task-v086-mini-fast-path` |
| `merge_back` | `merged(4a925bb)` |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读级别 | 已确认 |
|------|------|------|---------|--------|
| 项目内部 | 最近两轮规则块范式 | skills/task-planner/references/critical-rules.md 末尾 Rule 36/37 | 必读 | ☑ |
| 项目内部 | selftest 写法范式 | skills/task-planner/scripts/selftest-mechanism-profile.sh | 必读 | ☑ |
| 项目内部 | 三档键范式 | skills/task-planner/config.json（skill_modify_enforce 段） | 必读 | ☑ |
| 项目内部 | 豁免段写法范式 | scripts/attest-plan.sh FMEA 段（enforce/warn/off 三档解析） | 必读 | ☑ |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（对齐 22.3 ①-⑤） |
|-------|---------|---|---|---|-----|------------------------------|
| Phase 1 | provider 档位灭（sonnet/haiku 不可用） | 5 | 4 | 3 | 60 | ④ 主进程接管逐文件 Edit（单文件 ≤300 行） |
| Phase 2 | 锚级联漏网（1-3[5-7] 宽容锚未扩围） | 6 | 4 | 3 | 72 | ② 拆细：全量 selftest 红后 grep 定位单锚修复重跑 |
| Phase 3 | 豁免误伤全量路径 | 7 | 3 | 3 | 63 | ① 改派 debugger 定位 + 突变自测（删 mini 分支复现 FAIL） |
| Phase 4 | 部署竞态（并行会话推 master） | 4 | 3 | 3 | 36 | 先 merge-base --is-ancestor 探活，留 ±1 窗口 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 4（P2/P3；P1 基线 code-runner 亦计子代理） |
| 主进程直做 Phase 清单 | P4（白名单① git 编排+② 簿记） |
| 委派率 | 0.5 → 全部命中白名单①② → WHITELIST-EXEMPT（先例：v082-v085 同构簿记轮） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 | | code-runner-agent | 全量 selftest 基线（主进程求和定数） | queued | | | Selftest Baseline | plans/task-v086-mini-fast-path/subagent-state/1-code-runner-agent.md | | 0 | ☐ |
| 2 | | executor | P2 S1 条款+config+SKILL 联动 | queued | | | P2 条款节 | plans/task-v086-mini-fast-path/subagent-state/2-executor.md | | 0 | ☐ |
| 3 | | executor | P2 S2 mini 模板+init 分流 | queued | | | P2 模板节 | plans/task-v086-mini-fast-path/subagent-state/3-executor.md | | 0 | ☐ |
| 4 | | executor | P2 S3 四脚本豁免段 | queued | | | P2 豁免节 | plans/task-v086-mini-fast-path/subagent-state/4-executor.md | | 0 | ☐ |
| 5 | | executor | P3 selftest+回归 | queued | | | P3 回归节 | plans/task-v086-mini-fast-path/subagent-state/5-executor.md | | 0 | ☐ |

## Key Questions
1. mini 档判定机器可测的最简表达式（≤2 文件 ∧ ≤15min ∧ 单模块）落在哪处脚本最稳？（check-plan-dispatch vs init-session 双点）
2. 中档是否真的需要新模板，还是现有 13 variant 即中档（重档=general 全量）——避免模板数量膨胀。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 方案 B（模板+门控双轨）而非纯模板 | 用户痛点=全流程慢，每 Phase 仪式（6 步闭环/3file 回填/委派统计）是更大慢源；仅模板降档不减仪式，收益有限 |
| 中档复用现有 13 variant 不新造 | 现有模板即中档；只新增 mini-lite 1 个 + tier 标记，模板面不膨胀（Key Q2 倾向） |
| 门控豁免走 plan_tier frontmatter 标记而非全删 | 可追溯、非 mini 零影响、enforce/warn/off 三档范式与既有键一致（Rule 36.5 纯增量） |
| 委派率 0.5 走 WHITELIST-EXEMPT | 全部主进程直做理由命中白名单①②，先例 v082-v085 同构 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |
