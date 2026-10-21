# P4-S1 code-runner — 全量 selftest 批跑与归因

## 环境事实（已核验）
- worktree: /home/terry/task-planner-skill-worktrees/kb-persist-20261022
- 分支 wt/task-kb-persist-20261022，HEAD ced08af；skills/task-planner/scripts/selftest-*.sh = 92 个
- 逐脚本完整输出: /tmp/st-logs/<script>.txt；rc/耗时: /tmp/st-summary.tsv
- 执行方式: timeout 60 bash "$f"，92 个全部跑完，无超时中断

## 批跑结果（硬数字）
- PASS=92 FAIL=0 TOTAL=92
- 耗时 min=57ms max=24559ms(selftest-final-gate-hash) avg=2617ms，累计约 241s
- 空日志 0 个，rc=124（超时）0 个，失败清单为空（无输出摘录）

## 归因分类
- A 类（疑似本任务引入）= 0
- B 类（环境性 FAIL）= 0
- C 类（HEAD 既有 FAIL）= 0
- FAIL=0 故未到主仓 /mnt/data/dev/task-planner-skill 跑对照（对照仅用于区分 A/C，无对照组可建）

## 零回归强证据（不止"跑过都绿"）
任务 diff vs 基线 534255c（= 037c683^）全部为纯新增，零修改既有文件：
```
A .zcode/plan-templates/knowledge-brief.md
A knowledge/INDEX.md  A knowledge/README.md  A knowledge/entry-template.md
A knowledge/entries/*.md (13, 含 _draft-task-v122.md)
A scripts/kb-rebuild-index.sh  A scripts/kb-search.sh  A scripts/kb-sync-from-plan.sh
20 files changed, 1310 insertions(+), 0 deletions
```
⇒ 92 个 selftest 脚本、SKILL.md、config.json 与基线逐字节相同，A 类为零是结构性结论而非偶然。

## 负结果报告（"零回归"≠"新代码被验证"）
1. 新产物零直接测试覆盖（重要）：grep 'scripts/kb-|knowledge/entries|kb-rebuild|kb-sync|kb-search' 扫全部 92 个 selftest = 0 命中；grep '.zcode/plan-templates' = 0 命中；92 份日志亦无相关字样。⇒ 92/92 绿只证"既有面未回归"，不构成对 knowledge/ 与 3 个 kb 脚本正确性的任何验证（建议后续补 selftest-kb-*.sh）。
2. 计入 PASS 实为跳过（2 脚本 / 3 条）：selftest-absorption-discipline AD-13 SKIP（env TASK_PLANNER_ABSORB_PLAN 未设 + 主仓根未解析），自报 "Total: 16 pass, 0 fail, 1 skip" 且 exit 0；selftest-skill-modify SM-08 SKIP x2（SKILL.md Rule 36 行 / C24 检查项缺失，待 P4 联动转实断言），自报 "Total: 9 PASS=7 FAIL=0 (SKIP=2)"。
3. 3 脚本无 Total 行但断言可数（排除空跑）：selftest-verify-io（=== 总计: 4 PASS, 0 FAIL ===）、selftest-user-instruction-priority（=== ALL PASS ===）、selftest-final-gate-hash（PASS=22 FAIL=0）。
4. 套件有牙的负向对照（在 /tmp 副本操作，未动仓库）：(a) 删 knowledge/ 后跑 selftest-knowledge-brief 仍 PASS —— 该脚本断言 config/SKILL/模板而非 knowledge/ 目录，反向印证第 1 条；(b) 删 config.json#properties.knowledge_brief_enforce 后重跑 → rc=1，[FAIL] T9、[FAIL] T10a，"Total: 16 PASS=14 FAIL=2" ⇒ 断言与 rc 传播机制有效，92 个 PASS 非假绿。
5. 未排除项：串行执行未测并发；git merge-base HEAD main 返回空（疑似 shallow / 历史不连通），故基线取 037c683^=534255c，不影响纯新增文件归因。

## 判定结论
- 总 PASS/FAIL：92 / 0
- A=0、B=0、C=0
- 本任务零回归：成立（A 类 = 0）
- 遗留风险（非回归）：KB 新代码无自测覆盖；2 脚本存在环境性/延后性 SKIP；/mnt/data 磁盘 99%（1.8G 可用）
