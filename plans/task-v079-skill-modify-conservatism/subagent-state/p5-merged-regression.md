# 合并后 master 全量回归（8aba15d, 2026-09-17 07:10:30）
## selftest-active-plan.sh
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
exit=0
## selftest-conclusion-discipline.sh
CD-01 PASS critical-rules.md 含 '### 35 执行结论纪律'
CD-02 PASS 35.1 触发条款存在
CD-03 PASS 35.2 能力否定三关条款存在
CD-04 PASS 35.3 大输入落盘引用条款存在
CD-05 PASS 35.4 结论上报措辞条款存在
CD-06 PASS 35.5 消费侧条款存在
CD-07 PASS 35.6 机制条款存在
CD-08 PASS 22.4 行含 'Rule 35.3 大输入落盘引用'
CD-09 PASS SKILL.md 含 'Rule 35（P0）执行结论纪律' 列表行
CD-10 PASS SKILL.md 含 '| C23 |' 检查项行
CD-11 PASS SKILL.md '1-3[56]' 计数 ≥3（兼容 1-35/1-36 过渡，当前=3）
CD-12 PASS SKILL.md 不含 '1-34'（防回退，当前=0）
CD-13 PASS SKILL.md 含 'Rule 35.3 大输入落盘引用'（五档兜底引用注）
CD-14 PASS check-dispatch.sh 含 '补救(Rule 35.3)'
CD-15 PASS check-dispatch.sh 仍含 '⚠ prompt 长度'（selftest-dispatch FG 依赖）
CD-16 PASS subagent_dispatch.md 含 '超限补救(Rule 35.3)'
CD-17 PASS notepad-learnings.md 含 '🚫 被否决方案' 段
CD-18 PASS README.md 含 'Rules 1-3[56]' 宽容锚（兼容 1-35/1-36 过渡）
CD-19 PASS batch-quality-gate.md 含 '隶属 Rules 1-3[56]' 宽容锚（兼容 1-35/1-36 过渡）
CD-20 PASS plan-writer.md 含 '纯数字'（s_unit_id 契约行）
CD-21 PASS task_plan.md 含 'ID 列一律纯数字'（④ 注释行）
CD-22 PASS subagent_dispatch.md 含 '机械求和'（禁自报汇总行）
CD-23 PASS smart-merge-back.sh 含 'DEPLOY_SRC' 且含 '禁回退 SKILL_ROOT'（fail-closed）
Total: 23 PASS=23 FAIL=0
exit=0
## selftest-context-hygiene.sh
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
exit=0
## selftest-delegation.sh

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
exit=0
## selftest-dispatch.sh
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
TS-01 PASS (rc=0, 锁写入=1789600244)
TS-02 PASS (rc=2, stderr 含 串行)
TS-03 PASS (rc=0, stderr 含 串行警告)
TS-04 PASS (rc=0, 锁刷新=1789600245)
TS-05 PASS (rc=0, 锁未改写)
TS-06 PASS (rc=0, 锁已清除)
FG-01 PASS (rc=0, 零细粒度输出, 基线一致)
FG-02 PASS (rc=0, warn 告警+计数落盘)
FG-03 PASS (rc=0, 双 S-unit 打包检出)
FG-04 PASS (rc=0, brief 引用提示)
FG-05 PASS (双条件豁免: SKIPPED 提示, 未判打包)
Total: 23 PASS=23 FAIL=0
exit=0
## selftest-error-loop.sh
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
exit=0
## selftest-execution-stability.sh
[PASS] T1 check-scope.sh 'memories' 豁免 ≥1
[PASS] T2a plan-created.cjs '兜底清除' ≥1
[PASS] T2b plan-created.cjs 假成功旧文案行为注释在位 ('无残留哨兵' ≥1)
[PASS] T3 zcode-posttooluse.sh 'attested_by_sid|自动重锁' ≥1
[PASS] T4 attest-plan.sh 'attested_by_sid' ≥1
[PASS] T5 zcode-userpromptsubmit.sh 'CLAUDE_CODE_SESSION_ID' ≥1
[PASS] T6 check-delegation.sh 'task-planner-observe' 节流 flag ≥1
[PASS] T7 config hook_self_heal_enforce=warn (python3)
[PASS] T8a SKILL.md '环境级中断自愈' ≥1
[PASS] T8b SKILL.md 行数 ≤548
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
exit=0
## selftest-fallback.sh
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
exit=0
## selftest-interaction.sh
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
exit=0
## selftest-knowledge-brief.sh
[PASS] T1a knowledge-brief.md 存在
[PASS] T1b 五段标题 grep -c '^## §' = 5
[PASS] T1c 行数 ≤150
[PASS] T2a SKILL.md grep 'knowledge-brief' ≥2
[PASS] T2b SKILL.md 行数 ≤545（task-v076 扩充）
[PASS] T3a init-session.sh 'knowledge-brief.md' ≥2
[PASS] T3b init-session.sh '6/6' ≥1
[PASS] T4 check-scope.sh 'knowledge-brief.md' ≥1
[PASS] T5a 3file-gate '6 planning files' ≥1
[PASS] T5b 3file-gate 存在性循环首行不含 knowledge-brief (=0, KQ3)
[PASS] T6 critical-rules 21.2(115)+22.4(127) 命中且 100<行号<135
[PASS] T7 subagent_dispatch.md 'knowledge-brief' ≥1
[PASS] T8 plan-writer.md 'knowledge-brief|知识简略要点' ≥3
[PASS] T9 config knowledge_brief_enforce=warn (python3)
[PASS] T10a knowledge_brief_enforce 出现在 config.json+SKILL.md ≥2 文件
[PASS] T10b 无拼写变体 knowledge-brief-enforce (全 0)
Total: 16  PASS=16  FAIL=0
exit=0
## selftest-methodology.sh
M-01 PASS config 两键存在
M-02 PASS 两键 default=warn 且 enum 长度=3
M-03 PASS methodology.md 方法名关键词 ≥9 (实测 33)
M-04 PASS 模板 FMEA 段在位 (预演=1, RPN 7 列表头 2)
M-05 PASS writing-type.md 五维评分卡指针
M-06 PASS SKILL.md methodology 指针 ≥3 (实测 3)
M-07 PASS README 21 项说明 (实测 1/2)
M-08 PASS 无 FMEA 段计划: warn 档锁定成功且 stderr 有 ⚠ (实测 rc=0 attested=y)
M-09 PASS 无 FMEA 段计划: enforce 档 (env TASK_PLANNER_FMEA_ENFORCE=enforce) attest exit 1
M-10 PASS 高 RPN(>100) 无兜底行 enforce 档 exit 1; 有兜底行通过 (实测 rc=1/0)
M-11 PASS off 档: 无 FMEA 段计划静默锁定成功 (实测 rc=0)
Total: 11 PASS=11 FAIL=0
exit=0
## selftest-plan-dispatch.sh
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
exit=0
## selftest-reflect-verify.sh
RV-01 PASS Rule 33 头
RV-02 PASS 33.1 触发
RV-03 PASS 33.2 反思四问
RV-04 PASS 33.3 逐字 [reflect] 锚
RV-05 PASS 33.4 迭代边界（≤3 轮+升档）
RV-06 PASS 33.5 notepad What Worked 联动
RV-07 PASS 33.6 机制（开关键+REFLECT-GATE+selftest）
RV-08 PASS config.json reflect_verify_enforce（warn 默认+三档）
RV-09 PASS check-complete.sh REFLECT-GATE 锚点（gate/env/[reflect] 计数/SKIPPED 双分支）
RV-10 PASS SKILL.md 'Rules 1-3[56]' 宽容锚索引行（兼容 1-35/1-36 过渡）
RV-11 PASS SKILL.md 检查清单 C21 行
RV-12 PASS SKILL.md「解决后反思-验证循环」段
Total: 12 PASS=12 FAIL=0
exit=0
## selftest-rescue-chain.sh
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
exit=0
## selftest-shared-tracker.sh
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
exit=0
## selftest-skill-collab.sh
[PASS] T1a 文件存在
[PASS] T1b 行数 ≤300
[PASS] T1c 含 三族
[PASS] T1d 含 触发矩阵
[PASS] T1e 含 22.3.3
[PASS] T1f 含 移交
[PASS] T2a SKILL.md 含 专业技能协同路由
[PASS] T2b skill-collaboration.md 引用 ≥2
[PASS] T3 SKILL.md 含 任意 3 项
[PASS] T4 行号序 22.3.1(125) < 22.3.3(126) < 22.4(127)
[PASS] T5 22.7 行含 22.3.3 协同接管评估
[PASS] T6a skill_takeover ≥1
[PASS] T6b tier_order 全串 2 处(timeout+non_provider)
[PASS] T7 config skill_collab_enforce=warn (python3)
[PASS] T8a collaboration.md 含 command -v comet
[PASS] T8b SKILL.md 含 command -v comet
[PASS] T9a skill_collab_enforce 出现在 ≥2 文件
[PASS] T9b 无连字符变体 skill-collab-enforce
[PASS] T10 SKILL.md 行数 ≤548
Total: 19  PASS=19  FAIL=0
exit=0
## selftest-skill-modify.sh
SM-01 PASS 36 标题
SM-02 PASS 36.1-36.7 七子条锚齐全
SM-03 PASS 36.2 衔接 31.3 + 36.4 引 D6
SM-04 PASS config.json skill_modify_enforce（warn 默认+三档）
SM-05 PASS check-skill-modify.sh 存在+可执行+语法
SM-06 PASS zcode-pretooluse.sh 接线
SM-07 PASS check-complete.sh GATE 锚+tier 函数
SM-08 PASS SKILL.md Rule 36 行（P4 联动已实，A=5 B=1）
SM-08 PASS SKILL.md C24 检查项（P4 联动已实, A=5 B=1）
Total: 9 PASS=9 FAIL=0 (SKIP=0)
exit=0
## selftest-smart-merge.sh
SM-01 PASS rc=3(期望3) PRECHECK_DIRTY=在
SM-02 PASS rc=0(期望0) MERGED=在
SM-03 PASS rc=0(期望0) ALREADY=在 master无新commit=是 无MERGE_HEAD残留(绝对路径 /tmp/tmp.eIyq3ixo0P/main/.git/MERGE_HEAD)=是
SM-04a PASS rc=5(期望5) MASTER_AHEAD=在
SM-04b PASS --force rc=0(期望0) MERGED=在
SM-05 PASS rc=4(期望4) SCOPE_OVERLAP=在 交集含base.txt=在
SM-06 PASS rc=6(期望6) s1-IDENTICAL=在 s2-DRIFT=在
SM-07 PASS rc=0 CLEANUP行=在 worktree保留=是
SM-08 PASS rc=6(期望6) REJECTED行数=3(期望≥3) wt-md5不变=是 main未被部署替换=是
SM-09 PASS rc=6(期望6) REJECTED含空格=在
Deleted branch wt/task-test (was 974f5e6).
SM-10 PASS rc=6(期望6) 真实wt注入=是 REJECTED祖先=在 slot=/tmp/tmp.wmUoD434xZ/ancestor(guard=/tmp/tmp.wmUoD434xZ/ancestor/task-test) 零改动=是
SM-11 PASS rc=8(期望8) MERGE_IN_PROGRESS=在
SM-12 PASS rc=6(期望6) HOME内部白名单外REJECTED=在 白名单拒绝原因=在 zcode存活+清单md5不变=是
SM-13 PASS rc=6(期望6) 部署根内主仓exact-REJECTED(= 受保护路径)=在 .git存活=是 主仓根清单md5不变=是
SM-14 PASS rc=0(期望0) IDENTICAL=在 slotB-SKILL_MARKER=canonical-v077(期望canonical-v077非stale-content)
Total: 15 PASS=15 FAIL=0
exit=0
## selftest-template-lifecycle.sh
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
TL-17 PASS template-guide.md 含 rule-enhancement 且计数 13 个
Total: 17 PASS=17 FAIL=0
exit=0
## selftest-vc-gate.sh
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
exit=0
## selftest-veto.sh
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
exit=0
