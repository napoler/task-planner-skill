# Delivery Summary — task-v163-proactive-research

## 说明

Rule 75「网络调研主动激活与外部数据依赖纪律」完整落地。将用户核心诉求「遇问题先检索不本地死磕/计划期三态分析/GitHub+浏览器强制/模板调研触点」制度化为七子条（75.0-75.7）+ 计划期载体（模板区块+契约行+advisory）+ 模板层定制（4 variant 触点+plan-template-kit §2.6 判定条目）+ 机器守护（selftest 15 断言+registry+级联 1-75+C54 合规行）。CR APPROVED，回归 76/76 PASS，三部署位 IDENTICAL。

## 产出

### 新增文件（1）
- `skills/task-planner/scripts/selftest-proactive-research.sh` — 15 断言（PR-01..15）静态守护 Rule 75 子条锚/模板区块/契约行/advisory 段/guide §2.6/registry 自登记/config 零新键

### 修改文件（33）
- `skills/task-planner/references/critical-rules.md` — Rule 75 七子条（75.0-75.7）EOF 追加，+20 行
- `skills/task-planner/SKILL.md` — 三处计数位 1-75 + Rule 75 摘要 bullet + C54 合规行，+2 行
- `skills/task-planner/templates/task_plan.md` — 「🔍 调研需求与检索计划（Rule 75.1）」区块，+10 行
- `skills/task-planner/companion/agents/plan-writer.md` — Rule 75.1 契约行，+2 行
- `skills/task-planner/scripts/check-plan-dispatch.sh` — Rule 75.1 advisory 段（非 mini 缺区块→WARN），+13 行
- `skills/task-planner/templates/subagent_dispatch.md` — 反死磕触点行（Rule 75.2），+1 行
- `skills/task-planner/templates/variant/research-type.md` — 三态判定+现成方案触点，+3 行
- `skills/task-planner/templates/variant/code-edit-type.md` — GitHub/现成方案检索触点，+2 行
- `skills/task-planner/templates/variant/script-dev-type.md` — GitHub 现成实现检索触点，+2 行
- `skills/task-planner/templates/variant/deployment-type.md` — 官方文档/现成方案优先触点，+2 行
- `skills/plan-template-kit/references/template-guide.md` — §2.6 新模板调研需求判定条目，+13 行
- `skills/plan-template-kit/references/template-mapping.md` — Rule 75 注记，+1 行
- `skills/task-planner/scripts/selftest-registry.tsv` — selftest-proactive-research.sh 登记行，+1 行
- 11 个宽容锚 selftest 脚本 — 锚正则扩展至覆盖 75 纪元
- `CHANGELOG.md` / `CLAUDE.md` / `README_zh.md` — 计数标签+条目

## 审查详细

### CR Gate（2 轮）
- **Round 1**：CHANGES_REQUESTED — C52 撞号（master C52=Rule 72）+ 75.7 自述锚错位（C51→C53）+ subagent_dispatch.md 触点行缺失
- **Round 2**：APPROVED — C53→C54 修正 + 75.7 自述锚 C53→C54 + subagent_dispatch.md 反死磕触点行落盘

### 回归验证
- 全量 76 脚本 76/76 PASS（1084 断言 FAIL=0）
- selftest-proactive-research.sh 15/15 PASS
- 三部署位（zcode/claude/opencode）diff=0

### 对齐审计
- SKILL.md 计数位 1-75（三处）
- 合规清单 C50(Rule71)/C51(Rule74)/C52(Rule72)/C53(Rule73)/C54(Rule75)
- critical-rules.md Rule 71/72/73/74/75 连续
- 宽容锚覆盖 75 纪元

## 风险必须列举

1. **Rule 73 欠账已关闭**：master 已有 `### 73`（v156 落地），worktree 声明「1-75」名实相符
2. **master 前进合并风险**：master 已前进 5+ 提交（v162/v164/v165），已通过并集解解决 12 文件冲突
3. **zcode 部署位手动部署**：smart-merge-back 对 `/home/terry/.zcode/skills/task-planner`  REJECTED（受保护路径），已手动 rm+cp 部署
4. **行为面冒烟待验证**：Rule 75 的实际行为效果（计划期三态分析是否触发/执行期反死磕是否生效）需后续任务实战验证

## 下一步建议

1. **行为面冒烟**：后续任务中观察 Rule 75.1 计划期三态分析是否触发、75.2 反死磕是否生效
2. **模板生成实战**：plan-template-kit §2.6 判定条目在新模板生成时是否被消费
3. **持续回归**：Rule 75 守护脚本纳入常规回归基线
