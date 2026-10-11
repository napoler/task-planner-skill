# Checkpoint — sub:03-executor-endpoint-probe

> S-unit: 对候选额度端点做只读 GET 探测（≤3），原始响应落 findings，判定额度端点可用/不可得
> 需求锚: R3（视频剩余额度应直接通过 API 获取）

## Milestones
- [M1] 密钥同源确认：`/home/terry/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py:27-34` `get_api_key()` 读环境变量 `AGNES_API_KEY`/`AGNES_API_TOKEN`/`APIHUB_AGNES_API_KEY`；本次取 `AGNES_API_KEY`（已设，len=52，格式 `^cpk-[A-Za-z0-9_-]+$`，无空白；脱敏 `cpk-m4...h0fH`）；BASE=`https://api.agnes-ai.cn`（agnes_api.py:20）
- [M2] 探针 1（控制组）`GET /v1/models` → HTTP 401；响应体 `{"error":{"code":"","message":"无效的令牌 ...","type":"AgnesAI_error"}}`；响应头无 `x-ratelimit-*` 配额回传头
- [M3] 探针 2（假设组）`GET /v1/dashboard/billing/subscription` → HTTP 401；响应体 `{"error":{"code":"","message":"Invalid token ...","type":"AgnesAI_error"}}`
- [M4] 探针 3（假设组）`GET /v1/dashboard/billing/usage` → HTTP 401；响应体 `{"error":{"code":"","message":"Invalid token ...","type":"AgnesAI_error"}}`
- [M5] 判定：控制组失败（401）→ 命中「控制组即失败 → 登记 key/网络问题，不下结论」分支；端点可用性 **INDETERMINATE**（非「可用」、非「不可得穷尽」）；无 429/403 风控信号，跑满 3 探针后停止
- [M6] 根因诊断（未验证项已标注）：运行时 env `AGNES_API_KEY`（`cpk-m4...h0fH`）与 `/home/terry/.bashrc:194`（`export AGNES_API_KEY='cpk-fB...guim'`）sha256 不同 → 会话环境注入的 key 与 .bashrc 定义值非同一值；env 值被服务端判 token 无效；.bashrc 值有效性**未测**（受 ≤3 探针预算约束）
- [M7] 产出落盘：findings.md `#### [sub:03-executor-endpoint-probe]` 追加块 + progress.md Phase 1 追加行

## Raw evidence locations
- findings.md → `#### [sub:03-executor-endpoint-probe]`（3 探针 HTTP 状态码 + 全量响应头 + 响应体前 500 字符，key 已脱敏）
- 命令：`curl -sS -m 30 -o body -D hdr -w '%{http_code}' -X GET https://api.agnes-ai.cn/<path> -H "Authorization: Bearer $AGNES_API_KEY"` → 三次均 `HTTP_STATUS=401`

## Final conclusion (8 fields)
status: partial
acceptance: 3/4 pass — [1:PASS 控制组 GET /v1/models 已执行+原始响应落盘 2:PASS 假设组 subscription 已执行+原始响应落盘 3:PASS 假设组 usage 已执行+原始响应落盘 4:PARTIAL 端点可用性判定受阻于 key/网络问题（控制组失败，口径要求不下结论）]
files: /mnt/data/dev/task-planner-skill/plans/task-v138/findings.md(+1/-0); /mnt/data/dev/task-planner-skill/plans/task-v138/progress.md(+1/-0); /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/03-executor-endpoint-probe.md(+1/-0)
evidence: findings.md `#### [sub:03-executor-endpoint-probe]`（GET /v1/models→401 `无效的令牌`；GET /v1/dashboard/billing/subscription→401 `Invalid token`；GET /v1/dashboard/billing/usage→401 `Invalid token`）；agnes_api.py:27-34 get_api_key() 环境变量来源；/home/terry/.bashrc:194 key 与环境 key sha256 不一致
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v138/subagent-state/03-executor-endpoint-probe.md (status: done)
findings_written: findings.md `#### [sub:03-executor-endpoint-probe]`（Research Findings 段末，S1[sub:02] 块之后、Technical Decisions 前）
blockers: 控制组 401（key/网络问题）致额度端点可用性未定论；运行时 env AGNES_API_KEY 被服务端判无效且与 .bashrc:194 定义值不同
confidence: MED
