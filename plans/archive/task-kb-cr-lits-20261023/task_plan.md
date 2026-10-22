# Task Plan: task-kb-deploy-20261022 CR 复审 8 项非阻断遗留（L-1~L-8）全修
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「修正  未清项（计划已登记的 8 项非阻断遗留，」<sub>（[目标]——8 项 L-1~L-8 全部修复闭环）</sub>
- **R2**: 「部署  并且推送到远程」（本会话上一条指令，作为收口口径延续）<sub>（[手段]——修复合并后三位部署位同步 + push origin）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1~VC-5 | 8 项逐条 grep 断言（缺陷面=0/修后在位）+ 全量 selftest FAIL=0 |
| R2 | VC-6 | merge_back 提交 + 三位部署 diff（zcode=0，claude/cursor=9 flavor 内）+ origin/master 与本地 master 一致 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-kb-cr-lits-20261023/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结（Rule 80.2）
- **恢复协议**：会话恢复/压缩后先读专档（#1~最新），再读 task_plan.md
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 定位 8 项缺陷代码现场 | 行号漂移/口径误判 | 计划期主进程已逐一核实（findings.md §现场勘察） | VC-1~5 |
| 修复（S1 门控脚本族 / S2 守卫文档族） | 改错文件/破坏既有守卫 | worktree 隔离 + 逐文件 Read 后改 + 白名单最小 diff | VC-1~4 |
| 回归 | 修 A 炸 B（守卫/断言级联） | 全量 selftest-*.sh + tier 三夹具（L0-E/L0/L0-T）+ scope 夹具 | VC-5 |
| CR 门控 | 修出语义偏差 | Code Reviewer 独立 diff 审查 | VC-5 |
| 收口（合并/部署/推送） | 部署位 flavor 丢改/远端漏推 | smart-merge-back --deploy + 三位 diff 复验 + push 后 log 对照 | VC-6 |

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | R1-R2 原文 / VC 表 / L-1~L-8 缺陷清单与修后判据 / 既有守卫行为面（check-scope 拦截语义、L0-E 轻量放行语义不回退 10-22 videop1 裁决） | 本文件 §需求原文 + findings.md §L 清单 |
| 🔀 可变量 | S-unit 拆分/工具选型/夹具构造细节 | - |
| 📈 学得量 | 执行期新事实（实测规则计数、fixture 形态、级联面） | findings.md / notepad-learnings.md |

## Goal
修完 task-kb-deploy-20261022 CR 复审登记的 L-1~L-8 全部 8 项（门控脚本族 4 项 + 守卫文档族 3 项 + L-6 文案择一），全量 selftest 零回归，CR 通过后合并回 master、同步三位部署位并推送 origin。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `task-kb-cr-lits-20261023` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023` |
| `scope_files` | `[skills/task-planner/scripts/check-delegation.sh, skills/task-planner/scripts/check-tier-consistency.sh, skills/task-planner/scripts/check-scope.sh, skills/task-planner/scripts/task-plan-init.cjs, skills/task-planner/scripts/selftest-requirement-coverage.sh, skills/task-planner/README.md, skills/task-planner/docs/ARCHITECTURE.md, skills/task-planner/templates/task_plan.md]` |
| `interaction_mode` | `silent`（自主运行态：关键决策按推荐项裁决并登记 Decisions Made；呈报集中在交付总结） |
| `对齐审查` | [登记] Phase 4 前跑 alignment-review（文档计数面 README/ARCHITECTURE 变更） |
| `自动超时默认项` | [询问点 1: L-6 二择一] 默认=(b) 改文案为真语义（保留 10-22 videop1 轻量放行裁决，(a) 回退哨兵写入=回归 P1 投诉），超时 5min；[询问点 2: L-1 口径统一方向] 默认=双 glob 并集（`*/.k8s/*`+`*/k8s/*` 两侧同列，fail-closed），超时 5min |
| `new_rule` | （空——纯缺陷修复，无新 Rule） |
| `质量审查工具` | [Code Reviewer agent（既有）] |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：VC 复验由独立子代理（Phase 2 code-runner）与 CR（Phase 3）执行，主进程既有上下文自测不作为有效验收

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | L-1：check-delegation.sh 两处保护区清单 k8s glob 口径一致（两侧均含 `*/.k8s/*` 与 `*/k8s/*`） | worktree 内 `grep -n 'k8s' skills/task-planner/scripts/check-delegation.sh` | 两清单行逐行对照（④c is_protected_path 函数 vs ④b mini 分支 case） |
| VC-2 | L-2：`execution_lane: L0-E` 2-Phase 夹具 → check-tier-consistency.sh exit 0（不再前缀误判为 L0）；`L0` 2-Phase 夹具仍 exit 1（守卫不回退）；`L0-T` 精确 lane 走 L0T cap 路径 | 三夹具分别跑 `bash scripts/check-tier-consistency.sh <fixture-dir>` | 夹具在 worktree `tmp/`（gitignore 区）构造；三组 exit code 记录 progress.md |
| VC-3 | L-3：selftest-requirement-coverage.sh 含 51.13 守护断言（RC-28）且全绿；L-4：头注 RC 计数与实际最大 RC 号一致 | `bash skills/task-planner/scripts/selftest-requirement-coverage.sh` | 末行 `Total: 28 PASS=28 FAIL=0`；`head -12` 头注含 `RC-01..RC-28` |
| VC-4 | L-5：README.md 与 docs/ARCHITECTURE.md 规则计数 = 实测值（子代理实测后同步，禁拍脑袋改 76） | 实测：全仓 11 卫星 critical-rules-*.md 唯一规则编号数 vs 两处文档表述 | grep 实测命令+输出落 progress.md；两文件 diff 仅计数词变化 |
| VC-5 | L-6+L-7+L-8：init.cjs 无「跳过计划门控」失准文案（grep=0）且新文案含真语义锚；check-scope.sh 机械产物判定单函数复用（两处调用同一函数）；L-8 三 nit（头注放行来源枚举/留痕 >&2 判定登记/日期与路径基准）闭环 | `grep -c '跳过计划门控' skills/task-planner/scripts/task-plan-init.cjs`（期望 0）；`grep -n '_is_mechanical_artifact' skills/task-planner/scripts/check-scope.sh`（期望函数定义 1 处 + 调用 ≥2 处）；L-8 各点逐项 grep | 记录在 progress.md + CR diff 审查 |
| VC-6 | 收口链：master 合并提交在位 + 三位部署 diff（zcode=0；claude/cursor 仅 9 flavor 文件）+ origin/master 与本地 master 一致 + 全量 selftest FAIL=0 | `git log --oneline -3 master`；`diff -rq` 三位；`git status -sb`；`for f in scripts/selftest-*.sh; do bash $f; done` 汇总 | 记录在 progress.md 终态段 |

**终验规则**：全部 VC 通过 → COMPLETE；有遗留缺陷 → PARTIAL；≥1 VC 重试 3 次失败 → BLOCKED。code_review: required → CR APPROVED 才可 COMPLETE。

## 🎯 核心目标达成裁决（Rule 58.5）
| 字段 | 值 |
|------|-----|
| **目标型需求** | R1（8 项全修） |
| **裁决** | `solved`（L-1~L-8 全 8 项闭环：修复 commit 93e998c..862d4db + 回归 92/92 + CR 二轮 APPROVED WITH NITS + 收口链 342ccdb 推送 origin） |
| **解决证据锚** | VC-1~5 全 PASS 记录（progress.md 行锚） |
| **未解决面+原因** | （partial 时必填） |
| **已排除路径** | （not-solved 时必填） |
| **下一步建议** | （not-solved 时必填） |

## 🎯 Goal 单元表（Rule 66.1）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit | 状态 |
|---------|--------|--------------|------------------------|-------------|------|
| G1 | 门控脚本族修 | L-1/L-2/L-7/L-8 修完且夹具 PASS | 见 VC-1,VC-2,VC-5 命令组 | S1-S5/Phase 1 | complete |
| G2 | 守卫文档族修 | L-3/L-4/L-5 修完且 28/28 | 见 VC-3,VC-4 命令组 | S6,S7/Phase 1 | complete |
| G3 | 回归全绿 | 全量 selftest+CR APPROVED | 见 VC-5 全量段 + CR 裁决行 | S8/S9/Phase 2-3 | complete |
| G4 | 收口链 | 合并+三位部署+推送 | 见 VC-6 命令组 | Phase 4（主进程白名单） | complete |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | scripts/check-delegation.sh, scripts/check-tier-consistency.sh, scripts/check-scope.sh, scripts/task-plan-init.cjs, scripts/selftest-requirement-coverage.sh（均 skills/task-planner/ 下） | 其他 scripts |
| 文档 | README.md, docs/ARCHITECTURE.md | 其他文档 |
| 模板 | templates/task_plan.md（仅 L-8 nit 行 353/355 区） | 其他模板 |
| 夹具 | 本计划 worktree `tmp/`（gitignore 区） | 受管区写夹具 |

**执行前自我检查**：文件在表内？必要？用户要求（=L-1~L-8 修后方向）？全 Yes 才执行。

## 📋 变更标注表（Rule 74.3）
| 编号 | 对象（文件+锚点） | 类型 | 吸收判定 | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|------|----------|----------------|--------------|----------|
| CA-1 | check-delegation.sh:251 vs :351 k8s glob | 修改 | 替代（两侧清单互斥口径=缺陷证据，替代范围=统一双 glob；43.5 既有守卫=全量 selftest） | 修正未清项 | findings.md L-1 + 现场 grep | 两侧同列 `*/.k8s/*\|*/k8s/*` |
| CA-2 | check-tier-consistency.sh:61 LANE 解析 | 修改 | 替代（前缀解析 bug 实证 exit 1；L0-E 语义=独立 lane 族） | 同上 | L-2 夹具实测 | 精确 token + l0/l0-t 族入 L0 检查、l0-e 豁免（P4 权重 0 同口径） |
| CA-3 | selftest-requirement-coverage.sh（RC-28 新增 + 头注） | 修改 | 增量（36.5 纯增量守护先例）+ 头注=更新（计数字段同步，非规则替代） | 同上 | L-3/L-4 现场 grep | 仿 RC-27 加 51.13 断言；头注改 RC-01..RC-28 |
| CA-4 | README.md / docs/ARCHITECTURE.md 计数 | 修改 | 更新（74→实测值，以实测为准） | 同上 | L-5 实测 | 子代理实测唯一规则编号数后改 |
| CA-5 | task-plan-init.cjs:103-115 文案 | 修改 | 替代（旧文案与 10-22 口径①修后真语义矛盾=缺陷证据） | 同上 | L-6 + 10-22 videop1 裁决先例 | 择 (b)：真语义文案（轻量仅免「无计划」门控+放行限机械产物区/gitignore 区，受管文件仍拦；注明 fix/简单 子串连带面） |
| CA-6 | check-scope.sh:121-142 重复块 | 修改 | 替代（同构双份=漂移风险实证） | 同上 | L-7 | 抽 `_is_mechanical_artifact_path()` 双调用 |
| CA-7 | L-8 三 nit（头注枚举/>&2 判定/日期路径基准） | 修改 | 更新 | 同上 | L-8 | 逐项：头注补放行来源；>&2 先查 hook 消费面（stdout 被 PreToolUse 展示则保 stdout+登记决定）；统一日期与 `<skill>/scripts/` 路径基准【D-L8b 修正：CR MAJOR-1 证实模板 kb-* 命令基准方向失准——脚本实体在仓根，:355 回退项目相对 `scripts/kb-*` 形态+双基准注明，:353 行不动】 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）
| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | L-1~L-8 登记原文+待修方向 | plans/task-kb-deploy-20261022/findings.md:49-62 | 必读 | ☑ |
| 项目内部文档 | 10-22 口径①修复先例（轻量放行语义） | plans/task-kb-deploy-20261022/findings.md:46（CR blocker 修复 14d6673） | 必读 | ☑ |
| 项目内部文档 | L0-E 权重 0 豁免口径 | SKILL.md L0-E 段 + check-delegation.sh stats ④c | 必读 | ☑ |
| 官方文档 | worktree 隔离 SOP | skills/task-planner/references/worktree-isolation.md | 参考 | ☑ |

## ⚠️ 核心问题定义（强制）
**核心问题**: 8 项遗留能否以最小 diff 修好且不炸既有 27+ 项守卫（selftest 断言/纪元锚/守卫互引）？
- [x] 修完 8 项后结果可交付（R1+R2 收口链）
- [x] 不修则 CR 遗留悬置、部署位与仓库继续带病运行
- [x] 方法清晰：定位（已完成）→ 修 → 回归 → CR → 收口

## 🔍 调研需求与检索计划（Rule 75.1）
| S-unit/子目标 | 三态 | 检索关键词 | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|-----------|----------|--------------|--------------|
| S1/S2 修复 | LOCAL-ONLY | （纯既定修复，缺陷现场+登记方向齐备） | 本地 grep/Read | worktree 内 8 文件 diff | 不适用 |
| Phase 2 回归 | LOCAL-ONLY | （夹具构造+脚本执行） | 本地 | exit code 记录 | 不适用 |
> 无 NET-* 条目：全部工序本地可决（豁免声明：纯修复+回归，无外部方案依赖）。

## 🔍 证据面清单（Rule 58.1）
`n/a（纯执行类——既定缺陷清单+待修方向，无归因/评估类结论产出）`

## Current Phase
终验交付
## Next Step
计划 attest 锁定 → 并行派发 S1..S7（worktree 已建成，文件对账 8/8 SAME）

## 🧰 工具选择与编排（Rule 40）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent executor(轻档) ×2 并行 | 既定缺陷清单+最小 diff，轻档可决；两族文件集互斥→并行（21.4 四问全 no） |
| Phase 2 | Agent code-runner-agent | 批量脚本执行+夹具，主进程不落原始输出 |
| Phase 3 | Agent Code Reviewer | 独立 diff 视角（18.6 终验门先例） |
| Phase 4 | 主进程 git 编排 + smart-merge-back.sh --deploy | 白名单① git 编排 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8（并行 S-unit=2<3，非长链）→ Rule 21.4 独立性守门调度。
**/goal 对齐（Rule 40.3）**: 未使用 /goal，Goal+VC 即证据源。

## Phases

### Phase 1: 修复（worktree 内 S1..S7 并行）
- [x] 建 worktree `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023`（分支 wt/task-kb-cr-lits-20261023，自 master 923aa54）
- [x] 同步技能文件对账（worktree-branch-desync 教训：wt 文件 vs 主仓 HEAD，8/8 SAME）
- [x] S1-S7 按表并行派发（文件集两两互斥，21.4 四问全 no）
- [x] 主进程 Read 各检查点+抽查 diff（子代理产出核查，§三）
- [x] 逐 S-unit commit（Rule 27，只 add scope 文件）
- [x] 知识储备必读项已确认（☑）
- **V-N:** VC-1, VC-2, VC-3, VC-4, VC-5
- **Status:** complete
- **Executor:** executor（轻档，S1-S7 继承）
<!-- parallel_groups: [S1, S2, S3, S4, S5, S6, S7] — 独立性四问：文件集两两互斥 / 无共享 git 资源（主进程统一 commit）/ 输入独立（各自 L 项+现场勘察段）/ 验收独立（各自 VC 断言）→ 并行 -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | L-1 k8s glob 两侧并集 + L-8 delegation 日期 nit | 继承 | <wt>/skills/task-planner/scripts/check-delegation.sh（:251 vs :351 两清单 + :437 区注释日期统一为 2026-10-07 基线族） | 两清单均同列两个 k8s glob（.k8s/ 与 k8s/ 双形态，逐行 grep 对照）+ 日期行统一 + 检查点 | 10min | 1f/25l/10min | 无 | worktree 建成 | pending |
| S2 | L-2 LANE 精确解析 | 继承 | <wt>/scripts/check-tier-consistency.sh（:61 解析 + :127 L0 族判定 + :63 IS_L0T 勿破） | 三夹具 L0-E=exit0 / L0=exit1 / L0-T=L0T cap 路径 + 检查点 | 12min | 1f/40l/12min | 无 | worktree 建成 | pending |
| S3 | L-7 抽函数 + L-8(check-scope 头注/echo) | 继承 | <wt>/scripts/check-scope.sh（:121-142 双份同构 + :22-23 头注 + echo 行） | 单函数定义 1 处 + 调用 ≥2 处；头注列放行来源；>&2 判定登记（查 hook 消费面后定）+ 检查点 | 15min | 1f/60l/15min | 无 | worktree 建成 | pending |
| S4 | L-6 init.cjs 文案改真语义 | 继承 | <wt>/scripts/task-plan-init.cjs（:103-115 轻量档分支文案，照 D-L6 方向） | `grep -c '跳过计划门控'`=0；新文案含「仅免无计划门控/机械产物区+gitignore 区放行/受管文件仍拦/子串连带面」锚 + 检查点 | 10min | 1f/20l/10min | 无 | worktree 建成 | pending |
| S5 | L-8 模板路径基准 nit | 继承 | <wt>/templates/task_plan.md:353,355（相邻两行 `<skill>/scripts/` vs `bash scripts/` 基准混用） | 统一 `<skill>/scripts/` 基准并注明 + 检查点 | 8min | 1f/8l/8min | 无 | worktree 建成 | pending |
| S6 | L-3 RC-28 + L-4 头注同步 | 继承 | <wt>/scripts/selftest-requirement-coverage.sh（仿 :576 RC-27 范式）+ references/critical-rules.md:106（51.13 段） | `Total: 28 PASS=28 FAIL=0` + 头注 `RC-01..RC-28` + 检查点 | 15min | 1f/40l/15min | 无 | worktree 建成 | pending |
| S7 | L-5 两文档计数=实测值 | 继承 | <wt>/README.md:81 + <wt>/docs/ARCHITECTURE.md:4（实测 11 卫星唯一规则编号数后改） | 实测值落 progress + 两文件 diff 仅计数词 + 检查点 | 12min | 2f/10l/12min | 无 | worktree 建成 | pending |

### Phase 2: 回归
- [x] 全量 selftest-*.sh（scripts/ 下）FAIL=0
- [x] tier 三夹具（L0-E/L0/L0-T）+ scope 轻量/机械产物区夹具 复跑
- [x] 结果落 progress.md（Test Results 段）
- **V-N:** VC-2, VC-5
- **Status:** complete
- **Executor:** code-runner-agent（S8）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S8 | 全量 selftest+夹具回归 | 继承 | <wt>/skills/task-planner/scripts/（selftest-*.sh 全集）+ tmp/ 三夹具 | FAIL=0 汇总 + 夹具 exit code 记录落检查点 | 15min | 0f/30l/15min | 无 | S1-S7 全部 complete | pending |

### Phase 3: CR 门控
- [x] 派 Code Reviewer 审 worktree 全 diff（对照 L-1~L-8 修后判据）
- [x] APPROVED → 进 Phase 4；CHANGES_REQUESTED → 追加 fix S-unit 回 Phase 1
- [x] alignment-review（README/ARCHITECTURE 文档面）
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** code-reviewer（S9）∥ alignment-review skill（S10，并入 S9）
<!-- parallel_groups: [S9, S10] — 审查对象 disjoint（全 diff vs 文档计数面）→ 并行 -->

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S9 | CR diff 审查 | 继承 | <wt> 全 diff（git diff master...HEAD）+ L-1~L-8 判据表 | 裁决行（APPROVED/CHANGES）落检查点 | 15min | 0f/20l/15min | 无 | S8 complete | pending |
| S10 | 文档面 alignment | 继承 | <wt>/README.md + docs/ARCHITECTURE.md（计数面口径核对） | alignment 结论落检查点 | 8min | 2f/5l/8min | 无 | S7 complete | pending |

### Phase 4: 收口（合并/部署/推送/归档）
- [x] smart-merge-back.sh 合并回 master（三条件：全 Phase complete/VC 复验/git status 干净）
- [x] --deploy 三位同步（claude/cursor flavor 还原）+ diff 复验（zcode=0；claude/cursor=9 flavor 内）
- [x] `git push origin master` + log 对照
- [x] 清理 worktree/分支（§11.3-5）
- [x] check-complete.sh → archive-plan.sh → sync-todos --index
- **V-N:** VC-5, VC-6
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排+② 簿记——Rule 25.3 白名单）

## 🔀 隔离决策（冲突分析）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①=本计划 plans/ 未提交（与 skills/ scope 零重叠，不互踩）；信号③=遗留 `wt/task-v168-machine-parked` 未并入 master——系 10-11 用户裁决封存态（park commit 3a68579），非本任务产物，不触碰、交付时呈报） |
| `isolation` | `worktree`（实现类+技能脚本=运行中基础设施，§11.1 命中） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-kb-cr-lits-20261023` |
| `branch` | `wt/task-kb-cr-lits-20261023` |
| `merge_back` | `merged(342ccdb)` |

## 📊 FMEA 预演
| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（22.3 兜底链） |
|-------|---------|---|---|---|-----|-----------------------------|
| Phase 1 | 子代理改面越出 L 项清单（顺手重构） | 6 | 3 | 4 | 72 | diff 抽查发现→主进程 git checkout 越界文件回退+重派（22.3①） |
| Phase 2 | RC-28 新增断言撞纪元锚/守卫互引级联 | 7 | 4 | 4 | 112 | 全量 selftest FAIL 面定位→回炉 S2 补级联（22.3①改派）；≥2 次同法失败升 Complex Problem Solver |
| Phase 4 | 部署位 flavor 误还原/漏同步 | 6 | 3 | 3 | 54 | diff 复验 9 flavor 清单对照（先例 task-kb-deploy 三位复验 SOP） |

## 🔁 原生 Todo 同步（S1–S5）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 创建时 | S1∥S2 并行组 |
| Phase 2 | ☑ | 创建时 | |
| Phase 3 | ☑ | 创建时 | |
| Phase 4 | ☑ | 创建时 | |

## Key Questions
1. L-8「留痕 >&2」是否改变 PreToolUse hook 消费语义？→ 先查 hook 对 check-scope stdout/stderr 的消费面再定（查不清=保 stdout+登记决定，Nit 级不强行改）
2. L-5 实测规则计数基线 → S2 以 grep 唯一编号实测为准，禁沿用 findings「76」字面值

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| L-6 择 (b) 改文案为真语义 | (a) 恢复哨兵写入=回退 10-22 videop1 停摆投诉修复（用户已裁决的 P1 级变更），回归风险>文案收益；(b) 零行为变更、纯文案对齐（可测问题按数据裁决先例） |
| L-1 双 glob 并集（两侧同列 `*/.k8s/*`+`*/k8s/*`） | fail-closed 原则：两形态（dot 目录 .k8s/ 与仓内 k8s/）皆受保护=宪法 §5 基础设施清单+④b 原文并集，缺一侧即开放行口 |
| L-2 L0-E 豁免 L0 体量复核 | L0-E=纯执行档（权重 0，check-delegation stats 豁免先例 P4）；套 L0 单 Phase cap 与其「零受管变更」定义冲突；l0-t 仍走 L0T cap |
| 计划确认按 D1 自动裁决登记 | 自主运行态（用户非实时在场）+ 完成性指令（修正 8 项=射程明确）→ Rule 44.3 自动通过口径；五要素=超时值「N/A（自主态即时登记）」/推荐项=按本计划全修+收口/触发时间=计划创建当刻/理由=可逆（git）+射程无分叉/被覆盖未决选项=等待用户 yes（登记替代） |
| L-8 >&2 改动条件化 | hook 消费面未实证前不改 stdout 语义；查明则改+登记，查不清则保现状仅清头注/日期 nit |
| D-L8b 模板 kb-* 基准回退（CR MAJOR-1） | `<skill>/scripts/kb-*` 指向不存在路径（kb-sync-from-plan.sh/kb-rebuild-index.sh 实体=仓根 scripts/，grep 零命中证明）；改回项目相对形态+双基准注明防再漂移；CR MAJOR-2（progress 证据空白）主进程 Read 复核=误判驳回（79 行含 6 组证据行） |
| LANE-L0 ③ 单 commit 惯性偏差声明 | 本任务实际 7 个 feat 提交（93e998c/9484bb2/df8502b/5abd917/862d4db/b69ed9e/3544076）≠单 commit；机理由=Rule 27 逐 S-unit commit 纪律（每 S-unit 只 add scope 文件）+ CR 回退轮独立提交，L0 薄化「单 commit 簿记精简」在本多 S-unit 计划不适用 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
| （执行期登记） | - | - | → progress.md Error Log |

## Notes
- 子代理派发 prompt 八字段模板：templates/subagent_dispatch.md；检查点路径 worktree 内 `plans/task-kb-cr-lits-20261023/subagent-state/`（绝对路径）
- 夹具一律落 worktree `tmp/`（gitignore 区，§五 P1 豁免）
- 合并三条件缺一 STOP（§11.3）；遗留 `wt/task-v168-machine-parked` 非本任务管辖

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-23 02:44 | ✅ALIGNED（drift-checker 两连 provider 故障→22.3 降档 general-purpose 承接，检查点 subagent-state/drift-check-phase1.md） | VC-1~5 | 7 commit 逐行对照 R 射程零越界；8s 检查点在位=Phase2 已启动 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4（Phase 1 S1-S7、Phase 2 S8、Phase 3 S9∥S10） |
| 主进程直做 Phase 清单 | Phase 4（git 编排+簿记，白名单①②） |
| 委派率 | 3/4=0.75 ≥ 0.7 floor（L0-E 权重 0 面：本任务无 L0-E S-unit） |

## 🔗 Subagent Handoff 登记表（Rule 22.5）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | Phase 1 | executor | S1 L-1 k8s glob | queued | | | findings §S1 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/1-s1-check-delegation.md | - / 0 / ☐ |
| 2 | Phase 1 | executor | S2 L-2 LANE 解析 | queued | | | findings §S2 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/2-s2-tier.md | - / 0 / ☐ |
| 3 | Phase 1 | executor | S3 L-7+L-8 check-scope | queued | | | findings §S3 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/3-s3-scope.md | - / 0 / ☐ |
| 4 | Phase 1 | executor | S4 L-6 init.cjs 文案 | queued | | | findings §S4 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/4-s4-init-cjs.md | - / 0 / ☐ |
| 5 | Phase 1 | executor | S5 L-8 模板路径基准 | queued | | | findings §S5 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/5-s5-nits.md | - / 0 / ☐ |
| 6 | Phase 1 | code-assistant | S6 L-3 RC-28+L-4 头注 | queued | | | findings §S6 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/6-s6-selftest-rc.md | - / 0 / ☐ |
| 7 | Phase 1 | code-assistant | S7 L-5 计数实测 | queued | | | findings §S7 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/7-s7-counts.md | - / 0 / ☐ |
| 8 | Phase 2 | code-runner-agent | S8 全量回归 | queued | | | findings §S8 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/8-s8-regression.md | - / 0 / ☐ |
| 9 | Phase 3 | code-reviewer | S9 CR diff 审查 | done | 一轮 CHANGES REQUIRED(MAJOR-1 属实/MAJOR-2 时点差) → 二轮 APPROVED WITH NITS（MAJOR-1 862d4db 修复+MAJOR-2 关闭；NIT×6 登记不修） | subagent-state/9-s9-cr.md:172 | findings §CR 一轮裁决 | <主仓>/plans/task-kb-cr-lits-20261023/subagent-state/9-s9-cr.md | - / 1 / ☑ |
| 10 | Phase 3 | executor | S10 文档面 alignment | queued | | | findings §S10 | <wt>/plans/task-kb-cr-lits-20261023/subagent-state/10-s10-alignment.md | - / 0 / ☐ |

## 🔁 模板感知
<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底
- Rule 34.3②: 终验时评估沉淀（本任务=缺陷修复型，预计不沉淀）
