# Drift Check — Phase 7 偏移检查

**时间**: 2026-10-10
**载体**: Rule 61 载体 22.3.1 改派执行（只读+检查点）
**触发**: Phase 7 complete 前检查
**需求锚（Rule 51.1a）**: 不适用（偏移检查单元）

## 三锚

| 锚 | 内容 |
|----|------|
| ① Goal | task-planner 技能呈报触点强制 Rule 70 四要素 + 机器守护 |
| ② 近期动作 | Round 1 回归（62/65，4 断言 FAIL 全级联）→ S17a/S17b 修复（SR-01 精确锚 / G-07 存在性断言行 / 两处 SKILL 行数钉 515→540）→ Round 2 复跑 65/65 ΣFAIL=0 |
| ③ scope | 本 Phase 仅允许 scripts/selftest-{self-resolution,goal-unit-goal-mode,skill-split}.sh 三个守卫脚本 |

## 检查项与证据

### 1. Git status — scope 核对

命令: `git -C /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability status --short`

输出: **（空，工作树干净）**

说明（与任务书基线差异，已核实非漂移）: 任务书预期「恰好 3 脚本未提交」，实际 Phase 7 修复已由主进程提交为 HEAD commit `906f067`（commit message=「fix(skill): task-v155/Phase 7 — 锚级联清账…回归 65/65 ΣFAIL=0」）。提交状态差异属时序（主进程已推进至 Phase 8，task_plan Current Phase=Phase 8），**不改变 scope 判定**——Phase 7 增量仍恰为 3 个守卫脚本。

### 2. Phase 7 提交 scope 核对

命令: `git show --name-only --format="" 906f067`

输出（恰 3 文件，全在允许列表内）:
```
skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh
skills/task-planner/scripts/selftest-self-resolution.sh
skills/task-planner/scripts/selftest-skill-split.sh
```
`git show --stat 906f067`: 3 files changed, 23 insertions(+), 14 deletions(-)

判定: 与 scope 三脚本逐一对齐，**无越界文件**。

### 3. 必跑只读验证 — 三脚本 rc=0 + Total

| 脚本 | 命令 | 末行 | rc |
|------|------|------|-----|
| selftest-self-resolution.sh | `bash …/selftest-self-resolution.sh` | `Total: 13 PASS=13 FAIL=0` | 0 |
| selftest-goal-unit-goal-mode.sh | `bash …/selftest-goal-unit-goal-mode.sh` | `Total: 9 PASS=9 FAIL=0` | 0 |
| selftest-skill-split.sh | `bash …/selftest-skill-split.sh` | `Total: 41  PASS=41  FAIL=0` | 0 |

判定: 三脚本 Total 13/9/41 全 PASS，rc=0，与任务书预期一致。

### 4. 口径演进 vs 断言弱化 核对

**（a）SR-01 精确锚** — `selftest-self-resolution.sh`
- 旧锚 `^41\.` 实跑计数 = **7**（误计 critical-rules.md:883 = Rule 70.5 行内联引用「41.5 打包呈报补四要素…」，行首恰同形）
- 新锚 `^41\.[0-9]+ \*\*` 实跑计数 = **6**（精确命中 443-448 行 41.1-41.6 六子条标题加粗格式 `41.x **标题**`）
- 断言仍为 `-eq 6`，SR 总条数 **13 未减**。判定=**口径精确化**（排除行内联引用假阳性），非弱化。

**（b）G-07 存在性断言** — `selftest-goal-unit-goal-mode.sh`
- 旧: `tail -1` 钉「registry 末行=goal-unit 登记行」；v155 新增 selftest-report-reviewability.sh 登记行后末行改变 → FAIL
- 新: `grep -q 'selftest-goal-unit-goal-mode.sh' "$REGISTRY"` 存在性断言
- 语义等价（登记行在位即闭环），去脆性绝对位置依赖；G 总条数 **9 未减**。判定=**口径演进**。

**（c）515→540 行数钉** — 两脚本
- `grep -n 540` 命中: goal-unit-goal-mode=3 处（:26 注释 / :127 Why / :129 if+ok）、skill-split=2 处（:47 注释 / :48 断言行）
- 驱动: SKILL.md 实际 518 行（Rule 70 接线净 +7，511→518）触顶 515 → 钉随内容演进上调 540（留 22 行余量给 v152-154/v156）；`≤558` 总上限不动；注释载明演进史+先例（v150 判例）
- 判定=**阈值随内容演进重校准**（非删除断言），与既有「钉值随内容演进同步上调」先例一致。

**（d）总断言条数未减少**（运行时 Total 为准）: goal-unit **9** / self-res **13** / skill-split **41**，与任务书预期逐一相符。

### 5. 越界/写入核对

- 工作树 `git status --short` 为空 → 无未提交越界文件、无 untracked 残留。
- 本次偏移检查全程只读（git status/log/show + 三脚本跑批），未改任何仓库文件；仅写本检查点。

## 判定

**verdict: ALIGNED**

scope 证据: Phase 7 增量恰为 3 个守卫脚本（commit 906f067 的 name-only 输出逐一对齐允许列表，无越界）；三脚本 rc=0 且 Total 13/9/41 全 PASS；三处修复经实跑反证为口径演进/精确化（SR-01 计数 7→6 排除 Rule 70.5 假阳性、G-07 末行钉→存在性、515→540 阈值随 +7 行内容演进），断言总数未减。任务书「3 脚本未提交」基线与实际「已提交」存在时序差异，但 scope 判定不受影响，不构成漂移。

## 最终结论

```
status: done
acceptance: 3/3 pass — [1:PASS git scope（commit 906f067 恰 3 守卫脚本，无越界）, 2:PASS 三脚本 rc=0 Total 13/9/41, 3:PASS 口径演进核对（SR-01 精确锚 7→6/G-07 存在性/515→540，断言总数未减）]
files: none
evidence: git show --name-only 906f067 → 3 脚本; selftest-self-resolution.sh:40 grep -cE '^41\.[0-9]+ \*\*' → 6（旧 ^41\. → 7）; selftest-goal-unit-goal-mode.sh:107 grep -q 存在性; :129 ≤540; selftest-skill-split.sh:48 ≤540; 三脚本末行 Total 13/9/41 FAIL=0 rc=0
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/drift-phase7.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
