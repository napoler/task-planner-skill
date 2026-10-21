---
id: worktree-lifecycle-mergeback
title: "worktree 生命周期、合并回与部署位同步"
tags: [worktree隔离, 合并回合约, 部署位同步, git安全, 智能合并]
sources: [plans/archive/task-git-timely-commit/findings.md, plans/archive/task-v059-active-plan-race/findings.md, plans/archive/task-v159-pointer-lifecycle/findings.md, plans/archive/task-v159-pointer-lifecycle/subagent-state/4-code-assistant-SM.md, plans/archive/task-v159-pointer-lifecycle/subagent-state/4-code-runner-S8.md, plans/archive/task-v164-pointer-worktree-local/findings.md, plans/archive/task-v164-pointer-worktree-local/delivery-summary.md, plans/archive/task-deploy-9b167fe/findings.md, plans/archive/task-deploy-master-20260905/findings.md, plans/archive/task-v182-git-snapshot-commits/findings.md, plans/archive/task-v195-spec-recall/progress.md, plans/archive/task-videop1-ep03-rollback-guard/progress.md]
updated: 2026-10-22
---

# worktree 生命周期、合并回与部署位同步

## 结论（可直接复用）

1. **worktree 目录 ≠ 生效环境**：skill 脚本/hook 取的是主仓指针，旧版 check-dispatch 按主仓 `.active_plan` 校验 → worktree 任务被判「三文件缺项」拦截。修法三步：`ln -sfn <worktree>/plans/<task>` 到主仓同名路径 → `set-active-plan.sh set <task> --sid <sid> <主仓>` → 主仓 legacy 指针写 `<task>`。〔task-v059〕
2. **新建 worktree 文件不随主仓同步**：新树默认无全局指针（走 mtime 兜底）；实测 worktree HEAD `7317455` 是 master 的祖先、master 领先 16 提交 → 基线 ≠ master tip，回归口径须标注偏差并交主进程裁决是否 rebase。〔task-v164〕
3. **逐 Phase 提交（Rule 27）**：Phase 翻转 complete 前必提交到 worktree 分支、禁攒批；只 add scope 产物、**禁 `git add -A` / `git add .`**；提交后 `git status --porcelain -- <scope>` 必须为空；豁免须声明 `git_commit: deferred`；恢复会话发现未提交变更先补提交再继续。〔task-git-timely-commit〕
4. **提交必须早于 `git worktree remove`**：三条丢失路径=会话中断、误操作 `git clean -fd` / `git reset --hard`、提交前 remove 致整个隔离区归零；逐 Phase 提交把最坏损失收敛为单 Phase 增量。〔task-git-timely-commit〕
5. **合并回合约五条（宪法 §11.3）**：① Phase 全 complete + VC 逐条复验 → ② worktree status 干净 → ③ 主仓无重叠未提交变更（否则 STOP 报告用户）→ ④ `git merge --no-ff wt/<id>` + Read 关键文件 + `git log` 复验 → ⑤ **必须** `git worktree remove` + `git branch -d`（遗留 `wt/*` 分支 = 未完成信号）。首锚语义=确保基线存在（工作区干净则登记 HEAD 为基线锚），禁无条件空提交。〔task-git-timely-commit / task-v182〕
6. **瞬态文件冲突取分支版本，禁抢救内容**：`.dispatch-inflight` 被 git 跟踪 → 二轮合并与主仓 unstaged D 撞车，最小处置 restore 后合并（分支版本胜出）；`.active_plan` 合并取删除/忽略态，各会话 set 再生。〔task-v164〕
7. **部署位必须原子化：staging → swap → post-verify**：D4 事故（04:45:38 `~/.claude` 已写入，04:49:07 `~/.zcode` slot 被删后中断 → 技能全局停摆，靠仓内源原子恢复）。新契约消息=`[DEPLOY] STAGE-FAIL: <slot>`（rc=1）/ `[DEPLOY] SWAPPED: <slot>`（逐位）/ `[DEPLOY] OK: 全部部署位 IDENTICAL`（终行 rc=0）；`--legacy` 保留 IDENTICAL/DRIFT + exit 6。〔task-v159〕
8. **改 deploy 契约必须同步 selftest 断言**：旧断言期望 rc=6 + `[DEPLOY] IDENTICAL: <slot>` → SM-06/SM-14 FAIL（`Total: 17 PASS=15 FAIL=2`）。修法=断言对齐新契约（断 rc=1+STAGE-FAIL+s1 存活+marker 未变 / 断终行 OK+逐位 SWAPPED），**不给实现回补旧消息**；波及面已 grep 实证：消费者全仓仅 `selftest-smart-merge.sh` 一处。〔task-v159〕
9. **部署位同步 SOP**：canonical 主仓为唯一 truth source → `git diff --name-status` 定位范围 → 兄弟位 `diff -rq` IDENTICAL 则零改动 → 重部署位用 `rm -rf && cp -rL`（cp 覆盖不删目标多余文件 → master 已删的 `WORKFLOW.md` 会留残影）→ 替换前 tar 备份 /tmp → 逐位 `diff -rq` 终验 IDENTICAL。〔task-deploy-9b167fe / task-deploy-master-20260905〕
10. **部署位 ≠ 仓内全量**：仓根 `.gitignore` 不在技能目录 → 部署 diff 不含它是**预期差**，禁为「补齐」造部署差异。〔task-v164〕
11. **回滚 merge commit 必须带主父**：`git revert -m 1 <merge-sha>`（直接 revert merge 会失败）；部署位回滚由 `smart-merge-back.sh --deploy` 从主仓重推。〔task-v164〕
12. **并行在途提交限定 pathspec；慢 checkout 禁 TaskStop**：`git add`+裸 `commit` 提交的是整个 index → 他会话已暂存的 3 个 rename 搭车（`4e88cf3`），改 `git reset --soft HEAD~1` + `git commit -m … -- <pathspec>` 重提（`b169843`）并核 `git log -1 --stat`；慢 checkout 被 TaskStop 会留 index.lock，半成品 worktree 还可能被外部清理器当残留删除 → 用 `worktree add <path> <既有分支>` 重建（**不带 `-b`**）。〔task-videop1-ep03 / task-v195〕

## 证据锚

| 锚 | 事实 | 来源任务 |
|----|------|---------|
| plans/archive/task-v059-active-plan-race/findings.md:46,52-57 | worktree `cp -f` 落盘 + `diff -rq` 0 differ；旧 hook 按主仓指针误拦；symlink+`--sid`+legacy 三步修法 | task-v059 |
| plans/archive/task-git-timely-commit/findings.md:27,29-33,36 | 合并回合约仅 #2 一次性查干净；三条丢失路径；Rule 27 六细则；逐 Phase 提交细化 §4③ | task-git-timely-commit |
| plans/archive/task-git-timely-commit/findings.md:66-70 | merge commit `9b167fe`（--no-ff）+ worktree remove + 分支已删 + 部署位落后待重部署 | task-git-timely-commit |
| plans/archive/task-v159-pointer-lifecycle/findings.md:20,23 | F5 实弹 `[DEPLOY] OK` exit 0 + 三 slot diff -q IDENTICAL；D4 删后写中断窗事故 | task-v159 |
| plans/archive/task-v159-pointer-lifecycle/subagent-state/4-code-assistant-SM.md:3-4 / 4-code-runner-S8.md:29-34 | SM-06/SM-14 断言对齐 F5 契约（rc=1+STAGE-FAIL / 终行 OK+SWAPPED），Total 17/17；新旧消息漂移取证 | task-v159 |
| plans/archive/task-v164-pointer-worktree-local/findings.md:59,64 | `.dispatch-inflight` 跟踪导致二轮合并撞车；worktree HEAD 7317455 为 master 祖先、master 领先 16 提交 | task-v164 |
| plans/archive/task-v164-pointer-worktree-local/delivery-summary.md:3,53-54 | 合并基线 `a849947`（--no-ff）+ 三部署位 post-verify IDENTICAL；失效条件与 `git revert -m 1` 回滚路径 | task-v164 |
| plans/archive/task-deploy-9b167fe/findings.md:20-31 / task-deploy-master-20260905/findings.md:15-18,25 | 8 文件变更范围/9 位拓扑/cp 覆盖留残影/rm -rf+cp -rL/9-9 IDENTICAL；8 位字节级一致 + 唯一落后位；同步前 tar 备份 | task-deploy-* |
| plans/archive/task-v182-git-snapshot-commits/findings.md:41 | 首快照语义=确保基线存在，禁无条件空提交；merge --no-ff | task-v182 |
| plans/archive/task-videop1-ep03-rollback-guard/progress.md:106 / task-v195-spec-recall/progress.md:126 | 裸 commit 卷入并行会话 rename → pathspec 限定重提；TaskStop 误杀 checkout 留 index.lock + 半成品 worktree 被外部删除 | task-videop1-ep03 / task-v195 |

## 易错点

- **别把「worktree 已建」当「环境已生效」**：未做软链 + `--sid` + legacy 三步，hook 会按主仓计划目录校验并误拦（task-v059）。
- **别拿 worktree 基线当 master 基线**：worktree HEAD 常落后 master 多提交，回归结论必须标注口径（task-v164）。
- **别用 `git add -A`/`git add .`，也别裸 `git commit`**：前者扫入 scope 外文件，后者把并行会话暂存内容一起提交（task-git-timely-commit / task-videop1）。
- **别在提交前 `git worktree remove`**：隔离区工作归零且不可恢复（task-git-timely-commit）。
- **别忘清理 `wt/*` 分支**：遗留分支 = 下次冲突预警信号（宪法 §11.3⑤）。
- **别手工抢救瞬态文件的冲突值**：`.active_plan` / `.dispatch-inflight` 属即写即弃运行态，取删除/分支版本即可（task-v164）。
- **别用 `cp -rL` 单跑一次当部署完成**：cp 不删目标多余文件，须 `rm -rf` 整目录替换 + `diff -rq` 终验（task-deploy-9b167fe）。
- **别把「部署 diff 不含 .gitignore」当漏部署**：仓根文件不随技能部署，属预期差（task-v164）。
- **别在改了 deploy 消息/退出码后不复跑 `selftest-smart-merge.sh`**：断言漂移会以 FAIL 暴露，但根因在契约不同步（task-v159）。
- **别直接 `git revert <merge-sha>`**：merge commit 需 `-m 1`（task-v164）。

## 适用场景

- 实现类任务在 git worktree 隔离开发区（技能/agent 定义、scripts、配置、CI、部署位相关改动）。
- 任务收尾：Phase 全完成 → 逐 Phase 提交 → 合并回 master → 清理 worktree 与分支 → 部署位原子化发布与对账。
- 发布后回滚：merge commit revert + 部署位重推。
- 并行会话在途时提交本任务 scope 产物，或需从被误删的 worktree 恢复。
- 审查他任务时核对「worktree status 干净 / 分支已清理 / 部署位 IDENTICAL」三条收尾证据。
