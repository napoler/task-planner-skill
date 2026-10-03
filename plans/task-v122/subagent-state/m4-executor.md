# [sub:executor-m4] Rule 47 静态守护 selftest-media-dispatch.sh 执行检查点

## T1-T4 执行流水
- T1 读范式：selftest-reliability-institution.sh（t()/ok-bad、Total 行、R-12 jq fail-open SKIPPED 先例、SKILL_ROOT 定位法）+ findings.md §selftest 断言清单 MD-01..MD-09。
- T2 锚预验（全部实测命中）：`grep -c '^47\.'`=4 / `grep -c '^### 47 '`=1 / SKILL.md 媒体生成工序=1 剧集创作管线=1 Rule47摘要=1 代码编辑（单文件=1 / TMAP Rule47.2=2 媒体制作族=1 / jq properties=40 / 21.1b=1。
- T3 定位法修正：template-mapping.md 不在 task-planner/references/（task-v095 拆分后移入 plan-template-kit），采用先例 `$SKILL_ROOT/../plan-template-kit/references/template-mapping.md`（同 selftest-mechanism-profile.sh:30、selftest-template-lifecycle.sh:37）。
- T4 落盘：新建 skills/task-planner/scripts/selftest-media-dispatch.sh（MD-01..MD-09，头注释四要素+每断言 What/Why 双层注释）+ selftest-registry.tsv 末行追加 1 登记行（4 列制表符分隔，cat -A 确认 ^I 分隔、零删除 1 insertion）。

## 自检证据（worktree /mnt/data/dev/task-planner-skill-worktrees/task-v122）
- `bash selftest-media-dispatch.sh` rc=0：
  ```
  MD-01 PASS critical-rules.md Rule 47 子条锚 4 ≥4
  MD-02 PASS critical-rules.md Rule 47 标题锚在位
  MD-03 PASS SKILL.md 路由表「媒体生成工序」行 1 ≥1
  MD-04 PASS SKILL.md 路由表「剧集创作管线」行 1 ≥1
  MD-05 PASS SKILL.md Rule 47 摘要 bullet 1 ≥1
  MD-06 PASS template-mapping.md §九兜底注「Rule 47.2」2 ≥1
  MD-07 PASS template-mapping.md §十「媒体制作族」特化行 1 ≥1
  MD-08 PASS config.json properties 键数 40（零新增）
  MD-09 PASS 既有锚守护 21.1b=1 ≥1 且 SKILL.md「代码编辑（单文件」行 1 ≥1
  Total: 9 PASS=9 FAIL=0
  ```
- `bash selftest-registry.sh` rc=0：
  ```
  T01 PASS
  T02 PASS
  T03 PASS
  T04 PASS
  T05 PASS
  Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)
  ```
- `grep -c 'selftest-media-dispatch' selftest-registry.tsv` = 1。
- `git status --short`：仅 ` M selftest-registry.tsv` + `?? selftest-media-dispatch.sh`（2 文件，禁改清单外零改动）；`git diff --stat` = `1 file changed, 1 insertion(+)`（registry 纯增量 1 行，0 删除）。

## 最终结论（8 字段块，status: done）
status: done
acceptance: 3/3 pass — [① `bash selftest-media-dispatch.sh` rc=0 末行 `Total: 9 PASS=9 FAIL=0`；② `bash selftest-registry.sh` rc=0 末行 `Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)`；③ `grep -c 'selftest-media-dispatch'` = 1 且 git diff 仅限 2 文件]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v122/skills/task-planner/scripts/selftest-media-dispatch.sh(+126); /mnt/data/dev/task-planner-skill-worktrees/task-v122/skills/task-planner/scripts/selftest-registry.tsv(+1/-0)
evidence: `bash selftest-media-dispatch.sh`→`Total: 9 PASS=9 FAIL=0`(rc=0); `bash selftest-registry.sh`→`Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)`(rc=0); `grep -c 'selftest-media-dispatch' selftest-registry.tsv`→`1`; `git status --short`→` M selftest-registry.tsv` + `?? selftest-media-dispatch.sh`; `git diff --stat`→`1 file changed, 1 insertion(+)`
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/m4-executor.md (status: done)
findings_written: findings.md §Research Findings `#### [sub:executor-m4]` 段
blockers: none
confidence: HIGH
