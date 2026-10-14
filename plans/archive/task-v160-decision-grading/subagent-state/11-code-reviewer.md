# 11-code-reviewer — task-v160 S11 代码审查检查点

- 任务: 只读审查 task-v160 worktree 相对 master 的全部 .sh 改动
- worktree: /mnt/data/dev/task-planner-skill-worktrees/v160-decision-grading
- 真实审查基线: merge-base 62b8b4b..HEAD（分支自有的 .sh 改动）
- 结论: APPROVED（无 P0/P1；1 条 P2 语义收窄 + 2 条 Nit）

## 审查对象总清单（真实分支 diff = 5 个 .sh）
1. skills/task-planner/scripts/selftest-decision-grading.sh — 新建，DG-01..DG-12 静态断言守护（219 行，12/12 PASS）
2. skills/task-planner/scripts/selftest-conclusion-discipline.sh — CD-11/CD-12 宽容锚扩 1-7[0-2]（+4/-1）
3. skills/task-planner/scripts/selftest-parallel-scheduling.sh — P-05 上界判据改动态提取（+4/-1）
4. skills/task-planner/scripts/selftest-research-first.sh — RF-06 宽容锚扩 1-7[0-2]（+1/-1）
5. skills/task-planner/scripts/selftest-root-resolution.sh — RR-09 全集锚追加 7[0-2]（+2/-1）

## 关键证据
- `git merge-base master HEAD` = 62b8b4b；`git diff 62b8b4b..HEAD --stat -- '*.sh'` = 5 文件（含新增）——派发单所述的 2 个 selftest 删除 + 1 个 smoke 删除**不属于本分支**（见 P2#0）。
- `bash -n` 5/5 OK；`bash selftest-decision-grading.sh` → Total: PASS=12 FAIL=0 WARN=0（exit=0）
- 4 个被改脚本自跑: conclusion-discipline 24/24、parallel-scheduling 9/9、research-first 12/12、root-resolution 17/17，均 FAIL=0
- DG-02 括号容错实测（LC_ALL=C.UTF-8 / C / POSIX 三 locale）: 对「A 级（必须询问」「A 级必须询问」两形态均命中，计数=2，无误报
- P-05 提取实测: `grep -oE '^### [0-9]+ '` max=69（68 行）；`grep -oE '^## Rule [0-9]+'` 仅命中 2 行（892 Rule 70 / 918 Rule 72）→ max=72
- registry 新行 4 列（TAB），`grep -c 'selftest-decision-grading' registry`=1；无 BOM/CRLF（file=UTF-8 bash script）

## 逐条问题
🟡 [性质=方法/SCOPE] `.sh` 审查基线口径
- 原文(派发单): "git -C ... diff master..HEAD -- '*.sh'"
- 原因: 两点 diff `master..HEAD` 会混入 master 分叉后领先的 26 个提交（含 v152/v158 的并集导入）；据此统计得 25 个 .sh（含 3 个“删除”——selftest-context-pressure.sh / selftest-source-anchor-discipline.sh / 7-code-runner-S6-smoke.sh）。经核验这 3 文件在 merge-base(62b8b4b) 与 HEAD 均不存在、仅存于 master，属 master 领先侧，**非本分支删除**。真实本分支改动仅 5 个 .sh。
- 修法: 审查请用 `git diff $(git merge-base master HEAD)..HEAD -- '*.sh'`（三点 `master...HEAD` 等价）；派发单口径建议同步修正。
- 置信度: HIGH

🟡 [P2] skills/task-planner/scripts/selftest-parallel-scheduling.sh:106 — P-05 crit_max 提取采样面由 69 个标题收窄至 2 个，注释「判据语义不变」表述不准确
- 原文: `#   判据语义不变：SKILL 上界须 == critical-rules 实测最大编号（纯机械对齐，不改判据强度）。` 与 `crit_max="$(grep -oE '^## Rule [0-9]+' "$CRIT" | grep -oE '[0-9]+' | sort -n | tail -1)"`
- 原因: 旧模式 `^### [0-9]+ ` 实测覆盖 68 行/Rules 1-69（max=69）；新 `^## Rule [0-9]+` 仅命中 2 行（Rule 70、Rule 72）。即规则集 1-69 完全退出采样，判据从「全量规则最大号」变为「`## Rule N` 形态子集最大号」。当前 max=72 仍正确（Rule 72 恰为最大号），但属采样面收窄而非「语义不变」；若未来某 Rule 1-69 标题被裁剪，本判据不再报警。
- 现实风险: 低（新规则当前均以 `## Rule N（…）` 形态追加，且一旦上界失配会 FAIL 而非静默 PASS，偏 fail-closed）。
- 修法: 二选一——① 合并两种形态取并集最大号 `grep -oE '^(## Rule|###) [0-9]+'`；② 至少把注释「判据语义不变」改为「采样形态由 `### N` 改为 `## Rule N`（仅覆盖新形态规则，当前最大号 72）」如实说明覆盖面。
- 置信度: HIGH（证据: `grep -cE '^## Rule [0-9]+'`=2 vs `grep -cE '^### [0-9]+ '`=68）

💬 [Nit] skills/task-planner/scripts/selftest-decision-grading.sh:70 — `cnt()` 对「存在但不可读」文件返回空串，`[ "" -lt N ]` 触发整数表达式告警
- 原文: `cnt()  { [ -f "$2" ] || { echo 0; return; }; grep -c -e "$1" "$2" 2>/dev/null || true; }`
- 原因: `[ -f ]` 为真但 `grep` 因权限/IO 出错时，stdout 为空（`2>/dev/null` 吞错）→ 比较 `[ "" -lt N ]` 报 `integer expression expected`。行为偏保守（不会误 PASS），但输出噪声 + 静默吞错（§九 禁 `2>/dev/null` 吞错）。
- 修法: `n=$(grep -c -e "$1" "$2" 2>/dev/null || echo 0); echo "${n:-0}"`（空值兜底为 0 并显式）。
- 置信度: HIGH（探针实测: cnt 输出 `[]`，`[ : integer expression expected`）

💬 [Nit] skills/task-planner/scripts/selftest-decision-grading.sh:105-113 — DG-04/DG-11 注释自称「合规行内容锚（而非绝对编号）」，实现却硬断言 `C49`
- 原文: `# Why: 合规行内容锚（而非绝对编号）——编号让位不级联；同时锁分级语义未被裁剪。` 与 `DG04_C49=$(cnt "C49" "$SKILL")`
- 原因: 合规清单行号为并集易位资源（历史 C46→C48→C49），一旦后续合并让位至其它号，本断言会 FAIL，与注释宣称的「让位不级联」相悖（false-positive 风险）。
- 修法: 以内容定位该行（如 `grep -cE '^\\| C[0-9]+ .*决策分级与用户打断' "$SKILL"`）替代硬 `C49`，或在注释中如实标注「编号锚，让位时需级联」。
- 置信度: HIGH

💬 [Nit] skills/task-planner/scripts/selftest-root-resolution.sh:114 — ok 消息串未随锚更新（陈述 1-62，实断言已含 7[0-2]/现状 1-72）
- 原文: `ok 09 "SKILL.md 全集声明「Critical Rules 全集 1-(5[3-9]|6[0-9])」（现状 1-62）=1 且旧「1-51/53/55」残留=0"`
- 原因: 断言正则已更新为 `1-(5[3-9]|6[0-9]|7[0-2])` 且当前值 1-72，但成功消息文本仍写旧区间/旧现状，误导人工复核（纯文案漂移，断言正确）。
- 修法: 消息串同步为 `1-(5[3-9]|6[0-9]|7[0-2])`（现状 1-72）。
- 置信度: HIGH

## 已复现/排除项（负结果）
- 安全面: 5 脚本全为只读 grep/sed 计数，无 eval/rm/curl/网络/写操作；无注入面 → 无安全问题。
- shell 正确性: 5 脚本 `bash -n` 全 OK；`set -u` 用法正确（未用 `set -e`，避免 grep rc=1 中断）；变量引用均加引号；exit 语义正确（FAIL>0 → exit 1）。
- ugrep 兼容: 用 ugrep 影子 `grep` 跑新脚本 → 12/12 PASS；多字节 `（?` 量词在 C/UTF-8/POSIX 三 locale 均正确（GNU grep 实测一致）。
- DG-03 零行号引用: Rule 72 段内 `:\s?[0-9]+` 命中=0（实测），符合零行号硬编码约束。
- 零新 config 键: `decision_grading_enforce` 命中=0（实测）。

## 最终结论
status: done
acceptance: 2/2 pass — [1:PASS 2:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/subagent-state/11-code-reviewer.md (new) | /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/findings.md (+1 blk) | /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/progress.md (+1 blk)
evidence: bash selftest-decision-grading.sh → "Total: PASS=12 FAIL=0 WARN=0"(exit=0); git diff 62b8b4b..HEAD --stat -- '*.sh' = 5 files; grep -cE '^## Rule [0-9]+' critical-rules.md = 2
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v160-decision-grading/subagent-state/11-code-reviewer.md (status: done)
findings_written: ## Research Findings → #### [sub:11-code-reviewer] task-v160 .sh 代码审查（APPROVED）
blockers: none
confidence: HIGH
