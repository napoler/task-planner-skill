# [sub:executor-m7] 独立终验检查点（VC-5 全量回归 0 FAIL 复核）

- 会话: sub:executor-m7 (fresh 会话独立终验)
- 日期: 2026-10-03
- 执行方式: cwd=/mnt/data/dev/task-planner-skill-worktrees/task-v122, 单条 for 循环:
  `for f in skills/task-planner/scripts/selftest-*.sh; do echo "== $f"; bash "$f"; echo "rc=$?"; done`
- 原始日志: 见下方完整落盘（subagent-state/m7-executor.log 同步存于 836 行全量）

## 完整逐脚本原始日志

== skills/task-planner/scripts/selftest-active-plan.sh
T01 PASS 01
T01b PASS 01b
T02 PASS 02
T03 PASS 03
T04 PASS 04
T04b PASS 04b
T05a PASS 05a
T05b PASS 05b
T06 PASS 06
T07 PASS 07
T08a PASS 08a
T08b PASS 08b
T09 PASS 09
T10 PASS 10
T11 PASS 11
T12a PASS 12a
T12b PASS 12b
T12c PASS 12c
T12d PASS 12d
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-ask-default-timeout.sh
RT-01 PASS critical-rules.md Rule 44 子条锚 = 4
RT-02 PASS CRIT 44 节用户原话锚「默认选项」4 /「自动超时」2 /「5 分钟」2 均 ≥1
RT-03 PASS 44.2 行内「41.3」衔接引用 1 ≥1
RT-04 PASS SKILL.md C33 合规清单项 = 1
RT-05 PASS 模板 task_plan.md「自动超时默认项」行 1 ≥1
RT-06 PASS mini-lite「Rule 44 豁免」声明行 1 ≥1
RT-07 PASS registry 含 selftest-ask-default-timeout 行 = 1
RT-08 PASS 越界 1-4x 字面零命中（CRIT 44 节=0 / SKILL.md=0，1-4[5-9] 已加白 task-v117+task-v118+task-v121）
RT-09 PASS config.json properties 键数 40（零新增）
Total: 9 PASS=9 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-batch-pilot.sh
BP-01 PASS 18.9 试点先行硬门
BP-02 PASS 18.10 单件失败禁批量（投毒红线）
BP-03 PASS 18.11 宁慢勿错
BP-04 PASS 18.1-18.11 编号连续各 1 次
BP-05 PASS SKILL.md Rule 18 摘要行联动
BP-06 PASS batch-quality-gate §二表 18.9-18.11 三行
BP-07 PASS §八 试点先行硬门详解
BP-08 PASS SKILL.md 行数 447 ≤558
BP-09 PASS CD-19 宽容锚子串保护（隶属 Rules 1-36）
BP-10 PASS CHANGELOG task-v083 条目
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-conflicts.sh
CC-01 PASS 未提交变更计数+porcelain 列表+基础设施子信号, rc=1
CC-02 PASS 额外 worktree 计数+路径列表, rc=1
CC-03 PASS 遗留 wt/* 分支计数+列表, rc=1
CC-04 PASS 待处理区在册任务计数=2, rc=1
CC-05 PASS 无冲突基线全绿输出, rc=0
CC-06 PASS runtime 同文件冲突 A(真实形态 INDEX)恰 1 条且报他计划 t-other, rc=1
CC-07 PASS 仅自计划在册零冲突 A 全绿通过, rc=0
Total: 7 PASS=7 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-drift.sh
CD-01 PASS 全 complete 计划零 PHASE-SKIP 误报, INFO PHASE-ORDER, rc=0
CD-02 PASS complete,in_progress,pending 推进态零误报, INFO PHASE-ORDER, rc=0
CD-03 PASS 真越级仍报 CRITICAL PHASE-SKIP 恰 1 条, rc=1(报警不削弱)
CD-04 PASS 三列表: 越权+禁止列文件均报 BREACH, 允许列不误报, rc=1(S9 反向风险语义)
CD-05 PASS 无范围表计划 SCOPE-NONE 跳过, rc=0(fail-open 保持)
CD-06 PASS 两列表越权报 BREACH 含 hack/evil.py, 允许列不误报, rc=1
Total: 6 PASS=6 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-conclusion-discipline.sh
CD-01 PASS critical-rules.md 含 '### 35 执行结论纪律'
CD-02 PASS 35.1 触发条款存在
CD-03 PASS 35.2 能力否定三关条款存在
CD-04 PASS 35.3 大输入落盘引用条款存在
CD-05 PASS 35.4 结论上报措辞条款存在
CD-06 PASS 35.5 消费侧条款存在
CD-07 PASS 35.6 最小探针原则+35.7 机制条款存在（task-v082 重编号后双锚）
CD-08 PASS CD-25 critical-rules.md+SKILL.md 均含 '最小探针'（35.6 条款与 SKILL 联动在位）
CD-09 PASS 22.4 行含 'Rule 35.3 大输入落盘引用'
CD-10 PASS SKILL.md 含 'Rule 35（P0）执行结论纪律' 列表行
CD-11 PASS SKILL.md 含 '| C23 |' 检查项行
CD-12 PASS SKILL.md 宽容锚「1-3[5-9]」2 +「1-4[5-9]」1 合计 ≥3（兼容 1-35-46 过渡，task-v117+task-v118 双锚口径扩展+task-v121 预扩）
CD-13 PASS SKILL.md 不含 '1-34'（防回退，当前=0）
CD-14 PASS SKILL.md 含 'Rule 35.3 大输入落盘引用'（五档兜底引用注）
CD-15 PASS check-dispatch.sh 含 '补救(Rule 35.3)'
CD-16 PASS check-dispatch.sh 仍含 '⚠ prompt 长度'（selftest-dispatch FG 依赖）
CD-17 PASS subagent_dispatch.md 含 '超限补救(Rule 35.3)'
CD-18 PASS notepad-learnings.md 含 '🚫 被否决方案' 段
CD-19 PASS README.md 含 1-3[5-8] 宽容锚（task-v086 级联 1-38）（兼容 1-35/1-36 过渡）
CD-20 PASS batch-quality-gate.md 含 1-3[5-8] 宽容锚（task-v086 级联 1-38）（兼容 1-35/1-36 过渡）
CD-21 PASS plan-writer.md 含 '纯数字'（s_unit_id 契约行）
CD-22 PASS task_plan.md 含 'ID 列一律纯数字'（④ 注释行）
CD-23 PASS subagent_dispatch.md 含 '机械求和'（禁自报汇总行）
CD-24 PASS smart-merge-back.sh 含 'DEPLOY_SRC' 且含 '禁回退 SKILL_ROOT'（fail-closed）
Total: 24 PASS=24 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-context-hygiene.sh
T01 PASS critical-rules.md '### 29' 标题 + 29.1-29.6 六子条款
T02 PASS SKILL.md 'Rule 29' 指针 ≥2 (实测 2)
T03 PASS check-context-hygiene.sh clean fixture exit 0
T04 PASS check-context-hygiene.sh superseded+同主题≥5 fixture exit 1
T05 PASS check-context-hygiene.sh findings>500 行 fixture exit 2
T06 PASS check-context-hygiene.sh 不存在 plan-dir exit 0 (fail-open)
T07 PASS plan-hygiene.sh --dry-run: 超龄 completed 出 ARCHIVE 行, in_progress 不出
T08 PASS plan-hygiene.sh --execute: 超龄目录 mv 入 archive/, in_progress 不动, exit 0
T09 PASS plan-hygiene.sh --age 3 对 3 天前 completed 出 ARCHIVE; --age 5 不出
T10 PASS config.json 3 键注册 (context/plan hygiene=warn, plan_archive_age_days=7)
T11 PASS config.json 合法 (json.load 不抛异常)
T12 PASS check-context-hygiene.sh 只读 (运行前后 fixture mtime 不变)
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-delegation.sh

========================================
selftest-delegation results
========================================
PASS  T01 无计划放行  (exit=0)
PASS  T02 子代理 sid 放行  (exit=0)
PASS  T03 plans 白名单放行  (exit=0)
PASS  T04 SKILL_ROOT 放行  (exit=0)
PASS  T05 trivial 3 行放行  (exit=0)
PASS  T06 4 行拦截  (exit=2)
PASS  T07 enforce exit2  (exit=2)
PASS  T08 warn 不阻断  (exit=0)
PASS  T08 warn 注入  (grep hit)
PASS  T09 .allow-direct 放行  (exit=0)
PASS  T09b ledger 写入 bypass
PASS  T10 过期 allow-direct 拦截  (exit=2)
PASS  T11a 首次 on 成功  (exit=0)
PASS  T11b 二次 on 拒绝  (exit=3)
PASS  T12 stats 占位/理由检测  (grep hit)
PASS  T12 stats 退出码非 0(violation)  (exit=1)
PASS  T13 Handoff 交叉校验  (grep hit)
PASS  T14 jq 失败 fail-open  (exit=0)
PASS  T15 复合Executor全在Handoff不误报
PASS  T15b 复合Executor仍计delegated
PASS  T16 复合Executor部分缺失触发unverified
PASS  T16b reason字段含缺失token
PASS  T17 白名单④标记理由不触发violation
PASS  T17b 白名单标记main_direct全部self_declared=0
PASS  T18 无理由触发missing_reason violation
PASS  T18b verdict=violation exit=1  (exit=1)
PASS  T19 owner 多行注入 sid 放行(子代理语义)  (exit=0)
PASS  T19b owner 首行主进程+白名单外=exit2  (exit=2)
PASS  T20 owner 缺失 exit 0  (exit=0)
PASS  T20b owner 缺失输出观察模式  (grep hit)
PASS  T21 plans/ 内 .ts 不放行  (exit=2)
PASS  T21b plans/ 内 .md 放行  (exit=0)
PASS  T22a 同 sid 首次 on 成功  (exit=0)
PASS  T22b 同 sid 二次 on 拒绝  (exit=3)
PASS  T22c 不同 sid on 放行  (exit=0)
PASS  T_MEM 记忆目录白名单放行  (exit=0)
PASS  T_RATE_OK rate>=floor exit0 且比较式 1 处  (exit=0)
PASS  T_RATE_LOW rate<floor exit1  (exit=1)
----------------------------------------
Total: 38    PASS=38  FAIL=0
========================================
rc=0
== skills/task-planner/scripts/selftest-dispatch-grain.sh
GR-01 PASS critical-rules.md 46.1..46.5 共 5 条
GR-02 PASS 条款头「### 46 子代理单任务专注度」
GR-03 PASS SKILL.md 2.5 单会话单 S-unit
GR-04 PASS subagent_dispatch.md Rule 46.1 引导行 x2
GR-05 PASS check-dispatch.sh 含「任务书检出」收窄标记
GR-06 PASS 守卫④ tb 模式调用在位
GR-07 PASS 任务书 2 S-id → exit 2 + 任务书检出
GR-08 PASS 任务书 6 编号 → exit 2 + 步骤枚举超限
GR-09 PASS 自由 prompt 6 编号 → exit 0 不拦
GR-10 PASS 全角形态引用 + 2 S-id 任务书 → exit 2 + 任务书检出
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-dispatch.sh
T01 PASS 01 (rc=0)
T02 PASS 02 (rc=2)
T03 PASS 03 (rc=2)
T04 PASS 04 (rc=2)
T05 PASS 05 (rc=0)
T06 PASS 06 (rc=0)
T07 PASS 07 (rc=0)
T08 PASS 08 (rc=1)
  (stdout 恰 2 行: progress.md | checkpoint:)
T09 PASS 09 (rc=2)
T10 PASS 10 (rc=0)
T11 PASS 11 (rc=0)
T12 PASS 12 (rc=0)
TS-01 PASS (rc=0, 锁写入=1791007894)
TS-02 PASS (rc=2, stderr 含 串行)
TS-03 PASS (rc=0, stderr 含 串行警告)
TS-04 PASS (rc=0, 锁刷新=1791007895)
TS-05 PASS (rc=0, 锁未改写)
TS-06 PASS (rc=0, 锁已清除)
TS-07 PASS (rc=0, 组标记槽占用放行)
TS-08 PASS (rc=2, 无标记仍按串行槽拦截)
FG-01 PASS (rc=0, 零细粒度输出, 基线一致)
FG-02 PASS (rc=0, warn 告警+计数落盘)
FG-03 PASS (rc=0, 双 S-unit 打包检出)
FG-04 PASS (rc=0, brief 引用提示)
FG-05 PASS (双条件豁免: SKIPPED 提示, 未判打包)
DX-01 PASS
DX-02 PASS
DX-03 PASS
DX-04 PASS
DX-05 PASS
DX-05b PASS
Total: 31 PASS=31 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-error-loop.sh
EL-01 PASS 31.1 触发条件
EL-02 PASS 31.2 根因分析（5 Whys）
EL-03 PASS 31.3 修正路由（禁盲目）
EL-04 PASS 31.4 沉淀（notepad 两段）
EL-05 PASS 31.5 消费侧（Learning Gate）
EL-06 PASS 31.6 机制（开关键）
EL-07 PASS Rule 8 联动 Rule 31
EL-08 PASS SKILL.md 摘要行 Rule 31
EL-09 PASS SKILL.md C19 检查项
EL-10 PASS SKILL.md 用户新指令处理指针
EL-11 PASS SKILL.md Rules 1-3x 范围
EL-12 PASS config.json error_loop_enforce（warn 默认+三档）
EL-13 PASS progress.md 模板 Error Log 加列
EL-14 PASS task_plan.md Errors 表 Prevention 指针
EL-15 PASS notepad 模板消费侧契约
EL-16 PASS check-complete.sh Learning Gate 锚点
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-execution-stability.sh
[PASS] T1 check-scope.sh 'memories' 豁免 ≥1
[PASS] T2a plan-created.cjs '兜底清除' ≥1
[PASS] T2b plan-created.cjs 假成功旧文案行为注释在位 ('无残留哨兵' ≥1)
[PASS] T3 zcode-posttooluse.sh 'attested_by_sid|自动重锁' ≥1
[PASS] T4 attest-plan.sh 'attested_by_sid' ≥1
[PASS] T5 zcode-userpromptsubmit.sh 'CLAUDE_CODE_SESSION_ID' ≥1
[PASS] T6 check-delegation.sh 'task-planner-observe' 节流 flag ≥1
[PASS] T7 config hook_self_heal_enforce=warn (python3)
[PASS] T8a SKILL.md '环境级中断自愈' ≥1
[PASS] T8b SKILL.md 行数 ≤558
[PASS] T9a hook_self_heal_enforce 出现在 config.json+SKILL.md ≥2 文件
[PASS] T9b 无拼写变体 hook-self-heal (全 0)
[PASS] T10a knowledge-brief.md 五段 grep -c '^## §' = 5
[PASS] T10b init-session.sh '6/6' ≥1
[PASS] T11a B1 正例: 相对含 slash 路径 Edit → 自动重锁(attested_by_sid=sessabc123 且 plan_sha256=新文件哈希)
[PASS] T11b B1 负例: 改内容后 owner=othersid999 → 重锁不命中(plan_sha256 仍为旧值 且 attested_by_sid 重置为空, 不被洗白)
[PASS] T13a S5 正例: 陈旧计划+verification.md(前导空格 outcome: COMPLETE) → POSTTOOL 输出无 plan-compass/plan-sync 提醒(兜底豁免生效)
[PASS] T13b S5 因果对照: 同 fixture 删 verification.md → 输出含 plan-compass/plan-sync 陈旧提醒(豁免由兜底分支因果生效, 非环境巧合)
[PASS] T12 B2 三侧 canon 一致 (pretooluse L17 / UPS L34 / jq 全链路, sid=sess-abc123)
Total: 19  PASS=19  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-fallback.sh
[PASS] T01a probe(no-network) health.json 存在
[PASS] T01b entries=2
[PASS] T01c 全 skipped
[PASS] T02a dispatch_as=null
[PASS] T02b 含 no_health_file
[PASS] T02c escalation=split_then_takeover_or_askuser
[PASS] T03a dispatch_as=executor-fb
[PASS] T03b model=custom:pk-agg:agnes-2.5-flash
[PASS] T03c zero_cost=true
[PASS] T04 dispatch_as=null + non_provider_error
[PASS] T05a created 含 executor+explore
[PASS] T05b failures 含 code-assistant
[PASS] T05c failures 含 general-purpose
[PASS] T06a executor-fb.md 存在
[PASS] T06b 含 name_suffix 登记
[PASS] T06c model 行=custom:pk-agg:agnes-2.5-flash
[PASS] T06d 原键保留(name/description/tools)
[PASS] T06e ccr uuid 不残留
jq: error: syntax error, unexpected INVALID_CHARACTER (Unix shell quoting issues?) at <top-level>, line 1:
.files[\"executor-fb.md\"].hash       
jq: 1 compile error
jq: error: syntax error, unexpected INVALID_CHARACTER (Unix shell quoting issues?) at <top-level>, line 1:
.files[\"executor-fb.md\"].hash       
jq: 1 compile error
[PASS] T07a skipped 含 executor
[PASS] T07b created 为空
[PASS] T07c meta hash 不变
[PASS] T08 config.json provider_fallback.enabled=true
[PASS] T09a 含 timeout_split_first
[PASS] T09b 拆细指引(对照 21.1b + ② 拆细)
[PASS] T10a hint 含全序(①改派→②拆细→③降档→④主进程接管→22.3.3 技能族接管评估→⑤AskUser)
[PASS] T10b tier_order 数组 6 项
[PASS] T10c tier_order 含 split
[PASS] T10d tier_order 含 skill_takeover
[PASS] T11a escalation=split_then_takeover_or_askuser
[PASS] T11b no_healthy_channel 保留
[PASS] T11c hint 含 22.3.2 拆细再接管
Total: 31  PASS=31  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-final-gate-hash.sh
==== selftest-final-gate-hash (task-v091/S20 C-2) ====
  [PASS] 前置-键④完整性: 两脚本 jq .properties.* 消费集合==五键枚举 (fmea_enforce plan_tier_enforce subagent.step_max_files subagent.step_max_minutes subagent.step_max_steps )
  [PASS] setup: 沙箱 skill 副本+夹具计划+attest 锁定就绪
  [PASS] 基线: 全量轮 rc=0 无 SKIP, 两门实跑([plan-dispatch]+[fmea-gate] OK), 状态已落 fg_key
  [PASS] ①a: attest --verify 篡改后 rc=1 (TAMPERED 仍抓, attest 本体零改动)
  [PASS] ①b: check-complete 不 SKIP 走全量(rc=0, [plan-dispatch] 实跑在证), 篡改未被 SKIP 吞掉
  [PASS] ①c: 恢复后 attest --verify rc=0
  [PASS] ②a: plan+cpd mtime 改到 2020 后仍 SKIP×2 rc=0(缓存键不进 mtime)
  [PASS] ②b: 状态文件内容无 mtime/size 字样(提案护栏: 缓存键禁 mtime/size)
  [PASS] ③a: 未变重跑两门 SKIP-BY-HASH×2, 终态 rc=0 与全量轮一致
  [PASS] ③b: 余门照跑在证(四类余门标记命中 4/4)
  [PASS] ④a(键①): 内容变+re-attest 后不 SKIP(attest 层绿,状态层键①拦截)
  [PASS] ④b(键②): check-plan-dispatch.sh 变更后不 SKIP
  [PASS] ④c(键③): check-complete.sh FMEA 段变更后不 SKIP
  [PASS] ④d(键④/fmea_enforce): 消费键值 warn→enforce 后不 SKIP
  [PASS] ④e(键④/step_max_minutes): 消费键值 15→9 后不 SKIP
  [PASS] ④f-1: 还原后首轮全量重锁 rc=0(状态语义=最近全量通过条件, 上轮键④残留触发)
  [PASS] ④f-2: 次轮 SKIP 复效(四类突变还原完整性)
  [PASS] ⑤a: 状态缺失→全量 rc=0 且自愈重写 fg_key
  [PASS] ⑤b: 状态损坏(含 NUL)→全量 rc=0 且自愈重写
  [PASS] ⑥a: 篡改后 attest --verify rc=1(TAMPERED)
  [PASS] ⑥b: 真变化(Executor→子代理,缺 S-unit 表)全量重跑被拦 rc=1(SKIP 未吞掉门失败)
  [PASS] ⑥c: 恢复后 verify rc=0 且 SKIP 复效(失败轮未污染状态)

==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
rc=0
== skills/task-planner/scripts/selftest-fine-grain-steps.sh
SG-01 PASS 13×StepN → 13
SG-02 PASS 跨风格去重 distinct=4
SG-03 PASS enforce 13 步 → exit 2
SG-04 PASS enforce 4 步 → exit 0 静默
SG-05 PASS warn 13 步 → exit 0 + 计数落盘
SG-06 PASS 任务书 13 步 → exit 2 防绕门
SG-07 PASS 回退双分支: 剥键静默拦 / 缺 config SKIPPED+拦
SG-08 PASS 计划侧 6 步枚举 → SKIPPED 提示 exit 0
SG-09 PASS 对照无枚举 → 静默 exit 0
SG-10 PASS 条款/SKILL/模板 静态锚齐
SG-11 PASS 双脚本口径一致(=4)
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-interaction.sh
TI-01 PASS 01 (out=ask rc=0)
TI-02 PASS 02 (out=silent rc=0)
TI-03 PASS 03 (out=silent rc=0)
TI-04 PASS 04 (out=silent rc=0)
TI-05 PASS 05 (out=ask rc=0)
TI-06 PASS 06 (out=silent rc=0)
TI-07 PASS 07 (out=ask rc=0)
TI-08 PASS 08 (out=silent rc=0)
TI-09 PASS 09 (out=silent rc=0)
TI-10 PASS 10 (out=silent rc=0)
TI-11 PASS 28.2.1 static guard (critical-rules.md + SKILL.md 均含 28.2.1/思路复述)
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-iterative-optimizer.sh
IL-01 PASS iterative-optimizer/SKILL.md 存在且 frontmatter「name: iterative-optimizer」=1
IL-02 PASS SKILL.md 行数 97 ∈ [90,120]
IL-03 PASS 五步锚在位（评估 1 / 诊断弱点 1 / 定向改进 1 / 门控判定 1, 各 ≥1）
IL-04 PASS 状态文件锚 plans/loop-<task-id>-state.md 行 2 ≥1
IL-05 PASS 输入契约锚在位（≥3 条 2 / 机器可检查 5 / max_iterations 6 / 默认 5 1, 各 ≥1）
IL-06 PASS 门控铁律在位（禁止宣称 RESOLVED=1 且 连续 2 轮 3 ≥1）
IL-07 PASS 迭代摘要表头在位（改了什么 (what) 1 / 为什么 (why 1 / 门控结果 4, 各 ≥1）
IL-08 PASS banned 词（更好/大致/应该/足够）命中 0
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-knowledge-brief.sh
[PASS] T1a knowledge-brief.md 存在
[PASS] T1b 五段标题 grep -c '^## §' = 5
[PASS] T1c 行数 ≤150
[PASS] T2a SKILL.md grep 'knowledge-brief' ≥2
[PASS] T2b SKILL.md 行数 ≤558（task-v076 扩充 545; [2026-09-17 task-v080] 调研路由增补 545→548; [2026-09-20 task-v085] 机制画像增量 548→549; [2026-09-20 task-v086] Rule 38 联动 549→551, 上限 549→552; [2026-09-22 task-v087] Rule 8.1 D 类联动 551→555, 上限 552→555; [2026-09-23 task-v088] Rule 39 联动 555→558, 上限 555→558）
[PASS] T3a init-session.sh 'knowledge-brief.md' ≥2
[PASS] T3b init-session.sh '6/6' ≥1
[PASS] T4 check-scope.sh 'knowledge-brief.md' ≥1
[PASS] T5a 3file-gate '6 planning files' ≥1
[PASS] T5b 3file-gate 存在性循环首行不含 knowledge-brief (=0, KQ3)
[PASS] T6 critical-rules 21.2(142)+22.4(163) 命中且 100<行号<200（窗口放宽:Rule 21.4 演进正文膨胀,task-v110）
[PASS] T7 subagent_dispatch.md 'knowledge-brief' ≥1
[PASS] T8 plan-writer.md 'knowledge-brief|知识简略要点' ≥3
[PASS] T9 config knowledge_brief_enforce=warn (python3)
[PASS] T10a knowledge_brief_enforce 出现在 config.json+SKILL.md ≥2 文件
[PASS] T10b 无拼写变体 knowledge-brief-enforce (全 0)
Total: 16  PASS=16  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-mechanism-profile.sh
MP-01 PASS Rule 37 头
MP-02 PASS 37.1 权威源锚
MP-03 PASS 37.2 判定时点
MP-04 PASS 37.3 三类机制组
MP-05 PASS 37.4 消费侧
MP-06 PASS 37.5 机制（开关键+守护）
MP-07 PASS FMEA R1 兜底措辞
MP-08 PASS template-mapping.md §九 矩阵
MP-09 PASS 矩阵 writing/research/publish 三行不适用
MP-10 PASS SKILL.md「类型适配（Rule 37）」提示
MP-11 PASS SKILL.md C25 检查项
MP-12 PASS SKILL.md Critical Rules 列表 Rule 37 行
MP-13 PASS config.json mechanism_profile_enforce（warn 默认+三档）
MP-14 PASS task_plan.md「机制画像」≥2 处（实测 2）
MP-15 PASS template-guide.md「机制画像」（实测 1）
MP-16 PASS check-complete.sh mechanism-profile 抽查段锚
MP-17 PASS 行为: 默认档 exit 0 且打 ⚠ 提示（基线不变）
MP-18 PASS 行为: enforce 档 exit 1 且打 ✗
MP-19 PASS 行为: off 档整段跳过（exit 0, 无输出）
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-media-dispatch.sh
MD-01 PASS critical-rules.md Rule 47 子条锚 4 ≥4
MD-02 PASS critical-rules.md Rule 47 标题锚在位
MD-03 PASS SKILL.md 路由表「媒体生成工序」行 1 ≥1
MD-04 PASS SKILL.md 路由表「剧集创作管线」行 1 ≥1
MD-05 PASS SKILL.md Rule 47 摘要 bullet 1 ≥1
MD-06 PASS template-mapping.md §九兜底注「Rule 47.2」2 ≥1
MD-07 PASS template-mapping.md §十「媒体制作族」特化行 1 ≥1
MD-08 PASS config.json properties 键数 40（零新增）
MD-09 PASS 既有锚守护 21.1b=1 ≥1 且 SKILL.md「代码编辑（单文件」行 1 ≥1
Total: 9 PASS=9 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-methodology.sh
M-01 PASS config 两键存在
M-02 PASS 两键 default=warn 且 enum 长度=3
M-03 PASS methodology.md 方法名关键词 ≥9 (实测 37)
M-04 PASS 模板 FMEA 段在位 (预演=1, RPN 7 列表头 2)
M-05 PASS writing-type.md 五维评分卡指针
M-06 PASS SKILL.md methodology 指针 ≥3 (实测 4)
M-07 PASS README 21 项说明 (实测 1/2)
M-08 PASS 无 FMEA 段计划: warn 档锁定成功且 stderr 有 ⚠ (实测 rc=0 attested=y)
M-09 PASS 无 FMEA 段计划: enforce 档 (env TASK_PLANNER_FMEA_ENFORCE=enforce) attest exit 1
M-10 PASS 高 RPN(>100) 无兜底行 enforce 档 exit 1; 有兜底行通过 (实测 rc=1/0)
M-11 PASS off 档: 无 FMEA 段计划静默锁定成功 (实测 rc=0)
M-12 PASS methodology.md T1-T5 条目标题锚逐条≥1（任一节删除即红）
M-13 PASS §思维方法论章标题=1 且 同法不同时≥1 (实测 1/2)
M-14 PASS 机械联动 14 条≥1 且 9 条=0 (实测 4/0)
M-15 PASS SKILL.md 解构 bullet≥1 且 Poka-Yoke 指针≥1 (实测 1/1)
M-16 PASS plan-writer 问题解构四问契约行 (实测 1)
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-dispatch.sh
T01 PASS 01
T02 PASS 02
T03 PASS 03
T04 PASS 04
T05 PASS 05
T06 PASS attest 集成
T07 PASS 07
T08 PASS 08
T09 PASS 09
T10 PASS 10
T11 PASS 11
T12 PASS 12
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-tier.sh
PT-01 PASS Rule 38 头
PT-02 PASS 38.1 判定锚
PT-03 PASS 38.2 档位矩阵锚
PT-04 PASS 38.3 轻量模板契约锚
PT-05 PASS 38.4 豁免清单锚（铁律+VC 降档）
PT-06 PASS 38.5 机制锚（开关键+守护）
PT-07 PASS config.json plan_tier_enforce（warn 默认+三档）
PT-08 PASS SKILL.md frontmatter 索引 1-4[5-9]（task-v117+task-v118 口径扩展+task-v121 预扩，v088 级联 1-39 后继）
PT-09 PASS SKILL.md C26 检查项
PT-10 PASS SKILL.md Critical Rules 列表 Rule 38 摘要行
PT-11 PASS mini-lite 模板契约（48 行 ≤80 + plan_tier: mini 标记）
PT-12 PASS mini-lite 无六仪式区块
PT-13 PASS init-session.sh tier 分流锚（env+复制源+variant 忽略提示）
PT-14 PASS 13 variant + general 含 plan_tier: standard 标记（实测 29 处）
PT-15 PASS init 缺省场景=general 源（无 mini 标记）
PT-16 PASS init TASK_PLAN_TIER=mini 复制 mini-lite
PT-17 PASS mini+variant 定制优先+忽略提示
planmini written
PT-18 PASS 锚1: mini attest FMEA MINI-TIER SKIP + 锁定 rc=0
PT-19 PASS 锚2: mini check-complete VC=2 降档 PASSED rc=0
planbad written
PT-20 PASS 锚4: MISMATCH warn 档提示 rc=0
PT-21 PASS 锚4: MISMATCH enforce 档阻断 rc=1
PT-22 PASS 非 mini 回归: standard rc=0 且无 plan-tier 输出
PT-28 PASS mini 样例 enforce 档 attest 锁定(FMEA SKIP)+check-complete VC-GATE 均通过
PT-29 PASS auto-tier 路径: 四条件 env 提交 → mini 产物含 auto_tier: mini 标记（Rule 38.6）
PT-30 PASS 显式 mini 不打 auto_tier 标记（显式优先=不覆盖显式值）
planautobad/planautook written
PT-31 PASS AUTO-TIER 复核触发: 超限 → WARNING 点名 rc=0（warn 档不阻断）
PT-32 PASS AUTO-TIER 复核合规态: REVIEW PASSED 且无 WARNING rc=0
PT-23 PASS --list 输出内置 29 项+project 项+[default] 标记, 不创建文件
PT-24 PASS 项目 default 文件生效: 未显式 type → my-custom + frontmatter 插入
PT-25 PASS env TASK_TEMPLATE_DEFAULT=bugfix 生效(无项目 default 文件)
PT-26 PASS 全缺省零影响: 产物=general 首行且无 S6 路由/插入行
PT-27 PASS 自造模板无 template_type 行时显式指定 → 头部插入 frontmatter 行
Total: 32 PASS=32 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-reflect-verify.sh
RV-01 PASS Rule 33 头
RV-02 PASS 33.1 触发
RV-03 PASS 33.2 反思四问
RV-04 PASS 33.3 逐字 [reflect] 锚
RV-05 PASS 33.4 迭代边界（≤3 轮+升档）
RV-06 PASS 33.5 notepad What Worked 联动
RV-07 PASS 33.6 机制（开关键+REFLECT-GATE+selftest）
RV-08 PASS config.json reflect_verify_enforce（warn 默认+三档）
RV-09 PASS check-complete.sh REFLECT-GATE 锚点（gate/env/[reflect] 计数/SKIPPED 双分支）
RV-10 PASS SKILL.md 'Rules 1-3[5-9]' 宽容锚索引行（兼容 1-35/1-36/1-37/1-38 过渡）
RV-11 PASS SKILL.md 检查清单 C21 行
RV-12 PASS SKILL.md「解决后反思-验证循环」段
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-registry.sh
T01 PASS
T02 PASS
T03 PASS
T04 PASS
T05 PASS
Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)
rc=0
== skills/task-planner/scripts/selftest-reliability-institution.sh
R-01 PASS critical-rules.md Rule 42 子条锚 = 10
R-02 PASS critical-rules.md Rule 43 四子条锚 = 4
R-03 PASS 42.2 行内锚「均未命中=缺口」在位
R-04 PASS 42.3 行内锚「S-unit 登记」在位
R-05 PASS 43.1 行内锚「未验证」在位
R-06 PASS 43.2 行内锚「最小档位」在位
R-07 PASS 43.3 行内锚「候选对比表」在位
R-08 PASS SKILL.md C30/C31 合规清单项各 =1
R-09 PASS SKILL.md「含 Rule 40/41/42/43」锚 1 ≥1 且越界 1-40 =0
R-10 PASS 模板「质量审查工具」行 1 ≥1 且 plan-writer「质量审查工具检测登记」义务行 1 ≥1
R-11 PASS mini-lite「Rule 42.5 豁免」声明行 1 ≥1
R-12 PASS config.json properties 键数 40（零新增）
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rescue-chain.sh
T01 PASS
T02 PASS
T03 PASS
T04 PASS
T05 PASS
T06a PASS
T06b PASS (jq 解析 .violations[0].line==5)
T07 PASS
T08 PASS
T09 PASS
T10 PASS
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-review-library.sh
RL-01 PASS review-library/ 目录数 = 11
RL-02 PASS 11 个目录名与清单精确一致
RL-03 PASS 11 目录各含 SKILL.md
RL-04 PASS 11 个 SKILL.md frontmatter name/description 全在位
RL-05 PASS 11 个 SKILL.md APPROVED/CHANGES_REQUESTED/Rule 43.1 全在位
RL-06 PASS 11 个 SKILL.md 清单条目均 ≥10
RL-07 PASS 11 个 SKILL.md 四要素标题全在位
RL-08 PASS SKILL.md C30 项 =1 且「四级顺序」2 ≥1
RL-09 PASS CRIT 42.2 池主体锚 ≥1 / 均未命中=缺口 ≥1 / 三级检测顺序 =0
RL-10 PASS 全池 11 文件 1-4[0-9] 越界字面零命中
RL-11 PASS alignment-review 验证优先锚：写入前校验 3 ≥2 / 未经一致性校验 1 =1 / 变更记录输出 3 ≥1
RL-12 PASS alignment-review 闸门深化锚：全文扫描 2 ≥1 / 删除或归档 4 ≥1 / 变更范围 1 ≥1
RL-13 PASS 42.6.3 三要素升级锚：CRIT 42.6.3 行三要素 1 ≥1 / SKILL.md C32 行三要素 1 ≥1
RL-14 PASS smart-merge-back 池挂载函数+冲突跳过锚在位
RL-15 PASS install-companion 池分发+独立 skill 不覆盖锚在位
Total: 15 PASS=15 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rule23-conflict-scan.sh
R23-01 PASS 在途第二计划命中 scope → 报 [conflict]
R23-02 PASS 完结计划被豁免
R23-03 PASS 无指针过期在途计划仍被扫到
Total: 3 PASS=3 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-self-resolution.sh
SR-01 PASS critical-rules.md 六子条锚 = 6
SR-02 PASS critical-rules.md G1/G4 门槛锚各 ≥1
SR-03 PASS 「已尝试清单」+「D6 硬停点语义保留不弱化」措辞锚在位
SR-04 PASS trivial 裁定措辞「直接做」+「留用户裁决」在位
SR-05 PASS 41.6 行内锚（零新 config 键 / selftest-self-resolution.sh）在位
SR-06 PASS SKILL.md Rule 41 锚 3 ≥3 且 C29 项 =1
SR-07 PASS SKILL.md 字面锚 Rules 1-39=2 且 1-40=0
SR-08 PASS SKILL.md「含 Rule 40/41」锚 + critical-rules.md Rule 40 六子条 = 6（共存零损伤）
SR-09 PASS config.json properties 键数 40（零新增）
SR-10 PASS SKILL.md 摘要行锚「升级四门槛」在位
SR-11 PASS selftest-skill-split.sh task-v099/task-v1x label + -le 4 前缀断言行在位
SR-12 PASS registry selftest-self-resolution 登记行 ≥1 且总行数 45=脚本数+表头（动态）
SR-13 PASS 22.3.0 资料先行档行存在 + 资料先行/换道评估顺序/官方文档 关键词在位
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-shared-tracker.sh
ST-01 PASS 30.1 识别条件
ST-02 PASS 30.2 创建/复用（progress-tracker 权威源）
ST-03 PASS 30.3 认领登记（禁悬挂）
ST-04 PASS 30.4 防冲突（重复认领 D4）
ST-05 PASS 30.5 机制（开关键）
ST-06 PASS SKILL.md 摘要行 Rule 30
ST-07 PASS SKILL.md 设计期检查点
ST-08 PASS config.json shared_tracker_enforce（warn 默认+三档）
ST-09 PASS templates/shared-tracker.md 存在
ST-10 PASS skill-collab 矩阵 progress-tracker 行
ST-11 PASS progress-tracker 技能探针（存在）
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-collab.sh
[PASS] T1a 文件存在
[PASS] T1b 行数 ≤300
[PASS] T1c 含 三族
[PASS] T1d 含 触发矩阵
[PASS] T1e 含 22.3.3
[PASS] T1f 含 移交
[PASS] T2a SKILL.md 含 专业技能协同路由
[PASS] T2b skill-collaboration.md 引用 ≥2
[PASS] T3 SKILL.md 含 任意 3 项
[PASS] T4 行号序 22.3.1(161) < 22.3.3(162) < 22.4(163)
[PASS] T5 22.7 行含 22.3.3 协同接管评估
[PASS] T6a skill_takeover ≥1
[PASS] T6b tier_order 全串 2 处(timeout+non_provider)
[PASS] T7 config skill_collab_enforce=warn (python3)
[PASS] T8a collaboration.md 含 command -v comet
[PASS] T8b SKILL.md 含 command -v comet
[PASS] T9a skill_collab_enforce 出现在 ≥2 文件
[PASS] T9b 无连字符变体 skill-collab-enforce
[PASS] T10 SKILL.md 行数 ≤558
[PASS] T11a 调研链含 browser-use 插件路由(SKILL.md≥3 或 routing.md 合计≥3)
[PASS] T11b 调研链 research-assistant 主通道定位
[PASS] T11c 平台适配声明(禁假设不存在 MCP, 恰 1 行)
[PASS] T11d SKILL.md 路由表网页访问行
[PASS] T12a collab 矩阵 research-assistant 行
[PASS] T12b collab 矩阵 browser-use 行
Total: 25  PASS=25  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-modify.sh
SM-01 PASS 36 标题
SM-02 PASS 36.1-36.7 七子条锚齐全
SM-03 PASS 36.2 衔接 31.3 + 36.4 引 D6
SM-04 PASS config.json skill_modify_enforce（warn 默认+三档）
SM-05 PASS check-skill-modify.sh 存在+可执行+语法
SM-06 PASS zcode-pretooluse.sh 接线
SM-07 PASS check-complete.sh GATE 锚+tier 函数
SM-08 PASS SKILL.md Rule 36 行（P4 联动已实，A=6 B=1）
SM-08 PASS SKILL.md C24 检查项（P4 联动已实, A=6 B=1）
Total: 9 PASS=9 FAIL=0 (SKIP=0)
rc=0
== skills/task-planner/scripts/selftest-skill-split.sh
[PASS] T-plan-research-router 目录+SKILL.md 存在
[PASS] T-plan-research-router name 与目录名一致
[PASS] T-plan-research-router SKILL.md <100 行(薄正文)
[PASS] T-plan-template-kit 目录+SKILL.md 存在
[PASS] T-plan-template-kit name 与目录名一致
[PASS] T-plan-template-kit SKILL.md <100 行(薄正文)
[PASS] T-plan-cost-guard 目录+SKILL.md 存在
[PASS] T-plan-cost-guard name 与目录名一致
[PASS] T-plan-cost-guard SKILL.md <100 行(薄正文)
[PASS] T-plan-collab-router 目录+SKILL.md 存在
[PASS] T-plan-collab-router name 与目录名一致
[PASS] T-plan-collab-router SKILL.md <100 行(薄正文)
[PASS] T-主 行数 ≤447（task-v122 Rule 47 联动 +3;演进 440→442→444→447）且 ≤558 上限
[PASS] T-主 路由指针在位 plan-research-router ≥1
[PASS] T-主 路由指针在位 plan-template-kit ≥1
[PASS] T-主 路由指针在位 plan-cost-guard ≥1
[PASS] T-主 路由指针在位 plan-collab-router ≥1
[PASS] T-迁 research-routing.md 含 强制引用格式
[PASS] T-迁 template-guide.md 存在
[PASS] T-迁 template-mapping.md 存在
[PASS] T-迁 template-guide.md 含 29 个
[PASS] T-迁 cost-control.md 存在
[PASS] T-迁 billing.md 存在
[PASS] T-迁 cost_log.md 存在
[PASS] T-迁 skill-collaboration.md 存在
[PASS] T-迁 skill-collaboration.md ≤300 行
[PASS] T-死 references/research-routing.md 零残留(plan- 过滤后, N=0)
[PASS] T-死 references/template-guide.md 零残留(plan- 过滤后, N=0)
[PASS] T-死 references/template-mapping.md 零残留(plan- 过滤后, N=0)
[PASS] T-死 references/cost-control.md 零残留(plan- 过滤后, N=0)
[PASS] T-死 references/skill-collaboration.md 零残留(plan- 过滤后, N=0)
[PASS] T-锚 Rule 17 成本控制
[PASS] T-锚 C19 行在位
[PASS] T-锚 C25 行在位
[PASS] T-锚 C26 行在位
[PASS] T-锚 Rules 1-3 计数锚 ≥1
[PASS] T-守 check-skill-modify.sh 含 plan-research-router
[PASS] T-守 check-skill-modify.sh 含 plan-template-kit
[PASS] T-守 check-skill-modify.sh 含 plan-cost-guard
[PASS] T-守 check-skill-modify.sh 含 plan-collab-router
[PASS] T-reg registry.tsv 含 selftest-skill-split 行
Total: 41  PASS=41  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-smart-merge.sh
SM-01 PASS rc=3(期望3) PRECHECK_DIRTY=在
SM-02 PASS rc=0(期望0) MERGED=在
SM-03 PASS rc=0(期望0) ALREADY=在 master无新commit=是 无MERGE_HEAD残留(绝对路径 /tmp/tmp.Vp3jvH6DYd/main/.git/MERGE_HEAD)=是
SM-04a PASS rc=5(期望5) MASTER_AHEAD=在
SM-04b PASS --force rc=0(期望0) MERGED=在
SM-05 PASS rc=4(期望4) SCOPE_OVERLAP=在 交集含base.txt=在
SM-06 PASS rc=6(期望6) s1-IDENTICAL=在 s2-DRIFT=在
SM-07 PASS rc=0 CLEANUP行=在 worktree保留=是
SM-08 PASS rc=6(期望6) REJECTED行数=3(期望≥3) wt-md5不变=是 main未被部署替换=是
SM-09 PASS rc=6(期望6) REJECTED含空格=在
Deleted branch wt/task-test (was 4dbb59b).
SM-10 PASS rc=6(期望6) 真实wt注入=是 REJECTED祖先=在 slot=/tmp/tmp.bMf3BpLqEB/ancestor(guard=/tmp/tmp.bMf3BpLqEB/ancestor/task-test) 零改动=是
SM-11 PASS rc=8(期望8) MERGE_IN_PROGRESS=在
SM-12 PASS rc=6(期望6) HOME内部白名单外REJECTED=在 白名单拒绝原因=在 zcode存活+清单md5不变=是
SM-13 PASS rc=6(期望6) 部署根内主仓exact-REJECTED(= 受保护路径)=在 .git存活=是 主仓根清单md5不变=是
SM-14 PASS rc=0(期望0) IDENTICAL=在 slotB-SKILL_MARKER=canonical-v077(期望canonical-v077非stale-content)
SM-15a PASS P15基线(抽取含deploy_reconcile定义+LC_ALL=C comm钉)=在 zh-locale rc=1(期望1) DRIFT-L2=在 B.md入DRIFT明细=在
SM-15b PASS C-locale rc=1(期望1) 与15a-zh逐字节一致=是
Total: 17 PASS=17 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-sync-index.sh
T01 PASS 01
T02 PASS 02
T03 PASS 03
T04 PASS 04
T05 PASS 05
T06 PASS 06
T07 PASS 07
T08 PASS 08
T09 PASS 09
T10 PASS 10
T11 PASS 11
T12 PASS 12
T13 PASS 13
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-task-boundary.sh
TB-01 PASS 8.1 新任务边界子条
TB-02 PASS 8.1 判定依据三要素
TB-03 PASS 8.1 处置语义锚
TB-04 PASS Rule 8 原文未改动
TB-05 PASS SKILL.md D 行
TB-06 PASS SKILL.md D 特判段
TB-07 PASS SKILL.md C12 扩 D/A/B/C
TB-08 PASS UPS hook [plan-note] D 类指引
TB-09 PASS UPS hook 职责 3 注释联动
TB-10 PASS todo-sync.md S5 D 类分支
TB-11 PASS SKILL.md 漂移触发时机行兼容
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-lifecycle.sh
TL-01 PASS Rule 34 头
TL-02 PASS 34.1 选取门控
TL-03 PASS 34.2 四点同步
TL-04 PASS 34.3 沉淀触发三条件
TL-05 PASS 34.4 沉淀流程（≤100 行+登记）
TL-06 PASS 34.5 防滥用（查重）
TL-07 PASS 34.6 机制（开关键+门控+selftest）
TL-08 PASS config.json template_gate_enforce（warn 默认+三档）
TL-09 PASS check-template-type.sh 动态派生白名单
TL-10 PASS attest 集成门控+逃生
TL-11 PASS init-session env 兜底+动态派生
TL-12 PASS 行为: bugfix 计划 exit 0
TL-13 PASS 行为: nonexistent 计划 exit 1
TL-14 PASS SKILL.md 检查清单 C22 行
TL-15 PASS SKILL.md「模板选取门控与沉淀」段
TL-16 PASS template-mapping.md Rule 34 门控提示
TL-17 PASS template-guide.md 含 rule-enhancement 且计数 29 个
TL-18 PASS template-mapping.md 含 §九 机制适用性矩阵
TL-19 PASS delivery-summary.md 存在且五区块=5
TL-20 PASS SKILL.md 含 delivery-summary 指针 ≥2
TL-21 PASS template-guide.md 口径句含 delivery-summary.md
Total: 21 PASS=21 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-sense.sh
case-1 PASS general 空缺 → 输出含 [template-sense] 且 task_plan.md 含「🔁 模板感知」
case-2 PASS unknown 类型 foobar → 输出含 [template-sense] 且 task_plan.md 含「🔁 模板感知」
case-3 PASS known 类型 bugfix → [template-sense] 计 0（输出与产物区块均零触发）
case-4 PASS critical-rules 34.7 恰 1 条且含「全自动生成合约」; SKILL.md C22 行含「34.7 全自动生成」
case-5 PASS 含区块且无登记 → [template-sense] warn; 无区块计划 → 零 [template-sense] 输出
case-6 PASS selftest-registry.tsv 含本脚本登记行且 dep_anchors 四条在位
case-7 PASS mini 档空类型 → mini-lite 产物带标记, 无感知区块、无 general 注释（CR P1-1 负例通过）
case-8 PASS bugfix 后空类型重跑 → 产物标记仍 bugfix 且无感知区块（CR P1-2 负例通过）
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tier-b.sh
TB-01 PASS mini 业务文件直做放行
TB-02 PASS mini 保护区仍拦截
TB-03 PASS 非 mini 不受通道影响
TB-04 PASS Rule 14 ④ 通道条款在位
TB-05 PASS mini 无声明缺省 silent
TB-06 PASS mini 显式 ask 优先
TB-07 PASS standard 档不受影响
TB-08 PASS mini-lite 单 Phase 锚
TB-09 PASS 38.3 契约同步
TB-10 PASS 22.8.2 T5 豁免句
TB-11 PASS 19.2 一行声明句
TB-12 PASS SKILL CR 分级句
TB-13 PASS 验证流程合并句
TB-14 PASS 只读声明+标记槽占用放行
TB-15 PASS 写类槽占用仍拦截
TB-16 PASS 双条件缺声明仍拦
TB-17 PASS 槽空闲写类正常
TB-18 PASS 21.4 豁免子条在位
Total: 18 PASS=18 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tool-selection.sh
TS-01 PASS critical-rules.md 六子条锚 = 6
TS-02 PASS 40.3 披露措辞「不可代调」命中 2
TS-03 PASS 40.4 显式点名 + 40.6 零新 config 键 行内锚在位
TS-04 PASS SKILL.md Rule 40 锚命中 5 ≥3
TS-05 PASS SKILL.md 字面锚 Rules 1-39=2 且 1-40=0
TS-06 PASS SKILL.md 既有三锚（Rule 39 摘要行/C27/协同路由 dynamic-workflows）保全
TS-07 PASS SKILL.md C28 清单项在位
TS-08 PASS general 模板 🧰 区块与「上游分析记录」定位声明在位
TS-09 PASS mini-lite 豁免声明 =1 且 48 行 ≤80
TS-10 PASS subagent_dispatch 工具面提示行在位
TS-11 PASS 卫星两文档 + plan-writer 契约锚在位
TS-12 PASS config.json properties 键数 40（零新增）
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-vc-gate.sh
T01 PASS
T02 PASS
T02b PASS
T03 PASS
T03b PASS
T04 PASS
T05 PASS
T06 PASS
T07 PASS
T08 PASS
T09 PASS
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-veto.sh
VT-01 PASS 32.1 禁令登记
VT-02 PASS 32.2 计划期必查
VT-03 PASS 32.3 执行期消费
VT-04 PASS 32.4 解禁条件（两条）
VT-05 PASS 32.5 机制（开关键）
VT-06 PASS 31.5 消费侧联动 Rule 32
VT-07 PASS SKILL.md 摘要行 Rule 32
VT-08 PASS SKILL.md C20 检查项
VT-09 PASS SKILL.md 用户否决登记指针
VT-10 PASS SKILL.md Rules 1-3x 范围
VT-11 PASS config.json veto_enforce（warn 默认+三档）
VT-12 PASS notepad 模板被否决方案段
VT-13 PASS 无禁令项作 Recommended 矛盾表述
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-workflow-orchestration.sh
WF-01 PASS Rule 39 头
WF-02 PASS 39.1 触发纪律锚
WF-03 PASS 39.3 四机制映射锚
WF-04 PASS 39.4 并行豁免锚
WF-05 PASS 39.5 机器校验边界锚
WF-06 PASS 39.6 机制锚（零新 config 键）
WF-07 PASS SKILL.md Rule 39 摘要行
WF-08 PASS SKILL.md C27 清单项
WF-09 PASS SKILL.md 协同路由 dynamic-workflows 行
WF-10 PASS 4 索引文档 Rules 1-39+1-45 命中总和 6 ≥6
WF-11 PASS Rules 1-38 残留 0
WF-12 PASS config.json properties 键数 40（零新增）
WF-13 PASS 39.7 动态激活边界锚（三子条 + 39.5 观察面注记）
WF-14 PASS 用户级 skills 目录无 dynamic-workflows 副本（39.7.2 负断言）
WF-15 PASS zcode-pretooluse.sh 39.7.3 workflow 观察分支（观察文案在位且零阻断）
WF-16 PASS register-hooks-cj.ts matcher 含 workflow 四工具（39.7.3 观察面扩围）
Total: 16 PASS=16 FAIL=0
rc=0

## 复核结论

- 44/44 脚本全部执行，rc=0 共 44 条，无跳过（无单脚本超 60s 情形）。
- 43 个脚本以 `Total: N PASS=N FAIL=0` 原文行收尾；selftest-final-gate-hash.sh 以 `==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====` 收尾（该脚本输出格式为"结果:"而非"Total:"，仍为 FAIL=0 通过证据）。
- 全日志 `FAIL=[非0]` 出现次数 = 0（grep 计数 0）。
- 无 FAIL 明细；无跳过项。
- 置信度 HIGH（全部证据为本会话原始输出，未引用任何既有日志）。

## 8 字段返回块（同返回给主进程）

```
status: done
acceptance: 3/3 pass —
== skills/task-planner/scripts/selftest-active-plan.sh
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-ask-default-timeout.sh
Total: 9 PASS=9 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-batch-pilot.sh
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-conflicts.sh
Total: 7 PASS=7 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-check-drift.sh
Total: 6 PASS=6 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-conclusion-discipline.sh
Total: 24 PASS=24 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-context-hygiene.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-delegation.sh
Total: 38    PASS=38  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-dispatch-grain.sh
Total: 10 PASS=10 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-dispatch.sh
Total: 31 PASS=31 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-error-loop.sh
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-execution-stability.sh
Total: 19  PASS=19  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-fallback.sh
Total: 31  PASS=31  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-final-gate-hash.sh
==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
rc=0
== skills/task-planner/scripts/selftest-fine-grain-steps.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-interaction.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-iterative-optimizer.sh
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-knowledge-brief.sh
Total: 16  PASS=16  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-mechanism-profile.sh
Total: 19 PASS=19 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-media-dispatch.sh
Total: 9 PASS=9 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-methodology.sh
Total: 16 PASS=16 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-dispatch.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-plan-tier.sh
Total: 32 PASS=32 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-reflect-verify.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-registry.sh
Total: 5 PASS=5 FAIL=0 (registry rows=44, actual selftest=44)
rc=0
== skills/task-planner/scripts/selftest-reliability-institution.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rescue-chain.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-review-library.sh
Total: 15 PASS=15 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-rule23-conflict-scan.sh
Total: 3 PASS=3 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-self-resolution.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-shared-tracker.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-collab.sh
Total: 25  PASS=25  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-skill-modify.sh
Total: 9 PASS=9 FAIL=0 (SKIP=0)
rc=0
== skills/task-planner/scripts/selftest-skill-split.sh
Total: 41  PASS=41  FAIL=0
rc=0
== skills/task-planner/scripts/selftest-smart-merge.sh
Total: 17 PASS=17 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-sync-index.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-task-boundary.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-lifecycle.sh
Total: 21 PASS=21 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-template-sense.sh
Total: 8 PASS=8 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tier-b.sh
Total: 18 PASS=18 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-tool-selection.sh
Total: 12 PASS=12 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-vc-gate.sh
Total: 11 PASS=11 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-veto.sh
Total: 13 PASS=13 FAIL=0
rc=0
== skills/task-planner/scripts/selftest-workflow-orchestration.sh
Total: 16 PASS=16 FAIL=0
rc=0
evidence: `for f in skills/task-planner/scripts/selftest-*.sh; do echo "== $f"; bash "$f"; echo "rc=$?"; done`（cwd=worktree）→ 44 条 `rc=0`；43 条 `Total: N PASS=N FAIL=0` + selftest-final-gate-hash 以 `结果: PASS=22 FAIL=0` 收尾；全日志 `grep -c 'FAIL=[^0]'` = 0；全量原始日志存于 subagent-state/m7-executor.log（836 行）
files: /mnt/data/dev/task-planner-skill/plans/task-v122/verification.md(+复核证据段,/-0); /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/m7-executor.md(新建)
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v122/subagent-state/m7-executor.md (status: done)
findings_written: none
blockers: none
confidence: HIGH
```
