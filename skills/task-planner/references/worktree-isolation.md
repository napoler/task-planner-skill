# 工作树隔离契约（Worktree Isolation Contract）

> **强制策略（AGENTS.md §十一 P0，2026-08-29 升格）**：实现类任务（代码/配置/基础设施/技能）**必须**在 git worktree 隔离区开发，完成后合并回原分支并清理。完整 P0 条款、必命中范围、可绕过例外、并行开发期间的行为约束见 `AGENTS.md §十一`；本文件为操作 SOP 层。宪法条款与本节措辞漂移时，以 §十一 为准。原因：本仓多为运行中的基础设施（skills/hooks/config 被所有会话实时加载），直接改动可能使功能在工作期间半残；隔离让改动发生在副本，验证后原子合并回原分支。冲突扫描结果只是附加依据——干净仓库也首选隔离。

## 1. 冲突分析（计划创建时强制）

`bash scripts/check-conflicts.sh` → 五类信号（exit 0 安全 / 1 有风险）：

| 信号 | 含义 | 权重 |
|------|------|------|
| ① 未提交变更 | 与任务范围重叠会互相踩踏 | 直接开发必须先向用户报告并获认可 |
| 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。 | | |
| ② 额外 worktree | 可能有并行工作 | 强烈建议隔离 |
| ③ 遗留 wt/* 分支 | 未合并的隔离工作 | 先问用户：合并/废弃 |
| ④ INDEX 待处理任务在册 | 并行会话可能同时推进 | 建议隔离 |
| ⑤ 运行中基础设施改动 | 改动即影响所有会话 | 强烈建议隔离 |

结果 + 决策写入 task_plan.md「🔀 隔离决策」区块，随计划展示给用户。

## 2. 决策矩阵

| 任务类型 | 默认 | 说明 |
|----------|------|------|
| 实现类（代码/配置/基础设施/技能） | **worktree** | 用户未否决即隔离 |
| 纯文档/调研/计划类（只写 plans/、.md） | direct | 不影响运行行为;用户要求时仍可隔离 |
| 信号⑤ 命中（基础设施有未提交改动） | worktree + 强烈建议 | 或先请用户处理未提交变更 |
| 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。 | | |

## 3. 路径规范（消除散落 — 2026-08-29 立）

**强制**：所有 worktree 必须落在该仓专属的集中目录内,子目录 = `<task-id>`:

```
<repo-parent>/<repo>-worktrees/<task-id>/
```

例如 `~/.zcode` 仓 → `~/.zcode-worktrees/<task-id>/`。

**为什么**:旧约定 `../<repo>-wt-<task-id>` 把每个 worktree 散落在仓库旁,父目录被一堆 `-wt-xxx` 子目录污染,无法统一扫描/清理;集中目录把同一仓的所有 worktree 收拢到一处,`git worktree list` + `ls <repo>-worktrees/` 即可全量盘点,清理时按子目录逐个处理,不再遗漏。

**约束**:
- 必须用**绝对路径**(相对路径会因当前 cwd 解析错位置,落进主仓内部 — 已在 2026-08-29 验证过一次)
- 仓外、隐藏目录(以 `.` 起头,沿用现有约定)
- 路径模板中的 `${REPO_PARENT}` = 仓库父目录(即该仓所在目录,如某用户的 home 目录;按部署环境代入实际值),下文命令示例统一以 `${REPO_PARENT}` 书写
- 子目录名 = task-id,不要再带 `wt-` 前缀(父目录已限定仓库语义)
- 分支名仍为 `wt/<task-id>`(与路径解耦)

## 4. 生命周期（最小命令集）

```bash
# ① 创建(路径见 §3 路径规范;分支名 wt/<task-id>)
git worktree add ${REPO_PARENT}/<repo>-worktrees/<task-id> -b wt/<task-id> main

# ② 开发:所有文件操作用 worktree 绝对路径(CWD 不迁移!)
#    子代理派发时在 prompt 中写明 worktree 绝对路径

# ③ worktree 内提交 — 每 Phase 完成即提交(Rule 27),禁止攒批到最后;禁止把未提交变更带回合并
#    只 add 本 Phase 产物文件(禁用 add -A 盲扫,防卷入 plans/ 与并行任务产物)
git -C ${REPO_PARENT}/<repo>-worktrees/<task-id> add <本 Phase 产物文件...>
git -C ${REPO_PARENT}/<repo>-worktrees/<task-id> commit -m "<type>(<scope>): task-<id>/Phase N — <摘要>"

# ④ worktree 内全 VC 复验通过后,回主仓合并
git merge --no-ff wt/<task-id> -m "merge: <task-id> <goal>"

# ⑤ 清理
git worktree remove ${REPO_PARENT}/<repo>-worktrees/<task-id> && git branch -d wt/<task-id>

# ⑥ 主仓复验:Read 关键文件确认合并结果,更新 task_plan.md merge_back=merged(<commit>)
```

复杂场景（多工作树编排/上游同步）可调用 `Skill("using-git-worktrees")`。

## 4. 合并回合约（全部满足才可合并）

> **机制化入口（task-v064）**：`bash <skill>/scripts/smart-merge-back.sh <worktree-path> [--deploy]` 自动执行本合约第 2/3 条预检 + 已合并检测（ALREADY_MERGED——另一会话已合并时跳过转簿记补全）+ --no-ff 合并；V1-V6 判定与退出码 2-8 见脚本头注释（6 = DEPLOY_DRIFT，部署位不齐时可能在合并已成功后出现）。下方人工流程保留为逃生路径（脚本退出码非 0 时按失败处理人工介入）。

```
1. worktree 内全部 Phase = complete,VC 逐条复验通过
2. worktree 内无未提交变更(git status 干净)
3. 主仓无与任务范围重叠的未提交变更(信号①残余风险;有 → STOP 报告用户)
   STOP 呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项
4. merge 后:主仓 Read 关键文件复验 + git log 确认 merge commit
5. 清理 worktree 与分支;task_plan.md「隔离决策」merge_back 更新为 merged(<commit>)
```

**失败处理**：merge 冲突 → STOP 报告用户(不自动解决)；worktree 内验证失败 → 修到通过才合并，3 次失败升级用户。
呈报按 Rule 70：列变更/冲突文件绝对路径+看点（冲突 hunk/信号项）+动作+默认项。

## 5. 反模式（禁止）

- ❌ 实现类任务未经用户否决就直接在原分支开发
- ❌ 在 worktree 里创建计划文档(plans/ 属会话级状态，留主仓)
- ❌ 合并带回未提交变更 / 跳过 worktree 内复验直接 merge
- ❌ merge 冲突自动乱解不报告
- ❌ 合并后不清理 worktree/分支(遗留 wt/* 是下次冲突信号③)
- ❌ 切换会话 CWD 到 worktree(破坏哨兵与 hook 相对路径约定)

## 6. 并行任务同落点冲突与排队续跑（2026-10-16 立）

> 判例：task-v179（worktree 内 Rule 87）/task-v181（主仓直改 Rule 89）/task-v180（排队殿后 Rule 88）三任务同日竞写 `critical-rules-discipline.md` 末段与 SKILL.md 索引行——目录隔离各自合规仍发生冲突。**目录不冲突 ≠ 落点不冲突**；隔离必须从目录级升级到落点级。工作树隔离防的是「工作中互相覆盖」，防不了「汇合时抢同一追加锚点」与「协调态各会话各见一个世界」。

### 6.1 同落点盘点（开工前强制；L0-T 直改主仓前同样适用）

动笔前三查（任一命中 → 先排队再动笔）：

1. 在途计划落点交集：`ls plans/ | grep -v archive` 列在途任务，对照各自 task_plan.md 的 scope_files/落点文件，与本次落点取交集；
2. 台账在途占用：`plans/.rule-reservations.jsonl` 尾部（或 `rule-reserve.sh list`）reserved 未 land 行，指向同文件同锚点的在途任务；
3. 主仓未提交改动交集：`git status --short` 中被修改文件，与本次落点取交集（L0-T 直改任务尤其必查——主仓工作区就是并行会话的共同写入面）。

命中处置：在本任务计划「隔离决策/Decisions」登记**排队/殿后前置**（写明：对端任务 ID + 恢复条件 + 追加锚=届时文件实际最大编号段/实际末段），禁两任务并行双写同一追加锚点。

### 6.2 STOP 排队续跑语义（替代死停）

执行中才发现与在途任务重叠时，STOP 本身正确（不停 = 两会话互写同文件）；但 STOP 报告必须携带三件套，把「死停」变「排队」：

1. **阻塞对象**：在途任务 ID + 其落点文件/锚点；
2. **恢复条件**：可观察信号（对端 land 行出现在台账 / 对端 commit 出现于 master / worktree 已删）；
3. **续跑步骤**：恢复后第一动作（重跑 6.1 盘点 → 按届时实际末段落笔 → 原计划 Phase 继续）。

等待态落盘 progress.md（同 Rule 57 留痕口径）；对端收口后按续跑步骤无损继续，禁止死停等待用户人工重踢。

### 6.3 协调态提交纪律

台账预留行（`plans/.rule-reservations.jsonl`）与计划簿记是**跨会话共享事实**：任务收口（land/commit）时随行提交，禁止长期停留 uncommitted 态——uncommitted 的协调态 = 各会话各见一个世界，是误判「干净/无冲突」的第一根源（判例：worktree 内台账视图无 87 预留行，主仓工作区实际已预留，定号 `next=87` 因此撞号）。
