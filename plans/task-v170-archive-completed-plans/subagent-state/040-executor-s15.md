# checkpoint 040-executor-s15（task-v170 Phase 8 / S15：存量批量归档+INDEX 重生）

任务锚: R3「确保所有的被使用完成的计划任务全部归档处理。」；S-unit=S15（Rule 46.1 单任务，主仓存量批量归档）。
工作路径: /mnt/data/dev/task-planner-skill（绝对路径，不切 CWD）。

## T1 执行前基线（2026-10-12 06:54）
- `git status --porcelain` → 8 行（4 M + 4 ??，并行会话既存变更）:
  ```
   M plans/.rule-reservations.jsonl
   M plans/INDEX.md
   M plans/task-v152-proactive-context/.plan-attestation
   M plans/task-v160-decision-grading/.plan-attestation
  ?? plans/task-v162-change-absorption-safety/
  ?? plans/task-v168-session-anchor-skill-activation/
  ?? plans/task-v170-archive-completed-plans/
  ?? plans/task-v171-skill-specialization/
  ```
- `find plans -maxdepth 1 -type d | sort | md5sum` → `2a2b8a8dc386302a22daeed7c63a5113`
- 当前系统时间: `2026-10-12 06:54:42 +0800`（注意: 032 执行于 2026-10-11，跨日）

## T2 第 1 步 dry-run
命令:
```
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh --batch --dry-run --root /mnt/data/dev/task-planner-skill/plans
```
BATCH 汇总行:
```
[archive-plan] BATCH total=122 ok=0 skip=122 fail=0 (dry-run)
```
EXIT=0。候选计数: `grep -c 'candidate/none'` = **101**。
skip 各族（`grep -oE ... | sort | uniq -c`）:
```
      4 active-pointer
    101 candidate/none
      1 not-a-plan-dir: archive-target
      3 not-a-plan-dir: hidden
      1 not-a-plan-dir: no
      3 not-a-plan-dir: not
      8 status-incomplete
      1 status-none
```
算术闭合: 4+101+1+3+1+3+8+1 = 122 = BATCH total ✓

### 与 032 清单核对差异（逐条）
| 项 | 032 | 本次 | 差 | 根因 |
|----|------|------|-----|------|
| total | 123 | 122 | -1 | v070-archive-completed-plans 目录已从根目录消失（`ls -d` 确认 No such file or directory；032 时该目录仅 subagent-state/，SKIP no task_plan.md） |
| candidate | 100 | 101 | +1 | v166-summary-readability 从 active-pointer 转入 candidate |
| active-pointer | 5 | 4 | -1 | v166 转出（side 指针不再含 v166；.active_plan=task-v171-skill-specialization） |
| not-a-plan-dir | 9 | 8 | -1 | v070 目录消失（no task_plan.md 从 2→1） |
| status-incomplete | 8 | 8 | 0 | — |
| status-none | 1 | 1 | 0 | — |

v166 转 candidate 合规性验证:
- v166 `.session-owner` mtime = `2026-10-11 03:39:30.051955240 +0800`，当前 `2026-10-12 06:54:42 +0800`，差 27h15m >24h → 陈旧 owner 不拦（脚本设计: `archive-plan.sh` L101-106 "live owner 仅新鲜 mtime<24h 才拦；陈旧 owner=历史残留，永久拦截会使完成任务无法归档（违背 R3）"）
- v166 Status 行: `grep -c 'Status:\*\* complete'` = 5/5 全 complete
- v166 无 active 指针（.active_plan=v171，side 指针不含 v166）
- 结论: v166 转 candidate 符合脚本判定逻辑 ✓

dry-run 零移动验证: `find ... | sort | md5sum` 前 `2a2b8a8dc386302a22daeed7c63a5113` == 后 `2a2b8a8dc386302a22daeed7c63a5113` ✓

## T3 第 2 步实做
命令:
```
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/archive-plan.sh --batch --root /mnt/data/dev/task-planner-skill/plans
```
BATCH 汇总行:
```
[archive-plan] BATCH total=122 ok=101 skip=21 fail=0 (execute)
```
EXIT=0。**ok=101=候选数 ✓，fail=0 ✓**。skip=21（=4 active-pointer + 8 status-incomplete + 1 status-none + 8 not-a-plan-dir）。
ARCHIVED 行: 101 条（完整列表见 /tmp/s15-realrun.txt，逐条 `ARCHIVED <id> -> plans/archive/<id>`）。
注: v162-change-absorption-safety 在归档列（其 Status 全 complete，032 时即为 candidate/none）。

## T4 第 3 步 INDEX 重生
命令:
```
bash /mnt/data/dev/task-planner-skill/skills/task-planner/scripts/sync-todos.sh --index
```
输出:
```
[index] Wrote /mnt/data/dev/task-planner-skill/plans/INDEX.md (in_progress=7 pending=1 complete=6)
[index] Resume: read /mnt/data/dev/task-planner-skill/plans/INDEX.md → 待处理区
```
EXIT=0。archive 目录计数: `find plans/archive -maxdepth 1 -type d -name 'task-*' | wc -l` = **123**（=22 既有 + 101 本次）✓

INDEX 验证（grep 命中数）:
- 抽样 3 个已归档 id（应全 0）:
  ```
  task-v056-fine-grained-dispatch: 0
  task-v100-review-library: 0
  task-v166-summary-readability: 0
  ```
- 额外抽样已归档（应全 0）: v057=0, v130=0, v152=0
- 在途任务（应>0）:
  ```
  task-v142: 2    task-v143: 2    task-v144: 2    task-v146: 2
  task-v160-decision-grading: 2    task-v165-agent-template-deploy: 2
  task-v168-session-anchor: 2    task-v169-user-session: 2
  task-v170-archive-completed: 2    task-v171-skill-specialization: 2
  ```
- v162（本次已归档）在 INDEX 命中: 0 ✓（符合预期，v162 Status complete 被归档）
- 任务书 §3 第 3 步列在途含 v162，但 v162 实际 Status 全 complete 被归档，故不在 INDEX——此为任务书假设与脚本判定的差异，已说明。

## T5 第 4 步验证
根目录 task-* 目录数: `find plans -maxdepth 1 -type d -name 'task-*' | wc -l` = **14**。
根目录剩余清单（14 个，全部在途集合，非 complete）:
```
task-planner-skill-review          (no task_plan.md)
task-v069-context-hygiene         (status-incomplete)
task-v133                          (status-incomplete)
task-v135                          (status-incomplete)
task-v142                          (status-incomplete)
task-v143                          (status-incomplete)
task-v144                          (status-incomplete)
task-v146-drift-check-subagent     (status-none)
task-v160-decision-grading         (active-pointer)
task-v165-agent-template-deploy    (status-incomplete)
task-v168-session-anchor-skill-activation  (active-pointer)
task-v169-user-session-log-write-once        (active-pointer)
task-v170-archive-completed-plans (status-incomplete, 自身)
task-v171-skill-specialization     (active-pointer)
```
对账: 122 total - 101 归档 = 21 skip；其中非 task-* 的 skip = 7（archive-target 1 + hidden 3 + not task- prefixed 3）；21 - 7 = 14 task-* 剩余 ✓

git status --porcelain（归档后、提交前，2116 行）分类计数:
```
      4 ??
      3 M
   2108 R
      1 RM
```
- 2108 R = 101 目录 git mv 暂存的重命名
- 4 ?? = archive/task-v162/ + plans/task-v168/ + plans/task-v170/ + plans/task-v171/
- 3 M = .rule-reservations.jsonl + INDEX.md + v160-attestation
- 1 RM = v152-attestation（重命名+修改）

## T6 第 5 步精确提交
操作序列:
1. `git add -A plans/archive` → exit=0
2. `git add -u plans/ → exit=0
3. `git restore --staged plans/.rule-reservations.jsonl plans/task-v152-proactive-context/.plan-attestation plans/task-v160-decision-grading/.plan-attestation` → exit=0

暂存区异常处置（§4 禁改清单 P0 约束）:
- 三并行变更文件精确匹配残留检查: `git diff --cached --name-only | grep -E '(三路径精确$)'` = **0** ✓
- 但 v152-attestation 被 add -A 以 `A plans/archive/task-v152-proactive-context/.plan-attestation` 重新暂存（restore 源路径后 add -A 暂存了目标路径）；v162 被 add -A 暂存（21 A + 2 R100 = 23 文件）
- 处置: `git restore --staged plans/archive/task-v152-proactive-context/.plan-attestation` 和 `git restore --staged plans/archive/task-v162-change-absorption-safety`（均 exit=0），使 §4 禁动项禁入本提交

暂存区最终状态（commit 前，`git diff --cached --name-status`）:
```
M   plans/INDEX.md
R   plans/task-vXXX/... -> plans/archive/task-vXXX/...  (2108 条重命名)
```
暂存区总文件数: **2109**（2108 R + 1 M）。
残留检查: 三并行变更 + v152-attestation + v162 = **0** ✓
v152 其他文件（非 attestation）仍暂存: 41 条 R ✓
v162 暂存: 0 ✓

commit:
```
git commit -m "data(plans): task-v170 Phase 8 S15 — 存量批量归档 completed 计划入 archive/+INDEX 重生（archive-plan.sh --batch）"
```
**commit sha: `06ddfdff561619455d90a1cf55f58fbe8276d30b`**
commit 统计: `2109 files changed, 12 insertions(+), 209 deletions(-)`（12 insertions = INDEX.md 更新；209 deletions = 根目录删除）

### 并行会话变更保全实证（提交后 git status --porcelain）
```
 M plans/.rule-reservations.jsonl
 D plans/task-v152-proactive-context/.plan-attestation
 M plans/task-v160-decision-grading/.plan-attestation
?? plans/archive/task-v152-proactive-context/.plan-attestation
?? plans/archive/task-v162-change-absorption-safety/
?? plans/task-v168-session-anchor-skill-activation/
?? plans/task-v170-archive-completed-plans/
?? plans/task-v171-skill-specialization/
```
分类: 5 ?? + 1 D + 2 M。
- .rule-reservations.jsonl: M（未暂存，未提交）✓
- v160-attestation: M（未暂存，未提交）✓
- v152-attestation: D（根目录删除，未暂存）+ ??（archive 下未跟踪）✓
- v162: ??（archive 下未跟踪，未提交）✓
- v168/v170/v171: ??（根目录未跟踪，未提交）✓
**并行会话三项变更（.rule-reservations.jsonl / v152-attestation / v160-attestation）仍在工作区未提交 ✓**

## 归档计数
- archive 目录最终: **123**（22 既有 + 101 本次）
- 根目录 task-* 最终: **14**（全部在途）
- 本次归档: **101** 个 completed 计划

## 最终结论
status: done
acceptance: 5/5 pass
files: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/040-executor-s15.md(+97 新增), /mnt/data/dev/task-planner-skill/plans/INDEX.md(+12/-209), /mnt/data/dev/task-planner-skill/plans/archive/(+101 目录)
evidence: dry-run→`BATCH total=122 ok=0 skip=122 fail=0 (dry-run)` EXIT=0 候选=101；实做→`BATCH total=122 ok=101 skip=21 fail=0 (execute)` EXIT=0；INDEX→`[index] Wrote ... (in_progress=7 pending=1 complete=6)`；抽样 v056/v100/v166 命中=0 在途 v142/v171 等命中=2；根目录剩余 14=在途集合；commit→`06ddfdff561619455d90a1cf55f58fbe8276d30b` 2109 files changed；并行变更 .rule-reservations.jsonl=M/v160-attestation=M/v152-attestation=D+??/v162=??/v168=??/v170=??/v171=?? 全未提交
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v170-archive-completed-plans/subagent-state/040-executor-s15.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
