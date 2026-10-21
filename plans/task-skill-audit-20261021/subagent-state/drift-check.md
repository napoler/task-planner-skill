# 终验前偏移检查（Rule 15/61 载体）— task-skill-audit-20261021

- 检查时间：2026-10-22（检查点落盘）
- 检查范围：user-session-log.md #1~#3、task_plan.md（需求区/Goal/VC/不变量/Phases/变更标注表）、findings.md、progress.md、verification.md、audit-report.md、revision-proposals.md、subagent-state/S1-S9、ALIGN-review、DOCFIX-critic
- 只读约束：本次检查除本文件外未写任何文件；未执行 git 写操作

## 三态判定：⚠️DRIFT（收口前偏移，非方向性跑偏）

**判定理由**：R1/R2/R3 三条诉求均有对应产出与可独立复现的证据锚，写面零越界；但**终验状态自报超前**（Phase 4 / G4 标 complete 而归档未做、check-complete 无 exit 0 记录）、**三计划文件状态互斥**、**VC-3/VC-5 证据链单点**、**一条提案拟改写用户逐字记录**。不构成方向漂移，但按 VC 字面不得据此宣称"终验已过"。

## 一、对齐面（已核验成立）

| 诉求 | 产出 | 独立复核证据 |
|------|------|--------------|
| R1 系统性审查 + 流程 skill 精准校正审查 | audit-report.md 236 行 / `grep -n '^## '` → §0,§1~§8 + 附（9 节）；findings.md 七节；S1-S9 九份检查点 | 五维（结构/规则/脚本回归/部署簿记/派发契约）齐备，另加 §1 事实编造面（R3 增量） |
| R2 报告 + 修改方案 | audit-report.md、revision-proposals.md（110 行） | `grep -cE '^\| RP-[0-9]+'` = **31**，RP-01..RP-31 连续无缺号；P0 15 / P1 15 / P2 1 与报告 §0 分级汇总一致 |
| R3 视频生成"造谣"类缺陷取证与修正 | 报告 §1.1 时序表 / §1.2 D-F1~D-F6 / §1.3 固化 5 落点 / §1.4 G-01~G-05；方案 RP-01~RP-04 + RP-30/RP-31 | 一手证据全部独立复现（见下） |

**R3 一手证据独立复现（本次实查，非引用）**
- 声称原文：`sqlite3 file:...db.sqlite?mode=ro "select data from part where id='part_mvia2iou_0657e219-...'"` → 全文含「物理约束：现在 23:30，距 00:00 仅 30min，约束 4 禁今晚发起新创建 → 重抽只能明日 00:00 后…」；该 message `msg_mvi9riyb_…` role=assistant / modelId=fast；`time.created=1792596654515` → `date -d @1792596654` = **2026-10-21 23:30:54 CST**（与报告锚一致）
- 真实额度：`/mnt/data/dev/videop1/tmp/_gen-budget/video-seconds-20261021.json` = `{"used": 198}`，mtime **2026-10-21 23:03:58**（早于断言 27min）
- 子代理回执：`~/.zcode/cli/agents/session_a40eae…/agent_ce1928bc*/output.txt:45` = 「额度：… used=198（本任务 +18s，剩余 302s 随 00:00 清零）」
- 规则真实存在：`/mnt/data/dev/videop1/AGENTS.md:84` 含「距 00:00（北京时间）清零 ≥ …+30min」约束 4
- skill 侧根因：`grep -cE '额度|配额|资源状态|推迟|一手证据' skills/task-planner/SKILL.md` = **0**（G-02 成立）
- 卫星条款在位：`skills/task-discipline/references/critical-rules-discipline.md` :235(54.1)/:237(54.2)/:239(54.3)/:241(54.4)，措辞覆盖本案
- 规则真值：`grep -rhoE '^#{2,4} [0-9]+[ .]' skills/*/references/critical-rules*.md | sort -u | wc -l` = **89**，加 `## Rule 80`（不入 `^### N` 枚举，A-08 所述格式异常） = **90**，与 A-02「真值 90」一致

## 二、越界检查（通过）

| 检查 | 命令 | 结果 |
|------|------|------|
| HEAD 提交内容 | `git show --stat --oneline HEAD` | c79eb8a 仅 `plans/task-skill-audit-20261021/**` **23 文件**，零 skills/**、零 scripts/** |
| 仓内未提交面 | `git status --short` | 仅 3 个 skills/** M + `plans/.rule-reservations.jsonl` M + 计划目录内 `.dispatch-inflight` M；无本任务对其他目录的写痕迹 |
| 在途归属 | `ls -l --time-style=+%Y-%m-%d_%H:%M:%S` | skills/SKILL.md、references/critical-rules.md、scripts/selftest-requirement-coverage.sh mtime **2026-10-21 11:30:02**；plans/.rule-reservations.jsonl **11:32:33** —— 均早于本任务建计划（HEAD 2448e01 @ 21:27 / init 21:45），判为他方在途，非本任务越界 |
| 修改未执行 | 同上 | `skills/**` 无本任务期间变更；方案 RP-01~RP-31 全部为提案文本，未落地 |
| videop1 只读 | `git -C /mnt/data/dev/videop1 status --short` | 显示 videop1 自身在途变更（ep10/ep03/plans 状态）；本任务无写入路径指向该仓 |

## 三、偏移项（7 条，全部已验证）

### D-1 [重要] Phase 4 / G4 自报 complete，但归档与 check-complete exit 0 无证据
- 位置：`plans/task-skill-audit-20261021/task_plan.md:99`、`:208-216`；`.../verification.md:61-69`；`.../audit-report.md:116`
- 原文：G4「两份文档落盘+六 VC 全过+归档+交付总结 | 命令：`bash …/check-complete.sh <plan-dir>` exit 0 + archive-plan 走通 | complete」
- 实测：task_plan.md:208-214 Phase 4 七项全部 `- [ ]` 未勾且 `:216` Status: **in_progress**，与 verification.md:69 `Status: complete` 互斥；`ls plans/archive/ | grep -i 'audit-2026'` → rc=1（未归档，计划目录仍在 `plans/` 根）；报告 §3 自记 `check-complete.sh` → **exit 1**「Rule 27.3 violation」
- 原因：完成声明超前于其自身判据证据

### D-2 [重要] 交付文档声明 progress.md「仍为空模板/待回填」，与实测相反
- 位置：`audit-report.md:30`、`:32`；`revision-proposals.md:101`、`:103`
- 原文：「progress.md 的 Test Results 段（当前仍为空模板，数字对照待主进程回填）」
- 实测：progress.md:22-46（Phase 1/2 Test Results 表）与 :78-85（Phase 4 五项 VC 实测表）均已回填
- 原因：VC-3/VC-5 证据行是过期表述，报告自述证据状态与三文件事实矛盾

### D-3 [中] VC-3 / VC-5 判据要求"两点对照"，实际只有单点证据
- 位置：task_plan.md:76（VC-3「progress.md Test Results 段两行数字对照」）、:78（VC-5「两次 git status diff 对照（执行前基线已留档 progress.md）」）；verification.md:22-24
- 原文：「执行前后 `git status --short` 对照，本任务零改动仓内既有文件」
- 实测：progress.md 仅记 1 次回归（Phase 2 92/92）、1 次 git status，无执行前基线文件清单；VC-5 以「mtime 保持 10-21 11:30」单点论证替代前后对照
- 原因：VC-5 字面未满足；VC-3「审计动作零新增 FAIL」无第二次回归可证

### D-4 [中] G2 判据「无未复核 P0/P1」未达标却标 complete
- 位置：`task_plan.md:97`；`findings.md` 全文；`audit-report.md:199`
- 原文：G2「findings.md 各维发现区有 [verified] 或 [fp] 标记，无未复核 P0/P1 | complete」
- 实测：`grep -n 'verified\|\[fp\]' findings.md` → **0 命中**（无任何标记）；报告 §7 自认 B-04/B-05/C-06（P1）不在 S7 22 条清单内
- 原因：验收判据与落盘形态不一致，complete 属自我判定

### D-5 [中] RP-31 拟改写用户逐字记录，且锚点行号错
- 位置：`revision-proposals.md:80`
- 原文：「`videop1/plans/task-videop1-quotafact-001/{user-session-log.md:9; findings.md:20-21; …}` … 把「谎称没有额度」统一改为与一手原文一致的表述」
- 实测：该 user-session-log.md 文件头自述「append-only 只写不改」；`:5` 才是用户原话「…明明在视频额度充裕时候确造谣说没有额度要等到明天生成」，`:9` 是用户引述的「物理约束：现在 23:30…」原话 —— 拟改对象是**用户逐字记录**，与只写不改/逐字抄录纪律冲突；且报告 §1.3 把该文件列为"幻觉固化落点"属误判（内容为用户原话引用，非 assistant 固化）
- 原因：该 P0/P1 提案按字面不可执行（改用户原话=篡改证据），应只指向 findings/experience/AGENTS 判例等转述面

### D-6 [轻] 报告执行构成数字重复计数
- 位置：`audit-report.md:6`
- 原文：「9 个子代理单元（S1-S9）分三组并行 + 1 个独立复核单元（S7）」
- 实测：Handoff 登记表数据行 `grep -c '^| [0-9] |' task_plan.md` = **9**（S7 已含其中），实际单元总数 9 非 10

### D-7 [轻] 报告审计基线 HEAD 过期
- 位置：`audit-report.md:4`
- 原文：「审计基准：主仓工作树 HEAD `2448e01`」
- 实测：`git log -1 --oneline` = **c79eb8a**（本任务 03:05 提交，仅含计划目录）；基线标注未随提交更新（结论不受影响，因提交内容仅 plans/）

## 四、负结果（预期问题但未发现 / 已排除）

1. **未发现 skills/** 或 scripts/** 在本任务期间被写入**：HEAD 提交仅计划目录；4 个在途 M 文件 mtime 早于建计划时间 2-8 小时。
2. **未发现 R3 证据造假或错锚**：初次按 120 字符截断观察曾疑似 `part_mvia2iou_…` 内容不符，全量 dump 后确认原句在该 part 尾部（464 字符文本），**锚点正确**，撤回该疑点。
3. **未发现"结论无锚"**：抽查 8 处关键锚（EXEMPT_DANGLING:41、check-dispatch.sh:126 三字段、SKILL.md:195 区间 69-76、discipline:235/237/239/241、templates/task_plan.md:497/:502、selftest-verification-gate.sh:73 `-ge 0`、check-complete.sh:1747 精确匹配 verify_done、INDEX.md:8/:9 列数 8 vs 6 且 grep 本计划 0 命中）全部复现。
4. **未发现用户诉求被替换/缩水**：R3 用户措辞"造谣说没有额度"被报告修正为"调度硬闸转述"，属带负结果的证据化修正（会话树「没有额度」检索 0 命中已在 S8/report 标注），非曲解诉求；R1/R2 未删项。
5. **未发现 videop1 被本任务写入**（归属未验证项）：videop1 quotafact 计划文件 mtime 00:02-01:15，内容为 `/task-planner 必须修正缺陷确保不会再次犯错` 用户请求与 `/task-planner` 初始化模板字节数一致（knowledge-brief 7471B / notepad 2021B 与本计划同尺寸），`.plan-attestation` 的 `attested_by_sid=` 为空 → **归属未验证**，倾向 videop1 会话自建（当时该会话运行至 01:42）。

## 五、验证摘要

- 总发现 7 / 已验证 7 / 通过率 **100%**
- 每条发现均含：位置（file:line）+ 原文（≥10 字符）+ 推理 + 置信度（D-1~D-7 均 HIGH；第五节归属项 MED 并标未验证）

## 六、终验前建议动作（不代执行）

1. 先把 Phase 4 复选框与 G4/verification.md 状态对齐真实进度（要么补归档+check-complete exit 0 记录，要么回退为 in_progress）；
2. 修 D-2 过期表述（VC-3/VC-5 证据行），并补 VC-5 执行前基线清单与执行后二次对照；
3. 收窄 RP-31 目标面，移除 `user-session-log.md`（用户逐字记录）并修正行号至 `:5`；
4. D-6/D-7 为文本订正，可随 D-2 一并处理。
