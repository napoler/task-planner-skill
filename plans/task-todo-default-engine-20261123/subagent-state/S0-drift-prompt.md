# 偏移检查任务书（drift-checker）— task-todo-default-engine-20261123

## 1. 背景与判定对象
本会话用户 /goal 两条原话已逐字落盘（append-only）：
`/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/user-session-log.md`（#1 主指令 / #2 todo 默认项新思路 / 理解镜像配对）。

当前执行方向（主进程自述，需你独立对照原话核实，禁采信转述）：
- 方案 A = 把 todo 基线组 B1-B5 **扩为** B1-B8（B6 引擎检测 / B7 对齐核查 / B8 worktree 核验），既有 B1-B5 逐字保留，叠加而非替换。
- 补"冲突补救 SOP"（检出同写冲突→补建 worktree→迁移未提交改动→后期 smart-merge-back）。
- 修三层载体：sync-todos.sh `--json` 产出 B 组 / task_plan.md 模板露出 / selftest 守护加锚。
- 本计划自身用 OpenSpec 规格化（worktree 内 init + change + 4 artifacts，validate PASS）。
- 当前阶段：计划独立审计门第三轮复审后台进行中；未进入 S1-S7 实施。

## 2. 三态判定（Rule 15/61）
读原话全文 + 计划三文件（`task_plan.md` / `progress.md` / `findings.md`，均在上述计划目录）+ `plan-state.json` + 必要 git 证据，判定：
- **ALIGNED**：当前方向与用户原话一致，可继续。
- **DRIFTED**：存在偏移（列出原话锚句 vs 当前动作 vs 已改文件，逐条）。
- **CONFUSED**：方向不明，需写会话交接文档。

**重点核对四条硬约束**（任一违反即 DRIFTED）：
1. "之前添加的东西不要丢弃" → B1-B5 是否逐字保留、叠加而非重写。
2. "当前项目的核心定位…长文本/知识体系/记忆体系的记录，不要本末倒置" → 改动是否守住文档/规则/记忆体系而非跑偏到业务逻辑。
3. "依赖 todo 引擎来推进，因为最简单" → 是否避免扩张为运行时 exit 非0 硬门 / 新增守护脚本（文本优先铁律）。
4. "OpenSpec 和 Superpowers 作为引擎，实际从未有效利用，必须深层修正" → 是否有真实激活证据（本计划 OpenSpec change 目录 4 artifacts），而非仅口头提及。

## 3. 返回契约（8 字段）
```
status: PASS | FAIL
acceptance: 三态判定（ALIGNED/DRIFTED/CONFUSED）+ 四条硬约束逐条结论
files: 实际读过的绝对路径清单
evidence: 执行的命令 + 原始输出行（逐字）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-drift.md（写入完整判定记录）
findings_written: yes/no
blockers: 无 或 具体偏移项
confidence: high | medium | low
```

## 4. 边界
只读判定 + 唯一写上述 checkpoint 路径；不修任何文件、不改计划、不进入实施阶段。空闲可读 `~/.zcode/skills/drift-checker` 或 task-planner Rule 61 了解三态口径，但判定依据以本任务书第 2 节为准。