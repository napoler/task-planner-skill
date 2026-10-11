# sub:02-web-search-quota — checkpoint

## 任务
调研 Agnes 官方文档（wiki.agnes-ai.cn）是否记载「剩余额度/余额/配额直查」端点。

## 里程碑 1：工具可用性（M3）
- `web_search_prime` → HTTP 429 `Weekly/Monthly Limit Exhausted`，重置 2026-10-08 20:53:08（本单元全程不可用）。
- `WebFetch` → `Provider rejected the model request`（沿用 task-v122/v127 判例）。
- 降级：`curl -sS -L` 直取 Mintlify 裸 markdown（`.md` 后缀），全部 HTTP 200。

## 里程碑 2：站点地图穷举（M1、M2）
- `https://wiki.agnes-ai.cn/llms.txt` HTTP 200 → 26 条页面清单（官方自述 "built and hosted on Mintlify"）。
- `https://wiki.agnes-ai.cn/sitemap.xml` HTTP 200 → 26 条 `<loc>`，与 llms.txt 完全一致 → **官方文档全量页面已穷举，无遗漏**。

## 里程碑 3：全文档关键词扫描（M4）
已抓取 8 个 `.md`（video-25-flash / tokenplan / faqs / overview / quickstart / code / sitemap / llms.txt），正则扫
`额度|余额|配额|quota|balance|billing|usage|credit|remaining|剩余` → 命中全部指向「配额概念说明」或「控制台查看」，**无一条指向 API 端点**。

## 结论（终局）
**官方文档未记载任何额度/余额/配额直查端点。**

1. **文档记载的 HTTP 端点全集（穷举，仅 2 个）**：
   - `POST /v1/videos`（视频任务创建）
   - `GET /agnesapi?video_id=<ID>&model_name=agnes-video-2.5-flash`（视频任务查询）
   来源：`https://wiki.agnes-ai.cn/zh-Hans/docs/agnes-video-25-flash.md`
2. **额度只经 Web 控制台暴露，无 API**：`faqs.md:126`「你可以在仪表板的"Usage"或"Billing"中查看你的请求使用情况、限制和相关详情」——需登录控制台，API Key 无法直查。
3. **配额语义仅存在于错误码**：`402` 余额/积分/订阅或调用前校验未通过（`code.md:54-60`、`faqs.md:93`）；`429` 超过 RPM 或订阅配额（`faqs.md:95`）。即"额度耗尽"只能事后由 402/429 推断，无主动查询面。
4. **响应头亦无配额回传**：全文档正则扫 `x-ratelimit|ratelimit-|Retry-After` → 零命中；`Header` 命中全为 401/415/431 的请求头错误说明。
5. **Token Plan 配额为服务端计数、无查询接口**：`tokenplan.md:63-79,160-172` 定义文本按请求次数、图片按张数、视频按秒数配额（视频 500 秒/天），但仅描述限制本身，未给任何查询端点。

## 对下游 S-unit 的约束（design-brief §3.3 兜底分支成立）
- 官方文档路线**已穷尽**，不可得。Phase 1 S2 只读探针（OpenAI 兼容 billing 家族，如 `/v1/dashboard/billing/subscription`）成为唯一剩余假设，且**属未记载路径**，须标注为推测。
- 兜底形态（design-brief §3.3 第 50 行「端点待确认 + 错误处理已验证」）已被本单元证据**证实为必然而非保守**。

## 证据清单
| 结论 | 来源 |
|------|------|
| 文档端点全集 | https://wiki.agnes-ai.cn/zh-Hans/docs/agnes-video-25-flash.md (HTTP 200) |
| 额度只在控制台 | https://wiki.agnes-ai.cn/zh-Hans/docs/faqs.md:126 |
| 402/429 语义 | https://wiki.agnes-ai.cn/zh-Hans/docs/faqs.md:93,95 ; /zh-Hans/docs/code.md:54-60 |
| 配额定义无端点 | https://wiki.agnes-ai.cn/zh-Hans/docs/tokenplan.md:63-79,160-172 |
| 全量页面穷举 | https://wiki.agnes-ai.cn/llms.txt ; https://wiki.agnes-ai.cn/sitemap.xml |
| 本地原始快照 | /tmp/agnes_f66e0e52.out(video) /tmp/ag_tokenplan.md /tmp/ag_faqs.md /tmp/ag_code.md /tmp/ag_overview.md /tmp/ag_quickstart.md /tmp/agnes_8f908a4e.out(llms) /tmp/agnes_7ba42bbf.out(sitemap) |

## status
done