# Task Plan: CA-6 机器面授权接线与审计门行为测试

<!-- ===== frontmatter 头（Rule 16 选模板 + Rule 34.1 门控 + Rule 38.7 执行通道分级）=====
  本任务=Rule 109 审计门机器面授权实施（checker+attest 接线+selftest）与测试，
  复用既有 rule-enhancement 变体（显式选择，非 general 兜底）。 -->
template_type: rule-enhancement
plan_tier: standard
execution_lane: L1
parallel_groups: [p1-baseline]

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）

> 权威源=`plans/task-auditgate-machine-20261116/user-session-log.md` #1（2026-11-16，来源：用户新需求）。
> 原文条目第 12 行为「> 三、未完成项与风险 1 授权 2 测试」；同号理解镜像为非权威对照面，冲突以逐字原文为准（Rule 80.4）。

- **R1**: 「1 授权」<sub>（[目标]；逐字锚=user-session-log.md #1 原文「三、未完成项与风险 1 授权 2 测试」中的「1 授权」——CA-6 机器面从待授权候选转显式授权实施）</sub>
- **R2**: 「2 测试」<sub>（[目标]；同源逐字锚——审计门测试：机器面正负例+selftest 全绿+行为面自举实测）</sub>
- **R3**: 「三、未完成项与风险」<sub>（[手段]；同源章节锚——范围边界仅此两项，不扩其他机器面）</sub>

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2, VC-5 | checker fixture 正负例通过；attest 含 [audit-gate]/--skip-audit-check/缓存键（含 progress 哈希与 enforce 档）；Phase 5 merge-back 后主仓自举实测（rc=0+`[audit-gate]` 输出断言） |
| R2 | VC-3, VC-5, VC-6 | selftest 正负例+轻量豁免/L1+ 拒锁+mini/冲突档全过；Phase 5 merge-back 后主仓自举实测；全量回归**同集零增量**（`Failed:` 集合==Phase 1「selftest 基线冻结」7 名单，无新增 FAIL） |
| R3 | VC-4 | 109.8 仅授权 attest 审计门检查+对应 selftest；109.7 原文保留；其余机器面仍默认禁 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-auditgate-machine-20261116/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（Rule 80.7；非权威对照面，冲突以逐字原文为准）

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|----|
| 授权判定与范围冻结 | 把 CA-6 误扩为全部机器面，或未记录授权来源导致越权 | 109.8 限定授权范围=attest [audit-gate]+对应 selftest；109.7 原文保留；变更标注表逐行钉用户原话 | VC-4 |
| 门控判定器实现 | L1+ 判定口径错误（legacy 被拒锁）或 APPROVED 末段聚合错误（含**中间态假阳性**：末段 buf 吞进后随修复轮块的反引号元引用 → 未审也放行） | 独立 checker：显式 standard/L1/L2 才检查；末段 awk 聚合仅认 `^## [plan-audit-R<N>] ` 头且**聚合边界止于下一个 H2 `## ` 行**（不吞后随修复轮/留痕块）；APPROVED 判定用 **ERE 行首结构锚定**（`- 轮次: R<N>` + `审计体:` + `结论: **APPROVED**` 三段，完整正则见 verification.md VC-1，禁匹配反引号内/行中元引用）；三态 rc 0/1/2 | VC-1, VC-3 |
| attest 接线 | 缓存回放陈旧 PASS；skip 旗标/enforce 档/progress 留痕未纳入缓存键；门失败仍写锁 | cksum 纳入 skip_audit+AUDIT_GATE_ENFORCE+sha256(progress.md)；门置于 hash 取用前；失败 exit 1 不写 .plan-attestation | VC-2, VC-5 |
| 测试与行为实证 | 只有静态断言无行为级；fixture 污染真实 plans/；本计划自举时序错配（D1 时机器门尚不存在） | selftest 正负例+轻量豁免/L1+ 拒锁+mini/冲突档；/tmp fixture；D1 走既有文本审计链路（bootstrap: gate-absent），Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 自举实测并断言 `[audit-gate]` 输出 | VC-3, VC-5, VC-6 |
| 条款与索引联动 | 109.8 与 109.7 冲突；registry 漏登记导致回归不运行 | 109.7 原样保留；`^### 109 ` 计数=1 复核；registry 四列登记 | VC-4, VC-6 |

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3 — 声明后改动须走 73.2 对齐三问）

| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal 与 VC-1~VC-6；R1-R3 逐字锚与 R→VC 映射；109.7 原文逐字保留；109.8 仅授权 attest [audit-gate]+对应 selftest，其余机器面仍默认禁；零新 config 键（用 env-only TASK_PLANNER_AUDIT_GATE_ENFORCE）；L1+ 仅显式 standard/full 或 L1/L2 声明才进入检查面（无声明 legacy fail-open）；**自举条款=bootstrap: gate-absent**（D1 走既有文本审计链路；机器门=Phase 5 merge-back 后主仓自举实测）；`[plan-audit-skip]` 仅轻量档生效，L1+ 唯一逃生=`--skip-audit-check` 参数+WARN+交付披露；**lane 优先**（execution_lane L1/L2 必审，mini×L1 并存按最严=必审）；worktree 隔离 | 本文件 Goal/VC/R/不变量；user-session-log.md #1；critical-rules.md:210；progress.md [plan-audit-R1] F8/F11/F6 |
| 🔀 可变量 | S-unit 拆分与排期；[audit-gate] 消息串措辞；checker 内部实现；selftest fixture 布局与断言编号 | Phase 执行期 Decisions Made |
| 📈 学得量 | 执行期发现的锚点漂移、误报面、回归结果 → findings.md / knowledge-brief.md；禁反向改写不变量 | findings.md, knowledge-brief.md |

## Goal

在 task-planner 落地计划审计门机器强门（attest [audit-gate] 锁定前对 L1+ 校验 APPROVED、轻量档 [plan-audit-skip] 放行、独立 checker + selftest 正负例），并以 Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 并断言 `[audit-gate]` 输出（自举实测）验证机器门行为有效。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本与规则文档，终验前按轻/重 diff 触发 Code Review Gate） |
| `session_id` | `task-auditgate-machine-20261116` |
| `worktree_path` | `tmp/worktrees/task-auditgate-machine-20261116` |
| `scope_files` | `skills/task-planner/scripts/attest-plan.sh, skills/task-planner/scripts/check-plan-audit-gate.sh, skills/task-planner/scripts/selftest-plan-audit-gate.sh, skills/task-planner/scripts/selftest-registry.tsv, skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, plans/task-auditgate-machine-20261116/*` |
| `interaction_mode` | `ask`（D1 显式 yes；计划审计门不适用 Rule 44.3 自动通过） |
| `对齐审查` | `[登记]` 完成前对更新后的 SKILL.md / critical-rules.md 执行 alignment-review 或等价一致性校验并随交付落盘（Rule 42.6；standard 档不豁免） |
| `自动超时默认项` | `[D1 展示: 默认选项=按已展示计划执行 / 超时 5 分钟（Rule 44.3，仅审计 APPROVED 后适用）]`；审计门本身无自动通过 |
| `new_rule` | 留空（109.8 为 Rule 109 子条，不新增 Rule 编号） |
| `质量审查工具` | `critic（/home/terry/.zcode/agents/critic.md，计划审计）+ code-reviewer（CR Gate）+ decision-arbiter（Rule 69 分歧仲裁）+ verifier/run-verification（终验）` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

> **验证独立性**：VC 复验默认由独立子代理/全新上下文执行，主进程仅编排与簿记（Rule 33.3 延伸）。
> VC-1/VC-2 采用判别性专有 token + 基线负断言记录（改动前 `audit-gate` 在 attest-plan.sh/SKILL.md/critical-rules.md 均=0，见 findings 基线）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | （R1）审计门判定器落地（判别性）：新增 `check-plan-audit-gate.sh`——lane 优先（`execution_lane: L1/L2` 必审；`plan_tier: mini` 与 L1 并存按最严=必审）、显式 `plan_tier: standard/full` 必审、无声明输出 `[audit-gate] SKIP legacy-no-decl`、轻量档 `[plan-audit-skip]` 放行而 L1+ 写 skip 仍拒锁、末段 APPROVED 段须含 `审计体:`+`轮次:`+`问题清单` 最小形态（**`问题清单` 容忍全角/半角括注后接冒号**——唯一 APPROVED 段真实字节形态为 `- 问题清单（留档，不阻断）:`，按字面连写冒号判据会误拒真实 plan-dir（R7 I-1）；判据正则见 verification.md VC-1；`审计体:`/`轮次:` 维持字面）（**聚合边界止于下一个 H2 `## ` 行**——**该边界仅认 `^## `（H2），故审计段后随块必须用 H2 标题**，用 H3/粗体标题则边界不生效、约束静默退化（写作规范依赖，checker 注释须登记）、**结论行用 ERE 行首结构锚定**——`- 轮次: R<N>` + `审计体:` + `结论: **APPROVED**` 三段，完整正则见 verification.md VC-1；禁匹配反引号内/行中元引用）、rc 0/1/2（rc2 输出 `[audit-gate] WARN 判定器输入异常` 并 fail-open；**rc2 口径：progress.md 文件缺失/不可读=rc2，存在但空=无留痕 rc1**） | `bash -n` + fixture 正负例实测（无留痕 L1+→rc1；mini×L1 冲突→rc1；轻量 skip→rc0；**合规 APPROVED+三 token→rc0**；L1+ skip→rc1；APPROVED 缺形态→rc1；**中间态假阳性（REJECTED 段+后随含反引号 APPROVED 元引用的修复轮块）→rc1**；无声明 legacy→rc0 且输出含 SKIP legacy-no-decl；**真实生产形态（R6 字节形态：结论行带括注 + `问题清单` 带括注）→rc0**；**仅锚定假 PASS（段内裸文 APPROVED 意见文本）→rc1**；**仅边界假 PASS（后随 H2 块锚定 APPROVED 行）→rc1**；progress.md 删除→rc2 / 存在但空→rc1） | `skills/task-planner/scripts/check-plan-audit-gate.sh` |
| VC-2 | （R1）attest 接线落地（判别性）：`attest-plan.sh` 含 `[audit-gate]` 段、`--skip-audit-check` 解析、`_attest_cksum` 同时纳入 `skip_audit` 与 `TASK_PLANNER_AUDIT_GATE_ENFORCE` 及 `sha256sum progress.md`、门置于 `hash=` 前、失败拒锁且不写 `.plan-attestation`；rc2 fail-open+显式 WARN | `bash -n` + fixture 负例实测（无留痕 L1+ fixture 调 attest→exit≠0 且 `.plan-attestation` 不存在）+ **正向用例（APPROVED+三 token fixture→exit 0 且 `.plan-attestation` 存在）** + 缓存隔离用例（enforce→off→enforce 不复用陈旧缓存） | `skills/task-planner/scripts/attest-plan.sh` |
| VC-3 | （R2）selftest 正负例落地：`selftest-plan-audit-gate.sh` 覆盖静态 token + 行为断言（APPROVED 通过、无留痕 L1+ 拒锁、轻量档 skip 放行、L1+ skip 仍拒锁、mini 跳过、mini×L1 冲突必审、APPROVED 形态残缺 FAIL、rc2 输入缺失、缓存隔离；**R7/R8 增补判别用例以 verification.md:23 VC-3 全清单为权威**（真实生产形态正例 r7/仅锚定 fixture a/仅边界 fixture b/中间态假阳性/legacy SKIP/rc2=删文件），fixture 全在 `/tmp` 且正负例各用独立 task_plan 内容或每例清理 `/tmp/attest-cache-*`；脚本 exit 0 | 直接执行 `bash skills/task-planner/scripts/selftest-plan-audit-gate.sh`（exit 0 判）+ registry 行 `&&` 条件 | `skills/task-planner/scripts/selftest-plan-audit-gate.sh`、`skills/task-planner/scripts/selftest-registry.tsv` |
| VC-4 | （R3）条款与联动一致（判别性）：`critical-rules.md` 追加 109.8 且 109.7 原文保留；109.8 明确 skip 仅轻量档、L1+ 唯一逃生=`--skip-audit-check`；`^### 109 ` 计数=1；SKILL.md 审计门含机器面行（`[audit-gate]`/`--skip-audit-check`）；registry 含 `selftest-plan-audit-gate.sh` 四列行 | `test "$(grep -c '^### 109 ' ...)" -eq 1` + grep 109.8/--skip-audit-check/registry | `skills/task-planner/references/critical-rules.md`、`skills/task-planner/SKILL.md`、`skills/task-planner/scripts/selftest-registry.tsv` |
| VC-5 | （R1/R2）机器门自举实测：Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 `[audit-gate]` rc=0 且输出含 `[audit-gate]`（排除旧脚本/缓存回放假通过），命令/输出留痕 progress；D1 走既有文本审计链路（bootstrap: gate-absent） | 主仓 `check-plan-audit-gate.sh` 对本计划 rc=0 + 主仓 `attest-plan.sh` 对本计划 rc=0 且输出 grep `[audit-gate]`；执行时点=merge-back 后 | `plans/task-auditgate-machine-20261116/progress.md`、`plans/task-auditgate-machine-20261116` |
| VC-6 | （R2/R3）无回归：全量 selftest `--fresh` **同集零增量**——`Total:` 行 `FAIL=7` 且 `Failed:` 行与 Phase 1「selftest 基线冻结」7 名单**整行精确相等**（无新增 FAIL；断言面仍是全量回归，冻结已知存量失败集合而非降低断言强度——绝对 `FAIL=0` 会被跨任务共享仓他任务在途债确定性击穿）；部署位 `diff -r` 零差异（merge-back 后由 V-5.2 验证）；worktree `git diff --name-only master` + `ls-files --others`（untracked 口径，等效 `git add -N`）⊆ `scope_files`（merge-back 前执行）；`user-session-log.md` 未改、config.json 未新增键 | `bash .../run-selftests.sh --fresh` 的 `Total:` 行 `FAIL=7` + `Failed:` 行整行等值断言（冻结名单见 Phase 1 块）+ worktree 范围断言（含 untracked）+ V-5.2 部署位 diff | `progress.md` Phase 5、`task_plan.md` Phase 1「selftest 基线冻结」、`verification.md` |

**终验规则**：
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**（列出 + 建议后续）
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**（升级用户决策）

> **注意**：`code_review: required`，终验前必须先通过 Code Review Gate，否则不得标记 COMPLETE。计划审计门不适用 44.3 自动通过。

## 🛡 双轮质检与同步完整性声明（Rule 103 — 计划期设计位，standard 必填）

| 登记项 | 值 |
|--------|-----|
| 双轮质检适用面 | Phase 3（checker/attest/selftest）与 Phase 4（109.8/SKILL/registry）全部派发型实质产出 S-unit；Phase 1 调研产出 findings 锚点按 103.2/103.3 适用 |
| 豁免登记 | 纯只读基线核实若仅产出 findings 摘要且无独立产物文件，可登记轻量复核（Phase 1 S1/S2 由主进程盘上复核 findings 锚点） |
| 多文件变更集预判 | Phase 3（attest-plan.sh + checker + selftest 三文件）与 Phase 4（critical-rules.md + SKILL.md + registry 三文件）均触发 103.6；翻转前附同步核对清单 |
| 审计门与 103 边界 | 计划面由 Rule 109 审计门承载；执行期产物由 Rule 103 承载；二者不叠加 |

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填）

| 字段 | 值 |
|------|-----|
| **目标型需求** | R1, R2 |
| **裁决** | `solved（2026-11-17 终验：R1=机器面三件套+109.8+SKILL 落地；R2=selftest 16 断言+VC-2 行为+VC-5 自举+run-verification PASS=6 FAIL=0）` |
| **解决证据锚** | merge cf697f7（6 文件 +317/-2）；evidence/VC-1..6.out；VC-5=`[audit-gate] PASS: 末段审计留痕 [plan-audit-R8] APPROVED` rc=0；[plan-audit-R1..R8] 审计轨迹 |
| **未解决面+原因** | 存量 7 FAIL（他任务在途债，R3 边界排除，冻结基线零增量判据）；selftest-self-resolution 跨执行根 flaky（环境态依赖，已辨析留痕）；CR Q-1 默认 warn 档=首版起步（迁移披露+enforce 可 env 一行开启，已按获批计划 D1 登记） |
| **已排除路径** | 绝对 FAIL=0 判据（存量债确定性击穿，改同集零增量）；段锚 awk 消费 EOF 追加留痕（R5 I-1）；live worktree 断言（R4 I-1）；子串 skip 判定（自指计划误触发） |
| **下一步建议** | 存量迁移观察期后可切 enforce（env 一行）；md-edit-ops 孤儿行随 task-mdedit-reliability 收口消解 |

## 🎯 Goal 单元表（Rule 66.1 — attest 获批后逐步落证据，standard 必填）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 基线核实 | 产出 attest 插入锚/档位口径/selftest 范式与基线负断言 | `grep -c 'audit-gate' skills/task-planner/scripts/attest-plan.sh` 基线=0 + findings 锚点行 | Phase 1 S1/S2 | done（`grep -c 'audit-gate' …`=0 基线复核（worktree）+ findings S1/S2 锚点段）  |
| G2 | 设计定稿 | [audit-gate] 规格与 selftest 断言清单定稿并登记变更表 | Read Decisions Made + 变更标注表 CA-7~CA-12 行 | Phase 2 | done（findings Design Decisions D1-D6 + CA-7~CA-12 终态）  |
| G3 | 门控落地 | checker + attest 接线 + selftest 正负例全落地 | `bash -n` 三脚本 + `bash skills/task-planner/scripts/selftest-plan-audit-gate.sh` exit 0 | Phase 3 S1-S3 | done（`bash -n` 三脚本 rc=0 + selftest Total 16 PASS=16 FAIL=0 + VC-1 七态 rc=0）  |
| G4 | 条款联动 | 109.8 + SKILL 机器面行 + registry 行一致 | `grep -c '^### 109 ' skills/task-planner/references/critical-rules.md` 等于 1 且 grep 109.8/--skip-audit-check/registry 命中 | Phase 4 S1-S2 | done（`grep -c '^### 109 '`=1 + VC-4 exit=0（109.8/SKILL 行/registry 行全命中））  |
| G5 | 回归交付 | 全量 selftest **同集零增量**（`Failed:` 集合==Phase 1 冻结 7 名单，无新增 FAIL）+ 部署位一致 + 本计划 Phase 5 merge-back 后主仓自举实测 rc=0 且含 `[audit-gate]`（D1 走既有文本审计链路） | `bash skills/task-planner/scripts/run-selftests.sh --fresh` 的 `Total:` 行 `FAIL=7` 且 `Failed:` 行==冻结名单 + 三部署位 diff -r 零差异 + 主仓 `attest-plan.sh` 对本 plan-dir rc=0 且输出含 `[audit-gate]` | Phase 5 S1-S2 | done（主仓 Total 100 PASS=93 FAIL=7 且 Failed=冻结 7 名单逐字一致 + 部署位 IDENTICAL + VC-5 自举 rc=0 含 `[audit-gate]`）  |

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码/脚本 | `skills/task-planner/scripts/attest-plan.sh`、`skills/task-planner/scripts/check-plan-audit-gate.sh`（新建）、`skills/task-planner/scripts/selftest-plan-audit-gate.sh`（新建） | 其他脚本、无关重构 |
| 配置/登记 | `skills/task-planner/scripts/selftest-registry.tsv`（仅追加一行） | 改 config.json 或新增配置键 |
| 文档/规则 | `skills/task-planner/SKILL.md`（仅审计门区块加机器面一行）、`skills/task-planner/references/critical-rules.md`（仅追加 109.8） | 改 109.7 原文、改其他规则语义 |
| 计划产物 | `plans/task-auditgate-machine-20261116/*`（task_plan/findings/progress/verification/knowledge-brief/notepad-learnings；user-session-log 只读） | 其他计划目录 |

**执行前自我检查:**
- [ ] 这个文件在上面的列表中吗？
- [ ] 这个修改对完成任务有必要吗？
- [ ] 用户明确要求我做这个修改吗？
- 全部 Yes → 可以执行 | 任一 No → 先问用户（问询按 Rule 70 四要素）

## 📋 变更标注表（Rule 74.3 — 修订方案必填，无表=无效方案）

| 编号 | 对象（文件+锚点） | 类型（新增·修改·删除·更新） | 吸收判定（增量·替代·删除） | 用户原话（逐字） | 依据（证据） | 执行动作 |
|------|------------------|---------------------------|-----------|----------------|------------------------|---------|
| CA-7 | `skills/task-planner/scripts/check-plan-audit-gate.sh`（新建，attest 门前的独立判定器） | 新增 | 增量 | 「1 授权」 | attest 门链 :540-562 无审计检查；check-tier-consistency.sh:1-70 是 shell-out 判定器范式；**既定聚合形态在中间态假阳性**（主进程 2026-11-17 /tmp 一手实测：REJECTED 段+后随含反引号 APPROVED 元引用的修复轮块 → 旧形态 rc=0 假 PASS / 加固形态 rc=1） | 新增 checker：lane 优先（L1/L2 必审，mini×L1 按最严）+显式 standard/full 判定、无声明显式 SKIP legacy-no-decl、APPROVED 末段 awk 聚合（**① 聚合边界止于下一个 H2 `## ` 行**，不吞后随修复轮/留痕块的元引用）**+ ② 结论行 ERE 行首结构锚定**（`- 轮次: R<N>` + `审计体:` + `结论: **APPROVED**` 三段，完整正则见 verification.md VC-1；禁匹配反引号内/行中元引用）+ 最小形态（审计体/轮次/`问题清单`——**`问题清单` 容忍全角/半角括注后接冒号**，真实段形态 `- 问题清单（留档，不阻断）:`；R7 I-1）、轻量档 skip 放行/L1+ skip 拒锁、rc 0/1/2（rc2 显式 WARN+fail-open；**progress.md 缺失/不可读=rc2、存在但空=无留痕 rc1**；R7 Q-2）、**聚合边界仅认 H2 `## `——审计段后随块必须用 H2 标题（H3/粗体标题则约束静默退化，注释须登记该前提；R7 Q-1）**、两约束各配独立负例（fixture a=仅锚定假 PASS（段内裸文 APPROVED 意见文本）/ fixture b=仅边界假 PASS（后随 H2 块锚定 APPROVED 行）；R7 I-2） |
| CA-8 | `skills/task-planner/scripts/attest-plan.sh`（skip 旗标 :26-45 / 缓存键 :88 / hash 取用 :562 前） | 修改 | 增量 | 「1 授权」 | 既有 --skip-dispatch-check 同型；缓存键未含新旗标与 enforce 档会回放陈旧 PASS；progress 审计证据变更须失效缓存 | 新增 `--skip-audit-check` + `[audit-gate]` 段 + `_attest_cksum` 同时纳入 `skip_audit`、`TASK_PLANNER_AUDIT_GATE_ENFORCE` 与 `sha256sum progress.md` + 缓存回放 WARN；调用 checker（lane 优先/APPROVED 最小形态）；失败不写锁 |
| CA-9 | `skills/task-planner/scripts/selftest-plan-audit-gate.sh`（新建） | 新增 | 增量 | 「2 测试」 | selftest-vc-nonvacuous.sh:29-174 断言范式；registry T02 要求新脚本登记 | 新增 selftest：静态 token + 行为断言（APPROVED 通过/无留痕拒锁/轻量 skip 放行/L1+ skip 拒锁/mini 跳过/mini×L1 冲突必审/形态残缺 FAIL/rc2/缓存隔离），/tmp fixture，正负例独立 task_plan 内容或每例清理 `/tmp/attest-cache-*` |
| CA-10 | `skills/task-planner/references/critical-rules.md:210-212`（109.7 后、Why 前） | 新增 | 增量 | 「1 授权」 | 109.7 现文「未经显式授权禁实施」；2026-11-16 用户授权 #1 仅覆盖 CA-6 机器面 | 追加 109.8 机器面已授权范围（含 skip 仅轻量档、L1+ 唯一逃生=--skip-audit-check）；109.7 原文逐字保留；`^### 109 ` 计数仍=1 |
| CA-11 | `skills/task-planner/SKILL.md:68-77`（审计门区块） | 修改 | 增量 | 「1 授权」 | 审计门文本已落地；缺机器门一行 | 追加一行：attest [audit-gate] + --skip-audit-check + mini/L0 跳过 + selftest 指针 |
| CA-12 | `skills/task-planner/scripts/selftest-registry.tsv`（追加一行） | 新增 | 增量 | 「2 测试」 | registry 四列契约；T02 无缺失/T03 无孤儿 | 追加 `selftest-plan-audit-gate.sh` 四列登记行 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 | attest 门链、skip 旗标与缓存键契约 | `skills/task-planner/scripts/attest-plan.sh:26-99,106-198,540-562` | 必读 | ☑（计划期已 Read） |
| 规范/标准 | 档位/D 档解析与 rc 契约 | `skills/task-planner/scripts/check-tier-consistency.sh:1-70` | 必读 | ☑ |
| 规范/标准 | selftest 断言/fixture 隔离/registry 四列 | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh:29-174`、`selftest-plan-dispatch.sh:12-30`、`selftest-registry.tsv:1` | 必读 | ☑ |
| 规范/标准 | Rule 109 现文与 SKILL 审计门 | `skills/task-planner/references/critical-rules.md:194-212`、`skills/task-planner/SKILL.md:68-77` | 必读 | ☑ |
| 项目内部文档 | 先例计划审计留痕形态 | `plans/archive/task-planaudit-20261116/progress.md:119-208`、`verification.md:28-30` | 参考 | ☑ |
| 项目内部文档 | 三条铁律教训 | `knowledge/entries/task-planaudit-20261116.md:32-36` | 参考 | ☑ |

## ⚠️ 核心问题定义（强制 - 任务开始前必须回答）

**核心问题**: 如何把已落地的计划审计门从「文本条款」升级为「可机器拒锁的硬门」，并用正负例测试证明门链有效，同时不误伤轻量档与既有 attest 门链？

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？——是：L1+ 计划未审计 APPROVED 时 attest 拒锁，已审计/轻量档放行，selftest 与 Phase 5 自举实测双证据。
- [x] 核心问题不解决，其他工作都白费吗？——是：只有文本条款时审计门可被跳过，机器面授权目标未达成。
- [x] 核心问题的解决方法是清晰的、可执行的？——是：独立 checker + attest shell-out + 缓存键修正 + selftest 四态 + 本计划自身走门。

**问题解构四问（T2）**:
1. **问题是什么**：用户对「三、未完成项与风险」给出「1 授权 2 测试」——把 CA-6 机器面从待授权候选转为显式授权实施，并测试审计门。
2. **本质是什么（5 Whys）**：
   - 为什么需要机器门？文本门依赖模型自觉，可能被跳过（RCA：计划产出→D1 之间无独立复核）。
   - 为什么文本门可被跳过？attest 只校验结构/模板/VC/FMEA，不校验审计留痕，无机器事实源。
   - 为什么审计留痕可机器校验？留痕有固定形态 `[plan-audit-R<N>]` + `结论: **APPROVED**`，可 awk 聚合判末段。
   - 为什么需要分档？mini/L0/trivial 按比例原则豁免；一刀切会造成仪式膨胀。
   - 为什么需要 selftest 与自举实测？脚本会漂移/被误删；fixture 证明逻辑；D1 时新门尚不存在，故以 Phase 5 用新 attest 对本 plan-dir 实跑证明门在真实链路生效（bootstrap: gate-absent）。
3. **解决方案是什么（候选+取舍）**：
   - 候选 A：把审计检查内联进 attest-plan.sh——实现短，但难独立测试、易随门链漂移。
   - 候选 B：独立 `check-plan-audit-gate.sh` + attest shell-out——与 check-tier-consistency 同构，可独立 fixture 测试（选中）。
   - 候选 C：只加 selftest 不加 attest 门——不满足「机器强门」授权目标（否决）。
4. **执行方案是什么**：5 Phase / 9 S-unit；Phase 1 基线、Phase 2 设计冻结、Phase 3 checker+attest+selftest、Phase 4 109.8+SKILL+registry、Phase 5 回归+自举实测+合并部署；门控点=critic 文本审计 APPROVED → D1 → 既有 attest 锁定（bootstrap: gate-absent）→ 执行 → Phase 5 机器门自举实测。

## 🔍 调研需求与检索计划（Rule 75.1 — 计划期调研需求三态分析）

| S-unit/子目标 | 三态 | 检索关键词（≥2） | 检索渠道（63.2 四步链） | 预期产出形态 | 网络解难评估（R5） |
|---------------|------|------------------|--------------------------|--------------|-------------------|
| P1-S1/S2 基线核实 | LOCAL-ONLY | `audit-gate`、`plan-audit-skip` | 本地 Read/Grep | findings 锚点与基线负断言 | 否 |
| P3 门控实现 | LOCAL-ONLY | `attest-plan.sh`、`skip-audit-check` | 本地 Read/Grep | checker/attest 补丁 | 否 |
| P4 条款与联动 | LOCAL-ONLY | `Rule 109.8`、`selftest-registry` | 本地 Read/Grep | 109.8/SKILL/registry 变更 | 否 |
| P5 回归与交付 | LOCAL-ONLY | `run-selftests`、`smart-merge-back` | 本地 Bash | 回归与部署证据 | 否 |

> 三态判定：本任务为技能内脚本/规则增强，所需事实均在仓库内可定位；无外部事实依赖，故全为 LOCAL-ONLY。执行期若发现需外部标准佐证，按 Rule 75 追加 NET-* 条目并更新本表。

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）

| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | n/a（纯执行类：规则增强+脚本实现，无调研/归因结论面） | — | — | n/a |
| ② 对标样本（58.2 强制） | n/a（纯执行类） | — | — | n/a |
| ③ 外部约束 | n/a（纯执行类） | — | — | n/a |

> 纯执行类任务填 n/a（纯执行类）为 58.1 合法豁免；本任务不产出归因结论。

## Current Phase

Phase 1（基线已冻结含 selftest 存量基线；R1-R5 六发现链已逐轮修复收口，微修轮 4b 完成 VC-6 同集零增量对齐；**R6 复审 APPROVED（0C/0I，证据 subagent-state/audit-R6.md）**；**R6a 单点加固已落盘**（checker 末段聚合中间态假阳性：① 聚合边界止下一个 H2 ② 结论行 ERE 行首锚定）；**R7 范围化复审 REJECTED（0C/2I/2W/2Q/2N）→ 修复轮 7 已逐项收口**（I-1 token 容忍括注+真实形态正例 r7；I-2 r5/r6 两独立负例；W-2 legacy SKIP 用例；Q-1 H2 前提；Q-2 缺失=rc2/空=rc1），待 R8 复审；随后 D1 显式 yes 启动执行）

## Next Step

修复轮 7 增量修订已收口（I-1/I-2/W-2/Q-1/Q-2 全部实际 Edit 落盘 + /tmp 判别性实测 + 八机械门重跑，见 progress.md R7 修复轮段），交 critic **R8 复审**（Rule 109 既有文本审计链路），按 0C/0I 迭代；随后 D1 展示+yes，attest 经既有门链锁定（[audit-gate] 尚未存在，bootstrap: gate-absent），再派发 Phase 1 explore 子代理；机器门在 Phase 5 自举实测。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）

| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | Agent 子代理 explore（mini）；Read/Grep | 基线核实与范式检索属定位/分析，explore 隔离上下文且成本低 |
| Phase 2 | 主进程（编排/设计决策）；Read/Edit | 设计冻结与变更标注表维护属计划系统文件维护（25.3②），派发开销大于收益 |
| Phase 3 | Agent 子代理 executor（sonnet-1）；Read/Edit/Bash | checker/attest/selftest 为脚本实现，按 25.1/104 默认派发执行体 |
| Phase 4 | Agent 子代理 executor（sonnet-1）；Read/Edit/Grep | 109.8 条款与 SKILL/registry 联动为结构化文档变更，需精确增量 |
| Phase 5 | Agent 子代理 code-runner-agent（mini）；Bash/Grep/Read | 全量回归与部署为机械执行；合并/推送由主进程兜底接管 |

**workflow 编排判定（Rule 40.4）**: 未命中 Rule 39.8 激活条件（无 ≥3 独立并行 S-unit fan-out、非长链编排型、用户未点名 /workflow）→ 采用 Rule 21.4 独立性守门调度（Phase 1 内 S1/S2 无依赖已声明并行组 `p1-baseline`；跨 Phase 串行）。
**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 为会话目标证据源；`/goal` 为用户侧 harness 命令，技能层不可代调，执行期不虚构 /goal 状态。

## Phases

### Phase 1: 基线与设计冻结
- [x] S1 核实 attest 门链/skip 旗标/缓存键与 [audit-gate] 插入锚点（findings S1 段：锚点=:560/:561 之间，cksum 13 项+三预留位）
- [x] S2 核实 selftest 断言风格、/tmp fixture 隔离与 registry 四列登记契约（findings S2 段：ok/bad 模板+glob 自动发现+新行草稿）
- [x] 基线负断言记录（worktree 内复核 2026-11-17：audit-gate=0/0/0；两文件缺席；registry 行=0——findings S1 段）
- [x] selftest 存量基线冻结（`run-selftests.sh --fresh` 的 `Total:` 行与 `Failed:` 行原文 + 冻结日期 + 归属说明 → 本节末「selftest 基线冻结」块）——块已填（2026-11-17 实测 Total 99/FAIL=7 原文+7 名单+漂移双闸）
- [x] 设计规格落 findings/Decisions（档位判定/APPROVED 末段/豁免/rc 契约/缓存键）——Design Decisions D1-D6（Phase 2 定稿整合）
- **V-N:** VC-1, VC-2
- **Status:** complete
- **Executor:** explore（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | [parallel-group:p1-baseline] 核实 attest 门链与档位/D 档判据及 [audit-gate] 插入锚点 | 继承 | `skills/task-planner/scripts/attest-plan.sh:26-122`（skip 旗标/缓存键/门链顺序）+ `skills/task-planner/scripts/check-tier-consistency.sh:60-63`（plan_tier/execution_lane 精确解析与 rc 契约） | findings 记录插入锚点（window-lint 后/hash 前）、L1+/mini/L0/无声明判定口径、缓存键联动点 | 10min | 1f/60l/10min | 无 | - | done |
| S2 | [parallel-group:p1-baseline] 核实 selftest 断言风格/fixture 隔离/registry 登记契约 | 继承 | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh:29-174`（ok/bad+mktemp+Total 范式）+ `skills/task-planner/scripts/selftest-plan-dispatch.sh:12-30`（attest 集成 fixture 范式） | findings 记录断言模板、/tmp fixture 隔离、registry 四列登记格式 | 10min | 1f/50l/10min | 无 | - | done |

#### selftest 基线冻结（Phase 1 产出，2026-11-17 实测；VC-6「同集零增量」的对照集合）

> **用途**：VC-6 回归判据「同集零增量」的**冻结基线集合**。这**不是放宽断言**——断言面仍是全量 `run-selftests.sh --fresh`（全部 selftest 都跑、不缩子集），只是把「已知存量失败集合」冻结为对照面并判「无新增 FAIL」。绝对 `FAIL=0` 判据在跨任务共享仓下会被他任务在途债确定性击穿（Phase 5 必 FAIL → outcome 禁 COMPLETE），故按项目既有「同集零增量」惯例冻结基线集合。

```text
Total: 99 PASS=92 FAIL=7 (run=99 reused=0)
Failed: selftest-active-plan selftest-batch-pilot selftest-enumerate-first selftest-execution-stability selftest-registry selftest-self-resolution selftest-summary-readability
```

- **冻结日期**：2026-11-17（命令=`bash skills/task-planner/scripts/run-selftests.sh --fresh`；脚本 rc=1，因 7 项存量 FAIL）
- **归属说明**：7 项均为**其他在途任务遗留**在 `skills/task-planner/scripts/` 的未实现面（例：`selftest-registry` 的 T03 孤儿行 `selftest-md-edit-ops.sh` 属 `task-mdedit-reliability-20261116` 在途未实现面）。消解属 `skills/**` 保护区 + 他任务射程，R3 范围边界明确排除；本任务不改动其判定面，也不以改动判定面来「让回归变绿」。
- **判据语义**：执行期复跑时 `Failed:` 行须与上述 7 名单**整行精确相等**，且 `Total:` 行 `FAIL=7`；出现任何新 FAIL 名（如 `selftest-fake-new`）即判回归失败。
- **基线漂移条款（禁静默放宽；R5 W-1 双闸）**：若执行期该集合已因其他任务收口而变化（`FAIL<7` 或名单不同），由主进程重跑冻结新基线，并在 `progress.md` 记一行 `[baseline-shift] <ISO8601> <新 Total 行> | <新 Failed 行> | <逐名归因> | <重跑冻结依据> | <critic 简版复审结论>`，同步更新本冻结块与 `verification.md` VC-6 Verify command 的 `FAIL=<N>` 与名单字面量，改按新基线判同集零增量。**防滥用双闸（缺一即非法漂移）**：① **逐名归因**——名单中每个新增或消失的条目必须在 `[baseline-shift]` 行内指认对应他任务/提交锚（如 `task-mdedit-reliability-20261116 收口`）；**无法指认的新增 FAIL 不得吸收**（本任务自身新引入的 FAIL 一律判回归失败，禁以「他任务收口」名义豁免）；② **漂移后重走 critic 文本审计**——对判据字面量变更做简版复审并落 progress.md 留痕，**禁主进程自裁**。**未留 `[baseline-shift]` 行或归因/复审不全而判据松动 = 静默放宽，属违规**。

### Phase 2: 设计定稿与变更登记
- [x] [audit-gate] 规格定稿（findings Design Decisions D1：lane/skip/聚合两约束/容忍 token/rc 分层全规格）
- [x] selftest 断言清单与 fixture 规格定稿（findings D3；交付 16 断言=PAG-01..16——attest 写锁断言独立成项，CR N-3 口径修正）
- [x] 109.8 条款草案与 SKILL 机器面行草案定稿（findings D4/D5 逐字草案）
- [x] 变更标注表 CA-7~CA-12 逐行可执行登记（task_plan 变更标注表已随审计迭代终态化）
- **V-N:** VC-3, VC-4
- **Status:** complete
- **Executor:** 主进程（例外理由:25.3② 计划系统文件维护——仅编辑 plans/** 计划文档；设计整合派发开销大于收益）

### Phase 3: 审计门判定器与接线落地
- [x] S1 新增 check-plan-audit-gate.sh（lane 优先/显式档位/APPROVED 末段聚合边界止 H2 + 结论行 ERE 行首锚定/轻量 skip/L1+ 拒锁/legacy SKIP/rc 契约）——worktree 落地；VC-1 七态 rc=0+补充态全对（缺 progress=2/不可读=2/mini=0/无声明 SKIP=0）
- [x] S2 attest-plan.sh 接线 [audit-gate]（--skip-audit-check/cksum 含 skip+enforce+progress 哈希/WARN）——4 处增量；enforce 拒锁不写锁/APPROVED 写锁/warn 默认透传/逃生 WARN 全实测
- [x] S3 新增 selftest-plan-audit-gate.sh（静态+正负例+轻量 skip/L1+ skip/mini/冲突档/形态残缺/rc2/缓存隔离）——16/16 PASS exit 0（含 r5/r6/r7/legacy SKIP/中间态/fixture a b）
- [x] 三脚本 bash -n 与 selftest 自跑通过（run-selftests 聚合 `[run] selftest-plan-audit-gate (rc=0 PASS=16 FAIL=0)`）
- **V-N:** VC-1, VC-2, VC-3
- **Status:** complete
- **执行备注**：executor 派发三连败（provider rate limited）→主进程直做兜底（§十降级链+task-v171 先例），subagent-state/p3-s1s2.md 检查点；实现期自纠 2 缺陷（skip 子串误触发自指计划→行首锚定；progress 检查抢跑轻量档路径→判定序重排）
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 新增 check-plan-audit-gate.sh（lane 优先/档位判定/APPROVED 末段聚合+最小形态/轻量 skip/L1+ 拒锁/legacy SKIP/rc 0-1-2） | 继承 | `skills/task-planner/scripts/check-tier-consistency.sh:1-70`（档位解析/rc 契约/输出前缀范式）+ `plans/archive/task-planaudit-20261116/progress.md:119-208`（[plan-audit-R<N>] 留痕形态与 APPROVED 裁决；其聚合命令在中间态假阳性，加固口径见 kb §2「R6a 加固」） | 脚本 bash -n；正例 rc0/无留痕 rc1/输入缺失 rc2（显式 WARN；**progress.md 删除/不可读=rc2、存在但空=无留痕 rc1**）；lane 优先+mini×L1 冲突必审；无声明显式 SKIP legacy-no-decl；轻量 skip rc0、L1+ skip rc1；APPROVED 缺 审计体/轮次/问题清单 → rc1（**`问题清单` 容忍全角/半角括注后接冒号**——真实段形态 `- 问题清单（留档，不阻断）:` 须 rc0，字面连写冒号会误拒真实 plan-dir；判据正则见 verification.md VC-1）；**真实 R6 字节形态正向 → rc0**；**fixture a（段内裸文 APPROVED 意见文本）→ rc1、fixture b（后随 H2 块锚定 APPROVED）→ rc1**——两约束各自独立承重；**① 聚合边界**=末段 buf 止于下一个 `## `（H2）行（含修复轮 `## 2026-11-17 R<N> 修复轮`、`## 审计留痕占位` 等任何 H2），而非仅下一个 `[plan-audit-RN]` 头（**该边界仅认 `^## `，故审计段后随块必须用 H2 标题；H3/粗体标题则边界不生效、约束静默退化——checker 注释须登记该前提，R7 Q-1**）；**② 结论行锚定**=APPROVED/REJECTED 判定用 ERE 行首结构锚定（`- 轮次: R<N>` + `审计体:` + `结论: **APPROVED**` 三段，完整正则见 verification.md VC-1），禁匹配反引号内/行中元引用；**中间态假阳性负例**=fixture「REJECTED 审计段 + 后随含反引号 APPROVED 元引用的修复轮块」→ 必 rc1；[audit-gate] 前缀 | 15min | 1f/70l/15min | 无 | - | done |
| S2 | (A6) attest-plan.sh 接线 [audit-gate]（--skip-audit-check/档位/cksum 含 skip+enforce+progress 哈希/WARN） | 继承 | `skills/task-planner/scripts/attest-plan.sh:26-99`（skip 旗标/缓存键/缓存回放）+ `skills/task-planner/scripts/check-plan-audit-gate.sh`（S1 产物） | --skip-audit-check 解析；[audit-gate] 段 shell-out；_attest_cksum 含 skip_audit+AUDIT_GATE_ENFORCE+sha256(progress.md)；缓存回放 WARN；失败不写锁；rc2 fail-open | 15min | 1f/45l/15min | 无 | S1 | done |
| S3 | (A6) 新增 selftest-plan-audit-gate.sh（静态+正负例+轻量 skip/L1+ skip/mini/冲突档/形态残缺/rc2/缓存隔离） | 继承 | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh:29-174`（断言风格）+ `skills/task-planner/scripts/check-plan-audit-gate.sh`（S1 产物）+ `verification.md:23`（VC-3 判别用例全清单=权威，含 R7/R8 增补 r5/r6/r7/legacy SKIP/中间态/fixture a b） | selftest 自跑 FAIL=0；静态 token + 正例/无留痕/轻量 skip/L1+ skip/mini/mini×L1 冲突/形态残缺/rc2/缓存隔离用例；正负例独立 task_plan 内容或每例清理 `/tmp/attest-cache-*` | 15min | 1f/90l/15min | 无 | S1,S2 | done |

### Phase 4: 109.8 条款与 SKILL/registry 联动
- [x] S1 追加 critical-rules.md 109.8（109.7 原文保留）——109.8 六子项全文落刀（109.7 行原样；`^### 109 ` 计数=1 实测）
- [x] S2 SKILL.md 审计门补机器面一行 + registry 登记 selftest——机器门行落刀；registry 四列行 append（awk NF=4 全表校验过）
- [x] 一致性校验（`^### 109 ` 计数=1；109.7 逐字未变；registry 四列非空）——实测通过
- [x] 变更标注表 CA-10~CA-12 勾核——三行与落点一致
- **V-N:** VC-4（VC-6 两段式：范围断言=Phase 5 S2 merge-back 前执行并留痕 progress.md `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N`；回归/部署位 diff=终验 Goal Gate 复核）
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 追加 critical-rules.md 109.8 机器面授权范围（109.7 原样保留） | 继承 | `skills/task-planner/references/critical-rules.md:194-212`（Rule 109 现文/109.7 边界/Why 段） | 109.8 在位；109.7 原文逐字保留；`^### 109 ` 计数=1 | 10min | 1f/10l/10min | 无 | - | done |
| S2 | (A6) SKILL.md 审计门补机器面一行 + registry 登记 selftest | 继承 | `skills/task-planner/SKILL.md:68-77`（审计门区块）+ `skills/task-planner/scripts/selftest-registry.tsv:1-20`（四列表头与登记范式） | SKILL 机器面行含 --skip-audit-check/[audit-gate]；registry 行四列非空 | 10min | 2f/15l/10min | 无 | S1 | done |

### Phase 5: 全量回归、自举实测与合并部署
- [x] S1 全量 selftest --fresh 回归并采集证据（**同集零增量**：主仓 Total 100 PASS=93 FAIL=7，Failed==冻结 7 名单逐名一致；证据 evidence/VC-6.out）
- [x] 自举实测（merge-back 后，主进程执行）：主仓新 attest 对本 plan-dir 实跑 [audit-gate] rc=0 且输出含 [audit-gate]——实测 `TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce attest` rc=0+`[audit-gate] PASS: 末段审计留痕 [plan-audit-R8] APPROVED`（进度上文 VC-5 段）；D1 走既有文本审计链路（bootstrap: gate-absent，SHA d1be4e66）
- [x] S2 merge-back **前**由主进程执行 worktree 范围断言——实测 `[scope-check] 2026-11-16T23:19:08Z SCOPE-OK diff=6 untracked=0`（progress.md 末行）；smart-merge-back --deploy rc=0（merge cf697f7，部署位 IDENTICAL）；主仓复验含 VC-5 自举；worktree/分支已清理（§11.3.5）
- [x] 存量迁移说明登记：9 无声明 legacy（fail-open）+7 个 standard/L1 无留痕（未归档在途口径，含已 complete 未归档）→ 存量不重锁 + 部署首版 warn 起步建议（写入交付披露；enforce 可 `TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce` 一行开启）
- [x] 交付证据归档（verification/evidence VC-1..6.out + progress 回填完成）
- **V-N:** VC-5（VC-6 分两段：范围断言=S2 内 merge-back 前执行并留痕；部署位 diff/回归=终验 Goal Gate 复核）
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|------|------|------|
| S1 | (A6) 全量 selftest --fresh 回归并采集 Total 证据 | 继承 | `skills/task-planner/scripts/run-selftests.sh:1-60`（入口/缓存/汇总语义）+ `plans/task-auditgate-machine-20261116/verification.md`（VC-6 全量命令）+ 本文件 Phase 1「selftest 基线冻结」块（对照 7 名单） | 全量 `Total:` 行 `FAIL=7` 且 `Failed:` 行==Phase 1 冻结 7 名单（同集零增量；新 FAIL 名即失败）落 progress/evidence | 15min | 1f/10l/15min | 无 | - | pending |
| S2 | (A6) merge-back 前范围断言留痕 + smart-merge-back --deploy + push + 主仓复验（含自举实测）+ worktree 清理 | 主进程（例外理由:① git 编排+⑤ 兜底接管） | `skills/task-planner/scripts/smart-merge-back.sh:1-40`（合并/部署/清理契约）+ `plans/task-auditgate-machine-20261116/task_plan.md`（隔离决策） | merge-back **前** progress.md 含 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 行（内嵌命令**文件末尾追加**，留痕归属 Phase 5 段；VC-6 以全文件严格 token 正则匹配，位置不敏感；白名单集合执行时与 `scope_files` 逐项核对一致；worktree 缺失/git 失败/grep rc≥2/越界即停，不写 PASS 行）；部署位 diff=0；master 合并提交；**merge-back 后主仓新 attest 对本 plan-dir rc=0 且输出含 `[audit-gate]`**；worktree/分支清理；交付披露含存量迁移说明（9 无声明+7 个 standard/L1 无留痕（未归档在途口径，含已 complete 未归档）；存量不重锁+首版 warn 起步建议） | 10min | 1f/6l/10min | 无 | S1 | pending |

#### S2 内嵌命令：worktree 范围断言（Phase 5，merge-back **前**由主进程执行）

> 判据要点：① 白名单**文件级分支尾锚 `$`**（防 `SKILL.md.bak`/`attest-plan.sh.bak` 类副产物静默越界放行），目录分支 `plans/task-auditgate-machine-20261116/` 保持尾 `/`；② `grep` rc **显式捕获**——仅 rc=0（全命中）与 rc=1（全未命中）合法续行，rc≥2（模式/读错误）必须 exit 1，禁用 `|| true` 掩蔽；③ 白名单集合须与上方 Code Review 配置表 `scope_files` 逐项一致（执行时核对，不一致即停）；④ 通过后**立即**追加 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 入 progress.md（**文件末尾追加**；VC-6 以全文件严格 token 正则匹配，故位置不敏感——「留痕归属 Phase 5 段」仅为语义归属，非定位要求；VC-6 唯一权威证据）；失败即停，不写 PASS 行、不进入 merge-back。

```bash
set -u
WT=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-auditgate-machine-20261116
PROG=/mnt/data/dev/task-planner-skill/plans/task-auditgate-machine-20261116/progress.md
test -d "$WT" || { echo "[audit-gate] FAIL: worktree 缺失"; exit 1; }
D=$(mktemp); U=$(mktemp)
git -C "$WT" diff --name-only master >"$D" || { echo "[audit-gate] FAIL: git diff 失败"; rm -f "$D" "$U"; exit 1; }
git -C "$WT" ls-files --others --exclude-standard >"$U" || { echo "[audit-gate] FAIL: git ls-files 失败"; rm -f "$D" "$U"; exit 1; }
rc=0; out=$(cat "$D" "$U" | grep -vE "^(skills/task-planner/scripts/(attest-plan\.sh|check-plan-audit-gate\.sh|selftest-plan-audit-gate\.sh|selftest-registry\.tsv)$|skills/task-planner/SKILL\.md$|skills/task-planner/references/critical-rules\.md$|plans/task-auditgate-machine-20261116/)") || rc=$?
test "$rc" -eq 0 -o "$rc" -eq 1 || { echo "[audit-gate] FAIL: grep 异常 rc=$rc"; rm -f "$D" "$U"; exit 1; }
test -z "$out" || { echo "[audit-gate] FAIL: 越界文件: $out"; rm -f "$D" "$U"; exit 1; }
diffn=$(wc -l < "$D"); untn=$(wc -l < "$U"); rm -f "$D" "$U"
echo "[scope-check] $(date -u +%Y-%m-%dT%H:%M:%SZ) SCOPE-OK diff=$diffn untracked=$untn" >> "$PROG"
echo "[scope-check] 已留痕 progress.md: diff=$diffn untracked=$untn"
```

## 🔁 收尾回读梳理记录（Rule 84.14 — 迭代环留痕，交付前必填）

| 轮次 | 发现（偏移/遗漏/未利用知识） | 处置（修复动作+证据） |
|------|------------------------------|----------------------|
| 1    | 待执行期填写（需求↔目标↔执行↔验证↔知识五维互洽检查） | 待执行期填写 |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（attest-plan.sh/SKILL.md/critical-rules.md 均为运行中基础设施，属实现类变更；执行前复跑 check-conflicts.sh 确认） |
| `isolation` | `worktree`（实现类默认首选，§十一） |
| `worktree_path` | `tmp/worktrees/task-auditgate-machine-20261116` |
| `branch` | `wt/task-auditgate-machine-20261116` |
| `merge_back` | `merged(cf697f7)`（--deploy 部署位 IDENTICAL；worktree/分支已清理） |

> 契约详见 `skills/task-planner/references/worktree-isolation.md`（决策矩阵/生命周期/合并回合约/反模式）。

## 📊 FMEA 预演（规划期 — methodology.md §R2）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| Phase 1 | 基线误判（把无声明 legacy 计划当 L1+ 拒锁） | 7 | 4 | 5 | 140 | ② 拆细取证：显式 standard/L1/L2 才检查；无声明 fail-open；fixture 覆盖 legacy |
| Phase 2 | 设计遗漏（缓存键未纳入 skip 旗标/enforce 档/progress 哈希→陈旧 PASS） | 8 | 4 | 5 | 160 | ③ 降档重审+主进程复核：把 skip_audit+AUDIT_GATE_ENFORCE+sha256(progress.md) 纳入 cksum 列为验收项 |
| Phase 3 | checker 误报/漏报（APPROVED 末段聚合错误） | 9 | 3 | 5 | 135 | ① 改派+② 拆细：正负例三态实测；awk 只认 `R<N>] ` 段排除 revision |
| Phase 4 | 109.8 与 109.7 语义冲突/计数漂移 | 8 | 3 | 6 | 144 | ② 拆细+⑤ AskUser：109.7 原样保留；`^### 109 ` 计数=1 复核 |
| Phase 5 | 回归 FAIL 或部署位不一致 | 8 | 4 | 6 | 192 | ④ 主进程接管复核：全量 Total 行求和；部署位 diff；worktree 清理 |
| Phase 5 | 自举实测口径错配（声称 D1 走机器门/门不存在被当通过） | 9 | 3 | 4 | 108 | ② 拆细+④ 主进程复核：D1 走既有文本审计链路并登记 bootstrap: gate-absent；机器门证据=Phase 5 merge-back 后主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]` |

**填写规则**：RPN>100 项已登记兜底；执行期实际失败仍走 Rule 22.3 完整链路。

## 🔁 原生 Todo 同步（S1–S5 强制）

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | D1 批准后建映射 |
| Phase 2 | ☐ |  |  |
| Phase 3 | ☐ |  |  |
| Phase 4 | ☐ |  |  |
| Phase 5 | ☐ |  |  |

> 契约详见 `skills/task-planner/references/todo-sync.md`（映射规则/工具选择/hook 响应协议/反模式）。

## Key Questions

1. **L1+ 判定口径**：lane 优先——`execution_lane: L1|L2` 必审；`plan_tier: mini` 与 L1 并存按最严=必审；显式 `plan_tier: standard|full` 必审；`plan_tier: mini` 或 lane 为 L0/L0-T/L0-E 跳过；无声明=跳过但输出显式 `[audit-gate] SKIP legacy-no-decl`（禁静默）。答：采用 lane 优先+显式声明口径，避免阻断存量计划。
2. **`[plan-audit-skip]` 是否允许 L1+ 使用？** 答：否。skip 仅轻量档（mini/L0/L0-T/L0-E）生效；L1+ 写 skip 仍拒锁，唯一逃生=`--skip-audit-check` 参数+WARN+交付披露（与 109.3 轻量档限定对齐，不扩授权）；本计划不使用 skip。
3. **独立 checker 还是内联 attest？** 答：独立 `check-plan-audit-gate.sh` + attest shell-out，便于 fixture 测试并与既有 check-tier-consistency 同构。
4. **是否新增 config 键？** 答：否。用 env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE`（enforce/warn/off，默认 enforce），避免 properties 键数级联断言。
5. **109.7 改写还是追加 109.8？** 答：追加 109.8，109.7 原文逐字保留（Rule 74 增量默认）。

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 采用 `template_type: rule-enhancement` | 任务核心是 Rule 109 机器面增强+脚本+selftest，契合规则增强画像；复用既有变体 |
| 独立 checker + attest shell-out（非内联） | 可独立 fixture 测试、与 check-tier-consistency 同构、降低门链漂移面 |
| 零新 config 键，env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE` | 避免 properties 键数 53 的级联断言；对齐 Rule 84.6 env-only 先例 |
| L1+ 仅显式声明才检查，无声明=legacy fail-open | 不阻断存量计划；新计划由 init 写入 standard/L1 天然进入检查面 |
| 自举条款=bootstrap: gate-absent（方案 a） | D1 时新门尚不存在；D1 走既有文本审计链路（critic APPROVED 已是前置），机器门证据改由 Phase 5 merge-back 后主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]` 提供；避免「门不存在=默认通过」冒充走门实证 |
| `[plan-audit-skip]` 仅轻量档生效；L1+ 写 skip 仍拒锁 | 对齐 109.3 轻量档限定与用户授权范围；L1+ 唯一逃生=`--skip-audit-check` 参数+WARN+交付披露，防自声明旁路 |
| lane 优先：`execution_lane: L1/L2` 必审，mini×L1 按最严 | 避免冲突声明（mini+L1）被 mini 分支跳过；存量真实冲突计划按最严审 |
| 缓存键纳入 skip_audit + TASK_PLANNER_AUDIT_GATE_ENFORCE + sha256(progress.md) | 防止 skip/档位翻转/progress 审计留痕变更时回放陈旧 PASS；selftest 增缓存隔离用例 |
| 正确性优先：progress.md 进 cksum 使缓存命中率归零 | 有意取舍：APPROVED/进度变更即失效缓存，优先防误判回归；selftest 缓存隔离用例验证 enforce→off→enforce 不复用 |
| 109.7 原文保留，追加 109.8 | Rule 74 增量默认；避免改写既有条款语义 |
| checker 插入 attest 门链 window-lint 后、hash 前 | 门失败不写 .plan-attestation；与「先哈希后写」纪律一致 |
| Phase 2 主进程直做（25.3②） | 设计冻结与变更表维护均为 plans/** 计划文档；派发开销大于收益 |
| Phase 5 S2 主进程兜底 git 编排 | merge/deploy/push 属白名单①；Phase 5 仍由 code-runner-agent 承载回归（委派率 4/5=0.800） |

## Errors Encountered

| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
<!-- 执行期按 Rule 31 及时登记；当前无错误记录。 -->

## Notes

- **自举条款（bootstrap: gate-absent，2026-11-17 审计 F8 冻结方案 a）**：D1 走既有文本审计链路（critic APPROVED 已是 D1 前置，本计划已实证）；新 `[audit-gate]` Phase 3 才创建，故本计划 D1 时点不存在机器门，attest 仍由既有门链锁定。机器门证据=Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]`；机器门对未来计划生效。
- **本计划自身即自举实测首例（Phase 5，不是 D1 时点）**：Phase 5 merge-back 后主进程用主仓新 attest 读取本计划 progress.md 的 APPROVED 留痕并 rc=0，且断言输出含 `[audit-gate]`；该留痕由主进程在 critic 文本审计后写入，计划期不预写。
- **VC-6 两段式时点与证据（R4 I-1）**：范围断言在 merge-back 前于 worktree 执行（命令=Phase 5「S2 内嵌命令」；`git -C tmp/worktrees/task-auditgate-machine-20261116 diff --name-only master` + `ls-files --others --exclude-standard` 纳入 untracked，等效 `git add -N`）；**唯一权威证据=Phase 5 S2 merge-back 前主进程执行后追加的 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N` 行**。**VC-6 Verify command 只复核该留痕（全文件严格 token 正则 `^\[scope-check\] <ISO8601> SCOPE-OK diff=N untracked=N$`——R5 I-1：S2 产出形态是 progress.md 文件末尾追加，旧段锚 awk 只读 `### Phase 5:` 段会让留痕恒落段外致终验必 FAIL，故断言面改全文件 token 匹配，产出位置与消费断言的定位方式互洽），不 live 依赖 worktree**——S2 强制清理后 worktree 已删，live `test -d "$WT"` 断言与清理互斥会导致终验必败（R4 I-1 根因）。fail-closed 语义由 S2 内嵌命令承载（worktree 缺失/git 失败/grep rc≥2/越界均 exit 1 且不写 PASS 行）。部署位 diff 在 merge-back 后由 V-5.2 验证（终验 Goal Gate 复核）。
- **VC-6 同集零增量判据（微修轮 4b，2026-11-17）**：`run-selftests.sh --fresh` 存量基线=`Total: 99 PASS=92 FAIL=7`，7 名单全部为**他任务在途遗留**（见 Phase 1「selftest 基线冻结」块）。绝对 `FAIL=0` 判据会被他任务债在 Phase 5 确定性击穿，故 VC-6 改判「`Failed:` 集合==冻结基线集合且 `FAIL=7`」——断言面仍是全量回归，只冻结已知失败集合，不是降低强度。**基线漂移**：若他任务收口导致集合变化，须由主进程重跑冻结新基线 + `progress.md` 留 `[baseline-shift] <ISO8601> <新 Total> | <新 Failed> | <逐名归因> | <重跑冻结依据> | <critic 简版复审结论>` + 同步更新冻结块与 VC-6 Verify command 字面量，按新基线判零增量；**防滥用双闸（R5 W-1）**：① 逐名归因（每个新增/消失条目须指认他任务/提交锚，无法指认的新增 FAIL 不得吸收）② 漂移后重走 critic 文本审计（判据字面量变更经简版复审并留痕，禁主进程自裁）；**禁静默放宽**。
- **checker 末段聚合加固（R6a，2026-11-17 主进程 /tmp 一手实测）**：先例聚合命令（末段 buf 延伸到 EOF + 未锚定 grep）在**中间态**假阳性——审计段后跟修复轮块时，buf 吞进后随块反引号内的元引用 → 未审也放行（实测 `head -304` 截断态与「REJECTED 段+元引用修复轮块」fixture 旧形态 rc=0）。实现必须：① 聚合边界止于下一个 H2 `## ` 行（任何 H2，含修复轮/留痕占位块）；② 结论判定用 ERE 行首结构锚定（完整正则见 verification.md VC-1），禁匹配反引号内/行中元引用；③ selftest 与 VC-1 均含中间态假阳性负例（必 rc1）。
- **缓存键提醒**：Phase 3 S2 必须把 `skip_audit`、`TASK_PLANNER_AUDIT_GATE_ENFORCE` 与 `sha256sum progress.md` 同时纳入 `_attest_cksum`，否则 `--skip-audit-check`/档位翻转/APPROVED 追加都可能回放陈旧 PASS。
- **零新 config 键**：不修改 config.json；不要新增 properties 键，否则触发 selftest-session-log SL-09 等键数断言。
- **Verify command 纪律**：verification.md 命令禁反引号包裹（run-verification 以 bash -c 整行执行）。

## 🚨 Drift Log（漂移检测记录）

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| — | 待执行期 drift-checker | — | — |

## 📦 Batch Report（批量处理质量门控 — Rule 18.6）

| 字段 | 值 |
|------|-----|
| `total` | n/a（非批量任务：9 个离散异质 S-unit，非同类 fan-out） |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a（非批量任务；Q1:否/Q2:有客观 VC/Q3:git+worktree 可回滚） |
| `rollback_point` | n/a（worktree 分支 wt/task-auditgate-machine-20261116 合并前可弃） |

## 📊 委派统计（Rule 25.4 — 终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5（计划期预估：P1 explore / P3 executor / P4 executor / P5 code-runner-agent；P2 主进程 25.3②） |
| 主进程直做 Phase 清单 | Phase 2（例外理由:25.3② 计划系统文件维护——仅编辑 plans/** 计划文档；设计整合派发开销大于收益） |
| 委派率 | 0.800（计划期预估；执行期以 check-delegation stats 实测为准） |
| 激活子代理数（Rule 96.5） | 计划面预估 6（critic×1 + explore×1 + executor×2 + code-runner-agent×1 + plan-writer×1）；实际已派发 14 次（critic×7 + plan-writer×7，修复轮 1-2 合并 1 行登记）+ 4 项执行体排队待派（合计 18；见 Handoff 登记表——审计迭代轮次超预估属审计门设计行为，修复轮 7 末复跑 tier-consistency 见 progress 段） |
| 最大并行宽度（Rule 96.5） | 1 组 / 最宽 2（Phase 1 p1-baseline） |
| 串行化例外理由（Rule 96.4） | none（跨 Phase 串行属天然依赖；Phase 1 组内并行已声明） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | 备注(rescue/retry/verify_done) |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|
| 1 | 2026-11-17 | critic | 计划独立审计 R1（D1 前，既有文本审计链路；机器门尚未创建）：按 Rule 109 六维审计本计划 | done | **REJECTED**：14 发现（C1/I5/W6/N2）全录 progress.md [plan-audit-R1]；核心=自举时序矛盾(C)+缓存绕过硬门(I×2)+L1+ 豁免旁路(I)+VC 不执行被验证物(I)；已打回修复轮 | plans/task-auditgate-machine-20261116/progress.md | progress.md [plan-audit-R1] | subagent-state/ | - / 1 / ☑ |
| 2 | 2026-11-17 | explore→主进程直做 | Phase 1 S1/S2 基线与 selftest 范式核实 | done | 双 explore agent 被 provider 限流（failed: rate limited，证据=会话通知）→按 §十降级链主进程直做有界核实；findings S1/S2 段全记录 | findings.md Research Findings Phase 1 段 | findings.md Research Findings | subagent-state/p1-s1.md（未建，直做留痕在 findings/progress） | 降级 / 1 / ☑ |
| 3 | 2026-11-17 | executor→主进程兜底 | Phase 3 S1-S3 checker/attest 接线/selftest | done | executor 三连败 provider rate limited→主进程直做（§十降级链+task-v171 先例）；VC-1 七态 rc=0+selftest 16/16 | worktree b0e7caf 6 文件+subagent-state/p3-s1s2.md | findings.md Technical Decisions | subagent-state/p3-s1s2.md | 降级 / 1 / ☑ |
| 4 | 2026-11-17 | executor→主进程兜底 | Phase 4 109.8 条款 + SKILL/registry 联动 | done | 同上兜底；109.8 落刀（109 计数=1）+SKILL 机器门行+registry 行 NF=4 | worktree b0e7caf | findings.md Design Decisions D4/D5 | subagent-state/p3-s1s2.md | 降级 / 1 / ☑ |
| 5 | 2026-11-17 | code-runner-agent→主进程兜底 | Phase 5 S1 全量回归与证据采集 | done | 同上兜底；全量 Total 100 PASS=93 FAIL=7=冻结基线同集零增量+VC-5/VC-6 实测 | evidence/VC-5.out VC-6.out | progress.md Phase 5 | subagent-state/p3-s1s2.md | 降级 / 1 / ☑ |
| 6 | 2026-11-17 | critic | 计划独立审计 R2 | done | **REJECTED**：6 发现（N1-N6）全录 [plan-audit-R2]；核心=git 断言主仓必败+自举路径反向；已打回修复轮 2 | progress.md [plan-audit-R2] | progress.md [plan-audit-R2] | subagent-state/（R1-R3 轮无独立 checkpoint，证据=progress 段） | - / 1 / ☑ |
| 7 | 2026-11-17 | Plan Writer | 修复轮 1-2（F1-F14/N1-N6 增量修订） | done | 两轮全落盘+机械门 rc=0；R2/R3 复审输入就绪 | progress.md 修复轮段 | findings.md | subagent-state/（同上） | - / 2 / ☑ |
| 8 | 2026-11-17 | critic | 计划独立审计 R3 | done | **REJECTED**：I1 fail-open+W1/N7/N8 全录 [plan-audit-R3]；已打回修复轮 3 | progress.md [plan-audit-R3] | progress.md [plan-audit-R3] | subagent-state/（同上） | - / 1 / ☑ |
| 9 | 2026-11-17 | Plan Writer | 修复轮 3（I1 fail-closed+W1/N7/N8） | done | 四项落盘盘上复核；引入 C-1/I-1 回归由 R4 抓出 | progress.md R3 修复轮段 | findings.md | subagent-state/（同上） | - / 1 / ☑ |
| 10 | 2026-11-17 | critic | 计划独立审计 R4 | done | **REJECTED**：C-1 grep-c 双零恒败+I-1 时点互斥+2W+2N 全录 [plan-audit-R4]；已打回修复轮 4 | progress.md [plan-audit-R4] | progress.md [plan-audit-R4] | subagent-state/audit-R4.md | - / 1 / ☑ |
| 11 | 2026-11-17 | Plan Writer | 修复轮 4（C-1/I-1/W-1/W-2/N-1/N-2） | done | 六项落盘盘上复核；披露存量基线 7 FAIL 冲突 | progress.md R4 修复轮段 | findings.md | subagent-state/fix-R4.md | - / 1 / ☑ |
| 12 | 2026-11-17 | Plan Writer | 微修轮 4b（VC-6 同集零增量+基线冻结） | done | 判据对齐存量基线；端到端七态实测 | progress.md R4b 段 | findings.md | subagent-state/fix-R4b.md | - / 1 / ☑ |
| 13 | 2026-11-17 | critic | 计划独立审计 R5 | done | **REJECTED**：C-1 VC-2 顺序污染+I-1 段锚不兼容+2W+1Q+3N 全录 [plan-audit-R5]；已打回修复轮 5 | progress.md [plan-audit-R5] | progress.md [plan-audit-R5] | subagent-state/audit-R5.md | - / 1 / ☑ |
| 14 | 2026-11-17 | Plan Writer | 修复轮 5（C-1 时序重排+I-1 全文件 token+5 项簿记） | done | 八项落盘盘上复核；mock 六态实测 | progress.md R5 修复轮段 | findings.md | subagent-state/fix-R5.md | - / 1 / ☑ |
| 15 | 2026-11-17 | critic | 计划独立审计 R6（收敛轮） | done | **APPROVED**（0C/0I；1W+3N 留档）全录 [plan-audit-R6]；迭代收敛达成 | progress.md [plan-audit-R6] | progress.md [plan-audit-R6] | subagent-state/audit-R6.md | - / 1 / ☑ |
| 16 | 2026-11-17 | Plan Writer | 修订轮 R6a（checker 聚合中间态假阳性加固） | done | 两约束三落点+判别性六态实测；待 R7 复审登记 | progress.md R6a 段 | findings.md | subagent-state/fix-R6a.md | - / 1 / ☑ |
| 17 | 2026-11-17 | critic | 计划独立审计 R7（R6a 修订范围化复审） | done | **REJECTED**（0C/2I/2W/2Q/2N：I-1 token 形态与真实 APPROVED 段脱钩+I-2 半加固不可判别）全录 [plan-audit-R7]；已打回修复轮 7 | progress.md [plan-audit-R7] | progress.md [plan-audit-R7] | subagent-state/audit-R7.md | - / 1 / ☑ |
| 18 | 2026-11-17 | Plan Writer | 修复轮 7（I-1/I-2/W-2/Q-1/Q-2 增量修订） | done | 五项落盘盘上复核；容忍 token+真实形态正例 r7；r5/r6 两独立负例（半加固被抓）；八机械门 rc=0 | progress.md R7 修复轮段 | findings.md | subagent-state/fix-R7.md | - / 1 / ☑ |

> 派发 prompt 八字段模板：`skills/task-planner/templates/subagent_dispatch.md`；每次返回 30s 内 Read 产出 + 回填 findings 后勾 verify_done。

## 🔗 Chain 区块交接配置（可选）

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single` |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 审计门机器面（当前块）

| 字段 | 值 |
|------|-----|
| **goal** | CA-6 机器面授权实施与审计门测试 |
| **depends_on** | none |
| **passes_to** | — |
| **status** | in_progress |

## 🔁 模板感知

<!-- template_type: rule-enhancement（显式选择，非 general 兜底） -->
- 触发信号：任务为 task-planner 技能规则/流程增强（Rule 109 机器面+测试），复用既有 rule-enhancement 变体
- 不沉淀理由：复用既有 rule-enhancement 变体，无新增泛化缺口
- 终验必查：模板感知区块已登记不沉淀理由，check-complete [template-sense] 不告警
