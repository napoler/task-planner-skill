# 双轮质检任务书（只读审查）— task-todo-default-engine-20261123

## 1. 背景（自包含）
任务修复用户投诉的三缺陷：① 默认 worktree 却多会话争夺写同一文件；② 发现同写冲突不走 worktree 补救；③ OpenSpec/Superpowers 已声明为引擎却从未激活。方案 A：todo 基线组 B1-B5→B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验，B1-B5 逐字保留）+ 冲突补救 SOP + 三层载体（产出器/模板/守护）。用户明确"之前添加的东西不要丢弃"。

源仓：/mnt/data/dev/task-planner-skill
commit：f55507e（9 文件）；部署位：~/.zcode/skills 与 ~/.agents/skills（已授权，18 位 diff=0）
计划目录：/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/

## 2. 审查维度（逐条给证据，只读不改）
1. **守正（最高优先）**：B1-B5 五条定义在 todo-sync.md 与 critical-rules-discipline.md 是否**逐字保留**（对照 git show f55507e^ 的原句 diff）；有无删改。
2. **B6/B7/B8 齐备**：四处锚（todo-sync.md 唯一事实源 / Rule106.5 语义锚 / task-planner SKILL.md 指针 / task-discipline SKILL.md 索引）是否都含 B6/B7/B8；SKILL.md 是否 ≤470 行（应 461）。
3. **三层载体真实性**：sync-todos.sh --json 是否真输出 8 个 B 组条目（实跑 python3 解析）；模板是否露出 B1-B8；selftest 是否含 B6 锚断言（实跑 3 个 selftest 应全 PASS）。
4. **冲突补救 SOP**：worktree-isolation.md §6.4 是否含"同写冲突补救"锚 + 补建隔离→迁移→隔离内改→smart-merge-back 四步。
5. **越界残留**：9 文件 diff 中有无任务书外的内容（已知一次 S3 越界插入"默认文件系统读写对照表"已被清除，确认未复活）；有无残留 TODO/占位。
6. **部署一致性**：源仓 9 文件与 ~/.zcode/skills 及 ~/.agents/skills 对应位是否 diff=0（逐位实测）。
7. **计划自洽**：plan-state.json 的 vcs 7 条全 pass、phases 5 条全 complete、decisions 含 D-WT/D-DEPLOY、attest 未因改动失效（--verify exit 0）。

## 3. 验收方式
实跑命令取证，贴原始输出行；禁止采信声明或 checkpoint 转述。发现任一 P0/P1 缺陷即 FAIL 并列出 file:line；全部通过给 PASS。

## 4. 返回契约（8 字段）
status / acceptance（7 维逐条结论）/ files（读过的绝对路径）/ evidence（命令+原始输出行）/ checkpoint（写完整记录到 /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/QC-report.md）/ findings_written / blockers / confidence

## 5. 边界
只读审查 + 唯一写 QC-report.md；不改任何产物、不提交、不部署。
