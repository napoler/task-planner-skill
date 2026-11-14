# 2-recheck-clauses（独立只读复检）

- 对象：worktree `/mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115`
- 基线：`master`（`git -C <wt> diff master -- ...`）
- 草案：`/mnt/data/dev/task-planner-skill/plans/task-drift-fakeqc-20261115/clause-drafts.md`
- 复检时间：2026-11-15（本轮执行）

## A. 插入行与批准草案 §1/§2/§3 逐字一致

### A-1 命令与输出

```bash
$ cd /mnt/data/dev/task-planner-skill
$ sed -n '618p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-discipline/references/critical-rules-discipline.md
- **94.7 语料状态边界与规模跳变确认门（范围静默扩张封堵 — task-drift-fakeqc-20261115 判例，L0-T 文本锚）**：执行中工作对象集合满足任一**可判定触发器**时，该扩批动作=B 类扩范围（Rule 74），必须停下复述「我理解您要的是 X（范围/对象），现在把对象扩展为 Y（N 篇/条）」并等用户显式确认后才可继续；未经确认继续扩批=P0 目标偏移：① **跨语料状态边界**：对象集合跨 published/draft/trash/archive 等库存状态互跨（**同站点/同产品不豁免**——94.1 同域口径不适用本门，判例=同站点 coffeesploration 内 published→trash 全集审计仍属偏移）；② **规模跳变 ≥10×**：对象规模相对用户指令可推定范围扩大十倍以上（判例=10 篇 trash 异常处置演化到 2306 篇全集审计）；③ **子集→全集化**：从「处置异常子集」演化为「全集审计/全集扫描/逐篇取证」。**上报包装禁令**：未经确认的扩展成果禁以「战役/阶段成果」名义包装为用户目标进度上报，汇报必须显式标注「该范围未经用户指令确认」并单列。机制=L0-T 文本锚（94.6 同范式零脚本零新键）。判例锚：用户原话「什么鬼谁让你审核垃圾桶内容 正确的是对已发布内容进行审核」（progress.md:391）。

$ grep -nF '94.7 语料状态边界与规模跳变确认门' plans/task-drift-fakeqc-20261115/clause-drafts.md
8:- **94.7 语料状态边界与规模跳变确认门（范围静默扩张封堵 — task-drift-fakeqc-20261115 判例，L0-T 文本锚）**：执行中工作对象集合满足任一**可判定触发器**时，该扩批动作=B 类扩范围（Rule 74），必须停下复述「我理解您要的是 X（范围/对象），现在把对象扩展为 Y（N 篇/条）」并等用户显式确认后才可继续；未经确认继续扩批=P0 目标偏移：① **跨语料状态边界**：对象集合跨 published/draft/trash/archive 等库存状态互跨（**同站点/同产品不豁免**——94.1 同域口径不适用本门，判例=同站点 coffeesploration 内 published→trash 全集审计仍属偏移）；② **规模跳变 ≥10×**：对象规模相对用户指令可推定范围扩大十倍以上（判例=10 篇 trash 异常处置演化到 2306 篇全集审计）；③ **子集→全集化**：从「处置异常子集」演化为「全集审计/全集扫描/逐篇取证」。**上报包装禁令**：未经确认的扩展成果禁以「战役/阶段成果」名义包装为用户目标进度上报，汇报必须显式标注「该范围未经用户指令确认」并单列。机制=L0-T 文本锚（94.6 同范式零脚本零新键）。判例锚：用户原话「什么鬼谁让你审核垃圾桶内容 正确的是对已发布内容进行审核」（progress.md:391）。

$ diff <(sed -n '618p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-discipline/references/critical-rules-discipline.md) <(grep -nF '94.7 语料状态边界与规模跳变确认门' plans/task-drift-fakeqc-20261115/clause-drafts.md | cut -d: -f2-) ; echo "EXIT:$?"
EXIT:0
```

```bash
$ sed -n '107p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-planner/references/critical-rules.md
- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞：① **操作类型实词**：写明实际执行的操作类型——正则/机械扫描 ≠ 逐篇语义审读 ≠ 文字改写/优化；禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷3 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认 E4-03/E4-05；语义审读实测 progress.md:409-413）。

$ grep -nF '51.14 完成声称操作类型与物理可行性门' plans/task-drift-fakeqc-20261115/clause-drafts.md
12:- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞：① **操作类型实词**：写明实际执行的操作类型——正则/机械扫描 ≠ 逐篇语义审读 ≠ 文字改写/优化；禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷3 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认 E4-03/E4-05；语义审读实测 progress.md:409-413）。

$ diff <(sed -n '107p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-planner/references/critical-rules.md) <(grep -nF '51.14 完成声称操作类型与物理可行性门' plans/task-drift-fakeqc-20261115/clause-drafts.md | cut -d: -f2-) ; echo "EXIT:$?"
EXIT:0
```

```bash
$ sed -n '68p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-drift-guard/references/critical-rules-drift.md
- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近条目号+一句话摘要（61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md:37-38（trash 审计被写入计划任务项）+取证 E6-06（专档 NOT FOUND）。

$ grep -nF '64.7 用户原话对照锚强制' plans/task-drift-fakeqc-20261115/clause-drafts.md
16:- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近条目号+一句话摘要（61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md:37-38（trash 审计被写入计划任务项）+取证 E6-06（专档 NOT FOUND）。

$ diff <(sed -n '68p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-drift-guard/references/critical-rules-drift.md) <(grep -nF '64.7 用户原话对照锚强制' plans/task-drift-fakeqc-20261115/clause-drafts.md | cut -d: -f2-) ; echo "EXIT:$?"
EXIT:0
```

### A-结论：**PASS**（三行分别与草案 §1/§2/§3 逐字一致，`diff` 退出码均为 0）

## B. 锚行 94.6/51.13/64.6 相对 master 原文零改动

### B-1 命令与输出

```bash
$ cd /mnt/data/dev/task-planner-skill
$ sed -n '617p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-discipline/references/critical-rules-discipline.md; echo "---MASTER---"; git show master:skills/task-discipline/references/critical-rules-discipline.md | sed -n '617p'
- **94.6 机制（文本优先 L0-T——2026-10-23 用户裁决，对齐 86.7/89.6/90.6/92.7 范式）**：判定面=LLM 行为+本条款文本锚（94.1 总纲+94.2 判据+94.3 询问门+94.4 隔离处置），**零新增守护脚本/零新 config 键**；selftest/registry 机器化属 opt-in（Rule 38.7 L0-T 档），仅当用户显式要求才建。判例锚=2026-10-23 用户 /goal 指令（plans/task-focus-plan-split-20261023/user-session-log.md #1）。
---MASTER---
- **94.6 机制（文本优先 L0-T——2026-10-23 用户裁决，对齐 86.7/89.6/90.6/92.7 范式）**：判定面=LLM 行为+本条款文本锚（94.1 总纲+94.2 判据+94.3 询问门+94.4 隔离处置），**零新增守护脚本/零新 config 键**；selftest/registry 机器化属 opt-in（Rule 38.7 L0-T 档），仅当用户显式要求才建。判例锚=2026-10-23 用户 /goal 指令（plans/task-focus-plan-split-20261023/user-session-log.md #1）。

$ sed -n '106p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-planner/references/critical-rules.md; echo "---MASTER---"; git show master:skills/task-planner/references/critical-rules.md | sed -n '106p'
51.13 **机制（零新 config 键 — 与 43.4/47.4/50.6 同范式，L0-T 文本优先）**：判定面=LLM 行为（计划期交付类别识别/计数判据/留口让步锚，非机器触发）；机器面=`scripts/selftest-requirement-coverage.sh` 扩展静态守护（51.9-51.13 子条文本锚 + 事故判例锚「0 母图即 COMPLETE」+ SKILL.md 51 bullet 联动 + media-planner Rule 50 计数指针 + 零新键负断言）；既有 51.1-51.8 与 Rule 47/50/66/84 原文零改动（Rule 36.5 纯增量）。
---MASTER---
51.13 **机制（零新 config 键 — 与 43.4/47.4/50.6 同范式，L0-T 文本优先）**：判定面=LLM 行为（计划期交付类别识别/计数判据/留口让步锚，非机器触发）；机器面=`scripts/selftest-requirement-coverage.sh` 扩展静态守护（51.9-51.13 子条文本锚 + 事故判例锚「0 母图即 COMPLETE」+ SKILL.md 51 bullet 联动 + media-planner Rule 50 计数指针 + 零新键负断言）；既有 51.1-51.8 与 Rule 47/50/66/84 原文零改动（Rule 36.5 纯增量）。

$ sed -n '67p' tmp/worktrees/task-drift-fakeqc-20261115/skills/task-drift-guard/references/critical-rules-drift.md; echo "---MASTER---"; git show master:skills/task-drift-guard/references/critical-rules-drift.md | sed -n '67p'
64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。
---MASTER---
64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。

$ git -C tmp/worktrees/task-drift-fakeqc-20261115 diff master --unified=0 -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/references/critical-rules.md skills/task-drift-guard/references/critical-rules-drift.md | grep '^-' | grep -v '^---' ; echo "DEL_LINES:$?"
DEL_LINES:1
```

### B-结论：**PASS**（三锚行内容与 master 对应行一致；diff 无任何 `-` 删除行，`grep '^-' | grep -v '^---'` 无匹配，退出码 1）

## C. 整体纯增量（numstat +1/-0）

### C-1 命令与输出

```bash
$ git -C /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115 diff master --numstat -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/references/critical-rules.md skills/task-drift-guard/references/critical-rules-drift.md
1	0	skills/task-discipline/references/critical-rules-discipline.md
1	0	skills/task-drift-guard/references/critical-rules-drift.md
1	0	skills/task-planner/references/critical-rules.md
```

```bash
$ git -C tmp/worktrees/task-drift-fakeqc-20261115 diff master --unified=0 -- skills/task-discipline/references/critical-rules-discipline.md skills/task-planner/references/critical-rules.md skills/task-drift-guard/references/critical-rules-drift.md | grep '^+' | grep -v '^+++' ; echo "ADD_LINES_DONE"
+- **94.7 语料状态边界与规模跳变确认门（范围静默扩张封堵 — task-drift-fakeqc-20261115 判例，L0-T 文本锚）**：执行中工作对象集合满足任一**可判定触发器**时，该扩批动作=B 类扩范围（Rule 74），必须停下复述「我理解您要的是 X（范围/对象），现在把对象扩展为 Y（N 篇/条）」并等用户显式确认后才可继续；未经确认继续扩批=P0 目标偏移：① **跨语料状态边界**：对象集合跨 published/draft/trash/archive 等库存状态互跨（**同站点/同产品不豁免**——94.1 同域口径不适用本门，判例=同站点 coffeesploration 内 published→trash 全集审计仍属偏移）；② **规模跳变 ≥10×**：对象规模相对用户指令可推定范围扩大十倍以上（判例=10 篇 trash 异常处置演化到 2306 篇全集审计）；③ **子集→全集化**：从「处置异常子集」演化为「全集审计/全集扫描/逐篇取证」。**上报包装禁令**：未经确认的扩展成果禁以「战役/阶段成果」名义包装为用户目标进度上报，汇报必须显式标注「该范围未经用户指令确认」并单列。机制=L0-T 文本锚（94.6 同范式零脚本零新键）。判例锚：用户原话「什么鬼谁让你审核垃圾桶内容 正确的是对已发布内容进行审核」（progress.md:391）。
+- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近条目号+一句话摘要（61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md:37-38（trash 审计被写入计划任务项）+取证 E6-06（专档 NOT FOUND）。
+- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞：① **操作类型实词**：写明实际执行的操作类型——正则/机械扫描 ≠ 逐篇语义审读 ≠ 文字改写/优化；禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷3 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认 E4-03/E4-05；语义审读实测 progress.md:409-413）。
ADD_LINES_DONE
```

### C-结论：**PASS**（三文件均 `1	0`，纯增量）

## D. 插入位置正确（新行紧随各自锚行之后）

### D-1 命令与输出

```bash
$ cd /mnt/data/dev/task-planner-skill/tmp/worktrees/task-drift-fakeqc-20261115
$ grep -n -A1 '^\- \*\*94\.6 机制' skills/task-discipline/references/critical-rules-discipline.md
617:- **94.6 机制（文本优先 L0-T——2026-10-23 用户裁决，对齐 86.7/89.6/90.6/92.7 范式）**：判定面=LLM 行为+本条款文本锚（94.1 总纲+94.2 判据+94.3 询问门+94.4 隔离处置），**零新增守护脚本/零新 config 键**；selftest/registry 机器化属 opt-in（Rule 38.7 L0-T 档），仅当用户显式要求才建。判例锚=2026-10-23 用户 /goal 指令（plans/task-focus-plan-split-20261023/user-session-log.md #1）。
618-- **94.7 语料状态边界与规模跳变确认门（范围静默扩张封堵 — task-drift-fakeqc-20261115 判例，L0-T 文本锚）**：执行中工作对象集合满足任一**可判定触发器**时，该扩批动作=B 类扩范围（Rule 74），必须停下复述「我理解您要的是 X（范围/对象），现在把对象扩展为 Y（N 篇/条）」并等用户显式确认后才可继续；未经确认继续扩批=P0 目标偏移：① **跨语料状态边界**：对象集合跨 published/draft/trash/archive 等库存状态互跨（**同站点/同产品不豁免**——94.1 同域口径不适用本门，判例=同站点 coffeesploration 内 published→trash 全集审计仍属偏移）；② **规模跳变 ≥10×**：对象规模相对用户指令可推定范围扩大十倍以上（判例=10 篇 trash 异常处置演化到 2306 篇全集审计）；③ **子集→全集化**：从「处置异常子集」演化为「全集审计/全集扫描/逐篇取证」。**上报包装禁令**：未经确认的扩展成果禁以「战役/阶段成果」名义包装为用户目标进度上报，汇报必须显式标注「该范围未经用户指令确认」并单列。机制=L0-T 文本锚（94.6 同范式零脚本零新键）。判例锚：用户原话「什么鬼谁让你审核垃圾桶内容 正确的是对已发布内容进行审核」（progress.md:391）。

$ grep -n -A1 '^51\.13 \*\*机制' skills/task-planner/references/critical-rules.md
106:51.13 **机制（零新 config 键 — 与 43.4/47.4/50.6 同范式，L0-T 文本优先）**：判定面=LLM 行为（计划期交付类别识别/计数判据/留口让步锚，非机器触发）；机器面=`scripts/selftest-requirement-coverage.sh` 扩展静态守护（51.9-51.13 子条文本锚 + 事故判例锚「0 母图即 COMPLETE」+ SKILL.md 51 bullet 联动 + media-planner Rule 50 计数指针 + 零新键负断言）；既有 51.1-51.8 与 Rule 47/50/66/84 原文零改动（Rule 36.5 纯增量）。
107-- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞：① **操作类型实词**：写明实际执行的操作类型——正则/机械扫描 ≠ 逐篇语义审读 ≠ 文字改写/优化；禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷3 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认 E4-03/E4-05；语义审读实测 progress.md:409-413）。

$ grep -n -A1 '^64\.6 \*\*零新 config 键' skills/task-drift-guard/references/critical-rules-drift.md
67:64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。
68-- **64.7 用户原话对照锚强制（专档缺失=禁 ALIGNED — task-drift-fakeqc-20261115 判例）**：drift-checker 检查点判定必须记录**用户原话对照面**=`user-session-log.md` 最近条目号+一句话摘要（61.2「用户目标原话」字段的对照物溯源）；判定基线=计划 Goal ∩ 专档最近原话双锚——专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户（防「基线被未授权扩展污染后对污染基线自证 ALIGNED」——被投诉判例计划目录缺专档，80.8 五决策点读取全落空，trash 扩批被计划内任务项背书）。机制=L0-T 文本锚（64.6 同范式零脚本零新键）。判例锚：被投诉计划 task_plan.md:37-38（trash 审计被写入计划任务项）+取证 E6-06（专档 NOT FOUND）。
```

### D-结论：**PASS**（94.7 紧随 94.6，51.14 紧随 51.13，64.7 紧随 64.6）

## E. 草案三条款语义完整性（目检判读+原文短语作证）

### E-1 94.7（discipline，§1）
- 三触发器齐备：`① **跨语料状态边界**：对象集合跨 published/draft/trash/archive 等库存状态互跨`；`② **规模跳变 ≥10×**：对象规模相对用户指令可推定范围扩大十倍以上`；`③ **子集→全集化**：从「处置异常子集」演化为「全集审计/全集扫描/逐篇取证」`。
- 上报包装禁令：`**上报包装禁令**：未经确认的扩展成果禁以「战役/阶段成果」名义包装为用户目标进度上报，汇报必须显式标注「该范围未经用户指令确认」并单列`。
- 结论：**PASS**。

### E-2 51.14（planner，§2）
- 三要素齐备：`① **操作类型实词**：写明实际执行的操作类型——正则/机械扫描 ≠ 逐篇语义审读 ≠ 文字改写/优化；禁止用语义上位词包装低语义工作...`；`② **覆盖范围实数**：N/总数（未覆盖面单列）`；`③ **实测耗时**：产物时间戳或执行记录锚`。
- 物理可行性对照：`**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷3 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报。`
- 与 51.3/51.8 分工句：`**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。`
- 结论：**PASS**。

### E-3 64.7（drift-guard，§3）
- 双锚基线：`判定基线=计划 Goal ∩ 专档最近原话双锚`（并要求记录 `user-session-log.md` 最近条目号+一句话摘要）。
- 专档缺失=禁 ALIGNED+BLOCKED 处置：`专档缺失/空/零条目，或 Goal 与最近原话零交集时，ALIGNED 判定无效（64.1 未执行同口径），按 🔴BLOCKED 处置升级用户`。
- 结论：**PASS**。

## 总结

| 判据 | 结论 | 依据 |
|------|------|------|
| A | PASS | 三处 `diff` EXIT:0，worktree 插入行与 drafts 对应行逐字一致 |
| B | PASS | 锚行与 `git show master:...` 同行文本一致；diff 无删除行（`DEL_LINES:1`） |
| C | PASS | `--numstat` 三文件均 `1 0`，仅三行新增 |
| D | PASS | `grep -n -A1` 显示 618/107/68 分别紧随 617/106/67 锚行 |
| E | PASS | 94.7 含①②③+上报包装禁令；51.14 含①②③+物理可行性对照+与 51.3/51.8 分工；64.7 含双锚基线+专档缺失=禁 ALIGNED+BLOCKED |

**Verdict: APPROVED**（A-E 全过，无缺陷）。
