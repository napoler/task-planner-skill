---
template_type: rule-enhancement
cost_estimate:
  main_process_opus: 1
  subagent_calls:
    code-runner-agent: 3
    executor: 5
  estimated_opus_equivalent: 2.17
  estimated_savings_vs_naive: 0.65
deferred-from: task-v076
---

# Task Plan: v076 交付登记 4 项 deferred-fix 修复 + 守护扩展 + 回归部署

## Goal
修复 v076 登记的 4 个问题（smart-merge-back 部署源/对账基准改为主仓 DEPLOY_SRC、README/batch-gate Rules 1-27→1-35、plan-writer+task_plan 模板补 S-unit 纯数字 ID 契约、subagent_dispatch+critical-rules 补统计类禁自报汇总）+ CD selftest 扩展断言锁契约，全量 selftest 0 FAIL 后合并 master 并从主仓副本执行 smart-merge-back 部署 3 实体位再 push。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | 不声明（按计划参数；改动含 .sh 脚本，终验阶段人工 Read 复核 S3/S4 核心 diff） |
| `session_id` | `<uuid>` | 启动时生成,注册表追踪 |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes` | §十一 隔离决策已有字段 |
| `scope_files` | 9 文件 + CHANGELOG（见执行范围限制） | 并发检测基础 |
| `interaction_mode` | `silent` | 登记依据：自治会话 + v074/v075/v076 先例（Decisions ①） |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | smart-merge-back.sh 部署源与对账基准换为 `$MAIN_REPO/skills/task-planner`：L498 cp 与 L524 diff 两处换用 DEPLOY_SRC 变量；DEPLOY_SRC 源缺失→显式 DRIFT fail-closed 禁回退 SKILL_ROOT；头注释 L15/L41/L81 与 L538 尾注同步 | `grep -c 'DEPLOY_SRC' skills/task-planner/scripts/smart-merge-back.sh` ≥3 + Read 复核 L498/L524 | `skills/task-planner/scripts/smart-merge-back.sh` |
| VC-2 | selftest-smart-merge.sh 新增 SM-14（脚本副本放入陈旧部署位运行，断言槽位终态内容==主仓内容）PASS 且既有 SM-01..13 全 PASS | 实跑 `bash scripts/selftest-smart-merge.sh` 逐 SM 行观察 PASS + Total 行 0 FAIL | worktree 内 selftest-smart-merge.sh 输出 |
| VC-3 | README.md:67 与 batch-quality-gate.md:130 两处 `Rules 1-27`→`Rules 1-35`，且全仓活跃文件（排除 plans/）`grep -rn 'Rules 1-2[0-9]'` 命中 =0 | 全仓 grep 计数 + Read 两处行 | `skills/task-planner/README.md` / `references/batch-quality-gate.md` |
| VC-4 | 四契约点就位：plan-writer.md L116 后新表行（S-unit ID=纯数字，禁 S2a 字母后缀）/ templates/task_plan.md L184 区补 ④ 同义注释 / subagent_dispatch.md L54 后禁自报汇总子句 / critical-rules.md L129 22.4b 行内子句；且 selftest-conclusion-discipline.sh 新增 CD-18..CD-23 六断言全 PASS + 头注释 L4-15 清单与 L17 计数（17→23）同步 | 四锚点 Read 复核 + 实跑 CD selftest 观察 CD-18..23 PASS + Total 行 | `companion/agents/plan-writer.md` / `templates/task_plan.md` / `templates/subagent_dispatch.md` / `references/critical-rules.md` / `scripts/selftest-conclusion-discipline.sh` |
| VC-5 | 全量 20 脚本逐 Total awk 求和 0 FAIL（主进程机械求和，禁采信子代理自报）+ merge master + 3 部署位 diff=0（必须从主仓副本执行 smart-merge-back；.zcode 位若 REJECTED 则手动 rm+cp 补齐）+ push origin | 主进程 `for f in selftest-*.sh` 逐脚本 Total 行求和 + `smart-merge-back.sh --deploy` 输出 + `git log` 复验 merge commit | worktree/主仓 各 selftest 输出、部署输出、`git log` |

**终验规则**：全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED。

## ⚠️ 执行范围限制（强制 - 只操作列表内的文件）

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 脚本 | `skills/task-planner/scripts/smart-merge-back.sh`、`skills/task-planner/scripts/selftest-smart-merge.sh`、`skills/task-planner/scripts/selftest-conclusion-discipline.sh` | 其他脚本（含 verify.sh/lib） |
| 文档 | `skills/task-planner/README.md`、`skills/task-planner/references/batch-quality-gate.md`、`skills/task-planner/companion/agents/plan-writer.md`、`skills/task-planner/templates/task_plan.md`、`skills/task-planner/templates/subagent_dispatch.md`、`skills/task-planner/references/critical-rules.md` | 其他 references/文档 |
| 簿记 | `CHANGELOG.md`（[Unreleased] 新增一条，样式照既有） | 其他 |
| 配置 | 无 | `SKILL.md`、`config.json`（零新键、不加 env 覆盖键）、`lib/`、plans/ 之外文件 |

**强制约束**：
- selftest 只增不减（SM-01..13 与 CD-01..17 既有断言不得删改语义；SM-06 预置源语义按 L209 锚同步修改属修复非破坏）
- 主仓工作树零写入：所有 S3-S8 写入发生在 worktree 内；主仓只经 merge + 部署位同步
- 部署必须从主仓副本执行（本任务修复的正是「从部署位运行脚本」的假 IDENTICAL 根因）

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/commit） | 必读级别 | 已确认 |
|------|-----------|---------------------|---------|--------|
| 项目内部 | 锚点考古（01-explore-v077 全锚点表 + 5 设计裁决） | `plans/task-v077-deferred-fixes/subagent-state/01-explore-v077.md`（基于 master@5ad18f6） | 必读 | ☑ |
| 项目内部 | 根因与需求拆解 | `plans/task-v077-deferred-fixes/findings.md`（Research Findings 段） | 必读 | ☑ |
| 项目内部 | 计划骨架范式 | `skills/task-planner/templates/variant/rule-enhancement-type.md` | 必读 | ☑ |
| 项目内部 | 知识底座 | `plans/task-v077-deferred-fixes/knowledge-brief.md`（本任务 §1-§5） | 必读 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 从部署位运行 smart-merge-back.sh 时 SKILL_ROOT=部署位自身，导致重部署/对账以陈旧副本为源/基准 → 假 IDENTICAL（sm-rc 被管道吞掉的假象）；同时 3 处契约（Rules 1-35 字样、S-unit 纯数字 ID、统计类禁自报汇总）无守护 → 漂移。

**核心问题判断**:
- [x] 核心问题解决后，结果能交付吗？（能：4 修复 + 守护 + 回归 + 部署 push 闭环）
- [x] 核心问题不解决，其他工作都白费吗？（是：部署机制本身失真，后续部署全部不可信）
- [x] 核心问题的解决方法是清晰的、可执行的？（是：设计裁决 1-5 已定，锚点已实核）

## Current Phase
Phase 1

## Next Step
P1：主进程建 worktree（自 master@5ad18f6 新建分支 wt/task-v077-deferred-fixes）并派 code-runner-agent 跑 20 脚本全量基线（预期 330/0）逐 Total 行落盘检查点。

## Phases

### Phase 1: 隔离与基线
- [x] 建 worktree（8d62d3b=当前 master HEAD，分支 wt/task-v077-deferred-fixes）
- [x] 20 脚本全量基线（主进程 awk 求和 330/0，证据 subagent-state/p1-baseline.md）
- [x] 锚点实核（01-explore 表在 v076 交付后 master 无 skills/ 变更，行号有效——P2 各 S-unit 前置 Read 再核）
- **V-N:** VC-5, VC-1（基线为回归对照；锚实核为 S3 前置）
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排白名单）+ code-runner-agent（基线跑测，白名单③ 机械求和）

<!-- S-unit 派发单元表（Rule 22.6；ID 全局纯数字 S1..S11 禁字母后缀——本计划 dogfood 该契约） -->
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S1 | 建 worktree 并确认基线 commit | 主进程 | 01-explore-v077.md（L3 基于 master 锚 + 本计划隔离决策行 worktree_path/branch） | `git -C <worktree> log -1` 显示 8d62d3b 且主仓 `git status` 干净 | 5min | done |
| S2 | 全量 20 脚本基线跑测逐 Total 落盘 | code-runner-agent(mini) | knowledge-brief.md（§5 S2 材料包：fixture 注意 L21/263-268 + 逐 Total 求和指令 5 行摘要） | 逐脚本 Total 行原样落盘 `<plan-dir>/subagent-state/p1-baseline.md`，主进程求和=330/0 | 15min | done |

### Phase 2: 修复实现（VC-1..VC-4 全部写入）
- [x] S3 smart-merge-back.sh 部署源修复（VC-1；证据 commit 496b8b0 + 主进程复核冒烟三条）
- [x] S4 selftest-smart-merge.sh fixture 扩展 + SM-14 陈旧副本回归用例（VC-2；主进程复跑 15/15）
- [x] S5 README.md:67 与 batch-quality-gate.md:130 两处 Rules 1-27→1-35（VC-3；全扫 0 残留）
- [x] S6 plan-writer.md L116 后新表行 + templates/task_plan.md L184 区补 ④（VC-4 契约点 ①②）
- [x] S7 subagent_dispatch.md L54 后禁自报汇总 + critical-rules.md L129 22.4b 行内子句（VC-4 契约点 ③④）
- **V-N:** VC-1, VC-2, VC-3, VC-4
- **Status:** complete
- **Executor:** executor（sonnet-1），严格串行派发（S3→S4 有 fixture 依赖，禁并行）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S3 | smart-merge-back.sh 换 DEPLOY_SRC + fail-closed + 头尾注释同步 | 继承 | 01-explore-v077.md（§A 锚点表 9 行 + §I IDENTICAL 语义 5 文档点 + 设计裁决 1/2/3 共 ≤10 行摘要） | `grep -c DEPLOY_SRC` ≥3；L498 cp 与 L524 diff 均引用 $DEPLOY_SRC；源缺失分支 echo DRIFT + exit 6 不回退；自位 REJECTED 消息含「请改用主仓副本运行或手动 rm+cp 部署该位」；L15/L41/L81/L538 同步 | 15min | pending |
| S4 | selftest fixture 扩展 + SM-06 L209 语义同步 + 新增 SM-14 陈旧副本用例 | 继承 | 01-explore-v077.md（§B fixture L63-85 / SM-06 L198-220⚠️L209 独立定义 / 样板 SM-07 L222-230 / run L114 / report L121 / Total L413·415 共 ≤10 行摘要） | mk_fixture 建 `$repo/skills/task-planner` 内容标记；SM-06 自测侧 SKILL_ROOT 改指主仓 fixture 路径；SM-14 断言槽位终态==主仓内容；SM-01..14 实跑全 PASS，头注释用例清单 +1 | 15min | pending |
| S5 | 两处 Rules 1-27→Rules 1-35（括注自拟，如「1-12 核心执行约束 + 13-35 P0/P1 扩展门控与学习闭环」） | 继承 | knowledge-brief.md（§3 锚点表 README.md:67 与 batch-quality-gate.md:130 两行 ≤10 行摘要） | 两行改为 1-35；全仓（排除 plans/）`grep -rn 'Rules 1-2[0-9]'` 计数=0 | 5min | pending |
| S6 | plan-writer.md L116 后新表行 + task_plan 模板 L184 区补 ④ | 继承 | 01-explore-v077.md（§D L106-116 契约表 / L111 S-unit 行 / 插入点 L116 后；§E L182-187 注释块 ①②③、表头 L188 共 ≤10 行摘要） | plan-writer.md 新表行含「S-unit ID=纯数字（S1/S2…禁 S2a 字母后缀——check-plan-dispatch.sh 数据行正则 `^\|\s*S[0-9]+\s*\|` 不认，attest 拒锁教训）」；模板 L184 区 ④ 同义注释就位 | 5min | pending |
| S7 | subagent_dispatch.md L54 后追加统计类禁自报汇总 + critical-rules.md L129 22.4b 行内同义子句 | 继承 | 01-explore-v077.md（§F §7 L51-73 / acceptance 行 L54 / 插入点 L54 后；§G L129 行内锚 `acceptance:` 之后 共 ≤10 行摘要） | L54 后追加「统计/测试类：acceptance 只准贴逐项原文行（如各脚本 Total: 行），禁止自报汇总数字——汇总由主进程机械求和」；L129 行内括注后插入同义子句 | 5min | pending |

### Phase 3: 守护扩展（CD selftest 锁 VC-4 契约）
- [x] selftest-conclusion-discipline.sh 变量区扩展 + CD-18..23 六断言 + 头注释/计数 17→23 同步（worktree 提交）
- [x] 实跑 CD selftest：23 PASS/0 FAIL（主进程一手复跑，CD-18..23 逐行核过）
- **V-N:** VC-4, VC-5
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S8 | CD selftest 变量区扩展 + CD-18..23 六断言 + 头注释/计数同步 | 继承 | 01-explore-v077.md（§H 变量区 L21-26（L22 SKILL/L23 RULES/L24 DISPATCH/L25 TMPL/L26 NOTEPAD_TPL）/ CD-17=L60-61 / 插入点 L61 后 / Total L63 / 头注释 L4-15+L17 共 ≤10 行摘要） | 六断言对应 VC-4 清单：README 1-35 锚 / batch-gate 1-35 锚 / plan-writer 纯数字 ID 锚 / 模板 ④ 锚 / dispatch 禁自报锚 / smart-merge DEPLOY_SRC 存在锚（锚用行内容 grep 非裸行号）；CD-01..23 全 PASS，L17 计数 17→23，头注释 L4-15 清单 +6 行 | 15min | pending |

### Phase 4: 全量回归 + 文档簿记
- [x] S9 全量 20 脚本回归逐 Total 求和（主进程 awk=337 PASS/0 FAIL=330+CD6+SM14，证据 p4-regression.md）
- [x] S10 CHANGELOG.md [Unreleased] 新增一条（主仓，task-v077 条目）
- **V-N:** VC-5, VC-4
- **Status:** complete
- **Executor:** code-runner-agent（S9 回归跑测）+ 主进程（例外理由:白名单③ 机械求和定数 + 白名单② CHANGELOG 簿记）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S9 | 全量 20 脚本回归跑测逐 Total 落盘 | code-runner-agent(mini) | knowledge-brief.md（§5 S9 材料包：同 S2 求和方法 + 预期 336/0 提示、以实跑为准 ≤5 行摘要） | 逐脚本 Total 行原样落盘 `<plan-dir>/subagent-state/p4-regression.md`；主进程 awk 求和 0 FAIL | 15min | pending |
| S10 | CHANGELOG.md [Unreleased] 追加本任务条目 | 主进程 | `CHANGELOG.md`（[Unreleased] 段头部 ≤10 行既有样式摘要） | 新条目含 4 修复点 + 守护扩展 + 回归定数；`git diff CHANGELOG.md` 仅 +N 行 | 3min | pending |

### Phase 5: 合并回 + 部署 + 簿记
- [x] S11：主仓副本执行 smart-merge-back --deploy → merge commit 6a37279（V1-V6 全过）；三位 IDENTICAL + sm-rc=0（修复后 .zcode 位不再 REJECTED）；主进程 diff -r 亲验三位=0
- [x] worktree remove + branch -d 清零；push origin（5ad18f6..6a37279）
- [x] 簿记：merge_back 回写、INDEX/ledger/verification（本批）
- **V-N:** VC-5, VC-1
- **Status:** complete
- **Executor:** 主进程（例外理由:① git 编排 + ③ 部署/push 白名单）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|------------------------|-------------|---------|------|------|
| S11 | merge + 主仓副本执行 smart-merge-back 部署 + 清理 + push + 簿记回写 | 主进程 | 本计划隔离决策行（worktree_path/branch/merge_back）+ 11.3 合并回合约 6 条 ≤10 行摘要 | merge commit 入 master；3 位 diff=0；worktree/分支清理完成；push 记录；plan `merge_back=merged(6a37279)` 回写 | 15min | done |

## 🔀 隔离决策（冲突分析 — 实现类默认首选 worktree）
| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`（主仓干净：5ad18f6，v076 簿记已提交；无与任务范围重叠的未提交变更） |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v077-deferred-fixes` |
| `branch` | `wt/task-v077-deferred-fixes`（自 master 新建） |
| `merge_back` | `merged(6a37279)` 2026-09-17 |

> 契约详见 `references/worktree-isolation.md` §3（集中目录命名 `<repo-parent>/<repo>-worktrees/<task-id>`）。

## 📊 FMEA 预演（规划期）

| Phase | 失败模式 | S(1-10) | O(1-10) | D(1-10) | RPN=S×O×D | 预设兜底动作（RPN>100 必填，对齐 22.3 ①-⑤） |
|-------|---------|---------|---------|---------|-----------|---------------------------------------------|
| P2/S4 | SM fixture 改动致既有用例崩 | 6 | 3 | 4 | 72 | （RPN≤100；预防：改前先跑 SM 基线 + 逐用例对照，FAIL 则 S4 单步重做，不升档） |
| P2/S3 | 非标准仓布局 `$MAIN_REPO/skills/task-planner` 缺失 | 8 | 2 | 4 | 64 | （RPN≤100；设计已 fail-closed：源缺失→显式 DRIFT exit 6 不回退，SM-14 自测覆盖该分支） |
| P3/S8 | CD 断言锚漂移（行号随插入上移） | 4 | 5 | 5 | 100 | （RPN=100 临界；锚用行内容 grep 非裸行号，插入点固定在 L61 后；FAIL 则回 S8 按新行内容重锚，≤2 轮） |
| P5/S11 | .zcode 部署位自保护 REJECTED 致 3 位 diff≠0 | 5 | 6 | 4 | 120 | 主进程接管（22.3 ⑤ 档）：手动 `rm -rf` 该位内容 + `cp -rL` 主仓 `skills/task-planner` 补齐，再 diff 复验=0；仍 FAIL→AskUserQuestion |
| P4/S9 | 全量回归出意外 FAIL（脚本间耦合） | 7 | 2 | 5 | 70 | （RPN≤100；逐 Total 定位 FAIL 脚本，单点重跑对照 P1 基线） |

## 🔁 原生 Todo 同步（S1–S5 强制）
| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 隔离+基线 |
| Phase 2 | ☐ |  | 5 S-unit 串行 |
| Phase 3 | ☐ |  | CD 守护扩展 |
| Phase 4 | ☑ | 2026-09-17 | P4 complete 同步 |
| Phase 5 | ☑ | 2026-09-17 | P5 complete 同步 |

## Key Questions
1. SM-14 的「陈旧部署位」fixture 如何构造：mk_fixture 内预置一个与主仓内容不同的陈旧副本位，脚本运行后断言终态==主仓——需验证该 fixture 不误伤 SM-06 L209 独立定义语义（执行期 S4 逐用例对照确认）。
2. CD-18..23 六断言的锚行内容（grep 目标串）由 S8 实读 S3/S5/S6/S7 落盘后文件确定，计划期只锁清单不锁串。
3. .zcode 位自保护触发时的手动 rm+cp 边界：仅动 `~/.zcode/skills/task-planner/` 内容，不动 `cli/config.json` 等保护区他件（§六）。

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| ① `interaction_mode: silent` | 登记依据：自治会话 + v074/v075/v076 三轮先例均 silent |
| ② config.json 零新键、不加 env 覆盖键；测试靠 fixture 在主仓内容内造 `skills/task-planner` | 防绕过：env 键可被部署位旧值污染，正是本次假 IDENTICAL 同类根因 |
| ③ 自位（SKILL_ROOT==slot）REJECTED 保留 + 消息追加指引「请改用主仓副本运行或手动 rm+cp 部署该位」 | bash 执行中自覆盖风险（S2 轮既有裁决），只改提示不改行为 |
| ④ 共享追踪不适用（Rule 30：无可枚举部分认领） | 本任务为单任务 4 项修复，非共享追踪场景 |
| ⑤ C20 veto 检查 PASS | 本任务方案不含用户已否决项（未查证否定结论收场 / 大输入不落盘 均未出现） |
| ⑥ S-unit ID 全局纯数字 S1..S11 禁字母后缀 | 本计划 dogfood S6 即将写入的契约；check-plan-dispatch.sh 数据行正则 `^\|\s*S[0-9]+\s*\|` 不认 S2a |
| ⑦ `code_review` 不声明 | 计划参数照填；终验以 VC-1 Read 复核 + S3/S4 diff 人工抽查替代 |

## Errors Encountered
| Error | Attempt | Resolution | Prevention（Rule 31 指针） |
|-------|---------|------------|---------------------------|
|       | 1       |            | → progress.md Error Log   |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |         |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 2 / 5（P2 executor、P3 executor；子代理派发共 7 次：Explore 1/plan-writer 1/code-runner 2/executor 3，严格串行） |
| 主进程直做 Phase 清单 | P1（白名单① git 编排+③ 基线求和）、P4-S10/求和（白名单②③）、P5（白名单①③）——stats verdict=ok violations=0 |
| 委派率 | 0.400（delegation_rate_floor 0.7，全直做理由命中 Rule 25.3 白名单 → WHITELIST-EXEMPT 放行；JSON 证据=verification.md） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | rescue(档位/结果/时间) | retry_count | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|--------------|----------------|------------------------|-------------|-------------|
| 1 |  | explore（mini） | 01-explore 锚点考古 | done | 全锚点 + 5 设计裁决已落盘 | subagent-state/01-explore-v077.md | findings.md Research Findings | subagent-state/01-explore-v077.md | - | 0 | ☑ |
| 2 | 04:27 | plan-writer | 本计划 + knowledge-brief 撰写 | done(部分恢复) | 空响应；task_plan 已完整（主进程复核），brief/检查点主进程补写 | task_plan.md 全文 | findings.md plan-writer 条 | subagent-state/02-plan-writer.md | 22.8 落盘核查,无需重派 | 0 | ☑ |
| 3 | 04:45 | code-runner-agent(mini) | P1 全量 20 脚本基线 | done | 全 rc=0；主进程 awk=330/0 | subagent-state/p1-baseline.md | progress.md P1 段 | subagent-state/p1-baseline.md | - | 0 | ☑ |
| 4 | 05:2x | executor | P2 S3-S7 串行修复（5 单元） | done | S3 换源+自纠 2 回归/S4 SM-14 钉子 15/15/S5 两行 1-35/S6+S7 契约落位；主进程逐单元复核 | 496b8b0 diff + 各 p2-s*.md | findings.md P2 条 | subagent-state/p2-s{3,4,5,6,7}.md | S6/S7 走 35.3 任务书落盘（守卫示例 ID 计打包） | 0 | ☑ |
| 5 | 05:5x | executor | P3 S8 CD 守护扩展 | done | CD-18..23 就位；23/23 主进程复跑；SM 15/15 无连带 | subagent-state/p3-s8.md + CD 输出 | progress.md P3 段 | subagent-state/p3-s8.md | 任务书落盘 p3-s8-dispatch.md | 0 | ☑ |
| 6 | 06:0x | code-runner-agent(mini) | P4 S9 全量回归 | done | 全 rc=0；主进程 awk=337/0（=330+CD6+SM14） | subagent-state/p4-regression.md | progress.md P4 段 | subagent-state/p4-regression.md | - | 0 | ☑ |
| 7 | 06:2x | 主进程(白名单①③) | P5 S11 合并+部署+push | done | 主仓副本执行；merge 6a37279；三位 IDENTICAL sm-rc=0（修复生效）；worktree 清零 | git log 6a37279 / diff -r ×3 / push 输出 | verification.md VC-5 | plans/（主进程直做） | FMEA120 兜底未触发（.zcode 未被拒） | 0 | ☑ |

## Notes
- 更新 phase 状态: pending → in_progress → complete；重大决策前重读本计划
- 统计类结论一律逐 Total 原文行落盘，主进程机械求和定数（Rule 35 纪律）
- deferred-from: task-v076；本任务完成后 v076 Deferred Items 区 4 项全部销项
