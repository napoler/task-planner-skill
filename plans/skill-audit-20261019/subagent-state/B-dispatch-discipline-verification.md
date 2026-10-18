# 检查点 — 子代理 B：task-dispatch / task-discipline / verification-gate 深度审计
# 审计标准 = skill-fix（S40/S56/S64/S2/S25/S63/S67/S75/S68/S74）；只读，未改任何技能文件
# 生成时间 = 2026-10-19；审计对象全部文件已 Read（SKILL.md + references/ + scripts/ + templates/；三技能无 config.json）

## 0. 审计对象文件清单（全部 Read，含行数）

### task-dispatch（SKILL.md 2960B + 4 references + 6 scripts）
- SKILL.md
- references/critical-rules-dispatch.md（175 行）
- references/agent-coverage.md（130 行）
- references/dispatch-examples.md（107 行）
- references/split-pattern-library.md（136 行）
- scripts/analyze-splits.sh（198 行）
- scripts/check-rescue-chain.sh（286 行）
- scripts/check-subagent-return.sh（98 行）
- scripts/selftest-fallback.sh（146 行）
- scripts/selftest-rescue-chain.sh（132 行）
- scripts/subagent-fallback.sh（316 行）

### task-discipline（SKILL.md 5570B + 3 references + 2 scripts + 1 capability）
- SKILL.md
- references/batch-quality-gate.md（171 行）
- references/capability-registry.md（10 行）
- references/critical-rules-discipline.md（589 行 / ~40K 字）
- scripts/plan-hygiene.sh（165 行）
- scripts/capabilities/agnes-quota.sh（211 行）

### verification-gate（SKILL.md 5795B + 1 reference + 1 script + 1 template）
- SKILL.md
- references/critical-rules-verification.md（52 行）
- scripts/run-verification.sh（127 行）
- templates/verification.md（151 行）

---

## 1. 逐条发现（等级 + 标准 + 位置 + verbatim 证据 + 建议）

### [P1] task-dispatch 规则全文跨 skill 引用未加 ../task-planner/ 前缀（机械层留守脚本/config/引用错位）
- 标准: S64
- 位置: task-dispatch/references/critical-rules-dispatch.md:8（Rule 12）, :38（Rule 21.6.1）, :152（Rule 59.6）；及多处 `config.json#subagent.*` 引用
- 证据:
  - Rule 12: `完成后验证并主动合并回原分支再清理（合约见 `references/worktree-isolation.md`）`
  - Rule 21.6.1: `机器面=selftest-split-pattern-library.sh 静态守护（库在位/模式锚/消费契约段）`
  - Rule 59.6: `机器面=`scripts/analyze-splits.sh`… + `scripts/selftest-subagent-granularity-skill-escort.sh``
  - 正文多处 `config.json#subagent.step_max_files`(如 21.1b/:21)
- 分析: 上述 `scripts/*.sh`、`config.json`、`references/worktree-isolation.md` 实际均在 task-planner/ 下（已验证存在），本卫星 task-dispatch/ 下并无这些文件（references/ 只有 4 个、scripts/ 只有 6 个，无 worktree-isolation.md、无 selftest-split-pattern-library.sh、无 config.json）。SKILL.md 脚本表（:54-55）已正确使用 `../task-planner/scripts/` 前缀——同技能内"SKILL.md 带前缀 / references 不带前缀"两种写法并存，references 侧会误导读者在 task-dispatch/references/ 下找 worktree-isolation.md（不存在）。
- 建议: critical-rules-dispatch.md 内所有指向 task-planner 的 scripts/config/references 引用统一加 `../task-planner/` 前缀（与 SKILL.md 脚本表对齐），或显式声明"下列 scripts/ 均指 task-planner/scripts/"。

### [P1] task-discipline 规则全文跨 skill 引用未加 ../task-planner/ 前缀（同模式，40+ 处）
- 标准: S64
- 位置: task-discipline/references/critical-rules-discipline.md 全文；示例 :15（Rule 28.5 `scripts/resolve-interaction-mode.sh`）、:29（Rule 31.6 `scripts/selftest-error-loop.sh`）、:30（Rule 28.5 `scripts/selftest-interaction.sh`）、:40（Rule 36.7 `scripts/check-skill-modify.sh`/`scripts/selftest-skill-modify.sh`）、:43（Rule 42.5 `scripts/selftest-reliability-institution.sh`）、:46（Rule 43.4）、:52（Rule 44.4 `scripts/selftest-ask-default-timeout.sh`）、:54（Rule 65.5 `scripts/periodic-review.sh`/`scripts/selftest-periodic-review.sh`）、:64（Rule 67.5 `scripts/zcode-posttooluse.sh`）、:65（Rule 67.6 `scripts/selftest-context-pressure.sh`）、:77（Rule 69.6 `scripts/selftest-decision-arbiter.sh`）等
- 证据:
  - Rule 31.6: `scripts/selftest-error-loop.sh 静态守护（31.x 条款 + 模板列 + config 键 + SKILL 联动 + C19 + Learning Gate 锚点）`
  - Rule 65.5: `scripts/periodic-review.sh 检测结论一致性`
- 分析: 这些 selftest/check 脚本实际全部在 task-planner/scripts/（已验证 35 个 EXISTS），task-discipline/scripts/ 下只有 plan-hygiene.sh 与 capabilities/agnes-quota.sh（+ capability-registry 登记的 agnes-quota 一条）。SKILL.md 脚本表（:76-77）只列了本卫星自有 2 个脚本，未对"规则全文引用的 30+ 个 task-planner 机械脚本"加前缀。references 侧 `scripts/xxx.sh` 语义实际指向 task-planner/scripts/，读者按字面会去 task-discipline/scripts/ 找（多数不存在）。
- 建议: 同 task-dispatch——references/critical-rules-discipline.md 内指向 task-planner 的脚本/config 统一加 `../task-planner/` 前缀；或在文件头加一条"本文件 scripts/* 与 config.json 均指 task-planner/ 侧"的迁移注记（当前迁移注记只说了正文逐字复制，未说路径语义）。

### [P1] verification-gate 规则全文与 SKILL.md 对 selftest-verification-gate.sh 位置描述矛盾
- 标准: S40 / S64
- 位置: verification-gate/references/critical-rules-verification.md:44 vs verification-gate/SKILL.md:73
- 证据:
  - critical-rules-verification.md:44（Rule 84.6）: ``selftest-verification-gate.sh``（本卫星 scripts/）静态守护（84.1-84.6 子条文本锚…）
  - SKILL.md:73: `| selftest-verification-gate.sh | 静态守护（Rule 84 锚，机械层留守主技能） | 回归 | ../task-planner/scripts/ |`
- 分析: 同一脚本，规则全文说在"本卫星 scripts/"、SKILL.md 表格说在"../task-planner/scripts/（机械层留守主技能）"。实际：verification-gate/scripts/ 只有 run-verification.sh，无 selftest-verification-gate.sh；task-planner/scripts/ 有（已验证 EXISTS）。即 SKILL.md 正确、规则全文（critical-rules-verification.md:44）写错位置。SKILL.md 同表（:68-72）对 check-3file-gate/attest-plan/check-complete/check-plan-dispatch 均正确标注 ../task-planner/scripts/，唯独 selftest-verification-gate 在规则全文侧漂移成"本卫星"。
- 建议: 将 critical-rules-verification.md:44 的"（本卫星 scripts/）"改为"（task-planner/scripts/，机械层留守）"，与 SKILL.md:73 对齐。

### [P1] split-pattern-library.md 伴飞映射表硬编码 14 个 /home/terry/ 绝对路径
- 标准: S75
- 位置: task-dispatch/references/split-pattern-library.md:13-20（来源技能总表）, :124-130（伴飞映射表）
- 证据:
  - `| writing-plans | /home/terry/.zcode/skills/writing-plans/SKILL.md |`
  - `| subagent-driven-development | /home/terry/.agents/skills/subagent-driven-development/SKILL.md |`
  - `| dispatching-parallel-agents | /home/terry/.agents/skills/dispatching-parallel-agents/SKILL.md |`
  - `| brainstorming | /home/terry/.zcode/skills/brainstorming/SKILL.md |`
  - （共 14 处 /home/terry/…，.zcode 与 .agents 双宿主混用）
- 分析: S75 命中——迁移性禁止硬编码 /home/ 路径。这些是 Rule 59.2/59.3 要求的"SKILL.md 绝对路径"伴飞注入，但硬编码到 /home/terry/（当前部署者 home）而非相对技能根或运行时探测路径；且 .zcode 与 .agents 双宿主混用（S75 第二面）。换部署者/换宿主即失效。
- 建议: 用运行时探测（`$ZCODE_HOME/skills/<name>` 或 `command -v` 式解析）替代硬编码 /home/terry/；或至少改为 `~/.zcode/`/`~/.agents/`（~ 展开）+ 宿主自适应。

### [P2] verification-gate 模板硬编码 /mnt/ 默认路径（env 可覆盖但默认值命中 S75）
- 标准: S75
- 位置: verification-gate/templates/verification.md:97, :101
- 证据:
  - `bash ${TASK_PLANNER_ROOT:-/mnt/data/dev/task-planner-skill/skills/task-planner}/scripts/check-delegation.sh stats <plan-dir>`
- 分析: 用 `${TASK_PLANNER_ROOT:-/mnt/…}` 形式，env 可覆盖（缓解 S75），但默认回退值硬编码 /mnt/data/dev/task-planner-skill（当前开发仓路径）。命中 S75（硬编码 /mnt/），虽属"模板示例 + env 兜底"较缓和形态，仍建议改相对/探测。
- 建议: 默认值改为相对技能根（如 `${TASK_PLANNER_ROOT:-$(cd …/task-planner && pwd)}` 式运行时探测）或纯 env（缺则报错提示设 TASK_PLANNER_ROOT），避免把 /mnt/ 写进模板。

### [P2] task-discipline SKILL.md 规则索引表与实际 42 条不同步（缺 85-90）+ 计数 41/42 不一致
- 标准: S40（描述/正文无矛盾）
- 位置: task-discipline/SKILL.md:15（"共 41 条"）、:70（"本索引现共 41 条全文可消费"）、:81（"42 条规则全文"）、:32-68（索引表 36 行）vs references/critical-rules-discipline.md（42 条，含 85-90）
- 证据:
  - 索引表（:32-68）列 4/6/7/8/9/10/18/27/28/29/31/32/33/35/36/41/42/43/44/45/48/53/54/55/56/57/60/65/67/69/70/71/72/73/74/76/92 = 36 条，无 85/86/87/88/89/90。
  - 域边界 :24 列表含 `…76,85,86,87,88,89,90,92`（42 条），:70 又说"Rule 85…与 Rule 89…已后补落盘——本索引现共 41 条"，:81 说"42 条规则全文"。
  - critical-rules-discipline.md 实际含 Rule 85(:503)/86(:515)/87(:527)/88(:541)/89(:553)/90(:565)/92(:577)。
- 分析: 索引表漏 85-90 六行；正文计数 41（:15/:70）与 42（:81）互不一致。读者按索引表消费会漏掉 85-90 五条 P0 规则（85 输入一致性/86 可测禁问/87 极简改动/88 任务射程/89 逻辑一致/90 首尾双提交）。
- 建议: 索引表补齐 85/86/87/88/89/90 六行；统一计数为 42（:15/:70/:81 对齐）。

### [P2] task-discipline 规则全文头部"暂不写"迁移注记已陈旧（与实际内容矛盾）
- 标准: S40（描述与正文矛盾，边缘）/ 文档质量
- 位置: task-discipline/references/critical-rules-discipline.md:5, :7
- 证据:
  - :5 `本批次（task-v171 S15-S17）落盘 19 条：Rule 4,6,…,45；剩余 17 条（Rule 27,48,…,76）属后续批次（S18+），本文件暂不写。`
  - :7 `源文件核心 critical-rules.md 原文本批次不删（删除见后续 Phase 删除基线执行）。`
- 分析: 文件当前实际含 42 条（27/48/…/76 及 85-90 全部已落盘，:5 注记所述"暂不写"已过期）；:7"源文件本批次不删"若源 task-planner/references/critical-rules.md 已删则同样过期。头部注记未随 S18+ 批次更新，会误导读者以为本文件只有 19 条。
- 建议: 更新 :5/:7 迁移注记，反映 42 条已全落盘及源文件删除基线实际状态（需先核对 task-planner/references/critical-rules.md 是否已删 27/48-76/85-90 段）。

### [P2] task-dispatch 与 task-discipline frontmatter 用 `tools:` 而非 `allowed-tools:`，且三卫星 frontmatter 风格不统一
- 标准: S40（tools/model/description 与正文无矛盾；命名一致性）
- 位置: task-dispatch/SKILL.md:4、task-discipline/SKILL.md:4、verification-gate/SKILL.md:4-5
- 证据:
  - task-dispatch:4 `tools: [Read, Write, Edit, Bash, Grep, Glob]`（无 model 字段）
  - task-discipline:4 `tools: [Read, Write, Edit, Bash, Grep, Glob]`（无 model 字段）
  - verification-gate:4-5 `model: haiku`（无 tools 字段）
- 分析: ① `tools:` 为自定义键，Claude Code 原生 skill frontmatter 用 `allowed-tools:`（前置发现 1 确认）；② 三卫星风格分裂——task-dispatch/task-discipline 声明 tools 不声明 model，verification-gate 声明 model:haiku 不声明 tools。verification-gate 需 Bash 执行 run-verification.sh 与 check-complete.sh，却未声明 tools 面（haiku 默认工具面未知）；task-dispatch 的 `tools` 含 Write/Edit 但其正文定位为"派发/校验"（只读为主），Write/Edit 与定位略宽（正文有脚本写 .provider-health.json / 变体 agent，故 Write 可解释，未验证为矛盾）。
- 建议: 统一三卫星 frontmatter 键名（确认本仓 skill 规范是 `allowed-tools:` 还是 `tools:`，以仓内其他已部署技能为准）；verification-gate 补 tools 面（至少 Bash）；task-dispatch/task-discipline 若需限 model 则补 model 字段。

### [P2] 三技能均无 S63 执行流程任务列表 / S2 I/O 契约 / S67 JSON Schema（纪律/指针型卫星，边界未验证）
- 标准: S63 / S2 / S67
- 位置: 三 SKILL.md 均无"执行步骤"markdown 任务列表章节；无 Input/Output/Example；无 JSON Schema + verify_io
- 证据:
  - task-dispatch/SKILL.md 结构 = 定位/域边界/卫星路由/规则索引/脚本/参考文档（无执行步骤列表）。
  - task-discipline/SKILL.md 结构 = 定位/域边界/卫星路由/规则索引/落盘状态/脚本/参考文档（无执行步骤列表）。
  - verification-gate/SKILL.md:32-60 有 Step 1/2/3（VC 设计/V-N 校验/VC 复验）三阶段 + 门控（:50 `V-N 未全 PASS → 禁止 Phase 翻 complete`、:59 `check-complete.sh exit 0 才可交付`），形态最接近 S63。
  - 无 JSON Schema：task-dispatch 的 22.4b 八字段契约由 scripts/check-subagent-return.sh:24-56 机器校验（等价 I/O Schema 但以 bash 校验器承载，非 JSON Schema 文件）。
- 分析: 三技能为"规则全文 + 机械脚本索引"型卫星（SKILL.md 明言"规则全文见 references/…md"），执行流程实际在宿主 task-planner 主技能承载。严格按 S63（缺≥2 phase 任务列表=P1）/S2（缺 I/O=提示）/S67（缺 JSON Schema=P1）判为不完全满足；但卫星定位可能豁免，未验证（需与 skill-fix 规范确认"指针型/规则集型技能"是否豁免 S63/S2/S67）。verification-gate 因含三阶段+门控，S63 基本满足。
- 建议: 若 skill-fix 不豁免卫星型：task-dispatch/task-discipline 各补一节 markdown 任务列表（如"消费条件→Read references/→过脚本门"≥2 phase + 门控）；三技能各补 Input/Output/Example 契约段；task-dispatch 的 8 字段返回契约可落一份 JSON Schema + verify_io 供 S67。

### [P2] S25 触发词正交性：返回校验/调研/验证语义有交叠，SKILL.md 未显式划界
- 标准: S25
- 位置: task-dispatch/SKILL.md:3（"返回校验"）vs verification-gate/SKILL.md:3（"子代理返回 done 需 Read 复核"）；task-discipline/SKILL.md:3（"调研"）vs task-dispatch 22.3.0 资料先行档（critical-rules-dispatch.md:54）
- 证据:
  - task-dispatch SKILL.md:3 `子代理派发/拆分/并行调度/粒度门/伴飞/返回校验/执行体选型`
  - verification-gate SKILL.md:3 `…子代理返回 done 需 Read 复核时触发`
  - 实际分工：task-dispatch 管返回**格式**契约（22.4b 8 字段 + check-subagent-return.sh），verification-gate 管返回**内容**复核（84.4 Read 实际文件）；但两 SKILL.md 的 description 都含"返回"字样，未显式声明"格式归 dispatch / 内容归 verification-gate"。
- 分析: 语义有交叠但实际分工可辨（格式 vs 内容）。"调研"一词同时出现在 task-discipline 描述（:3）与 task-dispatch 22.3.0 资料先行档——task-discipline 域边界（:15）已声明"调研"属其执行期纪律面，task-dispatch 22.3.0 是"失败换道时的资料检索动作序"，分工可辨但 description 未显式排除。未验证是否会误触发（需实跑 trigger 命中测试）。
- 建议: 在两 SKILL.md description 加一句边界声明（"子代理返回：格式契约归 task-dispatch，内容复核归 verification-gate"；"调研纪律归 task-discipline，失败换道资料检索归 task-dispatch 22.3.0"）。

### [P2] S56：verification-gate Step 1/2/3 是否构成"≥3 Phase"未验证（无 TaskCreate/Update/List/Get 声明）
- 标准: S56
- 位置: verification-gate/SKILL.md:32-60（Step 1/2/3）
- 证据: `### Step 1: VC 设计（计划期）` / `### Step 2: V-N 校验（执行期，Phase complete 前）` / `### Step 3: VC 复验（终验期，交付前）`
- 分析: 无 Agent() 调用（SKILL.md 无 Agent()）。Step 1/2/3 是"执行步骤"三阶段，是否等同 S56 的"≥3 Phase"未验证。若判为 ≥3 Phase 则缺 TaskCreate/TaskUpdate/TaskList/TaskGet 声明=违规；若 Step≠Phase（task_plan.md 的 Phase 概念）则不命中。task-dispatch/task-discipline 无 Agent()/无 Phase，S56 不命中。
- 建议: 明确 S56 对"步骤列表"与"Phase"的判界；若 Step 1/2/3 触发 S56，verification-gate frontmatter 补 TaskCreate/Update/List/Get（并确认工具实际可用）。

### [P2] S68：verification-gate 有执行期纠正但无 L1/L2/L3 分层自我纠正声明
- 标准: S68
- 位置: verification-gate/references/critical-rules-verification.md:31（84.4④"验证失败 → 不标记 complete，派 subagent 修复"）
- 证据: `④ 验证失败 — 不标记 complete，派 subagent 修复`
- 分析: 84.4④ 是单层纠正（失败→派修复→重验），未见 L1/L2/L3 分级自我纠正（如 L1 文本层重试/L2 拆细重派/L3 升级用户）。L1/L2/L3 具体定义未验证（skill-fix S68 的 L 层语义需与规范原文对齐）。
- 建议: 若 S68 要求显式 L1/L2/L3：84.4 补三层（L1 单 V-N 重跑 / L2 拆细或改派 / L3 升级用户 AskUser）；否则标注"未验证 L 层语义"。

### [通过/不适用] S74 运行时实证（bun 缺失影响）
- 标准: S74
- 证据: 三技能 scripts 全部为 bash（.sh），无 .ts/.js 文件；task-dispatch/scripts/ 6 个、task-discipline/scripts/ 2 个 + capabilities/agnes-quota.sh、verification-gate/scripts/ run-verification.sh，均为 `#!/usr/bin/env bash`。task-discipline/SKILL.md、verification-gate/SKILL.md 未声明 ts-node/bun 运行时。
- 分析: bun 未安装不影响三技能（零 TS 依赖）；脚本依赖 bash + grep/sed/awk/coreutils + jq（可选，缺失时 fail-open 并显式提示，符合宪法 §五 错误曝光，如 analyze-splits.sh:89 `提示: jq 缺失或 config.json 不可读…阈值回退默认`）。S74 对三技能不适用/通过。
- 前置发现 2（bun 未安装需确认是否含 .ts）——确认：三技能无 .ts，bun 缺失不影响。

### [通过] 前置发现 4 验证：verification-gate 引用的 check-3file-gate.sh / check-complete.sh 实际存在
- 标准: S64
- 证据: verification-gate/SKILL.md:50 `bash ../task-planner/scripts/check-3file-gate.sh <plan-dir>`、:59 `bash ../task-planner/scripts/check-complete.sh`；两脚本均存在于 task-planner/scripts/（已验证 EXISTS），且 SKILL.md 均带 `../task-planner/` 前缀（正确）。`check-x.sh` 仅出现在 SKILL.md:38 作 VC 命令示例（`如 bash scripts/check-x.sh <plan>`），属示例文字（S75 豁免），非正式引用。
- 结论: 前置发现 4 的"缺失"不成立——SKILL.md 侧引用正确且脚本存在；真正的引用错位在 references/critical-rules-verification.md:44（见 P1 发现 3）与 S64 跨 skill 前缀缺失（P1 发现 1/2）。

---

## 2. 全量交叉核对（机械引用清单，task-planner/scripts/ 侧）
已验证 EXISTS（35）: selftest-subagent-granularity-skill-escort.sh / selftest-subagent-return.sh / selftest-split-pattern-library.sh / selftest-agent-coverage.sh / selftest-error-loop.sh / selftest-veto.sh / selftest-skill-modify.sh / selftest-reliability-institution.sh / selftest-review-library.sh / selftest-ask-default-timeout.sh / selftest-root-resolution.sh / selftest-execution-honesty.sh / selftest-user-instruction-priority.sh / selftest-iteration-persistence.sh / periodic-review.sh / selftest-periodic-review.sh / zcode-posttooluse.sh / selftest-context-pressure.sh / selftest-decision-arbiter.sh / selftest-report-reviewability.sh / selftest-source-anchor-discipline.sh / selftest-decision-grading.sh / selftest-decision-drift.sh / selftest-absorption-discipline.sh / selftest-summary-readability.sh / selftest-input-consistency.sh / selftest-capability-persistence.sh / check-context-hygiene.sh / resolve-interaction-mode.sh / selftest-interaction.sh / check-dispatch.sh / check-complete.sh / check-3file-gate.sh / check-plan-dispatch.sh / check-delegation.sh
MISSING（1）: check-x.sh（仅 SKILL.md:38 示例，豁免）
另: task-planner/references/worktree-isolation.md EXISTS；task-planner/config.json EXISTS。
→ 结论: 所有被引用机械脚本实际存在，问题不在"缺失"而在"引用路径缺前缀"（S64 歧义，非 P0 缺失）。

## 3. 前置发现逐条验证结论
1. task-dispatch frontmatter `tools:` vs `allowed-tools:` — 确认（SKILL.md:4），并入 [P2] 发现 7。
2. bun 未安装 / 是否含 .ts — 三技能无 .ts，S74 不适用（[通过] 发现 11）。
3. task-discipline 6 文件/236K、references 是否完整 — 文件齐；但发现 [P2] 索引表漏 85-90（发现 5）+ 头部"暂不写"陈旧注记（发现 6）。
4. verification-gate 引用 check-3file-gate/check-complete/check-x 缺失 — 不成立：脚本存在且 SKILL.md 前缀正确；真问题在 references 侧 selftest-verification-gate.sh 位置矛盾（[P1] 发现 3）。

## 4. 汇总（按等级）
- P1 ×4: 跨 skill 引用缺前缀（task-dispatch / task-discipline 各 1 条，同模式）×2、verification-gate 规则全文脚本位置矛盾 ×1、split-pattern-library.md 硬编码 /home/terry/ ×1
- P2 ×7: verification-gate 模板 /mnt/ 硬编码、task-discipline 索引表漏 85-90+计数 41/42 不一致、头部"暂不写"陈旧注记、三卫星 frontmatter tools/allowed-tools 风格不统一、S63/S2/S67 缺（卫星型未验证豁免）、S25 触发词交叠未划界、S56 Step 是否=Phase 未验证、S68 L1/L2/L3 未声明
- 通过/不适用: S74（无 TS 依赖）、前置发现 4（脚本未缺失）
- 未验证标注: S63/S2/S67 是否豁免"指针型/规则集型卫星"、S56 Step≡Phase 判定、S68 L1/L2/L3 语义定义 —— 需与 skill-fix 规范原文对齐
