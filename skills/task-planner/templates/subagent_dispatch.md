<!-- subagent_dispatch.md — Agent() 派发 prompt 模板(Rule 22.4)
使用方式:主进程读本模板填九字段作 Agent() prompt | 已填示例与主进程参考段(例/Resume/STOP)外置 references/dispatch-examples.md 按需 Read [2026-09-27 task-v091 B-1] | 禁止:省略任何必填字段;字段值使用占位符 {placeholder} 形式,调用方替换 -->

# Subagent Dispatch Prompt

## 1. 目标
{goal_one_sentence}

## 2. 输入(计划三文件必传,绝对路径 — Rule 22.4a 读写契约)
- task_plan: {plan_dir}/task_plan.md — 只读(状态由主进程翻转,禁止修改)
- findings:  {plan_dir}/findings.md — 可读;可写=仅追加 `#### [sub:{seq}-{type}] <标题>` 到 `## Research Findings` 段末(`## Technical Decisions` 前),禁改既有内容
- progress:  {plan_dir}/progress.md — 可读;可写=仅在当前 Phase 段「Actions taken」下追加 `  - [sub:{seq}] <摘要>`,禁改 Status/Started
- 材料包绝对路径/来源:取自 task_plan.md 该 Phase S-unit 表「输入」列(计划期预写):{path_1} {path_2}(此处只填路径,总量受 §9 预算约束)
- findings.md 相关摘要(≤10 行):{findings_excerpt}
- 上下文依赖:{context_dependencies}
- 工具面提示（Rule 40）: 若该 S-unit 执行工具面非 Agent 子代理（如 workflow 编排/机械脚本/卫星技能）,须在本节注明所用工具与选择理由;「🧰 工具选择与编排」区块（计划内）是上游分析记录,本任务书按其结论派发。

## 📚 必要知识储备上下文包(随 prompt 注入 — prompt 自包含)
<!-- WHAT: 派发时必须注入的知识源;全文摘录或路径引用,保证子代理无会话记忆也能对齐知识库 -->
| 知识源 | 定位 | 注入方式 |
|--------|------|---------|
| {knowledge_brief}(`<plan-dir>/knowledge-brief.md`,任务知识简略要点) | §1-§5 五段:速览/已验证事实/文件锚点/易错点/S-unit 材料包索引 | 材料包段引用对应节锚点;brief 存在时必读其索引节(§5) |

## 3. 验收标准(2-5 条可观察证据)
- [ ] {acceptance_1} / {acceptance_2} / {acceptance_3} / {acceptance_4}(可选)

## 4. Scope 禁改清单
- 禁止修改:{forbidden_path_1}, {forbidden_path_2} | 禁止操作:{forbidden_op_1}, {forbidden_op_2};默认禁止 git 写操作(add/commit/checkout/reset),只读 git diff/status/log 允许

## 5. 工作路径
- worktree 绝对路径(若在 worktree 中):{worktree_abs_path} | 否则 cwd:{cwd}(不切换 CWD,用绝对路径操作文件)

## 6. 时长预算
- 任务类型:{type} → 超时阈值:{timeout_minutes} 分钟;超过阈值:立即返回 partial,报告未完成部分

## 7. 返回格式(严格 — Rule 22.4b:8 个固定字段,逐字段填写,字段名与顺序不得改、不得增删、无内容填 none;**8 字段之后不得有任何内容**,备注一律写 blockers 或检查点)
```
status: done | partial | failed | timeout
acceptance: <n>/<total> pass — [1:PASS 2:PASS ...]
   统计/测试类任务: acceptance 只准贴逐项原文行(如各脚本 rc= 与 Total: 行逐条列出), 禁止自报汇总数字——汇总由主进程逐行机械求和(子代理算术错已 5 次实证)
files: <绝对路径>(+N/-M); ... | none
evidence: <file:line 或 命令→关键输出行>; ...
checkpoint: <绝对路径> (status: done|failed)
findings_written: <findings.md 小节锚点 #### [sub:{seq}-{type}]> | none
blockers: none | <一句话>
confidence: HIGH | MED | LOW
```
> 步骤枚举约束(task-v081):prompt 内显式步骤枚举(StepN/步骤N/第N步/①-⑮,按序号去重)≤ config `step_max_steps`(默认 4);超限=回炉拆 S-unit 再派,check-dispatch.sh fine_grain_checks ④ enforce 档硬拦(任务书豁免场景对任务书文件同步计数)。
已填示例(照此逐字段,不加标题/前言/总结):见 references/dispatch-examples.md §1 [2026-09-27 task-v091 B-1 外置]
主进程侧:收到缺字段/自由文本 → 视为 partial,以第 8 节检查点「最终结论」段(同一 8 字段块)为准(Rule 22.8.5)
**返回前必做**:1. Read 实际产出文件确认变更落盘 2. `files:` 列所有修改的绝对路径(含 §2 契约追加的 findings/progress) 3. failed 时 `blockers:` 写原因+检查点「错误与受阻」段写已尝试方案 4. 同一 8 字段块写入第 8 节检查点「最终结论」段并置 status(Rule 22.8.2 T5)

## 8. checkpoint 落盘路径(强制 — Rule 22.8)
- 检查点文件:{checkpoint_path}(约定 `<plan-dir>/subagent-state/{seq}-{agent_type}.md`)
- 落盘纪律: T1 每完成一文件 Edit/Write → 追加里程碑行(带时间戳) / T2 搜索调研得结论 → 追加 / T3 中间判断(根因/取舍) → 追加 / T4 遇错无法继续 → 写「错误与受阻」段(现象+已尝试方案),置 status: failed / T5 任务结束 → 写「最终结论」段(= 第 7 节同一 8 字段块),置 status: done(必做,防返回消息丢失)
- 文件格式:头部 status 行 + 已完成里程碑(append-only 带时间戳) + 进行中 + 产出文件清单 + 错误与受阻 + 最终结论;纯 markdown,无 frontmatter

## 9. 上下文预算(强制 — Rule 22.4 第 ⑨ 字段,小模型短上下文友好)
- 本 prompt 总长 ≤ `config.json#subagent.prompt_max_chars`(默认 3000 字符);超出=材料没在计划期拆好,回 S-unit 表把输入拆成"路径 + ≤10 行摘要"再派 | 超限补救(Rule 35.3):拆细后仍超 → 大内容写入 <plan-dir>/subagent-state/{seq}-prompt.md 或材料包文件,prompt 只放「绝对路径+第一步 Read 该文件」指令,禁止失败收场/静默截断
- 只注入本 S-unit 所需材料(路径 + 摘要),**禁止**贴 task_plan.md / findings.md 全文或大段源码 | 子代理侧:只 Read 本节列出的路径/区段,不做计划外探索;疑问按第 4 节 Scope 处理,不扩读
<!-- resume_from / STOP 上报模板(主进程专用,Rule 22.8.4 / 22.7.1)已外置 references/dispatch-examples.md §2/§3 [2026-09-27 task-v091 B-1] -->
