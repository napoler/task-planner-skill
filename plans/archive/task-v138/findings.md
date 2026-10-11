# Findings & Decisions
<!--
  知识库:一切发现/决策/证据的落盘处。Context Window = RAM(易失),本文件 = Disk(持久)。
  Rule 19.1: 子代理/调研返回后紧邻回填对应段落(结论摘要 + 证据路径 file:line/URL)。
  Rule 3:    每 2 次 view/browser/search 操作后必须更新本文件。
-->

## Requirements
<!-- 用户需求拆解(Phase 1 期间填写,保持可见防遗忘) -->
-

## 📚 必要知识储备对齐记录（Knowledge Base Alignment）
<!-- 消费一个知识源后立即登记;结论落点到对应段落 -->
| 知识源 | 定位(路径/URL) | 是否已消费 | 结论落点(本文件段落) |
|--------|---------------|-----------|---------------------|
|       |               |           |                     |

## Research Findings
<!-- 调研/搜索/文档/子代理结论:摘要 + 证据路径。子代理返回后紧邻写(Rule 19.1) -->
-

#### [sub:02-web-search-quota] Agnes 官方文档未记载额度/余额/配额直查端点（穷举验证）

**结论（高置信）**：`wiki.agnes-ai.cn` 官方文档**不存在**任何剩余额度/余额/配额直查端点。额度信息只经需登录的 Web 控制台暴露，API Key 无法直查。

**穷举方法（保证无遗漏）**：
- `https://wiki.agnes-ai.cn/llms.txt`（HTTP 200，26 条页面清单，站点自述 built on Mintlify）
- `https://wiki.agnes-ai.cn/sitemap.xml`（HTTP 200，26 条 `<loc>`，与 llms.txt 一致）
→ 官方文档全量页面已穷举，据此做全站关键词扫描。

**文档记载的 HTTP 端点全集（仅 2 个）**：
| Method + Path | 用途 | 来源 |
|---|---|---|
| `POST /v1/videos` | 视频任务创建 | https://wiki.agnes-ai.cn/zh-Hans/docs/agnes-video-25-flash.md |
| `GET /agnesapi?video_id=<VIDEO_ID>&model_name=agnes-video-2.5-flash` | 视频任务查询 | 同上 |

**额度暴露的 4 条旁证**：
1. `faqs.md:126`：「你可以在仪表板的"Usage"或"Billing"中查看你的请求使用情况、限制和相关详情」——控制台路径，需登录，非 API。
2. `faqs.md:93` / `code.md:54-60`：`402` = 余额、积分、订阅或调用前校验未通过；`code.md:58-60` 明确列「账户余额不足 / Token Plan 配额不足 / 超出可用配额」。额度耗尽只能事后由 402 推断。
3. `faqs.md:95`：`429` = 超过 RPM 或订阅配额，需「检查剩余配额」，但未给查询方式。
4. `tokenplan.md:63-79,160-172`：定义文本按请求次数、图片按张数、视频按秒数（500 秒/天）的配额模型，但仅描述限制，无任何查询端点。

**响应头也无配额回传**：全文档扫 `x-ratelimit|ratelimit-|Retry-After` 零命中（`code.md` 中 `Header` 命中全为 401/415/431 请求头错误说明）。

**对下游约束**：
- design-brief §3.3 第 48 行要求的「①wiki 官方文档调研」路线**已穷尽且不可得**，Phase 1 S2 的 OpenAI 兼容 billing 探针（如 `/v1/dashboard/billing/subscription`）成为唯一剩余假设，且属**文档未记载路径**，结论必须标注为推测而非事实。
- design-brief §3.3 第 50 行兜底形态（「错误处理已验证 + 端点待确认」，V2 判 PARTIAL）被本单元证据**证实为必然而非保守**。

**工具注记**：`web_search_prime` HTTP 429 周/月额度耗尽（重置 2026-10-08）；`WebFetch` provider rejected（沿用 task-v122/v127 判例）。本次改用 `curl` 直取 Mintlify 裸 markdown 完成调研。

#### [sub:03-executor-endpoint-probe] 额度端点只读 GET 探针：控制组 401 → 判定「key/网络问题」，端点可用性未定论

**执行摘要**：以 `agnes_api.py` 同源密钥对 3 个候选端点做 GET 只读探针（≤3 请求，未超预算）。**三个端点全部 HTTP 401**，其中控制组 `/v1/models` 亦失败 → 按判定口径落「控制组即失败」分支，**登记「key/网络问题」，不对额度端点可用性下结论**（既未达成「可用」终态，也未达成「不可得（穷尽）」终态）。无 429/403 风控信号，故跑满 3 探针后停止。

**密钥来源（同源确认）**：`/home/terry/.zcode/skills/agnes-ai-generation-skill/scripts/agnes_api.py:27-34` 的 `get_api_key()` 依次读环境变量 `AGNES_API_KEY` → `AGNES_API_TOKEN` → `APIHUB_AGNES_API_KEY`。本次取 `AGNES_API_KEY`（已设，len=52，格式匹配 `^cpk-[A-Za-z0-9_-]+$`，无空白字符；脱敏 `cpk-m4...h0fH`）。BASE=`https://api.agnes-ai.cn`（`agnes_api.py:20`）。请求头 `Authorization: Bearer <key>`。

**探针原始响应（key 已脱敏；均 GET 只读）**：

探针 1（控制组）`GET /v1/models` → **HTTP 401**
- 响应头（全量）：
  - `HTTP/2 401`
  - `date: Mon, 05 Oct 2026 13:22:42 GMT`
  - `content-type: application/json; charset=utf-8`
  - `content-length: 118`
  - `x-new-api-version: master-cn-17358a4e1e47d1d222d1bd4ac5041ba8406f7d09`
  - `set-cookie: __cf_bm=fV7I1wyvayYFXAlDle0.NhYD10JG3Yg6XjszVk6oAZo-1791206562.4740012-1.0.1.1-OvbBA16nLjvMpMC6xBG25ebi8YbqQFtDJVE1RAedQ9VzoDqdzXKSHK.EWaqVjOOr7TU2gl2Ju8SbaFNAe027f8JGjryGjEHBbdsQBMkfrpjzRKU8YaF14.tEnhXWpapV; HttpOnly; SameSite=None; Secure; Path=/; Domain=agnes-ai.cn; Expires=Mon, 05 Oct 2026 13:52:42 GMT`
  - `x-request-id: 61a43a9e09bd2f945397f1e03b012cc5`
  - `x-trace-id: 61a43a9e09bd2f945397f1e03b012cc5`
  - `cf-cache-status: BYPASS`
  - `server: cloudflare`
  - `cf-ray: a45cbc977ed738ad-TNA`
- 响应体（前 500 字符）：`{"error":{"code":"","message":"无效的令牌 (request id: 20261005132242486345554sDlUfDfM)","type":"AgnesAI_error"}}`
- **无任何 `x-ratelimit-*` 类配额回传头**（响应头仅含 cf/trace/version 类）

探针 2（假设组）`GET /v1/dashboard/billing/subscription` → **HTTP 401**
- 响应头（全量）：
  - `HTTP/2 401`
  - `date: Mon, 05 Oct 2026 13:22:52 GMT`
  - `content-type: application/json; charset=utf-8`
  - `vary: Accept-Encoding`
  - `x-new-api-version: master-cn-17358a4e1e47d1d222d1bd4ac5041ba8406f7d09`
  - `set-cookie: __cf_bm=xRewarYCtbvmimCffjMFHOtWaigp.HRkfCjhcI2QM18-1791206572.743756-1.0.1.1-9WUaz3laeF9vV6WTrEIdvh92dxjo84iiPdPDiT2E3gKCDtXs8p3VhxfCZPwqY6kru5y3fCikFHX_.MVyZLlcTmoRS8Nr0A1zNHzg1nRhKKVKnLLRzot1IfvXiy9DQKOY; HttpOnly; SameSite=None; Secure; Path=/; Domain=agnes-ai.cn; Expires=Mon, 05 Oct 2026 13:52:52 GMT`
  - `cf-cache-status: BYPASS`
  - `server: cloudflare`
  - `cf-ray: a45cbcd7ab9038ad-TNA`
- 响应体（前 500 字符）：`{"error":{"code":"","message":"Invalid token (request id: 20261005132252756344627edl8uK1Z)","type":"AgnesAI_error"}}`

探针 3（假设组）`GET /v1/dashboard/billing/usage` → **HTTP 401**
- 响应头（全量）：
  - `HTTP/2 401`
  - `date: Mon, 05 Oct 2026 13:22:58 GMT`
  - `content-type: application/json; charset=utf-8`
  - `vary: Accept-Encoding`
  - `x-new-api-version: master-cn-17358a4e1e47d1d222d1bd4ac5041ba8406f7d09`
  - `set-cookie: __cf_bm=pylxnEy.02Z4WhMttbKbCyjFS3hA9d.TXjmeFHar_Gw-1791206577.9940295-1.0.1.1-PsdBNvahkBCPiaZE3XFEq9Saxn.6BQRMCLAgUxq_D4Q5fBAWt.loqs95yrIYSCG.Ca4Npe4qdwEtVPSythVpEBklOMt_325KHNzFIKZsMMslHSjydf6if_VeofGZQsVF; HttpOnly; SameSite=None; Secure; Path=/; Domain=agnes-ai.cn; Expires=Mon, 05 Oct 2026 13:52:58 GMT`
  - `cf-cache-status: BYPASS`
  - `server: cloudflare`
  - `cf-ray: a45cbcf87d5638ad-TNA`
- 响应体（前 500 字符）：`{"error":{"code":"","message":"Invalid token (request id: 202610051322583907750uT5DeT02)","type":"AgnesAI_error"}}`

**判定（口径对照）**：控制组 `/v1/models` = 401（非 200）→ 命中「**控制组即失败 → 登记 key/网络问题，不下结论**」分支。假设组两探针亦 401（英文 `Invalid token`，与 `/v1/models` 的中文 `无效的令牌` 分属不同网关路由，但同判 token 无效）→ 无 429 连续 / 403 风控文案，未触发「立即停止剩余探针」条款。**全程未出现任何 200 + 额度/余额/配额字段** → 「可用」不成立；亦**不可**据 401 判「不可得（穷尽）」——401 是鉴权层拒绝而非 404 路由不存在，**无法区分**「端点存在但 key 无效」与「端点不存在」。

**关键诊断（阻塞根因，未验证项已标注）**：运行时环境 `AGNES_API_KEY` 与 `/home/terry/.bashrc:194` 定义的同名 key **不是同一值**（sha256 摘要不同）：
- 环境值（本次探针所用，即 `get_api_key()` 实际取值）：len=52，脱敏 `cpk-m4...h0fH`，服务端判 **token 无效**
- `.bashrc:194`：`export AGNES_API_KEY='cpk-fB...guim'`（len=52，脱敏 `cpk-fB...guim`），**未被本会话环境采用**（.bashrc 早退守卫致非交互 shell 未加载其 export，环境沿用父进程注入值）
→ 高度怀疑会话环境注入的 `AGNES_API_KEY` 为失效/过期或占位 key。**未验证**：`.bashrc` 那把 key 是否有效（未测，受 ≤3 探针预算约束，禁止超预算追加请求）。

**对下游约束（R3 影响）**：
- 本次**无法**确认额度直查端点是否存在。design-brief §3.3 的「端点不可得（穷尽）」终态**未达成**（既未证实可用、也未证实不存在）。
- Phase 3 S1 脚本形态**不能**据本结果二选一：需先解决 key 问题后**重跑本探针**（用有效 key 复核控制组 `/v1/models`），方能判「可用（走直查分支）」或「不可得（走 PARTIAL 兜底）」。
- 重跑建议：同时验证运行时 env key（`cpk-m4...h0fH`）与 `.bashrc` key（`cpk-fB...guim`）哪个有效；若 env 注入值失效而 `.bashrc` 值有效，则属**会话环境问题**而非端点问题。

#### [sub:04-executor-endpoint-probe2] 额度端点只读探针重试（key 候选链）：判定「不可得（穷尽）」；并反证前序「env key 失效」根因

**执行摘要**：按 key 候选链重跑只读 GET 探针（合计 5 请求 = 3 控制组 + 2 假设组，未超 ≤5）。**结论：额度直查端点「不可得（穷尽）」**——假设组（OpenAI 兼容 billing 路径）两探针全 401、从未出现 200 + 额度/余额字段；控制组曾 2xx（非「全部候选控制组均失败」分支）；官方文档穷举（sub:02）已证实无额度直查端点。命中判定口径 #4（工作 key 有效而假设组 404/401 → 不可得（穷尽）→ 触发 design-brief §3.3 兜底，V2 判 PARTIAL）。**置信度 MEDIUM**。

**① key 候选链解析（下游脚本 key 解析逻辑的规格输入；值全程脱敏 前6后4）**：

| 候选 | 来源 | 值（脱敏） | 状态 |
|---|---|---|---|
| ① | env `AGNES_API_KEY` | `cpk-m4...h0fH` (len=52) | **set（本机实际命中）** |
| ② | env `AGNES_API_TOKEN` | — | unset/empty |
| ③ | env `APIHUB_AGNES_API_KEY` | — | unset/empty |
| ④ | `/home/terry/.bashrc:194` `^export AGNES_API_KEY=` 提取（去单引号） | `cpk-fB...guim` (len=52) | set |

- 解析命令：`printenv <NAME>`；`.bashrc` 用 `grep -nE '^export AGNES_API_KEY=' /home/terry/.bashrc | head -1` 后 `sed -E "s/^export AGNES_API_KEY=//; s/^['\"]//; s/['\"]$//"` 取单引号内值。
- 候选顺序与 `agnes_api.py:28` 的 `get_api_key()` 一致（env 三名顺序），④为探针协议追加的 `.bashrc` 兜底源。
- **候选①与④行为无差异**（见下表 c1 vs c4），key 来源不是区分因子。

**② 控制组探针（每候选先跑；key 脱敏）**：

| 探针 | key 来源 | 端点 | HTTP | cf-cache-status | 响应体要点 |
|---|---|---|---|---|---|
| c1 | ① env `cpk-m4...h0fH` | `GET /v1/models` | **200** | `EXPIRED` | `{"data":[{"id":"agnes-2.0-flash"...},{"id":"agnes-3.0-flash"...}]}`（907B；含 `x-request-id`/`x-trace-id`、`age: 0`、`cache-control: public, max-age=14400`、`expires`、`last-modified`） |
| c1b | ① env（同 key，22s 后复测） | `GET /v1/models` | **401** | `BYPASS` | `{"error":{"code":"","message":"无效的令牌 (request id: 20261005132823669924953uxmgG6dn)","type":"AgnesAI_error"}}` |
| c4 | ④ `.bashrc:194` `cpk-fB...guim` | `GET /v1/models` | **200** | `EXPIRED` | 同上模型清单（同结构） |

- **关键现象（控制组不稳定）**：同一 key（候选①）在 22 秒内先 200（c1）后 401（c1b）。协议「2xx 即定为工作 key 并停止候选切换」在 c1 已触发，但因 2xx 不可复现（c1b 立即 401），为核验「env key 死 / bashrc key 活」假设追加测 c4。
- **缓存相关性**：全部 200 均带 `cf-cache-status: EXPIRED`（响应头含 `cache-control: public, max-age=14400`）；全部 401 均带 `cf-cache-status: BYPASS` → 200 疑为 Cloudflare 缓存态返回，**不能单独证明 key 有效**。此为本探针方法论缺陷（控制组判别力不足），需下游注意。

**③ 假设组探针（≤2 请求，均用工作 key 候选①，与 c1 同 key 同会话）**：

| 探针 | 端点 | HTTP | cf-cache-status | 响应体（前 300） |
|---|---|---|---|---|
| sub | `GET /v1/dashboard/billing/subscription` | **401** | `BYPASS` | `{"error":{"code":"","message":"Invalid token (request id: 202610051328099382225601luypjAZ)","type":"AgnesAI_error"}}` |
| usage | `GET /v1/dashboard/billing/usage` | **401** | `BYPASS` | `{"error":{"code":"","message":"Invalid token (request id: 202610051328101121324616WLJxf6M)","type":"AgnesAI_error"}}` |

- **无任何 `x-ratelimit-*` / `ratelimit-*` / `Retry-After` 响应头**（控制组 + 假设组全部 grep 零命中）。
- 错误文案差异：控制组 401 = 中文「无效的令牌」；假设组 401 = 英文 `Invalid token` → 分属**不同网关路由**，假设组路由不接受 API key（与 sub:02「额度仅经需登录 Web 控制台暴露」一致）。
- 无 429/403 风控迹象 → 未触发「立即停止」条款；跑满假设组预算后停止。

**④ 判定（口径对照）**：命中 #4「**工作 key 有效而假设组 404/401 → 不可得（穷尽）→ 触发 design-brief §3.3 兜底（V2 判 PARTIAL）**」。三重收敛：①假设组全 401 且无额度字段（「可用」不成立）；②控制组曾 2xx（非「全部控制组失败」分支）且官方文档穷举无端点；③假设组 401 为独立网关英文报错，与「额度仅控制台暴露」一致。**置信度 MEDIUM**（控制组抖动 + 假设组仅 2 样本 + 受 ≤5 预算限制未做 bogus-key 对照）。

**⑤ 对前序 sub:03 根因的反证（重要修正）**：本次**未能复现**前序「会话 env 的 `AGNES_API_KEY` 已失效」根因——**同一 env key（`cpk-m4...h0fH`）本次在控制组返回 200**。真实情形为**控制组自身不稳定（200/401 抖动，200 与 Cloudflare 缓存态相关）**，而非「env key 死 / `.bashrc` key 活」。前序「会话环境注入 key 失效」应降级为**未证实假设**（可能为瞬时鉴权抖动或缓存态返回）；本单元派发前提（「修复 key 来源后重跑」）**不成立**——key 来源并非失败根因。

**⑥ 对下游约束（R3 / Phase 3 S1）**：
- `agnes-quota.sh` 落盘为「错误处理已验证 + 端点待确认」形态（**PARTIAL**），禁止伪造直查成功（design-brief §3.3 / VC-2）。
- key 解析内建候选链：env `AGNES_API_KEY` → `AGNES_API_TOKEN` → `APIHUB_AGNES_API_KEY` → `.bashrc` `^export AGNES_API_KEY=`（同源 `agnes_api.py:27-36`，禁硬编码）。
- 必须对**控制组不稳定**加退避/重试，并显式「非 200 时不得推断额度」（控制组 2xx 亦不可单凭判定 key 有效——200 疑缓存态）。
- 额度端点确认走**控制台/文档**路线，非 API key 直查；如需 API 直查须先向 Agnes 确认是否存在账户级 billing 端点。

#### [sub:05-executor-endpoint-probe3] 额度端点探针第三波（绕缓存 + 校准控制组）：key 候选④确证有效，OpenAI 兼容 billing 端点「可用」（但值为网关默认，保真度存疑）

**执行摘要**：全请求强制绕缓存（`Cache-Control: no-cache` + `Pragma: no-cache` + 随机 `?_=<epoch_ns>`）。合计 **4 请求（≤5 预算）**，无 429/403。**先校准控制组再下结论**：候选④（`.bashrc`）→ `GET /agnesapi?video_id=<bogus>` 返回 **404 任务不存在**（`cf-cache-status: DYNAMIC`，非缓存态）；同一端点换必然无效的 bogus key → **401 无效的令牌**（同为 DYNAMIC）→ **端点确有鉴权判别力，「非 401 = 通过鉴权」成立**（修正前波 sub:04「控制组 200 疑缓存态、无判别力」缺陷）。据此**确证 key 候选④ `cpk-fB...guim`（/home/terry/.bashrc）有效**；假设组（OpenAI 兼容 billing）两探针均 **HTTP 200 且含额度/用量字段 → 按口径判「可用」**。**此项推翻前波 sub:04「不可得（穷尽）」**——后者对假设组误用了未经校准的 env key ①。

**① key 候选链解析（下游脚本 key 解析逻辑的规格输入；值全程脱敏 前6后4）**：

| 候选 | 来源 | 值（脱敏） | 绕缓存控制组结果 | 判定 |
|---|---|---|---|---|
| ④ | `/home/terry/.bashrc` `^export AGNES_API_KEY=`（去单引号） | `cpk-fB...guim` (len=52) | **404 任务不存在**（`cf-cache-status: DYNAMIC`） | **有效（通过鉴权）** |
| ① | env `AGNES_API_KEY` | `cpk-m4...h0fH` (len=52) | 未测（④已有效，省预算） | **未定论**（前波 sub:04 曾用其打假设组得 401，但控制组校准缺失，不足为凭） |
| bogus | 构造 `cpk-0000...` | — | **401 无效的令牌**（DYNAMIC） | 无效（负向对照，校准用） |
| ②③ | env `AGNES_API_TOKEN` / `APIHUB_AGNES_API_KEY` | — | 未测 | unset/empty（不可用） |

- 提取命令：`grep -E "^export AGNES_API_KEY=" /home/terry/.bashrc | head -1` 后 `sed -E "s/^export AGNES_API_KEY=//; s/^['\"]//; s/['\"]\$//"`。
- ④ 与 ① **不是同一值**（sha256 前 12 位不同）；**本次确证有效的是 ④（.bashrc 源）**，非 env 注入的 ①。
- **控制组端点特性（规格要点）**：`/agnesapi` 响应头含 `cache-control: private, no-store` + `vary: Authorization` → **不可被 CDN 缓存**，是可靠的鉴权探针（对比 `/v1/models` 的 `public, max-age=14400` 会缓存）。且响应头含 `x-oneapi-request-id` → 后端为 **one-api / new-api 系 OpenAI 兼容网关**。

**② 控制组探针（绕缓存；key 脱敏）**：

| 探针 | key | 端点 | HTTP | cf-cache-status | 响应体要点 |
|---|---|---|---|---|---|
| c4 | ④ `cpk-fB...guim` | `GET /agnesapi?video_id=probe-nonexist-<ns>&model_name=agnes-video-2.5-flash&_=<ns>` | **404** | `DYNAMIC` | `{"error":{"code":404,"message":"任务不存在 (request id: ...)"}}` |
| neg | bogus `cpk-0000...` | 同端点（新随机 ns） | **401** | `DYNAMIC` | `{"error":{"code":"","message":"无效的令牌 (request id: ...)","type":"AgnesAI_error"}}` |

- **判别力已校准**：有效 key→404（任务不存在=鉴权通过后查任务）；无效 key→401（鉴权拒绝）。二者均为 `DYNAMIC`（非 HIT/EXPIRED 缓存态），故 404 **可信地**证明 key 有效。
- 未出现 429/403 风控文案 → 未触发「立即停止」条款。

**③ 假设组探针（≤2 请求，均用已确证有效的候选④，绕缓存）**：

| 探针 | 端点 | HTTP | cf-cache-status | 响应体（全量） |
|---|---|---|---|---|
| subscription | `GET /v1/dashboard/billing/subscription?_=<ns>` | **200** | `MISS` | `{"object":"billing_subscription","has_payment_method":true,"soft_limit_usd":100000000,"hard_limit_usd":100000000,"system_hard_limit_usd":100000000,"access_until":0}` |
| usage | `GET /v1/dashboard/billing/usage?_=<ns>` | **200** | `MISS` | `{"object":"list","total_usage":0}` |

- **响应头无任何配额回传**：`x-ratelimit-*` / `ratelimit-*` / `quota` / `credit` / `balance` / `Retry-After` 全部 grep 零命中；额度信息**仅在 JSON body**。
- 两探针响应头含 `cache-control: public, max-age=14400`（**CDN 可缓存**，与 `/agnesapi` 的 `private, no-store` 相反）→ 下游脚本**必须**加随机 query 或 `Cache-Control: no-cache` 防缓存污染，否则可能读到陈旧/他人态。
- 对照前波：sub:04 用 key ① 打同两探针得 401（英文 `Invalid token`）；本次用 key ④ 得 200 → **401 的成因是 key ① 无效（或未经校准），非端点不存在**。前波「不可得（穷尽）」结论**证伪**。

**④ 判定（口径对照）**：命中口径 #6「**key 确认有效后假设组任一 200 含额度/余额字段 → 「可用」**」。key ④ 已由校准过的控制组确证有效；假设组两探针 200 且 `subscription` 含 `soft_limit_usd`/`hard_limit_usd`/`system_hard_limit_usd`（额度类字段）、`usage` 含 `total_usage`（用量字段）→ **判定「可用」，输出字段结构供后续脚本消费**。

**⑤ 保真度警告（未验证项，必须向下游明示）**：返回值疑为**网关默认桩值**，非 Agnes 账户真实剩余额度——
- `soft_limit_usd == hard_limit_usd == system_hard_limit_usd == 100000000`（1e8，one-api/new-api 默认硬顶）；`access_until: 0`；`usage.total_usage: 0` 且 `object: "list"`（空列表，无按模型/按天明细）。
- Agnes 官方额度模型（sub:02）为**视频按秒/天、文本按请求次数、图片按张数**，与上述 USD 字段**不同构**；`total_usage: 0` 与「用户实际已消耗」无从对应。
- **未验证**：这些值是否随账户/消耗变化（未做消耗前后对照，超预算）；`soft/hard_limit_usd=1e8` 是否为所有 key 恒定默认。→ **对 R3「剩余视频额度」的语义满足度：结构可用、数值存疑**。

**⑥ 对下游约束（R3 / Phase 3 S1）**：
- `agnes-quota.sh` 可采用候选链 **④ `.bashrc` 优先 → ① env → ②③**（本次证明 ④ 有效、① 未定论），端点选 `/v1/dashboard/billing/subscription` + `/v1/dashboard/billing/usage`。
- 脚本**必须**：① 全请求加随机 query 绕 CDN 缓存（假设组 `public, max-age=14400` 可缓存）；② 内置控制组自校准（`/agnesapi` + bogus video_id：401=key 无效，非 401=key 有效）后再采信 billing 值；③ 输出须标注「USD 限额字段，疑网关默认，非视频秒级剩余额度（保真度未验证）」，禁将 `total_usage: 0` 直接当「已用额度」。
- 判定档位：本次为 **「可用（结构级）」**，非前波的「不可得」。design-brief §3.3 兜底 V2 的 PARTIAL 触发条件**不再由「端点不可得」满足**；是否仍判 PARTIAL 取决于下游是否接受「数值保真度未验证」——建议脚本按「可用但值待核」形态落盘并在 findings 引用本块。

#### [sub:06-executor-endpoint-probe4] 额度探针收尾波（usage 日期参数真实性核验）：两日期窗均 total_usage=0 → 判定「端点存在但计费层未回传有效配额」

**执行摘要**：对 `/v1/dashboard/billing/usage` 加 OpenAI 语义日期参数（`start_date`/`end_date`，ISO YYYY-MM-DD）核验是否回传**真实 Agnes 消耗**。合计 **2 请求（≤3 预算）**，无 429/403。key 仅用候选④（`/home/terry/.bashrc`，本会话已校准有效）。**两日期窗（1 日窗 + 30 日窗）均 HTTP 200 且 body 恒为 `{"object":"list","total_usage":0}`，无任何 daily/按模型明细** → 按判定口径命中「**两个窗口都 total_usage=0/空 且 subscription limit 为 1e8 占位 → 端点存在但计费层未回传有效配额**」。**结论：usage 端点存在但计费层未填充，剩余额度不可由本 API 推出**；脚本须直查并如实呈现原始字段 + 显式判定行，**禁止二次推算**。

**① key（脱敏 前6后4）**：
- 候选④ `/home/terry/.bashrc` `^export AGNES_API_KEY=`（去单引号）= `cpk-fB...guim`（len=52，sha256_12=`6264d5da69db`），与前波 sub:05 同值同源；本会话已由校准控制组（`/agnesapi` bogus video_id：有效→404 / 无效→401）确证有效，故本波未重跑控制组（省预算）。
- 提取命令：`grep -E "^export AGNES_API_KEY=" /home/terry/.bashrc | head -1 | sed -E "s/^export AGNES_API_KEY=//; s/^['\"]//; s/['\"]\$//"`。

**② 探针原始响应（绕缓存：`Cache-Control: no-cache` + `Pragma: no-cache` + 随机 `?_=<epoch_ns>`）**：

| 探针 | 端点 | HTTP | cf-cache-status | 响应体（全量） |
|---|---|---|---|---|
| A（1 日窗） | `GET /v1/dashboard/billing/usage?start_date=2026-10-05&end_date=2026-10-06&_=<ns>` | **200** | `MISS` | `{"object":"list","total_usage":0}` |
| B（30 日窗） | `GET /v1/dashboard/billing/usage?start_date=2026-09-05&end_date=2026-10-06&_=<ns>` | **200** | `MISS` | `{"object":"list","total_usage":0}` |

- 响应头（两探针同构，摘录）：`content-type: application/json; charset=utf-8`、`cache-control: public, max-age=14400`、`expires`/`last-modified` 均存在、`cf-cache-status: MISS`（绕缓存生效，MISS=回源非缓存态）、`x-new-api-version: master-cn-17358a4e1e47d1d222d1bd4ac5041ba8406f7d09`、`server: cloudflare`、`cf-ray`、`set-cookie: __cf_bm=...`。
- **响应头无任何配额回传**：`x-ratelimit-*` / `ratelimit-*` / `quota` / `credit` / `balance` / `Retry-After` 全部 grep 零命中（延续 sub:05 观测）。
- 日期参数**被接受**（无 422/400 参数错误）→ 未触发替代参数名（如 `date=`）尝试；1 日窗与 30 日窗结果**逐字节相同**。
- 无 429/403 → 未触发「立即停止」条款；跑满假设组预算后停止。

**③ 判定（口径对照）**：命中口径行「**两个窗口都 total_usage=0/空 且 subscription 的 limit 为 1e8 占位 → 端点存在但计费层未回传有效配额**」——
- 两窗 `total_usage` 均为 0，`object: "list"` 但**无 data 数组/无按天或按模型明细**（非「非空 daily 数据」）；
- 合并 sub:05 已确证的 `subscription`（`soft/hard/system_hard_limit_usd=100000000` = 1e8 占位、`access_until: 0`）；
- 二者共同证明：端点路由**存在且可达**（200，绕缓存 MISS），但**计费层未回传与 Agnes 实际消耗对应的数值**。**判定：「端点存在但计费层未回传有效配额」**。**置信度 HIGH**。

**④ 保真度结论（R3 语义满足度）**：`total_usage: 0` 在 1 日窗与 30 日窗恒等 → 该字段**不随查询窗口/账户消耗变化**（至少本 API key 与当前账户如此），与 Agnes 官方额度模型（视频按秒/天、文本按请求次数、图片按张数，sub:02）**不同构**。**无法由本 API 推出「视频剩余生成额度」**；R3 的「剩余视频额度」语义**未由本端点满足**。
- **未验证项（显式登记）**：未做「消耗前后对照」（超预算），无法 100% 排除「计费层填充滞后」或「该 key 对应账户恰为零消耗」；但两窗恒等 + 1e8 占位 + 与官方模型不同构三重证据使「计费层未填充」为最可信解释。

**⑤ 对下游约束（R3 / Phase 3 S1 脚本规格）**：
- `agnes-quota.sh` 采用候选链 **④ `.bashrc` 优先 → ① env → ②③**，端点选 `/v1/dashboard/billing/subscription` + `/v1/dashboard/billing/usage`（已确证存在且 200）。
- 脚本**必须**：
  1. 全请求加随机 query + `Cache-Control: no-cache`（端点 `cache-control: public, max-age=14400` 可被 CDN 缓存）；
  2. 直查后**如实呈现原始字段**（subscription 的 `*_limit_usd` + usage 的 `total_usage`/`object`）；
  3. 输出**显式判定行**：「计费层数据未填充，剩余额度不可由本 API 推出」；
  4. **禁止二次推算**（不得用 `hard_limit - total_usage` 冒充剩余视频额度，不得用耗时累计等代理推算——Rule 55.2 权威来源优先禁令）。
- 判定档位：**「端点存在但计费层未回传有效配额」**；对应 design-brief §3.3 兜底形态的 PARTIAL 依据（非「端点不可得」，而是「端点可用但数值无效」）。建议脚本按「直查 + 原始字段 + 显式无效判定行」落盘并在脚本头注释与 findings 引用本块。

#### [sub:07-executor-critical-rules] Rule 55 六子条纯增量落盘 critical-rules.md 文件尾（593→606 行，+13/-0）

**执行摘要**：在 worktree（`/home/terry/task-planner-skill-worktrees/task-v138`）内 `skills/task-planner/references/critical-rules.md` **文件尾**（原末行=53.5 机制行，593 行）纯增量追加 `### 55 可复用能力落盘纪律` + 55.1-55.6 六子条，块首加说明行。全部改动=文件尾追加，1-593 行零触碰（53.5 行 md5 前后一致 `160795c6...`）。**status=done，置信度 HIGH**。

**落点与内容**：
- 块首说明行（第 595 行）：`<!-- Rule 55 (task-v138 2026-10-05): 纯增量新增；判例=本任务 P1 四波探针（findings [sub:03]/[sub:04]） -->`
- 块标题（597 行）：`### 55 可复用能力落盘纪律（P0, 2026-10-05 task-v138，目标：...；判定面=LLM 行为+selftest 静态守护、零新 config 键；衔接 Rule 23.10/43.1/43.6/51.8/34.3/Rule 45，既有 Rules 原文零改动）`
- intro 段（599 行）：逐条锚定 R1-R4 用户原文（R1 常用/可复用功能及时落盘；R2 落盘后必须复用禁重复现场发明；R3 权威 API 直查优先禁耗时累计代理推算；R4 机制=通用执行纪律，视频额度查询为首个落盘实例）+ 判例=Agnes 额度查询。
- 六子条（601-606 行，连续无空行，与 48/50 块风格一致）：55.1 复用前置检查（reuse-first check）/ 55.2 权威来源优先禁令（authoritative-source-first）/ 55.3 首次成功即落盘（persist-on-first-success）/ 55.4 固定位置与格式（canonical location）/ 55.5 执行体接线（executor wiring）/ 55.6 机制（零新 config 键 — 与 43.4/44.4/47.4/52.4 同范式）。
- 六子条逐条对应 design-brief §3.1 要点（55.1↔三条可复用判别特征、55.2↔权威直查禁代理推算、55.3↔当次落盘+DoD、55.4↔固定路径+8 列注册表+三宿主同步、55.5↔两执行体 SOP 指向行+23.10 取值来源、55.6↔零新键+selftest 静态守护+34.3 并行不冲突），无语义漂移。

**交叉引用在位验证（写入前逐号 grep）**：
| 编号 | 位置 | 结论 |
|---|---|---|
| 23.10 | critical-rules.md:197 | 在位 |
| 43.1 | :455 | 在位 |
| 43.6 | :460 | 在位 |
| 51.8 | :573 | 在位 |
| 22.3.0 | :153 | 在位 |
| 34.3 | :336 | 在位 |
| Rule 45 | :479 | 在位 |
| **54.1** | **不在位** | **task-v136 预留未落地（rule-reservations.jsonl:13 rule 54 reserved task-v136）**；master 与 worktree 均无 `^### 54`/`^54\.`。设计权威源 design-brief §3.1 55.2 要求衔接 54.1 → 保留引用并显式标注「task-v136 预留未落地」，避免悬空引用（对齐 52.2 B 类「登记指向不存在实体零容忍」精神） |

**自测验收（全部 PASS）**：
| 检查 | 命令 | 期望 | 实际 |
|---|---|---|---|
| 六子条 | `grep -cE '^55\.[1-6] '` | 6 | 6 |
| 块标题 | `grep -c '^### 55 '` | 1 | 1 |
| 行数 | `wc -l` | 593+新增 | 606（+13） |
| 纯增零删 | `git diff --numstat` | N/0 | 13/0（1 file changed, 13 insertions(+)） |
| 53.5 未改 | `sed -n 593p \| md5sum` 对比 HEAD | 一致 | `160795c6d3d9f2a65410cedf347b3bdc` 一致 |
| hunk 落点 | `git diff --unified=0 \| grep '^@@'` | 仅 593 后新增 | `@@ -593,0 +594,13 @@` |

**负结果报告**：① 检查了 8 个交叉引用编号，7 个在位、1 个（54.1）不在位（已标注预留状态，非阻塞）；② 未发现 1-593 行被触碰（git diff 仅 1 hunk、位于 593 之后，numstat 删行=0）；③ 排除了「误删既有条款/改写 53.5」风险（md5 逐字节一致）；④ 排除了「破坏其他文件」风险（`git diff --stat` 仅 critical-rules.md 单文件，主仓与其他 worktree 零改动）。

**对下游约束**：VC-1 的 critical-rules.md 侧锚已满足（`^55\.[1-6] `=6、`^### 55 `=1）；Phase 3 的 selftest-capability-persistence.sh 应断言 55.1-55.6 子条文本锚 + 注册表/脚本目录锚 + 零新键声明（55.6 已声明，只断言新增锚、防锚级联）；Phase 2 S2（SKILL.md 索引行）由后续 S-unit 承接。

#### [sub:08-executor-skill-index] SKILL.md Rule 55 索引三处联动落地（478→479 行，+4/-3）+ 锚级联缺口登记

- **改动**（worktree 内 `skills/task-planner/SKILL.md`，纯增量/行内改写禁净删，本单元仅触碰此一文件）：
  - `:9` frontmatter 全集行 `Critical Rules 全集 1-53` → `1-55`（行内改写）
  - `:267` 索引全集括注 `含 Rule 40-53 全集` → `含 Rule 40-55 全集，Rule 55 可复用能力落盘纪律`（行内追加）
  - `:308`（Rule 53 bullet 之后）新增 bullet `- **Rule 55（可复用能力落盘纪律 — task-v138）**：复用前置检查(55.1)/.../机制(55.6)...`（纯增量 +1 行）
  - `:332` References 表 critical-rules 行尾 `Rule 53 根源解决与决策管辖）` → `... / Rule 55 可复用能力落盘纪律）`（行内追加）
- **验收证据**：`grep -c 'Rule 55'`=3（:267/:308/:332）；`grep -c '40-55'`=1；`grep -c '40-53'`=0；`grep -c '1-53'`=0；`wc -l`=479（478+1）；`git diff --numstat -- SKILL.md` = `4 3`（3 处行内改写各 +1/-1 + 1 新增 bullet 行）；`bash scripts/selftest-knowledge-brief.sh` T2b「行数 479 ≤558」PASS（未触行数钉，无需上调）
- **口径说明（dispatch 验收 ≥3 的落地）**：dispatch 要求 `grep -c 'Rule 55'` ≥3 且点名「全集行」，但改动点 1 指定的 `含 Rule 40-55 全集` 字面不含子串 `Rule 55`（仅 :308/:332 两处命中）。为既通过门又保留点 1 指定子串，在 `:267` 括注行内补 `，Rule 55 可复用能力落盘纪律`（行内追加、禁净删，未改 `含 Rule 40-55 全集` 子串）
- **锚级联缺口（blocker — 本单元 scope 明令「禁改其他任何文件」，故未修，仅登记）**：`40-53`→`40-55`、`1-53`→`1-55` 打破 3 个既有 selftest 的 4 条断言（worktree 内实跑 FAIL）：
  - `scripts/selftest-root-resolution.sh:102` RR-09 断言 `Critical Rules 全集 1-53`=1 → 现 =0 FAIL
  - `scripts/selftest-root-resolution.sh:163` RR-16 断言索引行含 `Rule 40-53` → FAIL
  - `scripts/selftest-reliability-institution.sh:81` R-09 断言 `含 Rule 40-53 全集`≥1 → FAIL
  - `scripts/selftest-self-resolution.sh:71` SR-08 断言 `含 Rule 40-53`≥1 → FAIL
  - **建议（待授权）**：3 脚本锚随 SKILL 演进同步（`1-53`→`1-55`、`40-53`→`40-55`，含注释行），否则 Phase 4 VC-5「全量 selftest 0 FAIL」不达

**负结果报告**：① 检查了全部 `1-53`/`40-53` 全集措辞（grep 全扫，仅 `:9` 与 `:267` 两处，均已改写，无遗漏）；② 未发现 478 行内其他内容被净删（`git diff` 仅 3 处行内改写 + 1 处新增；3 个删行均为行内改写旧行，无净删）；③ 排除了「误改其他文件」风险（`git diff --numstat` 除 SKILL.md 外仅 `references/critical-rules.md`，系 S1 既有产物，本单元零触碰）；④ 排除了「行数钉触发」风险（479 ≤ 558）。

#### [sub:09-executor-epoch-sync] 3 个既有 selftest 的 4 条纪元断言同步 55 纪元（`1-53`→`1-55`、`40-53`→`40-55`），回归 4 脚本 FAIL=0

- **本单元 scope**：仅改 worktree 内 3 个既有 selftest 的断言字面（`selftest-root-resolution.sh`、`selftest-reliability-institution.sh`、`selftest-self-resolution.sh`），禁改其他任何文件（含 SKILL.md/critical-rules.md）。
- **登记（改前逐一 grep 全部 `1-53`/`40-53` 相关字面 + 负断言）**：
  - `selftest-root-resolution.sh:102` RR-09 正向 `grep -cF 'Critical Rules 全集 1-53'` → `1-55`
  - `selftest-root-resolution.sh:103` RR-09 负断言 `grep -cE '(全集|Rules) 1-51'` → `(全集|Rules) 1-(51|53)`（把 53 并入旧纪元清单，强度不减弱，先例 v127 RC-15 `^50→^52` 演进；负断言未删除）
  - `selftest-root-resolution.sh:163` RR-16 正向 `grep -qF 'Rule 40-53'` → `Rule 40-55`
  - `selftest-reliability-institution.sh:81` R-09 正向 `grep -c '含 Rule 40-53 全集'` → `含 Rule 40-55 全集`（越界负断言 `1-40`=0 不变）
  - `selftest-self-resolution.sh:71` SR-08 正向 `grep -c '含 Rule 40-53'` → `含 Rule 40-55`（`^40\.`=6 子条断言不变）
- **改动方式**：行内改写禁净删；每改行尾随 `# [2026-10-05 task-v138 演进重锚] ...` 标注（Rule 45 What+Why）；断言总数不变（root 17、rel 16、self 13）。
- **验收证据（worktree 内实跑）**：`bash selftest-root-resolution.sh` → `Total: 17 PASS=17 FAIL=0`；`selftest-reliability-institution.sh` → `Total: 16 PASS=16 FAIL=0`；`selftest-self-resolution.sh` → `Total: 13 PASS=13 FAIL=0`；`selftest-knowledge-brief.sh` → `Total: 16 PASS=16 FAIL=0`；`bash -n` 三脚本 exit 0；`git diff --numstat -- selftest-*.sh` = `1/1`、`3/3`、`1/1`（3 文件 5 行，+5/-5，仅 3 脚本）。
- **残余 out-of-scope blocker（本单元新发现，未修，scope 禁改其他文件）**：全量 51 脚本批跑发现 `selftest-skill-split.sh` `Total: 41 PASS=40 FAIL=1`——T-主 行数钉 `≤478` 被 sub:08 的 SKILL.md 478→479（+1 bullet）打破；该脚本 T-主 仅读 `$ROOT/SKILL.md`（`wc -l ≤478`），与本单元 3 脚本零因果关系（改前即 FAIL，master 基线 478 时通过）。建议派发独立单元同步该行数钉上限并注明 task-v138（先例 ≤523 task-v071→≤540 task-v074）。另 `selftest-final-gate-hash.sh` 输出格式为 `结果: PASS=22 FAIL=0`（无 `Total` 行，非 FAIL）。
- **负结果报告**：① 排除了「本单元改动引入新 FAIL」——全量 51 脚本仅 skill-split 1 条 FAIL，且其读 SKILL.md 行数、与本单元 3 脚本无依赖；② 排除了「负断言被删除/减弱」——RR-09 负断言 `1-51` 保留并并入 `53`（覆盖更全）；③ 排除了「断言计数漂移」——4 脚本 Total 与基线一致；④ 排除了「触碰其他文件」——`git diff --numstat` 本单元仅 3 selftest 脚本（SKILL.md/critical-rules.md 系 sub:07/sub:08 既有未提交产物，本单元零触碰）；⑤ 排除了「误改 Rule 53 号」——仅改 `1-53`/`40-53` 纪元字面，`Rule 53` 规则号本体（如 `^### 53 `、`Rule 50/52/53`）未动。

#### [sub:10-executor-pin-sync] selftest-skill-split.sh T-主 行数钉 ≤478→≤490 同步（task-v138 纪元上调），回归 Total 41 FAIL=0

- **目标**：收尾 sub:09 登记的 out-of-scope blocker——`selftest-skill-split.sh` T-主 SKILL.md 行数钉 `≤478` 被 sub:08 的 SKILL.md 478→479（Rule 55 索引演进）打破；同步该钉恢复回归全绿。
- **扫描清单（worktree 内 `skills/task-planner/scripts/*.sh` 全量，区分行数钉/无关命中）**：
  - **行数钉（命中，需同步）**：`selftest-skill-split.sh:41` — `T-主 行数 ≤478` + `wc -l ≤478`（**已改**，见下）。
  - **SKILL.md 行数钉（同类但未破，不改）**：`selftest-execution-stability.sh:72` T8b `≤558`、`selftest-knowledge-brief.sh:38` T2b `≤558`、`selftest-skill-collab.sh:82` T10 `≤558`、`selftest-batch-pilot.sh:55` BP-08 `≤558`——均为**上限钉**（非收敛目标钉），479 ≤ 558 恒成立，不被 478→479 打破，按 §4.2 口径只同步 `≤478` 目标钉（先例 v074 仅上调目标钉），故保留。
  - **无关命中（非 SKILL.md 行数钉，不改）**：`selftest-skill-split.sh:5` 头注释「≤433 目标」（陈述性 doc 注释，非断言，且 v125-v133 历次演进均未同步该行，保持一致不改）；`selftest-skill-collab.sh:28` T1b `COLLAB ≤300`；`selftest-knowledge-brief.sh:34` T1c `BRIEF ≤150`；`selftest-agent-coverage.sh:197/206/208` `agent-coverage.md ≤128`；`selftest-plan-tier.sh:87` mini 模板 `≤80`；`selftest-tool-selection.sh:77` mini-lite `≤80`；`selftest-self-resolution.sh:97`（REGISTRY 行数）、`check-context-hygiene.sh:54`（FINDINGS）、`selftest-iterative-optimizer.sh:33`（TARGET）——均非 SKILL.md 行数钉。
  - `selftest-agent-coverage.sh:198` 注释提及「SKILL.md 行数在 selftest-skill-split.sh 有阈值断言（461→477 演进史）」= 指向性说明，非独立钉，不改。
- **改动方式（Rule 45 What+Why+When）**：单行行内改写 `selftest-skill-split.sh:41`——`≤478`→`≤490`（标题标签 + `wc -l -le` 断言字面各 1 处）、演进链追加 `task-v138 Rule 55 索引演进 +1（478→479）` 与 `→479`、先例追加 `v138`；行尾追加 `# task-v138 (2026-10-05): SKILL.md Rule 55 索引演进 478→479，钉随纪元上调（先例 v074 ≤523→≤540）`。**断言逻辑/计数不变**（仍为 `-le 490 && -le 558` 双检），禁净删。
- **验收证据（worktree 内实跑）**：改前 `bash selftest-skill-split.sh` → `Total: 41 PASS=40 FAIL=1`（FAIL 行 = `T-主 行数 ≤478`）；改后 → `Total: 41  PASS=41  FAIL=0`（T-主 行数 ≤490 PASS）；`bash -n selftest-skill-split.sh` exit 0；`wc -l SKILL.md`=479（≤490 成立）；`git diff --numstat -- selftest-skill-split.sh` = `1 1`（1 行内改写，+1/-1）。
- **兄弟行数钉脚本回归（确认未连带打破）**：`selftest-execution-stability.sh` `Total: 19 PASS=19 FAIL=0`；`selftest-knowledge-brief.sh` `Total: 16 PASS=16 FAIL=0`；`selftest-skill-collab.sh` `Total: 25 PASS=25 FAIL=0`；`selftest-batch-pilot.sh` `Total: 10 PASS=10 FAIL=0`（4 个 ≤558 钉全绿）。
- **负结果报告**：① 排除了「漏网同类钉」——全 scripts 目录 grep `478` 仅 1 命中（skill-split:41），grep `SKILL\.md.{0,40}(47[0-9]|48[0-9])` 仅 skill-split:41（钉）+ agent-coverage:198（注释）；② 排除了「≤558 上限钉被打破」——479 ≤ 558，4 脚本实跑全绿，无需上调；③ 排除了「误改无关命中」——头注释/其他文件行数钉（COLLAB/BRIEF/agent-coverage/mini）零触碰；④ 排除了「断言计数漂移」——Total 41 不变，PASS 40→41，仅 FAIL→PASS；⑤ 排除了「净删」——numstat `1/1`，单行内改写。
- **残余**：本单元 `git diff --numstat` 仅 `selftest-skill-split.sh` 1 行；worktree 全量 `git diff --stat` 另含 sub:07/sub:08/sub:09 既有未提交产物（SKILL.md、critical-rules.md、3 selftest 脚本），本单元零触碰。

#### [sub:11-executor-capability-script] agnes-quota.sh + capability-registry.md 新建落盘（Rule 55.4 首个能力实例 + 8 列唯一索引），实跑直查成功

**执行摘要**：在 worktree（`/home/terry/task-planner-skill-worktrees/task-v138`）内新建两文件——① `skills/task-planner/scripts/capabilities/agnes-quota.sh`（Agnes 账户额度/计费层直查脚本：key 候选链 + 零成本鉴权校准 + 强制绕缓存 + 原始字段如实呈现 + 判定行；Rule 55 首个落盘实例）；② `skills/task-planner/references/capability-registry.md`（Rule 55.4 唯一索引，8 列，首条=agnes-quota）。`capabilities/` 目录本任务前不存在（`ls` → No such file or directory），本单元 `mkdir -p` 首建。**实跑验证：脚本对 `https://api.agnes-ai.cn` 直查成功**——key_source=`bashrc:export`（脱敏 `cpk-fB...guim`；env 候选①鉴权 401 被校准淘汰后回退 .bashrc 候选），`subscription`/`usage` 两计费端点 HTTP 200，判定行命中「计费层数据未填充」。status=done，置信度 HIGH。

**① 脚本规格落实（对照 subagent-state/11-prompt-spec.md A.1-A.10，逐条）**：

| 规格项 | 落实 | 证据 |
|---|---|---|
| A.1 bash+curl / What+Why 双层 / 退出码 | 头注释 What（用途/用法/退出码 0=取到数据,2=用法错误,3=全部 key 无效,4=端点不可达）+ Why（Rule 55 首个实例；判例一=耗时累计反模式；判例二=CDN 缓存态 200 冒充鉴权证据） | `grep -c 'What（'`=1、`'Why（'`=1、`'退出码'`=3 |
| A.2 key 候选链按序 | env AGNES_API_KEY → AGNES_API_TOKEN → APIHUB_AGNES_API_KEY → `grep -E '^export AGNES_API_KEY=' ~/.bashrc \| head -1` 去引号（sed）；全程脱敏前6后4 | `add_cand` 四行 + `mask_key()`；实跑 key_source=`bashrc:export` |
| A.3 零成本鉴权校准（每候选一请求） | 控制组 `GET /agnesapi?video_id=probe-nonexist-<ns>&model_name=agnes-video-2.5-flash&_=<ns>`；401=无效→下一候选，非 401=通过；全无效 exit 3+指引 | 实跑：env 候选 401 淘汰 → bashrc 候选非 401 命中 |
| A.4 直查 ≤2 请求 | `GET /v1/dashboard/billing/subscription?_=<ns>` + `GET /v1/dashboard/billing/usage?start_date=<今日>&end_date=<明日>&_=<ns>` | 实跑两请求均 200 |
| A.5 全请求绕缓存 | `-H 'Cache-Control: no-cache' -H 'Pragma: no-cache'` + 随机 `?_=<epoch_ns>`（`ns(){ date +%s%N; }`） | `grep -c no-cache`=2、`ns` 用于三处 URL |
| A.6 输出两形态 + 判定行 | 人读分节 + `--json` 纯 JSON；limit=1e8 或 total_usage=0 时输出规定判定行 | 实跑人读/JSON 均出判定行；jq 解析 exit 0 |
| A.7 禁二次推算 | 只呈现原始字段，无「剩余额度」减法计算；头注释显式禁令 | `grep -cE 'hard_limit_usd *-'`=0 |
| A.8 base/curl/端点失败 | `BASE=https://api.agnes-ai.cn`；`curl -fsS --max-time 15`；端点连续失败 exit 4 | `grep -c 'api.agnes-ai.cn'`=2；bogus proxy 实跑 exit 4 |
| A.9 禁硬编码密钥 | 无密钥字面（注释用 `<KEY>` 占位） | `grep -icE 'sk-[a-z0-9]\|cpk-'`=0 |
| A.10 稳健性 | `bash -n` exit 0；curl 失败显式分支（000→报错/exit4）；`set -u` | `bash -n` exit 0；未知参数 exit 2、空 key exit 3、不可达 exit 4 三分支实跑 |

**② 注册表规格落实（对照 B）**：标题 `# 能力注册表（capability-registry — Rule 55.4 唯一索引）`；用途说明段含消费方=55.1 复用前置检查 / 维护方=55.3 首次成功即落盘（8 列必填、verified 日期=实测通过日）/ 部署=三宿主同步；表头 8 列（名称/脚本路径/用途/调用方式/数据来源端点/输出形态/verified 日期/任务来源）；首条=agnes-quota，8 列全非空。

**③ 自测验收（全部 PASS）**：

| 检查 | 命令 | 期望 | 实际 |
|---|---|---|---|
| 语法 | `bash -n scripts/capabilities/agnes-quota.sh; echo $?` | 0 | 0 |
| 禁密钥 | `grep -icE 'sk-[a-z0-9]\|cpk-' scripts/capabilities/agnes-quota.sh` | 0 | 0 |
| 注册表列数 | `awk -F'\|' '/agnes-quota/{print NF}'` vs 表头行 NF | 相等 | 10 = 10 |
| 首条 8 字段非空 | awk 逐字段判空 | 8 | 8 |
| 头注释 What+Why+退出码 | grep 计数 | 各≥1 | 1/1/3 |
| git status | `git status --short --untracked-files=all` | 仅 2 新增 | 2 新增 |
| 实跑（人读） | `bash .../agnes-quota.sh` | 结构化额度+判定行 | key_source/subscription/usage/verdict 齐 |
| 实跑（JSON） | `bash .../agnes-quota.sh --json \| jq -e ...` | 纯 JSON 可解析 | jq exit 0 |
| 退出码分支 | 未知参数/空 key/不可达 | 2/3/4 | 2/3/4 |

**④ 实跑原始输出（关键行，绕缓存直查）**：
- `key_source: bashrc:export (cpk-fB...guim)`
- `endpoints_reachable: /agnesapi=yes subscription=yes usage=yes`
- subscription：`{"object":"billing_subscription","has_payment_method":true,"soft_limit_usd":100000000,"hard_limit_usd":100000000,"system_hard_limit_usd":100000000,"access_until":0}`
- usage：`{"object":"list","total_usage":0}`
- verdict：`计费层数据未填充：剩余额度不可由本 API 推出；权威面=登录仪表板 Usage/Billing；HTTP 402=配额耗尽事后信号`
- 与 findings [sub:05]/[sub:06] 探针结论逐字段一致（保真度：结构可用、数值存疑，非推算值）。

**⑤ 负结果报告**：① 排除了「脚本语法/运行缺陷」——首版 `${!CAND_SRC[@]+...}` 数组展开 idiom 在 bash 下报 `invalid variable name`（`for i` 取到值而非索引），已改用 `"${!CAND_SRC[@]}"` + 空数组前置守卫，复跑四分支全过；② 排除了「硬编码密钥」——`sk-`/`cpk-` 形态 grep=0，key 全部运行期从 env/.bashrc 解析；③ 排除了「误用错误域」——错误域 token grep=0，base 唯一 `api.agnes-ai.cn`；④ 排除了「二次推算」——无额度减法表达式，仅原始字段 + 判定行；⑤ 排除了「误改其他文件」——`git status --untracked-files=all` 仅新增 2 文件，worktree 既有产物（Phase 2 已提交 d6cc6c8）零触碰。

**⑥ 对下游约束**：Phase 3 S2（两执行体 SOP 接线）应指向 `scripts/capabilities/agnes-quota.sh` + `references/capability-registry.md` 首条；Phase 3 S3（selftest-capability-persistence.sh）可断言：目录/文件存在、`bash -n`、注册表 8 列首条、脚本无密钥形态字面、`^55\.[1-6]` 条款锚；VC-2/VC-3 判定锚已满足。

#### [sub:12-executor-sop-wiring] 两生成执行体 SOP 前置检查段对称接线 Rule 55.5 额度查询复用指向行（各 +1 行，纯增量）

**执行摘要**：在 worktree（`/home/terry/task-planner-skill-worktrees/task-v138`）内对两个生成执行体 SOP 的 `## 🔒 前置检查（强制）` 段各追加 1 行同款「额度/配额查询复用」指向行，把 Rule 55.5「当日剩余额度以脚本直查值为唯一取值来源」条款挂到执行体消费侧（防条款死文，knowledge-brief §4 第 11 条）。**纯增量接线，零触碰既有行**（含 frontmatter/正文）。

**① 接线行（两文件同款，位于各自 key 核验 HARD_BLOCK 行之后）**：
`- **额度/配额查询复用（Rule 55.1/55.5）**：任何「剩余额度/配额/计费」类查询必须先查 references/capability-registry.md 并复用首条脚本 agnes-quota.sh（bash scripts/capabilities/agnes-quota.sh，含 key 校准与缓存绕过）；**禁止**耗时累计/抽样等估算冒充额度值（Rule 55.2），计费层未填充时如实呈报脚本 verdict，HTTP 402=配额耗尽事后信号`

**② 落点（实施日实测行号，知识包 §3 :38-40 锚已漂移，按实测重定位）**：
| 文件 | 前置检查段 | 插入位置 | 插入后行号 |
|---|---|---|---|
| `skills/task-planner/companion/agents/video-generation-executor.md` | :39 `## 🔒 前置检查（强制）`（原 :39-41） | key 核验行（:41）之后 | 新行 = :42 |
| `skills/task-planner/companion/agents/image-generation-executor.md` | :38 `## 🔒 前置检查（强制）`（原 :38-40） | key 在位行（:40）之后 | 新行 = :41 |

**③ 自测验收（全部 PASS，6/6）**：
| 检查 | 命令 | 期望 | 实际 |
|---|---|---|---|
| video 注册表指向 | `grep -c 'capability-registry'` | ≥1 | 1 |
| video 脚本指向 | `grep -c 'agnes-quota'` | ≥1 | 1 |
| image 注册表指向 | `grep -c 'capability-registry'` | ≥1 | 1 |
| image 脚本指向 | `grep -c 'agnes-quota'` | ≥1 | 1 |
| 纯增量（两文件） | `git diff --numstat` | ≤+2/-0 | 各 `1  0` |
| 既有首行不变 | `head -1 \| md5sum` | 不变 | `6105347ebb9825ac754615ca55ff3b0c`（前后一致） |

**④ 原始证据（关键行）**：
- `git diff --numstat` → `1  0  .../image-generation-executor.md` / `1  0  .../video-generation-executor.md`
- `wc -l` 前后：video 68→69、image 67→68（仅增 1，符合 +1/+2 口径）
- `git status --short --untracked-files=all` → 仅 2 个 executor 为 ` M`，另 2 新增文件（sub:11 的 capability-registry.md / agnes-quota.sh）保持 `??`，无其他 tracked 改动

**⑤ 负结果报告**：① 排除了「误改既有行」——diff 为单行 `+` 且 md5 首行不变、numstat 均 -0；② 排除了「越界改其他文件」——`git status` 仅命中本 S-unit 范围 2 文件；③ 排除了「未对齐 Rule 55.2/55.5 语义」——行内显式含 Rule 55.1/55.5 复用前置 + Rule 55.2 禁估算冒充 + 402 事后信号，与 knowledge-brief §4 第 11 条（禁条款死文）一致；④ 排除了「两文件不对称」——两文件 grep 计数逐项相等（1/1 = 1/1）。

**⑥ 对下游约束**：Phase 3 S3（selftest-capability-persistence.sh）可新增断言：两 executor 各 `grep -c 'capability-registry'`≥1 且 `grep -c 'agnes-quota'`≥1（SOP 消费侧挂点存在性守护）。

#### [sub:13-executor-selftest] selftest-capability-persistence.sh 新建 + registry.tsv 登记（Rule 55.6 机器面落地，18 断言全 PASS）

**① 产出**：
- 新建 `skills/task-planner/scripts/selftest-capability-persistence.sh`（177 行，`bash -n` 通过，+x）：Rule 55 静态守护，CP-01..CP-18 共 18 断言。
- `skills/task-planner/scripts/selftest-registry.tsv` 末尾追加 1 行（52→53 行；4 列 Tab 对齐，列数=表头=4）。

**② 断言覆盖（对齐规格 §A 八条）**：CP-01/02/03=crtical-rules `^### 55 `=1 / `^55\.[1-6] `=6 / 块首含 task-v138；CP-04/05/06=SKILL `Rule 55`≥3 / `40-55`=1 / `40-53`=0（演进收口）；CP-07/08/09=capability-registry 存在 / 表头 8 列 / agnes-quota 行 8 字段全非空；CP-10..13=agnes-quota.sh 存在 / `bash -n` / 无硬编码密钥 / 头注释含 Rule 55；CP-14/15=两 executor 各含 `capability-registry`≥1；CP-16=config.json properties=40（零新键）；CP-17/18=脚本自身 SCRIPT_DIR 自定位行 + 头注释 What+Why（Rule 45）。

**③ 原始证据（关键行）**：
- `bash scripts/selftest-capability-persistence.sh` → `Total: 18 PASS=18 FAIL=0`，exit 0（skill 目录与 /tmp 绝对路径两处均同）。
- 负向测试（临时副本于 /tmp，仓外，未改仓库）→ `Total: 18 PASS=2 FAIL=16`，exit 1（验证 FAIL>0 退出码分支）。
- tsv：`wc -l`=53（52→53）；新行 `awk -F'\t' '{print NF}'`=4=表头；`git diff --numstat -- scripts/selftest-registry.tsv` → `1  0`。
- 回归未波及：`selftest-veto.sh` → `Total: 13 PASS=13 FAIL=0`；`selftest-media-dispatch.sh` → `Total: 9 PASS=9 FAIL=0`；`selftest-registry.sh` → `Total: 5 PASS=5 FAIL=0（registry rows=52, actual selftest=52）`。

**④ 负结果报告**：① 排除了「误触既有 selftest 断言行」——`git status --short` 仅本 S-unit 命中 1 新增脚本（`??`）+ tsv（` M`），无既有 selftest 脚本 tracked 改动；② 排除了「tsv 列错位」——53 行逐行 `NF` 全 =4；③ 排除了「脚本只能在 worktree 跑」——/tmp 绝对路径运行结果同（自定位相对解析生效）；④ 排除了「零新键破坏」——CP-16 断言 properties=40 通过，且 config.json 未改动（`git status` 无 config.json）。

**⑤ 排雷（实施中真实命中）**：首版消息串内用反引号包裹代码片段（`` `### 55 ` ``），双引号内反引号被 bash 当命令替换 → CP-01/04/05/06/11 消息文本被吞/报 `command not found`；已改单引号 `'...'` 包裹，重跑全 PASS。教训=printf/ok 消息参数内禁裸反引号。

**⑥ 对下游约束**：Phase 4 S1 全量回归目标总数=52 脚本（本脚本已入列），FAIL 计数须=0；总数以主进程逐脚本 `Total` 行求和为准（禁采信子代理自报）。

#### [sub:14-code-runner-regression] 全量 selftest 回归 52/52 脚本 FAIL=0（worktree task-v138，纯机械验证零改动）

**① 产出/执行**：在 `/home/terry/task-planner-skill-worktrees/task-v138/skills/task-planner/scripts` 逐脚本执行 `timeout 60 bash "$f"`，52 个 `selftest-*.sh` 全部 rc=0，无挂起（最长 `selftest-final-gate-hash.sh` 16.9s，次长 `selftest-vc-gate.sh` 16.2s）。原始日志落 `/tmp/selftest-v138/log/<script>.log`（52 个），汇总行 `/tmp/selftest-v138/summary.txt`。

**② 每脚本 Total 行（原样，禁自报汇总）**：
```
selftest-active-plan.sh                 Total: 19 PASS=19 FAIL=0
selftest-agent-coverage.sh              Total: 9 PASS=9 FAIL=0 SKIPPED=0
selftest-ask-default-timeout.sh         Total: 11 PASS=11 FAIL=0
selftest-batch-pilot.sh                 Total: 10 PASS=10 FAIL=0
selftest-capability-persistence.sh      Total: 18 PASS=18 FAIL=0
selftest-check-conflicts.sh             Total: 7 PASS=7 FAIL=0
selftest-check-drift.sh                 Total: 6 PASS=6 FAIL=0
selftest-conclusion-discipline.sh       Total: 24 PASS=24 FAIL=0
selftest-context-hygiene.sh             Total: 12 PASS=12 FAIL=0
selftest-delegation.sh                  Total: 38    PASS=38  FAIL=0
selftest-dispatch-grain.sh              Total: 10 PASS=10 FAIL=0
selftest-dispatch.sh                    Total: 31 PASS=31 FAIL=0
selftest-error-loop.sh                  Total: 16 PASS=16 FAIL=0
selftest-execution-stability.sh         Total: 19  PASS=19  FAIL=0
selftest-fallback.sh                    Total: 31  PASS=31  FAIL=0
selftest-final-gate-hash.sh             ==== selftest-final-gate-hash 结果: PASS=22 FAIL=0 ====
selftest-fine-grain-steps.sh            Total: 11 PASS=11 FAIL=0
selftest-interaction.sh                 Total: 11 PASS=11 FAIL=0
selftest-iterative-optimizer.sh         Total: 8 PASS=8 FAIL=0
selftest-knowledge-brief.sh             Total: 16  PASS=16  FAIL=0
selftest-lane-advancement.sh            Total: 14 PASS=14 FAIL=0
selftest-mechanism-profile.sh           Total: 19 PASS=19 FAIL=0
selftest-media-agents.sh                Total: 10 PASS=10 FAIL=0
selftest-media-dispatch.sh              Total: 9 PASS=9 FAIL=0
selftest-methodology.sh                 Total: 16 PASS=16 FAIL=0
selftest-plan-dispatch.sh               Total: 12 PASS=12 FAIL=0
selftest-plan-tier.sh                   Total: 32 PASS=32 FAIL=0
selftest-reflect-verify.sh              Total: 12 PASS=12 FAIL=0
selftest-registry.sh                    Total: 5 PASS=5 FAIL=0 (registry rows=52, actual selftest=52)
selftest-reliability-institution.sh     Total: 16 PASS=16 FAIL=0
selftest-requirement-coverage.sh        Total: 23 PASS=23 FAIL=0
selftest-requirement-grading.sh         Total: 7 PASS=7 FAIL=0
selftest-rescue-chain.sh                Total: 11 PASS=11 FAIL=0
selftest-review-library.sh              Total: 15 PASS=15 FAIL=0
selftest-root-resolution.sh             Total: 17 PASS=17 FAIL=0
selftest-rule23-conflict-scan.sh        Total: 3 PASS=3 FAIL=0
selftest-rule-reserve.sh                Total: 10 PASS=10 FAIL=0
selftest-self-resolution.sh             Total: 13 PASS=13 FAIL=0
selftest-shared-tracker.sh              Total: 11 PASS=11 FAIL=0
selftest-skill-collab.sh                Total: 25  PASS=25  FAIL=0
selftest-skill-modify.sh                Total: 9 PASS=9 FAIL=0 (SKIP=0)
selftest-skill-split.sh                 Total: 41  PASS=41  FAIL=0
selftest-smart-merge.sh                 Total: 17 PASS=17 FAIL=0
selftest-sync-index.sh                  Total: 13 PASS=13 FAIL=0
selftest-task-boundary.sh               Total: 11 PASS=11 FAIL=0
selftest-template-lifecycle.sh          Total: 24 PASS=24 FAIL=0
selftest-template-sense.sh              Total: 8 PASS=8 FAIL=0
selftest-tier-b.sh                      Total: 18 PASS=18 FAIL=0
selftest-tool-selection.sh              Total: 12 PASS=12 FAIL=0
selftest-vc-gate.sh                     Total: 11 PASS=11 FAIL=0
selftest-veto.sh                        Total: 13 PASS=13 FAIL=0
selftest-workflow-orchestration.sh      Total: 16 PASS=16 FAIL=0
```
- FAIL>0 脚本：**无**（`grep -nE '\[FAIL\]|\[FAILED\]|FAIL=[1-9]|FAIL: [1-9]' *.log` → 零命中；52/52 行均 `FAIL=0`）。
- 计数口径说明：51 脚本自报 `Total:` 行，`selftest-final-gate-hash.sh` 用等价终态行 `结果: PASS=22 FAIL=0`（该脚本 grep 'Total' 零命中属**格式差异非缺失**，日志全文 25 行完整可读，退出码 rc=0）。

**③ 附加核验（本 S-unit 要求）**：
- `wc -l ../references/critical-rules.md ../SKILL.md` → `606 references/critical-rules.md` / `479 SKILL.md`（期望 606/479 ✓，与 Phase 2 落盘后行数一致）。
- `ls capabilities/`（于 scripts 目录）→ `agnes-quota.sh`（期望命中 ✓）；`ls selftest-*.sh | wc -l` → 52（= knowledge-brief §2 基线 51 + sub:13 新增 1）；`wc -l selftest-registry.tsv` → 53 行（52 条目 + 表头），与 registry 自检 `registry rows=52, actual selftest=52` 互证。

**④ 负结果报告**：① 排除了「隐藏失败」——merged stderr 后全量 grep `\bERROR\b|\bFailed\b|Traceback|command not found` 零命中，exit=0 无 stderr 噪声；② 排除了「超时/挂起」——无 `timed out|Killed|Terminated` 标记，单脚本最长 16.9s 远低于 60s 上限，无脚本被跳过；③ 排除了「回归污染工作树」——`git status --short` 空输出（回归前后同一 HEAD `62561a1`），本 S-unit 零文件写入（仅 /tmp 日志 + 计划三文件回填）；④ 排除了「脚本数口径漂移」——registry 自检断言 rows=52 与 ls 实测 52 双双对齐。

**⑤ 对下游约束**：本结果支持 VC-5 判据「52 脚本全量回归 FAIL=0」；断言总数由主进程逐 `Total` 行相加核对，禁采信本报告任何自算合计（本报告刻意未给合计数字）。

#### [sub:15-code-quality-review] 代码面审查（P4-S2）：agnes-quota.sh + selftest-capability-persistence.sh + 纪元同步 diff — 结论 **CHANGES_REQUESTED**（1 阻塞 + 4 LOW 建议）

**执行摘要**：对 task-v138 全部 bash 脚本类落盘资产做只读代码审查：① `scripts/capabilities/agnes-quota.sh`（185 行）；② `scripts/selftest-capability-persistence.sh`（177 行）；③ 任务 diff `b03fd36..62561a1`（4 处纪元同步 + SKILL.md/executor/registry/tsv 接线一并过目）。**基准修正（如实登记）**：派发时点 worktree 已合并回 master 且被移除（`git worktree list` 仅主仓，merge=`1992566`），故审查以 git 对象库 `62561a1`（worktree 末态 HEAD）为基准——两目标脚本在 62561a1 与当前 master **逐字节一致**（md5 `4ae35b9dfe38926da0e00b778c2c83b3`；`git diff 62561a1..HEAD -- <两脚本>` 为空）。结论：**主路径全绿；错误路径存在 1 个可复现的伪成功判定缺陷（阻塞项 F1）；另 4 条 LOW 建议非阻塞**。

**逐维结论**：
| 维度 | 结论 | 关键证据 |
|---|---|---|
| 1 正确性 | **FAIL（1 阻塞 F1）** | 主路径实跑 rc=0（key_source=bashrc:export、两计费端点 200、verdict=未填充）；退出码 2/3/4 实测；校准实测剔除无效 env 候选（401）；**非 2xx 错误路径 verdict 伪成功（mock 复现，见 F1）** |
| 2 安全性 | PASS | 无硬编码密钥（`grep -icE 'sk-[a-z0-9]|cpk-'`=0）；真实 key 全字面在 human/JSON/stderr 三输出零泄漏；仅脱敏 前6...后4；无 set -x；apihub 错误域零命中 |
| 3 可移植性 | PASS | guard 从仓库 cwd 与 `/` cwd 两处实跑 18/18；两脚本无绝对路径字面；jq→python3→SKIPPED fail-open 降级链在位（先例 R-12/MD-08）；全相对 `SCRIPT_DIR` 解析 |
| 4 注释完整性 | PASS | 两脚本 What+Why 双层头注释 + 函数/每 CP What/Why；4 处纪元同步行均带 `# [2026-10-05 task-v138 演进重锚]` 标注（Rule 45） |
| 5 守卫质量 | PASS（2 条 LOW 建议） | 负向孤本 PASS=2/FAIL=16（与 sub:13 一致）；5 组定向变异全部咬合（CP-12/02/05+06/14/17 各 FAIL、rc=1）；RR-09 负断言并集 `1-(51|53)` 强度增强；断言计数零漂移（17/16/13/41） |
| 6 禁推算合规 | PASS | 全脚本仅计数器算术（`$((NET_FAIL+1))`）；无额度字段减法/耗时累计；verdict 显式「不推算」；WORK_KEY 仅经 mask_key 输出 |

**F1（阻塞 — 错误路径伪成功判定）**
- 位置: `skills/task-planner/scripts/capabilities/agnes-quota.sh:150-160`（辅证 `:116`）
- 原文: `verdict='计费层已回传数值（本脚本仅直查原始字段，不推算剩余额度；权威面=登录仪表板 Usage/Billing）'`（:154）；`reach_sub=0; [ "$sub_code" != '000' ] && reach_sub=1`（:150）；`if [ "$code" = '401' ]; then continue; fi`（:116）
- 问题: 默认 verdict「已回传数值」仅在两条启发式（body 含 `100000000` / `total_usage`=0）均不命中时输出。对非 2xx 响应（401/403/429/5xx）：`curl -f` 抑制错误体 → body 为空；`reach_*=1`（非 000 即「可达」）→ verdict 输出「计费层已回传数值」，而实际 JSON=`null`、人读=`<空>`、exit=0——与脚本自述「0=取到数据」及计划「禁伪造直查成功」相悖。触发现实性：429 限流为文档化常态（findings [sub:02]），且 `:116` 校准把「非 401」一律当工作 key（429/403/5xx 会被误收），两路径叠加即落入该分支。
- 复现（review 实测，mock 于 /tmp，未触碰仓库）: /agnesapi→404、billing→401 的本地 mock 实跑 → 输出 `"subscription": null` 与 `"verdict": "计费层已回传数值..."`，rc=0
- 建议修法: ① `:150-160` 增 `ok_sub/ok_use`（仅 2xx 置 1），任一非 2xx 输出新 verdict「计费端点返回非 2xx（subscription=HTTP X, usage=HTTP Y）：无法判定计费层状态（鉴权/限流/服务端错误），禁按返回值解读」；仅两码均 2xx 才进入「已回传数值/未填充」二分支；② 可选收窄 `:116` 接受条件为「404（明确 not-found 语义）」；③ 头注释退出码段（:10-13）同步新口径；④ 本地 mock 回归 401/429/5xx 三分支
- 置信度: HIGH（缺陷存在性，有复现）；严重度 MEDIUM（主路径实测无此问题，仅异常路径）

**非阻塞建议（LOW，建议登记后续维护窗口）**
- F2 `:157-158` 判定正则 `'"total_usage"[[:space:]]*:[[:space:]]*0([^0-9]|$)'` 对 `"total_usage":0.5` 假阳性（demo 实测「0.5 MATCHES」），建议改 `0(\.[0]*)?([^0-9.]|$)` 或 jq 数值比较。置信度 HIGH，影响 LOW
- F3 纪元同步 4 处断言**逻辑**已更新且强度未减，但**显示文本与兜底分支滞后**：`selftest-root-resolution.sh:105/:107`（消息仍写 1-53/1-51）、`:165`（RR-16 兜底分支仍判 `50` 与 `53`，未随 55 纪元更新）、`:159-160` 注释；`selftest-reliability-institution.sh:83`（消息写 40-53）；`selftest-self-resolution.sh:72/:74`（消息写 40-53）。仅影响调试可读性与兜底覆盖，不影响现行判定。置信度 HIGH
- F4 `agnes-quota.sh` 存储模式 100644，同仓操作脚本（init-session/smart-merge-back/selftest-veto）均 100755；文档调用为 `bash <path>` 故功能不受影响，建议按部署惯例统一为 755。置信度 HIGH（`git ls-files -s` 实测）
- F5 `:120-127` exit 3 分支在「部分候选 000 + 其余 401」时统一报「全部 key 候选鉴权无效（控制组 HTTP 401）」，未提示存在网络失败候选；建议消息附 NET_FAIL 计数（退出码语义可保持）。置信度 MEDIUM（代码面推演）

**验证证据（本审查实跑）**：
- guard 基线: `bash selftest-capability-persistence.sh` → `Total: 18 PASS=18 FAIL=0` rc=0（仓库 cwd 与 `/` cwd 两处同）
- 负向孤本（/tmp 无树副本）: → `Total: 18 PASS=2 FAIL=16` rc=1（与 sub:13 一致；两 PASS=CP-17/18 自检）
- 变异咬合 ×5（/tmp 镜像 @62561a1，各 rc=1）: 注入 `cpk-deadbeef0000`→CP-12 FAIL；删 `55.6` 行→CP-02 FAIL（计数=5）；SKILL `40-55`→`40-53`→CP-05/06 FAIL；删 video 接线→CP-14 FAIL；替换 SCRIPT_DIR→CP-17 FAIL
- 主路径实跑: human rc=0（`key_source: bashrc:export (cpk-fB...guim)`、subscription/usage 均 200、verdict=未填充）；`--json` 8 行纯 JSON，jq 解析 rc=0
- 密钥泄漏扫描: 真实 key 全字面 grep human/JSON/stderr 三输出 → 零命中
- 退出码: 未知参数 rc=2、无候选 rc=3、死代理全连接失败 rc=4
- 合规扫描: 无额度字段算术、无绝对路径/apihub、config properties=40、tsv 末行列数=4

**负结果报告**：① 排除硬编码/泄漏密钥（grep=0 + 三输出零泄漏）；② 排除绝对路径与 apihub 误域（两脚本 grep 零命中）；③ 排除净删（diff 全部 +N/-N 行内改写，逐文件 numstat 平衡；SKILL 行内改写为已登记唯一例外）；④ 排除断言计数漂移（17/16/13/41 不变）；⑤ 排除 config 改动（properties=40 实测）；⑥ 排除守卫在后续任务纪元变动下失稳（当前 master 仍 18/18）；⑦ **未验证项**：三宿主部署位实跑（artifact 尚未部署，属 Phase 5 待办；脚本全相对解析 + 双 cwd 实跑已覆盖结构面）——非缺陷，登记为审查限制。

**对下游约束**：按计划 Phase 4 S2 契约「CHANGES_REQUESTED 项全部闭环后才进 Phase 5」——**F1 为放行前置**；F2-F5 建议登记后续维护窗口；F1 闭环后建议复跑 mock 三分支 + 本审查 5 组变异 + 全量回归。

#### [sub:16-executor-f1-fix] Phase 4b S1：agnes-quota.sh F1 缺陷修复（200-only 成功判据 + exit 5）+ selftest CP-19/20 mock 负向断言（工作树 wt/task-v138b @fed4393）

**执行摘要**：在新 worktree `/home/terry/task-planner-skill-worktrees/task-v138b`（branch `wt/task-v138b`，HEAD `fed4393`，含 v138+v139 全部产物）内修复审查 F1 阻塞项并补 selftest 运行时回归钉。仅改 2 文件（`git status --short` 仅此 2 文件 `M`，`git diff --numstat` = agnes `47/21` + selftest `91/1`）。**status=done，置信度 HIGH**。

**① F1 修复（agnes-quota.sh，211 行）——原行为→新行为**：
| 维度 | 原行为（F1 缺陷） | 新行为 |
|---|---|---|
| 成功判据 | `reach_*=1` 当 `http_code != 000`（非连接失败即「可达」） | `ok_sub/ok_use=1` 仅当 `code=200`；非 200（含 000/4xx/5xx）一律失败 |
| 非 2xx 判定 | curl -f 抑制 body → 空 body + reach=1 → 落默认成功 verdict「计费层已回传数值」+ exit 0（伪成功） | 双失败 verdict「计费端点均未返回有效数据（subscription=HTTP X, usage=HTTP Y）：两个端点均非 HTTP 200，无法判定计费层状态（鉴权/限流/服务端错误/不可达）；禁按返回值解读」/ 单失败 verdict「计费端点部分不可达（subscription=X usage=Y）：本次无法判定计费层状态…」→ **exit 5** |
| 双 200 | 三态（已回传/未填充）判定 + exit 0 | 保留不变（默认行为不变） |
| 退出码 | 0/2/3/4（4=控制组或计费端点 000） | **0/2/3/4/5 全集**（头注释+usage 同步）；5=计费端点非 200；4 收窄为控制组 /agnesapi 全候选连接失败 |
| endpoints_reachable | 非 000 口径 | 200 口径（human + JSON 两处） |
| 可测试性缝 | 无 | `BASE="${AGNES_QUOTA_BASE:-https://api.agnes-ai.cn}"`（头注释注明仅测试用途，默认不变） |
| 注释 | — | 判例三按 Rule 45 三要素（现象/根因/原行为→新行为）；规避密钥扫描误报不写任务目录全字面（"task-v…"含 `sk-v` 子串） |

**② selftest 增补（selftest-capability-persistence.sh，267 行；既有 CP-01..CP-18 零改动）**：
- python3 本地 mock（`mktemp -d`，仅绑 `127.0.0.1` 随机端口，404/200 固定体；teardown 清临时目录+后台进程；`timeout 20`；缺 python3/curl/timeout 则 SKIPPED fail-open，先例 CP-16）
- **CP-19**（404 模式）：`AGNES_QUOTA_BASE=http://127.0.0.1:<port>` → 断言 `exit≠0` 且输出含失败语义（`无法判定|失败|不可达`）且**禁含**「计费层已回传数值」
- **CP-20**（200 模式，subscription 含 1e8 占位）：→ 断言 `exit=0` 且 verdict 含「未填充」

**③ 自测验收（全部 PASS）**：
| 检查 | 命令 | 期望 | 实际 |
|---|---|---|---|
| 语法（两文件） | `bash -n` | 0 | 0 |
| 禁硬编码密钥 | `grep -icE 'sk-[a-z0-9]\|cpk-'` agnes | 0 | 0（首版含 "task-v138b"→=4，按原文件规避约定改写后=0） |
| selftest 全绿 | `bash selftest-capability-persistence.sh` | FAIL=0，断言 18→≥20 | `Total: 20 PASS=20 FAIL=0` exit 0（仓库 cwd 与 `/` cwd 同） |
| 断言 A 命中 | CP-19 实跑 | exit≠0+失败语义禁伪成功 | exit=5，verdict=「均未返回有效数据…无法判定…」 |
| 断言 B 命中 | CP-20 实跑 | exit 0+未填充 | exit=0，verdict=「计费层数据未填充…」 |
| 真端点不变 | `bash agnes-quota.sh --json` | exit 0 | exit=0（key_source=bashrc:export、两计费端点 200、verdict=未填充） |
| 全量回归 | 53 脚本逐跑 | FAIL=0 | 53/53 FAIL=0（含 final-gate-hash `结果: PASS=22 FAIL=0`） |
| diff 范围 | `git diff --stat` | 仅两文件 | 仅 2 文件（agnes 47/21、selftest 91/1） |

**④ 咬合力验证（断言非空转）**：把修复后脚本的 ok 判据 mutate 回 F1 旧逻辑（`ok=1; [ code=000 ] && ok=0`），对 404 mock 实跑 → **复现 `rc=0` + `"subscription": null` + verdict「计费层已回传数值」**（与 [sub:15] F1 mock 复现逐字一致）→ 该变异下 CP-19 必 FAIL，证明断言对 F1 有咬合力。

**⑤ 负结果报告**：① 排除「误改既有 18 断言」——CP-01..CP-18 零触碰（仅头注释计数 18→20 + 追加 CP-19/20）；② 排除「硬编码密钥」——`sk-`/`cpk-` 形态 grep=0（首版误报已按原文件「不写任务目录全字面」约定消除）；③ 排除「改动越界」——`git status --short` 仅两文件 M，无新增/删除文件；④ 排除「回归破坏」——全量 53/53 FAIL=0，兄弟脚本全绿；⑤ 排除「真端点行为漂移」——exit 0、字段与 sub:11/sub:14 一致；⑥ 排除「mock 泄漏到真实网络」——mock 仅绑 127.0.0.1，测试注入 AGNES_QUOTA_BASE 后 curl 只打回环。

**⑥ 决策登记（双失败含两码均 000 的路由）**：按 dispatch「非 200（含 000/4xx/5xx）一律失败 + 双失败→exit 5」字面实现，**移除**旧「两码均 000→exit 4」块；exit 4 语义收窄为「控制组 /agnesapi 对全部候选连接失败」（bogus proxy 场景仍 exit 4，与 sub:11 一致）。task_plan 修复项①「退出码非 0（区分 3/4）」= 新码 5 与既有 3/4 相区分，方向一致。

**⑦ 对下游约束**：S2（code-runner-agent）复验 = mock 404/000 咬合 + 全量 FAIL=0 + 本文件 `git diff --stat` 仅两文件；F2-F5（[sub:15] LOW 非阻塞）未处理，留后续维护窗口；本 S-unit 未 commit（Phase 5 编排逐 Phase commit + smart-merge-back --deploy）。

#### [sub:18-alignment-review] Phase 4 S3 对齐审查（Rule 42.6.2 标准收尾）—— 结论 **APPROVED**（0 P0/P1 + 2 LOW 陈旧观察）

审查基准 = task_plan.md R1-R4 原文 + 根源覆盖表八工序 + VC 表；审查对象 = 主仓 `5ed69e7` 工作区实文件（Read 实读，非 worktree 副本）；模式 = 只读审查，零仓库文件改动。

**① R1-R4 逐条机制载体（4/4 COVERED）**
- R1（及时落盘到固定脚本/文档）→ `critical-rules.md:619`（55.3 落盘=DoD，①可脚本化→`scripts/capabilities/` ③纯知识→`references/`）+ `:620`（55.4 固定位置）+ 实体 `scripts/capabilities/agnes-quota.sh`（211 行，`bash -n` 过）+ `references/capability-registry.md:10` 首条登记
- R2（不重复现场发明）→ `:617`（55.1「命中既有脚本或登记行 → **直接复用，禁止现场重新实现**」）+ `:621`（55.5 接线，「条款无挂点=条款死文（53.2 反例）」）+ 挂点 `video-generation-executor.md:43` / `image-generation-executor.md:42`
- R3（API 直查，结果完全不对）→ `:618`（55.2 权威来源优先禁令 + P1 探针判例「间接观测值冒充直查值」）+ 脚本判定段 `agnes-quota.sh:169-183`（非 200 → 显式失败 verdict + exit 5；仅两码均 200 才进二态判定 exit 0）+ `:24-26` 反模式注释 + 机器守护 CP-19/CP-20（本次实跑 20/20 PASS）
- R4（通用执行纪律层，非视频个案补丁）→ 载体 = `critical-rules.md:613` `### 55` 块（技能体系通用条款层，判别特征泛指「查询类外部事实/重复≥2次固定多步/存在权威数据源」）；反向核查 = 视频额度仅为**注册表首条**与 55.5 挂点示例，55.1/55.3/55.4/55.6 全部泛指表述 + CP-01..CP-20 锚定通用条款/注册表/目录锚，非视频特化 → 通用性成立；注册表首条 8 列完整（CP-08/CP-09 PASS）+ 三宿主部署位逐位 IDENTICAL

**② 根源覆盖表八工序逐行核销（8/8）**：①→`:617` 三判别特征；②→`:617`+`:620` 固定位置；③→`:618`+脚本判定段；④→`:619`「落盘是 DoD」+实体脚本；⑤→`:620` 8 列枚举 + registry `:8/:10` + 三宿主 IDENTICAL；⑥→`:621` + 两 executor `:43/:42` 对称接线 + CP-14/15；⑦→`selftest-capability-persistence.sh`（CP-01..CP-20，实跑 20/20）+ `selftest-registry.tsv:54` 登记行 + CP-16（config `.properties` 实测 **40**）；⑧→HEAD `5ed69e7` + `git worktree list` 仅主仓一行 + 三宿主 `diff -q` IDENTICAL + `.rule-reservations.jsonl` 末行 `{"rule":55,"status":"landed","task_id":"task-v138","ts":"2026-10-06"}`

**③ 变更纪律（3 项全过）**
- 纯增量：v138 三 commit numstat = d6cc6c8（critical-rules **+13/-0** 纯增；SKILL +4/-3 三处删行**全为纪元行内改写** `:9/:268/:334`，属执行范围表登记的唯一例外，禁净删成立；4 既有 selftest 纪元跟随同步，Decisions Made 2026-10-05 silent 已授权）/ 62561a1（**+375/-0 全纯增**）/ 8b12495（仅动 v138 自建 2 文件，selftest -1 = 头注释计数 18→20 行内改写）
- **归属澄清**：`b03fd36..5ed69e7` 中 critical-rules 的 2 处删行（`-41.1`、`-53.3`）经 `git show 536e07d` 确认**归属 v139**，不在 v138 范围 → v138 范围内零净删
- 零新 config 键：`git diff --name-only b03fd36..5ed69e7 -- skills/task-planner/config.json` 命中 **0** 行；`.properties` 键数实测 40

**④ 交叉引用真实性 11/11**：23.10 / 43.1 / 43.6 / 51.8 / 34.3 / 45(`### 45` @`:470`) / 53.2(`:590`) / 54.1(`:599`) / 36.5 / 22.3.0(`:164`) / 41.2 全部实存，无悬空编号。

**⑤ LOW 观察（不阻断）**：LOW-1 `critical-rules.md:618` 55.2 内嵌注记「Rule 54.1…task-v136 预留未落地」已陈旧（v136 已于 `b2d38e5` 落地、`:599` 现为已落地条款），语义指向正确仅状态注记滞后，修法=单行括注改「已落地」；LOW-2 VC-5 字面「总数 51+1=52」vs 实测 53 脚本（差额 = v136 并行新增 `selftest-execution-honesty.sh`），Phase 4b 已自行修正基线为 53 且 findings [sub:16] 记录 53/53 FAIL=0 → 计划文档字面滞后，非资产缺陷。[sub:15] F2-F5 四条 LOW 按 `findings [sub:16] §⑦` 显式登记留后续维护窗口，不属 R1-R4 对齐面。

**⑥ 结论**：APPROVED，无 P0/P1 遗留，Phase 5 可继续终验编排。完整报告 = `subagent-state/18-alignment-review.md`。

## Technical Decisions
<!-- 技术选型/方案决策:一行摘要进 task_plan.md Decisions 表,论证过程写这里 -->
| Decision | Rationale |
|----------|-----------|
|          |           |

## Issues Encountered
<!-- 阻塞/意外问题与解法;代码错误走 progress.md Error Log(Rule 19.4) -->
| Issue | Resolution |
|-------|------------|
|       |            |

## Resources
<!-- 有用的 URL/文件路径/API 引用,发现即记 -->
-

## Visual/Browser Findings
<!-- 截图/PDF/网页等多模态信息必须立即转文字落盘(多模态不持久) -->
-

---
<!-- ⚠️ [plan-compass] 提醒 = 本文件陈旧 → 立即回填再继续(Rule 19.7);二次未响应触发升级警告(Rule 26.3 处置) -->
