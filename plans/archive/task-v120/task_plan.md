# Task Plan: task-v120 升级叙事联动 complex-planner（v119 D4 遗留落地）

<!-- plan_tier: standard -->
## Goal

把 complex-planner 以**纯增量**方式联入 task-planner 技能的升级叙事（2 处行内追加，行数不变）：SKILL.md 子代理路由表「规划/架构/编排」行超限动作列 + critical-rules.md Rule 22.3 失败兜底链；回归后定向部署 2 文件 × 3 部署位，v119 D4 遗留清账。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（纯 .md 行内追加 2 处，无代码文件） |
| `session_id` | `8e008b7fa380491996f76341cb771c8a` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v120` |
| `scope_files` | `skills/task-planner/SKILL.md`（:349 行内追加）、`skills/task-planner/references/critical-rules.md`（:149 行内追加） |
| `interaction_mode` | `ask` |
| `对齐审查` | 完成前对两处改动过 alignment-review 快检（42.6.2）；变更记录随交付总结落盘（42.6.3） |
| `自动超时默认项` | 唯一 2+ 选项询问点 = D1 计划批准（默认=本计划含 2 处逐项 diff，超时 5 分钟）；**计划批准 = Rule 36.4 语义改写逐项确认（2 项 diff 原文见「Decisions Made」D2/D3）** |
| `质量审查工具` | 用户级 alignment-review（登记沿用 v119 检测结论）；回归=selftest 机器面 |

## ✅ Verification Contract（目标完成判定标准）

> **验证独立性**：VC-4 回归由 code-runner-agent 承担（provider 故障时白名单③接管，先例 v119-P2）；其余以主进程第一手 grep/wc/diff/git 输出为准。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | SKILL.md「规划/架构/编排」行超限动作列同时含 `升级 ComplexProblemSolver`（保留）与 `complex-planner`（新增） | grep | `grep -n 'complex-planner' <wt>/skills/task-planner/SKILL.md` + Read :349 |
| VC-2 | critical-rules.md :149 原句 `回计划阶段重拆或升级 Complex Problem Solver` 保留且新增括注含 `complex-planner` | grep + Read | 同上文件 :149 |
| VC-3 | 两文件行数与基线一致：SKILL.md=444 行、critical-rules.md=483 行（行数定数断言零级联） | wc -l | `wc -l` 前后对照（基线取自 master a4bbd19，2026-10-03 实测） |
| VC-4 | 全量 selftest TOTAL=43 FAIL=0 + smoke 通过（基线随 v118 新增 selftest-dispatch-grain.sh 由 42 上移至 43，B 类修订 D7） | 循环跑 | worktree 内命令输出存 progress.md |
| VC-5 | 3 部署位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）对应 2 文件与 master diff=0；**部署前方向审计**：部署位现文件 ≡ master 基线（无未收编前向更新方可覆盖） | diff 逐位 | diff 输出存 progress.md |
| VC-6 | merge 落 master + worktree/分支清零 + v119 记忆 D4 状态更新为已落地 | git/memory | git log + memory 文件 diff |

**终验规则**：全部通过 → COMPLETE；有遗留 → PARTIAL 列明；3 次重试无效 → BLOCKED。

## ⚠️ 执行范围限制（强制）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 仓内源文件（worktree） | `skills/task-planner/SKILL.md`（仅 :349 行）、`skills/task-planner/references/critical-rules.md`（仅 :149 行） | 两文件其他行；templates/**；scripts/**；既有 agent/companion 文件 |
| 部署位（合并回后） | 3 位 `skills/task-planner/SKILL.md` 与 `references/critical-rules.md` 定向 cp | 3 位其他文件（**禁整目录 rm -rf**——EX-1 videop1 fork 保护：zcode 位 templates/variant=28 分叉待裁决，整目录重部署会摧毁未收编变体） |
| 簿记 | `plans/task-v120/**`、`plans/INDEX.md`、`plans/task-v119/`（补簿记入库）、memory 文件 | 其他 plans/** |

**执行前自我检查**: [x] 文件在列表 [x] 必要 [x] 用户授权（"2"=明确选择 D4 联动落地）

## 📚 必要知识储备（已确认）

| 类别 | 名称/定位 | 必读 | 已确认 |
|------|-----------|------|--------|
| 项目内部 | 3 处锚点原文（:339/:349/CR:149，本会话 sed -n 一手提取） | 必读 | ☑ |
| 项目内部 | v118 scope 声明（plans/task-v118/task_plan.md：CR 追加 Rule 46 + SKILL 净增 ≤10 行——同文件不同 hunk，git 可干净合并） | 必读 | ☑ |
| 项目内部 | EX-1 videop1 fork（memory task-planner-repo-deploy-flow [UPDATE 2026-10-02]：zcode 位 variant=28 vs 仓 17） | 必读 | ☑ |
| 项目内部 | v119 交付（complex-planner 已在位，master a4bbd19） | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 高复杂度规划类任务的升级出口在技能叙事中仍只指向 ComplexProblemSolver，新备用 complex-planner 不可见 → 两处升级叙事纯增量补入（CPS 保留，零删除）。能交付、方法清晰（先例=v119 全链路已通）。
- [x] 解决后能交付 [x] 不解决则 D4 悬置 [x] 方法清晰

## Current Phase

Phase 1（in_progress — D1 已批准 2026-10-03，D2/D3 逐项确认随批准生效，attest SHA 10c14692）

## Next Step

S1 已派发 code-assistant 执行 2 处行内追加（worktree 内），返回后 Read 复核+回填

## 🧰 工具选择与编排（Rule 40）

| Phase | 工具面 | 理由 |
|-------|--------|------|
| Phase 1 | Agent code-assistant(haiku-1) | 2 文件各 1 行行内追加，≤3 行 trivial 级机械改动 |
| Phase 2 | Agent code-runner-agent(mini)（失败→白名单③接管） | 机械回归；今日 mini provider 已 2 连拒（v119 实录），一次拒绝即接管不空耗 |
| Phase 3 | 机械脚本 + git 编排（主进程白名单①②③） | merge/定向部署/终验簿记 |

**workflow 编排判定**: 未命中（3 Phase 线性依赖链）→ Rule 21.4 串行
**/goal 对齐**: 未适用

## Phases

### Phase 1: 两处行内纯增量改（worktree 内）
- [ ] 建 worktree `/home/terry/task-planner-skill-worktrees/task-v120`（wt/task-v120 @ master a4bbd19）
- [ ] 按 knowledge-brief §6 逐字执行 2 处 Edit（D2/D3 diff 原文）
- [ ] 自验：grep 双锚 + wc -l 行数不变（444/483）
- [ ] 主进程 Read 复核 + findings 回填
- **V-N:** VC-1, VC-2, VC-3（全过：R7 一手复核）
- **Status:** complete（2026-10-03 05:35）
- **Executor:** code-assistant（haiku-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | 按 §6 diff 原文做 2 处行内追加并自验 | 继承（code-assistant, haiku-1） | `<plan-dir>/knowledge-brief.md` §6（2 组 before/after 逐字原文）+ §4 易错点 | 双锚 grep 命中；wc -l=444/483；8 字段返回含原始输出 | 5min | pending |

### Phase 2: 全量 selftest 回归
- [ ] worktree 内 42 脚本循环 + smoke；fail>0 → Rule 22.3 兜底链
- **V-N:** VC-4, VC-3（VC-4 过：TOTAL=43 FAIL=0 + smoke 17/0）
- **Status:** complete（2026-10-03 05:4x；执行体=主进程接管白名单③，计划预案内）
- **Executor:** code-runner-agent（mini）→ 实际主进程（接管登记：Rule 25.3 白名单③ 机械验证命令——计划预案"1 次拒绝即接管"；Handoff #2）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S2 | for 循环 42 selftest + smoke 汇总 | 继承（code-runner-agent, mini） | worktree 绝对路径 + 循环命令一行 | FAIL=0 + smoke 17/0 | 10min | pending |

### Phase 3: 合并回 + 定向部署 + 终验簿记
- [ ] worktree 提交干净 → smart-merge-back → 清理 worktree/分支
- [ ] 部署方向审计：3 位 2 文件 diff vs master 基线（有未收编前向更新 → STOP 收编，禁覆盖）
- [ ] 定向 cp 2 文件 × 3 位 + 逐位 diff=0 复验（zcode/claude 位 SKILL.md 逐字节同构，opencode 位同；无 model 行适配问题——纯技能文件）
- [ ] 终验：VC-1..6 + check-complete + 委派统计；簿记：INDEX 刷新、v119 memory D4 更新、v119/v120 plans 补簿记入库、delivery-summary
- **V-N:** VC-5, VC-6（双过：方向审计仅含本任务 2 行 + ALL 6 DIFF=0；merge 6961857 + 清零 + memory D4 更新）
- **Status:** complete（2026-10-03 05:5x）
- **Executor:** 主进程（例外理由:① git/worktree 编排 + ② 簿记 + ③ 机械 diff 验证——Rule 25.3 白名单）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`：信号① plans 簿记文件未跟踪（预期，本任务 P3 补入库）；信号② v118 worktree 在跑（fc6caff 未推进）——**v118 scope 含本任务两文件**（CR=尾部追加 Rule 46、SKILL=2.5 区净增 ≤10 行），本任务改动为 :349/:149 原行内追加，**hunk 距离远、行数不变**，git 可干净合并；风险登记：v118 合并时若撞 hunk 由其会话按冲突处置，本任务先落 master 不回退 |
| `isolation` | `worktree` |
| `worktree_path` | `/home/terry/task-planner-skill-worktrees/task-v120` |
| `branch` | `wt/task-v120` |
| `merge_back` | `merged(6961857)`（base 53936ec，V1-V6 全过，worktree+分支已清理） |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| P1 | 执行体改动越出 :349/:149 两行 | 7 | 2 | 2 | 28 | 验收 grep+wc 断言不过打回重写（档①）；再败白名单⑤接管 |
| P1 | 措辞破坏行内表格结构（SKILL :349 管道列数） | 5 | 2 | 2 | 20 | Edit 后 Read 该行验管道数=6；破坏即还原重做 |
| P2 | selftest 口径守卫命中（v117 RT-08/CD-12/PT-08 教训） | 6 | 2 | 3 | 36 | 本改动非 frontmatter/口径键，预评低危；若命中→按「口径扩展非回退」范式同步守卫锚并登记 |
| P3 | 部署位存在未收编前向更新被覆盖 | 8 | 2 | 3 | 48 | 部署前方向审计硬门（VC-5 前置）：diff ≢ 基线即 STOP 收编 |
| P3 | v118 之后合并撞 hunk | 5 | 2 | 4 | 40 | 行数不变+原行内追加最小化撞面；真撞由 v118 会话按其流程处置（登记于隔离决策） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 备注 |
|-------|-----------|------|
| Phase 1 | ☑ | S1 建 |
| Phase 2 | ☑ | S1 建 |
| Phase 3 | ☑ | S1 建 |

## Key Questions

1. 为什么 debug 行（:339）不加 complex-planner？→ 该 agent 规划不调试，加了误导路由；CPS 仍是调试升级正确出口（D3 登记）
2. 为什么用定向部署而非整目录重部署？→ EX-1：zcode 位 templates/variant=28 分叉待裁决，rm -rf 会摧毁未收编变体（memory 实录教训）
3. 与 v118 同文件冲突怎么办？→ 行数不变+原行内追加+hunk 距离远（149 vs 尾部追加；349 vs 2.5 区）；已登记隔离决策

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| D1 联动范围=2/3 处 | :349 规划行与 CR:149 兜底链为正确出口；:339 debug 行不改（complex-planner 不做调试）。用户授权源="2"（2026-10-03） |
| D2【Rule 36.4 逐项确认项 1/2】SKILL.md :349 末列 `升级 ComplexProblemSolver` → `升级 ComplexProblemSolver 或升级 complex-planner（高复杂度规划备用，GLM5.3/Opus 级）` | 纯增量子句，CPS 保留零删除；**计划批准即确认本项** |
| D3【Rule 36.4 逐项确认项 2/2】critical-rules.md :149 `…升级 Complex Problem Solver;换道…` → `…升级 Complex Problem Solver(高复杂度规划类亦可升级 complex-planner,GLM5.3/Opus 级备用);换道…` | 纯插入括注，原句逐字保留，半角标点随原文风格；**计划批准即确认本项** |
| D4 行数不变约束（VC-3） | 规避 SKILL 行数定数断言级联（memory: delivery-summary 教训）与 v118 合并撞面最小化 |
| D5 定向部署 2 文件×3 位 | EX-1 fork 保护 + §五 写入最小化 |
| D6 template_type: general（standard 档） | 保护区 scope 不满足 auto-mini ④排除条件；L0 精神落在本计划 3 Phase 精简结构与白名单接管预案 |
| D7【B 类修订 2026-10-03】基线前移：D1 批准与 worktree 建立间隙，master 由 a4bbd19 前进至 53936ec（v118 df7e427 + v121 三锚预扩合并） | 一手复测：两文件行数仍 444/483、锚点仍 :339/:349/:149 原文逐字未动 → VC-1/2/3 无需改；仅 selftest 脚本 42→43（v118 新增 dispatch-grain），VC-4 判据同步上移。S-unit 派发一律以内容 grep 定位锚点，不依赖行号 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （暂无） | | | |

## Notes

- 全程不触碰 wt/task-v118 工作区内容；master 合并后若 v118 后续合并撞 hunk 由其会话处置

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-03（D1 后开工前） | DRIFT 警觉→复测消解：master 前进至 53936ec（v118/v121 并行合并），一手复测锚点/行数零变化 → B 类修订 VC-4 基线 42→43（D7） | VC-3/VC-4 | ALIGNED（修订后继续） |
| 2026-10-03（P1/P2 后内联同口径检查） | ALIGNED（改动仅 2 行+检查点/三文件；提交 562c457 porcelain 干净） | VC-1/2/3/4 | 继续 |
| 2026-10-03（P3/交付点） | ALIGNED（部署=计划内定向 2×3 位，方向审计过；merge 6961857 仅含 2 文件改动） | VC-5/VC-6 | 交付 |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 1 / 3（机器口径：rate 0.333，verdict=ok，violations=0） |
| 主进程直做 Phase 清单 | Phase 2（白名单③ 机械验证命令，计划预案"1 次拒绝即接管"）；Phase 3（①②③ git 编排+簿记+机械 diff） |
| 委派率 | 0.333（< 0.7 但直做理由全命中 Rule 25.3 白名单 → **WHITELIST-EXEMPT 放行**；首轮 Executor 字段缺白名单关键词致 violation，补词后 ok） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-03 | code-assistant | 2 处行内追加+自验（haiku-1 档） | done | 两行与 D2/D3 逐字一致；行数 444/483；主进程一手复核（R7） | worktree SKILL:349 / CR:149 | findings R7 | plans/task-v120/subagent-state/1-code-assistant.md | - / 0 / ☑ |
| 2 | 2026-10-03 | code-runner-agent | 43 selftest 回归（mini 档） | done(接管) | 1 次 Provider rejected → 预案内主进程接管（白名单③）；TOTAL=43 FAIL=0 + smoke 17/0 | subagent-state/2-code-runner-agent.md | progress.md Phase 2 | plans/task-v120/subagent-state/2-code-runner-agent.md | rescue=接管档(白名单③,预案内) / retry=0 / ☑ |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 类型空缺（技能文本微改，29 variant 无对应）→ general 兜底
- Rule 34.3②: 沉淀预评——「升级叙事联动新 agent」若后续再现（第 2 个新 agent）可提炼 variant；首例不沉淀
- 终验必查: check-complete T3 warn 检索 [template-sense] token
- 处置登记处: 不沉淀理由=首例+行数不变微改无可泛化流程（D6 已登记）
