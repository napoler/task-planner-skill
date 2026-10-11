# Knowledge Brief — task-v077-deferred-fixes（主进程依 01-explore-v077 实核锚代写，2026-09-17）

> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期产出（本次因 plan-writer 空响应由主进程按白名单②补写），执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：修复 v076 交付登记 4 项（smart-merge-back 部署源假 IDENTICAL 根因/两处 Rules 1-27 滞后/S-unit ID 纯数字契约缺失/统计类禁自报汇总缺失）+ CD selftest 扩 6 断言，全量回归 0 FAIL 后合并部署 push。
- 核心概念：SKILL_ROOT=脚本运行处推导（BASH_SOURCE）；MAIN_REPO=主仓根（L195-218 推导）；DEPLOY_SRC=本任务新引入的部署源变量（=$MAIN_REPO/skills/task-planner）；假 IDENTICAL=对账基准与被部署内容同源陈旧导致的假绿。

## §2 已验证事实（全部一手实核，锚点=01-explore-v077.md）
- 假 IDENTICAL 链条：L348 SKILL_ROOT=脚本运行处；L498 cp 源、L524 diff 基准均=SKILL_ROOT；自位=SKILL_ROOT 被守卫 L457 精确拒绝；他位从陈旧自位拷贝再对同一陈旧源 diff → 假绿；v076 当时 sm-rc=0 是管道 tail 吞掉 exit 6 的假象
- MAIN_REPO 推导可靠：L195-218 三级回退+L218 pwd 规范化；ALREADY_MERGED 分支（L305-308）也执行 --deploy（统一入口 L345）
- SKILL_ROOT 部署路径仅 L498/L524 两处（grep 全列）；退出码文档 L81（0）/L86（6）；语义行 L15/L41/L525/L535/L538
- selftest-smart-merge 418 行 SM-01..13：fixture mk_fixture L63-85；SLOTS 注入 L216/247/263/305/349/381；deploy 用例 SM-06 L198-220（⚠️L209 自测侧 SKILL_ROOT="$SCRIPT_DIR/.." 独立定义，L210 cp 预置 s1）、SM-08/09/10/12/13；run L114/report L121/样板 SM-07 L222-230/Total L413（含 SKIP）/L415/FRAMEWORK_BROKEN L405-408
- Rules 1-27 活跃命中仅 2 处：skills/task-planner/README.md:67、references/batch-quality-gate.md:130（根目录仅 README_zh.md 无命中）
- plan-writer.md 269 行：契约表 L106-116、S-unit 行 L111、knowledge_brief 样板 L116；check-plan-dispatch.sh:153 正则 `^\|[[:space:]]*S([0-9]+)[[:space:]]*\|`
- templates/task_plan.md S-unit 注释块 L182-187（①L184 NNmin/②L185 输入/③L186 拆分基准）、表头 L188
- templates/subagent_dispatch.md §7=L51-73、字段块 L53-60（8 字段无 notes）、acceptance 行 L54、「返回前必做」L75-79
- critical-rules.md L129=22.4b 整行（acceptance 括注为行内追加锚）
- selftest-conclusion-discipline.sh：变量区 L21-26、CD-17=L60-61、Total L63、头注释 L4-15 清单+L17 计数「17 断言」
- 基线：master@5ad18f6，全量 20 脚本 330 PASS/0 FAIL（v076 P4 awk 定数）

## §3 文件锚点（S-unit 输入引用索引）
| 文件 | 关键行 |
|---|---|
| scripts/smart-merge-back.sh | 15/35/41/81/86/195-218/305-308/345/348/370/457/493-500/505-530/524/525/535/538 |
| scripts/selftest-smart-merge.sh | 63-85/114-124/198-220/209/222-230/405-408/413/415 |
| skills/task-planner/README.md | 67 |
| references/batch-quality-gate.md | 130 |
| companion/agents/plan-writer.md | 106-116/111/116 |
| templates/task_plan.md | 182-188 |
| templates/subagent_dispatch.md | 51-73/53-60/54/75-79 |
| references/critical-rules.md | 129 |
| scripts/selftest-conclusion-discipline.sh | 21-26/60-61/63/4-15/17 |

## §4 易错点
1. SM-06 L209 的 SKILL_ROOT 是 selftest 侧独立定义（fixture 预置源），与脚本 L348 同名不同物——改部署源时两处语义都要对齐，但禁把脚本侧守卫逻辑复制进 selftest
2. fixture 的 MAIN_REPO 是合成仓，默认无 skills/task-planner——mk_fixture 必须新建该目录并打内容标记，否则换源后 cp 失败全部 deploy 用例崩
3. 换源后 DEPLOY_SRC 缺失分支必须 fail-closed（显式 DRIFT exit 6），禁静默回退 SKILL_ROOT；不加 env 覆盖键（防部署位旧值污染——与假 IDENTICAL 同类根因）
4. 自位（SKILL_ROOT==slot）REJECTED 是 bash 执行中自覆盖防护，保留行为只改提示语
5. CD 新断言锚用行内容 grep 非裸行号；头注释 L4-15 清单与 L17 计数（17→23）必须同批改，否则邻接 selftest 锚检查失配
6. 统计类结论只贴逐项原文行；总数=主进程 awk 逐 Total 机械求和（子代理自报已 5 次算术错）
7. P5 部署必须从主仓副本执行 smart-merge-back；.zcode 位若 REJECTED（自保护）按 FMEA 120 兜底手动 rm+cp 主仓副本再 diff

## §5 S-unit 材料包索引
- S2/S9（code-runner 全量）：cd worktree/skills/task-planner/scripts；`for f in selftest-*.sh; do timeout 120 bash "$f" >/tmp/v077-$f.log 2>&1; echo "rc=$? $f"; grep -E '^Total:' /tmp/v077-$f.log; done`；逐 Total 行落盘检查点，禁自报汇总
- S3：§2 假 IDENTICAL 链条+A 表锚点（01-explore-v077 §A/§I）
- S4：§2 selftest 结构+B 表锚点+易错点 1/2（01-explore-v077 §B）
- S5/S6/S7：§3 文件锚点表对应行原文先 Read 再 Edit
- S8：§2 CD 结构+易错点 5（01-explore-v077 §H）
