---
template_type: rule-enhancement
new_rule: none（机制修复，不新增 Rule 编号；69/70/71 已被 v154/v155/v158 占用）
interaction_mode: ask
plan_tier: standard
code_review: required
isolation: worktree
parallel_groups: [p3-core, p3-guard]
session_id: de2c5bba-v159
---

# Task Plan: task-v159 — 指针与部署生命周期根治（D1-D5 五缺陷机制修复）

## 🎯 用户需求原文（Rule 51.1）

- **R1**: 「修复上面发现的问题 并彻底解决」（承接 task-v153 delivery-summary 下一步与 pointer-lifecycle-fix.md 三缺陷判定+防复发提案，用户要求机制层根治）<sub>（[目标]）</sub>

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|-------------------------|
| R1 | VC-1..VC-5 | D1 gc 生命周期+check-complete 移交提醒（构造 stale 夹具输出清除行）/ D2 哨兵缺口巡检报告 / D3 所有权守卫拒绝夹具+set ROOT 回归 / D4 deploy 全 slot 后验 exit 语义 / 全量 selftest FAIL=0+CR APPROVED |

## 🧮 根源覆盖表（Rule 53.1 — 五缺陷全链）

| 工序 | 缺陷面（实证） | 修复点 | VC |
|------|--------------|--------|-----|
| 全局指针生命周期 | D1：v150 完成后指针残留+哈希失配→sid-less 消费者 PLAN TAMPERED（v153 会话 21:34 被咬 2 次；04:5x 已临时原子修→v152 治标） | F1 set-active-plan.sh gc 增全局生命周期（目标计划目录缺失→清；目标 Status=complete 且锁陈旧→清+报告）+check-complete.sh 尾部 warn 移交提醒（.active_plan==本任务时提示移交） | VC-1 |
| 会话指针完整性 | D2：4 活跃哨兵（181730a4/1cefd1cf/bc12ebe6/f183e5d5）无 side key→带 sid 解析 miss 落全局/mtime 串台 | F2 gc 增哨兵-side 缺口巡检（有 .plan_required 无 side 指针→列名报告，advisory 不代写，越权代写=踩踏并行会话） | VC-2 |
| side 键归属 | D3：v156/v157 owner=sesscbab959f（=v153 会话 SessionStart key，CLAUDE_CODE_SESSION_ID 进程沿袭）→私有键共享、最新写者赢；v159 init 经 sidmap 误写 cbab959f→v159（当次人工还原 v157） | F3 写入所有权守卫：set/init 写 side 键前扫 plans/*/.session-owner，该键被其他 in_progress 计划声明→**不写该键**并 WARN（或 --force 覆盖）；init 同语义 | VC-3 |
| set 参数解析 | D5：set <id> 在计划目录内运行 ROOT 落 positional[0]→PLAN_ROOT 双重要素→require_plan 误报 exit 2（v159 实测复现） | F4 set-active-plan.sh set 分支 ROOT 默认 $PWD（对齐 60 行注释语义） | VC-4 |
| 部署原子性 | D4：2026-10-10 04:45:38 claude slot 写入/04:49:07 zcode slot 被删后 deploy 中断（v152 Rule 67 合并部署期）→task-planner 技能全局停摆数分钟，主进程从仓内源原子恢复（diff 0） | F5 smart-merge-back.sh deploy 段：全 slot 先 staging→逐 slot rename-swap→部署后验（slot 缺失或 diff≠0→exit 1），禁「先删后写」裸序列 | VC-5 |

## Goal

把指针三缺陷（D1/D2/D3/D5）与部署中断窗口（D4）从治标推进到机制层：全局指针生命周期化、side 写入所有权化、哨兵缺口可巡检、set 解析修正、部署 staging 原子化，并以新 selftest 守护，全量回归零新增失败。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（bash 脚本+schema 语义改动，重 diff 全量 CR） |
| `session_id` | `de2c5bba-v159` |
| `isolation` | `worktree`（宪法 §十一：skills/** 保护区命中） |
| `interaction_mode` | `ask`（D1=批准计划；5min 超时默认项=批准） |
| `对齐审查` | `required`（SKILL 流程行+脚本注释联动） |
| `new_rule` | 无（机制修复；v158 已占 71） |
| `质量审查工具` | `code-reviewer（sonnet-1）`（42.2 环境 agents 层命中） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 |
|---|---------|---------|
| VC-1 | gc 对 stale 全局指针执行清除并输出报告；check-complete 对指针=本任务的计划输出移交提醒 | 夹具：stale 全局+跑 gc→清除行原文；跑 check-complete→提醒行原文 |
| VC-2 | gc/--show 输出哨兵-side 缺口清单（≥1 命中当前 4 缺口） | 实测输出含 4 个 sidkey 列名 |
| VC-3 | 所有权守卫：构造他计划 in_progress owner 声明→set 拒绝 trample 且**不写该键**（输出 WARN 原文，与设计稿「不写该键」口径对齐）；--force 可覆盖 | 双夹具输出原文 |
| VC-4 | set 在计划目录内运行 exit 0 且指针正确落位 | 复现原失败路径 rc=0 |
| VC-5 | deploy 段 staging 化：模拟中断后验（slot 缺失→exit 1）；正常路径三 slot 后验 OK | 单元级行为夹具（隔离 tmp 目录，不触真 slot） |
| VC-6 | 全量 selftest FAIL=0（基线零新增） | 跑批 ΣFAIL=0 |
| VC-7 | Code Reviewer APPROVED；alignment-review（主进程机械巡）通过 | CR verdict+对齐结论 |
| VC-8 | 合并后三 slot 存在性+diff 双验（D4 直接回归项） | merge 后 slot 巡检输出 |

## 🎯 Goal 单元表（Rule 66.1 六列契约）

| goal-id | 任务名 | 目标 | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|------|-------------|------------------|------|
| G1 | gc 全局生命周期 | set-active-plan.sh gc 清除 stale 全局指针+check-complete 移交提醒 | stale 夹具 gc 输出清除行原文+check-complete 提醒行原文 | S,S3/Phase 3 | complete |
| G2 | 哨兵缺口巡检 | gc 报告有哨兵无 side 指针清单 | 实测输出含 4 个现存缺口 sidkey | S/Phase 3 | complete |
| G3 | 所有权守卫 | side 键被其他在途计划声明时拒绝 trample+env 键回退+WARN | 双夹具（拒绝+--force 覆盖）输出原文 | S,S2/Phase 3 | complete |
| G4 | set 解析修正 | set 在计划目录内运行 exit 0 | 原失败路径 rc=0 原文 | S/Phase 3 | complete |
| G5 | deploy 原子化 | 全 slot staging→swap→后验，缺失 exit 1 | 隔离 tmp 目录模拟中断夹具输出 | S4/Phase 3 | complete |
| G6 | selftest 固化 | selftest-pointer-lifecycle.sh 断言全过+registry | exit 0 全 PASS+registry 行 | S5/Phase 3 | complete |
| G7 | 回归与审查 | 全量 FAIL=0+CR APPROVED+对齐 | 跑批 ΣFAIL=0+verdict 原文 | V1,V2/Phase 4 | complete |
| G8 | 合并部署验证 | 合并后三 slot 存在性+diff 双验+新会话解析演练 | slot 巡检输出+演练记录 | Phase 5 | complete |

## ⚠️ 执行范围限制

| 类别 | 允许文件 |
|------|---------|
| 脚本 | `skills/task-planner/scripts/set-active-plan.sh`、`init-session.sh`、`check-complete.sh`（仅尾部 warn）、`smart-merge-back.sh`（仅 deploy 段） |
| SKILL | `skills/task-planner/SKILL.md`（计划流程加一行移交纪律+计数级联递推） |
| selftest | `skills/task-planner/scripts/selftest-pointer-lifecycle.sh`（新建）、`scripts/selftest-registry.tsv`、`scripts/selftest-smart-merge.sh`（仅 SM-06/SM-14 断言契约随 F5 更新，B 类扩 2026-10-10 06:3x） |
| 计划 | `plans/task-v159-pointer-lifecycle/*` |

禁止：critical-rules.md、其他脚本、其他任务目录与 worktree。

## Phases

### Phase 1: 设计定稿
- [x] design-pointer-fix.md：F1-F5 逐点函数定位+行区间+夹具设计+SKILL 行落点
- **Status:** complete（2026-10-10 06:0x；design-pointer-fix.md 已落盘含 F1-F5 定点+PL-01..10）
- **Executor:** 主进程（例外理由:② 计划系统文件维护——design-pointer-fix.md 落 plans/——Rule 25.3 白名单②）

### Phase 2: worktree+基线
- [x] worktree `wt/v159-pointer-lifecycle`（从 fetch 后最新 master 创建；v152 Rule 67 或已 land，创建后 git log 复核）
- [x] 基线 selftest 跑批（脚本数/FAIL 数存证）
- **Status:** complete（2026-10-10 06:1x；worktree=merge 时 master，66/66 基线；后随合并态再验 5 轮）
- **Executor:** 主进程（例外理由:① git/worktree 编排 +③ 机械验证跑批——Rule 25.3 白名单①③）

### Phase 3: 实施（组内异构+组域写隔离）
- p3-core={S1 set-active-plan四修点; S2 init-session同语义; S3 check-complete+SKILL移交纪律}（文件集不相交，共同输入=design 稿；执行体：executor sonnet-1 + code-assistant haiku-1 混）
- p3-guard={S4 smart-merge-back deploy staging 化; S5 selftest-pointer-lifecycle+registry}（文件集不相交；executor sonnet-1 + code-assistant haiku-1 混）
- S7 串行尾：合并预检（master 实态 grep）
- **Status:** complete（2026-10-10 07:0x；S1-S5 全验收+git adfd8d7+R3/R4 69/69）
- **Executor:** 主进程（例外理由:① 派发编排（21.4 调度管理器职责）+② 计划三文件簿记——Rule 25.3 白名单①②）

<!-- S-unit 派发单元表(Rule 22.6+68;ID=S<数字>;Nf/Nl/Nmin;前置依赖必填;-=无依赖) -->
| ID | 目标(≤1句) | 执行体(subagent_type(model)) | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 并行组 | 检查点 | 状态 |
|----|-----------|------------------------------|------------------|--------------|---------|-----------|---------|---------|--------|--------|------|
| S | set-active-plan.sh 四修点：gc 全局生命周期+哨兵缺口巡检+所有权守卫+set ROOT 修正 | executor（sonnet-1） | design-pointer-fix.md F1-F4+worktree scripts/set-active-plan.sh | gc stale 夹具输出清除行；巡检清单含 sidkey；守卫拒绝/force 双夹具；set rc=0 | 15min | 1f/60l/15min | 无 | - | p3-core | subagent-state/3-executor-S1.md | complete |
| S2 | init-session.sh side 写入同语义所有权守卫 | code-assistant（haiku-1） | design-pointer-fix.md F3+worktree scripts/init-session.sh 796-802 段 | 他计划 in_progress owner 声明夹具→只写 env 键+WARN 原文 | 15min | 1f/25l/15min | 无 | - | p3-core | subagent-state/3-code-assistant-S2.md | complete |
| S3 | check-complete.sh 尾部移交提醒（warn）+SKILL.md 计划流程移交纪律一行+计数级联 | code-assistant（haiku-1） | design-pointer-fix.md F1 SKILL 落点+worktree check-complete.sh 尾部/SKILL.md | 提醒行夹具原文；grep SKILL 移交纪律行≥1；计数递推无硬编码 | 15min | 2f/20l/15min | 无 | - | p3-core | subagent-state/3-code-assistant-S3.md | complete |
| S4 | smart-merge-back.sh deploy 段 staging+swap+后验原子化 | executor（sonnet-1） | design-pointer-fix.md F5+worktree scripts/smart-merge-back.sh 590-640 段 | 隔离 tmp 中断夹具：slot 缺失 exit 1；正常路径三 slot 后验 OK | 15min | 1f/50l/15min | 无 | - | p3-guard | subagent-state/3-executor-S4.md | complete |
| S5 | 新建 selftest-pointer-lifecycle.sh（D1-D5 断言）+registry 登记 | code-assistant（haiku-1） | design-pointer-fix.md selftest 清单+worktree scripts/ | exit 0 全 PASS；registry 行+4 列 | 15min | 2f/80l/15min | 无 | S | p3-guard | subagent-state/3-code-assistant-S5.md | complete |
| S7 | 合并预检：master 实态 grep+并集预案 | 主进程 | worktree git log/diff+S1-S6 产物 | 递推写法确认+mtime 最新计划核对 | 10min | 0f/0l/10min | 无 | S-S6 | - | - | complete |

> 单元组标记（Rule 21.4+68.2）：`[parallel-group:p3-core]`=S1,S2,S3（文件集互斥：set-active-plan.sh/init-session.sh/check-complete+SKILL；四问全否）；`[parallel-group:p3-guard]`=S4,S5（文件集互斥：smart-merge-back.sh/新 selftest+registry）；S7 前置=S1-S6 串行尾。组内异构：p3-core=sonnet-1+haiku-1×2；p3-guard=sonnet-1+haiku-1。派发 prompt 必含组标记+组域写隔离（68.4）。

### Phase 4: 验证
- [x] V1 全量回归（FAIL=0）+新 selftest 8-10 断言全 PASS
- [x] V2 Code Reviewer 全量 CR（五处改点+新 selftest）
- **Status:** complete（2026-10-10 07:1x；CR3 APPROVED+R5 71/71）
- **Executor:** code-runner-agent（mini）+code-reviewer（sonnet-1）

<!-- S-unit 派发单元表(Rule 22.6；ID=S<数字>;粒度三值 Nf/Nl/Nmin;前置依赖列必填 68.1) -->
| ID | 目标(≤1句) | 执行体(subagent_type(model)) | 输入(路径+摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 前置依赖 | 并行组 | 检查点 | 状态 |
|----|-----------|------------------------------|------------------|--------------|---------|-----------|---------|---------|--------|--------|------|
| S8 | worktree 全量 selftest 回归跑批与基线对比 | code-runner-agent（mini） | worktree scripts/ 全量+baseline 日志 | 逐行 rc/Total 回贴；ΣFAIL=基线 | 15min | 2f/20l/15min | 无 | S-S6 | - | subagent-state/4-code-runner-S8.md | complete |
| S9 | Code Reviewer 全量 CR（五修点+新 selftest 重 diff） | code-reviewer（sonnet-1） | worktree diff master 全量+design-pointer-fix.md | APPROVED 或发现清单 | 15min | 2f/100l/15min | 无 | S-S6 | - | subagent-state/4-code-reviewer-S9.md | complete |

### Phase 5: 合并+部署对账+簿记
- [x] smart-merge-back（**合并后部署必须跑三 slot 存在性+diff 后验——D4 直接回归项**）
- [x] 部署后实弹：新 sid 会话解析演练（只读巡检）
- [x] delivery-summary+ledger
- **Status:** complete（2026-10-10 07:2x；merge b6e6e2e+F5 实弹+D4 后验+worktree 清理）
- **Executor:** 主进程（例外理由:① git/worktree 编排（合并/清理/部署）+② 计划系统文件簿记——Rule 25.3 白名单①②）

## FMEA（RPN>100）

| Phase | 失败模式 | RPN | 兜底 |
|-------|---------|-----|------|
| P3 | F3 守卫误伤（owner 已 complete 仍拦） | 84 | 只拦 in_progress owner；complete/missing owner=fail-open 仅 WARN |
| P3 | F5 改坏在途部署（v152/v154/v155 共用 deploy） | 96 | staging 纯增量新路径，旧逻辑保留为 fallback；任slot失败整体 exit 1 不半途 |
| P5 | 合并时 master 再推进（v152 land 1-67/钉518） | 120 | S7 事前 grep 实态+并集解+递推写法 |
| P2 | worktree 创建后 master 又动 | 60 | 创建后 git log 复核，必要时 rebase |

## Key Decisions

- 不动 critical-rules：纪律文本已在 v153 pointer-lifecycle-fix.md（B/C 提示词），本任务做机制化（gc/守卫/提醒/selftest）而非立 Rule（与 v158 source-anchor 制度化分工不重叠）
- D2 只巡检不代写：其他会话 side 指针缺位属其自身 init 职责，越权补写=§十一 并行踩踏
- F5 只改 deploy 段 staging/后验，merge 本体零改动

## 🔗 Subagent Handoff 登记表（Rule 22.5）

| # | 时间 | subagent_type | 任务目标(≤1句) | 状态 | 结论摘要 | checkpoint 路径 | verify_done |
|---|------|---------------|----------------|------|---------|----------------|------------|
| 1 | 10-10 06:0x | executor | set-active-plan 四修点（F1/F2/F3/F4） | done | 8/8 夹具过 | subagent-state/3-executor-S1.md | ☑ |
| 2 | 10-10 06:1x | code-assistant | init-session F3 同语义守卫 | done | skip-WARN+fail-open 双夹具 | subagent-state/3-code-assistant-S2.md | ☑ |
| 3 | 10-10 06:1x | code-assistant | check-complete 移交提醒+SKILL 纪律行 | done | 夹具命中+负对照 | subagent-state/3-code-assistant-S3.md | ☑ |
| 4 | 10-10 06:2x | executor | smart-merge-back F5 staging 原子化 | done | 双夹具+真 slot 零触碰 | subagent-state/3-executor-S4.md | ☑ |
| 5 | 10-10 06:2x | code-assistant | selftest-pointer-lifecycle 新建+registry | done | PL-01..10 全 PASS | subagent-state/3-code-assistant-S5.md | ☑ |
| 6 | 10-10 06:3x | code-runner-agent | V1 全量回归（69 脚本） | done | 2 FAIL(契约漂移)→级联修复 | subagent-state/4-code-runner-S8.md | ☑ |
| 7 | 10-10 06:3x | code-reviewer | V2 CR 一轮 | done | CHANGES_REQUESTED 1B+4M+3m | subagent-state/4-code-reviewer-CR.md | ☑ |
| 8 | 10-10 06:4x | code-assistant | SM-06/SM-14 契约更新 | done | 17/17 PASS | subagent-state/4-code-assistant-SM.md | ☑ |
| 9 | 10-10 06:5x | executor | CR 修复单元（B1 前置轮） | done | 9/9 验收 | subagent-state/5-executor-crfix.md | ☑ |
| 10 | 10-10 07:0x | code-reviewer | CR 二轮复审 | done | 抓 B1 反向回归 | subagent-state/5-code-reviewer-CR2.md | ☑ |
| 11 | 10-10 07:0x | executor | B1/M1/N1 锚定式修复 | done | 夹具三态+SM-16 legacy | subagent-state/5-executor-b1fix.md | ☑ |
| 12 | 10-10 07:1x | code-reviewer | CR 三轮终审 | done | APPROVED | subagent-state/5-code-reviewer-CR3.md | ☑ |
