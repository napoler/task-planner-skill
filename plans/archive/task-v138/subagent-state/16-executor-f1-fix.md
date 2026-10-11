# Checkpoint: [sub:16-executor-f1-fix] Phase 4b S1 — agnes-quota.sh F1 缺陷修复 + selftest mock 负向断言

- 任务号: task-v138（Phase 4b S1）
- 工作面: /home/terry/task-planner-skill-worktrees/task-v138b（branch wt/task-v138b，HEAD fed4393，含 v138+v139 全部产物）
- 日期: 2026-10-06
- 状态: done（自测全绿；未 commit，留待 Phase 5 编排提交）

## 背景
Phase 4 S2 code-quality-review 判 CHANGES_REQUESTED，阻塞项 F1=agnes-quota.sh 非 200（4xx/5xx，curl -f 抑制 body）被旧判定逻辑
（`http_code != 000` 当「可达」）落入默认成功 verdict「计费层已回传数值」且 exit 0——失败被伪报成功，正是 R3 要根除的「不可信产出」。

## 改动（仅 2 文件，git diff --numstat：agnes 47/21、selftest 91/1；git status 仅此 2 文件 M）
### 1. skills/task-planner/scripts/capabilities/agnes-quota.sh（211 行）
- 成功判据改 200 口径：`ok_sub=0; [ "$sub_code" = '200' ] && ok_sub=1`（同 ok_use），废弃旧 `reach_*`（非 000 计）
- 判定分支：任一非 200 → 双失败 verdict「计费端点均未返回有效数据（subscription=HTTP X, usage=HTTP Y）…无法判定…」/
  单失败 verdict「计费端点部分不可达（subscription=X usage=Y）：本次无法判定…」+ `VERDICT_FAIL=1` → `exit 5`
- 双 200 → 保留占位/未填充/已回传三态逻辑 + exit 0（默认行为不变）
- 移除旧「两码均 000 → exit 4」块：000 归入 200 口径失败集 → exit 5；exit 4 保留给控制组 /agnesapi 全候选连接失败
- endpoints_reachable（human/JSON）改用 ok_sub/ok_use（200 口径）
- 可测试性缝：`BASE="${AGNES_QUOTA_BASE:-https://api.agnes-ai.cn}"`（头注释注明仅测试用途，默认不变）
- 头注释/usage() 同步登记退出码全集 0/2/3/4/5；判例三按 Rule 45 三要素（现象+根因+原行为→新行为）
- 规避密钥扫描误报：不书写任务目录全字面（"task-v…" 含 sk-v 子串），任务号指向 capability-registry.md

### 2. skills/task-planner/scripts/selftest-capability-persistence.sh（267 行）
- 既有 CP-01..CP-18 零改动；追加 CP-19/20（本地 mock 实跑回归钉），头注释/依赖段同步 18→20
- python3 mock（mktemp -d，仅绑 127.0.0.1 随机端口，404/200 固定体；teardown 清目录+后台进程；timeout 20；缺 python3/curl/timeout 则 SKIPPED fail-open）
- CP-19：404 模式（AGNES_QUOTA_BASE=http://127.0.0.1:<port>）→ 断言 exit≠0 且输出含失败语义且禁含「计费层已回传数值」
- CP-20：200 模式（subscription 含 1e8 占位）→ 断言 exit 0 且 verdict 含「未填充」

## 验证证据（本会话实跑）
- `bash -n` 两文件 exit 0
- `grep -icE 'sk-[a-z0-9]|cpk-'` agnes-quota.sh = 0（首次含 "task-v138b" 致 =4，已按原文件规避约定改写 → 0）
- `bash scripts/selftest-capability-persistence.sh` → `Total: 20 PASS=20 FAIL=0` exit 0（仓库 cwd 与 `/` cwd 两处同）
- CP-19 实测 exit=5；CP-20 实测 exit=0
- 咬合力验证：把 ok 判据 mutate 回 F1 旧逻辑 → 404 mock 实跑复现 rc=0 + `"subscription": null` + verdict「计费层已回传数值」（与审查 F1 mock 复现逐字一致）→ CP-19 必 FAIL
- 真端点 `bash agnes-quota.sh --json` → exit 0（key_source=bashrc:export、两计费端点 200、verdict=未填充，行为不变）
- 全量回归：53/53 脚本 FAIL=0（含 selftest-final-gate-hash `结果: PASS=22 FAIL=0`）；兄弟 selftest-registry 5/5、veto 13/13、media-dispatch 9/9
- `git diff --stat` 仅两文件；`git status --short` 仅两文件 M

## 决策登记
- 双失败含两码均 000 → 按 dispatch「非 200（含 000/4xx/5xx）一律失败 + 双失败→exit 5」字面实现，移除旧 both-000→exit 4 块；
  exit 4 语义收窄为「控制组 /agnesapi 全候选连接失败」（bogus proxy 场景仍 exit 4，sub:11 行为保留）。task_plan 修复项①「退出码非 0（区分 3/4）」= 新码 5 与 3/4 相区分，一致。

## 未决/下游
- 未 commit（Phase 5 逐 Phase commit + smart-merge-back --deploy）；F2-F5（LOW 非阻塞）未处理，属后续维护窗口
- S2（code-runner-agent）需复验：mock 404/000 咬合 + 全量 FAIL=0

## 最终结论（8 字段块）
status: done
acceptance: 4/4 pass — [1:PASS(断言A 404→exit5+失败语义禁伪成功) 2:PASS(断言B 200→exit0+未填充) 3:PASS(selftest Total:20 FAIL=0，18→20) 4:PASS(真端点 --json exit0 行为不变；git diff 仅两文件)]
files: /home/terry/task-planner-skill-worktrees/task-v138b/skills/task-planner/scripts/capabilities/agnes-quota.sh (+47/-21); /home/terry/task-planner-skill-worktrees/task-v138b/skills/task-planner/scripts/selftest-capability-persistence.sh (+91/-1)
evidence: agnes-quota.sh:159-185（200 判据+双/单失败 verdict）/:210（exit 5）/:49（BASE seam）; selftest-capability-persistence.sh:186-266（CP-19/20 mock）; `bash selftest-capability-persistence.sh` → `Total: 20 PASS=20 FAIL=0`; `bash agnes-quota.sh --json` → real exit=0 verdict=未填充; mutant 复现 F1（rc=0+success verdict+null）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/16-executor-f1-fix.md (status: done)
findings_written: findings.md `#### [sub:16-executor-f1-fix]`
blockers: none
confidence: HIGH
