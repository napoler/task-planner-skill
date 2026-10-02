# Task Plan: [文章创作任务]
<!-- template_type: writing -->
<!-- 写作型模板 — 适用于文章管线 Phase 0→6 -->

<!-- plan_tier: standard -->
## Goal
[一句话描述文章目标，如：为 soundgearx 站点创作关于 XXX 的长尾关键词文章]

## 🔍 Code Review 配置
| 字段 | 值 |
|------|-----|
| `code_review` | `n/a` / `required` |
| `对齐审查` | `[登记]` | Rule 42.6 消费：完成前跑 alignment-review;变更记录随交付落盘;mini 豁免 |
| `自动超时默认项` | `[询问点: 默认选项/超时值]` | Rule 44 消费：默认项+超时 5 分钟;低区分度 44.2 直接裁决;mini 豁免 |
| `质量审查工具` | `[检测结论]` | Rule 42 消费：42.2 四级检测登记;执行期用登记工具;mini 豁免 |

## ✅ Verification Contract
| # | 判定标准 | 验证方式 | 证据路径 |
|---|----------|----------|---------|
| VC-1 | article.json schema 通过 | python3 scripts/article_json_editor.py validate data/{site}/{id}/article | -- |
| VC-2 | content 原创性 ≥15% | python3 scripts/verify_content_originality.py --threshold 0.85 | tmp/originality-report.json |
| VC-3 | 封面域白名单通过 | grep storage.maomihezi.com article.json | article.json |
| VC-4 | SEO 字段完整 | jq '.meta_title, .focus_keyword' article.json | article.json |
| VC-5 | 配图 ≥3 张 | jq '.images | length' article.json | article.json |
| VC-6 | 无 Amazon 链接 | grep -c "amazon.com" content | content 字段 |

> 注：VC 表中脚本路径为示例值（目标项目相对路径），非本技能仓文件

## ⚠️ 执行范围限制
| 类别 | 允许的文件 | 禁止 |
|-------|------------|------|
| 文章数据 | data/{site}/{id}/article/* | data/ 其他站点 |
| 研究数据 | data/{site}/{id}/research/* | 其他路径 |
| 计划文件 | plans/task-{id}/* | 其他 plan 目录 |
| Skill 文件 | 仅本 skill 内部 | 其他 skill/agent 文件 |

## 📚 必要知识储备（任务知识库对齐 — 开工前必填）

> 目的：对齐任务知识库。列出本任务依赖的规范/文档/文献/图书等知识源，Phase 1 开工前逐项确认可获取；`必读` 项无法获取 → STOP 记入 findings.md Errors，禁止凭记忆硬写。

| 类别 | 名称/主题 | 定位（路径/URL/版本/commit SHA） | 必读级别 | 已确认 |
|------|-----------|--------------------------------|---------|--------|
| 规范/标准 |  |  | 必读/参考 | ☐ |
| 官方文档 |  |  | 必读/参考 | ☐ |
| 项目内部文档/知识库 |  |  | 参考 | ☐ |
| 文献/论文 |  |  | 参考 | ☐ |
| 图书/教程 |  |  | 参考 | ☐ |
| 风格/SEO 规范 | 写作风格指南与 SEO 基线 + 主题权威文献 | 路径/URL | 必读 | ☐ |

**填写规则**：① `定位` 必须可唯一定位（绝对路径/URL+版本）；② `必读` 项缺失 → 停止执行并在 Errors Encountered 登记；③ 引用格式对齐 SKILL.md「调研类操作·强制引用格式」。

## 🧰 工具选择与编排（Rule 40 — 计划期主动分析）
逐 Phase 登记工具面与理由;Executor 字段仍是委派门控机器事实源;mini 豁免
| Phase | 命中工具面 | 选择理由 |
|-------|----------|---------|
| Phase 1 | [如: Agent 子代理 executor(sonnet-1)] | [一句话理由] |

## Phases（对齐管线 Phase 0→6）

### Phase 1: 研究阶段 (Phase 0.5→1.5)
- [ ] Phase 0.5: research_data.json validator size-fail exit 7
- [ ] Phase 1-KW-Intel: keyword intel gather
- [ ] Phase 1-Topic: topic validation
- [ ] Phase 1-SEO: SEO tag generation
- [ ] Phase 1.5: synthesis prep
- [ ] 知识储备必读项已确认可获取(勾选「必要知识储备」表"已确认"列)
- **Status:** pending
- **Executor:** article-writer

### Phase 2: 合成阶段 (Phase 2→2.7)
- [ ] Phase 2: raw research → structured
- [ ] Phase 2.5: compression
- [ ] Phase 2.7: writing_context.md 生成
- **Status:** pending
- **Executor:** article-writer

### Phase 3: 写作阶段 (Phase 3.1→4)
- [ ] Phase 3.1: title draft
- [ ] Phase 3.2: body writing（fork article-phase-3-2-writer，deepseek-v4-pro 强制）
- [ ] Phase 3.3: assemble_article.py
- [ ] Phase 3.5: quality-reviewer 审查（含去 AI 化 10 条清单 + 五维评分卡 ≥4.0 门控，指针 references/methodology.md §内容质量 Q3/Q4；开关键 content_quality_enforce）
- [ ] Phase 4: schema 验证
- **Status:** pending
- **Executor:** article-writer

### Phase 4: 发布阶段 (Phase 5→6)
- [ ] Phase 5: Django API publish
- [ ] Phase 6: post-publish verify
- **Status:** pending
- **Executor:** article-writer

## 🚨 Drift Log
| 时间 | 检测结果 | 涉及VC | 结论 |
|------|---------|--------|------|
|      |          |        |      |

## 📊 委派统计（Rule 25.4 — 终验前必填）
<!-- 
  WHAT: 本计划子代理 vs 主进程的执行分布统计。
  WHY: 子代理占比需要可见反馈闭环;委派率 < config.json#delegation_rate_floor(默认 0.7)或含白名单外理由 → outcome 最高 PARTIAL(白名单见 critical-rules.md Rule 25.3)。
  WHEN: 每个 Phase complete 后更新;终验交付前必须完整。
-->
| 字段 | 值 |
|------|-----|
| 子代理执行 Phase 数 / 总 Phase 数 |  /  |
| 主进程直做 Phase 清单 | （含例外理由） |
| 委派率 | （< delegation_rate_floor 默认 0.7,或含白名单外理由 → 最高 PARTIAL） |

## 🔗 Subagent Handoff 登记表（Rule 22.5 必填）
每次 Agent() 派发前填一行;子代理返回后 Read 产出+findings 回填双条件才勾 verify_done(Rule 22.5)
| # | 时间 | subagent_type | 任务目标(≤1 句) | 状态 | 结论摘要(≤3 行) | 证据(file:line) | findings 落点 | checkpoint 路径 |
|---|------|--------------|----------------|------|---------------|---------------|--------------|----------------|
| 1 |  |  |  | queued |  |  |  |  |
