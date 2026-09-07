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

### R10 子代理失败量化统计（09-08 当日日志 `~/.zcode/cli/log/zcode-2026-09-08.jsonl`，主进程直接取证）
- **派发 37 次（subagent.spawned）→ 27 次 turn.failed = 73% 失败率**（系统性，非个别）
- **失败 agentType 分布**：general-purpose 19 / article-research-phase 9 / article-research-heavy 6 / Explore 6 / Simple Agent 5
- **失败全部落在网络/provider 层**（model.network.failed statusMessage 直方图）：
  | 形态 | 次数 | 说明 |
  |------|------|------|
  | ECONNREFUSED 192.168.123.36:3456 | 46 | 路由 provider 服务不可达 |
  | other side closed | 35 | 连接被对端断开 |
  | Provider rejected（400 invalid_request, retryable=false） | 27 | 请求被 provider 拒绝（haiku-1/sonnet-1） |
  | Network connection failed | 15 | 网络层失败 |
  | Model request was cancelled | 3 | 取消 |
  | Headers Timeout Error | 1 | 请求头超时 |
- **关键判定**：失败样本 turnNumber=0 / turnPhase=processing_input = **子代理还没执行任何工具，第一次模型请求就被 provider 拒绝** → 直接解释用户「子代理中并没有正确的执行」
- **harness 契约确认**：`model.retry.delay.resolved` 对 400 → canRetry=false；rollout 里 attempt 恒=1 → **provider 非可重试错误时 harness 不做自动重试**，主进程只拿到一段错误文本

### R8 子代理返回链路实测证据（09-08 Phase 5 扩展，主进程直接取证）
1. **Provider 拒绝形态实测**：`~/.zcode/cli/rollout/model-io-sess_subagent_agent_62a13a53-*.jsonl`——子代理会话 haiku-1 档（role=subagent）单条 model_io 记录：attempt=1，durationMs=278428（≈4.6 分钟），`error.name=TerminalStreamChunkError`，message="Provider rejected the model request."，startedAt 2026-09-07T20:26:39Z。**即：子代理派发后主进程同步等待 ~4.6 分钟才拿到一个"被拒绝"错误**——与用户体感「一直没有正确返回」完全吻合
2. **父会话侧**：同一时间窗父 rollout（model-io-sess_f9030ba5…jsonl）25 行中 19-23 行引用该子代理会话 id；父会话模型档位=fast（providerId 与主进程相同），子代理被路由到 haiku-1
3. **形态归类（待补全统计）**：Provider 拒绝（v055 1 次 + Code Assistant 1 次）/ API Headers Timeout（v053 code-assistant ×2，换 general-purpose 后成功）/ 外部干预漂移（executor-B 被用户并行合并打断）/ 交叠事故（v053 并行代理误 checkout 毁另一批产出）
4. **harness 契约结论（关键）**：Agent 工具是**同步阻塞**调用——主进程发起后挂起等待子代理整个会话跑完或出错才返回；子代理内部无超时机制（Rule 22.2 的 30/60/120min 档位无任何执行方，属纸面规则）；子代理失败时返回=错误文本，**无自动重试**（rollout 里 attempt 恒=1）

### R9 v055 新门控与子代理链路交互验证（Phase 5 关键验证项）
- check-delegation pretool 子代理放行靠「stdin session_id ≠ .session-owner」判据（check-delegation.sh:234-254）
- **风险点待实测**：子代理写 `subagent-state/*.md` 检查点文件时，若 hook 对子代理工具调用注入的 session_id 为空 → sid=default → 跳过节 ② → 走白名单链 → plans/**/*.md 命中白名单放行 ✓（不拦截，无误伤）
- 若子代理 session_id 非空且 ≠ owner → 直接 exit 0 放行 ✓
- **但反向问题**：sid 探测失效（子代理 sid 为空且无活跃计划解析）→ resolve_plan_dir_any 失败 → exit 0 放行（fail-open，无害）
- 结论：v055 门控对子代理返回链路**无拦截性误伤**；子代理"不返回"的根因在 provider 层（haiku-1 被拒）+ 同步阻塞语义 + 无自动重试，与门控无关

### R11 provider 通道实测矩阵（09-08 05:1x，1-token curl 探测）
| 通道 | 状态 | 结论 |
|------|------|------|
| ccr `192.168.123.36:3456`（haiku-1/sonnet-1/mini/opus-1/fast/deepseek-v4-pro） | curl 5s 超时；全天 46×ECONNREFUSED/35×other-closed/27×400（R10） | 主通道间歇性宕；所有 companion/用户 agent 绑定于此 |
| builtin:zai / zai-coding-plan / bigmodel（GLM-5.3） | 500 包 404 NOT_FOUND | 模型未开通，不可用 |
| go `cfe63a01`（opencode.ai zen） | Missing API key | 不可用 |
| **agnes-ai.cn `9a69b164`（agnes-2.5-flash）** | ✅ 1-token 调用成功（stop_reason=max_tokens） | **唯一可用 fallback 通道** |

### R12 Agent 类型热加载实证（09-08，负结论）
- 会话中现写 `~/.zcode/agents/v055-dyn-test.md` → `Agent(subagent_type="v055-dyn-test")` → 返回 `Agent type 'v055-dyn-test' not found`（可用列表=会话启动时快照，含全部 75 个已部署 agent）
- **结论：Agent 可用类型列表在会话启动时固化，运行中新建的 agent 定义不被识别** → fallback 变体 agent 必须「部署落盘 + 新会话生效」；当前会话内的兜底仍是主进程接管/AskUser（协议须如实写此边界）
- 清理：v055-dyn-test.md 已删除（实验产物，不落保护区）

### 方案 v055-fallback（最小闭环，09-08 设计）
1. **config.json** 新增 `subagent.provider_fallback`：`enabled` / `variant_types`（高频类型：executor/explore/code-assistant/general-purpose）/ `fallback_slugs`（裸 slug 有序表，跨机可携带：["agnes-2.5-flash"]）/ `probe_timeout_ms`
2. **scripts/subagent-fallback.sh**（新，3 模式）：
   - `probe`：读 `~/.zcode/v2/config.json` provider 表 → 对每个候选 (uuid, slug) 1-token 探测 → 写 `<plan-dir>/.provider-health.json`（ts + ok + latency + err）
   - `bind`：按 fallback_slugs 解析本机可用 provider uuid（含该模型 + probe ok）→ 从原 agent 文件复制生成 `~/.zcode/agents/<type>-fb.md`（frontmatter name/description 加「fallback 变体」标记，model 行 = `custom:<uuid>:<slug>`，body/tools 继承原 agent）；幂等（内容 hash 比对）+ 清理陈旧变体；输出报告 JSON
   - `next <type> [err_kind]`：读 health + 配置 → 输出 `{"dispatch_as":"<type>-fb","model":"custom:<uuid>:<slug>","reason":"..."}` 或 `{"dispatch_as":null,"escalation":"main_takeover_or_askuser"}`；err_kind=provider → **零消耗改派**（不计入 retry_limit）
3. **Rule 22.3 升级**（critical-rules.md + SKILL.md 各 2 行）：provider 类失败（网络/400/超时）→ 先 `subagent-fallback.sh next <type> provider` 主动指定变体改派（零消耗）→ 无可用变体 → 主进程接管（≤300 行）/ AskUser；派发前可 `probe` 预检（快速失败优于 4.6 分钟静默）
4. **install.sh** 尾部挂 `bind`（best-effort，失败告警不阻塞部署）；**verify.sh** +1 检查（脚本可执行 + config 键存在）；**selftest-fallback.sh** 6 断言
5. 边界（如实登记）：变体 agent 新会话才可用；`bind` 生成物落 `~/.zcode/agents/`（§六 保护区，本方案 = 用户 09-08 裁决即授权，生成清单登记 verification）
6. 不做（YAGNI）：单 agent 级 model override 配置、后台自动 probe 守护、跨机器 provider 自动发现（fallback_slugs 手工维护）

### R13 v055-fallback 实施结果（commit 382be79 → 合并 cd0acdb，09-08 发布）
- 7 文件 +494 行：subagent-fallback.sh（probe/bind/next 三模式，316 行）/ config.json provider_fallback 4 键 / Rule 22.3.1（critical-rules + SKILL.md 指针段）/ verify#10 / install Phase 5.7 / selftest-fallback.sh（21 断言）
- 实施插曲（根因 1 现场）：批次派发 executor 遭 Provider rejected → 改派 general-purpose 再遭 Provider rejected（ccr 三档 haiku/sonnet/mini 实测全宕）→ 按 22.3 ③ 主进程接管（白名单⑤，Handoff 表 11/12 行已登记）；这正是本批要修的链路
- 自测中修复 2 个脚本 bug：① entries 拼接产生非法 JSON（`jq -s '.[0]'` 方案 → 改 `jq -cs` 单次合成）② bind 生成变体时 model 行被 awk 丢弃而非替换（改为 `-v ml` 原地替换 + 缺键追加）
- 冷启动实测：agnes 通道 1-token 探测 10s 超时失败、25s 通过（0.67s 返回）→ 默认 probe_timeout_ms 10000→20000
- 真实 bind：4 个 -fb 变体生成（executor/explore/code-assistant/general-purpose → custom:9a69b164…:agnes-2.5-flash），meta `.task-planner-fallback-meta.json` 登记
- 验证：selftest 21/21；verify 25 pass/0 fail ×3 位；3 位 rm+cp -rL 重部署 diff=0×3；worktree 清理（外层仓 remove + branch -d）
- **当前 ccr 通道实测（09-08 06:4x）：haiku-1/sonnet-1/fast 全宕（curl 6s 超时）；变体 -fb（agnes 通道）下新会话可用 = 改派立即兑现**

## Resources（补充2）
- subagent-state/02-codebase-analyzer.md — 机制层完整分析（258 行）
- skills/task-planner/scripts/zcode-pretooluse.sh — 执行期拦截的改造落点
- skills/task-planner/scripts/check-complete.sh — 终验委派率统计的改造落点
- skills/task-planner/config.json:36-41 — delegation_rate_floor 接线落点

## 根因结论 2：子代理「不返回/未正确执行」（09-08 Phase 5 扩展）

**用户实测「子代理派发后一直不返回、内部没有正确执行」的根因 = provider/网络层系统性失败 + harness 同步阻塞语义 + 技能层零兜底机制，三者叠加，而非派发方式错误：**

| 排名 | 根因 | 证据 | 说明 |
|------|------|------|------|
| 1 | **路由 provider 服务（192.168.123.36:3456）本身高失败率** | R10：09-08 当天 subagent 网络失败 127 条（ECONNREFUSED 46 / other side closed 35 / 400 rejected 27）；haiku-1 档实测 4.6 分钟后 400 拒 | 子代理全部走 `custom:<uuid>:haiku-1/sonnet-1` 路由；路由器不可达或被拒 = 子代理**第一次模型请求就死**（turnPhase=processing_input），根本没执行任何工具 |
| 2 | **harness Agent 工具同步阻塞 + 非可重试错误零自动重试** | rollout attempt 恒=1；retryable=false 时 canRetry=false；主进程等待 ~4.6 分钟才拿到错误文本 | 用户体感「一直没有返回」= 同步等待期间的静默 + 失败后主进程拿到的是笼统错误而非定位信息 |
| 3 | **技能层（task-planner 协议）对 provider 层失败零机制化兜底** | critical-rules Rule 22.2/22.3/22.7 全是文本约束（同 Phase 1 根因 1 模式）；scripts/ 无 provider 健康探测；失败后靠主进程模型自觉走 22.3 改派，实测 73% 失败率下靠自觉必然崩 | 与 Phase 1 根因同构：「规则写了但没机制」；且当前 v055 门控只管主进程亲为，不管子代理失败恢复 |

**排除项（用户假设的反证）**：
- ❌ 「调用子代理的方式不对」不成立——派发协议（八字段 prompt + checkpoint 落盘）执行正确的批次（03/04/05/07/08/09/10 号检查点）全部正常返回并产出 4~27KB 检查点；失败批次全部死在 turnPhase=processing_input（第一次模型请求），与 prompt 写法无关
- ❌ v055 委派门控（check-delegation pretool sid 放行）不是致因——子代理写 subagent-state/*.md 走 plans/ .md 白名单放行，无拦截路径（R9 验证）

**修复方向（待用户裁决，见 Phase 5 后续）**：
- A. provider 健康探测前置（派发前 1 次低成本 ping 路由端点，不可用即快速失败+报告，避免 4.6 分钟静默）
- B. 失败即改派机制化（provider 类失败不消耗 retry_limit、自动升档/换 provider、连续 N 次失败熔断 STOP——做成脚本门控而非文本 Rule 22.3）
- C. 路由器侧（192.168.123.36:3456）稳定性 = 环境依赖，非本技能可修，只能探测+降级

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
