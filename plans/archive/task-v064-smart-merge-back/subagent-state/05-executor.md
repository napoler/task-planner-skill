# 05-executor — Phase 5 / S1 全量回归自检（只读执行，零改动）

> status: done（测试执行完成；验收 2/3 PASS，1 项 FAIL）
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v064-smart-merge-back
> branch: wt/task-v064-smart-merge-back
> HEAD: 928febbb5b4b4506c17441ed1d614daa4a9c2020（跑前跑后一致）

## 1. 7 套件结果（均 EXIT=0, FAIL=0；合计 113 用例）

| # | 套件 | Total / PASS / FAIL | EXIT | 期望 | 结果 |
|---|------|--------------------|------|------|------|
| 1 | selftest-smart-merge.sh | 7 / 7 / 0 | 0 | 7/7 | PASS |
| 2 | selftest-dispatch.sh | 18 / 18 / 0 | 0 | 18/18 | PASS |
| 3 | selftest-active-plan.sh | 13 / 13 / 0 | 0 | 13 | PASS |
| 4 | selftest-delegation.sh | 38 / 38 / 0 | 0 | 38 | PASS |
| 5 | selftest-plan-dispatch.sh | 6 / 6 / 0 | 0 | 6 | PASS |
| 6 | selftest-fallback.sh | 21 / 21 / 0 | 0 | 21 | PASS |
| 7 | selftest-interaction.sh | 10 / 10 / 0 | 0 | 10 | PASS |

合计 Total=113 PASS=113 FAIL=0。命令：`cd /tmp && bash <worktree>/skills/task-planner/scripts/<suite>.sh`。

observation（非 FAIL）：selftest-fallback T07 段 stderr 有 2 处 jq 编译报错
（`.files[\"executor-fb.md\"].hash` 引号转义），系测试脚本 heredoc 内联 jq 引号问题，
断言 T07a/T07b/T07c 均 PASS，不构成 FAIL，与智能门无关。

## 2. verify.sh 结果：22 pass / 3 fail（EXIT=1，期望 25/0）→ FAIL

命令：`cd /tmp && TASK_PLANNER_ROOT=<worktree>/skills/task-planner bash <worktree>/skills/task-planner/lib/verify.sh`
summary: `[verify] summary: 22 pass / 3 fail`

3 个 FAIL（verify.sh line 89 分支，cmp 不一致）：
- `claude-code deploy drift: full-copy SKILL.md differs from canonical (/home/terry/.claude/skills/task-planner)`
- `zcode deploy drift: full-copy SKILL.md differs from canonical (/home/terry/.zcode/skills/task-planner)`
- `opencode deploy drift: full-copy SKILL.md differs from canonical (/home/terry/.opencode/skills/task-planner)`

### 根因（第一手 md5 证据，HIGH）
- worktree canonical `skills/task-planner/SKILL.md`：48310 B, md5 `6f366e6f35751d6725298921dddb132a`
- 三处已安装 deploy SKILL.md：49044 B, md5 `207fb9f93cdb58846db80384a32d00b8`（三者互相同）
- 主仓 master（/mnt/data/dev/task-planner-skill 工作区，HEAD 9abca90）canonical SKILL.md：
  49044 B, md5 `207fb9f93cdb58846db80384a32d00b8` == deploy（byte 一致）

即：deploy 安装自 master 版本；worktree canonical 与之双向分叉（`diff` 实证）：
- worktree 多出 v064 smart-merge 文案（`smart-merge-back.sh` 两处 bullet），deploy 为旧文 `git merge wt/<task-id>`
- worktree 缺少 master/deploy 已有的 v063 行（Poka-Yoke 前置条件检查 + 内容质量门控 + methodology 指针）
- git 拓扑：`merge-base(worktree HEAD, master)=3391f64`；master HEAD 9abca90 **不是** worktree HEAD 祖先
  → worktree 分支基线 3391f64 早于 v063 合并，故缺 v063 内容

结论：3 处 drift 为 **worktree 前进（v064 未部署）+ 分支基线偏离 master（缺 v063）** 的环境/基线产物，
**非 smart-merge 智能门逻辑回归**（smart-merge 专属 7 用例全绿，且失败项仅 deploy 对账面）。

## 3. 零改动验证（PASS）
- pre `git status --short`: 0 行（clean）
- post `git status --short`: 0 行（clean）
- `diff pre post` exit=0；HEAD 928febb 不变 → worktree 零改动

## 验收
1. 7 套件 EXIT=0 且 FAIL=0，合计 ≥113 用例 → PASS（113/0）
2. verify.sh 25/0 → FAIL（实测 22/3，根因见上）
3. worktree git status 跑前后一致 → PASS

## blockers
verify.sh 3 处 deploy drift（非智能门回归）：需在 Phase 6 合并回后由
`smart-merge-back.sh --deploy` 重新部署对齐，或先 rebase 补齐 v063 基线；本轮只读不修复。
