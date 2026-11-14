# Drift Check — Phase 2（条款设计与定稿）
- 时间：2026-11-15
- 检查对象：Phase 2（Rule 107 六子条三环闭环条款起草+5 载体级联设计+变更标注表 CA-1~CA-6 终稿，经用户 #3 yes 批准）
- 检查者：general-purpose（drift-checker 载体 redispatch）
- 读序：task_plan.md → findings.md → progress.md → user-session-log.md

## 总判定：⚠️DRIFT（VC-2 判据关键词与 dispatch 条款终稿文本存在不匹配风险；其余要点 ALIGNED）

## 逐要点判定

### 1) R 锚定（服务 R1+R2；无擅自缩水/扩展） — ✅ALIGNED
- **R1（知识设定同步根治）**：Rule 107 在 findings.md §Technical Decisions 载体1（:43-56）给出完整三环闭环：107.0 台账登记（计划期介质，:46）、107.1 单元完成沉淀（产出期，:48）、107.2 动笔前强制回读（消费期，:50）、107.3 验收一致性核对（验收期五项，:52）、107.4 主进程验收与接续（编排期，:54）、107.5 豁免与边界（:56）。覆盖派发/执行/沉淀/验收/接续链路，无缩水。
- **R2（写新一集前阅读之前剧集内容）**：107.2（findings.md:50）明确“动笔前强制回读（消费期，P0——用户点名手段）”“执行体首动作=Read 台账+前序单元产出，回读未完成禁动笔”，并禁止摘要替代回读；22.4d（:60）+模板载体4（:68 “执行体首动作=完整 Read 前序产出+台账，未回读禁动笔”）承接强制回读要求。未缩水。
- **范围边界**：条款与级联均为技能规范文本/模板/索引纪元面（findings.md:41,58,62,66,70；task_plan.md:192-198,351-353,384-385 明确“禁新增守卫脚本”与文本优先）。未见超出技能规范文本范围的实现扩展。
- 证据锚：task_plan.md:20-22(R1/R2), :66(Goal), :104-105(VC-1/2语义)；findings.md:43,46,48,50,52,54,56,60,64,68。

### 2) 用户 #3 批准面（条款终稿即呈报并批准版本，无批准后偷改） — ✅ALIGNED
- user-session-log.md:53-57 记录 #3 来源“条款审阅”、原文 `> yes`，理解镜像为“用户批准 Rule 107 条款文本终稿（六子条三环闭环+5 载体级联+22.4d 派发硬条款），授权启动 Phase 3 worktree 实施。”
- findings.md:39 明确“Rule 107 条款终稿全文（Phase 2 定稿 2026-11-15——插入锚…以下为 Phase 3 实施蓝本）”，并包含：六子条 107.0-107.5（:46,48,50,52,54,56）、22.4d 派发条款（:58-60）、47.7 媒体指针（:62-64）、模板序列行（:66-68）、索引纪元载体5（:70）——与批准要点“六子条三环闭环+5 载体级联+22.4d 派发硬条款/模板行/索引纪元”一致。
- 批准后动作仅见 progress.md:38 “条款呈报用户→批准…变更标注表补 CA-6（subagent_dispatch.md 序列行）+scope_files 同步”——CA-6 为将已批准的模板载体4登记入变更表/范围同步，属簿记对齐，未见条款语义偷改。
- 证据锚：user-session-log.md:53-57；findings.md:39,43,46,48,50,52,54,56,58,60,62,64,66,68,70；progress.md:37-39；task_plan.md:198(CA-6)。

### 3) 变更标注表 CA-1~CA-6 与条款终稿载体清单一致性 — ✅ALIGNED
- findings.md 载体清单：①discipline Rule 107全文（:41-56）②dispatch 22.4d（:58-60）③media 47.7（:62-64）④subagent_dispatch.md 序列行（:66-68）⑤索引/纪元 SKILL.md+critical-rules.md+selftest-enumerate-first.sh（:70）。
- task_plan.md 变更标注表映射：CA-1→discipline Rule 107全文(:192)；CA-2→dispatch 序列任务契约(:193)；CA-2b→media Rule 47家族指针(:194)；CA-3→critical-rules.md+SKILL.md 索引/路由(:195)；CA-4→纪元锚 selftest-enumerate-first.sh+task-planner/SKILL.md(:196)；CA-5→FAIL命中时既有断言锁步修复(条件项,:197)；CA-6→subagent_dispatch.md 序列行(:198)。传播面全覆盖，无漏登记。
- 证据锚：task_plan.md:192-198；findings.md:41,58,62,66,70；task_plan.md:169(scope_files含相关文件)、:374纪元面实测2文件一致。

### 4) VC 对照（VC-1/VC-2 判据与条款终稿文本关键词匹配） — ⚠️DRIFT
- **VC-1（✅匹配）**：task_plan.md:104 要求 `grep -c '序列创作知识同步' ...critical-rules-discipline.md >=1 且 107.x 子条锚行 >=4`。findings.md:43 含“序列创作知识同步纪律”，:46/:48/:50/:52/:54/:56 含 107.0~107.5 六个子条锚（≥4）——关键词与锚点形态在终稿文本中可匹配。
- **VC-2（⚠️部分不匹配）**：task_plan.md:105 要求 `grep -c '前序产出' skills/task-dispatch/references/critical-rules-dispatch.md skills/media-planner/references/critical-rules-media.md 各 >=1`。
  - media 47.7（findings.md:64）含连续文本“必附前序产出+台账路径”——`前序产出` 关键词 **匹配**。
  - dispatch 22.4d（findings.md:60）正文为“①紧邻前序单元产出文件绝对路径…”——为“前序单元产出”而非连续子串“前序产出”；同段未见“前序产出”四字连续出现。按当前终稿措辞，dispatch 文件实施后 **可能无法满足** VC-2 的 grep 判据（需在 Phase 3 实施时补入连续“前序产出”锚或同步修订 VC-2 判据，二选一并留痕）。
- 证据锚：task_plan.md:104-105；findings.md:43,46,48,50,52,54,56,60,64。

## 偏差点与建议（供 Phase 3 前处置）
1. **[DRIFT-VC2-KEYWORD]** dispatch 22.4d 终稿（findings.md:60）缺连续“前序产出”子串，与 task_plan.md:105 的 VC-2 grep 判据不一致。建议：Phase 3 S2 落 dispatch 条款时显式包含“前序产出”（如“必附前序产出（紧邻前序单元产出文件绝对路径）…”或在条款中补连续锚），并在实施后用 VC-2 命令验证；若选择改判据而非改文，须走 74.3 变更标注与计划同步（本检查点仅报告，不擅自改写）。
2. 其余 R锚定/批准面/CA表一致性均对齐，可进入 Phase 3，但应先闭合 DRIFT-VC2-KEYWORD。

## 结论
- 判定：**⚠️DRIFT**
- 原因：VC-2 对 dispatch 的 grep 锚 `前序产出` 与 findings.md:60 22.4d 终稿措辞未形成连续匹配；R锚定、用户#3批准面、CA-1~CA-6 载体映射均 ALIGNED。
