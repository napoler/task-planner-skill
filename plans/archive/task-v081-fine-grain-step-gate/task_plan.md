<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务续用）; 本轮 task-v081 实例化 -->

# Task Plan: task-v081 步骤枚举门控（拆分子代理粒度防线补维）

## Goal
落地「单次派发步骤枚举数上限」门控维度（step_max_steps 默认 4）：config 新键 + check-dispatch.sh fine_grain_checks 第④项（enforce 档硬阻断）+ check-plan-dispatch.sh 第三 advisory 维 + Rule 21.1b/22.4/22.6 条款增量 + SKILL/模板联动 + selftest-fine-grain-steps 守护，全量 selftest 0 FAIL 后合并回 master、部署 3 实体位并 push。堵住"单子代理打包 13 步"类粗粒度派发（用户 2026-09-17 实证）。

## ⚙️ 计划配置
| 键 | 值 |
|----|-----|
| template_type | rule-enhancement |
| chain_mode | single |
| interaction_mode | silent（自主环境+用户显式指令在案+v079 先例；交付报告附静默决策清单） |
| git_commit | per-phase（Rule 27，禁攒批） |
| reflect_verify | required |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | config 键 `properties.subagent.properties.step_max_steps.default`=4（integer，与 step_max_* 族同型） | jq 实查 | `skills/task-planner/config.json` |
| VC-2 | enforce 档 13 步枚举 fixture prompt → check-dispatch.sh exit 2 且输出含「步骤枚举超限」 | fixture 实跑 | progress.md Selftest Log |
| VC-3 | 4 步枚举 fixture → exit 0；warn 档 13 步 → exit 0 且告警落盘 | fixture 实跑 | 同上 |
| VC-4 | 任务书双条件豁免场景：prompt 引用任务书+subagent-state/ 且任务书文件含 13 步枚举 → exit 2（防绕门） | fixture 实跑 | 同上 |
| VC-5 | check-plan-dispatch.sh：S-unit 目标单元格含 5+ 步枚举 → SKIPPED 提示行；1-2 步对照行无提示 | fixture 实跑 | 同上 |
| VC-6 | 条款增量在位（critical-rules.md 21.1b/22.4/22.6 + SKILL.md 两处 + templates/subagent_dispatch.md 一行）；git diff 对照 P1 基线证实纯增量零删除 | Read + git diff --stat | findings.md/progress.md |
| VC-7 | worktree 全量 selftest 0 FAIL 且合并后 master 全量 0 FAIL（总数=主进程逐 Total 行求和，禁采信子代理自报） | for f in selftest-*.sh 求和 | progress.md Selftest Log |
| VC-8 | 3 实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）diff -r IDENTICAL | 主进程 diff -r 亲验 | 终验输出 |
| VC-9 | CHANGELOG 条目在位；行数断言与 SKILL.md 实测行数自洽（净增>0 则两处断言同步扩围） | Read + selftest 实跑 | CHANGELOG.md |
| VC-10 | origin/master=local push 完成；worktree/分支已清理 | git log/ls 实查 | git 输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 配置 | `config.json`（subagent.properties 追加 step_max_steps） | 动既有键 |
| 派发守卫 | `scripts/check-dispatch.sh`（fine_grain_checks 增④+头注释） | 其他函数/串行槽逻辑 |
| 计划门控 | `scripts/check-plan-dispatch.sh`（增第三 advisory 维+头注释） | 既有两维语义 |
| 条款 | `references/critical-rules.md`（21.1b 句尾/22.4/22.6 增量） | 改既有规则语义 |
| SKILL | `SKILL.md`（并入现有行优先，净增 ≤2 行） | 大段新增 |
| 模板 | `templates/subagent_dispatch.md`（补一行约束） | 其他模板 |
| selftest | 新建 `scripts/selftest-fine-grain-steps.sh`；条件扩围 selftest-skill-collab.sh:81 与 selftest-execution-stability.sh:72 | 其他 selftest |
| 文档 | 仓库根 `CHANGELOG.md` 追加条目 | 其他文档 |

**强制约束**:
- 本任务**不新增 Rule 编号、不动 "Rules 1-N" 字样** → 无锚定级联；行数断言仅两处（skill-collab:81 / execution-stability:72），净增>0 才同步
- Rule 36 合规：纯增量（36.5），P1 建删除基线快照，终验 git diff 对照证实零删除零语义改写（C24）
- 派发契约：prompt 必含计划三文件绝对路径 + status:/acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）
- plans/task-v080-web-research-routing/ 属他任务（本会话早前运行），全程禁碰

## 📊 FMEA 预演

| # | Phase | 失败模式 | 严重度 | 发生度 | 检出度 | RPN | 预设兜底动作 |
|---|-------|---------|--------|--------|--------|-----|--------------|
| R-1 | P2/P4 | 新门控正则误伤/失配 → 既有 selftest 回归 FAIL | 7 | 4 | 4 | 112 | 对照 349/0 基线二分定位，fix ≤3 轮；仍 FAIL → 反思循环+PARTIAL |
| R-2 | P2 | 步骤枚举正则误伤合法短 prompt（如 5 步紧耦合原子链） | 6 | 4 | 3 | 72 | 默认 4 宽上限+config 可调；SKIPPED 显式化逃生；warn 档观察 |
| R-3 | P2/P3 | haiku-1 档位同样环境不可启动 | 6 | 5 | 2 | 60 | Rule 22.3④ 主进程逐文件接管（≤300 行/文件，25.3⑤ 登记，WHITELIST-EXEMPT 口径） |

## 🔀 隔离决策
| 项 | 值 |
|----|-----|
| isolation | worktree（默认首选：本仓为运行中基础设施，§六/§十一 保护区） |
| worktree 路径 | /mnt/data/dev/task-planner-skill-worktrees/task-v081-fine-grain-step-gate |
| 分支 | wt/task-v081-fine-grain-step-gate（基于 master=f0fa427） |
| CWD 约定 | 计划文档留主仓 plans/；实现全部走 worktree 绝对路径 |

## Phases

### Phase 1: 隔离与基线 — **Status: complete**（2026-09-17 23:40，证据=progress.md P1 段+baseline/ 快照+355/0）
- **Status:** complete
- worktree 建立 + 删除基线快照（改动面 9 文件 cp 到 subagent-state/baseline/）+ SKILL.md 行数基线（**543**，34c3959 新基线）+ 全量 selftest 基线求和（**355/0**）
- **Executor:** 主进程（白名单① git 编排 + ② 计划文件 + ③ 机械验证）

### Phase 2: 机器门控实现（config 键 + 双脚本第④/第三维 + fixture 自测） — **Status: complete**（2026-09-17 23:58，commit 9174635，6/6 fixture PASS，证据=progress.md P2 段）
- **Status:** complete
- **Executor:** 主进程（Rule 22.3④ 兜底接管,白名单⑤;原路由 code-assistant(haiku-1) 因环境 reasoning-level-missing 不可启动——Decisions ⑤+Handoff 表+Error Log 在案）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S1 | config 新增 step_max_steps 键 | code-assistant(haiku-1) | skills/task-planner/config.json（step_max_* 族旁插入，default 4） | jq 实查 =4 且既有键零变动 | 5min | complete |
| S2 | check-dispatch.sh 增④步骤枚举计数+任务书防绕门+头注释④口径 | code-assistant(haiku-1) | skills/task-planner/scripts/check-dispatch.sh（fine_grain_checks 243-292，④插③后） | fixture:13步 exit2/4步 exit0/缺键回退 SKIPPED | 15min | complete |
| S3 | check-plan-dispatch.sh 增第三 advisory 维+头注释 | code-assistant(haiku-1) | skills/task-planner/scripts/check-plan-dispatch.sh（awk 数据行块 161-190） | fixture:5+枚举行出 SKIPPED，对照行无 | 10min | complete |
| S4 | 四类 fixture 实跑取证（enforce/warn/豁免/回退） | code-runner-agent(mini) | plans/task-v081-fine-grain-step-gate/subagent-state/fixtures/ | 四条输出与 VC-2/3/4/5 一致 | 10min | complete |

### Phase 3: 条款与模板文本（D4/D5/D6） — **Status: complete**（2026-09-18 00:0x，commit ff1f6a5，纯增量零删除实证，证据=progress.md P3 段）
- **Status:** complete
- **Executor:** 主进程（Rule 22.3④ 兜底接管,白名单⑤;原路由 code-assistant(haiku-1) 环境不可启动,Decisions ⑤）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S5 | critical-rules.md 21.1b/22.4/22.6 步骤枚举增量 | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md（114/127/132 行锚） | grep 三锚点新句在位；diff 零删除 | 10min | complete |
| S6 | SKILL.md 两处并入 + subagent_dispatch.md 一行约束 | code-assistant(haiku-1) | skills/task-planner/SKILL.md（兜底节首段+Rule 21 摘要行）、skills/task-planner/templates/subagent_dispatch.md | wc -l ≤543；grep 新词在位 | 10min | complete |

### Phase 4: selftest 守护 + CHANGELOG — **Status: complete**（2026-09-18 00:1x，SG 11/0 三连跑密闭，证据=progress.md P4 段）
- **Status:** complete
- **Executor:** 主进程（Rule 22.3④ 兜底接管,白名单⑤;原路由 code-assistant(haiku-1) 环境不可启动,Decisions ⑤）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|
| S7 | 新建 selftest-fine-grain-steps.sh（fixtures+VC-2..5 断言组） | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-fine-grain-steps.sh（对齐 selftest-veto.sh 范式） | 本文件 0 FAIL | 15min | complete |
| S8 | 行数断言条件扩围 + CHANGELOG 条目 | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-skill-collab.sh、skills/task-planner/CHANGELOG.md | 净增>0 才扩围且两处同步；条目在位 | 5min | complete（扩围 N/A:净增0） |

### Phase 5: 全量回归 + Code Review — **Status: complete**（2026-09-18 00:2x，全量 366/0，CR APPROVED 证据=progress.md P5 段+CR-explore.md）
- **Status:** complete
- worktree 全量 selftest（**22 脚本 366/0**，主进程逐 Total 求和）→ Code Review Gate（Explore(mini)×2 provider server error → v064 先例+预登记路由=主进程对照 diff 逐文件复审 → **APPROVED**，1 P3 修复+3 P3 注记）→ fix 已提交
- **Executor:** 主进程（白名单③机械验证）+ code-runner-agent(mini)

### Phase 6: 合并回 + 部署 + 终验 + 簿记 — **Status: complete**（2026-09-18 00:3x，merge 38ed103 已 push，三位 diff -r IDENTICAL 亲验，master 全量 366/0）
- **Status:** complete
- smart-merge-back --deploy（主仓副本执行,V1-V6 全过,MERGED=38ed103）→ 三部署位主进程 diff -r 亲验 IDENTICAL → master 全量 22 脚本 **366/0**（'='分列求和）→ push origin/master=38ed103 → worktree+分支已清理 → check-complete → INDEX/ledger/memory/notepad
- **Executor:** 主进程（白名单①②③）

## 🎯 交付结论
- **outcome: COMPLETE**（2026-09-18,VC-1..10 全过,证据见 verification.md;merge_back=merged(38ed103);origin/master=38ed103）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type(model) | 目标/Scope | 状态 | findings 落点 | checkpoint 路径 | verify_done |
|------|---------------------|------------|------|---------------|-----------------|-------------|
| 09-17 23:26 | Explore(mini) | 管道探针+两守卫脚本行数/头注释取证 | done | findings.md Research Findings② | subagent-state/（无独立检查点,只读微任务） | ☑ |
| 09-17 23:4x | code-assistant(haiku-1) | S1 config 新增 step_max_steps 键（兼 haiku 档探针） | 派发失败→22.3④ 主进程接管完成 | findings.md Research Findings③ | subagent-state/S1-code-assistant.md | ☑ |
| 09-17 23:5x | 主进程(22.3④接管) | S2 check-dispatch ④+任务书防绕门（haiku-1 环境不可启动降级） | done | progress.md P2 Test 表 | subagent-state/fixtures/*.err | ☑ |
| 09-17 23:5x | 主进程(22.3④接管) | S3 check-plan-dispatch 第三 advisory 维（同上降级） | done | progress.md P2 Test 表 | subagent-state/fixtures/plan-a/b.md | ☑ |
| 09-17 23:5x | code-runner-agent(mini)→主进程③ | S4 fixture 六场景取证（白名单③机械验证直做） | done | progress.md P2 Test 表 | subagent-state/fixtures/ | ☑ |
| 09-18 00:0x | 主进程(22.3④接管) | S5/S6 条款+SKILL+模板行内增量（环境降级） | done | progress.md P3 | git diff ff1f6a5 | ☑ |
| 09-18 00:1x | 主进程(22.3④接管) | S7/S8 selftest 新建+CHANGELOG（环境降级） | done | progress.md P4 | SG 11/0×3 连跑 | ☑ |
| 09-18 00:2x | 主进程(白名单③,预登记路由) | CR 全量 diff 复审（Explore×2 provider server error 降级） | done | subagent-state/CR-explore.md | subagent-state/CR-explore.md | ☑ |

## Decisions Made

| # | 决策 | 依据/时间 |
|---|------|----------|
| 1 | silent: 交互模式取 silent | 自主执行环境用户不实时在线+用户显式指令在案+v079 先例（2026-09-17） |
| 2 | silent: plans/task-v080-web-research-routing/ 全程不碰不清理 | 属本会话早前运行的另一任务计划（.session-owner=本 sid），未锁定无 worktree，与本任务无关（2026-09-17 考古） |
| 3 | silent: plan-writer(sonnet-1)/general-purpose 均因 reasoning-level-missing 无法启动 → 主进程直接撰写计划（白名单②） | 两次同因失败实证；Explore(mini) 探针通过=仅 sonnet-1/继承档位不可用（2026-09-17 23:2x） |
| 4 | silent: step_max_steps 默认 4 | ≤4 步=单一主动作+紧耦合校验自然单元；枚举 ≥5 步=拆分信号；13 步反例被硬拦（2026-09-17） |
| 5 | silent: 实现路由 code-assistant(haiku-1) 优先，启动失败则 Rule 22.3④ 主进程逐文件接管（≤300 行/文件，25.3⑤ 登记，终验 WHITELIST-EXEMPT 口径） | sonnet-1 系环境性不可用（2026-09-17） |
| 6 | silent: Rule 36 纯增量声明——无功能性删除/无既有语义改写，C24 走纯新增 PASS；36.3 删除基线=P1 快照 | 设计方案天然纯增量（2026-09-17） |
| 7 | silent: 行数断言条件扩围——SKILL.md 现值 541/断言 ≤548，净增 ≤2 行则不动断言，>0 净增仍需同步两处 label | 预算充足但保持自洽（2026-09-17） |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | Rule 21.1b/22.3/22.4/22.5/22.6 现行文本 | references/critical-rules.md:114-132 | ☑ |
| 项目内部 | fine_grain_checks 现行实现（①②③+mode 分档） | scripts/check-dispatch.sh:243-292 | ☑ |
| 项目内部 | S-unit 数值门控 awk 块与列位 | scripts/check-plan-dispatch.sh:161-190 | ☑ |
| 项目内部 | selftest 范式与行数断言两处 | scripts/selftest-veto.sh、selftest-skill-collab.sh:80-81、selftest-execution-stability.sh:70-72 | ☑ |
| 项目内部 | 派发 8 字段字面契约 | templates/subagent_dispatch.md §7 | ☑ |
