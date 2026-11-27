# Comet 执行可信度机制学习方案 — 设计规格

- 日期：2026-11-27
- 状态：设计已批准（用户当日逐节确认：交付=方案+writing-plans 实施计划；优先级=地基优先；第 3-6 节全部通过）
- 来源诉求（原话要点）：把 Comet 技能特性融合进当前项目；搞清「为什么 Comet 执行可信度更高、本项目执行容易出错」；制定完善学习方案；**不得忘记项目核心=长线会话记录的数据基础、确保长任务执行稳定性**
- 范围：纯设计文档 + 后续 writing-plans 实施计划；**本阶段不改任何 `skills/` 源码、不部署、不提交**

## 1. 背景与证据

用户观察到本项目「执行的任务往往非常容易出错」，希望从同源（Superpowers/OpenSpec）的 Comet 学习可信度机制。两名只读子代理分别调研 Comet 源侧可信度机制与本项目失败判例，关键断言已由主进程盘上抽查复核。

**Comet 可信度的本质**：不靠「模型更谨慎」，而靠把决策、验收、证据、状态、失败、恢复都变成**有归属、有绑定、有阻塞的显式协议**——每个环节都有一个「不许自己说了算」的硬约束。

**本项目的结构性缺陷**（不是某次写错，而是同一模式反复出现）：判定与状态写在文本/JSON 里，但执行者实际读取面、机器门与消费链没有咬合——SOFT_ONLY 两次复发、假绿门、权威源空壳、部署漂移、子代理伪造证据。

## 2. 目标 / 非目标

**目标**：从 Comet 提炼可信度底层机制，按「地基→入口→出口」顺序融合进 task-planner，每条机制都回答「防住哪类本项目已发生的真实错误」并落成可机器判定的门或 selftest 断言。

**非目标（明确排除，防范围蔓延）**：
- 不做点状补丁、不把技能特化到单一任务/单一内容类型（§2.6 通用性铁律）
- 不新增独立 skill；不照搬 Comet 的 CLI / YAML runtime（本项目是文件系统驱动）
- 不另建平行状态源；派生视图仍由 `planctl render` 唯一派生，禁手工 Edit
- 本阶段不改 `skills/` 源码、不部署、不提交

## 3. 六维根因对照表

| 可信维度 | Comet 怎么做（源锚） | 本项目失败判例（证据） | 差距判定 |
|---|---|---|---|
| 决策可信 | 候选点四分类（用户决策/自动/停止/手动衔接）；≥2 合法选项才建用户门；禁止推荐值替用户拍板；未决项写 `[blocking]` 回写 Decisions（`comet/reference/decision-point.md:9-24`、`comet-native/reference/clarification.md:65-77`） | 归因层级错位致方案四轮返工；范围反复窄化/中途扩张；并行抢同一锚点（`plan-writing-genericity-methodology-20261126`、`scope-narrowing-antipattern-20261122`、`rule-number-collision-v179-v180`） | 有文本歧义门，无四分类机器判定；G1-G4 用户门停在文本，无 `[blocking]` 账本消费 |
| 验收可信 | Builder→只读复核→独立 Verifier 三分离；Verifier 最后看交接摘要；每 scope 恰好一次 `passed/failed/blocked`；异常不静默；`skills_invoked` 只认真实事件（`comet-native/SKILL.md:56-84`、`commands.md:40-47`、`eval/README.md:410-415`） | SOFT_ONLY 两次；零断言 selftest 计 PASS；子代理编造"原始输出"；判据不可达空转 11 轮；门命中仍 exit 0（`planctl-script-not-effective-20261122`、`subagent-verifier-fabricated-output-20261103`、`task-skill-audit-remaining-20261127/findings.md:23`、`four-governance-defects-20261124:16`） | **最集中缺口**：门只校验末态产物形态，不校验「断言真执行/证据来自现场/执行者实际读到什么」 |
| 证据可信 | 证据绑定当前 draft hash；eval/review/readiness 读同一份 `workflow-protocol.json`；旧证据只留审计（`comet-any/reference/eval-provider.md:17-25`） | grep 含 `\$` 静默失配；子代理数错行/误报 P0；错字被逐字落盘放大为需求锚（`four-governance-defects-20261124:17`、`subagent-verifier-fabricated-output-20261103:15`） | 权威源已建但「证据→版本绑定」弱；复核手段本身不可靠 |
| 状态可信 | `comet-state.yaml` 跨设备唯一可信；state version 保护；`runId` 拒迟到回报；`readyChildren` 锁执行面；dirty worktree 不自动推进（`comet-native/reference/artifacts.md:20-23`、`SKILL.md:63/109`） | 完成仍 pending 的半成品；指针读写命名空间分裂；worktree cwd 误解析；Edit 吞锚 7 犯；改源仓≠生效；部署槽位误传致 skills 根覆盖（`task-cleanup-alignment-efd03cc3-halfbaked-20261125`、`worktree-cwd-hook-misresolution`、`source-change-not-deployed-never-effective-20261124`、`deploy-slot-safety-incident-20261126`） | **并列首要缺口**：权威源/指针/部署位/计划态四处漂移，门在错误基线上判定 |
| 失败可信 | 四类异常显式路径；降级须用户确认；无进展止损（`max_verify_failures`）；`repair-child` 不推倒重来；保留现场；根因未明禁修（`commands.md:40-47`、`recovery.md:45-51`、`debug-gate.md:7-17`） | 失败被归因为「执行方跳过」而非技能缺驱动点；84 次 agent 失败无汇总；420 派发无 checkpoint；cleanup 只打印不执行（`execution-failure-is-skill-defect-no-executor-blame`、`task-planner-slowness-forensics-20261123`、`sess-ba603cf5-skill-loop-guard`） | 文本规则有，无计数驱动点；失败台账写了无人消费 |
| 断点可信 | 磁盘状态为准、聊天记忆只辅助；`state check --recover`；四态只读探针；恢复以持久化状态为准、不重复建资源；跨设备重验不计失败轮次（`comet/reference/context-recovery.md:5-25`、`recovery.md:9-43`） | 恢复后假设从断点继续实被他窗口合并；压缩后技能正文注入绑 inflight 整段跳过；两段式零消费者（`interruption-recovery-first-verify`、`compact-skill-always-inflight-root-cause-20261124`） | Rule 119 + SessionStart 只读探针已修「两段式」一点（`critical-rules.md:378-396`）；其余压缩恢复/跨设备重验无同等级驱动链 |

## 4. 学习优先级（地基→入口→出口）

两侧调研独立收敛到同一洞察：**缺的不是「再写一条规则」，而是把判定/状态从文本变成有归属、有绑定、有消费的机器链——优先改造「消费侧门」而非「写入侧条款」。**

1. **状态可信 + 证据绑定（地基，先做）**：借鉴 Comet「唯一事实源 + 版本绑定 + 执行面锁死」。落地 `plan-state.json` 唯一写入口 + 证据→版本绑定 + 部署位对账 + 单一事实源消费校验。直接服务「长线会话记录数据基础」：底座不可拆，改造只在其上加消费门。
2. **验收可信（质量出口，第二步）**：借鉴 Comet「三分离 + 强制三态判定 + 异常不静默」。落地判别性负控制夹具——零断言 selftest 必须 FAIL、假绿门/WARN 必须 FAIL、伪造证据必须被主进程重跑抓出。
3. **决策可信 + 断点可信（入口与跨会话稳定性，第三步）**：借鉴 Comet「四分类 + `[blocking]` 账本 + 只读恢复探针」。现有合规门（SKILL.md G1-G12 清单）中涉及用户专属决策者升级为可判定账本（`decisions` 字段 + `[blocking]` 未决项）；压缩技能正文注入已解绑 inflight（`zcode-sessionstart.sh:112-118` 已落地，本阶段只做回归守护）；只读恢复探针现状为二态（inflight 命中/未命中 + DEGRADED），按 Comet 四态语义补结构化 verdict（新实施）。

**顺序理由**：先地基（否则门建立在漂移状态上、重演 SOFT_ONLY）→ 再验收夹具（否则不知道改完是否真生效）→ 最后决策与断点（前两步机器链是它们的载体）。只写条款不加绑定/消费 → 重演「机制齐备但执行不起效」。

## 5. 分阶段融合路线

每阶段沿用既有形态：**条款 + 机器门 + selftest 负控制 + examples review**，不新增独立 skill、不照搬 CLI/YAML runtime。

**Phase 1 — 地基：状态可信 + 证据绑定**
| 动作 | Comet 机制 | 落地形态 | 防住的错误 |
|---|---|---|---|
| 唯一事实源消费校验 | `comet-state.yaml` 唯一可信、MD 只是投影 | `check-*` 门改读 `plan-state.json`；负控制：只改 MD 不改 JSON 不得放行 | SOFT_ONLY、手改报告冒充验收 |
| 证据→版本绑定 | 只有当前 hash 的 evidence 能推进 | `plan-state.json` 增 `evidence_binding`（产物路径→sha256→写入版本）；VC 引用须与当前绑定一致，旧哈希只审计 | 旧结果给新版本背书 |
| 部署位全文件对账 | 单一事实源 | `lib/verify.sh` 现状=full-copy 比 SKILL.md、thin-shell 已对 references/templates/config.json/schemas 做 `diff -rq`（:90/:103-111），真缺口=**scripts/lib 被排除**（本地化 rewrite）；扩到 scripts 并规范化合法差异 | 改源仓≠生效、部署位脚本篡改失明 |
| 单一写入口强化 | `readyChildren` 锁执行面 | PreToolUse 拦对 4 个派生 MD 的直接 Write/Edit | Edit 吞锚、绕过 render |

**Phase 2 — 质量出口：验收可信**
| 动作 | Comet 机制 | 落地形态 | 防住的错误 |
|---|---|---|---|
| 判别性负控制夹具 | 每 scope 恰好一次判定、异常不静默 | 零断言 selftest→FAIL；fail-open/WARN→FAIL；子代理伪造证据→主进程重跑必抓出 | 假绿门、零断言 PASS、伪造输出 |
| 三分离验收 | Builder/只读复核/Verifier 分离、最后看摘要 | 验收独立上下文 + 只读复核步骤 + 强制 `passed/failed/blocked`（blocked 须用户确认） | 自评自验、复述 builder 结论 |
| 真事件校验 | `skills_invoked` 只认真实调用 | 合规证据从产物反推改为工具事件登记 | 倒推「应该调用过」 |

**Phase 3 — 入口与稳定性：决策可信 + 断点可信**
| 动作 | Comet 机制 | 落地形态 | 防住的错误 |
|---|---|---|---|
| 决策四分类 + `[blocking]` 账本 | 四分类、禁默认值替用户拍板 | 现有 `decisions` 字段扩展为可判定用户门账本（保留 G1-G12 合规清单语义）；未决项入 `[blocking]`；注：仓库无 G1-G4 字面对象 | 推荐项静默拍板、口头决定不落地 |
| 压缩恢复注入解绑（已落地→回归守护） | 磁盘状态为准 | 现状 `zcode-sessionstart.sh:112-118` 已无条件注入技能正文；本阶段补 selftest 守护，防回退 | 恢复包整段跳过 |
| 只读恢复探针四态 | `auto_resume/ask_user/out_of_scope/none` | 探针只读判定，不建计划/不切分支/歧义不猜 | 误判进度、多候选猜一个 |

## 6. 长会话数据基础加固（核心锚，独立成节）

**不可拆底座**：`plan-state.json`（权威） + `task_plan/findings/progress/verification`（render 派生视图） + `user-session-log.md`（原话 append-only） + `knowledge-brief.md`（知识维） + `.zcode/ledger/`（长期进度） + `todo.json`（跨任务待办）。

Phase 1-3 只在其上加「消费门/绑定字段」，**绝不另起平行状态源**。Phase 1 的版本绑定让证据可信跨会话成立；Phase 3 的只读探针与注入解绑让压缩/接续不丢状态——这是对「项目核心=长线会话记录数据基础」的直接加固。

## 7. 验收标准（可机器判定）

1. **判别性双向**：每个新门须有正例（该过→PASS）+ 负控制（该拦→FAIL），负控制不被抓出即不算完成。
2. **零回归**：全量 selftest 的 FAIL 集合 == 基线，不新增 FAIL。
3. **部署对账**：改动落地后各部署位 diff=0（全文件，非仅 SKILL.md）。
4. **通用面三问**：换项目成立 / 与既有门互认（不新增 hook 除非必要）/ 部署位形态实测。

## 8. 自审（brainstorming Spec Self-Review）

- **占位扫描**：无 TBD/TODO/「略」，各阶段均有具体动作与验收（PASS）
- **内部一致性**：三阶段顺序与第 4 节优先级一致；底座不可拆与「不另起平行状态源」一致（PASS）
- **范围检查**：聚焦可信度机制融合；Eval/Supervisor/自进化三块 backlog 不在本方案内（属独立任务），边界清晰（PASS）
- **歧义检查**：「地基优先」已明确为状态/证据绑定；「消费侧门」已用表格逐项落地（PASS）

## 9. 证据清单（来源）

- Comet 源侧：`~/.zcode/skills/comet/reference/decision-point.md`、`comet/reference/context-recovery.md`、`comet/reference/debug-gate.md`、`comet/reference/dirty-worktree.md`、`comet/reference/auto-transition.md`；`comet-any/reference/{eval-provider,bundle-authoring,authoring-subagents}.md`；`comet-native/SKILL.md`、`comet-native/reference/{commands,artifacts,clarification,recovery}.md`；`comet/rules/comet-workflow-guard.md`；`~/.npm-global/lib/node_modules/@rpamis/comet/eval/README.md`
- 本项目侧：`todo.json:5-60`（三块 backlog）；`skills/task-planner/references/critical-rules.md:358-396`（Rule 118/119 已合并先例）；记忆目录判例条目（见第 3 节逐行引用）；`plans/task-skill-audit-remaining-20261127/findings.md:23`（D1/D2/D3 判别夹具）
- 提交证据：`76a81024`→`ced991e4`（Rule 118/119 已进 master，`git merge-base --is-ancestor` 复核为 YES）
