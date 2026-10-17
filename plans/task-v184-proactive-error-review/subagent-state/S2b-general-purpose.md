# S2b General-Purpose 检查点 (task-v184 8 FAIL 清零)

## 任务
清零 S2 接线后全量 selftest 的 8 FAIL（3 RVC 交互回归 + 4 stale-47 键数 + 1 summary-readability 元检），不引入新红。

## A 组：3 个 RVC 交互回归（单元隔离 env）
新 RVC 门（enforce 默认，check-complete.sh:1032）先于 R-COVERAGE(:1035)/EVIDENCE-ANCHOR(:1053) 拦截
「有 R 行但缺 R→VC 映射」的旧夹具。修法=调用点前缀 `TASK_PLANNER_RVC_COVERAGE_ENFORCE=off`
（check-complete.sh:845 off 档立即 return 0），行尾注释 `# [task-v184-S2b] RVC 单元隔离：本 selftest 测自身门，RVC 交互面由 check-rvc-coverage 注入夹具覆盖`。

- selftest-requirement-coverage.sh：3 处调用点（RC-19 :354 / RC-20 负例 :469 / RC-20 正例 :472）
  env 前缀加 RVC=off。复跑 Total: 23 PASS=23 FAIL=0。
- selftest-evidence-anchor.sh：3 处调用点（EA-16 :319 / EA-17 :330 / EA-19 :338）
  env 前缀加 RVC=off。复跑 Total: PASS=20 FAIL=0。
- selftest-final-gate-hash.sh：run_cc() 单点（:37，16 处调用全经此）加 RVC=off。
  复跑 PASS=22 FAIL=0。

## B 组：4 个 stale-47 键数断言升 53
S1 只级联 `"47"` 引号形态，这 4 文件是非引号形态（`=47`/`expect=47`/`应 47`）。
全部升 53，行尾注释 `# [task-v184-S2b] 键数 47→53（S1 引号形态级联漏网补齐）`。
历史注释（46→47/44→46/42→44/40→42）保留不动。

- selftest-channel-fast-fail.sh：CF-03 断言 `= '47'`→`'53'` + 消息 + 头部注释 :5 properties=47→53。
  复跑 Total: 6 PASS:6 FAIL:0。
- selftest-session-log.sh：SL-09 断言 `-eq 47`→`-eq 53` + 消息 + 注释。复跑 Total: 12 PASS=12 FAIL=0。
- selftest-four-file-dataflow.sh：FF-15 断言 `-eq 47`→`-eq 53` + ok/bad 消息 expect=(0,53)。
  复跑 Total: 18 PASS=18 FAIL=0。
- selftest-context-pressure.sh：CP-09 断言 `-eq 47`→`-eq 53` + ok/bad 消息。复跑 Total: 9 PASS=9 FAIL=0。

## C 组：summary-readability 元检（零改动转绿）
SRV-12 跑 9 个级联脚本要求 9/9 PASS。S2 归因的 2 个失败=context-pressure(stale-47)+requirement-coverage(RVC)，
已分别被 B 组/A 组修复覆盖。summary-readability.sh 本身零改动，复跑 PASS=13 FAIL=0。

## 验收
1. 8 selftest 逐个 rc=0 FAIL=0：requirement-coverage(23) / evidence-anchor(20) / final-gate-hash(22) /
   four-file-dataflow(18) / session-log(12) / channel-fast-fail(6) / context-pressure(9) / summary-readability(13)。
2. 全量 `run-selftests.sh --fresh`：Total=90 PASS=90 FAIL=0（run=90 reused=0）。
3. grep 验收：`grep -rnE '"47"|= *47\b' selftest-*.sh | grep -v '46→47\|44→46'` 零命中（grep exit=1）。
4. 全程禁 git 写操作：仅 `git status --short` / `git diff --stat` / `git diff` 只读。
5. 7 文件 `bash -n` 全 OK。

## 改动文件（7 个，均 selftest 脚本）
selftest-requirement-coverage.sh / selftest-evidence-anchor.sh / selftest-final-gate-hash.sh /
selftest-four-file-dataflow.sh / selftest-session-log.sh / selftest-channel-fast-fail.sh /
selftest-context-pressure.sh
（summary-readability.sh 零改动；attest-plan.sh 为 S2 遗留改动，非本任务触碰）

## 结论
8 FAIL 全部清零，全量 90/90 绿，零新红，零 git 写。任务完成。
