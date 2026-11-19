# Drift Checkpoint — task-spec-baseline-freeze-20261119
- 时间: 2026-11-19 (drift-checker read-only run)
- 触发点: 任务收口对齐复核（用户原话 R1/R2 vs 盘上产出/门控证据）
- 判定: **ALIGNED**（核心诉求实质满足；存在收口声称精度问题，见发现项）

## 证据
- V1 R→VC: task_plan.md:20-27 R1[目标]→VC-1,VC-4; R2[目标]→VC-2,VC-3,VC-5；verification.md:10-25 定义 VC-1..VC-5+Verify command+Evidence；两 R 均有映射。user-session-log.md 无 `## #1` 逐字条目（模板态，:11-16），原话锚以 task_plan R 行/本次派发 prompt 为准（Rule 80 落档缺口）。
- V2 6条款+闭环: critical-rules.md:109 `51.15`(定义→attest锁→四环绑定,含 `4-12s`/`sess_ba603cf5`/`SPEC-BASELINE TAMPERED`/双向上下界)；dispatch:66 `22.4e`(派发逐条携带禁转译/放宽/单边)+:241 `103.3b`(逐条回归,拦软豁免/单边降级/前合规后退化)；discipline:756 `106.7`(返工/续写/重审全量回归+[spec-regression])；verification:60 `84.15`(终验基线-产物逐条核验,FAIL/软豁免/缺表/sha漂移禁COMPLETE)；verification-gate SKILL.md:70 step 4b 消费84.15；subagent_dispatch.md:48 `{spec_baseline}`；task_plan模板:62 `🔒 规范基线`区块。闭环=定义冻结→派发携带→复检回归→返工回归→终验门 实质在位。
- V3 scope(commit 7db7a25): `git show --name-only --format="" 7db7a25`=7文件(critical-rules.md,critical-rules-dispatch.md,critical-rules-discipline.md,subagent_dispatch.md,task_plan.md模板,verification-gate/SKILL.md,verification-gate/references/critical-rules-verification.md)；`--numstat` 全为增量(2/4/2/1/6/1/2,+0 del)，无脚本无config键。`git diff --stat` 工作树无diff（仅staged+untracked）。
- V4 验证抽查: repo内VC-1锚点命令通过(51.15/22.4e/103.3b/106.7/84.15/spec_baseline/🔒规范基线均≥1)→VC1_PASS；VC-4: `grep '^51\.15 ' ...critical-rules.md` 行含 `4-12s`+`sess_ba603cf5`+`SPEC-BASELINE TAMPERED`→VC4_PASS。VC-2 selftest未在本次全量复跑（证据不足，依赖既有记录）；VC-3/“64锚零缺失”见发现P1。
- V5 他会话: `git diff --cached --name-only|wc -l`=17；名单=CLAUDE.md,README_zh.md,skills/plan-resume/SKILL.md,skills/task-discipline/references/critical-rules-discipline.md,skills/task-dispatch/references/critical-rules-dispatch.md,skills/task-planner/{SKILL.md,config.json,references/critical-rules.md,references/worktree-isolation.md,scripts/{check-conflicts,selftest-interaction,zcode-pretooluse,zcode-userpromptsubmit}.sh,templates/{task_plan.md,user-session-log.md}},skills/todo-skill/SKILL.md,skills/workflow-model-tiers/SKILL.md（staged M 保留）。
- V6: `git show --name-only 7db7a25 | grep task-planner/SKILL.md`=NOT_TOUCHED；md5 source `40b2d67...`==`~/.agents/skills/task-planner/SKILL.md`，但 `~/.zcode/skills/task-planner/SKILL.md`=`ab2a57f...`(DIFF,预存偏差)。任务worktree已清(`git worktree list`无task-spec-baseline-freeze-20261119；仅master+wt-tplsys-upgrade-20261117)。

## 发现（分级）
- **P1 收口声称与部署实况不完全一致**: (a) VC-3 verify命令(verification.md:18)仅列6文件且漏 `skills/verification-gate/references/critical-rules-verification.md`；按正确映射cmp：7文件在 `~/.zcode` 与 `~/.agents` 的 rules/references/SKILL 均OK，但 `~/.zcode/skills/task-planner/templates/task_plan.md` 与repo DIFF（含额外“🧭 指令理解迭代草稿”块，repo侧无），且 `~/.agents/skills/task-planner/templates/` 目录缺失(subagent_dispatch.md/task_plan.md模板MISSING)——“3部署位 19文件64锚零缺失/VC-3 diff=0”表述过满。(b) VC-2 selftest全绿未本次复跑，证据依赖既有记录。
- **P2 过程留痕**: user-session-log.md 未落 `## #1` 逐字原话条目（Rule 80 只写专档未实填）；progress.md Phase2仍标in_progress而verification/合并已完成（状态簿记滞后）；commit含7文件但部分叙述写“6处文本条款/6文件”口径不一（实质条款闭环已覆盖）。
- **P0 无**。核心R1/R2实现未漂移、无范围扩散、无篡改他会话staged。

建议: 补齐模板部署位一致性与user-session-log逐字条目，修正VC-3文件清单/部署声明后再宣称全绿。
