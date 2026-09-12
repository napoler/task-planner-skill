# Findings & Decisions — task-v064-smart-merge-back
<!-- Rule 19.1: 子代理/调研返回后紧邻回填;Rule 3: 每 2 次 view/search 后更新 -->

## Requirements
- 用户指令（2026-09-12）：「我希望可以智能合并」→ 经 D5 选项澄清，用户选 **A 合并回智能门**：把"合并回 master"从手工三步升级为智能门——预检（worktree 干净/master 无 scope 重叠/master 前进检测）+ **已合并自动检测**（另一窗口已 merge → 跳过合并转簿记补全，消灭双窗口人工考古）+ 合并执行 + 可选 `--deploy` 自动重部署 3 位+diff/verify 对账。
- 直接动因：v062 交付时的双窗口事故（续跑窗口已合并而本窗口不知情，人工 git 考古重建状态）。

## 📚 必要知识储备对齐记录
| 知识源 | 定位 | 已消费 | 结论落点 |
|--------|------|--------|---------|
| memory: interruption-recovery-first-verify | memory 目录 | ☑ | 已合并检测 = 该记忆的机制化（ALREADY_MERGED 分支） |
| memory: task-planner-repo-deploy-flow | memory 目录 | ☑ | --deploy 复用 rm+cp -rL+diff -rq SOP；中性 CWD 口径 |
| worktree-isolation.md §4 合并回合约 | references | ☑ | 联动嵌入点（5 条合约→脚本 V1-V6 映射） |
| SKILL.md :158/:216 合并回 bullets | SKILL.md | ☑ | 联动嵌入点（两处指针） |
| README.md :36/:80 脚本计数 | README | ☑ | 16→17 联动 |
| v060 挂账缺陷 | memory deploy-flow | ☑ | `set-active-plan.sh set` 路径嵌套 bug 本轮实锤（见 Issues），不在本任务 scope |

## Research Findings

### 嵌入点原文摘录（派发材料包源，2026-09-12 取自 master 3391f64）
- **worktree-isolation.md §4 合并回合约**（:70-79）：
  ```
  1. worktree 内全部 Phase = complete,VC 逐条复验通过
  2. worktree 内无未提交变更(git status 干净)
  3. 主仓无与任务范围重叠的未提交变更(信号①残余风险;有 → STOP 报告用户)
  4. merge 后:主仓 Read 关键文件复验 + git log 确认 merge commit
  5. 清理 worktree 与分支;task_plan.md「隔离决策」merge_back 更新为 merged(<commit>)
  ```
  失败处理：merge 冲突 → STOP 报告用户(不自动解决)；worktree 内验证失败 → 修到通过才合并，3 次失败升级用户。
- **SKILL.md:158**：`- **隔离任务合并回**（isolation=worktree 时，按 references/worktree-isolation.md 合约）：worktree 内全 VC 复验且无未提交变更 → 主仓 git merge wt/<task-id> → git worktree remove + git branch -d → 主仓 Read 关键文件复验`
- **SKILL.md:216**：`**完成后主动合并回**（合约见 references/worktree-isolation.md）：worktree 内全 VC 复验 → 主仓 git merge wt/<task-id> → git worktree remove + 删分支 → 主仓 Read 关键文件复验合并结果。复杂场景可配合 Skill("using-git-worktrees")。`
- **README.md**：:36 `scripts/     (16 个工具脚本)` 与 :80 `├── scripts/                                 ← 16 个工具脚本`（两处计数联动 16→17）
- **旁证（既存先例）**：check-dispatch.sh 的档位/fail-open 范式、selftest-dispatch.sh 的 hermetic 夹具范式（临时目录+trap 清理+Total 汇总行）

### smart-merge-back.sh 设计（材料包源，Phase 2 照此实现）
**接口**：`smart-merge-back.sh <worktree-path> [--base master] [--deploy] [--force]`
- worktree-path 必填；branch 由 `git -C <worktree> branch --show-current` 取得（须匹配 `wt/<task-id>` 且目录名 = task-id，双校验）
- 主仓路径 = `git -C <worktree> worktree list` 解析（主仓 = 不带 branch 的工作树行），禁止假设 CWD
- base 分支默认 master，可 --base 覆盖

**检查序列（每步一行结构化输出 `[Vn] VERDICT: 详情`，机器可解析；成功路径 exit 0）**：
- V1 前提：worktree 目录存在 + 分支名 wt/* + 在主仓 worktree list 在册 → 失败 exit 2 `PRECHECK_INVALID`
- V2 worktree 干净：`git -C wt status --porcelain` 为空 → 否则 exit 3 `PRECHECK_DIRTY`(列出文件)
- V3 master scope 重叠：主仓未提交文件集 ∩ 分支相对 merge-base 的变更文件集 → 非空 exit 4 `SCOPE_OVERLAP`(列出交集)
- V4 **已合并检测**：`git merge-base --is-ancestor <branch> master` → 是则输出 `[V4] ALREADY_MERGED: <branch> 已在 master(merge-base <sha>)`，**跳过合并**（这就是双窗口事故的机械判据）；继续清理提示与 --deploy
- V5 master 前进检测：master HEAD ≠ merge-base → 警告并 exit 5 `MASTER_AHEAD`（建议先在 worktree 内 `git merge master` 再重跑；`--force` 才继续，冲突仍 STOP——对齐合约"冲突不自动解"）
- V6 合并执行：`git -C <主仓> merge --no-ff <branch>` → `[V6] MERGED: <commit>`；冲突 exit 7 `MERGE_CONFLICT`(STOP 语义)
- 清理提示：MERGED/ALREADY_MERGED 后输出 `[CLEANUP] git worktree remove <path> && git branch -d <branch>`（**不自动执行**——ALREADY_MERGED 场景可能需先补簿记，清理时机留主进程）
- `--deploy`（可选）：对部署位执行既有 SOP（`rm -rf <位> && cp -rL <skill-根> <位>` → `diff -rq` → 逐位 `[DEPLOY] IDENTICAL|DRIFT: <位>`）；slot 列表 env `TASK_PLANNER_DEPLOY_SLOTS`（冒号分隔）覆盖供自测注入；skill 根 = `${BASH_SOURCE%/*}/..`；任一位 DRIFT → exit 6 `DEPLOY_DRIFT`
- 通用：`set -u`；无 jq 依赖；失败路径显式 exit 码（2-7）+ stderr 说明

### selftest-smart-merge.sh 设计（7 用例，hermetic 临时 git 仓）
- 夹具：mktemp -d + `git init --bare origin.git` + clone 出 `<tmp>/main`（master）+ `git -C main worktree add <tmp>/wt -b wt/task-test`；用例独立 tmp，trap 清理
- SM-01 脏 worktree → exit 3 PRECHECK_DIRTY
- SM-02 干净+无重叠 → V6 MERGED 且 master log 出现 --no-ff merge commit
- SM-03 已合并（先手工 merge 分支进 master 再跑）→ V4 ALREADY_MERGED、exit 0、master 无新 commit
- SM-04 master 前进（主仓直接 commit）→ exit 5 MASTER_AHEAD
- SM-05 scope 重叠（主仓未提交文件 = 分支将改文件）→ exit 4 SCOPE_OVERLAP
- SM-06 --deploy（env 注入两个临时 slot：一新一旧）→ IDENTICAL+DRIFT 判定正确，DRIFT exit 6
- SM-07 MERGED 后有 [CLEANUP] 行且脚本未删除 worktree

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 已合并检测用 `merge-base --is-ancestor` | git 原生祖先判定零误报；v062 双窗口事故的机械判据 |
| MASTER_AHEAD 默认中止不自动代 merge | 对齐合约"冲突 STOP"；自动代 merge master 入分支 = 代替用户做策略分叉（D2） |
| 清理不纳入脚本 | ALREADY_MERGED 场景可能需先补簿记/Read 复核；清理时机留主进程，脚本只提示 |
| 不新增 config.json 键 | 调用期 flag 而非阈值；避免键表/README/resolve 联动膨胀 |
| 与 task-v063 并行的 scope 隔离 | v063 改执行循环/config 键/新 methodology.md；本任务只碰 合并回 SOP 区+新脚本+selftest+README 计数——SKILL.md 两处 bullet 在终验区，不与 v063 执行循环区重叠 |
| --deploy 序列化既有 SOP | 部署语义单一权威源 = memory deploy-flow（rm+cp -rL+diff -rq）；脚本不发明新语义 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| `set-active-plan.sh set <task-id>` 路径嵌套错位报"计划不存在"（v060 挂账）本轮实锤：计划目录内与仓根均复现；裸 `<task-id>` 形式正常 | 本任务不改该脚本（scope 外）；已用裸形式绕过；登记后续轮修复 |
| 会话 sid 双拼写（`sess<uuid>` vs 剥前缀）：side 文件 sess 前缀写入后 `set-active-plan --show --sid` 查不到 | 注入链(resolve-plan-dir)实测兼容；--show 单拼写——观测项登记，不阻塞 |

## Resources
- 同构先例：plans/task-v061-serial-dispatch/、plans/task-v062-interaction-modes/
- 被机制化的手工流程：v062 progress.md「Phase 4-8 续跑执行」段（双窗口考古全记录）

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7) -->
