<!-- 本文件由 planctl.py 从 plan-state.json 生成，勿直接编辑 -->
# Verification: task-goal-unattended-protocol-20261124

- task_id: `task-goal-unattended-protocol-20261124`
- 时间: created_at=2026-11-23T16:44:25Z / updated_at=2026-11-23T22:37:41Z

## Goal (1 sentence)
- 修复 Skill 家族在 goal 模式下不能自主确认推进、无效多次循环的缺陷（Rule 28.9 + 载体级联）。
- 修复在全部运行位生效（合并 + 部署 5 位）。
- 独立裁决体 decision-arbiter 在当前宿主可派发（源配置对齐见 VC-6；派发冒烟见 VC-9）。

---
## Verification Contract（VC 状态与判据）
| id | status | criterion | command | evidence | tags |
|---|---|---|---|---|---|
| VC-1 | pass | 条款锚在位且旧措辞清零。 判据：6 个载体文件逐一打印的「28.9」计数均 ≥1；`old-wording-in-SKILL=0`。（改前：6 个计数全为 0、old=2——具判别性） | cd /mnt/data/dev/task-planner-skill && for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do echo "$(grep -c '28\.9' "$f") $f"; done; echo "old-wording-in-SKILL=$(grep -c '仅单次降级收口停止' skills/task-planner/SKILL.md)" |  | plan-brief §B4 |
| VC-2 | pass | Rule 28.9 本体在位：条款行 =1，八个子条标记 ①-⑧ 齐全，且含部署护栏原文。 判据：第一数 =1；第二数 =8；第三数 ≥3。 | cd /mnt/data/dev/task-planner-skill && F=skills/task-discipline/references/critical-rules-discipline.md; grep -c '^28\.9 ' $F; sed -n '/^28\.9 /p' $F \| grep -o '[①②③④⑤⑥⑦⑧]' \| sort -u \| wc -l; sed -n '/^28\.9 /p' $F \| grep -o -E '逐位 diff 判向\|禁整文件覆盖\|部署前备份\|verify 对账' \| wc -l |  | plan-brief §B4 |
| VC-3 | pass | 语法与 selftest 回归不破基线（selftest 基线 = `baseline-selftest.log`：104 PASS / 0 FAIL）。 判据：输出 `SYNTAX_OK`；fresh selftest 汇总行 FAIL 数 =0 且 PASS 数 =104（与基线相同）。 | cd /mnt/data/dev/task-planner-skill && bash -n skills/task-planner/scripts/*.sh && echo SYNTAX_OK; bash skills/task-planner/scripts/run-selftests.sh --fresh 2>&1 \| tail -4 |  | plan-brief §B4 |
| VC-4 | pass | 合并进 master 且隔离区已清理。 判据：第一数 ≥1；第二数 =0；第三数 =0。 | cd /mnt/data/dev/task-planner-skill && git log --oneline -6 \| grep -c 'task-goal-unattended-protocol-20261124'; git worktree list \| grep -c 'task-goal-unattended-protocol-20261124'; git branch --list 'wt/task-goal-unattended-protocol-20261124' \| wc -l |  | plan-brief §B4 |
| VC-5 | pass | 5 个运行位逐文件新锚在位（30 个位文件计数均 ≥1、无 MISSING），且部署对账不差于基线（`verify.sh` 基线 23 pass / 3 fail）。 判据：输出 `site-files-bad=0`；summary 行 pass ≥23 且 fail ≤3。 | cd /mnt/data/dev/task-planner-skill && for s in /home/terry/.zcode /home/terry/.agents /home/terry/.claude /home/terry/.config/opencode /home/terry/.cursor; do for f in skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/SKILL.md skills/task-planner/references/critical-rules.md skills/verification-gate/references/critical-rules-verification.md skills/verification-gate/SKILL.md skills/task-dispatch/references/critical-rules-dispatch.md; do t="$s/$f"; if [ -f "$t" ]; then grep -c '28\.9' "$t"; else echo MISSING; fi; done; done \| awk '{ if ($1=="MISSING" \|\| $1+0<1) bad++ } END { print "site-files-bad=" bad+0 }'; TASK_PLANNER_ROOT=/mnt/data/dev/task-planner-skill/skills/task-planner bash skills/task-planner/lib/verify.sh 2>&1 \| grep summary |  | plan-brief §B4 |
| VC-6 | pass | decision-arbiter 源配置对齐。 判据：=2（model 行与 thoughtLevel 行各 1）。 | cd /mnt/data/dev/task-planner-skill && sed -n '1,12p' skills/task-planner/companion/agents/decision-arbiter.md \| grep -cE '^model: "account:zai-individual-coding-plan/GLM-5\.4"$\|^thoughtLevel: max$' |  | plan-brief §B4 |
| VC-7 | pass | 项目 AGENTS.md 含 goal 部署预授权例外。 判据：≥1（改前 =0）。 | grep -c 'goal 模式部署预授权' /mnt/data/dev/task-planner-skill/AGENTS.md |  | plan-brief §B4 |
| VC-8 | fail | 新会话行为演练四判据全 PASS（D1 零等待式提问；D2 首轮即产出预算内成果并登记待授权清单与判据上限；D3 其后 3 轮模拟续推每轮 ≤10 行、无工具调用步骤、决策不翻转；D4「授权」当轮即执行待授权预案并验证）。 判据：第一数 =4；第二行 `skeleton-ok`。报告行严格按模板「- D<n> 判据 <名称>：PASS\|FAIL」每条一行；原始证据骨架 `drill-skeleton.txt`（主进程从演练会话记录抽取的逐消息骨架）非空，D1-D4 由主进程对照骨架判定并在报告中引用骨架行号。 | grep -cE '^- (D[1-4]) 判据[^:]*：PASS' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-report.md; test -s /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/drill-skeleton.txt && echo skeleton-ok |  | plan-brief §B4 |
| VC-9 | pass | decision-arbiter 派发冒烟成功（S15）：裁决体在当前宿主正常返回并落 checkpoint。 判据：≥1（checkpoint 缺失时命令失败 = FAIL，具判别性）。 | grep -c '^status: done' /mnt/data/dev/task-planner-skill/plans/task-goal-unattended-protocol-20261124/subagent-state/12-decision-arbiter.md |  | plan-brief §B4 |

## Phase Gates
| Goal | Depends on | Done when | Checks | Status |
|---|---|---|---|---|
| （本任务暂无Phase Gates 记录） |  |  |  |  |

## 📚 必要知识储备符合性核验（终验项）
| 必读知识源 | 核验方式(交付物对照点) | 结论(符合/偏离+说明) |
|---|---|---|
| （本任务暂无知识符合性记录） |  |  |

## 委派统计复验（Rule 25.4）
- （本任务暂无委派复验记录）

## 质量门控统计（Rule 26）
- （本任务暂无质量门控记录）

## Goal Gate (终验，所有 phase complete 后执行)
- （本任务暂无Goal Gate 记录）

---
## 交叉验证记录（Rule 108）
| 验证对象 | 机械面路径（命令+结果） | 语义面路径（复检体+结论） | 判定（一致/分歧→108.4 处置） |
|---|---|---|---|
| （本任务暂无交叉验证记录） |  |  |  |

## 5-Question Reboot Check
| # | Question | Answer (fill on resume) |
|---|---|---|
| （本任务暂无5Q 记录） |  |  |
