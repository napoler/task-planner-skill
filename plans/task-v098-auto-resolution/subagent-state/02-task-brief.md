# P2-S1 任务书: critical-rules.md EOF 纯追加 Rule 41 六子条（task-v098）

任务: worktree 内 critical-rules.md 末尾纯追加 Rule 41「问题自主消解与升级纪律」节头+六子条全文。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/task_plan.md（只读: Goal/VC-1/核心问题定义/Errors Encountered 首行归因）
- findings.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/findings.md（只读: 升级点盘点+31.2 归因）
- progress.md: /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/progress.md（子代理禁写）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v098-auto-resolution/skills/task-planner/references/critical-rules.md（当前 402 行,EOF=40.6）

## 硬约束
只在该文件 EOF 后追加,L1-402 一个字符都不许动（VC-6 要求 22.3/28/33.4/35.6/39/40 原文逐字节零改动）;禁写其他任何文件。

## 必读材料
1. 该文件 L369-402（Rule 39/40 全节）——格式范式必须同构: 节头 `### 41 问题自主消解与升级纪律（P0 — task-v098，目标：…）`,子条行首 `41.1 **标题**：内容`（保证 `grep -c '^41\.'` =6）
2. /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/knowledge-brief.md §2（六子条骨架与措辞锚）

## 六子条内容骨架（据此撰写完整条款,风格对齐 Rule 39/40,可适度扩写不偏离语义;引言段须写明与 22.3/28 的关系=后置纪律层不改其原文、与用户归因活例的呼应）

- 41.1 **消解优先原则**: 遇到问题（执行失败/异常/阻塞/不确定）的第一反应=自动消解,标准消解链=重读计划三文件对齐目标 → Rule 22.3 ①-④ 兜底链全试（改派/拆细/降档/主进程接管）→ 最小探针复测（35.6）→ 问题拆细 → 替代路径检索（35.2 三关）。升级用户（AskUserQuestion/STOP）是**最后手段而非默认出口**;「停点成本低于消解成本」是反模式。
- 41.2 **升级四门槛（evidence-gated escalation）**: 仅四类问题可升级用户——G1 破坏性/不可逆操作确认（rm -rf 实质数据/force push/reset --hard/drop schema/删用户文件）;G2 范围越界（跨项目改动/计划外文件写入/scope 扩围请求,scope guard 语义保留）;G3 对外不可撤回发布（push/发消息/发布内容/删远端资源）;G4 语义级目标分叉（≥2 个合理方案交付语义不同且无共识推荐——ask 模式询问,silent 模式按 T3 推荐项自动+登记）。四门槛之外的一切问题（含命名/格式/注释/路径细节/一致性顺带修复/技术选型有明确推荐者/失败重试/环境小障碍）=自动消解+Decisions Made 登记+交付披露,**禁止呈报询问**。
- 41.3 **trivial 自主裁定**: 明显正确的小修（trivial ≤3 行/单行配置增补如 .gitignore/注释同步/一致性收尾）=主进程直接做+Decisions Made 登记,禁止以「留用户裁决」「留用户后续处置」类措辞推诿;该类措辞在交付物中仅可用于命中 41.2 四门槛的项（task-v097 CR P2-b .gitignore 一行被推给用户即反例,本条即为其纠正）。
- 41.4 **升级前置消解清单（硬门槛）**: 任何 AskUserQuestion/STOP 升级动作前必须已过消解清单——①重读计划三文件对齐 ②22.3 ①-④ 全试 ③最小探针复测 ④问题拆细 ⑤替代路径检索;升级消息必须附「已尝试清单」（逐条列已试动作与结果）,缺失=violation（合规清单承载）。**D6 硬停点（破坏性操作确认/连续失败 STOP/Q3/drift BLOCKED）语义保留不弱化**,但触发前同样先执行清单中可自动部分,上报内容须含已尝试记录。
- 41.5 **打包呈报**: 同一会话存在多个待决项时一次性打包呈报（单次 AskUserQuestion 列全）,每项附主进程推荐项与默认动作,禁止逐个零碎骚扰;呈报后按用户答复执行,未答复项按推荐项登记 silent 决策继续（D6 项除外）。
- 41.6 **机制（零新 config 键 — 与 task-v087/v088/v097 同范式）**: 判定面=LLM 行为（升级冲动出现时的自我审查,非机器触发）;机器面=`scripts/selftest-self-resolution.sh` 静态断言（六子条锚/四门槛措辞/消解清单措辞/零新键）;消费侧=SKILL.md 合规清单 C29;22.3/28/D6 原文零改动,本条为后置纪律层经 checklist 生效。

## acceptance: 验收标准
1) `grep -c '^41\.' <目标文件>` = 6
2) `git -C <wt> diff --numstat` 该文件纯增（deletions=0）,L1-402 零变化
3) 41.2 含「G1」「G4」与「四类」;41.3 含「直接做」与「留用户裁决」;41.4 含「已尝试清单」与「D6 硬停点语义保留不弱化」;41.6 含「零新 config 键」与「selftest-self-resolution.sh」
4) `git -C <wt> diff --stat` 仅该 1 文件

## checkpoint
完成前把结论与命令实际输出写入 /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/subagent-state/02-executor-p2s1.md。禁 git commit/add。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
