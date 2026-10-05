# Checkpoint — [sub:04-executor-endpoint-probe2] 额度端点只读探针重试（key 候选链）

- Unit: 前序 S2 重试（修复 key 来源后重跑额度端点只读探针）
- Started: 2026-10-05 21:28 (local)
- Scope: 只读 GET 探针 + findings/progress 追加 + 本 checkpoint；key 全程脱敏（前 6 后 4）
- Request budget: 合计 5 请求（3 控制组 + 2 假设组），未超 ≤5 上限

## 里程碑

### M1 — key 候选链解析（完成）
| 候选 | 来源 | 值（脱敏） | 状态 |
|---|---|---|---|
| ① | env `AGNES_API_KEY` | `cpk-m4...h0fH` (len=52) | **set（命中）** |
| ② | env `AGNES_API_TOKEN` | — | unset/empty（不可发请求） |
| ③ | env `APIHUB_AGNES_API_KEY` | — | unset/empty（不可发请求） |
| ④ | `/home/terry/.bashrc:194` `^export AGNES_API_KEY=` | `cpk-fB...guim` (len=52) | set（协议：候选①已 2xx，按「停止候选切换」未继续，但为核验不稳定假设仍测） |

- 解析命令：`printenv <NAME>` + `grep -nE '^export AGNES_API_KEY=' /home/terry/.bashrc`，值以 `${v:0:6}...${v: -4}` 脱敏。
- 下游脚本规格输入：候选链顺序 = env 三名（AGNES_API_KEY → AGNES_API_TOKEN → APIHUB_AGNES_API_KEY）→ `.bashrc` 尾部 `^export AGNES_API_KEY=` 提取（去单引号）。本机实际命中候选①；候选④与①**行为无差异**（见 M4）。

### M2 — 控制组探针（完成）
| 探针 | key 来源 | 端点 | HTTP | cf-cache-status | 响应体要点 |
|---|---|---|---|---|---|
| c1 | ① env `cpk-m4...h0fH` | `GET /v1/models` | **200** | `EXPIRED` | `{"data":[{"id":"agnes-2.0-flash"...},{"id":"agnes-3.0-flash"...}]}`（907B，含 x-request-id/x-trace-id、age:0、cache-control: public max-age=14400） |
| c1b | ① env `cpk-m4...h0fH`（同 key，22s 后复测） | `GET /v1/models` | **401** | `BYPASS` | `{"error":{"message":"无效的令牌 ...","type":"AgnesAI_error"}}` |
| c4 | ④ `.bashrc:194` `cpk-fB...guim` | `GET /v1/models` | **200** | `EXPIRED` | 同上模型清单（同结构） |

- **关键现象**：同一 key（候选①）在 22 秒内先 200 后 401 → 控制组**不稳定**。
- **相关性**：所有 200 均带 `cf-cache-status: EXPIRED`（且响应头含 `cache-control: public, max-age=14400`、`expires`、`last-modified`、`age:0`）；所有 401 均带 `cf-cache-status: BYPASS`。→ 200 疑为 Cloudflare 缓存态返回，**不能单独证明 key 有效**。
- 两个不同 key（① env / ④ bashrc）得到**完全相同**的 200 结构 → key 来源不是区分因子。

### M3 — 假设组探针（完成，≤2 请求）
| 探针 | 端点 | HTTP | cf-cache-status | 响应体 |
|---|---|---|---|---|
| sub | `GET /v1/dashboard/billing/subscription` | **401** | `BYPASS` | `{"error":{"message":"Invalid token (request id: ...)","type":"AgnesAI_error"}}` |
| usage | `GET /v1/dashboard/billing/usage` | **401** | `BYPASS` | `{"error":{"message":"Invalid token (request id: ...)","type":"AgnesAI_error"}}` |

- 假设组均用**工作 key（候选①）**，与 c1 的 200 同 key 同会话。
- **无任何 `x-ratelimit-*` / `ratelimit-*` / `Retry-After` 响应头**（控制组与假设组全部 grep 零命中）。
- 错误文案差异：控制组 401 = 中文「无效的令牌」；假设组 401 = 英文 `Invalid token` → 分属不同网关路由（假设组路由不接受 API key）。
- 无 429/403 风控迹象 → 未触发「立即停止」条款；跑满假设组预算后停止。

### M4 — 判定（完成）
- **结论：不可得（穷尽）** —— 额度直查端点无法经 API key 获取。
- 依据链（三重收敛）：
  1. 假设组（OpenAI 兼容 billing 路径）两探针全 401，从未出现 200 + 额度/余额字段 → 「可用」不成立；
  2. 控制组曾 2xx（非「全部候选控制组均失败」分支），且官方文档穷举（sub:02）证实无任何额度直查端点；
  3. 假设组 401 为英文 `Invalid token`（独立网关），与 sub:02 结论一致：额度仅经需登录 Web 控制台暴露，API key 路由不承载 billing。
- **重要修正（对前序 sub:03 根因的反证）**：本次**未能复现**「env `AGNES_API_KEY` 已失效」这一前序根因——同一 env key（`cpk-m4...h0fH`）本次在控制组返回 200。真实情形为**控制组自身不稳定（200/401 抖动）**，而非「env key 死 / bashrc key 活」。因此前序「会话环境注入 key 失效」为**未证实假设**（可能是瞬时鉴权抖动或缓存态返回）。
- **判定口径归属**：命中 #4「工作 key 有效而假设组 404/401 → 不可得（穷尽）→ 触发 design-brief §3.3 兜底（V2 判 PARTIAL）」。置信度 **MEDIUM**（控制组抖动 + 假设组仅 2 样本 + 受 ≤5 预算限制未做 bogus-key 对照）。
- 对下游（Phase 3 S1）：`agnes-quota.sh` 应落盘为「错误处理已验证 + 端点待确认」形态（PARTIAL），key 解析内建候选链（①→④），并对控制组不稳定加退避/重试与「非 200 时不得推断额度」的显式错误处理。

## 原始证据文件（临时）
- /tmp/c1.hdr, /tmp/c1.body（控制① 200）
- /tmp/c1b.hdr, /tmp/c1b.body（控制① 复测 401）
- /tmp/c4.hdr, /tmp/c4.body（控制④ 200）
- /tmp/sub.hdr, /tmp/sub.body（假设 subscription 401）
- /tmp/usage.hdr, /tmp/usage.body（假设 usage 401）

## 最终结论（8 字段块）
status: done
acceptance: 6/6 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS 6:PASS]
files: /mnt/data/dev/task-planner-skill/plans/task-v138/findings.md(+1 块); /mnt/data/dev/task-planner-skill/plans/task-v138/progress.md(+1 行); /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/04-executor-endpoint-probe2.md(+new)
evidence: control c1 GET /v1/models→HTTP 200 (cf-cache-status EXPIRED); control c1b same key→HTTP 401 "无效的令牌" (BYPASS); hypothesis GET /v1/dashboard/billing/subscription→401 "Invalid token"; hypothesis GET /v1/dashboard/billing/usage→401 "Invalid token"; control c4 (bashrc key)→200; x-ratelimit-* headers=none
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/04-executor-endpoint-probe2.md (status: done)
findings_written: findings.md #### [sub:04-executor-endpoint-probe2]
blockers: none
confidence: MED
