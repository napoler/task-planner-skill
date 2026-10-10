# task-v156 — Code Review Gate 检查点（S8）

- 审查体: Code Reviewer（只读）
- 审查面: git diff a538a3a..HEAD（worktree /mnt/data/dev/task-planner-skill-worktrees/v156-decision-alignment）
- 基线口径说明: 任务书「master(a538a3a)」= merge-base；`git diff master..HEAD` 因 master 已前进至 79cd10a 而显示 97 文件/3879 删除（含 plans/task-v160/v164 删除），非本分支改动。真实任务面=13 文件 +202/-9。
- 结论三证据: ①执行证据=bash -n 三脚本 OK + selftest-decision-drift 实跑 22/22 PASS + 5 宽容化 selftest 实跑全 PASS ②产出证据=逐文件 diff/Read ③验证证据=grep 复现每个发现原文。

## 逐文件审查表

| 文件 | diff 要点 | 分级 | 行号锚 |
|------|-----------|------|--------|
| scripts/check-complete.sh | [judge-gate] 终验段 +19 行 | MAJOR（F1）/其余 OK | 1325-1342（缺档位门控） |
| scripts/zcode-posttooluse.sh | [judge] 节奏注入 +6 行（_jr 段） | OK（env 语义与环境一致） | 352-358 |
| scripts/selftest-decision-drift.sh | 新文件 106 行 DD-01~22 | MINOR（F2 DD-14 断言弱） | 65 |
| selftest-drift-check-subagent.sh | 锚宽容 40-(69\|71\|73)(\+N)? | OK | 61 |
| selftest-parallel-scheduling.sh | skill_max 宽锚 (\+N)? | OK | 107 |
| selftest-reliability-institution.sh | 40-[4567][0-9](\+N)? | OK | 85 |
| selftest-research-first.sh | RF-07 双锚宽化 +1-71(\+N)? | OK | 76 |
| selftest-root-resolution.sh | n 松弛为 1-[0-9]+(\+N)? | OK（负断言 m 保留） | 110 |
| selftest-registry.tsv | 自登记行 +1 | OK | 73 |
| SKILL.md | 六级联 (K1-K6) 计数 1-71+73 + C51 + 两决策点引用 | OK（Nit 拼接式 "+Rule 73"） | 9/90/234/251/297/361/387 |
| references/critical-rules.md | Rule 73 七子条 +16 行纯追加 | OK（条款完整自洽） | 944/952 |
| templates/deprecated.md | 新文件五段 +32 行 | OK（与 73.5 闭环一致） | 1-32 |
| templates/task_plan.md | 🔒 不变量声明区 +10 行 | OK（三态齐全） | 30-36 |

## 四焦点结论

1. **Rule 73 条款语义落地一致性**: PASS。SKILL 摘要（:361）「五类决策点/三态/三强制评判点/废弃只入不出/消歧义/零新键」与 critical-rules 73.1-73.7 逐项对应，无弱化/漂移。
2. **🔒 不变量声明区可执行性**: PASS。templates/task_plan.md:30-36 三态表（🔒不变量/🔀可变量/📈学得量）加持源锚列，LLM 消费者（[align] 三问 73.2「回读 🔒 不变量声明区」）可消费；selftest DD-12/13 机检关键词在位数=3。
3. **废弃只入不出闭环（deprecated.md §五段 vs 73.5）**: PASS。§1 表五列（原内容指针/废弃类型/废弃原因/日期/替代锚）=73.5 五要素；§2 分账（notepad veto vs 本文件隔离区）与 73.5 一致；§3 只入不出=73.5 语义；§4 消费侧双源=73.5；§5 消歧义=73.6。闭环无缺口。
4. **消歧义示范有效性**: PASS。deprecated.md §5 对「否决/推翻/旧版」三类型各给判据+反例；73.6 给不变量示例；术语首现带解释。有效消歧义。

## 发现清单（证据已 grep 复现）

### F1 — MAJOR（🔴/🟡 之间，判 MAJOR）[不变量契约失效] check-complete.sh [judge-gate] 未按档位门控，违背 73.4「standard/full 档」+ C51「mini 档豁免」
- 位置: skills/task-planner/scripts/check-complete.sh:1325-1342（判定行 :1330）
- 原文: 注释 :1326 `# WHAT: standard/full 档计划对照 progress.md [judge]/[align] 留痕行数`；判定 :1330 `case "${TASK_PLANNER_DECISION_JUDGE:-warn}" in`（无任何 plan_tier/PLAN_TIER_MINI 判定）
- 判据: critical-rules.md:952「机器承载=scripts/check-complete.sh [judge-gate]（standard/full 档…」+ SKILL.md:234 C51「…mini 档豁免」。
- 证据: 紧邻其上的 goal-gate 段在 :1288 `if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE"` 做档位门控并在 :1321-1323 else 跳过；[judge-gate] 段位于该 if/else/fi（:1323 闭合）之后的同级（4 空格缩进），`awk NR 1323..1342 /plan_tier|PLAN_TIER_MINI/`=零命中 → mini 与 legacy 计划同被纳入。
- 严重度: MAJOR。warn（默认）档对 mini 计划误报提示；env=enforce 档对 mini 计划 exit 1 阻断 complete——违背 mini 豁免契约、误伤轻量档。无数据丢失/无安全面（故非 BLOCKER）。
- 修复（返工路径）: 将 case 块包进与 goal-gate 同款判据：
  `if grep -qm1 -E 'plan_tier:[[:space:]]*(standard|full)' "$PLAN_FILE" 2>/dev/null; then <case 块>; else printf '[judge-gate] SKIPPED (mini 档豁免或计划无 plan_tier: standard|full 标记, Rule 73.4)\n' >&2; fi`
- 置信度: HIGH

### F2 — MINOR [可观测性缺口] selftest DD-14 仅断言字符串存在，未守护档位豁免/env enforce 行为
- 位置: skills/task-planner/scripts/selftest-decision-drift.sh:65
- 原文: `[ "$(cnt 'judge-gate' "$GATE")" -ge 1 ] && ok "DD-14 check-complete [judge-gate] 锚" || bad "DD-14" "门控锚缺失"`
- 原因: 只锚字符串存在；F1 的档位缺陷因此逃逸机检（selftest 已在头部如实披露机器边界，故 MINOR 非 MAJOR）。
- 修复: 增断言 judge-gate 段含 `plan_tier:[[:space:]]*(standard|full)` 档位门控（或守护 mini 的 SKIP 输出行），使 F1 类回归可机检。
- 置信度: HIGH

### F3 — MINOR/风险提示 [合并面] 审查基线歧义：真实 master 已前进，合并后锚需复验
- 现象: `git log --oneline -1 master`=79cd10a；`git merge-base master HEAD`=a538a3a；`git diff a538a3a..master --stat` 显示 master 侧亦改 critical-rules（+28，含 Rule 72）、SKILL.md、5 个同锚 selftest、registry。
- 风险: 合并真实 master 时，若 critical-rules 的 73 段与 master 的 72 段同区（文末）追加 → 文本冲突；合并后 skill_max（SKILL「1-71+73」提取=73）需与 crit_max 一致——本基线自洽（P-05 实跑 PASS），合并真实 master 后须复验。
- 定性: 纯流程/合并风险提示，非 v156 代码缺陷。
- 置信度: MEDIUM（静态推断，未实跑合并）

## Nit
- SKILL.md:387 references 表「…Rule 65 周期性回顾与前后对照 +Rule 73 执行期决策对齐与不变量纪律）」为拼接式追加（缺 "/" 分隔符），排版一致性小瑕。置信度 HIGH。
- 双承载 env 语义：check-complete 用 off/enforce/warn，posttooluse 用 off/其它=on（:354 `!= "off"`）。73.7 只声明 off/enforce 两档，posttooluse 把 warn 视作 on 可接受，非缺陷；仅记录口径差。

## verdict 行
**verdict: CHANGES_REQUESTED**（1 MAJOR=F1；BLOCKER=0）

返工路径: 仅需按 F1 给 [judge-gate] 段补 `plan_tier: standard|full` 门控（复用 goal-gate 判据）+ 可选 F2 增 DD-14 档位断言。文档面（critical-rules/SKILL/templates）无改动需求。

## 最终结论段
status: done
acceptance: 3/3 pass — [1:PASS 2:PASS 3:PASS]
files: none（纯审查）
evidence: diff 面=a538a3a..HEAD 13 文件/+202/-9；selftest-decision-drift 22/22 PASS、5 宽容化 selftest 全 PASS、bash -n OK；F1 check-complete.sh:1325-1342 [judge-gate] 缺 plan_tier 门控（对照 :1288/:1321-1323 goal-gate 同款判据）；F2 selftest-decision-drift.sh:65 DD-14 断言弱；F3 master 前进至 79cd10a 的合并锚风险
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v156-drift-shield/subagent-state/12-code-reviewer-S8.md (status: done)
findings_written: none（纯审查单元不写 findings）
blockers: none
confidence: HIGH
