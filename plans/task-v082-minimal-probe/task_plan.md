<!-- template_type: rule-enhancement -->
<!-- 沉淀出处: task-v074（Rule 34.3① 同类任务续用）; 本轮 task-v082 实例化 -->

# Task Plan: task-v082 最小探针原则（Rule 35 族增补 — 验证动作最小化）

## Goal
落地「最小探针原则」：验证/查证类动作（测试 bash 可用、工具可达、接口连通等）默认用最小代价探针（如 `echo ok` 一条输出测试），禁止一上来写复杂测试脚本或搭完整验证环境——复杂化仅在有具体怀疑点时升级。落点 = critical-rules.md Rule 35 族新增 35.6（原 35.6 机制重编号 35.7）+ SKILL.md 两处行内联动 + selftest-conclusion-discipline.sh 锚点联动 + 仓库根 CHANGELOG 条目；全量 selftest 0 FAIL 后合并回 master、部署 3 实体位并 push。

## ⚙️ 计划配置
| 键 | 值 |
|----|-----|
| template_type | rule-enhancement |
| chain_mode | single |
| interaction_mode | silent（自主环境+用户显式指令在案+v079/v081 先例；交付报告附静默决策清单） |
| git_commit | per-phase（Rule 27，禁攒批） |
| reflect_verify | required |

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `required`（改动含 .sh 脚本：selftest-conclusion-discipline.sh） |

## ✅ Verification Contract

| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | critical-rules.md：35.6=最小探针原则条款（含最小输出探针示例与「默认最小、升级需怀疑点」纪律）；35.7=机制（原 35.6 文本重编号，内容零改动）；git diff 对照 P1 基线证实除该行外零删除零改写 | Read + grep 双锚 + git diff | findings.md/progress.md |
| VC-2 | SKILL.md：C23 行与 Rule 35 摘要行（≈L305）各含「最小探针」引用；两处均行内原位改，`wc -l` 仍=543（净增 0，不触 ≤548 断言） | grep + wc -l | progress.md P2 段 |
| VC-3 | selftest-conclusion-discipline.sh：CD-02~07 头注记改 35.1-35.7；CD-07 改双锚（`^35.6 ` 最小探针 + `^35.7 ` 机制）；新增 CD-24「最小探针」在位断言；本文件全 PASS | 脚本实跑 | progress.md Selftest Log |
| VC-4 | worktree 全量 selftest 0 FAIL 且合并后 master 全量 0 FAIL（**总数=主进程逐 Total 行求和，禁采信子代理自报**） | for f in selftest-*.sh 求和 | progress.md Selftest Log |
| VC-5 | 仓库根 CHANGELOG.md 条目在位（含最小探针原则一句摘要） | Read | CHANGELOG.md |
| VC-6 | 3 实体位（~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner）diff -r IDENTICAL；origin/master push 完成；worktree/分支已清理 | 主进程 diff -r 亲验 + git 实查 | 终验输出 |

**终验规则**: 全部 VC 通过 → COMPLETE；回归 FAIL 无法定位 → 记录后 PARTIAL；证据不实 → BLOCKED

## ⚠️ 执行范围限制

| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 条款 | `skills/task-planner/references/critical-rules.md`（Rule 35 族：插入 35.6 + 原 35.6 重编号 35.7，仅此） | 其他 Rule/条款语义 |
| SKILL | `skills/task-planner/SKILL.md`（C23 行 + Rule 35 摘要行两处行内原位改，净增 0） | 大段新增/其他行 |
| selftest | `skills/task-planner/scripts/selftest-conclusion-discipline.sh`（头注记+CD-07 双锚+新增 CD-24） | 其他 selftest |
| 文档 | 仓库根 `CHANGELOG.md`（追加条目） | 其他文档 |
| 计划文件 | `plans/task-v082-minimal-probe/` 三件套+knowledge-brief | 其他 plans/ 目录 |

**强制约束**:
- **不新增 Rule 编号、不动 "Rules 1-N" 字样** → 无锚定级联；35.6→35.7 属锚点级联机械联动（Rule 36.1 明文不算功能删除，登记即可）
- SKILL.md 净增 0 行 → 两处行数断言（skill-collab:81 / execution-stability:72，现值 ≤548）不扩围
- Rule 36 合规：纯增量+编号级联（36.5），P1 建删除基线快照，终验 git diff 对照证实零语义删除（C24）
- **plans/task-v081-fine-grain-step-gate/ 与 worktrees/task-v081-* 属并行会话活跃任务，全程禁碰**（含不清理、不重锁其 attestation）
- 派发契约：prompt 必含计划三文件绝对路径 + status:/acceptance:/checkpoint: 等 8 字段标签（check-dispatch.sh 逐字校验）

## 📊 FMEA 预演

| # | Phase | 失败模式 | 严重度 | 发生度 | 检出度 | RPN | 预设兜底动作 |
|---|-------|---------|--------|--------|--------|-----|--------------|
| R-1 | P3 | CD-07 锚随 35.6→35.7 重编号联动漏改 → CD selftest FAIL | 6 | 4 | 2 | 48 | P3 第一步即改 CD；全量回归二分定位，fix ≤3 轮 |
| R-2 | P2/P3 | code-assistant(haiku-1) 环境不可启动（v081 同因 reasoning-level-missing） | 6 | 5 | 2 | 60 | Rule 22.3④ 主进程逐文件接管（≤300 行/文件，25.3⑤ 登记，WHITELIST-EXEMPT 口径，预登记） |
| R-3 | P5 | v081 并行会话先合并 → CHANGELOG/合并竞态冲突 | 6 | 3 | 3 | 54 | smart-merge-back 预检兜底；冲突则 rebase 本分支重跑全量再合并；合并后 master 全量重跑（不采信 worktree 期结果） |

## 🔀 隔离决策
| 项 | 值 |
|----|-----|
| isolation | worktree（默认首选：本仓为运行中基础设施，§六/§十一 保护区） |
| worktree 路径 | /mnt/data/dev/task-planner-skill-worktrees/task-v082-minimal-probe |
| 分支 | wt/task-v082-minimal-probe（基于 master=34c3959） |
| CWD 约定 | 计划文档留主仓 plans/；实现全部走 worktree 绝对路径 |

## Phases

### Phase 1: 隔离与基线 — **Status: complete**（2026-09-18 01:1x，基点=c10e8f2+v081 已先行合并，基线快照+366/0，证据=progress.md P1 段）
- **Status:** complete
- worktree 建立 + 删除基线快照（改动面 4 文件 cp 到 subagent-state/baseline/）+ SKILL.md 行数基线（预期 543）+ 全量 selftest 基线求和 + CD-02~07 现状取证
- **Executor:** 主进程（白名单① git 编排 + ② 计划系统文件 + ③ 机械验证命令）

### Phase 2: 条款与 SKILL 文本 — **Status: complete**（2026-09-18 01:1x，commit b8622ca，haiku-1 首败即 22.3④ 接管，证据=progress.md P2 段）
- **Status:** complete
- **Executor:** code-assistant(haiku-1)；启动失败 → Rule 22.3④ 主进程接管（白名单⑤，预登记，见 Decisions ④/FMEA R-2）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| 1 | critical-rules.md：插 35.6 最小探针原则 + 原 35.6 重编号 35.7 | code-assistant(haiku-1) | skills/task-planner/references/critical-rules.md（Rule 35 段 294-299 行；条款文本见 knowledge-brief §4 材料包） | grep 双锚在位；diff 除 35.6/35.7 两行外零变动 | 10min | pending |
| 2 | SKILL.md：C23 行 + Rule 35 摘要行两处行内并入「最小探针」 | code-assistant(haiku-1) | skills/task-planner/SKILL.md（197 行 C23 / 305 行摘要行；并入文案见 knowledge-brief §4） | grep 两处含「最小探针」；wc -l=543 | 10min | pending |

### Phase 3: 守护与文档 — **Status: complete**（2026-09-18 01:2x，commit b9ba09a，CD 24/0+CD-25 撞号避让，证据=progress.md P3 段）
- **Status:** complete
- **Executor:** code-assistant(haiku-1)；启动失败 → Rule 22.3④ 主进程接管（同上预登记）

| ID | 目标(≤1 句) | 执行体 | 输入(路径 + ≤10 行摘要) | 验收(可观察) | 预估时长 | 状态 |
|----|------------|--------|-------------|---------|------|------|
| 3 | selftest-conclusion-discipline.sh：头注记 35.1-35.7 + CD-07 双锚 + 新增 CD-24 | code-assistant(haiku-1) | skills/task-planner/scripts/selftest-conclusion-discipline.sh（5 行 CD-02~07 注记 / 52 行 CD-07 / 末尾断言区） | 本文件实跑全 PASS | 10min | pending |
| 4 | 仓库根 CHANGELOG.md 追加条目 | code-assistant(haiku-1) | CHANGELOG.md（头部格式照 v080 条目） | grep 条目在位 | 5min | pending |

### Phase 4: 全量回归 + Code Review — **Status: complete**（2026-09-18 01:3x，全量 367/0，Explore×2 降级后主进程 CR APPROVED，证据=progress.md P4 段+CR-review.md）
- **Status:** complete
- worktree 全量 selftest（逐 Total 求和）→ Code Review Gate（对照 diff 逐文件复审）→ fix（如有）已提交
- **Executor:** code-runner-agent(mini)（selftest 求和）+ code-reviewer/critic（CR）；失败降级主进程白名单③机械验证 + 主进程对照 diff 复审（预登记，v081 先例）

### Phase 5: 合并回 + 部署 + 终验 + 簿记 — **Status:** complete（2026-09-18 01:4x，merge e120331，三位 IDENTICAL 亲验×2，最终 HEAD(8fed498 含 v083) 全量 23 脚本 377/0）
- **Status:** complete
- smart-merge-back --deploy（主仓副本执行，V1-V6 全过，MERGED=e120331）→ 三部署位主进程 diff -r 亲验 IDENTICAL → master(e120331) 全量 367/0 精确口径 → push 时发现并行 v083 会话已 merge master（db7e97a 含本任务）并 push（HEAD=8fed498）→ e120331 祖先验证+改动在位抽查+三位复验 IDENTICAL → 最终 HEAD 全量 23 脚本 **377/0** → worktree+分支已清理 → check-complete 终验
- **Executor:** 主进程（白名单①②③）

## 🎯 交付结论
- **outcome: COMPLETE**（2026-09-18，VC-1..6 全过+委派统计 WHITELIST-EXEMPT，证据见 verification.md；merge_back=merged(e120331)；master HEAD=8fed498=origin（v083 并行会话已代 push，本任务内容在其祖先链）；最终全量 377/0）

## 🔗 Subagent Handoff 登记表

| 时间 | subagent_type(model) | 目标/Scope | 状态 | findings 落点 | checkpoint 路径 | verify_done |
|------|---------------------|------------|------|---------------|-----------------|-------------|
| 09-18 01:1x | code-assistant(haiku-1) | S1 critical-rules.md 35.6/35.7 | 派发失败（reasoning-level-missing）→22.3④ 主进程接管完成 | findings.md ③/progress P2 | subagent-state/S1-critical-rules.md | ☑ |
| 09-18 01:3x | Explore(mini)×2 | CR 隔离审查 | 派发失败×2（provider server error）→预登记降级主进程对照 diff 复审 APPROVED | findings.md/progress P4 | subagent-state/CR-review.md | ☑ |

## Decisions Made

| # | 决策 | 依据/时间 |
|---|------|----------|
| 1 | silent: 交互模式取 silent | 自主执行环境+用户显式指令在案+v079/v081 先例（2026-09-18） |
| 2 | silent: [PLAN TAMPERED] 判定为并行会话 v081 活跃簿记（非篡改）不处置不重锁 | v081 目录双指针认领+worktree 在册+subagent-state 23:53+progress 00:08 成对更新；本会话 sid 无关（2026-09-18 01:00 考古） |
| 3 | silent: 定名「最小探针原则」落 Rule 35 族（新 35.6，原 35.6 机制重编号 35.7） | 用户原话「最小测试原则」= 35.2 查证动作的最小代价化，同族就近；不新增 Rule 编号零级联（2026-09-18） |
| 4 | silent: 实现路由 code-assistant(haiku-1) 优先，启动失败（reasoning-level-missing 同因）即 Rule 22.3④ 主进程接管（≤300 行/文件，25.3⑤ 登记） | v081 同环境实证 sonnet/haiku 档位不可启动（2026-09-17/18） |
| 5 | silent: Rule 36 纯增量声明——新 35.6=纯新增；35.6→35.7=编号级联机械联动（36.1 明文豁免）；SKILL/CD 全部行内或锚点联动零删除 | 设计方案天然纯增量；P1 快照+终验 diff 对照（2026-09-18） |
| 6 | silent: SKILL.md 行内原位改（净增 0），行数断言两处不扩围 | 预算充足（543/548）但保持自洽最小 diff（2026-09-18） |
| 7 | silent: plan-writer 不可启动时主进程直接撰写计划与 knowledge-brief（白名单②） | v081 Decisions ③ 同因先例（2026-09-18） |

## 📚 必要知识储备

| 类别 | 名称 | 定位 | 必读 |
|------|------|------|------|
| 项目内部 | Rule 35 现行全文（35.1-35.6） | references/critical-rules.md:294-299 | ☑ |
| 项目内部 | selftest-conclusion-discipline 断言面 | scripts/selftest-conclusion-discipline.sh（CD-01~23） | ☑ |
| 项目内部 | SKILL.md C23 行 / Rule 35 摘要行 | SKILL.md:197 / :305 | ☑ |
| 项目内部 | 行数断言两处（本任务预期不触） | selftest-skill-collab.sh:81 / selftest-execution-stability.sh:72（≤548） | ☑ |
| 项目内部 | CHANGELOG 条目格式 | 仓库根 CHANGELOG.md 头部（v080 条目） | ☑ |
