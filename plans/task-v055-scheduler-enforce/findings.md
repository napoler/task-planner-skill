# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
- 用户核心诉求：task-planner 技能要真正做到「主进程 = 调度管理器（规划/拆分/派发/验收/簿记），任务执行一律下沉子代理」
- 实测反馈：使用该技能时主进程仍亲自干活，定位未落地 → 说明现有实现存在真实缺陷
- 隐含要求：修复必须是可观察、可验证的机制（用户说"真正达到"），纯文案修改不算达标（VC-2 门控）

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
| task-v052 调度定位收口 | plans/task-v052-scheduler-positioning/ | ✅（经 codebase-analyzer 交叉验证其成果=纯文本层） | 根因分析 |
| 部署拓扑 memory | ~/.zcode/cli/memories/.../task-planner-repo-deploy-flow.md | ✅ | 部署一致性矩阵 |
| Critical Rules 25 | skills/task-planner/references/critical-rules.md:158-166 | ✅（细则仅 9 行且不注入） | 根因 3 |
| hooks 配置 | ~/.zcode/cli/config.json hooks.events（4 条 enabled） | ✅ | hooks 盘点 |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->

### R1 部署一致性矩阵（2026-09-07，explore 派发失败后主进程补做，例外理由：Provider 拒绝×1 + 确定性 diff 属验收类）
| 部署位 | 结果 |
|--------|------|
| ~/.zcode/skills/task-planner | IDENTICAL（codebase-analyzer 附带 diff 证空） |
| ~/.claude/skills/task-planner | IDENTICAL（过滤 plans/ 会话产物后 diff -rq 空） |
| ~/.config/opencode/skills/task-planner | IDENTICAL（同上） |
| 仓库基线 | master e17df76，skills/ 无未提交变更 |

**结论：部署滞后假设证伪**——用户实测的就是最新版技能，缺陷在技能机制本身，不是版本问题。

### R2 机制层缺陷清单（codebase-analyzer，checkpoint: subagent-state/02-codebase-analyzer.md 258 行）
关键负向证据：`grep -rn "Executor\|delegation_rate\|Rule 25" skills/task-planner/scripts/` → **0 行匹配**。
1. `scripts/zcode-pretooluse.sh:13-47` — PreToolUse 只查哨兵+并发冲突，不读 Executor 字段，Rule 25 零拦截
2. `scripts/zcode-posttooluse.sh:1-176` — PostToolUse 只盯三文件陈旧度，不验证 Executor 一致性
3. `scripts/check-complete.sh:1-349` — 终验 349 行 0 处 Rule 25/delegation_rate_floor，Rule 25.4 自动统计失效
4. `scripts/check-3file-gate.sh:1-137` — 执行期硬门控只查 findings/progress，不验证 Phase 是否按 Executor 派发
5. `scripts/attest-plan.sh:1-63` — 只防篡改，不校验 Executor 字段填齐
6. `scripts/init-session.sh` — 复制模板不校验 Executor 字段
7. `config.json:36-41` — delegation_rate_floor: 0.7 是**死配置**（无脚本读取）
8. `templates/verification.md:77` — 委派统计是人工填写字段，无脚本解析
9. `SKILL.md:29` — 核心「主进程定位 P0」文本块仅 1 行，夹在 Goal 与 [CONTEXT] 之间
10. `SKILL.md:113-132` — Rule 25 检查点（步骤 2.5）与其他步骤同级，无"必过门控"等级
11. `SKILL.md` 全文 570 行 + 28 次 P0 字样 + 执行期硬门控 0 条 = "P0 贬值"
12. `references/critical-rules.md:158-166` — Rule 25 细则（六项白名单/委派率公式）在 207 行文档的 9 行中，SKILL.md 注入时不展开 references/
13. `templates/task_plan.md:130` — Executor 字段无强制校验，占位文本也能过
14. `references/critical-rules.md:166` — Rule 25.6「禁止静默转亲为」无脚本兜底

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
| **采纳方案 B（完整方案）+ critic 全部 BLOCKER/MAJOR 修法** | 方案 A 不覆盖最强根因 1（执行期拦截缺失），用户诉求「真正达到」不达标（VC-2 门控）；critic 裁决条件性可实施，修法见下 |
| 初始档位 enforce 优先（非 architect 原 warn 优先） | 用户实测已二轮失望（M-1/挑刺3：warn 档会复刻「还是没效果」）；Phase 3 第一动作实测 Q-1 子代理 stdin 特征——探测可靠→enforce 直上；不可靠→降「首次警告二次阻断」会话级策略 |
| B-1 修法：bypass 须用户明文确认 | 阻断文案删除 allow-direct.sh 自助路径；bypass 仅用户主对话指令可开；bypass 事件落 ledger 终验 expose；单会话硬上限 1 次 |
| B-2 修法：统计去口供化 | 白名单正则删除「④用户显式/②规划」自动通过（改终验 expose 待人工裁）；Executor 占位文本检测（templates 占位不计分子）；Executor=子代理 必须有 Handoff 表对应行交叉校验；理由⑥（≤3 行）用 git diff 行数硬证 |
| M-3 修法：部署 SOP 进 Phase 4 硬验收 | rm+cp -rL 重部署 3 位 task-planner + diff -r 复验 + verify.sh 体检，已在 VC-4；文案中 `~/.zcode/...` 路径改 `$TASK_PLANNER_ROOT` 变量（跨部署位可执行，Q-2） |

### 方案 B 最终版结构（architect 217 行 + critic 267 行检查点为权威细节）
1. **执行期拦截**（根因 1）：zcode-pretooluse.sh 哨兵检查后插委派门控分支——工具过滤(Write/Edit/ApplyPatch) → 子代理 stdin 特征探测放行（Q-1 实测定档）→ bypass 仅用户明文（B-1）→ 活跃计划判定 → 文件白名单（plans/** walk-up 祖先判定 m-2、.claude/plan-templates/、.zcode/plans/、三件套文件名、SKILL_ROOT 内部）→ trivial ≤3 行判定（new_string 前 4KB 截断 M-4；字段缺失→会话计数首次警告二次阻断）→ enforce 档 exit 2 阻断（教育式文案：派子代理/登记例外/请用户 bypass 三条合法路径，不含自助钥匙）+ warn 档 additionalContext。核心逻辑抽 check-delegation.sh 参数式共享
2. **终验统计**（根因 2/5）：check-complete.sh:134-149 扫描器扩展提取 Executor 行；缺字段任何时候 exit 1（Rule 25.1）；委派率 < floor 且含白名单外理由 → exit 1 禁 COMPLETE；B-2 去口供化修法全量落地；floor 从 config.json 接线（终结死配置）；脚本只读不写（attest SHA 红线）
3. **文案收敛**（根因 3/4）：SKILL.md 570→≤500 行、P0 28→≤10；「主进程定位」(line 29)与「最佳实践」段合并为单一调度器区块前置；Rule 25 六项白名单 9 行内联；m-1 顺修 SKILL.md:107 exit 码漂移
4. **三层闭环**：attest 锁 Executor（计划期）→ PreToolUse 拦亲为（执行期）→ check-complete 算委派率（终验）；warn 触发计数累计 /tmp state（M-1），终验报告 expose
5. **部署矩阵**：zcode 位全生效（hook 注册在 ~/.zcode/cli/config.json）；claude 位脚本随部署生效但 hook 注册属授权项（register-hooks-cj.ts:119，不在本任务自动改）；opencode 位不承诺拦截（明示预期管理）

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
| explore 子代理 Provider rejected（1 次） | 按 Rule 22.3 兜底：任务退化为已知路径确定性 diff，主进程补做（验收类白名单），已登记 Handoff |

## 根因结论（VC-1 证据链）

**用户实测「主进程仍亲自干活」的根因 = 调度规则只存在于文本层，机制层 100% 缺席：**

| 排名 | 根因 | 证据 | 解释力 |
|------|------|------|--------|
| 1 | **执行期硬拦截 100% 缺失** | 全 scripts/ 0 处 Rule 25 引用；PreToolUse 哨兵清除后对亲为零拦截 | 最强：主进程亲为瞬间无任何机制能发现/阻断 |
| 2 | 终验自动统计缺失 | check-complete.sh 不读 delegation_rate_floor；委派统计人工填 | 亲为到尾也不会判 PARTIAL |
| 3 | Rule 25 细则未进上下文 | critical-rules.md 默认不注入 | 白名单六项/公式模型无具象记忆 |
| 4 | 核心 P0 文本稀释 | SKILL.md 570 行/28 次 P0/定位块 1 行 | 长上下文里文本约束权重低 |
| 5 | 配置仪式化 | delegation_rate_floor 死配置 | 用户以为有机制实为装饰 |

修复方向推论：必须「指令性文本 → 机制性强制」——PreToolUse 硬拦截 + 终验脚本自动统计委派率 + SKILL.md 核心规则收敛，三者缺一不可（分别对应根因 1/2/4）。

### R3 执行期拦截组实施结果（executor-A，2026-09-07 03:4x，commit eadd9ae）
- 6 文件 +980 行：check-delegation.sh(526 行核心)/allow-direct.sh(153)/selftest-delegation.sh(249)/zcode-pretooluse.sh(+35)/zcode-userpromptsubmit.sh(+8 写 .session-owner)/config.json(+9 delegation_enforce)
- 自测 18/18 PASS（主进程独立复跑确认，证据 tmp/enforce-demo.txt）
- 实施中自纠 5 个关键 bug：CONFIG_JSON 层级错误(致拦截全失效)/BASH_REMATCH 时序/allow-direct 过期判定反向/Phase flush 丢失/heredoc 死循环
- 验收抽查：SKILL_ROOT/CONFIG_JSON/session-owner 判定链/pretooluse 插入点均正确（保留原哨兵逻辑）
- 遗留 4 项（均已裁决可接受/追修）：缺配置 fallback enforce=从严合理；Executor 含空格类型匹配弱（我方 agent 名无空格）；pretool 用 $PWD（与现有行为一致，Q-3 统一改造后续）；ApplyPatch 无 new_string 恒走首警二断降级（安全方向）

### R4 中途外部干预事件与处理（2026-09-07 03:26）
- executor-B 执行期间，用户（Terry）在另一会话将 A 批 worktree 合并回 master（eadd9ae→4420c08→176ff0f，含自行补做 check-complete.sh DELEGATION GATE + SKILL.md 部分收敛）并清理了 worktree
- executor-B 按宪法 §四正确 STOP（漂移报告），主进程核实 master 现状后按选项 B 路径处理：重建 worktree（基于 176ff0f）→ 派 executor-B' 只做剩余 3 项（SKILL 收敛达标/verify 3 项/verification 自动化）→ commit eee87e0
- 教训：并行开发期间派发子代理的 prompt 应含「外部合并事件的自适应路径」；本次损失 = executor-B 的 4 处重复 Edit（约 15 分钟）

### R5 B' 收尾批次结果（executor-B'，commit eee87e0）
- SKILL.md 548→497 行（−51）、P0 20→10；保留的 10 处均为机制级（头部铁律+Rule 13/14/19/22/25/26/27+路由表主标题+约束）
- verify.sh 新增 9 号检查（委派门控三件套可执行性）；verification.md 委派统计改机器驱动（check-delegation stats JSON 为事实源）
- 自测：18/18 selftest PASS（A 批未破坏）；verify 20 pass/3 fail（3 fail = 3 部署位 SKILL.md 漂移——Phase 4 部署后消除）
- 主进程复验：行数/P0/selftest/verify 全部独立复跑确认 ✓

### R6 Code Review 首轮（Code Reviewer，checkpoint 09-code-reviewer.md 187 行）
- verdict：CHANGES_REQUESTED — 1 BLOCKER + 6 MAJOR + 5 MINOR + 4 NIT
- BLOCKER：self_declared 正则 `(用户显式|规划|验收|编排|簿记)` 与 critical-rules.md:163 Rule 25.3 白名单字面措辞冲突——按权威源规范写理由 → verdict=violation → check-complete 硬 exit 1（合规反被拦，实测验证）
- MAJOR：M-2 session-owner 缺失/空/多行=fail-open+多行绕过（首执行轮 hook 失活=用户实测场景）；M-4 bypass 无人类在场证据+hook 文案打印可执行 bypass 命令（与自声明矛盾）；M-1 Executor 无括注理由 → reason 空 → 无 violation（去口供化漏洞）；M-3 enforce 阻断 stdout JSON vs check-scope 用 stderr（exit 2 反馈通道应为 stderr，消息可能丢）；M-5 `*/plans/*` 过宽（业务项目 plans/ 全放行，实测 rc=0）；M-6 EOF-flush 跳过 Handoff 交叉校验+3 份复制漂移
- 负结果（确认无恙）：哨兵机制/Rule23 冲突检测完整保留；jq fail-open 实测 PASS；TTL 方向正确；Write 不适用 trivial 正确；脚本均可执行
- 处置：B-1/M-1~M-6 + m-4/m-5（文案漂移）本轮 fix-phase 修；m-1/m-2/m-3 + NIT 记 deferred-issues

### R7 fix-phase 修复批（见 progress 对应段）

### R7 fix-review 批结果（executor，commit 7ab28e2 → 合并 fa893eb）
- 9 项全修：B-1 白名单编号标识判定（删关键词字面匹配）/M-1 missing_reason/M-2 owner head -n1+观察模式/M-3 stderr+exit2/M-4 sid 维度 bypass 闸门+文案去命令原文/M-5 plans 白名单限 .md|.json/M-6 _flush_phase() 单函数三处统一/m-4 行号指针/m-5 文案对齐
- 自测 22→35 断言全 PASS（新增 T17-T22×b 系列）
- **B-1 修复实证**：本计划 stats 复跑 violations=[] verdict=ok（此前 self_declared×2 误报消失）
- **机制实弹证据**：部署后本会话出现 [delegation-observe] 提示——hook 已在真实会话拦截链上工作
- 追修遗留（记 deferred-issues）：n-1 /tmp 可预测文件名、n-2 stats error JSON 误判 pass、n-3 SKILL.md:46 锚点、m-1 ledger 字段、m-2 trivial 4KB 绕过

## Resources（补充2）
- subagent-state/02-codebase-analyzer.md — 机制层完整分析（258 行）
- skills/task-planner/scripts/zcode-pretooluse.sh — 执行期拦截的改造落点
- skills/task-planner/scripts/check-complete.sh — 终验委派率统计的改造落点
- skills/task-planner/config.json:36-41 — delegation_rate_floor 接线落点

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
