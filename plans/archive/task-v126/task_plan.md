# Task Plan: Rule 49 单元线多路并行推进（已验收单元前置满足即推进，不等批）

<!-- template_type: rule-enhancement -->
<!-- plan_tier: standard -->

## Goal
落地 Rule 49「单元线多路并行推进」（49.1-49.5 五子条）：已验收生产单元的前置条件满足即推进其后续工序 S-unit（跨 Phase 前移合法、不等同批其他单元），多路并行推进且互不干扰（继承 21.4 独立性四问+汇合点强串行+22.4a 单写者）；SKILL.md 联动 4 锚 + selftest-lane-advancement.sh 守护，全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位。

## 核心问题定义（T1/T2 解构）
- **问题是什么**：现行执行模型是「Phase 同步栅栏」——Phase N 全部 S-unit 完成才进 Phase N+1；多单元任务（如多段落视频：段落A/B/C 各有 写词→生成→质检→组装 工序链）中，段落A 已通过质检验收、其后续工序（组装准备）前置已满足，但仍被迫等待仍在修生成问题的段落B，造成已通过单元的推进空闲。
- **本质是什么（5 Whys）**：①为何慢？已通过单元不能先行。②为何不能先行？Phase 翻转 complete 是派发下一 Phase 的隐式前置。③为何成为前置？Rule 21.4 只定义了「同批次内并行」（空间并行），未定义「跨 Phase 按依赖推进」（流水线推进）；执行循环步骤 2.5 派发点绑定在「当前 Phase 开启后」。④为何没定义？此前串行铁律时代（09-12）连批次内并行都禁止；10-02 演进只解决了批次内并行。⑤根因：执行模型缺少「单元线（lane）」这个中间抽象——单元×工序构成 DAG，推进单位应是「单元线的下一工序」而非「下一 Phase 的全部工序」。
- **解决方案**：新增 Rule 49 单元线推进层——lane = 可枚举生产单元 × 序贯工序链；推进三条件（三证据验收通过 + 目标工序前置产物在位 + 独立性四问通过）全满足即可立即派发该 lane 下一工序，登记后跨 Phase 前移合法；Phase complete 翻转语义不变（不弱化既有门控）。
- **执行方案**：critical-rules.md 追加 Rule 49 块（纯增量，Rule 36.5）→ SKILL.md 联动 4 锚（净增 ≤10 行）→ 新 selftest 静态守护 → 全量回归 → 合并部署。

## 用户原始诉求（2026-10-03）
「优化技能的运行策略 增强并行运行——在某些任务已经通过并且推进不影响其他前提下可以推进并行运行。比如：生成多段落视频，其中多段落已经前置条件满足，可以在解决其他段落问题时候，推进已经审核通过段落的前进。核心就是推进运行，确保不互相干扰前提下可以多路并行推进。」

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本） |
| 对齐审查 | alignment-review（Rule 42.6.2 标准收尾） |
| 自动超时默认项 | 无 2+ 选项询问点（设计已定，无低区分度分叉）；豁免登记 |
| 质量审查工具 | code-review skill（42.2 四级检测：用户级在位，登记即可） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|---------|---------|
| VC-1 | Rule 49 五子条完整（49.1 适用与单元线模型/49.2 推进三条件/49.3 推进动作与登记/49.4 不干扰边界/49.5 机制零新键），范式对齐 Rule 46/47 | Read 条款块 + grep 各子条锚（49.1-49.5） | `references/critical-rules.md` |
| VC-2 | SKILL.md 联动 4 锚：①Critical Rules 摘要行含 Rule 49 ②References 表括号追加 `/49`（主锚 `Rules 1-39` 字面不动，`grep -c 'Rules 1-39'`=2 且 `'1-40'`=0 不变）③执行循环推进检查点（验收通过后查推进三条件）④合规清单 C34；净增 ≤10 行 | grep 4 锚 + SR-07 字面锚复测 + wc -l 前后对比 | `SKILL.md` / selftest-self-resolution.sh 输出 |
| VC-3 | selftest-lane-advancement.sh 新建全 PASS（≥8 断言：五子条文本锚+SKILL 联动锚+零新键+负断言）+ 全量 45 脚本回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数**） | `for f in scripts/selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-4 | Code Review Gate APPROVED + alignment-review 对齐审查完成（变更记录三要素落盘） | CR 输出 + 变更记录 | verification.md / delivery-summary |
| VC-5 | 合并回 master（--no-ff）+ 部署 3 位 IDENTICAL + worktree/分支清理 + 簿记（INDEX/memory） | smart-merge-back --deploy 输出 + git worktree list 复验 | progress.md / ledger |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（Rule 48 块后追加 Rule 49 块，纯增量） | 改既有规则语义（21.4/46/47 原文零改动，49 只引用） |
| 配置 | 无（零新 config 键，46.5/47.4 同范式） | 动 config.json |
| 脚本 | 新建 `scripts/selftest-lane-advancement.sh` | 改其他脚本（锚级联例外：仅当基线断言意外 FAIL 时最小修复并登记） |
| SKILL | `SKILL.md`（净增 ≤10 行：行位替换优先） | 大段新增；动 `Rules 1-39` 主锚字面 |
| 文档 | 无其他文档 | — |

**强制约束**:
- Rule 编号接续 48 → **49**；合规清单接续 C33 → **C34**
- ⚠️ 锚级联预扫：改 SKILL.md 前先 `grep -rn "Rules 1-" scripts/*.sh` + `grep -rn "Rule 48\|47\.4\|49" scripts/*.sh` 扫全部锚断言，确认主锚不受影响（v121 预扩 1-4[5-9] + 括号追加范式双重保护，预期零级联，实测确认）
- SKILL.md 行数纪律：wc -l 前后对比（447 → ≤457）；行数上限断言（selftest-knowledge-brief T2b）在 Phase 1 基线确认当前阈值
- 派发契约：executor prompt 必含计划三文件绝对路径 + 8 字段标签（acceptance:/checkpoint:/plan_dir:/scope:/model_tier:/parallel:/resume_from:/handoff_seq，check-dispatch.sh 逐字校验）

## 🔀 隔离决策
- **isolation: worktree**（宪法 §十一 11.1.1 命中：修改 `~/.zcode/skills/**` 源仓 `skills/task-planner/**`）
- 路径：`/home/terry/task-planner-skill-worktrees/task-v126`，分支 `wt/task-v126`
- 计划文档留主仓 `plans/task-v126/`；子代理 prompt 全部自带 worktree 绝对路径
- 主仓现状核查：未提交变更均为 plans/ 簿记文件，与任务范围（skills/task-planner/**）零重叠 → 满足合并前提 11.3.3

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | 主进程（白名单① git 编排）+ bash 基线 | worktree 建立/selftest 基线是 git+机械操作 |
| Phase 2 | Agent executor(sonnet-1) ×2（并行组） | 判断型条款写作；S-unit 独立性四问通过（文件集不相交） |
| Phase 3 | Agent executor(sonnet-1) | selftest 脚本写作 |
| Phase 4 | code-runner-agent(mini) + code-review skill | 机器回归+CR Gate |
| Phase 5 | 主进程（白名单①）+ smart-merge-back --deploy | 合并部署是 git 编排 |
- workflow 编排判定：不命中（无 /workflow 点名，链路短，Agent 派发足够）——按 21.4 调度
- /goal 对齐判定：N/A（无 /goal 目标在案）

## 📐 Lane 状态表（Rule 49 首个 dogfood 场景说明）
本任务 Phase 1→5 为链式依赖（无并行单元线），不启用跨 Phase 前移；Phase 2 内 S1/S2 为同批次并行组（21.4 既有语义），非 lane 推进。Rule 49 生效面=未来媒体族/多单元任务。

## Phases

### Phase 1: worktree 隔离与基线
- **Status:** complete（2026-10-04；基线 44 脚本 666/0，锚位五处定位，F2 约束登记 pg-p2 撤销）
- **V-N:** VC-3、VC-2（Phase 段勾选见 verification.md）
- worktree 建立 + 全量 selftest 基线（主进程逐 Total 行求和，预期 44 脚本全 PASS）+ 锚级联预扫（Rules 1- 锚/Rule 48 块尾定位/SKILL 行数断言阈值确认）
- **Executor:** 主进程（白名单① git/worktree 编排 + ③ 机械验证命令）

### Phase 2: Rule 49 条款落地 + SKILL 联动
- **Status:** complete（2026-10-04；commit ae5071c；守卫往返 5 次实录 F4 摩擦）
- **V-N:** VC-1、VC-2
<!-- parallel_groups: 无（撤销 pg-p2 声明）——F2 串行槽锁实证约束（2026-10-04 复盘：check-dispatch .dispatch-inflight age<120s 对同批并行组派发直接拦截，v123 实证；修法 A=锁支持组标记属 F2 专项任务，本任务不扩范围）。S1/S2 按 21.4 未声明组=串行执行：S1 派发→验收→S2 派发→验收；规避派发往返摩擦（F4）与审计误读（计划声明并行但机器串行）。独立性四问结论保留在案供 F2 修正后复用。 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S1 | critical-rules.md Rule 48 块后追加 Rule 49 块（49.1-49.5 五子条，约 25-35 行，范式对齐 Rule 47 块；条款草案主进程预写在派发 prompt 内） | executor(sonnet-1) | worktree skills/task-planner/references/critical-rules.md（插入点=Rule 48 块尾后文件末尾）；派发 prompt 自带条款草案全文 | grep -c '^49\.' =5；git diff 仅追加；21.4/46/47 原文零改动 | 15min | pending |
| S2 | SKILL.md 联动 4 锚：Critical Rules 摘要行/References 表括号追加 49/执行循环推进检查点/合规清单 C34（净增 ≤10 行，行位替换优先） | executor(sonnet-1) | worktree skills/task-planner/SKILL.md（锚位：摘要列表 Rule 47 行后/References 表 Rules 行/执行循环步骤 2.5 与 4 之间/C33 行后） | grep 4 联动锚在位；grep -c 'Rules 1-39' =2 不变；wc -l ≤457 | 15min | pending |
- **Executor:** executor（sonnet-1；S-unit 表 S1/S2，Handoff 登记表 1-executor/2-executor 行实派）
- 验收：grep 49.1-49.5 各子条锚；grep SKILL 4 联动锚；`grep -c 'Rules 1-39' SKILL.md` 仍 =2

### Phase 3: selftest-lane-advancement.sh 守护
- **Status:** complete（2026-10-04；commit 5f66bd8；14 断言+registry 46 行）
- **V-N:** VC-3、VC-3（守护脚本双锚：脚本断言+registry 登记）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S3 | 新建 selftest-lane-advancement.sh（≥8 断言：49.1-49.5 文本锚×5+SKILL 摘要行锚+References 括号锚+零新 config 键负断言；范式对齐 selftest-media-dispatch.sh）+ registry.tsv 登记行 | executor(sonnet-1) | worktree skills/task-planner/scripts/selftest-media-dispatch.sh（范式参照）；scripts/registry.tsv（登记格式） | 脚本落盘且本脚本运行全 PASS；registry 计数+1 | 15min | pending |
- **Executor:** executor（sonnet-1；S-unit 表 S3，Handoff 登记表 3-executor 行实派）

### Phase 4: 全量回归 + Code Review Gate
- **Status:** complete（2026-10-04；回归 45 脚本 702/0；CR APPROVED；align APPROVED；skill-split 锚级联修复 6f0a9de）
- **V-N:** VC-3、VC-4
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|
| S4 | 全量 selftest 回归（45 脚本逐个跑，Total 行求和，与 Phase 1 基线对比；新增 FAIL 定位修复——锚过窄按 v121 宽容化先例，内容越界回炉；实派=executor(sonnet-1) 承接，code-runner-agent mini 档 provider 拒绝改派 22.3①） | code-runner-agent(mini)→executor(sonnet-1) | worktree skills/task-planner/scripts/selftest-*.sh 全集；progress.md 基线段 | 总 FAIL=0 且脚本数=基线+1 | 15min | done |
- **Executor:** executor（sonnet-1；S-unit 表 S4 改派承接，Handoff 登记表 4-code-runner-agent 行实派）；CR Gate=Skill("code-quality-review") 上下文隔离审查（终验交付段消费）

### Phase 5: 合并回 + 部署 + 簿记
- **Status:** complete（2026-10-04；merge 957a7a8；部署 3 位 IDENTICAL；worktree 已清理；VC 5/5 → **outcome: COMPLETE**）
- **V-N:** VC-5、VC-2（部署位主锚复测）
- smart-merge-back --deploy（3 位 IDENTICAL）+ worktree 清理 + INDEX/簿记/memory 更新 + 交付总结
- **Executor:** 主进程（白名单① git 编排）

## 📊 FMEA 预演
| 风险 | RPN | 预设兜底 |
|------|-----|---------|
| 锚级联意外 FAIL（SR-07 字面锚/RV-10/EL-11 宽容锚被 Rule 49 措辞波及） | 96 | 设计规避（主锚不动+括号追加）；若仍 FAIL → 最小修复该锚+登记（22.3 ④ 前置：先 Read 断言实现行再改，v118 教训） |
| SKILL 行数断言级联（T2b 上限） | 60 | Phase 1 确认阈值；净增 ≤10 行纪律兜底；超限 → 行位替换压缩 |
| 子代理写保护区被 check-skill-modify 拦 | 40 | skill_modify_enforce 默认 warn；worktree 内源仓副本不在 ~/.zcode 保护路径，实测确认 |
| selftest 新脚本断言 grep 转义错误 | 48 | 范式对齐 selftest-media-dispatch.sh 既有写法；先手跑单断言再全跑 |
| 部署漂移（master 间隙前进） | 72 | 合并前基线一手复测（v120 范式）；ALREADY_MERGED 路径已内置于 smart-merge-back |

## Decisions Made
| 时间 | 决策 | 依据 |
|------|------|------|
| 2026-10-03 | Rule 编号=49（接续 48） | 模板强制约束「接续当前最大」 |
| 2026-10-03 | **v125 撞号裁决：本任务占用 Rule 49，v125（执行体专业化草稿）若将来执行需改号 Rule 50** | 编号接续以技能本体落地为准（部署位 critical-rules.md 无 49，v125 计划未执行/progress stub/未登记 INDEX）；规划草稿不构成编号占用。副作用披露：本会话 22:57 attest sid 解析回落曾误锁 v125/.plan-attestation（SHA=其当前文件哈希，无实质破坏，v125 重规划时重 attest 即可） |
| 2026-10-03 | 零新 config 键（判定面=LLM 行为） | 46.5/47.4 同范式先例 |
| 2026-10-03 | 21.4 原文零改动，49 纯引用 | Rule 36.5 纯增量纪律 |
| 2026-10-03 | Phase complete 翻转语义不变（推进先于翻转合法） | 不弱化 3-File Gate/check-complete 既有门控 |
| 2026-10-04 | 删除性行为清单=无（Rule 36.3 基线：本任务纯增量——critical-rules 纯追加 16 行、SKILL 行内改写+净增 2 行、新脚本+registry 追加，零功能性删除零语义改写） | Rule 36.5 纯增量纪律 |

## 🔗 Subagent Handoff 登记表
| 时间 | subagent_type | 目标 | checkpoint 路径 | findings 落点 | verify_done |
|-------|--------------|------|----------------|--------------|-------------|
| 20261004 | executor | S1 critical-rules.md 追加 Rule 49 块 | plans/task-v126/subagent-state/1-executor.md | ## Issues/Research 段 | ✅（Read+grep+diff 三证据） |
| 20261004 | executor | S2 SKILL.md 四锚五处联动 | plans/task-v126/subagent-state/2-executor.md | ## Issues 段 | ✅（五处 Read+grep+wc 三证据） |
| 20261004 | executor | S3 selftest-lane-advancement.sh + registry 登记 | plans/task-v126/subagent-state/3-executor.md | ## Issues 段 | ✅（亲跑 14/0+registry 46+status 三证据） |
| 20261004 | code-runner-agent | S4 全量 45 脚本回归 | plans/task-v126/subagent-state/4-code-runner-agent.md | ## Test Results 段 | ✅（701/1 初跑+702/0 复跑亲验） |
