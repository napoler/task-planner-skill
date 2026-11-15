---
id: superpowers-openspec-complexity-routing
title: "Superpowers×OpenSpec 复杂度择一路由条款——设计要点、落地锚与 attest/部署判例"
tags: [task-planner, spec-mode, plan-collab-router, routing, superpowers, openspec]
sources: [plans/task-superpowers-openspec-routing-20261116/findings-external-families.md, plans/task-superpowers-openspec-routing-20261116/verify-report.md, skills/task-planner/references/spec-mode.md]
updated: 2026-11-16
---

# Superpowers×OpenSpec 复杂度择一路由（task-superpowers-openspec-routing-20261116 蒸馏）

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响 |
|------|---------------------|------|
| task-planner 对两族的集成是「部分完成」：2026-11-15 已落 Spec 模式路由+三族触发矩阵，缺的是复杂度轴与两族整族择一决策表 | skills/task-planner/SKILL.md:65,71,266；references/spec-mode.md:1-16；plan-collab-router/references/skill-collaboration.md:51-68（merge 42ab794 时点） | 后续增强先查既有载体，禁另起新技能重复建设 |
| comet 的变体选择=CLI resolve+IntentFrame/runtime scorer，非静态关键词表 | /home/terry/.zcode/skills/comet/SKILL.md:13-31；comet-classic/SKILL.md:32-44,78-127 | 学习 comet=学「画像维度+决策表」形态，勿复制其 runtime |
| OpenSpec 族前置 openspec CLI，路径由 CLI 动态解析（禁硬编码） | /home/terry/.zcode/skills/openspec-propose/SKILL.md:4-6,42-56 | 路由条款须带探针降级语义（spec-mode §2 安装引导） |
| 复杂度主轴+信号修正=用户裁决判据：L0/mini 直执行、L1→superpowers 嵌入、L2+/规格留存→openspec 移交、触及已有 spec/跨会话托管→信号修正 | plans/task-superpowers-openspec-routing-20261116/user-session-log.md#1（裁决逐字） | 后续调判据先读专档原话，禁凭记忆改判 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要 |
|------|------|-----------|
| skills/task-planner/references/spec-mode.md | :18-28 | §1b 复杂度分档→族选择决策表：四档映射+信号修正行+择一语义（merge 42ab794 时点，行号以实施日重验为准） |
| skills/plan-collab-router/references/skill-collaboration.md | :55 | §二「复杂度主轴初筛」段：初筛轴+信号修正覆盖+与 §1b 同构互引（冲突以本表=权威源为准） |
| skills/task-planner/SKILL.md | :65 | Spec 模式检查行行尾 §1b 择一路由指针（行尾追加，PREFIX 保真） |
| plans/task-superpowers-openspec-routing-20261116/findings-external-families.md | :1-145 | A-F 六段调研（仓内现状/comet 机制/两族画像/竞合 6 条/设计建议 5 条），逐条 file:line 锚 |

## §4 易错点与禁止假设清单
1. attest S-unit「预估时长」列须裸 `NNmin`——带 `≤` 前缀解析失败整行 SKIPPED（本次首跑拒锁判例）
2. S-unit 粒度三值 ≤100l 硬门：粒度列=计划期预估口径，实际产出超预估如实记 progress Test Results，两口径禁混写（Decisions 已登记）
3. Phase Executor 串禁出现「主进程」字样（委派体括注里也不行）——check-delegation 按关键词误计 main_direct+self_declared violation（本次 stats 首跑 verdict=violation 判例；改「由编排面代跑」归真）
4. VC 判据串写前先验证 commit message 实际格式（本次 --grep="wt/…" 对 feat(/merge( 前缀必空匹配=spec 笔误误 FAIL）；判据修正须 intent 不变+Decisions 登记
5. 部署位覆盖前必须逐对 diff 判向：位侧独有内容=0 才可正向覆盖；位侧缺失文件=mkdir+cp 补建（.agents 位缺 spec-mode.md/skill-collaboration.md 判例）
6. worktree 基点=master 禁 main（本仓 main 无共同祖先）；selftest 基线对照用「worktree FAIL ≤ master FAIL」防预存 FAIL 误判（master 基线 98/96/2：active-plan+execution-stability 预存）
- FMEA RPN>100 兜底指针：无（最高 RPN=63，Phase 5 部署判向；→ task_plan.md FMEA 表「Phase 5 部署位漂移方向误判」行）
