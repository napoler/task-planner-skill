# Git 健康 + 工作区状态巡检报告

- **任务**：`task-project-audit-20261123` / 子项：git 健康 + 工作区状态
- **巡检时间**：2026-11-23（执行环境当前日期）
- **仓库**：`/mnt/data/dev/task-planner-skill`
- **巡检人**：子代理（只读巡检；除本报告文件外未做任何写操作）
- **约束遵守**：仅执行只读命令（`git status/branch/log/worktree/merge-base/rev-parse/reflog/stash/show/rev-list/for-each-ref`、`ls/test`）；未执行 `git add/commit/checkout/clean/reset`，未删除/修改业务文件。

---

## 1. 分支拓扑

### 1.1 证据命令与输出

**命令 A：分支与跟踪关系**
```bash
cd /mnt/data/dev/task-planner-skill && git branch -a -vv
```
输出：
```text
  main                        15a3ecf sync: 从 ~/.claude/skills/task-planner 同步新版 skill
* master                      e3206b3 [origin/master: ahead 40] chore(plans): task-restart-baseline-20261122 弃旧开新机制计划文档入版本控制（Rule 27：计划每 Phase 提交；精确 pathspec 不捎带 hook 改写的 task-cli-help-examples）
  wt/task-v168-machine-parked 3a68579 park: task-v168 机器面封存（用户 2026-10-11 反馈『明明是逻辑/技能设置问题，一直在改代码』后整体封存；含 Rule 77/78/79 编号 land 记录；未合并主仓、未部署；后续在 wt/task-v168 分支只做逻辑/设置层）
+ wt/tplsys-upgrade-20261117  3b8a021 (/mnt/data/dev/task-planner-skill/tmp/worktrees/wt-tplsys-upgrade-20261117) feat(tplsys): upgrade template system for ZCode agent-aware scan, research-preceded generation, and approval-gated persistence
  remotes/origin/HEAD         -> origin/main
  remotes/origin/main         15a3ecf sync: 从 ~/.claude/skills/task-planner 同步新版 skill
  remotes/origin/master       f55f9c1 archive: task-antiregress-tplgov-20261120 归档（103.3 复检 APPROVED；防倒退+模板治理 R1-R5 闭环）
```

**命令 B：merge-base / rev-parse**
```bash
cd /mnt/data/dev/task-planner-skill && git merge-base master main; echo "rc=$?"
git rev-parse master main origin/master origin/main origin/HEAD
```
输出：
```text
rc=1
e3206b3c3215b0b413a3bced41b394a8d444fb5a
15a3ecf61b1c3aec7288da5f6bb352bde844f35a
f55f9c185567b9d436dc903f550e140fb67f9ee7
15a3ecf61b1c3aec7288da5f6bb352bde844f35a
15a3ecf61b1c3aec7288da5f6bb352bde844f35a
```

**命令 C：ahead/behind**
```bash
cd /mnt/data/dev/task-planner-skill && git rev-list --left-right --count origin/master...master
git rev-list --left-right --count origin/main...main
```
输出：
```text
0	40
0	0
```

**命令 D：最近提交**
```bash
cd /mnt/data/dev/task-planner-skill && git log --oneline -12
```
输出：
```text
e3206b3 chore(plans): task-restart-baseline-20261122 弃旧开新机制计划文档入版本控制（Rule 27：计划每 Phase 提交；精确 pathspec 不捎带 hook 改写的 task-cli-help-examples）
4581055 Merge branch 'wt/task-restart-baseline-20261122'
8bea62e feat(task-planner): 弃旧开新(restart-from-baseline)机制——...
fcc025c merge: task-cli-help-examples-20261122 CLI help 可照抄示例 + SKILL/examples 四件套
a52b9e5 feat(task-planner): CLI help 可照抄示例 + SKILL/examples 四件套（task-cli-help-examples-20261122）
3d964e6 chore(plans): task-git-rework-guard-20261122 轻量计划入版本控制（Rule 27：计划文档每 Phase 提交）
d889915 merge: task-git-rework-guard-20261122 Git 返工找回纪律固化
613c2fd feat(task-planner): Git 返工找回纪律——...
e38d106 chore(plans): 存量计划文档纳入 Git 版本控制——...
aff89a9 merge: task-core-opt-20261122 模板固化周期性会话记忆回顾（纯文本，零新增FAIL，渲染冒烟通过）
f82d26b feat(task-planner): 模板固化周期性会话记忆回顾条目——...
7dc4e35 merge: task-template-catalog-20261122 模板检索/管理脚本 + 32 模板元数据统一...
```

**命令 E：分支尖端对比**
```bash
git log --oneline --decorate -5 master
git log --oneline --decorate -5 origin/master
git log --oneline --decorate -5 main
```
关键输出：
```text
master:        e3206b3 (HEAD -> master) ...
origin/master: f55f9c1 (origin/master) archive: task-antiregress-tplgov-20261120 ...
main:          15a3ecf (origin/main, origin/HEAD, main) sync: 从 ~/.claude/skills/task-planner 同步新版 skill
```

### 1.2 判定

| 项目 | 结论 |
|---|---|
| `master` | 本地当前分支，`e3206b3`，比 `origin/master` **ahead 40 / behind 0** |
| `origin/master` | `f55f9c1`，停留在 `task-antiregress-tplgov-20261120` 归档提交 |
| `main` / `origin/main` / `origin/HEAD` | 均指向 `15a3ecf`，三者一致 |
| `merge-base master main` | **无共同祖先**（`rc=1`，无输出） |

- **现象**：`master` 与 `main` 无共同祖先；`master` 领先 `origin/master` 40 个提交；`main` 与远端同步。
- **证据**：命令 B `rc=1`；命令 C `0 40` / `0 0`；命令 A 显示 `origin/HEAD -> origin/main`。
- **根因推断**：仓库存在“历史分叉”的双主线形态：`main` 线是较早的同步提交线（origin 默认 HEAD 指向 main），`master` 线承载近期 task-planner 开发与合并，且本地已积累 40 个未推送提交。`merge-base rc=1` 表明两线不可按普通祖先关系直接比较（历史独立或重写过根）。
- **严重度**：**P1**（不是数据损坏，但对协作/发布有显著风险：默认分支认知可能混乱，40 个本地提交未备份到远端）。
- **建议（仅文字，不执行）**：明确仓库“发布主线”是 `master` 还是 `main`；若 `master` 为事实主线，考虑与远端对齐（推送/设置默认分支）；若需保留 `main`，在 README/CONTRIBUTING 标注分支策略。**不要**在未确认策略前强行合并/重置。

---

## 2. Worktree 残留

### 2.1 证据命令与输出

**命令 A：worktree 列表**
```bash
cd /mnt/data/dev/task-planner-skill && git worktree list --porcelain
```
输出：
```text
worktree /mnt/data/dev/task-planner-skill
HEAD e3206b3c3215b0b413a3bced41b394a8d444fb5a
branch refs/heads/master

worktree /mnt/data/dev/task-planner-skill/tmp/worktrees/wt-tplsys-upgrade-20261117
HEAD 3b8a0219e4c2b62c3ad89c3f8cc18ec8f5b1d252
branch refs/heads/wt/tplsys-upgrade-20261117
```

**命令 B：`.git/worktrees` 元数据**
```bash
ls -la .git/worktrees/
for d in .git/worktrees/*/; do echo "--- $d ---"; cat "$d/gitdir"; cat "$d/HEAD"; done
```
输出：
```text
drwxrwxr-x 3 terry terry 4096 11月 17 15:21 wt-tplsys-upgrade-20261117
--- .git/worktrees/wt-tplsys-upgrade-20261117/ ---
/mnt/data/dev/task-planner-skill/tmp/worktrees/wt-tplsys-upgrade-20261117/.git
ref: refs/heads/wt/tplsys-upgrade-20261117
```

**命令 C：目标目录存在性**
```bash
test -d tmp/worktrees/wt-tplsys-upgrade-20261117 && echo EXISTS_DIR || echo MISSING_DIR
ls -la tmp/worktrees/
```
输出：
```text
EXISTS_DIR
total 12
drwxrwxr-x 3 terry terry 4096 11月 22 23:01 .
drwxrwxr-x 4 terry terry 4096 11月 21 23:52 ..
drwxrwxr-x 8 terry terry 4096 11月 17 14:38 wt-tplsys-upgrade-20261117
```

**命令 D：目标 worktree 工作区状态（只读）**
```bash
git -C tmp/worktrees/wt-tplsys-upgrade-20261117 status --short
```
输出：
```text
?? .zcode_patch_helper.txt
```

### 2.2 判定

- **现象**：存在 1 个注册 worktree `wt/tplsys-upgrade-20261117`，目标目录真实存在，`.git/worktrees/wt-tplsys-upgrade-20261117/gitdir` 指向该目录 `.git`，HEAD 指向 `refs/heads/wt/tplsys-upgrade-20261117`；该 worktree 内仅有 `?? .zcode_patch_helper.txt` 未跟踪文件。
- **证据**：命令 A-D 输出一致，无缺失路径/悬空 gitdir。
- **根因推断**：这是一个**有效、已注册、目录存在**的在途/保留 worktree，不是孤儿元数据。分支与 worktree 均在（见第 3 节）。
- **孤儿元数据判定**：**否**。判定标准：gitdir 指向存在、worktree list 可见、分支存在——三者满足。
- **严重度**：**P2**（低风险；属于未清理的工作分支/worktree，但非损坏态）。worktree 内未跟踪文件 `.zcode_patch_helper.txt` 为轻微脏状态。
- **建议（仅文字，不执行）**：确认 `wt/tplsys-upgrade-20261117` 是否仍需继续开发或合并；若任务已完成，按 §十一 合并回合约评估后再清理。**不要**直接 `git worktree remove/prune`，也不要删除目录。

---

## 3. 遗留分支（`wt/*`）

### 3.1 证据命令与输出

**命令 A：wt 分支枚举与最后提交**
```bash
git for-each-ref --sort=-creatordate \
  --format='%(refname:short)|%(objectname:short)|%(creatordate:iso8601)|%(subject)' \
  refs/heads/wt refs/remotes/origin/wt
```
输出：
```text
wt/tplsys-upgrade-20261117|3b8a021|2026-11-17 15:21:23 +0800|feat(tplsys): upgrade template system for ZCode agent-aware scan, research-preceded generation, and approval-gated persistence
wt/task-v168-machine-parked|3a68579|2026-10-11 19:48:48 +0800|park: task-v168 机器面封存（用户 2026-10-11 反馈『明明是逻辑/技能设置问题，一直在改代码』后整体封存；含 Rule 77/78/79 编号 land 记录；未合并主仓、未部署；后续在 wt/task-v168 分支只做逻辑/设置层）
```

**命令 B：分支与 worktree 绑定**
```bash
git branch -a -vv | grep wt/
```
输出：
```text
  wt/task-v168-machine-parked 3a68579 park: task-v168 机器面封存...
+ wt/tplsys-upgrade-20261117  3b8a021 (/mnt/data/dev/task-planner-skill/tmp/worktrees/wt-tplsys-upgrade-20261117) feat(tplsys): ...
```

### 3.2 判定

| 分支 | 最后提交时间 | 绑定 worktree | 状态判定 |
|---|---|---|---|
| `wt/tplsys-upgrade-20261117` | 2026-11-17 15:21:23 +0800 | 有（存在且有效） | 在途/保留 worktree 分支，**非垃圾** |
| `wt/task-v168-machine-parked` | 2026-10-11 19:48:48 +0800 | 无 | 明确标注 “parked/封存/未合并主仓/未部署”，**封存分支，非垃圾** |

- **现象**：本地有 2 个 `wt/*` 分支，无远端 `origin/wt/*`。
- **证据**：命令 A/B。
- **根因推断**：`wt/tplsys-upgrade-20261117` 为活跃 worktree 对应分支；`wt/task-v168-machine-parked` 为人为封存分支（提交信息已写明封存原因与边界）。
- **严重度**：**P2**（治理噪音低；两者都有明确语义，不构成异常残留）。
- **建议（仅文字，不执行）**：保留两分支直至任务所有者确认；`task-v168-machine-parked` 已有明确封存说明，不应按普通遗留分支清理。若未来封存结束，按工作流归档/删除需经用户确认。

---

## 4. Stash

### 4.1 证据命令与输出

**命令 A：stash 列表**
```bash
git stash list
git stash list --format='%gd|%ci|%gs'
```
输出：
```text
stash@{0}: WIP on master: d806d05 feat(task-v141): Rule 57 迭代测试轮次落盘纪律 — land to master
===
stash@{0}|2026-10-07 05:33:36 +0800|WIP on master: d806d05 feat(task-v141): Rule 57 迭代测试轮次落盘纪律 — land to master
```

**命令 B：stash 影响范围**
```bash
git stash show --stat stash@{0}
```
输出：
```text
 plans/.rule-reservations.jsonl                          | 1 +
 plans/task-v116/subagent-state/.dispatch-inflight       | 2 +-
 plans/task-v141-iteration-persistence/.plan-attestation | 4 ++--
 3 files changed, 4 insertions(+), 3 deletions(-)
```

### 4.2 判定

- **现象**：仅 1 条 stash，创建于 2026-10-07 05:33:36 +0800，基于旧提交 `d806d05`（task-v141），影响 3 个 plans 相关文件，共 4+/3-。
- **证据**：命令 A/B。
- **根因推断**：历史 WIP 暂存，年代较久（>1 个月），且基底提交不是当前 master 尖端，直接 pop 可能冲突或语义过期。
- **严重度**：**P2**（不是活跃阻塞；但属于长期遗留上下文，容易被遗忘）。
- **建议（仅文字，不执行）**：由任务所有者确认该 stash 是否仍有价值；确认前**不要** `stash pop/drop/clear`。如需处理，应先在隔离环境检查内容再决策。

---

## 5. 工作区脏状态

### 5.1 证据命令与输出

**命令 A：全量 status**
```bash
git status --short
```
输出（原始）：
```text
 M .zcode/plans/plan-sess_66ec6ec3-2d6d-4832-a71e-a303e58eff8e.md
 D plans/task-cli-help-examples-20261122/.fix_vcs.py
 D plans/task-cli-help-examples-20261122/.fix_vcs_r3.py
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T204713-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205657-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205700-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205705-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205707-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205708-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205710-01.json
 D plans/task-cli-help-examples-20261122/.history/plan-state-20261122T205712-01.json
 M plans/task-cli-help-examples-20261122/findings.md
 M plans/task-cli-help-examples-20261122/plan-state.json
 M plans/task-cli-help-examples-20261122/progress.md
 M plans/task-cli-help-examples-20261122/task_plan.md
 M plans/task-cli-help-examples-20261122/verification.md
?? .zcode/plans/plan-sess_d0c282be-265e-44df-996f-a0e18e25201b.md
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T213012-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T213121-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220539-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220542-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220723-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220724-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220725-01.json
?? plans/task-cli-help-examples-20261122/.history/plan-state-20261122T220726-01.json
?? plans/task-project-audit-20261123/
```

**命令 B：按顶层前缀分类统计**
```bash
git status --short | awk '{print $1, $2}' | sed 's|/.*||' | sort | uniq -c | sort -rn
```
输出：
```text
     10 D plans
      9 ?? plans
      5 M plans
      1 ?? .zcode
      1 M .zcode
```

**命令 C：本巡检目录 vs 其他**
```bash
git status --short -- plans/task-project-audit-20261123/
# => ?? plans/task-project-audit-20261123/
git status --short | grep -v 'plans/task-project-audit-20261123/'
# => 其余 25 条
```

### 5.2 分类明细

| 类别 | 条目数 | 证据（status code） | 归属判定 |
|---|---:|---|---|
| 本巡检新建 | 1 | `?? plans/task-project-audit-20261123/` | **本任务巡检产物**（本次创建 forensics 目录导致），非脏污染 |
| 其他会话在途 - task-cli-help-examples-20261122 | 23 | `D` 10 条（.fix_vcs*.py + 8 条旧 .history 快照）；`M` 5 条（findings/progress/task_plan/verification/plan-state.json）；`??` 8 条（较新 .history 快照） | **已知他会话在途工作/计划态变更**，与 2026-11-22 已合并的 task-cli-help-examples 计划目录相关，禁止建议清理 |
| 其他会话在途 - .zcode/plans | 2 | `M .zcode/plans/plan-sess_66ec6ec3-...md`；`?? .zcode/plans/plan-sess_d0c282be-...md` | **会话计划文件在途变更**，禁止建议清理 |

### 5.3 判定

- **现象**：工作区共 26 条变更；除本巡检目录 1 条外，其余 25 条全部位于 `plans/task-cli-help-examples-20261122/` 与 `.zcode/plans/`。
- **证据**：命令 A-C。
- **根因推断**：`task-cli-help-examples-20261122` 目录存在计划态文件更新（M）、历史快照轮替（D 旧快照 + ?? 新快照）以及临时修复脚本删除（`.fix_vcs.py/.fix_vcs_r3.py` D）。这与 plan-state/history 的正常演进形态一致；无法仅凭只读证据断言是否“应提交”，但可明确其为**他会话在途计划工作**，不是随机垃圾。
- **严重度**：**P2**（工作区非干净，但变更集中在已知计划目录；无源码/配置误改迹象）。
- **建议（仅文字，不执行）**：**禁止清理/回滚这些在途变更**。由对应会话负责人在其任务收口时决定提交或保留；本巡检报告目录 `plans/task-project-audit-20261123/` 是否入库由本任务负责人决定。

---

## 6. 总体判定汇总

| # | 检查项 | 现象 | 证据 | 根因推断 | 严重度 | 建议（不执行） |
|---|---|---|---|---|---:|---|
| 1 | 分支拓扑 | `master` ahead `origin/master` 40；`main`=origin/main/origin/HEAD=`15a3ecf`；`merge-base master main` rc=1 | §1 A-E | 双主线历史分叉；本地 master 开发未推送 | **P1** | 明确主线策略后再同步远端；勿盲合并/重置 |
| 2 | worktree 残留 | 1 个 worktree 已注册且目录存在；非孤儿 | §2 A-D | 在途/保留 tplsys worktree | **P2** | 由任务所有者确认合并或保留；勿 prune/remove |
| 3 | wt/* 分支 | 2 个本地 wt 分支，无远端 wt | §3 A-B | tplsys 活跃；v168 明确封存 | **P2** | 保留直至所有者确认；封存分支不按垃圾清理 |
| 4 | stash | 1 条，2026-10-07，基于 d806d05，3 文件 | §4 A-B | 历史 WIP 暂存，可能过期 | **P2** | 所有人确认前勿 pop/drop/clear |
| 5 | 工作区脏状态 | 26 条：1 条本巡检 + 25 条他会话在途 | §5 A-C | 计划态演进与会话文件变更 | **P2** | 禁止清理他会话变更；由各任务收口处理 |

## 7. 明确排除（非问题）

- `?? plans/task-project-audit-20261123/`：本次巡检按要求创建的检查点目录，**不是**预存脏状态。
- `plans/task-cli-help-examples-20261122/` 下的 M/D/??：与已知任务目录一致，呈现 plan-state/history 轮替特征，**判定为他会话在途工作，不是垃圾，不建议清理**。
- `.zcode/plans/plan-sess_*.md` 的 M/??：会话级计划文件，**在途状态，不建议清理**。
- `wt/task-v168-machine-parked`：提交信息已明确封存/未合并/未部署，**不是异常残留分支**。
- `tmp/worktrees/wt-tplsys-upgrade-20261117`：目录存在、gitdir 有效、worktree 已注册，**不是孤儿元数据**。

## 8. 证据复现命令清单

```bash
# 分支拓扑
git branch -a -vv
git merge-base master main; echo "rc=$?"
git rev-parse master main origin/master origin/main origin/HEAD
git rev-list --left-right --count origin/master...master
git rev-list --left-right --count origin/main...main
git log --oneline -12
git log --oneline --decorate -5 master
git log --oneline --decorate -5 origin/master
git log --oneline --decorate -5 main

# worktree
git worktree list --porcelain
ls -la .git/worktrees/
cat .git/worktrees/wt-tplsys-upgrade-20261117/gitdir
cat .git/worktrees/wt-tplsys-upgrade-20261117/HEAD
test -d tmp/worktrees/wt-tplsys-upgrade-20261117 && echo EXISTS_DIR || echo MISSING_DIR
git -C tmp/worktrees/wt-tplsys-upgrade-20261117 status --short

# wt 分支
git for-each-ref --sort=-creatordate --format='%(refname:short)|%(objectname:short)|%(creatordate:iso8601)|%(subject)' refs/heads/wt refs/remotes/origin/wt

# stash
git stash list --format='%gd|%ci|%gs'
git stash show --stat stash@{0}

# 工作区脏状态
git status --short
git status --short -- plans/task-project-audit-20261123/
git status --short | grep -v 'plans/task-project-audit-20261123/'
```