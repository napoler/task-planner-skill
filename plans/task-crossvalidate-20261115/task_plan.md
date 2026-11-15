# Task Plan: 验证链交叉验证方法论固化
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} token 由 init-session.sh render_template() 脚本渲染；尖括号中文占位=模型填写面，脚本禁碰 -->
<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  template_type 填所选类型名；general=通用回退（恒合法，Rule 34.1）
  plan_tier ∈ {standard, mini}；execution_lane ∈ {L0, L1, L2}（缺省 L1）
  check-template-type.sh 三形态之一：行首 `^template_type:`（本块）/ 表格行 / HTML 注释 -->
template_type: general
plan_tier: standard
execution_lane: L1
<!-- parallel_groups: verify（Phase 3-S1/S2 无依赖并行组，Rule 96.3） -->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「验证的时候，我希望可以就是引入交叉验证这种方式，就是从方法层面上来识别出执行错误，就是提高补充更高的识别错误的能力」<sub>（[目标]）</sub>
- **R2**: 「不是说必须使用多高的模型，但是最重要的是就是经过隔离上下文，然后通过不同的角度来识别出错误，确保执行的嗯执行的，就是说执行产出的稳定性」<sub>（[手段]：机制=隔离上下文+多角度）</sub>
- **R3**: 「如果说可以尽快地更加有效地识别出嗯识别执行过程产出内容的错误以及缺陷等等」<sub>（[手段]：识别效率）</sub>
- **R4**: 「不要相信模型自我呃自我虚构的任何事情，就是说将各种虚构了或者说伪造了，都能够及时识别出来」<sub>（[目标]：反虚构可观察判据）</sub>
- **R5**: 「确保就是引入方法论来嗯更加有效的识别错误。完成执行验证。化相关的技能以及步骤，确保整个执行的稳定」<sub>（[手段]：固化=条款+SKILL+模板+守护）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1、VC-4 | Rule 108 条款在位（grep 五子条锚）+dogfood 实弹报告双路径结论 |
| R2 | VC-1、VC-4 | 108.2 独立重推导+108.3 双视角条款锚+dogfood 隔离上下文实弹 |
| R3 | VC-3、VC-5 | selftest 守护脚本 exit 0+全量回归 FAIL 增量=0 |
| R4 | VC-1、VC-4 | 108.5 伪造识别信号条款锚+dogfood 报告伪造信号面核验 |
| R5 | VC-2、VC-3、VC-6 | SKILL 级联+模板步骤区块+registry 登记+合并回落地 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-crossvalidate-20261115/user-session-log.md`（模板 = /mnt/data/dev/task-planner-skill/skills/task-planner/templates/user-session-log.md）
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md（目标/验收/下一步）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 侦察（P1-S1） | 插入点/守护面漏侦察→级联漂移或断言破坏 | Explore 全链侦察+级联「1-107」族枚举（F1-F6） | VC-1、VC-2 |
| 起草（P1-S2） | 条款抽象不可执行→规则空转（本任务主题反例） | 五子条全部落可 grep 锚+判例锚+触发面档位 | VC-1 |
| 落地（P2） | 插段吞锚/既有断言破坏 | 106.1a 三规约+增量原则（既有条款零改写）+P3 回归 | VC-1、VC-2、VC-3 |
| 守护（P2-S4） | 新条款无机器守护→后续改动静默漂移 | selftest-cross-validation.sh+registry 登记 | VC-3 |
| 验证（P3） | 复检缺位/单点验证者信自身→虚构漏检（正是本任务反虚构主题） | 双轮质检（critic 全文回读）+dogfood 双视角交叉验证实弹 | VC-4、VC-5 |
| 收口（P4） | 合并回/部署漂移、编号未 land | smart-merge-back+rule-reserve land+部署 diff=0 核验 | VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3）

| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | ① R1-R5 原文逐字锚 ② VC 表六条 ③ worktree 隔离决策 ④ 增量原则（既有条款/断言零改写，纯追加+级联句按四形态实测） ⑤ new_rule=108 ⑥ scope_files 清单 | task_plan.md 对应章节锚 |
| 🔀 可变量 | ① S-unit 拆分与并行顺序 ② Rule 108 五子条行文措辞（结构五子条锁定，措辞可调） ③ verification 模板 CV 区块落点（两模板择一，按侦察定） ④ 「1-107」级联族处置方式（宽容锚演进 vs 零动作登记） ⑤ 部署/push 批次与时机 | FMEA/侦察结论 |
| 📈 学得量 | 插段期新锚事实/级联新发现文件/交叉验证实弹细节 → findings.md/knowledge-brief §2；禁反向改写不变量 | findings.md |

## Goal

在本仓验证链固化「隔离上下文 + 多角度独立验证 + 分歧升级 + 伪造识别信号」的交叉验证方法论（Rule 108 条款 + SKILL 级联 + 验证模板步骤区块 + selftest 守护 + dogfood 实弹），使执行产出的错误、缺陷与虚构声称可由独立路径及时识别。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `n/a`（内容组画像：交付物=规则条款文本+≤70 行 bash 断言脚本；脚本质量由 P3 双轮质检（critic 全文回读）+全量回归覆盖，不另设 CR Gate） |
| `session_id` | `883beae2859d439fb3740d9f2aef9d2a` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115` |
| `scope_files` | `skills/verification-gate/references/critical-rules-verification.md`、`skills/verification-gate/SKILL.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/templates/verification.md`、`skills/task-planner/scripts/selftest-cross-validation.sh`（新建）、`skills/task-planner/scripts/selftest-registry.tsv`、级联族按 F3 侦察实测追加（plans/** 与本计划目录除外） |
| `interaction_mode` | ask（缺省回落 config.json） |
| `对齐审查` | `[登记]` 收尾跑 alignment-review（标准收尾流程；文档更新前版本一致性校验） |
| `自动超时默认项` | 询问点=D1 计划确认：默认项=按已展示计划执行、超时 5 分钟（Rule 44.3）；其余低区分度选项不询问直接裁决登记 |
| `new_rule` | `108` |
| `质量审查工具` | `critic`（103.3 独立复检+对抗挑刺，全文回读 103.3a）+ `alignment-review`（收尾）；既有 agent 在位，无缺口 |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：本计划验证动作默认由独立子代理执行，主进程既有上下文自测不作为有效验收（Rule 33.3 延伸）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | Rule 108 交叉验证纪律条款在位 verification-gate 卫星规则文：五子条锚（108.1 触发面/108.2 独立重推导/108.3 双视角交叉/108.4 分歧升级/108.5 伪造信号）各 grep ≥1 且含判例锚 | grep 命令 | `grep -cE '108\.[1-5]' skills/verification-gate/references/critical-rules-verification.md`（=5 段锚）+ `grep -c 'fabricated-output' <同文件>` ≥1 |
| VC-2 | SKILL 级联与模板步骤在位：verification-gate/SKILL.md 与 task-planner/SKILL.md 各含 Rule 108 引用 ≥1；verification 模板含「交叉验证记录」区块锚 ≥1 | grep 命令 | `grep -c 'Rule 108' skills/verification-gate/SKILL.md skills/task-planner/SKILL.md`（各 ≥1）+ `grep -c '交叉验证记录' skills/task-planner/templates/verification.md` ≥1 |
| VC-3 | selftest-cross-validation.sh 在位可执行、本机 exit 0、registry.tsv 登记行在位 | 运行命令 | `bash skills/task-planner/scripts/selftest-cross-validation.sh; echo EXIT=$?`（EXIT=0）+ `grep -c 'selftest-cross-validation' skills/task-planner/scripts/selftest-registry.tsv` ≥1 |
| VC-4 | dogfood 交叉验证实弹报告在位：双独立路径（机械面重推导+语义面 critic）结论+一致/分歧判定+108.4 协议留痕 | 检查文件 | `plans/task-crossvalidate-20261115/cross-validation-report.md`（含双路径段+判定行） |
| VC-5 | 全量回归无新增 FAIL：run-selftests.sh ΣFAIL 与 master 基线预存量对照增量=0 | 运行命令 | `bash skills/task-planner/scripts/run-selftests.sh`（输出 ΣFAIL；对照 Phase 3-S1 基线分账行） |
| VC-6 | 合并回落地：主仓 git log 含 merge commit、worktree 目录与 wt/* 分支已清理、rule-reserve land 108 登记行在位 | 检查文件+命令 | `git log --oneline -5`（含 merge）+ `ls tmp/worktrees/task-crossvalidate-20261115`（不存在）+ `grep '108' plans/.rule-reservations.jsonl`（landed 行） |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> `code_review: n/a` → 不设 Code Review Gate；P3-S2 critic 复检承担质量门（Rule 103.3）。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard/full 必填，mini 豁免）

| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 1-S2（条款草案）+Phase 2-S1/S2/S4/S5（全部插改/新建实质产出）；第二轮由 Phase 3-S2 critic 承接（复检对象=落位后终态文本，强于草稿态复检，避免同内容双审） |
| 豁免登记 | Phase 1-S1 侦察结论（非实质产出，findings 回填+主进程验收 Read 承担）；Phase 2-S3（≤8 行宽容锚微调，P3 全量回归覆盖） |
| 多文件变更集预判 | Phase 2（≥2 受管文件级联）→ 合并回前过 103.6 同步核对清单（scope 文件 grep 清单逐项全绿） |

## 🎯 核心目标达成裁决（Rule 58.5）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1、R4 |
| **裁决** | （终验时填写：solved/partial/not-solved） |
| **解决证据锚** | （终验时填写） |
| **未解决面+原因** | （如 partial/not-solved 必填） |
| **已排除路径** | （如 not-solved 必填） |
| **下一步建议** | （如 not-solved 必填） |

> 判据：R1/R4 的 [目标] 属性以 VC-1 条款锚 + VC-4 dogfood 实弹为可观察解决证据（非仅"文件写了"）。

## 🎯 Goal 单元表（Rule 66.1 — standard 必填）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 插入点侦察 | 锁定验证链全部插入点与守护面 | findings.md F1-F6 六节齐且各含 file:line 锚 | S1/Phase 1 | pending |
| G2 | 条款起草 | Rule 108 五子条草案+模板区块草案 | clause-drafts.md 在位且五子条锚齐 | S2/Phase 1 | pending |
| G3 | 落地插改 | 条款+SKILL 级联+模板区块+守护脚本落 worktree | VC-1/VC-2/VC-3 命令全过 | S1-S5/Phase 2 | pending |
| G4 | 回归+复检 | 全量回归零新增 FAIL+critic 复检回执 | VC-5 输出+checkpoint 回执五要素 | S1、S2/Phase 3 | pending |
| G5 | dogfood 实弹 | 按 Rule 108 对产出执行双视角交叉验证 | VC-4 报告在位含判定行 | S3/Phase 3 | pending |
| G6 | 合并收口 | 合并回+清理+land+部署+归档 | VC-6 三证据+归档 ARCHIVED | Phase 4 | pending |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 规则文 | skills/verification-gate/references/critical-rules-verification.md | 其他卫星规则文 |
| SKILL | skills/verification-gate/SKILL.md、skills/task-planner/SKILL.md | 其他 SKILL.md |
| 模板 | skills/task-planner/templates/verification.md | 其他模板 |
| 守护脚本 | skills/task-planner/scripts/selftest-cross-validation.sh（新建）、selftest-registry.tsv、级联族按 F3 实测 | 无关脚本 |
| 计划文档 | plans/task-crossvalidate-20261115/** | 其他任务 plans/ 目录 |
| 部署位 | 合并回后经 --deploy 通道同步 ~/.zcode/skills 对应文件 | 部署位其他文件 |

**执行前自我检查:** 文件在列表中？修改必要？用户原话要求？全部 Yes → 执行 | 任一 No → 按 Rule 70 呈报

## 📋 变更标注表（Rule 74.3）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|----------------|---------|
| CA-1 | critical-rules-verification.md（Rule 84 域末段后 append） | 新增 | 增量 | 「引入交叉验证…从方法层面上来识别出执行错误」 | F1 侦察锚 | 插入 Rule 108 五子条全条款 |
| CA-2 | verification-gate/SKILL.md（触发面/描述段） | 修改（加句） | 增量 | 「完成执行验证。化相关的技能以及步骤」 | F1 | 加 Rule 108 触发句 |
| CA-3 | task-planner/SKILL.md（卫星路由表 verification-gate 行+核心域索引段） | 修改（加句/计数演进） | 增量 | 同 R5 | F1/F3 | verification-gate 行加 108；索引段按宽容锚先例更新 |
| CA-4 | verification.md 模板（段尾 append） | 新增 | 增量 | 「完成执行验证…步骤」 | F1 | 加「交叉验证记录」区块 |
| CA-5 | selftest-cross-validation.sh（新建） | 新增 | 增量 | 同 R3/R5 | F2 注册机制 | 断言脚本 |
| CA-6 | selftest-registry.tsv（末行追加） | 修改（加行） | 增量 | 同 R3 | F2 | 注册新 selftest |
| CA-7 | 「1-107」级联族（selftest-enumerate-first.sh 等，按 F3 枚举） | 修改（宽容锚演进）或零动作 | 增量（演进登记） | 同 R5 | F3 四形态实测 | 按侦察结论处置，零动作也登记 |

## 📚 必要知识储备（任务知识库对齐）

| 类别 | 名称/主题 | 定位（路径） | 必读级别 | 已确认 |
|------|-----------|--------------|---------|--------|
| 项目内部文档/知识库 | 验证域规则全文（Rule 84）与落点文件结构 | skills/verification-gate/references/critical-rules-verification.md | 必读 | ☑ |
| 项目内部文档/知识库 | selftest 注册机制与行格式 | skills/task-planner/scripts/selftest-registry.tsv + run-selftests.sh | 必读 | ☑ |
| 项目内部文档/知识库 | 级联插改先例（S-unit 格式/106.1a/宽容锚） | plans/archive/task-tpl-sediment-20261115/task_plan.md | 参考 | ☑ |
| 项目内部文档/知识库 | Rule 51.14 档位/Rule 103 双轮质检条款现状 | skills/task-discipline/references/critical-rules-discipline.md + skills/task-dispatch/references/critical-rules-dispatch.md | 参考 | ☐（P1-S1 侦察确认） |
| 项目内部文档/知识库 | 伪造判例锚 | memory: subagent-verifier-fabricated-output-20261103（判例事实：verifier 编造「原始输出」，行号/字段与盘上不符） | 参考 | ☑ |

## ⚠️ 核心问题定义（强制）

**核心问题**: 现有验证链有独立复检但缺方法论级交叉验证强制框架——验证者可轻信执行者自我声称（判例：verifier 编造输出未被告警），需把「隔离上下文+多角度+分歧升级+反虚构」固化为可执行、可 grep、可守护的规则条款。

**核心问题判断**:
- [x] 核心问题解决后，产品/结果能交付吗？——能：条款+级联+守护+实弹四件套落地即交付
- [x] 核心问题不解决，其他工作都白费吗？——是：识别错误能力是本任务唯一目标
- [x] 核心问题的解决方法是清晰的、可执行的？——是：五子条结构+级联 SOP 先例齐备

## 🔍 调研需求与检索计划（Rule 75.1）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道 | 预期产出形态 | 网络解难评估 |
|---------------|------|------------------|----------|--------------|--------------|
| P1-S1 侦察 | LOCAL-ONLY | Rule 84 结构、selftest registry 格式 | 本仓 Grep/Read | findings F1-F6 | 不适用 |
| P1-S2 起草 | LOCAL-ONLY | 交叉验证条款、判例锚格式 | 本仓先例对照 | clause-drafts.md | 不适用 |

> 全任务无 NET-* 条目：纯本仓实现（侦察/起草/插改/守护/回归），无外部数据依赖（豁免声明：LOCAL-ONLY 全覆盖）。

## 🔍 证据面清单（Rule 58.1）

n/a（纯执行类：交付物=条款文本+级联+守护脚本+实弹报告，非归因/对比结论；设计依据=侦察一手取证 F1-F6 落 findings）

## Current Phase

Phase 4

## Next Step

P4 收口：run-verification.sh 全 VC 复验→84.14 收尾回读→smart-merge-back --deploy→清理 worktree→land 108→部署 diff=0 核验→归档→kb 入库

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 Explore（侦察）+ general-purpose（起草） | 搜索定位/文本起草按路由表 |
| Phase 2 | Agent 子代理 general-coder（默认档）×5 | 结构文件插改/新建，粒度门内 |
| Phase 3 | Agent 子代理 code-runner-agent + critic + general-purpose（并行组 verify，宽 2） | 回归机械跑+独立复检+dogfood |
| Phase 4 | 机械守卫脚本（smart-merge-back/check-complete/archive-plan/rule-reserve） | 收口白名单 |

**workflow 编排判定（Rule 40.4）**: 未命中 39.8 激活条件（串行链为主，最大并行宽度 2，不足 fan-out 门槛）→ Rule 21.4 独立性守门调度（并行默认+声明制）
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户以 /goal 锚定本任务（untrusted_objective=R1-R5 逐字源）

## Phases

### Phase 1: 侦察与起草（Discovery & Drafting）
- [ ] 侦察验证链插入点/守护面/级联族（F1-F6 落 findings）
- [ ] 起草 Rule 108 条款草案+模板 CV 区块草案（clause-drafts.md）
- [ ] 知识储备必读项确认（上表 ☑ 项已在位）
- **V-N:** VC-1, VC-2（侦察正确性支撑条款锚与级联落位）——V-1.1=6/6 PASS、V-1.2 五子条锚=11 处+§3 在位 PASS（progress 留痕）
- **Status:** complete
- **Executor:** Explore（默认档）/ general-purpose（默认档）

<!-- S-unit 派发单元表(Rule 22.6)：10 列固定列序，禁增列禁管道转义 -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 侦察验证链插入点与守护面：Rule 84 规则文末段锚/SKILL 触发面/task-planner 索引段「1-107」串族/selftest 注册机制/verification 模板结构/51.14+103 条款现状/判例锚格式先例 | Explore（默认档） | skills/verification-gate/references/critical-rules-verification.md（结构+末段锚）+ skills/task-planner/scripts/selftest-registry.tsv（行格式） | findings.md F1-F6 六节齐且各含 file:line 锚；级联族四形态枚举入 F3 | 15min | 1f/50l/15min | 无 | - | complete |
| S2 | (A6) 起草 clause-drafts.md：Rule 108 五子条全文（108.1 定义与触发面/108.2 独立重推导/108.3 双视角交叉/108.4 分歧升级/108.5 伪造信号）+verification 模板 CV 区块草案+级联 spec（§1/§2/§3） | general-purpose（默认档） | plans/task-crossvalidate-20261115/findings.md（F1-F6 消费）+ plans/task-crossvalidate-20261115/user-session-log.md（R1-R5 锚） | 草案在位+五子条锚齐+判例锚句在位+级联 spec 三节 | 15min | 1f/90l/15min | 无 | S1(P1) | pending |

### Phase 2: 落地插改（worktree 内实施）
- [ ] Rule 108 条款+SKILL 级联+模板区块+守护脚本+registry 全部落 worktree
- [ ] 每 S-unit 106.1a 三规约（grep 段清单/锚行子串/结构回读）
- [ ] 规范召回（Rule 93）：3 S-unit 后主进程 Read execution-recall-card.md 留 [recall] 行
- **V-N:** VC-1, VC-2, VC-3——V-2.1..V-2.4 全 PASS（worktree 实跑：108 锚=5/双 SKILL+模板锚齐/CV 6/6 exit0/EN 7/7）；103.6 清单六项全绿；worktree commit 8097063（7 文件 +59/-11）；drift ✅ALIGNED（checkpoint 4-drift-p2.md）
- **Status:** complete
- **Executor:** general-coder（默认档）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) Rule 108 条款插入 worktree critical-rules-verification.md（Rule 84 域末段后 append，增量原则） | general-coder（默认档） | worktree skills/verification-gate/references/critical-rules-verification.md（锚=F1 末段行）+ plans/task-crossvalidate-20261115/clause-drafts.md §1 | grep '108\.[1-5]' 各 ≥1+既有 Rule 84 段零改动+回读段序完整 | 15min | 1f/85l/15min | 无 | S2(P1) | pending |
| S2 | (A6) 级联 A：verification-gate/SKILL.md 触发面加 Rule 108 句+task-planner/SKILL.md 卫星路由表 verification-gate 行加 108+核心域索引段更新 | general-coder（默认档） | worktree skills/verification-gate/SKILL.md（触发面段）+ worktree skills/task-planner/SKILL.md（索引段+路由表行） | 两文件 grep 'Rule 108' 各 ≥1+邻行零改动+结构回读 | 10min | 2f/12l/10min | 无 | S1(P2) | pending |
| S3 | (A6) 级联 B：按 F3 枚举处置「1-107」级联族（宽容锚演进或零动作登记，禁盲改） | general-coder（默认档） | worktree skills/task-planner/scripts/selftest-enumerate-first.sh（F3 指认行）+ plans/task-crossvalidate-20261115/findings.md（F3 结论） | 处置后该脚本本机 exit 0+处置登记 findings F3 段 | 10min | 1f/8l/10min | 无 | S2(P2) | pending |
| S4 | (A6) 新建 worktree selftest-cross-validation.sh（断言 108 五子条+级联锚+判例锚）+registry.tsv 追加行 | general-coder（默认档） | worktree skills/task-planner/scripts/selftest-registry.tsv（F2 行格式+末行）+ plans/task-crossvalidate-20261115/clause-drafts.md §1 | 脚本 chmod+x 且本机 exit 0+registry 新行 grep=1 | 15min | 2f/70l/15min | 无 | S1(P2) | pending |
| S5 | (A6) verification 模板段尾追加「交叉验证记录」区块（落点按 F1 侦察结论定） | general-coder（默认档） | worktree skills/task-planner/templates/verification.md（段尾）+ plans/task-crossvalidate-20261115/clause-drafts.md §2 | 区块锚 grep=1+selftest-v* 模板家族本机 exit 0 | 10min | 1f/15l/10min | 无 | S1(P2) | pending |

### Phase 3: 验证（回归+复检+dogfood 实弹）
- [ ] 全量回归与 master 基线对照分账
- [ ] critic 全文回读复检（103.3/103.3a）回执落 checkpoint
- [ ] dogfood：按新 Rule 108 对产出本身执行双视角交叉验证
- **V-N:** VC-3, VC-4, VC-5——V-3.1 PASS（wt 全量 98 脚本 FAIL=2≤基线 3）/V-3.2 PASS（轮2 APPROVED）/V-3.3 PASS（报告判定行）；CR 链闭环+dogfood 报告双路径+drift ALIGNED 4/4（checkpoint 9-drift-p3.md）
- **Status:** complete
- **Executor:** code-runner-agent（默认档）/ critic（默认档）/ general-purpose（默认档）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 全量回归：worktree 跑 run-selftests.sh 全量+主仓 master 同命令基线对照分账（预存量 vs 新增） | code-runner-agent（默认档） | worktree skills/task-planner/scripts/run-selftests.sh + 主仓基线输出（tmp/ 基线文件） | ΣFAIL 增量=0+新增 selftest PASS 行在 progress | 15min | 1f/0l/15min | 无 | S1-S5(P2) | complete |
| S2 | (A6) critic 独立复检：全文回读 5 个变更文件对照 R1-R5 逐条核验+103.3 五要素回执 | critic（默认档） | worktree skills/verification-gate/references/critical-rules-verification.md（Rule 108 段）+ plans/task-crossvalidate-20261115/user-session-log.md（R 锚） | 回执五要素齐+CR 结论行（APPROVED/CHANGES_REQUESTED） | 15min | 1f/0l/15min | 无 | S1-S5(P2) | complete |
| S3 | (A6) dogfood：按 Rule 108 对 Phase 2 产出执行双视角交叉验证（机械面=VC-1/2/3 命令重推导；语义面=S2 回执）→cross-validation-report.md | general-purpose（默认档） | plans/task-crossvalidate-20261115/clause-drafts.md（验证对象清单 §1-§2）+ Phase 3-S2 checkpoint 回执（路径见 Handoff 表） | 报告含双路径结论段+一致/分歧判定行+108.4 协议留痕 | 15min | 1f/40l/15min | 无 | S1(P3)、S2(P3) | pending |

### Phase 4: 收口（Delivery）
- [ ] VC 全量复验（run-verification.sh 统一入口）+Rule 84.14 收尾回读梳理（连续一轮零新发现才出 outcome）
- [ ] 合并回：worktree 全 VC 复验+status 干净→smart-merge-back.sh（--deploy）→清理 worktree/分支→主仓 Read 复验
- [ ] 簿记：rule-reserve.sh land 108+三文件回填+Index 刷新+commit
- [ ] 部署位同步核验（--deploy 通道+diff=0）
- [ ] 归档：set-active-plan.sh --clear→archive-plan.sh task-crossvalidate-20261115（守卫拒绝则登记理由）
- [ ] 知识提取入库：scripts/kb-sync-from-plan.sh→精炼→kb-rebuild-index.sh
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** 主进程（例外理由:① git 编排+② 簿记+⑤ 机械守卫脚本——Rule 25.3 白名单）

## 🔁 收尾回读梳理记录（Rule 84.14）

| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    |                              |                      |

## 🔀 隔离决策（冲突分析）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号① 28 文件未提交变更=并行会话遗留且与本任务 scope 零重叠；信号⑤ 4 个运行中基础设施文件；信号③ 遗留 wt/task-v168-machine-parked 分支不触碰） |
| `isolation` | `worktree`（信号⑤ 命中+§11.1 ④⑥ 实现类强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-crossvalidate-20261115` |
| `branch` | `wt/task-crossvalidate-20261115` |
| `merge_back` | `pending` |

> 契约详见 skills/task-planner/references/worktree-isolation.md。合并前自检：主仓与本任务 scope 重叠的未提交变更=0（plan-resume/todo-skill/workflow-model-tiers 三 SKILL 与 plans/task-clause-generalize 归档删除均不在 scope）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|---------|---|---|---|-----|------------------------------|
| Phase 2 | 结构文件插段吞锚/既有断言破坏 | 8 | 5 | 6 | 240 | 106.1a 三规约前置+增量原则+失败即 22.3 ⑤ 拆细重派；回退=worktree 内 git restore |
| Phase 3 | 回归 FAIL 分账误判（预存量混淆） | 6 | 4 | 5 | 120 | 先跑 master 基线分账（22.3 ④ 主进程接管复算）；可疑行单跑对照 |
| Phase 4 | 合并冲突/部署位漂移 | 7 | 4 | 5 | 140 | smart-merge-back 前三自检（11.3）+deploy 后逐文件 diff=0 核验；冲突则 STOP 呈报 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-11-15 | S1 两组结构（任务组+基线组 B1-B5） |
| Phase 2 | ☑ | 2026-11-15 | 同步于计划展示前 |
| Phase 3 | ☑ | 2026-11-15 | 同步于计划展示前 |
| Phase 4 | ☑ | 2026-11-15 | 同步于计划展示前 |

## Key Questions

1. Rule 108 五子条的触发面档位如何定？（草案：完成声称 ≥L2 终验/多文件变更集终验/子代理验证类产出采信前/用户要求；mini/L0 豁免——执行期按 F4/F6 侦察对照既有档位体系定稿）
2. 「1-107」级联族是纪元断言还是无关字面？（P1-S1 F3 实测后处置，禁盲改）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Rule 108 落 verification-gate 卫星（非 task-discipline） | 域归属=验证域（Rule 84 同域）；Rule 82 分层纪律 |
| dogfood 实弹纳入 VC-4 | 方法论固化必须实弹验证——「规则写了但方法没用」恰是本任务要根治的缺陷面（R1 可观察判据） |
| Phase 3 双轮质检第二轮由 critic 承接草稿态豁免 | 复检对象=落位终态文本强于草稿态复检，避免同内容双审（103.7 登记） |
| code_review=n/a | 内容组画像；bash 断言脚本 ≤70 行由 critic+回归双检覆盖 |
| D1 自动裁决记录（Rule 44.3 五要素）：超时值=5min（44.1 默认）；推荐项=按已展示计划执行；触发时间=2026-11-15 计划呈现后；裁决理由=/goal 完成性指令场景命中 44.3 自动通过口径；被覆盖的未决选项=无（无 D2/D5/D6 硬分叉，五子条措辞属可变量自主裁决项） | Goal 绑定确认：Goal 行原文+user-session-log.md #1 用户原话已复述（见呈现记录），attest 锁定含绑定 |
| PLAN TAMPERED 重锁登记（Rule 51.7）：attest(df128c51) 后 task_plan.md 的变更均为流程操作性编辑——Phase 状态翻转/Drift Log 行/Current Phase/Next Step/S-unit 状态列/本登记行，无语义重规划；两条级联修订（EN-06 ',107' 保持不动/CV-03 收紧）已登记 findings Technical Decisions；处置=重跑 attest-plan.sh 重锁 | Rule 51.7 重锁前置=Decisions 已登记本行；重锁时间 2026-11-15（会话恢复续推） |
| 二次重锁登记（Rule 51.7）：verification.md V-3.2 机器面路径修正——原写预想路径 p3s2-critic-checkpoint.md，实际 checkpoint=subagent-state/8-critic-r2.md（critic 轮2 APPROVED 回执）；属 Phase 内路径机械纠偏非 VC 语义变更 | 路径以实际 checkpoint 落盘为准（108.2 独立重推导：验证命令须引用真实产出物）；二次 attest SHA 见 .plan-attestation |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
|       | 1       |            | → progress.md Error Log |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-11-15 P1 翻转前 | ✅ALIGNED | VC-1/VC-2 前置 | checkpoint=subagent-state/1-drift-p1.md；ledger drift_check 已追加；仓库无关脏态已分账不属本任务 scope |
| 2026-11-15 P2 翻转前 | ✅ALIGNED 4/4 | VC-1/VC-2/VC-3 | checkpoint=subagent-state/4-drift-p2.md；findings 仅追加 [sub:2-drift-p2]；test-gaming 排查过（enumerate-first 仅纪元字面）；主仓脏改无证据归属本任务 |
| 2026-11-15 P3 翻转前 | ✅ALIGNED 4/4 | VC-3/VC-4/VC-5 | checkpoint=subagent-state/9-drift-p3.md；CR 链 CHANGES_REQUESTED→fix 2abe3ec→APPROVED 闭环；分歧 D1 追溯链完整（F7 勘误+草案+预留注释）；回归分账口径未操纵 |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a |
| `rollback_point` | n/a |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 4（Phase 1-3 派发，Phase 4 主进程白名单） |
| 主进程直做 Phase 清单 | Phase 4（例外理由：① git 编排+② 簿记+⑤ 机械守卫脚本——Rule 25.3 白名单）；task_plan/findings/progress 回填（三文件回填白名单） |
| 委派率 | 0.75（≥0.7 达标） |
| 激活子代理数（Rule 96.5） | （执行期回填：预估 8） |
| 最大并行宽度（Rule 96.5） | 1 组 / 最宽 2（verify 组） |
| 串行化例外理由（Rule 96.4） | none（Phase 2 级联链存在真依赖；Phase 3 verify 组并行） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-15 | Explore | 侦察验证链插入点与守护面 | done | F1-F6 六节全锚返回：108 追加锚=规则文 EOF(:58 后)；级联族=SKILL:9/224/267+enumerate-first:9/92-97；CV 模板插入点=:127 后 :131 前 | findings.md ### F1-F6 | ### F1-F6 | - | - / 0 / ☑ |
| 2 | 2026-11-15 | general-purpose | 起草 clause-drafts.md | done | §1 五子条+§2 模板区块+§3 级联七项 78 行；主进程裁决修正 2 处（EN-06 ',107' 保持/CV-03 收紧）已登 findings | findings.md Technical Decisions | Technical Decisions | - | - / 0 / ☑ |
| 3 | 2026-11-15 | general-coder | Rule 108 条款插入 worktree 规则文 | done | +12 行；108.[1-5]=5/### 108=1/### 84=1 主进程盘上复核 PASS | subagent-state/2-insert-rule108.md | findings F7 | - | - / 0 / ☑ |
| 4 | 2026-11-15 | general-coder | 级联A 双 SKILL Rule 108 接线 | done | verifSKILL Rule 108=3/tpSKILL 84,108=1/1-108=3/1-107=0 盘上复核 PASS；自报 numstat 与实际 1 行出入（2/-1 vs 3/2）记 issues | subagent-state/3a-skill-cascade.md | findings F7 | - | - / 0 / ☑ |
| 5 | 2026-11-15 | general-coder | 守护脚本+registry 新建 | done | 脚本+78 行 chmod+x bash -n OK；registry 4 列 tab 行；实跑 5/6（CV-05 预期 FAIL 待模板单元） | subagent-state/3b-selftest-registry.md | findings F7 | - | - / 0 / ☑ |
| 6 | 2026-11-15 | general-coder | 模板 CV 区块插入 | done | +7 行 cv=1/h2=10 段序正确 主进程盘上复核 PASS | subagent-state/3c-template-cv.md | findings F7 | - | - / 0 / ☑ |
| 7 | 2026-11-15 | drift-checker | P1 翻转前偏移检查 | done | ✅ALIGNED 四项全 PASS | subagent-state/1-drift-p1.md | - | - | - / 0 / ☑ |
| 8 | | general-coder | 级联B EN-06 纪元演进 | queued | | | | | - / 0 / ☐ |
| 9 | | code-runner-agent | 全量回归分账 | queued | | | | | - / 0 / ☐ |
| 10 | | critic | 独立复检回执 | queued | | | | | - / 0 / ☐ |
| 11 | | general-purpose | dogfood 双视角交叉验证 | queued | | | | | - / 0 / ☐ |

## 🔗 Chain 区块交接配置

n/a（单 skill 任务，chain_mode: single）

## 🔁 模板感知

<!-- template_type: general -->
- 触发信号: 任务类型空缺 → 落 general 兜底（非 16 类已知类型之一）
- Rule 34.3②: 沉淀预登记 —— 终验时按 34.3 三条件评估是否沉淀为 variant
- 终验必查: check-complete T3 warn 兜底检索 [template-sense] token
- 处置登记处: 本任务为验证域规则落地，条款载体与既有 general 型先例（task-tpl-sediment）同构；不沉淀理由=无新增模板类型需求，属既有模板域的条款增量
