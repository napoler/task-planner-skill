# Seq-9 合并与部署检查点（merge + 部署位逐文件对账）

> 执行者：合并部署执行者。时间：2026-10-24。全程未 push（未获授权）。

## 1. 提交与合并链

| 动作 | 仓 | commit | 说明 |
|------|----|--------|------|
| worktree 提交 | wt/task-subagent-boost-20261023 | `e319ee3` | feat(rules): Rule 96 子代理激活默认与并行推进强化 (task-subagent-boost-20261023)；8 files changed, +135/-10；提交后 worktree 干净 |
| 台账单独提交 | master | `6d60e02` | chore(rules): reserve Rule 96 (attest 自动登记)；仅 plans/.rule-reservations.jsonl（+2 行：rule95/nopause、rule96/本任务） |
| merge --no-ff | master | **`cecacfb`** | Merge branch 'wt/task-subagent-boost-20261023'：双亲 6d60e02 + e319ee3，ort 策略，8 files changed, +135/-10，零冲突 |

- **mergeCommit = cecacfb**（`git log -2` 顶部即此 merge commit，双亲哈希已核对）
- master 合并后剩余 untracked：plans/task-nopause-execfirst-20261023/subagent-state/4a-selftest.md、4b-vc-verify.md（其他任务产物，未动）、plans/task-subagent-boost-20261023/（本计划目录，留主进程归并）

## 2. 合并后复核（步骤 3）

- ask 字面命令 `grep -n "96\.1" skills/task-planner/critical-rules.md` → **No such file or directory**（exit=2；ask 路径少 `references/` 一级，如实记录未硬凑）
- 真实路径替代执行：
  - `grep -n "96\.1" skills/task-planner/references/critical-rules.md` → 0 命中（该文件为路由索引格式），但 `grep ",96"` → **critical-rules.md:193** 命中（卫星路由索引追加 `,96`）✅
  - `grep -n "96\.1" skills/task-dispatch/references/critical-rules-dispatch.md` → **:192** 命中（Rule 96 正文「96.1 激活默认档矩阵」）✅
- `git log -2` → 顶部 cecacfb（merge commit）✅

## 3. 部署位逐文件对账表（16/16 diff=0）

映射来源：subagent-state/3-deploy-reserve.md §1（zcode 根=/home/terry/.zcode/skills/，cursor 根=/home/terry/.cursor/skills/，相对路径=根下直拼）。源=合并后 master。命令：mkdir -p + cp + diff -q。

| 文件（根下相对路径） | zcode | cursor |
|---------------------|-------|--------|
| task-dispatch/references/critical-rules-dispatch.md | OK diff=0 | OK diff=0 |
| task-planner/SKILL.md | OK diff=0 | OK diff=0 |
| task-planner/references/critical-rules.md | OK diff=0 | OK diff=0 |
| task-planner/scripts/run-selftests.sh | OK diff=0 | OK diff=0 |
| task-planner/scripts/selftest-registry.tsv | OK diff=0 | OK diff=0 |
| task-planner/scripts/selftest-subagent-activation.sh（新增） | OK diff=0 | OK diff=0 |
| task-planner/templates/subagent_dispatch.md | OK diff=0 | OK diff=0 |
| task-planner/templates/task_plan.md | OK diff=0 | OK diff=0 |

部署位锚复核：两侧 critical-rules-dispatch.md `96.1` 均 :192 命中；两侧 critical-rules.md `,96` 各 1 命中。`.drift-rhythm/` 目录零触碰。

## 4. 事故记录与处置（如实曝光）

**事故**：第一次部署误用仓内路径前缀（`skills/` 未剥离），目标写成 `$root/skills/task-planner/...`，cp 落入两部署位下**历史遗留的同构镜像树** `$root/skills/`（该树含 6 个非本次写入的既有文件：plan-collab-router、plan-template-kit、task-planner/companion/agents/plan-writer.md、selftest-tool-selection.sh、selftest-workflow-orchestration.sh 等，非本次创建、非 skill 加载路径）。

**影响**：该树内 7 个同名既有文件被本次 cp 覆盖为 Rule 96 新版（原内容无备份，无法精确还原）；另有 1 个文件（selftest-subagent-activation.sh）为本次误新建。

**处置**：① 误新建文件已按精确路径 rm 移除（两处，`ls` 复核均 No such file）；② 7 个被覆盖文件未做二次猜测式回写（历史遗留树不属本次射程、任何回写均为新写入而非恢复）——留待用户授权后决定：以正确位旧版回写还原或整树清理；③ 运行影响=零（`skills/skills/` 不在资源发现顺序内）。

## 5. pending

1. 历史遗留镜像树 `$root/skills/`（zcode+cursor 两处）内 7 个同名文件被本次误 cp 覆盖、原内容不可精确还原——待用户授权处置（该树非加载路径、无运行影响）
2. master 上 2 个未跟踪的 nopause 检查点属其他任务，本 ask 未动
3. 未 push（全程遵守）
