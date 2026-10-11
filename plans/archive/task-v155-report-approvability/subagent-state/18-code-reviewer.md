# [sub:18-code-reviewer] task-v155 .sh 代码改动 只读审查

- 时间: 2026-10-10
- rubric: skills/task-planner/review-library/code-quality-review/SKILL.md
- 审查方式: worktree 内 `git diff 5afba9c..HEAD -- '*.sh'`（真实分支改动）+ Read 新文件全文；全部断言实跑复现
- 结论(binding): **CHANGES_REQUESTED**（2×P1；P1-1 待裁决 lint 的 ugrep 不兼容空输入语义、P1-2 merge-back 行数钉冲突；余 P2/nit）

## 审查对象总清单（Rule 70①）

> 基线澄清：任务书要求审 `git diff master..HEAD`，但 master 已前进（含 task-v153 Rule 68 落地，master-ahead 明细见下），
> 分支 merge-base=`5afba9c`(v151)。故 `master..HEAD` 会把 v153 已落 master 的工作显示成「假删除/假回退」，
> **非本分支改动**。本分支真实 .sh 改动 = 以下 5 文件（命令：`git diff 5afba9c..HEAD --stat -- '*.sh'`）。

| # | 文件（绝对路径） | 一句话 |
|---|------------------|--------|
| 1 | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-report-reviewability.sh | 新建，RRV-01..13 静态守护（Rule 70 条款+S KILL 接线+13 触点+registry/config/lint） |
| 2 | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/check-complete.sh | rcov-gate 段后追加 report-lint fail-open 段（run_report_lint，3 项轻量 lint） |
| 3 | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-self-resolution.sh | SR-01 锚 `^41\.`→`^41\.[0-9]+ \*\*`（排除 Rule 70.5 行内「41.5」误计，7→6） |
| 4 | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-goal-unit-goal-mode.sh | G-07 末行钉→存在性断言；G-09 SKILL 行数钉 515→540 |
| 5 | /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/scripts/selftest-skill-split.sh | T-主 SKILL 行数钉 515→540（与 G-09 同步） |

（前缀统一 /mnt/data/dev/task-planner-skill-worktrees/v155-report-approvability/skills/task-planner/）

### 被排除的「假改动」（master..HEAD 独有，非本分支）
check-plan-dispatch.sh（-239，v153 Rule 68 段回退假象）/ selftest-parallel-scheduling.sh（整文件删除假象）/
selftest-lane-advancement.sh / selftest-requirement-coverage.sh / selftest-research-first.sh /
selftest-split-pattern-library.sh / selftest-tool-selection.sh / selftest-workflow-orchestration.sh（1-68↔1-66 锚假回退）。
上述均为「分支基于 v151、master 已含 v153」的基线漂移产物，**本分支未触碰**。

## 逐条问题清单

[P1] scripts/check-complete.sh:983 — 待裁决 lint 的 `grep -vqE` 空输入语义依赖 grep 实现（ugrep 不兼容）
- 原文: `if grep -n '待裁决' "$ds_file" 2>/dev/null | grep -vqE '/|http'; then`
- 原因: 当 delivery-summary.md **无任何「待裁决」行**（金标准 templates/delivery-summary.md 即无该区块）时，首段 grep 输出空流；`grep -vqE` 对**空输入**的退出码 GNU grep=1（不 warn，正确）而 **ugrep=0（warn，误报）**。ZCode 环境 `grep` 被 shell 函数包装为 ugrep（§十 环境事实 + 本次实测 `grep version: ugrep 7.8.4`）。实测复现：`printf '' | grep -vqE 'x'; echo $?` → ugrep=0。后果=在 ugrep 宿主上对每份合规交付总结误报「待裁决项缺对象定位」。
- 证据: `printf '' | grep -vqE 'x'` → exit 0（ugrep）/ `/usr/bin/grep -vqE` → exit 1（GNU）；本仓既有同类惯用写法规避此坑 → check-complete.sh:741 用 `grep -vxF -f ... | grep -q .`（显式测非空）。
- 修复: 改为与 :741 同惯用：「有 待裁决 行且其中有行缺路径」= `grep -n '待裁决' "$ds_file" 2>/dev/null | grep -vE '/|http' | grep -q .`
- 置信度: HIGH（机制实测复现；注：脚本以子进程 `bash check-complete.sh` 运行时用系统 GNU grep，误报仅在 grep=ugrep 的宿主/被 source 场景显现，功能面仅 warn 不阻断）

[P1] scripts/selftest-goal-unit-goal-mode.sh:129 + scripts/selftest-skill-split.sh:48 — 行数钉 540 与 master 的 526 冲突（merge-back 必冲突，须解为 540）
- 原文: `if [ "$n" -le 540 ]; then ok 09 "SKILL.md 行数=$n ≤540（task-v155 上调后上限…`（goal-unit:129）；`t "T-主 行数 ≤540（task-v125 S3…`（skill-split:48）
- 原因: master 已把同两处上调至 `≤526`（v153 口径，`git show master:...` 实测）。两分支对同一行做不同编辑 → `git merge-tree --write-tree master HEAD` 报 CONFLICT。合并后 SKILL.md≈530 行（v151 511 + v153 12 + v155 7），>526（master 钉）但 ≤540（本钉）；**若 merge 解冲突时保留 master 的 526，G-09/T-主 将在合并后 FAIL**。
- 证据: `git merge-tree --write-tree --name-only master HEAD` → `CONFLICT (content): ... selftest-goal-unit-goal-mode.sh`、`... selftest-skill-split.sh`；`git show master:.../selftest-goal-unit-goal-mode.sh | grep -o 'n\" -le 5[0-9][0-9]'` → `n" -le 526`；master SKILL.md=523、branch=518。
- 修复: merge-back 解冲突时**保留本分支的 540**（不要取 master 526）；合并后回归跑 goal-unit/skill-split 两脚本确认 PASS。
- 置信度: HIGH

[P2] scripts/selftest-report-reviewability.sh:143 — RRV-07 锚可被注释满足（守卫可腐化）
- 原文: `RRV07_LINT=$(cnt "report-lint" "$CHECKCOMPLETE")`
- 原因: `report-lint` 字样在 check-complete.sh 出现 6 次，其中注释头 5 次；若删除 `run_report_lint` 可执行体仅留注释头，`grep -c 'report-lint' ≥1` 仍成立 → RRV-07 假 PASS（探针未锚可执行代码行）。此反模式本仓 v153 CR-F4 已明确判过（「仅注释留存即 PASS，断言可腐化」）。
- 证据: `grep -c 'report-lint' check-complete.sh` → 6（含注释行 938-946）。
- 修复: 锚可执行行，如 `cnt 'run_report_lint$' "$CHECKCOMPLETE"` 或 `[report-lint] ⚠` printf 行（`grep -cE '\[report-lint\] ⚠' ≥1`）。
- 置信度: HIGH

[P2] scripts/selftest-report-reviewability.sh:207 — RRV-13 自指同义反复（断言恒真，零覆盖）
- 原文: `RRV13_PLACEHOLDER=$(cnt "TODO(RRVV-14)" "$SCRIPT_DIR/selftest-report-reviewability.sh")`
- 原因: 断言的「守护对象」是本脚本自身的占位注释字符串，只要注释在就 PASS，不校验任何交付物；计入 PASS 计数会虚增「13 条断言全过」的可信度。
- 证据: `grep -c 'TODO(RRVV-14)' selftest-report-reviewability.sh` → 2（注释 + 断言自身）；实跑 RRV-13 PASS。
- 修复: 未实现即标 WARN 或占位不进 PASS 计数（`warn "RRV-13" ...`），待 S13 实现真实断言再转 PASS。
- 置信度: HIGH

[P2] scripts/selftest-report-reviewability.sh:132 — RRV-06 config 子项空值时 `[ "" -gt 0 ]` 报整型错误
- 原文: `RRV06_CONFIG=$(grep -c -e 'report_lint' -e 'reviewability_enforce' "$CONFIG" 2>/dev/null || true)`（下游 `if [ "$RRV06_CONFIG" -gt 0 ]`）
- 原因: config.json 缺失/不可读时 grep -c 无 stdout，变量为空 → `[ "$RRV06_CONFIG" -gt 0 ]` 触发 `bash: integer expression expected`（本仓 §五 禁静默错误），落入 elif 分支语义错位。
- 证据: `bash -c 'X=$(grep -c -e report_lint /nonexistent 2>/dev/null||true); [ "$X" -gt 0 ]'` → `integer expression expected`。
- 修复: `${RRV06_CONFIG:-0}` 归一化后比较。
- 置信度: HIGH（当前 config.json 恒存在，实际触发面低）

[P2] scripts/check-complete.sh:966-970 — 检查① 表头启发式（区块首个表格行恒当表头跳过）可漏判
- 原文: `if (!hdr) { hdr=1; next }   # 区块内首个表格行=表头`
- 原因: 若「## 2. 产出清单」区块无表头/分隔行（直接数据行），首个数据行被当作表头跳过 → `rl_nopath` 少计 1，可能由 ≥2 降为 <2 而漏 warn。`hdr` 亦为全局、跨区块不复位（当前仅单区块，无实害）。
- 证据: 合成 ds2.md（表头「文件/路径」+ 1 无路径数据行）→ awk 计 1（非表头行）；若删表头同内容则计 0。
- 修复: 表头识别改为「区块内首个 | 行且含表头关键词（文件|路径|产出）」或去掉 hdr 跳过、仅按分隔行判定。
- 置信度: MED

[P2] scripts/check-complete.sh:983 — 检查③ 对「待裁决」标题行误报（标题本身无路径）
- 原文: `if grep -n '待裁决' "$ds_file" 2>/dev/null | grep -vqE '/|http'; then`
- 原因: 若交付总结以 `## N. 待裁决` 作区块标题，该标题行本身不含路径 → 即使其下条目均带路径也会 warn。与 P1-1 同源行。
- 证据: 合成 ds3.md（标题 `## 6. 待裁决` + 带路径条目）→ 命中标题行 → 触发 warn。
- 修复: 排除标题行（`grep -vE '^#|…'`）或仅对条目行（`^- |^[0-9]+\. `）判定。
- 置信度: MED（金标准模板无「待裁决」标题，触发面取决于实际写法）

[nit] scripts/selftest-report-reviewability.sh:44-59 vs 163-166 — 「13 触点」清单与实际受检集合口径不一致
- 原文: `TOUCH_FILES=( ... )`（13 项，不含 plan-writer.md）/ `RRV09_PW=$(cnt "Rule 70" "$SKILL_ROOT/companion/agents/plan-writer.md")`
- 原因: RRV-09 额外校验 plan-writer.md（不在 13 清单内）；命名「13 触点」低于实际守护面，易误导维护者增删触点时漏配。
- 修复: 统一触点清单为单一来源（TOUCH_FILES 内并入 plan-writer.md，或注释注明 RRV-08/09 为独立面组）。
- 置信度: HIGH（口径事实，影响轻微）

[nit] scripts/selftest-goal-unit-goal-mode.sh:110 — G-07 修复与 master 既有修复重复
- 原文: `if grep -q 'selftest-goal-unit-goal-mode.sh' "$REGISTRY"; then ok 07 ...`
- 原因: master 已含等价的「存在性断言」（v153 健壮化：`row="$(grep ...)"; if [ -n "$row" ]`）。本分支改动语义等价、文本不同 → merge 冲突纯文本冗余（非缺陷）。
- 修复: merge-back 时取任一侧即可，无需保留两版。
- 置信度: HIGH

## 负结果报告（未发现问题的面）
- 语法：`bash -n` 5 文件全 OK。
- 实跑：selftest-report-reviewability.sh `Total: PASS=13 FAIL=0` exit0；selftest-goal-unit-goal-mode.sh `9 PASS=9 FAIL=0` exit0；selftest-self-resolution.sh `13 PASS=13 FAIL=0` exit0。
- 锚点复核（关键断言实跑）：SR-01 `grep -c '^41\.'`=7 vs `grep -cE '^41\.[0-9]+ \*\*'`=6（修复正确，第 7 命中=:883「41.5 打包呈报补四要素」行内引用）；RRV-01 title=1/sub=6；RRV-03 Rule 70 段 `:\s?[0-9]+`=0；RRV-04 Rule70=8/C46=1；RRV-08/09/10/11/12 各阈值实测满足；G-09 实跑 SKILL.md=518 ≤540。
- fail-open 核验：check-complete.sh 无 `set -e`；run_report_lint 全分支 `return 0`、仅 `printf ... >&2`、不写 FAIL 计数、不改 exit（符合注释承诺）；delivery-summary.md 缺失走 SKIPPED 直返。
- 越界自检：本分支未触碰范围外文件（5 文件均在任务书/Phase 清单内）。
- 安全面：无 SQL/XSS/路径遍历/认证绕过/危险命令/不可逆副作用（纯只读 grep/awk lint）。

## 最终结论
status: done
acceptance: 2/2 pass — [1:PASS verdict+总清单+逐条问题已入 checkpoint; 2:PASS 每条 P1/P2 附可复现证据]
files: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/18-code-reviewer.md(new) | none(仓库只读，未改)
evidence: check-complete.sh:983（`grep -vqE` 空输入 ugrep=0/GNU=1 实测）；selftest-report-reviewability.sh:143（`grep -c 'report-lint'`=6）；selftest-goal-unit-goal-mode.sh:129（master≤526 vs 分支≤540，merge-tree CONFLICT）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v155-report-approvability/subagent-state/18-code-reviewer.md (status: done)
findings_written: findings.md ## Research Findings 段末 `#### [sub:18-code-reviewer]` | progress.md Phase 8 `[sub:18]`
blockers: none
confidence: HIGH
