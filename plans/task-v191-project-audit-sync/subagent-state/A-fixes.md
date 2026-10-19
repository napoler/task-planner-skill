# A-fixes 文档同步修正检查点（task-v191）

依据：A-root-docs.md 审计发现 + 权威口径（Rules 1-92 / 核心 14 / 73 条→11 卫星 / SKILL.md 237 行 / critical-rules 193 行 / scripts 146=137 .sh 含 92 selftest / refs 6 / templates 13/42 / agent 8 / config props 53）。全部实测于 worktree 内 Read/grep/wc/find 复核。

## 逐文件改动（改前 → 改后）

### 1. README_zh.md（3 处）
- :136 `Rules 1-91 核心执行约束` → `Rules 1-92`，行末纪元注释链补 `<!-- 2026-10-19 task-v191 对齐 1-91→1-92（Rule 92 落地，核心 14 条，task-v190 后实态） -->`
- :229 同：`Rules 1-91 —— 自定义前必读` → `Rules 1-92`，纪元注释链补同款 task-v191 注释
- :114 `7 个伴生 agent（…/ drift-checker）` → `8 个伴生 agent（…/ drift-checker / decision-arbiter）`+追加 `<!-- 2026-10-19 task-v191 对齐实态（+decision-arbiter，共 8 个） -->`（实测 `ls companion/agents/`=8，含 decision-arbiter.md）
- 11 卫星分解：README_zh.md 正文无卫星分解表述（仅 :139 billing 迁出注记），无需改；已 grep 确认

### 2. CLAUDE.md（2 处）
- :33 `Rules 1-91` → `Rules 1-92`，纪元注释链补 `<!-- 2026-10-19 task-v191 对齐 1-91→1-92（Rule 92 落地，核心 14 条，task-v190 后实态） -->`
- :36 `[billing.md → ../plan-cost-guard/references/billing.md]` → `[billing.md → skills/plan-cost-guard/references/billing.md]`+行末注记「2026-10-19 task-v191 修正：仓根相对路径应为 skills/ 前缀，原 ../ 在仓根不解析」（`test -f skills/plan-cost-guard/references/billing.md` = RESOLVES）

### 3. skills/task-planner/docs/ARCHITECTURE.md（最陈旧，15 处）
- :4 家族分层注记：`76 条…（3 新域 + 7 收编）` → `73 条非核心…（3 新域 + 7 收编 + 1 验证域 verification-gate，Rule 84 task-v173 新增；纪律域含 85-90/92，协同域含 91）；核心在位 14 条（列表补 81/83）`+task-v191 对齐注释
- :13 `SKILL.md（214 行…Rules 1-84 全集索引）` → `237 行…Rules 1-92`+对齐注释
- :16 `scripts/（119 条目 = 110 .sh 含 76 selftest）` → `146 条目 = 137 .sh 含 92 selftest`
- :29 `核心在位 12 条规则` → `14 条（1,2,3,5,19,20,26,51,62,66,80,81,82,83）`
- :37 `10 技能分层图…共 11 个节点（核心 1 + 卫星 10）` → `11 技能分层图…+ 1 验证域卫星 verification-gate…共 12 个节点（核心 1 + 卫星 11）`+对齐注释（第 11 颗入分解）
- :42-43 图内 `Rules 1-80 全集索引：核心在位 12 条（…80,82）` → `Rules 1-92：核心在位 14 条（…80,81,82,83）`
- 路径补一级（docs/ 层 `../<sat>` → `../../<sat>`）：:74-76、:84-90、:100-109 表格 24 处（`test -f docs/../../task-dispatch/...` = RESOLVES）；:197 §7.3、:264 §10、:288 §11.4 脚本/故障模式内 `../` 示例保持 skill 根口径并加澄清注记（避免误改为 `../../` 后语义错误）
- §4 :113-115 `Rules 1-80 / 核心 12 条（…82）/ 其余 70 条 / 165 行` → `Rules 1-92 / 核心 14 条（补 81,83）/ 其余 73 条 / 193 行`
- :121 纪元史补新行：`2026-10-14~18 task-v183/v187/v190：Rule 81/83 入核心（12→14）+ 第 11 颗 verification-gate（Rule 84）+ 85-90/92 + 91 → Rules 1-92`；:120 的 2026-10-12 task-v171 行保留为历史记录（未动）
- :128 `SKILL.md（214 行）` → `237 行`；:132 `核心域 12 条 + Rules 1-80 全集索引` → `14 条 + Rules 1-92`；:134 `70 条非核心` → `73 条非核心`
- :139 `scripts/ 119 条目（110 .sh 含 76 selftest，2026-10-12 实测）` → `146 条目（137 .sh 含 92 selftest，2026-10-19 task-v191 对齐）`；:149 `selftest-*.sh ×76` → `×92`
- :252 `76 个 selftest-*.sh 全量重跑` → `92 个`
- :303 §12 tradeoff `分层后核心 214 行` → `核心 237 行（task-v171 时点 214 行快照…实测 237，2026-10-19 对齐）`

### 4. INSTALL_zh.md（5 处）
- :290 `config.json 42 键` → `53 键 properties`+task-v191 注释（python3 实测 properties=53）
- :293 `scripts/ 106 项: .sh 96 含 62 selftest` → `146 项: .sh 137 含 92`，保留 task-v149 注释并追加 task-v191
- :295 `templates 39 个（顶层 10 个 md + variant 29）` → `42 个（顶层 13 个 md，补 user-session-log/session-handoff/deprecated）+ variant 29`
- :302-305 `references/ 10 个` → `6 个: critical-rules/completion-gate/goal-gate/methodology/todo-sync/worktree-isolation`+迁出注记（4 篇迁 task-dispatch/task-discipline 卫星，test -f 证实 MISSING）
- :306 `7 个配套 agent` → `8 个（+decision-arbiter）`；:313 实测注记整行刷新 `39/顶层10/106 含62/10 refs/7 agent` → `42/顶层13/146 含92/6 refs/8 agent`（2026-10-19 task-v191 实测）

### 5. skills/task-planner/README.md（9 处）
- :4 `SKILL.md 214 行 / 76 条既有规则（3 新域 + 7 收编）` → `237 行 / 73 条非核心（3 新域 + 7 收编 + 1 验证域 verification-gate）；核心在位 14 条`+task-v191 对齐注释
- :89 `SKILL.md (214 行)` → `237 行`
- :94 `scripts/ 119 条目 = 110 .sh 含 76 selftest` → `146 条目 = 137 .sh 含 92`
- :81 `critical-rules.md（190 行，2026-10-14 实测）；其余 71 条` → `193 行，2026-10-19 task-v191 实测；其余 73 条`
- :119 `SKILL.md（214 行…）` → `237 行`
- :127 `critical-rules-discipline 等 70 条规则` → `73 条非核心规则`
- :132 `scripts/ 119 条目（110 .sh 含 76 个 selftest）` → `146 条目（137 .sh 含 92 个，2026-10-19 task-v191 对齐实态）`；:146 `selftest-*.sh ×76` → `×92`
- :158 `companion/ 伴生 agents（drift-checker 等）` → `8 个伴生 agent（drift-checker / decision-arbiter 等；2026-10-19 对齐实态 7→8）`
- 保留未动（历史记录）：:287-288 v2.1 版本史「558→214 行 / 76 条→10 卫星」为 2026-10-12 当时事实，属版本日志不刷（与 ARCHITECTURE 纪元史 :120 同类）

### 6. progress.md（仓根，整文件改写）
- 原 32 行 = task-v086/v087/v139 交付簿记片段 + 竞写事故日志，均属历史孤儿（git log 证实 task-v087/v091 簿记已入库：cb16507/dff8c09；plans/ 下对应任务在 plans/archive/）。判定可删 → 改写为仓根进度账本占位：保留一句「本文件为仓级进度占位，任务级进度见各 plans/task-*/progress.md」+ task-v191 归档说明（指明原内容去向 = git 历史与 plans/archive/），未删除信息、可追溯

## 自检证据（改后 grep 实测）
- 6 文件 `task-v191` 计数：README_zh=3 / CLAUDE=2 / INSTALL=5 / README=4 / ARCHITECTURE=11 / progress=1（全在位）
- 旧值残留扫描（1-91、214 行、165 行、119/106、×76、7 个、42 键、10 个 refs、其余 70/71 条）→ 0 残留；仅 2 处有意保留的历史记录（ARCHITECTURE:120 纪元史 2026-10-12 行、README:288 版本史 v2.1 行）
- `test -f skills/plan-cost-guard/references/billing.md` = RESOLVES；`test -f skills/task-planner/docs/../../task-dispatch/...` = RESOLVES
- config properties=53 / templates 顶层 13+variant 29=42 / companion 8（ls 实测）

## 风险/未决
- ARCHITECTURE.md 表格内 `../../` 前缀是按「文档相对位置」解析的；§7.3 已加注记澄清 caller（脚本内）仍用 skill 根 `../` 口径，两套并存不混淆
- INSTALL_zh.md :293 保留 task-v149 旧注释+追加 task-v191（按指令「保留行内注释并追加」），未删旧快照值的历史痕迹
