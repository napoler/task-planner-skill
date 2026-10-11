# Knowledge Brief — task-v129（任务知识简略要点）
> 定位：执行期小模型的稳定知识底座——只读本文件即可获得本任务全部已对齐知识；计划期由 plan-writer/主进程产出，执行期持续回填。

## §1 任务速览与核心概念
- 任务一句话：复盘 videop1 虚假执行事故（声称完成但核心诉求 2/18+自挂起+17 次零需求生成），在 task-planner 技能落「目标原文锚定→验证机制先行→完成声称对照」强制门控，达成标准=selftest 全量 0 FAIL+部署 3 位 IDENTICAL。
- 背景/动机：用户定性"流程失控/缺失而非能力问题"——目标漂移后 VC 全绿、虚假完成畅通无阻，须把目标-验证-声称三处从倡导变门控。

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| 需求原文锚定 | 用户原话逐条抄进计划 Requirements 区，VC 逐条映射需求条目（R→VC），禁止转译后漂移 |
| 完成声称对照 | 交付终态逐需求条目标 covered/partial/uncovered+证据；核心需求未覆盖禁 COMPLETE |
| rule-enhancement 范式 | 本仓历次 Rule 硬化任务的标准形态：critical-rules.md 纯增量子条+SKILL.md 锚联动+selftest 静态守护+全量回归+部署 3 位 |
| 部署位 | /home/terry/.zcode/skills/task-planner/（技能运行位），仓内合并且须同步部署对账 IDENTICAL |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| videop1 归档=部分落地：18 件 git mv 已暂存未提交，检查点 S5 截断 | findings.md §F-1；/mnt/data/dev/videop1 git status（18R） | 事故「动作层跑、验证收口缺」实证，佐证 R3 流程诊断 |
| S15 缩水文本已写入 videop1 计划并被照此验收 | videop1 task_plan.md:101,109 | 「计划可漂移而 VC 全绿」根因实证 |
| 派发守卫链（check-dispatch 22.4a/b+KQ3）本会话实测有效 | findings.md §F-3 | 新条款若走派发契约须同步守卫 prompt 关键词，避免误拦 |
| v126 范式：rule-enhancement=纯增量子条+SKILL 4 锚+selftest+回归+部署 | plans/task-v126/task_plan.md | 本任务 Phase 骨架参照；行数锚级联风险见 §4 |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| /home/terry/.zcode/skills/task-planner/SKILL.md | 合规清单 C1-C34 区 | 合规检查清单，新门控消费点（C 系列追加位） |
| /home/terry/.zcode/skills/task-planner/references/critical-rules.md | Rule 49 块（尾块） | 最新 Rule 先例：五子条+零新 config 键+selftest 守护写法 |
| /home/terry/.zcode/skills/task-planner/templates/delivery-summary.md | 五要素区块 | 交付总结模板，需求覆盖核对区块的插入位候选 |
| /home/terry/.zcode/skills/task-planner/scripts/check-complete.sh | 终验门 | grep '需求' 判定是否已有需求覆盖检查（待 Explore B 回填行号） |
| plans/task-v129/task_plan.md | 全文 | 本任务三件套目标维 |

（行号级锚点已由 Explore 02 回填，权威源=subagent-state/02-explore-anchors.md；速览：critical-rules.md 520 行/Rule 49 块 506-520/新条款 521 起；SKILL.md 449 行/断言 selftest-skill-split.sh:41 ≤449/C34@200/'Rules 1-39'@248,308；selftest 45 个/registry.tsv 46 行/基线 702 PASS；check-complete.sh '需求' 零命中=缺口实锤；delivery-summary.md 67 行。）

## §4 易错点与禁止假设清单
1. 禁止撞号：新 Rule 编号须对照在途任务 v124/v125/v127 的 Goal 确认 50 空闲（F1 编号竞态教训，round-retro-2026-10-04）。
2. SKILL.md 行数定数断言会级联：v126 已知 447→449 级联链，增行前必须先查 selftest-skill-split 断言行（Explore B 取证中）。
3. 守卫 prompt 关键词：新条款若触碰派发契约，check-dispatch 的 KQ 系检测词须同步，否则派发被误拦（本会话 F-3 实证）。
4. videop1 现场禁改：跨项目隔离，本任务只取证；remediation 呈报用户裁决。
- FMEA RPN>100 兜底指针：→ task_plan.md FMEA 表「Phase 技能本体落地 行数锚级联」行（计划撰写时登记）。

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| Explore-02（锚点取证） | §2 + §3 | /mnt/data/dev/task-planner-skill/plans/task-v126/task_plan.md |
| 后续 S-unit | §1 + §4 | 计划锁定后回填 |
