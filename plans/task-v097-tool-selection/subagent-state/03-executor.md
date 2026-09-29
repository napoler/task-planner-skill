# Checkpoint — 03-executor (P2-S1)

status: done
timestamp: 2026-09-30
worktree: /mnt/data/dev/task-planner-skill-worktrees/task-v097-tool-selection

## 执行内容
在 worktree 内 `skills/task-planner/references/critical-rules.md` EOF（原 L391=39.7.3 末行）后纯追加 Rule 40「harness 工具面主动选择」节头 + 引言 + 40.1-40.6 六子条全文。未执行任何 git commit/add。

## 格式对齐
- 动前 Read L339-390（Rule 39 全节）：节头范式 `### 40 …（… — task-v097，目标：…）`、子条行首 `40.N **标题**：内容`（行首直接 40.N，无缩进）
- 语言风格对齐 Rule 39（「（Rule 36.5 纯增量）」「如实披露」「机制（零新 config 键）」表述）

## 验收实测输出（worktree 内命令原文）

### 1) grep -c '^40\.' = 6
```
$ grep -c '^40\.' skills/task-planner/references/critical-rules.md
6
```
逐子条位置（grep -n '^40\.' 截断显示）:
```
397:40.1 **工具面清单（六类 harness 执行工具面）**…
398:40.2 **计划期主动分析（「🧰 工具选择与编排」区块）**…
399:40.3 **/goal 对齐（映射指引 + 如实披露）**…
400:40.4 **workflow 编排计划期路径（建议登记面，非新增自动路由）**…
401:40.5 **机器校验边界（如实披露）**…
402:40.6 **机制（零新 config 键 — 与 task-v087/v088 同范式）**…
```

### 2) git diff --stat 仅 1 文件且纯增
```
$ git -C . diff --stat
 skills/task-planner/references/critical-rules.md | 11 +++++++++++
 1 file changed, 11 insertions(+)
```
deletions=0（`git diff` 中 `^-` 行仅 diff 头 `--- a/skills/...` 1 行，无内容删除行）。

### 3) L339-391 零变化
追加前 `wc -l`=391，追加后 `wc -l`=402（净增 11 行 = 空行 1 + 节头 1 + 引言 1 + 六子条 6 + 中间空行 2，实际 diff 显示 `11 insertions(+)` 全为追加段）；diff 变更集仅 L391 之后，L339-391（Rule 39 全节含 39.1 L373 原文）零变化。

### 4) 40.3 含「不可代调」披露措辞
```
399:…/goal 是用户侧 harness 会话命令，技能层不可代调、不可读取其运行态…
（397 行 40.1 ②亦含「不可代调」）
```

### 5) 40.6 含「零新 config 键」+「selftest-tool-selection.sh」
```
402:40.6 **机制（零新 config 键 — 与 task-v087/v088 同范式）**：…机器面 = `selftest-tool-selection.sh` 静态断言…
（grep -c 'selftest-tool-selection.sh' = 2：40.5 L401 + 40.6 L402）
```

### git status
```
 M skills/task-planner/references/critical-rules.md
```
（仅该 1 文件 modified，无新文件；未 commit / 未 add）

## 内容要点（六子条）
- 40.1 六类工具面：/workflow（CreateWorkflow 族）/ /goal 会话目标 / Agent 子代理 / 卫星技能（四 skill）/ MCP 平台工具 / 机械守卫脚本（Rule 25.3 白名单③）
- 40.2 「🧰 工具选择与编排」区块=standard/full 档必填（general 模板承载），逐 Phase 标注 + workflow 编排判定//goal 对齐两判定行必填；定位=Executor 上游分析记录不替代机器事实源；mini 档按 38.3 豁免
- 40.3 /goal 对齐=VC 证据源 + 交付时映射提示 + 如实披露不可代调/不可读运行态（Rule 35.2）
- 40.4 命中编排条件→🧰 区块登记「建议 CreateWorkflow」+ 39.4 并行豁免登记；未命中→维持 21.4 串行；39.1 原文不变、不新增自动路由
- 40.5 机器校验边界：🧰 区块 LLM 行为面不机器校验；守护=selftest-tool-selection.sh 静态断言
- 40.6 零新 config 键（与 v087/v088 同范式），消费侧=plan-writer 契约+general 模板区块+template-mapping 映射节

## 遗留/下一步
无遗留。下一步交 P2-S2（SKILL.md 四锚同步，需携带本检查点 + knowledge-brief §4 条 2/3 级联清单）。
