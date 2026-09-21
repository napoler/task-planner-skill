# Knowledge Brief — task-v087-task-boundary（任务知识简略要点）

## §1 任务速览与核心概念
- 任务一句话：task-planner 新增「新任务边界判定」（Rule 8.1 D 类）——无关新指令开新 task_plan.md，不相干内容不混入既有计划
- 背景/动机：用户痛点=旧三分类（A/B/C）把「新任务」误判为 A/B，导致新任务内容混进当前计划

| 概念/术语 | 一句话解释 |
|-----------|-----------|
| D 类（新任务边界） | 新指令与当前 Goal/scope/交付物均无关联 → 开新计划目录，旧计划原样保留 |
| 纯追加子条 | 8.1 追加在 Rule 8 原文之后（行首 `8.1 `），不改 Rule 8 原文，避 v082 插入级联教训 |
| 静态守护 selftest | 只防条款误删（grep 锚），LLM 行为面（判定本身）无脚本可测 |
| 行数回归钉 | 4 个既有 selftest 的 SKILL 行数断言 552→555（v080/v075 先例同步模式） |

## §2 已验证关键事实

| 事实 | 证据 file:line / URL | 影响（对本任务执行意味着什么） |
|------|---------------------|-------------------------------|
| 基线全量=25 selftest 430 PASS/0 FAIL | worktree 循环求和实证（task-v087 执行前） | 改动后全量应为 441/0（+11 新断言） |
| UPS hook [plan-note] 注入点 | scripts/zcode-userpromptsubmit.sh:130 | 一行扩写文案，fail-open 语义不变 |
| Rule 8 原文 L26-27（插入锚） | references/critical-rules.md:26 | 8.1 追加在 `### 9` 之前 L28 空行后 |
| 三位部署位 | ~/.zcode、~/.claude、~/.config/opencode 的 skills/task-planner | smart-merge-back --deploy 后主进程 diff -r 亲验 |
| attestation 注释形态盲区已修（v086 S7） | selftest-plan-tier PT-28 | 本计划 frontmatter 用注释形态已可过 template-gate（实测 OK） |

## §3 关键文件锚点表

| 路径 | 行号 | ≤10 行摘要（该区段做什么） |
|------|------|---------------------------|
| worktree skills/task-planner/references/critical-rules.md | :26-30 | Rule 8 段 + 新增 8.1（判定三要素+处置四步+机制侧守护清单） |
| worktree skills/task-planner/SKILL.md | :210-232 | 用户新指令表加 D 行+判定顺序行；特判段「新增任务边界判定（Rule 8.1 — task-v087）」；C12 扩 D/A/B/C |
| worktree skills/task-planner/scripts/zcode-userpromptsubmit.sh | :9、:130 | 职责 3 注释联动 D 类；[plan-note] 文案加 D 判定指引 |
| worktree skills/task-planner/references/todo-sync.md | :46 | S5 hook 说明加 D 类分支（开新计划+旧 Todo 映射保留） |
| worktree skills/task-planner/scripts/selftest-task-boundary.sh | 全文 | TB-01..11 静态锚（新文件，11 断言） |

## §4 易错点与禁止假设清单
1. 纯追加 8.1 不可改写 Rule 8 原文（TB-04 钉子：`A/B/C 影响判定`+`A 无影响照常执行` 语义锚须在位）
2. SKILL.md 行数净增 4 行（551→555）必同步 4 个 selftest 行数断言 552→555（v075 先例：扩围漏改=假 FAIL）
3. hook 文案扩写不得破坏 JSON 输出（实测 jq -e 校验 additionalContext 合法）
4. 部署前必重跑全量（v079 教训：worktree 基 master 可能被并行会话推进；本轮基 c340219 已亲验）
- FMEA RPN>100 兜底指针：本任务最高 RPN=40（Phase 4 部署漂移→部署前重跑全量+STOP 报告），无 RPN>100 项

## §5 S-unit 材料包索引

| S-unit ID | 应读本 brief 哪节 | 额外材料路径 |
|-----------|------------------|-------------|
| P2 | §1 + §2 + §3 | /mnt/data/dev/task-planner-skill-worktrees/task-v087-task-boundary/skills/task-planner/ |
