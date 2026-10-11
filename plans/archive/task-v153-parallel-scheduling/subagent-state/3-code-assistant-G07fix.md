#### [sub:G07修复] G-07 断言健壮化 checkpoint（3-code-assistant）

**结论：status=done，Total 计数与断言编号不变，两脚本验收全 PASS。**

改动点（worktree 内 scripts/selftest-goal-unit-goal-mode.sh 单文件）：
- 文件头 :19 说明行：`G-07 末行含 …` → `G-07 含 … 数据行（含断言，防跨任务追加登记行打破末行口径）`
- 断言函数区 :104 起（原 4 行注释+2 行断言 → 7 行注释+3 行断言）：
  - `tail -1 "$REGISTRY"` 末行口径 → `grep 'selftest-goal-unit-goal-mode.sh' "$REGISTRY"` 含数据行同义断言
  - PASS/FAIL 输出串同步改「含/未含 数据行」口径
  - 注释按注释规范（What+Why+修改原因/时间/原行为）写明现象（v153 追加新登记行后末行被跨任务打破复跑 FAIL）/根因（末行钉口径与 registry 纯增量追加约定冲突）/修法（含断言，编号与 Total 不变）
- 未动：G-01..G-06/G-08/G-09 断言、`Total: 9` 计数行、其他任何文件

验收实证（原文）：
- 目标脚本：`Total: 9 PASS=9 FAIL=0`，exit=0（G-07 PASS 输出串=`selftest-registry.tsv 含 selftest-goal-unit-goal-mode.sh 数据行`）
- `git diff master -- scripts/selftest-goal-unit-goal-mode.sh`：diff 仅两段（头 :19 一行替换 + 断言函数区 G-07 块），无 G-07 之外改动
- registry 面：`selftest-registry.sh` 输出 `Total: 5 PASS=5 FAIL=0 (registry rows=65, actual selftest=65)`，exit=0（零回归）
- `bash -n` 语法检查 SYNTAX_OK

排险：负结果报告——检查了 selftest-registry.tsv 现状（目标脚本数据行=行65，末行=新追加的 Rule 68 守护脚本登记行，证实末行口径确被跨任务追加打破）；未发现 G-07 改动与其他断言（G-08 零新键、G-09 行数钉）存在锚冲突；registry.sh 自登记检查口径按脚本名含断言，本改动不影响其 PASS。

scope 合规：仅写本单元 scope 文件 1 个（≤3 行断言逻辑改动，注释同步更新按 B 类扩 scope 已登记口径）；未触碰计划三文件既有内容。
