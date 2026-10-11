# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
- 用户原话（2026-09-18）：「单个处理都做不好 还恶意批量处理，和投毒有什么区别。记住在没有十足把握之前不要轻易尝试批量处理。我接受速度慢一点但不能接受批量处理出现问题」
- 派生需求：R1 批量启动前置=单件试点验证通过（硬门）；R2 单件失败未修复时批量=P0 投毒级违规；R3 速度理由一律无效（宁慢勿错）；R4 落点=当前技能（task-planner），不动 AGENTS.md

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Rule 18 八条款现状 | references/critical-rules.md:76-83 @c10e8f2 | ☑ | §Research Findings + §条款定稿 |
| Rule 18 详解 v2.2 全文 | references/batch-quality-gate.md:1-134 | ☑ | §详解段增补清单 |
| SKILL.md Rule 18 摘要行 | skills/task-planner/SKILL.md（Critical Rules 列表） | ☑ | §SKILL 联动 |
| 行数断言三处 | selftest-knowledge-brief.sh:38 / selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72 | ☑ | §断言清单 BP-08 |
| CD-19 宽容锚 | selftest-conclusion-discipline.sh:78（锚 `隶属 Rules 1-3[56]` 于 batch-quality-gate.md:130） | ☑ | §联动审计（改"十一条款"保留该子串，CD-19 不破） |

## Research Findings
- **缺口实锤**：18.1-18.8 全部是批中/批后门控（18.2 双采样 ≥10 单元、18.3 熔断、18.6 Batch Report），无任何"批量启动前单件试点"硬门；batch-quality-gate.md §一 Q3 的「先 3-5 单元试点」仅是**不可回滚时**的补救动作（非普适前置）——用户纪律缺口真实
- **联动审计（宽口径）**：「八条款」字样全仓 5 处，其中本任务范围 2 处（batch-quality-gate.md:25 §二标题、:130 §七）；cost-control.md:25/168 + templates/cost_log.md:69 的 3 处属 **Rule 17 八条款，禁碰**
- **引用面核查**：batch-quality-gate 被 7 文件引用，全部为泛引用或 §三/§四 指针，唯一内容级锚=CD-19 的 `隶属 Rules 1-3[56]`（L130 行内，保留子串即不破）
- **critical-rules.md 无行数断言**（grep selftest-*.sh 零命中）；SKILL.md Rule 18 行无他 selftest 锚定子串（"前置 3 问评估" 零命中）→ 行内改安全
- **共享账本实况**：.zcode/ledger/task-planner-maintenance/ 12 条历史（INDEX"0 条记录"为陈旧计数）；活跃认领仅本任务 1 条，v082 未登记无冲突（Rule 30.4 ✓）；约定=追加式（完成时追加 done 行）
- **并行 v082**：范围=Rule 35 族 35.6 插入式（需 35.6→35.7 级联）+ SKILL.md C23/Rule 35 行 + selftest-conclusion-discipline.sh + CHANGELOG；与本案（Rule 18 族追加式）同文件异条款区、零行交叠；其 plan/worktree/分支全程禁碰

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Rule 18 族内追加 18.9-18.11（非新 Rule 37） | 批量权威源单点（critical-rules + batch-quality-gate 同源），防双权威源漂移；纯追加零重编号零级联（对比 v082 插入式需 35.6→35.7 级联） |
| SKILL.md 净增 0 行 | 三处 ≤548 断言不扩围；兼容 v082 VC-2 的 wc=543 预期（并行友好） |
| 零新 config 键 | Rule 18 现无键；文本纪律+selftest 静态守护（Rule 35/task-v076 先例）；行为门控沿用既有 Batch Report 机器校验不扩权 |
| 18.9 把握四构成含「首批小步 ≤5 单元」 | 对齐 Q3 既有「3-5 单元试点」口径与用户「小步快跑」理念；宁慢勿错的操作性定义 |
| 自建 selftest-batch-pilot.sh（非扩既有） | 22 个既有 selftest 无 Rule 18 专属守护；独立脚本符合每规则一守护的 house style |

---

## §条款定稿（S1 材料包 — critical-rules.md L83 后逐字追加，3 行）

```markdown
18.9 **试点先行硬门（Pilot-First Gate，task-v083）**:任何批量操作(对 ≥2 个同构对象执行同一写操作:脚本循环/循环派发子代理/批量 API 调用/批量 Edit 写入)启动前,必须先选 1 个代表性样本完成单件「处理→端到端验证」全链路试点且通过,验证证据(命令+输出结论)落 progress.md;试点未通过或未做 → 禁止启动批量。「有十足把握」的最低构成 = ①单件试点通过 ②首批小步(≤5 单元,验证通过后逐步放大) ③批间抽检(18.2) ④可回滚/可枚举已写对象——四者缺一即视为无把握
18.10 **单件失败禁批量(投毒红线,task-v083)**:单件处理失败且未完成根因定位(Rule 31.2)与修复复验时,启动或继续批量 = P0 投毒级违规(明知单件不可靠仍扩大爆炸半径);处置:立即中止在跑批量 → 枚举盘点已写对象 → 逐对象回滚或修复 → 按 Rule 31 归因沉淀;用户 2026-09-18 训诫在案:「单个处理都做不好还恶意批量处理,和投毒有什么区别」
18.11 **宁慢勿错(task-v083)**:18.9/18.10 的任何豁免理由中「为了快/省时间/任务急」一律自动无效;宁可用单件串行慢速完成,不可用未验证批量承担出错风险;用户明示接受降速换正确性(2026-09-18),速度收益不得作为跳过试点/抽检的理由(与 Rule 26「速度收益不得作为跳过验证的理由」同构)
```

## §详解段增补清单（S2 材料包 — batch-quality-gate.md 7 处改动）

1. **L1** 版本号：`v2.2` → `v2.3`
2. **L25** §二标题：`Rule 18 八条款` → `Rule 18 十一条款`
3. **L37 后**（18.8 行之后）追加表 3 行：
```markdown
| **18.9** | **试点先行硬门**：批量启动前必须先对 1 个代表性样本完成单件「处理→端到端验证」试点且通过（证据落 progress.md）；试点未通过或未做 → 禁止批量；「十足把握」最低构成 = 试点通过 + 首批小步（≤5 单元）+ 批间抽检（18.2）+ 可回滚/可枚举已写对象 | 试点证据检查（progress.md） | 无试点记录直接全量跑 |
| **18.10** | **单件失败禁批量（投毒红线）**：单件失败且根因未定位/未修复复验时启动或继续批量 = P0 投毒级违规；立即中止 + 盘点已写对象 + 逐对象回滚或修复 + Rule 31 归因 | 批量启动前置检查 | 单件 FAIL 后批量照跑 |
| **18.11** | **宁慢勿错**：「为了快/省时间/任务急」一律无效理由；宁单件串行慢速，不赌未验证批量；用户 2026-09-18 明示接受降速换正确性 | 理由审查 | 以速度为由跳过试点/抽检 |
```
4. **§五表尾**（L110 `article-batch-publisher` 行后）追加：
```markdown
| Rule 31（错误学习闭环） | 18.10 投毒红线处置链直接消费 31.2（根因定位）/31.4（沉淀）；单件失败先归因再谈批量，禁直接重跑 |
```
5. **§六表尾**（L122 `unfoldtech` 行后）追加：
```markdown
| 用户 2026-09-18 投毒训诫（单件未验证即批量） | 18.9/18.10/18.11（试点先行 + 投毒红线 + 宁慢勿错） |
```
6. **L130** §七：`Rule 18 八条款（核心载体，隶属 Rules 1-36）` → `Rule 18 十一条款（核心载体，隶属 Rules 1-36）`（**保留 `隶属 Rules 1-36` 子串**，CD-19 锚不破）
7. **文末**（§七之后）新增 §八：

```markdown

---

## 八、试点先行硬门详解（18.9-18.11，task-v083）

> 用户训诫原文（2026-09-18）：「单个处理都做不好，还恶意批量处理，和投毒有什么区别。记住在没有十足把握之前不要轻易尝试批量处理。我接受速度慢一点，但不能接受批量处理出现问题。」

### 批量定义（18.9 适用范围）
对 **≥2 个同构对象**执行**同一写操作**即为批量——含脚本 for 循环、循环派发子代理、批量 API 调用、批量文件写入。纯读操作（批量 grep/批量 Read）不在此门内（仍受 Rule 13 隔离约束）。

### 试点流程（批量启动前置，四步）
1. **选样**：从待处理全集选 1 个代表性样本（优先中等难度/含边界特征，禁挑最容易的）
2. **单件处理**：按正式流程完整处理该样本（禁用"先随便跑跑"的简化版逻辑）
3. **端到端验证**：用与批量验收相同的客观标准验证（18.2 ground truth 同款），禁"看着没问题"
4. **证据落盘**：命令+输出结论写入 progress.md；试点未通过或未做 → 禁止启动批量

### 与既有门控的分层关系（防误读）
| 门 | 时机 | 适用 |
|----|------|------|
| **18.9 试点先行** | 批量**启动前** | 任何批量（≥2 单元）——单件都做不好就没有批量的资格 |
| §一 Q3「3-5 单元试点」 | 批量**启动前**（仅不可回滚时） | Q3 失败的补救动作，是 18.9 的子集场景 |
| **18.2 双采样** | 批量**运行前/后** | ≥10 单元——批中抽检，不豁免 18.9 前置 |
| **18.3 熔断** | 批量**运行中** | failure_rate 超阈止损 |

### 投毒红线处置（18.10 触发后）
立即中止在跑批量 → 枚举盘点已写对象（`rollback_point` 起增量清单）→ 逐对象回滚或修复 → Rule 31.2 归因（禁直接重跑）→ notepad 沉淀后重来（含 18.9 试点）。

### 宁慢勿错（18.11）
「为了快/省时间/任务急」在 18.9/18.10 语境下自动无效。用户明示（2026-09-18）：接受速度慢，不接受批量出错。单件串行慢速完成 > 未验证批量赌运气。
```

## §SKILL 联动（S3 材料包 — Rule 18 摘要行行内改，净增 0）

现文：
```markdown
- **Rule 18 批量处理质量门控**：批量操作禁止以牺牲质量/准确性为代价；前置 3 问评估 + 双采样抽检 + 失败率熔断 + Batch Report 八字段（详见 `references/batch-quality-gate.md`）
```
改后：
```markdown
- **Rule 18 批量处理质量门控**：批量操作禁止以牺牲质量/准确性为代价；试点先行硬门（18.9-18.11：单件未验证禁批量、单件失败即投毒红线、宁慢勿错，task-v083）+ 前置 3 问评估 + 双采样抽检 + 失败率熔断 + Batch Report 八字段（详见 `references/batch-quality-gate.md`）
```
（wc -l 必须=543；不新增 C25 检查行——净增 0 约束优先，Rule 18 族历史上亦无 C 行）

## §CHANGELOG 草稿（S4 材料包 — `### 新增` 下首条）

```markdown
- **批量试点先行硬门（task-v083）** — 补齐 Rule 18 批量质量门控的启动前置维度（用户 2026-09-18 训诫「单个处理都做不好还恶意批量处理=投毒；无十足把握禁批量；宁慢勿错」）：`references/critical-rules.md` Rule 18 族末尾纯追加 **18.9 试点先行硬门**（批量启动前必须对 1 个代表性样本完成单件「处理→端到端验证」且证据落 progress.md；十足把握=试点通过+首批小步 ≤5 单元+批间抽检+可回滚四构成）、**18.10 单件失败禁批量**（投毒红线：根因未定位/未修复复验即启动或继续批量=P0 违规，立即中止+盘点已写对象+Rule 31 归因）、**18.11 宁慢勿错**（「为了快」一律无效理由）；`references/batch-quality-gate.md` v2.2→v2.3（§二表 3 行+「八条款」→「十一条款」两处联动+新增 §八试点先行详解：批量定义/试点四步/与 Q3·18.2·18.3 分层关系/投毒红线处置链）；`SKILL.md` Rule 18 摘要行行内联动（净增 0 行，≤548 断言未触）。守护：`scripts/selftest-batch-pilot.sh`（新，BP-01..10：三条款锚+编号连续性 18.1-18.11+SKILL 行联动+详解段+行数回归钉+CD-19 子串保护+CHANGELOG 锚）。纯增量（Rule 36.3 删除基线=分支点 c10e8f2，diff 实证零语义删除）；零新 config 键、零新 Rule 编号。
```

## §断言清单（S5 材料包 — selftest-batch-pilot.sh，house style `check "cmd" "desc"`+计数+Total）

| ID | 断言 | 目标文件 |
|----|------|---------|
| BP-01 | grep `^18\.9 ` 含「试点先行」 | critical-rules.md |
| BP-02 | grep `^18\.10 ` 含「投毒红线」（「单件失败禁批量」） | critical-rules.md |
| BP-03 | grep `^18\.11 ` 含「宁慢勿错」 | critical-rules.md |
| BP-04 | 编号连续性：for i in 1..11，`grep -c "^18\.$i "` 各=1 | critical-rules.md |
| BP-05 | Rule 18 行含「试点先行」 | SKILL.md |
| BP-06 | 含 `| **18.9**`/`| **18.10**`/`| **18.11**` 表行 | batch-quality-gate.md |
| BP-07 | 含 `## 八、试点先行硬门详解` | batch-quality-gate.md |
| BP-08 | wc -l ≤548（行数回归钉，不用 =543 硬钉防未来扩围误伤） | SKILL.md |
| BP-09 | 含 `隶属 Rules 1-36`（CD-19 子串保护钉） | batch-quality-gate.md |
| BP-10 | 含「批量试点先行硬门（task-v083）」 | 仓库根 CHANGELOG.md |

## Resources
- 用户训诫原文：见 §Requirements（2026-09-18，本任务唯一上游需求源）
- v082 并行计划（只读参考）：plans/task-v082-minimal-probe/task_plan.md
- 行数断言三处：selftest-knowledge-brief.sh:38 / selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72
- CD-19 锚：selftest-conclusion-discipline.sh:78
- 共享账本：.zcode/ledger/task-planner-maintenance/task-planner-maintenance.jsonl（本任务认领行 2026-09-17T19:18:09Z）

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| attest 时 plan-dispatch 对「≤15min」报 SKIPPED 时长不可解析 | advisory 不阻断（attest 成功）；后续计划预估列写纯 `NNmin` 格式 |
| 共享账本 INDEX.md「0 条记录」与实际 12 条不符 | 陈旧计数，P5 簿记时顺带修正 |

#### [sub:1-code-assistant] S1 派发失败→④接管记录
- code-assistant 两次派发均 Provider server error（mini 探针 PASS 证明环境分档存活，haiku-1 档不可用，v081 同族症状）→ 按 v080 教训停止重试，预登记的 Rule 22.3④ 主进程接管生效
- 接管执行：critical-rules.md 18.8 行后追加 18.9/18.10/18.11 三行；自验 grep 18.1-18.11 各=1、git diff numstat=3增0删、deleted-lines=0
- 证据：worktree skills/task-planner/references/critical-rules.md:84-86

#### [sub:2-code-assistant] S2 接管执行记录
- batch-quality-gate.md 七处改动：v2.2→v2.3 / §二标题八→十一条款 / 18.8 行后表 3 行 / §五加 Rule 31 关系行 / §六加用户训诫行 / §七八→十一条款（保留 CD-19 子串）/ 文末新增 §八详解段
- 自验：git diff numstat=37增3删，删除行恰为 3 处机械联动（零语义删除）；`| **18.9/10/11**` 表行各=1；「八条款」残留=0；隶属 Rules 1-36=1；文件 134→168 行
- 证据：worktree batch-quality-gate.md:1,25,38-40,110-111,123,130,143-168

#### [sub:3-code-assistant] S3/S4/S5 接管执行记录
- S3：SKILL.md:287 Rule 18 摘要行行内改（「试点先行硬门（18.9-18.11…）」前置插入）；wc -l=543 净增 0
- S4：CHANGELOG.md `### 新增` 首条插入 task-v083 bullet（+2 行）
- S5：selftest-batch-pilot.sh 新建（BP-01..10，ok/bad+Total 行 house style）；**教训**：BP-10 CHANGELOG 路径 SKILL_ROOT/../../../ 多跳一层落到 worktree 父目录致 SKIP，改 SKILL_ROOT/../../ 后 10/10 PASS；部署环境（~/.zcode 等）无仓根 CHANGELOG → BP-10 显式 SKIP 不计 FAIL
- 证据：worktree SKILL.md:287 / CHANGELOG.md:12 / selftest-batch-pilot.sh:1-105；Total: 10 PASS=10 FAIL=0

#### [sub:4-code-runner-agent] P4 selftest 全量运行结果（2026-09-18）
- 范围：worktree `/home/terry/task-planner-skill-worktrees/task-v083-batch-pilot-first`，共 23 个 selftest 脚本（22 既有 + 新增 selftest-batch-pilot；子代理原写 22 系计数笔误，主进程修正）
- 全部 rc=0；主进程逐 Total 行亲算求和 = **376 PASS / 0 FAIL**（基线 v081=366 + batch-pilot 10，算术闭合）；Total 行逐条原文见检查点 subagent-state/4-code-runner-agent.md
- 证据：checkpoint path = `/mnt/data/dev/task-planner-skill/plans/task-v083-batch-pilot-first/subagent-state/4-code-runner-agent.md`
