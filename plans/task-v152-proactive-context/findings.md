# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- R1: 优化当前的技能，加入一个「主动」机制（2026-10-09 原话）
- R2: 遇到上下文过长、或者出现混乱的时候 → 主动进行压缩/整理优化
- R3: 实在解决不了 → 撰写交接文档，要求在新的会话中开启
- R4: 核心 = 主动评估、主动优化

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| Explore 侦察（7 问 A-G） | agentId=agent_9c951ea4；返回全文已蒸馏入本文件 | ✅ 2026-10-09 | Research Findings |
| 拆分模式库 Rule 21.6.1 | /home/terry/.zcode/skills/task-planner/references/split-pattern-library.md | ✅ 计划期已读前 80 行（P1-P8 模式） | → task_plan.md S-unit 拆分 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
### A. Rule 29 上下文与工作文件主动维护现状（critical-rules.md:290-299）
- 触发只有三档：① Phase complete（每 2 个 Phase 一次节流）② 会话恢复 ③ 用户显式指令（:294）——**全部事件驱动，无「上下文过长/混乱/重复失败」信号触发**
- 29.2 退场 SOP=check-context-hygiene.sh（superseded 标记/findings>500 行/progress 段>10 行/同标题≥5 项折叠）；29.3 压缩 SOP=compaction 前过 29.2+注入块>2KB 提示（:295-296）
- check-context-hygiene.sh 4 项检查全是结构/行数代理指标，不读真实上下文状态（check-context-hygiene.sh:46,56）
- 29.5 自述「本条为流程层 SOP（hook 未接读取），主进程按档位自律执行」→ **无 hook 承载**
- config 键：context_hygiene_enforce / plan_hygiene_enforce（默认 warn）/ plan_archive_age_days=7（:298）

### B. Rule 65 周期性回顾（critical-rules.md:816-846）
- 每 N 次工具调用（默认 8，periodic_review_interval_calls）做结论一致性前后对照+自动纠正（:822）
- periodic-review.sh 只读检 findings vs progress 矛盾（CONCLUSION-CONTRADICTION CRITICAL）+ Goal 漂移
- **未接 hook**：zcode-posttooluse.sh:46-107,321-344 只有 drift-rhythm（Rule 64.3，N=10），无 periodic-review 接线 → 执行可靠性空白
- 与 Rule 64.3 同为工具调用节奏但关注点不同：偏移检查 vs 结论一致性

### C. 会话级交接/恢复现状
- **不存在会话级「交接文档」模板或机制**：grep 会话交接|session handoff|交接文档 在 skills/ 与 plans/ 零命中（排除 Chain/Subagent Handoff）
- 现有两类 Handoff 均非会话级：Chain Handoff（block 间，reference.md:255-289）+ Subagent Handoff 登记表（子代理级，SKILL.md:86）
- 恢复链既有件：Rule 19.3 恢复读序（task_plan→progress→findings:114）→ Rule 62.1 四文件加 knowledge-brief（:745）→ Rule 24.5 自主续推（:216-226，Skill("plan-resume")，autonomous_resume=true）→ session-catchup.ts 检测中断点（SKILL.md:57）
- templates/ 共 10 主模板+29 variant，**无 handoff/交接类模板**（模板清单见 templates/ 目录实测）
- 空白：无法在「当前会话解决不了」时产出结构化会话交接文档驱动新会话继续

### D. hook 与 config 面
- /home/terry/.zcode/cli/config.json hooks.events 四事件：SessionStart→zcode-sessionstart.sh(10s)；PreToolUse(matcher Write|Edit|Agent|CreateWorkflow|…)→zcode-pretooluse.sh(5)；PostToolUse(全工具)→zcode-posttooluse.sh(5)；UserPromptSubmit→zcode-userpromptsubmit.sh(5)
- 技能 config.json 共 42 properties；间隔类：plan_update_interval_minutes=15 / todo_sync_interval_calls=10 / periodic_review_interval_calls=8 / prompt_note_interval=10 / stale_remind_cooldown_calls=10 / findings_stale_minutes=20 / progress_stale_minutes=25 / compass_escalate_after=2 / escalation_threshold=3
- **无任何「上下文长度阈值」键**（max_tool_calls_before_refresh 最接近但用于子代理刷新）
- ⚠️ 大量 selftest 钉死 `properties=42`（selftest-research-first / four-file-dataflow / execution-honesty 等）→ 新增 config 键需跨脚本级联；**先例=Rule 64.5/64.6 env 降档零新键**

### E. 编号账本状态
- plans/.rule-reservations.jsonl 共 33 行，最高 landed=65（task-v149，:33）；reserved 全部转 landed；历史 contested(50)/abandoned(60) 记录在案
- **66、67 均无记录**；但并行 task-v151 计划已声明 `new_rule: 66`（goal 模式）→ 本任务避让取 **67**
- critical-rules.md 最大 Rule=65、总 846 行；SKILL.md 509 行，:9,:280,:360 三处钉「Critical Rules 1-65」→ 新增 Rule 需级联改 1-67

### F. selftest 约定
- selftest-registry.tsv 精确 4 列（script/domain/trigger_scenarios/dep_anchors），63 数据行=63 个 selftest-*.sh 实测一致
- 骨架：set -u + ok()/bad() `<ID> PASS|FAIL` + 末行 `exit $((FAIL>0))`；断言=grep -q/jq -e/[ -x ] 字面锚（selftest-periodic-review.sh:20-31,103-104）
- 新增 selftest 必触及面：① registry.tsv 加行（selftest-registry.sh T02-T05）② selftest-self-resolution.sh SR-12 行数=ls+1 动态断言（:106-110）③ SKILL.md C-list/Rule bullet/1-N 计数 ④ config properties=42 锚（若零新键则免）⑤ docs/ARCHITECTURE.md:81 硬编码 ×62 已漂移实态 63（历史债，非本任务引入）

### G. 全仓 grep 压缩/context_exceeded 命中
- 既有：Rule 29.2/29.3 压缩 SOP（:295-296）；Rule 35.5 context_exceeded→35.3 落盘（:362）；SKILL.md:459,464 子代理面兜底；reference.md:88-100 Manus Compaction 原则（理论未落地）；check-context-hygiene.sh 结构压缩
- 同词不同义：Rule 26 Q2「压缩验证步骤」=缩减验证非上下文压缩（critical-rules.md:239-265）
- **空白三件**：① 主进程会话级上下文状态检测/触发 ② 「混乱/重复失败」作为主动压缩触发 ③ 会话交接文档产物

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 67（避让 v151 的 66）而非扩展 Rule 29 | 能力含评估 verdict+压缩动作+交接升级三段，超出 Rule 29「多→退场」SOP 语义；编号账本 67 空闲（E 节）；v151 已占 66 防撞号（历史撞号教训 task-v143/v142） |
| 零新 config 键，走 env 降档 | properties=42 被多 selftest 钉死（D 节）；先例=Rule 64.5/64.6 env 降档 |
| hook 承载=PostToolUse 既有节奏块内追加（借用 drift-rhythm 计数） | 主动性若无 hook 承载=纯 LLM 自律，与 Rule 65 同空白（B 节）；复用节奏状态免新计数器 |

### 计划产出（2026-10-09 20:0x）
- plan-writer（sonnet-1 档 reasoning 缺失 → 按 22.3① 改派 general-purpose，agentId=agent_1949f3de）产出 task_plan.md：386 行/6 Phase/7 S-unit；主进程 Read 全文复核+独立复跑 `check-plan-dispatch.sh`（exit 0，3 个派发型 Phase 均有带执行体 S-unit 表）与 `check-template-type.sh`（OK，rule-enhancement）
- 派发过程两插曲已处置：① 模板绝对路径被守卫锚成计划目录 → prompt 改非绝对写法 ② spawn 失败遗留孤儿串行锁 → 清除（subagent-state/.dispatch-inflight）

### 设计定稿（Phase 1，2026-10-09 20:10）
- 产物=design-draft.md（§1 条款六子条草案 / §2 五段模板草案 / §3 hook 施工图 / §4 钉值级联 8 项）；S-unit 消费映射见其尾注
- 关键设计：三档触发复用 64.3 drift-rhythm 同一计数与注入通道（零新计数器）；裁决留痕 `[assess]` 行（64.1 无痕迹=未执行同族）；PRESSURE 复用 29.2/29.3 SOP 只加「命中即执行」语义；交接文档=新模板 5 段含可复制恢复指令；env 两键（CONTEXT_PRESSURE / _N）零新 config；drift-rhythm 既有三键零改动=负锚
- 术语语义锚：HEALTHY/PRESSURE/CONFUSED 条款-模板-selftest-hook 四面逐字回写（v150 P11 判例）
- Phase 1 drift-check：**ALIGNED**（三锚证据齐，checkpoint=subagent-state/1c-drift-checker.md；haiku 档 provider 拒 → general-purpose 承载 22.3①，连续第 3 例 provider 档位拒绝：sonnet-1 reasoning/haiku 拒/general-purpose 正常——provider 面波动记入 kb §4）

### Phase 2 基线事实（2026-10-09 20:16-20:18）
- 基线快照：**63 selftest / 63 PASS / 0 FAIL**（worktree=master=dbc635a；对照 Phase 4 回归 FAIL 计数必须 =0）
- 部署位基线：仓 master vs ~/.zcode 部署四关键文件 IDENTICAL（终验三部署位 diff=0 的对照起点）
- worktree 与 master 四文件 diff 空=全新同步（memory「worktree 分支不同步」判例核验通过，无需从他处拷贝）

### 级联面发现（Phase 3 派发前，2026-10-09 20:22-20:30 — 触发 B 类扩展）
- **活断言钉值全清单**（worktree=master 实测，行号为改动前实测）：`selftest-research-first.sh:72` RF-06 cnt'1-65'≥3 / `:73` RF-07 双锚 'Critical Rules 1-65（含 Rule 40-65 全集'；`selftest-lane-advancement.sh:131,133` LA-12 ≥1；`selftest-workflow-orchestration.sh:70-73` WF-10 四索引文档计数≥3；`selftest-self-resolution.sh:74,76` ≥1；`selftest-tool-selection.sh:60,62` TS-05 ≥1；`selftest-requirement-coverage.sh:127-131` RC-11 ≥1；`selftest-drift-check-subagent.sh:59` DCS-11 'Rule 40-65 全集'；`selftest-skill-split.sh:46` 行数 ≤510（现 509）
- **索引文档标签面**：`skills/task-planner/README.md:72`、`CLAUDE.md:33`、`README_zh.md:136,229`（均带 v149 对齐注）——WO-10 扫描集=SKILL/CLAUDE/README_zh/skills-README 四文档
- **不动面（判定留）**：`^66\.` 前向防线五处（RC-15/EG-16/FF-16/IP-14/RF-10 对 FF 的引用）——语义=「66 号未被顺手创建」，67 落地不触发（`^67` 防线全仓 0 处，实测）；66 归 v151，防线不动=保护不撤；`conclusion-discipline.sh:88` 宽容锚 `1-6[0-9]` 自适配 1-67 无需改；`iteration-persistence` 仅注释行；`critical-rules.md:840` 匹配是 `65.1-65.5` 子串假阳性；行数上限 ≤558（knowledge-brief T2b/execution-stability T8b/DCS-19）宽裕不动
- **v149 同构判例**：plans/task-v149-skill-alignment-audit/progress.md:51-52「Wave2a 守卫级联批：1-64→1-65…各自 FAIL=0；S23 skill-split 行数 500→510」——本次照此模式拆 S8-S13
- 结论 → 触发 task_plan B 类扩展（scope +12 文件 + S8-S13），Decisions Made 20:30 行登记

### A 批验收（S1-S4，2026-10-09 21:1x，主进程 worktree 实测复验）
- 改动集=恰 4 scope 文件（critical-rules +15/-0、SKILL +8/-4、posttooluse +12/-1、session-handoff 新增 ??）零越界
- 实测锚：`^67\.[1-6]`=6；短串 `1-67`(SKILL)=3（RF-06 口径 ✓）；整串 `Critical Rules 1-67`=2（:280/:360；第 9 行为「Critical Rules **全集** 1-67」不含整串——**VC-5 原「=3」验收标准误设，纠正-3**；LA-12/TS-05/SR-07/RC-11 断言为 ≥1 均过）；`1-65`=0；RF-07 双锚整串=1；C45=1；SKILL=511 行；五段标题=1×5；bash -n OK；emit 计数 12=12（F9 未破）
- 执行体插曲：S4 首派（21:0x 前）33min 超限未落盘（陷入 F9 设计纠结）→ 设计细化-3 登记后重派即成；S2 上报「C44 行误改自纠」与两项偏差（诚实符合43.1）

### B/C 批验收（S5/S8-S13，2026-10-09 22:4x-23:0x，主进程复验）
- **改动集终态=恰 17 文件**（15 M + 2 新增），与 scope_files（18 减 CHANGELOG 留 Phase 6）逐一对上，零越界；diff 总量 +62/-26
- 主进程独立复跑：新 selftest-context-pressure 9/9；research-first 12/12；lane-advancement 14/14；self-resolution 13/13；tool-selection 12/12；requirement-coverage 23/23（RC-15 :166/:179 逐行零改动）；workflow-orchestration 16/16；drift-check-subagent 20/20；skill-split 41/41（钉 518×5）
- `^66\.` 防线完好：critical-rules 内 `^66.` 计数=0（RC-15 通过），五处前向防线全部未触碰——66 号保护完整留给并行 goal 任务
- 验收口径修正备案：S9 `40-65`=2 全在演进注历史引用（v149 先例同款）；S8/S9 的 `git diff --stat 仅该两文件` 在并行组语境下按「本单元增量」判定（各执行体自查+主进程总改动集=17 对照）
- 派发插曲合计：3 次守卫拦截（伴飞路径/S18 字面/步骤枚举 9>4）+2 次 provider 失败（S13×1、drift-checker×1）+1 次超限返工（S4 首派 33min）——全部按 22.3 换道处置，无一从零重做

### Phase 4 验证（2026-10-09 23:59 - 2026-10-10 01:5x）
- **零回归实证**：64 脚本 rc≠0=0、FAIL=0，对基线（63/63/0）新增恰=1 即新守护 selftest-context-pressure（9/9）；registry 动态断言 rows=64=actual 64；结果落 plans/task-v152-proactive-context/regression-worktree.log
- **hook 实弹冒烟双态 PASS**（VC-4）：run1 默认 env → 恰 1 行合法 JSON，additionalContext 同时含 `[drift-rhythm]`+`[context-pressure]`（F9 单 emit 形态实弹验证）；run2 `TASK_PLANNER_CONTEXT_PRESSURE=off` → 仅 drift 段。可复跑证据：subagent-state/7-code-runner-S6-smoke.sh + run1/run2.out
- config 零新键：properties=42，worktree config.json git diff 空（selftest-final-gate-hash 改写-恢复设计行为经 diff 空证实无污染）
- 注记：S6 跨夜长跑（23:59→01:5x）；当前日历日已跨至 2026-10-10，后续时间戳用 10-10

### fix-wave（S14-S17，2026-10-10 02:5x-03:06，CR round1 六项全修）
- 主进程复验：posttooluse `bash -n` OK + 双除零防护行（:336 rhythm_n 外移/:350 _cpn）+ N=0 复跑无 division-by-0 且 SMOKE PASS；selftest-context-pressure 9/9、`git show`=0、CP-03 三态词 hook 交叉断言在位；SKILL/条款 C46=1 且 C45=0；README 11核心=2
- 裁决：S15 的「CP 计数≥10」验收口径系主进程误设（MINOR-2 并入 CP-03 非新增编号），9 项=终态
- CR round2 复审已派（结论路径 G5=8-code-reviewer-S7-round2.md）

### CR round2 = APPROVED（2026-10-10 03:2x）
- 6 项修复逐项实测确认（含 _cpn=0/00 复现消除、_cpn=3 降频语义验证、C46 波及面=零断言、F9/F10/三键零副作用复核）；全量 990 PASS / 0 FAIL
- 唯一新发现=1 条非阻断 MINOR：selftest-skill-split.sh:46 演进注释内「C45」应随改名写 C46（纯注释）→ **折叠进 Phase 6 合并触碰时顺手修**（登记于 Phase 6 清单）
- design-draft 内 C45 字样=历史设计快照不回溯（CR 附带说明认可）；worktree C44→C46 断号=合并前预期态（C45 由 master goal 行合并时回归）

### Phase 6 合并回与部署（2026-10-10 06:4x-07:15）
- **三轮主仓并集**（并行会话 v151/v153/v154/v155 相继落地）：v151(66)→9 文件冲突；v153(68)+v154(69)→16 文件冲突；v155(70 Rule 70)→3 文件冲突+尾补。并集终态=critical-rules 66-70 编号序/SKILL 标签 1-69+70/C45(goal)+C46(68)+C47(69)+**C48(v155 呈报)+C49(本任务 67 压力)**/skill-split 钉 526/registry 68 行
- **五方合流教训**：①  sed 精确删冲突行时误删 master 侧合规行（v155 C48）→ 部署位对账+RRV-04 FAIL 才暴露→尾补恢复（教训：删行后必须逐侧内容核验，不能只验标记清零）② 自查行编号三次让位 C46→C48→C49——并行合流的 C 编号 cardinality 漂移（v155 已把此教训写进其 RRV-04 注释，双方互证）
- master 合并=`a7b1619`（no-ff）；部署位：~/.zcode **运行位自保护**（smart-merge-back 拒覆盖自身所在目录，明示手动 rm+cp）→ staging+rm+mv 完成部署；三部署位对账 IDENTICAL；部署位实弹 3 脚本全绿

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| Explore 为只读模式无法写检查点文件 | 结论经返回消息蒸馏入本文件+kb（Rule 62.3 双落盘路径之一）；agentId=agent_9c951ea4 留档可续问 |
| init WARN：哨兵 sidkey(4ec328f) 与 env sid(de2c5bba) 不一致（SessionStart 与 Bash env 的 sid 源分裂） | 复用 RC-1 已知家族问题；set-active-plan side 指针已按 env sid 落盘指向 v152，plan-created.cjs 确认「可正常执行写入操作」；不影响本任务 |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
- 侦察全文（可续问）：agentId=agent_9c951ea4-287a-406d-8460-ad58d36ecfcd
- 编号账本：/mnt/data/dev/task-planner-skill/plans/.rule-reservations.jsonl
- 并行任务参考：/mnt/data/dev/task-planner-skill/plans/task-v151-goal-mode/task_plan.md（Rule 66 声明，撞号避让对照）
- 拆分模式库：/home/terry/.zcode/skills/task-planner/references/split-pattern-library.md

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
