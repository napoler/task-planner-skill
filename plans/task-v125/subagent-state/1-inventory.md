# S-unit 1 检查点 — agent 全量盘点（sub:audit-inventory）
status: done（本文件为检查点；含分类全表 + T5 最终结论）
盘点日期: 2026-10-03

## 盘点口径与总数
- 目录: /home/terry/.zcode/agents/
- .md 总数 = 93（find -name '*.md' 实测 93）= 顶层 88 + web-search-modules/ 5
- 其中 README-model-sync.md 是文档非 agent → 有效 agent 定义 87 个 + 5 个 web-search 模块（无 frontmatter，非独立 agent）
- 88 顶层 .md 中 83 个声明 model 行，5 个无 model 行（默认档）: agent-quality-auditor / architect / planner / task-orchestrator / README-model-sync
- model-tiers.json 档位映射: haiku=haiku-1, sonnet=sonnet-1, opus=opus-1, mini=mini, fast=fast, deepseek-pro=deepseek-v4-pro

## 分类全表（87 有效 agent，逐一覆盖无重复；族内顺序即文件序）

### F1 规划/编排/执行（6）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| planner.md | 任务拆解+排期+依赖管理+里程碑规划 | 默认（无 model 行） |
| plan-writer.md | 产出标准 task_plan.md 计划文档，只写文档不执行 | sonnet |
| task-orchestrator.md | 多 agent 流水线编排+状态管理+任务调度 | 默认（无 model 行） |
| complex-planner.md | 高复杂度任务 GLM5.3 升级规划，仅常规档同法失败≥2次启用 | GLM-5.3（独立账号） |
| complex-problem-solver.md | haiku/sonnet 反复失败时升级大模型解决多模块疑难 | sonnet |
| executor.md | 按既定 SOP 步骤清单执行批量任务 | agnes-3.0-flash |

### F2 基础设施/自治（7）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| auto-agent.md | 任务类型→最适 agent 的自动路由分发 | sonnet |
| context-manager.md | 上下文工程+向量库+知识图谱+智能记忆系统 | mini |
| cron-patrol.md | cron/watchdog/cleanup 日志尾部只读巡检出健康报告 | haiku |
| memory-librarian.md | 记忆文件查重+frontmatter 校验+MEMORY.md 索引同步 | haiku |
| meta-corrector.md | 死循环/反复失败/范围蔓延的元认知结构化纠偏 | sonnet |
| simple-agent.md | 轻量独立小任务（文件读写/小脚本/改配置/数据整理） | mini |
| time-keeper.md | 进度跟踪+超时预警+deadline 时间管理 | haiku |

### F3 代码/CLI 执行（4）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| cli-executor-agent.md | CLI 命令+Linux 工具发现+参数验证执行 | haiku |
| cli-tool-builder.md | Bun+TypeScript CLI 工具设计构建维护 | sonnet |
| code-assistant.md | 单文件代码编辑+创建+注释（≤3 文件硬限制） | agnes-3.0-flash |
| code-runner-agent.md | 隔离主上下文运行代码/脚本/测试 | mini |

### F4 代码开发/UI（5）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| build-error-resolver.md | 编译/类型/链接/lint 构建错误 surgical 修复 | sonnet |
| code-simplifier.md | 代码简化重构（清晰度+可维护性） | sonnet |
| frontend-developer.md | React/Vue/Angular 前端实现+性能优化 | sonnet |
| refactor-cleaner.md | 死代码清理+结构优化+代码瘦身 | sonnet |
| ui-designer.md | UI 视觉设计系统+组件库+pixel-perfect 界面 | sonnet |

### F5 调试/代码分析/日志（5）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| architect.md | 系统架构设计+技术选型（DDD/微服务/数据库） | 默认（无 model 行） |
| codebase-analyzer.md | 代码库体检+技术债+架构+风险+完成度评估 | sonnet |
| debugger.md | bug 定位+根因分析+回归隔离 | sonnet |
| log-distiller.md | 大日志/长输出/超大文件只读提炼结构化摘要 | haiku |
| performance-optimizer.md | 性能瓶颈定位+调优 | sonnet |

### F6 Git/仓库/配置运维（4）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| git-master.md | Git 提交/变基/历史管理操作 | mini |
| git-security-expert.md | Git 安全审计+密钥泄露+history 清理 | sonnet |
| json-edit-agent.md | JSON 配置/数据原子编辑+验证+回滚 | mini |
| worktree-janitor.md | worktree/wt 遗留分支+孤儿目录只读巡检 | haiku |

### F7 测试/QA 门控（4）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| api-tester.md | API 接口验证+性能压测+跨系统集成 QA | sonnet |
| quality-auditor.md | SO-4.5 发布前最终质量门控（继承 10 维审查，HARD_BLOCK） | sonnet |
| quality-control-agent.md | 每 phase 后只读合规校验，拦截子代理违规（防御层） | haiku |
| test-engineer.md | 单元/集成/E2E 测试框架+用例设计实现 | sonnet |

### F8 质检/审查/校验（11）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| agent-quality-auditor.md | Agent/Skill 流程质检+执行偏差审计+修正建议 | 默认（无 model 行） |
| code-reviewer.md | 代码审查（正确性+可维护性+安全+性能，含管线审计） | sonnet |
| content-origin-verify-agent.md | 内容原创性验证执行体（独立上下文跑 verify 脚本） | haiku |
| critic.md | 第三方挑刺审查（代码/计划/文档/配置多维批判） | sonnet |
| doc-sync-verify-agent.md | 文档同步检查执行体（跑 cli_doc-sync-check.ts） | haiku |
| frontmatter-linter.md | agent/skill frontmatter 字段机械校验（只报告不修复） | haiku |
| plan-bookkeeper.md | task-planner 三文件簿记回填+Phase 状态翻转+门控核查 | haiku |
| quality-check-agent.md | 流程质检+验收+交付物审查+流程合规检查 | haiku |
| quality-reviewer.md | 文章语义级主检查（9 维综合评判，Phase 3.5） | sonnet |
| verifier.md | 验证策略+证据驱动的完成检查 | haiku |
| writing-skills.md | 技能创建/改进+评测+基准测试+触发词优化 | haiku |

### F9 搜索/调研/代码探索（9+5 模块）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| doc-search-agent.md | 官方文档（API/SDK/框架/技术规范）搜索 | haiku |
| document-specialist.md | 官方文档与参考资料查询（与 doc-search 近重复） | haiku |
| explore-fb.md | 代码库只读搜索（agnes-2.5-flash 备用版） | agnes-2.5-flash |
| explore.md | 代码库只读搜索（Read/Grep/Glob 查文件/模式/调用关系） | haiku |
| forum-search-agent.md | 技术论坛/问答社区搜索（SO/Reddit/GitHub Issues/知乎） | haiku |
| oss-search-agent.md | 开源项目/包搜索（GitHub/Gitee/npm/pypi/Docker Hub） | haiku |
| search-query-analyst.md | 搜索词分析+否定关键词架构+查询意图映射（付费搜索） | haiku |
| web-search-agent.md | 通用网络搜索+多引擎（Bing/SearXNG）多源交叉验证 | mini |
| web-search-opencode.md | 互联网研究+调试方案搜索+多源信息深度整合 | haiku |
| web-search-modules/academic-papers.md | 学术论文搜索模块（从 web-search-agent 提取，无 frontmatter） | —（模块） |
| web-search-modules/chinese-tech.md | 中文技术社区搜索模块（无 frontmatter） | —（模块） |
| web-search-modules/general-web.md | 通用网页搜索模块（无 frontmatter） | —（模块） |
| web-search-modules/github-debug.md | GitHub/Debug 搜索模块（无 frontmatter） | —（模块） |
| web-search-modules/stackoverflow.md | StackOverflow 技术问答模块（无 frontmatter） | —（模块） |

### F10 Web/浏览器（3）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| article-site-router.md | 网站类型识别+访问路由（URL→站点画像+认证策略） | mini |
| browser-automation.md | Playwright 浏览器自动化（JS 渲染+登录态+点击/截图/表单） | mini |
| web-scraper.md | scrapling 静态站反爬抓取+TLS 伪装+结构化提取 | mini |

### F11 文章管线（12）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| article-batch-publisher.md | 批量发布 article.json 到 Django API（并发+限流+自动重试） | sonnet |
| article-content-editor.md | 文章正文精细编辑（按审查意见逐条改，不整篇重写） | deepseek-v4-pro |
| article-data-fetcher.md | 批量获取多篇文章完整数据（并行抓取+过滤+导出） | haiku |
| article-field-fixer.md | article.json 批量规范化（封面迁移+标题清洗+SEO 截断+品牌注入） | haiku |
| article-publish-phase-agent.md | 发布阶段执行体（Phase 5→6，失败 HARD_BLOCK） | haiku |
| article-research-heavy-agent.md | 重度研究执行体（Phase 0.75/1-Topic/1-SEO 策略类） | sonnet |
| article-research-phase-agent.md | 研究阶段执行体（Group A，不写内容） | haiku |
| article-reviewer.md | 文章质量审查（SEO/可读性/事实核查/编辑质量） | haiku |
| article-synthesis-phase-agent.md | 综合阶段执行体（Phase 2→2.7，raw research→结构化数据） | haiku |
| article-writer.md | 文章正文创作（读 writing_prompt.md 写长尾内容） | deepseek-v4-pro |
| article-writing-phase-agent.md | 写作阶段执行体（Group C，3.2 委托 article-writer） | haiku |
| data-synthesizer.md | 研究数据+抽取内容→结构化可执行洞见摘要（供文章生成） | haiku |

### F12 数据/AI/研究（9）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| ai-data-remediation-engineer.md | 自愈数据管道（air-gapped SLM+语义聚类自动修复异常） | sonnet |
| ai-engineer.md | AI/ML 工程（模型开发部署+智能特性+数据管道） | sonnet |
| analyst.md | 数据分析综合+多源洞见+结构化定量/定性呈现 | nvidia/nemotron-3-super-120b |
| analytics-reporter.md | 数据→商业洞见（仪表盘+KPI 追踪+可视化报表） | sonnet |
| data-cleaning-expert.md | 数据清洗（预处理+去重+标准化+格式转换+对齐） | haiku |
| data-consolidation-agent.md | 销售数据整合+实时报表仪表盘 | haiku |
| data-engineer.md | 数据管道+lakehouse+ETL/ELT/Spark/dbt/流式 | sonnet |
| database-optimizer.md | schema 设计+查询优化+索引策略+数据库性能调优 | sonnet |
| scientist.md | 数据驱动研究执行（方案设计+假设验证+实验） | sonnet |

### F13 营销/SEO/商务/文档（6）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| cross-border-e-commerce-specialist.md | 跨境电商全链路（Amazon/Shopee/Lazada/Temu/海外仓/合规） | sonnet |
| marketing-content-creator.md | 多平台内容策略+编辑日历+品牌故事+内容优化 | haiku |
| marketing-seo-specialist.md | SEO 策略（技术 SEO+内容优化+链接权重+自然搜索增长） | haiku |
| organic-content-strategist.md | 有机内容规划（产品作为解决方案自然融入） | haiku |
| seo-specialist.md | SEO 策略+数据驱动流量（与 marketing-seo 近重复） | mini |
| technical-writer.md | 技术文档+API 参考+README+教程 | sonnet |

### F14 杂项/测试（2）
| 文件名 | 中文职责一句话 | model 档 |
|---|---|---|
| general-purpose.md | 万能兜底子代理（无专门 agent 时的通用任务） | agnes-3.0-flash |
| test.md | 测试用 agent（description="test 用于测试"，无实际职责） | agnes-3.0-flash |

族计数核对: 6+7+4+5+5+4+4+11+9+3+12+9+6+2 = 87 agent ✓（另有 5 模块 + 1 README = 93 文件）

## model 档分布（88 顶层 .md，含 README）
- haiku: 34（33 "custom:*:haiku-1" + 1 UUID 直绑 9e22…/haiku-1）
- sonnet: 30
- mini: 10（9 "custom:*:mini" + 1 UUID 直绑 9e22…/mini）
- 无 model 行（默认档）: 5（agent-quality-auditor / architect / planner / task-orchestrator / README-model-sync）
- agnes-3.0-flash: 4（code-assistant / executor / general-purpose / test）
- deepseek-v4-pro: 2（article-writer 编码式 %2F / article-content-editor 普通斜杠）
- agnes-2.5-flash: 1（explore-fb）
- GLM-5.3（account:zai-individual-coding-plan）: 1（complex-planner）
- nvidia/nemotron-3-super-120b-a12b: 1（analyst）
合计 88 ✓；无 opus/fast 档使用者（model-tiers.json 定义了但无 agent 绑定）

## 领域覆盖小结（§小结）
- 族系丰富: F8 质检/审查 11 个（含多个 quality-* 近义体: quality-auditor/quality-check/quality-control/quality-reviewer + critic + verifier 六体）；F11 文章管线 12 个（高度专业化于"文章生成→发布"单一业务流）；F12 数据/AI 9 个；F9 搜索 9+5 模块
- 近重复/冗余信号: explore vs explore-fb、doc-search-agent vs document-specialist、seo-specialist vs marketing-seo-specialist、code-reviewer vs critic vs quality-check-agent 功能交叠
- **明显稀疏/缺失领域（0 个专用体）**:
  1. 媒体生成/编辑: 视频、音频、音乐、图像生成、storyboard、字幕（无一体）
  2. 翻译/本地化: 0
  3. DevOps/云原生/SRE/K8s/CI: 0
  4. 移动开发（iOS/Android）: 0
  5. 游戏开发: 0
  6. 应用安全/渗透测试: 0（git-security-expert 仅 Git 层）
  7. UX 研究/用户测试: 0（ui-designer 仅视觉设计）
  8. 财务/会计、HR/招聘、法务: 0
  9. 运维告警响应/故障恢复: 仅 cron-patrol 只读巡检，无修复体
- 结论: 资产库明显偏向「代码工程 + 文章内容管线 + 质检门控」三大簇，多媒体/翻译/DevOps/安全领域完全空白；媒体 11 类任务当前只能走 executor 兜底（与 [sub:audit-coverage] 的 A 类缺口互证）

## T5 最终结论（8 字段）
status: done
acceptance: 3/3 pass — [93 个文件全部覆盖分类（87 agent 逐一入表+5 模块+1 文档，每行含 文件名/职责一句话/model 档）; 末尾「领域覆盖小结」含每族 agent 数 + 稀疏/缺失领域列表（媒体/音频/音乐/字幕/翻译/DevOps/移动/游戏/安全均 0 专用体）; 产出落检查点（本文件）+ findings 追加]
files: /mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/1-inventory.md(新建); /mnt/data/dev/task-planner-skill/plans/task-v125/findings.md(追加)
evidence: find /home/terry/.zcode/agents -name '*.md' | wc -l → 93; grep -hE '^model:' ./*.md 归一统计 → haiku34/sonnet30/mini10/默认5/agnes3flash4/deepseek2/agnes2flash1/GLM1/nemotron1
checkpoint: /mnt/data/dev/task-planner-skill/plans/task-v125/subagent-state/1-inventory.md (status: done)
findings_written: findings.md > ## Research Findings > #### [sub:audit-inventory]
blockers: none
confidence: HIGH
