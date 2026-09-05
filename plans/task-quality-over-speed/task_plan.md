# Task Plan: task-planner 质量优先于速度门控改造

<!--
  WHAT: 本计划 = task-planner 技能「质量>速度」流程化改造的工作底图
  WHY: 用户原话"优化该技能,确保从流程上可以避免降低质量",需要把质量原则变成可执行/可判定的门控+惩罚
  WHEN: Phase 状态每次变更同步;终验交付前完成委派率统计与 outcome 判定
-->

## Goal
将用户原则"质量优先于速度"固化为 task-planner 的流程门控与惩罚机制：新增质量门控 Rule（触发条件+惩罚后果）+ verification.md 增加质量统计段 + SKILL.md/critical-rules.md/templates/C 清单四处一致性同步落地。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required` |
| `session_id` | `<init 时生成 uuid>` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-quality-over-speed` |
| `scope_files` | `[skills/task-planner/SKILL.md, skills/task-planner/references/critical-rules.md, skills/task-planner/templates/verification.md, skills/task-planner/scripts/check-complete.sh]` |

## ✅ Verification Contract（目标完成判定标准 — 全部通过 = 完成）

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 新增质量门控条款同时落点 SKILL.md 与 references/critical-rules.md；含明确触发条件与惩罚后果 | `grep -nE "Rule 26|质量优先|质量门控" SKILL.md critical-rules.md` 显示两文件均命中 | 两文件 Read 行号,预计 critical-rules.md 末段追加 Rule 26,SKILL.md 「终验交付」/「Critical Rules」章节引用 Rule 26 |
| VC-2 | 惩罚机制可判定——规则文本含"触发条件 → 后果"的映射,对齐 Rule 25.4 "委派率<50% → outcome 最高 PARTIAL" 的降级范式 | Read critical-rules.md Rule 26 段,人工判定条款含触发条件清单 + outcome 降级/阻断映射 | critical-rules.md 末段行号 |
| VC-3 | templates/verification.md 含质量统计段（委派率/降级判定/质量违规计数等可量化字段）；若设计阶段论证豁免则必须在 findings.md 记录豁免理由 | Read verification.md 含"质量统计"/"委派统计"段;豁免则 Read findings.md 决策记录 | templates/verification.md 行号（或 findings.md 决策行） |
| VC-4 | 跨文件一致性:SKILL.md、critical-rules.md、templates/verification.md、合规检查清单 C 列表间 grep 无残留冲突措辞（同一概念两种说法/过期引用/不一致编号） | `grep -nE "Rule 25|Rule 26|委派率|质量门控"` 跨四文件,人工核对措辞一致 | grep 输出 + Read 命中行 |
| VC-5 | 无回归:init-session.sh 在临时目录生成 5 文件正常 + worktree 合并回后主仓 `git log` 可见 merge commit + worktree 已 `remove` + 分支已 `-d` | `bash scripts/init-session.sh /tmp/test-qos` + `git log --oneline -1` + `git worktree list` + `git branch -D wt/task-quality-over-speed`(失败也 OK) | 命令输出 |
| VC-6 | scripts/check-complete.sh 对既有全 complete 计划仍 exit 0（若改造涉及脚本） | `bash scripts/check-complete.sh plans/<既有 plan>/task_plan.md` 退出码 0 | 命令退出码与 stdout |

**终验规则**:
- 全部 VC 通过 → outcome: **COMPLETE**
- VC 通过但有已知遗留缺陷 → outcome: **PARTIAL**(列出 + 建议后续)
- ≥1 VC 失败且重试 3 次无效 → outcome: **BLOCKED**(升级用户决策)

## ⚠️ 执行范围限制(强制 - 只操作列表内的文件)

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 源码 | `skills/task-planner/SKILL.md`, `skills/task-planner/references/critical-rules.md`, `skills/task-planner/templates/verification.md`, `skills/task-planner/scripts/check-complete.sh`(仅当设计论证需修改时) | 其他 skills/task-planner 下文件、其他 skill 目录、仓根 AGENTS.md |
| 测试 | 无新增测试(YAGNI) | — |
| 配置 | 无 | config.json / hooks / plugins |
| 文档 | `plans/task-quality-over-speed/task_plan.md`, `plans/task-quality-over-speed/findings.md`, `plans/task-quality-over-speed/progress.md` | 其他 plans/* 目录、其他 markdown 文档 |

**执行前自我检查**:
- [ ] 这个文件在上面的列表中吗?
- [ ] 这个修改对完成任务有必要吗?
- [ ] 用户明确要求我做这个修改吗?
- 全部 Yes → 可以执行 | 任一 No → 先问用户

## ⚠️ 核心问题定义(强制 - 任务开始前必须回答)

**核心问题**: 现有 task-planner 是否能从流程层面阻止"为了赶速度而牺牲质量"的行为?改造后能否让违反质量门控的行为自动触发可判定的惩罚?

**核心问题判断**:
- [x] 核心问题解决后,技能升级版可交付用户使用
- [x] 核心问题不解决,其他质量优化都流于口头(用户原话明确"惩罚")
- [x] 核心问题的解决方法是清晰的(Rule 26 + verification.md + 四处同步,可分阶段实施)

## Current Phase

全部完成(5/5 Phase complete)

## Next Step

无 — 交付完成,outcome: COMPLETE(见 verification.md 终验段,VC-1~VC-6 全 PASS)。

## Phases

<!--
  5 Phase 总览:
  Phase 1 = 计划创建 + 模板填充(本阶段完成)
  Phase 2 = 现状盘点(codebase-analyzer)
  Phase 3 = 方案设计(architect)
  Phase 4 = worktree 实施(executor)
  Phase 5 = 一致性验证 + 合并回(critic + 主进程)
-->

### Phase 1: 计划创建与模板填充
<!-- WHAT: 在 init-session.sh 生成的空白模板上填充本计划,锁定 5 Phase + 6 VC + Scope + 隔离决策 -->
- [x] Read 模板 task_plan.md(critical-rules.md/SKILL.md 关键节/templates/verification.md)
- [x] 填写 Goal/VC/Scope/Phases/隔离决策/委派统计骨架
- [x] 跑 `check-conflicts.sh` 验证仅信号①(.plan-required 与 plans/),无 ②③④⑤
- **Status:** complete
- **Executor:** plan-writer(主进程白名单:计划文档属 Rule 14 例外)

### Phase 2: 现状盘点 — 已有机制 vs 质量优先诉求差距
<!--
  WHAT: 通读 task-planner 现有质量条款,产出可改造点清单
  WHY: 避免凭空设计 Rule 26,需先知道 Rule 18/19/25/completion-gate/goal-gate/C 清单已有什么、缺什么
-->
- [x] Read `skills/task-planner/SKILL.md`(全 613 行,主进程禁止 Read >500 行 → 派子代理)
- [x] Read `skills/task-planner/references/critical-rules.md`(已读,确认现有 Rule 1-25)
- [x] Read `skills/task-planner/references/completion-gate.md` 与 `goal-gate.md`
- [x] Read `skills/task-planner/templates/verification.md`(已读,确认结构)
- [x] 产出 findings.md「已有机制 vs 质量优先诉求」差距表(行级指出现有条款 + 缺什么 + 待 Rule 26 补什么)
- **Status:** complete
- **Executor:** codebase-analyzer(sonnet-1)— Rule 13 强制:大文件/跨文件 Read 必派子代理
- **产出:** `plans/task-quality-over-speed/findings.md` 差距清单段
- **VC 映射:** 为 VC-1/VC-3/VC-4 提供基线

### Phase 3: 方案设计 — Rule 26 草案 + 跨文件落地清单
<!--
  WHAT: 设计 Rule 26 「质量优先于速度门控」条款 + 同步修订清单
  WHY: 用户原话"对降质行为有惩罚"——Rule 25 是现成范式,Rule 26 沿用相同结构(触发条件清单 + outcome 降级映射)
-->
- [x] 设计 Rule 26 草案:触发条件(如跳过 VC 验证/压缩验证步骤/伪造证据/委派率<50%无理由/未读子代理产出即标记 complete 等 5-8 条)+ 惩罚后果(outcome 降级 PARTIAL / 阻断 BLOCKED / 强制回炉重做)+ 例外条款(用户显式豁免场景)
- [x] 列出跨文件落地清单:critical-rules.md 末段追加 Rule 26;SKILL.md 终验交付节 + 合规检查清单加引用;C 清单是否新增 C15「质量违规计数=0」由设计论证;verification.md 加质量统计段(委派率/降级记录/违规次数)
- [x] 决策记录:是否改 check-complete.sh(默认不改,YAGNI;若新增 C15 触发脚本硬校验则改)
- [x] findings.md 写入「方案设计」段(供 Phase 4 实施使用)
- **Status:** complete
- **Executor:** architect(sonnet-1)— Rule 21 拆分产物由设计者定型
- **产出:** findings.md「方案设计」段(本阶段权威);不写任何源码修改
- **VC 映射:** VC-1/VC-2 的措辞权威源;VC-3 的豁免决策点;VC-4 一致性目标来源

### Phase 4: worktree 实施 — 按方案修改 + commit
<!--
  WHAT: 在 worktree 隔离区按 Phase 3 方案修改 3-4 个文件并 commit
  WHY: §11.1.1 命中保护区 → 必须 worktree;单 Phase 触及 ≤3 文件(SCOPE_FILES=4 但 C 清单改动可能并入 SKILL.md),需评估是否拆 4a/4b
-->
- [x] 创建 worktree:`git worktree add /mnt/data/dev/task-planner-skill-worktrees/task-quality-over-speed -b wt/task-quality-over-speed master`
- [x] 4a 修改 critical-rules.md 末段追加 Rule 26 全文(对齐 Rule 25.4 范式)
- [x] 4b 修改 SKILL.md 终验交付节引用 Rule 26 + 合规检查清单加 C15(若设计阶段决定)
- [x] 4c 修改 templates/verification.md 加质量统计段
- [x] 4d 若需改 scripts/check-complete.sh(由 Phase 3 决策点决定)→ 单独派 executor
- [x] `git diff --stat` 确认改动落在 Scope 内 + `git commit` 每个文件独立提交
- **Status:** complete
- **Executor:** executor(sonnet-1)— Rule 14 多文件编辑路由;若 4 个文件触发 max_files_per_dispatch>3,拆为 4a/4b/4c 三个子阶段(每个子阶段 ≤3 文件)
- **产出:** worktree 内 1-4 个 git commit + `git status` 干净
- **VC 映射:** VC-1/VC-2/VC-3/VC-4 落地证据

### Phase 5: 一致性验证 + 合并回 + 终验
<!--
  WHAT: 跨文件一致性核对 + 脚本冒烟 + 主仓合并回 + 委派率统计 + outcome
  WHY: §11.3 合并回合约全部满足才可合并;主进程直做的 Phase 须在 Executor 字段写例外理由
-->
- [x] 5a 一致性核对(critic 子代理):跨四文件 grep `Rule 26|质量门控|质量统计|委派率`,核对措辞一致 + 无过期引用
- [x] 5b 冒烟测试:worktree 内 `bash scripts/init-session.sh /tmp/test-qos-$$` 生成 5 文件成功 + `bash scripts/check-complete.sh <plan>` exit 0
- [x] 5c 主仓 `git merge --no-ff wt/task-quality-over-speed` + Read 关键文件复验 + `git log` 确认 merge commit
- [x] 5d 清理:`git worktree remove` + `git branch -d wt/task-quality-over-speed`(遗留 = 视为未完成)
- [x] 5e 委派率统计:本计划 5 Phase,子代理执行 4 个(Phase 2/3/4/5a) = 80%;主进程直做 1 个(Phase 5c-5e git 编排 + 合并回)需在 Executor 字段登记例外理由
- [x] 5f 终验:VC 逐条复验 + outcome 判定 + verification.md 写入终验段
- **Status:** complete
- **Executor:** critic(sonnet-1)— Phase 5a 一致性核对;主进程(例外理由:§11.3 合并回合约 = `git merge`/`worktree remove`/`branch -d` 属主仓编排动作,不可委派子代理)
- **产出:** 主仓 master 分支含 merge commit + worktree 已清理 + verification.md 终验段 + outcome
- **VC 映射:** VC-5/VC-6 验证证据;VC-1~VC-4 复验

## 🔀 隔离决策(冲突分析 — 实现类默认首选 worktree)

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `safe`(仅信号①: .plan-required 与 plans/ 为本任务自身产物,无 ②③④⑤) |
| `isolation` | `worktree` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-quality-over-speed` |
| `branch` | `wt/task-quality-over-speed` |
| `merge_back` | `merged(d2f030d)` |

> 隔离理由:本任务修改 `skills/task-planner/SKILL.md` + `references/critical-rules.md` 等技能定义文件,命中宪法 §11.1.1 保护区(修改 `~/.zcode/skills/**` 类保护区文件),§11.5 不命中任一例外(非纯文档/非纯调研/非单文件 ≤3 行 trivial),故 worktree 强制。

> 合并回合约见 `~/.zcode/skills/task-planner/references/worktree-isolation.md` §3:全部 Phase = complete + worktree git status 干净 + 主仓无重叠变更 + `git merge --no-ff` + Read 复验 + 强制清理 worktree 与分支。

## 🔁 原生 Todo 同步(S1–S5 强制)

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☑ | 2026-09-04 | 计划已写入 |
| Phase 2 | ☐ |  | 待派 codebase-analyzer |
| Phase 3 | ☐ |  | 待派 architect |
| Phase 4 | ☐ |  | 待派 executor |
| Phase 5 | ☐ |  | 待派 critic + 主进程合并回 |

## Key Questions

1. Rule 26 的触发条件清单具体覆盖哪些"降质行为"?是否包含:跳过 VC 验证、压缩验证步骤、伪造证据、未读子代理产出即标记 complete、委派率 <50% 无理由?(默认对齐 Rule 18/25 范式,5-8 条为宜)
2. verification.md 质量统计段是否新增独立段落,还是嵌入既有「委派统计复验」段?(默认新增独立段,字段:委派率 / outcome 降级次数 / 质量违规计数)
3. 合规检查清单 C 清单是否新增 C15「质量违规计数=0」?(默认新增;若否则 C14 改为双查「Executor 一致 + 质量门控通过」)
4. scripts/check-complete.sh 是否需要加质量检查硬校验?(默认不改,YAGNI;若 C15 触发脚本硬校验则改)
5. worktree 实施是否需要拆 4a/4b/4c 三个子阶段?(默认按 max_files_per_dispatch=3 拆,确保单次 Agent 派发 ≤3 文件)

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 隔离方式 = worktree | 命中宪法 §11.1.1 保护区(skills/task-planner/**),§11.5 例外未命中;§11.3 合并回合约必须满足 |
| 模板类型 = code-edit + refactor 混合 | 本质是改造技能(修改 .md/.sh),对齐 code-edit 模板;但含 cross-file consistency 重构,叠加 refactor 关注点 |
| 6 条 VC(含 VC-6 条件性) | 用户原话"质量高于速度,从流程上来提高质量、惩罚" — 6 条覆盖门控+惩罚+同步+无回归+脚本兼容性 |
| 沿用 Rule 25 范式(委派率 <50% → PARTIAL) | 用户原话"对降质行为有惩罚",Rule 25.4 是现成最相近的降级惩罚范式,Rule 26 复制此结构以降低学习成本 |
| Scope 限定 4 文件(SKILL.md/critical-rules.md/verification.md/check-complete.sh 条件性) | YAGNI:不加用户没要的;check-complete.sh 仅在设计论证需 C15 硬校验时改 |
| Phase 5c-5e 主进程直做 | §11.3 合并回合约 = `git merge --no-ff` / `worktree remove` / `branch -d`,不可委派子代理(涉及主仓 reflog 与 mtime) |
| 不在 plan 中写具体措辞 | 用户原话 + Phase 草案明确"禁止把实施细节写死到具体措辞——Phase 2 设计产出才是措辞权威" |
| plan 总长目标 ≤500 行 | 当前约 280 行,实施期 findings.md 增长不影响本文件 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
| 无 | 1 | 初始化阶段无错误 |
| check-complete.sh 报 `NameError: name 'aggregator_missing' is not defined`(stdin line 169) → exit 1,影响所有含 Phase 的计划 | 1 | 脚本自身 bug:line 173-177 因缩进错误落入 line 167 `if total == 0` 早退分支内,含 Phase 的计划永不执行 `aggregator_missing = []` 初始化,line 183 顶层引用即 NameError。**非本计划内容缺陷**。脚本修正属技能源码改动(§六 保护区),归 Phase 3 设计决策(4d 条件项触发 → Phase 4d 必做),本计划撰写期不改 scripts |
| Edit 工具超时假阴性 → findings.md 方案设计段双写(297 行);同会话后续 Edit 对 worktree SKILL.md 报 String not found | 各 1 | 双写:grep 发现后 sed 行定位去重(150-232d)并复核单份;String not found:改行定位 sed 精确替换。教训已记 progress.md Error Log:超时后先验证是否已写入再重试 |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions (attention manipulation)
- Log ALL errors - they help avoid repetition
- Never repeat a failed action - mutate your approach instead
- 本计划粒度:Phase 2/3/4 各派一次子代理,Phase 5a 派 critic,总委派率 80%(≥50%,outcome 可达 COMPLETE)

## 🚨 Drift Log(漂移检测记录)

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |             |        |      |

## 📦 Batch Report(批量处理质量门控 — Rule 18.6)

| 字段 | 值 |
|------|-----|
| `total` | n/a(非批量场景) |
| `success` | n/a |
| `failed` | n/a |
| `failure_rate` | n/a |
| `sampled_pass` | n/a |
| `sampled_fail` | n/a |
| `pre_check` | n/a(单任务非批量,Rule 18 不适用) |
| `rollback_point` | n/a |

> 说明:本任务为单任务代码改造,非批量/并发/多文件批量场景,Rule 18 不适用,Batch Report 字段标记 n/a。如 Phase 4 拆为 4a/4b/4c 三个 subagent 派发,属 subagent 规模限制(Rule 22)而非批量质量门控(Rule 18)。

## 📊 委派统计(Rule 25.4 — 终验前必填)

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 4 / 5(Phase 2/3/4/5a 派子代理) |
| 主进程直做 Phase 清单 | Phase 5c/5d/5e(例外理由:§11.3 合并回合约 = git merge --no-ff / worktree remove / branch -d 涉及主仓 reflog 与 mtime 探针,Rule 11.4 P0 禁止委派) |
| 委派率 | 80%(≥50%,outcome 可达 COMPLETE) |

## 🔗 Subagent Handoff 登记表(Rule 22.5 必填)

| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | verify_done |
|---|------|--------------|----------------|------|--------------|---------------|-------------|
| 1 | 2026-09-04 | codebase-analyzer | 盘点 task-planner 现有质量条款,产出已有 vs 诉求差距清单 | done | 无统一质量违规→惩罚条款;6 类行为中压缩验证/伪造证据/直做真实性无门控;差距表已回填 findings.md | findings.md「Phase 2 现状盘点」段;抽查 5/5 命中(SKILL.md:183/200 等) | ☑ |
| 2 | 2026-09-04 | architect | 设计 Rule 26 草案 + 跨文件落地清单 | done | Rule 26 全文(Q1-Q6 触发式+惩罚阶梯,Q3 无豁免);4 文件 7 项落地清单;裁决 3 采纳 2 调整 | findings.md「方案设计」段;锚点复核 4/4 | ☑ |
| 3 | 2026-09-04 | executor(A) | worktree 内改 critical-rules.md(追加 Rule 26)+ SKILL.md(2a/2b/2c 三处) | done | commits ed5da8f+0f0469c;26.x=6;SKILL.md :184/:211 命中;worktree 干净 | 主进程 git log+grep 复核属实 | ☑ |
| 4 | 2026-09-04 | executor(B) | worktree 内改 verification.md(3a 小节)+ check-complete.sh(去缩进修 bug) | done | commits be4b04b+84259a7;插入位 :74/:80;双回归通过(无 NameError/exit 0) | 主进程重跑双回归属实 | ☑ |
| 5 | (Phase 4c) | executor | 在 worktree 内修改 templates/verification.md 加质量统计段 | queued | | | ☐ |
| 6 | (Phase 4d,条件性) | executor | 若设计决定则修改 scripts/check-complete.sh 加 C15 硬校验 | queued | | | ☐ |
| 7 | 2026-09-04 | critic | 跨四文件一致性核对(worktree diff 全量审查) | done | 六项 5 PASS+1 PASS(NIT);2 WARNING(Rules 1-25 陈旧标签)已由主进程修复(commit 367f388);脚本纯缩进修复 AST 证实 | findings.md「critic 审查结论」段 | ☑ |

## 🔗 Chain 区块交接配置(可选)

<!-- 单 skill 任务,可删除此整个区块。保留以备 Phase 4 拆 sub-task 时启用 linked 模式 -->

### Chain 模式

| 字段 | 值 |
|------|-----|
| **chain_mode** | `single`(默认) |
| **current_block** | Block 1 |
| **handoff_on_complete** | ❌ 否 |

### Block 1: 质量门控改造(当前块)

| 字段 | 值 |
|------|-----|
| **goal** | Rule 26 + verification.md + 四处一致性同步落地 |
| **depends_on** | none |
| **passes_to** | n/a(单块任务) |
| **status** | complete |

### 🔗 Handoff 追踪表

| Block | 状态 | 交接产物路径 | 验证命令 | 实际完成时间 |
|-------|------|------------|---------|-------------|
| Block 1 | in_progress | plans/task-quality-over-speed/findings.md | `bash scripts/check-complete.sh plans/task-quality-over-speed/task_plan.md` | — |