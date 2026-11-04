# 07-executor-r7.md — G 组 R7 双域条款落盘检查点（task-crossprojauth）

## S1 discipline 域（28.6/28.7 追加）
完成：`skills/task-discipline/references/critical-rules-discipline.md` 28.5 行后追加 28.6/28.7 两行（逐字照抄 clause28-r7.md 逐字稿，行首 `28.N ` 单行不折行）。
锚 grep 证据：
```
^28\.1  = 1
^28\.5  = 1
^28\.6  = 1
^28\.7  = 1
```

## S2 media 域（47.6 追加 + 47.4 改字）
完成：`skills/media-planner/references/critical-rules-media.md` 47.5 行后追加 47.6 逐字 1 行；47.4 行内「47.1-47.5 五子条文本锚」→「47.1-47.6 六子条文本锚」。
grep 证据：
```
--五子条文本锚: 0
--六子条: 1
^47\.4  = 1
^47\.5  = 1
^47\.6  = 1
```
47.4 改字前后：
- 前：`机器面=`scripts/selftest-media-dispatch.sh` 静态断言（47.1-47.5 五子条文本锚 + SKILL.md 路由表媒体行锚 + ...`
- 后：`机器面=`scripts/selftest-media-dispatch.sh` 静态断言（47.1-47.6 六子条文本锚 + SKILL.md 路由表媒体行锚 + ...`

## S3 selftest 加项
1. `skills/task-planner/scripts/selftest-interaction.sh`：
   - 先 Read 确认：$CRIT_D 变量指向 `../../task-discipline/references/critical-rules-discipline.md`（28.x 条款本体在卫星纪律域，R5/R6 先例同口径）→ TI-12/TI-13 直接断言 CRIT_D 行首 `^28\.6 ` / `^28\.7 `（非主文件路由行口径，因 $CR 未在本脚本定义 28.x 锚）。
   - 追加 TI-12（28.6 锚）/TI-13（28.7 锚），沿用既有 cnt/PASS/FAIL 惯用法；头注释「10 用例」→「13 用例」；Total 为 `PASS+FAIL` 动态计数，无独立 Total 字面需改。
2. `skills/task-planner/scripts/selftest-media-dispatch.sh`：
   - 先 Read 确认：$CRIT_M 指向 `../media-planner/references/critical-rules-media.md`；惯用法=MD-NN + ok()/bad() + Total 动态 `PASS+FAIL`。
   - 追加 MD-10（`^47\.6 ` 锚 ≥1）/MD-11（「六子条」≥1 且「五子条文本锚」=0 双断言）；头注释「MD-01..MD-09」→「MD-01..MD-11」。

## S4 级联加词
完成：`skills/task-planner/references/critical-rules.md` 两处路由行调用条件加词（均在既有调用条件串内追加，保持「时」字收尾句式，零新增行）：
- L194 task-discipline 行：「git 使用加强」后追加 `/预算声明与执行动作自动批准（28.6）/长耗时任务停等止损（28.7）`
- L195 media-planner 行：「媒体轴拆分与执行体路由」后追加 `/生成产物物理常识缺陷强制抽检（47.6）」`（逐字稿 §级联 2 口径）——实际改后行尾为「…媒体轴拆分与执行体路由/生成产物物理常识缺陷强制抽检（47.6）时。」
grep 证据（S6 全量）：三处字面各命中 1。

## S5 可选面判定
`skills/media-planner/SKILL.md` grep `47\.` 结果仅 L41（47.3 联动）/L43（47.5 本体）两行，均归属 task-discipline 列路由表行，**无「47.x 摘要 bullet」段** → 判定：无摘要 bullet 面，零改动（不新增表行，clause-media §级联 1 明文「无则不动」）。

## S6 全量自检表

| # | 验收口径（两份逐字稿 §验收） | 实测 | 判定 |
|---|---|---|---|
| 1 | `grep -c '^28\.6 ' critical-rules-discipline.md`=1 | 1 | PASS |
| 2 | `grep -c '^28\.7 '`=1 | 1 | PASS |
| 3 | 原文锚抽查 `^28\.5 `=1、`^28\.1 `=1 | 1 / 1 | PASS |
| 4 | selftest-interaction.sh 全绿（含新增 2 断言） | Total: 13 PASS=13 FAIL=0, exit=0（TI-12/TI-13 PASS） | PASS |
| 5 | critical-rules.md 路由行含「28.6」「28.7」字面各 ≥1 | 各 1 | PASS |
| 6 | `grep -c '^47\.6 ' critical-rules-media.md`=1 | 1 | PASS |
| 7 | `^47\.5 `=1、`^47\.4 `=1 | 1 / 1 | PASS |
| 8 | `grep -c '六子条'`≥1 且 `grep -c '五子条文本锚'`=0 | 1 / 0 | PASS |
| 9 | selftest-media-dispatch.sh 全绿 | Total: 11 PASS=11 FAIL=0, exit=0（MD-10/MD-11 PASS） | PASS |
| 10 | critical-rules.md media-planner 路由行含「47.6」字面 ≥1 | 1（`生成产物物理常识缺陷强制抽检（47.6）`） | PASS |

git diff 复核：
- critical-rules-discipline.md = 纯追加 2 行（+28.6/+28.7，零删改既有行）
- critical-rules-media.md = 3 行（47.4 改字 1 行 + 47.6 追加 1 行）
- critical-rules.md = 2 行内加词（L194/L195 各 1 行改动）
- selftest-interaction.sh = +22/-1（头注释 2 行 + 用例数 1 行 + TI-12/TI-13 断言块）
- selftest-media-dispatch.sh = +17/-1（头注释 1 行 + MD-10/MD-11 断言块）

## 最终结论
**全过**：S1-S6 全完成，10/10 验收项 PASS，两个 selftest 全绿（13/13、11/11），零新脚本文件、零新 config 键、零 hook 改动、agent 定义文件零改动，条款正文逐字照抄（git diff 证实 28.6/28.7/47.6 行与逐字稿一致，仅 47.4 授权改字一处）。无 FAIL 项，无机械面修复（MD-08 config 键数 53 为既有合法值，与 R7 无关）。遗留/风险：无（47.2 SOP 文件侧联动属 §六 保护区，条款正文已明文「SOP 文件改动另需用户授权」，本轮未触碰）。

