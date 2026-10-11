# P2 撰写任务书: task-v099 task_plan.md + knowledge-brief.md（executor 接管 plan-writer 面,白名单⑤登记）

任务: 在 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/ 下全量撰写 task_plan.md（替换 init 占位,保留结构区块）与 knowledge-brief.md（五段）。你只写这两个文件+检查点,禁写其他任何文件,禁 git commit/add。

## 第一步必读
1. 主任务书 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/01-task-brief.md（用户三原话+Rule 42/43 六子条骨架全文+硬性要求+基线事实）
2. 同目录既有 task_plan.md（结构区块清单: 配置表/VC/范围表/知识储备/核心问题/Current Phase/Next Step/Phases/FMEA/Todo/KeyQ/Decisions/Errors/Notes/Drift/Batch/委派统计/Handoff/Chain/模板感知）
3. /mnt/data/dev/task-planner-skill/plans/task-v098-auto-resolution/task_plan.md（**同族先例,v098 已交付**——结构/字段形态/措辞直接对标,其 Decisions 区「workflow 编排/25.4a 白名单/级联 wc 实测」三条经验必须继承）

## 动手前实测（结果写入 brief §2,禁凭记忆）
- `git -C /mnt/data/dev/task-planner-skill rev-parse master`（worktree 基线 SHA）
- `wc -l skills/task-planner/SKILL.md references/critical-rules.md`（两仓内文件）
- 全量 selftest 逐脚本 Total 行求和（脚本在 skills/task-planner/scripts/,Total 行有 `Total:` 与 `==== selftest` 两种形态,正则须双覆盖——v098 教训）
- `grep -c 'Rules 1-39' SKILL.md`（应=2,若漂移 STOP 报 issues）
- selftest-registry.tsv 行数

## task_plan.md 撰写规格
**配置表**: template_type: rule-enhancement / code_review: required / interaction_mode: silent / worktree_path=/mnt/data/dev/task-planner-skill-worktrees/task-v099-reliability-institution / branch=wt/task-v099-reliability-institution / 基线=实测 master SHA / scope_files 逐个列全（critical-rules.md、SKILL.md、templates/task_plan.md、templates/variant/mini-lite-type.md、companion/agents/plan-writer.md、scripts/selftest-reliability-institution.sh(新)、scripts/selftest-registry.tsv、scripts/selftest-skill-split.sh）
**VC 6 条**: ① `grep -c '^42\.'`=5 且 '^43\.'=4（critical-rules.md）② SKILL 三锚（C30/C31/摘要行/「含 Rule 42/43」括注）在位+级联 selftest-skill-split 上限=实测值 ③ 模板配置表「质量审查工具」行+mini-lite 豁免行在位 ④ plan-writer.md 义务行在位 ⑤ 新 selftest 全 PASS+全量回归 0 FAIL（≥基线实测+R 断言增量,主进程求和定数） ⑥ 合并+三位部署 IDENTICAL+push 成功+worktree 清理 0/0
**范围表**: 按上列 8 文件+plans 本目录;禁止列: config.json（零新键）/Rule 22-41 任何原文/模板契约标记
**Phase 5 段+Executor+S-unit（43.2 示范: S-unit 表加「建议档位」列,值取 mini/haiku-1/sonnet-1/opus 最小可承载档）**:
- P1 基线测绘+worktree: Executor=主进程（例外理由:① 纯 git/worktree 编排+③ 机械验证——基线求和纪律禁子代理自报,Rule 25.3 白名单）
- P2 条款层: executor。S1=critical-rules.md EOF 纯追加 Rule 42+43 全文（建议档位 sonnet-1）;S2=SKILL 三锚+「含 Rule 42/43」括注+级联 selftest-skill-split 上限（建议档位 haiku-1）
- P3 模板+契约+selftest: executor。S1=模板配置表行+mini-lite 豁免行+plan-writer.md 义务行（haiku-1）;S2=新建 selftest-reliability-institution.sh（R-01..R-12,对齐 selftest-self-resolution.sh SR 范式）+registry +1（sonnet-1）
- P4 合并部署+push+清理: 主进程（① git 编排+③ 机械验证+② 计划系统文件簿记）;B 类用户指令: `git push origin master` 随本 Phase（用户 09-30「部署到各个平台,提交 GitHub 备份」持久指令沿用,Decisions 登记）
- P5 CR Gate+终验: code-reviewer（sonnet-1）+主进程簿记（②⑤）
**隔离决策表**: worktree;conflict_scan=safe（信号①=plans 指针+本目录,与 scope 零重叠,主进程 P1 复扫确认）
**FMEA**: RPN 前列=SKILL 行数级联断裂（既有 -le 435 目标线+435→435+净增;兜底=级联值以 wc 实测为准+P2-S2 输入列携 P1 实测）;「Rules 1-39」字面 2 处保全（兜底=括注形态改写,S2 验收 grep=2 硬断言）
**Batch Report**: 八字段填 0 值零单元声明（v097/v098 先例,非批量任务禁填 n/a——check-complete 18.6 门 n/a 判缺项）
**Decisions Made** 必含行: silent: plan-writer 档位死亡（reasoning-level-missing 实测）→executor 接管撰写（22.3④+25.3 白名单⑤,接管先于派发登记）;silent: push 授权=用户 09-30 持久指令沿用;silent: 模板/契约改动新会话生效
**Handoff 表**: 第 1 行=plan-writer→executor 接管记录（纯 token 列,禁括号模型后缀）;后续行=P2/P3/P5 派发占位

## knowledge-brief.md 五段
§1 速览（任务一句话+Rule 42/43 各一句）;§2 已验证事实（你的全部实测数字,带命令）;§3 文件锚点表（8 scope 文件+行号+≤10 行摘要）;§4 易错点（级联字面锚/1-40 禁引入/registry 双向一致/Total 行双形态/push 前只读预检 origin 领先量）;§5 S-unit 材料包索引（P2-S1/S2、P3-S1/S2 各读 brief 哪节+仓内哪文件哪段）

## 验收（写完自查,证据写检查点）
a) task_plan.md 含 5 Phase,每 Phase Status+Executor+S-unit 表（带建议档位列）;b) VC=6;c) 模板感知区块（文件末尾,若 init 已追加则保留勿删）;d) knowledge-brief 五段非空;e) `grep -c 'Rules 1-39'` 你在 brief 记录的值;f) 全文禁字面「1-40」

## 检查点
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v099-reliability-institution/subagent-state/02-executor.md（实测数字+写入文件清单+验收 a-f 逐条）。

## 返回 8 字段（标签逐字）
status: / phase: / completed_steps: / files_written: / evidence: / issues: / next_step: / self_check:
