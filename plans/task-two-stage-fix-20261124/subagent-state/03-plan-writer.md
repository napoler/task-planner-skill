# 03-plan-writer.md — 计划撰写检查点（plan-writer 落点全登记）

- start: 2026-11-24 05:34:00 CST
- end: 2026-11-24 05:40:00 CST
- role: plan-writer（唯一写入=本检查点 + planctl 管理的 plan-state.json/4 派生 MD + knowledge-brief.md；禁改 user-session-log.md，禁跑会话绑定脚本，禁建 worktree，禁改任何 skills/ 源码）
- status: DONE（计划文档编码完成；planctl validate PASS；check-plan-dispatch rc=0）
- 输入消费: user-session-log.md #1 逐字原文 + subagent-state/01-general-analyst.md + 02-general-analyst.md + plan-writer 本次 Read 源码实证（sync-todos.sh / todo-sync.md / SKILL.md / plan-writer.md / split-pattern-library.md / bugfix-type.md / check-evidence-anchor.sh / check-complete.sh / critical-rules-discipline.md）

## 一、产出清单
- 权威源: plans/task-two-stage-fix-20261124/plan-state.json（planctl add/set 写入，validate PASS）
- 4 派生 MD（render 生成，未手工 Edit）: task_plan.md / findings.md / progress.md / verification.md
- knowledge-brief.md（§1-§7 五段齐 + 强化技能/KB 回链）
- 本检查点: subagent-state/03-plan-writer.md
- sections 计数: requirements=8 / goals=3 / vcs=9 / phases=5 / s_units=11 / decisions=9(D1-D9) / fmea=6 / research=7 / knowledge_use=5 / changes=9(CHG-1..9 逐文件改动清单) / scope_limits=3 / key_questions=3

## 二、D1-D8 裁决落点（逐条，未推翻；D9=实证补充）
- D1 触发=仅报错/改错/bug/回归类修复请求两段式；新建/问答不强制；制度层仍走 Rule 31.8 → 落 requirements R1-R8（目标型）+ decisions D1 + KQ-3 + knowledge-brief §4(6)。本计划按单计划 L2/standard。
- D2 两独立 task-id + tags 双向登记（阶段一 rootcause-followup:<B-id> / 阶段二 followup-of:<A-id>）+ 阶段二命名 <A-id>-rc，零 schema 新字段 → decisions D2 + research RS-6 + scope SC-3(禁新 schema) + knowledge-brief §1 术语/§4(5)。
- D3 阶段一必产两件登记物（根因线索包≤15行 8 要素 + 后续任务已登记=阶段二计划目录+tag+INDEX pending），不改源文件避 Rule 88.2③ → decisions D3 + S5(bugfix Phase2 交付物) + CHG-6 + knowledge-brief §1/§4(2)。
- D4 三驱动点逐文件增量（既有文字逐字保留）：①B12(sync-todos.sh+todo-sync.md，禁占 B9-B11)；②SKILL.md+plan-writer.md 两段式判定 + split-pattern-library.md P13 + bugfix-type.md Phase2；③check-complete.sh EVIDENCE-ANCHOR GATE 扩 --source=rootcause-followup，禁改门序/哈希锚 → changes CHG-1..CHG-9 + vcs VC-1..VC-6 + s_units S2/S4/S5/S7/S8/S10 + knowledge-brief §3 全锚点表。动手前已 Read 全部 9 处锚，均可落。
- D5 阶段二=阶段一合并回 master 后新 worktree(--base master)后台派发；失败/pending 交 task-resume，不影响阶段一 outcome → research RS-5(NONE FOUND 需文本新增) + decisions D5 语义并入 D2/S4 + knowledge-brief §1 术语(两段式)。注：阶段二启动协议属文本条款（规则面/SKILL 入口），本任务内不做实际派发。
- D6 Rule 31.8② 边界：阶段一守实例层、阶段二是用户授权独立任务(self Goal)不算擅自升规则；规则面加交叉引用一句 → s_unit S10 + CHG-9 + VC-6 + knowledge-brief §4(6)。
- D7 合并预案：基线=master HEAD d9f68655；增量锚避开他 worktree 面；冲突延后 smart-merge-back；主仓未提交 init-session.sh/planctl.py/attest-plan.sh 不碰 → KQ-2「合并回冲突预案」+ decisions D7 + fmea FM1/FM3 + scope SC-1/SC-3 + knowledge-brief §4(7)。
- D8 文本优先仍适用普通规则，机制类(B12/消费门)按 2026-11-24 裁决需驱动点，逐文件列改动交用户批准，不再问文本 or 门 → changes CHG-1..9（逐文件列增量）+ decisions D8 + knowledge-brief §1。
- D9（plan-writer 实证补充，非推翻）：D4③ 的 --source=rootcause-followup 需双文件改——check-evidence-anchor.sh(:115 case/:117 help/:121 未知 exit2/:509-514 dispatch 两支) + check-complete.sh(:769 传 --source/$src，:771 rc=2 fail-open，调用点 :1064/:1841)。只改调用点会 rc=2 fail-open 成空门。标记契约=findings.md 内 [rootcause-followup:PASS]+tag=rootcause-followup: 或 [rootcause-followup:N/A]+理由 → decisions D9 + fmea FM4 + s_units S7/S8/S9 + VC-5 + CHG-7/CHG-8。

## 三、未决项（交主进程/独立审计门 critic）
1. 【需 critic 复核】D9 双文件改法定标记契约（[rootcause-followup:PASS]+tag / [rootcause-followup:N/A]+理由）——若主进程已另有既定标记格式，以主进程裁决为准，S7/S9/VC-5 同步调整。
2. 【需主进程派发时确认】阶段二启动协议（D5）的文本落点：本计划选 SKILL.md:98-107 调度入口块内一句（S4）承载；若主进程希望另立更显眼的“两段式”专门段，需扩 S4 范围。
3. 【合并期】D7/KQ-2：task-session-regression / task-todo-default-engine 两 worktree 与他会话改动面重叠（SKILL.md/sync-todos.sh/todo-sync.md/templates/task_plan.md），本计划增量锚已逐条避开 task_plan.md/init-session.sh/planctl.py/attest-plan.sh，但重叠文件冲突只能实施期 smart-merge-back 逐条并线，非计划期可消除。
4. 【info】本计划本身不套两段式（KQ-3）：制度层机制固化走单计划 L2；B12 文案「非修复类标 N/A」为分类标记，非机器门分支。
5. 【info】VC-8 全量 selftest 计数须实施期主进程逐脚本 Total 行求和，禁采信子代理自报总数（模板本有此约束，已带入 S11 验收）。

## 四、自检
- 必填六项: Goal(requirements R 行+goals G1-G3) ✅ / VC(9 条可执行命令，含 grep/bash -n/selftest/validate) ✅ / Scope(SC-1..3 明确文件路径) ✅ / Phases(5 个，Status 全 pending，Executor 全具名 agent(model) 无主进程) ✅ / 隔离决策(isolation=direct 计划期 + 说明实施另起 worktree) ✅ / Todo 同步(经 todo_sync 口径，进度派生视图) ✅
- template_type=rule-enhancement（rule-enhancement-type.md）；execution_lane=L2 / plan_tier=standard
- S-unit 粒度: 全部 ≤2 文件 ∧ ≤60 行 ∧ ≤15min；ID 纯数字 S1..S11；执行体列非空
- 逐文件改动清单: CHG-1..CHG-9（文件路径+当前锚点+增量内容+验收命令 VC 映射）
- 不做什么: SC-3（8 条禁止动作）——不修 bug 现场/不部署不碰部署位/不新增 schema/不跑会话脚本/不建 worktree/不改门序哈希锚/不占 B9-B11/不手工 Edit 派生 MD
- planctl validate: PASS；check-plan-dispatch.sh: rc=0（5 个派发型 Phase 均有带执行体 S-unit 表）
- 未跑（按指令）: init-session.sh / attest-plan.sh / set-active-plan.sh / plan-created.cjs / 建 worktree / 改 skills/ 源码 / 改 user-session-log.md

---

## R2 修订段（独立审计 R1 REJECTED → C1+I1-I7+W1-W5+Q1 增量修订）

- 审计源: subagent-state/04-critic-audit.md（verdict REJECTED，C=1/I=7/W=5/Q=1）
- 方式: Rule 74 增量——planctl add/set 就地补明 + 追加，既有条目逐字保留；每写后 render；未重建计划
- 校验: planctl validate=PASS / check-plan-dispatch rc=0 / check-complete rc=0；VC-1..VC-11 全部 bash -n 通过；VC-5 未实施态实跑 rc=1（NO-SOURCE-PARSE，判别性成立非真空）

### 逐条对应（key → 落点）
- C1 → VC-5 重写为 POS+NEG 双向：真 planctl init/add/tag-add 生成 POS（带标记+tag→rc=0）、NEG（无标记→rc=1），双断言任一不符 exit 1；NO-OP(arg-case-only)被 NEG 拦下（NO-REAL-MODE/BI-DIRECTIONAL-FAIL）。
- I1 → CHG-8/S8 改「new 受控调用块，仿 :1063-1064/:1839-1841 guard 形态（VC_GATE_TIER/mini），禁写进 run_evidence_anchor() 函数体 :761-795 否则自递归」；VC-5 加位置断言 CN>FEND + guard grep。
- I2 → VC-9 改为 git diff --name-only ∩ skills/ 与 CHG-1..11 允许集求差集，非空 exit 1；部署位(仓外 5 路径)明确「不可机器验证-人工核对 mtime」，不再用恒真 git status grep 冒充证据。
- I3 → 新增 VC-10（四锚：合并回 master / --base master / 不阻塞·pending / followup-of: 与 rootcause-followup: 双向 tag）；R6/R7 vc 追加 VC-10（原 VC-5/VC-9 保留）；P3 v_checks 加 VC-10。
- I4 → 标记契约定死：findings 内 [rootcause-followup:PASS] 或 [rootcause-followup:N/A]+理由 + 真 planctl tag-add 写 <plan-dir>/../.tags-index.json（planctl.py:757-758/1055）；mode 读索引校验；VC-5 fixture 用真 planctl 且两 fixture 分置 $R/a/$R/b 隔离索引，禁空 {} 假索引。
- I5 → 新增 CHG-11 + S12(P4, code-assistant(sonnet-1)) + VC-11：selftest-evidence-anchor.sh 追加 EA-21 POS/EA-22 NEG/EA-23 B12 断言（不改 EA-01..20）；纳入 VC-8/VC-11；scope SC-1 allow 纳入该文件。
- I6 → CHG-3/S4 把两段式判定从 :98-107(L1+ 豁免块)移到 SKILL.md lane 无关强制段(:37/:266)，:98-107 仅留指针；明文「修复类 L0/mini/trivial/L0-E 先升 L1 复核」；CHG-2 + T-P2 写清 B12 在 mini/L0 口径=N/A 也要有证据；VC-2 加 N/A/升 L1 grep。
- I7 → D8 据实降级登记「主进程设计选择（跨会话记忆 2026-11-24 裁决，非 #1 逐字原话）」，不补假原话；task_plan Decisions 已同步；understanding.model/direction 同步；**#1 理解镜像表述=handoff 待办交主进程单写（Rule 80.7，plan-writer 禁改 user-session-log.md）**。
- W1 → 新增 CHG-10：critical-rules-discipline.md:749-751 Rule 106.5 通用基线组 B1-B8 枚举后追加 B12；他 worktree task-session-regression 同文件 :753 改动面已登记 KQ-2/D7 合并预案。
- W2 → root_causes 追加 RC-NA 定性行「不适用（制度机制建设、非结果级 bug）+ 理由」，替换 :68-71 占位文本。
- W3 → VC-1 追加：若 sync-todos.sh 源含 B9/B10/B11 定义，则 --json 输出须全部仍在（防并线吞掉他会话基线项）。
- W4 → VC-8 正向分支改 grep -Fq 'FAIL=0'，去掉近似恒真的 Total.*0。
- W5 → D5 补可执行步骤（执行者=阶段一主进程 / 时点=merge --no-ff 后 / 命令=git worktree add <root>/tmp/worktrees/<A-id>-rc -b wt/<A-id>-rc master + 后台 Agent / 失败=仅 INDEX+tag pending 交 task-resume，不改 outcome），映射 VC-10；S4 actions 同步。
- Q1 → 新增 D1'（主进程裁决，分级全覆盖取代 D1 窄口径：修复类=完整线索包+根治；非修复类=阶段一产出+早合并，阶段二=同族风险/隐患排雷，无风险 N/A+证据）；D1 rationale 标注「已被 D1' 取代、原文保留追溯」；B12 subject 统一改「根因/风险线索包已落盘+后续任务已登记」；VC-1/VC-2/CHG-1/CHG-7/understanding 同步。

### R2 未决/交接
1. 【handoff 主进程】user-session-log.md #1 理解镜像表述需按 Rule 80.7 单写同步 D1'/D8 口径（plan-writer 禁改——已据 I7 守住原条目，sha 未动）。
2. 【critic 复审】VC-5 标记契约（findings 标记 + 真 planctl tag-add 索引，两 fixture 隔离）需 R2 独立审计确认判别性；NEG fixture 期望 rc=1 是防 NO-OP 的核心门。
3. 【info】本计划仍不套两段式（制度层机制固化，单计划 L2）；D1' 仅定义未来执行形态，非本任务自检对象。
4. 【info】最终提交计数：vcs=11 / s_units=12 / changes=11 / decisions=10(D1-D9+D1') / fmea=6 / root_causes=1 / phases=5。
