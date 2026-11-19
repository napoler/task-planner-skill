# S3 任务书：防倒退机制接线 + selftest 断言 + variant 策略抽样（2026-11-20）

执行体：在 worktree 内把 P1-S2 已落地的 Rule 111/106.8/22.4f 与主模板两区块**接线**到 SKILL/脚本链，并建防倒退 selftest。全程中文。S2 产出已验证：core `### 111`@critical-rules.md:235、discipline `106.8`@:759、dispatch `22.4f`@:68、主模板「📦 进度产出基线」「🛡 防倒退终检」双区块在位。

## 0. 绝对路径（worktree 内）
- W=/mnt/data/dev/task-planner-skill/tmp/worktrees/task-antiregress-tplgov-20261120
- SKILL：$W/skills/task-planner/SKILL.md（先 Read 找 Phase 流程/检查点/收口序列段，跟随既有风格最小增量）
- init 脚本：$W/skills/task-planner/scripts/init-session.sh（既有提示风格参考 [template-sense]/[init] 行）
- 终验脚本：$W/skills/task-planner/scripts/check-complete.sh
- 新 selftest：$W/skills/task-planner/scripts/selftest-antiregress.sh（结构样本=先 Read selftest-template-lifecycle.sh 学断言/输出风格）
- registry：$W/skills/task-planner/scripts/selftest-registry.tsv（新 selftest 登记一行，格式随既有行）
- variant 抽样（3 个）：$W/skills/task-planner/templates/variant/ 下 rule-enhancement-type.md、bugfix-type.md、refactor-type.md（先 ls 确认存在，缺位则选其他非轻量档 variant 并在 findings 登记替换）

## 1. 交付物（6 处）
① SKILL.md：两处触发点接线——(a)计划初期：在计划初始化/规划流程相关段落加一句「计划期登记 📦 进度产出基线（Rule 111），禁倒退清单随计划 attest 锁定」；(b)交付面：在收口/终验相关段落加「交付/合并前执行 🛡 防倒退终检（Rule 111/106.8）」。最小增量，禁改既有行。
② init-session.sh：渲染完成后输出一行提示（跟随既有 echo 风格），提醒登记进度产出基线；禁改渲染逻辑本体。
③ check-complete.sh：加一条 warn 级提示检查（防倒退终检留痕提示，跟随既有 template-sense T3 warn 口径；不做硬门）。
④ selftest-antiregress.sh 新建：断言集=111 三份唯一（负断言：不得 ≥2）、106.8/22.4f 在位、主模板双区块+净效果关键词、SKILL/init/check-complete 三文件接线命中、（可选）variant 抽样命中。输出风格随样本（PASS=n FAIL=n + rc）。
⑤ registry.tsv：登记新 selftest；若任何既有计数钉值断言（如 selftest 总数）因新增脚本漂移，同步修复该断言并登记。
⑥ variant 抽样 3 文件：各加一行轻量指针（放在验证/检查区块附近或文件头注释区）：「📦/🛡 进度产出基线与防倒退终检：按主模板 Rule 111 区块执行（本 variant 不重复区块本体）」。禁选 mini-lite/l0-lite 类轻量档 variant（仪式区块豁免先例）。

## 2. 验收（自查 5 条，写入 checkpoint 自审段）
1. VC-05 面：`grep -c "进度产出基线\|防倒退终检"` 在 SKILL.md/init-session.sh/check-complete.sh/主模板 各≥1；≥3 variant 命中同 grep
2. 新 selftest PASS（rc=0）且 registry 已登记
3. `bash $W/skills/task-planner/scripts/run-selftests.sh` 全量：FAIL 集==基线 8 集（active-plan/batch-pilot/enumerate-first/execution-stability/registry/rule-reserve-pairing/self-resolution/summary-readability），零新增 FAIL；Total 数+1（100→101）若钉值断言受影响已修复
4. 改动面收敛：git diff 仅本任务书 §0 列出的文件（≤8 文件），init-session/check-complete/SKILL 的既有行为零破坏（相关既有 selftest 如 selftest-interaction/selftest-template-* rc=0）
5. 103.2 自审逐条对照，证据锚 file:line 入 checkpoint

## 3. 禁改面
§0 列出文件外一切文件禁改（含三份 rules 与主模板——S2 已完成勿再动）；既有条款/提示行零删除；主仓与部署位禁碰。若 run-selftests 暴露预存 8 FAIL 之外的失败且根因在本 S-unit 改动，修复；与本次改动无关的新暴露，登记 findings 不修（防范围漂移）。
