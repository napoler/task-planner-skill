# Rule 64 条款草案与接线规格（task-v148 Phase 2 产物 — S-unit 供料唯一锚文件）

> 供料日期 2026-10-08 | 来源：01-explore 调研（findings.md 同名小节）+ 用户 2026-10-08 裁决
> 纪律：全部纯增量（Rule 36.5）——零删除、零改写既有行；S-unit 落地前先跑 selftest-drift-check-subagent.sh 取 DCS 基线，落地后复跑全绿

## 0. 落点与格式约定（S1）

- 目标文件：`skills/task-planner/references/critical-rules.md` **文件尾部追加**（合并序注范式 = 现行尾部 59 块先例「按合并时间序列文件尾」；63=v147 在途未落地，落地后编号序回填但不改本条内容）
- 块头格式对齐 59 块：`### 64 偏移检查留痕强制与节奏化触发纪律（P0, 2026-10-08 task-v148，目标：…）`
- 块前注释：`<!-- Rule 64 (task-v148 2026-10-08): 纯增量新增；判例=task-v141~v145 共 25 Phase drift-check 执行率 0%（软触发不可靠实证）；用户 2026-10-08 裁决「防偏移容易失效，需要时刻记得纠正」 -->`
- CHANGELOG.md 追加条目（见 §7 文案）

## 1. Rule 64 条款全文（S1 逐字落地）

### 64 偏移检查留痕强制与节奏化触发纪律（P0, 2026-10-08 task-v148，目标：drift-check 从「软触发靠自觉」升级为「留痕可查+门控强制+节奏提醒」三层机械闭环，根除「条款在位执行率 0%」缺陷；判定面=LLM 行为+check-3file-gate 第三条件+posttooluse 注入+selftest 静态与行为双断言、零新 config 键；衔接 Rule 11/15/19.2/61，既有条款原文零改动）

本条源于用户 2026-10-08 反馈原话（逐字抄录于 plans/task-v148-drift-enforce/task_plan.md「🎯 用户需求原文」，51.1 口径）：「对防偏移进行加强」；「在当前我发现执行任务的时候，真的是防偏移这个东西非常容易（口语截断，语境=容易失效/被忽略）」；「需要进行时刻记得纠正」。归因（实证）：task-v141~v145 共 25 Phase drift-check 执行率 0%（drift-checker 检查点 0 个、[DRIFT CHECK] 记录 0 处）；机制面 18 项中 16 项软性——触发靠模型记得、判定结果无机器消费通道、selftest 只守措辞不守执行行为。载体（Rule 61）与触发时机（15.1）在位但无执行证据链 = 条款死文。

64.1 **留痕三件套强制（execution evidence chain）**：每次合规 drift-checker 派发返回后（无论 verdict=ALIGNED/DRIFT/BLOCKED），主进程 30s 内完成三痕迹：① 检查点 `<plan-dir>/subagent-state/{seq}-drift-checker.md`（61.2 契约既有）② 工作账本事件 `bash <skill>/scripts/ledger-append.sh <plan-dir> drift_check "<verdict>+一句话结论" --phase N`（64.5 枚举增补）③ task_plan.md「🚨 Drift Log」表追加一行（时间/结果/涉及VC/结论）。三痕迹缺任一 = 本次偏移检查视为未执行（64.2 门控按未执行处理；豁免/降档使用须 progress.md 记一行理由，44.3 五要素精神）。What=执行必留机器可查证据；Why=0% 执行率直接成因是无痕迹要求——「做没做过」无任何下游可核查，软条款退化为死文；三痕迹全部复用既有载体（检查点/ledger/Drift Log 表）零新增面。

64.2 **Phase complete 第三条件门控（machine gate）**：`check-3file-gate.sh` 在 19.2 既有双条件与 60.5 kb 条件之后追加第 6 条件——标记 complete 的 Phase 时间窗（progress.md 该 Phase `Started:` 时间戳锚；锚缺失退化既有 stale 阈值锚）内必须存在 ≥1 条 drift_check 痕迹（ledger `event="drift_check"` 行优先，`<plan-dir>/subagent-state/*-drift-checker.md` 检查点 mtime 兜底）；缺失 → 默认 exit 1 禁止翻转 complete。豁免（满足其一）：(a) task_plan.md 声明行 `drift_exempt: <Phase 清单>`（纯簿记/纯调研/纯交接 Phase 逐个列出）；(b) `plan_tier: mini` 任务整体豁免（38.3 同口径）；(c) env `TASK_PLANNER_DRIFT_ENFORCE=warn`（stderr 提示不阻断）`|off`（跳过）——降档/豁免使用须 progress.md 记一行。What=没留痕就不许翻 complete；Why=「时刻纠正」的收口兜底——即使 64.3 提醒被忽略，Phase 收口处机器强制必查（19.2 同族先例：3-File 门从软要求升硬门后执行率归一）；默认 enforce 对齐 51 R-COVERAGE/59.1 硬门先例，三档豁免保轻任务零增负。

64.3 **节奏化提醒（rhythm nudge——「时刻」载体）**：`zcode-posttooluse.sh` 在存在有效活跃计划（会话 side 指针解析出 plan-dir）时维护会话级计数状态 `<plans>/.drift-rhythm/<sidkey>.state`（两键 `{count, last_inject}`，fail-open：目录不可写/解析失败即静默跳过），每满 N=10 次工具调用（env `TASK_PLANNER_DRIFT_RHYTHM_N` 可覆盖）经既有 additionalContext 通道注入单行提醒 `[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套` 并重置计数（last_inject=count）。注入=软提醒不拦截（PostToolUse additionalContext 无拦截力是平台事实），拦截力由 64.2 承载——两层分工：64.3 管「时刻」（高频可见性），64.2 管「必查」（收口强制）。性能约束：状态文件两键读写 O(1)+指针解析复用既有函数，禁止全仓扫描或大文件解析。

64.4 **判定输入契约（anti-vacuous-ALIGNED）**：drift-checker 任务书（61.2 派发契约之上）必须内嵌三锚输入：① Goal 原文锚（task_plan.md Goal 段绝对路径+行锚，或 ≤3 行原文摘录）② 最近动作清单锚（progress.md 尾部 N 行路径锚）③ scope 文件集锚（执行范围表路径）；agent 侧判定必须逐锚引用证据写检查点（对照结论可复核），无证据锚的 ALIGNED 判定无效 = 按 64.1 未执行处理。配套：drift-checker agent 定义增补判定输入要求段（纯增量 ≤3 行，部署位随 Phase 5 同步）。What=判定必须可复核；Why=历史偏移案例（task-v075/v095/v096）多发生在「未对照 Goal 的自由执行」，无输入锚的检查=形式过场，三锚使 haiku 档判定有据可依、防幻觉式 ALIGNED。

64.5 **机制守护（mechanism guard）**：机器面五接线——`ledger-append.sh` VALID_EVENTS 增 `drift_check` 枚举（:28 尾部追加，既有枚举零改动）；`check-3file-gate.sh` 追加第 6 条件段（既有条件 1-5 语义零改动）；`zcode-posttooluse.sh` 追加计数段（复用既有 additionalContext 注入 helper）；`companion/agents/drift-checker.md` 判定输入段；SKILL.md 接线 2 处（Phase 循环第 6 步 [DRIFT CHECK] 块内追加 64.1 留痕行 + 合规清单 C4 行末追加留痕句——DCS-01~20 字面锚零触碰）。守护面=`scripts/selftest-drift-enforcement.sh`（静态断言 DCE-01~10 + 行为级 fixture DCE-11~16，fixture 范式对照 selftest-four-file-dataflow.sh）+ selftest-registry.tsv 登记。What=每处接线挂既有管线+静态与行为双断言；Why=53.2 根治判据=机制·守卫·载体三件齐，条款无挂点=死文（59.6 同范式）；行为 fixture 防「守措辞不守行为」错位复发（根因③）。

64.6 **零新 config 键与既有 Rules 关系**：不新增任何 config.json 键——降档与调参走 env（`TASK_PLANNER_DRIFT_ENFORCE` / `TASK_PLANNER_DRIFT_RHYTHM_N`），豁免走计划声明行 `drift_exempt`（59.7/43.4/44.4 同范式：键膨胀=配置面失控面）。关系：Rule 11/15 触发时机与三态判定原文零改动（本条只加证据链与节奏）；Rule 61 载体契约零改动（64.4 只加输入要求）；Rule 19.2 门控=第三条件追加非改写；Rule 62 四文件流转正交；SKILL.md 上界计数措辞（「1-62」等）本次不动（63 未落地避免计数失真，v146 同款遗留延续）。

## 2. S2 接线规格（ledger-append.sh + check-3file-gate.sh）

### 2.1 ledger-append.sh
- `:28` `VALID_EVENTS="progress phase_complete error gate_block attest note kb_distill"` → 值尾追加 ` drift_check`（既有枚举零改动）
- `:20` 附近 docblock 追加一行：`#   事件枚举增补 drift_check（2026-10-08 task-v148/Rule 64.1：偏移检查留痕事件，summary 格式建议 "<verdict>+一句话结论"，既有枚举零改动）。`

### 2.2 check-3file-gate.sh（在既有条件 5 [--require-kb] 之后追加条件 6）
- 判定序：ledger-*.jsonl 含锚点后 `event="drift_check"` 行 → PASS；否则 `<plan-dir>/subagent-state/*-drift-checker.md` mtime 晚于锚点 → PASS；否则 task_plan.md 含 `drift_exempt:` 声明且当前 Phase 号命中豁免清单 → PASS（stdout 提示豁免放行）；否则：
  - `TASK_PLANNER_DRIFT_ENFORCE=off` → 跳过本条件（stdout 提示一行）
  - `=warn` → stderr 提示 Rule 64.2 缺痕迹、**不改变退出码**（由既有条件 1-5 决定）
  - 默认（enforce）→ exit 1，stderr：`[drift-gate] Rule 64.2: 本 Phase 窗口内无 drift_check 痕迹——派发 drift-checker（Rule 61 载体）并按 64.1 留痕三件套，或在 task_plan.md 登记 drift_exempt`
- 锚点：复用既有「当前 in_progress Phase 段 `Started:` 时间戳」解析；Started 缺失/不可解析时退化既有 stale 阈值锚（窗内查找痕迹）
- 无活动 Phase（既有情形 2 exit 0）→ 条件 6 不触发，语义不变
- docblock「判定逻辑」清单同步追加第 6 条描述行（注释纯增量）

## 3. S3 接线规格（zcode-posttooluse.sh [drift-rhythm]）

- 复用既有注入 helper（`:155` additionalContext JSON 包装）与既有 plan-dir/sid 解析逻辑（文件内已有的就复用；没有则调 resolve-plan-dir.sh）
- 状态文件：`<plans>/.drift-rhythm/<sidkey>.state`，两键 `count` / `last_inject`（纯文本两行，容错解析）
- 逻辑（全部 fail-open）：
  1. 解析出有效 plan-dir 且目录可写 → count++ 并写回；否则静默跳过
  2. `count - last_inject ≥ N`（N=10，env `TASK_PLANNER_DRIFT_RHYTHM_N` 覆盖）→ 输出 `{"additionalContext": "[drift-rhythm] 距上次偏移检查已 ≥N 次工具调用：活跃执行期按 Rule 15 派发 drift-checker（Rule 61 载体）并按 Rule 64.1 留痕三件套"}` 并 `last_inject=count`
  3. 无 jq → 走脚本既有容错路径静默跳过
- 性能：O(1) 状态读写；禁止全仓扫描；状态目录初始化 `mkdir -p` 幂等
- 注意：本脚本为**运行中基础设施**——改动必须在 worktree 完成、合并部署后生效；部署前主仓行为不变（隔离意义所在）

## 4. S4 接线规格（SKILL.md + companion/agents/drift-checker.md）

### 4.1 SKILL.md（2 处纯追加，禁改任何既有行——DCS-01~20 字面锚保护）
- 「Phase 执行循环」第 6 步 [DRIFT CHECK] 块内、`**DRIFT CHECK 触发时机（强制）**` 行之前追加一行：
  `- 64.1 留痕三件套（Rule 64）：返回 30s 内 ① 检查点（61.2 既有）② \`ledger-append.sh <plan-dir> drift_check "<verdict>+一句话" --phase N\` ③ task_plan.md Drift Log 表一行——缺任一=未执行，64.2 门控按未执行拦截`
- 合规清单 C4 行**末尾**追加：`；留痕三件套已落实（Rule 64.1，缺一=未执行）`
- 前置动作：先跑 `bash skills/task-planner/scripts/selftest-drift-check-subagent.sh` 记 DCS 基线（应 20/20），追加后复跑必须全绿

### 4.2 companion/agents/drift-checker.md（仓内副本，纯增量 ≤3 行）
- 判定纪律段之后追加：判定输入三锚（Goal 锚/progress 尾部动作清单锚/scope 文件集锚）必须逐锚对照并写入检查点；无证据锚的 ALIGNED 判定无效（Rule 64.4）
- 部署位 `~/.zcode/agents/drift-checker.md` 不在本 S-unit 触碰（Phase 5 部署同步）

## 5. S5 断言清单（新建 scripts/selftest-drift-enforcement.sh）

静态断言（对仓内文件 grep）：
- DCE-01 critical-rules.md 含块头 `### 64 偏移检查留痕强制与节奏化触发纪律`
- DCE-02 64.1~64.6 六子条锚各 ≥1 命中
- DCE-03 ledger-append.sh VALID_EVENTS 含 `drift_check`
- DCE-04 check-3file-gate.sh 含 `Rule 64.2`（或 drift_check）条件段
- DCE-05 zcode-posttooluse.sh 含 `drift-rhythm`
- DCE-06 SKILL.md 含 `64.1 留痕三件套`
- DCE-07 SKILL.md C4 行含 `留痕三件套已落实`
- DCE-08 companion/agents/drift-checker.md 含判定输入锚（`64.4` 或 `判定输入`）
- DCE-09 负断言：config.json **不含** `drift_enforce`（零新键）
- DCE-10 CHANGELOG.md 含 `Rule 64`

行为级 fixture（mktemp 临时目录，范式对照 selftest-four-file-dataflow.sh；结束后清理）：
- DCE-11 gate fixture：合法 plan（满足既有条件 1-5）+ 无 drift 痕迹 → exit 1
- DCE-12 同 fixture + subagent-state/01-drift-checker.md（mtime 晚于 Started）→ exit 0
- DCE-13 同 fixture + task_plan.md 含 `drift_exempt: 2` → exit 0
- DCE-14 同 fixture + `TASK_PLANNER_DRIFT_ENFORCE=warn` → exit 0
- DCE-15 ledger-append.sh `<tmp> drift_check "ALIGNED 测试" --phase 1` 写入成功且行内 event 可 grep
- DCE-16 posttooluse 干跑：构造 state（count=10,last_inject=0）+ 临时 side 指针 → stdout JSON 含 `drift-rhythm`

收尾：selftest-registry.tsv 追加登记行（59.6 范式）。

## 6. S6 回归清单（code-runner-agent）
1. master 基线先行：主仓跑全量 `scripts/selftest-*.sh` 记 FAIL 集（master 基线可能非零——历史 memory 记录 15 FAIL 需对照分类；只认「零新增 FAIL」）
2. worktree 内跑全量 selftest → FAIL 清单 ⊆ master 基线 FAIL 集
3. 锚级联扫描：`grep -rn '1-62\|40-6[0-9]\|drift-checker 子代理偏移检查' skills/task-planner/scripts/ skills/task-planner/references/ | grep -v selftest-drift-enforcement` 比对改动面无意外破坏
4. 任何新增 FAIL → 回炉对应 S-unit 修复后复跑（57.2 逐轮落盘 progress.md）

## 7. CHANGELOG 条目文案（S1 随条款落地）

```
- 2026-10-08 task-v148: Rule 64 偏移检查留痕强制与节奏化触发纪律——64.1 留痕三件套（检查点+ledger drift_check+Drift Log）/64.2 Phase complete 第三条件硬门控（drift_exempt 豁免+env 降档）/64.3 posttooluse [drift-rhythm] 节奏提醒/64.4 判定输入三锚契约/64.5-64.6 机制守护与零新键；判例=25 Phase 执行率 0% 实证，载体 Rule 61 语义零改动
```
