# 检查点 09 — executor S6：check-complete.sh 追加 SKILL-MODIFY GATE（Rule 36.6/36.7②）
> 代理: executor(sonnet-1) | 完成时间: 2026-09-17 | 任务: task-v079 Phase2/S6
> worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism
> 目标文件: skills/task-planner/scripts/check-complete.sh（唯一改动文件）

## 开始
- 材料包 21.2 三件已按序 Read：01-explore-conventions.md §4（GATE 顺序 + resolve_X_tier 范式）、check-complete.sh L750-834（REFLECT GATE @L780-818 + 尾部 warn 计数/exit 段 @L820-833）、selftest-reflect-verify.sh 全文（fixture/断言方法参考）
- 三文件契约 22.4a 已读（task_plan.md / findings.md / progress.md，只读未改）
- 插入锚确认：REFLECT-GATE 块尾（`        fi` + `    fi` @L817-818）之后、`# 顺带输出 warn 档触发计数` @L820 之前；CONFIG_JSON 已 @L104 定义可复用

## 完成
- Edit 一次插入 35 行（0 删除，`git diff --stat` = `35 insertions(+)`），位置 L820-854（新行），≤45 行上限达标
- 块首锚注释原文：`# [2026-09-17 task-v079] SKILL-MODIFY GATE (Rule 36.6/36.7②): 删除性行为清单登记校验`
- 语义实现：
  - 档位解析 `resolve_skill_modify_tier()`：env TASK_PLANNER_SKILL_MODIFY_ENFORCE（合法值 enforce|warn|off 优先）> `jq -r '.properties.skill_modify_enforce.default // "warn"'` > warn；jq/config 缺失 → warn（fail-open，镜像 REFLECT-GATE resolve 范式 L785-792）
  - SKIPPED：tier=off 或 task_plan.md 不含 `skills/task-planner/`（未声明涉及技能修改）→ `SKIPPED (计划未声明涉及技能文件修改)` + 正常放行（不 exit）；计划声明但无 progress.md → `SKIPPED (无 progress.md...)`
  - PASS：progress.md 存在任一即通过——① `grep -E '删除性行为清单'` ② `grep -F '[skill-modify] 无功能性删除'` ③ `grep -F '[skill-modify] 删除清单:'` → `PASSED (Rule 36.6: 删除性行为清单/无删除声明已登记)`
  - FAIL：全无 → enforce 档 stderr `SKILL-MODIFY GATE FAILED (task-v079 Rule 36.6: 涉及技能文件修改的任务须登记删除性行为清单或声明无功能性删除——对照 36.3 基线逐项确认后回填 progress.md 重跑)` + `exit 1`；warn 档同文案 + `WARNING (task-v079 Rule 36.6, warn 档不阻断: TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce 可升级)` 不阻断
- 用 Edit 工具插入（锚定 REFLECT-GATE 块尾 + warn 注释行），未用 Bash sed 改文件

## 测试证据（原样）
### 静态
1. `bash -n check-complete.sh` → `SYNTAX-OK`（0 输出）
2. `grep -n "SKILL-MODIFY GATE" check-complete.sh` → 6 处（锚注释 L820 + SKIPPED 无 progress.md L835 + PASSED L839 + FAILED L843 + WARNING L847 + SKIPPED 未声明 L852），≥2 达标

### 行为实测（fixture 方法镜像 selftest-reflect-verify.sh 的静态断言思路 + REFLECT-GATE 的 tier 语义）
方法说明：/tmp/skill-modify-gate-fixture 造 case-pass/case-fail/case-skip/case-decl/case-list 五个最小 plan 目录（task_plan.md 含「执行范围限制」表，case-skip 表内无 skills/task-planner/ 路径；progress.md 各含/不含目标行）。因 3-File Gate（Rule 19.5）先于 GATE 段对 fixture 报 missing findings.md 使 python_rc=1（整个 GATE 段被 `if [ "$python_rc" -eq 0 ]` 跳过），测试副本对单行 `python_rc=$?` 打 test-patch 强制 python_rc=0（不改动被交付文件本体），其余脚本字节未变。
- T1 有清单（progress.md 含「## 删除性行为清单」）→ `rc=0`，stderr 原文：
  `[plan] SKILL-MODIFY GATE PASSED (Rule 36.6: 删除性行为清单/无删除声明已登记)`
- T2 无清单 + warn（TASK_PLANNER_SKILL_MODIFY_ENFORCE=warn）→ `rc=0`（不阻断），stderr 原文：
  `[plan] SKILL-MODIFY GATE WARNING (task-v079 Rule 36.6, warn 档不阻断: TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce 可升级) — 未登记删除性行为清单/无删除声明`
- T3 无清单 + enforce（TASK_PLANNER_SKILL_MODIFY_ENFORCE=enforce）→ `rc=1`，stderr 原文：
  `[plan] SKILL-MODIFY GATE FAILED (task-v079 Rule 36.6: 涉及技能文件修改的任务须登记删除性行为清单或声明无功能性删除——对照 36.3 基线逐项确认后回填 progress.md 重跑)`
- T4 无技能范围声明（task_plan.md 范围表仅 docs/readme.md）→ `rc=0`，stderr 原文：
  `[plan] SKILL-MODIFY GATE SKIPPED (计划未声明涉及技能文件修改)`
- T5 progress.md 仅 `[skill-modify] 无功能性删除` 行 → `rc=0` PASSED（三种 PASS 判定之一，补测通过）
- T6 progress.md 仅 `[skill-modify] 删除清单:` 前缀行 → `rc=0` PASSED（同上）

### diff 证据
`git -C <worktree> diff --stat` 全 worktree（含前序 S3/S4/S5 产物）：
```
 skills/task-planner/config.json                  |  6 ++++
 skills/task-planner/references/critical-rules.md | 12 ++++++++
 skills/task-planner/scripts/check-complete.sh    | 35 ++++++++++++++++++++++++
 skills/task-planner/scripts/zcode-pretooluse.sh  |  7 ++++-
 4 files changed, 59 insertions(+), 1 deletion(-)
```
本 S-unit 单独：`git diff --stat -- skills/task-planner/scripts/check-complete.sh` = `35 insertions(+)`，0 deletion，仅该 1 文件。

## 8 字段返回（22.4b）
- status: done
- completed: [S6 全部——材料包 Read / Edit 插入 GATE / 静态自验 / 4+2 场景行为实测 / diff 复核]
- files_changed: [/mnt/data/dev/task-planner-skill-worktrees/task-v079-skill-modify-conservatism/skills/task-planner/scripts/check-complete.sh]
- evidence: [上节测试证据原样：T1-T6 六条 + grep 锚 6 处 + 单文件 diff --stat 35 insertions 0 deletion]
- acceptance: [GATE 在位（REFLECT-GATE 块尾 L818 后 / warn 计数段前）+ 三档语义（enforce FAIL exit1 / warn WARNING 不阻断 / off 跳过）+ SKIPPED 双分支（未声明技能修改 / 无 progress.md）+ PASS 三种登记行判定 + 仅 1 文件 +35 行 ≤45]
- issues: [无。注：worktree diff --stat 另含 S3/S4/S5 已交付的 4 文件（config.json +6 / critical-rules.md +12 / zcode-pretooluse.sh +7-1 / 未跟踪 check-skill-modify.sh），非本 S-unit 改动；本 S-unit 仅 check-complete.sh]
- next: [主进程复核后 Phase 2 收尾（progress/VC-3③ 回填），串行进 Phase 3（S7 selftest-skill-modify.sh / S8 锚级联）]
- checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v079-skill-modify-conservatism/subagent-state/09-executor-s6.md
