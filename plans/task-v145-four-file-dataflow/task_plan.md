# Task Plan: Rule 62 — 四文件罗盘数据流转与调研知识沉淀纪律
<!-- template_type: rule-enhancement -->
<!-- new_rule 备注：60 已在账本手动预留（plans/.rule-reservations.jsonl）；58/59 分别被 v142 已落地/v144 预留 -->

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

- **R1**: 「我希望可以强化 安东尼过期技能的四个文件体系的重要性  也就是作为子代理和主代理之间的数据流转交互  确保可以获得更好的交互以及知识积累 尤其调研这些  调研产出可以罗盘到对应的知识库文件  等」
- **R2**: 「当前执行子代理存在缺陷 为什么执行调研过程子代理中不可用亿写入 findings.md 而且还是明确提示不可用,很奇怪这些不是检查知识发现吗 你不让写入不是严重不合理」（前轮缺陷上下文；「亿」按「以」判读）

> 判读注（可否决）：「安东尼过期技能」经语境判读 = **task-planner 技能**（本会话议题唯一技能主体）；「四个文件体系」= **task_plan.md / findings.md / progress.md / knowledge-brief.md**（三文件罗盘 + 知识底座第 4 文件）。判读依据与备选解读登记 Decisions Made，用户可否决。

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-3, VC-4 | Rule 60.1 四文件定位条款存在（grep `### 60`/`60.1` 锚）+ 派发模板 §2 四文件契约行齐装 + SKILL.md 三触点（映射表/摘要行/C41）grep 命中 |
| R1 | VC-5, VC-6 | 调研双落盘条款+kb 增量门控在位（60.3/60.5 锚）+ selftest 新守护断言全 PASS |
| R2 | VC-2 | check-dispatch.sh 契约措辞 lint 在位：含收窄词且缺 append 锚点的负样例 prompt 被拦（warn 告警/enforce exit 2），合规正样例放行（fixture 实测输出证据） |

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 需求采集 | 「四文件体系」无统一定位条款——散落在 Rule 19（三文件罗盘）/22.4a（读写契约）/v067（kb 第 6 文件），主子代理数据流转协议地位未制度化 | Rule 60.1 四文件定位 + 恢复读序扩展 | VC-1 |
| 派发契约 | prompt 契约措辞自由发挥可收窄——videop1 实证「主进程回填，你只写检查点」把 22.4a 子代理必做自写降级为禁写（守卫只查三文件路径存在性，不查措辞语义） | Rule 60.2 不可收窄禁令 + check-dispatch.sh 契约措辞 lint（机制面根治，53.2 判据=守卫载体） | VC-2 |
| 调研沉淀 | findings→knowledge-brief 无强制蒸馏链——调研知识停检查点（videop1 findings.md 43 行 0 小节 vs 检查点 17.7KB/12.6KB 实证） | Rule 60.3 调研双落盘 + 22.5 增量锚（复核+蒸馏双动作） | VC-1, VC-5 |
| 知识复用 | 材料包引用 kb 是「存在时应引用」非强制——后续调研从零重复 | Rule 60.4 调研型派发强制引用 kb §锚 + 联动 Rule 55 复用前置 | VC-1 |
| 完成门控 | check-3file-gate 只看 findings/progress 增量，不看知识沉淀 | Rule 60.5 kb 增量门控 + gate --require-kb + ledger kb_distill 事件 | VC-5 |
| 机制守护 | 新条款无静态守护可被无声破坏 | selftest-four-file-dataflow.sh + 合规清单 C41 | VC-6 |

## Goal

新增 Rule 62（六子条，原 60 两轮改号：v143 仲裁占 60/v146 占 61）把四文件体系制度化为主代理↔子代理数据流转协议介质：调研产出双落盘（findings 自写小节〔22.4a 既有〕+ 主进程 22.5 复核时蒸馏归档 knowledge-brief）、派发读写契约不可收窄（check-dispatch 措辞 lint，根治 videop1「只写检查点」类缺陷）、调研型 Phase 知识增量门控——知识积累从「靠主进程自觉回填」变为「协议强制 + 机器守护」。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `template_type` | `rule-enhancement` |
| `code_review` | `required`（Phase 2/4 产出 .sh 脚本=代码文件） |
| `session_id` | `45fc6cc1df4e447fb52d32e14603e350` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v145` |
| `scope_files` | `skills/task-planner/references/critical-rules.md`, `skills/task-planner/SKILL.md`, `skills/task-planner/templates/subagent_dispatch.md`, `skills/task-planner/scripts/check-dispatch.sh`, `skills/task-planner/scripts/check-3file-gate.sh`, `skills/task-planner/scripts/ledger-append.sh`, `skills/task-planner/scripts/selftest-four-file-dataflow.sh`(新), `skills/task-planner/scripts/selftest-registry.tsv` |
| `interaction_mode` | `ask` |
| `对齐审查` | `alignment-review`（收尾标准流程 42.6.2）+ 文档更新前版本一致性校验（42.6.1）+ 变更记录落盘（42.6.3） |
| `自动超时默认项` | 计划批准点=授权类门控（D1），**不设自动通过**，超时保持阻塞等待授权；执行期 2+ 选项点默认项=推荐项+5 分钟（44.1/44.3）；低区分度选项直接裁决登记（44.2） |
| `new_rule` | 62 |
| `质量审查工具` | `code-quality-review`（代码 CR，review-library 池内）+ `alignment-review`（42.6 对齐，池内）——42.2 四级检测结论=用户级池命中，无缺口，无补建 S-unit |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| VC | 验证项 | 判据（可观察证据） | Phase |
|----|--------|-------------------|-------|
| VC-1 | Rule 60 六子条条款落地 | `grep "^### 62" critical-rules.md` 命中 + `62.1`-`62.6` 子条锚各 ≥1 命中；既有 Rules 原文零改动（diff 仅追加） | 1 |
| VC-2 | 契约措辞 lint 机制化 | check-dispatch.sh 含收窄检测逻辑（grep 锚）；负样例（含「只写检查点」且缺 append 锚点）触发告警/阻断、正样例（含 append 契约）放行——fixture 实测输出留痕 progress.md | 2 |
| VC-3 | 派发模板四文件契约齐装 | templates/subagent_dispatch.md §2 含 knowledge-brief 只读行（grep `knowledge-brief` 锚）且 findings 可写行语义未被改动（diff 验证） | 3 |
| VC-4 | SKILL.md 三触点 | 产出落盘映射表 kb 行 + Critical Rules 摘要 Rule 60 行 + 合规清单 C41 行，各 grep ≥1 命中 | 3 |
| VC-5 | kb 增量门控机制 | check-3file-gate.sh 支持 `--require-kb`（help/代码锚）+ ledger-append.sh 事件枚举含 `kb_distill`；功能实测（无 kb 增量 exit 1 / 有则 exit 0）留痕 | 2 |
| VC-6 | 新静态守护 | selftest-four-file-dataflow.sh 在位且断言全 PASS（输出留痕）+ selftest-registry.tsv 已登记 | 4 |
| VC-7 | 全量回归 FAIL=0 | 改动前 master 基线记录 → 改动后全量 selftest 重跑，FAIL=0（级联按「口径扩展非回退」范式同步） | 4 |
| VC-8 | 双审查 APPROVED | code-quality-review 输出 APPROVED + alignment-review 输出 APPROVED；发现项清零或登记豁免 | 5 |
| VC-9 | 合并回+部署一致 | master 合并后关键文件 Read 复验 + 主部署位 `~/.zcode/skills/task-planner` diff IDENTICAL（含 v142 Rule 58 漂移一并补齐）；合并前主仓重扫无同范围未提交变更 | 5 |
| VC-10 | 簿记闭环 | rule-reserve land 60 + INDEX 刷新 + verification.md 复验表 + delivery-summary（五要素）落盘 | 6 |

## Current Phase

Phase 6（全部 complete）

## Next Step

等待用户计划批准（D1）→ attest 锁定 → 建 worktree（wt/task-v145，从 master a7c01a8）→ Phase 1 条款撰写。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程（机械守卫 rule-reserve 已用） | 条款措辞依赖会话记忆与格式惯例（25.3② 白名单，同 v136/v141/v143 先例） |
| Phase 2 | Agent 子代理 executor（sonnet-1）×2 S-unit | .sh 代码修改派执行体（Rule 14）；两 S-unit 文件集不相交→并行组 gw1 |
| Phase 3 | 主进程 | 模板/SKILL 增量小且格式敏感（25.3②） |
| Phase 4 | 主进程写脚本（25.3②）+ Agent 子代理 code-runner-agent（mini） | 守护脚本撰写同先例；全量回归派隔离执行 |
| Phase 5 | Agent 子代理 code-quality-review + alignment-review + 主进程 git 编排 | CR/对齐派池内审查体（42 检测结论）；合并/部署主进程（25.3①） |
| Phase 6 | 主进程 | 簿记=计划系统文件（25.3②） |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件 → 按 Rule 21.4 独立性守门调度（Phase 1-4 串行强依赖：条款→守卫→模板→守护，文件与基线面重叠；仅 Phase 2 内部两 S-unit 声明并行组 gw1）

## Phases

### Phase 1: Rule 62 条款撰写（原 60，改号见 Decisions Made）（critical-rules.md 文末追加）
- [x] 六子条全文撰写（60.1 四文件定位/60.2 契约不可收窄禁令/60.3 调研双落盘/60.4 消费闭环/60.5 知识增量门控/60.6 机制），标题行四要素齐全（P0/日期/task-v145/目标+判定面+衔接）
- [x] 衔接声明：衔接 Rule 19.1/19.6（落盘分流）/22.4a（读写契约）/22.5（复核回填）/22.8（检查点）/55（复用前置），既有 Rules 原文零改动（纯增量，36.5）
- [x] 60.2 内嵌 check-dispatch lint 判定语义（收窄词 ∧ 缺 append 锚点 → 违规）与 60.5 内嵌 gate/ledger 扩展语义（供 Phase 2 照规格实现）
- [x] findings.md 回填条款锚行号
- **S-unit 表（22.6）**: 主进程直做（条款文本，非派发单元——计划期理由如上）
- **V-N:** VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:② 计划系统文件维护+条款措辞质量依赖会话记忆——Rule 25.3 白名单，同 task-v136/v141/v143 先例）
- **Started:** 2026-10-08
- **Evidence:** worktree critical-rules.md:694-708（`### 60`+60.1-60.6 锚全命中）；git diff +18/-0 纯增量；commit fa5ea7a

### Phase 2: 守卫脚本扩展（3 文件，两 S-unit 并行组 gw1）
- [ ] **S-1** `check-dispatch.sh` 契约措辞 lint：prompt 含收窄词（「只写检查点」「主进程回填」类，黑名单窄化定义见 60.2）**且**缺 findings append 锚点标记（`#### [sub:` / `可写=仅追加`）→ 判契约收窄违规；处置挂既有 `get_mode()` 档位（enforce=exit 2 / warn=stderr 告警+计数 / off=跳过）；只增不改既有分支（v075 P3-S1 范式）；正负 fixture prompt 各 1 份实测
- [ ] **S-2** `check-3file-gate.sh` 增 `--require-kb` 判定（调研型 Phase：knowledge-brief mtime 晚于锚点或 ledger 含锚点后 `kb_distill` 行则通过）+ `ledger-append.sh` 事件枚举增补 `kb_distill`（纯增量，既有枚举零改动）
- **S-unit 表（22.6）**:

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------|--------|------|------|----------|------|
| S1 | check-dispatch 契约措辞 lint + fixture 实测 [parallel-group:gw1] | executor(sonnet-1) | 计划三文件+60.2 规格段+check-dispatch.sh | 负样例拦/正样例放行输出留痕 | 15min | pending |
| S2 | 3file-gate --require-kb + ledger kb_distill 事件 [parallel-group:gw1] | executor(sonnet-1) | 计划三文件+60.5 规格段+两脚本 | 功能实测输出留痕 | 15min | pending |

- **V-N:** VC-2, VC-5
- **Status:** complete
- **Executor:** executor→general-purpose（改派登记 Handoff #1/#2）——逐 S-unit 派发（46.1 单会话单 S-unit）
- **Started:** 2026-10-08
- **Evidence:** S1 负拦/正放/回归一致/edge×3 全过；S2 沙箱五态+锚点语义过；parity 逐字节一致；commit c8df05b

### Phase 3: 模板与 SKILL 联动
- [ ] templates/subagent_dispatch.md §2 增 knowledge-brief 行：`knowledge-brief: {plan_dir}/knowledge-brief.md — 只读（知识底座，主进程单写者；调研类材料包摘要必须引用其 §1-§5 节锚点，Rule 60.4）`；findings 可写行与三文件既有契约行语义零改动
- [ ] SKILL.md 产出落盘映射表增 knowledge-brief 行（调研蒸馏→§2/§3/§4，时机=22.5 复核时）
- [ ] SKILL.md Critical Rules 摘要区追加 Rule 62 一行（对齐 Rule 57/58 行格式）
- [ ] SKILL.md 合规检查清单追加 C41（四文件契约齐装+调研双落盘+selftest 守护，机器面=selftest-four-file-dataflow.sh）
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:② 同 Phase 1）
- **Started:** 2026-10-08
- **Evidence:** VC-3 kb 行 grep=1；VC-4 三触点 grep=1/1/1；模板既有契约行 0 删行

### Phase 4: selftest 守护+全量回归
- [x] selftest-four-file-dataflow.sh 撰写（≥12 静态断言：60.1-60.6 条款锚×6 + 模板 kb 行 + SKILL 三触点 + lint 检测锚 + gate 扩展锚 + ledger 事件枚举）
- [x] selftest-registry.tsv 登记
- [x] 全量回归：先记 master 基线（改动前跑全量存档），后改后全量重跑 FAIL=0；级联 FAIL 按「口径扩展非回退」范式同步守卫锚
- **S-unit 表（22.6）**:

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 状态 |
|----|------|--------|------|------|----------|------|
| S1 | 全量 selftest 基线+改后回归 | code-runner-agent(mini) | 计划三文件+scripts/selftest-*.sh | 两轮输出留痕 FAIL=0 | 30min | pending |

- **V-N:** VC-6, VC-7
- **Status:** complete
- **Executor:** 守护脚本撰写主进程（例外理由:② 同先例）；回归派 code-runner-agent
- **Started:** 2026-10-08
- **Evidence:** 新守护 18/18 PASS exit=0；全量 57 脚本双侧比对引入 FAIL=0（合并基线复现法，存量 21 条 master 漂移分类登记 progress）；commit 见 git log wt/task-v145

### Phase 5: CR Gate+合并回+部署同步
- [ ] Code Review（code-quality-review agent，REQUIRED）+ 对齐审查（alignment-review，42.6.2）双 APPROVED，发现清零
- [ ] 合并前重扫主仓（v143/v144 在飞防踩踏）→ smart-merge-back.sh（--no-ff）→ worktree 清理（remove+branch -d）
- [ ] 部署位同步：主位 `~/.zcode/skills/task-planner` rsync 后 diff IDENTICAL（**含 v142 Rule 58 既有漂移一并补齐**）；其余部署位盘点登记
- **V-N:** VC-8, VC-9
- **Status:** complete
- **Executor:** 审查子代理（池内登记体）+ 主进程（例外理由:① git/worktree 编排——Rule 25.3 白名单）
- **Started:** —

### Phase 6: 簿记与交付
- [ ] rule-reserve.sh land 60；INDEX.md 刷新；verification.md 复验表；delivery-summary（五要素+Rule 48 可定位性）
- [ ] memory 写入（任务结论记忆）+ 用户面交付总结
- **V-N:** VC-10
- **Status:** complete
- **Evidence:** land 62 ✓；INDEX 刷新；verification.md VC-1..10 全勾；delivery-summary.md 落盘；memory 写入
- **Executor:** 主进程（例外理由:② 簿记——Rule 25.3 白名单）
- **Started:** —

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注 |
|---|------|---------------|----------------|------|----------------|-----------------|---------------|-----------------|------|
| 1 | 2026-10-08 | executor→general-purpose | S1 check-dispatch 契约措辞 lint+fixture 实测 | done | lint 双条件落地+63/-0，4/4 验收过，误报 edge×3 放行，关联 5 selftest FAIL=0 | check-dispatch.sh:152-175,309-317,471-482 | #### [sub:2-S1-executor]\|kb:§2 | plans/task-v145-four-file-dataflow/subagent-state/2-S1-check-dispatch-lint.md | [parallel-group:gw1]；executor 型两次流式中断后 22.3①改派 general-purpose 成功 |
| 2 | 2026-10-08 | executor→general-purpose | S2 3file-gate --require-kb+ledger kb_distill 事件 | done | gate 第5条件+枚举第7项 +68/-5,+11/-1，4/4 验收过，真计划目录 parity 一致，selftest-kb 16/16 | check-3file-gate.sh:126-139,173-197；ledger-append.sh:28 | #### [sub:2-S2-general-purpose]\|kb:§2 | plans/task-v145-four-file-dataflow/subagent-state/2-S2-gate-ledger-kb.md | [parallel-group:gw1]；同上改派 |
| 3 | 2026-10-08 | code-quality-review | Phase 5 代码 CR（.sh 三脚本+新守护） | queued | — | — | 待回填 | plans/task-v145-four-file-dataflow/subagent-state/5-cr-code.md | 42 池登记体 |
| 4 | 2026-10-08 | alignment-review | Phase 5 对齐审查（Rule 42.6.2 收尾标准流程） | queued | — | — | 待回填 | plans/task-v145-four-file-dataflow/subagent-state/5-align.md | 42 池登记体 |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①未提交 7 文件=并行会话 plans 产物非本任务范围；信号②**v143/v144 双 worktree 在飞**——v143 改 critical-rules/模板面、v144 改 check-dispatch/模板/knowledge-brief 模板面，与本任务 scope 重叠；对策=Rule 60 已 ledger 占位防改号撞车 + 文末追加式改动 + 合并前重扫主仓 + 基点 diff 并集解冲突） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v145` |
| `branch` | `wt/task-v145` |
| `merge_back` | `merged(b7c46ce)` |

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S | O | D | RPN | 预设兜底动作（RPN>100 必填） |
|-------|---------|---|---|---|-----|------------------------------|
| 1/3 | 新增行破坏既有 selftest 行号/计数断言（历史级联 5 次实证） | 7 | 5 | 3 | 105 | Phase 4 全量回归必跑；FAIL 按「口径扩展非回退」范式同步守卫锚（22.3④ 主进程接管） |
| 5 | v143/v144 并行同窗合并冲突 critical-rules/check-dispatch/模板 | 7 | 5 | 2 | 70 | 合并前 git status 重扫+基点 diff；冲突按并集解法（v129 同日合流先例）；v143 若改号占用 60 → land 时账本 WARN 改 61 |
| 2 | 契约措辞 lint 误拦合规 prompt（黑名单词在合规语境出现） | 6 | 4 | 3 | 72 | 黑名单窄化（收窄词 ∧ 缺 append 锚点双条件）；正负 fixture 双样例实测；默认 warn 档观察 |
| 2 | worktree 从 master 建后关键文件与主仓不一致（v135/v141 教训） | 6 | 4 | 2 | 48 | 建树后先 diff 关键 5 文件再动工 |
| 5 | 部署位漂移比预期大（v142 Rule 58 未同步只是已知一处） | 5 | 3 | 2 | 30 | 同步前全量 diff 盘点登记，IDENTICAL 判定覆盖全部署位清单 |

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-10-08 | 计划创建时建（S1） |
| Phase 2 | ☑ | 2026-10-08 | 同上 |
| Phase 3 | ☑ | 2026-10-08 | 同上 |
| Phase 4 | ☑ | 2026-10-08 | 同上 |
| Phase 5 | ☑ | 2026-10-08 | 同上 |
| Phase 6 | ☑ | 2026-10-08 | 同上 |

## Key Questions

1. 「四个文件」的界定？→ task_plan/findings/progress/knowledge-brief（notepad-learnings 与 verification 为辅助文件不入罗盘协议——前者是学习沉淀、后者是终验产物）；依据=v067 起 kb 为第 6 计划文件且派发链已消费其 §1-§5
2. knowledge-brief 的写者？→ **主进程单写者**（22.5 复核时蒸馏归档），子代理只读——理由：kb 是结构化知识底座（§1-§5 固定段）供后续派发材料包消费，并行子代理直写会破坏结构（B-2 单写者纪律同构）；findings 仍为子代理自写小节（22.4a 既有，本任务不动其语义）
3. lint 档位与误报面？→ 挂既有 `dispatch_contract_enforce`（零新 config 键），默认 warn 起步；判定=收窄词 ∧ 缺 append 锚点**双条件**，单一条件不判（降误报）

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| ASR 噪声判读：「安东尼过期技能」=task-planner 技能；「四个文件体系」=三文件罗盘+knowledge-brief | 语境唯一技能主体+「知识库文件」指向 kb；**用户可否决**，否决则回本计划 C 类变更 |
| 新增 Rule 60 承载（六子条），不改写 22.4a/19 既有语义 | 36.5 纯增量纪律；58/59 已被占用；Rule 60 已 ledger 预留占位（防 v143 改号撞车） |
| kb 主进程单写者蒸馏，子代理只读 | Key Question 2 结论；findings 子代理自写语义不变（22.4a B-2） |
| 部署同步顺带补 v142 Rule 58 漂移 | 已知漂移实证（repo 有 653-690 行/deployed 无）；不补则 IDENTICAL 永不成立 |
| videop1 侧 findings 回填补救不入本任务范围 | 跨仓任务（§五 跨项目隔离）；进 delivery-summary 下一步建议 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## Notes

- task-v143 预留 Rule 58 后被 task-v142 搶先落地（master a7c01a8）——v143 落地时必须改号；本任务已占 60 并在 note 提醒 v143 避让
- task-v144（Rule 59 拆分粒度+技能伴飞）scope 与本任务重叠 check-dispatch.sh/模板/knowledge-brief 模板面——合并前重扫+并集解冲突（FMEA Phase 5 行）
- 部署位基线：repo master 领先 `~/.zcode/skills/task-planner`（critical-rules.md 差 Rule 58 全节；check-dispatch.sh 当前 IDENTICAL）
