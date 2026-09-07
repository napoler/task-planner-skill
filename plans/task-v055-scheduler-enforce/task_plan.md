<!-- template_type: bugfix -->
<!-- task: task-v055-scheduler-enforce -->

# Task Plan: task-v055-scheduler-enforce — 「主进程=调度器」定位机制化落地

## Goal
诊断并修复 task-planner 技能「主进程=调度管理器、任务执行下沉子代理」定位在实测中未落地的问题：定位当前是**指令性文本约束**（靠模型自觉遵守），需升级为**机制性强制**（hook 拦截/门控脚本），使主进程亲为白名单外操作时被硬性阻断，真正达到主进程调度、子代理执行。

**[09-08 B 类扩展]** 用户新增实测反馈：「执行子代理任务时，子代理往往没有正确返回——派发后长时间不返回，且子代理内部并未正确执行」。诊断范围扩展至**子代理派发-返回链路**（Agent 工具调用契约、sid 探测、模型路由 Provider 拒绝、同步阻塞语义、v055 新门控是否误伤子代理写入）。原机制层四 Phase 已完成并部署，本扩展 = Phase 5（新增）。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required` |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 根因已定位且含证据链（部署一致性 diff 结果 + 机制层缺陷分析，非"规则没写"这类症状描述） | findings.md 根因节含双证据 | `findings.md` |
| VC-2 | 修复为机制级强制（新增/强化 hook 或门控脚本可拦截白名单外亲为），非纯文本说教 | 拦截演示输出（模拟主进程写非白名单文件被阻断） | `tmp/enforce-demo.txt` |
| VC-3 | 修复不破坏现有功能：`verify.sh` 全绿 + 现有 5 计划文件 init 流程正常 | verify.sh exit 0 | `tmp/verify-output.txt` |
| VC-4 | 部署后 9 位副本与仓库字节级一致 | `diff -r` 逐位无差异 | `tmp/deploy-diff.txt` |
| VC-5 | 委派链路完整：本任务自身各 Phase 由子代理执行（Executor 字段 + Handoff 登记表 + 委派率 ≥ 0.75） | verification.md 委派统计段 | `verification.md` |

**终验规则**:
- 全部 VC 通过 → COMPLETE
- VC-1 失败 = 根因未明 → BLOCKED 升级用户
- VC-2 失败 = 仅改了文案 = 未达用户目标 → 回炉（用户本次核心诉求就是机制落地）

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 技能源码 | `skills/task-planner/**`（SKILL.md/scripts/hooks/references/templates） | 其他技能目录 |
| 部署目标 | 9 位部署点内 task-planner 目录（rm+cp -rL 重部署） | 部署点其他内容 |
| 计划文档 | `plans/task-v055-scheduler-enforce/**` | 改其他计划目录 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 项目内部文档 | task-v052 调度定位收口成果 | `plans/task-v052-scheduler-positioning/` | 必读 | ☐ |
| 项目内部文档 | worktree 隔离 SOP | `skills/task-planner/references/worktree-isolation.md` | 必读 | ☐ |
| 项目内部文档 | Critical Rules 25（委派门控） | `skills/task-planner/references/critical-rules.md` | 必读 | ☐ |
| 项目内部文档 | 部署拓扑 memory | `~/.zcode/cli/memories/projects/task-planner-skill-fba311568bf6d7b3/memory/task-planner-repo-deploy-flow.md` | 必读 | ☐ |
| 项目内部文档 | hooks 配置现状 | `~/.zcode/cli/config.json`（hooks.events）+ `skills/task-planner/hooks/` | 必读 | ☐ |

## Current Phase
Phase 5

## Phases

### Phase 1: 现状诊断与根因定位
- [x] 部署一致性：比对 9 位部署点 vs 仓库 master（找出用户实测位是否滞后）→ 3/3 一致，滞后证伪
- [x] 机制层分析：现有 hook/门控脚本对「主进程亲为白名单外操作」有无硬拦截 → scripts/ 0 处 Rule 25 引用，执行期拦截 100% 缺失
- [x] 内容层分析：SKILL.md 调度规则是文本说教还是可执行约束 → 570 行/28 次 P0/定位块 1 行，纯文本约束
- [x] 根因写入 findings.md（含证据链）→ findings.md「根因结论」节 + checkpoint 258 行
- **Status:** complete（2026-09-07 02:11，gate PASS）
- **Executor:** explore + codebase-analyzer（并行派发；explore Provider 拒绝×1 → 主进程补做 diff 验收，白名单④）

### Phase 2: 修复方案设计
- [x] 基于 Phase 1 根因出 ≥2 备选方案 + 推荐（机制级优先）→ 方案 A（最小）/B（完整），推荐 B
- [x] 评估副作用：hook 拦截过宽会误伤计划文件写入/部署操作 → critic 15 缺陷全评估（2 BLOCKER/4 MAJOR），修法已并入终版
- [x] 方案与证据写入 findings.md Technical Decisions → 含方案 B 最终版结构 5 节
- **Status:** complete（2026-09-07 02:35）
- **Executor:** architect + critic（方案挑刺）

### Phase 3: worktree 内实施修复
- [x] 创建 worktree（基于 master，A 批后因用户外部合并 176ff0f 重建一次基于最新 HEAD）
- [x] 按方案修改技能源码：A 批 eadd9ae（执行期拦截 6 文件+980 行，自测 18/18）+ 外部 4420c08（check-complete 门控+SKILL 部分收敛）+ B' 批 eee87e0（SKILL 收敛达标 497 行/P0×10 + verify 新 3 项 + verification 自動化）
- [x] 拦截演示验证（VC-2）tmp/enforce-demo.txt + verify.sh 回归（VC-3：selftest 18/18、verify 3 fail 均为待部署漂移）
- [x] 逐批提交（Rule 27）：eadd9ae / 4420c08(外部) / eee87e0
- **Status:** complete（2026-09-07 04:0x）
- **Executor:** executor（A 批+executor-B 外部干预 STOP 后 B' 批收尾；中途事件：用户并行合并 A 批并清理 worktree，B 批按选项 B 路径重建补完，见 findings R4）

### Phase 4: 合并回主仓 + 9 位重部署 + 终验
- [x] 主进程执行 `git merge --no-ff`（3 次合并：847f500/1d73577/fa893eb，白名单④调度簿记）
- [x] 派 executor 重部署 3 位 task-planner（rm+cp -rL ×3 轮）+ `diff -r` 逐位复验（VC-4：diff=0 ×9）
- [x] 主进程 Read 复验关键文件 + 委派率统计（VC-5：stats verdict=ok violations=[]）
- [x] Code Review Gate：首审 CHANGES_REQUESTED → fix-phase 批修 9 项 → 复审 **APPROVED**
- **Status:** complete（2026-09-07 05:0x）
- **Executor:** executor（部署执行 ×3 轮）+ 主进程（merge/验收/簿记，白名单④）

### Phase 5: 子代理派发-返回链路深度诊断（09-08 扩展）
- [x] 实收证据：各 plan 目录 subagent-state 与 verification 派发统计（Provider 拒绝/API 超时/丢失/未产出模式）
- [x] 契约比对：harness Agent 工具真实行为（同步阻塞？run_in_background？子代理 sid 特征？Provider/模型路由层失败形态）
- [x] 关键验证：v055 新门控（check-delegation pretool）对子代理写 subagent-state/ 检查点文件是否被放行/误拦（sid 探测 + 白名单 walk-up 实际行为）
- [x] 根因结论落 findings.md（新增「子代理返回失败」证据链），修复方向（机制层 or 派发协议层）
- [x] 修复方向裁决 + 机制化实施（用户 09-08 原话裁决=失败后主动 Scaling 指定模型改派；commit 382be79：subagent-fallback.sh probe/bind/next + config provider_fallback + Rule 22.3.1 + verify#10 + install 5.7）
- [x] 关键实证：ZCode Agent 工具**不热加载**新建 agent 定义（R12 双负结论：ccr 宕时变体 not found + ccr 宕时健康 provider 变体仍 not found）→ 架构定案 = 部署落盘预置 + 新会话生效；当前会话内兑现 = 主进程接管/新开会话
- [x] 真实实测：probe（agnes 通道 1-token OK，冷启动 >10s 故默认 timeout 提至 20s）+ bind（生成 4 个 -fb 变体=executor/explore/code-assistant/general-purpose，模型 custom:9a69b164…:agnes-2.5-flash，meta 登记）；自测 21/21；verify 25pass×3；3 位重部署 diff=0（cd0acdb）
- [x] 簿记 + push（382be79/cd0acdb/363a29e 已 push origin master）
- [x] 收尾：attest 重锁 + INDEX 刷新 + verification 委派统计追加
- **Status:** complete（2026-09-08）
- **Executor:** 主进程直做（白名单⑤ Rule 22.3 兜底接管：本批派发 executor/general-purpose 双双 Provider rejected——ccr 三档全宕，本批正是根因 1 现场演示；按 22.3 ③ 主进程接管（≤300 行/文件级编辑），派发记录见 Handoff 表 11/12 行）

## 09-08 B 类扩展 Decisions
| Decision | Rationale |
|----------|-----------|
| 失败改派 = 主动 Scaling（指定模型/换 provider 重派），非盲重试 | 用户 09-08 明示；73% 失败率下同类型盲试必崩（R10） |
| 动态 agent 文件方案需先实证可行性 | ZCode Agent 类型列表疑为会话启动时注入；热加载不确定 → 先 1 次最小派发实证再定架构 |
- **Executor:** 主进程编排 + Explore/general-purpose（证据收集）/ Debugger（契约排查）

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（信号①：7 未提交文件，均为 plans/ 计划文档+哨兵，与技能文件范围不重叠，判定无踩踏） |
| `isolation` | `worktree`（修改 skills 保护区文件，宪法 §十一 11.1-1 强制） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v055-scheduler-enforce` |
| `branch` | `wt/task-v055-scheduler-enforce` |
| `merge_back` | `merged(fa893eb)`（B' 收尾；后续 fix-composite→1d73577、fix-review→fa893eb 两轮追加合并） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步时间 | 备注 |
|-------|-----------|--------------|------|
| Phase 1 | ☐ |  | 诊断 |
| Phase 2 | ☐ |  | 方案 |
| Phase 3 | ☐ |  | 实施 |
| Phase 4 | ☐ |  | 部署终验 |

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type | 目标 | 状态 | checkpoint 路径 | findings 落点 | verify_done |
|------|---------------|------|------|----------------|---------------|-------------|
| 09-07 | explore | 9 位部署点一致性比对 | failed→兜底（Provider rejected ×1，主进程补做 diff） | subagent-state/01-explore.md（未产出） | Research Findings/R1 | ✓ |
| 09-07 | codebase-analyzer | 机制层+内容层缺陷分析 | complete | subagent-state/02-codebase-analyzer.md | Research Findings/R2 + 根因结论 | ✓ |
| 09-07 | architect | 方案 B 设计（三层闭环） | complete | subagent-state/03-architect.md | Technical Decisions | ✓ |
| 09-07 | critic | 方案挑刺（15 缺陷+裁决） | complete | subagent-state/04-critic.md | Technical Decisions | ✓ |
| 09-07 | executor-B | 终验统计+文案收敛 | STOP（外部干预：用户合并 A 批并清理 worktree，宪法 §四漂移 STOP 正确） | subagent-state/06-executor-b.md | — | n/a |
| 09-07 | executor-B' | 剩余 3 文件收尾（SKILL 收敛/verify/verification） | complete | subagent-state/07-executor-b2.md | findings R5 | ✓ |
| 09-07 | executor | 3 位重部署+diff 复验+verify 体检 | complete（3/3 零差异，23 pass/0 fail，selftest 18/18） | tmp/deploy-diff.txt | progress Phase 4 段 | ✓ |
| 09-08 | executor | v055-fallback 实施批次（5 文件+自测） | failed→③主进程接管（Provider rejected，ccr sonnet-1 宕；白名单⑤登记） | subagent-state/11-executor-fb.md（未产出，0 进度） | findings R13 | ✓（接管产出 382be79 已验收） |
| 09-08 | general-purpose | 同上（改派重试，零消耗不计 retry_limit 前的 1 次改派） | failed（Provider rejected；同法重试禁用 → 22.3 ③） | 同上（合并登记） | findings R13 | ✓ |

## Key Questions

1. 用户实测时用的是哪个部署位（zcode 主位/claude 位/opencode 位）？该位是否滞后于 master？
2. 现有 PreToolUse hook 在哨兵清除后是否还有任何「主进程亲为」拦截？
3. 委派率门控（delegation_rate_floor）是终验才查——执行中有没有提醒机制？
4. SKILL.md 加载后，调度规则处于什么位置/密度？执行模型能否稳定注意到？

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 修复方向=机制级强制优先 | 用户实测证明纯文本约束不生效（task-v052 已写定位文本仍失败）；指令性→机制性 |
| 失败后改派=主动 Scaling（用户 09-08 裁决） | 用户原话「失败以后主动使用 Scaling，主动指定模型运行子代理」；73% 失败率下同档盲试必崩（R10）；实现 = fallback 链（档位/provider 有序表）+ 脚本化改派决策 + agent 定义按档位预置 |

## Errors Encountered

| Error | Attempt | Resolution |
|-------|---------|------------|
|       | 1       |            |

## Notes

- 主进程本任务直做清单（白名单登记）：计划三文件维护/Todo 同步/git merge 合并回/部署验收 Read——其余全部派子代理
- 部署 = rm+cp -rL 重部署 + diff -r 复验（memory 部署铁律），禁止 cp 覆盖残留旧文件
- plans/ 按仓约定不入库；worktree 内只改 skills/ 源码
