---
id: discipline-research-evidence
title: 调研与证据纪律
tags: [调研路由, 证据纪律, 检索优先, 能力否定, 试点先行]
sources:
  - plans/archive/task-v147-research-first/knowledge-brief.md
  - plans/archive/task-v147-research-first/findings.md
  - plans/archive/task-v163-proactive-research/findings.md
  - plans/archive/task-v080-web-research-routing/knowledge-brief.md
  - plans/archive/task-v080-web-research-routing/findings.md
  - plans/archive/task-v076-conclusion-discipline/knowledge-brief.md
  - plans/archive/task-v082-minimal-probe/knowledge-brief.md
  - plans/archive/task-v083-batch-pilot-first/knowledge-brief.md
updated: 2026-10-22
---

# 调研与证据纪律

> 主题级合成：把「不知道→先查」「查什么/怎么查」「归因怎么锚」「查到什么算够」「断言做不到前必查证」「批量前先试点」串成一条可执行链；每条结论标注来源任务。

## 结论（可直接复用）

1. **检索是义务不是选项**：遇到不知道/不清楚/不确定/报错/API 用法/工具用法/领域知识，第一反应=主动检索资料，禁止以「不知道」作最终答复。检索链按序穷尽：①本地（代码库 Grep/Read、memory、knowledge-brief §2、既有 capability 脚本）→②工具自带帮助面（`--help`/`man` 全文）→③官方文档与网络搜索（WebSearch / Doc Search Agent / research-assistant 多源）→④社区经验（Forum Search、GitHub issues/PR）。唯一边界=用户私人数据与未授权凭据。（来源：task-v147-research-first）
2. **「不知道」须持证上岗**：穷尽检索链并附检索证据前，「不知道/无法确定/查不到」禁止作为答复、任务结论或阻塞上报内容。合法最小形态=「已检索 A/B/C（附证据锚）→ 仍无法确定 X → 建议下一步 Y」；缺检索证据的「不知道」=摆烂上报。（来源：task-v147-research-first）
3. **编造比「不知道」更严重**：检索结论必须附来源锚（URL/文件路径/命令输出）；检索片段与本地第一手事实冲突时以本地验证为准；未复核的检索内容引用时标注「待验证」；检索链穷尽后确实无解 → 按三态裁决以 not-solved 诚实收场并附已检索清单。（来源：task-v147-research-first）
4. **归因必须走证据面三件套**：调研/分析类结论要过「对标取证强制（拿到可比对标，不凭印象归因）→ 结论-证据锚定（每个结论挂证据）→ 因果链（写清 A 因 B 的中间环节，不跳步）」；缺任一项的归因只能写成「未验证假设」，不得直接写进结论。（来源：task-v163-proactive-research）
5. **计划期先做调研需求三态判定**：任务计划里先判「本地可解 / 需调研 / 必须联网」并登记检索关键词与渠道，调研类任务默认 NET-RESEARCH；不判就开工=计划期调研面空白。（来源：task-v163-proactive-research）
6. **反死磕：检索是事前触发，不是失败两次后的换道**：执行中遇阻（不知道/不确定/报错/选型）第一动作=评估网络检索；同一思路连续尝试 ≥2 次仍无外部输入 → 必须转入检索，禁以本地死磕为默认路径。（来源：task-v163-proactive-research）
7. **现成方案优先，禁重复造轮子**：脚本/代码编辑前必须先 GitHub 检索现成实现（gh CLI 搜仓库/issues/code）+ 官方文档；调研动手前先检索同类研究/竞品公开资料；部署配置前必须先查官方文档 + 社区成熟方案。「未检索就自研 = 违规」。（来源：task-v163-proactive-research）
8. **平台调研工具路由链（ZCode 实测）**：①WebSearch（关键词/英文/技术，实测可用）→②WebFetch（已知 URL 纯静态页）→③web_reader MCP / defuddle（需 JS 渲染）→④splash / Browser Use（动态页/登录态）→⑤Skill("research-assistant") → bing-intl → searxng（中文/多源交叉）。实存工具仅 WebSearch / WebFetch / mcp__web_reader__webReader / mcp__node_repl__js；浏览器能力唯一入口=Browser Use（mcp__node_repl__js）。（来源：task-v080-web-research-routing）
9. **能力否定三关**：断言「做不到/看不到/不存在」前必须①通读完整接口面（API 全 endpoint / CLI `--help` 全文 / schema 全字段）②CRUD 一致性推断（有写接口则读接口必存在，get/detail/view/fetch 变体逐一尝试）③替代路径 ≥1 条（如 list+过滤）。（来源：task-v076-conclusion-discipline）
10. **最小探针**：查证动作本身取最小代价——单条最小输出测试（`echo ok` / `--version` / 一次最小调用）以实际输出为准下结论；禁为一次性判断写复杂测试脚本、搭完整验证环境；仅当探针失败且有具体怀疑点（版本/参数/边界）才逐级加码，每步升级须对准该怀疑点。（来源：task-v082-minimal-probe）
11. **批量试点先行**：批量启动前先对 1 个代表性样本完成单件「处理→端到端验证」且通过，证据落 progress.md；单件失败且根因未定位/未修复复验仍启动批量 = P0 投毒红线（明知不可靠还扩大爆炸半径）。（来源：task-v083-batch-pilot-first）

## 证据锚

| 结论 | 锚点 |
|------|------|
| 1-3 检索链/持证上岗/编造边界 | plans/archive/task-v147-research-first/findings.md:44、:46、:48；知识储备底座 plans/archive/task-v147-research-first/knowledge-brief.md:16-27 |
| 既有规则分工（60/22.3.0/35/58 互补不重述） | plans/archive/task-v147-research-first/findings.md:26-31 |
| 4 证据面三件套（58.2/58.3/58.6） | plans/archive/task-v163-proactive-research/findings.md:63-64 |
| 5-7 三空白面/反死磕触点/现成方案触点 | plans/archive/task-v163-proactive-research/findings.md:79-81、:436、:234、:241-242、:265-266 |
| 8 工具路由链与实存工具清单 | plans/archive/task-v080-web-research-routing/knowledge-brief.md:13、:45；改前原文留存 plans/archive/task-v080-web-research-routing/findings.md:36 |
| 9 能力否定三关 | plans/archive/task-v076-conclusion-discipline/knowledge-brief.md:17 |
| 10 最小探针原则 | plans/archive/task-v082-minimal-probe/knowledge-brief.md:11、:49 |
| 11 试点先行/投毒红线/十足把握四构成 | plans/archive/task-v083-batch-pilot-first/knowledge-brief.md:10-12 |

## 易错点

1. 把检索链当「网络优先」：正确序=本地→帮助面→官方/网络→社区，WebSearch 只是第③层；跳过 `--help`/帮助面直接搜网=绕远且结论不可复现。
2. 「已检索」只写结论不写 A/B/C 检索清单与来源锚 → 违反持证上岗形态，判为摆烂上报。
3. 凭印象归因：没有对标取证就断言「是这个原因」，或跳过因果链直接从现象跳到结论。
4. 用检索片段覆盖本地第一手事实（真实文件内容/命令输出），或把未复核检索内容当已证事实引用。
5. 假设不存在的工具：playwright / context7 / codegraph MCP 在本平台不存在，动态页只有 Browser Use 一条路。
6. 把检索当「失败 ≥2 次才换道」的事后动作，漏掉计划期三态判定与事前反死磕触发。
7. 能力否定偷懒：只 grep 一个关键词就断言「接口不支持」，CRUD 变体（get/detail/view/fetch）未逐一尝试即收场。
8. 查证动作复杂化：为一个连通性判断搭测试夹具/完整验证环境，探针复杂度 ≫ 问题复杂度。
9. 批量未做单件试点就铺开——失败率熔断只在批后才生效，批中已写入的错无法回收。

## 适用场景

- 任务中出现「不知道/不确定/报错/查不到」，需要外部信息才能继续时；
- 调研类/研究类任务的计划期与执行期（含关键词与渠道登记）；
- 需要给出原因判断（归因）并被追问「凭什么这么说」时；
- 写脚本、改代码、做部署配置前找现成实现与官方文档时；
- 任何要断言「做不到 / 不存在 / 不支持」之前；
- 批量处理（多文件、多任务、多仓库）启动前；
- 为子代理写派发 prompt、需要挂检索触点契约行时。
