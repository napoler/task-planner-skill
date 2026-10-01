# checkpoint: sub:1 executor — 交付面普查+模板草案（Phase 1 S1）

- 派发: task-v112 Phase 1, executor fresh, 只读普查
- 时间: 2026-10-02
- 里程碑: M1 现状 ✅ / M2 模板草案 ✅ / M3 级联清单 ✅ / 最终结论（见末尾 8 字段块）

## M1 第一部分：交付面现状

### 终验交付段流程与输出结构（SKILL.md）

SKILL.md「终验交付」段 = L147-160（`skills/task-planner/SKILL.md:147` 起 `- [ ] **终验交付**`）。现有流程 8 步：
1. L148 Read `verification.md`
2. L149 逐条复验 VC（每条带证据路径）
3. L150 委派率统计（Rule 25.4，写 verification.md「委派统计」段；低于 floor 0.7 或白名单外 → check-complete.sh exit 1）
4. L151 3-File Gate（Rule 19.5，findings/progress 非 stub）
5. L152 质量门控统计（Rule 26，Q1-Q6 核查+Evidence 抽查 ≥3 条）
6. L153 内容质量门控（writing/research/publish 类 Q3 去 AI 化 + Q4 五维评分卡 ≥4.0）
7. L154 subagent 返回 done 必须 Read 实际产出文件；L155 worktree 合并回（smart-merge-back.sh）；L156 git 提交核验（Rule 27 终验联动）
8. L157 交付结论 `COMPLETE` / `PARTIAL` / `BLOCKED` → L158 退出前跑 `bash scripts/check-complete.sh`（exit 0 正常结束 / exit 1 STOP）

**现状结论：整个终验段没有「向用户输出什么格式」的约束。** L157 只定三态结论词，L158 后会话直接结束——用户看到的交付消息是自由格式（详略取决于执行者当时状态），五要素无结构承载。相关旁证：SKILL.md:42（Code Review Gate 在终验交付前触发）、:136（全部 Phase complete 之后、终验交付之前）——「终验交付」字面引用共 4 处（SKILL.md:42/136/142/144/147/155/156/157-160 区段 + critical-rules.md:240 Rule 26.6/250 Rule 27.5）。

### check-complete.sh 终验输出结构（机器信号面）

`scripts/check-complete.sh`（1053 行）输出全是 `[plan]`/`[fmea-gate]`/`[compliance]`/`[mechanism-profile]` 前缀的机器信号行，非用户面：
- L453 `DELEGATION GATE PASSED (rate=… >= floor=…, violations=…)`（L449 FAILED）
- L750/761 `VC-GATE FAILED/PASSED`
- L850/855 `LEARNING-GATE PASSED/FAILED`（Rule 31.5）
- L895/899 `REFLECT-GATE PASSED/FAILED`（Rule 33）
- L931/935 `SKILL-MODIFY GATE PASSED/FAILED`（Rule 36.6）
- L549-557 `[fmea-gate] OK/⚠/✗`（三档）
- L87/83 `Rule 27.3` porcelain 预检行
- L1038-1041 `[compliance] OK/WARNING (task-v091 A-3 终验抽查…)`
- L1053 `exit $python_rc`（python 全 Phase complete 判定为主退出码）

交付总结的「审查信息」区块可直接指针引用这些信号行（路径 `plans/<task-id>/subagent-state/` + check-complete stderr 记录），不重写。

### verification.md（机器面档案）与用户面交付总结职责边界

`templates/verification.md`（129 行）结构：Goal（L3-5）/ VC 表 ≥5 条（L9-23）/ Phase Gates（L27-67）/ 知识储备符合性核验（L69-73）/ 委派统计复验 Rule 25.4（L75-90）/ 质量门控统计 Rule 26（L92-96）/ Goal Gate（L98-116，含 outcome 三态，L112 `PARTIAL → 列出 + 建议后续`，L116 验证独立性铁律）/ 5-Question Reboot Check（L120-129，Q2「Where am I going」承载「部署同步待用户裁决」类遗留，如 plans/task-v109/verification.md:126）。

边界现状：**verification.md = 机器面档案**（VC 证据链/委派/门控/审计痕迹，消费方=check-complete.sh+主进程簿记+子代理验证）；**用户面交付总结 = 缺位**（无模板、无落点、无字段约束；v107-v109 三轮交付消息均未含独立「风险点」「下一步建议」结构区块，5Q Q2 一句「部署同步待用户裁决」是唯一近似承载）。规划面既有决策锚：task_plan.md Decisions Made（L175）「模板定位=用户面总结，引用机器档案，职责划界防重叠」——本普查证实该划界成立且无现存模板承载用户面。

### 交付实践五要素覆盖度（plans/task-v107..v109，逐要素）

任务说明（Goal 回顾+执行过程摘要）：**总是有（Goal 一句话）/ 常缺（执行过程摘要）**。verification.md Goal 段三任务均有（v107:5 / v108:5 / v109:5），Phase Gates 段有逐 Phase 摘要（v107 L30-79 / v108 L28-61 / v109 L30-58）——但这是机器面，用户交付消息未见「Phase 序列+执行体+关键裁决点」的过程摘要；silent 自动裁决清单（task_plan Decisions Made `silent:` 行，SKILL.md:74 要求交付报告附）在 v107-v109 交付消息中无固定区块承载。

产出清单（文件级路径+变更摘要+验证状态）：**常缺统一表格，信息散落在机器面**。数据源齐备（progress.md 每 Phase「Files created/modified」，plans/task-v108/progress.md:18/30/42/54/70）；v109 变更记录三要素表（plans/task-v109/verification.md:111-117，「what/why/验证」含文件级粒度「memory-hygiene-type.md 230 行+级联 7 文件+MEMORY.md 45.4KB→11.9KB」）是三任务中最接近产出清单的形态；v108 变更记录（v108/verification.md:114-119，「23 文件 +333/-8」粒度较粗）；v107 交付物=report.md 本身（VC-2 六段 42 条，v107/verification.md:13-14）。但「文件级路径+变更摘要+验证状态」三列合一的表格在三任务中均未出现。

审查信息（VC 复验/回归/对齐审查/委派统计/质量门控）：**总是有（机器面），用户面常缺透传**。三个 verification.md 均齐备委派统计 JSON（v107:107-109 / v108:88-90 / v109:86-88）+质量门控统计（v107:114-118 / v108:95-98 / v109:92-95）+Evidence 抽查记录（v107:83-94 / v108:65-75 / v109:62-73）+对齐审查 checkpoint 指针（v107:22 sub:10 / v108:16 sub:7 / v109:22 sub:5）。信息完整但全在机器档案内，用户交付消息通常只带结论不带这些细节——这正是模板「引用指针而非重写」要解决的。

风险点（已知遗留/待裁决/失效条件/回滚方式）：**常缺（三要素中三缺二）**。已知遗留：仅 v107 有（report.md §4 R-01~R-15 待授权修复清单+§5 待裁决 5 项，v107/verification.md:19-20 VC-5——但该任务交付物恰是审查报告，非通用形态）；v108/v109 PARTIAL 分支下「已知缺陷」无字段。待裁决：三任务均只有一行「部署同步待用户裁决」（5Q Q2，v107:145 / v108:128 / v109:126），无独立区块。失效条件：verification.md 模板无此字段，唯一先例在 memory-hygiene-type.md:162（「基线 42 脚本 660/0 — 失效条件:任一新增/删除 selftest 脚本或计数漂移」）——属记忆模板惯例，未进交付面。回滚方式：三任务零提及（git 锚倒是在 verification.md VC 证据里有 merge commit hash，如 v108「5a30382」/v109「d8eb770」，但未按「回滚方式」组织）。

下一步建议（用户可执行行动项带推荐排序）：**常缺（一行遗留提示有，结构化行动项无）**。5Q Q2 的「簿记 commit 后交付；R-01~R-15 待用户授权可开修复轮」（v107:145）是仅存的行动项形态，但无排序、无推荐标注（不满足 Rule 44.1「推荐项排第 1 位标注默认/推荐」）。

## M2 第二部分：templates/delivery-summary.md 模板草案（全文）

```markdown
<!-- delivery-summary.md — 任务交付总结五要素模板（SKILL 终验交付段配套，用户面） -->
<!-- 使用方式: 终验结论（COMPLETE/PARTIAL/BLOCKED）判定后、会话退出前，按本模板向用户输出交付总结；
     需要跨会话存证/独立子代理验收（VC 类条款要求落盘）时，同步落 plans/<task-id>/delivery-summary.md -->
<!-- 定位: 用户面总结 = 引用机器面档案而非重写——数据源指针: verification.md（VC/委派/门控/Goal Gate）、
     progress.md（每 Phase Files created-modified/Error Log）、subagent-state/（独立验证 checkpoint）、
     report.md / memory-hygiene-report.md（如有）；本模板不复述证据原文，只写指针+一句话结论 -->
<!-- 详略标准: 以「用户可独立决策」为准——用户读完不查三文件即可回答: 产出物在哪/哪些可信/风险是什么/我下一步做什么 -->
<!-- 头部形态: HTML 注释指引区（同 batch_report.md/knowledge-brief.md 根模板惯例），无 <!-- template_type: -->
     （非计划模板，不进 check-template-type 白名单，不入 25 模板口径） -->

# Delivery Summary — {task-id}（任务交付总结）

## 1. 任务说明
- **Goal 回顾**: [一行，引 task_plan.md Goal 原文]
- **执行过程摘要**: [Phase 序列 + 各 Phase 执行体（子代理/主进程）+ 关键裁决点（含 silent 自动裁决清单，
  Decisions Made 表 `silent:` 前缀行逐项列出），3-6 行；数据源 = progress.md Phase 段 + task_plan.md Decisions Made]
- **交付结论**: COMPLETE / PARTIAL / BLOCKED [引 verification.md Goal Gate outcome]

## 2. 产出清单（文件级）
| 文件（绝对/仓内路径） | 变更摘要（新增/修改/删除 + 一句话） | 验证状态 |
|----------------------|-----------------------------------|----------|
| ... | ... | VC-N PASS / N selftest rc=0 / grep 锚实测 / Read 复验 |

[数据源 = progress.md 每 Phase「Files created/modified」+ verification.md VC Evidence 逐条指针；
 合并类任务附 merge commit hash（如 5a30382）]

## 3. 审查信息（尽量详细）
- **VC 复验**: N/N 条 PASS（指针: verification.md Goal Gate 段）
- **回归**: <N> 个 selftest / SUM-ASSERTIONS=<数值>（独立子代理 sub:<k>，checkpoint: subagent-state/<k>-<agent>.md）
- **对齐审查**: verdict（APPROVED / CHANGES_REQUESTED + 处置项清单）（指针: checkpoint sub:<k>）
- **委派统计**: check-delegation.sh stats JSON 原文（phases_total/delegated/rate/verdict）+ 白名单豁免判定行
- **质量门控**: Q1-Q6 触发/豁免/未处置计数 + Evidence 抽查 ≥3 条记录（指针: verification.md 质量门控统计段）
- **验证独立性**: 本任务验证动作由 <N> 个全新独立子代理执行，主进程零自测替代验收（2026-09-26 裁决）

## 4. 风险点（必须列举；无则逐项写「无」，禁止整块省略）
- **已知遗留**: [PARTIAL 的已知缺陷 / 未授权零修复的候选清单指针 / 无]
- **待裁决**: [需用户拍板的事项逐项列出（部署同步/D6 授权等），带上下文一句话]
- **失效条件**: [本任务结论何时会过时——如「基线 42 脚本 660/0 — 失效条件: 任一新增/删除 selftest 脚本或计数漂移」；
  逐条给失效判据，消费方看到触发即重验，不盲信]
- **回滚方式**: [git revert <merge-hash> / 分支保留策略 / 备份文件路径（如 MEMORY.md.backup）/ 无]

## 5. 下一步建议（用户可执行行动项，按推荐排序；默认项排第 1 位并标注「推荐」）
1. **[推荐]** <行动项 1 — 一句话可执行，含触发条件>
2. <行动项 2>
3. ...
[多待决项按 Rule 41.5 打包呈报 + Rule 44.1 默认项排序；无待决项时写「本任务无待用户行动项」]
```

### 位置决策评估（templates/ 根 vs variant/）

variant/ 放法（否决）：`check-template-type.sh:17` 白名单动态派生 = `general` + `templates/variant/*-type.md` 去后缀。若 delivery-summary.md 入 variant/，为进入白名单需命名 `delivery-summary-type.md`，「delivery-summary」会成为合法 template_type——语义错误（它不是计划模板，是交付文档模板）；若不入 variant/ 而叫 delivery-summary.md 放 variant/，则既不进白名单又违反 variant/ 目录命名契约（`*-type.md` 统一后缀，v108 全链 17/17 声明形态核对锚）。

根目录放法（推荐）：与 batch_report.md / knowledge-brief.md / shared-tracker.md 同列——根模板 = 辅助区块/档案模板（非计划模板），头部用 HTML 注释指引区，零白名单影响，零 check-template-type 影响。级联代价仅一处：`plan-template-kit/references/template-guide.md:64` 的口径句「另有 knowledge-brief.md（第 6 计划文件）/shared-tracker.md（Rule 30 区块模板）不入此口径」——句尾追加「/delivery-summary.md（交付总结模板）「，25 模板口径数字不变，避免 README.md:23/35/74「5 核心 + 3 辅助 + 17 variant」计数链漂移（v107「43 脚本」数字错误证伪教训：计数锚要实测，新增文件必查全库计数引用面，本任务 grep 实测计数引用面 = README 3 处 + template-guide 1 处 + SKILL:274/368「17 variant」2 处，全部不动 = 零漂移）。

## M3 第三部分：级联清单

1. **SKILL.md 终验交付段指针行**：`skills/task-planner/SKILL.md:157`（`- 交付结论：COMPLETE / PARTIAL / BLOCKED`）与 L158（`- **退出前**：运行 check-complete.sh`）之间插入一行：
   `  - **交付总结（五要素）**：按 `templates/delivery-summary.md` 向用户输出任务交付总结（任务说明/产出清单/审查信息/风险点/下一步建议；数据引 verification.md/progress.md/subagent-state/ 指针不重写；风险点区块必须列举，无则逐项写「无」；需存证时落 plans/<task-id>/delivery-summary.md）`
   插入后 SKILL.md 442 → 443 行；selftest-knowledge-brief.sh T2b 上限 558（`grep -n "558"` 该脚本 L34 区）余量 115 行，不动上限断言。插入为纯指针追加，无既有行改动 → FMEA「锚破坏」兜底=Phase 3 全量回归。
2. **References 表行**：`SKILL.md:314`（`templates/shared-tracker.md` 行）之后追加：
   `| `templates/delivery-summary.md` | 终验交付总结五要素模板（终验交付段消费；数据源=verification/progress/report 引用不重写；非计划模板不入 25 口径） |`
3. **口径句级联（1 处）**：`skills/plan-template-kit/references/template-guide.md:64` 口径句句尾追加「/delivery-summary.md（交付总结模板）」；README.md:23/35/74 与 SKILL.md:274/368 的「17 variant/25 模板/3 辅助」计数**不动**（delivery-summary 走「不入口径」表述，非辅助计数项）——此点与 Phase 2 执行时对齐（若 Phase 2 判 delivery-summary 计入辅助，则改 README「3 辅助→4 辅助」+template-guide「总文件数 25→26」，但推荐不入口径=零计数漂移）。
4. **selftest 断言最小方案（推荐：并入既有，不新增脚本）**：
   - 最小断言 3 条（纯静态 grep，无 fixture）：① `test -f templates/delivery-summary.md` 且五要素区块标题 `grep -cE '^## [1-5]\.' = 5`；② `grep -c 'delivery-summary' SKILL.md ≥ 2`（终验段指针行 + References 行）；③ `grep -q 'delivery-summary.md' plan-template-kit/references/template-guide.md`（口径句在位）。
   - 落点选项 A（推荐）：并入 `selftest-template-lifecycle.sh`（Rule 34 模板生命周期守护，dep_anchors 已含 templates 面，加 1 组 T-用例约 6 行）——selftest 脚本数 42 不变，基线「42 selftest 660/0」零漂移（「SUM-ASSERTIONS=660」断言值需 +3 更新为 663，若存在 660 字面锚——v107/v109 verification 样例中 660 属任务基线记录不入仓库，仓库内 660 锚需 Phase 2 grep 实测）。
   - 选项 B（备选）：新增 `selftest-delivery-summary.sh`（3 断言 + registry.tsv 自登记 1 行，自 42→43）——语义更独立但触发「42 脚本」全库口径漂移（task_plan VC-1「全量 selftest 42」+ memory-hygiene-type.md:115「42 脚本」+ 各轮基线），级联面更大，不推荐。
5. **check-complete.sh**：不动（计划 scope_files 明确排除脚本逻辑改动，L46「默认不动脚本」）；其机器信号行（L453/L761/L850/L895/L1038 区）已足以支撑模板第 3 区块「审查信息」的指针引用。
6. **check-template-type.sh / init-session.sh**：零影响（delivery-summary 非 template_type、非计划建档文件，init-session.sh 六文件循环 L138 区不动）。

## 最终结论

status: done
acceptance: 3/3 pass — ①三部分逐项结论（M1 现状=终验段 8 步流程+check-complete 信号行+职责边界+五要素逐条覆盖度，均有 file:line；M2 模板草案=五区块全文+头部形态+根 vs variant 利弊；M3 级联清单=SKILL:157 插入行+References:314 行+口径句 1 处+selftest 并入方案+脚本零改动清单）②模板草案完整（五区块+每区块填写指引+数据来源指针+详略标准「用户可独立决策」）③级联清单含模板位置决策建议（根目录，否决 variant/，理由=白名单派生契约+命名后缀契约）
files: 无修改（只读普查，+0/-0）；checkpoint 新增 /mnt/data/dev/task-planner-skill/plans/task-v112/subagent-state/1-executor.md；findings.md 追加 1 段；progress.md 追加 1 行
evidence: skills/task-planner/SKILL.md:147-160（终验交付段 8 步，L157 交付结论+L158 退出前 check-complete，其间无用户面格式约束）; check-template-type.sh:17（白名单=general+variant/*-type.md 动态派生）; template-guide.md:64（25 口径+不入口径先例句）; plans/task-v107/verification.md:105-129 vs v108:86-112 vs v109:84-118（委派/质量门控/5Q-Q2 三任务对照：风险点与下一步建议区块缺失实证）; selftest-knowledge-brief.sh:34（T2b 上限 558 余量 115）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v112/subagent-state/1-executor.md (status: done)
findings_written: plans/task-v112/findings.md #### [sub:1-executor] 交付面普查
blockers: none
confidence: HIGH
