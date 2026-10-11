# Checkpoint: 01-explore-knowledge (task-v067-knowledge-brief)

- **time**: 2026-09-13
- **agent**: Explore（mini）, seq 01, Phase 1 S1
- **status**: done（子代理无 Write 工具，本文件由主进程按返回全文落盘）
- **消耗**: subagent_tokens≈2365k, tool_uses=42, 554s; acceptance 8/8

## ① 逐处 file:line 锚点表

### 1. 模板侧
- templates/task_plan.md:79 章节标题 `## 📚 必要知识储备（任务知识库对齐 — 开工前必填）`；:88-96 五类知识源表+填写规则；:147 Phase 1 checkbox「知识储备必读项已确认可获取」
- 12 variant 全含同章节（grep 20/20 命中）：bugfix-type.md:44 / code-edit-type.md:41 / deployment-type.md:45 / diagnostic-type.md:24 / migration-type.md:44 / performance-tuning-type.md:45 / publish-type.md:35 / refactor-type.md:44 / research-type.md:28 / schema-migration-type.md:46 / test-writing-type.md:44 / writing-type.md:25
- 辅助模板同标题：findings.md:12 / progress.md:36 / verification.md:69 / batch_report.md:6 / cost_log.md:58 / notepad-learnings.md:20 / subagent_dispatch.md:25
- 一致性验收锚：references/template-guide.md:65 `grep -rl "## 📚 必要知识储备" templates/ | wc -l` 应为 20
- 契约安全约束：template-guide.md:68 章节插入位置必须在「⚠️ 执行范围限制」区块完整结束之后（check-conflicts/check-drift 以 `/^## /` 状态机提取 scope）

### 2. agent 侧 plan-writer.md（companion/agents/）
- :4 frontmatter 描述；:37-43「掌握的技能」5 条；:40 材料包预写职责原文（Rule 21.1b/22.6）
- :98-116 产出契约表（八字段，无知识储备显式字段——章节靠模板复制自带）
- :188 禁止行为「❌ S-unit 输入列只写路径不写摘要」
- **全文 grep「必要知识储备」= 0 次 → plan-writer 无知识储备填写/预写显式职责（knowledge-brief 接入空档实锤）**
- 验证协议 :215-221

### 3. SKILL.md 侧
- SKILL.md:509 唯一约束行「所有模板统一含必要知识储备章节…缺失 → STOP」；:302-317 References 表（表体 :304-317 共 13 行，指针行可插 :316 前后）；:507 init-session 按 template_type 复制；:510 项目级覆盖路径

### 4. 守卫/校验侧
- check-3file-gate.sh：**不校验知识储备/brief**。:35-37 三文件路径定义；:39-45 存在性循环（缺→exit 1）；:100-125 mtime/ledger 新鲜度
- check-complete.sh：无知识储备/brief 校验（:289 3-File Gate 仅 findings/progress；:322 膨胀 WARN；:451-470 rescue；:467-574 VC-GATE）
- check-dispatch.sh「三文件」守卫（KQ2 核心）：:47 正则抽取 `/(task_plan|findings|progress)\.md`；:48 遍历列表（7 项=3 路径+status:/acceptance:/checkpoint:/subagent-state/）；:50-83 文件身份判定；:78-82 缺项名输出；:146/:151-159 自声明锚定只按 task_plan.md 目录；:195 阻断文案
- **扩四文件必改行：47/48/50/78-82/195 + 头部注释 :3/:28**（:146-159 锚定语义可不动；:172-185 串行槽不扰动）

### 5. selftest-dispatch.sh 影响面（18 用例=T01-T12+TS-01..06）
- :22-42 mk_prompt 组装 7 必检项；:27-30 三文件路径行
- 涉三文件断言：T01 :78 / T02 :80-81 / T05 :92-93 / T08 :101-107（**exit 1 且 stdout 恰 2 行——行数断言依赖缺项集大小**）/ T09 :109-114 / T10 :116-122（:117 项集）/ T12 :131-135 / TS 夹具 :138-142 + tscl_prompt :143-152
- **KQ2 波及必改：27-33 / 102-107 / 117-118 / 140-142 / 145-150 + T01/T02/T05/T06/T09/T12 传递复核**

### 6. 材料包链路
- templates/subagent_dispatch.md:10-23 §2 输入块（:11-14 三文件+22.4a 契约；:15-17 材料包路径；:18-21 findings 摘要；:23 来源说明）
- **brief 锚点最佳插入位 = :25-29 已有「📚 必要知识储备上下文包（随 prompt 注入）」表之下（该表 :27 三列：知识源/定位/注入方式），或 §2 :17 之后**
- critical-rules.md：:115 Rule 21.2 自包含；:127 Rule 22.4 九字段输入；:128 22.4a 三文件契约；:130 22.4c 守卫；:132 22.6 S-unit 输入列
- 扩四文件文字点：:127/:128/:130 + subagent_dispatch.md:11-14

### 7. init-session.sh
- :60-78 variant 路由；:90-98 循环建 4 文件；:101-115 task_plan 单独处理；:118-130「5 文件存在性复核」（:120 for 列表）；:131 `[init] 5/5 planning files verified`
- **扩第 6 文件改动点：90（循环）或单独建块 / 120（复核列表）/ 131（文案）**；模板复制走 :42-51 copy_template
- **联动（change-linkage-audit）**：scripts/check-scope.sh:66 白名单 `task_plan.md|findings.md|progress.md|notepad-learnings.md|verification.md)` 需 +1 项；references/template-mapping.md:163 白名单表（该处行号引用已漂移：实际 init-session.sh:120 / check-scope.sh:66）需同步

### 8. config.json
- fmea_enforce :81-90 / skill_collab_enforce :91-100（新键范式参照，插 :90 后或 :100 后）；**:327 additionalProperties:false——新键必须登记进 properties**

## ② KQ2 波及面清单（22.4a 扩四文件——高风险）

| 文件 | 需改行 | 改动 |
|------|--------|------|
| scripts/check-dispatch.sh | :47/:48/:50/:78-82/:195 + 头部 :3/:28 | 正则/列表/case/缺项名/文案/注释 |
| scripts/selftest-dispatch.sh | :27-33/:102-107/:117-118/:140-142/:145-150 | mk_prompt/T08 行数/T10/夹具/tscl_prompt + 6 用例传递复核 |
| references/critical-rules.md | :127/:128/:130 | 22.4/22.4a/22.4c 三→四措辞 |
| templates/subagent_dispatch.md | :11-14/:23 | §2 加第 4 路径 |
| scripts/init-session.sh | :90/:120/:131 | 建第 6 文件+复核+文案 |
| scripts/check-scope.sh | :66 | 白名单 |
| scripts/check-3file-gate.sh | :35-45 | 仅当纳入回填门控（建议否） |

## ③ KQ3 依据
- check-3file-gate/check-complete **零知识储备机械校验**（纯模板自带+人工 checkbox task_plan.md:147）
- 纳入 3file-gate 成本：改 3 处 + **存量 5 文件计划全量补建第 6 文件否则 exit 1 误报** → 破坏存量兼容
- 结论：brief 走「plan-writer 计划期生成 + init-session 建档 + 派发材料包引用」路线，不纳入 3file-gate

## ④ 建议接入点风险排序（低→高）
1. SKILL.md:509 指针强化 + References :316 +1 行 + template-guide §2.4 补说明 —— 纯文档零脚本波及
2. subagent_dispatch.md:25-29 知识上下文包表下补 brief 行（≤2 行）—— 不动 22.4a
3. config.json knowledge_brief_enforce（:81-90 范式，注意 :327 additionalProperties）—— 流程层执行
4. 22.4a 扩四文件 = 高风险（② 表全量波及+18 用例复核+存量兼容），**建议独立任务**
5. brief 纳入 check-3file-gate = 最高风险（存量全 exit 1），**否决**

## 负结果报告
- plan-writer.md「必要知识储备」0 命中（接入空档实锤）；attest-plan.sh:60-65 仅 S-unit dispatch-check；check-plan-dispatch.sh 仅 S-unit/Executor 门控
- 未验证项：worktree 9b3619d 与主仓逐字节 diff（任务声明一致，主仓调研覆盖全部锚点）
