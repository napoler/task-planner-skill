# Explore 检查点 — task-nopause-execfirst-20261023

任务：为 Rule 95「非必要暂停禁令与执行优先纪律」落地 + 视频/图片执行体额度预询问条款修正 + 纪元锚级联 1-94→1-95，产出四节映射清单。
只读；本文件为唯一可写。

---

## ① 执行体措辞面（额度/停等/质检处置条款）

### 文件 A：/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/video-generation-executor.md（70 行）

条款位置表（行号 → 语义类别 → 逐字原文摘录）：

- L3 (frontmatter description) — 放行/停等/G1 语义：「…视频生成链 B 侧 SOP（放行核验→单镜试水→异步生成→QC 回执）…视频链含 G1 放行前置与异步轮询;…草稿 QC 与放行归 A 侧执行体/用户，隔离铁律」
- L16 — 询问/放行（G1 前置门）：「**G1 放行前置门**: 任何 video 调用前必须存在「草稿放行登记」（放行/跳过/否决三登记之一）——缺登记 = 产出按「未经门」作废；子代理无权代放行」
- L18 — 质检问题处置阶梯（谁决策）：「**QC 判据与处置阶梯**: 机检八类+亲检仲裁；缺陷四级处置（剪辑补救→段级重生成→整件重生成→全量须用户显式批准）；四维归因（提示词/模型随机/参考/规格）」
- L19 — 额度/成本 + 批量前警示（**待修正的预询问条款核心**）：「**成本纪律**: 视频调用昂贵——单镜试水先行（smoke-test 不裸调），配额警示后再批量；中文 prompt 先译英文」
- L24 — 放行核验（回执项）：「放行核验: <登记 grep 行 或 缺失原因>」
- L27 — 处置建议（只建议不裁决）：「处置建议: none | 四级之一（含归因维度；只建议不裁决）」
- L32 — Role：不裁决处置级别：「…不发起未经放行的生成、不做草稿侧 QC、不裁决处置级别（处置路由归主进程）」
- L35 — 放行核验（grep 实证）：「**放行核验（grep 实证）**：派发 prompt 必含前置放行登记 grep 行；本 agent 复验后才调 video」
- L36 — 异步/轮询/超时上报：「**异步生成与轮询**：video_id 轮询（超时分级上报）；取回 URL/落盘按任务要求」
- L37 — 质检处置建议（不裁决）：「**QC 回执**：机检+亲检结论、缺陷类别与归因维度、建议处置级别（不自行裁决）」
- L38 — Rule 54 消费（配额声称需第一手证据/阻塞矩阵）：「**Rule 54 消费（task-v136）**：…资源状态声称（配额/容量/可用性）附第一手查询证据，未验证只可登记「未验证」；遇阻塞按 54.2 影响矩阵逐镜头单元判定「阻塞/未阻塞」，未阻塞镜头立即执行、禁止被阻塞项连带整批推迟；推迟决策附 54.4 四要素举证；决策依据数据先落盘（findings.md 结论段/知识档案 §2，19.1 格式）后按 54.5 引用落盘锚，禁裸会话数据入决策」
- L41 — 前置检查 HARD_BLOCK（缺放行/参数即阻断）：「缺「放行登记 grep 行 / 镜头清单 / 生成参数（mode、seconds、size、aspect）」任一 → `HARD_BLOCK: <缺项>`，禁发起调用」
- L42 — key/端点核验 HARD_BLOCK：「key 环境变量与端点核验（api.agnes-ai.cn；apihub 域名=401 陷阱）缺失/错用 → HARD_BLOCK」
- L43 — **额度/配额查询复用（待修正预询问条款）**：「**额度/配额查询复用（Rule 55.1/55.5）**：任何「剩余额度/配额/计费」类查询必须先查 references/capability-registry.md 并复用首条脚本 agnes-quota.sh（bash scripts/capabilities/agnes-quota.sh，含 key 校准与缓存绕过）；**禁止**耗时累计/抽样等估算冒充额度值（Rule 55.2），计费层未填充时如实呈报脚本 verdict，HTTP 402=配额耗尽事后信号」
- L46 — Workflow 放行核验：「放行核验：核对 prompt 内放行登记 grep 行（无=HARD_BLOCK）」
- L48 — 单镜试水：「单镜试水：smoke-test → 首镜生成 → 取回」
- L49 — 首镜 QC FAIL 处置：「首镜 QC：机检+亲检；FAIL → 四维归因 → 建议处置级别上报」
- L50 — 试水 PASS → 批量：「试水 PASS → 参数冻结 → 批量镜头生成（逐镜落检查点，异步轮询）」
- L54 — 禁止无放行调用：「❌ 无放行登记发起 video 调用（作废级违规）」
- L55 — 禁止裸调/未译：「❌ 未 smoke-test 裸调 / 中文长 prompt 未译英文直接发」
- L56 — 禁止代放行：「❌ 同会话兼做草稿 QC 或代用户放行」
- L57 — 禁止自行裁决四级处置：「❌ 自行裁决四级处置（只建议不裁决）」
- L58 — 禁止超配额无警示扩散：「❌ 超配额无警示批量扩散」
- L59 — 禁止静默吞错：「❌ 静默吞错（异步失败必须记录 video_id 与错误原文）」
- L70 — 负结果报告（配额拒绝→HARD_BLOCK 上报）：「连续 2 镜同型 FAIL / 轮询超时 / 配额拒绝 → 停止批量，`HARD_BLOCK: <现象+已尝试>` 上报（Rule 22.3 处置）」

### 文件 B：/mnt/data/dev/task-planner-skill/skills/task-planner/companion/agents/image-generation-executor.md（69 行）

条款位置表：

- L3 (frontmatter description) — 三检门控/路由：「…图像任务 SOP 执行（核词→试水→三检闭环→扩批回填）…本 agent 携带图像工序 SOP 与三检门控…图像层止于成图三检，视频链走 video 执行体」
- L15 — agnes-ai-generation-skill 调用/key 读 env：「**agnes-ai-generation-skill**: 图像生成（t2i/i2i，agnes-image-2.5-flash）——调用入口 `python scripts/agnes_api.py image ...`（技能目录下），key 读 env `AGNES_API_KEY`/`APIHUB_AGNES_API_KEY`（禁打印）；输出默认返 URL 不下载，落盘按任务要求」
- L17 — 三检闭环（缺检不得验收/入台账）：「**三检闭环**: 合规 / 一致性…/ 质量…；缺检 = 不得验收/入台账/进下游」
- L18 — 试水门与预算（重抽上限=唯一合法 STOP）：「**试水门与预算**: 批次第 1 件过完整三检才扩批；单件重抽 ≤20 次（超限冻结=唯一合法 STOP 上报）」
- L19 — 材料包纪律（缺位如实登记）：「**材料包纪律**: 工序/门控按目标项目 variant 模板…执行；项目侧资产…存在则优先，缺位按本 agent 内置 SOP 执行并如实登记」
- L26 — 重抽计数（回执）：「重抽: N 次（预算 20）」
- L31 — Role：不替主进程做验收裁决：「…不做任务规划、不改提示词策略以外的范围、不替主进程做验收裁决」
- L34 — 单件试水与三检仲裁（FAIL 修词重抽）：「**单件试水与三检仲裁**：首件完整三检，FAIL 修词重抽（记录每次失败维度）」
- L35 — 批量扩展（逐件落检查点）：「**批量扩展**：参数冻结后同参批处理，逐件落检查点，异常件单独标记」
- L36 — 静默执行（批次内 0 打断）：「**静默执行**：批次内 0 打断（冻结/D6 除外）；只落检查点不回传叙事；批次末单份收尾报告」
- L37 — Rule 54 消费（配额声称需第一手证据/阻塞矩阵）：「**Rule 54 消费（task-v136）**：…资源状态声称附第一手查询证据（查询时间戳+来源通道）；遇阻塞按 54.2 影响矩阵逐项判定「阻塞/未阻塞」，未阻塞单元立即执行、禁止被阻塞项连带；推迟决策附 54.4 四要素举证；决策依据数据先落盘（findings.md 结论段/知识档案 §2，19.1 格式）后按 54.5 引用落盘锚，禁裸会话数据入决策」
- L40 — 前置检查 HARD_BLOCK（缺输入即阻断）：「输入缺「任务单元清单 + 提示词（或写词材料）+ 生成参数」任一项 → 输出 `HARD_BLOCK: <缺项>`，不写产物文件」
- L41 — key 环境变量确认（缺失 HARD_BLOCK）：「生成 API 调用前确认 key 环境变量在位（缺失 → HARD_BLOCK，禁裸调）」
- L42 — **额度/配额查询复用（待修正预询问条款，与视频 L43 逐字同款）**：「**额度/配额查询复用（Rule 55.1/55.5）**：任何「剩余额度/配额/计费」类查询必须先查 references/capability-registry.md 并复用首条脚本 agnes-quota.sh（bash scripts/capabilities/agnes-quota.sh，含 key 校准与缓存绕过）；**禁止**耗时累计/抽样等估算冒充额度值（Rule 55.2），计费层未填充时如实呈报脚本 verdict，HTTP 402=配额耗尽事后信号」
- L47 — 单件试水生成（smoke-test 先行）：「单件试水生成（`agnes_api.py image`，smoke-test 先行）」
- L48 — 三检 FAIL 处置（定位维度→修词重抽）：「三检逐项过；FAIL → 定位维度（提示词/模型随机/参考/规格）→ 修词重抽（≤预算）」
- L49 — 试水 PASS → 参数冻结 → 扩批：「试水 PASS → 参数冻结 → 批次扩展（逐件落检查点）」
- L54 — 禁止首件未过三检扩批：「❌ 首件未过三检即扩批」
- L56 — 禁止超预算静默重抽：「❌ 超预算静默重抽（20 抽上限=冻结上报）」
- L57 — 禁止静默吞错：「❌ 静默吞错（API 报错必须记录并上报）」
- L58 — 禁止代表用户验收：「❌ 代表用户验收（QC 结论只是证据，验收归主进程/用户）」
- L69 — 负结果报告（连续 FAIL/报错→停止扩批，等待主进程）：「连续 2 件同维度 FAIL 或 API 持续报错 → 停止扩批，输出 `HARD_BLOCK: <现象+已尝试>`，等待主进程改派/升级（Rule 22.3）」

小结（①）：两执行体的「额度/配额」条款集中在**视频 L19 + L43**、**图片 L18 + L42**；L43/L42 为逐字同款「额度/配额查询复用」段，是 Rule 95 需修正的「预询问/停等」相关面。质检处置均为「只建议不裁决 / 归主进程」；合法 STOP 仅限：视频（连续 2 镜同型 FAIL/轮询超时/配额拒绝）、图片（重抽 ≤20 超限冻结/连续 2 件同维度 FAIL）。

---

## ② 规则/索引锚面

### Rule 94 完整落地形态（critical-rules-discipline.md，共 615 行，Rule 94 为文件末条 605-615=EOF）
- L591 `### 93 规范再召回纪律（P0 — task-v195，目标：…；判定面=LLM 行为+…；衔接 Rule …，既有规则条目原文零改动）` → 93.0-93.5 子块
- **L605 标题行**（Rule 95 照此格式）：`### 94 任务专注性与计划隔离纪律（P0 — task-focus-plan-split-20261023，目标：<一句话根因+解法>；判定面=LLM 行为+本条款文本锚、零新 config 键、零新增守护脚本；衔接 Rule 8.1/8.1.1（…）/61/64（…）/88（…）/74（…），既有规则条目原文零改动）`
- L606 空行
- L607 `**建制（为什么有这条）**：用户 2026-10-23 /goal 指令（逐字锚 plans/task-focus-plan-split-20261023/user-session-log.md #1）：「…」根因=…。本条补位…`
- L608 空行
- L609 `**专注与隔离协议（P0）**：`（协议段标题）
- L610-615 六个子弹子条，格式 `- **94.1 <子条名>（总纲/判据/…）**：…`（加粗+冒号；94.1..94.6 逐条一行）
- **间隔**：规则块之间空行分隔；`### NN` 标题后紧跟空行再接正文。Rule 95 将紧随 L615 之后追加（L616+）。
- **纪元/来源注释形态**：不单列注释行，来源 task-id+日期直接内嵌标题行括号内（`— task-focus-plan-split-20261023，目标：…`）；逐字锚写进「建制」段（`plans/<task>/user-session-log.md #1`）。
- 子条编号：`**94.N` 加粗；与 Rule 93 的 `93.0 **…**：`（号不粗）略有差异 → Rule 95 照 Rule 94（最近形态）。

### 全仓 skills/ 纪元计数声明行（grep "1-94\|Rules 1-9\|77 条\|94 全集\|核心在位"）——因新增 Rule 95 需改（1-94→1-95 / 77 条→78 条）
| 位置 | 原文关键段 | 改法 |
|------|-----------|------|
| SKILL.md:9 | `Rules 1-94 全集索引（核心在位 1,2,3,5,19,20,26,51,62,66,80,81,82,83…；其余 77 条按域归 11 卫星…` | 1-94→1-95；77→78 |
| SKILL.md:17 | 卫星技能 task-discipline 行枚举 `…,90,92,93,94）` | 末尾追加 `,95` |
| SKILL.md:196 | 路由表 task-discipline 行枚举 `…,90,92,93,94）` | 末尾追加 `,95` |
| SKILL.md:209 | `Rules 1-94 全集索引：**核心在位 14 条**…其余 77 条已按域迁至…（含 Rule 84 验证域、Rule 85/86/87/88/89/90/92/93/94 纪律域）` | 1-94→1-95；77→78；纪律域列表补 95 |
| SKILL.md:251 | `Critical Rules 核心域 1-94 全集索引` | 1-94→1-95 |
| README.md:4 | `77 条非核心规则…核心在位 14 条` + 尾部注释 `卫星侧实体规则 dedup=76（+Rule 94 → 77）` | 77→78；注释补 +Rule 95 |
| README.md:36 | `Rules 1-94 全集索引：核心在位 14 条` | 1-94→1-95 |
| README.md:81 | `Rules 1-94 全集索引：**核心在位 14 条**…其余 77 条…` | 1-94→1-95；77→78 |
| README.md:123 | `核心域 14 条规则全文+Rules 1-94 全集索引` | 1-94→1-95 |
| README.md:127 | `[critical-rules-discipline 等 77 条非核心规则 → …]` | 77→78 |
| docs/ARCHITECTURE.md:4 | `77 条非核心规则…纪律域含 85/86/87/88/89/90/92/93/94，协同域含 91` + 注释 | 77→78；纪律域补 95 |
| docs/ARCHITECTURE.md:13 | `Rules 1-94 全集索引` | 1-94→1-95 |
| docs/ARCHITECTURE.md:42 | `Rules 1-94 全集索引：核心在位 14 条` | 1-94→1-95 |
| docs/ARCHITECTURE.md:113 | `Rules 1-94 全集索引（…更新）` | 1-94→1-95 |
| docs/ARCHITECTURE.md:114 | `核心在位 14 条…critical-rules.md（203 行…）` | 行数注随动 |
| docs/ARCHITECTURE.md:115 | `其余 77 条…纪律域含 85/86/87/88/89/90/92/93/94 为 v171 后追加 9 条` + 长注释 | 77→78；补 95；算式随动 |
| docs/ARCHITECTURE.md:135 | `核心域 14 条全文 + Rules 1-94 全集索引` | 1-94→1-95 |
| docs/ARCHITECTURE.md:137 | `[77 条非核心规则 → …]` | 77→78 |
| CLAUDE.md:33 | `← Rules 1-94 核心执行约束` + 历史注释链 | 1-94→1-95；注释追加 |
| README_zh.md:136 | `← Rules 1-94 核心执行约束` + 注释链 | 1-94→1-95 |
| README_zh.md:229 | `Rules 1-94 —— 自定义前必读` + 注释链 | 1-94→1-95 |
| references/critical-rules.md:175 | `曾把 77 条既有规则（1-76+80）…` | **历史叙述（ii），不改** |

（注：ARCHITECTURE.md:121-123 为纪元演进史注释链，追加一行 2026-10-23 Rule 95 演进即可，不改旧行。）

---

## ③ selftest 纪元锚行清单

### 任务指定三条 grep（scripts/ + skills/*/scripts/）
- A `grep -rn "1-94" scripts/ skills/*/scripts/` → **零命中**
- B `grep -rn "1-9[0-9]" scripts/ skills/*/scripts/` → 3 命中：
  - `selftest-workflow-orchestration.sh:77`（注释，承载 v183 演进史）→ **ii**
  - `selftest-session-log.sh:71`（`echo '1-90'` 负样本字面 + 尾边界正则，非纪元 pin）→ **ii**
  - `selftest-conclusion-discipline.sh:90`（注释，承载 v182 演进史）→ **ii**
- C `grep -rnE "\-eq 94|== 94|94 条" scripts/ skills/*/scripts/` → **零命中**

### 判定结论：i 类（新增 Rule 95 会致 FAIL 需级联）= **0 行 / 0 文件**
理由：全仓所有「live 纪元计数」selftest 均用**宽容锚**，已覆盖 `9[0-9]`（1-90..1-99），1-95 天然命中，不 FAIL。逐条已核（regex 对 1-95 命中）：
| 文件:行 | 实际断言 regex | 1-95 判定 |
|---------|---------------|-----------|
| selftest-error-loop.sh:75 | `Rules 1-(3[1-9]\|[4-7][0-9]\|8[0-9]\|9[0-9])` | 命中（9[0-9]） |
| selftest-veto.sh:63 | `Rules 1-(…\|9[0-9]([^0-9]\|$))` | 命中 |
| selftest-reflect-verify.sh:66 | `Rules 1-(3[5-9]\|[4-9][0-9])` | 命中 |
| selftest-self-resolution.sh:97 | `1-[89][0-9]` | 命中 |
| selftest-root-resolution.sh:126 | `Rules 1-[89][0-9] 全集索引：` | 命中 |
| selftest-tool-selection.sh:83 | `1-[89][0-9]` | 命中 |
| selftest-requirement-coverage.sh:144 | `1-[89][0-9]` | 命中 |
| selftest-lane-advancement.sh:131 | `1-[89][0-9]` | 命中 |
| selftest-reliability-institution.sh:98 | `1-[89][0-9]` | 命中 |
| selftest-session-log.sh:68 | `1-[89][0-9]([^0-9]\|$)` ≥3 | 命中 |
| selftest-conclusion-discipline.sh:80 | `1-(3[5-9]\|9[0-9])` | 命中 |
| selftest-skill-split.sh:90 | `Rules 1-(3[0-9]\|[4-9][0-9])` | 命中 |
| selftest-context-pressure.sh:109 | `1-[89][0-9]` | 命中 |
| selftest-source-anchor-discipline.sh:49 | `1-[89][0-9]` ≥2 | 命中 |
| selftest-drift-check-subagent.sh:93 | `1-[89][0-9]` | 命中 |

### 两个需特别标注（非指定 grep 命中，但同族，判定 ii）
- `selftest-workflow-orchestration.sh:80` WF-10：历史变体族 `1-(68|69|71|75|91)`，阈值 ≥3。当前命中数=4（源自 CLAUDE.md:33/README_zh.md:136,229/README.md:296 内历史注释 `1-91→1-92`）→ 与 live 纪元解耦，1-94→1-95 后历史注释仍在 → 仍 PASS → **ii**（不改；若将来清历史注释才需补 95 入族）。
- `selftest-batch-pilot.sh:69` BP-09：`隶属 Rules 1-(3[6-9]|[4-6][0-9]|7[0-7])` 校验 `skills/task-discipline/references/batch-quality-gate.md:138`（原文 `隶属 Rules 1-36`）。当前字面 1-36 命中；该锚**非 live 纪元**，1-94→1-95 不触及 → **ii**。⚠脆弱：若级联把该处写成 `1-78` 则 7[0-7] 不含 78 → 会 FAIL（建议级联时勿动该行）。
- `selftest-registry.tsv`：92 个 selftest 已全登记；Rule 95 属 L0-T（零新增守护脚本）→ **无 registry 变更**。

### 全量回归入口命令（存在全量 runner）
- 入口脚本：`skills/task-planner/scripts/run-selftests.sh`（README.md:133/251）
- 命令：`bash skills/task-planner/scripts/run-selftests.sh --fresh`
- 期望：末行 `Total: N PASS=x FAIL=y` 且 FAIL=0（--fresh 无视缓存全量重跑）
- 另：卫星 selftest 随各卫星落盘（如 `skills/task-dispatch/scripts/selftest-*.sh`），按同口径跑批（README.md:254）

---

## ④ 部署位映射

### 候选部署任务目录
- `plans/task-v192-deploy-zcode`（zcode 单点）
- `plans/task-kb-deploy-20261022`（kb 部署）
- `plans/archive/task-deploy-rule94-20261023`（**最近同类：Rule 94 部署位同步，本次照搬**）
- 其他 archive：task-deploy-all-symlink / task-deploy-master-20260905 / task-deploy-9b167fe / task-symlink-skill-deploy / task-v165-agent-template-deploy / task-v053-skillfix-deploy

### 源→目标对应关系（取自 task-deploy-rule94-20261023/task_plan.md L24/79-81）
- **源（dev 仓 master）**：`skills/task-planner/{SKILL.md, references/critical-rules.md, README.md, docs/ARCHITECTURE.md}` + `skills/task-discipline/{SKILL.md, references/critical-rules-discipline.md, references/execution-recall-card.md}` = 7 文件
- **zcode 目标**：`~/.zcode/skills/task-planner/` 与 `~/.zcode/skills/task-discipline/`（对应 7 文件，cp 覆盖）
- **cursor 目标**：`~/.cursor/skills/task-planner/` 与 `~/.cursor/skills/task-discipline/`（对应 7 文件，cp 覆盖）
- **未部署位**：`~/.agents/skills`（无 task-planner/task-discipline，不创建）
- 机制：文件级 cp（非目录级），保部署位运行态（.drift-rhythm/install.log）与本地独有文件

### 平台部署位注册表（lib/detect-tools.sh:18-24，TOOL_PROBES）
| 工具 | 部署位路径 | hook style |
|------|-----------|-----------|
| claude-code | `$HOME/.claude/skills/task-planner` | claude-settings |
| zcode | `$HOME/.zcode/skills/task-planner` | zcode-frontmatter |
| opencode | `$HOME/.config/opencode/skills/task-planner` | opencode-frontmatter |
| cursor | `$HOME/.cursor/skills/task-planner` | cursor-frontmatter |
| continue | `$HOME/.continue/skills/task-planner` | continue-frontmatter |

### smart-merge-back.sh --deploy 目标位确定机制（无登记表，env 变量 + 内置默认）
- L370 `DEPLOY_SRC="$MAIN_REPO/skills/task-planner"`（部署源=主仓 canonical；源缺失 fail-closed DRIFT exit 6）
- L385 `if [ -n "${TASK_PLANNER_DEPLOY_SLOTS:-}" ]; then` → L386 `SLOTS="$TASK_PLANNER_DEPLOY_SLOTS"`（env 覆盖）
- L388 默认（无 env 时）`SLOTS="$HOME/.zcode/skills/task-planner:$HOME/.claude/skills/task-planner:$HOME/.config/opencode/skills/task-planner"`（3 默认位：zcode/claude-code/opencode，**默认不含 cursor**；cursor 需经 TASK_PLANNER_DEPLOY_SLOTS 显式指定）
- L15 机制：`--deploy` 合并后对部署位执行 F5 staging 原子化部署（task-v159 替代旧直写路径）；逐位对账 REJECTED|IDENTICAL|DRIFT

---

## 总结
- ① 两执行体额度/停等条款：video L19（成本纪律·配额警示后再批量）+ L43（额度/配额查询复用）；image L18（试水门与预算·重抽≤20）+ L42（额度/配额查询复用，与 video L43 逐字同款）。质检处置两体均「只建议不裁决/归主进程」。
- ② Rule 94 尾部形态：标题行 `### NN <名>（P0 — <task-id>，目标：…；判定面=LLM 行为+本条款文本锚、零新 config 键、零新增守护脚本；衔接 Rule …，既有规则条目原文零改动）` + 空行 + 建制段 + 空行 + `**<协议名>（P0）**：` + 加粗子弹子条 `- **NN.1…**：`；Rule 94 为文件末条（605-615），Rule 95 从 616 追加。需级联的文档声明：SKILL.md 5 处（9/17/196/209/251）、README.md 5 处、ARCHITECTURE.md 9 处、CLAUDE.md 1 处、README_zh.md 2 处（1-94→1-95 且 77 条→78 条，纪律域列表补 95）。
- ③ selftest 级联：i 类 = 0 行 / 0 文件（全部 live 纪元 selftest 用覆盖 9[0-9] 的宽容锚）；指定三 grep 命中 3 行全 ii；WF-10 与 BP-09 同族均 ii（WF-10 靠历史注释解耦；BP-09 锚非 live 纪元，勿写 1-78）。回归入口=`bash skills/task-planner/scripts/run-selftests.sh --fresh`（期望 FAIL=0）。
- ④ 部署位：源=skills/{task-planner,task-discipline}（7 文件）→ zcode `~/.zcode/skills/*` + cursor `~/.cursor/skills/*`（本次同 Rule 94 范围，2 位）；smart-merge --deploy 默认 3 位（zcode/claude-code/opencode，不含 cursor），env `TASK_PLANNER_DEPLOY_SLOTS` 可覆盖。
