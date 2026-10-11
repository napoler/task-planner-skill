# P2-S1 任务书: review-library/alignment-review/SKILL.md（task-v101,池内第 11 个）

任务: worktree 内新建 `skills/task-planner/review-library/alignment-review/SKILL.md`（对齐/同步一致性审查技能）。禁 git commit/add。

## 计划三文件契约（22.4a）
- task_plan.md / findings.md: /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/（只读）
- progress.md: 同目录（子代理禁写）

## 范式源（第一步按序 Read）
1. /mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review/skills/task-planner/review-library/general-review/SKILL.md（S1 范式标杆）
2. /mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review/skills/task-planner/review-library/security-review/SKILL.md（领域化写法参照）

## 目标文件
/mnt/data/dev/task-planner-skill-worktrees/task-v101-alignment-review/skills/task-planner/review-library/alignment-review/SKILL.md（新建,50-70 行）

## 领域定义: 对齐/同步一致性审查
审查「一次变更后,所有关联产物是否同步更新」——跨文档、跨代码、跨配置、跨引用的一致性。

## 清单来源（重要——每条都有本仓真实案例背书,逐条撰写为可执行检查项）
1. 文档↔代码同步: 行为改了,README/API 文档/注释是否同步（案例: 42.2 三级→四级,42.5 注释不同步被 CR 抓）
2. 计数与枚举联动: 数量/列表类声明改一处,其余出现处是否联动（案例: RL-01 计数 10→11 级联、「10 类」枚举、SR-12 行数 40）
3. 引用完整性: A 引用 B（链接/锚点/路径/文件名）,B 改名/移动后 A 是否失效
4. 术语一致性: 同一概念多个称呼混用（如「三级/四级」措辞漂移）
5. 多副本/多部署位同步: 同一文件存在多个实体副本时是否全部更新（案例: 三部署位 diff 惯例）
6. 模板与实例同步: 模板改了,已生成实例是否需要回溯（案例: B 类澄清后 general-review 枚举未回溯,CR P1）
7. 变更日志与实际变更同步: CHANGELOG/INDEX 声称的变更与 git diff 实际一致
8. 版本对齐: frontmatter/版本号/日期声明与实际一致
9. 跨文件语义一致: 分散在多文件的同一规则表述不互斥（案例: CR 专项「43.2 档位词汇与路由表逐级对照」）
10. 守卫锚与被守护对象同步: selftest 断言锚随被守护文件变更级联（案例: SR-11/12 级联漂移两连发）
以上 10 条为最低集,可补强（如 i18n 对齐/schema 对齐）。

## 共同要求（对标范式）
- frontmatter: name: alignment-review + description 一句话
- 触发条件段: Rule 42.2 四级检测第④层命中+任务类型涉及跨产物变更/联动修改/多副本
- 证据要求段: 引「Rule 43.1」;对齐审查证据天然可机器化（grep 计数对照/diff 对照）——注明「本领域断言优先机器可复现命令」
- 输出合约: APPROVED/CHANGES_REQUESTED+P0-P2 分级（可注明: 用户可见面失效引用/声明与事实不符=P0）
- 来源注释行: `<!-- task-v101-alignment-review 兜底池成员 11/11;Rule 42.2 第④层消费;对齐/同步一致性领域 -->`
- 50-70 行;禁「1-4x」越界字面;禁动本文件外任何文件

## acceptance: 验收标准
1) 文件存在且 50-70 行;四要素标题各 ≥1;frontmatter name=alignment-review
2) 清单 `- [ ]` ≥10 且每条领域具体化（引用上方案例至少覆盖 10 条来源）
3) 「Rule 43.1」≥1;「APPROVED」「CHANGES_REQUESTED」各 ≥1;来源注释行在位
4) 「1-4x」越界字面零命中
5) `ls review-library/ | wc -l`=11
6) git status 仅该文件 untracked

## checkpoint
完成前写 /mnt/data/dev/task-planner-skill/plans/task-v101-alignment-review/subagent-state/01-exec-p2s1.md。

## 返回 8 字段模板（标签逐字保留）
status: done|failed|partial
phase: P2-S1
completed_steps: 逐条
files_written: 绝对路径清单
evidence: 命令输出摘要
issues: 无或明细
next_step: 一句话
self_check: 对照 acceptance 逐条
