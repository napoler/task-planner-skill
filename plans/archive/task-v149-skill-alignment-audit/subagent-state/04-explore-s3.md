# S3 三面对齐扫描检查点 — task-v149

## 扫描范围
- 仓库：/mnt/data/dev/task-planner-skill（master 21f7e6b）
- 技能本体：/mnt/data/dev/task-planner-skill/skills/task-planner/
- 三面：SKILL.md（498 行）/ references/critical-rules.md（800 行）/ 消费面（scripts/*.sh + templates/ + companion/agents/）

## 扫描清单 1：SKILL↔CR 摘要对齐

### 发现 1.1 [H] Rule 45/46/48/56/60 在 SKILL.md Critical Rules 摘要列表中缺失
- **三方证据**：
  - SKILL.md:275-326（Critical Rules 摘要列表）— 只有 Rule 13-44/47/49-55/57-59/61-64 的独立 bullet
  - SKILL.md:350（References 表）— Rule 45/46/48/56/60 在 References 表中有列出
  - SKILL.md:9（frontmatter description）— Rule 45/46/48/56/60 在 description 行中有列出
  - critical-rules.md:472（Rule 45 注释完整性规范）
  - critical-rules.md:492（Rule 46 子代理单任务专注度）
  - critical-rules.md:514（Rule 48 交付总结可定位性与实用性）
  - critical-rules.md:626（Rule 56 用户指令优先与自动执行）
  - critical-rules.md:680（Rule 60 主动解决问题泛化行为原则）
- **建议修法**：以 critical-rules.md 为准，在 SKILL.md Critical Rules 摘要列表中补充 Rule 45/46/48/56/60 的独立 bullet

### 发现 1.2 [M] frontmatter description 行「61 预留未落地」过时
- **三方证据**：
  - SKILL.md:9 — 写「62 四文件罗盘数据流转与调研知识沉淀纪律（61 预留未落地）」
  - critical-rules.md:716-725 — Rule 61 已落地（task-v146），有完整 61.1-61.6 子条
  - SKILL.md:323 — Rule 61 摘要 bullet 已存在
- **建议修法**：以 critical-rules.md 为准，将 SKILL.md:9 的「61 预留未落地」改为「61 偏移检查子代理化」

### 发现 1.3 [M] Rule 61 括注缺失（已知遗留）
- **三方证据**：
  - SKILL.md:9 — Rule 62 后面跟了括注「61 预留未落地」，但 Rule 61 本身没有单独列出
  - SKILL.md:323 — Rule 61 摘要 bullet 存在，但格式为 `Rule 61（偏移检查子代理化 — task-v146）`，与其他 Rule 格式一致
  - critical-rules.md:716 — Rule 61 标题存在
- **建议修法**：以 critical-rules.md 为准，在 SKILL.md:9 的 description 行中补充 Rule 61 的独立列出

### 发现 1.4 [L] Rule 13 摘要措辞与 CR 标题轻微差异
- **三方证据**：
  - SKILL.md:279 — 「调研/搜索/大文件读取/Read 大文件 必须派子代理」
  - critical-rules.md:51 — 「调研/搜索/大文件读取/跨文件 Read 必须派子代理」
- **建议修法**：以 critical-rules.md 为准，将 SKILL.md:279 的「Read 大文件」改为「跨文件 Read」

## 扫描清单 2：守卫文本锚匹配

### 发现 2.1 [L] selftest-drift-check-subagent.sh 全部 20 条断言通过
- **证据**：DCS-01 至 DCS-20 的文本锚全部存在于 SKILL.md 和 critical-rules.md
- **状态**：PASS

### 发现 2.2 [L] selftest-research-first.sh 全部 12 条断言通过
- **证据**：RF-01 至 RF-12 的文本锚全部存在于 SKILL.md、critical-rules.md、templates/subagent_dispatch.md
- **状态**：PASS

### 发现 2.3 [L] attest-plan.sh 六个锚全部存在于 templates/task_plan.md
- **证据**：锚1-6 全部存在
- **状态**：PASS

### 发现 2.4 [L] check-*.sh 没有 grep SKILL.md 或 critical-rules.md 的锚
- **证据**：check-delegation.sh / check-dispatch.sh / check-complete.sh / check-3file-gate.sh / attest-plan.sh 的锚都是针对运行时生成的计划文件或 prompt
- **状态**：N/A（运行时锚，无法静态验证）

## 扫描清单 3：模板面对齐

### 发现 3.1 [H] 「📐 创作单元并行表（Lane 状态表）」在 templates/task_plan.md 中不存在
- **三方证据**：
  - SKILL.md:264 — 声称计划含「📐 创作单元并行表（Lane 状态表）」区块
  - templates/task_plan.md — grep 计数=0
  - critical-rules.md:198（Rule 23.9）— 声称 task_plan.md 含「📐 创作单元并行表（Lane 状态表）」区块
- **建议修法**：以 SKILL.md/critical-rules.md 为准，在 templates/task_plan.md 中补充「📐 创作单元并行表（Lane 状态表）」区块

### 发现 3.2 [M] 12 个 variant 模板缺少「🧰 工具选择与编排」区块
- **三方证据**：
  - SKILL.md:307（Rule 40 摘要）— 声称 standard/full 档计划含「🧰 工具选择与编排」区块
  - templates/variant/ — 12 个媒体族 variant 模板没有此区块
  - critical-rules.md:421（Rule 40.2）— 声称 standard/full 档计划须含「🧰 工具选择与编排」区块
- **建议修法**：以 critical-rules.md 为准，在 12 个媒体族 variant 模板中补充「🧰 工具选择与编排」区块

### 发现 3.3 [M] 20 个 variant 模板缺少「🔀 隔离决策」区块
- **三方证据**：
  - SKILL.md:65 — 声称计划含「🔀 隔离决策」区块
  - templates/variant/ — 20 个 variant 模板没有此区块（含 mini-lite-type.md，mini 档豁免）
  - critical-rules.md:49（Rule 12）— 声称计划含「🔀 隔离决策」区块
- **建议修法**：以 critical-rules.md 为准，在 19 个非 mini 档 variant 模板中补充「🔀 隔离决策」区块

### 发现 3.4 [L] knowledge-brief 模板头注「锚计数 35」口径正确
- **证据**：templates/ 全库 39 个文件，35 个含「📚 必要知识储备」区块，与 critical-rules.md Rule 16 的 35/39 口径一致
- **状态**：PASS

## 扫描清单 4：companion 面对齐

### 发现 4.1 [H] video-fix-executor 在 agent-coverage.md 中登记但实体文件不存在
- **三方证据**：
  - references/agent-coverage.md:36 — 登记 video-fix-executor(D3:274 承接位)
  - references/agent-coverage.md:50 — 声称 v124 补 video-fix-executor
  - references/agent-coverage.md:120 — 声称 v124 已补 video-fix-executor
  - companion/agents/ — 无 video-fix-executor.md
  - ~/.zcode/agents/ — 无 video-fix-executor.md
- **建议修法**：以 agent-coverage.md 为准，创建 video-fix-executor.md 实体文件；或修正 agent-coverage.md 登记为「未落地」

### 发现 4.2 [M] complex-planner 的 model 档位不一致
- **三方证据**：
  - SKILL.md:394（路由表）— model=继承主会话
  - companion/agents/complex-planner.md:5 — model="account:zai-individual-coding-plan/GLM-5.3"
  - references/agent-coverage.md:13 — complex-planner(D1/D2)，未明确 model 档位
- **建议修法**：以 companion/agents/complex-planner.md 为准，将 SKILL.md:394 的 model 档位改为「GLM-5.3」

### 发现 4.3 [L] companion/agents/ 中的 7 个 agent 全部存在
- **证据**：drift-checker / plan-writer / image-generation-executor / video-generation-executor / complex-planner / article-batch-publisher / article-field-fixer 全部存在
- **状态**：PASS

## 扫描清单 5：已知分叉核实

### 发现 5.1 [L] SKILL.md C32 合规行与 alignment-review 的 42.6 措辞无分叉
- **证据**：
  - SKILL.md:203（C32 合规行）— 提到「写入前校验闸门/变更记录输出」和「五维全文扫描+标记确认后整理+删除或归档+简短变更记录三要素」
  - /home/terry/.zcode/skills/alignment-review/SKILL.md:73 — 提到「+写入前校验闸门/变更记录输出」和「五维全文扫描+标记确认后整理+删除或归档+简短变更记录三要素」
- **状态**：PASS（措辞一致）

### 发现 5.2 [M] check-drift.sh 自身头注未反映「仅作 61.5 降级佐证」定位
- **三方证据**：
  - SKILL.md:98 — 「check-drift.sh 仅作 61.5 降级佐证，不双跑」
  - SKILL.md:175 — 「check-drift.sh 仅作 61.5 降级佐证，不与子代理双跑」
  - critical-rules.md:724（Rule 61.5）— 「仍失败降级主进程跑 check-drift.sh」
  - critical-rules.md:58（Rule 15）— 「check-drift.sh 降为可选佐证不双跑」
  - scripts/check-drift.sh:1-20（头注）— 「用途：在 phase 完成后（或每 N 次工具调用后）对照原始计划校验执行是否偏航」，未提到降级佐证定位
- **建议修法**：以 SKILL.md/critical-rules.md 为准，在 check-drift.sh 头注中补充「仅作 Rule 61.5 降级佐证，不双跑」定位说明

## 发现汇总

| # | 标题 | 级别 | 涉及面 |
|---|------|------|--------|
| 1.1 | Rule 45/46/48/56/60 在摘要列表中缺失 | H | SKILL.md ↔ critical-rules.md |
| 1.2 | frontmatter description 行「61 预留未落地」过时 | M | SKILL.md ↔ critical-rules.md |
| 1.3 | Rule 61 括注缺失 | M | SKILL.md ↔ critical-rules.md |
| 1.4 | Rule 13 摘要措辞轻微差异 | L | SKILL.md ↔ critical-rules.md |
| 2.1 | selftest-drift-check-subagent.sh 全部通过 | L | selftest-*.sh ↔ SKILL.md/CR |
| 2.2 | selftest-research-first.sh 全部通过 | L | selftest-*.sh ↔ SKILL.md/CR |
| 2.3 | attest-plan.sh 六个锚全部存在 | L | attest-plan.sh ↔ templates/ |
| 2.4 | check-*.sh 无静态文本锚 | L | check-*.sh ↔ 运行时文件 |
| 3.1 | 「创作单元并行表」在模板中缺失 | H | SKILL.md/CR ↔ templates/ |
| 3.2 | 12 个 variant 模板缺「工具选择与编排」 | M | SKILL.md/CR ↔ templates/ |
| 3.3 | 20 个 variant 模板缺「隔离决策」 | M | SKILL.md/CR ↔ templates/ |
| 3.4 | knowledge-brief 锚计数 35 口径正确 | L | templates/ ↔ CR |
| 4.1 | video-fix-executor 登记但实体不存在 | H | agent-coverage.md ↔ companion/ |
| 4.2 | complex-planner model 档位不一致 | M | SKILL.md ↔ companion/ |
| 4.3 | companion/agents/ 7 个 agent 全部存在 | L | companion/ ↔ ~/.zcode/agents/ |
| 5.1 | C32 合规行与 alignment-review 无分叉 | L | SKILL.md ↔ alignment-review |
| 5.2 | check-drift.sh 头注未反映降级佐证定位 | M | SKILL.md/CR ↔ check-drift.sh |

**统计**：H=3 / M=6 / L=8
