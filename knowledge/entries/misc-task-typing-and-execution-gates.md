---
id: misc-task-typing-and-execution-gates
title: "杂项任务分型与落地门控"
tags: [任务分型, 轻量档, 效率优化, 媒体派发, 需求覆盖]
sources:
  - plans/archive/task-v085-task-type-mechanism-profile/knowledge-brief.md
  - plans/archive/task-v086-mini-fast-path/findings.md
  - plans/archive/task-v091-efficiency-optimization/knowledge-brief.md
  - plans/archive/task-v122/knowledge-brief.md
  - plans/archive/task-v122/findings.md
  - plans/archive/task-v123/knowledge-brief.md
  - plans/archive/task-v123/findings.md
  - plans/archive/task-v124/knowledge-brief.md
  - plans/archive/task-v129/findings.md
  - plans/archive/task-v138/knowledge-brief.md
  - plans/archive/task-v138/findings.md
updated: 2026-10-22
---

# 杂项任务分型与落地门控

> 汇总"任务怎么分型 → 走哪档 → 派给谁 → 交付与留痕怎么过关"的杂项落地经验，供跨域复用。

## 结论（可直接复用）

1. **任务分型先于机制选择（机制画像）**：按计划 frontmatter 的 `template_type` 查表得"适用机制组 + 执行体路由组"。机制分三组——代码组（Code Review Gate / code-assistant 路由 / 修改后验证）、内容组（内容质量门控 / 文章类路由）、通用组（全部守卫不变、全类型适用）。非代码任务不再误入代码机制。锚：task-v085 knowledge-brief.md:13,18-20,30。
2. **轻量档（mini）判定四条件**：frontmatter 声明 `plan_tier: mini` ∧ `scope_files` ≤2 ∧ 预估时长 ≤15min ∧ 单模块；四条不全满足 → 机器门打 `[plan-tier] MISMATCH`（warn 不阻断，由用户改回 standard）；未声明 plan_tier 的既有计划一律 standard（零影响）。锚：task-v086 findings.md:27-30。
3. **mini 门控豁免五锚**：①FMEA 段缺失直接 OK（打 `[fmea-gate] MINI-TIER SKIP`）；②VC 最低 5→2、每 Phase V-N 映射 2→1；③委派率 floor 0.7→0 且 main_direct 理由视白名单直通；④派发型 Phase 的 S-unit 表豁免（**仅当 Executor 全为"主进程"**，有非主进程 Executor 即回落全量校验）；⑤knowledge-brief 降为可选单段"速览"。锚：task-v086 findings.md:19-23；机器门控消费 frontmatter 标记而非模板文件名（防手搓计划绕过）见 :40。
4. **效率优化提案必须 Tier A/B 分层**：Tier A=不触及用户既有裁决、可直接采纳；Tier B=涉裁决项，须按 Rule 32.4 引新证据单列交用户 D1 决策；"为了快"不构成豁免理由（Rule 18.9 试点先行 / 18.10 单件失败禁批量 / 18.11 宁慢勿错）。取证产出落固定目录 `<plan-dir>/workflow-evidence/`。锚：task-v091 knowledge-brief.md:10,13,25,27,38,65。
5. **媒体类任务三面派发**：①**拆分轴=制作阶段（写词→生成→质检→处置→组装）× 生产单元（集/场/分镜/镜头/张/音频条）**，单 S-unit=单生产单元×单阶段，禁"整集生成"式粗粒度派发；②**具名执行体路由**，general-purpose 仅限跨领域复合且须登记理由，禁"路由表无匹配行就默认落 general-purpose"；③**批量生成试点先行**：同参批量 ≥3 单元前首单元必须试点通过（提示词/参数/质检三通过）→参数冻结→方可批量，首单元失败禁止批量。锚：task-v122 findings.md:129-135,166-178。
6. **媒体专用执行体补齐 + 路由表登记**：新增 image/video-generation-executor 两个 companion agent（install-companion.sh glob 自动分发，新增 agent 零机制改动）；SKILL.md 与 template-mapping.md 用**行内替换**（净增 0 行）避免行数锚级联；image 设"首件过三检才扩批"试水门，video 设"任何调用前须有草稿放行登记"G1 硬门。锚：task-v124 knowledge-brief.md:6,14,21,24,31。
7. **交付总结可定位性（每条指针用户能直接打开或执行）**：指针必须为绝对路径 / 仓内路径+仓库根绝对路径 / 完整 URL / 含工作目录的可执行完整命令；**禁**裸文件名、模糊指代（"相关文件""上文"）、未解析占位符（`<merge-hash>` 原样输出）、缺路径命令。行动项三要素=①对象（要打开/审查的东西）②看点（锚点/段落）③动作（做什么+期望反馈）；**审查类条目必须含审查对象路径或网址**，操作类必须含可执行命令。锚：task-v123 findings.md:196-202；task-v123 knowledge-brief.md:20-21。
8. **需求覆盖门控六子条**：①需求原文锚定（逐条抄原话 R1..Rn，禁转译/缩写/合并，每条核心需求映射 ≥1 条 VC）；②验证机制先行（先登记"覆盖判据"再执行）；③完成声称对照门（逐需求出 covered/partial/uncovered+证据路径，核心需求未 covered 禁 COMPLETE，只可 PARTIAL）；④自缩水禁令（"挂起/搁置/收口/有条件不执行"=语义级目标分叉，须 AskUser/STOP + Decisions Made 登记）；⑤生成动作前置盘点（在库/在用同类资产清单落 findings，有货则零生成）；⑥机制=零新 config 键 + selftest-requirement-coverage.sh 守护。锚：task-v129 findings.md:95-100,116-123,126-127。
9. **可复用能力簿记 registry（落盘=DoD）**：可复用操作首次正确执行后必须落盘，否则任务不完整。固定落点 `scripts/capabilities/<name>.sh`，唯一索引 `references/capability-registry.md`（8 列：名称/脚本路径/用途/调用方式/数据来源端点/输出形态/verified 日期/任务来源）。**权威来源优先**：有 API/官方端点可直查时禁耗时累计/抽样估算/记忆拼接等代理推算；脚本只呈现原始字段，不做二次减法推算；密钥禁硬编码、须同源复用。锚：task-v138 knowledge-brief.md:23-33,50；task-v138 findings.md:334,351。
10. **新增脚本的失败分支必须可区分且显式**：退出码分档（0 取到数据 / 2 用法错误 / 3 全部候选 key 无效 / 4 端点不可达）；禁把"恒 200 但计费层未回传"冒充鉴权成功（CDN 缓存态 200 陷阱），用零成本控制组请求区分 401 与非 401。锚：task-v138 findings.md:340,342-345。

## 证据锚

- 机制画像：task-v085-task-type-mechanism-profile/knowledge-brief.md:13,18-20,30
- mini 判定与五锚豁免：task-v086-mini-fast-path/findings.md:19-30,40
- Tier A/B 与取证目录：task-v091-efficiency-optimization/knowledge-brief.md:10,13,25,27,38,65
- 媒体派发三面与断言清单：task-v122/knowledge-brief.md:6,11-12；task-v122/findings.md:113-135,166-178
- 媒体执行体：task-v124/knowledge-brief.md:6,14,21,24,31
- 交付总结可定位性：task-v123/knowledge-brief.md:20-21；task-v123/findings.md:196-202
- 需求覆盖门控与事故归因：task-v129/findings.md:36-37,95-100,116-123,126-127
- 能力簿记 registry 与失败分档：task-v138/knowledge-brief.md:23-33,50；task-v138/findings.md:334,340-351

## 易错点

1. **拿通用模板跑一切任务** —— 慢源是"重仪式区块全量标配"与"每 Phase 6 步闭环"，与复杂度无关；先分型再选档（task-v086 findings.md:11）。
2. **mini 声明与机器条件不一致** —— MISMATCH 只提示不阻断；Executor 字段混有非主进程时豁免不成立，须回落全量校验（task-v086 findings.md:22,28）。
3. **效率提案顺手废除串行派发铁律** —— 属 Tier B，须按 Rule 32.4 引新证据单列交用户决策，不得自行绕过（task-v091 knowledge-brief.md:24,65）。
4. **画像引用的项目专属资产在通用环境缺位** → 路由落空回退 general-purpose；必须补"资产缺位时的通用兜底路由"条款（task-v122 findings.md:118,131）。
5. **兜底路由只写执行体名、不点名生成技能与参数契约** → 派发后仍需现场发明（task-v122 findings.md:131）。
6. **批量生成未试点就扩批** —— 首单元失败仍批量=违反试点先行硬门（task-v122 findings.md:133）。
7. **交付总结用裸文件名/占位符/空泛动词**（"持续关注""后续跟进"）→ 用户不知去哪审查（task-v123 findings.md:199-200）。
8. **生成类动作不盘点库存** —— 17 次零产出浪费的根因即无盘点义务（task-v129 findings.md:37,99）。
9. **额度/配额类事实用耗时累计或抽样估算拼接** —— 产出完全错误的值；CDN 缓存态 200 会冒充鉴权成功（task-v138 knowledge-brief.md:24；task-v138 findings.md:340）。
10. **把"计划缩水"当已处置** —— 计划文本写"挂起"不等于获用户让步，须 Decisions Made 登记（task-v129 findings.md:98）。

## 适用场景

- 新任务不知该用哪套仪式、走哪档模板、派给谁时；
- 媒体/内容类任务被反馈"拆分粗、总落 general-purpose"时；
- 交付总结写完但用户反馈"不知道到哪里审查"时；
- "声称完成、实际核心诉求只完成 2/18"的虚假完成事故复盘与加门控时；
- 高频可复用操作每次现场重写、需落盘成脚本并建索引时。
