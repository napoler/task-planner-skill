# Checkpoint: 14-executor（Phase 7 / S14 CHANGES 清单逐条修复 + 复验）

- 时间：2026-10-10
- 执行体：executor/sonnet-1（task-v162-change-absorption-safety Phase 7）
- 操作区（worktree）：/home/terry/task-planner-skill-worktrees/v162-change-absorption-safety/
- 输入：S12=APPROVED（2 Suggestion）subagent-state/12-code-reviewer.md；S13=CHANGES_REQUESTED（P1×2+P2×6）subagent-state/13-alignment.md
- 结论：**done** — CHANGES 清单 10 条全数修复（P1×2 + S12 Suggestion×2 + P2×6）；重跑吸收守护 AD-01..14 全 PASS（14 pass/0 fail/0 skip）；全量 selftest 72 脚本 ΣFAIL=0（0 非零退出）

## 修复对照表（CHANGES 清单 → 落地）

| # | 级别 | 对象（worktree 绝对路径:锚） | 原状态 | 修复动作（落地原文） | 证据 |
|---|------|------------------------------|--------|----------------------|------|
| 1 | P1 | skills/task-planner/references/critical-rules.md（Rule 71.7） | `SKILL 登记行+计数 1-71` | → `SKILL 登记行+计数 1-74（[2026-10-10 task-v162 合并演进] 全集锚 1-71→1-74，Rule 74 落地后 A 类机械替换）` | grep `计数 1-74（[2026-10-10 task-v162 合并演进]` 命中 |
| 2 | P1 | skills/task-planner/references/critical-rules.md（Rule 67.6） | `SKILL「Critical Rules 1-69」三处（…v154 期 1-69，锚演进并集终态）` + `「Critical Rules 1-69」计数三处级联` | 首处标签 1-69→**1-74** 并句末补 `；[2026-10-10 task-v162/v158 合并演进] 全集再演进 1-71→1-74，CP-07 锚族扩为 1-(69|71|74)`；次处 `「Critical Rules 1-74」计数三处级联` | grep `SKILL「Critical Rules 1-74」三处（…CP-07 锚族扩为 1-(69|71\|74)）` 命中；`「Critical Rules 1-74」计数三处级联` 命中 |
| 3 | S12-1 | skills/task-planner/scripts/selftest-absorption-discipline.sh（AD-12） | `_pin_lit() { grep -qF '1-71' "$1"; }`（仅命中迁移注释=判别力弱） | `_pin_lit() { grep -qF "$2" "$1"; }`，5 个精确 pin 改断言 **live 锚字面**：4 文件 `'Critical Rules 1-74'` + SA-07 `"grep -cF '1-74'"`；宽容 pin 6 处不变（context-pressure 族值 `1-(69|71)`→`1-(69|71|74)` 随 live 同步） | 判别力对照实验：将 tool-selection.sh 全量 `Critical Rules 1-74`→`1-71` 后，NEW `_pin_lit` FAIL(1) 检出回退；OLD `_pin_lit` PASS(0) 漏检（弱） |
| 4 | S12-2 | skills/task-planner/scripts/selftest-absorption-discipline.sh（AD-13） | 硬编码 `/mnt/data/dev/task-planner-skill/…` + SKIP 走 `ok()` 报绿 | 删机器绝对路径；候选=①env `TASK_PLANNER_ABSORB_PLAN` ②主仓根（`git rev-parse --path-format=absolute --git-common-dir` 推导，worktree 内解析到主仓）③repo 相对 `$SKILL_ROOT/../../plans/…`；新增 `sk()` 中性态（`skip` 计数，不计 pass/fail），末行输出 `pass, fail, skip` 三计 | 默认 worktree 跑：`AD-13 PASS 自举消费：变更标注表含 14 行 CA-n 条目（≥10）`；`Total: 14 pass, 0 fail, 0 skip` |
| 5 | P2-5 | skills/task-planner/SKILL.md:111（注释） | `（master 1-69 不变）` | → `（当时 master 1-69 不变）`（Rule 45 历史留痕加「当时」限定） | grep `当时 master 1-69 不变` 命中 |
| 6 | P2-6 | skills/task-planner/SKILL.md:9（frontmatter 全集行） | `全集 1-74（67-71 均经并行任务合流落地）` | → `全集 1-74（67-71/74 均经并行任务合流落地；72/73 为编号预占空号，由 scripts/rule-reserve.sh 账本管理，非断号）`（rule-reserve.sh 实存已验证） | grep 整串命中；AD-04（'1-74'≥3）/SA-07（'1-74'≥2）/CP-07（1-(69\|71\|74)=4≥2）/RF-07 全 PASS |
| 7 | P2-7 | templates/task_plan.md:147 表头 + critical-rules.md 74.2/74.3(a) + AD-06 | 列名 `增量或替代`（类型=删除无落点） | 列名统一 `吸收判定（增量·替代·删除）`：模板表头、74.2「变更标注表「吸收判定（增量·替代·删除）」列」、74.3(a) 列序、AD-06 断言（`grep -F '吸收判定'` + 增 `grep -qF '增量·替代·删除'`）同步 | grep `吸收判定（增量·替代·删除）` 于 3 处命中；AD-06 PASS；全仓 `增量或替代` 残留=NONE |
| 8 | P2-8 | critical-rules.md 74.3(d) + 8.1 尾 | `（Rule 8 A 类流程入口）`（歧义） | → `（Rule 8 判定为 B/C 类后）`；同步 8.1 尾 `指令并入既有计划（A/B 类）时`→`（B/C 类）时`（对齐 Rule 8 头「凡影响计划（B/C）」与 SKILL.md:264「B/C 类重规划」） | grep `（Rule 8 判定为 B/C 类后）`、`指令并入既有计划（B/C 类）时` 均命中；AD-05（8.1 含 'Rule 74'）PASS；TB-01/02/03 PASS |
| 9 | P2-9 | critical-rules.md 36.5 | `替代四条件+删除确认的同位实现` | → `替代四条件+删除确认的特化实现`（对齐 74.1「36.5 为技能保护区特化」） | grep `删除确认的特化实现` 命中；全仓 `同位实现` 残留=NONE |
| 10 | P2-10 | templates/task_plan.md（变更标注表区块） | 新段缺 Rule 45 What+Why 注释块 | 段首补 `<!-- WHAT/WHY/WHEN -->` 三层注释（与「必要知识储备」段注释风格一致） | grep `WHAT: Rule 74.3 变更标注表` 命中（:140） |

## 复验证据（机器可复现）

### 1) 吸收守护 AD-01..14 全 PASS
```
$ bash skills/task-planner/scripts/selftest-absorption-discipline.sh
AD-01..AD-14 全 PASS
Total: 14 pass, 0 fail, 0 skip
exit=0
```
- AD-06 标签更新为「…六列（编号/对象/类型/吸收判定/依据/执行动作）+四类型串+吸收判定三态串齐备」
- AD-12 标签更新为「…live 锚字面（精确 5：Critical Rules 1-74 / 1-74 计数）或宽容正则族（6）二者居一」
- AD-13 默认 worktree 即 PASS（git-common-dir 解析主仓计划，14 行 CA-n ≥10）

### 2) 全量 selftest ΣFAIL=0
```
$ for s in scripts/selftest-*.sh; do bash "$s"; done  → 汇总
=== TOTAL SCRIPTS: 72 ; NONZERO-EXIT: 0 ===
=== failing scripts: (空) ===
```
关键守护逐项：
- `selftest-registry.sh`：`Total: 5 PASS=5 FAIL=0 (registry rows=72, actual selftest=72)`（脚本↔registry 双向一致）
- `selftest-research-first.sh`：RF-06 PASS（1-6X≥3）、RF-07 PASS（1-74 全集锚）、Total 12 PASS=12
- `selftest-context-pressure.sh`：`CP-07 PASS 1-(69|71|74)=4≥2 ∧ CR1-(69|71|74)=2≥1 ∧ C48=2 ∧ C49=1 ∧ C50=1`、Total 9 PASS=9
- `selftest-workflow-orchestration.sh`：WF-10 PASS（族命中 5≥3，旧 1-39/1-45=0）、WF-11 PASS、Total 16 PASS=16
- `selftest-source-anchor-discipline.sh`：SA-07 PASS（'1-74' 计数 ≥2）、Total 12 PASS=12
- `selftest-task-boundary.sh`：TB-01..11 PASS、Total 11 PASS=11

### 3) 残留清零
- `grep -rn '增量或替代'`（技能范围）→ NONE
- `grep -rn '同位实现'` → NONE
- `grep -rn 'A 类流程入口'` → NONE
- Rule 74 条文段 `:[0-9]` 硬编码行号锚 → NONE（AD-03 前提保持）

## 越界自检
- `git status --short`：本次 S14 仅编辑 4 个授权文件——`skills/task-planner/SKILL.md`、`skills/task-planner/references/critical-rules.md`、`skills/task-planner/templates/task_plan.md`、`skills/task-planner/scripts/selftest-absorption-discipline.sh`（后者 untracked=本任务新建）。
- 其余 modified 行（context-pressure.sh / drift-check-subagent.sh / execution-honesty.sh / lane-advancement.sh / registry.tsv / requirement-coverage.sh / research-first.sh / root-resolution.sh / self-resolution.sh / source-anchor-discipline.sh / tool-selection.sh / subagent_dispatch.md）均为 S0..S13 前序 Phase 既有改动，S14 未触碰。
- 未触碰其他 worktree；未改 config.json（AD-10 断言 grep absorption=0 PASS）。

## 负结果（排除了哪些风险）
- 未发现回归：改动后全量 72 脚本 0 非零退出（含未改动的宽容锚脚本 WF-10/CD-11/skill-split）。
- 未发现锚计数跌破阈值：SKILL.md 编辑后 AD-04/SA-07/CP-07/RF-07 全部仍 PASS（'1-74' 计数、1-(69|71|74) 族均达标）。
- 未发现语法/可执行位问题：`bash -n selftest-absorption-discipline.sh` OK，AD-14（chmod+x + bash -n）PASS。
- 未发现 Rule 8 术语新不一致：8.1 尾与 74.3(d) 已统一为「B/C 类」，与 Rule 8 头 + SKILL.md:264 一致。

## 待 S13/S12 复验确认项（供 reviewer 复核）
1. S12 Suggestion#1：AD-12 判别力已由注释匹配改为 live 锚断言，并附回退模拟对照（NEW 检出 / OLD 漏检）。
2. S12 Suggestion#2：AD-13 已去机器绝对路径；采用 env + git-common-dir + repo 相对三候选（均 portable），SKIP 中性态 `sk()` 不计 pass/fail。
3. P2-7 列名变更已级联 AD-06 断言（防锚腐），并全仓清零旧串。
4. P2-8 附带同步 8.1 尾 A/B→B/C（属 Rule 74 语义门同族一致性修订，非语义回退）。

## 返回契约（Rule 22.4b）
- status: done
- acceptance: CHANGES 清单 10 条全修复（P1×2 字面级联 1-71→1-74 / 1-69→1-74；S12 Suggestion×2=AD-12 live 锚收紧+AD-13 去绝对路径与 SKIP 中性态；P2×6 全处理）；复验=selftest-absorption-discipline.sh AD-01..14 全 PASS（14/0/0）+ 全量 72 脚本 ΣFAIL=0（0 非零退出）+ 残留串清零（增量或替代/同位实现/A 类流程入口 均 NONE）
- checkpoint: 本文件
