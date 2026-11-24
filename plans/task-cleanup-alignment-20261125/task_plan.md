<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Task Plan: task-cleanup-alignment-20261125

- task_id: `task-cleanup-alignment-20261125`
- 时间: created_at=2026-11-24T21:11:47Z / updated_at=2026-11-24T21:32:20Z
plan_tier: standard
execution_lane: L2
schema_version: 1
- 顶层 tags: （无）

## 🎯 用户需求原文
- **R1（目标）** 加强 task-planner，建立反屎山机制：任务执行后做清理；代码注释可保留，清理对象是技能定义文件中的无价值历史注释（用户原话 #1）
- **R2（目标）** 任务完成后执行双步骤：①对齐（过期/冲突口径拉平）②垃圾清理（无价值历史注释）（用户原话 #2）
- **R3（手段）** 纯文本条款落地即可：todo 最后两步做对齐+清理；task 模板中新增一个板块列出必要步骤；不搞脚本门/基建（用户原话 #3）
- **R4（手段）** 采纳方案 A，按三段式推进（用户原话 #4）

## Requirements（用户需求）
| id | type | text | vc | tags |
|---|---|---|---|---|
| R1 | 目标 | 加强 task-planner，建立反屎山机制：任务执行后做清理；代码注释可保留，清理对象是技能定义文件中的无价值历史注释（用户原话 #1） |  |  |
| R2 | 目标 | 任务完成后执行双步骤：①对齐（过期/冲突口径拉平）②垃圾清理（无价值历史注释）（用户原话 #2） |  |  |
| R3 | 手段 | 纯文本条款落地即可：todo 最后两步做对齐+清理；task 模板中新增一个板块列出必要步骤；不搞脚本门/基建（用户原话 #3） |  |  |
| R4 | 手段 | 采纳方案 A，按三段式推进（用户原话 #4） |  |  |

## Goals（目标单元）
| id | text | evidence | tags |
|---|---|---|---|

## 🎯 Goal 单元表
| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit | 状态 |
|---|---|---|---|---|---|

## Phases（阶段状态）
| id | status | s_units | v_checks | name | started | tags |
|---|---|---|---|---|---|---|
| P1 | pending |  |  | 段1：todo 收尾两步 B17/B18 |  |  |
| P2 | pending |  |  | 段2：task 模板新板块 + render 同步 |  |  |
| P3 | pending |  |  | 段3：SKILL 指针 + 验证 + 合并回 |  |  |

## R→VC 映射
| requirement | vcs |
|---|---|
| R1 |  |
| R2 |  |
| R3 |  |
| R4 |  |
## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
| 工序 | 缺陷面 | 修复点 | VC |
|---|---|---|---|
| （root_causes 未登记） | 结果级需求须 planctl add --section root_causes 逐工序补登；非结果级任务在本行写「不适用（非结果级）」+定性理由 | - | - |

## ✅ Verification Contract（VC 状态与判据）
| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|---|---|---|
| VC1 | todo-sync.md S1 基线组含 B17 口径对齐 / B18 垃圾清理，S4 增加前置约束 | grep -nE "B17\|B18" skills/task-planner/references/todo-sync.md |  |
| VC2 | task_plan 模板含独立的收尾对齐与清理板块 | grep -nF "收尾对齐与清理" skills/task-planner/templates/task_plan.md |  |
| VC3 | planctl render 实际输出该板块（standard 档），mini 档不输出 | python3 skills/task-planner/scripts/planctl.py render --plan-dir plans/task-cleanup-alignment-20261125 >/dev/null && grep -nF "收尾对齐与清理" plans/task-cleanup-alignment-20261125/task_plan.md |  |
| VC4 | SKILL.md 终验智能子动作段含收尾对齐与清理指针 | grep -nF "收尾对齐与清理" skills/task-planner/SKILL.md |  |
| VC5 | 语法检查通过且 selftest 零新增 FAIL、verify.sh 0 fail | bash -n skills/task-planner/scripts/*.sh && python3 -m py_compile skills/task-planner/scripts/*.py && bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -3 |  |

## 🔍 调研需求与检索计划
| unit | 三态(LOCAL-ONLY/NET-RESEARCH/NET-DATA-DEPENDENT) | 检索关键词 | 渠道 | 预期产出形态 |
|---|---|---|---|---|
| 全局 | LOCAL-ONLY | （无 NET-* 检索项；执行期新增外部调研须先 planctl set --section research_status 补登） | - | - |

## Phase 锚点明细（3file-gate/plan-dispatch 解析面）

### Phase 1: 段1：todo 收尾两步 B17/B18
- **Status:** pending
- **Started:** 
- **Executor:** -

### Phase 2: 段2：task 模板新板块 + render 同步
- **Status:** pending
- **Started:** 
- **Executor:** -

### Phase 3: 段3：SKILL 指针 + 验证 + 合并回
- **Status:** pending
- **Started:** 
- **Executor:** -

## 🧹 收尾对齐与清理（交付前必填）
| 类别 | 检查项 | 判据 | 证据 |
|---|---|---|---|
| 对齐 | 口径计数 / 冲突条款 / 行数快照 | 冲突锚 grep 无本任务新增命中 | progress `[align-final]` 行 |
| 清理 | 历史注释 / 过期注 / 残留物 | 本任务新增痕迹注为 0 | progress `[cleanup-final]` 行 |

执行时机：outcome 判定之前、合并回动作之前；mini / L0-lite 档豁免本板块。

## 🔀 隔离决策
| 字段 | 值 |
|---|---|
| merge_back | merged(9d5fb1b2) |

## Decisions Made
| Decision | Rationale |
|---|---|
| 方案 A + 三段式推进；范围严格限定文本条款，不新增脚本门/config/批量清存量/部署位 | 2026-11-25 用户裁决（用户原话 #4）；设计文档 docs/superpowers/specs/2026-11-25-task-cleanup-alignment-design.md |

## 📎 领域模板原文附录（仅供参考；权威判据以 JSON 结构化段+机器门为准）
<!-- template_type: rule-enhancement -->
execution_lane: L2
<!-- template_meta: {"type": "rule-enhancement", "name": "规则增强", "summary": "技能规则/条款增强：新增 Rule、config 三档键、消费侧门控、selftest 守护与 SKILL 联动。", "scenarios": ["新增 Rule", "条款增强", "消费侧门控脚本", "selftest 守护", "技能机制化增强"], "features": ["用户需求原文 R→VC 映射", "Verification Contract", "工具选择与编排", "消费侧门控与 selftest 守护", "SKILL 联动"]} -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程; 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发） -->
<!-- 📦/🛡 进度产出基线与防倒退终检：按主模板 Rule 111 区块执行（本 variant 不重复区块本体） -->

> # Task Plan: [规则增强任务名称]
<!-- template-lineage: level=derived parent=../task_plan.md base=../task_plan.md spec_version=1 pruned="根源覆盖表,不变量声明区,规范基线,进度产出基线,Goal,双轮质检与同步完整性声明,核心目标达成裁决,变更标注表,核心问题定义,调研需求与检索计划,证据面清单,CurrentPhase,NextStep,防倒退终检,收尾回读梳理记录,隔离决策,FMEA预演,原生Todo同步,KeyQuestions,DecisionsMade,ErrorsEncountered,Notes,Chain区块交接配置" pruned_reason="variant=领域裁剪全文，裁剪面以本清单显式登记（Rule 34.5 派生登记）" -->
<!-- planctl 派生口径(task-planctl-exec-surface-20261122)：本骨架数据经 planctl add/set 写入 plan-state.json 后 render 派生 task_plan.md 视图；直接填写会在首次 render 被覆盖 -->

> ## 🎯 用户需求原文（Rule 51.1 逐条抄录 + 51.2 R→VC 映射; R 行=用户原话逐条编号抄录，每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉）

<!-- plan_tier: standard -->
> ## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复，镜像 51.1 注入兜底范式）。适用判定:产出=结论/判断/建议/原因解释的任务；
     豁免: 纯执行类任务(单点动作)填 `n/a（纯执行类）`;对标面豁免仅限 58.2 两种登记理由,禁裸豁免 -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | （自身内容/产品/数据） | | | ☐ |
| ② 对标样本（58.2 强制） | （竞品/同类成功案例/历史基线，≥1 个可指名） | | | ☐ |
| ③ 外部约束 | （平台规则/市场环境/算法机制） | | | ☐ |

> 归因类结论（为什么没流量/为什么不如人）在 ② 未完成第一手取证前禁止产出（58.2 无对标取证=无据结论）。

> ## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）
<!-- 2026-10-07 task-v143：init 注入载体（CR F-1 修复）。58.4 手段/目标二分在需求区 R 行标注 [手段]/[目标]；
     本区块终验时回收目标型需求的解决状态；not-solved/partial 禁止标 COMPLETE（58.5②） -->
| 字段 | 值 |
|------|-----|
| **目标型需求** | （R 行编号，如 R1/R3） |
| **裁决** | `solved` / `partial` / `not-solved`（三选一必填） |
| **解决证据锚** | （file#锚点/取证记录行；solved 必填） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填：试过什么+为何不行） |
| **下一步建议** | （not-solved 必填：可执行的下一步） |

> 纯手段型任务（用户只要动作/产物，无问题待解）可填 `n/a（纯手段型任务）`——须与需求区标注一致，禁裸豁免。

> ## Goal: [一句话: 落地 Rule NN <规则名>（NN.1-NN.M 条款 + config 三档键 + 消费侧门控 + selftest 守护 + SKILL 联动），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位]

> ## 🔍 Code Review 配置
| `code_review` | `required`（改动含 .sh 脚本）; 对齐审查[登记] Rule 42.6;自动超时[询问点] Rule 44;质量审查[检测结论] Rule 42 — 均 mini 豁免 |

> ## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule NN 条款完整（NN.1-NN.M，范式对齐既有规则：子条=NN.M 动词短语，末条"机制"声明三档键+selftest） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | config 三档键落地（enforce/warn/off，默认 warn，挂 properties 内） | `jq .properties.<key>` 校验 | `config.json` |
| VC-3 | 消费侧脚本集成（档位解析 env>config>warn；各档位分支功能实跑） | enforce/warn/off 三档行为实测 | 消费侧脚本输出 |
| VC-4 | selftest 守护落地 + 全量回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数**） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-5 | SKILL 联动（索引行 Rules 1-N/合规清单 C 行/特判段/摘要行）+ 3 实体位部署 diff=0 | grep 联动锚 + smart-merge-back --deploy | SKILL.md / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

> ## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加新块） | 改既有规则语义 |
| 配置 | `config.json`（properties 追加新键） | 动既有键；顺手修既有脏点（最小 diff） |
| 脚本/文档 | 消费侧脚本 + 新建 selftest / template-mapping.md / plan-writer.md（如涉四点同步） | 其他脚本/文档 |
| SKILL | `SKILL.md`（**净增 ≤10 行**：行位替换优先） | 大段新增 |

**强制约束**:
- 新规则编号接续当前最大 Rule；合规清单接续最大 C 编号
- ⚠️ **锚定级联**：改 SKILL.md "Rules 1-N" 前先 `grep -rn "Rules 1-" scripts/` 扫全部锚断言一次修齐（宽容正则 `Rules 1-3[x-y]` 优先）; SKILL.md 行数纪律：wc -l 复核；行数上限断言（selftest-knowledge-brief T2b）同步上调 + label 注明 task 代号（先例：≤523 task-v071 → ≤540 task-v074）
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）

> ## 🧰 工具选择与编排（Rule 40 — 计划期主动分析;Executor 字段=委派门控机器事实源;mini 豁免）
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

> ## Phases（骨架，按任务规模增删）

> ### Phase 1: 隔离与基线
- worktree 建立（宪法 §十一）+ 全量 selftest 基线（主进程逐 Total 行求和）+ 插入点锚确认
- **Status:** pending
- **Executor:** 主进程（白名单① git 编排）+ code-runner-agent

> ### Phase 2: 条款 + config 键 + 消费侧门控
- S1 条款全文 / S2 config 键 + 门控脚本集成（派发型 Phase 必附 S-unit 7 列表，attest 校验时长列与输入路径 ≤2 列）
- **Status:** pending
- **Executor:** executor（sonnet-1），按 21.4 调度铁律派发（[EVOLVED 2026-10-02] 声明组内并行/未声明组=串行）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | （A6） | 继承 |  |  | 10min | 1f/10l/10min | 无 | - | pending |

> ### Phase 3: selftest 守护 + 锚点修复
- 新建 selftest（对齐 selftest-veto.sh 范式）/ 既有锚断言宽容化 / init 或集成收尾
- **Status:** pending
- **Executor:** executor（sonnet-1）

> ### Phase 4: SKILL 联动 + 文档同步 + 全量回归
- SKILL 净增纪律内联动 + 四点同步 + 全量回归（主进程复跑定数）
- **Status:** pending
- **Executor:** executor（sonnet-1）

> ### Phase 5: 合并回 + 部署 + 簿记
- smart-merge-back --deploy 3 实体位 + INDEX/ledger + worktree 清理
- **Status:** pending
- **Executor:** 主进程（白名单①②）

> ## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 最近两轮规则块范式 / selftest 写法范式 / 三档键范式 | references/critical-rules.md 末尾; scripts/selftest-veto.sh; config.json 最新三档键 | ☑ |
| 项目内部 | 台账供料简报（Rule 编号账本+审计台账路径等） | `<plan-dir>/knowledge-brief.md` §2/§3/§5（台账路径锚供料，禁 prompt 内联基线） | ☑ |

- **调研需求三态（Rule 75.1）**：本模板任务默认 **可选**——规则增强主要操作仓库内部文件（条款/config/脚本/SKILL.md），通常无需网络调研；涉及新机制引入或外部标准参照时按 Rule 75.1 逐个判定调研触点

> ## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|

> ## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- WHAT: 子代理 vs 主进程执行分布;WHY: 委派率 < delegation_rate_floor(默认 0.7)或白名单外理由 → 最高 PARTIAL;WHEN: 每 Phase complete 后更新,终验前必填 -->
| 字段 | 值 |
|------|-----|
| 子代理/主进程 Phase 数 |  /  |
| 主进程直做 Phase 清单 + 委派率 | （含例外理由; < delegation_rate_floor 默认 0.7 或白名单外理由 → 最高 PARTIAL） |

> ## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |

> ## 🎯 Goal 单元表（Rule 66.1 — attest 获批后填写）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 |  |  |  |  | pending |

> ## 📦 Batch Report（Rule 18.6 — 留空会被 check-complete 拦）
| 字段 | 值 |
|------|-----|
| `total` | n/a（<一句理由>） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | 任务 <5 单元不触发抽样 |
| `pre_check` | Q1:否 / Q2:无共享写 / Q3:能 |
| `rollback_point` | <worktree 分支，合并前可弃> |
