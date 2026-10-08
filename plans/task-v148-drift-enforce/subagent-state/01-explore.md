# Checkpoint — 01-explore（防偏移机制面盘点与失效取证）
- 时间: 2026-10-08 11:33（完成）| 执行体: Explore（mini）| 主进程代落盘（子代理只读未写盘，返回消息全文已蒸馏至 findings.md 同名小节）
- 状态: complete | Token: ~1.42M | 工具调用: 46 次

## 最终结论（主进程复核 findings.md 回填后 verify_done=☑）

1. **机制面 18 项：机械强制 2 / 软性 16**。机械力仅 check-drift.sh（exit 1，但 61.5 降级佐证位、正常流程不跑）与 selftest-drift-check-subagent.sh（DCS-01~20 守措辞不守行为）。
2. **drift-check 实际执行率 0%**：task-v141~v145 计 25 Phase / 85 todo，drift-checker 检查点 0 个、[DRIFT CHECK] 记录 0 处；全 plans/ 93 任务唯一正例=task-v085 progress.md:39 手工三问。
3. **根因三连**：①触发无机械计数器/hook（软触发不可靠实证）②判定无机器消费（ledger-append.sh:28 VALID_EVENTS 无 drift 枚举；check-3file-gate/check-complete 不校验；Drift Log 纯模板）③selftest 守措辞不守执行。
4. **历史偏移实例**：task-v075:215 / task-v096:107 / task-v095:130 / task-v079:142——偏移真实发生，靠 [plan-compass] 等旁路兜住而非 drift-check 检出。

## 关键接线锚点（64.x 挂载位）

| 锚 | 文件 | 挂载物 |
|----|------|--------|
| H1 | zcode-posttooluse.sh | 64.3 节奏计数器（v068 注入+会话节流先例） |
| H2 | check-3file-gate.sh | 64.2 Phase complete 第三条件 |
| H3 | ledger-append.sh:28 | VALID_EVENTS 增 drift_check |
| H4 | （无新 config 键） | env TASK_PLANNER_DRIFT_ENFORCE=warn\|off 降档口 |
| H5 | check-complete.sh | 终验 drift 统计（可选 P2） |
| H6 | zcode-userpromptsubmit.sh | [plan-note] 已有软提醒（不动） |
| H7 | selftest-drift-check-subagent.sh | 新 selftest 扩展位（新建 selftest-drift-enforcement.sh） |

## 断点续做指引
本检查点即终点产物；后续消费方=Phase 2 条款设计（读 findings.md 同名小节+本文件即可）。
