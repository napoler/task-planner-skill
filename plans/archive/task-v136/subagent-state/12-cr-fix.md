# 检查点 12-cr-fix.md — CR Gate 建议修复（task-v136 Phase 6 收尾修复单元）

- 时间: 2026-10-05
- worktree: /home/terry/task-planner-skill-worktrees/task-v136/skills/task-planner/
- 可写文件（仅 2）: SKILL.md / scripts/selftest-root-resolution.sh —— 实际改动与该清单完全一致（git diff --numstat 核对）

## 一、修改对照表（改前行原文 / 改后行原文）

### ① SKILL.md :9（行内替换，净行数不变，wc -l 仍 480）
| 位置 | 改前 | 改后 |
|------|------|------|
| :9 frontmatter references 行 | `- references/critical-rules.md: Critical Rules 全集 1-53（1-12 核心执行约束 + …` | `- references/critical-rules.md: Critical Rules 全集 1-54（1-12 核心执行约束 + …`（仅 `1-53`→`1-54`，其余逐字不变） |

### ② scripts/selftest-root-resolution.sh（净 +3 行）
| 位置 | 改前 | 改后 | 类型 |
|------|------|------|------|
| :5 docblock What | `…+ 全集声明 1-53 演进（负断言 1-51 残留=0）；` | `…+ 全集声明 1-54 演进（负断言 1-51 残留=0）；` | 现状描述→1-54 |
| :11（新增行，紧邻既有 v131/v132 注记风格） | （无） | `#    [2026-10-05 task-v136] 全集声明 1-53→1-54（Rule 54 落地），主断言宽容化 1-5[3-9]` | CR 建议 3 注记 |
| :13 docblock Why | `RR-09 负断言锁全集 1-51→1-53 演进不回退（锚级联第 3 次教训 §4）；` | `RR-09 负断言锁全集 1-51→1-5[3-9]（现状 1-54）演进不回退（锚级联第 3 次教训 §4）；` | 断言描述→宽容式 |
| RR-09 注释块（原 :98-:101） | `# RR-09 全集声明演进锚 \`grep -cF 'Critical Rules 全集 1-53'\` =1（负断言：'1-51' 残留 =0）` + 口径 3 行 | 标题改 `grep -cE 'Critical Rules 全集 1-5[3-9]'`；口径补 `→ 1-54（task-v136 新增 54 段）`；新增 2 行 `[2026-10-05 task-v136 CR P1]` 注记（宽容化依据对齐 R-09/SR-08/RR-16 先例 + 现状描述改 1-54） | CR 建议 1 宽容化 |
| RR-09 主断言（原 :102） | `n="$(grep -cF 'Critical Rules 全集 1-53' "$SKILLMD" \|\| true)"` | `n="$(grep -cE 'Critical Rules 全集 1-5[3-9]' "$SKILLMD" \|\| true)"` | 断言宽容化（-E 正则内 `[3-9]` 为字符类、无未转义元字符，转义正确性已核） |
| RR-09 ok/bad 诊断串（原 :105/:107） | `ok 09 "SKILL.md 全集声明「Critical Rules 全集 1-53」=1 且旧「1-51」残留=0"` / `bad 09 "SKILL.md 全集 1-53 命中=$n（应 =1）或旧 1-51 残留=$m（应 =0，级联漏改）"` | `ok 09 "SKILL.md 全集声明「Critical Rules 全集 1-5[3-9]」（现状 1-54）=1 且旧「1-51」残留=0"` / `bad 09 "SKILL.md 全集 1-5[3-9] 命中=$n（应 =1）或旧 1-51 残留=$m（应 =0，级联漏改）"` | 诊断串随动 |
| RR-17 ok 诊断串（原 :176，现 :179） | `ok 17 "critical-rules.md 区块锚「^### 53 」=1（索引行 40-53 全集的条款侧落点在位）"` | `ok 17 "…（索引行 40-54 全集的条款侧落点在位）"` | CR 建议 2 |

- 未动（历史叙述保留）: :162 注释「Rule 40/41/…/51」漏 50/52/53 判例叙述（锚级联第 3 次教训原文，属历史判例非现状描述）；:53/:64 等 53.x 子条锚字面（条款侧锚非全集面）。
- 未动 registry.tsv 行 52 域列 `1-53` 字样: 属 CR P2-8「存量行号锚迁语义锚 = deferred 登记（非本任务引入，后续清理任务承担）」，且 registry.tsv 不在本单元 2 文件白名单内。

## 二、复跑汇总（全部第一手命令输出）

### 单脚本
| 脚本 | 结果 |
|------|------|
| selftest-root-resolution.sh | `Total: 17 PASS=17 FAIL=0`（RR-09 PASS 串原文: `RR-09 PASS SKILL.md 全集声明「Critical Rules 全集 1-5[3-9]」（现状 1-54）=1 且旧「1-51」残留=0`；RR-17 PASS 串原文: `RR-17 PASS critical-rules.md 区块锚「^### 53 」=1（索引行 40-54 全集的条款侧落点在位）`） |
| selftest-execution-honesty.sh | `Total: 14 PASS=14 FAIL=0`（EH-09 PASS 原文: `EH-09 PASS SKILL.md Rule 54=3≥1 且 C38 行=1 且索引括注「Rule 40-54」=1`） |
| selftest-skill-split.sh | `Total: 41  PASS=41  FAIL=0`（T-主 行数 ≤480 钉通过，SKILL.md wc -l = 480 实证） |

### 全量 52 selftest 脚本
- 脚本数=52，失败脚本数=0，总 PASS=798，总 FAIL=0 —— 与 02-baseline / CR 段基线 798/0 一致
- 非标准汇总行脚本: selftest-final-gate-hash.sh（输出 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====`，已按非标准格式单独解析计入，未漏）
- 逐脚本 52 行 p/f 明细已输出（每行 `rc=0 f=0`）

## 三、验收 5 条逐项
1. SKILL.md:9 含 `全集 1-54` 且 wc -l 仍 480 → 通过（`grep -n` 实证 + `wc -l` = 480 + skill-split T-主 PASS）
2. RR-09 断言宽容化后脚本 PASS → 通过（RR-09 PASS，Total 17/0）
3. :176（现 :179）RR-17 ok 串为 40-54 → 通过（PASS 串原文见上）
4. 全量 52 脚本 failed=0 passed=798 → 通过
5. git diff 仅 2 文件 → 通过（`git diff --numstat` 原文: `1\t1\tskills/task-planner/SKILL.md` + `12\t9\tskills/task-planner/scripts/selftest-root-resolution.sh`，`git status --short` 仅 M×2）

## 四、负结果声明
- 检查了 SKILL.md 全文 `1-53|40-53` 残留 → 零命中（R4 依据链闭合: 索引面 :9 与 :268 括注 40-54 自洽）
- 检查了 scripts/、templates/ 其他文件 `1-53` 残留 → 仅 selftest-requirement-coverage.sh 注释内历史叙述（v131 演进重锚注记，非断言面，不在本单元白名单，零改动）
- 排除风险: EH-09 断言面（Rule 54/C38/40-54）与本单元 :9 改动正交，实证仍 PASS；registry T02 双向核对未因本单元漂移（T 系列 5/5 PASS）
