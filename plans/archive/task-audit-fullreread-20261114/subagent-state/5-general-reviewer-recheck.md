# 5-general-reviewer-recheck — P4 独立复检（103.3a dogfood，第二轮复检）

- 复检对象: `git show 83b3388`（worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-audit-fullreread-20261114`）
- 变更集: 6 受管文件，+10/-5（`git show --stat 83b3388`，2026-11-14）
- 需求锚: R2「如果没有的话，我希望可以修正。…当然说最重要的是在审核阶段，我希望可以在审核阶段去做这部分内容，在单独的子代理中进行。」（`user-session-log.md:42-43`；`task_plan.md:21`）
- 验收基准: `task_plan.md`「📋 变更标注表」CA-1~CA-7 原文（`task_plan.md:188-195`）

## 1. 每文件读取范围证据（103.3a 全文回读）

| # | 文件（worktree 根相对路径） | 总行数 (`wc -l`) | 实际 Read 范围（行号区间） | 关键锚点复核 |
|---|---|---:|---|---|
| 1 | `skills/task-dispatch/references/critical-rules-dispatch.md` | 297 | 1-282（首段，工具截断提示至 282/739 口径标识但文件实为 297 行）+283-297（续读）= **1-297 全覆盖** | `103.3a` @232，`103.5 五要素` @236，⑤全文回读要求 @236 |
| 2 | `skills/task-discipline/references/critical-rules-discipline.md` | 738 | 1-282（首段截断）+283-532（续读）+533-739（续读）= **1-739 全覆盖** | `106.1b` @727，106.1a 结构锚保留 @725 |
| 3 | `skills/task-planner/SKILL.md` | 282 | 1-283（单次读全文件，返回至末行 282）= **1-282 全覆盖** | 3h 追加句 @104 |
| 4 | `skills/task-planner/templates/subagent_dispatch.md` | 120 | 1-120（单次读全文件）= **1-120 全覆盖** | 五要素 @58，全文回读要素 @59 |
| 5 | `skills/task-planner/templates/task_plan.md` | 588 | 1-588（单次读全文件）= **1-588 全覆盖** | 「简洁五要素 103.5」@113 |
| 6 | `skills/verification-gate/references/critical-rules-verification.md` | 58 | 1-58（单次读全文件）= **1-58 全覆盖** | 「复检任务书简洁五要素」@55 |

补充核验命令与输出（证据）：
- `wc -l` 6 文件合计 2083 行（Bash 输出：297/738/282/120/588/58/2083 total）
- `grep -n "103.3a 全文回读与整体分析义务"` dispatch:232
- `grep -n "复检任务书简洁直接五要素"` dispatch:236；`grep -n "⑤全文回读要求"` dispatch:236
- `grep -n "103.3a 义务，2026-11-14 task-audit-fullreread-20261114"` SKILL.md:104
- `grep -n "106.1b 审核阶段全文回读分工"` discipline:727
- `grep -n "复检任务书只含五要素"` subagent_dispatch.md:58；`grep -n "第二轮·全文回读要素"` subagent_dispatch.md:59
- `grep -n "复检任务书简洁五要素"` task_plan.md:113 与 verification-gate:55
- 结构段数守恒复核：`grep -nE '^#{2,3} '` → dispatch 15、SKILL 17、discipline 66（与 S1/S2 checkpoint 及 progress.md:80-88 记录一致）

## 2. CA 逐条判定表（CA-1~CA-7，变更标注表原文逐条对照）

| CA | 对象/锚点（标注表） | 类型/吸收判定 | 判定 | 证据锚（file:line 或命令→输出） | 备注/自审比对 |
|---|---|---|---|---|---|
| CA-1 | `skills/task-dispatch/references/critical-rules-dispatch.md:230`（103.3 段尾追加义务句/103.3a） | 修改/增量 | **PASS** | `critical-rules-dispatch.md:232` 新段 `**103.3a 全文回读与整体分析义务（审核阶段，P0，2026-11-14 task-audit-fullreread-20261114）**：复检体收到任务书后必须完整回读被修改文件的全文（分页读完，非 diff/非片段）再下判定，并做整体分析四维——①结构完整性②修改落点正确性③交叉引用一致性④语义连贯；复检回执必须附全文回读证据（读取范围/行数），缺证据=复检无效，重派复检体。…`；103.3 原尾句保留 @230 `…申报与产物不一致按 FAIL 处置（防自审形式化填表）。`；`git show` dispatch hunk +3/-1。 | 与 S1 checkpoint（3-general-coder-s1.md）自审 1/4/5 一致；S1 记录的首轮 `**` 吞失已在 S1 内修复且当前盘上复核为行首 `**103.3a` 完整，申报与产物一致。 |
| CA-2 | `skills/task-dispatch/references/critical-rules-dispatch.md:234`（103.5 四要素→五要素） | 修改/增量 | **PASS** | `critical-rules-dispatch.md:236` 标题 `103.5 **复检任务书简洁直接五要素（低资源约束）**：`；①-④原文保留，追加 `；⑤全文回读要求=任务书须声明被修改文件绝对路径清单并要求复检体完整回读全文+整体分析四维（103.3a）、回执附读取范围证据。`；`grep -c '四要素'` 在 103.5 标题处为 0（本段内无残留）。 | 与 S1 checkpoint 自审 2/3/5 一致，申报与产物一致。 |
| CA-3 | `skills/task-planner/SKILL.md:104`（3h 行追加） | 修改/增量 | **PASS** | `SKILL.md:104` 行尾追加 `复检体全文回读被改文件并整体分析（103.3a 义务，2026-11-14 task-audit-fullreread-20261114）。`；原句 `多文件变更集附同步核对清单（103.6）。` 原文保留（`git show` hunk @@ -101,7 +101,7 @@ 中可见）。 | 与 S2 checkpoint（3-general-coder-s2.md）自审 1/3/4 一致，申报与产物一致。 |
| CA-4 | `skills/task-discipline/references/critical-rules-discipline.md:725 之后`（106.1a 与 106.2 之间新插 106.1b） | 新增/增量 | **PASS** | `critical-rules-discipline.md:727` 新段 `**106.1b 审核阶段全文回读分工（P1，指针，2026-11-14 task-audit-fullreread-20261114）**：受管文档修改的「完整回读+整体分析」在审核阶段（Rule 103.3a 独立复检）由全新复检子代理执行——分页读完被改文件全文+整体分析四维（结构完整性/落点正确性/交叉引用一致性/语义连贯）+回执附读取证据；106.1/106.1a/106.3 管过程期即时拦截（修改点/结构守恒/不变量回归），语义整体面归审核阶段复检体——两面互补不互代（分工范式同 84.x/106 边界声明）。`；106.1a 原尾句保留 @725。 | 与 S2 checkpoint 自审 2/3/4 一致，`**` 前缀与「独立复检」正字完整，申报与产物一致。 |
| CA-5 | `skills/task-planner/templates/subagent_dispatch.md:58`（复检任务书操作模板四要素→五要素） | 修改/增量 | **PASS** | `subagent_dispatch.md:58` 「复检任务书只含五要素：①…②…③…④…；复检体档位=…」；`subagent_dispatch.md:59` 新增 `- **第二轮·全文回读要素（103.3a，2026-11-14 task-audit-fullreread-20261114）**：复检任务书须声明被修改文件绝对路径清单，并要求复检体完整回读全文（分页读完，非 diff/非片段）+整体分析四维（结构完整性/落点正确性/交叉引用一致性/语义连贯）+回执附读取范围证据；缺证据=复检无效。` 与 103.5 ⑤措辞同义同步。 | 级联面枚举（task_plan.md:484-485/CA-5）满足；与 103.5 五要素语义对齐，无编号新增、①-④原意不变。 |
| CA-6 | `skills/task-planner/templates/task_plan.md:113`（双轮质检声明注释） | 修改/增量 | **PASS** | `task_plan.md(模板):113` 注释含 `…档位升一档 103.4、复检任务书简洁五要素 103.5`（`git show` hunk `-<!-- ... 简洁四要素 103.5 -->` → `+<!-- ... 简洁五要素 103.5 -->`）。 | 「四要素」→「五要素」字面同步，级联面满足。 |
| CA-7 | `skills/verification-gate/references/critical-rules-verification.md:55`（衔接行措辞同步） | 修改/增量 | **PASS** | `critical-rules-verification.md:55` `- **衔接（Rule 103，task-dualqc-20261104）**：…103.5 复检任务书简洁五要素/103.6 同步核对清单…`（`git show` hunk 同步四→五）。 | 级联字面面同步，与 103.5/84.7 衔接语义一致。 |

**CA 汇总**: 7/7 PASS。**执行体自审申报 vs 实际产出**：S1(3-general-coder-s1.md, 5/5 pass) 与 S2(3-general-coder-s2.md, 5/5 pass) 所报锚点、段清单守恒、diff 范围、逐字保真均与全文回读及 git show 实际产物一致（含 S1 自曝并修复的 103.3a 行首 `**` 吞失——当前产物已正确）；未发现申报与产物不一致项。

## 3. 整体分析四维（103.3a）

| 维度 | 结论 | 证据/说明 |
|---|---|---|
| ① 结构完整性（标题/段落层级未因修改受损） | **PASS** | 6 文件全读后段落层级连续，无孤立/错级标题；`grep -nE '^#{2,3} '` 段数守恒：dispatch 15、SKILL 17、discipline 66（与变更前基线及 S1/S2/progress 记录一致）；103.3a/106.1b 为段内加粗条目（非 `##/###`）插入，未破坏标题清单。模板文件结构与既有章节/注释块完整。 |
| ② 修改落点正确性（变更落在预期锚点、未误伤邻接段） | **PASS** | CA-1 落 103.3 与 103.4 之间（@232）；CA-2 落 103.5 同行追加⑤（@236）；CA-3 落 3h 行尾（@104）；CA-4 落 106.1a 与 106.2 之间（@727）；CA-5/6/7 落各自模板/衔接注释指定行（58-59/113/55）。邻接锚行原文保留：dispatch:230 `防自审形式化填表）。`、SKILL:104 原句 `多文件变更集附同步核对清单（103.6）。`、discipline:725 `本条为 106.1 写后回读门对结构文件的细化执行面。` 均未被改写。`git show` 6 文件 hunks 与 CA 表一一对应，无计划外落点。 |
| ③ 交叉引用一致性（与文件内外互引/编号/纪元锚协调） | **PASS** | 103.3a ↔ 103.5 ⑤ 互引 `103.3a`；103.3a 声明与 106.1 分工（过程期即时回读 vs 审核阶段语义整体面）互补不互代；106.1b 指向 `Rule 103.3a 独立复检` 并与 84.x/106 边界声明对齐；SKILL 3h 引用 103.3a 义务；subagent_dispatch 模板 103.3a 全文回读要素与 103.5 ⑤同义；task_plan 模板 113 与 verification-gate 55 均同步为「五要素」，同 commit 6 文件形成一致字面/引用面闭环。未见悬空引用或旧称「四要素」在变更目标位残留（目标位 grep 均已为五要素）。 |
| ④ 语义连贯（修改段与上下文整体语义一致） | **PASS** | 103.3a 的四维整体分析（结构完整性/落点正确性/交叉引用一致性/语义连贯）与 R2「修改完文件中重新读取完整文件，然后进行整体分析…在审核阶段…单独的子代理中进行」直接对应；执行面放在独立复检体（103.3 全新子代理、只读）且与 106.1/106.1a/106.3 过程期即时拦截分工明确，不与既有 84.7/84.14/103.6 语义冲突；模板/衔接措辞同步后，规则—模板—流程指针链语义自洽。 |

## 4. 需求锚覆盖与综合结论

- R2 覆盖：审核阶段 + 单独子代理（103.3 既有，103.3a 细化执行面）+ 全文回读（分页读完、非 diff/片段）+ 整体分析（四维）+ 回执附读取证据，已在规则/技能指针/分工指针/模板操作面/验证衔接面全链路落地（CA-1~CA-7）。
- 执行体自审对比：S1、S2 checkpoint 申报与实际产出逐项一致（含缺陷自修复留痕），无 FAIL 项。
- 只读审查：未修改任何文件（含 plans/）；未重做；未扩范围。

**最终结论 verdict: APPROVED**

---
status: done
acceptance: 7/7 pass — [CA-1:PASS CA-2:PASS CA-3:PASS CA-4:PASS CA-5:PASS CA-6:PASS CA-7:PASS]
files: skills/task-dispatch/references/critical-rules-dispatch.md(+3/-1); skills/task-discipline/references/critical-rules-discipline.md(+2/0); skills/task-planner/SKILL.md(+1/-1); skills/task-planner/templates/subagent_dispatch.md(+2/-1); skills/task-planner/templates/task_plan.md(+1/-1); skills/verification-gate/references/critical-rules-verification.md(+1/-1) | read-only review (no files modified)
evidence: git show --stat 83b3388 → 6 files +10/-5; wc -l → 297/738/282/120/588/58; full-read ranges 1-297,1-739,1-282,1-120,1-588,1-58; grep dispatch:232(103.3a),236(103.5五要素+⑤); SKILL.md:104(3h+103.3a义务); discipline:727(106.1b); subagent_dispatch.md:58-59(五要素+全文回读要素); task_plan模板:113 & verification:55(简洁五要素); heading counts dispatch15/SKILL17/discipline66; self-audit compare 3-general-coder-s1.md & 3-general-coder-s2.md vs产物一致
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-audit-fullreread-20261114/subagent-state/5-general-reviewer-recheck.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
