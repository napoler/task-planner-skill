# dispatch-examples.md — 派发示例与参考段（B-1 外置，task-v091 [2026-09-27]）

> 定位：本文件承载 `templates/subagent_dispatch.md` 外移的**示例与主进程参考段**（结构移动，零语义变更）。
> 消费方式（22.4b 修订口径）：派发 prompt 不附本文；仅当主进程断点续做（22.8.4）/STOP 上报（22.7.1）时 Read 本文相关段。
> 双向锚：本文 ↔ 22.4b 条款绑定，由 `scripts/selftest-dispatch.sh` DX-01..DX-03 静态断言守护（同 commit 不可拆分）。

<!-- 填写/使用指引 Why（task-v115 线C 补强，Rule 45.2/45.4）:
  ① 何时用: 本文不进派发 prompt（自 B-1 外置起,避免每次派发重贴 3 段示例吃上下文预算）;
     仅两种场景主进程按需 Read——子代理 failed/timeout 后断点续做取 §2 模板注入重试 prompt
     （22.8.4）;因子代理失败触发 STOP/BLOCKED 上报取 §3 模板（22.7.1）。
  ② 为何外置: 示例/参考段是低频消费材料（正常派发零参考,只有失败处置才用）,留在模板正文会
     推高 prompt 长度逼近 prompt_max_chars 上限（§9 预算）;外置后模板九字段主体保持精简。
  ③ 为何 §3 六字段缺一即拒: STOP 上报是失败链路唯一交接面,缺「已尝试档位清单/证据」字段
     = 摆烂上报,主进程无法判断剩余档位与根因,接收方有权拒绝受理——最小集即受理门槛。 -->

## 1. 已填 8 字段返回示例（压缩模板 §7「照此逐字段」的载体 — 不加标题/前言/总结）
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

> 注（task-v161）: 示例前后不加任何标题/前言/总结;本 8 字段格式优先于子代理 agent 定义中的任何输出模板(步骤进度/发现列表/任务交付报告/[BOOKKEEPING]),「返回格式」段禁填 ①②③ 任务要点清单——详见 templates/subagent_dispatch.md §7 追加三条与 references/critical-rules.md 22.4b 污染三面句

## 2. resume_from 注入模板（主进程专用 — Rule 22.8.4）
<!-- 子代理 failed/timeout 后,主进程 Read 检查点文件,有实质进度时把下段填好复制进重试 prompt -->
## 断点续做(resume_from — 禁止重做已完成部分)
前次执行中断于:{status + 最后一条里程碑}
已完成(禁止重做):
- {里程碑摘录}
已有产出文件(直接复用/在其上续写):
- {清单}
剩余任务:
- {按原验收标准推算}

## 3. STOP 上报模板（主进程专用 — Rule 22.7.1:6 字段最小集,缺任一 = 摆烂上报,接收方可拒绝受理）
<!-- 任何因子代理失败触发的 STOP/BLOCKED 上报必须逐字段填写;无内容项填"无"并给原因,禁止省略字段 -->
1. **失败子任务**:{Phase N / S-unit ID 定位}
2. **已尝试档位清单**(22.3 ①-④ 含 22.3.0 评估记录 与 22.3.3 逐档:动作 + 结果 + 失败原因):
   - ① 改派:{动作/结果/失败原因}
   - ② 拆细:{动作/结果/失败原因}
   - ③ 降档:{动作/结果/失败原因}
   - ④ 主进程接管:{动作/结果/失败原因}
3. **检查点路径 + 已落盘里程碑数**:{checkpoint_path}(里程碑 {n} 条;无检查点 = 违规,须说明)
4. **剩余未尝试档位或不适用原因**:{如 ③ 降档已至顶档,不适用原因:...}
5. **建议下一步**:{拆细方案 / 接管范围 / 所需决策}
6. **证据**:{file:line 或 命令→关键输出}

## 4. 同批不同 agent/模型派发示例（Rule 68.2/68.3 — 组内异构分摊，task-v153 [2026-10-09]）

<!-- 定位（Rule 45 What+Why 双层）:
  ① 何时用: 同一并行组（parallel_groups 声明制 21.4）内有 ≥2 个两两独立的 S-unit，
     且组内成员的 subagent_type(model) 需逐行具体化、至少一项互不相同（Rule 68.3 组内异构分摊）。
  ② 为何示例: 68.3 禁止「整组继承同一 Phase Executor」——把所有并行子任务交给单一
     agent/模型档位=资源消耗不可控（68.3 依据：workflow schema 级实证 subagent_model 为
     run 级单一字段）。本段以 p3-core 组三个并行单元为例，演示「同批不同 agent/模型」
     的混派 prompt 骨架（executor + code-assistant ×2），主进程派发时照此逐条调整。
  ③ 43.2 优先级: 最小可承载档位优先于异构——禁止为追求异构而升档/降档；同档可承载时
     优先按 agent 类型差异（专用体/通用体分工）实现异构，模型档位差异其次。 -->

以 p3-core 组三个并行 S-unit（三单元两两过 68.1 四问全 no）为例，三条派发 prompt 骨架如下。
每条均含 `[parallel-group:p3-core]` 组标记、组域写隔离声明（Rule 68.4）、验收三证据要点：

```
[parallel-group:p3-core] 单元 p3-a（脚本与守卫施工，专用执行体）
  子代理类型: executor（sonnet-1 档）
  任务范围: ……（目标/验收/验证三字段）
  组域写隔离: 只写 <plan-dir>/subagent-state/03-executor.md（checkpoint）与本单元 scope 文件
    {scope 文件绝对路径清单}；计划三文件（task_plan/findings/progress）状态列由主进程
    按组串行统一回写，本成员不得直接 Edit（Rule 68.4 单写者原则）
  验收三要点: ① 逐条贴出验收命令的原文输出行 ② 产物文件绝对路径+Read 复核证据
    ③ checkpoint 已落盘且含最终结论
```

```
[parallel-group:p3-core] 单元 p3-b（文档单元，通用代码执行体）
  子代理类型: code-assistant（haiku-1 档）
  任务范围: ……（目标/验收/验证三字段）
  组域写隔离: 只写 <plan-dir>/subagent-state/04-code-assistant.md（checkpoint）与本单元
    scope 文件 {scope 文件绝对路径清单}；计划三文件禁碰（同上一条 68.4 口径）
  验收三要点: 同上三证据（原文行 + 产物路径 + checkpoint 落盘）
```

```
[parallel-group:p3-core] 单元 p3-c（第二条文档工程，通用代码执行体）
  子代理类型: code-assistant（haiku-1 档）
  任务范围: ……（目标/验收/验证三字段）
  组域写隔离: 只写 <plan-dir>/subagent-state/05-code-assistant.md（checkpoint）与本单元
    scope 文件 {scope 文件绝对路径清单}；计划三文件禁碰
  验收三要点: 同上三证据
```

三单元异构口径=executor(sonnet-1) + code-assistant(haiku-1) ×2：agent 类型两分
（专用执行体 vs 通用代码体）即满足 68.3「至少一项互不相同」；同档可承载时优先按
agent 类型差异实现异构，不做档位级强行拉差（43.2 最小可承载档优先）。

组间串行（Rule 68.2，21.4 默认语义不回退）：p3-core 组未齐验收（组批验收三证据 22.5，
唯一 join 点 68.5）前，主进程不得派发后组（如 p4-*）；后组的前置依赖=前组验收通过。

「组内全同」后果：同组内 `subagent_type(model)` 列全部相同时，check-plan-dispatch.sh
68.6 advisory 档输出 WARN（不拒锁）——并行负载集中于单一 agent/模型档位，资源消耗
不可控；处理=按 68.3 调整组内分工（换专用体/通用体或可承载档位），而非升档迁就。
