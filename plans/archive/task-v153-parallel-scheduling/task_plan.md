---
template_type: rule-enhancement
new_rule: 68
interaction_mode: ask
plan_tier: standard
code_review: required
isolation: worktree
parallel_groups: [p3-core, p3-guard, p3-docs]
session_id: de2c5bba-20261009-v153
---

# Task Plan: Rule 68 — 计划期依赖分析、并行分组、组内异构分摊与状态一致性

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「优化当前项目技能的执行并行的效率……在计划初期就分析出哪些任务可以并行」<sub>（[目标]）</sub>
- **R2**: 「相互不影响的时候就可以并行执行；存在相互依赖关系就需要逐个串行……一个个击破」<sub>（[目标]）</sub>
- **R3**: 「最终我希望以后运行任务的时候,都可以针对可以并行的任务进行并行加速」<sub>（[目标]）</sub>
- **R4**: 「workflow 会将所有的任务都丢给一个模型执行……模型消耗资源会不可控」<sub>（[目标]）</sub>
- **R5**: 「学习它的并行策略,但是需要保证使用不同的 Agent,以及模型进行运作」<sub>（[目标]）</sub>
- **R6**: 「因为当前我发现执行工作非常缓慢,我希望可以优化并行运行」<sub>（[目标]）</sub>
- **R7**: 「在规划初期就可以将整个大段任务拆成几个可以并行的小任务……简单来说就是分组，任务分组，分组之后，每个任务更新的时候都可以在组内进行修正，以及比如更新状态之类的，确保可以后期整个运行并行的时候不会出现错乱问题」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | critical-rules.md 含 68.1 强制依赖分析条款 + S-unit 表「前置依赖」列在位 |
| R2 | VC-1, VC-7 | 68.2 并行分组推导条款 + 本计划 parallel_groups 声明与组内异构分配 |
| R3 | VC-4, VC-5 | selftest-parallel-scheduling.sh 断言通过 + 全量回归 FAIL=0（机制固化进技能长期生效） |
| R4 | VC-1, VC-6 | 68.3 组内异构分摊条款 + SKILL.md 计数级联含 Rule 68 索引行 |
| R5 | VC-1, VC-7 | 68.3 条款（agent 类型或模型档位至少一项不同）+ 本计划组内 haiku-1/sonnet-1 混派 |
| R6 | VC-3, VC-4 | check-plan-dispatch.sh 守卫扩展 + 新 selftest 断言通过（并行效率机制可验证） |
| R7 | VC-1, VC-7 | 68.4 组域写隔离与状态一致性条款 + 本计划组域协议行（吃狗粮证据） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 计划期依赖分析 | 无强制步骤，分组靠 LLM 自觉（B1） | S1: 68.1 条款 + S-unit 表加「前置依赖」列 | VC-1, VC-2 |
| 并行分组推导 | 声明制无机器校验，依赖-同组矛盾无拦截（B1/B4） | S1: 68.2 条款 + S4: check-plan-dispatch hard 档校验 | VC-1, VC-3 |
| 组内异构分摊 | 组内全同模型无约束（B3） | S1: 68.3 条款 + S4: advisory 档 WARN + 本计划组内混派 | VC-1, VC-7 |
| 并行更新状态一致性 | 组内并行成员直接 Edit task_plan.md 无组域协议（B3） | S1: 68.4 条款 + 本计划组域写隔离协议行 | VC-1, VC-7 |
| 守卫校验 | check-plan-dispatch 不校验组结构与异构（B4） | S4: 守卫扩展 hard+advisory 档 | VC-3 |
| 机制固化 | 无 selftest 断言新机制（B5） | S5: selftest-parallel-scheduling.sh + registry 登记 | VC-4, VC-5 |

<!-- plan_tier: standard -->
## Goal

给 task-planner 技能新增 Rule 68：计划期强制依赖分析→推导并行分组→组内异构 agent/模型分摊→组内状态更新防错乱，纠正现状「声明制靠自觉、组内全同模型、并行更新无组域协议」三缺口。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（实现类多文件变更：规则条款/模板/守卫/selftest，重 diff 全量多轮 CR） |
| `session_id` | `de2c5bba-20261009-v153` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling` |
| `scope_files` | 见「执行范围限制」区块 |
| `interaction_mode` | `ask`（D1 批准前按 28.2.1 口头复述执行思路） |
| `对齐审查` | `required`（42.6.2：Phase 4 跑 alignment-review） |
| `自动超时默认项` | `D1=批准计划+worktree / 5min`（44.3 五要素登记） |
| `new_rule` | `68`（Rule 20.6：attest 自动预留+查重；66=v151 在途、67=v152 在途，68 已 reserved） |
| `质量审查工具` | `Code Reviewer（sonnet-1）/ alignment-review skill`（42.4 登记） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | critical-rules.md 含 Rule 68 完整条款（68.1-68.7） | `grep -cE '^68\.[1-7] ' critical-rules.md` =7 且含「依赖分析/并行分组/异构分摊/组域写隔离」 | worktree critical-rules.md |
| VC-2 | templates/task_plan.md S-unit 表含「前置依赖」列 | `grep -c '前置依赖' templates/task_plan.md` ≥1 且表头含该列名 | worktree templates/task_plan.md |
| VC-3 | check-plan-dispatch.sh 扩展校验存在且对「依赖-同组矛盾」reject、「组内全同」WARN | 构造矛盾用例跑守卫 exit≠0；构造全同用例输出 WARN；测试证据存 progress.md | worktree check-plan-dispatch.sh |
| VC-4 | selftest-parallel-scheduling.sh 存在、registry 登记、断言通过 | `bash selftest-parallel-scheduling.sh` exit 0；`tail -1 registry.tsv` 含新行 | worktree scripts/ |
| VC-5 | 全量 selftest FAIL=0（相对基线零新增失败） | 跑全量 selftest 脚本集，统计 FAIL 数=0 | worktree scripts/ |
| VC-6 | SKILL.md 计数级联正确（Critical Rules 上界=合并后实际最大编号），含 Rule 68 索引行与合规清单行 | `grep -c 'Critical Rules 1-' SKILL.md` 上界=合并后最大值；`grep '68' SKILL.md` ≥1；合规清单 C 行存在 | worktree SKILL.md |
| VC-7 | 本计划自身含 parallel_groups 声明 + 组内异构执行体分配 + 组域写隔离协议行 | `grep 'parallel_groups' task_plan.md` ≥1；S-unit 表组内执行体列 haiku-1/sonnet-1 混；68.4 组域协议行存在 | plans/task-v153-parallel-scheduling/task_plan.md |
| VC-8 | 三部署位 IDENTICAL（合并后对账） | 合并后 `diff` 三部署位（技能目录/仓根/备份）关键文件一致 | 部署位对账记录 |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求的任务终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3/R4/R5/R6/R7（全部 [目标]） |
| **裁决** | `pending`（终验时填写） |
| **解决证据锚** | （终验时填写） |
| **未解决面+原因** | （终验时填写） |
| **已排除路径** | （终验时填写） |
| **下一步建议** | （终验时填写） |

## 🎯 Goal 单元表（Rule 66.1 — attest 后分解固化；六列契约）

| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|------|-------------|------------------|------|
| G1 | 条款落地 | critical-rules.md 文末追加 Rule 68 六子条全文 | `grep -cE '^68\.[1-7] ' <worktree>/references/critical-rules.md` 输出 7 且含「依赖分析/并行分组/异构分摊/组域写隔离」 | S1 / Phase 3 | complete |
| G2 | 流程级联 | SKILL.md 计划流程加强制步骤行+Critical Rules 上界级联+合规清单行 | `grep -c '依赖分析.*并行分组.*异构分摊' <worktree>/SKILL.md` ≥1；`grep -o 'Critical Rules 1-[0-9]*' <worktree>/SKILL.md` 输出上界=合并后实际最大编号（68） | S2 / Phase 3 | complete |
| G3 | 模板加列 | templates/task_plan.md S-unit 表加「前置依赖」列 | `grep -c '前置依赖' <worktree>/templates/task_plan.md` ≥1 且表头行含该列名 | S3 / Phase 3 | complete |
| G4 | 守卫扩展 | check-plan-dispatch.sh hard 档依赖-同组矛盾 reject+advisory 档组内全同 WARN | 构造矛盾夹具跑守卫 exit≠0；构造全同夹具输出含 WARN；`bash -n <worktree>/scripts/check-plan-dispatch.sh` exit 0 | S4 / Phase 3 | complete |
| G5 | selftest固化 | 新建 selftest-parallel-scheduling.sh 断言全过+registry 登记 | `bash <worktree>/scripts/selftest-parallel-scheduling.sh` exit 0；`grep -c 'selftest-parallel-scheduling' <worktree>/scripts/selftest-registry.tsv` ≥1 | S5 / Phase 3 | complete |
| G6 | 模式库示例 | split-pattern-library 加「依赖分批并行」模式+dispatch-examples 加异构示例 | `grep -c '依赖分批并行' <worktree>/references/split-pattern-library.md` ≥1；`grep -cE '异构|不同.*agent' <worktree>/references/dispatch-examples.md` ≥1 | S6 / Phase 3 | complete |
| G7 | 回归审查 | 全量 selftest 回归零新增失败+CR APPROVED+对齐审查 | 全量跑批输出 FAIL 计数=基线；Code Reviewer verdict=APPROVED；alignment-review 无未处置项 | V1,V2 / Phase 4 | complete |
| G8 | 合并部署 | 合并回 master+三部署位 IDENTICAL+land 68 | `git log --oneline -1 master` 含 v153 合并提交；三部署位 `diff -r` 关键文件 exit 0；`bash rule-reserve.sh check 68` 输出 landed | S7 / Phase 5 | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码（规则） | `references/critical-rules.md` | 其他规则文件 |
| 配置（技能） | `SKILL.md` | 其他技能配置 |
| 模板 | `templates/task_plan.md` | 其他模板 |
| 守卫脚本 | `scripts/check-plan-dispatch.sh` | 其他守卫脚本 |
| selftest | `scripts/selftest-parallel-scheduling.sh`（新建）, `scripts/selftest-registry.tsv`, `scripts/selftest-goal-unit-goal-mode.sh`（G-07 健壮化）, 旧 selftest 七脚本钉值级联（lane-advancement/requirement-coverage/research-first/root-resolution/self-resolution/split-pattern-library/tool-selection，B 类扩 2026-10-09 23:5x） | 上述七脚本的非钉值改动 |
| 参考文档 | `references/split-pattern-library.md`, `references/dispatch-examples.md` | 其他参考文档 |
| 计划文档 | `plans/task-v153-parallel-scheduling/*`（本计划六件套+design） | 其他任务计划目录 |
| 变更记录 | `CHANGELOG.md`（仓根，[Unreleased] 条目一条，S7 收尾簿记；B 类变更 2026-10-09 22:1x 扩 scope） | 其他段落改写 |
| CR fix-phase | `scripts/selftest-workflow-orchestration.sh`（仅 WF-10 锚 1-65→1-68）, `CLAUDE.md`, `README_zh.md`, `skills/task-planner/README.md`（仅 Rules 计数行 1-65→1-68 级联，CR F7+仓文档残留面；B 类扩 2026-10-09 00:0x） | 上述文件非计数行改动 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | Rule 21.4 并行声明制 / Rule 23.9-23.13 / Rule 43.2 / Rule 52 | `~/.zcode/skills/task-planner/references/critical-rules.md:150-157,210-214,470,593` | 必读 | ☑ |
| 官方文档 | dynamic-workflows 并行策略（SK/patterns/examples） | `/opt/ZCode/resources/glm/packages/bundled-skills/skills/dynamic-workflows/` | 必读 | ☑ |
| 项目内部文档 | check-plan-dispatch.sh 校验现状 / S-unit 表模板 | `~/.zcode/skills/task-planner/scripts/check-plan-dispatch.sh:242-249`；`templates/task_plan.md` | 必读 | ☑ |
| 项目内部文档 | 并行任务 v151/v152 在途事实 | `plans/.rule-reservations.jsonl`；`plans/task-v151-*/task_plan.md`；`plans/task-v152-*/task_plan.md` | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: task-planner 技能缺乏计划期强制依赖分析与并行分组机制，导致并行执行靠自觉、组内全同模型、并行更新无组域协议，用户执行效率低且并行运行可能错乱。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？—— Rule 68 落地后计划期自动推导并行组+异构分摊+组域协议，用户后续任务均可受益
- [x] 核心问题不解决，其他工作都白费吗？—— 是，三缺口不补则 R1-R7 全部目标落空
- [x] 核心问题的解决方法是清晰的、可执行的？—— 是，条款+模板列+守卫+selftest 四面落点已明确

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| 自身样本 | task-planner 规则/守卫/模板现状（Rule 21.4/23.9/43.2/52 + check-plan-dispatch + S-unit 表） | Explore 侦察 + Grep 定位 | findings.md §B | ☑ |
| 对标样本（58.2 强制） | dynamic-workflows 并行策略（先收窄 fan-out/唯一 join/per-task 模型缺陷） | Explore 读取 SK/patterns/examples | findings.md §A | ☑ |
| 外部约束 | 多会话并行合并（v151/v152 在途，计数级联冲突） | check-conflicts.sh 扫描 + 账本考古 | findings.md §B6 + progress.md Phase 0 | ☑ |

## Current Phase

Phase 1

## Next Step

Phase 1：plan-writer 产出 design-rule68.md（条款 68.1-68.7 全文草案 + check-plan-dispatch 校验点清单 + 模板 diff 预览）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程（计划系统文件白名单②）+ 机械守卫（grep 锚验证） | design-rule68.md 属 plans/ 计划系统文件；条款草案承自 plan-brief §四；v152 同型判例（plan-writer provider 故障亦改此路径） |
| Phase 2 | 主进程/git-master + 机械守卫（worktree 创建+基线跑批） | worktree 创建=git 编排；selftest 基线=机械守卫 |
| Phase 3 | Agent 子代理 executor(sonnet-1)/code-assistant(haiku-1) 混派 | 组内异构分摊=68.3 核心条款吃狗粮；多文件变更需不同档位 |
| Phase 4 | Agent 子代理 code-runner-agent（mini）+ Code Reviewer（sonnet-1）+ alignment-review skill | 独立执行体验证+CR+对齐审查=三视角 |
| Phase 5 | 主进程/git-master + 机械守卫（部署位对账 diff） | 合并回/部署对账/收尾簿记=git 编排+簿记白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（Phase 3 组内并行 = Rule 21.4 声明组调度，非独立子任务 fan-out；无长链多 skill 接力；用户未点名 /workflow——39.1 红线）→ 按 Rule 21.4 声明组调度：`parallel_groups: [p3-core, p3-guard, p3-docs]`，组内 S-unit 同消息并行派发（派发 prompt 须含 `[parallel-group:<组名>]` 标记），S7 合并尾串行。

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 的证据源；本任务用户未使用 /goal（该能力为并行 task-v151 专项），不涉 /goal 映射供料；/goal 为用户侧 harness 命令，技能层不可代调。

## Phases

### Phase 1: 设计定稿（条款文本草案+模板+守卫方案）
- [x] 条款 68.1-68.7 全文草案（计划期强制依赖分析/并行分组推导/组内异构分摊/组域写隔离/借鉴 workflow 三要点/守卫/机制=selftest）
- [x] check-plan-dispatch.sh 校验点清单（hard 档：组标记与声明组一致性、依赖-同组矛盾 reject；advisory 档：组内执行体全同 WARN）
- [x] templates/task_plan.md 加列 diff 预览（S-unit 表「前置依赖」列）
- [x] 落 `plans/task-v153-parallel-scheduling/design-rule68.md`
- **V-1.1:** VC-1（条款草案含 68.1-68.7 全部子条，grep 锚可验证）——Evidence: design-rule68.md §一（7 子条全文，grep '^68\.[1-7]' 可验）
- **V-N:** VC-1, VC-2
- **V-1.2:** VC-2（模板加列 diff 预览含「前置依赖」列）——Evidence: design-rule68.md §三（表头 278 行 diff）
- **Status:** complete（2026-10-09 22:55；3-File Gate exit 0+drift ALIGNED 22:52+Drift Log/ledger 双痕；[git-commit] 跳过=plans/ 按仓约定不入库）
- **Executor:** 主进程（例外理由:② 计划系统文件维护——design-rule68.md 属 `plans/` 计划系统文件，条款草案承自 plan-brief §四 设计方向——Rule 25.3 白名单；v152 同型判例）

### Phase 2: worktree 创建与基线快照
- [ ] worktree 创建：路径 `/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling`，分支 `wt/v153-parallel-scheduling`，从当前 master HEAD 创建并先校验关键文件与主仓一致（memory「worktree 分支不同步」教训）
- [ ] selftest 基线跑批存证（全量 selftest 脚本集，记录 PASS/FAIL 数）
- [ ] check-conflicts.sh 复核（确认 v151/v152 在途状态未变）
- **V-2.1:** VC-8（worktree 创建成功，分支 `wt/v153-parallel-scheduling`，关键文件与主仓 `git diff` 一致）——Evidence: git worktree list=ebb5fba + 7 文件三面 sha256 OK（progress Phase 2 段）
- **V-N:** VC-5, VC-8
- **V-2.2:** VC-5（selftest 基线跑批 PASS/FAIL 数记录在 progress.md，作为 Phase 4 回归对照基线）——Evidence: baseline-selftest.log（64/64 rc=0，ΣFAIL=0）
- **Status:** complete（2026-10-09 23:05；3-File Gate+drift 61.5 降级佐证 ALIGNED+双痕；[git-commit] 跳过=本 Phase 无仓内产物，worktree 未提交为正常初始态）
- **Executor:** 主进程（例外理由:① git/worktree 编排 +③ 机械守卫跑批——Rule 25.3 白名单①③）

### Phase 3: 实施（worktree 内，逐 S-unit 派发）
- [ ] **p3-core**={S1,S2,S3} 同消息并行派发（文件集不相交：critical-rules.md/SKILL.md/templates/task_plan.md；共同输入=design 稿；组内异构：sonnet-1/haiku-1 混）→ 三证据验收
- [ ] **p3-guard**={S4,S5} 同消息并行派发（文件集不相交：check-plan-dispatch.sh/selftest-parallel-scheduling.sh；共同输入=design 稿；组内异构：sonnet-1/haiku-1 混）→ 三证据验收
- [ ] **p3-docs**={S6} 单成员组派发（文件集：split-pattern-library.md+dispatch-examples.md）→ 验收
- [ ] **S7 合并尾**：主进程串行执行（依赖 S1-S6 全部完成；计数级联从 master 实际值递推，禁止硬编码；合并冲突按并集解 v149/v150 判例）
- [ ] 逐 S-unit 验收（22.5 三证据）+ 回填 findings/progress + ledger
- [ ] worktree 内 `git status --short` 核对改动集 = scope_files（无越界文件）
- **V-3.1:** VC-1（critical-rules.md 含 68.1-68.7 全部子条）
- **V-3.2:** VC-2（templates/task_plan.md S-unit 表含「前置依赖」列）
- **V-3.3:** VC-3（check-plan-dispatch.sh 扩展校验存在，构造用例测试有证据）
- **V-3.4:** VC-4（selftest-parallel-scheduling.sh 存在，registry 登记，断言通过）
- **V-3.5:** VC-7（本计划 parallel_groups 声明 + 组内异构执行体 + 组域写隔离协议行）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-7
- **Status:** complete（2026-10-09 23:38；三批全验收+commit 5c5b3f6；drift=61.5 降级佐证；G6 证据见 progress [goal:G6]）
- **Executor:** 主进程（例外理由:① 派发编排（21.4 调度管理器职责）+② 三文件簿记——Rule 25.3 白名单①②；S-unit 派发表见下）

<!-- S-unit 派发单元表(Rule 22.6 — 每行 = 一次 Agent() 派发;单步 ≤step_max_files(2) 文件 / ≤step_max_lines(100) 行 / ≤step_max_minutes(15) 分钟;ID 纯数字;粒度三值 Nf/Nl/Nmin 逐行校验;「伴飞技能」列非「无」→ 校验 SKILL.md 路径存在(Rule 59.2);Rule 68.1 前置依赖列必填,无依赖填 `-`) -->
| ID | 目标(≤ 1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 并行组 | 检查点 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|---------|--------|--------|------|
| S1 | critical-rules.md 文末追加 Rule 68 条款全文（68.1 计划期强制依赖分析/68.2 并行分组推导/68.3 组内异构分摊/68.4 组域写隔离与状态一致性/68.5 借鉴 workflow 三要点/68.6 守卫/68.7 机制=selftest） | executor（sonnet-1） | plans/task-v153-parallel-scheduling/design-rule68.md（条款草案全文）+ 部署位 references/critical-rules.md 文末追加位（Rule 65 之后） | `grep -cE '^68\.[1-7] ' critical-rules.md` =7 且含「依赖分析、并行分组、异构分摊、组域写隔离」；既有 Rule 1-65 正文 `git diff` 零改动（仅文末追加） | 15min | 1f/90l/15min | 无 | - | p3-core | subagent-state/3-executor-S1.md | complete |
| S2 | SKILL.md 计划撰写流程加「依赖分析→并行分组→异构分摊」强制步骤行 + 计数级联（Critical Rules 上界=合并后实际最大编号）+ 合规清单 C 行（编号以合并时 master 实际递推为准） | code-assistant（haiku-1） | design-rule68.md（流程步骤+计数级联清单）+ 部署位 SKILL.md 计划撰写流程段 + 合规清单 | 短串 `grep -c '依赖分析.*并行分组.*异构分摊' SKILL.md` ≥1；`Critical Rules 1-` 上界=合并后实际最大值；合规清单含 Rule 68 条目；`1-65`=0（旧值清零） | 15min | 1f/25l/15min | 无 | - | p3-core | subagent-state/3-code-assistant-S2.md | complete |
| S3 | templates/task_plan.md S-unit 表加「前置依赖」列（表头+数据行格式，无依赖填 `-`） | code-assistant（haiku-1） | design-rule68.md（模板 diff 预览）+ 部署位 templates/task_plan.md S-unit 表 | `grep -c '前置依赖' templates/task_plan.md` ≥1 且表头含该列名；既有列零改动（仅加列） | 10min | 1f/8l/10min | 无 | - | p3-core | subagent-state/3-code-assistant-S3.md | complete |
| S4 | check-plan-dispatch.sh attest 期扩展：hard 档校验组标记与声明组一致性、依赖-同组矛盾 reject；advisory 档校验组内执行体全同 WARN | executor（sonnet-1） | design-rule68.md（守卫校验点清单）+ 部署位 scripts/check-plan-dispatch.sh attest 期 | `grep -cE 'parallel-group、依赖-同组、组内全同'` 任一命中 ≥3 处（三关键词分别 grep）；构造矛盾用例跑守卫 exit≠0；构造全同用例输出 WARN；`bash -n` 语法通过 | 15min | 1f/30l/15min | 无 | S1 | p3-guard | subagent-state/3-executor-S4.md | complete |
| S5 | 新建 selftest-parallel-scheduling.sh（静态断言：68 子条/前置依赖列/守卫校验点/registry 行）+ selftest-registry.tsv 加 1 行 | code-assistant（haiku-1） | design-rule68.md（selftest 断言清单）+ 部署位 scripts/（无同名脚本，纯新建） | `bash selftest-parallel-scheduling.sh` exit 0 全 PASS；`tail -1 registry.tsv` 含新行且 4 列；`grep -c '68' selftest-parallel-scheduling.sh` ≥7 | 15min | 2f/80l/15min | 无 | S1 | p3-guard | subagent-state/3-code-assistant-S5.md | complete |
| S6 | split-pattern-library.md 新增「依赖分批并行（fan-out→join→串行链）」模式 + dispatch-examples.md 同批不同 agent/模型派发示例 | code-assistant（haiku-1） | design-rule68.md（模式草案+示例）+ 部署位 references/split-pattern-library.md 与 references/dispatch-examples.md（各追加一节） | `grep -c '依赖分批并行' split-pattern-library.md` ≥1；`grep -cE '异构、不同.*agent.*模型'` 任一命中 dispatch-examples.md；既有内容 `git diff` 仅追加 | 15min | 2f/40l/15min | 无 | S1 | p3-docs | subagent-state/3-code-assistant-S6.md | complete |
| S7 | 合并时计数级联与并集解（依赖 S1-S6 全部完成，串行尾）：所有计数锚写「合并时从 master 实际值递推」，禁止硬编码当前态；合并冲突按并集解（v149/v150 判例） | 主进程 | S1-S6 完成后的 worktree 状态 + v149/v150 并集解判例 | `git diff` 显示所有计数锚为递推写法（无硬编码数字）；并集解判例引用正确；worktree `git status` 干净 | 10min | 0f/0l/10min | 无 | S1-S6 | - | - | complete |

> **单元组标记（Rule 21.4 声明制 + Rule 68.2 依赖推导）**：`[parallel-group:p3-core]` = S1, S2, S3（文件集互斥：critical-rules.md / SKILL.md / templates/task_plan.md；输入各自独立、验收独立——独立性四问全否 → 组内并行）；**`[parallel-group:p3-guard]` = S4, S5**（文件集互斥：check-plan-dispatch.sh / selftest-parallel-scheduling.sh；输入各自独立、验收独立——独立性四问全否 → 组内并行）；**`[parallel-group:p3-docs]` = S6**（单成员组，split-pattern-library.md + dispatch-examples.md）。**S7 前置依赖=S1-S6 全部完成**（串行尾，主进程执行）。**组内异构（Rule 68.3）**：p3-core 含 sonnet-1（S1）与 haiku-1（S2,S3）混派；p3-guard 含 sonnet-1（S4）与 haiku-1（S5）混派。**派发 prompt 必须含对应 `[parallel-group:...]` 标记**（check-dispatch.sh 双条件放行槽锁）。**组域写隔离（Rule 68.4）**：组内成员只写自己 checkpoint 与 findings append + 自己 scope_files；计划三文件状态列/Handoff 表由主进程按组串行回写（单写者原则推广）；组内成员完成→组批验收→统一翻状态，禁止组内并行成员直接 Edit task_plan.md。

### Phase 4: 验证（独立执行体）
- [ ] selftest 全量回归（FAIL=0，相对 Phase 2 基线零新增失败）
- [ ] 新 selftest 断言验证（selftest-parallel-scheduling.sh 单跑 exit 0）
- [ ] Code Reviewer（sonnet-1）全量 CR（critical-rules.md/SKILL.md/templates/check-plan-dispatch.sh/selftest-parallel-scheduling.sh/split-pattern-library.md/dispatch-examples.md）
- [ ] alignment-review（42.6.2）对齐审查
- **V-4.1:** VC-5（全量 selftest FAIL=0，相对基线零新增失败）——Evidence: regression-v1.log Round1(7 FAIL→修复)/Round2 65/65/Round3 65/65/Round4 65/65，ΣFAIL=0（Round 4 终态，fix C 后）
- **V-4.2:** VC-3（check-plan-dispatch.sh 守卫扩展测试证据：reject+WARN 用例）——Evidence: fixA 复跑 H4 矛盾 rc=1 原文+W1 WARN rc=0+真实计划零误报+F8 双夹具（裸管道 reject/转义放行）
- **V-4.3:** VC-6（SKILL.md 计数级联正确，alignment-review 通过）——Evidence: CR 二轮 APPROVED（八发现全 fixed+3 新 MINOR 中 2 已修 1 为检查点文档口径）+主进程六维对齐核验（载体=gp Skill 调用连续两次取消→22.3.1 路由变更，已登记降级理由）
- **V-N:** VC-3, VC-5, VC-6
- **Status:** complete（2026-10-10 03:3x；V1 Round1-4 三轮修复闭环+CR 二轮 APPROVED+对齐六维全绿+commit 74177a6；drift=61.5 降级佐证+人工复核）
- **Executor:** code-runner-agent（mini）+ code-reviewer（sonnet-1）+ alignment-review skill（42.6.2；载体取消降级已登记）

<!-- S-unit 派发单元表(Rule 22.6 — 每行 = 一次 Agent() 派发;粒度三值 Nf/Nl/Nmin 逐行校验) -->
| ID | 目标(≤ 1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 并行组 | 检查点 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|---------|--------|--------|------|
| V1 | worktree 内全量 selftest 跑批回归与基线对比（FAIL 计数=基线零新增） | code-runner-agent（mini） | worktree scripts/ 全量 selftest + plans/task-v153-parallel-scheduling/baseline-selftest.log（Phase 2 基线） | 跑批输出 Total/FAIL 行逐条贴回（逐行原文，禁自报汇总）；FAIL 数=基线 | 15min | 2f/20l/15min | 无 | S1-S6 | - | subagent-state/4-code-runner-V1.md | pending |
| S9 | Code Reviewer 全量 CR（Rule 68 条款+SKILL 级联+模板列+守卫+selftest 七文件重 diff） | code-reviewer（sonnet-1） | worktree `git diff master` 全量 + design-rule68.md（审查基准） | 输出 APPROVED 或 CHANGES_REQUESTED（CHANGES → fix-phase 回炉） | 15min | 2f/100l/15min | 无 | S1-S6 | - | subagent-state/4-code-reviewer-V2.md | pending |

### Phase 5: 合并回+部署对账+收尾簿记
- [x] smart-merge-back（`git merge --no-ff wt/v153-parallel-scheduling`）——b20974f 自动归并零冲突（v151 终态 5afba9c+wt/v153 74177a6 并集）
- [x] 部署位对账（三部署位 IDENTICAL：repo/`~/.zcode`/`~/.claude` 关键文件 diff -q 全 OK）
- [x] land 68（Rule 68 正式生效，账本登记= landed）
- [x] CHANGELOG.md [Unreleased] 条目一条（Rule 68 变更记录三要素；B 类扩 scope 已登记 Decisions）
- [ ] delivery-summary + 清理 worktree（`git worktree remove` + `git branch -d`）
- **V-5.1:** VC-6（SKILL.md 计数级联合并后实际值正确，Rule 68 索引行与合规清单行在位）——Evidence: 合并态 grep 1-68×3+C46+bullet+66 枚举
- **V-5.2:** VC-8（三部署位 IDENTICAL，合并后对账 diff 一致）——Evidence: b20974f+三部署位 diff -q OK
- **V-N:** VC-6, VC-8
- **Status:** complete（2026-10-10 04:0x；merge 零冲突+部署 IDENTICAL+land 68+R5 合并态回归 65/65 ΣFAIL=0；drift=61.5 降级佐证+Drift Log 双痕）
- **Executor:** 主进程（例外理由:① git/worktree 编排（合并/清理/部署）+② 收尾簿记——Rule 25.3 白名单①②）

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号：未提交变更 4（plans 内并行任务产物）/ 额外 worktree 2（v151/v152 在途）/ wt/* 分支 2——与本任务文件范围不重叠） |
| `isolation` | `worktree`（宪法 §十一 保护区命中：`skills/**` 属保护区，实现类必须隔离） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/v153-parallel-scheduling` |
| `branch` | `wt/v153-parallel-scheduling` |
| `merge_back` | `pending` |

> 契约详见 `~/.zcode/skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — v063 方法论引入，指针 references/methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 五档） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 条款草案与 brief §四 设计方向漂移 | 6 | 3 | 3 | 54 | - |
| Phase 2 | worktree 分支不同步（master 在 Phase 0-2 间有新提交） | 7 | 4 | 4 | 112 | 拆细：创建后 `git fetch+reset --hard origin/master` 强制对齐；memory 教训已登记 |
| Phase 3 | 计数级联冲突（v151/v152 在途，66/67 可能已 merge） | 8 | 5 | 6 | 240 | 降档+改派：所有计数锚写递推，合并时从 master 实际值递推；冲突按并集解（v149/v150 判例）；provider 失败按 22.3.1 改派 |
| Phase 3 | 组内执行体全同（违背 68.3） | 7 | 4 | 5 | 140 | 降档：已预设组内 haiku-1/sonnet-1 混派；若派发失败按 22.3 改派补异构 |
| Phase 3 | 组内并行成员直接 Edit task_plan.md（违背 68.4） | 8 | 3 | 4 | 96 | - |
| Phase 4 | selftest 回归 FAIL>0（既有 selftest 锚被破坏） | 7 | 3 | 4 | 84 | - |
| Phase 5 | 合并冲突（critical-rules.md 文末追加位与 v151/v152 冲突） | 8 | 5 | 5 | 200 | 降档：并集解（v149/v150 判例）；所有计数锚递推；必要时 AskUserQuestion 确认 |

**填写规则**：RPN>100 的 Phase → 兜底动作列必填。本表是规划期预演，执行期实际失败仍走 Rule 22.3 完整兜底链。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ | | |
| Phase 2 | ☐ | | |
| Phase 3 | ☐ | | |
| Phase 4 | ☐ | | |
| Phase 5 | ☐ | | |

## Key Questions

- 计数级联递推写法是否覆盖全部锚点（Critical Rules 上界/合规清单行号/selftest registry 行数）？→ Phase 1 design 稿逐锚清单确认
- p3-guard 组内异构（S4 executor sonnet-1 / S5 code-assistant haiku-1）是否满足 68.3？→ 是，model 档位互不相同
- selftest-parallel-scheduling.sh 断言是否覆盖 68 子条全部关键锚？→ Phase 1 design 稿确认

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| auto:D1 计划批准按默认项「批准执行」自动裁决（超时值 5min/推荐项 批准执行/触发时间 2026-10-09 22:06/理由=用户 AskUserQuestion 未答复,Rule 44.3 自动裁决+登记/被覆盖选项=先看计划全文·修改计划·暂停任务） | Rule 44.1/44.3 计划预登记「自动超时默认项=D1 批准计划+worktree/5min」 |
| 思路复述已呈示，2026-10-09 22:05（28.2.1 五行：Phase 序列/执行体模型/关键门控/隔离合并/交付节奏） | Rule 28.2.1 ask 模式批准前复述义务 |
| B 类扩 scope：CHANGELOG.md 入 S7 收尾簿记范围（2026-10-09 22:1x，来源=主进程对照仓约定 v149/v150 均有 [Unreleased] 条目而初版 scope 遗漏） | Rule 8.1 B 类=扩交付物，计划先改后执行+重 attest |
| 执行期状态回写（Phase 翻转/Drift Log/V-N 证据行）致哈希漂移，按 Phase 边界重 attest 锁定（2026-10-09 22:55 首次执行期重锁登记） | Rule 20 注入锁惯例：状态回写=正常簿记非重规划，重锁前先行本行登记（51.7 防篡改语义满足） |
| alignment-review 载体降级：gp+Skill("alignment-review") 连续两次调度取消 → Rule 22.3.1 路由变更为主进程六维机械对齐核验（2026-10-10 03:3x） | 载体不可用≠跳过（41/63 反推诿）；机械对齐=42.6 版本一致性/联动锚五类巡检的本机可执行面，六维全绿+findings 登记（Skill JUDGMENT 面差异已如实披露）；parallel_scheduling selftest/守卫 selftest 另提供机器守护 |
| B 类扩 scope：selftest-goal-unit-goal-mode.sh 仅 G-07 断言健壮化（末行断言→含断言，≤3 行）（2026-10-09 23:2x） | 本任务 registry 追加行打破 v151 G-07「末行=goal-unit」断言（S4/S5 双复现+主进程复跑 FAIL 实证）；Phase 4 V1 回归零新增失败硬门要求修复；末行断言=跨任务 brittleness，改「含」=同义健壮化非语义改写 |
| B 类扩 scope：CR fix-phase 面（守卫 MAJOR+68.5 全名+SKILL 枚举 66+WF-10 锚+三仓文档计数行）（2026-10-09 00:0x） | CR CHANGES_REQUESTED（1 MAJOR+7 MINOR）：MAJOR=组标记消费口径不一致（注解形态 H4/W1/W2 静默失效）；F5=68.5 SK.md 悬空缩写；F6=SKILL:9 枚举漏 66；F7=WF-10 钉 1-65 仅因 CLAUDE.md/README_zh/技能 README 残留而侥幸 PASS（v149 世代文档未随 v151/v153 级联）——修法全为级联/健壮化非语义改写 |
| B 类扩 scope：旧 selftest 七脚本钉值级联+SKILL:9 词序还原（2026-10-09 23:5x） | V1 Round 1 实测 7 脚本 rc≠0（ΣFAIL=9）：literal 'Critical Rules 1-66'×4 脚本/RF-06 '1-66'≥3/RF-07 双锚/RR-09 '全集 1-' 宽容正则（被 S2 词序偏差击穿）/SP-02·SP-11 模式数=11 钉；v151 同型判例=其 S4 对同批脚本做过 1-65→1-66 重钉；词序还原同时消解 S2 披露偏差；锚级联=规则任务标准面 |
| 新 Rule 独立编号 68 而非扩展 21.4 子条 | 跨「计划期步骤+模板列+守卫+异构分配」四面，子条扩展会撑破 21.4 语义域；66/67 在途防撞号（B6） |
| p3-guard 组内 S5 selftest 用 code-assistant(haiku-1) 而非 brief 原写 executor(sonnet-1) | brief §五 原分配 p3-guard 全同（两个 executor sonnet-1）违背 68.3 组内异构；selftest 新建约 80 行 1-2 文件，code-assistant 可承载；按 68.3 优先修正 |
| 计数级联全部写递推，禁止硬编码 | v151/v152 在途，合并时 master 实际值未知；硬编码必冲突（§六 最高风险） |
| 借鉴 workflow 的是「依赖分组思想+唯一 join+先收窄」，不搬运行时调度器 | A4 schema 限制=无 per-task 模型；task-planner 的 Agent() 天然支持 subagent_type+model 异构 |
| 异构分配用软约束+advisory 校验起步 | 硬 enforce 需模型可用性事实源，先 advisory 防误拦（对照 43.2 既有档位表） |
| 组域写隔离=单写者原则推广到通用 S-unit | 49.4 已有单写者原则；68.4 将其从「计划文件」推广到「组内所有写操作」 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-09 22:52 | ALIGNED（三锚齐：Goal R1-R7 对位 68.1-68.4/design 落盘+attest SHA 实证/scope 无越界；drift-checker provider 拒×2 后 22.3.1 改派 general-purpose 承载） | VC-1~g | 继续；三条簿记观察（时间戳/kb 未填/锚点重验）已在 Phase 1 收尾处置 |
| 2026-10-09 23:05 | ALIGNED（Phase 2，61.5 降级佐证 check-drift.sh：无漂移） | VC-5/h | worktree+基线与计划对齐 |
| 2026-10-09 23:38 | 61.5 佐证=drift_score 1（SCOPE-BREACH 命中 10 文件）→ 主进程人工复核：命中集全部∈plans/task-v153-parallel-scheduling/*（设计稿/kb/检查点/账本=计划系统文件 Rule 25.3 白名单②），系脚本将计划目录相对路径与 skill 源 scope 表比对的口径差，无实质越界 → 复核判定 ALIGNED | VC-1~g | Phase 3 三批全验收+commit 5c5b3f6；继续 Phase 4 |
| 2026-10-10 03:4x | 61.5 佐证=drift_score 1（同上 SCOPE-BREACH 计划系统文件）→ 人工复核：无实质越界 ⊕ 四轮回归归零/CR APPROVED/对齐六维全绿，执行面与计划一致 → ALIGNED | VC-5/c/f | continue Phase 5 合并回 |
| 2026-10-10 04:0x | 61.5 佐证+人工复核（计划系统文件口径差）⊕ 合并零冲突/部署 IDENTICAL/land 68/R5 65-65 全绿 → ALIGNED | VC-8 | 交付收尾 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6,批量任务必填）

| 字段 | 值 |
|------|-----|
| `total` | 17（Agent 派发总数：7 实施+CR2+验收回填轮6+对齐2；v122/判例:按 Handoff 行计） |
| `success` | 17 |
| `failed` | 0 |
| `failure_rate` | 0.0%（<5% 阈值，无 STOP/熔断触发） |
| `sampled_pass` | n/a 非同质批量——本任务为 Rule 68 实现单元批次（单元间目标/文件集不同），不适用同质抽检；质量门=全量 selftest×5 轮+CR 两轮承担（Rule 18.4 语义） |
| `sampled_fail` | n/a（同上；运行前抽 2 语义不适配异质单元） |
| `pre_check` | Q1:否（异质单元非同质大批量）/Q2:有（check-dispatch 契约门+组内异构守卫）/Q3:能（每单元独立验收） |
| `rollback_point` | master b20974f（合并前点=worktree 74177a6；worktree 已清理，回滚路径=git revert 74177a6 与 5c5b3f6 区间） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤ 1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-10-09 21:50 | plan-writer→general-purpose(rescue) | 消费 plan-brief+findings 产出 task_plan.md 全文 | done | 守卫契约补拦 3 次+plan-writer provider reasoning-missing 2 次→22.3.1 改派 general-purpose 成功；产出 361 行/7 单元/8 VC 已主进程 Read 复核 | task_plan.md 全文 361 行；Provider error reasoning-level-missing（selection 9e221f47/sonnet-1） | findings §Requirements/§Technical Decisions | subagent-state/1-plan-writer.md | rescue: provider 失败改派（v127 判例）；plan-writer agent 定义故障待上报 / 2 / ☑ |
| 2 | 2026-10-09 23:08 | executor | S1 critical-rules.md 文末追加 Rule 68 条款全文 | done | grep=7+四关键词过；diff 1 deletion=master 66.2 演进（非本单元，S7 并集解） | worktree critical-rules.md:862-878 | findings 回填=主进程批记 | subagent-state/3-executor-S1.md | - / 0 / ☑ |
| 3 | 2026-10-09 23:08 | code-assistant | S2 SKILL.md 计数级联+C46+流程步骤行 | done | 四锚 1-68+C46:220+流程行:76+bullet:341；词序偏差披露待 S7 | worktree SKILL.md:9,76,220,283,341,365 | findings [sub:S2] | subagent-state/3-code-assistant-S2.md | - / 0 / ☑ |
| 4 | 2026-10-09 23:08 | code-assistant | S3 templates/task_plan.md 加「前置依赖」列 | done | 表头:279 插列位正确+注释:277；diff 仅该文件 | worktree templates/task_plan.md:277,279 | findings 回填=主进程批记 | subagent-state/3-code-assistant-S3.md | - / 0 / ☑ |
| 5 | 2026-10-09 23:17 | executor | S4 check-plan-dispatch.sh Rule 68 校验段（H1-H4+W1-W2） | done | +163 行 :414 起；夹具 H4 rc=1/W1 WARN rc=0；真实计划零误报 | worktree check-plan-dispatch.sh:414-577 | findings 回填=主进程批记 | subagent-state/3-executor-S4.md | - / 0 / ☑ |
| 6 | 2026-10-09 23:17 | code-assistant | S5 selftest-parallel-scheduling.sh 新建+registry 行 | done | 152 行 P-01..09；8 PASS+1 SOFT(P-09 待 S6)；registry 65/65 自校验 | worktree scripts/selftest-parallel-scheduling.sh | findings [sub:selftest单元] | subagent-state/3-code-assistant-S5.md | - / 0 / ☑ |
| 7 | 2026-10-09 23:26 | code-assistant | G-07 断言健壮化（B 类扩 scope，末行口径→含口径） | done | goal-unit selftest 9/9 PASS；registry 面零回归 | worktree selftest-goal-unit-goal-mode.sh:19,104-108 | findings [sub:G07修复] | subagent-state/3-code-assistant-G07fix.md | - / 0 / ☑ |
| 8 | 2026-10-09 23:30 | code-assistant | S6 split-pattern-library P12+dispatch-examples §4 异构示例 | done | P12:110+示例:52；selftest 9/9 全硬 PASS（P-09 升硬） | worktree references/split-pattern-library.md:110;dispatch-examples.md:52 | findings [sub:文档单元] | subagent-state/3-code-assistant-S6.md | - / 0 / ☑ |
| 9 | 2026-10-09 23:36 | 主进程 | S7 计数级联复核+CHANGELOG+Phase 3 提交（白名单①②） | done | 级联 3×1-68 零残留/registry 65/65/SKILL 514≤515 钉；commit 5c5b3f6 十文件 +417/-12 | worktree git log 5c5b3f6；CHANGELOG [Unreleased] 头条 | findings §Technical Decisions | n/a（主进程） | 主进程白名单例外已登记 / 0 / ☑ |
| 10 | 2026-10-09 23:42 | code-runner-agent | V1 全量 selftest 回归 Round 1（65 脚本逐行回贴） | done | Round 1=7 旧 selftest rc≠0（ΣFAIL=9）→触发级联修复轮 | regression-v1.log | findings [sub:回归单元] | subagent-state/4-code-runner-V1.md | - / 0 / ☑ |
| 11 | 2026-10-09 23:50 | code-assistant | 七脚本钉值级联修复+SKILL:9 词序还原 | done | 10 脚本 rc=0；RR-09 零改动命中恢复 | worktree 7 脚本+SKILL:9 | findings [sub:级联修复] | subagent-state/4-code-assistant-cascade-fix.md | - / 0 / ☑ |
| 12 | 2026-10-10 02:5x | code-reviewer | V2 全量 CR 第一轮 | done | CHANGES_REQUESTED 1 MAJOR+7 MINOR（无 BLOCKER） | subagent-state/4-code-reviewer-V2.md | findings [sub:CR] | subagent-state/4-code-reviewer-V2.md | - / 0 / ☑ |
| 13 | 2026-10-10 03:0x | executor | CR fix A（守卫 MAJOR+F2/F3/F4/F8+F5） | done | 修复前后对照复现+四夹具+真实计划零误报 | subagent-state/4-executor-crfixA.md | findings [sub:CR修复A] | subagent-state/4-executor-crfixA.md | - / 0 / ☑ |
| 14 | 2026-10-10 03:1x | code-assistant | CR fix B（F6/F7+三仓文档级联） | done | WF-10 16/16+1-65 三文档 0 命中 | subagent-state/4-code-assistant-crfixB.md | findings [sub:CR修复B] | subagent-state/4-code-assistant-crfixB.md | - / 0 / ☑ |
| 15 | 2026-10-10 03:2x | code-reviewer | V2 CR 第二轮回审 | done | **APPROVED**（八发现全 fixed；3 新 MINOR） | subagent-state/4-code-reviewer-V2-round2.md | findings [sub:CR2] | subagent-state/4-code-reviewer-V2-round2.md | - / 0 / ☑ |
| 16 | 2026-10-10 03:2x | code-assistant | fix C（F8 转义管道误报+registry 陈旧描述） | done | 双夹具（转义放行/裸管道 reject）+9/9+5/5 | subagent-state/4-code-assistant-fixC.md | findings [sub:修复C] | subagent-state/4-code-assistant-fixC.md | - / 0 / ☑ |
| 17 | 2026-10-10 03:3x | 主进程 | alignment-review 载体连续两次取消→22.3.1 路由变更主进程六维机械对齐 | done | 六维全绿（SKILL 计数/条款↔守卫↔selftest/模板↔模式库↔示例↔registry/仓文档/悬挂引用/design↔impl） | 本对话对齐浏览器结果 | findings §Technical Decisions | n/a | 路由变更已登记 Decisions / 0 / ☑ |

## 📋 需求覆盖核对表（Rule 51.3/51.4 终验交付态）

| R | 需求核心 | 覆盖 VC | 状态 | 证据锚 |
|---|---------|---------|------|--------|
| R1 | 计划初期分析任务依赖 | VC-1, VC-2 | covered | 68.1 条款+前置依赖列+守卫 H1/H2 |
| R2 | 可并行并行/有依赖串行 | VC-1, VC-7 | covered | 68.2 条款+H4 依赖-同组矛盾硬门+本计划三组分组 |
| R3 | 以后都自动并行加速（机制固化） | VC-4, VC-5 | covered | selftest 9/9+全量 65/65 零回归 |
| R4 | 纠正 workflow 单模型缺陷 | VC-1, VC-6 | covered | findings §A A4 schema 实证+68.3 条款+SKILL 级联 |
| R5 | 不同 Agent+模型运作 | VC-1, VC-7 | covered | 68.3+本计划组内三 provider 混派实证 |
| R6 | 执行慢（动机） | VC-3, VC-4 | covered | 守卫+两级 selftest+并行实测 6min vs ~40min |
| R7 | 分组后组内更新防错乱 | VC-1, VC-7 | covered | 68.4 组域写隔离+本计划协议行+组域隔离每批复验 |

让步登记：无（7/7 R 全 covered）。

## 🔗 Chain 区块交接配置（可选）

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 本任务（单 skill 单 Block）

| 字段 | 值 |
|------|-----|
| **goal** | Rule 68 落地（条款+模板+守卫+selftest） |
| **depends_on** | none |
| **passes_to** | n/a（单 Block 任务） |
| **status** | complete |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | - | - | - | - |

## 🔁 模板感知
<!-- template_type: rule-enhancement -->
<!-- task-v153: rule-enhancement 类型，check-template-type 第三形态机读标记 -->
- 触发信号: rule-enhancement 类型已确认（Rule 68 新增=规则增强）
- Rule 34.3 沉淀预登记: 任务完成终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ 指向 plan-template-kit 卫星 SOP
不沉淀理由：rule-enhancement 既有 variant 已覆盖本任务型（design-draft 驱动流程=既有契约面）；Rule 68 内容已由 critical-rules 本体承载，无新 variant 抽象空间；Rule 34.3 三触发条件均不命中（2026-10-10 终验登记）
