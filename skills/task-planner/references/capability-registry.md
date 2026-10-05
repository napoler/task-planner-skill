# 能力注册表（capability-registry — Rule 55.4 唯一索引）

> 用途：本表是 task-planner 技能体系内「可复用能力」的唯一索引（Rule 55.4 固定位置与格式）。
> - 消费方：Rule 55.1 复用前置检查——执行任何可能已有落盘能力的可复用操作前，必须先查本表与 `scripts/capabilities/` 目录，命中即复用，禁止重新现场发明（Rule 55.2 权威来源优先）。
> - 维护方：Rule 55.3 首次成功即落盘——可脚本化操作首次正确执行后当次登记一行，8 列必填，`verified 日期` = 实测通过日。
> - 部署：随技能三宿主部署位（`~/.zcode`、`~/.claude`、`~/.config/opencode` 的 `skills/task-planner`）同步；合并回主分支后逐位 diff 应为 IDENTICAL。

| 名称 | 脚本路径 | 用途 | 调用方式 | 数据来源端点 | 输出形态 | verified 日期 | 任务来源 |
|------|----------|------|----------|--------------|----------|---------------|----------|
| agnes-quota | `scripts/capabilities/agnes-quota.sh` | Agnes 账户额度/计费层直查（含 key 候选链+鉴权校准+缓存绕过；计费层未填充时如实报告不推算） | `bash scripts/capabilities/agnes-quota.sh [--json]` | `/v1/dashboard/billing/{subscription,usage} + /agnesapi（校准）` | 人读 + `--json` | 2026-10-05 | task-v138 |
