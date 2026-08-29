# Completion Gate — 子代理验证

> 与 critical-rules.md Rule 5/6 互补。核心：subagent "done" ≠ 完成，必须 Read 验证。

## 验证协议

1. **等通知** — 不轮询，等系统 notification
2. **Read 实际文件** — 验证声称的变更确实存在（路径+行号+内容）
3. **标记 complete** — 仅验证通过后，Edit plan checkbox `- [ ]` → `- [x]`
4. **验证失败** — 不标记 complete，派 subagent 修复

## 证据要求

Claims of "done" without evidence = FAILED。必须有：
- 文件路径 + 行号
- 验证输出（命令结果/文件内容）
- Before/after 对比（适用时）

## 并行任务同步

```
Wave 1 (并行) → [全部验证 complete] → Wave 2 (串行)
```

- 启动前存 session_id
- 等 ALL notification 到达
- 每条结果单独验证
- 任一失败 → 不进入 Wave 2

## 失败处理

- 验证失败 → 不标 complete，派 subagent 修复
- 同一 V-N 重试 3 次 FAIL → AskUserQuestion（escalation_threshold）
