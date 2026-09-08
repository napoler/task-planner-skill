<!-- subagent_dispatch.md — Agent() 派发 prompt 模板(Rule 22.4)
使用方式:在主进程脚本中读本模板,填九字段,作为 Agent() 的 prompt 参数传入
禁止:省略任何必填字段;字段值使用占位符 {placeholder} 形式,调用方替换 -->

# Subagent Dispatch Prompt

## 1. 目标
{goal_one_sentence}

## 2. 输入
- 计划三文件(必传,绝对路径 — Rule 22.4a 读写契约):
  - task_plan: {plan_dir}/task_plan.md — 只读(对齐 Goal/VC/Scope/S-unit 表;状态由主进程翻转,禁止修改)
  - findings:  {plan_dir}/findings.md  — 可读;可写 = 仅追加自己的小节 `#### [sub:{seq}-{type}] <标题>` 到 `## Research Findings` 段末尾(在 `## Technical Decisions` 前插入),禁止改动既有内容
  - progress:  {plan_dir}/progress.md  — 可读;可写 = 仅在当前 Phase 段「Actions taken」下追加 `  - [sub:{seq}] <摘要>`(用含 Phase 标题的唯一上下文 Edit),禁止改 Status/Started
- 材料包绝对路径(取自 S-unit 表「输入」列):
  - {path_1}
  - {path_2}
- findings.md 相关摘要(≤10 行):
  ```
  {findings_excerpt}
  ```
- 上下文依赖:{context_dependencies}
- 材料包来源:取自 task_plan.md 该 Phase S-unit 表「输入」列(计划期预写);此处只填路径 + ≤10 行摘要,总量受第 9 节预算约束

## 📚 必要知识储备上下文包（随 prompt 注入 — prompt 自包含要求）
<!-- WHAT: 派发子代理时必须注入的知识源;全文摘录或路径引用,保证子代理无会话记忆也能对齐知识库 -->
| 知识源 | 定位(路径/URL) | 注入方式(全文摘录/路径引用) |
|--------|---------------|---------------------------|
|        |               |                          |

## 3. 验收标准(2-5 条可观察证据)
- [ ] {acceptance_1}
- [ ] {acceptance_2}
- [ ] {acceptance_3}
- [ ] {acceptance_4}(可选)

## 4. Scope 禁改清单
- 禁止修改:{forbidden_path_1}, {forbidden_path_2}
- 禁止操作:{forbidden_op_1}, {forbidden_op_2};默认禁止 git 写操作(add/commit/checkout/reset),只读 git diff/status/log 允许

## 5. 工作路径
- worktree 绝对路径(若在 worktree 中):{worktree_abs_path}
- 否则 cwd:{cwd}
- 注意:不要切换 CWD,使用绝对路径操作文件

## 6. 时长预算
- 任务类型:{type} → 超时阈值:{timeout_minutes} 分钟
- 超过阈值:立即返回 partial,报告未完成部分

## 7. 返回格式(严格 — Rule 22.4b:8 个固定字段,逐字段填写,字段名与顺序不得改,不得增删,无内容填 none;**8 字段之后不得有任何内容**——备注/说明一律写进 blockers 或检查点)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS 3:FAIL(<≤20 字原因>) ...]
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:{seq}-{type}]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
已填示例(照此逐字段,不加标题/前言/总结):
```
status: done
acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
files: /abs/worktree/skills/task-planner/references/critical-rules.md(+1/-1)
evidence: critical-rules.md:114 含 "21.1b"; wc -l → 209
checkpoint: /abs/plans/task-x/subagent-state/02-executor.md (status: done)
findings_written: findings.md #### [sub:02-executor] 21.1b 落地
blockers: none
confidence: HIGH
```
主进程侧:收到缺字段/自由文本 → 视为 partial,以第 8 节检查点「最终结论」段(同一 8 字段块)为准(Rule 22.8.5)

**返回前必做**:
1. Read 实际产出文件确认变更落盘
2. `files:` 列出所有修改的绝对路径(供主进程登记),含按 §2 契约追加的 findings/progress
3. 若 failed:`blockers:` 写失败原因,检查点「错误与受阻」段写已尝试方案(供主进程决策拆细/改派/降档)
4. 将同一 8 字段块写入第 8 节检查点「最终结论」段并置 status(Rule 22.8.2 T5)

## 8. checkpoint 落盘路径(强制 — Rule 22.8)
- 检查点文件:{checkpoint_path}(约定 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`)
- 落盘纪律(执行中必守):
  - T1 每完成一个文件的 Edit/Write → 立即追加里程碑行(带时间戳)
  - T2 每次搜索/调研得出结论 → 立即追加
  - T3 中间判断/决策(根因定位、方案取舍)→ 立即追加
  - T4 遇错无法继续 → 写「错误与受阻」段(现象 + 已尝试方案),置 status: failed
  - T5 任务结束 → 写「最终结论」段(= 第 7 节同一 8 字段块,逐字段),置 status: done(必做,防返回消息丢失)
- 检查点文件格式:头部 status 行 + 已完成里程碑(append-only 带时间戳) + 进行中 + 产出文件清单 + 错误与受阻 + 最终结论;纯 markdown,无 frontmatter

## 9. 上下文预算(强制 — Rule 22.4 第 ⑨ 字段,小模型短上下文友好)
- 本 prompt 总长 ≤ `config.json#subagent.prompt_max_chars`(默认 3000 字符);超出 = 材料没在计划期拆好,回 S-unit 表把输入拆成"路径 + ≤10 行摘要"再派
- 只注入本 S-unit 所需材料:路径 + 摘要;**禁止**贴 task_plan.md / findings.md 全文或大段源码
- 子代理侧:只 Read 本节列出的路径/区段,不做计划外探索;疑问按第 4 节 Scope 处理,不扩读

## 附:resume_from 注入模板(主进程专用 — Rule 22.8.4)
<!-- 子代理 failed/timeout 后,主进程 Read 检查点文件,有实质进度时把下段填好复制进重试 prompt -->
## 断点续做(resume_from — 禁止重做已完成部分)
前次执行中断于:{status + 最后一条里程碑}
已完成(禁止重做):
- {里程碑摘录}
已有产出文件(直接复用/在其上续写):
- {清单}
剩余任务:
- {按原验收标准推算}
