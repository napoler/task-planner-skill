# 5-f4f7fix: F4/F7 句尾保真修复检查点

## 目标
- F4: `skills/task-planner/references/critical-rules.md` 51.14 行，`缺一禁用「完成」措辞：①` 后追加括注（豁免面见文末适用面——trivial 一行式免 ③ 实测耗时项）。
- F7: `skills/task-discipline/references/execution-recall-card.md` 行 E（偏移检查行），句尾追加“非 trivial 档专档缺失同款 BLOCKED（与 64.7 R-1 补位句同步）。”。

## 自验输出原文

### 1) F4 grep -cF
命令：
`grep -cF '缺一禁用「完成」措辞（豁免面见文末适用面——trivial 一行式免 ③ 实测耗时项）：①' skills/task-planner/references/critical-rules.md`

输出：
```
1
```
结果：PASS (=1)

### 2) F7 grep -cF
命令：
`grep -cF '非 trivial 档专档缺失同款 BLOCKED（与 64.7 R-1 补位句同步）。' skills/task-discipline/references/execution-recall-card.md`

输出：
```
1
```
结果：PASS (=1)

### 3) 目标行内容（单行确认）
`grep -n '51\.14 完成声称操作类型' skills/task-planner/references/critical-rules.md`：
```
107:- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞（豁免面见文末适用面——trivial 一行式免 ③ 实测耗时项）：① **操作类型档位（实词自证）**：按语义档位自证——L1 机械/统计级 ＜ L2 抽样级 ＜ L3 逐件语义处理级 ＜ L4 创作/改写级；措辞档位不得高于实际档位。域映射示例（列举可扩展）：内容 L1 正则/机械扫描/L2 抽样审读/L3 逐篇语义审读/L4 文字改写/优化；代码 L1 lint·grep/L2 抽样 review/L3 逐行审读/L4 重构修复；媒体 L1 参数校验/L2 抽帧目检/L3 逐帧审看/L4 剪辑重制。禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷K 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报（K=并发执行体数，缺省 3，须在声称中写明 K 的依据：单执行体/派发 N 子代理/批量接口）。**适用面**：对外交付/终态完成/阶段成果上报；单文件 ≤3 行 trivial 修改的自述可一行式（操作类型+覆盖 1/1），免耗时项。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认于取证报告 E4-03/E4-05；语义审读实测见判例会话 progress「逐篇语义审核首批示范」条目）（判例=task-drift-fakeqc-20261115 判例）。
```

`grep -n '偏移检查：Phase complete 后派 drift-checker' skills/task-discipline/references/execution-recall-card.md`：
```
41:- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）；检查点须记 64.7 用户原话对照面（最近含目标/指令类内容条目号+摘要，51.3 双锚口径），专档缺失且 trivial 档记 `专档=未建档(tier)` 不判 BLOCKED，专档在位但空/零条目或 Goal∩原话零交集按 64.1+BLOCKED 处置（task-drift-fakeqc-20261115 判例锚）。非 trivial 档专档缺失同款 BLOCKED（与 64.7 R-1 补位句同步）。
```
结果：两行仍单行，old 子串逐字保留。PASS

### 4) git diff --numstat
命令：
`git diff --numstat -- skills/task-planner/references/critical-rules.md skills/task-discipline/references/execution-recall-card.md`

输出：
```
1	1	skills/task-discipline/references/execution-recall-card.md
1	1	skills/task-planner/references/critical-rules.md
```
结果：各 `1 1`，两文件其余行零改动。PASS

### 5) git diff 全文
```diff
diff --git a/skills/task-discipline/references/execution-recall-card.md b/skills/task-discipline/references/execution-recall-card.md
index 56efa06..f5fb2ee 100644
--- a/skills/task-discipline/references/execution-recall-card.md
+++ b/skills/task-discipline/references/execution-recall-card.md
@@ -38,7 +38,7 @@
 - 规范召回：每 3 个 S-unit/Phase 翻转主进程 Read 本卡留 [recall]；压缩/恢复/PRESSURE 后第一动作（Rule 93）
 - 专注隔离：目标重大偏差（A→B）不就地吸收——主动询问拆分新 Task Plan，单计划单垂直域防污染（Rule 94）
 - 执行优先：零报错+有直推路径=禁停等——额度不可查询即执行探测；按日重置额度禁空置；质检处置自主化；暂停前三问（Rule 95）
-- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）；检查点须记 64.7 用户原话对照面（最近含目标/指令类内容条目号+摘要，51.3 双锚口径），专档缺失且 trivial 档记 `专档=未建档(tier)` 不判 BLOCKED，专档在位但空/零条目或 Goal∩原话零交集按 64.1+BLOCKED 处置（task-drift-fakeqc-20261115 判例锚）。
+- 偏移检查：Phase complete 后派 drift-checker+留痕三件套（Rule 61/64.2）；检查点须记 64.7 用户原话对照面（最近含目标/指令类内容条目号+摘要，51.3 双锚口径），专档缺失且 trivial 档记 `专档=未建档(tier)` 不判 BLOCKED，专档在位但空/零条目或 Goal∩原话零交集按 64.1+BLOCKED 处置（task-drift-fakeqc-20261115 判例锚）。非 trivial 档专档缺失同款 BLOCKED（与 64.7 R-1 补位句同步）。
 - 上下文压力：[assess] 三态；PRESSURE→主动压缩；CONFUSED→session-handoff 转新会话（Rule 67）
 - 恢复读序：user-session-log→task_plan→progress→findings→knowledge-brief（Rule 19.3/80.4/62.1）
 - 上下文卫生：每 2 Phase 跑 check-context-hygiene（Rule 29）
diff --git a/skills/task-planner/references/critical-rules.md b/skills/task-planner/references/critical-rules.md
index 5e31cf4..9dcaed7 100644
--- a/skills/task-planner/references/critical-rules.md
+++ b/skills/task-planner/references/critical-rules.md
@@ -104,7 +104,7 @@ Rule 18 管批量质量、19.2 管回填存在性、25 管委派率,但单/非
 51.12 **媒体类交付计数条目（pointer Rule 50.1）**：媒体/母图类 R 行（51.9）在计划期原子验收条目表（Rule 50.1）中必须落为**数量型条目**（类型 C：期望件数 N，判定刻度=在位件数 ≥ N；N 由该 R 行导出），**禁只落存在性 P 条目**（50.1 的 P=有/无二值，无法承载「N 件」语义——0 产出即 PASS 的结构性入口）。Rule 50 全文在 media-planner 卫星（`../../media-planner/references/critical-rules-media.md`）；本条只立「可计数交付必须可计数」的不变量，媒体轴拆分仍走 Rule 47。
 
 51.13 **机制（零新 config 键 — 与 43.4/47.4/50.6 同范式，L0-T 文本优先）**：判定面=LLM 行为（计划期交付类别识别/计数判据/留口让步锚，非机器触发）；机器面=`scripts/selftest-requirement-coverage.sh` 扩展静态守护（51.9-51.13 子条文本锚 + 事故判例锚「0 母图即 COMPLETE」+ SKILL.md 51 bullet 联动 + media-planner Rule 50 计数指针 + 零新键负断言）；既有 51.1-51.8 与 Rule 47/50/66/84 原文零改动（Rule 36.5 纯增量）。
-- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞：① **操作类型档位（实词自证）**：按语义档位自证——L1 机械/统计级 ＜ L2 抽样级 ＜ L3 逐件语义处理级 ＜ L4 创作/改写级；措辞档位不得高于实际档位。域映射示例（列举可扩展）：内容 L1 正则/机械扫描/L2 抽样审读/L3 逐篇语义审读/L4 文字改写/优化；代码 L1 lint·grep/L2 抽样 review/L3 逐行审读/L4 重构修复；媒体 L1 参数校验/L2 抽帧目检/L3 逐帧审看/L4 剪辑重制。禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷K 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报（K=并发执行体数，缺省 3，须在声称中写明 K 的依据：单执行体/派发 N 子代理/批量接口）。**适用面**：对外交付/终态完成/阶段成果上报；单文件 ≤3 行 trivial 修改的自述可一行式（操作类型+覆盖 1/1），免耗时项。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认于取证报告 E4-03/E4-05；语义审读实测见判例会话 progress「逐篇语义审核首批示范」条目）（判例=task-drift-fakeqc-20261115 判例）。
+- **51.14 完成声称操作类型与物理可行性门（claim-type honesty — task-drift-fakeqc-20261115 判例）**：完成/交付类声称必须三要素齐备，缺一禁用「完成」措辞（豁免面见文末适用面——trivial 一行式免 ③ 实测耗时项）：① **操作类型档位（实词自证）**：按语义档位自证——L1 机械/统计级 ＜ L2 抽样级 ＜ L3 逐件语义处理级 ＜ L4 创作/改写级；措辞档位不得高于实际档位。域映射示例（列举可扩展）：内容 L1 正则/机械扫描/L2 抽样审读/L3 逐篇语义审读/L4 文字改写/优化；代码 L1 lint·grep/L2 抽样 review/L3 逐行审读/L4 重构修复；媒体 L1 参数校验/L2 抽帧目检/L3 逐帧审看/L4 剪辑重制。禁止用语义上位词包装低语义工作（机械扫描级工作只可称「机械扫描/取证完成」，禁称「审核完成/审读完成/优化完成」）；② **覆盖范围实数**：N/总数（未覆盖面单列）；③ **实测耗时**：产物时间戳或执行记录锚。**物理可行性对照**：若 ① 所指操作类型存在近期实测单件成本（如语义审读 2-4.5 分钟/篇），声称耗时 < 件数×单件成本下限÷K 时禁以该操作类型「完成」声称，只能按 ① 的真实低档类型+真实覆盖数呈报（K=并发执行体数，缺省 3，须在声称中写明 K 的依据：单执行体/派发 N 子代理/批量接口）。**适用面**：对外交付/终态完成/阶段成果上报；单文件 ≤3 行 trivial 修改的自述可一行式（操作类型+覆盖 1/1），免耗时项。**与 51.3/51.8 分工**：51.3 管「做了用户要的事没有」（覆盖对照），51.8 管「没测试就声称」，本条管「做了的没做够档的事怎么称呼」（措辞不得高于实际操作类型）。机制=L0-T 文本锚。判例锚：224 篇 ≈5 分钟正则扫描被表述为「完成 published 内容审核」（零改写零语义审读自认于取证报告 E4-03/E4-05；语义审读实测见判例会话 progress「逐篇语义审核首批示范」条目）（判例=task-drift-fakeqc-20261115 判例）。
 
 <!-- Rule 62 (task-v145 2026-10-08): 纯增量新增；判例=videop1 调研派发 prompt 手写「findings.md（主进程回填，你只写检查点）」收窄 22.4a 契约——调研子代理守约禁写，30KB 知识只停检查点，findings.md 43 行 0 小节；守卫 check-dispatch.sh 只查三文件路径存在性，对契约措辞语义盲区 -->
 ### 62 四文件罗盘数据流转与调研知识沉淀纪律（P0 — task-v145，目标：task_plan/findings/progress/knowledge-brief 四文件 = 主代理↔子代理数据流转唯一协议介质，调研产出双落盘、派发契约不可收窄、知识增量门控；判定面=LLM 行为+check-dispatch.sh/check-3file-gate.sh 机器扩展，零新 config 键；衔接 Rule 19/22.4a/22.5/22.8/55，既有 Rules 原文零改动）
```

## 结论
- 修复 1 (F4, critical-rules.md:107): 已追加括注，old 子串逐字保留，单行。PASS
- 修复 2 (F7, execution-recall-card.md:41): 已追加补位句，old 子串逐字保留，单行。PASS
- git diff --numstat: 两文件各 1 1。PASS
- 其余行零改动。无 git 写操作。
