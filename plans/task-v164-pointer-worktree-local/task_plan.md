<!-- template_type: general -->
<!-- 适用场景: 技能运行态状态治理——把 git 跟踪的瞬态指针文件改为工作树内瞬态文件（untracked+gitignore）+ 引用面措辞级联 + selftest 回归 + 合并规则登记 -->
<!-- 触发关键词: 指针/active_plan/瞬态状态文件/gitignore/并行互顶/合并冲突/工作树本地化 -->
<!-- 推荐 subagent: executor(sonnet-1) 做 git 索引变更与措辞级联; code-runner-agent 跑 selftest; code-reviewer 终审; 合并部署主进程 -->
<!-- 沉淀出处: plans/fix-pointer-race-20261007（指针机制第二轮修复先例：side 层 2026-10-07 已下沉权威，本任务收口全局层跟踪态） -->

# Task Plan: 活跃计划全局指针瞬态化与工作树内本地化（active_plan untracked）

## 🎯 用户需求原文（Rule 51.1 — 逐条抄录，禁转译/缩写/合并）
<!-- 2026-10-05 task-v131：Rule 51.1 计划侧载体（审计 H-3 清账）。R 行=用户原话逐条编号抄录（语音转写保真，含口语赘余，禁润色）；映射=每条核心需求 ≥1 VC；缺区块或缺映射=计划无效先回炉（51.1/51.2） -->

- **R1** [手段]: 「既然已经有基于工作数这个隔离机制了，那么就可以经过那个就可以使用那些使用使用在工作数上，然后使用状态文件在存在工作数内。那这么这样的话不就做到了就是针对当前任务当前任务执行整个过程中的那个什么那个状态，都是保留在嗯对应的工作目录下吗？」
- **R2** [目标]: 「我要说的就是当前的工作存在严重的问题，就是当前技能在执行的还是那个指针问题，依旧存在着混乱的情况，依旧存在着总是被在并行过程中总是被无端地切换来回切换来切换去。」
- **R3** [手段]: 「为什么不将这个指针存放于存放于，就是因为我是使用的工作数，工作数的话，为什么不存放在工作数的相应的文件下？然后这样的话切换来切换去的话，在工作数内应该是不会变的。」
- **R4** [手段]: 「啊，这样意味着，就是说，呃，以后合并的时候，只需要合并的时候注意掉忽略掉这个文件就可以了，忽略掉这个状态临时文件就可以了。」
- **R5** [实证，用户贴出 v163 执行会话实录为证]:
  - R5a: 「你看，这就是下面在执行会话的时候，我只是让它继续执行文啊，继续继续执行，然后它的那个指针就发生了变化。」
  - R5b: 「指针侧已归位但全局指针仍是已完成的 v152——先移交全局指针到 v163，然后撰写完整计划。」
  - R5c 终端命令: `bash ~/.zcode/skills/task-planner/scripts/set-active-plan.sh set task-v163-proactive-research 2>&1 | tail -2 && cat plans/.active_plan && echo "---" && bash ~/.zcode/skills/task-planner/scripts/resolve-plan-dir.sh /mnt/data/dev/task-planner-skill | tail -1`
  - R5d 思考碎片: 「持续了 104 秒 / 现在撰写 v163 完整计划（R1-R14 逐字归档 + VC + Phase 0-6 +」（录入时被截断）

### R→VC 映射（Rule 51.2 验证机制先行）
| R | 映射 VC | 覆盖判据（可观察证据形态） |
|---|---------|---------------------------|
| R1 | VC-1, VC-2 | 状态文件瞬态化（untracked+gitignore）+ 双 worktree 行为实跑输出 |
| R2 | VC-2, VC-3 | 并行不互顶实跑 + "移交"叙事从措辞面退役（grep 无旧语义） |
| R3 | VC-1 | `git ls-files plans/.active_plan` 空 + `.gitignore` 命中条目 |
| R4 | VC-1, VC-4 | 合并零冲突（瞬态文件不入库）+ 飞行 worktree 合并规则登记 |
| R5 | VC-3, VC-4 | 引用面级联完成 + selftest 全量 0 FAIL |

<!-- plan_tier: standard -->

## 🧮 根源覆盖表（Rule 53.1 — 结果级需求全链工序审计）
<!-- 结果级需求（R2「并行指针不再混乱」）按生产管线逐工序审计缺陷面 -->

| 工序 | 缺陷面 | 修复点 | VC |
|------|--------|--------|-----|
| 指针写入（set-active-plan） | `.active_plan` 被 git 跟踪 → 每次"移交/指认"产生 chore 提交与 status dirty（git log 实证 8 次：f6d6158/de3c19f/21f7e6b/ee978a1/55c24fc/76168cb/26f938c/26878fe 同例连发） | Phase 2 S1：git rm --cached + .gitignore | VC-1 |
| 并行解析（resolve-plan-dir） | 主树内多会话共享该树唯一全局指针；legacy"移交全局指针"语义造成可见漂移（R5b 实证：全局仍指已完成 v152→被移交 v163） | Phase 2 S2：头注释退役"移交"叙事；side 优先链语义冻结（2026-10-07 已下沉权威） | VC-2, VC-3 |
| 合并回（smart-merge-back） | 飞行 worktree（v156/v160/v161）分支携带 tracked `.active_plan`，删除态合并可能冲突 | Phase 5：瞬态文件合并规则登记（冲突取删除态，指针由会话 set 再生） | VC-4 |
| 新建隔离区（worktree add） | 新 worktree 无全局指针 → mtime 兜底竞态（本改动副作用） | Phase 4 VC-2 行为验证 + 必要时 init 时 seed（备选，默认不改） | VC-2 |

## 🔍 证据面清单（Rule 58.1 — 调研/分析/评估/归因类任务计划期必填）
<!-- 本任务产出=机制变更，但归因（指针为何混乱）已第一手完成，三面如实登记 -->
| 证据面 | 取证对象（可指名） | 取证方式 | 落盘锚（54.5 格式） | 状态 |
|--------|------------------|---------|---------------------|------|
| ① 自身样本 | set-active-plan.sh 全文 268 行 + resolve-plan-dir.sh 全文 130 行 + .active_plan_side 8 个会话指针 + git log/`.gitignore` | Read + git 命令一手实跑 | findings.md Research Findings A-D；`skills/task-planner/scripts/resolve-plan-dir.sh:58-105` | ☑ |
| ② 对标样本（58.2） | 上一轮指针修复先例 plans/fix-pointer-race-20261007/ + 兄弟瞬态文件 ignore 范式 | Read 计划目录 + .gitignore:1-10 | findings.md Research Findings D/E | ☑ |
| ③ 外部约束 | 仓根 .gitignore 不随技能部署分发（三部署位 diff 不含它）；git 索引语义（rm --cached 保留工作区文件） | 部署拓扑记忆 + git 文档既有认知 | findings.md Technical Decisions D1 | ☑ |

> 归因结论（全局层 churn 根因=跟踪态+移交叙事，side 层已被 2026-10-07 修复保护）已在 ① 完成后产出，无 ② 未完成面。

## 🎯 核心目标达成裁决（Rule 58.5 — 含目标型需求([目标]标注)的任务终验必填)
| 字段 | 值 |
|------|-----|
| **目标型需求** | R2（R3 含目标语义） |
| **裁决** | ☐ pending（终验填 solved / partial / not-solved） |
| **解决证据锚** | （终验填：VC-2 行为验证输出 + VC-3 级联 grep） |
| **未解决面+原因** | （partial/not-solved 必填） |
| **已排除路径** | （not-solved 必填） |
| **下一步建议** | （not-solved 必填） |

## Goal
将 `plans/.active_plan` 全局指针从 git 跟踪文件改为工作树内瞬态状态文件（`git rm --cached` + `.gitignore` 追加条目，工作区文件保留），与 `.active_plan_side/`/`.plan_required_side/`/`.drift-rhythm/` 同族归一——指针路径本就随 `$PWD` 工作树本地化（set-active-plan.sh:69,84-85），瞬态化后跨工作树零共享、合并零冲突、git churn 止息；同步 28 文件引用面措辞级联（退役"移交"叙事）、selftest 全量回归 0 FAIL、飞行 worktree 合并规则登记，最终合并回 master 并同步部署位（注：.gitignore 为仓根文件不随部署）。

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本头注释 + git 索引语义变更） |
| `对齐审查` | `[登记]` Rule 42.6 消费：完成前跑 alignment-review；变更记录随交付落盘 |
| `自动超时默认项` | `[询问点]` Rule 44 消费：默认项=推进；CR 意见响应超时 5 分钟按 44.3 自动裁决登记 |
| `质量审查工具` | `code-reviewer`（sonnet-1）+ alignment-review；Rule 42.2 四级检测登记 |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | 瞬态化落地：`git ls-files plans/.active_plan` 输出为空 + `.gitignore` 含 `plans/.active_plan` + 主树 legacy set 后 `git status --short` 无该文件条目 | `git ls-files --error-unmatch` 反验 + grep .gitignore + 实跑 set-active-plan legacy 模式 | progress.md 行为验证段（命令+输出） |
| VC-2 | 工作树本地化+并行不互顶：两个隔离 worktree 分别 set 指针互不感知；新 worktree 无全局指针时 `resolve-plan-dir.sh` 的 side→mtime 链 exit 0 且 slug 正确 | 建 2 个临时 worktree 双 root 实跑 resolve 对比 | progress.md 行为验证段 |
| VC-3 | 级联无残留：引用面（28 文件/166 hits）中描述全局指针"入库/跟踪"的措辞全部改述，grep 无旧语义残留；只读消费方逐个登记 | `grep -rn 'active_plan' skills/task-planner/` + 逐文件判定记录 | findings.md 级联清单 |
| VC-4 | 全量 selftest 0 FAIL（**主进程逐 Total 行求和，禁采信自报**；重点 selftest-active-plan.sh / selftest-pointer-lifecycle.sh）+ 飞行 worktree 合并规则登记 critical-rules | `for f in selftest-*.sh` 逐个跑求和 | progress.md Selftest Log + critical-rules.md 合并规则段 |
| VC-5 | 部署簿记：INDEX（执行期登记）/ledger/CHANGELOG 更新 + 部署位 diff 对账（.gitignore 不随部署=预期差） | smart-merge-back --deploy 对账 | 部署输出 + INDEX.md |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## 🎯 Goal 单元表（Rule 66.1 — 规划获批后任务单元固化；standard/full 必填，mini 档豁免）
| goal-id | 任务名 | 目标（≤1 句） | 完整验证方式（可复现） | 对应 S-unit/Phase | 状态 |
|---------|--------|--------------|------------------------|------------------|------|
| G1 | 隔离基线 | worktree 建立+变更前 selftest 基线+先例复读 | baseline-selftest.log 逐脚本 rc/Total 在主进程求和记录 + `git worktree list` 含 wt/v164-pointer-worktree-local | Phase 1/S1 | complete（2026-10-10 15:2x：71/71 rc=0+FF master 79cd10a） |
| G2 | 指针瞬态化 | .active_plan untracked+gitignore+头注释退役移交叙事 | VC-1 命令级判定（ls-files 空/ignore 命中/status 无 M）+ diff 只见注释区 | Phase 2/S2-S3 | pending |
| G3 | 级联完成 | 28 文件引用面旧语义零残留 | VC-3：grep 无旧语义 + findings 级联清单 28 行判定 | Phase 3/S4-S7 | pending |
| G4 | 独立验证 | 回归零新增 FAIL+双树行为验证+CR APPROVED | VC-2 行为输出 + VC-4 主进程求和=0 新增 + CR 结论行 | Phase 4/S8-S10 | pending |
| G5 | 交付合并 | 合并回 master+部署对账+簿记+规则登记 | smart-merge-back no-ff 对账+INDEX/ledger/CHANGELOG+check-complete exit 0 | Phase 5 | pending |

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| git 状态 | `plans/.active_plan`（仅 `git rm --cached`，工作区文件保留为瞬态文件）、仓根 `.gitignore`（追加 1 行） | 删除工作区文件本身；动 .gitignore 其他规则 |
| 脚本注释 | `skills/task-planner/scripts/set-active-plan.sh`、`resolve-plan-dir.sh`（头注释区语义改述） | 改解析链逻辑/参数/写函数/gc 行为（语义冻结） |
| 文档 | `references/critical-rules.md`（指针相关段+合并规则登记）、`SKILL.md`、`README.md`、`INSTALL.md`、`CHANGELOG.md`（仅追加 v164 条目） | 改其他规则语义；顺手修其他脏点 |
| selftest | `selftest-active-plan.sh`、`selftest-pointer-lifecycle.sh`（断言适配）+ 全量回归 | 删既有断言（除因瞬态化失效的跟踪态断言） |
| 计划 | `plans/task-v164-pointer-worktree-local/**`、`plans/INDEX.md` | 其他计划目录内容 |

**强制约束**:
- 纯增量零删除（36.3 删除基线登记：唯一"删除"= `git rm --cached` 索引态变更，工作区瞬态文件保留，非内容删除）
- 引用面级联逐文件人工判定，**禁 grep+sed 批量替换**（166 hits 跨 28 文件，多数为只读消费方）
- 解析链顺序（side→global→mtime→legacy）语义冻结，本任务只改跟踪态与措辞
- `.gitignore` 为仓根文件，**不随技能部署分发**（三部署位 diff 不含它，VC-5 预期差须登记）
- 合并规则：master 删除 tracked `.active_plan` 后，飞行 worktree（v156/v160/v161）合并回时该文件冲突=按瞬态处置（取删除态，指针由各会话 set 再生）

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
| Phase | 命中工具面（40.1 六类） | 选择理由 |
|-------|----------------------|---------|
| Phase 1 | 主进程（白名单① git/worktree 编排）+ code-runner-agent | worktree 建立+全量 selftest 基线求和+引用面清单化 |
| Phase 2 | Agent 子代理 executor（sonnet-1） | S2 git 索引瞬态化+S3 头注释改述（各 ≤2 文件硬限制内） |
| Phase 3 | Agent 子代理 executor（sonnet-1） | S4-S7 引用面分级+措辞级联（每次派发 ≤2 文件，禁批替换） |
| Phase 4 | code-runner-agent（mini）+ code-reviewer（sonnet-1） | 全量回归+并行行为验证（Rule 33.3 独立验证）+全量 CR |
| Phase 5 | 主进程（白名单①②） | smart-merge-back --deploy+INDEX/ledger+worktree 清理 |

**workflow 编排判定（Rule 40.4）**: 未命中编排条件（S1-S3 串行依赖：S3 依赖 S1 的索引态与 S2 的语义定稿；无独立子任务 fan-out；用户未点名 /workflow）→ 按 Rule 21.4 声明制串行调度，未声明 `parallel_groups`。

**/goal 对齐（Rule 40.3）**: 本计划 Goal+VC 即 session goal 证据源；用户未使用 /goal，不涉映射供料。

## Phases
<!-- Executor 字段(Rule 25.1)：主进程直做必须写白名单例外理由；Executor≠主进程的 Phase 必附 S-unit 表(22.6)；check-plan-dispatch.sh 在计划批准时校验 -->
<!-- S-unit 派发单元表(Rule 22.6 — 每行=一次 Agent() 派发；单步 ≤step_max_files(2) 文件/≤step_max_lines(100) 行/≤step_max_minutes(15) 分钟；粒度三值 Nf/Nl/Nmin 逐行校验；Rule 46.1 单会话单 S-unit) -->

### Phase 1: 隔离与基线
- 按宪法 §十一 建 worktree（`wt/v164-pointer-worktree-local`，集中目录 /mnt/data/dev/task-planner-skill-worktrees/ 下）+ **worktree 初建即对账主仓 HEAD**（worktree-branch-desync 教训）
- 复读 plans/fix-pointer-race-20261007/（上一轮修复先例，禁重复设计）
- master 16 提交快进合并（79cd10a，S5 scope 重叠面预防：v160 Rule 72 改过 SKILL/critical-rules）
- **Status:** complete（2026-10-10 15:2x；S1 基线 71/71 rc=0 FAIL=0 经主进程复核）
- **V-N:** VC-4 前置（基线=零增量对照锚）+ VC-2 前置（双树验证的树 A）
- **Executor:** 主进程（白名单① git/worktree 编排）+ code-runner-agent（S1 基线跑批）

| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 | 前置依赖 |
|----|------------|------------------------|-------------|---------|------|------|------|------|---------|
| S1 | worktree 内全量 selftest 基线跑批（master HEAD 态=变更前基线），逐脚本 rc 与 Total 行落 baseline-selftest.log | code-runner-agent（mini） | ① worktree 根（=master HEAD 态）② skills/task-planner/scripts/selftest-*.sh 全集 | baseline-selftest.log 含逐脚本 rc 与 Total 行原文（主进程据以求和，禁自报汇总） | 15min | 0f/0l/15min | 无 | pending | - |

### Phase 2: 指针瞬态化（git 索引 + 头注释）
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 | 前置依赖 |
|----|------------|------------------------|-------------|---------|------|------|------|------|---------|
| S2 | `plans/.active_plan` 改瞬态：`git rm --cached` + `.gitignore` 追加 `plans/.active_plan`（工作区文件保留） | executor（sonnet-1） | ① findings.md A-D 节 ② 仓根 `.gitignore`:1-10 ③ worktree 绝对路径 | VC-1 命令级判定全过（ls-files 空/ignore 命中/legacy set 后 status 无 M）+ 工作区文件仍在 | 10min | 1f/1l/10min | 无 | pending | S1 基线后 |
| S3 | set-active-plan.sh + resolve-plan-dir.sh 头注释改述：全局指针="工作树内瞬态 fallback"，退役"移交"叙事 | executor（sonnet-1） | ① set-active-plan.sh:1-21 ② resolve-plan-dir.sh:1-27（knowledge-brief.md §3 由派发模板自动注入） | 头注释无"移交/入库"旧语义 + git diff 只见注释区 + `bash -n` 双通过 | 10min | 2f/20l/10min | 无 | pending | S2 后 |

- **Executor:** executor（sonnet-1）

### Phase 3: 引用面措辞级联
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 | 前置依赖 |
|----|------------|------------------------|-------------|---------|------|------|------|------|---------|
| S4 | 28 文件引用面逐个判定分级（只读消费方/措辞更新方），级联清单落 findings.md | executor（sonnet-1） | ① `grep -rn 'active_plan' skills/task-planner/` 输出 ② findings.md E 节 | findings.md 级联清单=28 文件逐个判定（只读/更新+一行理由） | 12min | 1f/30l/12min | 无 | pending | S3 后 |
| S5 | critical-rules.md 指针相关段措辞改述 + 瞬态文件合并规则登记段（按 S4 清单） | executor（sonnet-1） | ① S4 级联清单 ② knowledge-brief.md §3 锚（critical-rules 指针段行号实施日重测） | 无"入库/跟踪"旧语义；合并规则段在位；git diff 仅清单内行 | 12min | 1f/35l/12min | 无 | pending | S4 后 |
| S6 | README.md + INSTALL.md 措辞改述（按 S4 清单） | executor（sonnet-1） | ① S4 级联清单 ② knowledge-brief.md §3 锚 | 两文件无旧语义；git diff 仅清单内行 | 10min | 2f/20l/10min | 无 | pending | S5 后 |
| S7 | selftest-active-plan.sh + selftest-pointer-lifecycle.sh 注释/断言适配（按 S4 清单；禁删既有断言） | executor（sonnet-1） | ① S4 级联清单 ② 两 selftest 全文 | 断言逻辑零删（除瞬态化失效的跟踪态断言）；`bash -n` 通过 | 10min | 2f/20l/10min | 无 | pending | S6 后 |

- **Executor:** executor（sonnet-1）

### Phase 4: 全量回归 + 行为验证 + CR
| ID | 目标(≤1 句) | 执行体(subagent_type(model)) | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 粒度(三值) | 伴飞技能 | 状态 | 前置依赖 |
|----|------------|------------------------|-------------|---------|------|------|------|------|---------|
| S8 | 变更后态全量 selftest 回归跑批，逐脚本 rc/Total 落 regression-worktree.log | code-runner-agent（mini） | ① worktree（S2-S7 已落）② baseline-selftest.log 对照 | 主进程求和：新增 FAIL=0（对照基线既有 FAIL 清单分类） | 12min | 0f/0l/12min | 无 | pending | S5-S7 后 |
| S9 | 双 worktree 并行行为验证（VC-2）：两树分别 set 指针互不感知 + 新树无全局指针时 side→mtime 链 exit 0 | code-runner-agent（mini） | ① 主进程给定验证命令原文（worktree add ×2 + set/resolve 对比）② worktree | 行为验证输出（两树 resolve 各自正确 slug + 新树链正常） | 10min | 0f/0l/10min | 无 | pending | S8 后 |
| S10 | code-reviewer 全量 CR：worktree 变更 diff 审查（scope 符合性+删除基线 36.3） | code-reviewer（sonnet-1） | ① worktree `git diff master...HEAD` ② 执行范围限制表 | CR 结论=APPROVED（或意见闭环后复验通过） | 12min | 0f/0l/12min | 无 | pending | S8/S9 后 |

- **Executor:** code-runner-agent（mini）+ code-reviewer（sonnet-1）

### Phase 5: 合并回 + 部署 + 簿记
- smart-merge-back --deploy 部署位对账（.gitignore 不随部署=预期差登记）+ INDEX/ledger/CHANGELOG v164 条目 + worktree 清理
- **Executor:** 主进程（白名单①②）

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | 指针机制两脚本全文 | skills/task-planner/scripts/set-active-plan.sh + resolve-plan-dir.sh | ☑（本轮已读，anchors 落 knowledge-brief §3） |
| 项目内部 | 上一轮指针修复先例 | plans/fix-pointer-race-20261007/ | ☐（Phase 1 复读） |
| 项目内部 | 兄弟瞬态 ignore 范式 | 仓根 .gitignore:1-10 | ☑ |
| 项目内部 | selftest 范式 | scripts/selftest-active-plan.sh + selftest-pointer-lifecycle.sh | ☐（Phase 1 复读） |
| 项目内部 | worktree 隔离 SOP | skills/task-planner/references/worktree-isolation.md | ☐（Phase 1 复读） |
| 项目内部 | 台账供料简报 | plans/task-v164-pointer-worktree-local/knowledge-brief.md §2/§3 | ☑ |

## 📊 FMEA 预演

| Phase | 失效模式 | 局部影响 | 检出手段 | 根因面 | RPN | 预设兜底动作 |
|-------|---------|---------|---------|--------|-----|------------|
| Phase 4 | 新 worktree 无全局指针 → mtime 兜底竞态解析错计划 | 新会话拿错计划注入 | VC-2 双 worktree 行为验证 | 瞬态化副作用 | 120 | 行为验证必覆盖；必要时 init 时 seed 全局指针（备选，默认不改） |
| Phase 5 | 飞行 worktree（v156/v160/v161）合并回时 `.active_plan` 删除态冲突 | 合并被阻断/抢指针值 | Phase 1 基线+合并预演 | 在途分支携带 tracked 文件 | 90 | 瞬态处置规则：冲突取删除态，指针由各会话 set 再生（VC-4 登记 critical-rules） |
| Phase 3 | 引用面 grep+sed 批量替换误伤只读消费方 | hooks/check 读指针逻辑被改坏 | 逐文件人工判定记录 | 166 hits 跨 28 文件 | 80 | 禁 sed 批量；findings.md 级联清单逐文件判定；只读方登记不改 |
| Phase 2 | S2 头注释改述误伤解析链逻辑 | resolve 行为回归 | diff 只见注释区验证 | 注释与逻辑同文件 | 72 | VC-4 selftest-active-plan/pointer-lifecycle 重点回归+git diff 人工核对 |

## 🚨 Drift Log（漂移检测记录）
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
| 2026-10-10 15:2x | Phase 1 收口自检（drift-rhythm due=0 未到 hook 提醒阈值，按 64.2 主动自检）：原目标=.active_plan 瞬态化全链 vs 当前步=Phase 1 隔离基线全部达成； master 快进=防 S5 撞车的预防动作不改目标；R1-R5 范围零蔓延 | 全 VC | ALIGNED |

## Current Phase
<!-- WHAT: Which phase you're currently working on. WHY: Quick reference. -->
2（in_progress：Phase 1 complete，S2 索引瞬态化派发中）

## Next Step
<!-- WHAT: 单一下一步动作。WHEN: Phase 状态每次变更时同步刷新。 -->
派发 S2（executor，sonnet-1）：git rm --cached plans/.active_plan + .gitignore 追加瞬态条目（材料 subagent-state/2-prompt-material.md，checkpoint 2-executor.md）

## Decisions
| 时间 | 决策 | 理由 |
|------|------|------|
| 2026-10-10 11:3x | D 类新任务判定（Rule 8.1）：用户指针反馈与 v152（Rule 67，已 COMPLETE）及 v163（调研诚实性 R1-R14）目标均无关联 → 开新计划 task-v164-pointer-worktree-local 独立承载，R1-R5 逐字归档；v152/v163 不收编 | 用户原话五连发（状态入工作数/指针严重混乱/为何不存工作数/合并时忽略状态文件/执行会话实证）；03:3x D 类分立先例 |
| 2026-10-10 11:3x | 方案比选：采纳 D1（untracked+gitignore，语义改述为工作树内瞬态 fallback）；不取 D2（保留跟踪+合并约定）；否决 D3（删全局只留 side+mtime） | git log 实证 8 次 churn chore；.gitignore:3-9 兄弟瞬态范式在先；R4 用户明示"合并时忽略该文件"；D3 破坏 cron/sid-less legacy 消费者（set-active-plan.sh:3） |
| 2026-10-10 11:3x | 路径本地化纠正：用户"指针存工作数内"的路径诉求是既成事实（ROOT=$PWD），真缺陷=git 跟踪态+移交叙事 → 方案聚焦瞬态化而非路径改造 | set-active-plan.sh:69,84-85 + resolve-plan-dir.sh:30 一手实证；避免不必要的大改 |

## 📊 委派统计（Rule 25.4 — 终验前必填）
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 | 0 / 5（计划期） |
| 主进程直做 Phase 清单 | Phase 1（白名单① git/worktree 编排）+ Phase 5（白名单①②簿记） |
| 委派率 | （终验由 check-delegation.sh stats 定数） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
