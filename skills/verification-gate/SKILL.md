---
name: verification-gate
description: 任务验证全链路唯一权威域——创建任务时把 VC（Verification Contract）设计成可执行验证命令、执行期 V-N 逐项校验、终验 VC 逐条复验、交叉验证识别执行错误与虚构（Rule 108）。当创建/更新 task_plan.md 的 VC 表、Phase 标记 complete 前校验 V-N、执行终验交付复验、子代理返回 done 需 Read 复核时触发。也适用于：用户要求"验证规则/验证脚本/可验证性/所有产出都要验证"、VC 条目缺可执行命令需回炉、需要机器强制验证覆盖的场景。task-planner 第 12 卫星（Rule 82 分层；子代理返回内容复核归本技能，返回格式/段结构校验归 task-dispatch）。
model: haiku
allowed-tools: "Read, Bash, Grep, Glob"
---

# Verification Gate — 任务验证全链路卫星

任务验证域独立技能（task-planner 第 12 卫星，Rule 84 建制）。把「验证」从主技能罗盘管理中解耦为独立域：**规则/模板/SOP 在本卫星**，主技能各执行步骤显式引用本卫星。

## 定位：验证全链路唯一权威

本卫星管任务验证的**三个阶段**，覆盖「所有产出以及执行都有验证」的闭环：

| 阶段 | 时点 | 职责 |
|------|------|------|
| ① 计划期 VC 设计 | 创建/更新 task_plan.md 的 VC 表时 | VC 可执行化——每条 VC 必须带可运行验证命令（Rule 84.1） |
| ② 执行期 V-N 校验 | Phase 标记 complete 前 | Phase Gates 的 V-N 逐项校验 + 子代理产出 Read 复核（Rule 84.4） |
| ③ 终验 VC 复验 | 全 Phase complete 后交付前 | 逐条跑 VC 命令/查证据，出 COMPLETE/PARTIAL/BLOCKED（Rule 84.5） |

**与主技能边界**（Rule 82 禁镜像）：主技能 task-planner 只管四文件罗盘（计划制作+记录文档管理）；verification.md 契约的**设计规则与终验 SOP 全文在本卫星**，主技能 SKILL.md 只留指针。

## 调用时机（命中任一即调用）

1. 创建/更新 task_plan.md 的 Verification Contract（VC 表）时——plan 制作循环步骤
2. Phase 标记 complete 前校验 V-N（Phase Gates）时
3. 终验交付阶段复验 VC 时（主技能「终验交付」步骤入口）
4. 子代理返回 "done" 需 Read 实际产出复核时（Rule 84.4）
5. 用户要求"验证规则/验证脚本/可验证性/所有产出都要验证"时
6. attest-plan.sh 校验 VC 可执行性门失败回炉时
7. 终验/子代理产出采信前需隔离双视角交叉验证或识别伪造信号时（Rule 108）

## 执行步骤

### Step 1: VC 设计（计划期） [A]

1. 打开/编辑 `templates/verification.md`（本卫星模板），填写 VC 表
2. **每条 VC 必填三要素**（Rule 84.1 可执行性纪律）：
   - 验证命令：可运行的 bash 命令（如 `bash scripts/check-x.sh <plan>`）或路径+关键行（如 `grep -c 'Rule 84' file.md`）<!-- 示例占位 -->
   - 判据：命令输出的 PASS/FAIL 判定标准
   - 证据落点：verification.md 对应 VC 的 Evidence 字段
3. VC 条数：standard ≥5 / mini ≥2 / L0 ≥1（沿用 goal-gate 规则）
4. VC 设计完成 → attest-plan.sh 的 VC 可执行性门自动校验（缺命令=拒锁回炉）

**可选思路**：
1. 思路 A：逐条产出反推——从交付物/Phase 产出逐项反推「应验证什么」，再落成命令（适用场景：产出明确、需保证覆盖无遗漏时）
2. 思路 B：按验收维度分类设计——按功能/边界/回归/安全等维度分组各出 VC，再合并去重（适用场景：交付面广、需系统性覆盖多维度时）

### Step 2: V-N 校验（执行期，Phase complete 前） [M]

1. Read verification.md 当前 Phase 段的 V-N 项
2. 逐项执行验证命令，确认 PASS
3. V-N 未全 PASS → 禁止 Phase 翻 complete（goal-gate 规则 3）
4. 子代理产出：Read 实际文件复核（不信任 "done" 自报）后才勾 Handoff verify_done
5. 回填门控：`bash ../task-planner/scripts/check-3file-gate.sh <plan-dir>` exit 0 才可翻转

### Step 3a: VC 复验（终验期，交付前）— 机械子动作 [M]

1. Read verification.md 的 Goal Gate 段
2. 逐条 VC 执行验证命令（可用统一入口：`bash <skill>/scripts/run-verification.sh <plan-dir>`，解析 VC 命令自动执行汇总）
3. 终验前跑 `bash ../task-planner/scripts/check-complete.sh`（21 门总门，exit 0 才可交付）

### Step 3b: VC 复验（终验期，交付前）— 智能子动作 [A]

1. 逐条 VC 对照判据出 PASS/FAIL
2. 质量门控统计（Rule 26 面）+ 委派统计（Rule 25.4 面）按模板段核查
3. 出 outcome：全 VC PASS → COMPLETE；有已知遗留 → PARTIAL；≥1 VC 失败且 3 次重试无效 → BLOCKED 升级用户（goal 语境按 task-discipline Rule 28.9②④⑤ 消费，不升级提问）；语义保证型判据（确保/保证/根治/不再/杜绝/所有）计划期拆为机器可验拆分项+残余风险清单，执行期不新增判据行：拆分项全 PASS 且残余风险清单已登记 ⇒ PARTIAL，未全 PASS 或未拆分 ⇒ BLOCKED
4. 内容型交付（VC 证据/交付物含非脚本产出）翻 COMPLETE 前必须走 84.7 内容审查门（独立子代理 + 结论落 findings.md，见 `references/critical-rules-verification.md` Rule 84.7）
4b. 存在 Spec-Baseline 的任务（task_plan「🔒 规范基线」区块非空），翻 COMPLETE 前必须先过 84.15 规范基线终验门——对交付物本体逐条执行双向判定式并产出核验表落 verification.md；任一基线 FAIL/软豁免/核验表缺失 → 禁 COMPLETE（见 `references/critical-rules-verification.md` Rule 84.15）。
4c. 终验前运行 `bash <skill>/scripts/check-spec-baseline.sh <plan-dir> --final`（fail-closed，无 warn 档；l0-lite 豁免）；核验表观测/证据锚/结论列由终验执行者经 `planctl set` 写入后 `planctl render` 刷新。

**可选思路**：
1. 思路 A：逐条对照判据机械判定 PASS/FAIL，失败项按 3 次重试后升级 BLOCKED（适用场景：VC 判据客观、命令输出可直接比对时）
2. 思路 B：先归因再定态——对失败 VC 先定位是产出缺陷还是 VC 设计缺陷，再决定 PARTIAL/BLOCKED（适用场景：失败原因不明、可能为 VC 本身不可执行时）

## 验证反作弊规约（VC 编写严禁清单 — 2026-11-16 用户 /goal 增补：压制作弊行为）
> **定位**：验证判据的价值=能抓住作弊与错误。本段约束 VC/Verify command/验收判据的**编写与评审**，与机械层 `check-vc-nonvacuous.sh`（拦空洞命令）互补；评审动作在 Step 3b 逐条对照本段。
> **判据分型**：①结构型（grep 文本在位）仅限「产物即文本」的条款/文档类任务；②行为型（真实执行输入→输出）为代码/脚本/配置生效类任务的默认判据型。

**正向要求**：
- 行为型 VC：≥2 组未公开输入断言输入→输出，或关系判据（扰动输入→输出须按规律变化）；禁常量断言唯一判据。
- 负控制：每条行为型 VC 须配一条「人为破坏产物一处→判定必须翻 FAIL」的敏感性检验；判定不翻=验证器无效，VC 回炉重写。
- 盲探针：验收输入/期望值由独立复检体（Rule 33.3）验证期现生成，实现者事前不可见。
- 证据链：判定必须附命令输出原文（Rule 71 无源不写），禁口供式汇总。

**严禁清单（❌ 任一命中=该 VC 一票 FAIL，验证回炉）**：
1. ❌ 严禁写死期望值穿判据——期望常数以字面量现身实现 diff 新增行（提前 return 常量/硬编码分支/`if input==X then return expected`）=作弊实锤；
2. ❌ 严禁空洞/自证验证命令（`true`、`echo ok`、不消费产出物的命令）；
3. ❌ 严禁验证器未经负控制检验即声称有效（没抓过作弊的验证器默认无效）；
4. ❌ 严禁向执行体泄露盲探针的输入/期望（泄题=验证作废，须重生成探针）；
5. ❌ 严禁吞判据凑通过——验证失败时改判据/删判据/降阈值/放宽正则；判据变更必须走 attest 重锁+Decisions Made 登记；
6. ❌ 严禁选择性执行——只跑预期能过的子集、跳过失败项；全量验证命令必须完整执行并全量留痕；
7. ❌ 严禁旧证据冒充——复用上次/他任务的输出或缓存，时间戳/内容哈希与当前产物对不上；
8. ❌ 严禁以实现者自测替代独立验收（Rule 33.3：主进程/实现者既有上下文自测不作数）。
9. ❌ 严禁中途修改验证载体判据——task_plan.md 的 VC 表与 verification.md 的 Verify command/判据标准行自 attest 锁定即冻结；发现「判据达不成/任务解决不了」而修改判据=PLAN TAMPERED 级事件，唯一合法路径=STOP→用户显式授权→Decisions Made 登记理由→attest 重锁更新 SHA（私自改判据推进=交付作废）；例外（不属中途改判据）：计划期（attest 锁定前）的判据可达性拆分——语义保证型判据拆为机器可验拆分项+残余风险清单（Rule 84.5 判据拆分条款）；执行期不新增判据行；goal 语境下执行期才发现判据不可达 = 按 task-discipline Rule 28.9④ 类 C 定态并固定点应答，不提问。
10. ❌ 严禁修改验证机械层来让判据通过——改 selftest/attest/check 等守卫脚本、绕过 hook、降级 enforce 开关与篡改判据同罪；守卫本身有缺陷须另立任务修复并向用户披露，禁顺手改。

**判据冻结协议（执行期篡改防线，2026-11-16 用户 /goal 增补）**：verification.md 的行分两类——①状态行（checkbox 勾选/Evidence/交叉验证记录回填）=合法回填，随执行推进；②判据行（Verify command/判定标准/期望值）=自 attest 锁定起冻结，执行期禁改。两类不得混写：判据行若在执行期被修改而未走「STOP→用户授权→Decisions 登记→attest 重锁」四步，视为对已批准契约的篡改，[PLAN TAMPERED] 机制拦截+交付作废；「这个判据达不成了」的正确动作是 BLOCKED 升级用户，而不是改判据。

**评审动作（Step 3b 消费）**：逐条对照本段出判定；命中第 1/4/5/7 条作弊信号→升级 decision-arbiter 裁决并登记 Drift Log。

## 脚本引用索引（机械层留守主技能 scripts/）

按 Rule 82「机械层留守」先例，验证相关机械脚本在主技能 `task-planner/scripts/`（hook/init/selftest 深度集成，禁迁移防断链）。本卫星按其 SOP 调用：

| 脚本 | 功能 | 调用阶段 | 路径 |
|------|------|---------|------|
| `check-3file-gate.sh` | 执行中回填门（Phase 翻 complete 前） | 执行期 | `../task-planner/scripts/` |
| `attest-plan.sh` | 计划锁定聚合门（含 VC 可执行性门） | 计划期 | `../task-planner/scripts/` |
| `check-complete.sh` | 终验总门（21 门：VC-GATE/R-COVERAGE/goal-gate 等） | 终验期 | `../task-planner/scripts/` |
| `check-plan-dispatch.sh` | 计划期派发型 Phase S-unit 校验 | 计划期 | `../task-planner/scripts/` |
| `run-verification.sh` | **本卫星**统一验证执行入口（逐条跑 VC 命令） | 终验期 | `./scripts/`（本卫星） |
| `selftest-verification-gate.sh` | 静态守护（Rule 84 锚，机械层留守主技能） | 回归 | `../task-planner/scripts/` |

## References

| 文档 | 用途 |
|------|------|
| `references/critical-rules-verification.md` | 验证域规则全文（Rule 84.1-84.14, Rule 108 + 迁移的 VC 规则/子代理验证协议） |
| `templates/verification.md` | Verification Contract 模板（VC 可执行化 + Goal Gate + Phase Gates + 质量门控统计） |
| `scripts/run-verification.sh` | 统一验证执行入口（解析 verification.md VC 命令→逐条执行→PASS/FAIL 汇总） |
| 主技能引用面 | `task-planner/SKILL.md` 卫星路由表 + 计划期/执行期/终验三处步骤指针 |
