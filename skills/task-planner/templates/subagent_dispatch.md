<!-- subagent_dispatch.md — Agent() 派发 prompt 模板(Rule 22.4)
使用方式:在主进程脚本中读本模板,填九字段,作为 Agent() 的 prompt 参数传入
禁止:省略任何必填字段;字段值使用占位符 {placeholder} 形式,调用方替换 -->

# Subagent Dispatch Prompt

## 1. 目标
{goal_one_sentence}

## 2. 输入
- 绝对路径:
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
- 禁止操作:{forbidden_op_1}, {forbidden_op_2}

## 5. 工作路径
- worktree 绝对路径(若在 worktree 中):{worktree_abs_path}
- 否则 cwd:{cwd}
- 注意:不要切换 CWD,使用绝对路径操作文件

## 6. 时长预算
- 任务类型:{type} → 超时阈值:{timeout_minutes} 分钟
- 超过阈值:立即返回 partial,报告未完成部分

## 7. 返回格式(强制)
```
[done|partial|failed|timeout]
结论摘要(≤3 行):{conclusion}
证据(file:line):{evidence}
置信度:HIGH|MED|LOW
未完成/受阻点(若有):{blockers}
```

**返回前必做**:
1. Read 实际产出文件确认变更落盘
2. 列出所有修改的文件路径(用于主进程登记)
3. 若 failed:写明失败原因 + 已尝试的方案(供主进程决策改派/降档)
4. 将最终结论写入第 8 节检查点路径并置 status: done(Rule 22.8.2 T5)

## 8. checkpoint 落盘路径(强制 — Rule 22.8)
- 检查点文件:{checkpoint_path}(约定 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`)
- 落盘纪律(执行中必守):
  - T1 每完成一个文件的 Edit/Write → 立即追加里程碑行(带时间戳)
  - T2 每次搜索/调研得出结论 → 立即追加
  - T3 中间判断/决策(根因定位、方案取舍)→ 立即追加
  - T4 遇错无法继续 → 写「错误与受阻」段(现象 + 已尝试方案),置 status: failed
  - T5 任务结束 → 写「最终结论」段(同第 7 节返回格式),置 status: done(必做,防返回消息丢失)
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
