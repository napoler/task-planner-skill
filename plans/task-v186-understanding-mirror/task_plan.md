# Task Plan: Rule 80.7 理解镜像——模型理解同步记录配对机制
<!-- ===== frontmatter 头 ===== -->
template_type: general
plan_tier: standard
execution_lane: L1

## 🎯 用户需求原文（Rule 51.1）

- **R1**: 「之前当前技能的设计不是包含着将用户提交的请求，就是用户提交的内容，记录到文档吗」<sub>（[手段]）</sub>
- **R2**: 「我希望可以再加补充一点，就是将模型理解，就是模型整理之后的用户的需求，也同步存储到里面，存储到文档」<sub>（[手段]）</sub>
- **R3**: 「我的思路是这样的，就是将用户的请求，然后记录，然后再将模型理解的用户需求，然后再同步记录」<sub>（[手段]）</sub>
- **R4**: 「这样的话就是可以方便我后期如果出现问题，那么方便回溯这部分理解的是不是因为理解偏差，就是理解用户的需求偏差导致的错误」<sub>（[手段]）</sub>
- **R5**: 「这样后期也可以通过回溯这些信息发现哪里不对，然后及时纠正」<sub>（[手段]）</sub>

### R→VC 映射（Rule 51.2）
| R | 映射 VC | 覆盖判据 |
|---|---------|---------|
| R1 | VC-1 | 落点=现行 Rule 80 机制（子条增补非新建） |
| R2 | VC-1, VC-2 | 80.7 条款在位+模板配对格式在位 |
| R3 | VC-3 | 80.7 含「逐字条目后紧随配对/同号」语义 |
| R4 | VC-3 | 80.7 含「回溯定位理解偏差」语义与对照面定位 |
| R5 | VC-3 | 80.7 含「更正镜像追加（及时纠正）」语义 |

### 🗣️ 用户会话逐字记录（Rule 80 — 只写不改专档指针）
- **专档路径**：`plans/task-v186-understanding-mirror/user-session-log.md`
- **只写不改铁律**：条目 append-only；已写条目冻结，禁修订/删除/改写（Rule 80.2）
- **理解镜像**：每条逐字条目后同号配对「理解镜像」块（80.7 草案格式已在本任务专档 dogfood；非权威对照面，冲突以逐字原文为准）
- **恢复协议**：会话恢复/上下文压缩后先读专档（#1 至最新条目），再读 task_plan.md

## 🧮 根源覆盖表（Rule 53.1）

不适用（非结果级需求）——R1-R5 为「补充记录机制条款」的单点制度动作（手段型），无生产管线工序链可审计。

<!-- plan_tier: standard -->

## 🔒 不变量声明区（Rule 73.3）
| 三态 | 条目 | 来源锚 |
|------|------|--------|
| 🔒 不变量 | Goal；VC 表；R1-R5 原文；落点=Rule 80 增子条 80.7（零新 Rule 号/零全集级联）；逐字专档 80.1-80.6 既有条款原文零改动；L0-T 零新增守护脚本/零新 config 键 | 本计划各节 |
| 🔀 可变量 | 80.7 子条措辞细节、镜像块模板格式细节、S-unit 编辑顺序 | - |
| 📈 学得量 | selftest SL-01..11 锚实跑结果、指针区块静态断言实况 → findings.md | findings.md |

## Goal

向核心 Rule 80 增补子条 80.7「理解镜像（模型理解同步记录）」并更新逐字专档模板/指针区块/SKILL 指针的配对格式，使每条用户逐字记录后同号配对一条模型理解镜像（非权威对照面、append-only），供回溯定位理解偏差；全量回归零破坏并合并回 master。

## 🔍 Code Review 配置

| 字段 | 值 |
|------|-----|
| `code_review` | `required`（技能文件修改；轻量单轮） |
| `session_id` | `fae73c58a87848799b51ae47a36810ea` |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v186-understanding-mirror` |
| `scope_files` | worktree: skills/task-planner/references/critical-rules.md, skills/task-planner/SKILL.md, skills/task-planner/templates/user-session-log.md, skills/task-planner/templates/task_plan.md；主仓: plans/task-v186-understanding-mirror/**, plans/INDEX.md |
| `interaction_mode` | `silent`（自主会话；授权锚=user-session-log #1 逐字+#1 理解镜像） |
| `对齐审查` | `[登记]` alignment-review 单轮（终验前） |
| `自动超时默认项` | 无 2+ 选项询问点；若触发默认=推荐项、超时 5min |
| `new_rule` | （留空——子条增补非新 Rule，零编号占用） |
| `质量审查工具` | Code Reviewer + alignment-review + drift-checker；池覆盖无缺口 |

## ✅ Verification Contract

> **验证独立性**：终验核查由 Verifier 子代理执行（Rule 33.3）。

| # | 判定标准 | 验证方式 | 证据路径/命令 |
|---|----------|----------|---------------|
| VC-1 | 80.7 条款在位（核心 critical-rules.md，80.1-80.6 零改动） | grep | `grep -c "^80.7 \*\*理解镜像" skills/task-planner/references/critical-rules.md`=1；`git diff 基线..HEAD -- 该文件` 仅增 80.7 行 |
| VC-2 | 配对格式落位：专档模板+task_plan 模板指针+SKILL 指针 | grep | templates/user-session-log.md「理解镜像」≥2；templates/task_plan.md ≥1；SKILL.md ≥1 |
| VC-3 | 语义承载 R3-R5：配对/同号、非权威对照、append-only 更正、回溯理解偏差 | grep 段内 | 80.7 行含「非权威」≥1、「更正」≥1、「配对|同号」≥1、「理解偏差」≥1 |
| VC-4 | 全量回归零破坏（SL-01..11 既有锚不受扰） | 跑套件 | `run-selftests.sh --fresh` 末行 FAIL=0 |
| VC-5 | dogfood：本计划专档已按新格式配对 | grep | 本计划 user-session-log.md「#1 理解镜像」=1 且 #1 逐字条目在位 |
| VC-6 | 合并收口干净 | git | scope 零未提交+worktree list 无本任务+merge commit 在 log |

**终验规则**：全部 VC → COMPLETE；有遗留 → PARTIAL（列出）；≥1 VC 三次重试无效 → BLOCKED。

## 🎯 核心目标达成裁决（Rule 58.5）

n/a（纯手段型任务）——R1-R5 全 [手段]（交付物=记录机制条款），与本需求区标注一致。

## 🎯 Goal 单元表（Rule 66.1）

| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式 | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|-------------|------------------|------|
| G1 | 条款落地 | 80.7 入核心规则文件 | grep ^80.7 理解镜像=1 | S1/Phase 2 | pending |
| G2 | 配对格式 | 专档模板+指针区块+SKILL 指针更新 | grep 理解镜像 三文件命中 | S2/Phase 2 | pending |
| G3 | 回归绿 | selftest FAIL=0 | run-selftests --fresh FAIL=0 | S3/Phase 3 | pending |
| G4 | 合并收口 | --no-ff 合并+清理+归档簿记 | merge 在 log ∧ worktree=0 | Phase 4-5 | pending |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|------|-----------|------|
| 技能文件（worktree） | 上表 scope_files 四文件 | 其他技能文件；80.1-80.6 原文零改动；部署位 |
| selftest | 无（预期零断裂；断裂才最小修复并登记） | 新增 selftest/registry（L0-T 禁） |
| 主仓簿记 | plans/task-v186-understanding-mirror/**、plans/INDEX.md | 他任务目录；task-v184 目录 |

## 📋 变更标注表（Rule 74.3）

| 编号 | 对象 | 类型 | 吸收判定 | 依据 | 执行动作 |
|------|------|------|---------|------|---------|
| CA-1 | worktree skills/task-planner/references/critical-rules.md（:144 后） | 新增 | 增量 | R2-R5 | 80.1-80.6 后追加 80.7 全文（草稿=findings §80.7 草稿） |
| CA-2 | worktree skills/task-planner/templates/user-session-log.md | 更新 | 增量 | R3 | 条目格式区新增「### #N 理解镜像」配对块+格式范式注记 |
| CA-3 | worktree skills/task-planner/templates/task_plan.md 指针区块 | 更新 | 增量 | R2 | 静态行「理解镜像」说明（SL-08 负断言安全：无可变计数） |
| CA-4 | worktree skills/task-planner/SKILL.md（:188 Rule 80 指针行+G9 行） | 更新 | 增量 | R2 | 两行各追加 80.7 配对提示 |
| CA-5 | selftest（仅回归断裂时） | 更新 | 增量 | VC-4 | 断裂锚最小修复 |
| CA-6 | plans/INDEX.md | 更新 | 增量 | 簿记 | sync-todos --index |

## 📚 必要知识储备

| 类别 | 名称/主题 | 定位 | 必读 | 已确认 |
|------|-----------|------|------|--------|
| 项目内部文档 | Rule 80 现行 80.1-80.6 全文 | 核心 critical-rules.md:129-144 | 必读 | ☑ |
| 项目内部文档 | templates/user-session-log.md 现行格式+SL-01..11 断言面 | templates/ + selftest-session-log.sh | 必读 | ☑ |
| 项目内部文档 | 增补判例（19.8 子条增补先例）/L0-T 范式 | critical-rules-discipline.md 86.7/89.6/90.6/92.7 | 参考 | ☑ |

## ⚠️ 核心问题定义

**核心问题**: 逐字记录只存「用户说了什么」，不存「模型当时理解成什么」——理解偏差导致的错误无法回溯定位。解决=80.7 理解镜像配对机制，即可交付。

**核心问题判断**:
- [x] 解决后能交付（条款+模板+回归绿）
- [x] 不解决则用户回溯诉求（R4/R5）无承载
- [x] 方法清晰（落点/格式/级联面已考证）

## 🔍 调研需求与检索计划

| S-unit | 三态 | 关键词 | 渠道 | 产出 | 网络评估 |
|--------|------|--------|------|------|---------|
| S1/S2 | LOCAL-ONLY | Rule 80 文本/SL 断言面/模板格式 | 本仓 Read/grep（已完成） | 80.7 草稿+CA 表 | 否 |
| S3 | LOCAL-ONLY | run-selftests | 本地脚本 | 回归汇总 | 否 |
| S4 | LOCAL-ONLY | VC 命令 | 本地 grep/git | PASS 表 | 否 |

## 🔍 证据面清单

n/a（纯执行类）。

## Current Phase

Phase 5

## Next Step

CR→Verifier→align 三门→check-complete→归档→尾提交。

## 🧰 工具选择与编排（Rule 40）

| Phase | 命中工具面 | 理由 |
|-------|-----------|------|
| Phase 1 | 机械守卫脚本 | 簿记+指针（①②） |
| Phase 2 | executor(sonnet-1)×2 | 技能文件默认派发 |
| Phase 3 | code-runner-agent(mini) | 测试跑批 |
| Phase 4 | 机械守卫脚本 | git 编排（①） |
| Phase 5 | Verifier+Code Reviewer+drift-checker+alignment-review | 独立终验+三重审查门 |

**workflow 编排判定**: 未命中（线性小任务）。**/goal**: 未使用；Goal 单元表=证据源。

## Phases

### Phase 1: 计划与隔离基线
- [x] init 7 文件+指针指向本计划
- [x] 侦察（Rule 80 现文/SL 断言面/模板位置，落 findings）
- [x] 专档 dogfood：#1 逐字+#1 理解镜像配对落盘
- [ ] attest 锁定+哨兵清除
- [ ] worktree 创建（基线=主仓 HEAD）+resolve 复验
- **V-N:** VC-4, VC-6
- **Status:** in_progress
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排 ② 计划系统文件维护——Rule 25.3 白名单①②）

### Phase 2: 80.7 条款与配对格式落地（worktree）
- [x] S1：80.7 入核心 critical-rules.md（:146）+SKILL.md 两处指针（3/3 自验+主进程 8 项亲验全过）
- [x] S2：两模板配对格式（user-session-log ×2 处+task_plan 指针 ×1 处；SL-08 负断言 grep=0）
- [x] 主进程 Read 复核+drift-checker（**ALIGNED**，检查点 2-drift-checker.md）
- **V-N:** VC-1 ✓(1), VC-2 ✓(3/1/2), VC-3 ✓(1/1/1)
- **Status:** complete
- **Executor:** executor（sonnet-1）

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|------|---------|------|---------|---------|------|
| S1 | 80.7 条款+SKILL 指针落地 | executor(sonnet-1) | <plan>/s1-brief.md（80.7 草稿与精确编辑点）；<worktree>/skills/task-planner/references/critical-rules.md 与 SKILL.md | grep ^80.7=1 ∧ SKILL 理解镜像≥1 | 15min | 2f/20l/15min | 无 | - | pending |
| S2 | 两模板配对格式 | executor(sonnet-1) | <plan>/s2-brief.md（镜像块格式与插入位）；<worktree>/skills/task-planner/templates/user-session-log.md 与 task_plan.md | 两文件 grep 理解镜像命中 | 15min | 2f/15l/15min | 无 | S1 | pending |

### Phase 3: 全量回归（worktree）
- [x] run-selftests --fresh：**Total: 91 PASS=91 FAIL=0**（selftest-session-log 12/12 过）
- **V-N:** VC-4 ✓, VC-1 ✓
- **Status:** complete
- **Executor:** code-runner-agent（mini）

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|------|---------|------|---------|---------|------|
| S3 | worktree 全量回归 | code-runner-agent(mini) | <worktree>/；命令 run-selftests.sh --fresh | 末行 FAIL=0 | 15min | 1f/0l/15min | 无 | S1,S2 | pending |

### Phase 4: 合并回主仓
- [x] 主仓干净核对 ✓→merge --no-ff→核验（80.7=1）→worktree 清理（list=0）
- **V-N:** VC-6 ✓, VC-1 ✓
- **Status:** complete
- **Executor:** 主进程（例外理由:① 纯 git/worktree 编排——Rule 25.3 白名单①）
- **merge_back**: merged（见 git log merge(task-v186)）

### Phase 5: 终验与交付
- [ ] CR Gate 单轮+S4 Verifier 独立复验+alignment-review 单轮
- [ ] INDEX 刷新+归档尝试+delivery-summary 五要素
- **V-N:** VC-5, VC-6
- **Status:** in_progress
- **Executor:** Verifier（mini）（核查子代理；主进程簿记走白名单②）

### Phase 5: 终验与交付
- [ ] CR Gate 单轮+S4 Verifier 独立复验+alignment-review 单轮
- [ ] INDEX 刷新+归档尝试+delivery-summary 五要素
- **V-N:** VC-5, VC-6
- **Status:** pending
- **Executor:** Verifier（mini）（核查子代理；主进程簿记走白名单②）

| ID | 目标 | 执行体 | 输入 | 验收 | 预估时长 | 粒度 | 伴飞技能 | 前置依赖 | 状态 |
|----|------|--------|------|------|---------|------|---------|---------|------|
| S4 | 独立复验六项 VC | Verifier(mini) | <plan>/verification.md；主仓根 | 六项 PASS 表 | 15min | 1f/0l/15min | 无 | Phase 4 | pending |

## 🔀 隔离决策

| 字段 | 值 |
|------|-----|
| `conflict_scan` | `risk`（task-v184 簿记在途+INDEX 2 个未完成任务在册——side/global 指针并行竞态已知；本任务 side 指针隔离） |
| `isolation` | `worktree`（技能文件保护区，§十一） |
| `worktree_path` | `/mnt/data/dev/task-planner-skill-worktrees/task-v186-understanding-mirror` |
| `branch` | `wt/task-v186-understanding-mirror` |
| `merge_back` | `pending` |

## 📊 FMEA 预演

| Phase | 失败模式 | S | O | D | RPN | 兜底 |
|-------|---------|---|---|---|-----|------|
| Phase 2 | 模板锚被破坏触发 SL-01..11 FAIL | 5 | 3 | 2 | 30 | 断裂锚最小修复/回炉改派；>3 处 STOP |
| Phase 4 | 合并冲突（并行会话） | 7 | 3 | 3 | 63 | 主仓脏→STOP 排队（Rule 88.4） |

## 🔁 原生 Todo 同步

| Phase | Todo 已建 | 最近同步 | 备注 |
|-------|-----------|---------|------|
| Phase 1-5 | ☑ | 2026-10-17 | S1 完成 |

## Key Questions

1. 落点为何是子条 80.7 而非新 Rule 93？→ 机制辖域=Rule 80（用户会话记录专档），子条增补零编号级联（19.8 增补判例）；新 Rule 会触发 1-93 全集级联与核心/卫星归属争议
2. 镜像为何放同文件而非独立专档？→ 独立第 8 计划文件需动 init 建档/门控/selftest 三处机械面（blast radius 大）；同文件配对块保持 80.4 权威序且回溯时逐字/理解同屏对照
3. SL-01..11 会否断裂？→ 全部正向锚（80.1-80.6/模板三关键词/条目格式/恢复协议）不受增量影响；SL-08 负断言（指针区块无可变计数）——新增行为静态说明行不含计数词；以 S3 实跑为准

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| 计划推进重锁 #N | （状态翻转时随翻转登记，Rule 20.1 授权路径） |
| silent: 落点=Rule 80 子条 80.7 | 辖域一致+零编号级联+零新键；对齐 19.8 增补判例 |
| silent: 镜像=同文件配对块（非独立第 8 文件） | 机械面 blast radius 最小（init/门控/selftest 零改动）；80.4 权威序天然保持（同文件内逐字面>镜像面）；回溯同屏对照 |
| silent: 镜像=非权威对照面+append-only 更正块 | 用户目的=回溯对照定位偏差（非改写需求）；理解演进留痕对齐 80.2 只写不改精神 |
| silent: L0-T 零新增守护 | §四.6+Rule 38.7；SL 断言面不扩（机器化 opt-in） |
| silent: 交互模式 silent | 自主会话；授权锚=专档 #1 配对条目 |
| 全局指针竞态已知态 | task-v184 簿记在途（开场 TAMPERED 告警同源）；本任务 side 指针隔离，不碰他域 |

## Errors Encountered

| Error | Attempt | Resolution | Prevention |
|-------|---------|------------|------------|
| （暂无） | 1 | - | - |

## Notes

- Update phase status as you progress: pending → in_progress → complete
- Re-read this plan before major decisions
- Log ALL errors

## 🚨 Drift Log

| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| （Phase 2 后派发 drift-checker 时追加） | | | |

## 📊 委派统计（终验前必填）

| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 3 / 5（Phase 2 executor、Phase 3 code-runner、Phase 5 Verifier） |
| 主进程直做 Phase 清单 | Phase 1（①②）、Phase 4（①）、Phase 5 簿记（②）——白名单内 |
| 委派率 | stats 实跑为准（预期 verdict=ok，v185 判例同口径） |

## 🔗 Subagent Handoff 登记表

| # | 时间 | subagent_type | 任务目标 | 状态 | 结论摘要 | 证据 | findings 落点 | checkpoint 路径 | 备注 |
|---|------|--------------|---------|------|---------|------|--------------|----------------|------|
| 1 | | executor | S1 80.7+SKILL 指针 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/2-s1-executor.md | - / 0 / ☐ |
| 2 | | executor | S2 两模板配对格式 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/2-s2-executor.md | - / 0 / ☐ |
| 3 | | code-runner-agent | S3 全量回归 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/3-s3-code-runner-agent.md | - / 0 / ☐ |
| 4 | | drift-checker | Phase 2 偏移检查 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/2-drift-checker.md | - / 0 / ☐ |
| 5 | | Code Reviewer | CR 门单轮 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/5-code-reviewer.md | - / 0 / ☐ |
| 6 | | Verifier | S4 独立复验 | queued | | | | plans/task-v186-understanding-mirror/subagent-state/5-s4-verifier.md | - / 0 / ☐ |

## 🔁 模板感知

- 触发信号: general 兜底；预登记「不沉淀」——纯子条增补无新模板信号（终验确认）
