# 01 Explore-v077 考古检查点（2026-09-17，主进程代写自子代理协调消息，锚点已 Grep/Read 复验）

> 用途：plan-writer/后续 S-unit 材料包锚点源。基于 master@5ad18f6。

## 修复点速览
① smart-merge-back.sh 部署源/对账基准 SKILL_ROOT→主仓 skills/task-planner（假 IDENTICAL 根因）
② skills/task-planner/README.md:67 与 references/batch-quality-gate.md:130 `Rules 1-27`→`Rules 1-35`
③ companion/agents/plan-writer.md + templates/task_plan.md 补 S-unit ID=纯数字契约
④ templates/subagent_dispatch.md §7 + critical-rules.md 22.4b 补「统计类只贴逐项原文行禁自报汇总」

## A. smart-merge-back.sh（539 行）
| 锚点 | 位置 |
|---|---|
| MAIN_REPO 推导 | L195 空初始化→L196-213 三级回退→L218 `MAIN_REPO="$(cd "$MAIN_REPO" && pwd)"` |
| --deploy 语义文档 | L15（改名换位+diff -rq 对账）；L41（逐位 REJECTED\|IDENTICAL\|DRIFT，任一→exit 6） |
| ALREADY_MERGED 也部署 | L35 注释；执行 L305-308，统一入口 L345 |
| SKILL_ROOT 全列 | L348 推导（脚本运行处）；L370 GUARDS；**L498 `cp -rL "$SKILL_ROOT"` 与 L524 `diff -rq "$SKILL_ROOT" "$slotdir"` = 部署源/对账基准全部出现点** |
| 退出码文档 | L81（0=全位 IDENTICAL）；L86（6=DEPLOY_DRIFT） |
| 自位拒绝消息 | validate_slot L457 `(= 受保护路径 ...)` |
| 末尾语义行 | L525 IDENTICAL echo / L535 OK 行 / L538 尾注释 |

## B. selftest-smart-merge.sh（418 行，SM-01..13）
- fixture：L63-85 `mk_fixture`（mktemp bare origin+clone+worktree add）；TASK_PLANNER_DEPLOY_SLOTS 注入行 L216/247/263/305/349/381
- --deploy 用例：SM-06 L198-220（s1 IDENTICAL+s2 ENOTDIR）、SM-08 L232-256、SM-09 L258-266、SM-10 L268-323、SM-12 L339-356（HOME 注入）、SM-13 L358-389（主仓建在部署根）
- 框架：run() L114-119、report() L121-124、样板 SM-07 L222-230、Total L413（含 SKIP）/L415、FRAMEWORK_BROKEN L405-408
- ⚠️ SM-06 L209 `SKILL_ROOT="$SCRIPT_DIR/.."`（自测侧独立定义，fixture 预置源 L210 `cp -rL "$SKILL_ROOT" "$T6/s1"`）与脚本侧同名变量无关——改部署源时 SM-06 预置语义要同步

## C. Rules 1-27 滞后（全仓活跃命中仅 2 处）
- skills/task-planner/README.md:67 `# Rules 1-27（1-12 核心执行约束 + 13-27 P0/P1 扩展门控）`（L66 references/ 行、L68 todo-sync 行之间）
- references/batch-quality-gate.md:130 `Rule 18 八条款（核心载体，隶属 Rules 1-27）`（表格行）
- 根目录只有 README_zh.md（无该字样）；目标值以实施时实数为准（现为 Rule 35）

## D. plan-writer.md（269 行）
- 产出契约表 L106-116；knowledge_brief 契约行样板 L116；S-unit 表列定义行 L111；禁止行为区 L191-193
- 插入点建议：L111 行内追加或 L116 后新表行（+L191-193 加 ❌ 条可选）
- 机器佐证：check-plan-dispatch.sh:153 正则 `^\|[[:space:]]*S([0-9]+)[[:space:]]*\|`

## E. templates/task_plan.md
- S-unit 注释块 L182-187：L184=①NNmin；L185=②输入 token ≤2；L186=③拆分基准=预估时间；表头 L188
- 插入点：④「ID 列一律纯数字（S1/S2…禁 S2a 式字母后缀——check-plan-dispatch 数据行正则不认）」

## F. templates/subagent_dispatch.md
- §7 8 字段返回 L51-73；字段代码块 L53-60（8 字段=status/acceptance/files/evidence/checkpoint/findings_written/blockers/confidence，无 notes）；acceptance 说明行 L54；「返回前必做」L75-79
- 插入点：L54 行后加子句或 L75-79 段加一条

## G. critical-rules.md
- L129 = 22.4b 整行；行内追加锚：`acceptance:`(n/total pass + 逐项 PASS/FAIL 及 ≤20 字原因) 之后

## H. selftest-conclusion-discipline.sh
- 变量区 L21-26（L22 SKILL/L23 RULES/L24 DISPATCH/L25 TMPL/L26 NOTEPAD_TPL）；CD-17=L60-61；插入点 L61 后；Total L63
- 头注释 L4-15 断言清单 + L17「17 断言」计数——新增断言须同步两处

## I. IDENTICAL 语义文档点（改源后需同步）
- 脚本 L41/L81/L525/L535/L538；selftest SM-06 L198 头注释/L219-220 断言；references/SKILL/docs/README grep=0（无外部文档）

## 设计裁决（主进程预判，供计划采用）
1. 部署源 `DEPLOY_SRC="$MAIN_REPO/skills/task-planner"`，cp(L498)/diff(L524) 换用；源不存在→显式 DRIFT fail-closed（禁静默回退 SKILL_ROOT）
2. 不加 env 覆盖键（防绕过）；自测靠 fixture 在 MAIN_REPO 内造 skills/task-planner
3. 自位（SKILL_ROOT==slot）REJECTED 保留（bash 自覆盖风险），消息加指引「请改用主仓副本运行或手动 rm+cp」
4. 新增回归用例：把脚本副本放进「陈旧部署位」运行，断言槽位终态内容==主仓内容（钉死假 IDENTICAL）
5. CD selftest 扩展断言锁上述四处契约（README/batch-gate 1-35、plan-writer 纯数字、task_plan 模板④、dispatch 禁自报、smart-merge DEPLOY_SRC 存在）
