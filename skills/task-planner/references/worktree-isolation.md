# 工作树隔离契约（Worktree Isolation Contract）

> **强制策略（AGENTS.md §十一 P0，2026-08-29 升格）**：实现类任务（代码/配置/基础设施/技能）**必须**在 git worktree 隔离区开发，完成后合并回原分支并清理。完整 P0 条款、必命中范围、可绕过例外、并行开发期间的行为约束见 `AGENTS.md §十一`；本文件为操作 SOP 层。宪法条款与本节措辞漂移时，以 §十一 为准。**路径约定裁决（2026-11-04 用户，Rule 100）**：worktree 与一切临时产物统一放**当前项目** `tmp/`（worktree=`<项目根>/tmp/worktrees/<task-id>`）；本裁决与宪法 §十一.2「仓外集中目录」旧约定冲突时按 P0-1 用户当前指令优先，宪法本体对齐待授权（§六 保护区，本 SOP 不改 AGENTS.md）。原因：本仓多为运行中的基础设施（skills/hooks/config 被所有会话实时加载），直接改动可能使功能在工作期间半残；隔离让改动发生在副本，验证后原子合并回原分支。冲突扫描结果只是附加依据——干净仓库也首选隔离。

## 1. 冲突分析（计划创建时强制）

`bash scripts/check-conflicts.sh` → 五类信号（exit 0 安全 / 1 有风险）：

| 信号 | 含义 | 处置（默认不打断执行） |
|------|------|------------------------|
| ① 未提交变更 | 与任务范围重叠会互相踩踏 | 实现类任务默认隔离：创建 worktree 前按 §4 ①-备份 清理/备份主仓改动并登记，执行期不打断；合并期按 §4/§6 + V3 解决 |
| 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项（呈报记录，不因此向用户发起是否隔离/是否继续的确认）。 | | |
| ② 额外 worktree | 可能有并行工作 | 记录并行态；实现类任务仍默认隔离执行，不打断 |
| ③ 遗留 wt/* 分支 | 未合并的隔离工作 | 登记遗留状态；不阻断本任务隔离执行，合并/清理由对应任务收口 |
| ④ INDEX 待处理任务在册 | 并行会话可能同时推进 | 记录并行态；实现类任务仍默认隔离执行，不打断 |
| ⑤ 运行中基础设施改动 | 改动即影响所有会话 | 记录风险；实现类任务默认仍隔离推进，不打断 |

结果 + 决策写入 task_plan.md「🔀 隔离决策」区块，随计划记录（实现类默认直接执行，不就隔离/冲突向用户发起确认询问；执行期冲突仅记录、合并期解决）。

## 2. 决策矩阵

<!-- 2026-11-27 用户裁决（What/Why）：不再因“.md 后缀”一律直改主仓；交付型长文/写作/多章节或改动量超阈值必须隔离，以避免并行/误改风险。文件扩展名不是隔离判据。 -->

| 任务类型 / 判定 | 默认 | 说明 |
|----------|------|------|
| 实现类（代码/配置/基础设施/技能） | **worktree（REQUIRED）** | 默认隔离并直接执行；**禁止**就该安全默认向用户发起确认/询问。仅用户**显式**要求“直接改不用 worktree”且命中 AGENTS.md §11.5 豁免时才直改并登记理由。 |
| 交付型 Markdown（小说/写作/长文档/多章节/手册类交付物）或预计改动 **> 2 行**或**多文件**（任一命中） | **worktree（REQUIRED）** | 文件扩展名不是判据（`.md` 也可为交付型产物）；改动量/影响面决定隔离。即使“纯 Markdown”，只要属于交付型或 >2 行/多文件，必须进入 worktree。 |
| 非交付型过程文档且 **≤ 2 行** trivial 修改（如仅改 plans/、临时说明的极小勘误，非交付产物） | **direct（EXEMPT）可豁免** | 仅此类可免隔离；须在计划/备注登记“非交付型 + ≤2 行 trivial”。 |
| 纯调研/只读 | direct | 不产生写入；用户显式要求时仍可隔离。 |
| 信号⑤ 命中（基础设施有未提交改动） | worktree + 强烈建议 | 默认仍按隔离推进并呈报风险/看点；仅在用户显式豁免且合规时才不隔离。 |
| 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。 | | |

**判定要点（2026-11-27，绑定 check-worktree-required.sh 语义）**：① 文件扩展名**不是**隔离判据（`.md` 可能是交付型小说/长文，也可能是过程文档）。② 交付型 Markdown（小说/写作/长文档/多章节等交付物）或预计改动 >2 行/多文件 → **REQUIRED worktree**。③ 仅非交付型过程文档且 ≤2 行 trivial → **EXEMPT**。④ 用户显式说“直接改不用 worktree”仍按 AGENTS.md §11.5 处理，但**不因 .md 后缀自动生效**（必须同时满足 §11.5 的可绕过例外条件并登记理由）。

## 3. 路径规范（消除散落 — 2026-08-29 立；2026-11-04 修订为 Rule 100 内放）

**强制（用户裁决 2026-11-04，Rule 100）**：所有 worktree 与一切临时产物必须落在**当前项目**的临时目录内，子目录 = `<task-id>`：

```
<project-root>/tmp/worktrees/<task-id>/
```

`${PROJECT_ROOT}` = 当前项目根目录的绝对路径(即任务所属 git 仓根,如 `/mnt/data/dev/task-planner-skill` 或 `~/.zcode`;按部署环境代入实际值),下文命令示例统一以 `${PROJECT_ROOT}` 书写。

**为什么**:原 2026-08-29 约定(仓外隐藏集中目录 `<repo>-worktrees/<task-id>`,置于该仓父目录)解决了仓库旁散落问题,但临时态仍散在各项目 home 目录、跨项目盘点/清理成本高,且临时文件本无统一落点规则。2026-11-04 裁决(Rule 100,task-crossprojauth-20261104 R2)收拢为:worktree+一切临时产物统一落**当前项目** `tmp/`——`.gitignore` 一条 `tmp/` 统一忽略(Rule 100.2),`git worktree list` + `ls <project-root>/tmp/worktrees/` 全量盘点,清理时按子目录逐个处理不再遗漏。旧仓外集中目录约定**废止(2026-11-04)**:存量旧路径 worktree 按 §4/§6 逐个清理,新任务禁用旧路径。

**约束**:
- 必须用**绝对路径**(相对路径会因当前 cwd 解析错位置,落进主仓内部 — 已在 2026-08-29 验证过一次)
- 前置:`<project-root>/.gitignore` 含 `tmp/`(Rule 100.2;验证点 `git check-ignore -q tmp/` exit 0;任务起点缺则追加一行并登记 Decisions Made)
- `tmp/worktrees/` 位于主仓 gitignore 区 — 主仓忽略的是路径,worktree 内部 git 管理不受影响(其自身 HEAD 边界,worktree 内提交仍走 Rule 27)
- 子目录名 = task-id,不带 `wt-` 前缀(basename 语义不变,smart-merge-back.sh/check-conflicts.sh 的 basename=task-id 兼容逻辑不受影响)
- 分支名仍为 `wt/<task-id>`(与路径解耦)

## 4. 生命周期（最小命令集）

```bash
# ①-备份(前置): 主仓存在未提交变更时先做 git 备份,使主仓工作区干净、worktree 从稳定基线(main)创建,避免并行改动干扰且降低合并期 V3(scope 重叠)误拦
#    推荐(保留 plans/ 与 tmp/ 等会话协调/临时目录,仅备份其余改动): 
#      git -C ${PROJECT_ROOT} stash push -u -m "pre-wt-backup:<task-id>" -- . ':(exclude)plans' ':(exclude)tmp'
#    备份引用(如 stash@{0}/摘要)登记「隔离决策」;主仓已干净则跳过。⑥ 收尾后按需恢复(恢复前重跑 6.1 同落点盘点)。
#    注: worktree 自 main 创建已天然隔离于主仓工作区;①-备份用于清理主仓脏状态与稳定合并回,非 worktree 内容来源。

# ① 创建(路径见 §3 路径规范;分支名 wt/<task-id>;前置: ${PROJECT_ROOT}/.gitignore 含 tmp/ (Rule 100.2))
git worktree add ${PROJECT_ROOT}/tmp/worktrees/<task-id> -b wt/<task-id> master

# ①-校验（创建后规则版本一致性硬门，P1，2026-11-18 task-skill-loop-guard-20261118；固化 feedback worktree-branch-desync）
#    进入②前先校验两点：① 基线分支确为当前主工作分支——本仓 main 为陈旧无关历史,须改用 master（git merge-base --is-ancestor main master 为 NO 即命中）；
#    ② worktree 与主工作分支的关键规则文件（*/SKILL.md、*/references/critical-rules*.md）行数与关键锚一致。
#    任一不一致 = 禁止开发，从主工作分支同步正确版本后重校，校验结果登记「隔离决策」区块（规则版本锚）；
#    创作与审查必须同一规则版本快照，禁按旧规创作/按新规判 FAIL（判例 EP34 BLOCKER 纯流程性返工）。

# ② 开发:所有文件操作用 worktree 绝对路径(CWD 不迁移!)——worktree 文件隔离保证执行期稳定,不受其他并行开发工作区改动干扰
#    子代理派发时在 prompt 中写明 worktree 绝对路径

# ③ worktree 内提交 — 每 Phase 完成即提交(Rule 27),禁止攒批到最后;禁止把未提交变更带回合并
#    只 add 本 Phase 产物文件(禁用 add -A 盲扫,防卷入 plans/ 与并行任务产物)
git -C ${PROJECT_ROOT}/tmp/worktrees/<task-id> add <本 Phase 产物文件...>
git -C ${PROJECT_ROOT}/tmp/worktrees/<task-id> commit -m "<type>(<scope>): task-<id>/Phase N — <摘要>"
#    [git-rework-guard 2026-11-22] 更细 checkpoint:单个 S-unit/大改动完成即 commit(不等整 Phase),
#    使每个可回退点都进版本历史——返工时用 git 找回而非重做(见下方「返工 Git 找回流程」节)。
#    临时分支 wt/<task-id> 天然隔离主分支:方向错=丢弃分支,验证过=才合并,全程不污染 master。

# ④ worktree 内全 VC 复验通过后,回主仓合并(同步开发冲突仅在此阶段处理,执行期不打断)
git merge --no-ff wt/<task-id> -m "merge: <task-id> <goal>"

# ⑤ 清理
git worktree remove ${PROJECT_ROOT}/tmp/worktrees/<task-id> && git branch -d wt/<task-id>

# ⑥ 主仓复验:Read 关键文件确认合并结果,更新 task_plan.md merge_back=merged(<commit>);按需恢复 ①-备份(stash pop/apply 前重跑 6.1)
```

**执行期不打断原则（P0，对齐用户裁决）**：worktree 内执行**不因并行开发/其他在途 plan 的 Rule 23 同域冲突（`[conflict]` 注入、信号①-⑤、scope 重叠提示）而暂停或向用户发起 scope/是否继续确认**——冲突仅作记录，**统一延后至 ④ 合并回阶段**由 `smart-merge-back.sh` V3/V5/V6 与 Rule 101.2 解决。worktree 文件隔离 + ①-备份 保证执行稳定；冲突收口属于合并义务，不属于执行期阻塞。

复杂场景（多工作树编排/上游同步）可调用 `Skill("using-git-worktrees")`。

## 4. 合并回合约（全部满足才可合并）

> **机制化入口（task-v064）**：`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]` 自动执行本合约第 2/3 条预检 + 已合并检测（ALREADY_MERGED——另一会话已合并时跳过转簿记补全）+ --no-ff 合并；V1-V6 判定与退出码 2-8 见脚本头注释（6 = DEPLOY_DRIFT，部署位不齐时可能在合并已成功后出现）。下方人工流程保留为逃生路径（脚本退出码非 0 时按失败处理人工介入）。

```
1. worktree 内全部 Phase = complete,VC 逐条复验通过
2. worktree 内无未提交变更(git status 干净)
3. 主仓无与任务范围重叠的未提交变更(信号①残余风险;①-备份已清理则通常满足;仍有重叠 → STOP 报告用户,按 V3/合并期处理,非执行期打断)
   STOP 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项
4. merge 后:主仓 Read 关键文件复验 + git log 确认 merge commit
5. 清理 worktree 与分支;task_plan.md「隔离决策」merge_back 更新为 merged(<commit>)
```

**失败处理（2026-11-04 Rule 101.2 语义翻转）**：merge 冲突=收口义务（Rule 101.2）：逐条走 41.1 消解链配额（①git 三方合并/并集解 ②手动解冲突→复验 ③分叉重基）**解决所有冲突**，解后 VC 复验过才合并；仅**消解配额耗尽仍冲突**为真门（Rule 95.5）→ STOP 报告用户（Rule 70 四要素+冲突 hunk 看点）并在 progress 登记 `[conflict-unresolved]`；**不乱解守卫保留**：解冲突必带复验（VC/selftest/Read 对照），无复验的解=假收口（Rule 54），并集解仅限两侧增量场景、判为语义冲突处必须手动解+复验。worktree 内验证失败 → 修到通过才合并，3 次失败升级用户。
呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。

## 4.5 返工 Git 找回流程（git-rework-guard 2026-11-22，用户诉求：长链返工把可控项目改得不可控）

**核心原则**：返工/回退的**第一动作永远是查 Git 历史找回**，禁止凭记忆重做或全量改写。Git 的版本保存+历史找回是核心资产，长链返工中不用 Git = 抛弃最有力的安全网。

**触发**：QC FAIL / 方向错 / 改坏文件 / 需回退到某中间状态（含 Rule 103.8b 同文件第 3 轮返工前 STOP 换策略、Rule 96.7 checkpoint 后续批）。

**找回步骤（按顺序）**：
1. `git -C <worktree> log --oneline -20` → 定位最近的正确 commit（配套 commit message 写明 Phase/S-unit）；同时在 progress.md 查该节点的 commit hash 留痕。
2. 精确恢复：只需回退某文件 → `git -C <worktree> checkout <good-commit> -- <file>`（只取回该文件，不动其他成果）；需整体回退 → `git -C <worktree> revert <bad-commit>` 或在新 checkpoint commit 上继续（禁 `reset --hard` 未提交成果）。
3. 找回后**先 diff 对照**（`git diff <good-commit> -- <file>`）再决定保留哪些增量，禁止整文件覆盖丢失他人/他阶段成果。
4. 方向彻底错 → 丢弃整条临时分支（`git worktree remove` + `git branch -D wt/<task-id>`），主分支零污染，从主仓重新开始——这是 worktree+临时分支相对直接改主分支的核心价值。

**commit 频率纪律（防找回点缺失）**：单个 S-unit/一次大改动完成即 commit（粒度≤一个可回退单元），不等到整 Phase 末；commit message 必含 task-id + Phase/S-unit 标识。计划文档（plans/）也每 Phase 提交进版本控制（Rule 27），禁长期 uncommitted（否则会话中断/返工时 Git 无可找回）。

## 4.6 方向性止损与弃旧开新（restart-from-baseline 2026-11-22，用户诉求）

**定位与核心原则**：本节是 §4.5 git-rework-guard 的**补充出口**——§4.5 解决「局部返工能用 Git 找回」，本节解决「方向根本错误、找回已无意义时如何止损重开」。核心原则=**主动放弃错误路线，从干净基线牵新版本 + 新计划从头做**，切断错误上下文与错误历史负担。Why（用户真实诉求）：继续在错误方向挣扎会把可控项目改得不可控，重开往往更有效；本节复用同一 git/worktree/commit 基座（§4③、Rule 27、§4.5），是找回机制的延伸出口，不是另起一套机制。

**触发门（三级，逐级通过才执行；不可逆操作守宪法 §五）**：
1. ①量化阈值信号（复用既有规则，不新造）：Rule 96.7 单一会话/目标 `Agent()` 累计 >40 次或 >60 分钟；Rule 103.8b 同一 canonical 文件进入第 3 轮返工前 STOP。命中任一 = 「疑似方向性错误」，进入②。
2. ②归因评估：派 drift-checker（Rule 61/64）判 🔴BLOCKED，或 decision-arbiter 归因分层，确认为「方向根本错误/整体路线错」而非局部 bug（局部 bug 回 §4.5 Git 找回，不触发本节）。
3. ③用户确认门：主进程出评估报告（已耗预算/已证伪方向/有效数据清单/推荐 restart 范围）→ 用户显式 yes 才执行；禁未经确认就丢弃分支或改计划终态。

**有效数据提取白名单（salvage-manifest）**：从混乱状态提取有效数据、写入 salvage-manifest 随新计划登记（复用 findings.md/Decisions 载体，不新建文件类型）。Why：只迁经验证有效数据，禁把错误历史带进新基线。
- ✅可带：findings 结论/证据锚、knowledge-brief 知识锚、已 PASS 的 VC 结果、已 commit 且验证过的产物、user-session-log 中用户确认的决策。
- ❌不带：FAIL 产出、错误路线代码/文件、未验证推测、RAW 调试日志、被 `[corrected]` 的旧上下文。

**从基线牵新版本标准命令序列**：基线优先 master 当前 HEAD 上该任务开始前的干净 commit（或 wt 分支早期已验证 good commit，用 `git log --oneline` 定位）。
```
git -C <project> log --oneline -20                          # 定位干净基线 commit
git worktree add <project-root>/tmp/worktrees/<task-id>-rN -b wt/<task-id>-rN <baseline-commit>
```
新 worktree 不带错误分支后续提交（路径遵守 Rule 100 项目内 tmp/）；新计划 `plans/<task-id>-rN/` 走 init 全流程，头部登记 `restarted_from=<old-task-id>` + salvage-manifest 指针。

**旧线冻结登记**：旧计划 `outcome: RESTARTED`（新状态词，区别于 CANCELLED=用户授权不做、SUPERSEDED=被外部新目标取代，语义=同目标换路线从头做）+ Decisions 登记（触发证据/新计划 ID/salvage-manifest/ISO8601 时间）+ progress 追加 `[restart]` 行；旧 wt 分支留档不物理删除、仅从活跃指针移除，后续按正常收口或用户明示清理；不抹 git 历史（Rule 102.1e 精神），保留复盘链。

**反模式（❌清单）**：
- ❌ 未归因就弃旧（把局部 bug 当方向错）
- ❌ 无用户确认就丢弃分支 + 改计划终态
- ❌ 把 FAIL 产出/错误代码带进新计划（污染新基线）
- ❌ 物理删除旧证据（失去复盘）
- ❌ restart 循环无上限（restart ≥2 次仍方向错 → 升级用户裁决，不开 -r3）

## 5. 反模式（禁止）

- ❌ 实现类任务未经用户否决就直接在原分支开发
- ❌ 在 worktree 里创建计划文档(plans/ 属会话级状态，留主仓)
- ❌ 合并带回未提交变更 / 跳过 worktree 内复验直接 merge
- ❌ 解冲突不复验/留冲突给用户（冲突=收口义务，Rule 101.2：主动解决所有冲突+复验门；「不乱解」守卫保留——仅配额耗尽才真门）
- ❌ 合并后不清理 worktree/分支(遗留 wt/* 是下次冲突信号③)
- ❌ 切换会话 CWD 到 worktree(破坏哨兵与 hook 相对路径约定)
- ❌ 将 worktree/临时文件放在当前项目 tmp/ 之外(2026-11-04 Rule 100 内放;旧仓外集中目录路径已废止,见 §3)
- ❌ 因 Rule 23 并行冲突注入(`[conflict]`)/信号①-⑤/scope 重叠提示在 worktree 执行期暂停或向用户询问确认(冲突仅记录,统一延后至 ④ 合并回/V3/V5/V6 解决)

## 6. 并行任务同落点冲突与排队续跑（2026-10-16 立）

> 判例：task-v179（worktree 内 Rule 87）/task-v181（主仓直改 Rule 89）/task-v180（排队殿后 Rule 88）三任务同日竞写 `critical-rules-discipline.md` 末段与 SKILL.md 索引行——目录隔离各自合规仍发生冲突。**目录不冲突 ≠ 落点不冲突**；隔离必须从目录级升级到落点级。工作树隔离防的是「工作中互相覆盖」，防不了「汇合时抢同一追加锚点」与「协调态各会话各见一个世界」。
> **与 worktree 执行期不打断原则的关系**：worktree 内执行不因并行冲突/Rule 23 注入中断（§4 原则）；本节 6.1 的“开工前盘点”仍须执行并登记落点交集/排队意图，但**不阻断 worktree 内开发推进**——同落点冲突作为合并期风险登记，由 ④ 合并回阶段解决（V3/V5/V6+101.2 并集解/复验）。主仓直改/非隔离场景发现实时覆盖风险时，仍按 6.2 STOP 排队续跑。

**落点级三查（2026-11-24 用户投诉『用了 worktree 还同时编辑同一文件』强化）**：建 worktree 前除目录隔离外，还须逐项盘点落点——① 用 `git status --short` + `git diff --name-only` 列出主仓所有未提交改动文件；② 枚举 `plans/*/task_plan.md` 的 scope_files（不单靠 INDEX.md，其常为未提交脏态）；③ 对 scope ∩ (主仓脏文件 ∪ 其他 worktree 脏文件 ∪ 其他 in_progress plan 的 scope) 逐文件核对：命中即在 task_plan「🔀 隔离决策」登记并**主动错开落点/合并期优先处理**；仍未避免则合并回时逐文件 diff 复核，禁静默覆盖他会话改动。基线分支必须=`master`（本仓 main 无共同祖先，实测 `git merge-base main master` exit 1）。

### 6.1 同落点盘点（开工前强制；任意直改主仓前同样适用）

<!-- 2026-11-27 用户裁决：移除“仅 L0-T/纯文档豁免暗示”，强调落点盘点与隔离判定不以 .md 后缀为由放宽。 -->

动笔前三查（任一命中 → 登记落点交集与排队/殿后意图；**worktree 内不阻断执行**，冲突留合并期解决；**主仓直改/非隔离场景**命中同落点实时覆盖风险时先排队再动笔）。**隔离判定按 §2（2026-11-27）执行**：交付型 Markdown/多行/多文件一律 REQUIRED worktree，**不因后缀为 .md 而豁免**。

1. 在途计划落点交集：`ls plans/ | grep -v archive` 列在途任务，对照各自 task_plan.md 的 scope_files/落点文件，与本次落点取交集；
2. 台账在途占用：`plans/.rule-reservations.jsonl` 尾部（或 `rule-reserve.sh list`）reserved 未 land 行，指向同文件同锚点的在途任务；
3. 主仓未提交改动交集：`git status --short` 中被修改文件，与本次落点取交集（主仓工作区是并行会话的共同写入面；即使自认为“只改一点文档”也必查）。

命中处置：在本任务计划「隔离决策/Decisions」登记**排队/殿后前置**（写明：对端任务 ID + 恢复条件 + 追加锚=届时文件实际最大编号段/实际末段），禁两任务并行双写同一追加锚点。

### 6.2 STOP 排队续跑语义（替代死停）

执行中才发现与在途任务重叠时：**worktree 内执行不打断**，登记阻塞对象/合并期收口计划后继续（冲突由 ④ 合并回解决）；**主仓直改/非隔离场景**下实时覆盖风险仍 STOP，但 STOP 报告必须携带三件套，把「死停」变「排队」：

1. **阻塞对象**：在途任务 ID + 其落点文件/锚点；
2. **恢复条件**：可观察信号（对端 land 行出现在台账 / 对端 commit 出现于 master / worktree 已删）；
3. **续跑步骤**：恢复后第一动作（重跑 6.1 盘点 → 按届时实际末段落笔 → 原计划 Phase 继续）。

等待态落盘 progress.md（同 Rule 57 留痕口径）；对端收口后按续跑步骤无损继续，禁止死停等待用户人工重踢。

### 6.3 协调态提交纪律

台账预留行（`plans/.rule-reservations.jsonl`）与计划簿记是**跨会话共享事实**：任务收口（land/commit）时随行提交，禁止长期停留 uncommitted 态——uncommitted 的协调态 = 各会话各见一个世界，是误判「干净/无冲突」的第一根源（判例：worktree 内台账视图无 87 预留行，主仓工作区实际已预留，定号 `next=87` 因此撞号）。

### 6.4 同写冲突检出后的补救性隔离（用户缺陷①②，2026-11-23）

**触发**：check-conflicts.sh 或 PreToolUse 检出另一会话正在写同一受管文件；或发现两会话已在主树同写。
**禁止**：仅"记录冲突、延后到合并期"后继续在主树直接写（这是用户投诉的错误路径）。
**补救四步**：① 立即补建 worktree 隔离后续改动（路径/命名按 §3）；② 将主树该文件的未提交改动迁移到隔离分支（git stash 或手工复制后 git restore 主树，按 §4.5 找回纪律）；③ 后续所有改动在 worktree 内进行；④ 完成后用 smart-merge-back.sh 合并回主树（按 §4 合并回合约）。
**锚点**：`同写冲突补救`（供 grep / 执行体定位）。
