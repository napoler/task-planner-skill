<!-- template_type: rule-enhancement -->
<!-- 适用场景: task-planner 技能规则/条款增强——新增 Rule NN、config 三档键、消费侧门控脚本、selftest 守护、SKILL 联动 -->
<!-- 触发关键词: 加规则/新增 Rule/条款/门控/合规清单/守护/技能增强/机制化 -->
<!-- 推荐 subagent: executor(sonnet-1) 写条款与脚本; code-runner-agent 跑 selftest; 合并部署主进程 -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务第 3 次触发；v071-v073 同套路轮次佐证） -->

# Task Plan: [规则增强任务名称]

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->

- **R1**: 「<用户原话第 1 条，逐字抄录，禁转译>」
- **R2**: 「<按需增行>」

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1 | <判据：计数=0/文件在位+绝对路径/命令输出形态> |

<!-- plan_tier: standard -->
## Goal
[一句话: 落地 Rule NN <规则名>（NN.1-NN.M 条款 + config 三档键 + 消费侧门控 + selftest 守护 + SKILL 联动），全量 selftest 0 FAIL 后合并回 master 并部署 3 实体位]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本） |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | Rule NN 条款完整（NN.1-NN.M，范式对齐既有规则：子条=NN.M 动词短语，末条"机制"声明三档键+selftest） | Read 条款节 + grep 各子条锚 | `references/critical-rules.md` |
| VC-2 | config 三档键落地（enforce/warn/off，默认 warn，挂 properties 内） | `jq .properties.<key>` 校验 | `config.json` |
| VC-3 | 消费侧脚本集成（档位解析 env>config>warn；各档位分支功能实跑） | enforce/warn/off 三档行为实测 | 消费侧脚本输出 |
| VC-4 | selftest 守护落地 + 全量回归 0 FAIL（**总数=主进程逐脚本 Total 行求和，禁采信子代理自报总数**） | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log |
| VC-5 | SKILL 联动（索引行 Rules 1-N/合规清单 C 行/特判段/摘要行）+ 3 实体位部署 diff=0 | grep 联动锚 + smart-merge-back --deploy | SKILL.md / 部署输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则条款 | `references/critical-rules.md`（追加新块） | 改既有规则语义 |
| 配置 | `config.json`（properties 追加新键） | 动既有键；顺手修既有脏点（最小 diff） |
| 脚本 | 消费侧脚本 + 新建 selftest | 其他脚本 |
| SKILL | `SKILL.md`（**净增 ≤10 行**：行位替换优先） | 大段新增 |
| 文档 | template-mapping.md / plan-writer.md（如涉四点同步） | 其他文档 |

**强制约束**:
- 新规则编号接续当前最大 Rule；合规清单接续最大 C 编号
- ⚠️ **锚定级联**：改 SKILL.md "Rules 1-N" 字样前先 `grep -rn "Rules 1-" scripts/` 扫全部锚断言一次修齐（宽容正则 `Rules 1-3[x-y]` 优先，避免两阶段间回归 FAIL）
- SKILL.md 行数纪律：wc -l 复核；行数上限断言（selftest-knowledge-brief T2b）同步上调 + label 注明 task 代号（先例：≤523 task-v071 → ≤540 task-v074）
- 派发契约：executor prompt 必含计划三文件路径 + acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

## Phases（骨架，按任务规模增删）

### Phase 1: 隔离与基线
- worktree 建立（宪法 §十一）+ 全量 selftest 基线（主进程逐 Total 行求和）+ 插入点锚确认
- **Executor:** 主进程（白名单① git 编排）+ code-runner-agent

### Phase 2: 条款 + config 键 + 消费侧门控
- S1 条款全文 / S2 config 键 + 门控脚本集成
- **Executor:** executor（sonnet-1），按 21.4 调度铁律派发（[EVOLVED 2026-10-02] 声明组内并行/未声明组=串行）
<!-- 派发型 Phase 必附 S-unit 7 列表（示例行，实例化时替换为目标/输入/验收；attest 机器校验时长 NNmin 列与输入路径 ≤2 列） -->
| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | 写入新条款全文至 SKILL.md 指定插入点 | 继承 | plans/<task>/findings.md（条款草案 + 插入点锚） | 条款落盘且行数纪律复核通过 | 10min | pending |
| S2 | 集成 config 键 + 消费侧门控脚本 | 继承 | skills/task-planner/config.json（三档键段落） | 门控脚本单测通过且 selftest 全量无回归 | 12min | pending |

### Phase 3: selftest 守护 + 锚点修复
- 新建 selftest（对齐 selftest-veto.sh 范式）/ 既有锚断言宽容化 / init 或集成收尾
- **Executor:** executor（sonnet-1）

### Phase 4: SKILL 联动 + 文档同步 + 全量回归
- SKILL 净增纪律内联动 + 四点同步 + 全量回归（主进程复跑定数）
- **Executor:** executor（sonnet-1）

### Phase 5: 合并回 + 部署 + 簿记
- smart-merge-back --deploy 3 实体位 + INDEX/ledger + worktree 清理
- **Executor:** 主进程（白名单①②）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 最近两轮规则块范式 | references/critical-rules.md 末尾 | ☑ |
| 项目内部 | selftest 写法范式 | scripts/selftest-veto.sh | ☑ |
| 项目内部 | 三档键范式 | config.json 最新三档键 | ☑ |
| 项目内部 | 台账供料简报（B8 编号账本+审计台账路径等） | `<plan-dir>/knowledge-brief.md` §2/§3/§5（台账路径锚供料，禁 prompt 内联基线） | ☑ |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
