# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
  <!-- Rule 71（task-v158）：事实结论必带源锚；模板空段=显式占位合法；写入前过五问（见 critical-rules.md Rule 71） -->
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

#### [sub:s1-explore] videop1 任务时间线与回路（task-videop1-voicerivet-001）

**时间线骨架（锚=progress.md，基准 +08:00）**
- 05:47 用户 /workflow 下达「音色铆钉+固定提示词模板」（progress.md:15）→ 05:52 init 建计划+sid 错位修正（L17）→ 05:54 task-planner hook 拦 draft 写入（L54）→ 05:58 CreateWorkflow 3 次拒（L20/L53）→ 05:58 后 delegation hook 拦主进程 Edit+Write、executor 子代理整文件重写后返回空、主进程 grep 复验（L55/L56）→ 06:37:23 计划 attest（.plan-attestation:3）
- 派单窗口 21:58→09:40 推断为 UTC；文件内起点 05:47+08=21:47 UTC 早于窗口、终点 17:40+08 无文件内锚=未验证

**检查点 7 个（非派单 6 个）：主题+时间戳**
- 01-explore-template-area.md：模板区勘察（分区标记/VOICE-LOCK/参考图写法，L1/L100 必答五问）；无时间戳
- 02-explore-rule-area.md：规则区勘察（skill 门/gen.py 门/gap 1-4，L1/L127/L171 总结）；无时间戳
- 03-explore-series-area.md：系列现役区（ep01-prompts 23 段锁块+bible 鸽群悬置+jipin 10 集，L4/L83）；day=2026-10-13
- 04-design.md：设计定稿（音色库/模板/charBlockSpec/area A-D/门参数，L1/L442 日落 2026-11-12）；无时间戳
- 05-implement-A.md：区域A prompts/ 5 件+自检全 PASS+3 条待裁（L4/L41/L88）；无时间戳
- 05-implement-B.md（派单未列）：区域B gen.py 三新门+PY_COMPILE_OK+门测试全过（L5/L32/L35）；day=2026-10-13
- 05-implement-C.md：区域C skill 层 6 件（D23/L5-3/判例17）+6 条待裁（L5/L120）；无时间戳

**Error Log 四项拦截事实（progress.md L53-56）**
1. CreateWorkflow 拒：「needs the dynamic-workflows skill loaded... Call the Skill tool」，本会话无 Skill 工具，3 次复证=登记 D6 三选项待裁（L53）
2. draft 写入拦：task-planner hook「plans/ 外禁写」，sid 错位→set-active-plan --sid 修正（L54）
3. 委派路由拦：delegation hook 拦主进程 Edit 1 次+Write 1 次（.dwf.ts 判为业务代码）→路由 executor 子代理整文件重写（L55）
4. 子代理空返回：executor 落盘但返回无输出→主进程 grep/wc 独立核验后才采信（L56）

**耗时/浪费回路（6 条，各附锚）**
1. 主执行通道不可达降级：R4 指定 /workflow dynamic-workflows（task_plan.md:15），本会话 Skill 工具缺失致 3 次复证全拦（progress.md:20/D5 task_plan.md:183）→转 Agent 子代理编排产出 7 检查点+44KB 设计稿；D6 三选项待裁（task_plan.md:184）
2. 单任务 8 次子代理派发+检查点约 147KB：3 勘察/1 设计/3 实施（subagent-state/ 7 件）+1 次 executor 重写 dwf.ts v2（progress.md:22「主进程 Edit/Write 被 delegation hook 拦截→按路由派子代理」）；04-design 44KB 被 3 实施员各自全文重读；待裁项共 15 条（05-A L88-94 三/05-B L41-48 六/05-C L120-127 六）→复核阶段返工风险
3. 同一方法多次重试+hook 拦截回炉 3 轮：CreateWorkflow 3 次（L20/L53）+draft 写拦 1（L54）+委派路由拦 2（L55）+空返回复验 1（L56），全部在主上下文消化
4. scaffold 未填即开跑：Code Review 配置全占位（task_plan.md:72-74「[登记]/[询问点]」）、工具选择表示例未填（L98-99）、委派统计空白（L164-168）、Subagent Handoff 登记表仅 1 行空「queued」（L174）而实际 8 次派发 0 回填；五阶段段全 pending（L106/114/122/129/136）而 progress.md:11 已按另一套「Phase 1: 勘察+工作流设计+提交」执行=计划骨架与实际两套 Phase 体系
5. 设计稿内部漂移：05-A L90 节号漂移（设计「§2.3」vs 承载件「§3.1」）；05-C L116/L124 设计 #8.3 要求 video-qc SKILL.md 含 [VOICE-LOCK] 字面但 #6③ 卡全文无（自相矛盾）；L122 RI3 L89 未同步 D23
6. 回填断档：videop1 任务 findings.md L19-21「## Research Findings」仍空「-」，7 检查点结论未按 Rule 19.1 回填，交接依赖 44KB 设计稿全文重读

#### [sub:s2-explore] perf-diagnosis 已优化项与遗留缺口 + 当前固定开销清单 + 可降频点（2026-10-13）

> 计数口径勘误：任务书称「13 项优化清单」，report.md §5 实列 12 项 Change（report.md:246-352「## 5. 优化方案（逐项）」Change #1-#12；TL;DR report.md:24 亦称「12 项优化已实施」）。以下按 report 实际 12 项逐条。
> 落地状态判定：report.md:388 称 worktree「未合并回 master（留给主进程）」，但主仓实测已含全部 12 项改动标记（grep 锚见下），= 已合入/已应用（疑似 smart-merge-back 通道），report 该状态表述已过时。

**A. 12 项优化逐条一句话+状态（主仓落地锚）**
1. Change #1 init-session.sh auto-tier 新增 trivial 代码修复第四条件分支（单文件代码 ∧ ≤3 行 → mini+L0+TRIVIAL_CODE_TIER）——已落地：init-session.sh:410-444
2. Change #2 task-plan-init.cjs 轻量档关键词检测（简单修复/就改一行/fix/typo 命中即跳过触发提示，fail-open）——已落地：task-plan-init.cjs:29,52,105-111
3. Change #3 check-delegation.sh 无活跃计划 ∧ Edit≤3 行 ∧ 单文件 ∧ 非保护区 trivial 直通前置分支——已落地：check-delegation.sh:299
4. Change #4 check-complete.sh L0 GATE ① Total 行口径注释澄清（仅注释）——已落地：check-complete.sh:1555
5. Change #5 UPS smart 注入 prompt 类型门控（短 prompt 不含 Goal 关键 token 跳过注入，default off 需 opt-in）——已落地：zcode-userpromptsubmit.sh:84-111 + config.json:443
6. Change #6 [plan-note] D 类文案邻近行引用例外（第 N 行/继续/接着 → 归 B 类）——已落地：zcode-userpromptsubmit.sh:230-243
7. Change #7 trivial 档 7 文件缩减为 3 文件（user-session-log 改按需）——已落地：init-session.sh:536-540,616-618,727-748
8. Change #8 PostToolUse 6 次 jq 读 config.json 合并 1 次多键 @tsv（drift-rhythm 降频因破坏 DCE-22/23 N1 投递节奏已回退）——已落地（jq 合并）：zcode-posttooluse.sh:206-216
9. Change #9 attest-plan.sh 门结果缓存（SHA-256+门控配置为键；命中 0.042s vs 未命中 9.29s，report.md:402/413）——已落地：attest-plan.sh:17,75,91-95
10. Change #10 SKILL.md 投诉响应协议 + L0 通道定期边界审查（每 10 任务或每月）+ Rule 38.7 验证锚更新——已落地：SKILL.md:147-152
11. Change #11 run-selftests.sh top-5 重脚本并行化（selftest_heavy_concurrent default off）——已落地：run-selftests.sh:77-81 + config.json:449
12. Change #12 lib/install-stub.sh 安装副本同步改 rsync -a --delete + dry-run + install.log——已落地：lib/install-stub.sh:262-300
回归：全量 77/77 PASS=0 FAIL（report.md:411）。

**B. 遗留缺口（report.md:457-468 §8.3/8.4 + 实测）**
- G1：L0 边界定期审查只有触发条款，无机器执行/账本（SKILL.md:152「每 10 个任务或每月…审查留痕于 findings.md」无 cron/钩子载体）
- G2：drift-rhythm 状态读写降频已回退（zcode-posttooluse.sh:81-84），每调用仍 3×sed+1×写全量发生
- G3：Change #2 轻量档检测依赖 SessionStart stdin 携 prompt 字段，平台是否携带未验证（report.md:459，fail-open 留空）
- G4：Change #5/#11 门控 default off（zcode-userpromptsubmit.sh:92；run-selftests.sh:81），实际生效需用户 opt-in
- G5：worktree 合并状态表述与主仓实况漂移（report.md:388 vs 主仓实测已落地）

**C. 当前固定开销清单（逐项=触发条件+脚本路径:行号+量化；时延数值源 report.md:87-94 实测）**
C-01 SessionStart 每会话：zcode-sessionstart.sh:13 调 task-plan-init.cjs（写 side 哨兵 :99 + sidmap :128-133 + 触发条件 4 行文本注入 :101-116 + 轻量档检测 :52）；:18-28 读 plans/INDEX.md 待处理区 top-3 注入 [task-resume]（**跨任务 INDEX 噪音源**，每会话无条件）；:33 set-active-plan.sh gc
C-02 UserPromptSubmit 每轮：zcode-userpromptsubmit.sh:43 resolve-plan-dir.sh 子进程；:52 mtime>86400s 早退；:55 outcome COMPLETE/BLOCKED 静默；:65 attest-plan.sh --verify 每轮 1 次（缓存后 ~0.042s）；:124-167 smart 注入块每轮 task_plan.md 双遍全文 awk+progress.md tail-5（~1000-1500 字符/轮，report.md:177；唯一闸门 Change #5 :92-111 default off）；:229 [plan-note] prompt_note_interval=10（config.json:237）；:205-223 每轮写 .session-owner + .active_plan_side/<sid>.active_plan 指针；:249 每轮 check-conflicts.sh 子进程（grep 🔴|⚠️ head-5）。有活跃计划 0.22-0.26s/轮，无 0.07-0.08s（report.md:91-92）
C-03 PostToolUse 每次工具调用：zcode-posttooluse.sh:49 resolve-plan-dir.sh；:29-35 工具=Agent 时清 .dispatch-inflight；:70-117 drift_rhythm_check 每调用 3×sed+1×写 <plans>/.drift-rhythm/<sid>.state（:81-84 降频已回退）；:180-195,200 outcome 3×grep；:208 1×jq 多键 @tsv 读 6 阈值；:230-246 /tmp/task-planner-hook-<sid>.state 9 字段读；:376 9 字段写
C-04 提醒注入触发条件（冷却后仍周期性命中）：P1 task_plan.md 15min 未更新 → [plan-sync] 强制回写+sync-todos.sh --index（zcode-posttooluse.sh:255-262；config.json:202,213-217 冷却 10 次调用）；P2 findings.md 20min → [plan-compass]（:271-297；config.json:219-224）；P3 progress.md 25min → [plan-compass]（:299-325；config.json:231-236）；P4 每 10 次调用 → [plan-sync] 轻量同步+计数清零（:328-332；config.json:196-201）
C-05 三连注入：drift-rhythm due 每 N=10 次工具调用（TASK_PLANNER_DRIFT_RHYTHM_N，默认 10）→ [drift-rhythm]+[context-pressure]+[judge]（zcode-posttooluse.sh:341-373）
C-06 自动重锁：Write/Edit/MultiEdit 命中活跃计划 task_plan.md → attest 重锁（zcode-posttooluse.sh:119-165；缓存 0.042s/未缓存 9.29s）
C-07 periodic-review.sh 为 Rule 65 手动工具（每 8 次工具调用软触发，config.json:335-339 periodic_review_interval_calls default 8；critical-rules-discipline.md:352/364/366 机器守护/高危信号档），脚本本体无 cron/自动循环驱动器（负结果：scripts/ 下无定时入口，负结果锚=grep "periodic-review" 仅命中 selftest+文档）
C-08 量化（report.md:87-107 实测）：有活跃计划 PostToolUse 0.34-0.36s/调用；20 次调用≈7s 纯 hook+2 组注入；50 轮对话 smart 注入累积≈55KB（report.md:178）；简单任务端到端固定≈14s（report.md:120）

**D. 可降频/限频点（≥3，每条附文件锚；R3 锚=task_plan.md:16「每隔多少步才限制更新一次」）**
D-1 UPS smart 注入每轮无条件（task_plan 双遍+progress tail，zcode-userpromptsubmit.sh:124-188）：现成开关=启用 smart_inject_type_gate（config.json:443 default off→on）；进一步=改为「每 N 轮 / 无变化则跳过」（Goal/Next Step 两行文本不变时免注入，:180-186 拼装已具备 diff 判据基础）
D-2 提醒周期参数按 plan_tier/execution_lane 分档：config.json:196-242 全部阈值对 mini/L0/L1 统一（15/20/25min+10 calls+10 prompt），低复杂度任务 15min 即被 [plan-sync] 打回写；限频=「每隔多少步才更新一次」的机器化落点（加 tier 感知周期，机器断言=grep config 键存在+selftest 守护）
D-3 INDEX.md 全量重算：sync-todos.sh:206-291 write_index 恒全量重算全部 plans/*/task_plan.md（v3 口径注释 :176-178 明示增量方案已删）；触发点=[plan-sync] P1 提醒文案（zcode-posttooluse.sh:261）+ SessionStart [task-resume]（zcode-sessionstart.sh:18-28）；降频=仅当本任务 Phase 状态变更才重算 + 无待处理任务时 SessionStart 跳过 [task-resume] 注入（:21 pending 空则无注入已存在，剩余噪音=top-3 摘要文本本身）
D-4 drift-rhythm 全量降频被回退（zcode-posttooluse.sh:81-84），替代=合并 3 次 sed 为 1 次读（单 awk）+ 9 字段 /tmp state 9 次 cut 合并 1 次 awk（:230-246）——纯进程孵化优化零逻辑变化，与 DCE-22/23 N1 节奏守护（count 仍每调用 +1）不冲突
D-5 check-conflicts.sh 每轮 UPS 无条件跑（zcode-userpromptsubmit.sh:249）：可加节流（如 N 轮 1 次或仅计划文件 mtime 变化后跑）

**负结果报告**：检索 scripts/ 内 "periodic-review" 触发链，未见任何 cron/定时驱动器（grep 命中仅 selftest-periodic-review.sh + critical-rules 文档 + .backup 旧副本）；task-plan-init.cjs 本体无 resume 列表注入（report.md §2 所述「注入 3 个未完成任务 resume 列表」实际载体=zcode-sessionstart.sh:18-28 [task-resume] 段，非 task-plan-init.cjs）。


#### [sub:s3-code] CA-1/CA-2/CA-3 六项 Edit 落地 + 孤立 fi 语法修复 + 自检全绿（2026-10-13）
worktree=/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt，唯一执行依据=s3-code-editspec.md（E1-E6 全落盘）。
- E1 config.json: smart_inject_type_gate default off→on（:446）+ 新键 smart_inject_interval（默认 20，N=0 恢复每轮，:449）+ light_tier_interval_multiplier（默认 2，:455）；jq -e 通过（additionalProperties:false 不破）。
- E2/E3 zcode-userpromptsubmit.sh: 头部注释限频口径（:3-12）+ CA-1 内容限频块（:117-143）：plan mtime 变更立即注入；未变更每 20 轮兜底；状态 /tmp/task-planner-ups-inject-<sid>.state；attest --verify 每轮不变。
- E4/E5 zcode-posttooluse.sh: drift-rhythm 2×sed→1×awk 单读（:87-91）；/tmp state 8×cut→1×awk（:244-246），9 字段旧 5 字段兼容（case 兜底 0）。
- E6 zcode-posttooluse.sh: CA-2 tier-aware 提醒周期（:216-226）：plan_tier: mini ∨ execution_lane: L0 → plan_min/findings_n/progress_n ×mult（默认 2=30/40/50min）；fail-open mult 非数字/0→1。
- 异常处置：首跑 bash -n UPS 失败=文件内孤立 fi（:207，index/HEAD 版本均无、非 spec E1-E6 内容；spec 首行明示 awk-guard 段已由主进程先行落地）。git stash 对比确认无配对 if，删该 1 行后全绿。
- 冒烟：CA-1 逐轮 skip=0/1/0/1 符合注释口径；CA-2 mini→30/40/50、std→15/20/25 不放大。
- 证据：bash -n UPS/PTU→SYNTAX_OK；jq→JSON_OK；git diff --stat=3 files +70/-18；git status 仅 3 目标文件 modified。

#### [sub:s4-code] 17 个 selftest config 键数守护断言 44→46 级联 + 全量回归 77/77 全绿（2026-10-13）
worktree=/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt，唯一执行依据=s4-cascade-editspec.md（E1-E17，E8/E14 各 2 处，共 19 个 Edit，全落盘）。
- 17 个 selftest 的「零新 config 键」守护断言硬编码 44→46（task-v172 合法新增 smart_inject_interval+light_tier_interval_multiplier 2 键，先例=task-perf-opt 42→44）：reliability-institution/agent-coverage/requirement-grading/decision-drift/four-file-dataflow/media-dispatch/ask-default-timeout/capability-persistence(×2)/context-pressure/self-resolution/media-agents/requirement-coverage/session-log/iteration-persistence(×2)/workflow-orchestration/lane-advancement/tool-selection。
- 证据：worktree config.json 实测 `jq '.properties|keys|length'=46`；残留 grep（`keys" = "44"` / `-eq 44` / `expect=44` / `=44（`）仅命中脚本头部注释行（非 spec 枚举 Edit，未动）；断言行全部命中 46。
- 全量回归：`bash skills/task-planner/scripts/run-selftests.sh` → `Total: 77 PASS=77 FAIL=0 (run=77 reused=77)`，逐脚本 rc=0 FAIL=0。

#### [sub:s5-code] CA-7/CA-8 六文件 Edit 全落盘 + 全量回归 77/77 全绿（2026-10-13）
worktree=/home/terry/task-planner-skill-worktrees/task-v172-skill-efficiency-opt，唯一执行依据=s5-composite-review-editspec.md（E1-E6，全落盘）。
- CA-7 复合审查=用户原话锚接入 drift-checker 主体路径：drift-checker.md SOP 第 1 步「读计划」→「读计划+原话」（必读 user-session-log.md 全原话条目，判定口径升级=与用户原话不一致才算 DRIFT，Rule 80.4）；三锚段 Rule 64.4 ① Goal 原文锚 → 用户原话锚（user-session-log.md 全原话+task_plan R 条目双源，原话优先）；zcode-posttooluse.sh `[drift-rhythm]` emit 行追加「复合审查=读 user-session-log.md 全原话对照当前执行，偏移→打回重做/修正，Rule 80.4/61」指引（emit 结构/变量零改动）；selftest-drift-check-subagent.sh 新增 DCS-21 守护断言（grep user-session-log），头注计数 20→21。
- CA-8 纠偏执行率机器可观测 DRIFT-GATE：check-complete.sh DELEGATION GATE 段后新增自包含块——触发=≥2 个 `**Status:** complete` Phase ∧ subagent-state/ 无 `*drift*` 检查点；默认 stderr warn 不改 exit 码（保持 77/77 基线）；`TASK_PLANNER_DRIFT_GATE_ENFORCE=enforce` 且 outcome 非 BLOCKED → 追加「⛔ 应返工补派 drift-checker」升级文案（仍不 hard-fail）；L0（l0_gate_open）/plan_tier=mini 跳过；fail-open（目录缺失/变量缺失静默跳过）；零新 config 键（env var 方案）。selftest-check-drift.sh 新增 CD-07 守护断言（check-complete.sh 含 `DRIFT-GATE` ∧ `TASK_PLANNER_DRIFT_GATE_ENFORCE`）。
- 证据：`bash -n` 双脚本 → SYNTAX_OK_PTU/SYNTAX_OK_CC；selftest-drift-check-subagent.sh `Total: 21 PASS=21 FAIL=0`；selftest-check-drift.sh `Total: 7 PASS=7 FAIL=0`；全量 run-selftests `Total: 77 PASS=77 FAIL=0 (run=77 reused=0)` 逐脚本 rc=0 FAIL=0。
- 无回归失败；负结果说明：compgen 初版在 `set -u` 语境下改用 ls|grep 探测（目录缺失同判无检查点，fail-open 语义不变）；未动 spec 枚举以外的任何文件；config.json 键数不变（CA-8 明确禁新键）。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->

| RC | 根因（证据锚） | 优化（CA 对应） | 预期效果 |
|----|--------------|----------------|---------|
| RC1 通道/复杂度错配 | videop1 为 standard/L2 通道跑五阶段+8 子代理，tier 检测 fail-open（S1 回路 1/4） | CA-6（前置探测+快速失败）+ CA-2（分档降载） | 低复杂度任务走轻通道 |
| RC2 通道不可达无快速失败 | CreateWorkflow 无 Skill 工具仍重试 3 次（videop1 progress.md:20/L53） | CA-6 | 1 次探测即登记缺口 |
| RC3 hook 每轮/每调用开销复利 | UPS 0.22-0.26s/轮+1-1.5KB 注入；PostToolUse 0.34-0.36s/调用（S2 C-02/C-03，report.md:87-107） | CA-1（无变化跳过+gate on）+ CA-3（进程孵化合并） | 50 轮注入 55KB→仅变化轮注入 |
| RC4 提醒周期不分档 | 15/20/25min+10calls 全 tier 统一，低复杂度被 [plan-sync] 频繁打回写（S2 C-04/D-2）= R3 命中 | CA-2 | 低复杂度任务提醒间隔 2× |
| RC5 只读子代理契约不适配 | Explore 无写工具但契约强制 checkpoint 落盘→主进程代写往返（S1/S2 blockers，本次 2 连撞） | CA-4 | 消除此类误拦 |
| RC6 跨任务噪音与全量重算 | SessionStart 无条件注入 INDEX top-3（7 个 stale in_progress）+ sync-todos INDEX 恒全量重算（S2 C-01/D-3） | CA-5 | 会话启动零噪音/按需 |


## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
<!-- 2026-10-10 task-v158 Rule 71.3：无多模态信息时合法形态=显式占位「（本任务暂无多模态发现——未产生截图/PDF/网页证据）」；禁推测填充（v153 事故判例：无源照片描述） -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->

#### [sub:s6-code] CA-4 只读子代理 checkpoint 主进程代建豁免（22.8.6）E1-E3 全落盘 + 全量回归 77/77 全绿（2026-10-13）
worktree=/home/terry/task-planner-skill-worktrees/task-v172-ca4，唯一执行依据=s6-ca4-editspec.md（E1-E3，全落盘；禁自由发挥）。
- E1 critical-rules-dispatch.md:72 插入 22.8.6「只读型 Executor checkpoint 主进程代建豁免」（[task-v172 CA-4]）：tools 不含 Write 的子代理（如 Explore）允许主进程当场代建 22.8.1 检查点——返回 `checkpoint:` 字段填 `绝对路径（待主进程代建）` 且「最终结论」段全文附进返回消息，主进程同动作循环内 Write 该路径并在 progress.md 记 `[主进程] 代写 <path>`；代建完成=T5 满足+三证据齐备；未代建按 22.8.4「无进度」断点重试；本豁免只免子代理侧写盘动作，不减 checkpoint 内容义务。四锚字面（22.8.6/主进程代建/待主进程代建/tools 不含 Write）grep -cF 各=1。
- E2 selftest-subagent-return.sh 断言区末（Total 汇总前，:106-110）新增 A12 CA-4 守护断言（grep 四锚 ∧ $CR）；头部注释「内置 4 夹具」→「5 夹具」同步（:36）；registry 无断言数钉位（grep 核查）。
- E3（spec 可选项，已实施）check-subagent-return.sh selftest 区新增 fixture-5：checkpoint 值带「（待主进程代建）」中文注记 → 判据二 VIOLATION 不触发仍 PASS（:70-72）；头部 3 处「4 夹具」→「5 夹具」注释同步（:16/:18-20/:58）。
- 证据：selftest-subagent-return.sh `Total: 12 PASS=12 FAIL=0`；check-subagent-return.sh --selftest 末行 `[selftest] fixture-5 PASS`（rc=0）；task-planner run-selftests `Total: 77 PASS=77 FAIL=0 (run=77 reused=0)`；task-dispatch 无 run-selftests.sh（ls 目录逐一跑）：selftest-fallback.sh `Total: 31 PASS=31 FAIL=0` + selftest-rescue-chain.sh `Total: 11 PASS=11 FAIL=0`；grep -n '22.8.6' critical-rules-dispatch.md 命中 :72。
- 无回归失败；负结果说明：E1 old_string 按 spec 扩到 22.9 行首定位（spec 预案）；E2 首次 Edit old_string 误写 `$REG`（实际 `$RC`）修正后落盘；未动 spec 枚举 3 文件 + 本任务 findings/progress/检查点以外的任何文件；零 git 写操作。

#### [主进程] CA-5/CA-6 落地 + 实测 + bug 修复（2026-10-14）
worktree=/home/terry/task-planner-skill-worktrees/task-v172-ca5-ca6（已清理），merge 0817eef + fix 13a23ab。
- **CA-5 SessionStart 陈旧任务折叠**（zcode-sessionstart.sh [task-resume] 段：16-57 行）：
  从 INDEX.md 表格区用整行正则取「最后更新」列日期（不依赖 awk 列号），
  对含 in_progress/pending 状态的行判定是否全部 >7天→折叠为单行「N 项历史任务(未更新>7 天),按需 plan-resume」；
  有新鲜任务则保持 top-3 注入（既有行为）；无表格区/awk 异常→回退 fresh。
  3 场景实弹：全 stale=折叠 / 混合(近3天有更新)=注入 / 空 pending=跳过，全 PASS。
- **CA-6 Rule 83 通道不可用快速失败**（SKILL.md:152 投诉响应协议段 + critical-rules.md:169 起 Rule 83.1-83.4）：
  83.1 前置探测 Skill 工具面→83.2 快速失败三选项(换环境/Agent 替代授权/主进程直执行授权)→83.3 禁≥2次同法重试→83.4 机制。
  selftest-channel-fast-fail.sh CF-01..06 静态守护，registry 已登记（4 字段）。
- **Bug 发现与修复**（13a23ab）：初版 awk 用 `$8` 读日期列，但 INDEX.md scope_files 列含逗号导致
  `-F'|'` 字段位移（列号不固定），混合场景实测 FAIL→改用整行正则取最后一个 YYYY-MM-DD。
  这是「实际任务测试发现问题并解决」的实例。
- **回归**：全仓 78 selftest 唯 1 FAIL=selftest-requirement-grading.sh RG-04（归因并行会话模板扫荡
  删除 character-design-type.md 五要素行，与 CA-5/6 零相关）；CA-5/6 相关全绿（CF-01..06 + registry + session-log）。
