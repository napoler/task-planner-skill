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
