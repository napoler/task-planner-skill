# task-planner 技能深度审计 — 诊断报告

- **审计对象（worktree，只读）**：`/home/terry/task-planner-skill-worktrees/task-v065-subagent-failure-rescue/skills/task-planner/`
- **审计执行体**：general-purpose（skill-fix Phase 1 诊断，只读）
- **审计日期**：2026-09-13
- **用户核心诉求（原话）**：「一个子代理失败之后，应该选择采取挽救方案，而不是在那里摆烂。还有其他的不符合技能规范的，也需要纠正。」
- **审计标准**：`~/.zcode/skills/skill-fix/SKILL.md` Standard 39/41/43-52/56/64/65/74/75/76/59
- **重要声明**：本报告全部结论均有 `file:line` + verbatim 原文证据；未复现的线索按「负结果」如实登记（§1.9 / §3.7），不做推测性表述。

---

## §0 审计范围与文件清单

### 0.1 被审技能规模

| 项 | 值 |
|----|----|
| 文件总数 | 92（含 templates/variant 13 个、scripts 45 个：26 `.sh` + 6 `.ps1`(2) + 3 `.ts` + 2 `.cjs` + 8 selftest） |
| SKILL.md | 509 行 / sha256 `42fb5df9` |
| references/ | 11 个 .md（critical-rules.md 222 行 / 44058 B，长行密集文件） |
| templates/ | 8 顶层 .md + 13 variant .md |

### 0.2 关键文件 sha256 前 8 位与行数（审计基线）

| 文件 | 行数 | sha256[0:8] |
|------|------|-------------|
| `SKILL.md` | 509 | `42fb5df9` |
| `config.json` | 297 | `68350069` |
| `reference.md` | 285 | `00da6a66` |
| `templates/subagent_dispatch.md` | 104 | `89dfbfd1` |
| `templates/task_plan.md` | 399 | `458e9d07` |
| `references/critical-rules.md` | 222 | `7f588cfd` |
| `references/completion-gate.md` | 33 | `a47c9fd0` |
| `references/methodology.md` | 176 | `723ea017` |
| `scripts/check-delegation.sh` | 553 | `c46236b8` |
| `scripts/check-dispatch.sh` | 253 | `5681106a` |
| `scripts/check-complete.sh` | 461 | `2d6833e8` |
| `scripts/check-3file-gate.sh` | 136 | `a98ff93c` |
| `scripts/check-plan-dispatch.sh` | 131 | `7cde6ad6` |
| `scripts/subagent-fallback.sh` | 308 | `afbb8eaa` |
| `scripts/plan-created.cjs` | 123 | `2c101a8c` |
| `scripts/attest-plan.sh` | 72 | `14b0ff2c` |
| `scripts/sync-todos.sh` | 268 | `24beccd2` |
| `lib/verify.sh` | 271 | `2463ff92` |

### 0.3 审计覆盖

- **S59 前置 Read 门**：SKILL.md（全文）、references/critical-rules.md（Rule 19-28 全文精读）、completion-gate.md、goal-gate.md、methodology.md、todo-sync.md、templates/subagent_dispatch.md、templates/task_plan.md、config.json、scripts/{check-delegation,check-dispatch,check-complete,check-3file-gate,check-plan-dispatch,subagent-fallback,attest-plan,plan-created,sync-todos,zcode-posttooluse,zcode-pretooluse}、lib/verify.sh 均已 Read；其余脚本按清单 + 机械扫描覆盖。
- **兜底参考**：`plans/task-v053-skillfix-deploy/deferred-issues.log`、`plans/task-v062-interaction-modes/verification.md:108`、`plans/task-v063-methodology-intro/verification.md:102-106`。

---

## §1 核心诉求审计：失败挽救链路缺口（F-1 … F-9）

> **总体判定（P0）**：用户所述「子代理失败后摆烂」不是单点缺陷，而是**系统性缺口**——失败挽救链路（检查点续跑 → 五档兜底）**100% 存在于文本，0% 存在于机制**。
>
> - `grep -rniE "salvage|挽救|摆烂|放弃"` 全库 **零命中**（92 文件）——「挽救」在技能中不是概念、不是条款、不是检查项。
> - 全部 `scripts/*.sh|.ts|.cjs` 中，与失败相关的机制只有三处：`check-dispatch.sh`（**派发前**契约）、`subagent-fallback.sh`（**provider 类**且需人工调用）、`subagent-state/.dispatch-inflight`（串行锁，`zcode-posttooluse.sh:27-33` 清除）。**没有任何脚本/hook 观测「子代理失败」这一事件本身**。
> - 因此 Rule 22.3 五档兜底是可被模型整体跳过（silent skip）的软文本，而 Rule 22.7 STOP 却是 Rule 28.2 D6 规定的**两模式一致的强制硬停点**——结果是"跳过挽救 + 强制停止"的组合，即用户观察到的摆烂。

### F-1 [P0] 失败挽救顺序无任何机械门控，文本可被整体跳过

- **file:line**
  - `SKILL.md:378`：`**步骤 0 — 先查检查点(Rule 22.8.4)**:任何兜底动作执行前,主进程必须先 Read 该子代理的检查点文件(...)`
  - `SKILL.md:380`：`**五档兜底(优先级顺序,Rule 22.3 — 拆细先于升档)**:`
  - `SKILL.md:390-394`：触发条件四条（`status: failed`/超时/不可重试错误/连续失败 ≥2）
  - `references/critical-rules.md:124`（22.3）、`:133-138`（22.8 检查点协议）
- **原文摘录（verbatim）**
  - `SKILL.md:378`：`**步骤 0 — 先查检查点(Rule 22.8.4)**:任何兜底动作执行前,主进程必须先 Read 该子代理的检查点文件(`<plan-dir>/subagent-state/{seq}-{agent_type}.md`,路径见 Handoff 登记表「checkpoint 路径」列)`
  - `references/critical-rules.md:124`：`22.3 **失败兜底**(优先级顺序 — 拆细先于升档):超时/失败 → ① 改派(换更合适的 subagent 类型)→ ② **拆细**(...)→ ③ 降档(升一档 model,如 haiku→sonnet)→ ④ 主进程接管(单文件 ≤300 行主进程 Edit)→ ⑤ AskUserQuestion`
- **缺口分析**：整条链路（检查点 → resume_from → 五档串行）**只以 markdown 表格与条款文字表达**。机械守卫 `check-dispatch.sh` 的全部检查项为 `"$pd/task_plan.md" "$pd/findings.md" "$pd/progress.md" "status:" "acceptance:" "checkpoint:" "subagent-state/"`（`scripts/check-dispatch.sh:48`）——**全部是「派发前 prompt 内容」，无一涉及失败后的处置动作**。也就是说：模型可以完全不做步骤 0、不查检查点、不走五档，直接写 `outcome: BLOCKED`，不会有任何 hook/脚本/门控报错。对比同类风险已被机制化的项（三文件门控 `check-3file-gate.sh`、委派门控 `check-delegation.sh`、串行槽 `check-dispatch.sh:216-247`），失败挽救链是唯一「有 P0 条款但零机制」的链路。
- **修复建议**（Phase 3 输入）：① 新增 `scripts/check-rescue-chain.sh <plan-dir>`：读 `task_plan.md` Handoff 登记表 failed/timeout 行，校验「checkpoint 路径」列非空 + 新增「rescue 列」已按五档顺序留痕 + 终验时校验「已尝试挽救清单」非空；② 接入 `check-complete.sh`（终验门）与 `zcode-pretooluse.sh`（STOP 上报时）；③ `config.json` 增 `rescue_chain_enforce: enforce|warn|off`（默认 warn，与既有档位范式一致）；④ `selftest` 补 T 用例覆盖「failed 行无 rescue 留痕 → exit 1」。

### F-2 [P0] 计划期派发规划门控被静默绕过（实证：v065 本计划即被绕过）

- **file:line**：`scripts/check-plan-dispatch.sh:30-33`
- **原文摘录（verbatim）**
  ```
  if ! grep -q "执行体" "$PLAN_FILE" 2>/dev/null; then
      echo "[plan-dispatch] legacy plan(无执行体列),跳过门控"
      exit 0
  fi
  ```
- **实测证据（复现命令 + 输出）**
  ```
  $ bash skills/task-planner/scripts/check-plan-dispatch.sh plans/task-v065-subagent-failure-rescue/task_plan.md
  [plan-dispatch] legacy plan(无执行体列),跳过门控
  exit=0
  $ grep -c "执行体" plans/task-v065-subagent-failure-rescue/task_plan.md
  0
  $ grep -c "Executor:" plans/task-v065-subagent-failure-rescue/task_plan.md
  6
  ```
- **缺口分析**：legacy 判定键取**字面量 `执行体`**（只出现在 S-unit 表头 `| ID | 目标(≤1 句) | 执行体(...) |` 中），而非「是否存在 `**Executor:**` 字段」。后果：**恰好是「有 Executor 字段但缺 S-unit 表」的违规计划被判为 legacy 而放行**——这是门控本该拦截的唯一 target。v065 计划有 6 条 `Executor:` 行（含 4 个派发型 Phase：Phase 1/3/4/5），却无一条 S-unit 表，门控 0 报错；同文件 `.plan-attestation`（`attested_at=2026-09-13T15:48:46+08:00`）证明**锁定动作已成功通过该门**。`check-complete.sh:446` 终验同一门控，同样失效。→ 直接放大失败摆烂：派发型 Phase 无 S-unit 表 = 无拆分单元，失败后无法定位「拆哪个 S-unit」，22.3 ② 拆细在数据层无对象。
- **修复建议**：legacy 判定改为 `grep -qE '^- \*\*Executor:\*\*'`（无 Executor 行才算 legacy）；同时保留 `执行体` 作为表头判定的一部分。补 selftest：构造「有 Executor 行、无 S-unit 表」的计划 → 期望 exit 1。

### F-3 [P1] Rule 22.7「连续失败 ≥2 → STOP」与「穷尽挽救才放弃」语义冲突（早退 = 摆烂）

- **file:line**：`references/critical-rules.md:132`（22.7）、`:117`（21.4 首败段）、`:124`（22.3）、`SKILL.md:394`
- **原文摘录（verbatim）**
  - `references/critical-rules.md:132`：`22.7 **连续失败 STOP**:子代理连续失败 ≥2 次 → STOP 报告用户,不进入 Chain block 交接,不继续派发;升级处理后再继续`
  - `SKILL.md:394`：`- 同一子任务**连续失败 ≥2 次**(Rule 22.7)→ **强制 STOP** 报告用户,不进入 Chain block 交接`
- **缺口分析**：22.7 的触发条件是「连续失败次数」，**完全没有限定「已走完挽救链」**。与 21.4「子任务**首次**失败/超时 → 立即对照 21.1b 评估…拆细重派…未触及且疑似能力不足 → 22.3 ③ 降档」叠加后，出现「同法重试两次 → 直接 STOP」的合法路径（22.3 也只在「达 `retry_limit`（默认 2）」处写「必须 AskUser」，问的不是"是否继续挽救"，而是直接升级）。用户诉求「穷尽挽救才放弃」在本条中**不存在文字承载**。
- **修复建议**：22.7 改写为「连续失败 ≥2 次且**已完成 22.3 ①-④ 全部档位尝试**（逐档留痕于 Handoff rescue 列）→ STOP；未走完五档时，≥2 次失败 = **强制换档**（跳过重复档位，不得同法重试）而非 STOP」。

### F-4 [P0] STOP/BLOCKED 上报不要求附「已尝试挽救清单」（缺失 = 摆烂上报）

- **file:line**：`references/critical-rules.md:132`（22.7 全文）、`SKILL.md:399-403`（反模式段）
- **原文摘录（verbatim）**
  - `SKILL.md:403`：`- ❌ 失败时直接 `outcome: BLOCKED` 不留证据(违反 Rule 6 错误留痕)`
- **缺口分析**：22.7 全文仅 32 字（见 F-3 摘录），**没有任何「必须提交已尝试挽救清单」的要求**——「STOP 报告用户」的「报告」内容未定义。`SKILL.md:403` 反模式虽禁止「不留证据」，但「证据」未定义到字段级（五档各档动作/结果/失败原因/剩余可行档位）。对比：子代理侧有 8 字段严格模板（22.4b，`templates/subagent_dispatch.md:51-60`），主进程侧 STOP 上报却无对称模板 → **不对称**：子代理必须结构化，主进程可自由文本，正是摆烂话术的生成空间。
- **修复建议**：新增 22.7.1「STOP 上报最小集（6 字段）」：`失败子任务/已尝试档位（逐档动作+结果）/检查点路径+已落盘里程碑数/剩余未尝试档位或不适用原因/建议下一步/证据 file:line`；模板挂 `templates/subagent_dispatch.md` 附录（对称于 resume_from 附录，`:95-104`）。

### F-5 [P1] Handoff 登记表无「挽救状态」列，recover 口径无处落账

- **file:line**：`references/critical-rules.md:130`（22.5 列定义）、`templates/task_plan.md:345`、`scripts/subagent-fallback.sh:241`、`:277`
- **原文摘录（verbatim）**
  - `references/critical-rules.md:130`：`22.5 **交接登记**:每次 Agent() 派发前填 Subagent Handoff 登记表(时间/subagent_type/type/目标/状态(queued/pending/running/done/timeout/failed)/结论/证据/findings 落点/verify_done☐)`
  - `templates/task_plan.md:345`：`| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 | verify_done |`
  - `scripts/subagent-fallback.sh:277`：`'{dispatch_as:$t, model:$m, reason:"provider_failure_scaling", zero_cost:true, note:"零消耗改派,不计 subagent.retry_limit;变体新会话可见;Handoff 状态列记 failed→scaling-redispatch"}'`
- **缺口分析**：模板列已含 `findings 落点` / `checkpoint 路径` / `verify_done`（比 22.5 文字多一列 `checkpoint 路径`，一致性尚可），但**无 `rescue`（挽救状态）列**。`subagent-fallback.sh` 只在 JSON `note` 里**用自然语言建议**「Handoff 状态列记 failed→scaling-redispatch」，无列可落、无枚举可校、无脚本读取该口径 → 挽救动作不留痕、不可审计、终验不可查。
- **修复建议**：`templates/task_plan.md:345` 追加 `rescue(档位/结果/时间)` 与 `retry_count` 两列（并在 22.5 列定义中同步）；`状态` 列枚举补 `scaling-redispatch`；`check-rescue-chain.sh`（F-1）以该列为判据。

### F-6 [P1] `subagent-fallback.sh` 与 22.3 五档的衔接缺口（含编号错位与 `timeout` 误分类）

- **file:line**：`scripts/subagent-fallback.sh:260`、`:270`、`:280`
- **原文摘录（verbatim）**
  - `:260`：`provider|network|timeout|400|unknown|"")`
  - `:270`：`hint":"主通道与 fallback 通道均不可用 → Rule 22.3 ③ 主进程接管 / ④ AskUser"`
  - `:280`：`hint":"非 provider 类失败按 Rule 22.3 原顺序: ①换类型 → ②降档 → ③主进程接管 → ④AskUser（消耗 retry_limit）"`
- **缺口分析（三点，均可机械验证）**
  1. **`timeout` 被并入 provider 类**（`:260`）：超时的时间 → provider 通道探测/改派，而 22.3 明令「拆细先于升档」、21.4 明令「子任务首次失败/超时 → 立即对照 21.1b 评估…触及步级上限或预估超时 → 拆细重派」（`references/critical-rules.md:124`/`:117`）。脚本对**首败即应拆细的失败类型**直接给出升档改派，与核心哲学相反。
  2. **编号错位**：`:270` 把「主进程接管/AskUser」标为 22.3 ③/④，实际 22.3 中主进程接管 = ④、AskUser = ⑤（`references/critical-rules.md:124`：`④ 主进程接管(单文件 ≤300 行主进程 Edit)`）。
  3. **枚举漏档（最严重）**：`:280` 的「原顺序」把 22.3 五档写成四档，**整条剔除 ② 拆细**——脚本是模型失败时的第一信息源，它教模型跳过治本档位。
- **修复建议**：`:260` 拆出 `timeout` 独立分支，先返回「先按 21.4 对照 21.1b 评估拆细」决策（② 优先，仅当判定非"任务过大"才转 ①-fb）；`:270`/`:280` 编号改为 ④/⑤；`:280` 枚举补 `②拆细`，「非 provider 类」分支返回结构化的 `tier_order: ["dispatch_swap","split","model_downgrade","main_takeover","ask_user"]` 供模型逐步消费。

### F-7 [P0] provider 改派在本会话不可兑现，且超限场景无可用挽救路径

- **file:line**：`SKILL.md:405`、`references/critical-rules.md:125`、`references/critical-rules.md:124`（④ 上限）
- **原文摘录（verbatim）**
  - `SKILL.md:405`：`**Provider 失败主动 Scaling(task-v055-fallback)**:网络/400/超时类失败(`model.network.failed`)→ `scripts/subagent-fallback.sh`(...)` — 同段边界：`变体 agent 新会话才对 Agent 工具可见(类型列表会话启动固化);当前会话内兑现 = 新开会话派发或主进程接管。`
  - `references/critical-rules.md:125`：`**边界(如实)**:变体 agent 定义随会话启动固化——bind 后当前会话 `Agent(subagent_type="<type>-fb")` 不可见,新会话起可用;当前会话内兑现 = 新开会话派发或主进程接管;连续 2 个通道全灭 → 22.7 STOP`
- **缺口分析**：技能如实登记了「bind 后当前会话不可见」的边界（诚实，值得肯定），但**未登记后果的兜底**：失败现场实际只剩两条路——①「新开会话派发」（用户核心诉求是**当前任务内**挽救，开新会话等于任务中断，且与 21.4 串行槽/Handoff 簿记断裂）；②「主进程接管」，而 ④ 被硬限定 `单文件 ≤300 行`（`references/critical-rules.md:124`）。**当失败子任务 >300 行/多文件时，改写派不了、接管接不了、新会话断链 → 无挽救路径**，只剩 ⑤ AskUser 或按 22.7 STOP。这是「摆烂」在机制层的最后一道缺口。
- **修复建议**：补「⑤ 前置档」：provider 全灭且任务超 ④ 上限时，**先回计划层拆细**（拆到每片 ≤300 行单文件）再逐片 ④ 接管；或引入「降级交付点」机制（明确产出当前可挽救的最大子集 + 未完成清单，禁裸 BLOCKED）。同步 `subagent-fallback.sh next` 在该条件返回 `split_then_takeover`。

### F-8 [P0] silent/autonomous 模式下 D6 硬停点 + 第 5 档语义冲突 → 必然后无解空等

- **file:line**：`references/critical-rules.md:219`（D6）、`:221`（28.4）、`SKILL.md:388`（第 5 档）、`references/critical-rules.md:132`（22.7）
- **原文摘录（verbatim）**
  - `references/critical-rules.md:219`（D6）：`D6 既有硬停点——22.7 连续失败 STOP/Rule 11 drift BLOCKED/Rule 26 Q3/§五 破坏性操作确认,**两模式一致,不可静默豁免**。`
  - `references/critical-rules.md:221`（28.4）：`28.4 **silent 模式语义**:除 D6 外不调用 AskUserQuestion;每个被跳过的询问点按"推荐项"自主决策,并登记「静默决策清单」`
  - `SKILL.md:388`（第 5 档）：`| 5 | **AskUserQuestion** | 改派/拆细/降档/接管都失败,或问题需用户决策；交互模式见 Rule 28（ask=选项化询问并回填 Decisions；silent=按推荐项自主处置并登记 silent 决策行，D6 硬停点除外） | AskUserQuestion 工具 |`
- **缺口分析**：三处叠加成死结——① 22.7 是 D6 硬停点，silent 模式**必须** STOP（不可静默豁免）；② 22.7 STOP 的动作是「报告用户」，而 silent/autonomous 下**没有在线用户**；③ silent 下第 5 档 AskUserQuestion 唯一出路是「按推荐项自主处置」——但第 5 档的**推荐项未被定义**（22.3 只给档位顺序，未给"全档失败后推荐项"）。结果：STOP 强制 + 无人可问 + 无推荐项 = **无限期挂起**，正是用户所述摆烂的机制形态。文本对「autonomous 环境 AskUserQuestion 是否空等」**零定义**（全库 grep `autonomous` 只有 `autonomous_resume`，与询问门控无关）。
- **修复建议**：28.4 增例外：「D6 触发且 silent 模式且无用户在线（autonomous 判定：`TASK_PLANNER_INTERACTION_MODE=silent` 且无用户消息 N 分钟）」→ 允许一次 `AskUserQuestion` 带超时/或降级为「登记 `silent: STOP-DEGRADED` 决策行 + 交付 PARTIAL + 未完成挽救清单」，明确**禁止静默空等**；同时在 22.3 第 5 档补「推荐项 = 拆细后主进程接管 ≤300 行子集，剩余登记未完成清单」。

### F-9 [P1] Rule 28.2 D3「降档前询问」与 SKILL.md 五档表顺序矛盾（ask 模式会在第 3 档前停住）

- **file:line**：`references/critical-rules.md:219`（D3）、`SKILL.md:386-388`（五档表 3/4/5 行）
- **原文摘录（verbatim）**
  - `references/critical-rules.md:219`：`D3 兜底前移——22.3 链走到 ③ 降档前(② 拆细已失败)即询问"继续拆细/换方向/降档";`
  - `SKILL.md:388`（第 5 行）：`| 5 | **AskUserQuestion** | 改派/拆细/降档/接管都失败,或问题需用户决策`
- **缺口分析**：D3 要求**在第 ③ 档之前**（即 ② 拆细失败后立刻）询问；SKILL.md 五档表要求**第 4 档（接管）之后**才询问。同一链路两个互相矛盾的提问时点。ask 模式下按 D3 会在降档前停下等用户 → 挽救链提前中断（若用户不在线 → 空等，与 F-8 同源）。
- **修复建议**：统一为「D3 询问 = 在 ③ 降档前**给出选项并默认继续**（Recommended=按推荐项继续降档）」，或把 D3 移到第 5 档前，与五档表对齐；两处必须择一为准并互相引用。

### 1.9 负结果（已检查但未发现问题，如实登记）

| 检查项 | 结论 | 证据 |
|--------|------|------|
| `subagent-state/` 检查点机制是否完全不存在 | **否，机制存在**（路径约定/hook 校验/T5 最终结论兜底齐备） | `critical-rules.md:133-138`、`templates/subagent_dispatch.md:80-88`、`check-dispatch.sh:48`、`check-dispatch.sh:226` |
| Handoff 表是否漏 `findings 落点`/`verify_done` 列 | **否，模板已含**（仅缺 rescue 列，见 F-5） | `templates/task_plan.md:345` |
| 是否存在 TODO/FIXME/空壳脚本（S74/S65 S8） | **否，零命中** | `grep -rnE "TODO\|FIXME\|not implemented\|未实现" scripts/ lib/ tests/ templates/` → 仅命中 `mktemp ...XXXXXX` 与 `stub`（薄壳机制正当用法） |
| 是否把 `Skill()` 写进子代理**派发 prompt 模板**（S39 核心风险面） | **否**（`templates/subagent_dispatch.md` 无 `Skill(`） | `grep -rn "Skill(" templates/subagent_dispatch.md` → 零命中 |
| 三文件读写契约是否自相矛盾 | **否**（22.4a 与 `subagent_dispatch.md §2` 一致） | `critical-rules.md:127` vs `templates/subagent_dispatch.md:11-14` |

---

## §2 规范违规（V-1 … V-18）

### V-1 [P0][S56 允许工具声明] `allowed-tools` 缺 `AskUserQuestion`/`WebSearch`/`WebFetch`，直接掐断第 5 档兜底

- **file:line**：`SKILL.md:5`（声明） vs `SKILL.md:388`、`:428`、`:443`（使用）
- **原文摘录（verbatim）**
  - `SKILL.md:5`：`allowed-tools: "Read, Write, Edit, Bash, Glob, Grep, Agent, Skill, TodoWrite, TaskCreate, TaskUpdate, TaskList, TaskGet"`
  - `SKILL.md:388`：`| 5 | **AskUserQuestion** | 改派/拆细/降档/接管都失败,或问题需用户决策；... | AskUserQuestion 工具 |`
  - `SKILL.md:428`：`阶段与工具：**①WebSearch**（关键词/英文/技术，ZCode 实测可用）→ **②WebFetch**（已知 URL 纯静态页）→ ...`
- **证据（使用次数统计）**：`grep -oE` 计数 → `AskUserQuestion` 4 次、`WebSearch` 5 次、`WebFetch` 2 次；S56 主要求（4 个 Task 工具）**已满足**（`TaskCreate/Update/List/Get` 均在列）。
- **缺口分析**：S56 要求 declared 与 used 一致。`AskUserQuestion` 缺失后果最重——它是失败挽救链的**终档**（F-8），声明缺失意味着允许工具强约束环境下第 5 档不可调用 → 挽救链在终档断裂。
- **修复建议**：`SKILL.md:5` 追加 `AskUserQuestion, WebSearch, WebFetch`（`TaskOutput` 若未来启用后台派发也需补）。

### V-2 [P0][S39 子代理 Skill() 调用风险] 7 个 variant 模板把 `Skill()` 放进 Executor=子代理的 Phase

- **file:line**（机械扫描产出，见 §3.6 命令）
  | 文件:行 | Phase | Executor | 违规调用 |
  |---------|-------|----------|----------|
  | `templates/variant/bugfix-type.md:73` | Phase 2 根因定位 | `debugger（sonnet-1）` | `Skill("systematic-debugging")` |
  | `templates/variant/code-edit-type.md:93` | Phase 5 提交+收尾 | `code-assistant（haiku-1）` | `Skill("task-drift-guard")` |
  | `templates/variant/deployment-type.md:98` | Phase 5 部署后监控+收尾 | `executor（sonnet-1）` | `Skill("task-drift-guard")` |
  | `templates/variant/migration-type.md:91` | Phase 4 切流/路由切换 | `executor（sonnet-1）` | `Skill("cli-tool-builder")` |
  | `templates/variant/performance-tuning-type.md:99` | Phase 5 复现性归档+文档 | `performance-optimizer` | `Skill("task-drift-guard")` |
  | `templates/variant/schema-migration-type.md:100` | Phase 5 回滚预案确认+文档 | `database-optimizer` | `Skill("task-drift-guard")` |
  | `templates/variant/test-writing-type.md:96` | Phase 5 CI 集成 | `test-engineer（sonnet-1）` | `Skill("task-drift-guard")` |
- **原文摘录（verbatim）**
  - `templates/variant/migration-type.md:4`：`<!-- 推荐 subagent: executor (sonnet-1,跨步骤协调) + code-assistant + Skill("cli-tool-builder") -->`
  - `templates/variant/migration-type.md:91`：`- [ ] 派 `Skill("cli-tool-builder")` 检查 CLI 入口(若 CLI 迁移)`
  - `templates/variant/migration-type.md:95`：`- **Executor:** executor（sonnet-1）`
- **缺口分析**：Standard 39 明确「子代理无 Skill() 工具」。这些 `Skill()` 位于计划模板的具体 Phase 内，而该 Phase 的 `**Executor:**` 已指向子代理 → 按 Rule 25.2/SKILL.md:87「Executor 非主进程则立即派发」，该 Skill 调用将被委派给无 Skill() 工具的子代理 → 静默失败。注：`templates/variant/diagnostic-type.md:58` 命中为**误报**（该行是检查项文本「Standard 39 子代理 Skill() 调用扫描」），已过滤。
- **修复建议**：把 7 处 `Skill()` 显式标注为「**主进程**执行（Executor=子代理 Phase 内唯一的主进程例外⑤/④）」或移出 Phase 到「终验（主进程）」段；`migration-type.md:4` 的推荐注释同步删除 `+ Skill(...)`。

### V-3 [P0][门控失效] `check-plan-dispatch.sh` legacy 判定绕过（同 F-2，规范面登记）

- **file:line**：`scripts/check-plan-dispatch.sh:30-33`；**原文摘录**见 F-2。
- **可机械验证**：是（命令 + 退出码见 §3.7-③）。

### V-4 [P1][S56 代码-文档一致性] `sync-todos.sh` 的 subject 与契约文档矛盾，`phase_title` 死变量

- **file:line**：`scripts/sync-todos.sh:77` vs `references/todo-sync.md:18`、`SKILL.md:72`
- **原文摘录（verbatim）**
  - `scripts/sync-todos.sh:77`：`subject = tid "/Phase " phase_num`
  - `references/todo-sync.md:18`：`| 每个 `### Phase N: <title>` | 一条 todo | subject 格式：`{task-id}/Phase N: title`（与 `sync-todos.sh` 输出一致） |`
  - `SKILL.md:72`：`...为每个 Phase 建一条 todo（subject=`{task-id}/Phase N: title`...`
- **缺口分析**：实现在 `:77` 丢弃 title（`:60-61` 已算出 `phase_title` 但从未使用 = 死变量）；文档两处声称「含 title」且「与脚本输出一致」。**实测输出确认缺失**：`{"task_id":"task-v065-subagent-failure-rescue","phase":1,"status":"in_progress（2026-09-13）","subject":"task-v065-subagent-failure-rescue/Phase 1"}`（§3.6）。另注：`status` 字段未做清洗，把括号注释整段带出（`in_progress（2026-09-13）`），下游若做 `=== "in_progress"` 严格比较会失败。
- **修复建议**：`:77` 改为 `subject = tid "/Phase " phase_num ": " phase_title`（并按 60 字符截断规则保持）；status 提取时截断到首个非状态字符（或映射为枚举 `pending|in_progress|complete`）。

### V-5 [P1][可用性] `sync-todos.sh` 的 `PLANS_DIR` 无向上解析，SKILL.md 初始化流程会直接报错

- **file:line**：`scripts/sync-todos.sh:38`
- **原文摘录（verbatim）**：`PLANS_DIR="${PLANS_DIR:-$(pwd)/plans}"`
- **实测证据（复现 + 输出）**：见 §3.7-②。SKILL.md:297 的初始化示例为 `mkdir -p plans/task-001/ && cd $_ && bash <skill>/scripts/init-session.sh`（进入 plan 目录），紧接 `SKILL.md:72` 要求跑 `sync-todos.sh --json` → 得到 `{"error":"no_plans_dir","path":".../plans/task-v065-subagent-failure-rescue/plans"}`。
- **缺口分析**：同级脚本均有项目根向上解析（`plan-created.cjs:24-33 findProjectRoot`、`scripts/resolve-plan-dir.sh`），唯 `sync-todos.sh` 用裸 `$(pwd)/plans` → S1 映射步骤在标准流程下失败，Todo 映射静默缺失（S1 是强制时机）。
- **修复建议**：复用 `resolve-plan-dir.sh` 或加向上查找 `plans/` 祖先；失败时 stderr 明确提示需显式传 plans 目录。

### V-6 [P2][代码卫生] `sync-todos.sh` 中 `extract_plan_meta()` 重复定义（前者为死代码）

- **file:line**：`scripts/sync-todos.sh:91-99`（第一份）与 `:174-182`（第二份，字节级重复）
- **证据**：`grep -n "extract_plan_meta" scripts/sync-todos.sh` → `91:extract_plan_meta() {` 与 `174:extract_plan_meta() {`，两段函数体逐字相同（含注释 `# Returns: session_id|worktree_path|scope_files_path` 重复出现）。
- **建议**：删除 `:91-99` 重复块。

### V-7 [P1][S74/机制可信度] `plan-created.cjs` 存在性验证取任意计划，「无计划仍 exit 1」保护实际恒不触发

- **file:line**：`scripts/plan-created.cjs:63-77`（尤其 `:65-72`）；主张来源 `SKILL.md:73`
- **原文摘录（verbatim）**
  - `scripts/plan-created.cjs:65-71`：
    ```
    for (const entry of fs.readdirSync(PLANS_DIR)) {
      if (entry.startsWith('archive')) continue;
      const candidate = path.join(PLANS_DIR, entry, 'task_plan.md');
      if (fs.existsSync(candidate)) {
        planFound = true;
        planPath = candidate;
        break;
      }
    }
    ```
  - `SKILL.md:73`：`**清除哨兵**：计划创建完成后立即运行 `node ~/.zcode/skills/task-planner/scripts/plan-created.cjs`（带计划存在性验证，无计划仍 exit 1；双清除：本会话 side 哨兵 + legacy 残留）`
- **缺口分析（根因定位）**：`fs.readdirSync` 顺序 = 目录项顺序（非当前会话、非 mtime、非 active_plan 指针、非 sid）。**实测证据（只读复现，命令与输出见 §3.7-①）**：本仓 `plans/` 下 32 个目录均有 `task_plan.md`，同逻辑模拟的首个命中为 `plans/task-3file-enforce/task_plan.md`（历史计划），而真实活跃计划是 v065 → `planPath` 与「有效计划确认」提示均为误导性证据；且由于**只要任一计划存在**即 `planFound=true`，`exit 1` 分支（`:80-84`）在有历史计划的仓库中**永不触发** → SKILL.md:73 宣称的保护语义失效（模型会据 :121 的 ✓ 提示相信自己创建成功）。与父计划观察项「plan-created 清哨兵校验到 task-3file-enforce 非 v065」逐字吻合。副产品：`legacy` 哨兵清除分支（`:91-107`）另用 mtime 仲裁，两套口径并存。
- **方法备注（如实）**：本项复现使用了一次性 `node -e` 只读模拟（未写入、未执行 `plan-created.cjs` 本体，未触碰哨兵文件），仅为不改动被审对象的前提下取得可复现证据。
- **修复建议**：改为复用 `resolve-plan-dir.sh` 的解析链（active_plan_side → legacy 指针 → mtime），或接受 stdin 传入 `TASK_PLANNER_PLAN_DIR`；`planFound` 判定限定为「当前会话活跃计划存在」，旧计划不构成通过条件。

### V-8 [P1][S56/多会话正确性] `attest-plan.sh` 活跃计划探测用 mtime 最新，忽略会话指针与 sid

- **file:line**：`scripts/attest-plan.sh:29-34`
- **原文摘录（verbatim）**：`plan_file="$(ls -t plans/*/task_plan.md 2>/dev/null | head -1)"`
- **缺口分析**：直接 `ls -t` 取 mtime 最新，与技能主线（Rule 22.9 会话隔离双参解析：`plans/.active_plan_side/<sid>.active_plan` → global → mtime）**不一致**。并行会话/多计划场景下可能锁定**他会话**的计划（把别人的计划 SHA 写进别人的目录，或以「哈希不匹配」触发误报 [PLAN TAMPERED]）。对比 `check-dispatch.sh:118` 明确带 sid 调 resolver —— 同仓两套口径。
- **修复建议**：改为 `bash <skill>/scripts/resolve-plan-dir.sh "$PWD" "$SID"` 解析（或用 `set-active-plan.sh --show`）。

### V-9 [P1][S48/Goal Gate] VC 规则零机械校验，模板不提供 per-Phase V-N 骨架

- **file:line**：`references/goal-gate.md:7-8`（规则）、`templates/task_plan.md:30-44`（骨架）、`scripts/check-complete.sh`（零 VC 校验）
- **原文摘录（verbatim）**
  - `references/goal-gate.md:7-8`：`1. **≥5 条 VC**：客观、可测试、可追溯` / `2. **每 phase ≥2 条 V-N**：映射到 VC 编号`
  - `templates/task_plan.md:40`：`| VC-1 | [交付物可观测要求 1] | [运行命令 / 检查文件 / 查看输出] | [路径或命令] |`
- **证据**：`grep -n "VC\|V-N" scripts/check-complete.sh` → **零命中**（461 行终验脚本完全不校验 VC 数量/映射）。模板仅给 VC-1…VC-5 无 V-N 与 Phase 的映射骨架；`SKILL.md:29` 的 Goal 声称产出「含 Phases/VC/V-N」，但无任何机制核对 V-N 存在性。v065 本计划即为实例：VC 表 8 条，全文无 `V-N`/per-Phase V 映射。
- **修复建议**：`check-complete.sh` 增门控：VC 行数 ≥5、每 Phase 段含 ≥2 个 `V-N` 引用（缺失 → exit 1，档位 `vc_gate_enforce`）；模板 Phase 段补 `- **V-N:** VC-1, VC-3` 占位行。

### V-10 [P2][S61 引用同步] `methodology.md` 指针锚点两处过期

- **file:line**：`references/methodology.md:4`
- **原文摘录（verbatim）**：`> **指针入口**：SKILL.md:81（Poka-Yoke 前置门）/ SKILL.md:156 后（内容质量门控）/ ...`
- **证据**：实际锚点为 `SKILL.md:82`（`grep -n "methodology" SKILL.md` → 82/159/283）与 `:159`。v063 交付时已登记「CR P2① 记录锚点 :81 实为 :82（登记遗留）」（`plans/task-v063-methodology-intro/task_plan.md:66`）——**遗留至今未修**。
- **建议**：改 `SKILL.md:81` → `SKILL.md:82`、`SKILL.md:156` → `:159`。

### V-11 [P1][S75 D1 写死环境路径] 72 命中；其中 3 类为真实可迁移性缺陷

- **扫描命令与结果**：见 §3.3。分类如下（`${TASK_PLANNER_ROOT:-<默认>}` 写法 = 有 env 覆盖，属可接受默认值，登记不升级）：
  1. **真实缺陷（P1）**：`companion/agents/*.md` frontmatter 的 `model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"`（3 个 companion agent 全中）——硬编码本机 provider UUID，换机即不可用。
     - 证据：`companion/agents/article-batch-publisher.md:5`、`article-field-fixer.md:5`、`plan-writer.md:6`（verbatim：`model: "custom:9e221f47-3040-4ea7-b742-20b813fb79aa:sonnet-1"`）
  2. **真实缺陷（P1）**：`companion/agents/plan-writer.md:95`：`4. **cwd**(可选):当前工作目录,默认 `/home/terry/.zcode`` —— 硬编码用户主目录作为默认值。
  3. **真实缺陷（P1）**：`references/worktree-isolation.md:49/:56/:57/:63` 硬编码 `/home/terry/<repo>-worktrees/<task-id>`（与用户宪法 §11.2 同形，属规范层硬编码；换用户即失效）。
  4. **豁免登记**：`README.md` / `INSTALL.md` / `MIGRATION.md` / `docs/ARCHITECTURE.md` / `references/template-guide.md` 的 `${TASK_PLANNER_ROOT:-/mnt/data/dev/...}` 共 45+ 处（env 可覆盖）；`references/template-mapping.md:80/:82`（行内自标「示例路径，仅作格式示意」）；`scripts/check-complete.sh:65`、`scripts/check-dispatch.sh:23/:29/:142`、`scripts/selftest-smart-merge.sh:279`（注释中的历史说明文字，非可执行路径）。
- **建议**：① companion agent 的 model 改为经安装期注入的占位（如 `@provider_uuid`）+ 安装文档说明；② `plan-writer.md:95` 默认值改 `$HOME/.zcode`；③ `worktree-isolation.md` 路径模板参数化为 `${REPO_PARENT}`，并在宪法/技能间保持单一来源。

### V-12 [P1][S75 D3 平台一致性] `.claude` 与 `.zcode` 混用 5 命中，其中 3 处属真实缺陷

- **扫描命令与结果**：见 §3.4。逐条判定：
  - **豁免**：`SKILL.md:23`（`# See: ~/.claude/... (Claude Code) / ~/.zcode/... (ZCode)`）——显式双平台声明，设计如此。
  - **真实缺陷（P1）**：`SKILL.md:68`：`- 兜底：`~/.zcode/skills/task-planner/templates/{filename}`（内置 5 模板）` —— 同文件 `:23` 已声明双平台，此处硬写 `.zcode`，Claude Code 侧路径错误。
  - **真实缺陷（P1）**：`templates/task_plan.md` / `references/template-guide.md:12`：项目级覆盖目录固定写 `.claude/plan-templates/`，ZCode 侧应为 `.zcode/plan-templates/`（或平台无关写法）。
  - **真实缺陷（P2）**：`references/template-mapping.md:102/:104`：`mkdir -p ~/.claude/skills/skill-fix/.claude/plan-templates/` —— 双 `.claude` 叠加，示例路径可疑。
- **建议**：统一为 `${TASK_PLANNER_PLATFORM_DIR}`（或明确「两目录都探测」）并在 `references/template-guide.md §一` 单一权威源登记。

### V-13 [P1][S75 D2 @configurable 登记] 3 个 `.ts` 工具无 `@configurable` 块

- **扫描命令与结果**：`grep -L "@configurable" scripts/*.ts` → `scripts/register-hooks-cj.ts`、`scripts/session-catchup.ts`、`scripts/sync-ide-folders.ts`（3/3 缺失）。
- **判定**：S75 D2 要求工具文件头部有 `@configurable` 登记或 CONFIG 区。三者均含可变参数（hook 注册目标路径、会话扫描根、IDE 目录映射）。
- **建议**：为三文件补头部 `@configurable` 注释块（路径/超时/映射表），与 `subagent-fallback.sh` 等既有 CONFIG 范式对齐。

### V-14 [P1][S76 D2 锁与串行化] 计划账本存在无锁并发追加路径

- **扫描命令与结果**：见 §3.5。
- **证据**：全库仅 `scripts/ledger-append.sh:132` 使用 `flock`（verbatim：`if command -v flock >/dev/null 2>&1; then`，注释 `# flock 在持锁期间同时计算 tick 并写入,防并发 appender 撞号`）；而**另外两条写同一计划目录账本的路径无锁**：
  - `scripts/check-delegation.sh:196`：`"$ts" "$sid_esc" "$file_esc" "$remain" >> "$plan_dir/$LEDGER_FILE"`（无 flock）
  - `scripts/allow-direct.sh:118`：`"$ts" "$sid" "$force_tag" "$stamp" >> "$plan_dir/ledger-delegation.jsonl"`（无 flock）
- **缺口分析**：`check-3file-gate.sh:88-98` 以 `ledger-*.jsonl` 为**主信号**判定"本 Phase 有真实工作"——无锁追加在并发会话下可能产生交错/半行，使门控读到非法 JSON 行（`:92` 用正则抽取 ts，半行会静默跳过）→ 门控误判。D3/D4 判定：`>= 120` 字节的单次 `printf >>` 在 Linux 上通常原子，D4 追加式日志可豁免；但 D2「写共享资源无锁且未声明串行前提」成立。
- **建议**：三处统一走 `ledger-append.sh`（已含 flock），或各自加 `flock -w 5` 包裹；在文件头声明「并发追加前提」。

### V-15 [P2][S56 文档-实现一致性] `subagent-fallback.sh` 内置默认值与 `config.json` 默认值不一致

- **file:line**：`scripts/subagent-fallback.sh:40` vs `config.json`（`provider_fallback.probe_timeout_ms.default`）
- **原文摘录（verbatim）**
  - `scripts/subagent-fallback.sh:40`：`CFG_PROBE_TIMEOUT_MS=10000`
  - `config.json`（`provider_fallback.probe_timeout_ms`）：`"default": 20000`，描述：`单通道 1-token 探测 curl -m 秒数（ms）；默认 20000 覆盖冷启动首连（实测 agnes 通道冷启动 >10s）`
- **分析**：config 可读时取 20000（正常路径无碍），但 config 缺失/损坏时回落到 10000 —— 恰是注释里说明「冷启动 >10s 会误判」的值 → 降级路径会误报通道不健康。属 fail-open 方向错误。
- **建议**：`:40` 改 `20000` 与 config 对齐。

### V-16 [P1][S74/回归缺口] `lib/verify.sh` 自测清单仍未含 `selftest-methodology.sh`（v063 遗留项）

- **file:line**：`lib/verify.sh:227`
- **原文摘录（verbatim）**：`for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh; do`
- **证据**：`plans/task-v063-methodology-intro/findings.md:71` 已登记（`P2③ lib/verify.sh:227 §9 循环 for _script in check-delegation.sh allow-direct.sh selftest-delegation.sh 未含 selftest-methodology.sh → 登记遗留`），至今未修 → 部署校验不覆盖 methodology 守护脚本。
- **建议**：循环补 `selftest-methodology.sh`（及 `selftest-fallback.sh`、`selftest-interaction.sh`、`selftest-plan-dispatch.sh`、`selftest-smart-merge.sh`、`selftest-active-plan.sh`——当前 6 个 selftest 仅 1 个进 verify 清单）。

### V-17 [P2][S64] `references/template-guide.md:106` 引用的模板文件不存在

- **file:line**：`references/template-guide.md:106`
- **原文摘录（verbatim）**：`cp ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/templates/task_plan-research.md \`
- **证据**：`test -e templates/task_plan-research.md` → 不存在（`templates/` 实有 8 个顶层模板 + `variant/` 13 个）。上下文（`:102-106`）为「项目级覆盖示例」，要求先 `cp templates/task_plan.md → .claude/plan-templates/task_plan-research.md` 再从此处 `cp` 回读——第二步源文件不存在，示例不可执行。
- **说明**：`skill-fix` 的 `path_existence_validator.ts` 未捕获此项——该工具 `scanScripts/scanReferences` 只接收 SKILL.md 的 `content`（`tools/path_existence_validator.ts:163-192`），不遍历 `references/*.md` 内文 → **校验盲区**（建议登记为 skill-fix 改进项）。本项由人工 `grep -oE` + `test -e` 扫描得出（§3.3）。
- **建议**：修正示例为已存在文件名，或补该模板。

### V-18 [P2][文档完整性] `SKILL.md` frontmatter `references:` 索引与实际引用不一致

- **file:line**：`SKILL.md:7-24`（索引） vs `SKILL.md:305-316`（References 表）
- **原文摘录（verbatim）**
  - `SKILL.md:9`：`- references/critical-rules.md: Critical Rules 全集 1-27（1-12 核心执行约束 + 13-27 高级门控，含 Rule 27 git 提交强制）`
  - `SKILL.md:284`：`- **Rule 28（P0）交互模式与询问门控**：...`
  - `SKILL.md:308`：`| `references/critical-rules.md` | Critical Rules 1-27（含 Rule 13-18/21-23/25-27 关键条款） |`
- **分析**：`critical-rules.md` 实际含 **Rule 1-28**（`:216` 起为 Rule 28），frontmatter 与 References 表均写「1-27」；`SKILL.md:20-21` 还把 `task-drift-guard`/`plan-resume` 列为 `references:` 条目（它们是 skill 名而非本文档引用）；`:22-23` 的 hooks 注释写 `~/.claude/skills/task-planner/SKILL.md`（同 V-12）。
- **建议**：Rule 编号统一为 1-28；frontmatter 的跨 skill 条目移至正文「依赖」段；`:23` 双平台写法与 V-12 一并处理。

---

## §3 机械扫描附录（原始输出关键行）

### 3.1 `bash -n` 语法检查（S65/S74）

**命令**：`for f in scripts/*.sh; do bash -n "$f"; done`（另含 `install.sh uninstall.sh lib/*.sh tests/*.sh`）

**结果**：**全部 exit=0，零语法错误**（共 42 个 shell 文件 = `scripts/*.sh` 33 + `install.sh`/`uninstall.sh`/`lib/*.sh`(6)/`tests/smoke.sh` 9）。

```
allow-direct.sh exit=0    attest-plan.sh exit=0    check-3file-gate.sh exit=0
check-complete.sh exit=0  check-conflicts.sh exit=0  check-delegation.sh exit=0
check-dispatch.sh exit=0  check-doc-sync.sh exit=0   check-drift.sh exit=0
check-plan-dispatch.sh exit=0  check-scope.sh exit=0  init-session.sh exit=0
ledger-append.sh exit=0   plan-doctor.sh exit=0      resolve-interaction-mode.sh exit=0
resolve-plan-dir.sh exit=0  selftest-active-plan.sh exit=0  selftest-delegation.sh exit=0
selftest-dispatch.sh exit=0  selftest-fallback.sh exit=0  selftest-interaction.sh exit=0
selftest-methodology.sh exit=0  selftest-plan-dispatch.sh exit=0  selftest-smart-merge.sh exit=0
set-active-plan.sh exit=0  smart-merge-back.sh exit=0  subagent-fallback.sh exit=0
sync-companion.sh exit=0  sync-todos.sh exit=0  zcode-posttooluse.sh exit=0
zcode-pretooluse.sh exit=0  zcode-sessionstart.sh exit=0  zcode-userpromptsubmit.sh exit=0
install.sh exit=0  uninstall.sh exit=0  lib/backup.sh exit=0  lib/detect-tools.sh exit=0
lib/install-companion.sh exit=0  lib/install-stub.sh exit=0  lib/migrate-refs.sh exit=0
lib/verify.sh exit=0  tests/smoke.sh exit=0
```

**TypeScript/CJS 补充**：`bun build --no-bundle` × 3 `.ts` 全部 exit=0；`node --check` × 2 `.cjs` 全部 exit=0。

### 3.2 S64 引用路径存在性验证

**命令（S74 运行时先查）**：`command -v bun` → `/home/terry/.bun/bin/bun`（存在，S74 通过，无需降级）。

**工具**：`bun ~/.zcode/skills/skill-fix/tools/path_existence_validator.ts "$(pwd)" --scope all`

**结果（verdict 行 + 汇总）**：
```json
{ "severity_summary": { "P0": 0, "P1": 0 }, "verdict": "PASS" }
```
- `references`: total 6 / missing 0 / ambiguous 0（全部 `status: "OK"`）
- `scripts`: total 15 / missing 0（全部 OK）
- `tools` / `tools_bare`: total 0（本技能无 `tools/` 目录 → 该维度 N/A）
- ⚠ 工具局限：`scanScripts` 对 `sd/../../scripts` 与 `sd/scripts` 双根探测，命中时写死标签 `actual_path: ".zcode/skills/task-planner/scripts/<n>"`（`path_existence_validator.ts:181-191`）——该标签是常量字符串非真实路径，不影响 PASS 结论，但报告读者易误解为"部署副本"。
- ⚠ 工具盲区：仅扫描 SKILL.md 内容，不遍历 `references/*.md`（见 V-17）。

**人工补充扫描（覆盖 references/*.md 等）**：
```
MISSING in references/template-guide.md: templates/task_plan-research.md   ← V-17（真实缺失）
MISSING in README.md: references/templates                                  ← 误报（散文短语 "references/templates 全部从 canonical rsync"）
MISSING in docs/ARCHITECTURE.md: scripts/...                                ← 误报（占位符）
MISSING in docs/ARCHITECTURE.md: scripts/scan-plans.sh                      ← 豁免（同行自标 "示例,非实存脚本"）
```

### 3.3 S75 D1 写死环境路径

**命令**：`grep -rnE "/home/[^ )\`]*|/Users/[^ )\`]*|/mnt/[a-z]+/[^ )\`]*" .`

**结果**：**72 命中**（含 `.git/` 之外全部文件）。分类计数与豁免登记见 **V-11**。关键行原文：
```
README.md:31:│ canonical source: ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/
MIGRATION.md:11:| 源 | `~/.claude/skills/task-planner/` + `~/.zcode/skills/task-planner/` 双份独立 | ...
companion/agents/plan-writer.md:95:4. **cwd**(可选):当前工作目录,默认 `/home/terry/.zcode`
references/worktree-isolation.md:49:git worktree add /home/terry/<repo>-worktrees/<task-id> -b wt/<task-id> main
references/template-mapping.md:82:   /mnt/data/dev/article-generation/.claude/plan-templates/task_plan.md  # （示例路径，仅作格式示意）
scripts/check-complete.sh:65:  # ... 实测 skills/... 与 /home/... 混合即触发)
scripts/selftest-smart-merge.sh:279:  # [2026-09-12 R3] 相对推导替代硬编码任务 worktree 路径(原 /mnt/data/... 仅本任务成立)
```

### 3.4 S75 D3 平台一致性

**命令**：`grep -rnE "~?/(\.zcode|\.claude)/skills" SKILL.md references/`

**结果**：**5 命中**（SKILL.md 3 + references 2）：
```
SKILL.md:23:# See: ~/.claude/skills/task-planner/SKILL.md (Claude Code) / ~/.zcode/skills/task-planner/SKILL.md (ZCode)
SKILL.md:68:    - 兜底：`~/.zcode/skills/task-planner/templates/{filename}`（内置 5 模板）
SKILL.md:73:  - **清除哨兵**：... `node ~/.zcode/skills/task-planner/scripts/plan-created.cjs` ...
references/template-mapping.md:102:mkdir -p ~/.claude/skills/skill-fix/.claude/plan-templates/
references/template-mapping.md:104:   ~/.claude/skills/skill-fix/.claude/plan-templates/task_plan.md  # （示例路径，仅作格式示意）
```
判定与建议见 **V-12**。（`:102-104` 有「示例路径」标注 → D1 豁免但 D3 平台混用仍成立。）

### 3.5 S76 并行安全四维度

**命令**（按 Standard 76 原文 grep 执行）：
```bash
grep -nE "writeFile|writeFileSync|>> ?\"" -- scripts/ | grep -vE "\$\{?[a-zA-Z_(]"
grep -rnE "lockfile|flock|O_EXCL|exclusive" scripts/
grep -rnE "readFileSync|appendFileSync" scripts/
grep -rnE "writeFileSync|openSync.*w|createWriteStream" scripts/
```

| 维度 | 结果 | 判定 |
|------|------|------|
| **D1 写路径隔离** | 命中项均含变量路径（`$PLAN`/`$TMP`/`$wt`/`$plan_dir`），无固定全局路径盲写 | ✅ 通过 |
| **D2 锁与串行化** | `flock` 仅 1 处命中：`scripts/ledger-append.sh:132:if command -v flock >/dev/null 2>&1; then`（注释 `:130 flock 在持锁期间同时计算 tick 并写入,防并发 appender 撞号`）；`check-delegation.sh:196`、`allow-direct.sh:118` 无锁追加同一计划账本 | ⚠ **P1**（见 V-14） |
| **D3 幂等性** | `>>` 追加为主：`ledger-append.sh:126`、`check-delegation.sh:196`、`allow-direct.sh:118`（账本追加式，重复执行 = 多行审计记录，语义正确）；`subagent-fallback.sh bind` 有内容 md5 幂等判定（`:209-215`，`selftest-fallback.sh` T07 覆盖）；`check-delegation.sh:212:echo "$n" > "$count_file"` 为覆盖写（计数器语义，sid 隔离于 `/tmp/task-planner-warn-<sid>.count`） | ✅ 通过 |
| **D4 原子写** | `register-hooks-cj.ts:88-94`：`writeFileSync(tmp, ...)` → `writeFileSync(path, readFileSync(tmp))`（tmp+rename 模式）；`task-plan-init.cjs:85`：`fs.writeFileSync(tmp, content, ...)`（同模式）；`subagent-fallback.sh:217-219`、`:231`：`> "$meta_file.tmp" && mv` | ✅ 通过（3 处状态文件写均为 tmp+rename） |

### 3.6 S39 子代理 Skill() 调用扫描

**命令**：`bun ~/.zcode/skills/skill-fix/tools/subagent_skill_auditor.ts .`（+ 自建 awk Phase↔Executor 关联扫描 `/tmp/phase_skill.awk`，滤除「Executor 行位于 Skill 行之后」的误判）

**结果（关联后）**：7 个真实命中 + 1 个误报（`diagnostic-type.md:58` 为检查项文本）：
```
variant/bugfix-type.md | Phase 2: 根因定位 | Executor=debugger（sonnet-1） | Skill("systematic-debugging")
variant/code-edit-type.md | Phase 5: 提交 + 收尾 | Executor=code-assistant（haiku-1） | Skill("task-drift-guard")
variant/deployment-type.md | Phase 5: 部署后监控 + 收尾 | Executor=executor（sonnet-1） | Skill("task-drift-guard")
variant/migration-type.md | Phase 4: 切流/路由切换 | Executor=executor（sonnet-1） | Skill("cli-tool-builder")
variant/performance-tuning-type.md | Phase 5 | Executor=performance-optimizer | Skill("task-drift-guard")
variant/schema-migration-type.md | Phase 5 | Executor=database-optimizer | Skill("task-drift-guard")
variant/test-writing-type.md | Phase 5: CI 集成 | Executor=test-engineer（sonnet-1） | Skill("task-drift-guard")
```
**负结果**：`templates/subagent_dispatch.md`（派发 prompt 模板本体）**零** `Skill(` 命中——S39 最核心的风险面干净。

### 3.7 三条已知线索复核（实测复现 + 负结果）

**① plan-created.cjs 清哨兵校验到旧 plan 而非当前 plan** → **复现，根因定位** `scripts/plan-created.cjs:65-72`：`for (const entry of fs.readdirSync(PLANS_DIR))` + 首个命中即 break，无 active_plan/sid/mtime 参与。**实测复现（只读模拟同逻辑）**：
```
$ ls -t plans/*/task_plan.md | head -1
plans/task-v065-subagent-failure-rescue/task_plan.md          ← 真实活跃计划
$ <同逻辑只读模拟 readdirSync 首个命中>
first readdir hit = /mnt/data/dev/task-planner-skill/plans/task-3file-enforce/task_plan.md   ← 脚本实际认定的"有效计划"
total plan dirs = 32
```
即 `planPath` 认定为 **task-3file-enforce**（2026-09 前的历史计划），与父计划观察项「plan-created 清哨兵校验到 task-3file-enforce 非 v065」**完全吻合**。后果：`planFound=true` 恒成立（本仓 32 个计划目录均有 task_plan.md）→ `SKILL.md:73` 宣称的「无计划仍 exit 1」**永不触发**，且 `:121` 打印的「✓ 有效计划确认: <path>」为任意旧计划路径。详见 **V-7**。

**② sync-todos.sh --json 未收录无 S-unit 列的新计划** → **部分复现，但根因与描述不同（负结果已排除主假设）**：
- **负结果（排除）**：给定显式 plans 目录时，v065 **被正常收录**：
  ```
  $ bash skills/task-planner/scripts/sync-todos.sh --json plans | grep -c v065
  1
  → {"task_id":"task-v065-subagent-failure-rescue","phase":1,"status":"in_progress（2026-09-13）",
     "subject":"task-v065-subagent-failure-rescue/Phase 1"}
  ```
  即「无 S-unit 列」**不是**收录失败的原因；JSON 生成、逗号拼接、`[]` 空输出均合法（`json_entries` 为空时 `[[ -n ... ]]` 处于 `&&` 列表非末位，`set -e` 不触发）。
- **实际复现路径（根因）**：`scripts/sync-todos.sh:38` `PLANS_DIR="${PLANS_DIR:-$(pwd)/plans}"` 无向上解析。按 `SKILL.md:297` 初始化流程（`cd` 进 plan 目录）后执行 `SKILL.md:72` 的 S1 命令：
  ```
  $ cd plans/task-v065-subagent-failure-rescue
  $ bash .../sync-todos.sh --json
  {"error":"no_plans_dir","path":"/mnt/data/dev/task-planner-skill/plans/task-v065-subagent-failure-rescue/plans"}
  $ cd skills/task-planner && bash scripts/sync-todos.sh --json
  {"error":"no_plans_dir","path":"/mnt/data/dev/task-planner-skill/skills/task-planner/plans"}
  ```
  → 现象为「未收录新计划」，根因是 CWD 解析而非计划格式。详见 **V-5**、**V-4**。

**③ attest-plan.sh 对含 Executor 字段计划判 legacy 跳过派发门控** → **复现，根因定位** `scripts/check-plan-dispatch.sh:30`：legacy 判定键为字面量 `执行体`，而现代计划只有 `**Executor:**` 行。实测输出与 `.plan-attestation` 存在性见 **F-2 / V-3**（此为三线索中最严重的一条：P0 门控失效且已实际放行本计划）。

---

## §4 修复清单排序表

| 编号 | 优先级 | 目标文件 | 修复动作 | 预估行数 |
|------|--------|----------|----------|----------|
| F-1 | P0 | `scripts/check-rescue-chain.sh`(新) + `SKILL.md:374-405` + `check-complete.sh` + `config.json` | 新建失败挽救链路机械门控（failed 行 → checkpoint 非空 + rescue 列留痕 + 挽救清单）；接入终验与 PreToolUse；增 `rescue_chain_enforce` | +120 / ~25 |
| F-2 / V-3 | P0 | `scripts/check-plan-dispatch.sh:30` | legacy 判定键改 `^- \*\*Executor:\*\*`；补「有 Executor 无 S-unit 表」selftest 用例 | 3 + 25 |
| F-4 | P0 | `references/critical-rules.md`(22.7 后) + `templates/subagent_dispatch.md` 附录 | 新增 22.7.1「STOP 上报 6 字段最小集」+ 模板 | +15 / +12 |
| F-7 | P0 | `references/critical-rules.md:125` + `SKILL.md:405` + `subagent-fallback.sh` | 补「provider 全灭且超 ④ 上限 → 先拆细再接管」档位与「降级交付点」机制 | +10 / ~5 / +15 |
| F-8 | P0 | `references/critical-rules.md:221`(28.4) + `SKILL.md:388` | silent+无用户在线 的 D6 例外与推荐项定义（禁静默空等） | +8 / +3 |
| V-1 | P0 | `SKILL.md:5` | `allowed-tools` 补 `AskUserQuestion, WebSearch, WebFetch` | 1 |
| V-2 | P0 | `templates/variant/{bugfix,code-edit,deployment,migration,performance-tuning,schema-migration,test-writing}-type.md` | 7 处 `Skill()` 标注主进程执行或移出子代理 Phase；`migration-type.md:4` 注释删 `+ Skill(...)` | 7 |
| F-3 | P1 | `references/critical-rules.md:132` + `SKILL.md:394` | 22.7 增「已走完 ①-④ 才 STOP；未走完 = 强制换档」限定 | 4 + 2 |
| F-5 | P1 | `templates/task_plan.md:345` + `references/critical-rules.md:130` | Handoff 表增 `rescue`/`retry_count` 列；状态枚举补 `scaling-redispatch` | 3 + 2 |
| F-6 | P1 | `scripts/subagent-fallback.sh:260,270,280` | `timeout` 独立分支（先拆细）；编号 ③④→④⑤；枚举补 `②拆细` + 结构化 tier_order | 12 |
| F-9 | P1 | `references/critical-rules.md:219`(D3) 或 `SKILL.md:386-388` | 统一 D3 询问时点与五档表顺序 | 3 |
| V-4 | P1 | `scripts/sync-todos.sh:77`(+, :66 status 清洗) | subject 补 `: title`；status 归一化枚举 | 4 |
| V-5 | P1 | `scripts/sync-todos.sh:38` | PLANS_DIR 复用 resolve-plan-dir / 向上查找 | 10 |
| V-7 | P1 | `scripts/plan-created.cjs:63-77` | 存在性验证改用活跃计划解析（active_plan/sid/mtime） | 15 |
| V-8 | P1 | `scripts/attest-plan.sh:29-34` | 活跃计划探测改走 `resolve-plan-dir.sh`（带 sid） | 8 |
| V-9 | P1 | `scripts/check-complete.sh`(终验段) + `templates/task_plan.md:30-44` | 增 VC 数 ≥5 + 每 Phase ≥2 V-N 门控；模板补 V-N 占位行 | +30 / +8 |
| V-11 | P1 | `companion/agents/*.md`(3) + `references/worktree-isolation.md:49,56,57,63` | model UUID 占位化/安装期注入；cwd 默认改 `$HOME`；worktree 路径参数化 | ~12 |
| V-12 | P1 | `SKILL.md:23,68` + `references/template-guide.md:12` + `references/template-mapping.md:102,104` | 平台目录统一为平台无关变体 | ~8 |
| V-13 | P1 | `scripts/{register-hooks-cj,session-catchup,sync-ide-folders}.ts` | 补 `@configurable` 头部块 | +30 |
| V-14 | P1 | `scripts/check-delegation.sh:196` + `scripts/allow-direct.sh:118` | 账本追加统一走 `ledger-append.sh` 或加 flock | 10 |
| V-16 | P1 | `lib/verify.sh:227` | 自测清单补 6 个 selftest | 1 |
| V-6 | P2 | `scripts/sync-todos.sh:91-99` | 删除重复函数定义 | −9 |
| V-10 | P2 | `references/methodology.md:4` | 锚点 `:81`→`:82`、`:156`→`:159` | 1 |
| V-15 | P2 | `scripts/subagent-fallback.sh:40` | 内置默认 10000 → 20000 | 1 |
| V-17 | P2 | `references/template-guide.md:106` | 修正不存在模板引用 | 2 |
| V-18 | P2 | `SKILL.md:9,308`(+`:20-23`) | Rule 编号 1-27 → 1-28；frontmatter 条目归位 | ~6 |

**依赖顺序建议**：F-2/V-3（门控恢复）→ F-1（挽救链路骨架）→ F-3/F-4/F-5/F-6/F-7/F-8/F-9（条款与脚本补齐）→ V-1/V-2（P0 规范）→ 其余 P1 → P2。V-9 与 F-1 共用 `check-complete.sh` 改动，宜同批提交。

---

## §5 范围外发现（建议登记 `deferred-issues.log`）

| # | 发现 | 证据 | 建议归属 |
|---|------|------|---------|
| D-1 | `skill-fix` 工具 `path_existence_validator.ts` 存在**校验盲区**：`scanReferences/scanScripts` 只接收 SKILL.md 的 `content`，不遍历 `references/*.md`（本次 V-17 的 `templates/task_plan-research.md` 缺失即因此漏报） | `~/.zcode/skills/skill-fix/tools/path_existence_validator.ts:163-192` + V-17 | skill-fix 技能维护任务 |
| D-2 | 同工具的双根探测会在命中时输出**常量标签** `actual_path: ".zcode/skills/<skill>/scripts/<n>"`（非真实路径），审计报告易误读为「部署副本已校验」 | `path_existence_validator.ts:181-191` + §3.2 | skill-fix 技能维护任务（输出语义澄清） |
| D-3 | `path_existence_validator.ts` 自身硬编码 `.zcode` 平台串（`${sn}` 模板）——S75 D3 精神下属审计方自指缺口（Standard 75 已自认该现象） | `path_existence_validator.ts:187,192` | skill-fix（低优先） |
| D-4 | `plans/task-v062-interaction-modes` 遗留 ②③（`verification.md:108`：env 层非法值静默降级无诊断 / 2 条 P3 未改）与 v063 遗留 ②（methodology.md:137/:158 出处泛化）在本轮审计对象中**仍可见**，但属其他 skill 或纯文档出处补全，非本次修复范围 | `plans/task-v062-interaction-modes/verification.md:108`、`plans/task-v063-methodology-intro/task_plan.md:66` | 后续 skill-fix 轮次 |
| D-5 | 本技能 `plans/` 下 30+ 历史计划目录无归档策略（Archive 机制仅靠目录名 `archive*` 前缀约定），是 V-7/plan-created 类「取任意计划」缺陷的放大因素 | `scripts/plan-created.cjs:66`（`entry.startsWith('archive')`）+ `ls plans/` 实测 30+ 目录 | task-planner 后续轮次（归档策略） |

---

## §6 审计结论

- **P0 项 8 条**（F-1、F-2/V-3、F-4、F-7、F-8、V-1、V-2，其中 F-2 与 V-3 同为一条机制缺陷的两面）
- **P1 项 14 条**（F-3、F-5、F-6、F-9 + V-4、V-5、V-7、V-8、V-9、V-11、V-12、V-13、V-14、V-16），**P2 项 5 条**（V-6、V-10、V-15、V-17、V-18）
- **核心判定**：用户诉求「失败后挽救而非摆烂」在**机制层完全缺失**——文本齐备（Rule 22.3/22.7/22.8）但零机械门控、零 hook 观测、零 test 覆盖（`scripts/selftest-fallback.sh:88-91` T04 仅覆盖「非 provider → non_provider_error」，无任何时间/失败挽救链用例）；且存在两处**会让挽救链提前死亡**的机制缺陷：`check-plan-dispatch.sh` 门控静默绕过（F-2，已实际放行本计划）与 silent 模式 D6 硬停（F-8，autonomous 下必挂起）。修复必须优先落到「可机械验证」的脚本层，而非仅补文本条款。
- **可机械验证项**（修复后可用命令复现）：F-2、F-6、F-8（文本 grep）、V-1、V-2、V-3、V-4、V-5、V-6、V-7、V-9、V-10、V-15、V-16、V-17、V-18。
