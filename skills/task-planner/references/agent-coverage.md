# Agent 覆盖矩阵（执行体选型单一事实源 — Rule 52）

> **维护责任（52.3 口径）**：agent 增/删/改名或三登记面（SKILL.md 路由表 / skill-agent-router / template-mapping §九§十）任一改动 → 本矩阵必须同任务同步（change-linkage，禁悬空）；新增专用体落地后必须回填本矩阵与登记面行（task-v124→v125 媒体执行体登记=联动先例）。机器守护 = `scripts/selftest-agent-coverage.sh`（AC-01..08：矩阵在位/B 类实体存在性零容忍/C 类处置覆盖/零新键）。
>
> **选型顺序（52.1）**：S-unit 选择执行体先查本矩阵与三登记面——矩阵列有专用体 → 必须用专用体；专用体缺位 → 按族兜底（一等候选=具备工序 SOP 的 executor(sonnet-1) 组合）并在 Executor/S-unit 表登记兜底理由；general-purpose 仅限跨领域复合/无法归类（宪法 §一、Rule 47.2），禁「路由表无匹配行」式默认落泛。
>
> **底稿来源**：plans/task-v125/subagent-state/2-coverage.md（覆盖交叉审计，登记面锚 D1=SKILL.md:333-357 / D2=skill-agent-router:25-101 / D3=template-mapping.md:258-312）与 1-inventory.md（87 agent/14 族全量盘点）。

## 一、类型族 × 专用体 × 登记状态（审计矩阵转写，26 行）

| # | 类型族 | 专用体（登记面） | 登记状态/兜底 |
|---|---|---|---|
| 1 | 计划/架构/编排 | plan-writer(D1), complex-planner(D1/D2), planner(D1/D2), architect(D1/D2), task-orchestrator(D1/D2) | 全部在位 |
| 2 | 代码编辑小改 | code-assistant(D1/D2/D3) | 在位 |
| 3 | 代码编辑大改/跨文件 | executor(D1/D2/D3) | 在位 |
| 4 | 重构/瘦身 | code-simplifier(D1/D3), refactor-cleaner(D2) | 在位 |
| 5 | 构建错 | build-error-resolver(D1/D2/D3) | 在位 |
| 6 | bug/根因 | debugger(D1/D2/D3) | 在位 |
| 7 | 跑测试 | code-runner-agent(D1/D2/D3) | 在位 |
| 8 | 体检 | codebase-analyzer(D1/D2) | 在位 |
| 9 | 测试编写 | test-engineer(D2/D3) | 在位 |
| 10 | 性能 | performance-optimizer(D2) | 在位 |
| 11 | JSON | json-edit-agent(D2) | 在位 |
| 12 | 数据库 | database-optimizer(D2/D3) | 在位 |
| 13 | 审查/挑刺 | code-reviewer(D1/D2/D3), critic(D1/D2), verifier(D2/D3), agent-quality-auditor(D2) | 全部在位 |
| 14 | 搜索/文档 | explore(D1/D2/D3), web-search-agent(D1/D2/D3), doc-search-agent(D1/D2/D3), forum-search-agent(D2), oss-search-agent(D2), document-specialist(D2) | 全部在位 |
| 15 | 浏览器/抓取 | browser-automation(D1/D2), web-scraper(D2) | 在位 |
| 16 | CLI | cli-executor-agent(D2), cli-tool-builder(D2) | 在位 |
| 17 | 数据 | data-engineer / analyst / analytics-reporter / data-cleaning-expert / data-synthesizer / ai-data-remediation-engineer (D2) | 全部在位 |
| 18 | 其他 | simple-agent/complex-problem-solver/context-manager/time-keeper/meta-corrector(D2), complex-planner(D2) | 全部在位 |
| 19 | writing | article-writer(D1/D3), article-writing-phase-agent(D3) | 在位 |
| 20 | research | research-assistant(D1/D3), web-search-agent(D3) | B3：research-assistant 为 skill 非 agent，双列标注（见 §二 B3） |
| 21 | publish | code-runner-agent/article-batch-publisher(D3) | B4：登记名原为 article-batch-publish，已改 article-batch-publisher（见 §二 B4） |
| 22 | memory-hygiene | executor(fresh)/verifier(D3) | 在位 |
| 23 | video | Agnes 视频链路→v124 video-generation-executor(D3) | B*：原指向项目专属资产，v124 承接（在位后登记） |
| 24 | video-fix | videop1-video-fix SOP(D3:274)→v124 video-fix-executor(D3:274 承接位) | B*：同上，v124 承接 |
| 25 | 媒体 11 类工序（character-design/multiview-ref/storyboard/prompt-struct/video-prompt/motion-camera/physics-compliance/qc-defect/audio-voice/final-assembly + image） | 「写词/QC/判定/剪辑/核对子代理」泛称(D3:277-288) | A：无具名映射，兜底=executor(sonnet-1)+工序 SOP（D3:298 条款）；image 生成由 v124 image-generation-executor 承接 |
| 26 | 规则/模板组、迁移/部署组、轻量档、调研/诊断组、general | executor+worktree 隔离(D3:309) / 主进程 git 编排+executor(D3:310) / code-assistant 或主进程白名单(D3:311) / explore/web-search/debugger(D3:312) / 按 Phase Executor 逐案路由(D3:289) | 在位（general=设计如此） |

注：「登记面」D1=SKILL.md 路由表、D2=skill-agent-router、D3=template-mapping §九/§十；行 26 为底稿 5 行（规则/模板组、迁移/部署组、轻量档、调研/诊断组、general）合并，矩阵行号 1-26 对应底稿原 26 行类型族。

## 二、三类缺口处置表

### A 类 = 类型族无具名执行体映射（落泛兜底风险 → 兜底显式登记）

| 条目 | 证据 | 处置 | 状态 |
|---|---|---|---|
| 媒体工序 11 类（image 及 videotpl 工序族） | template-mapping.md:277-288 路由组列仅泛称；依赖 :298 兜底条款 | image 生成=v124 image-generation-executor；其余 10 工序（写词/审查/QC/判定/剪辑/核对）=兜底登记 executor(sonnet-1)+variant SOP（Rule 47.2），专用体增补列入 §四 增补候选 | 兜底已登记 |
| video / video-fix | template-mapping.md:273-274 指向「Agnes 视频链路」「videop1-video-fix SOP」项目专属资产 | v124 补 video-generation-executor / video-fix-executor 两专用体，在位后回填本矩阵 §一 行 23/24（52.3 联动先例） | v124 承接 |

### B 类 = 登记名指向不存在/名不符实体（零容忍，逐条实证 `test -f ~/.zcode/agents/<name>.md`）

| 条目 | 登记处 | 修正去向 | 状态 |
|---|---|---|---|
| B1 script-writer | template-mapping.md:278（无实体） | 登记改兜底路由：executor(sonnet-1)+script-dev variant SOP；专用体列入增补候选（D2a 裁决=候选②） | 本任务修（S4） |
| B2 script-auditor | template-mapping.md:278（无实体） | 同 B1：兜底路由 executor(sonnet-1)+script-dev variant SOP；与 B1 合并处置 | 本任务修（S4） |
| B3 research-assistant | SKILL.md:348、template-mapping.md:268（agents/ 无实体，实为 skill） | 双列标注：`Skill("research-assistant")`（skill 调用面）+ `web-search-agent`（agent spawn 面） | 本任务修（S3/S4） |
| B4 article-batch-publish | template-mapping.md:266（名漂移，实际实体=article-batch-publisher.md） | 登记名改 article-batch-publisher | 本任务修（S4） |
| B5 ComplexProblemSolver | SKILL.md:340/:350（大小写不符，实体=complex-problem-solver.md） | 字面改 complex-problem-solver | 本任务修（S3） |

AC-03 守护口径：B1/B2 修正后 script-dev 行无 `script-writer`/`script-auditor` 裸名；`article-batch-publish`（无 er 形）与 `ComplexProblemSolver` 字面全仓零命中；双侧反证=旧字面零残留+新字面在位。

## 三、C 类 41 实体纳入/豁免表（实体未登记「有体不用」，逐行纳入/豁免）

**处置原则**：族级登记防路由表膨胀（六族行=质量审查族/Git 运维族/营销 SEO 族/数据研究族/文档 UI 族/文章管线补充族，S3 插 SKILL 表尾、router 同步族行）；本表逐行保可追溯。纳入=列入对应族行登记去向；豁免=一行理由，router SKILL.md:7 已声明 article-* 系列不在其路由范围内。

| # | agent（实体） | 相 | 登记去向 | 纳入/豁免 | 理由 |
|---|---|---|---|---|---|
| 1 | article-batch-publisher | 文章管线 | 文章管线补充族 | 纳入 | 实体=article-batch-publisher.md；原登记名 article-batch-publish 为 B4 名漂移双挂，随 B4 改名后纳入族行 |
| 2 | article-content-editor | 文章管线 | 文章管线补充族 | 纳入 | 正文精修（按审查意见逐条改，不整篇重写） |
| 3 | article-data-fetcher | 文章管线 | 文章管线补充族 | 纳入 | 批量抓取多文章数据 |
| 4 | article-field-fixer | 文章管线 | 文章管线补充族 | 纳入 | article.json 批量规范化 |
| 5 | article-publish-phase-agent | 文章管线 | 文章管线补充族 | 纳入 | Phase 5→6 发布执行体 |
| 6 | article-research-heavy-agent | 文章管线 | 文章管线补充族 | 纳入 | 重度研究执行体（Phase 0.75/1-Topic/1-SEO） |
| 7 | article-research-phase-agent | 文章管线 | 文章管线补充族 | 纳入 | 研究阶段执行体（Group A） |
| 8 | article-reviewer | 文章管线 | 文章管线补充族 | 纳入 | 文章质量审查（SEO/可读性/事实核查） |
| 9 | article-site-router | 文章管线 | 文章管线补充族 | 纳入 | 网站类型识别+访问路由 |
| 10 | article-synthesis-phase-agent | 文章管线 | 文章管线补充族 | 纳入 | 综合阶段执行体（Phase 2→2.7） |
| 11 | api-tester | 数据/研究 | 质量审查族 | 纳入 | API 接口验证+性能压测+跨系统集成 QA |
| 12 | scientist | 数据/研究 | 数据研究族 | 纳入 | 数据驱动研究（方案设计+假设验证+实验） |
| 13 | data-consolidation-agent | 数据/研究 | 数据研究族 | 纳入 | 销售数据整合+实时报表仪表盘 |
| 14 | search-query-analyst | 数据/研究 | 数据研究族 | 纳入 | 搜索词分析+否定关键词架构（付费搜索） |
| 15 | log-distiller | 数据/研究 | 数据研究族 | 纳入 | 大日志/长输出只读提炼 |
| 16 | technical-writer | 内容/营销 | 文档 UI 族 | 纳入 | 技术文档/API 参考/README/教程 |
| 17 | ui-designer | 内容/营销 | 文档 UI 族 | 纳入 | UI 视觉设计系统+组件库 |
| 18 | frontend-developer | 内容/营销 | 文档 UI 族 | 纳入 | React/Vue/Angular 前端实现+性能优化 |
| 19 | marketing-content-creator | 内容/营销 | 营销 SEO 族 | 纳入 | 多平台内容策略+编辑日历+品牌故事 |
| 20 | marketing-seo-specialist | 内容/营销 | 营销 SEO 族 | 纳入 | 技术 SEO+内容优化+链接权重 |
| 21 | organic-content-strategist | 内容/营销 | 营销 SEO 族 | 纳入 | 有机内容规划 |
| 22 | seo-specialist | 内容/营销 | 营销 SEO 族 | 纳入 | SEO 数据驱动流量（与 marketing-seo-specialist 近重复，增补/合并时消歧） |
| 23 | quality-auditor | 质量/校验 | 质量审查族 | 纳入 | SO-4.5 发布前最终质量门控（被 agent-quality-auditor 子串遮蔽，grep 需按 word 边界单计） |
| 24 | quality-check-agent | 质量/校验 | 质量审查族 | 纳入 | 流程质检+验收+交付物审查 |
| 25 | quality-control-agent | 质量/校验 | 质量审查族 | 纳入 | 每 phase 后只读合规校验（防御层） |
| 26 | content-origin-verify-agent | 质量/校验 | 质量审查族 | 纳入 | 内容原创性验证（独立上下文） |
| 27 | doc-sync-verify-agent | 质量/校验 | 质量审查族 | 纳入 | 文档同步检查执行体 |
| 28 | cron-patrol | 运维/Git/记忆 | Git 运维族 | 纳入 | cron/watchdog/cleanup 日志只读巡检 |
| 29 | git-master | 运维/Git/记忆 | Git 运维族 | 纳入 | Git 提交/变基/历史管理 |
| 30 | git-security-expert | 运维/Git/记忆 | Git 运维族 | 纳入 | Git 安全审计+密钥泄露+history 清理 |
| 31 | worktree-janitor | 运维/Git/记忆 | Git 运维族 | 纳入 | worktree/wt 遗留分支+孤儿目录巡检 |
| 32 | memory-librarian | 运维/Git/记忆 | Git 运维族 | 纳入 | 记忆查重+frontmatter 校验+MEMORY.md 索引同步 |
| 33 | auto-agent | 其他 | 文章管线补充族 | 纳入 | 任务类型→最适 agent 自动路由分发；作管线智能分发改点由该族行承接 |
| 34 | explore-fb | 其他 | —（豁免） | 豁免 | explore 的 agnes-2.5-flash 备用版，冗余实体；保留 explore 为唯一登记面（冗余信号，1-inventory §小结） |
| 35 | web-search-opencode | 其他 | —（豁免） | 豁免 | 与 web-search-agent 能力交叠（多源深度整合为其长尾），交叠区暂由 web-search-agent 兜底，不重复开登记面 |
| 36 | ai-engineer | 其他 | 数据研究族 | 纳入 | AI/ML 工程（模型开发部署+数据管道） |
| 37 | cross-border-e-commerce-specialist | 其他 | 数据研究族 | 纳入 | 跨境电商全链路（Amazon/Shopee/Lazada/Temu/合规） |
| 38 | plan-bookkeeper | 其他 | 质量审查族 | 纳入 | 计划三文件簿记回填+Phase 状态翻转+门控核查 |
| 39 | frontmatter-linter | 其他 | Git 运维族 | 纳入 | agent/skill frontmatter 机械校验（配置/仓卫生） |
| 40 | writing-skills | 其他 | 文章管线补充族 | 纳入 | 技能创建/改进+评测（写作面） |
| 41 | quality-reviewer | 其他 | 文章管线补充族 | 纳入 | 文章语义级主检查（9 维，Phase 3.5） |

行数核对：41（文章管线 10 + 数据/研究 5 + 内容/营销 7 + 质量/校验 5 + 运维/Git/记忆 5 + 其他 9；quality-auditor 已单计）。豁免 2 行（#34/#35）各附一行理由；其余 39 行=纳入六族行。AC-05 守护口径：本表 grep 计数=41 且每行含「纳入|豁免」。

## 四、零专用体领域清单（增补候选 — 用户裁决，暂不擅自开 agent 增补）

> 来源：1-inventory.md「明显稀疏/缺失领域（0 个专用体）」9 大领域 + 底稿互证（A 类媒体 11 类无具名映射）；优先级=建议（P0=v124 已排队 / P1=高频缺口 / P2=低频或需业务信号），开闸需用户裁决。

| # | 领域 | 现状 | 建议增补优先级 |
|---|---|---|---|
| 1 | 媒体生成/编辑（图像/视频/音频/音乐/storyboard） | 0 专用体；v124 已补 image-generation-executor + video-generation-executor + video-fix-executor 两族三件（在位后回填 §一 行 23/25） | P0（v124 补中） |
| 2 | 字幕（字幕生成/校对工序） | 0 专用体（媒体 11 类 audio-voice 工序兜底中） | P1 |
| 3 | 翻译/本地化 | 0 专用体 | P1 |
| 4 | DevOps/云原生/SRE/K8s/CI | 0 专用体（git-security-expert 仅 Git 层） | P1 |
| 5 | 移动开发（iOS/Android） | 0 专用体 | P2 |
| 6 | 游戏开发 | 0 专用体 | P2 |
| 7 | 应用安全/渗透测试 | 0 专用体（git-security-expert 仅 Git 层） | P2 |
| 8 | UX 研究/用户测试 | 0 专用体（ui-designer 仅视觉设计） | P2 |
| 9 | 财务/会计、HR/招聘、法务 | 0 专用体 | P2 |
| 10 | 运维告警响应/故障恢复（增补项） | 仅 cron-patrol 只读巡检，无修复体 | P2 |
