# 06-executor-rule75-r6 检查点（F 组 / task-crossprojauth-20261104 R6）

## S1 完成（2026-11-04）
- clause75-r6.md（75.9/75.10/75.11/75.12 四子条，主进程审定原文）**逐字追加**到 `skills/plan-research-router/references/critical-rules-research.md` 文件尾。
- 锚点核验：追加在「- 机制面：LLM 行为面守门；…75.8 机制面自锚。」行（原 L68）之后，追加前空一行（L69 空行，L70 起 75.9）。
- 逐字核验：`diff <(tail -n 7 目标文件) clause75-r6.md` = 空（VERBATIM-OK）；git diff --stat = +8 行纯增量（75.9-75.12 四段 + 分隔空行）。

## S2 完成（2026-11-04）
- `skills/task-planner/scripts/selftest-proactive-research.sh` 三处按 spec 精确修改：
  1. 头注释 L5「共 15 条编号断言 PR-01..PR-15：」行尾补注「 [2026-11-04 task-crossprojauth-20261104-R6] 增 PR-16..PR-18（Rule 75.9/75.10/75.11 文本锚）」
  2. PR-09 断言行后插入 PR-16/17/18 三条 ge/cnt 断言行（锚 `^75\.9 ` / `^75\.10 ` / `^75\.11 `，对象 $CR）
  3. 尾行 `echo "Total: 15 …"` → `echo "Total: 18 PASS=$PASS FAIL=$FAIL"`
- git diff --stat：该脚本 +5 -2（净增 3 断言行 + 头注释注记）。

## S3 自检全 PASS（2026-11-04）
- V1：`grep -c '^75\.9 '`=1、`'^75\.10 '`=1、`'^75\.11 '`=1、`'^75\.12 '`=1 ✔
- V2：`grep -c '^75\.8 '`=1（75.0-75.8 原文零改动核验）✔
- V3：`bash selftest-proactive-research.sh` rc=0，末行 `Total: 18 PASS=18 FAIL=0`（PR-01..PR-18 全 PASS，含新增 PR-16/17/18）✔

## 最终结论
S1-S3 全部完成，V1-V3 全绿。偏差清单：**无**。
git diff --stat（本组两文件）：
- `skills/plan-research-router/references/critical-rules-research.md | 8 ++++++++`
- `skills/task-planner/scripts/selftest-proactive-research.sh | 7 +++++--`

遵守禁止项：未 git commit / 未部署 / 未跑 run-selftests 全量回归；未改 75.0-75.8 原文、config.json、其他脚本、宪法 AGENTS.md；与 E 组文件（critical-rules-discipline.md / task-planner SKILL.md / hook 等）零交集，未触碰。

## S4 级联面补项（2026-11-04，主进程追加指令）
- `skills/task-planner/references/critical-rules.md` L196 plan-research-router 卫星路由行：「调用条件=…证据面覆盖与反推诿时」句末追加「、用户明示参考网络诉求触发（75.9）/调研通道降级链推进（75.10）/无证据禁脑补核验（75.11）时」。
- 仅改该一行；偏差登记：该文件会话开始时即为主仓既有未提交 M 状态（E 组在途），diff 中 task-discipline 行变更系既有改动非本组所为，本组 Edit 只命中 plan-research-router 行（old_string 唯一匹配，未触碰其他行）。
- V4：`grep -c '75\.9' skills/task-planner/references/critical-rules.md` = 1（≥1 达标）✔
