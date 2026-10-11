# task-v138 / agnes-quota.sh + capability-registry.md 实施规格（P3-S1 任务书材料）

> 消费者：executor（P3-S1）｜权威源：findings.md [sub:05]/[sub:06] + design-brief §3.1/§3.3｜生成：主进程 2026-10-05

## A. agnes-quota.sh 规格（缺一即返工）

1. bash + curl；头注释 What+Why 双层（Rule 45）：
   - What：用途（Agnes 账户额度直查）/ 用法（`bash agnes-quota.sh`，无参数；可选 `--json` 输出纯 JSON）/ 退出码（0=取到数据；3=全部 key 候选无效；4=端点不可达）
   - Why：Rule 55「可复用能力落盘纪律」首个实例（task-v138 2026-10-05）；判例一=耗时累计推算反模式（用户 R3 原话见 plans/task-v138/task_plan.md 🎯 区块）；判例二=S2b 探针教训「CDN 缓存态 200 冒充鉴权证据」→ 故全请求强制绕缓存
2. key 候选链（按序）：env `AGNES_API_KEY` → env `AGNES_API_TOKEN` → env `APIHUB_AGNES_API_KEY` → `grep -E "^export AGNES_API_KEY=" "$HOME/.bashrc" | head -1` 提取去引号。key 全程脱敏输出（前 6 后 4），来源名记为 env:AGNES_API_KEY / bashrc:export。
3. key 校准（零成本鉴权控制组，每候选一请求）：
   `GET $BASE/agnesapi?video_id=probe-nonexist-<随机串>&model_name=agnes-video-2.5-flash&_=<epoch_ns>`
   - HTTP 401（无效的令牌）=该候选无效 → 试下一候选
   - 任何**非 401**（预期 404 任务不存在）=该候选通过鉴权 → 定为工作 key
   - 全候选无效 → exit 3，输出指引（检查 ~/.bashrc export AGNES_API_KEY 或更新 env）
4. 直查（校准通过的 key，≤2 请求）：
   - `GET $BASE/v1/dashboard/billing/subscription?_=<ns>`
   - `GET $BASE/v1/dashboard/billing/usage?start_date=<今日 YYYY-MM-DD>&end_date=<明日>&_=<ns>`
5. **全请求绕缓存**：头 `Cache-Control: no-cache` + `Pragma: no-cache` + 随机 `?_=`（判例二固化）。
6. 输出（人读 + `--json` 机读两形态）：key_source（脱敏）/ endpoints_reachable / subscription 原始字段 / usage 原始字段 / verdict 行。**必须**含判定行：limit 为 1e8 占位或 total_usage=0 时输出「计费层数据未填充：剩余额度不可由本 API 推出；权威面=登录仪表板 Usage/Billing；HTTP 402=配额耗尽事后信号」。
7. **禁止**输出 `hard_limit_usd - total_usage` 之类「剩余额度」计算值（Rule 55.2 禁二次推算；推算值冒充直查=本规则立法对象）。
8. `BASE="https://api.agnes-ai.cn"`（禁 apihub 域，恒 401 陷阱）；curl 全程 `-fsS --max-time 15`；端点连续失败 → exit 4。
9. 禁硬编码密钥：`grep -icE 'sk-[a-z0-9]|cpk-'` 必须=0（注释示例用 `<KEY>` 占位）。
10. 稳健性：bash -n 通过；无裸 except 式静默（curl 失败必须显式报错分支）；`set -u` 可用酌情。

## B. capability-registry.md 规格

- 标题：`# 能力注册表（capability-registry — Rule 55.4 唯一索引）`
- 用途说明一段：消费方=Rule 55.1 复用前置检查（执行可复用操作前必查本表）；维护方=Rule 55.3 首次成功即落盘（新增行 8 列必填，verified 日期=实测通过日）；部署随技能三宿主同步。
- 表头 8 列：`| 名称 | 脚本路径 | 用途 | 调用方式 | 数据来源端点 | 输出形态 | verified 日期 | 任务来源 |`
- 首条：名称=agnes-quota；脚本路径=`scripts/capabilities/agnes-quota.sh`；用途=Agnes 账户额度/计费层直查（含 key 候选链+鉴权校准+缓存绕过；计费层未填充时如实报告不推算）；调用方式=`bash scripts/capabilities/agnes-quota.sh [--json]`；数据来源端点=`/v1/dashboard/billing/{subscription,usage} + /agnesapi（校准）`；输出形态=人读+--json；verified 日期=2026-10-05；任务来源=task-v138
- 首条行 8 列不得空列。
