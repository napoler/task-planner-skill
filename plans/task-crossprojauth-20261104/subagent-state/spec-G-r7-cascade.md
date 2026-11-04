# spec-G R7 双域条款级联执行 spec（general-purpose 组）

## 任务

按两份逐字稿完成 R7 双域条款落盘（L0-T 文本档,零新脚本文件、零新 config 键,仅既有 selftest 脚本内加断言行——该加行先例=task-crossprojauth R5/R6 自写脚本加项,非新建脚本）。

## 绝对路径（仓根=/mnt/data/dev/task-planner-skill）

材料包（先 Read 再动手）:
- `/mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/clause28-r7.md`（28.6/28.7 逐字稿+级联+验收）
- `/mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/clause-media-r7.md`（47.6 逐字稿+47.4 措辞随动+级联+验收）

## 执行序（每步完成即落检查点,最终全量自检）

1. **S1 discipline 域**:Read `skills/task-discipline/references/critical-rules-discipline.md` 定位 28.5 行（L57）,按 clause28 逐字稿在 28.5 行后追加 28.6/28.7 两行（逐字,格式=行首 `28.N `+加粗标题+冒号,单行不折行）;复查既有 28.1-28.5 锚零漂移（`grep -c '^28\.1 '` 至 `^28\.5 ` 各=1）。
2. **S2 media 域**:Read `skills/media-planner/references/critical-rules-media.md`,47.5 行后追加 47.6 逐字 1 行;47.4 行内「47.1-47.5 五子条文本锚」→「47.1-47.6 六子条文本锚」改字;复查 `grep -c '五子条文本锚'` 该文件=0、`^47\.5 `=1。
3. **S3 selftest 加项（各先 Read 脚本再动手,禁凭空新造引用）**:
   - Read `skills/task-planner/scripts/selftest-interaction.sh`,确认其 $CR 变量指向与 TI-NN 惯用法,按 clause28 §2 追加 TI-12（28.6 锚）/TI-13（28.7 锚）;Total 计数 +2（脚本内 Total 字面与断言条数同步,防 Total 漂移）。
   - Read `skills/task-planner/scripts/selftest-media-dispatch.sh`,按 clause-media §3 追加 47.6 锚断言（MD-NN 顺延编号）+ 47.4「六子条」字面断言;Total 同步。
4. **S4 级联加词**:Read `skills/task-planner/references/critical-rules.md` 定位 task-discipline 路由行（L194 附近,「100/101/102」枚举行）与 media-planner 路由行,按两份逐字稿 §级联 追加「/预算声明与执行动作自动批准（28.6）/长耗时任务停等止损（28.7）」与「/生成产物物理常识缺陷强制抽检（47.6）」,保持既有句式（「时」字收尾）。
5. **S5 可选面**:Read `skills/media-planner/SKILL.md`,若存在 47.x 摘要 bullet 段则补 47.6 一条;无则不动并在检查点登记「无摘要 bullet 面,零改动」。
6. **S6 全量自检**:逐条跑两份逐字稿 §验收 的 grep 口径,全过后进检查点;任何 FAIL 自行修复至全过,修复仍不动逐字稿条款正文语义（只修锚/编号/Total 机械面）。

## 硬约束

- 逐字稿条款正文逐字照抄,禁改写/精简/加戏（语义锚防漂移,TB-08 判例）;逐字稿内的插入位置说明是给你看的,不属于追加正文。
- 既有子条/规则行原文零改动（唯 47.4 一行内「五子条→六子条」改字是授权面）。
- 不新建任何 .sh/.json/config 文件;不改 hook;不改 agent 定义文件。
- 检查点:`/mnt/data/dev/task-planner-skill/plans/task-crossprojauth-20261104/subagent-state/07-executor-r7.md`——每完成 S1-S5 即追加一段（含实际 grep 证据输出）,S6 后追加全量自检表+最终结论。

## 返回消息要求

8 字段范式:① 完成步 S1-S6 清单+证据行数 ② 逐条 grep 结果 ③ 改动文件列表+各自行数增量 ④ 47.4 改字前后行 ⑤ S5 判定（动/未动+理由）⑥ 遗留/风险 ⑦ 检查点路径 ⑧ 结论（全过/FAIL 项）。
