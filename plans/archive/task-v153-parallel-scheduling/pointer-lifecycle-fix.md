# Fix — plans/.active_plan 全局指针并行语义与生命周期缺陷（2026-10-10）

## 结论：全局指针「单值」=设计边界（非缺陷）；三处实态=真缺陷

- **设计边界（不是缺陷）**：`plans/.active_plan` 是单值文件（存一个 task id），结构上不可能表达「多任务并行集合」。并行支持在 side 指针层 `.active_plan_side/<sid>.active_plan`——每会话一 key 的 map 结构，N 会话并行天然成立（2026-10-07 fix-pointer-race 的架构本意：side 私有 > 全局 legacy 兜底 > mtime）。全局指针的定位=「无 sid 调用方（cron/纯脚本/Stop hook）」的兜底，不是并行集合的表达。
- **真缺陷 D1 生命周期孤儿**：全局指针无 owner、无 GC（set-active-plan.sh gc 只清 side 24h+sidmap）、无完成项移交 → 任务完成后指针留在已完成计划上；加 v150 锁定后被自身收尾提交修改（哈希 7d672276→55f844f），任何无 sid 消费者解析=PLAN TAMPERED 假警报（本会话 2026-10-09 21:34 被咬两次，根因链完整）。
- **真缺陷 D2 活跃会话缺 side 指针**：哨兵清单 181730a4/1cefd1cf/bc12ebe6/f183e5d5 四会话有 `.plan_required` 但无 side key → 带自身 sid 的解析 miss → 落全局/mtime → 该会话 hook 注入/check-dispatch 解析到他人计划（「随机串台」）。
- **真缺陷 D3 沿袭 sidkey 碰撞**：`plans/task-v156-drift-shield/.session-owner` 与 `plans/task-v157-error-fix-prompt-forge/.session-owner` 均=sesscbab959f…（=task-v153 会话的 SessionStart sidkey，CLAUDE_CODE_SESSION_ID 进程持久化沿袭）→ side「私有」键被多会话共享、最新写者赢 → 老会话 hook 注入跟随新会话计划（本会话 2026-10-10 03:0x 起注入的通用 Phase 1 模板即 v157 计划）。

## 本轮修复（最小、不动并行层）

- 原子写（tmp+mv）全局指针 → `task-v152-proactive-context`（在途任务中唯一 attest 哈希有效者，实测 STALE 判定其余四项）。
- 零触碰 side 指针四键；复验各 sid 解析不变（de2c5bba→v153、cbab959f→v157 沿袭、4ec328f→v152、无 sid→v152 兜底）。
- D2/D3 属会话自身 init 职责与技能层机制（越权代写=踩踏并行会话，§十一 禁止），只登记不改。

## 防复发提示词（三条）

### A — 指针体检（每次漂移检查附带/定期）
```
【目标】体检 plans/.active_plan 与 plans/.active_plan_side/* 一致性。
【判定】① 全局指针指向的计划：task_plan.md Status=complete 或 INDEX=complete
→ STALE（孤儿遗留，修=置空或指向哈希有效的在途任务，原子写 tmp+mv）；
② 该计划 attest 哈希现值≠锁定值 → sid-less 消费者将收 PLAN TAMPERED 假警报；
③ 对照 .plan_required_side 哨兵清单：有哨兵无 side 指针的会话=解析将串台，登记待其 init 自补。
【输出】体检表：指针|指向|状态(valid/stale/serial台)|处置。只读+改全局这单独一个文件的写权限。
```

### B — 任务完成项移交（每个任务 Phase 5 收尾清单加一行，未来超出现有模板先以人工纪律执行）
```
【完成项】若 plans/.active_plan 当前值==本任务 id：交付前将其移交——
优先置空（无 sid 消费者回退 mtime 最新=天然指向在途），或显式指向另一 attest 有效的在途任务；
移交动作+理由登记本计划 Decisions Made 一行。
```

### C — 新会话启动自检（init-session.sh 成功后）
```
【自检】cat plans/.active_plan_side/<本会话 sid>.active_plan 必须==本计划目录名；
不等=本会话 sid-less 解析风险，立即 bash scripts/set-active-plan.sh set <task> --sid <本会话 sid> 补齐；
同时 cat plans/.active_plan 记录移交前值（完成时按 B 移交）。
```

## 根治提案（需授权的后续任务，非本轮范围）

- 技能层：set-active-plan.sh gc 增加「全局指针指向已完成计划 >N 小时」清理规则；init-session 在 side 指针缺失哨兵命中时告警（D2）；
- sidmap/沿袭：同一 sidkey 被新 .session-owner 声明时，旧指针移交或拒绝（D3）；
- Index：哨兵-side 缺口人工巡检可脚本化。
