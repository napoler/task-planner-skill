# LangChain with Finetune 与长上下文问题调研报告

- 调研执行时间：2026-11-24 07:55–08:21 UTC（约 26 分钟）
- 调研方式：真实联网抓取一手页面（WebFetch / curl），GitHub REST API 取仓库元数据；所有结论均标注来源，抓取失败如实记录。
- 结论分级：**[已验证]**=一手来源直接读到，且关键项有第二来源印证；**[初步]**=单源一手抓取；**[存疑]**=来源冲突或未取得原文，仅作推断。
- 重要说明：用户问句中的 "LangChain with Finetune" 不是可确认的官方产品名（详见第 1 节）。本报告不把模型记忆当作抓取证据；凡未抓到原文者均列入"未能验证项"。

---

## [RESEARCH] 结论摘要（5 行）

1. **"LangChain with Finetune" 未找到官方定义**：Bing 精确短语零自然结果；GitHub 上只有零星个人项目（最高相关项 252 star）与 `langchain-finetune` 查询的 29 个小仓库；LangChain 本体是 `langchain-ai/langchain`（149,960 star，2026-11-24 推送），其官方定位是"agent engineering platform"，并未把 fine-tuning 做成核心模块。[已验证]
2. **"好用"的真实来源是编排与检索**：LangChain 官方 RAG 流程（加载→切分→嵌入→向量库→检索）、agent harness/中间件/持久化、结构化输出（ProviderStrategy/ToolStrategy + 重试），配合 Anthropic 的工作流模式；微调只负责低成本地改风格/格式/领域术语。[已验证]
3. **长上下文失效有实证**：`Lost in the Middle` 证明相关信息位于长输入中部时性能显著下降，连专为长上下文设计的模型也不例外；即使 1M 窗口的 Gemini 1.5 也只是"能装下"，不等于"能稳定用"。[已验证]
4. **业界解法是组合拳而非单一银弹**：按需检索 + 上下文压缩（LongLLMLingua 约 4× token 削减）、分层记忆（MemGPT）、prompt caching（最高省 90% 成本/85% 延迟）、compaction/结构化笔记/子代理（Anthropic 上下文工程）、长上下文模型与成本路由（Self-Route）。[已验证]
5. **微调不能扩展"可靠上下文"**：IBM 官方 fine-tuning 页列的是指令遵循、语气、格式、领域词汇与专有数据；未声称改变上下文长度。对"长文中间事实失忆"应改用检索/压缩/记忆/缓存；此为核心推断，缺一手负面声明，标为推断。[初步+推断]

---

## 1. "LangChain with Finetune" 的准确所指

### 1.1 抓取事实

- GitHub REST API 查询 `q=langchain-finetune&sort=stars`：total_count=29，前几项为 `intel/ipex-llm`（8,843★，pushed 2026-01-28，描述含 "seamlessly integrate with ... LangChain"）、`MuhammadBinUsman03/Real-Time-3-pipeline-LLM-Financial-Advisor`（26★，pushed 2025-04-12，"Training pipeline finetunes model ... utilizes Langchain to maintain history and context retrieval"）、`algopapi/RetroformAgent`（16★，pushed 2023-09-05，"Langchain Agent finetuning using 7B - LLAMA 2 ... Retroformer framework"）、`asokraju/LangChainDatasetForge`（4★，pushed 2023-08-13，"Generating artificial datasets using langchain and finetuning the LLMs"）。[来源: https://api.github.com/search/repositories?q=langchain-finetune&sort=stars&order=desc&per_page=15][已验证]
- 精确短语搜 README/名称/描述（`q="langchain finetune" in:name,description,readme`）：total_count=12，绝大多数为 0–2★个人作业仓库；`hotdog40836/first_langchain_finetune_project`（0★，2024-07-04，"fine tune a travel chatbot"）等。[来源: https://api.github.com/search/repositories?q=%22langchain%20finetune%22%20in%3Aname%2Cdescription%2Creadme&sort=stars&order=desc&per_page=15][已验证]
- GitHub 网页搜索 `langchain finetune`（WebFetch 首次成功）另见 `xxw1995/chatglm3-finetune`（252★，2024-02-03，"最容易上手的0门槛 chatglm3 & agent & langchain 项目"）与 `Praveen76/Finetune-Llama2-and-Mistral7B-using-Langchain`（3★，2024-05-14）。[来源: https://github.com/search?q=langchain+finetune&type=repositories][已验证]
- Bing 精确短语 `"LangChain with Finetune"`：无自然结果；追加中文"微调"亦无精确匹配，仅有通用 LangChain 教程页。[来源: https://cn.bing.com/search?q=%22LangChain+with+Finetune%22][来源: https://cn.bing.com/search?q=%22LangChain+with+Finetune%22+%E5%BE%AE%E8%B0%83][已验证（"未找到"，不等于不存在）]
- LangChain 本体仓库元数据：`langchain-ai/langchain`，描述 "The agent engineering platform."，149,960★，pushed_at=2026-11-24T06:21:53Z，open_issues=778，MIT。[来源: https://api.github.com/repos/langchain-ai/langchain][已验证]
- LangChain 官方当前 overview 页面列出 `create_agent`、工具、中间件（guardrails/retries/routing）、标准模型接口、LangGraph 持久化与 human-in-the-loop、可观测性；**未出现 fine-tuning 章节或链接**。[来源: https://docs.langchain.com/oss/python/langchain/overview][已验证]

### 1.2 可能的四种指涉（互斥澄清）

| 指涉 | 证据 | 判定 |
|---|---|---|
| A. "LangChain 编排 + LoRA/PEFT 微调模型"的通用组合教程/个人项目 | GitHub 多个小仓库，如 RetroformAgent、LangChainDatasetForge、Finetune-Llama2-and-Mistral7B-using-Langchain（见 1.1） | [已验证] 存在，但无权威"官方组合" |
| B. "微调模型 + RAG 检索"的落地项目 | `xxw1995/chatglm3-finetune`（252★）、`Mohamedalcafory/RAG_with_langchain`（0★，2024-10-06，"Implement RAG with Langchain for a finetuned model"） | [已验证] 存在，最贴近中文语境的"好用"叙事 |
| C. Retroformer 式"用 LangChain 生成 agent 轨迹再微调" | `algopapi/RetroformAgent`（16★，2023-09-05） | [初步] 单个仓库，未验证效果 |
| D. 用户泛指 LangChain 框架 + 微调方案（非单一项目） | LangChain 官方定位为 agent 平台；旧 fine-tuning guide 已 308 重定向到 overview；官方博客 "Fine-tuning vs RAG" 迁移后 404 | [已验证] 官方层面无独立 fine-tune 产品 |

**裁定**：把 "LangChain with Finetune" 当作**方案组合的说法**最稳妥；若有人声称它是某个具体明星开源项目，需对方给出链接——当前证据不支持。[推断]

---

## 2. 为什么被认为"好用"：可核查的具体机制

1. **RAG 流水线被框架化**：官方 RAG 文档明确流程："Load your data sources into `Document` objects" → "Use text splitters to break large `Document`s into smaller chunks"（`RecursiveCharacterTextSplitter`）→ 嵌入成向量 → "Store chunks and embeddings in VectorStore" → `vector_store.similarity_search(query, k=4)` → 模型用"question + retrieved data"生成答案。文档还给出 Deep Agents 的"Retrieve, offload, and delegate"范式：检索后把 chunk 写入文件、委派子代理、最后综合。[来源: https://docs.langchain.com/oss/python/langchain/rag][已验证]
2. **结构化输出降低解析失败**：官方支持 `response_format` + `ProviderStrategy`（provider 原生，最可靠）/`ToolStrategy`（含 Union 类型），schema 支持 Pydantic、dataclass、TypedDict、JSON Schema；结果放在 `structured_response`；`handle_errors` 可在校验失败时重试。原文："most reliable method when available"、"Avoids parsing natural language responses"。[来源: https://docs.langchain.com/oss/python/langchain/structured-output][已验证]
3. **Agent 编排与可靠性基础设施**：`create_agent`（"Agent = Model + Harness"）、中间件覆盖 "guardrails and retries to routing and custom tool policies"、LangGraph 提供 "durable execution, human-in-the-loop support, persistence"，并支持 trace/debug/evaluate。[来源: https://docs.langchain.com/oss/python/langchain/overview][已验证]
4. **成熟的流程模式**：Anthropic 列出 prompt chaining（固定子任务 + 检查门）、routing、parallelization（sectioning/voting）、orchestrator-workers（动态分解）、evaluator-optimizer（生成—评审循环），并建议仅在步骤不可预知时用 agent。[来源: https://www.anthropic.com/engineering/building-effective-agents，2024-12-19][已验证]
5. **微调成本被 PEFT 压低**：LoRA 示例可训练参数 3,686,400 / 3,089,625,088 = 0.1193%；A100 80GB 上 14.4GB vs 全量 47.14GB；checkpoint 19MB vs 11GB；QLoRA 可在 16GB GPU 上微调 Llama-2-7B。[来源: https://raw.githubusercontent.com/huggingface/peft/main/README.md][已验证]
6. **工具/上下文设计是隐性功臣**：Anthropic 建议工具返回用 "pagination, range selection, filtering, and/or truncation"，concise 版本约"⅓ of the tokens"，并用 `response_format` 做渐进式披露。[来源: https://www.anthropic.com/engineering/writing-tools-for-agents，2025-09-11][已验证]

**小结[推断]**：所谓"好用"主要来自**把检索、状态、工具、结构化输出工程化**，微调只是用很小成本把模型行为对齐到任务格式/领域语言；把长上下文失败归因于"缺微调"很可能是误诊。

---

## 3. 长上下文问题的业界解法（2023–2026 证据链）

### 3.1 问题本体：窗口大小 ≠ 有效利用

- `Lost in the Middle: How Language Models Use Long Contexts`（Nelson F. Liu 等，arXiv 2307.03172，提交 2023-07-06，v3 2023-11-20）："moving relevant information within long inputs can cause major performance drops"；"Performance is usually strongest when needed information appears near the start or end, but degrades when it is in the middle, including for models explicitly designed for long contexts."[来源: https://arxiv.org/abs/2307.03172][已验证]
- Gemini 1.5 官方发布（2024-02-15）：标准 128,000 token，预览最高 1M，研究测试到 10M；"Needle In A Haystack ... 99% of the time" up to 1M，可处理 1 小时视频/11 小时音频/30,000+ 行代码。[来源: https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/][已验证]
- Claude 3.5 Sonnet 发布（2024-06-21）："a 200K token context window"。[来源: https://www.anthropic.com/news/claude-3-5-sonnet][已验证]
- **判断[已验证+推断]**：1M/200K 是"容量"指标；Lost in the Middle 是"利用质量"证据，两者不可互替。

### 3.2 检索 vs 直接长上下文（成本—质量权衡）

- `Retrieval Augmented Generation or Long-Context LLMs? A Comprehensive Study and Hybrid Approach`（arXiv 2407.16833，2024-07-23）："when resourced sufficiently, LC consistently outperforms RAG in terms of average performance"，但 "RAG's significantly lower cost remains a distinct advantage"；提出 Self-Route，"routes queries to RAG or LC based on model self-reflection"，在接近 LC 性能下显著降低成本。[来源: https://arxiv.org/abs/2407.16833][已验证]
- LangChain 官方 RAG 页提供了检索的工程实现（见 2.1），可作为 Self-Route 中 RAG 分支的落点。[已验证]

### 3.3 压缩与记忆

- `LongLLMLingua: Accelerating and Enhancing LLMs in Long Context Scenarios via Prompt Compression`（arXiv 2310.06839，2023-10-10）：针对 "higher computational cost, performance reduction, and position bias"；NaturalQuestions 提升 "up to 21.4%"，GPT-3.5-Turbo 用 "around 4x fewer tokens"，LooGLE "94.0% cost reduction"，10k-token 延迟 "2x-6x" / "1.4x-2.6x" 加速。[来源: https://arxiv.org/abs/2310.06839][已验证]
- `MemGPT: Towards LLMs as Operating Systems`（arXiv 2310.08560，2023-10-12）："virtual context management"，借鉴操作系统分层内存，"data movement between fast and slow memory"，支持超出窗口的文档分析和多会话长期记忆。[来源: https://arxiv.org/abs/2310.08560][已验证]
- 纠正记录：最初按记忆尝试的 arXiv 2310.04020 实为无关论文《Snail Homing and Mating Search Algorithm》，未采信。[来源: https://arxiv.org/abs/2310.04020][已验证]

### 3.4 上下文工程（当前主流共识）

- Anthropic《Effective context engineering for AI agents》（2025-09-29）：核心是"smallest possible set of high-signal tokens"；具体手段包括 XML/Markdown 组织提示、token-efficient 工具、just-in-time 检索与 "progressive disclosure"（只留文件路径/查询/链接等轻量标识），接近上限时 compaction 并"clear tool calls and results"，结构化笔记（`NOTES.md`），子代理用"clean context windows"只回传"condensed, distilled summary"，常为 "1,000-2,000 tokens"。[来源: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents][已验证]
- Anthropic《Writing effective tools for agents》（2025-09-11）："context rot"概念；分页/过滤/截断、concise 响应约 1/3 token、渐进式披露、明确参数名（如 `user_id` 而非 `user`）、可操作的错误信息。[来源: https://www.anthropic.com/engineering/writing-tools-for-agents][已验证]

### 3.5 Prompt caching（降本增效，而非"治失忆"）

- Anthropic《Prompt caching with Claude》（2025-08-14）：缓存"frequently used context between API calls"，"reducing costs by up to 90% and latency by up to 85% for long prompts"；100,000-token 书稿示例 11.5s→2.4s 且 -90% 成本；10,000-token many-shot 1.6s→1.1s、-86%；长系统提示多轮 -53%；写入价 +25%、读取价为基准输入的 10%。[来源: https://claude.com/blog/prompt-caching][已验证（页面 `datePublished=2025-08-14` 经 curl 复核）]
- **判断[推断]**：缓存解决"重复长前缀"的费用/延迟，不改变模型对中部信息的注意力缺陷。

### 3.6 方法对照表（归纳，来源见上）

| 方法 | 解决的痛点 | 代价/边界 | 来源 |
|---|---|---|---|
| 长上下文模型（1M/200K） | 装得下整份材料 | 中部信息退化；成本高 | blog.google 2024-02-15；arXiv 2307.03172 |
| RAG | 动态知识、低成本、可溯源 | 检索召回质量决定上限 | docs.langchain.com RAG；arXiv 2407.16833 |
| 压缩（LongLLMLingua） | token 成本、位置偏置 | 有损，需评估任务容忍度 | arXiv 2310.06839 |
| 分层记忆（MemGPT） | 多会话/超长文档 | 系统复杂度、状态一致性 | arXiv 2310.08560 |
| Prompt caching | 重复前缀成本与延迟 | 不改善"失忆" | claude.com/blog/prompt-caching |
| 上下文工程（compaction/笔记/子代理/JIT 检索） | 上下文腐烂、工具输出膨胀 | 需重构 agent 架构 | anthropic.com/engineering 两篇 |

---

## 4. 微调在长上下文场景的真实作用与局限

1. **微调确实擅长的**：IBM《What is fine-tuning?》（2024-03-15）列举 "better follow instructions"、"adjust the conversational tone"、"reflect a brand's desired tone"、"emulate a specific writing style"、领域 "specialized, esoteric vocabulary"、"handle certain situations"、"Incorporating proprietary data"；同页也提醒 LLM "are not omniscient"。[来源: https://www.ibm.com/think/topics/fine-tuning][已验证]
2. **微调的工程优势**：PEFT/LoRA 用极少参数达到接近全量的效果，checkpoint 仅数 MB，适合每个下游任务保留一份。[来源: https://raw.githubusercontent.com/huggingface/peft/main/README.md][已验证]
3. **关键局限（一手文本未直接声明，标推断）**：IBM 页面**没有**把"扩展上下文长度"或"提升长文档中部事实回忆"列为微调用途；LangChain 官方 overview 也无 fine-tuning 模块；因此**[推断]** 微调主要改写行为分布（风格/格式/术语/指令遵循），不能把 128K 窗口变成"可靠 1M"，也无法根治 Lost in the Middle。
4. **与 RAG 的分工[推断]**：领域术语、输出 JSON 格式、固定工作流风格 → 微调；事实性、时效性、长文档定位 → 检索 + 压缩 + 记忆 + 缓存；两者叠加时微调模型也要能被 RAG 消费（如 GitHub 上的 "RAG with Langchain for a finetuned model" 项目）。[来源: https://api.github.com/search/repositories?q=langchain-finetune&sort=stars&order=desc&per_page=15][初步]
5. **对本项目的针对性推断（未改任何源码，仅只读核查）**：本地 `skills/task-planner/SKILL.md` 289 行、references 列表在 frontmatter 中逐条列出 Rules 1-110 与多个卫星路由、`AGENTS.md` 89 行、`references/worktree-isolation.md` 196 行；SKILL.md 第 29 行要求"每次回答前先复述当前任务 Goal 与 Requirements 首条用户原话"，第 54 行甚至有"上下文压缩恢复：技能正文 SKILL.md 全文无条件注入"。[来源: 本地只读 /mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md:1-60；wc -l 结果][本地事实]
   - **[推断]** 这类"整本规则注入 + 每轮复述 + 多文件罗盘"的设计，与 Anthropic 的"smallest possible set of high-signal tokens"和"just-in-time/progressive disclosure"方向相反；任务越长，工具结果和规则文本越容易触发 context rot，表现为"执行过程中感觉不理想、长上下文尤其差"。这与用户体感一致，但**未经 A/B 实验验证**，仅作为优先排查方向。
   - **[推断]** 优先排查顺序：① 减少常驻规则体积、改为按需读取 reference；② 把检索结果写文件留指针而非堆进上下文；③ 用 compaction/结构化笔记/子代理 1–2k token 摘要；④ 若使用支持缓存的 API，启用 prompt caching 降低长前缀成本。

---

## 5. 冲突与存疑点

- **冲突 1**：arXiv 2407.16833 称"资源充足时 LC 平均优于 RAG"；Anthropic 上下文工程强调"最小高信号 token"、JIT 检索。 **[倾向判断]** 二者不矛盾：前者比较"给定完整上下文"的质量上限，后者讨论工程成本与注意力退化；实践中宜按 Self-Route 思路路由（[已验证] 双方原文 + [推断] 综合）。
- **冲突 2**：IBM 称微调可加入 "domain-specific knowledge"/"proprietary data"，而常见工程经验称"微调不适合灌事实"。**[倾向判断]** 微调能写入稳定模式化知识，但不适合频繁更新的事实；本次未抓到 OpenAI/Anthropic 官方的明确负面声明，保留为[存疑]。
- **数据异常**：GitHub API 中 `v4valti/ipex-llm` 的 created_at=2026-08-10 晚于 pushed_at=2026-01-28，元数据自相矛盾，未采信其时间。
- **"未找到"≠"不存在"**：Bing 在本网络区域返回"部分搜索结果未予显示"，精确短语零结果只能说明未找到，不能证明无人使用。

## 6. 未能验证项（诚实标注）

1. LangChain 官方《Fine-tuning vs RAG》原文：`blog.langchain.com/fine-tuning-vs-rag/` 301→`www.langchain.com/blog/fine-tuning-vs-rag` 404；旧域 `blog.langchain.dev` 同样跳转；`web.archive.org` 两次超时（2026-11-24，WebFetch 10s / curl 25s）。**未取得原文**，因此不能逐字引用其 RAG vs fine-tuning 判据。
2. LangChain 旧 fine-tuning guide：`python.langchain.com/v0.2/docs/guides/fine_tuning/` 308 跳转到 overview（curl 200 但正文为 overview），旧指南内容不可得。
3. OpenAI 官方 fine-tuning 文档：`platform.openai.com/docs/guides/fine-tuning` 403；其"何时微调"原文未抓到。
4. Anthropic 平台 prompt-caching 参数页（cache prefix 最小 token、5m/1h TTL）：被 307 区域重定向到 `app-unavailable-in-region`；已改用 Anthropic 官方博客取得成本/延迟数据，但 TTL/最小阈值未核实。
5. Google Gemini API 长上下文/缓存文档：`ai.google.dev/gemini-api/docs/long-context` 25s 超时；只用官方 blog.google 发布页佐证 1M 窗口。
6. arXiv API 与搜索页：429 限流；上下文工程/记忆综述的精确 arXiv ID 未核实，故本报告未引用任何未核实的综述编号。
7. 搜索通道：searx.be JSON 连接重置；Jina Reader 两域 25s 超时；GitHub 精确短语网页搜索一次 10s 超时（同域 REST API 成功）；DuckDuckGo HTML 10s 超时。以上均按降级链换道，不作为"不可用"结论呈报。
8. 本项目长上下文体感与规则体积的因果性：仅有关联性推断，未做对照实验。

---

## 7. 已抓取来源清单（URL + 标题 + 日期）

| # | URL | 标题 | 日期/时间信息 |
|---|---|---|---|
| 1 | https://api.github.com/search/repositories?q=langchain-finetune&sort=stars&order=desc&per_page=15 | GitHub Search API: langchain-finetune（29 项） | 抓取 2026-11-24；各仓库 pushed_at 见正文 |
| 2 | https://api.github.com/search/repositories?q=%22langchain%20finetune%22%20in%3Aname%2Cdescription%2Creadme&sort=stars&order=desc&per_page=15 | GitHub Search API: 精确短语（12 项） | 抓取 2026-11-24 |
| 3 | https://github.com/search?q=langchain+finetune&type=repositories | GitHub 网页仓库搜索 | 抓取 2026-11-24；chatglm3-finetune 更新 2024-02-03 |
| 4 | https://api.github.com/repos/langchain-ai/langchain | langchain-ai/langchain 仓库元数据 | pushed 2026-11-24T06:21:53Z |
| 5 | https://docs.langchain.com/oss/python/langchain/overview | LangChain overview | 页面未标日期；抓取 2026-11-24 |
| 6 | https://docs.langchain.com/oss/python/langchain/rag | Retrieval Augmented Generation (RAG) with Deep Agents | 页面未标日期；抓取 2026-11-24 |
| 7 | https://docs.langchain.com/oss/python/langchain/structured-output | Structured output | 页面未标日期；抓取 2026-11-24 |
| 8 | https://www.anthropic.com/engineering/building-effective-agents | Building effective agents | Dec 19, 2024 |
| 9 | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Effective context engineering for AI agents | Sep 29, 2025 |
| 10 | https://www.anthropic.com/engineering/writing-tools-for-agents | Writing effective tools for agents — with agents | Sep 11, 2025 |
| 11 | https://claude.com/blog/prompt-caching | Prompt caching with Claude | Aug 14, 2025（curl 复核 datePublished=2025-08-14） |
| 12 | https://www.anthropic.com/news/claude-3-5-sonnet | Introducing Claude 3.5 Sonnet | Jun 21, 2024 |
| 13 | https://blog.google/technology/ai/google-gemini-next-generation-model-february-2024/ | Our next-generation model: Gemini 1.5 | Feb 15, 2024 |
| 14 | https://arxiv.org/abs/2307.03172 | Lost in the Middle: How Language Models Use Long Contexts | v1 2023-07-06；v3 2023-11-20 |
| 15 | https://arxiv.org/abs/2310.06839 | LongLLMLingua: ... via Prompt Compression | 2023-10-10 |
| 16 | https://arxiv.org/abs/2310.08560 | MemGPT: Towards LLMs as Operating Systems | 2023-10-12 |
| 17 | https://arxiv.org/abs/2407.16833 | Retrieval Augmented Generation or Long-Context LLMs? ... Hybrid Approach | 2024-07-23 |
| 18 | https://arxiv.org/abs/2310.04020 | （纠错用）Snail Homing and Mating Search Algorithm | 2023-10-06；与主题无关，未采信 |
| 19 | https://raw.githubusercontent.com/huggingface/peft/main/README.md | PEFT README（LoRA/QLoRA 数据） | ©2023 HuggingFace Team；抓取 2026-11-24 |
| 20 | https://www.ibm.com/think/topics/fine-tuning | What is fine-tuning? | Published 15 March 2024 |
| 21 | https://cn.bing.com/search?q=%22LangChain+with+Finetune%22 | 精确短语搜索（零自然结果） | 抓取 2026-11-24 |
| 22 | https://cn.bing.com/search?q=%22LangChain+with+Finetune%22+%E5%BE%AE%E8%B0%83 | 精确短语 + 微调（零匹配） | 抓取 2026-11-24 |
| 23 | 本地只读：/mnt/data/dev/task-planner-skill/skills/task-planner/SKILL.md（及 wc -l） | 本项目 SKILL.md 289 行、references/critical-rules.md 263 行、AGENTS.md 89 行 | 本地文件，抓取 2026-11-24 |

## 8. 建议后续动作（≤3 条）

1. 若用户所指是某个具体 "LangChain with Finetune" 教程/仓库，请提供链接；本报告已证明它没有可确认的官方产品身份，避免继续按错误所指优化。
2. 对本项目的"长上下文不理想"做一次实测：统计单次任务注入的规则 token 与工具输出 token，验证"SKILL.md 全文无条件注入"是否是主因；再按 Anthropic 的 JIT 读取/compaction/子代理摘要做 A/B。
3. 微调预算只用于风格/格式/领域术语对齐；长文档可靠性优先投入检索、压缩、结构化笔记与 prompt caching，并按 Self-Route 思路做"检索 vs 长上下文"路由。
