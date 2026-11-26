---
name: task-dispatch
description: 子代理派发与拆分调度（子代理派发/拆分/并行调度/粒度门/伴飞/返回格式校验/执行体选型；返回格式与段结构归本技能，返回内容正确性与 Read 复核归 verification-gate）
allowed-tools: "Read, Write, Edit, Bash, Grep, Glob"
---

# task-dispatch — 子代理派发与拆分调度

## 定位

管「计划如何被拆分、派发、校验、调度」——子代理全生命周期的机器门控与执行纪律。

## 域边界

**管**：拆分粒度（Rule 21/59）、派发契约（Rule 22/25）、返回校验（Rule 22.4b/22.8）、并行调度（Rule 21.4/23/68）、专注度（Rule 46）、执行体选型（Rule 52）、冲突隔离（Rule 12/13）、代码编辑派子代理（Rule 14）、依赖分析（Rule 68.1）。

**不管**：
- 四文件内容本身（核心 task-planner，Rule 62）
- 执行诚实/错误闭环等通用纪律（task-discipline）
- 媒体制作（media-planner）

## 卫星路由：task-dispatch

域=子代理派发与拆分调度。规则全文见 `references/critical-rules-dispatch.md`（Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104,110）；触发：涉及子代理拆分/派发/并行/粒度校验/伴飞/返回校验/执行体选型/冲突隔离/依赖分析/双轮质检/使用点标注时 Read 该文件；关键词：critical-rules-dispatch Rule12-25-68 拆分 派发 并行 粒度校验 伴飞 返回校验。

## 规则索引

| 编号 | 标题 | 锚点 |
|------|------|------|
| 12 | 冲突即隔离（工作树默认首选） | `references/critical-rules-dispatch.md` |
| 13 | 子代理隔离强制（P0） | 同上 |
| 14 | 代码编辑必须派子代理（P0） | 同上 |
| 21 | 子任务拆分与模型分工（P0） | 同上 |
| 22 | 子代理规模限制与交接文件(P0) | 同上 |
| 23 | 并行任务检测与冲突规避(P0) | 同上 |
| 25 | 子代理委派门控（P0） | 同上 |
| 46 | 子代理单任务专注度（P0） | 同上 |
| 52 | 执行体专业化优先与覆盖矩阵维护（P0） | 同上 |
| 59 | 子代理拆分粒度硬门与技能伴飞纪律（P0） | 同上 |
| 68 | 计划期依赖分析、并行分组、组内异构分摊与组域写一致性纪律 | 同上 |
| 96 | 子代理激活默认档与并行推进强化（P0） | 同上 |
| 103 | 双轮质检与同步完整性审查（P0） | 同上 |
| 104 | 子代理使用点显式标注纪律（P0） | 同上 |
| 110 | 任务分级×模型档位强制匹配（P0） | 同上 |

## 脚本

| 脚本 | 用途 |
|------|------|
| `scripts/analyze-splits.sh` | S-unit 表三值列超限行拆分建议 |
| `scripts/check-subagent-return.sh` | 子代理返回 8 字段契约校验 |
| `scripts/check-rescue-chain.sh` | 兜底链完整性校验 |
| `scripts/subagent-fallback.sh` | provider 失败主动 fallback |
| `scripts/selftest-rescue-chain.sh` | 兜底链 selftest |
| `scripts/selftest-fallback.sh` | fallback selftest |
| `../task-planner/scripts/selftest-subagent-granularity-skill-escort.sh` | 粒度门+伴飞 selftest（机械层留守主技能，Rule 82） |
| `../task-planner/scripts/selftest-subagent-return.sh` | 返回校验 selftest（机械层留守主技能，Rule 82） |

## 参考文档

- `references/critical-rules-dispatch.md` — 15 条规则全文（索引表列 15 条：Rule 12,13,14,21,22,23,25,46,52,59,68,96,103,104,110；[2026-11-23 task-fix-all-20261123] 补齐 Rule 96/103/104 入表，对齐实际编号清单）
- `references/agent-coverage.md` — 执行体覆盖矩阵；触发：选择执行体/查阅覆盖矩阵或路由映射时；关键词：agent-coverage 覆盖矩阵 执行体路由。
- `references/dispatch-examples.md` — 派发示例；触发：需要派发示例/写派发 prompt 模板参考时；关键词：dispatch-examples 派发示例 模板。
- `references/split-pattern-library.md` — 拆分模式库；触发：需要拆分模式库/粒度拆分参考时；关键词：split-pattern-library 拆分模式 粒度。
