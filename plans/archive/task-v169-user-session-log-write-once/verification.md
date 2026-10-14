# Verification Contract & Phase Gates

## Goal (1 sentence)

在 task-planner 技能内落地「用户会话逐字记录、只写不改」纪律（Rule 80 + user-session-log.md 专档 + init 自动建档 + SESSION-LOG GATE + selftest 守护），用户每次任务需求与对话内容即时逐字落盘、会话异常恢复后以专档为权威源。

---

## Verification Contract (≥5 items, objective standards)

- [x] VC-1: init-session.sh 为新计划自动创建 user-session-log.md，既有 6 文件创建与 `6/6` 校验字面零破坏
  Evidence: worktree e2e（sub:02）/tmp/v169-e2e 首跑 7 文件齐备含 user-session-log.md、二跑幂等 skipping；`grep -c '6/6' scripts/init-session.sh` = 1（selftest-session-log.sh SL-07 PASS，Total: 10 PASS=10）；六文件创建循环与 6/6 回显行 git diff 删除行=0
- [x] VC-2: templates/user-session-log.md 存在（只写不改铁律头+条目格式+恢复协议）；templates/task_plan.md 含「🗣️ 用户会话逐字记录」指针区块
  Evidence: worktree templates/user-session-log.md（22→24 行，含 append-only/逐字抄录/只写不改三要素+条目范式+恢复协议）；templates/task_plan.md:20 指针区块（专档路径/铁律/恢复协议三行）；SL-01/SL-02/SL-03/SL-08 PASS
- [x] VC-3: references/critical-rules.md Rule 80（80.1-80.6 六子条）；SKILL.md 级联三处 1-80 + 第 7 文件行 + C56 行
  Evidence: `grep -cE '^80\.[1-6] ' references/critical-rules.md` = 6；`grep -c '1-80' SKILL.md` = 3 且 `1-76` = 0；`grep -c '7 个文件'` = 1、`grep -c '| C56 |'` = 1；SKILL.md 558 行 ≤ 581（G-09/DCS-19/T8b/BP-08 上限未回归）；SL-04/SL-05 PASS
- [x] VC-4: check-complete.sh SESSION-LOG GATE 三态（指针区块在+专档缺/空=FAIL；无指针=SKIP；env 降级）
  Evidence: 主进程独立复跑五 fixture：enforce 违规 exit=1 + `[session-log-gate] ✗`；合规 OK（1 条）；默认 warn 违规 exit=0 + ⚠；off 档 SKIPPED；无指针存量 SKIPPED；env-only 开关 `TASK_PLANNER_SESSION_LOG_ENFORCE` 在位，config.json properties=42（SL-06/SL-09 PASS）
- [x] VC-5: selftest-session-log.sh SL-01..10 全 PASS 且已登记 registry
  Evidence: `bash scripts/selftest-session-log.sh` → `Total: 10 PASS=10 FAIL=0` rc=0（主进程+部署位双跑）；`grep -c 'selftest-session-log.sh' selftest-registry.tsv` = 1 且该行 awk NF=4 四列非空；负向自检（/tmp 副本破坏指针标题→SL-03 FAIL）证明断言非空转
- [x] VC-6: 全量回归 FAIL=0（dry-run 实证 19 FAIL→18 锚扩级联+1 Rule 80 行号修正关闭）；部署同步
  Evidence: 主仓 `bash skills/task-planner/scripts/run-selftests.sh` → `Total: 78 PASS=78 FAIL=0 (run=78 reused=0)`（冷跑）；code-runner-agent 独立复跑（sub:17）78/78 FAIL=0；部署位 ~/.zcode diff=0 / ~/.claude diff=0；~/.cursor 本任务 26 文件已同步（63 行存量漂移为其他任务历史欠账，非本次回归项——已在交付总结风险段登记）

---

## Outcome: **COMPLETE**

- VC-1..VC-6 全部 PASS；CR Gate APPROVED-WITH-NITS 三 nit 已当轮修复并复验；drift-checker 判定 aligned
- 委派率 0.667（check-delegation.sh verdict=ok，violations=[]；主进程直做理由全在 Rule 25.3 白名单内，25.4 豁免）
- 已知遗留（非本任务范围，均已登记）：~/.cursor 部署位 63 行存量漂移（24 缺+38 差异+.backup）；部署位 5 个 selftest 存量环境性失败（MA-08/PR-13/SA-10/WF-10 等，master 基线上同样复现，与本任务无关）

## 委派统计复验（Rule 25.4）

```bash
bash /home/terry/.zcode/skills/task-planner/scripts/check-delegation.sh stats /mnt/data/dev/task-planner-skill/plans/task-v169-user-session-log-write-once
```

JSON 输出：
```json
{"phases_total":6,"phases_delegated":4,"main_direct_count":2,"delegation_rate":0.667,"main_direct":[{"phase":"1 Requirements & Discovery","reason":"例外理由:② 计划系统文件维护——Rule 25.3 白名单"},{"phase":"6 合并、部署与终验收口","reason":"例外理由:① git 编排+② 簿记——Rule 25.3 白名单"}],"violations":[],"verdict":"ok"}
```
