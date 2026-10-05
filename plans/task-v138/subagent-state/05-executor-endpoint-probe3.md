# Checkpoint: 05-executor-endpoint-probe3（额度端点探针第三波）

**S-unit**: Phase 1 S2c — 绕缓存条件下重定 key 候选 + OpenAI 兼容 billing 假设组判定
**需求锚**: R3
**预算**: 总请求 ≤5（实耗 4）；连续 429/403 → 立即停（未触发）

## 里程碑日志

- [M0] Init — 2026-10-05 解析 S-unit 为 5 步；checkpoint 建立
- [M1] 提取 key 候选：④ `.bashrc:194` = `cpk-fB...guim`(len52)；① env = `cpk-m4...h0fH`(len52)；两者 sha256 不同；env `AGNES_API_TOKEN`/`APIHUB_AGNES_API_KEY` unset
- [M2] 控制组（绕缓存）候选④：`GET /agnesapi?video_id=probe-nonexist-<ns>&model_name=agnes-video-2.5-flash&_=<ns>` → **HTTP 404 `任务不存在`**，`cf-cache-status: DYNAMIC`，`cache-control: private, no-store`，`vary: Authorization` → 非 401 = **通过鉴权，候选④有效**
- [M2b] 负向对照校准（bogus key `cpk-0000...`，零成本）：同端点 → **HTTP 401 `无效的令牌`**，`cf-cache-status: DYNAMIC` → 端点确有鉴权判别力（校准前波「未校准代理观测」缺陷）
- [M3] 候选④有效 → 按协议跳过候选①（省预算，①未定论）
- [M4] 假设组（候选④，绕缓存）：`GET /v1/dashboard/billing/subscription` → **200** `{"object":"billing_subscription","has_payment_method":true,"soft_limit_usd":100000000,"hard_limit_usd":100000000,"system_hard_limit_usd":100000000,"access_until":0}`；`GET /v1/dashboard/billing/usage` → **200** `{"object":"list","total_usage":0}`；两者 `cf-cache-status: MISS`，无 `x-ratelimit-*`/quota/credit/balance 响应头 → 按口径判 **「可用」**（含额度/用量字段）
- [M5] 落 findings.md `#### [sub:05-executor-endpoint-probe3]` + progress.md `[sub:05]` 行

## 最终结论（8 字段块）

- status: done
- acceptance: 5/5 pass — [1:PASS 2:PASS 3:PASS 4:PASS 5:PASS]
- files: /mnt/data/dev/task-planner-skill/plans/task-v138/findings.md (+~55); /mnt/data/dev/task-planner-skill/plans/task-v138/progress.md (+1); /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/05-executor-endpoint-probe3.md (new)
- evidence: `GET /agnesapi?video_id=probe-nonexist-<ns>&model_name=agnes-video-2.5-flash&_=<ns>` w/ cand④ → `HTTP/2 404` + `{"error":{"code":404,"message":"任务不存在..."}}` + `cf-cache-status: DYNAMIC`; same w/ bogus key → `HTTP/2 401` + `{"error":{"message":"无效的令牌..."}}`; `GET /v1/dashboard/billing/subscription` → `HTTP/2 200` + `{"object":"billing_subscription",...,"hard_limit_usd":100000000,...}`; `GET /v1/dashboard/billing/usage` → `HTTP/2 200` + `{"object":"list","total_usage":0}`
- checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/05-executor-endpoint-probe3.md (status: done)
- findings_written: `#### [sub:05-executor-endpoint-probe3]`
- blockers: none
- confidence: MED（端点可达+key有效=HIGH；返回值语义保真度未验证=拖低）
