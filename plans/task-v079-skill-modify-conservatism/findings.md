# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 防技能偷渡修改：执行期技能报错时禁止盲目改技能（先 4 维归因，归因指向本体才可提案）
- 防功能静默移除：事故样本=文章优化技能「流量分级优化」功能（流量多→微调/流量少→深度优化）被未知时点删除→高流量旧文被彻底重构、流量尽失
- 技能修改默认保守（纯增量优先）；功能性删除/语义改写须请求用户确认

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
- [2026-09-17 P3/S7] selftest-skill-modify.sh 新建（61 行，SM-01..08）：主进程亲跑 7 PASS+2 SKIP（SM-08 SKILL 锚两段策略=P4 联动后自动转实断言）rc=0。S8 前锚行考古：CD-11=SKILL '1-35' 计数≥3 / CD-18=README 'Rules 1-35' / CD-19=batch-gate '隶属 Rules 1-35' / RV-10=SKILL 严格 'Rules 1-35' / VT-10+EL-11=宽容 1-3[1-5]。**S8 策略修正（silent 决策）**：严格锚改宽容 `1-3[56]`（S8 时 SKILL 仍 1-35 亦 PASS，P4 后 1-36 仍 PASS；严格态由 S9 残留 grep=0+SM-08 保证）——计划原文「严格锚改 1-36」在 S8 时序上自相矛盾，取舍就验收
- [2026-09-17 P2/S6] SKILL-MODIFY GATE 落地 check-complete.sh REFLECT-GATE 尾后（+35 行 0 删除）：resolve_skill_modify_tier 三档（env>jq>warn fail-open）；SKIPPED=off/未声明技能修改/无 progress.md；PASS=「删除性行为清单」或 `[skill-modify] 无功能性删除` 或 `[skill-modify] 删除清单:` 任一；enforce FAIL exit 1/warn WARNING 不阻断。主进程复验块语义+bash -n；fixture 六场景证据见 subagent-state/09-executor-s6.md（测试副本 test-patch 取证法，交付文件本体未动）
- [2026-09-17 P2/S5] check-skill-modify.sh 新建（92 行）+ zcode-pretooluse.sh 接线（L52-60 分支内，注释行改写 1 行+逻辑纯新增）。主进程抽查亲测：enforce 未授权 /tmp 假 SKILL.md→rc=2+BLOCKED；enforce 已授权 scope 文件（v079 sid）→rc=0 授权优先。执行体 3 处设计偏差均合理已记录：①计划定位改 root 链+sid 归属（防 worktree 陈旧 plans 误命中）②守卫对主/子代理一致分档，owner 文件缺失时保守放弃授权（owner 或 side 指针双通道）③接线含 1 行注释改写。细节证据=subagent-state/08-executor-s5.md
- [2026-09-17 P2/S4] config.json 新增 skill_modify_enforce（template_gate_enforce 后/subagent 前 @L311-316，+6 行 0 删除）：enum [enforce,warn,off]、default warn、description 注明 Rule 36 三档语义+消费侧三件名。主进程 python3 json.load 复验通过，additionalProperties:false 不破
- [2026-09-17 P2/S3] Rule 36 块落稿 worktree critical-rules.md L300-311（12 行纯新增，0 删除；主进程 Read 全文复核：标题/引言三链路含流量分级事故样本/36.1-36.7 齐；36.2 引 31.2+31.3 衔接句、36.4 引 D6 不扩列、36.7 三件消费侧+skill_modify_enforce 默认 warn 全在位）。条款为单行密排格式对齐 31.x/32.x。锚=^36.[1-7] 共 7 @L305-311
- [2026-09-17 P1 基线] worktree@187194b 全量 selftest 基线=**20 脚本 337/0**（主进程 awk 逐 Total 求和，证据 subagent-state/p1-baseline.md；code-runner 自报 352 为算术错弃用）。插入点锚一手复验：critical-rules.md 尾 L299（Rule 35@L292）/ config.json 三档键区 L299-310 / check-complete.sh REFLECT-GATE 尾 ~L812-818 共 833 行 / SKILL.md L278、L327、C23@L197、指针段@L219 / zcode-pretooluse.sh 分支@L29、check-delegation 调用@L40。P2 S3-S6 以此为插入基准
- [2026-09-17 Explore 结构侦察] 完整结论落盘 `subagent-state/01-explore-conventions.md`（代理 agent_907443c6 无 Write 工具,主进程代落盘）。要点：critical-rules.md 300 行最大 Rule 35;Rule 31/32 为最相近范式(31.3@L255 已有「本体修改走后续任务」先例须衔接);config.json 14 个三档 enforce 键全默认 warn+additionalProperties:false;check-complete.sh GATE 追加范式(resolve_X_tier);SKILL.md 联动锚=C24 空位+Rules 1-35 五处级联+CD-11/12 断言;zcode-pretooluse Write/Edit 分支=新守卫接线点,且 check-delegation 对子代理 sid≠owner exit 0 放行=新守卫需自行覆盖;「功能删除防护」语义全仓零命中=空白区无锚冲突
- [2026-09-17 会话异常观察] plans/task-v078-guard-fp-fixes/ 于本会话开始前后(05:29-05:31)被自动创建并挂到本会话 sid(.session-owner=sess1aae39...),内容=未填写空模板,主题为 v077 deferred 的 guard 误报修复,与本次目标无关;疑似 UserPromptSubmit 侧自动认领/初始化串扰。处置:本任务改用 v079,v078 目录保持原样待用户裁决（已登记 Technical Decisions）
- [2026-09-17 plan-writer 产出] task_plan.md 203 行 + knowledge-brief.md 76 行，主进程 Read 复核通过（VC-1..5/Phase 1-5/11 S-unit 纯数字 ID/FMEA RPN>100 兜底/隔离决策 worktree/Handoff 预填）。plan-writer 新发现：selftest-reflect-verify.sh RV-10（L13/L60）含严格 'Rules 1-35' 字面量锚，已补入 S8 锚级联清单——任务书未列，属计划期增值修正。检查点=subagent-state/02-plan-writer.md

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| 新增 Rule 36(七子条 36.1-36.7)而非扩写 Rule 31/32 | 归因前置/删除防护/保守化是独立链路;31.3 仅一句「走后续任务」,扩写会改既有条款语义(违反保守化自身);设计全文见 subagent-state/02-rule36-design-brief.md |
| 机制=config 键 skill_modify_enforce(warn 默认)+check-skill-modify.sh 挂 pretooluse+SKILL-MODIFY GATE+selftest | 对齐既有 14 个三档键与 GATE 追加范式;新守卫须覆盖子代理(check-delegation 对子代理放行的空档) |
| 36.4 删除确认引用 Rule 28 D6 语义而不扩列 D6 清单 | 保守化示范:不改 Rule 28 既有语义;D6 两模式一致(silent 也不得跳过)正合用户诉求 |
| 本次任务用 v079 编号;v078 空模板目录保持原样 | v078 被自动创建挂本会话 sid 但主题不同(guard-fp-fixes),归属待用户裁决,不覆盖不删除 |

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
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
