---
id: guard-attest-completion-gates
title: "attest 与完成门拦点清单"
tags: [attest拒锁, 完成声称门, 守卫误报, enforce档, 机器门]
sources:
  - plans/archive/task-v149-skill-alignment-audit/findings.md
  - plans/archive/task-v149-skill-alignment-audit/knowledge-brief.md
  - plans/archive/task-v092-guard-quirk-fixes/knowledge-brief.md
  - plans/archive/task-v092-guard-quirk-fixes/findings.md
  - plans/archive/task-v078-guard-fp-fixes/knowledge-brief.md
  - plans/archive/task-v078-guard-fp-fixes/findings.md
  - plans/archive/task-skill-audit-20261021/findings.md
  - plans/archive/task-v148-drift-enforce/findings.md
  - plans/archive/task-v066-skill-collab-routing/findings.md
  - plans/archive/task-v055-scheduler-enforce/subagent-state/09-code-reviewer.md
  - plans/archive/task-v158-source-anchor-discipline/findings.md
updated: 2026-10-22
---

# attest 与完成门拦点清单

## 结论（可直接复用）

**A. attest 拒锁三拦点**（来源：task-v149 / task-v092 / task-skill-audit-20261021）
①时长必须裸 `NNmin`（`≤15min` 带前缀不可解析，契约 `^[0-9]+min$`，check-plan-dispatch.sh:261）；②S-unit ID 必须 `S+纯数字`（`F1-F6` 等字母后缀不认，数据行正则 `^\|\s*S[0-9]+\s*\|`，:242；task-v076 attest 拒锁教训）；③每个派发型 Phase 必须自带 S-unit 表（缺表即拒锁）。修法＝读 check-plan-dispatch.sh 解析器后精确修正，三点齐改二跑通过（SHA 3c054bac）。粒度另受上限约束：S-unit 保持 ≤2f/≤100l/≤15min，超限 enforce 拒锁。Verify command 写在 verification.md，由 `skills/verification-gate/scripts/run-verification.sh` 逐条解析执行。锁后语义：执行期改计划＝B 类重规划 + 重跑 attest；连簿记性提交也会破锁（v150 判例：attest 后两个簿记提交未重锁 → `.plan-attestation` 哈希失配 → `[PLAN TAMPERED]` 告警，按 Rule 51.7 登记 + 重锁消音）。

**B. Rule 51 完成声称门**（来源：task-v149 / task-v055 / task-v078 / task-v079）
outcome 三态 COMPLETE / PARTIAL / BLOCKED；PARTIAL 定义＝「VC 通过但存在已知遗留缺陷 → 列出 + 建议后续」。硬拦截判据：委派率 < `delegation_rate_floor`（默认 0.7）或含白名单外理由或 stats verdict=violation → `check-complete.sh` exit 1 阻断交付，须按 violations 清单回炉补 plan 或转 PARTIAL 重跑。文案必须与实现一致：旧文案写「outcome 最高 PARTIAL」，脚本实际是硬 exit 1 拒绝报告 COMPLETE → 改为「exit 1 阻断 + 回炉补 plan 或转 PARTIAL 重跑」。自缩禁令：证据不实按 Rule 26 惩罚映射 Q3 档处置——不得自判 COMPLETE/PARTIAL，须以 BLOCKED 上报 + STOP 等用户裁决；回归 FAIL 无法定位 → 记录后 PARTIAL。outcome 载体约定：本仓写在 verification.md，而提醒链豁免只查 task_plan.md → 豁免永不触发（v076/v077 连续误报根因）→ 修法＝豁免点后补 verification.md 兜底分支（同目录、同正则、`-qi` 容前导空格）。

**C. 守卫误报/漏报典型模式**（来源：task-v092 / task-v078 / task-skill-audit-20261021 / task-v148）
1. 区间锚解析恒空：`sed -n '/start/,/end/p'` 在 end 模式首行即命中 → 只输出 2 行 → active_plans 恒空 → 检测从不触发；gawk 起始行同配终止时输出恒为「起始行 1 行」，经 `grep '|'` 后恒 0 行＝等同恒空。对策＝状态机化 `{f=1;next} /^## /{f=0}`。
2. 状态初值非中性：`prev_status` 初值 "pending" 虚构虚拟 Phase 0 → 首状态行=complete 即 CRITICAL PHASE-SKIP 误报（日常合法推进形态同样误报）。对策＝初值中性化 + 正反双向夹具。
3. 豁免只查单一载体（outcome 只查 task_plan.md）→ 豁免永不触发 → 持续误报；打包检测 `grep -oE 'S[0-9]+'` 全位置计数把契约条文示例 ID 计成多 S-unit → 误拦。对策＝豁免须在计数前短路。
4. 单条件豁免废门：单条件 `subagent-state/` 豁免会废掉打包门（所有合规派发的检查点路径都在其下）→ 必须「任务书」+ `subagent-state/` 双条件同时命中。
5. 模板占位当路径：`templates/subagent_dispatch.md:38` 的「伴飞技能 SKILL.md 绝对路径:{…}」被 check-dispatch.sh:580,592 抽成 `SKILL.md` 再 `-f` 校验 → enforce 档下合规派发被误 exit 2。
6. Handoff 裸名（含全角括号）：Phase Executor 写「按 S-unit 表（…）」→ check-delegation.sh:421-424,445 剥括号得「按S-unit表」，永不匹配 Handoff 列 → delegation_rate 0.000 → 终验 0.7 门槛误判不合格；执行体名必须是纯注册名。
7. 返回面：check-subagent-return.sh:51 判 `status: blocked` 值域外 rc=1，而 `status: failed` + `blockers: none` + `acceptance: 全部通过` 反而 PASS（与 subagent_dispatch.md:87 及 22.4b 相反）；返回格式段门由标题形态开关，改成 `### 7. 返回格式` 即整门静默放行，保留 `##` 但缺 `confidence:` 则 exit 2。
8. 夹具写法与仓内真实写法不同面：守卫正则 `outcome: *(COMPLETE|BLOCKED)` 要求值紧随，而仓内真实写法是 `- **outcome: COMPLETE**（…）` → 旧 fixture 不匹配 → 守卫不触发（emit 188 字节假通过）。
9. 恒真断言与永久豁免：`selftest-verification-gate.sh:73` 的 `-ge 0` 命中 0 仍 TRUE；`EXEMPT_DANGLING=(57 60 80 82)` 把「正文已落地、账本停 reserved」判 PASS → 失配被绿灯掩盖；DCS-20 扫描根＝SKILL_ROOT/.. 全 skills 树 → 命中无关技能文件被判 FAIL（实为环境敏感伪失败）。

**D. enforce 档处置**（来源：task-v066 / task-v079 / task-v149）
config 键 `enum enforce|warn|off`，默认 warn；档位解析 `env TASK_PLANNER_X_ENFORCE > config.json#X > warn`；enforce FAIL＝stderr `[plan] X-GATE FAILED` + exit 1，warn＝同文案不阻断；派发侧请求门以 exit 2 表示 enforce 拒绝。被拦后先判「门错」还是「写法错」：写法与门不同面 → 补门或改夹具（如 DCE-20 夹具改正）；确属违规 → 回炉补 plan 或转 PARTIAL 重跑，禁改门放行。声明档位语义必须如实披露是否已有机械校验（如 `skill_collab_enforce` 三档本轮纯流程层执行、无 hook 校验、enforce 语义预留）。新守卫须自行实现「主/子代理一致生效」：check-delegation 对 sid≠`.session-owner` 的子代理 exit 0 放行，不能假设 delegation 已覆盖技能文件。

## 证据锚

| 结论 | 证据锚（file:line） |
|------|---------------------|
| A 三拦点 + 粒度上限 | plans/archive/task-v149-skill-alignment-audit/findings.md:119、knowledge-brief.md:63,:67 |
| A 解析契约 | plans/archive/task-v149-skill-alignment-audit/knowledge-brief.md:44（:242/:261/:120） |
| A S-unit 纯数字（v076 教训） | plans/archive/task-v092-guard-quirk-fixes/knowledge-brief.md:42 |
| A Verify command 载体 | plans/archive/task-skill-audit-20261021/subagent-state/S1-explore.md:315 |
| A 破锁告警判例 | plans/archive/task-v158-source-anchor-discipline/findings.md:67（v150 PLAN TAMPERED） |
| B outcome 三态与 PARTIAL | plans/archive/task-v149-skill-alignment-audit/verification.md:107,:112 |
| B 委派率阻断判据 | plans/archive/task-v149-skill-alignment-audit/verification.md:90 |
| B 文案与实现不一致 | plans/archive/task-v055-scheduler-enforce/subagent-state/09-code-reviewer.md:150,:152 |
| B 自缩禁令（Q3 档） | plans/archive/task-v079-skill-modify-conservatism/subagent-state/01-explore-conventions.md:9 |
| B outcome 载体与误报根因 | plans/archive/task-v078-guard-fp-fixes/knowledge-brief.md:29,:31-32,:49 |
| C1/C2 恒空与初值误报 | plans/archive/task-v092-guard-quirk-fixes/findings.md:40（1a）、:74-86（3a）、:112-125（3c） |
| C5-C7 派发契约面 | plans/archive/task-skill-audit-20261021/findings.md:105-109（C-01~C-05） |
| C8 夹具与真实写法不同面 | plans/archive/task-v148-drift-enforce/findings.md:139-141（DCE-20 修正） |
| C9 恒真断言/永久豁免/扫描根 | plans/archive/task-skill-audit-20261021/findings.md:79,:96；task-v149-skill-alignment-audit/findings.md:37,:67 |
| D 三档范式与档位解析 | plans/archive/task-v066-skill-collab-routing/findings.md:91；task-v079-skill-modify-conservatism/subagent-state/01-explore-conventions.md:16,:26 |
| D 子代理放行空档 | plans/archive/task-v079-skill-modify-conservatism/knowledge-brief.md:53 |

## 易错点

1. 症状：attest 首跑失败 → 先查三拦点（NNmin / S 纯数字 / 每派发型 Phase 有表），禁改门禁阈值。
2. 症状：守卫报「越界/冲突」但计划合规 → 先查 C1~C4（恒空、初值、单载体豁免、全位置计数、单条件豁免），别急着改计划。
3. 症状：enforce 档把合规派发打回 → 查 C5/C6（模板占位被当路径、执行体名不纯）——是门不同面，不是违规。
4. 症状：selftest 全绿但生产无防护 → 查 C8/C9（夹具写法不同面、恒真断言、永久豁免、扫描根过宽）。
5. 症状：门拦下「纸面完成、现实未完成」→ 这是门在正确工作（首次在生产计划上真实拦下缺陷的实例），修计划而非修门。
6. 禁：被拦后改门放行（越权且破坏守护）；禁用自判降级（PARTIAL）替代回炉补 plan；禁把未提交/未部署的规则文本当已生效（部署位可能落后数十提交）。

## 适用场景

- 计划写完准备 attest 锁定（阶段任务书、时长、粒度自检）；终验判 COMPLETE / PARTIAL / BLOCKED 的裁决与自检；
- 守卫（check-*.sh / pretooluse / 派发契约门）误报、误拦、漏报的定位；config 三档 enforce/warn/off 的档位选择与语义声明；
- 派发任务书与返回格式的字段级校验（8 字段、值域、confidence）。
