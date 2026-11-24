# Drift Checkpoint (seq 34)
- time: 2026-11-24
- trigger: 复查 seq32 DRIFT(I-8: VC-8名实不符)
- verdict: ALIGNED

## 逐项证据
1. `planctl.py status --plan-dir ...` → `vc_counts:{pass:8,fail:1}`, `vcs[VC-8].status=fail`, `last_audit.round=6 verdict=REJECTED by=drift-checker issues[I-8 state=fixed]`.
2. drill-report.md:1 `# goal 行为演练报告（VC-8）` :3 `> **结论：VC-8 未通过（FAIL）。** ...全新会话以 build 权限模式运行...第 3 个工具调用...权限请求处等待`; :8-11 四行 `D1-D4 判据...：FAIL（新会话未验证；同会话模拟演练中为 PASS）`; `grep -cE '^- (D[1-4]) 判据[^:]*：PASS' drill-report.md` → `0`.
3. `cmp -s drill-skeleton.md drill-skeleton.txt && echo IDENTICAL` → `IDENTICAL`; skeleton.md:12 `- 权限模式：build（改动前需审批）`; :17 `- 即：卡在第 3 个工具调用（第 2 条 shell 命令）的权限请求上...`（与progress E10/D-21所述事实一致）。
4. progress.md grep `D-21|E10|A28|第 6 轮审查` → 无命中（字面缺失）；plan-state.json 含 `D-21`(line1418),`A28`(1784),`E10`(1882); plan-state audits[-1]={round:6,REJECTED,drift-checker,I-8 fixed}。第6轮审查“verdict REJECTED, I-8 fixed”在plan-state可证，progress.md无“第 6 轮审查”字样。
5. VC-8表述：verification.md:23 `VC-8 | fail | ...`; progress.md:139 记“模拟演练中D1-D4全PASS(VC-8原文=4+skeleton-ok)”,:140 明确“VC-8改判 fail”; drill-report.md 全文FAIL/未通过，无“已通过/已达成”。无残留pass断言。
6. scope: `git log --oneline -1`=`d9f68655 Merge branch 'wt/task-goal-unattended-protocol-20261124'`; `git diff --stat 9e42c0b HEAD|tail -1`=`10 files changed, 42 insertions(+), 34 deletions(-)`; `git status --short -- skills`=`M attest-plan.sh/init-session.sh/planctl.py/task-plan-init.cjs`(4个他会话未提交); `ls plans/goal-drill-20261124`→`No such file or directory`; `ls plans/.plan_required_side/|wc -l`=`8`; `/home/terry/.claude/agents/decision-arbiter.md` 前5行含 `model: "account:zai-individual-coding-plan/GLM-5.3"`。

## 建议
- seq32 I-8 已修正（VC-8=fail,报告/骨架口径一致）。progress.md缺D-21/E10/A28字面与“第6轮审查”字样，但plan-state已登记；若要审计可追溯性可补一行索引，不阻塞ALIGNED。