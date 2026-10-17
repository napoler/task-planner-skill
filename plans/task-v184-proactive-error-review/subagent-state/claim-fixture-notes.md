# S6 general-purpose 检查点 — CLAIM_MATCH 内容核对层（task-v184）

## M1 契约（2026-10-17）

**任务**：给 `skills/task-planner/scripts/check-evidence-anchor.sh` 增加 CLAIM_MATCH 内容核对层——R3
「对内容的错误及时审查出来」的机器层第一载体。证据格声明的结果串（`Total: 90 PASS=90`、`exit=0`、
`PASS=11` 等）与被引用证据文件实际内容交叉核对；文件存在但内容与声明不符 = 内容级错误检出。

**既有脚本结构**（前置 Read 结论）：
- 函数清单：`arch_rewrite / resolve_anchor / scope_text / in_scope / extract_tokens / judge_token / run_source`
- 主流程：`run_source coverage/goal` → SKIP 行 → `FAILS>0 ? exit 1 : exit 0`；rc 三态 0/1/2
- 调用契约（check-complete.sh:750 `run_evidence_anchor`）：rc=0 PASS 走 stdout；rc=1 明细转 stderr，
  caller 按 `evidence_anchor_enforce` 档位裁决（enforce=exit 1 / warn=仅告警）；rc=2 fail-open
- 路径层档位由 caller 裁决（脚本头注「纯判定器」）；**CLAIM_MATCH 档位按任务要求脚本自持**：
  env `TASK_PLANNER_CLAIM_MATCH_ENFORCE` > config `claim_match_enforce` > **warn（默认）**
- selftest 夹具证据串（`/etc/hostname`、`artifact.md:2`、`无 ` 等）均不含四形态声明串 → 预期全 SKIP

**设计决策**（实现前定）：
1. 声明串四形态正则族集中 `CLAIM_PATTERNS` 数组（Total:/PASS=/FAIL=/exit=/rc=），注释注明可扩
2. 证据文件定位：复用 `extract_tokens`（新增 `mode=="claim"` 分支，任意行直接抽 token）+ `resolve_anchor`
   解析链；取**首个可解析可读**文件；一格多文件只核对首个（诚实边界披露）
3. 核对语义：逐 (键,值) 对 grep 证据文件；数值右边界防子串误判（`PASS=9` 不命中 `PASS=90`）；
   冒号形态允许多空白（`Total:  90`）
4. SKIP 面（不算误报）：无声明串 / 路径 token 抽不出 / 证据文件不可读
5. 接线：run_source 的 `__EVAL__` 分支累积证据原文到 per-run tsv（tab 归一防断列）；主流程在既有
   判定完成后、rc 返回前调 `claim_match_check`；warn=⚠ 行不影响 rc，enforce=✗ 行 + FAILS++
6. 既有路径层判定语义一字不动；jq 仅作可选 config 读取器（缺失 → warn，核心判定纯 bash）

**验收**：① 不符夹具 warn/enforce 双档 ② 相符夹具无 mismatch 行 ③ selftest 回归（不改 selftest）
④ enforce 档 60 存量归档计划基线（flag 数+样例≤3）⑤ bash -n + run-selftests --only evidence-anchor
⑥ 禁 git 写；夹具自清理。

## M2 实现（2026-10-17）

改动文件：`skills/task-planner/scripts/check-evidence-anchor.sh`（145 insertions / 5 deletions，530 行总量；
`git status` 仅此一文件 `M`，无 git 写）。

**改动点清单**：
1. 头注：首行加 `+ CLAIM_MATCH 内容核对`；新增 `[2026-10-17 task-v184-S6]` 说明块；What 加 ④ CLAIM_MATCH
   层描述；Why 加 2 条（独立档位默认 warn 理由 / SKIP fail-open 理由）；用法/输出/退出码/依赖/档位 各段
   更新（加 `[claim-mismatch] ⚠|✗` 输出行 + 独立档位说明）；诚实边界加 2 条（四形态外声明不判 / 多文件
   只核对首个）。
2. 常量：`CLAIM_PATTERNS` 数组（5 行，Total:/PASS=/FAIL=/exit=/rc= 四形态起步，注释注明可扩）。
3. `CLAIM_INPUT` per-run mktemp + `trap EXIT` 清理；`CLAIM_FAILS=0` 计数器。
4. `extract_tokens` awk 新增 `mode == "claim"` 分支（任意行直接 emit_tokens，复用既有 PATH_TOKEN 规则）。
5. 新函数三件：`resolve_claim_match_tier()`（env > config jq 可选 > warn）/ `claim_pairs_from_ev()`
   （grep -oE 抽声明对，tab 归一）/ `claim_match_check()`（声明串 × 证据文件内容交叉核对，四档处置）。
6. run_source `__EVAL__` 分支：累积证据原文到 CLAIM_INPUT（tab 归一防 tsv 断列）。
7. 主流程：既有判定完成、rc 返回前调 `claim_match_check`；enforce 档 FAIL 后追加 `[claim-mismatch] ✗ N 条`
   汇总行。

**关键实现细节（防误报）**：核对 grep 用数值右边界 `([^0-9]|$)` 防子串误判（`PASS=9` 不命中 `PASS=90`）；
冒号形态（Total）允许多空白 `[[:space:]]*`。case 分组：`Total` 走冒号分支，`PASS/FAIL/exit/rc` 走等号
分支——**首版误把 PASS/FAIL 并入 Total 冒号分支导致相符夹具误报，已修**（M2 阶段自测发现）。

## M3 夹具验收（/tmp 夹具，跑毕即删）

| 用例 | 档位 | 期望 | 实测 | 结论 |
|------|------|------|------|------|
| T1a 不符（Total:90 PASS=90 vs 文件 Total:80 PASS=80） | 默认 warn | rc=0 + `[claim-mismatch] ⚠` | rc=0，`⚠ ... 缺失: Total=90 PASS=90` | ✓ |
| T1b 同夹具 | enforce | rc=1 + `[claim-mismatch] ✗` | rc=1，`✗ ... 缺失: Total=90 PASS=90` | ✓ |
| T2 相符（Total:90 PASS=90 FAIL=0 exit=0 全在文件） | warn+enforce | 无 mismatch 行, rc=0 | 两档均无 mismatch 行，rc=0 | ✓ |
| T3 SKIP（声明串存在但同格无路径 token） | warn+enforce | 无 mismatch 行, rc=0 | 两档 SKIP，rc=0 | ✓ |
| T4 单形态（PASS=11 不符, exit=0/rc=0 相符） | warn | 仅 PASS=11 缺失 | `⚠ ... 缺失: PASS=11`（exit/rc 未列） | ✓ |
| T5 off 档（不符夹具） | off | 整层跳过 | 无 claim-mismatch 输出，rc=0 | ✓ |

关键命令（夹具已删，路径示例）：
```
bash .../check-evidence-anchor.sh /tmp/claim-fx-mismatch            # warn, rc=0, ⚠ 行
TASK_PLANNER_CLAIM_MATCH_ENFORCE=enforce bash ... /tmp/claim-fx-mismatch   # rc=1, ✗ 行
```

## M4 存量基线（enforce 档，前 60 归档计划）

**统计**：扫描 60 计划 → 路径层 FAIL=0（全过）；**claim-mismatch ✗ 旗标 2 计划 / 共 5 条**；判定面
分母（证据行含四形态声明串的计划）≈ 40/60。旗标率：2/60=3.3%（全部计划）/ 2/40=5%（判定面）。

**flag 明细（供档位裁决）**：
| 计划 | 条数 | 证据行 | 被引文件 | 缺失声明 | 定性 |
|------|------|--------|----------|----------|------|
| task-v157-error-fix-prompt-forge | 2 | progress.md:148 `[goal:G4] ... FAIL=0 主进程独立复算` | subagent-state/04-executor/fix-prompt-sample.md | FAIL=0 | **真阳性**：引的是「修正任务书」，内容无 FAIL= 行，声明串确实不在被引文件 |
| task-v176 | 3 | progress.md:13/15 `run-selftests.sh ... Total:80 PASS=77 FAIL=3 / Total:81 PASS=81 FAIL=0` | skills/task-planner/scripts/run-selftests.sh | Total=80 PASS=77 FAIL=3 / Total=81 PASS=81 FAIL=0 | **边界阳性**：被引文件是「产出结果的脚本」而非输出日志（日志在 /tmp，已无），结果串合法地不在脚本里 |

**结论（供 S7/档位裁决）**：低误报率（5 条 / 40 判定面 ≈ 12.5% 触发，其中 1 真阳性 + 1 边界）。v176 类
「引用产出脚本而非输出日志」是主要潜在误报模式。默认 warn 档恰当；升 enforce 前需评估此类边界样例。

## 回归（收尾）

- `bash -n` rc=0
- `selftest-evidence-anchor.sh` → Total: PASS=20 FAIL=0, rc=0（零回归；夹具证据串均无四形态 → CLAIM_MATCH 全 SKIP）
- `run-selftests.sh --only evidence-anchor` → 1 PASS=1 FAIL=0, rc=0
- 既有 selftest 无需改动（断言面未受新增输出行影响——自测夹具无声明串，CLAIM_MATCH 层零输出）
- 全程 `git status` 仅 `M skills/task-planner/scripts/check-evidence-anchor.sh`，无 git 写；/tmp 夹具与
  per-run 临时文件（trap）全部清理，零残留
