# Task Plan: task-v170 计划完成后归档机制（Rule 81 + archive-plan.sh + 存量全归档）
execution_lane: L2
parallel_groups: [g-wire, g-cascade, g-cascade2]
lanes: [g-wire, g-cascade, g-cascade2]

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我发现当前的技能在执行完任务之后，存在一个存在缺失归档的步骤。」<sub>（[目标]）</sub>
- **R2**: 「因为所有计划文档在使用完成之后，没有直接进行归档，而导致计划目录下存在乱七八糟的一堆，这是严重缺陷，必须添加归档。」<sub>（[目标]）</sub>
- **R3**: 「确保所有的被使用完成的计划任务全部归档处理。」<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-4 | 完成流程（SKILL.md 终验交付段）出现归档步骤行 + archive-plan.sh 单任务归档实跑成功且幂等 |
| R2 | VC-2, VC-4, VC-6 | 守卫实证拒绝三类误归档；Rule 81 正文+selftest 在位；INDEX/指针等引用面归档后不失真 |
| R3 | VC-3 | plans/ 根目录 Status=complete 的任务目录数归档后=0（dry-run 清单 vs 实做后清点双向一致） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 任务收尾（终验交付→check-complete exit 0→会话结束） | 收尾链只到 check-complete.sh，无任何归档动作——70+ 任务完成后再未归档（仅 task-v069 一次性 plan-hygiene.sh --execute 归档 21 个，714c93b，此后机制断代） | Phase 3 S2：SKILL.md 终验交付段接入归档步骤 | VC-1, VC-4 |
| 归档动作执行（若有一步） | 无专用脚本；plan-hygiene.sh 为一次性工具、无守卫、无幂等、无批量 | Phase 3 S1：archive-plan.sh（守卫+幂等+dry-run+批量） | VC-1, VC-2 |
| 索引与指针联动 | sync-todos.sh/resolve-plan-dir.sh/set-active-plan.sh 硬扫 plans/*，未排除 archive（plan-created.cjs 已有跳过先例 L10/L122） | Phase 4 S4/S5：archive 跳过适配 | VC-6 |
| 存量治理 | 约 110 个 Status=complete 目录堆积在 plans/ 根（v055 起） | Phase 8：dry-run→试点→批量实做+INDEX 重生 | VC-3 |
| 防复发机制 | 无机器守护：新人/新会话不知道要归档 | Rule 81 + selftest-archive-plan.sh + check-complete [ARCHIVE-GATE] warn + C56 | VC-4, VC-5 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）

| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal/VC 表/R1-R3 原文；「完成→归档」必须进完成流程而非仅靠自觉；误归档防护 fail-closed（active/session-owner/非 complete 一律拒绝）；存量 completed 全归档；既有 selftest 全量不破；worktree 隔离实现 | 本文件对应章节 |
| 🔀 可变量 | 脚本内部实现/S-unit 拆分/Rule 81 子条款编号分配/selftest 断言形态/试点目录选取 | - |
| 📈 学得量 | 执行期新事实/教训/锚点→findings.md/notepad-learnings.md；禁反向改写不变量 | findings.md |

## Goal

给 task-planner 技能补齐「计划完成后归档」机制：完成流程末段接入归档步骤、新增带安全守卫的 archive-plan.sh 脚本、适配全部引用面脚本、制度化为 Rule 81 并有 selftest 守护，同时把存量约 110 个已完成计划全部归档进 plans/archive/，回归不破。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 6 个 .sh 脚本+SKILL.md 逻辑变更，命中 Rule 42.7 风险信号：逻辑变更/跨文件影响/diff>3 文件） |
| `session_id` | `task-v170-archive-completed-plans` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans` |
| `scope_files` | `skills/task-planner/scripts/archive-plan.sh`(新)、`skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/scripts/sync-todos.sh`、`skills/task-planner/scripts/resolve-plan-dir.sh`、`skills/task-planner/scripts/set-active-plan.sh`、`skills/task-planner/scripts/check-complete.sh`、`skills/task-planner/scripts/plan-created.cjs`(复核)、`skills/task-planner/scripts/selftest-archive-plan.sh`(新)、registry 登记文件、级联 selftest 文件 |
| `interaction_mode` | `silent`（理由：用户已给出明确完整指令「必须添加归档」「确保全部归档」，无待裁决分叉；按 v168/v169 先例登记静默决策；D6 硬停点仍遵守） |
| `对齐审查` | Rule 42.6：完成前对全部产出跑 alignment-review 对齐审查（Phase 7 委派）；文档更新前跑版本一致性校验 |
| `自动超时默认项` | 无 2+ 选项询问点（silent 模式；批量归档守门均为机器判据，无用户选项） |
| `new_rule` | `81` | Rule 20.6：本任务新增 Rule 编号时填写（attest 自动预留+查重；无则留空） |
| `质量审查工具` | Rule 42.2 四级检测：项目级无 → 用户级 `code-reviewer` agent（环境既有，Tools: Read/Grep/Glob/Bash/Agent/TodoWrite）命中 → 内置 review-library 兜底池不启用。CR 执行体=code-reviewer（Phase 6）|

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | archive-plan.sh 单任务归档实跑成功（试点目录 rename 落盘）+ 幂等（二次运行 ALREADY_ARCHIVED exit 0） | 跑脚本 + git status 观察 rename + 二次运行 | plans/task-v170.../progress.md Phase 8 段 + git status 输出 |
| VC-2 | 安全守卫实证：active 指针目标/.session-owner 持有者/Status≠complete 三类各至少 1 例拒绝（exit 1 且原目录不动） | dry-run/实跑拒绝案例 | progress.md Phase 4 守卫实测段（fixture 路径） |
| VC-3 | 存量全归档：plans/ 根目录 Status=complete 的 task-* 目录归档后=0；archive/ 收容数=dry-run 候选数 | dry-run 清单 vs 实做后清点双向对账 | progress.md Phase 8 Batch Report + ls 计数 |
| VC-4 | 流程与制度在位：SKILL.md 终验交付段含归档步骤行；critical-rules.md Rule 81 正文在位；selftest-archive-plan.sh 全 PASS 且登记 registry | grep 行 + 跑 selftest | grep 输出 + selftest 输出 |
| VC-5 | 无回归：仓内全量 selftest 套件 FAIL=0 | 跑测试入口（worktree 内） | tests 输出汇总 |
| VC-6 | 引用面适配：sync-todos.sh --index 重生 INDEX 不含 archive 任务；resolve-plan-dir.sh 不误中 archive；set-active-plan.sh gc 不误扫 archive | 三脚本实跑 | 命令输出 |
| VC-7 | 合并回 master 成功 + 两部署位（~/.zcode、~/.claude/skills/task-planner）与主仓 diff=0 | git merge --no-ff + diff -r | merge commit + diff 输出 |

**终验规则**：全部 VC 通过 → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 失败重试 3 次无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1/R2/R3 |
| **裁决** | 终验填（solved/partial/not-solved 三选一） |
| **解决证据锚** | 终验填 |
| **未解决面+原因** | 终验填 |
| **已排除路径** | 终验填 |
| **下一步建议** | 终验填 |

## 🎯 Goal 单元表（Rule 66.1）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 勘查定案 | 摸清完成流程/归档先例/引用面/存量清单 | 001-explore 检查点 + dry-run 清单对账 | S1/Phase 1 | pending |
| G2 | 归档脚本 | archive-plan.sh 带守卫+幂等+批量 | bash -n + 单任务实跑+幂等+守卫三拒绝 | S2/Phase 3 | pending |
| G3 | 流程接线 | 完成流程末段含归档步骤+Rule 81 在位 | grep SKILL.md 归档行 + grep Rule 81 | S3-S4/Phase 4 | pending |
| G4 | 联动适配 | 引用面三脚本跳过 archive | sync-todos/resolve-plan-dir/set-active-plan 实跑 | S5-S6/Phase 4 | pending |
| G5 | 守护回归 | selftest 新增+全量不破 | selftest-archive-plan PASS + 全量 FAIL=0 | S8-S10/Phase 5 | pending |
| G6 | 存量归档 | 110 个 completed 目录全部进 archive/ | dry-run 清单=实做清点双向一致 | Phase 8 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|------|------------|------|
| 源码 | skills/task-planner/scripts/archive-plan.sh（新）、scripts/selftest-archive-plan.sh（新）、scripts/sync-todos.sh、scripts/resolve-plan-dir.sh、scripts/set-active-plan.sh、scripts/check-complete.sh、scripts/plan-created.cjs（只读复核） | 其他脚本 |
| 文档 | skills/task-planner/SKILL.md、references/critical-rules.md、reference.md、registry 登记文件、级联 selftest 文件 | 其他技能/仓外文件 |
| 数据 | plans/**（仅归档 mv 操作与 INDEX 重生，Phase 8） | 删除任何计划文件 |
| 配置 | 无（零新 config 键；config.json 不动） | config.json 增删键 |

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------------------|------|----------|------|----------|
| CA-1 | skills/task-planner/scripts/archive-plan.sh | 新增 | 增量 | R1/R3 用户原话 | 新脚本（守卫+幂等+dry-run+批量） |
| CA-2 | skills/task-planner/SKILL.md 终验交付段（check-complete 行后） | 修改 | 增量 | R2「必须添加归档」 | 插入归档步骤行（≤6 行）+ 级联 SKILL 行号引用与行数钉 |
| CA-3 | skills/task-planner/references/critical-rules.md（Rule 76 后） | 修改 | 增量 | R2 制度化 | 新增 Rule 81 正文 |
| CA-4 | skills/task-planner/reference.md（规则摘要区） | 修改 | 增量 | 与 CA-3 同契 | Rule 81 摘要行（如有该区） |
| CA-5 | scripts/sync-todos.sh + scripts/resolve-plan-dir.sh | 修改 | 增量 | R3 联动正确性 | archive 子目录跳过 |
| CA-6 | scripts/set-active-plan.sh（gc/扫描面） | 修改 | 增量 | 同上 | archive 跳过 |
| CA-7 | scripts/check-complete.sh | 修改 | 增量 | 防复发 | [ARCHIVE-GATE] warn 段（complete 未归档计数提醒，恒 exit 0） |
| CA-8 | scripts/selftest-archive-plan.sh（新）+ registry 登记 | 新增 | 增量 | Rule 81.6 | 新 selftest + registry.tsv 行 |
| CA-9 | 级联 selftest（SKILL 行数钉/'1-76' epoch 计数/C56 行等） | 更新 | 替代（钉值演进，语义零改动） | 先例：v112→v155 十余次上调 | 按实测值演进 |
| CA-10 | plans/INDEX.md（Phase 8 重生） | 更新 | 替代（生成物） | 引用面适配后重跑 | sync-todos.sh --index |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档/知识库 | 既有完成流程与终验段 | skills/task-planner/SKILL.md:165-184 | 必读 | ☑（001-explore 已读） |
| 项目内部文档/知识库 | 既有归档先例 | plans/archive/（21 目录，commit 714c93b）+ scripts/plan-hygiene.sh | 必读 | ☑ |
| 项目内部文档/知识库 | 引用面脚本 | scripts/sync-todos.sh / resolve-plan-dir.sh / set-active-plan.sh / plan-created.cjs | 必读 | ☑（glob 细节 Phase 1 S1 补验） |
| 项目内部文档/知识库 | Rule 20.6 编号预留纪律 | plans/.rule-reservations.jsonl + critical-rules.md Rule 20.6 | 必读 | ☑（77-79 封存/80 预留已核） |
| 项目内部文档/知识库 | worktree 隔离 SOP | references/worktree-isolation.md | 必读 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: task-planner 完成任务后不归档计划目录，导致 plans/ 根无限堆积（实测约 110 个 completed）、索引失真、在途与历史混杂。补齐「完成→归档」机制并治理存量后，目录恢复「在途在根、历史在 archive/」的健康形态。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——机制+存量双交付即用户的全部诉求
- [x] 核心问题不解决，其他工作都白费吗？——是，堆积会持续（70+ 任务实证）
- [x] 核心问题的解决方法是清晰的、可执行的？——是：脚本+流程接线+守卫+批量（先例=714c93b/plan-created.cjs）

## 🔍 调研需求与检索计划（Rule 75.1）

| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|-------------|-------------|
| 全部 S-unit | LOCAL-ONLY | 本地 glob 形态/存量清单/selftest 入口 | 本地 grep+ls+脚本 | findings/进度清点 | 否（纯本地机械任务，现成方案=仓内 plan-hygiene.sh+plan-created.cjs 先例） |

## 🔍 证据面清单（Rule 58.1）

| 证据面 | 取证对象 | 取证方式 | 落盘锚 | 状态 |
|--------|---------|---------|--------|------|
| ① 自身样本 | 本仓 plans/ 114 目录堆积现状+完成流程末段 | 001-explore 只读勘查 | plans/task-v170.../subagent-state/001-explore.md | ☑ |
| ② 对标样本 | 历史唯一定向归档先例 714c93b（21 目录）+ plan-created.cjs archive 跳过先例 | git log + 脚本读码 | findings.md Research Findings | ☑ |
| ③ 外部约束 | 无（本任务为本地机制补齐，无外部依赖） | n/a | n/a | n/a（非归因类任务，根因已一手定位） |

## Current Phase

Phase 8

## Next Step

派发 S15 executor 批量归档（dry-run→实做显式 --root 主仓 plans→INDEX 重生→精确分期提交），随后主进程终验（VC 复验+委派率+rule land 81+交付总结+check-complete+自归档）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|------------------------|---------|
| Phase 1 | Agent 子代理 explore(mini) | 只读勘查+清单产出，隔离大目录扫描上下文 |
| Phase 2 | 主进程（计划系统文件维护，白名单②） | 设计定稿=计划文档撰写 |
| Phase 3 | Agent 子代理 code-assistant(haiku-1) | 单文件新脚本，按规格编码 |
| Phase 4 | Agent 子代理 code-assistant(haiku-1) ×6 S-unit（g-wire 并行组 S3-S6） | 多文件接线，S-unit 粒度可控 |
| Phase 5 | Agent 子代理 code-runner-agent(mini) | 全量 selftest 回归+实跑断言 |
| Phase 6 | Agent 子代理 code-reviewer | 代码组必走 CR Gate（Rule 42.7 命中） |
| Phase 7 | 主进程（git 编排白名单① + 机械对账③） | smart-merge-back+部署 diff |
| Phase 8 | Agent 子代理 executor(sonnet-1) 批量 + 主进程终验 | 存量归档机械执行；终验主责在主进程 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度（声明 g-wire 并行组，组内文件集不相交；未声明组串行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未用 /goal 锚定；/goal 为用户侧 harness 命令，技能层不可代调。

## Phases

### Phase 1: 勘查定案（完成流程/引用面细节/存量分类）
- [x] 01-explore 主体勘查回收（001-explore.md：完成流程无归档/先例 1 次/110 堆积/引用面清单）
- [x] S1 补验：sync-todos.sh:152 find 无深度限制（需修）/resolve-plan-dir.sh:121 glob 安全（无需修）；存量 completed/在途/辅助三类清单（53/62/5，主进程判定可归档口径=53+53=106）
- [x] findings.md 回填 + 分类清单落盘；v168 attest 哈希不符只读核验由主进程机械命令完成（结论见 findings Issues，仅报告用户不动该文件）
- **V-N:** VC-3, VC-6
- **Status:** complete
- **Executor:** explore
- **S-unit 表：**

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S1 | 补验 sync-todos/resolve-plan-dir glob 形态+产出三类存量清单 | explore(mini) | skills/task-planner/scripts/sync-todos.sh、resolve-plan-dir.sh（glob 扫描面读码） | 检查点含 glob 行号证据+三类计数表（completed/在途/辅助分列） | 15min | 2f/40l/15min | 无 | - | pending |

### Phase 2: 设计定稿（脚本契约/接入点/守卫集/Rule 81 条文）
- [x] archive-plan.sh 接口契约定稿（单任务/批量/dry-run/守卫/幂等/输出格式——全文入 progress.md Phase 2 段 + Decisions Made）
- [x] SKILL.md 接入点定稿（终验交付段 check-complete 行后，≤6 行）
- [x] 守卫集定稿：active 指针（全局+side）/.session-owner mtime<24h/Status 未全 complete（含 0 行）/已在 archive=幂等放行
- [x] Rule 81 子条款+级联面清单定稿；Decisions Made 补齐
- **V-N:** VC-1, VC-2, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护——Rule 25.3 白名单）

### Phase 3: 实现 archive-plan.sh
- [x] S2 编写 scripts/archive-plan.sh（bash -n+--help+fixture 五守卫场景+幂等+幂等批量 dry-run 零移动全过）
- [x] S-unit 自测：fixture 三守卫拒绝+幂等+单任务 mv
- [x] 事故闭环：S2 探针误归档主仓 task-v060 → 当次恢复，主进程独立核验干净（git status 该目录零变更、archive 无副本）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** code-assistant
- **S-unit 表：**

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S2 | 编写 archive-plan.sh（守卫+幂等+dry-run+批量） | code-assistant(haiku-1) | plans/task-v170-archive-completed-plans/task_plan.md（ Phase 2 定稿契约）；skills/task-planner/scripts/plan-hygiene.sh（风格参照） | bash -n exit 0；--help；对 fixture 三守卫 exit 1；幂等 exit 0 | 15min | 1f/95l/15min | 无 | Phase 2 | complete |

### Phase 4: 实现流程/规则/引用面/守护接线
- [ ] S3 SKILL.md 终验交付段接入归档步骤+Rule 81 摘要行+SKILL 行号引用级联+行数钉演进
- [ ] S4 critical-rules.md Rule 81 正文（插 Rule 76 后）+ reference.md 摘要行
- [ ] S5 sync-todos.sh + resolve-plan-dir.sh archive 跳过
- [ ] S6 set-active-plan.sh archive 跳过 + plan-created.cjs 既有跳过复核确认
- [x] S7 check-complete.sh [ARCHIVE-GATE] warn 段（恒 exit 0）
- [x] S8 selftest-archive-plan.sh 新脚本（含 fixture）
- [x] S9 registry 登记 + C56 合规行
- [x] S10a-S10f/S10g 级联执行：SKILL.md 行数钉 558→584（实值 559+25 先例）；SKILL.md:NNN 锚按实态校准；epoch '1-76'→'1-81'；SKILL.md Rule 81 摘要编号与 critical-rules 对齐
- [x] S10h-S10o/S10p epoch 宽容锚正则扩围（S11 全量回归证据驱动：15 脚本 16 断言 FAIL 全为 epoch 族，逐单元修完 Round 2 复跑 78/78 FAIL=0）
- **V-N:** VC-2, VC-4, VC-6
- **Status:** complete
- **Executor:** code-assistant
- **S-unit 表（g-wire 并行组：S3/S4/S5/S6 文件集不相交可并行；S7-S10f 依赖前置）**
<!-- [parallel-group:g-wire] = S3, S4, S5, S6（H3 标记：组内成员文件集两两不相交，独立性四问全 no） -->
<!-- [parallel-group:g-cascade] = S10a, S10b, S10c, S10d, S10e, S10f, S10g（H3 标记：七个单元文件集两两不相交；g-wire 已 complete 无写冲突） -->
<!-- [parallel-group:g-cascade2] = S10h, S10i, S10j, S10k, S10l, S10m, S10n, S10o（H3 标记：八个单元文件集两两不相交；修复证据=020-code-runner-s11.md 失败全集） -->

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S3 [parallel-group:g-wire] | SKILL.md 接入归档步骤+摘要行+行号级联+行数钉 | code-assistant(haiku-1) | skills/task-planner/SKILL.md（终验交付段） | 终验段出现归档步骤；级联引用无悬空；钉值 grep 一致 | 15min | 1f/25l/15min | 无 | Phase 3 | pending |
| S4 [parallel-group:g-wire] | critical-rules.md Rule 81 正文+reference.md 摘要 | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md（Rule 76 后插入位） | Rule 81 grep=1+；摘要级联一致 | 15min | 2f/60l/15min | 无 | Phase 3 | pending |
| S5 [parallel-group:g-wire] | sync-todos.sh+resolve-plan-dir.sh 跳过 archive | code-assistant(haiku-1) | skills/task-planner/scripts/sync-todos.sh、resolve-plan-dir.sh | archive 下 fixture 目录索引/解析零命中 | 15min | 2f/20l/15min | 无 | Phase 3 | pending |
| S6 [parallel-group:g-wire] | set-active-plan.sh 跳过 archive+plan-created.cjs 复核 | code-assistant(haiku-1) | skills/task-planner/scripts/set-active-plan.sh、plan-created.cjs | gc 不误扫 archive；plan-created 既有跳过复核留痕 | 15min | 2f/20l/15min | 无 | Phase 3 | pending |
| S7 | check-complete.sh [ARCHIVE-GATE] warn 段 | code-assistant(haiku-1) | scripts/check-complete.sh（complete 未归档计数提醒位） | ARCHIVE-GATE 存在且 warn 恒 exit 0（既有语义不破） | 15min | 1f/40l/15min | 无 | S2 | pending |
| S8 | selftest-archive-plan.sh 新脚本+fixture | code-assistant(haiku-1) | scripts/archive-plan.sh（S2 产物契约）；新文件 scripts/selftest-archive-plan.sh | 脚本全 PASS（守卫/幂等/dry-run/批量计数学） | 15min | 1f/65l/15min | 无 | S2 | pending |
| S9 | registry 登记 + C56 合规行 | code-assistant(haiku-1) | registry 登记文件（S8 查得路径）；plans/.rule-reservations.jsonl | registry 行在；C56 行含 Rule 81 引用 | 15min | 2f/30l/15min | 无 | S8 | pending |
| S10a [parallel-group:g-cascade] | 行数钉 558→584：batch-pilot+drift-check-subagent | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-batch-pilot.sh、selftest-drift-check-subagent.sh（S3 级联清单 B 项） | 两文件钉值=584 且实跑断言 PASS；SKILL.md 实值 559 有记录 | 15min | 2f/10l/15min | 无 | S9 | pending |
| S10b [parallel-group:g-cascade] | 行数钉 558→584：knowledge-brief+execution-stability | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-knowledge-brief.sh、selftest-execution-stability.sh（S3 级联清单 B 项） | 两文件钉值=584 且实跑断言 PASS | 15min | 2f/10l/15min | 无 | S9 | pending |
| S10c [parallel-group:g-cascade] | skill-collab 钉 584+research-first 锚/epoch | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-skill-collab.sh、selftest-research-first.sh（S3 清单 A7/B5/C 项） | skill-collab 钉=584；research-first SKILL.md 锚按实态校准+RF-07 epoch 演进；实跑 PASS | 15min | 2f/15l/15min | 无 | S9 | pending |
| S10d [parallel-group:g-cascade] | self-resolution+reliability-institution 锚校准 | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-self-resolution.sh、selftest-reliability-institution.sh（S3 清单 A1-A6） | 六处 SKILL.md 锚按实态校准（逐条 grep 验证目标行内容一致）；实跑 PASS | 15min | 2f/15l/15min | 无 | S9 | pending |
| S10e [parallel-group:g-cascade] | SKILL.md Rule 81 摘要编号对齐+epoch 字面 | code-assistant(haiku-1) | skills/task-planner/SKILL.md（:381 摘要行+epoch 字面 L313/L405 区） | 摘要编号与 critical-rules.md 81.x 权威一致；'1-76'→'1-81' 无非预期残留；实值行数如实记录 | 15min | 1f/10l/15min | 无 | S4,S9 | pending |
| S10f [parallel-group:g-cascade] | init-session+registry 锚校准 | code-assistant(haiku-1) | skills/task-planner/scripts/init-session.sh、scripts/selftest-registry.tsv（S3 清单 A8/A9） | 两处 SKILL.md 锚按实态校准（init L380 失真先修）；registry 行列不变只校准锚 | 15min | 2f/5l/15min | 无 | S9 | pending |

### Phase 5: 测试与实证（worktree 内）
- [x] S11 全量 selftest 回归：Round 1 FAIL=15/16 断言（epoch 族）→ g-cascade2 九单元定点修 → Round 2 `Total: 78 PASS=78 FAIL=0` EXIT=0 + smoke 17/0
- [x] S12 试点：task-v055-scheduler-enforce 实跑 ARCHIVED（commit ce89682）+ 幂等 ALREADY_ARCHIVED + 守卫 REJECT v170 exit 1
- [x] S13 批量 dry-run：候选 100+跳过 23（分类明细）+双采样过+零移动 md5 一致
- **V-N:** VC-1, VC-2, VC-3, VC-5, VC-6
- **Status:** complete
- **Executor:** code-runner-agent
- **S-unit 表：**

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S11 | 全量 selftest 回归 | code-runner-agent(mini) | skills/task-planner/tests/（selftest 套件入口，S10 后已确认） | FAIL=0 输出汇总 | 15min | 0f/0l/15min | 无 | S10 | pending |
| S12 | 试点归档 1 个真实 completed 目录+守卫实证 | code-runner-agent(mini) | scripts/archive-plan.sh；plans/task-v055-scheduler-enforce（试点候选，Phase 1 确认存在且 complete） | git status rename 行+幂等 ALREADY_ARCHIVED+三拒绝 exit 1 | 15min | 0f/0l/15min | 无 | S11 | pending |
| S13 | 批量 dry-run 双向对账+双采样 | code-runner-agent(mini) | scripts/archive-plan.sh --batch --dry-run（contract 见 Phase 2 定稿） | 候选数+跳过数+理由分类与 S1 清单一致；抽 2 预检全过 | 15min | 0f/0l/15min | 无 | S12 | pending |

### Phase 6: Code Review Gate
- [x] S14 委派 code-reviewer 对 worktree diff 全量审查（.sh+SKILL.md 逻辑变更面）
- [x] CR 结论 CHANGES_REQUESTED×1（_ag_ptr_hit 泄漏）→ fix-phase de1eed1 → 复评 4/4 APPROVED（036：78/78 独立复跑）
- **V-N:** VC-1, VC-4, VC-5（CR 覆盖面对 VC 的再确认）
- **Status:** complete
- **Executor:** code-reviewer
- **S-unit 表：**

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|------|
| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S14 | CR 全量审查 worktree diff | code-reviewer | worktree 路径+git diff 范围（prompt 附绝对路径与 VC 表） | APPROVED 或意见清单全部闭环 | 15min | 0f/0l/15min | 无 | S13 | pending |

### Phase 7: 合并回 master + 部署对账
- [x] master 前进（v169 Rule 80 e82dd42）→ worktree merge master 并集解（1651371：17 selftest epoch 冲突取 81 态保留 80 史+C56 撞号→Rule 81 行改 C57）+SL-05 镜像级联修复（d0874bc）；合并态回归 79/79 FAIL=0
- [x] smart-merge-back.sh --deploy：merge 41e62f6（--no-ff）+全部部署位 IDENTICAL
- [x] 清理 worktree+branch（11.3 合约 5，他人 worktree 未动）
- [x] 主仓 Read 关键文件复验（archive-plan.sh/selftest-archive-plan.sh/SKILL.md:185 归档步骤/C57/Rule 81 均已在位）
- **V-N:** VC-5, VC-7
- **Status:** complete
- **Executor:** 主进程（例外理由:① git/worktree 编排——Rule 25.3 白名单）

### Phase 8: 存量批量归档 + INDEX 重生 + 终验交付
- [x] S15 executor 批量实做：dry-run（候选 101+跳过分类校验）→实做 `BATCH ok=101 fail=0`→INDEX 重生（in_progress=7 pending=1 complete=6）→精确分期提交 1bd3d3d（2109 files，并行会话三项未提交变更保全+v152 rename 对补录 amend）
- [x] Batch Report 八字段回填（failure_rate=0%，回滚点 1bd3d3d^）
- [x] VC 复验+委派率统计+3-File Gate+指针清理+Rule 81 land+交付总结+check-complete 终跑+自归档
- **V-N:** VC-1, VC-2, VC-3, VC-6
- **Status:** complete
- **Executor:** executor（例外理由:终验簿记与合并编排主进程直做=①git 编排+②计划系统文件维护；S15 批量机械执行派 executor）
- **S-unit 表：**

| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|------|
| ID | 目标(≤1 句) | 执行体 | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|--------|----------------|--------------|---------|-----------|---------|---------|------|
| S10h [parallel-group:g-cascade2] | absorption-discipline+capability-persistence epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-absorption-discipline.sh、scripts/selftest-capability-persistence.sh（020 明细第 1-2 条） | 两脚本实跑 PASS；扩围含 81 且负样本 82/90 不过 | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10i [parallel-group:g-cascade2] | context-pressure+drift-check-subagent epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-context-pressure.sh、scripts/selftest-drift-check-subagent.sh（020 明细第 3-4 条） | 两脚本实跑 PASS；DCS-11 40-(69|71|73|7[4-9])→含 8[01] | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10j [parallel-group:g-cascade2] | error-loop+execution-honesty epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-error-loop.sh、scripts/selftest-execution-honesty.sh（020 明细第 5-6 条） | 两脚本实跑 PASS；EH-09 40-(5[3-9]|6[0-9]|7[0-6])→含 7[0-9]|8[01] | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10k [parallel-group:g-cascade2] | iteration-persistence+lane-advancement epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-iteration-persistence.sh、scripts/selftest-lane-advancement.sh（020 明细第 7-8 条） | 两脚本实跑 PASS；40-[567][0-9]→含 8[01] 类 | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10l [parallel-group:g-cascade2] | reflect-verify+requirement-coverage epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-reflect-verify.sh、scripts/selftest-requirement-coverage.sh（020 明细第 9-10 条） | 两脚本实跑 PASS；1-7[4-9] 类→含 8[01] | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10m [parallel-group:g-cascade2] | root-resolution+skill-split epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-root-resolution.sh、scripts/selftest-skill-split.sh（020 明细第 11-12 条） | 两脚本实跑 PASS；RR-16 40-(…7[0-6])→含 8[01]；T-锚 1-3..7→含 81 | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10n [parallel-group:g-cascade2] | summary-readability+tool-selection epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-summary-readability.sh、scripts/selftest-tool-selection.sh（020 明细第 13-15 条） | 两脚本实跑 PASS；SRV-03 偏 1-7[4-9]≥3→含 81；SRV-12 随 9 级联脚本全绿自愈 | 15min | 2f/8l/15min | 无 | S11 | pending |
| S10o [parallel-group:g-cascade2] | selftest-veto VT-10 epoch 扩围 | code-assistant(haiku-1) | scripts/selftest-veto.sh（020 明细第 16 条） | 实跑 PASS；扩围含 81 且负样本 82/90 不过 | 15min | 1f/5l/15min | 无 | S11 | pending |
| S15 | 批量实做+INDEX 重生 | executor(sonnet-1) | 主仓 plans/（Phase 5 dry-run 清单主仓同源对账）+scripts/archive-plan.sh | 实做必须显式 --root（禁依赖缺省推导）；归档数=dry-run 候选数；INDEX 重生；git status 仅 archive/ 与 INDEX | 15min | 0f/0l/15min | 无 | Phase 7 | pending |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|------|
| `conflict_scan` | `risk`（信号①7 文件未提交含 plans/INDEX.md——并行会话 v168/v169 在途；② 1 个额外 worktree=task-v169 活跃；③ 2 个遗留 wt 分支；④ 9 个未完成任务） |
| `isolation` | `worktree`（实现类默认首选；主仓未提交 INDEX.md 与本任务重叠 → 机制实现全部进 worktree，存量批量归档推迟到合并回后主仓执行，规避未提交变更冲突） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v170-archive-completed-plans` |
| `branch` | `wt/task-v170-archive-completed-plans` |
| `merge_back` | `merged(41e62f6)` |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作 |
|-------|---------|---|---|---|-----|-------------|
| Phase 3 S2 | 脚本守卫逻辑漏判（误归档在途） | 9 | 3 | 4 | 108 | 22.3①-②：dry-run 默认+批量无 --dry-run 需双参数；fixture 三守卫全过才进 Phase 5；CR 复核守卫面 |
| Phase 4 S3 | SKILL.md 行号引用级联漏改（悬空锚/行数钉 FAIL） | 7 | 6 | 5 | 210 | 22.3②：拆细重派 grep 全部 SKILL.md 行号引用逐条核对；全量 selftest FAIL=0 为硬门；级联清单先 grep 后改 |
| Phase 5 S11 | 全量 selftest 既有 FAIL 掩盖新 FAIL | 8 | 4 | 3 | 96 | 先跑基线（worktree 创建后即跑）留存对照；FAIL 分类为本任务引入 vs 存量 |
| Phase 8 S15 | 批量归档误伤在途任务/INDEX 失真 | 9 | 2 | 3 | 54 | dry-run 清单锁定候选集+试点先行（S12）+双采样（S13）+失败率熔断回滚 |
| Phase 7 | 合并与并行会话未提交变更冲突 | 6 | 4 | 4 | 96 | smart-merge-back 预检；冲突时并集解（先例多次）；本任务机制改动不碰 plans/ 数据面 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-11 | TodoWrite 已建 |
| Phase 2 | ☑ | - | |
| Phase 3 | ☑ | - | |
| Phase 4 | ☑ | - | |
| Phase 5 | ☑ | - | |
| Phase 6 | ☑ | - | |
| Phase 7 | ☑ | - | |
| Phase 8 | ☑ | - | |

## Key Questions

1. sync-todos.sh / resolve-plan-dir.sh / set-active-plan.sh 的 plans 扫描 glob 精确形态（plans/* 还是递归 find）？→ Phase 1 S1
2. archive/ 是否要保留 .plan-attestation 等会话态文件？→ Phase 2 定：保留全量目录内容（git mv 不动内部），旧 archive 21 目录无 attestation 是历史形态不追溯
3. 存量中 Status=complete 但带 .session-owner 或在 active 指针上的目录有哪些？→ Phase 1 S1 列出，Phase 8 逐一致跳过

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| interaction_mode=silent | 用户指令明确完整无分叉；v168/v169 同场景先例；D6 硬停点保留 |
| new_rule=81 | 77/78/79 封存分支未 land、80 被 v169 预留；Rule 20.6 attest 查重兜底 |
| 归档形态=git mv plans/<id> → plans/archive/<id>（内部文件不动） | 既有约定（21 目录先例）；git 全跟踪→可 revert 回退；plan-created.cjs 已有 archive 跳过先例 |
| 守卫 fail-closed：active/session-owner/非 complete 一律 exit 1 | 误归档在途=数据面事故；幂等仅对「已在 archive」放行 |
| [ARCHIVE-GATE]=warn 不阻断 | check-complete.sh 恒 exit 0 语义不破；提醒而非新硬门，避免既有流程误伤 |
| 机制实现进 worktree，存量批量归档在合并回后主仓执行 | 主仓 plans/INDEX.md 有并行会话未提交变更（信号①），data 面改动避开合并冲突 |
| INDEX 只列在根任务，archive 任务退出 INDEX | 用户诉求=根目录只留在途；archive/ 目录+git 历史为完整索引 |
| archive-plan.sh CLI 契约（Phase 2 定稿，全文见 progress.md Phase 2 段） | 子命令=单任务 `<id>` / `--batch [--dry-run]` / `--help`；`--root` 覆盖 plans 根（默认按脚本位置推导仓根）；输出=ARCHIVE/SKIP(<reason>)/FAIL 行+BATCH total/ok/skip/fail 汇总 |
| 守卫判据=task_plan.md 中全部 `- **Status:**` 行均为 complete（计数相等且总数>0） | 禁 `grep -m1`：mid-task 早期 Phase 已 complete 会误放行（实证风险）；v146 无 Status 行→0 行判异常拒绝，fail-closed |
| owner 守卫=`.session-owner` 在场且 mtime<24h 才拦 | 陈旧 owner（32 天前实证）永久拦截会使 53 个完成任务无法归档，违背 R3；TTL 与 side 指针 24h 惯例一致 |
| git 跟踪目录用 git mv，未跟踪（v162）用 mv 兜底 | plans/ 任务目录基本全跟踪（ls-files 实证）；兜底保证 untracked 也可归档，回退=git 可逆或 mv 回移 |
| SKILL.md 接入=终验交付段 check-complete 行后插 3 行+规则摘要 1 行 | 位置最晚化，行号级联面最小化 |
| [ARCHIVE-GATE]=check-complete warn 段恒 exit 0 | 既有 exit 语义不破；提醒存量而非阻断交付 |
| S10 按 Rule 59.1 发现期重拆为 S10a-S10f（每单元 ≤2 文件） | S3 级联清单实测涉及 11 文件（5 钉值+6 锚/epoch），超原声明 2f；重拆后 dispatching 为 g-cascade 并行组（文件集两两不相交） |
| S11 回归证据驱动再拆 S10h-S10o（g-cascade2 并行组） | 020-code-runner-s11.md 全量回归 78 脚本 FAIL=15/16 断言全 epoch 族；按 ≤2 文件拆 8 单元定点修；修完全量复跑由 S12 承载 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （无） | 1 | - | → progress.md Error Log |

## Notes

- 每 Phase complete 前跑 check-3file-gate.sh + drift-checker 派发（Rule 64.1 三件套）
- 批量操作按 Rule 18：dry-run→试点→双采样→熔断
- 主仓 CWD 不动，worktree 操作全部用绝对路径

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-11 23:45 | DRIFT（003-drift-check-p1：Phase 1 簿记未同步+v168 核验缺证据；acceptance 3/4） | VC-3/VC-6 | 机械修复：已翻 Phase 1 complete/Current Phase 2/Next Step；v168 哈希不符已核验（a35c941f≠dc600b0b，锁定后 7min 被改，非本会话所为，仅报告不动文件）；findings §6 已如实登记 53+53 修正 | 
| 2026-10-12 00:20 | ALIGNED-with-fix（005-drift-check-p3：acceptance 4/5，仅(e)机械簿记滞后：Current Phase/Next Step/S2 行未随 Phase 3 翻转） | VC-1/VC-2 | 已当次修复（Current Phase→4/Next Step→g-wire 派发/S2→complete）；并吸收观察项(d)：S15 验收列补「实做显式 --root」；教训复现=同 003 模式，Phase complete 时三处（状态/Current/Next）必须同源翻转 | 
| 2026-10-12 02:20 | ALIGNED（033-drift-check-p45：5/5 全过；实测纠正簿记 worktree commits 17→24） | VC-1/VC-4/VC-5 | Phase 4/5 完成态获独立证据确认（78/78 FAIL=0+试点 ce89682+100 候选对账闭合）；簿记失实已当次更正（Rule 54）；进 Phase 6 CR Gate | 

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

| 字段 | 值 |
|------|-----|
| `total` | 122（batch 枚举目录数：候选 101+跳过 21） |
| `success` | 101（含 pilot 后全量；archive/ 总数 123=旧 22+新 101） |
| `failed` | 0 |
| `failure_rate` | 0%（≤5% 通过） |
| `sampled_pass` | 3（试点 v055 实跑+S13 双采样 v056/v057：7/7 complete+owner 陈旧+无指针） |
| `sampled_fail` | 0 |
| `pre_check` | Q1:否（git revert 1bd3d3d 可回滚）/Q2:有（dry-run 锁定候选+试点先行）/Q3:能（archive-plan.sh 幂等可复跑） |
| `rollback_point` | 1bd3d3d^（=41e62f6，revert 1bd3d3d 即恢复原状） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 5 / 8（Phase 1 explore、3 code-assistant、4 code-assistant、5 code-runner-agent、6 code-reviewer；check-delegation.sh stats 实测） |
| 主进程直做 Phase 清单 | Phase 2（② 计划系统文件维护）；Phase 7（① git/worktree 编排）；Phase 8（① git 编排+② 计划系统文件维护；S15 批量已派 executor） |
| 委派率 | 0.625（<floor 0.7，但主进程直做理由全部命中 Rule 25.3 白名单 → WHITELIST-EXEMPT 放行；stats verdict=ok violations=[] 实证） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 10-11 22:10 | explore | 主体勘查（完成流程/先例/堆积/引用面） | done | 无归档步骤；先例 1 次；110 堆积；4 脚本硬引用 plans/ | 001-explore.md | findings.md Research Findings | subagent-state/001-explore.md | 无写工具返回值固化/0/☑ |
| 2 | 10-11 22:40 | explore | S1 glob 补验+三类清单 | done | L152 find 无深度限制需修/L121 glob 安全；候选 53/禁 62/辅助 5；v162/v168/v169 归属判定 | findings.md §6 | findings.md §6 | subagent-state/002-explore-s1.md（返回值固化） | 同上/0/☑ |
| 3 | 10-11 23:40 | general-purpose | Phase 1 偏移检查（drift-checker 角色降级改派） | done | DRIFT（簿记未同步+v168 核验缺证据 3/4）→已机械修复 | 003-drift-check-p1.md | progress.md Phase 1 | subagent-state/003-drift-check-p1.md | provider 拒改派/0/☑ |
| 4 | 10-12 00:05 | code-assistant | S2 archive-plan.sh 编码 | done | 6/6 验收；commit 05ccb12；事故（误归档 v060）当次恢复 | 004-code-assistant-s2.md | findings.md §8 | subagent-state/004-code-assistant-s2.md | 事故闭环/0/☑ |
| 5 | 10-12 00:19 | general-purpose | Phase 3 偏移检查（降级改派） | done | ALIGNED-with-fix（4/5，簿记滞后已修） | 005-drift-check-p3.md | progress.md Phase 3 | subagent-state/005-drift-check-p3.md | provider 拒改派/0/☑ |
| 6 | 10-12 00:44 | code-assistant | S3 SKILL.md 接入归档步骤+级联清单 | done | :185 归档步骤+Rule 81 摘要；commit 622508a；级联清单产出 | 006-code-assistant-s3.md | findings.md §12 | subagent-state/006-code-assistant-s3.md | g-wire 组/0/☑ |
| 7 | 10-12 00:52 | code-assistant | S4 Rule 81 正文 | done | critical-rules.md:1049 六子条；commit 9363e8d；reference.md 合法跳过 | 007-code-assistant-s4.md | findings.md §12 | subagent-state/007-code-assistant-s4.md | g-wire 组/0/☑ |
| 8 | 10-12 00:50 | code-assistant | S5 sync-todos/resolve-plan-dir archive 跳过 | done | :158 find 排除+:129 防御；commit 29c968a | 008-code-assistant-s5.md | findings.md §12 | subagent-state/008-code-assistant-s5.md | g-wire 组/0/☑ |
| 9 | 10-12 00:51 | code-assistant | S6 set-active-plan 跳过+plan-created 复核 | done | :239-243 F3 跳过；复核留痕；commit 4122454 | 009-code-assistant-s6.md | findings.md §12 | subagent-state/009-code-assistant-s6.md | g-wire 组/0/☑ |
| 10 | 10-12 01:00 | code-assistant | S7 check-complete ARCHIVE-GATE | done | :1606-1660 warn 恒 exit 0；commit 77e4c65 | 010-code-assistant-s7.md | findings.md §12 | subagent-state/010-code-assistant-s7.md | /0/☑ |
| 11 | 10-12 01:20 | code-assistant | S8 selftest-archive-plan.sh | done | 16/16 PASS；commit 8f8a987（首派空返重派一次） | 011-code-assistant-s8.md | findings.md §12 | subagent-state/011-code-assistant-s8.md | retry 1/1/☑ |
| 12 | 10-12 01:30 | code-assistant | S9 registry+C56 | done | registry.tsv:79+SKILL.md:247 C56；commit de7eb65 | 012-code-assistant-s9.md | findings.md §12 | subagent-state/012-code-assistant-s9.md | /0/☑ |
| 13 | 10-12 01:35 | code-assistant | S10a 钉 558→584 | done | BP-08/DCS-19 转 PASS；commit 6bf89a8；负报告 DCS-11 缺口 | 013-code-assistant-s10a.md | findings.md §12 | subagent-state/013-code-assistant-s10a.md | g-cascade 组/0/☑ |
| 14 | 10-12 01:36 | code-assistant | S10b 钉 558→584 | done | kb 16/16+es 19/19；commit 64523c9 | 014-code-assistant-s10b.md | findings.md §12 | subagent-state/014-code-assistant-s10b.md | g-cascade 组/0/☑ |
| 15 | 10-12 01:38 | code-assistant | S10c skill-collab 钉+research-first 锚/epoch | done | 25/25+12/12；commit 6c9186a | 015-code-assistant-s10c.md | findings.md §12 | subagent-state/015-code-assistant-s10c.md | g-cascade 组/0/☑ |
| 16 | 10-12 01:40 | code-assistant | S10d 六锚按实态校准 | done | 266/278/288 族→314；commit 7ebc030；负报告 epoch 缺口 | 016-code-assistant-s10d.md | findings.md §12 | subagent-state/016-code-assistant-s10d.md | g-cascade 组/0/☑ |
| 17 | 10-12 01:42 | code-assistant | S10e SKILL 摘要编号对齐+epoch | done | :382 对齐+:9/314/406 epoch 1-81；commit dabf466 | 017-code-assistant-s10e.md | findings.md §12 | subagent-state/017-code-assistant-s10e.md | g-cascade 组/0/☑ |
| 18 | 10-12 01:44 | code-assistant | S10f init/registry 锚校准 | done | init:381-382→60；registry:225/356；commit 52ac495 | 018-code-assistant-s10f.md | findings.md §12 | subagent-state/018-code-assistant-s10f.md | g-cascade 组/0/☑ |
| 19 | 10-12 01:46 | code-assistant | S10g epoch 正则扩围 SR/RI | done | SR-07/08/R-09 转 PASS；commit d35553f；负样本验证 | 019-code-assistant-s10g.md | findings.md §12 | subagent-state/019-code-assistant-s10g.md | g-cascade 组/0/☑ |
| 20 | 10-12 01:50 | code-runner-agent | S11 全量回归 Round 1 | done | 78 脚本 FAIL=15/16 断言（epoch 族，base 对照实证引入） | 020-code-runner-s11.md | findings.md §12 | subagent-state/020-code-runner-s11.md | 只读/0/☑ |
| 21 | 10-12 02:00 | code-assistant | S10h absorption+capability 扩围 | done | AD-04/CP-05 转 PASS；commit fdc56b5 | 021-code-assistant-s10h.md | findings.md §12 | subagent-state/021-code-assistant-s10h.md | g-cascade2 组/0/☑ |
| 22 | 10-12 02:01 | code-assistant | S10i context-pressure+drift-check 扩围 | done | CP-07/DCS-11 转 PASS；commit 53176e1 | 022-code-assistant-s10i.md | findings.md §12 | subagent-state/022-code-assistant-s10i.md | g-cascade2 组/0/☑ |
| 23 | 10-12 02:02 | code-assistant | S10j error-loop+execution-honesty 扩围 | done | EL-11/EH-09 转 PASS；commit 987689a | 023-code-assistant-s10j.md | findings.md §12 | subagent-state/023-code-assistant-s10j.md | g-cascade2 组/0/☑ |
| 24 | 10-12 02:03 | code-assistant | S10k iteration+lane 扩围 | done | IP-12/LA-12 转 PASS；commit 6042df1 | 024-code-assistant-s10k.md | findings.md §12 | subagent-state/024-code-assistant-s10k.md | g-cascade2 组/0/☑ |
| 25 | 10-12 02:04 | code-assistant | S10l reflect-verify+requirement-coverage 扩围 | done | RV-10/RC-11 转 PASS；commit 9497495 | 025-code-assistant-s10l.md | findings.md §12 | subagent-state/025-code-assistant-s10l.md | g-cascade2 组/0/☑ |
| 26 | 10-12 02:05 | code-assistant | S10m root-resolution+skill-split 扩围 | done | RR-16/T-锚转 PASS；commit 8647044 | 026-code-assistant-s10m.md | findings.md §12 | subagent-state/026-code-assistant-s10m.md | g-cascade2 组/0/☑ |
| 27 | 10-12 02:06 | code-assistant | S10n summary-readability+tool-selection 扩围 | done | SRV-03/TS-05 转 PASS；SRV-12 连带 AD-12；commit ebe21ac | 027-code-assistant-s10n.md | findings.md §12 | subagent-state/027-code-assistant-s10n.md | g-cascade2 组/0/☑ |
| 28 | 10-12 02:07 | code-assistant | S10o veto 扩围 | done | VT-10 转 PASS；commit 730c727 | 028-code-assistant-s10o.md | findings.md §12 | subagent-state/028-code-assistant-s10o.md | g-cascade2 组/0/☑ |
| 29 | 10-12 02:10 | code-assistant | S10p AD-12 pin 连带修复 | done | AD-12 转 PASS 14/14；commit ebdf4f4 | 029-code-assistant-s10p.md | findings.md §12 | subagent-state/029-code-assistant-s10p.md | g-cascade2 组/0/☑ |
| 30 | 10-12 02:15 | code-runner-agent | S11 Round 2 全量复跑 | done | `Total: 78 PASS=78 FAIL=0`+smoke 17/0 | 030-code-runner-s11r2.md | findings.md §12 | subagent-state/030-code-runner-s11r2.md | 只读/0/☑ |
| 31 | 10-12 02:20 | executor | S12 试点归档+守卫实证 | done | v055 ARCHIVED（ce89682）+幂等+REJECT v170 | 031-executor-s12.md | findings.md §12 | subagent-state/031-executor-s12.md | /0/☑ |
| 32 | 10-12 02:25 | code-runner-agent | S13 全量 dry-run 移交 | done | 候选 100+跳过分类+双采样+零移动 md5 | 032-code-runner-s13.md | findings.md §12 | subagent-state/032-code-runner-s13.md | 只读/0/☑ |
| 33 | 10-12 02:30 | general-purpose | Phase 4/5 偏移检查（降级改派） | done | ALIGNED 5/5；纠正 commits 17→24 | 033-drift-check-p45.md | progress.md Phase 5 | subagent-state/033-drift-check-p45.md | provider 拒改派/0/☑ |
| 34 | 10-12 03:00 | code-reviewer | S14 CR 全量审查 | done | CHANGES_REQUESTED×1（_ag_ptr_hit 泄漏 blocker） | 034-code-reviewer-s14.md | progress.md Phase 6 | subagent-state/034-code-reviewer-s14.md | /0/☑ |
| 35 | 10-12 03:10 | code-assistant | CR fix-phase _ag_ptr_hit 复位 | done | :1626 复位；双 fixture 正确；commit de1eed1 | 035-code-assistant-crfix1.md | progress.md Phase 6 | subagent-state/035-code-assistant-crfix1.md | CR 返工/0/☑ |
| 36 | 10-12 03:20 | code-reviewer | CR 复评 | done | 4/4 APPROVED；独立全量复跑 78/78 | 036-code-reviewer-s14r2.md | progress.md Phase 6 | subagent-state/036-code-reviewer-s14r2.md | /0/☑ |
| 37 | 10-12 03:30 | executor | merge 冲突并集解（17 selftest） | done | 14 文件清除+三文件收尾（上下文爆断链移交） | 037-executor-merge-union.md | progress.md Phase 7 | subagent-state/037-executor-merge-union.md | 输出截断改派/0/☑ |
| 38 | 10-12 03:35 | executor | merge 收尾三文件（SKILL/registry/critical-rules） | done | C56→C57 防撞号；merge 1651371 | 037-executor-merge-union.md | progress.md Phase 7 | subagent-state/037-executor-merge-union.md | /0/☑ |
| 39 | 10-12 03:45 | code-assistant | SL-05 镜像级联修复 | done | 1-8[01] 尾边界；10/10；commit d0874bc | 038-code-assistant-sl05.md | progress.md Phase 7 | subagent-state/038-code-assistant-sl05.md | /0/☑ |
| 40 | 10-12 04:00 | general-purpose | Phase 7 偏移检查（降级改派） | done | ALIGNED 5/5；C57/C56 并存实证 | 039-drift-check-p7.md | progress.md Phase 7 | subagent-state/039-drift-check-p7.md | provider 拒改派/0/☑ |
| 41 | 10-12 04:40 | executor | S15 存量批量归档+INDEX 重生 | done | ok=101 fail=0；INDEX 重生；commit 1bd3d3d；并行变更保全 | 040-executor-s15.md | findings.md §13 | subagent-state/040-executor-s15.md | 任务书模式/0/☑ |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底
- Rule 34.3②: 终验按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 沉淀理由 / 不沉淀理由（二选一必填）→ plan-template-kit 卫星 SOP
