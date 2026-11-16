# Findings & Decisions
<!-- 渲染契约(task-tplrender-20261024)：{{VAR}} 由 init-session.sh render_template() 渲染；[Title]/<待沉淀> 等语义占位=模型填写面 -->
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1[目标]：授权——CA-6 机器面从「待授权候选」转显式授权实施；为已落地的计划审计门（SKILL.md:68-77 + Rule 109 critical-rules.md:194-212）加机器强门（selftest/attest 接线）。逐字锚=user-session-log.md #1「1 授权」。
- R2[目标]：测试——审计门测试：机器面正负例 + selftest 全绿 + 行为面实证（D1 走既有文本审计链路；本计划 Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]`=自举实测）。逐字锚=user-session-log.md #1「2 测试」。
- R3[手段]：范围边界——仅「三、未完成项与风险」中的这两项，不扩其他机器面。逐字锚=user-session-log.md #1「三、未完成项与风险」。

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| attest 门链与 skip/缓存契约 | `skills/task-planner/scripts/attest-plan.sh:26-99,106-198,540-562` | ☑ 计划期 | Research Findings / Technical Decisions |
| 档位解析与 rc 契约 | `skills/task-planner/scripts/check-tier-consistency.sh:1-70` | ☑ 计划期 | Research Findings |
| selftest 范式与 registry | `skills/task-planner/scripts/selftest-vc-nonvacuous.sh:29-174`、`selftest-plan-dispatch.sh:12-30`、`selftest-registry.tsv:1` | ☑ 计划期 | Research Findings |
| Rule 109 与 SKILL 审计门 | `skills/task-planner/references/critical-rules.md:194-212`、`skills/task-planner/SKILL.md:68-77` | ☑ 计划期 | Research Findings / Resources |
| 先例审计留痕与三教训 | `plans/archive/task-planaudit-20261116/progress.md:119-208`、`verification.md:28-30`、`knowledge/entries/task-planaudit-20261116.md:32-36` | ☑ 计划期 | Research Findings / Issues Encountered |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### 2026-11-16 计划期基线核实（plan-writer，来源=本地 Read/Grep 已验证）

#### A. attest-plan.sh 门链与插入锚点
- 文件 606 行；门链顺序：skip 旗标解析 :26-45 → 探测活跃计划 :47-72 → 缓存键 :84-100 → check-plan-dispatch :106-122 → template-gate :123-163 → tier-consistency :164-198 → Rule 51.1 requirement-gate :199-242 → VC 可执行门 :243-392 → FMEA :393-475 → rule-reserve :476-539 → window-lint :540-561 → `hash=` 取用 :562 → 写 `.plan-attestation` :570。
- **插入锚点**：新 `[audit-gate]` 置于 window-lint 段之后、`hash=` 取用（:562）之前；门失败 exit 1 时不写 `.plan-attestation`（与 :563-566 注释「先哈希后写」纪律一致）。
- **skip 旗标范式**：变量声明 :26-31、参数解析 :32-45、缓存键 :88、缓存回放 WARN :93-99。新 `--skip-audit-check` 必须同型接入四处（否则缓存命中不回放 WARN，或跳旗标不进缓存键）。
- **缓存键关键缺陷面**：`_attest_cksum` 以 `plan_sha256 + skip flags + 门控 env` 组成；若 `skip_audit`/`TASK_PLANNER_AUDIT_GATE_ENFORCE` 未纳入，会回放陈旧 PASS；`progress.md` 审计留痕变更（APPROVED 追加/移除）若不纳入 `sha256(progress.md)`，同样不失效缓存（F3/F4）。
- **档位解析既有形态**：attest 的 requirement-gate 用 `grep -qm1 'plan_tier: mini'`（:218）；tier-consistency 用行首锚定 `^plan_tier:` + `^execution_lane:` + `grep -oE 'L[012]([_-][A-Za-z0-9]+)*'`（check-tier-consistency.sh:60-63）。审计门采用后者（精确 token，L0-T/L0-E 不被截成 L0）。

#### B. checker 判定器范式（shell-out + rc 0/1/2）
- `check-tier-consistency.sh`：输入 `<plan-dir>`；rc 0=一致/无判定面，1=不一致，2=输入缺失；stdout 前缀 `[tier-consistency]`；attest 侧 shell-out 段 :174-198 按档位裁决。
- `check-vc-nonvacuous.sh`：rc 0/1/2 同构；stdout 前缀 `[vc-nonvacuous]`；attest 侧 shell-out :301-319。
- **审计门 checker 采用同构**：`check-plan-audit-gate.sh <plan-dir>`，rc 0=通过/跳过，1=审计留痕缺失/未 APPROVED，2=输入缺失；stdout 前缀 `[audit-gate]`；attest 侧 fail-open on rc 2，enforce on rc 1。判定语义（F5/F6/F9/F11/F12）：lane 优先（L1/L2 必审，mini×L1 按最严）、无声明显式 `SKIP legacy-no-decl`、APPROVED 末段须含 `审计体:`/`轮次:`/`问题清单`（**`问题清单` 容忍全角/半角括注后接冒号**——真实段字节形态 `- 问题清单（留档，不阻断）:`，R7 I-1）、轻量档 skip 放行而 L1+ skip 拒锁、rc2 输出 `[audit-gate] WARN 判定器输入异常` 并 fail-open（progress.md 文件缺失/不可读=rc2、存在但空=无留痕 rc1，R7 Q-2）。

#### C. 审计留痕形态与 APPROVED 末段聚合
- 先例 `plans/archive/task-planaudit-20261116/progress.md`：
  - `[plan-audit-R1]` :119 段，结论 `REJECTED`
  - `[plan-audit-R2]` :148 段，结论 `REJECTED`
  - `[plan-audit-R3]` :194 段，结论 `**APPROVED**`（:195）
- 先例 `verification.md:30` 的 VC-6 验证命令使用 awk 末段聚合：
  `awk '/^## \[plan-audit-R[0-9]+\] /{buf=""} {buf=buf $0 "\n"} END{printf "%s",buf}' progress.md | grep -q "结论: \*\*APPROVED\*\*"`
- **判别性**：awk 正则要求 `] ` 后接空格，天然排除 `[plan-audit-R<N>-revision]` 收据段；取最后一个 `R<N>` 段（末段）判 APPROVED。checker 复用同形——**已被 R6a 加固推翻**：中间态假阳性实测后改为「聚合边界止 H2+结论行 ERE 行首锚定」两约束，见 kb:27 与本档 R6a/R7 处置段（本行为历史研究记录，保留+指针）。
- **`[plan-audit-skip]` 形态**：SKILL.md:70 已定义「一行留痕 `[plan-audit-skip]`+理由」；critical-rules.md:202/:208 两处引用。基线非零（1/2），故不作为新 token 判别面。语义（F11）：仅轻量档生效；L1+ 写 skip 仍拒锁，唯一逃生=`--skip-audit-check` 参数+WARN+交付披露。
- **APPROVED 最小形态（F5）**：末段除 `结论: **APPROVED**` 外，还须含 `审计体:`+`轮次:`+`问题清单`，缺任一=FAIL；**`问题清单` 判据容忍全角/半角括注后接冒号**（真实段 `- 问题清单（留档，不阻断）:`；按字面连写冒号会对真实 plan-dir 恒误拒，R7 I-1）；防生产者可写自述无形态校验。

#### D. selftest 范式与 registry 契约
- `selftest-vc-nonvacuous.sh:29-174`：`set -u`；`ok()/bad()` 计数器；`mktemp -d` 夹具；逐条 `VNC-NN PASS/FAIL`；末行 `Total: PASS=x FAIL=y`；`[ "$FAIL" -eq 0 ] || exit 1`；夹具跑毕即删。
- `selftest-tier-consistency.sh:1-138`：静态锚（脚本在位/bash -n/头注 What+Why/前缀+exit 语义/registry 自登记）+ 行为 fixture（mini 降档/L0 多重/standard 正例/无声明 SKIP）。
- `selftest-plan-dispatch.sh:12-30`：`TMP="$(mktemp -d)"` + `trap 'rm -rf "$TMP"' EXIT`；`assert()` 逐用例断言 rc + stdout/stderr 必含；含 attest 集成 fixture（T06）。
- `selftest-registry.tsv`：表头 4 列 `script	domain	trigger_scenarios	dep_anchors`；`selftest-registry.sh` T02 要求每个实际 `selftest-*.sh` 有行、T03 无孤儿、T05 四列非空。新 selftest 必须登记。
- **审计门 selftest 采用**：静态 token + 行为断言（APPROVED 通过/无留痕拒锁/轻量 skip 放行/L1+ skip 拒锁/mini 跳过/mini×L1 冲突必审/APPROVED 形态残缺 FAIL/rc2/缓存隔离）；fixture 全在 `/tmp`，正负例各用独立 task_plan 内容或每例清理 `/tmp/attest-cache-*`，不触真实 `plans/`。

#### E. Rule 109 现文与机器面边界
- `critical-rules.md:194-212` Rule 109：109.1 总则、109.2 计划面强制门、109.3 分档豁免、109.4 覆盖面映射、109.5 未列面判定、109.6 留痕、109.7 文本优先与机器面边界、Why 段。
- **109.7 现文（:210）**：「本条为文本条款承载；selftest 断言/attest 接线/门控脚本属机器面范围扩张，未经用户显式授权禁实施（宪法 §十 文本优先铁律；候选清单=plans/task-planaudit-20261116 CA-6）。」
- **授权后处置**：不改写 109.7；追加 109.8「机器面已授权范围（2026-11-16 用户授权 #1）」——仅授权 attest [audit-gate]+check-plan-audit-gate.sh+selftest-plan-audit-gate.sh；109.8 同时明确 skip 仅轻量档、L1+ 唯一逃生=`--skip-audit-check`；其余机器面仍默认禁。`^### 109 ` 定义仍唯一。
- SKILL.md:68-77 审计门区块已含分档/裁决/迭代/留痕/阻断；缺机器面一行。SKILL.md:70 已有 `[plan-audit-skip]`，:75 已有 `[plan-audit-R<N>]`。

#### F. 基线负断言（改动前，2026-11-16 计划期实测）
| 探针 | 命令 | 结果 |
|------|------|------|
| `audit-gate` in attest-plan.sh | `grep -c 'audit-gate' skills/task-planner/scripts/attest-plan.sh` | 0 |
| `audit-gate` in SKILL.md | `grep -c 'audit-gate' skills/task-planner/SKILL.md` | 0 |
| `audit-gate` in critical-rules.md | `grep -c 'audit-gate' skills/task-planner/references/critical-rules.md` | 0 |
| `plan-audit-skip` in SKILL.md | `grep -c 'plan-audit-skip' skills/task-planner/SKILL.md` | 1（既有，非新 token） |
| `plan-audit-skip` in critical-rules.md | `grep -c 'plan-audit-skip' skills/task-planner/references/critical-rules.md` | 2（既有，非新 token） |
| checker 文件 | `ls skills/task-planner/scripts/check-plan-audit-gate.sh` | absent |
| selftest 文件 | `ls skills/task-planner/scripts/selftest-plan-audit-gate.sh` | absent |
| registry 行 | `grep -c 'selftest-plan-audit-gate.sh' skills/task-planner/scripts/selftest-registry.tsv` | 0 |

> 判别性成立：`[audit-gate]`/`--skip-audit-check`/`check-plan-audit-gate.sh`/`selftest-plan-audit-gate.sh` 为新增 token/文件；`plan-audit-skip` 为既有载体，不作为新判别面。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 独立 checker `check-plan-audit-gate.sh` + attest shell-out | 可独立 fixture 测试；与 check-tier-consistency/check-vc-nonvacuous 同构；降低 attest 门链内联逻辑漂移面 |
| L1+ 仅显式 `plan_tier: standard|full` 或 `execution_lane: L1|L2` 才检查 | 不阻断无声明 legacy 计划；新计划由 init 写入 standard/L1 天然进入检查面 |
| mini/L0/L0-T/L0-E 跳过检查 | 对齐 Rule 109.3 分档豁免与 Rule 38.7 比例原则；轻量档不进 attest 检查面 |
| 自举条款=bootstrap: gate-absent（方案 a） | D1 走既有文本审计链路（critic APPROVED 已是前置）；机器门 Phase 5 merge-back 后由主进程用主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]`；避免「门不存在=默认通过」冒充走门实证（F8/N2） |
| `[plan-audit-skip]` 仅轻量档生效；L1+ 写 skip 仍拒锁 | 对齐 109.3 轻量档限定与用户授权范围；L1+ 唯一逃生=`--skip-audit-check` 参数+WARN+交付披露（F11） |
| lane 优先：execution_lane L1/L2 必审，mini×L1 按最严 | 防冲突声明被 mini 分支跳过；存量真实冲突计划按最严审（F6） |
| APPROVED 段最小形态校验 | 末段须含 `审计体:`+`轮次:`+`问题清单`（`问题清单` 容忍全角/半角括注后接冒号——真实段形态带括注，R7 I-1），防生产者可写自述无形态校验（F5） |
| rc2=fail-open+显式 WARN 行 | 与既有 shell-out 先例一致；避免判定器输入异常被当硬失败（F9） |
| 零新 config 键，env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE` | 避免 config properties 键数 53 的级联断言；对齐 Rule 84.6 env-only 先例 |
| 109.7 原文保留，追加 109.8 | Rule 74 增量默认；避免改写既有条款语义；109.8 限定授权范围，其余机器面仍禁 |
| checker 插入 attest window-lint 后、hash 前 | 门失败不写 `.plan-attestation`；与「先哈希后写」纪律一致 |
| 缓存键同时纳入 `skip_audit`、`TASK_PLANNER_AUDIT_GATE_ENFORCE`、`sha256(progress.md)` | 防 skip/档位翻转/审计留痕变更时回放陈旧 PASS；selftest 增缓存隔离用例（F3/F4） |
| Phase 2 主进程直做（25.3②） | 设计冻结与变更表维护均为 plans/** 计划文档；派发开销大于收益 |
| Phase 5 仍由 code-runner-agent 承载回归，S2 主进程兜底 merge/deploy | 委派率 4/5=0.800 ≥ floor；git 编排属白名单①由主进程兜底 |

## 2026-11-17 R1 修复轮处置对照（F1-F14，增量修订）

| 发现 | 处置 | 落点 |
|------|------|------|
| F8[CRITICAL] 自举时序 | 冻结方案 a：D1 走既有文本审计链路（bootstrap: gate-absent）；VC-5 改 Phase 5 merge-back 后主仓新 attest 对本 plan-dir 实跑 rc=0 且输出含 `[audit-gate]` | task_plan Goal/不变量/R→VC/VC-5/Notes/Next Step/Phase 5；verification Goal/VC-5/V-5.1 |
| F3[I] cksum 未含 enforce env | `_attest_cksum` 同时纳入 `skip_audit`+`TASK_PLANNER_AUDIT_GATE_ENFORCE`；selftest 增缓存隔离 fixture（enforce→off→enforce） | task_plan CA-8/VC-2/P3-S2/P3-S3；verification VC-2；kb §2/§4 |
| F4[I] cksum 未含 progress.md | `_attest_cksum` 并入 `sha256sum progress.md`；正负 fixture 独立内容/每例清理 `/tmp/attest-cache-*` | 同上 + selftest 断言清单 |
| F11[I] L1+ skip 旁路 | skip 仅轻量档生效；L1+ 写 skip 仍拒锁；唯一逃生=`--skip-audit-check`+WARN+披露；断言⑤改双断言 | task_plan VC-1/VC-3/KeyQ2/CA-7/CA-9；verification VC-1/VC-3；kb 概念/§2/§4 |
| F13[I] VC-3 不执行 selftest | VC-3 Verify command 改为直接执行 `bash .../selftest-plan-audit-gate.sh`（exit 0 判）+ registry 行 `&&` | verification VC-3 |
| F1[I] VC-6 判据缩水 | 冻结为全量 `run-selftests.sh --fresh` Total FAIL=0 + 三部署位 `diff -r` 零差异 | task_plan VC-6/G5；verification VC-6/Phase 5 |
| F2[W] 范围无机器断言 | VC-6 增 worktree `git diff --name-only master` + `ls-files --others`（含 untracked）⊆ scope_files，merge-back 前执行 | verification VC-6 |
| F5[W] APPROVED 无形态校验 | checker 增末段最小形态（审计体/轮次/问题清单），缺任一=FAIL + selftest 负例 | task_plan VC-1/CA-7/P3-S1/P3-S3；verification VC-1；kb §2/§4 |
| F6[W] mini×L1 优先级未定 | lane 优先：L1/L2 必审，mini×L1 按最严；fixture 增冲突用例 | task_plan VC-1/CA-7/KeyQ1/P3-S1；kb §2/§4 |
| F9[W] rc2 语义未定 | rc2=fail-open+显式 `[audit-gate] WARN 判定器输入异常`；selftest 覆盖输入缺失 | task_plan VC-1/P3-S1；verification VC-1；kb §2/§4 |
| F12[W] 存量迁移面未登记 | Phase 5 增迁移说明登记（9 无声明+7 个 standard/L1 无留痕（未归档在途口径，含已 complete 未归档）；存量不重锁+首版 warn 建议）；无声明显式 `SKIP legacy-no-decl` | task_plan Phase 5 清单/S2/VC-1；verification Phase 5 Done |
| F14[W] VC-1/2 纯静态 grep | VC-1/VC-2 Verify command 落 fixture 负例实测（无留痕 L1+→checker rc1 / attest exit≠0 且锁文件不存在） | verification VC-1/VC-2 |
| F7[NIT] kb awk 未转义 | kb §2 改 `^## \[plan-audit-R[0-9]+\] ` 并注明以先例 verification.md:30 为准 | knowledge-brief §2 |
| F10[NIT] kb 逃生旗标表述 | 改为「仅 argv 参数同型，不提供 env 逃生」 | knowledge-brief §1 概念表 |

## 2026-11-17 R2 修复轮处置对照（N1-N6，增量修订）

| 发现 | 处置 | 落点 |
|------|------|------|
| N1[CRITICAL] VC-6 git 范围断言指向主仓工作树 | 改为 worktree 路径 + `ls-files --others` 纳入 untracked；执行时点=merge-back 前；部署位 diff 后置 V-5.2 | task_plan VC-6/Notes；verification VC-6/Phase 5 V-5.2 |
| N2[IMPORTANT] 自举实测执行体/路径/断言三错 | 自举实测归主进程并入 Phase 5 S2（merge-back 后）；命令改为主仓路径；断言 rc=0 + `grep [audit-gate]` 实质输出 | task_plan Goal/VC-5/Phase 5 S2/Notes/Decisions；verification Goal/VC-5/V-5.1 |
| N3[W] Phase 4 V-N 含不可达 VC-6 | 删 VC-6，改 VC-4 并注明 VC-6 时点=全部 Phase 完成后终验 | task_plan Phase 4 V-N |
| N4[W] VC-1/VC-2 只断言负例 | VC-1 增合规 fixture rc0；VC-2 增 APPROVED+三 token 正向用例（attest exit 0 且锁文件存在） | verification VC-1/VC-2；task_plan VC-1/VC-2 验证方式 |
| N5[NIT] progress 占位段语义错 | APPROVED 段改为自举实测**输入**（非证据）；补 审计体:/轮次:/问题清单: 最小形态提示 | progress.md 审计留痕占位 |
| N6[NIT] Decisions 缺缓存取舍说明 | 补「正确性优先：progress 进 cksum 使缓存命中率归零」有意取舍行 | task_plan Decisions |

## 2026-11-17 R3 修复轮处置对照（I1 + W1/N7/N8，增量修订）

| 发现 | 处置 | 落点 |
|------|------|------|
| I1[IMPORTANT] VC-6 scope 子断言失败开放 + 无调度落点 | 命令前置 `test -d <worktree>` 缺失即 exit1；`git diff`/`git ls-files` 各自 rc 捕获失败即 exit1；`out=$(... || true)` 后 `test -z` 非空即 FAIL（git 任何失败均非空退出）；Phase 5 S2 增 merge-back **前** `[scope-check]` 留痕为唯一权威证据 | verification VC-6；task_plan Phase 5 S2/Notes |
| W1[W] Phase 5 V-N 与终验时点互斥 | :284 改 `VC-5（VC-6 分两段：范围断言=S2 内 merge-back 前执行并留痕；部署位 diff/回归=终验 Goal Gate 复核）` | task_plan Phase 5 V-N |
| N7[NIT] VC-2 负例 r1 前无清缓存 | 负例 r1 执行前补 `rm -f /tmp/attest-cache-*.result`（防同键历史缓存假失败） | verification VC-2 Verify command |
| N8[NIT] VC-1 rc2 措辞与实测不匹配 | 收敛为「rc 0/1 本命令实测（r3=rc0/r1=rc1）；rc2 fail-open 语义见 VC-3 selftest」 | verification VC-1 判据 |

## 2026-11-17 R4 修复轮处置对照（C-1/I-1/W-1/W-2/N-1/N-2，增量修订）

| 编号 | 发现（R4 critic） | 处置 | 落点（grep -n 可定位） |
|------|------------------|------|----------------------|
| C-1[CRITICAL] | verification.md:37 尾部 `test "$(grep -c "\"audit" config.json \|\| echo 0)" -eq 0` 恒败：`grep -c` 零命中已打印 `0` 且 exit 1，`\|\| echo 0` 追加第二个 0 → 变量=`0\n0` → `integer expression expected` rc=2 | 改 `test -f <config.json> && ! grep -q "\"audit" <config.json>`（缺文件 fail-closed；grep rc1 经 `!` 翻转为成功）。本机双态实测：旧形态 rc=2 / 新形态真实 config rc=0 / 含键 fixture rc=1 / 缺文件 fixture rc=1 | `verification.md:37` |
| I-1[IMPORTANT] | `test -d "$WT"` live 断言与 Phase 5 S2 强制 worktree 清理互斥 → 终验复跑必 FAIL；task_plan.md:269 残留「终验复验」矛盾 | ① VC-6 Verify 删 live worktree 断言，改段锚 awk + `SCOPE-OK` token 复核 progress.md Phase 5 段留痕；② 保留 live 复跑部分（run-selftests Total FAIL=0 + 逐字锚 grep + config 断言）；③ 范围断言本体移 task_plan Phase 5「S2 内嵌命令」（merge-back 前执行，失败不写 PASS 行）；④ 清理 :269 为两段式口径；⑤ Evidence/Notes 同步 | `verification.md:35-37`、`task_plan.md:269`、`task_plan.md:281`、`task_plan.md:291`、task_plan.md Phase 5「S2 内嵌命令」块、task_plan.md Notes「VC-6 两段式时点与证据」（本行「段锚 awk」形态已被 R5 I-1 取代——见下「R5 修复轮处置对照」表） |
| W-1[W] | 白名单正则文件级分支缺 `$` 锚 → `SKILL.md.bak` 类副产物静默越界放行 | 六个文件级分支全部补尾锚 `$`（`attest-plan\.sh$`/`check-plan-audit-gate\.sh$`/`selftest-plan-audit-gate\.sh$`/`selftest-registry\.tsv$`/`SKILL\.md$`/`critical-rules\.md$`），目录分支保持尾 `/`。合成仓实测：`SKILL.md.bak`/`attest-plan.sh.bak`/`other-script.sh` 拦截 rc=1，白名单控制组放行 rc=0 | task_plan.md Phase 5「S2 内嵌命令」代码块 |
| W-2[W] | `[scope-check]` 留痕无确定性 token 格式 | 定形态 `[scope-check] <ISO8601> SCOPE-OK diff=N untracked=N`；:281 步骤与 :291 验收双处登记；VC-6 Verify 以 `SCOPE-OK` 为机器 token | `task_plan.md:281`、`task_plan.md:291`、`verification.md:36` |
| N-1[NIT] | 管道 `\|\| true` 使 grep rc=2（模式/读错误）也落空输出放行；白名单为 scope_files 手抄副本（漂移面） | 改 `rc=0; out=$(...) \|\| rc=$?; test "$rc" -eq 0 -o "$rc" -eq 1 \|\| exit 1`；S2 验收与 VC-6 Evidence 增「白名单集合执行时与 `scope_files` 逐项核对一致」。实测：非法正则 rc=2 → exit 1；`\|\| true` 形态掩蔽为 rc=0；rc=1 合法续行 | task_plan.md「S2 内嵌命令」、`task_plan.md:291`、`verification.md:36` |
| N-2[NIT] | VC-1 措辞收敛后漏 r2（mini×L1 冲突负向）枚举 | 改为「rc 0/1 本命令实测（r3=rc0 正向 / r1=rc1 无留痕负向 / r2=rc1 mini×L1 冲突负向）」 | `verification.md:15` |

**R4 教训**：① `grep -c ... || echo 0` 是双零陷阱（零命中时 grep 已打印 0 且 rc=1），「无新增键」类断言应用 `test -f` + `! grep -q`；② fail-closed 改造必须核对**复跑时点资源存续**——R3 引入的 worktree live 断言与 S2 强制清理互斥，把真空放行翻转为确定性阻断（「修复引入回归」形态）；③ 计划期 VC 应做确定性干跑（fixture 正反态实测），不能只做静态「非真空」判定。

## 2026-11-17 R4b 微修轮处置对照（VC-6 判据 × 存量基线确定性冲突，单一主题）

| 项 | 发现 | 处置 | 落点（grep -n 可定位） |
|----|------|------|----------------------|
| 冲突 | VC-6 现行判据「全量 selftest `--fresh` 回归 0 FAIL」与存量基线确定性冲突：`Total: 99 PASS=92 FAIL=7`（7 项均为他任务在途遗留），Phase 5 终验必 FAIL → outcome 禁 COMPLETE | 改判「**同集零增量**」：断言面仍是全量回归（不缩子集），冻结已知存量失败集合、判「`Failed:` 集合==冻结集合且 `FAIL=7`」 | `task_plan.md:83`、`task_plan.md:241-253`、`verification.md:35-37` |
| 基线冻结 | 无冻结载体（判据悬浮在「0」这个绝对数上，无对照面） | Phase 1 新增冻结块：`Total:`/`Failed:` 行原文逐字 + 冻结日期 2026-11-17 + 归属说明（他任务在途遗留、R3 射程外）+ 判据语义 + 漂移条款 | `task_plan.md:230`（checkbox）、`task_plan.md:241-253`（块） |
| 判据一致性 | 同一含义散在 6 处（R→VC 映射 / VC-6 行 / G5 / Phase 5 步骤 / S-unit 验收 / Goal Gate），仅改一处会留矛盾 | 六处同步改口径（全改「同集零增量」并显式写「不是降低强度，是冻结已知失败集合」） | `task_plan.md:24,83,120,294,305,408`、`verification.md:35,182` |
| Verify command | `grep -qE "^Total: ... FAIL=0"` 在当前仓恒败；且原形态只校验计数、不校验名单（换成同名数不同集的失败也能过） | 改为「单次 `--fresh` 落 `mktemp` 文件 → `grep -qE '^Total: ... FAIL=7 '` + `grep -q '^Failed: <7 名单>$'`」双断言；`Failed:` 行用**整行等值**（两端锚），故计数相同但名单被换也判失败（TC-B2 实证） | `verification.md:37` |
| 基线漂移（禁静默放宽） | 若他任务收口使基线合法变化，硬编码 `FAIL=7` 会误判；但无条件放松又等于开规避口 | 三处一致条款：主进程重跑冻结新基线 + `progress.md` 记 `[baseline-shift] <ISO8601> <新 Total> | <新 Failed> | <原因>` + 同步更新冻结块与 Verify command 字面量；**未留该行而判据松动=违规** | `task_plan.md:253`、`task_plan.md:408`、`verification.md:36` |

**R4b 教训**：① 跨任务共享仓的回归判据**不能写成绝对零**（`FAIL=0`）——他任务在途债会在本任务终验时点确定性击穿判据，正确形态是「冻结基线集合 + 判无新增」；② 「同集零增量」必须**同时断言计数与名单整行**——只断言 `FAIL=N` 会让「换成同名数的不同失败集」静默通过；③ 判据变更必须扫全同义面（本次 6 处），否则 R5 审计必抓残留矛盾；④ 冻结必有漂移风险，故必须配 `[baseline-shift]` 显式留痕条款，把「放松」变成需要凭据的审计动作，而非默认行为。

## 2026-11-17 R5 修复轮处置对照（C-1/I-1/W-1/W-2/Q-1/N-1/N-2/N-3，增量修订）

| 编号 | 发现（R5 critic） | 处置 | 落点（grep -n 可定位） |
|------|------------------|------|----------------------|
| C-1[CRITICAL] | VC-2 Verify command 断言顺序污染：负例断言组 `test ! -f .plan-attestation` 写在正例（同 `$T` 建锁）之后 → 恒假 → n=1 → 无 PASS 路径 | **断言捕获时点紧跟各自用例**：负例断言紧贴 `r1` 捕获（在正例 fixture 写入与正例执行之前，`n=$?`），正例断言紧贴 `r2` 捕获（`p=$?`），末尾仅汇总 `test "$n" -eq 0 && test "$p" -eq 0`；其余元素（`rm -f /tmp/attest-cache-*.result` 双处、awk fixture、enforce env、`rm -rf "$T"`）全部保留。/tmp mock 实测：旧形态 rc=1（插桩 n=1）/ 新形态 rc=0（n=0,p=0）/ 破坏变体（负例也建锁）rc=1 | `verification.md:21`（命令）、`verification.md:20`（Evidence 增断言时点说明） |
| I-1[IMPORTANT] | S2 的 `echo ... >> "$PROG"` 文件末尾追加 ↔ VC-6 段锚 awk 只读 `### Phase 5:` 段 → 留痕恒落段外，终验必 FAIL；S2 验收位置不敏感 grep 查不出 | **改全文件严格 token 正则**（S2 追加形态保持不变）：`grep -qE "^\[scope-check\] [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z SCOPE-OK diff=[0-9]+ untracked=[0-9]+$" "$P"/progress.md`；判据/Evidence/Notes 口径同步；progress.md Phase 5 段补槽位说明行（非 SCOPE-OK 行本身）。六态实测：无留痕 rc=1 / 段内 rc=0 / EOF rc=0 / 缺 SCOPE-OK rc=1 / 缺 diff=N rc=1 / 带项目符号前缀 rc=1；端到端 TC 正向 rc=0、去留痕 rc=1、假 FAIL 名 rc=1 | `verification.md:35-37`、`task_plan.md:296`、`task_plan.md:306`、`task_plan.md:310`、`task_plan.md:407`、`progress.md` Phase 5 段 |
| W-1[W] | 基线漂移条款仅需一行 `[baseline-shift] <原因>` 自述即可改判据字面量 → 本任务自身新增 FAIL 也可被吸收 | 加**防滥用双闸**：① 逐名归因（名单每个新增/消失条目须指认他任务/提交锚，**无法指认的新增 FAIL 不得吸收**）；② 漂移后重走 critic 文本审计（判据字面量变更简版复审并留痕，禁主进程自裁）；`[baseline-shift]` 行格式扩为 `<ISO8601> <新 Total> \| <新 Failed> \| <逐名归因> \| <重跑冻结依据> \| <critic 简版复审结论>` | `task_plan.md:253`、`task_plan.md:408`、`verification.md:36` |
| W-2[W] | verification.md 5-Question Reboot Check / 交叉验证记录仍停在 R1/R2（4b 只同步了 task_plan） | 同步为当前实态：Where am I=R1-R4 逐轮修复+4b 完成+R5 修复轮 5 进行中；Where going=R6 复审→D1→…；What done=各轮增量修订+八门 rc=0；交叉验证记录改「R1-R5 均 REJECTED 并逐轮修复，修复轮 5 收口后交 R6」 | `verification.md:198`（交叉验证记录）、`verification.md:207-211`（5-Question 块） |
| Q-1[Q] | V-1.1 基线负断言与 Phase 3 产物天然互斥，疑终验复跑误判 | V-1.1 条目行加**时点注记**：仅 Phase 1 时点执行（基线快照）；Phase 3 落地后自然失效，**终验 Goal Gate 不复跑本 gate**（注记落在条目标签行而非 Verify command 行，保持命令可直接复跑） | `verification.md:53` |
| N-1[NIT] | config 断言 `! grep -q` 在 grep rc=2（文件不可读）时经 `!` 翻转 fail-open | 改显式 rc 捕获组：`test -f X && { grc=0; grep -q "\"audit" X 2>/dev/null \|\| grc=$?; test "$grc" -eq 1; }`（found→0→败；not found→1→过；error→2→败=fail-closed）。三态实测：含键 rc=1 / 无键 rc=0 / chmod 000 rc=1（旧形态 rc=0）；端到端 不可读 rc=1、真实 config rc=0 | `verification.md:37` |
| N-2[NIT] | progress.md:176 W-2 处置引用行号 stale（写 :281/:291，实际 :296/:306） | 历史段不改写，行尾追加括注「（行号后移：实际落点现为 task_plan.md:296/:306——R4 内嵌命令块插入所致）」 | `progress.md:177` |
| N-3[NIT] | progress.md:195 R4 历史段「VC-6 要求全量 FAIL=0」无 superseded 指针 | 行尾追加「（已由 R4b 处置：改同集零增量+基线冻结，见 [plan-audit-R5] 前的 R4b 段）」 | `progress.md:196` |

**R5 教训**：① **断言捕获时点必须紧跟各自用例**——共享 fixture 的命令里，晚求值的断言会被后续用例改写的共享状态污染（负例 `test ! -f` 在正例建锁后恒假），这是「无 PASS 路径」类恒败的第二个来源（首个是 R4 的 `grep -c || echo 0` 双零）；② **产出物写入位置必须与其消费断言的定位方式互洽**——产出是文件末尾追加就只能用全文件 token 匹配，段锚只在产出定向插入该段时成立；S-unit 验收若用位置不敏感 grep 会掩盖该缺陷（缺陷潜伏到终验/merge-back 后）；③ 冻结-漂移类条款必须配「逐名归因 + 独立复核」双闸，否则自述即可放宽判据；④ 轮次推进必须同步四处状态块（task_plan Current Phase/Next Step + verification 5-Question/交叉验证），否则会话恢复读到过期断点。

## 2026-11-17 R6a 修订轮处置对照（checker 末段聚合中间态假阳性，单点加固）

**发现来源**：主进程 2026-11-17 一手 `/tmp` 实测（非 critic 提出）。既有聚合形态（=kb §2「先例 APPROVED 末段聚合命令」：awk 只认 `^## [plan-audit-R[0-9]+] ` 段头 + 未锚定 `grep -q "结论: \*\*APPROVED\*\*"`）的末段 buf 从**最后一个审计头延伸到 EOF**；当审计段后还跟有修复轮块（中间态）时，buf 会吞进后续块中**反引号内的元引用**（如修复轮收据自证行「无审计段级 `结论: **APPROVED**` 预写」）→ 未审也放行（伪 PASS）。修复轮收据**天然**引用该三 token（checker 自身强制的最小形态），未来计划必然复现；先例 `task-planaudit-20261116` 同形态未暴露，因其验证时点恰为终态。

**实测（`/tmp/r6a`，两形态 mock checker 对同一 fixture；真实执行输出）**：

| 状态 | 构造 | OLD 形态 rc | 加固形态 rc | 判定 |
|------|------|------------|------------|------|
| s1 | 终态：`[plan-audit-R6]` 结论 APPROVED（fixture） | 0 | 0 | 无假阴性 |
| s2 | **中间态**：`[plan-audit-R5]` 结论 REJECTED + 后随 `## 2026-11-17 R5 修复轮` 块含反引号元引用 | **0（假 PASS）** | **1（真 FAIL）** | 判别性成立 |
| s3 | 真实 `progress.md` 的 `head -304` 截断态（末审计段=R5，隐于 :299 元引用行） | **0（假 PASS）** | **1（真 FAIL）** | 判别性成立 |
| s4d | 真实全文件 + 追加无 APPROVED 结论行的簿记块 | 0 | 0 | 无假阴性 |
| s5 | 审计段内唯一 APPROVED 为行中反引号元引用（无正规结论行） | 0 | 1 | 锚定约束独立承重（仅边界约束不足） |
| s6 | 真实全文件现状 | 0 | 0 | 无假阴性 |

**修订对照（实际 Edit 落盘）**：

| # | 落点 | 动作 |
|---|------|------|
| 1 | `task_plan.md` 根源覆盖表「门控判定器实现」行 | 补两条硬约束（聚合边界止下一个 H2；结论行 ERE 行首锚定）并入缺陷面描述 |
| 2 | `task_plan.md` CA-7 行（依据+执行动作） | 依据补主进程实测证据；执行动作写入 ①② 两约束 |
| 3 | `task_plan.md` Phase 3 S1 验收 + S1 目标 | 两约束写入验收判据 + **中间态假阳性负例**（必 rc1）；输入补 kb §2 指针 |
| 4 | `task_plan.md` VC-1 判据/验证方式 | 同步两约束 + 中间态负例（同义面一致性） |
| 5 | `task_plan.md` Phase 2 checkbox（规格定稿）+ Phase 3 S1 checkbox | 规格项补「聚合边界止 H2/结论行 ERE 锚定」（同义面一致性） |
| 6 | `verification.md` VC-1 判据 + Verify command | 判据写入两约束与 r4；**Verify command 增 r4 用例**（REJECTED 段+后随元引用修复轮块，awk 以 `sprintf("%c",96)` 生成反引号避免命令替换），末尾断言 `test "$r4" -eq 1` |
| 7 | `verification.md` VC-3 fixture 清单 + 知识储备核验行 | 增「中间态假阳性」用例；标注两约束由正向+中间态负例共同承重 |
| 8 | `knowledge-brief.md:27`（先例聚合命令行） | 补加固说明（实测证据+两约束+存量先例不改写） |
| 9 | 状态块簿记 | `task_plan.md` Current Phase/Next Step 与 `verification.md` 5-Question/交叉验证记录同步至 R6a 态（防 stale 断点） |

**R6a 教训**：① **「末段」必须显式定义边界**——只拿同族头（`[plan-audit-RN]`）当边界时，后随任何 H2 块都会被吞；边界须止于下一个 H2。② **结论类 token 必须行首结构锚定**——「审计结论」与「关于结论的叙述/元引用」用的是同一串 token，裸 grep 无法区分；元引用的判别特征是行中位置与引号包裹。③ **自测脚本自身也要实测**——首版 mock 用 `exit` 在首个 `## ` 处终止程序（只聚合了首个审计段），终态 fixture 假 FAIL；改 `inbuf=0; next` 后六态全对。mock 必须覆盖正例/负例/多同类头三面，否则测试的测试仍可能骗过自己。

## 2026-11-17 修复轮 7 处置对照（I-1/I-2/W-2/Q-1/Q-2，增量修订）

critic R7 范围化复审 REJECTED（0C/2I/2W/2Q/2N）；W-1（5Q 刷新）/N-1（:440 算术）/N-2（复跑留痕）由主进程登记时点处置，本轮修五项计划面。

| 编号 | 发现（R7 critic） | 处置 | 落点（grep -n 可定位） |
|------|------------------|------|----------------------|
| I-1[I] | 最小形态 token `问题清单:` 与唯一 APPROVED 审计段真实字节形态（`- 问题清单（留档，不阻断）:`）脱钩 → spec-literal checker 对真实 plan-dir 恒 rc1，VC-5 自举实测与 Phase 5 attest 实跑确定性失败 | ① token 定义改容忍形态：`问题清单` 后允许全角/半角括注再接冒号（ERE `^- 问题清单([（(][^）)]*[）)])?:`），`审计体:`/`轮次:` 维持字面（真实段无括注）；② VC-1 增 **r7 真实生产形态正例**（R6 段字节形态 → 必 rc0），保留 r3 规范示意形态正例；③ VC-3 用例清单同步双正例 | `verification.md:15,16,17,23`、`task_plan.md:78,141,275`、`knowledge-brief.md:27,69`（+§4 新增 17）、`findings.md:41,52,91`、`progress.md:76` |
| I-2[I] | 两约束只测「全缺」（r4）抓不到「只做其一」：仅边界 rc0 假 PASS、仅锚定 rc0 假 PASS，各有一条独立假 PASS 路径 | VC-1 增 **r5**（fixture a：REJECTED 段内裸文 `结论: **APPROVED**` 意见文本 → 期望 rc1，抓「仅锚定实现」）与 **r6**（fixture b：后随 H2 块内含正规锚定 APPROVED 行 → 期望 rc1，抓「仅边界实现」）；末断言扩为 r1..r7 七项；VC-3 补两行为用例；判据改**逐约束承重归属**（边界↔fixture b / 锚定↔fixture a / 全缺↔中间态 r4） | `verification.md:15,17,23` |
| W-2[W] | 无声明 `SKIP legacy-no-decl` 无可执行判据（既有面，非本轮引入） | VC-3 用例清单补「无 `plan_tier`/`execution_lane` 声明 → rc0 且输出含 `[audit-gate] SKIP legacy-no-decl`」；VC-1 判据与 task_plan VC-1 标注该分支有 fixture 承重 | `verification.md:15,23`、`task_plan.md:78,275` |
| Q-1[Q] | 聚合边界只认 H2，后随块若用 H3/粗体则约束静默退化（前提未强制） | 三处契约说明：聚合边界仅认 `^## `（H2）——**审计段后随块必须用 H2 标题**（H3/粗体则约束静默退化，checker 注释须登记该前提）；progress.md 占位区追加写作规范提示行；本文件新段即以 `## 2026-11-17 R7 修复轮` H2 自证 | `verification.md:15`、`knowledge-brief.md:27`（+§4 新增 16）、`task_plan.md:78,141,275`、`progress.md` 审计留痕占位区（append） |
| Q-2[Q] | progress.md 空文件归 rc1 还是 rc2 未定义 | 契约固化：`progress.md` **文件缺失/不可读=rc2**（fail-open+`[audit-gate] WARN 判定器输入异常`）、**存在但空=无留痕 rc1**；VC-3 的「rc2 输入缺失」用例明确为**删除文件**（非清空）；VC-1 r1 保持清空（=rc1）不变 | `verification.md:15,23`、`task_plan.md:78,141,275`、`knowledge-brief.md` §4 新增 16 |

**R7 教训**：① **判据 token 必须二次对齐生产字节形态**——R6 修的是「regeln 正则」，R7 抓到的是「token 字面与真实留痕字节形态脱钩」（`问题清单（留档，不阻断）:`）；判据类改动须同时给「规范示意形态」与「真实生产形态」两个正例 fixture，否则实现者按 spec 写就与生产脱钩。② **单负例不足以证明两约束都承重**——多个独立约束（边界/锚定）必须各配能独立击穿它的负例（fixture a 击穿锚定缺失、fixture b 击穿边界缺失），否则「只做其一」的半加固实现全部假 PASS。③ **前提依赖要写入契约而非仅注释**——「后随块须用 H2」是 checker 行为的前提，只写在实现注释里等于没强制；须进 VC 判据 + kb + 计划 S-unit 验收。

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| R1 独立审计 REJECTED（14 发现：CRITICAL×1/IMPORTANT×5/WARNING×6/NIT×2） | 2026-11-17 增量修复轮逐项处置（见上表 F1-F14）；未改 R1-R3 逐字锚与 user-session-log #1；R2 复审 11 项闭合 |
| R2 独立审计 REJECTED（6 新发现：N1 CRITICAL + N2 IMPORTANT + N3/N4 WARNING + N5/N6 NIT） | 2026-11-17 修复轮 2 逐项处置（见上表 N1-N6）；未改 R 锚与 #1 原话；R3 复审 N1-N6 闭合 5/6（N2-N6 全闭合） |
| R3 独立审计 REJECTED（剩 I1 IMPORTANT + W1/N7/N8） | 2026-11-17 修复轮 3 逐项处置（见上表）；VC-6 fail-closed + S2 留痕；V-N 时点统一；缓存清理与措辞收敛 |
| R4 独立审计 REJECTED（6 发现：C-1 CRITICAL + I-1 IMPORTANT + W-1/W-2 WARNING + N-1/N-2 NIT） | 2026-11-17 修复轮 4 逐项处置（见上表）；C-1 双零陷阱重写、I-1 两段式（消灭终验必败）、W-1 尾锚、W-2 token、N-1 rc 捕获、N-2 r2 枚举 |
| R5 独立审计 REJECTED（8 发现：C-1 CRITICAL + I-1 IMPORTANT + W-1/W-2 WARNING + Q-1 QUESTION + N-1/N-2/N-3 NIT） | 2026-11-17 修复轮 5 逐项处置（见上表）；C-1 断言时序（共享 fixture 顺序污染，无 PASS 路径）、I-1 全文件严格 token 正则（EOF 追加 ↔ 段锚不兼容）、W-1 漂移双闸、W-2 状态块同步、Q-1 时点注记、N-1 rc fail-closed、N-2/N-3 行号括注。三约束与八机械门全绿 |
| R6 独立审计 APPROVED（0C/0I；残留 1W+3N 留档） | 收敛出口命中（R1×14→R2×6→R3×1→R4×2→R5×2→R6×0 C/I 增量）；证据 `subagent-state/audit-R6.md` |
| **R6a 主进程 /tmp 一手实测：checker 末段聚合中间态假阳性**（非 critic 提出） | 2026-11-17 单点加固（见上表）：聚合边界止下一个 H2 + 结论行 ERE 行首锚定 + 中间态假阳性负例（task_plan S1 验收/VC-1、verification VC-1 判据与 Verify command r4、VC-3 fixture、kb:27）；/tmp 六态判别性实测（s2/s3 旧形态 rc=0 假 PASS → 新形态 rc=1；s1/s4d/s6 终态双形态 rc=0 无假阴性；s5 证明锚定独立承重） |
| **R7 范围化复审 REJECTED**（0C/2I/2W/2Q/2N：I-1 token 形态与真实 APPROVED 段脱钩 / I-2 半加固不可判别 + W-2 legacy SKIP 无判据 / Q-1 H2 前提未强制 / Q-2 空文件 rc 口径未定） | 2026-11-17 修复轮 7 逐项处置（见上表）：容忍 token 判据 + r7 真实形态正例、r5/r6 两独立负例（期望值反转：半加固被抓）、legacy SKIP 用例、Q-1 H2 前提三处登记、Q-2 缺失=rc2/空=rc1 契约；W-1/N-1/N-2 由主进程登记时点处置 |
| **存量风险（R4 披露 → R4b 已处置）**：全量 selftest 基线 7 FAIL | R4b 改判「同集零增量」：冻结基线=`Total: 99 PASS=92 FAIL=7` + 7 名单（`task_plan.md` Phase 1「selftest 基线冻结」块）；VC-6 判「`Failed:` 集合==冻结集合且 `FAIL=7`」而非绝对 `FAIL=0`（断言面仍全量回归、不缩子集，非放宽）。正反态干跑：TC-A rc=0 / TC-B1（新增假 FAIL 名）rc=1 / TC-B2（计数同 7 但名单换）rc=1 / TC-C（旧判据 FAIL=0）rc=1 / TC-D~G 端到端 rc=0,1,1,0。合法漂移须 `[baseline-shift]` 留痕 + 同步字面量，**禁静默放宽** |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- `skills/task-planner/scripts/attest-plan.sh:26-99,106-198,540-562`
- `skills/task-planner/scripts/check-tier-consistency.sh:1-70`
- `skills/task-planner/scripts/selftest-vc-nonvacuous.sh:29-174`
- `skills/task-planner/scripts/selftest-tier-consistency.sh:1-138`
- `skills/task-planner/scripts/selftest-plan-dispatch.sh:12-30`
- `skills/task-planner/scripts/selftest-registry.tsv:1`
- `skills/task-planner/references/critical-rules.md:194-212`
- `skills/task-planner/SKILL.md:68-77`
- `plans/archive/task-planaudit-20261116/progress.md:119-208`
- `plans/archive/task-planaudit-20261116/verification.md:28-30`
- `knowledge/entries/task-planaudit-20261116.md:32-36`

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
- （本任务暂无多模态发现——未产生截图/PDF/网页证据）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

## Research Findings — Phase 1 基线核实（2026-11-17，worktree tmp/worktrees/task-auditgate-machine-20261116@7e67c5d；provider 限流→主进程直做降级，证据=双 explore agent failed: Provider rate limited）

### S1 attest 门链与插入锚点（worktree 实测 file:line）
- **基线负断言（worktree 内全绿）**：`grep -c audit-gate` attest-plan.sh=0 / SKILL.md=0 / critical-rules.md=0；`check-plan-audit-gate.sh`/`selftest-plan-audit-gate.sh` 缺席（ls No such file）；selftest-registry.tsv audit-gate 行=0。
- **插入锚点（唯一权威位）**：window-lint 块=`attest-plan.sh:540-560`（wcl 调用+warn 输出，fi 止于 :560）；`hash="$(sha256sum "$plan_file" | awk '{print $1}')"`=:561 → **[audit-gate] 门插在 :560 与 :561 之间**（四门后/写锁前，被固化内容与警报一一对应语义保持）。
- **缓存键 `_attest_cksum`（:88）现组成**：printf 13 项=`_attest_hash|skip_dispatch|skip_template|skip_fmea|skip_vc|TEMPLATE_GATE_ENFORCE|FMEA_ENFORCE|VC_ENFORCE|VC_NONVACUOUS_ENFORCE|RVC_COVERAGE_ENFORCE|STEP_PLACEHOLDER_ENFORCE|TIER_CONSISTENCY_ENFORCE|GOAL_CJK_ENFORCE` → **三项预留位**：`skip_audit`（--skip-audit-check argv）+`AUDIT_GATE_ENFORCE`（env）+`$(sha256sum progress.md)`（progress 哈希）并入 printf 列表尾部。
- **档位判定对齐范式**：`check-tier-consistency.sh:60-63` 行首锚定 `grep -m1 -E '^plan_tier:'`+精确 token LANE 解析（`grep -oE 'L[012]([_-][A-Za-z0-9]+)*'`；无声明=LANE 空=SKIP fail-open）——新 checker lane 优先判定照此。
- skip 旗标现存形态：argv 逃生（如 `--skip-fmea` 类）设 skip_* 变量入 cksum——`--skip-audit-check` 同型新增。

### S2 selftest 范式与 registry 契约（worktree 实测 file:line）
- **断言模板**：`selftest-vc-nonvacuous.sh:34-38` `PASS=0; FAIL=0` + `ok()/bad()` 计数函数（`VNC-N PASS/FAIL` 前缀范式）+ `make_fix()` fixture 构造器（:40+ mktemp 风格目录）。
- **registry 契约**：4 列 tab 分隔（脚本名↔描述↔触发条件↔级联文件 `;` 分隔清单）；当前 101 行（100 数据+1 header）；新行=selftest-plan-audit-gate.sh 描述+触发（checker/attest/selftest 变更）+级联（scripts/check-plan-audit-gate.sh;scripts/attest-plan.sh;SKILL.md;references/critical-rules.md;scripts/selftest-registry.tsv）。
- **自动发现**：`run-selftests.sh:113` `for script in "$SCRIPT_DIR"/selftest-*.sh` glob——新 selftest 命名即被聚合；T02（selftest-registry.sh）要求每个 selftest-*.sh 已登记 registry。

## Design Decisions — Phase 2 设计定稿（2026-11-17 主进程 25.3②，审计 R1-R8 迭代终态整合；Phase 3 执行体以此为准）

### D1 [audit-gate] checker 规格定稿（check-plan-audit-gate.sh，新建于 worktree scripts/）
- 签名：`bash check-plan-audit-gate.sh <plan-dir>`；输出前缀 `[audit-gate]`。
- 入口判定：plan_dir 或 task_plan.md 缺失 → rc=2 + `[audit-gate] WARN 判定器输入异常`（fail-open）；progress.md **缺失/不可读** → rc=2 同上；**存在但空=无留痕 rc1**（R7 Q-2 分层）。
- lane 判定（对齐 check-tier-consistency.sh:60-63 范式）：行首 `^plan_tier:`/`^execution_lane:` 抽取；**L1/L2 必审**；**mini×L1 并存按最严=必审**；mini/L0/trivial 单独 → rc0（输出跳过提示行）；**无声明 → 输出 `[audit-gate] SKIP legacy-no-decl` rc0**（存量迁移：9 无声明+7 个 standard/L1 无留痕在途；存量不重锁+首版 warn 起步）。
- skip 判定：task_plan.md 含 `[plan-audit-skip]` → 轻量档 rc0 放行 / **L1+ 仍 rc1 拒锁**（自声明旁路封堵）。
- APPROVED 末段聚合：awk 取最后一个 `^## \[plan-audit-R[0-9]+\] ` 段，**buf 止于下一个 `^## `（H2）行**（含修复轮块/留痕占位；后随块必须 H2——H3/粗体则静默退化，脚本注释登记该前提）；结论判定=ERE 行首锚定 `^- 轮次: R[0-9]+ \| 审计体: .+ \| 结论: \*\*APPROVED\*\*`（禁匹配反引号内/行中元引用）；最小形态三 token：`审计体:`+`轮次:`（段内子串即可，不要求独立行）+`问题清单`（**容忍全角/半角括注后接冒号**：`^- 问题清单([（(][^）)]*[）)])?:`——真实段形态 `- 问题清单（留档，不阻断）:`）。末段无锚定 APPROVED（含 REJECTED/无留痕/形态残缺）→ rc1。
- rc 契约：0=放行；1=拒锁（输出 `[audit-gate] FAIL: <原因>`）；2=输入异常 fail-open+WARN。

### D2 attest 接线规格定稿（attest-plan.sh 修改）
- 插入点：window-lint 块 fi（:560）之后、`hash=`（:561）之前——新段调用 checker：`ag_out=$(bash "$SCRIPT_DIR/check-plan-audit-gate.sh" "$plan_dir" 2>&1)`+ag_rc 捕获。
- enforce 阶梯（env-only `TASK_PLANNER_AUDIT_GATE_ENFORCE`，零新 config 键）：**enforce=rc1 拒锁**（echo 警告行 exit 1 不写锁）；**warn=警告行留痕不拒锁**（**默认档**，首版起步——存量 standard/L1 无留痕计划不被立即锁死）；**off=输出 skip 行**跳过。
- argv 逃生：`--skip-audit-check` 同型 --skip-dispatch-check（:26-45 范式）：变量 `skip_audit`、参数解析、`[attest] [audit-gate] WARN: 已显式跳过审计门（--skip-audit-check）——交付须披露` 行；**任何档位均可跳过但必留 WARN+披露**（L1+ 唯一逃生）。
- 缓存键（:88 printf 尾部追加三项）：`...|${skip_audit:-}|${TASK_PLANNER_AUDIT_GATE_ENFORCE:-}|$(sha256sum "$plan_dir/progress.md" 2>/dev/null | cut -d' ' -f1)`——APPROVED 追加/档位翻转/skip 翻转均失效缓存；缓存回放 WARN 同步提及 audit-gate。

### D3 selftest 断言清单定稿（selftest-plan-audit-gate.sh，新建；run-selftests.sh glob 自动发现；registry 新行四列）
- 静态：脚本 bash -n；registry 已登记。
- 行为断言（mock/真脚本混合，fixture 全 /tmp+trap，正负例独立 task_plan 内容或每例清 /tmp/attest-cache-*）：
  ①规范示意 APPROVED 通过（`- 问题清单: 无`）rc0；②**真实生产形态 APPROVED 通过（R6 段字节形态：`- 问题清单（留档，不阻断）:`）rc0**；③无留痕 L1+ 拒锁 rc1；④无声明→rc0+输出含 `SKIP legacy-no-decl`；⑤轻量档 skip 放行 rc0；⑥L1+ skip 拒锁 rc1；⑦mini 跳过 rc0；⑧mini×L1 冲突必审 rc1；⑨APPROVED 形态残缺 FAIL rc1；⑩中间态假阳性（REJECTED 段+后随含反引号 APPROVED 元引用修复轮块）rc1；⑪仅锚定假 PASS 路径（fixture a：段内裸文 APPROVED 意见文本）rc1；⑫仅边界假 PASS 路径（fixture b：后随 H2 块锚定 APPROVED 行）rc1；⑬rc2=删除 progress.md 文件（非清空）+WARN；⑭缓存隔离（enforce→off→enforce 不复用）；⑮attest 行为断言（enforce 下无留痕拒锁不写锁文件+APPROVED 放行写锁+audit-gate 字样出现）。
- Total 行格式与 selftest-vc-nonvacuous.sh 一致；exit 0。

### D4 109.8 条款草案（Phase 4 落刀 critical-rules.md :212 后、Why 段前；109.7 逐字保留；`^### 109 ` 计数=1 保持）
「- **109.8 机器强门（已授权范围，2026-11-16 用户授权）**：计划审计门的机器面由 `scripts/check-plan-audit-gate.sh`（独立判定器）+ `attest-plan.sh` `[audit-gate]` 接线 + `scripts/selftest-plan-audit-gate.sh` 承载：lane 判定行首声明（L1/L2 必审、mini×L1 按最严、无声明 `SKIP legacy-no-decl` 放行并登记存量迁移）；`[plan-audit-skip]` 仅轻量档放行、L1+ 唯一逃生=attest `--skip-audit-check`（WARN+交付披露）；APPROVED 末段聚合边界止 H2+结论行行首锚定+最小形态（问题清单容忍括注）；rc 0/1/2（2=输入异常 fail-open+WARN；progress 缺失/不可读=rc2、存在但空=rc1）；enforce 档 env `TASK_PLANNER_AUDIT_GATE_ENFORCE`（enforce/warn/off，默认 warn 首版起步，零新 config 键）；skip_audit/AUDIT_GATE_ENFORCE/sha256(progress.md) 三项必入 `_attest_cksum` 缓存键。本条仅登记上述已授权机器面，不扩其他机器面（109.7 文本优先铁律继续适用）。」

### D5 SKILL.md 机器面一行草案（Phase 4 追加在 :68-77 审计门区块末行）
「机器门（attest 锁定前自动）：`check-plan-audit-gate.sh` 判定审计留痕（`[audit-gate]` 行）；`TASK_PLANNER_AUDIT_GATE_ENFORCE=enforce` 时未审计计划拒锁（默认 warn 留痕）；`--skip-audit-check` 仅 L1+ 逃生（WARN+披露）；mini/L0 跳过；selftest=`selftest-plan-audit-gate.sh`。」

### D6 缓存键三项+插入锚点（S1 实测锚）
插入=:560（window-lint fi）与 :561（hash=）之间；cksum printf 尾部追加 `${skip_audit:-}|${TASK_PLANNER_AUDIT_GATE_ENFORCE:-}|$(sha256sum "$plan_dir/progress.md" 2>/dev/null | cut -d' ' -f1)`。
