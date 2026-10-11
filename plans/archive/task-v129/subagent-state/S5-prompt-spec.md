# S5 执行规格书（selftest-requirement-coverage.sh + registry 登记行）
> 本文件=S5 单元材料包（prompt 超限按 Rule 35.3 落盘）。与 findings F-6.5 同源。

## 任务（S5：新建 selftest 脚本 + registry 登记行，2 文件）
worktree 根（下称 $WT）: /mnt/data/dev/task-planner-skill-worktrees/task-v129

### 文件 A（新建）: $WT/skills/task-planner/scripts/selftest-requirement-coverage.sh
1. 范式：先 Read $WT/skills/task-planner/scripts/selftest-lane-advancement.sh 全文，严格对齐其结构（头部 # 注释块：脚本名/task 出处/用途/断言清单 RC-01..RC-15/依赖位置；SKILL_ROOT 解析方式；ok N / bad N 函数；末尾 `Total: N PASS=x FAIL=y` 汇总行与 exit 语义）。
2. 实现 15 条断言（路径变量：$CRIT=$WT/skills/task-planner/references/critical-rules.md；$SKILL=$WT/skills/task-planner/SKILL.md；$TDEL=$WT/skills/task-planner/templates/delivery-summary.md；$CONFIG=$WT/skills/task-planner/config.json；$REG=$WT/skills/task-planner/scripts/selftest-registry.tsv）：
   - RC-01 `[ $(grep -c '^51\.' "$CRIT") -ge 6 ]`
   - RC-02 `grep -q '^### 51 ' "$CRIT"`
   - RC-03 `grep -q '需求原文锚定' "$CRIT"`
   - RC-04 `grep -q '覆盖判据' "$CRIT"`
   - RC-05 `grep -q '需求覆盖核对表' "$CRIT"`
   - RC-06 `grep -q '自缩水禁令' "$CRIT"`
   - RC-07 `grep -q '前置盘点' "$CRIT"`
   - RC-08 `grep -q '零新 config 键' "$CRIT"`
   - RC-09 `grep -q 'Rule 51（需求覆盖与完成声称门控' "$SKILL"`
   - RC-10 `grep -q '^| C35 |' "$SKILL"`
   - RC-11 `[ $(grep -c 'Rules 1-39' "$SKILL") -eq 2 ] && [ $(grep -c '1-40' "$SKILL") -eq 0 ]`
   - RC-12 `grep -q '需求覆盖核对' "$TDEL" && [ $(grep -cE '^## [1-5]\.' "$TDEL") -eq 5 ]`
   - RC-13 config.json `.properties|keys|length` = 40（jq 缺失时按 RT-09 口径打 SKIPPED 不 FAIL）
   - RC-14 `awk -F'\t' 'NR>1{print $1}' "$REG" | grep -q 'selftest-requirement-coverage.sh'`
   - RC-15 负断言：`[ $(grep -c '^50\.' "$CRIT") -eq 0 ]`（50 号未被误占）
   每条断言前写一行 # 注释（What + Why，对齐 lane-advancement 风格）。
3. 脚本 `chmod +x`；`bash -n` 语法自检通过。

### 文件 B（追加 1 行）: $WT/skills/task-planner/scripts/selftest-registry.tsv
先 Read 尾部 3 行对齐格式（4 个 TAB 分隔字段、无空字段），追加一行（字段间用真实 TAB 字符）：
`selftest-requirement-coverage.sh→TAB→Rule 51 需求覆盖与完成声称门控守护（task-v129）→TAB→Rule 51 六子条 / SKILL.md bullet+C35 / delivery-summary 区块 / config 零新键→TAB→SKILL.md:286,201,310 / critical-rules.md:522-530 / templates/delivery-summary.md:35`
（上行的 `→TAB→` 仅为说明分隔位，实际写入时替换为单个 TAB 字符。）仅追加 1 行，其余零改动。

## 验收标准（在 worktree 内逐条跑，全部满足）
- `bash skills/task-planner/scripts/selftest-requirement-coverage.sh` → Total 行 FAIL=0（15 断言全 PASS；RC-13 允许 SKIPPED）
- `bash skills/task-planner/scripts/selftest-registry.sh` → 全 pass（无未登记/孤儿/重复/字段缺陷）
- `wc -l skills/task-planner/scripts/selftest-registry.tsv` = 47
- `bash skills/task-planner/scripts/selftest-self-resolution.sh` → FAIL=0（SR-12 动态口径：47=脚本数+1）
- 邻锚抽样回归：`selftest-lane-advancement.sh`、`selftest-template-lifecycle.sh`、`selftest-tool-selection.sh` 三脚本各 FAIL=0
- `ls skills/task-planner/scripts/selftest-*.sh | wc -l` = 46

## 返回模板（22.4b 8 字段）
status: complete|partial|failed
key_findings: <新脚本断言结构摘要+registry 行>
evidence: <各 selftest Total 行原文 + wc -l 输出>
acceptance: <对照验收逐条自检>
files_touched: <应仅 2 个目标文件>
risks: <风险/不确定项>
open_questions: <待主进程裁决项>
checkpoint: <S5-executor.md 落盘确认>
