# 15-s12-executor checkpoint（task-v127/S12 worktree 合流级联 5 selftest FAIL 修复）

status: done

## T1 修复前 FAIL 原文（5 条，逐字）
- PT-08 FAIL SKILL.md frontmatter 缺「Critical Rules 全集 1-4[5-9]|1-50」（task-v117+task-v118+task-v121+task-v127 口径扩展后宽容字面锚）
- CD-12 FAIL SKILL.md 宽容锚「1-3[5-9]」2 +「1-4[5-9]|1-50」0 合计 ≥3（兼容 1-35-50 过渡，task-v117+task-v118 双锚口径扩展+task-v121 预扩+task-v127 扩 1-50）
- RG-06 FAIL SKILL.md 路由面锚缺失（'1-50' 或 'Rule 50' 命中=3 <2）
- LA-11 FAIL SKILL.md References 表「Rule 49 单元线多路并行推进）」缺失（文档表未联动）
- RC-15 FAIL critical-rules.md '50.' 子条命中=6（应 =0，编号假设被破坏）

## T2 根因定位（SKILL.md 现值实测）
- SKILL.md L9 全集行现值=1-51（v129 合流并入 Rule 51）；`grep -cn '1-50' SKILL.md`=0；`grep -c 'Rule 50'`=3；全集行匹配 `1-5[0-9]`=1
- References 表 L311 现值：「... / Rule 49 单元线多路并行推进 / Rule 50 ... / Rule 51 ...）」，LA-11 尾字符「）」已非 49 名紧邻
- critical-rules.md `^50.` 命中=6（Rule 50 六子条，task-v127 S5 合法落体）；`^52.` 命中=0；最大章节标题=### 51

## T2 修复内容（仅 5 脚本，锚宽容化/行号重锚，断言语义零改动）
- selftest-plan-tier.sh PT-08：`1-50`→`1-5[0-9]`（L78 注释追加 S12 行 + L79 改）
- selftest-conclusion-discipline.sh CD-11：n45 模式 `1-4[5-9]|1-50`→`1-4[5-9]|1-5[0-9]`，合计 ≥3 阈值不变（L71-72 改）
- selftest-requirement-grading.sh RG-06：`grep -q '1-50'`→`'1-5[0-9]'`，ok/bad 标签同步（L90/91/94 改；registry 行描述本已同步 1-5[0-9]）
- selftest-lane-advancement.sh LA-11：锚去尾字符「）」→ 锁「Rule 49 单元线多路并行推进」名在位（L115-119 改）
- selftest-requirement-coverage.sh RC-15：负断言 `^50.`→`^52.`（合流后 50 被 S5 合法占用且被 RG-02 正面守护，改锁后继号 52 未被占；语义=本任务编号假设后继号未被占用，不反转）（L157/161-163 改）

## T3 修复后复跑（逐脚本 rc + Total 行原文）
- selftest-plan-tier rc=0  Total: 32 PASS=32 FAIL=0
- selftest-conclusion-discipline rc=0  Total: 24 PASS=24 FAIL=0
- selftest-requirement-grading rc=0  Total: 7 PASS=7 FAIL=0
- selftest-lane-advancement rc=0  Total: 14 PASS=14 FAIL=0
- selftest-requirement-coverage rc=0  Total: 15 PASS=15 FAIL=0

## T4 验收证据
- `git -C <worktree> status --porcelain` 仅 5 个脚本 M：selftest-conclusion-discipline / selftest-lane-advancement / selftest-plan-tier / selftest-requirement-coverage / selftest-requirement-grading
- `git diff --stat`：5 files changed, 15 insertions(+), 13 deletions(-)；逐文件变更行数：PT=2 / CD=2 / RG=3 / LA=4 / RC=4（≤4）；无断言语义反转；无内容文件（SKILL.md/critical-rules.md/模板/goal-gate/registry）改动；未 git add/commit；主仓 plans/ 只读未触碰

## 最终结论
status: done
acceptance: 3/3 pass — [1:PASS 5 脚本单跑全 PASS rc=0（修复前 FAIL 行×5 见 T1 + 修复后 Total 行×5 见 T3，逐条如上）] [2:PASS 全部为锚/行号级适配，逐文件变更 ≤4 行（PT=2/CD=2/RG=3/LA=4/RC=4），无语义反转，无内容文件改动] [3:PASS git status --porcelain 仅 5 脚本文件]
files: /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-plan-tier.sh, /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-conclusion-discipline.sh, /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-requirement-grading.sh, /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-lane-advancement.sh, /mnt/data/dev/task-planner-skill-worktrees/task-v127/skills/task-planner/scripts/selftest-requirement-coverage.sh
evidence: 修复前 FAIL 行×5（T1 原文）+ 修复后 Total 行×5（T3 原文）+ `git diff --stat` = 5 files changed, 15 insertions(+), 13 deletions(-)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v127/subagent-state/15-s12-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
