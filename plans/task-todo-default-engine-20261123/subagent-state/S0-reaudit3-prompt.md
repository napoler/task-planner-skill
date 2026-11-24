# 第三轮独立复审任务书（critic）— task-todo-default-engine-20261123

## 1. 背景（自包含）
用户 /goal 要求修复项目方法论缺陷：① 默认走 worktree 仍多会话争夺写同一文件；② 发现同写冲突不走 worktree 补救；③ OpenSpec/Superpowers 已声明为引擎却从未激活。用户明定"依赖 todo 引擎推进=最简单方案"、"之前添加的东西不要丢弃"。方案 A（已自治定案）=把 todo 基线组 B1-B5 扩为 B1-B8（B6 引擎检测/B7 对齐/B8 worktree 核验）+ 冲突补救 SOP + 修三层载体（sync-todos.sh 产出器 / task_plan.md 模板 / selftest 守护），既有 B1-B5 逐字保留。

计划目录：`/mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/`
权威源：`plan-state.json`（4 个 MD 为 render 派生视图，禁手工 Edit）；知识底座：`knowledge-brief.md`（主进程单写者，非派生视图）。

## 2. 复审范围（**仅**以下两项，前两轮已收敛的 C/I/W 不再重提）
- **I-5（上轮 OPEN）**：`knowledge-brief.md` §1-§6 原全为 `{…}` 模板占位、§2 零已验证事实。主进程本轮已填实证内容。请盘上核实：§1 术语表、§2 每条事实带 file:line 或绝对路径证据锚、§3 文件锚点表、§4 易错点 + FMEA 兜底指针（本计划唯一 F1 rpn=75<100，须如实写"无 RPN>100 项"而非虚构）、§5 S-unit 材料索引、§6 强化技能清单——正文占位是否真正清零（HTML 注释里的模板说明文字不算占位）。
- **I-new（上轮 OPEN）**：S6（VC 全量复验单元）原 actions 只覆盖 VC-1..6、verify 只 6/6、计数 vcs=6。主进程已修。请盘上核实 `plan-state.json` 中 `s_units[S6].actions` 含 `VC-1..VC-7`、`verify` 含 `7/7`，并核对 `vcs` 数组长度为 7（VC-1..VC-7）。

## 3. 验收方式（反造谣铁律）
- 必须实际读盘 + 执行命令取证，禁止信任任何"已修复"声明或本任务书的转述。
- 复核命令建议（在 `/mnt/data/dev/task-planner-skill` 下）：
  - `grep -nE '\{[^}]*\}' plans/task-todo-default-engine-20261123/knowledge-brief.md`（正文占位应只剩 HTML 注释）
  - `python3 -c "import json;d=json.load(open('plans/task-todo-default-engine-20261123/plan-state.json'));s=[x for x in d['s_units'] if x['id']=='S6'][0];print(s['actions']);print(s['verify']);print(len(d['vcs']),[v['id'] for v in d['vcs']])"`
- 给出 verdict 前逐条对照第 2 节两项，任一项未闭环即 REJECTED 并指出盘上具体缺口；两项都闭环即 APPROVED。

## 4. 返回契约（8 字段，缺一不可）
以如下结构返回（纯文本，字段名逐字保留）：
```
status: PASS | FAIL
acceptance: 一项验收摘要（两项闭环状态）
files: 实际读过的绝对路径清单
evidence: 执行的命令 + 原始输出行（逐字，禁改写）
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-todo-default-engine-20261123/subagent-state/S0-reaudit3.md（写入你的完整复审记录）
findings_written: yes/no
blockers: 无 或 具体缺口（verdict=APPROVED 时必须为"无"）
confidence: high | medium | low
```
另在首行单独给出 verdict：`APPROVED` 或 `REJECTED (C<n> I<n> W<n>)`。

## 5. 边界
- 只读审查，不改任何文件（唯一允许写的是第 4 节 checkpoint 路径）。
- 不推翻前两轮已收敛结论，不扩展到实施阶段，不对未要求项发表意见。
- 你写 checkpoint 时使用 Write 工具（目录已存在）。